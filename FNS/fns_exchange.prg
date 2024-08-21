#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define NALOG_PLAT  1
#define PACIENT     2

// 20.08.24
Function reestr_xml_fns()

  Local mtitle
  Local buf := SaveScreen()
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

  // use_base( 'xml_fns', 'xml' )

  // xml->( dbGoBottom() )
  // mtitle := 'Файлы выгрузки для ФЭС'
  // alpha_browse( 5, 0, MaxRow() - 2, 79, 'defColumn_xml_FNS', color0, mtitle, 'BG+/GR', ;
  //   .f., .t., , , 'serv_xml_fns', , ;
  //   { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

  // dbCloseAll()
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

// 18.08.24
function name_file_fns_xml( org, dt, num, id_pol, id_end )

  local nameXML
  local prefix := 'UT_SVOPLMEDUSL'

  nameXML := prefix + '_' + id_pol + '_' + id_end + '_' + ;
    iif( org:UrOrIP(), org:INN() + org:KPP(), org:INN() ) + ;
    str( year( dt ), 4 ) + strzero( Month( dt ), 2, 0 ) + strzero( Day( dt ), 2, 0 ) + ;
    alltrim( str( num, 36 ) )

  return nameXML

// 21.08.24
function createXMLtoFNS() // nameFileXML )

  local aPlat := Array( 2, 17 )
  local oXmlDoc, oXmlNode, oXmlNodeDoc
  local oPAC, oUch, oDoc, oPodp, oRash, oSved
  local arr_m, i, mYear, curPreds := ''
  local org := hb_main_curorg
  local ver := '5.01'
  local nameFileXML
  local xml_created := .f., kolSpravka := 0, arr_spravka := {}
  local totalSpravka := 0, totalFile := 0

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
        oXmlDoc:save( nameFileXML + sxml )
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
        oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( 'НПЮЛ' ) ) )
        mo_add_xml_stroke( oUch, hb_OEMToANSI( 'НаимОрг' ), org:Name() )
        mo_add_xml_stroke( oUch, hb_OEMToANSI( 'ИННЮЛ' ), org:INN() )
        mo_add_xml_stroke( oUch, hb_OEMToANSI( 'КПП' ), org:KPP() )
      else
        oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( 'НПИП' ) ) )
        mo_add_xml_stroke( oUch, hb_OEMToANSI( 'ИННФЛ' ), org:INN() )
        node_fio_tip_fns( oUch, org:Ruk_fio() )
      endif

      // ПОДПИСАНТ
      oPodp := oDoc:add( hxmlnode():new( hb_OEMToANSI( 'Подписант' ) ) )
      if tmp_fns->pred_ruk == 0
        mo_add_xml_stroke( oPodp, hb_OEMToANSI( 'ПрПодп' ), '2' )
        node_fio_tip_fns( oPodp, alltrim( tmp_fns->predst ) )

        oSved := oPodp:add( hxmlnode():new( hb_OEMToANSI( 'СвПред' ) ) )
        mo_add_xml_stroke( oSved, hb_OEMToANSI( 'НаимДок' ), Upper( alltrim( tmp_fns->pred_doc ) ) )
      else
        mo_add_xml_stroke( oPodp, hb_OEMToANSI( 'ПрПодп' ), '1' )
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
    mo_add_xml_stroke( oRash, hb_OEMToANSI( 'НомерСвед' ), str( tmp_fns->num_s, 12 ) )
    mo_add_xml_stroke( oRash, hb_OEMToANSI( 'НомКорр' ), str( tmp_fns->version, 3 ) )
    mo_add_xml_stroke( oRash, hb_OEMToANSI( 'ПрПациент' ), str( tmp_fns->attribut, 1 ) )
    if tmp_fns->sum1 > 0
      mo_add_xml_stroke( oRash, hb_OEMToANSI( 'СуммаКод1' ), str( tmp_fns->sum1, 15, 2 ) )
    endif
    if tmp_fns->sum2 > 0
      mo_add_xml_stroke( oRash, hb_OEMToANSI( 'СуммаКод2' ), str( tmp_fns->sum2, 15, 2 ) )
    endif
    node_DAN_FIO_TIP( oRash, NALOG_PLAT, tmp_fns->inn, tmp_fns->plat_dob, tmp_fns->plat_fio, tmp_fns->viddoc, tmp_fns->ser_num, tmp_fns->datevyd )

    if tmp_fns->attribut == 0 // проверка на совпадение налогоплательщика и пациента
//      node_DAN_FIO_TIP( oRash, PACIENT, aPlat[ i, 12 ], aPlat[ i, 13 ], aPlat[ i, 17 ], aPlat[ i, 14 ], aPlat[ i, 15 ], aPlat[ i, 16 ] )
    endif

    tmp_fns->( dbSkip() )
  enddo
  if xml_created
    oXmlDoc:save( nameFileXML + sxml )

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
  hb_Alert( 'Обработано: ' + alltrim( str( totalSpravka ) ) + ' справок, создано ' + alltrim( str( totalFile ) ) + ' файлов.' )
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

// 18.08.24
function node_DAN_FIO_TIP( obj, node_type, inn, dob, fio, docType, docSerNum, docDate )

  local oDAN_FIO_TIP

  oDAN_FIO_TIP := obj:add( hxmlnode():new( hb_OEMToANSI( iif( node_type == NALOG_PLAT, 'НППлатМедУсл', 'Пациент' ) ) ) )
  if ! empty( inn )
    mo_add_xml_stroke( oDAN_FIO_TIP, hb_OEMToANSI( 'ИНН' ), inn )
  endif
  mo_add_xml_stroke( oDAN_FIO_TIP, hb_OEMToANSI( 'ДатаРожд' ), transform( dob, '99.99.9999' ) )
  node_fio_tip_fns( oDAN_FIO_TIP, fio )
  if empty( inn )
    node_Sved_Doc_fns( oDAN_FIO_TIP, docType, docSerNum, docDate )
  endif
  return nil

// 18.08.24
function node_Sved_Doc_fns( obj, kod, sernum, datedoc )

  local oSvedDoc

  oSvedDoc := obj:add( hxmlnode():new( hb_OEMToANSI( 'СведДок' ) ) )
  mo_add_xml_stroke( oSvedDoc, hb_OEMToANSI( 'КодВидДок' ), strzero( kod, 2 ) )
  mo_add_xml_stroke( oSvedDoc, hb_OEMToANSI( 'СерНомДок' ), sernum )
  mo_add_xml_stroke( oSvedDoc, hb_OEMToANSI( 'ДатаДок' ), transform( datedoc, '99.99.9999' ) )
  return nil

// 18.08.24
function node_fio_tip_fns( obj, fio )

  local aFio, node_fio

  aFIO := razbor_str_fio( Upper( fio ) )
  node_fio := obj:add( hxmlnode():new( hb_OEMToANSI( 'ФИО' ) ) )
  mo_add_xml_stroke( node_fio, hb_OEMToANSI( 'Фамилия' ), aFIO[ 1 ] )
  mo_add_xml_stroke( node_fio, hb_OEMToANSI( 'Имя' ), aFIO[ 2 ] )
  if ! empty( aFIO[ 3 ] )
    mo_add_xml_stroke( node_fio, hb_OEMToANSI( 'Отчество' ), aFIO[ 3 ] )
  endif
  return nil