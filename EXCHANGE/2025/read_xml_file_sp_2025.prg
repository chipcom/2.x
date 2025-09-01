#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 01.09.25 прочитать и 'разнести' по базам данных реестр СП и ТК 
Function read_xml_file_sp_2025( arr_XML_info, aerr, /*@*/current_i2, full_zip, cFileProtokol )

  Local count_in_schet := 0
  local mnschet, bSaveHandler, ii1, ii2, i, k, t_arr[ 2 ]
  local ldate_sptk, s, fl_589, mANSREESTR, mkod_reestr
  local arr_fio, mdate_r

  Local reserveKSG_ID_C := '' // GUID для вложенных двойных случаев

  If !( Type( 'p_ctrl_enter_sp_tk' ) == 'L' )
    Private p_ctrl_enter_sp_tk := .f.
  Endif
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  ldate_sptk := tmp1->_DATA
  mnschet := Int( Val( tmp1->_NSCHET ) )  // в число (отрезать всё, что после '-')
  mANSREESTR := AfterAtNum( '-', tmp1->_NSCHET )
  r_use( dir_server() + 'mo_rees', , 'REES' )
  Index On Str( FIELD->NSCHET, 6 ) to ( cur_dir() + 'tmp_rees' ) For FIELD->NYEAR == tmp1->_YEAR
//  find ( Str( mnschet, 6 ) )
  rees->( dbSeek( Str( mnschet, 6 ) ) )
  If rees->( Found() )
    mkod_reestr := arr_XML_info[ 7 ] := rees->kod
    StrFile( 'Обрабатывается ответ ТФОМС (' + AllTrim( tmp1->_NSCHET ) + ') на реестр № ' + ;
      lstr( rees->NSCHET ) + ' от ' + full_date( rees->DSCHET ) + 'г. (' + ;
      lstr( rees->KOL ) + ' чел.)' + ;
      hb_eol(), cFileProtokol, .t. )
    If !emptyany( rees->nyear, rees->nmonth )
      StrFile( 'выставленный за ' + ;
        mm_month()[ rees->nmonth ] + Str( rees->nyear, 5 ) + ' года' + ;
        hb_eol(), cFileProtokol, .t. )
    Endif
    StrFile( hb_eol(), cFileProtokol, .t. )
    //
    r_use( dir_server() + 'mo_xml', , 'MO_XML' )
    Index On FIELD->ANSREESTR to ( cur_dir() + 'tmp_xml' ) For FIELD->reestr == mkod_reestr
//    find ( mANSREESTR )
    mo_xml->( dbseek( mANSREESTR ) )
    If mo_xml->( Found() )
      AAdd( aerr, 'По реестру № ' + lstr( mnschet ) + ' от ' + date_8( tmp1->_DSCHET ) + ' уже прочитан ответ номер "' + AllTrim( tmp1->_NSCHET ) + '"' )
    Endif
  Else
    AAdd( aerr, 'Не найден РЕЕСТР № ' + lstr( mnschet ) + ' от ' + date_8( tmp1->_DSCHET ) )
  Endif
  If Empty( aerr ) .and. !extract_reestr( rees->( RecNo() ), rees->name_xml )
    AAdd( aerr, Center( 'Не найден ZIP-архив с РЕЕСТРом № ' + lstr( mnschet ) + ' от ' + date_8( tmp1->_DSCHET ), 80 ) )
    AAdd( aerr, '' )
    AAdd( aerr, Center( dir_server() + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip(), 80 ) )
    AAdd( aerr, '' )
    AAdd( aerr, Center( 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!', 80 ) )
  Endif
  If Empty( aerr )
    r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    r_use( dir_server() + 'human', , 'HUMAN' )
    r_use( dir_server() + 'human_', , 'HUMAN_' )
    r_use( dir_server() + 'mo_rhum', , 'RHUM' )
    Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
    Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
    // сначала проверка
    ii1 := ii2 := 0
//    Go Top
    tmp2->( dbGoTop() )
    Do While ! tmp2->( Eof() )
      If tmp2->_OPLATA == 1
        ++ii1
        If AScan( glob_arr_smo, {| x| x[ 2 ] == Int( Val( tmp2->_SMO ) ) } ) == 0
          AAdd( aerr, 'Некорректное значение атрибута SMO: ' + tmp2->_SMO )
        Endif
      Elseif tmp2->_OPLATA == 2
        ++ii2
      Else
        AAdd( aerr, 'Некорректное значение атрибута OPLATA: ' + lstr( tmp2->_OPLATA ) )
      Endif
//      Select RHUM
//      find ( Str( tmp2->_N_ZAP, 6 ) )
      rhum->( dbSeek( Str( tmp2->_N_ZAP, 6 ) ) )
      If rhum->( Found() )
        human_->( dbGoto( rhum->KOD_HUM ) )
        human->( dbGoto( rhum->KOD_HUM ) )
        If human->ishod == 89 // это 2-ой случай в двойном случае
//          Select HUMAN_3
          dbSelectArea( 'HUMAN_3')
          Set Order To 2
//          find ( Str( rhum->KOD_HUM, 7 ) )
          human_3->( dbSeek( Str( rhum->KOD_HUM, 7 ) ) )
          If human_3->( Found() )
            reserveKSG_ID_C = human_3->ID_C
            human_->( dbGoto( human_3->kod ) )   // встать на 1-ый случай
            human->( dbGoto( human_3->kod ) )    // т.к. GUID'ы в реестре из 1-го случая
          Endif
        Endif
        tmp2->fio := human->fio
        If rhum->OPLATA > 0
          AAdd( aerr, 'Пациент с REES_ZAP=' + lstr( rhum->REES_ZAP ) + ' был прочитан в предыдущем реестре СП и ТК' )
          If !Empty( human->fio )
            AAdd( aerr, '└─>(ФИО пациента = ' + AllTrim( human->fio ) + ')' )
          Endif
        Endif
        If iif( p_ctrl_enter_sp_tk, ( tmp2->_OPLATA == 1 ), .t. )
          If !( rhum->REES_ZAP == human_->REES_ZAP )
            AAdd( aerr, 'Не равен параметр REES_ZAP: ' + lstr( rhum->REES_ZAP ) + ' != ' + lstr( human_->REES_ZAP ) )
          Endif
          If !( Upper( tmp2->_ID_PAC ) == Upper( human_->ID_PAC ) )
            AAdd( aerr, 'Не равен параметр ID_PAC: ' + tmp2->_ID_PAC + ' != ' + human_->ID_PAC )
          Endif
          If Empty( reserveKSG_ID_C ) .and. !( Upper( tmp2->_ID_C ) == Upper( human_->ID_C ) )
            AAdd( aerr, 'Не равен параметр ID_C: ' + tmp2->_ID_C + ' != ' + human_->ID_C )
          Elseif !Empty( reserveKSG_ID_C ) .and. !( Upper( tmp2->_ID_C ) == Upper( reserveKSG_ID_C ) )
            AAdd( aerr, 'Не равен параметр ID_C для вложенного двойного случая: ' + tmp2->_ID_C + ' != ' + reserveKSG_ID_C )
          Endif
        Endif
      Else
        AAdd( aerr, 'Не найден случай с N_ZAP=' + lstr( tmp2->_N_ZAP ) + ', _ID_PAC=' + tmp2->_ID_PAC )
      Endif
      reserveKSG_ID_C := ''
//      Select TMP2
//      Skip
      tmp2->( dbSkip() )
    Enddo
    tmp1->kol1 := ii1
    tmp1->kol2 := ii2
//    Close databases
    dbCloseAll()
    If Empty( aerr ) // если проверка прошла успешно
      Private fl_open := .t.
      bSaveHandler := ErrorBlock( {| x| Break( x ) } )
      Begin Sequence
        If ii1 > 0 // были пациенты без ошибок
          index_base( 'schet' ) // для составления счетов
          index_base( 'human' ) // для разноски счетов
          index_base( 'human_3' ) // двойные случаи
          Use ( dir_server() + 'human_u' ) New READONLY
          Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + 'human_u' ) progress
//          Use
          human_u->( dbCloseArea() )
          Use ( dir_server() + 'mo_hu' ) New READONLY
          Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + 'mo_hu' ) progress
//          Use
          mo_hu->( dbCloseArea() )
        Endif
        If ii2 > 0 // были пациенты с ошибками
          If !p_ctrl_enter_sp_tk
            index_base( 'mo_refr' )  // для записи причин отказов
          Endif
          If ii1 == 0 // в ответном файле не было пациентов без ошибок
            index_base( 'human' ) // для разноски ФИО
          Endif
        Endif
      RECOVER USING error
        AAdd( aerr, 'Возникла непредвиденная ошибка при переиндексировании!' )
      End
      ErrorBlock( bSaveHandler )
//      Close databases
      dbCloseAll()
    Endif
    If Empty( aerr ) // если проверка прошла успешно
      // запишем принимаемый файл (реестр СП)
      // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server()+dir_XML_TF())
      chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
      g_use( dir_server() + 'mo_xml', , 'MO_XML' )
      addrecn()
      mo_xml->KOD := RecNo()
      mo_xml->FNAME := cReadFile
      mo_xml->DFILE := ldate_sptk
      mo_xml->TFILE := ''
      mo_xml->DREAD := Date() //  sys_date
      mo_xml->TREAD := hour_min( Seconds() )
      mo_xml->TIP_IN := _XML_FILE_SP // тип принимаемого файла;3-ФЛК, 4-СП, 5-РАК, 6-РПД пишем в каталог XML_TF
      mo_xml->DWORK  := Date()    // sys_date
      mo_xml->TWORK1 := cTimeBegin
      mo_xml->REESTR := mkod_reestr
      mo_xml->ANSREESTR := mANSREESTR
      mo_xml->KOL1 := ii1
      mo_xml->KOL2 := ii2
      //
      mXML_REESTR := mo_xml->KOD
//      Use
      mo_xml->( dbCloseArea() )
      If ii2 > 0
        If !p_ctrl_enter_sp_tk
          g_use( dir_server() + 'mo_refr', dir_server() + 'mo_refr', 'REFR' )
        Endif
        // G_Use(dir_server() + 'mo_kfio',,'KFIO')
        // index on str(kod, 7) to (cur_dir() + 'tmp_kfio')
      Endif
      // открыть распакованный реестр
      Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
      Index On Str( Val( FIELD->n_zap ), 6 ) to ( cur_dir() + 'tmpt1' )
      Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt2' )
      Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3
      Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + 'tmpt3' )
      Use ( cur_dir() + 'tmp_r_t4' ) New Alias T4
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt4' )
      Use ( cur_dir() + 'tmp_r_t5' ) New Alias T5
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt5' )
      Use ( cur_dir() + 'tmp_r_t6' ) New Alias T6
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt6' )
      Use ( cur_dir() + 'tmp_r_t7' ) New Alias T7
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt7' )
      Use ( cur_dir() + 'tmp_r_t8' ) New Alias T8
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt8' )
      Use ( cur_dir() + 'tmp_r_t9' ) New Alias T9
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt9' )
      Use ( cur_dir() + 'tmp_r_t10' ) New Alias T10
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) + FIELD->regnum + FIELD->code_sh + FIELD->date_inj to ( cur_dir() + 'tmpt10' )
      Use ( cur_dir() + 'tmp_r_t11' ) New Alias T11
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt11' )
      Use ( cur_dir() + 'tmp_r_t12' ) New Alias T12
      Index On FIELD->IDCASE + Str( FIELD->sluch, 6 ) to ( cur_dir() + 'tmpt12' )
      Use ( cur_dir() + 'tmp_r_t1_1' ) New Alias T1_1
      Index On FIELD->IDCASE to ( cur_dir() + 'tmpt1_1' )
      //
      g_use( dir_server() + 'mo_kfio', , 'KFIO' )
      Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_kfio' )
      g_use( dir_server() + 'kartote2', , 'KART2' )
      g_use( dir_server() + 'kartote_', , 'KART_' )
      g_use( dir_server() + 'kartotek', dir_server() + 'kartoten', 'KART' )
      Set Order To 0 // индекс открыт для реконструкции при перезаписи ФИО и даты рождения
      r_use( dir_server() + 'mo_otd', , 'OTD' )
      g_use( dir_server() + 'human_', , 'HUMAN_' )
      g_use( dir_server() + 'human', { dir_server() + 'humann', dir_server() + 'humans' }, 'HUMAN' )
      Set Order To 0 // индексы открыты для реконструкции при перезаписи ФИО
      Set Relation To RecNo() into HUMAN_, To FIELD->otd into OTD
      g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
      g_use( dir_server() + 'mo_rhum', , 'RHUM' )
      Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
      Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
      Index On Str( FIELD->_n_zap, 8 ) to ( cur_dir() + 'tmp3' )
      Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
      count_in_schet := LastRec()
      current_i2 := 0
//      Go Top
      tmp2->( dbGoTop() )
      Do While ! tmp2->( Eof() )
        If tmp2->_OPLATA == 1
//          Select T1
//          find ( Str( tmp2->_N_ZAP, 6 ) )
          t1->( dbSeek( Str( tmp2->_N_ZAP, 6 ) ) )
          If t1->( Found() )
            t1->VPOLIS := lstr( tmp2->_VPOLIS )
            t1->SPOLIS := tmp2->_SPOLIS
            t1->NPOLIS := tmp2->_NPOLIS
            t1->ENP    := tmp2->_ENP
            t1->SMO    := tmp2->_SMO
            t1->SMO_OK := tmp2->_SMO_OK
            t1->MO_PR  := tmp2->_MO_PR
          Endif
        Endif
//        Select RHUM
//        find ( Str( tmp2->_N_ZAP, 6 ) )
        rhum->( dbSeek( Str( tmp2->_N_ZAP, 6 ) ) )
        g_rlock( forever )
        rhum->OPLATA := tmp2->_OPLATA
        tmp2->kod_human := rhum->KOD_HUM
        is_2 := 0
//        Select HUMAN
//        Goto ( rhum->KOD_HUM )
        human->( dbGoto( rhum->KOD_HUM ) )
        If eq_any( human->ishod, 88, 89 )
          Select HUMAN_3
          If human->ishod == 88
            Set Order To 1
            is_2 := 1
          Else
            Set Order To 2
            is_2 := 2
          Endif
//          find ( Str( rhum->KOD_HUM, 7 ) )
          human_3->( dbSeek( Str( rhum->KOD_HUM, 7 ) ) )
          If human_3->( Found() ) // если нашли двойной случай
            Select HUMAN
            If human->ishod == 88  // если реестр составлен по 1-му листу
//              Goto ( human_3->kod2 )  // встать на 2-ой
              human->( dbGoto( human_3->kod2 ) )  // встать на 2-ой
            Else
//              Goto ( human_3->kod )   // иначе - на 1-ый
              human->( dbGoto( human_3->kod ) )   // иначе - на 1-ый
            Endif
//            human_->( g_rlock( forever ) )
            human_->( RLock() )
            human_->OPLATA := tmp2->_OPLATA
            If tmp2->_OPLATA > 1 .and. !p_ctrl_enter_sp_tk
              human_->REESTR := 0 // направляется на дальнейшее редактирование
              human_->ST_VERIFY := 0 // снова ещё не проверен
            Endif
//            human_3->( g_rlock( forever ) )
            human_3->( RLock() )
            human_3->OPLATA := tmp2->_OPLATA
            human_3->REESTR := 0
          Endif
        Endif
        Select HUMAN
//        Goto ( rhum->KOD_HUM )
        human->( dbGoto( rhum->KOD_HUM ) )
        g_rlock( forever )
//        human_->( g_rlock( forever ) )
        human_->( RLock() )
        human_->OPLATA := tmp2->_OPLATA
        kart->( dbGoto( human->kod_k ) )
        fl_589 := .f.
        If tmp2->_OPLATA == 1
          human->POLIS   := make_polis( tmp2->_spolis, tmp2->_npolis )
          human_->VPOLIS := tmp2->_VPOLIS
          human_->SPOLIS := tmp2->_SPOLIS
          human_->NPOLIS := tmp2->_NPOLIS
          human_->OKATO  := tmp2->_SMO_OK
          If Int( Val( tmp2->_SMO ) ) != 34 // не иногородние
            human_->SMO := tmp2->_SMO
          Endif
          If kart->za_smo == -9
            Select KART
            g_rlock( forever )
            kart->za_smo := 0  // снять признак 'Проблемы с полисом'
            dbUnlock()
          Endif
          If !eq_any( tmp2->_MO_PR, Space( 6 ), Replicate( '0', 6 ) ) .or. !Empty( tmp2->_enp )
            Select KART2
            Do While kart2->( LastRec() ) < human->kod_k
//              Append Blank
              kart2->( dbAppend() )
            Enddo
//            Goto ( human->kod_k )
            kart2->( dbGoto( human->kod_k ) )
            If Empty( kart2->MO_PR )
              g_rlock( forever )
              If !eq_any( tmp2->_MO_PR, Space( 6 ), Replicate( '0', 6 ) )
                kart2->MO_PR := tmp2->_MO_PR
                kart2->TIP_PR := 2 // тип/статус прикрепления 2-из реестра СП и ТК
                kart2->DATE_PR := ldate_sptk
                If Empty( kart2->pc4 )
                  kart2->pc4 := date_8( kart2->pc4 )
                Endif
              Endif
              If !Empty( tmp2->_enp )
                kart2->kod_mis := tmp2->_enp
              Endif
              dbUnlock()
            Endif
          Endif
        Else // tmp2->_OPLATA == 2
          --count_in_schet    // не включается в счет,
          If !p_ctrl_enter_sp_tk
            human_->REESTR := 0 // а направляется на дальнейшее редактирование
            human_->ST_VERIFY := 0 // снова ещё не проверен
            If current_i2 == 0
              StrFile( Space( 10 ) + 'Список случаев с ошибками' + hb_eol() + hb_eol(), cFileProtokol, .t. )
            Endif
            ++current_i2
            lal := 'human'
            If is_2 > 0
              lal += '_3'
            Endif
            StrFile( lstr( current_i2 ) + '. ' + AllTrim( human->fio ) + ', ' + ;
              full_date( human->date_r ) + ;
              iif( Empty( otd->SHORT_NAME ), '', ' [' + AllTrim( otd->SHORT_NAME ) + ']' ) + ;
              ' ' + AllTrim( human->KOD_DIAG ) + ;
              ' ' + date_8( &lal.->n_data ) + '-' + ;
              date_8( &lal.->k_data ) + hb_eol(), cFileProtokol, .t. )
            // изменение ФИО
            If !emptyall( tmp2->CORRECT, tmp2->_FAM, tmp2->_IM, tmp2->_OT, tmp2->_DR )
              arr_fio := retfamimot( 2, .f., .t. )
              mdate_r := human->date_r
              s := ''
              // s := space(5) + '!Ошибки в персональных данных!'+hb_eol()
              If !Empty( tmp2->_FAM )
                // s += space(5) + 'старая фамилия '' + alltrim(arr_fio[1]) + '', изменена на '' + alltrim(tmp2->_FAM) + '''+hb_eol()
                s += Space( 5 ) + 'фамилия в нашей БД "' + AllTrim( arr_fio[ 1 ] ) + '", в регистре ТФОМС "' + AllTrim( tmp2->_FAM ) + '"' + hb_eol()
                arr_fio[ 1 ] := AllTrim( tmp2->_FAM )
              Endif
              If !Empty( tmp2->_IM )
                // s += space(5) + 'старое имя '' + alltrim(arr_fio[2]) + '', изменено на '' + alltrim(tmp2->_IM) + '''+hb_eol()
                s += Space( 5 ) + 'имя в нашей БД "' + AllTrim( arr_fio[ 2 ] ) + '", в регистре ТФОМС "' + AllTrim( tmp2->_IM ) + '"' + hb_eol()
                arr_fio[ 2 ] := AllTrim( tmp2->_IM )
              Endif
              If !emptyall( tmp2->CORRECT, tmp2->_OT )
                // s += space(5) + 'старое отчество '' + alltrim(arr_fio[3]) + '', изменено на '' + alltrim(tmp2->_OT) + '''+hb_eol()
                s += Space( 5 ) + 'отчество в нашей БД "' + AllTrim( arr_fio[ 3 ] ) + '", в регистре ТФОМС "' + AllTrim( tmp2->_OT ) + '"' + hb_eol()
                arr_fio[ 3 ] := AllTrim( tmp2->_OT )
              Endif
              If !Empty( tmp2->_DR )
                mdate_r := xml2date( tmp2->_DR )
                // s += space(5) + 'старая дата рождения ' + full_date(human->date_r) + ', изменена на ' + full_date(mdate_r) + hb_eol()
                s += Space( 5 ) + 'дата рождения в нашей БД ' + full_date( human->date_r ) + ', в регистре ТФОМС ' + full_date( mdate_r ) + hb_eol()
              Endif
              // s += space(5) + '(исправлено - войти в редактирование л/у и подтвердить запись)'+hb_eol()
              // s += space(5) + '(исправляйте самостоятельно; в случае несогласия обращайтесь в отдел ТФОМС'+hb_eol()
              // s += space(5) + ' по ведению регистра застрахованных лиц, тел.94-71-59, 95-87-88, 94-67-41)'+hb_eol()
              StrFile( s, cFileProtokol, .t. )
              /*
              newMEST_INOG := 0
              if TwoWordFamImOt(arr_fio[1]) .or. TwoWordFamImOt(arr_fio[2]) .or. TwoWordFamImOt(arr_fio[3])
                newMEST_INOG := 9
              endif
              mfio := arr_fio[1]+' '+arr_fio[2]+' '+arr_fio[3]
              if kart->MEST_INOG == 9 .or. newMEST_INOG == 9
                select KFIO
                find (str(kart->kod, 7))
                if found()
                  if newMEST_INOG == 9
                    G_RLock(forever)
                    kfio->FAM := arr_fio[1]
                    kfio->IM  := arr_fio[2]
                    kfio->OT  := arr_fio[3]
                    dbUnLock()
                  else
                    DeleteRec(.t.)
                  endif
                else
                  if newMEST_INOG == 9
                    AddRec(7)
                    kfio->kod := kart->kod
                    kfio->FAM := arr_fio[1]
                    kfio->IM  := arr_fio[2]
                    kfio->OT  := arr_fio[3]
                    dbUnLock()
                  endif
                endif
              endif
              select KART
              G_RLock(forever)
              kart->fio := mfio
              kart->date_r := mdate_r
              kart->MEST_INOG := newMEST_INOG
              dbUnLock()
              select HUMAN
              G_RLock(forever)
              human->fio := mfio
              human->date_r := mdate_r
              dbUnLock()
              */
            Endif
            Select REFR
            Do While .t.
//              find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) )
              refr->( dbSeek( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) ) )
              If ! refr->( Found() )
                Exit
              Endif
              deleterec( .t. )
            Enddo
//            Select TMP3
//            find ( Str( tmp2->_N_ZAP, 8 ) )
            tmp3->( dbSeek(Str( tmp2->_N_ZAP, 8 ) ) )
            Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. ! tmp3->( Eof() )
              Select REFR
              addrec( 1 )
              refr->TIPD := 1
              refr->KODD := mkod_reestr
              refr->TIPZ := 1
              refr->KODZ := rhum->KOD_HUM
              refr->IDENTITY := tmp2->_IDENTITY
              refr->REFREASON := tmp3->_REFREASON
              refr->SREFREASON := tmp3->SREFREASON
              If Empty( refr->SREFREASON )
                If Empty( s := ret_t005( refr->REFREASON ) )
                  StrFile( Space( 5 ) + lstr( refr->REFREASON ) + ' неизвестная причина отказа' + ;
                    hb_eol(), cFileProtokol, .t. )
                Else
                  If tmp3->_REFREASON == 562
                    s += ' (спец-ть врача ' + ret_tmp_prvs( human_->PRVS ) + ')'
                  Elseif tmp3->_REFREASON == 589 .and. Int( Val( tmp2->_SMO ) ) > 0
                    fl_589 := .t.
                    s += ' (в л/у и в карточке пациента исправлены полис и СМО - войти в редактирование л/у и подтвердить запись)'
                  Endif
                  k := perenos( t_arr, s, 75 )
                  For i := 1 To k
                    StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
                  Next
                Endif
                If eq_any( refr->REFREASON, 57, 59 ) .and. kart->za_smo != -9
                  Select KART
                  g_rlock( forever )
                  kart->za_smo := -9  // установить признак 'Проблемы с полисом'
                  dbUnlock()
                Endif
                If refr->REFREASON == 513 .or. !eq_any( tmp2->_MO_PR, Space( 6 ), Replicate( '0', 6 ) )
                  Select KART2
                  Do While kart2->( LastRec() ) < human->kod_k
//                    Append Blank
                    kart2->( dbAppend() )
                  Enddo
//                  Goto ( human->kod_k )
                  kart2->( dbGoto( human->kod_k ) )
                  If Empty( kart2->MO_PR )
                    g_rlock( forever )
                    kart2->MO_PR := tmp2->_MO_PR
                    kart2->TIP_PR := 2
                    kart2->DATE_PR := ldate_sptk
                    If Empty( kart2->pc4 )
                      kart2->pc4 := date_8( kart2->pc4 )
                    Endif
                    dbUnlock()
                  Endif
                Endif
              Else
                s := 'код ошибки = ' + tmp3->SREFREASON + ' '
                s += '"' + getcategorycheckerrorbyid_q017( Left( tmp3->SREFREASON, 4 ) )[ 2 ] + '" '
                // s += alltrim(inieditspr(A__POPUPMENU, dir_exe()+'_mo_Q015', tmp3->SREFREASON))
                s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
                k := perenos( t_arr, s, 75 )
                For i := 1 To k
                  StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
                Next
              Endif
//              Select TMP3
//              Skip
              tmp3->( dbSkip() )
            Enddo
            If is_2 > 0
              StrFile( Space( 5 ) + '- разбейте двойной случай в режиме "ОМС/Двойные случаи/Разделить"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- отредактируйте каждый из случаев в режиме "ОМС/Редактирование"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- снова соберите случай в режиме "ОМС/Двойные случаи/Создать"' + ;
                hb_eol(), cFileProtokol, .t. )
            Endif
          Endif
        Endif
//        Unlock All
        dbUnlockAll()
        If fl_589
          Select HUMAN
          g_rlock( forever )
          human->POLIS := make_polis( tmp2->_spolis, tmp2->_npolis )
          //
//          human_->( g_rlock( forever ) )
          human_->( RLock() )
          human_->VPOLIS := tmp2->_VPOLIS
          human_->SPOLIS := tmp2->_SPOLIS
          human_->NPOLIS := tmp2->_NPOLIS
          human_->SMO    := tmp2->_SMO
          human_->OKATO  := tmp2->_SMO_OK
          //
          Select KART_
//          Goto ( human->kod_k )
          kart_->( dbGoto( human->kod_k ) )
          g_rlock( forever )
          kart_->VPOLIS    := tmp2->_VPOLIS
          kart_->SPOLIS    := tmp2->_SPOLIS
          kart_->NPOLIS    := tmp2->_NPOLIS
          kart_->SMO       := tmp2->_SMO
          kart_->KVARTAL_D := tmp2->_SMO_OK
          //
//          Unlock All
          dbUnlockAll()
        Endif
        Select TMP2
        If tmp2->( RecNo() ) % 1000 == 0
//          Commit
          tmp2->( dbCommit() )
        Endif
//        Skip
        tmp2->( dbSkip() )
      Enddo
    Endif
  Endif
//  Close databases
  dbCloseAll()
  Return count_in_schet
