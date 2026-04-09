#include 'hbsqlit3.ch'
#include 'function.ch'
//#include 'dict_error.ch'

#require 'hbsqlit3'

// 28.03.26
function make_f031( source, destination )

  local _f031 := { ;
    { 'IDMO',      'C',  17, 0 }, ;
    { 'NAM_MOP',   'C', 250, 0 }, ;
    { 'NAM_MOK',   'C',  50, 0 }, ;
    { 'OID_MO',    'C',  35, 0 }, ;
    { 'ADDR_J_GAR','C',  36, 0 } ;
  }
  local oXmlDoc, oXmlNode
  local cAlias, nameRef, nfile, k, j
  local mOKTMO  //  , mIDMO

  cAlias := 'F031'
  nameRef := 'F031.xml'
  nfile := source + nameRef
  If ! hb_vfExists( nfile )
    out_error( FILE_NOT_EXIST, nfile )
    Return Nil
  Else
    out_utf8_to_str( nameRef + ' - F031 Единый реестр медицинских организаций (ERMO)', 'RU866' )	
  Endif

  dbcreate( destination + '_mo_f031', _f031 )
  dbUseArea( .t., , destination + '_mo_f031', cAlias, .f., .f. )
  ( cAlias )->(dbGoTop())

  oXmlDoc := HXMLDoc():Read( nfile )
  IF Empty( oXmlDoc:aItems )
    ( cAlias )->( dbCloseArea() )
  else
    k := Len( oXmlDoc:aItems[ 1 ]:aItems )
    for j := 1 to k
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      if "ZAP" == Upper( oXmlNode:title )
//        mIDMO := mo_read_xml_stroke( oXmlNode, 'IDMO', )
//        if SubStr( mIDMO, 1, 2 ) == '34'
        mOKTMO := mo_read_xml_stroke( oXmlNode, 'OKTMO', )
        if SubStr( mOKTMO, 1, 2 ) == '18'
          ( cAlias )->( dbAppend() )
          ( cAlias )->IDMO := mo_read_xml_stroke( oXmlNode, 'IDMO', )
          ( cAlias )->NAM_MOP := substr( mo_read_xml_stroke( oXmlNode, 'NAM_MOP', ), 1, 250 )
          ( cAlias )->NAM_MOK := substr( mo_read_xml_stroke( oXmlNode, 'NAM_MOK', ), 1, 50 )
          ( cAlias )->OID_MO := mo_read_xml_stroke( oXmlNode, 'OID_MO', )
          ( cAlias )->ADDR_J_GAR := mo_read_xml_stroke( oXmlNode, 'ADDR_J_GAR', )
        endif
      endif
    next j
  endif
  out_obrabotka_eol()

  ( cAlias )->( dbCloseArea() )

  return Nil

// 25.01.26
Function make_f032( source, destination )

  local _f032 := { ;
    { 'UIDMO',    'C',  17, 0 }, ;
    { 'IDMO',     'C',  17, 0 }, ;
    { 'MCOD',     'C',   6, 0 }, ;
    { 'OSP',      'C',   1, 0 }, ;
    { 'NAMEMOK',  'C',  50, 0 }, ;
    { 'NAMEMOP',  'C', 150, 0 }, ;
    { 'ADDRESS',  'C', 250, 0 }, ;
    { 'DBEGIN',   'D',   8, 0 }, ;
    { 'DEND',     'D',   8, 0 } ;
  }
