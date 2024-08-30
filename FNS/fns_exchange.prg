#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'
#include 'i_xml.ch'

#define NALOG_PLAT  1
#define PACIENT     2

Static reestr_xml_fns_sem := 'Работа с реестрами справок ФНС'
Static reestr_xml_fns_err := 'В данный момент с реестрами ФНС работает другой пользователь.'

// 25.08.24
Function view_list_xml_fns()

  Local i, k, buf := SaveScreen()

  If ! g_slock( reestr_xml_fns_sem )
    Return func_error( 4, reestr_xml_fns_err )
  Endif

  g_use( dir_server + 'reg_xml_fns', , 'xml' )
  Index On str( kod, 6 ) to ( cur_dir() + 'tmp_xml' ) DESCENDING
  Go Top
  xml->( dbGoTop() )
  If xml->( Eof() )
    func_error( 4, 'Нет реестров справок' )
  Else
    alpha_browse( 5, 0, 23, 79, 'defColumn_xml_FNS', color0,,,,,,, ;
      'serv_xml_fns',, { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )
  Endif

  dbCloseAll()
  g_sunlock( reestr_xml_fns_sem )
  RestScreen( buf )
  return nil

// 26.08.24
function serv_xml_fns( nKey, oBrow )

  Local j := 0, ret := -1, buf := SaveScreen(), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, ;
    xml_file, s, k := 0, smsg := ''
  local nResult

  Do Case
  Case nKey == K_F5
    s := manager( T_ROW, T_COL + 5, MaxRow() - 2, , .t., 2, .f.,,, ) // "norton" для выбора каталога
    If !Empty( s )
      If Upper( s ) == Upper( dir_XML_FNS() )
        func_error( 4, 'Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.' )
      Else
        xml_file := alltrim( xml->fname ) + sxml
        If hb_FileExists( dir_XML_FNS() + xml_file )
          mywait( 'Копирование "' + xml_file + '" в каталог "' + s + '"' )
          if ( nResult := hb_vfCopyFile( dir_XML_FNS() + xml_file, s + xml_file ) ) == 0  // скопировано без ошибок
            xml->( g_rlock( forever ) )
            xml->DATE_OUT := sys_date
            If xml->NUMB_OUT < 99
              xml->NUMB_OUT++
            Endif
            //
          Else
            smsg := '! Ошибка записи файла ' + s + xml_file
            func_error( 4, smsg )
          Endif
        Else
          smsg := '! Не обнаружен файл ' + dir_XML_FNS() + xml_file
          func_error( 4, smsg )
        Endif
        Unlock
        Commit
      Endif
    endif
    ret := 0
  Case nKey == K_F3
    view_list_xml( oBrow )
    ret := 0
  Otherwise
    Keyboard ''
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )
  Return ret

// 28.08.24
Function view_list_xml( oBrow )

  Local buf := save_maxrow(), ;
    reg_print := 2, ;
    tmp_select := select(), ;
    mm_menu := { 'Список ~всех налогоплательшиков в реестре' ;
    }
  local nFile, ft, name_file := cur_dir() + 'fns_nalog.txt'
  local arr_title := { ;
    '───────┬──────┬───────────┬───────────────────────────────┬──────────┬────────────', ;
    ' Номер │Кор-ка│   Дата    │   Фамилия, имя, отчество      │  Сумма1  │  Сумма2', ;
    'справки│      │составления│                               │    руб.  │    руб.', ;
    '───────┼──────┼───────────┼───────────────────────────────┼──────────┼─────────────' ;
  }

  mywait()
  ft := tfiletext():new( name_file, , .t., , .t. ) 
  ft:width := 82
  ft:TableHeader := arr_title
  ft:EnableTableHeader := .t.
  ft:add_string( '' )
  ft:add_string( 'Список справок в реестре', FILE_CENTER, ' ' )
  ft:add_string( alltrim( xml->fname ) + sxml, FILE_CENTER, ' ' )
  ft:add_string( 'от ' + transform( xml->dfile, '99.99.99' ) + 'г.', FILE_CENTER, ' ' )
  ft:add_string( '' )
  ft:printTableHeader()

  r_use( dir_server + 'register_fns', , 'fns' )
  fns->( dbGoTop() )
  Do While ! fns->( Eof() )
    if fns->kod_xml == xml->kod
      ft:add_string( ' ' + str( fns->num_s, 5 ) + ' │  ' + strzero( fns->version, 3 ) ;
        + ' │ ' + transform( fns->date, '99.99.99' ) + '│ ' +  + padr( fns->plat_fio, 30 ) + '│ ' ;
        + str( fns->sum1, 8, 2 ) + ' │' + str( fns->sum2, 8, 2 ) )
    endif
    fns->( dbSkip() )
  Enddo
  ft:add_string( '───────┴──────┴───────────┴───────────────────────────────┴──────────┴─────────────' )
  nFile := ft:NameFile
  ft := nil
  viewtext( name_file, , , , .t., , , reg_print )
  select( tmp_select )
  fns->( dbCloseArea() )
  Return Nil

