/**
 * Overview of available functions grouped by location, including MT4Expander DLL functions.
 * Useful if the development environment provides no cTags functionality.
 *
 * Notes:
 *  - This file cannot be used as source code.
 *  - The trailing double-semicolon is specific to UEStudio and activates the UEStudio function browser.
 */


// include/configuration.mqh
string   GetAccountConfigPath(string companyId = "", string accountId = "");;

bool     IsConfigKey              (string section, string key);;
bool     IsAccountConfigKey       (string section, string key);;

bool     GetConfigBool            (string section, string key, bool defaultValue = false);;
bool     GetGlobalConfigBool      (string section, string key, bool defaultValue = false);;
bool     GetLocalConfigBool       (string section, string key, bool defaultValue = false);;
bool     GetAccountConfigBool     (string section, string key, bool defaultValue = false);;

color    GetConfigColor           (string section, string key, color defaultValue = CLR_NONE);;
color    GetGlobalConfigColor     (string section, string key, color defaultValue = CLR_NONE);;
color    GetLocalConfigColor      (string section, string key, color defaultValue = CLR_NONE);;
color    GetAccountConfigColor    (string section, string key, color defaultValue = CLR_NONE);;

int      GetConfigInt             (string section, string key, int defaultValue = 0);;
int      GetGlobalConfigInt       (string section, string key, int defaultValue = 0);;
int      GetLocalConfigInt        (string section, string key, int defaultValue = 0);;
int      GetAccountConfigInt      (string section, string key, int defaultValue = 0);;

double   GetConfigDouble          (string section, string key, double defaultValue = 0);;
double   GetGlobalConfigDouble    (string section, string key, double defaultValue = 0);;
double   GetLocalConfigDouble     (string section, string key, double defaultValue = 0);;
double   GetAccountConfigDouble   (string section, string key, double defaultValue = 0);;

string   GetConfigString          (string section, string key, string defaultValue = "");;
string   GetGlobalConfigString    (string section, string key, string defaultValue = "");;
string   GetLocalConfigString     (string section, string key, string defaultValue = "");;
string   GetAccountConfigString   (string section, string key, string defaultValue = "");;

string   GetConfigStringRaw       (string section, string key, string defaultValue = "");;
string   GetGlobalConfigStringRaw (string section, string key, string defaultValue = "");;
string   GetLocalConfigStringRaw  (string section, string key, string defaultValue = "");;
string   GetAccountConfigStringRaw(string section, string key, string defaultValue = "");;

bool     GetIniBool  (string fileName, string section, string key, bool   defaultValue = false);;
color    GetIniColor (string fileName, string section, string key, color  defaultValue = CLR_NONE);;
int      GetIniInt   (string fileName, string section, string key, int    defaultValue = 0);;
double   GetIniDouble(string fileName, string section, string key, double defaultValue = 0);;

bool     DeleteIniKey(string fileName, string section, string key);;


// include/scriptrunner.mqh
bool     RunScript(string name, string parameters = "");;
bool     ScriptRunner.GetParameters(string parameters[]);;
bool     ScriptRunner.SetParameters(string parameters);;


