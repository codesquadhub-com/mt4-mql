/**
 * Triple Smoothed Exponential Moving Average Oscillator = 1-day-ROC(TriEMA)
 *
 *
 * The Trix Oscillator displays the rate of change (the momentum) between two consecutive triple smoothed EMA (TriEMA) values.
 * The unit is normalized to "bps" (1 base point = 1/100th of a percent).
 *
 * Indicator buffers to use with iCustom():
 *  � Slope.MODE_MAIN:   Trix main value
 *  � Slope.MODE_TREND:  trend direction and length
 *    - trend direction: positive values denote an uptrend (+1...+n), negative values a downtrend (-1...-n)
 *    - trend length:    the absolute direction value is the length of the trend in bars since the last reversal
 *
 * To detect a crossing of the zero line use MovingAverage.MODE_TREND of the underlying TriEMA.
 *
 *
 * TODO:
 *    - SMA signal line
 */
#include <stddefines.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern int    EMA.Periods           = 38;
extern string EMA.AppliedPrice      = "Open | High | Low | Close* | Median | Typical | Weighted";

extern color  MainLine.Color        = DodgerBlue;           // indicator style management in MQL
extern int    MainLine.Width        = 1;

extern color  Histogram.Color.Upper = LimeGreen;
extern color  Histogram.Color.Lower = Red;
extern int    Histogram.Style.Width = 2;

extern int    Max.Values            = 5000;                 // max. number of values to display: -1 = all

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <stdfunctions.mqh>
#include <rsfLibs.mqh>
#include <functions/@Trend.mqh>

#property indicator_separate_window
#property indicator_buffers   4                             // configurable buffers (input dialog)
int       allocated_buffers = 7;                            // used buffers

#property indicator_width1    1
#property indicator_width2    0
#property indicator_width3    2
#property indicator_width4    2

#property indicator_level1    0

#define MODE_MAIN             Slope.MODE_MAIN               // indicator buffer ids
#define MODE_TREND            Slope.MODE_TREND
#define MODE_UPPER_SECTION    2
#define MODE_LOWER_SECTION    3
#define MODE_EMA_1            4
#define MODE_EMA_2            5
#define MODE_EMA_3            6

double trixMain [];                                         // Trix main line:                 visible, "Data" window
double trixTrend[];                                         // trend direction and length:     invisible
double trixUpper[];                                         // positive histogram values:      visible
double trixLower[];                                         // negative histogram values:      visible
double firstEma [];                                         // first intermediate EMA buffer:  invisible
double secondEma[];                                         // second intermediate EMA buffer: invisible
double thirdEma [];                                         // third intermediate EMA buffer:  invisible

int    ema.appliedPrice;


/**
 * Initialization
 *
 * @return int - error status
 */
