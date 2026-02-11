#include 'function.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 12.07.24 получение статуса обновления БД до определенной версии
function get_status_updateDB( idVer )
  // Возврат: .t. - обновление присутствует
  //          .f. - обновление отсутствует

  local ret := .f., fl

  fl := g_use( dir_server() + 'ver_updatedb', , 'UPD', , .t. )

  Locate For FIELD->ver == idVer
  If Found() .and. ( UPD->done == 1 )
    ret := .t.
  endif

  UPD->( dbCloseArea() )

  return ret

// 12.07.24 установка статуса обновления БД до определенной версии
function set_status_updateDB( idVer )
  // Возврат: .t. - обновление прошло успешно
  //          .f. - обновление не прошло или его не было

  local fl := .f.

  fl := g_use( dir_server() + 'ver_updatedb', , 'UPD', , .t. )

  UPD->( dbAppend() )
  UPD->ver := idVer
  UPD->done := 1

  UPD->( dbCloseArea() )

  return fl

// 09.02.26 проведение изменений в содержимом БД при обновлении
Function update_data_db( aVersion )

  Local snversion := Int( aVersion[ 1 ] * 10000 + aVersion[ 2 ] * 100 + aVersion[ 3 ] )
  Local ver_base := get_version_db()

  If ver_base < 21130 // переход на версию 2.11.30
    update_v21130()     // скоректироем листы углубленной диспансеризации
  Endif

  If ver_base < 21203 // переход на версию 2.12.3
    update_v21203()     // заполним поле MO_HU_K файла human_im.dbf
  Endif

  If ver_base < 21208 // переход на версию 2.12.08
    update_v21208()     // заполним поле PRVS_V021 кодами из справочника мед. специальностей V021
  Endif

  If ver_base < 50104 // переход на версию 5.1.4
    update_v50104()     // перенос данных об участниках СВО
  Endif

  If ver_base < 50202 // переход на версию 5.2.2
    update_v50202()     // перенос данных о гинеколгических услугах
  endif

  If ver_base < 60101 // переход на версию 6.1.1
    update_v60101()     // перенос данных о инвалидности I группы
  endif

  If ver_base < 60102 // переход на версию 6.1.2
    update_v60102()     // перенос данных о занятости пациентов
  endif

  If ver_base < 60103 // переход на версию 6.1.3
    update_v60103()     // перенос данных о прикреплении пациентов
  endif

  If ver_base < 60104 // переход на версию 6.1.4
    update_v60104()     // Заполним информацию о местах оказания помощи пациентам
  endif

  If ver_base < 60201 // переход на версию 6.2.1
    update_v60201()     // Заполним информацию о профиле МЗ РФ
  endif

  If ver_base < 60202 // переход на версию 6.2.2
    update_v60202()     // Заполним информацию о профиле МЗ РФ и UIDSPMO
  endif

  If ver_base < 60203 // переход на версию 6.2.3
    update_v60203()     // Заполним информацию о профиле МЗ РФ и UIDSPMO
  endif

Return Nil

// 09.02.26
Function update_v60203()     // Заполним информацию о профиле МЗ РФ

  stat_msg( 'Замена СМО 34001 на СМО 34007 в листах учета' )
  
  use_base( 'human', , .t. )
  human->( dbGoTop() )
  do while ! ( human->( Eof() ) )
    if ( human_->smo == "34001" .and. human_->reestr == 0 )
      human_->smo := "34007"
    endif
    human->( dbSkip() )
  enddo
  dbCloseAll()        // закроем все
  g_use( dir_server() + 'kartote_', , 'KART_',.T.,.T. )
  kart_->( dbGoTop() )
  do while ! ( kart_->( Eof() ) )
    if ( kart_->smo == '34001' )
      kart_->smo := '34007'
    endif
    kart_->( dbSkip() )
  enddo
  dbCloseAll()
  return nil

