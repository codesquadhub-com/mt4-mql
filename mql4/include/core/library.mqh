
/**
 * Dummy start()-Funktion f�r Libraries, siehe Bemerkungen bei init()
 *
 * @return int - Fehlerstatus
 *
 *
 * NOTE: F�r den Compiler v224 mu� ab einer unbestimmten Komplexit�t der Library eine start()-Funktion existieren,
 *       wenn eine init()-Funktion verwendet wird.
 */
int start() {
   return(catch("start()", ERR_WRONG_JUMP));
}


/**
 * Ob das aktuelle ausgef�hrte Programm ein Expert Adviser ist.
 *
 * @return bool
 */
bool IsExpert() {
   if (__TYPE__ == T_LIBRARY)
      return(_false(catch("IsExpert()   function must not be used before library initialization", ERR_RUNTIME_ERROR)));
   return(__TYPE__ & T_EXPERT);
}


/**
 * Ob das aktuelle ausgef�hrte Programm ein Indikator ist.
 *
 * @return bool
 */
bool IsIndicator() {
   if (__TYPE__ == T_LIBRARY)
      return(_false(catch("IsIndicator()   function must not be used before library initialization", ERR_RUNTIME_ERROR)));
   return(__TYPE__ & T_INDICATOR);
}


/**
 * Ob das aktuelle ausgef�hrte Programm ein Script ist.
 *
 * @return bool
 */
bool IsScript() {
   if (__TYPE__ == T_LIBRARY)
      return(_false(catch("IsScript()   function must not be used before library initialization", ERR_RUNTIME_ERROR)));
   return(__TYPE__ & T_SCRIPT);
}


/**
 * Ob das aktuelle ausgef�hrte Programm eine Library ist.
 *
 * @return bool
 */
bool IsLibrary() {
   return(true);
}
