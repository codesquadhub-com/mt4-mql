/*
   Generated by EX4 TO MQ4 decompile Service
   Website: http://www.ex4Tomq4.net
   E-mail : info@ex4Tomq4.net
*/
#property copyright "Dan Davidson"
#property link      "Dan@fxtradepro.com"

extern string id = "==== EA Identity Settings =========";
extern string ExpertName = "FXTradepro Manager";
extern int MagicNumber = 21354;
extern bool Disable_Comments = FALSE;
//int expires = D'06.10.2007 04:30';
extern string basic = "==== TP and SL Settings ========";
extern int TakeProfit = 40;
extern int Stoploss = 10;
double gd_120 = 0.1;
extern string entry = "==== Entry Options =============";
extern bool FirstOrder_Long = TRUE;
extern bool Hibernation = TRUE;
bool gi_144 = FALSE;
extern string time = "==== Time Entry Option ==========";
extern bool TimeEntry = FALSE;
extern int EntryHour = 0;
extern int EntryMinute = 55;
extern string price = "==== Price Entry Option ========";
extern bool PriceEntry = FALSE;
extern double Price = 0.0;
extern string multilot = "==== MultiLot Settings ======";
extern double MLot1 = 0.1;
extern double MLot2 = 0.1;
extern double MLot3 = 0.2;
extern double MLot4 = 0.3;
extern double MLot5 = 0.4;
extern double MLot6 = 0.6;
extern double MLot7 = 0.8;
extern double MLot8 = 1.1;
extern double MLot9 = 1.5;
extern double MLot10 = 2.0;
extern double MLot11 = 2.7;
extern double MLot12 = 3.6;
extern double MLot13 = 4.7;
extern double MLot14 = 6.2;
extern double MLot15 = 8.0;
extern double MLot16 = 10.2;
extern double MLot17 = 13.0;
extern double MLot18 = 16.5;
extern double MLot19 = 20.8;
extern double MLot20 = 26.3;
extern double MLot21 = 33.1;
extern double MLot22 = 41.6;
extern double MLot23 = 52.2;
extern double MLot24 = 65.5;
int gi_388 = 0;
int gi_392 = 0;
int gi_396 = 0;
bool gi_400 = FALSE;
bool gi_404 = FALSE;
bool gi_408 = FALSE;
bool gi_412 = TRUE;
bool gi_416 = TRUE;
int gi_420 = 0;
int gi_424 = 0;
int g_count_428 = 0;
int g_count_432 = 0;
int g_count_436 = 0;
int g_count_440 = 0;
int g_count_444 = 0;
int g_count_448 = 0;
int gi_452 = 0;
int gi_456 = 0;
int gi_460 = 0;
int gi_464 = 0;
int gi_468 = 0;
int gi_472 = 0;
int gi_476 = 0;
int gi_480;
int gi_484;
int gia_488[1];
int gia_492[1];
double gda_496[1];
int gi_500;
int gi_504;
string g_var_name_508;
bool gi_516 = FALSE;
bool gi_520 = FALSE;
bool gi_524 = FALSE;
double gd_528 = 0.0;

int init() {
   dynaReset();
   makeGlobals();
   onScreenComment(91);
   return (0);
}

int deinit() {
   onScreenComment(99);
   return (0);
}

int start() {
   houseKeeper();
   onScreenComment(98);
   if (newClosing() && progressing()) updateProgression();
   if (gia_492[0] == 2 || gi_480 == 0) resetProgression();
   if (gi_412 == FALSE && gi_460 > 0) {
   }
   if (gi_416 == FALSE && gi_464 > 0) {
   }
   if (newOrderPermitted(1)) {
      findMyOrders();
      if (gi_468 == 0) {
         if (lastOrderType() == 9 && FirstOrder_Long) sendLongOrder();
         if (lastOrderType() == 1 && progressing()) sendLongOrder();
         if (lastOrderType() == 0 && newSeries()) sendLongOrder();
      }
   }
   if (newOrderPermitted(2)) {
      findMyOrders();
      if (gi_468 == 0) {
         if (lastOrderType() == 9) sendShortOrder();
         if (lastOrderType() == 0 && progressing()) sendShortOrder();
         if (lastOrderType() == 1 && newSeries()) sendShortOrder();
      }
      gi_484 = gi_480;
      onScreenComment(98);
   }
   return (0);
}

void sendLongOrder() {
   versatileOrderTaker(1, -1, Ask);
}

void sendShortOrder() {
   versatileOrderTaker(2, -1, Bid);
}