int onInit() {
   if (InitReason() == IR_RECOMPILE) {
      if (!RestoreInputParameters()) return(last_error);
   }

   // (1) validate inputs
   // EMA.Periods
   if (EMA.Periods < 1)           return(catch("onInit(1)  Invalid input parameter EMA.Periods = "+ EMA.Periods, ERR_INVALID_INPUT_PARAMETER));

   // EMA.AppliedPrice
   string values[], sValue = StringToLower(EMA.AppliedPrice);
   if (Explode(sValue, "*", values, 2) > 1) {
      int size = Explode(values[0], "|", values, NULL);
      sValue = values[size-1];
   }
   sValue = StringTrim(sValue);
   if (sValue == "") sValue = "close";                                           // default price type
   ema.appliedPrice = StrToPriceType(sValue, F_ERR_INVALID_PARAMETER);
   if (IsEmpty(ema.appliedPrice)) {
      if      (StringStartsWith("open",     sValue)) ema.appliedPrice = PRICE_OPEN;
      else if (StringStartsWith("high",     sValue)) ema.appliedPrice = PRICE_HIGH;
      else if (StringStartsWith("low",      sValue)) ema.appliedPrice = PRICE_LOW;
      else if (StringStartsWith("close",    sValue)) ema.appliedPrice = PRICE_CLOSE;
      else if (StringStartsWith("median",   sValue)) ema.appliedPrice = PRICE_MEDIAN;
      else if (StringStartsWith("typical",  sValue)) ema.appliedPrice = PRICE_TYPICAL;
      else if (StringStartsWith("weighted", sValue)) ema.appliedPrice = PRICE_WEIGHTED;
      else                        return(catch("onInit(2)  Invalid input parameter EMA.AppliedPrice = "+ DoubleQuoteStr(EMA.AppliedPrice), ERR_INVALID_INPUT_PARAMETER));
   }
   EMA.AppliedPrice = PriceTypeDescription(ema.appliedPrice);

   // Colors
   if (MainLine.Color        == 0xFF000000) MainLine.Color        = CLR_NONE;    // after unserialization the terminal might turn CLR_NONE (0xFFFFFFFF)
   if (Histogram.Color.Upper == 0xFF000000) Histogram.Color.Upper = CLR_NONE;    // into Black (0xFF000000)
   if (Histogram.Color.Lower == 0xFF000000) Histogram.Color.Lower = CLR_NONE;

   // Styles
   if (MainLine.Width < 0)        return(catch("onInit(3)  Invalid input parameter MainLine.Width = "+ MainLine.Width, ERR_INVALID_INPUT_PARAMETER));
   if (MainLine.Width > 5)        return(catch("onInit(4)  Invalid input parameter MainLine.Width = "+ MainLine.Width, ERR_INVALID_INPUT_PARAMETER));
   if (Histogram.Style.Width < 0) return(catch("onInit(5)  Invalid input parameter Histogram.Style.Width = "+ Histogram.Style.Width, ERR_INVALID_INPUT_PARAMETER));
   if (Histogram.Style.Width > 5) return(catch("onInit(6)  Invalid input parameter Histogram.Style.Width = "+ Histogram.Style.Width, ERR_INVALID_INPUT_PARAMETER));

   // Max.Values
   if (Max.Values < -1)           return(catch("onInit(7)  Invalid input parameter Max.Values = "+ Max.Values, ERR_INVALID_INPUT_PARAMETER));


   // (2) setup buffer management
   SetIndexBuffer(MODE_EMA_1,         firstEma );
   SetIndexBuffer(MODE_EMA_2,         secondEma);
   SetIndexBuffer(MODE_EMA_3,         thirdEma );
   SetIndexBuffer(MODE_MAIN,          trixMain );
   SetIndexBuffer(MODE_UPPER_SECTION, trixUpper);
   SetIndexBuffer(MODE_LOWER_SECTION, trixLower);
   SetIndexBuffer(MODE_TREND,         trixTrend);


   // (3) data display configuration and names
   string sAppliedPrice = "";
      if (ema.appliedPrice != PRICE_CLOSE) sAppliedPrice = ", "+ PriceTypeDescription(ema.appliedPrice);
   string name = "Trix ("+ EMA.Periods + sAppliedPrice +")  ";
   IndicatorShortName(name);                                // indicator subwindow and context menus

   name = "Trix("+ EMA.Periods +")";                        // "Data" window and tooltips
   SetIndexLabel(MODE_EMA_1,         NULL);
   SetIndexLabel(MODE_EMA_2,         NULL);
   SetIndexLabel(MODE_EMA_3,         NULL);
   SetIndexLabel(MODE_MAIN,          name);
   SetIndexLabel(MODE_UPPER_SECTION, NULL);
   SetIndexLabel(MODE_LOWER_SECTION, NULL);
   SetIndexLabel(MODE_TREND,         NULL);
   IndicatorDigits(3);


   // (4) drawing options and styles
   int startDraw = 0;
   if (Max.Values >= 0) startDraw += Bars - Max.Values;
   if (startDraw  <  0) startDraw  = 0;
   SetIndexDrawBegin(MODE_MAIN,          startDraw);
   SetIndexDrawBegin(MODE_UPPER_SECTION, startDraw);
   SetIndexDrawBegin(MODE_LOWER_SECTION, startDraw);
   SetIndicatorOptions();

   return(catch("onInit(8)"));
}


/**
 * Called before recompilation.
 *
 * @return int - error status
 */
