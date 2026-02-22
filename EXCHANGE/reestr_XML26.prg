// реестры/счета с 2026 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 06.01.26
//Function create1reestr26( _recno, _nyear, _nmonth, kod_smo, p_tip_reestr )  //  , aBukva )
Function create1reestr26( _nyear, _nmonth, kod_smo, p_tip_reestr )

  Local buf := SaveScreen(), i, j, pole
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  Local reg_sort, cFor, bFor

  Private mpz, oldpz, atip, p_array_PZ

  p_array_PZ := get_array_pz( _nyear )  // получим массив план-заказа на год составления реестра
  lenPZ := len( p_array_PZ )

  mpz := Array( lenPZ + 1 )
  oldpz := Array( lenPZ + 1 )
  atip := Array( lenPZ + 1 )

  For j := 0 To lenPZ    // для таблицы _moXunit 03.02.23
    pole := 'A_SMO->PZ' + lstr( j )
    mpz[ j + 1 ] := oldpz[ j + 1 ] := &pole
    atip[ j + 1 ] := '-'
    If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j } ) ) > 0
      atip[ j + 1 ] := p_array_PZ[ i, 4 ]
    Endif
  Next

  Private pkol := A_SMO->kol, psumma := A_SMO->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma
  Private p_blk := { | mkol, msum| f_blk_create1reestr26() }

  g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  g_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_

  cFor := 'FIELD->tip == ' + AllTrim( str( p_tip_reestr, 1 ) ) + '.and. FIELD->kod_smo == "' + kod_smo + '"'
  bFor := &( '{||' + cFor + '}' )
  tmpb->( __dbCopy( 'mem:tmp', , bFor ) )
  dbUseArea( .t., , 'mem:tmp', 'TMP', .f., .f. )
  dbSelectArea( 'TMP' )
  Set Relation To FIELD->kod_human into HUMAN

  INDEX ON Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' )  

  tmp->( dbGoTop() )
  Eval( p_blk ) 

  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestrCommon', color0, ;
      'Составление реестра счетов за ' + mm_month()[ _nmonth ] + Str( _nyear, 5 ) + ' года', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestrCommon', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', , 300 } )
    If pkol > 0 .and. ( reg_sort := f_alert( { '', ;
        'Каким образом сортировать реестр, отправляемый в ТФОМС', ;
        '' }, ;
        { ' по ~ФИО пациента ', ' по ~убыванию стоимости ' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6, , 'BG+/RB, W+/R, W+/RB, GR+/R' ) ) > 0
      f_message( { 'Системная дата: ' + date_month( Date(), .t. ), ;
        'Обращаем Ваше внимание, что', ;
        'реестр будет создан с этой датой.', ;
        '', ;
        'Изменить её будет НЕВОЗМОЖНО!', ;
        '', ;
        'Сортировка реестра: ' + { 'по ФИО пациента', 'по убыванию стоимости лечения' }[ reg_sort ] }, , ;
        'GR+/R', 'W+/R' )
      If f_esc_enter( 'составления реестра' )
        RestScreen( buf )
/*
        if reg_sort == 1 
          INDEX ON FIELD->BUKVA + Upper( human->fio ) + DToS( tmp->k_data ) to ( 'mem:tmp' ) FOR FIELD->plus  // FOR kod_tmp == _recno
        else
          INDEX ON FIELD->BUKVA + Str( FIELD->pz, 2 ) + Str( 10000000 - FIELD->cena_1, 11, 2 ) to ( 'mem:tmp' ) FOR FIELD->plus   // .and. kod_tmp == _recno 
        endif
*/
//        create2reestr26( _recno, _nyear, _nmonth, reg_sort, kod_smo, p_tip_reestr, aBukva )
        create2reestr26( _nyear, _nmonth, kod_smo, p_tip_reestr, reg_sort )
      Endif
    Endif
  Endif
  close_list_alias( { 'TMP' } )
  dbDrop( 'mem:tmp' )  /* освободим память */
  hb_vfErase( 'mem:tmp.ntx' )  /* освободим память от индексного файла */

  close_list_alias( { 'HUMAN_3', 'HUMAN_', 'HUMAN' } )
  RestScreen( buf )
  Return Nil

// 03.01.26
Function f_blk_create1reestr26()  // 

  Local i, s, ta[ 2 ], sh := MaxCol() + 1

  s := 'Случаев - ' + expand_value( pkol ) + ' на сумму ' + expand_value( psumma, 2 ) + ' руб.'
  @ 0, 0 Say PadC( s, sh ) Color color1
  s := ''
  For i := 1 To Len( mpz )
    If !Empty( mpz[ i ] )
      s += AllTrim( str_0( mpz[ i ], 9, 2 ) ) + ' ' + atip[ i ] + ', '
    Endif
  Next
  If !Empty( s )
    s := '(п/з: ' + SubStr( s, 1, Len( s ) -2 ) + ')'
  Endif
  perenos( ta, s, sh )
  For i := 1 To 2
    @ i, 0 Say PadC( AllTrim( ta[ i ] ), sh ) Color color1
  Next
  Return Nil