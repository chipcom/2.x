#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

#define BASE_ISHOD_RZD 500  //

// 12.02.26
Function verify_sluch( fl_view, ft )

  local mIDPC // код цели посещения по справочнику V025
  local arr_IDPC := {}  // массив для кодов целей посещения
  local arrUslugiOver // для проверки услуг пересекающихся случаев поликлиники
  local dBegin  // дата начала случая
  local dEnd    // дата окончания случая
  local cd1, cd2, ym2
  local yearBegin // год даты начала случая
  local yearEnd // год даты окончания случая
  Local _ocenka := 5, ta := {}, u_other := {}, ssumma := 0, auet, fl, lshifr1, ;
    i, j, jk, k, c, s := ' ', a_srok_lech := {}, a_period_stac := {}, a_disp := {}, ;
    a_period_amb, a_1_11, u_1_stom := '', lprofil, ;
    lbukva, lst, lidsp, a_idsp := {}, a_bukva := {}, t_arr[ 2 ], ltip, lkol, ;
    a_dializ := {}, is_2_88 := .f., a_rec_ffoms := {}, arr_povod := {}, mpovod := 0, ;
    lal, lalf
  Local reserveKSG_1 := .f., reserveKSG_2 := .f.
  Local sbase
  Local arr_uslugi_geriatr := { 'B01.007.001', 'B01.007.003', 'B01.007.003' }, row, rowTmp
  Local flGeriatr := .f.
  Local arrV018, arrV019
  Local arrImplant
  Local arrLekPreparat, arrGroupPrep, mMNN
  Local flLekPreparat := .f.
  Local arrUslugi := {} // массив содержаший коды услуг в случае 
  Local lTypeLUMedReab := .f.
  Local aUslMedReab
  Local obyaz_uslugi_med_reab, iUsluga
  Local lTypeLUOnkoDisp := .f.
  Local lDoubleSluch := .f.
  Local iVMP
  Local aDiagnoze_for_check := {}
  Local fl_zolend := .f.
  Local header_error := ''
  Local vozrast, lu_type
  Local kol_dney  // количество дней лечения
  Local is_2_92_ := .f. // наличие услуг школ сахарного диабета или ХНИЗ
  local is_period_amb
  Local shifr_2_92 := ''  // шифр услуги из группы школ диабета и ХНИЗ
  Local kol_2_93_1 := 0  // кол-во услуг школы диабета, письмо 12-20-154 от 28.04.23
  Local kol_2_93_2 := 0 // кол-во услуг школы больных ХНИЗ, письмо 12-20-313 от 09.06.25
  Local l_mdiagnoz_fill := .f.  // в массиве диагнозов есть элементы
  Local i_n009, aN009 := getn009()
  Local i_n012, aN012_DS := getds_n012(), ar_N012 := {}, it
  Local aN021, l_n021
  Local usl_found := .f.
  local cuch_doc, gnot_disp, gkod_diag, gusl_ok
  local counter, arr_lfk
  local mPCEL := ''
  local info_disp_nabl := 0, ldate_next
  local s_lek_pr
  local iFind, aCheck, cUsluga, iCount
  local arrPZ
  local arr_PN_osmotr, arr_not_zs
  local arr_pn_issled
  local aDiagnozes
  local napr_number
  local iProfil_m
  local a_mo_prik
  local lKart2

  Default fl_view To .t.

  If Empty( human->k_data )
    Return .t.  // не проверять
  Endif
  
  Private mdate_r := human->date_r, mvozrast, mdvozrast, M1VZROS_REB := human->VZROS_REB, ;
    arr_usl_otkaz := {}, m1novor := 0, mpol := human->pol, mDATE_R2 := CToD( '' ), ;
    is_oncology := 0, is_oncology_smp := 0

  private mk_data

  a_period_amb := {}
  mIDPC := ''
  rec_human := human->( RecNo() )

  If human_->NOVOR > 0
    m1novor := 1 // для переопределения M1VZROS_REB
    mDATE_R2 := human_->DATE_R2
    mpol := human_->POL2
  Endif

  fv_date_r( human->n_data ) // переопределение M1VZROS_REB
  m1novor := human_->NOVOR // для запрета пересечения детей по номеру
  If M1VZROS_REB != human->VZROS_REB  // если неверно,
    human->( g_rlock( forever ) )
    human->VZROS_REB := M1VZROS_REB   // то перезаписываем
    Unlock
  Endif

  // определяем возраст, если 0 то возраст до года
  vozrast := count_years( iif( human_->NOVOR == 0, human->DATE_R, human_->DATE_R2 ), human->N_DATA )

  // установим курсор на нужное учреждение и отделение
  uch->( dbGoto( human->LPU ) )
  otd->( dbGoto( human->OTD ) )
  lu_type := otd->TIPLU

  // выводим сообщение в нижнюю строку
  s := fam_i_o( human->fio ) + ' '
  If !Empty( otd->short_name )
    s += '[' + AllTrim( otd->short_name ) + '] '
  Endif
  s += date_8( human->n_data ) + '-' + date_8( human->k_data )
  @ MaxRow(), 0 Say PadR( ' ' + s, 50 ) Color 'G+/R'

  // заголовок для вывода в протокол ошибок
  header_error := fio_plus_novor() + ' ' + AllTrim( human->kod_diag ) + ' ' + ;
    date_8( human->n_data ) + '-' + date_8( human->k_data ) + ;
    ' (' + count_ymd( human->date_r, human->n_data ) + ')' + hb_eol()
  header_error += AllTrim( uch->name ) + '/' + AllTrim( otd->name ) + '/профиль по "' + ;
    AllTrim( inieditspr( A__MENUVERT, getv002(), human_->profil ) ) + '"'

  glob_kartotek := human->kod_k
  dBegin := human->n_data
  dEnd := human->k_data
  mk_data := human->k_data
  cd1 := dtoc4( dBegin )
  cd2 := dtoc4( dEnd )
  yearBegin := Year( dBegin )
  yearEnd := Year( dEnd )

  arrPZ := get_array_PZ( yearEnd )

  ym2 := Left( DToS( dEnd ), 6 )

  kol_dney := kol_dney_lecheniya( human->n_data, human->k_data, human_->usl_ok )
  cuch_doc := human->uch_doc

  // проверка отделения
  if Empty( otd->LPU_1 )
    AAdd( ta, 'для отделения ' + AllTrim( otd->short_name ) + ' не выбрано "Структурное подразделение по ФФОМС"' )
  endif

  // проверка по датам
  If Year( human->date_r ) < LIMITED_DATE_MIN
    AAdd( ta, 'дата рождения: ' + full_date( human->date_r ) + ' ( < ' + str( LIMITED_DATE_MIN, 4 ) + 'г.)' )
  Endif
  If Year( human->date_r ) > LIMITED_DATE_MAX
    AAdd( ta, 'дата рождения: ' + full_date( human->date_r ) + ' ( > ' + str( LIMITED_DATE_MAX, 4 ) + 'г.)' )
  Endif
  If human->date_r > human->n_data
    AAdd( ta, 'дата рождения: ' + full_date( human->date_r ) + ;
      ' > даты начала лечения: ' + full_date( human->n_data ) )
  Endif
  If human->n_data > human->k_data
    AAdd( ta, 'дата начала лечения: ' + full_date( human->n_data ) + ;
      ' > даты окончания лечения: ' + full_date( human->k_data ) )
  Endif
  If yearEnd - yearBegin > 1
    AAdd( ta, 'время лечения составляет ' + lstr( human->k_data - human->n_data ) + ' дней' )
  Endif
  If human->k_data > sys_date
    AAdd( ta, 'дата окончания лечения > системной даты: ' + full_date( human->k_data ) )
  Endif
  If human_->NOVOR > 0
    If Empty( human_->DATE_R2 )
      AAdd( ta, 'не введена дата рождения новорожденного' )
    Elseif human_->DATE_R2 > human->n_data
      AAdd( ta, 'дата рождения новорожденного: ' + full_date( human_->DATE_R2 ) + ' больше даты начала лечения: ' + full_date( human->n_data ) )
    Elseif human->n_data - human_->DATE_R2 > 60
      AAdd( ta, 'новорожденному более двух месяцев' )
    Endif
  Endif

  If human_->usl_ok == USL_OK_POLYCLINIC
    s := 'амбулаторной карты'
  Elseif human_->usl_ok == USL_OK_AMBULANCE // 4
    s := 'карты вызова'
  Else
    s := 'истории болезни'
  Endif
  If Empty( CharRepl( '0', human->uch_doc, Space( 10 ) ) )
    AAdd( ta, 'не заполнен номер ' + s + ': ' + human->uch_doc )
  Else
    For i := 1 To Len( human->uch_doc )
      c := SubStr( human->uch_doc, i, 1 )
      If Between( c, '0', '9' )
        // цифры,
      Elseif isletter( c )
        // буквы русского и латинского алфавита,
      Elseif Empty( c )
        // пробел,
      Elseif eq_any( c, '.', '/', '\', '-', '|', '_', ' + ' )
        // точка,горизонтальные разделители, вертикальные и наклонные разделители,нижнее подчеркивание, знак ' + '
      Else
        AAdd( ta, 'недопустимый символ "' + c + '" в номере ' + s + ': ' + human->uch_doc )
      Endif
    Next
  Endif

  //
  // ПРОВЕРЯЕМ ДИАГНОЗЫ
  //
  mdiagnoz := diag_to_array(, , , , .t. ) 
  If Len( mdiagnoz ) == 0 .or. Empty( mdiagnoz[ 1 ] )
    AAdd( ta, 'не заполнено поле "ОСНОВНОЙ ДИАГНОЗ"' )
  Endif
  // проверим заполненные "фиктивные" диагнозы
  if Upper( AllTrim( mdiagnoz[ 1 ] ) ) == 'Z92.9' .and. ( Len( mdiagnoz ) == 1 .or. Empty( AllTrim( mdiagnoz[ 2 ] ) ) )
    AAdd( ta, 'для основного диагноза Z92.9 дополнительно заполняется сопутствующий диагноз' )
  Endif

  l_mdiagnoz_fill := ( Len( mdiagnoz ) > 0 )

  If l_mdiagnoz_fill
    If mdiagnoz[ 1 ] == 'Z00.2' .and. !( vozrast >= 1 .and. vozrast < 14 )
      AAdd( ta, 'основной диагноз Z00.2 допустим только для возраста от года до 14 лет' )
    Elseif mdiagnoz[ 1 ] == 'Z00.3' .and. !( vozrast >= 14 .and. vozrast < 18 )
      AAdd( ta, 'основной диагноз Z00.3 допустим только для возраста от 14 до 18 лет' )
    Elseif mdiagnoz[ 1 ] == 'Z00.1' .and. ( vozrast >= 1 )
      AAdd( ta, 'основной диагноз Z00.1 допустим только для возраста до года' )
    Endif
  Endif

  aDiagnozes := fill_array_diagnoze()
  If glob_otd[ 4 ] != TIP_LU_DVN_COVID
//    If Len( aDiagnoze_for_check := dublicate_diagnoze( fill_array_diagnoze() ) ) > 0
    If Len( aDiagnoze_for_check := dublicate_diagnoze( aDiagnozes ) ) > 0
      For i := 1 To Len( aDiagnoze_for_check )
        AAdd( ta, 'совпадающий диагноз ' + aDiagnoze_for_check[ i, 2 ] + aDiagnoze_for_check[ i, 1 ] )
      Next
    Endif
  Endif

  If Select( 'MKB_10' ) == 0
    r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
  Endif
  Select MKB_10

  if human_->usl_ok != USL_OK_AMBULANCE // проверка диагнозов, кроме скорой помощи
    checking_full_diagnoses_verify( 'MKB_10', mk_data, aDiagnozes, ta )
  endif

  For i := 1 To Len( mdiagnoz )
    mdiagnoz[ i ] := PadR( mdiagnoz[ i ], 6 )
    find ( mdiagnoz[ i ] )
    If Found()
      If !Between( human->ishod, 101, 305 ) .and. i == 1 .and. !between_date( mkb_10->dbegin, mkb_10->dend, human->k_data )
        AAdd( ta, 'основной диагноз не входит в ОМС' )
      Endif
      If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
        AAdd( ta, 'несовместимость диагноза по полу ' + AllTrim( mdiagnoz[ i ] ) )
      Endif
    Else
      AAdd( ta, 'не найден диагноз ' + AllTrim( mdiagnoz[ i ] ) + ' в справочнике МКБ-10' )
    Endif
  Next
  mdiagnoz3 := {}
  If !Empty( human_2->OSL1 )
    AAdd( mdiagnoz3, human_2->OSL1 )
  Endif
  If !Empty( human_2->OSL2 )
    AAdd( mdiagnoz3, human_2->OSL2 )
  Endif
  If !Empty( human_2->OSL3 )
    AAdd( mdiagnoz3, human_2->OSL3 )
  Endif
  ar := {}
  Select MKB_10
  For i := 1 To Len( mdiagnoz3 )
    If Left( mdiagnoz3[ i ], 3 ) == 'R52'
      AAdd( ar, i )
    Endif
    mdiagnoz3[ i ] := PadR( mdiagnoz3[ i ], 6 )
    find ( mdiagnoz3[ i ] )
    If Found()
      If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
        AAdd( ta, 'несовместимость диагноза по полу ' + AllTrim( mdiagnoz3[ i ] ) )
      Endif
    Else
      AAdd( ta, 'не найден диагноз ' + AllTrim( mdiagnoz3[ i ] ) + ' в справочнике МКБ-10' )
    Endif
  Next
  If human_->USL_OK == USL_OK_HOSPITAL ; // 1 - стационар
    .and. ( AScan( mdiagnoz, {| x| Left( x, 3 ) == 'P07' } ) > 0 .or. AScan( mdiagnoz3, {| x| Left( x, 3 ) == 'P07' } ) > 0 ) ;
      .and. mvozrast == 0 .and. human_2->VNR == 0
    AAdd( ta, 'для диагноза P07.* не указан вес недоношенного (маловесного) ребёнка' )
  Endif
  If mvozrast > 0 .and. l_mdiagnoz_fill .and. Left( mdiagnoz[ 1 ], 1 ) == 'P'
    AAdd( ta, 'для основного диагноза ' + mdiagnoz[ 1 ] + ' возраст должен быть меньше года' )
  Endif
  If l_mdiagnoz_fill .and. human_->USL_OK == USL_OK_HOSPITAL ; // 1 - стационар
    .and. ( mdiagnoz[ 1 ] = 'U07.1' .or. mdiagnoz[ 1 ] = 'U07.2' ) ;  // проверим что диагноз COVID-19
    .and. Empty( HUMAN_2->PC4 ) ;                                 // вес отсутствует
      .and. ( count_years( human->DATE_R, human->k_data ) >= 18 ) ;   // проверим что возраст больше 18 лет
    .and. !check_diag_pregant()   // проверим, что не беременна
    AAdd( ta, 'для диагноза U07.1 или U07.2 для условий стационара не указан вес пациента' )
  Endif
  If !Empty( HUMAN_2->PC4 ) .and. Val( HUMAN_2->PC4 ) < 0.3
    AAdd( ta, 'вес пациента не может быть меньше 300 грамм' )
  Endif
  //
  //
  // ПРОВЕРЯЕМ УДОСТОВЕРЕНИЕ ЛИЧНОСТИ ПРИ ОТСУТСТВИИ ЕНП И ПРИКРЕПЛЕНИЕ
  //
  if Empty( AllTrim( human->MO_PR ) ) .and. AllTrim( human_->smo ) != '34'
    AAdd( ta, 'пустое значение поля "МО прикрепления" в листе учета' )
  else
    a_mo_prik := get_f032_prik()
    if ( i := AScan( a_mo_prik, {| x | x[ 2 ] == human->MO_PR } ) ) == 0
      AAdd( ta, 'не верная организация прикрепления с кодом "' + human->MO_PR + '"' )
    endif
  endif

  if ! ( lKart2 := aliasIsAlreadyUse( 'KART2' ) )
    r_use( dir_server() + 'kartote2', , 'KART2' )
  endif
  Goto ( human->kod_k )

  if ( Len( AllTrim( kart2->kod_mis ) ) == 16 ) .and. ( human_->vpolis != 3 )
    kart_->( g_rlock( 'forever' ) )
    kart_->VPOLIS := 3    // новый
    kart_->SPOLIS := ''
    Kart_->NPOLIS := AllTrim( kart2->kod_mis )
    kart_->( dbUnlock() )
    human_->( g_rlock( 'forever' ) )
    human_->VPOLIS := 3    // новый
    human_->SPOLIS := ''
    human_->NPOLIS := AllTrim( kart2->kod_mis )
    human_->( dbUnlock() )
  endif

  if ! ( ( human_->vpolis == 3 ) .and. ( Len( AllTrim( human_->npolis ) ) == 16 ) )
//  if ( human_->vpolis != 3 ) .and. Empty( kart2->kod_mis ) .or. ( Len( AllTrim( kart2->kod_mis ) ) != 16 )

    If ( human_->usl_ok != USL_OK_AMBULANCE ) .and. ;
        eq_any( kart_->vid_ud, 3, 14 ) .and. ;
        ! Empty( kart_->ser_ud ) .and. Empty( del_spec_symbol( kart_->mesto_r ) )
      AAdd( ta, iif( kart_->vid_ud == 3, 'для свид-ва о рождении', 'для паспорта РФ' ) + ;
        ' обязательно заполнение поля "Место рождения"' )
    Endif

    If AScan( getvidud(), {| x | x[ 2 ] == kart_->vid_ud } ) == 0
      AAdd( ta, 'не заполнено поле "ВИД удостоверения личности"' )
    endif
    If eq_any( kart_->vid_ud, 1, 3, 14 ) .and. Empty( kart_->ser_ud )
      AAdd( ta, 'не заполнено поле "СЕРИЯ удостоверения личности" для "' + ;
        inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + '"' )
    Endif
    If Empty( kart_->nom_ud )
      AAdd( ta, 'должно быть заполнено поле "НОМЕР удостоверения личности" для "' + ;
        inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + '"' )
    Endif
    If Empty( kart_->kogdavyd )
      AAdd( ta, 'для пацентов без нового полиса обязательно заполнение поля "Дата выдачи документа, удостоверяющего личность"' )
    Endif
    if ! Empty( kart_->kogdavyd ) .and. ;
        ( Year( kart_->kogdavyd ) < LIMITED_DATE_MIN .or. Year( kart_->kogdavyd ) > LIMITED_DATE_MAX )
      AAdd( ta, 'дата выдачи документа удостоверяющего личность должна быть между ' ;
        + str( LIMITED_DATE_MIN, 4 ) + ' и ' + str( LIMITED_DATE_MAX, 4 ) + ' годом' )
    endif
    If Empty( kart_->kemvyd ) .or. ;
        Empty( del_spec_symbol( inieditspr( A__POPUPMENU, dir_server() + 's_kemvyd', kart_->kemvyd ) ) )
      AAdd( ta, 'для пациентов без нового полиса обязательно заполнение поля "Наименование органа, выдавшего документ, удостоверяющий личность"' )
    Endif
  endif
  
  if ! lKart2
    kart2->( dbCloseArea() )
  endif

/*
  If AScan( getvidud(), {| x | x[ 2 ] == kart_->vid_ud } ) == 0
    If human_->vpolis < 3
      AAdd( ta, 'не заполнено поле "ВИД удостоверения личности"' )
    Endif
  Else
    If Empty( kart_->nom_ud )
      If human_->vpolis < 3
        AAdd( ta, 'должно быть заполнено поле "НОМЕР удостоверения личности" для "' + ;
          inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + '"' )
      Endif
    Endif
    If !Empty( kart_->nom_ud )
      s := Space( 80 )
      If !val_ud_nom( 2, kart_->vid_ud, kart_->nom_ud, @s )
        AAdd( ta, s )
      Endif
    Endif
    If eq_any( kart_->vid_ud, 1, 3, 14 ) .and. Empty( kart_->ser_ud )
      AAdd( ta, 'не заполнено поле "СЕРИЯ удостоверения личности" для "' + ;
        inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + '"' )
    Endif
    If human_->usl_ok < USL_OK_AMBULANCE .and. eq_any( kart_->vid_ud, 3, 14 ) .and. ;
        !Empty( kart_->ser_ud ) .and. Empty( del_spec_symbol( kart_->mesto_r ) ) .and. human_->vpolis < 3
      AAdd( ta, iif( kart_->vid_ud == 3, 'для свид-ва о рождении', 'для паспорта РФ' ) + ;
        ' обязательно заполнение поля "Место рождения"' )
    Endif
    If !Empty( kart_->ser_ud )
      s := Space( 80 )
      If !val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud, @s )
        AAdd( ta, s )
      Endif
    Endif
    if ! Empty( kart_->kogdavyd ) .and. ;
        ( Year( kart_->kogdavyd ) < LIMITED_DATE_MIN .or. Year( kart_->kogdavyd ) > LIMITED_DATE_MAX )
      AAdd( ta, 'дата выдачи документа удостоверяющего личность должна быть между ' ;
        + str( LIMITED_DATE_MIN, 4 ) + ' и ' + str( LIMITED_DATE_MAX, 4 ) + ' годом' )
    endif
//    If human_->usl_ok < USL_OK_AMBULANCE .and. human_->vpolis < 3 .and. !eq_any( Left( human_->OKATO, 2 ), '  ', '18' ) // иногородние
    If human_->vpolis < 3
      If Empty( kart_->kogdavyd )
        AAdd( ta, 'для пацентов без нового полиса обязательно заполнение поля "Дата выдачи документа, удостоверяющего личность"' )
      Endif
      If Empty( kart_->kemvyd ) .or. ;
          Empty( del_spec_symbol( inieditspr( A__POPUPMENU, dir_server() + 's_kemvyd', kart_->kemvyd ) ) )
        AAdd( ta, 'для пациентов без нового полиса обязательно заполнение поля "Наименование органа, выдавшего документ, удостоверяющий личность"' )
      Endif
    Endif
  Endif
*/
  val_fio( retfamimot( 2, .f. ), ta )

//  Select HUMAN
//  Set Order To 1
//  dbGoto( rec_human )
//  g_rlock( forever )
  human_->( g_rlock( forever ) )
  human_2->( g_rlock( forever ) )

  //
  // Проверим ОКАТО пребывания и СМО
  //
  kart_->( g_rlock( forever ) )
  s := AllTrim( kart_->okatog )
  If mo_nodigit( s )
    AAdd( ta, 'нецифровые символы в ОКАТО регистрации' )
  Endif
  If Len( s ) == 0
    If human_->vpolis < 3
      AAdd( ta, 'не заполнен код ОКАТО в поле "Адрес регистрации"' )
    Endif
  Elseif Len( s ) > 0 .and. Len( s ) < 11
    kart_->okatog := PadR( s, 11, '0' )
  Endif
  s := AllTrim( kart_->okatop )
  If mo_nodigit( s )
    AAdd( ta, 'нецифровые символы в ОКАТО пребывания' )
  Endif
  If Len( s ) > 0 .and. Len( s ) < 11
    kart_->okatop := PadR( s, 11, '0' )
  Endif
  If !Empty( kart->snils )
    s := Space( 80 )
    If !val_snils( kart->snils, 2, @s )
      AAdd( ta, s + ' у пациента' )
    Endif
  Endif
  human_->SPOLIS := val_polis( human_->SPOLIS )
  human_->NPOLIS := val_polis( human_->NPOLIS )
//  valid_sn_polis( human_->vpolis, human_->SPOLIS, human_->NPOLIS, ta, Between( human_->smo, '34001', '34007' ) )
  //
  If Select( 'SMO' ) == 0
    r_use( dir_exe() + '_mo_smo', cur_dir() + '_mo_smo2', 'SMO' )
    // index on smo to (sbase+ '2')
  Endif
  Select SMO
  If AllTrim( human_->smo ) == '34'
    If Empty( human_->OKATO )
      AAdd( ta, 'не введён субъект РФ, в котором застрахован пациент' )
    Elseif Empty( ret_inogsmo_name( 2 ) )
      AAdd( ta, 'не введена иногородняя страховая компания' )
    Endif
  Else
    Select SMO
    find ( human_->smo )
    If Found()
      human_->OKATO := smo->okato
    Else
      AAdd( ta, 'не найдена СМО с кодом "' + human_->smo + '"' )
    Endif
  Endif
  
  gnot_disp := ( human->ishod < 100 )
  gkod_diag := human->kod_diag
  gusl_ok := human_->usl_ok
  
  Private is_disp_19 := !( dEnd < 0d20190501 )
  Private is_disp_21 := !( dEnd < 0d20210101 )
  Private is_disp_24 := !( dEnd < 0d20240901 )

  If human_->usl_ok == USL_OK_POLYCLINIC
    if Empty( human->MOP )
      AAdd( ta, 'не заполнено "Место обращения (посещения)"' )
    Endif
  endif

  arrUslugi := collect_uslugi( rec_human )   // выберем все коды услуг случая

  lTypeLUMedReab := ( otd->tiplu == TIP_LU_MED_REAB )
  lTypeLUOnkoDisp := ( otd->tiplu == TIP_LU_ONKO_DISP )

  If ! lTypeLUOnkoDisp
    is_oncology := f_is_oncology( 1, @is_oncology_smp )
  Endif
  //

  reserveKSG_1 := exist_reserve_ksg( human->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) )

  lal := create_name_alias( 'lusl', yearEnd )
  lalf := create_name_alias( 'luslf', yearEnd )
  //
  If gusl_ok == USL_OK_AMBULANCE // 4 - если 'скорая помощь'
    Select HUMAN
    Set Order To 3
    find ( DToS( dEnd ) + cuch_doc )
    Do While human->k_data == dEnd .and. cuch_doc == human->uch_doc .and. !Eof()
      fl := human_->usl_ok == USL_OK_AMBULANCE .and. glob_kartotek == human->kod_k .and. rec_human != human->( RecNo() )
      If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
        fl := .f. // лист учёта снят по акту или выставлен повторно
      Endif
      If fl
        AAdd( ta, '"' + AllTrim( cuch_doc ) + '" повтор № карты вызова от ' + ;
          date_8( human->k_data ) + ' ' + AllTrim( human->fio ) )
      Endif
      Skip
    Enddo
  Endif
  // просмотр других случаев данного больного
  Select HUMAN
  Set Order To 2
  find ( Str( glob_kartotek, 7 ) )
  Do While human->kod_k == glob_kartotek .and. !Eof()
    fl := ( rec_human != human->( RecNo() ) .and. Year( human->k_data ) > 2019 ) // прошлый год не смотрим вообще
    If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
      fl := .f. // лист учёта снят по акту (и выставлен повторно)
    Endif
    If fl .and. m1novor != human_->NOVOR
      fl := .f. // лист учёта на новорожденного (или наоборот)
    Endif
    If fl .and. gnot_disp .and. human->ishod < 100 ; // если не диспансеризация
      .and. gusl_ok == human_->usl_ok ; // если те же условия оказания помощи
      .and. !Empty( gkod_diag ) .and. Left( gkod_diag, 3 ) == Left( human->kod_diag, 3 )  // тот же основной диагноз
      If ( k := dBegin - human->k_data ) >= 0 // и случай оказан раньше проверяемого
        If gusl_ok == USL_OK_AMBULANCE  // 4 - скорая помощь
          If k < 2
            AAdd( a_rec_ffoms, { human->( RecNo() ), 0, k } )
          Endif
        Else // поликлиника, круглосуточный и дневной стационар
          If k < 31 // в течение 30 дней
            AAdd( a_rec_ffoms, { human->( RecNo() ), 0, k } )
          Endif
        Endif
      Endif
    Endif
    // если диапазон лечения перекрывается в стационаре и дневном стационаре
    If fl .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )

      reserveKSG_2 := exist_reserve_ksg( human->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) )

      fl1 := ( Left( DToS( human->k_data ), 6 ) == ym2 )   // один и тот же месяц окончания лечения
      fl2 := overlap_diapazon( human->n_data, human->k_data, dBegin, dEnd ) // перекрывается диапазон лечения
      fl3 := .t.
      k := 0
      If is_alldializ() .and. ( fl1 .or. fl2 ) .and. Year( human->k_data ) > 2018 // прошлый год не смотрим вообще
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If Left( lshifr, 5 ) == '60.3.' .or. Left( lshifr, 6 ) == '60.10.' // диализ
              If human_->USL_OK == USL_OK_DAY_HOSPITAL  // 2 - диализ в дневном стационаре
                fl3 := .f.
                If fl1
                  k := 2
                Endif
              Elseif fl2 // диализ в стационаре
                k := 1
              Endif
              Exit
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If k > 1
          AAdd( a_dializ, { human->n_data, human->k_data, human_->USL_OK, human->OTD, k } ) // диализы не в кругл.стационаре
        Endif
      Endif
      If k < 2 .and. fl2 .and. fl3 .and. iif( is_alldializ(), Year( human->k_data ) > 2018, .t. ) .and. ! ( reserveKSG_1 .or. reserveKSG_2 ) // с учетом возможных вложенных двойных случаев
        AAdd( a_srok_lech, { human->n_data, human->k_data, human_->USL_OK, human->OTD, k } )
      Endif
    Endif
    // если диапазон лечения частично перекрывается
    If fl .and. human->n_data <= dEnd .and. dBegin <= human->k_data
      is_period_amb := .f.
      // стационар
      If human_->USL_OK == USL_OK_HOSPITAL  // 1
        AAdd( a_period_stac, { human->n_data, ;
          human->k_data, ;
          human_->USL_OK, ;
          human->OTD, ;
          human->kod_diag, ;
          human_->profil, ;
          human_->RSLT_NEW, ;
          human_->ISHOD_NEW, ;
          k } )
        // поликлиника
      Elseif human_->USL_OK == USL_OK_POLYCLINIC .and. human->ishod < 101 ;
          .and. !( human_->profil == 60 .and. glob_mo[ _MO_KOD_TFOMS ] == '103001' ) // не онкология
        is_period_amb := .t.
      Endif
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        // если услуга в том же диапазоне лечения
        If Between( hu->date_u, cd1, cd2 )
          AAdd( u_other, { hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0, human->n_data, human->k_data, human->OTD } )
        Endif
        If is_period_amb
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If eq_any( Left( lshifr, 5 ), '2.80.', '2.82.', '60.4.', '60.5.', '60.6.', '60.7.', '60.8.', '60.9.' )
              is_period_amb := .f.
              Exit
            Elseif eq_any( lshifr, '60.3.1', '60.3.12', '60.3.13' )  // 04.12.22
              AAdd( a_dializ, { human->n_data, human->k_data, human_->USL_OK, human->OTD, 3 } ) // диализы не в кругл.стационаре
              Exit
            Endif
            if eq_any( lshifr, '2.92.1', '2.92.2', '2.92.3' ) .or. ;
                eq_any( lshifr, '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.8', '2.92.9', '2.92.10', '2.92.11', '2.92.12', '2.92.13' )
              is_2_92_ := .t.
            endif
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If is_period_amb
        AAdd( a_period_amb, { human->n_data, human->k_data, human_->profil, human->OTD, human->( RecNo() ), is_2_92_ } )
        is_2_92_ := .f.
      Endif
      Select MOHU
      find ( Str( human->kod, 7 ) )
      Do While mohu->kod == human->kod .and. !Eof()
        If Between( mohu->date_u, cd1, cd2 ) // услуга в том же диапазоне лечения
          AAdd( u_other, { mohu->u_kod, mohu->date_u, mohu->kol_1, mohu->profil, 1 } )
        Endif
        Skip
      Enddo
    Endif
    // диспансеризация/профилактика взрослого населения
    If fl .and. Between( human->ishod, 201, 205 )
      // если год начала текущего лечения = году начала прошлого лечения
      If Year( human->n_data ) == Year( dBegin ) // для диспансеризации
        AAdd( a_disp, { human->ishod - 200, human->n_data, human->k_data, human_->RSLT_NEW } )
      Endif
      // для профилактики
      If human->ishod == 203 .and. count_years( human->date_r, human->n_data ) == mvozrast
        AAdd( a_disp, { human->ishod - 200, human->n_data, human->k_data, human_->RSLT_NEW } )
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Select HUMAN
  Set Order To 1
  dbGoto( rec_human )
  g_rlock( forever )
  human_->( g_rlock( forever ) )
  human_2->( g_rlock( forever ) )
