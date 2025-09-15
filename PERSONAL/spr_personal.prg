#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 15.08.17 редактирование справочника персонала
Function edit_pers()

  Local buf, fl := .f., arr_blk, str_sem := 'Редактирование персонала'

  If g_slock( str_sem )
    buf := save_maxrow()
    mywait()
    Private tmp_V002 := create_classif_ffoms( 0, 'V002' ) // PROFIL
    Private str_find := '1', muslovie := 'p2->kod > 0'
    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| dbGoBottom() }, ;
      {| n| skippointer( n, muslovie ) }, ;
      str_find, muslovie;
      }
    If use_base( 'mo_pers' )
      Index On iif( kod > 0, '1', '0' ) + Upper( fio ) to ( cur_dir() + 'tmp_pers' )
      Set Index to ( cur_dir() + 'tmp_pers' ), ( dir_server() + 'mo_pers' )
      find ( str_find )
      If !Found()
        Keyboard Chr( K_INS )
      Endif
      Private mr := T_ROW
      rest_box( buf )
      alpha_browse( T_ROW, 0, MaxRow() -1, 79, 'f1edit_pers', color0, , , , , arr_blk, , 'f2edit_pers', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t. } )
    Endif
    Close databases
    g_sunlock( str_sem )
    rest_box( buf )
  Else
    func_error( 4, err_slock() )
  Endif
  Return Nil

