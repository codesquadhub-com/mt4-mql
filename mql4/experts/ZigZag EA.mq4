/**
 ****************************************************************************************************************************
 *                                           WORK-IN-PROGRESS, DO NOT YET USE                                               *
 ****************************************************************************************************************************
 *
 *
 * A strategy inspired by the "Turtle Trading" system of Richard Dennis.
 *
 *  @see [Turtle Trading] https://analyzingalpha.com/turtle-trading
 *  @see [Turtle Trading] http://web.archive.org/web/20220417032905/https://vantagepointtrading.com/top-trader-richard-dennis-turtle-trading-strategy/
 *
 *
 * Features
 * --------
 *  � A finished test can be loaded into an online chart for trade inspection and further analysis.
 *
 *  � The EA constantly writes a status file with complete runtime data and detailed trade statistics (more detailed than
 *    the tester). This status file can be used to move a running EA instance between different machines (e.g. from laptop
 *    to VPS).
 *
 *  � The EA supports a "virtual trading mode" in which all trades are only emulated. This makes it possible to hide all
 *    trading related deviations that impact test or real results (tester bugs, spread, slippage, swap, commission).
 *    It allows the EA to be tested and adjusted under idealised conditions.
 *
 *  � The EA contains a recorder that can record several performance graphs simultaneously at runtime (also in tester).
 *    These recordings are saved as regular chart symbols in the history directory of a second MT4 terminal. They can be
 *    displayed and analysed like regular MT4 symbols.
 *
 *
 * Requirements
 * ------------
 *  � ZigZag indicator: @see https://github.com/rosasurfer/mt4-mql/blob/master/mql4/indicators/ZigZag.mq4
 *
 *
 * Input parameters
 * ----------------
 *  � EA.Recorder: Metrics to record, for syntax @see https://github.com/rosasurfer/mt4-mql/blob/master/mql4/include/core/expert.recorder.mqh
 *
 *     1: Records real PnL after all costs in account currency (net).
 *     2: Records real PnL after all costs in price units (net).
 *     3: Records synthetic PnL before spread/any costs in price units (signal levels).
 *
 *     4: Records daily real PnL after all costs in account currency (net).                                              TODO
 *     5: Records daily real PnL after all costs in price units (net).                                                   TODO
 *     6: Records daily synthetic PnL before spread/any costs in price units (signal levels).                            TODO
 *
 *     Metrics in price units are recorded in the best matching unit. That's pip for Forex or full points otherwise.
 *
 *
 * External control
 * ----------------
 * The EA can be controlled via execution of the following scripts (online and in tester):
 *
 *  � EA.Start: When a "start" command is received the EA opens a position in direction of the current ZigZag leg. There are
 *              two sub-commands "start:long" and "start:short" to start the EA in a predefined direction. The command has no
 *              effect if the EA already manages an open position.
 *  � EA.Stop:  When a "stop" command is received the EA closes all open positions and stops waiting for trade signals. The
 *              command has no effect if the EA is already in status "stopped".
 *  � EA.Wait:  When a "wait" command is received a stopped EA will wait for new trade signals and start trading. The command
 *              has no effect if the EA is already in status "waiting".
 *  � EA.ToggleMetrics
 *  � Chart.ToggleOpenOrders
 *  � Chart.ToggleTradeHistory
 *
 *
 *
 * TODO:
 *  - add ZigZag projections
 *  - input TradingTimeframe
 *  - fix virtual trading
 *  - on recorder restart the first recorded bar opens at instance.startEquity
 *  - rewrite Test_GetCommission()
 *  - rewrite loglevels to global vars
 *  - document control scripts
 *  - block tests with bar model MODE_BAROPEN
 *
 *  - realtime metric charts
 *     on CreateRawSymbol() also create/update offline profile
 *     ChartInfos: read/display symbol description as long name
 *
 *  - performance (loglevel LOG_WARN)
 *     GBPJPY,M1 2024.01.15-2024.02.02, ZigZag(30), EveryTick:     21.5 sec, 432 trades, 1.737.000 ticks
 *     GBPJPY,M1 2024.01.15-2024.02.02, ZigZag(30), ControlPoints:  3.6 sec, 432 trades,   247.000 ticks
 *
 *     GBPJPY,M5 2024.01.15-2024.02.02, ZigZag(30), EveryTick:     20.4 sec,  93 trades, 1.732.000 ticks
 *     GBPJPY,M5 2024.01.15-2024.02.02, ZigZag(30), ControlPoints:  3.0 sec,  93 trades    243.000 ticks
 *
 *  - time functions
 *     TimeCurrentEx()     check scripts/standalone-indicators in tester/offline charts in old/current terminals
 *     TimeLocalEx()       check scripts/standalone-indicators in tester/offline charts in old/current terminals
 *     TimeFXT()
 *     TimeGMT()           check scripts/standalone-indicators in tester/offline charts in old/current terminals
 *     TimeServer()        check scripts/standalone-indicators in tester/offline charts in old/current terminals
 *
 *     FxtToGmtTime
 *     FxtToLocalTime
 *     FxtToServerTime
 *
 *     GmtToFxtTime
 *     GmtToLocalTime      OK    finish unit tests
 *     GmtToServerTime
 *
 *     LocalToFxtTime
 *     LocalToGmtTime      OK    finish unit tests
 *     LocalToServerTime
 *
 *     ServerToFxtTime
 *     ServerToGmtTime
 *     ServerToLocalTime
 *
 *  - merge Get(Prev|Next)?SessionStartTime()
 *  - merge Get(Prev|Next)?SessionEndTime()
 *
 *  - implement Get(Prev|Next)?Session(Start|End)Time(..., TZ_LOCAL)
 *  - implement (Fxt|Gmt|Server)ToLocalTime() and LocalTo(Fxt|Gmt|Server)Time()
 *
 *  - AverageRange
 *     fix EMPTY_VALUE
 *     integrate required bars in startbar calculation
 *     MTF option for lower TF data on higher TFs (to display more data than a single screen)
 *     one more buffer for current range
 *
 *  - SuperBars
 *     fix gap between days/weeks if market is not open 24h
 *     implement more timeframes
 *     ETH/RTH separation for Frankfurt session
 *
 *  - FATAL  BTCUSD,M5  ChartInfos::ParseDateTimeEx(5)  invalid history configuration in "Today 09:00"  [ERR_INVALID_CONFIG_VALUE]
 *
 *  - stop on reverse signal
 *  - signals MANUAL_LONG|MANUAL_SHORT
 *  - widen SL on manual positions in opposite direction
 *  - manage an existing manual order
 *  - track and display total slippage
 *  - reduce slippage on reversal: Close+Open => Hedge+CloseBy
 *  - reduce slippage on short reversal: enter market via StopSell
 *
 *  - virtual trading
 *     adjust virtual commissions
 *
 *  - trading functionality
 *     support command "wait" in status "progressing"
 *     rewrite and test all @profit() conditions
 *     breakeven stop
 *     trailing stop
 *     reverse trading and command EA.Reverse
 *     support multiple units and targets (add new metrics)
 *
 *  - ChartInfos
 *     CustomPosition() weekend configuration/timespans don't work
 *     CustomPosition() including/excluding a specific strategy is not supported
 *     don't recalculate unitsize on every tick (every few seconds is sufficient)
 *
 *  - performance tracking
 *     notifications for price feed outages
 *     daily metrics
 *
 *  - status display
 *     parameter: ZigZag.Periods
 *
 *  - trade breaks
 *    - full session (24h) with trade breaks
 *    - partial session (e.g. 09:00-16:00) with trade breaks
 *    - trading is disabled but the price feed is active
 *    - configuration:
 *       default: auto-config using the SYMBOL configuration
 *       manual override of times and behaviors (per instance => via input parameters)
 *    - default behaviour:
 *       no trade commands
 *       synchronize-after if an opposite signal occurred
 *    - manual behaviour configuration:
 *       close-before      (default: no)
 *       synchronize-after (default: yes; if no: wait for the next signal)
 *    - better parsing of struct SYMBOL
 *    - config support for session and trade breaks at specific day times
 *
 *  - on exceeding the max. open file limit of the terminal (512)
 *     FATAL  GBPJPY,M5  ZigZag EA::rsfHistory1::HistoryFile1.Open(12)->FileOpen("history/XTrade-Live/zGBPJP_581C30.hst", FILE_READ|FILE_WRITE) => -1 (zGBPJP_581C,M30)  [ERR_CANNOT_OPEN_FILE]
 *     ERROR  GBPJPY,M5  ZigZag EA::rsfHistory1::catch(1)  recursion: SendEmail(8)->FileOpen()  [ERR_CANNOT_OPEN_FILE]
 *            GBPJPY,M5  ZigZag EA::rsfHistory1::SendSMS(8)  SMS sent to +************: "FATAL:  GBPJPY,M5  ZigZag::rsfHistory1::HistoryFile1.Open(12)->FileOpen("history/XTrade-Live/zGBPJP_581C30.hst", FILE_READ|FILE_WRITE) => -1 (zGBPJP_581C,M30)  [ERR_CANNOT_OPEN_FILE] (12:59:52, ICM-DM-EUR)"
 *  - add cache parameter to HistorySet.AddTick(), e.g. 30 sec.
 *  - move all history functionality to the Expander (fixes MQL max. open file limit of program=64/terminal=512)
 *
 *  - improve handling of network outages (price and/or trade connection)
 *  - "no connection" event, no price feed for 5 minutes, signals during this time are not detected => EA out of sync
 *
 *  - handle orders.acceptableSlippage dynamically (via framework config)
 *     https://www.mql5.com/en/forum/120795
 *     https://www.mql5.com/en/forum/289014#comment_9296322
 *     https://www.mql5.com/en/forum/146808#comment_3701979#  [ECN restriction removed since build 500]
 *     https://www.mql5.com/en/forum/146808#comment_3701981#  [Query execution mode in MQL]
 *
 *  - merge inputs TakeProfit and StopConditions
 *  - fix log messages in ValidateInputs (conditionally display the instance name)
 *  - rewrite parameter stepping: remove commands from channel after processing
 *  - rewrite range bar generator
 *  - VPS: monitor and notify of incoming emails
 *  - CLI tools to rename/update/delete symbols
 */
#include <stddefines.mqh>
int   __InitFlags[] = {INIT_PIPVALUE, INIT_BUFFERED_LOG};
int __DeinitFlags[];
int __virtualTicks = 10000;                                 // every 10 seconds to continue operation on a stalled data feed

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern string Instance.ID         = "";                     // instance to load from a status file, format "[T]123"
extern string TradingMode         = "regular* | virtual";   // may be shortened

extern int    ZigZag.Periods      = 30;
extern double Lots                = 1.0;
extern string StartConditions     = "";                     // @time(datetime|time)
extern string StopConditions      = "";                     // @time(datetime|time)    // TODO: @signal([long|short]), @breakeven(on-profit), @trail([on-profit:]stepsize)
extern double TakeProfit          = 0;                      // TP value
extern string TakeProfit.Type     = "off* | money | percent | pip | quote-unit";       // can be shortened if distinct        // TODO: redefine point as index point

extern bool   ShowProfitInPercent = true;                   // whether PL is displayed in money or percentage terms

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/expert.mqh>
#include <stdfunctions.mqh>
#include <rsfLib.mqh>
#include <functions/HandleCommands.mqh>
#include <functions/ParseDateTime.mqh>
#include <functions/iCustom/ZigZag.mqh>
#include <structs/rsf/OrderExecution.mqh>

#define STRATEGY_ID               107              // unique strategy id between 101-1023 (10 bit)

#define INSTANCE_ID_MIN             1              // range of valid instance ids
#define INSTANCE_ID_MAX           999              //

#define STATUS_WAITING              1              // instance status values
#define STATUS_PROGRESSING          2
#define STATUS_STOPPED              3

#define TRADINGMODE_REGULAR         1              // trading modes
#define TRADINGMODE_VIRTUAL         2

#define SIGNAL_TYPE                 0              // signal object fields
#define SIGNAL_DIRECTION            1
#define SIGNAL_VALUE                2

#define SIGTYPE_MANUAL              1              // signal types
#define SIGTYPE_TIME                2
#define SIGTYPE_ZIGZAG              3
#define SIGTYPE_TAKEPROFIT          4

#define SIGDIRECTION_LONG  TRADE_DIRECTION_LONG    // 1 signal directions
#define SIGDIRECTION_SHORT TRADE_DIRECTION_SHORT   // 2

#define TP_TYPE_MONEY               1              // TakeProfit types
#define TP_TYPE_PERCENT             2
#define TP_TYPE_PIP                 3
#define TP_TYPE_PRICEUNIT           4

#define H_TICKET                    0              // trade history indexes
#define H_TYPE                      1
#define H_LOTS                      2
#define H_OPENTIME                  3
#define H_OPENPRICE                 4
#define H_OPENPRICE_SYNTH           5
#define H_CLOSETIME                 6
#define H_CLOSEPRICE                7
#define H_CLOSEPRICE_SYNTH          8
#define H_SLIPPAGE                  9
#define H_SWAP                     10
#define H_COMMISSION               11
#define H_GROSSPROFIT              12
#define H_NETPROFIT                13
#define H_NETPROFIT_P              14
#define H_SYNTHPROFIT_P            15

#define METRIC_TOTAL_NET_MONEY      1              // cumulated PnL metrics
#define METRIC_TOTAL_NET_UNITS      2
#define METRIC_TOTAL_SYNTH_UNITS    3

#define METRIC_DAILY_NET_MONEY      4              // daily PnL metrics
#define METRIC_DAILY_NET_UNITS      5
#define METRIC_DAILY_SYNTH_UNITS    6

#define METRIC_NEXT                 1              // directions for toggling between metrics
#define METRIC_PREVIOUS            -1

#define S_TRADES                    0              // indexes for trade statistics
#define S_TRADES_LONG               1
#define S_TRADES_LONG_PCT           2
#define S_TRADES_SHORT              3
#define S_TRADES_SHORT_PCT          4
#define S_TRADES_SUM                5
#define S_TRADES_AVG                6

#define S_WINNERS                   7
#define S_WINNERS_PCT               8
#define S_WINNERS_LONG              9
#define S_WINNERS_LONG_PCT         10
#define S_WINNERS_SHORT            11
#define S_WINNERS_SHORT_PCT        12
#define S_WINNERS_SUM              13
#define S_WINNERS_AVG              14

#define S_LOSERS                   15
#define S_LOSERS_PCT               16
#define S_LOSERS_LONG              17
#define S_LOSERS_LONG_PCT          18
#define S_LOSERS_SHORT             19
#define S_LOSERS_SHORT_PCT         20
#define S_LOSERS_SUM               21
#define S_LOSERS_AVG               22

#define S_SCRATCH                  23
#define S_SCRATCH_PCT              24
#define S_SCRATCH_LONG             25
#define S_SCRATCH_LONG_PCT         26
#define S_SCRATCH_SHORT            27
#define S_SCRATCH_SHORT_PCT        28
#define S_SCRATCH_SUM              29
#define S_SCRATCH_AVG              30

// general
int      tradingMode;

// instance data
int      instance.id;                              // used for magic order numbers
string   instance.name = "";
datetime instance.created;
bool     instance.isTest;                          // whether the instance is a test
int      instance.status;
double   instance.startEquity;

double   instance.openNetProfit;                   // real PnL after all costs in money (net)
double   instance.closedNetProfit;
double   instance.totalNetProfit;
double   instance.maxNetProfit;                    // max. observed profit:   0...+n
double   instance.maxNetDrawdown;                  // max. observed drawdown: -n...0

double   instance.openNetProfitP;                  // real PnL after all costs in point (net)
double   instance.closedNetProfitP;
double   instance.totalNetProfitP;
double   instance.maxNetProfitP;
double   instance.maxNetDrawdownP;

double   instance.openSynthProfitP;                // synthetic PnL before spread/any costs in point (exact execution)
double   instance.closedSynthProfitP;
double   instance.totalSynthProfitP;
double   instance.maxSynthProfitP;
double   instance.maxSynthDrawdownP;

// order data
int      open.ticket;                              // one open position
int      open.type;
double   open.lots;
datetime open.time;
double   open.price;
double   open.priceSynth;
double   open.slippage;
double   open.swap;
double   open.commission;
double   open.grossProfit;
double   open.netProfit;
double   open.netProfitP;
double   open.synthProfitP;
double   history[][16];                            // multiple closed positions

// trade statistics
double   stats[4][31];

// start conditions
bool     start.time.condition;                     // whether a time condition is active
datetime start.time.value;
bool     start.time.isDaily;
string   start.time.description = "";

// stop conditions ("OR" combined)
bool     stop.time.condition;                      // whether a time condition is active
datetime stop.time.value;
bool     stop.time.isDaily;
string   stop.time.description = "";

bool     stop.profitAbs.condition;                 // whether a takeprofit condition in money is active
double   stop.profitAbs.value;
string   stop.profitAbs.description = "";

bool     stop.profitPct.condition;                 // whether a takeprofit condition in percent is active
double   stop.profitPct.value;
double   stop.profitPct.absValue    = INT_MAX;
string   stop.profitPct.description = "";

bool     stop.profitPun.condition;                 // whether a takeprofit condition in price units is active (pip or full point)
int      stop.profitPun.type;
double   stop.profitPun.value;
string   stop.profitPun.description = "";

// volatile status data
int      status.activeMetric = 1;
bool     status.showOpenOrders;
bool     status.showTradeHistory;

// other
string   pUnit = "";
int      pDigits;
int      pMultiplier;
int      orders.acceptableSlippage = 1;            // in MQL points
string   tradingModeDescriptions[] = {"", "regular", "virtual"};
string   tpTypeDescriptions     [] = {"off", "money", "percent", "pip", "quote currency", "index points"};

// cache vars to speed-up ShowStatus()
string   sTradingModeStatus[] = {"", "", "Virtual "};
string   sStartConditions     = "";
string   sStopConditions      = "";
string   sMetric              = "";
string   sOpenLots            = "";
string   sClosedTrades        = "";
string   sTotalProfit         = "";
string   sProfitStats         = "";

// debug settings, configurable via framework config, see afterInit()
bool     test.onReversalPause     = false;         // whether to pause a test after a ZigZag reversal
bool     test.onSessionBreakPause = false;         // whether to pause a test after StopInstance(SIGNAL_TIME)
bool     test.onStopPause         = false;         // whether to pause a test after a final StopInstance()
bool     test.reduceStatusWrites  = true;          // whether to reduce status file I/O in tester

#include <apps/zigzag-ea/init.mqh>
#include <apps/zigzag-ea/deinit.mqh>


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   if (!instance.status) return(ERR_ILLEGAL_STATE);

   if (__isChart) HandleCommands();                // process incoming commands

   if (instance.status != STATUS_STOPPED) {
      double signal[3];

      if (instance.status == STATUS_WAITING) {
         if (IsStartSignal(signal)) StartInstance(signal);
      }
      else if (instance.status == STATUS_PROGRESSING) {
         if (UpdateStatus()) {
            if      (IsStopSignal(signal))   StopInstance(signal);
            else if (IsZigZagSignal(signal)) ReverseInstance(signal);
         }
      }
      RecordMetrics();
   }
   return(catch("onTick(1)"));
}


/**
 * Process an incoming command.
 *
 * @param  string cmd    - command name
 * @param  string params - command parameters
 * @param  int    keys   - combination of pressed modifier keys
 *
 * @return bool - success status of the executed command
 */
bool onCommand(string cmd, string params, int keys) {
   string fullCmd = cmd +":"+ params +":"+ keys;

   if (cmd == "start") {
      switch (instance.status) {
         case STATUS_WAITING:
         case STATUS_STOPPED:
            double signal[3];
            string sDetail = " ";
            int logLevel = LOG_INFO;

            signal[SIGNAL_TYPE ] = SIGTYPE_MANUAL;
            signal[SIGNAL_VALUE] = NULL;
            if      (params == "long")  signal[SIGNAL_DIRECTION] = SIGDIRECTION_LONG;
            else if (params == "short") signal[SIGNAL_DIRECTION] = SIGDIRECTION_SHORT;
            else {
               signal[SIGNAL_DIRECTION] = ifInt(GetZigZagTrend(0) > 0, SIGDIRECTION_LONG, SIGDIRECTION_SHORT);
               if (params != "") {
                  sDetail  = " skipping unsupported parameter in command ";
                  logLevel = LOG_NOTICE;
               }
            }
            log("onCommand(1)  "+ instance.name + sDetail + DoubleQuoteStr(fullCmd), NO_ERROR, logLevel);
            return(StartInstance(signal));
      }
   }

   else if (cmd == "stop") {
      switch (instance.status) {
         case STATUS_WAITING:
         case STATUS_PROGRESSING:
            logInfo("onCommand(2)  "+ instance.name +" "+ DoubleQuoteStr(fullCmd));
            double manual[] = {SIGTYPE_MANUAL, 0, 0};
            return(StopInstance(manual));
      }
   }

   else if (cmd == "wait") {
      switch (instance.status) {
         case STATUS_STOPPED:
            logInfo("onCommand(3)  "+ instance.name +" "+ DoubleQuoteStr(fullCmd));
            instance.status = STATUS_WAITING;
            return(SaveStatus());
      }
   }

   else if (cmd == "toggle-metrics") {
      int direction = ifInt(keys & F_VK_SHIFT, METRIC_PREVIOUS, METRIC_NEXT);
      return(ToggleMetrics(direction));
   }

   else if (cmd == "toggle-open-orders") {
      return(ToggleOpenOrders());
   }

   else if (cmd == "toggle-trade-history") {
      return(ToggleTradeHistory());
   }
   else return(!logNotice("onCommand(4)  "+ instance.name +" unsupported command: "+ DoubleQuoteStr(fullCmd)));

   return(!logWarn("onCommand(5)  "+ instance.name +" cannot execute command "+ DoubleQuoteStr(fullCmd) +" in status "+ StatusToStr(instance.status)));
}


/**
 * Toggle EA status between displayed metrics.
 *
 * @param  int direction - METRIC_NEXT|METRIC_PREVIOUS
 *
 * @return bool - success status
 */
