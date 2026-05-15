#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 11.04.26
Function read_arr_dispans( lkod )

  Local s := '', tmp_select := Select()

  use_base( 'mo_hdisp' )
  find ( Str( lkod, 7 ) )
  Do While hdisp->kod == lkod .and. !hdisp->( Eof() )
    s += hdisp->name
    Skip
  Enddo
  hdisp->( dbCloseArea() )
  Select ( tmp_select )

  Return rest_arr_mem( s ) // востановление массива из символьной переменной s

// 11.04.26
Function save_arr_dispans( lkod, arr )

  Local l, s, i, i1, i2, arr_d := {}, tmp_select := Select()

  If Empty( arr )
    Return Nil
  Endif
  use_base( 'mo_hdisp' )
  find ( Str( lkod, 7 ) )
  Do While hdisp->kod == lkod .and. !hdisp->( Eof() )
    AAdd( arr_d, hdisp->( RecNo() ) )
    Skip
  Enddo
  l := FieldLen( FieldNum( 'NAME' ) ) // берём длину поля базы данных
  s := save_arr_mem( arr ) // сохранение массива в символьной переменной
  arr := {}
  Do While Len( s ) > 0
    AAdd( arr, Left( s, l ) )
    s := SubStr( s, l + 1 )
  Enddo
  i1 := Len( arr_d )
  i2 := Len( arr )
  For i := 1 To i2
    If i > i1
      add1rec( 7 )
      hdisp->kod := lkod
    Else
      Goto ( arr_d[ i ] )
      g_rlock( 'forever' )
    Endif
    hdisp->ks := i
    hdisp->name := arr[ i ]
  Next
  If i2 < i1
    For i := i2 + 1 To i1
      Goto ( arr_d[ i ] )
      deleterec( .t. )
    Next
  Endif
  hdisp->( dbCloseArea() )
  Select ( tmp_select )

  Return Nil

