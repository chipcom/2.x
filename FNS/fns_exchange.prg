#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define NALOG_PLAT  1
#define PACIENT     2

// 17.08.24
Function reestr_xml_fns()

  Local mtitle
  Local buf := SaveScreen()
  local prefix := 'UT_SVOPLMEDUSL', nameFileXML := ''
  local org := hb_main_curorg
  local dt, num

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

  dt := Date()  //временно
  num := fns_N_SPR_FILE + 1  //временно

  nameFileXML := name_file_fns_xml( org, dt, num, fns_ID_POL, fns_ID_END )

  createXMLtoFNS( nameFileXML )

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

// 18.08.24
function createXMLtoFNS( nameFileXML )

  local aPlat := Array( 2, 17 )
  local oXmlDoc, oXmlNode, oXmlNodeDoc
  local oPAC, oUch, oDoc, oPodp, oRash, oSved
  local org := hb_main_curorg
  local ver := '5.01', i

  local dt := date()    // временно

  aPlat[ 1, 1 ] := 1  // номер справки
  aPlat[ 1, 2 ] := 0  // номер корректировки
  aPlat[ 1, 3 ] := 1  // налогоплательщик и пациент одно лицо 0 - нет, 1 - да
  aPlat[ 1, 4 ] := 1234.98  // сумма 1
  aPlat[ 1, 5 ] := 0.0  // сумма 2
  aPlat[ 1, 6 ] := '344402247520'  // ИНН
  aPlat[ 1, 7 ] := ctod( '04.03.1973' )  // дата рождения
  aPlat[ 1, 8 ] := 21  // документ удостоверяющий личность код
  aPlat[ 1, 9 ] := '1806 920681'  // документ удостоверяющий личность серия и номер
  aPlat[ 1, 10 ] := ctod( '09.03.2004' )  // документ удостоверяющий личность дата выдачи
  aPlat[ 1, 11 ] := 'Сидоров Сидор Петрович' // ФИО плательщика
  aPlat[ 2, 1 ] := 2
  aPlat[ 2, 2 ] := 0  // номер корректировки
  aPlat[ 2, 3 ] := 0  // налогоплательщик и пациент одно лицо 0 - нет, 1 - да
  aPlat[ 2, 4 ] := 0.00  // сумма 1
  aPlat[ 2, 5 ] := 154254.0  // сумма 2
  aPlat[ 2, 6 ] := ''  // ИНН
  aPlat[ 2, 7 ] := ctod( '10.02.1962' )  // дата рождения
  aPlat[ 2, 8 ] := 21  // документ удостоверяющий личность код
  aPlat[ 2, 9 ] := '1818 458756'  // документ удостоверяющий личность серия и номер
  aPlat[ 2, 10 ] := ctod( '25.08.2019' )  // документ удостоверяющий личность дата выдачи
  aPlat[ 2, 11 ] := 'Сонина Евдокия Петровна'

  aPlat[ 2, 12 ] := '344205196771'  // ИНН
  aPlat[ 2, 13 ] := ctod( '20.09.1957' )  // дата рождения
  aPlat[ 2, 14 ] := 21  // документ удостоверяющий личность код
  aPlat[ 2, 15 ] := ''  // документ удостоверяющий личность серия и номер
  aPlat[ 2, 16 ] := ctod( '' )  // документ удостоверяющий личность дата выдачи
  aPlat[ 2, 17 ] := 'Бакулина тамара петровна'

  // создадим новый XML-документ
  oXmlDoc := hxmldoc():new()

  oXmlNode := hxmlnode():new( hb_OEMToANSI( 'Файл' ) )
  oXmlNode:SetAttribute( hb_OEMToANSI( 'ИдФайл' ), nameFileXML )
  oXmlNode:SetAttribute( hb_OEMToANSI( 'ВерсПрог' ), hb_OEMToANSI( 'ЧИП_МО ' ) + fs_version_short( _version() ) )
  oXmlNode:SetAttribute( hb_OEMToANSI( 'ВерсФорм' ), ver )
  oXmlDoc:add( oXmlNode )

  oXmlNodeDoc := hxmlnode():new( hb_OEMToANSI( 'Документ' ) )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'КНД' ), '1184043' )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'ДатаДок' ), transform( dt, '99.99.9999' ) )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'КодНО' ), fns_ID_POL )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( 'ОтчГод' ), str( year( dt ), 4 ) )
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
  if fns_PODPISANT == 0
    mo_add_xml_stroke( oPodp, hb_OEMToANSI( 'ПрПодп' ), '2' )
    node_fio_tip_fns( oPodp, fns_PREDST )

    oSved := oPodp:add( hxmlnode():new( hb_OEMToANSI( 'СвПред' ) ) )
    mo_add_xml_stroke( oSved, hb_OEMToANSI( 'НаимДок' ), Upper( fns_PREDST_DOC ) )
  else
    mo_add_xml_stroke( oPodp, hb_OEMToANSI( 'ПрПодп' ), '1' )
    if org:UrOrIp()
      node_fio_tip_fns( oPodp, org:Ruk_fio() )
    endif
  endif
    // Сведения о расходах
  for i := 1 to len( aPlat )  // временно
    oRash := oDoc:add( hxmlnode():new( hb_OEMToANSI( 'СведРасхУсл' ) ) )
    mo_add_xml_stroke( oRash, hb_OEMToANSI( 'НомерСвед' ), str( aPlat[ i, 1 ], 12 ) )
    mo_add_xml_stroke( oRash, hb_OEMToANSI( 'НомКорр' ), str( aPlat[ i, 2 ], 3 ) )
    mo_add_xml_stroke( oRash, hb_OEMToANSI( 'ПрПациент' ), str( aPlat[ i, 3 ], 1 ) )
    if aPlat[ i, 4 ] > 0
      mo_add_xml_stroke( oRash, hb_OEMToANSI( 'СуммаКод1' ), str( aPlat[ i, 4 ], 15, 2 ) )
    endif
    if aPlat[ i, 5 ] > 0
      mo_add_xml_stroke( oRash, hb_OEMToANSI( 'СуммаКод2' ), str( aPlat[ i, 5 ], 15, 2 ) )
    endif
    node_DAN_FIO_TIP( oRash, NALOG_PLAT, aPlat[ i, 6 ], aPlat[ i, 7 ], aPlat[ i, 11 ], aPlat[ i, 8 ], aPlat[ i, 9 ], aPlat[ i, 10 ] )

    if aPlat[ i, 3 ] == 0 // проверка на совпадение налогоплательщика и пациента
      node_DAN_FIO_TIP( oRash, PACIENT, aPlat[ i, 12 ], aPlat[ i, 13 ], aPlat[ i, 17 ], aPlat[ i, 14 ], aPlat[ i, 15 ], aPlat[ i, 16 ] )
    endif
  next

  oXmlDoc:save( nameFileXML + sxml )

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