// 26.08.24
function defColumn_xml_FNS( oBrow )

  Local oColumn, s, ;
  blk := {|| iif( hb_FileExists( dir_XML_FNS() + AllTrim( xml->fname ) + sxml ), ;
    iif( Empty( xml->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( ' Номер ', {|| padl( alltrim( substr( xml->fname, hb_RAt( '_', xml->fname ) + 1 ) ), 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  Дата', {|| date_8( xml->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Кол.;спр.', {|| str( xml->kol1, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Имя файла ', {|| substr( xml->fname, 26 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Примечание', {|| view_xml_fns() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход; ^<F3>^ список справок в реестре; ^<F5>^ запись для ФНС' )
  Return Nil

// 25.08.24
Function view_xml_fns()

  Local s := ''
  
  If ! hb_FileExists( dir_XML_FNS() + AllTrim( xml->fname ) + sxml )
    s := 'нет файла'
  Elseif Empty( xml->date_out )
    s := 'не записан'
  Else
    s := 'зап. ' + lstr( xml->NUMB_OUT ) + ' раз'
  Endif
  Return PadR( s, 10 )
  
  // 25.08.24
Function reestr_xml_fns()

//  Local buf := SaveScreen()
  local prefix := 'UT_SVOPLMEDUSL', nameFileXML := ''
  local org := hb_main_curorg

  _fns_nastr( 1 )

  if empty( org:INN() )
    func_error( 4, 'Для организации отсутствует ИНН!' )
    return nil
  endif

  if org:UrOrIP() .and. empty( org:KPP() )
    func_error( 4, 'Для организации отсутствует КПП!' )
    return nil
  endif
  if empty( fns_ID_POL )
    func_error( 4, 'Отсутствует идентификатор получателя, которому направляется файл обмена!' )
    return nil
  endif

  if empty( fns_ID_END )
    func_error( 4, 'Отсутствует идентификатор конечного получателя, для которого предназначена информация из данного файла обмена!' )
    return nil
  endif

  createXMLtoFNS()
//  RestScreen( buf )
  Return Nil

// 22.08.24
function name_file_fns_xml( org, dt, num, id_pol, id_end )

  local nameXML
  local prefix := 'UT_SVOPLMEDUSL'

  nameXML := prefix + '_' + id_pol + '_' + id_end + '_' + ;
    iif( org:UrOrIP(), org:INN() + org:KPP(), org:INN() ) + '_' + ;
    str( year( dt ), 4 ) + strzero( Month( dt ), 2, 0 ) + strzero( Day( dt ), 2, 0 ) + '_' + ;
    alltrim( str( num, 36 ) )

  return nameXML

// 29.08.24
function createXMLtoFNS()

  local aPlat := Array( 2, 17 )
  local oXmlDoc, oXmlNode, oXmlNodeDoc
  local oPAC, oUch, oDoc, oPodp, oRash, oSved
  local arr_m, i, mYear, curPreds := ''
  local org := hb_main_curorg
  local ver := '5.01'
  local nameFileXML
  local xml_created := .f., kolSpravka := 0, arr_spravka := {}
  local totalSpravka := 0, totalFile := 0
  local dir_xml := dir_XML_FNS()

  local tmp_fns := { ;  // журнал выданных справок для ФНС
    { 'KOD',     'N',     7,   0 }, ; // recno()
    { 'DATE',    'D',     8,   0 }, ; // дата составления
    { 'KOD_K',   'N',     7,   0 }, ; // код по картотеке
    { 'NYEAR',   'N',     4,   0 }, ; // отчетный год
    { 'NUM_S',   'N',     7,   0 }, ; // номер справки
    { 'VERSION', 'N',     3,   0 }, ; // номер корректировки
    { 'ATTRIBUT','N',     1,   0 }, ; // признак 0 - налогоплательщик и пациент не являются одним лицом; 1 - налогоплательщик и пациент являются одним лицом.
    { 'INN',     'C',    12,   0 }, ; // ИНН плательщика
    { 'PLAT_FIO','C',    50,   0 }, ; // ФИО налогоплательщика
    { 'PLAT_DOB','D',     8,   0 }, ; // дата рождения налогоплательщика
    { 'VIDDOC',  'N',     2,   0 }, ; // вид документа налогоплательщика
    { 'SER_NUM', 'C',    20,   0 }, ; // серия и номер документа налогоплательщика
    { 'DATEVYD', 'D',     8,   0 }, ; // дата выдачи документа налогоплательщика
    { 'SUM1',    'N',    16,   2 }, ; // сумма 1
    { 'SUM2',    'N',    16,   2 }, ; // сумма 2
    { 'PRED_RUK','N',     1,   0 }, ; // признак 1 - представитель руководитель МО; 2 - представитель, сотрудник МО
    { 'PREDST',  'C',    50,   0 }, ; // представитель организации
    { 'PRED_DOC','C',    50,   0 }, ; // документ представителя
    { 'KOD_XML', 'N',     6,   0 } ; // ссылка на файл 'mo_xml_fns', для отправки в ФНС или число -1 если печатная форма, 0 - если xml файл не формировался
  }

  If ( arr_m := input_year() ) == NIL
    Return Nil
  Endif
  mYear := arr_m[ 1 ]

  use_base( 'xml_fns', 'xml_fns', .t. )

  dbCreate( cur_dir() + 'tmp_fns', tmp_fns,, .t., 'tmp_fns' )
  Index On predst + Str( num_s, 7 ) to ( cur_dir() + 'tmp_fns' )
  use_base( 'reg_fns', 'fns', .t. )
  fns->( dbGoTop() )
  do while ! fns->( Eof() )
    if fns->nyear == mYear .and. fns->KOD_XML <= 0
      tmp_fns->( dbAppend() )
      tmp_fns->kod := fns->kod
      tmp_fns->date := fns->date
      tmp_fns->kod_k := fns->kod_k
      tmp_fns->nyear := fns->nyear
      tmp_fns->num_s := fns->num_s
      tmp_fns->version := fns->version
      tmp_fns->attribut := fns->attribut
      tmp_fns->inn := fns->inn
      tmp_fns->plat_fio := fns->plat_fio
      tmp_fns->plat_dob := fns->plat_dob
      tmp_fns->viddoc := fns->viddoc
      tmp_fns->ser_num := fns->ser_num
      tmp_fns->datevyd := fns->datevyd
      tmp_fns->sum1 := fns->sum1
      tmp_fns->sum2 := fns->sum2
      tmp_fns->pred_ruk := fns->pred_ruk
      tmp_fns->predst := fns->predst
      tmp_fns->pred_doc := fns->pred_doc
    endif
    fns->( dbSkip() )
  enddo
  tmp_fns->( dbSelectArea() )
  tmp_fns->( dbGoTop() )

  do while ! tmp_fns->( Eof() )

    if curPreds != tmp_fns->predst
      if xml_created
        check_and_create_dir( dir_xml )
        oXmlDoc:save( dir_xml + nameFileXML + sxml )
        
        xml_fns->( dbAppend() )
        xml_fns->kod := xml_fns->( recno() )
        xml_fns->fname := nameFileXML
        xml_fns->dfile := date()
        xml_fns->tfile := hour_min( Seconds() )
        xml_fns->kol1 := kolSpravka
        fill_pole_spravok( 'fns', arr_spravka, xml_fns->kod )

        G_Use( dir_server + 'reg_fns_nastr', , 'NASTR_FNS' )
        G_RLock( forever )
        NASTR_FNS->N_FILE_UP := fns_N_SPR_FILE
        nastr_fns->( dbCloseArea() )
        totalFile++
      endif

      arr_spravka := {}
      kolSpravka := 0
      curPreds := tmp_fns->predst
      nameFileXML := name_file_fns_xml( org, date(), ++fns_N_SPR_FILE, fns_ID_POL, fns_ID_END )
  
      // создадим новый XML-документ
      oXmlDoc := hxmldoc():new()
      xml_created := .t.

      oXmlNode := hxmlnode():new( hb_OEMToANSI( 'Файл' ) )
      oXmlNode:SetAttribute( hb_OEMToANSI( 'ИдФайл' ), nameFileXML )
      oXmlNode:SetAttribute( hb_OEMToANSI( 'ВерсПрог' ), hb_OEMToANSI( 'ЧИП_МО ' ) + fs_version_short( _version() ) )
      oXmlNode:SetAttribute( hb_OEMToANSI( 'ВерсФорм' ), ver )
      oXmlDoc:add( oXmlNode )

      oXmlNodeDoc := hxmlnode():new( hb_OEMToANSI( 'Документ' ) )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'КНД' ), '1184043' )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'ДатаДок' ), transform( date(), '99.99.9999' ) )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'КодНО' ), fns_ID_POL )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'ОтчГод' ), str( mYear, 4 ) )
      oDOC := oXmlDoc:aItems[ 1 ]:add( oXmlNodeDoc )

      oPAC := oDoc:add( hxmlnode():new( hb_OEMToANSI( 'СвНП' ) ) )
      if org:UrOrIp()
        oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( 'НПЮЛ' ), HBXML_TYPE_SINGLE ) )
        oUch:SetAttribute( hb_OEMToANSI( 'НаимОрг' ), hb_OEMToANSI( alltrim( org:Name() ) ) )
        oUch:SetAttribute( hb_OEMToANSI( 'ИННЮЛ' ), hb_OEMToANSI( alltrim( org:INN() ) ) )
        oUch:SetAttribute( hb_OEMToANSI( 'КПП' ), hb_OEMToANSI( alltrim( org:KPP() ) ) )
      else
        oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( 'НПИП' ), HBXML_TYPE_SINGLE ) )
        oUch:SetAttribute( hb_OEMToANSI( 'ИННФЛ' ), hb_OEMToANSI( alltrim( org:INN() ) ) )
        node_fio_tip_fns( oUch, org:Ruk_fio() )
      endif

      // ПОДПИСАНТ
      oPodp := oDoc:add( hxmlnode():new( hb_OEMToANSI( 'Подписант' ) ) )
      if tmp_fns->pred_ruk == 0
        oPodp:SetAttribute( hb_OEMToANSI( 'ПрПодп' ), '2' )
        node_fio_tip_fns( oPodp, alltrim( tmp_fns->predst ) )

        oSved := oPodp:add( hxmlnode():new( hb_OEMToANSI( 'СвПред' ), HBXML_TYPE_SINGLE ) )
        oSved:SetAttribute( hb_OEMToANSI( 'НаимДок' ), hb_OEMToANSI( Upper( alltrim( tmp_fns->pred_doc ) ) ) )
      else
        oPodp:SetAttribute( hb_OEMToANSI( 'ПрПодп' ), '1' )
        if org:UrOrIp()
          node_fio_tip_fns( oPodp, org:Ruk_fio() )
        endif
      endif
    endif
    totalSpravka++
    kolSpravka++
    AAdd( arr_spravka, tmp_fns->kod )
    // Сведения о расходах
    oRash := oDoc:add( hxmlnode():new( hb_OEMToANSI( 'СведРасхУсл' ) ) )
    oRash:SetAttribute( hb_OEMToANSI( 'НомерСвед' ), alltrim( str( tmp_fns->num_s, 12 ) ) )
    oRash:SetAttribute( hb_OEMToANSI( 'НомКорр' ), alltrim( str( tmp_fns->version, 3 ) ) )
    oRash:SetAttribute( hb_OEMToANSI( 'ПрПациент' ), str( tmp_fns->attribut, 1 ) )
    if tmp_fns->sum1 > 0
      oRash:SetAttribute( hb_OEMToANSI( 'СуммаКод1' ), alltrim( str( tmp_fns->sum1, 15, 2 ) ) )
    endif
    if tmp_fns->sum2 > 0
      oRash:SetAttribute( hb_OEMToANSI( 'СуммаКод2' ), alltrim( str( tmp_fns->sum2, 15, 2 ) ) )
    endif
    node_DAN_FIO_TIP( oRash, NALOG_PLAT, tmp_fns->inn, tmp_fns->plat_dob, tmp_fns->plat_fio, tmp_fns->viddoc, tmp_fns->ser_num, tmp_fns->datevyd )

    if tmp_fns->attribut == 0 // проверка на совпадение налогоплательщика и пациента
