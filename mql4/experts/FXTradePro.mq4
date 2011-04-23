/**
 * FXTradePro Martingale EA
 *
 * @see FXTradePro Strategy:     http://www.forexfactory.com/showthread.php?t=43221
 *      FXTradePro Journal:      http://www.forexfactory.com/showthread.php?t=82544
 *      FXTradePro Swing Trades: http://www.forexfactory.com/showthread.php?t=87564
 *
 *      PowerSM EA:              http://www.forexfactory.com/showthread.php?t=75394
 *      PowerSM Journal:         http://www.forexfactory.com/showthread.php?t=159789
 */
#include <stdlib.mqh>


int EA.uniqueId = 101;           // eindeutige ID des EA's im Bereich 0-1023


//////////////////////////////////////////////////////////////// Externe Parameter ////////////////////////////////////////////////////////////////

extern string _1____________________________ = "==== Entry Options ==============";
//extern string Entry.Direction                = "{ long | short }";
extern string Entry.Direction                = "long";
extern double Entry.Limit                    = 0;

extern string _2____________________________ = "==== TP and SL Settings =========";
extern int    TakeProfit                     = 40;
extern int    Stoploss                       = 10;

extern string _3____________________________ = "==== Lotsizes ==================";
extern double Lotsize.Level.1                =  0.1;
extern double Lotsize.Level.2                =  0.1;
extern double Lotsize.Level.3                =  0.2;
extern double Lotsize.Level.4                =  0.3;
extern double Lotsize.Level.5                =  0.4;
extern double Lotsize.Level.6                =  0.6;
extern double Lotsize.Level.7                =  0.8;
extern double Lotsize.Level.8                =  1.1;
extern double Lotsize.Level.9                =  1.5;
extern double Lotsize.Level.10               =  2.0;
extern double Lotsize.Level.11               =  2.7;
extern double Lotsize.Level.12               =  3.6;
extern double Lotsize.Level.13               =  4.7;
extern double Lotsize.Level.14               =  6.2;
extern double Lotsize.Level.15               =  8.0;
extern double Lotsize.Level.16               = 10.2;
extern double Lotsize.Level.17               = 13.0;
extern double Lotsize.Level.18               = 16.5;
extern double Lotsize.Level.19               = 20.8;
extern double Lotsize.Level.20               = 26.3;
extern double Lotsize.Level.21               = 33.1;
extern double Lotsize.Level.22               = 41.6;
extern double Lotsize.Level.23               = 52.2;
extern double Lotsize.Level.24               = 65.5;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


int    entryDirection;
int    openPositions, closedPositions;

int    lastPosition.ticket, last_ticket;  // !!! last_ticket ist nicht statisch und verursacht Fehler bei Timeframe-Wechseln etc.
int    lastPosition.type;
double lastPosition.lots;
int    lastPosition.result;

int    breakevenDistance    = 0;          // Gewinnschwelle in Point (nicht Pip), an der der StopLoss der Position auf BreakEven gesetzt wird
int    trailingStop         = 0;          // TrailingStop in Point (nicht Pip)
bool   trailStopImmediately = true;       // TrailingStop sofort starten oder warten, bis Position <trailingStop> Points im Gewinn ist

double minAccountBalance;                 // Balance-Minimum, um zu traden
double minAccountEquity;                  // Equity-Minimum, um zu traden


#define OP_NONE                       -1

#define RESULT_UNKNOWN                 0
#define RESULT_TAKEPROFIT              1
#define RESULT_STOPLOSS                2
#define RESULT_WINNER                  3
#define RESULT_LOOSER                  4
#define RESULT_BREAKEVEN               5