// 06.02.26
Function update_v60202()     // Заполним информацию о профиле МЗ РФ

  stat_msg( 'Заполним информацию о профиле МЗ РФ в листах учета' )
  
  r_use( dir_server() + 'kartote2', , 'KART2' )
  use_base( 'human', , .t. )
  human->( dbGoTop() )
  do while ! ( human->( Eof() ) )
    if ( human_->PROFIL != 0 )
      human->PROFIL_M := soot_v002_m003( human_->PROFIL, human->VZROS_REB )
    endif
//    kart2->( dbGoto( human->kod_k ) )
//    if ( ! ( kart2->( Eof() ) .and. kart2->( Bof() ) ) ) .and. ( ! Empty( kart2->MO_PR ))
//      human->MO_PR := code_TFOMS_to_FFOMS( kart2->mo_pr )
//    endif
    human->( dbSkip() )
  enddo

  stat_msg( 'Заполним информацию о профиле МЗ РФ в услугах' )

  g_use( dir_server() + 'human_u', , 'HU', , .f., .f. )
  g_use( dir_server() + 'human_u_', , 'HU_', , .t., .f. )
  hu_->( dbGoTop() )
  do while ! ( hu_->( Eof() ) )
    if ( hu_->PROFIL != 0 )
      hu->( dbGoto( hu_->( RecNo() ) ) )
      human->( dbGoto( hu->kod ) )
      hu_->PROFIL_M := soot_v002_m003( hu_->PROFIL, human->VZROS_REB )
    endif
    hu_->( dbSkip() )
  enddo

  use_base( 'mo_hu', , .t. )
  mohu->( dbGoTop() )
  do while ! ( mohu->( Eof() ) )
    if ( mohu->PROFIL != 0 )
      human->( dbGoto( mohu->kod ) )
      mohu->PROFIL_M := soot_v002_m003( mohu->PROFIL, human->VZROS_REB )
    endif
    mohu->( dbSkip() )
  enddo

  r_use( dir_exe() + '_mo_f033', , 'F033' )

  g_use( dir_server() + 'mo_otd', , 'OTD', , .t., .f. )
  otd->( dbGoTop() )
  do while ! otd->( Eof() )
    if ! Empty( otd->LPU_1 )
      Select f033
      Locate FOR FIELD->IDSPMO == AllTrim( otd->LPU_1 )
      if Found()
        otd->LPU_1 := f033->UIDSPMO
      endif
      Select otd
    endif
    otd->( dbSkip() )
  enddo

  dbCloseAll()        // закроем все

  return nil

// 03.02.26
Function update_v60201()     // Заполним информацию о профиле МЗ РФ

  stat_msg( 'Заполним информацию о профиле МЗ РФ в листах учета' )
  
  r_use( dir_server() + 'kartote2', , 'KART2' )
  use_base( 'human', , .t. )
  human->( dbGoTop() )
  do while ! ( human->( Eof() ) )
    if ( human_->PROFIL != 0 ) .and. ( human->PROFIL_M == 0 )
      human->PROFIL_M := soot_v002_m003( human_->PROFIL )
    endif
    kart2->( dbGoto( human->kod_k ) )
    if ( ! ( kart2->( Eof() ) .and. kart2->( Bof() ) ) ) .and. ( ! Empty( kart2->MO_PR ))
      human->MO_PR := code_TFOMS_to_FFOMS( kart2->mo_pr )
    endif
    human->( dbSkip() )
  enddo

  stat_msg( 'Заполним информацию о профиле МЗ РФ в услугах' )

  g_use( dir_server() + 'human_u_', , 'HU_', , .t., .f. )
  hu_->( dbGoTop() )
  do while ! ( hu_->( Eof() ) )
    if ( hu_->PROFIL != 0 ) .and. ( hu_->PROFIL_M == 0 )
      hu_->PROFIL_M := soot_v002_m003( hu_->PROFIL )
    endif
    hu_->( dbSkip() )
  enddo

  use_base( 'mo_hu', , .t. )
  mohu->( dbGoTop() )
  do while ! ( mohu->( Eof() ) )
    if ( mohu->PROFIL != 0 ) .and. ( mohu->PROFIL_M == 0 )
      mohu->PROFIL_M := soot_v002_m003( mohu->PROFIL )
    endif
    mohu->( dbSkip() )
  enddo

  dbCloseAll()        // закроем все

  return nil

