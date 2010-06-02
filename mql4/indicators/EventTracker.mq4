/**
 * EventTracker
 *
 * �berwacht ein Instrument auf verschiedene, konfigurierbare Signale und benachrichtigt dar�ber optisch, akustisch und/oder per SMS.
 */

#include <stdlib.mqh>


#property indicator_chart_window


//////////////////////////////////////////////////////////////// Default-Konfiguration ////////////////////////////////////////////////////////////

bool   Sound.Alerts                 = true;
string Sound.File.Up                = "alert3.wav";
string Sound.File.Down              = "alert4.wav";
string Sound.File.PositionOpen      = "OrderFilled.wav";
string Sound.File.PositionClose     = "PositionClosed.wav";

bool   SMS.Alerts                   = true;
string SMS.Receiver                 = "";

bool   Track.Positions              = false;

bool   Track.QuoteChanges           = false;
int    QuoteChanges.Gridsize        = 25;

bool   Track.BollingerBands         = false;
int    BollingerBands.MA.Timeframe  = 0;
int    BollingerBands.MA.Periods    = 0;
int    BollingerBands.MA.Method     = MODE_SMA;
double BollingerBands.Deviation     = 2;

bool   Track.PivotLevels            = false;
bool   PivotLevels.PreviousDayRange = false;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// sonstige Variablen
string Instrument.Name, Instrument.ShortName;

double quoteLimits[2];                       // {lowerLimit, upperLimit}
double bandLimits [3];                       // {MODE_BASE, MODE_UPPER, MODE_LOWER}



/**
 *
 */
