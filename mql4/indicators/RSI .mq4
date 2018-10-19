/**
 * RSI (Relative Strength Index)
 *
 * An RSI implementation supporting the display as histogram.
 *
 *
 * Indicator buffers to use with iCustom():
 *  � RSI.MODE_MAIN:    RSI main values
 *  � RSI.MODE_SECTION: RSI section and section length since last crossing of level 50
 *    - section: positive values denote a RSI above 50 (+1...+n), negative values a RSI below 50 (-1...-n)
 *    - length:  the absolute value is the histogram section length (bars since the last crossing of level 50)
 *
 *
 * Note: The file is intentionally named "RSI .mql" as a file "RSI.mql" would be overwritten by newer terminal versions.
 */
#include <stddefines.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern int    RSI.Periods           = 14;
extern string RSI.AppliedPrice      = "Open | High | Low | Close* | Median | Typical | Weighted";

extern color  MainLine.Color        = DodgerBlue;           // indicator style management in MQL
extern int    MainLine.Width        = 1;

extern color  Histogram.Color.Upper = Blue;
extern color  Histogram.Color.Lower = Red;
extern int    Histogram.Style.Width = 2;

extern int    Max.Values            = 5000;                 // max. number of values to display: -1 = all

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <stdfunctions.mqh>
#include <rsfLibs.mqh>

#define MODE_MAIN             MACD.MODE_MAIN                // indicator buffer ids
#define MODE_SECTION          MACD.MODE_SECTION
#define MODE_UPPER_SECTION    2
#define MODE_LOWER_SECTION    3

#property indicator_separate_window
#property indicator_buffers   4                             // configurable buffers (input dialog)
int       allocated_buffers = 4;                            // used buffers
#property indicator_level1    0

double bufferRSI    [];                                     // RSI main value:            visible, displayed in "Data" window
double bufferSection[];                                     // RSI section and length:    invisible
double bufferUpper  [];                                     // positive histogram values: visible
double bufferLower  [];                                     // negative histogram values: visible

int    rsi.periods;
int    rsi.appliedPrice;