void onScreenComment(int ai_0) {
   string ls_unused_4;
   string ls_unused_12;
   string l_dbl2str_20;
   string ls_28;
   string ls_36;
   string ls_44;
   string ls_52;
   if (Disable_Comments == FALSE) {
      ls_unused_4 = DoubleToStr(AccountBalance(), 2);
      ls_unused_12 = DoubleToStr(AccountEquity(), 2);
      l_dbl2str_20 = DoubleToStr(getLotForProgression(), 2);
      ls_28 = "\n";
      ls_44 = ExpertName + " is Trading.";
      if (gi_144) ls_36 = "Dynamic";
      else ls_36 = "Regular";
      ls_52 = ls_28 + ls_28 + "Date and Time:  " + TimeToStr(TimeCurrent()) + ls_28 + ls_36 + " TakeProfit:  " + gi_504 + ls_28 + ls_36 + " Stoploss:  " + gi_500 + ls_28 + "Progression Level:  " + getProgression() + ls_28 + "Lot Size:  " + l_dbl2str_20 + ls_28;
      switch (ai_0) {
      case 91:
         Comment(ExpertName + " is waiting for the next tick to begin Trading.");
         return;
      case 96:
         Comment(ls_28 + ExpertName + " has expired.  Please contact Dan@fxtradepro.com.");
         return;
      case 98:
         Comment(ls_44 + ls_52);
         return;
      case 99:
         Comment(" ");
         return;
      case 11:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  User option");
         return;
      case 12:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  User Settings");
         return;
      case 13:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Equity below minumum");
         return;
      case 14:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Balance below minimum");
         return;
      case 15:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Existing orders at maximum");
         return;
      case 21:
         Comment(ls_44 + ls_52 + "New Long Orders Disabled:  User option");
         return;
      case 22:
         Comment(ls_44 + ls_52 + "New Long Orders Disabled:  Internal calculation");
         return;
      case 31:
         Comment(ls_44 + ls_52 + "New Short Orders Disabled:  User option");
         return;
      case 32:
         Comment(ls_44 + ls_52 + "New Short Orders Disabled:  Internal calculation");
         return;
      case 41:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Hibernation");
         return;
      case 42:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Out of Time Range");
         return;
      case 43:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Out of Price Range");
         return;
      case 44:
         Comment(ls_44 + ls_52 + "New Orders Disabled:  Progression has been exhausted");
      }
   }
}

void houseKeeper() {
   g_count_428 = 0;
   g_count_432 = 0;
   g_count_436 = 0;
   g_count_440 = 0;
   g_count_444 = 0;
   g_count_448 = 0;
   gi_452 = 0;
   gi_456 = 0;
   gi_460 = 0;
   gi_464 = 0;
   gi_468 = 0;
   gi_472 = 0;
   gi_476 = 0;
   gi_516 = FALSE;
   gi_520 = FALSE;
   gd_528 = Ask - Bid;
   findMyOrders();
   findMyOrders_HISTORIC();
   historyLogger();
   if (gi_468 > 0) {
      if (gi_388 > 0) breakEvenManager();
      if (gi_396 > 0) trailingStopManager();
   }
}

int simpleMagicGenerator() {
   return (MagicNumber);
}

bool orderBelongsToMe() {
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == simpleMagicGenerator()) return (TRUE);
   return (FALSE);
}

void findMyOrders() {
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (orderBelongsToMe()) {
         if (OrderType() == OP_BUY) g_count_428++;
         else {
            if (OrderType() == OP_SELL) g_count_432++;
            else {
               if (OrderType() == OP_BUYSTOP) g_count_436++;
               else {
                  if (OrderType() == OP_SELLSTOP) g_count_440++;
                  else {
                     if (OrderType() == OP_BUYLIMIT) g_count_444++;
                     else
                        if (OrderType() == OP_SELLLIMIT) g_count_448++;
                  }
               }
            }
         }
      }
   }
   gi_452 = g_count_436 + g_count_444;
   gi_456 = g_count_440 + g_count_448;
   gi_472 = gi_452 + gi_456;
   gi_468 = g_count_428 + g_count_432;
   gi_460 = g_count_436 + g_count_444 + g_count_428;
   gi_464 = g_count_440 + g_count_448 + g_count_432;
   gi_476 = gi_468 + gi_472;
}

void findMyOrders_HISTORIC() {
   gi_480 = 0;
   int li_0 = 0;
   int li_4 = 1;
   bool li_8 = FALSE;
   int l_hist_total_12 = OrdersHistoryTotal();
   if (OrdersHistoryTotal() > 0) {
      for (int l_pos_16 = li_8; l_pos_16 < l_hist_total_12; l_pos_16++) {
         OrderSelect(l_pos_16, li_0, li_4);
         if (orderBelongsToMe()) gi_480++;
      }
   }
}

