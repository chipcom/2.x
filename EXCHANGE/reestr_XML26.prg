// реестры/счета с 2019 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 11.12.25
Function create1reestr26( _recno, _nyear, _nmonth, kod_smo, p_tip_reestr, aBukva )

  Local buf := SaveScreen(), i, j, pole
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  Local reg_sort

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
  Private old_kol := pkol, old_summa := psumma, p_blk := { | mkol, msum| f_blk_create1reestr19( _nyear ) }

  g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  g_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_

  dbSelectArea( 'TMP' )
  Set Relation To FIELD->kod_human into HUMAN

//  Index On Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' )  // For FIELD->kod_tmp == _recno
  Index On Upper( tmp->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' )  // For FIELD->kod_tmp == _recno

  tmp->( dbGoTop() )
  Eval( p_blk )
  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestr19', color0, ;
      'Составление реестра случаев за ' + mm_month[ _nmonth ] + Str( _nyear, 5 ) + ' года', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestr19', , ;
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
        if reg_sort == 1 
          Index On FIELD->BUKVA + Upper( human->fio ) + DToS( tmp->k_data ) to ( 'mem:tmp' ) For FIELD->plus  // For kod_tmp == _recno
        else
          Index On FIELD->BUKVA + Str( FIELD->pz, 2 ) + Str( 10000000 - FIELD->cena_1, 11, 2 ) to ( 'mem:tmp' ) For FIELD->plus   // .and. kod_tmp == _recno 
        endif
        create2reestr26( _recno, _nyear, _nmonth, reg_sort, kod_smo, p_tip_reestr, aBukva )
      Endif
    Endif
  Endif
  close_list_alias( { 'HUMAN_3', 'HUMAN_', 'HUMAN' } )
  RestScreen( buf )
  Return Nil

// 19.11.25 создание XML-файлов реестра
Function create2reestr26( _recno, _nyear, _nmonth, reg_sort, kod_smo, p_tip_reestr, aBukva )

  Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, code_reestr, mb, me, nsh
  Local i, j
  Local reserveKSG_ID_C := '' // GUID для вложенных двойных случаев
  Local arrLP
  Local controlVer
  Local lTypeLUOnkoDisp := .f.  // флаг листа учета постановки на диспансерное наблюдение онкобольных
  local dPUMPver40 := 0d20240301
  local aFilesName
  local sVersion, fl_ver
  local oXmlDoc, oXmlNode
  Local cBukva := '', cNschet := '', countBukva
  Local oXmlDocPacient, oXmlNodePacient, sVersionPacient
  local oPb

  //
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    Private &pole_diag := Space( 6 )
    Private &pole_1dispans := 0
    Private &pole_dn_dispans := CToD( '' )
  Next
  stat_msg( 'Составление реестра случаев' )
  nsh := f_mb_me_nsh( _nyear, @mb, @me )

  use_base( 'lusl' )
  use_base( 'luslc' )
  use_base( 'luslf' )
  r_use( dir_server() + 'human_im', dir_server() + 'human_im', 'IMPL' )
  r_use( dir_server() + 'human_lek_pr', dir_server() + 'human_lek_pr', 'LEK_PR' )

//  laluslf := create_name_alias( 'luslf', _nyear )
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'mo_pers', , 'P2' )
  r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2TABN' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  g_use( dir_server() + 'mo_rhum', , 'RHUM' )
  Index On Str( FIELD->REESTR, 6 ) to ( cur_dir() + 'tmp_rhum' )
  g_use( dir_server() + 'human_u_', , 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To FIELD->u_kod into MOSU

  If p_tip_reestr == 1
    r_use( dir_server() + 'kart_inv', , 'INV' )
    Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_inv' )
  Endif
  r_use( dir_server() + 'kartote2', , 'KART2' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_, To RecNo() into KART2
  r_use( dir_server() + 'mo_onkna', dir_server() + 'mo_onkna', 'ONKNA' ) // онконаправления
  r_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco', 'ONKCO' )
  r_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'ONKSL' ) // Сведения о случае лечения онкологического заболевания
  r_use( dir_server() + 'mo_onkdi', dir_server() + 'mo_onkdi', 'ONKDI' ) // Диагностический блок
  r_use( dir_server() + 'mo_onkpr', dir_server() + 'mo_onkpr', 'ONKPR' ) // Сведения об имеющихся противопоказаниях
  g_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus', 'ONKUS' )
  g_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle', 'ONKLE' )
//  g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
//  Set Order To 2 // индекс по 2-му случаю
  g_use( dir_server() + 'human_2', , 'HUMAN_2' )
//  g_use( dir_server() + 'human_', , 'HUMAN_' )
//  r_use( dir_server() + 'human', , 'HUMAN' )
  dbSelectArea( 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To FIELD->kod_k into KART
  r_use( dir_exe() + '_mo_t2_v1', , 'T21' )
  Index On FIELD->shifr to ( cur_dir() + 'tmp_t21' )

  r_use( dir_exe() + '_mo_mkb', , 'MKB_10' )
  Index On FIELD->shifr + Str( FIELD->ks, 1 ) to ( cur_dir() + '_mo_mkb' )
  g_use( dir_server() + 'mo_xml', , 'MO_XML' )
  g_use( dir_server() + 'mo_rees', , 'REES' )

  for countBukva := 1 to len( aBukva )
//    dbSelectArea( 'TMP' )
//    tmp->( dbGoTop() )
//    do while ! tmp->( Eof() )
//      if cBukva != tmp->bukva
    cBukva := aBukva[ countBukva ]
    dbSelectArea( 'REES' )
    Index On Str( FIELD->nn, nsh ) to ( cur_dir() + 'tmp_rees' ) For FIELD->nyear == _nyear .and. FIELD->nmonth == _nmonth
    fl := .f.
    For mnn := mb To me
      find ( Str( mnn, nsh ) )
      If ! Found() // нашли свободный номер
        fl := .t.
        Exit
      Endif
    Next
    If ! fl
      close_file_reestr26()
      Return func_error( 10, 'Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!' )
    Endif
    Index On Str( FIELD->nschet, 6 ) to ( cur_dir() + 'tmp_rees' ) For FIELD->nyear == _nyear
    If ! Eof()
      rees->( dbGoBottom() )
      mnschet := rees->nschet + 1
    Endif
    If ! Between( mnschet, mem_beg_rees, mem_end_rees )
      fl := .f.
      For mnschet := mem_beg_rees To mem_end_rees
        find ( Str( mnschet, 6 ) )
        If ! Found() // нашли свободный номер
          fl := .t.
          Exit
        Endif
      Next
      If ! fl
        close_file_reestr26()
        Return func_error( 10, 'Не удалось найти свободный номер реестра. Проверьте настройки!' )
      Endif
    Endif
    Set Index To

    addrecn()
    rees->KOD    := RecNo()
    rees->NSCHET := mnschet
    rees->DSCHET := Date()
    rees->NYEAR  := _NYEAR
    rees->NMONTH := _NMONTH
    rees->NN     := mnn
//    aFilesName := name_reestr_XML_2025( p_tip_reestr, _NYEAR, _NMONTH, mnschet, 5, kod_smo )
    aFilesName := name_reestr_XML( p_tip_reestr, _NYEAR, _NMONTH, mnschet, 5, kod_smo )
    rees->NAME_XML := aFilesName[ 1 ]
    mkod_reestr := rees->KOD
    rees->CODE  := ret_unique_code( mkod_reestr )
    code_reestr := rees->CODE

    dbSelectArea( 'MO_XML' )
    addrecn()
    mo_xml->KOD    := RecNo()
    mo_xml->FNAME  := rees->NAME_XML
//    mo_xml->FNAME2 := 'L' + s
    mo_xml->FNAME2 := aFilesName[ 2 ]
    mo_xml->DFILE  := rees->DSCHET
    mo_xml->TFILE  := hour_min( Seconds() )
    mo_xml->TIP_OUT := _XML_FILE_SCHET_25 // тип высылаемого файла; 7-реестр счетов новой системы обмена
    mo_xml->REESTR := mkod_reestr
//
    rees->KOD_XML := mo_xml->KOD
    // изменить
//    cNschet := kod_smo + '-' + '782' + '-1' + cBukva
    cNschet := kod_smo + '-' + AllTrim( Str( mnschet ) ) + '-1' + cBukva
    rees->NOMER_S := cNschet
    rees->BUKVA := cBukva
    //
    mo_xml->( dbUnlock() )
    mo_xml->( dbCommit() )
    rees->( dbUnlock() )
    rees->( dbCommit() )

    pkol := psumma := iusl := 0
    dbSelectArea( 'TMP' )
    tmp->( dbGoTop() )
    tmp->( dbSeek( cBukva, .t. ) )
    do while tmp->BUKVA == cBukva .and. ! tmp->( Eof() )
      arrLP := {}
//      @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
      HUMAN->( dbGoto( tmp->kod_human ) )

      otd->( dbGoto( human->OTD ) )
      lTypeLUOnkoDisp := ( otd->tiplu == TIP_LU_ONKO_DISP )
      
      pkol++
      psumma += human->cena_1
      dbSelectArea( 'RHUM' )
      addrec( 6 )
      rhum->REESTR := mkod_reestr
      rhum->KOD_HUM := human->kod
      rhum->REES_ZAP := pkol
//      human_->( g_rlock( forever ) )
      human_->( dbRLock() )
      If human_->REES_NUM < 99
        human_->REES_NUM := human_->REES_NUM + 1
      Endif
      human_->REESTR := mkod_reestr
      human_->REES_ZAP := pkol
      If tmpb->ishod == 89  // 2-й случай
        dbSelectArea( 'HUMAN_3' )
        human_3->( dbSeek( Str( tmpb->kod_human, 7 ) ) )
        If human_3->( Found() )
          g_rlock( forever )
          If human_3->REES_NUM < 99
            human_3->REES_NUM := human_3->REES_NUM + 1
          Endif
          human_3->REESTR := mkod_reestr
          human_3->REES_ZAP := pkol
          //
          dbSelectArea( 'HUMAN' )
          human->( dbGoto( human_3->kod ) ) // встать на 1-й случай
//          human_->( g_rlock( forever ) )
          human_->( dbRLock() )
          psumma += human->cena_1
          If human_->REES_NUM < 99
            human_->REES_NUM := human_->REES_NUM + 1
          Endif
          human_->REESTR := mkod_reestr
          human_->REES_ZAP := pkol
        Endif
        If pkol % 2000 == 0
          dbUnlockAll()
          dbCommitAll()
        Endif
      Endif
//        dbSelectArea( 'TMP' )
//        cBukva := tmp->bukva
//      endif
      tmp->(dbSkip() )
    enddo
    dbSelectArea( 'REES' )
    g_rlock( forever )
    rees->KOL := pkol
    rees->SUMMA := psumma
    dbUnlockAll()
    dbCommitAll()
    //
    //
    Private arr_usl_otkaz, adiag_talon[ 16 ]
    //
    // создадим новый XML-документ для реестра случаев
    oXmlDoc := hxmldoc():new()
    // заполним корневой элемент XML-документа
    oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
    // заполним заголовок XML-документа
    controlVer := _nyear * 100 + _nmonth
    if p_tip_reestr == 1
      // Реестр случаев оказания медицинской помощи, за исключением медицинской помощи по диспансеризации,
      // медицинским осмотрам несовершеннолетних и профилактическим медицинским осмотрам определенных групп взрослого населения
      sVersion := '5.1'
      If ( controlVer >= 202507 ) // с июля 2025 года
        sVersion := '5.1'
      Endif
    elseif p_tip_reestr == 2
      // Реестр случаев оказания медицинской помощи по диспансеризации, профилактическим медицинским
      // осмотрам несовершеннолетних и профилактическим медицинским осмотрам определенных групп взрослого населения
      sVersion := '5.0'
      If ( controlVer >= 202501 ) // с января 2025 года
        sVersion := '5.0'
      Endif
    endif
    mo_add_xml_stroke( oXmlNode, 'VERSION', sVersion )
    mo_add_xml_stroke( oXmlNode, 'DATA', date2xml( rees->DSCHET ) )
    mo_add_xml_stroke( oXmlNode, 'FILENAME', mo_xml->FNAME )
    mo_add_xml_stroke( oXmlNode, 'SD_Z', lstr( pkol ) )

    // заполним реестр случаев для XML-документа
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'SCHET' ) )
    mo_add_xml_stroke( oXmlNode, 'CODE', lstr( code_reestr ) )
    mo_add_xml_stroke( oXmlNode, 'CODE_MO', glob_mo()[ _MO_KOD_FFOMS ] )    //  CODE_MO )
    mo_add_xml_stroke( oXmlNode, 'YEAR', lstr( _NYEAR ) )
    mo_add_xml_stroke( oXmlNode, 'MONTH', lstr( _NMONTH ) )
