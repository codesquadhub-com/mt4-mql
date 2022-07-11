/**
 * NonLag Moving Average
 *
 * A moving average using a cosine wave function for calculating bar weights. Corrected and enhanced version of the original
 * version published by Igor Durkin aka igorad.
 *
 * Indicator buffers for iCustom():
 *  � MovingAverage.MODE_MA:    MA values
 *  � MovingAverage.MODE_TREND: trend direction and length
 *    - trend direction:        positive values denote an uptrend (+1...+n), negative values a downtrend (-1...-n)
 *    - trend length:           the absolute direction value is the length of the trend in bars since the last reversal
 *
 *  @link  https://www.forexfactory.com/thread/571026#                                           [NonLag Moving Average v4.0]
 *  @link  http://www.yellowfx.com/nonlagma-v7-1-mq4-indicator.htm#                              [NonLag Moving Average v7.1]
 *  @link  http://www.mql5.com/en/forum/175037/page62#comment_4583907                            [NonLag Moving Average v7.8]
 *  @link  https://www.mql5.com/en/forum/175037/page74#comment_4584032                           [NonLag Moving Average v7.9]
 */
#include <stddefines.mqh>
int   __InitFlags[];
int __DeinitFlags[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern int    WaveCycle.Periods              = 20;                // bar periods per cosine wave cycle
extern string MA.AppliedPrice                = "Open | High | Low | Close* | Median | Average | Typical | Weighted";
extern double MA.Filter                      = 0.68;              // min. MA change in std-deviations for a trend reversal (use half of igorad's PctFilter for corresponding filtering)

extern string Draw.Type                      = "Line* | Dot";
extern int    Draw.Width                     = 3;
extern color  Color.UpTrend                  = Magenta;  //RoyalBlue;
extern color  Color.DownTrend                = Yellow;   //Red;
extern int    Max.Bars                       = 10000;             // max. values to calculate (-1: all available)
extern int    PeriodStepper.StepSize         = 0;                 // parameter stepper for WaveCycle.Periods

extern string ___a__________________________ = "=== Signaling ===";
extern bool   Signal.onTrendChange           = false;
extern bool   Signal.onTrendChange.Sound     = true;
extern string Signal.onTrendChange.SoundUp   = "Signal Up.wav";
extern string Signal.onTrendChange.SoundDown = "Signal Down.wav";
extern bool   Signal.onTrendChange.Popup     = false;
extern bool   Signal.onTrendChange.Mail      = false;
extern bool   Signal.onTrendChange.SMS       = false;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <stdfunctions.mqh>
#include <rsfLib.mqh>
#include <functions/ConfigureSignals.mqh>
#include <functions/HandleCommands.mqh>
#include <functions/IsBarOpen.mqh>
#include <functions/Trend.mqh>
#include <functions/ta/NLMA.mqh>

#define MODE_MA_FILTERED      MovingAverage.MODE_MA      // indicator buffer ids
#define MODE_TREND            MovingAverage.MODE_TREND
#define MODE_UPTREND          2
#define MODE_DOWNTREND        3
#define MODE_UPTREND2         4
#define MODE_MA_RAW           5
#define MODE_MA_CHANGE        6
#define MODE_AVG              7

#property indicator_chart_window
#property indicator_buffers   5                          // visible buffers
int       terminal_buffers  = 8;                         // all buffers

#property indicator_color1    CLR_NONE
#property indicator_color2    CLR_NONE
#property indicator_color3    CLR_NONE
#property indicator_color4    CLR_NONE
#property indicator_color5    CLR_NONE

double maRaw     [];                                     // MA raw main values:      invisible
double maFiltered[];                                     // MA filtered main values: invisible, displayed in legend and "Data" window
double trend     [];                                     // trend direction:         invisible, displayed in "Data" window
double uptrend   [];                                     // uptrend values:          visible
double downtrend [];                                     // downtrend values:        visible
double uptrend2  [];                                     // single-bar uptrends:     visible

double maChange  [];                                     // absolute change of current maRaw[] to previous maFiltered[]
double maAverage [];                                     // average of maChange[] over the last 'waveCyclePeriods' bars

int    waveCycles = 4;                                   // 4 initial cycles (1 more is added later)
int    waveCyclePeriods;
int    maPeriods;
int    maAppliedPrice;
double maWeights[];                                      // bar weighting of the MA
int    drawType;
int    maxValues;

string indicatorName = "";
string legendLabel   = "";
string legendInfo    = "";                               // additional chart legend info
bool   enableMultiColoring;

bool   signalTrendChange;
bool   signalTrendChange.sound;
bool   signalTrendChange.popup;
bool   signalTrendChange.mail;
string signalTrendChange.mailSender   = "";
string signalTrendChange.mailReceiver = "";
bool   signalTrendChange.sms;
string signalTrendChange.smsReceiver = "";

// period stepper directions
#define STEP_UP    1
#define STEP_DOWN -1


/**
 * Initialization
 *
 * @return int - error status
 */
int onInit() {
   string indicator = ProgramName(MODE_NICE);

   // validate inputs
   // WaveCycle.Periods
   waveCyclePeriods = WaveCycle.Periods;
   if (AutoConfiguration) waveCyclePeriods = GetConfigInt(indicator, "WaveCycle.Periods", waveCyclePeriods);
   if (waveCyclePeriods < 3)                                 return(catch("onInit(1)  invalid input parameter WaveCycle.Periods: "+ waveCyclePeriods +" (min. 3)", ERR_INVALID_INPUT_PARAMETER));
   // MA.AppliedPrice
   string sValues[], sValue = MA.AppliedPrice;
   if (AutoConfiguration) sValue = GetConfigString(indicator, "MA.AppliedPrice", sValue);
   if (Explode(sValue, "*", sValues, 2) > 1) {
      int size = Explode(sValues[0], "|", sValues, NULL);
      sValue = sValues[size-1];
   }
   sValue = StrTrim(sValue);
   maAppliedPrice = StrToPriceType(sValue, F_PARTIAL_ID|F_ERR_INVALID_PARAMETER);
   if (maAppliedPrice==-1 || maAppliedPrice > PRICE_AVERAGE) return(catch("onInit(2)  invalid input parameter MA.AppliedPrice: "+ DoubleQuoteStr(sValue), ERR_INVALID_INPUT_PARAMETER));
   MA.AppliedPrice = PriceTypeDescription(maAppliedPrice);
   // MA.Filter
   if (AutoConfiguration) MA.Filter = GetConfigDouble(indicator, "MA.Filter", MA.Filter);
   if (MA.Filter < 0)                                        return(catch("onInit(3)  invalid input parameter MA.Filter: "+ NumberToStr(MA.Filter, ".1+") +" (must be >= 0)", ERR_INVALID_INPUT_PARAMETER));
   // Draw.Type
   sValue = Draw.Type;
   if (AutoConfiguration) sValue = GetConfigString(indicator, "Draw.Type", sValue);
   if (Explode(sValue, "*", sValues, 2) > 1) {
      size = Explode(sValues[0], "|", sValues, NULL);
      sValue = sValues[size-1];
   }
   sValue = StrToLower(StrTrim(sValue));
   if      (StrStartsWith("line", sValue)) { drawType = DRAW_LINE;  Draw.Type = "Line"; }
   else if (StrStartsWith("dot",  sValue)) { drawType = DRAW_ARROW; Draw.Type = "Dot";  }
   else                                                      return(catch("onInit(4)  invalid input parameter Draw.Type: "+ DoubleQuoteStr(sValue), ERR_INVALID_INPUT_PARAMETER));
   // Draw.Width
   if (AutoConfiguration) Draw.Width = GetConfigInt(indicator, "Draw.Width", Draw.Width);
   if (Draw.Width < 0)                                       return(catch("onInit(5)  invalid input parameter Draw.Width: "+ Draw.Width, ERR_INVALID_INPUT_PARAMETER));
   // colors: after deserialization the terminal might turn CLR_NONE (0xFFFFFFFF) into Black (0xFF000000)
   if (AutoConfiguration) Color.UpTrend   = GetConfigColor(indicator, "Color.UpTrend",   Color.UpTrend  );
   if (AutoConfiguration) Color.DownTrend = GetConfigColor(indicator, "Color.DownTrend", Color.DownTrend);
   if (Color.UpTrend   == 0xFF000000) Color.UpTrend   = CLR_NONE;
   if (Color.DownTrend == 0xFF000000) Color.DownTrend = CLR_NONE;
   // Max.Bars
   if (AutoConfiguration) Max.Bars = GetConfigInt(indicator, "Max.Bars", Max.Bars);
   if (Max.Bars < -1)                                        return(catch("onInit(6)  invalid input parameter Max.Bars: "+ Max.Bars, ERR_INVALID_INPUT_PARAMETER));
   maxValues = ifInt(Max.Bars==-1, INT_MAX, Max.Bars);
   // PeriodStepper.StepSize
   if (PeriodStepper.StepSize < 0)                           return(catch("onInit(7)  invalid input parameter PeriodStepper.StepSize: "+ PeriodStepper.StepSize +" (must be >= 0)", ERR_INVALID_INPUT_PARAMETER));

   // signaling
   signalTrendChange       = Signal.onTrendChange;
   signalTrendChange.sound = Signal.onTrendChange.Sound;
   signalTrendChange.popup = Signal.onTrendChange.Popup;
   signalTrendChange.mail  = Signal.onTrendChange.Mail;
   signalTrendChange.sms   = Signal.onTrendChange.SMS;
   legendInfo              = "";
   string signalId = "Signal.onTrendChange";
   if (!ConfigureSignals2(signalId, AutoConfiguration, signalTrendChange)) return(last_error);
   if (signalTrendChange) {
      if (!ConfigureSignalsBySound2(signalId, AutoConfiguration, signalTrendChange.sound))                                                              return(last_error);
      if (!ConfigureSignalsByPopup (signalId, AutoConfiguration, signalTrendChange.popup))                                                              return(last_error);
      if (!ConfigureSignalsByMail2 (signalId, AutoConfiguration, signalTrendChange.mail, signalTrendChange.mailSender, signalTrendChange.mailReceiver)) return(last_error);
      if (!ConfigureSignalsBySMS2  (signalId, AutoConfiguration, signalTrendChange.sms, signalTrendChange.smsReceiver))                                 return(last_error);
      if (signalTrendChange.sound || signalTrendChange.popup || signalTrendChange.mail || signalTrendChange.sms) {
         legendInfo = StrLeft(ifString(signalTrendChange.sound, "sound,", "") + ifString(signalTrendChange.popup, "popup,", "") + ifString(signalTrendChange.mail, "mail,", "") + ifString(signalTrendChange.sms, "sms,", ""), -1);
      }
      else signalTrendChange = false;
   }

   // buffer management and display options
   SetIndexBuffer(MODE_MA_RAW,      maRaw     );   // MA raw main values:      invisible
   SetIndexBuffer(MODE_MA_FILTERED, maFiltered);   // MA filtered main values: invisible, displayed in legend and "Data" window
   SetIndexBuffer(MODE_TREND,       trend     );   // trend direction:         invisible, displayed in "Data" window
   SetIndexBuffer(MODE_UPTREND,     uptrend   );   // uptrend values:          visible
   SetIndexBuffer(MODE_DOWNTREND,   downtrend );   // downtrend values:        visible
   SetIndexBuffer(MODE_UPTREND2,    uptrend2  );   // single-bar uptrends:     visible
   SetIndexBuffer(MODE_MA_CHANGE,   maChange  );   //                          invisible
   SetIndexBuffer(MODE_AVG,         maAverage );   //                          invisible
   SetIndicatorOptions();

   // calculate NLMA bar weights
   NLMA.CalculateWeights(waveCycles, waveCyclePeriods, maWeights);
   maPeriods = ArraySize(maWeights);

   // chart legend and coloring
   if (!__isSuperContext) {
      legendLabel = CreateLegendLabel();
      RegisterObject(legendLabel);
      enableMultiColoring = true;
   }
   else {
      enableMultiColoring = false;
   }
   return(catch("onInit(8)"));
}


/**
 * Deinitialization
 *
 * @return int - error status
 */
int onDeinit() {
   RepositionLegend();
   return(catch("onDeinit(1)"));
}


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   // on the first tick after terminal start buffers may not yet be initialized (spurious issue)
   if (!ArraySize(maRaw)) return(logInfo("onTick(1)  sizeof(maRaw) = 0", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // process incoming commands (may rewrite ValidBars/ChangedBars/ShiftedBars)
   if (__isChart && PeriodStepper.StepSize) HandleCommands("ParameterStepper", false);

   // reset buffers before performing a full recalculation
   if (!ValidBars) {
      ArrayInitialize(maRaw,                0);
      ArrayInitialize(maFiltered, EMPTY_VALUE);
      ArrayInitialize(maChange,             0);
      ArrayInitialize(maAverage,            0);
      ArrayInitialize(trend,                0);
      ArrayInitialize(uptrend,    EMPTY_VALUE);
      ArrayInitialize(downtrend,  EMPTY_VALUE);
      ArrayInitialize(uptrend2,   EMPTY_VALUE);
      SetIndicatorOptions();
   }

   // synchronize buffers with a shifted offline chart
   if (ShiftedBars > 0) {
      ShiftDoubleIndicatorBuffer(maRaw,      Bars, ShiftedBars,           0);
      ShiftDoubleIndicatorBuffer(maFiltered, Bars, ShiftedBars, EMPTY_VALUE);
      ShiftDoubleIndicatorBuffer(maChange,   Bars, ShiftedBars,           0);
      ShiftDoubleIndicatorBuffer(maAverage,  Bars, ShiftedBars,           0);
      ShiftDoubleIndicatorBuffer(trend,      Bars, ShiftedBars,           0);
      ShiftDoubleIndicatorBuffer(uptrend,    Bars, ShiftedBars, EMPTY_VALUE);
      ShiftDoubleIndicatorBuffer(downtrend,  Bars, ShiftedBars, EMPTY_VALUE);
      ShiftDoubleIndicatorBuffer(uptrend2,   Bars, ShiftedBars, EMPTY_VALUE);
   }

   // calculate start bar
   int bars     = Min(ChangedBars, maxValues);
   int startbar = Min(bars-1, Bars-maPeriods);
   if (startbar < 0) return(logInfo("onTick(2)  Tick="+ Ticks +"  Bars="+ Bars +"  needed="+ maPeriods, ERR_HISTORY_INSUFFICIENT));

   double sum, stdDev, minChange;

   // recalculate changed bars
   for (int bar=startbar; bar >= 0; bar--) {
      maRaw[bar] = 0;
      for (int i=0; i < maPeriods; i++) {
         maRaw[bar] += maWeights[i] * GetPrice(maAppliedPrice, bar+i);
      }
      maFiltered[bar] = maRaw[bar];

      if (MA.Filter > 0) {
         maChange[bar] = maFiltered[bar] - maFiltered[bar+1];        // calculate the change of current raw to previous filtered MA
         sum = 0;
         for (i=0; i < waveCyclePeriods; i++) {                      // calculate average(change) over last 'waveCyclePeriods'
            sum += maChange[bar+i];
         }
         maAverage[bar] = sum/waveCyclePeriods;

         if (maChange[bar] * trend[bar+1] < 0) {                     // on opposite signs = possible trend reversal
            sum = 0;                                                 // calculate stdDeviation(maChange[]) over last 'waveCyclePeriods'
            for (i=0; i < waveCyclePeriods; i++) {
               sum += MathPow(maChange[bar+i] - maAverage[bar+i], 2);
            }
            stdDev = MathSqrt(sum/waveCyclePeriods);
            minChange = MA.Filter * stdDev;                          // calculate required min. change

            if (MathAbs(maChange[bar]) < minChange) {
               maFiltered[bar] = maFiltered[bar+1];                  // discard current raw MA if change is smaller
            }
         }
      }
      Trend.UpdateDirection(maFiltered, bar, trend, uptrend, downtrend, uptrend2, enableMultiColoring, enableMultiColoring, drawType, Digits);
   }

   if (!__isSuperContext) {
      Trend.UpdateLegend(legendLabel, indicatorName, legendInfo, Color.UpTrend, Color.DownTrend, maFiltered[0], Digits, trend[0], Time[0]);

      // monitor trend reversals
      if (signalTrendChange) /*&&*/ if (IsBarOpen()) {
         int iTrend = Round(trend[1]);
         if      (iTrend ==  1) onTrendChange(MODE_UPTREND);
         else if (iTrend == -1) onTrendChange(MODE_DOWNTREND);
      }
   }
   return(last_error);
}


/**
 * Event handler for trend changes.
 *
 * @param  int trend - direction
 *
 * @return bool - success status
 */
bool onTrendChange(int trend) {
   string message="", accountTime="("+ TimeToStr(TimeLocal(), TIME_MINUTES|TIME_SECONDS) +", "+ GetAccountAlias() +")";
   int error = NO_ERROR;

   if (trend == MODE_UPTREND) {
      message = indicatorName +" turned up (bid: "+ NumberToStr(Bid, PriceFormat) +")";
      if (IsLogInfo()) logInfo("onTrendChange(1)  "+ message);
      message = Symbol() +","+ PeriodDescription() +": "+ message;

      if (signalTrendChange.popup)          Alert(message);
      if (signalTrendChange.sound) error |= PlaySoundEx(Signal.onTrendChange.SoundUp);
      if (signalTrendChange.mail)  error |= !SendEmail(signalTrendChange.mailSender, signalTrendChange.mailReceiver, message, message + NL + accountTime);
      if (signalTrendChange.sms)   error |= !SendSMS(signalTrendChange.smsReceiver, message + NL + accountTime);
      return(!error);
   }

   if (trend == MODE_DOWNTREND) {
      message = indicatorName +" turned down (bid: "+ NumberToStr(Bid, PriceFormat) +")";
      if (IsLogInfo()) logInfo("onTrendChange(2)  "+ message);
      message = Symbol() +","+ PeriodDescription() +": "+ message;

      if (signalTrendChange.popup)          Alert(message);
      if (signalTrendChange.sound) error |= PlaySoundEx(Signal.onTrendChange.SoundDown);
      if (signalTrendChange.mail)  error |= !SendEmail(signalTrendChange.mailSender, signalTrendChange.mailReceiver, message, message + NL + accountTime);
      if (signalTrendChange.sms)   error |= !SendSMS(signalTrendChange.smsReceiver, message + NL + accountTime);
      return(!error);
   }

   return(!catch("onTrendChange(3)  invalid parameter trend: "+ trend, ERR_INVALID_PARAMETER));
}


/**
 * Process an incoming command.
 *
 * @param  string cmd                  - command name
 * @param  string params [optional]    - command parameters (default: none)
 * @param  string modifiers [optional] - command modifiers (default: none)
 *
 * @return bool - success status of the executed command
 */
bool onCommand(string cmd, string params="", string modifiers="") {
   string fullCmd = cmd +":"+ params +":"+ modifiers;

   static int lastTickcount = 0;
   int tickcount = StrToInteger(params);
   if (tickcount <= lastTickcount) return(false);
   lastTickcount = tickcount;

   if (cmd == "parameter-up")   return(PeriodStepper(STEP_UP));
   if (cmd == "parameter-down") return(PeriodStepper(STEP_DOWN));

   return(!logNotice("onCommand(1)  unsupported command: \""+ fullCmd +"\""));
}


/**
 * Change the currently active parameter "Periods".
 *
 * @param  int direction - STEP_UP | STEP_DOWN
 *
 * @return bool - success status
 */
bool PeriodStepper(int direction) {
   if (direction!=STEP_UP && direction!=STEP_DOWN) return(!catch("PeriodStepper(1)  invalid parameter direction: "+ direction, ERR_INVALID_PARAMETER));

   if (waveCyclePeriods + direction*PeriodStepper.StepSize < 3) {
      PlaySoundEx("Plonk.wav");
      return(false);
   }
   if (direction == STEP_UP) waveCyclePeriods += PeriodStepper.StepSize;
   else                      waveCyclePeriods -= PeriodStepper.StepSize;

   ChangedBars = Bars;
   ValidBars   = 0;
   ShiftedBars = 0;

   if (NLMA.CalculateWeights(waveCycles, waveCyclePeriods, maWeights)) {
      maPeriods = ArraySize(maWeights);
      return(true);
   }
   return(false);
}


/**
 * Get the price of the specified type at the given bar offset.
 *
 * @param  int type - price type
 * @param  int i    - bar offset
 *
 * @return double - price or NULL in case of errors
 */
double GetPrice(int type, int i) {
   if (i < 0 || i >= Bars) return(!catch("GetPrice(1)  invalid parameter i: "+ i +" (out of range)", ERR_INVALID_PARAMETER));

   switch (type) {
      case PRICE_CLOSE:                                                          // 0
      case PRICE_BID:      return(Close[i]);                                     // 8
      case PRICE_OPEN:     return( Open[i]);                                     // 1
      case PRICE_HIGH:     return( High[i]);                                     // 2
      case PRICE_LOW:      return(  Low[i]);                                     // 3
      case PRICE_MEDIAN:                                                         // 4: (H+L)/2
      case PRICE_TYPICAL:                                                        // 5: (H+L+C)/3
      case PRICE_WEIGHTED: return(iMA(NULL, NULL, 1, 0, MODE_SMA, type, i));     // 6: (H+L+C+C)/4
      case PRICE_AVERAGE:  return((Open[i] + High[i] + Low[i] + Close[i])/4);    // 7: (O+H+L+C)/4
   }
   return(!catch("GetPrice(2)  invalid or unsupported price type: "+ type, ERR_INVALID_PARAMETER));
}


/**
 * Workaround for various terminal bugs when setting indicator options. Usually options are set in init(). However after
 * recompilation options must be set in start() to not be ignored.
 */
void SetIndicatorOptions() {
   IndicatorBuffers(terminal_buffers);

   string sAppliedPrice = ifString(maAppliedPrice==PRICE_CLOSE, "", ", "+ PriceTypeDescription(maAppliedPrice));
   indicatorName = "NonLagMA("+ ifString(PeriodStepper.StepSize, "var:", "") + waveCyclePeriods +"/"+ maPeriods + sAppliedPrice +")";
   string shortName = "NLMA("+ waveCyclePeriods +")";
   IndicatorShortName(shortName);

   int draw_type = ifInt(Draw.Width, drawType, DRAW_NONE);

   SetIndexStyle(MODE_MA_FILTERED, DRAW_NONE, EMPTY, EMPTY,      CLR_NONE       );                                     SetIndexLabel(MODE_MA_FILTERED, shortName);
   SetIndexStyle(MODE_TREND,       DRAW_NONE, EMPTY, EMPTY,      CLR_NONE       );                                     SetIndexLabel(MODE_TREND,       shortName +" trend");
   SetIndexStyle(MODE_UPTREND,     draw_type, EMPTY, Draw.Width, Color.UpTrend  ); SetIndexArrow(MODE_UPTREND,   158); SetIndexLabel(MODE_UPTREND,     NULL);
   SetIndexStyle(MODE_DOWNTREND,   draw_type, EMPTY, Draw.Width, Color.DownTrend); SetIndexArrow(MODE_DOWNTREND, 158); SetIndexLabel(MODE_DOWNTREND,   NULL);
   SetIndexStyle(MODE_UPTREND2,    draw_type, EMPTY, Draw.Width, Color.UpTrend  ); SetIndexArrow(MODE_UPTREND2,  158); SetIndexLabel(MODE_UPTREND2,    NULL);
   IndicatorDigits(Digits);
}


/**
 * Return a string representation of the input parameters (for logging purposes).
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("WaveCycle.Periods=",              WaveCycle.Periods,                              ";"+ NL,
                            "MA.AppliedPrice=",                DoubleQuoteStr(MA.AppliedPrice),                ";"+ NL,
                            "MA.Filter=",                      NumberToStr(MA.Filter, ".1+"),                  ";"+ NL,

                            "Draw.Type=",                      DoubleQuoteStr(Draw.Type),                      ";"+ NL,
                            "Draw.Width=",                     Draw.Width,                                     ";"+ NL,
                            "Color.UpTrend=",                  ColorToStr(Color.UpTrend),                      ";"+ NL,
                            "Color.DownTrend=",                ColorToStr(Color.DownTrend),                    ";"+ NL,
                            "Max.Bars=",                       Max.Bars,                                       ";"+ NL,
                            "PeriodStepper.StepSize=",         PeriodStepper.StepSize,                         ";"+ NL,

                            "Signal.onTrendChange=",           BoolToStr(Signal.onTrendChange),                ";"+ NL,
                            "Signal.onTrendChange.Sound=",     BoolToStr(Signal.onTrendChange.Sound),          ";"+ NL,
                            "Signal.onTrendChange.SoundUp=",   DoubleQuoteStr(Signal.onTrendChange.SoundUp),   ";"+ NL,
                            "Signal.onTrendChange.SoundDown=", DoubleQuoteStr(Signal.onTrendChange.SoundDown), ";"+ NL,
                            "Signal.onTrendChange.Popup=",     BoolToStr(Signal.onTrendChange.Popup),          ";"+ NL,
                            "Signal.onTrendChange.Mail=",      BoolToStr(Signal.onTrendChange.Mail),           ";"+ NL,
                            "Signal.onTrendChange.SMS=",       BoolToStr(Signal.onTrendChange.SMS),            ";")
   );
}
