if !empty( hZip := HB_ZIPOPEN( dir_archiv + zip_file ) )
  // ᭠砫� ��稥 䠩��
  ar := { sfile_begin, ;
        tools_ini, ;
        f_stat_lpu, ;
        dir_server + 'f39_nast' + sini, ;
        dir_server + 'usl1year' + smem, ;
        dir_server + 'error' + stxt }
  if ! empty( zip_xml_mo )
    aadd( ar, cur_dir + zip_xml_mo )
  endif
  if ! empty( zip_xml_tf )
    aadd( ar, cur_dir + zip_xml_tf )
  endif
  if ! empty( zip_napr_mo )
    aadd( ar, cur_dir + zip_napr_mo )
  endif
  if ! empty( zip_napr_tf )
    aadd( ar, cur_dir + zip_napr_tf )
  endif
  for i := 1 To Len( ar )
    
    if hb_vfExists( ar[ i ] )
      stat_msg('���������� � ��娢 䠩�� ' + ar[ i ] )
      HB_ZipStoreFile( hZip, ar[ i ], StripPath( ar[ i ] ) )  //, cPassword )
    endif
  next
  hGauge := GaugeNew( , , { 'N/BG*', 'N/BG*', 'N/BG*' }, '�������� ��娢� ' + zip_file, .t. )
  GaugeDisplay( hGauge )
  // � ⥯��� ���� ������
  for i := 1 To Len( array_files_DB )
    cFile := upper( array_files_DB[ i ] ) + sdbf
    GaugeUpdate( hGauge, i / Len( array_files_DB ) )
    if hb_vfExists( dir_server + cFile )
      stat_msg( '���������� � ��娢 䠩�� ' + cFile )
      HB_ZipStoreFile( hZip, dir_server + cFile, cFile )  //, cPassword )
    endif
  next
  hb_vfErase( sfile_end )
  hb_memowrit( sfile_end, full_date( sys_date ) + ' ' + hour_min(seconds()) + ' ' + hb_OemToAnsi(fio_polzovat))
  if hb_vfExists( sfile_end )
    HB_ZipStoreFile( hZip, sfile_end, sfile_end ) //, cPassword )
  endif
  // � ⥯��� 䠩�� WQ...
  arr_f := {}
  y := year( sys_date )
  // ⮫쪮 ⥪�騩 ���
  scandirfiles( dir_server, 'mo_wq' + substr( str( y, 4 ), 3 ) + '*' + sdbf, { | x | aadd( arr_f, x ) } )
  for i := 1 To Len( arr_f )
    cFile := StripPath( arr_f[ i ] )  // ��� 䠩�� ��� ���
    HB_ZipStoreFile( hZip, arr_f[ i ], cFile )  //, cPassword )
  next
  CloseGauge( hGauge ) // ���஥� ���� �⮡ࠦ����
  HB_ZIPCLOSE( hZip )
