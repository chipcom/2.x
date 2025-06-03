#include 'common.ch'
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define COMPRESSION 3
#define YEAR_COMPRESSION 2

// 25.03.24 १�ࢭ�� ����஢���� ॥��� �� FTP
function XML_files_to_FTP( name_xml, kod )

  local zip_file, i
  local out_dir := dir_server() + dir_XML_MO() + hb_ps()
  local xml_file := out_dir + AllTrim( name_xml ) + szip()
  local in_dir := dir_server() + dir_XML_TF() + hb_ps()
  local fileName
  local ar := {}
  local ar_hrt := {}

  if empty( name_xml ) .or. ! ( hb_FileExists( xml_file ) )
    func_error( 4, "��祣� ��ࠢ����!" )
    return nil
  endif
  mywait( '��ࠢ�� ॥��� "' + name_xml + '" �� FTP-�ࢥ� �㦡� �����প�' )
  zip_file := 'reestr_' + name_xml
  AAdd( ar, xml_file )

  Select MO_XML
  Index On FNAME to ( cur_dir() + 'tmp_xml' ) ;
    For reestr == kod .and. Between( TIP_IN, _XML_FILE_FLK, _XML_FILE_SP ) .and. Empty( TIP_OUT )
  Go Top
  Do While !Eof()
    fileName := in_dir + RTrim( mo_xml->FNAME ) + szip()
    if hb_FileExists( fileName )
      AAdd( ar, fileName )
      if upper( substr( RTrim( mo_xml->FNAME ), 1, 3 ) ) == 'HRT'
        AAdd( ar_hrt, mo_xml->kod )
      endif
    endif
    Skip
  Enddo
  Set Index To
  if len( ar_hrt ) > 0
    g_use( dir_server() + 'schet_', , 'SCHET_' )
    for i := 1 to len( ar_hrt )
      Index On XML_REESTR to ( cur_dir() + 'tmp_sch' ) ;
        For xml_reestr == ar_hrt[ i ]
      Go Top
      Do While ! Eof()
        fileName := out_dir + RTrim( schet_->name_xml ) + szip()
        if hb_FileExists( fileName )
          AAdd( ar, fileName )
        endif
        Skip
      enddo
      set index to
    next
    schet_->( dbCloseArea() )
    Select REES
  endif
  create_zip_to_ftp( zip_file, ar, 'reestr' )
  return nil

// 25.03.24 १�ࢭ�� ����஢���� 䠩�� �訡�� �� FTP
function errorFileToFTP()

  local zip_file
  local ar := {}
  
  zip_file := 'mo' + AllTrim( glob_mo[ _MO_KOD_TFOMS ] ) + '_error'
  AAdd( ar, dir_server() + 'error.txt' )
  create_zip_to_ftp( zip_file, ar, 'Error' )
  return nil

// 25.03.24 ᮧ����� zip-䠩�� � ��ࠢ�� �� FTP �ࢥ�
function create_zip_to_ftp( name, ar, strPath )

  local nLen, aGauge, lCompress, fl := .f., zip_file
  local name_file, ft

  // ᮧ����� 䠩� � ��������� ����樭᪮� �࣠����樨
  name_file := cur_dir() + '��������_��.txt'
  ft := tfiletext():new( name_file, , , , )
  ft:add_string( hb_main_curOrg:Name_Tfoms )
  ft := nil
  AAdd( ar, name_file )
  zip_file := cur_dir() + name + Lower( szip() )
  nLen := Len( ar )
  aGauge := gaugenew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, '�������� ��娢� ' + zip_file, .t. )
  lCompress := hb_ZipFile( zip_file, ar, COMPRESSION, ;
    {| cFile, nPos | gaugedisplay( aGauge ), stat_msg( '���������� � ��娢 䠩�� ' + hb_FNameNameExt( cFile ) + ' ( ' + AllTrim( lstr( nPos ) ) + ' �� ' + AllTrim( lstr( nLen ) ) + ' )' ) }, ;
    .t., , .f., , {| nPos, nLen | gaugeupdate( aGauge, nPos / nLen ) } )
  closegauge( aGauge ) // ���஥� ���� �⮡ࠦ���� ���㭪�
  If ! lCompress
    func_error( 4, '�������� �訡�� �� ��娢�஢���� 䠩��.' ) 
  else
    mywait( '��ࠢ�� "' + zip_file + '" �� FTP-�ࢥ� �㦡� �����প�' )
    If filetoftp( zip_file, strPath )
      stat_msg( '���� ' + zip_file + ' �ᯥ譮 ��ࠢ��� �� �ࢥ�!' )
      fl := .t.
    Else
      stat_msg( '�訡�� ��ࠢ�� 䠩�� ' + zip_file + ' �� �ࢥ�!' )
    Endif
    hb_vfErase( zip_file )
  Endif
  return nil

