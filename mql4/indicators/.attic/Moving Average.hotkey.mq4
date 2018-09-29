/**
 * Multi-Color Moving Average mit Hotkey-Steuerung
 *
 *
 * Unterst�tzte MA-Typen:
 *  � SMA  - Simple Moving Average:          Gewichtung aller Bars gleich
 *  � LWMA - Linear Weighted Moving Average: Gewichtung der Bars nach linearer Funktion
 *  � EMA  - Exponential Moving Average:     Gewichtung der Bars nach Exponentialfunktion
 *  � ALMA - Arnaud Legoux Moving Average:   Gewichtung der Bars nach Gau�scher Funktion
 *
 * Nicht unterst�tzte MA-Typen:
 *  � SMMA - Smoothed Moving Average:   EMA anderer Periode, das sich teilweise schneller berechnen l��t
 *  � TMA  - Triangular Moving Average: doppelter MA = SMA(SMA(n)), also glatter, jedoch verdoppelte Response-Zeit (Lag)
 *
 * Sind im aktuellen Chart f�r mehr als einen Indikator Hotkeys zur schnellen �nderung der Indikatorperiode aktiviert,
 * empf�ngt nur der erste f�r Hotkeys konfigurierte Indikator die entsprechenden Commands (in der Reihenfolge der Indikatoren
 * im "Indicators List" Window).
 *
 * Der Buffer MovingAverage.MODE_MA enth�lt die Werte, der Buffer MovingAverage.MODE_TREND Richtung und L�nge des Trends der
 * einzelnen Bars:
 *  � Trendrichtung: positive Werte f�r Aufw�rtstrends (+1...+n), negative Werte f�r Abw�rtstrends (-1...-n)
 *  � Trendl�nge:    der Absolutwert des Trends einer Bar minu 1 (Distanz dieser Bar vom letzten davor aufgetretenen Reversal)
 */
#include <stddefines.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern int    MA.Periods                 = 200;
extern string MA.Method                  = "SMA* | LWMA | EMA | ALMA";
extern string MA.AppliedPrice            = "Open | High | Low | Close* | Median | Typical | Weighted";
extern bool   MA.Periods.Hotkeys.Enabled = false;                    // ob Hotkeys zur �nderung der Periode aktiviert sind

extern color  Color.UpTrend              = DodgerBlue;               // Farbverwaltung hier, damit Code Zugriff hat
extern color  Color.DownTrend            = Orange;

extern int    Max.Values                 = 5000;                     // max. number of values to display: -1 = all

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <stdfunctions.mqh>
#include <rsfLibs.mqh>
#include <functions/@ALMA.mqh>
#include <functions/@Trend.mqh>

#define MODE_MA               MovingAverage.MODE_MA                  // Buffer-ID's
#define MODE_TREND            MovingAverage.MODE_TREND               //
#define MODE_UPTREND1         2                                      // Bei Unterbrechung eines Down-Trends um nur eine Bar wird dieser Up-Trend durch den sich fortsetzenden
#define MODE_DOWNTREND        3                                      // Down-Trend optisch verdeckt. Um auch solche kurzen Trendwechsel sichtbar zu machen, werden sie zus�tzlich
#define MODE_UPTREND2         4                                      // im Buffer MODE_UPTREND2 gespeichert, der im Chart den Buffer MODE_DOWNTREND optisch �berlagert.

#define MA_PERIODS_UP         1                                      // Hotkey-Command-IDs
#define MA_PERIODS_DOWN      -1

#property indicator_chart_window

#property indicator_buffers   5                                      // configurable buffers (input dialog)
int       allocated_buffers = 5;                                     // used buffers

#property indicator_width1    0
#property indicator_width2    0
#property indicator_width3    2
#property indicator_width4    2
#property indicator_width5    2
int       indicator_drawingType = DRAW_LINE;

double bufferMA       [];                                            // vollst. Indikator (unsichtbar, Anzeige im Data window)
double bufferTrend    [];                                            // Trend: +/-        (unsichtbar)
double bufferUpTrend1 [];                                            // UpTrend-Linie 1   (sichtbar)
double bufferDownTrend[];                                            // DownTrend-Linie   (sichtbar, �berlagert UpTrend-Linie 1)
double bufferUpTrend2 [];                                            // UpTrend-Linie 2   (sichtbar, �berlagert DownTrend-Linie)

