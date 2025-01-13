#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

#define PLAT 1  // подзадача платные услуги
#define ORTO 2  // подзадача ортопедия
#define KASSA_MO 3 // подзадача касса МО

// 12.01.25
function control_number_phone( get )

  local phoneTemplate := '^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$'  
//  local phoneTemplate := "^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$"
  local lRet := .f.

  lRet := hb_RegexLike( phoneTemplate, get:Buffer )
  if ! lRet
    func_error( 4, 'Не допустимый номер телефона!' )
  endif

  return lRet

// 13.01.25
function check_payer( g )

  local oBox, lRet := .f., tmp_keys, tmp_list
  local tmp_select

  local MFIO := Space( 50 ) // Ф.И.О. больного
  local mfam := Space( 20 ), mim := Space( 20 ), mot := Space( 20 )
  local mdate_r := CToD( '  /  /    ')
  local mSearch := '', lFind := .f., mINN := space( 12 )
  local mser_ud := Space( 10 ), mnom_ud := Space( 20 ), MKOGDAVYD := CToD( '' ) // когда выдан паспорт
  local mSer_num, oPassport

  private MVID_UD, ; // вид удостоверения
          M1VID_UD    := 14, ; // 1-18
          mPHONE_M := Space( 11 )
      
  if m1P_ATTR == 1  // плательщик и пациент одно лицо
    return .t.
  endif

  tmp_select := select()
  tmp_keys := my_savekey()
  Save gets To tmp_list

  oBox := tbox():new( 5, 5, 15, MaxCol() - 5, .t. )
  oBox:ChangeAttr := .t.
  oBox:CaptionColor := color8
  oBox:Caption := 'Плательщик'
  // oBox:Color := color1
  oBox:Save := .t.
  oBox:view()

	do while .t.
    mvid_ud   := PadR( inieditspr( A__MENUVERT, TPassport():aMenuType, m1vid_ud ), 23 )

    @ 1, 6 TBOX oBox Say 'Фамилия' Get mfam Pict '@K@!' VALID { | g | LastKey() == K_UP .or. valfamimot( 1, mfam ) }
    @ 1, Col() + 1 TBOX oBox Say 'Имя' Get mim Pict '@K@!' valid { | g | valfamimot( 2, mim ) }
    @ 2, 6 TBOX oBox Say 'Отчество' Get mot Pict '@K@!' valid { | g | valfamimot( 3, mot ) }
    @ 3, 6 TBOX oBox Say 'Дата рождения' Get mdate_r

    @ 4, 6 TBOX oBox Say 'ИНН' Get mINN pict '999999999999' valid { | g | check_input_INN( g ) }
    @ 5, 6 TBOX oBox Say 'Уд-ие личности:' Get mvid_ud ;
      reader {| x| menu_reader( x, TPassport():aMenuType, A__MENUVERT, , , .f. ) }
    @ 6, 6 TBOX oBox Say 'Серия' Get mser_ud Pict '@!' valid {| oGet | checkdocumentseries( oGet, m1vid_ud ) }
    @ 6, 25 TBOX oBox Say '№' Get mnom_ud Pict '@!S18' Valid val_ud_nom( 1, m1vid_ud, mnom_ud )
    @ 6, 50 TBOX oBox Say 'Выдан' Get mkogdavyd
  
//    @ 7, 6 TBOX oBox Say 'Телефон мобильный' Get mPHONE_M valid {| g | control_number_phone( g ) } //valid_phone( g, .t. ) }
    @ 7, 6 TBOX oBox Say 'Телефон мобильный' Get mPHONE_M valid {| g | valid_phone( g, .t. ) }

    myread()
    if lastkey() != K_ESC
//      oPassport := TPassport():New( M1VID_UD, mser_ud, mnom_ud, , )
      use_base( 'payer', 'payer' )
      MFIO := upper( alltrim( mfam ) + ' ' + alltrim( mim ) + ' ' + alltrim( mot ) )
      mSearch := MFIO + DToC( mdate_r )
      mSer_num := alltrim( mser_ud ) + ' ' + alltrim( mnom_ud )
      mINN := alltrim( mINN )

      payer->( dbSeek( padr( MFIO, 50 ) ) )
      if payer->( found() )
        Do While alltrim( payer->NAME ) == MFIO .and. payer->DOB == mdate_r .and. !Eof()
          if ( ! Empty( mINN ) ) .and. ( alltrim( payer->INN ) == mINN ) .or. ;
                ( payer->VID_UD == M1VID_UD .and. alltrim( payer->SER_NUM ) == mSer_num )
            mKod_payer := payer->KOD_PAYER
            lFind := .t.
            exit
          endif
        enddo
      endif
      if ! lFind
        payer->( dbAppend() )
        payer->NAME := MFIO
        payer->VID_UD := M1VID_UD
        payer->INN := mINN
        payer->PHONE := mPHONE_M
        payer->KOD_PAYER := recno()
        payer->SER_NUM := mSer_num
        payer->DOB := mdate_r
      endif
      mKod_payer := payer->KOD_PAYER
      payer->( dbCloseArea() )
      lRet := .t.
      exit
    else
      exit
    endif
  enddo
  Restore gets From tmp_list
  my_restkey( tmp_keys )
  select( tmp_select )
  return lRet

// 13.08.24
function reestr_spravka_fns()

  Local mtitle
  Local buf := SaveScreen()

  use_base( 'reg_fns', 'fns' )

  fns->( dbGoBottom() )
  mtitle := 'Сформированные справки для ФНС'
  alpha_browse( 5, 0, MaxRow() - 2, 79, 'defColumn_Spravka_FNS', color0, mtitle, 'BG+/GR', ;
    .f., .t., , , 'serv_spravka_fns', , ;
    { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

  dbCloseAll()
  RestScreen( buf )

  return nil

// 11.01.25
Function defcolumn_spravka_fns( oBrow )

  Local oColumn, s
  local mm_plat := { { 'он же ', 1 }, { 'другой', 0 } }
  Local blk := {|| iif( Empty( fns->kod_xml ), { 5, 6 }, { 3, 4 } ) }

//  oColumn := TBColumnNew( ' Год ', {|| str( fns->nyear, 4 ) } )
//  oColumn:colorBlock := blk
//  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Номер ', {|| str( fns->num_s, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  Дата', {|| date_8( fns->date ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Вер.', {|| str( fns->version, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'ФИО', {|| substr( short_FIO( fns->plat_fio ), 1, 15 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Плат. ', {|| inieditspr( A__MENUVERT, mm_plat, fns->attribut ) } ) //substr( short_FIO( fns->plat_fio ), 1, 15 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 1', {|| str( fns->sum1, 9, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 2', {|| str( fns->sum2, 9, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Статус', {|| iif( fns->kod_xml <= 0, iif( fns->kod_xml == 0, 'не обработано', 'принтер' ), 'файл' ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

//  s := '<Esc> выход <F5> журнал справок <F9> печать <Del> аннулирование'
  s := '<Esc> выход <F5> журнал справок <F9> печать'
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Del>', '<F5>', '<F9>' }, 'R/W' )

  Return Nil

// 02.01.25
Function serv_spravka_fns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2
  local arr_m
  Local name_file := 'Журнал сформированных справок'
  Local name_file_full := name_file + '.xlsx'

  Do Case
  Case nKey == K_F9
    if fns->kod_xml == -1 .or. fns->kod_xml == 0
      print_spravka_fns()
    else
      func_error( 4, 'Справка включена в файл обмена с ФНС!' )
    endif
  Case nKey == K_F5
//    If ( arr_m := year_month( ) ) == NIL
//      return flag
//    endif

//    fns_jornal_excel( hb_OEMToANSI( name_file_full ), arr_m )
////    work_with_Excel_file( name_file_full )

    Case nKey == K_DEL
//    anul_spravka_fns()
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 13.01.25
function print_spravka_fns()

  local hSpravka, pos, cFileToSave
  local org := hb_main_curOrg
  local aFIOPlat, aFIOPacient
  local innPlat, dobPlat, vidDocPlat, sernumPlat, dateVydPlat := CToD( '  /  /    ')
  local innPacient := '', dobPacient := CToD( '  /  /    '), vidDocpacient := 21, sernumPacient := '', dateVydPacient := CToD( '  /  /    ')
  local tmp_select

  pos := hb_At( '/', org:INN() )
  if fns->attribut == 0
    tmp_select := select()
    r_use( dir_server + 'payer', , 'payer' )
    payer->( dbGoto( fns->kod_payer ) )
    if ! payer->( eof() ) .and. ! payer->( bof() )
      aFIOPlat := razbor_str_fio( payer->name )
      aFIOPacient := razbor_str_fio( fns->plat_fio )
      innPlat := payer->inn
      dobPlat := payer->DOB
      vidDocPlat := soot_doc( payer->VID_UD )
      sernumPlat := payer->SER_NUM
      dateVydPlat := payer->KOGDAVYD

      innPacient := fns->inn
      dobPacient := fns->plat_dob
      vidDocPacient := soot_doc( fns->viddoc )
      sernumPacient := fns->SER_NUM
      dateVydPacient := fns->datevyd
    endif
    payer->( dbCloseArea() )
    select( tmp_select )
  else
    aFIOPlat := razbor_str_fio( fns->plat_fio )
    innPlat := fns->inn
    dobPlat := fns->plat_dob
    vidDocPlat := fns->VIDDOC
    sernumPlat := fns->SER_NUM
    dateVydPlat := fns->datevyd
    aFIOPacient := { '', '', '' }
  endif

  cFileToSave := cur_dir() + 'spravkaFNS.pdf'

  hSpravka := hb_Hash()
  if pos == 0
    hb_HSet( hSpravka, 'inn', org:INN() )
    hb_HSet( hSpravka, 'kpp', '' )
  else
    hb_HSet( hSpravka, 'inn', substr( org:INN(), 1, pos - 1) )
    hb_HSet( hSpravka, 'kpp', substr( org:INN(), pos + 1 ) )
  endif
  hb_HSet( hSpravka, 'num_spr', fns->num_s )
  hb_HSet( hSpravka, 'nYear', fns->nyear )
  hb_HSet( hSpravka, 'cor', fns->version )
  hb_HSet( hSpravka, 'name', org:Name() )
  hb_HSet( hSpravka, 'full_name', org:Name() )

  hb_HSet( hSpravka, 'fam', aFIOPlat[ 1 ] )
  hb_HSet( hSpravka, 'im', aFIOPlat[ 2 ] )
  hb_HSet( hSpravka, 'ot', aFIOPlat[ 3 ] )
  hb_HSet( hSpravka, 'inn_plat', innPlat ) // fns->INN )
  hb_HSet( hSpravka, 'dob', dobPlat ) // fns->plat_dob )
  hb_HSet( hSpravka, 'vid_d', vidDocPlat ) // fns->viddoc )
  hb_HSet( hSpravka, 'ser', sernumPlat ) // fns->ser_num )
//  hb_HSet( hSpravka, 'nomer', '123456' )
  hb_HSet( hSpravka, 'dVydach', dateVydPlat ) // fns->datevyd )
  hb_HSet( hSpravka, 'attribut', fns->attribut )
  hb_HSet( hSpravka, 'sum1', fns->sum1 )
  hb_HSet( hSpravka, 'sum2', fns->sum2 )
  hb_HSet( hSpravka, 'fioSost', fns->predst )
  hb_HSet( hSpravka, 'dSost', fns->Date )
  hb_HSet( hSpravka, 'kolStr', iif( fns->attribut == 1, 1, 2 ) )
  hb_HSet( hSpravka, 'famPacient', aFIOPacient[ 1 ] )
  hb_HSet( hSpravka, 'imPacient', aFIOPacient[ 2 ] )
  hb_HSet( hSpravka, 'otPacient', aFIOPacient[ 3 ] )
  hb_HSet( hSpravka, 'dobPacient', dobPacient )
  hb_HSet( hSpravka, 'innPacient', innPacient )
  hb_HSet( hSpravka, 'vid_d_pacient', vidDocpacient )
  hb_HSet( hSpravka, 'ser_pacient', sernumPacient )
  hb_HSet( hSpravka, 'dVydachPacient', dateVydPacient )
//  hb_HSet( hSpravka, 'annul', 1 ) // справка на аннулирование, 1 - да, 0 - нет

  if DesignSpravkaPDF( cFileToSave, hSpravka )
    view_file_in_Viewer( cFileToSave )
    G_RLock( forever )
    fns->kod_xml := -1
    Unlock
  endif
  return nil

// 19.08.24
function anul_spravka_fns()

  local rec := fns->( recno() ), str_find
  local mkod, mPlat, mNyear, mNspravka, mVersion, mAttribut
  local mInn, mPlat_fio, mPlat_dob, mPlat_vid, mPlat_ser_num, mPlat_date_vyd, mSum1, mSum2
  local predst := '', predst_doc := '', pred_ruk := 0
  local org := hb_main_curOrg

  if ! fns->( eof() )

    _fns_nastr( 1 ) // прочитаем сущетствующие настроеки
    pred_ruk := fns_PODPISANT
    if pred_ruk == 0
      predst := alltrim( fns_PREDST )
      predst_doc := alltrim( fns_PREDST_DOC )
    else
      predst := upper( alltrim( org:ruk_fio() ) )
    endif
    mPlat := fns->kod_k
    mNyear := fns->nyear
    mNspravka := fns->num_s
    mVersion := fns->version
    mAttribut := fns->attribut
    mInn := fns->INN
    mPlat_fio := fns->PLAT_FIO
    mPlat_dob := fns->PLAT_DOB
    mPlat_vid := fns->VIDDOC
    mPlat_ser_num := fns->SER_NUM
    mPlat_date_vyd := fns->DATEVYD
    mSum1 := fns->SUM1
    mSum2 := fns->SUM2

    str_find := Str( mPlat, 7 ) + Str( mNyear, 4 ) + Str( mAttribut, 1 ) + Str( mNspravka, 7 ) + '999'
    fns->( dbSeek( str_find ) )
    if fns->( Found() )
      fns->( dbGoto( rec ) )
      func_error( 4, 'Для справки уже сформирована аннулирующая запись!' )
      return nil
    endif
    select fns
    add1rec( 7 )
    mkod := RecNo()
    fns->kod := mkod
    fns->kod_k := mPlat
    fns->date := date()
    fns->nyear := mNyear
    fns->num_s := mNspravka
    fns->version := 999
    fns->inn := mInn
    fns->plat_fio := mPlat_fio
    fns->plat_dob := mPlat_dob
    fns->viddoc := mPlat_vid
    fns->ser_num := mPlat_ser_num
    fns->datevyd := mPlat_date_vyd

    fns->attribut := mAttribut  // плательщик, пациент одно лицо

    fns->sum1 := mSum1
    fns->sum2 := mSum2

    fns->pred_ruk := pred_ruk
    if pred_ruk == 0
      fns->predst := predst
      fns->pred_doc := predst_doc
    else
      fns->predst := predst
      fns->pred_doc := ''
    endif

    g_rlock( forever )
  endif
  return nil

// 03.01.25 проверка существования справки за конкретный год
function exist_spravka( get, kod_kart, onePerson )
  // get - объект Get системы
  // kod_kart - код пациента по картотеке
  // onePerson - налогоплательщик и пациент одно лицо ( 1- да, 0 - нет)

  local nyear, str_find, tmp_select, i
  local zakaz_naryad := {}
  local tData

  nyear := get
  str_find := Str( kod_kart, 7 ) + Str( nyear, 4 ) + Str( onePerson, 1 )
  find ( str_find )
  if Found()
    Return func_error( 4, 'За ' + str( nyear, 4 ) + ' справка уже сформирована!' )
  endif

  tmp_select := select()

  // ПЛАТНЫЕ УСЛУГИ
  if hb_vfExists( dir_server + 'hum_p.dbf' )
    use_base( 'hum_p', 'hum_p' )
    find ( str( glob_kartotek, 7 ) )
    do while hum_p->kod_k == glob_kartotek
//      if year( hum_p->K_DATA ) == nyear // .and. ! empty( hum_p->FR_DATA )
      tData := c4tod( hum_p->FR_DATA )
      if ! empty( tData ) .and. year( tData ) == nyear
        AAdd( aCheck, { hum_p->( recno() ), PLAT, ;
        hum_p->cena, ;
        iif( year( c4tod( hum_p->VZFR_DATA ) ) == nyear, hum_p->sum_voz, 0 ) } )
      endif
      hum_p->( dbSkip() )
    enddo
    hum_p->( dbCloseArea() )
  endif

  // ОРТОПЕДИЯ
  if hb_vfExists( dir_server + 'hum_ort.dbf' ) .and. hb_vfExists( dir_server + 'hum_oro.dbf' )
    use_base( 'hum_ort' )
    find ( str( glob_kartotek, 7 ) )
    do while HUMAN->kod_k == glob_kartotek
      AAdd( zakaz_naryad, HUMAN->( recno() ) )
      HUMAN->( dbSkip() )
    enddo
    HUMAN->( dbCloseArea() )

    if len( zakaz_naryad ) > 0
      use_base( 'hum_oro' ) //, 'hum_oro' )
      for i := 1 to len( zakaz_naryad )
        find ( str( zakaz_naryad[ i ], 7 ) )
        do while HO->kod == zakaz_naryad[ i ]
          tData := c4tod( HO->FR_DATA )
//          if year( c4tod( HO->PDATE ) ) == nyear
          if year( tData ) == nyear
            AAdd( aCheck, { HO->( recno() ), ORTO, ;
              iif( HO->cena_opl > 0, HO->cena_opl, 0 ), ;
              iif( ( HO->cena_opl < 0 ) .and. ( year( c4tod( HO->VZFR_DATA ) ) == nyear ), Abs( HO->cena_opl ), 0 ) } )
          endif
          HO->( dbSkip() )
        enddo
      next
      HO->( dbCloseArea() )
    endif
  endif

  // Касса МО
  if hb_vfExists( dir_server + 'kas_pl.dbf' )
    use_base( 'kas_pl', 'KASSA' )
    find ( str( glob_kartotek, 7 ) )
    do while KASSA->kod_k == glob_kartotek
      tData := c4tod( KASSA->FR_DATA )
//      if year( KASSA->K_DATA ) == nyear
      if year( tData ) == nyear
        AAdd( aCheck, { KASSA->( recno() ), KASSA_MO, ;
          iif( KASSA->cena > 0, KASSA->cena, 0 ), ;
          iif( ( KASSA->cena < 0 ) .and. ( year( c4tod( KASSA->VZFR_DATA ) ) == nyear ), Abs( KASSA->cena ), 0 ) } )
      endif
      KASSA->( dbSkip() )
    enddo
    KASSA->( dbCloseArea() )
  endif

  select( tmp_select )

  return .t.

// 13.01.25
function input_spravka_fns()

  Local str_sem
  Local buf := SaveScreen(), str_1, tmp_color := SetColor(), ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    mINN := space( 12 ), ;
    mSumma := 0.0, mSum1 := 0.0, mSum2 := 0.0, ;
    j := 0, i, mkod
  local nYear := 2024 // отчетный год
//  local arr_m

  local aFIOPlat, mDOB, mVID, mSerNomer, mKogda
  local predst := '', predst_doc := '', pred_ruk := 0
  local org := hb_main_curOrg
  local aFIOPredst

  Private aCheck := {}
  private mm_plat := { { 'он же ', 1 }, ;
    { 'другой', 0 } }, ;
    m1P_ATTR := 1, mP_ATTR  // вид плательщика
  private mKod_payer := 0   // код плательщика

//  If ( arr_m := input_year() ) == NIL
//    Return Nil
//  Endif
//  if arr_m[ 1 ] != 2024
//    hb_Alert( 'Справки для ФНС составляются на 2024 год' )
//    return nil
//  endif

  mP_ATTR := inieditspr( A__MENUVERT, mm_plat, m1p_attr )
  _fns_nastr( 0 ) // проверим сущетствование настроек
  _fns_nastr( 1 ) // прочитаем сущетствующие настроеки
  pred_ruk := fns_PODPISANT
  if pred_ruk == 0
    predst := alltrim( fns_PREDST )
    predst_doc := alltrim( fns_PREDST_DOC )
  else
    predst := upper( alltrim( org:ruk_fio() ) )
  endif
  if At( '.', predst ) > 0
    return func_error( 4, 'В ФИО  ' + iif( pred_ruk == 0, 'представаителя', 'руководителя' ) + ' МО не должно быть знаков препинания!' )
  endif
  aFIOPredst := razbor_str_fio( predst )
  if Empty( aFIOPredst[ 1 ] ) .or. Empty( aFIOPredst[ 2 ] ) .or. Empty( aFIOPredst[ 3 ] )
    return func_error( 4, 'ФИО ' + iif( pred_ruk == 0, 'представаителя', 'руководителя' ) + ' МО должно быть полным (пример: Иванов Иван Иванович)!' )
  endif

  If polikl1_kart() > 0
    R_Use( dir_server + 'kartote_', , 'KART_' )
    goto ( glob_kartotek )
    R_Use( dir_server + 'kartotek', , 'KART' )
    goto ( glob_kartotek )

    if ! kart->( eof() )
      aFIOPlat := razbor_str_fio( kart->fio )
      mDOB      := kart->date_r
//      mVID      := soot_doc( kart_->vid_ud )
      mVID      := kart_->vid_ud
      mSerNomer := alltrim( kart_->ser_ud ) + iif( empty( kart_->ser_ud ), '', ' ' ) + alltrim( kart_->nom_ud )
      mKogda    := kart_->kogdavyd
    endif

    use_base( 'link_fns', 'link_fns' )
    use_base( 'reg_fns', 'fns' )
//    if ! exist_spravka( arr_m[ 1 ], glob_kartotek, 1 )
    if ! exist_spravka( nYear, glob_kartotek, 1 )
      dbCloseAll()
      return nil
    endif
    _fns_nastr( 1 ) // прочитаем последний номер справки
    mSumma := 0
    for i := 1 to len( aCheck )
      mSumma := mSumma + aCheck[ i, 3 ] - aCheck[ i, 4 ]
    next
    if mSumma <= 0
      hb_Alert( 'Сумма оплат за год равна или меньше нуля' )
      return nil
    endif

    str_sem := 'Справка ФНС человека ' + lstr( glob_kartotek )
    If ! g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif

    SetColor( cDataCGet )
//    str_1 := 'за ' + str( arr_m[ 1 ], 4 ) + ' для ' + aFIOPlat[ 1 ] + ' ' + aFIOPlat[ 2 ] + ' ' + aFIOPlat[ 3 ]
    str_1 := 'за ' + str( nYear, 4 ) + ' для ' + aFIOPlat[ 1 ] + ' ' + aFIOPlat[ 2 ] + ' ' + aFIOPlat[ 3 ]
    j := 10
    Private gl_area := { j, 0, MaxRow() -1, MaxCol(), 0 }
    box_shadow( j, 0, MaxRow() -1, MaxCol(), color1, 'Справка для ФНС ' + str_1, color8 )
    status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запись' )
    //
    Do While .t.
      j := 11
      @ j, 1 Clear To MaxRow() - 2, MaxCol() - 1
//      @ ++j, 2 Say 'Отчетный год ' + str( arr_m[ 1 ], 4 )
      @ ++j, 2 Say 'ИНН пациента' Get mINN pict '999999999999' valid {| g | check_input_INN( g ) }

      @ j, 37 say 'Плательщик:' Get mP_ATTR ;
        reader {| x| menu_reader( x, mm_plat, A__MENUVERT, , , .f. ) } ;
        valid {| g | check_payer( g ) }

      ++j
      @ ++j, 2 Say 'Оплаченная сумма по чекам за минусом возвратов - ' + str( mSumma, 10, 2 )
      @ ++j, 2 Say 'Сумма 1 -' Get mSum1 pict '999999999.99'
      @ j, 37 Say 'Сумма 2 -' Get mSum2 pict '999999999.99'
      ++j
      @ ++j, 2 Say 'Сумма 1 - указывается общая сумма произведенных расходов на оказанные'
      @ ++j, 2 Say ' медицинские услуги (за исключением расходов по дорогостоящим видам лечения)'
      ++j
      @ ++j, 2 Say 'Сумма 2 - общая сумма произведенных расходов по дорогостоящим видам'
      @ ++j, 2 Say 'лечения в соответствии с перечнем медицинских услуг, утвержденным'
      @ ++j, 2 Say 'Правительством Российской Федерации, постановление № 458 от 08.04.2020 г.'
      count_edit := myread(, @pos_read, ++k_read )
      If LastKey() != K_ESC
        If f_esc_enter( 1 )
          If mSum1 + mSum2 == 0.0
            func_error( 4, 'Нет распределения суммы расходов!' )
            Loop
          Endif
          If mSum1 + mSum2 != mSumma
            func_error( 4, 'Распределения суммы не равна сумме расходов по чекам!' )
            Loop
          Endif
          If mSumma == 0.0
            func_error( 4, 'Сумма расходов по чекам равна нулю!' )
            Loop
          Endif
          if len( aCheck ) == 0
            func_error( 4, 'Отсутствуют чеки оплаты!' )
            Loop
          Endif
          if empty( mDOB )
            func_error( 4, 'У налогоплательщика отсутствует дата рождения!' )
            Loop
          Endif
          if empty( mINN )
            if empty( mSerNomer )
              func_error( 4, 'У налогоплательщика отсутствует серия и номер документа!' )
              Loop
            endif
            if empty( mKogda )
              func_error( 4, 'У налогоплательщика отсутствует дата выдачи документа!' )
              Loop
            endif
          endif
          mywait()
          select fns
          add1rec( 7 )
          mkod := RecNo()
          fns->kod := mkod
          fns->kod_k := glob_kartotek
          fns->date := date()
          fns->nyear := nYear   //  arr_m[ 1 ]
          fns->num_s := ++fns_N_SPR_FNS
          fns->version := 0
          fns->inn := mINN
          fns->plat_fio := kart->fio
          fns->plat_dob := mDOB
          fns->viddoc := mVID
          fns->ser_num := mSerNomer
          fns->datevyd := mKogda

          fns->attribut := m1P_ATTR  // вид плательщика
          if m1P_ATTR == 0  // плательщик и пациент разные лица
            fns->kod_payer := mKod_payer
          else              // плательщик и пациент одно лицо
            fns->kod_payer := 0
          endif

          fns->sum1 := mSum1
          fns->sum2 := mSum2
          fns->pred_ruk := pred_ruk
          if pred_ruk == 0
            fns->predst := predst
            fns->pred_doc := predst_doc
          else
            fns->predst := predst
            fns->pred_doc := ''
          endif
          g_rlock( forever )
          select link_fns
          for i := 1 to len( aCheck )
            add1rec( 7 )
            link_fns->KOD_SPR := mkod
            link_fns->TYPE := aCheck[ i, 2 ]
            link_fns->KOD_REC := aCheck[ i, 1 ]
            link_fns->SUM_OPL := aCheck[ i, 3 ]
            link_fns->SUM_VOZ := aCheck[ i, 4 ]
            g_rlock( forever )
          next
          G_Use( dir_server + 'reg_fns_nastr', , 'NASTR_FNS' )
          G_RLock( forever )
          NASTR_FNS->N_SPR_FNS := fns_N_SPR_FNS
//          Unlock
          write_work_oper( glob_task, OPER_LIST, 1, 1, count_edit )
          exit
        Endif
      elseif LastKey() == K_ESC
        exit
      endif
    enddo
    SetColor( tmp_color )
    RestScreen( buf )
    g_sunlock( str_sem )
    dbCloseAll()
  endif
  
  return nil

// 25.08.24
// вызывается в 'Платные услуги(Ортопедия\Касса)/Информация/Справки для ФНС'
Function inf_fns( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { ;
      'Ввод данных', ;
      'Список справок для ФНС', ;
      'Составление реестров для ФНС', ;
      'Просмотр реестров для ФНС' ;
      }
    mas_msg := { ;
      'Формирование и просмотр выданных справок по пациенту', ;
      'Просмотр список сформированных справок для ФНС', ;
      'Составление реестров справок о расходах для выгрузки в ФНС', ;
      'Просмотр реестров справок о расходах для выгрузки в ФНС' ;
      }
    mas_fun := { ;
      'inf_fns(11)', ;
      'inf_fns(12)', ;
      'inf_fns(13)', ;
      'inf_fns(14)' ;
      }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    input_spravka_fns()
  case k == 12
    reestr_spravka_fns()
  Case k == 13
    reestr_xml_fns()
  Case k == 14
    view_list_xml_fns()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 22.08.24
function _fns_nastr( k )

  Static file_mem := 'reg_fns_nastr'
  Local mm_tmp

  private mPodpis, m1Podpis := 0
  private mm_danet := { { 'да', 1 }, { 'нет', 0 } }

  if type( 'fns_N_SPR_FNS' ) == 'N'
    // второй раз зашли
  else
    Public fns_N_SPR_FNS   := 0, ;
          fns_N_SPR_FILE   := 0, ;
          fns_PODPISANT    := 0, ;
          fns_PREDST       := space( 50 ), ;
          fns_PREDST_DOC   := space( 50 ), ;
          fns_ID_POL       := space( 4 ), ;
          fns_ID_END       := space( 4 )
  endif

  if k == 0 // инициализация файла и переменных
    mm_tmp := { ;  // справочник настроек обмена с ФНС
      { 'N_SPR_FNS',  'N',   7,  0 }, ; // последний номер справки для ФНС
      { 'N_FILE_UP',  'N',   7,  0 }, ; // последний номер файла выгрузки для ФНС
      { 'PODPIS',     'N',   1,  0 }, ; // подписант руководитель?; 0-нет, 1-да
      { 'PREDST',     'C',  50,  0 }, ; // представитель МО
      { 'PRED_DOC',   'C',  50,  0 }, ; // документ по которому действует представитель
      { 'ID_POL',     'C',   4,  0 }, ; // идентификатор получателя, кому направляется файл выгрузок
      { 'ID_END',     'C',   4,  0 } ; // идентификатор конечного получателя, для которого предназначен файл выгрузок
   }
    reconstruct( dir_server + file_mem, mm_tmp, , , .t. )
    G_Use( dir_server + file_mem, , 'NASTR_FNS' )
    if lastrec() == 0
      AddRecN()
      nastr_fns->N_SPR_FNS := fns_N_SPR_FNS
      nastr_fns->N_FILE_UP := fns_N_SPR_FILE
    else
      G_RLock( forever )
    endif
    if empty( nastr_fns->ID_POL)
      nastr_fns->ID_POL := fns_ID_POL
    endif
    if empty( nastr_fns->ID_END)
      nastr_fns->ID_END := fns_ID_END
    endif
    NASTR_FNS->( dbCloseAre() ) //Use
  elseif k == 1
    R_Use( dir_server + file_mem, , 'NASTR_FNS')
    fns_N_SPR_FNS  := nastr_fns->N_SPR_FNS
    fns_N_SPR_FILE  := nastr_fns->N_FILE_UP
    fns_PODPISANT  := nastr_fns->PODPIS
    fns_PREDST      := nastr_fns->PREDST
    fns_PREDST_DOC      := nastr_fns->PRED_DOC
    fns_ID_POL := nastr_fns->ID_POL
    fns_ID_END := nastr_fns->ID_END
    NASTR_FNS->( dbCloseAre() ) //Use
  endif
  return NIL

// 08.08.24
function soot_doc( nVid )

  local ret, aHash

  aHash := hb_hash()
  hb_hSet(aHash, 14, 21 )
  hb_hSet(aHash, 3, 03 )
  hb_hSet(aHash, 7, 07 )
  hb_hSet(aHash, 9, 10 )
  hb_hSet(aHash, 11, 12 )
  hb_hSet(aHash, 12, 13 )
  hb_hSet(aHash, 13, 14 )
  hb_hSet(aHash, 23, 15 )
  hb_hSet(aHash, 10, 19 )
  hb_hSet(aHash, 24, 23 )
  hb_hSet(aHash, 4, 24 )
  hb_hSet(aHash, 17, 27 )
  hb_hSet(aHash, 18, 91 )

  if hb_hHaskey( aHash, nVid )
    ret := aHash[ nVid ]
  else
    ret := 91
  endif

//  08	Временное удостоверение, выданное взамен военного билета
//  hb_hSet(aHash, , 08 )
//  11	Свидетельство о рассмотрении ходатайства о признании лица беженцем на территории Российской Федерации по существу
//  hb_hSet(aHash, , 11 )

  return ret

// 08.08.24
function razbor_str_fio( mfio )

  local k := 0, i, s := '', s1 := '', aFIO := { '', '', '' }

  mfio := alltrim( mfio )
  For i := 1 To NumToken( mfio, ' ' )
    s1 := AllTrim( Token( mfio, ' ', i ) )
    If ! Empty( s1 )
      ++k
      If k < 3
        aFIO[ k ] := s1
      Else
        s += s1 + ' '
      Endif
    Endif
  Next
  aFIO[ 3 ] := AllTrim( s )
  return aFIO

// 09.08.24
function short_FIO( mfio )

  local aFIO := razbor_str_fio( mfio )

  return 	aFIO[ 1 ] + ' ' + Left( aFIO[2], 1 ) + '.' + if( Empty( aFIO[3] ), '', Left( aFIO[3], 1 ) + '.' )