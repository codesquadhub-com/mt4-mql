
int __lpSuperContext = NULL;


/**
 * Initialization
 *
 * @return int - error status
 */
int init() {
   int error = SyncLibContext_init(__ExecutionContext, UninitializeReason(), SumInts(__INIT_FLAGS__), SumInts(__DEINIT_FLAGS__), WindowExpertName(), Symbol(), Period(), Digits, IsOptimization());
   if (IsError(error)) return(error);

   // globale Variablen initialisieren
   __lpSuperContext = ec_lpSuperContext(__ExecutionContext);
   __NAME__         = ec_ProgramName   (__ExecutionContext) +"::"+ WindowExpertName();    // TODO: lost in deinit()
   __CHART          = ec_hChart        (__ExecutionContext) != 0;                         // TODO: noch dauerhaft falsch
   __LOG            = ec_Logging       (__ExecutionContext);                              // TODO: noch dauerhaft falsch
   __LOG_CUSTOM     = ec_InitFlags     (__ExecutionContext) & INIT_CUSTOMLOG && __LOG;    // TODO: noch dauerhaft falsch

   PipDigits        = Digits & (~1);                                        SubPipDigits      = PipDigits+1;
   PipPoints        = MathRound(MathPow(10, Digits & 1));                   PipPoint          = PipPoints;
   Pips             = NormalizeDouble(1/MathPow(10, PipDigits), PipDigits); Pip               = Pips;
   PipPriceFormat   = StringConcatenate(".", PipDigits);                    SubPipPriceFormat = StringConcatenate(PipPriceFormat, "'");   // TODO: lost in deinit()
   PriceFormat      = ifString(Digits==PipDigits, PipPriceFormat, SubPipPriceFormat);                                                     // TODO: lost in deinit()
   prev_error       = NO_ERROR;
   last_error       = NO_ERROR;

   // EA-Tasks
   if (IsExpert()) {
      OrderSelect(0, SELECT_BY_TICKET);                              // Orderkontext der Library wegen Bug ausdr�cklich zur�cksetzen (siehe MQL.doc)
      error = GetLastError();
      if (error && error!=ERR_NO_TICKET_SELECTED) return(catch("init(1)", error));

      if (IsTesting() && ec_InitCycle(__ExecutionContext)) {         // Bei Init-Cyle im Tester globale Variablen der Library zur�cksetzen.
         ArrayResize(stack.OrderSelect, 0);                          // in stdfunctions global definierte Variable
         Tester.ResetGlobalLibraryVars();
      }
   }

   onInit();
   return(catch("init(2)"));
}


/**
 * Dummy-Startfunktion f�r Libraries. F�r den Compiler build 224 mu� ab einer unbestimmten Komplexit�t der Library eine start()-
 * Funktion existieren, damit die init()-Funktion aufgerufen wird.
 *
 * @return int - Fehlerstatus
 */
int start() {
   return(catch("start(1)", ERR_WRONG_JUMP));
}


/**
 * Deinitialisierung der Library.
 *
 * @return int - Fehlerstatus
 *
 *
 * TODO: Bei VisualMode=Off und regul�rem Testende (Testperiode zu Ende) bricht das Terminal komplexere Expert::deinit()
 *       Funktionen verfr�ht und mitten im Code ab (nicht erst nach 2.5 Sekunden).
 *       - Pr�fen, ob in diesem Fall Library::deinit() noch zuverl�ssig ausgef�hrt wird.
 *       - Beachten, da� die Library in diesem Fall bei Start des n�chsten Tests einen Init-Cycle durchf�hrt.
 */
int deinit() {
   int error = SyncLibContext_deinit(__ExecutionContext, UninitializeReason());
   if (!error) {
      onDeinit();
      catch("deinit(1)");
   }
   return(error|last_error|LeaveContext(__ExecutionContext));
}


/**
 * Gibt die ID des aktuellen Deinit()-Szenarios zur�ck. Kann nur in deinit() aufgerufen werden.
 *
 * @return int - ID oder NULL, falls ein Fehler auftrat
 */
int DeinitReason() {
   return(!catch("DeinitReason(1)", ERR_NOT_IMPLEMENTED));
}


/**
 * Whether or not the current program is an expert.
 *
 * @return bool
 */
bool IsExpert() {
   return(__ExecutionContext[I_EC.programType] & MT_EXPERT != 0);
}


/**
 * Whether or not the current program is a script.
 *
 * @return bool
 */
bool IsScript() {
   return(__ExecutionContext[I_EC.programType] & MT_SCRIPT != 0);
}


/**
 * Whether or not the current program is an indicator.
 *
 * @return bool
 */
bool IsIndicator() {
   return(__ExecutionContext[I_EC.programType] & MT_INDICATOR != 0);
}


/**
 * Whether or not the current module is a library.
 *
 * @return bool
 */
bool IsLibrary() {
   return(true);
}


/**
 * Check and update the program's error status and activate the flag __STATUS_OFF accordingly.
 *
 * @param  string location - location of the check
 * @param  int    setError - error to enforce
 *
 * @return bool - whether or not the flag __STATUS_OFF is set
 */
bool CheckErrors(string location, int setError = NULL) {
   // empty library stub
   return(false);
}


// ----------------------------------------------------------------------------------------------------------------------------


#import "rsfExpander.dll"
   bool   ec_InitCycle     (/*EXECUTION_CONTEXT*/int ec[]);
   int    ec_InitFlags     (/*EXECUTION_CONTEXT*/int ec[]);
   bool   ec_Logging       (/*EXECUTION_CONTEXT*/int ec[]);
   int    ec_lpSuperContext(/*EXECUTION_CONTEXT*/int ec[]);

   int    SyncLibContext_init  (int ec[], int uninitReason, int initFlags, int deinitFlags, string name, string symbol, int period, int digits, int isOptimization);
   int    SyncLibContext_deinit(int ec[], int uninitReason);
#import