// 22.03.24 ����� ०��� १�ࢭ��� ����஢���� �� ����
Function m_copy_db( par )
  // par - 1 - १�ࢭ�� ����� �� ���
  // 2 - १�ࢭ�� ����� �� FTP-�ࢥ�
  // 3 - ���१�ࢨ஢����
  Local zip_file

  If ( zip_file := create_zip( par, '' ) ) == nil
    Return Nil
  Endif
  // ���쭥��� ࠡ�� � ��娢��
  If par == 1
    saveto( cur_dir() + zip_file )
  Elseif par == 2
    mywait( '��ࠢ�� "' + zip_file + '" �� FTP-�ࢥ� �㦡� �����প�' )
    If filetoftp( zip_file )
      stat_msg( '���� ' + zip_file + ' �ᯥ譮 ��ࠢ��� �� �ࢥ�!' )
    Else
      stat_msg( '�訡�� ��ࢪ� 䠩�� ' + zip_file + ' �� �ࢥ�!' )
    Endif
    hb_vfErase( zip_file )
  Endif
  mybell( 2, OK )
  Return Nil

// 22.03.24 ����� ०��� १�ࢭ��� ����஢���� �� f_end()
Function m_copy_db_from_end( del_last, spath )

  Local hCurrent, hFile, nSize, fl := .t., ta, zip_file, ;
    i, k, arr_f, dir_archiv := cur_dir() + 'OwnChipArchiv'

  Default del_last To .f., spath To ''

  If !Empty( spath )
    dir_archiv := AllTrim( spath )
    If Right( dir_archiv, 1 ) == hb_ps()
      dir_archiv := Left( dir_archiv, Len( dir_archiv ) -1 )
    Endif
  Endif
  If !hb_DirExists( dir_archiv )
    If hb_DirCreate( dir_archiv ) != 0
      Return func_error( 4, '���������� ᮧ���� �����⠫�� ��� ��娢�஢����!' )
    Endif
  Endif
  dir_archiv += hb_ps()
  // �� 㦥 ��࠭�� ��娢� - � ���ᨢ
  arr_f := Directory( dir_archiv + 'mo*' + szip() )
  ta := Directory( dir_archiv + 'mo*' + schip() )
  For i := 1 To Len( ta )
    AAdd( arr_f, AClone( ta[ i ] ) )
  Next
  If ( k := Len( arr_f ) ) > 0
    // ����㥬 䠩��
    ASort( arr_f, , , {| x, y | iif( x[ 3 ] == y[ 3 ], x[ 4 ] < y[ 4 ], x[ 3 ] < y[ 3 ] ) } )
    // �������� ࠧ��� ��᫥����� ��娢�
    nSize := arr_f[ k, 2 ] * 1.5 // ��� ���񦭮�� १�ࢨ�㥬 ����� � 1.5 ࠧ�
    // �஢��塞 ���� � �६� ��᫥����� 䠩��
    If arr_f[ k, 3 ] == sys_date // �᫨ ᥣ���� 㦥 ��࠭﫨
      hCurrent := Int( Val( SecToTime( Seconds() ) ) )
      hFile := Int( Val( arr_f[ k, 4 ] ) )
      fl := ( del_last .or. ( hCurrent - hFile ) > 1 ) // ��諮 �������� ����� 1 ��
      If fl
        hb_vfErase( dir_archiv + arr_f[ k, 1 ] ) // 㤠��� ᥣ����譨� ��娢
        --k
      Endif
    Endif
  Endif
  If fl .and. k > 4 // ��⠢�塞 ⮫쪮 4 ��᫥���� ��娢�
    For i := 1 To k -4
      hb_vfErase( dir_archiv + arr_f[ i, 1 ] ) // 㤠��� ��譨� ��娢
    Next
  Endif
  If fl .and. k > 0 .and. DiskSpace() < nSize // �������筮 ���� ��� ��娢�஢����
    For i := 1 To k
      If hb_vfExists( dir_archiv + arr_f[ i, 1 ] )
        hb_vfErase( dir_archiv + arr_f[ i, 1 ] ) // 㤠��� ��譨� ��娢
        If DiskSpace() > nSize // 㦥 �����筮 ����?
          Exit  // ��室 �� 横��
        Endif
      Endif
    Next
  Endif
  If fl
    zip_file := create_zip( 3, dir_archiv )
  Endif
  Return fl

