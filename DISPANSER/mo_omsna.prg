// mo_omsna.prg - диспансерное наблюдение
#include 'inkey.ch'
#include 'fastreph.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'hbxlsxwriter.ch'

Static lcount_uch  := 1

//
Function test_mkb_10()

  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
  Go Top
  Do While !Eof()
    If mkb_10->ks == 0 .and. between_date( mkb_10->dbegin, mkb_10->dend, sys_date )
      If f_is_diag_dn( mkb_10->shifr,,, .f. )
      Endif
    Endif
    Skip
  Enddo
  Close databases
  Return Nil

// 05.12.25 Диспансерное наблюдение
Function disp_nabludenie( k )

  Static S_sem := 'disp_nabludenie'
  Static si1 := 2, si2 := 1, si3 := 2, si4 := 1, si5 := 1, si6 := 1
  Local mas_pmt, mas_msg, mas_fun, j, buf, fl_umer := .f., zaplatka_D01 := .f., ;
    zaplatka_D_OPL := .f., zaplatka_D_131 := .f., kol_err := 0

  Default k To 1

  Do Case
  Case k == 1
    // временное начало
    //r_use( dir_server() + 'mo_d01d' )
    //If FieldNum( 'OPLATA' ) == 0 //
    //  zaplatka_D_OPL := .t.
    //Endif
    //Close databases
    //
    r_use( dir_server() + 'mo_dnab' )
    If FieldNum( 'PEREHOD2' ) == 0 // Преход 2026
      zaplatka_D_OPL := .t.
    Endif
    //
    //r_use( dir_server() + 'mo_dnab' )
    //If FieldNum( 'PEREHOD1' ) == 0 // Правка ошибки 131
    //  zaplatka_D_131 := .t.
    //Endif
    //
    Close databases

    If zaplatka_D_OPL
      Close databases
      If !g_slock( S_sem )
        Return func_error( 4, 'Доступ в данный режим пока запрещён' )
      Endif
      buf := save_maxrow()
      waitstatus( 'Ждите! Составляется список по диспансерному наблюдению на 2025 год' )
      reconstruct_d01() // инициализация всех файлов инф.сопровождения по диспансерному наблюдению
      Close databases
      Use ( dir_server() + 'mo_dnab' ) New Alias DN
      Index On Str( FIELD->KOD_K, 7 ) + FIELD->KOD_DIAG to ( dir_server() + 'mo_dnab' )
      Select DN
      Go Top
      Do While !Eof()
        updatestatus()
        If !Empty( dn->LU_DATA )
          If dn->FREQUENCY == 0
            dn->FREQUENCY := 1
          Endif
          k := Year( dn->NEXT_DATA )
          If !Between( k, 2025, 2027 ) // ЮЮ если некорректная дата след.визита
            dn->NEXT_DATA := AddMonth( dn->LU_DATA, 12 )
          Endif
          Do While dn->NEXT_DATA < 0d20260101 // ЮЮ
            dn->NEXT_DATA := AddMonth( dn->NEXT_DATA, dn->FREQUENCY )
          Enddo
          If dn->NEXT_DATA < 0d20260101
            dn->FREQUENCY := 0
          Endif
        Endif
        Skip
      Enddo
      Close databases
      //
      waitstatus( 'Из списка по диспансерному наблюдению на 2026 год удаляются умершие' )
      r_use( dir_server() + 'kartote2',, '_KART2' )
      r_use( dir_server() + 'kartotek',, '_KART' )
      Use ( dir_server() + 'mo_dnab' ) New Alias DN
      Go Top
      Do While !Eof()
        updatestatus()
        If dn->kod_k > 0
          Select _KART
          Goto ( dn->kod_k )
          Select _KART2
          Goto ( dn->kod_k )
          fl := .f.
          If Left( _kart2->PC2, 1 ) == '1'  // Умер по результатам сверки
            fl := .t.
          Endif
          If fl
            Select DN
            dn->kod_k := 0
          Endif
        Endif
        Select DN
        Skip
      Enddo
      //
      //
      Commit
      Index On Str( FIELD->KOD_K, 7 ) + FIELD->KOD_DIAG to ( dir_server() + 'mo_dnab' )
      Close databases
      //
      rest_box( buf )
      g_sunlock( S_sem )
    Endif
    //
    /*If zaplatka_D_131 
      Close databases
      If !g_slock( S_sem )
        Return func_error( 4, 'Доступ в данный режим пока запрещён' )
      Endif
      buf := save_maxrow()
      waitstatus( 'Ждите! Исправление ошибки 131 ' )
      reconstruct_d01() // инициализация всех файлов инф.сопровождения по диспансерному наблюдению
      r_use( dir_server() + 'mo_dnab',, 'DN' )
      r_use( dir_server() + 'mo_d01',, 'D01' )
      g_use( dir_server() + 'mo_d01k',, 'RHUM',.T.,.T. )
      g_use( dir_server() + 'mo_d01d',, 'DD',.T.,.T. )
      set relation to FIELD->KOD_D into RHUM
      Index On Str( rhum->REESTR, 6 ) + Str( rhum->KOD_K, 7 ) + padr(alltrim(FIELD->KOD_DIAG),3) to ( cur_dir() + 'tmp_dd' ) 
      //{ 'REESTR',   'N', 6, 0 }, ; // код реестра по файлу 'mo_d01'
      //{ 'KOD_K',    'N', 7, 0 }, ; // код по картотеке
      // { 'KOD_DIAG', 'C', 5, 0 }, ;  // диагноз заболевания, по поводу которого пациент подлежит диспансерному наблюдению
      g_use( dir_server() + 'mo_d01e',, 'RHUM_E',.T.,.T. )
      //
      select D01 
      go Top 
      do while !eof()
        if d01-> NYEAR == 2024
          select dd
          t_hum := 0 
          t_diag := ''
          go Top
          do while !eof()
           // записи (люди) в пакете  
            if rhum->reestr == d01->kod 
              if RHUM->kod_k == t_hum .and. padr(alltrim(dd->kod_diag),3) == t_diag
                //текущий и предыдущий диагноз  - в ошибки  
                t_hum := RHUM->kod_k 
                t_diag := padr(alltrim(dd->kod_diag),3) 
                if rhum->oplata == 1
                  dd->oplata := 2
                  rhum->oplata := 2
                  ++ kol_err
                endif  
                // доб RHUM_E
                skip -1
                if rhum->oplata == 1
                  dd->oplata := 2
                  rhum->oplata := 2
                  ++ kol_err
                endif  
                
                // доб RHUM_E
                skip
              else
                t_hum := RHUM->kod_k 
                t_diag := padr(alltrim(dd->kod_diag),3) 
              endif  
            endif 
            select dd
            skip 
          enddo
        endif  
        select D01
        skip
      enddo 
      Commit
      Close databases
      //
      rest_box( buf )
      g_sunlock( S_sem )
      stat_msg(' Исправлено '+lstr(kol_err)+ '')
      mybell(2)
    Endif
    */
    Close databases
    Private mdate_r, M1VZROS_REB

    //
    mas_pmt := { '~Работа с файлами обмена D01', ;
      '~Информация по дисп.наблюдению' }
    mas_msg := { 'Создание файла обмена D01... с ещё не отправленными пациентами (диагнозами)', ;
      'Просмотр информации по результатам диспансерного наблюдения' }
    mas_fun := { 'disp_nabludenie(11)', ;
      'disp_nabludenie(12)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    mas_pmt := { 'Первичный ~ввод', ;
      '~Информация', ;
      '~Обмен с ТФОМС' }
    mas_msg := { 'Первичный ввод сведений о состоящих на диспансерном учёте в Вашей МО', ;
      'Информация по первичному вводу сведений о состоящих на диспансерном учёте', ;
      'Обмен с ТФОМС информацией по диспансерному наблюдению' }
    mas_fun := { 'disp_nabludenie(21)', ;
      'disp_nabludenie(22)', ;
      'disp_nabludenie(23)' }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 21
    mas_pmt := { 'Ввод с поиском по лечащему ~врачу', ;
      'Ввод с поиском по ~пациенту', ;
      'Подгрузка пациент~ов 2025'  }
    mas_msg := { 'Первичный ввод сведений о состоящих на дисп.учёте с поиском по лечащему врачу', ;
      'Первичный ввод сведений о состоящих на дисп.учёте с поиском по пациенту', ;
      'Подгрузка новых пациентов вставших на ДН в 2025 году '  }
    mas_fun := { 'disp_nabludenie(51)', ;
      'disp_nabludenie(52)', ;
      'disp_nabludenie(53)'   }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
  Case k == 22
    mas_pmt := { 'Информация по ~первичному вводу', ;
      'Список обязательных ~диагнозов' }
    mas_msg := { 'Информация по первичному вводу сведений о состоящих на диспансерном учёте', ;
      'Список диагнозов, обязательных для диспансерного наблюдения' }
    mas_fun := { 'disp_nabludenie(41)', ;
      'disp_nabludenie(42)' }
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 23
    mas_pmt := { '~Создание файла обмена D01', ;
      '~Просмотр файлов обмена D01' }
    mas_msg := { 'Создание файла обмена D01... с ещё не отправленными пациентами (диагнозами)', ;
      'Просмотр файлов обмена D01... и результатов работы с ними' }
    mas_fun := { 'disp_nabludenie(31)', ;
      'disp_nabludenie(32)' }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 41
    inf_disp_nabl()
  Case k == 42
    spr_disp_nabl()
  Case k == 31
    //ne_real()
    f_create_d01()
  Case k == 32
    f_view_d01()
  Case k == 51
    vvod_disp_nabl()
  Case k == 52
    vvodp_disp_nabl()
  Case k == 53
    vvodn_disp_nabl()
  Case k == 12
    mas_pmt := { '~Отсутствуют л/у с диспансерным наблюдением', ;
      '~Существуют л/у с диспансерным наблюдением', ;
      '~Ежемесячный прирост ДН за 2025год' }
    mas_msg := { 'Список пациентов, у которых осутствуют л/у с диспансерным наблюдением', ;
      'Список пациентов, у которых существуют л/у с диспансерным наблюдением', ;
      'Пациенты, вставшие на ДН в 2025году'  }
    mas_fun := { 'disp_nabludenie(61)', ;
      'disp_nabludenie(62)', ;
      'disp_nabludenie(63)'  }
    popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, mas_msg, mas_fun )
  Case k == 61
    f_inf_disp_nabl( 1 )
  Case k == 62
    f_inf_disp_nabl( 2 )
  Case k == 63
    //f_inf_prirost_disp_nabl()
    ne_real()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Endif
  Endif
  Return Nil

// 17.01.14 переопределение критерия 'взрослый/ребёнок' по дате рождения и '_date'
Function fvdn_date_r( _data, mdate_r )

  Local k,  cy, ldate_r := mdate_r

  Default _data To sys_date

  cy := count_years( ldate_r, _data )

  If cy < 14
    k := 1  // ребенок
  Elseif cy < 18
    k := 2  // подросток
  else
    k := 0  // взрослый
  Endif
  Return k


