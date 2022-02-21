#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// **** 20.02.22 график регистрации счетов, включаемых в акт сверки на 2022 год
// ****            в соответствии с письмом ТФОМС от 11.02.2022г. №03-30/55
// !!! ВНИМАНИЕ
FUNCTION ret_days_for_akt_sverki( arr_m, /*@*/b1,/*@*/b2,/*@*/a1,/*@*/a2)

   STATIC sd16 :=  { 12, 4, 7, 6, 7, 7, 5, 7, 7, 8, 7, 19 }
   STATIC sd17 :=  { 9, 7, 7, 5, 7, 7, 7, 7, 6, 8, 7, 18 }
   STATIC sad17 := { 2, 9, 10, 10, 8, 10, 8, 8, 9, 9, 8, 19 }
   STATIC sd18 :=  { 7, 7, 6, 7, 7, 6, 7, 7, 5, 8, 7, 21 }
   STATIC sad18 := { 8, 12, 10, 8, 8, 9, 8, 10, 8, 9, 10, 22 }
   STATIC sd19 :=  { 7, 7, 5, 8, 7, 5, 7, 4, 7, 8, 6, 17 }
   STATIC sad19 := { 8, 8, 8, 13, 10, 8, 8, 5, 8, 11, 9, 20 }
   STATIC sd20 :=  { 7, 6, 7, 8, 5, 7, 7, 7, 7, 9, 7, 15 }
   STATIC sad20 := { 10, 10, 8, 12, 8, 8, 10, 8, 8, 10, 8, 18 }
   STATIC sd21 :=  { 5, 5, 7, 7, 7, 7, 6, 7, 8, 9, 7, 14 }
   STATIC sad21 := { 8, 9, 8, 11, 8, 13, 12, 13, 13, 15, 13, 20 }
   STATIC sd22 :=  { 15, 5, 7, 12, 7, 7, 5, 7, 7, 8, 7, 13 }
   STATIC sad22 := { 17, 14, 13, 18, 14, 13, 11, 13, 13, 14, 13, 19 }

   LOCAL y := arr_m[ 1 ], m := arr_m[ 2 ]

   b1 := b2 := a1 := a2 := 0

   IF y == 2022
      b1 := 27 ; a1 := 18
      IF m > 1
         b1 := sd22[ m - 1 ]
         a1 := sad22[ m - 1 ]
      ENDIF
      b2 := sd22[ m ]
      a2 := sad22[ m ]
   ELSEIF y == 2021
      b1 := 27 ; a1 := 18
      IF m > 1
         b1 := sd21[ m - 1 ]
         a1 := sad21[ m - 1 ]
      ENDIF
      b2 := sd21[ m ]
      a2 := sad21[ m ]
   ELSEIF y == 2020
      b1 := 17 ; a1 := 20
      IF m > 1
         b1 := sd20[ m - 1 ]
         a1 := sad20[ m - 1 ]
      ENDIF
      b2 := sd20[ m ]
      a2 := sad20[ m ]
   ELSEIF y == 2019
      b1 := 21 ; a1 := 22
      IF m > 1
         b1 := sd19[ m - 1 ]
         a1 := sad19[ m - 1 ]
      ENDIF
      b2 := sd19[ m ]
      a2 := sad19[ m ]
   ELSEIF y == 2018
      b1 := 24 ; a1 := 25
      IF m > 1
         b1 := sd18[ m - 1 ]
         a1 := sad18[ m - 1 ]
      ENDIF
      b2 := sd18[ m ]
      a2 := sad18[ m ]
      IF m == 12 .AND. glob_mo[ _MO_KOD_TFOMS ] == '134505'
         b2 := a2 := 23
      ENDIF
   ELSEIF y == 2017
      b1 := 19 ; a1 := 2
      IF m > 1
         b1 := sd17[ m - 1 ]
         a1 := sad17[ m - 1 ]
      ENDIF
      b2 := sd17[ m ]
      a2 := sad17[ m ]
   ELSEIF y == 2016
      IF m > 1
         a1 := b1 := sd16[ m - 1 ]
      ENDIF
      a2 := b2 := sd16[ m ]
   ENDIF

   RETURN NIL