// 20.11.21
Function fillzip( arr_f, sFileName )

  Local aGauge
  Local lCompress, nLen

  If Empty( arr_f )
    sFileName := ''
  Else
    hb_vfErase( sFileName )

    nLen := Len( arr_f )
    aGauge := gaugenew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, '�������� ��娢� ' + hb_FNameNameExt( sFileName ), .t. )
    // lCompress := hb_ZipFile( sFileName, arr_f, COMPRESSION, ;
    // , ;
    // .t., , .f., ,  )
    lCompress := hb_ZipFile( sFileName, arr_f, COMPRESSION, ;
      {| cFile, nPos | gaugedisplay( aGauge ), stat_msg( '���������� � ��娢 䠩�� ' + hb_FNameNameExt( cFile ) + ' ( ' + AllTrim( lstr( nPos ) ) + ' �� ' + AllTrim( lstr( nLen ) ) + ' )' ) }, ;
      .t., , .f., , {| nPos, nLen | gaugeupdate( aGauge, nPos / nLen ) } )
    If ! lCompress
      sFileName := ''
    Endif
    closegauge( aGauge ) // ���஥� ���� �⮡ࠦ���� ���㭪�
  Endif
  Return sFileName

// 22.08.24
Function create_zip( par, dir_archiv )

  Static sast := '*', sfile_begin := '_begin.txt', sfile_end := '_end.txt'
  Local arr_f, ar
  Local blk := {| x | AAdd( arr_f, x ) }
  Local i, fl := .t., aGauge, y
  Local cFile, nLen
  Local zip_file, lCompress
  Local buf := SaveScreen()
  Local zip_xml_mo, zip_xml_tf, zip_napr_mo, zip_napr_tf, zip_xml_fns
  local afterDate := BoY( AddMonth( date(), - ( 12 * YEAR_COMPRESSION ) ) )
  // Local blk := {| x | f_aadd_copy_db( arr_f, x ) }
  // Local time_zip := 0, t1

  zip_xml_mo := zip_xml_tf := zip_napr_mo := zip_napr_tf := zip_xml_fns := ''
  If par == 1
    If ! g_slock1task( sem_task, sem_vagno )  // ����� ����㯠 �ᥬ
      func_error( 4, '� ����� ������ ࠡ���� ��㣨� �����. ����஢���� ����饭�!' )
      Return Nil
    Endif
  Endif
  If par == 3 .or. f_esc_enter( '१�ࢭ��� ����஢����' )

    f_message( { '��������! ��������� ��娢 ���� ������.', ;
      '', ;
      '�� ��������� ࠧ��襭�� ������', ;
      '�� ���뢠�� �����!' }, , 'GR+/R', 'W+/R', 13 )
    // �ନ�㥬 ����� ��娢��
    zip_file := 'mo' + AllTrim( glob_mo[ _MO_KOD_TFOMS ] ) + '_' + DToS( sys_date ) + ;
      Lower( iif( par != 3, szip(), schip() ) )
    zip_xml_mo := dir_XML_MO() + szip()
    zip_xml_tf := dir_XML_TF() + szip()
    zip_napr_mo := dir_NAPR_MO() + szip()
    zip_napr_tf := dir_NAPR_TF() + szip()
    zip_xml_fns := 'XML_FNS' + szip()
    hb_vfErase( sfile_begin )
    hb_MemoWrit( sfile_begin, full_date( sys_date ) + ' ' + Time() + ' ' + hb_OEMToANSI( fio_polzovat ) )
    //
    arr_f := {}
    scandirfiles_for_backup( dir_server() + dir_XML_MO() + hb_ps(), sast + szip(), blk, afterDate )
    scandirfiles_for_backup( dir_server() + dir_XML_MO() + hb_ps(), sast + scsv(), blk, afterDate )
    zip_xml_mo := fillzip( arr_f, zip_xml_mo )
    //
    arr_f := {}
    scandirfiles_for_backup( dir_server() + dir_XML_TF() + hb_ps(), sast + szip(), blk, afterDate )
    scandirfiles_for_backup( dir_server() + dir_XML_TF() + hb_ps(), sast + scsv(), blk, afterDate )
    scandirfiles_for_backup( dir_server() + dir_XML_TF() + hb_ps(), sast + stxt(), blk, afterDate )
    zip_xml_tf := fillzip( arr_f, zip_xml_tf )
    //
    arr_f := {}
    scandirfiles_for_backup( dir_server() + dir_NAPR_MO() + hb_ps(), sast + szip(), blk, afterDate )
    scandirfiles_for_backup( dir_server() + dir_NAPR_MO() + hb_ps(), sast + stxt(), blk, afterDate )
    zip_napr_mo := fillzip( arr_f, zip_napr_mo )
    //
    arr_f := {}
    scandirfiles_for_backup( dir_server() + dir_NAPR_TF() + hb_ps(), sast + szip(), blk, afterDate )
    scandirfiles_for_backup( dir_server() + dir_NAPR_TF() + hb_ps(), sast + stxt(), blk, afterDate )
    zip_napr_tf := fillzip( arr_f, zip_napr_tf )
    //
    arr_f := {}
    scandirfiles_for_backup( dir_XML_FNS(), sast + sxml(), blk, afterDate )
    zip_xml_fns := fillzip( arr_f, zip_xml_fns )
    hb_vfErase( dir_archiv + zip_file )
    // ᭠砫� ��稥 䠩��
    ar := { sfile_begin, ;
      tools_ini, ;
      f_stat_lpu, ;
      dir_server() + 'f39_nast' + sini(), ;
      dir_server() + 'usl1year' + smem(), ;
      dir_server() + 'error.txt' }
    If ! Empty( zip_xml_mo )
      AAdd( ar, cur_dir() + zip_xml_mo )
    Endif
    If ! Empty( zip_xml_tf )
      AAdd( ar, cur_dir() + zip_xml_tf )
    Endif
    If ! Empty( zip_napr_mo )
      AAdd( ar, cur_dir() + zip_napr_mo )
    Endif
    If ! Empty( zip_napr_tf )
      AAdd( ar, cur_dir() + zip_napr_tf )
    Endif
    If ! Empty( zip_xml_fns )
      AAdd( ar, cur_dir() + zip_xml_fns )
    Endif
    For i := 1 To Len( array_files_DB )
      cFile := Upper( array_files_DB[ i ] ) + sdbf()
      If hb_vfExists( dir_server() + cFile )
        AAdd( ar, dir_server() + cFile )
      Endif
    Next
    // � ⥯��� 䠩�� WQ...
    arr_f := {}
    y := Year( sys_date )
    // ⮫쪮 ⥪�騩 ���
    scandirfiles_for_backup( dir_server(), 'mo_wq' + SubStr( Str( y, 4 ), 3 ) + '*' + sdbf(), {| x | AAdd( arr_f, x ) }, afterDate )
    For i := 1 To Len( arr_f )
      AAdd( ar, arr_f[ i ] )
    Next
    nLen := Len( ar )
    aGauge := gaugenew( , , { 'R/BG*', 'R/BG*', 'R/BG*' }, '�������� ��娢� ' + zip_file, .t. )
    // lCompress := hb_ZipFile( dir_archiv + zip_file, ar, COMPRESSION, ;
    // , ;
    // .t., , .f., , )
    lCompress := hb_ZipFile( dir_archiv + zip_file, ar, COMPRESSION, ;
      {| cFile, nPos | gaugedisplay( aGauge ), stat_msg( '���������� � ��娢 䠩�� ' + hb_FNameNameExt( cFile ) + ' ( ' + AllTrim( lstr( nPos ) ) + ' �� ' + AllTrim( lstr( nLen ) ) + ' )' ) }, ;
      .t., , .f., , {| nPos, nLen | gaugeupdate( aGauge, nPos / nLen ) } )
    closegauge( aGauge ) // ���஥� ���� �⮡ࠦ���� ���㭪�
    If ! lCompress
      fl := func_error( 4, '�������� �訡�� �� ��娢�஢���� ���� ������.' )
    Endif
    hb_vfErase( sfile_end )
    hb_MemoWrit( sfile_end, full_date( sys_date ) + ' ' + Time() + ' ' + hb_OEMToANSI( fio_polzovat ) )
    RestScreen( buf )
  Endif
  // 㤠�塞 ���㦭� ��娢�
  If ! Empty( zip_xml_mo )
    hb_vfErase( zip_xml_mo )
  Endif
  If ! Empty( zip_xml_tf )
    hb_vfErase( zip_xml_tf )
  Endif
  If !Empty( zip_napr_mo )
    hb_vfErase( zip_napr_mo )
  Endif
  If !Empty( zip_napr_tf )
    hb_vfErase( zip_napr_tf )
  Endif
  If !Empty( zip_xml_fns )
    hb_vfErase( zip_xml_fns )
  Endif
  // ࠧ�襭�� ����㯠 �ᥬ
  If par == 1
    g_sunlock( sem_vagno )
  Endif
  Keyboard ''
  If ! fl
    Return Nil
  Endif
  Return zip_file

