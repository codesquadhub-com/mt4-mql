/**
 * Multi-Color/Timeframe Moving Averages
 */
#include <stddefine.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];
#include <stdlib.mqh>

//////////////////////////////////////////////////////////////////////////////// Konfiguration ////////////////////////////////////////////////////////////////////////////////

extern string MA.Periods            = "200";                         // f�r einige Timeframes sind gebrochene Werte zul�ssig (z.B. 1.5 x D1)
extern string MA.Timeframe          = "current";                     // Timeframe: [M1|M5|M15|...], "" = aktueller Timeframe
extern string MA.Method             = "SMA* | EMA | SMMA | LWMA | TMA | ALMA";
extern string MA.AppliedPrice       = "Open | High | Low | Close* | Median | Typical | Weighted";

extern color  Color.UpTrend         = DodgerBlue;                    // Farbverwaltung hier, damit Code Zugriff hat
extern color  Color.DownTrend       = Orange;

extern int    Max.Values            = 2000;                          // H�chstanzahl darzustellender Werte: -1 = keine Begrenzung
extern int    Shift.Horizontal.Bars = 0;                             // horizontale Shift in Bars
extern int    Shift.Vertical.Pips   = 0;                             // vertikale Shift in Pips

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <indicators/iMA.mqh>
#include <indicators/iALMA.mqh>

#define MovingAverage.MODE_MA          0        // Buffer-Identifier
#define MovingAverage.MODE_TREND       1
#define MovingAverage.MODE_UPTREND     2        // Bei Unterbrechung eines Down-Trends um nur eine Bar wird dieser Up-Trend durch den sich fortsetzenden Down-Trend
#define MovingAverage.MODE_DOWNTREND   3        // verdeckt. Um solche kurzfristigen Trendwechsel sichtbar zu machen, werden sie im Buffer MODE_UPTREND2 gespeichert, der
#define MovingAverage.MODE_UPTREND2    4        // MODE_DOWNTREND �berlagert.
#define MovingAverage.MODE_TMASMA      5

#property indicator_chart_window

#property indicator_buffers 5

#property indicator_width1  0
#property indicator_width2  0
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2

double bufferMA       [];                       // vollst. Indikator: unsichtbar (Anzeige im "Data Window")
double bufferTrend    [];                       // Trend: +/-         unsichtbar
double bufferUpTrend  [];                       // UpTrend-Linie 1:   sichtbar
double bufferDownTrend[];                       // DownTrend-Linie:   sichtbar (�berlagert UpTrend-Linie 1)
double bufferUpTrend2 [];                       // UpTrend-Linie 2:   sichtbar (�berlagert DownTrend-Linie)
double bufferTmaSma   [];                       // TMA-Hilfsbuffer

int    ma.periods;
int    ma.method;
int    ma.appliedPrice;

int    tma.sma1.periods;                        // Periode des ersten SMA eines TMA
int    tma.sma2.periods;                        // Periode des zweiten SMA eines TMA

double alma.weights[];                          // Gewichtungen der einzelnen Bars eines ALMA