int init() {
   // DataBox-Anzeige ausschalten
   SetIndexLabel(0, NULL);


   // nach Recompilation statische Arrays zur�cksetzen
   if (UninitializeReason() == REASON_RECOMPILE) {
      ArrayInitialize(quoteLimits, 0);
      ArrayInitialize(bandLimits , 0);
   }


   // Konfiguration auswerten
   string symbols = GetConfigString("EventTracker", "Track.Symbols", "");

   // Soll das aktuelle Instrument �berwacht werden?
   if (StringContains(","+symbols+",", ","+Symbol()+",")) {
      Instrument.Name      = GetConfigString("Instrument.Names"     , Symbol() , Symbol());
      Instrument.ShortName = GetConfigString("Instrument.ShortNames", Instrument.Name, Instrument.Name);

      // Sound- und SMS-Einstellungen
      Sound.Alerts = GetConfigBool("EventTracker", "Sound.Alerts", Sound.Alerts);
      SMS.Alerts   = GetConfigBool("EventTracker", "SMS.Alerts"  , SMS.Alerts);
      if (SMS.Alerts) {
         SMS.Receiver = GetConfigString("SMS", "Receiver", SMS.Receiver);
         if (!StringIsDigit(SMS.Receiver)) {
            catch("init(1)  invalid phone number SMS.Receiver: "+ SMS.Receiver, ERR_INVALID_INPUT_PARAMVALUE);
            SMS.Alerts = false;
         }
      }

      // offene Positionen
      string accounts = GetConfigString("EventTracker", "Track.Accounts", "");
      if (StringContains(","+accounts+",", ","+GetAccountNumber()+","))
         Track.Positions = true;

      string section = "EventTracker."+ Symbol();

      // Kurs�nderungen
      Track.QuoteChanges = GetConfigBool(section, "QuoteChanges"  , Track.QuoteChanges);
      if (Track.QuoteChanges) {
         QuoteChanges.Gridsize = GetConfigInt(section, "QuoteChanges.Gridsize", QuoteChanges.Gridsize);
         if (QuoteChanges.Gridsize < 1) {
            catch("init(2)  invalid value QuoteChanges.Gridsize: "+ GetConfigString(section, "QuoteChanges.Gridsize", ""), ERR_INVALID_INPUT_PARAMVALUE);
            Track.QuoteChanges = false;
         }
      }

      // Bollinger-B�nder
      Track.BollingerBands = GetConfigBool(section, "BollingerBands", Track.BollingerBands);
      if (Track.BollingerBands) {
         string value = GetConfigString(section, "BollingerBands.MA.Timeframe", BollingerBands.MA.Timeframe);
         BollingerBands.MA.Timeframe = GetPeriod(value);
         if (BollingerBands.MA.Timeframe == 0) {
            catch("init(3)  invalid value BollingerBands.MA.Timeframe: "+ value, ERR_INVALID_INPUT_PARAMVALUE);
            Track.BollingerBands = false;
         }
      }
      if (Track.BollingerBands) {
         BollingerBands.MA.Periods = GetConfigInt(section, "BollingerBands.MA.Periods", BollingerBands.MA.Periods);
         if (BollingerBands.MA.Periods < 2) {
            catch("init(4)  invalid value BollingerBands.MA.Periods: "+ GetConfigString(section, "BollingerBands.MA.Periods", ""), ERR_INVALID_INPUT_PARAMVALUE);
            Track.BollingerBands = false;
         }
      }
      if (Track.BollingerBands) {
         value = GetConfigString(section, "BollingerBands.MA.Method", BollingerBands.MA.Method);
         BollingerBands.MA.Method = GetMovingAverageMethod(value);
         if (BollingerBands.MA.Method < 0) {
            catch("init(5)  invalid value BollingerBands.MA.Method: "+ value, ERR_INVALID_INPUT_PARAMVALUE);
            Track.BollingerBands = false;
         }
      }
      if (Track.BollingerBands) {
         BollingerBands.Deviation = GetConfigDouble(section, "BollingerBands.Deviation", BollingerBands.Deviation);
         if (BollingerBands.Deviation < 0 || CompareDoubles(BollingerBands.Deviation, 0)) {
            catch("init(6)  invalid value BollingerBands.Deviation: "+ GetConfigString(section, "BollingerBands.Deviation", ""), ERR_INVALID_INPUT_PARAMVALUE);
            Track.BollingerBands = false;
         }
      }

      // Pivot-Level
      Track.PivotLevels = GetConfigBool(section, "PivotLevels", Track.PivotLevels);
      if (Track.PivotLevels)
         PivotLevels.PreviousDayRange = GetConfigBool(section, "PivotLevels.PreviousDayRange", PivotLevels.PreviousDayRange);
   }


   // nach Parameter�nderung sofort start() aufrufen und nicht auf den n�chsten Tick warten
   if (UninitializeReason() == REASON_PARAMETERS) {
      start();
      WindowRedraw();
   }

   //Print("init()   Sound.Alerts="+ Sound.Alerts +"   SMS.Alerts="+ SMS.Alerts +"   Track.Positions: "+ Track.Positions +"   Track.QuoteChanges="+ Track.QuoteChanges +"   Track.BollingerBands="+ Track.BollingerBands +"   Track.PivotLevels="+ Track.PivotLevels);
   return(catch("init(7)"));
}


/**
 *
 */
int start() {
   //Print("start()   IsConnected="+ IsConnected() +"   Bars: "+ Bars +"   processedBars: "+ IndicatorCounted());

   // TODO: nach Config-�nderung Limite zur�cksetzen

   if (IsConnected()) {                                           // nur bei Verbindung zum Quoteserver
      int processedBars = IndicatorCounted();

      if (processedBars == 0) {                                   // Chart�nderung => alle Limite zur�cksetzen
         ArrayInitialize(quoteLimits, 0);

         ArrayInitialize(bandLimits, 0);
         EventTracker.SetBandLimits(bandLimits);
      }

      // Limite �berpr�fen
      if (Track.Positions)
         HandleEvents(EVENT_POSITION_OPEN | EVENT_POSITION_CLOSE);

      if (Track.QuoteChanges)
         if (CheckQuoteChanges() == ERR_HISTORY_WILL_UPDATED)
            return(ERR_HISTORY_WILL_UPDATED);

      if (Track.BollingerBands) {
         HandleEvent(EVENT_BAR_OPEN, PERIODFLAG_M1);              // Limite jede Minute aktualisieren
         if (CheckBollingerBands() == ERR_HISTORY_WILL_UPDATED)
            return(ERR_HISTORY_WILL_UPDATED);
      }

      if (Track.PivotLevels)
         if (CheckPivotLevels() == ERR_HISTORY_WILL_UPDATED)
            return(ERR_HISTORY_WILL_UPDATED);
   }

   return(catch("start()"));
}