int    ma.periods;
int    ma.method;
int    ma.appliedPrice;

double alma.weights[];                                               // ALMA: Gewichtungen der einzelnen Bars

string legendLabel, legendName;


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int onInit() {
   // (1) Validierung
   // MA.Periods
   if (MA.Periods < 1)                                          return(catch("onInit(1)  Invalid input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMETER));
   ma.periods = MA.Periods;

   // MA.Method
   string sValue, values[];
   if (Explode(MA.Method, "*", values, 2) > 1) {
      int size = Explode(values[0], "|", values, NULL);
      sValue   = values[size-1];
   }
   else sValue = MA.Method;
   ma.method = StrToMaMethod(sValue, F_ERR_INVALID_PARAMETER);
   if (ma.method == -1)                                         return(catch("onInit(2)  Invalid input parameter MA.Method = "+ DoubleQuoteStr(MA.Method), ERR_INVALID_INPUT_PARAMETER));
   MA.Method = MaMethodDescription(ma.method);

   // MA.AppliedPrice
   sValue = StringToLower(MA.AppliedPrice);
   if (Explode(sValue, "*", values, 2) > 1) {
      size = Explode(values[0], "|", values, NULL);
      sValue = values[size-1];
   }
   sValue = StringTrim(sValue);
   if (sValue == "") sValue = "close";                               // default price type
   if      (StringStartsWith("open",     sValue)) ma.appliedPrice = PRICE_OPEN;
   else if (StringStartsWith("high",     sValue)) ma.appliedPrice = PRICE_HIGH;
   else if (StringStartsWith("low",      sValue)) ma.appliedPrice = PRICE_LOW;
   else if (StringStartsWith("close",    sValue)) ma.appliedPrice = PRICE_CLOSE;
   else if (StringStartsWith("median",   sValue)) ma.appliedPrice = PRICE_MEDIAN;
   else if (StringStartsWith("typical",  sValue)) ma.appliedPrice = PRICE_TYPICAL;
   else if (StringStartsWith("weighted", sValue)) ma.appliedPrice = PRICE_WEIGHTED;
   else                                                         return(catch("onInit(3)  Invalid input parameter MA.AppliedPrice = "+ DoubleQuoteStr(MA.AppliedPrice), ERR_INVALID_INPUT_PARAMETER));
   MA.AppliedPrice = PriceTypeDescription(ma.appliedPrice);

   // Max.Values
   if (Max.Values < -1)                                         return(catch("onInit(4)  Invalid input parameter Max.Values = "+ Max.Values, ERR_INVALID_INPUT_PARAMETER));

   // Colors
   if (Color.UpTrend   == 0xFF000000) Color.UpTrend   = CLR_NONE;    // aus CLR_NONE = 0xFFFFFFFF macht das Terminal nach Recompilation oder Deserialisierung
   if (Color.DownTrend == 0xFF000000) Color.DownTrend = CLR_NONE;    // u.U. 0xFF000000 (entspricht Schwarz)


   // (2) Chart-Legende erzeugen
   string sAppliedPrice = "";
   if (ma.appliedPrice != PRICE_CLOSE) sAppliedPrice = ", "+ PriceTypeDescription(ma.appliedPrice);
   legendName = MA.Method +"("+ MA.Periods + sAppliedPrice +")";
   if (!IsSuperContext()) {
       legendLabel = CreateLegendLabel(legendName);
       ObjectRegister(legendLabel);
   }


   // (3) ggf. ALMA-Gewichtungen berechnen
   if (ma.method==MODE_ALMA) /*&&*/ if (ma.periods > 1)              // ma.periods < 2 ist m�glich bei Umschalten auf zu gro�en Timeframe
      @ALMA.CalculateWeights(alma.weights, ma.periods);


   // (4.1) Bufferverwaltung
   SetIndexBuffer(MODE_MA,        bufferMA       );                  // vollst. Indikator: unsichtbar (Anzeige im Data window)
   SetIndexBuffer(MODE_TREND,     bufferTrend    );                  // Trend: +/-         unsichtbar
   SetIndexBuffer(MODE_UPTREND1,  bufferUpTrend1 );                  // UpTrend-Linie 1:   sichtbar
   SetIndexBuffer(MODE_DOWNTREND, bufferDownTrend);                  // DownTrend-Linie:   sichtbar
   SetIndexBuffer(MODE_UPTREND2,  bufferUpTrend2 );                  // UpTrend-Linie 2:   sichtbar

   // (4.2) Anzeigeoptionen
   IndicatorShortName(legendName);                                   // f�r Context Menu
   string dataName = MA.Method +"("+ MA.Periods +")";
   SetIndexLabel(MODE_MA,        dataName);                          // f�r Tooltip und Data window
   SetIndexLabel(MODE_TREND,     NULL    );
   SetIndexLabel(MODE_UPTREND1,  NULL    );
   SetIndexLabel(MODE_DOWNTREND, NULL    );
   SetIndexLabel(MODE_UPTREND2,  NULL    );
   IndicatorDigits(SubPipDigits);

   // (4.3) Zeichenoptionen
   int startDraw = 0;
   if (Max.Values >= 0) startDraw = Bars - Max.Values;
   if (startDraw  <  0) startDraw = 0;
   SetIndexDrawBegin(MODE_UPTREND1,  startDraw);
   SetIndexDrawBegin(MODE_DOWNTREND, startDraw);
   SetIndexDrawBegin(MODE_UPTREND2,  startDraw);
   SetIndicatorOptions();

   return(catch("onInit(15)"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int onDeinit() {
   DeleteRegisteredObjects(NULL);
   RepositionLegend();
   return(catch("onDeinit(1)"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 *
 * @throws ERS_TERMINAL_NOT_YET_READY
 */
int onTick() {
   // Abschlu� der Buffer-Initialisierung �berpr�fen
   if (!ArraySize(bufferMA))                                            // kann bei Terminal-Start auftreten
      return(log("onTick(1)  size(bufferMA) = 0", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // reset all buffers and delete garbage behind Max.Values before doing a full recalculation
   if (!ValidBars) {
      ArrayInitialize(bufferMA,        EMPTY_VALUE);
      ArrayInitialize(bufferTrend,               0);
      ArrayInitialize(bufferUpTrend1,  EMPTY_VALUE);
      ArrayInitialize(bufferDownTrend, EMPTY_VALUE);
      ArrayInitialize(bufferUpTrend2,  EMPTY_VALUE);
      SetIndicatorOptions();
   }


   // (1) synchronize buffers with a shifted offline chart
   if (ShiftedBars > 0) {
      ShiftIndicatorBuffer(bufferMA,        Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferTrend,     Bars, ShiftedBars,           0);
      ShiftIndicatorBuffer(bufferUpTrend1,  Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferDownTrend, Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferUpTrend2,  Bars, ShiftedBars, EMPTY_VALUE);
   }


   // (2) �nderungen der MA-Periode zur Laufzeit (per Hotkey) erkennen und �bernehmen
   if (MA.Periods.Hotkeys.Enabled)
      HandleEvent(EVENT_CHART_CMD);                                     // ChartCommands verarbeiten

   if (ma.periods < 2)                                                  // Abbruch bei ma.periods < 2 (m�glich bei Umschalten auf zu gro�en Timeframe)
      return(NO_ERROR);


   // (3) Startbar der Berechnung ermitteln
   int ma.ChangedBars = ChangedBars;
   if (ma.ChangedBars > Max.Values) /*&&*/ if (Max.Values >= 0)
      ma.ChangedBars = Max.Values;
   int ma.startBar = Min(ma.ChangedBars-1, Bars-ma.periods);
   if (ma.startBar < 0) {
      if (IsSuperContext()) return(catch("onTick(2)", ERR_HISTORY_INSUFFICIENT));
      SetLastError(ERR_HISTORY_INSUFFICIENT);                           // Signalisieren, falls Bars f�r Berechnung nicht ausreichen (keine R�ckkehr)
   }


   // (4) ung�ltige Bars neuberechnen
   for (int bar=ma.startBar; bar >= 0; bar--) {
      // der eigentliche Moving Average
      if (ma.method == MODE_ALMA) {                                     // ALMA
         bufferMA[bar] = 0;
         for (int i=0; i < ma.periods; i++) {
            bufferMA[bar] += alma.weights[i] * iMA(NULL, NULL, 1, 0, MODE_SMA, ma.appliedPrice, bar+i);
         }
      }
      else {                                                            // alle �brigen MA's
         bufferMA[bar] = iMA(NULL, NULL, ma.periods, 0, ma.method, ma.appliedPrice, bar);
      }

      // Trend aktualisieren
      @Trend.UpdateDirection(bufferMA, bar, bufferTrend, bufferUpTrend1, bufferDownTrend, bufferUpTrend2, indicator_drawingType, true, true, SubPipDigits);
   }


   if (!IsSuperContext()) {
       // (5) Legende aktualisieren
       @Trend.UpdateLegend(legendLabel, legendName, "", Color.UpTrend, Color.DownTrend, bufferMA[0], bufferTrend[0], Time[0]);
   }
   return(last_error);
}


/**
 * Handler f�r ChartCommands.
 *
 * @param  string commands[] - die eingetroffenen Commands
 *
 * @return bool - Erfolgsstatus
 */
bool onChartCommand(string commands[]) {
   int size = ArraySize(commands);
   if (!size) return(!warn("onChartCommand(1)  empty parameter commands = {}"));

   for (int i=0; i < size; i++) {
      if      (commands[i] == "Periods=Up"  ) { if (!ModifyMaPeriods(MA_PERIODS_UP  )) return(false); }
      else if (commands[i] == "Periods=Down") { if (!ModifyMaPeriods(MA_PERIODS_DOWN)) return(false); }
      else
         warn("onChartCommand(2)  unknown chart command \""+ commands[i] +"\"");
   }
   return(!catch("onChartCommand(3)"));
}


/**
 * Erh�ht oder verringert den Parameter MA.Periods des Indikators.
 *
 * @param  int direction - Richtungs-ID:  MA_PERIODS_UP|MA_PERIODS_DOWN
 *
 * @return bool - Erfolgsstatus
 */
bool ModifyMaPeriods(int direction) {
   if (direction == MA_PERIODS_DOWN) {
   }
   else if (direction == MA_PERIODS_UP) {
   }
   else warn("ModifyMaPeriods(1)  unknown parameter direction = "+ direction);

   return(true);
}


/**
 * Workaround for various terminal bugs when setting indicator options. Usually options are set in init(). However after
 * recompilation options must be set in start() to not get ignored.
 */
void SetIndicatorOptions() {
   SetIndexStyle(MODE_MA,        DRAW_NONE,             EMPTY, EMPTY);
   SetIndexStyle(MODE_TREND,     DRAW_NONE,             EMPTY, EMPTY);
   SetIndexStyle(MODE_UPTREND1,  indicator_drawingType, EMPTY, EMPTY, Color.UpTrend  );
   SetIndexStyle(MODE_DOWNTREND, indicator_drawingType, EMPTY, EMPTY, Color.DownTrend);
   SetIndexStyle(MODE_UPTREND2,  indicator_drawingType, EMPTY, EMPTY, Color.UpTrend  );
}


/**
 * Return a string representation of the input parameters. Used to log iCustom() calls.
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("input: ",

                            "MA.Periods=",                 DoubleQuoteStr(MA.Periods),            "; ",
                            "MA.Periods.Hotkeys.Enabled=", BoolToStr(MA.Periods.Hotkeys.Enabled), "; ",
                            "MA.Method=",                  DoubleQuoteStr(MA.Method),             "; ",
                            "MA.AppliedPrice=",            DoubleQuoteStr(MA.AppliedPrice),       "; ",

                            "Color.UpTrend=",              ColorToStr(Color.UpTrend),             "; ",
                            "Color.DownTrend=",            ColorToStr(Color.DownTrend),           "; ",

                            "Max.Values=",                 Max.Values,                            "; ")
   );
}
