/**
 * Zeichnet den Balance-Verlauf eines Accounts.
 */

#include <stdlib.mqh>


#property indicator_separate_window

#property indicator_buffers 1

#property indicator_color1  Blue
#property indicator_width1  2


// Account, dessen Balance angezeigt werden soll (default: der aktuelle Account)
extern int account = 0;


double Balance[];


/**
 *
 */
int init() {
   SetIndexBuffer(0, Balance);
   SetIndexLabel (0, "Balance");
   SetIndexStyle (0, DRAW_LINE);

   IndicatorDigits(2);

   // w�hrend der Entwicklung Puffer explizit zur�cksetzen
   if (UninitializeReason() == REASON_RECOMPILE) {
      ArrayInitialize(Balance, EMPTY_VALUE);
   }

   if (account == 0)
      account = AccountNumber();

   return(catch("init()"));
}


/**
 *
 */
int start() {
   int processedBars = IndicatorCounted();

   if (processedBars == 0) {                          // 1. Aufruf oder nach Data-Pumping: alles neu berechnen
      iBalanceSeries(account, Balance);
      return(catch("start(1)"));
   }

   for (int i=Bars-processedBars-1; i >= 0; i--) {    // nur fehlende Werte neu berechnen
      iBalance(account, Balance, i);
   }

   return(catch("start(2)"));
}


/**
 * Berechnet den vollst�ndigen Verlauf der Balance f�r den aktuellen Chart und schreibt die Werte in den �bergebenen
 * Indikatorpuffer.  Diese Funktion ist vorzuziehen, wenn der Indikator vollst�ndig neu berechnet werden soll.
 *
 * @param int     account - Account, f�r den der Indikator berechnet werden soll
 * @param double& iBuffer - Zeichenpuffer, mu� dem aktuellen Chart entsprechend dimensioniert sein
 *
 * @return int - Fehlerstatus
 */
int iBalanceSeries(int account, double& iBuffer[]) {

   // Balance-History holen
   datetime bTimes[];
   double   bValues[];
   GetBalanceHistory(account, bTimes, bValues);

   int n, lastN, z, size=ArraySize(bTimes);


   // Balancewerte in Buffer �bertragen (die History ist nach Zeit sortiert)
   for (int i=0; i<size; i++) {
      // Barindex des Zeitpunkts berechnen und nur Chartzeitraum ber�cksichtigen
      n = iBarShift(NULL, 0, bTimes[i], true);
      if (n == -1) {
         if (bTimes[i] > Time[0])   // dieser und alle folgenden Werte sind zu neu f�r den Chart
            break;
         continue;                  // diese Werte sind zu alt f�r den Chart
      }

      // Indikatorl�cken mit vorherigem Balancewert f�llen
      if (n < lastN-1) {
         for (z=lastN-1; z > n; z--)
            iBuffer[z] = iBuffer[lastN];
      }

      // Balancewert eintragen
      iBuffer[n] = bValues[i];
      lastN = n;
   }


   // Indikator bis zur ersten Bar mit dem letzten bekannten Wert f�llen
   for (n=lastN-1; n >= 0; n--) {
      iBuffer[n] = iBuffer[lastN];
   }

   return(catch("iBalanceSeries()"));
}


/**
 * Berechnet den Balancewert am angegebenen Offset des aktuellen Charts und schreibt ihn in den bereitgestellten
 * Indikatorpuffer.
 *
 * NOTE:
 * -----
 * Die einzelnen Werte dieses Indikators h�ngen von vorhergehenden Werten desselben Indikators ab. Daher vereinfacht
 * und beschleunigt der �bergebene Indikatorpuffer die Berechnung einzelner Werte ganz wesentlich.
 *
 * @param int     account - Account, f�r den der Indikator berechnet werden soll
 * @param double& iBuffer - Zeichenpuffer, mu� dem aktuellen Chart entsprechend dimensioniert sein
 * @param int     offset  - Chart-Offset des zu berechnenden Wertes (Barindex)
 *
 * @return int - Fehlerstatus
 */
int iBalance(int account, double& iBuffer[], int offset) {

   // TODO: zur Vereinfachung wird der Indikator hier noch komplett neuberechnet
   iBalanceSeries(account, iBuffer);

   return(catch("iBalance()"));
}