// 05.12.25
Function f_inf_dop_disp_nabl()

  Local adiagnoz, sh := 80, HH := 60, buf := save_maxrow(), name_file := cur_dir() + 'disp_nabl.txt', ;
    buf1, ii1 := 0, s, i, t_arr[ 2 ], ar, ausl, fl

  Private mm_dopo_na := { { '2.78', 1 }, { '2.79', 2 }, { '2.88 ДН', 3 }, { '2.88 не ДН', 4 } }
  Private gl_arr := { ;  // для битовых полей
    { 'dopo_na', 'N', 10, 0,,,, {| x| inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
    }
  Private mdopo_na, m1dopo_na := 0, muchast, m1uchast := 0, arr_uchast := {}, ;
    m1period := 0, mperiod := Space( 10 ), parr_m
  m1dopo_na := SetBit( m1dopo_na, 3 )
  mdopo_na  := inieditspr( A__MENUBIT, mm_dopo_na, m1dopo_na )
  muchast := init_uchast( arr_uchast )
  buf1 := box_shadow( 15, 2, 19, 77, color1 )
  SetColor( cDataCGet )
  @ 16, 10 Say 'По каким услугам проводить доп.поиск' Get mdopo_na ;
    reader {| x| menu_reader( x, mm_dopo_na, A__MENUBIT,,, .f. ) }
  @ 17, 10 Say 'Участок (участки)' Get muchast ;
    reader {| x| menu_reader( x, { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION,,, .f. ) }
  @ 18, 10 Say 'За какой период времени вести поиск' Get mperiod ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( parr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION,,, .f. ) }
  myread()
  rest_box( buf1 )
  If LastKey() == K_ESC .or. Empty( m1dopo_na )
    Return Nil
  Endif
  If !( ValType( parr_m ) == 'A' )
    parr_m := Array( 8 )
    parr_m[ 5 ] := 0d20230101    // ЮЮ
    parr_m[ 6 ] := 0d20251231    // ЮЮ
  Endif
  stat_msg( 'Поиск информации...' )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  arr_title := { ;
    '──┬─────────────────────────────────────────────┬──────────┬────────┬─────┬──────────────────', ;
    'NN│  ФИО пациента                               │   Дата   │Дата по-│ Таб.│ Диагнозы         ', ;
    'уч│    адрес пациента                           │ рождения │сещения │номер│ для ДН           ', ;
    '──┴─────────────────────────────────────────────┴──────────┴────────┴─────┴──────────────────' }
  sh := Len( arr_title[ 1 ] )
  s := 'Пациенты, не попавшие в первичный список'
  add_string( '' )
  add_string( Center( s, sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  use_base( 'lusl' )
  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use( dir_server() + 'mo_pers',, 'PERS' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To FIELD->u_kod into USL
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  Set Relation To FIELD->vrach into PERS
  r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Index On Str( FIELD->kod_k, 7 ) + Descend( DToS( FIELD->k_data ) ) to ( cur_dir() + 'tmp_humankk' ) ;
    For human_->USL_OK == 3 .and. Between( human->k_data, parr_m[ 5 ], parr_m[ 6 ] ) ;
    progress
  //
  r_use( dir_server() + 'mo_dnab',, 'DD' )
  Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_dd' ) For FIELD->kod_k > 0
  r_use( dir_server() + 'kartote2',, 'KART2' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART2
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kart->kod, 7 ) to ( cur_dir() + 'tmp_rhum' ) ;
    For kart->kod > 0
  Go Top
  Do While !Eof()
    fl := .t.
    If Left( kart2->PC2, 1 ) == '1'
      fl := .f.
    Elseif !( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
      fl := .f.
    Endif
    If fl
      mdate_r := kart->date_r ; M1VZROS_REB := kart->VZROS_REB
      fv_date_r( 0d20251201 ) // переопределение M1VZROS_REB // ЮЮ
      fl := ( M1VZROS_REB == 0 )
    Endif
    If fl .and. !Empty( m1uchast )
      fl := f_is_uchast( arr_uchast, kart->uchast )
    Endif
    If fl
      Select DD
      find ( Str( kart->kod, 7 ) )
      fl := !Found() // нет в файле для дисп.наблюдений
    Endif
    If fl
      Select HUMAN
      find ( Str( kart->kod, 7 ) )
      Do While human->kod_k == kart->kod .and. !Eof()
        ar := {}
        adiagnoz := diag_to_array()
        For i := 1 To Len( adiagnoz )
          If !Empty( adiagnoz[ i ] )
            s := PadR( adiagnoz[ i ], 5 )
            If f_is_diag_dn( s,,, .f. )
              AAdd( ar, s )
              fl := .t.
            Endif
          Endif
        Next i
        If Len( ar ) > 0 // либо основной, либо сопутствующие диагнозы из списка
          ausl := ''
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
              left_lshifr_5 := Left( lshifr, 5 )
              If IsBit( m1dopo_na, 1 ) .and. left_lshifr_5 == '2.78.'
                ausl := lshifr
              Elseif IsBit( m1dopo_na, 2 ) .and. left_lshifr_5 == '2.79.'
                ausl := lshifr
              Elseif left_lshifr_5 == '2.88.'
                If is_usluga_disp_nabl( lshifr )
                  If IsBit( m1dopo_na, 3 )
                    ausl := lshifr
                  Endif
                Else
                  If IsBit( m1dopo_na, 4 )
                    ausl := lshifr
                  Endif
                Endif
              Endif
            Endif
            If !Empty( ausl ) ; exit ; Endif
            Select HU
            Skip
          Enddo
          If !Empty( ausl )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ++ii1
            perenos( t_arr, arr2slist( ar ), 18 )
            add_string( Str( kart->uchast, 2 ) + ' ' + PadR( kart->fio, 45 ) + ' ' + full_date( kart->date_r ) + ' ' + date_8( human->k_data ) + ;
              Str( pers->tab_nom, 6 ) + ' ' + t_arr[ 1 ] )
            add_string( Space( 3 ) + PadR( kart->adres, 45 + 12 ) + PadR( ausl, 15 ) + t_arr[ 2 ] )
            Exit
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    @ MaxRow(), 1 Say lstr( ii1 ) Color cColorStMsg
    Select KART
    Skip
  Enddo
  Close databases
  rest_box( buf )
  If ii1 == 0
    FClose( fp )
    func_error( 4, 'Не найдено пациентов, по которым были другие листы учёта с диагнозом из списка' )
  Else
    add_string( '=== Дополнительно найдено пациентов - ' + lstr( ii1 ) )
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, 2 )
  Endif

  Return Nil

// 05.10.25
Function  vvodn_disp_nabl()

  Local new_hum := 0, new_diag := 0
  Static S_sem := 'disp_nabludenie'

  If f_esc_enter( 'Загрузка новых ДН за 2025г', .t. )
    s := 'Подтвердите загрузку новых ДН из листов учета за текущий год'
    stat_msg( s )
    mybell( 2 )
    If f_esc_enter( 'Загрузить новые ДН за 2025г', .t. )
      Close databases
      If !g_slock( S_sem )
        Return func_error( 4, 'Доступ в данный режим пока запрещён' )
      Endif
      buf := save_maxrow()
      waitstatus( 'Ждите! Составляется список по диспансерному наблюдению на 2026 год' )
      // reconstruct_d01() // инициализация всех файлов инф.сопровождения по диспансерному наблюдению
      // проверяем на изменение приказа - если диагноза нет - удаляем пациента из списка
      Use ( dir_server() + 'mo_dnab' ) New Alias DN
      Index On Str( FIELD->KOD_K, 7 ) + FIELD->KOD_DIAG to ( dir_server() + 'mo_dnab' )
      // очистка завершена
      //
      r_use( dir_server() + 'uslugi',, 'USL' )
      r_use( dir_server() + 'human_u_',, 'HU_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human',, 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_hfio' ) For human_->usl_ok == 3 .and. FIELD->k_data > 0d20250101 // ЮЮ
      // ОТрабатываем 2025 ТЕКУЩИЙ
      Go Top
      Do While !Eof()
        updatestatus()
        If 0 == fvdn_date_r( sys_date, human->date_r )  // контроль по ДР
          mdiagnoz := diag_for_xml(, .t.,,, .t. )
          ar_dn := {}
          If Between( human->ishod, 201, 205 )
            adiag_talon := Array( 16 )
            AFill( adiag_talon, 0 )
            For i := 1 To 16
              adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
            Next
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
                s := 3 // не подлежит диспансерному наблюдению
                If adiag_talon[ i * 2 -1 ] == 1 // впервые
                  If adiag_talon[ i * 2 ] == 2
                    s := 2 // взят на диспансерное наблюдение
                  Endif
                Elseif adiag_talon[ i * 2 -1 ] == 2 // ранее
                  If adiag_talon[ i * 2 ] == 1
                    s := 1 // состоит на диспансерном наблюдении
                  Elseif adiag_talon[ i * 2 ] == 2
                    s := 2 // взят на диспансерное наблюдение
                  Endif
                Endif
                If eq_any( s, 1, 2 ) // взят или состоит на диспансерное наблюдение
                  AAdd( ar_dn, AllTrim( mdiagnoz[ i ] ) )
                Endif
              Endif
            Next
            If !Empty( ar_dn ) // взят на диспансерное наблюдение
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := 'mdiag' + sk
                pole_1dispans := 'm1dispans' + sk
                pole_dn_dispans := 'mdndispans' + sk
                &pole_diag := Space( 6 )
                &pole_1dispans := 0
                &pole_dn_dispans := CToD( '' )
              Next
              read_arr_dvn( human->kod )
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := 'mdiag' + sk
                pole_1dispans := 'm1dispans' + sk
                pole_dn_dispans := 'mdndispans' + sk
                If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. !Empty( &pole_dn_dispans ) ;
                    .and. ( j := AScan( ar_dn, AllTrim( &pole_diag ) ) ) > 0
                  Select DN
                  find ( Str( human->KOD_K, 7 ) + PadR( ar_dn[ j ], 5 ) )
                  If !Found()
                    new_diag++
                    addrec( 7 )
                    dn->KOD_K := human->KOD_K
                    dn->KOD_DIAG := ar_dn[ j ]
                  Endif
                  dn->VRACH := human_->vrach
                  dn->PRVS := human_->prvs
                  If Empty( dn->N_DATA )
                    dn->N_DATA := human->k_data // дата начала диспансерного наблюдения
                  Endif
                  //
                  dn->LU_DATA := human->k_data // дата листа учёта с целью диспансерного наблюдения
                  dn->NEXT_DATA := &pole_dn_dispans // дата следующей явки с целью диспансерного наблюдения
                  If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                    n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // количество месяцев в течение которых предполагается одна явка пациента
                    If Between( n, 1, 99 )
                      dn->FREQUENCY := n
                    Endif
                  Endif
                Endif
              Next
            Endif
          Else
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
                AAdd( ar_dn, PadR( mdiagnoz[ i ], 5 ) )
              Endif
            Next
            If !Empty( ar_dn ) // диагнозы из списка диспансерного наблюдения
              Select HU
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
                If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                  lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                  If is_usluga_disp_nabl( lshifr )
                    For i := 1 To Len( ar_dn )
                      Select DN
                      find ( Str( human->KOD_K, 7 ) + ar_dn[ i ] )
                      If !Found()
                        addrec( 7 )
                        dn->KOD_K := human->KOD_K
                        dn->KOD_DIAG := ar_dn[ i ]
                      Endif
                      dn->VRACH := hu->KOD_VR
                      dn->PRVS := hu_->prvs // Специальность врача по справочнику V004, с минусом - по справочнику V015
                      If Empty( dn->N_DATA )
                        dn->N_DATA := human->k_data // дата начала диспансерного наблюдения
                      Endif
                      //
                      dn->LU_DATA := human->k_data // дата листа учёта с целью диспансерного наблюдения
                      dn->NEXT_DATA := c4tod( human->DATE_OPL ) // дата следующей явки с целью диспансерного наблюдения
                      If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                        n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // количество месяцев в течение которых предполагается одна явка пациента
                        If Between( n, 1, 99 )
                          dn->FREQUENCY := n
                        Endif
                      Endif
                      dn->MESTO := iif( hu->KOL_RCP < 0, 1, 0 ) // место проведения диспансерного наблюдения: 0 - в МО или 1 - на дому
                    Next i
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      Commit
      Select DN
      Go Top
      Do While !Eof()
        updatestatus()
        If !Empty( dn->LU_DATA )
          If dn->FREQUENCY == 0
            dn->FREQUENCY := 1
          Endif
          k := Year( dn->NEXT_DATA )
          If !Between( k, 2023, 2026 ) // ЮЮ если некорректная дата след.визита
            dn->NEXT_DATA := AddMonth( dn->LU_DATA, 12 )
          Endif
          Do While dn->NEXT_DATA < 0d20260101 // ЮЮ
            dn->NEXT_DATA := AddMonth( dn->NEXT_DATA, dn->FREQUENCY )
          Enddo
          If dn->NEXT_DATA < 0d20260101
            dn->FREQUENCY := 0
          Endif
        Endif
        Skip
      Enddo
      Close databases
      //
      rest_box( buf )
      g_sunlock( S_sem )
      func_error( 4, 'Добавлено ' + lstr( new_diag ) + ' пациентов на ДН' )
    Endif
  Endif
  Return Nil

// 02.12.19 Первичный ввод сведений о состоящих на диспансерном учёте в Вашей МО
Function vvodp_disp_nabl()

  Local buf := SaveScreen(), t_arr := Array( BR_LEN )

  mywait()
  dbCreate( 'tmp_kart', { ;
    { 'KOD_K',    'N', 7, 0 }, ; // код по картотеке
    { 'FIO',      'C', 50, 0 }, ;
    { 'POL',      'C', 1, 0 }, ;
    { 'DATE_R',   'D', 8, 0 };
  } )
  Use ( cur_dir() + 'tmp_kart' ) new
  r_use( dir_server() + 'kartotek',, '_KART' )
  use_base( 'mo_dnab' )
  Index On Str( FIELD->kod_k, 7 ) to ( 'tmp_dnab' ) For FIELD->kod_k > 0 UNIQUE
  Go Top
  Do While !Eof()
    Select _kart
    Goto ( dn->kod_k )
    Select TMP_KART
    Append Blank
    tmp_kart->kod_k := dn->kod_k
    tmp_kart->fio := _kart->fio
    tmp_kart->pol := _kart->pol
    tmp_kart->date_r := _kart->date_r
    Select DN
    Skip
  Enddo
  _kart->( dbCloseArea() )
  dn->( dbCloseArea() )
  Select TMP_KART
  If LastRec() == 0
    Close databases
    RestScreen( buf )
    Return func_error( 4, 'Список для диспансерного наблюдения пуст. Добавление через поиск по леч.врачу' )
  Endif
  Index On Upper( FIELD->fio ) to ( cur_dir() + 'tmp_kart' )
  Go Top
  Do While alpha_browse( T_ROW, 7, MaxRow() -2, 71, 'f1vvodP_disp_nabl', color8,,,,,,,,, { '═', '░', '═', } )
    f2vvodp_disp_nabl( tmp_kart->kod_k )
  Enddo
  Close databases
  RestScreen( buf )
  Return Nil

// 02.12.19
Function f1vvodp_disp_nabl( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( 'Ф.И.О.', 50 ), {|| tmp_kart->fio } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Дата рожд.', {|| full_date( tmp_kart->date_r ) } )
  oBrow:addcolumn( oColumn )
  Return Nil


// 23.12.22 Первичный ввод сведений о состоящих на диспансерном учёте в Вашей МО
Function f2vvodp_disp_nabl( lkod_k )

  Local buf := SaveScreen(), t_arr := Array( BR_LEN ), str_sem1

  Private str_find, muslovie

  glob_kartotek := lkod_k
  str_sem1 := lstr( glob_kartotek ) + 'f2vvodP_disp_nabl'
  If g_slock( str_sem1 )
    str_find := Str( glob_kartotek, 7 ) ; muslovie := 'dn->kod_k == glob_kartotek'
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := MaxCol() -2
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := AllTrim( tmp_kart->fio ) + ' ' + full_date( tmp_kart->date_r )
    t_arr[ BR_TITUL_COLOR ] := 'B/BG'
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B', .t. }
    t_arr[ BR_OPEN ] := {| nk, ob| f1_vvod_disp_nabl( nk, ob, 'open' ) }
    t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find ) }, ;
      {| n| skippointer( n, muslovie ) }, ;
      str_find, muslovie ;
      }
    blk := {|| iif( emptyany( dn->vrach, dn->next_data, dn->frequency ) .or. dn->NEXT_DATA <= 0d20191201, { 3, 4 }, { 1, 2 } ) }
    t_arr[ BR_COLUMN ] := { { 'Таб.;номер;врача', {|| iif( dn->vrach > 0, ( p2->( dbGoto( dn->vrach ) ), p2->tab_nom ), 0 ) }, blk } }
    AAdd( t_arr[ BR_COLUMN ], { 'Диагноз;заболевания', {|| dn->kod_diag }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { '   Дата;постановки; на учёт', {|| full_date( dn->n_data ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { '   Дата;следующего;посещения', {|| full_date( dn->next_data ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { 'Кол-во;месяцев между;визитами', {|| put_val( dn->frequency, 7 ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { 'Место проведения;диспансерного;наблюдения', {|| iif( Empty( dn->kod_diag ), Space( 7 ), iif( dn->mesto == 0, ' в МО  ', 'на дому' ) ) }, blk } )
    t_arr[ BR_EDIT ] := {| nk, ob| f3vvodp_disp_nabl( nk, ob, 'edit' ) }
    r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
    use_base( 'mo_dnab' )
    edit_browse( t_arr )
    g_sunlock( str_sem1 )
    dn->( dbCloseArea() )
    p2->( dbCloseArea() )
  Else
    func_error( 4, 'По этому пациенту в данный момент вводит информацию другой пользователь' )
  Endif
  Select TMP_KART
  RestScreen( buf )
  Return Nil

// 03.12.23
Function f3vvodp_disp_nabl( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec := 0, r1, r2, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }
  Local mm_dom := { ;
    { 'в МО   ', 0 }, ;
    { 'на дому', 1 } ;
  }

  Do Case
  Case regim == 'open'
    find ( str_find )
    ret := Found()
  Case regim == 'edit'
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. dn->kod_k > 0 )
      If nKey == K_ENTER
        rec := RecNo()
      Endif
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 5, pc1, pr1 + 5, pc2, 'N/N', 'W+/N' )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
        mKOD_DIAG := iif( nKey == K_INS, Space( 5 ), dn->kod_diag ), ;
        mN_DATA := iif( nKey == K_INS, sys_date -1, dn->n_data ), ;
        mNEXT_DATA := iif( nKey == K_INS, 0d20250101, dn->next_data ), ;  // ЮЮ
      mfrequency := iif( nKey == K_INS, 3, dn->frequency ), ;
        MVRACH := Space( 10 ), ; // фамилия и инициалы лечащего врача
      M1VRACH := iif( nKey == K_INS, 0, dn->vrach ), MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
      mMESTO, m1mesto := iif( nKey == K_INS, 0, dn->mesto )
      mmesto := inieditspr( A__MENUVERT, mm_dom, m1mesto )
      If M1VRACH > 0
        p2->( dbGoto( dn->vrach ) )
        MTAB_NOM := p2->tab_nom
        m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
        mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_tmp_prvs( m1prvs ), 36 )
      Endif
      p2->( dbCloseArea() )
      r1 := pr2 -8 ; r2 := pr2 -1
      tmp_color := SetColor( cDataCScr )
      box_shadow( r1, pc1 + 1, r2, pc2 -1,, iif( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
      SetColor( cDataCGet )
      Do While .t.
        @ r1 + 1, pc1 + 3 Say 'Лечащий врач' Get MTAB_NOM Pict '99999' ;
          valid {| g| v_kart_vrach( g, .t. ) }
        @ Row(), Col() + 1 Get mvrach When .f. Color color14
        @ r1 + 2, pc1 + 3 Say 'Диагноз, по поводу которого пациент подлежит дисп.наблюдению' Get mkod_diag ;
          Pict '@K@!' reader {| o| mygetreader( o, bg ) } ;
          Valid val1_10diag( .t., .f., .f., 0d20191201, tmp_kart->pol )
        @ r1 + 3, pc1 + 3 Say 'Дата начала диспансерного наблюдения' Get mn_data
        @ r1 + 4, pc1 + 3 Say 'Дата следующей явки с целью диспансерного наблюдения' Get mnext_data
        @ r1 + 5, pc1 + 3 Say 'Кол-во месяцев до каждого следующего визита' Get mfrequency Pict '99'
        @ r1 + 6, pc1 + 3 Say 'Место проведения диспансерного наблюдения' Get mmesto ;
          reader {| x| menu_reader( x, mm_dom, A__MENUVERT,,, .f. ) }
        status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
        myread()
        If LastKey() != K_ESC .and. f_esc_enter( 1 )
          mKOD_DIAG := PadR( mKOD_DIAG, 5 )
          fl := .t.
          If Empty( mKOD_DIAG )
            fl := func_error( 4, 'Не введён диагноз' )
          Elseif !f_is_diag_dn( mKOD_DIAG,,, .f. )
            fl := func_error( 4, 'Диагноз не входит в список допустимых' )
          Else
            Select DN
            find ( Str( glob_kartotek, 7 ) )
            Do While dn->kod_k == glob_kartotek .and. !Eof()
              If rec != RecNo() .and. mKOD_DIAG == dn->kod_diag
                fl := func_error( 4, 'Данный диагноз уже введён для данного пациента' )
                Exit
              Endif
              Skip
            Enddo
          Endif
          If Empty( mN_DATA )
            fl := func_error( 4, 'Не введена дата начала диспансерного наблюдения' )
          Elseif mN_DATA >= 0d20251201  // ЮЮ
            fl := func_error( 4, 'Дата начала диспансерного наблюдения слишком большая' )
          Endif
          If Empty( mNEXT_DATA )
            fl := func_error( 4, 'Не введена дата следующей явки' )
          Elseif mN_DATA >= mNEXT_DATA
            fl := func_error( 4, 'Дата следующей явки меньше даты начала диспансерного наблюдения' )
          Elseif mNEXT_DATA <= 0d20260101  // ЮЮ
            fl := func_error( 4, 'Дата следующей явки должна быть не ранее 1 января' )
          Endif
          If !fl
            Loop
          Endif
          Select DN
          If nKey == K_INS
            fl_found := .t.
            addrec( 7 )
            dn->kod_k := glob_kartotek
            rec := RecNo()
          Else
            Goto ( rec )
            g_rlock( forever )
          Endif
          dn->vrach := m1vrach
          dn->prvs  := m1prvs
          dn->kod_diag := mKOD_DIAG
          dn->n_data := mN_DATA
          dn->next_data := mNEXT_DATA
          dn->frequency := mfrequency
          dn->mesto := m1mesto
          Unlock
          Commit
          oBrow:gotop()
          Goto ( rec )
          ret := 0
        Elseif nKey == K_INS .and. !fl_found
          ret := 1
        Endif
        Exit
      Enddo
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
      Select DN
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof() .or. !&muslovie
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

// 25.06.24  выявление типа диагноза
Function  check_tip_disp_nabl( diag )

  Local vozvr := 0

  If check_diag_usl_disp_nabl( diag, '2.78.109' ) // прочие
    vozvr := 109
  Endif
  If vozvr == 0
    If check_diag_usl_disp_nabl( diag, '2.78.110' ) // онкология
      vozvr := 110
    Endif
  Endif
  If vozvr == 0
    If check_diag_usl_disp_nabl( diag, '2.78.111' ) // сахарный Д.
      vozvr := 111
    Endif
  Endif
  If vozvr == 0
    If check_diag_usl_disp_nabl( diag, '2.78.112' ) // ССО
      vozvr := 112
    Endif
  Endif
  Return vozvr

// 05.12.25 Список пациентов, по которым были л/у с диспансерным наблюдением
Function f_inf_disp_nabl( par )

  // 1 -  '~Не было л/у с диспансерным наблюдением',;
  // 2 -  '~Были л/у с диспансерным наблюдением'

  Local arr, arr_full_name, sh := 120, HH := 60, buf := save_maxrow(), name_file := cur_dir() + 'disp_nabl.txt', ;
    ii1 := 0, ii2 := 0, ii3 := 0, s, name_dbf := '___DN' + sdbf(), arr_fl, fl_prikrep := Space( 6 ), kol_kartotek := 0, ;
    t_kartotek := 0
  Local arr_tip_DN := { 'Прочие ДН - ', 'Онкологическое ДН - ', 'Сахарный диабет ДН - ', 'Сердечно-сосудистое ДН - ' }
  Local arr_tip_DN1 := { '2.78.109', '2.78.110', '2.78.111', '2.78.112' }
  Local arr_tip_KOD_USL := { 109, 110, 111, 112 }
  Local arr_kol_ND := { 0, 0, 0, 0 }
  Local arr_kol_ND1 := { 0, 0, 0, 0 }
  Local mas_str_ot := {}, mas_str_ot_FULL := {}
  Local flag_BILO := .f., flag_NAL := .t.
  Local kol_umer := { 0, 0, 0, 0 }, kol_smena := { 0, 0, 0, 0 }, kol_itogo := { 0, 0, 0, 0 }, kol_old := { 0, 0, 0, 0 }
  Local kol_umer1 := { 0, 0, 0, 0 }, kol_smena1 := { 0, 0, 0, 0 }, kol_itogo1 := { 0, 0, 0, 0 }, kol_old1 := { 0, 0, 0, 0 }
  Local lExcel := .f.
  Local name_fileXLS := 'DispNab_' + suffixfiletimestamp()
  Local name_fileXLS_full := hb_DirTemp() + name_fileXLS + '.xlsx'
  Local workbook, worksheet, row, column
  Local fmt_cell_header, fmt_header, fmt_text
  Local VREM_N1 := '', VREM_N2 := ''

  If par == 1
    s := 'Список пациентов, состоящих на ДН, у которых отсутствуют л/у с диспансерным наблюдением'
  Elseif par == 2
    s := 'Список пациентов, состоящих на ДН, у которых присутствуют л/у с диспансерным наблюдением'
  Endif
  //
  row := 0
  column := 0
  workbook  := workbook_new( name_fileXLS_full )
  worksheet := workbook_add_worksheet( workbook, hb_StrToUTF8( 'Список' ) )

  fmt_cell_header := fmt_excel_hc_vc( workbook )
  format_set_text_wrap( fmt_cell_header )
  format_set_bold( fmt_cell_header )
  format_set_font_size( fmt_cell_header, 15 ) // 20

  fmt_header := fmt_excel_hc_vc( workbook )
  format_set_text_wrap( fmt_header )
  format_set_border( fmt_header, LXW_BORDER_THIN )
  format_set_fg_color( fmt_header, 0xC6EFCE )
  format_set_bold( fmt_header )

  fmt_text := fmt_excel_hl_vc( workbook )
  format_set_text_wrap( fmt_text )
  format_set_border( fmt_text, LXW_BORDER_THIN )

  // fmtCellNumberRub := fmt_excel_hR_vC( workbook )
  // format_set_border( fmtCellNumberRub, LXW_BORDER_THIN )
  // format_set_num_format( fmtCellNumberRub, '#,##0.00' )

  // fmtCellNumberNDS := fmt_excel_hR_vC( workbook )
  // format_set_border( fmtCellNumberNDS, LXW_BORDER_THIN )
  // format_set_num_format( fmtCellNumberNDS, '#,##0' )

  worksheet_set_row( worksheet,  0, 40,  nil )
  worksheet_set_column( worksheet, 0, 0, 40, nil )
  worksheet_set_column( worksheet, 2, 2, 11, nil )
  worksheet_set_column( worksheet, 5, 5, 40, nil )
  worksheet_set_column( worksheet, 6, 6, 14, nil )
  worksheet_set_column( worksheet, 7, 7, 20, nil )
  worksheet_merge_range( worksheet, row, column, row, 7, '', nil )
  worksheet_write_string( worksheet, row++, column, hb_StrToUTF8( s ), fmt_cell_header )
  worksheet_write_string( worksheet, row, 0, hb_StrToUTF8( '             ФИО                 ' ), fmt_header )
  worksheet_write_string( worksheet, row, 1, hb_StrToUTF8( 'Участок' ), fmt_header )
  worksheet_write_string( worksheet, row, 2, hb_StrToUTF8( 'Дата рождения' ), fmt_header )
  worksheet_write_string( worksheet, row, 3, hb_StrToUTF8( 'Диагноз' ), fmt_header )
  worksheet_write_string( worksheet, row, 4, hb_StrToUTF8( 'Прикрепление' ), fmt_header )
  worksheet_write_string( worksheet, row, 5, hb_StrToUTF8( '             Адрес             ' ), fmt_header )
  worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( 'СНИЛС' ), fmt_header )
  worksheet_write_string( worksheet, row++, 7, hb_StrToUTF8( 'ЕНП' ), fmt_header )
  //
  dbCreate( cur_dir() + '_disp_NB', { ;
    { 'FIO',        'c', 50, 0 }, ;
    { 'UCHAST',     'c',  3, 0 }, ;
    { 'date_r',     'c', 10, 0 }, ;
    { 'Arr_d',      'c', 10, 0 }, ;
    { 'prikrep',    'c',  3, 0 }, ;
    { 'usluga',     'c',  8, 0 }, ;
    { 'adres',      'c', 50, 0 } } )
  Use ( cur_dir() + '_disp_NB' ) new
  stat_msg( 'Поиск информации...' )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  arr_title := { ;
    '─────────────────────────────────────────────┬────┬──────────┬───────┬───────┬─────────────────────────────────────', ;
    '                                             │  № │   Дата   │Диагноз│  МО   │                                     ', ;
    '              ФИО пациента                   │уч-к│ рождения │  ДН   │прикреп│           Адрес                     ', ;
    '─────────────────────────────────────────────┴────┴──────────┴───────┴───────┴─────────────────────────────────────' }
  sh := Len( arr_title[ 1 ] )

  add_string( '' )
  add_string( Center( s, sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  use_base( 'lusl' )
  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use( dir_server() + 'mo_pers',, 'PERS' )
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'schet',, 'SCHET' )
  Set Relation To RecNo() into SCHET_
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To FIELD->u_kod into USL
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  Set Relation To FIELD->vrach into PERS
  r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->k_data ) to ( cur_dir() + 'tmp_humankk' ) ;
    For human_->USL_OK == 3 .and. human->k_data >= 0d20250101 ; // т.е. текущий год  ЮЮ
  progress
  //
  r_use( dir_server() + 'mo_dnab',, 'DN' )
  r_use( dir_server() + 'mo_d01',, 'D01' )
  r_use( dir_server() + 'mo_d01d',, 'DD' )
  Index On Str( FIELD->kod_d, 6 ) to ( cur_dir() + 'tmp_dd' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartote2',, 'KART2' )
  r_use( dir_server() + 'mo_d01k',, 'RHUM' )
  Set Relation To FIELD->kod_k into KART, To FIELD->reestr into D01
  // добавляем фильтр - год
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kart->kod, 7 ) to ( cur_dir() + 'tmp_rhum' ) ;
    For kart->kod > 0 .and. rhum->oplata == 1 .and. d01->nyear == 2025  // ЮЮ
  //
  For iii := 1 To 4
    vrem_kod := 0
    add_string( '' )
    add_string( Center( arr_tip_DN[ iii ], sh ) )
    add_string( '' )
    Go Top
    Do While !Eof()  // цикл по всей базе картотеки ДИСПАНСЕРНОГО НАБЛЮДЕНИЯ
      // цикл идет по только по ПРИНЯТЫМ ПАЦИЕНТАМ
      arr := {}
      arr_fl := {}
      arr_full_name := {}
      Select DD
      find ( Str( rhum->( RecNo() ), 6 ) )
      // если человек стоит на Д-учете - создаем массив его Д диагнозов
      Do While dd->kod_d == rhum->( RecNo() ) .and. !Eof()
        If dd->next_data >= 0d20260101 .and. dd->next_data <= 0d20261231 .and. dd->oplata == 1 // !!!!!!! ВНИМАНИЕ год   ЮЮ
          If arr_tip_KOD_USL[ iii ] == check_tip_disp_nabl( dd->kod_diag )
            AAdd( arr, PadR( dd->kod_diag, 4 ) )   // было 5
            AAdd( arr_fl, .f. )
            AAdd( arr_full_name, dd->kod_diag )
          Endif
        Endif
        Skip
      Enddo
      //
      If Len( arr ) > 0
        // есть ДД
        fl1 := .f.
        // проверяем пациента на прикрепление
        fl_prikrep := Space( 6 )
        Select KART2
        Goto kart->kod
        If kart2->mo_pr != glob_mo()[ _MO_KOD_TFOMS ]
          fl_prikrep := kart2->mo_pr
          kol_smena[ iii ] := kol_smena[ iii ] + 1
        Endif
        If Left( kart2->PC2, 1 ) == '1'
          fl_prikrep := ' УМЕР '
          kol_umer[ iii ] :=  kol_umer[ iii ] + 1
        Endif
       
        //
        Select KART_
        Goto kart->kod
        // Пациент состоит на ДН
        fl_disp := .f.
        diag_disp := ''
        Select HUMAN
        find ( Str( kart->kod, 7 ) )
        Do While human->kod_k == kart->kod .and. !Eof()
          If !fl_disp .and. human->k_data >= 0d20260101 // !!!!!!! ВНИМАНИЕ год  ЮЮ
            s := PadR( human->kod_diag, 5 )
            diag_disp := s
            // проверяем на ВООБЩЕ диагноз из ДН
            If arr_tip_KOD_USL[ iii ] == check_tip_disp_nabl( s )
              Select HU
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                // отсекаем только текущий год
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
                If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                  lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                  usl_disp := lshifr
                  left_lshifr_8 := Left( lshifr, 8 )
                  If Left( left_lshifr_8, 4 ) == '72.6' .or. getpcel_usl( left_lshifr_8 ) == '1.3'
                    fl_disp := .t.
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Endif
          Select HUMAN
          Skip
        Enddo
        //
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If fl_disp .and. par == 2 // Были л/у с диспансерным наблюдением при наличии ДД
          ttt :=  PadR( '. ' + kart->fio, 40 ) + ' ' + PadL( lstr( kart->uchast ), 4 ) + ' ' + full_date( kart->date_r ) + '  ' + diag_disp  + '   ' + fl_prikrep + ' ' + ;
            PadR( iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), kart->adres ), 40 )
          add_string( PadL( lstr( ++ii2 ), 5 ) + ttt )
          //
          if kart->kod != vrem_kod
            arr_kol_ND[ iii ] := arr_kol_ND[ iii ] + 1
          endif  
          Select _disp_NB
          VREM_N1 := iif( fl_prikrep == glob_mo()[ _MO_KOD_TFOMS ] .or. Len( AllTrim( fl_prikrep ) ) < 1, 'ДА', 'НЕТ' )
          VREM_N2  := iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), PadR( kart->adres, 40 ) )
          //
          worksheet_write_string( worksheet, row,   0, hb_StrToUTF8( AllTrim( PadR( kart->fio, 50 ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   1, hb_StrToUTF8( AllTrim( Str( kart->uchast ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   2, hb_StrToUTF8( AllTrim( full_date( kart->date_r ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   3, hb_StrToUTF8( AllTrim( diag_disp ) ), fmt_text )
          worksheet_write_string( worksheet, row,   4, hb_StrToUTF8( AllTrim( VREM_N1  ) ), fmt_text )
          worksheet_write_string( worksheet, row,   5, hb_StrToUTF8( AllTrim( VREM_N2 ) ), fmt_text )
//          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform( kart->SNILS, picture_pf ) ), fmt_text )
          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform_SNILS( kart->SNILS ) ), fmt_text )
          worksheet_write_string( worksheet, row++, 7, hb_StrToUTF8( iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) ), fmt_text )
          //
        Elseif  !fl_disp .and. par == 1
          ttt :=  PadR( '. ' + kart->fio, 40 ) + ' ' + PadL( lstr( kart->uchast ), 4 ) + ' ' + full_date( kart->date_r ) + '  ' + arr_full_name[ 1 ]  + '   ' + fl_prikrep + ' ' + ;
            PadR( iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), kart->adres ), 40 )
          add_string( PadL( lstr( ++ii2 ), 5 ) + ttt )
          //
          if kart->kod != vrem_kod
            arr_kol_ND[ iii ] := arr_kol_ND[ iii ] + 1
          endif  
          Select _disp_NB
          VREM_N1 := iif( fl_prikrep == glob_mo()[ _MO_KOD_TFOMS ] .or. Len( AllTrim( fl_prikrep ) ) < 1, 'ДА', 'НЕТ' )
          VREM_N2  := iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), PadR( kart->adres, 40 ) )
          //
          worksheet_write_string( worksheet, row,   0, hb_StrToUTF8( AllTrim( kart->fio ) ), fmt_text )
          worksheet_write_string( worksheet, row,   1, hb_StrToUTF8( AllTrim( Str( kart->uchast ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   2, hb_StrToUTF8( AllTrim( full_date( kart->date_r ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   3, hb_StrToUTF8( AllTrim( arr_full_name[ 1 ] ) ), fmt_text )
          worksheet_write_string( worksheet, row,   4, hb_StrToUTF8( AllTrim( VREM_N1  ) ), fmt_text )
          worksheet_write_string( worksheet, row,   5, hb_StrToUTF8( AllTrim( VREM_N2 ) ), fmt_text )
//          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform( kart->SNILS, picture_pf ) ), fmt_text )
          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform_SNILS( kart->SNILS ) ), fmt_text )
          worksheet_write_string( worksheet, row++, 7, hb_StrToUTF8( iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) ), fmt_text )
          //
        Endif
        if kart->kod != vrem_kod
          kol_itogo[ iii ] := kol_itogo[ iii ] + 1
          vrem_kod := kart->kod
        endif  
      Endif
      Select RHUM
      Skip
    Enddo
  Next
  // ---------------------------------------------------------------------------------------------------------------------
  // за текущий год встали на ДН
  For iii := 1 To 4
    add_string( '' )
    add_string( Center( arr_tip_DN[ iii ] + 'Встали на ДН в текущем году', sh ) )
    add_string( '' )
    vrem_kod := 0
    //
    Select DN
    Set Relation To FIELD->kod_k into KART, To FIELD->kod_k into KART_
    Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( dn->kod_k, 7 ) + Descend( DToS( dn->n_data ) ) to ( cur_dir() + 'tmp_dn' ) ;
      For kart->kod > 0
    Go Top
    Do While !Eof()  // цикл по всей базе картотеки ДИСПАНСЕРНОГО НАБЛЮДЕНИЯ
      arr := {}
      arr_fl := {}
      arr_full_name := {}
      // создаем массив его Д диагнозов
      t_kod_k := dn->kod_k
      Select DN
      Do While dn->kod_k == t_kod_k .and. !Eof()
        If arr_tip_KOD_USL[ iii ] == check_tip_disp_nabl( AllTrim( dn->kod_diag ) )
          // проверяем - не добавлен ли к старым диагнозам
          If Year( DN->N_data ) == 2026 .and. Year( DN->lu_data ) == 2026   // ЮЮ
            AAdd( arr, PadR( dn->kod_diag, 4 ) )   // было 5
            AAdd( arr_fl, .f. )
            AAdd( arr_full_name, dn->kod_diag )
          Else
            arr := {}
            Skip
            Exit
          Endif
        Endif
        Skip
      Enddo
      // открутили пацианта
      If Len( arr ) > 0
        // есть ДД
        // проверяем пациента на прикрепление
        fl_prikrep := Space( 6 )
        Select KART2
        Goto kart->kod
        If kart2->mo_pr != glob_mo()[ _MO_KOD_TFOMS ]
          fl_prikrep := kart2->mo_pr
          kol_smena1[ iii ] := kol_smena1[ iii ] + 1
        Endif
        If Left( kart2->PC2, 1 ) == '1'
          fl_prikrep := ' УМЕР '
          kol_umer1[ iii ] :=  kol_umer1[ iii ] + 1
        Endif
      //  kol_itogo1[ iii ] := kol_itogo1[ iii ] + 1
        // проверяем на прошлый год
        Select KART_
        Goto kart->kod
        fl_disp := .f.
        diag_disp := ''
        usl_disp := ''
        Select HUMAN
        find ( Str( kart->kod, 7 ) )
        Do While human->kod_k == kart->kod .and. !Eof()
          If !fl_disp .and. human->k_data >= 0d20260101 // !!!!!!! ВНИМАНИЕ год   ЮЮ
            s := PadR( human->kod_diag, 5 )
            diag_disp := s
            // проверяем на ВООБЩЕ диагноз из ДН
            If arr_tip_KOD_USL[ iii ] == check_tip_disp_nabl( s )
              Select HU
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                // отсекаем только текущий год
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
                If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                  lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                  usl_disp := lshifr
                  left_lshifr_8 := Left( lshifr, 8 )
                  If Left( left_lshifr_8, 4 ) == '72.6' .or. getpcel_usl( left_lshifr_8 ) == '1.3'
                    fl_disp := .t.
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Endif
          Select HUMAN
          Skip
        Enddo
        //
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif

        If fl_disp .and. par == 2 // Были л/у с диспансерным наблюдением при наличии ДД
          ttt :=  PadR( '. ' + kart->fio, 40 ) + ' ' + PadL( lstr( kart->uchast ), 4 ) + ' ' + full_date( kart->date_r ) + ' ' + diag_disp  + '   ' + fl_prikrep + ' ' + ;
            PadR( iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), kart->adres ), 40 )
          add_string( PadL( lstr( ++ii2 ), 5 ) + ttt )
          //
          if kart->kod != vrem_kod
            arr_kol_ND1[ iii ] := arr_kol_ND1[ iii ] + 1
          endif
          Select _disp_NB
          VREM_N1 := iif( fl_prikrep == glob_mo()[ _MO_KOD_TFOMS ] .or. Len( AllTrim( fl_prikrep ) ) < 1, 'ДА', 'НЕТ' )
          VREM_N2   := iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), PadR( kart->adres, 40 ) )
          //
          //
          worksheet_write_string( worksheet, row,   0, hb_StrToUTF8( AllTrim( PadR( kart->fio, 50 ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   1, hb_StrToUTF8( AllTrim( Str( kart->uchast ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   2, hb_StrToUTF8( AllTrim( full_date( kart->date_r ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   3, hb_StrToUTF8( AllTrim( diag_disp ) ), fmt_text )
          worksheet_write_string( worksheet, row,   4, hb_StrToUTF8( AllTrim( VREM_N1 ) ), fmt_text )
          worksheet_write_string( worksheet, row,   5, hb_StrToUTF8( AllTrim( VREM_N2 ) ), fmt_text )
//          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform( kart->SNILS, picture_pf ) ), fmt_text )
          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform_SNILS( kart->SNILS ) ), fmt_text )
          worksheet_write_string( worksheet, row++, 7, hb_StrToUTF8( iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) ), fmt_text )
          //
        Elseif !fl_disp .and. par == 1
          ttt :=  PadR( '. ' + kart->fio, 40 ) + ' ' + PadL( lstr( kart->uchast ), 4 ) + ' ' + full_date( kart->date_r ) + ' ' + arr_full_name[ 1 ]  + '   ' + fl_prikrep + ' ' + ;
            PadR( iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), kart->adres ), 40 )
          add_string( PadL( lstr( ++ii2 ), 5 ) + ttt )
          //
          if kart->kod != vrem_kod
            arr_kol_ND1[ iii ] := arr_kol_ND1[ iii ] + 1
          endif  
          Select _disp_NB
          VREM_N1 := iif( fl_prikrep == glob_mo()[ _MO_KOD_TFOMS ] .or. Len( AllTrim( fl_prikrep ) ) < 1, 'ДА', 'НЕТ' )
          VREM_N2   := iif( Len( AllTrim( kart->adres ) ) < 3, AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres ), PadR( kart->adres, 40 ) )
          //
          worksheet_write_string( worksheet, row,   0, hb_StrToUTF8( AllTrim( kart->fio ) ), fmt_text )
          worksheet_write_string( worksheet, row,   1, hb_StrToUTF8( AllTrim( Str( kart->uchast ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   2, hb_StrToUTF8( AllTrim( full_date( kart->date_r ) ) ), fmt_text )
          worksheet_write_string( worksheet, row,   3, hb_StrToUTF8( AllTrim( arr_full_name[ 1 ] ) ), fmt_text )
          worksheet_write_string( worksheet, row,   4, hb_StrToUTF8( AllTrim( VREM_N1  ) ), fmt_text )
          worksheet_write_string( worksheet, row,   5, hb_StrToUTF8( AllTrim( VREM_N2 ) ), fmt_text )
//          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform( kart->SNILS, picture_pf ) ), fmt_text )
          worksheet_write_string( worksheet, row,   6, hb_StrToUTF8( Transform_SNILS( kart->SNILS ) ), fmt_text )
          worksheet_write_string( worksheet, row++, 7, hb_StrToUTF8( iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) ), fmt_text )
          //
        Endif
        if kart->kod != vrem_kod
          kol_itogo1[ iii ] := kol_itogo1[ iii ] + 1
          vrem_kod := kart->kod
        endif 
      Endif
      Select DN
      // Skip
    Enddo
  Next
  
  //
  For iii := 1 To 4
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( PadR( arr_tip_DN[ iii ], 33 ) )
    add_string( 'по состоянию на конец 2025 года: ' + lstr( kol_itogo[ iii ] ) )
    add_string( 'из них умерло: ' + PadR( lstr( kol_umer[ iii ] ), 8 ) + 'поменяли МО прикрепления: ' + PadR( lstr( kol_smena[ iii ] ), 8 ) )
    If par == 1
      add_string( 'НЕ прошли ДН : ' + lstr( arr_kol_ND[ iii ] ) )
    Else
      add_string( 'прошли ДН : ' + lstr( arr_kol_ND[ iii ] ) )
    Endif
    add_string( 'добавилось за 2026 года: ' + lstr( kol_itogo1[ iii ] ) )
    add_string( 'из них умерло: ' + PadR( lstr( kol_umer1[ iii ] ), 8 ) + 'поменяли МО прикрепления: ' + PadR( lstr( kol_smena1[ iii ] ), 8 ) )
    If par == 1
      add_string( 'НЕ прошли ДН : ' + lstr( arr_kol_ND1[ iii ] ) )
    Else
      add_string( 'прошли ДН : ' + lstr( arr_kol_ND1[ iii ] ) )
    Endif
    add_string( '------------------------------------------------------------------------------------------------------------------------------------------' )
  Next
  Close databases
  FClose( fp )
  rest_box( buf )
  workbook_close( workbook )
  viewtext( name_file,,,, ( sh > 80 ),,, 3 )
  // inf_drz_excel( hb_OEMToANSI( name_file_full ), arr_m, arr )
  work_with_excel_file( name_fileXLS_full )
  Return Nil

// 09.12.18 Первичный ввод сведений о состоящих на диспансерном учёте в Вашей МО
Function vvod_disp_nabl()

  Local buf := SaveScreen(), k, s, s1, t_arr := Array( BR_LEN ), str_sem1, lcolor
  Private str_find, muslovie

  If input_perso( T_ROW, T_COL -5 )
    Do While .t.
      buf := SaveScreen()
      k := -ret_new_spec( glob_human[ 7 ], glob_human[ 8 ] )
      box_shadow( 0, 0, 2, 49, color13,,, 0 )
      @ 0, 0 Say PadC( '[' + lstr( glob_human[ 5 ] ) + '] ' + glob_human[ 2 ], 50 ) Color color14
      @ 1, 0 Say PadC( ret_tmp_prvs( k ), 50 ) Color color14
      @ 2, 0 Say PadC( '... Выбор пациента ...', 50 ) Color color1
      k := polikl1_kart()
      Close databases
      //
      str_sem1 := lstr( glob_kartotek ) + 'f2vvodP_disp_nabl'
      If k == 0
        Exit
      Elseif g_slock( str_sem1 )
        s1 := f0_vvod_disp_nabl()
        r_use( dir_server() + 'kartote2',, '_KART2' )
        Goto ( glob_kartotek )
        r_use( dir_server() + 'kartotek',, '_KART' )
        Goto ( glob_kartotek )
        s := AllTrim( PadR( _kart->fio, 37 ) ) + ' (' + full_date( _kart->date_r ) + ')'
        lcolor := color1
        If Left( _kart2->PC2, 1 ) == '1'
          s := 'УМЕР ' + s ; lcolor := color8
        Elseif !( _kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
          s := 'НЕ НАШ ' + s ; lcolor := color8
        Endif
        @ 2, 0 Say PadC( s, 50 ) Color lcolor
        mdate_r := _kart->date_r ; M1VZROS_REB := _kart->VZROS_REB
        fv_date_r( sys_date ) // переопределение M1VZROS_REB
        If M1VZROS_REB > 0
          func_error( 4, 'Данный режим только для взрослых, а выбранный пациент пока РЕБЁНОК!' )
        Else
          If .f. // !empty(s1)
            box_shadow( 3, 0, 3, 49, color13, Center( s1, 50 ), 'BG+/B', 0 )
          Endif
          str_find := Str( glob_kartotek, 7 ) ; muslovie := 'dn->kod_k == glob_kartotek'
          t_arr[ BR_TOP ] := T_ROW
          t_arr[ BR_BOTTOM ] := MaxRow() -2
          t_arr[ BR_LEFT ] := 2
          t_arr[ BR_RIGHT ] := MaxCol() -2
          t_arr[ BR_COLOR ] := color0
          t_arr[ BR_ARR_BROWSE ] := {,,,, .t. }
          t_arr[ BR_OPEN ] := {| nk, ob| f1_vvod_disp_nabl( nk, ob, 'open' ) }
          t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
            {|| findlast( str_find ) }, ;
            {| n| skippointer( n, muslovie ) }, ;
            str_find, muslovie;
            }
          t_arr[ BR_COLUMN ] := { { 'Диагноз;заболевания', {|| dn->kod_diag } } }
          AAdd( t_arr[ BR_COLUMN ], { '   Дата;постановки; на учёт', {|| full_date( dn->n_data ) } } )
          AAdd( t_arr[ BR_COLUMN ], { '   Дата;следующего;посещения', {|| full_date( dn->next_data ) } } )
          AAdd( t_arr[ BR_COLUMN ], { 'Кол-во;месяцев между;визитами', {|| put_val( dn->frequency, 7 ) } } )
          AAdd( t_arr[ BR_COLUMN ], { 'Место проведения;диспансерного;наблюдения', {|| iif( Empty( dn->kod_diag ), Space( 7 ), iif( dn->mesto == 0, ' в МО  ', 'на дому' ) ) } } )
          t_arr[ BR_EDIT ] := {| nk, ob| f1_vvod_disp_nabl( nk, ob, 'edit' ) }
          use_base( 'mo_dnab' )
          edit_browse( t_arr )
        Endif
        g_sunlock( str_sem1 )
      Else
        func_error( 4, 'По этому пациенту в данный момент вводит информацию другой пользователь' )
      Endif
      Close databases
      RestScreen( buf )
    Enddo
  Endif
  Close databases
  RestScreen( buf )
  Return Nil

// 20.05.25 - старый  вариант
Function  f_inf_prirost_disp_nabl()

  Local new_hum := 0, new_diag := 0, s
  Local arr_tip_KOD_USL := { 109, 110, 111, 112 }
  Local arr_DN_new[ 12, 4 ]
  Local sh := 120, HH := 60, buf := save_maxrow(), name_file := cur_dir() + 'disp_new.txt'
  Local i_1 := i_2 := i_3 := i_4 := 0
  Local arr_tip_TIP_DN := { 'ПРОЧ', 'ОНКО', 'ДИАБ', 'БСК' } 
  Local name_tip := ''
  Local name_fileXLS := 'DispNab_' + suffixfiletimestamp()
  Local name_fileXLS_full := hb_DirTemp() + name_fileXLS + '.xlsx'
  Local workbook, worksheet, row, column
  Local fmt_cell_header, fmtCellNumberRub, fmt_header, fmt_text, fmtCellNumberNDS
  Static  S_sem := 'disp_nabludenie'

  s := 'Список пациентов, поставленных на ДН'
  row := 0
  column := 0
  workbook  := workbook_new( name_fileXLS_full )
  worksheet := workbook_add_worksheet( workbook, hb_StrToUTF8( 'Список' ) )

  fmt_cell_header := fmt_excel_hc_vc( workbook )
  format_set_text_wrap( fmt_cell_header )
  format_set_bold( fmt_cell_header )
  format_set_font_size( fmt_cell_header, 15 ) // 20

  fmt_header := fmt_excel_hc_vc( workbook )
  format_set_text_wrap( fmt_header )
  format_set_border( fmt_header, LXW_BORDER_THIN )
  format_set_fg_color( fmt_header, 0xC6EFCE )
  format_set_bold( fmt_header )

  fmt_text := fmt_excel_hl_vc( workbook )
  format_set_text_wrap( fmt_text )
  format_set_border( fmt_text, LXW_BORDER_THIN )

  worksheet_set_row( worksheet,  0, 40,  nil )
  worksheet_set_column( worksheet, 0, 0, 40, nil )
  worksheet_set_column( worksheet, 1, 1, 20, nil )
  worksheet_set_column( worksheet, 2, 2, 20, nil )
  worksheet_merge_range( worksheet, row, column, row, 2, '', nil )
  worksheet_write_string( worksheet, row++, column, hb_StrToUTF8( s ), fmt_cell_header )
  worksheet_write_string( worksheet, row, 0, hb_StrToUTF8( '             ФИО                 ' ), fmt_header )
  worksheet_write_string( worksheet, row, 1, hb_StrToUTF8( 'ВИД ДН' ), fmt_header )
  worksheet_write_string( worksheet, row++, 2, hb_StrToUTF8( 'Месяц постановки на ДН' ), fmt_header )
  dbCreate( cur_dir() + 't_dN_spis', { ;
    { 'KOD_K',  'N',  7, 0 }, ;
    { 'FIO',    'C',  50, 0 }, ;
    { 'tip',    'N',  3, 0 }, ;   // 1-2-3-4
    { 'MES',    'N',  2, 0 };
  } )
  afillall( arr_DN_new, 0 )
  Close databases
  If !g_slock( S_sem )
    Return func_error( 4, 'Доступ в данный режим пока запрещён' )
  Endif
  buf := save_maxrow()
  waitstatus( 'Ждите! Идет проверка по диспансерному наблюдению на 2026 год' )
  Use ( dir_server() + 'mo_dnab' ) New Alias DN
  Index On Str( FIELD->KOD_K, 7 ) + FIELD->KOD_DIAG to ( dir_server() + 'mo_dnab' )
  // очистка завершена
  //
  Use t_DN_SPIS  New Alias DN_SPIS
  Index On Str( FIELD->KOD_K, 7 ) + Str( FIELD->tip, 3 ) To 'DN_SPIS'
  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use( dir_server() + 'human_u_',, 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human',, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_hfio' ) For human_->usl_ok == 3 .and. FIELD->k_data > 0d20260101 // ЮЮ
  // ОТрабатываем 2025 ТЕКУЩИЙ
  Go Top
  Do While !Eof()
    updatestatus()
    If 0 == fvdn_date_r( sys_date, human->date_r ) .and. human->schet > 0 // контроль по ДР и отправка в ТФОМС
      mdiagnoz := diag_for_xml(, .t.,,, .t. )
      ar_dn := {}
      If Between( human->ishod, 201, 205 )
        adiag_talon := Array( 16 )
        AFill( adiag_talon, 0 )
        For i := 1 To 16
          adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
        Next
        For i := 1 To Len( mdiagnoz )
          If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
            s := 3 // не подлежит диспансерному наблюдению
            If adiag_talon[ i * 2 -1 ] == 1 // впервые
              If adiag_talon[ i * 2 ] == 2
                s := 2 // взят на диспансерное наблюдение
              Endif
            Elseif adiag_talon[ i * 2 -1 ] == 2 // ранее
              If adiag_talon[ i * 2 ] == 1
                s := 1 // состоит на диспансерном наблюдении
              Elseif adiag_talon[ i * 2 ] == 2
                s := 2 // взят на диспансерное наблюдение
              Endif
            Endif
            If eq_any( s, 1, 2 ) // взят или состоит на диспансерное наблюдение
              AAdd( ar_dn, AllTrim( mdiagnoz[ i ] ) )
            Endif
          Endif
        Next
        If !Empty( ar_dn ) // взят на диспансерное наблюдение
          For i := 1 To 5
            sk := lstr( i )
            pole_diag := 'mdiag' + sk
            pole_1dispans := 'm1dispans' + sk
            pole_d_dispans := 'mddispans' + sk
            &pole_diag := Space( 6 )
            &pole_1dispans := 0
            &pole_d_dispans := CToD( '' )
          Next
          read_arr_dvn( human->kod )
          For i := 1 To 5
            sk := lstr( i )
            pole_diag := 'mdiag' + sk
            pole_1dispans := 'm1dispans' + sk
            pole_d_dispans := 'mddispans' + sk
            vr_tip := 0
            vr_tip := check_tip_disp_nabl(  &pole_diag )
            If !Empty( &pole_diag ) .and. !Empty( ( &pole_d_dispans ) ) .and. &pole_1dispans == 1 .and. vr_tip > 100
              // .and. ( j := AScan( ar_dn, AllTrim( &pole_diag ) ) ) > 0

              Select DN_SPIS
              find ( Str( human->KOD_K, 7 ) + Str( vr_tip, 3 ) )
              If !Found()
                addrec( 7 )
                dn_SPIS->KOD_K := human->KOD_K
                dn_spis->fio   := human->fio
                dn_SPIS->tip := vr_tip
              Endif
              If Empty( dn_SPIS->mes ) .or. dn_SPIS->mes > Month( human->k_data )
                dn_SPIS->mes := Month( human->k_data ) // дата начала диспансерного наблюдения
              Endif
              //
            Endif
          Next
        Endif
      Else
        For i := 1 To Len( mdiagnoz )
          If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
            AAdd( ar_dn, PadR( mdiagnoz[ i ], 5 ) )
          Endif
        Next
      /*  If !Empty( ar_dn ) // диагнозы из списка диспансерного наблюдения
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
              If is_usluga_disp_nabl( lshifr )
                For i := 1 To Len( ar_dn )
                  // vr_tip := 0
                  vr_tip := check_tip_disp_nabl(  ar_dn[ i ] )
                  Select DN_SPIS
                  find ( Str( human->KOD_K, 7 ) + Str( vr_tip, 3 ) )
                  If !Found()
                    addrec( 7 )
                    dn_SPIS->KOD_K := human->KOD_K
                    dn_spis->fio   := human->fio
                    dn_SPIS->tip := vr_tip
                  Endif
                  If Empty( dn_SPIS->mes ) .or. dn_SPIS->mes > Month( human->k_data )
                    dn_SPIS->mes := Month( human->k_data ) // дата начала диспансерного наблюдения
                  Endif
                  //
                Next i
              Endif
            Endif
            Select HU
            Skip
          Enddo
        Endif
        */
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  // удаляем диагнозы до 2023 год
  // Use ( dir_server() + 'mo_dnab' ) New Alias DN
  Select dn_SPIS
  Set Index To
  Go Top
  Do While !Eof()
    updatestatus()
    Select DN
    find ( Str( dn_spis->kod_k, 7 ) )
    Do While dn_spis->kod_k == dn->kod_k .and. !Eof() // цикл по человеку
      // ищем нужный тип ДН
      If dn_SPIS->tip ==   check_tip_disp_nabl( dn->KOD_DIAG )
        If Year( DN->n_data ) == 2025                           //ЮЮ
          // ничего не делаем
        Else
          // удаляем диагноз из  dn_SPIS
          dn_SPIS->kod_k := 0
        Endif
      Endif
      Select DN
      Skip
    Enddo
    Select dn_SPIS
    Skip
  Enddo
  Commit
  r_use( dir_server() + 'kartotek',, 'KART' )
  Select DN_SPIS
  Go Top
  Do While !Eof()
    updatestatus()
    If kod_k > 0
      Select kart
      Goto ( DN_SPIS->kod_k )
      DN_SPIS->fio := kart->fio
    Else
      Delete
    Endif
    Select dn_SPIS
    Skip
  Enddo
  Select DN_SPIS

  Pack
  //
  Select DN_SPIS
  Go Top
  Do While !Eof()
    updatestatus()
    If DN_SPIS->tip == 109
      arr_DN_new[ DN_SPIS->mes, 1 ]++
    Elseif  DN_SPIS->tip == 110
      arr_DN_new[ DN_SPIS->mes, 2 ]++
    Elseif  DN_SPIS->tip == 111
      arr_DN_new[ DN_SPIS->mes, 3 ]++
    Elseif  DN_SPIS->tip == 112
      arr_DN_new[ DN_SPIS->mes, 4 ]++
    Endif
    Select dn_SPIS
    Skip
  Enddo

  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  arr_title := { ;
    '────────────────────┬────────┬────────┬────────┬────────', ;
    '        месяц       │ Прочие │  Онко- │Сахарный│        ', ;
    '  постановки на ДН  │ забол-я│  логия │ диабет │  БСК   ', ;
    '────────────────────┴────────┴────────┴────────┴────────' }
  sh := Len( arr_title[ 1 ] )

  add_string( '          Поставленные на ДН за 2025 год' )
  add_string( '              Кол-во диагнозов' )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  For i := 1 To 12
    add_string( PadR( mm_month[ i ], 20 ) + Str( arr_DN_new[ i, 1 ], 8 ) + ' ' + Str( arr_DN_new[ i, 2 ], 8 ) + ' ' + Str( arr_DN_new[ i, 3 ], 8 ) + ' ' + Str( arr_DN_new[ i, 4 ], 8 ) )
    i_1 := i_1 + arr_DN_new[ i, 1 ]
    i_2 := i_2 + arr_DN_new[ i, 2 ]
    i_3 := i_3 + arr_DN_new[ i, 3 ]
    i_4 := i_4 + arr_DN_new[ i, 4 ]
  Next
  add_string( '────────────────────────────────────────────────────────' )
  add_string( PadR( 'ИТОГО:', 20 ) + Str( i_1, 8 ) + ' ' + Str( i_2, 8 ) + ' ' + Str( i_3, 8 ) + ' ' + Str( i_4, 8 ) )
  add_string( '' )
  //
  //Use t_DN_SPIS  New Alias DN_SPIS
  arr_title := { ;
    '─────────────────────────────────────────┬────────────────', ;
    '                   ФИО                   │    Вид  ДН     ', ;
    '─────────────────────────────────────────┴────────────────' }
  Index On Str( FIELD->mes, 2 ) + Str( FIELD->tip, 3 ) + FIELD->fio To 'DN_SPIS'
  //
  Select DN_SPIS
  Go Top
  add_string( padc('Месяц постановки на ДН '+ mm_month[ dn_spis->mes],80)   )
  t_mes := 1
  Do While !Eof()
    updatestatus()
    if t_mes != dn_spis->mes
      add_string( '' )
      add_string(padc('Месяц постановки на ДН '+ mm_month[ dn_spis->mes],80)  )
      add_string( '' )
      t_mes := dn_spis->mes
    endif  
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    name_tip := ''
    if dn_spis->tip ==  109
      name_tip := arr_tip_TIP_DN[1]  
    elseif  dn_spis->tip == 110 
      name_tip := arr_tip_TIP_DN[2]  
    elseif  dn_spis->tip ==  111 
      name_tip := arr_tip_TIP_DN[3] 
    elseif  dn_spis->tip ==  112 
      name_tip := arr_tip_TIP_DN[4] 
    endif 
    add_string( PadR( DN_spis->fio, 50 ) + name_tip   )
    worksheet_write_string( worksheet, row,   0, hb_StrToUTF8( AllTrim( DN_spis->fio ) ), fmt_text )
    worksheet_write_string( worksheet, row, 1, hb_StrToUTF8( AllTrim( name_tip  )), fmt_text )
    worksheet_write_string( worksheet, row++, 2, hb_StrToUTF8( AllTrim( mm_month[ dn_spis->mes]  )), fmt_text )
    Select dn_SPIS
    Skip
  Enddo

  Close databases
  //
  rest_box( buf )
  g_sunlock( S_sem )
  FClose( fp )
  workbook_close( workbook )
  viewtext( name_file,,,, ( sh > 80 ),,, 1 )
  // inf_drz_excel( hb_OEMToANSI( name_file_full ), arr_m, arr )
  work_with_excel_file( name_fileXLS_full )
  Return Nil

// 09.12.18
Function f0_vvod_disp_nabl()

  Local s := ''

  r_use( dir_server() + 'mo_d01k',, 'DK' )
  Index On Str( FIELD->reestr, 6 ) to ( cur_dir() + 'tmp_dk' ) For FIELD->kod_k == glob_kartotek
  Go Top
  Do While !Eof()
    If dk->oplata == 0
      s := 'отправлен в ТФОМС - ответ ещё не получен'
      Exit
    Elseif dk->oplata == 1
      s := 'отправлен в ТФОМС - без ошибок'
      Exit
    Else
      s := 'вернулся из ТФОМС с ошибками'
    Endif
    Skip
  Enddo
  dk->( dbCloseArea() )
  Return s

// 01.11.24
Function f1_vvod_disp_nabl( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec := 0, rec1, r1, r2, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }
  Local mm_dom := { ;
    { 'в МО   ', 0 }, ;
    { 'на дому', 1 } ;
  }

  Do Case
  Case regim == 'open'
    find ( str_find )
    ret := Found()
  Case regim == 'edit'
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. dn->kod_k > 0 )
      If nKey == K_ENTER .and. dn->vrach != glob_human[ 1 ]
        func_error( 4, 'Данная строка введена другим врачом!' )
        Return ret
      Endif
      If nKey == K_ENTER
        rec := RecNo()
      Endif
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 5, pc1, pr1 + 5, pc2, 'N/N', 'W+/N' )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
        mKOD_DIAG := iif( nKey == K_INS, Space( 5 ), dn->kod_diag ), ;
        mN_DATA := iif( nKey == K_INS, sys_date -1, dn->n_data ), ;
        mNEXT_DATA := iif( nKey == K_INS, 0d20250201, dn->next_data ), ; // ЮЮ - ВРЕМЕННО
      mfrequency := iif( nKey == K_INS, 3, dn->frequency ), ;
        mMESTO, m1mesto := iif( nKey == K_INS, 0, dn->mesto )
      mmesto := inieditspr( A__MENUVERT, mm_dom, m1mesto )
      r1 := pr2 -7 ; r2 := pr2 -1
      tmp_color := SetColor( cDataCScr )
      box_shadow( r1, pc1 + 1, r2, pc2 -1,, iif( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
      SetColor( cDataCGet )
      Do While .t.
        @ r1 + 1, pc1 + 3 Say 'Диагноз, по поводу которого пациент подлежит дисп.наблюдению' Get mkod_diag ;
          Pict '@K@!' reader {| o| mygetreader( o, bg ) } ;
          Valid val1_10diag( .t., .f., .f., 0d20251201, _kart->pol )  // ЮЮ
        @ r1 + 2, pc1 + 3 Say 'Дата начала диспансерного наблюдения' Get mn_data
        @ r1 + 3, pc1 + 3 Say 'Дата следующей явки с целью диспансерного наблюдения' Get mnext_data
        @ r1 + 4, pc1 + 3 Say 'Кол-во месяцев до каждого следующего визита' Get mfrequency Pict '99'
        @ r1 + 5, pc1 + 3 Say 'Место проведения диспансерного наблюдения' Get mmesto ;
          reader {| x| menu_reader( x, mm_dom, A__MENUVERT,,, .f. ) }
        status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
        myread()
        If LastKey() != K_ESC .and. f_esc_enter( 1 )
          mKOD_DIAG := PadR( mKOD_DIAG, 5 )
          fl := .t.
          If Empty( mKOD_DIAG )
            fl := func_error( 4, 'Не введён диагноз' )
          Elseif !f_is_diag_dn( mKOD_DIAG,,, .f. )
            fl := func_error( 4, 'Диагноз не входит в список допустимых' )
          Else
            Select DN
            find ( Str( glob_kartotek, 7 ) )
            Do While dn->kod_k == glob_kartotek .and. !Eof()
              If rec != RecNo() .and. mKOD_DIAG == dn->kod_diag
                fl := func_error( 4, 'Данный диагноз уже введён для данного пациента' )
                Exit
              Endif
              Skip
            Enddo
          Endif
          If Empty( mN_DATA )
            fl := func_error( 4, 'Не введена дата начала диспансерного наблюдения' )
          Elseif mN_DATA >= 0d20251201  // ЮЮ
            fl := func_error( 4, 'Дата начала диспансерного наблюдения слишком большая' )
          Endif
          If Empty( mNEXT_DATA )
            fl := func_error( 4, 'Не введена дата следующей явки' )
          Elseif mN_DATA >= mNEXT_DATA
            fl := func_error( 4, 'Дата следующей явки меньше даты начала диспансерного наблюдения' )
          Elseif mNEXT_DATA <= 0d20260101  // ЮЮ - временно
            fl := func_error( 4, 'Дата следующей явки должна быть не ранее 1 января' )
          Endif
          If !fl
            Loop
          Endif
          Select DN
          If nKey == K_INS
            fl_found := .t.
            addrec( 7 )
            dn->kod_k := glob_kartotek
            rec := RecNo()
          Else
            Goto ( rec )
            g_rlock( forever )
          Endif
          dn->vrach := glob_human[ 1 ]
          dn->prvs  := iif( Empty( glob_human[ 8 ] ), glob_human[ 7 ], -glob_human[ 8 ] )
          dn->kod_diag := mKOD_DIAG
          dn->n_data := mN_DATA
          dn->next_data := mNEXT_DATA
          dn->frequency := mfrequency
          dn->mesto := m1mesto
          Unlock
          Commit
          oBrow:gotop()
          Goto ( rec )
          ret := 0
        Elseif nKey == K_INS .and. !fl_found
          ret := 1
        Endif
        Exit
      Enddo
      Select DN
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof() .or. !&muslovie
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

// 09.12.18 Информация по первичному вводу сведений о состоящих на диспансерном учёте
Function f2_vvod_disp_nabl( ldiag )

  Local fl := .f., lfp, i, s, d1, d2

  If len_diag == 0
    lfp := FOpen( file_form )
    Do While !feof( lfp )
      s := freadln( lfp )
      If !Empty( s )
        AAdd( diag1, AllTrim( s ) )
      Endif
    Enddo
    FClose( lfp )
    len_diag := Len( diag1 )
  Endif
  Return AScan( diag1, AllTrim( ldiag ) ) > 0



// 12.09.25 Информация по первичному вводу сведений о состоящих на диспансерном учёте
Function inf_disp_nabl()

  Static suchast := 0, svrach := 0, sdiag := '', ;
    mm_spisok := { { 'весь список пациентов', 0 }, { 'с неполным вводом', 1 }, { 'с корректным вводом', 2 } }
  Local bg := {| o, k| get_mkb10( o, k, .f. ) }
  Local buf := SaveScreen(), r := 13, sh, HH := 60, name_file := cur_dir() + 'info_dn.txt', ru := 0, ;
    rd := 0, rd1 := 0, rpr := 0, ro_f := .f., ro := 0, rod := 0, t_vr
  Local mas_tip_dz := { 0, 0, 0, 0, 0 }, mas_tip_pc := { 0, 0, 0, 0, 0, 0 }, fl_1 := 0, fl_2 := 0, fl_3 := 0, fl_4 := 0, ;
    fl_5 := 0, fl_31 := 0, fl_32 := 0, fl_33 := 0, fl_umer := .t., otvet := '      ', fl_prinet := .f., ;
    mas_tip_prin := { 0, 0, 0, 0, 0, 0 }, t_mo_prik := '', iii := 0, iii1 := 0, iii2 := 0, s

  // это эксель
  Local lExcel := .f., iOutput
  Local name_fileXLS := 'DispN_spis_' + suffixfiletimestamp()
  Local name_fileXLS_full := hb_DirTemp() + name_fileXLS + '.xlsx'
  Local workbook, worksheet, row, column
  Local fmt_cell_header, fmtCellNumberRub, fmt_header, fmt_text, fmtCellNumberNDS
  Local old_row_XLS := 0
  Local old_fio := '', old_adres := '', old_DR := '', old_PRIKREP := '', old_num_UCH := '', old_SNILS := '', old_ENP := ''
  Local arr_DN := Array( 5, 5 ) // всего наших - принято- ошибка - не отправл - нет ответа
  Local arr_tip_DN1 := { '2.78.109', '2.78.110', '2.78.111', '2.78.112' }
  Local arr_tip_KOD_USL := { 109, 110, 111, 112 }
  Local flag_1 := .t., flag_2 := .t., flag_3 := .t., flag_4 := .t., t_kart_kod := 0
  Local flag_1_1 := .t., flag_2_1 := .t., flag_3_1 := .t., flag_4_1 := .t.
  Local flag_1_2 := .t., flag_2_2 := .t., flag_3_2 := .t., flag_4_2 := .t.
  Local flag_1_3 := .t., flag_2_3 := .t., flag_3_3 := .t., flag_4_3 := .t.
  Local flag_1_4 := .t., flag_2_4 := .t., flag_3_4 := .t., flag_4_4 := .t.

  afillall( arr_DN, 0 )
  SetColor( cDataCGet )
  myclear( r )
  Private muchast := suchast, ;
    mvrach := svrach, ;
    mkod_diag := PadR( sdiag, 5 ), ;
    mkod_diag1 := '   ', mkod_diag2 := '   ', ;
    m1spisok := 0, mspisok := mm_spisok[ 1, 1 ], ;
    m1adres := 0, madres := mm_danet[ 1, 1 ], ;
    m1umer := mm_danet[ 1, 2 ], mumer := mm_danet[ 1, 1 ], ;
    m1period := 0, mperiod := Space( 10 ), parr_m, ;
    gl_area := { r, 0, MaxRow() -1, MaxCol(), 0 }
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - составление документа' )
  //
  @ r, 0 To r + 10, MaxCol() Color color8
  str_center( r, ' Запрос информации по ведённому диспансерному наблюдению ', color14 )
  @ r + 2, 2 Say 'Номер участка (0 - по всем участкам)' Get muchast Pict '99999'
  @ r + 3, 2 Say 'Табельный номер врача (0 - по всем врачам)' Get mvrach Pict '99999'
  @ r + 4, 2 Say 'Диагноз (или начальные 1-2 символа, или пустая строка)' Get mkod_diag ;
    Pict '@K@!' reader {| o| mygetreader( o, bg ) }
  @ r + 5, 2 Say '  или диапазон диагнозов' Get mkod_diag1 ;
    Pict '@K@!' reader {| o| mygetreader( o, bg ) } When Empty( mkod_diag )
  @ Row(), Col() Say ' -' Get mkod_diag2 ;
    Pict '@K@!' reader {| o| mygetreader( o, bg ) } When Empty( mkod_diag )
  // @ r + 6, 2 Say 'Полнота списка' Get mspisok ;
  // reader {| x| menu_reader( x, mm_spisok, A__MENUVERT,,, .f. ) }
  @ r + 6, 2 Say 'Дата постановки на диспансерное наблюдение' Get mperiod ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( parr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION,,, .f. ) }
  @ r + 7, 2 Say 'Выводить адреса пациентов' Get madres ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
  @ r + 8, 2 Say 'Выводить Умерших пациентов' Get mumer ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
  myread()
  If LastKey() != K_ESC
    If !( ValType( parr_m ) == 'A' )
      parr_m := Array( 8 )
      parr_m[ 5 ] := 0d19000101    // ЮЮ
      parr_m[ 6 ] := 0d20261231    // ЮЮ
    Endif
    If mvrach > 0
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'PERSO' )
      find ( Str( mvrach, 5 ) )
      If Found()
        glob_human := { perso->kod, ;
          AllTrim( perso->fio ), ;
          perso->uch, ;
          perso->otd, ;
          mvrach, ;
          AllTrim( perso->name_dolj ), ;
          perso->prvs, ;
          perso->prvs_new }
        fl1 := .t.
      Else
        func_error( 4, 'Сотрудника с табельным номером ' + lstr( i ) + ' нет в базе данных персонала!' )
        mvrach := 0
      Endif
      Close databases
    Endif
    d1 := d2 := 0
    If Empty( mkod_diag )
      mkod_diag1 := AllTrim( mkod_diag1 )
      mkod_diag2 := AllTrim( mkod_diag2 )
      If Len( mkod_diag1 ) == 3 .and. Len( mkod_diag2 ) == 3
        d1 := diag_to_num( mkod_diag1, 1 )
        d2 := diag_to_num( mkod_diag2, 2 )
      Endif
    Else
      fl_all_diag := .f.
      mkod_diag := AllTrim( mkod_diag ) ; l := Len( mkod_diag )
      If f_is_diag_dn( mkod_diag,,, .f. )
        fl_all_diag := .t.
      Endif
    Endif
    //
    suchast := muchast
    svrach := mvrach
    sdiag := mkod_diag
    //
    row := 0
    column := 0
    workbook  := workbook_new( name_fileXLS_full )
    worksheet := workbook_add_worksheet( workbook, hb_StrToUTF8( 'Список' ) )

    fmt_cell_header := fmt_excel_hc_vc( workbook )
    format_set_text_wrap( fmt_cell_header )
    format_set_bold( fmt_cell_header )
    format_set_font_size( fmt_cell_header, 20 )

    fmt_header := fmt_excel_hc_vc( workbook )
    format_set_text_wrap( fmt_header )
    format_set_border( fmt_header, LXW_BORDER_THIN )
    format_set_fg_color( fmt_header, 0xC6EFCE )
    format_set_bold( fmt_header )

    fmt_text := fmt_excel_hl_vc( workbook )
    format_set_text_wrap( fmt_text )
    format_set_border( fmt_text, LXW_BORDER_THIN )

    // fmtCellNumberRub := fmt_excel_hR_vC( workbook )
    // format_set_border( fmtCellNumberRub, LXW_BORDER_THIN )
    // format_set_num_format( fmtCellNumberRub, '#,##0.00' )

    // fmtCellNumberNDS := fmt_excel_hR_vC( workbook )
    // format_set_border( fmtCellNumberNDS, LXW_BORDER_THIN )
    // format_set_num_format( fmtCellNumberNDS, '#,##0' )
    s := 'Список пациентов, состоящих на диспансерном учёте'
    worksheet_set_row( worksheet,  0, 40,  nil )
    worksheet_set_column( worksheet, 0, 0, 12, nil )
    worksheet_set_column( worksheet, 1, 1, 40, nil )
    worksheet_set_column( worksheet, 2, 2, 40, nil )
    worksheet_set_column( worksheet, 3, 3, 10, nil )
    worksheet_set_column( worksheet, 4, 4, 13, nil )
    worksheet_set_column( worksheet, 5, 5, 16, nil )
    worksheet_set_column( worksheet, 7, 7, 7, nil )
    worksheet_set_column( worksheet, 8, 8, 7, nil )
    worksheet_set_column( worksheet, 10, 10, 11, nil )
    worksheet_set_column( worksheet, 11, 11, 11, nil )
    worksheet_set_column( worksheet, 12, 12, 11, nil )
    worksheet_merge_range( worksheet, row, column, row, 13, '', nil )
    worksheet_write_string( worksheet, row++, column, hb_StrToUTF8( s ), fmt_cell_header )
    worksheet_write_string( worksheet, row, 0, hb_StrToUTF8( 'Ответ ТФОМС' ), fmt_header )
    worksheet_write_string( worksheet, row, 1, hb_StrToUTF8( 'ФИО' ), fmt_header )
    worksheet_write_string( worksheet, row, 2, hb_StrToUTF8( 'Адрес' ), fmt_header )
    worksheet_write_string( worksheet, row, 3, hb_StrToUTF8( 'Дата рождения' ), fmt_header )
    worksheet_write_string( worksheet, row, 4, hb_StrToUTF8( 'СНИЛС' ), fmt_header )
    worksheet_write_string( worksheet, row, 5, hb_StrToUTF8( 'ЕНП' ), fmt_header )
    worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( 'Прикрепление' ), fmt_header )
    worksheet_write_string( worksheet, row, 7, hb_StrToUTF8( 'Участок' ), fmt_header )
    worksheet_write_string( worksheet, row, 8, hb_StrToUTF8( 'Таб. номер врача' ), fmt_header )
    worksheet_write_string( worksheet, row, 9, hb_StrToUTF8( 'Диагноз' ), fmt_header )
    worksheet_write_string( worksheet, row, 10, hb_StrToUTF8( 'Дата последнего ЛУ' ), fmt_header )
    worksheet_write_string( worksheet, row, 11, hb_StrToUTF8( 'Дата постановки на ДН' ), fmt_header )
    worksheet_write_string( worksheet, row, 12, hb_StrToUTF8( 'Дата следующего визита' ), fmt_header )
    worksheet_write_string( worksheet, row++, 13, hb_StrToUTF8( 'через N месяцев' ), fmt_header )
    //
    arr_title := { ;
      '──────────┬──────────────────────────────────────┬──────────┬──────┬──┬─────┬─────┬────────┬────────┬────────────────', ;
      '   Ответ  │                                      │   Дата   │  МО  │Уч│ Таб.│Диаг-│Дата по-│Дата по-│_Следующий_визит', ;
      '          │        ФИО пациента                  │ рождения │прик-я│ас│номер│ноз  │следнего│становки│        │через N', ;
      '   ТФОМС  │                                      │   Дата   │      │то│врача│     │   ЛУ   │ на ДН  │  дата  │месяцев', ;
      '──────────┴──────────────────────────────────────┴──────────┴──────┴──┴─────┴─────┴────────┴────────┴────────┴───────' }
    sh := Len( arr_title[ 1 ] )
    mywait()
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( '' )
    add_string( Center( 'Список пациентов, состоящих на диспансерном учёте', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    r_use( dir_server() + 'mo_D01E',,  'D01E' ) // ошибки пациента в пакете D01
    index on str( FIELD->reestr, 6 ) + str( FIELD->d01_zap, 6 ) to  ( cur_dir() + 'tmp_D01E' )
    r_use( dir_server() + 'mo_D01',,  'D01' )  // пакеты D01
    r_use( dir_server() + 'mo_D01K',,  'D01K' ) // пациента в пакете D01
    r_use( dir_server() + 'mo_D01D',,  'D01D' ) // диагнозы у пациентов в пакете D01
    Index On Str( FIELD->kod_n, 6 ) + Str( FIELD->kod_d, 7 ) to ( cur_dir() + 'tmp_D01' ) DESCENDING
    r_use( dir_server() + 'mo_pers',,  'PERS' )
    r_use( dir_server() + 'kartote2',, 'KART2' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    r_use_base( 'mo_dnab' )
    Set Relation To FIELD->kod_k into KART, To FIELD->kod_k into KART_, To FIELD->vrach into PERS
    Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( dn->kod_k, 7 ) + dn->kod_diag to ( cur_dir() + 'tmp_dn' ) ;
      For kart->kod > 0
    old := r := rs := ro := 0
    sadres := ''
    fl_umer := .t.
    waitstatus( 'Ждите! Составляется список, состоящих на диспансерном учёте' )
    Go Top
    Do While !Eof()   // ЦИКЛ по файлу со всеми ДН
      If t_kart_kod != kart->kod
        t_kart_kod := kart->kod
        flag_1 := flag_2 := flag_3 := flag_4 := .t.
        flag_1_1 := flag_2_1 := flag_3_1 := flag_4_1 := .t.
        flag_1_2 := flag_2_2 := flag_3_2 := flag_4_2 := .t.
        flag_1_4 := flag_2_4 := flag_3_4 := flag_4_4 := .t.
      Endif
      updatestatus()
      otvet := '       '
      ro_f := .f.
      fl := .t.
      // fl_umer := .t.
      If Between( dn->n_data, parr_m[ 5 ], parr_m[ 6 ] )
        fl := .t.
      Else
        fl := .f.
      Endif
      If muchast > 0
        fl := ( kart->uchast == muchast )
      Endif
      If fl .and. mvrach > 0
        fl := ( glob_human[ 1 ] == dn->vrach )
      Endif
      If fl .and. !Empty( mkod_diag )
        If fl_all_diag
          fl := ( AllTrim( dn->kod_diag ) == mkod_diag )
        Else
          fl := ( Left( dn->kod_diag, l ) == mkod_diag )
        Endif
      Endif
      If fl .and. !emptyany( d1, d2 )
        fl := Between( diag_to_num( dn->kod_diag, 1 ), d1, d2 )
      Endif
      If fl .and. ( 1 == fvdn_date_r( sys_date, kart->date_r ) .or. 2 == fvdn_date_r( sys_date, kart->date_r ) )
        fl := .f.
      Endif
      //
      If fl
        If old == dn->kod_k // не первая строка у пациента
          If !Empty( sadres )
            s := PadR( '  ' + sadres, 38 + 1 + 10 + 3 + 7  )
            sadres := ''
          Else
            s := Space( 38 ) + Space( 1 + 10 + 3 + 7  )
          Endif
          worksheet_write_string( worksheet, row, 1, hb_StrToUTF8(  AllTrim( kart->fio ) ), fmt_text )
          worksheet_write_string( worksheet, row, 3, hb_StrToUTF8( full_date( kart->date_r ) ), fmt_text )
//          worksheet_write_string( worksheet, row, 4, hb_StrToUTF8( Transform( kart->SNILS, picture_pf ) ), fmt_text )
          worksheet_write_string( worksheet, row, 4, hb_StrToUTF8( Transform_SNILS( kart->SNILS ) ), fmt_text )
          worksheet_write_string( worksheet, row, 5, hb_StrToUTF8( iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) ), fmt_text )
          worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( old_PRIKREP ), fmt_text )
          worksheet_write_string( worksheet, row, 7, hb_StrToUTF8(  old_num_UCH ), fmt_text )
        Else
          If old_row_XLS > 0
            If ( row - old_row_XLS ) > 1
              worksheet_merge_range(  worksheet, old_row_XLS, 1, row - 1, 1,  hb_StrToUTF8( old_fio ), fmt_text )
              worksheet_merge_range(  worksheet, old_row_XLS, 2, row - 1, 2,  hb_StrToUTF8( old_adres ), fmt_text )
              worksheet_merge_range(  worksheet, old_row_XLS, 3, row - 1, 3,  hb_StrToUTF8( old_DR ), fmt_text )
              worksheet_merge_range(  worksheet, old_row_XLS, 4, row - 1, 4,  hb_StrToUTF8( old_SNILS ), fmt_text )
              worksheet_merge_range(  worksheet, old_row_XLS, 5, row - 1, 5,  hb_StrToUTF8( old_ENP ), fmt_text )
              worksheet_merge_range(  worksheet, old_row_XLS, 6, row - 1, 6,  hb_StrToUTF8( old_PRIKREP ), fmt_text )
              worksheet_merge_range(  worksheet, old_row_XLS, 7, row - 1, 7,  hb_StrToUTF8( old_num_UCH  ), fmt_text )
            Endif
          Endif
          old_row_XLS := row
          worksheet_write_string( worksheet, row, 1, hb_StrToUTF8(  AllTrim( kart->fio ) ), fmt_text )
          worksheet_write_string( worksheet, row, 3, hb_StrToUTF8( full_date( kart->date_r ) ), fmt_text )
//          worksheet_write_string( worksheet, row, 4, hb_StrToUTF8( Transform( kart->SNILS, picture_pf ) ), fmt_text )
          worksheet_write_string( worksheet, row, 4, hb_StrToUTF8( Transform_SNILS( kart->SNILS ) ), fmt_text )
          worksheet_write_string( worksheet, row, 5, hb_StrToUTF8( iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) ), fmt_text )
          old_fio := AllTrim( kart->fio )
          old_DR := full_date( kart->date_r )
//          old_SNILS := Transform( kart->SNILS, picture_pf )
          old_SNILS := Transform_SNILS( kart->SNILS )
          old_ENP := iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' )
          // первая строка на человека
          fl_prinet := .f. // по умолчанию - не принят
          If !Empty( sadres )
            add_string( '        ' + sadres )
          Endif
          s := PadR( kart->fio, 38 ) + ' ' + full_date( kart->date_r )
          Select KART2
          Goto kart->kod
          If !Empty( kart2->mo_pr )
            If glob_mo()[ _MO_KOD_TFOMS ] == kart2->mo_pr
              s := s + '       '
              old_PRIKREP := ''
            Else
              ++rpr
              ro_f := .t.
              If Len( AllTrim( kart2->mo_pr ) ) < 4
                worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( 'неизв' ), fmt_text )
                s := s + ' ' + ' неизв'
                old_PRIKREP := 'неизв'
              Else
                worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( kart2->mo_pr ), fmt_text )
                s := s + ' ' + kart2->mo_pr
                old_PRIKREP := kart2->mo_pr
              Endif
            Endif
            t_mo_prik := kart2->mo_pr
          Else
            s := s + Space( 7 )
            worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( 'неизв' ), fmt_text )
            old_PRIKREP := 'неизв'
          Endif
          If Left( kart2->PC2, 1 ) == '1'
            s := s + 'УМР'
            ++ru
            ro_f := .t.
            fl_umer := .f.  // отметка пациент умер
            worksheet_write_string( worksheet, row, 6, hb_StrToUTF8( 'УМЕР' ), fmt_text )
            old_PRIKREP := 'УМЕР'
          Else
            s := s + Str( kart->uchast, 3 )
            worksheet_write_string( worksheet, row, 7, hb_StrToUTF8(  Str( kart->uchast, 3 ) ), fmt_text )
            old_num_UCH :=   Str( kart->uchast, 3 )
            fl_umer := .t.  // отметка пациент умер
          Endif
          If m1adres == 1
            sadres := ret_okato_ulica( kart->adres, kart_->okatog, 0, 1 )
          Endif
          ++r
          If !ro_f
            ++ro
          Endif
        Endif
        old_adres := AllTrim( ret_okato_ulica( kart->adres, kart_->okatog, 0, 1 ) )
        worksheet_write_string( worksheet, row, 2, hb_StrToUTF8( old_adres ), fmt_text )
        s += Str( pers->tab_nom, 6 ) + ' ' + dn->kod_diag + ' ' + date_8( dn->lu_data ) + ' ' + date_8( dn->n_data ) + ' ' + date_8( dn->next_data )
        s += iif( dn->next_data < 0d20260101, '___', '   ' )   // ЮЮ
        worksheet_write_string( worksheet, row, 8, hb_StrToUTF8( Str( pers->tab_nom, 6 ) ), fmt_text )
        worksheet_write_string( worksheet, row, 9, hb_StrToUTF8( dn->kod_diag ), fmt_text )
        worksheet_write_string( worksheet, row, 10, hb_StrToUTF8( full_date( dn->lu_data ) ), fmt_text )
        worksheet_write_string( worksheet, row, 11, hb_StrToUTF8( full_date( dn->n_data ) ), fmt_text )
        worksheet_write_string( worksheet, row, 12, hb_StrToUTF8( full_date( dn->next_data ) ), fmt_text )
        worksheet_write_string( worksheet, row, 13, hb_StrToUTF8( lstr( dn->frequency ) ), fmt_text )
        If dn->next_data < 0d20250101
          s += '_____'
        Else
          s += iif( Empty( dn->frequency ), '_____', Str( dn->frequency, 5 ) )
        Endif
        If f_is_diag_dn_neobez( dn->kod_diag )
          s += ' **'
        Endif
        //
        t_vr := Select()
        Select D01D
        fl_prinet := .f.
        otvet  :=  '       '
        // Выборки по отдельным группам ДИАГНОЗОВ
        If old_PRIKREP == ''
          If flag_1 .and. arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dn->kod_diag ) // 109
            arr_DN[ 1, 1 ] ++
            flag_1 := .f.
          Elseif flag_2 .and. arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dn->kod_diag ) // 110
            arr_DN[ 1, 2 ] ++
            flag_2 := .f.
          Elseif flag_3 .and. arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dn->kod_diag ) // 111
            if substr(alltrim(dn->kod_diag),1,3) == 'E10'
              arr_DN[ 1, 5 ] ++
            else  
              arr_DN[ 1, 3 ] ++
            endif
            flag_3 := .f.
          Elseif flag_4 .and. arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dn->kod_diag ) // 112
            arr_DN[ 1, 4 ] ++
            flag_4 := .f.
          Endif
        Endif
        // проверка на принятие
        find( Str( dn->( RecNo() ), 6 ) ) 
        If Found()
          If d01d->OPLATA == 1
            // контрольная проверка 
            // r_use( dir_server() + 'mo_D01',,  'D01' )  // пакеты D01
            // r_use( dir_server() + 'mo_D01K',,  'D01K' ) // пациента в пакете D01
            // r_use( dir_server() + 'mo_D01D',,  'D01D' ) // диагнозы у пациентов в пакете D01
            // Index On Str( FIELD->kod_n, 6 ) + Str( FIELD->kod_d, 7 ) to ( cur_dir() + 'tmp_D01' ) DESCENDING
            select D01K 
            goto (D01D->kod_d)
            select D01
            goto (d01k->REESTR)
            if d01->nyear == 2025 // на 2026 год
              fl_prinet := .t.
              otvet  := 'принят '
              If flag_1_1 .and. arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dn->kod_diag ) // 109
                arr_DN[ 2, 1 ] ++
                flag_1_1 := .f.
              Elseif flag_2_1 .and. arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dn->kod_diag ) // 110
                arr_DN[ 2, 2 ] ++
                flag_2_1 := .f.
              Elseif flag_3_1 .and. arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dn->kod_diag ) // 111
                  arr_DN[ 2, 3 ] ++
                flag_3_1 := .f.
              Elseif flag_4_1 .and. arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dn->kod_diag ) // 112
                arr_DN[ 2, 4 ] ++
                flag_4_1 := .f.
              Else
              Endif
            else
              //otvet  := 'НЕ ПОС.'
            endif  
          Elseif d01d->OPLATA == 0
            otvet  := 'НЕТ ОТВ'
            If flag_1_4 .and. arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dn->kod_diag ) // 109
              arr_DN[ 5, 1 ] ++
              flag_1_4 := .f.
            Elseif flag_2_4 .and. arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dn->kod_diag ) // 110
              arr_DN[ 5, 2 ] ++
              flag_2_4 := .f.
            Elseif flag_3_4 .and. arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dn->kod_diag ) // 111
                arr_DN[ 5, 3 ] ++
              flag_3_4 := .f.
            Elseif flag_4_4 .and. arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dn->kod_diag ) // 112
              arr_DN[ 5, 4 ] ++
              flag_4_4 := .f.
             Endif
          Else
             // { 'REESTR',   'N', 6, 0 }, ; // код реестра;по файлу 'mo_d01'
             // { 'D01_ZAP',  'N', 6, 0 }, ; // номер позиции записи в реестре;'ZAP') в D01
             // { 'KOD_ERR',  'N', 3, 0 }, ; // код ошибки ТК
             // { 'MESTO',    'N', 1, 0 };  // место проведения диспансерного наблюдения: 0 - в МО или 1 - на до
            otvet  := 'ОШИБКА '
            if d01d->OPLATA == 2
              // идем в ошибки
              select D01K 
              goto (D01D->kod_d)
              select D01E 
              find (str(d01k->reestr,6) + str(d01k->d01_zap,6))   
              //index on str( FIELD->reestr, 6 ) + str( FIELD->d01_zap, 6 ) to  ( cur_dir() + 'tmp_D01E' )
              if found()
                otvet  := 'ОШИБКА ' + lstr( D01E->kod_err )
              else
                otvet  := 'ОШИБКА 131' 
              endif
            else
              otvet := otvet+lstr(d01d->OPLATA)
            endif    
            If flag_1_2 .and. arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dn->kod_diag ) // 109
              arr_DN[ 3, 1 ] ++
              flag_1_2 := .f.
            Elseif flag_2_2 .and. arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dn->kod_diag ) // 110
              arr_DN[ 3, 2 ] ++
              flag_2_2 := .f.
            Elseif flag_3_2 .and. arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dn->kod_diag ) // 111
              arr_DN[ 3, 3 ] ++
              flag_3_2 := .f.
            Elseif flag_4_2 .and. arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dn->kod_diag ) // 112
              arr_DN[ 3, 4 ] ++
              flag_4_2 := .f.
            Endif
          Endif
        Else
          otvet  := '       '
        Endif
        
        // Конец ВЫБОРКИ
        Select( t_vr )
        s := padr(otvet,11) + s
        // //
        worksheet_write_string( worksheet, row, 0, hb_StrToUTF8( AllTrim( otvet ) ), fmt_text )
        row++
        // //
        If dn->next_data < 0d20250101  // ЮЮ
          ++rd
        Endif
        If Empty( dn->frequency )
          ++rd1
        Endif
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If m1umer == 1                     //------------------------------------------------------------------------------------
           add_string( s )
           ++iii1
        Else
          If fl_umer
            add_string( s )
            ++iii1
          Endif
        Endif
        old := dn->kod_k
        ++rs
        If !ro_f
          ++rod
        Endif

        // Конец ВЫБОРКИ
      Endif
      Select DN
      Skip
    Enddo
    If !Empty( sadres )
      add_string( '  ' + sadres )
    Endif
    verify_ff( HH, .t., sh )
    If Empty( r )
      add_string( 'Не найдено пациентов по заданному условию' )
    Else
      add_string( '=== Итого пациентов - ' + lstr( r ) + ' чел., итого диагнозов - ' + lstr( rs ) + ' ===' )
      add_string( '=== из них УМЕРЛО   - ' + lstr( ru ) + ' чел., в ТФОМС отправлены не будут ===' )
      add_string( '=== пациентов прикрепленных не к нашему МО - ' + lstr( rpr ) + ' чел. и ТФОМСом вероятно приняты не будут ' )
      add_string( '===                       Прикреплены к нашему МО : ' )
      // всего наших - принято- ошибка - не отправл - нет ответа
      verify_ff( HH, .t., sh )
      add_string('─────────────────┬───────────┬─────────┬───────────┬──────────┬')
      add_string('  Заболевание    │ Пациентов │ Принято │ Вернулось │НЕ получен│')
      add_string('                 │   всего   │  в D01  │ с ошибкой │   ответ  │')
      add_string('─────────────────┴───────────┴─────────┴───────────┴──────────┴') 
      add_string( ' ПРОЧИЕ         ' + PadL(lstr(arr_DN[1,1]),12) + PadL(lstr(arr_DN[2,1]),10)+ PadL(lstr(arr_DN[3,1]),12)+ PadL(lstr(arr_DN[5,1]),12) )
      add_string( ' ОНКО           ' + PadL(lstr(arr_DN[1,2]),12) + PadL(lstr(arr_DN[2,2]),10)+ PadL(lstr(arr_DN[3,2]),12)+ PadL(lstr(arr_DN[5,2]),12) )
      add_string( ' С.ДИАБЕТ - E11 ' + PadL(lstr(arr_DN[1,3]),12) + PadL(lstr(arr_DN[2,3]),10)+ PadL(lstr(arr_DN[3,3]),12)+ PadL(lstr(arr_DN[5,3]),12) )
      add_string( ' БСК            ' + PadL(lstr(arr_DN[1,4]),12) + PadL(lstr(arr_DN[2,4]),10)+ PadL(lstr(arr_DN[3,4]),12)+ PadL(lstr(arr_DN[5,4]),12) )
      //
      add_string( '** Обоснованность постановки на ДН с такими диагнозами необходимо проверить врачу, т.к. ' )
      add_string( 'данный диагноз не является строго обязательным для постановки на Диспансерное наблюдение' )
    Endif
    Close databases
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, 3 )
    workbook_close( workbook )
    work_with_excel_file( name_fileXLS_full )
  Endif
  RestScreen( buf )
  Return Nil