// 22.11.24
function read_napr_dispanser( lkod )
  // возврат arr_napr
  // arr_napr[1,1], arr_napr[1,2], arr_napr[1,3] - виды доп обследования (вид, 0, номер записи в справочнике персонала)
  // arr_napr[2,1], arr_napr[2,2], arr_napr[2,3] - напр. в МО (куда отправляем, массив кодов специализации, номер записи в справочнике персонала)
  // arr_napr[3,1], arr_napr[3,2], arr_napr[3,3] - напр. на лечение (куда направляем, код профиля, номер записи в справочнике персонала)
  // arr_napr[4,1], arr_napr[4,2], arr_napr[4,3] - напр. реабилитации (да/нет, код профиля, номер записи в справочнике персонала)
  // arr_napr[5,1], arr_napr[5,2], arr_napr[5,3] - напр. на сан.-кур. (да/нет, 0, номер записи в справочнике персонала)

  local i, j, arr
  local arr_napr := Array( 5, 3 )

  for i := 1 to 5
    for j := 1 to 3
      arr_napr[ i, j ] := 0
    next
  next

  arr := read_arr_dispans( lkod )

  for i := 1 to len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      do case
        Case arr[ i, 1 ] == '47'
          // If ValType( arr[ i, 2 ] ) == 'N'
          //   m1dopo_na  := arr[ i, 2 ]
          // Elseif ValType( arr[ i, 2 ] ) == 'A'
          //   m1dopo_na  := arr[ i, 2 ][ 1 ]
          //   If arr[ i, 2 ][ 2 ] > 0
          //     TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
          //     mtab_v_dopo_na := TPERS->tab_nom
          //   Endif
          // Endif
          // arr_napr[ 1, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 1, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '50'
          arr_napr[ 5, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 5, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '52'
          arr_napr[ 2, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 2, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
          arr_napr[ 2, 2 ] := arr[ i, 2 ]
        Case arr[ i, 1 ] == '54'
          arr_napr[ 3, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 3, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
          arr_napr[ 3, 2 ] := arr[ i, 2 ]
        Case arr[ i, 1 ] == '56'
          arr_napr[ 4, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 4, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
          arr_napr[ 4, 2 ] := arr[ i, 2 ]
      endcase
    endif
  next
  return arr_napr

// 12.04.26
function check_group_nazn( type, ... )
  // type - тип проверки ( '1' - общая, '2' - для ДРЗ )
  // для проверки используются PRIVATE переменные:
  // m1gruppa - начначенная группа здоровья
  // m1dopo_na - направление на дополнительное обследование
  // m1napr_v_mo - направление к специалистам 
  // m1napr_stac - направление на лечение
  // m1napr_reab - направления на реабилитацию
  // m1sank_na - не участвует в проверке
  local ret := .f.
  local mvar, i
  local nfunc := 'eq_any( m1gruppa'

  type := substr( type, 1, 1 )
  if pcount() < 2
    return ret
  endif
  // соберем вызов ф-ции
  for i := 2 to pcount()
    mvar := alltrim( str( hb_PValue( i ) ) )
    nfunc := nfunc + ', ' + mvar
  next
  nfunc += ')'

  if type == '1'
    ret := &nfunc .and. ( m1dopo_na == 0 ) .and. ( m1napr_v_mo == 0 ) .and. ( m1napr_stac == 0 ) .and. ( m1napr_reab == 0 )
  else
    ret := &nfunc .and. ( ( m1dopo_na != 0 ) .or. ( m1napr_v_mo != 0 ) .or. ( m1napr_stac != 0 ) .or. ( m1napr_reab != 0 ) )
  endif
  if ret .and. ( count_napr == 0 )
    if type == '1'
      func_error( 4, 'Для выбранной ГРУППЫ ЗДОРОВЬЯ выберите назначения (направления) для пациента!' )
    else
      func_error( 4, 'При направлении на II этап не допускаются назначения (направления) для пациента!' )
    endif
  Endif
  return ret

// 04.07.24
function is_dispanserizaciya( ishod )

  // return ( Between( ishod, 101, 102 ) .or. ;  // диспансеризация детей-сирот в стационарах или диспансеризация детей-сирот под опекой
  //       Between( ishod, 201, 205 ) .or. ;   // диспансеризация взрослого населения
  //       Between( ishod, 301, 305 ) .or. ;   // профилактики несовершеннолетних
  //       Between( ishod, 401, 402 ) .or. ;   // диспансеризация после COVID-19
  //       Between( ishod, 501, 502) )         // диспансеризация репродуктивного здоровья
  return ( is_sluch_dispanser_deti_siroty( ishod ) .or. ; // диспансеризация детей-сирот в стационарах или диспансеризация детей-сирот под опекой
    is_sluch_dispanser_DVN_prof( ishod ) .or. ;           // диспансеризация взрослого населения
    is_sluch_dispanser_profilaktika_deti( ishod ) .or. ;  // профилактики несовершеннолетних
    is_sluch_dispanser_COVID( ishod ) .or. ;              // диспансеризация после COVID-19
    is_sluch_dispanser_DRZ( ishod ) )                     // диспансеризация репродуктивного здоровья

// 04.07.24 это случай диспансеризацию детей-сирот
function is_sluch_dispanser_deti_siroty( ishod )

  return Between( ishod, 101, 102)

// 04.07.24 это случай диспансеризация/профилактика взрослого населения
function is_sluch_dispanser_DVN_prof( ishod )

  return Between( ishod, 201, 205)

// 04.07.24 это случай профилактики несовершеннолетних
function is_sluch_dispanser_profilaktika_deti( ishod )

  return Between( ishod, 301, 305)

// 04.07.24 это случай диспансеризации после COVID-19
function is_sluch_dispanser_COVID( ishod )

  return Between( ishod, 401, 402)

// 04.07.24 это случай диспансеризации репродуктивного здоровья
function is_sluch_dispanser_DRZ( ishod )

  return Between( ishod, 501, 502)

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

// 31.01.26
function prescriptions_dispans( human_kod, _NYEAR )

  local arr_nazn := {}
  Local arr, i, k
  Local aliasIsUse := aliasisalreadyuse( 'P2TABN' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers',, 'P2TABN' )
  Endif

  arr := read_arr_dispans( human_kod )
/*
  if is_sluch_dispanser_deti_siroty( human->ishod ) // дисп-ия детей-сирот
  elseif is_sluch_dispanser_profilaktika_deti( human->ishod ) // профосмотры несовершеннолетних
  elseif is_sluch_dispanser_DVN_prof( human->ishod ) // диспансеризация/профилактика взрослого населения
  Elseif is_sluch_dispanser_COVID( human->ishod ) // углубленная диспансеризация после COVID
  elseif is_sluch_dispanser_DRZ( human->ishod ) // диспансеризации репродуктивного здоровья
  endif
*/
  If m1dopo_na > 0
    For i := 1 To 4
      If IsBit( m1dopo_na, i )
        If mtab_v_dopo_na != 0
          If P2TABN->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
            AAdd( arr_nazn, { 3, i, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
          Else
            AAdd( arr_nazn, { 3, i, '', '' } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
          Endif
        Else
          AAdd( arr_nazn, { 3, i, '', '' } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
        Endif
      Endif
    Next
  Endif
  If Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
    For i := 1 To Len( arr_mo_spec ) // теперь каждая специальность в отдельном PRESCRIPTIONS
      If mtab_v_mo != 0
        If P2TABN->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )  // '-', т.к. спец-ть была в кодировке V015
        Else
          AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), '', '' } ) // '-', т.к. спец-ть была в кодировке V015
        Endif
      Else
        AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), '', '' } ) // '-', т.к. спец-ть была в кодировке V015
      Endif
    Next
  Endif
  If Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
    If mtab_v_stac != 0
      If P2TABN->( dbSeek( Str( mtab_v_stac, 5 ) ) )
        AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
      Else
        AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, '', '' } )
      Endif
    Else
      AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, '', '' } )
    Endif
  Endif
  If m1napr_reab == 1 .and. m1profil_kojki > 0
    If mtab_v_reab != 0
      If P2TABN->( dbSeek( Str( mtab_v_reab, 5 ) ) )
        AAdd( arr_nazn, { 6, m1profil_kojki, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
      Else
        AAdd( arr_nazn, { 6, m1profil_kojki, '', '' } )
      Endif
    Else
      AAdd( arr_nazn, { 6, m1profil_kojki, '', '' } )
    Endif
  Endif

  If ! aliasIsUse
    P2TABN->( dbCloseArea() )
    Select( oldSelect )
  Endif

  return arr_nazn

// 15.05.26
Function get_plans_KZVO( mYear, kod_mo )

  // plan_drz - Получить плановые показатели по диспансеризации репродуктивного здоровья
  //  1 - KOL_M(N) 2 - KOL_F(N) 3 - KOL0_14(N) 4 - KOL15_17(N) 5 YOUNG_MEN(N) 6 CHILDREN_INV
  Local arr
  local db
  local aTable

  local s

  kod_mo := AllTrim( kod_mo )
  arr := {}
  db := openSQL_DB()
  s := 'SELECT kol_m, kol_f, kol0_14, kol15_17, young_men, children_inv, children_stac, children_family FROM plans WHERE year=' + str( mYear, 4 ) + ' and kod_mo=' + kod_mo
  aTable := sqlite3_get_table( db, s )
    
  if len( aTable ) > 1
    aadd( arr, val( aTable[ 2, 1 ] ) ) // мужчины
    aadd( arr, val( aTable[ 2, 2 ] ) ) // женщины
    aadd( arr, val( aTable[ 2, 3 ] ) ) // дети от 0 до 14 включительно
    aadd( arr, val( aTable[ 2, 4 ] ) ) // дети от 15 до 17 включительно
    aadd( arr, val( aTable[ 2, 5 ] ) ) // юноши 15-17 лет  включительно
    aadd( arr, val( aTable[ 2, 6 ] ) ) // дети-инвалиды
    aadd( arr, val( aTable[ 2, 7 ] ) ) // дети-сироты в стационарных учреждениях
    aadd( arr, val( aTable[ 2, 8 ] ) ) // дети-сироты под опекой в семьях
  else
    arr := { 0, 0, 0, 0, 0, 0 } // нет данных
  endif
  db := nil
  return arr