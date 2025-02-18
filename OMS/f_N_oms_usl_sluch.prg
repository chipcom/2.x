#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.02.25 ввод услуг в лист учёта
Function f2oms_usl_sluch( nKey, oBrow )

  Static skod_k := 0, skod_human := 0, SKOD_DIAG, SZF, ;
    st_vzrosl, st_arr_dbf, skod_vr, skod_as, aksg := {}
  Local flag := -1, buf := SaveScreen(), fl := .f., rec, max_date, new_date, ;
    i1, k, i, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := SetColor(), ;
    rec_tmp := tmp->( RecNo() ), arr_u, arr_dni, st_arr_dbf_s, ;
    date_tmp := tmp->date_u1, ta, lvid_mp, lerr_mp, v, ;
    uch_otd := saveuchotd(), in_array, out_array, pic_diag := '@K@!', ;
    k_read := 0, count_edit := 0, bg := {| o, k| get_mkb10( o, k, .t. ) }
  Local mm_dom := { { 'в поликлинике', 0 }, ;
    { 'на дому      ', -1 } }
  Local tmSel
  Local aOptions :=  { 'Нет', 'Да' }, nChoice
  Local blk_col
  Local lTypeLUMedReab := .f.
  Local aUslMedReab
  Local mdate_end
  Local aReab, mvto := 0
  Local info_disp_nabl := 0

  Static old_date_usl, new_date_usl

  lTypeLUMedReab := is_lu_med_reab()

  If mem_dom_aktiv == 1
    AAdd( mm_dom, { 'на дому-АКТИВ', -2 } )
  Endif
  Private r1 := 10, mrec_hu := tmp->rec_hu
  Do Case
  Case nKey == K_F6 .and. ( HUMAN->K_DATA >= 0d20220101 ) .and. service_requires_implants( tmp->shifr_u, tmp->date_u1 )
    view_implantant( collect_implantant( glob_perso, tmp->rec_hu ), new_date_usl, ( new_date_usl != old_date_usl ) )

    blk_col := {|| iif( ! service_requires_implants( tmp->shifr_u, tmp->DATE_U ), { 1, 2 }, ;
      iif( ! exist_implantant_in_db( glob_perso, tmp->rec_hu ), { 9, 10 }, { 7, 8 } ) ) }
    oBrow:colorrect( blk_col )

  Case nKey == K_F9 .and. !Empty( aksg )
    f_put_arr_ksg( aksg )
  Case nKey == K_F10 .and. tmp->kod > 0 .and. f_esc_enter( 'запоминания услуг' )
    mywait()
    st_vzrosl := ( human->vzros_reb == 0 )
    st_arr_dbf := {}
    Select TMP
    adbf1 := Array( _HU_LEN )
    Go Top
    Do While !Eof()
      adbf1[ _HU_DATE_U1 ] := tmp->date_u1
      adbf1[ _HU_U_KOD   ] := tmp->U_KOD
      adbf1[ _HU_U_CENA  ] := tmp->U_CENA
      adbf1[ _HU_SHIFR_U ] := tmp->shifr_u
      adbf1[ _HU_SHIFR1  ] := tmp->shifr1
      adbf1[ _HU_NAME_U  ] := tmp->name_u
      adbf1[ _HU_IS_NUL  ] := tmp->is_nul
      adbf1[ _HU_IS_EDIT ] := tmp->is_edit
      adbf1[ _HU_IS_OMS  ] := tmp->is_oms
      adbf1[ _HU_KOL_RCP ] := tmp->dom
      adbf1[ _HU_KOD_VR  ] := tmp->KOD_VR
      adbf1[ _HU_KOD_AS  ] := tmp->KOD_AS
      adbf1[ _HU_OTD     ] := tmp->OTD
      adbf1[ _HU_KOL_1   ] := tmp->KOL_1
      adbf1[ _HU_STOIM_1 ] := tmp->STOIM_1
      adbf1[ _HU_KOD_DIAG ] := tmp->kod_diag
      adbf1[ _HU_PROFIL  ] := tmp->PROFIL
      adbf1[ _HU_PRVS    ] := tmp->PRVS
      adbf1[ _HU_N_BASE  ] := tmp->n_base
      AAdd( st_arr_dbf, AClone( adbf1 ) )
      Select TMP
      Skip
    Enddo
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    stat_msg( 'Услуги запомнены!' )
    mybell( 1, OK )
    RestScreen( buf )
    flag := 0
  Case eq_any( nKey, K_CTRL_F10, K_F11 ) .and. st_arr_dbf != NIL
    If !fl_found
      ColorWin( 6, 0, 6, 79, 'B/B', 'W+/RB' )
    Endif
    If st_vzrosl != ( human->vzros_reb == 0 )
      func_error( 4, 'Критерий "взрослый/ребенок" у данного больного отличается от предыдущего!' )
    Elseif f_esc_enter( 'копирования услуг' )
      mywait()
      last_date := human->n_data
      min_date := st_arr_dbf[ 1, _HU_DATE_U1 ]
      For k := 1 To Len( st_arr_dbf )
        min_date := Min( st_arr_dbf[ k, _HU_DATE_U1 ], min_date )
      Next
      Select HU
      For k := 1 To Len( st_arr_dbf )
        fl_found := .t.
        ++mvu[1, 1 ]  // услуги добавлены оператором
        new_date := human->n_data + ( st_arr_dbf[ k, _HU_DATE_U1 ] - min_date )
        If !Between( new_date, human->n_data, human->k_data )
          new_date := human->k_data
        Endif
        //
        If st_arr_dbf[ k, _HU_N_BASE ] == 0
          Select HU
          add1rec( 7 )
          rec := hu->( RecNo() )
          hu->kod     := human->kod
          hu->kod_vr  := st_arr_dbf[ k, _HU_KOD_VR ]
          hu->kod_as  := st_arr_dbf[ k, _HU_KOD_AS ]
          hu->u_koef  := 1
          hu->u_kod   := st_arr_dbf[ k, _HU_U_KOD ]
          hu->u_cena  := st_arr_dbf[ k, _HU_U_CENA ]
          hu->kol_rcp := st_arr_dbf[ k, _HU_KOL_RCP ]
          hu->is_edit := st_arr_dbf[ k, _HU_IS_EDIT ]
          hu->date_u  := dtoc4( new_date )
          hu->otd     := st_arr_dbf[ k, _HU_OTD    ]
          hu->kol     := st_arr_dbf[ k, _HU_KOL_1  ]
          hu->stoim   := st_arr_dbf[ k, _HU_STOIM_1 ]
          hu->kol_1   := st_arr_dbf[ k, _HU_KOL_1  ]
          hu->stoim_1 := st_arr_dbf[ k, _HU_STOIM_1 ]
          Select HU_
          Do While hu_->( LastRec() ) < hu->( RecNo() )
            Append Blank
          Enddo
          Goto ( hu->( RecNo() ) )
          g_rlock( forever )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
          hu_->kod_diag := human_kod_diag
          hu_->PROFIL   := st_arr_dbf[ k, _HU_PROFIL  ]
          hu_->PRVS     := st_arr_dbf[ k, _HU_PRVS    ]
        Else
          Select MOHU
          add1rec( 7 )
          rec := mohu->( RecNo() )
          mohu->kod     := human->kod
          mohu->kod_vr  := st_arr_dbf[ k, _HU_KOD_VR ]
          mohu->kod_as  := st_arr_dbf[ k, _HU_KOD_AS ]
          mohu->u_kod   := st_arr_dbf[ k, _HU_U_KOD ]
          mohu->u_cena  := st_arr_dbf[ k, _HU_U_CENA ]
          mohu->date_u  := dtoc4( new_date )
          mohu->otd     := st_arr_dbf[ k, _HU_OTD    ]
          mohu->kol_1   := st_arr_dbf[ k, _HU_KOL_1  ]
          mohu->stoim_1 := st_arr_dbf[ k, _HU_STOIM_1 ]
          mohu->ID_U    := mo_guid( 4, mohu->( RecNo() ) )
          mohu->kod_diag := human_kod_diag
          mohu->PROFIL  := st_arr_dbf[ k, _HU_PROFIL ]
          mohu->PRVS    := st_arr_dbf[ k, _HU_PRVS  ]
        Endif
        //
        Unlock
        Select TMP
        Append Blank
        tmp->kod      := human->kod
        tmp->date_u   := dtoc4( new_date )
        tmp->date_u1  := new_date
        tmp->rec_hu   := rec
        tmp->U_KOD    := st_arr_dbf[ k, _HU_U_KOD  ]
        tmp->U_CENA   := st_arr_dbf[ k, _HU_U_CENA ]
        tmp->shifr_u  := st_arr_dbf[ k, _HU_SHIFR_U ]
        tmp->shifr1   := st_arr_dbf[ k, _HU_SHIFR1 ]
        tmp->name_u   := st_arr_dbf[ k, _HU_NAME_U ]
        tmp->is_nul   := st_arr_dbf[ k, _HU_IS_NUL ]
        tmp->is_oms   := st_arr_dbf[ k, _HU_IS_OMS ]
        tmp->is_edit  := st_arr_dbf[ k, _HU_IS_EDIT ]
        tmp->dom      := st_arr_dbf[ k, _HU_KOL_RCP ]
        tmp->KOD_VR   := st_arr_dbf[ k, _HU_KOD_VR ]
        tmp->KOD_AS   := st_arr_dbf[ k, _HU_KOD_AS ]
        tmp->OTD      := st_arr_dbf[ k, _HU_OTD    ]
        tmp->KOL_1    := st_arr_dbf[ k, _HU_KOL_1  ]
        tmp->STOIM_1  := st_arr_dbf[ k, _HU_STOIM_1 ]
        tmp->kod_diag := human_kod_diag
        tmp->PROFIL   := st_arr_dbf[ k, _HU_PROFIL ]
        tmp->PRVS     := st_arr_dbf[ k, _HU_PRVS  ]
        tmp->n_base   := st_arr_dbf[ k, _HU_N_BASE ]
        last_date := Max( tmp->date_u1, last_date )
        If st_arr_dbf[ k, _HU_N_BASE ] == 0
          // переопределение цены
          If ( v := f1cena_oms( tmp->shifr_u, ;
              tmp->shifr1, ;
              ( human->vzros_reb == 0 ), ;
              human->k_data, ;
              tmp->is_nul, ;
              @fl ) ) != NIL
            tmp->is_oms := fl
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
      Next
      If human_->USL_OK < 3 // стационар
        aksg := f_usl_definition_ksg( human->kod )
      Endif
      summa_usl()
      stat_msg( 'Услуги скопированы!' )
      mybell( 1, OK )
      RestScreen( buf )
      f3oms_usl_sluch()
      vr_pr_1_den( 1, , u_other )
      Select TMP
      oBrow:gotop()
      flag := 0
    Elseif !fl_found
      flag := 1
    Endif
  Case eq_any( nKey, K_F4, K_F5, K_CTRL_F5 ) .and. tmp->kod > 0
    If ( arr_dni := uk_arr_dni( nKey ) ) != NIL
      mywait()
      st_arr_dbf_s := {}
      adbf1 := Array( _HU_LEN )
      If eq_any( nkey, K_F4, K_F5 )  // запомнить копируемую услугу
        adbf1[ _HU_DATE_U1 ] := tmp->date_u1
        adbf1[ _HU_U_KOD   ] := tmp->U_KOD
        adbf1[ _HU_U_CENA  ] := tmp->U_CENA
        adbf1[ _HU_SHIFR_U ] := tmp->shifr_u
        adbf1[ _HU_SHIFR1  ] := tmp->shifr1
        adbf1[ _HU_NAME_U  ] := tmp->name_u
        adbf1[ _HU_IS_NUL  ] := tmp->is_nul
        adbf1[ _HU_IS_OMS  ] := tmp->is_oms
        adbf1[ _HU_IS_EDIT ] := tmp->is_edit
        adbf1[ _HU_KOL_RCP ] := tmp->dom
        adbf1[ _HU_KOD_VR  ] := tmp->KOD_VR
        adbf1[ _HU_KOD_AS  ] := tmp->KOD_AS
        adbf1[ _HU_OTD     ] := tmp->OTD
        adbf1[ _HU_KOL_1   ] := tmp->KOL_1
        adbf1[ _HU_STOIM_1 ] := tmp->STOIM_1
        adbf1[ _HU_KOD_DIAG ] := tmp->kod_diag
        adbf1[ _HU_PROFIL  ] := tmp->PROFIL
        adbf1[ _HU_PRVS    ] := tmp->PRVS
        adbf1[ _HU_N_BASE  ] := tmp->n_base
        AAdd( st_arr_dbf_s, AClone( adbf1 ) )
      Else
        Select TMP
        Go Top
        Do While !Eof()
          If date_tmp == tmp->date_u1  // запомнить все услуги за этот день
            adbf1[ _HU_DATE_U1 ] := tmp->date_u1
            adbf1[ _HU_U_KOD   ] := tmp->U_KOD
            adbf1[ _HU_U_CENA  ] := tmp->U_CENA
            adbf1[ _HU_SHIFR_U ] := tmp->shifr_u
            adbf1[ _HU_SHIFR1  ] := tmp->shifr1
            adbf1[ _HU_NAME_U  ] := tmp->name_u
            adbf1[ _HU_IS_NUL  ] := tmp->is_nul
            adbf1[ _HU_IS_OMS  ] := tmp->is_oms
            adbf1[ _HU_IS_EDIT ] := tmp->is_edit
            adbf1[ _HU_KOL_RCP ] := tmp->dom
            adbf1[ _HU_KOD_VR  ] := tmp->KOD_VR
            adbf1[ _HU_KOD_AS  ] := tmp->KOD_AS
            adbf1[ _HU_OTD     ] := tmp->OTD
            adbf1[ _HU_KOL_1   ] := tmp->KOL_1
            adbf1[ _HU_STOIM_1 ] := tmp->STOIM_1
            adbf1[ _HU_KOD_DIAG ] := tmp->kod_diag
            adbf1[ _HU_PROFIL  ] := tmp->PROFIL
            adbf1[ _HU_PRVS    ] := tmp->PRVS
            adbf1[ _HU_N_BASE  ] := tmp->n_base
            AAdd( st_arr_dbf_s, AClone( adbf1 ) )
          Endif
          Select TMP
          Skip
        Enddo
      Endif
      For j := 1 To Len( arr_dni )
        For k := 1 To Len( st_arr_dbf_s )
          ++mvu[1, 1 ]  // услуги добавлены оператором
          If st_arr_dbf_s[ k, _HU_N_BASE ] == 0
            Select HU
            add1rec( 7 )
            hu->kod     := human->kod
            hu->kod_vr  := st_arr_dbf_s[ k, _HU_KOD_VR ]
            hu->kod_as  := st_arr_dbf_s[ k, _HU_KOD_AS ]
            hu->u_koef  := 1
            hu->u_kod   := st_arr_dbf_s[ k, _HU_U_KOD ]
            hu->u_cena  := st_arr_dbf_s[ k, _HU_U_CENA ]
            hu->is_edit := st_arr_dbf_s[ k, _HU_IS_EDIT ]
            hu->kol_rcp := st_arr_dbf_s[ k, _HU_KOL_RCP ]
            hu->date_u  := dtoc4( arr_dni[ j, 2 ] )
            hu->otd     := st_arr_dbf_s[ k, _HU_OTD    ]
            hu->kol     := st_arr_dbf_s[ k, _HU_KOL_1  ]
            hu->stoim   := st_arr_dbf_s[ k, _HU_STOIM_1 ]
            hu->kol_1   := st_arr_dbf_s[ k, _HU_KOL_1  ]
            hu->stoim_1 := st_arr_dbf_s[ k, _HU_STOIM_1 ]
            Select HU_
            Do While hu_->( LastRec() ) < hu->( RecNo() )
              Append Blank
            Enddo
            Goto ( hu->( RecNo() ) )
            g_rlock( forever )
            hu_->ID_U     := mo_guid( 3, hu_->( RecNo() ) )
            hu_->kod_diag := st_arr_dbf_s[ k, _HU_KOD_DIAG ]
            hu_->PROFIL   := st_arr_dbf_s[ k, _HU_PROFIL  ]
            hu_->PRVS     := st_arr_dbf_s[ k, _HU_PRVS    ]
            //
            mrec_hu := hu->( RecNo() )
          Else
            Select MOHU
            add1rec( 7 )
            mohu->kod     := human->kod
            mohu->kod_vr  := st_arr_dbf_s[ k, _HU_KOD_VR ]
            mohu->kod_as  := st_arr_dbf_s[ k, _HU_KOD_AS ]
            mohu->u_kod   := st_arr_dbf_s[ k, _HU_U_KOD ]
            mohu->u_cena  := st_arr_dbf_s[ k, _HU_U_CENA ]
            mohu->date_u  := dtoc4( arr_dni[ j, 2 ] )
            mohu->otd     := st_arr_dbf_s[ k, _HU_OTD    ]
            mohu->kol_1   := st_arr_dbf_s[ k, _HU_KOL_1  ]
            mohu->stoim_1 := st_arr_dbf_s[ k, _HU_STOIM_1 ]
            mohu->ID_U    := mo_guid( 4, mohu->( RecNo() ) )
            mohu->kod_diag := human_kod_diag
            mohu->PROFIL  := st_arr_dbf_s[ k, _HU_PROFIL ]
            mohu->PRVS    := st_arr_dbf_s[ k, _HU_PRVS  ]
            //
            mrec_hu := mohu->( RecNo() )
          Endif
          Unlock
          Select TMP
          Append Blank
          tmp->kod      := human->kod
          tmp->date_u   := dtoc4( arr_dni[ j, 2 ] )
          tmp->date_u1  := arr_dni[ j, 2 ]
          tmp->rec_hu   := mrec_hu
          tmp->U_KOD    := st_arr_dbf_s[ k, _HU_U_KOD   ]
          tmp->U_CENA   := st_arr_dbf_s[ k, _HU_U_CENA  ]
          tmp->shifr_u  := st_arr_dbf_s[ k, _HU_SHIFR_U ]
          tmp->shifr1   := st_arr_dbf_s[ k, _HU_SHIFR1  ]
          tmp->name_u   := st_arr_dbf_s[ k, _HU_NAME_U  ]
          tmp->is_nul   := st_arr_dbf_s[ k, _HU_IS_NUL  ]
          tmp->is_oms   := st_arr_dbf_s[ k, _HU_IS_OMS  ]
          tmp->is_edit  := st_arr_dbf_s[ k, _HU_IS_EDIT ]
          tmp->dom      := st_arr_dbf_s[ k, _HU_KOL_RCP ]
          tmp->KOD_VR   := st_arr_dbf_s[ k, _HU_KOD_VR  ]
          tmp->KOD_AS   := st_arr_dbf_s[ k, _HU_KOD_AS  ]
          tmp->OTD      := st_arr_dbf_s[ k, _HU_OTD     ]
          tmp->KOL_1    := st_arr_dbf_s[ k, _HU_KOL_1   ]
          tmp->STOIM_1  := st_arr_dbf_s[ k, _HU_STOIM_1 ]
          tmp->kod_diag := st_arr_dbf_s[ k, _HU_KOD_DIAG ]
          tmp->PROFIL   := st_arr_dbf_s[ k, _HU_PROFIL  ]
          tmp->PRVS     := st_arr_dbf_s[ k, _HU_PRVS    ]
          rec_tmp := tmp->( RecNo() )
          If st_arr_dbf_s[ k, _HU_N_BASE ] == 0
            // переопределение цены
            If ( v := f1cena_oms( tmp->shifr_u, ;
                tmp->shifr1, ;
                ( human->vzros_reb == 0 ), ;
                human->k_data, ;
                tmp->is_nul ) ) != NIL
              If !( Round( tmp->u_cena, 2 ) == Round( v, 2 ) )
                tmp->u_cena := v
                tmp->stoim_1 := round_5( tmp->u_cena * tmp->kol_1, 2 )
                Select HU
                g_rlock( forever )
                hu->u_cena := tmp->u_cena
                hu->stoim  := hu->stoim_1 := tmp->stoim_1
                Unlock
                Select TMP
              Endif
            Endif
          Endif
        Next
      Next
      If human_->USL_OK < 3 // стационар
        aksg := f_usl_definition_ksg( human->kod )
      Endif
      summa_usl()
      RestScreen( buf )
      f3oms_usl_sluch()
      vr_pr_1_den( 1, , u_other )
      Select TMP
      oBrow:gotop()
      Goto ( rec_tmp )
      SetColor( tmp_color )
      flag := 0
    Endif
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->kod > 0 )
    If !( skod_human == human->kod .and. skod_k == human->kod_k )
      skod_human := human->kod
      skod_k := human->kod_k
      SKOD_DIAG := PadR( human_kod_diag, 6 )
      SZF := Space( 30 )
    Endif
    If nKey == K_INS .and. !fl_found
      ColorWin( 6, 0, 6, 79, 'B/B', 'W+/RB' )
    Endif
    If mem_pom_va == 1 .or. skod_vr == NIL
      skod_vr := skod_as := 0
    Endif
    If mem_coplec == 2 .and. kod_lech_vr > 0
      skod_vr := kod_lech_vr
      kod_lech_vr := 0
    Endif
    mdate_end := iif( nKey == K_INS, last_date, tmp->date_end )
    Private motd := Space( 10 ), ;
      m1otd := iif( nKey == K_INS, iif( pr1otd == NIL, human->otd, pr1otd ), tmp->otd ), ;
      mu_kod := iif( nKey == K_INS, 0, tmp->u_kod ), ;
      mdate_u1 := iif( nKey == K_INS, last_date, tmp->date_u1 ), ;
      mis_nul := iif( nKey == K_INS, .f., tmp->is_nul ), ;
      mis_oms := iif( nKey == K_INS, .f., tmp->is_oms ), ;
      mis_edit := iif( nKey == K_INS, 0, tmp->is_edit ), ;
      mu_cena := iif( nKey == K_INS, 0, tmp->u_cena ), ;
      mkod_vr := iif( nKey == K_INS, skod_vr, tmp->kod_vr ), ;
      mkod_as := iif( nKey == K_INS, skod_as, tmp->kod_as ), ;
      mtabn_vr := 0, mtabn_as := 0, m1prvs := 0, ;
      mshifr := iif( nKey == K_INS, Space( 20 ), tmp->shifr_u ), ;
      mshifr1 := iif( nKey == K_INS, Space( 20 ), tmp->shifr1 ), ;
      mname_u := iif( nKey == K_INS, Space( 65 ), tmp->name_u ), ;
      mKOD_DIAG := iif( nKey == K_INS, SKOD_DIAG, tmp->KOD_DIAG ), ;
      mZF := iif( nKey == K_INS, SZF, tmp->ZF ), ;
      mpar_org := Space( 10 ), m1par_org := iif( nKey == K_INS, '', tmp->ZF ), ;
      is_gist := .f., mgist := Space( 10 ), m1gist := iif( nKey == K_INS, 4, tmp->is_edit ), ;
      m1PROFIL := iif( nKey == K_INS, human_->profil, tmp->profil ), mPROFIL, ;
      mkol_1 := iif( nKey == K_INS, 0, tmp->kol_1 ), ;
      mstoim_1 := iif( nKey == K_INS, 0, tmp->stoim_1 ), ;
      mn_base := iif( nKey == K_INS, 0, tmp->n_base ), ;
      mdom, m1dom := iif( nKey == K_INS, 0, tmp->dom ), ;
      mdate_next := iif( nKey == K_INS, CToD( '' ), tmp->DATE_NEXT ), fl_date_next := .f., ;
      mvrach := massist := Space( 35 ), vr_uva := as_uva := .t., ;
      arr_zf, is_usluga_zf := iif( nKey == K_INS, 0, tmp->is_zf ), ;
      m1NPR_MO := '', mNPR_MO := Space( 10 ), ;
      pr_k_usl := {}, ;  // массив комплексных услуг
    tip_par_org := iif( nKey == K_INS, '', tmp->par_org ), ;
      tip_telemed := 0, tip_telemed2 := .f., ;
      mnmic := Space( 10 ), m1nmic := 0, mnmic1 := Space( 10 ), m1nmic1 := 0, ;
      row_dom, gl_area := { 1, 0, MaxRow() -1, 79, 0 }

    // переменные для КСЛП
    Private mKSLP := iif( nKey == K_INS, Space( 10 ), iif( Empty( HUMAN_2->PC1 ), Space( 10 ), AllTrim( HUMAN_2->PC1 ) ) ), ;
      m1KSLP := iif( nKey == K_INS, Space( 10 ), iif( Empty( HUMAN_2->PC1 ), Space( 10 ), AllTrim( HUMAN_2->PC1 ) ) )

    Private mm_gist := { { 'в Волгоградском патал.анат.бюро', 4 }, ;
      { 'в нашей медицинской организации', 0 }, ;
      { 'в иногороднем патал.анат.бюро  ', 5 } }

    new_date_usl := mdate_u1
    If service_requires_implants( tmp->shifr_u, tmp->date_u1 )
      old_date_usl := mdate_u1
    Else
      old_date_usl := NIL
    Endif
    If nKey == K_ENTER
      mshifr1 := iif( Empty( mshifr1 ), mshifr, mshifr1 )
      If is_telemedicina( mshifr1, @tip_telemed2 )
        tip_telemed := 1
        If tip_telemed2
          m1nmic := Int( Val( BeforAtNum( ':', mzf ) ) )
          mnmic := inieditspr( A__MENUVERT, getnmic(), m1nmic )
          If m1nmic > 0
            m1nmic1 := Int( Val( AfterAtNum( ':', mzf ) ) )
            mnmic1 := inieditspr( A__MENUVERT, mm_danet, m1nmic1 )
          Endif
        Endif
      Endif
      fl_date_next := is_usluga_disp_nabl( mshifr, mshifr1 )
      mpar_org := ini_par_org( m1par_org, tip_par_org )
      If Left( mshifr1, 5 ) == '60.8.'
        mgist := inieditspr( A__MENUVERT, mm_gist, m1gist )
        is_gist := .t.
      Endif
      If pr_amb_reab .and. Left( mshifr1, 2 ) == '4.'
        m1NPR_MO := Left( mzf, 6 )
        If Empty( m1NPR_MO )
          m1NPR_MO := glob_mo[ _MO_KOD_TFOMS ]
        Endif
        If m1NPR_MO = '999999'
          mNPR_MO := '=== сторонняя МО (не в ОМС или не в Волгоградской области) ==='
        Else
          mNPR_MO := ret_mo( m1NPR_MO )[ _MO_SHORT_NAME ]
        Endif
      Endif
      Select TMP
      in_array := get_field()
    Endif
    If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
      motd := pr_arr[ i, 2 ]
    Elseif nKey == K_ENTER
      If yes_many_uch
        motd := '! некорректное отделение !'
      Else
        motd := '! не то учреждение !'
      Endif
    Endif
    If !Empty( mshifr )
      verify_uva( 2 )
    Endif
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mtabn_vr := perso->tab_nom
      m1prvs := -ret_new_spec( perso->prvs, perso->prvs_new )
      mvrach := PadR( fam_i_o( perso->fio ) + ' ' + AllTrim( ret_str_spec( perso->PRVS_021 ) ), 45 )
    Endif
    If mkod_as > 0
      Select PERSO
      Goto ( mkod_as )
      massist := AllTrim( PadR( perso->fio, 35 ) )
      mtabn_as := perso->tab_nom
    Endif
    If Empty( m1PROFIL )
      m1PROFIL := human_->profil
    Endif
    mdom := inieditspr( A__MENUVERT, mm_dom, m1dom )
    mPROFIL := PadR( inieditspr( A__MENUVERT, getv002(), m1PROFIL ), 69 )
    --r1
    box_shadow( r1 -1, 0, MaxRow() -1, 79, color8, ;
      iif( nKey == K_INS, 'Добавление новой услуги', ;
      'Редактирование услуги' ), iif( yes_color, 'RB+/B', 'W/N' ) )
    If mem_otdusl == 2
      Keyboard Chr( K_TAB )
    Endif
    Do While .t.
      SetColor( cDataCGet )
      ix := 1
      If mem_kodotd == 1 .or. mem_otdusl == 2
        @ r1 + ix, 2 Say 'Отделение, где оказана услуга' Get motd ;
          reader {| x| menu_reader( x, { {| k, r, c| get_otd( k, r + 1, c, .t. ) } }, A__FUNCTION, , , .f. ) }
      Else
        @ r1 + ix, 2 Say 'Отделение, где оказана услуга' Get m1otd Pict '99' ;
          when {| g| f5editkusl( g, 1, 10 ) } ;
          valid {| g| f5editkusl( g, 2, 10 ) }
        @ Row(), Col() + 2 Get motd Color color14 When .f.
      Endif
      ++ix
      @ r1 + ix, 2 Say 'Дата оказания услуги' Get mdate_u1 ;
        valid {| g| f5editkusl( g, 2, 1 ) }

      If human_->usl_ok == 3 .and. lTypeLUMedReab
        @ Row(), Col() + 2 Say 'Дата окончания оказания услуги' Get mdate_end ;
          when ( iif( nKey == K_INS, .t., ( AScan( mnogo_uslug_med_reab(), Left( mshifr1, 3 ) ) > 0 ) ) )
      Endif

      ++ix
      @ r1 + ix, 2 Say 'Диагноз по МКБ-10' Get mkod_diag Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        When when_diag() ;
        Valid val1_10diag( .t., .f., .f., human->k_data, iif( human_->novor == 0, human->pol, human_->pol2 ) )  // изменил после разговора с Антоновой 31.03.21
      If is_zf_stomat == 1
        ++ix
        @ r1 + ix, 2 Say 'Зубная формула' Get mzf Pict pic_diag ;
          valid {| g| f5editkusl( g, 2, 101 ) }
      Endif

      ++ix
      @ r1 + ix, 2 Say 'Шифр услуги' Get mshifr Pict '@!' ;
        when {| g| f5editkusl( g, 1, 2 ) } ;
        valid {| g| f5editkusl( g, 2, 2, lTypeLUMedReab, ;
        iif( Empty( human_2->PC5 ), nil, list2arr( human_2->PC5 )[ 1 ] ), ;
        iif( Empty( human_2->PC5 ), nil, list2arr( human_2->PC5 )[ 2 ] ), human->vzros_reb == 0 ) }

      @ Row(), 35 Say 'Цена услуги' Get mu_cena Pict pict_cena ;
        When .f. Color color14
      If human_->usl_ok < 3
        @ Row(), 58 Say 'КСЛП' Get mKSLP Pict '@!' When .f.
      Endif

      ++ix
      @ r1 + ix, 2 Say 'Услуга' Get mname_u When .f. Color color14
      ++ix
      row_dom := r1 + ix
      @ row_dom, 2 Say 'Где оказана услуга' Get mnmic ;
        reader {| x| menu_reader( x, getnmic(), A__MENUVERT, , , .f. ) } ;
        When tip_telemed2 ;
        valid {|| iif( m1nmic == 0, ( mnmic1 := Space( 10 ), m1nmic1 := 0 ), ), update_get( 'mnmic1' ) }
      ++ix
      @ row_dom + 1, 2 Say ' Получены ли результаты на дату окончания лечения' Get mnmic1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When m1nmic > 0

      If !tip_telemed2
        @ row_dom,     1 Say Space( 78 ) Color color1
        @ row_dom + 1, 1 Say Space( 78 ) Color color1
        If human_->usl_ok == 3
          If iif( Empty( mshifr ), .t., is_gist )
            @ row_dom, 2 Say ' Где проведено это исследование' Get mgist ;
              reader {| x| menu_reader( x, mm_gist, A__MENUVERT, , , .f. ) } ;
              When iif( Empty( mshifr ), .f., is_gist ) ;
              valid {|| mis_edit := m1gist, .t. }
          Endif
          If iif( Empty( mshifr ), .t., domuslugatfoms( mshifr1 ) ) .and. !( is_gist .or. pr_amb_reab )
            @ row_dom, 2 Say 'Где оказана услуга' Get mdom ;
              reader {| x| menu_reader( x, mm_dom, A__MENUVERT, , , .f. ) } ;
              When iif( Empty( mshifr ), .t., domuslugatfoms( mshifr1 ) )
          Endif
          If iif( Empty( mshifr ), pr_amb_reab, pr_amb_reab .and. Left( mshifr1, 2 ) == '4.' )
            @ row_dom, 2 Say 'Где оказана услуга' Get mNPR_MO ;
              reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c, , 2 ) } }, A__FUNCTION, , , .f. ) } ;
              When iif( Empty( mshifr ), pr_amb_reab, pr_amb_reab .and. Left( mshifr1, 2 ) == '4.' )
          Endif
          If ! ( is_gist .or. pr_amb_reab )
            info_disp_nabl := Val( SubStr( human_->DISPANS, 2, 1 ) )  // получим сведения по диспансерному наблюдению по основному заболеванию
            If ! ( eq_any( info_disp_nabl, 4, 6 ) ) // согласно письму ТФОМС 09-20-615 от 21.11.24
              @ row_dom, 35 Say 'Дата след.явки для дисп.набл-ия' Get mdate_next When fl_date_next valid {| g | check_next_visit_dn( g, mdate_u1 ) }
            Endif
          Endif
        Endif
        If human_->usl_ok < 3
          @ row_dom + 1, 2 Say 'Органы/части тела' Get mpar_org ;
            reader {| x| menu_reader( x, { {| k, r, c| get_par_org( r, c, k, tip_par_org ) } }, A__FUNCTION, , , .f. ) } ;
            When !Empty( tip_par_org )
        Endif
      Endif
      ++ix
      @ r1 + ix, 2 Say 'Профиль' Get MPROFIL ;
        reader {| x| menu_reader( x, tmp_V002, A__MENUVERT, , , .f. ) } ;
        When mis_edit == 0 ;
        valid {|| mprofil := PadR( mprofil, 69 ), .t. }
      For x := 1 To 3
        If mem_por_vr == x
          ++ix
          @ r1 + ix, 2 Say 'Врач(сред.медперсонал)' Get mtabn_vr Pict '99999' ;
            when {| g| mis_edit == 0 .and. f5editkusl( g, 1, 3 ) } ;
            valid {| g| f5editkusl( g, 2, 3 ) }
          @ Row(), Col() + 1 Get mvrach When .f. Color color14
        Endif
        If mem_por_ass == x
          ++ix
          @ r1 + ix, 2 Say 'Таб.№ ассистента' Get mtabn_as Pict '99999' ;
            when {| g| mis_edit == 0 .and. f5editkusl( g, 1, 4 ) } ;
            valid {| g| f5editkusl( g, 2, 4 ) }
          @ Row(), Col() + 3 Get massist When .f. Color color14
        Endif
        If mem_por_kol == x
          ++ix
          @ r1 + ix, 2 Say 'Количество услуг' Get mkol_1 Pict '999' ;
            when {| g| f5editkusl( g, 1, 5 ) } ;
            valid {| g| f5editkusl( g, 2, 5 ) }
        Endif
      Next
      ++ix
      @ r1 + ix, 2 Say 'Стоимость услуги' Get mstoim_1 Pict pict_cena When .f.
      status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи' )
      Set Key K_F11 To clear_gets
      Set Key K_CTRL_F10 To clear_gets
      // чтение введенной информации
      count_edit := myread(, , ++k_read )
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      SetKey( K_F5, NIL )
      SetKey( K_F11, NIL )
      SetKey( K_CTRL_F10, NIL )
      If eq_any( LastKey(), K_CTRL_F10, K_F11 )
        hb_keyPut( K_CTRL_F10 ) // keysend(KS_CTRL_F10)
      Elseif LastKey() != K_ESC
        new_date_usl := mdate_u1
        // запомним КСЛП для случая услуг круглосуточного и дневного стационара
        If Year( mdate_u1 ) >= 2021 .and. ( SubStr( Lower( mshifr ), 1, 2 ) == 'st' .or. SubStr( Lower( mshifr ), 1, 2 ) == 'ds' )
          // запомним КСЛП
          tmSel := Select( 'HUMAN_2' )
          If ( tmSel )->( dbRLock() )
            // G_RLock(forever)
            // HUMAN_2->PC1 := m1KSLP
            HUMAN_2->PC1 := mKSLP
            ( tmSel )->( dbRUnlock() )
          Endif
          Select( tmSel )
        Endif
        mkol := mkol_1
        mstoim := mstoim_1
        Private amsg := {}
        If Empty( mdate_u1 )
          func_error( 4, 'Не введена дата оказания услуги!' )
          Loop
        Endif
        If mdate_u1 < human->n_data .and. !( tip_telemed2 .and. m1nmic > 0 )
          func_error( 4, 'Введенная дата начал оказания услуги меньше даты начала лечения!' )
          Loop
        Endif
        If lTypeLUMedReab .and. ( AScan( mnogo_uslug_med_reab(), Left( mshifr1, 3 ) ) > 0 )   // left(mshifr1, 5) != '2.89.'
          aReab      := list2arr( human_2->PC5 )
          If Len( aReab ) > 2
            mvto := aReab[ 3 ]
          Endif
          aUslMedReab := ret_usluga_med_reab( mshifr, list2arr( human_2->PC5 )[ 1 ], list2arr( human_2->PC5 )[ 2 ], human->vzros_reb == 0, mvto )
          If ( !Empty( mdate_end ) )
            If mdate_end < mdate_u1
              func_error( 4, 'Введенная дата окончания многократной услуги меньше даты начала оказания услуги!' )
              Loop
            Endif
            If mdate_end > human->k_data
              func_error( 4, 'Введенная дата окончания многократной услуги больше даты окончания лечения!' )
              Loop
            Endif
          Endif
          If aUslMedReab != Nil .and. Len( aUslMedReab ) != 0
            If aUslMedReab[ 3 ] > mkol_1
              func_error( 4, 'Для услуги ' + AllTrim( mshifr ) + ' требуется минимум ' + lstr( aUslMedReab[ 3 ] ) + ' предоставлений!' )
              Loop
            Endif
            If aUslMedReab[ 3 ] > 1 .and. ( count_days( mdate_u1, mdate_end ) < aUslMedReab[ 3 ] )
              func_error( 4, 'Количество дней выполнения услуги меньше количества повторений услуги!' )
              Loop
            Endif
          Endif
        Endif
        If Len( pr_k_usl ) == 0 .and. emptyall( mu_kod, mshifr )
          func_error( 4, 'Не введена услуга!' )
          Loop
        Endif
        If Len( pr_k_usl ) == 0 .and. !mis_nul .and. Empty( mstoim_1 ) .and. !nuluslugatfoms( iif( Empty( mshifr1 ), mshifr, mshifr1 ) )
          func_error( 4, 'Не введена цена услуги!' )
          Loop
        Endif
        If mis_edit >= 0 .and. Empty( mkod_vr ) .and. !is_gist .and. is_usluga_tfoms( mshifr, mshifr1, human->k_data ) ;
            .and. !( pr_amb_reab .and. Left( mshifr1, 2 ) == '4.' .and. ( m1NPR_MO == '999999' .or. m1NPR_MO != glob_mo[ _MO_KOD_TFOMS ] ) )
          func_error( 4, 'Не введен врач!' )
          Loop
        Endif
        err_date_diap( mdate_u1, 'Дата оказания услуги' )
        mywait()
        If nKey == K_INS
          mvu[ 1, 2 ] += count_edit
        Else
          mvu[ 2, 2 ] += count_edit
        Endif
        If nKey == K_INS .and. Len( pr_k_usl ) > 0
          // комплексная услуга
          For i := 1 To Len( pr_k_usl )
            mshifr := pr_k_usl[ i, 1 ]
            mu_kod := pr_k_usl[ i, 3 ]
            mname_u := pr_k_usl[ i, 4 ]
            mu_cena := pr_k_usl[ i, 5 ]
            mshifr1 := pr_k_usl[ i, 8 ]
            mis_nul := pr_k_usl[ i, 9 ]
            mis_oms := pr_k_usl[ i, 10 ]
            mstoim := mstoim_1 := round_5( mu_cena * mkol_1, 2 )
            //
            Select HU
            add1rec( 7 )
            mrec_hu := hu->( RecNo() )
            fl_found := .t.
            Select TMP
            Append Blank
            rec_tmp := tmp->( RecNo() )
            ++mvu[1, 1 ]  // услуга добавлена оператором
            //
            Select HU
            Replace hu->kod     With human->kod, ;
              hu->kod_vr  With mkod_vr, ;
              hu->kod_as  With mkod_as, ;
              hu->u_koef  With 1, ;
              hu->u_kod   With mu_kod, ;
              hu->u_cena  With mu_cena, ;
              hu->is_edit With 0, ;
              hu->date_u  With dtoc4( mdate_u1 ), ;
              hu->otd     With m1otd, ;
              hu->kol     With mkol_1, ;
              hu->stoim   With mstoim_1, ;
              hu->kol_1   With mkol_1, ;
              hu->stoim_1 With mstoim_1
            If Len( arr_uva ) > 0 .and. ( j := AScan( arr_uva, {| x| Like( x[ 1 ], AllTrim( mshifr ) ) } ) ) > 0
              If arr_uva[ j, 2 ] == 1
                hu->kod_vr := 0
              Endif
              If arr_uva[ j, 3 ] == 1
                hu->kod_as := 0
              Endif
            Endif
            Select HU_
            Do While hu_->( LastRec() ) < mrec_hu
              Append Blank
            Enddo
            Goto ( mrec_hu )
            g_rlock( forever )
            hu_->ID_U   := mo_guid( 3, hu_->( RecNo() ) )
            hu_->PROFIL := m1PROFIL
            hu_->PRVS   := m1PRVS
            hu_->kod_diag := mkod_diag
            // if lTypeLUMedReab .and. !empty(mdate_end)
            // hu_->date_end := mdate_end
            // endif
            If lTypeLUMedReab .and. ( AScan( mnogo_uslug_med_reab(), Left( mshifr1, 3 ) ) > 0 )
              hu_->date_end := mdate_end
            Else
              hu_->date_end := mdate_u1
            Endif
            Unlock
            //
            pr1otd := m1otd
            adbf := Array( FCount() )
            AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
            Select TMP
            tmp->KOD     := human->kod
            tmp->DATE_U  := dtoc4( mdate_u1 )
            tmp->DATE_END := mdate_end
            tmp->U_KOD   := mu_kod
            tmp->U_CENA  := mu_cena
            tmp->KOD_VR  := mkod_vr
            tmp->KOD_AS  := mkod_as
            tmp->OTD     := m1otd
            tmp->KOL_1   := mkol_1
            tmp->STOIM_1 := mstoim_1
            tmp->kod_diag := mkod_diag
            tmp->ZF      := mzf
            tmp->PROFIL  := m1profil
            tmp->PRVS    := m1prvs
            tmp->date_u1 := mdate_u1
            tmp->shifr_u := mshifr
            tmp->shifr1  := mshifr1
            tmp->name_u  := mname_u
            tmp->is_nul  := mis_nul
            tmp->is_oms  := mis_oms
            tmp->rec_hu  := mrec_hu
            last_date := tmp->date_u1
          Next
        Else  // запись одной введённой услуги
          SKOD_DIAG := mkod_diag
          If mn_base == 1 .and. mu_kod == 0
            // добавляем в свой справочник федеральную услугу
            Select MOSU
            Set Order To 1
            find ( Str( -1, 6 ) )
            If Found()
              g_rlock( forever )
            Else
              addrec( 6 )
            Endif
            mu_kod := mosu->kod := RecNo()
            mosu->name   := mname_u
            mosu->shifr1 := mshifr1
            mosu->profil := m1PROFIL
          Endif
          // одна услуга
          If mn_base == 0
            If human_->usl_ok == 3 .and. Left( mshifr1, 5 ) == '2.89.'
              pr_amb_reab := .t.
            Endif
            Select HU
            If nKey == K_INS
              add1rec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              ++mvu[1, 1 ]  // услуга добавлена оператором
            Else
              Goto ( mrec_hu )
              g_rlock( forever )
              Select TMP
              Goto ( rec_tmp )
              ++mvu[2, 1 ]  // услуга отредактирована оператором
            Endif
            Select HU
            Replace hu->kod     With human->kod, ;
              hu->kod_vr  With mkod_vr, ;
              hu->kod_as  With mkod_as, ;
              hu->u_koef  With 1, ;
              hu->u_kod   With mu_kod, ;
              hu->u_cena  With mu_cena, ;
              hu->is_edit With mis_edit, ;
              hu->date_u  With dtoc4( mdate_u1 ), ;
              hu->otd     With m1otd, ;
              hu->kol     With mkol_1, ;
              hu->stoim   With mstoim_1, ;
              hu->kol_1   With mkol_1, ;
              hu->stoim_1 With mstoim_1
            If domuslugatfoms( iif( Empty( mshifr1 ), mshifr, mshifr1 ) )
              hu->KOL_RCP := m1dom
            Endif
            Select HU_
            Do While hu_->( LastRec() ) < mrec_hu
              Append Blank
            Enddo
            Goto ( mrec_hu )
            g_rlock( forever )
            If nKey == K_INS .or. !valid_guid( hu_->ID_U )
              hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
            Endif
            hu_->PROFIL   := m1PROFIL
            hu_->PRVS     := m1PRVS
            hu_->kod_diag := mkod_diag
            If lTypeLUMedReab .and. !Empty( mdate_end )
              hu_->date_end := mdate_end
            Else
              hu_->date_end := CToD( '' )
            Endif
            If pr_amb_reab .and. Left( mshifr1, 2 ) == '4.'
              hu_->zf := m1NPR_MO
            Endif
          Else
            Select MOHU
            If nKey == K_INS
              add1rec( 7 )
              mrec_hu := mohu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              ++mvu[1, 1 ]  // услуга добавлена оператором
            Else
              Goto ( mrec_hu )
              g_rlock( forever )
              Select TMP
              Goto ( rec_tmp )
              ++mvu[2, 1 ]  // услуга отредактирована оператором
            Endif
            Select MOHU
            mohu->kod     := human->kod
            mohu->kod_vr  := mkod_vr
            mohu->kod_as  := mkod_as
            mohu->u_kod   := mu_kod
            mohu->u_cena  := mu_cena
            mohu->date_u  := dtoc4( mdate_u1 )
            mohu->otd     := m1otd
            mohu->kol_1   := mkol_1
            mohu->stoim_1 := mstoim_1
            If nKey == K_INS .or. !valid_guid( mohu->ID_U )
              mohu->ID_U  := mo_guid( 4, mohu->( RecNo() ) )
            Endif
            mohu->PROFIL  := m1PROFIL
            mohu->PRVS    := m1PRVS
            mohu->kod_diag := mkod_diag
            If is_zf_stomat == 1
              mohu->ZF    := mzf
            Elseif tip_telemed2
              mohu->ZF    := iif( m1nmic > 0, lstr( m1nmic ) + ':' + lstr( m1nmic1 ), '' )
            Else
              mohu->ZF    := m1par_org
            Endif
            //
            mrec_hu := mohu->( RecNo() )
            If is_zf_stomat == 1
              If ValType( is_usluga_zf ) == 'N' .and. is_usluga_zf == 1 ; // должна быть формула зуба
                .and. stverifykolzf( arr_zf, mkol_1, @amsg ) // проверка по количеству зубов
                func_error( 4, amsg[ 1 ] )
              Endif
              // STappendDelZ(human->kod_k, mzf, mohu->date_u, mohu->u_kod)
              Select MOHU
            Endif
          Endif
          Unlock
          //
          pr1otd := m1otd
            /*if is_zf_stomat == 1
              STappend(iif(mn_base == 0, 1, 7), mrec_hu, human->kod_k, hu->date_u, mu_kod, mkod_vr, mzf, mkod_diag)
            endif*/
          Select TMP
          tmp->KOD     := human->kod
          tmp->DATE_U  := dtoc4( mdate_u1 )
          tmp->DATE_END := mdate_end
          tmp->DATE_NEXT := mdate_next
          tmp->U_KOD   := mu_kod
          tmp->U_CENA  := mu_cena
          tmp->KOD_VR  := mkod_vr
          tmp->KOD_AS  := mkod_as
          tmp->OTD     := m1otd
          tmp->KOL_1   := mkol_1
          tmp->STOIM_1 := mstoim_1
          tmp->kod_diag := mkod_diag
          If is_zf_stomat == 1
            tmp->ZF    := mzf
          Elseif tip_telemed2
            tmp->ZF    := iif( m1nmic > 0, lstr( m1nmic ) + ':' + lstr( m1nmic1 ), '' )
          Elseif pr_amb_reab .and. Left( mshifr1, 2 ) == '4.'
            tmp->ZF    := m1NPR_MO
          Else
            tmp->ZF    := m1par_org
          Endif
          tmp->PROFIL  := m1profil
          tmp->PRVS    := m1prvs
          tmp->date_u1 := mdate_u1
          tmp->shifr_u := mshifr
          tmp->shifr1  := mshifr1
          tmp->name_u  := mname_u
          tmp->is_nul  := mis_nul
          tmp->is_oms  := mis_oms
          tmp->is_edit := mis_edit
          If nKey == K_INS
            tmp->is_zf := is_usluga_zf
          Endif
          tmp->par_org := tip_par_org
          tmp->n_base  := mn_base
          tmp->dom     := m1dom
          tmp->rec_hu  := mrec_hu
          last_date := tmp->date_u1
        Endif
        aksg := f_usl_definition_ksg( human->kod )
        summa_usl()
        If mem_pom_va == 2
          skod_vr := mkod_vr
          skod_as := mkod_as
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found .and. !eq_any( LastKey(), K_CTRL_F10, K_F11 )
      flag := 1
    Endif
    RestScreen( buf )
    f3oms_usl_sluch()
    vr_pr_1_den( 1, , u_other )
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. tmp->kod > 0 .and. f_esc_enter( 2 )
    mywait()
    ++mvu[3, 1 ]  // услуга удалена оператором
    If is_zf_stomat == 1  .and. tmp->n_base == 1 .and. !Empty( mohu->zf )
      // STDelDelZ(human->kod_k, mohu->zf, mohu->u_kod)
    Endif
    If tmp->n_base == 0
      Select HU
      Goto ( tmp->rec_hu )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
    Else
      Select MOHU
      Goto ( tmp->rec_hu )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
    Endif
    Select TMP
    deleterec( .t. )  // с пометкой на удаление
    aksg := f_usl_definition_ksg( human->kod )
    summa_usl()
    vr_pr_1_den( 1, , u_other )

    // удалим имплантанты
    delete_implantants( human->kod, tmp->rec_hu )

    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f.
      Keyboard Chr( K_INS )
    Endif
    flag := 0
    RestScreen( buf )
    f3oms_usl_sluch()
  Otherwise
    Keyboard ''
  Endcase
  restuchotd( uch_otd )
  Return flag