// 27.01.26
Function update_v60104()     // Заполним информацию о местах оказания помощи пациентам

  stat_msg( 'Заполним информацию о местах оказания помощи пациентам' )
  use_base( 'human', , .t. )

  human->( dbGoTop() )
  do while ! ( human->( Eof() ) )
    if ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. ( human->MOP == 0 )
      human->MOP := 1 // поликлиника
    endif
    human->( dbSkip() )
  enddo
  dbCloseAll()        // закроем все

  return nil

// 23.01.26
Function update_v60103()     // перенос данных о прикреплении пациентов

  stat_msg( 'Переносим информацию о прикреплении пациентов' )
  r_use( dir_server() + 'kartote2', , 'KART2' )
  g_use( dir_server() + 'human', , 'HUMAN', , .t. )

  human->( dbGoTop() )
  do while ! ( human->( Eof() ) )
    kart2->( dbGoto( human->kod_k ) )
    if ( ! ( kart2->( Eof() ) .and. kart2->( Bof() ) ) ) .and. ( ! Empty( kart2->MO_PR ))
      human->MO_PR := code_TFOMS_to_FFOMS( kart2->mo_pr )
    endif
    human->( dbSkip() )
  enddo
  dbCloseAll()        // закроем все

  return nil

// 19.01.26
Function update_v60102()     // перенос данных о занятости пациентов

  stat_msg( 'Переносим информацию о занятости пациентов' )
  use_base( 'kartotek', 'kart', .t. ) // откроем файл kartotek
  kart->( dbGoTop() )
  do while ! kart->( Eof() )
    if kart_->PENSIONER == 1
      kart->VZ := 3
    elseif kart->RAB_NERAB == 0
      kart->VZ := 1
    elseif kart->RAB_NERAB == 1
      kart->VZ := 5
    elseif kart->RAB_NERAB == 2
      kart->VZ := 4
    else
      kart->VZ := 6
    endif
    kart->( dbSkip() )
  enddo
  dbCloseAll()        // закроем все

  use_base( 'human', 'human', .t. ) // откроем файл human
  human->( dbGoTop() )
  do while ! human->( Eof() )
    if human->RAB_NERAB == 0
      human->VZ := 1
    elseif human->RAB_NERAB == 1
      human->VZ := 5
    elseif human->RAB_NERAB == 2
      human->VZ := 4
    else
      human->VZ := 6
    endif
    human->( dbSkip() )
  enddo
  dbCloseAll()        // закроем все

  stat_msg( 'Корректировка информацию об инвалидах I группы' )
  use_base( 'kartotek', 'kart', .t. ) // откроем файл kartotek

  dbEval( { || iif( AllTrim( kart->PC3 ) == '083', kart->PC3 := '810', ) } )

  dbCloseAll()        // закроем все

  return nil

// 31.12.25
Function update_v60101()     // перенос данных о инвалидности I группы

  stat_msg( 'Переносим информацию об инвалидах I группы' )
  use_base( 'kartotek', 'kart', .t. ) // откроем файл kartotek

  dbEval( { || iif( kart_->INVALID == 1, kart->PC3 := '083', kart->PC3 := kart->PC3 ) } )

  dbCloseAll()        // закроем все

  return nil

//  12.03.22
Function update_v21203()

  Local cAlias := 'IMPL'

  r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
  r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )

  g_use( dir_server() + 'human_im', dir_server() + 'human_im', cAlias )
  ( cAlias )->( dbSelectArea() )
  ( cAlias )->( dbGoTop() )
  Do While ! ( cAlias )->( Eof() )
    If ( cAlias )->KOD_HUM != 0
      HU->( dbSeek( Str( ( cAlias )->KOD_HUM, 7 ) ) )
      If HU->( Found() )
        HUMAN->( dbSeek( Str( ( cAlias )->KOD_HUM, 7 ) ) )
        If HUMAN->( Found() )
          If ( cAlias )->( dbRLock() )
            ( cAlias )->MO_HU_K := HU->( RecNo() )
          Endif
          ( cAlias )->( dbRUnlock() )
        Endif
      Endif
    Endif
    ( cAlias )->( dbSkip() )
  End Do
  HU->( dbCloseAre() )
  HUMAN->( dbCloseAre() )
  ( cAlias )->( dbSelectArea() )
  index_base( 'human_im' )
  dbCloseAll()        // закроем все

  Return Nil

