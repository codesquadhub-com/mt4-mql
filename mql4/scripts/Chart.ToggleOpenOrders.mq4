/**
 * Aktiviert/deaktiviert die Anzeige der in "remote_positions.ini" gespeicherten offenen LFX-Tickets des aktuellen Accounts.
 */
#include <stddefine.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];
#include <stdlib.mqh>
#include <win32api.mqh>

#include <core/script.mqh>
#include <lfx.mqh>


string lfxCurrency;                                                  // aktuelle LFX-W�hrung
int    lfxCurrencyId;
double lfxChartDeviation;

int    remoteAccount;                                                // aktueller Remote-Account
string remoteAccountCompany;                                         // Company des Remote-Accounts


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int onInit() {
   // (1) LFX-Currency, ID und Chartabweichung setzen
   if      (StringStartsWith(Symbol(), "LFX")) lfxCurrency = StringRight(Symbol(), -3);
   else if (StringEndsWith  (Symbol(), "LFX")) lfxCurrency = StringLeft (Symbol(), -3);
   else {
      PlaySound("notify.wav");
      MessageBox("Cannot display LFX orders on a non LFX chart (\""+ Symbol() +"\")", __NAME__ +"::init()", MB_ICONSTOP|MB_OK);
      return(SetLastError(ERR_RUNTIME_ERROR));
   }
   lfxCurrencyId     = GetCurrencyId(lfxCurrency);
   lfxChartDeviation = GetGlobalConfigDouble("LfxChartDeviation", lfxCurrency, 0);


   // (2) aktuellen Remote-Account und dessen AccountCompany ermitteln
   string section = "LFX";
   string key     = "MRURemoteAccount";
   remoteAccount  = GetLocalConfigInt(section, key, 0);
   if (remoteAccount <= 0) {
      PlaySound("notify.wav");
      string value = GetLocalConfigString(section, key, "");
      if (!StringLen(value)) MessageBox("Missing remote account setting ["+ section +"]->"+ key                      , __NAME__ +"::init()", MB_ICONSTOP|MB_OK);
      else                   MessageBox("Invalid remote account setting ["+ section +"]->"+ key +" = \""+ value +"\"", __NAME__ +"::init()", MB_ICONSTOP|MB_OK);
      return(SetLastError(ERR_RUNTIME_ERROR));
   }
   section = "Accounts";
   key     = remoteAccount +".company";
   remoteAccountCompany = GetGlobalConfigString(section, key, "");
   if (!StringLen(remoteAccountCompany)) {
      PlaySound("notify.wav");
      MessageBox("Missing account company setting for remote account \""+ remoteAccount +"\"", __NAME__ +"::init()", MB_ICONSTOP|MB_OK);
      return(SetLastError(ERR_RUNTIME_ERROR));
   }

   return(catch("onInit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onStart() {
   // (1) aktuellen Anzeigestatus aus dem Chart auslesen (ON/OFF) und umschalten
   bool status = !LFX.ReadDisplayStatus();


   if (status) {
      // (2.1) Status ON: alle Tickets des Accounts einlesen
      string file    = TerminalPath() +"\\experts\\files\\LiteForex\\remote_positions.ini";
      string section = remoteAccountCompany +"."+ remoteAccount;
      string keys[];
      int keysSize = GetIniKeys(file, section, keys);

      // (2.2) offene Orders finden und anzeigen
      string   symbol="", label="";
      int      ticket, orderType;
      double   units, openEquity, openPrice, stopLoss, takeProfit, closePrice, profit;
      datetime openTime, closeTime, lastUpdate;

      for (int i=0; i < keysSize; i++) {
         if (StringIsDigit(keys[i])) {
            ticket = StrToInteger(keys[i]);
            if (LFX.CurrencyId(ticket) == lfxCurrencyId) {
               int result = LFX.ReadTicket(remoteAccount, ticket, symbol, label, orderType, units, openTime, openEquity, openPrice, stopLoss, takeProfit, closeTime, closePrice, profit, lastUpdate);
               if (result != 1)                                                        // +1, wenn das Ticket erfolgreich gelesen wurden
                  return(last_error);                                                  // -1, wenn das Ticket nicht gefunden wurde
               if (closeTime != 0)                                                     //  0, falls ein Fehler auftrat
                  continue;            // keine offene Order

               openTime   = GMTToServerTime(openTime);
               openPrice += lfxChartDeviation;

               if (!SetOpenOrderMarker(label, orderType, units, openTime, openPrice))
                  break;
            }
         }
      }
   }
   else {
      // (3) Status OFF: alle existierenden Chartobjekte offener Tickets l�schen
      for (i=ObjectsTotal()-1; i >= 0; i--) {
         string name = ObjectName(i);
         if (StringStartsWith(name, "LFX.OpenTicket."))
            ObjectDelete(name);
      }
   }


   // (4) aktuellen Status im Chart speichern
   LFX.SaveDisplayStatus(status);

   return(last_error);
}


/**
 * Zeichnet f�r die angegebenen Daten einen Positions-Marker in den Chart.
 *
 * @param  string   label
 * @param  int      type
 * @param  double   lots
 * @param  datetime openTime
 * @param  double   openPrice
 *
 * @return bool - Erfolgsstatus
 */
bool SetOpenOrderMarker(string label, int type, double lots, datetime openTime, double openPrice) {
   string name = StringConcatenate("LFX.OpenTicket.", label, ".Line");
   if (ObjectFind(name) > -1)
      ObjectDelete(name);

   if (ObjectCreate(name, OBJ_TREND, 0, D'1970.01.01 00:01', openPrice, openTime, openPrice)) {
      ObjectSet(name, OBJPROP_RAY  , false);
      ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(name, OBJPROP_COLOR, ifInt(type==OP_BUY, Green, Red));
      ObjectSet(name, OBJPROP_BACK , false);
      ObjectSetText(name, StringConcatenate(" ", label, ":  ", NumberToStr(lots, ".+"), " x ", NumberToStr(NormalizeDouble(openPrice, SubPipDigits), SubPipPriceFormat)));
   }
   else GetLastError();

   return(!catch("SetOpenOrderMarker()"));
}
