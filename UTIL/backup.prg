#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define COMPRESSION 3
#define YEAR_COMPRESSION 2

// 05.05.21 ����� ०��� १�ࢭ��� ����஢���� �� ����
Function m_copy_db( par )
  // par - 1 - १�ࢭ�� ����� �� ���
  // 2 - १�ࢭ�� ����� �� FTP-�ࢥ�
  // 3 - ���१�ࢨ஢����
  Local s, zip_file

  If ( zip_file := create_zip( par, '' ) ) == nil
    Return Nil
  Endif
  // ���쭥��� ࠡ�� � ��娢��
  If par == 1
    saveto( cur_dir + zip_file )
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

// 05.05.21 ����� ०��� १�ࢭ��� ����஢���� �� f_end()
Function m_copy_db_from_end( del_last, spath )
  Local hCurrent, hFile, nSize, fl := .t., ta, zip_file, ;
    i, k, arr_f, dir_archiv := cur_dir + 'OwnChipArchiv'

  Default del_last To .f., spath To ''

  If !Empty( spath )
    dir_archiv := AllTrim( spath )
    If Right( dir_archiv, 1 ) == cslash
      dir_archiv := Left( dir_archiv, Len( dir_archiv ) -1 )
    Endif
  Endif
  If !hb_DirExists( dir_archiv )
    If hb_DirCreate( dir_archiv ) != 0
      Return func_error( 4, '���������� ᮧ���� �����⠫�� ��� ��娢�஢����!' )
    Endif
  Endif
  dir_archiv += cslash
  // �� 㦥 ��࠭�� ��娢� - � ���ᨢ
  arr_f := Directory( dir_archiv + 'mo*' + szip )
  ta := Directory( dir_archiv + 'mo*' + schip )
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
  Local hZip, aGauge, cFile
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

// 06.11.23
Function create_zip( par, dir_archiv )
  Static sast := '*', sfile_begin := '_begin.txt', sfile_end := '_end.txt'
  Local arr_f, ar
  Local blk := {| x | f_aadd_copy_db( arr_f, x ) }
  Local hZip, i, cPassword, fl := .t., aGauge, s, y
  Local cFile, nLen
  Local zip_file
  Local buf := SaveScreen()
  Local zip_xml_mo, zip_xml_tf, zip_napr_mo, zip_napr_tf

  // Local time_zip := 0, t1

  // t1 := seconds()

  zip_xml_mo := zip_xml_tf := zip_napr_mo := zip_napr_tf := ''
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
      Lower( iif( par != 3, szip, schip ) )

    zip_xml_mo := dir_XML_MO + szip
    zip_xml_tf := dir_XML_TF + szip
    zip_napr_mo := dir_NAPR_MO + szip
    zip_napr_tf := dir_NAPR_TF + szip

    hb_vfErase( sfile_begin )
    hb_MemoWrit( sfile_begin, full_date( sys_date ) + ' ' + Time() + ' ' + hb_OEMToANSI( fio_polzovat ) )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_XML_MO + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_XML_MO + cslash, sast + scsv, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_xml_mo := fillzip( arr_f, zip_xml_mo )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_XML_TF + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_XML_TF + cslash, sast + scsv, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_XML_TF + cslash, sast + stxt, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_xml_tf := fillzip( arr_f, zip_xml_tf )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_NAPR_MO + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_NAPR_MO + cslash, sast + stxt, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_napr_mo := fillzip( arr_f, zip_napr_mo )

    //
    arr_f := {}
    scandirfiles_for_backup( dir_server + dir_NAPR_TF + cslash, sast + szip, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
    scandirfiles_for_backup( dir_server + dir_NAPR_TF + cslash, sast + stxt, blk, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )

    zip_napr_tf := fillzip( arr_f, zip_napr_tf )

    hb_vfErase( dir_archiv + zip_file )

    // ᭠砫� ��稥 䠩��
    ar := { sfile_begin, ;
      tools_ini, ;
      f_stat_lpu, ;
      dir_server + 'f39_nast' + sini, ;
      dir_server + 'usl1year' + smem, ;
      dir_server + 'error' + stxt }
    If ! Empty( zip_xml_mo )
      AAdd( ar, cur_dir + zip_xml_mo )
    Endif
    If ! Empty( zip_xml_tf )
      AAdd( ar, cur_dir + zip_xml_tf )
    Endif
    If ! Empty( zip_napr_mo )
      AAdd( ar, cur_dir + zip_napr_mo )
    Endif
    If ! Empty( zip_napr_tf )
      AAdd( ar, cur_dir + zip_napr_tf )
    Endif

    For i := 1 To Len( array_files_DB )
      cFile := Upper( array_files_DB[ i ] ) + sdbf
      If hb_vfExists( dir_server + cFile )
        AAdd( ar, dir_server + cFile )
      Endif
    Next

    // � ⥯��� 䠩�� WQ...
    arr_f := {}
    y := Year( sys_date )
    // ⮫쪮 ⥪�騩 ���
    scandirfiles_for_backup( dir_server, 'mo_wq' + SubStr( Str( y, 4 ), 3 ) + '*' + sdbf, {| x | AAdd( arr_f, x ) }, AddMonth(date(), -(12 * YEAR_COMPRESSION)) )
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

    // time_zip := seconds() - t1

    // if fl .and. time_zip > 0
    // n_message({'', '�६� ᮧ����� १�ࢭ�� ����� - ' + sectotime(time_zip)}, , ;
    // color1, cDataCSay, , , color8)
    // endif

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

  // ࠧ�襭�� ����㯠 �ᥬ
  If par == 1
    g_sunlock( sem_vagno )
  Endif
  Keyboard ''
  If ! fl
    Return Nil
  Endif

  Return zip_file

// 04.05.21
Function f_aadd_copy_db( arr_f, x )

  Local fl := .t., s, y

  x := Upper( x )
  If eq_any( Right( x, 4 ), szip, stxt )
    s := strippath( x )
    // ॥����, ��� � ���
    If eq_any( Left( s, 3 ), 'FRM', 'HRM' ) .or. eq_any( Left( s, 4 ), 'PFRM', 'PHRM' ) ;
        .or. eq_any( Left( s, 2 ), 'I0', 'FM', 'HM', 'AT', 'AS', 'DT', 'DS' )
      y := Int( Val( Left( AfterAtNum( '_', s ), 2 ) ) )
      fl := ( y > 19 )  // � 2020 ����
    Elseif eq_any( Left( s, 3 ), 'FRT', 'HRT' )
      y := Int( Val( SubStr( s, 14, 2 ) ) )
      fl := ( y > 19 )  // � 2020 ����
    Endif
  Endif
  If fl
    AAdd( arr_f, x )
  Endif

  Return Nil

// 06.11.23 � ��, �� � ScanFiles, �� �� ����� ��४�ਨ cPath
FUNCTION scandirfiles_for_backup(cPath, cFilespec, blk, afterDate)
  LOCAL cFile

  DEFAULT cPath TO '', cFilespec TO '*.*'
  default afterDate to AddMonth(date(), -12)  //���� ���
  cFile := FILESEEK(cPath + cFileSpec , 32)
  DO WHILE !EMPTY(cFile)
    if FileDate() >= afterDate
      eval(blk, cPath + cFile)         // �맮� ����� ���� ��� ������� 䠩��
    endif
    cFile := FILESEEK()              // ᫥���騩 䠩�
  ENDDO
  RETURN NIL                         // �����頥��� ���祭�� �������
  