//  16.12.22
Function update_v21208()

  Local i := 0, j := 0
  Local arr_conv_V015_V021 := conversion_v015_v021()

  stat_msg( 'Заполняем специальность' )
  use_base( 'mo_pers', 'PERS', .t. ) // откроем файл mo_pers

  pers->( dbSelectArea() )
  pers->( dbGoTop() )
  Do While ! pers->( Eof() )
    i++
    @ MaxRow(), 1 Say pers->fio Color 'W+/R, , , , B/W'
    If ! Empty( pers->PRVS_NEW )
      j := 0
      If ( j := AScan( arr_conv_V015_V021, {| x| x[ 1 ] == pers->PRVS_NEW } ) ) > 0
        pers->PRVS_021 := arr_conv_V015_V021[ j, 2 ]
      Endif
    Elseif ! Empty( pers->PRVS )
      pers->PRVS_021 := ret_prvs_v021( pers->PRVS )
    Endif
    pers->( dbSkip() )
  End Do
  dbCloseAll()        // закроем все

  Return Nil

// 17.12.21
Function update_v21130()

  Local is_DVN_COVID := .f.
  Local mkod
  Local begin_DVN_COVID := 0d20210701   // дата начала углубленной диспансеризации
  Local i := 0, j := 0
  Local lshifr := ''

  r_use( dir_server() + 'mo_otd', , 'otd' )
  OTD->( dbGoTop() )
  Do While ! otd->( Eof() )
    If otd->TIPLU == TIP_LU_DVN_COVID
      is_DVN_COVID := .t.
      Exit
    Endif
    otd->( dbSkip() )
  End Do
  otd->( dbCloseArea() )

  If is_DVN_COVID

    stat_msg( 'Проверка и исправление кода врача в листах учета Углубленной диспансеризации' )

    r_use( dir_server() + 'uslugi', , 'USL' )
    r_use( dir_server() + 'mo_su', , 'MOSU' )

    use_base( 'mo_hu' )
    use_base( 'human_u' ) // откроем файл human_u и сопутствующие файлы

    use_base( 'human' ) // откроем файл human_u и сопутствующие файлы

    human->( dbSelectArea() )
    human->( dbGoTop() )

    Do While ! human->( Eof() )
      mkod := human->kod
      If human->k_data >= begin_DVN_COVID
        If human->ishod == 401
          hu->( dbSelectArea() )
          hu->( dbSeek( Str( mkod, 7 ) ) )
          Do While hu->kod == mkod .and. !Eof()
            usl->( dbGoto( hu->u_kod ) )
            If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
              lshifr := usl->shifr
            Endif
            lshifr := AllTrim( lshifr )

            If lshifr == '70.8.1' .and. human_->VRACH != hu->KOD_VR
              i++
              @ MaxRow(), 1 Say human->fio Color 'W+/R, , , , B/W'
              human_->( dbSelectArea() )
              If human_->( dbRLock() )
                human_->VRACH := hu->KOD_VR
              Endif
              human_->( dbRUnlock() )
              hu->( dbSelectArea() )
            Endif
            hu->( dbSkip() )
          End Do

        Elseif human->ishod == 402
          Select MOHU
          Set Relation To FIELD->u_kod into MOSU
          mohu->( dbSeek( Str( mkod, 7 ) ) )
          Do While MOHU->kod == mkod .and. !Eof()
            MOSU->( dbGoto( MOHU->u_kod ) )
            lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )

            If ( lshifr == 'B01.026.002' .or. lshifr == 'B01.047.002' .or. lshifr == 'B01.047.006' ) .and. human_->VRACH != mohu->KOD_VR
              j++
              @ MaxRow(), 1 Say human->fio Color 'W+/R, , , , B/W'
              human_->( dbSelectArea() )
              If human_->( dbRLock() )
                human_->VRACH := mohu->KOD_VR
              Endif
              human_->( dbRUnlock() )
              mohu->( dbSelectArea() )
            Endif
            mohu->( dbSkip() )
          Enddo
        Endif
      Endif
      human->( dbSelectArea() )
      human->( dbSkip() )
    End Do
    dbCloseAll()        // закроем все
  Endif

  Return Nil