// include/stdfunctions.mqh
bool     __CHART();;
bool     __LOG();;
string   __NAME();;
bool     _bool       (bool   param1,      int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
double   _double     (double param1,      int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      _EMPTY      (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
string   _EMPTY_STR  (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      _EMPTY_VALUE(int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
bool     _false      (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      _int        (int    param1,      int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      _last_error (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
datetime _NaT        (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      _NO_ERROR   (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      _NULL       (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
string   _string     (string param1,      int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
bool     _true       (int    param1=NULL, int param2=NULL, int param3=NULL, int param4=NULL, int param5=NULL, int param6=NULL, int param7=NULL, int param8=NULL);;
int      Abs(int value);;
string   AccountAlias(string accountCompany, int accountNumber);;
int      AccountCompanyId(string shortName);;
int      AccountNumberFromAlias(string accountCompany, string accountAlias);;
int      ArrayUnshiftString(string array[], string value);;
int      catch(string location, int error=NO_ERROR, bool orderPop=false);;
int      Ceil(double value);;
bool     Chart.DeleteValue(string key);;
int      Chart.Expert.Properties();;
int      Chart.Objects.UnselectAll();;
int      Chart.Refresh();;
bool     Chart.RestoreBool  (string key, bool   &var);;
bool     Chart.RestoreColor (string key, color  &var);;
bool     Chart.RestoreDouble(string key, double &var);;
bool     Chart.RestoreInt   (string key, int    &var);;
bool     Chart.RestoreString(string key, string &var);;
int      Chart.SendTick(bool sound = false);;
bool     Chart.StoreBool  (string key, bool   value);;
bool     Chart.StoreColor (string key, color  value);;
bool     Chart.StoreDouble(string key, double value);;
bool     Chart.StoreInt   (string key, int    value);;
bool     Chart.StoreString(string key, string value);;
string   ColorToHtmlStr(color value);;
string   ColorToRGBStr(color value);;
string   ColorToStr(color value);;
void     CopyMemory(int destination, int source, int bytes);;
int      CountDecimals(double number);;
string   CreateString(int length);;
datetime DateTime(int year, int month=1, int day=1, int hours=0, int minutes=0, int seconds=0);;
int      debug(string message, int error = NO_ERROR);;
int      DebugMarketInfo(string location);;
int      Div(int a, int b, int onZero = 0);;
bool     EnumChildWindows(int hWnd, bool recursive = false);;
bool     EQ(double double1, double double2, int digits = 8);;
string   ErrorDescription(int error);;
bool     EventListener.NewTick();;
string   FileAccessModeToStr(int mode);;
int      Floor(double value);;
void     ForceAlert(string message);;
bool     GE(double double1, double double2, int digits = 8);;
string   GetClassName(int hWnd);;
double   GetCommission(double lots = 1.0);;
string   GetCurrency(int id);;
int      GetCurrencyId(string currency);;
double   GetExternalAssets(string companyId, string accountId);;
string   GetFullMqlFilesPath();;
datetime GetFxtTime();;
datetime GetServerTime();;
bool     GT(double double1, double double2, int digits = 8);;
bool     HandleEvent(int event);;
string   HistoryFlagsToStr(int flags);;
double   icALMA(int timeframe, int maPeriods, string maAppliedPrice, double distributionOffset, double distributionSigma, int iBuffer, int iBar);;
double   icHalfTrend(int timeframe, int periods, int iBuffer, int iBar);;
double   icMACD(int timeframe, int fastMaPeriods, string fastMaMethod, string fastMaAppliedPrice, int slowMaPeriods, string slowMaMethod, string slowMaAppliedPrice, int iBuffer, int iBar);;
double   icMovingAverage(int timeframe, int maPeriods, string maMethod, string maAppliedPrice, int iBuffer, int iBar);;
double   icNonLagMA(int timeframe, int cycleLength, int iBuffer, int iBar);;
double   icRSI(int timeframe, int rsiPeriods, string rsiAppliedPrice, int iBuffer, int iBar);;
double   icSuperTrend(int timeframe, int atrPeriods, int smaPeriods, int iBuffer, int iBar);;
double   icTriEMA(int timeframe, int maPeriods, string maAppliedPrice, int iBuffer, int iBar);;
double   icTrix(int timeframe, int emaPeriods, string emaAppliedPrice, int iBuffer, int iBar);;
bool     ifBool(bool condition, bool thenValue, bool elseValue);;
double   ifDouble(bool condition, double thenValue, double elseValue);;
int      ifInt(bool condition, int thenValue, int elseValue);;
string   ifString(bool condition, string thenValue, string elseValue);;
string   InitReasonDescription(int reason);;
bool     IsCurrency(string value);;
bool     IsEmpty(double value);;
bool     IsEmptyString(string value);;
bool     IsEmptyValue(double value);;
bool     IsError(int value);;
bool     IsInfinity(double value);;
bool     IsLastError();;
bool     IsLeapYear(int year);;
bool     IsLimitOrderType(int value);;
bool     IsLogging();;
bool     IsLongOrderType(int value);;
bool     IsNaN(double value);;
bool     IsNaT(datetime value);;
bool     IsOrderType(int value);;
bool     IsPendingOrderType(int value);;
bool     IsShortAccountCompany(string value);;
bool     IsShortOrderType(int value);;
bool     IsStopOrderType(int value);;
bool     IsSuperContext();;
bool     IsTicket(int ticket);;
bool     IsVisualModeFix();;
bool     LE(double double1, double double2, int digits = 8);;
int      log(string message, int error = NO_ERROR);;
bool     LogOrder(int ticket);;
bool     LogTicket(int ticket);;
bool     LT(double double1, double double2, int digits = 8);;
string   MaMethodDescription(int method);;
string   MaMethodToStr(int method);;
int      MarketWatch.Symbols();;
double   MathDiv(double a, double b, double onZero = 0);;
double   MathModFix(double a, double b);;
int      Max(int value1, int value2, int value3=INT_MIN, int value4=INT_MIN, int value5=INT_MIN, int value6=INT_MIN, int value7=INT_MIN, int value8=INT_MIN);;
string   MessageBoxButtonToStr(int id);;
int      MessageBoxEx(string caption, string message, int flags = MB_OK);;
int      Min(int value1, int value2, int value3=INT_MAX, int value4=INT_MAX, int value5=INT_MAX, int value6=INT_MAX, int value7=INT_MAX, int value8=INT_MAX);;
string   ModuleTypesToStr(int fType);;
string   MovingAverageMethodDescription(int method);;
string   MovingAverageMethodToStr(int method);;
bool     MQL.IsDirectory(string dirname);;
bool     MQL.IsFile(string filename);;
color    NameToColor(string name);;
bool     NE(double double1, double double2, int digits = 8);;
double   NormalizeLots(double lots, string symbol = "");;
string   NumberToStr(double value, string mask);;
string   OperationTypeDescription(int type);;
string   OperationTypeToStr(int type);;
bool     OrderPop(string location);;
bool     OrderPush(string location);;
string   OrderTypeDescription(int type);;
string   OrderTypeToStr(int type);;
int      PeriodFlag(int period = NULL);;
string   PeriodFlagsToStr(int flags);;
double   PipValue(double lots=1.0, bool suppressErrors=false);;
double   PipValueEx(string symbol, double lots=1.0, bool suppressErrors=false);;
bool     PlaySoundEx(string soundfile);;
bool     PlaySoundOrFail(string soundfile);;
string   PriceTypeDescription(int type);;
string   PriceTypeToStr(int type);;
int      ProgramInitReason();;
string   QuoteStr(string value);;
double   RefreshExternalAssets(string companyId, string accountId);;
int      ResetLastError();;
color    RGBStrToColor(string value);;
int      Round(double value);;
double   RoundCeil(double number, int decimals = 0);;
double   RoundEx(double number, int decimals = 0);;
double   RoundFloor(double number, int decimals = 0);;
bool     SelectTicket(int ticket, string location, bool pushTicket=false, bool onErrorPopTicket=false);;
bool     SendChartCommand(string cmdObject, string cmd, string cmdMutex = "");;
bool     SendEmail(string sender, string receiver, string subject, string message);;
bool     SendSMS(string receiver, string message);;
string   ShellExecuteErrorDescription(int error);;
string   ShortAccountCompany();;
string   ShortAccountCompanyFromId(int id);;
int      Sign(double number);;
int      start.RelaunchInputDialog();;
string   StrCapitalize(string value);;
bool     StrCompareI(string string1, string string2);;
bool     StrContains(string object, string substring);;
bool     StrContainsI(string object, string substring);;
bool     StrEndsWithI(string object, string suffix);;
int      StrFindR(string object, string search);;
bool     StrIsDigit(string value);;
bool     StrIsEmailAddress(string value);;
bool     StrIsInteger(string value);;
bool     StrIsNumeric(string value);;
bool     StrIsPhoneNumber(string value);;
string   StrLeft(string value, int n);;
string   StrLeftPad(string input, int pad_length, string pad_string = " ");;
string   StrLeftTo(string value, string substring, int count = 1);;
string   StrPadLeft(string input, int pad_length, string pad_string = " ");;
string   StrPadRight(string input, int pad_length, string pad_string = " ");;
string   StrRepeat(string input, int times);;
string   StrReplace(string object, string search, string replace);;
string   StrReplaceR(string object, string search, string replace);;
string   StrRight(string value, int n);;
string   StrRightFrom(string value, string substring, int count = 1);;
string   StrRightPad(string input, int pad_length, string pad_string = " ");;
bool     StrStartsWithI(string object, string prefix);;
string   StrSubstr(string object, int start, int length = INT_MAX);;
bool     StrToBool(string value);;
string   StrToHexStr(string value);;
string   StrToLower(string value);;
int      StrToMaMethod(string value, int execFlags = NULL);;
int      StrToMovingAverageMethod(string value, int execFlags = NULL);;
int      StrToOperationType(string value);;
int      StrToPeriod(string value, int execFlags = NULL);;
int      StrToPriceType(string value, int execFlags = NULL);;
int      StrToTimeframe(string timeframe, int execFlags = NULL);;
int      StrToTradeDirection(string value, int execFlags = NULL);;
string   StrToUpper(string value);;
string   StrTrim(string value);;
int      SumInts(int values[]);;
string   SwapCalculationModeToStr(int mode);;
int      Tester.GetBarModel();;
bool     Tester.IsPaused();;
bool     Tester.IsStopped();;
int      Tester.Pause();;
bool     This.IsTesting();;
datetime TimeCurrentEx(string location = "");;
int      TimeDayFix(datetime time);;
int      TimeDayOfWeekFix(datetime time);;
int      TimeframeFlag(int timeframe = NULL);;
datetime TimeFXT();;
datetime TimeGMT();;
datetime TimeLocalEx(string location = "");;
datetime TimeServer();;
int      TimeYearFix(datetime time);;
int      Toolbar.Experts(bool enable);;
string   TradeCommandToStr(int cmd);;
string   UninitializeReasonDescription(int reason);;
string   UrlEncode(string value);;
bool     WaitForTicket(int ticket, bool select = false);;
int      warn(string message, int error = NO_ERROR);;


// include/functions/
void     @ALMA.CalculateWeights(double &weights[], int periods, double offset=0.85, double sigma=6.0);;
double   @ATR(string symbol, int timeframe, int periods, int offset);;
void     @Bands.UpdateLegend(string label, string name, string status, color bandsColor, double upperValue, double lowerValue, datetime barOpenTime);;
bool     @NLMA.CalculateWeights(double &weights[], int cycles, int cycleLength);;
void     @Trend.UpdateDirection(double values[], int bar, double &trend[], double &uptrend[], double &downtrend[], double &uptrend2[], int lineStyle, bool enableColoring=false, bool enableUptrend2=false, int normalizeDigits=EMPTY_VALUE);;
void     @Trend.UpdateLegend(string label, string name, string status, color uptrendColor, color downtrendColor, double value, int digits, int trend, datetime barOpenTime);;
bool     Configure.Signal(string name, string &configValue, bool &enabled);;
bool     Configure.Signal.Mail(string configValue, bool &enabled, string &sender, string &receiver);;
bool     Configure.Signal.SMS(string configValue, bool &enabled, string &receiver);;
bool     Configure.Signal.Sound(string configValue, bool &enabled);;
int      ExplodeStrings(int buffer[], string &results[]);;
int      iBarShiftNext(string symbol=NULL, int period=NULL, datetime time, int muteFlags=NULL);;
int      iBarShiftPrevious(string symbol=NULL, int period=NULL, datetime time, int muteFlags=NULL);;
int      iChangedBars(string symbol=NULL, int period=NULL, int muteFlags=NULL);;
int      InitializeByteBuffer(int buffer[], int bytes);;
bool     iPreviousPeriodTimes(int timeframe=NULL, datetime &openTime.fxt=NULL, datetime &closeTime.fxt, datetime &openTime.srv, datetime &closeTime.srv);;
bool     IsBarOpenEvent(int timeframe = NULL);;
string   JoinBools(bool values[], string separator = ", ");;
string   JoinDoubles(double values[], string separator = ", ");;
string   JoinDoublesEx(double values[], int digits, string separator = ", ");;
string   JoinInts(int values[], string separator = ", ");;
string   JoinStrings(string values[], string separator = ", ");;


// include/structs/mt4/


// include/structs/rsf/Bar.mqh
datetime bar.Time      (/*BAR*/double bar[]);;
double   bar.Open      (/*BAR*/double bar[]);;
double   bar.Low       (/*BAR*/double bar[]);;
double   bar.High      (/*BAR*/double bar[]);;
double   bar.Close     (/*BAR*/double bar[]);;
int      bar.Volume    (/*BAR*/double bar[]);;

datetime bar.setTime   (/*BAR*/double &bar[], datetime time  );;
double   bar.setOpen   (/*BAR*/double &bar[], double   open  );;
double   bar.setLow    (/*BAR*/double &bar[], double   low   );;
double   bar.setHigh   (/*BAR*/double &bar[], double   high  );;
double   bar.setClose  (/*BAR*/double &bar[], double   close );;
int      bar.setVolume (/*BAR*/double &bar[], int      volume);;

datetime bars.Time     (/*BAR*/double bar[][], int i);;
double   bars.Open     (/*BAR*/double bar[][], int i);;
double   bars.Low      (/*BAR*/double bar[][], int i);;
double   bars.High     (/*BAR*/double bar[][], int i);;
double   bars.Close    (/*BAR*/double bar[][], int i);;
int      bars.Volume   (/*BAR*/double bar[][], int i);;

datetime bars.setTime  (/*BAR*/double &bar[][], int i, datetime time  );;
double   bars.setOpen  (/*BAR*/double &bar[][], int i, double   open  );;
double   bars.setLow   (/*BAR*/double &bar[][], int i, double   low   );;
double   bars.setHigh  (/*BAR*/double &bar[][], int i, double   high  );;
double   bars.setClose (/*BAR*/double &bar[][], int i, double   close );;
int      bars.setVolume(/*BAR*/double &bar[][], int i, int      volume);;

string   BAR.toStr     (/*BAR*/double bar[], bool outputDebug = false);;


// include/structs/win32/


// libraries/rsfLib1.ex4
bool     AquireLock(string mutexName, bool wait);;
int      ArrayDropBool(bool array[], bool value);;
int      ArrayDropDouble(double array[], double value);;
int      ArrayDropInt(int array[], int value);;
int      ArrayDropString(string array[], string value);;
int      ArrayInsertBool(bool &array[], int offset, bool value);;
int      ArrayInsertBools(bool array[], int offset, bool values[]);;
int      ArrayInsertDouble(double &array[], int offset, double value);;
int      ArrayInsertDoubles(double array[], int offset, double values[]);;
int      ArrayInsertInt(int &array[], int offset, int value);;
int      ArrayInsertInts(int array[], int offset, int values[]);;
bool     ArrayPopBool(bool array[]);;
double   ArrayPopDouble(double array[]);;
int      ArrayPopInt(int array[]);;
string   ArrayPopString(string array[]);;
int      ArrayPushBool(bool &array[], bool value);;
int      ArrayPushDouble(double &array[], double value);;
int      ArrayPushInt(int &array[], int value);;
int      ArrayPushInts(int array[][], int value[]);;
int      ArrayPushString(string &array[], string value);;
int      ArraySetInts(int array[][], int offset, int values[]);;
bool     ArrayShiftBool(bool array[]);;
double   ArrayShiftDouble(double array[]);;
int      ArrayShiftInt(int array[]);;
string   ArrayShiftString(string array[]);;
int      ArraySpliceBools(bool array[], int offset, int length);;
int      ArraySpliceDoubles(double array[], int offset, int length);;
int      ArraySpliceInts(int array[], int offset, int length);;
int      ArraySpliceStrings(string array[], int offset, int length);;
int      ArrayUnshiftBool(bool array[], bool value);;
int      ArrayUnshiftDouble(double array[], double value);;
int      ArrayUnshiftInt(int array[], int value);;
bool     BoolInArray(bool haystack[], bool needle);;
int      BufferGetChar(int buffer[], int pos);;
string   BufferToHexStr(int buffer[]);;
string   BufferToStr(int buffer[]);;
string   BufferWCharsToStr(int buffer[], int from, int length);;
string   CharToHexStr(int char);;
bool     ChartMarker.OrderDeleted_A(int ticket, int digits, color markerColor);;
bool     ChartMarker.OrderDeleted_B(int ticket, int digits, color markerColor, int type, double lots, string symbol, datetime openTime, double openPrice, datetime closeTime, double closePrice);;
bool     ChartMarker.OrderFilled_A(int ticket, int pendingType, double pendingPrice, int digits, color markerColor);;
bool     ChartMarker.OrderFilled_B(int ticket, int pendingType, double pendingPrice, int digits, color markerColor, double lots, string symbol, datetime openTime, double openPrice, string comment);;
bool     ChartMarker.OrderModified_A(int ticket, int digits, color markerColor, datetime modifyTime, double oldOpenPrice, double oldStopLoss, double oldTakeprofit);;
bool     ChartMarker.OrderModified_B(int ticket, int digits, color markerColor, int type, double lots, string symbol, datetime openTime, datetime modifyTime, double oldOpenPrice, double openPrice, double oldStopLoss, double stopLoss, double oldTakeProfit, double takeProfit, string comment);;
bool     ChartMarker.OrderSent_A(int ticket, int digits, color markerColor);;
bool     ChartMarker.OrderSent_B(int ticket, int digits, color markerColor, int type, double lots, string symbol, datetime openTime, double openPrice, double stopLoss, double takeProfit, string comment);;
bool     ChartMarker.PositionClosed_A(int ticket, int digits, color markerColor);;
bool     ChartMarker.PositionClosed_B(int ticket, int digits, color markerColor, int type, double lots, string symbol, datetime openTime, double openPrice, datetime closeTime, double closePrice);;
color    ColorAdjust(color rgb, double adjustHue, double adjustSaturation, double adjustLightness);;
string   CreateLegendLabel(string name);;
string   CreateTempFile(string path, string prefix = "");;
int      DecreasePeriod(int period = 0);;
bool     DeletePendingOrders(color markerColor = CLR_NONE);;
int      DeleteRegisteredObjects(string prefix = NULL);;
bool     DoubleInArray(double haystack[], double needle);;
string   DoubleToStrEx(double value, int digits);;
bool     EditFile(string filename);;
bool     EditFiles(string filenames[]);;
int      Explode(string input, string separator, string &results[], int limit = NULL);;
int      FileReadLines(string filename, string result[], bool skipEmptyLines = false);;
int      FindFileNames(string pattern, string &lpResults[], int flags = NULL);;
datetime FxtToGmtTime(datetime fxtTime);;
datetime FxtToServerTime(datetime fxtTime);;
int      GetAccountNumber();;
int      GetCustomLogID();;
int      GetFxtToGmtTimeOffset(datetime fxtTime);;
int      GetFxtToServerTimeOffset(datetime fxtTime);;
int      GetGmtToFxtTimeOffset(datetime gmtTime);;
int      GetGmtToServerTimeOffset(datetime gmtTime);;
string   GetHostName();;
int      GetIniKeys(string fileName, string section, string keys[]);;
int      GetLocalToGmtTimeOffset();;
string   GetLongSymbolName(string symbol);;
string   GetLongSymbolNameOrAlt(string symbol, string altValue = "");;
string   GetLongSymbolNameStrict(string symbol);;
datetime GetNextSessionEndTime.fxt(datetime fxtTime);;
datetime GetNextSessionEndTime.gmt(datetime gmtTime);;
datetime GetNextSessionEndTime.srv(datetime serverTime);;
datetime GetNextSessionStartTime.fxt(datetime fxtTime);;
datetime GetNextSessionStartTime.gmt(datetime gmtTime);;
datetime GetNextSessionStartTime.srv(datetime serverTime);;
datetime GetPrevSessionEndTime.fxt(datetime fxtTime);;
datetime GetPrevSessionEndTime.gmt(datetime gmtTime);;
datetime GetPrevSessionEndTime.srv(datetime serverTime);;
datetime GetPrevSessionStartTime.fxt(datetime fxtTime);;
datetime GetPrevSessionStartTime.gmt(datetime gmtTime);;
datetime GetPrevSessionStartTime.srv(datetime serverTime);;
string   GetServerName();;
string   GetServerTimezone();;
int      GetServerToFxtTimeOffset(datetime serverTime);;
int      GetServerToGmtTimeOffset(datetime serverTime);;
datetime GetSessionEndTime.fxt(datetime fxtTime);;
datetime GetSessionEndTime.gmt(datetime gmtTime);;
datetime GetSessionEndTime.srv(datetime serverTime);;
datetime GetSessionStartTime.fxt(datetime fxtTime);;
datetime GetSessionStartTime.gmt(datetime gmtTime);;
datetime GetSessionStartTime.srv(datetime serverTime);;
string   GetStandardSymbol(string symbol);;
string   GetStandardSymbolOrAlt(string symbol, string altValue = "");;
string   GetStandardSymbolStrict(string symbol);;
string   GetSymbolName(string symbol);;
string   GetSymbolNameOrAlt(string symbol, string altValue = "");;
string   GetSymbolNameStrict(string symbol);;
string   GetTempPath();;
bool     GetTimezoneTransitions(datetime serverTime, int &previousTransition[], int &nextTransition[]);;
string   GetWindowsShortcutTarget(string lnkFilename);;
string   GetWindowText(int hWnd);;
datetime GmtToFxtTime(datetime gmtTime);;
datetime GmtToServerTime(datetime gmtTime);;
color    HSLToRGB(double hsl[3]);;
int      IncreasePeriod(int period = NULL);;
int      InitializeDoubleBuffer(double buffer[], int size);;
int      InitializeStringBuffer(string &buffer[], int length);;
string   IntegerToBinaryStr(int integer);;
string   IntegerToHexStr(int integer);;
bool     IntInArray(int haystack[], int needle);;
bool     IsReverseIndexedBoolArray(bool array[]);;
bool     IsReverseIndexedDoubleArray(double array[]);;
bool     IsReverseIndexedIntArray(int array[]);;
bool     IsReverseIndexedStringArray(string array[]);;
bool     IsTemporaryTradeError(int error);;
int      MergeBoolArrays(bool array1[], bool array2[], bool merged[]);;
int      MergeDoubleArrays(double array1[], double array2[], double merged[]);;
int      MergeIntArrays(int array1[], int array2[], int merged[]);;
int      MergeStringArrays(string array1[], string array2[], string merged[]);;
bool     ObjectDeleteSilent(string label, string location);;
int      ObjectRegister(string label);;
bool     onBarOpen();;
bool     onCommand(string data[]);;
int      OrderSendEx(string symbol=NULL, int type, double lots, double price, double slippage, double stopLoss, double takeProfit, string comment, int magicNumber, datetime expires, color markerColor, int oeFlags, int oe[]);;
bool     OrderModifyEx(int ticket, double openPrice, double stopLoss, double takeProfit, datetime expires, color markerColor, int oeFlags, int oe[]);;
bool     OrderDeleteEx(int ticket, color markerColor, int oeFlags, int oe[]);;
bool     OrderCloseEx(int ticket, double lots, double slippage, color markerColor, int oeFlags, int oe[]);;
bool     OrderCloseByEx(int ticket, int opposite, color markerColor, int oeFlags, int oe[]);;
bool     OrdersClose(int tickets[], double slippage, color markerColor, int oeFlags, int oes[][]);;
bool     OrdersCloseSameSymbol(int tickets[], double slippage, color markerColor, int oeFlags, int oes[][]);;
int      OrdersHedge(int tickets[], double slippage, int oeFlags, int oes[][]);;
bool     OrdersCloseHedged(int tickets[], color markerColor, int oeFlags, int oes[][]);;
bool     ReleaseLock(string mutexName);;
int      RepositionLegend();;
bool     ReverseBoolArray(bool array[]);;
bool     ReverseDoubleArray(double array[]);;
bool     ReverseIntArray(int array[]);;
bool     ReverseStringArray(string array[]);;
color    RGB(int red, int green, int blue);;
int      RGBToHSL(color rgb, double &hsl[], , bool human = false);;
int      SearchBoolArray(bool haystack[], bool needle);;
int      SearchDoubleArray(double haystack[], double needle);;
int      SearchIntArray(int haystack[], int needle);;
int      SearchStringArray(string haystack[], string needle);;
int      SearchStringArrayI(string haystack[], string needle);;
datetime ServerToFxtTime(datetime serverTime);;
datetime ServerToGmtTime(datetime serverTime);;
int      SetCustomLog(int id, string file);;
int      SortTicketsChronological(int &tickets[]);;
string   StdSymbol();;
bool     StringInArray(string haystack[], string needle);;
bool     StringInArrayI(string haystack[], string needle);;
string   StringPad(string input, int pad_length, string pad_string=" ", int pad_type=STR_PAD_RIGHT);;
double   SumDoubles(double values[]);;
string   WaitForSingleObjectValueToStr(int value);;
int      WinExecWait(string cmdLine, int cmdShow);;
string   WordToHexStr(int word);;


// libraries/rsfLib2.ex4
string   BoolsToStr(bool array[], string separator);;
string   CharsToStr(int array[], string separator);;
string   DoublesToStr(double array[], string separator);;
string   DoublesToStrEx(double array[], string separator, int digits/*=0..16*/);;
string   iBufferToStr(double array[], string separator);;
string   IntsToStr(int array[], string separator);;
string   MoneysToStr(double array[], string separator);;
string   OperationTypesToStr(int array[], string separator);;
string   PricesToStr(double array[], string separator);;
string   RatesToStr(double array[], string separator);;
string   StringsToStr(string array[], string separator);;
string   TicketsToStr(int array[], string separator);;
string   TicketsToStr.Lots(int array[], string separator);;
string   TicketsToStr.LotsSymbols(int array[], string separator);;
string   TicketsToStr.Position(int array[]);;
string   TimesToStr(datetime array[], string separator);;


// libraries/rsfExpander.dll
int      AnsiToWCharStr(string ansi, int wchar[], int wcharSize);;
string   BarModelDescription(int id);;
string   BarModelToStr(int id);;
string   BoolToStr(bool value);;
string   CoreFunctionDescription(int func);;
string   CoreFunctionToStr(int func);;
int      CreateDirectoryRecursive(string path);;
string   DeinitFlagsToStr(int flags);;
string   DoubleQuoteStr(string value);;
double   ec_Ask                   (int ec[]);;
int      ec_Bars                  (int ec[]);;
double   ec_Bid                   (int ec[]);;
string   ec_CustomLogFile         (int ec[]);;
bool     ec_CustomLogging         (int ec[]);;
int      ec_CycleTicks            (int ec[]);;
int      ec_ModuleDeinitFlags     (int ec[]);;
int      ec_Digits                (int ec[]);;
int      ec_DllError              (int ec[]);;
int      ec_DllWarning            (int ec[]);;
bool     ec_ExtReporting          (int ec[]);;
int      ec_ModuleInitFlags       (int ec[]);;
datetime ec_LastTickTime          (int ec[]);;
bool     ec_Logging               (int ec[]);;
string   ec_ModuleName            (int ec[]);;
int      ec_ModuleType            (int ec[]);;
int      ec_ModuleUninitReason    (int ec[]);;
int      ec_MqlError              (int ec[]);;
bool     ec_Optimization          (int ec[]);;
int      ec_Pid                   (int ec[]);;
double   ec_Pip                   (int ec[]);;
string   ec_PipPriceFormat        (int ec[]);;
int      ec_PipDigits             (int ec[]);;
int      ec_PipPoints             (int ec[]);;
double   ec_Point                 (int ec[]);;
int      ec_PreviousPid           (int ec[]);;
datetime ec_PrevTickTime          (int ec[]);;
string   ec_PriceFormat           (int ec[]);;
int      ec_ProgramCoreFunction   (int ec[]);;
int      ec_ProgramInitReason     (int ec[]);;
string   ec_ProgramName           (int ec[]);;
int      ec_ProgramType           (int ec[]);;
int      ec_ProgramUninitReason   (int ec[]);;
bool     ec_RecordEquity          (int ec[]);;
int      ec_SetDllError           (int ec[], int error   );;
bool     ec_SetLogging            (int ec[], int logging );;
int      ec_SetMqlError           (int ec[], int error   );;
int      ec_SetProgramCoreFunction(int ec[], int function);;
int      ec_SubPipDigits          (int ec[]);;
string   ec_SubPipPriceFormat     (int ec[]);;
bool     ec_SuperContext          (int ec[], int target[]);;
string   ec_Symbol                (int ec[]);;
int      ec_TestBarModel          (int ec[]);;
int      ec_TestBars              (int ec[]);;
datetime ec_TestCreated           (int ec[]);;
datetime ec_TestEndTime           (int ec[]);;
int      ec_TestId                (int ec[]);;
int      ec_TestReportId          (int ec[]);;
string   ec_TestReportSymbol      (int ec[]);;
double   ec_TestSpread            (int ec[]);;
datetime ec_TestStartTime         (int ec[]);;
int      ec_TestTicks             (int ec[]);;
int      ec_TestTradeDirections   (int ec[]);;
bool     ec_TestVisualMode        (int ec[]);;
bool     ec_Testing               (int ec[]);;
int      ec_Ticks                 (int ec[]);;
int      ec_Timeframe             (int ec[]);;
bool     ec_VisualMode            (int ec[]);;
int      ec_hChart                (int ec[]);;
int      ec_hChartWindow          (int ec[]);;
int      ec_lpSuperContext        (int ec[]);;
string   ErrorToStr(int error);;
bool     EventListener_ChartCommand(string commands[]);;
string   EXECUTION_CONTEXT_toStr(int ec[], int outputDebug);;
int      FindInputDialog(int programType, string programName);;
int      FindTesterWindow();;
int      GetBoolsAddress(bool array[]);;
int      GetDoublesAddress(double array[]);;
string   GetFinalPathNameA(string name);;
string   GetGlobalConfigPathA();;
datetime GetGmtTime();;
int      GetIniKeysA(string fileName, string section, int buffer[], int bufferSize);;
string   GetIniString(string fileName, string section, string key, string defaultValue);;
string   GetIniStringRaw(string fileName, string section, string key, string defaultValue);;
int      GetIntsAddress(int array[]);;
int      GetLastWin32Error();;
string   GetLocalConfigPathA();;
datetime GetLocalTime();;
string   GetMqlDirectoryA();;
int      GetPointedAddress(void &value);;
string   GetReparsePointTargetA(string name);;
string   GetStringA(int address);;
string   GetStringW(int address);;
int      GetStringAddress(string value);;
int      GetStringsAddress(string values[]);;
int      GetTerminalBuild();;
string   GetTerminalCommonDataPathA();;
string   GetTerminalDataPathA();;
int      GetTerminalMainWindow();;
string   GetTerminalModuleFileNameA();;
string   GetTerminalRoamingDataPathA();;
string   GetTerminalVersion();;
int      GetUIThreadId();;
int      GetWindowProperty(int hWnd, string name);;
string   GmtTimeFormat(datetime timestamp, string format);;
string   InitFlagsToStr(int flags);;
string   InitializeReasonToStr(int reason);;
string   InitReasonToStr(int reason);;
string   InputParamsDiff(string initial, string current);;
string   InputsToStr();;
string   IntToHexStr(int value);;
bool     IsCustomTimeframe(int timeframe);;
bool     IsDirectoryA(string name);;
bool     IsFileA(string name);;
bool     IsGlobalConfigKey        (string section, string key);;
bool     IsIniKey(string fileName, string section, string key);;
bool     IsIniSection(string fileName, string section);;
bool     IsJunctionA(string name);;
bool     IsLocalConfigKey(string section, string key);;
bool     IsStdTimeframe(int timeframe);;
bool     IsSymlinkA(string name);;
bool     IsUIThread(int threadId);;
int      LeaveContext(int ec[]);;
bool     LoadMqlProgramA(int hChart, int programType, string programName);;
bool     LoadMqlProgramW(int hChart, int programType, string programName);;
string   LocalTimeFormat(datetime timestamp, string format);;
string   lpEXECUTION_CONTEXT_toStr(int lpEc, int outputDebug);;
string   MD5Hash(int input[], int length);;
string   MD5HashA(string str);;
bool     MemCompare(int lpBufferA, int lpBufferB, int size);;
string   ModuleTypeDescription(int type);;
string   ModuleTypeToStr(int type);;
int      MT4InternalMsg();;
string   NumberFormat(double value, string format);;
int      onDeinitAccountChange();;
int      onDeinitChartChange();;
int      onDeinitChartClose();;
int      onDeinitClose();;
int      onDeinitFailed();;
int      onDeinitParameterChange();;
int      onDeinitRecompile();;
int      onDeinitRemove();;
int      onDeinitTemplate();;
int      onDeinitUndefined();;
string   PeriodDescription(int period);;
string   PeriodToStr(int period);;
string   ProgramTypeDescription(int type);;
string   ProgramTypeToStr(int type);;
bool     RemoveTickTimer(int timerId);;
int      RemoveWindowProperty(int hWnd, string name);;
int      SetupTickTimer(int hWnd, int millis, int flags);;
bool     SetWindowProperty(int hWnd, string name, int value);;
bool     ShiftIndicatorBuffer(double buffer[], int bufferSize, int bars, double emptyValue);;
int      ShowStatus(int error);;
string   ShowWindowCmdToStr(int cmdShow);;
bool     StrCompare(string s1, string s2);;
bool     StrEndsWith(string str, string suffix);;
string   StringToStr(string str);;
bool     StrIsNull(string str);;
bool     StrStartsWith(string str, string prefix);;
int      SyncLibContext_deinit(int ec[], int uninitReason);;
int      SyncLibContext_init(int ec[], int uninitReason, int initFlags, int deinitFlags, string name, string symbol, int timeframe, int digits, double point, int isTesting, int isOptimization);;
int      SyncMainContext_deinit(int ec[], int uninitReason);;
int      SyncMainContext_init(int ec[], int programType, string programName, int uninitReason, int initFlags, int deinitFlags, string symbol, int timeframe, int digits, double point, int extReporting, int recordEquity, int isTesting, int isVisualMode, int isOptimization, int lpSec, int hChart, int droppedOnChart, int droppedOnPosX, int droppedOnPosY);;
int      SyncMainContext_start(int ec[], double rates[][], int bars, int changedBars, int ticks, datetime time, double bid, double ask);;
bool     TerminalIsPortableMode();;
bool     Test_onPositionOpen(int ec[], int ticket, int type, double lots, string symbol, double openPrice, datetime openTime, double stopLoss, double takeProfit, double commission, int magicNumber, string comment);;
bool     Test_onPositionClose(int ec[], int ticket, double closePrice, datetime closeTime, double swap, double profit);;
double   Test_GetCommission(int ec[], double lots);;
bool     Test_StartReporting(int ec[], datetime from, int bars, int reportId, string reportSymbol);;
bool     Test_StopReporting (int ec[], datetime to,   int bars);;
int      Tester_GetBarModel();;
datetime Tester_GetStartDate();;
datetime Tester_GetEndDate();;
string   TimeframeDescription(int timeframe);;
string   TimeframeToStr(int timeframe);;
string   TradeDirectionDescription(int direction);;
string   TradeDirectionToStr(int direction);;
string   UninitializeReasonToStr(int reason);;
string   UninitReasonToStr(int reason);;
int      WM_MT4();;
