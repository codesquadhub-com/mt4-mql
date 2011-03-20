/**
 * Bollinger-Bands-Indikator
 */
#include <stdlib.mqh>


#property indicator_chart_window

#property indicator_buffers 3

#property indicator_color1 C'102,135,232'
#property indicator_color2 C'163,183,241'
#property indicator_color3 C'102,135,232'

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_SOLID


//////////////////////////////////////////////////////////////// Externe Parameter ////////////////////////////////////////////////////////////////

extern int    Periods        = 75;           // Anzahl der zu verwendenden Perioden
extern string Timeframe      = "H1";         // zu verwendender Zeitrahmen (M1, M5, M15, M30 etc.)
extern double Deviation      = 1.65;         // Standardabweichung
extern string MA.Method      = "SMA";        // MA-Methode
extern string MA.Method.Help = "SMA | EMA | SMMA | LWMA";
extern int    Max.Values     = -1;           // Anzahl der maximal anzuzeigenden Werte: -1 = all

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


double UpperBand[], MovingAvg[], LowerBand[];      // Indikatorpuffer
int    maTimeframe, maMethod;


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   init = true; init_error = NO_ERROR; __SCRIPT__ = WindowExpertName();
   stdlib_init(__SCRIPT__);

   // Konfiguration auswerten
   if (Periods < 2)
      return(catch("init(1)  Invalid input parameter Periods: "+ Periods, ERR_INVALID_INPUT_PARAMVALUE));

   maTimeframe = GetPeriod(Timeframe);
   if (maTimeframe == 0)
      return(catch("init(2)  Invalid input parameter Timeframe: \'"+ Timeframe +"\'", ERR_INVALID_INPUT_PARAMVALUE));

   string method = StringToUpper(MA.Method);
   if      (method == "SMA" ) maMethod = MODE_SMA;
   else if (method == "EMA" ) maMethod = MODE_EMA;
   else if (method == "SMMA") maMethod = MODE_SMMA;
   else if (method == "LWMA") maMethod = MODE_LWMA;
   else {
      return(catch("init(3)  Invalid input parameter MA.Method: \""+ MA.Method +"\"", ERR_INVALID_INPUT_PARAMVALUE));
   }

   if (Deviation <= 0)
      return(catch("init(4)  Invalid input parameter Deviation: "+ Deviation, ERR_INVALID_INPUT_PARAMVALUE));

   if (Max.Values < 0)
      Max.Values = Bars;

   // Puffer zuweisen
   SetIndexBuffer(0, UpperBand);
   SetIndexBuffer(1, MovingAvg);
   SetIndexBuffer(2, LowerBand);
   IndicatorDigits(Digits);

   // Anzeigeoptionen
   SetIndexLabel(0, StringConcatenate("UpperBand(", Periods, "x", Timeframe, ")"));
   SetIndexLabel(1, StringConcatenate("MovingAvg(", Periods, "x", Timeframe, ")"));
   SetIndexLabel(2, StringConcatenate("LowerBand(", Periods, "x", Timeframe, ")"));

   // MA-Parameter nach Setzen der Label auf aktuellen Zeitrahmen umrechnen
   if (Period() != maTimeframe) {
      double minutes = maTimeframe * Periods;        // Timeframe * Anzahl Bars = Range in Minuten
      Periods = MathRound(minutes / Period());
   }

   // nach Parameter�nderung nicht auf den n�chsten Tick warten (nur im "Indicators List" window notwendig)
   if (UninitializeReason() == REASON_PARAMETERS)
      SendTick(false);

   return(catch("init(6)"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int deinit() {
   return(catch("deinit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int start() {
   Tick++;
   if      (init_error != NO_ERROR)                   ValidBars = 0;
   else if (last_error == ERR_TERMINAL_NOT_YET_READY) ValidBars = 0;
   else                                               ValidBars = IndicatorCounted();
   ChangedBars = Bars - ValidBars;
   stdlib_onTick(ValidBars);

   // init() nach ERR_TERMINAL_NOT_YET_READY nochmal aufrufen oder abbrechen
   if (init_error == ERR_TERMINAL_NOT_YET_READY) /*&&*/ if (!init)
      init();
   init = false;
   if (init_error != NO_ERROR)
      return(init_error);

   // nach Terminal-Start Abschlu� der Initialisierung �berpr�fen
   if (Bars == 0 || ArraySize(UpperBand) == 0) {
      last_error = ERR_TERMINAL_NOT_YET_READY;
      return(last_error);
   }
   last_error = 0;
   // -----------------------------------------------------------------------------


   // vor Neuberechnung alle Indikatorwerte zur�cksetzen
   if (ValidBars == 0) {
      ArrayInitialize(UpperBand, EMPTY_VALUE);
      ArrayInitialize(MovingAvg, EMPTY_VALUE);
      ArrayInitialize(LowerBand, EMPTY_VALUE);
   }

   if (Periods < 2)                             // Abbruch bei Periods < 2 (m�glich bei Umschalten auf zu gro�en Timeframe)
      return(0);

   int iLastIndBar = Bars - Periods,            // Index der letzten Indikator-Bar
       bars,                                    // Anzahl der zu berechnenden Bars
       i, k;

   if (iLastIndBar < 0)
      return(0);                                // Abbruch im Falle Bars < Periods


   // Anzahl der zu berechnenden Bars bestimmen
   if (ValidBars == 0) {
      bars = iLastIndBar + 1;                   // alle
   }
   else {                                       // nur die fehlenden Bars
      bars = ChangedBars;
      if (bars > iLastIndBar + 1)
         bars = iLastIndBar + 1;
      // TODO: Eventhandler integrieren: Update nur bei onNewHigh|onNewLow
   }

   // zu berechnende Bars auf Max.Values begrenzen
   if (bars > Max.Values)
      bars = Max.Values;


   /**
    * MovingAverage und B�nder berechnen
    *
    * Folgende Beobachtungen und Schlu�folgerungen wurden f�r die verschiedenen MA-Methoden gemacht:
    * ----------------------------------------------------------------------------------------------
    * 1) Die Ergebnisse von stdDev(appliedPrice=Close) und stdDev(appliedPrice=Median) stimmen nahezu zu 100% �berein.
    *
    * 2) Die Ergebnisse von stdDev(appliedPrice=Median) und stdDev(appliedPrice=High|Low) lassen sich durch Anpassung des Faktors Deviation zu 90-95%
    *    in �bereinstimmung bringen.  Der Wert von stdDev(appliedPrice=Close)*1.65 entspricht nahezu dem Wert von stdDev(appliedPrice=High|Low)*1.4.
    *
    * 3) Die Verwendung von appliedPrice=High|Low ist sehr langsam, die von appliedPrice=Close am schnellsten.
    *
    * 4) Zur Performancesteigerung wird appliedPrice=Median verwendet, auch wenn appliedPrice=High|Low geringf�gig exakter scheint.  Denn was ist
    *    im Sinne dieses Indikators "exakt"?  Die einzelnen berechneten Werte haben keine tats�chliche Aussagekraft.  Aus diesem Grunde wird ein
    *    weiteres Bollinger-Band auf SMA-Basis verwendet (dessen einzelne Werte ebenfalls keine tats�chliche Aussagekraft haben).  Beide Indikatoren
    *    zusammen dienen zur Orientierung, "exakt messen" k�nnen beide nichts.
    */
   double ma, dev;

   for (i=bars-1; i >= 0; i--) {
      ma  = iMA    (NULL, 0, Periods, 0, maMethod, PRICE_MEDIAN, i);
      dev = iStdDev(NULL, 0, Periods, 0, maMethod, PRICE_MEDIAN, i) * Deviation;
      UpperBand[i] = ma + dev;
      MovingAvg[i] = ma;
      LowerBand[i] = ma - dev;
   }

   return(catch("start()"));
}