// 07.11.23
// Function f_aadd_copy_db( arr_f, x )

  // static curYear
  // Local fl := .t., s, y

  // if isnil(curYear)
  //   curYear := Year(date()) - 2000
  // Endif

  // x := Upper( x )
  // If eq_any( Right( x, 4 ), szip(), stxt() )
  //   s := strippath( x )
  //   // ॥����, ��� � ���
  //   If eq_any( Left( s, 3 ), 'FRM', 'HRM' ) .or. eq_any( Left( s, 4 ), 'PFRM', 'PHRM' ) ;
  //       .or. eq_any( Left( s, 2 ), 'I0', 'FM', 'HM', 'AT', 'AS', 'DT', 'DS' )
  //     y := Int( Val( Left( AfterAtNum( '_', s ), 2 ) ) )
  //     fl := ( y > 19 )  // � 2020 ����
  //   Elseif eq_any( Left( s, 3 ), 'FRT', 'HRT' )
  //     y := Int( Val( SubStr( s, 14, 2 ) ) )
  //     fl := ( y > 19 )  // � 2020 ����
  //   elseif eq_any( left( lower(s), 3), 'r01', 'r05', 'd01')
  //     y := Int( Val( Left( AfterAtNum( '_', s ), 2 ) ) )
  //     fl := ( y > (curYear - 2) )  // �� ���㤭�� 2 ����
  //   elseif left( lower(s), 3) == 'r11'
  //     y := Int( Val( Left( AfterAtNum( '_', s ), 2 ) ) )
  //     fl := ( y > (curYear - 1) )  // �� ���㤭�� 1 ���
  //   elseif left( lower(s), 2) == 'sz'
  //     y := Int( Val( SubStr( s, 12, 2 ) ) )
  //     fl := ( y > (curYear - 2) )  // �� ���㤭�� 2 ����
  //   Endif
  // Endif
  // If fl
    // AAdd( arr_f, x )
  // Endif

  // Return Nil

// 06.11.23 � ��, �� � ScanFiles, �� �� ����� ��४�ਨ cPath
FUNCTION scandirfiles_for_backup( cPath, cFilespec, blk, afterDate )

  LOCAL cFile

  DEFAULT cPath TO '', cFilespec TO '*.*'
  default afterDate to BoY( AddMonth( date(), -12 ) )  //���� ���
  cFile := FILESEEK( cPath + cFileSpec , 32 )
  DO WHILE !EMPTY( cFile )
    if FileDate() >= afterDate
      eval( blk, cPath + cFile )         // �맮� ����� ���� ��� ������� 䠩��
    endif
    cFile := FILESEEK()              // ᫥���騩 䠩�
  ENDDO
  RETURN NIL                         // �����頥��� ���祭�� �������
  