bool newOrderPermitted(int ai_0) {
   if (gi_404 && gi_408) {
      onScreenComment(11);
      return (FALSE);
   }
   if (gi_516 && gi_520) {
      onScreenComment(12);
      return (FALSE);
   }
   if (AccountEquity() < gi_420) {
      onScreenComment(13);
      return (FALSE);
   }
   if (AccountBalance() < gi_424) {
      onScreenComment(14);
      return (FALSE);
   }
   if (Hibernation) {
      if (gia_492[0] == 2) {
         onScreenComment(41);
         return (FALSE);
      }
   }
   if (TimeEntry) {
      if (!(Hour() == EntryHour && Minute() >= EntryMinute) && progressing() == 0) {
         onScreenComment(42);
         return (FALSE);
      }
   }
   if (PriceEntry) {
      if (Ask != Price && progressing() == 0) {
         onScreenComment(43);
         return (FALSE);
      }
   }
   if (ai_0 == 1) {
      if (gi_404) {
         onScreenComment(21);
         return (FALSE);
      }
      if (gi_516) {
         onScreenComment(22);
         return (FALSE);
      }
      return (TRUE);
   }
   if (ai_0 == 2) {
      if (gi_408) {
         onScreenComment(31);
         return (FALSE);
      }
      if (gi_520) {
         onScreenComment(32);
         return (FALSE);
      }
      return (TRUE);
   }
   return (FALSE);
}

double lotMaker() {
   double ld_ret_0 = gd_120;
   ld_ret_0 = getLotForProgression();
   if (ld_ret_0 <= 0.0) ld_ret_0 = 0.1;
   if (ld_ret_0 > 100.0) ld_ret_0 = 100;
   return (ld_ret_0);
}

void breakEvenManager() {
   for (int l_pos_0 = 0; l_pos_0 < OrdersTotal(); l_pos_0++) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (gi_388 > 0 && orderBelongsToMe()) {
         if (OrderType() == OP_BUY) {
            if (Bid - OrderOpenPrice() >= Point * gi_388)
               if (OrderStopLoss() < OrderOpenPrice() + gi_392 * Point) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + gi_392 * Point, OrderTakeProfit(), 0, Green);
         } else {
            if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask >= Point * gi_388)
                  if (OrderStopLoss() > OrderOpenPrice() - gi_392 * Point) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - gi_392 * Point, OrderTakeProfit(), 0, Red);
            }
         }
      }
   }
}

void trailingStopManager() {
   int l_ord_total_4 = OrdersTotal();
   for (int l_pos_0 = 0; l_pos_0 < l_ord_total_4; l_pos_0++) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (gi_396 > 0 && orderBelongsToMe()) {
         if (OrderType() == OP_BUY) {
            if (Bid - OrderOpenPrice() > Point * gi_396 || gi_400 == FALSE)
               if (OrderStopLoss() < Bid - Point * gi_396) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * gi_396, OrderTakeProfit(), 0, Green);
         } else {
            if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask > Point * gi_396 || gi_400 == FALSE)
                  if (OrderStopLoss() > Ask + Point * gi_396 || OrderStopLoss() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * gi_396, OrderTakeProfit(), 0, Red);
            }
         }
      }
   }
}

string commentString() {
   return (ExpertName + " " + Symbol());
}

void versatileOrderTaker(int ai_0, int ai_4, double a_price_8) {
   int l_ticket_48;
   int l_cmd_52;
   string ls_56;
   double l_price_16 = 0;
   double l_price_24 = 0;
   double l_lots_32 = 0;
   int l_slippage_40 = 3;
   int l_datetime_44 = 0;
   if (ai_4 < 0) l_lots_32 = lotMaker();
   else l_lots_32 = ai_4;
   string l_dbl2str_64 = DoubleToStr(l_lots_32, 2);
   if (newClosing()) dynaAdjust();
   if (gia_492[0] == 2 || gi_480 == 0) dynaReset();
   switch (ai_0) {
   case 2:
      l_cmd_52 = 1;
      ls_56 = "SELL";
      a_price_8 = Bid;
      if (Stoploss > 0) l_price_16 = a_price_8 + gi_500 * Point;
      if (TakeProfit > 0) l_price_24 = a_price_8 - gi_504 * Point;
      break;
   case 1:
      l_cmd_52 = 0;
      ls_56 = "BUY";
      a_price_8 = Ask;
      if (Stoploss > 0) l_price_16 = a_price_8 - gi_500 * Point;
      if (TakeProfit > 0) l_price_24 = a_price_8 + gi_504 * Point;
      break;
   default:
      Print("versatileOrderTaker has been passed an invalid SimpleType parameter: " + ai_0);
   }
   if (gi_524 == FALSE) {
      l_ticket_48 = OrderSend(Symbol(), l_cmd_52, l_lots_32, a_price_8, l_slippage_40, l_price_16, l_price_24, commentString(), simpleMagicGenerator(), l_datetime_44, Green);
      if (l_ticket_48 > 0) {
         if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) Print(ExpertName + " " + Symbol() + " - Progression Level " + getProgression() + " @ " + l_dbl2str_64 + " Lots - " + ls_56 + " order at ", OrderOpenPrice());
      } else Print("Error opening " + ls_56 + " order: ", GetLastError());
   }
}