bool ToggleMetrics(int direction) {
   if (direction!=METRIC_NEXT && direction!=METRIC_PREVIOUS) return(!catch("ToggleMetrics(1)  "+ instance.name +" invalid parameter direction: "+ direction, ERR_INVALID_PARAMETER));

   bool syntheticMetric = (status.activeMetric==METRIC_TOTAL_SYNTH_UNITS || status.activeMetric==METRIC_DAILY_SYNTH_UNITS);

   status.activeMetric += direction;
   if (status.activeMetric < 1) status.activeMetric = 3;    // valid metrics: 1-3
   if (status.activeMetric > 3) status.activeMetric = 1;
   StoreVolatileData();
   SS.All();

   syntheticMetric = (syntheticMetric || status.activeMetric==METRIC_TOTAL_SYNTH_UNITS || status.activeMetric==METRIC_DAILY_SYNTH_UNITS);

   if (syntheticMetric) {
      if (status.showOpenOrders) {
         ToggleOpenOrders(false);
         ToggleOpenOrders(false);
      }
      if (status.showTradeHistory) {
         ToggleTradeHistory(false);
         ToggleTradeHistory(false);
      }
   }
   return(!catch("ToggleMetrics(2)"));
}


/**
 * Toggle the display of open orders.
 *
 * @param  bool soundOnNone [optional] - whether to play a sound if no open orders exist (default: yes)
 *
 * @return bool - success status
 */
bool ToggleOpenOrders(bool soundOnNone = true) {
   soundOnNone = soundOnNone!=0;

   // toggle current status
   bool showOrders = !status.showOpenOrders;

   // ON: display open orders
   if (showOrders) {
      string types[] = {"buy", "sell"};
      color clrs[] = {CLR_OPEN_LONG, CLR_OPEN_SHORT};

      if (open.ticket != NULL) {
         double openPrice = ifDouble(status.activeMetric == METRIC_TOTAL_SYNTH_UNITS, open.priceSynth, open.price);
         string label = StringConcatenate("#", open.ticket, " ", types[open.type], " ", NumberToStr(open.lots, ".+"), " at ", NumberToStr(openPrice, PriceFormat));

         if (ObjectFind(label) == -1) if (!ObjectCreate(label, OBJ_ARROW, 0, 0, 0)) return(!catch("ToggleOpenOrders(1)", intOr(GetLastError(), ERR_RUNTIME_ERROR)));
         ObjectSet    (label, OBJPROP_ARROWCODE, SYMBOL_ORDEROPEN);
         ObjectSet    (label, OBJPROP_COLOR,  clrs[open.type]);
         ObjectSet    (label, OBJPROP_TIME1,  open.time);
         ObjectSet    (label, OBJPROP_PRICE1, openPrice);
         ObjectSetText(label, instance.name);
      }
      else {
         showOrders = false;                          // Without open orders status must be reset to have the "off" section
         if (soundOnNone) PlaySoundEx("Plonk.wav");   // remove any existing open order markers.
      }
   }

   // OFF: remove open order markers
   if (!showOrders) {
      for (int i=ObjectsTotal()-1; i >= 0; i--) {
         label = ObjectName(i);

         if (StringGetChar(label, 0) == '#') {
            if (ObjectType(label) == OBJ_ARROW) {
               int arrow = ObjectGet(label, OBJPROP_ARROWCODE);
               color clr = ObjectGet(label, OBJPROP_COLOR);

               if (arrow == SYMBOL_ORDEROPEN) {
                  if (clr!=CLR_OPEN_LONG && clr!=CLR_OPEN_SHORT) continue;
               }
               else if (arrow == SYMBOL_ORDERCLOSE) {
                  if (clr!=CLR_OPEN_TAKEPROFIT && clr!=CLR_OPEN_STOPLOSS) continue;
               }
               ObjectDelete(label);
            }
         }
      }
   }

   // store current status
   status.showOpenOrders = showOrders;
   StoreVolatileData();

   if (__isTesting) WindowRedraw();
   return(!catch("ToggleOpenOrders(2)"));
}


/**
 * Toggle the display of closed trades.
 *
 * @param  bool soundOnNone [optional] - whether to play a sound if no closed trades exist (default: yes)
 *
 * @return bool - success status
 */
bool ToggleTradeHistory(bool soundOnNone = true) {
   soundOnNone = soundOnNone!=0;

   // toggle current status
   bool showHistory = !status.showTradeHistory;

   // ON: display closed trades
   if (showHistory) {
      int trades = ShowTradeHistory();
      if (trades == -1) return(false);
      if (!trades) {                                        // Without any closed trades the status must be reset to enable
         showHistory = false;                               // the "off" section to clear existing markers.
         if (soundOnNone) PlaySoundEx("Plonk.wav");
      }
   }

   // OFF: remove all closed trade markers (from this EA or another program)
   if (!showHistory) {
      for (int i=ObjectsTotal()-1; i >= 0; i--) {
         string name = ObjectName(i);

         if (StringGetChar(name, 0) == '#') {
            if (ObjectType(name) == OBJ_ARROW) {
               int arrow = ObjectGet(name, OBJPROP_ARROWCODE);
               color clr = ObjectGet(name, OBJPROP_COLOR);

               if (arrow == SYMBOL_ORDEROPEN) {
                  if (clr!=CLR_CLOSED_LONG && clr!=CLR_CLOSED_SHORT) continue;
               }
               else if (arrow == SYMBOL_ORDERCLOSE) {
                  if (clr!=CLR_CLOSED) continue;
               }
            }
            else if (ObjectType(name) != OBJ_TREND) continue;
            ObjectDelete(name);
         }
      }
   }

   // store current status
   status.showTradeHistory = showHistory;
   StoreVolatileData();

   if (__isTesting) WindowRedraw();
   return(!catch("ToggleTradeHistory(1)"));
}


/**
 * Display closed trades.
 *
 * @return int - number of displayed trades or EMPTY (-1) in case of errors
 */
int ShowTradeHistory() {
   string openLabel="", lineLabel="", closeLabel="", sOpenPrice="", sClosePrice="", sOperations[]={"buy", "sell"};
   int iOpenColors[]={CLR_CLOSED_LONG, CLR_CLOSED_SHORT}, iLineColors[]={Blue, Red};

   // process the local trade history
   int orders = ArrayRange(history, 0), closedTrades = 0;

   for (int i=0; i < orders; i++) {
      int      ticket     = history[i][H_TICKET    ];
      int      type       = history[i][H_TYPE      ];
      double   lots       = history[i][H_LOTS      ];
      datetime openTime   = history[i][H_OPENTIME  ];
      double   openPrice  = history[i][H_OPENPRICE ];
      datetime closeTime  = history[i][H_CLOSETIME ];
      double   closePrice = history[i][H_CLOSEPRICE];

      if (status.activeMetric == METRIC_TOTAL_SYNTH_UNITS) {
         openPrice  = history[i][H_OPENPRICE_SYNTH ];
         closePrice = history[i][H_CLOSEPRICE_SYNTH];
      }
      if (!closeTime)                    continue;             // skip open tickets (should not happen)
      if (type!=OP_BUY && type!=OP_SELL) continue;             // skip non-trades   (should not happen)

      sOpenPrice  = NumberToStr(openPrice, PriceFormat);
      sClosePrice = NumberToStr(closePrice, PriceFormat);

      // open marker
      openLabel = StringConcatenate("#", ticket, " ", sOperations[type], " ", NumberToStr(lots, ".+"), " at ", sOpenPrice);
      if (ObjectFind(openLabel) == -1) ObjectCreate(openLabel, OBJ_ARROW, 0, 0, 0);
      ObjectSet    (openLabel, OBJPROP_ARROWCODE, SYMBOL_ORDEROPEN);
      ObjectSet    (openLabel, OBJPROP_COLOR,  iOpenColors[type]);
      ObjectSet    (openLabel, OBJPROP_TIME1,  openTime);
      ObjectSet    (openLabel, OBJPROP_PRICE1, openPrice);
      ObjectSetText(openLabel, instance.name);

      // trend line
      lineLabel = StringConcatenate("#", ticket, " ", sOpenPrice, " -> ", sClosePrice);
      if (ObjectFind(lineLabel) == -1) ObjectCreate(lineLabel, OBJ_TREND, 0, 0, 0, 0, 0);
      ObjectSet(lineLabel, OBJPROP_RAY,    false);
      ObjectSet(lineLabel, OBJPROP_STYLE,  STYLE_DOT);
      ObjectSet(lineLabel, OBJPROP_COLOR,  iLineColors[type]);
      ObjectSet(lineLabel, OBJPROP_BACK,   true);
      ObjectSet(lineLabel, OBJPROP_TIME1,  openTime);
      ObjectSet(lineLabel, OBJPROP_PRICE1, openPrice);
      ObjectSet(lineLabel, OBJPROP_TIME2,  closeTime);
      ObjectSet(lineLabel, OBJPROP_PRICE2, closePrice);

      // close marker
      closeLabel = StringConcatenate(openLabel, " close at ", sClosePrice);
      if (ObjectFind(closeLabel) == -1) ObjectCreate(closeLabel, OBJ_ARROW, 0, 0, 0);
      ObjectSet    (closeLabel, OBJPROP_ARROWCODE, SYMBOL_ORDERCLOSE);
      ObjectSet    (closeLabel, OBJPROP_COLOR,  CLR_CLOSED);
      ObjectSet    (closeLabel, OBJPROP_TIME1,  closeTime);
      ObjectSet    (closeLabel, OBJPROP_PRICE1, closePrice);
      ObjectSetText(closeLabel, instance.name);
      closedTrades++;
   }

   if (!catch("ShowTradeHistory(1)"))
      return(closedTrades);
   return(EMPTY);
}


/**
 * Whether a new ZigZag reversal occurred.
 *
 * @param  _Out_ double &signal[] - array receiving signal details
 *
 * @return bool
 */
bool IsZigZagSignal(double &signal[]) {
   if (last_error != NULL) return(false);

   static int lastTick, lastType, lastDirection, lastSigBar, lastSigDirection;
   static double lastValue, reversalPrice;
   int trend, reversalOffset;

   if (Ticks == lastTick) {
      signal[SIGNAL_TYPE     ] = lastType;
      signal[SIGNAL_DIRECTION] = lastDirection;
      signal[SIGNAL_VALUE    ] = lastValue;
   }
   else {
      signal[SIGNAL_TYPE] = NULL;

      if (!GetZigZagData(0, trend, reversalOffset, reversalPrice)) return(!logError("IsZigZagSignal(1)  "+ instance.name +" GetZigZagData(0) => FALSE", ERR_RUNTIME_ERROR));
      int absTrend = MathAbs(trend);
      bool isReversal = false;
      if      (absTrend == reversalOffset)     isReversal = true;             // regular reversal
      else if (absTrend==1 && !reversalOffset) isReversal = true;             // reversal after double crossing

      if (isReversal) {
         if (trend > 0) int direction = SIGDIRECTION_LONG;
         else               direction = SIGDIRECTION_SHORT;

         if (Time[0]!=lastSigBar || direction!=lastSigDirection) {
            signal[SIGNAL_TYPE     ] = SIGTYPE_ZIGZAG;
            signal[SIGNAL_DIRECTION] = direction;
            signal[SIGNAL_VALUE    ] = reversalPrice;

            if (IsLogNotice()) logNotice("IsZigZagSignal(2)  "+ instance.name +" "+ ifString(direction==SIGDIRECTION_LONG, "long", "short") +" reversal at "+ NumberToStr(reversalPrice, PriceFormat) +" (market: "+ NumberToStr(Bid, PriceFormat) +"/"+ NumberToStr(Ask, PriceFormat) +")");
            lastSigBar       = Time[0];
            lastSigDirection = direction;

            if (IsVisualMode()) {
               if (test.onReversalPause) Tester.Pause("IsZigZagSignal(3)");   // pause the tester according to the debug configuration
            }
         }
      }
      lastTick      = Ticks;
      lastType      = signal[SIGNAL_TYPE     ];
      lastDirection = signal[SIGNAL_DIRECTION];
      lastValue     = signal[SIGNAL_VALUE    ];
   }
   return(signal[SIGNAL_TYPE] != NULL);
}


/**
 * Get ZigZag buffer values at the specified bar offset. The returned values correspond to the documented indicator buffers.
 *
 * @param  _In_  int    bar             - bar offset
 * @param  _Out_ int    &trend          - MODE_TREND: combined buffers MODE_KNOWN_TREND + MODE_UNKNOWN_TREND
 * @param  _Out_ int    &reversalOffset - MODE_REVERSAL: bar offset of most recent ZigZag reversal to previous ZigZag semaphore
 * @param  _Out_ double &reversalPrice  - MODE_(UPPER|LOWER)_CROSS: reversal price if the bar denotes a ZigZag reversal; otherwise 0
 *
 * @return bool - success status
 */
bool GetZigZagData(int bar, int &trend, int &reversalOffset, double &reversalPrice) {
   trend          = MathRound(icZigZag(NULL, ZigZag.Periods, ZigZag.MODE_TREND,    bar));
   reversalOffset = MathRound(icZigZag(NULL, ZigZag.Periods, ZigZag.MODE_REVERSAL, bar));

   if (trend > 0) reversalPrice = icZigZag(NULL, ZigZag.Periods, ZigZag.MODE_UPPER_CROSS, bar);
   else           reversalPrice = icZigZag(NULL, ZigZag.Periods, ZigZag.MODE_LOWER_CROSS, bar);
   return(!last_error && trend);
}


/**
 * Get the length of the ZigZag trend at the specified bar offset.
 *
 * @param  int bar - bar offset
 *
 * @return int - trend length or NULL (0) in case of errors
 */
int GetZigZagTrend(int bar) {
   int trend, iNull;
   double dNull;
   if (!GetZigZagData(bar, trend, iNull, dNull)) return(NULL);
   return(trend % 100000);
}


#define MODE_TRADESERVER   1
#define MODE_STRATEGY      2


/**
 * Whether the current time is outside of the specified trading time range.
 *
 * @param  _In_    int      tradingFrom    - daily trading start time offset in seconds
 * @param  _In_    int      tradingTo      - daily trading stop time offset in seconds
 * @param  _InOut_ datetime &stopTime      - last stop time preceeding 'nextStartTime'
 * @param  _InOut_ datetime &nextStartTime - next start time in the future
 * @param  _In_    int      mode           - one of MODE_TRADESERVER | MODE_STRATEGY
 *
 * @return bool
 */
bool IsTradingBreak(int tradingFrom, int tradingTo, datetime &stopTime, datetime &nextStartTime, int mode) {
   if (mode!=MODE_TRADESERVER && mode!=MODE_STRATEGY) return(!catch("IsTradingBreak(1)  "+ instance.name +" invalid parameter mode: "+ mode, ERR_INVALID_PARAMETER));
   datetime srvNow = TimeServer();

   // check whether to recalculate start/stop times
   if (srvNow >= nextStartTime) {
      int startOffset = tradingFrom % DAYS;
      int stopOffset  = tradingTo % DAYS;

      // calculate today's theoretical start time in SRV and FXT
      datetime srvMidnight  = srvNow - srvNow % DAYS;                // today's Midnight in SRV
      datetime srvStartTime = srvMidnight + startOffset;             // today's theoretical start time in SRV
      datetime fxtNow       = ServerToFxtTime(srvNow);
      datetime fxtMidnight  = fxtNow - fxtNow % DAYS;                // today's Midnight in FXT
      datetime fxtStartTime = fxtMidnight + startOffset;             // today's theoretical start time in FXT

      // determine the next real start time in SRV
      bool skipWeekend = (Symbol() != "BTCUSD");                     // BTCUSD trades at weekends           // TODO: make configurable
      int dow = TimeDayOfWeekEx(fxtStartTime);
      bool isWeekend = (dow==SATURDAY || dow==SUNDAY);

      while (srvStartTime <= srvNow || (isWeekend && skipWeekend)) {
         srvStartTime += 1*DAY;
         fxtStartTime += 1*DAY;
         dow = TimeDayOfWeekEx(fxtStartTime);
         isWeekend = (dow==SATURDAY || dow==SUNDAY);
      }
      nextStartTime = srvStartTime;

      // determine the preceeding stop time
      srvMidnight          = srvStartTime - srvStartTime % DAYS;     // the start day's Midnight in SRV
      datetime srvStopTime = srvMidnight + stopOffset;               // the start day's theoretical stop time in SRV
      fxtMidnight          = fxtStartTime - fxtStartTime % DAYS;     // the start day's Midnight in FXT
      datetime fxtStopTime = fxtMidnight + stopOffset;               // the start day's theoretical stop time in FXT

      dow = TimeDayOfWeekEx(fxtStopTime);
      isWeekend = (dow==SATURDAY || dow==SUNDAY);

      while (srvStopTime > srvStartTime || (isWeekend && skipWeekend) || (dow==MONDAY && fxtStopTime==fxtMidnight)) {
         srvStopTime -= 1*DAY;
         fxtStopTime -= 1*DAY;
         dow = TimeDayOfWeekEx(fxtStopTime);
         isWeekend = (dow==SATURDAY || dow==SUNDAY);                 // BTCUSD trades at weekends           // TODO: make configurable
      }
      stopTime = srvStopTime;

      if (IsLogDebug()) logDebug("IsTradingBreak(2)  "+ instance.name +" recalculated "+ ifString(srvNow >= stopTime, "current", "next") + ifString(mode==MODE_TRADESERVER, " trade session", " strategy") +" stop \""+ TimeToStr(startOffset, TIME_MINUTES) +"-"+ TimeToStr(stopOffset, TIME_MINUTES) +"\" as "+ GmtTimeFormat(stopTime, "%a, %Y.%m.%d %H:%M:%S") +" to "+ GmtTimeFormat(nextStartTime, "%a, %Y.%m.%d %H:%M:%S"));
   }

   // perform the actual check
   return(srvNow >= stopTime);                                       // nextStartTime is in the future of stopTime
}


datetime tradeSession.startOffset = D'1970.01.01 00:05:00';
datetime tradeSession.stopOffset  = D'1970.01.01 23:55:00';
datetime tradeSession.startTime;
datetime tradeSession.stopTime;


/**
 * Whether the current time is outside of the broker's trade session.
 *
 * @return bool
 */
bool IsTradeSessionBreak() {
   return(IsTradingBreak(tradeSession.startOffset, tradeSession.stopOffset, tradeSession.stopTime, tradeSession.startTime, MODE_TRADESERVER));
}


datetime strategy.startTime;
datetime strategy.stopTime;


/**
 * Whether the current time is outside of the strategy's trading times.
 *
 * @return bool
 */
bool IsStrategyBreak() {
   return(IsTradingBreak(start.time.value, stop.time.value, strategy.stopTime, strategy.startTime, MODE_STRATEGY));
}


// start/stop time variants:
// +------+----------+----------+---------------------------------------------+----------------------+--------------------------------------------------+
// | case | startime | stoptime | behavior                                    | validation           | adjustment                                       |
// +------+----------+----------+---------------------------------------------+----------------------+--------------------------------------------------+
// |  1   | -        | -        | immediate start, never stop                 |                      |                                                  |
// |  2   | fix      | -        | defined start, never stop                   |                      | after start disable starttime condition          |
// |  3   | -        | fix      | immediate start, defined stop               |                      | after stop disable stoptime condition            |
// |  4   | fix      | fix      | defined start, defined stop                 | starttime < stoptime | after start/stop disable corresponding condition |
// +------+----------+----------+---------------------------------------------+----------------------+--------------------------------------------------+
// |  5   | daily    | -        | next start, never stop                      |                      | after start disable starttime condition          |
// |  6   | -        | daily    | immediate start, next stop after start      |                      |                                                  |
// |  7   | daily    | daily    | immediate|next start, next stop after start |                      |                                                  |
// +------+----------+----------+---------------------------------------------+----------------------+--------------------------------------------------+
// |  8   | fix      | daily    | defined start, next stop after start        |                      | after start disable starttime condition          |
// |  9   | daily    | fix      | next start if before stop, defined stop     |                      | after stop disable stoptime condition            |
// +------+----------+----------+---------------------------------------------+----------------------+--------------------------------------------------+


/**
 * Whether the expert is able and allowed to trade at the current time.
 *
 * @return bool
 */
bool IsTradingTime() {
   if (IsTradeSessionBreak()) return(false);

   if (!start.time.condition && !stop.time.condition) {     // case 1
      return(!catch("IsTradingTime(1)  "+ instance.name +" start.time=(empty) + stop.time=(empty) not implemented", ERR_NOT_IMPLEMENTED));
   }
   else if (!stop.time.condition) {                         // case 2 or 5
      return(!catch("IsTradingTime(2)  "+ instance.name +" stop.time=(empty) not implemented", ERR_NOT_IMPLEMENTED));
   }
   else if (!start.time.condition) {                        // case 3 or 6
      return(!catch("IsTradingTime(3)  "+ instance.name +" start.time=(empty) not implemented", ERR_NOT_IMPLEMENTED));
   }
   else if (!start.time.isDaily && !stop.time.isDaily) {    // case 4
      return(!catch("IsTradingTime(4)  "+ instance.name +" start.time=(fix) + stop.time=(fix) not implemented", ERR_NOT_IMPLEMENTED));
   }
   else if (start.time.isDaily && stop.time.isDaily) {      // case 7
      if (IsStrategyBreak()) return(false);
   }
   else if (stop.time.isDaily) {                            // case 8
      return(!catch("IsTradingTime(5)  "+ instance.name +" start.time=(fix) + stop.time=(daily) not implemented", ERR_NOT_IMPLEMENTED));
   }
   else {                                                   // case 9
      return(!catch("IsTradingTime(6)  "+ instance.name +" start.time=(daily) + stop.time=(fix) not implemented", ERR_NOT_IMPLEMENTED));
   }
   return(true);
}


/**
 * Whether a start condition is triggered.
 *
 * @param  _Out_ double &signal[] - array receiving signal infos of a triggered condition
 *
 * @return bool
 */
bool IsStartSignal(double &signal[]) {
   if (last_error || instance.status!=STATUS_WAITING) return(false);
   signal[SIGNAL_TYPE] = NULL;

   // start.time ------------------------------------------------------------------------------------------------------------
   if (!IsTradingTime()) {
      return(false);
   }

   // ZigZag signal ---------------------------------------------------------------------------------------------------------
   if (IsZigZagSignal(signal)) {
      return(true);
   }
   return(false);
}