//    mo_add_xml_stroke( oXmlNode, 'NSCHET', lstr( rees->NSCHET ) )
    mo_add_xml_stroke( oXmlNode, 'NSCHET', cNschet )
    mo_add_xml_stroke( oXmlNode, 'DSCHET', date2xml( rees->DSCHET ) )
    mo_add_xml_stroke( oXmlNode, 'SUMMAV', Str( psumma, 15, 2 ) )

    // создадим новый XML-документ для реестра пациентов
    fl_ver := 311
    oXmlDocPacient := hxmldoc():new()
    // заполним корневой элемент реестра пациентов для XML-документа
    oXmlDocPacient:add( hxmlnode():new( 'PERS_LIST' ) )
    // заполним заголовок файла реестра пациентов для XML-документа
    oXmlNodePacient := oXmlDocPacient:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
    sVersionPacient := '3.11'
    If StrZero( _nyear, 4 ) + StrZero( _nmonth, 2 ) > '201910' // с ноября 2019 года
      fl_ver := 32
      sVersionPacient := '3.2'
    Endif
    mo_add_xml_stroke( oXmlNodePacient, 'VERSION', sVersionPacient )
    mo_add_xml_stroke( oXmlNodePacient, 'DATA', date2xml( rees->DSCHET ) )
    mo_add_xml_stroke( oXmlNodePacient, 'FILENAME', mo_xml->FNAME2 )
    mo_add_xml_stroke( oXmlNodePacient, 'FILENAME1', mo_xml->FNAME )

