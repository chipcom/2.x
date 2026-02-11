// реестры/счета с 2019 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// 20.11.25
Function create1reestr19( _recno, _nyear, _nmonth, p_tip_reestr )

  Local buf := SaveScreen(), i, j, pole
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local reg_sort

  Private mpz, oldpz, atip

  lenPZ := len( p_array_PZ )

  mpz := Array( lenPZ + 1 )
  oldpz := Array( lenPZ + 1 )
  atip := Array( lenPZ + 1 )

  For j := 0 To lenPZ    // для таблицы _moXunit 03.02.23
    pole := 'tmp->PZ' + lstr( j )
    mpz[ j + 1 ] := oldpz[ j + 1 ] := &pole
    atip[ j + 1 ] := '-'
    If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j } ) ) > 0
      atip[ j + 1 ] := p_array_PZ[ i, 4 ]
    Endif
  Next

  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma
  private p_blk := {| mkol, msum| f_blk_create1reestr19() }

  dbCloseAll()
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Use ( cur_dir() + 'tmpb' ) New Alias TMP
  Set Relation To FIELD->kod_human into HUMAN
  Index On Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' ) For FIELD->kod_tmp == _recno
  Go Top
  Eval( p_blk )
  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestrCommon', color0, ;
      'Составление реестра случаев за ' + mm_month()[ _nmonth ] + Str( _nyear, 5 ) + ' года', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestrCommon', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', , 300 } )
    If pkol > 0 .and. ( reg_sort := f_alert( { '', ;
        'Каким образом сортировать реестр, отправляемый в ТФОМС', ;
        '' }, ;
        { ' по ~ФИО пациента ', ' по ~убыванию стоимости ' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6, , 'BG+/RB, W+/R, W+/RB, GR+/R' ) ) > 0
      f_message( { 'Системная дата: ' + date_month( sys_date, .t. ), ;
        'Обращаем Ваше внимание, что', ;
        'реестр будет создан с этой датой.', ;
        '', ;
        'Изменить её будет НЕВОЗМОЖНО!', ;
        '', ;
        'Сортировка реестра: ' + { 'по ФИО пациента', 'по убыванию стоимости лечения' }[ reg_sort ] }, , ;
        'GR+/R', 'W+/R' )
      If f_esc_enter( 'составления реестра' )
        RestScreen( buf )
        create2reestr19( _recno, _nyear, _nmonth, reg_sort, p_tip_reestr )
      Endif
    Endif
  Endif
  dbCloseAll()
  RestScreen( buf )
  Return Nil

// 03.01.26
Function f_blk_create1reestr19()  // 

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