// 10.12.25 Список диагнозов, обязательных для диспансерного наблюдения
Function spr_disp_nabl()

  Local i, j, s := '', c := '  ', sh := 80, HH := 60, diag1 := {}, buf := save_maxrow(), name_file := cur_dir() + 'diagn_dn.txt'

  f_is_diag_dn(, @diag1,, .f. )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Список диагнозов, обязательных для диспансерного наблюдения на 2026 г.', sh ) )
  add_string( '' )
  For i := 1 To Len( diag1 )
    verify_ff( HH, .t., sh )
    add_string( diag1[ i, 1 ] )
    If Len( diag1[ i ] ) > 1
      s := '  (кроме'
      For j := 2 To Len( diag1[ i ] )
        s += ' ' + diag1[ i, j ]
      Next
      s += ')'
      add_string( s )
    Endif
  Next
  FClose( fp )
  viewtext( name_file,,,, .t.,,, 2 )
  rest_box( buf )
  Return Nil

// 19.12.25 Обмен с ТФОМС информацией по диспансерному наблюдению
Function f_create_d01()

  Local fl := .t., arr, id01 := 0, lspec, lmesto, buf := save_maxrow()

  mywait()
  r_use( dir_server() + 'mo_xml',, 'MO_XML' )
  Index On Str( FIELD->reestr, 6 ) to ( cur_dir() + 'tmp_xml' ) ;
    For DFILE > 0d20251202 .and. tip_in == _XML_FILE_D02 .and. Empty( TIP_OUT ) // ЮЮ
  r_use( dir_server() + 'mo_d01',, 'REES' )
  Index On Str( FIELD->nn, 3 ) to ( cur_dir() + 'tmp_d01' ) For FIELD->nyear == 2025 // ЮЮ

  Go Top
  Do While !Eof()
    // aadd(a_reestr, rees->kod)
    If rees->kol_err < 0
      // fl := func_error(4,'В файле D02 ошибки на уровне файла! Операция запрещена')
    Elseif Empty( rees->answer )
      fl := func_error( 4, 'Файл D02 не был прочитан! Операция запрещена' )
    Else
      Select MO_XML
      find ( Str( rees->kod, 6 ) )
      If Found()
        If Empty( mo_xml->TWORK2 )
          fl := func_error( 4, 'Прервано чтение файла ' + AllTrim( mo_xml->FNAME ) + '! Аннулируйте (Ctrl+F12) и прочитайте снова' )
        Else
          // aadd(arr_rees,rees->kod)
        Endif
      Endif
    Endif
    Select REES
    Skip
  Enddo
  If !fl
    Close databases
    rest_box( buf )
    Return Nil
  Endif
  Select REES
  Set Index To
  g_use( dir_server() + 'mo_d01d',, 'DD' )
  Index On Str( FIELD->kod_d, 6 ) to ( cur_dir() + 'tmp_d01d' )
  g_use( dir_server() + 'mo_d01k',, 'DK' )
  Index On Str( FIELD->reestr, 6 ) to ( cur_dir() + 'tmp_d01k' )
  iii := 0
  Do While .t.
    iii++
    Select DK
    find ( Str( 0, 6 ) ) // если во время создания D01...XML операция не была корректно завершена
    If Found()
      Select DD
      Do While .t.
        find ( Str( dk->( RecNo() ), 6 ) )
        If Found()
          deleterec( .t. )
        Else
          Exit
        Endif
      Enddo
      Select DK
      deleterec( .t. )
    Else
      Exit
    Endif
    If iii % 500 == 0
      Commit
    Endif
  Enddo
  Commit
  // quit
  dbCreate( cur_dir() + 'tmp', { { 'KOD_K', 'N', 7, 0 }, ;
    { 'KOD_DN', 'N', 7, 0 }, ;
    { 'KOD_DIAG', 'C', 5, 0 }, ;
    { 'KOD_T', 'N', 7, 0 } ;
  } )
  Use ( cur_dir() + 'tmp' ) new
  dbCreate( cur_dir() + 'tmp1', { { 'KOD_K', 'N', 7, 0 }, ;
    { 'KOD_DN', 'N', 7, 0 }, ;
    { 'KOD_DIAG', 'C', 5, 0 }, ;
    { 'KOD_T', 'N', 7, 0 } ;
  } )
  Use ( cur_dir() + 'tmp1' ) new
  Select DK
  Set Relation To FIELD->reestr into REES
  Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_d01k' ) For rees->nyear == 2025 // ЮЮ
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'kartote2',, 'KART2' )
  g_use( dir_server() + 'mo_dnab',, 'DN',.T.,.T. )
  Set Relation To FIELD->kod_k into KART
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_dn' ) For kart->kod > 0 .and. dn->next_data > 0d20260101 // временно
  // unique - переходим - одна запись - один диагноз
  Go Top
  Do While !Eof()
    fl := .t.
    Select DK
    find ( Str( dn->kod_k, 7 ) )
    Do While dk->kod_k == dn->kod_k .and. !Eof()
      If dk->oplata < 1 // если oplata = 0 (ответ ещё не получен) // или oplata = 1 (оплачен) - оплачен то-же впускаем было 2
        fl := .f.
      Endif
      Skip
    Enddo
    // 
    //If month(dn->next_data) == 1 .and. year(dn->next_data) == 2025 //правка 20.02.25
      // заплатка
    //  dn->next_data := dn->next_data +31    
    //endif
    // проверяем дату на 25 год
    if dn->next_data > 0d20260101 .and. dn->next_data < 0d20270101 //правка 
        //
    Else
      fl := .f.
    Endif
    // еще один контроль по возрасту
    If fl
      If ( 1 == fvdn_date_r( sys_date, kart->date_r ) .or. 2 == fvdn_date_r( sys_date, kart->date_r ) )
        fl := .f.
      Endif
      If fl
        If kart->date_r < 0d19100101
          fl := .f.
        Endif
      Endif
    Endif
    // еще один контороль по смерти
    If fl
      Select KART2
      Goto dn->kod_k
      If Left( kart2->PC2, 1 ) == '1'
        fl := .f.
      Endif
    Endif
    //
    If fl
      Select TMP
      Append Blank
      tmp->kod_k    := dn->kod_k
      tmp->kod_dn   := dn->( RecNo() )
      tmp->kod_diag := dn->kod_diag
      tmp->kod_t    := tmp->( RecNo() )
    Endif
    Select DN
    Skip
  Enddo
  kart2->( dbCloseArea() )
  // подготовка завершена в разрезе Пациентов
  // Очищаем от уже принятых пациентов/диагнозов
  Select TMP
  Index On Str( FIELD->kod_dn, 7 ) to ( cur_dir() + 'tmp_dnn' )
  r_use( dir_server() + 'mo_d01d',, 'mo_d01d' ) // список диагнозов пациентов
  Go Top
  Do While !Eof()
    If Year( mo_d01d->next_data ) == 2026
      If mo_d01d->kod_n > 0 .and. mo_d01d->oplata == 1 // принятые
        Select TMP
        find ( Str( mo_d01d->kod_n, 7 ) )
        If Found()
          Delete
        Endif
      Endif
    Endif
    Select MO_D01D
    Skip
  Enddo
  // очистим от не нужных
  Select TMP
  Pack
  // очищаем от дублей по диагнозу
  Select TMP
  Index On Str( FIELD->kod_k, 7 ) + PadR( AllTrim( FIELD->kod_diag ), 3 ) to ( cur_dir() + 'tmp_dnn' ) unique //21.01.25 уникальность на 3 знака в человеке
  Go Top
  Do While !Eof()
    If f_is_diag_dn( tmp->kod_diag,,, .f. ) .or. PadR( AllTrim( tmp->kod_diag ), 3 ) == 'E10'// только диагнозы из последнего списка от 21 ноября + E10
      Select TMP1
      Append Blank
      tmp1->KOD_K    := tmp->KOD_K
      tmp1->KOD_DN   := tmp->KOD_DN
      tmp1->KOD_DIAG := tmp->KOD_DIAG
      tmp1->KOD_T    := tmp->KOD_T
    Endif
    Select TMP
    Skip
  Enddo
  Select TMP
  Set Index To
  Zap
  Select TMP1
  Index On Str( FIELD->kod_t, 7 ) to ( cur_dir() + 'tmp_dnn' )
  Go Top
  Do While !Eof()
    Select TMP
    Append Blank
    tmp->KOD_K    := tmp1->KOD_K
    tmp->KOD_DN   := tmp1->KOD_DN
    tmp->KOD_DIAG := tmp1->KOD_DIAG
    tmp->KOD_T    := tmp1->KOD_T
    Select TMP1
    Skip
  Enddo
  //
//quit
  //
  If tmp->( LastRec() ) == 0
    func_error( 4, 'Не обнаружено пациентов, состоящих под дисп.наблюдением, ещё не отправленных в ТФОМС' )
  Else
   /* Select DK
    Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_d01k' )
    r_use( dir_server() + 'mo_pers',, 'PERSO' )
    Select DN
    Set Relation To FIELD->vrach into PERSO
    Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_dn' )
    Select TMP
    Go Top
    Do While !Eof()
      arr := {} ; lmesto := 0
      Select DN
      find ( Str( tmp->kod_k, 7 ) )
      Do While dn->kod_k == tmp->kod_k .and. !Eof()
        If f_is_diag_dn( dn->kod_diag,,, .f. ) .or. padr(alltrim(dn->kod_diag),3) == 'E10'// только диагнозы из последнего списка от 21 ноября + E10
          If dn->next_data > SToD( '20231231' )   // 11.12.2023
            lspec := ret_prvs_v021( iif( Empty( perso->prvs_new ), perso->prvs, -perso->prvs_new ) )
            AAdd( arr, { lspec, dn->kod_diag, dn->n_data, BoM( dn->next_data ), dn->FREQUENCY } )
            i := Len( arr )
            If Empty( arr[ i, 4 ] ) .or. !Between( arr[ i, 4 ], 0d20210101, 0d20250101 ) // ЮЮ
              arr[ i, 4 ] := 0d20230101  // ЮЮ
            Endif
            If !Between( arr[ i, 5 ], 1, 36 )
              arr[ i, 5 ] := 3
            Endif
            If dn->mesto == 1
              lmesto := 1
            Endif
          Endif
        Endif
        Select DN
        Skip
      Enddo
      ar1 := {} ; ar2 := {}
      For i := 1 To Len( arr )
        fl := .t.
        If AScan( ar1, Left( arr[ i, 2 ], 3 ) ) == 0
          AAdd( ar1, Left( arr[ i, 2 ], 3 ) )
        Else
          fl := .f.
        Endif
        If fl
          AAdd( ar2, arr[ i ] )
        Endif
      Next i
      */
    Select DK
    Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_d01k' )
    r_use( dir_server() + 'mo_pers',, 'PERSO' )
    Select DN
    Set Relation To FIELD->vrach into PERSO
    Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_dn' )
    Select TMP
    Go Top
    tmp_kod_k := 0
    kol_kod_k := 0
    Do While !Eof()
      arr := {}
      lmesto := 0
      Select DN
      Goto ( tmp->kod_dn )
      If dn->next_data > SToD( '20260101' )   // 05.12.2025
        lspec := ret_prvs_v021( iif( Empty( perso->prvs_new ), perso->prvs, -perso->prvs_new ) )
        If Empty( dn->next_data ) .or. !Between( dn->next_data, 0d20260101, 0d20270101 )
          tnext_data := 0d20260201
        Else
          tnext_data := dn->next_data
        Endif
        If !Between( dn->FREQUENCY, 1, 36 )
          tFREQUENCY := 3
        Else
          tFREQUENCY := dn->FREQUENCY
        Endif
        If dn->mesto == 1
          lmesto := 1
        Endif
        //
        If tmp_kod_k != tmp->kod_k
          tmp_kod_k := tmp->kod_k
          kol_kod_k++
        Endif
        //
        Select DK
        addrec( 7 )
        dk->REESTR  := 0                     // код реестра по файлу 'mo_d01'
        dk->KOD_K   := tmp->kod_k            // код по картотеке
        dk->D01_ZAP := ++id01                // номер позиции записи в реестре;'ZAP' в D01
        dk->ID_PAC  := mo_guid( 1, tmp->kod_k ) // GUID пациента в D01 (создается при добавлении записи)
        dk->MESTO   := lmesto                // место проведения диспансерного наблюдения: 0 - в МО или 1 - на дому
        dk->OPLATA  := 0                     // тип оплаты: сначала 0, затем из ТФОМС 1,2,3,4
        Select DD
        addrec( 6 )
        dd->KOD_D     := dk->( RecNo() ) // код (номер записи) по файлу 'mo_d01k'
        dd->PRVS      := lspec  // ar2[ i, 1 ]     // Специальность врача по справочнику V021
        dd->KOD_DIAG  := dn->kod_diag   // ar2[ i, 2 ]      // диагноз заболевания, по поводу которого пациент подлежит диспансерному наблюдению
        dd->N_DATA    := dn->n_data     // ar2[ i, 3 ]      // дата начала диспансерного наблюдения
        dd->NEXT_DATA := tnext_data  // ar2[ i, 4 ]      // дата явки с целью диспансерного наблюдения
        dd->FREQUENCY := tFREQUENCY     // ar2[ i, 5 ]
        dd->KOD_N     := tmp->kod_dn    // код диспансерного наблюдения
        dd->oplata    := 0
        If id01 % 500 == 0
          Commit
        Endif
      Endif
      Select TMP
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  //
  If id01 > 0 .and. f_esc_enter( 'создания D01 (' + lstr( kol_kod_k ) + ' пац-ов)', .t. ) // ПРАВКА
    mywait()
    inn := 0 ; nsh := 3
    g_use( dir_server() + 'mo_d01',, 'REES' )
    Index On Str( FIELD->nn, 3 ) to ( cur_dir() + 'tmp_d01' ) For FIELD->nyear == 2025 // ЮЮ
    Go Top
    Do While !Eof()
      inn := rees->nn
      Skip
    Enddo
    Set Index To
    r_use( dir_server() + 'kartote2',, 'KART2' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    g_use( dir_server() + 'mo_xml',, 'MO_XML' )
    smsg := 'Составление файла D01...'
    stat_msg( smsg )
    Select REES
    addrecn()
    rees->KOD    := RecNo()
    rees->DSCHET := sys_date
    rees->NYEAR  := 2025 // ЮЮ
    rees->MM     := 12
    rees->NN     := inn + 1
    s := 'D01' + 'T34M' + glob_mo()[ _MO_KOD_TFOMS ] + '_2512' + StrZero( rees->NN, nsh ) // ЮЮ
    rees->NAME_XML := s
    mkod_reestr := rees->KOD
    //
    Select MO_XML
    addrecn()
    mo_xml->KOD    := RecNo()
    mo_xml->FNAME  := s
    mo_xml->FNAME2 := ''
    mo_xml->DFILE  := rees->DSCHET
    mo_xml->TFILE  := hour_min( Seconds() )
    mo_xml->TIP_IN := 0
    mo_xml->TIP_OUT := _XML_FILE_D01  // тип высылаемого файла - D01
    mo_xml->REESTR := mkod_reestr
    mo_xml->DWORK := sys_date
    mo_xml->TWORK1 := hour_min( Seconds() )
    //
    rees->KOD_XML := mo_xml->KOD
    Unlock
    Commit
    pkol := 0
    g_use( dir_server() + 'mo_d01d', cur_dir() + 'tmp_d01d', 'DD' )
    g_use( dir_server() + 'mo_d01k',, 'RHUM' )
    Index On Str( FIELD->REESTR, 6 ) + Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' )
    Do While .t.
      find ( Str( 0, 6 ) )
      If Found()
        ++pkol
        @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
        //
        g_rlock( forever )
        rhum->REESTR := mkod_reestr
        If pkol % 2000 == 0
          dbUnlockAll()
          dbCommitAll()
        Endif
      Else
        Exit
      Endif
    Enddo
    Select REES
    g_rlock( forever )
    rees->KOL := pkol
    rees->KOL_ERR := 0
    dbUnlockAll()
    dbCommitAll()
    //
    stat_msg( smsg )
    //
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
    mo_add_xml_stroke( oXmlNode, 'VERSION', '1.0' )
    mo_add_xml_stroke( oXmlNode, 'CODE_MO', glob_mo()[ _MO_KOD_FFOMS ] )
    mo_add_xml_stroke( oXmlNode, 'CODEM', glob_mo()[ _MO_KOD_TFOMS ] )
    mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( mo_xml->DFILE ) )
    mo_add_xml_stroke( oXmlNode, 'NAME_F', mo_xml->FNAME )
    mo_add_xml_stroke( oXmlNode, 'SMO', '34' )
    mo_add_xml_stroke( oXmlNode, 'YEAR', lstr( rees->NYEAR ) )
    mo_add_xml_stroke( oXmlNode, 'MONTH', lstr( rees->MM ) )
    mo_add_xml_stroke( oXmlNode, 'N_PACK', lstr( rees->NN ) )
    //
    Select RHUM
    Set Relation To FIELD->kod_k into KART, To FIELD->kod_k into KART_, To FIELD->kod_k into KART2
    Index On Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->REESTR == mkod_reestr
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( rhum->D01_ZAP / pkol * 100, 6, 2 ) + '%' Color cColorSt2Msg
      arr_fio := retfamimot( 1, .f. )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'PERSONS' ) )
      mo_add_xml_stroke( oXmlNode, 'ZAP', lstr( rhum->D01_ZAP ) )
      mo_add_xml_stroke( oXmlNode, 'IDPAC', rhum->ID_PAC )
      mo_add_xml_stroke( oXmlNode, 'SURNAME', arr_fio[ 1 ] )
      mo_add_xml_stroke( oXmlNode, 'NAME', arr_fio[ 2 ] )
      If !Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oXmlNode, 'PATRONYMIC', arr_fio[ 3 ] )
      Endif
      mo_add_xml_stroke( oXmlNode, 'BIRTHDAY', date2xml( kart->date_r ) )
      mo_add_xml_stroke( oXmlNode, 'SEX', iif( kart->pol == 'М', '1', '2' ) )
      If !Empty( kart->snils )
//        mo_add_xml_stroke( oXmlNode, 'SS', Transform( kart->SNILS, picture_pf ) )
        mo_add_xml_stroke( oXmlNode, 'SS', Transform_SNILS( kart->SNILS ) )
      Endif
      // проверим наличие ЕНП - иначе старый вариант
      If Len( AllTrim( kart2->KOD_MIS ) ) > 14
        mo_add_xml_stroke( oXmlNode, 'TYPE_P', lstr( 3 ) ) // только НОВЫЙ
        s := AllTrim( kart2->KOD_MIS )
        s := PadR( s, 16, '0' )
        //
        mo_add_xml_stroke( oXmlNode, 'NUM_P', s )
        mo_add_xml_stroke( oXmlNode, 'ENP', s )
      Else
        mo_add_xml_stroke( oXmlNode, 'TYPE_P', lstr( iif( Between( kart_->VPOLIS, 1, 3 ), kart_->VPOLIS, 1 ) ) )
        If !Empty( kart_->SPOLIS )
          mo_add_xml_stroke( oXmlNode, 'SER_P', kart_->SPOLIS )
        Endif
        s := AllTrim( kart_->NPOLIS )
        If kart_->VPOLIS == 3 .and. Len( s ) != 16
          s := PadR( s, 16, '0' )
        Endif
        //
        mo_add_xml_stroke( oXmlNode, 'NUM_P', s )
        If kart_->VPOLIS == 3
          mo_add_xml_stroke( oXmlNode, 'ENP', s )
        Endif
      Endif
      mo_add_xml_stroke( oXmlNode, 'DOCTYPE', lstr( kart_->vid_ud ) )
      If !Empty( kart_->ser_ud )
        mo_add_xml_stroke( oXmlNode, 'DOCSER', kart_->ser_ud )
      Endif
      mo_add_xml_stroke( oXmlNode, 'DOCNUM', kart_->nom_ud )
      If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
        mo_add_xml_stroke( oXmlNode, 'MR', smr )
      Endif
      mo_add_xml_stroke( oXmlNode, 'PLACE', lstr( rhum->mesto ) )
      oCONTACTS := oXmlNode:add( hxmlnode():new( 'CONTACTS' ) )
      If !Empty( kart_->PHONE_H )
        mo_add_xml_stroke( oCONTACTS, 'TEL_F', Left( kart_->PHONE_H, 1 ) + '-' + SubStr( kart_->PHONE_H, 2, 4 ) + '-' + SubStr( kart_->PHONE_H, 6 ) )
      Endif
      If !Empty( kart_->PHONE_M )
        mo_add_xml_stroke( oCONTACTS, 'TEL_M', Left( kart_->PHONE_M, 1 ) + '-' + SubStr( kart_->PHONE_M, 2, 3 ) + '-' + SubStr( kart_->PHONE_M, 5 ) )
      Endif
      oADDRESS := oCONTACTS:add( hxmlnode():new( 'ADDRESS' ) )
      s := '18000'
      If Len( AllTrim( kart_->okatop ) ) == 11
        s := Left( kart_->okatop, 5 )
      Elseif Len( AllTrim( kart_->okatog ) ) == 11
        s := Left( kart_->okatog, 5 )
      Endif
      mo_add_xml_stroke( oADDRESS, 'SUBJ', s )
      If !Empty( kart->adres )
        mo_add_xml_stroke( oADDRESS, 'UL', kart->adres )
      Endif
      arr := {}
      Select DD
      find ( Str( rhum->( RecNo() ), 6 ) )
      Do While dd->kod_d == rhum->( RecNo() ) .and. !Eof()
        If ( i := AScan( arr, {| x| x[ 1 ] == dd->prvs } ) ) == 0
          AAdd( arr, { dd->prvs, {} } ) ; i := Len( arr )
        Endif
        AAdd( arr[ i, 2 ], { dd->KOD_DIAG, dd->N_DATA, dd->NEXT_DATA, dd->FREQUENCY } )
        Skip
      Enddo
      oSPECs := oXmlNode:add( hxmlnode():new( 'SPECIALISATIONS' ) )
      For i := 1 To Len( arr )
        oSPEC := oSPECs:add( hxmlnode():new( 'SPECIALISATION' ) )
        mo_add_xml_stroke( oSPEC, 'SPECIALIST', lstr( arr[ i, 1 ] ) )
        oREASONS := oSPEC:add( hxmlnode():new( 'REASONS' ) )
        For j := 1 To Len( arr[ i, 2 ] )
          oREASON := oREASONS:add( hxmlnode():new( 'REASON' ) )
          mo_add_xml_stroke( oREASON, 'DS', arr[ i, 2, j, 1 ] )
          mo_add_xml_stroke( oREASON, 'DATE_B', date2xml( arr[ i, 2, j, 2 ] ) )
          mo_add_xml_stroke( oREASON, 'DATE_VISIT', date2xml( arr[ i, 2, j, 3 ] ) )
          mo_add_xml_stroke( oREASON, 'FREQUENCY', lstr( arr[ i, 2, j, 4 ] ) )
        Next j
      Next i
      Select RHUM
      Skip
    Enddo
    stat_msg( 'Запись XML-файла' )
    oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml() )
    chip_create_zipxml( AllTrim( mo_xml->FNAME ) + szip(), { AllTrim( mo_xml->FNAME ) + sxml() }, .t. )
    mo_xml->( g_rlock( forever ) )
    mo_xml->TWORK2 := hour_min( Seconds() )
    Close databases
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
    rest_box( buf )
  Endif
  Return Nil

// 05.12.25 Обмен с ТФОМС информацией по диспансерному наблюдению
Function f_view_d01()

  Local i, k, buf := SaveScreen()
  Private goal_dir := dir_server() + dir_XML_MO() + hb_ps()

  g_use( dir_server() + 'mo_xml',, 'MO_XML' )
  g_use( dir_server() + 'mo_d01',, 'REES' )
  Index On Descend( StrZero( FIELD->nn, 3 ) ) to ( cur_dir() + 'tmp_rees' ) For FIELD->nyear == 2025 // ЮЮ
  Go Top
  If Eof()
    func_error( 4, 'Не было создано файлов D01... для 2026 года' ) // ЮЮ
  Else
    Private reg := 1
    alpha_browse( T_ROW, 2, MaxRow() -2, 77, 'f1_view_D01', color0,,,,,,, ;
      'f2_view_D01',, { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R', .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )
  Return Nil

// 29.11.18
Function f1_view_d01( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() ), ;
    iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( ' №№', {|| Str( rees->nn, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Дата', {|| date_8( rees->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол-во;диаг-ов', {|| Str( rees->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Кол-во; ошибок', {|| iif( rees->kol_err < 0, 'в файле', put_val( rees->kol_err, 7 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'От-;вет', {|| iif( rees->answer == 1, 'да ', 'нет' ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Наименование файла', {|| PadR( rees->NAME_XML, 21 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Примечание', {|| f11_view_d01() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If reg == 1
    status_key( '^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о файле' )
  Else
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата' )
  Endif
  Return Nil

// 03.12.18
Static Function f11_view_d01()

  Local s := ''

  If rees->kod_xml > 0
    mo_xml->( dbGoto( rees->kod_xml ) )
    If Empty( mo_xml->twork2 )
      s := 'НЕ СОЗДАН'
    Endif
  Endif
  If Empty( s )
    If !hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() )
      s := 'нет файла'
    Elseif Empty( rees->date_out )
      s := 'не записан'
    Else
      s := 'зап. ' + lstr( rees->NUMB_OUT ) + ' раз'
    Endif
  Endif
  Return PadR( s, 10 )

// 03.12.18
Function f2_view_d01( nKey, oBrow )

  Local ret := -1, rec := rees->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr := {}, i := 1, k, mdate, t_arr[ 2 ], arr_pmt := {}
  local smsg, cFileProtokol

  Do Case
  Case nKey == K_F5
    mdate := rees->dschet
    AAdd( arr, { rees->name_xml, rees->kod_xml, rees->( RecNo() ) } )
    s := 'Записывается файл ' + AllTrim( arr[ i, 1 ] ) + szip() + '.'
    perenos( t_arr, s, 74 )
    f_message( t_arr,, color1, color8 )
    If f_esc_enter( 'записи файла D01' )
      Private p_var_manager := 'copy_schet'
      s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // 'norton' для выбора каталога
      If !Empty( s )
        If Upper( s ) == Upper( goal_dir )
          func_error( 4, 'Вы выбрали каталог, в котором уже записан целевой файл! Это недопустимо.' )
        Else
          cFileProtokol := cur_dir() + 'prot_sch.txt'
          StrFile( hb_eol() + Center( glob_mo()[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
          smsg := 'Файл D01 записан на: ' + s + ' (' + full_date( sys_date ) + 'г. ' + hour_min( Seconds() ) + ')'
          StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
          k := 0
          For i := 1 To Len( arr )
            zip_file := AllTrim( arr[ i, 1 ] ) + szip()
            If hb_FileExists( goal_dir + zip_file )
              mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
              // copy file (goal_dir + zip_file) to (hb_OemToAnsi(s) + zip_file)
              Copy File ( goal_dir + zip_file ) to ( s + zip_file )
              // if hb_fileExists(hb_OemToAnsi(s) + zip_file)
              If hb_FileExists( s + zip_file )
                ++k
                rees->( dbGoto( arr[ i, 3 ] ) )
                smsg := 'Пакет D01 № ' + lstr( rees->nn ) + ' от ' + date_8( mdate ) + 'г. ' + AllTrim( rees->name_xml ) + szip()
                StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                smsg := '   количество пациентов - ' + lstr( rees->kol )
                StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                rees->( g_rlock( forever ) )
                rees->DATE_OUT := sys_date
                If rees->NUMB_OUT < 99
                  rees->NUMB_OUT++
                Endif
                //
                mo_xml->( dbGoto( arr[ i, 2 ] ) )
                mo_xml->( g_rlock( forever ) )
                mo_xml->DREAD := sys_date
                mo_xml->TREAD := hour_min( Seconds() )
              Else
                smsg := '! Ошибка записи файла ' + s + zip_file
                func_error( 4, smsg )
                StrFile( smsg + hb_eol(), cFileProtokol, .t. )
              Endif
            Else
              smsg := '! Не обнаружен файл ' + goal_dir + zip_file
              func_error( 4, smsg )
              StrFile( smsg + hb_eol(), cFileProtokol, .t. )
            Endif
          Next i
          Unlock
          Commit
          viewtext( cFileProtokol,,,, .t.,,, 2 )
        Endif
      Endif
    Endif
    Select REES
    Goto ( rec )
    ret := 0
  Case nKey == K_F3
    f3_view_d01( oBrow )
    ret := 0
  Case nKey == K_CTRL_F12
    If rees->ANSWER == 0
      mo_xml->( dbGoto( rees->kod_xml ) )
      If Empty( mo_xml->twork2 )
        ret := delete_reestr_d01( rees->( RecNo() ) )
      Else
        func_error( 4, 'Файл ' + AllTrim( rees->NAME_XML ) + sxml() + ' создан корректно. Аннулирование запрещено!' )
      Endif
    Else
      ret := delete_reestr_d02( rees->( RecNo() ), AllTrim( rees->NAME_XML ) )
    Endif
    Close databases
    g_use( dir_server() + 'mo_xml',, 'MO_XML' )
    g_use( dir_server() + 'mo_d01', cur_dir() + 'tmp_rees', 'REES' )
    If ret != 1
      Goto ( rec )
    Endif
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )
  Return ret

// 18.01.25
Function f3_view_d01( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), fl, s, ;
    mm_func := { -99 }, ;
    mm_menu := { 'Список ~всех пациентов из D01' }
 
  mywait()
  Select MO_XML
  Index On FIELD->FNAME to ( cur_dir() + 'tmp_xml' ) ;
    For reestr == rees->kod .and. tip_in == _XML_FILE_D02 .and. Empty( TIP_OUT )
  Go Top
  Do While !Eof()
    AAdd( mm_func, -1 )
    AAdd( mm_menu, '1-установлена страх.принадлежность, подтверждено прикрепление к МО' )
    AAdd( mm_func, -2 )
    AAdd( mm_menu, '2-присутствуют ошибки технологического контроля' )
    AAdd( mm_func, -3 )
    AAdd( mm_menu, '3-не установлена страховая принадлежность' )
    AAdd( mm_func, -4 )
    AAdd( mm_menu, '4-не установлена страх.принадлежность, не подтверждено прикрепление к МО' )
    s := 'Протокол чтения ' + RTrim( mo_xml->FNAME ) + ' прочитан ' + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      s += '-ПРОЦЕСС НЕ ЗАВЕРШЁН'
    Else
      s += ' в ' + mo_xml->TWORK1
    Endif
    AAdd( mm_func, mo_xml->kod )
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  If r <= 12
    r1 := r + 1
    r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r -1
    r1 := r2 - Len( mm_menu ) -1
  Endif
  rest_box( buf )
  If Len( mm_menu ) == 1
    i := 1
    si := i
    If mm_func[ i ] < 0
      f31_view_d01( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Endif
  Elseif ( i := popup_prompt( r1, 10, si, mm_menu,,, color5 ) ) > 0
    si := i
    If mm_func[ i ] < 0
      f31_view_d01( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Else
      mo_xml->( dbGoto( mm_func[ i ] ) )
      viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + AllTrim( mo_xml->FNAME ) + stxt(), 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif
  Select REES
  Return Nil

// 19.01.25
Function  f31_view_d01( reg, s )

  Local fl := .t., buf := save_maxrow(), k := 0, n_file := cur_dir() + 'D01_spis.txt'
  Local t_kod := 0, arr_DN[ 4 ],  flag_1 := .t.,  flag_2 := .t.,  flag_3 := .t.,   flag_4 := .t.
  Local arr_tip_KOD_USL := { 109, 110, 111, 112 }, kn := 0

  mywait()
  arr_DN := {0,0,0,0}
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( '' )
  add_string( Center( 'Список пациентов файла ' + AllTrim( rees->NAME_XML ) + ' от ' + date_8( rees->dschet ), 80 ) )
  If reg == 99
    s := 'все пациенты'
  Endif
  add_string( Center( '[ ' + s + ' ]', 80 ) )
  add_string( '' )
  r_use( dir_server() + 'mo_d01d',, 'DD' )
  Index On Str( FIELD->kod_d, 6 ) to ( cur_dir() + 'tmp_dd' )
  r_use( dir_server() + 'kartote2',, 'KART2' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'mo_d01k',, 'RHUM' )
  Set Relation To FIELD->kod_k into KART
  Index On Str( rhum->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == rees->kod
  Go Top
  Do While !Eof()
    If iif( reg == 99, .t., rhum->OPLATA == reg )
      // добавить фильтр по реестру
      If rhum->reestr == rees->kod // 19.12.2020
        ++kn
        s := Str( rhum->D01_ZAP, 5 ) + '. '
        If Empty( kart->fio )
          s += 'удалён дубликат в картотеке (код=' + lstr( kod_k ) + ')'
        Else
          s += PadR( Upper( kart->fio ), 35 ) + ' ' + full_date( kart->date_r )
          select kart2
          goto(kart->kod)
          s += '  '+AllTrim( kart2->KOD_MIS )
        Endif
        s += ' ('
        Select DD
        find ( Str( rhum->( RecNo() ), 6 ) )
        Do While dd->kod_d == rhum->( RecNo() ) .and. !Eof()
          s += ' ' + AllTrim( dd->kod_diag ) + f300_view_d01( dd->kod_diag )
          if t_kod == rhum->kod_k
            If flag_1 .and. arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dd->kod_diag )     // 109
              arr_DN[ 1 ] ++
              flag_1 := .f.
            Elseif flag_2 .and. arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dd->kod_diag ) // 110
              arr_DN[ 2 ] ++
              flag_2 := .f.
            Elseif flag_3 .and. arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dd->kod_diag ) // 111
              arr_DN[ 3 ] ++
              flag_3 := .f.
            Elseif  flag_4 .and. arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dd->kod_diag ) // 112
              arr_DN[ 4 ] ++
              flag_4 := .f.
            Endif
          else // первая запись ФИО в файле 
            flag_1 := flag_2 := flag_3 :=  flag_4 := .t.
            If arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dd->kod_diag ) // 109
              arr_DN[ 1 ] ++
              flag_1 := .f.
            Elseif arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dd->kod_diag ) // 110
              arr_DN[ 2 ] ++
              flag_2 := .f.
            Elseif arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dd->kod_diag ) // 111
              arr_DN[ 3 ] ++
              flag_3 := .f.
            Elseif  arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dd->kod_diag ) // 112
              arr_DN[ 4 ] ++
              flag_4 := .f.
            Endif
            t_kod := rhum->kod_k
            ++k
          endif  
          Skip
        Enddo
        s += ' )' // + str(kart->kod)
         //
        verify_ff( 60, .t., 80 )
        add_string( s )
      Endif
    Endif
    Select RHUM
    Skip
  Enddo
  add_string( '' )
  add_string( 'Всего       ' + lstr( kn ) + ' диагнозов.' )
  add_string( 'Всего       ' + lstr( k ) + ' чел.' )
  add_string( '  из них ПРОЧИЕ ' + lstr( arr_DN[ 1 ]  ) + ' чел.' )
  add_string( '         ОНКО   ' + lstr( arr_DN[ 2 ]  ) + ' чел.' )
  add_string( '    САХ.ДИАБЕТ  ' + lstr( arr_DN[ 3 ]  ) + ' чел.' )
  add_string( '         БСК    ' + lstr( arr_DN[ 4 ]  ) + ' чел.' )
  kart->( dbCloseArea() )
  kart2->( dbCloseArea() )
  rhum->( dbCloseArea() )
  dd->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 3 )
  Return Nil

// 19.01.25 
Function f300_view_d01( diag )

Local arr_tip_KOD_USL := { 109, 110, 111, 112 }
Local arr_tip_TIP_DN := { 'ПРОЧ', 'ОНКО', 'ДИАБ', 'БСК' } 

if arr_tip_KOD_USL[ 1 ] == check_tip_disp_nabl( dd->kod_diag ) // 109
  return  ' ['+arr_tip_TIP_DN[1]+']' 
elseif  arr_tip_KOD_USL[ 2 ] == check_tip_disp_nabl( dd->kod_diag ) // 110 
  return ' ['+arr_tip_TIP_DN[2]+']'  
elseif  arr_tip_KOD_USL[ 3 ] == check_tip_disp_nabl( dd->kod_diag ) // 111 
  return  ' ['+arr_tip_TIP_DN[3]+']'  
elseif  arr_tip_KOD_USL[ 4 ] == check_tip_disp_nabl( dd->kod_diag ) // 112 
  return ' ['+arr_tip_TIP_DN[4]+']'  
endif 
return ' '

// 03.12.19 зачитать D01 во временные файлы
Function reestr_d01_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ''
  stat_msg( 'Распаковка/чтение/анализ файла ' + mname_xml )
  dbCreate( cur_dir() + 'tmp4file', { ;
    { 'ZAP',        'N',  6, 0 }, ;
    { 'IDPAC',      'C', 36, 0 }, ;
    { 'SURNAME',    'C', 40, 0 }, ;
    { 'NAME',       'C', 40, 0 }, ;
    { 'PATRONYMIC', 'C', 40, 0 }, ;
    { 'BIRTHDAY',   'C', 10, 0 }, ;
    { 'SEX',        'C',  1, 0 }, ;
    { 'SS',         'C', 14, 0 }, ;
    { 'TYPE_P',     'C',  1, 0 }, ;
    { 'SER_P',      'C', 10, 0 }, ;
    { 'NUM_P',      'C', 20, 0 }, ;
    { 'ENP',        'C', 16, 0 }, ;
    { 'DOCTYPE',    'C',  2, 0 }, ;
    { 'DOCSER',     'C', 10, 0 }, ;
    { 'DOCNUM',     'C', 20, 0 }, ;
    { 'MR',         'C', 100, 0 }, ;
    { 'PLACE',      'C',  1, 0 }, ;
    { 'TEL_F',      'C', 13, 0 }, ;
    { 'TEL_M',      'C', 13, 0 }, ;
    { 'SUBJ',       'C',  5, 0 }, ;
    { 'UL',         'C', 120, 0 }, ;
    { 'kod_k',      'N',  7, 0 }, ;
    { 'OPLATA',     'N',  1, 0 };
  } )
  dbCreate( cur_dir() + 'tmp5file', { ;
    { 'ZAP',        'N',  6, 0 }, ;
    { 'PRVS',   'C',  4, 0 }, ;
    { 'DS',   'C',  5, 0 }, ;
    { 'DATE_B',   'C', 10, 0 }, ;
    { 'DATE_VIZIT', 'C', 10, 0 }, ;
    { 'FREQUENCY',  'N',  2, 0 };
  } )
  Use ( cur_dir() + 'tmp4file' ) New Alias TMP2
  Use ( cur_dir() + 'tmp5file' ) New Alias TMP5
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    If 'PERSONS' == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->ZAP       := Val( mo_read_xml_stroke( oXmlNode, 'ZAP', aerr ) )
      tmp2->IDPAC     :=     mo_read_xml_stroke( oXmlNode, 'IDPAC', aerr, .f. )
      tmp2->SURNAME   :=     mo_read_xml_stroke( oXmlNode, 'SURNAME', aerr, .f. )
      tmp2->NAME      :=     mo_read_xml_stroke( oXmlNode, 'NAME', aerr, .f. )
      tmp2->PATRONYMIC :=     mo_read_xml_stroke( oXmlNode, 'PATRONYMIC', aerr, .f. )
      tmp2->BIRTHDAY  :=     mo_read_xml_stroke( oXmlNode, 'BIRTHDAY', aerr, .f. )
      tmp2->SEX       :=     mo_read_xml_stroke( oXmlNode, 'SEX', aerr, .f. )
      tmp2->SS        :=     mo_read_xml_stroke( oXmlNode, 'SS', aerr, .f. )
      tmp2->TYPE_P    :=     mo_read_xml_stroke( oXmlNode, 'TYPE_P', aerr, .f. )
      tmp2->SER_P     :=     mo_read_xml_stroke( oXmlNode, 'SER_P', aerr, .f. )
      tmp2->NUM_P     :=     mo_read_xml_stroke( oXmlNode, 'NUM_P', aerr, .f. )
      tmp2->ENP       :=     mo_read_xml_stroke( oXmlNode, 'ENP', aerr, .f. )
      tmp2->DOCTYPE   :=     mo_read_xml_stroke( oXmlNode, 'DOCTYPE', aerr, .f. )
      tmp2->DOCSER    :=     mo_read_xml_stroke( oXmlNode, 'DOCSER', aerr, .f. )
      tmp2->DOCNUM    :=     mo_read_xml_stroke( oXmlNode, 'DOCNUM', aerr, .f. )
      tmp2->MR        :=     mo_read_xml_stroke( oXmlNode, 'MR', aerr, .f. )
      tmp2->PLACE     :=     mo_read_xml_stroke( oXmlNode, 'PLACE', aerr, .f. )
      If ( oNode1 := oXmlNode:find( 'CONTACTS' ) ) != NIL
        tmp2->TEL_F   :=     mo_read_xml_stroke( oNode1, 'TEL_F', aerr, .f. )
        tmp2->TEL_M   :=     mo_read_xml_stroke( oNode1, 'TEL_M', aerr, .f. )
        If ( oNode2 := oNode1:find( 'ADDRESS' ) ) != NIL
          tmp2->SUBJ  :=     mo_read_xml_stroke( oNode2, 'SUBJ', aerr, .f. )
          tmp2->UL    :=     mo_read_xml_stroke( oNode2, 'UL', aerr, .f. )
        Endif
      Endif
      If ( oNode1 := oXmlNode:find( 'SPECIALISATIONS' ) ) != NIL
        _ar := mo_read_xml_array( oNode1, 'SPECIALISATION' )
        For j1 := 1 To Len( _ar )
          lprvs := mo_read_xml_stroke( oNode1, 'SPECIALIST', aerr, .f. )
          If ( oNode2 := oXmlNode:find( 'REASONS' ) ) != NIL
            _ar2 := mo_read_xml_array( oNode2, 'REASON' )
            For j2 := 1 To Len( _ar2 )
              Select TMP5
              Append Blank
              tmp5->N_ZAP := tmp2->_N_ZAP
              tmp5->PRVS := lprvs
              tmp5->DS := mo_read_xml_stroke( oNode2, 'DS', aerr, .f. )
              tmp5->DATE_B := mo_read_xml_stroke( oNode2, 'DATE_B', aerr, .f. )
              tmp5->DATE_VISIT := mo_read_xml_stroke( oNode2, 'DATE_VISIT', aerr, .f. )
              tmp5->FREQUENCY := Val( mo_read_xml_stroke( oNode2, 'FREQUENCY', aerr, .f. ) )
            Next j2
          Endif
        Next j1
      Endif
    Endif
  Next j
  tmp2->( dbCloseArea() )
  tmp5->( dbCloseArea() )
  rest_box( buf )
  Return Nil

// 27.11.18 зачитать D02 во временные файлы
Function reestr_d02_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ''
  stat_msg( 'Распаковка/чтение/анализ файла ' + mname_xml )
  dbCreate( cur_dir() + 'tmp1file', { ;
    { '_VERSION',   'C',  5, 0 }, ;
    { '_DATE_F',    'D',  8, 0 }, ;
    { '_NAME_F',    'C', 26, 0 }, ;
    { '_NAME_FE',   'C', 26, 0 }, ;
    { 'KOL',        'N',  6, 0 }, ; // количество пациентов в реестре/файле
    { 'KOL_ERR',    'N',  6, 0 };  // количество пациентов с ошибками в реестре
  } )
  dbCreate( cur_dir() + 'tmp2file', { ;
    { '_N_ZAP',     'N',  6, 0 }, ;
    { '_SMO',       'C',  5, 0 }, ;
    { '_ENP',       'C', 16, 0 }, ;
    { '_OPLATA',    'N',  1, 0 }, ;
    { '_ERROR',     'N',  3, 0 };
  } )
  dbCreate( cur_dir() + 'tmp3file', { ;
    { '_N_ZAP',     'N',  6, 0 }, ;
    { '_ERROR',     'N',  3, 0 };
  } )
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  Append Blank
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case 'ZGLV' == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
      tmp1->_DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr ) )
      tmp1->_NAME_F  :=          mo_read_xml_stroke( oXmlNode, 'NAME_F', aerr )
      tmp1->_NAME_FE :=          mo_read_xml_stroke( oXmlNode, 'NAME_FE', aerr )
    Case 'ERRS' == oXmlNode:title
      Select TMP3
      Append Blank
      tmp3->_N_ZAP := 0
      tmp3->_ERROR := Val( mo_read_xml_tag( oXmlNode, aerr ) )
    Case 'ZAPS' == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->_N_ZAP  := Val( mo_read_xml_stroke( oXmlNode, 'ZAP', aerr ) )
      tmp2->_ENP    :=     mo_read_xml_stroke( oXmlNode, 'ENP', aerr, .f. )
      tmp2->_SMO    :=     mo_read_xml_stroke( oXmlNode, 'SMO', aerr, .f. )
      tmp2->_OPLATA := Val( mo_read_xml_stroke( oXmlNode, 'RESULT', aerr ) )
      If tmp2->_OPLATA > 1 .and. ( oNode1 := oXmlNode:find( 'ERRORS' ) ) != NIL
        _ar := mo_read_xml_array( oNode1, 'ERROR' )
        For j1 := 1 To Len( _ar )
          Select TMP3
          Append Blank
          tmp3->_N_ZAP := tmp2->_N_ZAP
          tmp3->_ERROR := Val( _ar[ j1 ] )
          tmp2->_ERROR := Val( _ar[ j1 ] ) // получаем последнюю ошибку
        Next
      Endif
    Endcase
  Next j
  Commit
  rest_box( buf )
  Return Nil

// 17.11.25 прочитать и 'разнести' по базам данных файл D02
Function read_xml_file_d02( arr_XML_info, aerr, /*@*/current_i2,lrec_xml)

  Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[ 2 ], ldate_D02, s, err_file := .f.

  Default lrec_xml To 0
  mkod_reestr := arr_XML_info[ 7 ]
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  ldate_D02 := tmp1->_DATE_F
  r_use( dir_server() + 'mo_d01',, 'REES' )
  Goto ( arr_XML_info[ 7 ] )
  StrFile( 'Обрабатывается ответ ТФОМС (D02) на информационный пакет ' + AllTrim( rees->NAME_XML ) + sxml() + hb_eol() + ;
    'от ' + date_8( rees->DSCHET ) + 'г. (' + lstr( rees->kol ) + ' чел.)' + hb_eol() + hb_eol(), cFileProtokol, .t. )
  rees_kol := rees->kol
  //
  r_use( dir_server() + 'mo_d01k',, 'RHUM' )
  Index On Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->REESTR == mkod_reestr
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  i := 0 ; k := LastRec()
  // сначала проверка
  ii1 := ii2 := 0
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + '%' Color cColorWait
    If tmp2->_OPLATA == 1
      ++ii1
//      If !Empty( tmp2->_SMO ) .and. AScan( glob_arr_smo, {| x| x[ 2 ] == Int( Val( tmp2->_SMO ) ) } ) == 0
      If !Empty( tmp2->_SMO ) .and. AScan( smo_volgograd(), {| x| x[ 2 ] == Int( Val( tmp2->_SMO ) ) } ) == 0
        AAdd( aerr, 'Некорректное значение атрибута SMO: ' + tmp2->_SMO )
      Endif
    Elseif Between( tmp2->_OPLATA, 2, 4 )
     /* If tmp2->_OPLATA == 2 .and. tmp2->_ERROR == 131 // правка 01.02.24
        g_rlock( forever )
        tmp2->_OPLATA := 1
        Unlock
        ++ii1
      Else*/
        ++ii2
      //Endif
    Else
      AAdd( aerr, 'Некорректное значение атрибута RESULT: ' + lstr( tmp2->_OPLATA ) )
    Endif
    Select RHUM
    find ( Str( tmp2->_N_ZAP, 6 ) )
    If !Found()
      AAdd( aerr, 'Не найден случай с N_ZAP = ' + lstr( tmp2->_N_ZAP ) )
    Endif
    Select TMP2
    Skip
  Enddo
  tmp1->kol := ii1
  tmp1->kol_err := ii2
  If Empty( ii2 )
    Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
    Index On Str( FIELD->_n_zap, 6 ) to ( cur_dir() + 'tmp3' )
    find ( Str( 0, 6 ) )
    err_file := Found() // ошибки на уровне файла
  Endif
  Close databases
  If Empty( aerr ) // если проверка прошла успешно
    // запишем принимаемый файл (реестр СП)
    // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server()+dir_XML_TF())
    chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
    g_use( dir_server() + 'mo_xml',, 'MO_XML' )
    If Empty( lrec_xml )
      addrecn()
    Else
      Goto ( lrec_xml )
      g_rlock( forever )
    Endif
    mo_xml->KOD := RecNo()
    mo_xml->KOD := RecNo()
    mo_xml->FNAME := cReadFile
    mo_xml->DFILE := ldate_D02
    mo_xml->TFILE := ''
    mo_xml->DREAD := sys_date
    mo_xml->TREAD := hour_min( Seconds() )
    mo_xml->TIP_IN := _XML_FILE_D02 // тип принимаемого файла
    mo_xml->DWORK  := sys_date
    mo_xml->TWORK1 := cTimeBegin
    mo_xml->REESTR := mkod_reestr
    mo_xml->KOL1 := ii1
    mo_xml->KOL2 := ii2
    //
    mXML_REESTR := mo_xml->KOD
    Use
    g_use( dir_server() + 'mo_d01',, 'REES' )
    Goto ( mkod_reestr )
    g_rlock( forever )
    rees->answer := 1
    If ii2 > 0
      rees->kol_err := ii2
    Elseif err_file
      rees->kol_err := -1
    Endif
    Use
    If ii2 > 0 .or. err_file
      Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
      Index On Str( FIELD->_n_zap, 6 ) to ( cur_dir() + 'tmp3' )
      g_use( dir_server() + 'mo_d01e',, 'REFR' )
      Index On Str( FIELD->REESTR, 6 ) + Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_D01e' )
      If err_file
        Select REFR
        Do While .t.
          find ( Str( mkod_reestr, 6 ) + Str( 0, 6 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        StrFile( 'Ошибки на уровне файла:' + hb_eol(), cFileProtokol, .t. )
        Select TMP3
        find ( Str( 0, 6 ) )
        Do While tmp3->_N_ZAP == 0 .and. !Eof()
          Select REFR
          addrec( 6 )
          refr->reestr := mkod_reestr
          refr->D01_ZAP := 0
          refr->KOD_ERR := tmp3->_ERROR
          // if (j := ascan(getT012(), {|x| x[2] == tmp3->_ERROR })) > 0
          // strfile(space(8) + 'ошибка ' + lstr(tmp3->_ERROR) + ' - ' + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
          // else
          // strfile(space(8)+'ошибка '+lstr(tmp3->_ERROR)+' (неизвестная ошибка)'+hb_eol(),cFileProtokol,.t.)
          // endif
         // If tmp3->_ERROR != 131 /////////////////////////////////////////////////////////////////////////////////////
            StrFile( Space( 8 ) + geterror_t012( tmp3->_ERROR ) + hb_eol(), cFileProtokol, .t. )
         // Endif
          Select TMP3
          Skip
        Enddo
      Endif
      tmp3->( dbCloseArea() )
    Endif
    g_use( dir_server() + 'kartote2',, 'KART2' )
    g_use( dir_server() + 'kartote_',, 'KART_' )
    g_use( dir_server() + 'kartotek',, 'KART' )
    g_use( dir_server() + 'mo_d01k',, 'RHUM' )
    Index On Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->REESTR == mkod_reestr
    i := 0
    If err_file
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( ++i / rees_kol * 100, 6, 2 ) + '%' Color cColorWait
        g_rlock( forever )
        rhum->OPLATA := 2 // искусственно присваиваем ошибку '2'
        Skip
      Enddo
    Else
      Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
      Index On Str( FIELD->_n_zap, 6 ) to ( cur_dir() + 'tmp3' )
      Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
      Index On Str( FIELD->_n_zap, 6 ) to ( cur_dir() + 'tmp2' )
      count_in_schet := LastRec()
      current_i2 := 0
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + '%' Color cColorWait
        Select RHUM
        find ( Str( tmp2->_N_ZAP, 6 ) )
        g_rlock( forever )
        rhum->OPLATA := tmp2->_OPLATA
        If !Empty( tmp2->_enp )
          Select KART2
          Do While kart2->( LastRec() ) < rhum->kod_k
            Append Blank
          Enddo
          Goto ( rhum->kod_k )
          If Len( AllTrim( kart2->kod_mis ) ) != 16
            g_rlock( forever )
            kart2->kod_mis := tmp2->_enp
            dbUnlock()
          Endif
        Endif
        If tmp2->_OPLATA > 1
          --count_in_schet    // не включается в счет,
          If current_i2 == 0
            StrFile( Space( 10 ) + 'Список случаев с ошибками:' + hb_eol() + hb_eol(), cFileProtokol, .t. )
          Endif
          ++current_i2
          kart->( dbGoto( rhum->kod_k ) )
          If Empty( kart->fio )
            StrFile( Str( tmp2->_N_ZAP, 6 ) + '. Пациент с кодом по картотеке ' + lstr( kart->( RecNo() ) ) + hb_eol(), cFileProtokol, .t. )
          Else
            select KART2
            goto (kart->kod)  
            StrFile( Str( tmp2->_N_ZAP, 6 ) + '. ' + AllTrim( kart->fio ) + ', ' + full_date( kart->date_r ) +' '+ alltrim(kart2->kod_mis) + hb_eol(), cFileProtokol, .t. )
          Endif
          select kart
          Select REFR
          Do While .t.
            find ( Str( mkod_reestr, 6 ) + Str( tmp2->_N_ZAP, 6 ) )
            If !Found() ; exit ; Endif
            deleterec( .t. )
          Enddo
          Select TMP3
          find ( Str( tmp2->_N_ZAP, 6 ) )
          Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. !Eof()
            Select REFR
            addrec( 6 )
            refr->reestr := mkod_reestr
            refr->D01_ZAP := tmp2->_N_ZAP
            refr->KOD_ERR := tmp3->_ERROR
            //if (j := ascan(getT012(), {|x| x[2] == tmp3->_ERROR })) > 0
            // strfile(space(8) + 'ошибка ' + lstr(tmp3->_ERROR) + ' - ' + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
            //else
            // strfile(space(8)+'ошибка '+lstr(tmp3->_ERROR)+' (неизвестная ошибка)'+hb_eol(),cFileProtokol,.t.)
            //endif
            StrFile( Space( 8 ) + geterror_t012( tmp3->_ERROR ) + hb_eol(), cFileProtokol, .t. )
            Select TMP3
            Skip
          Enddo
          If tmp2->_OPLATA == 3
            StrFile( Space( 8 ) + 'не установлена страховая принадлежность' + hb_eol(), cFileProtokol, .t. )
          Elseif tmp2->_OPLATA == 4
            StrFile( Space( 8 ) + 'не установлена страховая принадлежность, не подтверждено прикрепление к МО' + hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
        Unlock All
        Select TMP2
        If RecNo() % 1000 == 0
          Commit
        Endif
        Skip
      Enddo
    Endif
  Endif
  Close databases
  // вставить перенос оплаты из DK в DD
  g_use( dir_server() + 'mo_d01d',, 'mo_d01d', .t., .t. ) // список диагнозов пациентов в реестрах
  Index On Str( FIELD->kod_d, 7 ) to ( cur_dir() + 'tmp_kodd' )
  // { 'KOD_D',    'N', 6, 0 }, ; // код (номер записи) по файлу 'mo_d01k'
  r_use( dir_server() + 'mo_d01k'  ) // список пациентов в реестрах
  Index On Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->REESTR == mkod_reestr
  //
  Go Top
  Do While !Eof()
    // пациенты из реестра
    Select MO_D01D
    find ( Str( mo_d01k->( RecNo() ), 7 ) )
    Do While mo_d01d->kod_d == mo_d01k->( RecNo() ) .and. !Eof()
      // идем по диагнозам данного пациента
      g_rlock( forever )
      mo_d01d->oplata := mo_d01k->oplata
      Unlock
      Select MO_D01D
      Skip  // диагнозы
    Enddo
    Select MO_D01K // люди
    Skip
  Enddo
  Close databases
  Return count_in_schet

// 03.12.18
Function delete_reestr_d01( mkod_reestr )

  Local ret := -1, rec, ir, fl := .t.

  If f_esc_enter( 'аннулирования D01' )
    mywait()
    Select REES
    Goto ( mkod_reestr )
    g_use( dir_server() + 'mo_d01d',, 'DD' )
    Index On Str( FIELD->kod_d, 6 ) to ( cur_dir() + 'tmp_d01d' )
    g_use( dir_server() + 'mo_d01k',, 'DK' )
    Index On Str( FIELD->reestr, 6 ) to ( cur_dir() + 'tmp_d01k' )
    Do While .t.
      Select DK
      find ( Str( mkod_reestr, 6 ) )
      If Found()
        Select DD
        Do While .t.
          find ( Str( dk->( RecNo() ), 6 ) )
          If Found()
            deleterec( .t. )
          Else
            Exit
          Endif
        Enddo
        Select DK
        deleterec( .t. )
      Else
        Exit
      Endif
    Enddo
    Select MO_XML
    Goto ( rees->KOD_XML )
    deleterec( .t. )
    Select REES
    deleterec( .t. )
    dbUnlockAll()
    dbCommitAll()
    stat_msg( 'Аннулирование завершено!' ) ; mybell( 2, OK )
    ret := 1
  Endif
  Return ret

// 29.11.18 аннулировать чтение недочитанного реестра D02
Function delete_reestr_d02( mkod_reestr, mname_reestr )

  Local i, s, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
    arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
    cFileProtokol := cur_dir() + 'tmp.txt'

  mywait()
  Select MO_XML
  Index On FIELD->FNAME to ( cur_dir() + 'tmp_xml' ) ;
    For reestr == mkod_reestr .and. tip_in == _XML_FILE_D02 .and. TIP_OUT == 0
  Go Top
  Do While !Eof()
    AAdd( mm_func, mo_xml->kod )
    s := 'Протокол чтения ' + RTrim( mo_xml->FNAME ) + ' прочитан ' + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      AAdd( mm_flag, .t. )
      s += '-ПРОЦЕСС НЕ ЗАВЕРШЁН'
    Else
      AAdd( mm_flag, .f. )
      s += ' в ' + mo_xml->TWORK1
    Endif
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  rest_box( buf )
  If Len( mm_menu ) == 0
    func_error( 4, 'Не было чтения файла D02...' )
    Return 0
  Endif
  If r <= 18
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r -1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  If ( i := popup_prompt( r1, 10, 1, mm_menu,,, color5 ) ) > 0
    is_allow_delete := mm_flag[ i ]
    mreestr_sp_tk := mm_func[ i ]
    Select MO_XML
    Goto ( mreestr_sp_tk )
    cFile := AllTrim( mo_xml->FNAME )
    mtip_in := mo_xml->TIP_IN
    Close databases
    If !is_allow_delete
      func_error( 4, 'Файл ' + cFile + sxml() + ' корректно прочитан. Аннулирование запрещено!' )
      Return 0
    Endif
    If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF(), cFile + szip() ) ) != NIL
      cFile += sxml()
      // читаем файл в память
      oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        func_error( 4, 'Ошибка в чтении файла ' + cFile )
      Else // читаем и записываем XML-файл во временные TMP-файлы
        reestr_d02_tmpfile( oXmlDoc, aerr, cFile )
        If !Empty( aerr )
          ins_array( aerr, 1, '' )
          ins_array( aerr, 1, Center( 'Ошибки в чтении файла ' + cFile, 80 ) )
          AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
          viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
          Delete File ( cFileProtokol )
        Else
          If !is_allow_delete .and. involved_password( 2, cFile, 'аннулирования чтения файла D02' )
            is_allow_delete := .t.
          Endif
          If is_allow_delete
            Close databases
            g_use( dir_server() + 'mo_d01',, 'REES' )
            Goto ( mkod_reestr )
            Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
            Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
            arr := {}
            AAdd( arr, 'Информационный пакет ' + AllTrim( rees->NAME_XML ) + sxml() + ' от ' + date_8( rees->DSCHET ) + 'г.' )
            AAdd( arr, 'за ' + lstr( rees->NYEAR ) + ' год, кол-во пациентов ' + lstr( rees->kol ) + ' чел.' )
            AAdd( arr, '' )
            g_use( dir_server() + 'mo_xml',, 'MO_XML' )
            Goto ( mreestr_sp_tk )
            AAdd( arr, 'Аннулируется файл ответа ' + cFile + ' от ' + date_8( mo_xml->DFILE ) + 'г.' )
            AAdd( arr, 'После подтверждения аннулирования все последствия чтения данного' )
            AAdd( arr, 'файла D02, а также сам файл D02, будут удалены.' )
            f_message( arr,, cColorSt2Msg, cColorSt1Msg )
            s := 'Подтвердите аннулирование файла D02'
            stat_msg( s ) ; mybell( 1 )
            is_allow_delete := .f.
            If f_esc_enter( 'аннулирования', .t. )
              stat_msg( s + ' ещё раз.' ) ; mybell( 3 )
              If f_esc_enter( 'аннулирования', .t. )
                mywait()
                is_allow_delete := .t.
              Endif
            Endif
            Close databases
          Endif
          If is_allow_delete
            g_use( dir_server() + 'mo_xml',, 'MO_XML' )
            g_use( dir_server() + 'mo_d01',, 'REES' )
            Goto ( mkod_reestr )
            g_rlock( forever )
            rees->answer := 0
            rees->kol_err := 0
            g_use( dir_server() + 'mo_d01e',, 'REFR' )
            Index On Str( FIELD->REESTR, 6 ) + Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_D01e' )
            Select REFR
            Do While .t.
              find ( Str( mkod_reestr, 6 ) + Str( 0, 6 ) ) // удалим ошибки на уровне файла
              If !Found() ; exit ; Endif
              deleterec( .t. )
            Enddo
            g_use( dir_server() + 'mo_d01k',, 'RHUM' )
            Index On Str( FIELD->D01_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == mkod_reestr
            Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
            Go Top
            Do While !Eof()
              Select RHUM
              find ( Str( tmp2->_N_ZAP, 6 ) )
              g_rlock( forever )
              rhum->OPLATA := 0
              Unlock
              Select REFR
              Do While .t.
                find ( Str( mkod_reestr, 6 ) + Str( tmp2->_N_ZAP, 6 ) )
                If !Found() ; exit ; Endif
                deleterec( .t. )
              Enddo
              Select TMP2
              Skip
            Enddo
            Select MO_XML
            Goto ( mreestr_sp_tk )
            deleterec()
            Close databases
            stat_msg( 'Файл ' + cFile + ' успешно аннулирован. Можно прочитать ещё раз.' ) ; mybell( 5 )
          Endif
        Endif
      Endif
    Endif
  Endif
  rest_box( buf )
  Return 0
