#include 'common.ch'
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 06.08.24 �஢�ઠ ����⢮����� �ࠢ�� �� ������� ���
function exist_spravka( get, kod_kart, onePerson )
  // get - ��ꥪ� Get ��⥬�
  // kod_kart - ��� ��樥�� �� ����⥪�
  // onePerson - ���������⥫�騪 � ��樥�� ���� ��� ( 1- ��, 0 - ���)

  local nyear, str_find, tmp_select

//  nyear := get:original // ����稬 ���� �����
  nyear := get
  str_find := Str( kod_kart, 7 ) + Str( nyear, 4 ) + Str( onePerson, 1 )
  find ( str_find )
  if Found()
    Return func_error( 4, '�� ' + str( nyear, 4 ) + ' �ࠢ�� 㦥 ��ନ஢���!' )
  endif

  tmp_select := select()

  use_base( 'hum_p', 'hum_p' )
  find ( str( glob_kartotek, 7 ) )
  do while hum_p->kod_k == glob_kartotek
    if year( hum_p->K_DATA ) == nyear
//      mSumma := hum_p->cena - hum_p->sum_voz
      AAdd( aCheck, { hum_p->( recno() ), 1, hum_p->cena, hum_p->sum_voz } )
    endif
    hum_p->( dbSkip() )
  enddo
  hum_p->( dbCloseArea() )
  select( tmp_select )

  return .t.

// 06.08.24
function input_spravka_fns()

  Local str_sem  //, str_find, muslovie, mtitle
  Local buf := SaveScreen(), str_1, tmp_color := SetColor(), ;
    colget_menu := 'R/W', arr_m, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    mINN := space( 12 ), ;
    mSumma := 0.0, mSum1 := 0.0, mSum2 := 0.0, ;
    j := 0, i, k

  Private aCheck := {}

  If ( arr_m := input_year() ) == NIL
    Return Nil
  Endif

  If polikl1_kart() > 0
    use_base( 'reg_fns', 'fns' )
    if ! exist_spravka( arr_m[ 1 ], glob_kartotek, 1 )
      dbCloseAll()
      return nil
    endif
    mSumma := 0
    for i := 1 to len( aCheck )
      mSumma := mSumma + aCheck[ i, 3 ] - aCheck[ i, 4 ]
    next
    str_sem := '��ࠢ�� ��� 祫����� ' + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif

    Private ;
      mplat_fio := Space( 40 ), mplat_inn := Space( 12 ), ;
      mplat_pasport := Space( 15 ), ;  // ���㬥�� ���⥫�騪�
      MKOGDAVYD := CToD( '' ) // ��� � ����� �뤠� ��ᯮ�� �����������

    SetColor( cDataCGet )

    str_1 := '�� ' + str( arr_m[ 1 ] )
    j := 11
    Private gl_area := { j, 0, MaxRow() -1, MaxCol(), 0 }
    box_shadow( j, 0, MaxRow() -1, MaxCol(), color1, '��ࠢ�� ��� ��� ' + str_1, color8 )
    status_key( '^<Esc>^ - ��室;  ^<PgDn>^ - ������' )
    //
    Do While .t.
      j := 12
      @ j, 1 Clear To MaxRow() - 2, MaxCol() - 1
      @ ++j, 2 Say '����� ��� ' + str( arr_m[ 1 ], 4)
      @ j, 37 Say '��� ���⥫�騪�' Get mINN pict '999999999999'
      @ ++j, 2 Say '����祭��� �㬬� �� 祪�� �� ����ᮬ �����⮢ - ' + str( mSumma, 10, 2 )
      @ ++j, 2 Say '�㬬� 1 -' Get mSum1 pict '999999999.99'
      @ j, 37 Say '�㬬� 2 -' Get mSum2 pict '999999999.99'
      count_edit := myread(, @pos_read, ++k_read )
      If LastKey() != K_ESC
        If f_esc_enter( 1 )
          If mSum1 + mSum2 == 0.0
            func_error( 4, '��� ��।������ �㬬� ��室��!' )
            Loop
          Endif
          If mSum1 + mSum2 != mSumma
            func_error( 4, '���।������ �㬬� �� ࠢ�� �㬬� ��室�� �� 祪��!' )
            Loop
          Endif
          If mSumma == 0.0
            func_error( 4, '�㬬� ��室�� �� 祪�� ࠢ�� ���!' )
            Loop
          Endif
          if len( aCheck ) == 0
            func_error( 4, '���������� 祪� ������!' )
            Loop
          Endif
