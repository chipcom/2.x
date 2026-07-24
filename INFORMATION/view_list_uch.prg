// view_lists_uch.prg - просмотр листов учета по ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 16.07.26
Function print_l_uch( mkod, par, regim, lnomer )

  // mkod - код больного по БД human

  Local sh := 80, HH := 77, buf := save_maxrow(), ;
    name_lpu, name_otd := '', mvzros_reb, mrab_nerab, ;
    mkomu, name_org, mlech_vr := '', msumma := 0, ;
    mud_lich := '', arr, n_file := cur_dir() + 'list_uch.txt', adiag_talon[ 16 ], ;
    madres, i := 1, j, k, tmp[ 2 ], tmp1, w1 := 37, s, s1, mnum_lu, lshifr1
  Local tmpAlias
  Local arrLekPreparat, arrImplantant, row
  Local cREGNUM, cUNITCODE, cMETHOD
  Local lTypeLUMedReab := .f., aMedReab
  Local diagVspom := '', diagMemory := '', add_criteria
  Local arrKSLP, akslp, len_akslp, arrKIRO, akiro
  Local k_kslp, tmp_kslp := {}
  Local k_kiro, tmp_kiro := {}
  Local mas[ 2 ], lname
  Local lExistFilesTFOMS
  Local lDisp := .f., sh_zam, lZam := .f.
  Local nTipLu

  Default par To 1, regim To 1, lnomer To 0
  mywait()
  fp := FCreate( n_file )
  tek_stroke := 0
  n_list := 1
  //
  r_use( dir_server() + 'organiz', , 'ORG' )
  name_org := AllTrim( org->name )
  dbCloseAll()
  If !myfiledeleted( cur_dir() + 'tmp1' + sdbf() )
    Return Nil
  Endif
  dbCreate( cur_dir() + 'tmp1', { { 'kod', 'N', 4, 0 }, ;
    { 'name', 'C', 255, 0 }, ;
    { 'shifr', 'C', 20, 0 }, ;
    { 'shifr1', 'C', 20, 0 }, ;
    { 'dom', 'N', 1, 0 }, ;
    { 'zf', 'C', 30, 0 }, ;
    { 'kod_diag', 'C', 5, 0 }, ;
    { 'date_u1', 'D', 8, 0 }, ;
    { 'date_u2', 'D', 8, 0 }, ;
    { 'rec_hu', 'N', 8, 0 }, ;
    { 'otd', 'C', 5, 0 }, ;
    { 'plus', 'L', 1, 0 }, ;
    { 'is_edit', 'N', 2, 0 }, ;
    { 'kod_vr', 'N', 5, 0 }, ;
    { 'kod_as', 'N', 5, 0 }, ;
    { 'profil', 'N', 4, 0 }, ;
    { 'kol', 'N', 4, 0 }, ;
    { 'summa', 'N', 11, 2 } } )
  Use ( cur_dir() + 'tmp1' )
  Index On Str( FIELD->kod, 4 ) to ( cur_dir() + 'tmp11' )
  Index On DToS( FIELD->date_u1 ) + fsort_usl( FIELD->shifr ) to ( cur_dir() + 'tmp12' )
  Use ( cur_dir() + 'tmp1' ) index ( cur_dir() + 'tmp11' ), ( cur_dir() + 'tmp12' ) Alias tmp1
  use_base( 'lusl' )
  use_base( 'luslf' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u_', , 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  Goto ( mkod )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  Goto ( mkod )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Goto ( mkod )
  r_use( dir_server() + 'mo_pers', , 'PERSO' )
  Goto ( human_->vrach )
  mlech_vr := iif( Empty( perso->tab_nom ), '', lstr( perso->tab_nom ) + ' ' ) + AllTrim( perso->fio )
  otd->( dbGoto( human->otd ) )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  Goto ( human->kod_k )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Goto ( human->kod_k )
  //
  Private mvid_ud := kart_->vid_ud, ;
    mser    := kart_->ser_ud, ;
    mnom    := kart_->nom_ud, ;
    m1kategor := kart_->kategor, ;
    m1povod  := human_->POVOD, ;
    m1travma := human_->TRAVMA
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  Private M1F14_EKST := Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) )
  Private M1F14_SKOR := Int( Val( SubStr( human_->FORMA14, 2, 1 ) ) )
  Private M1F14_VSKR := Int( Val( SubStr( human_->FORMA14, 3, 1 ) ) )
  Private M1F14_RASH := Int( Val( SubStr( human_->FORMA14, 4, 1 ) ) )
  If mvid_ud > 0
    mud_lich := get_name_vid_ud( mvid_ud, , ': ' )
    If !Empty( mser )
      mud_lich += CharOne( ' ', mser ) + ' '
    Endif
    If !Empty( mnom )
      mud_lich += mnom + ' '
    Endif
  Endif
  mpolis := AllTrim( RTrim( human_->SPOLIS ) + ' ' + human_->NPOLIS ) + ' (' + ;
    AllTrim( inieditspr( A__MENUVERT, mm_vid_polis(), human_->VPOLIS ) ) + ')'
  madres := iif( emptyall( kart_->okatog, kart->adres ), '', ret_okato_ulica( kart->adres, kart_->okatog ) )
  madresp := iif( emptyall( kart_->okatop, kart_->adresp ), '', ret_okato_ulica( kart_->adresp, kart_->okatop ) )
  //
  If human->tip_h >= B_SCHET .and. human->schet > 0 // добавление номера счета
    r_use( dir_server() + 'schet_', , 'SCHET_' )
    Goto ( human->schet )
    r_use( dir_server() + 'schet', , 'SCHET' )
    Goto ( human->schet )
    add_string( 'Счет № ' + AllTrim( schet_->nschet ) + ' от ' + date_8( schet_->dschet ) + 'г.' + ;
      if( human_->SCHET_ZAP == 0, '', '  [ № ' + lstr( human_->SCHET_ZAP ) + ' ]' ) )
    If eq_any( human_->oplata, 2, 3, 9 )
      s := iif( eq_any( human_->oplata, 2, 9 ), 'Не', 'Частично' ) + ' оплачен. '
      If human_->oplata == 3
        s += '(' + lstr( human_->sump ) + ') '
      Endif
      r_use( dir_server() + 'mo_os', , 'MO_OS' )
      Locate For kod == mkod
      If Found()
        s += 'Акт № ' + AllTrim( mo_os->AKT ) + ' от ' + date_8( mo_os->DATE_OPL ) + ' '
        // if !empty(s1 := ret_t005(mo_os->REFREASON))
        If ! Empty( s1 := ret_f014( mo_os->REFREASON ) )
          s += 'Код дефекта ' + s1 + '. '
        Endif
        If mo_os->IS_REPEAT == 1
          s += 'Лист учёта выставлен повторно.'
        Endif
      Else
        r_use( dir_server() + 'mo_rak', , 'RAK' )
        r_use( dir_server() + 'mo_raks', , 'RAKS' )
        Set Relation To FIELD->akt into RAK
        r_use( dir_server() + 'mo_raksh', , 'RAKSH' )
        Set Relation To FIELD->kod_raks into RAKS
        arr := {}
        Index On Str( FIELD->kod_h, 7 ) to ( cur_dir() + 'tmp_raksh' ) For FIELD->kod_h == mkod
        // Locate for kod_h == mkod
        // do while found()
        // aadd(arr, {rak->NAKT, rak->DAKT, raksh->REFREASON, raksh->NEXT_KOD})
        // continue
        // enddo
        find( Str( mkod, 7 ) )
        If Found()
          Do While raksh->kod_h == mkod .and. !Eof()
            AAdd( arr, { rak->NAKT, rak->DAKT, raksh->REFREASON, raksh->NEXT_KOD } )
            Skip
          Enddo
        Endif
        //
        ASort( arr, , , {| x, y| x[ 2 ] < y[ 2 ] } )
        For i := 1 To Len( arr )
          s += 'Акт № ' + AllTrim( arr[ i, 1 ] ) + ' от ' + date_8( arr[ i, 2 ] ) + '. '
          // if !empty(s1 := ret_t005(arr[i, 3]))
          If ! Empty( s1 := ret_f014( arr[ i, 3 ] ) )
            s += 'Код дефекта ' + s1 + '. '
          Endif
          If arr[ i, 4 ] > 0
            s += 'Лист учёта выставлен повторно. '
          Endif
          If i < Len( arr )
            s += '; '
          Endif
        Next
      Endif
      For i := 1 To perenos( tmp, s, sh )
        add_string( tmp[ i ] )
      Next
    Endif
    add_string( '' )
  Endif
  name_lpu := RTrim( inieditspr( A__MENUVERT, getuch(), human->lpu ) )
  name_otd := '  [ ' + AllTrim( otd->name ) + ' ]'
  nTipLu := otd->tiplu
  lTypeLUMedReab := ( otd->tiplu == TIP_LU_MED_REAB )

  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros(), human->vzros_reb )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab(), kart->rab_nerab )
  mkomu := f4_view_list_schet( human->komu, cut_code_smo( human_->smo ), human->str_crb )
  mnum_lu := AllTrim( human->uch_doc )
  If yes_num_lu == 1
    mnum_lu += ' [' + lstr( human->kod ) + ']'
  Endif
  //
  If ! ( lExistFilesTFOMS := check_files_tfoms( Year( human->k_data ) ) )  // проверим наличие справочников ТФОМС
    func_error( 4, 'Отсутствуют справочники ТФОМС за ' + Str( Year( human->k_data ), 4 ) + ' год.' )
  Endif

  For i := 1 To perenos( tmp, name_org, sh )
    add_string( Center( AllTrim( tmp[ i ] ), sh ) )
  Next
  add_string( '' )
  add_string( Center( name_lpu + name_otd, sh ) )
  add_string( '' )
  add_string( Center( 'Л_И_С_Т  У_Ч_Е_Т_А', sh ) )
  add_string( Center( 'М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  № ' + mnum_lu, sh ) )
  print_l_uch_disp( sh )
  If eq_any( human->ishod, 88, 89 )
    Select HUMAN_3
    If human->ishod == 88
      Set Order To 1
      is_2 := 1
    Else
      Set Order To 2
      is_2 := 2
    Endif
    find ( Str( human->kod, 7 ) )
    If Found() // если нашли двойной случай
      add_string( '' )
      add_string( 'Это двойной случай (с ' + date_8( human_3->N_DATA ) + ' по ' + date_8( human_3->K_DATA ) + ' на сумму ' + lstr( human_3->CENA_1, 10, 2 ) + 'р.)' )
    Endif
  Endif
  add_string( '' )
  add_string( '  Ф.И.О.: ' + human->fio + '          Пол: ' + human->pol )
  add_string( '  Дата рождения: ' + full_date( human->date_r ) + '  (' + mvzros_reb + ')' )
  // add_string('  СНИЛС: ' + transform(kart->SNILS, picture_pf))
  add_string( '  СНИЛС: ' + transform_snils( kart->SNILS ) )

  If !Empty( mud_lich )
    k := perenos( tmp, mud_lich, sh -2 )
    add_string( '  ' + tmp[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
    Next
  Endif
  k := perenos( tmp, 'Место рождения: ' + kart_->mesto_r, sh -2 )
  add_string( '  ' + tmp[ 1 ] )
  For i := 2 To k
    add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
  Next
  k := perenos( tmp, 'Адрес регистрации: ' + madres, sh -2 )
  add_string( '  ' + tmp[ 1 ] )
  For i := 2 To k
    add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
  Next
  If !Empty( madresp )
    k := perenos( tmp, 'Адрес пребывания: ' + madresp, sh -2 )
    add_string( '  ' + tmp[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
    Next
  Endif
  If !Empty( human->mr_dol )
    add_string( '  Место работы/учебы: ' + human->mr_dol )
  Endif
  add_string( '  Статус пациента: ' + mrab_nerab )
  add_string( '  Социальная категория пациента: ' + inieditspr( A__MENUVERT, mm_soc(), Val( kart->PC3 ) ) )

  If human_->NOVOR > 0
    add_string( '' )
    add_string( '  Новорожденный: ' + lstr( human_->NOVOR ) + '-й ребёнок, д.р. ' + ;
      date_8( human_->DATE_R2 ) + ', пол ' + human_->POL2 )
    add_string( '' )
  Endif
  If !Empty( human_->NPR_MO ) .and. !( human_->NPR_MO == glob_mo[ _MO_KOD_TFOMS ] )
    k := perenos( tmp, 'Направившая МО: ' + ret_mo( human_->NPR_MO )[ _MO_FULL_NAME ], sh -2 )
    add_string( '  ' + tmp[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
    Next
    If !Empty( human_2->NPR_DATE )
      add_string( '  Дата направления: ' + full_date( human_2->NPR_DATE ) )
    Endif
  Endif
  add_string( '  Принадлежность счета: ' + mkomu )
  add_string( '  Серия и номер страхового полиса: ' + mpolis )
  If M1F14_EKST == 1
    s := '  Госпитализирован по экстренным показаниям'
    If M1F14_SKOR == 1
      s += ' (доставлен скорой мед.помощью)'
    Endif
    add_string( s )
  Endif
  s := ''
  If eq_any( human->ishod, 201, 202, 203, 401, 402, 501, 502 )  // дисп-ия (профосмотр) взрослого населения
    Private pole_diag, pole_1pervich
    For i := 1 To 5
      pole_diag := 'mdiag' + lstr( i )
      pole_1pervich := 'm1pervich' + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_1pervich := 0
    Next
    If eq_any( human->ishod, 501, 502 )  // дисп-ия  репродуктивного здоровья взрослого населения
      read_arr_drz( human->kod )
    Else
      read_arr_dvn( human->kod )
    Endif
    arr := {}
    For i := 1 To 5
      pole_diag := 'mdiag' + lstr( i )
      pole_1pervich := 'm1pervich' + lstr( i )
      If !Empty( &pole_diag ) .and. &pole_1pervich == 2  // предварительный диагноз
        AAdd( arr, &pole_diag )
      Endif
    Next
    For j := 1 To Len( arr )
      s += ' ' + AllTrim( arr[ j ] )
    Next
    If !Empty( s )
      s := '  Предварительный диагноз: ' + s
    Endif
  Elseif !Empty( human_->KOD_DIAG0 )
    s := '  Первичный диагноз: ' + human_->KOD_DIAG0
  Endif
  If !Empty( s )
    add_string( s )
  Endif
  arr := diag_to_array( , .t., .t., .t., .t., adiag_talon )
  If Len( arr ) > 0
    If eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. diagnosis_for_replacement( arr[ 1 ], human_->USL_OK )
      diagVspom := AllTrim( arr[ 1 ] )
      diagMemory := AllTrim( arr[ 2 ] )
    Endif
    add_string( '  Основной диагноз: ' + iif( Empty( diagVspom ), arr[ 1 ], arr[ 2 ] + ' (!!!вспомогательный диагноз ' + diagVspom + '!!!)' ) )
    If Year( human->k_data ) > 2017 .and. !Empty( human_2->pc3 )
      k := 0
      add_string( '  Дополнительный критерий : ' )
      If lExistFilesTFOMS
        add_criteria := getarraycriteria( human->K_DATA, human_2->pc3 )
        If ! Empty( add_criteria )
          If Year( human->k_data ) >= 2021
            k := perenos( tmp, AllTrim( human_2->pc3 ) + ' - ' + AllTrim( add_criteria[ 6 ] ), sh -3 )
            For i := 1 To k
              add_string( Space( 3 ) + tmp[ i ] )
            Next
          Else
            add_string( Space( 3 ) + AllTrim( human_2->pc3 ) )
          Endif
        Endif
      Else
        add_string( Space( 3 ) + AllTrim( human_2->pc3 ) )
      Endif
    Endif
    If Len( arr ) > 1
      tmp1 := '  Сопутствующие диагнозы:'
      For j := iif( Empty( diagVspom ), 2, 3 ) To Len( arr )
        tmp1 += ' ' + arr[ j ]
      Next
      add_string( tmp1 )
    Endif
  Endif
  tmp1 := ''
  arr := { human_2->OSL1, human_2->OSL2, human_2->OSL3 }
  For j := 1 To Len( arr )
    tmp1 += ' ' + arr[ j ]
  Next
  If !Empty( tmp1 )
    add_string( '  Диагнозы осложнения:' + tmp1 )
  Endif
  If lTypeLUMedReab
    aMedReab := list2arr( human_2->PC5 )  // [1], list2arr(human_2->PC5)[2]
    If Len( aMedReab ) > 0
      add_string( '' )
      add_string( '  Вид реаблитации: ' + inieditspr( A__MENUVERT, type_reabilitacia(), aMedReab[ 1 ] ) )
      add_string( '  Шкала Реабилитационной Маршрутизации: ' + inieditspr( A__MENUVERT, type_shrm_reabilitacia(), aMedReab[ 2 ] ) )
    Endif
  Endif

  add_string( '  Медицинская помощь: условия оказания: ' + inieditspr( A__MENUVERT, getv006(), human_->USL_OK ) )
  If human_->PROFIL > 0
    k := perenos( tmp, 'профиль: ' + inieditspr( A__MENUVERT, getv002(), human_->PROFIL ), sh -4 )
    add_string( Space( 4 ) + tmp[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
    Next
  Endif
  If human_2->PROFIL_K > 0 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    k := perenos( tmp, 'профиль койки: ' + inieditspr( A__MENUVERT, getv020(), human_2->PROFIL_K ), sh -4 )
    add_string( Space( 4 ) + tmp[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
    Next
  Endif
  k := perenos( tmp, inieditspr( A__MENUVERT, getv010(), human_->IDSP ), sh -19 )
  add_string( '    способ оплаты: ' + tmp[ 1 ] )
  For i := 2 To k
    add_string( Space( 19 ) + tmp[ i ] )
  Next
  k := perenos( tmp, 'Результат обращения: ' + inieditspr( A__MENUVERT, getv009(), human_->RSLT_NEW ), sh -2 )
  add_string( '  ' + tmp[ 1 ] )
  For i := 2 To k
    add_string( PadL( AllTrim( tmp[ i ] ), sh ) )
  Next
  If human->OBRASHEN == '1'
    add_string( '  Признак подозрения на злокачественное новообразование: да' )
  Endif
  add_string( '  Исход заболевания: ' + inieditspr( A__MENUVERT, getv012(), human_->ISHOD_NEW ) )
  If is_death( human_->RSLT_NEW ) .and. M1F14_VSKR == 1 // смерть
    s := '  Проведено патологоанатомическое вскрытие'
    If M1F14_RASH == 1
      s += ' (установлено расхождение диагнозов)'
    Endif
    add_string( s )
  Endif
  If human_2->VMP == 1 .and. !Empty( human_2->VIDVMP )
    If !Empty( human_2->TAL_NUM )
      add_string( '  Номер талона на ВМП: ' + human_2->TAL_NUM )
    Endif
    If lExistFilesTFOMS
      k := perenos( tmp, ret_v018( human_2->VIDVMP, human->k_data ), sh -11 )
      add_string( '  Вид ВМП: ' + tmp[ 1 ] )
      For i := 2 To k
        add_string( Space( 11 ) + tmp[ i ] )
      Next
      If !Empty( human_2->METVMP )
        k := perenos( tmp, ret_v019( human_2->METVMP, human_2->VIDVMP, human->k_data ), sh -14 )
        add_string( '   метод ВМП: ' + tmp[ 1 ] )
        For i := 2 To k
          add_string( Space( 14 ) + tmp[ i ] )
        Next
      Endif
    Endif
  Endif

  If HUMAN_2->PN6 == 1
    add_string( '' )
    add_string( '  Пациент направлен на МСЭ в бюро медико-социальной экспертизы' )
  Endif

  add_string( '  Вид помощи: ' + AllTrim( inieditspr( A__MENUVERT, getv008(), human_->VIDPOM ) ) )
  If human_->USL_OK == USL_OK_POLYCLINIC
    add_string( '  Цель посещения: ' + get_npc_from_v025_by_idpc( human_->P_CEL ) )// inieditspr( A__MENUVERT, getv008(), human_->VIDPOM ) ) )
  Endif
  If ! Between( human_->RSLT_NEW, 316, 393 ) // если не диспансеризация и т.п.
    If !Empty( mlech_vr )
      add_string( '  Лечащий врач : ' + mlech_vr )
    Endif
  Else
    lDisp := .t.
  Endif

  add_string( '' )
  add_string( Center( 'Срок лечения с ' + full_date( human->n_data ) + ' по ' + full_date( human->k_data ), sh ) )
  add_string( '' )
  If human->bolnich > 0
    add_string( '  Временная нетрудоспособность (больничный) с ' + ;
      full_date( c4tod( human->date_b_1 ) ) + ' по ' + full_date( c4tod( human->date_b_2 ) ) )
    If human->bolnich == 2
      add_string( '  (По уходу: дата рождения родителя ' + ;
        full_date( human_->RODIT_DR ) + ', пол ' + human_->RODIT_POL + ')' )
    Endif
    add_string( '' )
  Endif
  add_string( Center( 'О_К_А_З_А_Н_Ы   У_С_Л_У_Г_И', sh ) )
  Select HU
  find ( Str( mkod, 7 ) )
  Do While hu->kod == mkod .and. ! hu->( Eof() )
    lZam := .f.
    If ! emptyall( hu->kol_1, hu->stoim_1 )
      Select OTD
      Goto ( hu->otd )
      Select USL
      Goto ( hu->u_kod )
      lname := usl->name

      tmpAlias := create_name_alias( 'LUSL',  Year( human->k_data ) )
      If lExistFilesTFOMS
        Select ( tmpAlias )
        If c4tod( hu->date_u ) < human->n_data .and. lDisp
          lZam := .t.
          // sh_zam := get_zamenauslugi_dvn( human->k_data, alltrim( usl->shifr ) )
          sh_zam := get_zamenauslugi_on_date( nTipLu, human->k_data, AllTrim( usl->shifr ) )
          find ( PadR( sh_zam, 10 ) )
        Else
          find ( PadR( usl->shifr, 10 ) )
        Endif

        If Found()
          lname := ( tmpAlias )->name  // наименование услуги из справочника ТФОМС
        Endif
      Endif
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      Select TMP1
      tmp1->( dbAppend() )    // append blank
      tmp1->kod := usl->kod
      tmp1->name := lname
      If lZam
        tmp1->shifr := sh_zam
        tmp1->shifr1 := sh_zam
      Else
        tmp1->shifr := usl->shifr // iif(empty(lshifr1), usl->shifr, lshifr1)
        tmp1->shifr1 := lshifr1
      Endif
      tmp1->date_u1 := c4tod( hu->date_u )
      tmp1->date_u2 := c4tod( hu_->date_u2 )
      tmp1->rec_hu := hu->( RecNo() )
      tmp1->kod_diag := hu_->KOD_DIAG
      tmp1->dom := iif( Between( hu->kol_rcp, -2, -1 ), -hu->kol_rcp, 0 )
      tmp1->otd := otd->short_name
      If lExistFilesTFOMS
        If human->k_data < 0d20120301
          tmp1->plus := !f_paraklinika( usl->shifr, lshifr1, c4tod( hu->date_u ) )
        Else
          tmp1->plus := !f_paraklinika( usl->shifr, lshifr1, human->k_data )
        Endif
      Endif
      tmp1->profil := hu_->profil
      tmp1->is_edit := hu->is_edit
      tmp1->kod_vr := hu->kod_vr
      tmp1->kod_as := hu->kod_as
      tmp1->kol += hu->kol_1
      If lZam
        tmp1->summa += 0
      Else
        tmp1->summa += hu->stoim_1
      Endif
    Endif
    Select HU
    hu->( dbSkip() )    // Skip
  Enddo
  Select MOHU
  find ( Str( mkod, 7 ) )
  Do While mohu->kod == mkod .and. !Eof()
    If !Empty( mohu->kol_1 )
      Select OTD
      Goto ( mohu->otd )
      Select MOSU
      Goto ( mohu->u_kod )
      lname := mosu->name
      If lExistFilesTFOMS
        tmpAlias := create_name_alias( 'LUSLF',  Year( human->k_data ) )
        Select ( tmpAlias )
        find ( PadR( mosu->shifr1, 20 ) )
        If Found()
          lname := ( tmpAlias )->name  // наименование услуги из справочника ТФОМС
        Endif
      Endif

      Select TMP1
      tmp1->( dbAppend() )    // append blank
      tmp1->kod := mosu->kod
      tmp1->name := lname
      tmp1->shifr := iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr )
      tmp1->shifr1 := mosu->shifr1
      tmp1->date_u1 := c4tod( mohu->date_u )
      tmp1->date_u2 := c4tod( mohu->date_u2 )
      tmp1->rec_hu := mohu->( RecNo() )
      tmp1->kod_diag := mohu->KOD_DIAG
      If stiszf( human_->USL_OK, human_->PROFIL )
        tmp1->zf := mohu->ZF
      Endif
      tmp1->otd := otd->short_name
      tmp1->plus := .f.
      tmp1->kod_vr := mohu->kod_vr
      tmp1->kod_as := mohu->kod_as
      tmp1->kol += mohu->kol_1
      tmp1->summa += mohu->stoim_1
    Endif
    Select MOHU
    mohu->( dbSkip() )    // Skip
  Enddo
  mpsumma := 0
  w1 := 34
  header_uslugi( w1 )
  Select TMP1
  Set Order To 2
  tmp1->( dbGoTop() )   // go top
  Do While ! tmp1->( Eof() )
    s := AllTrim( tmp1->shifr )
    If ! ( AllTrim( tmp1->shifr ) == AllTrim( tmp1->shifr1 ) ) .and. ! Empty( tmp1->shifr1 )
      s += '(' + AllTrim( tmp1->shifr1 ) + ')'
    Endif
    s += iif( tmp1->dom == 1, '/на дому/', iif( tmp1->dom == 2, '/домАКТИВ/', ' ' ) )
    s += AllTrim( tmp1->name )
    If eq_any( AllTrim( tmp1->shifr ), '2.3.1', '2.3.3', '2.6.1', '2.60.1' )
      s += ' (' + AllTrim( inieditspr( A__MENUVERT, getv002(), tmp1->PROFIL ) ) + ')'
    Elseif !Empty( tmp1->zf )
      s += ' ЗФ:' + AllTrim( tmp1->ZF )
    Endif
    k := perenos( tmp, s, w1 )
    If verify_ff( HH )
      header_uslugi( w1 )
    Endif
    If eq_any( Left( tmp1->shifr, 5 ), '1.11.', '55.1.' )
      s := Left( date_8( tmp1->date_u1 ), 2 ) + '-' + Left( date_8( tmp1->date_u2 ), 5 ) + ' '
    Else
      s := date_8( tmp1->date_u1 ) + ' '
    Endif
    If tmp1->is_edit == 1
      s += 'КДП№2 '
    Elseif tmp1->is_edit == 2
      s += ' РДЛ  '
    Elseif tmp1->is_edit == 4
      s += 'ПАбюро'
    Elseif tmp1->is_edit == 5
      s += 'ПАпроч'
    Elseif tmp1->is_edit == -1
      s += 'ЦКДЛ  '
    Elseif AllTrim( tmp1->shifr ) == '4.20.2' .or. tmp1->is_edit == 3
      s += 'ВОКОД '
    Else
      s += tmp1->otd + ' '
    Endif
    If Empty( diagVspom )
      s += tmp1->kod_diag + ' '
    Else
      s += diagMemory + ' '
    Endif
    s += PadR( tmp[ 1 ], w1 )
    s += put_val( ret_tabn( tmp1->kod_vr ), 6 ) + put_val( ret_tabn( tmp1->kod_as ), 6 )
    If tmp1->plus
      s += PadL( ' + ' + lstr( tmp1->kol ), 4 )
      mpsumma += tmp1->summa
    Else
      If tmp1->summa >= 100000
        s += ' ' + PadR( lstr( tmp1->kol ), 3 )
      Else
        s += put_val( tmp1->kol, 4 )
      Endif
      msumma += tmp1->summa
    Endif
    s += put_kope( tmp1->summa, 9 )
    //
    // if eq_any(human->ishod, 401, 402 ) .and. tmp1->kod_vr == 0
    If is_sluch_dispanser_covid( human->ishod ) .and. tmp1->kod_vr == 0
      // УГЛУБЛЕННАЯ дисп-ия взрослого населения
    Else
      add_string( s )
      For i := 2 To k
        add_string( Space( 21 ) + PadL( RTrim( tmp[ i ] ), w1 ) )
      Next
    Endif
    //
    If tmp1->summa > 0 .and. is_ksg( tmp1->shifr )
      If Year( human->k_data ) > 2017
        s1 := ''
        If !Empty( human_2->pc1 )
          akslp := list2arr( human_2->pc1 )
          If Len( akslp ) > 0
            s1 += '(с учётом КСЛП='
            If Year( human->k_data ) >= 2021
              For i := 1 To Len( akslp )  // возможно несколько КСЛП для КСГ
                If lExistFilesTFOMS
                  arrKSLP := getinfokslp( human->k_data, akslp[ i ] )
                  s1 += AllTrim( Str( arrKSLP[ 1 ] ) ) + '. ' + arrKSLP[ 3 ] + ', коэф.=' + Str( arrKSLP[ 4 ], 4, 2 ) + ') '
                Else
                  //
                Endif
              Next
            Else
              len_akslp := Len( akslp ) / 2
              For i := 1 To len_akslp
                If lExistFilesTFOMS
                  arrKSLP := getinfokslp( human->k_data, akslp[ i * 2 -1 ] )
                  s1 += AllTrim( Str( arrKSLP[ 1 ] ) ) + '. ' + arrKSLP[ 3 ] + ', коэф.=' + Str( arrKSLP[ 4 ], 4, 2 ) + ') '
                Else
                  //
                Endif
              Next
            Endif
            k_kslp := perenos( tmp_kslp, s1, w1 )
          Endif
        Endif
        If !Empty( human_2->pc2 )
          s1 := ''
          akiro := list2arr( human_2->pc2 )
          If Len( akiro ) > 1
            s1 += '(с учётом КИРО='
            If lExistFilesTFOMS
              arrKIRO := getinfokiro( human->k_data, akiro[ 1 ] )
              s1 += AllTrim( Str( arrKIRO[ 1 ] ) ) + '. ' + arrKIRO[ 3 ] + ', коэф.=' + Str( arrKIRO[ 4 ], 4, 2 ) + ') '
            Else
              //
            Endif
            k_kiro := perenos( tmp_kiro, s1, w1 )
          Endif
        Endif
        If !Empty( tmp_kslp )
          For i := 1 To k_kslp
            If i == 1
              add_string( Space( 21 ) + tmp_kslp[ i ] )
            Else
              add_string( Space( 21 ) + PadL( RTrim( tmp_kslp[ i ] ), w1 ) )
            Endif
          Next
        Endif
        If !Empty( tmp_kiro )
          For i := 1 To k_kiro
            If i == 1
              add_string( Space( 21 ) + tmp_kiro[ i ] )
            Else
              add_string( Space( 21 ) + PadL( RTrim( tmp_kiro[ i ] ), w1 ) )
            Endif
          Next
        Endif
      Endif
    Endif
    Select TMP1
    tmp1->( dbSkip() )    // skip
  Enddo
  Zap
  Set Order To 1
  add_string( Replicate( '-', sh ) )
  s := 'Общая сумма лечения: ' + put_kop( human->cena_1, 12 )
  If mpsumma > 0
    s := AllTrim( s ) + ' (+ ' + lput_kop( mpsumma, .t. ) + ')'
  Endif
  add_string( PadL( s, sh ) )

  If f_is_oncology( 1 ) == 2 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    print_luch_onk( human->k_data, human->KOD_DIAG, sh )
  Else
    arrLekPreparat := collect_lek_pr( mkod ) // выберем лекарственные препараты
    If Len( arrLekPreparat ) != 0  // не пустой список лекарственных препаратов
      add_string( '' )
      add_string( Center( 'Л_Е_К_А_Р_С_Т_В_Е_Н_Н_Ы_Е   П_Р_Е_П_А_Р_А_Т_Ы', sh ) )
      header_lek_preparat( w1 )
      For Each row in arrLekPreparat
        If verify_ff( HH )
          header_lek_preparat( w1 )
        Endif
        s := ''
        cREGNUM := PadR( get_lek_pr_by_id( row[ 3 ] ), 30 )
        cUNITCODE := PadR( inieditspr( A__MENUVERT, get_ed_izm(), row[ 4 ] ), iif( mem_n_V034 == 0, 15, 30 ) )
        cMETHOD := PadR( inieditspr( A__MENUVERT, getmethodinj(), row[ 6 ] ), 30 )
        s := date_8( row[ 1 ] ) + ' '
        If Empty( cREGNUM )
          s += PadR( ret_schema_v032( row[ 8 ] ), 33 )
        Else
          s += PadR( cREGNUM, 33 ) + ' '
          s := s + Str( row[ 5 ], 6, 2 ) + ' ' ;
            + PadR( cUNITCODE, 7 ) + ' ' ;
            + PadR( cMETHOD, 15 ) + ' ' ;
            + Str( row[ 7 ], 6 )
        Endif
        add_string( s )
      Next
    Endif
  Endif

  arrImplantant := collect_implantant( mkod ) // выберем имплантант
  If ! Empty( arrImplantant )
    add_string( '' )
    add_string( Center( 'У_С_Т_А_Н_О_В_Л_Е_Н_Н_Ы_Е   И_М_П_Л_А_Н_Т_А_Н_Т_Ы', sh ) )
    header_implantant( w1 )
    For Each row in arrImplantant
      s := ''
      s := date_8( row[ 3 ] ) + ' '
      k := perenos( mas, inieditspr( A__MENUVERT, get_implantant(), row[ 4 ] ), 40, ' ,;' )
      s := s + PadR( mas[ 1 ], 40 ) + ' ' + PadR( row[ 5 ], 35 )
      add_string( s )
      If k > 1
        add_string( Space( 9 ) + PadL( AllTrim( mas[ 2 ] ), 40 ) )
      Endif
    Next
  Endif

  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( n_file, , , , .f., , , 5 )

  Return Nil

//
Function header_implantant( w1 )

  add_string( '────────┬────────────────────────────────────────┬──────────────────────────────' )
  add_string( '  Дата  │Наименование имплантанта                │Серийный номер' )
  add_string( '────────┴────────────────────────────────────────┴──────────────────────────────' )

  Return Nil

//
Function header_lek_preparat( w1 )

  add_string( '────────┬─────────────────────────────────┬──────┬───────┬───────────────┬──────' )
  add_string( '  Дата  │Наименование препарата или группы│Доз-ка│Единица│Способ введения│Кол-во' )
  add_string( '────────┴─────────────────────────────────┴──────┴───────┴───────────────┴──────' )

  Return Nil

// 27.01.25
Function header_lek_preparat_onko( w1 )

  add_string( '────────┬─────────────────────────────────┬───────┬───────┬─────────────┬─────────────' )
  add_string( '  Дата  │Наименование препарата или группы│Единица│Введено│Израсходовано│Стоимость ед.' )
  add_string( '────────┴─────────────────────────────────┴───────┴───────┴─────────────┴─────────────' )

  Return Nil

//
Function header_uslugi( w1 )

  add_string( '────────┬─────┬─────┬' + Replicate( '─', w1 )              + '┬─────┬─────┬───┬────────' )
  add_string( '  Дата  │ Отд.│МКБ10│' + PadC( 'Наименование услуги', w1 ) + '│ Врач│ Асс.│Кол│ Сумма  ' )
  add_string( '────────┴─────┴─────┴' + Replicate( '─', w1 )              + '┴─────┴─────┴───┴────────' )

  Return Nil

// 02.11.22 печать доп.заголовка, если это лист учёта диспансеризации/профилактики
Function print_l_uch_disp( sh )

  Local s := ''

  If eq_any( human->ishod, 101, 102 )
    s := 'диспансеризация детей-сирот ' + ;
      iif( ! Empty( human->ZA_SMO ), 'в стационаре', 'под опекой' ) + ;
      iif( human->ishod == 101, ' I этап', ' I и II этап' )
  Elseif eq_any( human->ishod, 201, 202, 203 )
    s := iif( human->ishod == 203, 'профилактика', 'диспансеризация' ) + ;
      ' опр.групп взрослого населения'
    If eq_any( human->ishod, 201, 202 )
      s += iif( human->ishod == 201, ' I', ' II' ) + ' этап'
    Endif
  Elseif eq_any( human->ishod, 204, 205 )
    s := 'диспансеризация опр.групп взрослого населения (1 раз в 2 года) ' + iif( human->ishod == 204, 'I', 'II' ) + ' этап'
  Elseif eq_any( human->ishod, 301, 302 )
    s := 'профилактика несовершеннолетних' + ;
      iif( human->ishod == 301, ' I этап', ' I и II этап' )
  Elseif eq_any( human->ishod, 303, 304 )
    s := 'предварительный осмотр несовершеннолетних' + ;
      iif( human->ishod == 303, ' I этап', ' I и II этап' )
  Elseif human->ishod == 305
    s := 'периодический осмотр несовершеннолетних'
  Endif
  If !Empty( s )
    add_string( '' )
    add_string( Center( ' [' + s + ']', sh ) )
  Endif

  Return Nil

// 02.09.25 добавка по онкологии к листу учёта
Function print_luch_onk( dk,  diag, sh )

  Local mm_DS1_T // := getN018()  // N018
  Local mm_usl_tip // := getN013()
  Local fname // := prefixFileRefName( dk ) + 'shema'

  Local mm_N014 // := getn014()
  Local mm_N015 // := getn015()
  Local mm_N016 // := getn016()
  Local mm_N017 // := getn017()

  Local mm_str1 := { '',  'Тип лечения',  'Цикл терапии',  'Тип терапии',  'Тип терапии',  '' }
  Local mm_shema_err := { { 'соблюдён', 0 }, { 'не соблюдён', 1 } }
  Local tstr
  Local _arr_sh // := ret_arr_shema( 1, dk )
  Local _arr_mt // := ret_arr_shema( 2, dk )
  Local _arr_fr // := ret_arr_shema( 3, dk )
  Local mm_shema_usl
  Local m1PR_CONS := 0, mDT_CONS
  Local arrLekPreparat, row, w1
  Local HH := 77
  Local m1usl_tip1, mm_usl_tip1, m1usl_tip2, mm_usl_tip2
  Local m1crit
  Local cREGNUM, cUNITCODE

  Local mm_N002
  Local mm_N003
  Local mm_N004
  Local mm_N005
  Local stage

  If f_is_oncology( 1 ) == 2 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )

    mm_DS1_T := getn018()  // N018
    mm_usl_tip := getn013()
    fname := prefixfilerefname( dk ) + 'shema'

    mm_N014 := getn014()
    mm_N015 := getn015()
    mm_N016 := getn016()
    mm_N017 := getn017()
    _arr_sh := ret_arr_shema( 1, dk )
    _arr_mt := ret_arr_shema( 2, dk )
    _arr_fr := ret_arr_shema( 3, dk )

    dbCreate( cur_dir() + 'tmp_onkle',  { ; // Сведения о применённых лекарственных препаратах
    { 'KOD',      'N',   7,  0 }, ; // код больного
    { 'REGNUM',   'C',   6,  0 }, ; // IDD лек.препарата N020
    { 'ID_ZAP',   'N',   6,  0 }, ; // IDD лек.препарата N021
    { 'CODE_SH',  'C',  20,  0 }, ; // код схемы лек.терапии V024
    { 'DATE_INJ', 'D',   8,  0 };  // дата введения лек.препарата
    } )
    Use ( cur_dir() + 'tmp_onkle' ) New Alias TMPLE
    r_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle',  'LE' ) // Сведения о применённых лекарственных препаратах
    find ( Str( human->kod, 7 ) )
    Do While le->kod == human->kod .and. !Eof()
      Select TMPLE
      Append Blank
      tmple->REGNUM   := le->REGNUM
      tmple->CODE_SH  := le->CODE_SH
      tmple->DATE_INJ := le->DATE_INJ
      Select LE
      Skip
    Enddo
    r_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco',  'CO' )
    find ( Str( human->kod, 7 ) )
    If Found()
      m1PR_CONS := co->pr_cons
      mDT_CONS := co->dt_cons
    Endif
    tmple->( dbCloseArea() )
    le->( dbCloseArea() )
    co->( dbCloseArea() )

    add_string( '  Онкология:' )
    r_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'ONKSL' ) // Сведения о случае лечения онкологического заболевания
    find ( Str( human->kod, 7 ) )

    mm_N002 := f_define_tnm( 2, diag, dk )
    stage := inieditspr( A__MENUVERT, mm_N002, onksl->STAD )
    mm_N003 := f_define_tnm( 3, diag, dk, stage )
    mm_N004 := f_define_tnm( 4, diag, dk, stage )
    mm_N005 := f_define_tnm( 5, diag, dk, stage )

    add_string( '   Повод обращения: ' + inieditspr( A__MENUVERT, mm_DS1_T, onksl->DS1_T ) )
    add_string( '   Стадия заболевания: ' + AllTrim( inieditspr( A__MENUVERT, mm_N002, onksl->STAD ) ) ;
      + ', Tumor: ' + AllTrim( inieditspr( A__MENUVERT, mm_N003, onksl->ONK_T ) ) ;
      + ', Nodus: ' + AllTrim( inieditspr( A__MENUVERT, mm_N004, onksl->ONK_N ) ) ;
      + ', Metastasis: ' + AllTrim( inieditspr( A__MENUVERT, mm_N005, onksl->ONK_M ) ) )
    add_string( '   Наличие отдаленных метастазов (при рецидиве или прогрессировании): ' + AllTrim( inieditspr( A__MENUVERT, mm_danet(), onksl->MTSTZ ) ) )
    add_string( '' )
    tstr := Space( 3 ) + 'Консилиум: ' + inieditspr( A__MENUVERT, getn019(), m1PR_CONS )
    If m1PR_CONS != 0
      tstr += ' дата ' + DToC( mDT_CONS )
    Endif
    add_string( tstr )
    add_string( '' )

    add_string( Space( 3 ) + 'Гистология / иммуногистохимия: ' + ;
      inieditspr( A__MENUVERT, mmb_diag(), onksl->b_diag ) )

    add_string( '' )
    r_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus', 'ONKUS' )
    find ( Str( human->kod, 7 ) )
    Do While onkus->kod == human->kod .and. !Eof()
      If Between( onkus->USL_TIP, 1, 6 )
        add_string( '   Проведённое лечение: ' + inieditspr( A__MENUVERT, mm_usl_tip, onkus->USL_TIP ) )
        If eq_any( onkus->USL_TIP, 2, 4 ) .and. !Empty( onksl->crit )
          add_string( '    Схема: ' + AllTrim( onksl->crit ) + ' ' + inieditspr( A__POPUPEDIT, dir_exe() + fname, onksl->crit ) )
        Endif
        If eq_any( onkus->USL_TIP, 3, 4 )
          add_string( '    Количество фракций: ' + lstr( onksl->k_fr ) )
        Endif
      Endif
      If ONKUS->USL_TIP == 1
        m1usl_tip1 := ONKUS->HIR_TIP
        mm_usl_tip1 := mm_N014
      Elseif ONKUS->USL_TIP == 2
        m1usl_tip1 := ONKUS->LEK_TIP_V
        mm_usl_tip1 := mm_N016
        m1usl_tip2 := ONKUS->LEK_TIP_L
        mm_usl_tip2 := mm_N015
      Elseif eq_any( ONKUS->USL_TIP, 3, 4 )
        m1usl_tip1 := ONKUS->LUCH_TIP
        mm_usl_tip1 := mm_N017
      Endif

      m1crit := onksl->crit

      If Between( ONKUS->USL_TIP, 1, 4 )
        add_string( Space( 3 ) + PadR( mm_str1[ ONKUS->USL_TIP + 1 ], 12 ) + ': ' + ;
          inieditspr( A__MENUVERT, mm_usl_tip1, m1usl_tip1 ) )
        If ONKUS->USL_TIP == 2
          add_string( Space( 3 ) + 'Линия терапии: ' + ;
            inieditspr( A__MENUVERT, mm_usl_tip2, m1usl_tip2 ) )
          add_string( Space( 3 ) + ret_str_onc( 6, 1 ) + ': ' + ;
            inieditspr( A__MENUVERT, mm_shema_err, onksl->is_err ) )
        Endif
        If eq_any( ONKUS->USL_TIP, 2, 4 )
          tstr := ret_str_onc( 3, 1 ) + ' ' + AllTrim( str_0( onksl->WEI, 5, 1 ) ) + ','
          tstr += ' ' + ret_str_onc( 4, 1 ) + ' ' + lstr( onksl->HEI ) + ','
          tstr += ' ' + ret_str_onc( 5, 1 ) + ' ' +  AllTrim( str_0( onksl->BSA, 4, 2 ) )
          add_string( Space( 3 ) + tstr )
          If Left( m1crit, 2 ) == 'mt' .and. ONKUS->USL_TIP == 2
            m1crit := Space( 10 )
          Elseif eq_any( Left( m1crit, 2 ),  'не',  'sh' ) .and. ONKUS->USL_TIP == 4
            m1crit := Space( 10 )
          Endif
          If !Empty( human_2->PC3 ) .and. Left( Lower( human_2->PC3 ), 5 ) == 'gemop' // после разговора с Л.Н.Антоновой 13.01.23
            mm_shema_usl := f_valid2ad_cr( dk )  // mm_ad_cr
            m1crit := AllTrim( human_2->PC3 )
          Else
            mm_shema_usl := iif( ONKUS->USL_TIP == 2, _arr_sh, _arr_mt )
          Endif
          add_string( Space( 3 ) + ret_str_onc( 7, 1 ) + ': ' + inieditspr( A__MENUVERT, mm_shema_usl, m1crit ) )
          add_string( Space( 3 ) + ret_str_onc( 8, 1 ) + ': ' + init_lek_pr() )
          add_string( Space( 3 ) + ret_str_onc( 9, 1 ) + ': ' + ;
            inieditspr( A__MENUVERT, mm_danet(), ONKUS->pptr ) )
        Endif
      Endif
      Select ONKUS
      Skip
    Enddo
    add_string( '' )
    ONKUS->( dbCloseArea() )
    ONKSL->( dbCloseArea() )

    w1 := 34
    arrLekPreparat := collect_lek_pr_onko( human->kod ) // выберем лекарственные препараты
    If Len( arrLekPreparat ) != 0  // не пустой список лекарственных препаратов
      add_string( '' )
      add_string( Center( 'Л_Е_К_А_Р_С_Т_В_Е_Н_Н_Ы_Е   П_Р_Е_П_А_Р_А_Т_Ы', sh ) )
      header_lek_preparat_onko( w1 )
      For Each row in arrLekPreparat
        If verify_ff( HH )
          header_lek_preparat_onko( w1 )
        Endif
        tstr := ''
        cREGNUM := PadR( get_lek_pr_by_id( row[ 3 ] ), 30 )
        cUNITCODE := PadR( inieditspr( A__MENUVERT, get_ed_izm(), row[ 2 ] ), iif( mem_n_V034 == 0, 15, 30 ) )
        tstr := date_8( row[ 1 ] ) + ' '
        If Empty( cREGNUM )
          tstr += PadR( ret_schema_v032( row[ 8 ] ), 33 )
        Else
          tstr += PadR( cREGNUM, 33 ) + ' '
          tstr += + PadR( cUNITCODE, 7 ) + ' ' ;
            + Str( row[ 4 ], 8, 3 ) + ' ' ;
            + Str( row[ 5 ], 8, 3 ) + ' ' ;
            + Str( row[ 6 ], 15, 6 )
        Endif
        add_string( tstr )
      Next
    Endif
  Endif

  Return Nil

// 29.10.22 просмотр/печать листов учёта
Function o_list_uch()

  Local j := 0, buf := SaveScreen(), mtitul, func_step := '', r2 := MaxRow() -2

  If polikl1_kart() > 0
    mywait()
    If yes_parol
      func_step := 'f3o_list_uch'
    Endif
    Private blk_open := {|| iif( yes_parol, r_use( dir_server() + 'base1', , 'BASE1' ), nil ), ;
      r_use( dir_server() + 'mo_otd', , 'OTD' ), ;
      r_use( dir_server() + 'mo_rees', , 'REES' ), ;
      r_use( dir_server() + 'schet_', , 'SCHET_' ), ;
      r_use( dir_server() + 'schet', , 'SCHET' ), ;
      dbSetRelation( 'SCHET_', {|| RecNo() }, 'recno()' ), ;
      r_use( dir_server() + 'human_2', , 'HUMAN_2' ), ;
      r_use( dir_server() + 'human_', , 'HUMAN_' ), ;
      r_use( dir_server() + 'human', , 'HUMAN' ), ;
      dbSetRelation( 'HUMAN_2', {|| RecNo() }, 'recno()' ), ;
      dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
      dbSetRelation( 'OTD', {|| otd }, 'otd' ), ;
      dbSetRelation( 'SCHET', {|| schet }, 'schet' ) }
    Eval( blk_open )
    Set Index to ( dir_server() + 'humankk' )
    find ( Str( glob_kartotek, 7 ) )
    If Found()
      mtitul := AllTrim( fio )
      Index On DToS( FIELD->k_data ) + DToS( FIELD->n_data ) to ( cur_dir() + 'tmp_olu' ) While FIELD->kod_k == glob_kartotek descending
      dbEval( {|| ++j } )
      Go Top
      If yes_parol
        r2 := MaxRow() -6
        box_shadow( MaxRow() -4, 2, MaxRow() -2, 77, color5 )
      Endif
      If j > 0
        alpha_browse( T_ROW, 2, r2, 77, 'f1o_list_uch', color5, ;
          mtitul, 'B/W', , .t., , func_step, 'f4o_list_uch', , ;
          { '═', '░', '═', 'N/W,W+/N,' + ;
          'B/W,W+/B,' + ;
          'R/W,W+/R,' + ;
          'RB/W,W+/RB,' + ;
          'GR/W,W+/GR,' + ;
          'BG+/W,W+/BG', .t. } )
      Endif
    Else
      func_error( 4, 'В базе данных нет листов учета на выбранного человека!' )
    Endif
    Close databases
  Endif
  RestScreen( buf )

  Return Nil

// 02.11.11
Function f1o_list_uch( oBrow )

  Local oColumn, blk := {| _i| _i := iif( Between( human->tip_h, 1, 6 ), human->tip_h, 2 ), ;
    { { 1, 2 }, { 3, 4 }, { 5, 6 }, { 7, 8 }, { 9, 10 }, { 11, 12 } }[ _i ] }

  //
  oColumn := TBColumnNew( ' Начало; лечения', {|| date_8( human->n_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Окончание; лечения', {|| date_8( human->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( ' Отд.', {|| otd->short_name } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( '  Стоимость;   лечения', ;
    {|| PadL( expand_value( human->cena_1, 2 ), 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Примечание', {|| PadR( f2o_list_uch( human->tip_h ), 33 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход ^<Enter>^ печать л/у ^<F9>^ печать свода л/у ^<F10>^ печать справки ОМС' )

  Return Nil

//
Function f2o_list_uch( k )

  Static arr := { 'лечится', ;
    'не закончено лечение', ;
    'закончено лечение', ;
    '', ;
    '', ;
    '' }

  Local s

  k := iif( Between( k, 1, 6 ), k, 4 )
  s := arr[ k ]
  If k == B_STANDART .and. human_->reestr > 0
    rees->( dbGoto( human_->reestr ) )
    s := 'реестр № ' + lstr( rees->nschet ) + ' от ' + date_8( rees->dschet )
  Endif
  If k >= B_SCHET  // добавление номера счета
    s := 'счёт № ' + AllTrim( schet_->nschet ) + ' от ' + date_8( schet_->dschet )
  Endif

  Return s

// 12.05.2019
Function f3o_list_uch()

  Local s := 'Добавление ' + date_8( c4tod( human->date_e ) ) + 'г. '

  If Asc( human->kod_p ) > 0
    Select BASE1
    Goto ( Asc( human->kod_p ) )
    If !Eof() .and. !Empty( base1->p1 )
      s += AllTrim( Crypt( base1->p1, gpasskod ) ) + ' '
    Endif
  Elseif human_2->PN3 > 0
    s += 'ИМПОРТ '
  Endif
  If !Empty( human_->DATE_E2 )
    s := AllTrim( s ) + ', '
    s += 'исправление ' + date_8( c4tod( human_->DATE_E2 ) ) + 'г. '
    If Asc( human_->kod_p2 ) > 0
      Select BASE1
      Goto ( Asc( human_->kod_p2 ) )
      If !Eof() .and. !Empty( base1->p1 )
        s += AllTrim( Crypt( base1->p1, gpasskod ) )
      Endif
    Endif
  Endif
  @ MaxRow() -3, 3 Say PadC( s, 74 ) Color 'B/W'
  Select HUMAN

  Return Nil

// 31.10.22
Function f4o_list_uch( nKey, oBrow )

  Local buf, rec, k := -1, fl := .f., arr_m, arr_rec := {}

  rec := human->( RecNo() )
  If eq_any( nkey, K_ENTER, K_F10 )
    fl := .t.
    glob_perso := human->kod
  Elseif nkey == K_F9
    buf := SaveScreen()
    change_attr()
    If ( arr_m := year_month() ) != NIL
      Go Top
      dbEval( {|| AAdd( arr_rec, { human->k_data, human->( RecNo() ) } ) }, ;
        {|| Between( human->k_data, arr_m[ 5 ], arr_m[ 6 ] ) } )
      If Len( arr_rec ) > 0
        fl := .t.
        ASort( arr_rec, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      Else
        Goto ( rec )
        func_error( 4, 'Не найдено листов учета по данному больному в требуемом диапазоне времени!' )
      Endif
    Endif
    RestScreen( buf )
  Endif
  If fl
    Close databases
    If nkey == K_ENTER
      print_l_uch( glob_perso )
    Elseif nkey == K_F9
      print_al_uch( arr_rec, arr_m )
    Elseif nkey == K_F10
      print_spravka_oms( glob_perso )
    Endif
    Eval( blk_open )
    Set Index to ( cur_dir() + 'tmp_olu' )
    Goto ( rec )
  Endif

  Return k

// 27.11.14
Function create_fr_file_for_spravkaoms()

  dbCloseAll()
  delfrfiles()
  dbCreate( fr_titl, { { 'name', 'C', 255, 0 }, ;
    { 'adres', 'C', 255, 0 }, ;
    { 'data', 'D', 8, 0 }, ;
    { 'data1', 'D', 8, 0 }, ;
    { 'data2', 'D', 8, 0 }, ;
    { 'fio', 'C', 60, 0 } } )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_FULL_NAME ]
  frt->adres := glob_mo[ _MO_ADRES ]
  dbCreate( fr_data, { { 'name', 'C', 255, 0 }, ;
    { 'name1', 'C', 55, 0 }, ;
    { 'shifr', 'C', 10, 0 }, ;
    { 'kol', 'N', 4, 0 }, ;
    { 'cena', 'N', 11, 2 }, ;
    { 'summa', 'N', 11, 2 } } )
  Use ( fr_data ) New Alias FRD
  Index On FIELD->shifr to ( cur_dir() + 'tmp1' )

  Return Nil

// 15.12.23 печать справки ОМС по готовому листу учёта
Function print_spravka_oms( mkod )

  // mkod - код больного по БД human
  Local r1, c1, r2, c2, mdate, buf := save_maxrow(), msumma := 0, lshifr
  Local tmpAlias
  Local lExistFilesTFOMS

  get_row_col_max( 18, 4, @r1, @c1, @r2, @c2 )
  If ( mdate := input_value( r1, c1, r2, c2, color1, ;
      'Введите дату выдачи справки о стоимости мед.помощи по ОМС', ;
      sys_date ) ) == NIL
    Return Nil
  Endif
  mywait()
  create_fr_file_for_spravkaoms()
  use_base( 'lusl' )
  use_base( 'luslf' )
  r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
    dir_server() + 'uslugi1s' }, 'USL1' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  Goto ( mkod )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Goto ( mkod )
  If mdate < human->k_data
    rest_box( buf )
    Close databases
    Return func_error( 4, 'Дата выдачи справки меньше даты окончания лечения!' )
  Endif
  tmpAlias := create_name_alias( 'LUSL',  Year( human->k_data ) )
  If ! ( lExistFilesTFOMS := check_files_tfoms( Year( human->k_data ) ) )  // проверим наличие справочников ТФОМС
    func_error( 4, 'Отсутствуют справочники ТФОМС за ' + Str( Year( human->k_data ), 4 ) + ' год.' )
  Endif

  frt->data := mdate
  frt->data1 := human->n_data
  frt->data2 := human->k_data
  frt->fio := human->fio
  Select HU
  find ( Str( mkod, 7 ) )
  Do While hu->kod == mkod .and. !Eof()
    If !emptyany( hu->kol_1, hu->stoim_1 )
      usl->( dbGoto( hu->u_kod ) )
      lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If lExistFilesTFOMS
        If is_usluga_tfoms( usl->shifr, lshifr, human->k_data )
          lshifr := iif( Empty( lshifr ), usl->shifr, lshifr )
          Select LUSL
          find ( PadR( lshifr, 10 ) )
          Select FRD
          find ( PadR( lshifr, 10 ) )
          If !Found()
            Append Blank
            frd->shifr := lshifr
            frd->name := lusl->name  // наименование услуги из справочника ТФОМС
            frd->cena := hu->stoim_1 / hu->kol_1
          Endif
          frd->kol += hu->kol_1
          frd->summa += hu->stoim_1
          msumma += hu->stoim_1
        Endif
      Else
        lshifr := iif( Empty( lshifr ), usl->shifr, lshifr )
        Select FRD
        find ( PadR( lshifr, 10 ) )
        If !Found()
          Append Blank
          frd->shifr := lshifr
          frd->name := 'Отсутствуют справочники ТФОМС за ' + Str( Year( human->k_data ), 4 ) + ' год.'
          frd->cena := hu->stoim_1 / hu->kol_1
        Endif
        frd->kol += hu->kol_1
        frd->summa += hu->stoim_1
        msumma += hu->stoim_1
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Select FRD
  Go Top
  Do While !Eof()
    If frd->kol > 1
      frd->name1 := ' (в количестве ' + lstr( frd->kol ) + ')'
    Endif
    Skip
  Enddo
  Index On Str( FIELD->summa, 11, 2 ) to ( fr_data ) descending
  g_use( dir_server() + 'mo_sprav', , 'SPR_OMS' )
  Locate For kod_h == mkod
  If Found()
    g_rlock( forever )
  Else
    Append Blank
    spr_oms->KOD_H  := mkod
    spr_oms->KOD_K  := 0
  Endif
  spr_oms->FIO    := human->FIO
  spr_oms->DATE_R := human->DATE_R
  spr_oms->DATA   := mdate
  spr_oms->N_DATA := human->n_data
  spr_oms->K_DATA := human->k_data
  If human_->USL_OK == USL_OK_HOSPITAL
    spr_oms->TIP := 2  // стационар
  Elseif human_->USL_OK == USL_OK_DAY_HOSPITAL
    spr_oms->TIP := 3  // дневной стационар
  Else
    spr_oms->TIP := 1  // амбулаторно
  Endif
  spr_oms->STOIM  := human->CENA_1
  Close databases
  rest_box( buf )
  call_fr( 'mo_spravkaOMS' )

  Return Nil

// 27.11.14 Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС')
Function f_spravka_oms()

  Local i, j, k, k1, buf := SaveScreen(), rec_spr_oms := 0

  k1 := polikl1_kart()
  Close databases // если вдруг вышли по <Esc>
  //
  Private mfio := Space( 50 ), mdate_r := CToD( '' ), ;
    mdate := sys_date, mn_data := sys_date, mk_data := sys_date, ;
    mstoim := 0, m1usl := 1, musl := ' ', parr_usl := {}, ;
    p_box_buf, gl_area := { 1, 0, 23, 79, 0 }

  If k1 > 0
    r_use( dir_server() + 'kartotek', , 'KART' )
    Goto ( glob_kartotek )
    mfio    := kart->fio
    mdate_r := kart->date_r
    Close databases
  Endif
  Private r1 := MaxRow() -18
  Do While .t.
    SetColor( cDataCGet )
    clrlines( r1, MaxRow() -1 )
    @ r1 -1, 0 Say PadC( 'Справка ОМС', 80 ) Color 'B/B*'
    If p_box_buf != NIL
      rest_box( p_box_buf )
    Endif
    i := r1 + 1
    If k1 == 0
      @ i, 1 Say 'Пациент' Get mfio Pict '@!'
      @ Row(), Col() + 2 Say 'Дата р.' Get mdate_r
    Else
      @ i, 1 Say 'Пациент' Color 'G+/B' Get mfio When .f.
      @ Row(), Col() + 2 Say 'Дата р.' Color 'G+/B' Get mdate_r When .f.
    Endif
    @ ++i, 1 Say 'Сроки лечения: с' Get mn_data
    @ Row(), Col() + 1 Say 'по' Get mk_data
    @ Row(), Col() + 7 Say 'Дата выдачи справки' Get mdate ;
      valid {|| __Keyboard( Chr( K_ENTER ) ), .t. }
    @ ++i, 1 Say 'Оказанные услуги:' Color color8 Get musl ;
      reader {| x| menu_reader( x, { {| k, r, c| fu_spravka_oms( r, c ) } }, A__FUNCTION,,, .f. ) }
    status_key( '^<Esc>^ - выход для печати' )
    myread()
    Do While ( k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
        { ' Выход ', ' Печать справки ', ' Возврат в редактирование ' }, ;
        2, 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' ) ) == 0
    Enddo
    If k == 1
      Exit
    Elseif k == 2
      If Empty( mfio )
        func_error( 4, 'Не введены Ф.И.О.' )
        Loop
      Endif
      If Empty( mdate )
        func_error( 4, 'Не введена дата выдачи справки.' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, 'Не введена дата начала лечения.' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, 'Не введена дата окончания лечения.' )
        Loop
      Endif
      If mdate < mk_data
        func_error( 4, 'Дата выдачи справки меньше даты окончания лечения.' )
        Loop
      Endif
      If mk_data < mn_data
        func_error( 4, 'Дата окончания лечения меньше даты начала лечения.' )
        Loop
      Endif
      mstoim := 0 ; mtip := 2 // стационар
      For i := 1 To Len( parr_usl )
        mstoim += parr_usl[ i, 2 ] * parr_usl[ i, 3 ]
        If Left( parr_usl[ i, 5 ], 3 ) == '55.'
          mtip := 3  // дневной стационар
          Exit
        Elseif Left( parr_usl[ i, 5 ], 2 ) == '2.' .or. eq_any( Left( parr_usl[ i, 5 ], 3 ), '57.', '60.', '70.', '72.' )
          mtip := 1  // амбулаторно
          Exit
        Endif
      Next
      If Empty( mstoim )
        func_error( 4, 'Не введены услуги.' )
        Loop
      Endif
      create_fr_file_for_spravkaoms()
      use_base( 'lusl' )
      frt->data := mdate
      frt->data1 := mn_data
      frt->data2 := mk_data
      frt->fio := mfio
      For i := 1 To Len( parr_usl )
        If !emptyany( parr_usl[ i, 2 ], parr_usl[ i, 3 ] )
          Select LUSL
          find ( PadR( parr_usl[ i, 5 ], 10 ) )
          Select FRD
          find ( PadR( parr_usl[ i, 5 ], 10 ) )
          If !Found()
            Append Blank
            frd->shifr := parr_usl[ i, 5 ]
            frd->name := lusl->name  // наименование услуги из справочника ТФОМС
            frd->cena := parr_usl[ i, 3 ]
          Endif
          frd->kol += parr_usl[ i, 2 ]
          frd->summa += parr_usl[ i, 2 ] * parr_usl[ i, 3 ]
        Endif
      Next
      Select FRD
      Go Top
      Do While !Eof()
        If frd->kol > 1
          frd->name1 := ' (в количестве ' + lstr( frd->kol ) + ')'
        Endif
        Skip
      Enddo
      Index On Str( FIELD->summa, 11, 2 ) to ( fr_data ) descending
      g_use( dir_server() + 'mo_sprav', , 'SPR_OMS' )
      If rec_spr_oms == 0
        Append Blank
        spr_oms->KOD_H  := 0
        spr_oms->KOD_K  := iif( k1 > 0, glob_kartotek, 0 )
        rec_spr_oms := RecNo()
      Else
        Goto ( rec_spr_oms )
        g_rlock( forever )
      Endif
      spr_oms->FIO    := mFIO
      spr_oms->DATE_R := mDATE_R
      spr_oms->DATA   := mdate
      spr_oms->N_DATA := mn_data
      spr_oms->K_DATA := mk_data
      spr_oms->TIP    := mtip
      spr_oms->STOIM  := mstoim
      Close databases
      call_fr( 'mo_spravkaOMS' )
    Endif
  Enddo
  RestScreen( buf )

  Return Nil

// 27.11.14
Function fu_spravka_oms( r, c )

  Local arr_title := { { 1, ' Шифр усл.' }, ;
    { 2, 'Кол' }, ;
    { 3, '   Цена   ' }, ;
    { 4, ' Наименование услуги' } }
  Local mpic := {, { 3, 0 }, { 10, 2 } }, tmp_color := SetColor( 'W+/B, W+/RB' ), i
  Local blk := {| b, ar, nDim, nElem, nKey| fu2spravka_oms( b, ar, nDim, nElem, nKey ) }

  If emptyany( mdate_r, mn_data, mk_data )
    func_error( 4, 'Проверьте правильность ввода даты рождения и сроков лечения' )
  Else
    @ r, c Say Space( 10 ) Color 'B/B'
    Private mvzros_reb := iif( count_years( mdate_r, mn_data ) < 18, 1, 0 )
    If Len( parr_usl ) == 0
      AAdd( parr_usl, { Space( 10 ), 1, 0, Space( 40 ), '' } )
    Endif
    use_base( 'lusl' )
    use_base( 'luslc' )
    r_use( dir_server() + 'uslugi', dir_server() + 'uslugish', 'USL' )
    arrn_browse( r + 1, 2, MaxRow() -2, 77, parr_usl, arr_title, 1, , , , , .t., , mpic, blk, { .t., .t., .t. } )
    p_box_buf := save_box( r + 1, 0, MaxRow() -1, 79 )
    Close databases
  Endif
  SetColor( tmp_color )

  Return { 1, ' ' }

// 27.11.14
Function fu2spravka_oms( b, ar, nDim, nElem, nKey )

  Local nRow := Row(), nCol := Col(), i, j, flag := .f., fl, lshifr, lshifr1

  Do Case
  Case nKey == K_DOWN .or. nKey == K_INS
    b:panhome()
  Case nKey == K_LEFT
    b:Left()
  Case nKey == K_RIGHT
    If nDim == 1
      b:Right()
    Endif
  Otherwise
    If ( nKey == K_ENTER .or. Between( nKey, 48, 57 ) ) .and. nDim < 3
      If nDim == 1 .and. Empty( parr[ nElem, nDim ] )
        If Between( nKey, 48, 57 )
          Keyboard Chr( nKey )
        Endif
        Private mshifr := Space( 10 )
        @ nRow, nCol Get mshifr Picture '@!' Valid valid_shifr()
        myread()
        If LastKey() != K_ESC
          lshifr := mname := ''
          Select USL
          find ( mshifr )
          If Found()
            mname := usl->name
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, mk_data )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
            Else
              func_error( 4, 'Это не услуга ТФОМС: ' + lshifr1 )
            Endif
          Else
            Select LUSL
            find ( mshifr )
            If Found()
              lshifr := lusl->shifr
              mname := lusl->name
            Else
              func_error( 4, 'Это не услуга ТФОМС: ' + mshifr )
            Endif
          Endif
          If !Empty( lshifr )
            fl_del := fl_uslc := .f.
            glob_podr := ''
            glob_otd_dep := 0
            v := fcena_oms( lshifr, ;
              ( mvzros_reb == 0 ), ;
              mk_data, ;
              @fl_del, ;
              @fl_uslc )
            If fl_uslc  // если нашли в справочнике ТФОМС
              If fl_del
                func_error( 4, 'Цена на услугу ' + RTrim( lshifr ) + ' отсутствует в справочнике ТФОМС' )
              Else
                fl := .t.
                parr[ nElem, 1 ] := mshifr
                If Empty( parr[ nElem, 2 ] )
                  parr[ nElem, 2 ] := 1
                Endif
                parr[ nElem, 3 ] := v
                parr[ nElem, 4 ] := Left( mname, 40 )
                parr[ nElem, 5 ] := lshifr
                b:Right()
                b:refreshall() ; flag := .t.
              Endif
            Else
              func_error( 4, 'Не найдена услуга в справочнике ТФОМС: ' + lshifr )
            Endif
          Endif
        Endif
      Elseif nDim == 2
        If Between( nKey, 48, 57 )
          Keyboard Chr( nKey )
        Endif
        Private mkol := parr[ nElem, nDim ]
        @ nRow, nCol Get mkol Picture '999'
        myread()
        If LastKey() != K_ESC .and. mkol >= 0
          parr[ nElem, 2 ] := mkol
          flag := .t.
        Endif
      Endif
    Else
      Keyboard ''
    Endif
  Endcase
  @ nRow, nCol Say ''

  Return flag

// 27.11.14 Отчёт о количестве выданных справок ОМС
Function f_otchet_spravka_oms()

  Local arr_m, buf := save_maxrow(), as := { 0, 0, 0 }, sh := 80, HH := 80, ;
    i, n_file := cur_dir() + 'o_sprOMS.txt'

  If ( arr_m := year_month() ) != NIL
    mywait()
    r_use( dir_server() + 'mo_sprav', , 'SPR_OMS' )
    Index On FIELD->Data to ( cur_dir() + 'tmp' ) For Between( FIELD->data, arr_m[ 5 ], arr_m[ 6 ] )
    Go Top
    Do While !Eof()
      i := 1
      If Between( spr_oms->TIP, 1, 3 )
        i := spr_oms->TIP
      Endif
      as[ i ] ++
      Skip
    Enddo
    Use
    fp := FCreate( n_file )
    n_list := 1
    tek_stroke := 0
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( PadL( 'Приложение 3', sh ) )
    add_string( PadL( 'к Приказу МЗВО и ТФОМС', sh ) )
    add_string( PadL( '№2841/758 от 29.10.2014г.', sh ) )
    add_string( '' )
    add_string( Center( 'Отчёт', sh ) )
    add_string( Center( 'О количестве справок о стоимости оказанной медицинской помощи в', sh ) )
    add_string( Center( 'сфере ОМС, выданных застрахованным лицам в медицинских организациях', sh ) )
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( '' )
    add_string( '────────────────────────────────────────────────────────────────────────────────' )
    add_string( '      Количество проинформированных пациентов с выдачей справок о стоимости     ' )
    add_string( '                      медицинской помощи в сфере ОМС                            ' )
    add_string( '──────────────────────────┬──────────────────────────┬──────────────────────────' )
    add_string( ' в амбулаторно-поликлини- │  в условиях стационара   │     в условиях дневного  ' )
    add_string( '     ческих условиях      │                          │         стационара       ' )
    add_string( '──────────────────────────┴──────────────────────────┴──────────────────────────' )
    add_string( '' )
    add_string( PadC( lstr( as[ 1 ] ), 26 ) + ' ' + PadC( lstr( as[ 2 ] ), 26 ) + ' ' + PadC( lstr( as[ 3 ] ), 26 ) )
    add_string( '' )
    add_string( '────────────────────────────────────────────────────────────────────────────────' )
    FClose( fp )
    rest_box( buf )
    viewtext( n_file, , , , .f., , , 2 )
  Endif

  Return Nil

// 12.09.25 печать нескольких листов учёта
Function print_al_uch( arr_h, arr_m )

  Local sh := 80, HH := 77, buf := save_maxrow(), ;
        mvzros_reb, mrab_nerab, ;
        mkomu, name_org, mlech_vr := '', msumma := 0, ;
        mud_lich := '', arr, n_file := cur_dir() + 'list_uch.txt', adiag_talon[ 16 ], ;
        i := 1, ii, j, k, tmp[ 2 ], tmp1, w1 := 65, s, mnum_lu, lshifr1
  local diagVspom := '', diagMemory := '' 
  
  mywait()
  fp := fcreate( n_file )
  tek_stroke := 0
  n_list := 1
  //
  R_Use( dir_server() + 'organiz' )
  name_org := center( alltrim( name ), sh )
  dbCloseAll()
  if !myFileDeleted( cur_dir() + 'tmp1' + sdbf() )
    return NIL
  endif
  dbcreate(cur_dir() + 'tmp1', {{'kod', 'N', 4, 0}, ;
                   {'name', 'C', 65, 0}, ;
                   {'shifr', 'C', 10, 0}, ;
                   {'dom', 'N', 1, 0}, ;
                   {'zf', 'C', 30, 0}, ;
                   {'kod_diag', 'C', 5, 0}, ;
                   {'date_u1', 'D', 8, 0}, ;
                   {'rec_hu', 'N', 8, 0}, ;
                   {'otd', 'C', 5, 0}, ;
                   {'plus', 'L', 1, 0}, ;
                   {'is_edit', 'N', 2, 0}, ;
                   {'kod_vr', 'N', 5, 0}, ;
                   {'kod_as', 'N', 5, 0}, ;
                   {'profil', 'N', 4, 0}, ;
                   {'kol', 'N', 4, 0}, ;
                   {'summa', 'N', 11, 2}})
  use (cur_dir() + 'tmp1')
  index on str( FIELD->kod, 4 ) to ( cur_dir() + 'tmp11' )
  index on dtos( FIELD->date_u1 ) + fsort_usl( FIELD->shifr ) to ( cur_dir() + 'tmp12' )
  dbCloseAll()
  //
  R_Use(dir_server() + 'human_', , 'HUMAN_')
  R_Use(dir_server() + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_
  goto (atail(arr_h)[2])
  mpolis := alltrim(rtrim(human_->SPOLIS) + ' ' +human_->NPOLIS) + ' (' + ;
            alltrim(inieditspr(A__MENUVERT, mm_vid_polis(), human_->VPOLIS)) + ')'
  R_Use(dir_server() + 'kartote_', , 'KART_')
  R_Use(dir_server() + 'kartotek', , 'KART')
  set relation to recno() into KART_
  goto (human->kod_k)
  madres := iif(emptyall(kart_->okatog, kart->adres), '', ;
                ret_okato_ulica(kart->adres, kart_->okatog))
  Private mvid_ud := kart_->vid_ud, ;
          mser    := kart_->ser_ud, ;
          mnom    := kart_->nom_ud
  if mvid_ud > 0
    mud_lich := get_Name_Vid_Ud(mvid_ud, , ': ')
    if !empty(mser)
      mud_lich += charone(' ',mser) + ' '
    endif
    if !empty(mnom)
      mud_lich += mnom + ' '
    endif
  endif
  //
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros(), human->vzros_reb)
  mrab_nerab := inieditspr(A__MENUVERT, menu_rab(), human->rab_nerab)
  mkomu := f4_view_list_schet(human->komu, cut_code_smo(human_->smo), human->str_crb)
  mnum_lu := alltrim(human->uch_doc)
  if yes_num_lu == 1
    mnum_lu += ' [' + lstr(human->kod) + ']'
  endif
  add_string(name_org)
  add_string('')
  add_string(center('Л_И_С_Ты  У_Ч_Е_Т_А', sh))
  add_string(center('М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  № ' + mnum_lu, sh))
  add_string(center(arr_m[4], sh))
  add_string('')
  add_string('  Ф.И.О.: ' + human->fio+ '          Пол: ' + human->pol)
  add_string('  Дата рождения: ' + full_date(human->date_r) + '  [ ' +mvzros_reb+ ' ]')
//  add_string('  СНИЛС: ' + transform(kart->SNILS, picture_pf))
  add_string( '  СНИЛС: ' + transform_SNILS( kart->SNILS ) )

  if !empty(mud_lich)
    k := perenos(tmp, mud_lich, sh-2)
    add_string('  ' + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  add_string('  Адрес: ' + madres)
  if !empty(kart->mr_dol)
    add_string('  Место работы/учебы: ' + human->mr_dol)
  endif
  add_string('  Статус пациента: ' + mrab_nerab)
  add_string('  Принадлежность счета: ' + mkomu)
  // add_string('  Полис: ' + mpolis)
  add_string('  Серия и номер страхового полиса: ' + mpolis)
  //
  // R_Use(dir_server() + 'mo_uch', , 'UCH')
  R_Use(dir_server() + 'mo_otd', , 'OTD')
  R_Use(dir_server() + 'uslugi', , 'USL')
  R_Use(dir_server() + 'mo_pers', , 'PERSO')
  R_Use(dir_server() + 'schet_', , 'SCHET_')
  R_Use(dir_server() + 'schet', , 'SCHET')
  set relation to recno() into SCHET_
  R_Use(dir_server() + 'human_u_', , 'HU_')
  R_Use(dir_server() + 'human_u', dir_server() + 'human_u', 'HU')
  set relation to recno() into HU_
  R_Use(dir_server() + 'mo_su', , 'MOSU')
  R_Use(dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU')
  use ( cur_dir() + 'tmp1' ) index ( cur_dir() + 'tmp11' ), ( cur_dir() + 'tmp12' ) new alias tmp1
  for ii := 1 to len(arr_h)
    select TMP1
    set order to 1
    zap
    select HUMAN
    goto (arr_h[ii, 2])
    if human->schet > 0
      schet->(dbGoto(human->schet))
    endif
    mlech_vr := ''
    if human_->vrach > 0
      select PERSO
      goto (human_->vrach)
      mlech_vr := alltrim(perso->fio)
    endif
    //
    afill(adiag_talon, 0)
    for j := 1 to 16
      adiag_talon[j] := int(val(substr(human_->DISPANS, j, 1)))
    next
    //
    verify_FF(HH - 5, .t., sh)
    print_l_uch_disp(sh)
    add_string('')
    add_string(padc(' Срок лечения с ' + full_date(human->n_data) + ' по ' + full_date(human->k_data) + ' ', sh, '─'))
    // uch->(dbGoto(human->lpu))
    otd->(dbGoto(human->otd))
    add_string('  Условия: ' + ;
      inieditspr(A__MENUVERT, getV006(), human_->USL_OK) + ', ' + ;
      alltrim(otd->name) + ' [' + alltrim(getUCH_Name(human->lpu)) + ']')
      // alltrim(otd->name) + ' [' + alltrim(uch->name) + ']')
    s := '  '
    if !empty(human_->KOD_DIAG0)
      s := padr('  Первичный диагноз: ' + human_->KOD_DIAG0, 40)
    endif
    if !empty(human_->STATUS_ST)
      s += 'Статус стом.больного: ' + alltrim(human_->STATUS_ST)
    endif
    if !empty(s)
      add_string(s)
    endif
    diagVspom := ''
    arr := diag_to_array( , .t., .t., .t., .t., adiag_talon)
    if len(arr) > 0
      if diagnosis_for_replacement(arr[1], human_->USL_OK)
        diagVspom := alltrim(arr[1])
        diagMemory := alltrim(arr[2])
      endif
      add_string('  Основной диагноз: ' + iif(empty(diagVspom), arr[1], arr[2] + ' (!!!вспомогательный диагноз ' + diagVspom + '!!!)'))
      if len(arr) > 1
        tmp1 := '  Сопутствующие диагнозы:'
        for j := iif(empty(diagVspom), 2, 3) to len(arr)
        // for j := 2 to len(arr)
          tmp1 += ' ' + arr[j]
        next
        add_string(tmp1)
      endif
    endif
    tmp1 := ''
  
    verify_FF(HH - 6, .t., sh)
    if human_->PROFIL > 0
      add_string('  Профиль: ' + inieditspr(A__MENUVERT, getV002(), human_->PROFIL))
    endif
    add_string('  Способ оплаты: ' + inieditspr(A__MENUVERT, getV010(), human_->IDSP))
    add_string('  Результат обращения: ' + inieditspr(A__MENUVERT, getV009(), human_->RSLT_NEW))
    add_string('  Исход заболевания: ' + inieditspr(A__MENUVERT, getV012(), human_->ISHOD_NEW))
    if !empty(mlech_vr)
      add_string('  Лечащий врач : ' + mlech_vr)
    endif
    if human->bolnich > 0
      add_string('  Временная нетрудоспособность (больничный) с ' +;
                 full_date(c4tod(human->date_b_1)) + ' по ' + full_date(c4tod(human->date_b_2)))
      add_string('')
    endif
    Select HU
    find (str(arr_h[ii, 2], 7))
    do while hu->kod == arr_h[ii, 2] .and. !eof()
      if !emptyall(hu->kol_1, hu->stoim_1)
        Select OTD
        goto (hu->otd)
        Select USL
        goto (hu->u_kod)
        lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
        select TMP1
        append blank
        tmp1->kod := usl->kod
        tmp1->name := usl->name
        tmp1->shifr := usl->shifr //iif(empty(lshifr1), usl->shifr, lshifr1)
        tmp1->date_u1 := c4tod(hu->date_u)
        tmp1->dom := iif(between(hu->kol_rcp, -2, -1), -hu->kol_rcp, 0)
        tmp1->rec_hu := hu->( recno() )
        tmp1->kod_diag := hu_->KOD_DIAG
        tmp1->otd := otd->short_name
        if check_files_TFOMS( year( human->k_data ) )
          if human->k_data < 0d20120301
            tmp1->plus := !f_paraklinika( usl->shifr, lshifr1, c4tod( hu->date_u ) )
          else
            tmp1->plus := !f_paraklinika( usl->shifr, lshifr1, human->k_data )
          endif
        endif
        tmp1->is_edit := hu->is_edit
        tmp1->kod_vr := hu->kod_vr
        tmp1->kod_as := hu->kod_as
        tmp1->profil := hu_->profil
        tmp1->kol += hu->kol_1
        tmp1->summa += hu->stoim_1
      endif
      select HU
      Skip
    enddo
    Select MOHU
    find ( str( arr_h[ ii, 2 ], 7 ) )
    do while mohu->kod == arr_h[ ii, 2 ] .and. !eof()
      if !empty( mohu->kol_1 )
        Select OTD
        goto ( mohu->otd )
        Select MOSU
        goto ( mohu->u_kod )
        select TMP1
        append blank
        tmp1->kod := mosu->kod
        tmp1->name := mosu->name
        tmp1->shifr := iif( empty( mosu->shifr ), mosu->shifr1, mosu->shifr )
        tmp1->date_u1 := c4tod( mohu->date_u )
        tmp1->rec_hu := mohu->( recno() )
        tmp1->kod_diag := mohu->KOD_DIAG
        if STisZF( human_->USL_OK, human_->PROFIL )
          tmp1->zf := mohu->ZF
        endif
        tmp1->otd := otd->short_name
        tmp1->plus := .f.
        tmp1->kod_vr := mohu->kod_vr
        tmp1->kod_as := mohu->kod_as
        tmp1->kol += mohu->kol_1
        tmp1->summa += mohu->stoim_1
      endif
      select MOHU
      Skip
    enddo
    mpsumma := 0
    verify_FF( HH - 4, .t., sh )
    w1 := 34
    header_uslugi( w1 )
    select TMP1
    set order TO 2
    go top
    do while !eof()
      s := alltrim( tmp1->shifr ) + iif( tmp1->dom == 1, '/на дому/', iif( tmp1->dom == 2, '/домАКТИВ/', ' ' ) ) + alltrim( tmp1->name )
      if eq_any( alltrim( tmp1->shifr ), '2.3.1', '2.3.3', '2.6.1', '2.60.1' )
        s += ' (' + alltrim( inieditspr( A__MENUVERT, getV002(), tmp1->PROFIL ) ) + ')'
      elseif !empty( tmp1->zf )
        s += ' ЗФ:' + alltrim( tmp1->ZF )
      endif
      k := perenos( tmp, s, w1 )
      if verify_FF( HH )
        header_uslugi( w1 )
      endif
      s := date_8( tmp1->date_u1 ) + ' '
      if tmp1->is_edit == 1
        s += 'КДП№2 '
      elseif tmp1->is_edit == 2
        s += ' РДЛ  '
      elseif tmp1->is_edit == 4
        s += 'ПАбюро'
      elseif tmp1->is_edit == 5
        s += 'ПАпроч'
      elseif tmp1->is_edit == -1
        s += 'ЦКДЛ  '
      elseif alltrim( tmp1->shifr ) == '4.20.2' .or. tmp1->is_edit == 3
        s += 'ВОКОД '
      else
        s += tmp1->otd+ ' '
      endif
      s += tmp1->kod_diag+ ' '
      s += padr( tmp[ 1 ], w1 )
      s += put_val( ret_tabn( tmp1->kod_vr ), 6 ) + ;
           put_val( ret_tabn( tmp1->kod_as ), 6 )
      if tmp1->plus
        s += padl( ' + ' + lstr( tmp1->kol ), 4 )
        mpsumma += tmp1->summa
      else
        s += put_val( tmp1->kol, 4 )
        msumma += tmp1->summa
      endif
      s += put_kopE( tmp1->summa, 9 )
      add_string( s )
      for i := 2 to k
        add_string( space( 21 ) + padl( rtrim( tmp[ i ] ), w1 ) )
      next
      select TMP1
      skip
    enddo
    add_string( padl( replicate( '-', 33 ), sh ) )
    s := 'Общая сумма лечения: ' + put_kop( human->cena_1, 12 )
    if mpsumma > 0
      s := alltrim( s ) + ' (+ ' + lput_kop( mpsumma, .t. ) + ')'
    endi
    add_string( padl( s, sh ) )
  next
  close databases
  fclose( fp )
  rest_box( buf )
  viewtext( n_file, , , , .f., , , 5 )
  return NIL