//      node_DAN_FIO_TIP( oRash, PACIENT, aPlat[ i, 12 ], aPlat[ i, 13 ], aPlat[ i, 17 ], aPlat[ i, 14 ], aPlat[ i, 15 ], aPlat[ i, 16 ] )
    endif

    tmp_fns->( dbSkip() )
  enddo
  if xml_created
    check_and_create_dir( dir_xml )
    oXmlDoc:save( dir_xml + nameFileXML + sxml )

    xml_fns->( dbAppend() )
    xml_fns->kod := xml_fns->( recno() )
    xml_fns->fname := nameFileXML
    xml_fns->dfile := date()
    xml_fns->tfile := hour_min( Seconds() )
    xml_fns->kol1 := kolSpravka
    fill_pole_spravok( 'fns', arr_spravka, xml_fns->kod )

    G_Use( dir_server + 'reg_fns_nastr', , 'NASTR_FNS' )
    G_RLock( forever )
    NASTR_FNS->N_FILE_UP := fns_N_SPR_FILE
    nastr_fns->( dbCloseArea() )
    totalFile++
  endif

  tmp_fns->( dbCloseArea() )
  xml_fns->( dbCloseArea() )
  fns->( dbCloseArea() )
  if totalSpravka == 0
    hb_Alert( 'Отсутствуют не обработанные справки!' )
  else
    hb_Alert( 'Обработано: ' + alltrim( str( totalSpravka ) ) + ' справок, создано ' + alltrim( str( totalFile ) ) + ' файлов.' )
  endif
  return nil

