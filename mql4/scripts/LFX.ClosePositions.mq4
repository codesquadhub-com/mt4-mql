/**
 * Schlie�t die angegebenen LFX-Positionen.
 */
#include <stdlib.mqh>


#property show_inputs


//////////////////////////////////////////////////////////////// Externe Parameter ////////////////////////////////////////////////////////////////

extern string LFX.Labels = "";                           // Label-1 [, Label-n [, ...]]      (Pr�fung per OrderComment().StringIStartsWith(value))

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


int Strategy.Id = 102;                                   // eindeutige ID der Strategie (Bereich 101-1023)

string labels[];
int    sizeOfLabels;


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   if (onInit(T_SCRIPT) != NO_ERROR)
      return(last_error);

   // Parametervalidierung
   LFX.Labels = StringTrim(LFX.Labels);
   if (StringLen(LFX.Labels) == 0)
      return(catch("init(1)  Invalid input parameter LFX.Labels = \""+ LFX.Labels +"\"", ERR_INVALID_INPUT_PARAMVALUE));

   // Parameter splitten und die einzelnen Label trimmen
   sizeOfLabels = Explode(LFX.Labels, ",", labels, NULL);

   for (int i=0; i < sizeOfLabels; i++) {
      labels[i] = StringTrim(labels[i]);
   }
   return(catch("init(2)"));
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
int onStart() {
   // letztes selektiertes Ticket speichern
   int _error_      = GetLastError(); if (IsError(_error_)) return(catch("onStart(1)", _error_));
   int _lastTicket_ = OrderTicket(); GetLastError();


   int    orders = OrdersTotal();
   string positions[]; ArrayResize(positions, 0);
   int    tickets  []; ArrayResize(tickets, 0);


   // (1) zu schlie�ende Positionen selektieren
   for (int i=0; i < orders; i++) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))      // FALSE: w�hrend des Auslesens wird in einem anderen Thread eine aktive Order geschlossen oder gestrichen
         break;

      if (IsMyOrder()) {
         if (OrderType() > OP_SELL)
            continue;

         for (int n=0; n < sizeOfLabels; n++) {
            if (StringIStartsWith(OrderComment(), labels[n])) {
               string label = LFX.Currency(OrderMagicNumber()) +"."+ LFX.Counter(OrderMagicNumber());
               if (!StringInArray(label, positions))
                  ArrayPushString(positions, label);
               if (!IntInArray(OrderTicket(), tickets))
                  ArrayPushInt(tickets, OrderTicket());
               break;
            }
         }
      }
   }


   // (2) Positionen schlie�en
   int sizeOfPositions = ArraySize(positions);
   if (sizeOfPositions > 0) {
      PlaySound("notify.wav");
      int button = MessageBox(ifString(!IsDemo(), "- Live Account -\n\n", "") +"Do you really want to close the specified "+ ifString(sizeOfPositions==1, "", sizeOfPositions +" ") +"position"+ ifString(sizeOfPositions==1, "", "s") +"?", __SCRIPT__, MB_ICONQUESTION|MB_OKCANCEL);
      if (button == IDOK) {
         if (!OrderMultiClose(tickets, 0.1, Orange))
            return(SetLastError(stdlib_PeekLastError()));

         // TODO: erzielten ClosePrice() berechnen und ausgeben

         // (3) Positionen aus "experts\files\SIG\remote_positions.ini" l�schen
         string file    = TerminalPath() +"\\experts\\files\\SIG\\remote_positions.ini";
         string section = ShortAccountCompany() +"."+ AccountNumber();
         for (i=0; i < sizeOfPositions; i++) {
            int error = DeletePrivateProfileKey(file, section, positions[i]);
            if (IsError(error))
               return(SetLastError(error));
         }
      }
   }
   else {
      PlaySound("notify.wav");
      MessageBox("No matching positions found.", __SCRIPT__, MB_ICONEXCLAMATION|MB_OK);
   }

   // letztes selektiertes Ticket restaurieren
   if (_lastTicket_ != 0) OrderSelect(_lastTicket_, SELECT_BY_TICKET);
   return(catch("onStart(2)"));
}


/**
 * Ob die aktuell selektierte Order zu dieser Strategie geh�rt.
 *
 * @return bool
 */
bool IsMyOrder() {
   return(StrategyId(OrderMagicNumber()) == Strategy.Id);
}
