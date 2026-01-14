#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

// 14.01.26 Редактирование случая с выбором по конкретной ошибке из ТФОМС
Function f3oms_edit()

  Static si := 1
  Local buf, str_sem, i, k, arr, old_yes_h_otd := yes_h_otd, iRefr, ret_arr, srec, buf24, buf_scr, s, mas_pmt
  local s1, aTokens, adbf
  Local lek_pr := .f.

  If !myfiledeleted( cur_dir() + 'tmp_h' + sdbf() )
    Return Nil
  Endif

  Private arr_m

  If ( arr_m := year_month( T_ROW, T_COL + 5,, 3 ) ) != NIL
    buf24 := save_maxrow()
    mywait()
    arr := {}
    dbCreate( cur_dir() + 'tmp_h', { ;
      { 'kod', 'N', 7, 0 }, ;
      { 'SREFREASON', 'C', 12, 0 }, ;
      { 'REFREASON', 'N', 10, 0 } ;
    } )
    Use ( cur_dir() + 'tmp_h' ) new
    r_use( dir_server() + 'mo_refr',, 'REFR' )
    Index On Str( FIELD->kodz, 8 ) to ( cur_dir() + 'tmp_refr' ) For FIELD->tipz == 1
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To Str( human->kod, 8 ) into REFR

    // заполним временный файл БД видами полученных ошибок
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !human->( Eof() )
      If human_->reestr == 0 .and. human_->REES_NUM > 0 .and. human->schet == 0
        s := 0
        s1 := ''
        Select REFR
        find ( Str( human->kod, 8 ) )
        Do While human->kod == refr->kodz .and. !Eof()
          s := refr->REFREASON // берём последнее значение
          s1 := alltrim( refr->SREFREASON )
          Skip
        Enddo
        If s > 0
          Select TMP_H
          Append Blank
          Replace kod With human->kod, REFREASON With s
          If ( i := AScan( arr, {| x| x[ 2 ] == tmp_h->REFREASON } ) ) == 0
            If Empty( s := ret_t005( tmp_h->REFREASON ) )
              s := lstr( tmp_h->REFREASON ) + ' неизвестная причина отказа'
            Endif
            AAdd( arr, { s, tmp_h->REFREASON } )
          Endif
        Elseif !Empty( s1 )
          Select TMP_H
          tmp_h->( dbAppend() )
          // replace kod with human->kod, REFREASON with -99, SREFREASON with s1 
//          Replace kod With human->kod, REFREASON With 10, SREFREASON With s1  // чтобы обмануть выбор пациентов 20/02/21
          Replace kod With human->kod, REFREASON With hb_CRC32( s1 ), SREFREASON With s1
          If ( i := AScan( arr, {| x| x[ 2 ] == tmp_h->REFREASON } ) ) == 0
            If Len( aTokens := hb_ATokens( s1, '.' ) ) == 3 // ошибка по справочнику Q015
              s := AllTrim( s1 ) + ' ' + getcategorycheckerrorbyid_q017( aTokens[ 1 ] )[ 1 ]
            Else
              s := s1 + ' новая причина отказа'
            Endif
            AAdd( arr, { s, tmp_h->REFREASON } )
          Endif
        Endif
      Endif
