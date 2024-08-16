#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

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

// 11.08.24
Function serv_spravka_fns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2

  Do Case
//  Case nKey == K_F3
    // view_p_kvit(K_F3)
//  Case nKey == K_F4
    // view_p_kvit(K_F4)
  Case nKey == K_F9
    if fns->kod_xml == -1 .or. fns->kod_xml == 0
      print_spravka_fns()
    else
      func_error( 4, 'Справка включена в файл обмена с ФНС!' )
    endif
//  Case nKey == K_INS
  Case nKey == K_DEL
    anul_spravka_fns()
//  Case nKey == K_CTRL_RET
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 11.08.24
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
  hb_HSet( hSpravka, 'attribut', fns->attribut )
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

  if DesignSpravkaPDF( cFileToSave, hSpravka )
    view_file_in_Viewer( cFileToSave )
    G_RLock( forever )
    fns->kod_xml := -1
    Unlock
  endif
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

// 11.08.24
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
          fns->num_s := ++fns_N_SPR_FNS
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
  
// 13.08.24
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
    reestr_spravka_fns()
  Case k == 13
    reestr_xml_fns()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 15.08.24
function _fns_nastr( k )

  Static file_mem := 'reg_fns_nastr'
  Local mm_tmp

  private mPodpis, m1Podpis := 0

//          m1sertif   := p2->sertif
//  msertif   := inieditspr_bay( A__MENUVERT, mm_danet, m1sertif )
//@ ++r, 2 say 'Наличие сертификата' get mSERTIF ;
//  reader { | x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
//        p2->sertif   := m1sertif


  if type( 'fns_N_SPR_FNS' ) == 'N'
    // второй раз зашли
  else
    Public fns_N_SPR_FNS   := 0, ;
          fns_N_SPR_FILE   := 0, ;
          fns_CATALOG_FNS  := '', ;
          fns_ID_POL       := space( 4 ), ;
          fns_ID_END       := space( 4 )
  endif

  if k == 0 // инициализация файла и переменных
    mm_tmp := { ;  // справочник настроек обмена с ФНС
      {'N_SPR_FNS',  'N',   7,  0}, ; // последний номер справки для ФНС
      {'N_FILE_UP',  'N',   7,  0}, ; // последний номер файла выгрузки для ФНС
      {'CATALOG',    'C', 254,  0}, ; // каталог записи сформированных выгрузок
      {'ID_POL',     'C',   4,  0}, ; // идентификатор получателя, кому направляется файл выгрузок
      {'ID_END',     'C',   4,  0} ; // идентификатор конечного получателя, для которого предназначен файл выгрузок
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
    if empty( nastr_fns->Catalog)
      nastr_fns->Catalog := fns_CATALOG_FNS
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
    fns_CATALOG_FNS := nastr_fns->Catalog
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
