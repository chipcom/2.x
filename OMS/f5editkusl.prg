#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.02.25 функция для when и valid при вводе услуг в лист учёта
Function f5editkusl( get, when_valid, k, lMedReab, vidReab, shrm, adult )

  Local fl := .t., i, lu_cena, lshifr1, v, old_kod, amsg, fl1, fl2, ;
    msg1_err := 'Код врача равен коду ассистента! Это недопустимо.', ;
    msg2_err := 'Сотрудника с таким кодом нет в базе данных персонала!', ;
    blk_sum := {|| mstoim_1 := round_5( mu_cena * mkol_1, 2 ) }
  Local aMedReab, aReab, mvto := 0

  Default lMedReab To .f.
  Default vidReab To 0
  Default shrm To 0
  Default adult To .t.

  If when_valid == 1    // when
    If k == 2     // Шифр услуги
      If !Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 3 // Код врача
      fl := vr_uva
    Elseif k == 4 // Код ассистента
      fl := as_uva
    Elseif k == 5 // Количество услуг
      If Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 10  // код отделения
      SetKey( K_F3, {| p, l, v| get1_otd( p, l, v, get:Row, get:Col ) } )
      @ r1, 45 Say '<F3> - выбор отделения из меню' Color color13
    Endif
  Else  // valid
    If k == 1     // Дата оказания услуги
      If !emptyany( human->n_data, mdate_u1 ) .and. mdate_u1 < human->n_data
        fl := func_error( 4, 'Введенная дата меньше даты начала лечения!' )
      Elseif !emptyany( human->k_data, mdate_u1 ) .and. mdate_u1 > human->k_data
        fl := func_error( 4, 'Введенная дата больше даты окончания лечения!' )
      Endif
      If fl .and. is_zf_stomat == 1 .and. !Empty( mzf )
        // перепрыгнуть на ввод шифра услуги
        Keyboard Chr( K_TAB )
      Endif
    Elseif k == 2 // Шифр услуги
      If !Empty( mshifr ) .and. !( mshifr == get:original )
        mshifr := transform_shifr( mshifr )
        If lMedReab   // сначала проверим шифр амбулаторную мед. реабилитацию
          aReab      := list2arr( human_2->PC5 )
          If Len( aReab ) > 2
            mvto     := aReab[ 3 ]
          Endif
          aMedReab := ret_usluga_med_reab( mshifr, vidReab, shrm, adult, mvto )
          If aMedReab == Nil .or. Len( aMedReab ) == 0
            func_error( 4, 'Услуга не входит в набор услуг обращения в амбулаторной медицинской реабилитации' )
            mshifr := Space( 20 )
            Return .f.
          Endif
        Endif
        // сначала проверим на код лаб.услуги, направляемой в ЦКДЛ
        If is_lab_usluga( mshifr ) .and. !( Type( 'is_oncology' ) == 'N' )
          fl := .f.
          If f1cena_oms( mshifr, ;
              mshifr, ;
              ( human->vzros_reb == 0 ), ;
              human->k_data, ;
              .t., ;
              @mis_oms ) == NIL
            Select LUSL
            find ( PadR( mshifr, 10 ) )
            If Found()
              func_error( 4, 'Данная лабораторная услуга не разрешена для использования в Вашей МО' )
            Else
              func_error( 4, 'Введена несуществующая лабораторная услуга' )
            Endif
            mshifr := Space( 20 )
          Else // услуга разрешена данной МО
            If Select( 'MOPROF' ) == 0
              r_use( dir_exe() + '_mo_prof', cur_dir() + '_mo_prof', 'MOPROF' )
              // index on shifr+str(vzros_reb,1)+str(profil,3) to (sbase)
            Endif
            m1profil := iif( Left( mshifr, 5 ) == '4.16.', 6, 34 )
            Select MOPROF
            find ( PadR( mshifr, 20 ) + Str( iif( human->vzros_reb == 0, 0, 1 ), 1 ) + Str( m1profil, 3 ) )
            If !Found()
              find ( PadR( mshifr, 20 ) + Str( iif( human->vzros_reb == 0, 0, 1 ), 1 ) )
              If Found()
                m1profil := moprof->profil
              Endif
            Endif
            Select USL
            Set Order To 1
            find ( PadR( mshifr, 10 ) )
            If Found() // уже занесена в наш справочник услуг
              mu_kod  := usl->kod
            Else // не занесена в наш справочник услуг
              mu_kod := foundourusluga( mshifr, human->k_data, m1PROFIL, human->VZROS_REB, @mu_cena, 2 )
              Select USL
              Set Order To 0
              Goto ( mu_kod )
            Endif
            mname_u := usl->name
            mn_base := 0
            mstoim_1 := mu_cena := 0
            mis_nul := .t.
            mis_edit := -1 // т.е. лаб.услуга направлена в ЦКДЛ
            mu_koef := 1
            mPROFIL := PadR( inieditspr( A__MENUVERT, getv002(), m1PROFIL ), 69 )
            mkod_vr := mtabn_vr := 0
            mvrach := Space( 35 )
            mkod_as := mtabn_as := 0
            massist := Space( 35 )
            mkol := mkol_1 := 1
            fl := update_gets()
          Endif
          Return fl
        Endif
        // сначала проверим на код операции ФФОМС
        fl1 := fl2 := .f.
        Select LUSLF
        find ( PadR( mshifr, 20 ) )
        If Found() .and. AllTrim( mshifr ) == AllTrim( luslf->shifr )
          is_usluga_zf := luslf->zf
          tip_onko_napr := luslf->onko_napr
          tip_onko_ksg := luslf->onko_ksg
          If ( tip_telemed := luslf->telemed ) == 1
            tip_telemed2 := ( Left( mshifr, 4 ) == 'B01.' )
          Endif
          tip_par_org := luslf->par_org
          fl1 := .t.
          Select MOSU
          Set Order To 3
          find ( PadR( mshifr, 20 ) ) // поищем федеральный код операции ФФОМС
          If Found()
            If mosu->tip == 0 // проверяем, что ЭТО НЕ стоматология 2016 (удалённая)
              mu_kod  := mosu->kod
              mname_u := mosu->name
              mshifr1 := mosu->shifr1
              If !Empty( mosu->profil )
                m1PROFIL := mosu->profil
                mPROFIL := PadR( inieditspr( A__MENUVERT, getv002(), m1PROFIL ), 69 )
              Endif
            Else // Старая стоматология 2016
              fl1 := .f.
              fl2 := .t.
            Endif
          Else
            mu_kod  := 0
            mname_u := Left( luslf->name, 65 )
            mshifr1 := mshifr
          Endif
        Endif
        If !fl1 // не нашли в операциях ФФОМС
          Select MOSU
          Set Order To 2
          find ( PadR( mshifr, 10 ) ) // поищем собственный код операции ФФОМС
          If Found()
            If mosu->tip == 0 // проверяем, что ЭТО НЕ стоматология 2016 (удалённая)
              fl1 := .t.
              mu_kod  := mosu->kod
              mname_u := mosu->name
              mshifr1 := mosu->shifr1
              If !Empty( mosu->profil )
                m1PROFIL := mosu->profil
                mPROFIL := PadR( inieditspr( A__MENUVERT, getv002(), m1PROFIL ), 69 )
              Endif
              Select LUSLF
              find ( PadR( mshifr1, 20 ) )
              If Found()
                is_usluga_zf := luslf->zf
                tip_onko_napr := luslf->onko_napr
                tip_onko_ksg := luslf->onko_ksg
                If ( tip_telemed := luslf->telemed ) == 1
                  tip_telemed2 := ( Left( mshifr1, 4 ) == 'B01.' )
                Endif
                tip_par_org := luslf->par_org
              Endif
            Else // Старая стоматология 2016
              fl1 := .f.
              fl2 := .t.
            Endif
          Endif
        Endif
        If Type( 'is_oncology' ) == 'N'
          If !fl1
            fl := func_error( 4, 'Шифра ' + AllTrim( mshifr ) + ' нет в базе данных федеральных услуг.' )
          Endif
          Return fl
        Elseif fl1
          mn_base := 1
          mstoim_1 := mu_cena := 0
          If Type( 'tip_telemed2' ) == 'L' .and. is_telemedicina( mshifr1, @tip_telemed2 ) // является услугой телемедицины - не заполняется код врача
            tip_telemed := 1
            mis_edit := -1
          Endif
          mis_nul := .t.
          mkol := mkol_1 := 1
          verify_uva( 2 )
          update_gets()
          If Type( 'row_dom' ) == 'N'
            If Empty( tip_par_org )
              m1dom := 0
              mdom := Space( 20 )
              @ row_dom + 1, 1 Say Space( 78 ) Color color1
            Endif
            If Type( 'tip_telemed2' ) == 'L' .and. tip_telemed2
              @ row_dom, 2 Say 'Где оказана услуга' Color color1
              @ Row(), Col() + 1 Say PadR( mnmic, 58 ) Color color13
              @ row_dom + 1, 2 Say ' Получены ли результаты на дату окончания лечения' Color color1
              @ Row(), Col() + 1 Say PadR( mnmic1, 27 ) Color color13
            Endif
          Endif
          Return fl  // !!!!!!!!!!!!!!!!!!!!!
        Endif
        If fl2
          fl := func_error( 4, 'Данную СТОМАТОЛОГИЧЕСКУЮ услугу запрещено вводить после 2016 года!' )
        Else // теперь проверим по старому алгоритму
          Select USL
          Set Order To 1
          find ( PadR( mshifr, 10 ) )
          If Found()
            lu_cena := iif( human->vzros_reb == 0, usl->cena, usl->cena_d )
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If ( v := f1cena_oms( usl->shifr, ;
                lshifr1, ;
                ( human->vzros_reb == 0 ), ;
                human->k_data, ;
                usl->is_nul, ;
                @mis_oms ) ) != NIL
              lu_cena := v
            Endif
            fl1 := .t.
            If Empty( lu_cena )
              fl1 := .f.
              If nuluslugatfoms( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                fl1 := .t.
              Else
                fl1 := usl->is_nul
              Endif
            Endif
            If !fl1
              fl := func_error( 4, 'В данной услуге не проставлена цена!' )
            Else
              If mem_otdusl == 2 .and. Type( 'pr1arr_otd' ) == 'A'
                // автоматическое присвоение отделения по месту работы персонала
                fl := .t.
              Else
                Select UO
                find ( Str( usl->kod, 4 ) )
                If Found() .and. !( Chr( m1otd ) $ uo->otdel )
                  fl := func_error( 4, 'Данную услугу запрещено вводить в данном отделении!' )
                Endif
              Endif
              If fl
                mu_kod  := usl->kod
                mname_u := usl->name
                mshifr1 := iif( Empty( lshifr1 ), mshifr, lshifr1 )
                If Left( mshifr1, 5 ) == '60.8.'
                  mgist := inieditspr( A__MENUVERT, mm_gist, m1gist )
                  is_gist := .t.
                Endif
                mu_cena := lu_cena
                mis_nul := usl->is_nul
                mu_koef := 1
                If mis_nul  // услуга с нулевой ценой
                  mu_cena := 0
                Endif
                mkol := mkol_1 := 1
                fl_date_next := is_usluga_disp_nabl( mshifr, mshifr1 )
                If !Empty( usl->profil )
                  m1PROFIL := usl->profil
                  mPROFIL := PadR( inieditspr( A__MENUVERT, getv002(), m1PROFIL ), 69 )
                Endif
                Eval( blk_sum )
                verify_uva( 2 )
                update_gets()
                // if type('row_dom') == 'N' .and. !DomUslugaTFOMS(mshifr1) .and. !tip_telemed2
                // m1dom := 0
                // mdom := space(20)
                // @ row_dom, 1 say space(34) color color1
                // endif
                // if type('row_dom') == 'N' .and. !fl_date_next .and. !tip_telemed2
                // mdate_next := ctod('')
                // @ row_dom,35 say space(42) color color1
                // endif
                If Type( 'row_dom' ) == 'N'
                  If ! tip_telemed2
                    If ! domuslugatfoms( mshifr1 )
                      m1dom := 0
                      mdom := Space( 20 )
                      @ row_dom, 1 Say Space( 34 ) Color color1
                    Endif
                    If ! fl_date_next
                      mdate_next := CToD( '' )
                      @ row_dom, 35 Say Space( 42 ) Color color1
                    Endif
                  Endif
                Endif
                If is_gist
                  @ row_dom, 2 Say ' Где проведено это исследование'
                  update_get( 'mgist' )
                Endif
                If !Empty( arr_usl1year )
                  f_usl1year( iif( Empty( mshifr1 ), mshifr, mshifr1 ), mshifr, mname_u )
                Endif
              Endif
            Endif
          Elseif get_k_usluga( mshifr, human->vzros_reb, @fl )
            box_shadow( r1 - 5, 40, r1 - 3, 77, cColorStMsg, 'Комплексная услуга', cColorSt2Msg )
            @ r1 - 4, 41 Say PadC( 'Количество услуг - ' + lstr( Len( pr_k_usl ) ), 36 ) Color cColorStMsg
            mkol := mkol_1 := 1
            If fl  // сменить код врача и ассистента
              mvrach := Space( 35 )
              mtabn_vr := 0
              If mkod_vr > 0
                Select PERSO
                Goto ( mkod_vr )
                If !Eof() .and. !Deleted()
                  mvrach := PadR( perso->fio, 35 )
                  mtabn_vr := perso->tab_nom
                Endif
              Endif
              massist := Space( 35 )
              mtabn_as := 0
              If mkod_as > 0
                Select PERSO
                Goto ( mkod_as )
                If !Eof() .and. !Deleted()
                  massist := PadR( perso->fio, 35 )
                  mtabn_as := perso->tab_nom
                Endif
              Endif
            Endif
            fl := update_gets()
          Else
            fl := func_error( 4, 'Такого шифра нет в базе данных услуг.' )
          Endif
        Endif
      Endif
    Elseif k == 3 // Код врача
      old_kod := mkod_vr
      If Empty( mtabn_vr )
        mkod_vr := 0
        mvrach := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_vr, 5 ) )
        If Found()
          If Type( 'mkod_as' ) == 'N' .and. perso->kod == mkod_as
            fl := func_error( 4, msg1_err )
          Elseif mem_kat_va == 2 .and. perso->kateg != 1 .and. !uslugafeldsher( iif( Empty( mshifr1 ), mshifr, mshifr1 ) )
            fl := func_error( 4, 'Данный сотрудник не является ВРАЧОМ по штатному расписанию' )
          Else
            mkod_vr := perso->kod
            m1prvs := -ret_new_spec( perso->prvs, perso->prvs_new )
            mvrach := PadR( fam_i_o( perso->fio ) + ' ' + AllTrim( ret_str_spec( perso->PRVS_021 ) ), 45 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_vr
        update_get( 'mvrach' )
      Endif
    Elseif k == 4 // Код ассистента
      old_kod := mkod_as
      If Empty( mtabn_as )
        mkod_as := 0
        massist := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_as, 5 ) )
        If Found()
          If perso->kod == mkod_vr
            fl := func_error( 4, msg1_err )
          Elseif mem_kat_va == 2 .and. perso->kateg != 2
            fl := func_error( 4, 'Данный сотрудник не является СРЕДНИМ МЕД.ПЕРСОНАЛОМ по штатному расписанию' )
          Else
            mkod_as := perso->kod
            massist := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_as
        update_get( 'massist' )
      Endif
    Elseif k == 5 // Количество услуг
      If mkol_1 != get:original
        Eval( blk_sum )
        update_get( 'mstoim_1' )
      Endif
    Elseif k == 10  // код отделения
      If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
        If Type( 'mu_kod' ) == 'N' .and. mu_kod > 0 .and. mn_base == 0
          Select UO
          find ( Str( mu_kod, 4 ) )
          If Found() .and. !( Chr( m1otd ) $ uo->otdel )
            fl := func_error( 4, 'Данную услугу запрещено вводить в данном отделении!' )
          Endif
        Endif
        If fl
          motd := pr_arr[ i, 2 ]
          update_get( 'motd' )
          SetKey( K_F3, NIL )
          @ r1, 45 Say Space( 30 ) Color color13
        Endif
      Else
        fl := func_error( 4, 'Данный код отделения не найден!' )
      Endif
    Elseif k == 101  // зубная формула
      If !Empty( mzf )
        amsg := {}
        If mu_kod > 0 .and. mn_base == 0
          usl->( dbGoto( mu_kod ) )
          If usl->zf == 0
            AAdd( amsg, 'В данную услугу запрещен ввод зубной формулы!' )
          Endif
        Endif
        arr_zf := stverifyzf( mzf, human->date_r, human->n_data, @amsg )
        If Len( arr_zf ) > 0
          If Empty( mkod_diag )
            AAdd( amsg, 'Не введен диагноз!' )
          Endif
          stverdelzub( human->kod_k, arr_zf, dtoc4( mdate_u1 ), iif( mn_base == 0, 1, 7 ), mrec_hu, @amsg )
          If Len( amsg ) > 0
            n_message( amsg,, 'W/G', 'N/G',,, 'GR/G' )
          Endif
        Endif
      Endif
    Endif
    If !fl
      &( ReadVar() ) := get:original
    Elseif equalany( k, 3, 4 ) .and. mem_otdusl == 2 .and. Type( 'pr1arr_otd' ) == 'A'
      If ( old_kod := mkod_vr ) == 0
        old_kod := mkod_as
      Endif
      If old_kod > 0 .and. mn_base == 0
        Select PERSO
        Goto ( old_kod )
        If iif( yes_many_uch, .t., perso->uch == glob_uch[ 1 ] ) .and. ;
            perso->otd > 0 .and. ( i := AScan( pr1arr_otd, {| x| x[ 1 ] == perso->otd } ) ) > 0
          Select UO
          find ( Str( mu_kod, 4 ) )
          If Found() .and. !( Chr( perso->otd ) $ uo->otdel )
            fl := func_error( 4, 'Данную услугу запрещено вводить в отделении "' + AllTrim( pr1arr_otd[ i, 2 ] ) + '"!' )
            &( ReadVar() ) := get:original
          Else
            m1otd := perso->otd
            motd := pr1arr_otd[ i, 2 ]
            update_get( 'm1otd' )
            update_get( 'motd' )
          Endif
        Else
          &( ReadVar() ) := get:original
          If iif( yes_many_uch, .t., perso->uch == glob_uch[ 1 ] )
            fl := func_error( 4, 'Не проставлено отделение, в котором работает данный человек!' )
          Else
            fl := func_error( 4, 'Данный человек работает в другом учреждении!' )
          Endif
        Endif
      Endif
    Endif
  Endif
  Return fl