void historyLogger() {
   string ls_8;
   int l_index_4 = gi_480 - 1;
   l_index_4 = 0;
   if (gi_480 > 0) {
      if (gi_480 > 1) {
         ArrayResize(gia_488, gi_480);
         ArrayResize(gda_496, gi_480);
         ArrayResize(gia_492, gi_480);
      }
      for (int l_pos_0 = OrdersHistoryTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
         OrderSelect(l_pos_0, SELECT_BY_POS, MODE_HISTORY);
         if (orderBelongsToMe()) {
            gia_488[l_index_4] = l_pos_0;
            gda_496[l_index_4] = OrderLots();
            if (OrderClosePrice() == OrderTakeProfit()) gia_492[l_index_4] = 2;
            else {
               if (OrderClosePrice() == OrderStopLoss()) gia_492[l_index_4] = -2;
               else {
                  if (OrderProfit() > 0.0) gia_492[l_index_4] = 1;
                  else {
                     if (OrderProfit() < 0.0) gia_492[l_index_4] = -1;
                     else gia_492[l_index_4] = 0;
                  }
               }
            }
            l_index_4++;
         }
      }
   }
   for (l_pos_0 = 0; l_pos_0 < gi_480; l_pos_0++) {
      ls_8 = ls_8 + gia_488[l_pos_0] + " " + gia_492[l_pos_0] + " " + gda_496[l_pos_0]
      + "\n";
   }
}

int lastOrderType() {
   if (gi_480 == 0) return (9);
   OrderSelect(gia_488[0], SELECT_BY_POS, MODE_HISTORY);
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) return (OrderType());
   return (9);
}

void dynaAdjust() {
   if (gi_144) {
      gi_504++;
      gi_500--;
   }
}

void dynaReset() {
   gi_504 = TakeProfit;
   gi_500 = Stoploss;
}

bool newClosing() {
   return (gi_480 != gi_484);
}

int progressing() {
   if (getLotForProgression() == 0.0) {
      onScreenComment(44);
      return (0);
   }
   if (gia_492[0] == -2) return (1);
   return (0);
}

int newSeries() {
   return (gia_492[0] == 2);
}

void updateProgression() {
   GlobalVariableSet(g_var_name_508, getProgression() + 1);
}

void resetProgression() {
   GlobalVariableSet(g_var_name_508, 1);
}

int getProgression() {
   return (GlobalVariableGet(g_var_name_508));
}

double getLotForProgression() {
   switch (getProgression()) {
   case 1:
      return (MLot1);
   case 2:
      return (MLot2);
   case 3:
      return (MLot3);
   case 4:
      return (MLot4);
   case 5:
      return (MLot5);
   case 6:
      return (MLot6);
   case 7:
      return (MLot7);
   case 8:
      return (MLot8);
   case 9:
      return (MLot9);
   case 10:
      return (MLot10);
   case 11:
      return (MLot11);
   case 12:
      return (MLot12);
   case 13:
      return (MLot13);
   case 14:
      return (MLot14);
   case 15:
      return (MLot15);
   case 16:
      return (MLot16);
   case 17:
      return (MLot17);
   case 18:
      return (MLot18);
   case 19:
      return (MLot19);
   case 20:
      return (MLot20);
   case 21:
      return (MLot21);
   case 22:
      return (MLot22);
   case 23:
      return (MLot23);
   case 24:
      return (MLot24);
   }
   return (MLot1);
}

void makeGlobals() {
   g_var_name_508 = AccountNumber() + "_" + Symbol() + "_Progression";
   if (!GlobalVariableCheck(g_var_name_508)) resetProgression();
}