#define STATUS_ENTRYLIMIT_WAIT         1
#define STATUS_FINISHED                2
#define STATUS_UNSUFFICIENT_BALANCE    3
#define STATUS_UNSUFFICIENT_EQUITY     4


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   init = true; init_error = NO_ERROR; __SCRIPT__ = WindowExpertName();
   stdlib_init(__SCRIPT__);

   // Parameter �berpr�fen

   // Entry.Direction
   string direction = StringToUpper(StringTrim(Entry.Direction));
   if (StringLen(direction) == 0)
      return(catch("init(1)  Invalid input parameter Entry.Direction = \""+ Entry.Direction +"\"", ERR_INVALID_INPUT_PARAMVALUE));
   switch (StringGetChar(direction, 0)) {
      case 'B':
      case 'L': entryDirection = OP_BUY;  break;
      case 'S': entryDirection = OP_SELL; break;
      default:
         return(catch("init(2)  Invalid input parameter Entry.Direction = \""+ Entry.Direction +"\"", ERR_INVALID_INPUT_PARAMVALUE));
   }

   // Entry.Limit
   if (Entry.Limit < 0)
      return(catch("init(3)  Invalid input parameter Entry.Limit = "+ NumberToStr(Entry.Limit, ".+"), ERR_INVALID_INPUT_PARAMVALUE));

   // TakeProfit
   if (TakeProfit < 1)
      return(catch("init(4)  Invalid input parameter TakeProfit = "+ TakeProfit, ERR_INVALID_INPUT_PARAMVALUE));

   // Stoploss
   if (Stoploss < 1)
      return(catch("init(5)  Invalid input parameter Stoploss = "+ Stoploss, ERR_INVALID_INPUT_PARAMVALUE));


   // nicht auf den n�chsten Tick warten sondern sofort start() aufrufen
   SendTick(false);

   return(catch("init(6)"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int deinit() {
   Comment("");
   return(catch("deinit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int start() {
   init = false;

   // 1) aktuellen Status einlesen

   // 2) -> im Markt ?

   // 2.1) nein, nicht im Markt -> Entry.Limit definiert ?
   //    nein) in Entry.Direction in den Markt gehen
   //    ja)   -> Limit erreicht ?
   //       nein) warten
   //       ja)   in Entry.Direction in den Markt gehen

   // 2.2) ja, im Markt, Sequenz �bernehmen und fortsetzen








   ReadOrderStatus();
   ShowStatus();

   if (NewOrderPermitted()) {
      if (openPositions == 0) {
         if (lastPosition.type==OP_NONE) {
                                            SendOrder(entryDirection);
         }
         else if (Progressing()) {
            if (lastPosition.type==OP_SELL) SendOrder(OP_BUY);
            else                            SendOrder(OP_SELL);
         }
      }
      ShowStatus();
   }

   last_ticket = lastPosition.ticket;
   return(catch("start()"));
}


/**
 * Liest die Orderdaten der aktuellen Sequenz ein.
 *
 * @return int - Fehlerstatus
 */
int ReadOrderStatus() {
   // openPositions
   openPositions = 0;

   for (int i=OrdersTotal()-1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (IsMyOrder())
         openPositions++;
   }

   // closedPositions
   closedPositions = 0;

   for (i=OrdersHistoryTotal()-1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if (IsMyOrder()) {
         closedPositions++;
                                                                        lastPosition.ticket = OrderTicket();
                                                                        lastPosition.type   = OrderType();
                                                                        lastPosition.lots   = OrderLots();
         if      (CompareDoubles(OrderClosePrice(), OrderTakeProfit())) lastPosition.result = RESULT_TAKEPROFIT;
         else if (CompareDoubles(OrderClosePrice(), OrderStopLoss()))   lastPosition.result = RESULT_STOPLOSS;
         else if (OrderProfit() > 0)                                    lastPosition.result = RESULT_WINNER;
         else if (OrderProfit() < 0)                                    lastPosition.result = RESULT_LOOSER;
         else                                                           lastPosition.result = RESULT_BREAKEVEN;
      }
   }

   return(catch("ReadOrderStatus(2)"));
}


/**
 *
 */
bool IsMyOrder() {
   return(OrderSymbol()==Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderMagicNumber()==MagicNumber());
}


/**
 *
 */
bool NewOrderPermitted() {
   if (AccountBalance() < minAccountBalance) {
      ShowStatus(STATUS_UNSUFFICIENT_BALANCE);
      return(false);
   }

   if (AccountEquity() < minAccountEquity) {
      ShowStatus(STATUS_UNSUFFICIENT_EQUITY);
      return(false);
   }

   if (!CompareDoubles(Entry.Limit, 0)) {
      if (Ask != Entry.Limit && !Progressing()) {  // Bl�dsinn
         ShowStatus(STATUS_ENTRYLIMIT_WAIT);
         return(false);
      }
   }

   return(true);
}


/**
 *
 */
bool NewClosedPosition() {
   return(lastPosition.ticket!=last_ticket && last_ticket!=0);
}


/**
 *
 */
bool Progressing() {
   if (CompareDoubles(CurrentLotSize(), 0)) {
      ShowStatus(STATUS_FINISHED);
      return(false);
   }

   if (lastPosition.result == RESULT_STOPLOSS)
      return(true);

   return(false);
}


/**
 *
 * @return int - magic number
 */
int MagicNumber() {
   // 10 Bit f�r EA.uniqueId, 22 Bit f�r Expert-spezifische Werte
   int magicNumber = EA.uniqueId << 22;

   int error = GetLastError();
   if (error != NO_ERROR) {
      catch("MagicNumber()", error);
      return(0);
   }
   return(magicNumber);
}


/**
 *
 * @return int - Fehlerstatus
 */
int SendOrder(int type) {
   if (type!=OP_BUY && type!=OP_SELL)
      return(catch("SendOrder(1)   illegal parameter type = "+ type, ERR_INVALID_FUNCTION_PARAMVALUE));

   double price, sl, tp;

   switch (type) {
      case OP_BUY:  price = Ask;
                    if (Stoploss   > 0) sl = price - Stoploss  *Point;
                    if (TakeProfit > 0) tp = price + TakeProfit*Point;
                    break;

      case OP_SELL: price = Bid;
                    if (Stoploss   > 0) sl = price + Stoploss  *Point;
                    if (TakeProfit > 0) tp = price - TakeProfit*Point;
                    break;
   }

   double   lotsize    = CurrentLotSize();
   int      slippage   = 3;
   string   comment    = "FTP."+ MagicNumber() +"."+ CurrentLevel();
   datetime expiration = 0;

   log("SendOrder()   OrderSend("+ Symbol()+ ", "+ OperationTypeDescription(type) +", "+ NumberToStr(lotsize, ".+") +" lots, price="+ NumberToStr(price, ".+") +", slippage="+ NumberToStr(slippage, ".+") +", sl="+ NumberToStr(sl, ".+") +", tp="+ NumberToStr(tp, ".+") +", comment=\""+ comment +"\", magic="+ MagicNumber() +", expires="+ expiration +", Green)");

   int ticket = OrderSend(Symbol(), type, lotsize, price, slippage, sl, tp, comment, MagicNumber(), expiration, Green);

   if (ticket > 0) {
      if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
         log("SendOrder()   Progression level "+ CurrentLevel() +" ("+ NumberToStr(lotsize, ".+") +" lot) - "+ OperationTypeDescription(type) +" at "+ NumberToStr(OrderOpenPrice(), ".+"));
   }
   else return(catch("SendOrder(2)   error opening "+ OperationTypeDescription(type) +" order"));

   return(catch("SendOrder(3)"));
}


/**
 *
 * @return int - Fehlerstatus
 */
int BreakevenManager() {
   if (breakevenDistance <= 0)
      return(NO_ERROR);

   for (int i=0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if (IsMyOrder()) {
         if (OrderType()==OP_BUY) /*&&*/ if (OrderStopLoss() < OrderOpenPrice()) {
            if (Bid - OrderOpenPrice() >= breakevenDistance*Point)
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Green);
         }

         if (OrderType()==OP_SELL) /*&&*/ if (OrderStopLoss() > OrderOpenPrice()) {
            if (OrderOpenPrice() - Ask >= breakevenDistance*Point)
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Red);
         }
      }
   }
   return(catch("BreakEvenManager()"));
}


/**
 *
 * @return int - Fehlerstatus
 */
int TrailingStopManager() {
   int orders = OrdersTotal();

   for (int i=0; i < orders; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (IsMyOrder()) {
         if (OrderType() == OP_BUY) {
            if (trailStopImmediately || Bid - OrderOpenPrice() > trailingStop*Point)
               if (OrderStopLoss() < Bid - trailingStop*Point)
                  OrderModify(OrderTicket(), OrderOpenPrice(), Bid - trailingStop*Point, OrderTakeProfit(), 0, Green);
         }

         if (OrderType() == OP_SELL) {
            if (trailStopImmediately || OrderOpenPrice() - Ask > trailingStop*Point)
               if (OrderStopLoss() > Ask + trailingStop*Point || CompareDoubles(OrderStopLoss(), 0))
                  OrderModify(OrderTicket(), OrderOpenPrice(), Ask + trailingStop*Point, OrderTakeProfit(), 0, Red);
         }
      }
   }
   return(catch("TrailingStopManager()"));
}


/**
 * Setzt den aktuellen Progression-Level auf die n�chste Stufe.
 *
 * @return int - Fehlerstatus
 */
int IncreaseProgressionLevel() {
   return(catch("IncreaseProgressionLevel()"));
}


/**
 * Gibt den aktuellen Progression-Level zur�ck.
 *
 * @return int - Level oder -1, wenn ein Fehler auftrat
 */
int CurrentLevel() {
   int level = 1;

   int error = GetLastError();
   if (error != NO_ERROR) {
      catch("CurrentLevel()", error);
      return(-1);
   }
   return(level);
}


/**
 * Gibt die Lotsize des aktuellen Progression-Levels zur�ck.
 *
 * @return double - Lotsize oder -1, wenn ein Fehler auftrat
 */
double CurrentLotSize() {
   int level = CurrentLevel();

   switch (level) {
      case  0: return(0);                    // bei Fehler in CurrentLevel()
      case  1: return(Lotsize.Level.1);
      case  2: return(Lotsize.Level.2);
      case  3: return(Lotsize.Level.3);
      case  4: return(Lotsize.Level.4);
      case  5: return(Lotsize.Level.5);
      case  6: return(Lotsize.Level.6);
      case  7: return(Lotsize.Level.7);
      case  8: return(Lotsize.Level.8);
      case  9: return(Lotsize.Level.9);
      case 10: return(Lotsize.Level.10);
      case 11: return(Lotsize.Level.11);
      case 12: return(Lotsize.Level.12);
      case 13: return(Lotsize.Level.13);
      case 14: return(Lotsize.Level.14);
      case 15: return(Lotsize.Level.15);
      case 16: return(Lotsize.Level.16);
      case 17: return(Lotsize.Level.17);
      case 18: return(Lotsize.Level.18);
      case 19: return(Lotsize.Level.19);
      case 20: return(Lotsize.Level.20);
      case 21: return(Lotsize.Level.21);
      case 22: return(Lotsize.Level.22);
      case 23: return(Lotsize.Level.23);
      case 24: return(Lotsize.Level.24);
   }

   catch("CurrentLotSize()   illegal progression level = "+ level, ERR_RUNTIME_ERROR);
   return(-1);
}


/**
 *
 * @return int - Fehlerstatus
 */
int ShowStatus(int id=NULL) {
   string msg = "";

   switch (id) {
      case NULL                       : msg = "";                                                break;
      case STATUS_ENTRYLIMIT_WAIT     : msg = " waiting for entry limit to reach";               break;
      case STATUS_FINISHED            : msg = ":  Trading sequence finished.";                   break;
      case STATUS_UNSUFFICIENT_BALANCE: msg = ":  New orders disabled (balance below minimum)."; break;
      case STATUS_UNSUFFICIENT_EQUITY : msg = ":  New orders disabled (equity below minimum)." ; break;
   }

   string status = __SCRIPT__ + msg + LF
                 + LF
                 + "Progression Level:  "+ CurrentLevel() +"  =  "+ NumberToStr(CurrentLotSize(), ".+") +" lot"    + LF
                 + "TakeProfit:            "+ TakeProfit +" points"                                                + LF
                 + "Stoploss:               "+ Stoploss +" points"                                                 + LF
                 + "Breakeven:           "+ NumberToStr(Bid, "."+ (Digits-Digits%2) + ifString(Digits%2, "'", "")) + LF
                 + "Profit / Loss:          "+ DoubleToStr(0, 2)                                                   + LF;
   // 2 Zeilen Abstand nach oben f�r Instrumentanzeige
   Comment(LF+LF+ status);

   return(catch("ShowStatus(2)"));

   if (false) {
      BreakevenManager();
      TrailingStopManager();
      NewClosedPosition();
      IncreaseProgressionLevel();
   }
}