//  uch->( dbGoto( human->LPU ) )
//  otd->( dbGoto( human->OTD ) )

  If Year( human->k_data ) == 2022 .and. !Empty( HUMAN_2->PC1 )
    If AllTrim( human_2->PC1 ) == '2' // КСЛП 2 - место законному представителю для 2022 года
      If human_->PROFIL != 12 .and. human_->PROFIL != 18  // допустимо для профилей 'гематология' и 'деткская онкология'
        AAdd( ta, 'для выбранного КСЛП = 2, профиль оказания услуг должен быть или "гематология" или "детская онкология"' )
      Endif
    Endif
  Endif

  If Year( human->k_data ) == 2022 .and. !Empty( HUMAN_2->PC1 )
    If AllTrim( human_2->PC1 ) == '3' // КСЛП 3 - старше 75 лет для 2022 года
      For Each row in arr_uslugi_geriatr
        If AScan( arrUslugi, row ) > 0 // проверим все услуги случая
          flGeriatr := .t.
        Endif
      Next
      If !flGeriatr
        AAdd( ta, 'для выбранного КСЛП = 3, в списке услуг для случая необходимо наличие одной из услуг B01.007.001, B01.007.002 или B01.007.003' )
      Endif
    Endif
  Endif

  s := ''
  If l_mdiagnoz_fill .and. f_oms_beremenn( mdiagnoz[ 1 ], human->k_data ) == 3 .and. Between( human_2->pn2, 1, 4 )
    s := 'R52.' + { '0', '1', '2', '9' }[ human_2->pn2 ]
  Endif
  If !emptyall( s, ar )
    If Empty( ar )
      human_2->OSL3 := s
    Else
      fl := .t.
      For i := 3 To 1 Step -1
        pole := 'human_2->OSL' + lstr( i )
        If Left( &pole, 3 ) == 'R52'
          If fl
            fl := .f.
            If !( AllTrim( pole ) == s )
              &pole := s  // самый последний - перезапишем
            Endif
          Else
            &pole := ''   // остальные - очистим
          Endif
        Endif
      Next
    Endif
  Endif

  //
  d := human->k_data - human->n_data
  adiag := {}
  kkd := kds := kvp := kuet := kkt := ksmp := 0
  mpztip := mpzkol := kol_uet := 0
  kkd_1_11 := kkd_1_12 := kol_ksg := 0
  is_reabil := is_dializ := is_perito := is_s_dializ := is_eko := fl_stom := fl_dop_ob_em := .f.
  If is_dop_ob_em()
    fl_dop_ob_em := ( human->reg_lech == 9 )
  Endif
  au_lu := {} ; au_flu := {} ; au_lu_ne := {} ; arr_perso := {} ; arr_unit := {}
  arr_onkna := {} ; arr_mo_spec := {}
  m1dopo_na := m1napr_v_mo := m1napr_stac := m1profil_stac := m1napr_reab := m1profil_kojki := 0

  m1sank_na := 0
  mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  is_kt := is_mrt := is_uzi := is_endo := is_gisto := is_mgi := is_g_cit := is_pr_skr := is_covid := .f.
  is_71_1 := is_71_2 := is_71_3 := is_dom := .f.
  kvp_2_78 := kvp_2_79 := kvp_2_89 := kol_2_3 := kol_2_60 := kol_2_4 := kol_2_6 := kol_55_1 := 0
  kvp_70_5 := kvp_70_6 := kvp_70_3 := kvp_72_2 := kvp_72_3 := kvp_72_4 := 0
  is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f.
  is_2_83 := is_2_84 := is_2_85 := is_2_86 := is_2_87 := is_2_88 := is_2_89 := is_2_94 := .f.
  a_2_89 := Array( 15 )
  AFill( a_2_89, 0 )
  is_disp_DDS := is_disp_DVN := is_disp_DVN3 := is_prof_PN := is_neonat := is_pren_diagn := .f.

  is_disp_DVN_COVID := .f.
  is_disp_DRZ := .f.
  is_exist_Prescription := .f.  // имеется блок направлений для диспансеризаций

  is_70_3 := is_70_5 := is_70_6 := is_72_2 := is_72_3 := is_72_4 := .f.
  lstkol := 0 ; lstshifr := shifr_ksg := '' ; cena_ksg := 0
  midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := m1lis := 0
  lvidpoms := ''
  // реабилитация - для физкультурного диспансера и других
  arr_lfk := { '3.1.5', '3.1.19', '3.4.31', ;
    '4.2.153', '4.11.136', ;
    '7.12.5', '7.12.6', '7.12.7', '7.2.2', ;
    '13.1.1', ;
    '14.2.3', ;
    '16.1.17', '16.1.18', ;
    '19.1.1', '19.1.2', '19.1.3', '19.1.5', '19.1.6', '19.1.7', '19.1.9', '19.1.11', '19.1.12', '19.1.29', '19.1.30', '19.1.31', '19.1.32', '19.1.33', '19.1.34', '19.1.35', '19.1.36', '19.1.37', '19.1.38', ;
    '19.2.1', '19.2.2', '19.2.4', '19.2.5', '19.3.1', '19.5.1', '19.5.2', '19.5.19', '19.6.1', '19.6.2', '19.7.1', ;
    '19.3.1', ;
    '20.1.1', '20.1.2', '20.1.3', '20.1.4', '20.1.5', '20.1.6', '20.2.1', '20.2.2', '20.2.3', '20.2.4', ;
    '21.1.1', '21.1.2', '21.1.3', '21.1.4', '21.1.5', '21.2.1', ;
    '22.1.1', '22.1.2', '22.1.3' }
  //
  f_put_glob_podr( human_->USL_OK, dEnd, ta ) // заполнить код подразделения
  musl_ok := USL_OK_POLYCLINIC  // 3 - п-ка по умолчанию
  ldnej := 0
  pr_amb_reab := .f.
  If human_->USL_OK < USL_OK_AMBULANCE  // не скорая помощь
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        If eq_any( Left( lshifr, 5 ), '1.11.', '55.1.' )
          ldnej += hu->kol_1
        Elseif Left( lshifr, 5 ) == '2.89.'
          pr_amb_reab := .t.
        Endif
      Endif
      Select HU
      Skip
    Enddo
  Endif
  // проверим не этап ли это углубленной диспансеризации после COVID
  If is_sluch_dispanser_COVID( human->ishod )
    is_disp_DVN_COVID := .t.
    is_exist_Prescription := .t.
  Endif

  // проверим не этап ли это диспансеризации репродуктивного здоровья
  If is_sluch_dispanser_DRZ( human->ishod )
    is_disp_DRZ := .t.
    is_exist_Prescription := .t.
  Endif

  d_sroks := ''

  Select HU
  hu->( dbSeek( Str( human->kod, 7 ) ) )  //   find ( Str( human->kod, 7 ) )
  If ! hu->( Found() )
    ft:add_string( header_error, FILE_CENTER, ' ', .t. )
    AAdd( ta, 'для случая отсутствует список оказанных услуг' )
    For i := 1 To Len( ta )
      For j := 1 To perenos( t_arr, ta[ i ], 78 )
        If j == 1
          ft:add_string( iif( i == 1, ' ', '- ' ) + t_arr[ j ] )
        Else
