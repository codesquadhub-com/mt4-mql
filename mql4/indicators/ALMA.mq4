/**
 * Arnaud Legoux Moving Average
 *
 *
 * A moving average with bar weigths using a Gaussian distribution function.
 *
 * Indicator buffers for iCustom():
 *  � MovingAverage.MODE_MA:    MA values
 *  � MovingAverage.MODE_TREND: trend direction and length
 *    - trend direction:        positive values denote an uptrend (+1...+n), negative values a downtrend (-1...-n)
 *    - trend length:           the absolute direction value is the length of the trend in bars since the last reversal
 *
 * @author  Arnaud Legoux
 * @see     http://web.archive.org/web/20180307031850/http://www.arnaudlegoux.com/
 *
 */
#include <stddefines.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern int    MA.Periods           = 38;
extern string MA.AppliedPrice      = "Open | High | Low | Close* | Median | Typical | Weighted";
extern double Distribution.Offset  = 0.85;               // Gaussian distribution offset: 0..1 (offset of parabola vertex)
extern double Distribution.Sigma   = 6.0;                // Gaussian distribution sigma        (parabola steepness)

extern color  Color.UpTrend        = Blue;
extern color  Color.DownTrend      = Red;
extern string Draw.Type            = "Line* | Dot";
extern int    Draw.Width           = 3;
extern int    Max.Values           = 5000;               // max. amount of values to calculate (-1: all)
extern string __________________________;

extern string Signal.onTrendChange = "on | off | auto*";
extern string Signal.Sound         = "on | off | auto*";
extern string Signal.Mail.Receiver = "on | off | auto* | {email-address}";
extern string Signal.SMS.Receiver  = "on | off | auto* | {phone-number}";

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <stdfunctions.mqh>
#include <rsfLibs.mqh>
#include <functions/@ALMA.mqh>
#include <functions/@Trend.mqh>
#include <functions/BarOpenEvent.mqh>
#include <functions/Configure.Signal.mqh>
#include <functions/Configure.Signal.Mail.mqh>
#include <functions/Configure.Signal.SMS.mqh>
#include <functions/Configure.Signal.Sound.mqh>

#define MODE_MA               MovingAverage.MODE_MA      // indicator buffer ids
#define MODE_TREND            MovingAverage.MODE_TREND
#define MODE_UPTREND          2
#define MODE_DOWNTREND        3
#define MODE_UPTREND1         MODE_UPTREND
#define MODE_UPTREND2         4

#property indicator_chart_window
#property indicator_buffers   5

#property indicator_color1    CLR_NONE
#property indicator_color2    CLR_NONE
#property indicator_color3    CLR_NONE
#property indicator_color4    CLR_NONE
#property indicator_color5    CLR_NONE

double main     [];                                      // ALMA main values:    invisible, displayed in legend and "Data" window
double trend    [];                                      // trend direction:     invisible, displayed in "Data" window
double uptrend1 [];                                      // uptrend values:      visible
double downtrend[];                                      // downtrend values:    visible
double uptrend2 [];                                      // single-bar uptrends: visible

int    maAppliedPrice;
double almaWeights[];                                    // bar weights

int    maxValues;
int    drawType      = DRAW_LINE;                        // DRAW_LINE | DRAW_ARROW
int    drawArrowSize = 1;                                // default symbol size for Draw.Type="dot"

string indicatorName;
string chartLegendLabel;

bool   signals;
bool   signal.sound;
string signal.sound.trendChange_up   = "Signal-Up.wav";
string signal.sound.trendChange_down = "Signal-Down.wav";
bool   signal.mail;
string signal.mail.sender   = "";
string signal.mail.receiver = "";
bool   signal.sms;
string signal.sms.receiver = "";
string signal.info = "";                                 // additional chart legend info


/**
 * Initialization
 *
 * @return int - error status
 */
