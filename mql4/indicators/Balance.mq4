/**
 * Balance-Verlauf des aktuellen Accounts als Linienchart im Indikator-Subfenster
 */
#include <stdlib.mqh>

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1  Blue


double iBalance[];


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   init = true; init_error = NO_ERROR; __SCRIPT__ = WindowExpertName();
   stdlib_init(__SCRIPT__);

   // ERR_TERMINAL_NOT_YET_READY abfangen
   if (!GetAccountNumber()) {
      init_error = stdlib_GetLastError();
      return(init_error);
   }

   SetIndexBuffer(0, iBalance);
   SetIndexLabel (0, "Balance");
   IndicatorShortName("Balance");
   IndicatorDigits(2);

   // nach Parameter�nderung nicht auf den n�chsten Tick warten (nur im "Indicators List" window notwendig)
   if (UninitializeReason() == REASON_PARAMETERS)
      SendTick(false);

   return(catch("init()"));
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
   if      (init_error != NO_ERROR) ValidBars = 0;
   else if (last_error != NO_ERROR) ValidBars = 0;
   else                             ValidBars = IndicatorCounted();
   ChangedBars = Bars - ValidBars;
   stdlib_onTick(ValidBars);

   // init() nach ERR_TERMINAL_NOT_YET_READY nochmal aufrufen oder abbrechen
   if (init_error == ERR_TERMINAL_NOT_YET_READY) /*&&*/ if (!init)
      init();
   init = false;
   if (init_error != NO_ERROR)
      return(init_error);

   // Abschlu� der Chart-Initialisierung �berpr�fen
   if (Bars == 0 || ArraySize(iBalance) == 0) {          // tritt u.U. bei Terminal-Start auf
      last_error = ERR_TERMINAL_NOT_YET_READY;
      return(last_error);
   }
   last_error = NO_ERROR;
   // -----------------------------------------------------------------------------


   // Alle Werte komplett ...
   if (ValidBars == 0) {
      ArrayInitialize(iBalance, EMPTY_VALUE);      // vor Neuberechnung alte Werte zur�cksetzen
      last_error = iAccountBalanceSeries(AccountNumber(), iBalance);
   }
   else {                                          // ... oder nur die fehlenden Werte berechnen
      for (int bar=ChangedBars-1; bar >= 0; bar--) {
         last_error = iAccountBalance(AccountNumber(), iBalance, bar);
         if (last_error != NO_ERROR)
            break;
      }
   }

   return(catch("start()"));
}


