#include 'common.ch'
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 30.03.24 ДВН - добавление или редактирование случая (листа учета)
Function oms_sluch_dvn_covid( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static sadiag1  // := {}
  Static st_N_DATA, st_K_DATA, s1dispans := 1

  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, mrec_mohu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {}, ah, ;
    i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG", ;
    pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod, ;
    fl, tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0

  Local iUslDop := iUslOtkaz := iUslOtklon := 0   // счетчики
  Local lenArr_Uslugi_DVN_COVID
  local str_1, hS, wS

  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  //
  Private oms_sluch_DVN := .t., ps1dispans := s1dispans, is_prazdnik

  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0,,, .t. ) ) == 0
      Return Nil
    Endif
  Elseif Loc_kod > 0
    r_use( dir_server + "human",, "HUMAN" )
    Goto ( Loc_kod )
    fl := ( human->k_data < 0d20210701 )
    Use
    If fl
      Return func_error( 4, "Углубленная диспансеризация после COVID началась 01 июля 2021 году" )
    Endif
  Endif

  // if empty(sadiag1)
  // Private file_form, diag1 := {}, len_diag := 0
  // if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
  // func_error(4,"Не обнаружен файл DISP_NAB"+sfrm)
  // endif
  // f2_vvod_disp_nabl("A00")
  // sadiag1 := diag1
  // endif
  If ISNIL( sadiag1 )
    sadiag1 := load_diagnoze_disp_nabl_from_file()
  Endif

  chm_help_code := 3002

  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  msmo := "34007", rec_inogSMO := 0, ;
    mokato, m1okato := "", mismo, m1ismo := "", mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, is_talon := .f., mshifr_zs := "", ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MRAB_NERAB, M1RAB_NERAB := 0, ; // 0-работающий, 1 -неработающий
  MUCH_DOC    := Space( 10 ),; // вид и номер учетного документа
  MKOD_DIAG   := Space( 5 ),; // шифр 1-ой осн.болезни
  MKOD_DIAG2  := Space( 5 ),; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := Space( 5 ),; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := Space( 5 ),; // шифр 4-ой осн.болезни
  MSOPUT_B1   := Space( 5 ),; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := Space( 5 ),; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := Space( 5 ),; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := Space( 5 ),; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := Space( 8 ),; // дополнения к диагнозам
  adiag_talon[ 16 ],; // из статталона к диагнозам
  m1rslt  := 317,; // результат (присвоена I группа здоровья)
  m1ishod := 306,; // исход = осмотр
  MN_DATA := st_N_DATA,; // дата начала лечения
  MK_DATA := st_K_DATA,; // дата окончания лечения
  MVRACH := Space( 10 ),; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 4, ;   // Профилактический
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // поликлиника
  m1VIDPOM :=  1, ; // первичная
  m1PROFIL := 97, ; // 97-терапия,57-общая врач.практика (семейн.мед-а),42-лечебное дело
  m1IDSP   := 11, ; // доп.диспансеризация
  mmobilbr, m1mobilbr := 0, ;  // мобильная бригада
  mcena_1 := 0
  //
  Private arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
  Private metap := 1, ;  // 1-первый этап, 2-второй этап (по умолчанию 1 этап)
  mnapr_onk := Space( 10 ), m1napr_onk := 0, ;
    mOKSI := 0, ;  // данные оксиметра %
  mDateCOVID := sys_date, ;  // дата окончания лечения COVID
  mgruppa, m1gruppa := 1, ;      // группа здоровья
    mdyspnea, m1dyspnea := 0 //
  Private mdispans, m1dispans := 0, mnazn_l, m1nazn_l  := 0, ;
    mdopo_na, m1dopo_na := 0, mssh_na, m1ssh_na  := 0, ;
    mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0
  Private mvar, m1var // переменный для организации ввода ин-ции в табличной части
  Private mm_ndisp := { { "Углубленная диспансеризация I  этап", 1 }, ;
    { "Углубленная диспансеризация II этап", 2 } }
  Private mm_strong := { { 'Легкое течение болезни', 1 }, ;
    { 'Среднее течение болезни', 2 }, ;
    { 'Тяжелое течение болезни', 3 }, ;
    { 'Крайне тяжелое течение', 4 }, ;
    { 'Отсутствуют сведения о болезни', 5 } } // Письмо ТФОМС 09-30-370 от 03.12.21
  Private mstrong, m1strong := 1

  Private mm_komorbid := { { 'Иное', 0 }, ;
    { '1 группа', 1 }, ;
    { '2 группа', 2 } }
  Private mkomorbid, m1komorbid := 0

  Private mm_gruppa //, mm_ndisp1