int onInit() {
   if (ProgramInitReason() == IR_RECOMPILE) {
      if (!RestoreInputParameters()) return(last_error);
   }

   // validate inputs
   // MA.Periods
   if (MA.Periods < 1)  return(catch("onInit(1)  Invalid input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMETER));

   // MA.AppliedPrice
   string sValues[], sValue=StrToLower(MA.AppliedPrice);
   if (Explode(sValue, "*", sValues, 2) > 1) {
      int size = Explode(sValues[0], "|", sValues, NULL);
      sValue = sValues[size-1];
   }
   sValue = StrTrim(sValue);
   if (sValue == "") sValue = "close";                   // default price type
   maAppliedPrice = StrToPriceType(sValue, F_ERR_INVALID_PARAMETER);
   if (maAppliedPrice == -1) {
      if      (StrStartsWith("open",     sValue)) maAppliedPrice = PRICE_OPEN;
      else if (StrStartsWith("high",     sValue)) maAppliedPrice = PRICE_HIGH;
      else if (StrStartsWith("low",      sValue)) maAppliedPrice = PRICE_LOW;
      else if (StrStartsWith("close",    sValue)) maAppliedPrice = PRICE_CLOSE;
      else if (StrStartsWith("median",   sValue)) maAppliedPrice = PRICE_MEDIAN;
      else if (StrStartsWith("typical",  sValue)) maAppliedPrice = PRICE_TYPICAL;
      else if (StrStartsWith("weighted", sValue)) maAppliedPrice = PRICE_WEIGHTED;
      else              return(catch("onInit(2)  Invalid input parameter MA.AppliedPrice = "+ DoubleQuoteStr(MA.AppliedPrice), ERR_INVALID_INPUT_PARAMETER));
   }
   MA.AppliedPrice = PriceTypeDescription(maAppliedPrice);

   // colors: after deserialization the terminal might turn CLR_NONE (0xFFFFFFFF) into Black (0xFF000000)
   if (Color.UpTrend   == 0xFF000000) Color.UpTrend   = CLR_NONE;
   if (Color.DownTrend == 0xFF000000) Color.DownTrend = CLR_NONE;

   // Draw.Type
   sValue = StrToLower(Draw.Type);
   if (Explode(sValue, "*", sValues, 2) > 1) {
      size = Explode(sValues[0], "|", sValues, NULL);
      sValue = sValues[size-1];
   }
   sValue = StrTrim(sValue);
   if      (StrStartsWith("line", sValue)) { drawType = DRAW_LINE;  Draw.Type = "Line"; }
   else if (StrStartsWith("dot",  sValue)) { drawType = DRAW_ARROW; Draw.Type = "Dot";  }
   else                 return(catch("onInit(3)  Invalid input parameter Draw.Type = "+ DoubleQuoteStr(Draw.Type), ERR_INVALID_INPUT_PARAMETER));

   // Draw.Width
   if (Draw.Width < 0)  return(catch("onInit(4)  Invalid input parameter Draw.Width = "+ Draw.Width, ERR_INVALID_INPUT_PARAMETER));
   if (Draw.Width > 5)  return(catch("onInit(5)  Invalid input parameter Draw.Width = "+ Draw.Width, ERR_INVALID_INPUT_PARAMETER));

   // Max.Values
   if (Max.Values < -1) return(catch("onInit(6)  Invalid input parameter Max.Values = "+ Max.Values, ERR_INVALID_INPUT_PARAMETER));
   maxValues = ifInt(Max.Values==-1, INT_MAX, Max.Values);

   // signals
   if (!Configure.Signal(__NAME(), Signal.onTrendChange, signals))                                              return(last_error);
   if (signals) {
      if (!Configure.Signal.Sound(Signal.Sound,         signal.sound                                         )) return(last_error);
      if (!Configure.Signal.Mail (Signal.Mail.Receiver, signal.mail, signal.mail.sender, signal.mail.receiver)) return(last_error);
      if (!Configure.Signal.SMS  (Signal.SMS.Receiver,  signal.sms,                      signal.sms.receiver )) return(last_error);
      if (signal.sound || signal.mail || signal.sms) {
         signal.info = "TrendChange="+ StrLeft(ifString(signal.sound, "Sound,", "") + ifString(signal.mail, "Mail,", "") + ifString(signal.sms, "SMS,", ""), -1);
      }
      else signals = false;
   }

   // buffer management
   SetIndexBuffer(MODE_MA,        main     );            // MA main values:   invisible, displayed in legend and "Data" window
   SetIndexBuffer(MODE_TREND,     trend    );            // trend direction:  invisible, displayed in "Data" window
   SetIndexBuffer(MODE_UPTREND1,  uptrend1 );            // uptrend values:   visible
   SetIndexBuffer(MODE_DOWNTREND, downtrend);            // downtrend values: visible
   SetIndexBuffer(MODE_UPTREND2,  uptrend2 );            // on-bar uptrends:  visible

   // chart legend
   string sAppliedPrice = ifString(maAppliedPrice==PRICE_CLOSE, "", ", "+ PriceTypeDescription(maAppliedPrice));
   indicatorName = __NAME() +"("+ MA.Periods + sAppliedPrice +")";
   if (!IsSuperContext()) {
       chartLegendLabel = CreateLegendLabel(indicatorName);
       ObjectRegister(chartLegendLabel);
   }

   // names, labels, styles and display options
   string shortName = __NAME() +"("+ MA.Periods +")";
   IndicatorShortName(shortName);
   SetIndexLabel(MODE_MA,        shortName);             // chart tooltips and "Data" window
   SetIndexLabel(MODE_TREND,     shortName +" trend");
   SetIndexLabel(MODE_UPTREND1,  NULL);
   SetIndexLabel(MODE_DOWNTREND, NULL);
   SetIndexLabel(MODE_UPTREND2,  NULL);
   IndicatorDigits(Digits);
   SetIndicatorOptions();

   // pre-calculate ALMA bar weights
   @ALMA.CalculateWeights(almaWeights, MA.Periods, Distribution.Offset, Distribution.Sigma);

   return(catch("onInit(7)"));
}


/**
 * Deinitialization
 *
 * @return int - error status
 */
int onDeinit() {
   DeleteRegisteredObjects(NULL);
   RepositionLegend();
   return(catch("onDeinit(1)"));
}


/**
 * Called before recompilation.
 *
 * @return int - error status
 */
int onDeinitRecompile() {
   StoreInputParameters();
   return(catch("onDeinitRecompile(1)"));
}


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   // a not initialized buffer can happen on terminal start under specific circumstances
   if (!ArraySize(main))
      return(log("onTick(1)  size(main) = 0", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // reset all buffers and delete garbage behind Max.Values before doing a full recalculation
   if (!UnchangedBars) {
      ArrayInitialize(main,      EMPTY_VALUE);
      ArrayInitialize(trend,               0);
      ArrayInitialize(uptrend1,  EMPTY_VALUE);
      ArrayInitialize(downtrend, EMPTY_VALUE);
      ArrayInitialize(uptrend2,  EMPTY_VALUE);
      SetIndicatorOptions();
   }

   // synchronize buffers with a shifted offline chart
   if (ShiftedBars > 0) {
      ShiftIndicatorBuffer(main,      Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(trend,     Bars, ShiftedBars,           0);
      ShiftIndicatorBuffer(uptrend1,  Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(downtrend, Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(uptrend2,  Bars, ShiftedBars, EMPTY_VALUE);
   }

   // calculate start bar
   int bars     = Min(ChangedBars, maxValues);
   int startBar = Min(bars-1, Bars-MA.Periods);
   if (startBar < 0) return(catch("onTick(2)", ERR_HISTORY_INSUFFICIENT));

   // recalculate changed bars
   for (int bar=startBar; bar >= 0; bar--) {
      main[bar] = 0;
      for (int i=0; i < MA.Periods; i++) {
         main[bar] += almaWeights[i] * iMA(NULL, NULL, 1, 0, MODE_SMA, maAppliedPrice, bar+i);
      }
      @Trend.UpdateDirection(main, bar, trend, uptrend1, downtrend, uptrend2, drawType, true, true, Digits);
   }

   if (!IsSuperContext()) {
      @Trend.UpdateLegend(chartLegendLabel, indicatorName, signal.info, Color.UpTrend, Color.DownTrend, main[0], Digits, trend[0], Time[0]);

      // detect trend changes
      if (signals) /*&&*/ if (IsBarOpenEvent()) {
         if      (trend[1] ==  1) onTrendChange(MODE_UPTREND);
         else if (trend[1] == -1) onTrendChange(MODE_DOWNTREND);
      }
   }
   return(last_error);

   // Speed benchmark on Toshiba Satellite
   // ------------------------------------
   // H1 ::ALMA(7xD1)::onTick()   weights(  168)=0.000 sec   buffer(2000)=0.110 sec   loops=   336,000
   // M30::ALMA(7xD1)::onTick()   weights(  336)=0.000 sec   buffer(2000)=0.250 sec   loops=   672,000
   // M15::ALMA(7xD1)::onTick()   weights(  672)=0.000 sec   buffer(2000)=0.453 sec   loops= 1,344,000
   // M5 ::ALMA(7xD1)::onTick()   weights( 2016)=0.016 sec   buffer(2000)=1.547 sec   loops= 4,032,000
   // M1 ::ALMA(7xD1)::onTick()   weights(10080)=0.000 sec   buffer(2000)=7.110 sec   loops=20,160,000
   //
   // Speed benchmark on Toshiba Portege
   // ----------------------------------
   // H1 ::ALMA(7xD1)::onTick()                              buffer(2000)=0.078 sec
   // M30::ALMA(7xD1)::onTick()                              buffer(2000)=0.156 sec
   // M15::ALMA(7xD1)::onTick()                              buffer(2000)=0.312 sec
   // M5 ::ALMA(7xD1)::onTick()                              buffer(2000)=0.952 sec
   // M1 ::ALMA(7xD1)::onTick()                              buffer(2000)=4.773 sec
   //
   // Conclusion: weights calculation is ignorable, bottleneck is the nested loop in MA calculation
}


/**
 * Event handler for trend changes.
 *
 * @param  int trend - direction
 *
 * @return bool - success status
 */
bool onTrendChange(int trend) {
   string message="", accountTime="("+ TimeToStr(TimeLocal(), TIME_MINUTES|TIME_SECONDS) +", "+ AccountAlias(ShortAccountCompany(), GetAccountNumber()) +")";
   int error = 0;

   if (trend == MODE_UPTREND) {
      message = indicatorName +" turned up (market: "+ NumberToStr((Bid+Ask)/2, PriceFormat) +")";
      if (__LOG()) log("onTrendChange(1)  "+ message);
      message = Symbol() +","+ PeriodDescription(Period()) +": "+ message;

      if (signal.sound) error |= !PlaySoundEx(signal.sound.trendChange_up);
      if (signal.mail)  error |= !SendEmail(signal.mail.sender, signal.mail.receiver, message, message +NL+ accountTime);
      if (signal.sms)   error |= !SendSMS(signal.sms.receiver, message +NL+ accountTime);
      return(!error);
   }

   if (trend == MODE_DOWNTREND) {
      message = indicatorName +" turned down (market: "+ NumberToStr((Bid+Ask)/2, PriceFormat) +")";
      if (__LOG()) log("onTrendChange(2)  "+ message);
      message = Symbol() +","+ PeriodDescription(Period()) +": "+ message;

      if (signal.sound) error |= !PlaySoundEx(signal.sound.trendChange_down);
      if (signal.mail)  error |= !SendEmail(signal.mail.sender, signal.mail.receiver, message, message +NL+ accountTime);
      if (signal.sms)   error |= !SendSMS(signal.sms.receiver, message +NL+ accountTime);
      return(!error);
   }

   return(!catch("onTrendChange(3)  invalid parameter trend = "+ trend, ERR_INVALID_PARAMETER));
}


/**
 * Workaround for various terminal bugs when setting indicator options. Usually options are set in init(). However after
 * recompilation options must be set in start() to not get ignored.
 */
void SetIndicatorOptions() {
   IndicatorBuffers(indicator_buffers);

   int draw_type  = ifInt(Draw.Width, drawType, DRAW_NONE);
   int draw_width = ifInt(drawType==DRAW_ARROW, drawArrowSize, Draw.Width);

   SetIndexStyle(MODE_MA,        DRAW_NONE, EMPTY, EMPTY,      CLR_NONE       );
   SetIndexStyle(MODE_TREND,     DRAW_NONE, EMPTY, EMPTY,      CLR_NONE       );
   SetIndexStyle(MODE_UPTREND1,  draw_type, EMPTY, draw_width, Color.UpTrend  ); SetIndexArrow(MODE_UPTREND1,  159);
   SetIndexStyle(MODE_DOWNTREND, draw_type, EMPTY, draw_width, Color.DownTrend); SetIndexArrow(MODE_DOWNTREND, 159);
   SetIndexStyle(MODE_UPTREND2,  draw_type, EMPTY, draw_width, Color.UpTrend  ); SetIndexArrow(MODE_UPTREND2,  159);
}


/**
 * Store input parameters in the chart before recompilation.
 *
 * @return bool - success status
 */
bool StoreInputParameters() {
   string name = __NAME();
   Chart.StoreInt   (name +".input.MA.Periods",           MA.Periods           );
   Chart.StoreString(name +".input.MA.AppliedPrice",      MA.AppliedPrice      );
   Chart.StoreDouble(name +".input.Distribution.Offset",  Distribution.Offset  );
   Chart.StoreDouble(name +".input.Distribution.Sigma",   Distribution.Sigma   );
   Chart.StoreColor (name +".input.Color.UpTrend",        Color.UpTrend        );
   Chart.StoreColor (name +".input.Color.DownTrend",      Color.DownTrend      );
   Chart.StoreString(name +".input.Draw.Type",            Draw.Type            );
   Chart.StoreInt   (name +".input.Draw.Width",           Draw.Width           );
   Chart.StoreInt   (name +".input.Max.Values",           Max.Values           );
   Chart.StoreString(name +".input.Signal.onTrendChange", Signal.onTrendChange );
   Chart.StoreString(name +".input.Signal.Sound",         Signal.Sound         );
   Chart.StoreString(name +".input.Signal.Mail.Receiver", Signal.Mail.Receiver );
   Chart.StoreString(name +".input.Signal.SMS.Receiver",  Signal.SMS.Receiver  );
   return(!catch("StoreInputParameters(1)"));
}


/**
 * Restore input parameters found in the chart after recompilation.
 *
 * @return bool - success status
 */
bool RestoreInputParameters() {
   string name = __NAME();
   Chart.RestoreInt   (name +".input.MA.Periods",           MA.Periods           );
   Chart.RestoreString(name +".input.MA.AppliedPrice",      MA.AppliedPrice      );
   Chart.RestoreDouble(name +".input.Distribution.Offset",  Distribution.Offset  );
   Chart.RestoreDouble(name +".input.Distribution.Sigma",   Distribution.Sigma   );
   Chart.RestoreColor (name +".input.Color.UpTrend",        Color.UpTrend        );
   Chart.RestoreColor (name +".input.Color.DownTrend",      Color.DownTrend      );
   Chart.RestoreString(name +".input.Draw.Type",            Draw.Type            );
   Chart.RestoreInt   (name +".input.Draw.Width",           Draw.Width           );
   Chart.RestoreInt   (name +".input.Max.Values",           Max.Values           );
   Chart.RestoreString(name +".input.Signal.onTrendChange", Signal.onTrendChange );
   Chart.RestoreString(name +".input.Signal.Sound",         Signal.Sound         );
   Chart.RestoreString(name +".input.Signal.Mail.Receiver", Signal.Mail.Receiver );
   Chart.RestoreString(name +".input.Signal.SMS.Receiver",  Signal.SMS.Receiver  );
   return(!catch("RestoreInputParameters(1)"));
}


/**
 * Return a string representation of the input parameters (for logging purposes).
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("MA.Periods=",           MA.Periods,                              ";", NL,
                            "MA.AppliedPrice=",      DoubleQuoteStr(MA.AppliedPrice),         ";", NL,
                            "Distribution.Offset=",  NumberToStr(Distribution.Offset, ".1+"), ";", NL,
                            "Distribution.Sigma=",   NumberToStr(Distribution.Sigma, ".1+"),  ";", NL,
                            "Color.UpTrend=",        ColorToStr(Color.UpTrend),               ";", NL,
                            "Color.DownTrend=",      ColorToStr(Color.DownTrend),             ";", NL,
                            "Draw.Type=",            DoubleQuoteStr(Draw.Type),               ";", NL,
                            "Draw.Width=",           Draw.Width,                              ";", NL,
                            "Max.Values=",           Max.Values,                              ";", NL,
                            "Signal.onTrendChange=", DoubleQuoteStr(Signal.onTrendChange),    ";", NL,
                            "Signal.Sound=",         DoubleQuoteStr(Signal.Sound),            ";", NL,
                            "Signal.Mail.Receiver=", DoubleQuoteStr(Signal.Mail.Receiver),    ";", NL,
                            "Signal.SMS.Receiver=",  DoubleQuoteStr(Signal.SMS.Receiver),     ";")
   );
}
