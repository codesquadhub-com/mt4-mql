/**
 * Berechnet die Kurse der momentan verf�gbaren LiteForex-Indizes und zeigt sie an.
 */
#include <stddefine.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];
#include <stdlib.mqh>

#include <core/indicator.mqh>

#property indicator_chart_window


string fontName  = "Tahoma";
int    fontSize  = 10;
color  fontColor = Blue;
color  bgColor   = C'212,208,200';

string symbols[] = { "USD","AUD","CAD","CHF","EUR","GBP","JPY","NZD" };


#define I_USD  0
#define I_AUD  1
#define I_CAD  2
#define I_CHF  3
#define I_EUR  4
#define I_GBP  5
#define I_JPY  6
#define I_NZD  7


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int onInit() {
   CreateLabels();

   // Datenanzeige ausschalten
   SetIndexLabel(0, NULL);
   return(catch("onInit()"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int onDeinit() {
   RemoveChartObjects();
   return(catch("onDeinit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onTick() {
   UpdateInfos();
   return(last_error);
}


/**
 * Erzeugt die Textlabel.
 *
 * @return int - Fehlerstatus
 */
int CreateLabels() {
   int c = 10;                               // Z�hlervariable f�r Label, zweistellig

   // Backgrounds
   c++;
   string label = StringConcatenate(__NAME__, ".", c, ".Background");
   if (ObjectFind(label) == 0)
      ObjectDelete(label);
   if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
      ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
      ObjectSet    (label, OBJPROP_XDISTANCE, 114);
      ObjectSet    (label, OBJPROP_YDISTANCE,  55);
      ObjectSetText(label, "g", 114, "Webdings", bgColor);
      PushObject   (label);
   }
   else GetLastError();

   c++;
   label = StringConcatenate(__NAME__, ".", c, ".Background");
   if (ObjectFind(label) == 0)
      ObjectDelete(label);
   if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
      ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
      ObjectSet    (label, OBJPROP_XDISTANCE, 13);
      ObjectSet    (label, OBJPROP_YDISTANCE, 55);
      ObjectSetText(label, "g", 114, "Webdings", bgColor);
      PushObject   (label);
   }
   else GetLastError();

   // Headerzeile
   int col3width = 110;
   int yCoord    =  58;
   c++;
   label = StringConcatenate(__NAME__, ".", c, ".Header.direct");
   if (ObjectFind(label) == 0)
      ObjectDelete(label);
   if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
      ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
      ObjectSet    (label, OBJPROP_XDISTANCE, 59+col3width);
      ObjectSet    (label, OBJPROP_YDISTANCE, yCoord);
      ObjectSetText(label, "direct", fontSize, fontName, fontColor);
      PushObject   (label);
   }
   else GetLastError();

   c++;
   label = StringConcatenate(__NAME__, ".", c, ".Header.viaUSD");
   if (ObjectFind(label) == 0)
      ObjectDelete(label);
   if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
      ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
      ObjectSet    (label, OBJPROP_XDISTANCE, 59);
      ObjectSet    (label, OBJPROP_YDISTANCE, yCoord);
      ObjectSetText(label, "via USD", fontSize, fontName, fontColor);
      PushObject   (label);
   }
   else GetLastError();

   // Datenzeilen
   yCoord += 16;
   for (int i=0; i < ArraySize(symbols); i++) {
      c++;
      // W�hrung
      label = StringConcatenate(__NAME__, ".", c, ".", symbols[i]);
      if (ObjectFind(label) == 0)
         ObjectDelete(label);
      if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
         ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
         ObjectSet    (label, OBJPROP_XDISTANCE, 119+col3width);
         ObjectSet    (label, OBJPROP_YDISTANCE, yCoord + i*16);
         ObjectSetText(label, symbols[i] +":", fontSize, fontName, fontColor);
         PushObject   (label);
         symbols[i] = label;
      }
      else GetLastError();

      // Index direct
      label = StringConcatenate(symbols[i], ".quote.direct");
      if (ObjectFind(label) == 0)
         ObjectDelete(label);
      if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
         ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
         ObjectSet    (label, OBJPROP_XDISTANCE, 59+col3width);
         ObjectSet    (label, OBJPROP_YDISTANCE, yCoord + i*16);
         ObjectSetText(label, " ");
         PushObject   (label);
      }
      else GetLastError();

      // Spread direct
      label = StringConcatenate(symbols[i], ".spread.direct");
      if (ObjectFind(label) == 0)
         ObjectDelete(label);
      if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
         ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
         ObjectSet    (label, OBJPROP_XDISTANCE, 19+col3width);
         ObjectSet    (label, OBJPROP_YDISTANCE, yCoord + i*16);
         ObjectSetText(label, " ");
         PushObject   (label);
      }
      else GetLastError();

      // Index via USD
      label = StringConcatenate(symbols[i], ".quote.viaUSD");
      if (ObjectFind(label) == 0)
         ObjectDelete(label);
      if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
         ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
         ObjectSet    (label, OBJPROP_XDISTANCE, 59);
         ObjectSet    (label, OBJPROP_YDISTANCE, yCoord + i*16);
         ObjectSetText(label, " ");
         PushObject   (label);
      }
      else GetLastError();

      // Spread via USD
      label = StringConcatenate(symbols[i], ".spread.viaUSD");
      if (ObjectFind(label) == 0)
         ObjectDelete(label);
      if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
         ObjectSet    (label, OBJPROP_CORNER, CORNER_TOP_RIGHT);
         ObjectSet    (label, OBJPROP_XDISTANCE, 19);
         ObjectSet    (label, OBJPROP_YDISTANCE, yCoord + i*16);
         ObjectSetText(label, " ");
         PushObject   (label);
      }
      else GetLastError();
   }

   return(catch("CreateLabels()"));
}