/**
 * Handler f�r PositionOpen-Events.
 *
 * @param int tickets[] - Tickets der neuen Positionen
 *
 * @return int - Fehlerstatus
 */
int onPositionOpen(int tickets[]) {
   if (!Track.Positions)
      return(0);

   // TODO: Sound und SMS nur bei ausgef�hrter Limit-Order und nicht bei manueller Market-Order ausl�sen
   // TODO: Unterscheidung zwischen Remote- und Home-Terminal, um Accountmi�brauch zu erkennen

   bool playSound = false;
   int size = ArraySize(tickets);

   for (int i=0; i < size; i++) {
      if (!OrderSelect(tickets[i], SELECT_BY_TICKET)) // FALSE ist praktisch nahezu unm�glich
         continue;

      // nur PositionOpen-Events des aktuellen Instruments ber�cksichtigen
      if (Symbol() == OrderSymbol()) {
         // 1. zuerst SMS abschicken ...
         if (SMS.Alerts) {
            string type       = GetOperationTypeDescription(OrderType());
            string lots       = DoubleToStrTrim(OrderLots());
            string instrument = GetConfigString("Instrument.Names", OrderSymbol(), OrderSymbol());
            string price      = FormatPrice(OrderOpenPrice(), MarketInfo(OrderSymbol(), MODE_DIGITS));

            string message = StringConcatenate(TimeToStr(TimeLocal(), TIME_MINUTES), " Position opened: ", type, " ", lots, " ", instrument, " @ ", price);
            int error = SendTextMessage(SMS.Receiver, message);
            if (error != ERR_NO_ERROR)
               return(catch("onPositionOpen(1)   error sending text message to "+ SMS.Receiver, error));
            Print("onPositionOpen()   SMS sent to ", SMS.Receiver, ":  ", message);
         }
         playSound = true;                            // Flag f�r Sound-Status setzen
      }
   }

   // 2. ... danach ggf. Sound spielen
   if (Sound.Alerts) if (playSound)                   // max. 1 x Sound, auch bei mehreren neuen Positionen
      PlaySound(Sound.File.PositionOpen);

   return(catch("onPositionOpen(2)"));
}


/**
 * Handler f�r PositionClose-Events.
 *
 * @param int tickets[] - Tickets der geschlossenen Positionen
 *
 * @return int - Fehlerstatus
 */
int onPositionClose(int tickets[]) {
   if (!Track.Positions)
      return(0);

   bool playSound = false;
   int size = ArraySize(tickets);

   for (int i=0; i < size; i++) {
      if (!OrderSelect(tickets[i], SELECT_BY_TICKET)) // false: praktisch nahezu unm�glich
         continue;

      // nur PositionClose-Events des aktuellen Instruments ber�cksichtigen
      if (Symbol() == OrderSymbol()) {
         // 1. zuerst SMS abschicken ...
         if (SMS.Alerts) {
            string type       = GetOperationTypeDescription(OrderType());
            string lots       = DoubleToStrTrim(OrderLots());
            string instrument = GetConfigString("Instrument.Names", OrderSymbol(), OrderSymbol());
            int    digits     = MarketInfo(OrderSymbol(), MODE_DIGITS);
            string openPrice  = FormatPrice(OrderOpenPrice(), digits);
            string closePrice = FormatPrice(OrderClosePrice(), digits);

            string message = StringConcatenate(TimeToStr(TimeLocal(), TIME_MINUTES), " Position closed: ", type, " ", lots, " ", instrument, " @ ", openPrice, " -> ", closePrice);
            int error = SendTextMessage(SMS.Receiver, message);
            if (error != ERR_NO_ERROR)
               return(catch("onPositionClose(1)   error sending text message to "+ SMS.Receiver, error));
            Print("onPositionClose()   SMS sent to ", SMS.Receiver, ":  ", message);
         }
         playSound = true;                            // Flag f�r Sound-Status setzen
      }
   }

   // 2. ... danach ggf. Sound spielen
   if (Sound.Alerts) if (playSound)                   // max. 1 x Sound, auch bei mehreren Positionen
      PlaySound(Sound.File.PositionClose);

   return(catch("onPositionClose(2)"));
}