//  mm_ndisp1 := AClone( mm_ndisp )

  Private mm_gruppaP := arr_mm_gruppaP()
  Private mm_gruppaD1 := { ;
    { "Проведена диспансеризация - присвоена I группа здоровья",1, 317 }, ;
    { "Проведена диспансеризация - присвоена II группа здоровья",2, 318 }, ;
    { "Проведена диспансеризация - присвоена IIIа группа здоровья", 3, 355 }, ;
    { "Проведена диспансеризация - присвоена IIIб группа здоровья", 4, 356 }, ;
    { "Направлен на 2 этап, предварительно присвоена I группа здоровья",11, 352 }, ;
    { "Направлен на 2 этап, предварительно присвоена II группа здоровья",12, 353 }, ;
    { "Направлен на 2 этап, предварительно присвоена IIIа группа здоровья", 13, 357 }, ;
    { "Направлен на 2 этап, предварительно присвоена IIIб группа здоровья", 14, 358 };
    }
  Private mm_gruppaD2 := AClone( mm_gruppaD1 )
  ASize( mm_gruppaD2, 4 )
  Private mm_otkaz := arr_mm_otkaz()
  Private mm_otkaz1 := AClone( mm_otkaz )
  ASize( mm_otkaz1, 3 )
  Private mm_otkaz0 := AClone( mm_otkaz )
  ASize( mm_otkaz0, 2 )

  Private mm_pervich := arr_mm_pervich()
  Private mm_dispans := arr_mm_dispans()
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // для битовых полей
  { "dopo_na", "N", 10, 0,,,, {| x| inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
    }
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
    Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0

  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  // //// РАЗОБРАТЬСЯ С НАПРАВЛЕНИЯМИ
  Private mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0

  Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
    pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans

  For i := 1 To 5
    sk := lstr( i )
    pole_diag := "mdiag" + sk
    pole_d_diag := "mddiag" + sk
    pole_pervich := "mpervich" + sk
    pole_1pervich := "m1pervich" + sk
    pole_stadia := "m1stadia" + sk
    pole_dispans := "mdispans" + sk
    pole_1dispans := "m1dispans" + sk
    pole_d_dispans := "mddispans" + sk
    pole_dn_dispans := "mdndispans" + sk
    Private &pole_diag := Space( 6 )
    Private &pole_d_diag := CToD( "" )
    Private &pole_pervich := Space( 7 )
    Private &pole_1pervich := 0
    Private &pole_stadia := 1
    Private &pole_dispans := Space( 10 )
    Private &pole_1dispans := 0
    Private &pole_d_dispans := CToD( "" )
    Private &pole_dn_dispans := CToD( "" )
  Next

  For i := 1 To Len( ret_arrays_disp_covid() )  // создадим поля ввода для всех возможных услуг диспансеризации
    mvar := "MTAB_NOMv" + lstr( i )
    Private &mvar := 0
    mvar := "MTAB_NOMa" + lstr( i )
    Private &mvar := 0
    mvar := "MDATE" + lstr( i )
    Private &mvar := CToD( "" )
    mvar := "MKOD_DIAG" + lstr( i )
    Private &mvar := Space( 6 )
    mvar := "MOTKAZ" + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := "M1OTKAZ" + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
  //
  AFill( adiag_talon, 0 )

  r_use( dir_server + "human_2",, "HUMAN_2" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human",, "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2

  If mkod_k > 0
    r_use( dir_server + "kartote2",, "KART2" )
    Goto ( mkod_k )
    r_use( dir_server + "kartote_",, "KART_" )
    Goto ( mkod_k )
    r_use( dir_server + "kartotek",, "KART" )
    Goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR
    If kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    Endif
    If eq_any( is_uchastok, 1, 3 )
      MUCH_DOC := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1,, .t. ) // открыть и закрыть
    Endif
    // проверка исхода = СМЕРТЬ
    ah := {}
    Select HUMAN
    Set Index to ( dir_server + "humankk" )
    find ( Str( mkod_k, 7 ) )
    Do While human->kod_k == mkod_k .and. !Eof()
      If human_->oplata != 9 .and. human_->NOVOR == 0 .and. RecNo() != Loc_kod
        If is_death( human_->RSLT_NEW ) .and. Empty( a_smert )
          a_smert := { "Данный больной умер!", ;
            "Лечение с " + full_date( human->N_DATA ) + " по " + full_date( human->K_DATA ) }
        Endif
        If Between( human->ishod, 401, 402 )
          AAdd( ah, { human->( RecNo() ), human->K_DATA } )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Set Index To
    If Len( ah ) > 0
      ASort( ah,,, {| x, y| x[ 2 ] < y[ 2 ] } )
      Select HUMAN
      Goto ( ATail( ah )[ 1 ] )
      M1RAB_NERAB := human->RAB_NERAB // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
      letap := human->ishod -400
      If eq_any( letap, 1, 2 )
        lrslt_1_etap := human_->RSLT_NEW
      Endif
      // read_arr_DVN_COVID(human->kod,.f.)  // читаем сохраненные данные по углубленной диспансеризации
    Endif
  Endif

  If Loc_kod > 0  // читаем информацию из HUMAN, HUMAN_U и MO_HU и заполним табличную часть
    Select HUMAN
    Goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // адрес больного
    MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    m1rslt     := human_->RSLT_NEW
    //
    is_prazdnik := f_is_prazdnik_dvn_covid( mn_data )

    metap := human->ishod - 400   // получим сохраненный этап диспансеризации

    If Between( metap, 1, 2 )
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2 }[ metap ]
      If ( i := AScan( mm_gruppa, {| x| x[ 3 ] == m1rslt } ) ) > 0
        m1GRUPPA := mm_gruppa[ i, 2 ]
      Endif
    Endif
    //
    // выбираем иформацию об услугах
    larr := Array( 2, Len( uslugietap_dvn_covid( metap ) ) )
    arr_usl := {} // array(len(uslugiEtap_DVN_COVID(metap)))
    afillall( larr, 0 )
    // afillall(arr_usl,0)
    r_use( dir_server + "uslugi",, "USL" )
    r_use( dir_server + "mo_su",, "MOSU" )
    use_base( "mo_hu" )
    use_base( "human_u" )

    // сначала выберем информацию из human_u по услугам ТФОМС
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      For i := 1 To Len( uslugietap_dvn_covid( metap ) )
        If Empty( larr[ 1, i ] )
          If ValType( uslugietap_dvn_covid( metap )[ i, 2 ] ) == "C" .and. uslugietap_dvn_covid( metap )[ i, 12 ] == 0  // услуга ТФОМС
            If uslugietap_dvn_covid( metap )[ i, 2 ] == lshifr
              fl := .f.
              larr[ 1, i ] := hu->( RecNo() )
              larr[ 2, i ] := lshifr
              // arr_usl[i] := hu->(recno())
              AAdd( arr_usl, hu->( RecNo() ) )

              If ValType( uslugietap_dvn_covid( metap )[ i, 13 ] ) == "C" .and. !Empty( uslugietap_dvn_covid( metap )[ i, 13 ] )
                Select MOHU
                Set Relation To u_kod into MOSU
                find ( Str( Loc_kod, 7 ) )
                Do While MOHU->kod == Loc_kod .and. !Eof()
                  MOSU->( dbGoto( MOHU->u_kod ) )
                  lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )
                  If lshifr == uslugietap_dvn_covid( metap )[ i, 13 ]
                    AAdd( arr_usl, MOHU->( RecNo() ) )
                  Endif

                  // for i := 1 to len(uslugiEtap_DVN_COVID(metap))
                  // if empty(larr[1,i])
                  // if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C" .and. uslugiEtap_DVN_COVID(metap)[i,12] == 1  // услуга ФФОМС
                  // if uslugiEtap_DVN_COVID(metap)[i,2] == lshifr
                  // fl := .f.
                  // larr[1,i] := MOHU->(recno())
                  // larr[2,i] := lshifr
                  // arr_usl[i] := MOHU->(recno())
                  // endif
                  // endif
                  // endif
                  // next
                  Select MOHU
                  Skip
                Enddo
                Select HU
              Endif
            Endif
          Endif
        Endif
      Next
      Select HU
      Skip
    Enddo

    // затем выберем информацию из mo_hu по услугам ФФОМС
    Select MOHU
    Set Relation To u_kod into MOSU
    find ( Str( Loc_kod, 7 ) )
    Do While MOHU->kod == Loc_kod .and. !Eof()
      MOSU->( dbGoto( MOHU->u_kod ) )
      lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )
      For i := 1 To Len( uslugietap_dvn_covid( metap ) )
        If Empty( larr[ 1, i ] )
          If ValType( uslugietap_dvn_covid( metap )[ i, 2 ] ) == "C" .and. uslugietap_dvn_covid( metap )[ i, 12 ] == 1  // услуга ФФОМС
            If uslugietap_dvn_covid( metap )[ i, 2 ] == lshifr
              fl := .f.
              larr[ 1, i ] := MOHU->( RecNo() )
              larr[ 2, i ] := lshifr
              AAdd( arr_usl, MOHU->( RecNo() ) )
            Endif
          Endif
        Endif
      Next
      Select MOHU
      Skip
    Enddo
    //
    r_use( dir_server + "mo_pers",, "P2" )
    read_arr_dvn_covid( Loc_kod )     // читаем сохраненные данные по углубленной диспансеризации

    If metap == 1 .and. Between( m1GRUPPA, 11, 14 ) .and. m1p_otk == 1
      m1GRUPPA += 10
    Endif
    For i := 1 To Len( larr[ 1 ] )
      If ( ValType( larr[ 2, i ] ) == "C" ) .and. ( ! eq_any( SubStr( larr[ 2, i ], 1, 1 ), 'A', 'B' ) )  // это услуга ТФОМС, а не ФФОМС (первый символ не A,B)
        If larr[ 2, i ] == '70.8.1'  // пропустим эту услугу
          Loop
        Endif
        hu->( dbGoto( larr[ 1, i ] ) )
        If hu->kod_vr > 0
          p2->( dbGoto( hu->kod_vr ) )
          mvar := "MTAB_NOMv" + lstr( i )
          &mvar := p2->tab_nom
        Endif
        If hu->kod_as > 0
          p2->( dbGoto( hu->kod_as ) )
          mvar := "MTAB_NOMa" + lstr( i )
          &mvar := p2->tab_nom
        Endif
        mvar := "MDATE" + lstr( i )
        &mvar := c4tod( hu->date_u )
        If !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == "U" )
          mvar := "MKOD_DIAG" + lstr( i )
          &mvar := hu_->kod_diag
        Endif
        m1var := "M1OTKAZ" + lstr( i )
        &m1var := 0 // выполнено
        If ValType( uslugietap_dvn_covid( metap )[ i, 2 ] ) == "C"
          If AScan( arr_otklon, uslugietap_dvn_covid( metap )[ i, 2 ] ) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          Endif
        Endif
        mvar := "MOTKAZ" + lstr( i )
        &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
      Elseif ( ValType( larr[ 2, i ] ) == "C" ) .and. ( eq_any( SubStr( larr[ 2, i ], 1, 1 ), 'A', 'B' ) )  // это услуга ФФОМС (первый символ A,B)
        MOHU->( dbGoto( larr[ 1, i ] ) )
        If MOHU->kod_vr > 0
          p2->( dbGoto( MOHU->kod_vr ) )
          mvar := "MTAB_NOMv" + lstr( i )
          &mvar := p2->tab_nom
        Endif
        If MOHU->kod_as > 0
          p2->( dbGoto( MOHU->kod_as ) )
          mvar := "MTAB_NOMa" + lstr( i )
          &mvar := p2->tab_nom
        Endif
        mvar := "MDATE" + lstr( i )
        &mvar := c4tod( MOHU->date_u )
        If !Empty( MOHU->kod_diag ) .and. !( Left( MOHU->kod_diag, 1 ) == "U" )
          mvar := "MKOD_DIAG" + lstr( i )
          &mvar := hu_->kod_diag
        Endif
        m1var := "M1OTKAZ" + lstr( i )
        &m1var := 0 // выполнено
        If ValType( uslugietap_dvn_covid( metap )[ i, 2 ] ) == "C"
          If AScan( arr_otklon, uslugietap_dvn_covid( metap )[ i, 2 ] ) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          Endif
        Endif
        mvar := "MOTKAZ" + lstr( i )
        &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
      Endif
    Next
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif
    If ValType( arr_usl_otkaz ) == "A"
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == "A" .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == "C"
          lshifr := AllTrim( ar[ 5 ] )

          For i := 1 To Len( uslugietap_dvn_covid( metap ) )
            If ValType( uslugietap_dvn_covid( metap )[ i, 2 ] ) == "C" .and. ;
                ( uslugietap_dvn_covid( metap )[ i, 2 ] == lshifr )
              If ValType( ar[ 1 ] ) == "N" .and. ar[ 1 ] > 0
                p2->( dbGoto( ar[ 1 ] ) )
                mvar := "MTAB_NOMv" + lstr( i )
                &mvar := p2->tab_nom
              Endif
              If ValType( ar[ 3 ] ) == "N" .and. ar[ 3 ] > 0
                p2->( dbGoto( ar[ 3 ] ) )
                mvar := "MTAB_NOMa" + lstr( i )
                &mvar := p2->tab_nom
              Endif
              mvar := "MDATE" + lstr( i )
              &mvar := mn_data
              If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == "D"
                &mvar := ar[ 9 ]
              Endif
              m1var := "M1OTKAZ" + lstr( i )
              &m1var := 1
              If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == "N" .and. Between( ar[ 10 ], 1, 2 )
                &m1var := ar[ 10 ]
              Endif
              mvar := "MOTKAZ" + lstr( i )
              &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
            Endif
          Next i
        Endif
      Next j
    Endif
    For i := 1 To 5
      f_valid_vyav_diag_dispanser(, i )
    Next i
  Endif

  If Empty( mOKSI )
    mOKSI := 95   // оксиметрия в %
  Endif
  //

  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo ; msmo := '34'
  Endif
  is_talon := .t.
  Close databases

  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mndisp    := inieditspr( A__MENUVERT, mm_ndisp, metap )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server + "mo_uch", m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server + "mo_otd", m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mstrong := inieditspr( A__MENUVERT, mm_strong, m1strong )
  mdyspnea := inieditspr( A__MENUVERT, mm_danet, m1dyspnea )
  mdispans  := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  mnazn_l   := inieditspr( A__MENUVERT, mm_danet, m1nazn_l )
  mdopo_na  := inieditspr( A__MENUBIT, mm_dopo_na, m1dopo_na )
  mnapr_v_mo := inieditspr( A__MENUVERT, mm_napr_v_mo, m1napr_v_mo )
  mkomorbid := inieditspr( A__MENUVERT, mm_komorbid, m1komorbid )
  If Empty( arr_mo_spec )
    ma_mo_spec := "---"
  Else
    ma_mo_spec := ""
    For i := 1 To Len( arr_mo_spec )
      ma_mo_spec += lstr( arr_mo_spec[ i ] ) + ","
    Next
    ma_mo_spec := Left( ma_mo_spec, Len( ma_mo_spec ) -1 )
  Endif
  mnapr_stac := inieditspr( A__MENUVERT, mm_napr_stac, m1napr_stac )
  mprofil_stac := inieditspr( A__MENUVERT, getv002(), m1profil_stac )
  mnapr_reab := inieditspr( A__MENUVERT, mm_danet, m1napr_reab )
  mprofil_kojki := inieditspr( A__MENUVERT, getv020(), m1profil_kojki )
  mssh_na   := inieditspr( A__MENUVERT, mm_danet, m1ssh_na )
  mspec_na  := inieditspr( A__MENUVERT, mm_danet, m1spec_na )
  msank_na  := inieditspr( A__MENUVERT, mm_danet, m1sank_na )

  If ! ret_ndisp_covid( Loc_kod, kod_kartotek )
    Return Nil
  Endif
  //
  If !Empty( f_print )
    return &( f_print + "(" + lstr( Loc_kod ) + "," + lstr( kod_kartotek ) + ")" )
  Endif

  //
  str_1 := " случая углубленной диспансеризации взрослого населения (COVID)"
  If Loc_kod == 0
    str_1 := "Добавление" + str_1
  Else
    str_1 := "Редактирование" + str_1
  Endif

  SetColor( color8 )
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // сделать "шестизначные" диагнозы

  Private num_screen := 1
  Do While .t.
    Close databases
    DispBegin()
    hS := 26
    wS := 80
    SetMode( hS, wS )
    @ 0, 0 Say PadC( str_1, wS ) Color "B/BG*"
    gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }

    j := 1
    myclear( j )

    @ j, 0 Say "Экран " + lstr( num_screen ) Color color8
    If num_screen > 1
      s := AllTrim( mfio ) + " (" + lstr( mvozrast ) + " " + s_let( mvozrast ) + ")"
      @ j, wS - Len( s ) Say s Color color14
    Endif
    If num_screen == 1 //
      @ ++j, 1 Say "ФИО" Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION,,, .f. ) } ;
        valid {| g, o| update_get( "mdate_r" ), ;
        update_get( "mkomu" ), update_get( "mcompany" ) }
      @ Row(), Col() + 5 Say "Д.р." Get mdate_r When .f. Color color14

      @ ++j, 1 Say " Принадлежность счёта" Get mkomu ;
        reader {| x| menu_reader( x, mm_komu, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say "==>" Get mcompany ;
        reader {| x| menu_reader( x, mm_company, A__MENUVERT,,, .f. ) } ;
        When m1komu < 5 ;
        valid {| g| func_valid_ismo( g, m1komu, 38 ) }
      @ ++j, 1 Say " Полис ОМС: серия" Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say "номер"  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say "вид"    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT,,, .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      //
      @ ++j, 1 Say "Сроки" Get mn_data ;
        valid {| g| f_k_data( g, 1 ), f_valid_begdata_dvn_covid( g, Loc_kod ), ;
        iif( mvozrast < 18, func_error( 4, "Это не взрослый пациент!" ), nil ), ;
        ret_ndisp_covid( Loc_kod, kod_kartotek );
        }
      @ Row(), Col() + 1 Say "-" Get mk_data ;
        valid {| g| f_k_data( g, 2 ), f_valid_enddata_dvn_covid( g, Loc_kod ), ;
        ret_ndisp_covid( Loc_kod, kod_kartotek ) ;
        }

      @ j, Col() + 5 Say "№ амбулаторной карты" Get much_doc Picture "@!" ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) .or. mem_edit_ist == 2

      ret_ndisp_covid( Loc_kod, kod_kartotek )

      @ ++j, 8 Get mndisp When .f. Color color14

      @ ++j, 1 Say "Степень тяжести болезни"
      @ j, Col() + 1 Get mstrong ;
        reader {| x| menu_reader( x, mm_strong, A__MENUVERT,,, .f. ) };
        valid {| g| valid_strong_date( g ) }

      @ ++j, 1 Say 'Дата окончания лечения COVID' Get mDateCOVID ;
        valid {|| iif( ( ( Empty( mDateCOVID ) ) .or. ( ( mn_data - mDateCOVID ) < 60 ) ), ;
        func_error( 4, iif( Empty( mDateCOVID ), 'Дата окончания лечения не может быть пустой!', 'Прошло меньше 60 дней после заболевания!' ) ), ;
        .t. ) } ;
        when ( m1strong != 5 )   // редактируем только на первом этапе  // Письмо ТФОМС 09-30-370 от 03.12.21
      If metap == 1 // вводим только на первом этапе
        @ ++j, 1 Say "Пульсооксиметрия" Get mOKSI Pict "999" ;
          valid {|| iif( Between( mOKSI, 70, 100 ),, func_error( 4, "Неразумные показания пульсооксиметрии" ) ), .t. }
        @ Row(), Col() + 1 Say "%"
        @ j, Col() + 5 Say "Одышка/отеки" Get mdyspnea ;
          reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
        @ j, Col() + 5 Say "Коморбидная форма"
        @ j, Col() + 1 Get mkomorbid ;
          reader {| x| menu_reader( x, mm_komorbid, A__MENUVERT,,, .f. ) }
      Endif

      @ ++j, 1 Say "────────────────────────────────────────────┬─────┬─────┬──────────┬──────────" Color color8
      @ ++j, 1 Say "Наименования исследований                   │врач │ассис│дата услуг│выполнение " Color color8
      @ ++j, 1 Say "────────────────────────────────────────────┴─────┴─────┴──────────┴──────────" Color color8
      If mem_por_ass == 0
        @ j - 1, 52 Say Space( 5 )
      Endif
      fl_vrach := .t.

      lenArr_Uslugi_DVN_COVID := Len( uslugietap_dvn_covid( metap ) )
      For i := 1 To Len( uslugietap_dvn_covid( metap ) )
        fl_diag := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn_covid( i, metap, .f., @fl_diag, @i_otkaz )
          If fl_diag .and. fl_vrach
            @ ++j, 1 Say "────────────────────────────────────────────┬─────┬─────┬───────────" Color color8
            @ ++j, 1 Say "Наименования осмотров                       │врач │ассис│дата услуги" Color color8
            @ ++j, 1 Say "────────────────────────────────────────────┴─────┴─────┴───────────" Color color8
            If mem_por_ass == 0
              @ j - 1, 52 Say Space( 5 )
            Endif
            fl_vrach := .f.
          Endif
          mvarv := "MTAB_NOMv" + lstr( i )
          mvara := "MTAB_NOMa" + lstr( i )
          mvard := "MDATE" + lstr( i )
          If Empty( &mvard )
            &mvard := mn_data
          Endif
          mvarz := "MKOD_DIAG" + lstr( i )
          mvaro := "MOTKAZ" + lstr( i )
          @ ++j, 1 Say uslugietap_dvn_covid( metap )[ i, 1 ]
          @ j, 46 get &mvarv Pict "99999" valid {| g| v_kart_vrach( g ) } when {| g| condition_when_uslugi_covid( g, metap, mOKSI, m1dyspnea, m1strong ) }
          If mem_por_ass > 0
            @ j, 52 get &mvara Pict "99999" valid {| g| v_kart_vrach( g ) } when {| g| condition_when_uslugi_covid( g, metap, mOKSI, m1dyspnea, m1strong ) }
          Endif
          @ j, 58 get &mvard valid {| g| valid_date_uslugi_covid( g, metap, mn_data, mk_data, lenArr_Uslugi_DVN_COVID, i ) } when {| g| condition_when_uslugi_covid( g, metap, mOKSI, m1dyspnea, m1strong ) }
          If fl_diag
            // @ j, 69 get &mvarz picture pic_diag ;
            // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
          Elseif i_otkaz == 0
            @ j, 69 get &mvaro ;
              reader {| x| menu_reader( x, mm_otkaz0, A__MENUVERT,,, .f. ) } when {| g| condition_when_uslugi_covid( g, metap, mOKSI, m1dyspnea, m1strong ) }
          Elseif i_otkaz == 1
            @ j, 69 get &mvaro ;
              reader {| x| menu_reader( x, mm_otkaz1, A__MENUVERT,,, .f. ) } when {| g| condition_when_uslugi_covid( g, metap, mOKSI, m1dyspnea, m1strong ) }
          Elseif eq_any( i_otkaz, 2, 3 )
            @ j, 69 get &mvaro ;
              reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT,,, .f. ) } when {| g| condition_when_uslugi_covid( g, metap, mOKSI, m1dyspnea, m1strong ) }
          Endif
        Endif
      Next
      @ ++j, 1 Say Replicate( "─", 68 ) Color color8
      status_key( "^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу" )
    Elseif num_screen == 2 //

      mm_gruppa := { mm_gruppaD1, mm_gruppaD2 }[ metap ]
      mgruppa := inieditspr( A__MENUVERT, mm_gruppa, m1gruppa )
      If ( i := AScan( mm_gruppa, {| x| x[ 3 ] == m1rslt } ) ) > 0
        m1GRUPPA := mm_gruppa[ i, 2 ]
      Endif

      ret_ndisp_covid( Loc_kod, kod_kartotek )
