/**
 * Manage an additional indicator buffer. In MQL4.0 the terminal manages a maximum of 8 indicator buffers. Additional buffers
 * can be used but must be managed by the framework. Additional buffers are for internal calculations only, they can't be
 * automatically drawn on the chart nor accessed via iCustom().
 *
 * @param  int    id       - buffer id
 * @param  double buffer[] - buffer
 *
 * @return bool - success status
 */
bool ManageIndicatorBuffer(int id, double buffer[]) {
   // TODO: At the moment the function reallocates memory each time the number of bars changes.
   //       Pre-allocate excess memory and use a dynamic offset to improve the performance of additional buffers.
   //
   if (id < 0)                                                 return(!catch("ManageIndicatorBuffer(1)  invalid parameter id: "+ id, ERR_INVALID_PARAMETER));
   if (__ExecutionContext[EC.programCoreFunction] != CF_START) return(!catch("ManageIndicatorBuffer(2)  invalid calling context: "+ ProgramTypeDescription(__ExecutionContext[EC.programType]) +"::"+ CoreFunctionDescription(__ExecutionContext[EC.programCoreFunction]), ERR_ILLEGAL_STATE));
   if (!Bars)                                                  return(!catch("ManageIndicatorBuffer(3)  Tick="+ Tick +"  Bars=0", ERR_ILLEGAL_STATE));

   // maintain a metadata array {id => data[]} to support multiple buffers
   #define IB.Tick            0                                // last Tick value for detecting multiple calls during the same tick
   #define IB.Bars            1                                // last number of bars
   #define IB.FirstBarTime    2                                // last opentime of the newest bar
   #define IB.LastBarTime     3                                // last opentime of the oldest bar

   int data[][4];                                              // TODO: reset data on account change
   if (ArraySize(data) <= id) {
      ArrayResize(data, id+1);                                 // {id} is used as array key
   }
   int      prevTick         = data[id][IB.Tick        ];
   int      prevBars         = data[id][IB.Bars        ];
   datetime prevFirstBarTime = data[id][IB.FirstBarTime];
   datetime prevLastBarTime  = data[id][IB.LastBarTime ];

   if (Tick == prevTick) return(true);                         // execute only once per tick

   if (Bars == prevBars) {                                     // number of Bars unchanged
      if (Time[Bars-1] != prevLastBarTime) {                   // last bar changed: bars have been shifted off the end
         // TODO: find previous FirstBarTime and shift content accordingly
         return(!catch("ManageIndicatorBuffer(4)  Tick="+ Tick +", Bars unchanged but oldest bar changed, hit the timeseries MAX_CHART_BARS? (Bars="+ Bars +", lastBarTime="+ TimeToStr(Time[Bars-1], TIME_FULL) +", prevLastBarTime="+ TimeToStr(prevLastBarTime, TIME_FULL) +")", ERR_NOT_IMPLEMENTED));
      }
   }
   else {                                                      // number of Bars changed
      if (Bars < prevBars) return(!catch("ManageIndicatorBuffer(5)  Tick="+ Tick +", Bars decreased from "+ prevBars +" to "+ Bars +" (lastBarTime="+ TimeToStr(Time[Bars-1], TIME_FULL) +", prevLastBarTime="+ TimeToStr(prevLastBarTime, TIME_FULL) +")", ERR_ILLEGAL_STATE));
      // Bars increased
      ArraySetAsSeries(buffer, false);                         // update buffer size
      ArrayResize(buffer, Bars);
      ArraySetAsSeries(buffer, true);                          // Bars increased, new bars may have been inserted or appended: both cases are covered by ChangedBars

      if (prevBars && Time[Bars-1]!=prevLastBarTime) {         // Bars increased and last bar changed: additionally bars have been added by data pumping
         // TODO: find previous FirstBarTime and shift content accordingly
         if (IsLogDebug()) logDebug("ManageIndicatorBuffer(6)  Tick="+ Tick +", Bars increased and oldest bar changed (Bars="+ Bars +", prevBars="+ prevBars +", lastBarTime="+ TimeToStr(Time[Bars-1], TIME_FULL) +", prevLastBarTime="+ TimeToStr(prevLastBarTime, TIME_FULL) +")");
      }
   }

   data[id][IB.Tick        ] = Tick;
   data[id][IB.Bars        ] = Bars;
   data[id][IB.FirstBarTime] = Time[0];
   data[id][IB.LastBarTime ] = Time[Bars-1];

   // safety double-check
   if (ArraySize(buffer) != Bars)
      return(!catch("ManageIndicatorBuffer(7)  Tick="+ Tick +", size(buffer)="+ ArraySize(buffer) +" doesn't match Bars="+ Bars, ERR_RUNTIME_ERROR));
   return(!catch("ManageIndicatorBuffer(8)"));
}