/**
 * Handler f�r BarOpen-Events.
 *
 * @param int timeframes[] - Flags der Timeframes, in denen das Event aufgetreten ist
 *
 * @return int - Fehlerstatus
 */
int onBarOpen(int timeframes[]) {
   // BollingerBand-Limite zur�cksetzen
   if (Track.BollingerBands) {
      ArrayInitialize(bandLimits, 0);
      EventTracker.SetBandLimits(bandLimits);   // auch in Library
   }

   //Print("onBarOpen()   BarOpen event");
   return(catch("onBarOpen()"));
}


/**
 * Pr�ft, ob die normalen Kurslimite verletzt wurden und benachrichtigt entsprechend.
 *
 * @return int - Fehlerstatus
 */
int CheckQuoteChanges() {
   if (!Track.QuoteChanges)
      return(0);

   // aktuelle Limite ermitteln (und ggf. neu berechnen)
   if (quoteLimits[0] == 0) if (!EventTracker.QuoteLimits(quoteLimits)) {
      if (InitializeQuoteLimits() == ERR_HISTORY_WILL_UPDATED)
         return(ERR_HISTORY_WILL_UPDATED);

      EventTracker.QuoteLimits(quoteLimits);             // Limite in Library timeframe-�bergreifend speichern
      return(catch("CheckQuoteChanges(1)"));             // nach Initialisierung ist Test der Limite �berfl�ssig
   }


   double gridSize   = QuoteChanges.Gridsize / 10000.0;
   double upperLimit = quoteLimits[1]-0.00001,           // +-  1/10 pip, um Alert geringf�gig fr�her auszul�sen
          lowerLimit = quoteLimits[0]+0.00001;
   string message;
   int    error;

   // Limite �berpr�fen
   if (Ask > upperLimit) {
      // erst SMS, dann Sound
      if (SMS.Alerts) {
         message = StringConcatenate(TimeToStr(TimeLocal(), TIME_MINUTES), " ", Instrument.ShortName, " => ", DoubleToStr(quoteLimits[1], 4));
         error = SendTextMessage(SMS.Receiver, message);
         if (error != ERR_NO_ERROR)
            return(catch("CheckQuoteChanges(2)   error sending text message to "+ SMS.Receiver, error));
         Print("CheckQuoteChanges()   SMS sent to ", SMS.Receiver, ":  ", message, "   (Ask: ", FormatPrice(Ask, Digits), ")");
      }
      if (Sound.Alerts)
         PlaySound(Sound.File.Up);

      quoteLimits[1] = NormalizeDouble(quoteLimits[1] + gridSize, 4);
      quoteLimits[0] = NormalizeDouble(quoteLimits[1] - gridSize - gridSize, 4);    // Abstand: 2 x GridSize
      EventTracker.QuoteLimits(quoteLimits);                                        // neue Limite in Library speichern
      Print("CheckQuoteChanges()   quote limits adjusted: "+ DoubleToStr(quoteLimits[0], 4) +"  <=>  "+ DoubleToStr(quoteLimits[1], 4));
   }
   else if (Bid < lowerLimit) {
      // erst SMS, dann Sound
      if (SMS.Alerts) {
         message = StringConcatenate(TimeToStr(TimeLocal(), TIME_MINUTES), " ", Instrument.ShortName, " <= ", DoubleToStr(quoteLimits[0], 4));
         error = SendTextMessage(SMS.Receiver, message);
         if (error != ERR_NO_ERROR)
            return(catch("CheckQuoteChanges(3)   error sending text message to "+ SMS.Receiver, error));
         Print("CheckQuoteChanges()   SMS sent to ", SMS.Receiver, ":  ", message, "   (Bid: ", FormatPrice(Bid, Digits), ")");
      }
      if (Sound.Alerts)
         PlaySound(Sound.File.Down);

      quoteLimits[0] = NormalizeDouble(quoteLimits[0] - gridSize, 4);
      quoteLimits[1] = NormalizeDouble(quoteLimits[0] + gridSize + gridSize, 4);    // Abstand: 2 x GridSize
      EventTracker.QuoteLimits(quoteLimits);                                        // neue Limite in Library speichern
      Print("CheckQuoteChanges()   quote limits adjusted: ", DoubleToStr(quoteLimits[0], 4), "  <=>  ", DoubleToStr(quoteLimits[1], 4));
   }

   return(catch("CheckQuoteChanges(4)"));
}


