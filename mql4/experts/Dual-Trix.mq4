/**
 * Matrix EA (MA-Trix Convergence-Divergence)
 *
 * @see  https://www.mql5.com/en/code/165
 */
#include <stddefine.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern int BalanceDivider    = 1000;      // was "double DML  = 1000"
extern int DoublingCount     =    1;      // was "int    Ud   = 1"
extern int TakeProfit.Pip    =  150;      // was "int    Tp   = 1500"
extern int StopLoss.Pip      =   50;      // was "int    Stop = 500"
extern int Trix.Fast.Periods =    9;      // was "int    Fast = 9"
extern int Trix.Slow.Periods =   18;      // was "int    Slow = 9"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/expert.mqh>
#include <stdfunctions.mqh>
#include <stdlibs.mqh>


int m.level;

// OrderSend() defaults
string os.name        = "Dual-Trix";
int    os.magicNumber = 777;
int    os.slippage    = 1;


/**
 *
 */
int onTick() {
   if (Volume[0] == 1) {
      if (!OrdersTotal())              // TODO: simplified, works in Tester only
         OpenPosition();
   }
   return(last_error);
}


/**
 *
 */
double OnTester() {
   if (TakeProfit.Pip < StopLoss.Pip)
      return(0);
   return(GetPlRatio() / (GetMaxConsecutiveLosses()+1));
}


#define TRIX.MODE_MAIN     0
#define TRIX.MODE_TREND    1


/**
 *
 */
double iTrix(string symbol, int timeframe, int periods, int buffer, int bar) {
   return(1);
}


/**
 *
 */
void OpenPosition() {
   double tp, sl, lots;

   int fastTrixTrend = iTrix(Symbol(), NULL, Trix.Fast.Periods, TRIX.MODE_TREND, 1);
   int slowTrixTrend = iTrix(Symbol(), NULL, Trix.Slow.Periods, TRIX.MODE_TREND, 1);

   if (slowTrixTrend < 0) {                        // if slowTrix trend is down
      if (fastTrixTrend == 1) {                    // and fastTrix trend turned up
         lots = CalculateLots();
         tp   = Ask + TakeProfit.Pip * Pips;
         sl   = Bid -   StopLoss.Pip * Pips;
         OrderSend(Symbol(), OP_BUY, lots, Ask, os.slippage, sl, tp, os.name, os.magicNumber, NULL, Blue);
      }
   }

   else /*slowTrixTrend > 0*/ {                    // else if slowTrix trend is up
      if (fastTrixTrend == -1) {                   // and fastTrix trend turned down
         lots = CalculateLots();
         tp   = Bid - TakeProfit.Pip * Pips;
         sl   = Ask +   StopLoss.Pip * Pips;
         OrderSend(Symbol(), OP_SELL, lots, Bid, os.slippage, sl, tp, os.name, os.magicNumber, NULL, Red);
      }
   }
}


/**
 *
 */
double CalculateLots() {
   double lots = MathFloor(AccountBalance()/BalanceDivider) * MarketInfo(Symbol(), MODE_MINLOT);
   if (!lots) lots = MarketInfo(Symbol(), MODE_MINLOT);
   if (!DoublingCount)
      return(lots);

   int history = OrdersHistoryTotal();                   // TODO: over-simplified, works only in Tester
   if (history < 2) return(lots);

   OrderSelect(history-1, SELECT_BY_POS, MODE_HISTORY);  // last closed ticket
   double lastOpenPrice = OrderOpenPrice();

   OrderSelect(history-2, SELECT_BY_POS, MODE_HISTORY);  // previous closed ticket
   int    prevType      = OrderType();
   double prevOpenPrice = OrderOpenPrice();
   double prevLots      = OrderLots();


   // this logic looks like complete non-sense
   if (prevType == OP_BUY) {
      if (prevOpenPrice > lastOpenPrice && m.level < DoublingCount) {
         lots = prevLots * 2;
         m.level++;
      }
      else {
         m.level = 0;
      }
   }

   else if (prevType == OP_SELL) {
      if (prevOpenPrice < lastOpenPrice && m.level < DoublingCount) {
         lots = prevLots * 2;
         m.level++;
      }
      else {
         m.level = 0;
      }
   }
   return(lots);

   OnTester();    // dummy call to suppress compiler warnings
}


/**
 *
 */
double GetMaxConsecutiveLosses() {
   double thisOpenPrice, nextOpenPrice;
   int    thisType, counter, max, history = OrdersHistoryTotal();

   // again the logic is utter non-sense
   for (int i=0; i < history-1; i+=2) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      thisType      = OrderType();
      thisOpenPrice = OrderOpenPrice();

      OrderSelect(i+1, SELECT_BY_POS, MODE_HISTORY);
      nextOpenPrice = OrderOpenPrice();

      if (thisType == OP_BUY) {
         if (nextOpenPrice > thisOpenPrice) {
            if (counter > max) max = counter;
            counter = 0;
         }
         else counter++;
      }
      else if (thisType == OP_SELL) {
         if (nextOpenPrice < thisOpenPrice) {
            if (counter > max) max = counter;
            counter = 0;
         }
         else counter++;
      }
   }
   return(max);
}


/**
 *
 */
double GetPlRatio() {
   double thisOpenPrice, nextOpenPrice;
   int    thisType, profits, losses=1, history=OrdersHistoryTotal();

   for (int i=0; i < history-1; i+=2) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      thisType      = OrderType();
      thisOpenPrice = OrderOpenPrice();

      OrderSelect(i+1, SELECT_BY_POS, MODE_HISTORY);
      nextOpenPrice = OrderOpenPrice();

      if (thisType == OP_BUY) {
         if (nextOpenPrice > thisOpenPrice) profits++;
         else                               losses++;
      }
      else if (thisType == OP_SELL) {
         if (nextOpenPrice < thisOpenPrice) profits++;
         else                               losses++;
      }
   }
   return(1.* profits/losses);
}