//      Select HUMAN
//      Skip
      human->( dbSkip() )
    Enddo
    If glob_mo()[ _MO_KOD_TFOMS ] == '805965' // РДЛ
      adbf := { ;
        { 'REFREASON', 'N', 15, 0 }, ;
        { 'shifr_usl', 'C', 10, 0 }, ;  // шифр услуги
        { 'name_usl', 'C', 250, 0 }, ; // наименование услуги
        { 'NUMORDER', 'N', 10, 0 }, ;   // Номер заявки(ORDER Number)
        { 'fio', 'C', 70, 0 }, ;
        { 'date_r', 'C', 10, 0 }, ;
        { 'kol_usl', 'N', 10, 0 }, ;    // кол-во услуг
        { 'cena_1', 'N', 11, 2 }, ;
        { 'otd', 'C', 42, 0 }, ;
        { 'otd_kod', 'N', 3, 0 }, ;
        { 'smo_kod', 'C', 5, 0 }, ;
        { 'napr_uch', 'C', 6, 0 } ;
      }
      dbCreate( cur_dir() + fr_data + '2', adbf )
      If f_esc_enter( 'создания отчета в Excel ', .t. )
        // dbcreate(cur_dir() + fr_data + '2', adbf)
        Use ( cur_dir() + fr_data + '2' ) New Alias FRD2
        // база готова
        r_use( dir_server() + 'mo_otd',, 'OTD' )
        r_use( dir_server() + 'human_2',, 'HU2' )
        r_use( dir_server() + 'uslugi',, 'USL' )
        r_use( dir_server() + 'human_u_',, 'HU_' )
        r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
        Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
        use_base( 'lusl' )
        Select tmp_h
        Go Top
        Do While !Eof()
          Select hu
          find ( Str( tmp_h->kod, 7 ) )
          Do While tmp_h->kod == hu->kod .and. !Eof()
            Select hu2
            Goto tmp_h->kod
            Select  frd2
            Append Blank
            frd2->REFREASON := tmp_h->refreason
            frd2->shifr_usl := usl->shifr    // шифр услуги
            frd2->name_usl  :=  usl->name // наименование услуги
            Select human
            Goto tmp_h->kod
            Select human_
            Goto tmp_h->kod
            frd2->smo_kod   := human_->smo
            frd2->napr_uch  := human_->NPR_MO
            //
            musl := transform_shifr( frd2->shifr_usl )
            Select lusl
            find( musl )
            frd2->name_usl := lusl->name
            //
            frd2->NUMORDER := hu2->pn3   // Номер заявки(ORDER Number)
            frd2->fio     := AllTrim ( human->fio ) + ' ' + full_date( human->date_r )
            frd2->kol_usl := hu->kol_1     // кол-во услуг
            frd2->cena_1  := hu->stoim_1
            Select otd
            Goto human->otd
            frd2->otd    := AllTrim( otd->NAME )
            frd2->otd_kod := human->otd
            Select hu
            Skip
          Enddo
          Select tmp_h
          Skip
        Enddo
      Endif
    Endif  // Окончание РДЛ
    dbCloseAll()
    rest_box( buf24 )
    Private kod_REFREASON_menu
    If Empty( arr )
      func_error( 4, 'Нет пациентов с ошибками из ТФОМС ' + arr_m[ 4 ] )
    Elseif ( iRefr := popup_2array( arr, T_ROW, T_COL + 5,,, @ret_arr, 'Выбор вида ошибки', 'B/BG', color0, 'errorOMSkey', ;
        '^<Esc>^ - отказ;  ^<Enter>^ - выбор; ^F2^ - дополнительное описание' ) ) > 0
        // в случае выбора ошибки 57 (ошибки в персональных данных) или 599 (неверный пол или дата рождения)
      If eq_any( iRefr, 57, 599 ) .and. ( i := popup_prompt( T_ROW, T_COL + 5, 1, ;
          { ;
            'Редактирование листов учёта', ;
            'Создание файла ХОДАТАЙСТВА для отсылки в ТФОМС', ;
            'Оформление (печать) ХОДАТАЙСТВА (по старому)' ;
          },,, color5 ) ) > 1
        Return tfoms_hodatajstvo( arr_m, iRefr, i - 1 )
      Endif
      Private mr1 := T_ROW, regim_vyb := 2, p_del_error := ret_arr
      kod_REFREASON_menu := iRefr
      Do While .t.
        r_use( dir_server() + 'mo_otd',, 'OTD' )
        g_use( dir_server() + 'human_',, 'HUMAN_' )
        r_use( dir_server() + 'human',, 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To FIELD->otd into OTD
        Use ( cur_dir() + 'tmp_h' ) new
        Set Relation To FIELD->kod into HUMAN
        Index On Upper( human->fio ) to ( cur_dir() + 'tmp_h' ) For FIELD->REFREASON == iRefr
        If srec == NIL
          Go Top
        Else
          Goto ( srec )
        Endif
        mkod := 0
        yes_h_otd := 2
        buf_scr := SaveScreen()
        box_shadow( MaxRow() -3, 2, MaxRow() -1, 77, color0 )
        If alpha_browse( T_ROW, 2, MaxRow() -4, 77, 'f1ret_oms_human', color0, ret_arr[ 1 ], 'B/BG',, ;
            .t.,, 'f21ret_oms_human', 'f2ret_oms_human',, ;
            { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R' } )
          If ( glob_perso := tmp_h->kod ) == 0
            func_error( 4, 'Не найдено нужных записей!' )
          Elseif eq_any( human->ishod, 88, 89 )
            func_error( 4, 'Данный случай - часть двойного случая. Редактирование запрещено!' )
          Else
            srec := tmp_h->( RecNo() )
            mkod := glob_perso
            glob_kartotek := human->kod_k
            glob_k_fio := fio_plus_novor()
            glob_otd[ 1 ] := human->otd
            glob_otd[ 2 ] := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', human->otd )
            If Len( glob_otd ) == 2
              AAdd( glob_otd, human_->usl_ok )
            Else
              glob_otd[ 3 ] := human_->usl_ok
            Endif
            k := ret_tip_lu()
            If Len( glob_otd ) == 3
              AAdd( glob_otd, k )
            Else
              glob_otd[ 4 ] := k
            Endif
            glob_uch[ 1 ] := human->LPU
            glob_uch[ 2 ] := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', human->LPU )
            fl_schet := ( human->schet > 0 )
          Endif
        Else
          RestScreen( buf_scr )
          Exit
        Endif
        RestScreen( buf_scr )
        dbCloseAll()
        If mkod > 0
          lek_pr := check_oms_sluch_lek_pr( glob_perso )
          yes_h_otd := old_yes_h_otd
          If buf != NIL
            rest_box( buf )
          Endif
          buf := box_shadow( 0, 41, 3, 77, color13 )
          @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
          @ 2, 42 Say PadC( glob_k_fio, 35 ) Color color8
          If lek_pr
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг', 'Использованные ~лекарства' }
          Else
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг' }
          Endif
          If glob_otd[ 3 ] == 4 .or. ;
              ( glob_otd[ 4 ] > 0 .and. ;
                glob_otd[ 4 ] != TIP_LU_MED_REAB .and. ;
                glob_otd[ 4 ] != TIP_LU_H_DIA .and. ;
                glob_otd[ 4 ] != TIP_LU_P_DIA )
            si := 1
            ASize( mas_pmt, 1 )
            Keyboard Chr( K_ENTER )
          Endif
          Do While ( i := popup_prompt( T_ROW, T_COL + 5, si, mas_pmt ) ) > 0
            si := i
            str_sem := 'Редактирование человека ' + lstr( glob_perso )
            If g_slock( str_sem )
              If i == 1
                oms_sluch( glob_perso, glob_kartotek )
              Elseif i == 2
                oms_usl_sluch( glob_perso, glob_kartotek )
              Elseif i == 3
                oms_sluch_lek_pr( glob_perso, glob_kartotek )
              Endif
              g_sunlock( str_sem )
            Else
              func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
              Exit
            Endif
          Enddo
        Endif
      Enddo
    Endif
    If buf != NIL
      rest_box( buf )
    Endif
    yes_h_otd := old_yes_h_otd
    dbCloseAll()
  Endif
  Return Nil

// 25.05.21 получить ошибку ФФОМС в виде массива из файлов Q015 или Q016
Function errorarrayffoms( error_code )

  Local arr_error := {}

  If SubStr( error_code, 4, 1 ) == 'F' .and. SubStr( error_code, 6, 2 ) == '00'
    arr_error := getrulecheckerrorbyid_q015( error_code )
  Elseif SubStr( error_code, 4, 1 ) == 'K' .and. SubStr( error_code, 6, 2 ) == '00'
    arr_error := getrulecheckerrorbyid_q016( error_code )
  Endif
  Return arr_error

// 26.02.25 отображение полного описания ошибки
Function erroromskey( nkey, ind )

  Local ret := -1, oBox
  Local color_say := 'N/W', color_get := 'W/N*'
  Local arr := split( parr[ ind ] )
  Local error_code, opis := {}, arr_error, cond := .f.
  Local begin_row := 2, i

  error_code := arr[ 1 ]

  If Len( error_code ) < 4
    perenos( opis, retarr_t005( Val( error_code ) )[ 3 ], 56 )
  Elseif ( Len( error_code ) == 12 ) .and. ( hb_tokenCount( error_code, '.' ) == 3 )
    arr_error := errorarrayffoms( error_code )
    perenos( opis, arr_error[ 6 ], 56 )
    If ! Empty( arr_error[ 4 ] )
      hb_AIns( opis, 1, 'Для: ' + arr_error[ 4 ], .t. )
      cond := .t.
    Endif
    If ! Empty( arr_error[ 5 ] )
      hb_AIns( opis, iif( cond, 2, 1 ), 'Должно быть: ' + arr_error[ 5 ], .t. )
    Endif
  Else
    // дополнительной информации по ошибке нет
    Return ret
  Endif
  If nKey == K_F2
    oBox := Nil // уничтожим окно
    oBox := tbox():new( begin_row, 10, 3 + Len( opis ), 70 )
    oBox:Color := color_say + ',' + color_get
    oBox:Frame := BORDER_DOUBLE
    oBox:MessageLine := '^<любая клавиша>^ - выход'
    oBox:Save := .t.
    oBox:Caption := 'Описание ошибки - ' + error_code
    oBox:view()
    For i := 1 To Len( opis )
      @ begin_row + i, 12 Say opis[ i ]
    Next
    Inkey( 0 )

    // ret := 0
  Elseif nKey == K_F3
    // ret := 0
  Elseif nKey == K_SPACE
    // ret := 1
  Endif
  Return ret