// 22.08.24
function check_and_create_dir( dir )

  if ! hb_vfDirExists( dir )
    hb_vfDirMake( dir )
  endif
  return nil

// 21.08.24
function fill_pole_spravok( alias, arr_spravka, kod )

  local tmpRec, i

  tmpRec := ( alias )->( recno() )

  for i := 1 to len( arr_spravka )
    ( alias )->( dbGoto( arr_spravka[ i ] ) )
    ( alias )->kod_xml := kod
  next

  ( alias )->( dbGoto( tmpRec ) )
  return nil

// 23.08.24
function node_DAN_FIO_TIP( obj, node_type, inn, dob, fio, docType, docSerNum, docDate )

  local oDAN_FIO_TIP

  oDAN_FIO_TIP := obj:add( hxmlnode():new( hb_OEMToANSI( iif( node_type == NALOG_PLAT, 'НППлатМедУсл', 'Пациент' ) ) ) )
  if ! empty( inn )
    oDAN_FIO_TIP:SetAttribute( hb_OEMToANSI( 'ИНН' ), alltrim( inn ) )
  endif
  oDAN_FIO_TIP:SetAttribute( hb_OEMToANSI( 'ДатаРожд' ), transform( dob, '99.99.9999' ) )
  node_fio_tip_fns( oDAN_FIO_TIP, fio )
  if empty( inn )
    node_Sved_Doc_fns( oDAN_FIO_TIP, docType, docSerNum, docDate )
  endif
  return nil

