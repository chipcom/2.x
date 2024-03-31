#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 23.01.17
Function f_valid_diag_oms_sluch_dvn( get, k )

  Local sk := lstr( k )
  Private pole_diag := 'mdiag' + sk, ;
    pole_d_diag := 'mddiag' + sk, ;
    pole_pervich := 'mpervich' + sk, ;
    pole_1pervich := 'm1pervich' + sk, ;
    pole_stadia := 'm1stadia' + sk, ;
    pole_dispans := 'mdispans' + sk, ;
    pole_1dispans := 'm1dispans' + sk, ;
    pole_d_dispans := 'mddispans' + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 12 )
      &pole_1pervich := 0
      &pole_d_diag := CToD( '' )
      &pole_stadia := 1
      &pole_dispans := Space( 3 )
      &pole_1dispans := 0
      &pole_d_dispans := CToD( '' )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_dispans := inieditspr( A__MENUVERT, mm_danet, &pole_1dispans )
    Endif
  Endif
  If emptyall( m1dispans1, m1dispans2, m1dispans3, m1dispans4, m1dispans5 )
    m1dispans := 0
  Elseif m1dispans == 0
    m1dispans := ps1dispans
  Endif
  mdispans := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  update_get( pole_pervich )
  update_get( pole_d_diag )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_d_dispans )
  update_get( 'mdispans' )

  Return .t.

// 16.06.19 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_dvn( i, _etap, _vozrast, _pol )

  Local fl := .f., j, ta, ar := dvn_arr_umolch[ i ]

  If _etap > 3
    Return fl
  Endif
  If ValType( ar[ 3 ] ) == 'N'
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  If fl
    If _etap == 1
      i := iif( _pol == 'М', 4, 5 )
    Else// if _etap == 3
      i := iif( _pol == 'М', 6, 7 )
    Endif
    If ValType( ar[ i ] ) == 'N'
      fl := ( ar[ i ] != 0 )
    Elseif ValType( ar[ i ] ) == 'C'
      // '18,65' - для краткого инд.проф.консультирования
      ta := list2arr( ar[ i ] )
      For i := Len( ta ) To 1 Step -1
        If _vozrast >= ta[ i ]
          For j := 0 To 99
            If _vozrast == Int( ta[ i ] + j * 3 )
              fl := .t. ; Exit
            Endif
          Next
          If fl ; exit ; Endif
        Endif
      Next
    Else
      fl := Between( _vozrast, ar[ i, 1 ], ar[ i, 2 ] )
    Endif
  Endif

  Return fl

// 30.03.24
function arr_mm_napr_stac()

  local mm_napr_stac := { ;
        { '--- нет ---', 0 }, ;
        { 'в стационар', 1 }, ;
        { 'в дн. стац.', 2 } ;
      }

  return AClone( mm_napr_stac )

// 30.03.24
function arr_mm_napr_v_mo()

  local mm_napr_v_mo := { ;
        { '-- нет --', 0 }, ;
        { 'в нашу МО', 1 }, ;
        { 'в иную МО', 2 } ;
      }

  return AClone( mm_napr_v_mo )

// 30.03.24
function arr_mm_pervich()

  local mm_pervich := { ;
        { 'впервые     ', 1 }, ;
        { 'ранее выявл.', 0 }, ;
        { 'пред.диагноз', 2 } ;
      }

  return AClone( mm_pervich )

// 30.03.24
function arr_mm_dispans()

  local mm_dispans := { ;
        { 'не установлено             ', 0 }, ;
        { 'участковым терапевтом      ', 3 }, ;
        { 'врачом отд.мед.профилактики', 1 }, ;
        { 'врачом центра здоровья     ', 2 } ;
      }

  return AClone( mm_dispans )

// 30.03.24
function arr_mm_dopo_na()

  local mm_dopo_na := { ;
        { 'лаб.диагностика', 1 }, ;
        { 'инстр.диагностика', 2 }, ;
        { 'лучевая диагностика', 3 }, ;
        { 'КТ, МРТ, ангиография', 4 } ;
      }

  return AClone( mm_dopo_na )

// 30.03.24
function arr_mm_otkaz()

  local mm_otkaz := { ;
        { '_выполнено', 0 }, ;
        { 'отклонение', 3 }, ;
        { 'ОТКАЗ пац.', 1 }, ;
        { 'НЕВОЗМОЖНО', 2 } ;
      }

  return AClone( mm_otkaz )

//30.03.24
function arr_mm_gruppaP()

  local mm_gruppaP := { ;
        { 'Присвоена I группа здоровья'   , 1, 343 }, ;
        { 'Присвоена II группа здоровья'  , 2, 344 }, ;
        { 'Присвоена III группа здоровья' , 3, 345 }, ;
        { 'Присвоена IIIа группа здоровья', 3, 373 }, ;
        { 'Присвоена IIIб группа здоровья', 4, 374 } ;
      }

  return AClone( mm_gruppaP )