//      @ ++j, 8 Get mndisp When .f. Color color14

//      @ ++j, 1  Say "───────┬────────────┬──────────┬──────┬───────────────────────────────────────"
//      @ ++j, 1  Say "       │  выявлено  │   дата   │стадия│установлено диспансерное Дата следующего"
//      @ ++j, 1  Say "диагноз│заболевание │выявления │забол.│наблюдение     (когда)     визита"
//      @ ++j, 1  Say "───────┴────────────┴──────────┴──────┴───────────────────────────────────────"
//      // 2      9            22           35       44        54
//      @ ++j, 2  Get mdiag1 Picture pic_diag ;
//        reader {| o| mygetreader( o, bg ) } ;
//        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
//        f_valid_vyav_diag_dispanser( g, 1 ), ;
//        .f. ) }
//      @ j, 9  Get mpervich1 ;
//        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag1 )
//      @ j, 22 Get mddiag1 When !Empty( mdiag1 )
//      @ j, 35 Get m1stadia1 Pict "9" Range 1, 4 ;
//        When !Empty( mdiag1 )
//      @ j, 44 Get mdispans1 ;
//        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag1 )
//      @ j, 54 Get mddispans1 When m1dispans1 == 1
//      @ j, 67 Get mdndispans1 When m1dispans1 == 1
      //
