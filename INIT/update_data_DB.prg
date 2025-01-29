#include 'function.ch'
#include 'chip_mo.ch'

// 12.07.24 получение статуса обновления БД до определенной версии
function get_status_updateDB( idVer )
  // Возврат: .t. - обновление присутствует
  //          .f. - обновление отсутствует

  local ret := .f., fl

  fl := g_use( dir_server + 'ver_updatedb', , 'UPD', , .t. )

  Locate For ver == idVer
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

  fl := g_use( dir_server + 'ver_updatedb', , 'UPD', , .t. )

  UPD->( dbAppend() )
  UPD->ver := idVer
  UPD->done := 1

  UPD->( dbCloseArea() )

  return fl

// 10.07.24 
Function update_v____()

  Local i := 0, j := 0, fl

  stat_msg( 'Заполняем поле "Цель посещения"' )
  fl := g_use( dir_server + 'human_', , 'HUMAN_', , .t. )

//  use_base( 'mo_pers', 'PERS', .t. ) // откроем файл mo_pers
  if fl
    HUMAN_->( dbSelectArea() )
    HUMAN_->( dbGoTop() )
    Do While ! HUMAN_->( Eof() )
  //    i++
      @ MaxRow(), 1 Say HUMAN_->( RecNo() ) Color cColorStMsg
  //    If ! Empty( HUMAN_->PRVS_NEW )
  //      j := 0
  //      If ( j := AScan( arr_conv_V015_V021, {| x| x[ 1 ] == pers->PRVS_NEW } ) ) > 0
  //        HUMAN_->PRVS_021 := arr_conv_V015_V021[ j, 2 ]
  //      Endif
  //    Elseif ! Empty( HUMAN_->PRVS )
  //      HUMAN_->PRVS_021 := ret_prvs_v021( HUMAN_->PRVS )
  //    Endif
      HUMAN_->( dbSkip() )
    End Do
    dbCloseAll()        // закроем все
  endif

  Return Nil
  
// 29.01.25 проведение изменений в содержимом БД при обновлении
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

Return Nil

//  12.03.22
Function update_v21203()

  Local cAlias := 'IMPL'

  // Local t1 := 0, t2 := 0

  // t1 := seconds()
  r_use( dir_server + 'human', dir_server + 'humank', 'HUMAN' )
  r_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'HU' )

  g_use( dir_server + 'human_im', dir_server + 'human_im', cAlias )
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
  // t2 := seconds() - t1
  // if t2 > 0
  // n_message({"","Время обхода БД - "+sectotime(t2)},,;
  // color1,cDataCSay,,,color8)
  // endif
  // alertx(i, 'Количество сотрудников')

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
    @ MaxRow(), 1 Say pers->fio Color cColorStMsg
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

  r_use( dir_server + 'mo_otd', , 'otd' )
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

    r_use( dir_server + 'uslugi', , 'USL' )
    r_use( dir_server + 'mo_su', , 'MOSU' )

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
              @ MaxRow(), 1 Say human->fio Color cColorStMsg
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
          Set Relation To u_kod into MOSU
          mohu->( dbSeek( Str( mkod, 7 ) ) )
          Do While MOHU->kod == mkod .and. !Eof()
            MOSU->( dbGoto( MOHU->u_kod ) )
            lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )

            If ( lshifr == 'B01.026.002' .or. lshifr == 'B01.047.002' .or. lshifr == 'B01.047.006' ) .and. human_->VRACH != mohu->KOD_VR
              j++
              @ MaxRow(), 1 Say human->fio Color cColorStMsg
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

  dbEval( { || kart->PC3 := iif( kart->PN1 == 30, '035', ;
      iif( Empty( kart->PC3 ), '000', kart->PC3 ) ) } )

  dbCloseAll()        // закроем все
  return nil
