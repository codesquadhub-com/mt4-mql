/**
 * Leeres Script, dem der Hotkey Strg-P zugeordnet ist und den unbeabsichtigten Aufruf des "Drucken"-Dialog abf�ngt.
 */
#include <stddefines.mqh>
int   __InitFlags[] = {INIT_NO_BARS_REQUIRED};
int __DeinitFlags[];
#include <core/script.mqh>
#include <stdfunctions.mqh>


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onStart() {
   return(last_error);
}
