/**
 * Umschaltzeiten von Normal- zu Sommerzeit und zur�ck f�r die integrierten Zeitzonen (1970 bis 2037).
 *
 *
 * Um die Ermittlung eines TZ-Offsets f�r einen Zeitpunkt zu beschleunigen, sind auch f�r Jahre, in denen kein Wechsel stattfindet,
 * Pseudozeiten angegeben. Durch diese Werte sind die Zeilenindizes eines jeden Jahres in allen Zeitzonen identisch:
 *
 *    int i = TimeYear(datetime) - 1970;
 *
 *
 * Logik:
 * ------
 *  if      (datetime < TR_TO_DST) offset = STD_OFFSET;     // Normalzeit zu Jahresbeginn
 *  else if (datetime < TR_TO_STD) offset = DST_OFFSET;     // DST
 *  else                           offset = STD_OFFSET;     // Normalzeit zu Jahresende
 *
 *
 * Szenarien:                           Wechsel zu DST (TR_TO_DST)              Wechsel zu Normalzeit (TR_TO_STD)
 * ----------                           ----------------------------------      ----------------------------------
 *  kein Wechsel, st�ndig Normalzeit:   -1                      DST_OFFSET      -1                      STD_OFFSET      // durchgehend Normalzeit
 *  kein Wechsel, st�ndig DST:          -1                      DST_OFFSET      INT_MAX                 STD_OFFSET      // durchgehend DST
 *  1 Wechsel zu DST:                   1975.04.11 00:00:00     DST_OFFSET      INT_MAX                 STD_OFFSET      // Jahr beginnt mit Normalzeit und endet mit DST
 *  1 Wechsel zu Normalzeit:            -1                      DST_OFFSET      1975.11.01 00:00:00     STD_OFFSET      // Jahr beginnt mit DST und endet mit Normalzeit
 *  2 Wechsel:                          1975.04.01 00:00:00     DST_OFFSET      1975.11.01 00:00:00     STD_OFFSET      // Normalzeit -> DST -> Normalzeit
 */

// Spaltenindizes der Transition-Arrays
//dow                            0
#define TR_TO_DST.gmt            1        // Umschaltzeit zu DST in GMT
//dow                            2
#define TR_TO_DST.local          3        // Umschaltzeit zu DST in lokaler Zeit
#define DST_OFFSET               4

//dow                            5
#define TR_TO_STD.gmt            6        // Umschaltzeit zu Normalzeit in GMT
//dow                            7
#define TR_TO_STD.local          8        // Umschaltzeit zu Normalzeit in lokaler Zeit
#define STD_OFFSET               9

#define MINUS_1_HOUR         -3600        // Timezone-Offsets
#define MINUS_2_HOURS        -7200
#define MINUS_3_HOURS       -10800
#define MINUS_4_HOURS       -14400
#define MINUS_5_HOURS       -18000
#define MINUS_6_HOURS       -21600
#define MINUS_7_HOURS       -25200
#define MINUS_8_HOURS       -28800
#define MINUS_9_HOURS       -32400
#define MINUS_10_HOURS      -36000
#define MINUS_11_HOURS      -39600
#define MINUS_12_HOURS      -43200

#define PLUS_1_HOUR           3600
#define PLUS_2_HOURS          7200
#define PLUS_3_HOURS         10800
#define PLUS_4_HOURS         14400
#define PLUS_5_HOURS         18000
#define PLUS_6_HOURS         21600
#define PLUS_7_HOURS         25200
#define PLUS_8_HOURS         28800
#define PLUS_9_HOURS         32400
#define PLUS_10_HOURS        36000
#define PLUS_11_HOURS        39600
#define PLUS_12_HOURS        43200


// Europe/Kiev: GMT+0200,GMT+0300
int transitions.Europe_Kiev[68][10] = {
   // Wechsel zu DST                                         DST-Offset       // Wechsel zu Normalzeit                                  Std.-Offset
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS, // durchgehend Normalzeit
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   TUE, D'1981.03.31 21:00:00', WED, D'1981.04.01 01:00:00', PLUS_4_HOURS,    WED, D'1981.09.30 20:00:00', WED, D'1981.09.30 23:00:00', PLUS_3_HOURS,
   WED, D'1982.03.31 21:00:00', THU, D'1982.04.01 01:00:00', PLUS_4_HOURS,    THU, D'1982.09.30 20:00:00', THU, D'1982.09.30 23:00:00', PLUS_3_HOURS,
   THU, D'1983.03.31 21:00:00', FRI, D'1983.04.01 01:00:00', PLUS_4_HOURS,    FRI, D'1983.09.30 20:00:00', FRI, D'1983.09.30 23:00:00', PLUS_3_HOURS,
   SAT, D'1984.03.31 21:00:00', SUN, D'1984.04.01 01:00:00', PLUS_4_HOURS,    SAT, D'1984.09.29 23:00:00', SUN, D'1984.09.30 02:00:00', PLUS_3_HOURS,
   SAT, D'1985.03.30 23:00:00', SUN, D'1985.03.31 03:00:00', PLUS_4_HOURS,    SAT, D'1985.09.28 23:00:00', SUN, D'1985.09.29 02:00:00', PLUS_3_HOURS,
   SAT, D'1986.03.29 23:00:00', SUN, D'1986.03.30 03:00:00', PLUS_4_HOURS,    SAT, D'1986.09.27 23:00:00', SUN, D'1986.09.28 02:00:00', PLUS_3_HOURS,
   SAT, D'1987.03.28 23:00:00', SUN, D'1987.03.29 03:00:00', PLUS_4_HOURS,    SAT, D'1987.09.26 23:00:00', SUN, D'1987.09.27 02:00:00', PLUS_3_HOURS,
   SAT, D'1988.03.26 23:00:00', SUN, D'1988.03.27 03:00:00', PLUS_4_HOURS,    SAT, D'1988.09.24 23:00:00', SUN, D'1988.09.25 02:00:00', PLUS_3_HOURS,
   SAT, D'1989.03.25 23:00:00', SUN, D'1989.03.26 03:00:00', PLUS_4_HOURS,    SAT, D'1989.09.23 23:00:00', SUN, D'1989.09.24 02:00:00', PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    SAT, D'1990.06.30 23:00:00', SUN, D'1990.07.01 01:00:00', PLUS_2_HOURS, // Offset�nderung
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_2_HOURS, // durchgehend Normalzeit
   SAT, D'1992.03.28 22:00:00', SUN, D'1992.03.29 01:00:00', PLUS_3_HOURS,    SAT, D'1992.09.26 21:00:00', SAT, D'1992.09.26 23:00:00', PLUS_2_HOURS,
   SAT, D'1993.03.27 22:00:00', SUN, D'1993.03.28 01:00:00', PLUS_3_HOURS,    SAT, D'1993.09.25 21:00:00', SAT, D'1993.09.25 23:00:00', PLUS_2_HOURS,
   SAT, D'1994.03.26 22:00:00', SUN, D'1994.03.27 01:00:00', PLUS_3_HOURS,    SAT, D'1994.09.24 21:00:00', SAT, D'1994.09.24 23:00:00', PLUS_2_HOURS,
   SUN, D'1995.03.26 01:00:00', SUN, D'1995.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'1995.09.24 01:00:00', SUN, D'1995.09.24 03:00:00', PLUS_2_HOURS,
   SUN, D'1996.03.31 01:00:00', SUN, D'1996.03.31 04:00:00', PLUS_3_HOURS,    SUN, D'1996.10.27 01:00:00', SUN, D'1996.10.27 03:00:00', PLUS_2_HOURS,
   SUN, D'1997.03.30 01:00:00', SUN, D'1997.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'1997.10.26 01:00:00', SUN, D'1997.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'1998.03.29 01:00:00', SUN, D'1998.03.29 04:00:00', PLUS_3_HOURS,    SUN, D'1998.10.25 01:00:00', SUN, D'1998.10.25 03:00:00', PLUS_2_HOURS,
   SUN, D'1999.03.28 01:00:00', SUN, D'1999.03.28 04:00:00', PLUS_3_HOURS,    SUN, D'1999.10.31 01:00:00', SUN, D'1999.10.31 03:00:00', PLUS_2_HOURS,
   SUN, D'2000.03.26 01:00:00', SUN, D'2000.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'2000.10.29 01:00:00', SUN, D'2000.10.29 03:00:00', PLUS_2_HOURS,
   SUN, D'2001.03.25 01:00:00', SUN, D'2001.03.25 04:00:00', PLUS_3_HOURS,    SUN, D'2001.10.28 01:00:00', SUN, D'2001.10.28 03:00:00', PLUS_2_HOURS,
   SUN, D'2002.03.31 01:00:00', SUN, D'2002.03.31 04:00:00', PLUS_3_HOURS,    SUN, D'2002.10.27 01:00:00', SUN, D'2002.10.27 03:00:00', PLUS_2_HOURS,
   SUN, D'2003.03.30 01:00:00', SUN, D'2003.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'2003.10.26 01:00:00', SUN, D'2003.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'2004.03.28 01:00:00', SUN, D'2004.03.28 04:00:00', PLUS_3_HOURS,    SUN, D'2004.10.31 01:00:00', SUN, D'2004.10.31 03:00:00', PLUS_2_HOURS,
   SUN, D'2005.03.27 01:00:00', SUN, D'2005.03.27 04:00:00', PLUS_3_HOURS,    SUN, D'2005.10.30 01:00:00', SUN, D'2005.10.30 03:00:00', PLUS_2_HOURS,
   SUN, D'2006.03.26 01:00:00', SUN, D'2006.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'2006.10.29 01:00:00', SUN, D'2006.10.29 03:00:00', PLUS_2_HOURS,
   SUN, D'2007.03.25 01:00:00', SUN, D'2007.03.25 04:00:00', PLUS_3_HOURS,    SUN, D'2007.10.28 01:00:00', SUN, D'2007.10.28 03:00:00', PLUS_2_HOURS,
   SUN, D'2008.03.30 01:00:00', SUN, D'2008.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'2008.10.26 01:00:00', SUN, D'2008.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'2009.03.29 01:00:00', SUN, D'2009.03.29 04:00:00', PLUS_3_HOURS,    SUN, D'2009.10.25 01:00:00', SUN, D'2009.10.25 03:00:00', PLUS_2_HOURS,
   SUN, D'2010.03.28 01:00:00', SUN, D'2010.03.28 04:00:00', PLUS_3_HOURS,    SUN, D'2010.10.31 01:00:00', SUN, D'2010.10.31 03:00:00', PLUS_2_HOURS,
   SUN, D'2011.03.27 01:00:00', SUN, D'2011.03.27 04:00:00', PLUS_3_HOURS,    SUN, D'2011.10.30 01:00:00', SUN, D'2011.10.30 03:00:00', PLUS_2_HOURS,
   SUN, D'2012.03.25 01:00:00', SUN, D'2012.03.25 04:00:00', PLUS_3_HOURS,    SUN, D'2012.10.28 01:00:00', SUN, D'2012.10.28 03:00:00', PLUS_2_HOURS,
   SUN, D'2013.03.31 01:00:00', SUN, D'2013.03.31 04:00:00', PLUS_3_HOURS,    SUN, D'2013.10.27 01:00:00', SUN, D'2013.10.27 03:00:00', PLUS_2_HOURS,
   SUN, D'2014.03.30 01:00:00', SUN, D'2014.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'2014.10.26 01:00:00', SUN, D'2014.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'2015.03.29 01:00:00', SUN, D'2015.03.29 04:00:00', PLUS_3_HOURS,    SUN, D'2015.10.25 01:00:00', SUN, D'2015.10.25 03:00:00', PLUS_2_HOURS,
   SUN, D'2016.03.27 01:00:00', SUN, D'2016.03.27 04:00:00', PLUS_3_HOURS,    SUN, D'2016.10.30 01:00:00', SUN, D'2016.10.30 03:00:00', PLUS_2_HOURS,
   SUN, D'2017.03.26 01:00:00', SUN, D'2017.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'2017.10.29 01:00:00', SUN, D'2017.10.29 03:00:00', PLUS_2_HOURS,
   SUN, D'2018.03.25 01:00:00', SUN, D'2018.03.25 04:00:00', PLUS_3_HOURS,    SUN, D'2018.10.28 01:00:00', SUN, D'2018.10.28 03:00:00', PLUS_2_HOURS,
   SUN, D'2019.03.31 01:00:00', SUN, D'2019.03.31 04:00:00', PLUS_3_HOURS,    SUN, D'2019.10.27 01:00:00', SUN, D'2019.10.27 03:00:00', PLUS_2_HOURS,
   SUN, D'2020.03.29 01:00:00', SUN, D'2020.03.29 04:00:00', PLUS_3_HOURS,    SUN, D'2020.10.25 01:00:00', SUN, D'2020.10.25 03:00:00', PLUS_2_HOURS,
   SUN, D'2021.03.28 01:00:00', SUN, D'2021.03.28 04:00:00', PLUS_3_HOURS,    SUN, D'2021.10.31 01:00:00', SUN, D'2021.10.31 03:00:00', PLUS_2_HOURS,
   SUN, D'2022.03.27 01:00:00', SUN, D'2022.03.27 04:00:00', PLUS_3_HOURS,    SUN, D'2022.10.30 01:00:00', SUN, D'2022.10.30 03:00:00', PLUS_2_HOURS,
   SUN, D'2023.03.26 01:00:00', SUN, D'2023.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'2023.10.29 01:00:00', SUN, D'2023.10.29 03:00:00', PLUS_2_HOURS,
   SUN, D'2024.03.31 01:00:00', SUN, D'2024.03.31 04:00:00', PLUS_3_HOURS,    SUN, D'2024.10.27 01:00:00', SUN, D'2024.10.27 03:00:00', PLUS_2_HOURS,
   SUN, D'2025.03.30 01:00:00', SUN, D'2025.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'2025.10.26 01:00:00', SUN, D'2025.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'2026.03.29 01:00:00', SUN, D'2026.03.29 04:00:00', PLUS_3_HOURS,    SUN, D'2026.10.25 01:00:00', SUN, D'2026.10.25 03:00:00', PLUS_2_HOURS,
   SUN, D'2027.03.28 01:00:00', SUN, D'2027.03.28 04:00:00', PLUS_3_HOURS,    SUN, D'2027.10.31 01:00:00', SUN, D'2027.10.31 03:00:00', PLUS_2_HOURS,
   SUN, D'2028.03.26 01:00:00', SUN, D'2028.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'2028.10.29 01:00:00', SUN, D'2028.10.29 03:00:00', PLUS_2_HOURS,
   SUN, D'2029.03.25 01:00:00', SUN, D'2029.03.25 04:00:00', PLUS_3_HOURS,    SUN, D'2029.10.28 01:00:00', SUN, D'2029.10.28 03:00:00', PLUS_2_HOURS,
   SUN, D'2030.03.31 01:00:00', SUN, D'2030.03.31 04:00:00', PLUS_3_HOURS,    SUN, D'2030.10.27 01:00:00', SUN, D'2030.10.27 03:00:00', PLUS_2_HOURS,
   SUN, D'2031.03.30 01:00:00', SUN, D'2031.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'2031.10.26 01:00:00', SUN, D'2031.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'2032.03.28 01:00:00', SUN, D'2032.03.28 04:00:00', PLUS_3_HOURS,    SUN, D'2032.10.31 01:00:00', SUN, D'2032.10.31 03:00:00', PLUS_2_HOURS,
   SUN, D'2033.03.27 01:00:00', SUN, D'2033.03.27 04:00:00', PLUS_3_HOURS,    SUN, D'2033.10.30 01:00:00', SUN, D'2033.10.30 03:00:00', PLUS_2_HOURS,
   SUN, D'2034.03.26 01:00:00', SUN, D'2034.03.26 04:00:00', PLUS_3_HOURS,    SUN, D'2034.10.29 01:00:00', SUN, D'2034.10.29 03:00:00', PLUS_2_HOURS,
   SUN, D'2035.03.25 01:00:00', SUN, D'2035.03.25 04:00:00', PLUS_3_HOURS,    SUN, D'2035.10.28 01:00:00', SUN, D'2035.10.28 03:00:00', PLUS_2_HOURS,
   SUN, D'2036.03.30 01:00:00', SUN, D'2036.03.30 04:00:00', PLUS_3_HOURS,    SUN, D'2036.10.26 01:00:00', SUN, D'2036.10.26 03:00:00', PLUS_2_HOURS,
   SUN, D'2037.03.29 01:00:00', SUN, D'2037.03.29 04:00:00', PLUS_3_HOURS,    SUN, D'2037.10.25 01:00:00', SUN, D'2037.10.25 03:00:00', PLUS_2_HOURS,
};