/**
 * Berechnet die Indizes und zeigt sie an.
 *
 * @return int - Fehlerstatus
 */
int UpdateInfos() {
   double usdlfx, usdlfx_Bid, usdlfx_Ask, usdlfx.u, usdlfx_Bid.u, usdlfx_Ask.u;
   double audlfx, audlfx_Bid, audlfx_Ask, audlfx.u, audlfx_Bid.u, audlfx_Ask.u;
   double cadlfx, cadlfx_Bid, cadlfx_Ask, cadlfx.u, cadlfx_Bid.u, cadlfx_Ask.u;
   double chflfx, chflfx_Bid, chflfx_Ask, chflfx.u, chflfx_Bid.u, chflfx_Ask.u;
   double eurlfx, eurlfx_Bid, eurlfx_Ask, eurlfx.u, eurlfx_Bid.u, eurlfx_Ask.u;
   double gbplfx, gbplfx_Bid, gbplfx_Ask, gbplfx.u, gbplfx_Bid.u, gbplfx_Ask.u;
   double jpylfx, jpylfx_Bid, jpylfx_Ask, jpylfx.u, jpylfx_Bid.u, jpylfx_Ask.u;
   double nzdlfx, nzdlfx_Bid, nzdlfx_Ask, nzdlfx.u, nzdlfx_Bid.u, nzdlfx_Ask.u;

   // USDLFX
   double usdcad_Bid = MarketInfo("USDCAD", MODE_BID), usdcad_Ask = MarketInfo("USDCAD", MODE_ASK), usdcad = (usdcad_Bid + usdcad_Ask)/2;
   double usdchf_Bid = MarketInfo("USDCHF", MODE_BID), usdchf_Ask = MarketInfo("USDCHF", MODE_ASK), usdchf = (usdchf_Bid + usdchf_Ask)/2;
   double usdjpy_Bid = MarketInfo("USDJPY", MODE_BID), usdjpy_Ask = MarketInfo("USDJPY", MODE_ASK), usdjpy = (usdjpy_Bid + usdjpy_Ask)/2;
   double audusd_Bid = MarketInfo("AUDUSD", MODE_BID), audusd_Ask = MarketInfo("AUDUSD", MODE_ASK), audusd = (audusd_Bid + audusd_Ask)/2;
   double eurusd_Bid = MarketInfo("EURUSD", MODE_BID), eurusd_Ask = MarketInfo("EURUSD", MODE_ASK), eurusd = (eurusd_Bid + eurusd_Ask)/2;
   double gbpusd_Bid = MarketInfo("GBPUSD", MODE_BID), gbpusd_Ask = MarketInfo("GBPUSD", MODE_ASK), gbpusd = (gbpusd_Bid + gbpusd_Ask)/2;
   bool   usd = (usdcad_Bid!=0 && usdchf_Bid!=0 && usdjpy_Bid!=0 && audusd_Bid!=0 && eurusd_Bid!=0 && gbpusd_Bid!=0);
   if (usd) {
      usdlfx     = MathPow((usdcad     * usdchf     * usdjpy    ) / (audusd     * eurusd     * gbpusd    ), 1/7.);
      usdlfx_Bid = MathPow((usdcad_Bid * usdchf_Bid * usdjpy_Bid) / (audusd_Ask * eurusd_Ask * gbpusd_Ask), 1/7.);
      usdlfx_Ask = MathPow((usdcad_Ask * usdchf_Ask * usdjpy_Ask) / (audusd_Bid * eurusd_Bid * gbpusd_Bid), 1/7.);
   }

   // AUDLFX
   double audcad_Bid = MarketInfo("AUDCAD", MODE_BID), audcad_Ask = MarketInfo("AUDCAD", MODE_ASK), audcad = (audcad_Bid + audcad_Ask)/2;
   double audchf_Bid = MarketInfo("AUDCHF", MODE_BID), audchf_Ask = MarketInfo("AUDCHF", MODE_ASK), audchf = (audchf_Bid + audchf_Ask)/2;
   double audjpy_Bid = MarketInfo("AUDJPY", MODE_BID), audjpy_Ask = MarketInfo("AUDJPY", MODE_ASK), audjpy = (audjpy_Bid + audjpy_Ask)/2;
   //     audusd_Bid = ...
   double euraud_Bid = MarketInfo("EURAUD", MODE_BID), euraud_Ask = MarketInfo("EURAUD", MODE_ASK), euraud = (euraud_Bid + euraud_Ask)/2;
   double gbpaud_Bid = MarketInfo("GBPAUD", MODE_BID), gbpaud_Ask = MarketInfo("GBPAUD", MODE_ASK), gbpaud = (gbpaud_Bid + gbpaud_Ask)/2;
   bool   aud = (audcad_Bid!=0 && audchf_Bid!=0 && audjpy_Bid!=0 && audusd_Bid!=0 && euraud_Bid!=0 && gbpaud_Bid!=0);
   if (aud) {
      audlfx     = MathPow((audcad     * audchf     * audjpy     * audusd    ) / (euraud     * gbpaud    ), 1/7.);
      audlfx_Bid = MathPow((audcad_Bid * audchf_Bid * audjpy_Bid * audusd_Bid) / (euraud_Ask * gbpaud_Ask), 1/7.);
      audlfx_Ask = MathPow((audcad_Ask * audchf_Ask * audjpy_Ask * audusd_Ask) / (euraud_Bid * gbpaud_Bid), 1/7.);
   }
   if (usd) {
      audlfx.u     = usdlfx * audusd;
      audlfx_Bid.u = MathPow((usdcad_Bid * usdchf_Bid * usdjpy_Bid) / (audusd_Bid * eurusd_Ask * gbpusd_Ask), 1/7.) * audusd_Bid;
      audlfx_Ask.u = MathPow((usdcad_Ask * usdchf_Ask * usdjpy_Ask) / (audusd_Ask * eurusd_Bid * gbpusd_Bid), 1/7.) * audusd_Ask;
   }

   // CADLFX
   double cadchf_Bid = MarketInfo("CADCHF", MODE_BID), cadchf_Ask = MarketInfo("CADCHF", MODE_ASK), cadchf = (cadchf_Bid + cadchf_Ask)/2;
   double cadjpy_Bid = MarketInfo("CADJPY", MODE_BID), cadjpy_Ask = MarketInfo("CADJPY", MODE_ASK), cadjpy = (cadjpy_Bid + cadjpy_Ask)/2;
   //     audcad_Bid = ...
   double eurcad_Bid = MarketInfo("EURCAD", MODE_BID), eurcad_Ask = MarketInfo("EURCAD", MODE_ASK), eurcad = (eurcad_Bid + eurcad_Ask)/2;
   double gbpcad_Bid = MarketInfo("GBPCAD", MODE_BID), gbpcad_Ask = MarketInfo("GBPCAD", MODE_ASK), gbpcad = (gbpcad_Bid + gbpcad_Ask)/2;
   //     usdcad_Bid = ...
   bool   cad = (cadchf_Bid!=0 && cadjpy_Bid!=0 && audcad_Bid!=0 && eurcad_Bid!=0 && gbpcad_Bid!=0 && usdcad_Bid!=0);
   if (cad) {
      cadlfx     = MathPow((cadchf     * cadjpy    ) / (audcad     * eurcad     * gbpcad     * usdcad    ), 1/7.);
      cadlfx_Bid = MathPow((cadchf_Bid * cadjpy_Bid) / (audcad_Ask * eurcad_Ask * gbpcad_Ask * usdcad_Ask), 1/7.);
      cadlfx_Ask = MathPow((cadchf_Ask * cadjpy_Ask) / (audcad_Bid * eurcad_Bid * gbpcad_Bid * usdcad_Bid), 1/7.);
   }
   if (usd) {
      cadlfx.u     = usdlfx / usdcad;
      cadlfx_Bid.u = MathPow((usdcad_Ask * usdchf_Bid * usdjpy_Bid) / (audusd_Ask * eurusd_Ask * gbpusd_Ask), 1/7.) / usdcad_Ask;
      cadlfx_Ask.u = MathPow((usdcad_Bid * usdchf_Ask * usdjpy_Ask) / (audusd_Bid * eurusd_Bid * gbpusd_Bid), 1/7.) / usdcad_Bid;
   }

   // CHFLFX
   double chfjpy_Bid = MarketInfo("CHFJPY", MODE_BID), chfjpy_Ask = MarketInfo("CHFJPY", MODE_ASK), chfjpy = (chfjpy_Bid + chfjpy_Ask)/2;
   //     audchf_Bid = ...
   //     cadchf_Bid = ...
   double eurchf_Bid = MarketInfo("EURCHF", MODE_BID), eurchf_Ask = MarketInfo("EURCHF", MODE_ASK), eurchf = (eurchf_Bid + eurchf_Ask)/2;
   double gbpchf_Bid = MarketInfo("GBPCHF", MODE_BID), gbpchf_Ask = MarketInfo("GBPCHF", MODE_ASK), gbpchf = (gbpchf_Bid + gbpchf_Ask)/2;
   //     usdchf_Bid = ...
   bool   chf = (chfjpy_Bid!=0 && audchf_Bid!=0 && cadchf_Bid!=0 && eurchf_Bid!=0 && gbpchf_Bid!=0 && usdchf_Bid!=0);
   if (chf) {
      chflfx     = MathPow(chfjpy     / (audchf     * cadchf     * eurchf     * gbpchf     * usdchf    ), 1/7.);
      chflfx_Bid = MathPow(chfjpy_Bid / (audchf_Ask * cadchf_Ask * eurchf_Ask * gbpchf_Ask * usdchf_Ask), 1/7.);
      chflfx_Ask = MathPow(chfjpy_Ask / (audchf_Bid * cadchf_Bid * eurchf_Bid * gbpchf_Bid * usdchf_Bid), 1/7.);
   }
   if (usd) {
      chflfx.u     = usdlfx / usdchf;
      chflfx_Bid.u = MathPow((usdcad_Bid * usdchf_Ask * usdjpy_Bid) / (audusd_Ask * eurusd_Ask * gbpusd_Ask), 1/7.) / usdchf_Ask;
      chflfx_Ask.u = MathPow((usdcad_Ask * usdchf_Bid * usdjpy_Ask) / (audusd_Bid * eurusd_Bid * gbpusd_Bid), 1/7.) / usdchf_Bid;
   }
   /*
   chfjpy = usdjpy / usdchf
   audchf = audusd * usdchf
   cadchf = usdchf / usdcad
   eurchf = eurusd * usdchf
   gbpchf = gbpusd * usdchf

            |                       chfjpy                        |
   CHFLFX = | --------------------------------------------------- | ^ 1/7
            |     audchf * cadchf * eurchf * gbpchf * usdchf      |


            |                                  (usdjpy/usdchf)                                     |
          = | ------------------------------------------------------------------------------------ | ^ 1/7
            | (audusd * usdchf) * (usdchf/usdcad) * (eurusd * usdchf) * (gbpusd * usdchf) * usdchf |


            |                                         usdjpy                                          |
          = | --------------------------------------------------------------------------------------- | ^ 1/7
            | usdchf * audusd * usdchf * (usdchf/usdcad) * eurusd * usdchf * gbpusd * usdchf * usdchf |


            |    1           usdcad * usdjpy      |
          = | -------- * ------------------------ | ^ 1/7
            | usdchf^6   audusd * eurusd * gbpusd |


            |      usdcad * usdchf * usdjpy       |
          = | ----------------------------------- | ^ 1/7
            | usdchf^7 * audusd * eurusd * gbpusd |


            |     1    |         | usdcad * usdchf * usdjpy |
          = | -------- | ^ 1/7 * | ------------------------ | ^ 1/7
            | usdchf^7 |         | audusd * eurusd * gbpusd |


            | usdcad * usdchf * usdjpy |
          = | ------------------------ | ^ 1/7 / usdchf
            | audusd * eurusd * gbpusd |


          =   USDLFX / usdchf
   */

   // EURLFX
   //     euraud_Bid = ...
   //     eurcad_Bid = ...
   //     eurchf_Bid = ...
   double eurgbp_Bid = MarketInfo("EURGBP", MODE_BID), eurgbp_Ask = MarketInfo("EURGBP", MODE_ASK), eurgbp = (eurgbp_Bid + eurgbp_Ask)/2;
   double eurjpy_Bid = MarketInfo("EURJPY", MODE_BID), eurjpy_Ask = MarketInfo("EURJPY", MODE_ASK), eurjpy = (eurjpy_Bid + eurjpy_Ask)/2;
   //     eurusd_Bid = ...
   bool   eur = (euraud_Bid!=0 && eurcad_Bid!=0 && eurchf_Bid!=0 && eurgbp_Bid!=0 && eurjpy_Bid!=0 && eurusd_Bid!=0);
   if (eur) {
      eurlfx     = MathPow((euraud     * eurcad     * eurchf     * eurgbp     * eurjpy     * eurusd    ), 1/7.);
      eurlfx_Bid = MathPow((euraud_Bid * eurcad_Bid * eurchf_Bid * eurgbp_Bid * eurjpy_Bid * eurusd_Bid), 1/7.);
      eurlfx_Ask = MathPow((euraud_Ask * eurcad_Ask * eurchf_Ask * eurgbp_Ask * eurjpy_Ask * eurusd_Ask), 1/7.);
   }
   if (usd) {
      eurlfx.u     = usdlfx * eurusd;
      eurlfx_Bid.u = MathPow((usdcad_Bid * usdchf_Bid * usdjpy_Bid) / (audusd_Ask * eurusd_Bid * gbpusd_Ask), 1/7.) * eurusd_Bid;
      eurlfx_Ask.u = MathPow((usdcad_Ask * usdchf_Ask * usdjpy_Ask) / (audusd_Bid * eurusd_Ask * gbpusd_Bid), 1/7.) * eurusd_Ask;
   }

   // GBPLFX
   //     gbpaud_Bid = ...
   //     gbpcad_Bid = ...
   //     gbpchf_Bid = ...
   double gbpjpy_Bid = MarketInfo("GBPJPY", MODE_BID), gbpjpy_Ask = MarketInfo("GBPJPY", MODE_ASK), gbpjpy = (gbpjpy_Bid + gbpjpy_Ask)/2;
   //     gbpusd_Bid = ...
   //     eurgbp_Bid = ...
   bool   gbp = (gbpaud_Bid!=0 && gbpcad_Bid!=0 && gbpchf_Bid!=0 && gbpjpy_Bid!=0 && gbpusd_Bid!=0 && eurgbp_Bid!=0);
   if (gbp) {
      gbplfx     = MathPow((gbpaud     * gbpcad     * gbpchf     * gbpjpy     * gbpusd    ) / eurgbp    , 1/7.);
      gbplfx_Bid = MathPow((gbpaud_Bid * gbpcad_Bid * gbpchf_Bid * gbpjpy_Bid * gbpusd_Bid) / eurgbp_Ask, 1/7.);
      gbplfx_Ask = MathPow((gbpaud_Ask * gbpcad_Ask * gbpchf_Ask * gbpjpy_Ask * gbpusd_Ask) / eurgbp_Bid, 1/7.);
   }
   if (usd) {
      gbplfx.u     = usdlfx * gbpusd;
      gbplfx_Bid.u = MathPow((usdcad_Bid * usdchf_Bid * usdjpy_Bid) / (audusd_Ask * eurusd_Ask * gbpusd_Bid), 1/7.) * gbpusd_Bid;
      gbplfx_Ask.u = MathPow((usdcad_Ask * usdchf_Ask * usdjpy_Ask) / (audusd_Bid * eurusd_Bid * gbpusd_Ask), 1/7.) * gbpusd_Ask;
   }

   // JPYLFX
   //     audjpy_Bid = ...
   //     cadjpy_Bid = ...
   //     chfjpy_Bid = ...
   //     eurjpy_Bid = ...
   //     gbpjpy_Bid = ...
   //     usdjpy_Bid = ...
   bool   jpy = (audjpy_Bid!=0 && cadjpy_Bid!=0 && chfjpy_Bid!=0 && eurjpy_Bid!=0 && gbpjpy_Bid!=0 && usdjpy_Bid!=0);
   if (jpy) {
      jpylfx     = MathPow((audjpy     * cadjpy     * chfjpy     * eurjpy     * gbpjpy     * usdjpy    ), 1/7.);
      jpylfx_Bid = MathPow((audjpy_Bid * cadjpy_Bid * chfjpy_Bid * eurjpy_Bid * gbpjpy_Bid * usdjpy_Bid), 1/7.);
      jpylfx_Ask = MathPow((audjpy_Ask * cadjpy_Ask * chfjpy_Ask * eurjpy_Ask * gbpjpy_Ask * usdjpy_Ask), 1/7.);
   }
   if (usd) {
      jpylfx.u     = usdjpy / usdlfx;
      jpylfx_Bid.u = usdjpy_Bid / MathPow((usdcad_Ask * usdchf_Ask * usdjpy_Bid) / (audusd_Bid * eurusd_Bid * gbpusd_Bid), 1/7.);
      jpylfx_Ask.u = usdjpy_Ask / MathPow((usdcad_Bid * usdchf_Bid * usdjpy_Ask) / (audusd_Ask * eurusd_Ask * gbpusd_Ask), 1/7.);
   }

   // NZDLFX
   double audnzd_Bid = MarketInfo("AUDNZD", MODE_BID), audnzd_Ask = MarketInfo("AUDNZD", MODE_ASK), audnzd = (audnzd_Bid + audnzd_Ask)/2;
   double eurnzd_Bid = MarketInfo("EURNZD", MODE_BID), eurnzd_Ask = MarketInfo("EURNZD", MODE_ASK), eurnzd = (eurnzd_Bid + eurnzd_Ask)/2;
   double gbpnzd_Bid = MarketInfo("GBPNZD", MODE_BID), gbpnzd_Ask = MarketInfo("GBPNZD", MODE_ASK), gbpnzd = (gbpnzd_Bid + gbpnzd_Ask)/2;
   double nzdcad_Bid = MarketInfo("NZDCAD", MODE_BID), nzdcad_Ask = MarketInfo("NZDCAD", MODE_ASK), nzdcad = (nzdcad_Bid + nzdcad_Ask)/2;
   double nzdchf_Bid = MarketInfo("NZDCHF", MODE_BID), nzdchf_Ask = MarketInfo("NZDCHF", MODE_ASK), nzdchf = (nzdchf_Bid + nzdchf_Ask)/2;
   double nzdjpy_Bid = MarketInfo("NZDJPY", MODE_BID), nzdjpy_Ask = MarketInfo("NZDJPY", MODE_ASK), nzdjpy = (nzdjpy_Bid + nzdjpy_Ask)/2;
   double nzdusd_Bid = MarketInfo("NZDUSD", MODE_BID), nzdusd_Ask = MarketInfo("NZDUSD", MODE_ASK), nzdusd = (nzdusd_Bid + nzdusd_Ask)/2;
   bool   nzd = (audnzd_Bid!=0 && eurnzd_Bid!=0 && gbpnzd_Bid!=0 && nzdcad_Bid!=0 && nzdchf_Bid!=0 && nzdjpy_Bid!=0 && nzdusd_Bid!=0);
   if (nzd) {
      nzdlfx     = MathPow((nzdcad     * nzdchf     * nzdjpy     * nzdusd    ) / (audnzd     * eurnzd     * gbpnzd    ), 1/7.);
      nzdlfx_Bid = MathPow((nzdcad_Bid * nzdchf_Bid * nzdjpy_Bid * nzdusd_Bid) / (audnzd_Ask * eurnzd_Ask * gbpnzd_Ask), 1/7.);
      nzdlfx_Ask = MathPow((nzdcad_Ask * nzdchf_Ask * nzdjpy_Ask * nzdusd_Ask) / (audnzd_Bid * eurnzd_Bid * gbpnzd_Bid), 1/7.);
   }
   if (usd && nzdusd_Bid!=0) {
      nzdlfx.u     = usdlfx * nzdusd;
      nzdlfx_Bid.u = MathPow((usdcad_Bid * usdchf_Bid * usdjpy_Bid) / (audusd_Ask * eurusd_Ask * gbpusd_Ask), 1/7.) * nzdusd_Bid;
      nzdlfx_Ask.u = MathPow((usdcad_Ask * usdchf_Ask * usdjpy_Ask) / (audusd_Bid * eurusd_Bid * gbpusd_Bid), 1/7.) * nzdusd_Ask;
   }
   /*
   usdcad = nzdcad / nzdusd
   usdchf = nzdchf / nzdusd
   usdjpy = nzdjpy / nzdusd
   audusd = audnzd * nzdusd
   eurusd = eurnzd * nzdusd
   gbpusd = gbpnzd * nzdusd


   NZDLFX =   USDLFX * nzdusd

            | usdcad * usdchf * usdjpy |
          = | ------------------------ | ^ 1/7 * nzdusd
            | audusd * eurusd * gbpusd |


            | usdcad * usdchf * usdjpy |
          = | ------------------------ | ^ 1/7 * (nzdusd^7) ^ 1/7
            | audusd * eurusd * gbpusd |


            | usdcad * usdchf * usdjpy * nzdusd^7 |
          = | ----------------------------------- | ^ 1/7
            |      audusd * eurusd * gbpusd       |


            | (nzdcad/nzdusd) * (nzdchf/nzdusd) * nzdjpy/nzdusd * nzdusd^7 |
          = | ------------------------------------------------------------ | ^ 1/7
            |   (audnzd * nzdusd) * (eurnzd * nzdusd) * (gbpnzd * nzdusd)  |


            | (nzdcad/nzdusd) * (nzdchf/nzdusd) * nzdjpy/nzdusd * nzdusd^7 |
          = | ------------------------------------------------------------ | ^ 1/7
            |              audnzd * eurnzd * gbpnzd * nzdusd^3             |


            | nzdcad   nzdchf   nzdjpy               nzdusd^7                |
          = | ------ * ------ * ------ * ----------------------------------- | ^ 1/7
            | nzdusd   nzdusd   nzdusd   audnzd * eurnzd * gbpnzd * nzdusd^3 |


            | nzdcad * nzdchf * nzdjpy * nzdusd^7 |
          = | ----------------------------------- | ^ 1/7
            | audnzd * eurnzd * gbpnzd * nzdusd^6 |


            | nzdcad * nzdchf * nzdjpy * nzdusd |
          = | --------------------------------- | ^ 1/7
            |      audnzd * eurnzd * gbpnzd     |
   */


   // Fehlerbehandlung
   int error = GetLastError();
   if (error == ERS_HISTORY_UPDATE)                                  // TODO: ERS_HISTORY_UPDATE f�r welches Symbol,Timeframe ???
      return(SetLastError(error));
   if (IsError(error) && error!=ERR_UNKNOWN_SYMBOL)
      return(catch("UpdateInfos(1)", error));


   // Index-Anzeige: direkt
   if (usdlfx       != 0) ObjectSetText(symbols[I_USD] +".quote.direct",               NumberToStr(NormalizeDouble(usdlfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_USD] +".quote.direct",  " ", fontSize, fontName);
   if (audlfx       != 0) ObjectSetText(symbols[I_AUD] +".quote.direct",               NumberToStr(NormalizeDouble(audlfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_AUD] +".quote.direct",  " ", fontSize, fontName);
   if (cadlfx       != 0) ObjectSetText(symbols[I_CAD] +".quote.direct",               NumberToStr(NormalizeDouble(cadlfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CAD] +".quote.direct",  " ", fontSize, fontName);
   if (chflfx       != 0) ObjectSetText(symbols[I_CHF] +".quote.direct",               NumberToStr(NormalizeDouble(chflfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CHF] +".quote.direct",  " ", fontSize, fontName);
   if (eurlfx       != 0) ObjectSetText(symbols[I_EUR] +".quote.direct",               NumberToStr(NormalizeDouble(eurlfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_EUR] +".quote.direct",  " ", fontSize, fontName);
   if (gbplfx       != 0) ObjectSetText(symbols[I_GBP] +".quote.direct",               NumberToStr(NormalizeDouble(gbplfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_GBP] +".quote.direct",  " ", fontSize, fontName);
   if (jpylfx       != 0) ObjectSetText(symbols[I_JPY] +".quote.direct",               NumberToStr(NormalizeDouble(jpylfx, 3), ".2'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_JPY] +".quote.direct",  " ", fontSize, fontName);
   if (nzdlfx       != 0) ObjectSetText(symbols[I_NZD] +".quote.direct",               NumberToStr(NormalizeDouble(nzdlfx, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_NZD] +".quote.direct",  " ", fontSize, fontName);

   // Spread-Anzeige: direkt
   if (usdlfx_Bid   != 0) ObjectSetText(symbols[I_USD] +".spread.direct",     "("+ DoubleToStr((usdlfx_Ask-usdlfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_USD] +".spread.direct", " ", fontSize, fontName);
   if (audlfx_Bid   != 0) ObjectSetText(symbols[I_AUD] +".spread.direct",     "("+ DoubleToStr((audlfx_Ask-audlfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_AUD] +".spread.direct", " ", fontSize, fontName);
   if (cadlfx_Bid   != 0) ObjectSetText(symbols[I_CAD] +".spread.direct",     "("+ DoubleToStr((cadlfx_Ask-cadlfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CAD] +".spread.direct", " ", fontSize, fontName);
   if (chflfx_Bid   != 0) ObjectSetText(symbols[I_CHF] +".spread.direct",     "("+ DoubleToStr((chflfx_Ask-chflfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CHF] +".spread.direct", " ", fontSize, fontName);
   if (eurlfx_Bid   != 0) ObjectSetText(symbols[I_EUR] +".spread.direct",     "("+ DoubleToStr((eurlfx_Ask-eurlfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_EUR] +".spread.direct", " ", fontSize, fontName);
   if (gbplfx_Bid   != 0) ObjectSetText(symbols[I_GBP] +".spread.direct",     "("+ DoubleToStr((gbplfx_Ask-gbplfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_GBP] +".spread.direct", " ", fontSize, fontName);
   if (jpylfx_Bid   != 0) ObjectSetText(symbols[I_JPY] +".spread.direct",     "("+ DoubleToStr((jpylfx_Ask-jpylfx_Bid)*  100, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_JPY] +".spread.direct", " ", fontSize, fontName);
   if (nzdlfx_Bid   != 0) ObjectSetText(symbols[I_NZD] +".spread.direct",     "("+ DoubleToStr((nzdlfx_Ask-nzdlfx_Bid)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_NZD] +".spread.direct", " ", fontSize, fontName);

   // Index-Anzeige: via USDLFX
   if (audlfx.u     != 0) ObjectSetText(symbols[I_AUD] +".quote.viaUSD",             NumberToStr(NormalizeDouble(audlfx.u, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_AUD] +".quote.viaUSD",  " ", fontSize, fontName);
   if (cadlfx.u     != 0) ObjectSetText(symbols[I_CAD] +".quote.viaUSD",             NumberToStr(NormalizeDouble(cadlfx.u, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CAD] +".quote.viaUSD",  " ", fontSize, fontName);
   if (chflfx.u     != 0) ObjectSetText(symbols[I_CHF] +".quote.viaUSD",             NumberToStr(NormalizeDouble(chflfx.u, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CHF] +".quote.viaUSD",  " ", fontSize, fontName);
   if (eurlfx.u     != 0) ObjectSetText(symbols[I_EUR] +".quote.viaUSD",             NumberToStr(NormalizeDouble(eurlfx.u, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_EUR] +".quote.viaUSD",  " ", fontSize, fontName);
   if (gbplfx.u     != 0) ObjectSetText(symbols[I_GBP] +".quote.viaUSD",             NumberToStr(NormalizeDouble(gbplfx.u, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_GBP] +".quote.viaUSD",  " ", fontSize, fontName);
   if (jpylfx.u     != 0) ObjectSetText(symbols[I_JPY] +".quote.viaUSD",             NumberToStr(NormalizeDouble(jpylfx.u, 3), ".2'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_JPY] +".quote.viaUSD",  " ", fontSize, fontName);
   if (nzdlfx.u     != 0) ObjectSetText(symbols[I_NZD] +".quote.viaUSD",             NumberToStr(NormalizeDouble(nzdlfx.u, 5), ".4'"), fontSize, fontName, fontColor); else ObjectSetText(symbols[I_NZD] +".quote.viaUSD",  " ", fontSize, fontName);

   // Spread-Anzeige: via USDLFX
   if (audlfx_Bid.u != 0) ObjectSetText(symbols[I_AUD] +".spread.viaUSD", "("+ DoubleToStr((audlfx_Ask.u-audlfx_Bid.u)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_AUD] +".spread.viaUSD", " ", fontSize, fontName);
   if (cadlfx_Bid.u != 0) ObjectSetText(symbols[I_CAD] +".spread.viaUSD", "("+ DoubleToStr((cadlfx_Ask.u-cadlfx_Bid.u)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CAD] +".spread.viaUSD", " ", fontSize, fontName);
   if (chflfx_Bid.u != 0) ObjectSetText(symbols[I_CHF] +".spread.viaUSD", "("+ DoubleToStr((chflfx_Ask.u-chflfx_Bid.u)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_CHF] +".spread.viaUSD", " ", fontSize, fontName);
   if (eurlfx_Bid.u != 0) ObjectSetText(symbols[I_EUR] +".spread.viaUSD", "("+ DoubleToStr((eurlfx_Ask.u-eurlfx_Bid.u)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_EUR] +".spread.viaUSD", " ", fontSize, fontName);
   if (gbplfx_Bid.u != 0) ObjectSetText(symbols[I_GBP] +".spread.viaUSD", "("+ DoubleToStr((gbplfx_Ask.u-gbplfx_Bid.u)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_GBP] +".spread.viaUSD", " ", fontSize, fontName);
   if (jpylfx_Bid.u != 0) ObjectSetText(symbols[I_JPY] +".spread.viaUSD", "("+ DoubleToStr((jpylfx_Ask.u-jpylfx_Bid.u)*  100, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_JPY] +".spread.viaUSD", " ", fontSize, fontName);
   if (nzdlfx_Bid.u != 0) ObjectSetText(symbols[I_NZD] +".spread.viaUSD", "("+ DoubleToStr((nzdlfx_Ask.u-nzdlfx_Bid.u)*10000, 1) +")", fontSize, fontName, fontColor); else ObjectSetText(symbols[I_NZD] +".spread.viaUSD", " ", fontSize, fontName);

   return(catch("UpdateInfos(2)"));
}