/**
 * Pr�ft, ob die aktuellen BollingerBand-Limite verletzt wurden und benachrichtigt entsprechend.
 *
 * @return int - Fehlerstatus (ERR_HISTORY_WILL_UPDATED, falls die Kursreihe gerade aktualisiert wird)
 */
int CheckBollingerBands() {
   if (!Track.BollingerBands)
      return(0);

   // Limite ggf. initialisieren
   if (bandLimits[0] == 0) if (!EventTracker.GetBandLimits(bandLimits)) {
      if (InitializeBandLimits() == ERR_HISTORY_WILL_UPDATED)
         return(ERR_HISTORY_WILL_UPDATED);
      EventTracker.SetBandLimits(bandLimits);               // Limite in Library timeframe-�bergreifend speichern
   }

   double upperBand = bandLimits[MODE_UPPER]-0.000001,   // +- 1/100 pip, um Fehler beim Vergleich von Doubles zu vermeiden
          movingAvg = bandLimits[MODE_BASE ]+0.000001,
          lowerBand = bandLimits[MODE_LOWER]+0.000001;

   //Print("CheckBollingerBands()   band limits checked");
   return(catch("CheckBollingerBands(2)"));
}


/**
 * @return int - Fehlerstatus
 */
int CheckPivotLevels() {
   if (!Track.PivotLevels)
      return(0);

   return(catch("CheckPivotLevels()"));
}


/**
 * Initialisiert (berechnet und speichert) die aktuellen normalen Kurslimite.
 *
 * @return int - Fehlerstatus
 */
int InitializeQuoteLimits() {
   double gridSize = QuoteChanges.Gridsize / 10000.0;
   int    faktor   = MathFloor((Bid+Ask) / 2.0 / gridSize);

   quoteLimits[0] = NormalizeDouble(gridSize * faktor, 4);
   quoteLimits[1] = NormalizeDouble(gridSize * (faktor+1), 4);             // Abstand: 1 x GridSize

   // letztes Signal ermitteln und Limit in diese Richtung auf 2 x GridSize erweitern
   bool up=false, down=false;
   int error, period=Period();                                             // Ausgangsbasis ist der aktuelle Timeframe

   while (!up && !down) {
      for (int bar=0; bar <= Bars-1; bar++) {
         // TODO: Verwendung von Bars ist nicht sauber
         if (iLow (NULL, period, bar) < quoteLimits[0]) down = true;
         if (iHigh(NULL, period, bar) > quoteLimits[1]) up   = true;

         error = GetLastError();
         if (error == ERR_HISTORY_WILL_UPDATED) return(ERR_HISTORY_WILL_UPDATED);
         if (error != ERR_NO_ERROR            ) return(catch("InitializeQuoteLimits(1)", error));

         if (up || down)
            break;
      }

      if (up && down) {                                                    // Bar hat beide Limite ber�hrt
         if (period == PERIOD_M1)
            break;
         period = DecreasePeriod(period);                                  // Timeframe verringern
         up   = false;
         down = false;
      }
      else if (!up && !down) {
         return(catch("InitializeQuoteLimits(2)   error initializing quote limits", ERR_RUNTIME_ERROR));
      }
   }
   if (down) quoteLimits[0] = NormalizeDouble(quoteLimits[0] - gridSize, 4);
   if (up  ) quoteLimits[1] = NormalizeDouble(quoteLimits[1] + gridSize, 4);

   Print("InitializeQuoteLimits()   quote limits initialized: "+ DoubleToStr(quoteLimits[0], 4) +"  <=>  "+ DoubleToStr(quoteLimits[1], 4));
   return(catch("InitializeQuoteLimits(3)"));
}