// 30.08.24
function node_Sved_Doc_fns( obj, kod, sernum, datedoc )

  local oSvedDoc
  local aAttr := {}

  AAdd( aAttr, { hb_OEMToANSI( 'КодВидДок' ), strzero( kod, 2 ) } )
  AAdd( aAttr, { hb_OEMToANSI( 'СерНомДок' ), alltrim( sernum ) } )
  AAdd( aAttr, { hb_OEMToANSI( 'ДатаДок' ), transform( datedoc, '99.99.9999' ) } )
  oSvedDoc := obj:add( hxmlnode():new( hb_OEMToANSI( 'СведДок' ), HBXML_TYPE_SINGLE, aAttr ) )
  // oSvedDoc:SetAttribute( hb_OEMToANSI( 'КодВидДок' ), strzero( kod, 2 ) )
  // oSvedDoc:SetAttribute( hb_OEMToANSI( 'СерНомДок' ), alltrim( sernum ) )
  // oSvedDoc:SetAttribute( hb_OEMToANSI( 'ДатаДок' ), transform( datedoc, '99.99.9999' ) )
  return nil

// 30.08.24
function node_fio_tip_fns( obj, fio )

  local aFio, node_fio
  local aAttr := {}

  aFIO := razbor_str_fio( Upper( fio ) )
  AAdd( aAttr, { hb_OEMToANSI( 'Фамилия' ), hb_OEMToANSI( aFIO[ 1 ] ) } )
  AAdd( aAttr, { hb_OEMToANSI( 'Имя' ), hb_OEMToANSI( aFIO[ 2 ] ) } )
  if ! empty( aFIO[ 3 ] )
    AAdd( aAttr, { hb_OEMToANSI( 'Отчество' ), hb_OEMToANSI( aFIO[ 3 ] ) } )
  endif
  node_fio := obj:add( hxmlnode():new( hb_OEMToANSI( 'ФИО' ), HBXML_TYPE_SINGLE, aAttr ) )
  // node_fio:SetAttribute( hb_OEMToANSI( 'Фамилия' ), hb_OEMToANSI( aFIO[ 1 ] ) )
  // node_fio:SetAttribute( hb_OEMToANSI( 'Имя' ), hb_OEMToANSI( aFIO[ 2 ] ) )
  // if ! empty( aFIO[ 3 ] )
  //   node_fio:SetAttribute( hb_OEMToANSI( 'Отчество' ), hb_OEMToANSI( aFIO[ 3 ] ) )
  // endif
  return nil