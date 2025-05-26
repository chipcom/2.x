// spr_uslugi.prg - Работа со справочниками услуг
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// Редактирование справочника услуг
Function edit_spr_uslugi( k )

  Static sk := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    If ! hb_user_curUser:isadmin()
      Return func_error( 4, err_admin )
    Endif
    mas_pmt := { '~Редактирование услуг', ;
      'Услуги Минздрава РФ (~ФФОМС)', ;
      '~Комплексные услуги', ;
      'Редактирование ~УЕТ', ;
      'Плановые У~ЕТ', ;
      'Несовместимость по ~дате', ;
      'Услуги без ~врачей', ;
      'Услуги - ~1 раз в году', ;
      'Редактирование ~служб' }
    mas_msg := { 'Редактирование справочника услуг (ТФОМС и МО)', ;
      'Редактирование справочника услуг Министерства здравоохранения РФ (манипуляции ФФОМС)', ;
      'Редактирование справочника комплексных услуг (для удобства ввода данных)', ;
      'Редактирование коэффициентов трудоёмкости услуг (УЕТ)', ;
      'Редактирование плановой месячной трудоёмкости персонала', ;
      'Редактирование справочника услуг, которые не должны быть оказаны в один день', ;
      'Ввод/редактирование услуг, у которых не вводится врач (ассистент)', ;
      'Ввод/редактирование услуг, которые могут быть оказаны человеку только раз в году', ;
      'Редактирование справочника служб' }
    mas_fun := { 'edit_spr_uslugi(1)', ;
      'edit_spr_uslugi(2)', ;
      'edit_spr_uslugi(3)', ;
      'edit_spr_uslugi(4)', ;
      'edit_spr_uslugi(5)', ;
      'edit_spr_uslugi(6)', ;
      'edit_spr_uslugi(7)', ;
      'edit_spr_uslugi(8)', ;
      'edit_spr_uslugi(9)' }
    popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    f1_uslugi()
  Case k == 2
    spr_uslugi_ffoms()
  Case k == 3
    f_k_uslugi()
  Case k == 4
    f_trkoef()
  Case k == 5
    f_trpers()
  Case k == 6
    f_ns_uslugi()
  Case k == 7
    f_usl_uva()
  Case k == 8
    f_usl_raz()
  Case k == 9
    f5_uslugi( 2, T_COL + 10 )
  Endcase
  If k > 0
    sk := k
  Endif
  Return Nil