//    { 'NAME_MOK', 'C',  50, 0 }, ;
//    { 'NAME_MOP', 'C', 150, 0 }  ;

  local oXmlDoc, oXmlNode
  local cAlias, nameRef, nfile, k, j
  local mMcod

  cAlias := 'F032'
  nameRef := 'F032.xml'
  nfile := source + nameRef
  If ! hb_vfExists( nfile )
    out_error( FILE_NOT_EXIST, nfile )
    Return Nil
  Else
    out_utf8_to_str( nameRef + ' - Реестр медицинских организаций, осуществляющих деятельность в сфере обязательного медицинского страхования (TRMO) ', 'RU866' )	
  Endif

  dbcreate( destination + '_mo_f032', _f032)
  dbUseArea( .t.,, destination + '_mo_f032', cAlias, .f., .f. )
  ( cAlias )->(dbGoTop())

  oXmlDoc := HXMLDoc():Read( nfile )
  IF Empty( oXmlDoc:aItems )
    ( cAlias )->( dbCloseArea() )
  else
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    k := Len( oXmlDoc:aItems[ 1 ]:aItems )
    FOR j := 1 TO k
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      IF "ZAP" == Upper( oXmlNode:title )
//        mOSP := mo_read_xml_stroke( oXmlNode, 'OSP', )
        mMcod := mo_read_xml_stroke( oXmlNode, 'MCOD', )
//        if SubStr( mMcod, 1, 2 ) == '34'  // 
          ( cAlias )->( dbAppend() )
          ( cAlias )->UIDMO := mo_read_xml_stroke( oXmlNode, 'UIDMO', )
          ( cAlias )->IDMO := mo_read_xml_stroke( oXmlNode, 'IDMO', )
          ( cAlias )->MCOD := mMcod // mo_read_xml_stroke( oXmlNode, 'MCOD', )
          ( cAlias )->OSP := mo_read_xml_stroke( oXmlNode, 'OSP', )
          ( cAlias )->NAMEMOK := mo_read_xml_stroke( oXmlNode, 'NAM_MOK', )
          ( cAlias )->NAMEMOP := mo_read_xml_stroke( oXmlNode, 'NAM_MOP', )
          ( cAlias )->ADDRESS := mo_read_xml_stroke( oXmlNode, 'JURADDRESS_ADDRESS', )
          ( cAlias )->DBEGIN := CToD( mo_read_xml_stroke( oXmlNode, 'DATEBEG', ) )
          ( cAlias )->DEND := CToD( mo_read_xml_stroke( oXmlNode, 'DATEEND', ) )
//        endif
      ENDIF
    NEXT j
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
  endif
  out_obrabotka_eol()

  ( cAlias )->( dbCloseArea() )

  return nil

// 25.01.26
Function make_f033( source, destination )

  local _f033 := { ;
    { 'UIDSPMO',  'C',  17, 0 }, ;
    { 'IDSPMO',   'C',  17, 0 }, ;
    { 'NAM_SK',   'C',  80, 0 }, ;
    { 'NAM_SPMO', 'C', 150, 0 },  ;
    { 'OSP',      'C',   1, 0 } ;
  }
  local oXmlDoc, oXmlNode
  local cAlias, nameRef, nfile, k, j
  local mUIDSPMO, mOSP

  cAlias := 'F033'
  nameRef := 'F033.xml'
  nfile := source + nameRef
  If ! hb_vfExists( nfile )
    out_error( FILE_NOT_EXIST, nfile )
    Return Nil
  Else
    out_utf8_to_str( nameRef + ' - F033 Справочник структурных подразделений медицинских организаций, осуществляющих деятельность в сфере обязательного медицинского страхования (SPMO)', 'RU866' )	
  Endif

  dbcreate( destination + '_mo_f033', _f033)
  dbUseArea( .t., , destination + '_mo_f033', cAlias, .f., .f. )
  ( cAlias )->(dbGoTop())

  oXmlDoc := HXMLDoc():Read( nfile )
  IF Empty( oXmlDoc:aItems )
    ( cAlias )->( dbCloseArea() )
  else
    k := Len( oXmlDoc:aItems[ 1 ]:aItems )
    FOR j := 1 TO k
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      IF "ZAP" == Upper( oXmlNode:title )
        mUIDSPMO := mo_read_xml_stroke( oXmlNode, 'UIDSPMO', )
        mOSP := mo_read_xml_stroke( oXmlNode, 'OSP', )
        if SubStr( mUIDSPMO, 1, 2 ) == '34' .and. mOSP == '0'
          ( cAlias )->( dbAppend() )
          ( cAlias )->UIDSPMO := mUIDSPMO
          ( cAlias )->IDSPMO := mo_read_xml_stroke( oXmlNode, 'IDSPMO', )
          ( cAlias )->OSP := mOSP
          ( cAlias )->NAM_SK := substr( mo_read_xml_stroke( oXmlNode, 'NAM_SK_SPMO', ), 1, 80 )
          ( cAlias )->NAM_SPMO := substr( mo_read_xml_stroke( oXmlNode, 'NAM_SPMO', ), 1, 150 )
        endif
      ENDIF
    NEXT j
  endif
  out_obrabotka_eol()

  ( cAlias )->( dbCloseArea() )

  return nil