// FXT: GMT+0200,GMT+0300 (Umschaltzeiten von America/New_York, Offsets von Europe/Kiev: entspricht also America/New_York+0700 = Forex Standard Time)
int transitions.FXT[68][10] = {
   // Wechsel zu DST                                         DST-Offset       // Wechsel zu Normalzeit                                  Std.-Offset
   SUN, D'1970.04.26 07:00:00', SUN, D'1970.04.26 10:00:00', PLUS_3_HOURS,    SUN, D'1970.10.25 06:00:00', SUN, D'1970.10.25 08:00:00', PLUS_2_HOURS,
   SUN, D'1971.04.25 07:00:00', SUN, D'1971.04.25 10:00:00', PLUS_3_HOURS,    SUN, D'1971.10.31 06:00:00', SUN, D'1971.10.31 08:00:00', PLUS_2_HOURS,
   SUN, D'1972.04.30 07:00:00', SUN, D'1972.04.30 10:00:00', PLUS_3_HOURS,    SUN, D'1972.10.29 06:00:00', SUN, D'1972.10.29 08:00:00', PLUS_2_HOURS,
   SUN, D'1973.04.29 07:00:00', SUN, D'1973.04.29 10:00:00', PLUS_3_HOURS,    SUN, D'1973.10.28 06:00:00', SUN, D'1973.10.28 08:00:00', PLUS_2_HOURS,
   SUN, D'1974.01.06 07:00:00', SUN, D'1974.01.06 10:00:00', PLUS_3_HOURS,    SUN, D'1974.10.27 06:00:00', SUN, D'1974.10.27 08:00:00', PLUS_2_HOURS,
   SUN, D'1975.02.23 07:00:00', SUN, D'1975.02.23 10:00:00', PLUS_3_HOURS,    SUN, D'1975.10.26 06:00:00', SUN, D'1975.10.26 08:00:00', PLUS_2_HOURS,
   SUN, D'1976.04.25 07:00:00', SUN, D'1976.04.25 10:00:00', PLUS_3_HOURS,    SUN, D'1976.10.31 06:00:00', SUN, D'1976.10.31 08:00:00', PLUS_2_HOURS,
   SUN, D'1977.04.24 07:00:00', SUN, D'1977.04.24 10:00:00', PLUS_3_HOURS,    SUN, D'1977.10.30 06:00:00', SUN, D'1977.10.30 08:00:00', PLUS_2_HOURS,
   SUN, D'1978.04.30 07:00:00', SUN, D'1978.04.30 10:00:00', PLUS_3_HOURS,    SUN, D'1978.10.29 06:00:00', SUN, D'1978.10.29 08:00:00', PLUS_2_HOURS,
   SUN, D'1979.04.29 07:00:00', SUN, D'1979.04.29 10:00:00', PLUS_3_HOURS,    SUN, D'1979.10.28 06:00:00', SUN, D'1979.10.28 08:00:00', PLUS_2_HOURS,
   SUN, D'1980.04.27 07:00:00', SUN, D'1980.04.27 10:00:00', PLUS_3_HOURS,    SUN, D'1980.10.26 06:00:00', SUN, D'1980.10.26 08:00:00', PLUS_2_HOURS,
   SUN, D'1981.04.26 07:00:00', SUN, D'1981.04.26 10:00:00', PLUS_3_HOURS,    SUN, D'1981.10.25 06:00:00', SUN, D'1981.10.25 08:00:00', PLUS_2_HOURS,
   SUN, D'1982.04.25 07:00:00', SUN, D'1982.04.25 10:00:00', PLUS_3_HOURS,    SUN, D'1982.10.31 06:00:00', SUN, D'1982.10.31 08:00:00', PLUS_2_HOURS,
   SUN, D'1983.04.24 07:00:00', SUN, D'1983.04.24 10:00:00', PLUS_3_HOURS,    SUN, D'1983.10.30 06:00:00', SUN, D'1983.10.30 08:00:00', PLUS_2_HOURS,
   SUN, D'1984.04.29 07:00:00', SUN, D'1984.04.29 10:00:00', PLUS_3_HOURS,    SUN, D'1984.10.28 06:00:00', SUN, D'1984.10.28 08:00:00', PLUS_2_HOURS,
   SUN, D'1985.04.28 07:00:00', SUN, D'1985.04.28 10:00:00', PLUS_3_HOURS,    SUN, D'1985.10.27 06:00:00', SUN, D'1985.10.27 08:00:00', PLUS_2_HOURS,
   SUN, D'1986.04.27 07:00:00', SUN, D'1986.04.27 10:00:00', PLUS_3_HOURS,    SUN, D'1986.10.26 06:00:00', SUN, D'1986.10.26 08:00:00', PLUS_2_HOURS,
   SUN, D'1987.04.05 07:00:00', SUN, D'1987.04.05 10:00:00', PLUS_3_HOURS,    SUN, D'1987.10.25 06:00:00', SUN, D'1987.10.25 08:00:00', PLUS_2_HOURS,
   SUN, D'1988.04.03 07:00:00', SUN, D'1988.04.03 10:00:00', PLUS_3_HOURS,    SUN, D'1988.10.30 06:00:00', SUN, D'1988.10.30 08:00:00', PLUS_2_HOURS,
   SUN, D'1989.04.02 07:00:00', SUN, D'1989.04.02 10:00:00', PLUS_3_HOURS,    SUN, D'1989.10.29 06:00:00', SUN, D'1989.10.29 08:00:00', PLUS_2_HOURS,
   SUN, D'1990.04.01 07:00:00', SUN, D'1990.04.01 10:00:00', PLUS_3_HOURS,    SUN, D'1990.10.28 06:00:00', SUN, D'1990.10.28 08:00:00', PLUS_2_HOURS,
   SUN, D'1991.04.07 07:00:00', SUN, D'1991.04.07 10:00:00', PLUS_3_HOURS,    SUN, D'1991.10.27 06:00:00', SUN, D'1991.10.27 08:00:00', PLUS_2_HOURS,
   SUN, D'1992.04.05 07:00:00', SUN, D'1992.04.05 10:00:00', PLUS_3_HOURS,    SUN, D'1992.10.25 06:00:00', SUN, D'1992.10.25 08:00:00', PLUS_2_HOURS,
   SUN, D'1993.04.04 07:00:00', SUN, D'1993.04.04 10:00:00', PLUS_3_HOURS,    SUN, D'1993.10.31 06:00:00', SUN, D'1993.10.31 08:00:00', PLUS_2_HOURS,
   SUN, D'1994.04.03 07:00:00', SUN, D'1994.04.03 10:00:00', PLUS_3_HOURS,    SUN, D'1994.10.30 06:00:00', SUN, D'1994.10.30 08:00:00', PLUS_2_HOURS,
   SUN, D'1995.04.02 07:00:00', SUN, D'1995.04.02 10:00:00', PLUS_3_HOURS,    SUN, D'1995.10.29 06:00:00', SUN, D'1995.10.29 08:00:00', PLUS_2_HOURS,
   SUN, D'1996.04.07 07:00:00', SUN, D'1996.04.07 10:00:00', PLUS_3_HOURS,    SUN, D'1996.10.27 06:00:00', SUN, D'1996.10.27 08:00:00', PLUS_2_HOURS,
   SUN, D'1997.04.06 07:00:00', SUN, D'1997.04.06 10:00:00', PLUS_3_HOURS,    SUN, D'1997.10.26 06:00:00', SUN, D'1997.10.26 08:00:00', PLUS_2_HOURS,
   SUN, D'1998.04.05 07:00:00', SUN, D'1998.04.05 10:00:00', PLUS_3_HOURS,    SUN, D'1998.10.25 06:00:00', SUN, D'1998.10.25 08:00:00', PLUS_2_HOURS,
   SUN, D'1999.04.04 07:00:00', SUN, D'1999.04.04 10:00:00', PLUS_3_HOURS,    SUN, D'1999.10.31 06:00:00', SUN, D'1999.10.31 08:00:00', PLUS_2_HOURS,
   SUN, D'2000.04.02 07:00:00', SUN, D'2000.04.02 10:00:00', PLUS_3_HOURS,    SUN, D'2000.10.29 06:00:00', SUN, D'2000.10.29 08:00:00', PLUS_2_HOURS,
   SUN, D'2001.04.01 07:00:00', SUN, D'2001.04.01 10:00:00', PLUS_3_HOURS,    SUN, D'2001.10.28 06:00:00', SUN, D'2001.10.28 08:00:00', PLUS_2_HOURS,
   SUN, D'2002.04.07 07:00:00', SUN, D'2002.04.07 10:00:00', PLUS_3_HOURS,    SUN, D'2002.10.27 06:00:00', SUN, D'2002.10.27 08:00:00', PLUS_2_HOURS,
   SUN, D'2003.04.06 07:00:00', SUN, D'2003.04.06 10:00:00', PLUS_3_HOURS,    SUN, D'2003.10.26 06:00:00', SUN, D'2003.10.26 08:00:00', PLUS_2_HOURS,
   SUN, D'2004.04.04 07:00:00', SUN, D'2004.04.04 10:00:00', PLUS_3_HOURS,    SUN, D'2004.10.31 06:00:00', SUN, D'2004.10.31 08:00:00', PLUS_2_HOURS,
   SUN, D'2005.04.03 07:00:00', SUN, D'2005.04.03 10:00:00', PLUS_3_HOURS,    SUN, D'2005.10.30 06:00:00', SUN, D'2005.10.30 08:00:00', PLUS_2_HOURS,
   SUN, D'2006.04.02 07:00:00', SUN, D'2006.04.02 10:00:00', PLUS_3_HOURS,    SUN, D'2006.10.29 06:00:00', SUN, D'2006.10.29 08:00:00', PLUS_2_HOURS,
   SUN, D'2007.03.11 07:00:00', SUN, D'2007.03.11 10:00:00', PLUS_3_HOURS,    SUN, D'2007.11.04 06:00:00', SUN, D'2007.11.04 08:00:00', PLUS_2_HOURS,
   SUN, D'2008.03.09 07:00:00', SUN, D'2008.03.09 10:00:00', PLUS_3_HOURS,    SUN, D'2008.11.02 06:00:00', SUN, D'2008.11.02 08:00:00', PLUS_2_HOURS,
   SUN, D'2009.03.08 07:00:00', SUN, D'2009.03.08 10:00:00', PLUS_3_HOURS,    SUN, D'2009.11.01 06:00:00', SUN, D'2009.11.01 08:00:00', PLUS_2_HOURS,
   SUN, D'2010.03.14 07:00:00', SUN, D'2010.03.14 10:00:00', PLUS_3_HOURS,    SUN, D'2010.11.07 06:00:00', SUN, D'2010.11.07 08:00:00', PLUS_2_HOURS,
   SUN, D'2011.03.13 07:00:00', SUN, D'2011.03.13 10:00:00', PLUS_3_HOURS,    SUN, D'2011.11.06 06:00:00', SUN, D'2011.11.06 08:00:00', PLUS_2_HOURS,
   SUN, D'2012.03.11 07:00:00', SUN, D'2012.03.11 10:00:00', PLUS_3_HOURS,    SUN, D'2012.11.04 06:00:00', SUN, D'2012.11.04 08:00:00', PLUS_2_HOURS,
   SUN, D'2013.03.10 07:00:00', SUN, D'2013.03.10 10:00:00', PLUS_3_HOURS,    SUN, D'2013.11.03 06:00:00', SUN, D'2013.11.03 08:00:00', PLUS_2_HOURS,
   SUN, D'2014.03.09 07:00:00', SUN, D'2014.03.09 10:00:00', PLUS_3_HOURS,    SUN, D'2014.11.02 06:00:00', SUN, D'2014.11.02 08:00:00', PLUS_2_HOURS,
   SUN, D'2015.03.08 07:00:00', SUN, D'2015.03.08 10:00:00', PLUS_3_HOURS,    SUN, D'2015.11.01 06:00:00', SUN, D'2015.11.01 08:00:00', PLUS_2_HOURS,
   SUN, D'2016.03.13 07:00:00', SUN, D'2016.03.13 10:00:00', PLUS_3_HOURS,    SUN, D'2016.11.06 06:00:00', SUN, D'2016.11.06 08:00:00', PLUS_2_HOURS,
   SUN, D'2017.03.12 07:00:00', SUN, D'2017.03.12 10:00:00', PLUS_3_HOURS,    SUN, D'2017.11.05 06:00:00', SUN, D'2017.11.05 08:00:00', PLUS_2_HOURS,
   SUN, D'2018.03.11 07:00:00', SUN, D'2018.03.11 10:00:00', PLUS_3_HOURS,    SUN, D'2018.11.04 06:00:00', SUN, D'2018.11.04 08:00:00', PLUS_2_HOURS,
   SUN, D'2019.03.10 07:00:00', SUN, D'2019.03.10 10:00:00', PLUS_3_HOURS,    SUN, D'2019.11.03 06:00:00', SUN, D'2019.11.03 08:00:00', PLUS_2_HOURS,
   SUN, D'2020.03.08 07:00:00', SUN, D'2020.03.08 10:00:00', PLUS_3_HOURS,    SUN, D'2020.11.01 06:00:00', SUN, D'2020.11.01 08:00:00', PLUS_2_HOURS,
   SUN, D'2021.03.14 07:00:00', SUN, D'2021.03.14 10:00:00', PLUS_3_HOURS,    SUN, D'2021.11.07 06:00:00', SUN, D'2021.11.07 08:00:00', PLUS_2_HOURS,
   SUN, D'2022.03.13 07:00:00', SUN, D'2022.03.13 10:00:00', PLUS_3_HOURS,    SUN, D'2022.11.06 06:00:00', SUN, D'2022.11.06 08:00:00', PLUS_2_HOURS,
   SUN, D'2023.03.12 07:00:00', SUN, D'2023.03.12 10:00:00', PLUS_3_HOURS,    SUN, D'2023.11.05 06:00:00', SUN, D'2023.11.05 08:00:00', PLUS_2_HOURS,
   SUN, D'2024.03.10 07:00:00', SUN, D'2024.03.10 10:00:00', PLUS_3_HOURS,    SUN, D'2024.11.03 06:00:00', SUN, D'2024.11.03 08:00:00', PLUS_2_HOURS,
   SUN, D'2025.03.09 07:00:00', SUN, D'2025.03.09 10:00:00', PLUS_3_HOURS,    SUN, D'2025.11.02 06:00:00', SUN, D'2025.11.02 08:00:00', PLUS_2_HOURS,
   SUN, D'2026.03.08 07:00:00', SUN, D'2026.03.08 10:00:00', PLUS_3_HOURS,    SUN, D'2026.11.01 06:00:00', SUN, D'2026.11.01 08:00:00', PLUS_2_HOURS,
   SUN, D'2027.03.14 07:00:00', SUN, D'2027.03.14 10:00:00', PLUS_3_HOURS,    SUN, D'2027.11.07 06:00:00', SUN, D'2027.11.07 08:00:00', PLUS_2_HOURS,
   SUN, D'2028.03.12 07:00:00', SUN, D'2028.03.12 10:00:00', PLUS_3_HOURS,    SUN, D'2028.11.05 06:00:00', SUN, D'2028.11.05 08:00:00', PLUS_2_HOURS,
   SUN, D'2029.03.11 07:00:00', SUN, D'2029.03.11 10:00:00', PLUS_3_HOURS,    SUN, D'2029.11.04 06:00:00', SUN, D'2029.11.04 08:00:00', PLUS_2_HOURS,
   SUN, D'2030.03.10 07:00:00', SUN, D'2030.03.10 10:00:00', PLUS_3_HOURS,    SUN, D'2030.11.03 06:00:00', SUN, D'2030.11.03 08:00:00', PLUS_2_HOURS,
   SUN, D'2031.03.09 07:00:00', SUN, D'2031.03.09 10:00:00', PLUS_3_HOURS,    SUN, D'2031.11.02 06:00:00', SUN, D'2031.11.02 08:00:00', PLUS_2_HOURS,
   SUN, D'2032.03.14 07:00:00', SUN, D'2032.03.14 10:00:00', PLUS_3_HOURS,    SUN, D'2032.11.07 06:00:00', SUN, D'2032.11.07 08:00:00', PLUS_2_HOURS,
   SUN, D'2033.03.13 07:00:00', SUN, D'2033.03.13 10:00:00', PLUS_3_HOURS,    SUN, D'2033.11.06 06:00:00', SUN, D'2033.11.06 08:00:00', PLUS_2_HOURS,
   SUN, D'2034.03.12 07:00:00', SUN, D'2034.03.12 10:00:00', PLUS_3_HOURS,    SUN, D'2034.11.05 06:00:00', SUN, D'2034.11.05 08:00:00', PLUS_2_HOURS,
   SUN, D'2035.03.11 07:00:00', SUN, D'2035.03.11 10:00:00', PLUS_3_HOURS,    SUN, D'2035.11.04 06:00:00', SUN, D'2035.11.04 08:00:00', PLUS_2_HOURS,
   SUN, D'2036.03.09 07:00:00', SUN, D'2036.03.09 10:00:00', PLUS_3_HOURS,    SUN, D'2036.11.02 06:00:00', SUN, D'2036.11.02 08:00:00', PLUS_2_HOURS,
   SUN, D'2037.03.08 07:00:00', SUN, D'2037.03.08 10:00:00', PLUS_3_HOURS,    SUN, D'2037.11.01 06:00:00', SUN, D'2037.11.01 08:00:00', PLUS_2_HOURS,
};