// 17.03.22
Function f_oms_usl_sluch( oBrow )

  Local oColumn, blk_color

  blk_color := {|| iif( ! service_requires_implants( tmp->shifr_u, tmp->DATE_U ), { 1, 2 }, ;
    iif( ! exist_implantant_in_db( glob_perso, tmp->rec_hu ), { 9, 10 }, { 7, 8 } ) ) }  // голубовато - зеленовато

  oColumn := TBColumnNew( ' NN; пп', {|| tmp->number } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 1
    oColumn := TBColumnNew( 'Дата; усл.', {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( ' Шифр услуги', {|| iif( tmp->dom == -1, PadR( tmp->shifr_u, 11 ) + 'дом', ;
    iif( tmp->dom == -2, PadR( tmp->shifr_u, 11 ) + 'д-А', ;
    PadR( tmp->shifr_u, 14 ) ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 2
    oColumn := TBColumnNew( 'Дата; усл.', {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( 'Отде-;ление', {|| otd->short_name } )
  oColumn:defColor := { 6, 6 }
  oColumn:colorBlock := {|| { 6, 6 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'МКБ10', {|| tmp->kod_diag } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Профиль услуги', {|| PadR( inieditspr( A__MENUVERT, getv002(), tmp->PROFIL ), 15 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Врач', {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Асс.', {|| put_val( ret_tabn( tmp->kod_as ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол;усл', {|| Str( tmp->kol_1, 3 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Общая; ст-ть', {|| put_kop( tmp->stoim_1, 8 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь' )
  Return Nil

// 07.11.22
Function f1oms_usl_sluch()

  Local nRow := Row(), nCol := Col(), s := tmp->name_u, lcolor := cDataCSay
  Local strImplInfo := 'Услуга требует ввода данных по имплантантам. F6 - ред.'
  Local strImplExists := 'Информация по имплантантам введена. F6 - ред.'

  If is_zf_stomat == 1 .and. !Empty( tmp->zf )
    s := AllTrim( tmp->zf ) + ' / ' + s
    lcolor := color8
  Endif
  @ MaxRow() -2, 2 Say PadR( s, 65 ) Color lcolor
  If Empty( tmp->u_cena )
    s := iif( tmp->n_base == 0, '', 'ФФОМС' )
  Else
    s := AllTrim( dellastnul( tmp->u_cena, 10, 2 ) )
  Endif
  @ MaxRow() -2, 68 Say PadC( s, 11 ) Color cDataCSay
  f3oms_usl_sluch()
  @ nRow, nCol Say ''

  // проверим наличие имплантов
  If ( Year( human->k_data ) > 2021 ) .and. service_requires_implants( tmp->shifr_u, tmp->DATE_U )
    If exist_implantant_in_db( glob_perso, tmp->rec_hu )
      @ 2, 80 - Len( strImplExists ) Say PadL( strImplExists, Len( strImplExists ) ) Color 'W+/R'
    Else
      @ 2, 80 - Len( strImplInfo ) Say PadL( strImplInfo, Len( strImplInfo ) ) Color 'W+/R'
    Endif
  Else
    @ 2, 80 - Len( strImplInfo ) Say Replicate( ' ', Len( strImplInfo ) )
  Endif
  Return Nil

//
Function f3oms_usl_sluch()

  @ MaxRow() -4, 59 Say PadL( 'Итого: ' + lstr( human->cena_1, 11, 2 ), 20 ) Color 'W+/N'
  Return Nil