int onDeinitRecompile() {
   StoreInputParameters();
   return(last_error);
}


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   // check for finished buffer initialization (needed on terminal start)
   if (!ArraySize(trixMain))
      return(log("onTick(1)  size(trixMain) = 0", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // reset all buffers and delete garbage behind Max.Values before doing a full recalculation
   if (!ValidBars) {
      ArrayInitialize(firstEma,  EMPTY_VALUE);
      ArrayInitialize(secondEma, EMPTY_VALUE);
      ArrayInitialize(thirdEma,  EMPTY_VALUE);
      ArrayInitialize(trixMain,  EMPTY_VALUE);
      ArrayInitialize(trixUpper, EMPTY_VALUE);
      ArrayInitialize(trixLower, EMPTY_VALUE);
      ArrayInitialize(trixTrend,           0);
      SetIndicatorOptions();
   }

   // synchronize buffers with a shifted offline chart
   if (ShiftedBars > 0) {
      ShiftIndicatorBuffer(firstEma,  Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(secondEma, Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(thirdEma,  Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(trixMain,  Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(trixUpper, Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(trixLower, Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(trixTrend, Bars, ShiftedBars,           0);
   }


   // (1) calculate start bar
   int changedBars = ChangedBars;
   if (Max.Values >= 0) /*&&*/ if (Max.Values < ChangedBars)         // Because EMA(EMA(EMA)) is used in the calculation, TriEMA needs
      changedBars = Max.Values;                                      // 3*<period>-2 samples to start producing values in contrast to
   int bar, startBar = Min(changedBars-1, Bars - (3*EMA.Periods-2)); // <period> samples needed by a regular EMA.
   if (startBar < 0) return(catch("onTick(2)", ERR_HISTORY_INSUFFICIENT));


   // (2) recalculate invalid bars
   double dNull[];
   for (bar=ChangedBars-1; bar >= 0; bar--) firstEma [bar] =        iMA(NULL,      NULL,        EMA.Periods, 0, MODE_EMA, ema.appliedPrice, bar);
   for (bar=ChangedBars-1; bar >= 0; bar--) secondEma[bar] = iMAOnArray(firstEma,  WHOLE_ARRAY, EMA.Periods, 0, MODE_EMA,                   bar);
   for (bar=ChangedBars-1; bar >= 0; bar--) thirdEma [bar] = iMAOnArray(secondEma, WHOLE_ARRAY, EMA.Periods, 0, MODE_EMA,                   bar);

   for (bar=startBar; bar >= 0; bar--) {
      if (!thirdEma[bar+1]) {
         debug("onTick(0."+ Tick +")  thirdEma["+ (bar+1) +"]=NULL  ShiftedBars="+ ShiftedBars +"  ChangedBars="+ ChangedBars +"  startBar="+ startBar);
         continue;
      }
      // Trix main value
      trixMain[bar] = (thirdEma[bar] - thirdEma[bar+1]) / thirdEma[bar+1] * 10000;              // convert to bps

      // histogram sections
      if (trixMain[bar] > 0) { trixUpper[bar] = trixMain[bar]; trixLower[bar] = EMPTY_VALUE;   }
      else                   { trixUpper[bar] = EMPTY_VALUE;   trixLower[bar] = trixMain[bar]; }

      // trend direction and length
      @Trend.UpdateDirection(trixMain, bar, trixTrend, dNull, dNull, dNull, DRAW_NONE);
   }
   return(last_error);
}


/**
 * Workaround for various terminal bugs when setting indicator options. Usually options are set in init(). However after
 * recompilation options must be set in start() to not get ignored.
 */
void SetIndicatorOptions() {
   IndicatorBuffers(allocated_buffers);

   int mainType    = ifInt(MainLine.Width,        DRAW_LINE,      DRAW_NONE);
   int sectionType = ifInt(Histogram.Style.Width, DRAW_HISTOGRAM, DRAW_NONE);

   SetIndexStyle(MODE_MAIN,          mainType,    EMPTY, MainLine.Width,        MainLine.Color       );
   SetIndexStyle(MODE_UPPER_SECTION, sectionType, EMPTY, Histogram.Style.Width, Histogram.Color.Upper);
   SetIndexStyle(MODE_LOWER_SECTION, sectionType, EMPTY, Histogram.Style.Width, Histogram.Color.Lower);
   SetIndexStyle(MODE_TREND,         DRAW_NONE,   EMPTY, EMPTY);
}


/**
 * Store input parameters in the chart before recompilation.
 *
 * @return bool - success status
 */
bool StoreInputParameters() {
   Chart.StoreInt   (__NAME__ +".input.EMA.Periods",           EMA.Periods          );
   Chart.StoreString(__NAME__ +".input.EMA.AppliedPrice",      EMA.AppliedPrice     );
   Chart.StoreColor (__NAME__ +".input.MainLine.Color",        MainLine.Color       );
   Chart.StoreInt   (__NAME__ +".input.MainLine.Width",        MainLine.Width       );
   Chart.StoreColor (__NAME__ +".input.Histogram.Color.Upper", Histogram.Color.Upper);
   Chart.StoreColor (__NAME__ +".input.Histogram.Color.Lower", Histogram.Color.Lower);
   Chart.StoreInt   (__NAME__ +".input.Histogram.Style.Width", Histogram.Style.Width);
   Chart.StoreInt   (__NAME__ +".input.Max.Values",            Max.Values           );
   return(!catch("StoreInputParameters(1)"));
}


/**
 * Restore input parameters found in the chart after recompilation.
 *
 * @return bool - success status
 */
bool RestoreInputParameters() {
   Chart.RestoreInt   ("EMA.Periods",           EMA.Periods          );
   Chart.RestoreString("EMA.AppliedPrice",      EMA.AppliedPrice     );
   Chart.RestoreColor ("MainLine.Color",        MainLine.Color       );
   Chart.RestoreInt   ("MainLine.Width",        MainLine.Width       );
   Chart.RestoreColor ("Histogram.Color.Upper", Histogram.Color.Upper);
   Chart.RestoreColor ("Histogram.Color.Lower", Histogram.Color.Lower);
   Chart.RestoreInt   ("Histogram.Style.Width", Histogram.Style.Width);
   Chart.RestoreInt   ("Max.Values",            Max.Values           );
   return(!catch("RestoreInputParameters(1)"));
}


/**
 * Return a string representation of the input parameters (for logging purposes).
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("EMA.Periods=",           EMA.Periods,                       ";", NL,
                            "EMA.AppliedPrice=",      DoubleQuoteStr(EMA.AppliedPrice),  ";", NL,

                            "MainLine.Color=",        ColorToStr(MainLine.Color),        ";", NL,
                            "MainLine.Width=",        MainLine.Width,                    ";", NL,

                            "Histogram.Color.Upper=", ColorToStr(Histogram.Color.Upper), ";", NL,
                            "Histogram.Color.Lower=", ColorToStr(Histogram.Color.Lower), ";", NL,
                            "Histogram.Style.Width=", Histogram.Style.Width,             ";", NL,

                            "Max.Values=",            Max.Values,                        ";")
   );
}
