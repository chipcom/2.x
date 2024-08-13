#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.08.24
Function reestr_xml_fns()

  Local mtitle
  Local buf := SaveScreen()

  use_base( 'xml_fns', 'xml' )

  xml->( dbGoBottom() )
  mtitle := 'Файлы выгрузки для ФНС'
  alpha_browse( 5, 0, MaxRow() - 2, 79, 'defColumn_xml_FNS', color0, mtitle, 'BG+/GR', ;
    .f., .t., , , 'serv_xml_fns', , ;
    { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

  dbCloseAll()
  RestScreen( buf )

  Return Nil

// 13.08.24
function defColumn_xml_FNS( oBrow )

  Local oColumn, s
//  Local blk := {|| iif( Empty( xml->kod_xml ), { 5, 6 }, { 3, 4 } ) }

  oColumn := TBColumnNew( ' Код ', {|| str( xml->kod, 6 ) } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Имя файла ', {|| xml->fname } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Имя файла 2', {|| xml->fname2 } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  Дата', {|| date_8( xml->dfile ) } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  s := '<Esc> выход <Ins> новый'
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<Del>', '<Ctrl+Enter>', '<F3>', '<F4>', '<F8>', '<F9>', '<F10>' }, 'R/W' )

  Return Nil

// 13.08.24
function serv_xml_fns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2

  Do Case
  Case nKey == K_F9
  Case nKey == K_INS
  Case nKey == K_DEL
  Otherwise
    Keyboard ''
  Endcase

  Return flag