//        If Empty( mk_data )
//          func_error( 4, '�� ������� ��� ����砭�� ��祭��.' )
//          Loop
//        Endif
          mywait()
// ����襬
          add1rec( 7 )
          mkod := RecNo()
          fns->kod := mkod
          fns->kod_k := glob_kartotek
          fns->nyear := arr_m[ 1 ]
//          fns->num_s :=
          fns->version := 0
          fns->inn := mINN
          fns->attribut := 1  // ���⥫�騪, ��樥�� ���� ���
          fns->sum1 := mSum1
          fns->sum2 := mSum2
// � �����
          g_rlock( forever )
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

// 03.08.24
Function spravka_fns()

  Local buf, str_sem, str_find, muslovie, mtitle
  Local arr_blk

  Private fl_found

  If polikl1_kart() > 0

    str_sem := '��ࠢ�� ��� 祫����� ' + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif
    buf := SaveScreen()

    str_find := Str( glob_kartotek, 7 )
    muslovie := 'fns->kod_k == glob_kartotek'
    // R_Use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
    // use_base( 'hum_p', 'HUMAN' )
    use_base( 'xml_fns', 'xml' )
    use_base( 'reg_fns', 'fns' )
    Set Relation To kod_xml into xml
    find ( str_find )
    fl_found := Found()

    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find, -1 ) }, ;
      {| n | skippointer( n, muslovie ) }, ;
      str_find, muslovie ;
      }

    If ! fl_found
      Keyboard Chr( K_INS )
    Endif
    mtitle := '��ࠢ�� ��� ���: ' + glob_k_fio
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, 'defColumnSpravkaFNS', color0, mtitle, 'BG+/GR', ;
      .f., .t., arr_blk, , 'operspravkafns', , ;
      { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

    dbCloseAll()
    RestScreen( buf )
    g_sunlock( str_sem )
  Endif

  Return Nil

// 03.08.24
Function defcolumnspravkafns( oBrow )

  Local oColumn, s
  Local blk := {|| iif( Empty( fns->kod_xml ), { 5, 6 }, { 3, 4 } ) } // iif( human->cena > 0, { 1, 2 }, { 3, 4 } ) ) }
  Local tip_bank := { '��', '��', 'VI', 'MC', '����' }

  oColumn := TBColumnNew( ' ��� ;     ', {|| put_val( fns->nyear, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' ����� ;�ࠢ��', {|| put_val( fns->num_s, 7 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '���४-;�஢��', {|| put_val( fns->version, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '�㬬� 1;       ', {|| put_kop( fns->sum1, 12 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '�㬬� 2;       ', {|| put_kop( fns->sum2, 12 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '���;    ', {|| date_8( fns->date ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '�����;      ', {|| iif( fns->kod_xml <= 0, iif( fns->kod_xml == 0, '�� ��ࠡ�⠭�', '�ਭ��' ), xml->fname  ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  // If glob_kassa == 1 .and. mek_kassa == 1 // � ���� 01.12.2008
  // // oColumn := TBColumnNew('  ',{|| iif(human->sbank < 1, '    ',iif(human->sbank == human->cena, '�/� ','�/��')) })
  // oColumn := TBColumnNew( '    ', ;
  // {|| iif( human->sbank < 1, '    ', ;
  // tip_bank[ human->fr_tipkart + 1 ] + iif( human->sbank == human->cena, ' ', '�' ) ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // oColumn := TBColumnNew( '    ', ;
  // {|| iif( human->tip_usl == PU_PLAT, { '    ', Str( human->kv_cia, 4 ), ' ' }[ human->is_kas + 1 ], ;
  // iif( human->tip_usl == PU_PR_VZ, '�/� ', '��� ' ) ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // Elseif glob_kassa == 1 .and. mek_kassa == 2 // � �� �� �� � ����� 01.12.2008
  // oColumn := TBColumnNew( '� ��.;������', {|| put_val( human->n_kvit, 5 ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // oColumn := TBColumnNew( '    ', ;
  // {|| iif( human->tip_usl == PU_PLAT, { '    ', Str( human->kv_cia, 4 ), ' ' }[ human->is_kas + 1 ], ;
  // iif( human->tip_usl == PU_PR_VZ, '�/� ', '��� ' ) ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // Elseif glob_pl_reg == 1
  // oColumn := TBColumnNew( '� ��.;������', {|| put_val( human->n_kvit, 5 ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // //
  // oColumn := TBColumnNew( '� ���-;⠭樨', {|| put_val( human->kv_cia, 6 ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // //
  // oColumn := TBColumnNew( '  ���; ������', {|| date_8( c4tod( human->pdate ) ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // Endif
  // //
  // oColumn := TBColumnNew( ' ��砫�; ��祭��', {|| date_8( human->n_data ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // //
  // oColumn := TBColumnNew( '����砭.; ��祭��', {|| date_8( human->k_data ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // //
  // If mem_naprvr == 2
  // oColumn := TBColumnNew( '����.;���', {|| put_val( ret_tabn( human->kod_vr ), 5 ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // Endif
  // //
  // oColumn := TBColumnNew( '�⮨�����; ��祭��', {|| put_kop( human->cena, 10 ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // //
  // If glob_kassa == 1
  // oColumn := TBColumnNew( '  ������;  �����', {|| put_kop( human->sum_voz, 10 ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // Else
  // oColumn := TBColumnNew( ' ', {|| iif( human->tip_usl == PU_D_SMO, '�', iif( human->tip_usl == PU_PR_VZ, '�', ' ' ) ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // Endif
  // //
  // oColumn := TBColumnNew( '  ���;�������', {|| date_8( human->date_close ) } )
  // oColumn:colorBlock := blk
  // oBrow:addcolumn( oColumn )
  // If is_task( X_KASSA )
  // @ MaxRow() -1, 0 Say PadC( '<Esc>��室 <Enter>।���஢���� <Ins>���������� <Del>㤠����� <F8>������', 80 ) Color 'N/W'
  // s := '<Ctrl+Enter>���� ��� <F9>������� <F3>���⠭樨 <F4>��ᬮ�� 祪�� <F10>����� 祪�'
  // Else
  // @ MaxRow() -1, 0 Say PadC( '<Esc> ��室 <Enter> ।���஢���� <Ins> ���������� <Del> 㤠�����', 80 ) Color 'N/W'
  // s := '<Ctrl+Enter> ���� ��� <F8> ������ <F9> ������� <F10> ����� 祪�'
  // Endif
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<Del>', '<Ctrl+Enter>', '<F3>', '<F4>', '<F8>', '<F9>', '<F10>' }, 'R/W' )

  Return Nil

// 03.08.24
Function operspravkafns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, ;
    ln_chek := 0, t_hum_rec := 0, ;
    tip_kart := 2 //, ;
//    err_close := '���� ��� ������. ����� ࠧ��� ⮫쪮 ������������ ��⥬�!'
  Private ldate_voz, lsum_voz, lfr_data, lfr_time

  Do Case
  Case nKey == K_F3
    // view_p_kvit(K_F3)
  Case nKey == K_F4
    // view_p_kvit(K_F4)
  Case nKey == K_F9
  Case nKey == K_INS  // .or. (nKey == K_ENTER .and. human->kod_k > 0)
    // if nKey == K_ENTER
    // func_error( 4, err_close )
    // return flag
    // endif
    If nKey == K_INS .and. ! fl_found
      ColorWin( 7, 0, 7, 79, 'N/N', 'W+/N' )
      ColorWin( 7, 0, 7, 79, 'N/N', 'BG+/B' )
      ColorWin( 7, 0, 7, 79, 'N/N', 'GR+/R' )
    Endif
    // rec := recno()
    flag := input_spr_fns( nKey )
  Case nKey == K_DEL
  Case nKey == K_CTRL_RET
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 05.08.24
function collect_pay( nYear )

  local tmp_sel := select()

  hb_alert( '����ࠥ� 祪�' )
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
  
// 05.08.24
Function input_spr_fns( nKey )

  Local buf := SaveScreen(), tmp_color := SetColor(), str_1, ;
    colget_menu := 'R/W', i, k, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    mYear := year( date() ), mINN := space( 12 ), ;
    mSum1 := 0.0, mSum2 := 0, ;
    ret := -1, j := 0

  Private r1 := 11
  Private aCheck := {}, ;
    mncheck := '�����', m1ncheck := 0, ;
    mSumma := 0.0, mSummaVozvrat := 0.0, ;
    nStrSum, ;
    mplat_fio := Space( 40 ), mplat_inn := Space( 12 ), ;
    mplat_adres := Space( 50 ), ; // ���� ���⥫�騪�
    mplat_pasport := Space( 15 ), ;  // ���㬥�� ���⥫�騪�
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := CToD( '' ) // ��� � ����� �뤠� ��ᯮ�� �����������

  If mem_plsoput == 2
    --r1
  Endif
  mywait()
    
  If nKey == K_ENTER
  Endif
//  r_use( dir_server + 'hum_plat', dir_server + 'hum_plat', 'KPLAT' )
//  find ( Str( human->( RecNo() ), 7 ) )
//  If Found()
//    mplat_adres   := KPLAT->ADRES
//    mplat_pasport := KPLAT->PASPORT
//    m1kemvyd  := Kplat->kemvyd   // ��� �뤠� ���㬥�� �����������
//    mkogdavyd := kplat->kogdavyd // ����� �뤠� ���㬥�� �����������
//  Endif
//  KPLAT->( dbCloseArea() )
  //
//  mtip_usl := inieditspr( A__MENUVERT, menu_kb, m1tip_usl )
//  mlpu := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', m1lpu )
//  motd := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', m1otd )
//  MKEMVYD := inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', M1KEMVYD )
//  If m1tip_usl == PU_D_SMO
//    mpr_smo := inieditspr( A__POPUPMENU, dir_server + 'p_d_smo', m1pr_smo )
//  Elseif m1tip_usl == PU_PR_VZ
//    mpr_smo := inieditspr( A__POPUPMENU, dir_server + 'p_pr_vz', m1pr_smo )
//  Endif
//  str_1 := ' �ࠢ�� ��� ���'
  If nKey == K_INS
    str_1 := '����������' // + str_1
  Else
    str_1 := '।���஢����' // + str_1
  Endif
  Private gl_area := { r1, 0, MaxRow() -1, MaxCol(), 0 }
  box_shadow( r1, 0, MaxRow() -1, MaxCol(), color1, '��ࠢ�� ��� ��� - ' + str_1, color8 )
  status_key( '^<Esc>^ - ��室;  ^<PgDn>^ - ������' )
  //
  Do While .t.
    SetColor( cDataCGet )
    j := r1 + 1
    @ j, 1 Clear To MaxRow() -2, MaxCol() -1
    @ ++j, 2 Say '����� ���' Get mYear pict '9999'  // ;
//      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c, sys_date,, X_PLATN ) } }, A__FUNCTION,,, .f. ) }
    @ j, 37 Say '��� ���⥫�騪�' Get mINN pict '999999999999'
    if nKey == K_INS
      @ ++j, 3 say '������ 祪�� ...' get mncheck ;
          reader { | x | menu_reader( x, { { | | collect_pay( mYear ) } } ,A__FUNCTION, , , .f. ) }
    endif
    nStrSum := ++j
    @ j, 2 Say '����祭��� �㬬� - '  // + str( mSumma, 10, 2 )
    @ j, 37 Say '�㬬� �����⮢ - '  // + str( mSummaVozvrat, 10, 2 ) // ;
    @ ++j, 2 Say '�㬬� 1 -' Get mSum1 pict '999999999.99'
    @ j, 37 Say '�㬬� 1 -' Get mSum2 pict '999999999.99'
      //      reader {| x| menu_reader( x, menu_kb, A__MENUVERT,,, .f. ) } ;
//      valid {| g, o| val_tip_usl( g, o ) }
//    get1_p_kart()  // ��⠫�� Get'�
//    If nKey == K_ENTER .and. !ver_pub_date( mk_data, .t. )
//      Keyboard Chr( K_ESC )
//    Endif
    count_edit := myread(, @pos_read, ++k_read )
    If LastKey() != K_ESC
//      err_date_diap( mn_data, '��� ��砫� ��祭��' )
//      err_date_diap( mk_data, '��� ����砭�� ��祭��' )
      If f_esc_enter( 1 )
//        If m1lpu == 0
//          func_error( 4, '�� ������� ��祡��� ��०�����!' )
//          Loop
//        Endif
//        If Empty( mk_data )
//          func_error( 4, '�� ������� ��� ����砭�� ��祭��.' )
//          Loop
//        Endif
        mywait()
//        Select HUMAN
//        If nKey == K_INS
//          addrec( 7 )
//          human->kod_k := glob_kartotek
//          fl_found := .t.
//        Else
//          g_rlock( forever )
//        Endif
// ����襬
        Unlock
//        human->( dbCommit() )
//        g_use( dir_server + 'hum_plat', dir_server + 'hum_plat', 'KPLAT' )
//        If Len( AllTrim( mplat_adres ) ) > 2 .or. Len( AllTrim( mplat_pasport ) ) > 2
//          find ( Str( human->( RecNo() ), 7 ) )
//          If !Found()
//            Append Blank
//          Else
//            g_rlock( forever )
//          Endif
//          KPLAT->kod     := human->( RecNo() )
//          KPLAT->ADRES   := mplat_adres
//          KPLAT->PASPORT := mplat_pasport
//          KPLAT->kemvyd := m1kemvyd     // ��� �뤠� ���㬥�� �����������
//          KPLAT->kogdavyd := mkogdavyd  // ����� �뤠� ���㬥�� �����������
//        Else
//          find ( Str( human->( RecNo() ), 7 ) )
//          If Found()
//            deleterec( .t. )
//          Endif
//        Endif
//        KPLAT->( dbCloseArea() )
//        Select HUMAN
        write_work_oper( glob_task, OPER_LIST, iif( nKey == K_INS, 1, 2 ), 1, count_edit )
        ret := 0
      Endif
    Endif
    If nKey == K_INS .and. ! fl_found
      ret := 1
    Endif
    Exit
  Enddo
//  Select HUMAN
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 03.08.24
Function reestr_fns()

  hb_Alert( '������� ���' )

  Return Nil

// 03.08.24
// ��뢠���� � '����� ��㣨(��⮯����\����)/���ଠ��/��ࠢ�� ��� ���'
Function inf_fns( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { ;
      '���� ������', ;
      '������� ��� ���' ;
      }
    mas_msg := { ;
      '��ନ஢���� � ��ᬮ�� �뤠���� �ࠢ�� �� ��樥���', ;
      '��ᬮ�� ᯨ᪠ � ᮧ����� ॥��஢ ��� ��ࠢ�� � ���' ;
      }
    mas_fun := { ;
      'inf_fns(11)', ;
      'inf_fns(12)' ;
      }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    input_spravka_fns() // spravka_fns()
  Case k == 12
    reestr_fns()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil
