//  delete_reestr.prg - удаление реестров в задаче ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//  14.02.26 аннулировать чтение реестра СП и ТК по реестру с кодом mkod_reestr
Function delete_reestr_sp_tk( mkod_reestr, mname_reestr )

  Local i, s, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
    arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
    cFileProtokol := cur_dir() + 'tmp.txt', is_other_reestr, bSaveHandler, ;
    arr_schet, rees_nschet := rees->nschet, mtip_in
  local result_TFOMS

  mywait()
  result_TFOMS := rees->RES_TFOMS
  Select MO_XML
  Index On FIELD->FNAME to ( cur_dir() + 'tmp_xml' ) For FIELD->reestr == mkod_reestr .and. FIELD->TIP_OUT == 0
  mo_xml->( dbGoTop() ) //  Go Top

  if ! ( rees->nyear >= 2026 .and. eq_any( result_TFOMS, 2, 3 ) )
    Do While ! mo_xml->( Eof() )
      If mo_xml->TIP_IN == _XML_FILE_FLK_26 //  _XML_FILE_SP
        AAdd( mm_func, mo_xml->kod )
//        s := 'Реестр СП и ТК ' + RTrim( mo_xml->FNAME ) + ' прочитан ' + date_8( mo_xml->DWORK )
        s := 'Файл ФЛК ' + RTrim( mo_xml->FNAME ) + ' прочитан ' + date_8( mo_xml->DWORK )
        If Empty( mo_xml->TWORK2 )
            AAdd( mm_flag, .t. )
            s += '-ПРОЦЕСС НЕ ЗАВЕРШЁН'
        Else
            AAdd( mm_flag, .f. )
            s += ' в ' + mo_xml->TWORK1
        Endif
        AAdd( mm_menu, s )
//      Elseif mo_xml->TIP_IN == _XML_FILE_FLK
//        If mo_xml->kol2 > 0
//            AAdd( mm_func, mo_xml->kod )
//            AAdd( mm_flag, .f. )
//            s := 'Протокол ФЛК ' + RTrim( mo_xml->FNAME ) + ' прочитан ' + date_8( mo_xml->DWORK ) + ' в ' + mo_xml->TWORK1
//          AAdd( mm_menu, s )
//        Endif
      Endif
      mo_xml->( dbSkip() )  //  Skip
    Enddo
  endif
  Select MO_XML
  Set Index To
  rest_box( buf )
  If Len( mm_menu ) == 0
    if ( rees->nyear >= 2026 .and. eq_any( result_TFOMS, 2, 3 ) ) .or. ( involved_password( 1, rees_nschet, 'подтверждения возврата (удаления) реестра' ) )
//      If involved_password( 1, rees_nschet, 'подтверждения возврата (удаления) реестра' )
        f1vozvrat_reestr( mkod_reestr )
//      Endif
    endif
    Return 1
  Endif
  If r <= 18
    r1 := r + 1
    r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1
    r1 := r2 - Len( mm_menu ) -1
  Endif
  If ( i := popup_prompt( r1, 10, 1, mm_menu,,, color5 ) ) > 0
    is_allow_delete := mm_flag[ i ]
    mreestr_sp_tk := mm_func[ i ]
    mywait()
    Select MO_XML
    Goto ( mreestr_sp_tk )
    cFile := AllTrim( mo_xml->FNAME )
    mtip_in := mo_xml->TIP_IN
    dbCloseAll()
    If mtip_in == _XML_FILE_SP // возврат реестра СП и ТК
      If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF(), cFile + szip() ) ) != Nil .and. mo_lock_task( X_OMS )
        cFile += sxml()
        // читаем файл в память
        oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
        If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
          func_error( 4, 'Ошибка в чтении файла ' + cFile )
        Else // читаем и записываем XML-файл во временные TMP-файлы
          reestr_sp_tk_tmpfile( oXmlDoc, aerr, cFile )
          If !Empty( aerr )
            ins_array( aerr, 1, '' )
            ins_array( aerr, 1, Center( 'Ошибки в чтении файла ' + cFile, 80 ) )
            AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
            viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
            Delete File ( cFileProtokol )
          Else
            // если точно попал в другой реестр
            is_other_reestr := is_delete_human := .f.
            r_use( dir_server() + 'human',, 'HUMAN' )
            r_use( dir_server() + 'human_',, 'HUMAN_' )
            r_use( dir_server() + 'mo_rhum',, 'RHUM' )
            Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
            Select TMP2
            Go Top
            Do While !Eof()
              Select RHUM
              find ( Str( tmp2->_N_ZAP, 6 ) )
              If Found()
                tmp2->kod_human := rhum->KOD_HUM
                Select HUMAN
                Goto ( rhum->KOD_HUM )
                If emptyany( human->kod, human->fio )
                  is_delete_human := .t.
                  Exit
                Endif
                Select HUMAN_
                Goto ( rhum->KOD_HUM )
                If human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                  is_other_reestr := .t.
                  Exit
                Endif
              Endif
              Select TMP2
              Skip
            Enddo
            If !is_other_reestr .and. !is_delete_human
              // если попал в другой реестр, вернулся с ошибкой, и отредактирован
              r_use( dir_server() + 'mo_rees',, 'REES' )
              Select RHUM
              Set Relation To FIELD->reestr into REES
              // сортируем пациентов по дате попадания в реестры
              Index On Str( FIELD->kod_hum, 7 ) + DToS( rees->DSCHET ) to ( cur_dir() + 'tmp_rhum' )
              Select TMP2
              Go Top
              Do While !Eof()
                r := r1 := 0
                Select RHUM
                find ( Str( tmp2->kod_human, 7 ) )
                Do While tmp2->kod_human == rhum->KOD_HUM
                  ++r // во сколько реестров попал
                  If rhum->reestr == mkod_reestr
                    r1 := r // какой по номеру текущий реестр
                  Endif
                  Skip
                Enddo
                If r1 > 0 .and. r > r1  // если текущий реестр не последний
                  is_other_reestr := .t.
                  Exit
                Endif
                Select TMP2
                Skip
              Enddo
            Endif
            If is_delete_human
              func_error( 10, 'Некоторые пациенты из данного реестра уже УДАЛЕНЫ. Операция запрещена!' )
            Elseif is_other_reestr
              func_error( 10, 'Пациенты из данного реестра уже ПОПАЛИ В ДРУГОЙ РЕЕСТР. Операция запрещена!' )
            Else
              If !is_allow_delete .and. involved_password( 1, rees_nschet, 'аннулирования чтения реестра СП и ТК' )
                is_allow_delete := .t.
              Endif
              If is_allow_delete
                dbCloseAll()
                arr_schet := {}
                r_use( dir_server() + 'schet_',, 'SCH' )
                Index On FIELD->nschet to ( cur_dir() + 'tmp_sch' ) For FIELD->XML_REESTR == mreestr_sp_tk
                dbEval( {|| AAdd( arr_schet, { AllTrim( nschet ), RecNo(), KOD_XML } ) } )
                sch->( dbCloseArea() )
                is_allow_delete := .f.
                g_use( dir_server() + 'mo_rees',, 'REES' )
                Goto ( mkod_reestr )
                Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
                Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
                arr := {}
                AAdd( arr, 'Реестр № ' + lstr( rees->nschet ) + ' от ' + full_date( rees->dschet ) + 'г.' )
                AAdd( arr, 'период "' + lstr( rees->nmonth ) + '/' + lstr( rees->nyear ) + ;
                  '", сумма ' + lput_kop( rees->summa, .t. ) + ;
                  ' руб., кол-во пациентов ' + lstr( rees->kol ) + ' чел.' )
                AAdd( arr, '' )
                AAdd( arr, 'Аннулируется реестр СП и ТК № ' + AllTrim( tmp1->_NSCHET ) + ' от ' + full_date( tmp1->_dschet ) + 'г.' )
                AAdd( arr, 'кол-во пациентов ' + lstr( tmp2->( LastRec() ) ) + ' чел. (файл ' + name_without_ext( cFile ) + ')' )
                If Len( arr_schet ) > 0
                  AAdd( arr, 'Количество удаляемых счетов - ' + lstr( Len( arr_schet ) ) + ' сч.' )
                Endif
                AAdd( arr, 'После подтверждения аннулирования все последствия чтения данного' )
                AAdd( arr, 'реестра СП и ТК, а также сам реестр СП и ТК, будут удалены.' )
                f_message( arr,, cColorSt2Msg, cColorSt1Msg )
                s := 'Подтвердите аннулирование реестра СП и ТК'
                stat_msg( s )
                mybell( 1 )
                If f_esc_enter( 'аннулирования', .t. )
                  stat_msg( s + ' ещё раз.' )
                  mybell( 3 )
                  If f_esc_enter( 'аннулирования', .t. )
                    mywait()
                    is_allow_delete := .t.
                  Endif
                Endif
              Endif
              // переиндексируем некоторые файлы
              If is_allow_delete
                Private fl_open := .t.
                bSaveHandler := ErrorBlock( {| x| Break( x ) } )
                Begin Sequence
                  index_base( 'schet' ) // для составления счетов
                  index_base( 'human' ) // для разноски счетов
                  index_base( 'mo_refr' )  // для записи причин отказов
                  index_base( 'human_3' )  // для двойных случаев
                RECOVER USING error
                  is_allow_delete := func_error( 10, 'Возникла непредвиденная ошибка при переиндексировании!' )
                End
                ErrorBlock( bSaveHandler )
              Endif
              // аннулируем последствия чтения реестра СП и ТК
              If is_allow_delete
                dbCloseAll()
                use_base( 'schet' )
                Set Relation To
                g_use( dir_server() + 'schetd',, 'SD' )
                Index On Str( FIELD->kod, 6 ) to ( cur_dir() + 'tmp_sd' )
                g_use( dir_server() + 'mo_xml',, 'MO_XML' )
                g_use( dir_server() + 'mo_refr', dir_server() + 'mo_refr', 'REFR' )
                g_use( dir_server() + 'mo_rhum',, 'RHUM' )
                Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
                g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
                use_base( 'human' )
                Set Order To 0
                Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
                Go Top
                Do While !Eof()
                  Select RHUM
                  find ( Str( tmp2->_N_ZAP, 6 ) )
                  g_rlock( forever )
                  rhum->OPLATA := 0
                  Select HUMAN
                  Goto ( tmp2->kod_human )
                  If human->ishod == 88  // сначала проверим, не двойной ли это случай (по-старому)
                    Select HUMAN_3
                    Set Order To 1
                    find ( Str( tmp2->kod_human, 7 ) )
                    If Found()
                      Select HUMAN
                      Goto ( human_3->kod2 )  // встали на 2-ой лист учёта
                      human->( g_rlock( forever ) )
                      human->schet := 0
                      human->tip_h := B_STANDART
                      human_->( g_rlock( forever ) )
                      If human_->schet_zap > 0
                        If human_->SCHET_NUM > 0
                          human_->SCHET_NUM := human_->SCHET_NUM - 1
                        Endif
                        human_->schet_zap := 0
                      Endif
                      human_->OPLATA := 0
                      human_->REESTR := mkod_reestr
                      Unlock
                      // очистка заголовка двойного случая
                      human_3->( g_rlock( forever ) )
                      human_3->schet := 0
                      If human_3->schet_zap > 0
                        If human_3->SCHET_NUM > 0
                          human_3->SCHET_NUM := human_3->SCHET_NUM -1
                        Endif
                        human_3->schet_zap := 0
                      Endif
                      human_3->OPLATA := 0
                      human_3->REESTR := mkod_reestr
                    Endif
                    // возвращаемся к 1-му листу учёта
                    Select HUMAN
                    Goto ( tmp2->kod_human )
                    human->( g_rlock( forever ) )
                    human->schet := 0
                    human->tip_h := B_STANDART
                    human_->( g_rlock( forever ) )
                    If human_->schet_zap > 0
                      If human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM - 1
                      Endif
                      human_->schet_zap := 0
                    Endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    Unlock
                  Elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
                    // сначала обработаем 2-ой случай
                    human->( g_rlock( forever ) )
                    human->schet := 0
                    human->tip_h := B_STANDART
                    human_->( g_rlock( forever ) )
                    If human_->schet_zap > 0
                      If human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM - 1
                      Endif
                      human_->schet_zap := 0
                    Endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    Unlock
                    // поищем 1-ый случай
                    Select HUMAN_3
                    Set Order To 2
                    find ( Str( human->kod, 7 ) )
                    If Found() // нашли двойной случай
                      Select HUMAN
                      Goto ( human_3->kod ) // встать на 1-ый лист учёта
                      human->( g_rlock( forever ) )
                      human->schet := 0
                      human->tip_h := B_STANDART
                      human_->( g_rlock( forever ) )
                      If human_->schet_zap > 0
                        If human_->SCHET_NUM > 0
                          human_->SCHET_NUM := human_->SCHET_NUM - 1
                        Endif
                        human_->schet_zap := 0
                      Endif
                      human_->OPLATA := 0
                      human_->REESTR := mkod_reestr
                      Unlock
                      // очистка заголовка двойного случая
                      human_3->( g_rlock( forever ) )
                      human_3->schet := 0
                      If human_3->schet_zap > 0
                        If human_3->SCHET_NUM > 0
                          human_3->SCHET_NUM := human_3->SCHET_NUM -1
                        Endif
                        human_3->schet_zap := 0
                      Endif
                      human_3->OPLATA := 0
                      human_3->REESTR := mkod_reestr
                    Endif
                  Else
                    // обработка одинарного случая
                    Select HUMAN
                    Goto ( tmp2->kod_human )
                    human->( g_rlock( forever ) )
                    human->schet := 0
                    human->tip_h := B_STANDART
                    human_->( g_rlock( forever ) )
                    If human_->schet_zap > 0
                      If human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM - 1
                      Endif
                      human_->schet_zap := 0
                    Endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    Unlock
                  Endif
                  Select REFR
                  Do While .t.
                    find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( tmp2->kod_human, 8 ) )
                    If !Found()
                      exit
                    Endif
                    deleterec( .t. )
                  Enddo
                  Select TMP2
                  Skip
                Enddo
                For i := 1 To Len( arr_schet )
                  //
                  Select SD
                  find ( Str( arr_schet[ i, 2 ], 6 ) )
                  If Found()
                    deleterec( .t. )
                  Endif
                  //
                  Select SCHET_
                  Goto ( arr_schet[ i, 2 ] )
                  deleterec( .t., .f. )  // без пометки на удаление
                  //
                  Select SCHET
                  Goto ( arr_schet[ i, 2 ] )
                  deleterec( .t. )
                  //
                  If arr_schet[ i, 3 ] > 0
                    Select MO_XML
                    Goto ( arr_schet[ i, 3 ] )
                    If !Empty( mo_xml->FNAME )
                      s := dir_server() + dir_XML_MO() + hb_ps() + AllTrim( mo_xml->FNAME ) + szip()
                      If hb_FileExists( s )
                        Delete File ( s )
                      Endif
                    Endif
                    deleterec( .t. )
                  Endif
                Next
                Select MO_XML
                Goto ( mreestr_sp_tk )
                deleterec()
                dbCloseAll()
                stat_msg( 'Реестр СП и ТК успешно аннулирован. Можно прочитать ещё раз.' )
                mybell( 5 )
              Endif
            Endif
          Endif
        Endif
        mo_unlock_task( X_OMS )
      Endif
    Elseif mTIP_IN == _XML_FILE_FLK // возврат протокола ФЛК
      If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF(), cFile + szip() ) ) != Nil .and. mo_lock_task( X_OMS )
        cFile += sxml()
        // читаем файл в память
        oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
        If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
          func_error( 4, 'Ошибка в чтении файла ' + cFile )
        Else // читаем и записываем XML-файл во временные TMP-файлы
          is_err_FLK := protokol_flk_tmpfile( arr_f, aerr )
          dbCloseAll()
          If Empty( aerr ) .and. !extract_reestr( mkod_reestr, mname_reestr )
            AAdd( aerr, 'Не найден ZIP-архив с РЕЕСТРом ' + mname_reestr )
            AAdd( aerr, 'Без данного архива дальнейшая работа НЕВОЗМОЖНА!' )
          Endif
          If !Empty( aerr )
            ins_array( aerr, 1, '' )
            ins_array( aerr, 1, Center( 'Ошибки в чтении файла ' + cFile, 80 ) )
            AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
            viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
            Delete File ( cFileProtokol )
          Else
            // если точно попал в другой реестр
            is_other_reestr := is_delete_human := .f.
            Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
            Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
            Index On Str( FIELD->tip, 1 ) + Str( FIELD->oshib, 3 ) + FIELD->soshib to ( cur_dir() + 'tmp2' )
            Use ( cur_dir() + 'tmp_r_t1' ) New Alias T1
            Index On Upper( FIELD->ID_PAC ) to ( cur_dir() + 'tmp_r_t1' )
            Use ( cur_dir() + 'tmp_r_t2' ) New Alias T2
            Use ( cur_dir() + 'tmp_r_t3' ) New Alias T3
            Use ( cur_dir() + 'tmp_r_t4' ) New Alias T4
            // заполнить поле 'N_ZAP' в файле 'tmp2'
            fill_tmp2_file_flk()
            r_use( dir_server() + 'human',, 'HUMAN' )
            r_use( dir_server() + 'human_',, 'HUMAN_' )
            r_use( dir_server() + 'mo_rhum',, 'RHUM' )
            Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
            Select TMP2
            Go Top
            Do While !Eof()
              If !Empty( tmp2->BAS_EL ) .and. !Empty( tmp2->ID_BAS ) .and. !Empty( tmp2->N_ZAP )
                Select RHUM
                find ( Str( tmp2->N_ZAP, 6 ) )
                If Found()
                  tmp2->kod_human := rhum->KOD_HUM
                  Select HUMAN
                  Goto ( rhum->KOD_HUM )
                  If emptyany( human->kod, human->fio )
                    is_delete_human := .t.
                    Exit
                  Endif
                  Select HUMAN_
                  Goto ( rhum->KOD_HUM )
                  If human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                    is_other_reestr := .t.
                    Exit
                  Endif
                Endif
              Endif
              Select TMP2
              Skip
            Enddo
            If !is_other_reestr .and. !is_delete_human
              // если попал в другой реестр, вернулся с ошибкой, и отредактирован
              r_use( dir_server() + 'mo_rees',, 'REES' )
              Select RHUM
              Set Relation To FIELD->reestr into REES
              // сортируем пациентов по дате попадания в реестры
              Index On Str( FIELD->kod_hum, 7 ) + DToS( rees->DSCHET ) to ( cur_dir() + 'tmp_rhum' )
              Select TMP2
              Go Top
              Do While !Eof()
                r := r1 := 0
                Select RHUM
                find ( Str( tmp2->kod_human, 7 ) )
                Do While tmp2->kod_human == rhum->KOD_HUM
                  ++r // во сколько реестров попал
                  If rhum->reestr == mkod_reestr
                    r1 := r // какой по номеру текущий реестр
                  Endif
                  Skip
                Enddo
                If r1 > 0 .and. r > r1  // если текущий реестр не последний
                  is_other_reestr := .t.
                  Exit
                Endif
                Select TMP2
                Skip
              Enddo
            Endif
            If is_delete_human
              func_error( 10, 'Некоторые пациенты из данного реестра уже УДАЛЕНЫ. Операция запрещена!' )
            Elseif is_other_reestr
              func_error( 10, 'Пациенты из данного реестра уже ПОПАЛИ В ДРУГОЙ РЕЕСТР. Операция запрещена!' )
            Else
              If !is_allow_delete .and. involved_password( 1, rees_nschet, 'аннулирования чтения протокола ФЛК' )
                is_allow_delete := .t.
              Endif
              If is_allow_delete
                dbCloseAll()
                is_allow_delete := .f.
                r_use( dir_server() + 'mo_rees',, 'REES' )
                Goto ( mkod_reestr )
                Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
                Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
                arr := {}
                AAdd( arr, 'Реестр № ' + lstr( rees->nschet ) + ' от ' + full_date( rees->dschet ) + 'г.' )
                AAdd( arr, 'период "' + lstr( rees->nmonth ) + '/' + lstr( rees->nyear ) + ;
                  '", сумма ' + lput_kop( rees->summa, .t. ) + ;
                  ' руб., кол-во пациентов ' + lstr( rees->kol ) + ' чел.' )
                AAdd( arr, '' )
                AAdd( arr, 'Аннулируется чтение протокола ФЛК № ' + AllTrim( tmp1->FNAME ) )
                AAdd( arr, 'кол-во пациентов с ошибкой ' + lstr( tmp2->( LastRec() ) ) + ' чел.' )
                AAdd( arr, 'После подтверждения аннулирования все последствия чтения' )
                AAdd( arr, 'данного протокола ФЛК, а также сам протокол, будут удалены.' )
                f_message( arr,, cColorSt2Msg, cColorSt1Msg )
                s := 'Подтвердите аннулирование чтения протокола ФЛК'
                stat_msg( s )
                mybell( 1 )
                If f_esc_enter( 'аннулирования', .t. )
                  stat_msg( s + ' ещё раз.' )
                  mybell( 3 )
                  If f_esc_enter( 'аннулирования', .t. )
                    mywait()
                    is_allow_delete := .t.
                  Endif
                Endif
              Endif
              // аннулируем последствия чтения реестра ФЛК
              If is_allow_delete
                dbCloseAll()
                g_use( dir_server() + 'mo_xml',, 'MO_XML' )
                g_use( dir_server() + 'mo_rhum',, 'RHUM' )
                Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
                g_use( dir_server() + 'human_',, 'HUMAN_' )
                Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
                Set Relation To FIELD->kod_human into HUMAN_
                Go Top
                Do While !Eof()
                  Select RHUM
                  find ( Str( tmp2->N_ZAP, 6 ) )
                  g_rlock( forever )
                  rhum->OPLATA := 0
                  Select HUMAN_
                  g_rlock( forever )
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  Unlock
                  Select TMP2
                  Skip
                Enddo
                Select MO_XML
                Goto ( mreestr_sp_tk )
                deleterec()
                dbCloseAll()
                stat_msg( 'Протокол ФЛК успешно аннулирован.' )
                mybell( 5 )
              Endif
            Endif
          Endif
        Endif
        mo_unlock_task( X_OMS )
      Endif
    Endif
  Endif
  rest_box( buf )

  Return 0

//  вернуть ещё не записанный на дискету реестр
Function vozvrat_reestr()

  Local k, buf := SaveScreen(), tmp_help := chm_help_code, mkod_reestr

  If ! currentuser():isadmin()
    Return func_error( 4, err_admin() )
  Endif
  If !g_slock( Sreestr_sem )
    Return func_error( 4, Sreestr_err )
  Endif
  Private goal_dir := dir_server() + dir_XML_MO() + hb_ps()
  g_use( dir_server() + 'mo_rees',, 'REES' )
  Index On DToS( FIELD->dschet ) + Str( FIELD->nschet, 6 ) to ( cur_dir() + 'tmp_rees' ) DESCENDING For Empty( FIELD->date_out )
  Go Top
  If Eof()
    func_error( 4, 'Не обнаружено реестров, не отправленных в ТФОМС' )
  Else
    chm_help_code := 114
    Private reg := 2
    If alpha_browse( T_ROW, 0, 23, 79, 'f1_view_list_reestr', color0,,,, .t.,,,,, ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R',, 60 } )
      mkod_reestr := rees->KOD
      mywait()
      g_use( dir_server() + 'mo_xml',, 'MO_XML' )
      Index On FIELD->FNAME to ( cur_dir() + 'tmp_xml' ) For FIELD->reestr == mkod_reestr .and. FIELD->TIP_OUT == 0
      k := kol_err := 0
      Go Top
      Do While !Eof()
        If mo_xml->TIP_IN == _XML_FILE_SP
          ++k
        Elseif mo_xml->TIP_IN == _XML_FILE_FLK
          kol_err += mo_xml->kol2
        Endif
        Skip
      Enddo
      If k > 0
        func_error( 4, 'По данному реестру уже были прочитаны реестры СП и ТК. Возврат ЗАПРЕЩЁН!' )
      Elseif kol_err > 0
        func_error( 4, 'По данному реестру был прочитан протокол ФЛК с ошибками. Возврат ЗАПРЕЩЁН!' )
      Else
        f1vozvrat_reestr( mkod_reestr )
      Endif
    Endif
  Endif
  dbCloseAll()
  g_sunlock( Sreestr_sem )
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil

//  14.02.26
Function f1vozvrat_reestr( mkod_reestr )

  Local buf := SaveScreen()

  dbCloseAll()
  g_use( dir_server() + 'mo_rees',, 'REES' )
  Goto ( mkod_reestr )
  stat_msg( '' )
  arr := {}
  AAdd( arr, 'Удаляется реестр № ' + lstr( rees->nschet ) + ' от ' + full_date( rees->dschet ) + 'г.' )
  AAdd( arr, 'за период "' + iif( Between( rees->nmonth, 1, 12 ), mm_month[ rees->nmonth ], lstr( rees->nmonth ) + ' месяц' ) + ;
    Str( rees->nyear, 5 ) + ' года".' )
  AAdd( arr, 'Сумма реестра ' + lput_kop( rees->summa, .t. ) + ;
    ' руб., количество пациентов ' + lstr( rees->kol ) + ' чел.' )
  AAdd( arr, 'Наименование файла ' + AllTrim( rees->NAME_XML ) )
  AAdd( arr, '' )
  AAdd( arr, 'После подтверждения удаления пациенты будут вычеркнуты' )
  AAdd( arr, 'из данного реестра, а реестр будет удален.' )
  f_message( arr,, color1, color8 )
  If f_esc_enter( 'удаления реестра № ' + lstr( rees->nschet ), .t. )
    stat_msg( 'Подтвердите удаление ещё раз.' )
    mybell( 2 )
    If f_esc_enter( 'удаления реестра № ' + lstr( rees->nschet ), .t. )
      mywait( 'Ждите. Производится удаление реестра.' )
      g_use( dir_server() + 'human_u_',, 'HU_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      Set Relation To RecNo() into HU_
      g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
      g_use( dir_server() + 'human',, 'HUMAN' )
      g_use( dir_server() + 'human_',, 'HUMAN_' )
      g_use( dir_server() + 'mo_rhum',, 'RHUM' )
      Index On Str( FIELD->reestr, 6 ) to ( cur_dir() + 'tmp_rhum' )
      Do While .t.
        Select RHUM
        find ( Str( mkod_reestr, 6 ) )
        If !Found()
          exit
        Endif
        //
        Select HUMAN_
        Goto ( rhum->KOD_HUM )
        If human_->REESTR == mkod_reestr // на всякий случай
          Select HUMAN
          Goto ( rhum->KOD_HUM )
          If human->ishod == 88 // сначала проверим, не двойной ли это случай (по-старому)
            Select HUMAN_3
            Set Order To 1
            find ( Str( human->kod, 7 ) )
            If Found()
              Select HUMAN_
              Goto ( human_3->kod2 ) // встать на 2-ой лист учёта
              Select HU
              find ( Str( human_3->kod2, 7 ) )
              Do While human_3->kod2 == hu->kod .and. !Eof()
                hu_->( g_rlock( forever ) )
                hu_->REES_ZAP := 0
                hu_->( dbUnlock() )
                Select HU
                Skip
              Enddo
              human_->( g_rlock( forever ) )
              If human_->REES_NUM > 0
                human_->REES_NUM := human_->REES_NUM - 1
              Endif
              human_->REES_ZAP := 0
              human_->REESTR := 0
              human_->( dbUnlock() )
              // обработка заголовка двойного случая
              human_3->( g_rlock( forever ) )
              If human_3->REES_NUM > 0
                human_3->REES_NUM := human_3->REES_NUM - 1
              Endif
              human_3->REES_ZAP := 0
              human_3->REESTR := 0
              human_3->( dbUnlock() )
            Endif
            // возвращаемся к 1-му листу учёта
            Select HUMAN_
            Goto ( rhum->KOD_HUM )
            Select HU
            find ( Str( rhum->KOD_HUM, 7 ) )
            Do While rhum->KOD_HUM == hu->kod .and. !Eof()
              hu_->( g_rlock( forever ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( forever ) )
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
          Elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
            // сначала обработаем 2-ой случай
            Select HU
            find ( Str( rhum->KOD_HUM, 7 ) )
            Do While rhum->KOD_HUM == hu->kod .and. !Eof()
              hu_->( g_rlock( forever ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( forever ) )
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
            // поищем 1-ый случай
            Select HUMAN_3
            Set Order To 2
            find ( Str( human->kod, 7 ) )
            If Found()
              Select HUMAN_
              Goto ( human_3->kod ) // встать на 1-ый лист учёта
              Select HU
              find ( Str( human_3->kod2, 7 ) )
              Do While human_3->kod2 == hu->kod .and. !Eof()
                hu_->( g_rlock( forever ) )
                hu_->REES_ZAP := 0
                hu_->( dbUnlock() )
                Select HU
                Skip
              Enddo
              human_->( g_rlock( forever ) )
              If human_->REES_NUM > 0
                human_->REES_NUM := human_->REES_NUM - 1
              Endif
              human_->REES_ZAP := 0
              human_->REESTR := 0
              human_->( dbUnlock() )
              // обработка заголовка двойного случая
              human_3->( g_rlock( forever ) )
              If human_3->REES_NUM > 0
                human_3->REES_NUM := human_3->REES_NUM - 1
              Endif
              human_3->REES_ZAP := 0
              human_3->REESTR := 0
              human_3->( dbUnlock() )
            Endif
          Else
            // обработка одинарного случая
            Select HUMAN_
            Goto ( rhum->KOD_HUM )
            Select HU
            find ( Str( rhum->KOD_HUM, 7 ) )
            Do While rhum->KOD_HUM == hu->kod .and. !Eof()
              hu_->( g_rlock( forever ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( forever ) )
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
          Endif
        Endif
        //
        Select RHUM
        deleterec( .t. )
      Enddo
      zip_file := AllTrim( rees->name_xml ) + szip()
      If hb_FileExists( goal_dir + zip_file )
        Delete File ( goal_dir + zip_file )
      Endif
      g_use( dir_server() + 'mo_xml',, 'MO_XML' )
      Goto ( rees->KOD_XML )
      If !Eof() .and. !Deleted()
        deleterec( .t. )
      Endif
      Select REES
      deleterec( .t. )
      stat_msg( 'Реестр удалён!' )
      mybell( 2, OK )
    Endif
  Endif
  dbCloseAll()
  RestScreen( buf )

  Return Nil