/**
 * Whether a stop condition is triggered.
 *
 * @param  _Out_ double &signal[] - array receiving the stop signal infos (if any)
 *
 * @return bool
 */
bool IsStopSignal(double &signal[]) {
   signal[SIGNAL_TYPE] = NULL;
   if (last_error || (instance.status!=STATUS_WAITING && instance.status!=STATUS_PROGRESSING)) return(false);

   if (instance.status == STATUS_PROGRESSING) {
      // stop.profitAbs -----------------------------------------------------------------------------------------------------
      if (stop.profitAbs.condition) {
         if (instance.totalNetProfit >= stop.profitAbs.value) {
            signal[SIGNAL_TYPE     ] = SIGTYPE_TAKEPROFIT;
            signal[SIGNAL_DIRECTION] = NULL;
            signal[SIGNAL_VALUE    ] = stop.profitAbs.value;
            if (IsLogNotice()) logNotice("IsStopSignal(1)  "+ instance.name +" stop condition \"@"+ stop.profitAbs.description +"\" triggered (market: "+ NumberToStr(Bid, PriceFormat) +"/"+ NumberToStr(Ask, PriceFormat) +")");
            return(true);
         }
      }

      // stop.profitPct -----------------------------------------------------------------------------------------------------
      if (stop.profitPct.condition) {
         if (stop.profitPct.absValue == INT_MAX)
            stop.profitPct.absValue = stop.profitPct.AbsValue();

         if (instance.totalNetProfit >= stop.profitPct.absValue) {
            signal[SIGNAL_TYPE     ] = SIGTYPE_TAKEPROFIT;
            signal[SIGNAL_DIRECTION] = NULL;
            signal[SIGNAL_VALUE    ] = stop.profitPct.value;
            if (IsLogNotice()) logNotice("IsStopSignal(2)  "+ instance.name +" stop condition \"@"+ stop.profitPct.description +"\" triggered (market: "+ NumberToStr(Bid, PriceFormat) +"/"+ NumberToStr(Ask, PriceFormat) +")");
            return(true);
         }
      }

      // stop.profitPun -----------------------------------------------------------------------------------------------------
      if (stop.profitPun.condition) {
         if (instance.totalNetProfitP >= stop.profitPun.value) {
            signal[SIGNAL_TYPE     ] = SIGTYPE_TAKEPROFIT;
            signal[SIGNAL_DIRECTION] = NULL;
            signal[SIGNAL_VALUE    ] = stop.profitPun.value;
            if (IsLogNotice()) logNotice("IsStopSignal(3)  "+ instance.name +" stop condition \"@"+ stop.profitPun.description +"\" triggered (market: "+ NumberToStr(Bid, PriceFormat) +"/"+ NumberToStr(Ask, PriceFormat) +")");
            return(true);
         }
      }
   }

   // stop.time -------------------------------------------------------------------------------------------------------------
   if (stop.time.condition) {
      if (!IsTradingTime()) {
         signal[SIGNAL_TYPE     ] = SIGTYPE_TIME;
         signal[SIGNAL_DIRECTION] = NULL;
         signal[SIGNAL_VALUE    ] = NULL;
         if (IsLogNotice()) logNotice("IsStopSignal(4)  "+ instance.name +" stop condition \"@"+ stop.time.description +"\" triggered (market: "+ NumberToStr(Bid, PriceFormat) +"/"+ NumberToStr(Ask, PriceFormat) +")");
         return(true);
      }
   }
   return(false);
}


/**
 * Start a waiting or restart a stopped instance.
 *
 * @param  double signal[] - signal infos causing the call
 *
 * @return bool - success status
 */
bool StartInstance(double signal[]) {
   if (last_error != NULL)                                                 return(false);
   if (instance.status!=STATUS_WAITING && instance.status!=STATUS_STOPPED) return(!catch("StartInstance(1)  "+ instance.name +" cannot start "+ StatusDescription(instance.status) +" instance", ERR_ILLEGAL_STATE));
   if (!signal[SIGNAL_DIRECTION])                                          return(!catch("StartInstance(2)  "+ instance.name +" invalid parameter SIGNAL_DIRECTION: "+ _int(signal[SIGNAL_DIRECTION]), ERR_INVALID_PARAMETER));

   int sigType      = signal[SIGNAL_TYPE];
   int sigDirection = signal[SIGNAL_DIRECTION];
   double sigValue  = signal[SIGNAL_VALUE];

   instance.status = STATUS_PROGRESSING;
   if (!instance.startEquity) instance.startEquity = NormalizeDouble(AccountEquity() - AccountCredit() + GetExternalAssets(), 2);

   // open a new position
   int      type        = ifInt(sigDirection==SIGDIRECTION_LONG, OP_BUY, OP_SELL);
   double   price       = NULL;
   datetime expires     = NULL;
   string   comment     = "ZigZag."+ StrPadLeft(instance.id, 3, "0");
   int      magicNumber = CalculateMagicNumber();
   color    marker      = ifInt(!type, CLR_OPEN_LONG, CLR_OPEN_SHORT);

   int ticket, oeFlags, oe[];
   if (tradingMode == TRADINGMODE_VIRTUAL) ticket = VirtualOrderSend(type, Lots, NULL, NULL, marker, oe);
   else                                    ticket = OrderSendEx(Symbol(), type, Lots, price, orders.acceptableSlippage, NULL, NULL, comment, magicNumber, expires, marker, oeFlags, oe);
   if (!ticket) return(!SetLastError(oe.Error(oe)));

   // store the position data
   open.ticket       = ticket;
   open.type         = type;
   open.lots         = oe.Lots(oe); SS.OpenLots();
   open.time         = oe.OpenTime(oe);
   open.price        = oe.OpenPrice(oe);
   open.priceSynth   = sigValue;
   open.slippage     = oe.Slippage(oe);
   open.swap         = oe.Swap(oe);
   open.commission   = oe.Commission(oe);
   open.grossProfit  = oe.Profit(oe);
   open.netProfit    = open.grossProfit + open.swap + open.commission;
   open.netProfitP   = ifDouble(type==OP_BUY, Bid-open.price, open.price-Ask) + (open.swap + open.commission)/PointValue(open.lots);
   open.synthProfitP = ifDouble(type==OP_BUY, Bid-open.priceSynth, open.priceSynth-Bid);

   // update PL numbers
   instance.openNetProfit  = open.netProfit;
   instance.totalNetProfit = instance.openNetProfit + instance.closedNetProfit;
   instance.maxNetProfit   = MathMax(instance.maxNetProfit,   instance.totalNetProfit);
   instance.maxNetDrawdown = MathMin(instance.maxNetDrawdown, instance.totalNetProfit);

   instance.openNetProfitP  = open.netProfitP;
   instance.totalNetProfitP = instance.openNetProfitP + instance.closedNetProfitP;
   instance.maxNetProfitP   = MathMax(instance.maxNetProfitP,   instance.totalNetProfitP);
   instance.maxNetDrawdownP = MathMin(instance.maxNetDrawdownP, instance.totalNetProfitP);

   instance.openSynthProfitP  = open.synthProfitP;
   instance.totalSynthProfitP = instance.openSynthProfitP + instance.closedSynthProfitP;
   instance.maxSynthProfitP   = MathMax(instance.maxSynthProfitP,   instance.totalSynthProfitP);
   instance.maxSynthDrawdownP = MathMin(instance.maxSynthDrawdownP, instance.totalSynthProfitP);
   SS.TotalProfit();
   SS.ProfitStats();

   // update start conditions
   if (start.time.condition) {
      if (!start.time.isDaily || !stop.time.condition) {                   // see start/stop time variants
         start.time.condition = false;
      }
   }
   SS.StartStopConditions();

   if (IsLogInfo()) logInfo("StartInstance(3)  "+ instance.name +" instance started ("+ SignalDirectionToStr(sigDirection) +")");
   return(SaveStatus());
}


/**
 * Reverse a progressing instance.
 *
 * @param  double signal[] - signal infos causing the call
 *
 * @return bool - success status
 */
bool ReverseInstance(double signal[]) {
   if (last_error != NULL)                    return(false);
   if (instance.status != STATUS_PROGRESSING) return(!catch("ReverseInstance(1)  "+ instance.name +" cannot reverse "+ StatusDescription(instance.status) +" instance", ERR_ILLEGAL_STATE));
   if (!signal[SIGNAL_DIRECTION])             return(!catch("ReverseInstance(2)  "+ instance.name +" invalid parameter SIGNAL_DIRECTION: "+ _int(signal[SIGNAL_DIRECTION]), ERR_INVALID_PARAMETER));
   int ticket, oeFlags, oe[];

   int sigType      = signal[SIGNAL_TYPE];
   int sigDirection = signal[SIGNAL_DIRECTION];
   double sigValue  = signal[SIGNAL_VALUE];

   if (open.ticket > 0) {
      // continue with an already reversed position
      if ((open.type==OP_BUY && sigDirection==SIGDIRECTION_LONG) || (open.type==OP_SELL && sigDirection==SIGDIRECTION_SHORT)) {
         return(_true(logWarn("ReverseInstance(3)  "+ instance.name +" to "+ ifString(sigDirection==SIGDIRECTION_LONG, "long", "short") +": continuing with already open "+ ifString(tradingMode==TRADINGMODE_VIRTUAL, "virtual ", "") + ifString(sigDirection==SIGDIRECTION_LONG, "long", "short") +" position #"+ open.ticket)));
      }

      // close the existing position
      bool success;
      if (tradingMode == TRADINGMODE_VIRTUAL) success = VirtualOrderClose(open.ticket, open.lots, CLR_NONE, oe);
      else                                    success = OrderCloseEx(open.ticket, NULL, orders.acceptableSlippage, CLR_NONE, oeFlags, oe);
      if (!success) return(!SetLastError(oe.Error(oe)));

      open.slippage   += oe.Slippage(oe);
      open.swap        = oe.Swap(oe);
      open.commission  = oe.Commission(oe);
      open.grossProfit = oe.Profit(oe);
      open.netProfit   = open.grossProfit + open.swap + open.commission;
      open.netProfitP  = ifDouble(open.type==OP_BUY, oe.ClosePrice(oe)-open.price, open.price-oe.ClosePrice(oe)) + (open.swap + open.commission)/PointValue(oe.Lots(oe));
      if (!MoveCurrentPositionToHistory(oe.CloseTime(oe), oe.ClosePrice(oe), sigValue)) return(false);
   }

   // open a new position
   int      type        = ifInt(sigDirection==SIGDIRECTION_LONG, OP_BUY, OP_SELL);
   double   price       = NULL;
   datetime expires     = NULL;
   string   comment     = "ZigZag."+ StrPadLeft(instance.id, 3, "0");
   int      magicNumber = CalculateMagicNumber();
   color    marker      = ifInt(type==OP_BUY, CLR_OPEN_LONG, CLR_OPEN_SHORT);

   if (tradingMode == TRADINGMODE_VIRTUAL) ticket = VirtualOrderSend(type, Lots, NULL, NULL, marker, oe);
   else                                    ticket = OrderSendEx(Symbol(), type, Lots, price, orders.acceptableSlippage, NULL, NULL, comment, magicNumber, expires, marker, oeFlags, oe);
   if (!ticket) return(!SetLastError(oe.Error(oe)));

   // store the new position data
   open.ticket       = ticket;
   open.type         = type;
   open.lots         = oe.Lots(oe); SS.OpenLots();
   open.time         = oe.OpenTime(oe);
   open.price        = oe.OpenPrice(oe);
   open.priceSynth   = sigValue;
   open.slippage     = oe.Slippage(oe);
   open.swap         = oe.Swap(oe);
   open.commission   = oe.Commission(oe);
   open.grossProfit  = oe.Profit(oe);
   open.netProfit    = open.grossProfit + open.swap + open.commission;
   open.netProfitP   = ifDouble(type==OP_BUY, Bid-open.price, open.price-Ask) + (open.swap + open.commission)/PointValue(open.lots);
   open.synthProfitP = ifDouble(type==OP_BUY, Bid-open.priceSynth, open.priceSynth-Bid);

   // update PL numbers
   instance.openNetProfit  = open.netProfit;
   instance.totalNetProfit = instance.openNetProfit + instance.closedNetProfit;
   instance.maxNetProfit   = MathMax(instance.maxNetProfit,   instance.totalNetProfit);
   instance.maxNetDrawdown = MathMin(instance.maxNetDrawdown, instance.totalNetProfit);

   instance.openNetProfitP  = open.netProfitP;
   instance.totalNetProfitP = instance.openNetProfitP + instance.closedNetProfitP;
   instance.maxNetProfitP   = MathMax(instance.maxNetProfitP,   instance.totalNetProfitP);
   instance.maxNetDrawdownP = MathMin(instance.maxNetDrawdownP, instance.totalNetProfitP);

   instance.openSynthProfitP  = open.synthProfitP;
   instance.totalSynthProfitP = instance.openSynthProfitP + instance.closedSynthProfitP;
   instance.maxSynthProfitP   = MathMax(instance.maxSynthProfitP,   instance.totalSynthProfitP);
   instance.maxSynthDrawdownP = MathMin(instance.maxSynthDrawdownP, instance.totalSynthProfitP);
   SS.TotalProfit();
   SS.ProfitStats();

   if (IsLogInfo()) logInfo("ReverseInstance(4)  "+ instance.name +" instance reversed ("+ SignalDirectionToStr(sigDirection) +")");
   return(SaveStatus());
}


/**
 * Return the absolute value of a percentage type TakeProfit condition.
 *
 * @return double - absolute value or INT_MAX if no percentage TakeProfit was configured
 */
double stop.profitPct.AbsValue() {
   if (stop.profitPct.condition) {
      if (stop.profitPct.absValue == INT_MAX) {
         double startEquity = instance.startEquity;
         if (!startEquity) startEquity = AccountEquity() - AccountCredit() + GetExternalAssets();
         return(stop.profitPct.value/100 * startEquity);
      }
   }
   return(stop.profitPct.absValue);
}


/**
 * Stop a waiting or progressing instance and close open positions (if any).
 *
 * @param  double signal[] - signal which triggered the stop condition
 *
 * @return bool - success status
 */
bool StopInstance(double signal[]) {
   if (last_error != NULL)                                                     return(false);
   if (instance.status!=STATUS_WAITING && instance.status!=STATUS_PROGRESSING) return(!catch("StopInstance(1)  "+ instance.name +" cannot stop "+ StatusDescription(instance.status) +" instance", ERR_ILLEGAL_STATE));

   int sigType      = signal[SIGNAL_TYPE];
   int sigDirection = signal[SIGNAL_DIRECTION];
   double sigValue  = signal[SIGNAL_VALUE];

   // close an open position
   if (instance.status == STATUS_PROGRESSING) {
      if (open.ticket > 0) {
         bool success;
         int oeFlags, oe[];
         if (tradingMode == TRADINGMODE_VIRTUAL) success = VirtualOrderClose(open.ticket, open.lots, CLR_NONE, oe);
         else                                    success = OrderCloseEx(open.ticket, NULL, orders.acceptableSlippage, CLR_NONE, oeFlags, oe);
         if (!success) return(!SetLastError(oe.Error(oe)));

         open.slippage   += oe.Slippage(oe);
         open.swap        = oe.Swap(oe);
         open.commission  = oe.Commission(oe);
         open.grossProfit = oe.Profit(oe);
         open.netProfit   = open.grossProfit + open.swap + open.commission;
         open.netProfitP  = ifDouble(open.type==OP_BUY, oe.ClosePrice(oe)-open.price, open.price-oe.ClosePrice(oe)) + (open.swap + open.commission)/PointValue(oe.Lots(oe));
         if (!MoveCurrentPositionToHistory(oe.CloseTime(oe), oe.ClosePrice(oe), Bid)) return(false);

         instance.openNetProfit  = open.netProfit;
         instance.totalNetProfit = instance.openNetProfit + instance.closedNetProfit;
         instance.maxNetProfit   = MathMax(instance.maxNetProfit,   instance.totalNetProfit);
         instance.maxNetDrawdown = MathMin(instance.maxNetDrawdown, instance.totalNetProfit);

         instance.openNetProfitP  = open.netProfitP;
         instance.totalNetProfitP = instance.openNetProfitP + instance.closedNetProfitP;
         instance.maxNetProfitP   = MathMax(instance.maxNetProfitP,   instance.totalNetProfitP);
         instance.maxNetDrawdownP = MathMin(instance.maxNetDrawdownP, instance.totalNetProfitP);

         instance.openSynthProfitP  = open.synthProfitP;
         instance.totalSynthProfitP = instance.openSynthProfitP + instance.closedSynthProfitP;
         instance.maxSynthProfitP   = MathMax(instance.maxSynthProfitP,   instance.totalSynthProfitP);
         instance.maxSynthDrawdownP = MathMin(instance.maxSynthDrawdownP, instance.totalSynthProfitP);
      }
   }

   // update stop conditions and status
   switch (sigType) {
      case SIGTYPE_TIME:
         if (!stop.time.isDaily) {
            stop.time.condition = false;                    // see start/stop time variants
         }
         instance.status = ifInt(start.time.condition && start.time.isDaily, STATUS_WAITING, STATUS_STOPPED);
         break;

      case SIGTYPE_TAKEPROFIT:
         stop.profitAbs.condition = false;
         stop.profitPct.condition = false;
         stop.profitPun.condition = false;
         instance.status          = STATUS_STOPPED;
         break;

      case SIGTYPE_MANUAL:                                  // explicit stop (manual) or end of test
         instance.status = STATUS_STOPPED;
         break;

      default: return(!catch("StopInstance(2)  "+ instance.name +" invalid parameter SIGNAL_TYPE: "+ sigType, ERR_INVALID_PARAMETER));
   }
   SS.StartStopConditions();
   SS.TotalProfit();
   SS.ProfitStats();

   if (IsLogInfo()) logInfo("StopInstance(3)  "+ instance.name +" "+ ifString(__isTesting && sigType==SIGTYPE_MANUAL, "test ", "") +"instance stopped"+ ifString(sigType==SIGTYPE_MANUAL, "", " ("+ SignalTypeToStr(sigType) +")") +", profit: "+ sTotalProfit +" "+ sProfitStats);
   SaveStatus();

   // pause/stop the tester according to the debug configuration
   if (__isTesting) {
      if      (!IsVisualMode())         { if (instance.status == STATUS_STOPPED) Tester.Stop ("StopInstance(4)"); }
      else if (sigType == SIGTYPE_TIME) { if (test.onSessionBreakPause)          Tester.Pause("StopInstance(5)"); }
      else                              { if (test.onStopPause)                  Tester.Pause("StopInstance(6)"); }
   }
   return(!catch("StopInstance(7)"));
}


/**
 * Update order status and PL.
 *
 * @return bool - success status
 */
bool UpdateStatus() {
   if (last_error != NULL)                    return(false);
   if (instance.status != STATUS_PROGRESSING) return(!catch("UpdateStatus(1)  "+ instance.name +" cannot update order status of "+ StatusDescription(instance.status) +" instance", ERR_ILLEGAL_STATE));
   if (!open.ticket)                          return(true);

   if (tradingMode == TRADINGMODE_VIRTUAL) {
      open.swap         = 0;
      open.commission   = 0;
      open.netProfitP   = ifDouble(open.type==OP_BUY, Bid-open.price, open.price-Ask);
      open.netProfit    = open.netProfitP * PointValue(open.lots);
      open.grossProfit  = open.netProfit;
      open.synthProfitP = ifDouble(open.type==OP_BUY, Bid-open.priceSynth, open.priceSynth-Bid);
   }
   else {
      if (!SelectTicket(open.ticket, "UpdateStatus(2)")) return(false);
      open.swap         = NormalizeDouble(OrderSwap(), 2);
      open.commission   = OrderCommission();
      open.grossProfit  = OrderProfit();
      open.netProfit    = open.grossProfit + open.swap + open.commission;
      open.netProfitP   = ifDouble(open.type==OP_BUY, Bid-open.price, open.price-Ask); if (open.swap!=0 || open.commission!=0) open.netProfitP += (open.swap + open.commission)/PointValue(OrderLots());
      open.synthProfitP = ifDouble(open.type==OP_BUY, Bid-open.priceSynth, open.priceSynth-Bid);

      if (OrderCloseTime() != NULL) {
         int error;
         if (IsError(onPositionClose("UpdateStatus(3)  "+ instance.name +" "+ UpdateStatus.PositionCloseMsg(error), error))) return(false);
         if (!MoveCurrentPositionToHistory(OrderCloseTime(), OrderClosePrice(), OrderClosePrice()))                          return(false);
      }
   }

   instance.openNetProfit    = open.netProfit;
   instance.openNetProfitP   = open.netProfitP;
   instance.openSynthProfitP = open.synthProfitP;

   instance.totalNetProfit    = instance.openNetProfit    + instance.closedNetProfit;
   instance.totalNetProfitP   = instance.openNetProfitP   + instance.closedNetProfitP;
   instance.totalSynthProfitP = instance.openSynthProfitP + instance.closedSynthProfitP;
   if (__isChart) SS.TotalProfit();

   instance.maxNetProfit      = MathMax(instance.maxNetProfit,      instance.totalNetProfit);
   instance.maxNetDrawdown    = MathMin(instance.maxNetDrawdown,    instance.totalNetProfit);
   instance.maxNetProfitP     = MathMax(instance.maxNetProfitP,     instance.totalNetProfitP);
   instance.maxNetDrawdownP   = MathMin(instance.maxNetDrawdownP,   instance.totalNetProfitP);
   instance.maxSynthProfitP   = MathMax(instance.maxSynthProfitP,   instance.totalSynthProfitP);
   instance.maxSynthDrawdownP = MathMin(instance.maxSynthDrawdownP, instance.totalSynthProfitP);
   if (__isChart) SS.ProfitStats();

   return(!catch("UpdateStatus(4)"));
}


/**
 * Compose a log message for a closed position. The ticket must be selected.
 *
 * @param  _Out_ int error - error code to be returned from the call (if any)
 *
 * @return string - log message or an empty string in case of errors
 */