//          add_string( PadL( AllTrim( t_arr[ j ] ), 80 ) )
          ft:add_string( AllTrim( t_arr[ j ] ), FILE_LEFT )
        Endif
      Next
    Next
    Return .f.
  Endif

  if ! eq_any( lu_type, TIP_LU_DDS, TIP_LU_DVN, TIP_LU_DDSOP, TIP_LU_PN, TIP_LU_PREDN, TIP_LU_PERN, TIP_LU_DVN_COVID, TIP_LU_DRZ )
    if Empty( human->PROFIL_M ) .and. ( ( iProfil_m := soot_v002_m003( human_->PROFIL, human->VZROS_REB ) ) > 0 )
        AAdd( ta, 'не заполнено поле "Профиль МЗ РФ" для листа учета' )
    endif
  endif
 
  lshifr := ''
  lshifr1 := ''
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, @auet, @lbukva, @lst, @lidsp, @s )
      If Empty( hu->kol_1 )
        AAdd( ta, 'не заполнено поле "Количество услуг" для "' + AllTrim( usl->shifr ) + '"' )
      Endif

      if ! eq_any( lu_type, TIP_LU_DDS, TIP_LU_DVN, TIP_LU_DDSOP, TIP_LU_PN, TIP_LU_PREDN, TIP_LU_PERN, TIP_LU_DVN_COVID, TIP_LU_DRZ )
        if Empty( human->PROFIL_M ) .and. ( ( iProfil_m := soot_v002_m003( human_->PROFIL, human->VZROS_REB ) ) > 0 )
          AAdd( ta, 'не заполнено поле "Профиль МЗ РФ" для услуги "' + AllTrim( usl->shifr ) + '"' )
        endif
      endif

      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If hu->STOIM_1 > 0 .or. lTypeLUOnkoDisp .or. Left( lshifr, 3 ) == '71.'  // скорая помощь
        If !Empty( lbukva ) .and. AScan( a_bukva, {| x| x[ 1 ] == lbukva } ) == 0
          AAdd( a_bukva, { lbukva, lshifr } )
        Endif
        If !Empty( lidsp ) .and. AScan( a_idsp, {| x| x[ 1 ] == lidsp } ) == 0
          AAdd( a_idsp, { lidsp, lshifr } )
        Endif
      Endif
      If lst == 1
        k := 0 ; lstshifr := '' ; lstkol := hu->kol_1
        For i := 1 To Len( lshifr )
          If !Empty( c := SubStr( lshifr, i, 1 ) )
            lstshifr += c
            If c == '.' ; ++k ; Endif
            If k == 2 ; exit ; Endif // две точки в шифре услуги
          Endif
        Next
      Endif
      otd->( dbGoto( hu->OTD ) )
      // проверка отделения для услуги
      if Empty( otd->LPU_1 )
        AAdd( ta, 'для отделения ' + AllTrim( otd->short_name ) + ', где оказана услуга ' + AllTrim( lshifr ) + ' не выбрано "Структурное подразделение по ФФОМС"' )
      endif
      hu->( g_rlock( forever ) )
      hu_->( g_rlock( forever ) )
      If hu->is_edit == -1 .and. AllTrim( lshifr ) == '4.27.2'
        hu->is_edit := 0 // исправление начальной ошибки
      Elseif hu->is_edit == 0 .and. is_lab_usluga( lshifr )
        hu->is_edit := -1
        hu->kod_vr := hu->kod_as := 0
        lprofil := iif( Left( lshifr, 5 ) == '4.16.', 6, 34 )
        If Select( 'MOPROF' ) == 0
          r_use( dir_exe() + '_mo_prof', cur_dir() + '_mo_prof', 'MOPROF' )
          // index on shifr+ str(vzros_reb, 1) + str(profil, 3) to (sbase)
        Endif
        Select MOPROF
        find ( PadR( lshifr, 20 ) + Str( iif( human->vzros_reb == 0, 0, 1 ), 1 ) )
        If Found()
          lprofil := moprof->profil
        Endif
        hu_->profil := lprofil
      Endif
      If Left( lshifr, 5 ) == '60.8.' .and. ! is_volgamedlab()
        hu_->profil := 15   // гистология за исключение "Волгамедлаб"
        mprvs := hu_->PRVS := -13 // Клиническая лабораторная диагностика
      Elseif Empty( hu->kod_vr )
        If eq_any( AllTrim( lshifr ), '4.20.2' )
          // не заполняется код врача
        Elseif pr_amb_reab .and. Left( lshifr, 2 ) == '4.' .and. ( Left( hu_->zf, 6 ) == '999999' .or. Left( hu_->zf, 6 ) != glob_mo[ _MO_KOD_TFOMS ] )
          // не заполняется код врача
        Elseif hu->is_edit == -1
          If human_->USL_OK == USL_OK_POLYCLINIC
            hu_->PRVS := iif( hu_->profil == 34, -13, -54 )
          Else
            AAdd( ta, 'лабораторная услуга "' + AllTrim( usl->shifr ) + '" может быть оказана только в поликлинике' )
          Endif
        Elseif hu->is_edit == 0 .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // исправлено для углубленной диспансеризации и ДРЗ
          AAdd( ta, 'не заполнено поле "Врач, оказавший услугу ' + AllTrim( usl->shifr ) + '"' )
        Endif
      Else
        If Empty( mvrach ) .and. !( AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) )
          mvrach := hu->kod_vr
        Endif
        pers->( dbGoto( hu->kod_vr ) )
        mprvs := -ret_new_spec( pers->prvs, pers->prvs_new )
        If Empty( mprvs ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // исправлено для углубленной диспансеризации и ДРЗ
          AAdd( ta, 'нет специальности в справочнике персонала у "' + AllTrim( pers->fio ) + '"' )
        Elseif hu_->PRVS != mprvs
          hu_->PRVS := mprvs
        Endif
        If hu_->PRVS > 0 .and. ret_v004_v015( hu_->PRVS ) == 0
          AAdd( ta, 'не найдено специальности в справочнике V015 у "' + AllTrim( pers->fio ) + '"' )
        Endif
        If AllTrim( lshifr ) == '1.11.1' .and. human_->profil == 28 .and. human_2->profil_k == 24
          // профиль 'инфекционные болезни' и профиль койки 'инфекционные'
        Else // проверяем на специальность
          uslugaaccordanceprvs( lshifr, human->vzros_reb, hu_->prvs, ta, usl->shifr, hu->kod_vr )
        Endif
      Endif
      If Empty( mprofil )
        mprofil := usl->profil
        If Empty( mprofil )
          mprofil := hu_->profil
        Endif
      Endif
      If Empty( hu_->profil )
        hu_->profil := usl->profil
        If Empty( hu_->profil )
          hu_->profil := otd->profil
        Endif
      Endif
      If hu_->profil > 0 .and. hu_->profil != correct_profil( hu_->profil )
        hu_->profil := correct_profil( hu_->profil )
      Endif
      If !valid_guid( hu_->ID_U )
        hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
      Endif
      mdate := c4tod( hu->date_u )

      If !Empty( hu->kod_vr ) .and. mdate >= human->n_data
        arr_perso := addkoddoctortoarray( arr_perso, hu->kod_vr )
      Endif

      mdate_u1 := dtoc4( human->n_data )
      mdate_u2 := hu->date_u
      alltrim_lshifr := AllTrim( lshifr )
      left_lshifr_2 := Left( lshifr, 2 )
      left_lshifr_3 := Left( lshifr, 3 )
      left_lshifr_4 := Left( lshifr, 4 )
      left_lshifr_5 := Left( lshifr, 5 )
      If hu->kol_1 > 1 .and. AScan( arr_lfk, alltrim_lshifr ) > 0
        mdate_u2 := dtoc4( mdate + hu->kol_1 - 1 )
      Endif
      // проверяем на профиль
      lprofil := uslugaaccordanceprofil( lshifr, human->vzros_reb, hu_->profil, ta, usl->shifr )
      If human_->USL_OK == USL_OK_AMBULANCE .and. lprofil != hu_->profil
        hu_->profil := lprofil
      Endif
      dbSelectArea( lal )
      find ( PadR( lshifr, 10 ) )
      If Found() .and. !Empty( &lal.->unit_code ) .and. AScan( arr_unit, &lal.->unit_code ) == 0
        if AllTrim( lshifr ) != '7.2.702' // временно
          AAdd( arr_unit, &lal.->unit_code )
        Endif
      Endif
      AAdd( au_lu, { lshifr, ;    // 1 шифр услуги
        mdate, ;                  // 2 дата предоставления
        hu_->profil, ;            // 3 профиль усдуги
        hu_->PRVS, ;              // 4 код специальности врача
        AllTrim( usl->shifr ), ;  // 5
        hu->kol_1, ;              // 6 количество предоставлений
        c4tod( mdate_u2 ), ;      // 7
        hu_->kod_diag, ;          // 8
        hu->( RecNo() ), ;        // 9 - номер записи
        hu->is_edit, ;            // 10
        hu_->date_end  } )        // 11 - дата окончания предоставления услуги
      kodKSG := ''
      If is_ksg( lshifr )
        If !Empty( s ) .and. ',' $ s
          lvidpoms := s
        Endif
        shifr_ksg := kodKSG := alltrim_lshifr
        cena_ksg := hu->u_cena
        If SubStr( kodKSG, 3, 2 ) == '37'
          is_reabil := .t.
        Elseif kodKSG == 'ds02.005'
          is_eko := .t.
        Endif
        kol_ksg += hu->kol_1
      Endif
      If !Empty( kodKSG ) // КСГ
        If Left( kodKSG, 2 ) == 'st'
          musl_ok := USL_OK_HOSPITAL  // 1 - стационар
          midsp := 33
        Else
          musl_ok := USL_OK_DAY_HOSPITAL  // 2 - дневной стационар
          midsp := 33
        Endif
        mdate_u2 := dtoc4( human->k_data )
      Elseif left_lshifr_2 == '1.'
        musl_ok := USL_OK_HOSPITAL  // 1 - стационар
        mdate_u2 := dtoc4( human->k_data )
        If left_lshifr_5 == '1.11.'
          kkd += hu->kol_1
          kkd_1_11 += hu->kol_1
          hu_->PZKOL := hu->kol_1
          If mdate + hu->kol_1 <= dEnd
            mdate_u2 := dtoc4( mdate + hu->kol_1 )
          Endif
        Else
          If left_lshifr_5 == code_services_vmp( yearEnd )
            midsp := 18 // Законченный случай в круглосуточном стационаре
            kkd_1_12 += hu->kol_1
            kol_ksg += hu->kol_1
            hu_->PZKOL := d
            If ! value_public_is_vmp( yearEnd )
              AAdd( ta, 'работа с услугой ' + alltrim_lshifr + ' запрещена в Вашей МО' )
            Endif
          Endif
        Endif
        hu_->PZTIP := 1
      Elseif left_lshifr_3 == '55.'
        musl_ok := USL_OK_DAY_HOSPITAL  // 2  // дн.стационар
        mdate_u2 := dtoc4( human->k_data )
        If left_lshifr_5 == '55.1.' // кол-во пациенто-дней
          kds += hu->kol_1
          kol_55_1 += hu->kol_1
          hu_->PZKOL := hu->kol_1
          If mdate + hu->kol_1 - 1 <= dEnd
            mdate_u2 := dtoc4( mdate + hu->kol_1 - 1 )
          Endif
        Else
          // ошибка
        Endif
        hu_->PZTIP := 2
      Elseif alltrim_lshifr == '56.1.723' .and. human->ishod == 202 .and. !is_disp_19 // второй этап ДВН - одна услуга
        is_disp_DVN := .t.
        is_exist_Prescription := .t.
      elseif eq_any( alltrim_lshifr, '7.2.706', '7.57.704', '7.61.704' ) // услуги с применением ИИ
        mpovod := 7 // 2.3-Комплексное обследование
        mIDPC := '2.3'
        mIDSP := 28 // за медицинскую услугу
      Elseif eq_any( left_lshifr_5, '60.4.', '60.5.', '60.6.', '60.7.', '60.8.', '60.9.' ) .or. ;
          eq_any( alltrim_lshifr, '4.20.702', '4.15.746' ) // ЛДП
        If alltrim_lshifr == '4.15.746' // пренатальный скрининг
          mpovod := 1 // 1.0-Посещение по заболеванию
          mIDPC := '1.0'
        Else
          mpovod := 7 // 2.3-Комплексное обследование
          mIDPC := '2.3'
        Endif
        mIDSP := 4 // лечебно-диагностическая процедура 
        kkt += hu->kol_1
        hu_->PZTIP := 5
        hu_->PZKOL := hu->kol_1
        musl_ok := USL_OK_POLYCLINIC  // 3 - п-ка
        If left_lshifr_5 == '60.4.'
          is_kt := .t.
        Elseif left_lshifr_5 == '60.5.'
          is_mrt := .t.
        Elseif left_lshifr_5 == '60.6.'
          is_uzi := .t.
        Elseif left_lshifr_5 == '60.7.'
          is_endo := .t.
        Elseif left_lshifr_5 == '60.8.'
          is_gisto := .t.
        Elseif left_lshifr_5 == '60.9.'
          is_mgi := .t.
          shifr_mgi := alltrim_lshifr
        Elseif alltrim_lshifr == '4.20.702'
          is_g_cit := .t.
        Elseif alltrim_lshifr == '4.15.746'
          is_pr_skr := .t.
        Endif
      Elseif left_lshifr_5 == '60.3.' .or. left_lshifr_5 == '60.10'// диализ
        mIDSP := 4 // лечебно-диагностическая процедура
        kkt += hu->kol_1
        hu_->PZTIP := 5
        hu_->PZKOL := hu->kol_1
        mdate_u2 := dtoc4( human->k_data )
        If eq_any( alltrim_lshifr, '60.3.1', '60.3.12', '60.3.13' )  // 04.12.22
          mpovod := 10 // 3.0
          mIDPC := '3.0'
          musl_ok := USL_OK_POLYCLINIC  // 3 - п-ка
          is_perito := .t.
        Elseif eq_any( alltrim_lshifr, '60.3.9', '60.3.10', '60.3.11' ) // 01.12.21
          musl_ok := USL_OK_DAY_HOSPITAL  // 2 - дневной стационар
          is_dializ := .t.
        ElseIf eq_any( alltrim_lshifr, '60.3.19', '60.3.20', '60.3.21' )  // 16.02.24
          mpovod := 10 // 3.0
          mIDPC := '3.0'
          musl_ok := USL_OK_POLYCLINIC  // 3 - п-ка
          is_dializ := .t.
        Else
          musl_ok := USL_OK_HOSPITAL  // 1 - стационар
          is_s_dializ := .t.
        Endif
      Elseif eq_any( left_lshifr_5, '71.1.', '71.2.', '71.3.' )  // скорая помощь
        musl_ok := USL_OK_AMBULANCE // 4 - СМП
        mIDSP := 24 // Вызов скорой медицинской помощи
        If left_lshifr_5 == '71.1.'
          is_71_1 := .t.
        Elseif left_lshifr_5 == '71.2.'
          is_71_2 := .t.
        Else
          is_71_3 := .t.
        Endif
        hu_->PZTIP := 6
        hu_->PZKOL := hu->kol_1
        ksmp += hu->kol_1
      Elseif left_lshifr_2 == '4.'
        If left_lshifr_5 == '4.26.'
          is_neonat := .t.
        Endif
        If alltrim_lshifr == '4.17.785' // Молекулярно-биологическое исследование мазков со слизистой оболочки носоглотки, ротоглотки и отделяемого верхних дыхательных путей на новый коронавирус COVID-19 (за исключением тест-систем)
          is_covid := .t.
        Endif
        If eq_any( hu->is_edit, 1, 2 ) .and. dBegin <= c4tod( mdate_u2 )
          m1lis := hu->is_edit
        Endif
      Else
        musl_ok := USL_OK_POLYCLINIC  // 3 - п-ка
        mIDSP := 1 // Посещение в поликлинике
        mpztip := 3
        mpzkol := hu->kol_1
        If hu->KOL_RCP < 0
          is_dom := .t.
        Endif
        If left_lshifr_4 == '2.3.'
          kol_2_3++
        Elseif left_lshifr_4 == '2.6.'
          kol_2_6++
        Elseif left_lshifr_5 == '2.60.'
          kol_2_60++
        Elseif eq_any( alltrim_lshifr, '2.4.1', '2.4.2' )
          kol_2_4++
        Elseif eq_any( alltrim_lshifr, '2.92.1', '2.92.2', '2.92.3' ) .or. ;
          eq_any( alltrim_lshifr, '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.8', '2.92.9', '2.92.10', '2.92.11', '2.92.12', '2.92.13' )
          shifr_2_92 := alltrim_lshifr
          is_2_92_ := .t.
          mpovod := 10 // 3.0
          mIDPC := '3.0'
          If vozrast >= 18 .and. alltrim_lshifr == '2.92.3'
            AAdd( ta, 'услуга 2.92.3 оказывается только детям или подросткам' )
          Elseif vozrast < 18 .and. eq_any( alltrim_lshifr, '2.92.1', '2.92.2' )
            AAdd( ta, 'услуга ' + alltrim_lshifr + ' оказывается только взрослым' )
          Endif
        Elseif alltrim_lshifr == '2.93.1'
          kol_2_93_1++
        Elseif alltrim_lshifr == '2.93.2'
          kol_2_93_2++
        Elseif left_lshifr_5 == '2.76.'
          mpovod := 7 // 2.3
          mIDPC := '2.3'
          mIDSP := 12 // Комплексная услуга центра здоровья
        Elseif left_lshifr_5 == '2.78.'
          mpovod := 10 // 3.0 обращение по заболеванию
          mIDPC := '3.0'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          If between_shifr( alltrim_lshifr, '2.78.54', '2.78.60' )
            fl_stom := .t.
            mpztip := 4
          Else
            ++kvp_2_78
            is_2_78 := .t.
            mIDSP := 17 // Законченный случай в поликлинике
            If eq_any( alltrim_lshifr, '2.78.90', '2.78.91' ) .and. Len( mdiagnoz ) > 0 .and. Left( mdiagnoz[ 1 ], 1 ) == 'Z'
              mpovod := 11 // 3.1 обращение с проф.целью
              mIDPC := '3.1'
            Elseif l_mdiagnoz_fill .and. ;
              ( ( alltrim_lshifr == '2.78.107' .and. ( human->k_data >= 0d20230101 ) ) .or. ;
              ( eq_any(alltrim_lshifr, '2.78.109', '2.78.110', '2.78.111', '2.78.112' ) .and. ( human->k_data >= 0d20240101 ) ) )
              // добавлена комплексная услуга 2.78.107 02.2023
              // добавлена услуги 2.78.109, 2.78.110, 2.78.111, 2.78.112 01.2024
              mpovod := 4 // 1.3
              mIDPC := '1.3'
              If ! check_diag_usl_disp_nabl( mdiagnoz[ 1 ], alltrim_lshifr, human->k_data ) //, .f. )
                AAdd( ta, 'в услуге ' + alltrim_lshifr + ' должен стоять допустимый диагноз для диспансерного наблюдения' )
              Endif
              if between_diag( mdiagnoz[ 1 ], ;
                  'E10.0', 'E10.9') .and. alltrim_lshifr == '2.78.111' .and. ;
                  human->k_data >= 0d20240426 // согласно письму 09-20-180 от 26.04.24
                AAdd( ta, 'для диагноза ' + alltrim( mdiagnoz[ 1 ] ) + ' следует использовать услуги 2.78.61-63, 2.78.68-69, 2.78.71, 2.78.80, 2.78.86 для диспансерного наблюдения' )
              endif
            Endif
          Endif
          mdate_u2 := dtoc4( human->k_data )
        Elseif left_lshifr_5 == '2.79.'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          If between_shifr( alltrim_lshifr, '2.79.44', '2.79.50' ) .or. eq_any( alltrim_lshifr, '2.79.79', '2.79.80' )
            mpovod := 8 // 2.5 - патронаж
            mIDPC := '2.5'
          Else
            mpovod := 9 // 2.6
            mIDPC := '2.6'
          Endif
          If between_shifr( alltrim_lshifr, '2.79.59', '2.79.64' )
            fl_stom := .t.
            mpztip := 4
          Else
            is_2_79 := .t.
            If alltrim_lshifr == '2.79.51'
              is_pren_diagn := .t.
            Else
              kvp_2_79++
            Endif
          Endif
        Elseif left_lshifr_5 == '2.80.'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          mpovod := 2 // 1.1
          mIDPC := '1.1'
          If between_shifr( alltrim_lshifr, '2.80.34', '2.80.38' )
            fl_stom := .t.
            mpztip := 4
          Else
            is_2_80 := .t.
          Endif
        Elseif left_lshifr_5 == '2.81.'
          mpovod := 1 // 1.0
          mIDPC := '1.0'
          is_2_81 := .t.
        Elseif left_lshifr_5 == '2.82.'
          If alltrim_lshifr == '2.82.10' .and. hu_->profil == 90
            AAdd( ta, 'для услуги 2.82.10 рекомедуется проставлять профиль "челюстно-лицевой хирургии"' )
          Endif
          mpovod := 2 // 1.1
          mIDPC := '1.1'
          is_2_82 := .t.
          mIDSP := 22 // Посещение в приёмном покое
        Elseif left_lshifr_5 == '2.83.'
          is_disp_DDS := .t.
          is_2_83 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.84.'
          mIDSP := 11 // диспансеризация
          is_disp_DVN := .t.
          is_2_84 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '7.80.'
          mIDSP := 30 // углубленная диспансеризация после COVID
          is_disp_DVN_COVID := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.9.'
          mIDSP := 30 // диспансеризация репродуктивного здоровья
          is_disp_DRZ := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.94.' // профилактика несовершеннолетних c 01.09.25
          is_prof_PN := .t.
          is_2_94 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.85.' // профилактика несовершеннолетних
          is_prof_PN := .t.
          is_2_85 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.87.'
          is_disp_DDS := .t.
          is_2_87 := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.88.'
          d_sroks := AfterAtNum( '.', alltrim_lshifr )
          mpovod := 1 // 1.0
          mIDPC := '1.0'
          If between_shifr( alltrim_lshifr, '2.88.46', '2.88.51' )
            fl_stom := .t.
            mpztip := 4
          Else
            is_2_88 := .t.
            If between_shifr( alltrim_lshifr, '2.88.111', '2.88.118' ) .and. ( human->k_data < 0d20220201 )
              If is_dom
                is_dom := .f. // чтобы для услуги с коронавирусом (на дому) не менять повод обращения
              Else
                AAdd( ta, 'услуга ' + alltrim_lshifr + ' может быть оказана только "на дому"' )
              Endif
            Endif
          Endif
        Elseif left_lshifr_5 == '2.89.'
          mpovod := 10 // 3.0
          mIDPC := '3.0'
          ++kvp_2_89
          is_2_89 := .t.
          i := 3
          k := Int( Val( AfterAtNum( '.', alltrim_lshifr ) ) )
          If     eq_any( k, 1, 13 )
            i := 1  // оп.двиг.аппарат
          Elseif eq_any( k, 3, 14 )
            i := 3  // сердечно-сосудистая патология
          Elseif eq_any( k, 4, 15 )
            i := 4  // центральная нервная система
          Elseif eq_any( k, 5, 16 )
            i := 5  // периферическая нервная система
          Elseif eq_any( k, 6, 17 )
            i := 6  // рак молочной железы
          Elseif eq_any( k, 7, 18 )
            i := 7  // рак женских половых органов
          Elseif eq_any( k, 8, 19 )
            i := 8  // урогенетальный рак
          Elseif eq_any( k, 9, 20 )
            i := 9  // колоректальный рак
          Elseif eq_any( k, 10, 21 )
            i := 10 // рак легких и бронхов
          Elseif eq_any( k, 11, 22 )
            i := 11 // опухоль головы и шеи
          Elseif eq_any( k, 12, 23 )
            i := 12 // опухоль пищевода, желудка
          Elseif k == 24
            i := 13 // 2.89.24 'Обращение с целью медицинской реабилитации пациентов при лечении органов дыхания, после COVID-19'
          Elseif k == 25
            i := 14 // 2.89.25 'Обращение с целью медицинской реабилитации пациентов при лечении органов дыхания'
          Elseif k == 26
            i := 15 // 2.89.26 'Обращение с целью медицинской реабилитации пациентов при лечении органов дыхания, после COVID-19 с исп-ем телемедицины'
          Endif
          a_2_89[ i ] := 1
          mdate_u2 := dtoc4( human->k_data )
        Elseif left_lshifr_5 == '2.90.'
          mIDSP := 11 // диспансеризация
          is_disp_DVN := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '7.80.'  // углубленная диспансеризация после COVID
          mIDSP := 30 // 'Код способа оплаты' '30 - за обращение (законченный случай)'
          is_disp_DVN_COVID := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.9.'  // диспансеризация репродуктивного здоровья
          mIDSP := 30 // 'Код способа оплаты' '30 - за обращение (законченный случай)'
          is_disp_DRZ := .t.
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '2.91.'
          mIDSP := 29 // за посещение в поликлинике
          is_prof_PN := .t.
          is_exist_Prescription := .t.
        Elseif eq_any( left_lshifr_5, '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' ) // диспансеризация взрослых
          is_disp_DVN := .t.
          is_exist_Prescription := .t.
          If eq_any( left_lshifr_5, '70.3.', '70.7.' )
            mIDSP := 11 // диспансеризация
          Else
            is_disp_DVN3 := .t.
            is_exist_Prescription := .t.
            mIDSP := 17 // Законченный случай в поликлинике
          Endif
          ++kvp_70_3
          is_70_3 := .t.
          mdate_u2 := dtoc4( human->k_data )
        Elseif left_lshifr_5 == '72.2.' // профилактика несовершеннолетних
          is_prof_PN := .t.
          ++kvp_72_2
          is_72_2 := .t.
          mdate_u2 := dtoc4( human->k_data )
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.5.' // диспансеризация детей-сирот
          is_disp_DDS := .t.
          mIDSP := 11 // диспансеризация
          ++kvp_70_5
          is_70_5 := .t.
          mdate_u2 := dtoc4( human->k_data )
          is_exist_Prescription := .t.
        Elseif left_lshifr_5 == '70.6.' // диспансеризация детей-сирот
          is_disp_DDS := .t.
          mIDSP := 11 // диспансеризация 
          tip_lu := iif( !Empty( human->ZA_SMO ), TIP_LU_DDS, TIP_LU_DDSOP )
          if ! ( dEnd >= 0d20250901 .and. ( tip_lu == TIP_LU_DDSOP .or. tip_lu == TIP_LU_DDS ) )
            ++kvp_70_6
          endif
          is_70_6 := .t.
          mdate_u2 := dtoc4( human->k_data )
          is_exist_Prescription := .t.
        Endif
        If is_usluga_disp_nabl( alltrim_lshifr )
          mpovod := 4 // 1.3-Диспансерное наблюдение
          mIDPC := '1.3'
          ldate_next := c4tod( human->DATE_OPL )
          info_disp_nabl := val( substr( human_->DISPANS, 2, 1 ) )  // получим сведения по диспансерному наблюдению по основному заболеванию
          if ! ( eq_any( info_disp_nabl, 4, 6 ) ) // согласно письму ТФОМС 09-20-615 от 21.11.24
            If Empty( ldate_next )
              AAdd( ta, 'для услуги ' + alltrim_lshifr + ' не заполнена "Дата следующей явки пациента для диспансерного наблюдения"' )
            Elseif ldate_next < dEnd
              AAdd( ta, 'для услуги ' + alltrim_lshifr + ' "дата следующей явки пациента для диспансерного наблюдения" меньше даты окончания лечения' )
            Endif
          endif
        Endif
        kvp += hu->kol_1
        hu_->PZTIP := mPZTIP
        hu_->PZKOL := mPZKOL
      Endif
      If musl_ok == USL_OK_POLYCLINIC // 3
        If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
          //
        Elseif mpovod > 0 .and. AScan( arr_povod, {| x| x[ 1 ] == mpovod } ) == 0
          AAdd( arr_povod, { mpovod, alltrim_lshifr } )
          AAdd( arr_IDPC, { mIDPC, alltrim_lshifr } )
        Endif
      Elseif !( hu->date_u == mdate_u1 ) .and. Len( au_lu ) == 1
        AAdd( ta, 'дата услуги ' + alltrim_lshifr + ' должна равняться дате начала лечения' )
      Endif
      hu_->date_u2 := mdate_u2
      If Empty( hu_->kod_diag ) .and. l_mdiagnoz_fill
        hu_->kod_diag := mdiagnoz[ 1 ]
      Endif
      Select MKB_10
      find ( PadR( hu_->kod_diag, 6 ) )
      If !Found()
        AAdd( ta, 'не найден диагноз ' + AllTrim( hu_->kod_diag ) + '(' + AllTrim( usl->shifr ) + ') в справочнике МКБ-10' )
      Endif
      AAdd( adiag, hu_->kod_diag )
      ATail( au_lu )[ 7 ] := c4tod( mdate_u2 )
      ATail( au_lu )[ 8 ] := hu_->kod_diag
      If Empty( kodKSG ) // для КСГ цену перепроверим потом через definition_ksg()
        fl_del := fl_uslc := .f.
        v := fcena_oms( lshifr, ( human->vzros_reb == 0 ), human->k_data, @fl_del, @fl_uslc )
        If fl_uslc  // если нашли в справочнике ТФОМС
          If fl_del
            AAdd( ta, 'Цена на услугу ' + RTrim( lshifr ) + ' отсутствует в справочнике ТФОМС' )
          Elseif !( Round( v, 2 ) == Round( hu->u_cena, 2 ) )
            AAdd( ta, 'Ошибка в цене услуги[' + ;
              iif( human->vzros_reb == 0, 'взр', 'реб' ) + ;
              ']: ' + RTrim( lshifr ) + ': ' + lstr( hu->u_cena, 9, 2 ) + ;
              ', должно быть: ' + lstr( v, 9, 2 ) )
          Endif
          If !( Round( hu->u_cena * hu->kol_1, 2 ) == Round( hu->stoim_1, 2 ) )
            AAdd( ta, 'Услуга ' + RTrim( lshifr ) + ': сумма строки ' + ;
              lstr( hu->stoim_1 ) + ' не равна произведению ' + ;
              lstr( hu->u_cena ) + ' * ' + lstr( hu->kol_1 ) )
          Endif
        Elseif is_disp_DVN_COVID .and. eq_any( AllTrim( lshifr ), 'A12.09.005', 'A12.09.001', 'B03.016.003', 'B03.016.004', ;
            'A06.09.007', 'B01.026.002', 'B01.047.002', 'B01.047.006' )
        Elseif is_disp_DRZ .and. eq_any_new( AllTrim( lshifr ), ;
            'B01.001.001', 'B01.001.002', 'B01.053.001', 'B01.053.002', ;
            'B01.057.001', 'B01.057.002', 'B03.053.002', ;
            'A01.20.006', 'A02.20.001', ;
            'A04.20.001', 'A04.20.001.001', ;
            'A04.20.002', 'A04.21.001', 'A04.28.003', ;
            'A08.20.017', 'A08.20.017.001', 'A08.20.017.002', ;
            'A12.20.001', ;
            'A26.20.009.002', 'A26.20.034.001', 'A26.21.035.001', 'A26.21.036.001' )
          // //////
        Else
          AAdd( ta, 'Не найдена услуга ' + RTrim( lshifr ) + iif( human->vzros_reb == 0, ' для взрослых', ' для детей' ) + ' в справочнике ТФОМС' )
        Endif
      Endif
      If is_disp_DVN_COVID .or. is_disp_DRZ
        If hu->kod_vr != 0  // присутствует код врача
          ssumma += hu->stoim_1
        Endif
      Else
        ssumma += hu->stoim_1
      Endif
    Else
      AAdd( au_lu_ne, { usl->shifr, ;        // 1
        lshifr1, ;           // 2
        usl->name, ;         // 3
        c4tod( hu->date_u ), ; // 4
      hu->kol_1 } )         // 5
    Endif
    Select HU
    Skip
  Enddo

  if ! valid_date( human_2->NPR_DATE, 0d20000101, 0d20301231, .t. )
    AAdd( ta, 'Недопустимое значение поля "Дата направления"' )
  endif
  
  If !is_mgi .and. AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0
    If eq_any( human_->profil, 6, 34 )
      human->KOD_DIAG := 'Z01.7' // всегда
    Endif
    mdiagnoz := diag_to_array(, , , , .t. )
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      hu_->( g_rlock( forever ) )
      If l_mdiagnoz_fill .and. eq_any( human_->profil, 6, 34 )
        hu_->kod_diag := mdiagnoz[ 1 ]
      Endif
      Skip
    Enddo
  Elseif is_covid
    If l_mdiagnoz_fill .and. !( PadR( mdiagnoz[ 1 ], 5 ) == 'Z01.7' )
      AAdd( ta, 'для услуги 4.17.785 основной диагноз должен быть Z01.7' )
    Endif
    If Empty( human_->NPR_MO )
      AAdd( ta, 'для услуги 4.17.785 должно быть заполнено поле "Направившая МО"' )
    Elseif Empty( human_2->NPR_DATE )
      If glob_mo[ _MO_KOD_TFOMS ] == ret_mo( human_->NPR_MO )[ _MO_KOD_TFOMS ]
        human_2->NPR_DATE := dBegin
      Else
        AAdd( ta, 'должно быть заполнено поле "Дата направления"' )
      Endif
    Elseif human_2->NPR_DATE > dBegin
      AAdd( ta, '"Дата направления" больше "Даты начала лечения"' )
    Elseif human_2->NPR_DATE + 60 < dBegin
      AAdd( ta, 'Направлению больше двух месяцев' )
    Endif
    If !eq_any( human_->RSLT_NEW, 314 )
      AAdd( ta, 'в поле "Результат обращения" должно быть "314 Динамическое наблюдение"' )
    Endif
    If !eq_any( human_->ISHOD_NEW, 304 )
      AAdd( ta, 'в поле "Исход заболевания" должно быть "304 Без перемен"' )
    Endif
  Endif

  checkrslt_ishod( human_->RSLT_NEW, human_->ISHOD_NEW, ta )

  If Len( arr_povod ) > 0
    If Len( arr_povod ) > 1
      AAdd( ta, 'смешивание целей посещения в случае ' + print_array( arr_povod ) )
    Else
//      If is_dom .and. arr_povod[ 1, 1 ] == 1
//        arr_povod[ 1, 1 ] := 3 // 1.2 - активное посещение, т.е. на дому
//      Endif
      If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
        //
      Elseif human_->usl_ok == USL_OK_POLYCLINIC .and. l_mdiagnoz_fill
        If Len( a_idsp ) == 1 .and. a_idsp[ 1, 1 ] != 28 // т.е. idsp не равно 'за медицинскую услугу в поликлинике'
          If eq_any( arr_povod[ 1, 1 ], 1, 2, 4, 10 ) // 1.0, 1.1, 1.3, 3.0
            If !Between( Left( mdiagnoz[ 1 ], 1 ), 'A', 'U' )
              AAdd( ta, 'для посещения (обращения) по поводу заболевания основной диагноз должен быть A00-T98 или U04,U07' )
            Endif
          Elseif eq_any( arr_povod[ 1, 1 ], 9, 11 ) // 2.6, 3.1
            If !( Left( mdiagnoz[ 1 ], 1 ) == 'Z' )
              AAdd( ta, 'для посещения (обращения) с профилактической целью основной диагноз должен быть Z00-Z99' )
            Endif
          Endif
        Endif
        If arr_povod[ 1, 1 ] == 4 .and. l_mdiagnoz_fill .and. ( Left( mdiagnoz[ 1 ], 1 ) == 'C' .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D00', 'D09' ) .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D45', 'D47' ) )
          k := ret_prvs_v021( human_->PRVS )
          If !eq_any( k, 9, 19, 41 )  // как исключение добавил гематологов, специальность - 9
            AAdd( ta, 'диспансерное наблюдение при ЗНО осуществляют только врачи-онкологи (детские онкологи), а в листе учёта стоит специальность "' + inieditspr( A__MENUVERT, getv021(), k ) + '"' )
          Endif
        Endif
      Endif
    Endif
  Endif
  //
  If l_mdiagnoz_fill .and. human->OBRASHEN == '1'
    For i := 1 To Len( mdiagnoz )
      If Left( mdiagnoz[ i ], 1 ) == 'C' .or. Between( Left( mdiagnoz[ i ], 3 ), 'D00', 'D09' ) .or. Between( Left( mdiagnoz[ i ], 3 ), 'D45', 'D47' )
        AAdd( ta, AllTrim( mdiagnoz[ i ] ) + ' основной (или сопутствующий) диагноз - онкология, поэтому в поле "подозрение на ЗНО" не должно стоять "да"' )
        Exit
      Endif
    Next
    For i := 1 To Len( mdiagnoz3 )
      If Left( mdiagnoz3[ i ], 1 ) == 'C' .or. Between( Left( mdiagnoz3[ i ], 3 ), 'D00', 'D09' ) .or. Between( Left( mdiagnoz3[ i ], 3 ), 'D45', 'D47' )
        AAdd( ta, AllTrim( mdiagnoz3[ i ] ) + ' диагноз осложнения - онкология, поэтому в поле "подозрение на ЗНО" не должно стоять "да"' )
        Exit
      Endif
    Next
  Endif
  fl := ( AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) > 0 )
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
    If is_oncology == 2
      is_oncology := 1
    Endif
    If fl  .and. ! eq_any( human_->RSLT_NEW, 375, 376, 377, 378, 379 ) // для ДРЗ исключаем согласно письма 09-20-214 от 21.05.24
      AAdd( ta, 'при диспансеризации не должно быть основного (или сопутствующего) диагноза Z03.1 "наблюдение при подозрении на злокачественную опухоль"' )
    Endif
  Else
    For i := 1 To Len( au_lu )
      If !Between( au_lu[ i, 2 ], dBegin, dEnd )
        AAdd( ta, 'услуга ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ') не попадает в диапазон лечения' )
      Endif
    Next
    If human_->usl_ok < USL_OK_AMBULANCE .and. fl .and. !( human->OBRASHEN == '1' )
      If is_oncology > 0 // онкология - направления
        AAdd( ta, 'основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", но лист учёта и так онкологический' )
      Else
        AAdd( ta, 'если основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", то в поле "подозрение на ЗНО" должно стоять "да"' )
      Endif
    Endif
  Endif
  If is_oncology_smp > 0 // специально для скорой помощи
    Select ONKCO
    find ( Str( human->kod, 7 ) )
    If Found()
      If Between( onkco->PR_CONS, 1, 3 ) .and. !Between( onkco->DT_CONS, dBegin, dEnd )
        AAdd( ta, 'дата консилиума по онкологии должна быть внутри сроков лечения' )
      Endif
    Else
      addrec( 7 )
      onkco->kod := human->kod
      onkco->PR_CONS := 0 // 0-отсутствует необходимость
      onkco->DT_CONS := CToD( '' )
      Unlock
    Endif
  Endif
  If is_oncology > 0 // онкология - направления
    If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
      //
    Elseif human->OBRASHEN == '1' .and. AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) == 0
      AAdd( ta, 'при "подозрении на ЗНО" в листе учёта обязательно должен быть основной (или сопутствующий) диагноз "Z03.1 Наблюдение при подозрении на злокачественную опухоль"' )
    Endif
    i := 0
    arr := {}
    Select ONKNA // онконаправления
    find ( Str( human->kod, 7 ) )
    Do While onkna->kod == human->kod .and. !Eof()
      ++i
      AAdd( arr, { onkna->NAPR_DATE, ;
        onkna->NAPR_MO, ;
        onkna->NAPR_V, ;
        iif( onkna->NAPR_V == 3, onkna->MET_ISSL, 0 ), ;
        iif( onkna->NAPR_V == 3, onkna->U_KOD, 0 ), ;
        '', ;
        onkna->( RecNo() ), ;
        onkna->KOD_VR } )
      If !Between( onkna->NAPR_DATE, dBegin, dEnd )
        AAdd( ta, 'дата направления должна быть внутри сроков лечения (направление ' + lstr( i ) + ')' )
      Elseif !Empty( s := verify_dend_mo( onkna->NAPR_MO, onkna->NAPR_DATE ) )
        AAdd( ta, 'онконаправление в МО: ' + s )
      Endif
      If onkna->NAPR_V == 3
        If Empty( onkna->MET_ISSL )
          AAdd( ta, 'не определён "Метод диагн.исследования" для направления ' + lstr( i ) )
        Elseif Empty( onkna->KOD_VR )
          AAdd( ta, 'отсутствует табельный номер направившего врача для направления ' + lstr( i ) )
        Elseif Empty( onkna->U_KOD )
          AAdd( ta, 'не определена "Медицинская услуга" для направления ' + lstr( i ) )
        Else
          Select MOSU
          Goto ( onkna->U_KOD )
          If Empty( mosu->shifr1 )
            AAdd( ta, 'не определена "Медицинская услуга" для направления ' + lstr( i ) )
          Else
            dbSelectArea( lalf )
            find ( PadR( mosu->shifr1, 20 ) )
            If Found()
              If onkna->MET_ISSL != &lalf.->onko_napr
                AAdd( ta, 'не тот метод диагностического исследования в услуге ' + ;
                  AllTrim( iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr ) ) + ' для направления ' + lstr( i ) )
              Endif
            Else
              AAdd( ta, 'услуга ' + AllTrim( iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr ) ) + ;
                ' не найдена в справочнике (для направления ' + lstr( i ) + ')' )
            Endif
          Endif
        Endif
      Endif
      Select ONKNA
      Skip
    Enddo
    If eq_any( human_->RSLT_NEW, 308, 309 )
      If AScan( arr, {| x| eq_any( x[ 3 ], 1, 4 ) } ) == 0
        AAdd( ta, 'при "подозрении на ЗНО" или онкологическом диагнозе в листе учёта и результатах лечения "308 Направлен на консультацию" или "309 Направлен на консультацию в другое ЛПУ" обязательно должны быть направления "к онкологу" или "для определения тактики лечения"' )
      Endif
    Elseif human_->RSLT_NEW == 315
      If AScan( arr, {| x| x[ 3 ] == 3 } ) == 0
        AAdd( ta, 'при "подозрении на ЗНО" или онкологическом диагнозе в листе учёта и результате лечения "315 Направлен на обследования" обязательно должно быть направление "на дообследование"' )
      Endif
    Endif
    If Len( arr ) > 0
      arr_onkna := AClone( arr )
    Endif
    For i := 1 To Len( arr )  // ищем дубликаты направления
      s := DToS( arr[ i, 1 ] ) + arr[ i, 2 ] + Str( arr[ i, 3 ], 1 ) + Str( arr[ i, 4 ], 1 ) + Str( arr[ i, 5 ], 6 )
      arr[ i, 6 ] := s
      If i > 1 .and. ( j := AScan( arr, {| x| s == x[ 6 ] }, 1, i - 1 ) ) > 0
        Select ONKNA
        Goto ( arr[ i, 7 ] )
        deleterec( .t. )  // удаляем дубликат направления
      Endif
    Next
  Endif
  //
  Select MOHU
  find ( Str( human->kod, 7 ) )
  Do While mohu->kod == human->kod .and. !Eof()
    lshifr := mosu->shifr1
    dbSelectArea( lalf )
    find ( PadR( lshifr, 20 ) )
    usl_found := Found()
    s := AllTrim( mosu->shifr1 ) + iif( Empty( mosu->shifr ), '', '(' + AllTrim( mosu->shifr ) + ')' )
    If mosu->tip == 5
      AAdd( ta, 'услуга "' + s + '" удалена в 2017 году' )
    Endif
    If Empty( mohu->kol_1 )
      AAdd( ta, 'не заполнено поле "Количество услуг" для "' + s + '"' )
    Endif
    mdate := c4tod( mohu->date_u )
    If !Between( mdate, dBegin, dEnd )
      If usl_found .and. &lalf.->telemed == 1 .and. mdate < dBegin
        // разерешается оказывать раньше
      Elseif eq_any( Left( lshifr, 4 ), 'A06.', 'A12.', 'B01.', 'B03.' )
        // разерешается оказывать раньше
      Elseif eq_any( alltrim( lshifr ), 'A04.20.001', 'A04.20.001.001', 'A08.20.017', 'A08.20.017.001', 'A08.20.017.002' )
        // пропуск услуги
      Else
        AAdd( ta, 'услуга ' + s + ' (' + date_8( mdate ) + ') не попадает в диапазон лечения' )
      Endif
    Endif
    otd->( dbGoto( mohu->OTD ) )
    // проверка отделения для услуги
    if Empty( otd->LPU_1 )
      AAdd( ta, 'для отделения ' + AllTrim( otd->short_name ) + ', где оказана услуга ' + AllTrim( lshifr ) + ' не выбрано "Структурное подразделение по ФФОМС"' )
    endif
    mohu->( g_rlock( forever ) )
    If Empty( mohu->kod_vr ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // исправлено для углубленной диспансеризации и ДРЗ
      If usl_found .and. &lalf.->telemed == 1
        If !( mohu->PRVS == human_->PRVS )
          mohu->PRVS := human_->PRVS // для телемедицины специальность копируем из случая
        Endif
        If !( mohu->profil == human_->profil )
          mohu->profil := human_->profil // для телемедицины профиль копируем из случая
        Endif
      Else
        AAdd( ta, 'не заполнено поле "Врач, оказавший услугу ' + s + '"' )
      Endif
    Else

      arr_perso := addkoddoctortoarray( arr_perso, mohu->kod_vr )

      If Empty( mvrach ) .and. !( AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) )
        mvrach := mohu->kod_vr
      Endif
      pers->( dbGoto( mohu->kod_vr ) )
      mprvs := -ret_new_spec( pers->prvs, pers->prvs_new )
      If Empty( mprvs ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // исправлено для углубленной диспансеризации и ДРЗ
        AAdd( ta, 'нет специальности в справочнике персонала у "' + AllTrim( pers->fio ) + '"' )
      Elseif mohu->PRVS != mprvs
        mohu->PRVS := mprvs
      Endif
      If mohu->PRVS > 0 .and. ret_v004_v015( mohu->PRVS ) == 0
        AAdd( ta, 'не найдено специальности в справочнике V015 у "' + AllTrim( pers->fio ) + '"' )
      Endif
    Endif
    If Empty( mprofil )
      mprofil := mosu->profil
      If Empty( mprofil )
        mprofil := mohu->profil
      Endif
    Endif

    if ! eq_any( lu_type, TIP_LU_DDS, TIP_LU_DVN, TIP_LU_DDSOP, TIP_LU_PN, TIP_LU_PREDN, TIP_LU_PERN, TIP_LU_DVN_COVID, TIP_LU_DRZ )
      if Empty( mohu->PROFIL_M )
        AAdd( ta, 'не заполнено поле "Профиль МЗ РФ" для услуги "' + AllTrim( s ) + '"' )
      endif
    endif

    If Empty( mohu->profil )
      mohu->profil := mosu->profil
      If Empty( mohu->profil )
        mohu->profil := otd->profil
      Endif
    Endif
    If Empty( mohu->profil )
      if ! Empty( mohu->kod_vr )
        AAdd( ta, 'для услуги ' + s + ' не заполнено поле "Профиль"' )
      endif
    Elseif mohu->profil != correct_profil( mohu->profil )
      mohu->profil := correct_profil( mohu->profil )
    Endif
    ltip_onko := 0
    If usl_found
      If !Empty( &lalf.->par_org )
        If Empty( mohu->zf )
          AAdd( ta, 'в услуге ' + s + ' не введены органы (части тела), на которых выполнена операция' )
        Else
          a1 := list2arr( mohu->zf )
          a2 := list2arr( &lalf.->par_org )
          s1 := ''
          For i := 1 To Len( a2 )
            If AScan( a1, a2[ i ] ) > 0
              s1 += lstr( a2[ i ] ) + ','
            Endif
          Next
          If !Empty( s1 )
            s1 := Left( s1, Len( s1 ) - 1 )
          Endif
          If Empty( s1 ) .or. !( s1 == AllTrim( mohu->zf ) )
            AAdd( ta, 'в услуге ' + s + ' некорректно введены органы (части тела) ' + AllTrim( mohu->zf ) )
          Endif
        Endif
      Endif
      ltip_onko := &lalf.->onko_ksg
      Do Case
      Case human_->usl_ok == USL_OK_HOSPITAL  // 1
        if &lalf.->tip == 2
          AAdd( ta, 'услуга ' + s + ' относится к стоматологическим' )
        Endif
      Case human_->usl_ok == USL_OK_DAY_HOSPITAL  // 2
        if &lalf.->tip == 2
          AAdd( ta, 'услуга ' + s + ' относится к стоматологическим' )
        Endif
      Case human_->usl_ok == USL_OK_POLYCLINIC
        If fl_stom
          If Empty( &lalf.->tip )
            AAdd( ta, 'услуга ' + s + ' не относится к стоматологическим' )
          Else
            // проверяем на профиль
            uslugaaccordanceprofil( lshifr, human->vzros_reb, mohu->profil, ta, mosu->shifr )
            // проверяем на специальность
            uslugaaccordanceprvs( lshifr, human->vzros_reb, mohu->prvs, ta, mosu->shifr, mohu->kod_vr )
          Endif
          if &lalf.->zf == 1  // обязателен ввод зубной формулы
            arr_zf := stverifyzf( mohu->zf, human->date_r, dBegin, ta, s )
            stverifykolzf( arr_zf, mohu->kol_1, ta, s )
          Endif
        elseif &lalf.->telemed == 0 .and. ! eq_any_new( AllTrim( &lalf.->shifr ), ;
            'A01.20.006', 'A01.20.002', 'A01.20.003', 'A01.20.005', 'A02.20.001', 'A02.20.003', 'A02.20.005', ;
            'A04.10.002', 'A04.12.006.002', ;
            'A04.20.001', 'A04.20.001.001', 'A04.20.002', ;
            'A04.21.001', 'A04.28.003', ;
            'A06.09.005', 'A06.09.007', ;
            'A08.20.017', 'A08.20.017.001', 'A08.20.017.002', ;
            'A09.05.051.001', 'A09.20.011',  ;
            'A12.09.001', 'A12.09.005', 'A12.20.001', ;
            'A23.30.023', ;
            'A26.20.009.002', 'A26.20.034.001', 'A26.21.035.001', 'A26.21.036.001', ;
            'B01.001.001', 'B01.001.002', ;
            'B03.016.003', 'B03.016.004', ;
            'B01.026.001', 'B01.026.002', ;
            'B01.053.001', 'B01.053.002', ;
            'B01.057.001', 'B01.057.002', ;
            'B03.053.002', ;
            'B01.070.009', 'B01.070.010', ;
            'A25.28.001.001', 'A25.28.001.002', ;
            'A06.09.007.002', 'A06.20.004', 'A06.09.006.001' ;
          )
          AAdd( ta, 'услугу ' + s + ' нельзя вводить для амбулаторной помощи' )
        Endif
      Case human_->usl_ok == USL_OK_AMBULANCE // 4
        if &lalf.->telemed == 0
          AAdd( ta, 'услугу ' + s + ' нельзя вводить для скорой помощи' )
        Endif
      Endcase
    Else
      AAdd( ta, 'услуга ' + s + ' не найдена в справочнике' )
    Endif
    If !valid_guid( mohu->ID_U )
      mohu->ID_U := mo_guid( 4, mohu->( RecNo() ) )
    Endif
    mohu->date_u2 := mohu->date_u
    If Empty( mohu->kod_diag ) .and. l_mdiagnoz_fill
      mohu->kod_diag := mdiagnoz[ 1 ]
    Endif
    Select MKB_10
    find ( PadR( mohu->kod_diag, 6 ) )
    If !Found()
      AAdd( ta, 'не найден диагноз ' + AllTrim( mohu->kod_diag ) + ' в справочнике МКБ-10' )
    Endif
    AAdd( au_flu, { lshifr, ;               // 1
      mdate, ;                // 2
      mohu->profil, ;         // 3
      mohu->PRVS, ;           // 4
      mosu->shifr, ;          // 5
      mohu->kol_1, ;          // 6
      c4tod( mohu->date_u2 ), ; // 7
    mohu->kod_diag, ;       // 8
      mohu->( RecNo() ), ;      // 9
    ltip_onko, ;            // 10 тип онкологического лечения
      .f. } )                  // 11 тип онкологического лечения ставим в услугу
    Select MOHU
    Skip
  Enddo
  v := 0
  If is_oncology == 2 // онкология
    Select ONKSL
    find ( Str( human->kod, 7 ) )
    Select ONKCO
    find ( Str( human->kod, 7 ) )
    If Found()
      If Between( onkco->PR_CONS, 1, 3 ) .and. !Between( onkco->DT_CONS, dBegin, dEnd )
        AAdd( ta, 'дата консилиума по онкологии должна быть внутри сроков лечения' )
      Endif
    Else
      addrec( 7 )
      onkco->kod := human->kod
      onkco->PR_CONS := 0 // 0-отсутствует необходимость
      onkco->DT_CONS := CToD( '' )
      Unlock
    Endif
    fl := .t.
    If l_mdiagnoz_fill .and. Between( onksl->ds1_t, 0, 4 )
      If Empty( onksl->STAD ) .and. ( human->k_data < 0d20250701 )
        AAdd( ta, 'онкология: не введена стадия заболевания' )
      Else
        f_verify_tnm( 2, onksl->STAD, mdiagnoz[ 1 ], human->k_data, ta )
      Endif
    Endif
    If kkt > 0 .and. onksl->ds1_t != 5
      AAdd( ta, 'онкология: для отдельных диагностических услуг в поле "Повод обращения" должно быть проставлено "Диагностика"' )
    Endif
    If Len( arr_povod ) > 0 .and. arr_povod[ 1, 1 ] == 4 .and. onksl->ds1_t != 4
      AAdd( ta, 'онкология: в случае диспансерного наблюдения в поле "Повод обращения" должно быть проставлено "диспансерное наблюдение"' )
    Endif
    If l_mdiagnoz_fill .and. onksl->ds1_t == 0 .and. human->vzros_reb == 0
      If Empty( onksl->ONK_T ) .and. ( human->k_data < 0d20250701 )
        fl := .f. ; AAdd( ta, 'онкология: не введена стадия заболевания T' )
      Endif
      If Empty( onksl->ONK_N ) .and. ( human->k_data < 0d20250701 )
        fl := .f. ; AAdd( ta, 'онкология: не введена стадия заболевания N' )
      Endif
      If Empty( onksl->ONK_M ) .and. ( human->k_data < 0d20250701 )
        fl := .f. ; AAdd( ta, 'онкология: не введена стадия заболевания M' )
      Endif
      If fl
        fl := f_verify_tnm( 3, onksl->ONK_T, mdiagnoz[ 1 ], human->k_data, ta )
      Endif
      If fl
        fl := f_verify_tnm( 4, onksl->ONK_N, mdiagnoz[ 1 ], human->k_data, ta )
      Endif
      If fl
        fl := f_verify_tnm( 5, onksl->ONK_M, mdiagnoz[ 1 ], human->k_data, ta )
      Endif
    Endif
    // гистология
    If is_gisto .and. onksl->b_diag != 98
      AAdd( ta, 'для листа учёта по гистологии обязателен ввод результатов гистологии' )
    Endif
    If is_mgi .and. onksl->b_diag != 98
      AAdd( ta, 'для листа учёта по молекулярной генетике обязателен ввод результатов иммуногистохимии' )
    Endif
    If onksl->b_diag == 0 // отказ
      // при составлении реестра самостоятельно дополнить блок противопоказаний id_prot = 0
    Elseif onksl->b_diag == 7 // не показано
      // при составлении реестра самостоятельно дополнить блок противопоказаний id_prot = 7
    Elseif onksl->b_diag == 8 // противопоказано
      // при составлении реестра самостоятельно дополнить блок противопоказаний id_prot = 8
    Elseif onksl->b_diag == -1 // выполнено (до 1 сентября 2018 года)
      // при составлении реестра блок B_DIAG не заполняется
    Elseif l_mdiagnoz_fill .and. eq_any( onksl->b_diag, 97, 98 ) // выполнено
      ar_N009 := {}
      If !is_mgi
        For i_n009 := 1 To Len( aN009 )
          If between_date( aN009[ i_n009, 4 ], aN009[ i_n009, 5 ], dEnd ) .and. PadR( mdiagnoz[ 1 ], 3 ) == Left( aN009[ i_n009, 2 ], 3 )
            AAdd( ar_N009, { '', aN009[ i_n009, 3 ], {} } )
          Endif
        Next
      Endif
      // Иммуногистохимия/маркеры
      mm_N012 := {}
      ar_N012 := {}
      If ( it := AScan( aN012_DS, {| x| Left( x[ 1 ], 3 ) == PadR( mdiagnoz[ 1 ], 3 ) } ) ) > 0
        ar_N012 := AClone( aN012_DS[ it, 2 ] )
        For i_n012 := 1 To Len( ar_N012 )
          AAdd( mm_N012, { '', ar_N012[ i_n012 ], {} } )
        Next
      Endif
      If is_mgi
        If ( i := AScan( glob_MGI, {| x| x[ 1 ] == shifr_mgi } ) ) > 0 // услуга входит в список ТФОМС
          If ( j := AScan( ar_N012, {| x| x[ 2 ] == glob_MGI[ i, 2 ] } ) ) > 0 // по данному диагнозу присутствует необходимый маркер
            tmp_arr := {}
            AAdd( tmp_arr, AClone( ar_N012[ j ] ) )
            ar_N012 := AClone( tmp_arr ) // оставим в массиве только один нужный нам маркер
          Else
            ar_N012 := {}
          Endif
        Else
          ar_N012 := {}
        Endif
      Endif
      arr_onkdi0 := {}
      arr_onkdi1 := {}
      arr_onkdi2 := {}
      ngist := nimmun := 0 ; fl_krit_date := .f.
      Select ONKDI
      find ( Str( human->kod, 7 ) )
      If Found()
        If Empty( onkdi->DIAG_DATE ) .and. is_gisto
          AAdd( arr_onkdi0, .f. )
        Else
          // if is_gisto .and. onkdi->DIAG_DATE != dBegin
          // aadd(ta, 'для гистологии дата взятия материала ' + date_8(onkdi->DIAG_DATE) + 'г. не равняется дате начала лечения ' + date_8(dBegin) + 'г.')
          // elseif onkdi->DIAG_DATE < 0d20180901
          // fl_krit_date := .t.
          // //aadd(ta, 'Дата взятия материала ' + date_8(onkdi->DIAG_DATE) + 'г. меньше КРИТИЧЕСКОЙ даты')
          // endif
        Endif
        Do While onkdi->kod == human->kod .and. !Eof()
          If onkdi->DIAG_TIP == 1
            AAdd( arr_onkdi1, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
            If onkdi->DIAG_RSLT > 0
              ++ngist
            Endif
          Elseif onkdi->DIAG_TIP == 2
            AAdd( arr_onkdi2, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
            If onkdi->DIAG_RSLT > 0
              ++nimmun
            Endif
          Endif
          Skip
        Enddo
      Endif
      If fl_krit_date // выполнено (до 1 сентября 2018 года)
        Select ONKDI // при составлении реестра блок B_DIAG не заполняется
        Do While .t.
          find ( Str( human->kod, 7 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        Select ONKSL
        g_rlock( forever )
        onksl->b_diag := -1
        Unlock
      Else
        If Len( arr_onkdi0 ) > 0
          AAdd( ta, 'не заполнена дата взятия материала' )
        Endif
        If is_gisto .and. emptyall( Len( ar_N009 ), Len( ar_N012 ) ) .and. ( onksl->DS1_T != 5 )  // взятие гистологии и справочники пустые
          If Empty( ngist )
            AAdd( ta, 'для амбулаторного случая по взятию гистологического материала обязательно заполнение поля "Результаты гистологии"' )
          Endif
        Else
          If is_mgi
            If Len( arr_onkdi1 ) > 0
              AAdd( ta, 'для листа учёта по молекулярной генетике не должна заполняться таблица гистологий' )
            Endif
          Elseif Len( arr_onkdi1 ) != Len( ar_N009 )  .and. ( onksl->DS1_T != 5 )
            AAdd( ta, 'ошибки заполнения таблицы гистологий' )
          Endif
          If Len( arr_onkdi2 ) != Len( ar_N012 )
            AAdd( ta, 'ошибки заполнения таблицы иммуногистохимий' )
          Elseif is_mgi .and. Len( ar_N012 ) > 0 .and. Len( arr_onkdi2 ) != 1
            AAdd( ta, 'для листа учёта по молекулярной генетике зполняется только один маркер по иммуногистохимии' )
          Endif
          If onksl->b_diag == 98
            If ngist != Len( ar_N009 )
              AAdd( ta, 'не все гистологии заполнены' )
            Endif
            If nimmun != Len( ar_N012 )
              AAdd( ta, 'не все иммуногистохимии заполнены' )
            Endif
          Endif
        Endif
      Endif
    Endif
    //
    Select ONKPR
    find ( Str( human->kod, 7 ) )
    Do While onkpr->kod == human->kod .and. !Eof()
      If !Between( onkpr->PROT, 0, 8 )  // цифры взяты из справочника N001.xml
        AAdd( ta, 'Некорректно записано противопоказание к проведению (отказ от проведения)' )
      Elseif onkpr->D_PROT > dEnd
        AAdd( ta, AllTrim( Lower( inieditspr( A__MENUVERT, getn001(), n1->prot_name ) ) ) + ' - дата регистрации больше даты окончания лечения' )
      Endif
      Select ONKPR
      Skip
    Enddo
    // услуга обязательна для стационара и дневного стационара при проведении противоопухолевого лечения
    If human_->usl_ok < USL_OK_POLYCLINIC // 3
      arr_onk_usl := {}
      Select ONKUS
      find ( Str( human->kod, 7 ) )
      Do While onkus->kod == human->kod .and. !Eof()
        If Between( onkus->USL_TIP, 1, 6 )
          AAdd( arr_onk_usl, onkus->USL_TIP )
          k := iif( onkus->USL_TIP == 4, 3, onkus->USL_TIP )
          If ( i := AScan( au_flu, {| x| x[ 10 ] == k } ) ) > 0
            If onkus->USL_TIP == 1
              If Empty( onkus->HIR_TIP )
                AAdd( ta, 'не заполнен тип хирургического лечения' )
              Endif
            Elseif onkus->USL_TIP == 2
              If Empty( onkus->LEK_TIP_V )
                AAdd( ta, 'не заполнен цикл лекарственной терапии' )
              Endif
              If Empty( onkus->LEK_TIP_L )
                AAdd( ta, 'не заполнена линия лекарственной терапии' )
              Endif
            Elseif Between( onkus->USL_TIP, 3, 4 )
              If Empty( onkus->LUCH_TIP )
                AAdd( ta, 'не заполнен тип ' + iif( onkus->USL_TIP == 3, '', 'химио' ) + 'лучевой терапии' )
              Endif
            Endif
            au_flu[ i, 11 ] := .t.
          Elseif eq_any( onkus->USL_TIP, 1, 3, 4 )
            AAdd( ta, 'не введена услуга для выбранного типа онкологического лечения (' + ;
              { 'хирург.', '', 'лучевая', 'химиолучевая' }[ onkus->USL_TIP ] + ')' )
          Endif
          If onkus->USL_TIP == 5 .and. onksl->ds1_t != 6
            AAdd( ta, 'для выбранного повода обращения нельзя вводить "симптоматическое лечение"' )
          Elseif onkus->USL_TIP == 6 .and. onksl->ds1_t != 5
            AAdd( ta, 'для выбранного повода обращения нельзя вводить лечение "диагностика"' )
          Endif
        Endif
        Select ONKUS
        Skip
      Enddo
      If Empty( arr_onk_usl )
        //
        // закомментировал временно 13.02.22 пока не разберусь
        //
        // if iif(human_2->VMP == 1, .t., between(onksl->ds1_t, 0, 2)) .and. empty(alltrim(human_2->PC3))
        // aadd(ta, 'не введено онкологическое лечение')
        // endif
      Elseif eq_ascan( arr_onk_usl, 2, 4 )
        If Empty( onksl->crit )
          AAdd( ta, 'не введена схема лекарственной терапии' )
        Else
          // исправлено исходя из нового справочника Q015 13.01.23
          // if human->vzros_reb  > 0 .or. is_lymphoid(mdiagnoz[1]) // если ребёнок или ЗНО кроветворная или лимфоидная
          If human->vzros_reb  > 0 // если ребёнок
            If AllTrim( onksl->crit ) == 'нет'
              // всё правильно
            Else
              AAdd( ta, 'для детей вместо схемы лечения необходимо указывать "без схемы лекарственной терапии"' )
            Endif
          Else
            If AllTrim( onksl->crit ) == 'нет'
              AAdd( ta, 'нельзя указывать "без схемы", необходимо указывать схему' )
            Else
              // всё правильно
            Endif
          Endif
        Endif
        If Empty( onksl->wei )
          AAdd( ta, 'не введена масса тела для выбранного типа онкологического лечения' )
        Elseif !( onksl->wei < 500 )
          AAdd( ta, 'слишком большая масса тела для выбранного типа онкологического лечения' )
        Endif
        If Empty( onksl->hei )
          AAdd( ta, 'не введен рост пациента для выбранного типа онкологического лечения' )
        Elseif !( onksl->hei < 260 )
          AAdd( ta, 'слишком большой рост пациента для выбранного типа онкологического лечения' )
        Endif
        If Empty( onksl->bsa )
          AAdd( ta, 'не введена площадь поверхности тела для выбранного типа онкологического лечения' )
        Elseif !( onksl->bsa < 6 )
          AAdd( ta, 'слишком большая площадь поверхности тела для выбранного типа онкологического лечения' )
        Endif
        arr_lek := {}
        fl := .t.
        // fl_zolend := .t.
        Select ONKLE
        find ( Str( human->kod, 7 ) )
        Do While onkle->kod == human->kod .and. !Eof()
          If Empty( onkle->REGNUM )
            AAdd( ta, 'не введен идентификатор лекарственного препарата - отредактируйте cписок лекарственных препаратов' )
            fl := .f.
            Exit
          Else
            If Empty( onkle->CODE_SH )
              AAdd( ta, 'не введена схема лекарственной терапии в лекарствах - отредактируйте cписок лекарственных препаратов' )
              fl := .f.
              Exit
            Else
              If ( i := AScan( arr_lek, {| x| x[ 1 ] == onkle->REGNUM .and. x[ 2 ] == onkle->CODE_SH } ) ) == 0
                AAdd( arr_lek, { onkle->REGNUM, onkle->CODE_SH } )
              Endif
            Endif
            If Empty( onkle->DATE_INJ )
              AAdd( ta, 'не введена дата введения препарата - отредактируйте cписок лекарственных препаратов' )
              fl := .f.
              Exit
            Elseif !Between( onkle->DATE_INJ, dBegin, dEnd )
              AAdd( ta, 'дата введения препарата выходит за сроки лечения - отредактируйте cписок лекарственных препаратов' )
              fl := .f.
              Exit
            Endif
          Endif
          Select ONKLE
          Skip
        Enddo
        If fl
          If Empty( arr_lek )
            AAdd( ta, 'не заполнен cписок лекарственных препаратов' )
          Else
            // if fl_zolend
            // aadd(ta, 'в составе случая оказания химиотерапии не может быть применен ТОЛЬКО один препарат из списка (золедроновая кислота, ибандроновая кислота, памидроновая кислота, клодроновая кислота или деносумаб)')
            // endif
            aN021 := getn021( dEnd )
            n := 0
            l_n021 := .f.
            For Each row in aN021
              If row[ 2 ] == onksl->crit
                l_n021 := .t.
                If ( i := AScan( arr_lek, {| x| x[ 1 ] == row[ 3 ] } ) ) > 0
                  ++n
                  // elseif onksl->is_err == 0
                  // aadd(ta, 'не по всем препаратам введены даты - отредактируйте cписок лекарственных препаратов')
                  // fl := .f.
                  // exit
                Endif
              Endif
            Next
            If l_n021
              If n != Len( arr_lek )
                AAdd( ta, 'отредактируйте cписок лекарственных препаратов' )
              Endif
            Endif
          Endif
        Endif
      Endif
    Endif
  Endif
  If is_mgi .and. l_mdiagnoz_fill .and. !( Left( mdiagnoz[ 1 ], 1 ) == 'C' )
    AAdd( ta, 'для листа учёта по молекулярной генетике основной диагноз должен быть C00-C97' )
  Endif
  mpztip := mpzkol := 0
  If !( Round( human->cena_1, 2 ) == Round( ssumma, 2 ) )
    AAdd( ta, 'Сумма случая ' + lstr( human->cena_1 ) + ' не равна сумме услуг ' + lstr( ssumma ) )
    AAdd( ta, 'Выполните ПЕРЕИНДЕКСИРОВАНИЕ и отредактируйте услуги в листе учёта' )
  Endif
  If Empty( au_lu )
    If Empty( au_flu )
      AAdd( ta, 'Не введено ни одной услуги' )
    Else
      AAdd( ta, 'Не введена основная услуга, но введена манипуляция Минздрава РФ' )
    Endif
  Endif
  If Empty( human_->profil )
    human_->profil := mprofil  // сначала профиль из первой услуги
  Endif
  If Empty( human_->profil )
    otd->( dbGoto( human->OTD ) )
    human_->profil := otd->profil  // если нет, то из отделения
  Endif
  If !Empty( human_->profil ) .and. human_->profil != correct_profil( human_->profil )
    human_->profil := correct_profil( human_->profil )
  Endif
  If l_mdiagnoz_fill .and. Left( mdiagnoz[ 1 ], 3 ) == 'O04' .and. eq_any( human_->profil, 136, 137 ) // акушерству и гинекологии
    If !Between( human_2->pn2, 1, 2 )
      AAdd( ta, 'для диагноза ' + AllTrim( mdiagnoz[ 1 ] ) + ' обязательно заполнять, искусственное прерывание беременности проводилось по медицинским показаниям или нет' )
    Elseif human_2->pn2 == 1 .and. ( Len( mdiagnoz ) < 2 .or. Empty( mdiagnoz[ 2 ] ) )
      AAdd( ta, 'для диагноза ' + AllTrim( mdiagnoz[ 1 ] ) + ' (искусственное прерывание беременности по медицинским показаниям) не указан сопутствующий диагноз' )
    Endif
  Endif
  If Empty( human_->VRACH ) .and. !( AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) )
    human_->VRACH := mvrach // врача из первой услуги
  Endif
  If AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
    mpzkol := Len( au_lu )
  Endif
  If AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
    If !Empty( human_2->PN3 )
      human->UCH_DOC := lstr( human_2->PN3 ) // ORDER по ЛИС перезаписываем (вдруг исправили)
    Endif
    If !is_mgi
      human_->VRACH := 0
    Endif
    human_->PRVS := iif( human_->profil == 34, -13, -54 )
  Elseif human_->profil == 15   // гистология
    human_->PRVS := -13 // Клиническая лабораторная диагностика
  Elseif Empty( human_->VRACH )
    AAdd( ta, 'не заполнено поле "Лечащий врач"' )
  Else
    pers->( dbGoto( human_->VRACH ) )
    mprvs := -ret_new_spec( pers->prvs, pers->prvs_new )
    If Empty( mprvs ) .and. ( ! is_disp_DVN_COVID ) .and. ( ! is_disp_DRZ ) // исправлено для углубленной диспансеризации и ДРЗ
      AAdd( ta, 'нет специальности в справочнике персонала у "' + AllTrim( pers->fio ) + '"' )
    Elseif human_->PRVS != mprvs
      human_->PRVS := mprvs
    Endif
    If human_->PRVS > 0 .and. ret_v004_v015( human_->PRVS ) == 0
      AAdd( ta, 'не найдено специальности в справочнике у "' + AllTrim( pers->fio ) + '"' )
    Endif

    arr_perso := addkoddoctortoarray( arr_perso, human_->VRACH )

  Endif
  For i := 1 To Len( arr_perso )
    pers->( dbGoto( arr_perso[ i ] ) )
    If pers->tab_nom != 0 // добавлен для углубленной диспансеризации
      mvrach := fam_i_o( pers->fio ) + ' [' + lstr( pers->tab_nom ) + ']'
      If Empty( pers->snils )
        AAdd( ta, 'не введен СНИЛС у врача - ' + mvrach )
      Else
        s := Space( 80 )
        If !val_snils( pers->snils, 2, @s )
          AAdd( ta, s + ' у врача - ' + mvrach )
        Endif
      Endif
    Endif
  Next
  If Empty( human_->USL_OK )
    human_->USL_OK := musl_ok
  Elseif mUSL_OK > 0 .and. human_->USL_OK != mUSL_OK
    AAdd( ta, 'в поле "Условия оказания" должно быть "' + inieditspr( A__MENUVERT, getv006(), mUSL_OK ) + '"' )
  Endif
  If human_->USL_OK == USL_OK_POLYCLINIC // для поликлиники
    s := Space( 80 )
    If !vr_pr_1_den( 2, @s, u_other )
      AAdd( ta, s )
    Endif
  Endif
  If human_->USL_OK == USL_OK_HOSPITAL .and. SubStr( human_->FORMA14, 1, 1 ) == '0'
    If Empty( human_->NPR_MO )
      AAdd( ta, 'при ПЛАНОВОЙ госпитализации должно быть заполнено поле "Направившая МО"' )
    Elseif Empty( human_2->NPR_DATE )
      If glob_mo[ _MO_KOD_TFOMS ] == ret_mo( human_->NPR_MO )[ _MO_KOD_TFOMS ]
        human_2->NPR_DATE := dBegin
      Else
        AAdd( ta, 'должно быть заполнено поле "Дата направления на госпитализацию"' )
      Endif
    Elseif human_2->NPR_DATE > dBegin
      AAdd( ta, '"Дата направления на госпитализацию" больше "Даты начала лечения"' )
    Elseif human_2->NPR_DATE + 60 < dBegin
      AAdd( ta, 'Направлению на госпитализацию больше двух месяцев' )
    Endif
  Endif

  // проверка номера направления на госпитализацию
  If eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    napr_number := AllTrim( get_NAPR_MO( human->kod, _NPR_LECH ) ) 
    if Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) ) == 0 .and. Empty( napr_number )
        AAdd( ta, 'должно быть заполнено поле "Номер направление на госпитализацию"' )
    endif
  endif

  If eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    i := human_2->p_per
    If !Between( human_2->p_per, 1, 4 ) // если не вводили
      i := iif( SubStr( human_->FORMA14, 2, 1 ) == '1', 2, 1 )
    Elseif SubStr( human_->FORMA14, 2, 1 ) == '1' // если скорая помощь
      i := 2
    Elseif !( SubStr( human_->FORMA14, 2, 1 ) == '1' ) // если не скорая помощь
      If i == 2 // если скорая помощь
        i := 1
      Endif
    Endif
    If i != human_2->p_per
      human_2->p_per := i
    Endif
  Endif
  If kkt == 0 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. Len( a_srok_lech ) > 0
    For i := 1 To Len( a_srok_lech )
      otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
      If a_srok_lech[ i, 5 ] == 0
        otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
        AAdd( ta, 'пересечение ' + date_8( a_srok_lech[ i, 1 ] ) + '-' + date_8( a_srok_lech[ i, 2 ] ) + ;
          iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
      Endif
    Next
  Endif
  If fl_stom
    mpzkol := 1
    If f_vid_p_stom( au_lu, ta, , , dEnd, @ltip, @lkol, @is_2_88, au_flu )
      Do Case
      Case ltip == 1 // с лечебной целью
        mpztip := 65
        If lkol < 2
          AAdd( ta, 'при обращении по поводу заболевания должно быть не менее ДВУХ посещений к врачу-стоматологу' )
        Elseif AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '2.78.55' } ) > 0 .and. ;
            eq_any( Left( human->KOD_DIAG, 3 ), 'K05', 'K06' ) .and. lkol < 5
          AAdd( ta, 'при обращении по поводу заболевания пародонта должно быть не менее ПЯТИ посещений к врачу-стоматологу' )
        Elseif human->KOD_DIAG == 'Z01.2'
          AAdd( ta, 'основной диагноз Z01.2 применяется при посещении с профилактической целью в стоматологии, а в случае - по поводу заболевания' )
        Endif
      Case ltip == 2 // с профилактической целью или разовое по поводу заболевания
        mpztip := 63
        If lkol != 1
          AAdd( ta, 'при посещении с профилактической целью должно быть ОДНО посещение к врачу-стоматологу' )
        Elseif is_2_88 .and. human->KOD_DIAG == 'Z01.2'
          AAdd( ta, 'при разовом посещении по поводу заболевания в стоматологии основной диагноз не должен быть Z01.2' )
        Elseif !is_2_88 .and. !( human->KOD_DIAG == 'Z01.2' )
          AAdd( ta, 'при посещении с профилактической целью в стоматологии основной диагноз всегда Z01.2' )
        Endif
        If !is_2_88
          human_->RSLT_NEW := 314
          human_->ISHOD_NEW := 304
        Endif
      Case ltip == 3 // при оказании неотложной помощи
        mpztip := 64
        If lkol != 1
          AAdd( ta, 'при неотложном посещении должно быть ОДНО посещение к врачу-стоматологу' )
        Elseif human->KOD_DIAG == 'Z01.2'
          AAdd( ta, 'основной диагноз Z01.2 применяется при посещении с профилактической целью в стоматологии, а в случае - неотложное' )
        Endif
      Endcase
      If ltip > 1 .and. dBegin != dEnd
        AAdd( ta, iif( ltip == 2, 'при посещении с профилактической целью', 'при неотложном посещении' ) + ' дата окончания должна равняться дате начала лечения' )
      Endif
    Endif
  Endif
  If human_->USL_OK == USL_OK_HOSPITAL  // 1 - стационар
    If human_2->VNR > 0 .and. !Between( human_2->VNR, 301, 2499 )
      AAdd( ta, 'вес недоношенного ребёнка должен быть более 300 г и менее 2500 г' )
    Endif
    For i := 1 To 3
      pole := 'human_2->VNR' + lstr( i )
      if &pole > 0 .and. !Between( &pole, 301, 2499 )
        AAdd( ta, 'вес ' + lstr( i ) + '-го недоношенного ребёнка должен быть более 300 г и менее 2500 г' )
      Endif
    Next
    If kol_ksg > 1
      AAdd( ta, 'введено более одной КСГ' )
    Endif
    mpztip := 52 // 52, 'Случай госпитализации', 'случ.госп.'}, ;
    mpzkol := kkd_1_11
    If ( i := dEnd - dBegin ) == 0
      i := 1
    Endif
    If kkd_1_11 != i
      AAdd( ta, 'количество койко-дней 1.11.* должно равняться ' + lstr( i ) )
    Elseif is_reabil // реабилитация
      mpztip := 53 // 53, 'случай госпитализации при реабилитации', 'госп.реаб.'}, ;
      If human_2->VMP == 1 // если установили ВМП
        AAdd( ta, 'при реабилитации не может быть оказана ВМП' )
      Endif
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          If !( AllTrim( au_lu[ i, 1 ] ) == '1.11.2' )
            AAdd( ta, 'неверная услуга ' + au_lu[ i, 1 ] )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;
            au_lu[ i, 7 ], ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ], ;
            au_lu[ i, 6 ] } )
        Endif
      Next
      If Len( a_1_11 ) == 1
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, 'дата начала услуги 1.11.2 должна равняться дате начала лечения' )
        Endif
        If a_1_11[ 1, 2 ] != dEnd
          AAdd( ta, 'дата окончания услуги 1.11.2 должна равняться дате окончания лечения' )
        Endif
      Else
        AAdd( ta, 'услуга 1.11.2 должна встречаться один раз' )
      Endif
    Else // остальные койко-дни
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          If !( AllTrim( au_lu[ i, 1 ] ) == '1.11.1' )
            AAdd( ta, 'неверная услуга ' + au_lu[ i, 1 ] )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;
            au_lu[ i, 7 ], ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ], ;
            au_lu[ i, 6 ] } )
        Endif
      Next
      If Len( a_1_11 ) > 0
        ASort( a_1_11, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, 'дата начала первой услуги 1.11.1 должна равняться дате начала лечения' )
        Endif
        For i := 2 To Len( a_1_11 )
          If a_1_11[ i - 1, 2 ] != a_1_11[ i, 1 ]
            AAdd( ta, 'дата начала ' + lstr( i ) + '-й услуги 1.11.1 должна равняться ' + date_8( a_1_11[ i - 1, 2 ] ) )
          Endif
        Next
        If ATail( a_1_11 )[ 2 ] != dEnd
          AAdd( ta, 'дата окончания последней услуги 1.11.1 должна равняться дате окончания лечения' )
        Endif
      Endif
    Endif
    fl := .t.
    If Empty( human_->profil )
      AAdd( ta, 'в случае не проставлен профиль' )
    Elseif Empty( human_->PRVS )
      AAdd( ta, 'у лечащего врача в случае не проставлена специальность' )
    Elseif is_reabil // реабилитация
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          fl := .t.
          Exit
        Endif
      Next
    Else // остальные койко-дни
      If human_->profil == 158
        AAdd( ta, 'в случае нельзя использовать профиль по: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
      Endif
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      For i := 1 To Len( au_flu )
        AAdd( a_1_11, { AllTrim( au_flu[ i, 8 ] ), ;
          au_flu[ i, 3 ], ;
          au_flu[ i, 4 ] } )
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. ;
            human_->profil == a_1_11[ i, 2 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          If a_1_11[ i, 2 ] == 158
            AAdd( ta, 'в услуге нельзя использовать профиль по: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
          Endif
          fl := .t. ; Exit
        Endif
      Next
    Endif
    ar_1_19_1 := {} ; fl_19 := .f.
    For i := 1 To Len( au_lu )
      If Left( au_lu[ i, 1 ], 5 ) == '1.19.'
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == AllTrim( au_lu[ i, 8 ] ) .and. ;
            human_->profil == au_lu[ i, 3 ] .and. human_->PRVS == au_lu[ i, 4 ]
          fl_19 := .t.
        Endif
        AAdd( ar_1_19_1, au_lu[ i, 2 ] )
        If au_lu[ i, 6 ] > 1
          AAdd( ta, 'в услуге 1.19.1 (' + DToC( au_lu[ i, 2 ] ) + ') количество больше 1' )
        Endif
      Endif
    Next
    If !( fl .or. fl_19 )
      AAdd( ta, 'в одной из услуг 1.11.*(1.19.1) должны повториться диагноз+профиль+врач из случая' )
    Endif
    For j := 1 To Len( ar_1_19_1 )
      fl := .t.
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '1.11.' .and. eq_any( ar_1_19_1[ j ], au_lu[ i, 2 ], au_lu[ i, 7 ] )
          fl := .f.
          Exit
        Endif
      Next
      If fl
        AAdd( ta, 'дата услуги 1.19.1 (' + DToC( ar_1_19_1[ j ] ) + ') обязательно должна равняться дате начала/окончания одной из услуг 1.11.1/1.11.2' )
      Endif
    Next
    If human_2->VMP == 1 // проверим ВМП
      If is_MO_VMP  // если есть услуги ВМП для учреждения
        arrV018 := getv018( human->k_data )
        arrV019 := getv019( human->k_data )
        If !Empty( ar_1_19_1 )
          AAdd( ta, 'при оказании ВМП не может быть применена услуга 1.19.1' )
        Endif
        If Empty( human_2->TAL_NUM )
          AAdd( ta, 'ВМП оказана, но не введен номер талона на ВМП' )
        Elseif ( human->k_data > 0d20220101 ) .and. !Empty( human_2->TAL_NUM ) .and. !valid_number_talon( human_2->TAL_NUM, human->k_data, .f. )
          AAdd( ta, 'ВМП оказана, но формат номера талона на ВМП не верен (шаблон 99.9999.99999.999)' )
        Endif
        If Empty( human_2->TAL_D )
          AAdd( ta, 'ВМП оказана, но не введена дата выдачи талона на ВМП' )
        Elseif !eq_any( Year( human_2->TAL_D ), yearEnd - 1, yearEnd, yearEnd + 1 )
          AAdd( ta, 'дата выдачи талона на ВМП (' + date_8( human_2->TAL_D ) + ') должна быть в текущем или прошлом году' )
        Endif
        If Empty( human_2->TAL_P )
          AAdd( ta, 'ВМП оказана, но не введена дата планируемой госпитализации в соответствии с талоном на ВМП' )
        Elseif !eq_any( Year( human_2->TAL_P ), yearEnd - 1, yearEnd, yearEnd + 1 )
          AAdd( ta, 'дата планируемой госпитализации в соответствии с талоном на ВМП (' + date_8( human_2->TAL_P ) + ') должна быть в текущем или прошлом году' )
        Endif
        If Empty( human_2->VIDVMP )
          AAdd( ta, 'ВМП оказана, но не введён вид ВМП' )
        Elseif AScan( arrV018, {| x| x[ 1 ] == AllTrim( human_2->VIDVMP ) } ) == 0
          AAdd( ta, 'Не найден вид ВМП "' + human_2->VIDVMP + '" в справочнике V018' )
        Elseif Empty( human_2->METVMP )
          AAdd( ta, 'ВМП оказана, введён вид ВМП, но не введён метод ВМП' )
        Elseif ( ( i := AScan( arrV019, {| x| x[ 1 ] == human_2->METVMP } ) ) > 0 ) .and. ( Year( human->k_data ) == 2020 )
          If arrV019[ i, 4 ] == AllTrim( human_2->VIDVMP )
            If !( ! ( l_mdiagnoz_fill ) .or. Empty( mdiagnoz[ 1 ] ) )
              fl := .f.
              s := PadR( mdiagnoz[ 1 ], 6 )
              For j := 1 To Len( arrV019[ i, 3 ] )
                If Left( s, Len( arrV019[ i, 3, j ] ) ) == arrV019[ i, 3, j ]
                  fl := .t.
                  Exit
                Endif
              Next
              If fl
                If Empty( mpztip := ret_pz_vmp( human_2->METVMP, human->k_data ) )
                  mpztip := 1
                Endif
              Else
                AAdd( ta, 'основной диагноз ' + s + ', а у метода ВМП "' + lstr( human_2->METVMP ) + '.' + AllTrim( arrV019[ i, 2 ] ) + '"' )
                AAdd( ta, '└─допустимые диагнозы: ' + print_array( arrV019[ i, 3 ] ) )
              Endif
            Endif
          Else
            AAdd( ta, 'метод ВМП ' + lstr( human_2->METVMP ) + ' не соответствует виду ВМП ' + human_2->VIDVMP )
          Endif
          // elseif ((i := ascan(arrV019, {|x| x[1] == human_2->METVMP .and. x[8] == human_2->PN5 })) > 0) .and. (year(human->k_data)>=2021)
        Elseif ( ( i := AScan( arrV019, {| x| x[ 1 ] == human_2->METVMP .and. x[ 8 ] == human_2->PN5 .and. x[ 4 ] == AllTrim( human_2->VIDVMP ) } ) ) > 0 ) .and. ( Year( human->k_data ) >= 2021 )
          If ( arrV019[ i, 4 ] == AllTrim( human_2->VIDVMP ) ) // .or. (arrV019[i, 4] == '26' .and. alltrim(human_2->VIDVMP) == '27')

            If !( !( l_mdiagnoz_fill ) .or. Empty( mdiagnoz[ 1 ] ) )
              fl := .f. ; s := PadR( mdiagnoz[ 1 ], 6 )
              For j := 1 To Len( arrV019[ i, 3 ] )
                If Left( s, Len( arrV019[ i, 3, j ] ) ) == arrV019[ i, 3, j ]
                  fl := .t. ; Exit
                Endif
              Next
              If fl
                If Empty( mpztip := ret_pz_vmp( human_2->METVMP, human->k_data ) )
                  mpztip := 1
                Endif
              Else
                AAdd( ta, 'основной диагноз ' + s + ', а у метода ВМП "' + lstr( human_2->METVMP ) + '.' + AllTrim( arrV019[ i, 2 ] ) + '"' )
                AAdd( ta, '└─допустимые диагнозы: ' + print_array( arrV019[ i, 3 ] ) )
              Endif
            Endif
          Else
            AAdd( ta, 'метод ВМП ' + lstr( human_2->METVMP ) + ' не соответствует виду ВМП ' + human_2->VIDVMP )
          Endif
        Else
          AAdd( ta, 'Не найден метод ВМП ' + lstr( human_2->METVMP ) + ' в справочнике V019' )
        Endif
      Else
        human_2->VMP     := 0
        human_2->VIDVMP  := ''
        human_2->METVMP  := 0
        human_2->TAL_NUM := ''
        human_2->TAL_D   := CToD( '' )
        human_2->TAL_P   := CToD( '' )
      Endif
    Endif
    // добавим период, если лечился в стационаре
    AAdd( a_period_stac, { human->n_data, ;
      human->k_data, ;
      human_->USL_OK, ;
      human->OTD, ;
      human->kod_diag, ;
      human_->profil, ;
      human_->RSLT_NEW, ;
      human_->ISHOD_NEW, ;
      iif( is_s_dializ, 1, 0 ) } )
  Elseif human_->USL_OK == USL_OK_DAY_HOSPITAL .and. kol_ksg > 0 // дневной стационар
    If kol_ksg > 1
      AAdd( ta, 'введено более одной КСГ' )
    Endif
    mpztip := 55 // 55, 'случай лечения', 'случ.лечен'}, ;
    mpzkol := kol_55_1
    If Empty( kol_55_1 )
      AAdd( ta, 'не введена услуга пациенто-день 55.1.*' )
    Elseif is_reabil // реабилитация
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          If !( AllTrim( au_lu[ i, 1 ] ) == '55.1.4' )
            AAdd( ta, 'неверная услуга ' + RTrim( au_lu[ i, 1 ] ) + ', должна быть 55.1.4' )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;  // 1-mdate
          au_lu[ i, 7 ], ;  // 2-c4tod(mdate_u2)
          au_lu[ i, 3 ], ;  // 3-hu_->profil
          au_lu[ i, 4 ], ;  // 4-hu_->PRVS
          au_lu[ i, 6 ], ;  // 5-hu->kol_1
          au_lu[ i, 9 ] } )  // 6-номер записи
        Endif
      Next
      If Len( a_1_11 ) == 1
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, 'дата начала услуги 55.1.4 должна равняться дате начала лечения' )
        Endif
        If a_1_11[ 1, 2 ] != dEnd
          Select HU
          Goto ( a_1_11[ 1, 6 ] )
          hu_->( my_rec_lock( a_1_11[ 1, 6 ] ) )
          hu_->date_u2 := cd2
        Endif
      Else
        AAdd( ta, 'услуга 55.1.4 должна встречаться один раз' )
      Endif
    Else // остальные койко-дни
      a_1_11 := {}
      s := ''
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          If Empty( s )
            s := au_lu[ i, 1 ]
          Endif
          If !( au_lu[ i, 1 ] == s ) // не смешивать разные 55.1.*
            AAdd( ta, 'неверная услуга ' + au_lu[ i, 1 ] )
          Elseif !eq_any( AllTrim( au_lu[ i, 1 ] ), '55.1.1', '55.1.2', '55.1.3' )
            AAdd( ta, 'неверная услуга ' + RTrim( au_lu[ i, 1 ] ) )
          Endif
          AAdd( a_1_11, { au_lu[ i, 2 ], ;   // 1-mdate
          au_lu[ i, 7 ], ;   // 2-c4tod(mdate_u2)
          au_lu[ i, 3 ], ;   // 3-hu_->profil
          au_lu[ i, 4 ], ;   // 4-hu_->PRVS
          au_lu[ i, 6 ], ;   // 5-hu->kol_1
          au_lu[ i, 9 ] } )   // 6-номер записи
        Endif
      Next
      If ( k := Len( a_1_11 ) ) > 0
        ASort( a_1_11, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        If a_1_11[ 1, 1 ] != dBegin
          AAdd( ta, 'дата начала первой услуги 55.1.* должна равняться дате начала лечения' )
        Endif
        For i := 2 To k
          // 1-дата окончания пред.услуги = дата начала след.услуги минус 1
          a_1_11[ i - 1, 2 ] := a_1_11[ i, 1 ] - 1
          // 2-дата окончания пред.услуги = дата начала пред.услуги + дни - 1
          d := a_1_11[ i - 1, 1 ] + a_1_11[ i - 1, 5 ] - 1
          If d > a_1_11[ i - 1, 2 ]
            AAdd( ta, 'дата начала ' + lstr( i ) + '-й услуги 55.1.* должна равняться ' + date_8( d + 1 ) )
          Endif
        Next
        If Empty( ta ) // нет ошибок
          For i := 1 To k
            Select HU
            Goto ( a_1_11[ i, 6 ] )
            hu_->( my_rec_lock( a_1_11[ i, 6 ] ) )
            If i == k
              a_1_11[ i, 2 ] := dEnd   // для последней услуги
              hu_->date_u2 := cd2 // поставим дату окончания лечения
              d := a_1_11[ i, 1 ] + a_1_11[ i, 5 ] - 1
              If d > dEnd
                AAdd( ta, 'дата окончания последней услуги 55.1.* больше даты окончания лечения ' + date_8( d ) )
              Endif
            Else
              hu_->date_u2 := dtoc4( a_1_11[ i, 2 ] ) // перепишем дату окончания
            Endif
          Next
        Endif
      Endif
    Endif
    If Empty( human_->profil )
      AAdd( ta, 'в случае не проставлен профиль' )
    Elseif Empty( human_->PRVS )
      AAdd( ta, 'у лечащего врача в случае не проставлена специальность' )
    Elseif is_reabil // реабилитация
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          fl := .t.
          Exit
        Endif
      Next
      If !fl
        AAdd( ta, 'в услуге 55.1.4 должны повториться диагноз+врач из случая' )
      Endif
    Else // остальные койко-дни
      a_1_11 := {}
      For i := 1 To Len( au_lu )
        If Left( au_lu[ i, 1 ], 5 ) == '55.1.'
          AAdd( a_1_11, { AllTrim( au_lu[ i, 8 ] ), ;
            au_lu[ i, 3 ], ;
            au_lu[ i, 4 ] } )
        Endif
      Next
      For i := 1 To Len( au_flu )
        AAdd( a_1_11, { AllTrim( au_flu[ i, 8 ] ), ;
          au_flu[ i, 3 ], ;
          au_flu[ i, 4 ] } )
      Next
      fl := .f.
      For i := 1 To Len( a_1_11 )
        If l_mdiagnoz_fill .and. AllTrim( mdiagnoz[ 1 ] ) == a_1_11[ i, 1 ] .and. ;
            human_->profil == a_1_11[ i, 2 ] .and. human_->PRVS == a_1_11[ i, 3 ]
          fl := .t.
          Exit
        Endif
      Next
      If !fl
        AAdd( ta, 'в одной из услуг 55.1.* должны повториться диагноз+профиль+врач из случая' )
      Endif
    Endif
    If !Empty( lvidpoms )
      If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.2' } ) > 0 .or. ;
          AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.3' } ) > 0
        //
        //
        If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.3' } ) > 0
          lvidpoms := ret_vidpom_st_dom_licensia( human_->USL_OK, lvidpoms, lprofil )
        Endif
      Else // только для дн.стационара при стационаре смотрим лицензию
        lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms )
      Endif
      If ',' $ lvidpoms
        If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.1' } ) > 0 .or. ;
            AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.4' } ) > 0 .or. ;
            AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == '55.1.6' } ) > 0
          If !( '31' $ lvidpoms )
            AAdd( ta, 'для КСГ=' + shifr_ksg + ' в справочнике Т006 не введён вид помощи 31' )
          Endif
        Else
          If eq_any( human_->PROFIL, 57, 68, 97 ) // терапия,педиатр,врач общ.практики
            If !( '12' $ lvidpoms )
              AAdd( ta, 'для КСГ=' + shifr_ksg + ' в справочнике Т006 не введён вид помощи 12; ' + ;
                'вероятно, в случае не может стоять профиль "терапевт", "педиатр", "врач общ.практики"' )
            Endif
          Else
            If !( '13' $ lvidpoms )
              AAdd( ta, 'для КСГ=' + shifr_ksg + ' в справочнике Т006 не введён вид помощи 13; ' + ;
                'проставьте в случае профиль "терапевт", "педиатр", "врач общ.практики" ' + ;
                'или звоните в ТФОМС об ошибке в справочнике' )
            Endif
          Endif
        Endif
      Endif
    Endif
  Endif
  If Len( a_period_stac ) > 0 // .and. !is_s_dializ .and. !is_dializ .and. !is_perito
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      AAdd( u_other, { hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0, human->n_data, human->k_data, human->OTD } )
      Select HU
      Skip
    Enddo
    Select HU
    Set Relation To
    For i := 1 To Len( u_other )
      If u_other[ i, 5 ] == 0
        usl->( dbGoto( u_other[ i, 1 ] ) )
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, u_other[ i, 7 ] )
          mdate := c4tod( u_other[ i, 2 ] )
          If ( k := AScan( a_period_stac, {| x| x[ 1 ] < mdate .and. mdate < x[ 2 ] } ) ) > 0
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If ( Left( lshifr, 2 ) == '2.' .or. eq_any( Left( lshifr, 3 ), '60.', '70.', '71.', '72.' ) ) ;
                .and. !( Left( lshifr, 5 ) == '60.3.' ) ;
                .and. !( Left( lshifr, 6 ) == '60.10.' ) ;
                .and. is_2_stomat( lshifr, , .t. ) == 0 // не стоматология
              otd->( dbGoto( u_other[ i, 8 ] ) )
              AAdd( ta, 'услуга ' + AllTrim( usl->shifr ) + ' от ' + date_8( mdate ) + ' в случае ' + ;
                date_8( u_other[ i, 6 ] ) + '-' + date_8( u_other[ i, 7 ] ) + ;
                iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
              otd->( dbGoto( a_period_stac[ k, 4 ] ) )
              AAdd( ta, '└>пересекается 222 со случаем стац.лечения ' + ;
                date_8( a_period_stac[ k, 1 ] ) + '-' + date_8( a_period_stac[ k, 2 ] ) + ;
                iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
            Endif
          Endif
        Endif
      Endif
    Next i
    Select HU
    Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  Endif

  u_other := {}
  lshifr := ''
  lshifr1 := ''

  If eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. kol_ksg > 0 .and. human_2->VMP == 0 // не ВМП
    k_data2 := human->k_data
    If human->ishod == 88
      s := 'это двойной случай - он закачивается ' + date_8( k_data2 ) + '; '
      Select HUMAN
      Goto ( human_2->pn4 ) // ссылка на 2-й лист учёта
      k_data2 := human->k_data // переприсваиваем дату окончания лечения
      Goto ( rec_human )
      lDoubleSluch := .t.
    Else
      s := ''
    Endif
    arr_ksg := definition_ksg( 1, k_data2, lDoubleSluch )
    If Empty( arr_ksg[ 2 ] ) // нет ошибок
      If shifr_ksg == arr_ksg[ 3 ] // КСГ определена правильно
        If !( Round( cena_ksg, 2 ) == Round( arr_ksg[ 4 ], 2 ) ) // не та цена
          AAdd( ta, s + 'в л/у для КСГ=' + arr_ksg[ 3 ] + ' стоит цена ' + lstr( cena_ksg, 10, 2 ) + ', а должна быть ' + lstr( arr_ksg[ 4 ], 10, 2 ) )
        Else
          put_str_kslp_kiro( arr_ksg, .f. )
        Endif
      Else // не тот шифр КСГ
        AAdd( ta, s + 'в л/у стоит КСГ=' + AllTrim( shifr_ksg ) + '(' + lstr( cena_ksg, 10, 2 ) + '), а должна быть ' + arr_ksg[ 3 ] + '(' + lstr( arr_ksg[ 4 ], 10, 2 ) + ')' )
      Endif
    Else
      AEval( arr_ksg[ 2 ], {| x| AAdd( ta, s + x ) } )
    Endif
  Endif
  // проверим период, если лечился амбулаторно
  If human_->USL_OK == USL_OK_POLYCLINIC .and. human->ishod < 101 ;// не диспансеризация
    .and. m1novor == human_->NOVOR ;
      .and. !( is_2_80 .or. is_2_82 ) ;// не неотложная помощь
    .and. !( AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) ) ; // не КДП2
    .and. kkt == 0 ; // не отдельно стоящая иссл.процедура
    .and. Len( a_period_amb ) > 0
    For i := 1 To Len( a_period_amb )
//      If a_period_amb[ i, 3 ] == human_->profil .and. ! ( human_->profil == 122 .or. human_->profil == 21 ) // кроме эндокринологии 
      If a_period_amb[ i, 3 ] == human_->profil .and. ! ( eq_any( human_->profil, 122, 21, 97, 11, 29, 17, 53, 56, 68, 75, 4, 100 ) ) ;// кроме эндокринологии 
          .and. ! ( a_period_amb[ i, 6 ] .or. is_2_92_ )  // школы ХНИЗ исключаем
        AAdd( ta, 'данный случай пересекается со случаем амбулаторного лечения' )
        otd->( dbGoto( a_period_amb[ i, 4 ] ) )
        AAdd( ta, '└>с тем же профилем ' + ;
          date_8( a_period_amb[ i, 1 ] ) + '-' + date_8( a_period_amb[ i, 2 ] ) + ;
          iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
        // aadd(ta, '└>данный л/у - запись № ' + lstr(human->(recno())) + ', прошлый л/у - запись № ' + lstr(a_period_amb[i, 5]))
      else
        
        if AScan( collect_uslugi( a_period_amb[ i, 5 ] ), shifr_2_92 ) > 0
          AAdd( ta, 'данный случай школы ХНИЗ пересекается с анологичным случаем школы ХНИЗ' )
        AAdd( ta, '└> ' + ;
          date_8( a_period_amb[ i, 1 ] ) + '-' + date_8( a_period_amb[ i, 2 ] ) + ;
          ' в отделении: ' + ;
          iif( Empty( otd->name ), '', ' [' + AllTrim( otd->name ) + ']' ) )
        endif
      Endif
    Next
  Endif
  If mRSLT_NEW > 0
    human_->RSLT_NEW := mRSLT_NEW // записать доп.диспансеризацию
  Endif
  //
  If is_2_78
    mIDSP := 17 // Законченный случай в поликлинике
    If kvp_2_78 > 1
      AAdd( ta, 'в случае применены ' + lstr( kvp_2_78 ) + ' услуги "2.78.*" (должна быть одна)' )
    Endif
  Endif
  If is_disp_DDS // is_70_5 .or. is_70_6 
    mIDSP := 11 // диспансеризация
    If kvp_70_5 > 1 .and. dEnd < 0d20250901
      AAdd( ta, 'в случае применены ' + lstr( kvp_70_5 ) + ' услуги "70.5.*" (должна быть одна)' )
    Endif
    If kvp_70_6 > 1 .and. dEnd < 0d20250901
      AAdd( ta, 'в случае применены ' + lstr( kvp_70_6 ) + ' услуги "70.6.*" (должна быть одна)' )
    Endif
  Endif
  If is_disp_DVN // is_70_3
    mIDSP := 11 // диспансеризация
    If is_disp_DVN3 // профилактика
      mIDSP := 17 // Законченный случай в поликлинике
    Endif
    If kvp_70_3 > 1
      AAdd( ta, 'в случае применены ' + lstr( kvp_70_3 ) + ' услуг "зак.сл." (должна быть одна)' )
    Endif
  Endif
  If is_prof_PN // is_72_2
    If is_72_2
      a_idsp := { { 30, 'За законченный случай в поликлинике' } }
    Else
      a_idsp := { { 29, 'За посещение в поликлинике' } }
    Endif
    If kvp_72_2 > 1
      AAdd( ta, 'в случае применены ' + lstr( kvp_72_2 ) + ' услуги "72.2.*" (должна быть одна)' )
    Endif
  Endif
  If ( k := Len( a_idsp ) ) == 0 .and. is_dializ
    If Empty( kodKSG )
      a_idsp := { { 28, 'За медицинскую услугу' } }
    Else // КСГ
      a_idsp := { { 33, 'За законченный случай' } }
    Endif
    k := 1
  Endif
  If lTypeLUOnkoDisp
    a_idsp := { { 29, 'За посещение в поликлинике' } }
    k := 1
  Endif
  If k == 0
    AAdd( ta, 'ни в одной из услуг в справочнике ТФОМС не установлен способ оплаты' )
  Elseif k == 1
    midsp := human_->IDSP := a_idsp[ 1, 1 ]
  Else
    ASort( a_idsp, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    If Len( a_idsp ) == 2 .and. a_idsp[ 1, 1 ] == 28 .and. a_idsp[ 2, 1 ] == 33 .and. is_dializ
      del_array( a_idsp, 1 ) // удалить 1-ый элемент массива
      midsp := human_->IDSP := a_idsp[ 1, 1 ]
    Else
      AAdd( ta, 'смешивание способов оплаты: ' + ;
        lstr( a_idsp[ 1, 1 ] ) + '-' + AllTrim( a_idsp[ 1, 2 ] ) + ' и ' + ;
        lstr( a_idsp[ 2, 1 ] ) + '-' + AllTrim( a_idsp[ 2, 2 ] ) )
    Endif
  Endif
  If ( k := Len( a_bukva ) ) == 0
    AAdd( ta, 'ни в одной из услуг в справочнике T002 не установлена буква счёта' )
  Elseif k == 1
    //
  Else
    AAdd( ta, 'смешивание букв счёта: ' + ;
      a_bukva[ 1, 1 ] + '-' + AllTrim( a_bukva[ 1, 2 ] ) + ' и ' + ;
      a_bukva[ 2, 1 ] + '-' + AllTrim( a_bukva[ 2, 2 ] ) )
  Endif
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID .or. is_disp_DRZ
    //
  Elseif l_mdiagnoz_fill .and. AScan( adiag, mdiagnoz[ 1 ] ) == 0
    AAdd( ta, 'основной диагноз ' + RTrim( mdiagnoz[ 1 ] ) + ' не встречается ни в одной услуге' )
  Endif
  //
  If Empty( human_->USL_OK )
    AAdd( ta, 'не заполнено поле "Условия оказания"' )
  Endif
  If Empty( human_->PROFIL )
    AAdd( ta, 'не заполнено поле "Профиль"' )
  Elseif eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    If Empty( human_2->profil_k )
      AAdd( ta, 'в случае не проставлен профиль койки' )
    Else
      If Select( 'PRPRK' ) == 0
        r_use( dir_exe() + '_mo_prprk', cur_dir() + '_mo_prprk', 'PRPRK' )
        // index on str(profil, 3) + str(profil_k, 3) to (cur_dir()+ sbase)
      Endif
      Select PRPRK
      find ( Str( human_->profil, 3 ) + Str( human_2->profil_k, 3 ) )
      If Found()
        If !Empty( prprk->vozr )
          If human->vzros_reb == 0
            If prprk->vozr == 'Д'
              AAdd( ta, 'возраст пациента не соответствует профилю койки' )
            Endif
          Else
            If prprk->vozr == 'В'
              AAdd( ta, 'возраст пациента не соответствует профилю койки' )
            Endif
          Endif
        Endif
        If !Empty( prprk->pol ) .and. !( human->pol == prprk->pol )
          AAdd( ta, 'значение поля "Пол" не соответствует профилю койки' )
        Endif
      Else
        s := ''
        Select PRPRK
        find ( Str( human_->profil, 3 ) )
        Do While prprk->profil == human_->profil .and. !Eof()
          s += '"' + inieditspr( A__MENUVERT, getv020(), prprk->profil_k ) + '" '
          Skip
        Enddo
        If Empty( s )
          AAdd( ta, 'профиль медицинской помощи не оплачивается в ОМС' )
        Else
          AAdd( ta, 'профиль мед.помощи не соответствует профилю койки; допустимый профиль койки: ' + s )
        Endif
      Endif
    Endif
  Endif
  If Empty( human_->IDSP )
    AAdd( ta, 'не заполнено поле "Способ оплаты"' )
  Endif
  If Empty( human_->RSLT_NEW )
    AAdd( ta, 'не заполнено поле "Результат обращения"' )
  Elseif Int( Val( Left( lstr( human_->RSLT_NEW ), 1 ) ) ) != human_->USL_OK
    AAdd( ta, 'в поле "Результат обращения" стоит неверное значение' )
  Endif
  If Empty( human_->ISHOD_NEW )
    AAdd( ta, 'не заполнено поле "Исход заболевания"' )
  Elseif Int( Val( Left( lstr( human_->ISHOD_NEW ), 1 ) ) ) != human_->USL_OK
    AAdd( ta, 'в поле "Исход заболевания" стоит неверное значение' )
  Endif
  If is_2_82
    If human_->profil == 134
      AAdd( ta, 'в случае не должно быть профиля "Приёмного отделения"' )
    Endif
  Endif
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_pren_diagn .or. kol_ksg > 0 ;
      .or. is_2_89 .or. is_reabil ;
      .or. is_disp_DVN_COVID .or. is_disp_DRZ  // .or. is_s_dializ
    If is_reabil  // проводим проверку на профиль при реабилитации
      If human_->profil != 158
        AAdd( ta, 'в случае надо использовать профиль по: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
      Endif

      For i := 1 To Len( au_lu )
        If au_lu[ i, 3 ] == 158 .and. AllTrim( au_lu[ i, 1 ] ) != shifr_ksg
          AAdd( ta, 'нельзя в услуге ' + AllTrim( au_lu[ i, 1 ] ) + ' использовать профиль по: ' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) )
        Endif
      Next

      If is_reabil_slux()
        t_arr := { '1331.0', '1332.0', '1333.0', '1335.0', '2127.0', '2128.0', '2130.0' }
        For i := 1 To Len( t_arr )
          If t_arr[ i ] == shifr_ksg .and. !Between( human_2->PN1, 1, 3 )
            human_2->PN1 := 1
            // aadd(ta, 'в случае реабилитации для КСГ=' + shifr_ksg+ ' необходимо заполнить поле 'вид мед.реабилитации'')
          Endif
        Next
      Endif
    Endif
  Else
    If human_->profil == 158
      AAdd( ta, 'в случае нельзя использовать профиль по: ' + inieditspr( A__MENUVERT, getv002(), 158 ) )
    Endif
    arr_profil := { human_->profil }
    For i := 1 To Len( au_lu )
      If au_lu[ i, 10 ] >= 0 .and. AScan( arr_profil, au_lu[ i, 3 ] ) == 0
        AAdd( arr_profil, au_lu[ i, 3 ] )
      Endif
    Next
    For i := 1 To Len( au_flu )
      If AScan( arr_profil, au_flu[ i, 3 ] ) == 0
        AAdd( arr_profil, au_flu[ i, 3 ] )
      Endif
    Next
    If Len( arr_profil ) > 1
      If human_->USL_OK == USL_OK_AMBULANCE // 4 - если скорая помощь
        human_->profil := au_lu[ 1, 3 ]
      Else
        AAdd( ta, 'в случае использован профиль по: ' + inieditspr( A__MENUVERT, getv002(), arr_profil[ 1 ] ) )
        For i := 2 To Len( arr_profil )
          AAdd( ta, '                  а в услуге по: ' + inieditspr( A__MENUVERT, getv002(), arr_profil[ i ] ) )
        Next
      Endif
    Elseif Empty( arr_profil[ 1 ] )
      AAdd( ta, 'в случае не проставлен профиль' )
    Endif
    //
    If AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
      // не проверять
    Else
      arr_prvs := { human_->PRVS }
      For i := 1 To Len( au_lu )
        If au_lu[ i, 10 ] >= 0 .and. AScan( arr_prvs, au_lu[ i, 4 ] ) == 0
          AAdd( arr_prvs, au_lu[ i, 4 ] )
        Endif
      Next
      For i := 1 To Len( au_flu )
        If AScan( arr_prvs, au_flu[ i, 4 ] ) == 0
          AAdd( arr_prvs, au_flu[ i, 4 ] )
        Endif
      Next
      If Len( arr_prvs ) > 1 .and. !is_gisto
        AAdd( ta, 'в случае использованы разные специальности врачей' )
      Endif
    Endif
  Endif
  If lstkol > 0
    lstshifr += '*'
    If lstkol > 1
      AAdd( ta, 'кол-во услуг ' + lstshifr + ' (' + lstr( lstkol ) + ') более 1' )
    Endif
    If Len( au_lu ) > 1 .and. kol_ksg == 0
      If is_2_78 .or. is_2_89 .or. is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2 .or. is_2_92_ .or. is_disp_DRZ
        //
      Else
        AAdd( ta, 'кроме услуги ' + lstshifr + ' в листе учета не должно быть других услуг ТФОМС' )
      Endif
    Endif

    // проверка школы диабета
    If kol_2_93_1 > 0 .and. ! is_2_92_
      AAdd( ta, 'в случае небходима ' + iif( vozrast < 18, 'услуга 2.92.3', 'одна из услуг 2.92.1 или 2.92.2' ) )
    Endif
    If kol_2_93_2 > 0 .and. ! is_2_92_
      AAdd( ta, 'в случае небходима + одна из услуг 2.92.4, 2.92.5, 2.92.6, 2.92.7, 2.92.8, 2.92.9, 2.92.10, 2.92.11, 2.92.12 или 2.92.13' )
    Endif

    If is_2_92_
      diabetes_school_xniz( shifr_2_92, vozrast, kol_dney, kol_2_93_1, kol_2_93_2, human_->RSLT_NEW, human_->ISHOD_NEW, ta )

      // If !eq_any( human_->RSLT_NEW, 314 )
      //   AAdd( ta, 'в поле "Результат обращения" должно быть "314 Динамическое наблюдение"' )
      // Endif
      // If !eq_any( human_->ISHOD_NEW, 304 )
      //   AAdd( ta, 'в поле "Исход заболевания" должно быть "304 Без перемен"' )
      // Endif

      // s := 'услуга 2.93.1 оказывается не менее '
      // If vozrast < 18 .and. kol_2_93_1 < 10
      //   AAdd( ta, s + ' 10 раз' )
      // Elseif vozrast >= 18 .and. kol_2_93_1 < 5
      //   AAdd( ta, s + ' 5 раз' )
      // Endif
      // If vozrast < 18 .and. kol_dney < 10
      //   AAdd( ta, s + ' 10 дней' )
      // Elseif vozrast >= 18 .and. kol_dney < 5
      //   AAdd( ta, s + ' 5 дней' )
      // Endif
      // конец проверки школ диабета и НХИЗ
    Endif
  Endif
  s := '2.60.*'
  If is_2_78
    is_1_den := is_last_den := .f.
    zs := oth_usl := 0
    am := {}
    For i := 1 To Len( au_lu )
      If Left( au_lu[ i, 1 ], 5 ) == '2.78.'
        ++zs
      Elseif Left( au_lu[ i, 1 ], 4 ) == '2.60'
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
        If ( j := AScan( am, {| x| x[ 1 ] == Month( au_lu[ i, 2 ] ) } ) ) == 0
          AAdd( am, { Month( au_lu[ i, 2 ] ), 0 } ) ; j := Len( am )
        Endif
        am[ j, 2 ] ++
      Elseif au_lu[ i, 10 ] >= 0 .and. !( AllTrim( au_lu[ i, 1 ] ) == '4.27.2' )
        ++oth_usl
      Endif
    Next
    j := Len( am )
    If !is_last_den .and. j > 0
      ASort( am, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      If Month( dEnd ) - am[ j, 1 ] > 1 .and. Year( dBegin ) == Year( dEnd )
        AAdd( ta, 'в предыдущем месяце не оказано врачебных приёмов' )
      Endif
    Endif
    If zs > 1
      AAdd( ta, 'в листе учета более одной услуги "законченный случай"' )
    Endif
    If oth_usl > 0
      AAdd( ta, 'кроме услуги ' + lstshifr + ' и ' + s + ' в листе учета не должно быть других услуг' )
    Endif
    If kol_2_60 == 0
      AAdd( ta, 'не оказано ни одной услуги ' + s )
    Else
      If !is_1_den
        AAdd( ta, 'первая услуга ' + s + ' должна быть оказана в первый день лечения' )
      Elseif human_->RSLT_NEW != 302
        If kol_2_60 < 2
          AAdd( ta, 'кроме услуги ' + lstshifr + ' в листе учета должно быть не менее двух услуг ' + s )
        Endif
        If !is_last_den
          AAdd( ta, 'последняя услуга ' + s + ' должна быть оказана в последний день лечения' )
        Endif
      Endif
    Endif
  Elseif kvp_2_79 > 1
    s := '2.79.*'
    AAdd( ta, 'услуга ' + s + ' должна быть единственной в случае' )
  Elseif is_2_89 // медицинская реабилитация (физкультурный диспансер и другие)
    If dBegin == dEnd
      AAdd( ta, 'время лечения не должно равняться одному дню' )
    Endif
    If Empty( human_->NPR_MO )
      AAdd( ta, 'не заполнено "Направившая МО", в которой пациент имел прикрепление' )
    Else
      If Empty( human_2->NPR_DATE )
        AAdd( ta, 'должно быть заполнено поле "Дата направления на лечение"' )
      Elseif human_2->NPR_DATE > dBegin
        AAdd( ta, '"Дата направления на лечение" больше "Даты начала лечения"' )
      Elseif human_2->NPR_DATE + 60 < dBegin
        AAdd( ta, 'Направлению на лечение больше двух месяцев' )
      Endif
      // 10.07.23 после звонка Мызгину
      // if !(eq_any(glob_mo[_MO_KOD_TFOMS], '103001', '104401') .or. ret_mo(human_->NPR_MO)[_MO_IS_UCH])
      // aadd(ta, 'введена "Направившая МО", которая не имеет право прикреплять пациентов')
      // endif
    Endif
    aps := {} // сочетание профиля и специальности
    human_->profil := 158  // медицинской реабилитации
    is_1_den := is_last_den := .f.
    zs := km := oth_usl := 0
    s := ''
    shifr_zs := ''
    For i := 1 To Len( au_lu )
      If Left( au_lu[ i, 1 ], 5 ) == '2.89.'
        shifr_zs := au_lu[ i, 1 ]
        Exit
      Endif
    Next
    For i := 1 To Len( au_lu )
      alltrim_lshifr := AllTrim( au_lu[ i, 1 ] )
      left_lshifr_2 := Left( au_lu[ i, 1 ], 2 )
      left_lshifr_3 := Left( au_lu[ i, 1 ], 3 )
      left_lshifr_4 := Left( au_lu[ i, 1 ], 4 )
      left_lshifr_5 := Left( au_lu[ i, 1 ], 5 )
      If !Between( au_lu[ i, 2 ], dBegin, dEnd )
        AAdd( ta, 'дата услуги ' + alltrim_lshifr + ' вне диапазона лечения (' + date_8( au_lu[ i, 2 ] ) + ')' )
      Endif
      If l_mdiagnoz_fill .and. !( AllTrim( mdiagnoz[ 1 ] ) == AllTrim( au_lu[ i, 8 ] ) )
        AAdd( ta, 'в услуге ' + alltrim_lshifr + ' должен стоять основной диагноз' )
      Endif
      If left_lshifr_5 == '2.89.'
        zs += au_lu[ i, 6 ]
      Elseif left_lshifr_4 == '2.6.'  // .and. (! lTypeLUMedReab)
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Elseif dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
        If au_lu[ i, 6 ] != 1
          AAdd( ta, 'в услуге ' + alltrim_lshifr + ' количество не должно быть больше 1' )
        Endif
      Elseif AScan( arr_lfk, alltrim_lshifr ) > 0
        ++km
        If eq_any( alltrim_lshifr, '4.2.153', '4.11.136', '3.4.31' ) .and. au_lu[ i, 6 ] != 1
          AAdd( ta, 'в услуге ' + alltrim_lshifr + ' количество не должно быть больше 1' )
        Endif
        If au_lu[ i, 6 ] > 1 .and. au_lu[ i, 2 ] + au_lu[ i, 6 ] - 1 > dEnd
          AAdd( ta, 'дата окончания услуги ' + alltrim_lshifr + ' больше даты окончания лечения' )
        Endif
        //
        fl_not_2_89 := .f.
        If lTypeLUMedReab
          obyaz_uslugi_med_reab := compulsory_services( list2arr( human_2->PC5 )[ 1 ], list2arr( human_2->PC5 )[ 2 ], M1VZROS_REB == 0, iif( len( list2arr( human_2->PC5 ) ) > 2, list2arr( human_2->PC5 )[ 3 ], 0 ) )
          For Each row in arrUslugi // проверим все услуги случая
            If ( iUsluga := AScan( obyaz_uslugi_med_reab, {| x| AllTrim( x ) == AllTrim( row ) } ) ) > 0
              hb_ADel( obyaz_uslugi_med_reab, iUsluga, .t. )
            Endif
          Next
          If Len( obyaz_uslugi_med_reab ) > 0
            For Each row in obyaz_uslugi_med_reab
              AAdd( ta, 'отсутствует обязательная услуга для медицинской реабилитации "' + AllTrim( row ) + '"' )
            Next
          Endif

          aUslMedReab := ret_usluga_med_reab( alltrim_lshifr, list2arr( human_2->PC5 )[ 1 ], list2arr( human_2->PC5 )[ 2 ], M1VZROS_REB == 0, iif( len( list2arr( human_2->PC5 ) ) > 2, list2arr( human_2->PC5 )[ 3 ], 0 ) )
          If aUslMedReab != Nil .and. Len( aUslMedReab ) != 0
            If aUslMedReab[ 3 ] > au_lu[ i, 6 ]
              AAdd( ta, 'для услуги ' + alltrim_lshifr + ' требуется минимум ' + lstr( aUslMedReab[ 3 ] ) + ' предоставлений!' )
            Endif
            If aUslMedReab[ 3 ] > 1 .and. ( count_days( au_lu[ i, 2 ], au_lu[ i, 11 ] ) < aUslMedReab[ 3 ] )
              AAdd( ta, 'количество дней выполнения услуги меньше количества повторений услуги!' )
            Endif
          Endif
        Else
          If left_lshifr_3 == '20.' // ЛФК
            atmp := { '20.1.2', '20.1.1', '20.1.3', '20.1.1', '20.1.1' }
            For j := 6 To 12
              AAdd( atmp, '20.1.4' )
            Next
            For j := 13 To 14
              AAdd( atmp, '20.1.5' )
            Next
            AAdd( atmp, '20.2.3' ) // j=15 ЛФК с исп-ием телемедицины
            If AScan( atmp, alltrim_lshifr ) > 0
              For j := 1 To 15
                If a_2_89[ j ] == 1 .and. !( alltrim_lshifr == atmp[ j ] )
                  fl_not_2_89 := .t.
                Endif
              Next
            Endif
            If alltrim_lshifr == '20.2.1' .and. emptyall( a_2_89[ 1 ], a_2_89[ 4 ], a_2_89[ 5 ] )
              fl_not_2_89 := .t.
            Elseif alltrim_lshifr == '20.2.2' .and. Empty( a_2_89[ 3 ] )
              fl_not_2_89 := .t.
            Endif
          Elseif left_lshifr_3 == '21.' // массаж
            // кроме онкологии
            atmp := { '21.1.2', '21.1.1', '21.1.3', '21.1.1', '21.1.1' }
            If AScan( atmp, alltrim_lshifr ) > 0
              For j := 1 To Len( atmp )
                If a_2_89[ j ] == 1 .and. !( alltrim_lshifr == atmp[ j ] )
                  fl_not_2_89 := .t.
                Endif
              Next
            Endif
            // онкология
            If alltrim_lshifr == '21.1.4' .and. emptyall( a_2_89[ 6 ], a_2_89[ 7 ], a_2_89[ 9 ], a_2_89[ 10 ] )
              fl_not_2_89 := .t.
            Endif
            If alltrim_lshifr == '21.2.1' .and. emptyall( a_2_89[ 6 ], a_2_89[ 7 ], a_2_89[ 8 ], a_2_89[ 9 ], a_2_89[ 11 ] )
              fl_not_2_89 := .t.
            Endif
            // 2.89.25 'Обращение с целью медицинской реабилитации пациентов при лечении органов дыхания'
            If alltrim_lshifr == '21.1.5' .and. Empty( a_2_89[ 14 ] )
              fl_not_2_89 := .t.
            Endif
          Elseif left_lshifr_3 == '22.' // рефлексотерапия
            // кроме онкологии
            atmp := { '22.1.2', '22.1.1', '22.1.3', '22.1.1', '22.1.1' }
            If AScan( atmp, alltrim_lshifr ) > 0
              For j := 1 To 5
                If a_2_89[ j ] == 1 .and. !( alltrim_lshifr == atmp[ j ] )
                  fl_not_2_89 := .t.
                Endif
              Next
            Endif
          Endif
          If zs > 1
            AAdd( ta, 'в листе учета более одной услуги 2.89.* "законченный случай"' )
          Endif
          If kol_2_6 < 2
            AAdd( ta, 'кроме услуги ' + lstshifr + ' в листе учета должно быть две и более услуг 2.6.*' )
          Endif
        Endif
        If fl_not_2_89
          AAdd( ta, 'услуга ' + alltrim_lshifr + ' не входит в набор услуг для обращения с целью медицинской реабилитации ' + shifr_zs )
        Endif
      Else
        s += alltrim_lshifr + ' '
        ++oth_usl
      Endif
    Next
    If oth_usl > 0
      AAdd( ta, 'в листе учета не должно быть данных услуг: ' + s )
    Endif
    If kol_2_6 > 0
      If !is_1_den
        AAdd( ta, 'первая услуга 2.6.* должна быть оказана в первый день лечения' )
      Endif
      If !is_last_den
        AAdd( ta, 'последняя услуга 2.6.* должна быть оказана в последний день лечения' )
      Endif
    Endif
    If km == 0
      AAdd( ta, 'в листе учета нет ни одной услуги "манипуляция"' )
    Endif
  Elseif is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
    //
  Elseif kol_2_60 > 0
    AAdd( ta, 'вместе с услугами ' + s + ' должна быть услуга "законченный случай"' )
  Endif
  d := human->k_data - human->n_data
  If kkd > 0
    If Empty( d ) .and. kkd == 1
      // по-новому один койко-день
    Elseif kkd > d
      AAdd( ta, 'кол-во койко-дней (' + lstr( kkd ) + ') превышает срок лечения на ' + lstr( kkd - d ) )
    Elseif kkd < d
      AAdd( ta, 'кол-во койко-дней (' + lstr( kkd ) + ') меньше срока лечения на ' + lstr( d - kkd ) )
    Endif
  Elseif kds > 0
    If kds > ( d + 1 )
      AAdd( ta, 'кол-во услуг дневного стационара (' + lstr( kds ) + ') превышает срок лечения на ' + lstr( kds - ( d + 1 ) ) )
    Endif
    If is_eko
      If human_->PROFIL != 137
        AAdd( ta, 'для КСГ=' + shifr_ksg + ' профиль должен быть по "акушерству и гинекологии (использованию вспомогательных репродуктивных технологий)"' )
      Endif
      a_1_11 := {}
      For i := 1 To Len( au_flu )
        AAdd( a_1_11, AllTrim( au_flu[ i, 1 ] ) )
      Next
      j := 1 // КСЛП - 1 схема
      If AScan( a_1_11, 'A11.20.031' ) > 0  // крио
        j := 6  // 6 схема
        If AScan( a_1_11, 'A11.20.028' ) > 0 // третий этап
          j := 2   // 2 схема
        Endif
      Elseif AScan( a_1_11, 'A11.20.025.001' ) > 0  // первый этап
        j := 3  // 3 схема
        If AScan( a_1_11, 'A11.20.036' ) > 0  // завершающий второй этап
          j := 4  // 4 схема
        Elseif AScan( a_1_11, 'A11.20.028' ) > 0  // завершающий третий этап
          j := 5  // 5 схема
        Endif
      Elseif AScan( a_1_11, 'A11.20.030.001' ) > 0  // только четвертый этап
        j := 7  // 7 схема
      Endif
      ashema := { ;
        { 'A11.20.017' }, ;
        { 'A11.20.017', 'A11.20.028', 'A11.20.031' }, ;
        { 'A11.20.017', 'A11.20.025.001' }, ;
        { 'A11.20.017', 'A11.20.025.001', 'A11.20.036' }, ;
        { 'A11.20.017', 'A11.20.025.001', 'A11.20.028' }, ;
        { 'A11.20.017', 'A11.20.031' }, ;
        { 'A11.20.017', 'A11.20.030.001' };
        }
      If ( k := Len( ashema[ j ] ) ) == ( n := Len( a_1_11 ) )
        //
      Elseif k > n
        AAdd( ta, 'в листе учёта по ЭКО не хватает услуг ' + print_array( a_1_11 ) )
      Elseif k < n
        For i := 1 To k
          If ( n := AScan( a_1_11, ashema[ j, i ] ) ) > 0
            del_array( a_1_11, n )
          Endif
        Next
        If Len( a_1_11 ) > 0
          AAdd( ta, 'в листе учёта по ЭКО лишние услуги ' + print_array( a_1_11 ) )
        Endif
      Endif
    Endif
  Elseif kkt > 0 .and. !is_s_dializ .and. !is_dializ .and. !is_perito
    mPZTIP := 66 // 66, 'Р-исследование', 'Р-исслед.'}, ;
    mPZKOL := kkt
    If !emptyall( kkd, kds, kvp, ksmp )
      AAdd( ta, 'кроме услуг 60.* в листе учета не должно быть других услуг ТФОМС' )
    Endif
    If human_->USL_OK != USL_OK_POLYCLINIC
      AAdd( ta, 'в поле "Условия оказания" должно быть "Поликлиника"' )
    Endif
    If is_kt
      s := 'КТ'
    Elseif is_mrt
      s := 'МРТ'
    Elseif is_uzi
      s := 'УЗИ ССС'
    Elseif is_endo
      s := 'эндоскопии'
    Elseif is_gisto
      s := 'гистологии'
    Elseif is_mgi
      s := 'молекулярной генетики'
    Elseif is_g_cit
      s := 'жидкостной цитологии'
      mPZTIP := 68 // 68, 'жидкостная цитология', 'жидк.цитол'}, ;
    Elseif is_pr_skr
      s := 'пренатального скрининга'
      mPZTIP := 67 // 67, 'пренатальный скрининг', 'прен.скрин'}, ;
    Endif
    If Empty( human_->NPR_MO )
      AAdd( ta, 'для ' + s + ' должно быть заполнено "Направившая МО"' )
    Elseif Empty( human_2->NPR_DATE )
      If glob_mo[ _MO_KOD_TFOMS ] == ret_mo( human_->NPR_MO )[ _MO_KOD_TFOMS ]
        human_2->NPR_DATE := dBegin
      Else
        AAdd( ta, 'должно быть заполнено поле "Дата направления"' )
      Endif
    Elseif human_2->NPR_DATE > dBegin
      AAdd( ta, '"Дата направления" больше "Даты начала лечения"' )
    Elseif human_2->NPR_DATE + 60 < dBegin
      AAdd( ta, 'Направлению больше двух месяцев' )
    Endif
    If !eq_any( human_->RSLT_NEW, 314 )
      AAdd( ta, 'в поле "Результат обращения" должно быть "314 Динамическое наблюдение"' )
    Endif
    If !eq_any( human_->ISHOD_NEW, 304 )
      AAdd( ta, 'в поле "Исход заболевания" должно быть "304 Без перемен"' )
    Endif
    If is_g_cit .or. is_pr_skr
      If kkt > 1
        AAdd( ta, 'кол-во услуг ' + s + ' (' + lstr( kkt ) + ') не должно быть более 1' )
      Endif
      If human_->PROFIL != 34
        AAdd( ta, 'для ' + s + ' профиль должен быть КЛИНИЧЕСКАЯ ЛАБОРАТОРНАЯ ДИАГНОСТИКА' )
      Endif
    Else
      If is_oncology == 2
        // повод обращения - диагностика уже проверен выше
      Elseif PadR( mdiagnoz[ 1 ], 5 ) == 'Z03.1'
        // if is_gisto
        // aadd(ta, 'для ' + s + ' не может быть установлен основной диагноз 'Z03.1 наблюдение при подозрении на злокачественную опухоль'')
        // endif
      Elseif is_kt
        If !( PadR( mdiagnoz[ 1 ], 5 ) == 'Z01.6' )
          AAdd( ta, 'для ' + s + ' основной диагноз должен быть Z01.6' )
        Endif
      Elseif is_mrt .or. is_uzi .or. is_endo
        If !( PadR( mdiagnoz[ 1 ], 5 ) == 'Z01.8' )
          AAdd( ta, 'для ' + s + ' основной диагноз должен быть Z01.8' )
        Endif
      Elseif is_gisto
        AAdd( ta, 'для ' + s + ' основной диагноз не может быть ' + RTrim( mdiagnoz[ 1 ] ) + ;
          ' (кроме онкологического диагноза разрешается использовать только Z03.1)' )
      Endif
    Endif
    fl := .t.
    For i := 1 To Len( au_lu )
      If au_lu[ i, 2 ] == dBegin
        fl := .f. ; Exit
      Endif
    Next
    If fl
      AAdd( ta, 'для ' + s + ' одна из услуг должна быть оказана в день начала лечения' )
    Endif
  Elseif kvp > 0
    mPZKOL := kvp - kvp_2_78 - kvp_2_89
    If mIDSP == 12
      mPZTIP := 60 // 60, 'Посещение профилактическое Центра здоровья', 'ПосПроф.ЦЗ'}, ;
      If kvp > 1 // Комплексная услуга центра здоровья
        AAdd( ta, 'в центре здоровья введено ' + lstr( kvp ) + ' услуги (должна быть одна)' )
      Endif
    Endif
    If dEnd > dBegin
      If is_2_88
        If Month( dBegin ) == Month( dEnd )
          AAdd( ta, 'для данной услуги срок лечения - один день' )
        Elseif Month( dEnd ) - Month( dBegin ) > 1 .and. Year( dBegin ) == Year( dEnd )
          AAdd( ta, 'для данной услуги срок лечения не может быть более месяца' )
        Endif
      Elseif is_2_80 .or. is_2_81 .or. is_2_82 .or. is_pren_diagn
        AAdd( ta, 'для данной услуги срок лечения - один день' )
      Endif
    Endif
    If kvp > 1 .and. ( is_2_80 .or. is_2_81 .or. is_2_82 .or. is_2_88 )
      AAdd( ta, 'количество услуг должно быть равно 1' )
    Endif
    If is_2_78 .or. is_2_89
      // mpztip := 59 // 59, 'Обращение', 'амб.обращ.'}, ;
      mPZKOL := 1 // ???
    Elseif is_2_79 .or. is_2_81 .or. is_2_88
      // mpztip := 57 // 57, 'Посещение профилактическое', 'амб.проф.'}, ;
    Elseif is_2_80 .or. is_2_82
      // mpztip := 58 // 58, 'Посещение неотложное', 'амб.неотл.'}, ;
    Endif
  Elseif ksmp > 0
    mpztip := 51 // 51, 'Вызов СМП', 'вызов СМП'}, ;
    mpzkol := ksmp
    If ksmp > 1
      AAdd( ta, 'количество услуг СМП должно быть равно 1' )
    Endif
    If Len( au_lu ) > 1
      AAdd( ta, 'кроме услуги 71.* в листе учета не должно быть других услуг ТФОМС' )
    Endif
    If human_->USL_OK != USL_OK_AMBULANCE // 4
      AAdd( ta, 'для услуги СМП условия должны быть "Скорая помощь"' )
    Endif
    If human_->IDSP != 24
      AAdd( ta, 'для услуги СМП способ оплаты должен быть "Вызов скорой медицинской помощи"' )
    Endif
    If dBegin < dEnd
      AAdd( ta, 'для скорой помощи дата начала должна равняться дате окончания лечения' )
    Endif
    If ( is_komm_smp() .and. dEnd < 0d20190501 ) .or. ( is_komm_smp() .and. dEnd > 0d20220101 ) // если это коммерческая скорая
      If is_71_1
        AAdd( ta, 'для коммерческой СМП необходимо применять услуги 71.2.*' )
      Endif
    Elseif Empty( human_->OKATO ) .or. human_->OKATO == '18000'
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
  If is_dializ
    s := 'гемодиализа'
    If kds > 0 .and. kol_ksg == 0
      AAdd( ta, 'для ' + s + ' не вводится пациенто-день' )
    Endif
    If !eq_any( human_->PROFIL, 56 ) // НЕФРОЛОГИЯ
      AAdd( ta, 'для ' + s + ' профиль должен быть НЕФРОЛОГИЯ' )
    Endif
    If !eq_any( ret_old_prvs( human_->PRVS ), 112207, 113412 ) // НЕФРОЛОГИЯ
      AAdd( ta, 'для ' + s + ' специальность врача должна быть НЕФРОЛОГИЯ' )
    Endif
    If glob_mo[ _MO_KOD_TFOMS ] == '101004' // УНЦ
      If Empty( AllTrim( human_->NPR_MO ) )
        human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // безусловно проставляем направившую МО
        human_2->( g_rlock( forever ) )
        human_2->NPR_DATE := dBegin
        human_2->( dbUnlock() )
      Endif
    Elseif ! glob_mo[ _MO_KOD_TFOMS ] == '141023' // не больница 15, временно пока не разберемся
      human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // безусловно проставляем направившую МО
      human_2->( g_rlock( forever ) )
      human_2->NPR_DATE := dBegin
      human_2->( dbUnlock() )
    Endif
    mpztip := 56 // 56, 'случай диализа', 'случ.диал.'}, ;
    mpzkol := kkt
  Endif
  If is_perito
    s := 'для ПЕРИТОНЕАЛЬНОГО ДИАЛИЗА '
    If human_->PROFIL != 56
      AAdd( ta, s + 'профиль должен быть НЕФРОЛОГИЯ' )
    Endif
    If !eq_any( ret_old_prvs( human_->PRVS ), 112207, 113412 ) // НЕФРОЛОГИЯ
      AAdd( ta, s + 'специальность врача должна быть НЕФРОЛОГИЯ' )
    Endif
    If glob_mo[ _MO_KOD_TFOMS ] == '101004' // УНЦ
      If Empty( AllTrim( human_->NPR_MO ) )
        human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // безусловно проставляем направившую МО
        human_2->( g_rlock( forever ) )
        human_2->NPR_DATE := dBegin
        human_2->( dbUnlock() )
      Endif
    Elseif ! glob_mo[ _MO_KOD_TFOMS ] == '141023' // не больница 15, временно пока не разберемся
      human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // безусловно проставляем направившую МО
      human_2->( g_rlock( forever ) )
      human_2->NPR_DATE := dBegin
      human_2->( dbUnlock() )
    Endif
    mpztip := 56 // 56, 'случай диализа', 'случ.диал.'}, ;
    mpzkol := kkt
  Endif
  If is_s_dializ
    s := 'услуги диализа в стационаре'
    If glob_mo[ _MO_KOD_TFOMS ] == '101004' // УНЦ
      If Empty( AllTrim( human_->NPR_MO ) )
        human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // безусловно проставляем направившую МО
        human_2->( g_rlock( forever ) )
        human_2->NPR_DATE := dBegin
        human_2->( dbUnlock() )
      Endif
    Elseif ! glob_mo[ _MO_KOD_TFOMS ] == '141023' // не больница 15, временно пока не разберемся
      human_->NPR_MO := glob_mo[ _MO_KOD_TFOMS ] // безусловно проставляем направившую МО
      human_2->( g_rlock( forever ) )
      human_2->NPR_DATE := dBegin
      human_2->( dbUnlock() )
    Endif
    mpztip := 54 // 54, 'случай ЗПТ', 'случай ЗПТ'}, ;
    mpzkol := kkt
    For i := 1 To Len( a_dializ )
      j := a_dializ[ i, 5 ] - 1
      If !Between( j, 1, 2 )
        j := 1
      Endif
      If overlap_diapazon( a_dializ[ i, 1 ], a_dializ[ i, 2 ], dBegin, dEnd ) .or. eq_any( dBegin, a_dializ[ i, 1 ], a_dializ[ i, 2 ] ) ;
          .or. eq_any( dEnd, a_dializ[ i, 1 ], a_dializ[ i, 2 ] )
        AAdd( ta, 'услуга диализа в стационаре пересекается со случаем ' + { 'гемо', 'перитонеального ' }[ j ] + 'диализа ' + date_8( a_dializ[ i, 1 ] ) + '-' + date_8( a_dializ[ i, 2 ] ) )
      Endif
    Next
    For i := 1 To Len( a_srok_lech )
      otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
      If a_srok_lech[ i, 5 ] == 1
        otd->( dbGoto( a_srok_lech[ i, 4 ] ) )
        AAdd( ta, 'пересечение с аналогичным диализом ' + date_8( a_srok_lech[ i, 1 ] ) + '-' + date_8( a_srok_lech[ i, 2 ] ) + ;
          iif( Empty( otd->short_name ), '', ' [' + AllTrim( otd->short_name ) + ']' ) )
      Endif
    Next
  Endif
  If is_disp_DDS //
    metap := 1
    m1mobilbr := 0
    human->OBRASHEN := ''
    tip_lu := iif( !Empty( human->ZA_SMO ), TIP_LU_DDS, TIP_LU_DDSOP )
    If yearBegin != yearEnd
      AAdd( ta, 'дата начала и окончания случая должны быть в одном году' )
    Endif
    If eq_any( human->ishod, 101, 102 )
      metap := human->ishod -100
      read_arr_dds( human->kod )
    Else
      AAdd( ta, 'диспансеризацию детей-сирот надо вводить через специальный экран ввода' )
    Endif
    is_1_den := is_last_den := .f.
    zs := kvp := 0
    oth_usl := ''
    For i := 1 To Len( au_lu )
      If au_lu[ i, 3 ] == 0
        AAdd( ta, 'в услуге ' + AllTrim( au_lu[ i, 1 ] ) + ' не проставлен профиль' )
      Endif
      If au_lu[ i, 4 ] == 0
        AAdd( ta, 'в услуге ' + AllTrim( au_lu[ i, 1 ] ) + ' не проставлена спец-ть врача' )
      Endif
      If au_lu[ i, 2 ] > dEnd
        AAdd( ta, 'услуга ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ') не попадает в диапазон лечения' )
      Endif
      If is_issl_dds( au_lu[ i ], mvozrast, ta, human->K_DATA )
        s := 'услуга ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ')'
        If AllTrim( au_lu[ i, 1 ] ) == '7.61.3'
          If au_lu[ i, 2 ] < AddMonth( dBegin, -12 )
            AAdd( ta, 'флюорография оказана более 1 года назад' )
          Endif
        Elseif mvozrast < 2
          If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
            AAdd( ta, s + ' оказана более 1 месяца назад' )
          Endif
        Else
          If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
            AAdd( ta, s + ' оказана более 3 месяцев назад' )
          Endif
        Endif
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
      Else
        s := 'услуга ' + au_lu[ i, 5 ] + '-' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) + '(' + date_8( au_lu[ i, 2 ] ) + ')'
        If is_osmotr_dds_1_etap( au_lu[ i ], mvozrast, metap, mpol, tip_lu, human->K_DATA ) // eq_any(alltrim(au_lu[i, 5]),'2.3.1','2.4.1') // + 2.4.1-психиатр
          If eq_any( au_lu[ i, 3 ], 68, 57 ) // педиатр (врач общей практики)
            If au_lu[ i, 2 ] < dBegin
              AAdd( ta, 'дата осмотра педиатра на I этапе не попадает в диапазон лечения' )
            Endif
          Elseif mvozrast < 2
            If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
              AAdd( ta, s + ' оказана более 1 месяца назад' )
            Endif
          Else
            If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
              AAdd( ta, s + ' оказана более 3 месяцев назад' )
            Endif
          Endif
        Elseif ( au_lu[ i, 2 ] < dBegin ) .and. ;
            ! ( ( mvozrast >= 2 ) .and. ( au_lu[ i, 2 ] >= AddMonth( dBegin, -3 ) ) ) .and. ;
            ! ( ( mvozrast < 2 ) .and. ( au_lu[ i, 2 ] >= AddMonth( dBegin, -1 ) ) ) .and. ;
            ! ( au_lu[ i, 5 ] == '7.2.702' )
          AAdd( ta, s + ' не попадает в диапазон лечения' )
        Endif
/*
        if dEnd < 0d20250901
          If eq_any( Left( au_lu[ i, 1 ], 5 ), '70.5.', '70.6.' )
            ++zs
            s := ret_shifr_zs_dds( tip_lu )
            If dEnd < 0d20250901 .and. !( AllTrim( au_lu[ i, 1 ] ) == s )
              AAdd( ta, 'в л/у услуга ' + AllTrim( au_lu[ i, 1 ] ) + ', а должна быть ' + s + ;
                ' для возраста ' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) )
            Endif
          Elseif is_osmotr_dds( au_lu[ i ], mvozrast, ta, metap, mpol, tip_lu, human->K_DATA, m1mobilbr )
            If eq_any( Left( au_lu[ i, 1 ], 5 ), '2.83.', '2.87.' )
              ++kvp
            Elseif Left( au_lu[ i, 1 ], 4 ) == '2.3.'
              ++kvp
            Endif
            If dBegin == au_lu[ i, 2 ]
              is_1_den := .t.
            Endif
            If dEnd == au_lu[ i, 2 ]
              is_last_den := .t.
            Endif
          Else
            oth_usl += AllTrim( au_lu[ i, 1 ] ) + ' '
          Endif
        else
          If dBegin == au_lu[ i, 2 ]
            is_1_den := .t.
          Endif
          If dEnd == au_lu[ i, 2 ]
            is_last_den := .t.
          Endif
        Endif
*/
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
      Endif
    Next
    If metap == 1 .and. zs > 1
      AAdd( ta, 'в листе учета более одной услуги "законченный случай"' )
    Elseif metap == 2 .and. zs > 0
      AAdd( ta, 'для I и II этапов ДДС не должно быть услуг "законченный случай"' )
    Endif
    If !Empty( oth_usl )
      AAdd( ta, 'в листе учета ДДС лишние услуги: ' + oth_usl )
    Endif
    If !is_1_den
      // aadd(ta, 'первый врачебный осмотр должен быть оказан в первый день лечения')
    Endif
    If !is_last_den
      AAdd( ta, 'последний врачебный осмотр должен быть оказан в последний день лечения' )
    Endif
    k := 0
    For counter := dBegin To dEnd
      If is_work_day( counter )
        ++k
      Endif
    Next
    If metap == 1 .and. k > 10
      AAdd( ta, 'срок ДДС I этапа должен составлять не более 10 рабочих дней (у Вас ' + lstr( k ) + ')' )
    Elseif metap == 2 .and. k > 45
      AAdd( ta, 'срок ДДС I и II этапа должен составлять не более 45 рабочих дней (у Вас ' + lstr( k ) + ')' )
    Endif
  Endif
  If is_prof_PN //
    human_->profil := 151  // медицинским осмотрам профилактическим
    metap := 1
    m1mobilbr := 0
    If yearBegin != yearEnd
      AAdd( ta, 'дата начала и окончания случая должны быть в одном году' )
    Endif
    If eq_any( human->ishod, 301, 302 )
      metap := human->ishod -300
      license_for_dispans( 2, dBegin, ta )
    Else
      AAdd( ta, 'профилактику несовершеннолетних надо вводить через специальный экран ввода' )
    Endif
    mperiod := ret_period_pn( mdate_r, dBegin, dEnd )
    If Between( mperiod, 1, 31 )
      np_oftal_2_85_21( mperiod, dEnd ) // добавить или удалить офтальмолога в массив для несовершеннолетних для 12 месяцев
      read_arr_pn( human->kod, .t., dEnd )
      arr_PN_osmotr := np_arr_osmotr( dEnd, m1mobilbr )
      kol_d_otkaz := 0
      arr_pn_issled := np_arr_issled( dEnd )
      If ValType( arr_usl_otkaz ) == 'A'
        For j := 1 To Len( arr_usl_otkaz )
          ar := arr_usl_otkaz[ j ]
          If ValType( ar ) == 'A' .and. Len( ar ) > 9 .and. ValType( ar[ 5 ] ) == 'C' .and. ;
              ValType( ar[ 10 ] ) == 'C' .and. ar[ 10 ] $ 'io'
            lshifr := AllTrim( ar[ 5 ] )
            If ar[ 10 ] == 'i' // исследования
              If ( i := AScan( arr_pn_issled, {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
                If is_issled_pn( { lshifr, ar[ 6 ], ar[ 4 ], ar[ 2 ] }, mperiod, ta, human->pol, dEnd )
                  ++kol_d_otkaz
                Endif
              Endif
            Elseif ( i := AScan( arr_PN_osmotr, {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0 // осмотры
              If is_osmotr_pn( { lshifr, ar[ 6 ], ar[ 4 ], ar[ 2 ] }, mperiod, ta, metap, human->pol, dEnd, m1mobilbr )
                ++kol_d_otkaz
              Endif
            Endif
          Endif
        Next j
      Endif
      is_1_den := is_last_den := .f.
      zs := kvp := 0
      oth_usl := kod_zs := ''
      is_neonat := .f.
      For i := 1 To Len( au_lu )
        If au_lu[ i, 3 ] == 0
          AAdd( ta, 'в услуге ' + AllTrim( au_lu[ i, 1 ] ) + ' не проставлен профиль' )
        Endif
        If au_lu[ i, 4 ] == 0
          AAdd( ta, 'в услуге ' + AllTrim( au_lu[ i, 1 ] ) + ' не проставлена спец-ть врача' )
        Endif
        If au_lu[ i, 2 ] > dEnd
          AAdd( ta, 'услуга ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ') не попадает в диапазон лечения' )
        Endif
        If is_issled_pn( au_lu[ i ], mperiod, ta, mpol, dEnd )
          s := 'услуга ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ')'
          If mvozrast < 2
            If Left( au_lu[ i, 5 ], 5 ) == '4.26.'
              is_neonat := .t.
            Endif
            If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
              AAdd( ta, s + ' оказана более 1 месяца назад' )
            Endif
          Else
            If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
              AAdd( ta, s + ' оказана более 3 месяцев назад' )
            Endif
          Endif
          If dBegin == au_lu[ i, 2 ]
            is_1_den := .t.
          Endif
        Else
          s := 'услуга ' + au_lu[ i, 5 ] + '-' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) + '(' + date_8( au_lu[ i, 2 ] ) + ')'
          If eq_any( au_lu[ i, 3 ], 68, 57 ) .and. !( au_lu[ i, 5 ] == '2.4.2' )// врачебный приём - педиатр (врач общей практики)
            If au_lu[ i, 2 ] < dBegin
              AAdd( ta, 'дата осмотра педиатра не попадает в диапазон лечения' )
            Endif
          Elseif is_1_etap_pn( au_lu[ i ], mperiod, metap, dEnd, m1mobilbr ) // если услуга из 1 этапа
            If mvozrast < 2
              If au_lu[ i, 2 ] < AddMonth( dBegin, -1 )
                AAdd( ta, s + ' оказана более 1 месяца назад' )
              Endif
            Else
              If au_lu[ i, 2 ] < AddMonth( dBegin, -3 )
                AAdd( ta, s + ' оказана более 3 месяцев назад' )
              Endif
            Endif
          Elseif au_lu[ i, 2 ] < dBegin
            AAdd( ta, s + ' не попадает в диапазон лечения' )
          Endif
          If Left( au_lu[ i, 1 ], 5 ) == '72.2.'
            ++zs
            kod_zs := AllTrim( au_lu[ i, 1 ] )
          Elseif eq_any( au_lu[ i, 3 ], 68, 57 ) // педиатр (врач общей практики)
            ++kvp
            If dBegin == au_lu[ i, 2 ]
              is_1_den := .t.
            Endif
            If dEnd == au_lu[ i, 2 ]
              is_last_den := .t.
            Endif
          Elseif is_osmotr_pn( au_lu[ i ], mperiod, ta, metap, mpol, dEnd, m1mobilbr )
            If eq_any( Left( au_lu[ i, 1 ], 4 ), '2.3.', '2.4.', '2.85', '2.91', '2.94' )
              ++kvp
            Endif
            If dBegin == au_lu[ i, 2 ]
              is_1_den := .t.
            Endif
            If dEnd == au_lu[ i, 2 ]
              is_last_den := .t.
            Endif
          Elseif !( metap == 2 .and. is_lab_usluga( au_lu[ i, 1 ] ) )
//            oth_usl += AllTrim( au_lu[ i, 1 ] ) + ' '
          Endif
        Endif
      Next
      If metap == 1 .and. zs == 1
        s := ret_shifr_zs_pn( mperiod, dEnd )
        If !( kod_zs == s )
          AAdd( ta, 'в л/у услуга ' + kod_zs + ', а должна быть ' + s + ' для возраста ' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) )
        Endif
      Elseif metap == 1 .and. zs > 1
        AAdd( ta, 'в листе учета более одной услуги "законченный случай"' )
      Elseif metap == 2 .and. zs > 0
        AAdd( ta, 'для двухэтапной профилактики несовершеннолетних не должно быть услуг "законченный случай"' )
      Endif
      If !Empty( oth_usl )
        AAdd( ta, 'в листе учета ПН лишние услуги: ' + oth_usl )
      Endif
      If !is_1_den
        // aadd(ta, 'первый врачебный осмотр должен быть оказан в первый день лечения')
      Endif
      If !is_last_den
        AAdd( ta, 'последний врачебный осмотр должен быть оказан в последний день лечения' )
      Endif
      k := 0
      For counter := dBegin To dEnd
        If is_work_day( counter )
          ++k
        Endif
      Next
      If metap == 1 .and. k > 20
        AAdd( ta, 'срок ПН I этапа должен составлять 20 рабочих дней (у Вас ' + lstr( k ) + ')' )
      Elseif metap == 2 .and. k > 45
        AAdd( ta, 'срок ПН I и II этапа должен составлять 45 рабочих дней (у Вас ' + lstr( k ) + ')' )
      Endif
      // проверим, выполнены обязательные услуги (и наоборот)
//      ar := AClone( np_arr_1_etap[ mperiod, 5 ] )
      ar := AClone( np_arr_1_etap( dEnd )[ mperiod, 5 ] )
      For i := 1 To Len( ar ) // исследования
        lshifr := AllTrim( ar[ i ] )
        If ( AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == lshifr } ) > 0 ) .or. ( lshifr == '4.29.2' ) // исследование уровня холестерина в крови
          // услуга оказана
        Elseif dEnd < 0d20250901 .and. AScan( arr_usl_otkaz, {| x| ValType( x ) == 'A' .and. ValType( x[ 5 ] ) == 'C' .and. AllTrim( x[ 5 ] ) == lshifr } ) > 0
          // услуга в отказах
        elseif dEnd >= 0d20250901 .and. proverka_otkaza_new( dEnd, arr_usl_otkaz, lshifr )
          // услуга в отказах
        Else
          s := ''
          arr_not_zs := np_arr_not_zs( dEnd )
          
//          If ( ( j := AScan( np_arr_issled( dEnd ), {| x| x[ 1 ] == lshifr } ) ) > 0 ) .and. ;
//              ( ( jk := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0 )
//            if np_arr_issled( dEnd )[ j, 1 ] != arr_not_zs[ jk, 1 ]
//              s := np_arr_issled( dEnd )[ j, 3 ]
          If ( ( j := AScan( arr_pn_issled, {| x| x[ 1 ] == lshifr } ) ) > 0 ) .and. ;
              ( ( jk := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0 )
            if arr_pn_issled[ j, 1 ] != arr_not_zs[ jk, 1 ]
              s := arr_pn_issled[ j, 3 ]
              AAdd( ta, 'некорректно записано исследование ' + lshifr + ' ' + s + ' (отредактируйте)' )
            endif
//            s := np_arr_issled( dEnd )[ j, 3 ]
          Endif
//          AAdd( ta, 'некорректно записано исследование ' + lshifr + ' ' + s + ' (отредактируйте)' )
        Endif
      Next
      ar := AClone( np_arr_1_etap( dEnd )[ mperiod, 4 ] )
      For i := 1 To Len( ar ) // осмотры 1 -го этапа
        lshifr := AllTrim( ar[ i ] )
        If ( j := AScan( arr_PN_osmotr, {| x| x[ 1 ] == lshifr } ) ) > 0
          fl := .f.
          If AScan( au_lu, {| x| AllTrim( x[ 1 ] ) == lshifr } ) > 0
            fl := .t. // услуга оказана
          Elseif  dEnd < 0d20250901 .and. AScan( arr_usl_otkaz, {| x| ValType( x ) == 'A' .and. ValType( x[ 5 ] ) == 'C' .and. AllTrim( x[ 5 ] ) == lshifr } ) > 0
            fl := .t. // услуга в отказах
          elseif dEnd >= 0d20250901 .and. proverka_otkaza_new( dEnd, arr_usl_otkaz, lshifr )
            fl := .t. // услуга в отказах
          Elseif !Empty( arr_PN_osmotr[ j, 2 ] ) .and. !( arr_PN_osmotr[ j, 2 ] == human->pol )
            Loop
          Else
            For k := 1 To Len( au_lu )
              // проверяем только нулевые услуги
              If eq_any( Left( au_lu[ k, 1 ], 4 ), '2.3.', '2.4.' )
                If ValType( arr_PN_osmotr[ j, 4 ] ) == 'N'
                  If au_lu[ k, 3 ] == arr_PN_osmotr[ j, 4 ]
                    fl := .t. // услуга оказана (нашли по профилю)
                    Exit
                  Endif
                Elseif AScan( arr_PN_osmotr[ j, 4 ], au_lu[ k, 3 ] ) > 0
                  fl := .t. // услуга оказана (нашли по профилю)
                  Exit
                Endif
              Endif
            Next k
          Endif
          If !fl .and. dEnd < 0d20191101
            If mperiod == 16 .and. arr_PN_osmotr[ j, 1 ] == '2.4.2' // 2 года
              fl := .t. // услуга не должна быть оказана
            Elseif mperiod == 20 .and. arr_PN_osmotr[ j, 1 ] == '2.85.24' // 6 лет
              fl := .t. // услуга не должна быть оказана
            Endif
          Endif
          If !fl
            AAdd( ta, 'некорректно записан врачебный осмотр 1-го этапа "' + arr_PN_osmotr[ j, 3 ] + ' (отредактируйте)' )
          Endif
        Endif
      Next i
      If Empty( ta ) // если пока нет ошибок
        fl := .f.
        For i := 1 To Len( au_lu )
          If eq_any( au_lu[ i, 3 ], 68, 57 ) ; // педиатр (врач общей практики)
              .and. ( ( Left( au_lu[ i, 1 ], 4 ) == '2.85' ) .or. ;
              ( Left( au_lu[ i, 1 ], 4 ) == '2.3.' .or. Left( au_lu[ i, 1 ], 4 ) == '2.94' ) ) // на 1-ом этапе
            fl := .t.
            Exit
          Endif
        Next i
        If !fl
          AAdd( ta, 'некорректно записан врачебный осмотр педиатра на 1-ом этапе (отредактируйте)' )
        Endif
      Endif
    Else
      AAdd( ta, 'не удалось определить возрастной период для профилактики несовершеннолетнего' )
    Endif
  Endif
  If is_disp_DVN //
    m1mobilbr := 0
    human_->profil := 151  // медицинским осмотрам профилактическим
    ret_arr_vozrast_dvn( dEnd )
    ret_arrays_disp( dEnd )
    m1g_cit := m1veteran := m1dispans := 0 ; is_prazdnik := f_is_prazdnik_dvn( dBegin )

    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1pervich := 'm1pervich' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      Private &pole_diag := Space( 6 )
      Private &pole_1pervich := 0
      Private &pole_1dispans := 0
      Private &pole_dn_dispans := CToD( '' )
    Next
    m1dopo_na := 0
    m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_dvn( human->kod )
    If m1dopo_na > 0
      AAdd( arr_nazn, { 3, {} } ) ; j := Len( arr_nazn )
      For i := 1 To 4
        If IsBit( m1dopo_na, i )
          AAdd( arr_nazn[ j, 2 ], i )
        Endif
      Next
    Endif
    If Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
      AAdd( arr_nazn, { m1napr_v_mo, {} } ) ; j := Len( arr_nazn )
      For i := 1 To Min( 3, Len( arr_mo_spec ) )
        AAdd( arr_nazn[ j, 2 ], arr_mo_spec[ i ] )
      Next
    Endif
    If Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
      AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac } )
    Endif
    If m1napr_reab == 1 .and. m1profil_kojki > 0
      AAdd( arr_nazn, { 6, m1profil_kojki } )
    Endif
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1pervich := 'm1pervich' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      arr_diag := { AllTrim( &pole_diag ), &pole_1pervich, &pole_1dispans, &pole_dn_dispans }
      // действия при записи в лист учёта
      If arr_diag[ 2 ] == 0 // 'ранее выявлено'
        arr_diag[ 2 ] := 2  // заменяем, как в листе учёта ОМС
      Endif
      If arr_diag[ 3 ] > 0 // 'дисп.наблюдение установлено' и 'ранее выявлено'
        If arr_diag[ 2 ] == 2 // 'ранее выявлено'
          arr_diag[ 3 ] := 1 // то 'Состоит'
        Else
          arr_diag[ 3 ] := 2 // то 'Взят'
        Endif
      Endif
      // действия при записи в реестр
      s := 3 // не подлежит диспансерному наблюдению
      If arr_diag[ 2 ] == 1 // впервые
        If arr_diag[ 3 ] == 2
          s := 2 // взят на диспансерное наблюдение
        Endif
      Elseif arr_diag[ 2 ] == 2 // ранее
        If arr_diag[ 3 ] == 1
          s := 1 // состоит на диспансерном наблюдении
        Elseif arr_diag[ 3 ] == 2
          s := 2 // взят на диспансерное наблюдение
        Endif
      Endif
      If !Empty( arr_diag[ 1 ] ) .and. diag_in_list_dn( arr_diag[ 1 ] )
        If Empty( arr_diag[ 4 ] )
          If s == 2
            AAdd( ta, 'не введена дата следующего визита для ' + arr_diag[ 1 ] )
          Endif
        Elseif arr_diag[ 4 ] > dEnd
          If s == 1
            is_disp_nabl := .t.
          Endif
        Else
          AAdd( ta, 'некорректная дата следующего визита для ' + arr_diag[ 1 ] )
        Endif
      Endif
    Next
    If yearBegin != yearEnd
      AAdd( ta, 'Дата начала и окончания случая должны быть в одном году' )
    Endif
    For i := 1 To Len( au_lu_ne )
      s := AllTrim( au_lu_ne[ i, 1 ] )
      If !Empty( au_lu_ne[ i, 2 ] )
        s += '(' + AllTrim( au_lu_ne[ i, 2 ] ) + ')'
      Endif
      s += ' ' + AllTrim( au_lu_ne[ i, 3 ] )
      AAdd( ta, 'неверная услуга "' + s + '" от ' + date_8( au_lu_ne[ i, 4 ] ) + 'г.' )
    Next
    metap := 3
    If Between( human->ishod, 201, 205 )
      metap := human->ishod -200
      license_for_dispans( 1, dBegin, ta )
    Else
      AAdd( ta, 'диспансеризацию/профилактику взрослых надо вводить через специальный экран ввода' )
    Endif
    If m1veteran == 1
      If metap == 3
        AAdd( ta, 'профилактику взрослых не проводят ветеранам ВОВ (блокадникам)' )
      Else
        mdvozrast := ret_vozr_dvn_veteran( mdvozrast, dEnd )
      Endif
    Endif
    is_prof_disp := .f.
    // если это профосмотр
    If metap == 3 .and. AScan( ret_arr_vozrast_dvn( dEnd ), mdvozrast ) > 0 // а возраст диспансеризации
      metap := 1 // превращаем в диспансеризацию
      is_prof_disp := .t.
    Endif
    For i := 1 To Len( a_disp )
      // {human->ishod-200, human->n_data, human->k_data, human_->RSLT_NEW}
      If overlap_diapazon( a_disp[ i, 2 ], a_disp[ i, 3 ], dBegin, dEnd )
        AAdd( ta, 'пересечение с ' + iif( a_disp[ i, 1 ] == 3, 'профилактикой ', 'диспансеризацией ' ) + ;
          date_8( a_disp[ i, 2 ] ) + '-' + date_8( a_disp[ i, 3 ] ) )
      Endif
    Next
    If metap == 2 .and. AScan( a_disp, {| x| x[ 1 ] == 1 } ) == 0
      AAdd( ta, 'это II этап диспансеризации, но отсутствует случай I этапа диспансеризации' )
    Elseif metap == 5 .and. AScan( a_disp, {| x| x[ 1 ] == 4 } ) == 0
      AAdd( ta, 'это II этап диспансеризации, но отсутствует случай I этапа диспансеризации раз в 2 года' )
    Endif
    // отметим обязательные услуги
    arr1 := Array( count_dvn_arr_usl, 5 )
    afillall( arr1, 0 )
    arr2 := Array( count_dvn_arr_umolch, 5 )
    afillall( arr2, 0 )
    For i := 1 To count_dvn_arr_usl
      fl_ekg := .f.
      i_otkaz := 0
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, , @i_otkaz, @fl_ekg )
        arr1[ i, 2 ] := 1
        arr1[ i, 3 ] := i_otkaz
        arr1[ i, 5 ] := iif( fl_ekg, 1, 0 ) // 1 - необязательный возраст
      Endif
    Next
    For i := 1 To count_dvn_arr_umolch
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol )
        arr2[ i, 2 ] := 1
      Endif
    Next
    // отметим выполненные услуги
    For j := 1 To Len( au_lu )
      lshifr := AllTrim( au_lu[ j, 1 ] )
      fl := .t.
      If !is_disp_19 .and. ( ( lshifr == '2.3.3' .and. au_lu[ j, 3 ] == 3 ) .or.  ; // акушерскому делу
        ( lshifr == '2.3.1' .and. au_lu[ j, 3 ] == 136 ) )  ; // акушерству и гинекологии
        .and. ( i := AScan( dvn_arr_usl, {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.1.12' } ) ) > 0
        arr1[ i, 1 ] ++
        fl := .f.
      Endif
      If fl
        For i := 1 To count_dvn_arr_umolch
          If arr2[ i, 1 ] == 0 .and. dvn_arr_umolch[ i, 2 ] == lshifr
            arr2[ i, 1 ] ++
            fl := .f.
            Exit
          Endif
        Next
      Endif
      If fl
        For i := 1 To count_dvn_arr_usl
          If metap == 2 .and. ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. dvn_arr_usl[ i, 2 ] == lshifr
            s := '"' + dvn_arr_usl[ i, 2 ] + ' ' + dvn_arr_usl[ i, 1 ] + '"'
            If ValType( dvn_arr_usl[ i, 3 ] ) == 'N'
              If dvn_arr_usl[ i, 3 ] != 2
                AAdd( ta, 'не надо выполнять, а выполнили ' + s )
              Endif
            Else
              If AScan( dvn_arr_usl[ i, 3 ], 2 ) == 0
                AAdd( ta, 'не надо выполнять, а выполнили ' + s )
              Endif
            Endif
          Endif
          If arr1[ i, 1 ] == 0
            If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
              If dvn_arr_usl[ i, 2 ] == '4.20.1'
                If lshifr == '4.20.1'
                  m1g_cit := 1
                Elseif lshifr == '4.20.2'
                  m1g_cit := 2 ; fl := .f.
                Endif
              Endif
              If dvn_arr_usl[ i, 2 ] == lshifr
                fl := .f.
              Endif
            Endif
            If fl .and. Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A'
              If AScan( dvn_arr_usl[ i, 12 ], {| x| x[ 1 ] == lshifr .and. x[ 2 ] == au_lu[ j, 3 ] } ) > 0
                fl := .f.
              Endif
            Endif
            If !fl
              arr1[ i, 1 ] ++
              Exit
            Endif
          Endif
        Next
      Endif
      If fl .and. !is_disp_19 .and. AScan( dvn_700(), {| x| x[ 2 ] == lshifr } ) > 0
        fl := .f. // к нулевой услуге добавлена услуга с ценой на '700'
      Endif
      If fl .and. !eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        AAdd( ta, lshifr + ' - некорректная настройка в справочнике услуг шифра ТФОМС' )
      Endif
    Next j
    is_1_den := is_last_den := .f.
    zs := kvp := 0
    oth_usl := ''
    mv := iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast )
    kod_spec_ter := 0
    If eq_any( metap, 1, 4 )
      For i := 1 To Len( au_lu )
        If eq_any( au_lu[ i, 3 ], 97, 57, 42 ) // профиль терапевт (врач общей практики)
          kod_spec_ter := au_lu[ i, 4 ]  // специальность терапевта (врача общей практики)
          Exit
        Endif
      Next
    Elseif eq_any( metap, 2, 5 ) // поверка на обязательное сочетание услуг второго этапа
      ar := Array( Len( dvn_2_etap ), 2 )
      afillall( ar, 0 )
      For i := 1 To Len( au_lu )
        lshifr := AllTrim( au_lu[ i, 1 ] )
        For j := 1 To Len( dvn_2_etap )
          If AScan( dvn_2_etap[ j, 1 ], lshifr ) > 0 .and. Between( mdvozrast, dvn_2_etap[ j, 3 ], dvn_2_etap[ j, 4 ] )
            ar[ j, 1 ] := 1
          Elseif AScan( dvn_2_etap[ j, 2 ], lshifr ) > 0 .and. Between( mdvozrast, dvn_2_etap[ j, 3 ], dvn_2_etap[ j, 4 ] )
            ar[ j, 2 ] := 1
          Endif
        Next
      Next
      For j := 1 To Len( dvn_2_etap )
        If Empty( ar[ j, 1 ] ) .and. !Empty( ar[ j, 2 ] )
          If Len( dvn_2_etap[ j, 2 ] ) == 1
            s := 'для услуги ' + dvn_2_etap[ j, 2, 1 ]
          Else
            s := 'для услуг ' + print_array( dvn_2_etap[ j, 2 ] )
          Endif
          s += ' обязательно наличие услуги '
          If Len( dvn_2_etap[ j, 1 ] ) == 1
            s += dvn_2_etap[ j, 1, 1 ]
          Else
            s += print_array( dvn_2_etap[ j, 1 ] )
          Endif
          s += ' (в возрасте от ' + lstr( dvn_2_etap[ j, 3 ] ) + ' до ' + lstr( dvn_2_etap[ j, 4 ] ) + ' лет)'
          AAdd( ta, s )
          // elseif !empty(ar[j, 1]) .and. empty(ar[j, 2])
          // aadd(ta, 'для услуги ' + print_array(dvn_2_etap[j, 1]) + ' обязательно наличие  услуг ' + print_array(dvn_2_etap[j, 2]))
        Endif
      Next
    Endif
    a_4_20_1 := { 0, 0 }
    For i := 1 To Len( au_lu )
      lshifr := AllTrim( au_lu[ i, 1 ] )
      Do Case
      Case lshifr == '4.1.12' // Осмотр акушеркой, взятие мазка (соскоба)
        a_4_20_1[ 1 ] := 3
      Case eq_any( lshifr, '4.20.1', '4.20.2' ) // Иссл-е взятого цитологического материала
        a_4_20_1[ 2 ] := 3
        If lshifr == '4.20.2' .and. au_lu[ i, 7 ] < dBegin
          m1g_cit := 1
        Endif
      Endcase
    Next
    // учёт и проверка отказов
    kol_d_usl := kol_d_otkaz := kol_n_date := kol_ob_otkaz := 0
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          For i := 1 To count_dvn_arr_usl
            If ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. ;
                ( dvn_arr_usl[ i, 2 ] == lshifr .or. ( Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A' ;
                .and. AScan( dvn_arr_usl[ i, 12 ], {| x| x[ 1 ] == lshifr } ) > 0 ) )
              If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
                ++kol_d_usl
                arr1[ i, 4 ] := ar[ 10 ] // 1-отказ, 2-невозможность
                If lshifr == '4.1.12' // Осмотр акушеркой, взятие мазка (соскоба)
                  a_4_20_1[ 1 ] := ar[ 10 ]
                Endif
                If ar[ 10 ] == 1
                  ++kol_d_otkaz
                  If is_disp_19 .and. eq_any( lshifr, '4.8.4', '4.14.66', '7.57.3', '2.3.1', '2.3.3', '4.1.12', '4.20.1', '4.20.2' )
                    ++kol_ob_otkaz // кол-во отказов от обязательных услуг
                  Endif
                  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
                  is_usluga_dvn( { lshifr, ar[ 9 ], ar[ 4 ], ar[ 2 ] }, mv, ta, metap, mpol, kod_spec_ter )
                  // проверяем на специальность
                  uslugaaccordanceprvs( lshifr, human->vzros_reb, ar[ 2 ], ta, lshifr, iif( ValType( ar[ 1 ] ) == 'N', ar[ 1 ], 0 ) )
                Endif
              Endif
            Endif
          Next i
        Endif
      Next j
    Endif
    If kol_ob_otkaz > 0 .and. metap == 1 .and. !is_prof_disp
      AAdd( ta, 'некорректно записан случай профоосмотра в год диспансеризации - отредактируйте' )
    Endif
    If !eq_any( metap, 2, 5 ) // проверим, выполнены обязательные услуги (и наоборот)
      For i := 1 To count_dvn_arr_usl
        s := '"' + iif( ValType( dvn_arr_usl[ i, 2 ] ) == 'C', dvn_arr_usl[ i, 2 ] + ' ', '' )
        s += dvn_arr_usl[ i, 1 ] + '"'
        If arr1[ i, 2 ] == 0 // не надо выполнять
          If arr1[ i, 1 ] > 1
            AAdd( ta, 'не надо выполнять, а выполнили ' + s )
          Endif
        Elseif arr1[ i, 2 ] == 1 // надо выполнять
          If eq_any( arr1[ i, 4 ], 1, 2 ) ;// отказ, невозможно
            .and. ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. dvn_arr_usl[ i, 2 ] == '4.1.12'
            If a_4_20_1[ 2 ] == 3
              AAdd( ta, 'не должно быть услуги "4.20.1 Исследование взятого цитологического материала", т.к. в услуге ' + s + ' стоит ' + { 'ОТКАЗ', 'НЕВОЗМОЖНОСТЬ' }[ arr1[ i, 4 ] ] + ' - отредактируйте' )
            Endif
          Endif
          If arr1[ i, 1 ] == 0 .and. arr1[ i, 5 ] == 0 // ЭКГ + обязательный возраст
            If arr1[ i, 4 ] == 2 .and. arr1[ i, 3 ] < 2 // 'невозможно', разрешён 'отказ'
              AAdd( ta, 'НЕВЕРНО установлена "невозможность" оказания услуги ' + s )
            Elseif arr1[ i, 4 ] == 0 // не отказ
              fl := .t.
              If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
                If dvn_arr_usl[ i, 2 ] == '4.20.1' .and. a_4_20_1[ 1 ] < 3
                  fl := .f.
                Endif
              Endif
              If fl
                AAdd( ta, 'не оказана услуга ' + s )
              Endif
            Endif
          Elseif arr1[ i, 1 ] > 1
            AAdd( ta, 'выполнили более одной услуги ' + s )
          Endif
        Endif
      Next
      For i := 1 To count_dvn_arr_umolch
        s := '"' + dvn_arr_umolch[ i, 2 ] + ' ' + dvn_arr_umolch[ i, 1 ] + '"'
        If arr2[ i, 2 ] == 0 // не надо выполнять
          If arr2[ i, 1 ] > 1
            AAdd( ta, 'не надо выполнять, а выполнили ' + s )
          Endif
        Elseif arr2[ i, 2 ] == 1 // надо выполнять
          If Empty( arr2[ i, 1 ] )
            AAdd( ta, 'нет услуги ' + s )
          Elseif arr2[ i, 1 ] > 1
            AAdd( ta, 'более одной услуги ' + s )
          Endif
        Endif
      Next
    Endif
    k700 := kkt := kzad := 0
    For i := 1 To Len( au_lu )
      hu->( dbGoto( au_lu[ i, 9 ] ) )       // 9 - номер записи
      lshifr := AllTrim( au_lu[ i, 1 ] )
      If Left( lshifr, 4 ) == '2.3.' .and. !Empty( au_lu[ i, 3 ] )
        s := 'услуга ' + au_lu[ i, 5 ] + '-' + inieditspr( A__MENUVERT, getv002(), au_lu[ i, 3 ] ) + '(' + date_8( au_lu[ i, 2 ] ) + ')'
      Else
        s := 'услуга ' + au_lu[ i, 5 ] + '(' + date_8( au_lu[ i, 2 ] ) + ')'
      Endif
      If au_lu[ i, 3 ] == 0
        AAdd( ta, s + ' - не проставлен профиль' )
      Endif
      If au_lu[ i, 4 ] == 0
        AAdd( ta, s + ' - не проставлена спец-ть врача' )
      Endif
      If au_lu[ i, 2 ] > dEnd
        AAdd( ta, s + ' не попадает в диапазон лечения' )
      Endif
      If is_usluga_dvn( au_lu[ i ], mv, ta, metap, mpol, kod_spec_ter )
        If metap == 1 .and. Empty( hu->u_cena ) .and. !eq_any( Left( lshifr, 5 ), '4.20.', '2.90.' )
          ++kol_d_usl
        Elseif metap == 3 .and. !( lshifr == '56.1.14' )
          ++kol_d_usl
        Endif
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If metap == 2
          If eq_any( lshifr, '7.2.701', '7.2.702', '7.2.703', '7.2.704', '7.2.705' )
            ++kkt
          Endif
          If eq_any( lshifr, '10.6.710', '10.4.701' )
            ++kzad
          Endif
        Endif
        If !eq_any( metap, 2, 5 ) .and. au_lu[ i, 2 ] < dBegin .and. !eq_any( lshifr, '4.20.1', '4.20.2' )
          If is_disp_19
            If Year( au_lu[ i, 2 ] ) < Year( dBegin ) // кол-во услуг без отказа выполнены ранее
              ++kol_n_date                 // начала проведения диспансеризации и не принадлежат текущему календарному году
            Endif
          Else
            ++kol_n_date // учтена ранее оказанная услуга
          Endif
        Endif
        If eq_any( metap, 2, 5 ) .and. au_lu[ i, 2 ] < dBegin
          AAdd( ta, s + ' не попадает в диапазон лечения' )
        Elseif Left( lshifr, 2 ) == '2.' .and. eq_any( au_lu[ i, 3 ], 97, 57, 42 )
          If au_lu[ i, 2 ] != dEnd
            AAdd( ta, s + ' - терапевт должен проводить осмотр последним' )
          Endif
        Elseif AllTrim( au_lu[ i, 1 ] ) == '7.61.3' .and. !is_disp_19
          If eq_any( Year( au_lu[ i, 2 ] ), yearBegin, yearBegin - 1 )
            // в течение предшествующего календарного года либо года проведения диспансеризации проводилась флюорография
          Else
            AAdd( ta, 'флюорография оказана в позапрошлом календарном году' )
          Endif
        Else
          If au_lu[ i, 2 ] < AddMonth( dBegin, -12 )
            AAdd( ta, s + ' оказана более 1 года назад' )
          Endif
        Endif
        If Left( lshifr, 5 ) == '2.84.'
          ++kvp
        Elseif eq_any( Left( lshifr, 4 ), '2.3.', '2.90' )
          ++kvp
        Endif
        If dBegin == au_lu[ i, 2 ]
          is_1_den := .t.
        Endif
        If dEnd == au_lu[ i, 2 ]
          is_last_den := .t.
        Endif
      Elseif AScan( dvn_700(), {| x| x[ 2 ] == lshifr } ) > 0
        ++k700 // к нулевой услуге добавлена услуга с ценой на '700'
      Elseif eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        ++zs
        If is_prof_disp
          s := ret_shifr_zs_dvn( 3, mv, mpol, dEnd )
        Else
          s := ret_shifr_zs_dvn( metap, mv, mpol, dEnd )
        Endif
        If !( lshifr == s )
          AAdd( ta, 'в л/у услуга ' + lshifr + ', а должна быть ' + s + ' для возраста ' + lstr( mv ) + ' ' + s_let( mv ) + '. Отредактируйте!' )
        Endif
      Else
        oth_usl += lshifr + ' '
      Endif
    Next
    If kkt > 1
      AAdd( ta, 'разрешается выполнить только одну процедуру рентгенографиии или КТ органов грудной клетки' )
    Endif
    If kzad > 1
      AAdd( ta, 'не разрешается совместно применять ректосигмоколоноскопию и ректороманоскопию' )
    Endif
    If AScan( ret_arr_vozrast_dvn( dEnd ), mdvozrast ) > 0
      If metap > 2
        AAdd( ta, 'в ' + lstr( mdvozrast ) + s_let( mdvozrast ) + ' проводится диспансеризация, а проведена профилактика' )
      Endif
    Else
      If eq_any( metap, 1, 2 )
        AAdd( ta, 'в ' + lstr( mvozrast ) + s_let( mvozrast ) + ' проводится профилактика, а проведена диспансеризация' )
      Endif
    Endif
    Do Case
    Case metap == 1 .or. ( metap == 3 .and. is_disp_19 )
      If zs > 1
        AAdd( ta, 'в листе учета более одной услуги "законченный случай"' )
      Elseif emptyall( zs, k700 ) .and. !is_disp_19
        AAdd( ta, 'в листе нет услуг с ценой' )
      Endif
      If ( i := AScan( dvn_85(), {| x| x[ 1 ] == kol_d_usl } ) ) > 0
        If is_disp_19
          k := dvn_85()[ i, 1 ] - dvn_85()[ i, 2 ]
          If kol_n_date + kol_d_otkaz <= k // отказы + ранее оказано менее 15%
            If zs == 0
              AAdd( ta, 'в листе учета должна быть услуга "законченный случай" - отредактируйте' )
            Endif
          Else
            AAdd( ta, 'данный случай не может быть отправлен в ТФОМС, т.к. оказано менее 85% услуг (оказано в прошлом календарном году-' + lstr( kol_n_date ) + ', отказов-' + lstr( kol_d_otkaz ) + ', всего учитываемых услуг-' + lstr( kol_d_usl ) + ')' )
          Endif
        Else
          If ( k := dvn_85()[ i, 1 ] - dvn_85()[ i, 2 ] ) < kol_d_otkaz
            AAdd( ta, 'отказы пациента составляют ' + lstr( kol_d_otkaz / kol_d_usl * 100, 5, 0 ) + '% (должно быть не более 15%)' )
            AAdd( ta, 'отказов-' + lstr( kol_d_otkaz ) + ', всего учитываемых услуг-' + lstr( kol_d_usl ) )
          Elseif kol_n_date + kol_d_otkaz <= k // отказы + ранее оказано менее 15%
            If zs == 0 .or. k700 > 0
              AAdd( ta, 'в листе учета должна быть услуга "законченный случай" - отредактируйте' )
            Endif
          Else
            If zs > 0 .or. Empty( k700 )
              AAdd( ta, 'в листе учета не должно быть услуги "законченный случай" - отредактируйте' )
            Endif
          Endif
        Endif
      Else
        AAdd( ta, 'слишком много отказов-' + lstr( kol_d_otkaz ) + ' услуг-' + lstr( kol_d_usl ) )
      Endif
    Case metap == 4
      If zs > 1
        AAdd( ta, 'в листе учета более одной услуги "законченный случай"' )
      Elseif emptyall( zs, k700 )
        AAdd( ta, 'в листе учета нет услуг с ценой' )
      Endif
    Case eq_any( metap, 2, 5 )
      If zs > 0
        AAdd( ta, 'для II этапа ДВН не должно быть услуг "законченный случай"' )
      Endif
    Case metap == 3 .and.  !is_disp_19
      If zs > 1
        AAdd( ta, 'в листе учета более одной услуги "законченный случай"' )
      Endif
      If ( i := AScan( prof_vn_85(), {| x| x[ 1 ] == kol_d_usl } ) ) > 0
        If prof_vn_85()[ i, 1 ] - prof_vn_85()[ i, 2 ] < kol_d_otkaz
          AAdd( ta, 'отказы пациента составляют ' + lstr( kol_d_otkaz / kol_d_usl * 100, 5, 0 ) + '% (должно быть не более 15%)' )
          AAdd( ta, 'отказов-' + lstr( kol_d_otkaz ) + ', всего учитываемых услуг-' + lstr( kol_d_usl ) )
        Endif
      Else
        AAdd( ta, 'слишком много отказов-' + lstr( kol_d_otkaz ) )
      Endif
    Endcase
    If !Empty( oth_usl )
      AAdd( ta, 'в листе учета ДВН лишние услуги: ' + oth_usl )
    Endif
    If !is_1_den
      // aadd(ta, 'первый врачебный осмотр должен быть оказан в первый день лечения')
    Endif
    If !is_last_den
      AAdd( ta, 'последний врачебный осмотр должен быть оказан в последний день лечения' )
    Endif
    If metap != 3 .and. eq_any( human_->RSLT_NEW, 317, 318, 355, 356 )
      adiag_talon := Array( 16 )
      For i := 1 To 16
        adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
      Next
      am := {}
      For i := 1 To Len( mdiagnoz )
        If !Empty( mdiagnoz[ i ] ) .and. eq_any( adiag_talon[ i * 2 ], 1, 2 )
          AAdd( am, mdiagnoz[ i ] ) // массив диагнозов с диспансеризацией
        Endif
      Next
      Do Case
      Case human_->RSLT_NEW == 317 // {'Проведена диспансеризация - присвоена I группа здоровья'   , 1, 317}
        If !Empty( am )
          AAdd( ta, 'для I группы здоровья не должно быть установления диспансерного учёта ' + print_array( am ) )
        Endif
      Case human_->RSLT_NEW == 318 // {'Проведена диспансеризация - присвоена II группа здоровья'  , 2, 318}
        fl := .f.
        For i := 1 To Len( am )
          If Left( am[ i ], 3 ) == 'E78'
            fl := .t.
          Else
            AAdd( ta, 'для II группы здоровья диспансерный учёт может быть установлен только для гиперхолестеринемии, а не для ' + am[ i ] )
          Endif
        Next
        If fl .and. m1dispans != 3 // {'участковым терапевтом', 3}
          AAdd( ta, 'для II группы здоровья "Диспансерное наблюдение установлено" может быть только "участковым терапевтом"' )
        Endif
      Case human_->RSLT_NEW == 355 // {'Проведена диспансеризация - присвоена IIIа группа здоровья', 3, 355}
        If Empty( am )
          AAdd( ta, 'для IIIа группы здоровья обязательно должен быть установлен диспансерный учёт' )
        Endif
      Case human_->RSLT_NEW == 356 // {'Проведена диспансеризация - присвоена IIIб группа здоровья', 4, 356}
        If Empty( am )
          AAdd( ta, 'для IIIб группы здоровья обязательно должен быть установлен диспансерный учёт' )
        Endif
      Endcase
    Endif
  Endif

  If is_disp_DVN_COVID
    If ( human->k_data < 0d20210701 )
      AAdd( ta, 'углубленная диспансеризация после COVID началась с 01 июля 2021 года' )
    Endif
    m1dopo_na := 0
    m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_dvn_covid( human->kod )
  Endif

  If is_disp_DRZ
    If ( human->k_data < 0d20240301 )
      AAdd( ta, 'диспансеризация репродуктивного здоровья началась с 01 марта 2024 года' )
    Endif
    m1dopo_na := 0
    m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_drz( human->kod )
    If eq_any( human_->RSLT_NEW, 376, 377 ) .and. ;
        ( m1dopo_na == 0 ) .and. ( m1napr_v_mo == 0 ) .and. ( m1napr_stac == 0 ) .and. ( m1napr_reab == 0 )
      AAdd( ta, 'для выбранной ГРУППЫ ЗДОРОВЬЯ не выбраны назначения (направления) для пациента' )
    endif
    If ( ( human->ishod - BASE_ISHOD_RZD ) == 1 ) .and. ;
        eq_any( human_->RSLT_NEW, 378, 379 ) .and. ;
        ( ( m1dopo_na != 0 ) .or. ( m1napr_v_mo != 0 ) .or. ( m1napr_stac != 0 ) .or. ( m1napr_reab != 0 ) )
      AAdd( ta, 'при направлении на II этап не допускаются назначения (направления) для пациента' )
    Endif

  Endif

  //
  // ПРОВЕРКА УСЛУГ С ИСКУСТВЕННЫМ ИНТЕЛЕКТОМ
  //
  fl := .f.
  iFind := 0
  iCount := 0
  cUsluga := ''
  aCheck := { { '7.2.706', 'A06.09.007.002' }, { '7.57.704', 'A06.20.004' }, { '7.61.704', 'A06.09.006.001' }, { '60.4.583', 'A06.09.005' }, { '60.4.584', 'A06.23.004' } }
  for counter := 1 to len( arrUslugi )
    if ( iFind := AScan( aCheck, {| x | x[ 1 ] == arrUslugi[ counter ] } ) ) > 0
      iCount := counter
      cUsluga := aCheck[ iFind, 2 ]
      fl := .t.
      exit
    endif
  next
  if fl
    if Empty( human_2->NPR_DATE )
      AAdd( ta, 'для услуги ' + arrUslugi[ iCount ] + ' обязательно направление (дата и направившее МО)' )
    endif
    if ( human_->USL_OK != USL_OK_POLYCLINIC )
      AAdd( ta, 'услуга ' + arrUslugi[ iCount ] + ' оказывается только в амбулаторных условиях' )
    endif
    if ( AllTrim( mdiagnoz[ 1 ] ) != 'Z01.8' ) .and. SubStr( arrUslugi[ iCount ], 1, 5 ) != '60.4.'
      AAdd( ta, 'для услуги ' + arrUslugi[ iCount ] + ' необходимо выбрать основной диагноз Z01.8, ' ;
        + 'у вас выбран ' + AllTrim( mdiagnoz[ 1 ] ) + '!' )
    endif
    if AScan( arrUslugi, cUsluga ) > 0
      AAdd( ta, 'в случае необходимо удалить услугу ' + cUsluga )
    endif
  endif

  //
  // ПРОВЕРКА ЛЕКАРСТВЕННЫХ ПРЕПАРАТОВ
  //
  If ( eq_any( AllTrim( mdiagnoz[ 1 ] ), 'U07.1', 'U07.2' ) .and. ( count_years( human->DATE_R, human->k_data ) >= 18 ) ;
      .and. !check_diag_pregant() .and. Empty( human_->DATE_R2 ) ) ;
      .or. ( is_oncology == 2 .and. iif( substr( lower( ONKSL->crit ), 1, 2 ) == 'sh', .t., .f. ) )
    If ( human_->USL_OK == USL_OK_HOSPITAL ) .and. ( human->k_data >= 0d20220101 )
      flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
        .and. ( Lower( AllTrim( human_2->PC3 ) ) != 'stt5' )
    Elseif ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. ( human->k_data >= 0d20220401 )
      flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
        .and. ( get_idpc_from_v025_by_number( human_->povod ) == '3.0' )
    elseIf ( human_->USL_OK == USL_OK_HOSPITAL .or. human_->USL_OK == USL_OK_DAY_HOSPITAL ) ;
        .and. ( human->k_data >= 0d20250101 ) .and. is_oncology == 2
      flLekPreparat := .t.
    Endif
  Endif

  If flLekPreparat
    arrLekPreparat := collect_lek_pr( rec_human ) // выберем лекарственные препараты
    If Len( arrLekPreparat ) == 0  // пустой список лекарственных препаратов
      if is_oncology == 2
        AAdd( ta, 'для выбранного вида химиотерапии ' + alltrim( lower( ONKSL->crit ) ) + ' необходим ввод лекараственных препаратов' )
      else
        AAdd( ta, 'для диагнозов U07.1 и U07.2 необходим ввод лекараственных препаратов' )
      endif
    Else  // не пустой проверим его
      For Each row in arrLekPreparat
        If Empty( row[ 1 ] )
          AAdd( ta, 'не указана дата инъекции' )
        Endif
        If ! between_date( human->n_data, human->k_data, row[ 1 ] )
          AAdd( ta, 'дата инъекции не входит в период случая' )
        Endif
        if is_oncology == 2
          s_lek_pr := AllTrim( get_lek_pr_by_id( row[ 3 ] ) )
          If Empty( row[ 5 ] )
            AAdd( ta, 'Дата: ' + dtoc( row[ 1 ] ) + ' для "' + s_lek_pr + '" не введено количество лекарственного препарата (действующего вещества)' )
          Endif
          If Empty( row[ 9 ] )
            AAdd( ta, 'Дата: ' + dtoc( row[ 1 ] ) + ' для "' + s_lek_pr + '" не введено количество израсходованного (введеного + утилизированного) лекарственного препарата' )
          Endif
          If Empty( row[ 10 ] )
            AAdd( ta, 'Дата: ' + dtoc( row[ 1 ] ) + ' для "' + s_lek_pr + '" не введена фактическая стоимость лек. препарата за единицу измерения' )
          Endif
        else    // для COVID19
          If Empty( row[ 2 ] )
            AAdd( ta, 'пустая схема лечения' )
          Endif
          If Empty( row[ 8 ] )
            AAdd( ta, 'пустая схема соответствия препаратам' )
          Endif
          If ( arrGroupPrep := get_group_prep_by_kod( AllTrim( row[ 8 ] ), row[ 1 ] ) ) != nil
            mMNN := iif( arrGroupPrep[ 3 ] == 1, .t., .f. )
            If mMNN
              If Empty( row[ 3 ] )
                AAdd( ta, 'для "' + AllTrim( arrGroupPrep[ 2 ] ) + '" не выбран лекарственный препарат' )
              Endif
              If Empty( row[ 4 ] )
                AAdd( ta, 'для "' + AllTrim( arrGroupPrep[ 2 ] ) + '" не выбрана единица измерения' )
              Endif
              If Empty( row[ 5 ] )
                AAdd( ta, 'для "' + AllTrim( arrGroupPrep[ 2 ] ) + '" не выбрана доза препарата' )
              Endif
              If Empty( row[ 6 ] )
                AAdd( ta, 'для "' + AllTrim( arrGroupPrep[ 2 ] ) + '" не выбран способ введения препарата' )
              Endif
              If Empty( row[ 7 ] )
                AAdd( ta, 'для "' + AllTrim( arrGroupPrep[ 2 ] ) + '" не количество инъекций в день' )
              Endif
            endif
          Endif
        Endif
      Next
    Endif
  Endif

  //
  // ПРОВЕРКА РЕЗУЛЬТАТА ОБРАЩЕНИЯ "109-лечение продолжено", ОШИБКА 356
  // письмо Л.Н.Антоновой 26.11.24
  //
  if ( human_->USL_OK == USL_OK_HOSPITAL ) .and. ( human_->RSLT_NEW == 109 ) // лечение продолжено
    fl := .f.
    for counter := 1 to len( arrUslugi )
      if ! eq_any( arrUslugi[ counter ], 'st19.090', 'st19.091', 'st19.092', 'st19.093', ;
          'st19.094', 'st19.095', 'st19.096', 'st19.097', 'st19.098', 'st19.099', ;
          'st19.100', 'st19.101', 'st19.102' )
        fl := .t.
      endif
    next
    if fl
      AAdd( ta, 'для выбранного КСГ не допустимо применение результата обращения "109-лечение продолжено"' )
    endif
  endif

  //
  // ПРОВЕРКА НАПРАВИВШИХ МЕД. УЧРЕЖДЕНИЙ, ОШИБКА 348
  //
  // if ((substr(human_->OKATO, 1, 2) != '34') .and. (human_->USL_OK == USL_OK_HOSPITAL .or. human_->USL_OK == USL_OK_DAY_HOSPITAL)  ;
  // .and. substr(human_->FORMA14, 1, 1) == '0')
  // if  substr(ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS], 1, 2) == '34'
  // aadd(ta, 'для плановой госпитализации иногородних пациентов требуется направление от медицинского учреждения другого региона')
  // endif
  // endif

  //
  // ПРОВЕРКА ДЛЯ СЛУЧАЕВ ДИАГНОЗОВ Z00-Z99 в поликлинике
  //
  If human_->USL_OK == USL_OK_POLYCLINIC .and. between_diag( mdiagnoz[ 1 ], 'Z00', 'Z99' ) ;
      .and. ( ! diagnosis_for_replacement( mdiagnoz[ 1 ], human_->USL_OK ) )

    If lu_type == TIP_LU_STD .and. human_->RSLT_NEW != 314 .and. human_->RSLT_NEW != 308 .and. human_->RSLT_NEW != 309 ;
        .and. human_->RSLT_NEW != 311 .and. human_->RSLT_NEW != 315 .and. human_->RSLT_NEW != 305 .and. human_->RSLT_NEW != 306
      AAdd( ta, 'для диагноза "' + mdiagnoz[ 1 ] + '" результат обращения должен быть 314 или 308 или 309 или 311 или 315 или 305 или 306' )
    Endif
    If lu_type == TIP_LU_STD .and. human_->ISHOD_NEW != 304 .and. human_->ISHOD_NEW != 306
      AAdd( ta, 'для диагноза "' + mdiagnoz[ 1 ] + '" исход заболевания должен быть "304-без перемен" или "306-осмотр"' )
    Endif

  Endif
  //
  // ПРОВЕРКА УСТАНОВЛЕННЫХ ИМПЛАНТОВ
  //
  If Year( human->k_data ) > 2021
    For Each row in arrUslugi // проверим все услуги случая
      If service_requires_implants( row, human->k_data )
        // проверим наличие имплантов
        arrImplant := collect_implantant( human->kod )
        If ! Empty( arrImplant )
          For Each rowTmp in arrImplant
            If Empty( rowTmp[ 3 ] )
              AAdd( ta, 'не указана дата установки имплантанта' )
            Endif
            If ! between_date( human->n_data, human->k_data, rowTmp[ 3 ] )
              AAdd( ta, 'дата установки имплантанта не входит в период случая' )
            Endif
            If Empty( rowTmp[ 4 ] )
              AAdd( ta, 'для имплантанта необходимо указать его вид' )
            Endif
            If Empty( rowTmp[ 5 ] )
              AAdd( ta, 'для имплантанта необходимо указать серийный номер' )
            Endif
          Next
        Else
          AAdd( ta, 'для услуги ' + row + ' обязательно указание имплантантов' )
        Endif
      Endif
    Next
  Endif

  //
  // ПРОВЕРКА НАПРАВИВШИХ ВРАЧЕЙ
  //
  If is_exist_Prescription
    If human->k_data >= 0d20210801
      checksectionprescription( ta )
    Endif
  Endif
  //

  If is_pren_diagn //
    human_->PROFIL := 106 // ультразвуковой диагностике
    If human->n_data != human->k_data
      AAdd( ta, 'дата окончания лечения должна совпадать с датой начала лечения' )
    Endif
    If human->ishod != 99
      AAdd( ta, 'пренатальная диагностика вводится через специальный экран ввода' )
    Endif
    k1 := k2 := 0 ; oth_usl := ''
    For i := 1 To Len( au_lu )
      If eq_any( AllTrim( au_lu[ i, 1 ] ), '2.79.51', '8.30.3' )
        k1 += au_lu[ i, 6 ]
      Elseif AllTrim( au_lu[ i, 1 ] ) == '4.26.6'
        k1 += au_lu[ i, 6 ]
      Elseif AllTrim( au_lu[ i, 1 ] ) == '2.5.1'
        k2 += au_lu[ i, 6 ]
      Else
        oth_usl += AllTrim( au_lu[ i, 1 ] ) + ' '
      Endif
    Next
    If k1 != 3
      AAdd( ta, 'в листе учета неверное количество обязательных услуг' )
    Endif
    If k2 > 1
      AAdd( ta, 'в листе учета должно быть не более одной услуги 2.5.1' )
    Endif
    If !Empty( oth_usl )
      AAdd( ta, 'в листе учета пренатальной диагностики лишние услуги: ' + oth_usl )
    Endif
  Endif
  If human_->USL_OK == USL_OK_AMBULANCE .and. !( is_71_1 .or. is_71_2 .or. is_71_3 )
    AAdd( ta, 'для условия "Скорая помощь" не введены услуги СМП' )
  Endif
  If !Empty( u_1_stom )
    // просмотр других случаев данного больного
    Select HUMAN
    Set Order To 2
    find ( Str( glob_kartotek, 7 ) )
    Do While human->kod_k == glob_kartotek .and. !Eof()
      If ( fl := ( yearEnd == Year( human->k_data ) .and. rec_human != human->( RecNo() ) ) )
        //
      Endif
      If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
        fl := .f. // лист учёта снят по акту или выставлен повторно
      Endif
      If fl .and. m1novor != human_->NOVOR
        fl := .f. // лист учёта на новорожденного (или наоборот)
      Endif
      If fl .and. human_->idsp == 4 // лечебно-диагностическая процедура
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If f_is_1_stom( lshifr )
              AAdd( ta, 'оказана услуга первичного стоматологического приёма ' + u_1_stom + ',' )
              AAdd( ta, ' а в случае ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) + ' уже была оказана услуга ' + lshifr )
            Endif
          Endif
          Select HU
          Skip
        Enddo
      Endif
      Select HUMAN
      Skip
    Enddo
    Select HUMAN
    Set Order To 1
    human->( dbGoto( rec_human ) )
  Endif

  If human_->oplata == 2
    AAdd( ta, 'вернулся из ТФОМС с ошибкой и ещё не отредактирован' )
  Endif
  If Len( arr_unit ) > 1
    s := 'совокупность услуг должна быть из одной учётной единицы объёма, а в данном случае: '
    For i := 1 To Len( arr_unit )
      if ( iFind := AScan( arrPZ, { | x | x[ 2 ] == arr_unit[ i ] } ) ) > 0
        s += arrPZ[ iFind, PZ_ARRAY_NAME ] + ', '
      endif
    Next
    AAdd( ta, Left( s, Len( s ) -2 ) )
  Endif
  If fl_view .and. !is_s_dializ .and. !is_dializ .and. !is_perito .and. Len( a_rec_ffoms ) > 0 // повтор диагноза
    ltip := 0
    s := ''
    i := 1
    ASort( a_rec_ffoms, , , {| x, y| x[ 3 ] < y[ 3 ] } )
    If gusl_ok == USL_OK_POLYCLINIC // 3 - поликлиника
      If is_2_78
        ltip := 1
      Elseif is_2_80
        ltip := 2
      Elseif is_2_88
        ltip := 3
      Elseif is_2_89
        ltip := 4
      Endif
      If ltip == 0
        i := 0
      Else
        fl := .f.
        For i := 1 To Len( a_rec_ffoms )
          Select HU
          find ( Str( a_rec_ffoms[ i, 1 ], 7 ) )
          Do While hu->kod == a_rec_ffoms[ i, 1 ] .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
              left_lshifr_5 := Left( lshifr, 5 )
              If left_lshifr_5 == '2.78.'
                If !between_shifr( lshifr, '2.78.54', '2.78.60' )
                  a_rec_ffoms[ i, 2 ] := 1
                  s := AfterAtNum( '.', lshifr )
                  fl := .t.
                Endif
              Elseif left_lshifr_5 == '2.80.'
                If !between_shifr( lshifr, '2.80.34', '2.80.38' )
                  If ltip == 2 // если прошлое и новое лечение '2.80.'
                    a_rec_ffoms[ i, 2 ] := 2
                    s := AfterAtNum( '.', lshifr )
                    fl := .t.
                  Endif
                Endif
              Elseif left_lshifr_5 == '2.88.'
                If !between_shifr( lshifr, '2.88.46', '2.88.51' )
                  a_rec_ffoms[ i, 2 ] := 3
                  s := AfterAtNum( '.', lshifr )
                  fl := .t.
                Endif
              Elseif left_lshifr_5 == '2.89.'
                a_rec_ffoms[ i, 2 ] := 4
                s := AfterAtNum( '.', lshifr )
                fl := .t.
              Endif
            Endif
            If fl
              Exit
            Endif
            Select HU
            Skip
          Enddo
          If fl
            Exit
          Endif
        Next
        If !fl
          i := 0
        Endif
      Endif
    Endif
    If i > 0
      Select D_SROK
      Append Blank
      d_srok->kod   := human->kod
      d_srok->tip   := ltip
      d_srok->tips  := d_sroks
      d_srok->otd   := human->otd
      d_srok->kod1  := a_rec_ffoms[ i, 1 ]
      d_srok->tip1  := a_rec_ffoms[ i, 2 ]
      d_srok->tip1s := s
      d_srok->dni   := a_rec_ffoms[ i, 3 ]
    Endif
  Endif
  If Len( arr_unit ) == 0 .and. ! lTypeLUOnkoDisp // .and. ! is_disp_DVN_COVID
    AAdd( ta, 'ни в одной из услуг не обнаружен код план-заказа' )
  Endif
  If is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
    If eq_any( human_->RSLT_NEW, 317, 321, 332, 343, 347, 375 )
      If human->OBRASHEN == '1' // подозрение на ЗНО
        AAdd( ta, 'первая группа не может быть присвоена пациенту с подозрением на ЗНО' )
      Endif
    Elseif eq_any( human_->RSLT_NEW, 323, 324, 325, 334, 335, 336, 349, 350, 351, 355, 356, 373, 374, 357, 358, 377, 379 )
      fl := !Empty( arr_onkna )
      If !fl .and. m1dopo_na > 0
        fl := .t.
      Endif
      If !fl .and. Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
        fl := .t.
      Endif
      If !fl .and. Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
        fl := .t.
      Endif
      If !fl .and. m1napr_reab == 1 .and. m1profil_kojki > 0
        fl := .t.
      Endif
      If !fl
        AAdd( ta, 'пациент с группой здоровья большей 2 должен быть направлен на доп.обследование, к специалистам, на лечение или на реабилитацию' )
      Endif
    Endif
  Endif
  arr := { 301, 305, 308, 314, 315, 317, 318, 321, 322, 323, 324, 325, 332, 333, 334, 335, 336, 343, 344, 347, 348, 349, 350, ;
    351, 353, 355, 356, 357, 358, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, ;
    375, 376, 377, 378, 379 }
  If human_->ISHOD_NEW == 306 .and. AScan( arr, human_->RSLT_NEW ) == 0
    AAdd( ta, 'для исхода заболевания "306/Осмотр" некорректный результат обращения "' + ;
      inieditspr( A__MENUVERT, getv009(), human_->RSLT_NEW ) + '"' )
  Endif
  If !emptyany( human_->NPR_MO, human_2->NPR_DATE ) .and. !Empty( s := verify_dend_mo( human_->NPR_MO, human_2->NPR_DATE, .t. ) )
    AAdd( ta, 'направившая МО: ' + s )
  Endif
  // mpovod := iif(len(arr_povod) == 1, arr_povod[1, 1], 0)
  If ( is_disp_DDS .or. is_disp_DVN .or. is_prof_PN ) .and. ;
      ( Between( dEnd, 0d20200320, 0d20200906 ) .or. Between( dBegin, 0d20200320, 0d20200906 ) )
    AAdd( ta, 'случай не может быть начат ранее 7 сентября' )
  Endif
  If Len( ta ) > 0
    _ocenka := 0
    If AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. Type( 'old_npr_mo' ) == 'C'
      If !( old_npr_mo == human_->NPR_MO )
        If !( old_npr_mo == '000000' )
//          verify_ff( -1, .t., 80 ) // безусловный перевод страницы
        Endif
        ft:add_string( Replicate( '=', 80 ) )
        ft:add_string( 'Направление из МО: ' + human_->NPR_MO + ' ' + ret_mo( human_->NPR_MO )[ _MO_SHORT_NAME ] )
        ft:add_string( Replicate( '=', 80 ) )
      Endif
      old_npr_mo := human_->NPR_MO
    Endif
//    verify_ff( 80 - Len( ta ) -3, .t., 80 )
    // вывод заголовок пациента
    ft:add_string( '' )
    ft:add_string( header_error, FILE_CENTER, ' ', .t. )
    ft:add_string( '' )

    If human->cena_1 == 0 ; // если цена нулевая
      .and. eq_any( human->ishod, 201, 202 ) // диспансеризация взрослого населения
      ASize( ta, 1 ) // чтобы не выводить бессмысленные строки
      AAdd( ta, 'не определена сумма случая - отредактируйте' )
    Endif
    For i := 1 To Len( ta )
      For j := 1 To perenos( t_arr, ta[ i ], 78 )
        If j == 1
          ft:add_string( '- ' + t_arr[ j ] )
        Else
//          add_string( PadL( AllTrim( t_arr[ j ] ), 80 ) )
          ft:add_string( AllTrim( t_arr[ j ] ), FILE_LEFT )
        Endif
      Next
    Next
  Else
    If is_disp_DDS .or. is_prof_PN .or. is_disp_DVN
      mpzkol := 1
    Elseif AScan( kod_LIS(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 )
      mpzkol := Len( au_lu ) // кол-во анализов
    Endif
    If Len( arr_unit ) == 1
      if ( iFind := AScan( arrPZ, { | x | x[ 2 ] == arr_unit[ 1 ] } ) ) > 0
        mpztip := arrPZ[ iFind, PZ_ARRAY_ID ]
      endif
    Endif
    human_->POVOD := iif( Len( arr_povod ) > 0, arr_povod[ 1, 1 ], 1 )
    human_->PZTIP := mpztip
    human_->PZKOL := iif( mpzkol > 0, mpzkol, 1 )
  Endif
  alltrim_lshifr := alltrim( lshifr )
  If ( between_shifr( alltrim_lshifr, '2.88.111', '2.88.119' ) .and. ( human->k_data >= 0d20220201 ) )
    arr_povod[ 1, 1 ] := 1
    human_->POVOD := arr_povod[ 1, 1 ]
  Endif
  // ниже условие согласно соответствия АПП целям посещения согласно таблице Excel от 15.02.24
  if ( between_shifr( alltrim_lshifr, '2.88.1', '2.88.119' ) .and. ( human->k_data >= 0d20240201 ) )
    arr_povod[ 1, 1 ] := 1
    If is_dom .and. between_shifr( alltrim_lshifr, '2.88.46', '2.88.51' )
      arr_povod[ 1, 1 ] := 3 // 1.2 - активное посещение, т.е. на дому
    Endif
    human_->POVOD := arr_povod[ 1, 1 ]
  Endif

//  if ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. empty( human_->P_CEL ) .and. ( len( arr_povod ) == 1 )
  if ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. ( len( arr_povod ) == 1 )
    for counter := 1 to len( arrUslugi )
      mPCEL := getPCEL_usl( arrUslugi[ counter ] )
      human_->P_CEL := mPCEL
    next
  endif

  If !valid_guid( human_->ID_PAC )
    human_->ID_PAC := mo_guid( 1, human_->( RecNo() ) )
  Endif
  If !valid_guid( human_->ID_C )
    human_->ID_C := mo_guid( 2, human_->( RecNo() ) )
  Endif
  human_->ST_VERIFY := _ocenka // проверен
  If fl_view
    // dbUnLockAll()
  Endif

  Return ( _ocenka >= 5 )
