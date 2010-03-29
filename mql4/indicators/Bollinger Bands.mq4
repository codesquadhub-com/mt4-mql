/**
 * Bollinger-Bands-Indikator
 */

#include <stdlib.mqh>


#property indicator_chart_window

#property indicator_buffers 3

#property indicator_color1 C'102,135,232'
#property indicator_color2 LightBlue
#property indicator_color3 C'102,135,232'

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_SOLID


////////////////////////////////////////////////////////////////// User Variablen ////////////////////////////////////////////////////////////////

extern string Timeframe      = "H1";         // zu verwendender Zeitrahmen (M1, M5, M15, M30 etc.)
extern int    Periods        = 75;           // Anzahl der zu verwendenden Perioden
extern double Deviation      = 1.4;          // Standardabweichung
extern int    MA.Method      = 2;            // MA-Methode, siehe MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
extern string MA.Method.Help = "1: Simple, 2: Exponential, 3: Smoothed, 4: Linear Weighted";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


double UpperBand[], MovingAvg[], LowerBand[];      // Indikatorpuffer
int    period;                                     // Period-Code zum angegebenen Timeframe

int error = ERR_NO_ERROR;


/**
 *
 */
int init() {
   // Puffer zuordnen
   SetIndexBuffer(0, UpperBand);
   SetIndexBuffer(1, MovingAvg);
   SetIndexBuffer(2, LowerBand);
   IndicatorDigits(Digits);


   // w�hrend der Entwicklung Puffer jedesmal zur�cksetzen
   if (UninitializeReason() == REASON_RECOMPILE) {
      ArrayInitialize(UpperBand, EMPTY_VALUE);
      ArrayInitialize(MovingAvg, EMPTY_VALUE);
      ArrayInitialize(LowerBand, EMPTY_VALUE);
   }


   // Parameter �berpr�fen
   period = GetPeriod(Timeframe);
   if (period == 0) {
      error = catch("init()  Invalid input parameter Timeframe: \'"+ Timeframe +"\'", ERR_INVALID_INPUT_PARAMVALUE);
      return(error);
   }
   if (Periods < 2) {
      error = catch("init()  Invalid input parameter Periods: "+ Periods, ERR_INVALID_INPUT_PARAMVALUE);
      return(error);
   }
   if (Deviation < 0 || CompareDoubles(Deviation, 0)) {
      error = catch("init()  Invalid input parameter Deviation: "+ Deviation, ERR_INVALID_INPUT_PARAMVALUE);
      return(error);
   }
   switch (MA.Method) {
      case 1: MA.Method = MODE_SMA ; break;
      case 2: MA.Method = MODE_EMA ; break;
      case 3: MA.Method = MODE_SMMA; break;
      case 4: MA.Method = MODE_LWMA; break;
      default: 
         error = catch("init()  Invalid input parameter MA.Method: "+ MA.Method, ERR_INVALID_INPUT_PARAMVALUE);
         return(error);
   }


   // Indikatorlabel setzen
   SetIndexLabel (0, StringConcatenate("UpperBand(", Periods, "x", Timeframe, ")"));
   SetIndexLabel (1, NULL);
   SetIndexLabel (2, StringConcatenate("LowerBand(", Periods, "x", Timeframe, ")"));


   // nach Setzen der Label Parameter auf aktuellen Zeitrahmen umrechnen
   if (Period() != period) {
      double minutes = period * Periods;           // Timeframe * Anzahl Bars = Range in Minuten
      Periods = MathRound(minutes/Period());
   }


   // nach Parameter�nderung sofort start() aufrufen und nicht auf den n�chsten Tick warten
   if (UninitializeReason() == REASON_PARAMETERS) {
      start();
      WindowRedraw();
   }
   return(catch("init()"));
}


/**
 *
 */
int start() {
   if (error != ERR_NO_ERROR) return(error);    // Abbruch bei Parameterfehlern ...
   if (Periods < 2)           return(0);        // und bei Periods < 2 (m�glich bei Umschalten auf gr��eren Timeframe)
     

   int processedBars = IndicatorCounted(),
       iLastIndBar   = Bars - Periods,          // Index der letzten Indikator-Bar
       bars,                                    // Anzahl der zu berechnenden Bars
       i, k;

   if (iLastIndBar < 0)                         // im Falle Bars < Periods
      iLastIndBar = -1;

   if (iLastIndBar == -1)                        
      return(catch("start(1)"));


   // Anzahl der zu berechnenden Bars bestimmen
   if (processedBars == 0) {
      bars = iLastIndBar + 1;                   // alle
   }
   else {                                       // nur die fehlenden Bars
      bars = Bars - processedBars;
      if (bars > iLastIndBar + 1)
         bars = iLastIndBar + 1;
      // TODO: Eventhandler integrieren: Update nur bei onNewHigh|onNewLow
   }


   //int tick = GetTickCount();

   double ma, diffH, diffL, sum, deviation;


   // MovingAverage und B�nder berechnen
   for (i=bars-1; i >= 0; i--) {
      ma  = iMA(NULL, 0, Periods, 0, MA.Method, PRICE_MEDIAN, i);
      sum = 0;

      for (k=i+Periods-1; k >= i; k--) {
         //diffH = Close[k] - ma;            // Verwendung von Close
         //sum += diffH * diffH;

         diffH = High[k] - ma;               // Verwendung von High oder Low (der am weitesten vom MA entfernte Wert)
         diffL = Low [k] - ma;               
         diffH *= diffH;
         diffL *= diffL;                     // Quad(a) + Quad(b) ist schneller als MathAbs(a) + MathAbs(b) + Quad(a|b)
         if (diffH > diffL) sum += diffH;    // (a > b) ist wesentlich schneller als MathMax(a, b)
         else               sum += diffL;
      }

      deviation    = Deviation * MathSqrt(sum/Periods);
      UpperBand[i] = ma + deviation;
      MovingAvg[i] = ma;
      LowerBand[i] = ma - deviation;
   }
   

   //if (bars > 1) Print("start()   zu berechnende Bars: "+ bars +"    Zeit: "+ (GetTickCount()-tick) +" ms");

   return(catch("start(2)"));
}