string UpdateStatus.PositionCloseMsg(int &error) {
   // #1 Sell 0.1 GBPUSD at 1.5457'2 ("Z.869") was [unexpectedly ]closed at 1.5457'2 (market: Bid/Ask[, so: 47.7%/169.20/354.40])
   error = NO_ERROR;

   int    ticket     = OrderTicket();
   int    type       = OrderType();
   double lots       = OrderLots();
   double openPrice  = OrderOpenPrice();
   double closePrice = OrderClosePrice();

   string sType       = OperationTypeDescription(type);
   string sOpenPrice  = NumberToStr(openPrice, PriceFormat);
   string sClosePrice = NumberToStr(closePrice, PriceFormat);
   string sUnexpected = ifString(__CoreFunction==CF_INIT || (__CoreFunction==CF_DEINIT && __isTesting), "", "unexpectedly ");
   string message     = "#"+ ticket +" "+ sType +" "+ NumberToStr(lots, ".+") +" "+ OrderSymbol() +" at "+ sOpenPrice +" (\""+ instance.name +"\") was "+ sUnexpected +"closed at "+ sClosePrice;

   string sStopout = "";
   if (StrStartsWithI(OrderComment(), "so:")) {       error = ERR_MARGIN_STOPOUT; sStopout = ", "+ OrderComment(); }
   else if (__CoreFunction==CF_INIT)                  error = NO_ERROR;
   else if (__CoreFunction==CF_DEINIT && __isTesting) error = NO_ERROR;
   else                                               error = ERR_CONCURRENT_MODIFICATION;

   return(message +" (market: "+ NumberToStr(Bid, PriceFormat) +"/"+ NumberToStr(Ask, PriceFormat) + sStopout +")");
}


/**
 * Event handler for an unexpectedly closed position.
 *
 * @param  string message - error message
 * @param  int    error   - error code
 *
 * @return int - error status, i.e. whether to interrupt program execution
 */
int onPositionClose(string message, int error) {
   if (!error) return(logInfo(message));                    // no error

   if (error == ERR_ORDER_CHANGED)                          // expected in a fast market: a SL was triggered
      return(!logNotice(message, error));                   // continue

   if (__isTesting) return(catch(message, error));          // in tester treat everything else as terminating

   logWarn(message, error);                                 // online
   if (error == ERR_CONCURRENT_MODIFICATION)                // unexpected: most probably manually closed
      return(NO_ERROR);                                     // continue
   return(error);
}


/**
 * Move the current open position to the trade history. Assumes the position is closed.
 *
 * @param datetime closeTime       - close time
 * @param double   closePrice      - close price
 * @param double   closePriceSynth - synthetic close price
 *
 * @return bool - success status
 */
bool MoveCurrentPositionToHistory(datetime closeTime, double closePrice, double closePriceSynth) {
   if (last_error != NULL)                    return(false);
   if (instance.status != STATUS_PROGRESSING) return(!catch("MoveCurrentPositionToHistory(1)  "+ instance.name +" cannot process current position of "+ StatusDescription(instance.status) +" instance", ERR_ILLEGAL_STATE));
   if (!open.ticket)                          return(!catch("MoveCurrentPositionToHistory(2)  "+ instance.name +" no open position found (open.ticket=NULL)", ERR_ILLEGAL_STATE));

   // update position data
   open.synthProfitP = ifDouble(open.type==OP_BUY, closePriceSynth-open.priceSynth, open.priceSynth-closePriceSynth);

   // add data to history
   int i = ArrayRange(history, 0);
   ArrayResize(history, i+1);
   history[i][H_TICKET          ] = open.ticket;
   history[i][H_TYPE            ] = open.type;
   history[i][H_LOTS            ] = open.lots;
   history[i][H_OPENTIME        ] = open.time;
   history[i][H_OPENPRICE       ] = open.price;
   history[i][H_OPENPRICE_SYNTH ] = open.priceSynth;
   history[i][H_CLOSETIME       ] = closeTime;
   history[i][H_CLOSEPRICE      ] = closePrice;
   history[i][H_CLOSEPRICE_SYNTH] = closePriceSynth;
   history[i][H_SLIPPAGE        ] = open.slippage;
   history[i][H_SWAP            ] = open.swap;
   history[i][H_COMMISSION      ] = open.commission;
   history[i][H_GROSSPROFIT     ] = open.grossProfit;
   history[i][H_NETPROFIT       ] = open.netProfit;
   history[i][H_NETPROFIT_P     ] = open.netProfitP;
   history[i][H_SYNTHPROFIT_P   ] = open.synthProfitP;

   // update PL numbers
   instance.openNetProfit    = 0;
   instance.openNetProfitP   = 0;
   instance.openSynthProfitP = 0;

   instance.closedNetProfit    += open.netProfit;
   instance.closedNetProfitP   += open.netProfitP;
   instance.closedSynthProfitP += open.synthProfitP;

   // reset open position data
   open.ticket       = NULL;
   open.type         = NULL;
   open.lots         = NULL;
   open.time         = NULL;
   open.price        = NULL;
   open.priceSynth   = NULL;
   open.slippage     = NULL;
   open.swap         = NULL;
   open.commission   = NULL;
   open.grossProfit  = NULL;
   open.netProfit    = NULL;
   open.netProfitP   = NULL;
   open.synthProfitP = NULL;
   SS.OpenLots();

   // update trade stats
   CalculateTradeStats();
   SS.ClosedTrades();

   return(!catch("MoveCurrentPositionToHistory(3)"));
}


/**
 * Update trade statistics.
 */
void CalculateTradeStats() {
   int trades = ArrayRange(history, 0);
   int prevTrades = stats[0][S_TRADES];

   if (!trades || trades < prevTrades) {
      ArrayInitialize(stats, 0);
      prevTrades = 0;
   }

   if (trades > prevTrades) {
      for (int i=prevTrades; i < trades; i++) {                   // speed-up by processing only new history entries
         // all trades
         if (history[i][H_TYPE] == OP_LONG) {
            stats[METRIC_TOTAL_NET_MONEY  ][S_TRADES_LONG]++;
            stats[METRIC_TOTAL_NET_UNITS  ][S_TRADES_LONG]++;
            stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_LONG]++;
         }
         else {
            stats[METRIC_TOTAL_NET_MONEY  ][S_TRADES_SHORT]++;
            stats[METRIC_TOTAL_NET_UNITS  ][S_TRADES_SHORT]++;
            stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_SHORT]++;
         }
         stats[METRIC_TOTAL_NET_MONEY  ][S_TRADES_SUM] += history[i][H_NETPROFIT    ];
         stats[METRIC_TOTAL_NET_UNITS  ][S_TRADES_SUM] += history[i][H_NETPROFIT_P  ];
         stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_SUM] += history[i][H_SYNTHPROFIT_P];

         // after all costs in punits
         if (GT(history[i][H_NETPROFIT_P], 0.5*Point)) {
            // winners
            stats[METRIC_TOTAL_NET_UNITS][S_WINNERS]++;
            if (history[i][H_TYPE] == OP_LONG) stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_LONG ]++;
            else                               stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_SHORT]++;
            stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_SUM] += history[i][H_NETPROFIT_P];
         }
         else if (LT(history[i][H_NETPROFIT_P], -0.5*Point)) {
            // losers
            stats[METRIC_TOTAL_NET_UNITS][S_LOSERS]++;
            if (history[i][H_TYPE] == OP_LONG) stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_LONG ]++;
            else                               stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_SHORT]++;
            stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_SUM] += history[i][H_NETPROFIT_P];
         }
         else {
            // scratch
            stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH]++;
            if (history[i][H_TYPE] == OP_LONG) stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_LONG ]++;
            else                               stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_SHORT]++;
            stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_SUM] += history[i][H_NETPROFIT_P];
         }

         // before spread/any costs (signal levels)
         if (GT(history[i][H_SYNTHPROFIT_P], 0.5*Point)) {
            // winners
            stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS]++;
            if (history[i][H_TYPE] == OP_LONG) stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_LONG ]++;
            else                               stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_SHORT]++;
            stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_SUM] += history[i][H_SYNTHPROFIT_P];
         }
         else if (LT(history[i][H_SYNTHPROFIT_P], -0.5*Point)) {
            // losers
            stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS]++;
            if (history[i][H_TYPE] == OP_LONG) stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_LONG ]++;
            else                               stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_SHORT]++;
            stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_SUM] += history[i][H_SYNTHPROFIT_P];
         }
         else {
            // scratch
            stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH]++;
            if (history[i][H_TYPE] == OP_LONG) stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_LONG ]++;
            else                               stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_SHORT]++;
            stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_SUM] += history[i][H_SYNTHPROFIT_P];
         }
      }
      stats[METRIC_TOTAL_NET_MONEY  ][S_TRADES_AVG]  = stats[METRIC_TOTAL_NET_MONEY  ][S_TRADES_SUM]/trades;
      stats[METRIC_TOTAL_NET_UNITS  ][S_TRADES_AVG]  = stats[METRIC_TOTAL_NET_UNITS  ][S_TRADES_SUM]/trades;
      stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_AVG]  = stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_SUM]/trades;

      stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_AVG]   = MathDiv(stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_SUM], MathRound(stats[METRIC_TOTAL_NET_UNITS][S_WINNERS]));
      stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_AVG ]   = MathDiv(stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_SUM ], MathRound(stats[METRIC_TOTAL_NET_UNITS][S_LOSERS ]));
      stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_AVG]   = MathDiv(stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_SUM], MathRound(stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH]));

      stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_AVG] = MathDiv(stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_SUM], MathRound(stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS]));
      stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_AVG ] = MathDiv(stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_SUM ], MathRound(stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS ]));
      stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_AVG] = MathDiv(stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_SUM], MathRound(stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH]));

      // new number of total trades and trade percentages
      for (i=ArrayRange(stats, 0)-1; i >= 0; i--) {
         stats[i][S_TRADES] = trades;
         stats[i][S_TRADES] = trades;
         stats[i][S_TRADES] = trades;
         stats[i][S_TRADES] = trades;

         stats[i][S_TRADES_LONG_PCT  ] = MathDiv(stats[i][S_TRADES_LONG  ], stats[i][S_TRADES ]);
         stats[i][S_TRADES_SHORT_PCT ] = MathDiv(stats[i][S_TRADES_SHORT ], stats[i][S_TRADES ]);
         stats[i][S_WINNERS_PCT      ] = MathDiv(stats[i][S_WINNERS      ], stats[i][S_TRADES ]);
         stats[i][S_WINNERS_LONG_PCT ] = MathDiv(stats[i][S_WINNERS_LONG ], stats[i][S_WINNERS]);
         stats[i][S_WINNERS_SHORT_PCT] = MathDiv(stats[i][S_WINNERS_SHORT], stats[i][S_WINNERS]);
         stats[i][S_LOSERS_PCT       ] = MathDiv(stats[i][S_LOSERS       ], stats[i][S_TRADES ]);
         stats[i][S_LOSERS_LONG_PCT  ] = MathDiv(stats[i][S_LOSERS_LONG  ], stats[i][S_LOSERS ]);
         stats[i][S_LOSERS_SHORT_PCT ] = MathDiv(stats[i][S_LOSERS_SHORT ], stats[i][S_LOSERS ]);
         stats[i][S_SCRATCH_PCT      ] = MathDiv(stats[i][S_SCRATCH      ], stats[i][S_TRADES ]);
         stats[i][S_SCRATCH_LONG_PCT ] = MathDiv(stats[i][S_SCRATCH_LONG ], stats[i][S_SCRATCH]);
         stats[i][S_SCRATCH_SHORT_PCT] = MathDiv(stats[i][S_SCRATCH_SHORT], stats[i][S_SCRATCH]);
      }
   }
}


/**
 * Calculate a magic order number for the strategy.
 *
 * @param  int instanceId [optional] - instance to calculate the magic number for (default: the current instance)
 *
 * @return int - magic number or NULL in case of errors
 */
int CalculateMagicNumber(int instanceId = NULL) {
   if (STRATEGY_ID < 101 || STRATEGY_ID > 1023)      return(!catch("CalculateMagicNumber(1)  "+ instance.name +" illegal strategy id: "+ STRATEGY_ID, ERR_ILLEGAL_STATE));
   int id = intOr(instanceId, instance.id);
   if (id < INSTANCE_ID_MIN || id > INSTANCE_ID_MAX) return(!catch("CalculateMagicNumber(2)  "+ instance.name +" illegal instance id: "+ id, ERR_ILLEGAL_STATE));

   int strategy = STRATEGY_ID;                              // 101-1023 (10 bit)
   int instance = id;                                       // 001-999 but was 1000-9999 (14 bit)

   return((strategy<<22) + (instance<<8));                  // the remaining 8 bit are not used in this strategy
}


/**
 * Whether the currently selected ticket belongs to the current strategy and optionally instance.
 *
 * @param  int instanceId [optional] - instance to check the ticket against (default: check for matching strategy only)
 *
 * @return bool
 */
bool IsMyOrder(int instanceId = NULL) {
   if (OrderSymbol() == Symbol()) {
      int strategy = OrderMagicNumber() >> 22;
      if (strategy == STRATEGY_ID) {
         int instance = OrderMagicNumber() >> 8 & 0x3FFF;   // 14 bit starting at bit 8: instance id
         return(!instanceId || instanceId==instance);
      }
   }
   return(false);
}


/**
 * Generate a new instance id. Unique for all instances per symbol (instances of different symbols may use the same id).
 *
 * @return int - instance id in the range of 100-999 or NULL (0) in case of errors
 */
int CreateInstanceId() {
   int instanceId, magicNumber;
   MathSrand(GetTickCount()-__ExecutionContext[EC.hChartWindow]);

   if (__isTesting) {
      // generate next consecutive id from already recorded metrics
      string nextSymbol = Recorder.GetNextMetricSymbol(); if (nextSymbol == "") return(NULL);
      string sCounter = StrRightFrom(nextSymbol, ".", -1);
      if (!StrIsDigits(sCounter)) return(!catch("CreateInstanceId(1)  "+ instance.name +" illegal value for next symbol "+ DoubleQuoteStr(nextSymbol) +" (doesn't end with 3 digits)", ERR_ILLEGAL_STATE));
      int nextMetricId = MathMax(INSTANCE_ID_MIN, StrToInteger(sCounter));

      if (recorder.mode == RECORDER_OFF) {
         int minInstanceId = MathCeil(nextMetricId + 0.2*(INSTANCE_ID_MAX-nextMetricId));    // nextMetricId + 20% of remaining range (leave 20% of range empty for tests with metrics)
         while (instanceId < minInstanceId || instanceId > INSTANCE_ID_MAX) {                // select random id between <minInstanceId> and ID_MAX
            instanceId = MathRand();
         }
      }
      else {
         instanceId = nextMetricId;                                                          // use next metric id
      }
   }
   else {
      // online: generate random id
      while (!magicNumber) {
         // generate a new instance id
         while (instanceId < INSTANCE_ID_MIN || instanceId > INSTANCE_ID_MAX) {
            instanceId = MathRand();                                                         // select random id between ID_MIN and ID_MAX
         }
         magicNumber = CalculateMagicNumber(instanceId); if (!magicNumber) return(NULL);

         // test for uniqueness against open orders
         int openOrders = OrdersTotal();
         for (int i=0; i < openOrders; i++) {
            if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return(!catch("CreateInstanceId(2)  "+ instance.name, intOr(GetLastError(), ERR_RUNTIME_ERROR)));
            if (OrderMagicNumber() == magicNumber) {
               magicNumber = NULL;
               break;
            }
         }
         if (!magicNumber) continue;

         // test for uniqueness against closed orders
         int closedOrders = OrdersHistoryTotal();
         for (i=0; i < closedOrders; i++) {
            if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) return(!catch("CreateInstanceId(3)  "+ instance.name, intOr(GetLastError(), ERR_RUNTIME_ERROR)));
            if (OrderMagicNumber() == magicNumber) {
               magicNumber = NULL;
               break;
            }
         }
      }
   }
   return(instanceId);
}


/**
 * Return a symbol definition for the specified metric to be recorded.
 *
 * @param  _In_  int    id           - metric id; 0 = standard AccountEquity() symbol, positive integer for custom metrics
 * @param  _Out_ bool   &ready       - whether metric details are complete and the metric is ready to be recorded
 * @param  _Out_ string &symbol      - unique MT4 timeseries symbol
 * @param  _Out_ string &description - symbol description as in the MT4 "Symbols" window (if empty a description is generated)
 * @param  _Out_ string &group       - symbol group name as in the MT4 "Symbols" window (if empty a name is generated)
 * @param  _Out_ int    &digits      - symbol digits value
 * @param  _Out_ double &baseValue   - quotes base value (if EMPTY recorder default settings are used)
 * @param  _Out_ int    &multiplier  - quotes multiplier
 *
 * @return int - error status; especially ERR_INVALID_INPUT_PARAMETER if the passed metric id is unknown or not supported
 */
int Recorder_GetSymbolDefinition(int id, bool &ready, string &symbol, string &description, string &group, int &digits, double &baseValue, int &multiplier) {
   string sId = ifString(!instance.id, "???", StrPadLeft(instance.id, 3, "0"));
   string descrSuffix="", sBarModel="";
   switch (__Test.barModel) {
      case MODE_EVERYTICK:     sBarModel = "EveryTick"; break;
      case MODE_CONTROLPOINTS: sBarModel = "ControlP";  break;
      case MODE_BAROPEN:       sBarModel = "BarOpen";   break;
      default:                 sBarModel = "Live";      break;
   }

   ready      = false;
   group      = "";
   baseValue  = EMPTY;
   digits     = pDigits;
   multiplier = pMultiplier;

   switch (id) {
      // --- standard AccountEquity() symbol for recorder.mode = RECORDER_ON ------------------------------------------------
      case NULL:
         symbol      = recorder.stdEquitySymbol;
         description = "";
         digits      = 2;
         multiplier  = 1;
         ready       = true;
         return(NO_ERROR);

      // --- custom cumulated metrcis ---------------------------------------------------------------------------------------
      case METRIC_TOTAL_NET_MONEY:              // OK
         symbol      = StrLeft(Symbol(), 6) +"."+ sId +"A";                      // "US500.123A"
         descrSuffix = ", "+ PeriodDescription() +", "+ sBarModel +", net PnL, "+ AccountCurrency() + LocalTimeFormat(GetGmtTime(), ", %d.%m.%Y %H:%M");
         digits      = 2;
         multiplier  = 1;
         break;

      case METRIC_TOTAL_NET_UNITS:              // OK
         symbol      = StrLeft(Symbol(), 6) +"."+ sId +"B";
         descrSuffix = ", "+ PeriodDescription() +", "+ sBarModel +", net PnL, "+ pUnit + LocalTimeFormat(GetGmtTime(), ", %d.%m.%Y %H:%M");
         break;

      case METRIC_TOTAL_SYNTH_UNITS:            // OK
         symbol      = StrLeft(Symbol(), 6) +"."+ sId +"C";
         descrSuffix = ", "+ PeriodDescription() +", "+ sBarModel +", synth PnL, "+ pUnit + LocalTimeFormat(GetGmtTime(), ", %d.%m.%Y %H:%M");
         break;

      // --- custom daily metrics -------------------------------------------------------------------------------------------
      case METRIC_DAILY_NET_MONEY:
         symbol      = StrLeft(Symbol(), 6) +"."+ sId +"D";
         descrSuffix = ", "+ PeriodDescription() +", "+ sBarModel +", net PnL/day, "+ AccountCurrency() + LocalTimeFormat(GetGmtTime(), ", %d.%m.%Y %H:%M");
         digits      = 2;
         multiplier  = 1;
         break;

      case METRIC_DAILY_NET_UNITS:
         symbol      = StrLeft(Symbol(), 6) +"."+ sId +"E";
         descrSuffix = ", "+ PeriodDescription() +", "+ sBarModel +", net PnL/day, "+ pUnit + LocalTimeFormat(GetGmtTime(), ", %d.%m.%Y %H:%M");
         break;

      case METRIC_DAILY_SYNTH_UNITS:
         symbol      = StrLeft(Symbol(), 6) +"."+ sId +"F";
         descrSuffix = ", "+ PeriodDescription() +", "+ sBarModel +", synth PnL/day, "+ pUnit + LocalTimeFormat(GetGmtTime(), ", %d.%m.%Y %H:%M");
         break;

      default:
         return(ERR_INVALID_INPUT_PARAMETER);
   }

   description = StrLeft(ProgramName(), 63-StringLen(descrSuffix )) + descrSuffix;
   ready = (instance.id > 0);

   return(NO_ERROR);
}


/**
 * Update the recorder with current metric values.
 */
void RecordMetrics() {
   if (recorder.mode == RECORDER_CUSTOM) {
      int size = ArraySize(metric.ready);
      if (size > METRIC_TOTAL_NET_MONEY  ) metric.currValue[METRIC_TOTAL_NET_MONEY  ] = instance.totalNetProfit;
      if (size > METRIC_TOTAL_NET_UNITS  ) metric.currValue[METRIC_TOTAL_NET_UNITS  ] = instance.totalNetProfitP;
      if (size > METRIC_TOTAL_SYNTH_UNITS) metric.currValue[METRIC_TOTAL_SYNTH_UNITS] = instance.totalSynthProfitP;
   }
}


/**
 * Return the full name of the instance logfile.
 *
 * @return string - filename or an empty string in case of errors
 */
string GetLogFilename() {
   string name = GetStatusFilename();
   if (!StringLen(name)) return("");
   return(StrLeftTo(name, ".", -1) +".log");
}


/**
 * Return the name of the status file.
 *
 * @param  bool relative [optional] - whether to return an absolute path or a path relative to the MQL "files" directory
 *                                    (default: absolute path)
 *
 * @return string - filename or an empty string in case of errors
 */
string GetStatusFilename(bool relative = false) {
   relative = relative!=0;
   if (!instance.id)      return(_EMPTY_STR(catch("GetStatusFilename(1)  "+ instance.name +" illegal value of instance.id: 0", ERR_ILLEGAL_STATE)));
   if (!instance.created) return(_EMPTY_STR(catch("GetStatusFilename(2)  "+ instance.name +" illegal value of instance.created: 0", ERR_ILLEGAL_STATE)));

   static string filename = ""; if (!StringLen(filename)) {
      string directory = "presets/"+ ifString(IsTestInstance(), "Tester", GetAccountCompanyId()) +"/";
      string baseName  = ProgramName() +", "+ Symbol() +", "+ GmtTimeFormat(instance.created, "%Y-%m-%d %H.%M") +", id="+ StrPadLeft(instance.id, 3, "0") +".set";
      filename = directory + baseName;
   }

   if (relative)
      return(filename);
   return(GetMqlSandboxPath() +"/"+ filename);
}