// 29.01.25
function update_v50104()     // перенос данных об участниках СВО

  stat_msg( 'Переносим информацию об участниках СВО' )
  use_base( 'kartotek', 'kart', .t. ) // откроем файл kartotek

  dbEval( { || kart->PC3 := '000' } )

  dbCloseAll()        // закроем все
  return nil

// 03.02.25
Function update_v50202()     // перенос данных о гинеколгических услугах

  local  i
  Local org_gen_N_PNF := { ;  
   '101001', ; //	ГБУЗ 'ВОКБ № 1'
   '101002', ; //	ГБУЗ 'ВОДКБ'
   '101003', ; //	ГБУЗ 'ВОКБ № 3'
   '101201', ; //	ГБУЗ 'ВОКГВВ'
   '102604', ; //	ГБУЗ 'ВОККВД'
   '104001', ; //	ГБУЗ 'ВОКЦМР'
   '104401', ; //	ГБУЗ 'ВОККЦ'
   '106001', ; //	ГБУЗ 'ВОКПЦ № 1', г.Волжский
   '106002', ; //	ГБУЗ 'ВОКПЦ № 2'
   '131001', ; //	ГУЗ 'ГКБ № 1'
   '131940', ; //	ФГБУЗ ВМКЦ ФМБА России
   '146004', ; //	ГУЗ 'Родильный дом № 4'
   '151005', ; //	ГУЗ 'КБ № 5'
   '161007', ; //	ГУЗ 'КБ СМП № 7'
   '171004', ; //	ГУЗ 'Клиническая больница № 4 '
   '184551', ; //	Филиал ООО 'МЕДИС' в г.Волгограде
   '186002', ; //	ГУЗ 'Клинический родильный дом № 2'
   '254570', ; //	АО 'ВТЗ'
   '731002', ; //	ФКУЗ 'МСЧ МВД России по Волгоградской области'
   '741904', ; //	ФГБУ '413 ВГ' Минобороны России
   '801926', ; //	ООО 'Геном-Волга'
   '804504', ; //	АО 'ФНПЦ 'Титан-Баррикады'
   '805929', ; //	ООО 'МК 'Рефлекс'
   '805938', ; //	НМЧУ 'ЗДОРОВЬЕ+'
   '805960', ; //	ООО 'Вита-Лайт'
   '805972' } //	ООО 'Клиника Семья'
  
  Local mas_usl_gen0      := { '2.79.13', '2.79.47', '2.80.8',  '2.88.33',  '2.78.26' }
  Local mas_usl_gen_N_PNF := { '2.79.78', '2.79.80', '2.80.70', '2.88.147', '2.78.118' }
  Local mas_usl_gen_PNF   := { '2.79.77', '2.79.79', '2.80.69', '2.88.146', '2.78.117' }
  Local mas_kod_gen_N_PNF := { 0, 0, 0, 0, 0 }
  Local mas_kod_gen_PNF   := { 0, 0, 0, 0, 0 }
  Local mas_kod_gen0      := { 0, 0, 0, 0, 0 }
  Local cena, flag := .F. 
  
  
  stat_msg( 'Изменение информации о гинекологических приемах' )
  Use_base( 'lusl' )
  Use_base( 'luslc' )
  Use_base( 'uslugi' )
  R_Use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1',;
                              dir_server() + 'uslugi1s' }, 'USL1' )
  //проверяем наличие услуг в нашем справочнике - если нет - добавляем
  // и создаем массив позиций в файле услуг
  //Function foundourusluga( lshifr, ldate, lprofil, lvzros_reb, /*@*/lu_cena, ipar, not_cycle)
  for i := 1 to len( org_gen_N_PNF )
    if org_gen_N_PNF[ i ] == glob_mo()[ _MO_KOD_TFOMS ] 
      flag := .T. 
    endif
  next  
  if flag
    for i := 1 to 5
      mas_kod_gen_N_PNF[ i ] := foundourusluga( mas_usl_gen_N_PNF[ i ], 0d20250102, 136, 0, cena )
    next
  else
    for i := 1 to 5
      mas_kod_gen_PNF[ i ] := foundourusluga( mas_usl_gen_PNF[ i ], 0d20250102, 136, 0, cena )
    next
  endif  
  // теперь старые услуги   
  for i := 1 to 5
    mas_kod_gen0[ i ] := foundourusluga( mas_usl_gen0[ i ], 0d20241202, 136, 0, cena ) // смотрю по декабрю 2024 года
  next    
  // массивы для замены готовы
  Use_base( 'human' )
  Use_base( 'human_u' )
  select HUMAN
  set order to 4 //   dir_server() + 'humand'
  find ( dtos( stod( '20250101' ) ) )
  do while year( human->k_data )== 2025 .and. !eof()    
    // по случ - отфильтровал - теперь надо по услугам
    select hu
    set order to 1
    find ( str( human->kod, 7 ) )
    do while human->kod == hu->kod .and. !eof() 
      // проверяем на шифр услуги по списку 
      g_rlock( 'forever' )
      if hu->u_kod == mas_kod_gen0[ 1 ]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[ 1 ]
        else
          hu->u_kod := mas_kod_gen_PNF[ 1 ]
        endif
      elseif hu->u_kod == mas_kod_gen0[ 2 ]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[ 2 ]
        else
          hu->u_kod := mas_kod_gen_PNF[ 2 ]
        endif
      elseif hu->u_kod == mas_kod_gen0[ 3 ]  
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[ 3 ]
        else
          hu->u_kod := mas_kod_gen_PNF[ 3 ]
        endif
      elseif hu->u_kod == mas_kod_gen0[ 4 ]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[ 4 ]
        else
          hu->u_kod := mas_kod_gen_PNF[ 4 ]
        endif
      elseif hu->u_kod == mas_kod_gen0[ 5 ]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[ 5 ]
        else
          hu->u_kod := mas_kod_gen_PNF[ 5 ]
        endif
      endif  
      select hu 
      Unlock
      skip
    enddo 
    select human
    skip
  enddo

  dbCloseAll()        // закроем все
  Return Nil
  
