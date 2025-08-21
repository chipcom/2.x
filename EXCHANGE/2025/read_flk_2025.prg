#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 21.08.25 зачитать протокол ФЛК во временные файлы новая версия
Function protokol_flk_tmpfile_2025( arr_f, aerr )

  Local adbf, ii, j, s, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
    { 'FNAME',  'C', 27, 0 }, ;
    { 'FNAME1', 'C', 26, 0 }, ;
    { 'FNAME2', 'C', 26, 0 }, ;
    { 'KOL2',   'N',  6, 0 };   // кол-во ошибок
  }
//  { 'DATE_F', 'D',  8, 0 }, ;
  dbCreate( cur_dir() + 'tmp1file', adbf, , .t., 'TMP1' )
//  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
//  Append Blank
  tmp1->( dbAppend() )

  adbf := { ; // элементы PR
  { 'TIP',        'N',  1, 0 }, ;  // тип(номер) обрабатываемого файла
  { 'OSHIB',      'N',  3, 0 }, ;  // код ошибки T005
  { 'SOSHIB',     'C', 12, 0 }, ;  // код ошибки Q015, Q022
  { 'IM_POL',     'C', 20, 0 }, ;  // имя поля, в котором ошибка
  { 'ZN_POL',     'C', 100, 0 }, ;  // Значение поля, вызвавшее ошибку. Не заполняется, если ошибка относится к файлу в целом
  { 'NSCHET',     'C', 15, 0 }, ;  // Номер счета, в котором обнаружена ошибка
  { 'BAS_EL',     'C', 20, 0 }, ;  // имя базового элемента
  { 'N_ZAP',     'C', 36, 0 }, ;  // Номер записи, в одном из полей которой обнаружена ошибка
  { 'ID_PAC',     'C', 36, 0 }, ;  // Код записи о пациенте, в которой обнаружена ошибка. Не заполняется только в том случае, если ошибка относится к файлу в целом.
  { 'IDCASE',     'N', 11, 0 }, ;  // Номер законченного случая, в котором обнаружена ошибка(указывается, если ошибка обнаружена внутри тега ?Z_SL?, в том числе во входящих в него элементах ?SL? и услугах)
  { 'SL_ID',     'C', 36, 0 }, ;  // Идентификатор случая, в котором обнаружена ошибка (указывается, если ошибка обнаружена внутри тега ?SL?, в том числе во входящих в него услугах)
  { 'IDSERV',     'C', 36, 0 }, ;  // Номер услуги, в которой обнаружена ошибка (указывается, если ошибка обнаруживается внутри тега ?USL?)
  { 'COMMENT',    'C', 250, 0 }, ;  // описание ошибки
  { 'N_ZAP',      'N',  6, 0 }, ;  // поле из первичного реестра
  { 'KOD_HUMAN',  'N',  7, 0 };   // код по БД листов учёта
  }
  dbCreate( cur_dir() + 'tmp2file', adbf, , .t., 'TMP2' ) // элементы PR
//  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2

  dbCreate( cur_dir() + 'tmp22fil', adbf ) // доп.файл, если по одному пациенту > 1 листа учёта

  For ii := 1 To Len( arr_f )
    // т.к. в ZIP'е два XML-файла, второй файл также прочитать
    If Upper( Right( arr_f[ ii ], 4 ) ) == sxml() .and. ValType( oXmlDoc := hxmldoc():read( _tmp_dir1() + arr_f[ ii ] ) ) == 'O'
      For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
        oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
        Do Case
        Case 'FNAME' == oXmlNode:title
          tmp1->FNAME := mo_read_xml_tag( oXmlNode, aerr, .t. )
        Case 'FNAME_I' == oXmlNode:title
          If ii == 1
            tmp1->FNAME1 := mo_read_xml_tag( oXmlNode, aerr, .t. )
          Else
            tmp1->FNAME2 := mo_read_xml_tag( oXmlNode, aerr, .t. )
          Endif
//        Case 'DATE_F' == oXmlNode:title
//          tmp1->DATE_F := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr, .f. ) )
        Case 'PR' == oXmlNode:title
//          Select TMP2
//          Append Blank
          dbSelectArea( 'TMP2' )
          tmp2->( dbAppend() )
          tmp2->tip := ii
          s := AllTrim( mo_read_xml_stroke( oXmlNode, 'OSHIB', aerr ) )
          If Len( s ) > 3 .or. '.' $ s
            tmp2->SOSHIB := s
          Else
            tmp2->OSHIB := Val( s )
          Endif
          tmp2->IM_POL  := mo_read_xml_stroke( oXmlNode, 'IM_POL', aerr, .f. )
          tmp2->ZN_POL  := mo_read_xml_stroke( oXmlNode, 'ZN_POL', aerr, .f. )
          tmp2->NSCHET  := mo_read_xml_stroke( oXmlNode, 'NSCHET', aerr, .f. )
          tmp2->BAS_EL  := mo_read_xml_stroke( oXmlNode, 'BAS_EL', aerr, .f. )
          tmp2->N_ZAP  := mo_read_xml_stroke( oXmlNode, 'N_ZAP', aerr, .f. )
          tmp2->ID_PAC  := mo_read_xml_stroke( oXmlNode, 'ID_PAC', aerr, .f. )
          tmp2->IDCASE  := Val( mo_read_xml_stroke( oXmlNode, 'IDCASE', aerr, .f. ) )
          tmp2->SL_ID  := mo_read_xml_stroke( oXmlNode, 'SL_ID', aerr, .f. )
          tmp2->IDSERV  := mo_read_xml_stroke( oXmlNode, 'IDSERV', aerr, .f. )
          tmp2->COMMENT := mo_read_xml_stroke( oXmlNode, 'COMMENT', aerr, .f. )
          If ! Empty( tmp2->BAS_EL )   // .and. !Empty( tmp2->ID_BAS )
            is_err_FLK := .t.
            tmp1->KOL2++
          Endif
        Endcase
      Next j
    Endif
  Next ii
//  Commit
  dbCommitAll()
  Return is_err_FLK