// 30.05.23
Function f1_uslugi()

  Local arr_block, buf := SaveScreen(), str_sem := 'Редактирование услуг'
  Local tmpAlias, i

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  If !use_base( 'lusl' ) .or. !use_base( 'luslc' ) .or. ;
      !g_use( dir_server + 'uslugi1', { dir_server + 'uslugi1', ;
      dir_server + 'uslugi1s' }, 'USL1' ) .or. ;
      !g_use( dir_server + 'uslugi', , 'USL' ) .or. ;
      !g_use( dir_server + 'usl_otd', dir_server + 'usl_otd', 'UO' ) .or. ;
      !r_use( dir_server + 'slugba', dir_server + 'slugba', 'SL' )
    Close databases
    Return Nil
  Endif
  mywait()
  If is_otd_dep .and. glob_otd_dep == 0 .and. Len( mm_otd_dep ) > 0
    glob_otd_dep := mm_otd_dep[ 1, 2 ] // просто берём первое отделение
  Endif
  If !( Type( 'arr_date_usl' ) == 'A' )
    Public arr_date_usl := {}
    For i := 2018 To WORK_YEAR
      tmpAlias := create_name_alias( 'LUSLC', i )
      If ! ( tmpAlias )->( Used() )
        Loop
      Endif
      Select ( tmpAlias )
      Index On DToS( datebeg ) to ( cur_dir() + 'tmp1' ) unique
      dbEval( {|| AAdd( arr_date_usl, ( tmpAlias )->datebeg ) } )
      Set Index to ( cur_dir() + prefixfilerefname( i ) + 'uslc' ), ( cur_dir() + prefixfilerefname( i ) + 'uslu' )
    Next
  Endif
  Private tmp_V002 := create_classif_ffoms( 0, 'V002' ) // PROFIL
  dbCreate( cur_dir() + 'tmp_usl1', { { 'shifr1',  'C', 10, 0 }, ;
    { 'name',    'C', 77, 0 }, ;
    { 'date_b',  'D', 8, 0 } } )
  Use ( cur_dir() + 'tmp_usl1' ) new
  Index On DToS( date_b ) to ( cur_dir() + 'tmp_usl1' )
  Select USL
  Index On iif( kod > 0, '1', '0' ) + fsort_usl( shifr ) to ( cur_dir() + 'tmp_usl' )
  Set Index to ( cur_dir() + 'tmp_usl' ), ;
    ( dir_server + 'uslugi' ), ;
    ( dir_server + 'uslugish' ), ;
    ( dir_server + 'uslugis1' ), ;
    ( dir_server + 'uslugisl' )
  Private str_find := '1', muslovie := 'usl->kod > 0'
  arr_block := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  find ( '1' )
  Private fl_found := Found()
  If fl_found
    Do While Empty( shifr ) .and. !Eof()
      Skip
    Enddo
  Else
    Keyboard Chr( K_INS )
  Endif
  alpha_browse( 2, 0, MaxRow() -1, 79, 'f1_es_uslugi', color0, 'Редактирование услуг', 'B/BG', ;
    .f., , arr_block, , 'f2_es_uslugi', , ;
    { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R,N+/BG,W/N,RB/BG,W+/RB', .t., 180 } )
  Close databases
  g_sunlock( str_sem )
  RestScreen( buf )
  Return Nil

//
Function f1_es_uslugi( oBrow )

  Local n := 56
  Local oColumn, blk := {| _c| _c := f0_es_uslugi(), { { 1, 2 }, { 3, 4 }, { 5, 6 }, { 7, 8 }, { 9, 10 } }[ _c ] }

  oColumn := TBColumnNew( '   Шифр', {|| usl->shifr } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Шифр ТФОМС', {|| opr_shifr_tfoms( usl->shifr1, usl->kod ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If is_zf_stomat == 1
    oColumn := TBColumnNew( 'ЗФ', {|| iif( usl->zf == 1, 'да', '  ' ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    n -= 3
  Endif
  oColumn := TBColumnNew( Center( 'Наименование услуги', n ), {|| Left( usl->name, n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<F4>^ копирование ^<Del>^ удаление ^<F2>^ поиск' )
  Return Nil

//
Function f2_es_uslugi( nKey, oBrow )

  Static sshifr := '          '
  Local j := 0, k := -1, buf := save_maxrow(), fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 14, c1 := 2

  Do Case
  Case nKey == K_F2
    rec := RecNo()
    If ( mshifr := input_value( 18, 10, 20, 69, color1, ;
        '  Введите необходимый шифр услуги для поиска', ;
        sshifr, '@K@!' ) ) != NIL
      sshifr := mshifr := transform_shifr( mshifr )
      Set Order To 3
      find ( PadR( mshifr, 10 ) )
      If Found()
        rec := RecNo()
        fl := .t.
      Endif
      Set Order To 1
      If fl
        oBrow:gotop()
        Goto ( rec )
        k := 0
      Else
        Goto ( rec )
        func_error( 4, 'Услуга с шифром "' + AllTrim( mshifr ) + '" не найдена!' )
      Endif
    Endif
  Case nKey == K_INS .or. nKey == K_F4 .or. ( nKey == K_ENTER .and. usl->kod > 0 )
    rec := f3_es_uslugi( nKey )
    Select USL
    oBrow:gotop()
    Goto ( rec )
    k := 0
  Case nKey == K_DEL .and. usl->kod > 0
    stat_msg( 'Ждите! Производится проверка на наличие удаляемой услуги в других базах данных.' )
    mybell( 0.1, OK )
    r_use( dir_server + 'human_u', dir_server + 'human_uk', 'HU' )
    find ( Str( usl->kod, 4 ) )
    fl := Found()
    hu->( dbCloseArea() )
    If !fl
      r_use( dir_server + 'hum_p_u', dir_server + 'hum_p_uk', 'HU' )
      find ( Str( usl->kod, 4 ) )
      fl := Found()
      hu->( dbCloseArea() )
    Endif
    If !fl
      r_use( dir_server + 'hum_oru', dir_server + 'hum_oruk', 'HU' )
      find ( Str( usl->kod, 4 ) )
      fl := Found()
      hu->( dbCloseArea() )
    Endif
    If !fl
      r_use( dir_server + 'kas_pl_u', dir_server + 'kas_pl2u', 'HU' )
      find ( Str( usl->kod, 4 ) )
      fl := Found()
      hu->( dbCloseArea() )
      If !fl
        r_use( dir_server + 'kas_ortu', dir_server + 'kas_or2u', 'HU' )
        find ( Str( usl->kod, 4 ) )
        fl := Found()
        hu->( dbCloseArea() )
      Endif
    Endif
    Select USL
    If fl
      func_error( 4, 'Данная услуга встречается в других базах данных. Удаление запрещено!' )
    Elseif f_esc_enter( 2, .t. )
      mywait()
      useuch_usl()
      Select UU1
      Do While .t.
        find ( Str( usl->kod, 4 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      Select UU
      find ( Str( usl->kod, 4 ) )
      Do While uu->kod == usl->kod .and. !Eof()
        g_rlock( forever )
        uu->vkoef_v := 0
        uu->vkoef_r := 0
        uu->akoef_v := 0
        uu->akoef_r := 0
        uu->koef_v := 0
        uu->koef_r := 0
        Unlock
        Skip
      Enddo
      uu->( dbCloseArea() )
      uu1->( dbCloseArea() )
      //
      Select USL1
      Do While .t.
        find ( Str( usl->kod, 4 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      //
      Select USL
      g_rlock( forever )
      Replace usl->kod With -1, ;
        usl->slugba With -1, ;
        usl->name With '', ;
        usl->shifr With '', ;
        usl->shifr1 With ''
      Unlock
      Commit
      stat_msg( 'Услуга удалена!' )
      mybell( 1, OK )
      oBrow:gotop()
      k := 0
    Endif
  Endcase
  rest_box( buf )
  Return k

// 22.12.22
Function f3_es_uslugi( nKey )

  Static menu_nul := { { 'нет', .f. }, { 'да', .t. } }
  Local tmp_help := chm_help_code, buf := SaveScreen(), r, r1 := MaxRow() -11, ;
    k, tmp_color := SetColor(), ret := usl->( RecNo() ), old_m1otd, s, is_full

  Private mkod, mname, mpcena, mpcena_d, mshifr, mshifr1, mcena, mcena_d, ;
    m1shifr1, m1PROFIL, mPROFIL, mpnds, mpnds_d, mzf, m1zf, ;
    mdms_cena, m1is_nul, mis_nul, motdel := Space( 10 ), m1otdel := '', ;
    mname1 := '', mslugba, m1slugba, gl_area, ;
    m1is_nulp, mis_nulp, yes_tfoms := .f., pifin := 0, pifinr, pifinc

  If ( is_full := ( is_task( X_ORTO ) .or. is_task( X_KASSA ) .or. is_task( X_PLATN ) ) )
    r1 -= 4
  Endif
  gl_area := { r1 + 1, 0, 23, 79, 0 }
  //
  Select TMP_USL1
  Zap
  //
  mkod      := if( nKey == K_INS, 0, usl->kod )
  mname     := if( nKey == K_INS, Space( 65 ), usl->name )
  mfull_name := if( nKey == K_INS, Space( 255 ), usl->full_name )
  mshifr    := if( nKey == K_INS, Space( 10 ), usl->shifr )
  mshifr1   := if( nKey == K_INS, Space( 10 ), usl->shifr1 )
  m1PROFIL  := if( nKey == K_INS, 0, usl->profil )
  mPROFIL   := inieditspr( A__MENUVERT, getv002(), m1PROFIL )
  mcena     := if( nKey == K_INS, 0, usl->cena )
  mcena_d   := if( nKey == K_INS, 0, usl->cena_d )
  mpcena    := if( nKey == K_INS, 0, usl->pcena )
  mpcena_d  := if( nKey == K_INS, 0, usl->pcena_d )
  mpnds     := if( nKey == K_INS, 0, usl->pnds )
  mpnds_d   := if( nKey == K_INS, 0, usl->pnds_d )
  mdms_cena := if( nKey == K_INS, 0, usl->dms_cena )
  m1slugba  := if( nKey == K_INS, -1, usl->slugba )
  m1zf      := if( nKey == K_INS, .f., ( usl->zf == 1 ) )
  mzf       := inieditspr( A__MENUVERT, menu_nul, m1zf )
  m1is_nul  := if( nKey == K_INS, .f., usl->is_nul )
  mis_nul   := inieditspr( A__MENUVERT, menu_nul, m1is_nul )
  m1is_nulp := if( nKey == K_INS, .f., usl->is_nulp )
  mis_nulp  := inieditspr( A__MENUVERT, menu_nul, m1is_nulp )
  If m1slugba >= 0
    Select SL
    find ( Str( m1slugba, 3 ) )
    mslugba := lstr( sl->shifr ) + '. ' + AllTrim( sl->name )
  Else
    mslugba := Space( 10 )
  Endif
  If nKey == K_ENTER .or. nKey == K_F4 // редактирование или копирование
    If !Empty( s := f0_e_uslugi1( mkod, , .t. ) )
      mshifr1 := s
    Endif
    Select UO
    find ( Str( mkod, 4 ) )
    If Found()
      k := AtNum( Chr( 0 ), uo->otdel, 1 )
      motdel := '= ' + lstr( k -1 ) + 'отд. ='
      m1otdel := Left( uo->otdel, k -1 )
    Endif
  Endif
  m1shifr1 := mshifr1
  old_m1otd := m1otdel
  chm_help_code := 1// H_Edit_uslugi
  //
  SetColor( color8 )
  Scroll( r1, 0, MaxRow() -1, MaxCol() )
  @ r1, 0 To r1, MaxCol()
  status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - запись' )
  If nKey == K_INS .or. nKey == K_F4
    str_center( r1, ' Добавление услуги ' )
  Else
    str_center( r1, ' Редактирование ' )
  Endif
  f4_es_uslugi( 0 )
  Do While .t.
    SetColor( cDataCGet )
    If !m1is_nul
      Keyboard Chr( K_TAB )
    Endif
    r := r1
    @ ++r, 1 Say 'Разрешается ввод данной услуги по НУЛЕВОЙ цене в задаче ОМС?' ;
      Get mis_nul reader {| x| menu_reader( x, menu_nul, A__MENUVERT, , , .f. ) }
    @ ++r, 1 Say 'Наименование услуги по справочнику ТФОМС'
    @ ++r, 3 Get mname1 When .f. Color color14
    @ ++r, 1 Say 'Шифр МО' Get mshifr Picture '@!' Valid f4_es_uslugi( 1, .t., nKey )
    @ Row(), Col() + 5 Say 'шифр ТФОМС' Get mshifr1 ;
      reader {| x| menu_reader( x, { {| k, r, c| f1_e_uslugi1( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      Valid f4_es_uslugi( 0 ) ;
      Color 'R/W'
    If is_zf_stomat == 1
      @ Row(), Col() + 5 Say 'Ввод зубной формулы' Get mzf ;
        reader {| x| menu_reader( x, menu_nul, A__MENUVERT, , , .f. ) }
    Endif
    @ ++r, 1 Say 'Наименование услуги' Get mname Picture '@S59'
    If is_full
      @ ++r, 1 Say 'Наименование/платные' Get mfull_name Picture '@S58'
    Endif
    @ ++r, 1 Say 'Цена услуги ОМС: для взрослого' Get mcena Picture pict_cena When !yes_tfoms Color color14
    @ Row(), Col() Say ', для ребенка' Get mcena_d Picture pict_cena When !yes_tfoms Color color14
    @ ++r, 1 Say 'Профиль' Get MPROFIL ;
      reader {| x| menu_reader( x, tmp_V002, A__MENUVERT_SPACE, , , .f. ) }
    If is_full
      @ ++r, 1 Say 'Разрешается ввод ПЛАТНОЙ услуги по НУЛЕВОЙ цене?' ;
        Get mis_nulp reader {| x| menu_reader( x, menu_nul, A__MENUVERT, , , .f. ) }
      @ ++r, 1 Say 'Цена ПЛАТНОЙ услуги: для взрослого' Get mpcena Picture pict_cena
      @ Row(), Col() Say ' (в т.ч. НДС' Get mpnds Picture pict_cena
      @ Row(), Col() Say ')'
      @ ++r, 1 Say '   для ребенка' Get mpcena_d Picture pict_cena
      @ Row(), Col() Say ' (в т.ч. НДС' Get mpnds_d Picture pict_cena
      @ Row(), Col() Say '); цена по ДМС' Get mdms_cena Picture pict_cena
    Endif

    @ ++r, 1 Say 'Служба' Get mslugba ;
      reader {| x| menu_reader( x, { {| k, r, c| fget_slugba( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      Color 'R/W'
    @ ++r, 1 Say 'В каких отделениях разрешается ввод услуги' Get motdel ;
      reader {| x| menu_reader( x, { {| k, r, c| inp_bit_otd( k, r, c ) } }, A__FUNCTION, , , .f. ) }

    myread()
    If LastKey() != K_ESC
      fl := .t.
      If Empty( mname )
        fl := func_error( 'Не введено название услуги. Нет записи.' )
      Elseif Empty( mshifr )
        fl := func_error( 'Не введен шифр услуги. Нет записи.' )
      Endif
      If fl
        mywait()
        Select USL
        Set Order To 2
        If nKey == K_INS .or. nKey == K_F4
          find ( Str( -1, 4 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 4 )
          Endif
          mkod := RecNo()
          usl->kod := mkod
        Else
          find ( Str( mkod, 4 ) )
          g_rlock( forever )
        Endif
        usl->name     := mname
        usl->full_name := mfull_name
        usl->shifr    := mshifr
        usl->shifr1   := mshifr1
        usl->PROFIL   := m1PROFIL
        usl->zf       := iif( m1zf, 1, 0 )
        usl->is_nul   := m1is_nul
        usl->is_nulp  := m1is_nulp
        usl->slugba   := m1slugba
        If ValType( mcena ) == 'C'
          usl->cena   := Val( mcena )
          usl->cena_d := Val( mcena_d )
        Else
          usl->cena   := mcena
          usl->cena_d := mcena_d
        Endif
        usl->pcena    := mpcena
        usl->pcena_d  := mpcena_d
        usl->dms_cena := mdms_cena
        usl->pnds     := mpnds
        usl->pnds_d   := mpnds_d
        //
        Select USL1
        Do While .t.
          find ( Str( mkod, 4 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        Select TMP_USL1
        Go Top
        Do While !Eof()
          Select USL1
          addrec( 4 )
          usl1->kod    := mkod
          usl1->shifr1 := tmp_usl1->shifr1
          usl1->date_b := tmp_usl1->date_b
          Select TMP_USL1
          Skip
        Enddo
        //
        If !( old_m1otd == m1otdel )
          Select UO
          If Len( m1otdel ) == 0
            find ( Str( mkod, 4 ) )
            If Found()
              deleterec( .t. )
            Endif
          Else
            find ( Str( mkod, 4 ) )
            If Found()
              g_rlock( forever )
            Else
              addrec( 4 )
              uo->kod := mkod
            Endif
            uo->otdel := PadR( m1otdel, 255, Chr( 0 ) )
          Endif
        Endif
        Unlock All
        Commit
        ret := mkod
      Else
        Loop
      Endif
    Endif
    Exit
  Enddo
  chm_help_code := tmp_help
  RestScreen( buf )
  SetColor( tmp_color )
  Select USL
  Set Order To 1
  Return ret

// 22.12.22
Function f4_es_uslugi( k, fl_poisk, nKey )

  Local v1, v2, s, rec, fl1del, fl2del

  If k > 0
    Default fl_poisk To .f.
    Private tmp := ReadVar()
    &tmp := transform_shifr( &tmp )
    If fl_poisk .and. !Empty( mshifr )
      Select USL
      rec := RecNo()
      Set Order To 1
      v1 := 0
      find ( mshifr )
      Do While usl->shifr == mshifr .and. !Eof()
        If nKey == K_INS .or. nKey == K_F4
          ++v1
        Elseif RecNo() != rec
          ++v1
        Endif
        Skip
      Enddo
      Goto ( rec )
      If v1 > 0
        Return func_error( 4, 'Данный шифр услуги уже встречается в справочнике услуг!' )
      Endif
      r_use( dir_server + 'mo_su', dir_server + 'mo_sush', 'MOSU' )
      find ( mshifr )
      If Found()
        v1 := 1
      Endif
      dbCloseArea()
      Select USL
      If v1 > 0
        Return func_error( 4, 'Данный шифр услуги уже встречается в справочнике операций!' )
      Endif
    Endif
  Endif
  s := iif( Empty( mshifr1 ), mshifr, mshifr1 )
  mname1 := Space( 77 )
  yes_tfoms := .f.
  If !Empty( s )
    s := PadR( transform_shifr( s ), 10 )
    Select LUSL
    find ( s )
    If Found()
      yes_tfoms := .t.
      mname1 := PadR( lusl->name, 77 )
      If Empty( mname )
        mname := PadR( mname1, 65 )
      Endif
      v1 := fcena_oms( lusl->shifr, .t., sys_date,  @fl1del, , @pifin )
      v2 := fcena_oms( lusl->shifr, .f., sys_date, @fl2del, , @pifin )
      If fl1del .and. fl2del
        mcena := mcena_d := PadR( 'удалена', 10 )
      Else
        mcena := put_kop( v1, 10 )
        mcena_d := put_kop( v2, 10 )
      Endif
    Else
      mname1 := PadR( 'не найдена', 77 )
    Endif
    Select USL
  Endif
  Return update_gets()

// 15.01.19
Function f0_es_uslugi()

  Local k := 3, v1, v2, fl1del, fl2del, s := iif( Empty( usl->shifr1 ), usl->shifr, usl->shifr1 )

  s := PadR( transform_shifr( s ), 10 )
  Select LUSL
  find ( s )
  If Found()
    k := 4  // найдена, но нет цены
    v1 := fcena_oms( lusl->shifr, .t., sys_date, @fl1del )
    v2 := fcena_oms( lusl->shifr, .f., sys_date, @fl2del )
    If fl1del .and. fl2del
      k := 5  // удалена
    Elseif !emptyall( v1, v2 )
      k := 1  // есть цена
    Endif
  Elseif !emptyall( usl->pcena, usl->pcena_d, usl->dms_cena )
    k := 2  // есть платная цена
  Endif
  Select USL
  Return k

//
Function f0_e_uslugi1( lkod, ldate, is_base )

  Local s := '', tmp_select := Select()

  Default ldate To sys_date, is_base To .f.
  Select USL1
  find ( Str( lkod, 4 ) )
  Do While usl1->kod == lkod .and. !Eof()
    If usl1->date_b <= ldate
      s := usl1->shifr1
    Endif
    If is_base .and. !Empty( usl1->shifr1 )
      Select TMP_USL1
      Append Blank
      tmp_usl1->date_b := usl1->date_b
      tmp_usl1->shifr1 := usl1->shifr1
      Select LUSL
      find ( PadR( usl1->shifr1, 10 ) )
      If Found()
        tmp_usl1->name := lusl->name
      Else
        tmp_usl1->name := 'не найдено наименование услуги'
      Endif
    Endif
    Select USL1
    Skip
  Enddo
  If is_base .and. tmp_usl1->( LastRec() ) == 0 .and. !Empty( mshifr1 )
    Select TMP_USL1
    Append Blank
    tmp_usl1->date_b := arr_date_usl[ 1 ]
    tmp_usl1->shifr1 := mshifr1
    Select LUSL
    find ( PadR( mshifr1, 10 ) )
    tmp_usl1->name := lusl->name
  Endif
  Select ( tmp_select )
  Return s

//
Function f1_e_uslugi1( k, r, c )

  Local t_arr := Array( BR_LEN ), tmp_select := Select(), ret := { Space( 10 ), Space( 10 ) }

  t_arr[ BR_TOP ] := r -10
  t_arr[ BR_BOTTOM ] := r -1
  t_arr[ BR_LEFT ]  := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color5
  t_arr[ BR_TITUL ] := 'Редактирование шифра ТФОМС для услуги ' + AllTrim( mshifr )
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  t_arr[ BR_OPEN ] := {| nk, ob| f2_e_uslugi1( nk, ob, 'open' ) }
  t_arr[ BR_COLUMN ] := { { '   Дата;  начала; действия', {|| full_date( tmp_usl1->date_b ) } }, ;
    { 'Шифр ТФОМС', {|| tmp_usl1->shifr1 } }, ;
    { ' Наименование', {|| Left( tmp_usl1->name, 56 ) } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_e_uslugi1( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  //
  Select TMP_USL1
  Go Top
  Do While !Eof()
    If tmp_usl1->date_b > sys_date
      Exit
    Endif
    ret := { tmp_usl1->shifr1, tmp_usl1->shifr1 }
    Skip
  Enddo
  Select ( tmp_select )
  Return ret

//
Function f2_e_uslugi1( nKey, oBrow, regim )

  Local ret := -1, buf, fl := .f., rec, tmp_color

  Do Case
  Case regim == 'open'
    Select TMP_USL1
    Go Top
    If ( ret := !Eof() )
      Keyboard Chr( K_CTRL_PGDN )  // встать на последнюю запись
    Endif
  Case regim == 'edit'
    Do Case
    Case eq_any( nKey, K_INS, K_ENTER )
      rec := RecNo()
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'W/W', 'GR+/R' )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
        mdate_b := if( nKey == K_INS, ATail( arr_date_usl ), tmp_usl1->date_b ), ;
        mshifr1 := if( nKey == K_INS, Space( 10 ), tmp_usl1->shifr1 ), ;
        mname1  := if( nKey == K_INS, Space( 77 ), tmp_usl1->name )
      tmp_color := SetColor( cDataCScr )
      box_shadow( pr2 -5, 0, pr2 -1, 79, , ;
        if( nKey == K_INS, 'Добавление', 'Редактирование' ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ pr2 -4, 2 Say 'Дата начала действия шифра ТФОМС' Get mdate_b valid {| g| f3_e_uslugi1( g, mdate_b ) }
      @ pr2 -3, 2 Say 'Шифр ТФОМС' Get mshifr1 Pict '@!' valid {| g| f4_e_uslugi1( g ) }
      @ pr2 -2, 2 Get mname1 When .f.
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      Select TMP_USL1
      If LastKey() != K_ESC .and. !emptyany( mdate_b, mshifr1 ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          Append Blank
          rec := RecNo()
        Else
          g_rlock( forever )
        Endif
        Replace tmp_usl1->date_b With mdate_b, ;
          tmp_usl1->shifr1 With mshifr1, ;
          tmp_usl1->name   With mname1
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( tmp_usl1->date_b ) .and. f_esc_enter( 2 )
      Delete
      Pack
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function f3_e_uslugi1( get, ldate )

  Local i := 1, fl := .t.

  If Empty( ldate )
    fl := func_error( 4, 'Данное поле не может быть пустым' )
  Elseif AScan( arr_date_usl, ldate ) == 0
    If ldate > ATail( arr_date_usl )
      i := Len( arr_date_usl )
    Elseif ldate > arr_date_usl[ 1 ]
      Do While ldate > arr_date_usl[ 1 ]
        --ldate
        If ( i := AScan( arr_date_usl, ldate ) ) > 0
          Exit
        Endif
        i := 1
      Enddo
    Endif
    fl := func_error( 4, 'Неверное значение (ближайшая дата смены цен ' + date_8( arr_date_usl[ i ] ) + 'г.)' )
  Endif
  Return fl

// 16.01.13
Function f4_e_uslugi1( get )

  Local fl := .t., fl1del, fl2del

  If !Empty( mshifr1 := transform_shifr( mshifr1 ) )
    Select LUSL
    find ( mshifr1 )
    If Found()
      mname1 := PadR( lusl->name, 77 )
      fcena_oms( lusl->shifr, .t., mdate_b, @fl1del )
      fcena_oms( lusl->shifr, .f., mdate_b, @fl2del )
      If fl1del .and. fl2del
        fl := func_error( 4, 'Данная услуга удалена ТФОМС по состоянию на ' + date_8( mdate_b ) + 'г.' )
      Endif
    Else
      fl := func_error( 4, 'Не найдена услуга с данным шифром' )
    Endif
    If !fl
      mshifr1 := get:original
    Endif
  Endif
  Return fl

//
Function spr_uslugi_ffoms()

  Static menu_nul := { { 'нет', .f. }, { 'да', .t. } }
  Local arr_block, buf := SaveScreen(),  str_sem

  str_sem := 'Редактирование услуг'
  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  If !use_base( 'luslf' ) .or. !g_use( dir_server + 'mo_su', , 'MOSU' )
    Close databases
    Return Nil
  Endif
  mywait()
  Private tmp_V002 := create_classif_ffoms( 0, 'V002' ) // PROFIL
  Select MOSU
  Index On iif( kod > 0, '1', '0' ) + shifr1 to ( cur_dir() + 'tmp_usl' )
  Set Index to ( cur_dir() + 'tmp_usl' ), ;
    ( dir_server + 'mo_su' ), ;
    ( dir_server + 'mo_sush' ), ;
    ( dir_server + 'mo_sush1' )
  Private str_find := '1', muslovie := 'mosu->kod > 0'
  arr_block := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  find ( '1' )
  Private fl_found := Found()
  If !fl_found
    Keyboard Chr( K_INS )
  Endif
  alpha_browse( 2, 0, MaxRow() -1, 79, 'f1_FF_uslugi', color0, ;
    'Редактирование услуг Министерства здравоохранения РФ', 'W+/GR', ;
    .f., , arr_block, , 'f2_FF_uslugi', , ;
    { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R,N+/BG,W/N,RB/BG,W+/RB', .t., 180 } )
  Close databases
  g_sunlock( str_sem )
  RestScreen( buf )
  Return Nil

// 05.08.16
Function f1_ff_uslugi( oBrow )

  Local n := 46, oColumn, blk

  oColumn := TBColumnNew( ' Шифр ФФОМС', {|| mosu->shifr1 } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Шифр МО', {|| mosu->shifr } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If is_zf_stomat == 1
    oColumn := TBColumnNew( 'ЗФ', {|| iif( mosu->zf == 1, 'да', '  ' ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    n -= 3
  Endif
  oColumn := TBColumnNew( Center( 'Наименование услуги', n ), {|| Left( mosu->name, n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F2>^ поиск' )
  Return Nil

// 09.09.18
Function f2_ff_uslugi( nKey, oBrow )

  Static sshifr := '          '
  Local j := 0, k := -1, buf := save_maxrow(), fl := .f., rec, ;
    tmp_color := SetColor(), r1 := MaxRow() -10, c1 := 2

  Do Case
  Case nKey == K_F2
    rec := RecNo()
    If ( mshifr := input_value( 18, 10, 20, 69, color1, ;
        '  Введите необходимый шифр услуги для поиска', ;
        sshifr, '@K@!' ) ) != NIL
      sshifr := mshifr := transform_shifr( mshifr )
      Set Order To 3
      find ( mshifr )
      If Found()
        rec := RecNo()
        fl := .t.
      Endif
      Set Order To 1
      If fl
        oBrow:gotop()
        Goto ( rec )
        k := 0
      Else
        Goto ( rec )
        func_error( 4, 'Услуга с шифром "' + AllTrim( mshifr ) + '" не найдена!' )
      Endif
    Endif
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. mosu->kod > 0 )
    rec := f3_ff_uslugi( nKey )
    Select MOSU
    oBrow:gotop()
    Goto ( rec )
    k := 0
  Case nKey == K_DEL .and. mosu->kod > 0
    stat_msg( 'Ждите! Производится проверка на наличие удаляемой услуги в других базах данных.' )
    mybell( 0.1, OK )
    r_use( dir_server + 'mo_hu', dir_server + 'mo_huk', 'HU' )
    find ( Str( mosu->kod, 6 ) )
    fl := Found()
    hu->( dbCloseArea() )
    If !fl
      r_use( dir_server + 'mo_onkna', , 'NAPR' ) // онконаправления
      Locate For U_KOD == mosu->kod
      fl := Found()
      napr->( dbCloseArea() )
    Endif
    Select MOSU
    If fl
      func_error( 4, 'Данная услуга встречается в других базах данных. Удаление запрещено!' )
    Elseif f_esc_enter( 2, .t. )
      g_rlock( forever )
      Replace mosu->kod With -1, ;
        mosu->name With '', tip With 0, ;
        mosu->shifr With '', mosu->shifr1 With ''
      Unlock
      Commit
      stat_msg( 'Услуга удалена!' )
      mybell( 1, OK )
      oBrow:gotop()
      k := 0
    Endif
  Endcase
  rest_box( buf )
  Return k

// 31.01.17
Function f3_ff_uslugi( nKey )

  Static menu_nul := { { 'нет', .f. }, { 'да', .t. } }
  Local buf := SaveScreen(), r1 := MaxRow() -9, ;
    tmp_color := SetColor(), ret := mosu->( RecNo() )

  Private mkod, mname, mshifr, mshifr1, m1PROFIL, mPROFIL, mzf, m1zf, m1tip, ;
    mname1, gl_area := { r1 + 1, 0, MaxRow() -1, MaxCol(), 0 }

  //
  m1tip     := if( nKey == K_INS, 0, mosu->tip )
  mkod      := if( nKey == K_INS, 0, mosu->kod )
  mname     := if( nKey == K_INS, Space( 65 ), mosu->name )
  mshifr    := if( nKey == K_INS, Space( 10 ), mosu->shifr )
  mshifr1   := if( nKey == K_INS, Space( 20 ), mosu->shifr1 )
  m1PROFIL  := if( nKey == K_INS, 0, mosu->profil )
  mPROFIL   := inieditspr( A__MENUVERT, getv002(), m1PROFIL )
  m1zf      := if( nKey == K_INS, .f., ( mosu->zf == 1 ) )
  mzf       := inieditspr( A__MENUVERT, menu_nul, m1zf )
  //
  SetColor( color8 )
  Scroll( r1, 0, MaxRow() -1, MaxCol() )
  @ r1, 0 To r1, MaxCol()
  status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - запись' )
  If nKey == K_INS
    str_center( r1, ' Добавление услуги ' )
  Else
    str_center( r1, ' Редактирование ' )
  Endif
  f4_ff_uslugi( 0 )
  Do While .t.
    SetColor( cDataCGet )
    @ r1 + 1, 1 Say 'Шифр в счете (ФФОМС)' Get mshifr1 Picture '@!' ;
      When Empty( mshifr1 ) Valid f4_ff_uslugi( 1, nKey )
    @ r1 + 2, 1 Say 'Наименование услуги по справочнику Минздрава (ФФОМС)'
    @ r1 + 3, 2 Get mname1 When .f. Color color14
    @ r1 + 4, 1 Say 'Шифр услуги (в МО)' Get mshifr Picture '@!' Valid f4_ff_uslugi( 2, nKey )
    @ r1 + 5, 1 Say 'Наименование услуги' Get mname Picture '@S59'
    @ r1 + 6, 1 Say 'Профиль' Get MPROFIL ;
      reader {| x| menu_reader( x, tmp_V002, A__MENUVERT_SPACE, , , .f. ) }
    If is_zf_stomat == 1
      @ r1 + 7, 1 Say 'Ввод зубной формулы' Get mzf ;
        reader {| x| menu_reader( x, menu_nul, A__MENUVERT, , , .f. ) }
    Endif
    myread()
    If LastKey() != K_ESC
      fl := .t.
      If Empty( mshifr1 )
        fl := func_error( 'Не введен шифр Минздрава (ФФОМС). Нет записи.' )
      Endif
      If fl
        mywait()
        Select MOSU
        Set Order To 2
        If nKey == K_INS
          find ( Str( -1, 6 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 6 )
          Endif
          mkod := RecNo()
          mosu->kod := mkod
        Else
          find ( Str( mkod, 6 ) )
          g_rlock( forever )
        Endif
        mosu->name     := mname
        mosu->shifr    := mshifr
        mosu->shifr1   := mshifr1
        mosu->PROFIL   := m1PROFIL
        mosu->zf       := iif( m1zf, 1, 0 )
        Unlock
        Commit
        ret := mkod
      Else
        Loop
      Endif
    Endif
    Exit
  Enddo
  RestScreen( buf )
  SetColor( tmp_color )
  Select MOSU
  Set Order To 1
  Return ret

// 31.01.17
Function f4_ff_uslugi( k, nKey )

  Local fl := .t., rec, v1

  Select MOSU
  rec := RecNo()
  Do Case
  Case k == 0 // перед входом в GET
    mname1 := Space( 78 )
    If !Empty( mshifr1 )
      If m1tip > 0
        mname1 := PadR( 'удалена', 78 )
      Else
        Select LUSLF
        find ( mshifr1 )
        If Found()
          mname1 := PadR( luslf->name, 78 )
          If Empty( mname )
            mname := PadR( mname1, 65 )
          Endif
        Else
          mname1 := PadR( 'не найдена', 78 )
        Endif
      Endif
    Endif
  Case k == 1
    mshifr1 := transform_shifr( mshifr1 )
    Select LUSLF
    find ( mshifr1 )
    If Found()
      If nKey == K_INS
        Select MOSU
        Set Order To 4
        find ( mshifr1 )
        If Found()
          fl := func_error( 4, 'Данный шифр ФФОМС уже встречается в справочнике!' )
          mshifr1 := Space( 20 )
        Endif
      Endif
      If fl
        mname1 := PadR( luslf->name, 78 )
        If Empty( mname )
          mname := PadR( mname1, 65 )
        Endif
        update_gets()
      Endif
    Else
      fl := func_error( 1, 'Не найдена услуга с таким шифром' )
      mshifr1 := Space( 20 )
    Endif
  Case k == 2
    mshifr := transform_shifr( mshifr )
    If !Empty( mshifr )
      v1 := 0
      Set Order To 3
      find ( mshifr )
      Do While mosu->shifr == mshifr .and. !Eof()
        If nKey == K_INS
          ++v1
        Elseif RecNo() != rec
          ++v1
        Endif
        Skip
      Enddo
      If v1 > 0
        fl := func_error( 4, 'Данный шифр услуги уже встречается в справочнике!' )
        mshifr := Space( 10 )
      Endif
      If fl
        r_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
        find ( mshifr )
        If Found()
          fl := func_error( 4, 'Данный шифр услуги уже встречается в основном справочнике услуг!' )
          mshifr := Space( 10 )
        Endif
        dbCloseArea()
      Endif
    Endif
  Endcase
  Select MOSU
  Set Order To 1
  Goto ( rec )
  Return fl

// Редактирование справочника комплексных услуг (для удобства ввода данных)
Function f_k_uslugi( r1 )

  Local str_sem := 'Редактирование комплексных услуг'

  Default r1 To 2
  Private pr1 := r1, pc1 := 2, pc2 := 77, fl_found := .t.
  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
  g_use( dir_server + 'uslugi_k', dir_server + 'uslugi_k', 'UK' )
  Go Top
  If Eof()
    fl_found := .f.
    Keyboard Chr( K_INS )
  Endif
  alpha_browse( pr1, pc1, MaxRow() -2, pc2, 'f1_k_uslugi', color0, , , , , , , 'f2_k_uslugi', , ;
    { '═', '░', '═', , .t. } )
  Close databases
  g_sunlock( str_sem )
  Return Nil

//
Function f1_k_uslugi( oBrow )

  Local oColumn, n := 49

  oColumn := TBColumnNew( '   Шифр', {|| uk->shifr } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Наименование комплексной услуги', n ), {|| Left( uk->name, n ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Врач', {|| put_val( ret_tabn( uk->kod_vr ), 5 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Асс.', {|| put_val( ret_tabn( uk->kod_as ), 5 ) } )
  oBrow:addcolumn( oColumn )
  If Type( 'pr1' ) == 'N'
    status_key( '^<Esc>^ выход; ^<Enter>^ ред-ние; ^<Ins>^ добавление; ^<Del>^ удал.; ^<Ctrl+Enter>^ услуги' )
  Else
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор комплексной услуги' )
  Endif
  Return Nil

//
Function f2_k_uslugi( nKey, oBrow )

  Local buf, fl := .f., rec, k := -1, r := MaxRow() -9, tmp_color

  Do Case
  Case ( nKey == K_INS .or. ( nKey == K_ENTER .and. !emptyall( uk->shifr, uk->name ) ) ) ;
      .and. Type( 'pr1' ) == 'N'
    Save Screen To buf
    If nkey == K_INS .and. !fl_found
      ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N' )
    Endif
    If nKey == K_ENTER
      rec := RecNo()
    Endif
    Private mshifr, mname, gl_area := { 1, 0, MaxRow() -1, 79, 0 }, old_shifr, ;
      mkod_vr := if( nKey == K_INS, 0, uk->kod_vr ), ;
      mkod_as := if( nKey == K_INS, 0, uk->kod_as ), ;
      mtabn_vr := 0, mtabn_as := 0, ;
      mvrach := massist := Space( 35 )
    old_shifr := mshifr := if( nKey == K_INS, Space( 10 ), uk->shifr )
    mname := if( nKey == K_INS, Space( 60 ), uk->name )
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mvrach := PadR( perso->fio, 35 )
      mtabn_vr := perso->tab_nom
    Endif
    If mkod_as > 0
      Select PERSO
      Goto ( mkod_as )
      massist := PadR( perso->fio, 35 )
      mtabn_as := perso->tab_nom
    Endif
    tmp_color := SetColor( cDataCScr )
    box_shadow( r, pc1 + 1, MaxRow() -3, pc2 -1, , ;
      if( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
    SetColor( cDataCGet )
    @ r + 1, pc1 + 3 Say 'Шифр услуги' Get mshifr Picture '@!' Valid valid_shifr()
    @ r + 2, pc1 + 3 Say 'Наименование комплексной услуги'
    @ r + 3, pc1 + 5 Get mname
    @ r + 4, pc1 + 3 Say 'Таб.№ врача' Get mtabn_vr Pict '99999' valid {| g| f5editkusl( g, 2, 3 ) }
    @ Row(), Col() + 3 Get mvrach When .f. Color color14
    @ r + 5, pc1 + 3 Say 'Таб.№ ассистента' Get mtabn_as Pict '99999' valid {| g| f5editkusl( g, 2, 4 ) }
    @ Row(), Col() + 3 Get massist When .f. Color color14
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    Select UK
    If LastKey() != K_ESC .and. !emptyany( mshifr, mname )
      fl := .t.
      If !( old_shifr == mshifr )
        find ( mshifr )
        Do While uk->shifr == mshifr .and. !Eof()
          If iif( nKey == K_INS, .t., ( RecNo() != rec ) )
            fl := func_error( 4, 'Коплексная услуга с данным шифром уже присутствует в базе данных!' )
            Exit
          Endif
          Skip
        Enddo
        If nKey == K_ENTER
          Goto ( rec )
        Endif
      Endif
      If fl .and. f_esc_enter( 1 )
        mywait()
        If nKey == K_INS
          addrecn()
          fl_found := .t.
        Else
          g_rlock( forever )
        Endif
        Replace uk->shifr With mshifr, uk->name With mname, ;
          uk->kod_vr With mkod_vr, uk->kod_as With mkod_as
        Unlock
        Commit
        If nKey == K_ENTER .and. !( old_shifr == mshifr )
          g_use( dir_server + 'uslugi1k', { dir_server + 'uslugi1k' }, 'U1K' )
          Do While .t.
            find ( old_shifr )
            If !Found()
              Exit
            Endif
            g_rlock( forever )
            u1k->shifr := mshifr
            Unlock
          Enddo
          u1k->( dbCloseArea() )
          Select UK
        Endif
        oBrow:gotop()
        find ( mshifr )
        k := 0
      Endif
    Elseif nKey == K_INS .and. !fl_found
      k := 1
    Endif
    SetColor( tmp_color )
    Restore Screen From buf
  Case nKey == K_DEL .and. !emptyall( uk->shifr, uk->name ) ;
      .and. Type( 'pr1' ) == 'N' ;
      .and. f_esc_enter( 2, .t. )
    buf := save_maxrow()
    mywait()
    g_use( dir_server + 'uslugi1k', { dir_server + 'uslugi1k' }, 'U1K' )
    Do While .t.
      find ( uk->shifr )
      If !Found()
        Exit
      Endif
      deleterec( .t. )
    Enddo
    u1k->( dbCloseArea() )
    Select UK
    deleterec()
    oBrow:gotop()
    Go Top
    k := 0
    If Eof()
      k := 1
    Endif
    rest_box( buf )
  Case nKey == K_CTRL_ENTER .and. !Empty( uk->shifr ) ;
      .and. Type( 'pr1' ) == 'N'
    f3_k_uslugi()
    k := 0
  Endcase
  Return k

//
Function f3_k_uslugi()

  Local buf := SaveScreen(), adbf

  Private fl_found

  mywait()
  g_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
  g_use( dir_server + 'uslugi1k', { dir_server + 'uslugi1k' }, 'U1K' )
  adbf := dbStruct()
  AAdd( adbf, { 'rec_u1k', 'N', 6, 0 } )
  AAdd( adbf, { 'name', 'C', 64, 0 } )
  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' ) New Alias TMP
  Index On shifr1 to ( cur_dir() + 'tmp' )
  Select U1K
  find ( uk->shifr )
  If ( fl_found := Found() )
    adbf := Array( FCount() )
    Do While u1k->shifr == uk->shifr .and. !Eof()
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select USL
      find ( u1k->shifr1 )
      Select TMP
      Append Blank
      AEval( adbf, {| x, i| FieldPut( i, x ) } )
      tmp->rec_u1k := u1k->( RecNo() )
      tmp->name := usl->name
      Select U1K
      Skip
    Enddo
  Endif
  Select TMP
  Go Top
  If !fl_found
    Keyboard Chr( K_INS )
  Endif
  box_shadow( 0, 2, 0, 77, 'GR+/RB', 'Содержание комплексной услуги', , 0 )
  alpha_browse( 2, 1, MaxRow() -1, 77, 'f4_k_uslugi', color0, ;
    AllTrim( uk->shifr ) + '. ' + AllTrim( uk->name ), 'BG+/GR', ;
    .t., .t., , , 'f5_k_uslugi', , ;
    { '═', '░', '═', 'N/BG,W+/N,B/BG', .t., 58 } )
  u1k->( dbCloseArea() )
  usl->( dbCloseArea() )
  tmp->( dbCloseArea() )
  Select UK
  RestScreen( buf )
  Return Nil

//
Function f4_k_uslugi( oBrow )

  Local oColumn

  oColumn := TBColumnNew( '   Шифр', {|| tmp->shifr1 } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Наименование услуги', 64 ), {|| tmp->name } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход;  ^<Ins>^ - добавление;  ^<Del>^ - удаление' )
  Return Nil

//
Function f5_k_uslugi( nKey, oBrow )

  Local j := 0, k := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1 := MaxRow() -9, c1 := 2, ;
    rec_uk := uk->( RecNo() ), rec_tmp := tmp->( RecNo() ), ;
    rec_u1k := tmp->rec_u1k

  Do Case
  Case nKey == K_INS
    If !fl_found
      ColorWin( 5, 0, 5, 79, 'N/N', 'W+/N' )
    Endif
    Private mname := Space( 60 ), ;
      mshifr := Space( 10 ), ;
      gl_area := { 1, 0, MaxRow() -1, 79, 0 }
    buf1 := box_shadow( r1, c1, 21, 77, color8, ;
      'Добавление новой услуги в комплексную', cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, pc1 + 3 Say 'Шифр услуги' Get mshifr Picture '@!' ;
      Valid f6_k_uslugi()
    @ r1 + 3, pc1 + 3 Say 'Наименование услуги'
    @ r1 + 4, pc1 + 5 Get mname When .f.
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC .and. !Empty( mshifr ) .and. f_esc_enter( 1 )
      mywait()
      Select U1K
      addrecn()
      fl_found := .t.
      Replace u1k->shifr With uk->shifr, u1k->shifr1 With mshifr
      Unlock
      adbf := Array( FCount() )
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      rec_u1k := u1k->( RecNo() )
      Select TMP
      Append Blank
      rec_tmp := tmp->( RecNo() )
      AEval( adbf, {| x, i| FieldPut( i, x ) } )
      tmp->rec_u1k := u1k->( RecNo() )
      tmp->name := mname
      Commit
      k := 0
    Elseif !fl_found
      k := 1
    Endif
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
    rest_box( buf )
    rest_box( buf1 )
  Case nKey == K_DEL .and. !Empty( tmp->shifr ) .and. f_esc_enter( 2 )
    mywait()
    Select U1K
    Goto ( tmp->rec_u1k )
    deleterec( .t. )
    Select TMP
    deleterec( .t. )
    Commit
    k := 0
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f.
      k := 1
    Endif
    rest_box( buf )
  Otherwise
    Keyboard ''
  Endcase
  Return k

//
Function f6_k_uslugi()

  Local fl

  If ( fl := valid_shifr() )
    Select USL
    find ( mshifr )
    If Found()
      mname := usl->name
    Else
      fl := func_error( 4, 'Нет такого шифра в базе данных услуг!' )
    Endif
  Endif
  Return fl


// Редактирование коэффициентов трудоёмкости услуг (УЕТ)
Function f_trkoef()

  Local uslugi := { { 'kod',    'N', 4, 0 }, ;
    { 'name',   'C', 65, 0 }, ;
    { 'shifr',  'C', 10, 0 }, ;
    { 'vkoef_v', 'N', 7, 4 }, ;   // врач - УЕТ для взрослого
    { 'akoef_v', 'N', 7, 4 }, ;   // асс. - УЕТ для взрослого
    { 'vkoef_r', 'N', 7, 4 }, ;   // врач - УЕТ для ребенка
    { 'akoef_r', 'N', 7, 4 }, ;   // асс. - УЕТ для ребенка
    { 'koef_v', 'N', 7, 4 }, ;
    { 'koef_r', 'N', 7, 4 } }
  Local k1, k2, buf := save_maxrow(), fl, ;
    fl_plat := is_task( X_PLATN ), ; // для платных услуг
  str_sem := 'Редактирование коэффициентов - UCH_USL'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  mywait()
  dbCreate( cur_dir() + 'tmp', uslugi )
  Use ( cur_dir() + 'tmp' ) Alias tmp
  Index On fsort_usl( shifr ) to ( cur_dir() + 'tmp' )
  If useuch_usl() .and. r_use( dir_server + 'uslugi', , 'USL' )
    k1 := usl->( LastRec() )
    k2 := uu->( LastRec() )
    Select UU
    Do While k2 < k1
      g_rlock( .t., forever )
      Replace kod With RecNo()
      Unlock
      k2++
    Enddo
    Select USL
    Set Relation To Str( kod, 4 ) into UU
    Go Top
    Do While !Eof()
      If usl->kod > 0
        fl := ( usl->cena > 0 .or. usl->cena_d > 0 )
        If !fl .and. fl_plat
          fl := ( usl->pcena > 0 .or. usl->pcena_d > 0 .or. usl->dms_cena > 0 )
        Endif
        If !fl .and. ( usl->is_nul .or. usl->is_nulp ) // если возможен ввод услуги без цены
          fl := .t.
        Endif
        If fl
          Select TMP
          Append Blank
          tmp->kod     := usl->kod
          tmp->name    := usl->name
          tmp->shifr   := usl->shifr
          tmp->vkoef_v := uu->vkoef_v
          tmp->akoef_v := uu->akoef_v
          tmp->vkoef_r := uu->vkoef_r
          tmp->akoef_r := uu->akoef_r
          tmp->koef_v  := uu->koef_v
          tmp->koef_r  := uu->koef_r
        Endif
      Endif
      Select USL
      Skip
    Enddo
    Set Relation To
    usl->( dbCloseArea() )
    Select TMP
    dbCommit()
    Set Relation To Str( kod, 4 ) into UU
    Go Top
    Do While Empty( shifr ) .and. !Eof()
      Skip
    Enddo
    alpha_browse( 0, 0, MaxRow() -1, 79, 'f1_trkoef', color0, ;
      'Условные единицы трудоемкости услуг для взрослых и детей', 'BG+/GR', ;
      .f., , , , 'f2_trkoef', , ;
      { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,GR+/BG,BG+/GR,R/BG,BG+/R', .t., 180 } )
  Endif
  Close databases
  rest_box( buf )
  g_sunlock( str_sem )
  Return Nil

//
Function f1_trkoef( oBrow )

  Local k := 51, oColumn, ;
    blk := {|| if( tmp->koef_v > 0 .and. tmp->koef_r > 0, { 1, 2 }, ;
    if( tmp->koef_v > 0, { 3, 4 }, ;
    if( tmp->koef_r > 0, { 5, 6 }, { 7, 8 } ) ) ) }

  If is_oplata == 7
    k := 43
  Endif
  oColumn := TBColumnNew( '   Шифр;  услуги', {|| tmp->shifr } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Наименование услуги', k ), {|| Left( tmp->name, k ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If is_oplata == 7
    oColumn := TBColumnNew( 'Врач;УЕТ;взр.', {|| Str( tmp->vkoef_v, 5, 2 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( 'Асс.;УЕТ;взр.', {|| Str( tmp->akoef_v, 5, 2 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( 'Врач;УЕТ;дет.', {|| Str( tmp->vkoef_r, 5, 2 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( 'Асс.;УЕТ;дет.', {|| Str( tmp->akoef_r, 5, 2 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Else
    oColumn := TBColumnNew( 'УЕТ;взр.', {|| tmp->koef_v } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( 'УЕТ;дет.', {|| tmp->koef_r } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  status_key( '^<Esc>^ - выход;  ^<Enter>^ - редактирование коэффициентов;  ^<F2>^ - поиск по шифру' )
  Return Nil

//
Function f2_trkoef( nKey, oBrow )

  Static sshifr := '          '
  Local flag := -1, buf := save_maxrow(), tmp_color := SetColor(), mshifr, rec

  If nKey == K_F2
    rec := RecNo()
    If ( mshifr := input_value( 18, 10, 20, 69, color1, ;
        '  Введите необходимый шифр услуги для поиска', ;
        sshifr, '@K@!' ) ) != NIL
      sshifr := mshifr := transform_shifr( mshifr )
      find ( fsort_usl( mshifr ) )
      If Found()
        rec := RecNo()
        oBrow:gotop()
        Goto ( rec )
        flag := 0
      Else
        Goto ( rec )
        func_error( 4, 'Услуга с шифром "' + AllTrim( mshifr ) + '" не найдена!' )
      Endif
    Endif
  Elseif nKey == K_ENTER
    If ( rec := f3_e_trk( Row() ) ) > 0
      Select UU1
      Goto ( rec )
      Select UU
      g_rlock( forever )
      If is_oplata == 7
        uu->vkoef_v := uu1->vkoef_v ; uu->vkoef_r := uu1->vkoef_r
        uu->akoef_v := uu1->akoef_v ; uu->akoef_r := uu1->akoef_r
      Endif
      uu->koef_v := uu1->koef_v ; uu->koef_r := uu1->koef_r
      Unlock
      Commit
      Select TMP
      If is_oplata == 7
        tmp->vkoef_v := uu->vkoef_v ; tmp->vkoef_r := uu->vkoef_r
        tmp->akoef_v := uu->akoef_v ; tmp->akoef_r := uu->akoef_r
      Endif
      tmp->koef_v := uu->koef_v ; tmp->koef_r := uu->koef_r
    Endif
    Select TMP
    flag := 0
  Endif
  Return flag

//
Function f2_e_trk()

  Local rec := 0

  Select UU1
  find ( Str( uu->kod, 4 ) )
  Do While uu1->kod == uu->kod .and. !Eof()
    rec := uu1->( RecNo() )
    Skip
  Enddo
  Select UU
  Return rec

//
Function f3_e_trk( r )

  Local t_arr := Array( BR_LEN ), ret

  Private str_find := Str( uu->kod, 4 ), muslovie := 'uu->kod == uu1->kod'

  If r > MaxRow() / 2
    t_arr[ BR_TOP ] := r - 10
    t_arr[ BR_BOTTOM ] := r - 1
  Else
    t_arr[ BR_TOP ] := r + 1
    t_arr[ BR_BOTTOM ] := r + 10
  Endif
  t_arr[ BR_LEFT ] := 50
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color5
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  t_arr[ BR_OPEN ] := {| nk, ob| f4_e_trk( nk, ob, 'open' ) }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  t_arr[ BR_COLUMN ] := { { '   Дата;  начала; действия', {|| full_date( uu1->date_b ) } } }
  If is_oplata == 7
    t_arr[ BR_LEFT ] -= 6
    AAdd( t_arr[ BR_COLUMN ], { 'Врач;УЕТ;взр.', {|| Str( uu1->vkoef_v, 5, 2 ) } } )
    AAdd( t_arr[ BR_COLUMN ], { 'Асс.;УЕТ;взр.', {|| Str( uu1->akoef_v, 5, 2 ) } } )
    AAdd( t_arr[ BR_COLUMN ], { 'Врач;УЕТ;дет.', {|| Str( uu1->vkoef_r, 5, 2 ) } } )
    AAdd( t_arr[ BR_COLUMN ], { 'Асс.;УЕТ;дет.', {|| Str( uu1->akoef_r, 5, 2 ) } } )
  Else
    AAdd( t_arr[ BR_COLUMN ], { 'УЕТ;взр.', {|| uu1->koef_v } } )
    AAdd( t_arr[ BR_COLUMN ], { 'УЕТ;дет.', {|| uu1->koef_r } } )
  Endif
  t_arr[ BR_EDIT ] := {| nk, ob| f4_e_trk( nk, ob, 'edit' ) }
  Select UU1
  find ( str_find )
  If !Found()
    addrec( 4 )
    uu1->kod := uu->kod ; uu1->date_b := SToD( '19930101' )
    uu1->vkoef_v := uu->vkoef_v ; uu1->vkoef_r := uu->vkoef_r
    uu1->akoef_v := uu->akoef_v ; uu1->akoef_r := uu->akoef_r
    uu1->koef_v  := uu->koef_v  ; uu1->koef_r  := uu->koef_r
    Unlock
    Commit
  Endif
  edit_browse( t_arr )
  Select UU
  Return f2_e_trk()

//
Function f4_e_trk( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, rec1, r1, r2, tmp_color

  Do Case
  Case regim == 'open'
    find ( str_find )
    If ( ret := Found() )
      Keyboard Chr( K_CTRL_PGDN )  // встать на последнюю (по дате) запись
    Endif
  Case regim == 'edit'
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( uu1->kod ) )
      rec := RecNo()
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'W/W', 'GR+/R' )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, mpic := '99.99', mpic1 := '99.9999', ;
        mdate_b  := if( nKey == K_INS, sys_date, uu1->date_b ), ;
        mvkoef_v := if( nKey == K_INS, 0, uu1->vkoef_v ), ;
        mvkoef_r := if( nKey == K_INS, 0, uu1->vkoef_r ), ;
        makoef_v := if( nKey == K_INS, 0, uu1->akoef_v ), ;
        makoef_r := if( nKey == K_INS, 0, uu1->akoef_r ), ;
        mkoef_v  := if( nKey == K_INS, 0, uu1->koef_v ), ;
        mkoef_r  := if( nKey == K_INS, 0, uu1->koef_r )
      If is_oplata == 7
        r1 := Row() -3 ; r2 := r1 + 6
      Else
        r1 := Row() -2 ; r2 := r1 + 4
      Endif
      tmp_color := SetColor( cDataCScr )
      box_shadow( r1, pc1 - 40, r2, pc1 - 1, , ;
        if( nKey == K_INS, 'Добавление', 'Редактирование' ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ r1 + 1, pc1 - 38 Say 'Дата начала действия УЕТ' Get mdate_b Valid func_empty( mdate_b )
      If is_oplata == 7
        @ r1 + 2, pc1 - 38 Say 'УЕТ на взрослом приеме (врач)' Get mvkoef_v Pict mpic
        @ r1 + 3, pc1 - 38 Say 'УЕТ на взрослом приеме (врач)' Get makoef_v Pict mpic
        @ r1 + 4, pc1 - 38 Say 'УЕТ на детском  приеме (асс.)' Get mvkoef_r Pict mpic
        @ r1 + 5, pc1 - 38 Say 'УЕТ на детском  приеме (асс.)' Get makoef_r Pict mpic
      Else
        @ r1 + 2, pc1 - 38 Say 'УЕТ на взрослом приеме' Get mkoef_v Pict mpic1
        @ r1 + 3, pc1 - 38 Say 'УЕТ на детском  приеме' Get mkoef_r Pict mpic1
      Endif
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      If is_oplata == 7
        fl := !emptyall( mvkoef_v, makoef_v, mvkoef_r, makoef_r )
      Else
        fl := !emptyall( mkoef_v, mkoef_r )
      Endif
      If LastKey() != K_ESC .and. fl .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrec( 4 )
          Replace uu1->kod With uu->kod
          rec := RecNo()
        Else
          g_rlock( forever )
        Endif
        Replace uu1->date_b With mdate_b
        If is_oplata == 7
          uu1->vkoef_v := mvkoef_v ; uu1->vkoef_r := mvkoef_r
          uu1->akoef_v := makoef_v ; uu1->akoef_r := makoef_r
          mkoef_v := mvkoef_v + makoef_v
          mkoef_r := mvkoef_r + makoef_r
        Endif
        uu1->koef_v := mkoef_v ; uu1->koef_r := mkoef_r
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( uu1->kod ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof() .or. !&muslovie
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

// плановая месячная трудоемкость персонала
Function f_trpers()

  Static si := 1
  Local i, arr_m, mtitle, k1, k2, buf := save_maxrow(), ;
    str_sem := 'Редактирование плановой трудоемкости - UCH_PERS'

  If ( i := popup_prompt( T_ROW, T_COL + 5, si, { 'Среднемесячные УЕТ', ;
      'УЕТ за конкретный месяц' } ) ) == 0
    Return Nil
  Endif
  si := i
  Private lgod := 0, lmes := 0
  If i == 1
    mtitle := 'Плановые среднемесячные УЕТ персонала'
  Else
    If ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) == NIL
      Return Nil
    Endif
    lgod := arr_m[ 1 ]
    lmes := arr_m[ 2 ]
    mtitle := 'Плановые УЕТ персонала ' + arr_m[ 4 ]
  Endif
  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  mywait()
  If g_use( dir_server + 'uch_pers', dir_server + 'uch_pers', 'UCHP' ) .and. ;
      r_use( dir_server + 'mo_pers', , 'PERSO' )
    Index On Str( kod, 4 ) to ( cur_dir() + 'tmp_pers' ) For kod > 0
    Select UCHP
    Set Order To 0
    Go Top
    Do While !Eof()
      If Empty( uchp->m_trud )
        deleterec( .t. )
      Else
        Select PERSO
        find ( Str( uchp->kod, 4 ) )
        If !Found()
          Select UCHP
          deleterec( .t. )
        Endif
      Endif
      Select UCHP
      Skip
    Enddo
    Commit
    Set Order To 1
    Select PERSO
    Go Top
    Do While !Eof()
      Select UCHP
      find ( Str( perso->kod, 4 ) + Str( lgod, 4 ) + Str( lmes, 2 ) )
      If !Found()
        addrec( 4 )
        uchp->kod := perso->kod
        uchp->god := lgod
        uchp->mes := lmes
        Unlock
      Endif
      Select PERSO
      Skip
    Enddo
    Commit
    Select UCHP
    Set Relation To Str( kod, 4 ) into PERSO
    Index On Upper( perso->fio ) to ( cur_dir() + 'tmp_uch' ) For god == lgod .and. mes == lmes
    Set Index to ( cur_dir() + 'tmp_uch' ), ( dir_server + 'uch_pers' )
    Go Top
    alpha_browse( 2, 2, MaxRow() -2, 77, 'f1_trpers', color0, mtitle, 'BG+/GR', ;
      .f., , , , 'f2_trpers', , {, , , 'N/BG,W+/N,B/BG,BG+/B', .t., 180 } )
  Endif
  Close databases
  rest_box( buf )
  g_sunlock( str_sem )
  Return Nil

//
Function f1_trpers( oBrow )

  Local oColumn, blk := {|| if( uchp->m_trud > 0, { 1, 2 }, { 3, 4 } ) }

  oColumn := TBColumnNew( 'Таб.№', ;
    {|| iif( perso->tab_nom > 0, Str( perso->tab_nom, 5 ), '-----' ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Ф.И.О.', 50 ), {|| perso->fio } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'У.Е.Т.', {|| uchp->m_trud } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход;  ^<Enter>^ - редактирование плановых УЕТ' )
  Return Nil

//
Function f2_trpers( nKey, oBrow )

  Local flag := -1, buf := save_maxrow(), tmp_color := SetColor(), ;
    mshifr, rec
  Private mm_trud

  If nKey == K_ENTER .or. Between( nKey, 48, 57 )
    If Empty( perso->tab_nom )
      Keyboard ''
      Return flag
    Endif
    SetColor( 'GR+/RB,GR+/RB, , ,G+/RB' )
    mm_trud := uchp->m_trud
    If Between( nKey, 48, 57 )
      Keyboard Chr( nkey )
    Endif
    @ Row(), 67 Get mm_trud
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение смены УЕТ' )
    myread()
    If LastKey() != K_ESC .and. Updated()
      Select UCHP
      g_rlock( forever )
      uchp->m_trud := mm_trud
      Unlock
      Commit
    Endif
    rest_box( buf )
    SetColor( tmp_color ) ; flag := 0
  Endif
  Return flag

// Редактирование справочника услуг, которые не должны быть оказаны в один день
Function f_ns_uslugi()

  Local str_sem, r1 := T_ROW

  Private pr1 := r1, pc1 := T_COL + 5, pc2 := T_COL + 5 + 33, fl_found := .t.

  str_sem := 'Редактирование несовместимых услуг'
  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  g_use( dir_server + 'ns_usl', , 'UK' )
  Index On Upper( name ) to ( cur_dir() + 'tmp_usl' )
  Go Top
  If Eof()
    fl_found := .f.
    Keyboard Chr( K_INS )
  Endif
  alpha_browse( pr1, pc1, MaxRow() -2, pc2, 'f1_ns_uslugi', color0, , , , , , , 'f2_ns_uslugi', , ;
    {, , , , .t. } )
  Close databases
  g_sunlock( str_sem )
  Return Nil

//
Function f2_ns_uslugi( nKey, oBrow )

  Local buf, fl := .f., rec, rec1, k := -1, r := MaxRow() -7, tmp_color
  Local sh := 80, HH := 57

  Do Case
  Case nKey == K_F9
    buf := save_maxrow()
    rec := RecNo()
    mywait()
    fp := FCreate( 'n_uslugi' + stxt() ) ; n_list := 1 ; tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Услуги, не совместимые по дате', sh ) )
    r_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
    r_use( dir_server + 'ns_usl_k', dir_server + 'ns_usl_k', 'U1K' )
    Set Relation To shifr into USL
    Select UK
    Go Top
    Do While !Eof()
      verify_ff( HH - 3, .t., sh )
      add_string( '' )
      add_string( RTrim( uk->name ) )
      Select U1K
      find ( Str( uk->( RecNo() ), 6 ) )
      Do While u1k->kod == uk->( RecNo() ) .and. !Eof()
        verify_ff( HH, .t., sh )
        add_string( '   ' + u1k->shifr + ' ' + RTrim( usl->name ) )
        Skip
      Enddo
      Select UK
      Skip
    Enddo
    FClose( fp )
    viewtext( 'n_uslugi' + stxt(), , , , , , , 2 )
    usl->( dbCloseArea() )
    u1k->( dbCloseArea() )
    Select UK
    Goto ( rec )
    rest_box( buf )
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( uk->name ) )
    Save Screen To buf
    If nkey == K_INS .and. !fl_found
      ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N' )
    Endif
    If nKey == K_ENTER
      rec := RecNo()
    Endif
    Private mname, gl_area := { 1, 0, MaxRow() -1, 79, 0 }
    mname := if( nKey == K_INS, Space( 30 ), uk->name )
    tmp_color := SetColor( cDataCScr )
    box_shadow( r, pc1 + 1, MaxRow() -3, pc2 - 1, , ;
      if( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
    SetColor( cDataCGet )
    @ r + 2, pc1 + 3 Say 'Наименование'
    @ r + 3, pc1 + 3 Get mname Pict '@S29'
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC .and. !Empty( mname ) .and. f_esc_enter( 1 )
      mywait()
      If nKey == K_INS
        addrecn()
        fl_found := .t.
        rec := RecNo()
      Else
        g_rlock( forever )
      Endif
      Replace uk->name With mname
      Unlock
      Commit
      oBrow:gotop()
      Goto ( rec )
      k := 0
    Elseif nKey == K_INS .and. !fl_found
      k := 1
    Endif
    SetColor( tmp_color )
    Restore Screen From buf
  Case nKey == K_DEL .and. !Empty( uk->name ) .and. f_esc_enter( 2, .t. )
    buf := save_maxrow()
    mywait()
    g_use( dir_server + 'ns_usl_k', dir_server + 'ns_usl_k', 'U1K' )
    Do While .t.
      find ( Str( uk->( RecNo() ), 6 ) )
      If !Found() ; exit ; Endif
      deleterec( .t. )
    Enddo
    u1k->( dbCloseArea() )
    Select UK
    deleterec()
    oBrow:gotop()
    Go Top
    k := 0
    If Eof()
      k := 1
    Endif
    rest_box( buf )
  Case nKey == K_CTRL_ENTER .and. !Empty( uk->name )
    f3_ns_uslugi()
    k := 0
  Endcase
  Return k

//
Function f3_ns_uslugi()

  Local buf := SaveScreen(), adbf
  Private fl_found

  mywait()
  r_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
  g_use( dir_server + 'ns_usl_k', dir_server + 'ns_usl_k', 'U1K' )
  adbf := dbStruct()
  AAdd( adbf, { 'rec_u1k', 'N', 6, 0 } )
  AAdd( adbf, { 'name', 'C', 64, 0 } )
  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' ) New Alias TMP
  Index On shifr to ( cur_dir() + 'tmp' )
  Select U1K
  find ( Str( uk->( RecNo() ), 6 ) )
  If ( fl_found := Found() )
    Do While u1k->kod == uk->( RecNo() ) .and. !Eof()
      Select USL
      find ( u1k->shifr )
      Select TMP
      Append Blank
      tmp->kod := uk->( RecNo() )
      tmp->shifr := u1k->shifr
      tmp->rec_u1k := u1k->( RecNo() )
      tmp->name := usl->name
      Select U1K
      Skip
    Enddo
  Endif
  Select TMP
  Go Top
  If !fl_found ; Keyboard Chr( K_INS ) ; Endif
  box_shadow( 0, 2, 0, 77, 'GR+/RB', 'Список несовместимых услуг', , 0 )
  alpha_browse( 2, 1, MaxRow() -1, 77, 'f4_ns_uslugi', color0, AllTrim( uk->name ), 'BG+/GR', ;
    .t., .t., , , 'f5_ns_uslugi', , ;
    { '═', '░', '═', 'N/BG,W+/N,B/BG', .t., 58 } )
  u1k->( dbCloseArea() )
  usl->( dbCloseArea() )
  tmp->( dbCloseArea() )
  Select UK
  RestScreen( buf )
  Return Nil

//
Function f4_ns_uslugi( oBrow )

  Local oColumn

  oColumn := TBColumnNew( '   Шифр', {|| tmp->shifr } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Наименование услуги', 64 ), {|| tmp->name } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход;  ^<Ins>^ - добавление;  ^<Del>^ - удаление' )
  Return Nil

//
Function f5_ns_uslugi( nKey, oBrow )

  Local j := 0, k := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1 := MaxRow() -10, c1 := 2, ;
    rec_uk := uk->( RecNo() ), rec_tmp := tmp->( RecNo() ), ;
    rec_u1k := tmp->rec_u1k

  Do Case
  Case nKey == K_INS
    If !fl_found
      ColorWin( 5, 0, 5, 79, 'N/N', 'W+/N' )
    Endif
    Private mname := Space( 60 ), ;
      mshifr := Space( 10 ), ;
      gl_area := { 1, 0, MaxRow() -1, 79, 0 }
    buf1 := box_shadow( r1, c1, MaxRow() -3, 77, color8, ;
      'Добавление новой услуги в список несовместимых', cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, pc1 + 3 Say 'Шифр услуги' Get mshifr Picture '@!' ;
      Valid f6_ns_uslugi()
    @ r1 + 3, pc1 + 3 Say 'Наименование услуги'
    @ r1 + 4, pc1 + 5 Get mname When .f.
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC .and. !Empty( mshifr ) .and. f_esc_enter( 1 )
      mywait()
      Select U1K
      addrecn()
      fl_found := .t.
      Replace u1k->kod With uk->( RecNo() ), u1k->shifr With mshifr
      Unlock
      rec_u1k := u1k->( RecNo() )
      Select TMP
      Append Blank
      rec_tmp := tmp->( RecNo() )
      tmp->kod := uk->( RecNo() )
      tmp->shifr := mshifr
      tmp->name := mname
      tmp->rec_u1k := u1k->( RecNo() )
      Commit
      k := 0
    Elseif !fl_found
      k := 1
    Endif
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
    rest_box( buf ) ; rest_box( buf1 )
  Case nKey == K_DEL .and. !Empty( tmp->shifr ) .and. f_esc_enter( 2 )
    mywait()
    Select U1K
    Goto ( tmp->rec_u1k )
    deleterec( .t. )
    Select TMP
    deleterec( .t. )
    Commit
    k := 0
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f. ; k := 1
    Endif
    rest_box( buf )
  Otherwise
    Keyboard ''
  Endcase
  Return k

//
Function f6_ns_uslugi()

  Local fl

  If ( fl := valid_shifr() )
    Select USL
    find ( mshifr )
    If Found()
      mkod := usl->kod
      mname := usl->name
    Else
      fl := func_error( 4, 'Нет такого шифра в базе данных услуг!' )
    Endif
  Endif
  Return fl

// Ввод/редактирование услуг, у которых не вводится врач (ассистент)
Function f_usl_uva()

  Local t_arr[ BR_LEN ], mtitle := 'Услуги, где не вводится врач (асс.)'

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL + 5
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 41
  t_arr[ BR_OPEN ] := {|| f1_usl_uva( , , 'open' ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_ARR_BROWSE ] := {, , , , .t. }
  t_arr[ BR_COLUMN ] := { { '   Шифр', {|| dbf1->shifr } }, ;
    { 'Врача нет?', {|| PadC( if( dbf1->kod_vr == 1, '//', '' ), 10 ) } }, ;
    { 'Асс-та нет?', {|| PadC( if( dbf1->kod_as == 1, '//', '' ), 12 ) } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_usl_uva( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Return Nil

//
Function f1_usl_uva( nKey, oBrow, regim, lrec )

  Local ret := -1, mm_da_net := { { 'да ', 0 }, { 'НЕТ', 1 } }
  Local buf, fl := .f., rec, rec1, k := MaxRow() -7, tmp_color

  Do Case
  Case regim == 'open'
    g_use( dir_server + 'usl_uva', dir_server + 'usl_uva', 'DBF1' )
    Go Top
    If ( ret := !Eof() ) .and. lrec != Nil .and. lrec > 0
      Goto ( lrec )
    Endif
  Case regim == 'edit'
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( dbf1->shifr ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N' )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
        mshifr := if( nKey == K_INS, Space( 10 ), dbf1->shifr ), ;
        mkod_vr, m1kod_vr := if( nKey == K_INS, 0, dbf1->kod_vr ), ;
        mkod_as, m1kod_as := if( nKey == K_INS, 0, dbf1->kod_as )
      tmp_color := SetColor( cDataCScr )
      mkod_vr := inieditspr( A__MENUVERT, mm_da_net, m1kod_vr )
      mkod_as := inieditspr( A__MENUVERT, mm_da_net, m1kod_as )
      box_shadow( k, pc1 + 1, MaxRow() -3, pc2 - 1, , ;
        if( nKey == K_INS, 'Добавление', 'Редактирование' ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say 'Шифр услуги (шаблон)' Get mshifr ;
        valid {| g| f2_usl_diag( g, nKey ) }
      @ k + 2, pc1 + 3 Say 'Вводится код врача' Get mkod_vr ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
      @ k + 3, pc1 + 3 Say 'Вводится код ассистента' Get mkod_as ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      If LastKey() != K_ESC .and. !Empty( mshifr ) ;
          .and. !emptyall( m1kod_vr, m1kod_as ) ;
          .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrecn()
        Else
          g_rlock( forever )
        Endif
        Replace dbf1->shifr With mshifr, ;
          dbf1->kod_vr With m1kod_vr, dbf1->kod_as With m1kod_as
        Unlock
        Commit
        oBrow:gotop()
        find ( mshifr )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( dbf1->shifr ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function f2_usl_diag( get, nKey )

  Local fl := .t., rec := 0

  mshifr := transform_shifr( mshifr )
  If mshifr != get:original
    rec := RecNo()
    find ( mshifr )
    If Found()
      fl := func_error( 4, 'Данный шифр уже присутствует в справочнике!' )
    Endif
    Goto ( rec )
    If !fl
      mshifr := get:original
    Endif
  Endif
  Return fl

// Ввод/редактирование услуг, которые могут быть оказаны человеку только раз в году
Function f_usl_raz()

  Local buf := SaveScreen(), adbf, i, n_file := dir_server + 'usl1year' + smem()

  Private fl_found := .f., arr_usl1year := {}

  If hb_FileExists( n_file )
    arr_usl1year := rest_arr( n_file )
  Endif
  mywait()
  r_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
  adbf := { { 'kod', 'N', 4, 0 }, ;
    { 'shifr', 'C', 10, 0 }, ;
    { 'name', 'C', 64, 0 } }
  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' ) New Alias TMP
  Index On fsort_usl( shifr ) to ( cur_dir() + 'tmp' )
  For i := 1 To Len( arr_usl1year )
    fl_found := .t.
    Select USL
    Goto ( arr_usl1year[ i ] )
    Select TMP
    Append Blank
    tmp->kod := arr_usl1year[ i ]
    tmp->shifr := usl->shifr
    tmp->name := usl->name
  Next
  Select TMP
  Go Top
  If !fl_found
    Keyboard Chr( K_INS )
  Endif
  box_shadow( 0, 2, 0, 77, 'GR+/RB', 'Список услуг, которые разрешается вводить только раз в году', , 0 )
  alpha_browse( 2, 1, MaxRow() -1, 77, 'f4_ns_uslugi', color0, , , .t., .t., , , 'f1_usl_raz', , ;
    { '═', '░', '═', 'N/BG,W+/N,B/BG', .t., 58 } )
  Close databases
  RestScreen( buf )
  If f_esc_enter( 1 )
    arr_usl1year := {}
    Use ( cur_dir() + 'tmp' )
    Go Top
    Do While !Eof()
      If !Empty( tmp->kod )
        AAdd( arr_usl1year, tmp->kod )
      Endif
      Skip
    Enddo
    save_arr( arr_usl1year, n_file )
  Endif
  Close databases
  Return Nil

//
Function f1_usl_raz( nKey, oBrow )

  Local j := 0, k := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1 := MaxRow() -10, c1 := 2, ;
    rec_tmp := tmp->( RecNo() )

  Do Case
  Case nKey == K_INS
    If !fl_found
      ColorWin( 5, 0, 5, 79, 'N/N', 'W+/N' )
    Endif
    Private mkod := 0, ;
      mname := Space( 60 ), ;
      mshifr := Space( 10 ), ;
      gl_area := { 1, 0, MaxRow() -1, 79, 0 }
    buf1 := box_shadow( r1, c1, MaxRow() -3, 77, color8, ;
      'Добавление новой услуги в список', cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, pc1 + 3 Say 'Шифр услуги' Get mshifr Picture '@!' ;
      Valid f6_ns_uslugi()
    @ r1 + 3, pc1 + 3 Say 'Наименование услуги'
    @ r1 + 4, pc1 + 5 Get mname When .f.
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC .and. !Empty( mshifr ) .and. f_esc_enter( 1 )
      mywait()
      Select TMP
      Append Blank
      tmp->kod := mkod
      tmp->shifr := mshifr
      tmp->name := mname
      rec_tmp := tmp->( RecNo() )
      Commit
      k := 0
    Elseif !fl_found
      k := 1
    Endif
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
    rest_box( buf )
    rest_box( buf1 )
  Case nKey == K_DEL .and. !Empty( tmp->shifr ) .and. f_esc_enter( 2 )
    mywait()
    Select TMP
    deleterec( .t. )
    Commit
    k := 0
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f.
      k := 1
    Endif
    rest_box( buf )
  Otherwise
    Keyboard ''
  Endcase
  Return k

// 08.11.22
Function f5_uslugi( r1, c1 )

  Local c2 := c1 + 50, str_sem := 'Редактирование служб'

  Private pr1 := r1, pc1, pc2

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  If c2 > 77
    c2 := 77
    c1 := 27
  Endif
  pc1 := c1
  pc2 := c2
  g_use( dir_server + 'slugba', dir_server + 'slugba', 'SL' )
  Go Top
  If LastRec() == 0
    addrec( 3 )
    Unlock
    Keyboard Chr( K_INS )
  Elseif LastRec() == 1 .and. sl->shifr == 0 .and. Empty( sl->name )
    Keyboard Chr( K_INS )
  Endif
  alpha_browse( r1, c1, MaxRow() -2, c2, 'f51_uslugi', color0, , , , , , , 'f52_uslugi', , ;
    {, , , , .t. } )
  dbCloseArea()
  g_sunlock( str_sem )
  Return Nil

//
Function f51_uslugi( oBrow )

  Local oColumn

  oColumn := TBColumnNew( 'Шифр', {|| sl->shifr } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Наименование службы', 40 ), {|| sl->name } )
  oBrow:addcolumn( oColumn )
  If Type( 'pr1' ) == 'N'
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ins>^ - добавление;  ^<Del>^ - удаление' )
  Else
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор службы' )
  Endif
  Return Nil

//
Function f52_uslugi( nKey, oBrow )

  Local buf, fl := .f., rec, rec1, k := MaxRow() -7, tmp_color

  Do Case
  Case nKey == K_INS .or. nKey == K_ENTER
    Save Screen To buf
    If nkey == K_INS .and. LastRec() == 1 .and. sl->shifr == 0 .and. Empty( sl->name )
      ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N' )
    Endif
    If nKey == K_ENTER
      rec := RecNo()
    Endif
    Private mshifr, mname, gl_area := { 1, 0, MaxRow() -1, 79, 0 }, old_shifr
    old_shifr := mshifr := if( nKey == K_INS, 0, sl->shifr )
    mname := if( nKey == K_INS, Space( 40 ), sl->name )
    tmp_color := SetColor( cDataCScr )
    box_shadow( k, pc1 + 1, MaxRow() -3, pc2 -1, , ;
      if( nKey == K_INS, 'Добавление', 'Редактирование' ) + ' службы', cDataPgDn )
    SetColor( cDataCGet )
    @ k + 1, pc1 + 3 Say 'Шифр службы' Get mshifr Picture '999'
    @ k + 2, pc1 + 3 Say 'Наименование службы'
    @ k + 3, pc1 + 5 Get mname Valid func_empty( mname )
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    k := -1
    If LastKey() != K_ESC
      fl := .t.
      If nKey == K_ENTER .and. old_shifr != mshifr
        find ( Str( mshifr, 3 ) )
        Do While sl->shifr == mshifr .and. !Eof()
          If RecNo() != rec
            fl := func_error( 4, 'Служба с данным шифром уже присутствует в базе данных!' )
            Exit
          Endif
          Skip
        Enddo
        Goto ( rec )
      Endif
      If fl .and. f_esc_enter( 1 )
        mywait()
        If nKey == K_INS
          fl := .f.
          If LastRec() == 1
            Go Top
            If sl->shifr == 0 .and. Empty( sl->name )
              g_rlock( forever )
              fl := .t.
            Endif
          Endif
          If !fl
            addrec( 3 )
          Endif
        Else
          g_rlock( forever )
        Endif
        Replace sl->shifr With mshifr, sl->name With mname
        Unlock
        Commit
        If nKey == K_ENTER .and. old_shifr != mshifr
          g_use( dir_server + 'uslugi', { dir_server + 'uslugisl' }, 'USL' )
          Do While .t.
            find ( Str( old_shifr, 3 ) )
            If !Found()
              Exit
            Endif
            g_rlock( forever )
            usl->slugba := mshifr
            Unlock
          Enddo
          usl->( dbCloseArea() )
          Select SL
        Endif
        oBrow:gotop()
        find ( Str( mshifr, 3 ) )
        k := 0
      Endif
    Elseif nKey == K_INS .and. LastRec() == 1
      Go Top
      If sl->shifr == 0 .and. Empty( sl->name )
        k := 1
      Endif
    Endif
    SetColor( tmp_color )
    Restore Screen From buf
    Return k
  Case nKey == K_DEL .and. !Empty( sl->name ) .and. f_esc_enter( 2 )
    r_use( dir_server + 'uslugi', { dir_server + 'uslugisl' }, 'USL' )
    find ( Str( sl->shifr, 3 ) )
    fl := Found()
    dbCloseArea()
    Select SL
    If fl
      func_error( 4, 'Данная служба присутствует в справочнике услуг. Удаление запрещено!' )
    Else
      deleterec()
      Return 0
    Endif
  Endcase
  Return -1