//      @ ++j, 2  Get mdiag2 Picture pic_diag ;
//        reader {| o| mygetreader( o, bg ) } ;
//        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
//        f_valid_vyav_diag_dispanser( g, 2 ), ;
//        .f. ) }
//      @ j, 9  Get mpervich2 ;
//        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag2 )
//      @ j, 22 Get mddiag2 When !Empty( mdiag2 )
//      @ j, 35 Get m1stadia2 Pict "9" Range 1, 4 ;
//        When !Empty( mdiag2 )
//      @ j, 44 Get mdispans2 ;
//        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag2 )
//      @ j, 54 Get mddispans2 When m1dispans2 == 1
//      @ j, 67 Get mdndispans2 When m1dispans2 == 1
      //
//      @ ++j, 2  Get mdiag3 Picture pic_diag ;
//        reader {| o| mygetreader( o, bg ) } ;
//        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
//        f_valid_vyav_diag_dispanser( g, 3 ), ;
//        .f. ) }
//      @ j, 9  Get mpervich3 ;
//        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag3 )
//      @ j, 22 Get mddiag3 When !Empty( mdiag3 )
//      @ j, 35 Get m1stadia3 Pict "9" Range 1, 4 ;
//        When !Empty( mdiag3 )
//      @ j, 44 Get mdispans3 ;
//        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag3 )
//      @ j, 54 Get mddispans3 When m1dispans3 == 1
//      @ j, 67 Get mdndispans3 When m1dispans3 == 1
      //
