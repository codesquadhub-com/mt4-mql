/**
 * Test-Script f�r den MT4Expander
 */
#include <stddefine.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];
#include <core/script.mqh>
#include <stdfunctions.mqh>
#include <stdlib.mqh>


#import "Expander.Release.dll"

   bool Test_onInit  (int context[], int logLevel);
   bool Test_onStart (int context[], int logLevel);
   bool Test_onDeinit(int context[], int logLevel);

#import


/**
 *
 * @return int - Fehlerstatus
 */
int onInit() {
   Test_onInit(__ExecutionContext, L_DEBUG);
   return(last_error);
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onStart() {
   Test_onStart(__ExecutionContext, L_DEBUG);
   return(last_error);
}


/**
 *
 * @return int - Fehlerstatus
 */
int onDeinit() {
   Test_onDeinit(__ExecutionContext, L_DEBUG);
   return(last_error);
}
