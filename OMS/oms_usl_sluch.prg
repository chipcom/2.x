#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'


// * 02.04.22 ввод услуг в случай (лист учёта)
Function oms_usl_sluch( mkod_human, mkod_kartotek, fl_edit )

  // mkod_human - код по БД human
  // mkod_kartotek - код по БД kartotek
  Local adbf, buf := SaveScreen(), i, j := 0, tmp_color := SetColor( color1 ), rec_ksg := 0, ;
    lshifr := '', l_color, tmp_help, mtitle, d1, d2, cd1, cd2, fl_oms, fl, kol_rec, old_is_zf_stomat
  Local begin_row

  Default fl_edit To .t.
  //
  Private fl_edit_usl := fl_edit
  Private fl_found, last_date, mvu[ 3, 2 ], pr1otd, pr_amb_reab := .f., ;
    pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, is_1_vvod, ;
    kod_lech_vr := 0, is_open_u1 := .f., arr_uva := {}, arr_usl1year, u_other := {}
  Private arrImplant

  If hb_vfExists( cur_dir() + 'tmp_impl.dbf' )
    hb_vfErase( cur_dir() + 'tmp_impl.dbf' )
  Endif

  afillall( mvu, 0 )
  //
  Private tmp_V002 := create_classif_ffoms( 0, 'V002' ) // PROFIL
  //
  mywait()
  r_use( dir_server() + 'usl_uva',, 'OU' )
  dbEval( {|| AAdd( arr_uva, { AllTrim( ou->shifr ), ou->kod_vr, ou->kod_as } ) } )
  ou->( dbCloseArea() )
  use_base( 'lusl' )
  use_base( 'luslc' )
  use_base( 'luslf' )
  use_base( 'mo_su' )
  Set Order To 0
  g_use( dir_server() + 'uslugi', { dir_server() + 'uslugish', ;
    dir_server() + 'uslugi' }, 'USL' )
  Set Order To 0
  use_base( 'mo_hu' )
  use_base( 'human_u' )
  g_use( dir_server() + 'human_2',, 'HUMAN_2' )
  g_use( dir_server() + 'human_',, 'HUMAN_' )
  g_use( dir_server() + 'human', { dir_server() + 'humank', ;
    dir_server() + 'humankk', ;
    dir_server() + 'humano' }, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  find ( Str( mkod_human, 7 ) )
  arr_usl1year := f_arr_usl1()
  glob_kartotek := human->kod_k
  d1 := human->n_data ; d2 := human->k_data
  cd1 := dtoc4( d1 ) ; cd2 := dtoc4( d2 )
  last_date := human->n_data
  Private m1USL_OK := human_->USL_OK
  Private m1PROFIL := human_->PROFIL
  Private mdiagnoz := diag_to_array(,,,, .t. )
  If Len( mdiagnoz ) == 0
    mdiagnoz := { Space( 6 ) }
  Endif
  Private human_kod_diag := mdiagnoz[ 1 ]
  //
  make_arr_uch_otd( human->n_data, human->LPU )
  uch->( dbGoto( human->LPU ) )
  otd->( dbGoto( human->OTD ) )
  f_put_glob_podr( human_->USL_OK, d2 ) // заполнить код подразделения
  // просмотр других случаев данного больного
  Select HUMAN
  Set Order To 2
  find ( Str( glob_kartotek, 7 ) )
  Do While human->kod_k == glob_kartotek .and. !Eof()
    fl := ( mkod_human != human->kod )
    If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
      fl := .f. // лист учёта снят по акту и выставлен повторно
    Endif
    // если диапазон лечения частично перекрывается
    If fl .and. human->n_data <= d2 .and. d1 <= human->k_data
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        If Between( hu->date_u, cd1, cd2 ) // услуга в том же диапазоне лечения
          AAdd( u_other, { hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0 } )
        Endif
        Skip
      Enddo
      Select MOHU
      find ( Str( human->kod, 7 ) )
      Do While mohu->kod == human->kod .and. !Eof()
        If Between( mohu->date_u, cd1, cd2 ) // услуга в том же диапазоне лечения
          AAdd( u_other, { mohu->u_kod, mohu->date_u, mohu->kol_1, mohu->profil, 1 } )
        Endif
        Skip
      Enddo
    Endif
    Select HUMAN
    Skip
  Enddo
  //

  //
  adbf := { ;
    { 'KOD',   'N',     7,     0 }, ; // код больного в HUMAN.dbf
    { 'DATE_U',   'C',     4,     0 }, ; // дата оказания услуги
  { 'date_u2',   'C',     4,     0 }, ; // дата окончания оказания услуги
  { 'date_u1',   'D',     8,     0 }, ;
    { 'date_end',   'D',     8,     0 }, ; // дата окончания выполнения многоразовой услуги
  { 'date_next',   'D',     8,     0 }, ; // дата след.визита для дисп.наблюдения
  { 'shifr_u',   'C',    20,     0 }, ;
    { 'shifr1',   'C',    20,     0 }, ;
    { 'name_u',   'C',    65,     0 }, ;
    { 'U_KOD',   'N',     6,     0 }, ; // код услуги
  { 'U_CENA',   'N',    10,     2 }, ; // цена услуги
  { 'dom',   'N',     2,     0 }, ; // -1 - на дому
  { 'KOD_VR',   'N',     4,     0 }, ; // код врача
  { 'KOD_AS',   'N',     4,     0 }, ; // код ассистента
  { 'OTD',   'N',     3,     0 }, ; // код отделения
  { 'KOL_1',   'N',     3,     0 }, ; // оплачиваемое количество услуг
    { 'STOIM_1',   'N',    10,     2 }, ; // оплачиваемая стоимость услуги
  { 'ZF',   'C',    30,     0 }, ; // зубная формула или парные органы
  { 'PAR_ORG',   'C',    40,     0 }, ; // разрешённые парные органы
  { 'ID_U',   'C',    36,     0 }, ; // код записи об оказанной услуге;GUID оказанной услуги;создается при добавлении записи
    { 'PROFIL',   'N',     3,     0 }, ; // профиль;по справочнику V002
  { 'PRVS',   'N',     9,     0 }, ; // Специальность врача;по справочнику V004;
    { 'kod_diag',   'C',     6,     0 }, ; // диагноз;перенести из основного диагноза
  { 'n_base',   'N',     1,     0 }, ; // номер справочника услуг 0-старый,1-новый
  { 'is_nul',   'L',     1,     0 }, ;
    { 'is_oms',   'L',     1,     0 }, ;
    { 'is_zf',   'N',     1,     0 }, ;
    { 'is_edit',   'N',     2,     0 }, ;
    { 'number',   'N',     3,     0 }, ;
    { 'rec_hu',   'N',     8,     0 } }
  dbCreate( cur_dir() + 'tmp_usl_', adbf )
  Use ( cur_dir() + 'tmp_usl_' ) New Alias TMP
  Select HUMAN
  Set Order To 1
  find ( Str( mkod_human, 7 ) )
  Select HU
  Set Relation To u_kod into USL Additive
  find ( Str( mkod_human, 7 ) )
  If Found()
    Do While hu->kod == mkod_human .and. !Eof()
      Select TMP
      Append Blank
      tmp->KOD     := hu->kod
      tmp->DATE_U  := hu->date_u
      tmp->date_u2 := hu_->date_u2
      tmp->date_end := hu_->date_end
      tmp->date_u1 := c4tod( hu->date_u )
      tmp->shifr_u := usl->shifr
      tmp->shifr1  := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If Empty( lshifr := tmp->shifr1 )
        lshifr := tmp->shifr_u
      Endif
      If human_->usl_ok == 3
        If is_usluga_disp_nabl( lshifr )
          tmp->DATE_NEXT := c4tod( human->DATE_OPL )
        Elseif Left( lshifr, 5 ) == '2.89.'
          pr_amb_reab := .t.
        Endif
      Endif
      tmp->name_u  := usl->name
      tmp->U_KOD   := hu->u_kod
      tmp->U_CENA  := hu->u_cena
      tmp->KOD_VR  := hu->kod_vr
      tmp->dom     := hu->KOL_RCP
      tmp->KOD_AS  := hu->kod_as
      tmp->OTD     := hu->otd
      tmp->KOL_1   := hu->kol_1
      tmp->STOIM_1 := hu->stoim_1
      tmp->ZF      := hu_->ZF
      tmp->ID_U    := hu_->ID_U
      tmp->PROFIL  := hu_->PROFIL
      tmp->PRVS    := hu_->PRVS
      tmp->kod_diag := hu_->kod_diag
      tmp->n_base  := 0
      tmp->is_edit := hu->is_edit
      tmp->is_nul  := usl->is_nul
      tmp->rec_hu  := hu->( RecNo() )
      last_date := Max( tmp->date_u1, last_date )
      If human_->usl_ok < 3 .and. is_ksg( lshifr ) // для КСГ цену не переопределяем - сделаем попозже
        rec_ksg := tmp->( RecNo() )
      Else
        fl_oms := .f.
        // переопределение цены
        If ( v := f1cena_oms( tmp->shifr_u, ;
            tmp->shifr1, ;
            ( human->vzros_reb == 0 ), ;
            human->k_data, ;
            tmp->is_nul, ;
            @fl_oms ) ) != NIL
          tmp->is_oms := fl_oms
          If !( Round( tmp->u_cena, 2 ) == Round( v, 2 ) )
            tmp->u_cena := v
            tmp->stoim_1 := round_5( tmp->u_cena * tmp->kol_1, 2 )
            Select HU
            g_rlock( forever )
            hu->u_cena := tmp->u_cena
            hu->stoim  := hu->stoim_1 := tmp->stoim_1
            Unlock
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    Commit
  Endif
  Select MOHU
  Set Relation To u_kod into MOSU
  find ( Str( mkod_human, 7 ) )
  If Found()
    Do While mohu->kod == mkod_human .and. !Eof()
      Select TMP
      Append Blank
      tmp->KOD     := mohu->kod
      tmp->DATE_U  := mohu->date_u
      tmp->date_u2 := mohu->date_u2
      tmp->date_u1 := c4tod( mohu->date_u )
      tmp->shifr_u := iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr )
      tmp->shifr1  := mosu->shifr1
      tmp->name_u  := mosu->name
      tmp->U_KOD   := mohu->u_kod
      tmp->U_CENA  := mohu->u_cena
      tmp->KOD_VR  := mohu->kod_vr
      tmp->KOD_AS  := mohu->kod_as
      tmp->OTD     := mohu->otd
      tmp->KOL_1   := mohu->kol_1
      tmp->STOIM_1 := mohu->stoim_1
      tmp->ZF      := mohu->ZF
      tmp->ID_U    := mohu->ID_U
      tmp->PROFIL  := mohu->PROFIL
      tmp->PRVS    := mohu->PRVS
      tmp->kod_diag := mohu->kod_diag
      tmp->n_base  := 1
      tmp->is_nul  := .t.
      tmp->is_oms  := .t.
      tmp->is_zf   := ret_is_zf( tmp->shifr1 )
      tmp->rec_hu  := mohu->( RecNo() )
      tmp->par_org := ret_par_org( tmp->shifr1, d2 )
      If is_telemedicina( tmp->shifr1 )
        tmp->is_edit := -1 // не заполняется код врача
      Endif
      last_date := Max( tmp->date_u1, last_date )
      Select MOHU
      Skip
    Enddo
    Commit
  Endif
  Select TMP
  fl_found := ( tmp->( LastRec() ) > 0 )
  is_1_vvod := ( tmp->( LastRec() ) == 0 .and. mem_ordu_1 == 1 )
  If !is_1_vvod
    If mem_ordusl == 1
      Index On DToS( date_u1 ) + fsort_usl( shifr_u ) to ( cur_dir() + 'tmp_usl_' )
    Else
      Index On fsort_usl( shifr_u ) + DToS( date_u1 ) to ( cur_dir() + 'tmp_usl_' )
    Endif
  Endif
  summa_usl( .f. )
  //
  old_is_zf_stomat := is_zf_stomat
  Select HU
  Set Relation To  // 'отвязываем' human_u_
  Select USL
  Set Order To 1
  is_zf_stomat := 0
  If stiszf( m1USL_OK, m1PROFIL )
    is_zf_stomat := 1
  Endif
  If is_zf_stomat == 1
    use_base( 'kartdelz' )
  Endif
  r_use( dir_server() + 'usl_otd', dir_server() + 'usl_otd', 'UO' )
  r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'PERSO' )
  Select TMP
  Set Relation To otd into OTD
  Go Top
  i := tmp->( LastRec() )
  If i == 0
    If mem_coplec == 2
      kod_lech_vr := human_->vrach
    Endif
  Elseif rec_ksg > 0
    aksg := f_usl_definition_ksg( human->kod )
    If mem_coplec == 2 .and. i == 1
      kod_lech_vr := human_->vrach
    Endif
  Endif
  cls


  pr_1_str( 'Услуги для < ' + fio_plus_novor() + ' >' )
  If yes_num_lu == 1
    @ 1, 50 Say PadL( 'Лист учета № ' + lstr( human->kod ), 29 ) Color color14
  Endif

  begin_row := 3

  l_color := 'W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B,G+/B,G+/RB,R+/B,N/R'
  s := 'Полное наименование услуги'
  If is_zf_stomat == 1
    s := 'Формула зуба / ' + s
  Endif
  @ MaxRow() -3, 0 Say '╒' + PadC( s, 66, '═' ) +                                                '╤══ Цена ═══╕'
  @ MaxRow() -2, 0 Say '│                                                                  │           │'
  @ MaxRow() -1, 0 Say '╘══════════════════════════════════════════════════════════════════╧═══════════╛'
  If fl_found
    Keyboard Chr( K_RIGHT )
  Else
    Keyboard Chr( K_INS )
  Endif
  SetColor( color1 )
  tmp_help := chm_help_code
  chm_help_code := 3003
  mtitle := f_srok_lech( human->n_data, human->k_data, human_->usl_ok )
  alpha_browse( begin_row, 0, MaxRow() -5, 79, 'f_oms_usl_sluch', color1, mtitle, col_tit_popup, ;
    .f., .t., , 'f1oms_usl_sluch', 'f2oms_usl_sluch', , ;
    { '═', '░', '═', l_color, .t., 180 } )
  Select TMP

  Pack
  kol_rec := LastRec()
  Private mcena_1 := human->cena_1, msmo := human_->smo
  If yes_parol .and. ( mvu[ 1, 1 ] > 0 .or. mvu[ 2, 1 ] > 0 .or. mvu[ 3, 1 ] > 0 ) ;
      .and. hb_FileExists( dir_server() + 'mo_opern' + sdbf() )
    Close databases
    If g_use( dir_server() + 'mo_opern', dir_server() + 'mo_opern', 'OP' )
      For i := 1 To 3
        If mvu[ i, 1 ] > 0
          write_work_oper( glob_task, OPER_USL, i, mvu[ i, 1 ], mvu[ i, 2 ], .f. )
        Endif
      Next
    Endif
  Endif
  Close databases
  SetColor( tmp_color )
  If kol_rec == 0
    n_message( { 'Не введено ни одной услуги' },, 'GR+/R', 'W+/R',,, 'G+/R' )
  Endif
  RestScreen( buf )
  chm_help_code := tmp_help
  // запускаем проверку
  If ( mcena_1 > 0 .or. is_smp( m1USL_OK, m1PROFIL ) ) .and. !Empty( Val( msmo ) )
    verify_oms_sluch( mkod_human )
  Endif
  is_zf_stomat := old_is_zf_stomat

  Return Nil