/**
 * Find an existing status file for the specified instance.
 *
 * @param  int  instanceId - instance id
 * @param  bool isTest     - whether the instance is a test instance
 *
 * @return string - absolute filename or an empty string in case of errors
 */
string FindStatusFile(int instanceId, bool isTest) {
   if (instanceId < INSTANCE_ID_MIN || instanceId > INSTANCE_ID_MAX) return(_EMPTY_STR(catch("FindStatusFile(1)  "+ instance.name +" invalid parameter instanceId: "+ instanceId, ERR_INVALID_PARAMETER)));
   isTest = isTest!=0;

   string sandboxDir  = GetMqlSandboxPath() +"/";
   string statusDir   = "presets/"+ ifString(isTest, "Tester", GetAccountCompanyId()) +"/";
   string basePattern = ProgramName() +", "+ Symbol() +",*id="+ StrPadLeft(""+ instanceId, 3, "0") +".set";
   string pathPattern = sandboxDir + statusDir + basePattern;

   string result[];
   int size = FindFileNames(pathPattern, result, FF_FILESONLY);

   if (size != 1) {
      if (size > 1) return(_EMPTY_STR(logError("FindStatusFile(2)  "+ instance.name +" multiple matching files found for pattern "+ DoubleQuoteStr(pathPattern), ERR_ILLEGAL_STATE)));
   }
   return(sandboxDir + statusDir + result[0]);
}


/**
 * Return a readable representation of an instance status code.
 *
 * @param  int status
 *
 * @return string
 */
string StatusToStr(int status) {
   switch (status) {
      case NULL              : return("(NULL)"            );
      case STATUS_WAITING    : return("STATUS_WAITING"    );
      case STATUS_PROGRESSING: return("STATUS_PROGRESSING");
      case STATUS_STOPPED    : return("STATUS_STOPPED"    );
   }
   return(_EMPTY_STR(catch("StatusToStr(1)  "+ instance.name +" invalid parameter status: "+ status, ERR_INVALID_PARAMETER)));
}


/**
 * Return a description of an instance status code.
 *
 * @param  int status
 *
 * @return string - description or an empty string in case of errors
 */
string StatusDescription(int status) {
   switch (status) {
      case NULL              : return("(undefined)");
      case STATUS_WAITING    : return("waiting"    );
      case STATUS_PROGRESSING: return("progressing");
      case STATUS_STOPPED    : return("stopped"    );
   }
   return(_EMPTY_STR(catch("StatusDescription(1)  "+ instance.name +" invalid parameter status: "+ status, ERR_INVALID_PARAMETER)));
}


/**
 * Return a readable representation of a signal type constant.
 *
 * @param  int type
 *
 * @return string - readable constant or an empty string in case of errors
 */
string SignalTypeToStr(int type) {
   switch (type) {
      case NULL              : return("no type"           );
      case SIGTYPE_MANUAL    : return("SIGTYPE_MANUAL"    );
      case SIGTYPE_TIME      : return("SIGTYPE_TIME"      );
      case SIGTYPE_ZIGZAG    : return("SIGTYPE_ZIGZAG"    );
      case SIGTYPE_TAKEPROFIT: return("SIGTYPE_TAKEPROFIT");
   }
   return(_EMPTY_STR(catch("SignalTypeToStr(1)  "+ instance.name +" invalid parameter type: "+ type, ERR_INVALID_PARAMETER)));
}


/**
 * Return a readable representation of a signal direction constant.
 *
 * @param  int direction
 *
 * @return string - readable constant or an empty string in case of errors
 */
string SignalDirectionToStr(int direction) {
   switch (direction) {
      case NULL              : return("no direction"      );
      case SIGDIRECTION_LONG : return("SIGDIRECTION_LONG" );
      case SIGDIRECTION_SHORT: return("SIGDIRECTION_SHORT");
   }
   return(_EMPTY_STR(catch("SignalDirectionToStr(1)  "+ instance.name +" invalid parameter direction: "+ direction, ERR_INVALID_PARAMETER)));
}


/**
 * Write the current instance status to a file.
 *
 * @return bool - success status
 */
bool SaveStatus() {
   if (last_error != NULL)               return(false);
   if (!instance.id || Instance.ID=="")  return(!catch("SaveStatus(1)  illegal instance id: "+ instance.id +" (Instance.ID="+ DoubleQuoteStr(Instance.ID) +")", ERR_ILLEGAL_STATE));
   if (__isTesting) {
      if (test.reduceStatusWrites) {                              // in tester skip most writes except file creation, instance stop and test end
         static bool saved = false;
         if (saved && instance.status!=STATUS_STOPPED && __CoreFunction!=CF_DEINIT) return(true);
         saved = true;
      }
   }
   else if (IsTestInstance()) return(true);                       // don't change the status file of a finished test

   string section="", separator="", file=GetStatusFilename();
   if (!IsFile(file, MODE_SYSTEM)) separator = CRLF;              // an empty line separator

   // [General]
   section = "General";
   WriteIniString(file, section, "Account", GetAccountCompanyId() +":"+ GetAccountNumber() +" ("+ ifString(IsDemoFix(), "demo", "real") +")"+ ifString(__isTesting, separator, ""));

   if (!__isTesting) {
      WriteIniString(file, section, "AccountCurrency", AccountCurrency());
      WriteIniString(file, section, "Symbol",          Symbol() + separator);
   }
   else {
      WriteIniString(file, section, "Test.Currency",   AccountCurrency());
      WriteIniString(file, section, "Test.Symbol",     Symbol());
      WriteIniString(file, section, "Test.TimeRange",  TimeToStr(Test.GetStartDate(), TIME_DATE) +"-"+ TimeToStr(Test.GetEndDate()-1*DAY, TIME_DATE));
      WriteIniString(file, section, "Test.Period",     PeriodDescription());
      WriteIniString(file, section, "Test.BarModel",   BarModelDescription(__Test.barModel));
      WriteIniString(file, section, "Test.Spread",     DoubleToStr((Ask-Bid) * pMultiplier, pDigits) +" "+ pUnit);
         double commission  = GetCommission();
         string sCommission = DoubleToStr(commission, 2);
         if (NE(commission, 0)) {
            double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
            double tickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);
            double units     = MathDiv(commission, MathDiv(tickValue, tickSize));
            sCommission = sCommission +" ("+ DoubleToStr(units * pMultiplier, pDigits) +" "+ pUnit +")";
         }
      WriteIniString(file, section, "Test.Commission", sCommission + separator);
   }

   // [Inputs]
   section = "Inputs";
   WriteIniString(file, section, "Instance.ID",                /*string  */ Instance.ID);
   WriteIniString(file, section, "TradingMode",                /*string  */ TradingMode);
   WriteIniString(file, section, "ZigZag.Periods",             /*int     */ ZigZag.Periods);
   WriteIniString(file, section, "Lots",                       /*double  */ NumberToStr(Lots, ".+"));
   WriteIniString(file, section, "StartConditions",            /*string  */ StartConditions);
   WriteIniString(file, section, "StopConditions",             /*string  */ StopConditions);
   WriteIniString(file, section, "TakeProfit",                 /*double  */ NumberToStr(TakeProfit, ".+"));
   WriteIniString(file, section, "TakeProfit.Type",            /*string  */ TakeProfit.Type);
   WriteIniString(file, section, "ShowProfitInPercent",        /*bool    */ ShowProfitInPercent);
   WriteIniString(file, section, "EA.Recorder",                /*string  */ EA.Recorder + separator);

   // [Stats: net in money]
   section = "Stats: net in money";
   WriteIniString(file, section, "openProfit",                 /*double  */ StrPadRight(DoubleToStr(instance.openNetProfit, 2), 21)                        +"; after all costs in "+ AccountCurrency());
   WriteIniString(file, section, "closedProfit",               /*double  */ DoubleToStr(instance.closedNetProfit, 2));
   WriteIniString(file, section, "totalProfit",                /*double  */ DoubleToStr(instance.totalNetProfit, 2));
   WriteIniString(file, section, "minProfit",                  /*double  */ DoubleToStr(instance.maxNetDrawdown, 2));
   WriteIniString(file, section, "maxProfit",                  /*double  */ DoubleToStr(instance.maxNetProfit, 2) + separator);

   // [Stats: net in punits]
   section = "Stats: net in "+ pUnit;
   WriteIniString(file, section, "openProfit",                 /*double  */ StrPadRight(NumberToStr(instance.openNetProfitP * pMultiplier, ".1+"), 21)     +"; after all costs");
   WriteIniString(file, section, "closedProfit",               /*double  */ NumberToStr(instance.closedNetProfitP * pMultiplier, ".1+"));
   WriteIniString(file, section, "totalProfit",                /*double  */ NumberToStr(instance.totalNetProfitP * pMultiplier, ".1+"));
   WriteIniString(file, section, "minProfit",                  /*double  */ NumberToStr(instance.maxNetDrawdownP * pMultiplier, ".1+"));
   WriteIniString(file, section, "maxProfit",                  /*double  */ NumberToStr(instance.maxNetProfitP * pMultiplier, ".1+") + separator);

   WriteIniString(file, section, "trades",                     /*double  */ Round(stats[METRIC_TOTAL_NET_UNITS][S_TRADES]));
   WriteIniString(file, section, "trades.long",                /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_TRADES_LONG]), 9)   + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_TRADES_LONG_PCT  ], 1) +"%)", 8));
   WriteIniString(file, section, "trades.short",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_TRADES_SHORT]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_TRADES_SHORT_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "avgTrade",                   /*double  */ DoubleToStr(stats[METRIC_TOTAL_NET_UNITS][S_TRADES_AVG] * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "winners",                    /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_WINNERS]), 13)      + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_PCT      ], 1) +"%)", 8));
   WriteIniString(file, section, "winners.long",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_LONG]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_LONG_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "winners.short",              /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_SHORT]), 7) + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_SHORT_PCT], 1) +"%)", 8));
   WriteIniString(file, section, "avgWinner",                  /*double  */ DoubleToStr(stats[METRIC_TOTAL_NET_UNITS][S_WINNERS_AVG] * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "losers",                     /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_LOSERS]), 14)       + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_PCT       ], 1) +"%)", 8));
   WriteIniString(file, section, "losers.long",                /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_LONG]), 9)   + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_LONG_PCT  ], 1) +"%)", 8));
   WriteIniString(file, section, "losers.short",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_SHORT]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_SHORT_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "avgLoser",                   /*double  */ DoubleToStr(stats[METRIC_TOTAL_NET_UNITS][S_LOSERS_AVG] * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "scratch",                    /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH]), 13)      + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_PCT      ], 1) +"%)", 8));
   WriteIniString(file, section, "scratch.long",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_LONG]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_LONG_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "scratch.short",              /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_SHORT]), 7) + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_NET_UNITS][S_SCRATCH_SHORT_PCT], 1) +"%)", 8) + separator);

   // [Stats: synthetic in punits]
   section = "Stats: synthetic in "+ pUnit;
   WriteIniString(file, section, "openProfit",                 /*double  */ StrPadRight(DoubleToStr(instance.openSynthProfitP * pMultiplier, pDigits), 21) +"; before spread/any costs (signal levels)");
   WriteIniString(file, section, "closedProfit",               /*double  */ DoubleToStr(instance.closedSynthProfitP * pMultiplier, pDigits));
   WriteIniString(file, section, "totalProfit",                /*double  */ DoubleToStr(instance.totalSynthProfitP * pMultiplier, pDigits));
   WriteIniString(file, section, "minProfit",                  /*double  */ DoubleToStr(instance.maxSynthDrawdownP * pMultiplier, pDigits));
   WriteIniString(file, section, "maxProfit",                  /*double  */ DoubleToStr(instance.maxSynthProfitP * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "trades",                     /*double  */ Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES]));
   WriteIniString(file, section, "trades.long",                /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_LONG]), 9)   + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_LONG_PCT  ], 1) +"%)", 8));
   WriteIniString(file, section, "trades.short",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_SHORT]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_SHORT_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "avgTrade",                   /*double  */ DoubleToStr(stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_AVG] * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "winners",                    /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS]), 13)      + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_PCT      ], 1) +"%)", 8));
   WriteIniString(file, section, "winners.long",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_LONG]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_LONG_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "winners.short",              /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_SHORT]), 7) + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_SHORT_PCT], 1) +"%)", 8));
   WriteIniString(file, section, "avgWinner",                  /*double  */ DoubleToStr(stats[METRIC_TOTAL_SYNTH_UNITS][S_WINNERS_AVG] * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "losers",                     /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS]), 14)       + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_PCT       ], 1) +"%)", 8));
   WriteIniString(file, section, "losers.long",                /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_LONG]), 9)   + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_LONG_PCT  ], 1) +"%)", 8));
   WriteIniString(file, section, "losers.short",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_SHORT]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_SHORT_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "avgLoser",                   /*double  */ DoubleToStr(stats[METRIC_TOTAL_SYNTH_UNITS][S_LOSERS_AVG] * pMultiplier, pDigits) + separator);

   WriteIniString(file, section, "scratch",                    /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH]), 13)      + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_PCT      ], 1) +"%)", 8));
   WriteIniString(file, section, "scratch.long",               /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_LONG]), 8)  + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_LONG_PCT ], 1) +"%)", 8));
   WriteIniString(file, section, "scratch.short",              /*double  */ StrPadRight(Round(stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_SHORT]), 7) + StrPadLeft("("+ DoubleToStr(100 * stats[METRIC_TOTAL_SYNTH_UNITS][S_SCRATCH_SHORT_PCT], 1) +"%)", 8) + separator);

   // [Runtime status]
   section = "Runtime status";
   WriteIniString(file, section, "instance.id",                /*int     */ instance.id);
   WriteIniString(file, section, "instance.name",              /*string  */ instance.name);
   WriteIniString(file, section, "instance.created",           /*datetime*/ instance.created + GmtTimeFormat(instance.created, " (%a, %Y.%m.%d %H:%M:%S)"));
   WriteIniString(file, section, "instance.isTest",            /*bool    */ instance.isTest);
   WriteIniString(file, section, "instance.status",            /*int     */ instance.status +" ("+ StatusDescription(instance.status) +")");
   WriteIniString(file, section, "instance.startEquity",       /*double  */ DoubleToStr(instance.startEquity, 2) + separator);

   WriteIniString(file, section, "tradingMode",                /*int     */ tradingMode);
   WriteIniString(file, section, "recorder.stdEquitySymbol",   /*string  */ recorder.stdEquitySymbol + separator);

   WriteIniString(file, section, "start.time.condition",       /*bool    */ start.time.condition);
   WriteIniString(file, section, "start.time.value",           /*datetime*/ start.time.value);
   WriteIniString(file, section, "start.time.isDaily",         /*bool    */ start.time.isDaily);
   WriteIniString(file, section, "start.time.description",     /*string  */ start.time.description + separator);

   WriteIniString(file, section, "stop.time.condition",        /*bool    */ stop.time.condition);
   WriteIniString(file, section, "stop.time.value",            /*datetime*/ stop.time.value);
   WriteIniString(file, section, "stop.time.isDaily",          /*bool    */ stop.time.isDaily);
   WriteIniString(file, section, "stop.time.description",      /*string  */ stop.time.description + separator);

   WriteIniString(file, section, "stop.profitAbs.condition",   /*bool    */ stop.profitAbs.condition);
   WriteIniString(file, section, "stop.profitAbs.value",       /*double  */ DoubleToStr(stop.profitAbs.value, 2));
   WriteIniString(file, section, "stop.profitAbs.description", /*string  */ stop.profitAbs.description);
   WriteIniString(file, section, "stop.profitPct.condition",   /*bool    */ stop.profitPct.condition);
   WriteIniString(file, section, "stop.profitPct.value",       /*double  */ NumberToStr(stop.profitPct.value, ".1+"));
   WriteIniString(file, section, "stop.profitPct.absValue",    /*double  */ ifString(stop.profitPct.absValue==INT_MAX, INT_MAX, DoubleToStr(stop.profitPct.absValue, 2)));
   WriteIniString(file, section, "stop.profitPct.description", /*string  */ stop.profitPct.description);
   WriteIniString(file, section, "stop.profitPun.condition",   /*bool    */ stop.profitPun.condition);
   WriteIniString(file, section, "stop.profitPun.type",        /*int     */ stop.profitPun.type);
   WriteIniString(file, section, "stop.profitPun.value",       /*double  */ NumberToStr(stop.profitPun.value, ".1+"));
   WriteIniString(file, section, "stop.profitPun.description", /*string  */ stop.profitPun.description + separator);

   // [Open positions]
   section = "Open positions";
   WriteIniString(file, section, "open.ticket",                /*int     */ open.ticket);
   WriteIniString(file, section, "open.type",                  /*int     */ open.type);
   WriteIniString(file, section, "open.lots",                  /*double  */ NumberToStr(open.lots, ".+"));
   WriteIniString(file, section, "open.time",                  /*datetime*/ open.time + ifString(open.time, GmtTimeFormat(open.time, " (%a, %Y.%m.%d %H:%M:%S)"), ""));
   WriteIniString(file, section, "open.price",                 /*double  */ DoubleToStr(open.price, Digits));
   WriteIniString(file, section, "open.priceSynth",            /*double  */ DoubleToStr(open.priceSynth, Digits));
   WriteIniString(file, section, "open.slippage",              /*double  */ DoubleToStr(open.slippage, Digits));
   WriteIniString(file, section, "open.swap",                  /*double  */ DoubleToStr(open.swap, 2));
   WriteIniString(file, section, "open.commission",            /*double  */ DoubleToStr(open.commission, 2));
   WriteIniString(file, section, "open.grossProfit",           /*double  */ DoubleToStr(open.grossProfit, 2));
   WriteIniString(file, section, "open.netProfit",             /*double  */ DoubleToStr(open.netProfit, 2));
   WriteIniString(file, section, "open.netProfitP",            /*double  */ NumberToStr(open.netProfitP, ".1+"));
   WriteIniString(file, section, "open.synthProfitP",          /*double  */ DoubleToStr(open.synthProfitP, Digits) + separator);

   // [Trade history]
   section = "Trade history";
   double netProfit, netProfitP, synthProfitP;
   int size = ArrayRange(history, 0);

   for (int i=0; i < size; i++) {
      WriteIniString(file, section, "history."+ i, SaveStatus.HistoryToStr(i));
      netProfit    += history[i][H_NETPROFIT    ];
      netProfitP   += history[i][H_NETPROFIT_P  ];
      synthProfitP += history[i][H_SYNTHPROFIT_P];
   }

   // cross-check stored stats
   int precision = MathMax(Digits, 2) + 1;                     // required precision for fractional point values
   if (NE(netProfit,    instance.closedNetProfit, 2))          return(!catch("SaveStatus(2)  "+ instance.name +" sum(history[H_NETPROFIT]) != instance.closedNetProfit ("       + NumberToStr(netProfit, ".2+")               +" != "+ NumberToStr(instance.closedNetProfit, ".2+")               +")", ERR_ILLEGAL_STATE));
   if (NE(netProfitP,   instance.closedNetProfitP, precision)) return(!catch("SaveStatus(3)  "+ instance.name +" sum(history[H_NETPROFIT_P]) != instance.closedNetProfitP ("    + NumberToStr(netProfitP, "."+ Digits +"+")   +" != "+ NumberToStr(instance.closedNetProfitP, "."+ Digits +"+")   +")", ERR_ILLEGAL_STATE));
   if (NE(synthProfitP, instance.closedSynthProfitP,  Digits)) return(!catch("SaveStatus(4)  "+ instance.name +" sum(history[H_SYNTHPROFIT_P]) != instance.closedSynthProfitP ("+ NumberToStr(synthProfitP, "."+ Digits +"+") +" != "+ NumberToStr(instance.closedSynthProfitP, "."+ Digits +"+") +")", ERR_ILLEGAL_STATE));

   return(!catch("SaveStatus(5)"));
}


/**
 * Return a string representation of a history record to be stored by SaveStatus().
 *
 * @param  int index - index of the history record
 *
 * @return string - string representation or an empty string in case of errors
 */
string SaveStatus.HistoryToStr(int index) {
   // result: ticket,type,lots,openTime,openPrice,openPriceSynth,closeTime,closePrice,closePriceSynth,slippage,swap,commission,grossProfit,netProfit,netProfiP,synthProfitP

   int      ticket          = history[index][H_TICKET          ];
   int      type            = history[index][H_TYPE            ];
   double   lots            = history[index][H_LOTS            ];
   datetime openTime        = history[index][H_OPENTIME        ];
   double   openPrice       = history[index][H_OPENPRICE       ];
   double   openPriceSynth  = history[index][H_OPENPRICE_SYNTH ];
   datetime closeTime       = history[index][H_CLOSETIME       ];
   double   closePrice      = history[index][H_CLOSEPRICE      ];
   double   closePriceSynth = history[index][H_CLOSEPRICE_SYNTH];
   double   slippage        = history[index][H_SLIPPAGE        ];
   double   swap            = history[index][H_SWAP            ];
   double   commission      = history[index][H_COMMISSION      ];
   double   grossProfit     = history[index][H_GROSSPROFIT     ];
   double   netProfit       = history[index][H_NETPROFIT       ];
   double   netProfitP      = history[index][H_NETPROFIT_P     ];
   double   synthProfitP    = history[index][H_SYNTHPROFIT_P   ];

   return(StringConcatenate(ticket, ",", type, ",", DoubleToStr(lots, 2), ",", openTime, ",", DoubleToStr(openPrice, Digits), ",", DoubleToStr(openPriceSynth, Digits), ",", closeTime, ",", DoubleToStr(closePrice, Digits), ",", DoubleToStr(closePriceSynth, Digits), ",", DoubleToStr(slippage, Digits), ",", DoubleToStr(swap, 2), ",", DoubleToStr(commission, 2), ",", DoubleToStr(grossProfit, 2), ",", DoubleToStr(netProfit, 2), ",", NumberToStr(netProfitP, ".1+"), ",", DoubleToStr(synthProfitP, Digits)));
}


/**
 * Restore the internal state of the EA from a status file. Requires 'instance.id' and 'instance.isTest' to be set.
 *
 * @return bool - success status
 */