// 23.01.17
Function f_valid_vyav_diag_dispanser( get, k )

  Local sk := lstr( k )

  Private pole_diag := "mdiag" + sk, ;
    pole_d_diag := "mddiag" + sk, ;
    pole_pervich := "mpervich" + sk, ;
    pole_1pervich := "m1pervich" + sk, ;
    pole_stadia := "m1stadia" + sk, ;
    pole_dispans := "mdispans" + sk, ;
    pole_1dispans := "m1dispans" + sk, ;
    pole_d_dispans := "mddispans" + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 12 )
      &pole_1pervich := 0
      &pole_d_diag := CToD( "" )
      &pole_stadia := 1
      &pole_dispans := Space( 3 )
      &pole_1dispans := 0
      &pole_d_dispans := CToD( "" )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_dispans := inieditspr( A__MENUVERT, mm_danet, &pole_1dispans )
    Endif
  Endif
  If emptyall( m1dispans1, m1dispans2, m1dispans3, m1dispans4, m1dispans5 )
    m1dispans := 0
  Elseif m1dispans == 0
    m1dispans := ps1dispans
  Endif
  mdispans := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  update_get( pole_pervich )
  update_get( pole_d_diag )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_d_dispans )
  update_get( "mdispans" )

  Return .t.

// 30.03.24 - заполнение списка выявленных диагнозов при диспансеризации
function dispans_vyav_diag( /*@*/j, mndisp )

  // j - счетчик строк на экране
  // mndisp - заголовок вида диспнсеризации
  // используются PRIVATE-переменные
  local pic_diag := '@K@!'
  Local bg := {| o, k | get_mkb10( o, k, .t. ) }

  @ ++j, 8 Get mndisp When .f. Color color14

  @ ++j, 1  Say '───────┬────────────┬──────────┬──────┬───────────────────────────────────────'
  @ ++j, 1  Say '       │  выявлено  │   дата   │стадия│установлено диспансерное Дата следующего'
  @ ++j, 1  Say 'диагноз│заболевание │выявления │забол.│наблюдение     (когда)     визита'
  @ ++j, 1  Say '───────┴────────────┴──────────┴──────┴───────────────────────────────────────'
  // 2      9            22           35       44        54
  @ ++j, 2  Get mdiag1 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 1 ), ;
    .f. ) }
  @ j, 9  Get mpervich1 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag1 )
  @ j, 22 Get mddiag1 When !Empty( mdiag1 )
  @ j, 35 Get m1stadia1 Pict '9' Range 1, 4 ;
    When !Empty( mdiag1 )
  @ j, 44 Get mdispans1 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag1 )
  @ j, 54 Get mddispans1 When m1dispans1 == 1
  @ j, 67 Get mdndispans1 When m1dispans1 == 1
  //
  @ ++j, 2  Get mdiag2 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 2 ), ;
    .f. ) }
  @ j, 9  Get mpervich2 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag2 )
  @ j, 22 Get mddiag2 When !Empty( mdiag2 )
  @ j, 35 Get m1stadia2 Pict '9' Range 1, 4 ;
    When !Empty( mdiag2 )
  @ j, 44 Get mdispans2 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag2 )
  @ j, 54 Get mddispans2 When m1dispans2 == 1
  @ j, 67 Get mdndispans2 When m1dispans2 == 1
  //
  @ ++j, 2  Get mdiag3 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 3 ), ;
    .f. ) }
  @ j, 9  Get mpervich3 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag3 )
  @ j, 22 Get mddiag3 When !Empty( mdiag3 )
  @ j, 35 Get m1stadia3 Pict '9' Range 1, 4 ;
    When !Empty( mdiag3 )
  @ j, 44 Get mdispans3 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag3 )
  @ j, 54 Get mddispans3 When m1dispans3 == 1
  @ j, 67 Get mdndispans3 When m1dispans3 == 1
  //
  @ ++j, 2  Get mdiag4 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 4 ), ;
    .f. ) }
  @ j, 9  Get mpervich4 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag4 )
  @ j, 22 Get mddiag4 When !Empty( mdiag4 )
  @ j, 35 Get m1stadia4 Pict '9' Range 1, 4 ;
    When !Empty( mdiag4 )
  @ j, 44 Get mdispans4 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag4 )
  @ j, 54 Get mddispans4 When m1dispans4 == 1
  @ j, 67 Get mdndispans4 When m1dispans4 == 1
  //
  @ ++j, 2  Get mdiag5 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 5 ), ;
    .f. ) }
  @ j, 9  Get mpervich5 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag5 )
  @ j, 22 Get mddiag5 When !Empty( mdiag5 )
  @ j, 35 Get m1stadia5 Pict '9' Range 1, 4 ;
    When !Empty( mdiag5 )
  @ j, 44 Get mdispans5 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag5 )
  @ j, 54 Get mddispans5 When m1dispans5 == 1
  @ j, 67 Get mdndispans5 When m1dispans5 == 1
  //
  @ ++j, 1 Say Replicate( '─', 78 ) Color color1

  return nil