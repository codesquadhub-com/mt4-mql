
string  qc.ScriptParameterChannel;
int    hQC.ScriptParameterSender;


/**
 * Startet im aktuellen Chart ein Script und �bergibt die angegebenen Parameter. Darf nicht aus einem Script selbst aufgerufen werden,
 * da im Chart jeweils nur ein Script laufen kann.
 *
 * @param  string name       - Name des Scripts
 * @param  string parameters - Parameter im Format "param1Name=param1Value{TAB}param2Name=param2Value[{TAB}...]" (default: keine Parameter)
 *
 * @return bool - Ob die Startanweisung erfolgreich ans System �bermittelt wurde.
 *                Nicht, ob das Script erfolgreich gestartet und/oder ausgef�hrt wurde.
 */
bool RunScript(string name, string parameters="") {
   if (IsScript())       return(!catch("RunScript(1)  invalid calling context (must not be called from a script)", ERR_RUNTIME_ERROR));
   if (!StringLen(name)) return(!catch("RunScript(2)  invalid parameter name=\"\"", ERR_INVALID_PARAMETER));

   if (parameters == "0")                                            // (string) NULL
      parameters = "";

   int hWnd = WindowHandleEx(NULL);
   if (!hWnd) return(false);

   // Parameter hinterlegen
   if (!SetScriptParameters(parameters))
      return(false);

   string scriptName[]; ArrayResize(scriptName, 1);                  // 'scriptName[0]' mu� nach Verlassen der Funktion zur Script-Ausf�hrung noch g�ltig sein,
   scriptName[0] = StringConcatenate("", name);                      // was im Indikator oder Expert nur mit einem String-Array sichergestellt ist.
                                                                     // 'scriptName' darf daher bei Verlassen der Funktion nicht zur�ckgesetzt werden.
   // Script starten
   if (!PostMessageA(hWnd, MT4InternalMsg(), MT4_LOAD_SCRIPT, GetStringAddress(scriptName[0])))
      return(!catch("RunScript(3)->user32::PostMessageA()", ERR_WIN32_ERROR));

   return(true);
   DummyCalls.ParameterProvider();
}


/**
 * Hinterlegt die �bergebenen Parameter f�r den automatischen Aufruf des n�chsten Scripts im aktuellen Chart.
 *
 * @param  string parameters - dem Script entsprechender Parameterstring im Format "param1Name=param1Value{TAB}param2Name=param2Value[{TAB}...]"
 *
 * @return bool - Erfolgsstatus
 */
bool SetScriptParameters(string parameters) {
   // Script-Parameter via QuickChannel hinterlegen
   if (!hQC.ScriptParameterSender) /*&&*/ if (!QC.StartScriptParameterSender())     // Da Laufzeit und Erfolg des zu startenden Scripts unbekannt sind,
      return(false);                                                                // darf der Sender erst beim n�chsten deinit() gestoppt werden

   // TODO: bei Mehrfachaufrufen vorhandene Parameter modifizieren

   int result = QC_SendMessage(hQC.ScriptParameterSender, parameters, NULL);
   if (!result)
      return(!catch("SetScriptParameters()->MT4iQuickChannel::QC_SendMessage() = QC_SEND_MSG_ERROR", ERR_WIN32_ERROR));

   return(true);
   DummyCalls.ParameterProvider();
}


/**
 * Gibt die per QuickChannel �bergebenen Parameter des aktuellen Scripts zur�ck.
 *
 * @param  string paramNames [] - Array zur Aufnahme der Parameternamen
 * @param  string paramValues[] - Array zur Aufnahme der Parameterwerte
 *
 * @return int - Anzahl der �bergebenen Parameter oder -1 (EMPTY), falls ein Fehler auftrat
 */