// Europe/Minsk: GMT+0200,GMT+0300 (seit Sommer 2011 durchgehend Sommerzeit, davor wie Europe/Kiev)
int transitions.Europe_Minsk[68][10] = {
   // Wechsel zu DST                                         DST-Offset       // Wechsel zu Normalzeit                                  Std.-Offset
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS, // durchgehend Normalzeit
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,
   TUE, D'1981.03.31 21:00:00', WED, D'1981.04.01 01:00:00', PLUS_4_HOURS,    WED, D'1981.09.30 20:00:00', WED, D'1981.09.30 23:00:00', PLUS_3_HOURS,
   WED, D'1982.03.31 21:00:00', THU, D'1982.04.01 01:00:00', PLUS_4_HOURS,    THU, D'1982.09.30 20:00:00', THU, D'1982.09.30 23:00:00', PLUS_3_HOURS,
   THU, D'1983.03.31 21:00:00', FRI, D'1983.04.01 01:00:00', PLUS_4_HOURS,    FRI, D'1983.09.30 20:00:00', FRI, D'1983.09.30 23:00:00', PLUS_3_HOURS,
   SAT, D'1984.03.31 21:00:00', SUN, D'1984.04.01 01:00:00', PLUS_4_HOURS,    SAT, D'1984.09.29 23:00:00', SUN, D'1984.09.30 02:00:00', PLUS_3_HOURS,
   SAT, D'1985.03.30 23:00:00', SUN, D'1985.03.31 03:00:00', PLUS_4_HOURS,    SAT, D'1985.09.28 23:00:00', SUN, D'1985.09.29 02:00:00', PLUS_3_HOURS,
   SAT, D'1986.03.29 23:00:00', SUN, D'1986.03.30 03:00:00', PLUS_4_HOURS,    SAT, D'1986.09.27 23:00:00', SUN, D'1986.09.28 02:00:00', PLUS_3_HOURS,
   SAT, D'1987.03.28 23:00:00', SUN, D'1987.03.29 03:00:00', PLUS_4_HOURS,    SAT, D'1987.09.26 23:00:00', SUN, D'1987.09.27 02:00:00', PLUS_3_HOURS,
   SAT, D'1988.03.26 23:00:00', SUN, D'1988.03.27 03:00:00', PLUS_4_HOURS,    SAT, D'1988.09.24 23:00:00', SUN, D'1988.09.25 02:00:00', PLUS_3_HOURS,
   SAT, D'1989.03.25 23:00:00', SUN, D'1989.03.26 03:00:00', PLUS_4_HOURS,    SAT, D'1989.09.23 23:00:00', SUN, D'1989.09.24 02:00:00', PLUS_3_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_4_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_3_HOURS, // durchgehend Normalzeit
   SAT, D'1991.03.30 23:00:00', SUN, D'1991.03.31 02:00:00', PLUS_3_HOURS,    SUN, D'1991.09.29 00:00:00', SUN, D'1991.09.29 02:00:00', PLUS_2_HOURS, // Offset�nderung
   SAT, D'1992.03.28 22:00:00', SUN, D'1992.03.29 01:00:00', PLUS_3_HOURS,    SAT, D'1992.09.26 22:00:00', SUN, D'1992.09.27 00:00:00', PLUS_2_HOURS,
   SUN, D'1993.03.28 00:00:00', SUN, D'1993.03.28 03:00:00', PLUS_3_HOURS,    SUN, D'1993.09.26 00:00:00', SUN, D'1993.09.26 02:00:00', PLUS_2_HOURS,
   SUN, D'1994.03.27 00:00:00', SUN, D'1994.03.27 03:00:00', PLUS_3_HOURS,    SUN, D'1994.09.25 00:00:00', SUN, D'1994.09.25 02:00:00', PLUS_2_HOURS,
   SUN, D'1995.03.26 00:00:00', SUN, D'1995.03.26 03:00:00', PLUS_3_HOURS,    SUN, D'1995.09.24 00:00:00', SUN, D'1995.09.24 02:00:00', PLUS_2_HOURS,
   SUN, D'1996.03.31 00:00:00', SUN, D'1996.03.31 03:00:00', PLUS_3_HOURS,    SUN, D'1996.10.27 00:00:00', SUN, D'1996.10.27 02:00:00', PLUS_2_HOURS,
   SUN, D'1997.03.30 00:00:00', SUN, D'1997.03.30 03:00:00', PLUS_3_HOURS,    SUN, D'1997.10.26 00:00:00', SUN, D'1997.10.26 02:00:00', PLUS_2_HOURS,
   SUN, D'1998.03.29 00:00:00', SUN, D'1998.03.29 03:00:00', PLUS_3_HOURS,    SUN, D'1998.10.25 00:00:00', SUN, D'1998.10.25 02:00:00', PLUS_2_HOURS,
   SUN, D'1999.03.28 00:00:00', SUN, D'1999.03.28 03:00:00', PLUS_3_HOURS,    SUN, D'1999.10.31 00:00:00', SUN, D'1999.10.31 02:00:00', PLUS_2_HOURS,
   SUN, D'2000.03.26 00:00:00', SUN, D'2000.03.26 03:00:00', PLUS_3_HOURS,    SUN, D'2000.10.29 00:00:00', SUN, D'2000.10.29 02:00:00', PLUS_2_HOURS,
   SUN, D'2001.03.25 00:00:00', SUN, D'2001.03.25 03:00:00', PLUS_3_HOURS,    SUN, D'2001.10.28 00:00:00', SUN, D'2001.10.28 02:00:00', PLUS_2_HOURS,
   SUN, D'2002.03.31 00:00:00', SUN, D'2002.03.31 03:00:00', PLUS_3_HOURS,    SUN, D'2002.10.27 00:00:00', SUN, D'2002.10.27 02:00:00', PLUS_2_HOURS,
   SUN, D'2003.03.30 00:00:00', SUN, D'2003.03.30 03:00:00', PLUS_3_HOURS,    SUN, D'2003.10.26 00:00:00', SUN, D'2003.10.26 02:00:00', PLUS_2_HOURS,
   SUN, D'2004.03.28 00:00:00', SUN, D'2004.03.28 03:00:00', PLUS_3_HOURS,    SUN, D'2004.10.31 00:00:00', SUN, D'2004.10.31 02:00:00', PLUS_2_HOURS,
   SUN, D'2005.03.27 00:00:00', SUN, D'2005.03.27 03:00:00', PLUS_3_HOURS,    SUN, D'2005.10.30 00:00:00', SUN, D'2005.10.30 02:00:00', PLUS_2_HOURS,
   SUN, D'2006.03.26 00:00:00', SUN, D'2006.03.26 03:00:00', PLUS_3_HOURS,    SUN, D'2006.10.29 00:00:00', SUN, D'2006.10.29 02:00:00', PLUS_2_HOURS,
   SUN, D'2007.03.25 00:00:00', SUN, D'2007.03.25 03:00:00', PLUS_3_HOURS,    SUN, D'2007.10.28 00:00:00', SUN, D'2007.10.28 02:00:00', PLUS_2_HOURS,
   SUN, D'2008.03.30 00:00:00', SUN, D'2008.03.30 03:00:00', PLUS_3_HOURS,    SUN, D'2008.10.26 00:00:00', SUN, D'2008.10.26 02:00:00', PLUS_2_HOURS,
   SUN, D'2009.03.29 00:00:00', SUN, D'2009.03.29 03:00:00', PLUS_3_HOURS,    SUN, D'2009.10.25 00:00:00', SUN, D'2009.10.25 02:00:00', PLUS_2_HOURS,
   SUN, D'2010.03.28 00:00:00', SUN, D'2010.03.28 03:00:00', PLUS_3_HOURS,    SUN, D'2010.10.31 00:00:00', SUN, D'2010.10.31 02:00:00', PLUS_2_HOURS,
   SUN, D'2011.03.27 00:00:00', SUN, D'2011.03.27 03:00:00', PLUS_3_HOURS,    SUN, INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS, // seit Sommer 2011
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS, // durchgehend Sommerzeit
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
   -1,  -1,                     -1,  -1,                     PLUS_3_HOURS,    -1,  INT_MAX,                -1,  INT_MAX,                PLUS_2_HOURS,
};