// 28.03.26
function make_f034( source, destination )

  local _f034 := { ;
    { 'UIDSPMO',  'C',  17, 0 }, ;
    { 'IDADDRESS','N',  19, 0 }, ;
    { 'MPVID',    'N',   4, 0 }, ;
    { 'MPUSL',    'N',   2, 0 }, ;
    { 'MPROF',    'N',   3, 0 }  ;
  }
  local oXmlDoc, oXmlNode
  local cAlias, nameRef, nfile, k, j
  local mUIDSPMO

  cAlias := 'F034'
  nameRef := 'F034.xml'
  nfile := source + nameRef
  If ! hb_vfExists( nfile )
    out_error( FILE_NOT_EXIST, nfile )
    Return Nil
  Else
    out_utf8_to_str( nameRef + ' - F034 Справочник видов, условий и профилей медицинской помощи, оказываемой МО (VUP)', 'RU866' )	
  Endif

  dbcreate( destination + '_mo_f034', _f034 )
  dbUseArea( .t., , destination + '_mo_f034', cAlias, .f., .f. )
  ( cAlias )->(dbGoTop())

  oXmlDoc := HXMLDoc():Read( nfile )
  IF Empty( oXmlDoc:aItems )
    ( cAlias )->( dbCloseArea() )
  else
    k := Len( oXmlDoc:aItems[ 1 ]:aItems )
    for j := 1 to k
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      if "ZAP" == Upper( oXmlNode:title )
        mUIDSPMO := mo_read_xml_stroke( oXmlNode, 'UIDSPMO', )
        if SubStr( mUIDSPMO, 1, 2 ) == '34'
          ( cAlias )->( dbAppend() )
          ( cAlias )->UIDSPMO := mUIDSPMO
          ( cAlias )->IDADDRESS := val( mo_read_xml_stroke( oXmlNode, 'IDADDRESS', ) )
          ( cAlias )->MPVID := val( mo_read_xml_stroke( oXmlNode, 'MPVID', ) )
          ( cAlias )->MPUSL := val( mo_read_xml_stroke( oXmlNode, 'MPUSL', ) )
          ( cAlias )->MPROF := val( mo_read_xml_stroke( oXmlNode, 'MPROF', ) )
        endif
      endif
    next j
  endif
  out_obrabotka_eol()

  ( cAlias )->( dbCloseArea() )

  return Nil