int GetScriptParameters(string paramNames[], string paramValues[]) {
   if (!IsScript())
      return(_EMPTY(catch("GetScriptParameters(1)  invalid calling context (not a script)", ERR_RUNTIME_ERROR)));

   string parameters = "";

   // Um f�r den QC-Receiver kein Fenster registrieren zu m�ssen (l�st unn�tige Ticks aus), benutzen wir zum Lesen des Channels einen weiteren Sender.
   if (!hQC.ScriptParameterSender) /*&&*/ if (!QC.StartScriptParameterSender())
      return(EMPTY);

   // TODO: Channel zuerst pr�fen, erst dann Sender starten

   // check channel
   int checkResult = QC_CheckChannel(qc.ScriptParameterChannel);
   if (checkResult < QC_CHECK_CHANNEL_EMPTY) {
      if      (checkResult == QC_CHECK_CHANNEL_ERROR) catch("GetScriptParameters(2)->MT4iQuickChannel::QC_CheckChannel(name=\""+ qc.ScriptParameterChannel +"\") => QC_CHECK_CHANNEL_ERROR",                ERR_WIN32_ERROR);
      else if (checkResult == QC_CHECK_CHANNEL_NONE ) catch("GetScriptParameters(3)->MT4iQuickChannel::QC_CheckChannel(name=\""+ qc.ScriptParameterChannel +"\")  channel doesn't exist",                   ERR_WIN32_ERROR);
      else                                            catch("GetScriptParameters(4)->MT4iQuickChannel::QC_CheckChannel(name=\""+ qc.ScriptParameterChannel +"\")  unexpected return value = "+ checkResult, ERR_WIN32_ERROR);
   }
   else if (checkResult > QC_CHECK_CHANNEL_EMPTY) {
      // get messages
      string messageBuffer[]; if (!ArraySize(messageBuffer)) InitializeStringBuffer(messageBuffer, QC_MAX_BUFFER_SIZE);
      int getResult = QC_GetMessages3(hQC.ScriptParameterSender, messageBuffer, QC_MAX_BUFFER_SIZE);
      if (getResult != QC_GET_MSG3_SUCCESS) {
         if      (getResult == QC_GET_MSG3_CHANNEL_EMPTY) catch("GetScriptParameters(5)->MT4iQuickChannel::QC_GetMessages3()  QuickChannel mis-match: QC_CheckChannel="+ checkResult +"chars/QC_GetMessages3=CHANNEL_EMPTY", ERR_WIN32_ERROR);
         else if (getResult == QC_GET_MSG3_INSUF_BUFFER ) catch("GetScriptParameters(6)->MT4iQuickChannel::QC_GetMessages3()  QuickChannel mis-match: QC_CheckChannel="+ checkResult +"chars/QC_MAX_BUFFER_SIZE="+ QC_MAX_BUFFER_SIZE +"/size(buffer)="+ (StringLen(messageBuffer[0])+1) +"/QC_GetMessages3=INSUF_BUFFER", ERR_WIN32_ERROR);
         else                                             catch("GetScriptParameters(7)->MT4iQuickChannel::QC_GetMessages3()  unexpected return value = "+ getResult, ERR_WIN32_ERROR);
      }
      else {
         parameters = messageBuffer[0];
      }
   }

   // stop sender
   if (!QC.StopScriptParameterSender())
      return(EMPTY);
   if (IsLastError())
      return(EMPTY);


   // Parameter parsen
   ArrayResize(paramNames,  0);
   ArrayResize(paramValues, 0);

   string pairs[], param[];
   int size = Explode(parameters, TAB, pairs, NULL);

   for (int i=0; i < size; i++) {
      if (Explode(pairs[i], "=", param, 2) < 2)                      // kein "="-Separator, Parameter wird verworfen
         continue;
      ArrayPushString(paramNames,  param[0]);
      ArrayPushString(paramValues, param[1]);
   }

   return(ArraySize(paramNames));
   DummyCalls.ParameterProvider();
}


/**
 * Startet einen QuickChannel-Sender f�r Scriptparameter. Bei Aufruf aus einem Script mu� der Channel bereits existieren, ohne k�nnen
 * keine Parameter hinterlegt worden sein.
 *
 * @return bool - Erfolgsstatus
 */
bool QC.StartScriptParameterSender() {
   if (hQC.ScriptParameterSender != 0)
      return(true);

   int hWnd = WindowHandleEx(NULL);
   if (!hWnd) return(false);

   qc.ScriptParameterChannel = "ScriptParameters.0x"+ IntToHexStr(hWnd);

   if (IsScript()) {
      // Der Channel mu� bereits existieren, ohne k�nnen keine Parameter hinterlegt worden sein.
      int result = QC_CheckChannel(qc.ScriptParameterChannel);
      if (result < QC_CHECK_CHANNEL_EMPTY) {
         if (result == QC_CHECK_CHANNEL_NONE ) return(!catch("QC.StartScriptParameterSender(1)  you cannot manually call this script (channel \""+ qc.ScriptParameterChannel +"\" doesn't exist)",                ERR_RUNTIME_ERROR));
         if (result == QC_CHECK_CHANNEL_ERROR) return(!catch("QC.StartScriptParameterSender(2)->MT4iQuickChannel::QC_CheckChannel(name=\""+ qc.ScriptParameterChannel +"\") => QC_CHECK_CHANNEL_ERROR",            ERR_WIN32_ERROR  ));
                                               return(!catch("QC.StartScriptParameterSender(3)->MT4iQuickChannel::QC_CheckChannel(name=\""+ qc.ScriptParameterChannel +"\")  unexpected return value = "+ result, ERR_WIN32_ERROR  ));
      }
   }

   hQC.ScriptParameterSender = QC_StartSender(qc.ScriptParameterChannel);
   if (!hQC.ScriptParameterSender)
      return(!catch("QC.StartScriptParameterSender(4)->MT4iQuickChannel::QC_StartSender(channel=\""+ qc.ScriptParameterChannel +"\")", ERR_WIN32_ERROR));

   return(true);
   DummyCalls.ParameterProvider();
}


/**
 * Stoppt einen QuickChannel-Sender f�r Scriptparameter.
 *
 * @return bool - Erfolgsstatus
 */
bool QC.StopScriptParameterSender() {
   if (!hQC.ScriptParameterSender)
      return(true);

   // TODO: pr�fen, ob alle Messages abgeholt sind und der Channel leer ist

   int hTmp = hQC.ScriptParameterSender;
              hQC.ScriptParameterSender = NULL;

   if (!QC_ReleaseSender(hTmp))
      return(!catch("QC.StopScriptParameterSender(1)->MT4iQuickChannel::QC_ReleaseSender(ch=\""+ qc.ScriptParameterChannel +"\")  error stopping sender", ERR_WIN32_ERROR));

   return(true);
   DummyCalls.ParameterProvider();
}


/**
 * Dummy-Calls unterdr�cken unn�tze Compilerwarnungen.
 *
 */
void DummyCalls.ParameterProvider() {
   string sNulls[];
   GetScriptParameters(sNulls, sNulls);
   QC.StartScriptParameterSender();
   QC.StopScriptParameterSender();
   RunScript(NULL);
   SetScriptParameters(NULL);
}


// --------------------------------------------------------------------------------------------------------------------------------------------------


#import "stdlib1.ex4"
   int Explode(string input, string separator, string results[], int limit);
#import
