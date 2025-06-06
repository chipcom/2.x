#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"
#include 'dbstruct.ch'

// ***** 02.04.22 - просмотр списка имплантантов
Function view_implantant( arrImplantant, date_usl, fl_change )

  Local tmp_keys
  Local oBox, oBrowse, oColumn
  Local nTop := 7, nLeft := 10, nBottom := 17, nRight := 70
  Local cAlias := 'tmp_001'
  Local oldSelect := Select()
  Local row, mtitle, l_color
  Local mo_implant := { ;  // имплантанты
  { 'KOD_HUM',   'N',   7, 0 }, ; // код листа учёта по файлу "human"
  { 'KOD_K',     'N',   7, 0 }, ; // код по картотеке
  { 'MO_HU_K',   'N',   7, 0 }, ; // recno() из файла mo_hu.dbf
  { 'DATE_UST',  'D',   8, 0 }, ; // дата установки импланта
  { 'RZN',       'N',   6, 0 }, ;  // Код вида медицинского изделия (номенклатурная классификация медицинских изделий справочника МинЗдрава (OID 1.2.643.5.1.13.13.11.1079))
  { 'SER_NUM',   'C', 100, 0 };  // Серийный номер
  }
  Local fl_found
  Local buf := SaveScreen()
  Local k_hum, mo_hu_rec

  dbCreate( cur_dir() + 'tmp_impl', mo_implant )
  g_use( cur_dir() + 'tmp_impl', , cAlias, , .t. )
  dbSelectArea( cAlias )
  For Each row in arrImplantant
    ( cAlias )->( dbAppend() )
    ( cAlias )->KOD_HUM := row[ 1 ]
    k_hum := row[ 1 ]
    ( cAlias )->KOD_K := row[ 2 ]
    If fl_change
      ( cAlias )->DATE_UST := date_usl
    Else
      ( cAlias )->DATE_UST := row[ 3 ]
    Endif
    ( cAlias )->RZN := row[ 4 ]
    ( cAlias )->SER_NUM := row[ 5 ]
    ( cAlias )->MO_HU_K := row[ 6 ]
    mo_hu_rec := row[ 6 ]
  Next
  fl_found := ( ( cAlias )->( LastRec() ) > 0 )

  ( cAlias )->( dbGoTop() )
  If fl_found
    Keyboard Chr( K_RIGHT )
  Else
    Keyboard Chr( K_INS )
  Endif

  tmp_keys := my_savekey()
  Save gets To tmp_gets

  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"

  mtitle := 'Установленные имплантанты'
  alpha_browse( nTop, nLeft, nBottom, nRight, 'f_view_implant', color1, mtitle, col_tit_popup, ;
    .f., .t., , 'f1_view_implant', 'f2_view_implant', , ;
    { "═", "│", "═", l_color, .t., 180 } )

  ( cAlias )->( dbCloseArea() )

  delete_implantants( k_hum, mo_hu_rec )
  save_implantants( k_hum, mo_hu_rec )
  Restore gets From tmp_gets
  my_restkey( tmp_keys )
  Select( oldSelect )
  RestScreen( buf )

  Return Nil

// **** 14.03.22
Function f_view_implant( oBrow )

  Local oColumn, blk_color

  blk_color := {|| { 1, 2 } }

  oColumn := TBColumnNew( 'Вид имплантанта', {|| PadR( inieditspr( A__MENUVERT, get_implantant(), tmp_001->RZN ), 31 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Серийный номер имплантанта', {|| PadR( tmp_001->SER_NUM, 27 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление" )

  Return Nil

// **** 13.03.22
Function f1_view_implant()
  Return Nil

// **** 14.03.22
Function f2_view_implant( nKey, oBrow )

  Local flag := -1, ret

  Do Case
  Case nKey == K_INS .or. ( nKey == K_ENTER )
    If nKey == K_ENTER
      ret := select_implantant( tmp_001->DATE_UST, tmp_001->RZN, tmp_001->SER_NUM )
    Else
      ret := select_implantant( tmp->DATE_U1 )
      If ret != nil
        tmp_001->( dbAppend() )
      Endif
    Endif
    If LastKey() != K_ESC
      tmp_001->DATE_UST := ret[ 1 ]
      tmp_001->RZN := ret[ 2 ]
      tmp_001->SER_NUM := ret[ 3 ]
      tmp_001->KOD_HUM := tmp->KOD
      tmp_001->KOD_K := glob_kartotek
      tmp_001->MO_HU_K := tmp->rec_hu
      tmp_001->( dbGoTop() )
    Endif
    flag := 0
  Case nKey == K_DEL .and. f_esc_enter( 2 )
    tmp_001->( dbDelete() )
    tmp_001->( __dbPack() )
    oBrow:gotop()
    tmp_001->( dbGoTop() )
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// ***** 17.03.22 - выбор импланта
Function select_implantant( date_ust, rzn, ser_num )

  Local ret := NIL, oBox
  Local buf, tmp_keys, iRow
  Local sPicture
  Local mNUMBER

  Private mVIDIMPL := '', m1VIDIMPL := 0

  // Private glob_Implantant := get_implantant()
  Private tmp_Implantant := create_classif_ffoms( 2, 'Implantant' )

  Default rzn To 0
  Default ser_num To Space( 100 )

  m1VIDIMPL := rzn
  mNUMBER := PadR( ser_num, 100 )

  mVIDIMPL := PadR( inieditspr( A__MENUVERT, get_implantant(), m1VIDIMPL ), 44 )

  buf := SaveScreen()
  change_attr()
  iRow := 11
  tmp_keys := my_savekey()
  Save gets To tmp_gets

  oBox := tbox():new( iRow, 10, iRow + 5, 70, .t. )
  oBox:CaptionColor := 'B/B*'
  oBox:Color := cDataCGet
  oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
  oBox:Caption := 'Выберите имплантант'
  oBox:view()

  Do While .t.
    iRow := 12

    @ ++iRow, 12 Say 'Вид импланта:' Get mVIDIMPL ;
      reader {| x| menu_reader( x, tmp_Implantant, A__MENUVERT, , , .f. ) } ;
      valid {|| mVIDIMPL := PadR( mVIDIMPL, 44 ), .t. }

    sPicture := '@S40'
    @ ++iRow, 12 Say 'Серийный номер:' Get mNUMBER Picture sPicture ;
      valid {|| !Empty( mNUMBER ) }

    myread()
    If LastKey() != K_ESC .and. m1VIDIMPL != 0
      ret := { date_ust, m1VIDIMPL, AllTrim( mNUMBER ) }
      Exit
    Else
      Exit
    Endif
  Enddo
  update_gets()

  oBox := nil
  RestScreen( buf )
  Restore gets From tmp_gets
  my_restkey( tmp_keys )

  Return ret

// ***** 12.03.22 вернуть имплантант в листе учета
Function exist_implantant_in_db( mkod_human, rec_hu )

  Local oldSelect := Select()
  Local arrImplantant, ser_num
  Local cAlias := 'IMPL', impAlias
  Local fl := .f.

  // default rec_hu to 0
  hb_default( @rec_hu, 0 )
  impAlias := Select( cAlias )
  If impAlias == 0
    r_use( dir_server() + 'human_im', dir_server() + 'human_im', cAlias )
  Endif
  dbSelectArea( cAlias )
  If rec_hu == 0
    ( cAlias )->( dbSeek( Str( mkod_human, 7 ) ) )
  Else
    ( cAlias )->( dbSeek( Str( mkod_human, 7 ) + Str( rec_hu, 7 ) ) )
  Endif
  If ( cAlias )->( Found() )
    fl := .t.
  Endif
  ( cAlias )->( dbCloseArea() )
  Select( oldSelect )
  If impAlias == 0
    ( cAlias )->( dbCloseArea() )
  Endif

  Return fl

// ***** 18.03.22 вернуть имплантант в листе учета
Function collect_implantant( mkod_human, rec_hu )

  Local oldSelect := Select()
  Local ser_num, arrImplantant := {}
  Local cAlias := 'IMPL', impAlias

  hb_default( @rec_hu, 0 )
  impAlias := Select( cAlias )
  If impAlias == 0
    r_use( dir_server() + 'human_im', dir_server() + 'human_im', cAlias )
  Endif
  dbSelectArea( cAlias )
  If rec_hu == 0
    ( cAlias )->( dbSeek( Str( mkod_human, 7 ) ) )
  Else
    ( cAlias )->( dbSeek( Str( mkod_human, 7 ) + Str( rec_hu, 7 ) ) )
  Endif
  If ( cAlias )->( Found() )
    Do While !( cAlias )->( Eof() ) .and. mkod_human == ( cAlias )->KOD_HUM
      If rec_hu != 0 .and. rec_hu != ( cAlias )->MO_HU_K
        ( cAlias )->( dbSkip() )
        Loop
      Endif
      // найти серийный номер если есть
      ser_num := chek_implantant_ser_number( ( cAlias )->( RecNo() ) )
      // создать массив
      AAdd( arrImplantant, { ( cAlias )->KOD_HUM, ( cAlias )->KOD_K, ( cAlias )->DATE_UST, ( cAlias )->RZN, iif( ser_num != nil, ser_num, '' ), ( cAlias )->MO_HU_K } )
      ( cAlias )->( dbSkip() )
    Enddo
  Endif
  ( cAlias )->( dbCloseArea() )
  Select( oldSelect )
  If impAlias == 0
    ( cAlias )->( dbCloseArea() )
  Endif

  Return arrImplantant

// ***** 16.03.22 удалить имплантанты в листе учета
Function delete_implantants( mkod_human, rec_hu )

  Local oldSelect := Select()
  Local cAlias := 'IMPL'

  hb_default( @rec_hu, 0 )
  use_base( "human_im" )
  // find (str(mkod_human, 7))
  dbSelectArea( cAlias )
  ( cAlias )->( dbGoTop() )
  Do While !( cAlias )->( Eof() )
    If mkod_human == ( cAlias )->KOD_HUM
      If rec_hu == 0
        // вначале удалить серийный номер если есть
        delete_implantant_ser_number( ( cAlias )->( RecNo() ) )
        deleterec( .t. )  // очистка записи с пометкой на удаление
      Else
        If ( cAlias )->MO_HU_K == rec_hu
          // вначале удалить серийный номер если есть
          delete_implantant_ser_number( ( cAlias )->( RecNo() ) )
          deleterec( .t. )  // очистка записи с пометкой на удаление
        Endif
      Endif
    Endif
    ( cAlias )->( dbSkip() )
  Enddo
  ( cAlias )->( dbCloseArea() )
  Select( oldSelect )

  Return Nil

// ***** 16.03.22 сохранить имплантант в БД учета
Function save_implantants( mkod_human, rec_hu )

  Local oldSelect := Select()
  Local cAlias := 'tmp_001'

  use_base( "human_im" )

  r_use( cur_dir() + 'tmp_impl', , cAlias )
  dbSelectArea( cAlias )
  ( cAlias )->( dbGoTop() )
  Do While ! ( cAlias )->( Eof() )
    dbSelectArea( 'IMPL' )
    addrec( 7, , .t. )
    IMPL->KOD_HUM   := ( cAlias )->KOD_HUM
    IMPL->KOD_K     := ( cAlias )->KOD_K
    IMPL->DATE_UST  := ( cAlias )->DATE_UST
    IMPL->RZN       := ( cAlias )->RZN
    IMPL->MO_HU_K   := ( cAlias )->MO_HU_K
    If ! Empty( ( cAlias )->SER_NUM )
      // сохранить серийный номер если есть
      save_implantant_ser_number( IMPL->( RecNo() ), ( cAlias )->SER_NUM )
    Endif
    dbSelectArea( cAlias )
    ( cAlias )->( dbSkip() )
  End Do
  ( cAlias )->( dbCloseArea() )
  IMPL->( dbCloseArea() )
  Select( oldSelect )

  Return Nil

// **** 01.02.22 вернуть массив услуга для имплантации
Function ret_impl_v036( s_code, lk_data )

  // s_code - код федеральной услуги
  // lk_data - дата оказания услуги
  Local i, retArr := nil
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv036(), {| x| x[ 1 ] == code .and. ( x[ 3 ] == 1 .or. x[ 3 ] == 3 ) } ) ) > 0 ) // согласно ПУМП 04-18-03 от 31.01.2022
    retArr := getv036()[ i ]
  Endif

  Return retArr

// **** 12.03.22 услуга требует имплантанты
Function service_requires_implants( s_code, lk_data )

  // s_code - код федеральной услуги
  // lk_data - дата оказания услуги
  Local i, fl := .f.
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv036(), {| x| x[ 1 ] == code .and. ( x[ 3 ] == 1 .or. x[ 3 ] == 3 ) } ) ) > 0 ) // согласно ПУМП 04-18-03 от 31.01.2022
    fl := .t.
  Endif

  Return fl