/**
 * Initialisiert (berechnet und speichert) die aktuellen BollingerBand-Limite.
 *
 * @return int - Fehlerstatus (ERR_HISTORY_WILL_UPDATED, falls die Kursreihe gerade aktualisiert wird)
 */
int InitializeBandLimits() {
   // f�r h�here Genauigkeit Timeframe wenn m�glich auf M5 umrechnen
   int timeframe = BollingerBands.MA.Timeframe;
   int periods   = BollingerBands.MA.Periods;

   if (timeframe > PERIOD_M5) {
      double minutes = timeframe * periods;     // Timeframe * Anzahl Bars = Range in Minuten
      timeframe = PERIOD_M5;
      periods   = MathRound(minutes/PERIOD_M5);
   }

   int error = iBollingerBands(Symbol(), timeframe, periods, BollingerBands.MA.Method, PRICE_MEDIAN, BollingerBands.Deviation, 0, bandLimits);

   if (error == ERR_HISTORY_WILL_UPDATED) return(ERR_HISTORY_WILL_UPDATED);
   if (error != ERR_NO_ERROR            ) return(catch("InitializeBandLimits()", error));

   //Print("InitializeBandLimits()   band limits calculated: "+ FormatPrice(bandLimits[MODE_LOWER], 5) +"  <=  "+ FormatPrice(bandLimits[MODE_BASE], 5) +"  =>  "+ FormatPrice(bandLimits[MODE_UPPER], 5));
   return(error);
}


/**
 * Berechnet die BollingerBand-Werte (lowerBand, movingAverage, upperband) f�r eine Chart-Bar und speichert die Ergebnisse im angegebenen Array.
 *
 * @return int - Fehlerstatus (ERR_HISTORY_WILL_UPDATED, falls die Kursreihe gerade aktualisiert wird)
 */
int iBollingerBands(string symbol, int timeframe, int periods, int maMethod, int appliedPrice, double deviation, int bar, double& results[]) {
   if (symbol == "0")      // MQL: NULL ist ein Integer
      symbol = Symbol();

   double ma  = iMA    (symbol, timeframe, periods, 0, maMethod, appliedPrice, bar);
   double dev = iStdDev(symbol, timeframe, periods, 0, maMethod, appliedPrice, bar) * deviation;
   results[MODE_UPPER] = ma + dev;
   results[MODE_BASE ] = ma;
   results[MODE_LOWER] = ma - dev;

   int error = GetLastError();
   if (error == ERR_HISTORY_WILL_UPDATED) return(ERR_HISTORY_WILL_UPDATED);
   if (error != ERR_NO_ERROR            ) return(catch("iBollingerBands()", error));

   //Print("iBollingerBands(bar "+ bar +")   symbol: "+ symbol +"   timeframe: "+ timeframe +"   periods: "+ periods +"   maMethod: "+ maMethod +"   appliedPrice: "+ appliedPrice +"   deviation: "+ deviation +"   results: "+ FormatPrice(results[MODE_LOWER], 5) +"  <=  "+ FormatPrice(results[MODE_BASE], 5) +"  =>  "+ FormatPrice(results[MODE_UPPER], 5));
   return(error);
}