// 30.05.25
function illegal_stad_kod()

  local cAlias, cAliasHum, ft, exist, i
  local name_file := cur_dir() + 'error_stad.txt', reg_print := 2

  exist := .f.
  i := 0
  cAlias := 'ONKOSL'
  cAliasHum := 'HUMAN'

  r_use( dir_server() + 'human', , cAliasHum )
  r_use( dir_server() + 'mo_onksl', , cAlias )
  ( cAlias )->( dbGoTop() )
  do while ! ( cAlias )->( Eof() )

    if ( cAlias )->STAD > 333 // последний код старого N002
      if ! exist
        ft := tfiletext():new( name_file, , .t., , .t. )
        ft:add_string( '' )
        ft:add_string( 'Список пациентов с ошибками стадии онкозаболевания', FILE_CENTER, ' ' )
        ft:add_string( '' )
        exist := .t.
      endif
      ( cAliasHum )->( dbGoto( ( cAlias )->KOD ) )
      if ( ! ( cAliasHum )->( Eof() ) ) .and. ( ! ( cAliasHum )->( Bof() ) )
        ft:add_string( AllTrim( ( cAliasHum )->FIO ) + '  ' + DToC( ( cAliasHum )->Date_R ) )
      endif
      i++
    endif
    ( cAlias )->( dbSkip() )
  Enddo

  ( cAlias )->( dbCloseArea() )
  ( cAliasHum )->( dbCloseArea() )
  if i > 0
    ft := nil
    viewtext( name_file, , , , .t., , , reg_print )
  endif
  return nil