// 26.03.26
function make_f037( source, destination )

  local _f037 := { ;
    { 'IDMO',      'C',  17, 0 }, ;
    { 'OID_MO',    'C',  35, 0 }, ;
    { 'MCOD',      'C',   6, 0 }, ;
    { 'UIDMO',     'C',  17, 0 }, ;
    { 'N_DOC',     'C',  32, 0 } ;
  }
  local oXmlDoc, oXmlNode
  local cAlias, nameRef, nfile, k, j
  local mMCOD

  cAlias := 'F037'
  nameRef := 'F037.xml'
  nfile := source + nameRef
  If ! hb_vfExists( nfile )
    out_error( FILE_NOT_EXIST, nfile )
    Return Nil
  Else
    out_utf8_to_str( nameRef + ' - F037 лицензий медицинских организаций (LicMO)', 'RU866' )	
  Endif

  dbcreate( destination + '_mo_f037', _f037 )
  dbUseArea( .t., , destination + '_mo_f037', cAlias, .f., .f. )
  ( cAlias )->(dbGoTop())

  oXmlDoc := HXMLDoc():Read( nfile )
  IF Empty( oXmlDoc:aItems )
    ( cAlias )->( dbCloseArea() )
  else
    k := Len( oXmlDoc:aItems[ 1 ]:aItems )
    for j := 1 to k
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      if "ZAP" == Upper( oXmlNode:title )
        mMCOD := mo_read_xml_stroke( oXmlNode, 'MCOD', )
        if SubStr( mMCOD, 1, 2 ) == '34'
          ( cAlias )->( dbAppend() )
          ( cAlias )->MCOD := mMCOD
          ( cAlias )->IDMO := mo_read_xml_stroke( oXmlNode, 'IDMO', )
          ( cAlias )->OID_MO := mo_read_xml_stroke( oXmlNode, 'OID_MO', )
          ( cAlias )->UIDMO := mo_read_xml_stroke( oXmlNode, 'UIDMO', )
          ( cAlias )->N_DOC := mo_read_xml_stroke( oXmlNode, 'N_DOC', )
        endif
      endif
    next j
  endif
  out_obrabotka_eol()

  ( cAlias )->( dbCloseArea() )

  return Nil

// 26.03.26
function make_f038( source, destination )

  local _f038 := { ;
    { 'IDADDRESS', 'N',  19, 0 }, ;
    { 'UIDMO',     'C',  17, 0 }, ;
    { 'UIDSPMO',   'C',  17, 0 }, ;
    { 'N_DOC',     'C',  32, 0 }, ;
    { 'ADDR',      'C', 250, 0 }, ;
    { 'ADDR_GAR',  'C',  36, 0 } ;
  }
  local oXmlDoc, oXmlNode
  local cAlias, nameRef, nfile, k, j
  local mUIDMO   //  , mMCOD

  cAlias := 'F038'
  nameRef := 'F038.xml'
  nfile := source + nameRef
  If ! hb_vfExists( nfile )
    out_error( FILE_NOT_EXIST, nfile )
    Return Nil
  Else
    out_utf8_to_str( nameRef + ' - F038 Справочник адресов оказания медицинской помощи (ADDRMP)', 'RU866' )	
  Endif

  dbcreate( destination + '_mo_f038', _f038 )
  dbUseArea( .t., , destination + '_mo_f038', cAlias, .f., .f. )
  ( cAlias )->(dbGoTop())

  oXmlDoc := HXMLDoc():Read( nfile )
  IF Empty( oXmlDoc:aItems )
    ( cAlias )->( dbCloseArea() )
  else
    k := Len( oXmlDoc:aItems[ 1 ]:aItems )
    for j := 1 to k
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      if "ZAP" == Upper( oXmlNode:title )
//        mMCOD := mo_read_xml_stroke( oXmlNode, 'MCOD', )
//        if SubStr( mMCOD, 1, 2 ) == '34'
        mUIDMO := mo_read_xml_stroke( oXmlNode, 'UIDMO', )
        if SubStr( mUIDMO, 1, 2 ) == '34'
          ( cAlias )->( dbAppend() )
          ( cAlias )->IDADDRESS := val( mo_read_xml_stroke( oXmlNode, 'IDADDRESS', ) )
          ( cAlias )->UIDMO := mo_read_xml_stroke( oXmlNode, 'UIDMO', )
          ( cAlias )->UIDSPMO := mo_read_xml_stroke( oXmlNode, 'UIDSPMO', )
          ( cAlias )->N_DOC := mo_read_xml_stroke( oXmlNode, 'N_DOC', )
          ( cAlias )->ADDR := mo_read_xml_stroke( oXmlNode, 'ADDR', )
          ( cAlias )->ADDR_GAR := mo_read_xml_stroke( oXmlNode, 'ADDR_GAR', )
        endif
      endif
    next j
  endif
  out_obrabotka_eol()

  ( cAlias )->( dbCloseArea() )

  return Nil
