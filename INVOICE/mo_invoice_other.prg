// mo_invoice_other.prg - прочие счета для задачи ОМС
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 28.12.21
Function other_schets( k )

  Static si1 := 2
  Local mas_pmt, mas_msg, mas_fun, j, str_sem

  Default k To 1
  Do Case
  Case k == 1
    If ! hb_user_curUser:isadmin()
      Return func_error( 4, err_admin )
    Endif
    mas_pmt := { "Список ~прочих счетов", ;
      "~Невыписанные счета", ;
      "Выписка ~счёта", ;
      "~Возврат счёта" }
    mas_msg := { "Просмотр/печать прочих счетов", ;
      "Составление прочего счёта через режим невыписанных счетов", ;
      "Составление прочего счёта по конкретной компании", ;
      "Возврат прочего счёта" }
    mas_fun := { "other_schets(11)", ;
      "other_schets(12)", ;
      "other_schets(13)", ;
      "other_schets(14)" }
    str_sem := "Работа со счетами"
    If !g_slock( str_sem )
      Return func_error( 4, "В данный момент со счетами работает другой пользователь." )
    Endif
    popup_prompt( T_ROW, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
    g_sunlock( str_sem )
  Case k == 11
    other_schet_view()
  Case k == 12
    other_schet_nevyp()
  Case k == 13
    other_schet_vyp()
  Case k == 14
    other_schet_vozvrat()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// Просмотр списка счетов, печать счетов
Function other_schet_view()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code, ;
    mdate := SToD( "20110101" )

  mywait()
  r_use( dir_server + "mo_rees", , "REES" )
  g_use( dir_server + "mo_xml", , "MO_XML" )
  g_use( dir_server + "schet_", , "SCHET_" )
  g_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + schet_->nschet to ( cur_dir() + "tmp_sch" ) ;
    For schet_->dschet >= mdate .and. !Empty( pdate ) .and. ;
    !( schet_->IS_DOPLATA == 1 .or. !Empty( Val( schet_->smo ) ) ) ;
    DESCENDING
  Go Top
  If Eof()
    RestScreen( buf )
    Close databases
    Return func_error( 4, "Нет выписанных счетов c " + date_month( mdate ) )
  Endif
  chm_help_code := 1// H_opl_schet
  alpha_browse( T_ROW, 0, 23, 79, "f1_view_other_schet", color0, , , , , , , ;
    "f2_view_other_schet", , { '═', '░', '═', "N/BG,W+/N", .t., 60 } )
  Close databases
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil

//
Function f1_view_other_schet( oBrow )

  Local s, oColumn, blk

  oColumn := TBColumnNew( "Номер счета", {|| schet->nomer_s } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "   Дата", {|| full_date( schet_->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Сумма счета", {|| put_kop( schet->summa, 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Кол.;бол.", {|| Str( schet->kol, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Принадлежность;счета", {|| PadR( f4_view_list_schet(), 34 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход ^<F7>^ печать акта ^<F8>^ печать счёта-фактуры ^<F9>^ печать счёта" )

  Return Nil

// 06.12.12
Function f2_view_other_schet( nKey, oBrow )

  Local ret := -1, rec := schet->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}

  Do Case
  Case nKey == K_F9
    print_other_schet( 1 )
    ret := 0
  Case nKey == K_F8
    print_faktura( 1 )
    ret := 0
  Case nKey == K_F7
    print_akt( 1 )
    ret := 0
  Endcase
  Select SCHET
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// невыписанные счета
Function other_schet_nevyp()

  Local buf := save_maxrow(), k := 0, s1, s2, mstr_crb, gnevyp_schet := .f.

  If !myfiledeleted( cur_dir() + "tmp" + sdbf )
    Return Nil
  Endif
  Private pkol := 0, psumma := 0
  mywait()
  dbCreate( cur_dir() + "tmp", { ;
    { "KOMU",   "N",     1,     0 }, ;
    { "STR_CRB",   "N",     2,     0 }, ;
    { "MIN_DATE",   "D",     8,     0 }, ;
    { "DNI",   "N",     3,     0 }, ;
    { "KOL_BOLN",   "N",     6,     0 }, ;
    { "SUMMA",   "N",    13,     2 }, ;
    { "NKOMU",   "C",    80,     0 }, ;
    { "KOD",   "N",     7,     0 }, ;
    { "PLUS",   "L",     1,     0 } } )
  Use ( cur_dir() + "tmp" ) Alias TMP
  Index On Str( komu, 1 ) + Str( str_crb, 2 ) to ( cur_dir() + "tmp" )
  Index On nkomu to ( cur_dir() + "tmp1" )
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ), ( cur_dir() + "tmp1" ) Alias TMP
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  find ( Str( 0, 6 ) + Str( B_STANDART, 1 ) )
  Do While human->schet == 0 .and. human->tip_h == B_STANDART .and. !Eof()
    If human_->reestr == 0 .and. ;
        human->cena_1 > 0 .and. human->komu > 0 .and. Empty( Val( human_->smo ) )
      mstr_crb := iif( human->komu == 5, 0, human->str_crb )
      Select TMP
      find ( Str( human->komu, 1 ) + Str( mstr_crb, 2 ) )
      If Found() .and. human->komu != 5
        tmp->kol_boln++
        tmp->summa += human->cena_1
        tmp->min_date := Min( tmp->min_date, human->k_data )
      Else
        k++
        Append Blank
        Replace tmp->komu With human->komu, ;
          tmp->str_crb With mstr_crb, ;
          tmp->kol_boln With 1, tmp->summa With human->cena_1, ;
          tmp->min_date With human->k_data, ;
          tmp->plus With .t.
        If human->komu == 5
          Replace tmp->nkomu With " Личн.счет - " + AllTrim( human->fio ) + ", " + ;
            Left( DToC( human->n_data ), 5 ) + "-" + date_8( human->k_data ), ;
            tmp->kod With human->kod
        Endif
      Endif
      pkol++; psumma += human->cena_1
    Endif
    Select HUMAN
    Skip
  Enddo
  If k == 0
    rest_box( buf )
    func_error( 4, "В базе данных нет больных, по которым не выписаны прочие счета!" )
  Else
    human_->( dbCloseArea() )
    human->( dbCloseArea() )
    Select TMP
    Set Order To 0
    Go Top
    Do While !Eof()
      If tmp->komu != 5
        tmp->nkomu := func1_komu( tmp->komu, tmp->str_crb )
      Endif
      k := sys_date - tmp->min_date
      tmp->dni := iif( Between( k, 1, 999 ), k, -99 )
      Skip
    Enddo
    Set Order To 2
    Go Top
    rest_box( buf )
    s1 := " Общее количество больных - " + expand_value( pkol ) + " чел. "
    s2 := " Общая сумма счетов - " + expand_value( psumma, 2 ) + " руб. "
    k := 80 -Max( Len( s1 ), Len( s2 ) )
    buf := box_shadow( T_ROW - 3, k, T_ROW - 2, 79, color1, , , 0 )
    @ T_ROW - 3, k Say s1 Color color8
    @ T_ROW - 2, k Say s2 Color color8
    If alpha_browse( T_ROW, 0, 23, 79, "f1nevyp_schet", color0, ;
        "Невыписанные счета", "R/BG", , , , , "f2nevyp_schet", , ;
        { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B,R/BG", .f., 0 } )
      gnevyp_schet := .t.
      If ( glob_komu := tmp->komu ) == 1
        glob_strah[ 1 ] := tmp->str_crb
      Elseif glob_komu == 3
        glob_komitet[ 1 ] := tmp->str_crb
      Endif
      glob_all := { tmp->str_crb, RTrim( tmp->nkomu ) }
      If glob_komu == 5
        glob_all := { tmp->kod, RTrim( tmp->nkomu ) }
      Endif
    Endif
    rest_box( buf )
  Endif
  Close databases
  If gnevyp_schet
    vyp1other_schet( .f., glob_komu, glob_all[ 1 ] )
  Endif

  Return Nil

//
Function f1nevyp_schet( oBrow )

  Local oColumn, n := 57, blk

  oColumn := TBColumnNew( Center( "Принадлежность счета", n ), {|| Left( tmp->nkomu, n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Дни;max", {|| put_val( tmp->dni, 3 ) } )
  oColumn:defColor := { 5, 5 }
  oColumn:colorBlock := {|| { 5, 5 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Кол.;бол.", {|| Str( tmp->kol_boln, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Сумма счета", {|| Str( tmp->summa, 11, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход;  ^<F10>^ - проверка цен;  ^<Enter>^ - вход в режим "Выписка счета"' )

  Return Nil

//
Function f2nevyp_schet( nKey, oBrow )

  Local iprov := 0, inprov := 0
  Local buf, rec, k := -1, sh := 80, HH := 60, nfile := "err_sl.txt", j := 0

  Do Case
  Case nkey == K_F10
    buf := save_maxrow()
    mywait()
    rec := tmp->( RecNo() )
    fp := FCreate( nfile ) ; n_list := 1 ; tek_stroke := 0
    add_string( "" )
    add_string( Center( "Список обнаруженных ошибок по невыписанным счетам", 80 ) )
    add_string( Center( AllTrim( tmp->nkomu ), 80 ) )
    add_string( "" )
    //
    r_use( dir_server + "mo_pers", , "PERS" )
    r_use( dir_server + "mo_uch", , "UCH" )
    r_use( dir_server + "mo_otd", , "OTD" )
    use_base( "lusl" )
    use_base( "luslc" )
    r_use( dir_server + "uslugi", , "USL" )
    r_use( dir_server + "human_u_", , "HU_" )
    r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
    Set Relation To RecNo() into HU_, To u_kod into USL
    r_use( dir_server + "kartote_", , "KART_" )
    r_use( dir_server + "kartotek", , "KART" )
    Set Relation To RecNo() into KART_
    r_use( dir_server + "human_", , "HUMAN_" )
    r_use( dir_server + "human", , "HUMAN" )
    Set Relation To RecNo() into HUMAN_, To kod_k into KART
    If tmp->komu == 5
      Goto ( tmp->kod )
      If verify_1_other_sluch()
        ++iprov
      Else
        ++inprov
      Endif
    Else
      Set Index to ( dir_server + "humans" )
      find ( Str( 0, 6 ) + Str( B_STANDART, 1 ) )
      Do While human->schet == 0 .and. human->tip_h == B_STANDART .and. !Eof()
        If human_->reestr == 0 .and. human->cena_1 > 0 .and. ;
            human->komu == tmp->komu .and. human->str_crb == tmp->str_crb ;
            .and. Empty( Val( human_->smo ) )
          If verify_1_other_sluch()
            ++iprov
          Else
            ++inprov
          Endif
          @ 24, 0 Say PadC( "Прошли проверку: " + lstr( iprov ) + ", не прошли проверку: " + lstr( inprov ), 80 ) Color cColorSt2Msg
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    If inprov == 0
      If iprov > 0
        add_string( "Проверено случаев - " + lstr( iprov ) + ". Ошибок не обнаружено." )
      Else
        add_string( "Нечего проверять!" )
      Endif
    Endif
    FClose( fp )
    Close databases
    rest_box( buf )
    viewtext( nfile, , , , , , , 2 )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ), ( cur_dir() + "tmp1" ) Alias TMP
    Set Order To 2
    Goto ( rec )
  Endcase

  Return k

// 14.03.19
Function verify_1_other_sluch()

  Local ta := {}, ssumma := 0, fl, _ocenka := 5, lshifr1, auet

  rec_human := human->( RecNo() )
  glob_kartotek := human->kod_k
  d1 := human->n_data ; d2 := human->k_data ; dnovor := human_->NOVOR
  d2_year := Year( d2 )
  cd1 := dtoc4( d1 ) ; cd2 := dtoc4( d2 )
  uch->( dbGoto( human->LPU ) )
  otd->( dbGoto( human->OTD ) )
  // проверка по датам
  If Year( human->date_r ) < 1900
    AAdd( ta, "дата рождения: " + full_date( human->date_r ) + " ( < 1900г.)" )
  Endif
  If human->date_r > human->n_data
    AAdd( ta, "дата рождения: " + full_date( human->date_r ) + ;
      " > даты начала лечения: " + full_date( human->n_data ) )
  Endif
  If human->n_data > human->k_data
    AAdd( ta, "дата начала лечения: " + full_date( human->n_data ) + ;
      " > даты окончания лечения: " + full_date( human->k_data ) )
  Endif
  If human->k_data - human->n_data > 364
    AAdd( ta, "время лечения составляет больше года" )
  Endif
  If human->k_data > sys_date
    AAdd( ta, "дата окончания лечения > системной даты: " + full_date( human->k_data ) )
  Endif
  If human_->NOVOR > 0
    If Empty( human_->DATE_R2 )
      AAdd( ta, "не введена дата рождения новорожденного" )
    Elseif human_->DATE_R2 > human->n_data
      AAdd( ta, "дата рождения новорожденного: " + full_date( human_->DATE_R2 ) + " больше даты начала лечения: " + full_date( human->n_data ) )
    Elseif human->n_data - human_->DATE_R2 > 60
      AAdd( ta, "новорожденному более двух месяцев" )
    Endif
  Endif
  mdiagnoz := diag_to_array(, , , , .t. )
  If Len( mdiagnoz ) == 0 .or. Empty( mdiagnoz[ 1 ] )
    AAdd( ta, 'не заполнено поле "ОСНОВНОЙ ДИАГНОЗ"' )
  Endif
  val_fio( retfamimot( 2, .f. ), ta )
  //
  d := human->k_data - human->n_data
  kkd := kds := kvp := kuet := kkt := ksmp := 0 ; mpztip := mpzkol := kol_uet := 0
  kkd_1_7 := 0 ; fl_1_7_12 := .f. ; kkd_1_10 := 0 ; fl_70_1 := .f. ; au_lu := {}
  fl_1_7_53 := .f. ; is_perito := .f.
  kkd_1_9 := 0 ; is_kt := is_mrt := is_71_1 := is_71_2 := .f. ; lstkol := kvp_2_78 := 0
  is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f. ; lstshifr := ""
  midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := 0
  f_put_glob_podr( human_->USL_OK, d2, ta ) // заполнить код подразделения
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    mdate := c4tod( hu->date_u )
    If !Between( mdate, d1, d2 )
      AAdd( ta, 'услуга ' + AllTrim( usl->shifr ) + '(' + date_8( mdate ) + ') не попадает в диапазон лечения' )
    Endif
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    lst := 0
    is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, @auet, , @lst )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If lst == 1
        k := 0 ; lstshifr := "" ; lstkol := hu->kol_1
        For i := 1 To Len( lshifr )
          c := SubStr( lshifr, i, 1 )
          lstshifr += c
          If c == "." ; ++k ; Endif
          If k == 2 ; exit ; Endif
        Next
      Endif
      otd->( dbGoto( hu->OTD ) )
      AAdd( au_lu, { lshifr, mdate, hu_->profil, hu_->PRVS } )
      mdate_u1 := dtoc4( human->n_data )
      mdate_u2 := hu->date_u
      If Left( lshifr, 2 ) == "1."
        musl_ok := 1  // стационар
        mdate_u2 := dtoc4( human->k_data )
        If Left( lshifr, 4 ) == "1.7."
          midsp := 18 // Законченный случай в круглосуточном стационаре
          kkd_1_7 += hu->kol_1
          i := Int( Val( SubStr( lshifr, 5 ) ) )
          fl_1_7_12 := Between( i, 1, 12 )  // от 1.7.1  до 1.7.12
          fl_1_7_53 := Between( i, 53, 57 ) // от 1.7.53 до 1.7.57
          zaksluchaccordancediagnoz( lshifr, mdiagnoz, ta )
        Elseif Left( lshifr, 5 ) == "1.10."
          midsp := 18 // Законченный случай в круглосуточном стационаре
          kkd_1_10 += hu->kol_1
          zaksluchaccordancediagnoz( lshifr, mdiagnoz, ta )
        Elseif Left( lshifr, 4 ) == "1.9."
          midsp := 14 // Лечение в профильном отделении стационара
          kkd_1_9 += hu->kol_1
        Else
          midsp := 5 // Койко-день в круглосуточном стационаре
          kkd += hu->kol_1
        Endif
      Elseif Left( lshifr, 3 ) == "55."
        musl_ok := 2  // дн.стационар
        mdate_u2 := dtoc4( human->k_data )
        If Left( lshifr, 5 ) == "55.2." // дн.стац. при б-це
          midsp := 6
          kds += hu->kol_1
        Elseif Left( lshifr, 5 ) == "55.3." // дн.стац. при п-ке
          midsp := 7
          kds += hu->kol_1
        Elseif Left( lshifr, 5 ) == "55.4." // стационар на дому
          midsp := 8
          kds += hu->kol_1
        Elseif Left( lshifr, 5 ) == "55.5." // Законченный случай в дн.стац. при б-це
          midsp := 19
          kds += d + 1
        Elseif Left( lshifr, 5 ) == "55.6." // Законченный случай в дн.стац. при п-ке
          midsp := 20
          kds += d + 1
        Elseif Left( lshifr, 5 ) == "55.7." // Законченный случай в стационаре на дому
          midsp := 21
          kds += d + 1
        Endif
        If eq_any( AllTrim( lshifr ), "55.4.2", "55.7.8" ) // перитонеальный диализ
          is_perito := .t.
        Endif
      Elseif Left( lshifr, 5 ) == "60.2."  // ЛДП
        mIDSP := 4 // лечебно-диагностическая процедура
        kkt += hu->kol_1
        If eq_any( AllTrim( lshifr ), "60.2.1", "60.2.2", "60.2.8" )
          is_kt := .t.
        Endif
        If eq_any( AllTrim( lshifr ), "60.2.3", "60.2.4" )
          is_mrt := .t.
        Endif
        If d2_year > 2012
          musl_ok := 3  // п-ка
        Endif
      Elseif eq_any( Left( lshifr, 5 ), "71.1.", "71.2." )  // скорая помощь
        musl_ok := 4  // СМП
        mIDSP := 24 // Вызов скорой медицинской помощи
        If Left( lshifr, 5 ) == "71.1."
          is_71_1 := .t.
        Else
          is_71_2 := .t.
        Endif
        ksmp += hu->kol_1
      Else
        musl_ok := 3  // п-ка
        mIDSP := 1 // Посещение в поликлинике
        If Left( lshifr, 5 ) == "2.76."
          mIDSP := 12 // Комплексная услуга центра здоровья
        Elseif Left( lshifr, 5 ) == "2.78."
          ++kvp_2_78
          is_2_78 := .t.
          mIDSP := 17 // Законченный случай в поликлинике
        Elseif Left( lshifr, 5 ) == "2.79."
          is_2_79 := .t.
        Elseif Left( lshifr, 5 ) == "2.80."
          is_2_80 := .t.
        Elseif Left( lshifr, 5 ) == "2.81."
          is_2_81 := .t.
        Elseif Left( lshifr, 5 ) == "2.82."
          is_2_82 := .t.
          mIDSP := 22 // Посещение в приёмном покое
        Elseif Left( lshifr, 5 ) == "70.1."
          mIDSP := 11 // Дополнительная диспансеризация
          mRSLT_NEW := 312
          fl_70_1 := .t.
          If mdate < SToD( "20110901" )
            AAdd( a_h, 'Услуга ' + RTrim( lshifr ) + ' оказана ранее 1 сентября' )
          Endif
        Elseif Left( lshifr, 3 ) == "57."
          mIDSP := 4 // лечебно-диагностическая процедура
          mpzkol := hu->kol_1 * iif( human->vzros_reb == 0, auet[ 1 ], auet[ 2 ] )
          kol_uet += mpzkol
        Endif
        kvp += hu->kol_1
      Endif
      If musl_ok != 3 .and. !( hu->date_u == mdate_u1 ) .and. Len( au_lu ) == 1
        AAdd( ta, 'дата услуги ' + AllTrim( lshifr ) + ' должна равняться дате начала лечения' )
      Endif
      hu_->date_u2 := mdate_u2
      fl_del := fl_uslc := .f.
      v := fcena_oms( lshifr, ;
        ( human->vzros_reb == 0 ), ;
        human->k_data, ;
        @fl_del, ;
        @fl_uslc )
      If fl_uslc  // если нашли в справочнике ТФОМС
        If fl_del
          AAdd( ta, 'Цена на услугу ' + RTrim( lshifr ) + ' отсутствует в справочнике ТФОМС' )
        Elseif !( Round( v, 2 ) == Round( hu->u_cena, 2 ) )
          AAdd( ta, 'Ошибка в цене услуги[' + ;
            iif( human->vzros_reb == 0, 'взр', 'реб' ) + ;
            ']: ' + RTrim( lshifr ) + ": " + lstr( hu->u_cena, 9, 2 ) + ;
            ", должно быть: " + lstr( v, 9, 2 ) )
        Endif
        If !( Round( hu->u_cena * hu->kol_1, 2 ) == Round( hu->stoim_1, 2 ) )
          AAdd( ta, 'Услуга ' + RTrim( lshifr ) + ': сумма строки ' + ;
            lstr( hu->stoim_1 ) + ' не равна произведению ' + ;
            lstr( hu->u_cena ) + " * " + lstr( hu->kol_1 ) )
        Endif
      Endif
      ssumma += hu->stoim_1
    Endif
    Select HU
    Skip
  Enddo
  If !( Round( human->cena_1, 2 ) == Round( ssumma, 2 ) )
    AAdd( ta, 'Сумма случая ' + lstr( human->cena_1 ) + ' не равна сумме услуг ' + lstr( ssumma ) )
    AAdd( ta, 'Выполните ПЕРЕИНДЕКСИРОВАНИЕ и отредактируйте услуги в листе учёта' )
  Endif
  If Empty( au_lu )
    AAdd( ta, 'Не введено ни одной услуги' )
  Endif
  If Empty( human_->USL_OK )
    human_->USL_OK := musl_ok
  Endif
  If is_2_78
    mIDSP := 17 // Законченный случай в поликлинике
  Endif
  If Empty( human_->IDSP )
    human_->IDSP := midsp
  Endif
  If kkd_1_7 > 0
    If !fl_1_7_53 .and. d < iif( fl_1_7_12, 2, 4 )
      AAdd( ta, 'для услуги 1.7.* слишком мал срок лечения' )
    Endif
  Elseif kkd_1_9 > 0
    If d < 4
      AAdd( ta, 'для услуги 1.9.* слишком мал срок лечения' )
    Endif
  Elseif kkd_1_10 > 0
    If d < 4
      AAdd( ta, 'для услуги 1.10.* слишком мал срок лечения' )
    Endif
  Elseif kkd > 0
    If Empty( d ) .and. kkd == 1
      // по-новому один койко-день
    Elseif kkd > d
      AAdd( ta, 'кол-во койко-дней (' + lstr( kkd ) + ') превышает срок лечения на ' + lstr( kkd - d ) )
    Elseif kkd < d
      AAdd( ta, 'кол-во койко-дней (' + lstr( kkd ) + ') меньше срока лечения на ' + lstr( d - kkd ) )
    Elseif kkd > 3 .and. d2_year > 2012
      AAdd( ta, 'кол-во койко-дней (' + lstr( kkd ) + ') должно быть 1-3 дня' )
    Endif
  Elseif kds > 0
    If kds > ( d + 1 )
      AAdd( ta, 'кол-во услуг дневного стационара (' + lstr( kds ) + ') превышает срок лечения' )
    Endif
  Elseif kkt > 0
    If is_kt
      If kkt > 2
        AAdd( ta, 'кол-во услуг КОМПЬЮТЕРНАЯ ТОМОГРАФИЯ (' + lstr( kkt ) + ') не должно быть более 2' )
      Endif
    Elseif is_mrt
      If kkt > 2
        AAdd( ta, 'кол-во услуг МРТ (' + lstr( kkt ) + ') не должно быть более 2' )
      Endif
    Elseif AllTrim( au_lu[ 1, 1 ] ) == '60.2.5'
      If Month( d1 ) != Month( d2 )
        AAdd( ta, 'для услуги гемодиализа случай должен быть в одном отчётном месяце' )
      Endif
    Else // 60.2.6 Ангиография   60.2.7 Коронарография
      If kkt > 2
        AAdd( ta, 'кол-во услуг (' + lstr( kkt ) + ') не должно быть более 2' )
      Endif
    Endif
  Elseif kvp > 0
    If d2 > d1 .and. ( is_2_80 .or. is_2_81 .or. is_2_82 )
      AAdd( ta, 'для данной услуги срок лечения - один день' )
    Endif
  Elseif ksmp > 0
    If ksmp > 1
      AAdd( ta, 'количество услуг СМП должно быть равно 1' )
    Endif
    If Len( au_lu ) > 1
      AAdd( ta, 'кроме услуги 71.* в листе учета не должно быть других услуг ТФОМС' )
    Endif
    If human_->USL_OK != 4
      AAdd( ta, 'для услуги СМП условия должны быть "Скорая помощь"' )
    Endif
    If human_->PROFIL != 84
      AAdd( ta, 'для услуги СМП профиль должен быть "скорой медицинской помощи"' )
    Endif
    If human_->IDSP != 24
      AAdd( ta, 'для услуги СМП способ оплаты должен быть "Вызов скорой медицинской помощи"' )
    Endif
    If d1 < d2
      AAdd( ta, 'для скорой помощи дата начала должна равняться дате окончания лечения' )
    Endif
    If ( is_komm_smp() .and. d2 < 0d20190501 ) .or. ( is_komm_smp() .and. d2 > 0d20220101 ) // если это коммерческая скорая
      If is_71_1
        AAdd( ta, 'для коммерческой СМП необходимо применять услуги 71.2.*' )
      Endif
    Elseif human_->OKATO == '18000'
      If is_71_2
        AAdd( ta, 'для пациентов, застрахованных на территории Волгоградской области,' )
        AAdd( ta, 'необходимо применять услуги 71.1.*' )
      Endif
    Else
      If is_71_1
        AAdd( ta, 'для пациентов, застрахованных за пределами Волгоградской области,' )
        AAdd( ta, 'необходимо применять услуги 71.2.*' )
      Endif
    Endif
  Endif
  If human_->USL_OK == 4 .and. !is_71_1 .and. !is_71_2
    AAdd( ta, 'для условия "Скорая помощь" не введены услуги СМП' )
  Endif
  If Len( ta ) > 0
    _ocenka := 0
    verify_ff( 80 -Len( ta ) -3, .t., 80 )
    add_string( "" )
    add_string( AllTrim( human->fio ) + " " + ;
      date_8( human->n_data ) + "-" + date_8( human->k_data ) )
    add_string( " " + AllTrim( uch->name ) + "/" + AllTrim( otd->name ) )
    AEval( ta, {| x| add_string( "- " + x ) } )
  Endif

  Return ( _ocenka >= 5 )

//
Function other_schet_vyp()

  Local mas_pmt := { "Выписать ~один счет" }, ;
    mas_msg := { "Выписать один (прочий) счет" }, ;
    mas_fun := { "vyp1other_schet()" }

  If is_0_schet == 1
    AAdd( mas_pmt, "Выписать счет с ~нулевой суммой" )
    AAdd( mas_msg, "Выписать счет с нулевой суммой (по параклинике)" )
    AAdd( mas_fun, "vyp0other_schet()" )
  Endif
  If Len( mas_pmt ) == 1
    return &( mas_fun[ 1 ] )
  Else
    popup_prompt( T_ROW, T_COL + 5, 1, mas_pmt, mas_msg, mas_fun )
  Endif

  Return Nil

//
Function func2_komu( kod_komu, kod_str_crb, r, c, fl_top )

  Local i, k, r1, r2, mmenu := { "~Прочие компании", ;
    "~Комитеты (МО)", ;
    "~Личный счет" }

  Default kod_komu To glob_komu
  If fl_top == NIL
    fl_top := ( r < 12 )
  Endif
  If !( kod_komu == 2 .or. kod_komu == 5 ) .and. Type( "mstr_crb" ) == "N"
    kod_str_crb := mstr_crb
  Endif
  If ( i := popup_prompt( if( fl_top, r + 1, r - 7 ), c, kod_komu, mmenu ) ) > 0
    r1 := if( fl_top, r + 1, 2 )
    r2 := if( fl_top, r + 10, r - 1 )
    glob_komu := i
    Do Case
    Case i == 1
      Default kod_str_crb To glob_strah[ 1 ]
      If ( k := popup_edit( dir_server + "str_komp", r1, c, r2, kod_str_crb, ;
          PE_RETURN, , , , {|| !Between( tfoms, 44, 47 ) }, , , fl_top, "Прочие компании", col_tit_popup ) ) != NIL
        pp_str_crb := mstr_crb := k[ 1 ]
        glob_all := glob_strah := k
        Return { 1, "СМО - " + AllTrim( k[ 2 ] ) }
      Endif
    Case i == 2
      Default kod_str_crb To glob_komitet[ 1 ]
      If ( k := popup_edit( dir_server + "komitet", r1, c, r2, kod_str_crb, ;
          PE_RETURN, , , , , , , fl_top, "Комитеты (МО)", col_tit_popup ) ) != NIL
        pp_str_crb := mstr_crb := k[ 1 ]
        glob_all := glob_komitet := k
        Return { 3, AllTrim( k[ 2 ] ) }
      Endif
    Case i == 3
      glob_all := { 0, "Личный счет" }
      pp_str_crb := mstr_crb := 0
      Return { 5, "Личный счет" }
    Endcase
  Endif

  Return Nil

// Выписать счет с нулевой суммой (по параклинике)
Function vyp0other_schet()

  Local buf := save_maxrow(), k := 0, s1, s2, adbf
  Private pkol := 0, psumma := 0, par_ns := 1

  gnevyp_schet := .f.
  mywait()
  adbf := { ;
    { "KOMU",   "N",     1,     0 }, ;
    { "STR_CRB",   "N",     2,     0 }, ;
    { "MIN_DATE",   "D",     8,     0 }, ;
    { "DNI",   "N",     3,     0 }, ;
    { "KOL_BOLN",   "N",     6,     0 }, ;
    { "SUMMA",   "N",    13,     2 }, ;
    { "NKOMU",   "C",    80,     0 }, ;
    { "KOD",   "N",     7,     0 }, ;
    { "PLUS",   "L",     1,     0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) Alias TMP
  Index On Str( komu, 1 ) + Str( str_crb, 2 ) to ( cur_dir() + "tmp" )
  Index On nkomu to ( cur_dir() + "tmp1" )
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ), ( cur_dir() + "tmp1" ) Alias TMP
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  find ( Str( 0, 6 ) + Str( B_STANDART, 1 ) )
  Do While human->schet == 0 .and. human->tip_h == B_STANDART .and. !Eof()
    If human_->reestr == 0 .and. ;
        Empty( human->cena_1 ) .and. human->komu > 0 .and. Empty( Val( human_->smo ) )
      mstr_crb := iif( human->komu == 5, 0, human->str_crb )
      Select TMP
      find ( Str( human->komu, 1 ) + Str( mstr_crb, 2 ) )
      If Found() .and. human->komu != 5
        tmp->kol_boln++
        tmp->summa += human->cena_1
        tmp->min_date := Min( tmp->min_date, human->k_data )
      Else
        k++
        Append Blank
        Replace tmp->komu With human->komu, ;
          tmp->str_crb With mstr_crb, ;
          tmp->kol_boln With 1, tmp->summa With human->cena_1, ;
          tmp->min_date With human->k_data, ;
          tmp->plus With .t.
        If human->komu == 5
          Replace tmp->nkomu With " Личн.счет - " + AllTrim( human->fio ) + ", " + ;
            Left( DToC( human->n_data ), 5 ) + "-" + date_8( human->k_data ), ;
            tmp->kod With human->kod
        Endif
      Endif
      pkol++; psumma += human->cena_1
    Endif
    Select HUMAN
    Skip
  Enddo
  If k == 0
    rest_box( buf )
    func_error( 4, "Не обнаружено больных с нулевой суммой случая, по которым не выписаны счета!" )
  Else
    human_->( dbCloseArea() )
    human->( dbCloseArea() )
    Select TMP
    Set Order To 0
    Go Top
    Do While !Eof()
      If tmp->komu != 5
        tmp->nkomu := func1_komu( tmp->komu, tmp->str_crb )
      Endif
      k := sys_date - tmp->min_date
      tmp->dni := iif( Between( k, 1, 999 ), k, -99 )
      Skip
    Enddo
    Set Order To 2
    Go Top
    rest_box( buf )
    s1 := " Общее количество больных - " + expand_value( pkol ) + " чел. "
    s2 := " Общая сумма счетов - " + expand_value( psumma, 2 ) + " руб. "
    k := 80 -Max( Len( s1 ), Len( s2 ) )
    buf := box_shadow( T_ROW - 3, k, T_ROW - 2, 79, color1, , , 0 )
    @ T_ROW - 3, k Say s1 Color color8
    @ T_ROW - 2, k Say s2 Color color8
    If alpha_browse( T_ROW, 0, 23, 79, "f1nevyp_schet", color0, ;
        "Невыписанные счета с нулевой суммой", "R/BG", , , , , "f2nevyp_schet", , ;
        { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B,R/BG", .f., 0 } )
      gnevyp_schet := .t.
      If ( glob_komu := tmp->komu ) == 1
        glob_strah[ 1 ] := tmp->str_crb
      Elseif glob_komu == 3
        glob_komitet[ 1 ] := tmp->str_crb
      Endif
      glob_all := { tmp->str_crb, RTrim( tmp->nkomu ) }
      If glob_komu == 5
        glob_all := { tmp->kod, RTrim( tmp->nkomu ) }
      Endif
      Close databases
      Private p_0_schet := .t.
      vyp1other_schet( .t., glob_komu, glob_all[ 1 ] )
    Endif
    rest_box( buf )
  Endif
  Close databases

  Return Nil

//
Function vyp1other_schet( is_nul, lkomu, lstr_crb )

  Local buf := save_maxrow(), buf1
  Local mas_pmt, mas_fun, mas1_pmt, dbf_tmp, lrzs
  Local i, j, k, k1 := 0, tmp1, tmp2, lOldDeleted, ;
    tmp_arr, tmp1_arr, fl_err := .f., larr_r := {}

  Default is_nul To .f.
  mas_pmt := { "Предварительный просмотр ~счета", ;
    "Предварительный просмотр ~листов учета", ;
    "~Исключение из счета некоторых больных", ;
    "~Выписка счета" }
  mas_fun := { "print_other_schet()", ;
    "pr_vklad(1)", ;
    "f1vyp_schet()", ;
    "f2vyp_schet()" }
  dbf_tmp := { ;
    { "KOD",   "N",     7,     0 }, ;
    { "NOMER",   "N",     6,     0 }, ;
    { "KOD_K",   "N",     7,     0 }, ;
    { "N_DATA",   "D",     8,     0 }, ; // дата начала лечения
  { "K_DATA",   "D",     8,     0 }, ; // дата окончания лечения
    { "FIO",   "C",    50,     0 }, ; // Ф.И.О. больного
    { "DATE_R",   "D",     8,     0 }, ; // дата рождения
  { "VZROS_REB",   "N",     1,     0 }, ; // 0-взрослый, 1 -ребенок, 2-подросток
  { "CENA",   "N",    12,     2 }, ; // стоимость лечения
  { "RAB_NERAB",   "N",     1,     0 }, ; // 0-работающий, 1 -неработающий
  { "PLUS",   "L",     1,     0 } }  // включается ли в счет
  mas1_pmt := { "Выписать счет по всем ~больным", ;
    "Выписать счет по ~условию" }
  Private p_1, p_2, ob_summa := 0, ob_kol, str_kriterij := "Все больные", ;
    muslovie := ".t.", mmax_kol := 999
  Private mn1_data := CToD( "" ), mn2_data := CToD( "" ), ;
    mk1_data := CToD( "" ), mk2_data := CToD( "" )
  Private p_number := "___", p_date := CToD( "" )
  If iif( lkomu != NIL, .t., ( k := func2_komu(, , T_ROW - 1, T_COL + 6 ) ) != NIL )
    If lkomu == NIL
      glob_komu := k[ 1 ]
    Else
      k := { glob_komu, glob_all[ 2 ] }
    Endif
    If glob_komu == 5 // меню людей с личными счетами
      dbCreate( cur_dir() + "tmp", dbf_tmp )
      Use ( cur_dir() + "tmp" ) Alias TMP
      Index On Upper( fio ) to ( cur_dir() + "tmp" )
      r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
      find ( Str( 0, 6 ) + Str( B_STANDART, 1 ) )
      Do While human->schet == 0 .and. human->tip_h == B_STANDART .and. !Eof()
        If iif( is_nul, Empty( human->CENA_1 ), human->CENA_1 > 0 ) ;
            .and. human->komu == 5
          k1++
          Select TMP
          Append Blank
          Replace tmp->KOD    With human->KOD, ;
            tmp->KOD_K  With human->KOD_K, ;
            tmp->n_data With human->n_data, ;
            tmp->k_data With human->k_data, ;
            tmp->FIO    With human->FIO, ;
            tmp->date_r With human->date_r, ;
            tmp->CENA   With human->CENA_1, ;
            tmp->PLUS   With .t.
        Endif
        Select HUMAN
        Skip
      Enddo
      j := 0
      Select TMP
      Go Top
      Do While !Eof()
        tmp->NOMER := ++j
        Skip
      Enddo
      Close databases
      If k1 == 0
        rest_box( buf )
        Return func_error( 4, "Не найдено людей с личными счетами!" )
      Endif
      Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) Alias TMP
      If lkomu != NIL
        Locate For kod == glob_all[ 1 ]
        If !Found()
          Go Top
        Endif
      Endif
      If alpha_browse( T_ROW, 2, MaxRow() -2, 77, "f2pr_vklad", color0, ;
          "Выбор больного для выписки личного счета", "R/BG", .t., , , , , , ;
          { '═', '░', '═', , , 0 } )
        glob_all := { tmp->kod, AllTrim( tmp->fio ) }
        Close databases
      Else
        Close databases
        rest_box( buf )
        Return Nil
      Endif
      k1 := 0
    Endif
    dbCreate( cur_dir() + "tmp", dbf_tmp )
    Use ( cur_dir() + "tmp" ) Alias TMP
    Index On Upper( fio ) to ( cur_dir() + "tmp" )
    k1 := 0
    If glob_komu == 5
      r_use( dir_server + "human", , "HUMAN" )
      Goto ( glob_all[ 1 ] )
      k1++
      Select TMP
      Append Blank
      Replace tmp->KOD       With human->KOD, ;
        tmp->KOD_K     With human->KOD_K, ;
        tmp->n_data    With human->n_data, ;
        tmp->k_data    With human->k_data, ;
        tmp->FIO       With human->FIO, ;
        tmp->date_r    With human->date_r, ;
        tmp->VZROS_REB With human->VZROS_REB, ;
        tmp->CENA      With human->CENA_1, ;
        tmp->RAB_NERAB With human->RAB_NERAB, ;
        tmp->PLUS      With .t.
      k := { 5, "Личный счет - " + RTrim( human->fio ) }
      glob_all := { 0, "" }
    Else
      r_use( dir_server + "uslugi", , "USL" )
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      Set Relation To u_kod into USL
      r_use( dir_server + "human_", , "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      find ( Str( 0, 6 ) + Str( B_STANDART, 1 ) )
      Do While human->schet == 0 .and. human->tip_h == B_STANDART .and. !Eof()
        If iif( is_nul, Empty( human->CENA_1 ), human->CENA_1 > 0 ) ;
            .and. human_->reestr == 0 .and. Empty( Val( human_->smo ) ) .and. ;
            human->komu == glob_komu .and. human->str_crb == glob_all[ 1 ]
          k1++
          Select TMP
          Append Blank
          Replace tmp->KOD       With human->KOD, ;
            tmp->KOD_K     With human->KOD_K, ;
            tmp->n_data    With human->n_data, ;
            tmp->k_data    With human->k_data, ;
            tmp->FIO       With human->FIO, ;
            tmp->date_r    With human->date_r, ;
            tmp->VZROS_REB With human->VZROS_REB, ;
            tmp->CENA      With human->CENA_1, ;
            tmp->PLUS      With .t.
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    j := 0
    Select TMP
    Go Top
    Do While !Eof()
      tmp->NOMER := ++j
      Skip
    Enddo
    Close databases
    rest_box( buf )
    If k1 == 0
      func_error( 4, "Некого включать в данный счет!" )
    Else
      s_lpu_smo := k[ 2 ]
      buf := SaveScreen()
      box_shadow( 0, 2, 3, 77, color1, "Информация о счете", color8, 0 )
      SetColor( color1 )
      @ 1, 4 Say s_lpu_smo Color "BG+/B"
      @ 2, 6 Say "Количество больных: " + lstr( k1 ) + " чел."
      SetColor( color0 )
      If ( k1 := iif( glob_komu == 5, 1, popup_prompt( T_ROW, T_COL + 6, 1, mas1_pmt ) ) ) > 0
        If iif( k1 == 1, .t., usl_vyp_schet() ) // выписать счет по условию
          mywait()
          lOldDeleted := Set( _SET_DELETED, .f. )
          Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" )
          Go Top
          i := ob_summa := ob_kol := 0
          Do While !Eof()
            if &muslovie .and. ob_kol < mmax_kol
              ob_kol++; ob_summa += tmp->cena
            Else
              i++
              Delete
            Endif
            Skip
          Enddo
          If i > 0
            Pack
            j := 0
            Select TMP
            Go Top
            Do While !Eof()
              tmp->NOMER := ++j
              Skip
            Enddo
          Endif
          Use
          Set( _SET_DELETED, lOldDeleted )  // Восстановление среды _SET_DELETED
          RestScreen( buf )
          box_shadow( 0, 2, 5, 77, color1, "Информация о счете", color8, 0 )
          SetColor( color1 )
          @ 1, 4 Say s_lpu_smo Color "BG+/B"
          @ 2, 10 Say "Количество больных в счете: " + expand_value( ob_kol ) + " чел."
          @ 3, 10 Say "Сумма счета: " + expand_value( ob_summa, 2 ) + " руб."
          SetColor( color0 )
          If ob_kol == 0
            func_error( 4, "По выбранному критерию нет больных!" )
          Else
            If ob_kol == 1
              del_array( mas_pmt, 3 )
              del_array( mas_fun, 3 )
            Endif
            popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL + 6, 1, mas_pmt, , mas_fun )
          Endif
        Endif
      Endif
      RestScreen( buf )
    Endif
  Endif
  gnevyp_schet := .f.

  Return Nil

//
Function pr_vklad( k )

  Local i := 1, buf := SaveScreen()
  Private is_spisok := .t., p_k := k

  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
  If LastRec() == 1
    Keyboard Chr( K_ENTER )
  Endif
  alpha_browse( T_ROW, 2, MaxRow() -2, 77, "f2pr_vklad", color0, ;
    "Выбор больного", "R/BG", .t., , , , "f9pr_vklad", , ;
    { '═', '░', '═', , .t., 0 } )
  Close databases
  RestScreen( buf )

  Return Nil

//
Function f2pr_vklad( oBrow )

  Local oColumn, n := 40

  oColumn := TBColumnNew( " №№; пп", {|| Str( tmp->nomer, 4 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( "Ф.И.О. больного", n ), {|| Left( tmp->fio, n ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "На-;чало", {|| Left( date_8( tmp->k_data ), 5 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Оконч.;лечения", {|| date_8( tmp->k_data ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "   Сумма", {|| PadL( expand_value( tmp->cena, 2 ), 13 ) } )
  oBrow:addcolumn( oColumn )
  If Type( "is_spisok" ) == "L" .and. is_spisok
    status_key( "^^,нач.буква - просмотр;  ^<Esc>^-выход;  ^<Enter>^-печать;  ^<F9>^-печать списка" )
  Endif

  Return Nil

//
Function f9pr_vklad( nKey, oBrow )

  Static srazmer := 0
  Local k := -1, rec, hGauge, i, j, n, nrec, l, arr, lkod, lnomer, ;
    n_file, buf := SaveScreen()

  Do Case
  Case nKey == K_ENTER // печать 1 листа учета
    rec := tmp->( RecNo() ) ; lkod := tmp->kod ; lnomer := tmp->nomer
    Close databases
    print_l_uch( lkod, 2, p_k, lnomer )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    Goto ( rec )
  Case nKey == K_F9 // непрерывная печать листов учета
    f_message( { "", "При просмотре списка листов учета", ;
      "комбинация клавиш <Ctrl+F10> позволяет", ;
      "вызвать на экран справочник диагнозов", ;
      "" }, , "B/W", "N/W" )
    If ( i := input_value( 20, 2, 22, 77, "N/W,GR+/R", ;
        "Введите стоимость лечения, выше которой распечатываются л/учета", ;
        srazmer, "9999999" ) ) != NIL
      srazmer := i
      clrline( 24, color0 )
      rec := tmp->( RecNo() ) ; nrec := tmp->( LastRec() ) ; n := 0
      hGauge := gaugenew(, , { "GR+/RB", "BG+/RB", "G+/RB" }, "Печать листов учета", .t. )
      gaugedisplay( hGauge )
      //
      dbCreate( cur_dir() + "tmps", { { "nomer", "N", 4, 0 }, ;
        { "stroke", "C", 80, 0 } } )
      Use ( cur_dir() + "tmps" ) new
      Index On Str( nomer, 4 ) to ( cur_dir() + "tmps" )
      //
      dbCreate( cur_dir() + "tmpd", { { "nomer", "N", 4, 0 }, ;
        { "kol_s", "N", 3, 0 } } )
      Use ( cur_dir() + "tmpd" ) new
      Index On Str( kol_s, 3 ) to ( cur_dir() + "tmpd" )
      //
      dbCreate( cur_dir() + "tmp1", { { "kod", "N", 4, 0 }, ;
        { "name", "C", 65, 0 }, ;
        { "shifr", "C", 10, 0 }, ;
        { "plus", "L", 1, 0 }, ;
        { "kol", "N", 4, 0 }, ;
        { "summa", "N", 11, 2 } } )
      Use ( cur_dir() + "tmp1" ) new
      Index On Str( kod, 4 ) to ( cur_dir() + "tmp11" )
      Index On fsort_usl( shifr ) to ( cur_dir() + "tmp12" )
      Set Index to ( cur_dir() + "tmp11" ), ( cur_dir() + "tmp12" )
      //
      r_use( dir_server + "uslugi", dir_server + "uslugi", "USL" )
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "human_", , "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humank", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      For i := 1 To nrec
        Select TMP
        Goto ( i )
        If tmp->cena >= srazmer
          ++n
          arr := f91pr_vklad( tmp->kod, tmp->nomer )
          For j := 1 To Len( arr )
            Select TMPS
            Append Blank
            tmps->nomer := n
            tmps->stroke := arr[ j ]
          Next
          Select TMPD
          Append Blank
          tmpd->nomer := n
          tmpd->kol_s := Len( arr )
        Endif
        gaugeupdate( hGauge, i / nrec )
      Next
      closegauge( hGauge )
      If n == 0
        func_error( 4, "В счете нет больных со стоимостью лечения больше " + lstr( srazmer ) + " руб." )
      Endif
      tmp1->( dbCloseArea() )
      usl->( dbCloseArea() )
      hu->( dbCloseArea() )
      human_->( dbCloseArea() )
      human->( dbCloseArea() )
      If n > 0
        mywait()
        i := 0
        n_file := "list_uch.txt"
        fp := FCreate( n_file )
        tek_stroke := 0
        n_list := 1
        add_string( "Приложение к счету № " + AllTrim( p_number ) + " от " + DToC( p_date ) + " г." )
        add_string( "" )
        add_string( Center( "Листы учета пролеченных больных [ >=" + lstr( srazmer ) + "руб. ]", 80 ) )
        add_string( "" )
        add_string( Replicate( ".", 80 ) )
        Select TMPD
        Go Top
        Do While !Eof()
          If tek_stroke + tmpd->kol_s > 80
            add_string( Chr( 12 ) ) ; tek_stroke := 0 ; ++n_list
          Elseif tek_stroke > 0 .and. i > 0
            add_string( Replicate( ".", 80 ) )
          Endif
          ++i
          Select TMPS
          find ( Str( tmpd->nomer, 4 ) )
          Do While tmps->nomer == tmpd->nomer
            verify_ff( 80 )
            add_string( RTrim( tmps->stroke ) )
            Skip
          Enddo
          Select TMPD
          Skip
        Enddo
        FClose( fp )
        Set Key K_CTRL_F10 To f10pr_vklad
        viewtext( n_file, , , , .f., , , 5 )
        Set Key K_CTRL_F10 To
      Endif
      tmps->( dbCloseArea() )
      tmpd->( dbCloseArea() )
      Select TMP
      Goto ( rec )
    Endif
    RestScreen( buf )
  Endcase

  Return k

// * 05.11.22
Function f91pr_vklad( mkod, mnomer )

  // mkod - код больного по БД human
  // mnomer - номер больного по счету
  Local sh := 80, arr := {}, arr1, msumma := 0, adiag_talon[ 16 ], ;
    i := 1, j, k, s, tmp[ 2 ], tmp1, w1 := 65, mishod, mprodol, ;
    lshifr1, fl_parakl, fl_plus, mpsumma
  //
  Select TMP1
  Set Order To 1
  Zap
  Select HUMAN
  find ( Str( mkod, 7 ) )
  AAdd( arr, "" )
  AAdd( arr, PadR( "№ " + lstr( mnomer ) + ".  " + human->fio, sh - 27 ) + ;
    PadL( "Дата рождения: " + full_date( human->date_r ), 27 ) )
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  arr1 := diag_to_array(, .t., .t., .t., .t., adiag_talon )
  AAdd( arr, "  Шифр основного заболевания: " + arr1[ 1 ] )
  If Len( arr1 ) > 1
    tmp1 := "  Шифры сопутствующих заболеваний:"
    For j := 2 To Len( arr1 )
      tmp1 += " " + arr1[ j ]
    Next
    AAdd( arr, tmp1 )
  Endif
  AAdd( arr, '  Результат обращения: ' + inieditspr( A__MENUVERT, getv009(), human_->RSLT_NEW ) )
  AAdd( arr, '  Исход заболевания: ' + inieditspr( A__MENUVERT, getv012(), human_->ISHOD_NEW ) )
  AAdd( arr, '  Срок лечения с ' + full_date( human->n_data ) + ' по ' + full_date( human->k_data ) )
  Select HU
  find ( Str( mkod, 7 ) )
  Do While hu->kod == mkod .and. !Eof()
    If !emptyall( hu->kol_1, hu->stoim_1 )
      Select USL
      dbSeek( Str( hu->u_kod, 4 ) )
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      Select TMP1
      find ( Str( usl->kod, 4 ) )
      If !Found()
        Append Blank
        tmp1->kod := usl->kod
        tmp1->name := usl->name
        tmp1->shifr := if( Empty( lshifr1 ), usl->shifr, lshifr1 )
      Endif
      tmp1->plus := !f_paraklinika( usl->shifr, lshifr1, human->k_data )
      tmp1->kol += hu->kol_1
      tmp1->summa += hu->stoim_1
    Endif
    Select HU
    Skip
  Enddo
  mpsumma := 0
  Select TMP1
  Set Order To 2
  Go Top
  AAdd( arr, "--------------------------------------------------------------------------------" )
  AAdd( arr, "                      Наименование услуги                       | Кол |  Сумма  " )
  AAdd( arr, "--------------------------------------------------------------------------------" )
  Do While !Eof()
    k := perenos( tmp, tmp1->shifr + " " + tmp1->name, w1 )
    If tmp1->plus
      AAdd( arr, PadR( tmp[ 1 ], 65 ) + PadL( "+" + lstr( tmp1->kol ), 4 ) + " " + put_kope( tmp1->summa, 10 ) )
      mpsumma += tmp1->summa
    Else
      AAdd( arr, PadR( tmp[ 1 ], 66 ) + put_val( tmp1->kol, 3 ) + " " + put_kope( tmp1->summa, 10 ) )
      msumma += tmp1->summa
    Endif
    If k > 1
      AAdd( arr, PadL( RTrim( tmp[ 2 ] ), w1 ) )
    Endif
    Skip
  Enddo
  AAdd( arr, Space( 45 ) + Replicate( "-", sh - 45 ) )
  // msumma := round(msumma,2)
  msumma := human->cena_1
  s := "Общая сумма лечения: " + put_kop( msumma, 12 )
  If mpsumma > 0
    s := AllTrim( s ) + " (+" + lput_kop( mpsumma, .t. ) + ")"
  Endif
  AAdd( arr, PadL( s, sh ) )

  Return arr

//
Function f10pr_vklad()

  Set Key K_CTRL_F10 To
  f10_diagnoz()
  Set Key K_CTRL_F10 To f10pr_vklad

  Return Nil

// 26.05.23 печать прочего счёта
Function print_other_schet( is_vyp, is_usl, n_file )

  Local sh := 169, HH := 40, regim := 3, buf := save_maxrow(), ;
    tmp, tmp1, tmp2 := '', mcena_1, hGauge, lshifr1, ;
    name_lpu, name_otd, mvzros_reb, mmest_inog, mrab_nerab, ;
    mkomu, fl_parakl, mdate, r1, c1, ;
    i := 1, j := 0, k, k1, k2, k3, k4, k5, srok_lech, ;
    a_fio[ 8 ], a_polis[ 8 ], a_adres[ 8 ], a_rabota[ 8 ], a_shifr[ 8 ], a_mesto_l[ 8 ], j1, ;
    tel_org, razmer_usl := 0, is_view := .t., mdate_r[ 10 ], arr

  Default is_vyp To 0, ;  // по умолчанию счет еще не выписан
    n_file To cur_dir() + 'schet_o.txt'
  Private name_org, adres_org, inn_org, pok_name, pok_adres, pok_inn, ;
    schet_org, bank_org, mfo_org, mkorr_schet, ;
    mfio_ruk, mfio_bux, ob_summa := 0, pj
  If is_usl == NIL
    is_usl := 1
  Else
    is_view := .f.
  Endif
  mywait()
  delfrfiles()
  name_lpu := RTrim( glob_uch[ 2 ] )
  adbf := { { "name_org", "C", 130, 0 }, ;
    { "adres_org", "C", 110, 0 }, ;
    { "inn_org", "C", 30, 0 }, ;
    { "tel_org", "C", 20, 0 }, ;
    { "bank_org", "C", 130, 0 }, ;
    { "schet_org", "C", 45, 0 }, ;
    { "korr_schet", "C", 45, 0 }, ;
    { "bik", "C", 10, 0 }, ;
    { "ruk", "C", 20, 0 }, ;
    { "bux", "C", 20, 0 }, ;
    { "komu", "C", 80, 0 }, ;
    { "nschet", "C", 20, 0 }, ;
    { "dschet", "D", 8, 0 }, ;
    { "ssumma", "C", 250, 0 }, ;
    { "summa", "N", 15, 2 }, ;
    { "kol", "N", 6, 0 } }
  dbCreate( fr_titl, adbf )
  r_use( dir_server + "organiz", , "ORG" )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name_org := name_org := AllTrim( org->name )
  frt->adres_org := adres_org := AllTrim( org->adres )
  frt->inn_org := inn_org := iif( Empty( org->inn ), "", ", ИНН " + org->inn )
  frt->tel_org := tel_org := iif( Empty( org->telefon ), "", " тел." + org->telefon )
  frt->schet_org := schet_org := AllTrim( org->r_schet )
  frt->korr_schet := mkorr_schet := AllTrim( org->k_schet )
  frt->bank_org := bank_org := AllTrim( org->bank )
  frt->bik := mfo_org := AllTrim( org->smfo )
  frt->ruk := mruk := AllTrim( org->ruk )
  frt->bux := mbux := AllTrim( org->bux )
  org->( dbCloseArea() )
  //
  adbf := { { "nomer", "N", 4, 0 }, ;
    { "fio", "C", 50, 0 }, ;
    { "pol", "C", 10, 0 }, ;
    { "date_r", "D", 8, 0 }, ;
    { "otd", "C", 100, 0 }, ;
    { "pasport", "C", 50, 0 }, ;
    { "adresp", "C", 250, 0 }, ;
    { "adresg", "C", 250, 0 }, ;
    { "snils", "C", 50, 0 }, ;
    { "mr_dol", "C", 50, 0 }, ;
    { "diagnoz", "C", 100, 0 }, ;
    { "s_lech", "C", 20, 0 }, ;
    { "stoim", "N", 12, 2 }, ;
    { "uslugi", "C", 250, 0 } }
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  Index On Str( nomer, 4 ) to ( fr_data )
  //
  fp := FCreate( n_file )
  tek_stroke := 0
  n_list := 1
  If is_usl == 1
    dbCreate( cur_dir() + "tmp1", { { "shifr", "C", 10, 0 }, ;
      { "kol",  "N", 4, 0 }, ;
      { "data", "D", 8, 0 } } )
    Use ( cur_dir() + "tmp1" ) new
    Index On shifr + DToS( data ) to ( cur_dir() + "tmp11" )
    Index On fsort_usl( shifr ) + DToS( data ) to ( cur_dir() + "tmp12" )
    Set Index to ( cur_dir() + "tmp11" ), ( cur_dir() + "tmp12" )
  Endif
  r_use( dir_server + "mo_otd", , "OTD" )
  r_use( dir_server + "uslugi", dir_server + "uslugi", "USL" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  r_use( dir_server + "kartote_", , "KART_" )
  r_use( dir_server + "kartotek", , "KART" )
  Set Relation To RecNo() into KART_
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  If is_vyp == 1
    dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, { "fio", "C", 50, 0 } } )
    Use ( cur_dir() + "tmp" ) new
    Select HUMAN
    Set Index to ( dir_server + "humans" )
    find ( Str( schet->kod, 6 ) )
    Do While human->schet == schet->kod .and. !Eof()
      Select TMP
      Append Blank
      tmp->kod := human->kod
      tmp->fio := human->fio
      Select HUMAN
      Skip
    Enddo
    Select TMP
    Index On Upper( fio ) to ( cur_dir() + "tmp" )
    Use
    Private p_number := AllTrim( schet->nomer_s ), p_date := c4tod( schet->pdate )
  Endif
  frt->nschet := p_number
  frt->dschet := p_date
  Select HUMAN
  Set Index to ( dir_server + "humank" )
  Set Relation To RecNo() into HUMAN_, To otd into OTD, To kod_k into KART
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) New Alias TMP
  Go Top
  Select HUMAN
  find ( Str( tmp->kod, 7 ) )
  If human->komu == 5
    mkomu := "( Личный счет )"
  Else
    mkomu := 'в "' + func1_komu( human->komu, human->str_crb ) + '"'
  Endif
  frt->komu := mkomu
  //
  add_string( "ПОСТАВЩИК:  " + name_org + inn_org )
  add_string( "            " + adres_org + tel_org )
  add_string( "р/с N " + schet_org + " в " + bank_org + ", БИК " + mfo_org + ", кор/c " + mkorr_schet )
  add_string( Center( "Счет N " + AllTrim( p_number ) + " от " + full_date( p_date ) + " г.", sh ) )
  add_string( Center( "на оплату медицинских услуг", sh ) )
  add_string( "" )
  add_string( Center( mkomu, sh ) )
  add_string( "" )
  arr_title := { ;
    "════╤════════════════════════╤═════════════╤══════════╤════════════════════════╤══════════════════════╤═══════════╤═══════════╤═════════╤══════════════════════╤═════════", ;
    "    │                        │Серия и номер│          │                        │                      │   Шифры   │           │ Вид и   │                      │         ", ;
    " NN │    Ф.И.О. больного     │ страхового  │   Дата   │     Домашний  адрес    │   Место работы или   │ основного │   Срок    │ номеp   │    Место лечения     │Стоимость", ;
    " пп │                        │   полиса    │ рождения │                        │ причина безработности│и сопутств.│  лечения  │учетного │ (отделение, участок) │ лечения,", ;
    "    │                        │             │          │                        │                      │заболеваний│           │документа│                      │  в pуб. ", ;
    "────┼────────────────────────┼─────────────┼──────────┼────────────────────────┼──────────────────────┼───────────┼───────────┼─────────┼──────────────────────┼─────────", ;
    "  1 │           2            │      3      │    4     │            5           │           6          │     7     │     8     │    9    │          10          │    11   ", ;
    "════╧════════════════════════╧═════════════╧══════════╧════════════════════════╧══════════════════════╧═══════════╧═══════════╧═════════╧══════════════════════╧═════════" }
  arr1title := { ;
    "────┬────────────────────────┬─────────────┬──────────┬────────────────────────┬──────────────────────┬───────────┬───────────┬─────────┬──────────────────────┬─────────", ;
    "  1 │           2            │      3      │    4     │            5           │           6          │     7     │     8     │    9    │          10          │    11   ", ;
    "────┴────────────────────────┴─────────────┴──────────┴────────────────────────┴──────────────────────┴───────────┴───────────┴─────────┴──────────────────────┴─────────" }
  AEval( arr_title, {| x| add_string( x ) } )
  //
  hGauge := gaugenew( , , , "Составление счета", .t. )
  gaugedisplay( hGauge )
  Select TMP
  Go Top
  Do While !Eof()
    ++j
    gaugeupdate( hGauge, j / LastRec() )
    Select HUMAN
    find ( Str( tmp->kod, 7 ) )
    If Found()
      Select FRD
      Append Blank
      frd->nomer := j
      frd->fio := human->fio
      frd->pol := iif( human->pol == "М", "муж", "жен" )
      frd->date_r := human->date_r
      name_otd := AllTrim( otd->name )
      mpolis := human->polis
      srok_lech := iif( human->n_data == human->k_data, DToC( human->n_data ), SubStr( DToC( human->n_data ), 1, 5 ) + "-" + SubStr( DToC( human->k_data ), 1, 5 ) )
      frd->s_lech := srok_lech
      k1 := perenos( a_fio, human->fio, 24 )
      kp := perenos( a_polis, mpolis, 13 )
      tmp1 := ret_okato_ulica( kart->adres, kart_->okatog )
      frd->adresg := tmp1
      k2 := perenos( a_adres, tmp1, 24, " , ;" )
      k3 := perenos( a_rabota, human->mr_dol, 22 )
      arr := diag_to_array( , .t., , , .t. )
      tmp1 := ""
      AEval( arr, {| x| tmp1 += x + " " } )
      frd->diagnoz := tmp1
      k4 := perenos( a_shifr, tmp1, 11 )
      tmp := name_otd
      If FieldNum( "uchastok" ) > 0
        tmp += ", участок-" + lstr( human->uchastok )
      Endif
      frd->otd := tmp
      k5 := perenos( a_mesto_l, tmp, 22, " , ;" )
      If verify_ff( HH, .t., sh )
        AEval( arr1title, {| x| add_string( x ) } )
      Endif
      mcena_1 := human->cena_1
      mdate_r := full_date( human->date_r )
      s := ""
      If !Empty( kart_->ser_ud )
        s += AllTrim( kart_->ser_ud ) + " "
      Endif
      If !Empty( kart_->nom_ud )
        s += AllTrim( kart_->nom_ud )
      Endif
      s := get_name_vid_ud( kart_->vid_ud ) + ' ' + s

      frd->pasport := s
      If !Empty( kart->snils )
        frd->snils := Transform( kart->SNILS, picture_pf )
      Endif
      frd->mr_dol := human->mr_dol
      frd->stoim := human->cena_1
      add_string( put_val( j, 4 ) + "." + PadR( a_fio[ 1 ], 24 ) + " " + ;
        PadC( AllTrim( a_polis[ 1 ] ), 13 ) + ;
        " " + mdate_r + " " + PadR( a_adres[ 1 ], 24 ) + " " + ;
        PadR( a_rabota[ 1 ], 22 ) + " " + PadC( AllTrim( a_shifr[ 1 ] ), 11 ) + " " + ;
        PadC( srok_lech, 11 ) + " " + PadC( AllTrim( human->uch_doc ), 9 ) + " " + ;
        PadC( AllTrim( a_mesto_l[ 1 ] ), 22 ) + Str( mcena_1, 10, 2 ) )
      For k := 2 To Max( k1, k2, k3, k4, k5, kp )
        add_string( Space( 5 ) + PadR( a_fio[ k ], 25 ) + ;
          PadC( AllTrim( a_polis[ k ] ), 13 ) + ;
          Space( 12 ) + ;
          PadR( a_adres[ k ], 25 ) + ;
          PadR( a_rabota[ k ], 23 ) + PadC( AllTrim( a_shifr[ k ] ), 11 ) + ;
          Space( 23 ) + PadC( AllTrim( a_mesto_l[ k ] ), 22 ) )
      Next
      ob_summa += mcena_1
      If is_usl == 1 .and. mcena_1 >= razmer_usl
        Select HU
        find ( Str( tmp->kod, 7 ) )
        Do While hu->kod == tmp->kod .and. !Eof()
          Select USL
          find ( Str( hu->u_kod, 4 ) )
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If f_paraklinika( usl->shifr, lshifr1, human->k_data ) .and. hu->kol_1 > 0// .and. hu->u_cena > 0
            mdate := c4tod( hu->date_u )
            s := if( Empty( lshifr1 ), usl->shifr, lshifr1 )
            Select TMP1
            find ( s + DToS( mdate ) )
            If !Found()
              Append Blank
              tmp1->shifr := s
              tmp1->data := mdate
            Endif
            tmp1->kol += hu->kol_1
          Endif
          Select HU
          Skip
        Enddo
        Select TMP1
        Set Order To 2
        Go Top
        tmp := "Медуслуги:"
        Do While !Eof()
          If !Empty( tmp1->shifr )
            tmp += " " + AllTrim( tmp1->shifr ) + ;
              "(" + lstr( tmp1->kol ) + "," + date_8( tmp1->data ) + "),"
          Endif
          Skip
        Enddo
        tmp := Left( tmp, Len( tmp ) -1 )
        frd->uslugi := SubStr( tmp, 12 )
        j1 := perenos( a_fio, tmp, sh -10, " " )
        If verify_ff( HH - j1 -1, .t., sh )
          AEval( arr1title, {| x| add_string( x ) } )
        Endif
        For k := 1 To j1
          add_string( Space( 10 ) + a_fio[ k ] )
        Next
        add_string( "" )
        Select TMP1
        Zap
        Set Order To 1
      Endif
    Endif
    Select TMP
    Skip
  Enddo
  otd->( dbCloseArea() )
  usl->( dbCloseArea() )
  hu->( dbCloseArea() )
  kart_->( dbCloseArea() )
  kart->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  tmp->( dbCloseArea() )
  If is_usl == 1
    tmp1->( dbCloseArea() )
  Endif
  close_use_base( 'LUSL' )
  // if select("LUSL") > 0
  // lusl->(dbCloseArea())
  // lusl19->(dbCloseArea())
  // lusl18->(dbCloseArea())
  // endif
  closegauge( hGauge )
  If verify_ff( HH -8, .t., sh )
    AEval( arr1title, {| x| add_string( x ) } )
  Endif
  If is_vyp == 1  // если счет выписан, взять сумму из БД счетов
    ob_summa := schet->summa
  Endif
  frt->ssumma := srub_kop( ob_summa, .t. )
  frt->summa := ob_summa
  frt->kol := j
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "Количество пролеченных больных в счете - " + lstr( j ), sh -20 ) + "Итого: " + Str( ob_summa, 13, 2 ) )
  pj := j
  add_string( "" )
  For i := 1 To perenos( a_fio, "(" + srub_kop( ob_summa, .t. ) + ")", sh )
    add_string( a_fio[ i ] )
  Next
  add_string( "" )
  add_string( Space( 35 ) + "Руководитель      ________________________ / " + mruk + " /" )
  add_string( "" )
  add_string( Space( 35 ) + "Главный бухгалтер ________________________ / " + mbux + " /" )
  FClose( fp )
  frd->( dbCloseArea() )
  frt->( dbCloseArea() )
  rest_box( buf )
  If is_view
    name_fr := "mo_schpr" + sfr3()
    If _upr_epson() .or. !File( dir_exe() + name_fr )
      Private yes_albom := .t.
      viewtext( n_file, , , , .t., , , regim )
    Else
      call_fr( name_fr )
    Endif
  Endif

  Return Nil

// Исключение из счета некоторых больных
Function f1vyp_schet()

  Local i := 1, j, buf := save_box( T_ROW, 0, 24, 79 ), fl, ;
    str_sem, old_cena, new_cena
  Private old_summa := ob_summa, old_kol := ob_kol, regim_t := 1
  Private p_blk := {| mkol, msum| DevPos( 2, 10 ), ;
    DevOut( PadR( "Количество больных в счете: " + ;
    expand_value( mkol ) + " чел.", 50 ), color1 ), ;
    DevPos( 3, 10 ), ;
    DevOut( PadR( "Сумма счета: " + ;
    expand_value( msum, 2 ) + " руб.", 40 ), color1 ) }

  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" )
  fl := .f.
  If alpha_browse( T_ROW, 0, 20, 79, "f1_tmp_sch", color1, ;
      "Корректировка счета", "G+/B", .t., .t., , , "f2_tmp_sch", , ;
      { '═', '░', '═', "W+/B,W+/R,GR+/B,GR+/R", , 300 } )
    If ob_kol == 0
      func_error( 4, "В счете никого не осталось! Операция запрещена." )
    Elseif old_kol != ob_kol .and. f_esc_enter( "корректировки счета" )
      fl := .t.
      mywait()
      Delete For !plus
      Pack
      j := 0
      Select TMP
      Go Top
      Do While !Eof()
        tmp->NOMER := ++j
        Skip
      Enddo
    Endif
  Endif
  If !fl
    ob_summa := old_summa ; ob_kol := old_kol
    tmp->( dbEval( {|| tmp->plus := .t. } ) )
  Endif
  Close databases
  Eval( p_blk, ob_kol, ob_summa )
  rest_box( buf )

  Return Nil

//
Function f2vyp_schet()

  Local buf, tmp_color := SetColor(), buf24 := save_maxrow(), fl, mkod, i, hGauge

  buf := box_shadow( 15, 20, 20, 59, color8 )
  SetColor( cDataCGet )
  Private mnomer := Space( 10 ), mdate := sys_date
  If Type( "p_0_schet" ) == "L"
    mnomer := PadR( retnext0schet(), 10 )
    Keyboard Chr( K_TAB )
  Endif
  Do While .t.
    status_key( "^<Esc>^ - выход без записи счета;  ^<Enter>^ - подтверждение записи счета" )
    @ 17, 28 Say "Номер счета " Get mnomer Picture "@!"
    @ 18, 28 Say "Дата счета  " Get mdate
    myread( { "confirm" } )
    If LastKey() != K_ESC
      If Empty( mnomer )
        func_error( 4, "Вы не ввели номер счета!" )
        Loop
      Endif
      mywait()
      fl := .f.
      r_use( dir_server + "schet", dir_server + "schetn", "SCHET" )
      find ( mnomer )
      Do While schet->nomer_s == mnomer .and. !Eof()
        If Year( mdate ) == Year( c4tod( schet->pdate ) )
          fl := .t. ; Exit
        Endif
        Skip
      Enddo
      Use
      If fl
        func_error( 4, "В этом году счет с таким номером уже был выписан! Исправьте номер счета." )
        Loop
      Elseif f_esc_enter( "записи счета" )
        Use ( cur_dir() + "tmp" ) New Alias TMP
        Index On Upper( fio ) to ( cur_dir() + "tmp" )
        If use_base( "schet" ) .and. use_base( "human" )
          hGauge := gaugenew(, , { "GR+/RB", "BG+/RB", "G+/RB" }, ;
            "Запись номера счета по всем больным", .t. )
          gaugedisplay( hGauge )
          Select SCHET
          addrec( 6 )
          mkod := RecNo()
          Replace kod With mkod, nomer_s With mnomer, pdate With dtoc4( mdate ), ;
            komu With glob_komu, str_crb With glob_all[ 1 ], ;
            summa With ob_summa, kol With ob_kol, ;
            summa_ost With ob_summa, kol_ost With ob_kol
          //
          Select SCHET_
          Do While schet_->( LastRec() ) < mkod
            Append Blank
          Enddo
          Goto ( mkod )
          g_rlock( forever )
          schet_->NSCHET := mnomer
          schet_->DSCHET := mdate
          Unlock
          Commit
          // запись номера счета по больным
          i := 0
          Select TMP
          Go Top
          Do While !Eof()
            gaugeupdate( hGauge, RecNo() / LastRec() )
            Select HUMAN
            find ( Str( tmp->kod, 7 ) )
            If Found()  // на всякий случай
              g_rlock( forever )
              human->schet := mkod ; human->tip_h := B_SCHET
              human_->( g_rlock( forever ) )
              human_->schet_zap := ++i
              Unlock
            Endif
            Select TMP
            Skip
          Enddo
          Close databases
          closegauge( hGauge )
          stat_msg( "Запись счета завершена!" ) ; mybell( 2, OK )
        Endif
        Close databases
        Keyboard Chr( K_ESC )
        Exit
      Endif
    Else
      Exit
    Endif
  Enddo
  SetColor( tmp_color )
  rest_box( buf )
  rest_box( buf24 )

  Return Nil

//
Function usl_vyp_schet( amp )

  Local fl := .f., buf := SaveScreen(), buf1, r := 9, i := 3, k, ;
    tmp_color := SetColor(), tmp_help := help_code
  Private gl_area := { 1, 0, 23, 79, 0 }

  SetColor( cDataCGet )
  Do While .t.
    If i == 3
      mmax_kol := 999
      mn1_data := mn2_data := mk1_data := mk2_data := CToD( "" )
    Endif
    box_shadow( r, 8, r + 4, 71, color1, "Редактирование условий отбора в счет", color8 )
    @ r + 1, 10 Say "Макс.кол-во больных в счете" Get mmax_kol Pict "999"
    @ r + 2, 10 Say "Больные начали лечение с" Get mn1_data
    @ Row(), Col() + 1 Say "по" Get mn2_data
    @ r + 3, 10 Say "Больные закончили лечение с" Get mk1_data
    @ Row(), Col() + 1 Say "по" Get mk2_data
    status_key( "^<Esc>^ - отказ;  ^<PgDn>^ - подтверждение" )
    myread()
    buf1 := box_shadow( 19, 2, 23, 77, color0 )
    setmtcolor( col1menu )
    @ 21, 5 Prompt " ~Отказ "
    @ 21, 14 Prompt " Составить ~счет "
    @ 21, 32 Prompt " ~Очистка полей "
    @ 21, 49 Prompt " Продолжить ~редактирование "
    i := iif( LastKey() == K_ESC, 1, 2 )
    Menu To i
    rest_box( buf1 )
    If i < 2
      Exit
    Elseif i == 2
      buf1 := save_maxrow() ; k := 0 ; muslovie := "" ; str_kriterij := ""
      mywait()
      If !emptyall( mn1_data, mn2_data )
        str_kriterij += "Начало лечения:"
        If !Empty( mn1_data )
          str_kriterij += " после " + DToC( mn1_data ) + "; "
          muslovie += "tmp->n_data >= mn1_data .and. "
        Endif
        If !Empty( mn2_data )
          str_kriterij += " до " + DToC( mn2_data ) + "; "
          muslovie += "tmp->n_data <= mn2_data .and. "
        Endif
      Endif
      If !emptyall( mk1_data, mk2_data )
        str_kriterij += "Оконч.лечения:"
        If !Empty( mk1_data )
          str_kriterij += " после " + DToC( mk1_data ) + "; "
          muslovie += "tmp->k_data >= mk1_data .and. "
        Endif
        If !Empty( mk2_data )
          str_kriterij += " до " + DToC( mk2_data ) + "; "
          muslovie += "tmp->k_data <= mk2_data .and. "
        Endif
      Endif
      Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" )
      If Empty( muslovie )
        muslovie := ".t."
        str_kriterij := "Все больные"
        k := Min( tmp->( LastRec() ), mmax_kol )
      Else
        muslovie := Left( muslovie, Len( muslovie ) -7 )
        str_kriterij := Left( str_kriterij, Len( str_kriterij ) -2 )
        k := 0
        Go Top
        Do While !Eof()
          if &muslovie .and. k < mmax_kol
            ++k
          Endif
          Skip
        Enddo
      Endif
      Use
      rest_box( buf1 )
      If k == 0
        func_error( 4, "По данному условию некого включать в счет!" )
      Else
        fl := .t.
        Exit
      Endif
    Endif
  Enddo
  RestScreen( buf )
  SetColor( tmp_color )

  Return fl

//
Function other_schet_vozvrat()

  Local buf := SaveScreen(), i, s, mkod_opl, mdoplata, msmo, mdate, as := {}

  If input_schet( 0 )
    r_use( dir_server + "schet_", , "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetk", "SCHET" )
    Set Relation To RecNo() into SCHET_
    find ( Str( glob_schet, 6 ) )
    mkod_opl := schet->flag_opl ; mdate := c4tod( schet->pdate )
    mdoplata := schet_->IS_DOPLATA
    msmo := Val( schet_->smo )
    Close databases
    If mdoplata == 1
      func_error( 4, "Это счет на доплату! Возврат запрещен." )
    Elseif !Empty( msmo )
      func_error( 4, "Это счет ОМС! Возврат запрещен." )
    Elseif mkod_opl > 0
      func_error( 4, "По данному счету уже произведена оплата! Возврат запрещен." )
    Elseif ver_pub_date( mdate, .t. )
      i := 16
      box_shadow( i, 10, 22, 69, color0 )
      SetColor( "R/BG" )
      AAdd( as, glob_schet )
      str_center( i + 1, "Предупреждение!" )
      str_center( i + 2, "После подтверждения больные будут вычеркнуты" )
      str_center( i + 3, "из данного счета, а счет будет удален." )
      SetColor( color0 )
      setmtcolor( col1menu )
      @ 21, 24 Prompt " ~Отказ "
      @ 21, 33 Prompt " Подтверждение ~возврата "
      Menu To i
      If i == 2 .and. use_base( "schet" ) .and. use_base( "human" )
        Set Order To 6
        mywait()
        For i := 1 To Len( as )
          Do While .t.
            find ( Str( as[ i ], 6 ) )
            If !Found() ; exit ; Endif
            g_rlock( forever )
            human->schet := 0
            human->tip_h := B_STANDART
            human_->( g_rlock( forever ) )
            human_->schet_zap := 0
            Unlock
          Enddo
        Next
        Select SCHET
        find ( Str( glob_schet, 6 ) )
        Select SCHET_
        deleterec( .t., .f. ) // очистить и не помечать на удаление
        Select SCHET
        deleterec( .t. )
        Close databases
        stat_msg( "Возврат счета прошел успешно." ) ; mybell( 2, OK )
      Endif
    Endif
  Endif
  RestScreen( buf )

  Return Nil

//
Function f1_tmp_sch( oBrow )

  Local oColumn, tmp_color, blk_color := {|| if( tmp->plus, { 3, 4 }, { 1, 2 } ) }, ;
    s1, s2, s3, n := 42

  If regim_t == 3
    oColumn := TBColumnNew( Center( "Ф.И.О. больного", n + 2 ), {|| PadR( tmp->fio, n + 2 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Else
    oColumn := TBColumnNew( "   NN", {|| if( tmp->plus, "", " " ) + Str( tmp->nomer, 4 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( Center( "Ф.И.О. больного", n ), {|| PadR( tmp->fio, n ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "На-;чало", {|| Left( DToC( tmp->n_data ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Окончан.;лечения", {|| date_8( tmp->k_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "   Сумма", {|| PadL( expand_value( tmp->cena, 2 ), 13 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  tmp_color := SetColor( "N/W" )
  Do Case
  Case regim_t == 1
    s1 := "корректировки счета"
    s2 := "все включены в счет"
    s3 := "все исключены из счета"
  Case regim_t == 2
    s1 := "частичной оплаты счета"
    s2 := "все включены в частично оплачиваемый счет"
    s3 := "все исключены из счета"
  Case regim_t == 3
    s1 := "простановки стандарта"
    s2 := "всем проставлен стандарт"
    s3 := "никому не проставлен стандарт"
  Case regim_t == 4
    s1 := "возврата больных"
    s2 := "все оплачены"
    s3 := "все становятся неоплаченными"
  Endcase
  @ 21, 0 Say PadR( " <Esc> - выход без изменений;    <Enter> - подтверждение " + s1, 80 )
  @ 22, 0 Say PadR( " <Ins> - отметить одного больного или снять отметку с одного больного", 80 )
  @ 23, 0 Say PadR( " <+> - отметить всех больных (" + s2 + ")", 80 )
  @ 24, 0 Say PadR( " <-> - снять отметку со всех больных (" + s3 + ")", 80 )
  mark_keys( { s1 }, "R/W" )
  mark_keys( { "<Esc>", "<Enter>", "<Ins>", "<+>", "<->" }, "B/W" )
  SetColor( tmp_color )

  Return Nil

//
Function f2_tmp_sch( nKey, oBrow )

  Local buf, rec, k := -1

  Do Case
  Case nkey == K_INS
    Replace tmp->plus With !tmp->plus
    If tmp->plus
      ob_summa += tmp->cena ; ob_kol++
    Else
      ob_summa -= tmp->cena ; ob_kol--
    Endif
    Eval( p_blk, ob_kol, ob_summa )
    k := 0
    Keyboard Chr( K_TAB )
  Case nkey == 43 .or. nkey == 45  // + или -
    fl := ( nkey == 43 )
    rec := RecNo()
    buf := save_maxrow()
    mywait()
    tmp->( dbEval( {|| tmp->plus := fl } ) )
    Goto ( rec )
    rest_box( buf )
    If fl
      ob_summa := old_summa ; ob_kol := tmp->( LastRec() )
    Else
      ob_summa := ob_kol := 0
    Endif
    Eval( p_blk, ob_kol, ob_summa )
    k := 0
  Endcase

  Return k

//
Function retnext0schet()

  Local buf := save_maxrow(), n := 1, c2, c := "П"

  mywait( "Поиск следующего номера счета" )
  c2 := Left( dtoc4( mdate ), 2 )
  g_use( dir_server + "schet", , "SCHET" )
  Index On f_nom0sch( nomer_s ) to ( cur_dir() + "tmp_sch" ) ;
    For Left( nomer_s, 1 ) == c .and. Left( pdate, 2 ) == c2
  Go Top
  If !Eof()
    Go Bottom
    n := f_nom0sch( schet->nomer_s ) + 1
  Endif
  Close databases
  rest_box( buf )

  Return c + lstr( n )

// определить целую величину номера счета
Function f_nom0sch( s )

  Local c, i, n := 0

  s := SubStr( AllTrim( s ), 2 )
  For i := 1 To Len( s )
    c := Asc( SubStr( s, i, 1 ) )
    If Between( c, 48, 57 )  // если цифра
      n := Int( Val( SubStr( s, i ) ) )
      Exit
    Endif
  Next

  Return n


// 28.12.21
Function akt_kontrol_2012()

  Local buf, fl, ii := 0, fl_numeration := .f., str_sem := "Оплата счетов"
  Local t_arr[ BR_LEN ], blk, s

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  If g_slock( str_sem )
    buf := SaveScreen()
    fl := input_schet( 0 )
    RestScreen( buf )
    If fl
      r_use( dir_server + "schet_", , "SCHET_" )
      r_use( dir_server + "schet", dir_server + "schetk", "SCHET" )
      Set Relation To RecNo() into SCHET_
      find ( Str( glob_schet, 6 ) )
      Private snyear := schet_->nyear
      If emptyany( schet_->nyear, schet_->nmonth )
        fl_numeration := .t.
      Endif
      t_arr[ BR_TITUL ] := "Счёт № " + AllTrim( schet_->nschet ) + " от " + ;
        date_8( schet_->dschet ) + " " + f4_view_list_schet()
      //
      Private mm_eksp := { { "МЭК ", 1 }, ;
        { "МЭЭ ", 2 }, ;
        { "ЭКМП", 3 } }
      adbf := { { "nomer", "N", 4, 0 }, ;
        { "kod", "N", 7, 0 }, ;
        { "fio", "C", 50, 0 }, ;
        { "date_r", "D", 8, 0 }, ;
        { "stoim", "N", 10, 2 }, ;
        { "sump", "N", 10, 2 }, ;
        { "oplata", "N", 1, 0 }, ;
        { "is_ekps", "N", 1, 0 }, ;
        { "IS_REPEAT", "N", 1, 0 }, ;
        { "prim", "C", 20, 0 } }
      dbCreate( cur_dir() + "tmps", adbf )
      Use ( cur_dir() + "tmps" ) new
      r_use( dir_server + "mo_rak", , "RAK" )
      r_use( dir_server + "mo_raks", , "RAKS" )
      Set Relation To akt into RAK
      r_use( dir_server + "mo_raksh", , "RAKSH" )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_raksh" ) For raks->SCHET == glob_schet
      r_use( dir_server + "mo_os", , "MO_OS" )
      Index On Str( kod, 7 ) to ( cur_dir() + "tmp_moos" )
      r_use( dir_server + "human_", , "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      Select HUMAN
      find ( Str( glob_schet, 6 ) )
      Do While human->schet == glob_schet .and. !Eof()
        Select TMPS
        Append Blank
        tmps->nomer  := iif( fl_numeration, ++ii, human_->SCHET_ZAP )
        tmps->kod    := human->kod
        tmps->fio    := human->fio
        tmps->date_r := human->date_r
        tmps->stoim  := human->cena_1
        tmps->oplata := human_->oplata
        If human_->oplata == 1
          tmps->sump := human->cena_1
        Elseif eq_any( human_->oplata, 2, 9 )
          tmps->sump := 0
          tmps->oplata := 2
        Else
          tmps->sump := human_->sump
        Endif
        Select MO_OS
        find ( Str( human->kod, 7 ) )
        If Found()
          tmps->is_ekps := 1
          tmps->IS_REPEAT := mo_os->IS_REPEAT
          tmps->prim := _prim_akt_kontrol_2012()
        Elseif human_->oplata > 1
          s := ""
          If human_->oplata == 2
            s := "отказ"
          Elseif human_->oplata == 3
            s := "част."
          Elseif human_->oplata == 4
            s := "возврат"
          Elseif human_->oplata == 9
            s := "повтор"
          Endif
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          If Found()
            s += " " + AllTrim( rak->NAKT ) + " от " + date_8( rak->DAKT )
          Elseif !Empty( s )
            s += "-акт не найден"
          Endif
          tmps->prim := s
        Endif
        Select HUMAN
        Skip
      Enddo
      Close databases
      //
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := MaxRow() -1
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
      t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═", "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( tmps->is_ekps == 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { "№/пп", {|| tmps->nomer }, blk }, ;
        { " Ф.И.О.", {|| PadR( tmps->fio, 30 ) }, blk }, ;
        { "Дата рожд", {|| full_date( tmps->date_r ) }, blk }, ;
        { "Стоимость", {|| put_kop( tmps->stoim, 10 ) }, blk }, ;
        { " Примечание", {|| PadR( tmps->prim, 20 ) }, blk } }
      t_arr[ BR_EDIT ] := {| nk, ob| f1akt_kontrol_2012( nk, ob, "edit" ) }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ выход  ^<Del>^ отменить акт  ^<Enter>^ добавить акт  ^<F9>^ печать листа учёта" ) }
      Use ( cur_dir() + "tmps" ) new
      Index On nomer to ( cur_dir() + "tmps" )
      edit_browse( t_arr )
      Close databases
    Endif
    g_sunlock( str_sem )
  Else
    func_error( 4, "В данный момент с оплатой счетов работает другой пользователь." )
  Endif

  Return Nil

// 19.12.13
Static Function f1akt_kontrol_2012( nKey, oBrow, regim )

  Static mm_oplata := { { "полная оплата", 1 }, ;
    { "полный отказ", 2 }, ;
    { "частичный отказ", 3 } }
  Static mm_repeat := { { "нет (обычное снятие)", 0 }, ;
    { "повторное выставление листа учёта", 1 } }
  Local ret := -1, rec, buf, i, r, fl

  If regim == "edit"
    rec := RecNo()
    glob_perso := tmps->kod
    Do Case
    Case nKey == K_ENTER
      If snyear > 2012
        func_error( 4, 'С 2013 года снятие осуществляется в режиме "Реестр актов контроля"' )
        Return ret
      Endif
      buf := SaveScreen()
      Private makt := Space( 15 ), mdate_opl := sys_date, ;
        mtip_eksp, m1tip_eksp := 1, msump := tmps->stoim, ;
        moplata, m1oplata := tmps->oplata, ;
        mrepeat, m1repeat := tmps->IS_REPEAT, ;
        merror := Space( 10 ), m1error := 0, ;
        gl_area := { 1, 0, 23, 79, 0 }
      g_use( dir_server + "mo_os", cur_dir() + "tmp_moos", "MO_OS" )
      If tmps->is_ekps == 1
        find ( Str( glob_perso, 7 ) )
        If Found()
          makt := mo_os->AKT
          mdate_opl := mo_os->DATE_OPL
          m1oplata := mo_os->oplata
          msump := mo_os->sump
          If !Empty( mo_os->SANK_MEE )
            m1tip_eksp := 2
          Elseif !Empty( mo_os->SANK_EKMP )
            m1tip_eksp := 3
          Endif
          If ( m1error := mo_os->REFREASON ) > 0
            // merror := inieditspr(A__POPUPMENU, dir_exe()+"_mo_t005", m1error)
            merror := inieditspr( A__POPUPMENU, loadt005(), m1error )
          Endif
        Endif
      Endif
      mtip_eksp := inieditspr( A__MENUVERT, mm_eksp, m1tip_eksp )
      moplata := inieditspr( A__MENUVERT, mm_oplata, m1oplata )
      mrepeat := inieditspr( A__MENUVERT, mm_repeat, m1repeat )
      //
      r := pr1 + 1
      SetColor( cDataCGet )
      clrlines( r, 23 )
      @ r, 0 Say PadC( iif( mo_os->( Found() ), "Просмотр", "Ввод" ) + " акта снятия", 80, "─" ) Color "B+/B"
      @ r + 2, 1 Say "Номер случая в счёте" Get tmps->nomer When .f.
      @ r + 3, 1 Say "Пациент" Get tmps->fio When .f.
      @ r + 4, 1 Say "Дата рождения" Get tmps->date_r When .f.
      @ r + 5, 1 Say "Сумма случая" Get tmps->stoim When .f.
      @ r + 6, 1 Say " Вид оплаты" Get moplata ;
        reader {| x| menu_reader( x, mm_oplata, A__MENUVERT, , , .f. ) } ;
        valid {|| iif( m1oplata == 2, msump := 0, nil ), update_get( "msump" ) }
      @ r + 7, 1 Say "Сумма, принятая к оплате" Get msump Pict "9999999.99" ;
        When m1oplata == 3
      @ r + 8, 1 Say "Номер акта" Get makt When m1oplata > 1
      @ Row(), Col() + 3 Say "Дата акта" Get mdate_opl When m1oplata > 1
      @ r + 9, 1 Say "Вид экспертизы" Get mtip_eksp ;
        reader {| x| menu_reader( x, mm_eksp, A__MENUVERT, , , .f. ) } ;
        When m1oplata > 1
      // @ r+10,1 say "Код дефекта" get merror ;
      // reader {|x|menu_reader(x,{dir_exe()+"_mo_t005"},A__POPUPEDIT, , , .f.)} ;
      // when m1oplata > 1
      @ r + 10, 1 Say "Код дефекта" Get merror ;
        reader {| x| menu_reader( x, { loadt005() }, A__POPUPEDIT, , , .f. ) } ;
        When m1oplata > 1
      @ r + 11, 1 Say "Выставить случай повторно?" Get mrepeat ;
        reader {| x| menu_reader( x, mm_repeat, A__MENUVERT, , , .f. ) } ;
        When m1oplata == 2
      If mo_os->( Found() )
        clear_gets()
        stat_msg( "Нажмите любую клавишу" )
        Inkey( 0 )
        SetLastKey( K_ESC )
      Else
        Keyboard Chr( K_ENTER )
        status_key( "^<Esc>^ - отказ;  ^<PgDn>^ - подтверждение записи акта" )
        myread()
      Endif
      fl := ( LastKey() != K_ESC )
      If fl .and. m1oplata == 1
        fl := func_error( 4, "Не было ввода акта снятия" )
      Endif
      If fl .and. m1oplata == 3
        m1repeat := 0
        If Round( tmps->stoim, 2 ) <= Round( msump, 2 )
          fl := func_error( 4, "Сумма, принятая к оплате, должна быть меньше суммы случая" )
        Endif
        If Empty( msump ) .or. msump < 0
          fl := func_error( 4, "Сумма, принятая к оплате, должна быть больше нуля" )
        Endif
      Endif
      If fl .and. f_esc_enter( "записи акта снятия", .t. )
        If m1repeat == 1
          // сначала запоминаем копию листа учёта в массивах
          use_base( "human" )
          Set Relation To // "отвязываем"
          Goto ( glob_perso )
          ahuman := get_field()
          Select HUMAN_
          Goto ( glob_perso )
          ahuman_ := get_field()
          Select HUMAN_2
          Goto ( glob_perso )
          ahuman_2 := get_field()
          If ( fl_iname := ( human_->smo == '34   ' ) )
            g_use( dir_server + "mo_hismo", , "SN" )
            Index On Str( kod, 7 ) to ( cur_dir() + "tmp_ismo" )
            find ( Str( glob_perso, 7 ) )
            mnameismo := sn->smo_name
          Endif
          arr_hu := {}
          use_base( "human_u" )
          Set Relation To // "отвязываем"
          find ( Str( glob_perso, 7 ) )
          Do While hu->kod == glob_perso .and. !Eof()
            ahu := get_field()
            Select HU_
            Goto ( hu->( RecNo() ) )
            ahu_ := get_field()
            AAdd( arr_hu, { ahu, ahu_ } )
            Select HU
            Skip
          Enddo
        Endif
        Select MO_OS
        addrec( 7 )
        mo_os->KOD := glob_perso
        mo_os->AKT := makt
        mo_os->DATE_OPL := mdate_opl
        mo_os->OPLATA := m1oplata
        mo_os->IS_REPEAT := m1repeat
        mo_os->SUMP := msump
        If m1tip_eksp == 1
          mo_os->SANK_MEK := tmps->stoim - msump
        Elseif m1tip_eksp == 2
          mo_os->SANK_MEE := tmps->stoim - msump
        Elseif m1tip_eksp == 3
          mo_os->SANK_EKMP := tmps->stoim - msump
        Endif
        mo_os->REFREASON := m1error
        mo_os->NEXT_KOD  := 0
        //
        tmps->is_ekps := 1
        tmps->IS_REPEAT := m1repeat
        tmps->prim := _prim_akt_kontrol_2012()
        //
        If m1repeat == 1
          Select HUMAN_
        Else
          g_use( dir_server + "human_", , "HUMAN_" )
        Endif
        Goto ( glob_perso )
        g_rlock( forever )
        human_->OPLATA := iif( m1repeat == 0, mo_os->OPLATA, 9 )
        human_->SUMP      := mo_os->SUMP
        human_->SANK_MEK  := mo_os->SANK_MEK
        human_->SANK_MEE  := mo_os->SANK_MEE
        human_->SANK_EKMP := mo_os->SANK_EKMP
        If m1repeat == 1
          // теперь записываем в БД копию листа учёта
          Select HUMAN
          add1rec( 7 )
          mkod := RecNo()
          AEval( ahuman, {| x, i| FieldPut( i, x ) } )
          human->kod      := mkod
          human->TIP_H    := B_STANDART // лечение завершено
          // human->DATE_OPL := ""
          human->schet    := 0
          //
          mo_os->NEXT_KOD := mkod // запомним, в какую запись попала копия л/у
          //
          Select HUMAN_
          Do While human_->( LastRec() ) < mkod
            Append Blank
          Enddo
          Goto ( mkod )
          g_rlock( forever )
          AEval( ahuman_, {| x, i| FieldPut( i, x ) } )
          human_->KOD_UP    := glob_perso // код оригинального листа учёта
          human_->SUMP      := 0
          human_->OPLATA    := 0
          human_->SANK_MEK  := 0
          human_->SANK_MEE  := 0
          human_->SANK_EKMP := 0
          human_->REESTR    := 0
          human_->REES_ZAP  := 0
          human_->SCHET_ZAP := 0
          human_->ST_VERIFY := 0 // снова ещё не проверен
          //
          Select HUMAN_2
          Do While human_2->( LastRec() ) < mkod
            Append Blank
          Enddo
          Goto ( mkod )
          g_rlock( forever )
          AEval( ahuman_2, {| x, i| FieldPut( i, x ) } )
          If fl_iname
            Select SN
            find ( Str( mkod, 7 ) )
            If Found()
              If !Empty( mnameismo )
                g_rlock( forever )
                sn->smo_name := mnameismo
              Else
                deleterec( .t. )
              Endif
            Else
              If !Empty( mnameismo )
                addrec( 7 )
                sn->kod := mkod
                sn->smo_name := mnameismo
              Endif
            Endif
          Endif
          For i := 1 To Len( arr_hu )
            Select HU
            add1rec( 7 )
            AEval( arr_hu[ i, 1 ], {| x, i| FieldPut( i, x ) } )
            hu->kod := mkod
            Select HU_
            Do While hu_->( LastRec() ) < hu->( RecNo() )
              Append Blank
            Enddo
            Goto ( hu->( RecNo() ) )
            g_rlock( forever )
            AEval( arr_hu[ i, 2 ], {| x, i| FieldPut( i, x ) } )
            hu_->OPLATA    := 0
            hu_->REES_ZAP  := 0
            hu_->SCHET_ZAP := 0
          Next
        Endif
      Endif
      Close databases
      RestScreen( buf )
      Use ( cur_dir() + "tmps" ) index ( cur_dir() + "tmps" ) new
      Goto ( rec )
      ret := 0
    Case nKey == K_DEL
      If tmps->is_ekps == 1 .and. f_esc_enter( "удаления акта снятия", .t. )
        buf := SaveScreen()
        fl := .t.
        If tmps->IS_REPEAT == 1
          f_message( { "", "При удалении данного акта снятия", ;
            "также будет удалён повторно выставленный", ;
            "лист учёта", "" }, , "GR+/R", "W+/R" )
          fl := f_esc_enter( "удаления акта снятия", .t. )
        Endif
        If fl
          g_use( dir_server + "mo_os", cur_dir() + "tmp_moos", "MO_OS" )
          find ( Str( glob_perso, 7 ) )
          mkod := mo_os->NEXT_KOD
          If tmps->IS_REPEAT == 1 .and. mkod > 0
            // удаляем повторно выставленный лист учёта
            use_base( "human" )
            find ( Str( mkod, 7 ) )
            If human->schet > 0 .or. human_->REESTR > 0
              fl := func_error( 10, "Повторно выставленный лист учёта уже попал в реестр (счёт). Удаление запрещено!" )
            Endif
            If fl
              use_base( "mo_hu" )
              Do While .t.
                Select MOHU
                find ( Str( mkod, 7 ) )
                If !Found() ; exit ; Endif
                deleterec( .t., .f. )  // без пометки на удаление
              Enddo
              use_base( "human_u" )
              Do While .t.
                Select HU
                find ( Str( mkod, 7 ) )
                If !Found() ; exit ; Endif
                //
                Select HU_
                deleterec( .t., .f. )
                Select HU
                deleterec( .t., .f. )  // без пометки на удаление
              Enddo
              Select HUMAN_
              deleterec( .t., .f. )
              Select HUMAN
              deleterec( .t., .f. )  // без пометки на удаление
              g_rlock( forever )
              Replace human->schet With -1  // (вместо нуля)
            Endif
          Else
            g_use( dir_server + "human_", , "HUMAN_" )
          Endif
          If fl
            Select HUMAN_
            Goto ( glob_perso )
            g_rlock( forever )
            human_->OPLATA    := 1
            human_->SANK_MEK  := 0
            human_->SANK_MEE  := 0
            human_->SANK_EKMP := 0
            Unlock
            //
            Select MO_OS
            find ( Str( glob_perso, 7 ) )
            If Found()
              deleterec( .t. )
            Endif
            //
            tmps->is_ekps := 0
            tmps->IS_REPEAT := 0
            tmps->prim := ""
          Endif
        Endif
        RestScreen( buf )
        Close databases
        Use ( cur_dir() + "tmps" ) index ( cur_dir() + "tmps" ) new
        Goto ( rec )
      Endif
      ret := 0
    Case nKey == K_F9
      print_l_uch( glob_perso )
      Use ( cur_dir() + "tmps" ) index ( cur_dir() + "tmps" ) new
      Goto ( rec )
    Endcase
  Endif

  Return ret

// 19.12.13
Static Function _prim_akt_kontrol_2012()

  Local i := 0, s := ""

  If !Empty( mo_os->SANK_MEK )
    i := 1
  Elseif !Empty( mo_os->SANK_MEE )
    i := 2
  Elseif !Empty( mo_os->SANK_EKMP )
    i := 3
  Endif
  If i > 0
    s := AllTrim( mm_eksp[ i, 1 ] ) + " "
  Endif
  s += Left( date_8( mo_os->DATE_OPL ), 5 ) + " "
  If mo_os->IS_REPEAT == 1
    s += "повторно выставлен"
  Elseif mo_os->oplata == 2
    s += "полный отказ"
  Elseif mo_os->oplata > 2
    s += "(" + lstr( mo_os->sump, 10, 2 ) + ")"
  Endif

  Return s

// отметка о регистрации счетов в ТФОМС
Function registr_schet()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code, ;
    mdate := SToD( "20110101" )

  mywait()
  g_use( dir_server + "schet_", , "SCHET_" )
  g_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + schet_->nschet to ( cur_dir() + "tmp_sch" ) ;
    For schet_->dschet >= mdate .and. !Empty( pdate ) .and. ;
    ( schet_->IS_DOPLATA == 1 .or. !Empty( Val( schet_->smo ) ) ) ;
    DESCENDING
  Go Top
  If Eof()
    RestScreen( buf )
    Close databases
    Return func_error( 4, "Нет выписанных счетов c " + date_month( mdate ) )
  Endif
  chm_help_code := 1// H_opl_schet
  alpha_browse( T_ROW, 0, 23, 79, "f1_view_registr_schet", color0, , , , , , , ;
    "f2_view_registr_schet", , { '═', '░', '═', "N/BG,W+/N,R/BG,W+/R,RB/BG,W+/RB,GR/BG,W+/GR", .t., 60 } )
  Close databases
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil

//
Function f1_view_registr_schet( oBrow )

  Local s, oColumn, ;
    blk := {|| iif( schet_->NREGISTR == 3, { 7, 8 }, ;
    iif( schet_->NREGISTR == 2, { 5, 6 }, ;
    iif( schet_->NREGISTR == 1, { 3, 4 }, { 1, 2 } ) ) ) }

  oColumn := TBColumnNew( "Номер счета", {|| schet_->nschet } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Дата", {|| date_8( schet_->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Пе-;риод", ;
    {|| iif( emptyany( schet_->nyear, schet_->nmonth ), ;
    Space( 5 ), ;
    Right( Str( schet_->nyear, 4 ), 2 ) + "/" + StrZero( schet_->nmonth, 2 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Сумма счета", {|| put_kop( schet->summa, 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Кол.;бол.", {|| Str( schet->kol, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Дата ре-;гистрац.", {|| f11_view_registr_schet() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Примечание", {|| PadR( f12_view_registr_schet(), 19 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход  ^<Enter>^ регистрация  ^<F2>^ поиск  ^<F9>^ печать незарег.счетов" )

  Return Nil

//
Function f11_view_registr_schet()

  Local mdate := schet_->dregistr

  If eq_any( schet_->NREGISTR, 0, 2 ) .and. Empty( mdate )
    mdate := schet_->dschet
  Endif

  Return date_8( mdate )

//
Function f12_view_registr_schet()

  Local s := ""

  If schet_->NREGISTR == 3
    s := "удалён/перевыставлен"
  Elseif schet_->NREGISTR == 2
    s := iif( Empty( schet_->SREGISTR ), "отказ в регистрации", schet_->SREGISTR )
  Elseif schet_->NREGISTR == 1
    s := "ещё не зарегистрирован"
  Endif

  Return s

//
Function f2_view_registr_schet( nKey, oBrow )

  Static mm_tip := { { "не зарегистрирован ", 1 }, ;
    { "зарегистрирован    ", 0 }, ;
    { "отказ в регистрации", 2 } }
  Local ret := -1, rec := schet->( RecNo() ), tmp_color := SetColor(), ;
    r1, buf := SaveScreen(), rec1, fl

  Do Case
  Case nKey == K_ENTER
    If schet_->NREGISTR == 3
      func_error( 4, "Счёт удалён. Случаи перевыставлены. Редактирование запрещено!" )
      Return ret
    Endif
    Private mdate, mtitle, mtip, m1tip, mprim, gl_area := { r1, 2, 22, 77, 0 }
    mdate := schet_->dschet
    mtitle := " №" + AllTrim( schet_->nschet ) + " от " + date_8( schet_->dschet ) + "г."
    mprim := Space( 20 )
    If schet_->NREGISTR == 1
      m1tip := 1
    Elseif schet_->NREGISTR == 2
      m1tip := 2
      If !Empty( schet_->dregistr )
        mdate := schet_->dregistr
      Endif
      mprim := schet_->sregistr
    Else
      m1tip := 0
      If !Empty( schet_->dregistr )
        mdate := schet_->dregistr
      Endif
    Endif
    mtip := inieditspr( A__MENUVERT, mm_tip, m1tip )
    r1 := 15
    SetColor( cDataCGet )
    box_shadow( r1, 2, 22, 77, , "Регистрация счёта" + mtitle, color8 )
    @ r1 + 2, 4 Say "Отметка о регистрации" Get mtip ;
      reader {| x| menu_reader( x, mm_tip, A__MENUVERT, , , .f. ) }
    @ r1 + 3, 4 Say "Дата регистрации (отказа)" Get mdate When m1tip != 1
    @ r1 + 4, 4 Say "Причина отказа" Get mprim When m1tip == 2
    status_key( "^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода" )
    myread()
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      Select SCHET_
      g_rlock( forever )
      schet_->nregistr := m1tip
      If m1tip != 1
        schet_->dregistr := mdate
      Endif
      schet_->sregistr := iif( m1tip == 2, mprim, "" )
      Unlock
      Commit
      Select SCHET
      ret := 0
    Endif
  Case nKey == K_F2
    Private ar := getinisect( tmp_ini, "schet" )
    Private mnomer := PadR( a2default( ar, "number" ), 15 )
    box_shadow( 16, 20, 20, 59, color8 )
    SetColor( cDataCGet )
    status_key( "^<Esc>^ - отказ;  ^<Enter>^ - подтверждение выбора счета" )
    @ 18, 22 Say "Введите номер счета" Get mnomer Picture "@!@K"
    myread( { "confirm" } )
    rec1 := 0
    If LastKey() != K_ESC .and. !Empty( mnomer )
      mywait()
      Go Top
      Locate For schet_->NSCHET == mnomer
      If Found()
        rec1 := schet->( RecNo() )
      Else
        func_error( 4, "Не найден счёт с номером " + AllTrim( mnomer ) )
      Endif
    Endif
    If rec1 == 0
      Goto ( rec )
    Else
      oBrow:gotop()
      Goto ( rec1 )
      setinivar( tmp_ini, { { "schet", "number", mnomer } } )
      ret := 0
    Endif
  Case nKey == K_F9
    ne_real()
  Case nKey == K_CTRL_F12 .and. schet_->NREGISTR == 1
    fl := .f.
    Private mkod_schet := schet->kod
    Private name_schet := AllTrim( schet_->nschet )
    Private _date_schet := schet_->dschet
    Close databases
    If g_slock1task( sem_task, sem_vagno ) // запрет доступа всем
      If involved_password( 4, name_schet, "удаления/перевыставления счёта " + name_schet ) ;
          .and. f_esc_enter( "удаления счёта" ) ;
          .and. m_copy_db_from_end( .t. ) // резервное копирование
        waitstatus( "Перевыставление случаев из удаляемого счёта" )
        arr_human := {}
        fl_iname := .f.
        use_base( "human_u" )
        Set Relation To // "отвязываем"
        use_base( "mo_hu" )
        Set Relation To // "отвязываем"
        use_base( "human" )
        Set Order To 6
        find ( Str( mkod_schet, 6 ) )
        Do While human->schet == mkod_schet .and. !Eof()
          If human_->smo == '34   '
            fl_iname := .t.
          Endif
          AAdd( arr_human, human->( RecNo() ) )
          Skip
        Enddo
        Select HUMAN
        Set Order To 1
        Set Relation To // "отвязываем"
        If fl_iname
          g_use( dir_server + "mo_hismo", , "SN" )
          Index On Str( kod, 7 ) to ( cur_dir() + "tmp_ismo" )
        Endif
        For ii := 1 To Len( arr_human )
          updatestatus()
          glob_perso := arr_human[ ii ]
          Select HUMAN
          Goto ( glob_perso )
          ahuman := get_field()
          Select HUMAN_
          Goto ( glob_perso )
          ahuman_ := get_field()
          Select HUMAN_2
          Goto ( glob_perso )
          ahuman_2 := get_field()
          mnameismo := ""
          If fl_iname .and. human_->smo == '34   '
            Select SN
            find ( Str( glob_perso, 7 ) )
            mnameismo := sn->smo_name
          Endif
          arr_hu := {}
          Select HU
          find ( Str( glob_perso, 7 ) )
          Do While hu->kod == glob_perso .and. !Eof()
            ahu := get_field()
            Select HU_
            Goto ( hu->( RecNo() ) )
            ahu_ := get_field()
            AAdd( arr_hu, { ahu, ahu_ } )
            Select HU
            Skip
          Enddo
          arr_mohu := {}
          Select MOHU
          find ( Str( glob_perso, 7 ) )
          Do While mohu->kod == glob_perso .and. !Eof()
            AAdd( arr_mohu, get_field() )
            Skip
          Enddo
          arr_disp := read_arr_dispans( glob_perso )
          //
          Select HUMAN_
          Goto ( glob_perso )
          g_rlock( forever )
          human_->OPLATA := 9
          // теперь записываем в БД копию листа учёта
          Select HUMAN
          add1rec( 7 )
          mkod := RecNo()
          AEval( ahuman, {| x, i| FieldPut( i, x ) } )
          human->kod      := mkod
          human->TIP_H    := B_STANDART // лечение завершено
          // human->DATE_OPL := ""
          human->schet    := 0
          //
          Select HUMAN_
          Do While human_->( LastRec() ) < mkod
            Append Blank
          Enddo
          Goto ( mkod )
          g_rlock( forever )
          AEval( ahuman_, {| x, i| FieldPut( i, x ) } )
          human_->KOD_UP    := glob_perso // код оригинального листа учёта
          human_->SUMP      := 0
          human_->OPLATA    := 0
          human_->SANK_MEK  := 0
          human_->SANK_MEE  := 0
          human_->SANK_EKMP := 0
          human_->REESTR    := 0
          human_->REES_ZAP  := 0
          human_->SCHET_ZAP := 0
          human_->ST_VERIFY := 0 // снова ещё не проверен
          If human_->SCHET_NUM > 0
            human_->SCHET_NUM := human_->SCHET_NUM -1
          Endif
          //
          Select HUMAN_2
          Do While human_2->( LastRec() ) < mkod
            Append Blank
          Enddo
          Goto ( mkod )
          g_rlock( forever )
          AEval( ahuman_2, {| x, i| FieldPut( i, x ) } )
          If fl_iname .and. human_->smo == '34   '
            Select SN
            find ( Str( mkod, 7 ) )
            If Found()
              If !Empty( mnameismo )
                g_rlock( forever )
                sn->smo_name := mnameismo
              Else
                deleterec( .t. )
              Endif
            Else
              If !Empty( mnameismo )
                addrec( 7 )
                sn->kod := mkod
                sn->smo_name := mnameismo
              Endif
            Endif
          Endif
          For i := 1 To Len( arr_hu )
            Select HU
            add1rec( 7 )
            AEval( arr_hu[ i, 1 ], {| x, i| FieldPut( i, x ) } )
            hu->kod := mkod
            Select HU_
            Do While hu_->( LastRec() ) < hu->( RecNo() )
              Append Blank
            Enddo
            Goto ( hu->( RecNo() ) )
            g_rlock( forever )
            AEval( arr_hu[ i, 2 ], {| x, i| FieldPut( i, x ) } )
            hu_->OPLATA    := 0
            hu_->REES_ZAP  := 0
            hu_->SCHET_ZAP := 0
          Next
          //
          For i := 1 To Len( arr_mohu )
            Select MOHU
            add1rec( 7 )
            AEval( arr_mohu[ i ], {| x, i| FieldPut( i, x ) } )
            mohu->kod       := mkod
            mohu->OPLATA    := 0
            mohu->REES_ZAP  := 0
            mohu->SCHET_ZAP := 0
          Next
          save_arr_dispans( mkod, arr_disp )
        Next
        fl := .t.
      Endif
      Close databases
      // разрешение доступа всем
      g_sunlock( sem_vagno )
      Keyboard ""
    Else
      func_error( 4, "В данный момент работают другие задачи. Операция запрещена!" )
    Endif
    g_use( dir_server + "schet_", , "SCHET_" )
    g_use( dir_server + "schet", cur_dir() + "tmp_sch", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Goto ( rec )
    If fl
      Select SCHET_
      g_rlock( forever )
      schet_->nregistr := 3
      schet_->dregistr := sys_date
      schet_->sregistr := "удалён и перевыставлен"
      Unlock
      Commit
      Select SCHET
      stat_msg( "Счёт удалён. Все случаи перевыставлены. Отредактируйте их!" )
      mybell( 2, OK )
    Endif
    rec := 0
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 05.10.17 печать счёта-фактуры
Function print_faktura( regim )

  Local adbf := {}, ip := 0, s, ret

  //
  If ( ret := input_diapazon( MaxRow() -4, 9, MaxRow() -2, 68, color8, ;
      { "Введите номер", "и дату", "счёта-фактуры" }, ;
      { schet->nomer_s, c4tod( schet->pdate ) } ) ) == NIL
    Return Nil
  Endif
  //
  Private pole := "_t->name"
  delfrfiles()
  dbCreate( fr_titl, { { "title1", "C", 100, 0 }, ;
    { "title2", "C", 100, 0 }, ;
    { "name01", "C", 200, 0 }, ;
    { "name02", "C", 200, 0 }, ;
    { "name03", "C", 200, 0 }, ;
    { "name04", "C", 200, 0 }, ;
    { "name05", "C", 200, 0 }, ;
    { "name06", "C", 200, 0 }, ;
    { "name07", "C", 200, 0 }, ;
    { "name08", "C", 200, 0 }, ;
    { "name09", "C", 200, 0 }, ;
    { "name10", "C", 200, 0 }, ;
    { "name11", "C", 200, 0 }, ;
    { "name12", "C", 200, 0 }, ;
    { "name13", "C", 200, 0 }, ;
    { "name14", "C", 200, 0 }, ;
    { "name15", "C", 200, 0 }, ;
    { "pril", "C", 200, 0 }, ;
    { "pril2", "C", 100, 0 }, ;
    { "bottom", "C", 2000, 0 }, ;
    { "stoim", "C", 15, 0 }, ;
    { "nds", "C", 15, 0 }, ;
    { "itogo", "C", 15, 0 }, ;
    { "ind_pred", "C", 80, 0 }, ;
    { "svid_vo", "C", 80, 0 }, ;
    { "fio_ruk", "C", 50, 0 }, ;
    { "fio_bux", "C", 50, 0 } } )
  For j := 1 To 13
    AAdd( adbf, { "p_" + lstr( j ), "C", 60, 0 } )
  Next
  dbCreate( fr_data, adbf )
  Use ( fr_titl ) New Alias _t
  Append Blank
  Use ( fr_data ) New Alias _d
  r_use( dir_server + "organiz", , "ORG" )
  r_use( dir_server + "kartote_", , "KART_" )
  r_use( dir_server + "kartotek", , "KART" )
  Set Relation To RecNo() into KART_
  r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
  Set Relation To kod_k into KART
  find ( Str( schet->kod, 6 ) )
  pok_name := pok_adres := pok_inn := ""
  s := "Оказание медицинских услуг - "
  If schet->komu == 5
    pok_name := AllTrim( human->fio )
    pok_adres := ret_okato_ulica( kart->adres, kart_->okatog )
    s += fam_i_o( pok_name )
  Else
    If schet->kol == 1
      s += fam_i_o( human->fio )
    Else
      s += lstr( schet->kol ) + " чел."
    Endif
    If schet->komu == 1
      r_use( dir_server + "str_komp", , "PK" )
      Goto ( schet->str_crb )
    Else
      r_use( dir_server + "komitet", , "PK" )
      Goto ( schet->str_crb )
    Endif
    pok_name := AllTrim( iif( Empty( pk->fname ), pk->name, pk->fname ) )
    pok_adres := AllTrim( pk->adres )
    pok_inn := AllTrim( pk->inn )
    pk->( dbCloseArea() )
  Endif
  kart_->( dbCloseArea() )
  kart->( dbCloseArea() )
  human->( dbCloseArea() )
  //
  _t->pril := "Приложение № 1" + eos + ;
    "к постановлению Правительства" + eos + ;
    "Российской Федерации" + eos + ;
    "от 26 декабря 2011 г. № 1137"
  _t->pril2 := "(в ред.Постановления Правительства РФ от 19.08.2017 №981)"
  _t->title1 := "СЧЕТ-ФАКТУРА  № " + AllTrim( ret[ 1 ] ) + " от " + date_month( ret[ 2 ], .t. )
  _t->title2 := "ИСПРАВЛЕНИЕ   № -          от -"
  ip := 1
  &( pole + StrZero( ++ip, 2 ) ) := "Продавец :  " + org->name
  &( pole + StrZero( ++ip, 2 ) ) := "Адрес :  " + org->adres
  &( pole + StrZero( ++ip, 2 ) ) := "ИНН/КПП продавца :  " + org->inn
  &( pole + StrZero( ++ip, 2 ) ) := "Грузоотправитель и его адрес :  " + AllTrim( org->name ) + ", " + org->adres
  &( pole + StrZero( ++ip, 2 ) ) := "Грузополучатель и его адрес :  " + pok_name + ", " + pok_adres
  &( pole + StrZero( ++ip, 2 ) ) := "К платежно-расчетному документу № _________ от ____________________"
  &( pole + StrZero( ++ip, 2 ) ) := "Покупатель :  " + pok_name
  &( pole + StrZero( ++ip, 2 ) ) := "Адрес :  " + pok_adres
  &( pole + StrZero( ++ip, 2 ) ) := "ИНН/КПП покупателя :  " + pok_inn
  &( pole + StrZero( ++ip, 2 ) ) := "Валюта: наименование, код :  Российский рубль, 643"
  &( pole + StrZero( ++ip, 2 ) ) := "Идентификатор государственного контракта, договора (соглашения) (при наличии):"
  Select _d
  Append Blank
  _d->p_1 := s
  _d->p_2 := "-"
  _d->p_3 := "-"
  _d->p_4 := "1"
  _d->p_5 := lstr( schet->summa, 11, 2 )
  _d->p_6 := lstr( schet->summa, 13, 2 )
  _d->p_7 := "без акциза"
  _d->p_8 := _d->p_9 := "без НДС"
  _d->p_10 := lstr( schet->summa, 13, 2 )
  _d->p_11 := "643"
  _d->p_12 := "Россия"
  // _d->p_13 := mtamog
  _t->stoim := lstr( schet->summa, 15, 2 )
  _t->nds := ""
  _t->itogo := lstr( schet->summa, 15, 2 )
  _t->fio_ruk := AllTrim( org->ruk )
  _t->fio_bux := AllTrim( org->bux )
  org->( dbCloseArea() )
  _d->( dbCloseArea() )
  _t->( dbCloseArea() )
  call_fr( "mo_faktu" + sfr3() )

  Return Nil

// 07.12.12 печать акта выполненных работ
Function print_akt( regim )

  Local adbf := {}, s, ret

  //
  If ( ret := input_diapazon( MaxRow() -4, 14, MaxRow() -2, 64, color8, ;
      { "Введите номер", "и дату", "акта" }, ;
      { schet->nomer_s, c4tod( schet->pdate ) } ) ) == NIL
    Return Nil
  Endif
  //
  delfrfiles()
  dbCreate( fr_titl, { { "nomer", "C", 10, 0 }, ;
    { "data", "C", 30, 0 }, ;
    { "prod_name", "C", 150, 0 }, ;
    { "prod_adres", "C", 100, 0 }, ;
    { "prod_inn", "C", 20, 0 }, ;
    { "pok_name", "C", 150, 0 }, ;
    { "pok_adres", "C", 100, 0 }, ;
    { "pok_inn", "C", 20, 0 }, ;
    { "stoim", "C", 15, 0 }, ;
    { "sstoim", "C", 200, 0 } } )
  For j := 1 To 7
    AAdd( adbf, { "p_" + lstr( j ), "C", 60, 0 } )
  Next
  dbCreate( fr_data, adbf )
  Use ( fr_titl ) New Alias _t
  Append Blank
  Use ( fr_data ) New Alias _d
  r_use( dir_server + "organiz", , "ORG" )
  r_use( dir_server + "kartote_", , "KART_" )
  r_use( dir_server + "kartotek", , "KART" )
  Set Relation To RecNo() into KART_
  r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
  Set Relation To kod_k into KART
  find ( Str( schet->kod, 6 ) )
  p_name := p_adres := p_inn := ""
  s := "Оказание медицинских услуг - "
  If schet->komu == 5
    p_name := AllTrim( human->fio )
    p_adres := ret_okato_ulica( kart->adres, kart_->okatog )
    s += fam_i_o( human->fio )
  Else
    If schet->kol == 1
      s += fam_i_o( human->fio )
    Else
      s += lstr( schet->kol ) + " чел."
    Endif
    If schet->komu == 1
      r_use( dir_server + "str_komp", , "PK" )
      Goto ( schet->str_crb )
    Else
      r_use( dir_server + "komitet", , "PK" )
      Goto ( schet->str_crb )
    Endif
    p_name := AllTrim( iif( Empty( pk->fname ), pk->name, pk->fname ) )
    p_adres := AllTrim( pk->adres )
    p_inn := AllTrim( pk->inn )
    pk->( dbCloseArea() )
  Endif
  kart_->( dbCloseArea() )
  kart->( dbCloseArea() )
  human->( dbCloseArea() )
  //
  _t->nomer := AllTrim( ret[ 1 ] )
  _t->data := date_month( ret[ 2 ], .t. )
  _t->prod_name := org->name
  _t->prod_adres := org->adres
  _t->prod_inn := org->inn
  _t->pok_name := p_name
  _t->pok_adres := p_adres
  _t->pok_inn := p_inn
  Select _d
  Append Blank
  _d->p_1 := s
  _d->p_2 := "1"
  _d->p_3 := _d->p_4 := lstr( schet->summa, 11, 2 )
  _d->p_5 := _d->p_6 := "-"
  _d->p_7 := lstr( schet->summa, 13, 2 )
  _t->stoim := lstr( schet->summa, 15, 2 )
  _t->sstoim := srub_kop( schet->summa, .t. )
  org->( dbCloseArea() )
  _d->( dbCloseArea() )
  _t->( dbCloseArea() )
  call_fr( "mo_akt" + sfr3() )

  Return Nil

// 17.03.13 список незарегистрированных счетов
Function spisok_s_not_registred()

  Local i, k, mdate := SToD( "20110101" ), ;
    sh, HH := 60, reg_print, n_file := "ne_zag_s.txt"

  mywait()
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + schet_->nschet to ( cur_dir() + "tmp_sch" ) ;
    For schet_->NREGISTR > 0 .and. schet_->dschet >= mdate .and. !Empty( pdate ) .and. ;
    ( schet_->IS_DOPLATA == 1 .or. !Empty( Val( schet_->smo ) ) ) ;
    DESCENDING
  Go Top
  arr_title := { ;
    "───────────────┬──────────┬───────┬─────────────┬────┬──────────────────────────", ;
    "  Номер счета  │   Дата   │Период │ Сумма счета │Кол.│ Примечание               ", ;
    "               │   счёта  │       │             │бол.│                          ", ;
    "───────────────┴──────────┴───────┴─────────────┴────┴──────────────────────────" }
  reg_print := 2
  f_reg_print( arr_title, @sh )
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( 'Список незарегистрированных счетов', sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Do While !Eof()
    s := schet_->nschet + " " + full_date( schet_->dschet ) + " " + ;
      iif( emptyany( schet_->nyear, schet_->nmonth ), Space( 7 ), ;
      Str( schet_->nyear, 4 ) + "/" + StrZero( schet_->nmonth, 2 ) ) + ;
      put_kop( schet->summa, 14 ) + Str( schet->kol, 5 ) + " " + ;
      f12_view_registr_schet()
    add_string( s )
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  FClose( fp )
  Close databases
  viewtext( n_file, , , , ( sh > 80 ), , , reg_print )
  Return Nil

// для совместимости со старой версией программы
Function func1_komu( lkomu, lstr_crb )
  Return f4_view_list_schet( lkomu, '', lstr_crb )