// заполняем реестры случаев и пациентов    
    dbSelectArea( 'RHUM' )
    Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->REESTR == mkod_reestr
    rhum->( dbGoTop() )
  
    oPb := TProgressBar():New( MaxRow(), 0, 20, 0, pkol )
    oPb:Color := cColorStMsg
    oPb:Symbol := Chr( 219 )
    oPb:Display()

    j := 0
    Do While ! rhum->( Eof() )
//      @ MaxRow(), 0 Say Str( rhum->REES_ZAP / pkol * 100, 6, 2 ) + '%' Color cColorSt2Msg
      oPb:Update( j )

      // записываем элемент для случая
      elem_reestr_sluch( oXmlDoc, p_tip_reestr, _nyear )

      // записываем элемент для пациента
      elem_reestr_pacient( oXmlDocPacient, fl_ver, p_tip_reestr )      
      rhum->( dbSkip() )
      j++
    enddo
    oPb := nil

//    stat_msg( 'Запись XML-документа в файл реестра случаев' )

    oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml() )
    name_zip := AllTrim( mo_xml->FNAME ) + szip()
    AAdd( arr_zip, AllTrim( mo_xml->FNAME ) + sxml() )
    //
    oXmlDocPacient:save( AllTrim( mo_xml->FNAME2 ) + sxml() )
    AAdd( arr_zip, AllTrim( mo_xml->FNAME2 ) + sxml() )
    //
    If chip_create_zipxml( name_zip, arr_zip, .t. )
//      Keyboard Chr( K_TAB ) + Chr( K_ENTER )
    Endif
  next

  close_file_reestr26()
  Return Nil

// 17.05.25
function close_file_reestr26()

  close_use_base( 'lusl' )
  close_use_base( 'luslc' )
  close_use_base( 'luslf' )
  close_list_alias( { 'MKB_10', 'REES', 'MO_XML', 'IMPL', 'LEK_PR', 'UCH', 'OTD', 'P2', 'P2TABN' } )
  close_list_alias( { 'USL', 'RHUM', 'HU_', 'HU', 'MOSU', 'MOHU' } )
  close_list_alias( { 'INV', 'KART2', 'KART_', 'KART', 'HUMAN_2', 'T21' } )
  close_list_alias( { 'ONKNA', 'ONKCO', 'ONKSL', 'ONKDI', 'ONKPR', 'ONKUS', 'ONKLE' } )
  return nil