double shift.vertical;
string legendLabel, legendName;


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int onInit() {
   // (1) Validierung
   // (1.1) MA.Timeframe zuerst, da G�ltigkeit von MA.Periods davon abh�ngt
   MA.Timeframe = StringToUpper(StringTrim(MA.Timeframe));
   if (MA.Timeframe == "CURRENT")     MA.Timeframe = "";
   if (MA.Timeframe == ""       ) int ma.timeframe = Period();
   else                               ma.timeframe = StrToPeriod(MA.Timeframe);
   if (ma.timeframe == -1)           return(catch("onInit(1)   Invalid input parameter MA.Timeframe = \""+ MA.Timeframe +"\"", ERR_INVALID_INPUT_PARAMVALUE));

   // (1.2) MA.Periods
   string strValue = StringTrim(MA.Periods);
   if (!StringIsNumeric(strValue))   return(catch("onInit(2)   Invalid input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMVALUE));
   double dValue = StrToDouble(strValue);
   if (dValue <= 0)                  return(catch("onInit(3)   Invalid input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMVALUE));
   if (MathModFix(dValue, 0.5) != 0) return(catch("onInit(4)   Invalid input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMVALUE));
   strValue = NumberToStr(dValue, ".+");
   if (StringEndsWith(strValue, ".5")) {                                // gebrochene Perioden in ganze Bars umrechnen
      switch (ma.timeframe) {
         case PERIOD_M30: dValue *=  2; ma.timeframe = PERIOD_M15; break;
         case PERIOD_H1 : dValue *=  2; ma.timeframe = PERIOD_M30; break;
         case PERIOD_H4 : dValue *=  4; ma.timeframe = PERIOD_H1;  break;
         case PERIOD_D1 : dValue *=  6; ma.timeframe = PERIOD_H4;  break;
         case PERIOD_W1 : dValue *= 30; ma.timeframe = PERIOD_H4;  break;
         default:                    return(catch("onInit(5)   Illegal input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMVALUE));
      }
   }
   switch (ma.timeframe) {                                              // Timeframes > H1 auf H1 umrechnen
      case PERIOD_H4: dValue *=   4; ma.timeframe = PERIOD_H1; break;
      case PERIOD_D1: dValue *=  24; ma.timeframe = PERIOD_H1; break;
      case PERIOD_W1: dValue *= 120; ma.timeframe = PERIOD_H1; break;
   }
   ma.periods = MathRound(dValue);
   if (ma.periods < 2)               return(catch("onInit(6)   Invalid input parameter MA.Periods = "+ MA.Periods, ERR_INVALID_INPUT_PARAMVALUE));
   if (ma.timeframe != Period()) {                                      // angegebenen auf aktuellen Timeframe umrechnen
      double minutes = ma.timeframe * ma.periods;                       // Timeframe * Anzahl_Bars = Range_in_Minuten
      ma.periods = MathRound(minutes/Period());
   }
   MA.Periods = strValue;

   // (1.3) MA.Method
   string elems[];
   if (Explode(MA.Method, "*", elems, 2) > 1) {
      int size = Explode(elems[0], "|", elems, NULL);
      strValue = elems[size-1];
   }
   else strValue = MA.Method;
   ma.method = StrToMovAvgMethod(strValue);
   if (ma.method == -1)              return(catch("onInit(7)   Invalid input parameter MA.Method = \""+ MA.Method +"\"", ERR_INVALID_INPUT_PARAMVALUE));
   MA.Method = MovAvgMethodDescription(ma.method);

   // (1.4) MA.AppliedPrice
   if (Explode(MA.AppliedPrice, "*", elems, 2) > 1) {
      size     = Explode(elems[0], "|", elems, NULL);
      strValue = elems[size-1];
   }
   else strValue = MA.AppliedPrice;
   ma.appliedPrice = StrToPriceType(strValue);
   if (ma.appliedPrice==-1 || ma.appliedPrice > PRICE_WEIGHTED)
                                     return(catch("onInit(8)   Invalid input parameter MA.AppliedPrice = \""+ MA.AppliedPrice +"\"", ERR_INVALID_INPUT_PARAMVALUE));
   MA.AppliedPrice = PriceTypeDescription(ma.appliedPrice);

   // (1.5) Max.Values
   if (Max.Values < -1)              return(catch("onInit(9)   Invalid input parameter Max.Values = "+ Max.Values, ERR_INVALID_INPUT_PARAMVALUE));

   // (1.6) Colors
   if (Color.UpTrend   == 0xFF000000) Color.UpTrend   = CLR_NONE;       // k�nnen vom Terminal falsch gesetzt worden sein
   if (Color.DownTrend == 0xFF000000) Color.DownTrend = CLR_NONE;


   // (2) Chart-Legende erzeugen
   string strTimeframe="", strAppliedPrice="";
   if (MA.Timeframe != "")             strTimeframe    = "x"+ MA.Timeframe;
   if (ma.appliedPrice != PRICE_CLOSE) strAppliedPrice = ", "+ PriceTypeDescription(ma.appliedPrice);
   legendName  = MA.Method +"("+ MA.Periods + strTimeframe + strAppliedPrice +")";
   legendLabel = CreateLegendLabel(legendName);
   ObjectRegister(legendLabel);


   // (3) ggf. TMA-Subperioden berechnen
   if (ma.method==MODE_TMA) {
      tma.sma1.periods = ma.periods/2;                                  // (int)
      tma.sma2.periods = ma.periods - tma.sma1.periods;
   }


   // (4) ggf. ALMA-Gewichtungen berechnen
   if (ma.method==MODE_ALMA) /*&&*/ if (ma.periods > 1)                 // ma.periods < 2 ist m�glich bei Umschalten auf zu gro�en Timeframe
      iALMA.CalculateWeights(alma.weights, ma.periods);


   // (5.1) Bufferverwaltung
   IndicatorBuffers(6);
   SetIndexBuffer(MovingAverage.MODE_MA,        bufferMA       );       // vollst. Indikator: unsichtbar (Anzeige im "Data Window"
   SetIndexBuffer(MovingAverage.MODE_TREND,     bufferTrend    );       // Trend: +/-         unsichtbar
   SetIndexBuffer(MovingAverage.MODE_UPTREND,   bufferUpTrend  );       // UpTrend-Linie 1:   sichtbar
   SetIndexBuffer(MovingAverage.MODE_DOWNTREND, bufferDownTrend);       // DownTrend-Linie:   sichtbar
   SetIndexBuffer(MovingAverage.MODE_UPTREND2,  bufferUpTrend2 );       // UpTrend-Linie 2:   sichtbar
   SetIndexBuffer(MovingAverage.MODE_TMASMA,    bufferTmaSma   );       // TMA-Hilfsbuffer

   // (5.2) Anzeigeoptionen
   IndicatorShortName(legendName);                                      // Context Menu
   string dataName = MA.Method +"("+ MA.Periods + strTimeframe +")";
   SetIndexLabel(MovingAverage.MODE_MA,        dataName);               // Tooltip und "Data Window"
   SetIndexLabel(MovingAverage.MODE_TREND,     NULL);
   SetIndexLabel(MovingAverage.MODE_UPTREND,   NULL);
   SetIndexLabel(MovingAverage.MODE_DOWNTREND, NULL);
   SetIndexLabel(MovingAverage.MODE_UPTREND2,  NULL);
   IndicatorDigits(SubPipDigits);

   // (5.3) Zeichenoptionen
   int startDraw = Max(ma.periods-1, Bars-ifInt(Max.Values < 0, Bars, Max.Values)) + Shift.Horizontal.Bars;
   SetIndexDrawBegin(MovingAverage.MODE_MA,        0        ); SetIndexShift(MovingAverage.MODE_MA,        Shift.Horizontal.Bars);
   SetIndexDrawBegin(MovingAverage.MODE_TREND,     0        ); SetIndexShift(MovingAverage.MODE_TREND,     Shift.Horizontal.Bars);
   SetIndexDrawBegin(MovingAverage.MODE_UPTREND,   startDraw); SetIndexShift(MovingAverage.MODE_UPTREND,   Shift.Horizontal.Bars);
   SetIndexDrawBegin(MovingAverage.MODE_DOWNTREND, startDraw); SetIndexShift(MovingAverage.MODE_DOWNTREND, Shift.Horizontal.Bars);
   SetIndexDrawBegin(MovingAverage.MODE_UPTREND2,  startDraw); SetIndexShift(MovingAverage.MODE_UPTREND2,  Shift.Horizontal.Bars);

   shift.vertical = Shift.Vertical.Pips * Pip;                          // TODO: Digits/Point-Fehler abfangen

   // (5.4) Styles
   SetIndicatorStyles();                                                // Workaround um diverse Terminalbugs (siehe dort)

   return(catch("onInit(10)"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int onDeinit() {
   DeleteRegisteredObjects(NULL);
   RepositionLegend();
   return(catch("onDeinit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onTick() {
   // Abschlu� der Buffer-Initialisierung �berpr�fen
   if (ArraySize(bufferMA) == 0)                                        // kann bei Terminal-Start auftreten
      return(SetLastError(ERS_TERMINAL_NOT_YET_READY));

   // vor kompletter Neuberechnung Buffer zur�cksetzen
   if (!ValidBars) {
      ArrayInitialize(bufferMA,        EMPTY_VALUE);
      ArrayInitialize(bufferTrend,               0);
      ArrayInitialize(bufferUpTrend,   EMPTY_VALUE);
      ArrayInitialize(bufferDownTrend, EMPTY_VALUE);
      ArrayInitialize(bufferUpTrend2,  EMPTY_VALUE);
      ArrayInitialize(bufferTmaSma,              0);
      SetIndicatorStyles();                                             // Workaround um diverse Terminalbugs (siehe dort)
   }

   if (ma.periods < 2)                                                  // Abbruch bei ma.periods < 2 (m�glich bei Umschalten auf zu gro�en Timeframe)
      return(NO_ERROR);


   // (1) Startbar der Berechnung ermitteln
   int ma.ChangedBars = ChangedBars;
   if (ma.ChangedBars > Max.Values) /*&&*/ if (Max.Values >= 0)
      ma.ChangedBars = Max.Values;
   int ma.startBar = Min(ma.ChangedBars-1, Bars-ma.periods);
   if (ma.startBar < 0) {
      if (IsSuperContext())
         return(catch("onTick()", ERR_HISTORY_INSUFFICIENT));
      SetLastError(ERR_HISTORY_INSUFFICIENT);                           // Signalisieren, falls Bars f�r Berechnung nicht ausreichen (keine R�ckkehr)
   }


   // (2) ung�ltige Bars neuberechnen
   if (ma.method == MODE_TMA) {
      // TMA: erster SMA
      int sma.ChangedBars = ChangedBars;
      if (sma.ChangedBars > Max.Values+tma.sma1.periods) /*&&*/ if (Max.Values >= 0)
         sma.ChangedBars = Max.Values+tma.sma1.periods;
      int sma.startBar = Min(sma.ChangedBars-1, Bars-tma.sma1.periods);

      for (int bar=sma.startBar; bar >= 0; bar--) {                     // eigene Schleife (darf nicht innerhalb der 2. Schleife erfolgen)
         bufferTmaSma[bar] = iMA(NULL, NULL, tma.sma1.periods, 0, MODE_SMA, ma.appliedPrice, bar);
      }
   }
   for (bar=ma.startBar; bar >= 0; bar--) {
      // der eigentliche Moving Average
      if (ma.method == MODE_ALMA) {                                     // ALMA
         bufferMA[bar] = 0;
         for (int i=0; i < ma.periods; i++) {
            bufferMA[bar] += alma.weights[i] * iMA(NULL, NULL, 1, 0, MODE_SMA, ma.appliedPrice, bar+i);
         }
      }
      else if (ma.method == MODE_TMA) {                                 // TMA
         bufferMA[bar] = iMAOnArray(bufferTmaSma, WHOLE_ARRAY, tma.sma2.periods, 0, MODE_SMA, bar);
      }
      else {                                                            // alle �brigen MA's
         bufferMA[bar] = iMA(NULL, NULL, ma.periods, 0, ma.method, ma.appliedPrice, bar);
      }
      bufferMA[bar] += shift.vertical;

      // Trend aktualisieren
      iMA.UpdateTrend(bufferMA, bufferTrend, bufferUpTrend, bufferDownTrend, bufferUpTrend2, bar);
   }


   // (3) Legende aktualisieren
   iMA.UpdateLegend(legendLabel, legendName, Color.UpTrend, Color.DownTrend, bufferMA[0], bufferTrend[0], Time[0]);
   return(last_error);
}


/**
 * Indikator-Styles setzen. Workaround um diverse Terminalbugs (Farb-/Style�nderungen nach Recompile), die erfordern, da� die Styles
 * normalerweise in init(), nach Recompile jedoch in start() gesetzt werden m�ssen, um korrekt angezeigt zu werden.
 */
void SetIndicatorStyles() {
   SetIndexStyle(MovingAverage.MODE_MA,        DRAW_NONE, EMPTY, EMPTY, CLR_NONE       );
   SetIndexStyle(MovingAverage.MODE_TREND,     DRAW_NONE, EMPTY, EMPTY, CLR_NONE       );
   SetIndexStyle(MovingAverage.MODE_UPTREND,   DRAW_LINE, EMPTY, EMPTY, Color.UpTrend  );
   SetIndexStyle(MovingAverage.MODE_DOWNTREND, DRAW_LINE, EMPTY, EMPTY, Color.DownTrend);
   SetIndexStyle(MovingAverage.MODE_UPTREND2,  DRAW_LINE, EMPTY, EMPTY, Color.UpTrend  );
}


/**
 * String-Repr�sentation der Input-Parameter f�rs Logging bei Aufruf durch iCustom().
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("init()   inputs: ",

                            "MA.Periods=\"",          MA.Periods                 , "\"; ",
                            "MA.Timeframe=\"",        MA.Timeframe               , "\"; ",
                            "MA.Method=\"",           MA.Method                  , "\"; ",
                            "MA.AppliedPrice=\"",     MA.AppliedPrice            , "\"; ",

                            "Color.UpTrend=",         ColorToStr(Color.UpTrend)  , "; ",
                            "Color.DownTrend=",       ColorToStr(Color.DownTrend), "; ",

                            "Max.Values=",            Max.Values                 , "; ",
                            "Shift.Horizontal.Bars=", Shift.Horizontal.Bars      , "; ",
                            "Shift.Vertical.Pips=",   Shift.Vertical.Pips        , "; ")
   );
}