//      @ ++j, 2  Get mdiag4 Picture pic_diag ;
//        reader {| o| mygetreader( o, bg ) } ;
//        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
//        f_valid_vyav_diag_dispanser( g, 4 ), ;
//        .f. ) }
//      @ j, 9  Get mpervich4 ;
//        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag4 )
//      @ j, 22 Get mddiag4 When !Empty( mdiag4 )
//      @ j, 35 Get m1stadia4 Pict "9" Range 1, 4 ;
//        When !Empty( mdiag4 )
//      @ j, 44 Get mdispans4 ;
//        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag4 )
//      @ j, 54 Get mddispans4 When m1dispans4 == 1
//      @ j, 67 Get mdndispans4 When m1dispans4 == 1
      //
//      @ ++j, 2  Get mdiag5 Picture pic_diag ;
//        reader {| o| mygetreader( o, bg ) } ;
//        valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
//        f_valid_vyav_diag_dispanser( g, 5 ), ;
//        .f. ) }
//      @ j, 9  Get mpervich5 ;
//        reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag5 )
//      @ j, 22 Get mddiag5 When !Empty( mdiag5 )
//      @ j, 35 Get m1stadia5 Pict "9" Range 1, 4 ;
//        When !Empty( mdiag5 )
//      @ j, 44 Get mdispans5 ;
//        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
//        When !Empty( mdiag5 )
//      @ j, 54 Get mddispans5 When m1dispans5 == 1
//      @ j, 67 Get mdndispans5 When m1dispans5 == 1
      //