// Europe/Berlin: GMT+0100,GMT+0200
int transitions.Europe_Berlin[68][10] = {
   // Wechsel zu DST                                         DST-Offset       // Wechsel zu Normalzeit                                  Std.-Offset
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,  // durchgehend Normalzeit
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   -1,  -1,                     -1,  -1,                     PLUS_2_HOURS,    -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,
   SUN, D'1980.04.06 01:00:00', SUN, D'1980.04.06 03:00:00', PLUS_2_HOURS,    SUN, D'1980.09.28 01:00:00', SUN, D'1980.09.28 02:00:00', PLUS_1_HOUR,
   SUN, D'1981.03.29 01:00:00', SUN, D'1981.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'1981.09.27 01:00:00', SUN, D'1981.09.27 02:00:00', PLUS_1_HOUR,
   SUN, D'1982.03.28 01:00:00', SUN, D'1982.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'1982.09.26 01:00:00', SUN, D'1982.09.26 02:00:00', PLUS_1_HOUR,
   SUN, D'1983.03.27 01:00:00', SUN, D'1983.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'1983.09.25 01:00:00', SUN, D'1983.09.25 02:00:00', PLUS_1_HOUR,
   SUN, D'1984.03.25 01:00:00', SUN, D'1984.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'1984.09.30 01:00:00', SUN, D'1984.09.30 02:00:00', PLUS_1_HOUR,
   SUN, D'1985.03.31 01:00:00', SUN, D'1985.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'1985.09.29 01:00:00', SUN, D'1985.09.29 02:00:00', PLUS_1_HOUR,
   SUN, D'1986.03.30 01:00:00', SUN, D'1986.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'1986.09.28 01:00:00', SUN, D'1986.09.28 02:00:00', PLUS_1_HOUR,
   SUN, D'1987.03.29 01:00:00', SUN, D'1987.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'1987.09.27 01:00:00', SUN, D'1987.09.27 02:00:00', PLUS_1_HOUR,
   SUN, D'1988.03.27 01:00:00', SUN, D'1988.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'1988.09.25 01:00:00', SUN, D'1988.09.25 02:00:00', PLUS_1_HOUR,
   SUN, D'1989.03.26 01:00:00', SUN, D'1989.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'1989.09.24 01:00:00', SUN, D'1989.09.24 02:00:00', PLUS_1_HOUR,
   SUN, D'1990.03.25 01:00:00', SUN, D'1990.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'1990.09.30 01:00:00', SUN, D'1990.09.30 02:00:00', PLUS_1_HOUR,
   SUN, D'1991.03.31 01:00:00', SUN, D'1991.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'1991.09.29 01:00:00', SUN, D'1991.09.29 02:00:00', PLUS_1_HOUR,
   SUN, D'1992.03.29 01:00:00', SUN, D'1992.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'1992.09.27 01:00:00', SUN, D'1992.09.27 02:00:00', PLUS_1_HOUR,
   SUN, D'1993.03.28 01:00:00', SUN, D'1993.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'1993.09.26 01:00:00', SUN, D'1993.09.26 02:00:00', PLUS_1_HOUR,
   SUN, D'1994.03.27 01:00:00', SUN, D'1994.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'1994.09.25 01:00:00', SUN, D'1994.09.25 02:00:00', PLUS_1_HOUR,
   SUN, D'1995.03.26 01:00:00', SUN, D'1995.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'1995.09.24 01:00:00', SUN, D'1995.09.24 02:00:00', PLUS_1_HOUR,
   SUN, D'1996.03.31 01:00:00', SUN, D'1996.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'1996.10.27 01:00:00', SUN, D'1996.10.27 02:00:00', PLUS_1_HOUR,
   SUN, D'1997.03.30 01:00:00', SUN, D'1997.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'1997.10.26 01:00:00', SUN, D'1997.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'1998.03.29 01:00:00', SUN, D'1998.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'1998.10.25 01:00:00', SUN, D'1998.10.25 02:00:00', PLUS_1_HOUR,
   SUN, D'1999.03.28 01:00:00', SUN, D'1999.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'1999.10.31 01:00:00', SUN, D'1999.10.31 02:00:00', PLUS_1_HOUR,
   SUN, D'2000.03.26 01:00:00', SUN, D'2000.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'2000.10.29 01:00:00', SUN, D'2000.10.29 02:00:00', PLUS_1_HOUR,
   SUN, D'2001.03.25 01:00:00', SUN, D'2001.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'2001.10.28 01:00:00', SUN, D'2001.10.28 02:00:00', PLUS_1_HOUR,
   SUN, D'2002.03.31 01:00:00', SUN, D'2002.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'2002.10.27 01:00:00', SUN, D'2002.10.27 02:00:00', PLUS_1_HOUR,
   SUN, D'2003.03.30 01:00:00', SUN, D'2003.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'2003.10.26 01:00:00', SUN, D'2003.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'2004.03.28 01:00:00', SUN, D'2004.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'2004.10.31 01:00:00', SUN, D'2004.10.31 02:00:00', PLUS_1_HOUR,
   SUN, D'2005.03.27 01:00:00', SUN, D'2005.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'2005.10.30 01:00:00', SUN, D'2005.10.30 02:00:00', PLUS_1_HOUR,
   SUN, D'2006.03.26 01:00:00', SUN, D'2006.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'2006.10.29 01:00:00', SUN, D'2006.10.29 02:00:00', PLUS_1_HOUR,
   SUN, D'2007.03.25 01:00:00', SUN, D'2007.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'2007.10.28 01:00:00', SUN, D'2007.10.28 02:00:00', PLUS_1_HOUR,
   SUN, D'2008.03.30 01:00:00', SUN, D'2008.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'2008.10.26 01:00:00', SUN, D'2008.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'2009.03.29 01:00:00', SUN, D'2009.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'2009.10.25 01:00:00', SUN, D'2009.10.25 02:00:00', PLUS_1_HOUR,
   SUN, D'2010.03.28 01:00:00', SUN, D'2010.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'2010.10.31 01:00:00', SUN, D'2010.10.31 02:00:00', PLUS_1_HOUR,
   SUN, D'2011.03.27 01:00:00', SUN, D'2011.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'2011.10.30 01:00:00', SUN, D'2011.10.30 02:00:00', PLUS_1_HOUR,
   SUN, D'2012.03.25 01:00:00', SUN, D'2012.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'2012.10.28 01:00:00', SUN, D'2012.10.28 02:00:00', PLUS_1_HOUR,
   SUN, D'2013.03.31 01:00:00', SUN, D'2013.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'2013.10.27 01:00:00', SUN, D'2013.10.27 02:00:00', PLUS_1_HOUR,
   SUN, D'2014.03.30 01:00:00', SUN, D'2014.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'2014.10.26 01:00:00', SUN, D'2014.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'2015.03.29 01:00:00', SUN, D'2015.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'2015.10.25 01:00:00', SUN, D'2015.10.25 02:00:00', PLUS_1_HOUR,
   SUN, D'2016.03.27 01:00:00', SUN, D'2016.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'2016.10.30 01:00:00', SUN, D'2016.10.30 02:00:00', PLUS_1_HOUR,
   SUN, D'2017.03.26 01:00:00', SUN, D'2017.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'2017.10.29 01:00:00', SUN, D'2017.10.29 02:00:00', PLUS_1_HOUR,
   SUN, D'2018.03.25 01:00:00', SUN, D'2018.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'2018.10.28 01:00:00', SUN, D'2018.10.28 02:00:00', PLUS_1_HOUR,
   SUN, D'2019.03.31 01:00:00', SUN, D'2019.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'2019.10.27 01:00:00', SUN, D'2019.10.27 02:00:00', PLUS_1_HOUR,
   SUN, D'2020.03.29 01:00:00', SUN, D'2020.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'2020.10.25 01:00:00', SUN, D'2020.10.25 02:00:00', PLUS_1_HOUR,
   SUN, D'2021.03.28 01:00:00', SUN, D'2021.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'2021.10.31 01:00:00', SUN, D'2021.10.31 02:00:00', PLUS_1_HOUR,
   SUN, D'2022.03.27 01:00:00', SUN, D'2022.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'2022.10.30 01:00:00', SUN, D'2022.10.30 02:00:00', PLUS_1_HOUR,
   SUN, D'2023.03.26 01:00:00', SUN, D'2023.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'2023.10.29 01:00:00', SUN, D'2023.10.29 02:00:00', PLUS_1_HOUR,
   SUN, D'2024.03.31 01:00:00', SUN, D'2024.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'2024.10.27 01:00:00', SUN, D'2024.10.27 02:00:00', PLUS_1_HOUR,
   SUN, D'2025.03.30 01:00:00', SUN, D'2025.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'2025.10.26 01:00:00', SUN, D'2025.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'2026.03.29 01:00:00', SUN, D'2026.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'2026.10.25 01:00:00', SUN, D'2026.10.25 02:00:00', PLUS_1_HOUR,
   SUN, D'2027.03.28 01:00:00', SUN, D'2027.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'2027.10.31 01:00:00', SUN, D'2027.10.31 02:00:00', PLUS_1_HOUR,
   SUN, D'2028.03.26 01:00:00', SUN, D'2028.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'2028.10.29 01:00:00', SUN, D'2028.10.29 02:00:00', PLUS_1_HOUR,
   SUN, D'2029.03.25 01:00:00', SUN, D'2029.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'2029.10.28 01:00:00', SUN, D'2029.10.28 02:00:00', PLUS_1_HOUR,
   SUN, D'2030.03.31 01:00:00', SUN, D'2030.03.31 03:00:00', PLUS_2_HOURS,    SUN, D'2030.10.27 01:00:00', SUN, D'2030.10.27 02:00:00', PLUS_1_HOUR,
   SUN, D'2031.03.30 01:00:00', SUN, D'2031.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'2031.10.26 01:00:00', SUN, D'2031.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'2032.03.28 01:00:00', SUN, D'2032.03.28 03:00:00', PLUS_2_HOURS,    SUN, D'2032.10.31 01:00:00', SUN, D'2032.10.31 02:00:00', PLUS_1_HOUR,
   SUN, D'2033.03.27 01:00:00', SUN, D'2033.03.27 03:00:00', PLUS_2_HOURS,    SUN, D'2033.10.30 01:00:00', SUN, D'2033.10.30 02:00:00', PLUS_1_HOUR,
   SUN, D'2034.03.26 01:00:00', SUN, D'2034.03.26 03:00:00', PLUS_2_HOURS,    SUN, D'2034.10.29 01:00:00', SUN, D'2034.10.29 02:00:00', PLUS_1_HOUR,
   SUN, D'2035.03.25 01:00:00', SUN, D'2035.03.25 03:00:00', PLUS_2_HOURS,    SUN, D'2035.10.28 01:00:00', SUN, D'2035.10.28 02:00:00', PLUS_1_HOUR,
   SUN, D'2036.03.30 01:00:00', SUN, D'2036.03.30 03:00:00', PLUS_2_HOURS,    SUN, D'2036.10.26 01:00:00', SUN, D'2036.10.26 02:00:00', PLUS_1_HOUR,
   SUN, D'2037.03.29 01:00:00', SUN, D'2037.03.29 03:00:00', PLUS_2_HOURS,    SUN, D'2037.10.25 01:00:00', SUN, D'2037.10.25 02:00:00', PLUS_1_HOUR,
};


// Europe/London: GMT+0000,GMT+0100
int transitions.Europe_London[68][10] = {
   // Wechsel zu DST                                         DST-Offset       // Wechsel zu Normalzeit                                  Std.-Offset
   -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,     -1,  INT_MAX,                -1,  INT_MAX,                0,            // durchgehend Sommerzeit (1)
   -1,  -1,                     -1,  -1,                     PLUS_1_HOUR,     SUN, D'1971.10.31 02:00:00', SUN, D'1971.10.31 02:00:00', 0,
   SUN, D'1972.03.19 02:00:00', SUN, D'1972.03.19 03:00:00', PLUS_1_HOUR,     SUN, D'1972.10.29 02:00:00', SUN, D'1972.10.29 02:00:00', 0,
   SUN, D'1973.03.18 02:00:00', SUN, D'1973.03.18 03:00:00', PLUS_1_HOUR,     SUN, D'1973.10.28 02:00:00', SUN, D'1973.10.28 02:00:00', 0,
   SUN, D'1974.03.17 02:00:00', SUN, D'1974.03.17 03:00:00', PLUS_1_HOUR,     SUN, D'1974.10.27 02:00:00', SUN, D'1974.10.27 02:00:00', 0,
   SUN, D'1975.03.16 02:00:00', SUN, D'1975.03.16 03:00:00', PLUS_1_HOUR,     SUN, D'1975.10.26 02:00:00', SUN, D'1975.10.26 02:00:00', 0,
   SUN, D'1976.03.21 02:00:00', SUN, D'1976.03.21 03:00:00', PLUS_1_HOUR,     SUN, D'1976.10.24 02:00:00', SUN, D'1976.10.24 02:00:00', 0,
   SUN, D'1977.03.20 02:00:00', SUN, D'1977.03.20 03:00:00', PLUS_1_HOUR,     SUN, D'1977.10.23 02:00:00', SUN, D'1977.10.23 02:00:00', 0,
   SUN, D'1978.03.19 02:00:00', SUN, D'1978.03.19 03:00:00', PLUS_1_HOUR,     SUN, D'1978.10.29 02:00:00', SUN, D'1978.10.29 02:00:00', 0,
   SUN, D'1979.03.18 02:00:00', SUN, D'1979.03.18 03:00:00', PLUS_1_HOUR,     SUN, D'1979.10.28 02:00:00', SUN, D'1979.10.28 02:00:00', 0,
   SUN, D'1980.03.16 02:00:00', SUN, D'1980.03.16 03:00:00', PLUS_1_HOUR,     SUN, D'1980.10.26 02:00:00', SUN, D'1980.10.26 02:00:00', 0,
   SUN, D'1981.03.29 01:00:00', SUN, D'1981.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'1981.10.25 01:00:00', SUN, D'1981.10.25 01:00:00', 0,
   SUN, D'1982.03.28 01:00:00', SUN, D'1982.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'1982.10.24 01:00:00', SUN, D'1982.10.24 01:00:00', 0,
   SUN, D'1983.03.27 01:00:00', SUN, D'1983.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'1983.10.23 01:00:00', SUN, D'1983.10.23 01:00:00', 0,
   SUN, D'1984.03.25 01:00:00', SUN, D'1984.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'1984.10.28 01:00:00', SUN, D'1984.10.28 01:00:00', 0,
   SUN, D'1985.03.31 01:00:00', SUN, D'1985.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'1985.10.27 01:00:00', SUN, D'1985.10.27 01:00:00', 0,
   SUN, D'1986.03.30 01:00:00', SUN, D'1986.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'1986.10.26 01:00:00', SUN, D'1986.10.26 01:00:00', 0,
   SUN, D'1987.03.29 01:00:00', SUN, D'1987.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'1987.10.25 01:00:00', SUN, D'1987.10.25 01:00:00', 0,
   SUN, D'1988.03.27 01:00:00', SUN, D'1988.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'1988.10.23 01:00:00', SUN, D'1988.10.23 01:00:00', 0,
   SUN, D'1989.03.26 01:00:00', SUN, D'1989.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'1989.10.29 01:00:00', SUN, D'1989.10.29 01:00:00', 0,
   SUN, D'1990.03.25 01:00:00', SUN, D'1990.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'1990.10.28 01:00:00', SUN, D'1990.10.28 01:00:00', 0,
   SUN, D'1991.03.31 01:00:00', SUN, D'1991.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'1991.10.27 01:00:00', SUN, D'1991.10.27 01:00:00', 0,
   SUN, D'1992.03.29 01:00:00', SUN, D'1992.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'1992.10.25 01:00:00', SUN, D'1992.10.25 01:00:00', 0,
   SUN, D'1993.03.28 01:00:00', SUN, D'1993.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'1993.10.24 01:00:00', SUN, D'1993.10.24 01:00:00', 0,
   SUN, D'1994.03.27 01:00:00', SUN, D'1994.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'1994.10.23 01:00:00', SUN, D'1994.10.23 01:00:00', 0,
   SUN, D'1995.03.26 01:00:00', SUN, D'1995.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'1995.10.22 01:00:00', SUN, D'1995.10.22 01:00:00', 0,
   SUN, D'1996.03.31 01:00:00', SUN, D'1996.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'1996.10.27 01:00:00', SUN, D'1996.10.27 01:00:00', 0,
   SUN, D'1997.03.30 01:00:00', SUN, D'1997.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'1997.10.26 01:00:00', SUN, D'1997.10.26 01:00:00', 0,
   SUN, D'1998.03.29 01:00:00', SUN, D'1998.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'1998.10.25 01:00:00', SUN, D'1998.10.25 01:00:00', 0,
   SUN, D'1999.03.28 01:00:00', SUN, D'1999.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'1999.10.31 01:00:00', SUN, D'1999.10.31 01:00:00', 0,
   SUN, D'2000.03.26 01:00:00', SUN, D'2000.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'2000.10.29 01:00:00', SUN, D'2000.10.29 01:00:00', 0,
   SUN, D'2001.03.25 01:00:00', SUN, D'2001.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'2001.10.28 01:00:00', SUN, D'2001.10.28 01:00:00', 0,
   SUN, D'2002.03.31 01:00:00', SUN, D'2002.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'2002.10.27 01:00:00', SUN, D'2002.10.27 01:00:00', 0,
   SUN, D'2003.03.30 01:00:00', SUN, D'2003.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'2003.10.26 01:00:00', SUN, D'2003.10.26 01:00:00', 0,
   SUN, D'2004.03.28 01:00:00', SUN, D'2004.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'2004.10.31 01:00:00', SUN, D'2004.10.31 01:00:00', 0,
   SUN, D'2005.03.27 01:00:00', SUN, D'2005.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'2005.10.30 01:00:00', SUN, D'2005.10.30 01:00:00', 0,
   SUN, D'2006.03.26 01:00:00', SUN, D'2006.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'2006.10.29 01:00:00', SUN, D'2006.10.29 01:00:00', 0,
   SUN, D'2007.03.25 01:00:00', SUN, D'2007.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'2007.10.28 01:00:00', SUN, D'2007.10.28 01:00:00', 0,
   SUN, D'2008.03.30 01:00:00', SUN, D'2008.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'2008.10.26 01:00:00', SUN, D'2008.10.26 01:00:00', 0,
   SUN, D'2009.03.29 01:00:00', SUN, D'2009.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'2009.10.25 01:00:00', SUN, D'2009.10.25 01:00:00', 0,
   SUN, D'2010.03.28 01:00:00', SUN, D'2010.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'2010.10.31 01:00:00', SUN, D'2010.10.31 01:00:00', 0,
   SUN, D'2011.03.27 01:00:00', SUN, D'2011.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'2011.10.30 01:00:00', SUN, D'2011.10.30 01:00:00', 0,
   SUN, D'2012.03.25 01:00:00', SUN, D'2012.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'2012.10.28 01:00:00', SUN, D'2012.10.28 01:00:00', 0,
   SUN, D'2013.03.31 01:00:00', SUN, D'2013.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'2013.10.27 01:00:00', SUN, D'2013.10.27 01:00:00', 0,
   SUN, D'2014.03.30 01:00:00', SUN, D'2014.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'2014.10.26 01:00:00', SUN, D'2014.10.26 01:00:00', 0,
   SUN, D'2015.03.29 01:00:00', SUN, D'2015.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'2015.10.25 01:00:00', SUN, D'2015.10.25 01:00:00', 0,
   SUN, D'2016.03.27 01:00:00', SUN, D'2016.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'2016.10.30 01:00:00', SUN, D'2016.10.30 01:00:00', 0,
   SUN, D'2017.03.26 01:00:00', SUN, D'2017.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'2017.10.29 01:00:00', SUN, D'2017.10.29 01:00:00', 0,
   SUN, D'2018.03.25 01:00:00', SUN, D'2018.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'2018.10.28 01:00:00', SUN, D'2018.10.28 01:00:00', 0,
   SUN, D'2019.03.31 01:00:00', SUN, D'2019.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'2019.10.27 01:00:00', SUN, D'2019.10.27 01:00:00', 0,
   SUN, D'2020.03.29 01:00:00', SUN, D'2020.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'2020.10.25 01:00:00', SUN, D'2020.10.25 01:00:00', 0,
   SUN, D'2021.03.28 01:00:00', SUN, D'2021.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'2021.10.31 01:00:00', SUN, D'2021.10.31 01:00:00', 0,
   SUN, D'2022.03.27 01:00:00', SUN, D'2022.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'2022.10.30 01:00:00', SUN, D'2022.10.30 01:00:00', 0,
   SUN, D'2023.03.26 01:00:00', SUN, D'2023.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'2023.10.29 01:00:00', SUN, D'2023.10.29 01:00:00', 0,
   SUN, D'2024.03.31 01:00:00', SUN, D'2024.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'2024.10.27 01:00:00', SUN, D'2024.10.27 01:00:00', 0,
   SUN, D'2025.03.30 01:00:00', SUN, D'2025.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'2025.10.26 01:00:00', SUN, D'2025.10.26 01:00:00', 0,
   SUN, D'2026.03.29 01:00:00', SUN, D'2026.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'2026.10.25 01:00:00', SUN, D'2026.10.25 01:00:00', 0,
   SUN, D'2027.03.28 01:00:00', SUN, D'2027.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'2027.10.31 01:00:00', SUN, D'2027.10.31 01:00:00', 0,
   SUN, D'2028.03.26 01:00:00', SUN, D'2028.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'2028.10.29 01:00:00', SUN, D'2028.10.29 01:00:00', 0,
   SUN, D'2029.03.25 01:00:00', SUN, D'2029.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'2029.10.28 01:00:00', SUN, D'2029.10.28 01:00:00', 0,
   SUN, D'2030.03.31 01:00:00', SUN, D'2030.03.31 02:00:00', PLUS_1_HOUR,     SUN, D'2030.10.27 01:00:00', SUN, D'2030.10.27 01:00:00', 0,
   SUN, D'2031.03.30 01:00:00', SUN, D'2031.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'2031.10.26 01:00:00', SUN, D'2031.10.26 01:00:00', 0,
   SUN, D'2032.03.28 01:00:00', SUN, D'2032.03.28 02:00:00', PLUS_1_HOUR,     SUN, D'2032.10.31 01:00:00', SUN, D'2032.10.31 01:00:00', 0,
   SUN, D'2033.03.27 01:00:00', SUN, D'2033.03.27 02:00:00', PLUS_1_HOUR,     SUN, D'2033.10.30 01:00:00', SUN, D'2033.10.30 01:00:00', 0,
   SUN, D'2034.03.26 01:00:00', SUN, D'2034.03.26 02:00:00', PLUS_1_HOUR,     SUN, D'2034.10.29 01:00:00', SUN, D'2034.10.29 01:00:00', 0,
   SUN, D'2035.03.25 01:00:00', SUN, D'2035.03.25 02:00:00', PLUS_1_HOUR,     SUN, D'2035.10.28 01:00:00', SUN, D'2035.10.28 01:00:00', 0,
   SUN, D'2036.03.30 01:00:00', SUN, D'2036.03.30 02:00:00', PLUS_1_HOUR,     SUN, D'2036.10.26 01:00:00', SUN, D'2036.10.26 01:00:00', 0,
   SUN, D'2037.03.29 01:00:00', SUN, D'2037.03.29 02:00:00', PLUS_1_HOUR,     SUN, D'2037.10.25 01:00:00', SUN, D'2037.10.25 01:00:00', 0,

   // (1) Vom 18.02.1968 bis zum 31.10.1971 galt in England durchgehend Sommerzeit (GMT+0100).
};


// America/New_York: GMT-0500,GMT-0400
int transitions.America_New_York[68][10] = {
   // Wechsel zu DST                                         DST-Offset       // Wechsel zu Normalzeit                                  Std.-Offset
   SUN, D'1970.04.26 07:00:00', SUN, D'1970.04.26 03:00:00', MINUS_4_HOURS,   SUN, D'1970.10.25 06:00:00', SUN, D'1970.10.25 01:00:00', MINUS_5_HOURS,
   SUN, D'1971.04.25 07:00:00', SUN, D'1971.04.25 03:00:00', MINUS_4_HOURS,   SUN, D'1971.10.31 06:00:00', SUN, D'1971.10.31 01:00:00', MINUS_5_HOURS,
   SUN, D'1972.04.30 07:00:00', SUN, D'1972.04.30 03:00:00', MINUS_4_HOURS,   SUN, D'1972.10.29 06:00:00', SUN, D'1972.10.29 01:00:00', MINUS_5_HOURS,
   SUN, D'1973.04.29 07:00:00', SUN, D'1973.04.29 03:00:00', MINUS_4_HOURS,   SUN, D'1973.10.28 06:00:00', SUN, D'1973.10.28 01:00:00', MINUS_5_HOURS,
   SUN, D'1974.01.06 07:00:00', SUN, D'1974.01.06 03:00:00', MINUS_4_HOURS,   SUN, D'1974.10.27 06:00:00', SUN, D'1974.10.27 01:00:00', MINUS_5_HOURS,
   SUN, D'1975.02.23 07:00:00', SUN, D'1975.02.23 03:00:00', MINUS_4_HOURS,   SUN, D'1975.10.26 06:00:00', SUN, D'1975.10.26 01:00:00', MINUS_5_HOURS,
   SUN, D'1976.04.25 07:00:00', SUN, D'1976.04.25 03:00:00', MINUS_4_HOURS,   SUN, D'1976.10.31 06:00:00', SUN, D'1976.10.31 01:00:00', MINUS_5_HOURS,
   SUN, D'1977.04.24 07:00:00', SUN, D'1977.04.24 03:00:00', MINUS_4_HOURS,   SUN, D'1977.10.30 06:00:00', SUN, D'1977.10.30 01:00:00', MINUS_5_HOURS,
   SUN, D'1978.04.30 07:00:00', SUN, D'1978.04.30 03:00:00', MINUS_4_HOURS,   SUN, D'1978.10.29 06:00:00', SUN, D'1978.10.29 01:00:00', MINUS_5_HOURS,
   SUN, D'1979.04.29 07:00:00', SUN, D'1979.04.29 03:00:00', MINUS_4_HOURS,   SUN, D'1979.10.28 06:00:00', SUN, D'1979.10.28 01:00:00', MINUS_5_HOURS,
   SUN, D'1980.04.27 07:00:00', SUN, D'1980.04.27 03:00:00', MINUS_4_HOURS,   SUN, D'1980.10.26 06:00:00', SUN, D'1980.10.26 01:00:00', MINUS_5_HOURS,
   SUN, D'1981.04.26 07:00:00', SUN, D'1981.04.26 03:00:00', MINUS_4_HOURS,   SUN, D'1981.10.25 06:00:00', SUN, D'1981.10.25 01:00:00', MINUS_5_HOURS,
   SUN, D'1982.04.25 07:00:00', SUN, D'1982.04.25 03:00:00', MINUS_4_HOURS,   SUN, D'1982.10.31 06:00:00', SUN, D'1982.10.31 01:00:00', MINUS_5_HOURS,
   SUN, D'1983.04.24 07:00:00', SUN, D'1983.04.24 03:00:00', MINUS_4_HOURS,   SUN, D'1983.10.30 06:00:00', SUN, D'1983.10.30 01:00:00', MINUS_5_HOURS,
   SUN, D'1984.04.29 07:00:00', SUN, D'1984.04.29 03:00:00', MINUS_4_HOURS,   SUN, D'1984.10.28 06:00:00', SUN, D'1984.10.28 01:00:00', MINUS_5_HOURS,
   SUN, D'1985.04.28 07:00:00', SUN, D'1985.04.28 03:00:00', MINUS_4_HOURS,   SUN, D'1985.10.27 06:00:00', SUN, D'1985.10.27 01:00:00', MINUS_5_HOURS,
   SUN, D'1986.04.27 07:00:00', SUN, D'1986.04.27 03:00:00', MINUS_4_HOURS,   SUN, D'1986.10.26 06:00:00', SUN, D'1986.10.26 01:00:00', MINUS_5_HOURS,
   SUN, D'1987.04.05 07:00:00', SUN, D'1987.04.05 03:00:00', MINUS_4_HOURS,   SUN, D'1987.10.25 06:00:00', SUN, D'1987.10.25 01:00:00', MINUS_5_HOURS,
   SUN, D'1988.04.03 07:00:00', SUN, D'1988.04.03 03:00:00', MINUS_4_HOURS,   SUN, D'1988.10.30 06:00:00', SUN, D'1988.10.30 01:00:00', MINUS_5_HOURS,
   SUN, D'1989.04.02 07:00:00', SUN, D'1989.04.02 03:00:00', MINUS_4_HOURS,   SUN, D'1989.10.29 06:00:00', SUN, D'1989.10.29 01:00:00', MINUS_5_HOURS,
   SUN, D'1990.04.01 07:00:00', SUN, D'1990.04.01 03:00:00', MINUS_4_HOURS,   SUN, D'1990.10.28 06:00:00', SUN, D'1990.10.28 01:00:00', MINUS_5_HOURS,
   SUN, D'1991.04.07 07:00:00', SUN, D'1991.04.07 03:00:00', MINUS_4_HOURS,   SUN, D'1991.10.27 06:00:00', SUN, D'1991.10.27 01:00:00', MINUS_5_HOURS,
   SUN, D'1992.04.05 07:00:00', SUN, D'1992.04.05 03:00:00', MINUS_4_HOURS,   SUN, D'1992.10.25 06:00:00', SUN, D'1992.10.25 01:00:00', MINUS_5_HOURS,
   SUN, D'1993.04.04 07:00:00', SUN, D'1993.04.04 03:00:00', MINUS_4_HOURS,   SUN, D'1993.10.31 06:00:00', SUN, D'1993.10.31 01:00:00', MINUS_5_HOURS,
   SUN, D'1994.04.03 07:00:00', SUN, D'1994.04.03 03:00:00', MINUS_4_HOURS,   SUN, D'1994.10.30 06:00:00', SUN, D'1994.10.30 01:00:00', MINUS_5_HOURS,
   SUN, D'1995.04.02 07:00:00', SUN, D'1995.04.02 03:00:00', MINUS_4_HOURS,   SUN, D'1995.10.29 06:00:00', SUN, D'1995.10.29 01:00:00', MINUS_5_HOURS,
   SUN, D'1996.04.07 07:00:00', SUN, D'1996.04.07 03:00:00', MINUS_4_HOURS,   SUN, D'1996.10.27 06:00:00', SUN, D'1996.10.27 01:00:00', MINUS_5_HOURS,
   SUN, D'1997.04.06 07:00:00', SUN, D'1997.04.06 03:00:00', MINUS_4_HOURS,   SUN, D'1997.10.26 06:00:00', SUN, D'1997.10.26 01:00:00', MINUS_5_HOURS,
   SUN, D'1998.04.05 07:00:00', SUN, D'1998.04.05 03:00:00', MINUS_4_HOURS,   SUN, D'1998.10.25 06:00:00', SUN, D'1998.10.25 01:00:00', MINUS_5_HOURS,
   SUN, D'1999.04.04 07:00:00', SUN, D'1999.04.04 03:00:00', MINUS_4_HOURS,   SUN, D'1999.10.31 06:00:00', SUN, D'1999.10.31 01:00:00', MINUS_5_HOURS,
   SUN, D'2000.04.02 07:00:00', SUN, D'2000.04.02 03:00:00', MINUS_4_HOURS,   SUN, D'2000.10.29 06:00:00', SUN, D'2000.10.29 01:00:00', MINUS_5_HOURS,
   SUN, D'2001.04.01 07:00:00', SUN, D'2001.04.01 03:00:00', MINUS_4_HOURS,   SUN, D'2001.10.28 06:00:00', SUN, D'2001.10.28 01:00:00', MINUS_5_HOURS,
   SUN, D'2002.04.07 07:00:00', SUN, D'2002.04.07 03:00:00', MINUS_4_HOURS,   SUN, D'2002.10.27 06:00:00', SUN, D'2002.10.27 01:00:00', MINUS_5_HOURS,
   SUN, D'2003.04.06 07:00:00', SUN, D'2003.04.06 03:00:00', MINUS_4_HOURS,   SUN, D'2003.10.26 06:00:00', SUN, D'2003.10.26 01:00:00', MINUS_5_HOURS,
   SUN, D'2004.04.04 07:00:00', SUN, D'2004.04.04 03:00:00', MINUS_4_HOURS,   SUN, D'2004.10.31 06:00:00', SUN, D'2004.10.31 01:00:00', MINUS_5_HOURS,
   SUN, D'2005.04.03 07:00:00', SUN, D'2005.04.03 03:00:00', MINUS_4_HOURS,   SUN, D'2005.10.30 06:00:00', SUN, D'2005.10.30 01:00:00', MINUS_5_HOURS,
   SUN, D'2006.04.02 07:00:00', SUN, D'2006.04.02 03:00:00', MINUS_4_HOURS,   SUN, D'2006.10.29 06:00:00', SUN, D'2006.10.29 01:00:00', MINUS_5_HOURS,
   SUN, D'2007.03.11 07:00:00', SUN, D'2007.03.11 03:00:00', MINUS_4_HOURS,   SUN, D'2007.11.04 06:00:00', SUN, D'2007.11.04 01:00:00', MINUS_5_HOURS,
   SUN, D'2008.03.09 07:00:00', SUN, D'2008.03.09 03:00:00', MINUS_4_HOURS,   SUN, D'2008.11.02 06:00:00', SUN, D'2008.11.02 01:00:00', MINUS_5_HOURS,
   SUN, D'2009.03.08 07:00:00', SUN, D'2009.03.08 03:00:00', MINUS_4_HOURS,   SUN, D'2009.11.01 06:00:00', SUN, D'2009.11.01 01:00:00', MINUS_5_HOURS,
   SUN, D'2010.03.14 07:00:00', SUN, D'2010.03.14 03:00:00', MINUS_4_HOURS,   SUN, D'2010.11.07 06:00:00', SUN, D'2010.11.07 01:00:00', MINUS_5_HOURS,
   SUN, D'2011.03.13 07:00:00', SUN, D'2011.03.13 03:00:00', MINUS_4_HOURS,   SUN, D'2011.11.06 06:00:00', SUN, D'2011.11.06 01:00:00', MINUS_5_HOURS,
   SUN, D'2012.03.11 07:00:00', SUN, D'2012.03.11 03:00:00', MINUS_4_HOURS,   SUN, D'2012.11.04 06:00:00', SUN, D'2012.11.04 01:00:00', MINUS_5_HOURS,
   SUN, D'2013.03.10 07:00:00', SUN, D'2013.03.10 03:00:00', MINUS_4_HOURS,   SUN, D'2013.11.03 06:00:00', SUN, D'2013.11.03 01:00:00', MINUS_5_HOURS,
   SUN, D'2014.03.09 07:00:00', SUN, D'2014.03.09 03:00:00', MINUS_4_HOURS,   SUN, D'2014.11.02 06:00:00', SUN, D'2014.11.02 01:00:00', MINUS_5_HOURS,
   SUN, D'2015.03.08 07:00:00', SUN, D'2015.03.08 03:00:00', MINUS_4_HOURS,   SUN, D'2015.11.01 06:00:00', SUN, D'2015.11.01 01:00:00', MINUS_5_HOURS,
   SUN, D'2016.03.13 07:00:00', SUN, D'2016.03.13 03:00:00', MINUS_4_HOURS,   SUN, D'2016.11.06 06:00:00', SUN, D'2016.11.06 01:00:00', MINUS_5_HOURS,
   SUN, D'2017.03.12 07:00:00', SUN, D'2017.03.12 03:00:00', MINUS_4_HOURS,   SUN, D'2017.11.05 06:00:00', SUN, D'2017.11.05 01:00:00', MINUS_5_HOURS,
   SUN, D'2018.03.11 07:00:00', SUN, D'2018.03.11 03:00:00', MINUS_4_HOURS,   SUN, D'2018.11.04 06:00:00', SUN, D'2018.11.04 01:00:00', MINUS_5_HOURS,
   SUN, D'2019.03.10 07:00:00', SUN, D'2019.03.10 03:00:00', MINUS_4_HOURS,   SUN, D'2019.11.03 06:00:00', SUN, D'2019.11.03 01:00:00', MINUS_5_HOURS,
   SUN, D'2020.03.08 07:00:00', SUN, D'2020.03.08 03:00:00', MINUS_4_HOURS,   SUN, D'2020.11.01 06:00:00', SUN, D'2020.11.01 01:00:00', MINUS_5_HOURS,
   SUN, D'2021.03.14 07:00:00', SUN, D'2021.03.14 03:00:00', MINUS_4_HOURS,   SUN, D'2021.11.07 06:00:00', SUN, D'2021.11.07 01:00:00', MINUS_5_HOURS,
   SUN, D'2022.03.13 07:00:00', SUN, D'2022.03.13 03:00:00', MINUS_4_HOURS,   SUN, D'2022.11.06 06:00:00', SUN, D'2022.11.06 01:00:00', MINUS_5_HOURS,
   SUN, D'2023.03.12 07:00:00', SUN, D'2023.03.12 03:00:00', MINUS_4_HOURS,   SUN, D'2023.11.05 06:00:00', SUN, D'2023.11.05 01:00:00', MINUS_5_HOURS,
   SUN, D'2024.03.10 07:00:00', SUN, D'2024.03.10 03:00:00', MINUS_4_HOURS,   SUN, D'2024.11.03 06:00:00', SUN, D'2024.11.03 01:00:00', MINUS_5_HOURS,
   SUN, D'2025.03.09 07:00:00', SUN, D'2025.03.09 03:00:00', MINUS_4_HOURS,   SUN, D'2025.11.02 06:00:00', SUN, D'2025.11.02 01:00:00', MINUS_5_HOURS,
   SUN, D'2026.03.08 07:00:00', SUN, D'2026.03.08 03:00:00', MINUS_4_HOURS,   SUN, D'2026.11.01 06:00:00', SUN, D'2026.11.01 01:00:00', MINUS_5_HOURS,
   SUN, D'2027.03.14 07:00:00', SUN, D'2027.03.14 03:00:00', MINUS_4_HOURS,   SUN, D'2027.11.07 06:00:00', SUN, D'2027.11.07 01:00:00', MINUS_5_HOURS,
   SUN, D'2028.03.12 07:00:00', SUN, D'2028.03.12 03:00:00', MINUS_4_HOURS,   SUN, D'2028.11.05 06:00:00', SUN, D'2028.11.05 01:00:00', MINUS_5_HOURS,
   SUN, D'2029.03.11 07:00:00', SUN, D'2029.03.11 03:00:00', MINUS_4_HOURS,   SUN, D'2029.11.04 06:00:00', SUN, D'2029.11.04 01:00:00', MINUS_5_HOURS,
   SUN, D'2030.03.10 07:00:00', SUN, D'2030.03.10 03:00:00', MINUS_4_HOURS,   SUN, D'2030.11.03 06:00:00', SUN, D'2030.11.03 01:00:00', MINUS_5_HOURS,
   SUN, D'2031.03.09 07:00:00', SUN, D'2031.03.09 03:00:00', MINUS_4_HOURS,   SUN, D'2031.11.02 06:00:00', SUN, D'2031.11.02 01:00:00', MINUS_5_HOURS,
   SUN, D'2032.03.14 07:00:00', SUN, D'2032.03.14 03:00:00', MINUS_4_HOURS,   SUN, D'2032.11.07 06:00:00', SUN, D'2032.11.07 01:00:00', MINUS_5_HOURS,
   SUN, D'2033.03.13 07:00:00', SUN, D'2033.03.13 03:00:00', MINUS_4_HOURS,   SUN, D'2033.11.06 06:00:00', SUN, D'2033.11.06 01:00:00', MINUS_5_HOURS,
   SUN, D'2034.03.12 07:00:00', SUN, D'2034.03.12 03:00:00', MINUS_4_HOURS,   SUN, D'2034.11.05 06:00:00', SUN, D'2034.11.05 01:00:00', MINUS_5_HOURS,
   SUN, D'2035.03.11 07:00:00', SUN, D'2035.03.11 03:00:00', MINUS_4_HOURS,   SUN, D'2035.11.04 06:00:00', SUN, D'2035.11.04 01:00:00', MINUS_5_HOURS,
   SUN, D'2036.03.09 07:00:00', SUN, D'2036.03.09 03:00:00', MINUS_4_HOURS,   SUN, D'2036.11.02 06:00:00', SUN, D'2036.11.02 01:00:00', MINUS_5_HOURS,
   SUN, D'2037.03.08 07:00:00', SUN, D'2037.03.08 03:00:00', MINUS_4_HOURS,   SUN, D'2037.11.01 06:00:00', SUN, D'2037.11.01 01:00:00', MINUS_5_HOURS,
};

/*
<?php

$dstGmt       = $dstLocal    = $stdGmt    = $stdLocal    = '                               ';
$dstGmtMql    = $dstLocalMql = $stdGmtMql = $stdLocalMql = '-1,  -1,                    ';
$dstOffsetMql = $stdOffsetMql = '            0';
$dstSet       = $stdSet       = false;
$year         = $lastYear     = 1970;
$tsMin = strToTime('1970-01-01 00:00:00 GMT');


$tzName      = 'Europe/Minsk';
$timezone    = new DateTimeZone($tzName);
$transitions = $timezone->getTransitions();


echoPre("Timezone transitions for '$tzName'\n\n");


foreach ($transitions as $transition) {
   $ts     = $transition['ts'    ];
   $offset = $transition['offset'];
   $isDST  = $transition['isdst' ];

   if ($ts >= $tsMin) {
      date_default_timezone_set('GMT');
      $year = iDate('Y', $ts);
      if ($year != $lastYear) {
         printYear();
         while (++$lastYear < $year) {
            echoPre($lastYear);
         }
      }

      if ($isDST) {
         if ($dstSet)
            printYear();
         $dstGmt      = date(DATE_RSS,         $ts);
         $dstGmtMql   = strToUpper(date('D, ', $ts)).date("\D'Y.m.d H:i:s',", $ts);

         date_default_timezone_set($tzName);
         $dstLocal    = date(DATE_RSS,         $ts);
         $dstLocalMql = strToUpper(date('D, ', $ts)).date("\D'Y.m.d H:i:s',", $ts);

         $dstOffsetMql = (!$offset ? '            0':(($offset<0?'MINUS_':' PLUS_').(abs($offset)/HOURS).'_HOURS'));
         $dstSet = true;
      }
      else {
         if ($stdSet)
            printYear();
         $stdGmt      = date(DATE_RSS,         $ts);
         $stdGmtMql   = strToUpper(date('D, ', $ts)).date("\D'Y.m.d H:i:s',", $ts);

         date_default_timezone_set($tzName);
         $stdLocal    = date(DATE_RSS,         $ts);
         $stdLocalMql = strToUpper(date('D, ', $ts)).date("\D'Y.m.d H:i:s',", $ts);

         $stdOffsetMql = (!$offset ? '            0':(($offset<0?'MINUS_':' PLUS_').(abs($offset)/HOURS).'_HOURS'));
         $stdSet = true;
      }
   }
}
if ($dstSet || $stdSet) {
   printYear();
}


echoPre($transitions);


function printYear() {
   global $lastYear, $dstGmt, $dstLocal, $stdGmt, $stdLocal, $dstGmtMql, $dstLocalMql, $stdGmtMql, $stdLocalMql, $dstOffsetMql, $stdOffsetMql, $dstSet, $stdSet;

   echoPre("$lastYear    DST: $dstGmt    $dstLocal        STD: $stdGmt    $stdLocal        $dstGmtMql $dstLocalMql $dstOffsetMql,    $stdGmtMql $stdLocalMql $stdOffsetMql,");
   $dstGmt       = $dstLocal     = $stdGmt    = $stdLocal    = '                               ';
   $dstGmtMql    = $dstLocalMql  = $stdGmtMql = $stdLocalMql = '-1,  -1,                    ';
   $dstOffsetMql = $stdOffsetMql                             = '            0';
   $dstSet       = $stdSet                                   = false;
}
?>
*/