string ind.shortName;                                       // "Data" window and indicator subwindow


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
   // RSI.Periods
   if (RSI.Periods < 2)           return(catch("onInit(1)  Invalid input parameter RSI.Periods: "+ RSI.Periods, ERR_INVALID_INPUT_PARAMETER));
   rsi.periods = RSI.Periods;

   // RSI.AppliedPrice
   string values[], sValue=StringToLower(RSI.AppliedPrice);
   if (Explode(sValue, "*", values, 2) > 1) {
      int size = Explode(values[0], "|", values, NULL);
      sValue = values[size-1];
   }
   sValue = StringTrim(sValue);
   if (sValue == "") sValue = "close";                               // default price type
   rsi.appliedPrice = StrToPriceType(sValue, F_ERR_INVALID_PARAMETER);
   if (IsEmpty(rsi.appliedPrice)) {
      if      (StrStartsWith("open",     sValue)) rsi.appliedPrice = PRICE_OPEN;
      else if (StrStartsWith("high",     sValue)) rsi.appliedPrice = PRICE_HIGH;
      else if (StrStartsWith("low",      sValue)) rsi.appliedPrice = PRICE_LOW;
      else if (StrStartsWith("close",    sValue)) rsi.appliedPrice = PRICE_CLOSE;
      else if (StrStartsWith("median",   sValue)) rsi.appliedPrice = PRICE_MEDIAN;
      else if (StrStartsWith("typical",  sValue)) rsi.appliedPrice = PRICE_TYPICAL;
      else if (StrStartsWith("weighted", sValue)) rsi.appliedPrice = PRICE_WEIGHTED;
      else                        return(catch("onInit(2)  Invalid input parameter RSI.AppliedPrice: "+ DoubleQuoteStr(RSI.AppliedPrice), ERR_INVALID_INPUT_PARAMETER));
   }
   RSI.AppliedPrice = PriceTypeDescription(rsi.appliedPrice);

   // Colors: after unserialization the terminal might turn CLR_NONE (0xFFFFFFFF) into Black (0xFF000000)
   if (MainLine.Color        == 0xFF000000) MainLine.Color        = CLR_NONE;
   if (Histogram.Color.Upper == 0xFF000000) Histogram.Color.Upper = CLR_NONE;
   if (Histogram.Color.Lower == 0xFF000000) Histogram.Color.Lower = CLR_NONE;

   // Styles
   if (MainLine.Width < 0)        return(catch("onInit(3)  Invalid input parameter MainLine.Width: "+ MainLine.Width, ERR_INVALID_INPUT_PARAMETER));
   if (MainLine.Width > 5)        return(catch("onInit(4)  Invalid input parameter MainLine.Width: "+ MainLine.Width, ERR_INVALID_INPUT_PARAMETER));
   if (Histogram.Style.Width < 0) return(catch("onInit(5)  Invalid input parameter Histogram.Style.Width: "+ Histogram.Style.Width, ERR_INVALID_INPUT_PARAMETER));
   if (Histogram.Style.Width > 5) return(catch("onInit(6)  Invalid input parameter Histogram.Style.Width: "+ Histogram.Style.Width, ERR_INVALID_INPUT_PARAMETER));

   // Max.Values
   if (Max.Values < -1)           return(catch("onInit(7)  Invalid input parameter Max.Values: "+ Max.Values, ERR_INVALID_INPUT_PARAMETER));


   // (2) setup buffer management
   SetIndexBuffer(MODE_MAIN,          bufferRSI    );                // RSI main value:         visible, displayed in "Data" window
   SetIndexBuffer(MODE_SECTION,       bufferSection);                // RSI section and length: invisible
   SetIndexBuffer(MODE_UPPER_SECTION, bufferUpper  );                // positive values:        visible
   SetIndexBuffer(MODE_LOWER_SECTION, bufferLower  );                // negative values:        visible


   // (3) data display configuration and names
   string strAppliedPrice = ifString(rsi.appliedPrice==PRICE_CLOSE, "", ","+ PriceTypeDescription(rsi.appliedPrice));
   ind.shortName = "RSI("+ rsi.periods + strAppliedPrice +")";

   // names and labels
   IndicatorShortName(ind.shortName +"  ");                          // indicator subwindow and context menu
   SetIndexLabel(MODE_MAIN,          ind.shortName);                 // "Data" window and tooltips
   SetIndexLabel(MODE_SECTION,       NULL);
   SetIndexLabel(MODE_UPPER_SECTION, NULL);
   SetIndexLabel(MODE_LOWER_SECTION, NULL);
   IndicatorDigits(2);


   // (4) drawing options and styles
   int startDraw = 0;
   if (Max.Values >= 0) startDraw += Bars - Max.Values;
   if (startDraw  <  0) startDraw  = 0;
   SetIndexDrawBegin(MODE_MAIN,          startDraw);
   SetIndexDrawBegin(MODE_SECTION,       INT_MAX  );                 // work around scaling bug in terminals <=509
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
   return(NO_ERROR);
}


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   // check for finished buffer initialization (needed on terminal start)
   if (!ArraySize(bufferRSI))
      return(log("onTick(1)  size(bufferRSI) = 0", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // reset all buffers and delete garbage behind Max.Values before doing a full recalculation
   if (!ValidBars) {
      ArrayInitialize(bufferRSI,     EMPTY_VALUE);
      ArrayInitialize(bufferSection,           0);
      ArrayInitialize(bufferUpper,   EMPTY_VALUE);
      ArrayInitialize(bufferLower,   EMPTY_VALUE);
      SetIndicatorOptions();
   }

   // synchronize buffers with a shifted offline chart
   if (ShiftedBars > 0) {
      ShiftIndicatorBuffer(bufferRSI,     Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferSection, Bars, ShiftedBars,           0);
      ShiftIndicatorBuffer(bufferUpper,   Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferLower,   Bars, ShiftedBars, EMPTY_VALUE);
   }


   // (1) calculate start bar
   int changedBars = ChangedBars;
   if (Max.Values >= 0) /*&&*/ if (ChangedBars > Max.Values)
      changedBars = Max.Values;
   int startBar = Min(changedBars-1, Bars-rsi.periods);
   if (startBar < 0) return(catch("onTick(2)", ERR_HISTORY_INSUFFICIENT));


   double fast.ma, slow.ma;


   // (2) recalculate invalid bars
   for (int bar=startBar; bar >= 0; bar--) {
      // actual RSI
      bufferRSI[bar] = iRSI(NULL, NULL, rsi.periods, rsi.appliedPrice, bar);

      if (bufferRSI[bar] > 50) {
         bufferUpper[bar] = bufferRSI[bar];
         bufferLower[bar] = EMPTY_VALUE;
      }
      else {
         bufferUpper[bar] = EMPTY_VALUE;
         bufferLower[bar] = bufferRSI[bar];
      }

      // update section length (duration)
      if      (bufferSection[bar+1] > 0 && bufferRSI[bar] >= 50) bufferSection[bar] = bufferSection[bar+1] + 1;
      else if (bufferSection[bar+1] < 0 && bufferRSI[bar] <= 50) bufferSection[bar] = bufferSection[bar+1] - 1;
      else                                                       bufferSection[bar] = ifInt(bufferRSI[bar]>=50, +1, -1);
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
   SetIndexStyle(MODE_SECTION,       DRAW_NONE,   EMPTY, EMPTY                                       );
   SetIndexStyle(MODE_UPPER_SECTION, sectionType, EMPTY, Histogram.Style.Width, Histogram.Color.Upper);
   SetIndexStyle(MODE_LOWER_SECTION, sectionType, EMPTY, Histogram.Style.Width, Histogram.Color.Lower);
}


/**
 * Store input parameters in the chart before recompilation.
 *
 * @return bool - success status
 */
bool StoreInputParameters() {
   Chart.StoreInt   (__NAME__ +".input.RSI.Periods",           RSI.Periods          );
   Chart.StoreString(__NAME__ +".input.RSI.AppliedPrice",      RSI.AppliedPrice     );
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
   Chart.RestoreInt   ("RSI.Periods",           RSI.Periods          );
   Chart.RestoreString("RSI.AppliedPrice",      RSI.AppliedPrice     );
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
   return(StringConcatenate("RSI.Periods=",           RSI.Periods,                       ";"+ NL,
                            "RSI.AppliedPrice=",      DoubleQuoteStr(RSI.AppliedPrice),  ";"+ NL,

                            "MainLine.Color=",        ColorToStr(MainLine.Color),        ";"+ NL,
                            "MainLine.Width=",        MainLine.Width,                    ";"+ NL,

                            "Histogram.Color.Upper=", ColorToStr(Histogram.Color.Upper), ";"+ NL,
                            "Histogram.Color.Lower=", ColorToStr(Histogram.Color.Lower), ";"+ NL,
                            "Histogram.Style.Width=", Histogram.Style.Width,             ";"+ NL,

                            "Max.Values=",            Max.Values,                        ";"+ NL)
   );
}