bool RestoreInstance() {
   if (IsLastError())        return(false);
   if (!ReadStatus())        return(false);              // read and apply the status file
   if (!ValidateInputs())    return(false);              // validate restored input parameters
   if (!SynchronizeStatus()) return(false);              // synchronize restored state with current order state
   return(true);
}


/**
 * Read the status file of an instance and restore inputs and runtime variables. Called only from RestoreInstance().
 *
 * @return bool - success status
 */
bool ReadStatus() {
   if (IsLastError()) return(false);
   if (!instance.id)  return(!catch("ReadStatus(1)  "+ instance.name +" illegal value of instance.id: "+ instance.id, ERR_ILLEGAL_STATE));

   string file = FindStatusFile(instance.id, instance.isTest);
   if (file == "")                 return(!catch("ReadStatus(2)  "+ instance.name +" status file not found", ERR_RUNTIME_ERROR));
   if (!IsFile(file, MODE_SYSTEM)) return(!catch("ReadStatus(3)  "+ instance.name +" file "+ DoubleQuoteStr(file) +" not found", ERR_FILE_NOT_FOUND));

   // [General]
   string section      = "General";
   string sAccount     = GetIniStringA(file, section, "Account",     "");                          // string Account     = ICMarkets:12345678 (demo)
   string sThisAccount = GetAccountCompanyId() +":"+ GetAccountNumber();
   string sRealSymbol  = GetIniStringA(file, section, "Symbol",      "");                          // string Symbol      = EURUSD
   string sTestSymbol  = GetIniStringA(file, section, "Test.Symbol", "");                          // string Test.Symbol = EURUSD
   if (sTestSymbol == "") {
      if (!StrCompareI(StrLeftTo(sAccount, " ("), sThisAccount)) return(!catch("ReadStatus(4)  "+ instance.name +" account mis-match: "+ DoubleQuoteStr(sThisAccount) +" vs. "+ DoubleQuoteStr(sAccount) +" in status file "+ DoubleQuoteStr(file), ERR_INVALID_CONFIG_VALUE));
      if (!StrCompareI(sRealSymbol, Symbol()))                   return(!catch("ReadStatus(5)  "+ instance.name +" symbol mis-match: "+ DoubleQuoteStr(Symbol()) +" vs. "+ DoubleQuoteStr(sRealSymbol) +" in status file "+ DoubleQuoteStr(file), ERR_INVALID_CONFIG_VALUE));
   }
   else {
      if (!StrCompareI(sTestSymbol, Symbol()))                   return(!catch("ReadStatus(6)  "+ instance.name +" symbol mis-match: "+ DoubleQuoteStr(Symbol()) +" vs. "+ DoubleQuoteStr(sTestSymbol) +" in status file "+ DoubleQuoteStr(file), ERR_INVALID_CONFIG_VALUE));
   }

   // [Inputs]
   section = "Inputs";
   string sInstanceID          = GetIniStringA(file, section, "Instance.ID",         "");          // string Instance.ID         = T123
   string sTradingMode         = GetIniStringA(file, section, "TradingMode",         "");          // string TradingMode         = regular
   int    iZigZagPeriods       = GetIniInt    (file, section, "ZigZag.Periods"         );          // int    ZigZag.Periods      = 40
   string sLots                = GetIniStringA(file, section, "Lots",                "");          // double Lots                = 0.1
   string sStartConditions     = GetIniStringA(file, section, "StartConditions",     "");          // string StartConditions     = @time(datetime|time)
   string sStopConditions      = GetIniStringA(file, section, "StopConditions",      "");          // string StopConditions      = @time(datetime|time)
   string sTakeProfit          = GetIniStringA(file, section, "TakeProfit",          "");          // double TakeProfit          = 3.0
   string sTakeProfitType      = GetIniStringA(file, section, "TakeProfit.Type",     "");          // string TakeProfit.Type     = off* | money | percent | pip
   string sShowProfitInPercent = GetIniStringA(file, section, "ShowProfitInPercent", "");          // bool   ShowProfitInPercent = 1
   string sEaRecorder          = GetIniStringA(file, section, "EA.Recorder",         "");          // string EA.Recorder         = 1,2,4

   if (!StrIsNumeric(sLots))       return(!catch("ReadStatus(7)  "+ instance.name +" invalid input parameter Lots "+ DoubleQuoteStr(sLots) +" in status file "+ DoubleQuoteStr(file), ERR_INVALID_FILE_FORMAT));
   if (!StrIsNumeric(sTakeProfit)) return(!catch("ReadStatus(8)  "+ instance.name +" invalid input parameter TakeProfit "+ DoubleQuoteStr(sTakeProfit) +" in status file "+ DoubleQuoteStr(file), ERR_INVALID_FILE_FORMAT));

   Instance.ID          = sInstanceID;
   TradingMode          = sTradingMode;
   Lots                 = StrToDouble(sLots);
   ZigZag.Periods       = iZigZagPeriods;
   StartConditions      = sStartConditions;
   StopConditions       = sStopConditions;
   TakeProfit           = StrToDouble(sTakeProfit);
   TakeProfit.Type      = sTakeProfitType;
   ShowProfitInPercent  = StrToBool(sShowProfitInPercent);
   EA.Recorder          = sEaRecorder;

   // [Runtime status]
   section = "Runtime status";
   instance.id                 = GetIniInt    (file, section, "instance.id"                );      // int      instance.id                 = 123
   instance.name               = GetIniStringA(file, section, "instance.name",           "");      // string   instance.name               = Z.123
   instance.created            = GetIniInt    (file, section, "instance.created"           );      // datetime instance.created            = 1624924800 (Mon, 2021.05.12 13:22:34)
   instance.isTest             = GetIniBool   (file, section, "instance.isTest"            );      // bool     instance.isTest             = 1
   instance.status             = GetIniInt    (file, section, "instance.status"            );      // int      instance.status             = 1 (waiting)
   instance.startEquity        = GetIniDouble (file, section, "instance.startEquity"       );      // double   instance.startEquity        = 1000.00
   SS.InstanceName();

   tradingMode                 = GetIniInt    (file, section, "tradingMode");                      // int      tradingMode                 = 1
   recorder.stdEquitySymbol    = GetIniStringA(file, section, "recorder.stdEquitySymbol", "");     // string   recorder.stdEquitySymbol    = GBPJPY.001

   start.time.condition        = GetIniBool   (file, section, "start.time.condition"      );       // bool     start.time.condition       = 1
   start.time.value            = GetIniInt    (file, section, "start.time.value"          );       // datetime start.time.value           = 1624924800
   start.time.isDaily          = GetIniBool   (file, section, "start.time.isDaily"        );       // bool     start.time.isDaily         = 0
   start.time.description      = GetIniStringA(file, section, "start.time.description", "");       // string   start.time.description     = text

   stop.time.condition         = GetIniBool   (file, section, "stop.time.condition"      );        // bool     stop.time.condition        = 1
   stop.time.value             = GetIniInt    (file, section, "stop.time.value"          );        // datetime stop.time.value            = 1624924800
   stop.time.isDaily           = GetIniBool   (file, section, "stop.time.isDaily"        );        // bool     stop.time.isDaily          = 0
   stop.time.description       = GetIniStringA(file, section, "stop.time.description", "");        // string   stop.time.description      = text

   stop.profitAbs.condition    = GetIniBool   (file, section, "stop.profitAbs.condition"        ); // bool     stop.profitAbs.condition   = 1
   stop.profitAbs.value        = GetIniDouble (file, section, "stop.profitAbs.value"            ); // double   stop.profitAbs.value       = 10.00
   stop.profitAbs.description  = GetIniStringA(file, section, "stop.profitAbs.description",   ""); // string   stop.profitAbs.description = text
   stop.profitPct.condition    = GetIniBool   (file, section, "stop.profitPct.condition"        ); // bool     stop.profitPct.condition   = 0
   stop.profitPct.value        = GetIniDouble (file, section, "stop.profitPct.value"            ); // double   stop.profitPct.value       = 0
   stop.profitPct.absValue     = GetIniDouble (file, section, "stop.profitPct.absValue", INT_MAX); // double   stop.profitPct.absValue    = 0.00
   stop.profitPct.description  = GetIniStringA(file, section, "stop.profitPct.description",   ""); // string   stop.profitPct.description = text

   stop.profitPun.condition    = GetIniBool   (file, section, "stop.profitPun.condition"      );   // bool     stop.profitPun.condition   = 1
   stop.profitPun.type         = GetIniInt    (file, section, "stop.profitPun.type"           );   // int      stop.profitPun.type        = 4
   stop.profitPun.value        = GetIniDouble (file, section, "stop.profitPun.value"          );   // double   stop.profitPun.value       = 1.23456
   stop.profitPun.description  = GetIniStringA(file, section, "stop.profitPun.description", "");   // string   stop.profitPun.description = text

   // [Stats: net in money]
   section = "Stats: net in money";
   instance.openNetProfit      = GetIniDouble (file, section, "openProfit"  );                     // double   openProfit   = 23.45
   instance.closedNetProfit    = GetIniDouble (file, section, "closedProfit");                     // double   closedProfit = 45.67
   instance.totalNetProfit     = GetIniDouble (file, section, "totalProfit" );                     // double   totalProfit  = 123.45
   instance.maxNetDrawdown     = GetIniDouble (file, section, "minProfit"   );                     // double   minProfit    = -11.23
   instance.maxNetProfit       = GetIniDouble (file, section, "maxProfit"   );                     // double   maxProfit    = 23.45

   // [Stats: net in punits]
   section = "Stats: net in "+ pUnit;
   instance.openNetProfitP     = GetIniDouble (file, section, "openProfit"  )/pMultiplier;         // double   openProfit   = 1234.5
   instance.closedNetProfitP   = GetIniDouble (file, section, "closedProfit")/pMultiplier;         // double   closedProfit = -2345.6
   instance.totalNetProfitP    = GetIniDouble (file, section, "totalProfit" )/pMultiplier;         // double   totalProfit  = 12345.6
   instance.maxNetDrawdownP    = GetIniDouble (file, section, "minProfit"   )/pMultiplier;         // double   minProfit    = -2345.6
   instance.maxNetProfitP      = GetIniDouble (file, section, "maxProfit"   )/pMultiplier;         // double   maxProfit    = 1234.5

   // [Stats: synthetic in punits]
   section = "Stats: synthetic in "+ pUnit;
   instance.openSynthProfitP   = GetIniDouble (file, section, "openProfit"  )/pMultiplier;         // double   openProfit   = 1234.5
   instance.closedSynthProfitP = GetIniDouble (file, section, "closedProfit")/pMultiplier;         // double   closedProfit = -2345.6
   instance.totalSynthProfitP  = GetIniDouble (file, section, "totalProfit" )/pMultiplier;         // double   totalProfit  = 12345.6
   instance.maxSynthDrawdownP  = GetIniDouble (file, section, "minProfit"   )/pMultiplier;         // double   minProfit    = -2345.6
   instance.maxSynthProfitP    = GetIniDouble (file, section, "maxProfit"   )/pMultiplier;         // double   maxProfit    = 1234.5

   // [Open positions]
   section = "Open positions";
   open.ticket                 = GetIniInt    (file, section, "open.ticket"      );                // int      open.ticket       = 123456
   open.type                   = GetIniInt    (file, section, "open.type"        );                // int      open.type         = 1
   open.lots                   = GetIniDouble (file, section, "open.lots"        );                // double   open.lots         = 0.01
   open.time                   = GetIniInt    (file, section, "open.time"        );                // datetime open.time         = 1624924800 (Mon, 2021.05.12 13:22:34)
   open.price                  = GetIniDouble (file, section, "open.price"       );                // double   open.price        = 1.24363
   open.priceSynth             = GetIniDouble (file, section, "open.priceSynth"  );                // double   open.priceSynth   = 1.24363
   open.slippage               = GetIniDouble (file, section, "open.slippage"    );                // double   open.slippage     = 0.00002
   open.swap                   = GetIniDouble (file, section, "open.swap"        );                // double   open.swap         = -1.23
   open.commission             = GetIniDouble (file, section, "open.commission"  );                // double   open.commission   = -5.50
   open.grossProfit            = GetIniDouble (file, section, "open.grossProfit" );                // double   open.grossProfit  = 12.34
   open.netProfit              = GetIniDouble (file, section, "open.netProfit"   );                // double   open.netProfit    = 12.56
   open.netProfitP             = GetIniDouble (file, section, "open.netProfitP"  );                // double   open.netProfitP   = 0.12345
   open.synthProfitP           = GetIniDouble (file, section, "open.synthProfitP");                // double   open.synthProfitP = 0.12345

   // [Trade history]
   section = "Trade history";
   string sKeys[], sOrder="";
   double netProfit, netProfitP, synthProfitP;
   int size = ReadStatus.HistoryKeys(file, section, sKeys); if (size < 0) return(false);

   for (int i=0; i < size; i++) {
      sOrder = GetIniStringA(file, section, sKeys[i], "");                                         // history.{i} = {data}
      int n = ReadStatus.RestoreHistory(sKeys[i], sOrder);
      if (n < 0) return(!catch("ReadStatus(9)  "+ instance.name +" invalid history record in status file "+ DoubleQuoteStr(file) + NL + sKeys[i] +"="+ sOrder, ERR_INVALID_FILE_FORMAT));

      netProfit    += history[n][H_NETPROFIT    ];
      netProfitP   += history[n][H_NETPROFIT_P  ];
      synthProfitP += history[n][H_SYNTHPROFIT_P];
   }

   // cross-check restored stats
   int precision = MathMax(Digits, 2) + 1;                     // required precision for fractional point values
   if (NE(netProfit,    instance.closedNetProfit, 2))          return(!catch("ReadStatus(10)  "+ instance.name +" sum(history[H_NETPROFIT]) != instance.closedNetProfit ("       + NumberToStr(netProfit, ".2+")               +" != "+ NumberToStr(instance.closedNetProfit, ".2+")               +")", ERR_ILLEGAL_STATE));
   if (NE(netProfitP,   instance.closedNetProfitP, precision)) return(!catch("ReadStatus(11)  "+ instance.name +" sum(history[H_NETPROFIT_P]) != instance.closedNetProfitP ("    + NumberToStr(netProfitP, "."+ Digits +"+")   +" != "+ NumberToStr(instance.closedNetProfitP, "."+ Digits +"+")   +")", ERR_ILLEGAL_STATE));
   if (NE(synthProfitP, instance.closedSynthProfitP, Digits))  return(!catch("ReadStatus(12)  "+ instance.name +" sum(history[H_SYNTHPROFIT_P]) != instance.closedSynthProfitP ("+ NumberToStr(synthProfitP, "."+ Digits +"+") +" != "+ NumberToStr(instance.closedSynthProfitP, "."+ Digits +"+") +")", ERR_ILLEGAL_STATE));

   return(!catch("ReadStatus(13)"));
}


/**
 * Read and return the keys of all trade history records found in the status file (sorting order doesn't matter).
 *
 * @param  _In_  string file    - status filename
 * @param  _In_  string section - status section
 * @param  _Out_ string &keys[] - array receiving the found keys
 *
 * @return int - number of found keys or EMPTY (-1) in case of errors
 */
int ReadStatus.HistoryKeys(string file, string section, string &keys[]) {
   int size = GetIniKeys(file, section, keys);
   if (size < 0) return(EMPTY);

   for (int i=size-1; i >= 0; i--) {
      if (StrStartsWithI(keys[i], "history."))
         continue;
      ArraySpliceStrings(keys, i, 1);     // drop all non-order keys
      size--;
   }
   return(size);                          // no need to sort as records are inserted at the correct position
}


/**
 * Parse the string representation of a closed order record and store the parsed data.
 *
 * @param  string key   - order key
 * @param  string value - order string to parse
 *
 * @return int - index the data record was inserted at or EMPTY (-1) in case of errors
 */
int ReadStatus.RestoreHistory(string key, string value) {
   if (IsLastError())                    return(EMPTY);
   if (!StrStartsWithI(key, "history.")) return(_EMPTY(catch("ReadStatus.RestoreHistory(1)  "+ instance.name +" illegal history record key "+ DoubleQuoteStr(key), ERR_INVALID_FILE_FORMAT)));

   // history.i=ticket,type,lots,openTime,openPrice,openPriceSynth,closeTime,closePrice,closePriceSynth,slippage,swap,commission,grossProfit,netProfit,netProfitP,synthProfitP
   string values[];
   string sId = StrRightFrom(key, ".", -1); if (!StrIsDigits(sId))  return(_EMPTY(catch("ReadStatus.RestoreHistory(2)  "+ instance.name +" illegal history record key "+ DoubleQuoteStr(key), ERR_INVALID_FILE_FORMAT)));
   if (Explode(value, ",", values, NULL) != ArrayRange(history, 1)) return(_EMPTY(catch("ReadStatus.RestoreHistory(3)  "+ instance.name +" illegal number of details ("+ ArraySize(values) +") in history record", ERR_INVALID_FILE_FORMAT)));

   int      ticket          = StrToInteger(values[H_TICKET          ]);
   int      type            = StrToInteger(values[H_TYPE            ]);
   double   lots            =  StrToDouble(values[H_LOTS            ]);
   datetime openTime        = StrToInteger(values[H_OPENTIME        ]);
   double   openPrice       =  StrToDouble(values[H_OPENPRICE       ]);
   double   openPriceSynth  =  StrToDouble(values[H_OPENPRICE_SYNTH ]);
   datetime closeTime       = StrToInteger(values[H_CLOSETIME       ]);
   double   closePrice      =  StrToDouble(values[H_CLOSEPRICE      ]);
   double   closePriceSynth =  StrToDouble(values[H_CLOSEPRICE_SYNTH]);
   double   slippage        =  StrToDouble(values[H_SLIPPAGE        ]);
   double   swap            =  StrToDouble(values[H_SWAP            ]);
   double   commission      =  StrToDouble(values[H_COMMISSION      ]);
   double   grossProfit     =  StrToDouble(values[H_GROSSPROFIT     ]);
   double   netProfit       =  StrToDouble(values[H_NETPROFIT       ]);
   double   netProfitP      =  StrToDouble(values[H_NETPROFIT_P     ]);
   double   synthProfitP    =  StrToDouble(values[H_SYNTHPROFIT_P   ]);

   return(History.AddRecord(ticket, type, lots, openTime, openPrice, openPriceSynth, closeTime, closePrice, closePriceSynth, slippage, swap, commission, grossProfit, netProfit, netProfitP, synthProfitP));
}


/**
 * Add an order record to the history array. Records are ordered ascending by {OpenTime;Ticket} and the new record is inserted
 * at the correct position. No data is overwritten.
 *
 * @param  int ticket - order record details
 * @param  ...
 *
 * @return int - index the record was inserted at or EMPTY (-1) in case of errors
 */
int History.AddRecord(int ticket, int type, double lots, datetime openTime, double openPrice, double openPriceSynth, datetime closeTime, double closePrice, double closePriceSynth, double slippage, double swap, double commission, double grossProfit, double netProfit, double netProfitP, double synthProfitP) {
   int size = ArrayRange(history, 0);

   for (int i=0; i < size; i++) {
      if (EQ(ticket,   history[i][H_TICKET  ])) return(_EMPTY(catch("History.AddRecord(1)  "+ instance.name +" cannot add record, ticket #"+ ticket +" already exists (offset: "+ i +")", ERR_INVALID_PARAMETER)));
      if (GT(openTime, history[i][H_OPENTIME])) continue;
      if (LT(openTime, history[i][H_OPENTIME])) break;
      if (LT(ticket,   history[i][H_TICKET  ])) break;
   }

   // 'i' now holds the array index to insert at
   if (i == size) {
      ArrayResize(history, size+1);                                  // add a new empty slot or...
   }
   else {
      int dim2=ArrayRange(history, 1), from=i*dim2, to=from+dim2;    // ...free an existing slot by shifting existing data
      ArrayCopy(history, history, to, from);
   }

   // insert the new data
   history[i][H_TICKET          ] = ticket;
   history[i][H_TYPE            ] = type;
   history[i][H_LOTS            ] = lots;
   history[i][H_OPENTIME        ] = openTime;
   history[i][H_OPENPRICE       ] = openPrice;
   history[i][H_OPENPRICE_SYNTH ] = openPriceSynth;
   history[i][H_CLOSETIME       ] = closeTime;
   history[i][H_CLOSEPRICE      ] = closePrice;
   history[i][H_CLOSEPRICE_SYNTH] = closePriceSynth;
   history[i][H_SLIPPAGE        ] = slippage;
   history[i][H_SWAP            ] = swap;
   history[i][H_COMMISSION      ] = commission;
   history[i][H_GROSSPROFIT     ] = grossProfit;
   history[i][H_NETPROFIT       ] = netProfit;
   history[i][H_NETPROFIT_P     ] = netProfitP;
   history[i][H_SYNTHPROFIT_P   ] = synthProfitP;

   if (!catch("History.AddRecord(2)"))
      return(i);
   return(EMPTY);
}


/**
 * Synchronize runtime state and vars with current order status on the trade server. Called only from RestoreInstance().
 *
 * @return bool - success status
 */
bool SynchronizeStatus() {
   if (IsLastError()) return(false);

   int prevOpenTicket  = open.ticket;
   int prevHistorySize = ArrayRange(history, 0);

   // detect dangling open positions
   for (int i=OrdersTotal()-1; i >= 0; i--) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (IsMyOrder(instance.id)) {
         if (IsPendingOrderType(OrderType())) {
            logWarn("SynchronizeStatus(1)  "+ instance.name +" unsupported pending order found: #"+ OrderTicket() +", ignoring it...");
            continue;
         }
         if (!open.ticket) {
            logWarn("SynchronizeStatus(2)  "+ instance.name +" dangling open position found: #"+ OrderTicket() +", adding to instance...");
            open.ticket     = OrderTicket();
            open.type       = OrderType();
            open.time       = OrderOpenTime();
            open.price      = OrderOpenPrice();
            open.priceSynth = open.price;
            open.slippage   = NULL;                                   // open PnL numbers will auto-update in the following UpdateStatus() call
         }
         else if (OrderTicket() != open.ticket) {
            return(!catch("SynchronizeStatus(3)  "+ instance.name +" dangling open position found: #"+ OrderTicket(), ERR_RUNTIME_ERROR));
         }
      }
   }

   // update open position status
   if (open.ticket > 0) {
      if (!UpdateStatus()) return(false);
   }

   // detect orphaned closed positions
   for (i=OrdersHistoryTotal()-1; i >= 0; i--) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (IsPendingOrderType(OrderType()))              continue;    // skip deleted pending orders (atm not supported)

      if (IsMyOrder(instance.id)) {
         if (!IsLocalClosedPosition(OrderTicket())) {
            int      ticket       = OrderTicket();
            double   lots         = OrderLots();
            int      openType     = OrderType();
            datetime openTime     = OrderOpenTime();
            double   openPrice    = OrderOpenPrice();
            datetime closeTime    = OrderCloseTime();
            double   closePrice   = OrderClosePrice();
            double   slippage     = 0;
            double   swap         = NormalizeDouble(OrderSwap(), 2);
            double   commission   = OrderCommission();
            double   grossProfit  = OrderProfit();
            double   grossProfitP = ifDouble(!openType, closePrice-openPrice, openPrice-closePrice);
            double   netProfit    = grossProfit + swap + commission;
            double   netProfitP   = grossProfitP + MathDiv(swap + commission, PointValue(lots));

            logWarn("SynchronizeStatus(4)  "+ instance.name +" dangling closed position found: #"+ ticket +", adding to instance...");
            if (IsEmpty(History.AddRecord(ticket, lots, openType, openTime, openPrice, openPrice, closeTime, closePrice, closePrice, slippage, swap, commission, grossProfit, netProfit, netProfitP, grossProfitP))) return(false);

            // update closed PL numbers
            instance.closedNetProfit    += netProfit;
            instance.closedNetProfitP   += netProfitP;
            instance.closedSynthProfitP += grossProfitP;             // for orphaned positions same as grossProfitP
         }
      }
   }

   // recalculate total PL numbers
   instance.totalNetProfit = instance.openNetProfit + instance.closedNetProfit;
   instance.maxNetProfit   = MathMax(instance.maxNetProfit,   instance.totalNetProfit);
   instance.maxNetDrawdown = MathMin(instance.maxNetDrawdown, instance.totalNetProfit);

   instance.totalNetProfitP = instance.openNetProfitP + instance.closedNetProfitP;
   instance.maxNetProfitP   = MathMax(instance.maxNetProfitP,   instance.totalNetProfitP);
   instance.maxNetDrawdownP = MathMin(instance.maxNetDrawdownP, instance.totalNetProfitP);

   instance.totalSynthProfitP = instance.openSynthProfitP + instance.closedSynthProfitP;
   instance.maxSynthProfitP   = MathMax(instance.maxSynthProfitP,   instance.totalSynthProfitP);
   instance.maxSynthDrawdownP = MathMin(instance.maxSynthDrawdownP, instance.totalSynthProfitP);
   SS.All();

   if (open.ticket!=prevOpenTicket || ArrayRange(history, 0)!=prevHistorySize)
      return(SaveStatus());                                          // immediately save status if orders changed
   return(!catch("SynchronizeStatus(5)"));
}


/**
 * Whether the specified ticket exists in the local history of closed positions.
 *
 * @param  int ticket
 *
 * @return bool
 */
bool IsLocalClosedPosition(int ticket) {
   int size = ArrayRange(history, 0);
   for (int i=0; i < size; i++) {
      if (history[i][H_TICKET] == ticket) return(true);
   }
   return(false);
}


/**
 * Whether the current instance was created in the tester. Also returns TRUE if a finished test is loaded into an online chart.
 *
 * @return bool
 */
bool IsTestInstance() {
   return(instance.isTest || __isTesting);
}


// backed-up input parameters
string   prev.Instance.ID = "";
string   prev.TradingMode = "";
int      prev.ZigZag.Periods;
double   prev.Lots;
string   prev.StartConditions = "";
string   prev.StopConditions = "";
double   prev.TakeProfit;
string   prev.TakeProfit.Type = "";
bool     prev.ShowProfitInPercent;

// backed-up runtime variables affected by changing input parameters
int      prev.tradingMode;

int      prev.instance.id;
datetime prev.instance.created;
bool     prev.instance.isTest;
string   prev.instance.name = "";
int      prev.instance.status;

bool     prev.start.time.condition;
datetime prev.start.time.value;
bool     prev.start.time.isDaily;
string   prev.start.time.description = "";

bool     prev.stop.time.condition;
datetime prev.stop.time.value;
bool     prev.stop.time.isDaily;
string   prev.stop.time.description = "";
bool     prev.stop.profitAbs.condition;
double   prev.stop.profitAbs.value;
string   prev.stop.profitAbs.description = "";
bool     prev.stop.profitPct.condition;
double   prev.stop.profitPct.value;
double   prev.stop.profitPct.absValue;
string   prev.stop.profitPct.description = "";
bool     prev.stop.profitPun.condition;
int      prev.stop.profitPun.type;
double   prev.stop.profitPun.value;
string   prev.stop.profitPun.description = "";


/**
 * Programatically changed input parameters don't survive init cycles. Therefore inputs are backed-up in deinit() and can be
 * restored in init(). Called in onDeinitParameters() and onDeinitChartChange().
 */
void BackupInputs() {
   // backup input parameters, used for comparison in ValidateInputs()
   prev.Instance.ID         = StringConcatenate(Instance.ID, "");       // string inputs are references to internal C literals
   prev.TradingMode         = StringConcatenate(TradingMode, "");       // and must be copied to break the reference
   prev.ZigZag.Periods      = ZigZag.Periods;
   prev.Lots                = Lots;
   prev.StartConditions     = StringConcatenate(StartConditions, "");
   prev.StopConditions      = StringConcatenate(StopConditions, "");
   prev.TakeProfit          = TakeProfit;
   prev.TakeProfit.Type     = StringConcatenate(TakeProfit.Type, "");
   prev.ShowProfitInPercent = ShowProfitInPercent;

   // backup runtime variables affected by changing input parameters
   prev.tradingMode                = tradingMode;

   prev.instance.id                = instance.id;
   prev.instance.created           = instance.created;
   prev.instance.isTest            = instance.isTest;
   prev.instance.name              = instance.name;
   prev.instance.status            = instance.status;

   prev.start.time.condition       = start.time.condition;
   prev.start.time.value           = start.time.value;
   prev.start.time.isDaily         = start.time.isDaily;
   prev.start.time.description     = start.time.description;

   prev.stop.time.condition        = stop.time.condition;
   prev.stop.time.value            = stop.time.value;
   prev.stop.time.isDaily          = stop.time.isDaily;
   prev.stop.time.description      = stop.time.description;
   prev.stop.profitAbs.condition   = stop.profitAbs.condition;
   prev.stop.profitAbs.value       = stop.profitAbs.value;
   prev.stop.profitAbs.description = stop.profitAbs.description;
   prev.stop.profitPct.condition   = stop.profitPct.condition;
   prev.stop.profitPct.value       = stop.profitPct.value;
   prev.stop.profitPct.absValue    = stop.profitPct.absValue;
   prev.stop.profitPct.description = stop.profitPct.description;
   prev.stop.profitPun.condition    = stop.profitPun.condition;
   prev.stop.profitPun.type         = stop.profitPun.type;
   prev.stop.profitPun.value        = stop.profitPun.value;
   prev.stop.profitPun.description  = stop.profitPun.description;

   Recorder.BackupInputs();
}


/**
 * Restore backed-up input parameters and runtime variables. Called from onInitParameters() and onInitTimeframeChange().
 */
void RestoreInputs() {
   // restore input parameters
   Instance.ID          = prev.Instance.ID;
   TradingMode          = prev.TradingMode;
   ZigZag.Periods       = prev.ZigZag.Periods;
   Lots                 = prev.Lots;
   StartConditions      = prev.StartConditions;
   StopConditions       = prev.StopConditions;
   TakeProfit           = prev.TakeProfit;
   TakeProfit.Type      = prev.TakeProfit.Type;
   ShowProfitInPercent  = prev.ShowProfitInPercent;
   EA.Recorder          = prev.EA.Recorder;

   // restore runtime variables
   tradingMode                = prev.tradingMode;

   instance.id                = prev.instance.id;
   instance.created           = prev.instance.created;
   instance.isTest            = prev.instance.isTest;
   instance.name              = prev.instance.name;
   instance.status            = prev.instance.status;

   start.time.condition       = prev.start.time.condition;
   start.time.value           = prev.start.time.value;
   start.time.isDaily         = prev.start.time.isDaily;
   start.time.description     = prev.start.time.description;

   stop.time.condition        = prev.stop.time.condition;
   stop.time.value            = prev.stop.time.value;
   stop.time.isDaily          = prev.stop.time.isDaily;
   stop.time.description      = prev.stop.time.description;
   stop.profitAbs.condition   = prev.stop.profitAbs.condition;
   stop.profitAbs.value       = prev.stop.profitAbs.value;
   stop.profitAbs.description = prev.stop.profitAbs.description;
   stop.profitPct.condition   = prev.stop.profitPct.condition;
   stop.profitPct.value       = prev.stop.profitPct.value;
   stop.profitPct.absValue    = prev.stop.profitPct.absValue;
   stop.profitPct.description = prev.stop.profitPct.description;
   stop.profitPun.condition   = prev.stop.profitPun.condition;
   stop.profitPun.type        = prev.stop.profitPun.type;
   stop.profitPun.value       = prev.stop.profitPun.value;
   stop.profitPun.description = prev.stop.profitPun.description;

   Recorder.RestoreInputs();
}


/**
 * Validate and apply input parameter "Instance.ID".
 *
 * @return bool - whether an instance id value was successfully restored (the status file is not checked)
 */
bool ValidateInputs.ID() {
   bool errorFlag = true;

   if (!SetInstanceId(Instance.ID, errorFlag, "ValidateInputs.ID(1)")) {
      if (errorFlag) onInputError("ValidateInputs.ID(2)  invalid input parameter Instance.ID: \""+ Instance.ID +"\"");
      return(false);
   }
   return(true);
}


/**
 * Validate all input parameters. Parameters may have been entered through the input dialog, read from a status file or were
 * deserialized and set programmatically by the terminal (e.g. at terminal restart). Called from onInitUser(),
 * onInitParameters() or onInitTemplate().
 *
 * @return bool - whether input parameters are valid
 */
bool ValidateInputs() {
   if (IsLastError()) return(false);
   bool isInitParameters = (ProgramInitReason()==IR_PARAMETERS);  // whether we validate manual or programatic input
   bool instanceWasStarted = (open.ticket || ArrayRange(history, 0));

   // Instance.ID
   if (isInitParameters) {                              // otherwise the id was validated in ValidateInputs.ID()
      if (StrTrim(Instance.ID) == "") {                 // the id was deleted or not yet set, re-apply the internal id
         Instance.ID = prev.Instance.ID;
      }
      else if (Instance.ID != prev.Instance.ID)         return(!onInputError("ValidateInputs(1)  "+ instance.name +" switching to another instance is not supported (unload the EA first)"));
   }

   // TradingMode: "regular* | virtual"
   string sValues[], sValue=TradingMode;
   if (Explode(sValue, "*", sValues, 2) > 1) {
      int size = Explode(sValues[0], "|", sValues, NULL);
      sValue = sValues[size-1];
   }
   sValue = StrToLower(StrTrim(sValue));
   if      (StrStartsWith("regular", sValue)) tradingMode = TRADINGMODE_REGULAR;
   else if (StrStartsWith("virtual", sValue)) tradingMode = TRADINGMODE_VIRTUAL;
   else                                                 return(!onInputError("ValidateInputs(2)  "+ instance.name +" invalid input parameter TradingMode: "+ DoubleQuoteStr(TradingMode)));
   if (isInitParameters && tradingMode!=prev.tradingMode) {
      if (instanceWasStarted)                           return(!onInputError("ValidateInputs(3)  "+ instance.name +" cannot change input parameter TradingMode of "+ StatusDescription(instance.status) +" instance"));
   }
   TradingMode = tradingModeDescriptions[tradingMode];

   // ZigZag.Periods
   if (isInitParameters && ZigZag.Periods!=prev.ZigZag.Periods) {
      if (instanceWasStarted)                           return(!onInputError("ValidateInputs(4)  "+ instance.name +" cannot change input parameter ZigZag.Periods of "+ StatusDescription(instance.status) +" instance"));
   }
   if (ZigZag.Periods < 2)                              return(!onInputError("ValidateInputs(5)  "+ instance.name +" invalid input parameter ZigZag.Periods: "+ ZigZag.Periods));

   // Lots
   if (isInitParameters && NE(Lots, prev.Lots)) {
      if (instanceWasStarted)                           return(!onInputError("ValidateInputs(6)  "+ instance.name +" cannot change input parameter Lots of "+ StatusDescription(instance.status) +" instance"));
   }
   if (LT(Lots, 0))                                     return(!onInputError("ValidateInputs(7)  "+ instance.name +" invalid input parameter Lots: "+ NumberToStr(Lots, ".1+") +" (too small)"));
   if (NE(Lots, NormalizeLots(Lots)))                   return(!onInputError("ValidateInputs(8)  "+ instance.name +" invalid input parameter Lots: "+ NumberToStr(Lots, ".1+") +" (not a multiple of MODE_LOTSTEP="+ NumberToStr(MarketInfo(Symbol(), MODE_LOTSTEP), ".+") +")"));

   // StartConditions: @time(datetime|time)
   if (!isInitParameters || StartConditions!=prev.StartConditions) {
      string exprs[], expr="", key="", descr="";        // split conditions
      int sizeOfExprs = Explode(StartConditions, "|", exprs, NULL), iValue, time, pt[];
      datetime dtValue;
      bool isDaily, containsTimeCondition = false;

      for (int i=0; i < sizeOfExprs; i++) {             // validate each expression
         expr = StrTrim(exprs[i]);
         if (!StringLen(expr)) continue;
         if (StringGetChar(expr, 0) != '@')             return(!onInputError("ValidateInputs(9)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions)));
         if (Explode(expr, "(", sValues, NULL) != 2)    return(!onInputError("ValidateInputs(10)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions)));
         if (!StrEndsWith(sValues[1], ")"))             return(!onInputError("ValidateInputs(11)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions)));
         key = StrTrim(sValues[0]);
         sValue = StrTrim(StrLeft(sValues[1], -1));
         if (!StringLen(sValue))                        return(!onInputError("ValidateInputs(12)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions)));

         if (key == "@time") {
            if (containsTimeCondition)                  return(!onInputError("ValidateInputs(13)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions) +" (multiple time conditions)"));
            containsTimeCondition = true;

            if (!ParseDateTime(sValue, NULL, pt))       return(!onInputError("ValidateInputs(14)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions)));
            dtValue = DateTime2(pt, DATE_OF_ERA);
            isDaily = !pt[PT_HAS_DATE];
            descr   = "time("+ TimeToStr(dtValue, ifInt(isDaily, TIME_MINUTES, TIME_DATE|TIME_MINUTES)) +")";

            if (descr != start.time.description) {      // enable condition only if changed
               start.time.condition   = true;
               start.time.value       = dtValue;
               start.time.isDaily     = isDaily;
               start.time.description = descr;
            }
         }
         else                                           return(!onInputError("ValidateInputs(15)  "+ instance.name +" invalid input parameter StartConditions: "+ DoubleQuoteStr(StartConditions)));
      }
      if (!containsTimeCondition && start.time.condition) {
         start.time.condition = false;
      }
   }

   // StopConditions: @time(datetime|time)
   if (!isInitParameters || StopConditions!=prev.StopConditions) {
      sizeOfExprs = Explode(StopConditions, "|", exprs, NULL);
      containsTimeCondition = false;

      for (i=0; i < sizeOfExprs; i++) {                 // validate each expression
         expr = StrTrim(exprs[i]);
         if (!StringLen(expr)) continue;
         if (StringGetChar(expr, 0) != '@')             return(!onInputError("ValidateInputs(16)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions)));
         if (Explode(expr, "(", sValues, NULL) != 2)    return(!onInputError("ValidateInputs(17)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions)));
         if (!StrEndsWith(sValues[1], ")"))             return(!onInputError("ValidateInputs(18)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions)));
         key = StrTrim(sValues[0]);
         sValue = StrTrim(StrLeft(sValues[1], -1));
         if (!StringLen(sValue))                        return(!onInputError("ValidateInputs(19)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions)));

         if (key == "@time") {
            if (containsTimeCondition)                  return(!onInputError("ValidateInputs(20)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions) +" (multiple time conditions)"));
            containsTimeCondition = true;

            if (!ParseDateTime(sValue, NULL, pt))       return(!onInputError("ValidateInputs(21)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions)));
            dtValue = DateTime2(pt, DATE_OF_ERA);
            isDaily = !pt[PT_HAS_DATE];
            descr   = "time("+ TimeToStr(dtValue, ifInt(isDaily, TIME_MINUTES, TIME_DATE|TIME_MINUTES)) +")";

            if (descr != stop.time.description) {       // enable condition only if changed
               stop.time.condition   = true;
               stop.time.value       = dtValue;
               stop.time.isDaily     = isDaily;
               stop.time.description = descr;
            }
            if (start.time.condition && !start.time.isDaily && !stop.time.isDaily) {
               if (start.time.value >= stop.time.value) return(!onInputError("ValidateInputs(22)  "+ instance.name +" invalid times in Start/StopConditions: "+ start.time.description +" / "+ stop.time.description +" (start time must preceed stop time)"));
            }
         }
         else                                           return(!onInputError("ValidateInputs(23)  "+ instance.name +" invalid input parameter StopConditions: "+ DoubleQuoteStr(StopConditions)));
      }
      if (!containsTimeCondition && stop.time.condition) {
         stop.time.condition = false;
      }
   }

   // TakeProfit (nothing to do)

   // TakeProfit.Type: "off* | money | percent | pip | quote-unit"
   sValue = StrToLower(TakeProfit.Type);
   if (Explode(sValue, "*", sValues, 2) > 1) {
      size = Explode(sValues[0], "|", sValues, NULL);
      sValue = sValues[size-1];
   }
   sValue = StrTrim(sValue);
   if      (StrStartsWith("off",        sValue)) stop.profitPun.type = NULL;
   else if (StrStartsWith("money",      sValue)) stop.profitPun.type = TP_TYPE_MONEY;
   else if (StrStartsWith("quote-unit", sValue)) stop.profitPun.type = TP_TYPE_PRICEUNIT;
   else if (StringLen(sValue) < 2)                      return(!onInputError("ValidateInputs(24)  "+ instance.name +" invalid parameter TakeProfit.Type: "+ DoubleQuoteStr(TakeProfit.Type)));
   else if (StrStartsWith("percent", sValue))    stop.profitPun.type = TP_TYPE_PERCENT;
   else if (StrStartsWith("pip",     sValue))    stop.profitPun.type = TP_TYPE_PIP;
   else                                                 return(!onInputError("ValidateInputs(25)  "+ instance.name +" invalid parameter TakeProfit.Type: "+ DoubleQuoteStr(TakeProfit.Type)));
   stop.profitAbs.condition   = false;
   stop.profitAbs.description = "";
   stop.profitPct.condition   = false;
   stop.profitPct.description = "";
   stop.profitPun.condition   = false;
   stop.profitPun.description = "";

   switch (stop.profitPun.type) {
      case TP_TYPE_MONEY:
         stop.profitAbs.condition   = true;
         stop.profitAbs.value       = NormalizeDouble(TakeProfit, 2);
         stop.profitAbs.description = "profit("+ DoubleToStr(stop.profitAbs.value, 2) +" "+ AccountCurrency() +")";
         break;

      case TP_TYPE_PERCENT:
         stop.profitPct.condition   = true;
         stop.profitPct.value       = TakeProfit;
         stop.profitPct.absValue    = INT_MAX;
         stop.profitPct.description = "profit("+ NumberToStr(stop.profitPct.value, ".+") +"%)";
         break;

      case TP_TYPE_PIP:
         stop.profitPun.condition   = true;
         stop.profitPun.value       = NormalizeDouble(TakeProfit*Pip, Digits);
         stop.profitPun.description = "profit("+ NumberToStr(TakeProfit, ".+") +" pip)";
         break;

      case TP_TYPE_PRICEUNIT:
         stop.profitPun.condition   = true;
         stop.profitPun.value       = NormalizeDouble(TakeProfit, Digits);
         stop.profitPun.description = "profit("+ NumberToStr(stop.profitPun.value, PriceFormat) +" point)";
         break;
   }
   TakeProfit.Type = tpTypeDescriptions[stop.profitPun.type];

   // EA.Recorder: on | off* | 1,2,3=1000,...
   if (!Recorder.ValidateInputs(IsTestInstance())) return(false);

   SS.All();
   return(!catch("ValidateInputs(26)"));
}


/**
 * Error handler for invalid input parameters. Depending on the execution context a non-/terminating error is set.
 *
 * @param  string message - error message
 *
 * @return int - error status
 */
int onInputError(string message) {
   int error = ERR_INVALID_PARAMETER;

   if (ProgramInitReason() == IR_PARAMETERS)
      return(logError(message, error));            // non-terminating error
   return(catch(message, error));                  // terminating error
}


/**
 * Store volatile runtime vars in chart and chart window (for template reload, terminal restart, recompilation etc).
 *
 * @return bool - success status
 */
bool StoreVolatileData() {
   string name = ProgramName();

   // input string Instance.ID
   string value = ifString(instance.isTest, "T", "") + StrPadLeft(instance.id, 3, "0");
   Instance.ID = value;
   if (__isChart) {
      string key = name +".Instance.ID";
      SetWindowStringA(__ExecutionContext[EC.hChart], key, value);
      Chart.StoreString(key, value);
   }

   // int status.activeMetric
   if (__isChart) {
      key = name +".status.activeMetric";
      SetWindowIntegerA(__ExecutionContext[EC.hChart], key, status.activeMetric);
      Chart.StoreInt(key, status.activeMetric);
   }

   // bool status.showOpenOrders
   if (__isChart) {
      key = name +".status.showOpenOrders";
      SetWindowIntegerA(__ExecutionContext[EC.hChart], key, ifInt(status.showOpenOrders, 1, -1));
      Chart.StoreBool(key, status.showOpenOrders);
   }

   // bool status.showTradeHistory
   if (__isChart) {
      key = name +".status.showTradeHistory";
      SetWindowIntegerA(__ExecutionContext[EC.hChart], key, ifInt(status.showTradeHistory, 1, -1));
      Chart.StoreBool(key, status.showTradeHistory);
   }
   return(!catch("StoreVolatileData(1)"));
}


/**
 * Restore volatile runtime data from chart or chart window (for template reload, terminal restart, recompilation etc).
 *
 * @return bool - whether an instance id was successfully restored
 */
bool RestoreVolatileData() {
   string name = ProgramName();

   // input string Instance.ID
   while (true) {
      bool error = false;
      if (SetInstanceId(Instance.ID, error, "RestoreVolatileData(1)")) break;
      if (error) return(false);

      if (__isChart) {
         string key = name +".Instance.ID";
         string sValue = GetWindowStringA(__ExecutionContext[EC.hChart], key);
         if (SetInstanceId(sValue, error, "RestoreVolatileData(2)")) break;
         if (error) return(false);

         Chart.RestoreString(key, sValue, false);
         if (SetInstanceId(sValue, error, "RestoreVolatileData(3)")) break;
         return(false);
      }
   }

   // int status.activeMetric
   if (__isChart) {
      key = name +".status.activeMetric";
      while (true) {
         int iValue = GetWindowIntegerA(__ExecutionContext[EC.hChart], key);
         if (iValue != 0) {
            if (iValue > 0 && iValue <= 6) {                // valid metrics: 1-6
               status.activeMetric = iValue;
               break;
            }
         }
         if (Chart.RestoreInt(key, iValue, false)) {
            if (iValue > 0 && iValue <= 6) {
               status.activeMetric = iValue;
               break;
            }
         }
         logWarn("RestoreVolatileData(4)  "+ instance.name +"  invalid data: status.activeMetric="+ iValue);
         status.activeMetric = 1;                           // reset to default value
         break;
      }
   }

   // bool status.showOpenOrders
   if (__isChart) {
      key = name +".status.showOpenOrders";
      iValue = GetWindowIntegerA(__ExecutionContext[EC.hChart], key);
      if (iValue != 0) {
         status.showOpenOrders = (iValue > 0);
      }
      else if (!Chart.RestoreBool(key, status.showOpenOrders, false)) {
         status.showOpenOrders = false;                     // reset to default value
      }
   }

   // bool status.showTradeHistory
   if (__isChart) {
      key = name +".status.showTradeHistory";
      iValue = GetWindowIntegerA(__ExecutionContext[EC.hChart], key);
      if (iValue != 0) {
         status.showTradeHistory = (iValue > 0);
      }
      else if (!Chart.RestoreBool(key, status.showTradeHistory, false)) {
         status.showOpenOrders = false;                     // reset to default value
      }
   }
   return(true);
}


/**
 * Remove stored volatile runtime data from chart and chart window.
 *
 * @return bool - success status
 */
bool RemoveVolatileData() {
   string name = ProgramName();

   // input string Instance.ID
   if (__isChart) {
      string key = name +".Instance.ID";
      string sValue = RemoveWindowStringA(__ExecutionContext[EC.hChart], key);
      Chart.RestoreString(key, sValue, true);
   }

   // int status.activeMetric
   if (__isChart) {
      key = name +".status.activeMetric";
      int iValue = RemoveWindowIntegerA(__ExecutionContext[EC.hChart], key);
      Chart.RestoreInt(key, iValue, true);
   }

   // bool status.showOpenOrders
   if (__isChart) {
      key = name +".status.showOpenOrders";
      bool bValue = RemoveWindowIntegerA(__ExecutionContext[EC.hChart], key);
      Chart.RestoreBool(key, bValue, true);
   }

   // bool status.showTradeHistory
   if (__isChart) {
      key = name +".status.showTradeHistory";
      bValue = RemoveWindowIntegerA(__ExecutionContext[EC.hChart], key);
      Chart.RestoreBool(key, bValue, true);
   }

   // event object for chart commands
   if (__isChart) {
      key = "EA.status";
      if (ObjectFind(key) != -1) ObjectDelete(key);
   }
   return(!catch("RemoveVolatileData(1)"));
}


/**
 * Parse and set the passed instance id value. Format: "[T]123"
 *
 * @param  _In_    string value  - instance id value
 * @param  _InOut_ bool   error  - in:  mute parse errors (TRUE) or trigger a fatal error (FALSE)
 *                                 out: whether parse errors occurred (stored in last_error)
 * @param  _In_    string caller - caller identification (for error messages)
 *
 * @return bool - whether the instance id value was successfully set
 */
bool SetInstanceId(string value, bool &error, string caller) {
   string valueBak = value;
   bool muteErrors = error!=0;
   error = false;

   value = StrTrim(value);
   if (!StringLen(value)) return(false);

   bool isTest = false;
   int instanceId = 0;

   if (StrStartsWith(value, "T")) {
      isTest = true;
      value = StringTrimLeft(StrSubstr(value, 1));
   }

   if (!StrIsDigits(value)) {
      error = true;
      if (muteErrors) return(!SetLastError(ERR_INVALID_PARAMETER));
      return(!catch(caller +"->SetInstanceId(1)  invalid instance id value: \""+ valueBak +"\" (must be digits only)", ERR_INVALID_PARAMETER));
   }

   int iValue = StrToInteger(value);
   if (iValue < INSTANCE_ID_MIN || iValue > INSTANCE_ID_MAX) {
      error = true;
      if (muteErrors) return(!SetLastError(ERR_INVALID_PARAMETER));
      return(!catch(caller +"->SetInstanceId(2)  invalid instance id value: \""+ valueBak +"\" (range error)", ERR_INVALID_PARAMETER));
   }

   instance.isTest = isTest;
   instance.id     = iValue;
   Instance.ID     = ifString(IsTestInstance(), "T", "") + StrPadLeft(instance.id, 3, "0");
   SS.InstanceName();
   return(true);
}


/**
 * Virtual replacement for OrderSendEx().
 *
 * @param  _In_  int    type       - trade operation type
 * @param  _In_  double lots       - trade volume in lots
 * @param  _In_  double stopLoss   - stoploss price
 * @param  _In_  double takeProfit - takeprofit price
 * @param  _In_  color  marker     - color of the chart marker to set
 * @param  _Out_ int    &oe[]      - order execution details (struct ORDER_EXECUTION)
 *
 * @return int - resulting ticket or NULL in case of errors
 */
int VirtualOrderSend(int type, double lots, double stopLoss, double takeProfit, color marker, int &oe[]) {
   if (ArraySize(oe) != ORDER_EXECUTION_intSize) ArrayResize(oe, ORDER_EXECUTION_intSize);
   ArrayInitialize(oe, 0);

   if (type!=OP_BUY && type!=OP_SELL) return(!catch("VirtualOrderSend(1)  "+ instance.name +" invalid parameter type: "+ type, oe.setError(oe, ERR_INVALID_PARAMETER)));
   double openPrice = ifDouble(type, Bid, Ask);
   string comment = "ZigZag."+ StrPadLeft(instance.id, 3, "0");

   // generate a new ticket
   int ticket = open.ticket;
   int size = ArrayRange(history, 0);
   if (size > 0) ticket = Max(ticket, history[size-1][H_TICKET]);
   ticket++;

   // populate oe[]
   oe.setTicket    (oe, ticket);
   oe.setSymbol    (oe, Symbol());
   oe.setDigits    (oe, Digits);
   oe.setBid       (oe, Bid);
   oe.setAsk       (oe, Ask);
   oe.setType      (oe, type);
   oe.setLots      (oe, lots);
   oe.setOpenTime  (oe, Tick.time);
   oe.setOpenPrice (oe, openPrice);
   oe.setStopLoss  (oe, stopLoss);
   oe.setTakeProfit(oe, takeProfit);

   if (IsLogDebug()) {
      string sType  = OperationTypeDescription(type);
      string sLots  = NumberToStr(lots, ".+");
      string sPrice = NumberToStr(openPrice, PriceFormat);
      string sBid   = NumberToStr(Bid, PriceFormat);
      string sAsk   = NumberToStr(Ask, PriceFormat);
      logDebug("VirtualOrderSend(2)  "+ instance.name +" opened virtual #"+ ticket +" "+ sType +" "+ sLots +" "+ Symbol() +" \"."+ comment +"\" at "+ sPrice +" (market: "+ sBid +"/"+ sAsk +")");
   }
   if (__isChart && marker!=CLR_NONE) ChartMarker.OrderSent_B(ticket, Digits, marker, type, lots, Symbol(), Tick.time, openPrice, stopLoss, takeProfit, comment);
   if (!__isTesting)                  PlaySoundEx("OrderOk.wav");

   return(ticket);
}


/**
 * Virtual replacement for OrderCloseEx().
 *
 * @param  _In_  int    ticket - order ticket of the position to close
 * @param  _In_  double lots   - order size to close
 * @param  _In_  color  marker - color of the chart marker to set
 * @param  _Out_ int    &oe[]  - execution details (struct ORDER_EXECUTION)
 *
 * @return bool - success status
 */
bool VirtualOrderClose(int ticket, double lots, color marker, int &oe[]) {
   if (ArraySize(oe) != ORDER_EXECUTION_intSize) ArrayResize(oe, ORDER_EXECUTION_intSize);
   ArrayInitialize(oe, 0);

   if (ticket != open.ticket) return(!catch("VirtualOrderClose(1)  "+ instance.name +" parameter ticket/open.ticket mis-match: "+ ticket +"/"+ open.ticket, oe.setError(oe, ERR_INVALID_PARAMETER)));
   double closePrice = ifDouble(open.type==OP_BUY, Bid, Ask);
   double profit = NormalizeDouble(ifDouble(open.type==OP_BUY, closePrice-open.price, open.price-closePrice) * PointValue(lots), 2);

   // populate oe[]
   oe.setTicket    (oe, ticket);
   oe.setSymbol    (oe, Symbol());
   oe.setDigits    (oe, Digits);
   oe.setBid       (oe, Bid);
   oe.setAsk       (oe, Ask);
   oe.setType      (oe, open.type);
   oe.setLots      (oe, lots);
   oe.setOpenTime  (oe, open.time);
   oe.setOpenPrice (oe, open.price);
   oe.setCloseTime (oe, Tick.time);
   oe.setClosePrice(oe, closePrice);
   oe.setProfit    (oe, profit);

   if (IsLogDebug()) {
      string sType       = OperationTypeDescription(open.type);
      string sLots       = NumberToStr(lots, ".+");
      string sOpenPrice  = NumberToStr(open.price, PriceFormat);
      string sClosePrice = NumberToStr(closePrice, PriceFormat);
      string sBid        = NumberToStr(Bid, PriceFormat);
      string sAsk        = NumberToStr(Ask, PriceFormat);
      logDebug("VirtualOrderClose(2)  "+ instance.name +" closed virtual #"+ ticket +" "+ sType +" "+ sLots +" "+ Symbol() +" \"ZigZag."+ StrPadLeft(instance.id, 3, "0") +"\" from "+ sOpenPrice +" at "+ sClosePrice +" (market: "+ sBid +"/"+ sAsk +")");
   }
   if (__isChart && marker!=CLR_NONE) ChartMarker.PositionClosed_B(ticket, Digits, marker, open.type, lots, Symbol(), open.time, open.price, Tick.time, closePrice);
   if (!__isTesting)                  PlaySoundEx("OrderOk.wav");

   return(true);
}


/**
 * ShowStatus: Update all string representations.
 */
void SS.All() {
   SS.InstanceName();
   SS.StartStopConditions();
   SS.Metric();
   SS.OpenLots();
   SS.ClosedTrades();
   SS.TotalProfit();
   SS.ProfitStats();
}


/**
 * ShowStatus: Update the string representation of the instance name.
 */
void SS.InstanceName() {
   instance.name = "Z."+ StrPadLeft(instance.id, 3, "0");

   switch (tradingMode) {
      case TRADINGMODE_REGULAR:
         break;
      case TRADINGMODE_VIRTUAL:
         instance.name = "V"+ instance.name;
         break;
   }
}


/**
 * ShowStatus: Update the string representation of the configured start/stop conditions.
 */
void SS.StartStopConditions() {
   if (__isChart) {
      // start conditions
      string sValue = "";
      if (start.time.description != "") {
         sValue = sValue + ifString(sValue=="", "", " | ") + ifString(start.time.condition, "@", "!") + start.time.description;
      }
      if (sValue == "") sStartConditions = "-";
      else              sStartConditions = sValue;

      // stop conditions
      sValue = "";
      if (stop.time.description != "") {
         sValue = sValue + ifString(sValue=="", "", " | ") + ifString(stop.time.condition, "@", "!") + stop.time.description;
      }
      if (stop.profitAbs.description != "") {
         sValue = sValue + ifString(sValue=="", "", " | ") + ifString(stop.profitAbs.condition, "@", "!") + stop.profitAbs.description;
      }
      if (stop.profitPct.description != "") {
         sValue = sValue + ifString(sValue=="", "", " | ") + ifString(stop.profitPct.condition, "@", "!") + stop.profitPct.description;
      }
      if (stop.profitPun.description != "") {
         sValue = sValue + ifString(sValue=="", "", " | ") + ifString(stop.profitPun.condition, "@", "!") + stop.profitPun.description;
      }
      if (sValue == "") sStopConditions = "-";
      else              sStopConditions = sValue;
   }
}


/**
 * ShowStatus: Update the description of the displayed metric.
 */
void SS.Metric() {
   switch (status.activeMetric) {
      case METRIC_TOTAL_NET_MONEY:
         sMetric = "Net PnL after all costs in "+ AccountCurrency() + NL + "-----------------------------------";
         break;
      case METRIC_TOTAL_NET_UNITS:
         sMetric = "Net PnL after all costs in "+ pUnit + NL + "---------------------------------"+ ifString(pUnit=="point", "---", "");
         break;
      case METRIC_TOTAL_SYNTH_UNITS:
         sMetric = "Synthetic PnL before spread/any costs in "+ pUnit + NL + "------------------------------------------------------"+ ifString(pUnit=="point", "--", "");
         break;

      default: return(!catch("SS.MetricDescription(1)  "+ instance.name +" illegal value of status.activeMetric: "+ status.activeMetric, ERR_ILLEGAL_STATE));
   }
}


/**
 * ShowStatus: Update the string representation of the open position size.
 */
void SS.OpenLots() {
   if      (!open.lots)           sOpenLots = "-";
   else if (open.type == OP_LONG) sOpenLots = "+"+ NumberToStr(open.lots, ".+") +" lot";
   else                           sOpenLots = "-"+ NumberToStr(open.lots, ".+") +" lot";
}


/**
 * ShowStatus: Update the string summary of the closed trades.
 */
void SS.ClosedTrades() {
   int size = ArrayRange(history, 0);
   if (!size) {
      sClosedTrades = "-";
   }
   else {
      if (!stats[0][S_TRADES]) CalculateTradeStats();

      switch (status.activeMetric) {
         case METRIC_TOTAL_NET_MONEY:
            sClosedTrades = size +" trades    avg: "+ NumberToStr(stats[METRIC_TOTAL_NET_MONEY][S_TRADES_AVG], "R+.2") +" "+ AccountCurrency();
            break;
         case METRIC_TOTAL_NET_UNITS:
            sClosedTrades = size +" trades    avg: "+ NumberToStr(stats[METRIC_TOTAL_NET_UNITS][S_TRADES_AVG] * pMultiplier, "R+."+ pDigits) +" "+ pUnit;
            break;
         case METRIC_TOTAL_SYNTH_UNITS:
            sClosedTrades = size +" trades    avg: "+ NumberToStr(stats[METRIC_TOTAL_SYNTH_UNITS][S_TRADES_AVG] * pMultiplier, "R+."+ pDigits) +" "+ pUnit;
            break;

         default: return(!catch("SS.ClosedTrades(1)  "+ instance.name +" illegal value of status.activeMetric: "+ status.activeMetric, ERR_ILLEGAL_STATE));
      }
   }
}


/**
 * ShowStatus: Update the string representation of the total instance PnL.
 */
void SS.TotalProfit() {
   // not before a position was opened
   if (!open.ticket && !ArrayRange(history, 0)) {
      sTotalProfit = "-";
   }
   else {
      switch (status.activeMetric) {
         case METRIC_TOTAL_NET_MONEY:
            if (ShowProfitInPercent) sTotalProfit = NumberToStr(MathDiv(instance.totalNetProfit, instance.startEquity) * 100, "R+.2") +"%";
            else                     sTotalProfit = NumberToStr(instance.totalNetProfit, "R+.2") +" "+ AccountCurrency();
            break;
         case METRIC_TOTAL_NET_UNITS:
            sTotalProfit = NumberToStr(instance.totalNetProfitP * pMultiplier, "R+."+ pDigits) +" "+ pUnit;
            break;
         case METRIC_TOTAL_SYNTH_UNITS:
            sTotalProfit = NumberToStr(instance.totalSynthProfitP * pMultiplier, "R+."+ pDigits) +" "+ pUnit;
            break;

         default: return(!catch("SS.TotalProfit(1)  "+ instance.name +" illegal value of status.activeMetric: "+ status.activeMetric, ERR_ILLEGAL_STATE));
      }
   }
}


/**
 * ShowStatus: Update the string representaton of the PnL statistics.
 */
void SS.ProfitStats() {
   // not before a position was opened
   if (!open.ticket && !ArrayRange(history, 0)) {
      sProfitStats = "";
   }
   else {
      string sMaxProfit="", sMaxDrawdown="";

      switch (status.activeMetric) {
         case METRIC_TOTAL_NET_MONEY:
            if (ShowProfitInPercent) {
               sMaxProfit   = NumberToStr(MathDiv(instance.maxNetProfit,   instance.startEquity) * 100, "R+.2");
               sMaxDrawdown = NumberToStr(MathDiv(instance.maxNetDrawdown, instance.startEquity) * 100, "R+.2");
            }
            else {
               sMaxProfit   = NumberToStr(instance.maxNetProfit,   "R+.2");
               sMaxDrawdown = NumberToStr(instance.maxNetDrawdown, "R+.2");
            }
            break;
         case METRIC_TOTAL_NET_UNITS:
            sMaxProfit   = NumberToStr(instance.maxNetProfitP   * pMultiplier, "R+."+ pDigits);
            sMaxDrawdown = NumberToStr(instance.maxNetDrawdownP * pMultiplier, "R+."+ pDigits);
            break;
         case METRIC_TOTAL_SYNTH_UNITS:
            sMaxProfit   = NumberToStr(instance.maxSynthProfitP   * pMultiplier, "R+."+ pDigits);
            sMaxDrawdown = NumberToStr(instance.maxSynthDrawdownP * pMultiplier, "R+."+ pDigits);
            break;

         default: return(!catch("SS.ProfitStats(1)  "+ instance.name +" illegal value of status.activeMetric: "+ status.activeMetric, ERR_ILLEGAL_STATE));
      }
      sProfitStats = StringConcatenate("(", sMaxDrawdown, "/", sMaxProfit, ")");
   }
}



/**
 * Display the current runtime status.
 *
 * @param  int error [optional] - error to display (default: none)
 *
 * @return int - the same error or the current error status if no error was specified
 */
int ShowStatus(int error = NO_ERROR) {
   if (!__isChart) return(error);

   static bool isRecursion = false;                   // to prevent recursive calls a specified error is displayed only once
   if (error != 0) {
      if (isRecursion) return(error);
      isRecursion = true;
   }
   string sStatus="", sError="";

   switch (instance.status) {
      case NULL:               sStatus = StringConcatenate(instance.name, "  not initialized"); break;
      case STATUS_WAITING:     sStatus = StringConcatenate(instance.name, "  waiting");         break;
      case STATUS_PROGRESSING: sStatus = StringConcatenate(instance.name, "  progressing");     break;
      case STATUS_STOPPED:     sStatus = StringConcatenate(instance.name, "  stopped");         break;
      default:
         return(catch("ShowStatus(1)  "+ instance.name +" illegal instance status: "+ instance.status, ERR_ILLEGAL_STATE));
   }
   if (__STATUS_OFF) sError = StringConcatenate("  [switched off => ", ErrorDescription(__STATUS_OFF.reason), "]");

   string text = StringConcatenate(sTradingModeStatus[tradingMode], ProgramName(), "    ", sStatus, sError, NL,
                                                                                                            NL,
                                  "Start:    ",  sStartConditions,                                          NL,
                                  "Stop:     ",  sStopConditions,                                           NL,
                                                                                                            NL,
                                   sMetric,                                                                 NL,
                                  "Open:    ",   sOpenLots,                                                 NL,
                                  "Closed:  ",   sClosedTrades,                                             NL,
                                  "Profit:    ", sTotalProfit, "  ", sProfitStats,                          NL
   );

   // 3 lines margin-top for instrument and indicator legends
   Comment(NL, NL, NL, text);
   if (__CoreFunction == CF_INIT) WindowRedraw();

   // store status in the chart to enable sending of chart commands
   string label = "EA.status";
   if (ObjectFind(label) != 0) {
      ObjectCreate(label, OBJ_LABEL, 0, 0, 0);
      ObjectSet(label, OBJPROP_TIMEFRAMES, OBJ_PERIODS_NONE);
   }
   ObjectSetText(label, StringConcatenate(Instance.ID, "|", StatusDescription(instance.status)));

   error = intOr(catch("ShowStatus(2)"), error);
   isRecursion = false;
   return(error);
}


/**
 * Return a string representation of the input parameters (for logging purposes).
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("Instance.ID=",          DoubleQuoteStr(Instance.ID),     ";", NL,
                            "TradingMode=",          DoubleQuoteStr(TradingMode),     ";", NL,
                            "ZigZag.Periods=",       ZigZag.Periods,                  ";", NL,
                            "Lots=",                 NumberToStr(Lots, ".1+"),        ";", NL,
                            "StartConditions=",      DoubleQuoteStr(StartConditions), ";", NL,
                            "StopConditions=",       DoubleQuoteStr(StopConditions),  ";", NL,
                            "TakeProfit=",           NumberToStr(TakeProfit, ".1+"),  ";", NL,
                            "TakeProfit.Type=",      DoubleQuoteStr(TakeProfit.Type), ";", NL,
                            "ShowProfitInPercent=",  BoolToStr(ShowProfitInPercent),  ";")
   );
}