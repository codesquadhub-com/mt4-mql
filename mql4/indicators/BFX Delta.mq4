/**
 * BFX Delta
 *
 * Displays oscillator values calculated by the fraudulent BankersFX Core Volume indicator.
 *
 *
 * Indicator buffers for iCustom():
 *  � MODE_DELTA_MAIN:   delta values
 *  � MODE_DELTA_SIGNAL: delta direction and periods since last crossing of the opposite signal level
 *    - direction: positive values represent a delta above the negative signal level (+1...+n),
 *                 negative values represent a delta below the positive signal level (-1...-n)
 *    - length:    the absolute value is the period in bars since the last crossing of the opposite signal level
 *
 * @see  https://github.com/rosasurfer/bfx-core-volume
 */
#include <stddefines.mqh>
int   __InitFlags[];
int __DeinitFlags[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////

extern color  Histogram.Color.Long  = LimeGreen;
extern color  Histogram.Color.Short = Red;
extern int    Histogram.Style.Width = 2;

extern int    Max.Bars              = 10000;                   // max. values to calculate (-1: all available)

extern string __________________________;

extern int    Signal.Level          = 20;
extern string Signal.onLevelCross   = "on | off | auto*";
extern string Signal.Sound          = "on | off | auto*";
extern string Signal.Mail.Receiver  = "on | off | auto* | {email-address}";
extern string Signal.SMS.Receiver   = "on | off | auto* | {phone-number}";

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/indicator.mqh>
#include <stdfunctions.mqh>
#include <rsfLibs.mqh>
#include <functions/BarOpenEvent.mqh>
#include <functions/ConfigureSignal.mqh>
#include <functions/ConfigureSignalMail.mqh>
#include <functions/ConfigureSignalSMS.mqh>
#include <functions/ConfigureSignalSound.mqh>

#define MODE_DELTA_MAIN       0                                // this indicator's buffer ids
#define MODE_DELTA_SIGNAL     1
#define MODE_DELTA_LONG       2
#define MODE_DELTA_SHORT      3

#define MODE_CVI_LONG         0                                // the Core Volume indicator's buffer ids
#define MODE_CVI_SHORT        1
#define MODE_CVI_SIGNAL       2

#property indicator_separate_window
#property indicator_buffers   4

#property indicator_width1    0
#property indicator_width2    0
#property indicator_width3    2
#property indicator_width4    2

double bufferMain  [];                                         // all values:           invisible, displayed in "Data" window
double bufferSignal[];                                         // direction and length: invisible
double bufferLong  [];                                         // long values:          visible
double bufferShort [];                                         // short values:         visible

string indicatorName;                                          // "Data" window and signal notification name
string bfxName = ".attic/BFX Core Volume v1.20.0";             // BFX indicator name
string bfxLicense;                                             // BFX indicator license

bool   signals;
bool   signal.sound;
string signal.sound.levelCross.long  = "Signal-Up.wav";
string signal.sound.levelCross.short = "Signal-Down.wav";
bool   signal.mail;
string signal.mail.sender   = "";
string signal.mail.receiver = "";
bool   signal.sms;
string signal.sms.receiver = "";


/**
 * Initialization
 *
 * @return int - error status
 */
int onInit() {
   if (ProgramInitReason() == IR_RECOMPILE) {
      if (!RestoreInputParameters()) return(last_error);
   }

   // (1) input validation
   // colors: after deserialization the terminal might turn CLR_NONE (0xFFFFFFFF) into Black (0xFF000000)
   if (Histogram.Color.Long  == 0xFF000000) Histogram.Color.Long  = CLR_NONE;
   if (Histogram.Color.Short == 0xFF000000) Histogram.Color.Short = CLR_NONE;

   // styles
   if (Histogram.Style.Width < 0) return(catch("onInit(1)  Invalid input parameter Histogram.Style.Width = "+ Histogram.Style.Width, ERR_INVALID_INPUT_PARAMETER));
   if (Histogram.Style.Width > 5) return(catch("onInit(2)  Invalid input parameter Histogram.Style.Width = "+ Histogram.Style.Width, ERR_INVALID_INPUT_PARAMETER));

   // Max.Bars
   if (Max.Bars < -1)             return(catch("onInit(3)  Invalid input parameter Max.Bars = "+ Max.Bars, ERR_INVALID_INPUT_PARAMETER));

   // Signal.Level
   if (Signal.Level <    0)       return(catch("onInit(4)  Invalid input parameter Signal.Level = "+ Signal.Level, ERR_INVALID_INPUT_PARAMETER));
   if (Signal.Level >= 100)       return(catch("onInit(5)  Invalid input parameter Signal.Level = "+ Signal.Level, ERR_INVALID_INPUT_PARAMETER));

   // signal configuration
   if (!ConfigureSignal("BFXDelta", Signal.onLevelCross, signals))                                            return(last_error);
   if (signals) {
      if (!ConfigureSignalSound(Signal.Sound,         signal.sound                                         )) return(last_error);
      if (!ConfigureSignalMail (Signal.Mail.Receiver, signal.mail, signal.mail.sender, signal.mail.receiver)) return(last_error);
      if (!ConfigureSignalSMS  (Signal.SMS.Receiver,  signal.sms,                      signal.sms.receiver )) return(last_error);
      if (!signal.sound && !signal.mail && !signal.sms)
         signals = false;
   }


   // (2) check BFX indicator and license for existence
   string indicatorFile = GetMqlDirectoryA() +"\\indicators\\"+ bfxName +".ex4";
   if (!IsFileA(indicatorFile))   return(catch("onInit(6)  BankersFX Core Volume indicator not found: "+ DoubleQuoteStr(indicatorFile), ERR_FILE_NOT_FOUND));

   string section = "bankersfx.com", key = "CoreVolume.License";
   bfxLicense = GetConfigString(section, key);
   if (!StringLen(bfxLicense))    return(!catch("onInit(7)  missing configuration value ["+ section +"]->"+ key, ERR_INVALID_CONFIG_VALUE));


   // (3) setup buffer management
   SetIndexBuffer(MODE_DELTA_MAIN,   bufferMain  );            // all values:           invisible, displayed in "Data" window
   SetIndexBuffer(MODE_DELTA_SIGNAL, bufferSignal);            // direction and length: invisible
   SetIndexBuffer(MODE_DELTA_LONG,   bufferLong  );            // long values:          visible
   SetIndexBuffer(MODE_DELTA_SHORT,  bufferShort );            // short values:         visible


   // (4) data display configuration, names and labels
   indicatorName = ProgramName();
   string signalInfo = ifString(signals, "   onLevel("+ Signal.Level +")="+ StrSubstr(ifString(signal.sound, ", Sound", "") + ifString(signal.mail, ", Mail", "") + ifString(signal.sms, ", SMS", ""), 2), "");
   IndicatorShortName(indicatorName + signalInfo +"  ");       // chart subwindow and context menu
   SetIndexLabel(MODE_DELTA_MAIN,   indicatorName);            // chart tooltips and "Data" window
   SetIndexLabel(MODE_DELTA_SIGNAL, NULL);
   SetIndexLabel(MODE_DELTA_LONG,   NULL);
   SetIndexLabel(MODE_DELTA_SHORT,  NULL);
   IndicatorDigits(2);


   // (5) drawing options and styles
   int startDraw = 0;
   if (Max.Bars >= 0)
      startDraw = Max(startDraw, Bars-Max.Bars);
   SetIndexDrawBegin(MODE_DELTA_LONG,  startDraw);
   SetIndexDrawBegin(MODE_DELTA_SHORT, startDraw);
   SetIndicatorOptions();

   return(catch("onInit(8)"));
}


/**
 * Called before recompilation.
 *
 * @return int - error status
 */
int onDeinitRecompile() {
   StoreInputParameters();
   return(last_error);
}


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   // wait for account number initialization (required for BFX license validation)
   if (!AccountNumber())
      return(logInfo("onInit(1)  waiting for account number initialization", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // on the first tick after terminal start buffers may not yet be initialized (spurious issue)
   if (!ArraySize(bufferMain)) return(logInfo("onTick(2)  size(bufferMain) = 0", SetLastError(ERS_TERMINAL_NOT_YET_READY)));

   // reset all buffers and delete garbage behind Max.Bars before doing a full recalculation
   if (!UnchangedBars) {
      ArrayInitialize(bufferMain,   EMPTY_VALUE);
      ArrayInitialize(bufferSignal,           0);
      ArrayInitialize(bufferLong,   EMPTY_VALUE);
      ArrayInitialize(bufferShort,  EMPTY_VALUE);
      SetIndicatorOptions();
   }

   // synchronize buffers with a shifted offline chart
   if (ShiftedBars > 0) {
      ShiftIndicatorBuffer(bufferMain,   Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferSignal, Bars, ShiftedBars,           0);
      ShiftIndicatorBuffer(bufferLong,   Bars, ShiftedBars, EMPTY_VALUE);
      ShiftIndicatorBuffer(bufferShort,  Bars, ShiftedBars, EMPTY_VALUE);
   }


   // (1) calculate start bar
   int changedBars = ChangedBars;
   if (Max.Bars >= 0) /*&&*/ if (changedBars > Max.Bars)
      changedBars = Max.Bars;
   int startBar = changedBars-1;
   if (startBar < 0) return(logInfo("onTick(3)  Tick="+ Tick, ERR_HISTORY_INSUFFICIENT));


   // (2) recalculate changed bars
   double delta;
   for (int bar=startBar; bar >= 0; bar--) {
      bufferLong [bar] = GetBfxCoreVolume(MODE_CVI_LONG, bar);  if (last_error != NO_ERROR) return(last_error);
      bufferShort[bar] = GetBfxCoreVolume(MODE_CVI_SHORT, bar); if (last_error != NO_ERROR) return(last_error);

      delta = EMPTY_VALUE;
      if      (bufferLong [bar] != EMPTY_VALUE) delta = bufferLong [bar];
      else if (bufferShort[bar] != EMPTY_VALUE) delta = bufferShort[bar];
      bufferMain[bar] = delta;

      // update signal level and duration since last crossing of the opposite level
      if (bar < Bars-1 && delta!=EMPTY_VALUE) {
         // if the last signal was up
         if (bufferSignal[bar+1] > 0) {
            if (delta > -Signal.Level) bufferSignal[bar] = bufferSignal[bar+1] + 1; // continuation up
            else                       bufferSignal[bar] = -1;                      // opposite signal (down)
         }

         // if the last signal was down
         else if (bufferSignal[bar+1] < 0) {
            if (delta < Signal.Level) bufferSignal[bar] = bufferSignal[bar+1] - 1;  // continuation down
            else                      bufferSignal[bar] = 1;                        // opposite signal (up)
         }

         // if there was no signal yet
         else /*(bufferSignal[bar+1] == 0)*/ {
            if      (delta >=  Signal.Level) bufferSignal[bar] =  1;                // first signal up
            else if (delta <= -Signal.Level) bufferSignal[bar] = -1;                // first signal down
            else                             bufferSignal[bar] =  0;                // still no signal
         }
      }
   }

   // signal zero line crossings
   if (signals) /*&&*/ if (!IsSuperContext()) /*&&*/ if (IsBarOpenEvent()) {
      if      (bufferSignal[1] ==  1) onLevelCross(MODE_UPPER);
      else if (bufferSignal[1] == -1) onLevelCross(MODE_LOWER);
   }
   return(last_error);
}


/**
 * Event handler called on BarOpen if delta crossed the signal level.
 *
 * @param  int mode - direction identifier: MODE_UPPER | MODE_LOWER
 *
 * @return bool - success status
 */
bool onLevelCross(int mode) {
   string message = "";
   int error = 0;

   if (mode == MODE_UPPER) {
      message = indicatorName +" crossed level "+ Signal.Level;
      logInfo("onLevelCross(1)  "+ message);
      message = Symbol() +","+ PeriodDescription(Period()) +": "+ message;

      if (signal.sound) error |= !PlaySoundEx(signal.sound.levelCross.long);
      if (signal.mail)  error |= !SendEmail(signal.mail.sender, signal.mail.receiver, message, message);  // subject = body
      if (signal.sms)   error |= !SendSMS(signal.sms.receiver, message);
      return(!error);
   }

   if (mode == MODE_LOWER) {
      message = indicatorName +" crossed level "+ (-Signal.Level);
      logInfo("onLevelCross(2)  "+ message);
      message = Symbol() +","+ PeriodDescription(Period()) +": "+ message;

      if (signal.sound) error |= !PlaySoundEx(signal.sound.levelCross.short);
      if (signal.mail)  error |= !SendEmail(signal.mail.sender, signal.mail.receiver, message, message);  // subject = body
      if (signal.sms)   error |= !SendSMS(signal.sms.receiver, message);
      return(!error);
   }

   return(!catch("onLevelCross(3)  invalid parameter mode = "+ mode, ERR_INVALID_PARAMETER));
}


/**
 * Load the BFX Core Volume indicator and return an indicator value.
 *
 * @param  int buffer - buffer index of the value to return
 * @param  int bar    - bar index of the value to return
 *
 * @return double - indicator value or NULL in case of errors (short values are returned as negative values)
 */
double GetBfxCoreVolume(int buffer, int bar) {
   string separator      = "�����������������������������������"; // title1         init() error if an empty string
 //string bfxLicense     = ...                                    // UserID
   int    serverId       = 0;                                     // ServerURL
   int    loginTries     = 1;                                     // Retries        minimum = 1 (in fact tries, not retries)
   string symbolPrefix   = "";                                    // Prefix
   string symbolSuffix   = "";                                    // Suffix
   color  colorLong      = Red;                                   // PositiveState
   color  colorShort     = Green;                                 // NegativeState
   color  colorLevel     = Gray;                                  // Level
   int    histogramWidth = 2;                                     // WidthStateBars
   bool   signalAlert    = false;                                 // Alerts
   bool   signalPopup    = false;                                 // PopUp
   bool   signalSound    = false;                                 // Sound
   bool   signalMobile   = false;                                 // Mobile
   bool   signalEmail    = false;                                 // Email

   int error;

   // check indicator initialization with signal level on bar 0
   static bool initialized = false; if (!initialized) {
      double level = iCustom(NULL, NULL, bfxName,
                             separator, bfxLicense, serverId, loginTries, symbolPrefix, symbolSuffix, colorLong, colorShort, colorLevel, histogramWidth, signalAlert, signalPopup, signalSound, signalMobile, signalEmail,
                             MODE_CVI_SIGNAL, 0);
      if (level == EMPTY_VALUE) {
         error = GetLastError();
         return(!catch("GetBfxCoreVolume(1)  initialization of indicator "+ DoubleQuoteStr(bfxName) +" failed", ifInt(error, error, ERR_CUSTOM_INDICATOR_ERROR)));
      }
      initialized = true;
   }

   // get the requested value
   double value = iCustom(NULL, NULL, bfxName,
                          separator, bfxLicense, serverId, loginTries, symbolPrefix, symbolSuffix, colorLong, colorShort, colorLevel, histogramWidth, signalAlert, signalPopup, signalSound, signalMobile, signalEmail,
                          buffer, bar);

   if (buffer == MODE_CVI_SHORT) {
      if (value != EMPTY_VALUE)
         value = -value;                                          // convert short values to negative values
   }

   error = GetLastError();
   if (error != NO_ERROR)
      return(!catch("GetBfxCoreVolume(2)", error));
   return(value);
}


/**
 * Workaround for various terminal bugs when setting indicator options. Usually options are set in init(). However after
 * recompilation options must be set in start() to not be ignored.
 */
void SetIndicatorOptions() {
   IndicatorBuffers(indicator_buffers);

   int drawType = ifInt(Histogram.Style.Width, DRAW_HISTOGRAM, DRAW_NONE);

   SetIndexStyle(MODE_DELTA_MAIN,   DRAW_NONE, EMPTY, EMPTY,                 CLR_NONE             );
   SetIndexStyle(MODE_DELTA_SIGNAL, DRAW_NONE, EMPTY, EMPTY,                 CLR_NONE             );
   SetIndexStyle(MODE_DELTA_LONG,   drawType,  EMPTY, Histogram.Style.Width, Histogram.Color.Long );
   SetIndexStyle(MODE_DELTA_SHORT,  drawType,  EMPTY, Histogram.Style.Width, Histogram.Color.Short);

   SetLevelValue(0,  Signal.Level);
   SetLevelValue(1, -Signal.Level);
}


/**
 * Store input parameters in the chart before recompilation.
 *
 * @return bool - success status
 */
bool StoreInputParameters() {
   string name = ProgramName();
   Chart.StoreColor (name +".input.Histogram.Color.Long",  Histogram.Color.Long );
   Chart.StoreColor (name +".input.Histogram.Color.Short", Histogram.Color.Short);
   Chart.StoreInt   (name +".input.Histogram.Style.Width", Histogram.Style.Width);
   Chart.StoreInt   (name +".input.Max.Bars",              Max.Bars             );
   Chart.StoreInt   (name +".input.Signal.Level",          Signal.Level         );
   Chart.StoreString(name +".input.Signal.onLevelCross",   Signal.onLevelCross  );
   Chart.StoreString(name +".input.Signal.Sound",          Signal.Sound         );
   Chart.StoreString(name +".input.Signal.Mail.Receiver",  Signal.Mail.Receiver );
   Chart.StoreString(name +".input.Signal.SMS.Receiver",   Signal.SMS.Receiver  );
   return(!catch("StoreInputParameters(1)"));
}


/**
 * Restore input parameters found in the chart after recompilation.
 *
 * @return bool - success status
 */
bool RestoreInputParameters() {
   string name = ProgramName();
   Chart.RestoreColor (name +".input.Histogram.Color.Long",  Histogram.Color.Long );
   Chart.RestoreColor (name +".input.Histogram.Color.Short", Histogram.Color.Short);
   Chart.RestoreInt   (name +".input.Histogram.Style.Width", Histogram.Style.Width);
   Chart.RestoreInt   (name +".input.Max.Bars",              Max.Bars             );
   Chart.RestoreInt   (name +".input.Signal.Level",          Signal.Level         );
   Chart.RestoreString(name +".input.Signal.onLevelCross",   Signal.onLevelCross  );
   Chart.RestoreString(name +".input.Signal.Sound",          Signal.Sound         );
   Chart.RestoreString(name +".input.Signal.Mail.Receiver",  Signal.Mail.Receiver );
   Chart.RestoreString(name +".input.Signal.SMS.Receiver",   Signal.SMS.Receiver  );
   return(!catch("RestoreInputParameters(1)"));
}


/**
 * Return a string representation of the input parameters (for logging purposes).
 *
 * @return string
 */
string InputsToStr() {
   return(StringConcatenate("Histogram.Color.Long=",  ColorToStr(Histogram.Color.Long),     ";", NL,
                            "Histogram.Color.Short=", ColorToStr(Histogram.Color.Short),    ";", NL,
                            "Histogram.Style.Width=", Histogram.Style.Width,                ";", NL,
                            "Max.Bars=",              Max.Bars,                             ";", NL,
                            "Signal.Level=",          Signal.Level,                         ";", NL,
                            "Signal.onLevelCross=",   DoubleQuoteStr(Signal.onLevelCross),  ";", NL,
                            "Signal.Sound=",          DoubleQuoteStr(Signal.Sound),         ";", NL,
                            "Signal.Mail.Receiver=",  DoubleQuoteStr(Signal.Mail.Receiver), ";", NL,
                            "Signal.SMS.Receiver=",   DoubleQuoteStr(Signal.SMS.Receiver),  ";")
   );
}