//      @ ++j, 1 Say Replicate( "─", 78 ) Color color1

      dispans_vyav_diag( @j, mndisp ) // вызов заполнения блока выявленных заболеваний
      // подвал второго листа
      @ ++j, 1 Say "Диспансерное наблюдение установлено" Get mdispans ;
        reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !emptyall( mdispans1, mdispans2, mdispans3, mdispans4, mdispans5 )
      @ ++j, 1 Say "Назначено лечение (для ф.131)" Get mnazn_l ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }

      dispans_napr( mk_data, @j, .t. )  // вызов заполнения блока направлений

      ++j

      @ ++j, 1 Say "ГРУППА состояния ЗДОРОВЬЯ"
      @ j, Col() + 1 Get mGRUPPA ;
        reader {| x| menu_reader( x, mm_gruppa, A__MENUVERT,,, .f. ) }
      status_key( "^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ ЗАПИСЬ" )
    Endif
    DispEnd()
    count_edit += myread()

    // /////////////////////////////////////////////////////////////////////////////////////////

    If num_screen == 2
      If LastKey() == K_PGUP
        k := 3
        --num_screen
      Else
        k := f_alert( { PadC( "Выберите действие", 60, "." ) }, ;
          { " Выход без записи ", " Запись ", " Возврат в редактирование " }, ;
          iif( LastKey() == K_ESC, 1, 2 ), "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" )
      Endif
    Else
      If LastKey() == K_PGUP
        k := 3
        If num_screen > 1
          --num_screen
        Endif
      Elseif LastKey() == K_ESC
        If ( k := f_alert( { PadC( "Выберите действие", 60, "." ) }, ;
            { " Выход без записи ", " Возврат в редактирование " }, ;
            1, "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" ) ) == 2
          k := 3
        Endif
      Else
        k := 3
        ++num_screen
        If mvozrast < 18
          num_screen := 1
          func_error( 4, "Это не взрослый пациент!" )
        Elseif metap == 0
          num_screen := 1
          func_error( 4, "Проверьте сроки диспансеризации!" )
        Endif
      Endif
    Endif

    SetMode( 25, 80 )
    If k == 3
      Loop
    Elseif k == 2
      num_screen := 1
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0
          s := "СМО"
        Elseif m1komu == 1
          s := "компании"
        Else
          s := "комитета/МО"
        Endif
        func_error( 4, 'Не заполнено наименование ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, 'Не заполнен номер полиса' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, "Не введена дата начала углубленной диспансеризации после COVID." )
        Loop
      Endif
      If mvozrast < 18
        func_error( 4, "Диспансеризация оказана НЕ взрослому пациенту!" )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, "Не введена дата окончания углубленной диспансеризации после COVID." )
        Loop
      Endif
      If Empty( CharRepl( "0", much_doc, Space( 10 ) ) )
        func_error( 4, 'Не заполнен номер амбулаторной карты' )
        Loop
      Endif
      If eq_any( m1gruppa, 3, 4, 13, 14 ) .and. ( m1dopo_na == 0 ) .and. ( m1napr_v_mo == 0 ) .and. ( m1napr_stac == 0 ) .and. ( m1napr_reab == 0 )
        func_error( 4, "Для выбранной ГРУППЫ ЗДОРОВЬЯ выберите назначения (направления) для пациента!" )
        Loop
      Endif
      If ! checktabnumberdoctor( mk_data, .t. )
        Loop
      Endif
      //
      // ////////////////////////////////////////////////////////////
      mdef_diagnoz := 'U09.9 '
      r_use( dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "MKB_10" )
      r_use( dir_server + "mo_pers", dir_server + "mo_pers", "P2" )
      num_screen := 2
      fl := .t.
      k := 0
      kol_d_usl := 0
      arr_osm1 := Array( Len( uslugietap_dvn_covid( metap ) ), 13 )
      afillall( arr_osm1, 0 )

      // ВСЕ ЗАПИСЫВАЕМ
      tmpvr := 0
      For i := 1 To Len( uslugietap_dvn_covid( metap ) )
        fl_diag := .f.
        i_otkaz := 0
        f_is_usl_oms_sluch_dvn_covid( i, metap, .t., @fl_diag, @i_otkaz )
        mvart := "MTAB_NOMv" + lstr( i )
        mvara := "MTAB_NOMa" + lstr( i )
        mvard := "MDATE" + lstr( i )
        mvarz := "MKOD_DIAG" + lstr( i )
        mvaro := "M1OTKAZ" + lstr( i )
        ar := uslugietap_dvn_covid( metap )[ i ]
        // для заполнения услуги 70.8.1
        If ValType( ar[ 2 ] ) == "C" .and. ar[ 2 ] == "B01.026.001"
          tmpvr := &mvart
        Endif
        If ValType( ar[ 2 ] ) == "C" .and. ar[ 2 ] == "70.8.1" .and. metap == 1
          &mvard := mn_data
          &mvart := tmpvr
        Endif
        //
        ++kol_d_usl
        arr_osm1[ i, 12 ] := uslugietap_dvn_covid( metap )[ i, 12 ]   // признак услуги 0 - ТФОМС / 1 - ФФОМС
        If arr_osm1[ i, 12 ] == 0
          arr_osm1[ i, 13 ] := uslugietap_dvn_covid( metap )[ i, 13 ]
        Endif
        If i_otkaz == 2 .and. &mvaro == 2 // если исследование невозможно
          Select P2
          find ( Str( &mvart, 5 ) )
          If Found()
            arr_osm1[ i, 1 ] := p2->kod
          Endif
          If ValType( ar[ 11 ] ) == "A" // специальность
            arr_osm1[ i, 2 ] := ar[ 11, 1 ]
          Endif
          If ValType( ar[ 10 ] ) == "N" // профиль
            arr_osm1[ i, 4 ] := ar[ 10 ]
          Endif
          arr_osm1[ i, 5 ] := ar[ 2 ] // шифр услуги
          // arr_osm1[i,9] := iif(empty(&mvard), mn_data, &mvard)
          arr_osm1[ i, 9 ] := iif( Empty( &mvard ), mk_data, &mvard )
          arr_osm1[ i, 10 ] := &mvaro
          --kol_d_usl
        Elseif i_otkaz == 1 .and. &mvaro == 1  // ОТКАЗ от манипуляции
          arr_osm1[ i, 1 ] := 0
          If ValType( ar[ 11 ] ) == "A" // специальность
            arr_osm1[ i, 2 ] := ar[ 11, 1 ]
          Endif
          If ValType( ar[ 10 ] ) == "N" // профиль
            arr_osm1[ i, 4 ] := ar[ 10 ]
          Endif
          arr_osm1[ i, 5 ] := ar[ 2 ] // шифр услуги
          arr_osm1[ i, 9 ] := iif( Empty( &mvard ), mk_data, &mvard )
          arr_osm1[ i, 10 ] := &mvaro
        Elseif Empty( &mvard )
          fl := func_error( 4, 'Не введена дата услуги "' + LTrim( ar[ 1 ] ) + '"' )
        Elseif Empty( &mvart ) .and. metap == 1 .and. !eq_any( ar[ 2 ], '70.8.2', '70.8.3' )      // на втором этапе услуги могут быть не все
          fl := func_error( 4, 'Не введен врач в услуге "' + LTrim( ar[ 1 ] ) + '"' )
        Else  // табельный номер врача и его специальность
          If !Empty( &mvart ) // табельный номер врача
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_osm1[ i, 1 ] := p2->kod
              arr_osm1[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
            Endif
          Endif
          If !Empty( &mvara ) // табельный номер ассистента
            Select P2
            find ( Str( &mvara, 5 ) )
            If Found()
              arr_osm1[ i, 3 ] := p2->kod
            Endif
          Endif
          If ValType( ar[ 10 ] ) == "N" // профиль
            arr_osm1[ i, 4 ] := ret_profil_dispans_covid( ar[ 10 ], arr_osm1[ i, 2 ] )
          Else
            If Len( ar[ 10 ] ) == Len( ar[ 11 ] ) ; // кол-во профилей = кол-ву спец-тей
              .and. arr_osm1[ i, 2 ] < 0 ; // и нашли специальность по V015
              .and. ( j := AScan( ar[ 11 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
              // берём профиль, соответствующий специальности
            Else
              j := 1 // если нет, берём первый профиль из списка
            Endif
            arr_osm1[ i, 4 ] := ar[ 10, j ] // профиль
          Endif
          If ValType( ar[ 2 ] ) == "C"  // шифр услуги
            arr_osm1[ i, 5 ] := ar[ 2 ] // шифр услуги
          Else
            If Len( ar[ 2 ] ) >= metap
              j := metap
            Else
              j := 1
            Endif
            arr_osm1[ i, 5 ] := ar[ 2, j ] // шифр услуги
          Endif

          If !fl_diag .or. Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'U'
            If m1strong != 5   // Письмо ТФОМС 09-30-370 от 03.12.21
              arr_osm1[ i, 6 ] := mdef_diagnoz
            Endif
          Else
            arr_osm1[ i, 6 ] := &mvarz
            Select MKB_10
            find ( PadR( arr_osm1[ i, 6 ], 6 ) )
            If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
              fl := func_error( 4, "Несовместимость диагноза по полу " + arr_osm1[ i, 6 ] )
            Endif
          Endif
          arr_osm1[ i, 10 ] := &mvaro
          arr_osm1[ i, 9 ] := &mvard
        Endif
        If !fl
          Exit
        Endif
      Next
      If metap == 1
        iB01_026_001 := indexuslugaetap_dvn_covid( metap, 'B01.026.001' )
        i70_80_1 := indexuslugaetap_dvn_covid( metap, '70.8.1' )
        arr_osm1[ i70_80_1, 1 ] := arr_osm1[ iB01_026_001, 1 ]
        arr_osm1[ i70_80_1, 2 ] := arr_osm1[ iB01_026_001, 2 ]
        arr_osm1[ i70_80_1, 3 ] := arr_osm1[ iB01_026_001, 3 ]
        arr_osm1[ i70_80_1, 6 ] := arr_osm1[ iB01_026_001, 6 ]
        arr_osm1[ i70_80_1, 9 ] := arr_osm1[ iB01_026_001, 9 ]
        arr_osm1[ i70_80_1, 11 ] := arr_osm1[ iB01_026_001, 11 ]
      Endif
      If !fl
        Loop
      Endif

      num_screen := 2
      arr_diag := {}
      For i := 1 To 5
        sk := lstr( i )
        pole_diag := "mdiag" + sk
        pole_d_diag := "mddiag" + sk
        pole_1pervich := "m1pervich" + sk
        pole_1dispans := "m1dispans" + sk
        pole_d_dispans := "mddispans" + sk
        pole_dn_dispans := "mdndispans" + sk
        If !Empty( &pole_diag )
          If Left( &pole_diag, 1 ) == "U"
            fl := func_error( 4, 'Диагноз ' + RTrim( &pole_diag ) + '(первый символ "U") не вводится. Это не заболевание!' )
          elseif &pole_1pervich == 0
            If Empty( &pole_d_diag )
              fl := func_error( 4, "Не введена дата выявления диагноза " + &pole_diag )
            elseif &pole_1dispans == 1 .and. Empty( &pole_d_dispans )
              fl := func_error( 4, "Не введена дата установления диспансерного наблюдения для диагноза " + &pole_diag )
            Endif
          Endif
          If fl .and. Between( &pole_1pervich, 0, 1 ) // предварительные диагнозы не берём
            AAdd( arr_diag, { &pole_diag, &pole_1pervich, &pole_1dispans, &pole_dn_dispans } )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If Len( arr_diag ) > 0 .and. m1strong != 5   // Письмо ТФОМС 09-30-370 от 03.12.21
        AAdd( arr_diag, { mdef_diagnoz, 0, 0, CToD( "" ) } )
      Endif
      If !fl
        Loop
      Endif

      AFill( adiag_talon, 0 )
      If Empty( arr_diag ) .and. m1strong != 5 // диагнозы не вводили  // Письмо ТФОМС 09-30-370 от 03.12.21
        MKOD_DIAG := mdef_diagnoz
      Else
        For i := 1 To Len( arr_diag )
          If arr_diag[ i, 2 ] == 0 // "ранее выявлено"
            arr_diag[ i, 2 ] := 2  // заменяем, как в листе учёта ОМС
          Endif
          If arr_diag[ i, 3 ] > 0 // "дисп.наблюдение установлено" и "ранее выявлено"
            If arr_diag[ i, 2 ] == 2 // "ранее выявлено"
              arr_diag[ i, 3 ] := 1 // то "Состоит"
            Else
              arr_diag[ i, 3 ] := 2 // то "Взят"
            Endif
          Endif
        Next
        For i := 1 To Len( arr_diag )
          // if ascan(sadiag1,alltrim(arr_diag[i,1])) > 0 .and. ;
          // arr_diag[i,3] == 1 .and. !empty(arr_diag[i,4]) .and. arr_diag[i,4] > mk_data
          // endif
          adiag_talon[ i * 2 -1 ] := arr_diag[ i, 2 ]
          adiag_talon[ i * 2  ] := arr_diag[ i, 3 ]
          If i == 1
            MKOD_DIAG := arr_diag[ i, 1 ]
          Elseif i == 2
            MKOD_DIAG2 := arr_diag[ i, 1 ]
          Elseif i == 3
            MKOD_DIAG3 := arr_diag[ i, 1 ]
          Elseif i == 4
            MKOD_DIAG4 := arr_diag[ i, 1 ]
          Elseif i == 5
            MSOPUT_B1 := arr_diag[ i, 1 ]
          Endif
          Select MKB_10
          find ( PadR( arr_diag[ i, 1 ], 6 ) )
          If Found()
            If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
              fl := func_error( 4, "несовместимость диагноза по полу " + AllTrim( arr_diag[ i, 1 ] ) )
            Endif
          Else
            fl := func_error( 4, "не найден диагноз " + AllTrim( arr_diag[ i, 1 ] ) + " в справочнике МКБ-10" )
          Endif
          If !fl
            Exit
          Endif
        Next
        If !fl
          Loop
        Endif
      Endif

      If  m1strong != 5  // Письмо ТФОМС 09-30-370 от 03.12.21
        AAdd( arr_diag, { mdef_diagnoz, 0, 0, CToD( "" ) } ) // всегда добавляем в лист учета
      Endif

      mm_gruppa := { mm_gruppaD1, mm_gruppaD2 }[ metap ]

      m1p_otk := 0
      If ( i := AScan( mm_gruppa, {| x| x[ 2 ] == m1GRUPPA } ) ) > 0
        If ( m1rslt := mm_gruppa[ i, 3 ] ) == 352
          m1rslt := 353 // по письму ТФОМС от 06.07.18 №09-30-96
        Endif
        If eq_any( m1GRUPPA, 11, 21 )
          m1GRUPPA++ // по письму ТФОМС от 06.07.18 №09 -30 -96
        Endif
        If m1GRUPPA > 20
          m1p_otk := 1 // отказ от прихода на 2-й этап
        Endif
      Else
        func_error( 4, "Не введена ГРУППА состояния ЗДОРОВЬЯ" )
        Loop
      Endif
      //
      m1ssh_na := m1psih_na := m1spec_na := 0
      If m1napr_v_mo > 0
        If eq_ascan( arr_mo_spec, 45, 141 ) // Направлен к врачу-сердечно-сосудистому хирургу
          m1ssh_na := 1
        Endif
        If eq_ascan( arr_mo_spec, 23, 97 ) // Направлен к врачу-психиатру (врачу-психиатру-наркологу)
          m1psih_na := 1
        Endif
      Endif
      If m1napr_stac > 0 .and. m1profil_stac > 0
        m1spec_na := 1 // Направлен для получения специализированной медицинской помощи (в т.ч. ВМП)
      Endif
      //
      err_date_diap( mn_data, "Дата начала углубленной диспансеризации после COVID" )
      err_date_diap( mk_data, "Дата окончания углубленной диспансеризации после COVID" )
      //
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, 'Оператор "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, 'Ввод данных за ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait()
      is_prazdnik := f_is_prazdnik_dvn_covid( mn_data )

      make_diagp( 2 )  // сделать "пятизначные" диагнозы
      If m1dispans > 0
        s1dispans := m1dispans
      Endif
      //
      use_base( "lusl" )
      use_base( "luslc" )
      use_base( "uslugi" )
      r_use( dir_server + "uslugi1", { dir_server + "uslugi1", ;
        dir_server + "uslugi1s" }, "USL1" )
      mcena_1 := mu_cena := 0
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      arr_otklon := {}
      glob_podr := ""
      glob_otd_dep := 0
      iUslDop := 0
      iUslOtkaz := 0
      iUslOtklon := 0
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == "C"
          If arr_osm1[ i, 12 ] == 0
            arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
            arr_osm1[ i, 8 ] := iif( eq_any( arr_osm1[ i, 10 ], 0, 3 ), mu_cena, 0 )
          Else
            arr_osm1[ i, 7 ] := foundffomsusluga( arr_osm1[ i, 5 ] )
            arr_osm1[ i, 8 ] := 0  // для федеральных услуг цену дадим 0
            // mu_cena := 0
          Endif

          // if arr_osm1[i,1] == 0    // если в услуге не назначен врач
          // loop
          // endif

          If eq_any( arr_osm1[ i, 10 ], 0, 3 ) // выполнено
            AAdd( arr_usl_dop, AClone( arr_osm1[ i ] ) )
            // iUslDop++
            If arr_osm1[ i, 12 ] == 0 .and. !Empty( arr_osm1[ i, 13 ] )  // для услуги ТФОМС добавим услугу ФФОМС
              AAdd( arr_usl_dop, AClone( arr_osm1[ i ] ) )
              iUslDop := Len( arr_usl_dop ) // ++
              arr_usl_dop[ iUslDop, 5 ] := arr_osm1[ i, 13 ]
              arr_usl_dop[ iUslDop, 7 ] := foundffomsusluga( arr_usl_dop[ iUslDop, 5 ] )
              arr_usl_dop[ iUslDop, 8 ] := 0  // для федеральных услуг цену дадим 0
              arr_usl_dop[ iUslDop, 12 ] := 1  // установим флаг услуги ФФОМС
              arr_usl_dop[ iUslDop, 13 ] := ''  // очистим федеральную услугу
            Endif
            If arr_osm1[ i, 10 ] == 3 // обнаружены отклонения
              AAdd( arr_otklon, arr_osm1[ i, 5 ] )
              iUslOtklon++
            Endif
          Else // отказ и невозможность
            AAdd( arr_usl_otkaz, AClone( arr_osm1[ i ] ) )
            // iUslOtkaz++
            If arr_osm1[ i, 12 ] == 0 .and. !Empty( arr_osm1[ i, 13 ] )  // для услуги ТФОМС добавим услугу ФФОМС
              AAdd( arr_usl_otkaz, AClone( arr_osm1[ i ] ) )
              iUslOtkaz := Len( arr_usl_otkaz ) // ++
              arr_usl_otkaz[ iUslOtkaz, 5 ] := arr_osm1[ i, 13 ]
              arr_usl_otkaz[ iUslOtkaz, 7 ] := foundffomsusluga( arr_usl_otkaz[ iUslOtkaz, 5 ] )
              arr_usl_otkaz[ iUslOtkaz, 8 ] := 0  // для федеральных услуг цену дадим 0
              arr_usl_otkaz[ iUslOtkaz, 12 ] := 1  // установим флаг услуги ФФОМС
              arr_usl_otkaz[ iUslOtkaz, 13 ] := ''  // очистим федеральную услугу
            Endif
          Endif
        Endif
      Next
      // получим общую стоимость случая для принимаемых услуг
      For i := 1 To Len( arr_usl_dop )
        mcena_1 += iif( arr_usl_dop[ i, 1 ] == 0, 0, arr_usl_dop[ i, 8 ] )
      Next
      //
      use_base( "human" )
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        mkod := Loc_kod
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace human->kod With mkod
      Endif
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      st_N_DATA := MN_DATA
      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ""
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-лечение завершено
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий, 2-студент
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 400 + metap
      human->bolnich    := 0
      human->date_b_1   := ""
      human->date_b_2   := ""
      human_->RODIT_DR  := CToD( "" )
      human_->RODIT_POL := ""
      s := ""
      AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ""
      human_->POVOD     := iif( metap == 3, 5, 6 )
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( "" )
      human_->POL2      := ""
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := 151    // m1PROFIL
      human_->IDSP      := 30     // iif(metap == 3, 17, 11)
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod

      m1vrach := arr_osm1[ Len( arr_osm1 ), 1 ]  // возьмем врача оказавшего последнюю услугу

      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      If Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
        human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // код оператора
        human->date_e  := c4sys_date
      Else // при редактированиии
        human_->kod_p2  := kod_polzovat    // код оператора
        human_->date_e2 := c4sys_date
      Endif
      put_0_human_2()
      Private fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        g_use( dir_server + "mo_hismo",, "SN" )
        Index On Str( kod, 7 ) to ( cur_dir + "tmp_ismo" )
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            sn->smo_name := mnameismo
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            sn->kod := mkod
            sn->smo_name := mnameismo
          Endif
        Endif
      Endif
      i1 := Len( arr_usl )

      r_use( dir_server + "mo_su",, "MOSU" )
      use_base( "mo_hu" )
      use_base( "human_u" )
      For i := 1 To Len( arr_usl_dop )  // i2
        flExist := .f.
        If arr_usl_dop[ i, 12 ] == 0   // это услуга ТФОМС
          // сначала выберем информацию из human_u по услугам ТФОМС
          Select HU
          find ( Str( Loc_kod, 7 ) )
          Do While hu->kod == Loc_kod .and. !Eof()
            usl->( dbGoto( hu->u_kod ) )
            If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
              lshifr := usl->shifr
            Endif
            lshifr := AllTrim( lshifr )
            If lshifr == AllTrim( arr_usl_dop[ i, 5 ] )
              g_rlock( forever )
              flExist := .t.
              Exit
            Endif
            Skip
          Enddo
          If ! flExist
            add1rec( 7 )
            hu->kod := human->kod
          Endif
          mrec_hu := hu->( RecNo() )
          hu->kod_vr  := arr_usl_dop[ i, 1 ]
          hu->kod_as  := arr_usl_dop[ i, 3 ]
          hu->u_koef  := 1
          hu->u_kod   := arr_usl_dop[ i, 7 ]
          hu->u_cena  := arr_usl_dop[ i, 8 ]
          hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 10 .and. ValType( arr_usl_dop[ i, 11 ] ) == "N", arr_usl_dop[ i, 11 ], 0 )
          hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
          hu->otd     := m1otd
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
          hu->KOL_RCP := 0
          Select HU_
          Do While hu_->( LastRec() ) < mrec_hu
            Append Blank
          Enddo
          Goto ( mrec_hu )
          g_rlock( forever )
          If i > i1 .or. !valid_guid( hu_->ID_U )
            hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
          Endif
          hu_->PROFIL := arr_usl_dop[ i, 4 ]
          hu_->PRVS   := arr_usl_dop[ i, 2 ]
          hu_->kod_diag := iif( Empty( arr_usl_dop[ i, 6 ] ), MKOD_DIAG, arr_usl_dop[ i, 6 ] )
          hu_->zf := ""
          Unlock
        Else  // 1 - это услуга ФФОМС
          // затем выберем информацию из mo_hu по услугам ФФОМС
          Select MOHU
          Set Relation To u_kod into MOSU
          find ( Str( Loc_kod, 7 ) )
          Do While MOHU->kod == Loc_kod .and. !Eof()
            MOSU->( dbGoto( MOHU->u_kod ) )
            Select MOHU
            lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )
            If AllTrim( lshifr ) == AllTrim( arr_usl_dop[ i, 5 ] )
              g_rlock( forever )
              flExist := .t.
              Exit
            Endif
            Skip
          Enddo
          If ! flExist
            add1rec( 7 )
            MOHU->kod := human->kod
          Endif
          mrec_mohu := MOHU->( RecNo() )
          MOHU->kod_vr  := arr_usl_dop[ i, 1 ]
          MOHU->kod_as  := arr_usl_dop[ i, 3 ]
          MOHU->u_kod   := arr_usl_dop[ i, 7 ]
          MOHU->u_cena  := arr_usl_dop[ i, 8 ]
          MOHU->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
          MOHU->otd     := m1otd
          MOHU->kol_1 := 1
          MOHU->stoim_1 := arr_usl_dop[ i, 8 ]
          If i > i1 .or. !valid_guid( MOHU->ID_U )
            MOHU->ID_U := mo_guid( 3, MOHU->( RecNo() ) )
          Endif
          MOHU->PROFIL := arr_usl_dop[ i, 4 ]
          MOHU->PRVS   := arr_usl_dop[ i, 2 ]
          MOHU->kod_diag := iif( Empty( arr_usl_dop[ i, 6 ] ), MKOD_DIAG, arr_usl_dop[ i, 6 ] )
          Unlock
        Endif
      Next
      // ????????

      If ! ( Len( arr_usl ) == 0 )
        If ! Empty( arr_usl_otkaz )
          For iOtkaz := 1 To Len( arr_usl_otkaz )
            If arr_usl_otkaz[ iOtkaz, 12 ] == 0
              Select HU
              // сначала выберем информацию из human_u по услугам ТФОМС
              find ( Str( Loc_kod, 7 ) )
              Do While hu->kod == Loc_kod .and. !Eof()
                usl->( dbGoto( hu->u_kod ) )
                If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
                  lshifr := usl->shifr
                Endif
                lshifr := AllTrim( lshifr )
                If lshifr == AllTrim( arr_usl_otkaz[ iOtkaz, 5 ] )
                  deleterec( .t., .f. )  // очистка записи без пометки на удаление
                  Exit
                Endif
                Skip
              Enddo
            Else
              // затем выберем информацию из mo_hu по услугам ФФОМС
              Select MOHU
              Set Relation To u_kod into MOSU
              find ( Str( Loc_kod, 7 ) )
              Do While MOHU->kod == Loc_kod .and. !Eof()
                MOSU->( dbGoto( MOHU->u_kod ) )
                lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )
                Select MOHU
                If AllTrim( lshifr ) == AllTrim( arr_usl_otkaz[ iOtkaz, 5 ] )
                  deleterec( .t., .f. )  // очистка записи без пометки на удаление
                  Exit
                Endif
                Skip
              Enddo
            Endif
          Next
        Endif
        For i := 1 To Len( arr_osm1 )
          // if arr_osm1[i, 1] == 0  // не заполнен врач
          // if arr_osm1[i,12] == 0
          // select HU
          // // goto (arr_usl[indexUslugaEtap_DVN_COVID(metap, arr_osm1[i,5])])
          // // if !eof() .and. !bof()
          // //   DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
          // // endif

          // // сначала выберем информацию из human_u по услугам ТФОМС
          // find (str(Loc_kod,7))
          // do while hu->kod == Loc_kod .and. !eof()
          // usl->(dbGoto(hu->u_kod))
          // if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
          // lshifr := usl->shifr
          // endif
          // lshifr := alltrim(lshifr)
          // flFFOMS := valtype(arr_osm1[i,13]) == 'C' .and. !empty(arr_osm1[i,13])    // есть соответствующая услуга ФФОМС
          // if lshifr == alltrim(arr_osm1[i,5])
          // DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
          // if flFFOMS
          // select MOHU
          // // затем выберем информацию из mo_hu по услугам ФФОМС
          // set relation to u_kod into MOSU
          // find (str(Loc_kod,7))
          // do while MOHU->kod == Loc_kod .and. !eof()
          // MOSU->(dbGoto(MOHU->u_kod))
          // lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
          // if alltrim(lshifr) == alltrim(arr_osm1[i,13])
          // DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
          // exit
          // endif
          // skip
          // enddo
          // select HU
          // endif
          // exit
          // endif
          // skip
          // enddo

          // else
          // select MOHU
          // // goto (arr_usl[indexUslugaEtap_DVN_COVID(metap, arr_osm1[i,5])])
          // // if !eof() .and. !bof()
          // //   DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
          // // endif
          // // затем выберем информацию из mo_hu по услугам ФФОМС
          // set relation to u_kod into MOSU
          // find (str(Loc_kod,7))
          // do while MOHU->kod == Loc_kod .and. !eof()
          // MOSU->(dbGoto(MOHU->u_kod))
          // lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
          // select MOHU
          // if alltrim(lshifr) == alltrim(arr_osm1[i,5])
          // DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
          // exit
          // endif
          // skip
          // enddo

          // endif
          // endif
        Next
      Endif

      save_arr_dvn_covid( mkod, mk_data )

      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( "Запись завершена!", .f. )
    Endif
    Exit
  Enddo

  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // если записали - запускаем проверку
    If Type( "fl_edit_DVN_COVID" ) == "L"
      fl_edit_DVN_COVID := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil
