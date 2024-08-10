#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.08.24
function list_spravka_fns()

  Local mtitle
  Local buf := SaveScreen()

  use_base( 'reg_fns', 'fns' )

  mtitle := 'Сформированные справки для ФНС'
  alpha_browse( 5, 0, MaxRow() - 2, 79, 'defColumn_Spravka_FNS', color0, mtitle, 'BG+/GR', ;
    .f., .t., , , 'serv_spravka_fns', , ;
    { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

  dbCloseAll()
  RestScreen( buf )

  return nil

// 10.08.24
Function defcolumn_spravka_fns( oBrow )

  Local oColumn, s
  Local blk := {|| iif( Empty( fns->kod_xml ), { 5, 6 }, { 3, 4 } ) }

  oColumn := TBColumnNew( ' Год ', {|| str( fns->nyear, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Номер ', {|| str( fns->num_s, 7 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Вер.', {|| str( fns->version, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'ФИО', {|| substr( short_FIO( fns->plat_fio ), 1, 15 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 1', {|| str( fns->sum1, 9, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 2', {|| str( fns->sum2, 9, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  Дата', {|| date_8( fns->date ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Статус', {|| iif( fns->kod_xml <= 0, iif( fns->kod_xml == 0, 'не обработано', 'принтер' ), xml->fname  ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  s := '<Esc> выход <F8> возврат <F9> печать <Del> аннулирование'
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<Del>', '<Ctrl+Enter>', '<F3>', '<F4>', '<F8>', '<F9>', '<F10>' }, 'R/W' )

  Return Nil

// 09.08.24
Function serv_spravka_fns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2

  Do Case
//  Case nKey == K_F3
    // view_p_kvit(K_F3)
//  Case nKey == K_F4
    // view_p_kvit(K_F4)
  Case nKey == K_F9
    print_spravka_fns()
//  Case nKey == K_INS
  Case nKey == K_DEL
    anul_spravka_fns()
//  Case nKey == K_CTRL_RET
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 10.08.24
function print_spravka_fns()

  local hSpravka, pos, aFIO, cFileToSave

  pos := hb_At( '/', hb_main_curOrg:INN() )
  aFIO := razbor_str_fio( fns->plat_fio )

  cFileToSave := cur_dir() + 'spravkaFNS.pdf'

  hSpravka := hb_Hash()
  if pos == 0
    hb_HSet( hSpravka, 'inn', hb_main_curOrg:INN() )
    hb_HSet( hSpravka, 'kpp', '' )
  else
    hb_HSet( hSpravka, 'inn', substr( hb_main_curOrg:INN(), 1, pos - 1) )
    hb_HSet( hSpravka, 'kpp', substr( hb_main_curOrg:INN(), pos + 1 ) )
  endif
  hb_HSet( hSpravka, 'num_spr', fns->num_s )
  hb_HSet( hSpravka, 'nYear', fns->nyear )
  hb_HSet( hSpravka, 'cor', fns->version )
  hb_HSet( hSpravka, 'name', hb_main_curOrg:Name() )
  hb_HSet( hSpravka, 'full_name', hb_main_curOrg:Name() )
  hb_HSet( hSpravka, 'fam', aFIO[ 1 ] )
  hb_HSet( hSpravka, 'im', aFIO[ 2 ] )
  hb_HSet( hSpravka, 'ot', aFIO[ 3 ] )
  hb_HSet( hSpravka, 'inn_plat', fns->INN )
  hb_HSet( hSpravka, 'dob', fns->plat_dob )
  hb_HSet( hSpravka, 'vid_d', fns->viddoc )
  hb_HSet( hSpravka, 'ser', fns->ser_num )
//  hb_HSet( hSpravka, 'nomer', '123456' )
  hb_HSet( hSpravka, 'dVydach', fns->datevyd )
  hb_HSet( hSpravka, 'odnolico', fns->attribut )
  hb_HSet( hSpravka, 'sum1', fns->sum1 )
  hb_HSet( hSpravka, 'sum2', fns->sum2 )
  hb_HSet( hSpravka, 'fioSost', fns->exec_fio )
  hb_HSet( hSpravka, 'dSost', fns->Date )
  hb_HSet( hSpravka, 'kolStr', 1 )
//  hb_HSet( hSpravka, 'famPacient', 'Кукуев' )
//  hb_HSet( hSpravka, 'imPacient', 'Ростислав' )
//  hb_HSet( hSpravka, 'otPacient', 'Илларионович' )
//  hb_HSet( hSpravka, 'dobPacient', 0d19990912 )
//  hb_HSet( hSpravka, 'innPacient', '344408677499' )
//  hb_HSet( hSpravka, 'vid_d_pacient', 21 )
//  hb_HSet( hSpravka, 'ser_pacient', '10 07' )
//  hb_HSet( hSpravka, 'nomer_pacient', '654321' )
//  hb_HSet( hSpravka, 'dVydachPacient', 0d20200507 )
//  hb_HSet( hSpravka, 'annul', 1 ) // справка на аннулирование, 1 - да, 0 - нет

//  if DesignSpravkaPDF( cFileToSave, hSpravka )
    // запомним что печатали
//  endif
  return nil

// 10.08.24
function anul_spravka_fns()

  local rec := fns->( recno() ), str_find
  local mkod, mPlat, mNyear, mNspravka, mVersion, mAttribut
  local mInn, mPlat_fio, mPlat_dob, mPlat_vid, mPlat_ser_num, mPlat_date_vyd, mSum1, mSum2

  if ! fns->( eof() )
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
    find ( str_find )
    if Found()
      fns->( dbGoto( rec ) )
      func_error( 4, 'Для справки уже сформирована аннулирующая запись!' )
      return nil
    endif
    select fns
    add1rec( 7 )
    mkod := RecNo()
    fns->kod := mkod
    fns->kod_k := mPlat
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
    fns->EXECUTOR := hb_user_curUser:ID()
    fns->exec_fio := hb_user_curUser:FIO()
    fns->date := date()
    g_rlock( forever )
  endif
  return nil

// 06.08.24 проверка существования справки за конкретный год
function exist_spravka( get, kod_kart, onePerson )
  // get - объект Get системы
  // kod_kart - код пациента по картотеке
  // onePerson - налогоплательщик и пациент одно лицо ( 1- да, 0 - нет)

  local nyear, str_find, tmp_select

//  nyear := get:original // получим поле ввода
  nyear := get
  str_find := Str( kod_kart, 7 ) + Str( nyear, 4 ) + Str( onePerson, 1 )
  find ( str_find )
  if Found()
    Return func_error( 4, 'За ' + str( nyear, 4 ) + ' справка уже сформирована!' )
  endif

  tmp_select := select()

  use_base( 'hum_p', 'hum_p' )
  find ( str( glob_kartotek, 7 ) )
  do while hum_p->kod_k == glob_kartotek
    if year( hum_p->K_DATA ) == nyear
      AAdd( aCheck, { hum_p->( recno() ), 1, hum_p->cena, hum_p->sum_voz } )
    endif
    hum_p->( dbSkip() )
  enddo
  hum_p->( dbCloseArea() )
  select( tmp_select )

  return .t.

// 09.08.24
function input_spravka_fns()

  Local str_sem
  Local buf := SaveScreen(), str_1, tmp_color := SetColor(), ;
    arr_m, pos_read := 0, k_read := 0, count_edit := 0, ;
    mINN := space( 12 ), ;
    mSumma := 0.0, mSum1 := 0.0, mSum2 := 0.0, ;
    j := 0, i, mkod

  local aFIOPlat, mDOB, mVID, mSerNomer, mKogda
  local aFIOExecutor := razbor_str_fio( hb_user_curUser:FIO() )

  Private aCheck := {}

  If ( arr_m := input_year() ) == NIL
    Return Nil
  Endif

  _fns_nastr( 0 )
  If polikl1_kart() > 0
    R_Use( dir_server + 'kartote_', , 'KART_' )
    goto ( glob_kartotek )
    R_Use( dir_server + 'kartotek', , 'KART' )
    goto ( glob_kartotek )

    if ! kart->( eof() )
      aFIOPlat := razbor_str_fio( kart->fio )
      mDOB      := kart->date_r
      mVID      := soot_doc( kart_->vid_ud )
      mSerNomer := alltrim( kart_->ser_ud ) + iif( empty( kart_->ser_ud ), '', ' ' ) + alltrim( kart_->nom_ud )
      mKogda    := kart_->kogdavyd
    endif

    use_base( 'link_fns', 'link_fns' )
    use_base( 'reg_fns', 'fns' )
    if ! exist_spravka( arr_m[ 1 ], glob_kartotek, 1 )
      dbCloseAll()
      return nil
    endif
    _fns_nastr( 1 ) // прочитаем последний номер справки
    mSumma := 0
    for i := 1 to len( aCheck )
      mSumma := mSumma + aCheck[ i, 3 ] - aCheck[ i, 4 ]
    next
    str_sem := 'Справка ФНС человека ' + lstr( glob_kartotek )
    If ! g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif

    SetColor( cDataCGet )
    str_1 := 'за ' + str( arr_m[ 1 ], 4 ) + ' для ' + aFIOPlat[ 1 ] + ' ' + aFIOPlat[ 2 ] + ' ' + aFIOPlat[ 3 ]
    j := 11
    Private gl_area := { j, 0, MaxRow() -1, MaxCol(), 0 }
    box_shadow( j, 0, MaxRow() -1, MaxCol(), color1, 'Справка для ФНС ' + str_1, color8 )
    status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запись' )
    //
    Do While .t.
      j := 12
      @ j, 1 Clear To MaxRow() - 2, MaxCol() - 1
      @ ++j, 2 Say 'Отчетный год ' + str( arr_m[ 1 ], 4)
      @ j, 37 Say 'ИНН плательщика' Get mINN pict '999999999999'
      @ ++j, 2 Say 'Оплаченная сумма по чекам за минусом возвратов - ' + str( mSumma, 10, 2 )
      @ ++j, 2 Say 'Сумма 1 -' Get mSum1 pict '999999999.99'
      @ j, 37 Say 'Сумма 2 -' Get mSum2 pict '999999999.99'
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
          if len( aFIOExecutor ) < 3
            func_error( 4, 'У исполнителя отсутствует отчество!' )
            Loop
          endif
          mywait()
          select fns
          add1rec( 7 )
          mkod := RecNo()
          fns->kod := mkod
          fns->kod_k := glob_kartotek
          fns->nyear := arr_m[ 1 ]
          fns->num_s := ++pp_N_SPR_FNS
          fns->version := 0
          fns->inn := mINN
          fns->plat_fio := kart->fio
          fns->plat_dob := mDOB
          fns->viddoc := mVID
          fns->ser_num := mSerNomer
          fns->datevyd := mKogda

          fns->attribut := 1  // плательщик, пациент одно лицо

          fns->sum1 := mSum1
          fns->sum2 := mSum2
          fns->EXECUTOR := hb_user_curUser:ID()
          fns->exec_fio := hb_user_curUser:FIO()
          fns->date := date()
          g_rlock( forever )
          select link_fns
          for i := 1 to len( aCheck )
            add1rec( 7 )
            link_fns->KOD_SPR := mkod
            link_fns->TYPE := aCheck[ i, 2 ]
            link_fns->KOD_REC := aCheck[ i, 1 ]
            g_rlock( forever )
          next
          G_Use( dir_server + 'reg_fns_nastr', , 'NASTR_FNS' )
          G_RLock(forever)
          NASTR_FNS->N_SPR_FNS := pp_N_SPR_FNS
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

// 03.08.24
Function spravka_fns()

  Local buf, str_sem, str_find, muslovie, mtitle
  Local arr_blk

  Private fl_found

  If polikl1_kart() > 0

    str_sem := 'Справка ФНС человека ' + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif
    buf := SaveScreen()

    str_find := Str( glob_kartotek, 7 )
    muslovie := 'fns->kod_k == glob_kartotek'
    // R_Use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
    // use_base( 'hum_p', 'HUMAN' )
    use_base( 'xml_fns', 'xml' )
    use_base( 'reg_fns', 'fns' )
    Set Relation To kod_xml into xml
    find ( str_find )
    fl_found := Found()

    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find, -1 ) }, ;
      {| n | skippointer( n, muslovie ) }, ;
      str_find, muslovie ;
      }

    If ! fl_found
      Keyboard Chr( K_INS )
    Endif
    mtitle := 'Справки для ФНС: ' + glob_k_fio
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, 'defColumnSpravkaFNS', color0, mtitle, 'BG+/GR', ;
      .f., .t., arr_blk, , 'operspravkafns', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

    dbCloseAll()
    RestScreen( buf )
    g_sunlock( str_sem )
  Endif

  Return Nil

// 03.08.24
Function defcolumnspravkafns( oBrow )

  Local oColumn, s
  Local blk := {|| iif( Empty( fns->kod_xml ), { 5, 6 }, { 3, 4 } ) } // iif( human->cena > 0, { 1, 2 }, { 3, 4 } ) ) }
  Local tip_bank := { 'бн', 'МИ', 'VI', 'MC', 'БАНК' }

  oColumn := TBColumnNew( ' Год ;     ', {|| put_val( fns->nyear, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Номер ;справки', {|| put_val( fns->num_s, 7 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Коррек-;тировка', {|| put_val( fns->version, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 1;       ', {|| put_kop( fns->sum1, 12 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 2;       ', {|| put_kop( fns->sum2, 12 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Дата;    ', {|| date_8( fns->date ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Статус;      ', {|| iif( fns->kod_xml <= 0, iif( fns->kod_xml == 0, 'не обработано', 'принтер' ), xml->fname  ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  // If is_task( X_KASSA )
  // @ MaxRow() -1, 0 Say PadC( '<Esc>выход <Enter>редактирование <Ins>добавление <Del>удаление <F8>возврат', 80 ) Color 'N/W'
  // s := '<Ctrl+Enter>ввод услуг <F9>договор <F3>квитанции <F4>просмотр чеков <F10>печать чека'
  // Else
  // @ MaxRow() -1, 0 Say PadC( '<Esc> выход <Enter> редактирование <Ins> добавление <Del> удаление', 80 ) Color 'N/W'
  // s := '<Ctrl+Enter> ввод услуг <F8> возврат <F9> договор <F10> печать чека'
  // Endif
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<Del>', '<Ctrl+Enter>', '<F3>', '<F4>', '<F8>', '<F9>', '<F10>' }, 'R/W' )

  Return Nil

// 03.08.24
Function operspravkafns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, ;
    ln_chek := 0, t_hum_rec := 0, ;
    tip_kart := 2 //, ;
//    err_close := 'Лист учета ЗАКРЫТ. Доступ разрешён только администратору системы!'
  Private ldate_voz, lsum_voz, lfr_data, lfr_time

  Do Case
  Case nKey == K_F3
    // view_p_kvit(K_F3)
  Case nKey == K_F4
    // view_p_kvit(K_F4)
  Case nKey == K_F9
  Case nKey == K_INS  // .or. (nKey == K_ENTER .and. human->kod_k > 0)
    // if nKey == K_ENTER
    // func_error( 4, err_close )
    // return flag
    // endif
    If nKey == K_INS .and. ! fl_found
      ColorWin( 7, 0, 7, 79, 'N/N', 'W+/N' )
      ColorWin( 7, 0, 7, 79, 'N/N', 'BG+/B' )
      ColorWin( 7, 0, 7, 79, 'N/N', 'GR+/R' )
    Endif
    // rec := recno()
    flag := input_spr_fns( nKey )
  Case nKey == K_DEL
  Case nKey == K_CTRL_RET
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 05.08.24
function collect_pay( nYear )

  local tmp_sel := select()

  hb_alert( 'Собираем чеки' )
  use_base( 'hum_p', 'hum_p' )
  find ( str( glob_kartotek, 7 ) )
  do while hum_p->kod_k == glob_kartotek
    if year( hum_p->K_DATA ) == nYear
      mSumma += hum_p->cena
      AAdd( aCheck, { hum_p->( recno() ), 1, hum_p->cena, hum_p->sum_voz } )
//  KOD_K
    endif
    hum_p->( dbSkip() )
  enddo
  hum_p->( dbCloseArea() )

  @ nStrSum, 22 Say str( mSumma, 10, 2 )
  @ nStrSum, 54 Say str( mSummaVozvrat, 10, 2 )
  select( tmp_sel )
  return nil
  
// 05.08.24
Function input_spr_fns( nKey )

  Local buf := SaveScreen(), tmp_color := SetColor(), str_1, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    mYear := year( date() ), mINN := space( 12 ), ;
    mSum1 := 0.0, mSum2 := 0, ;
    ret := -1, j := 0

  Private r1 := 11
  Private aCheck := {}, ;
    mncheck := 'Запуск', m1ncheck := 0, ;
    mSumma := 0.0, mSummaVozvrat := 0.0, ;
    nStrSum, ;
    mplat_fio := Space( 40 ), mplat_inn := Space( 12 ), ;
    mplat_adres := Space( 50 ), ; // адрес плательщика
    mplat_pasport := Space( 15 ), ;  // документ плательщика
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := CToD( '' ) // кем и когда выдан паспорт ПЛАТЕЛЬЩИКА

  If mem_plsoput == 2
    --r1
  Endif
  mywait()
    
  If nKey == K_ENTER
  Endif
//  r_use( dir_server + 'hum_plat', dir_server + 'hum_plat', 'KPLAT' )
//  find ( Str( human->( RecNo() ), 7 ) )
//  If Found()
//    mplat_adres   := KPLAT->ADRES
//    mplat_pasport := KPLAT->PASPORT
//    m1kemvyd  := Kplat->kemvyd   // кем выдан документ ПЛАТЕЛЬЩИКА
//    mkogdavyd := kplat->kogdavyd // когда выдан документ ПЛАТЕЛЬЩИКА
//  Endif
//  KPLAT->( dbCloseArea() )
  //
//  mtip_usl := inieditspr( A__MENUVERT, menu_kb, m1tip_usl )
//  mlpu := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', m1lpu )
//  motd := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', m1otd )
//  MKEMVYD := inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', M1KEMVYD )
//  If m1tip_usl == PU_D_SMO
//    mpr_smo := inieditspr( A__POPUPMENU, dir_server + 'p_d_smo', m1pr_smo )
//  Elseif m1tip_usl == PU_PR_VZ
//    mpr_smo := inieditspr( A__POPUPMENU, dir_server + 'p_pr_vz', m1pr_smo )
//  Endif
//  str_1 := ' справки для ФНС'
  If nKey == K_INS
    str_1 := 'добавление' // + str_1
  Else
    str_1 := 'редактирование' // + str_1
  Endif
  Private gl_area := { r1, 0, MaxRow() -1, MaxCol(), 0 }
  box_shadow( r1, 0, MaxRow() -1, MaxCol(), color1, 'Справка для ФНС - ' + str_1, color8 )
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запись' )
  //
  Do While .t.
    SetColor( cDataCGet )
    j := r1 + 1
    @ j, 1 Clear To MaxRow() -2, MaxCol() -1
    @ ++j, 2 Say 'Отчетный год' Get mYear pict '9999'  // ;
//      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c, sys_date,, X_PLATN ) } }, A__FUNCTION,,, .f. ) }
    @ j, 37 Say 'ИНН плательщика' Get mINN pict '999999999999'
    if nKey == K_INS
      @ ++j, 3 say 'Подбор чеков ...' get mncheck ;
          reader { | x | menu_reader( x, { { | | collect_pay( mYear ) } } ,A__FUNCTION, , , .f. ) }
    endif
    nStrSum := ++j
    @ j, 2 Say 'Оплаченная сумма - '  // + str( mSumma, 10, 2 )
    @ j, 37 Say 'Сумма возвратов - '  // + str( mSummaVozvrat, 10, 2 ) // ;
    @ ++j, 2 Say 'Сумма 1 -' Get mSum1 pict '999999999.99'
    @ j, 37 Say 'Сумма 1 -' Get mSum2 pict '999999999.99'
      //      reader {| x| menu_reader( x, menu_kb, A__MENUVERT,,, .f. ) } ;
//      valid {| g, o| val_tip_usl( g, o ) }
//    get1_p_kart()  // остальные Get'ы
//    If nKey == K_ENTER .and. !ver_pub_date( mk_data, .t. )
//      Keyboard Chr( K_ESC )
//    Endif
    count_edit := myread(, @pos_read, ++k_read )
    If LastKey() != K_ESC
//      err_date_diap( mn_data, 'Дата начала лечения' )
//      err_date_diap( mk_data, 'Дата окончания лечения' )
      If f_esc_enter( 1 )
//        If m1lpu == 0
//          func_error( 4, 'Не введено лечебное учреждение!' )
//          Loop
//        Endif
//        If Empty( mk_data )
//          func_error( 4, 'Не введена дата окончания лечения.' )
//          Loop
//        Endif
        mywait()
//        Select HUMAN
//        If nKey == K_INS
//          addrec( 7 )
//          human->kod_k := glob_kartotek
//          fl_found := .t.
//        Else
//          g_rlock( forever )
//        Endif
// запишем
        Unlock
//        human->( dbCommit() )
//        g_use( dir_server + 'hum_plat', dir_server + 'hum_plat', 'KPLAT' )
//        If Len( AllTrim( mplat_adres ) ) > 2 .or. Len( AllTrim( mplat_pasport ) ) > 2
//          find ( Str( human->( RecNo() ), 7 ) )
//          If !Found()
//            Append Blank
//          Else
//            g_rlock( forever )
//          Endif
//          KPLAT->kod     := human->( RecNo() )
//          KPLAT->ADRES   := mplat_adres
//          KPLAT->PASPORT := mplat_pasport
//          KPLAT->kemvyd := m1kemvyd     // кем выдан документ ПЛАТЕЛЬЩИКА
//          KPLAT->kogdavyd := mkogdavyd  // когда выдан документ ПЛАТЕЛЬЩИКА
//        Else
//          find ( Str( human->( RecNo() ), 7 ) )
//          If Found()
//            deleterec( .t. )
//          Endif
//        Endif
//        KPLAT->( dbCloseArea() )
//        Select HUMAN
        write_work_oper( glob_task, OPER_LIST, iif( nKey == K_INS, 1, 2 ), 1, count_edit )
        ret := 0
      Endif
    Endif
    If nKey == K_INS .and. ! fl_found
      ret := 1
    Endif
    Exit
  Enddo
//  Select HUMAN
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 03.08.24
Function reestr_fns()

  hb_Alert( 'Реестры ФНС' )

  Return Nil

// 03.08.24
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
      'Реестры для ФНС' ;
      }
    mas_msg := { ;
      'Формирование и просмотр выданных справок по пациенту', ;
      'Просмотр список сформированных справок для ФНС', ;
      'Просмотр списка и создание реестров для отправки в ФНС' ;
      }
    mas_fun := { ;
      'inf_fns(11)', ;
      'inf_fns(12)', ;
      'inf_fns(13)' ;
      }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    input_spravka_fns() // spravka_fns()
  case k == 12
    list_spravka_fns()
  Case k == 13
    reestr_fns()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 07.08.24
function _fns_nastr( k )

  Static file_mem := 'reg_fns_nastr'
  Local mm_tmp

  if k == 0 // инициализация файла и переменных
    mm_tmp := { ;  // справочник настроек обмена с ФНС
      {'N_SPR_FNS',  'N',   7,  0}, ; // последний номер справки для ФНС
      {'CATALOG',    'C', 254,  0} ; // каталог записи сформированных выгрузок
   }
    reconstruct( dir_server + file_mem, mm_tmp, , , .t. )
    if type( 'pp_N_SPR_FNS' ) == 'N'
      // второй раз зашли
    else
      Public pp_N_SPR_FNS    := 0, ;
            pp_CATALOG_FNS  := ''
    endif
    G_Use( dir_server + file_mem, , 'NASTR_FNS' )
    if lastrec() == 0
      AddRecN()
      nastr_fns->N_SPR_FNS := pp_N_SPR_FNS
    else
      G_RLock(forever)
    endif
    if empty( nastr_fns->Catalog)
      nastr_fns->Catalog := pp_CATALOG_FNS
    endif
    NASTR_FNS->( dbCloseAre() ) //Use
  elseif k == 1
    R_Use( dir_server + file_mem, , 'NASTR_FNS')
    pp_N_SPR_FNS  := nastr_fns->N_SPR_FNS
    pp_CATALOG_FNS := nastr_fns->Catalog
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