// 12.09.25
Function f1edit_pers( oBrow )

  Static ak := { '   ', 'вр.', 'ср.', 'мл.', 'пр.' }
  Local oColumn, nf := 27, n := 19, ;
    blk := {|| iif( between_date( dbegin, dend ), ;
    iif( P2->tab_nom > 0, { 1, 2 }, { 5, 6 } ), ;
    { 3, 4 } ) }

  oColumn := TBColumnNew( Center( 'Ф.И.О.', nf ), {|| Left( P2->fio, nf ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Таб.№', {|| put_val( P2->tab_nom, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
//  oColumn := TBColumnNew( PadC( 'СНИЛС', 14 ), {|| Transform( p2->SNILS, picture_pf ) } )
  oColumn := TBColumnNew( PadC( 'СНИЛС', 14 ), {|| Transform_SNILS( p2->SNILS ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кат', {|| ak[ P2->kateg + 1 ] } )
  oColumn:colorBlock := blk
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew(center('Специальность', n), {|| padr(ret_tmp_prvs(p2->prvs, p2->prvs_new), n)})
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Специальность', n ), ;
    {|| PadR( inieditspr( A__MENUVERT, getv021(), p2->prvs_021 ), n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Свод.;таб.№', {|| put_val( P2->svod_nom, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать' )
//  @ mr, 45 Say ' <F2> - поиск <F3> - сортировка' Color 'GR+/BG'
//  mark_keys( { '<F2>', '<F3>' }, 'R/BG' )
  @ mr, 45 Say ' <F2> - поиск' Color 'GR+/BG'
  mark_keys( { '<F2>', '<F3>' }, 'R/BG' )
  Return Nil

// 12.09.25
Function f2edit_pers( nKey, oBrow )

  Static gmenu_kateg := { { 'врач                ', 1 }, ;
    { 'средний мед.персонал', 2 }, ;
    { 'младший мед.персонал', 3 }, ;
    { 'прочие              ', 4 } }
  Static menu_vr_kateg := { { 'без категории   ', 0 }, ;
    { '2-ая категория  ', 1 }, ;
    { '1-ая категория  ', 2 }, ;
    { 'высшая категория', 3 } }
  Static osn_sovm := { { 'основная работа', 0 }, ;
    { 'совмещение     ', 1 } }
  Local buf, fl := .f., rec, j, k, tmp_color, mkod, r, ret := -1
  local i, max_nom, iSort, s
//  local name_file := cur_dir() + 'personal.txt'
  local typeSort := { ;
    'по фамилии          ', ;
    'по табельному номеру', ;
    'по специальности    ', ;
    'по отделению        ' ;
  }

  Do Case
  Case nKey == K_F2
    Return f4edit_pers( K_F2 )
  Case nKey == K_F3
/*    iSort := 1
    if ( iSort := popup_prompt( 10, 20, iSort, typeSort ) ) == 0
      return ret
    endif
    if iSort == 1
      Index On iif( kod > 0, '1', '0' ) + Upper( fio ) to ( cur_dir() + 'tmp_pers' )
      Set Index to ( cur_dir() + 'tmp_pers' ), ( dir_server() + 'mo_pers' )
      GOTO Top
    elseif iSort == 2
      Index On tab_nom to ( cur_dir() + 'tmp_persTN' )
      Set Index to ( cur_dir() + 'tmp_persTN' ), ( dir_server() + 'mo_pers' )
      GOTO Top
    elseif iSort == 3
      Index On prvs_021 to ( cur_dir() + 'tmp_pers21' )
      Set Index to ( cur_dir() + 'tmp_pers21' ), ( dir_server() + 'mo_pers' )
      GOTO Top
    elseif iSort == 4
      Index On otd to ( cur_dir() + 'tmp_persOTD' )
      Set Index to ( cur_dir() + 'tmp_persOTD' ), ( dir_server() + 'mo_pers' )
      GOTO Top
    endif
    Return 0
*/
  Case nKey == K_F9
    If ( j := f_alert( { PadC( 'Выберите порядок сортировки при печати', 60, '.' ) }, ;
        { ' По ФИО ', ' По таб.номеру ' }, ;
        1, 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' ) ) == 0
      Return ret
    Endif
    rec := p2->( RecNo() )
    buf := save_maxrow()
    
    spr_personal( 1, j )
/*    mywait()
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    sh := 81
    HH := 60
    add_string( '' )
    add_string( Center( 'Список работающего персонала с табельными номерами', sh ) )
    add_string( '' )
    If j == 1
      Set Order To 1
      find ( str_find )
    Else
      Set Order To 2
      Go Top
    Endif

    Do While !Eof()
      If iif( j == 2, kod > 0, .t. ) .and. between_date( dbegin, dend )
        verify_ff( HH, .t., sh )
        s := Str( p2->tab_nom, 5 ) + ;
          iif( Empty( p2->svod_nom ), Space( 7 ), PadL( '(' + lstr( p2->svod_nom ) + ')', 7 ) ) + ;
          ' ' + PadR( p2->fio, 35 ) + ' ' + Transform( p2->SNILS, picture_pf ) + ' ' + ;
          ret_tmp_prvs( p2->prvs, p2->prvs_new )
        add_string( s )
      Endif
      Skip
    Enddo

    Set Order To 2
    Go Bottom
    max_nom := p2->tab_nom
    verify_ff( HH - 3, .t., sh )
    add_string( Replicate( '=', sh ) )
    add_string( Center( 'Список свободных табельных номеров:', sh ) )
    s := ''
    k := 0
    For i := 1 To max_nom
      find ( Str( i, 5 ) )
      If !Found()
        s += lstr( i ) + ', '
        If Len( s ) > sh
          verify_ff( HH, .t., sh )
          add_string( s )
          s := ''
          If ++k > 10
            add_string( '...' )
            Exit
          Endif
        Endif
      Endif
    Next
    If !Empty( s )
      add_string( s )
    Endif
    Set Order To 1
    FClose( fp )
    viewtext( name_file, , , , .t., , , 2 )
*/
    rest_box( buf )
    Goto ( rec )
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. kod > 0 )
    Save Screen To buf
    Private mfio := Space( 50 ), m1uch := 0, m1otd := 0, m1kateg := 1, ;
      much, motd, mname_dolj := Space( 30 ), mkateg, mstavka := 1, ;
      mvid, m1vid := 0, mtab_nom := 0, msvod_nom := 0, mkod_dlo := 0, ;
      mvr_kateg, m1vr_kateg := 0, msnils := Space( 11 ), mprofil, m1profil := 0, fl_profil := .f., ;
      mDOLJKAT := Space( 15 ), mD_KATEG := CToD( '' ), ;
      mSERTIF, m1sertif := 0, mD_SERTIF := CToD( '' ), ;
      mPRVS, m1prvs := 0, muroven := 0, motdal := 0, ;
      mDBEGIN := BoY( sys_date ), mDEND := CToD( '' ), ;
      gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
      mprvs_021, m1prvs_021 := 0
    If nKey == K_ENTER
      mkod       := RecNo()
      mfio       := p2->fio
      mtab_nom   := p2->tab_nom
      msvod_nom  := p2->svod_nom
      m1uch      := p2->uch
      m1otd      := p2->otd
      m1kateg    := p2->kateg
      mname_dolj := PadR( p2->name_dolj, 30 )
      mstavka    := p2->stavka
      m1vid      := p2->vid
      mtab_nom   := p2->tab_nom
      msvod_nom  := p2->svod_nom
      mkod_dlo   := p2->kod_dlo
      m1vr_kateg := p2->vr_kateg
      mDOLJKAT   := p2->DOLJKAT
      mD_KATEG   := p2->D_KATEG
      m1sertif   := p2->sertif
      mD_SERTIF  := p2->D_SERTIF
      m1prvs     := ret_new_spec( p2->prvs, p2->prvs_new )
      m1prvs_021 := p2->prvs_021
      If FieldPos( 'profil' ) > 0
        fl_profil := .t.
        m1profil := p2->profil
      Endif
      muroven    := p2->uroven
      motdal     := p2->otdal
      msnils     := p2->snils
      mDBEGIN    := p2->DBEGIN
      mDEND      := p2->DEND
    Endif
    If mstavka <= 0
      mstavka := 1
    Endif
    much      := inieditspr( A__POPUPBASE, dir_server() + 'mo_uch', m1uch )
    motd      := inieditspr( A__POPUPBASE, dir_server() + 'mo_otd', m1otd )
    mkateg    := inieditspr( A__MENUVERT, gmenu_kateg, m1kateg )
    mvid      := inieditspr( A__MENUVERT, osn_sovm, m1vid )
    mvr_kateg := inieditspr( A__MENUVERT, menu_vr_kateg, m1vr_kateg )
    msertif   := inieditspr( A__MENUVERT, mm_danet, m1sertif )
    m1prvs    := iif( Empty( m1prvs ), Space( 4 ), PadR( lstr( m1prvs ), 4 ) )
    mprvs     := PadR( ret_tmp_prvs( 0, m1prvs ), 40 )

    m1prvs_021 := iif( Empty( m1prvs_021 ), Space( 4 ), PadR( lstr( m1prvs_021 ), 4 ) )
    mprvs_021 := PadR( inieditspr( A__MENUVERT, getv021(), Val( m1prvs_021 ) ), 40 )

    tmp_color := SetColor( cDataCScr )
    k := MaxRow() -19
    If fl_profil
      --k
      mprofil := inieditspr( A__MENUVERT, getv002(), m1profil )
    Endif
    box_shadow( k -1, 0, MaxRow() -1, 79, , ;
      if( nKey == K_INS, 'Добавление', 'Редактирование' ) + ' информации о сотруднике', color8 )
    SetColor( cDataCGet )
    r := k
    @ ++r, 2 Say 'Табельный номер' Get mtab_nom Picture '99999' ;
      valid {| g| val_tab_nom( g, nKey ) }
    @ r, 36 Say 'Сводный табельный номер' Get msvod_nom Picture '99999'
    @ ++r, 2 Say 'Ф.И.О.' Get mfio
    @ ++r, 2 Say 'СНИЛС' Get msnils Picture picture_pf() Valid val_snils( msnils, 1 )
    @ ++r, 2 Say 'Учр-е' Get much ;
      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c ) } }, A__FUNCTION, , , .f. ) }
    @ r, 39 Say 'Отделение' Get motd When .f.
    @ ++r, 2 Say 'Вид работы' Get mvid ;
      reader {| x| menu_reader( x, osn_sovm, A__MENUVERT, , , .f. ) }
    @ r, 36 Say 'Ставка' Color color8 Get mstavka Picture '9.99'
    @ ++r, 2 Say 'Категория' Get mkateg ;
      reader {| x| menu_reader( x, gmenu_kateg, A__MENUVERT, , , .f. ) }
    @ ++r, 2 Say 'Мед.специальность' Get mPRVS ;
      reader {| x| menu_reader( x, { {| k, r, c| fget_tmp_v015( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      valid {| g| set_prvs( g, 1 ) } when ( m1kateg == 1 .or. m1kateg == 2 )
    @ ++r, 2 Say 'Мед.специальность V021' Get mPRVS_021 ;
      reader {| x| menu_reader( x, getv021(), A__MENUVERT_SPACE, , , .f. ) } ;
      valid {| g| set_prvs( g, 2 ) } when ( m1kateg == 1 .or. m1kateg == 2 )
    If fl_profil
      @ ++r, 2 Say 'Профиль' Get mprofil ;
        reader {| x| menu_reader( x, tmp_V002, A__MENUVERT_SPACE, , , .f. ) } ;
        when ( m1kateg == 1 .or. m1kateg == 2 )
    Endif
    @ ++r, 2 Say 'Наименование должности' Get mname_dolj
    @ ++r, 2 Say 'Медицинская категория' Get mvr_kateg ;
      reader {| x| menu_reader( x, menu_vr_kateg, A__MENUVERT, , , .f. ) } ;
      when ( m1kateg == 1 .or. m1kateg == 2 )
    @ ++r, 2 Say 'Наименование должности по мед.категории' Get mDOLJKAT ;
      when ( m1kateg == 1 .or. m1kateg == 2 )
    @ ++r, 2 Say 'Дата подтверждения мед.категории' Get mD_KATEG  when ( m1kateg == 1 .or. m1kateg == 2 )
    @ ++r, 2 Say 'Наличие сертификата' Get mSERTIF ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
      when ( m1kateg == 1 .or. m1kateg == 2 )
    @ ++r, 2 Say 'Дата подтверждения сертификата' Get mD_SERTIF ;
      when ( m1kateg == 1 .or. m1kateg == 2 )
    @ ++r, 2 Say 'Код врача для выписки рецептов по ДЛО' Get mKOD_DLO Pict '99999' ;
      When m1kateg == 1
    @ ++r, 2 Say 'Дата начала работы в должности' Get mDBEGIN
    @ ++r, 2 Say 'Дата окончания работы' Get mDEND
    status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC .and. !Empty( mfio ) .and. f_esc_enter( 1 )
      Select P2
      If nKey == K_INS
        find ( '0' )
        If Found()
          g_rlock( forever )
        Else
          addrecn()
        Endif
        mkod := RecNo()
        Replace kod With RecNo()
      Else
        Goto ( mkod )
        g_rlock( forever )
      Endif
      p2->fio      := mfio
      p2->tab_nom  := mtab_nom
      p2->svod_nom := msvod_nom
      p2->uch      := m1uch
      p2->otd      := m1otd
      p2->kateg    := m1kateg
      p2->name_dolj := mname_dolj
      p2->stavka   := mstavka
      p2->vid      := m1vid
      p2->vr_kateg := m1vr_kateg
      p2->DOLJKAT  := mDOLJKAT
      p2->D_KATEG  := mD_KATEG
      p2->sertif   := m1sertif
      p2->D_SERTIF := mD_SERTIF
      p2->prvs_new := iif( ValType( m1prvs ) == 'C', Val( m1prvs ), m1prvs )
      p2->prvs_021 := iif( ValType( m1prvs_021 ) == 'C', Val( m1prvs_021 ), m1prvs_021 )  // val(m1prvs_021)
      If fl_profil
        p2->profil := m1profil
      Endif
      p2->uroven   := muroven
      p2->otdal    := motdal
      p2->kod_dlo  := mkod_dlo
      p2->snils    := msnils
      p2->DBEGIN   := mDBEGIN
      p2->DEND     := mDEND
      Unlock
      Commit
      oBrow:gotop()
      Goto ( mkod )
      ret := 0
    Endif
    SetColor( tmp_color )
    Restore Screen From buf
  Case nKey == K_DEL .and. ( k := p2->kod ) > 0
    buf := save_maxrow()
    s := 'Ждите! Производится проверка на допустимость удаления '
    mywait( s + 'human_u' )
    r_use( dir_server() + 'human_u', , 'HU' )
    Set Index to ( dir_server() + 'human_uv' )
    find ( Str( k, 4 ) )
    If !( fl := Found() )
      Set Index to ( dir_server() + 'human_ua' )
      find ( Str( k, 4 ) )
      fl := Found()
    Endif
    hu->( dbCloseArea() )
    If !fl
      mywait( s + 'hum_p_u' )
      r_use( dir_server() + 'hum_p_u', , 'HU' )  // проверить Платные услуги
      Set Index to ( dir_server() + 'hum_p_uv' )
      find ( Str( k, 4 ) )
      If !( fl := Found() )
        Set Index to ( dir_server() + 'hum_p_ua' )
        find ( Str( k, 4 ) )
        fl := Found()
      Endif
      hu->( dbCloseArea() )
    Endif
    If !fl
      mywait( s + 'hum_oru' )
      r_use( dir_server() + 'hum_oru', , 'HU' ) // проверить Ортопедию
      Set Index to ( dir_server() + 'hum_oruv' )
      find ( Str( k, 4 ) )
      If !( fl := Found() )
        Set Index to ( dir_server() + 'hum_orua' )
        find ( Str( k, 4 ) )
        fl := Found()
      Endif
      hu->( dbCloseArea() )
    Endif
    If !fl
      mywait( s + 'kas_pl_u' )
      r_use( dir_server() + 'kas_pl_u', , 'HU' ) // проверить Кассу
      Index On Str( kod_vr, 4 ) to ( cur_dir() + 'tmp_hu' ) For kod_vr > 0
      find ( Str( k, 4 ) )
      fl := Found()
      hu->( dbCloseArea() )
      If !fl
        mywait( s + 'kas_ort' )
        r_use( dir_server() + 'kas_ort', , 'HU' )
        Index On Str( kod_vr, 4 ) to ( cur_dir() + 'tmp_hu' ) For kod_vr > 0
        find ( Str( k, 4 ) )
        If !( fl := Found() )
          Index On Str( kod_tex, 4 ) to ( cur_dir() + 'tmp_hu' ) For kod_tex > 0
          find ( Str( k, 4 ) )
          fl := Found()
        Endif
        hu->( dbCloseArea() )
      Endif
    Endif
    rest_box( buf )
    Select P2
    If fl
      func_error( 4, 'Данный человек встречается в других базах данных. Удаление запрещено!' )
    Elseif f_esc_enter( 2 )
      deleterec(, .f. )   // очистить без пометки на удаление
      find ( str_find )
      oBrow:gotop()
      ret := 0
    Endif
  Endcase
  Return ret

// 27.02.23
Function set_prvs( get, regim )

  // regim - место вызова, (1 - выбор mprvs, 2 - выбор mprvs_021)
  Local fl := .t., prvs := 0, prvs_021 := 0

  If regim == 1
    prvs := iif( ValType( m1prvs ) == 'C', Val( m1prvs ), m1prvs )
    m1prvs_021 := prvs_v015_to_v021( prvs )
    mprvs_021 := PadR( inieditspr( A__MENUVERT, getv021(), m1prvs_021 ), 40 )
    mname_dolj := PadR( doljbyspec_v021( m1prvs_021 ), 30 )
    update_get( 'mprvs_021' )
    update_get( 'mname_dolj' )
  Elseif regim == 2
    prvs_021 := m1prvs_021
    m1PRVS := prvs_v021_to_v015( prvs_021 )
    mprvs  := PadR( ret_tmp_prvs( 0, m1prvs ), 40 )
    mname_dolj := PadR( doljbyspec_v021( prvs_021 ), 30 )
    update_get( 'mprvs' )
    update_get( 'mname_dolj' )
  Endif
  Return fl

// проверка на допустимость табельного номера
Function val_tab_nom( get, nKey )

  Local fl := .t., rec := 0, norder

  If mtab_nom > 0 .and. !( mtab_nom == get:original )
    rec := RecNo()
    Set Order To 2
    find ( Str( mtab_nom, 5 ) )
    Do While tab_nom == mtab_nom .and. !Eof()
      If nKey == K_ENTER
        If rec != RecNo()
          fl := .f.
          Exit
        Endif
      Elseif nKey == K_INS
        fl := .f.
        Exit
      Endif
      Skip
    Enddo
    If !fl
      func_error( 4, 'Человек с данным табельным номером уже присутствует в справочнике персонала!' )
    Endif
    Set Order To 1
    Goto ( rec )
    If !fl
      mtab_nom := get:original
    Endif
  Endif
  Return fl

//
Function f4edit_pers( nkey )

  Static tmp := ' '
  Local buf := SaveScreen(), buf1, rec1 := RecNo(), fl := -1, tmp1, ;
    i, s, fl1

  If nkey != K_F2
    Return -1
  Endif
  buf1 := SaveScreen( 13, 4, 19, 77 )
  Do While .t.
    tmp1 := PadR( tmp, 50 )
    SetColor( color8 )
    box_shadow( 13, 14, 18, 67 )
    @ 15, 15 Say Center( 'Введите подстроку (или табельный номер) для поиска', 52 )
    status_key( '^<Esc>^ - отказ от ввода' )
    @ 16, 16 Get tmp1 Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp1 )
      Exit
    Endif
    mywait()
    tmp := AllTrim( tmp1 )
    // проверка на поиск по таб.номеру
    fl1 := .t.
    For i := 1 To Len( tmp )
      If !( SubStr( tmp, i, 1 ) $ '0123456789' )
        fl1 := .f.
        Exit
      Endif
    Next
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr + 3, k2 := 21
    i := 0
    If fl1  // поиск по табельному номеру
      Set Order To 2
      tmp1 := Int( Val( tmp ) )
      find ( Str( tmp1, 5 ) )
      Do While tab_nom == tmp1 .and. !Eof()
        If kod > 0
          AAdd( tmp_mas, P2->fio )
          AAdd( tmp_kod, P2->kod )
        Endif
        Skip
      Enddo
      Set Order To 1
    Else
      find ( str_find )
      Do While !Eof()
        If tmp $ Upper( fio )
          AAdd( tmp_mas, P2->fio )
          AAdd( tmp_kod, P2->kod )
        Endif
        Skip
      Enddo
    Endif
    If ( t_len := Len( tmp_kod ) ) = 0
      stat_msg( 'Не найдено ни одной записи, удовлетворяющей данному запросу!' )
      mybell( 2 )
      RestScreen( 13, 4, 19, 77, buf1 )
      Loop
    Elseif t_len == 1  // по табельному номру найдена одна строка
      Goto ( tmp_kod[ 1 ] )
      fl := 0
      Exit
    Else
      box_shadow( mr, 2, 22, 77 )
      SetColor( 'B/BG' )
      @ k1 -2, 15 Say 'Подстрока: ' + tmp
      SetColor( color0 )
      If k1 + t_len + 2 < 21
        k2 := k1 + t_len + 2
      Endif
      @ k1, 3 Say Center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
      status_key( '^<Esc>^ - отказ от выбора' )
      If ( i := Popup( k1 + 1, 13, k2, 66, tmp_mas, , color0 ) ) > 0
        Goto ( tmp_kod[ i ] )
        fl := 0
      Endif
      Exit
    Endif
  Enddo
  If fl == -1
    Goto rec1
  Endif
  RestScreen( buf )
  Return fl

// 12.09.25
function spr_personal( type_report, type_sort )

  local ft, arr_title := {}
  local s, max_nom, i, k
  local name_file := cur_dir() + 'personal.txt'
  local aRow

  if type_report == 1
    If type_sort == 1
      Set Order To 1
      find ( str_find )
    Else
      Set Order To 2
      Go Top
    Endif
  elseif type_report == 2
    r_use( dir_server() + 'mo_pers',, 'P2' )
    Index On Upper( fio ) to ( cur_dir() + 'tmp_pers' ) For kod > 0
  endif

  mywait()
  ft := tfiletext():new( name_file, , .t., , .t. )
  ft:add_string( '' )
  ft:add_string( 'Список работающего персонала с табельными номерами', FILE_CENTER, ' ' )
  ft:add_string( '' )

  ft:Add_Column( 'Таб.№', 5, FILE_RIGHT )
  ft:Add_Column( 'Ф.И.О.', 40, FILE_LEFT, , .t., FILE_CENTER )

  if type_report == 1
    ft:Add_Column( 'СНИЛС', 14, FILE_LEFT )
    ft:Add_Column( 'Специальность', 26, FILE_LEFT )
  elseif type_report == 2
    ft:Add_Column( 'Специальность', 26, FILE_LEFT )
  endif
  ft:EnableTableHeader := .t.
  ft:printTableHeader()
  Do While !Eof()
    aRow := {}
    if type_report == 1
      If iif( type_sort == 2, kod > 0, .t. ) .and. between_date( p2->dbegin, p2->dend )
        AAdd( aRow, put_val( p2->tab_nom, 5 ) )
        AAdd( aRow, iif( Empty( p2->svod_nom ), Space( 5 ), PadL( '(' + lstr( p2->svod_nom ) + ')', 5 ) ) + ;
          ' ' + AllTrim( p2->fio ) )
//        AAdd( aRow, Transform( p2->SNILS, picture_pf ) )
        AAdd( aRow, Transform_SNILS( p2->SNILS ) )
        AAdd( aRow, ret_tmp_prvs( p2->prvs, p2->prvs_new ) )
      Endif
    elseif type_report == 2
      AAdd( aRow, put_val( p2->tab_nom, 5 ) )
      AAdd( aRow, iif( Empty( p2->svod_nom ), Space( 5 ), PadL( '(' + lstr( p2->svod_nom ) + ')', 5 ) ) + ;
        ' ' + AllTrim( p2->fio ) )
      AAdd( aRow, ret_tmp_prvs( p2->prvs, p2->prvs_new ) )
    endif
    ft:Add_Row( aRow )
    Skip
  Enddo

  if type_report == 1
    Set Order To 2
    Go Bottom
    max_nom := p2->tab_nom
    ft:add_string( Replicate( '=', ft:Width ) )
    ft:add_string( 'Список свободных табельных номеров:', FILE_CENTER, ' ' )
    s := ''
    k := 0
    For i := 1 To max_nom
      find ( Str( i, 5 ) )
      If !Found()
        s += lstr( i ) + ', '
        If Len( s ) > ft:Width
          ft:add_string( s )
          s := ''
          If ++k > 10
            ft:add_string( '...' )
            Exit
          Endif
        Endif
      Endif
    Next
    If !Empty( s )
      ft:add_string( s )
    Endif
    Set Order To 1
  endif
  ft := nil
  if type_report == 2
    p2->( dbCloseArea() )
  endif
  viewtext( name_file, , , , .t., , , 2 )
  return nil

// 07.03.21 список персонала
/* Function spr_personal() 

  Local sh := 80, HH := 57, fl := .t., s

  mywait()
  fp := FCreate( cur_dir() + 'spisok' + stxt() )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Списочный состав персонала с табельными номерами', sh ) )
  add_string( '' )
  add_string( Center( AllTrim( glob_uch[ 2 ] ) + ' (' + AllTrim( glob_otd[ 2 ] ) + ')', sh ) )
  add_string( PadL( date_8( sys_date ) + 'г.', sh ) )
  If r_use( dir_server() + 'mo_pers',, 'PERSO' )
    Index On Upper( fio ) to ( cur_dir() + 'tmp_pers' ) For kod > 0
    Do While !Eof()
      If fl .or. tek_stroke > HH
        If !fl
          add_string( Chr( 12 ) )
          tek_stroke := 0
          n_list++
          next_list( sh )
        Endif
        add_string( '─────┬──────────────────────────────────────────────────┬──────────────────────' )
        add_string( 'Таб.№│                       Ф.И.О.                     │ Специальность        ' )
        add_string( '─────┴──────────────────────────────────────────────────┴──────────────────────' )
      Endif
      fl := .f.
      s := put_val( perso->tab_nom, 5 ) + ;
        iif( Empty( perso->svod_nom ), Space( 5 ), PadL( '(' + lstr( perso->svod_nom ) + ')', 5 ) ) + ;
        ' ' + PadR( AllTrim( perso->fio ), 45 )
      If !emptyall( perso->prvs, perso->prvs_new )
        s += ' ' + ret_tmp_prvs( perso->prvs, perso->prvs_new )
      Endif
      add_string( s )
      Select PERSO
      Skip
    Enddo
  Endif
  Close databases
  FClose( fp )
  viewtext( 'spisok' + stxt(),,,,,,, 2 )
  Return Nil
*/
