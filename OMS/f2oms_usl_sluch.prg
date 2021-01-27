#include "inkey.ch"
#include "..\..\_mylib_hbt\function.ch"
#include "..\..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"


***** 13.10.20 ввод услуг в лист учёта
Function f2oms_usl_sluch(nKey,oBrow)
  Static skod_k := 0, skod_human := 0, SKOD_DIAG, SZF,;
         st_vzrosl, st_arr_dbf, skod_vr, skod_as, aksg := {}
  LOCAL flag := -1, buf := savescreen(), fl := .f., rec, max_date, new_date,;
        i1, k, i, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
        rec_tmp := tmp->(recno()), arr_u, arr_dni, st_arr_dbf_s,;
        date_tmp := tmp->date_u1, ta, lvid_mp, lerr_mp, v,;
        uch_otd := saveuchotd(), in_array, out_array, pic_diag := "@K@!",;
        k_read := 0, count_edit := 0, bg := {|o,k| get_MKB10(o,k,.t.) }
  Local mm_dom := {{"в поликлинике", 0},;
                   {"на дому      ",-1}}
  if mem_dom_aktiv == 1
       aadd(mm_dom,{"на дому-АКТИВ",-2})
  endif
  Private r1 := 10, mrec_hu := tmp->rec_hu
  do case
    case nKey == K_F9 .and. !empty(aksg)
      f_put_arr_ksg(aksg)
    case nKey == K_F10 .and. tmp->kod > 0 .and. f_Esc_Enter("запоминания услуг")
      mywait()
      st_vzrosl := (human->vzros_reb==0)
      st_arr_dbf := {}
      select TMP
      adbf1 := array(_HU_LEN)
      go top
      do while !eof()
        adbf1[_HU_DATE_U1 ] := tmp->date_u1
        adbf1[_HU_U_KOD   ] := tmp->U_KOD
        adbf1[_HU_U_CENA  ] := tmp->U_CENA
        adbf1[_HU_SHIFR_U ] := tmp->shifr_u
        adbf1[_HU_SHIFR1  ] := tmp->shifr1
        adbf1[_HU_NAME_U  ] := tmp->name_u
        adbf1[_HU_IS_NUL  ] := tmp->is_nul
        adbf1[_HU_IS_EDIT ] := tmp->is_edit
        adbf1[_HU_IS_OMS  ] := tmp->is_oms
        adbf1[_HU_KOL_RCP ] := tmp->dom
        adbf1[_HU_KOD_VR  ] := tmp->KOD_VR
        adbf1[_HU_KOD_AS  ] := tmp->KOD_AS
        adbf1[_HU_OTD     ] := tmp->OTD
        adbf1[_HU_KOL_1   ] := tmp->KOL_1
        adbf1[_HU_STOIM_1 ] := tmp->STOIM_1
        adbf1[_HU_KOD_DIAG] := tmp->kod_diag
        adbf1[_HU_PROFIL  ] := tmp->PROFIL
        adbf1[_HU_PRVS    ] := tmp->PRVS
        adbf1[_HU_N_BASE  ] := tmp->n_base
        aadd(st_arr_dbf, aclone(adbf1) )
        select TMP
        skip
      enddo
      select TMP
      oBrow:goTop()
      goto (rec_tmp)
      stat_msg("Услуги запомнены!") ; mybell(1,OK)
      restscreen(buf)
      flag := 0
    case eq_any(nKey,K_CTRL_F10,K_F11) .and. st_arr_dbf != NIL
      if !fl_found
        colorwin(6,0,6,79,"B/B","W+/RB")
      endif
      if st_vzrosl != (human->vzros_reb==0)
        func_error(4,'Критерий "взрослый/ребенок" у данного больного отличается от предыдущего!')
      elseif f_Esc_Enter("копирования услуг")
        mywait()
        last_date := human->n_data
        min_date := st_arr_dbf[1,_HU_DATE_U1]
        for k := 1 to len(st_arr_dbf)
          min_date := min(st_arr_dbf[k,_HU_DATE_U1],min_date)
        next
        select HU
        for k := 1 to len(st_arr_dbf)
          fl_found := .t.
          ++mvu[1,1]  // услуги добавлены оператором
          new_date := human->n_data + (st_arr_dbf[k,_HU_DATE_U1] - min_date)
          if !between(new_date,human->n_data,human->k_data)
            new_date := human->k_data
          endif
          if st_arr_dbf[k,_HU_N_BASE] == 0
            select HU
            Add1Rec(7)
            rec := hu->(recno())
            hu->kod     := human->kod
            hu->kod_vr  := st_arr_dbf[k,_HU_KOD_VR]
            hu->kod_as  := st_arr_dbf[k,_HU_KOD_AS]
            hu->u_koef  := 1
            hu->u_kod   := st_arr_dbf[k,_HU_U_KOD ]
            hu->u_cena  := st_arr_dbf[k,_HU_U_CENA]
            hu->kol_rcp := st_arr_dbf[k,_HU_KOL_RCP]
            hu->is_edit := st_arr_dbf[k,_HU_IS_EDIT]
            hu->date_u  := dtoc4(new_date)
            hu->otd     := st_arr_dbf[k,_HU_OTD    ]
            hu->kol     := st_arr_dbf[k,_HU_KOL_1  ]
            hu->stoim   := st_arr_dbf[k,_HU_STOIM_1]
            hu->kol_1   := st_arr_dbf[k,_HU_KOL_1  ]
            hu->stoim_1 := st_arr_dbf[k,_HU_STOIM_1]
            select HU_
            do while hu_->(lastrec()) < hu->(recno())
              APPEND BLANK
            enddo
            goto (hu->(recno()))
            G_RLock(forever)
            hu_->ID_U := mo_guid(3,hu_->(recno()))
            hu_->kod_diag := human_kod_diag
            hu_->PROFIL   := st_arr_dbf[k,_HU_PROFIL  ]
            hu_->PRVS     := st_arr_dbf[k,_HU_PRVS    ]
          else
            select MOHU
            Add1Rec(7)
            rec := mohu->(recno())
            mohu->kod     := human->kod
            mohu->kod_vr  := st_arr_dbf[k,_HU_KOD_VR]
            mohu->kod_as  := st_arr_dbf[k,_HU_KOD_AS]
            mohu->u_kod   := st_arr_dbf[k,_HU_U_KOD ]
            mohu->u_cena  := st_arr_dbf[k,_HU_U_CENA]
            mohu->date_u  := dtoc4(new_date)
            mohu->otd     := st_arr_dbf[k,_HU_OTD    ]
            mohu->kol_1   := st_arr_dbf[k,_HU_KOL_1  ]
            mohu->stoim_1 := st_arr_dbf[k,_HU_STOIM_1]
            mohu->ID_U    := mo_guid(4,mohu->(recno()))
            mohu->kod_diag:= human_kod_diag
            mohu->PROFIL  := st_arr_dbf[k,_HU_PROFIL]
            mohu->PRVS    := st_arr_dbf[k,_HU_PRVS  ]
          endif
          //
          UNLOCK
          select TMP
          append blank
          tmp->kod      := human->kod
          tmp->date_u   := dtoc4(new_date)
          tmp->date_u1  := new_date
          tmp->rec_hu   := rec
          tmp->U_KOD    := st_arr_dbf[k,_HU_U_KOD  ]
          tmp->U_CENA   := st_arr_dbf[k,_HU_U_CENA ]
          tmp->shifr_u  := st_arr_dbf[k,_HU_SHIFR_U]
          tmp->shifr1   := st_arr_dbf[k,_HU_SHIFR1 ]
          tmp->name_u   := st_arr_dbf[k,_HU_NAME_U ]
          tmp->is_nul   := st_arr_dbf[k,_HU_IS_NUL ]
          tmp->is_oms   := st_arr_dbf[k,_HU_IS_OMS ]
          tmp->is_edit  := st_arr_dbf[k,_HU_IS_EDIT]
          tmp->dom      := st_arr_dbf[k,_HU_KOL_RCP]
          tmp->KOD_VR   := st_arr_dbf[k,_HU_KOD_VR ]
          tmp->KOD_AS   := st_arr_dbf[k,_HU_KOD_AS ]
          tmp->OTD      := st_arr_dbf[k,_HU_OTD    ]
          tmp->KOL_1    := st_arr_dbf[k,_HU_KOL_1  ]
          tmp->STOIM_1  := st_arr_dbf[k,_HU_STOIM_1]
          tmp->kod_diag := human_kod_diag
          tmp->PROFIL   := st_arr_dbf[k,_HU_PROFIL]
          tmp->PRVS     := st_arr_dbf[k,_HU_PRVS  ]
          tmp->n_base   := st_arr_dbf[k,_HU_N_BASE]
          last_date := max(tmp->date_u1,last_date)
          if st_arr_dbf[k,_HU_N_BASE] == 0
            // переопределение цены
  my_debug(," 1. f2oms_usl_sluch")
  
            if (v := f1cena_oms(tmp->shifr_u,;
                                tmp->shifr1,;
                                (human->vzros_reb==0),;
                                human->k_data,;
                                tmp->is_nul,;
                                @fl)) != NIL
              tmp->is_oms := fl
              if !(round(tmp->u_cena,2)==round(v,2))
                tmp->u_cena := v
                tmp->stoim_1 := round_5(tmp->u_cena * tmp->kol_1, 2)
                select HU
                G_RLock(forever)
                hu->u_cena := tmp->u_cena
                hu->stoim  := hu->stoim_1 := tmp->stoim_1
                UNLOCK
              endif
            endif
          endif
        next
        if human_->USL_OK < 3 // стационар
          aksg := f_usl_definition_KSG(human->kod)
        endif
        summa_usl()
        stat_msg("Услуги скопированы!") ; mybell(1,OK)
        restscreen(buf)
        f3oms_usl_sluch()
        vr_pr_1_den(1,,u_other)
        select TMP
        oBrow:goTop()
        flag := 0
      elseif !fl_found
        flag := 1
      endif
    case eq_any(nKey,K_F4,K_F5,K_CTRL_F5) .and. tmp->kod > 0
      if (arr_dni := uk_arr_dni(nKey)) != NIL
        mywait()
        st_arr_dbf_s := {}
        adbf1 := array(_HU_LEN)
        if eq_any(nkey,K_F4,K_F5)  // запомнить копируемую услугу
          adbf1[_HU_DATE_U1 ] := tmp->date_u1
          adbf1[_HU_U_KOD   ] := tmp->U_KOD
          adbf1[_HU_U_CENA  ] := tmp->U_CENA
          adbf1[_HU_SHIFR_U ] := tmp->shifr_u
          adbf1[_HU_SHIFR1  ] := tmp->shifr1
          adbf1[_HU_NAME_U  ] := tmp->name_u
          adbf1[_HU_IS_NUL  ] := tmp->is_nul
          adbf1[_HU_IS_OMS  ] := tmp->is_oms
          adbf1[_HU_IS_EDIT ] := tmp->is_edit
          adbf1[_HU_KOL_RCP ] := tmp->dom
          adbf1[_HU_KOD_VR  ] := tmp->KOD_VR
          adbf1[_HU_KOD_AS  ] := tmp->KOD_AS
          adbf1[_HU_OTD     ] := tmp->OTD
          adbf1[_HU_KOL_1   ] := tmp->KOL_1
          adbf1[_HU_STOIM_1 ] := tmp->STOIM_1
          adbf1[_HU_KOD_DIAG] := tmp->kod_diag
          adbf1[_HU_PROFIL  ] := tmp->PROFIL
          adbf1[_HU_PRVS    ] := tmp->PRVS
          adbf1[_HU_N_BASE  ] := tmp->n_base
          aadd(st_arr_dbf_s,aclone(adbf1))
        else
          select TMP
          go top
          do while !eof()
            if date_tmp == tmp->date_u1  // запомнить все услуги за этот день
              adbf1[_HU_DATE_U1 ] := tmp->date_u1
              adbf1[_HU_U_KOD   ] := tmp->U_KOD
              adbf1[_HU_U_CENA  ] := tmp->U_CENA
              adbf1[_HU_SHIFR_U ] := tmp->shifr_u
              adbf1[_HU_SHIFR1  ] := tmp->shifr1
              adbf1[_HU_NAME_U  ] := tmp->name_u
              adbf1[_HU_IS_NUL  ] := tmp->is_nul
              adbf1[_HU_IS_OMS  ] := tmp->is_oms
              adbf1[_HU_IS_EDIT ] := tmp->is_edit
              adbf1[_HU_KOL_RCP ] := tmp->dom
              adbf1[_HU_KOD_VR  ] := tmp->KOD_VR
              adbf1[_HU_KOD_AS  ] := tmp->KOD_AS
              adbf1[_HU_OTD     ] := tmp->OTD
              adbf1[_HU_KOL_1   ] := tmp->KOL_1
              adbf1[_HU_STOIM_1 ] := tmp->STOIM_1
              adbf1[_HU_KOD_DIAG] := tmp->kod_diag
              adbf1[_HU_PROFIL  ] := tmp->PROFIL
              adbf1[_HU_PRVS    ] := tmp->PRVS
              adbf1[_HU_N_BASE  ] := tmp->n_base
              aadd(st_arr_dbf_s,aclone(adbf1))
            endif
            select TMP
            skip
          enddo
        endif
        for j := 1 to len(arr_dni)
          for k := 1 to len(st_arr_dbf_s)
            ++mvu[1,1]  // услуги добавлены оператором
            if st_arr_dbf_s[k,_HU_N_BASE] == 0
              select HU
              Add1Rec(7)
              hu->kod     := human->kod
              hu->kod_vr  := st_arr_dbf_s[k,_HU_KOD_VR]
              hu->kod_as  := st_arr_dbf_s[k,_HU_KOD_AS]
              hu->u_koef  := 1
              hu->u_kod   := st_arr_dbf_s[k,_HU_U_KOD ]
              hu->u_cena  := st_arr_dbf_s[k,_HU_U_CENA]
              hu->is_edit := st_arr_dbf_s[k,_HU_IS_EDIT]
              hu->kol_rcp := st_arr_dbf_s[k,_HU_KOL_RCP]
              hu->date_u  := dtoc4(arr_dni[j,2])
              hu->otd     := st_arr_dbf_s[k,_HU_OTD    ]
              hu->kol     := st_arr_dbf_s[k,_HU_KOL_1  ]
              hu->stoim   := st_arr_dbf_s[k,_HU_STOIM_1]
              hu->kol_1   := st_arr_dbf_s[k,_HU_KOL_1  ]
              hu->stoim_1 := st_arr_dbf_s[k,_HU_STOIM_1]
              select HU_
              do while hu_->(lastrec()) < hu->(recno())
                APPEND BLANK
              enddo
              goto (hu->(recno()))
              G_RLock(forever)
              hu_->ID_U     := mo_guid(3,hu_->(recno()))
              hu_->kod_diag := st_arr_dbf_s[k,_HU_KOD_DIAG]
              hu_->PROFIL   := st_arr_dbf_s[k,_HU_PROFIL  ]
              hu_->PRVS     := st_arr_dbf_s[k,_HU_PRVS    ]
              //
              mrec_hu := hu->(recno())
            else
              select MOHU
              Add1Rec(7)
              mohu->kod     := human->kod
              mohu->kod_vr  := st_arr_dbf_s[k,_HU_KOD_VR]
              mohu->kod_as  := st_arr_dbf_s[k,_HU_KOD_AS]
              mohu->u_kod   := st_arr_dbf_s[k,_HU_U_KOD ]
              mohu->u_cena  := st_arr_dbf_s[k,_HU_U_CENA]
              mohu->date_u  := dtoc4(arr_dni[j,2])
              mohu->otd     := st_arr_dbf_s[k,_HU_OTD    ]
              mohu->kol_1   := st_arr_dbf_s[k,_HU_KOL_1  ]
              mohu->stoim_1 := st_arr_dbf_s[k,_HU_STOIM_1]
              mohu->ID_U    := mo_guid(4,mohu->(recno()))
              mohu->kod_diag:= human_kod_diag
              mohu->PROFIL  := st_arr_dbf_s[k,_HU_PROFIL]
              mohu->PRVS    := st_arr_dbf_s[k,_HU_PRVS  ]
              //
              mrec_hu := mohu->(recno())
            endif
            UNLOCK
            select TMP
            append blank
            tmp->kod      := human->kod
            tmp->date_u   := dtoc4(arr_dni[j,2])
            tmp->date_u1  := arr_dni[j,2]
            tmp->rec_hu   := mrec_hu
            tmp->U_KOD    := st_arr_dbf_s[k,_HU_U_KOD   ]
            tmp->U_CENA   := st_arr_dbf_s[k,_HU_U_CENA  ]
            tmp->shifr_u  := st_arr_dbf_s[k,_HU_SHIFR_U ]
            tmp->shifr1   := st_arr_dbf_s[k,_HU_SHIFR1  ]
            tmp->name_u   := st_arr_dbf_s[k,_HU_NAME_U  ]
            tmp->is_nul   := st_arr_dbf_s[k,_HU_IS_NUL  ]
            tmp->is_oms   := st_arr_dbf_s[k,_HU_IS_OMS  ]
            tmp->is_edit  := st_arr_dbf_s[k,_HU_IS_EDIT ]
            tmp->dom      := st_arr_dbf_s[k,_HU_KOL_RCP ]
            tmp->KOD_VR   := st_arr_dbf_s[k,_HU_KOD_VR  ]
            tmp->KOD_AS   := st_arr_dbf_s[k,_HU_KOD_AS  ]
            tmp->OTD      := st_arr_dbf_s[k,_HU_OTD     ]
            tmp->KOL_1    := st_arr_dbf_s[k,_HU_KOL_1   ]
            tmp->STOIM_1  := st_arr_dbf_s[k,_HU_STOIM_1 ]
            tmp->kod_diag := st_arr_dbf_s[k,_HU_KOD_DIAG]
            tmp->PROFIL   := st_arr_dbf_s[k,_HU_PROFIL  ]
            tmp->PRVS     := st_arr_dbf_s[k,_HU_PRVS    ]
            rec_tmp := tmp->(recno())
            if st_arr_dbf_s[k,_HU_N_BASE] == 0
              // переопределение цены
  my_debug(," 1. f2oms_usl_sluch")
  
              if (v := f1cena_oms(tmp->shifr_u,;
                                  tmp->shifr1,;
                                  (human->vzros_reb==0),;
                                  human->k_data,;
                                  tmp->is_nul)) != NIL
                if !(round(tmp->u_cena,2)==round(v,2))
                  tmp->u_cena := v
                  tmp->stoim_1 := round_5(tmp->u_cena * tmp->kol_1, 2)
                  select HU
                  G_RLock(forever)
                  hu->u_cena := tmp->u_cena
                  hu->stoim  := hu->stoim_1 := tmp->stoim_1
                  UNLOCK
                  select TMP
                endif
              endif
            endif
          next
        next
        if human_->USL_OK < 3 // стационар
          aksg := f_usl_definition_KSG(human->kod)
        endif
        summa_usl()
        restscreen(buf)
        f3oms_usl_sluch()
        vr_pr_1_den(1,,u_other)
        select TMP
        oBrow:goTop()
        goto (rec_tmp)
        setcolor(tmp_color)
        flag := 0
      endif
    case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->kod > 0)
      if !(skod_human == human->kod .and. skod_k == human->kod_k)
        skod_human := human->kod
        skod_k := human->kod_k
        SKOD_DIAG := padr(human_kod_diag,6)
        SZF := space(30)
      endif
      if nKey == K_INS .and. !fl_found
        colorwin(6,0,6,79,"B/B","W+/RB")
      endif
      if mem_pom_va == 1 .or. skod_vr == NIL
        skod_vr := skod_as := 0
      endif
      if mem_coplec == 2 .and. kod_lech_vr > 0
        skod_vr := kod_lech_vr
        kod_lech_vr := 0
      endif
      Private motd := space(10), ;
              m1otd := iif(nKey == K_INS, iif(pr1otd == NIL, human->otd, pr1otd), tmp->otd),;
              mu_kod := iif(nKey == K_INS, 0, tmp->u_kod),;
              mdate_u1 := iif(nKey == K_INS, last_date, tmp->date_u1),;
              mis_nul := iif(nKey == K_INS, .f., tmp->is_nul),;
              mis_oms := iif(nKey == K_INS, .f., tmp->is_oms),;
              mis_edit := iif(nKey == K_INS, 0, tmp->is_edit),;
              mu_cena := iif(nKey == K_INS, 0, tmp->u_cena),;
              mkod_vr := iif(nKey == K_INS, skod_vr, tmp->kod_vr),;
              mkod_as := iif(nKey == K_INS, skod_as, tmp->kod_as),;
              mtabn_vr := 0, mtabn_as := 0, m1prvs := 0,;
              mshifr := iif(nKey == K_INS, space(20), tmp->shifr_u),;
              mshifr1 := iif(nKey == K_INS, space(20), tmp->shifr1),;
              mname_u := iif(nKey == K_INS, space(65), tmp->name_u),;
              mKOD_DIAG := iif(nKey == K_INS, SKOD_DIAG, tmp->KOD_DIAG),;
              mZF := iif(nKey == K_INS, SZF, tmp->ZF),;
              mpar_org := space(10), m1par_org := iif(nKey == K_INS, "", tmp->ZF),;
              is_gist := .f., mgist := space(10), m1gist := iif(nKey == K_INS, 4, tmp->is_edit),;
              m1PROFIL := iif(nKey == K_INS, human_->profil, tmp->profil), mPROFIL,;
              mkol_1 := iif(nKey == K_INS, 0, tmp->kol_1),;
              mstoim_1 := iif(nKey == K_INS, 0, tmp->stoim_1),;
              mn_base := iif(nKey == K_INS, 0, tmp->n_base),;
              mdom, m1dom := iif(nKey == K_INS, 0, tmp->dom),;
              mdate_next := iif(nKey == K_INS, ctod(""), tmp->DATE_NEXT), fl_date_next := .f.,;
              mvrach := massist := space(35), vr_uva := as_uva := .t., ;
              arr_zf, is_usluga_zf := iif(nKey == K_INS, 0, tmp->is_zf),;
              m1NPR_MO := "", mNPR_MO := space(10),;
              pr_k_usl := {},;  // массив комплексных услуг
              tip_par_org := iif(nKey == K_INS, "", tmp->par_org),;
              tip_telemed := 0, tip_telemed2 := .f.,;
              mnmic := space(10), m1nmic := 0, mnmic1 := space(10), m1nmic1 := 0,;
              row_dom, gl_area := {1,0,maxrow()-1,79,0}
      Private mm_gist := {{"в Волгоградском патал.анат.бюро",4},;
                          {"в нашей медицинской организации",0},;
                          {"в иногороднем патал.анат.бюро  ",5}}
      if nKey == K_ENTER
        mshifr1 := iif(empty(mshifr1), mshifr, mshifr1)
        if is_telemedicina(mshifr1,@tip_telemed2)
          tip_telemed := 1
          if tip_telemed2
            m1nmic := int(val(beforatnum(":",mzf)))
            mnmic := inieditspr(A__MENUVERT, glob_nmic, m1nmic)
            if m1nmic > 0
              m1nmic1 := int(val(afteratnum(":",mzf)))
              mnmic1 := inieditspr(A__MENUVERT, mm_danet, m1nmic1)
            endif
          endif
        endif
        fl_date_next := is_usluga_disp_nabl(mshifr,mshifr1)
        mpar_org := ini_par_org(m1par_org,tip_par_org)
        if left(mshifr1,5) == "60.8."
          mgist := inieditspr(A__MENUVERT, mm_gist, m1gist)
          is_gist := .t.
        endif
        if pr_amb_reab .and. left(mshifr1,2)=='4.'
          m1NPR_MO := left(mzf,6)
          if empty(m1NPR_MO)
            m1NPR_MO := glob_mo[_MO_KOD_TFOMS]
          endif
          if m1NPR_MO = '999999'
            mNPR_MO := '=== сторонняя МО (не в ОМС или не в Волгоградской области) ==='
          else
            mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
          endif
        endif
        select TMP
        in_array := get_field()
      endif
      if (i := ascan(pr_arr,{|x| x[1] == m1otd } )) > 0
        motd := pr_arr[i,2]
      elseif nKey == K_ENTER
        if yes_many_uch
          motd := "! некорректное отделение !"
        else
          motd := "! не то учреждение !"
        endif
      endif
      if !empty(mshifr)
        verify_uva(2)
      endif
      if mkod_vr > 0
        select PERSO
        goto (mkod_vr)
        mtabn_vr := perso->tab_nom
        m1prvs := -ret_new_spec(perso->prvs,perso->prvs_new)
        mvrach := alltrim(padr(fam_i_o(perso->fio)+" "+ret_tmp_prvs(m1prvs),57))
      endif
      if mkod_as > 0
        select PERSO
        goto (mkod_as)
        massist := alltrim(padr(perso->fio,35))
        mtabn_as := perso->tab_nom
      endif
      if empty(m1PROFIL)
        m1PROFIL := human_->profil
      endif
      mdom := inieditspr(A__MENUVERT, mm_dom, m1dom)
      mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL), 69)
      --r1
      box_shadow(r1-1,0,maxrow()-1,79,color8,;
                 iif(nKey == K_INS,"Добавление новой услуги",;
                                   "Редактирование услуги"),iif(yes_color,"RB+/B","W/N"))
      if mem_otdusl == 2
        keyboard chr(K_TAB)
      endif
      do while .t.
        setcolor(cDataCGet)
        ix := 1
        if mem_kodotd == 1 .or. mem_otdusl == 2
          @ r1+ix,2 say "Отделение, где оказана услуга" get motd ;
                    reader {|x|menu_reader(x,{{|k,r,c| get_otd(k,r+1,c,.t.) }},A__FUNCTION,,,.f.)}
        else
          @ r1+ix,2 say "Отделение, где оказана услуга" get m1otd pict "99" ;
                    when {|g| f5editkusl(g,1,10) } ;
                    valid {|g| f5editkusl(g,2,10) }
          @ row(),col()+2 get motd color color14 when .f.
        endif
        ++ix
        @ r1+ix,2 say "Дата оказания услуги" get mdate_u1 ;
                  valid {|g| f5editkusl(g,2,1) }
        ++ix
        @ r1+ix,2 say "Диагноз по МКБ-10" get mkod_diag picture pic_diag ;
                  reader {|o|MyGetReader(o,bg)} ;
                  when when_diag() ;
                  valid val1_10diag(.t.,.f.,.f.,human->n_data,iif(human_->novor==0,human->pol,human_->pol2))
        if is_zf_stomat == 1
          ++ix
          @ r1+ix,2 say "Зубная формула" get mzf pict pic_diag ;
                    valid {|g| f5editkusl(g,2,101) }
        endif
        ++ix
        @ r1+ix,2 say "Шифр услуги" get mshifr pict "@!" ;
                  when {|g| f5editkusl(g,1,2) } ;
                  valid {|g| f5editkusl(g,2,2) }
        @ row(),40 say "Цена услуги" get mu_cena pict pict_cena ;
                   when .f. color color14
        ++ix
        @ r1+ix,2 say "Услуга" get mname_u when .f. color color14
        ++ix ; row_dom := r1+ix
        @ row_dom,2 say "Где оказана услуга" get mnmic ;
                    reader {|x|menu_reader(x,glob_nmic,A__MENUVERT,,,.f.)} ;
                    when tip_telemed2 ;
                    valid {|| iif(m1nmic == 0, (mnmic1 := space(10), m1nmic1 := 0), ), update_get("mnmic1") }
        ++ix
        @ row_dom+1,2 say " Получены ли результаты на дату окончания лечения" get mnmic1 ;
                      reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                      when m1nmic > 0
        if !tip_telemed2
          @ row_dom  ,1 say space(78) color color1
          @ row_dom+1,1 say space(78) color color1
          if human_->usl_ok == 3
            if iif(empty(mshifr), .t., is_gist)
             @ row_dom,2 say " Где проведено это исследование" get mgist ;
                         reader {|x|menu_reader(x,mm_gist,A__MENUVERT,,,.f.)} ;
                         when iif(empty(mshifr), .f., is_gist) ;
                         valid {|| mis_edit := m1gist, .t. }
            endif
            if iif(empty(mshifr), .t., DomUslugaTFOMS(mshifr1)) .and. !(is_gist .or. pr_amb_reab)
             @ row_dom,2 say "Где оказана услуга" get mdom ;
                         reader {|x|menu_reader(x,mm_dom,A__MENUVERT,,,.f.)} ;
                         when iif(empty(mshifr), .t., DomUslugaTFOMS(mshifr1))
            endif
            if iif(empty(mshifr), pr_amb_reab, pr_amb_reab.and.left(mshifr1,2)=='4.')
             @ row_dom,2 say "Где оказана услуга" get mNPR_MO ;
                         reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c,,2)}},A__FUNCTION,,,.f.)} ;
                         when iif(empty(mshifr), pr_amb_reab, pr_amb_reab.and.left(mshifr1,2)=='4.')
            endif
            if !(is_gist .or. pr_amb_reab)
             @ row_dom,35 say "Дата след.явки для дисп.набл-ия" get mdate_next when fl_date_next
            endif
          endif
          if human_->usl_ok < 3
            @ row_dom+1,2 say "Органы/части тела" get mpar_org ;
                        reader {|x|menu_reader(x,{{|k,r,c|get_par_org(r,c,k,tip_par_org)}},A__FUNCTION,,,.f.)} ;
                        when !empty(tip_par_org)
          endif
        endif
        ++ix
        @ r1+ix,2 say "Профиль" get MPROFIL ;
                  reader {|x|menu_reader(x,tmp_V002,A__MENUVERT,,,.f.)} ;
                  when mis_edit == 0 ;
                  valid {|| mprofil := padr(mprofil,69), .t. }
        for x := 1 to 3
          if mem_por_vr == x
            ++ix
            @ r1+ix,2 say "Врач(сред.медперсонал)" get mtabn_vr pict "99999" ;
                      when {|g| mis_edit == 0 .and. f5editkusl(g,1,3) } ;
                      valid {|g| f5editkusl(g,2,3) }
            @ row(),col()+3 get mvrach when .f. color color14
          endif
          if mem_por_ass == x
            ++ix
            @ r1+ix,2 say "Таб.№ ассистента" get mtabn_as pict "99999" ;
                      when {|g| mis_edit == 0 .and. f5editkusl(g,1,4) } ;
                      valid {|g| f5editkusl(g,2,4) }
            @ row(),col()+3 get massist when .f. color color14
          endif
          if mem_por_kol == x
            ++ix
            @ r1+ix,2 say "Количество услуг" get mkol_1 pict "999" ;
                      when {|g| f5editkusl(g,1,5) } ;
                      valid {|g| f5editkusl(g,2,5) }
          endif
        next
        ++ix
        @ r1+ix,2 say "Стоимость услуги" get mstoim_1 pict pict_cena ;
                  when .f.
        status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
        set key K_F11 to clear_gets
        set key K_CTRL_F10 to clear_gets
        count_edit := myread(,,++k_read)
        SetKey( K_F2, NIL )
        SetKey( K_F3, NIL )
        SetKey( K_F5, NIL )
        SetKey( K_F11, NIL )
        SetKey( K_CTRL_F10, NIL )
        if eq_any(lastkey(),K_CTRL_F10,K_F11)
          hb_KeyPut(K_CTRL_F10) //keysend(KS_CTRL_F10)
        elseif lastkey() != K_ESC
          mkol := mkol_1 ; mstoim := mstoim_1
          Private amsg := {}
          if empty(mdate_u1)
            func_error(4,"Не введена дата оказания услуги!")
            loop
          elseif mdate_u1 < human->n_data .and. !(tip_telemed2 .and. m1nmic > 0)
            func_error(4,"Введенная дата меньше даты начала лечения!")
            loop
          elseif len(pr_k_usl) == 0 .and. emptyall(mu_kod,mshifr)
            func_error(4,"Не введена услуга!")
            loop
          elseif len(pr_k_usl) == 0 .and. !mis_nul .and. empty(mstoim_1) .and. !NulUslugaTFOMS(iif(empty(mshifr1), mshifr, mshifr1))
            func_error(4,"Не введена цена услуги!")
            loop
          elseif mis_edit >= 0 .and. empty(mkod_vr) .and. !is_gist .and. is_usluga_TFOMS(mshifr,mshifr1,human->k_data) ;
             .and. !(pr_amb_reab .and. left(mshifr1,2)=='4.' .and. (m1NPR_MO=='999999' .or. m1NPR_MO!=glob_mo[_MO_KOD_TFOMS]))
            func_error(4,"Не введен врач!")
            loop
          else
            err_date_diap(mdate_u1,"Дата оказания услуги")
            mywait()
            if nKey == K_INS
              mvu[1,2] += count_edit
            else
              mvu[2,2] += count_edit
            endif
            if nKey == K_INS .and. len(pr_k_usl) > 0
              // комплексная услуга
              for i := 1 to len(pr_k_usl)
                mshifr := pr_k_usl[i,1]
                mu_kod := pr_k_usl[i,3]
                mname_u := pr_k_usl[i,4]
                mu_cena := pr_k_usl[i,5]
                mshifr1 := pr_k_usl[i,8]
                mis_nul := pr_k_usl[i,9]
                mis_oms := pr_k_usl[i,10]
                mstoim := mstoim_1 := round_5(mu_cena * mkol_1, 2)
                //
                select HU
                Add1Rec(7)
                mrec_hu := hu->(recno())
                fl_found := .t.
                select TMP
                append blank
                rec_tmp := tmp->(recno())
                ++mvu[1,1]  // услуга добавлена оператором
                //
                select HU
                replace hu->kod     with human->kod,;
                        hu->kod_vr  with mkod_vr,;
                        hu->kod_as  with mkod_as,;
                        hu->u_koef  with 1,;
                        hu->u_kod   with mu_kod,;
                        hu->u_cena  with mu_cena,;
                        hu->is_edit with 0,;
                        hu->date_u  with dtoc4(mdate_u1),;
                        hu->otd     with m1otd,;
                        hu->kol     with mkol_1,;
                        hu->stoim   with mstoim_1,;
                        hu->kol_1   with mkol_1,;
                        hu->stoim_1 with mstoim_1
                if len(arr_uva) > 0 .and. (j := ascan(arr_uva, {|x| like(x[1],alltrim(mshifr)) })) > 0
                  if arr_uva[j,2] == 1
                    hu->kod_vr := 0
                  endif
                  if arr_uva[j,3] == 1
                    hu->kod_as := 0
                  endif
                endif
                select HU_
                do while hu_->(lastrec()) < mrec_hu
                  APPEND BLANK
                enddo
                goto (mrec_hu)
                G_RLock(forever)
                hu_->ID_U   := mo_guid(3,hu_->(recno()))
                hu_->PROFIL := m1PROFIL
                hu_->PRVS   := m1PRVS
                hu_->kod_diag := mkod_diag
                UNLOCK
                //
                pr1otd := m1otd
                adbf := array(fcount())
                aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
                select TMP
                tmp->KOD     := human->kod
                tmp->DATE_U  := dtoc4(mdate_u1)
                tmp->U_KOD   := mu_kod
                tmp->U_CENA  := mu_cena
                tmp->KOD_VR  := mkod_vr
                tmp->KOD_AS  := mkod_as
                tmp->OTD     := m1otd
                tmp->KOL_1   := mkol_1
                tmp->STOIM_1 := mstoim_1
                tmp->kod_diag:= mkod_diag
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
              next
            else// запись одной введённой услуги
              SKOD_DIAG := mkod_diag
              if mn_base == 1 .and. mu_kod == 0
                // добавляем в свой справочник федеральную услугу
                select MOSU
                set order to 1
                FIND (STR(-1,6))
                if found()
                  G_RLock(forever)
                else
                  AddRec(6)
                endif
                mu_kod := mosu->kod := recno()
                mosu->name   := mname_u
                mosu->shifr1 := mshifr1
                mosu->profil := m1PROFIL
              endif
              // одна услуга
              if mn_base == 0
                if human_->usl_ok == 3 .and. left(mshifr1,5) == "2.89."
                  pr_amb_reab := .t.
                endif
                select HU
                if nKey == K_INS
                  Add1Rec(7)
                  mrec_hu := hu->(recno())
                  fl_found := .t.
                  select TMP
                  append blank
                  rec_tmp := tmp->(recno())
                  ++mvu[1,1]  // услуга добавлена оператором
                else
                  goto (mrec_hu)
                  G_RLock(forever)
                  select TMP
                  goto (rec_tmp)
                  ++mvu[2,1]  // услуга отредактирована оператором
                endif
                select HU
                replace hu->kod     with human->kod,;
                        hu->kod_vr  with mkod_vr,;
                        hu->kod_as  with mkod_as,;
                        hu->u_koef  with 1,;
                        hu->u_kod   with mu_kod,;
                        hu->u_cena  with mu_cena,;
                        hu->is_edit with mis_edit,;
                        hu->date_u  with dtoc4(mdate_u1),;
                        hu->otd     with m1otd,;
                        hu->kol     with mkol_1,;
                        hu->stoim   with mstoim_1,;
                        hu->kol_1   with mkol_1,;
                        hu->stoim_1 with mstoim_1
                if DomUslugaTFOMS(iif(empty(mshifr1), mshifr, mshifr1))
                  hu->KOL_RCP := m1dom
                endif
                select HU_
                do while hu_->(lastrec()) < mrec_hu
                  APPEND BLANK
                enddo
                goto (mrec_hu)
                G_RLock(forever)
                if nKey == K_INS .or. !valid_GUID(hu_->ID_U)
                  hu_->ID_U := mo_guid(3,hu_->(recno()))
                endif
                hu_->PROFIL   := m1PROFIL
                hu_->PRVS     := m1PRVS
                hu_->kod_diag := mkod_diag
                if pr_amb_reab .and. left(mshifr1,2)=='4.'
                  hu_->zf := m1NPR_MO
                endif
              else
                select MOHU
                if nKey == K_INS
                  Add1Rec(7)
                  mrec_hu := mohu->(recno())
                  fl_found := .t.
                  select TMP
                  append blank
                  rec_tmp := tmp->(recno())
                  ++mvu[1,1]  // услуга добавлена оператором
                else
                  goto (mrec_hu)
                  G_RLock(forever)
                  select TMP
                  goto (rec_tmp)
                  ++mvu[2,1]  // услуга отредактирована оператором
                endif
                select MOHU
                mohu->kod     := human->kod
                mohu->kod_vr  := mkod_vr
                mohu->kod_as  := mkod_as
                mohu->u_kod   := mu_kod
                mohu->u_cena  := mu_cena
                mohu->date_u  := dtoc4(mdate_u1)
                mohu->otd     := m1otd
                mohu->kol_1   := mkol_1
                mohu->stoim_1 := mstoim_1
                if nKey == K_INS .or. !valid_GUID(mohu->ID_U)
                  mohu->ID_U  := mo_guid(4,mohu->(recno()))
                endif
                mohu->PROFIL  := m1PROFIL
                mohu->PRVS    := m1PRVS
                mohu->kod_diag:= mkod_diag
                if is_zf_stomat == 1
                  mohu->ZF    := mzf
                elseif tip_telemed2
                  mohu->ZF    := iif(m1nmic > 0, lstr(m1nmic)+":"+lstr(m1nmic1), "")
                else
                  mohu->ZF    := m1par_org
                endif
                //
                mrec_hu := mohu->(recno())
                if is_zf_stomat == 1
                  if valtype(is_usluga_zf) == "N" .and. is_usluga_zf == 1 ; // должна быть формула зуба
                                   .and. STVerifyKolZf(arr_zf,mkol_1,@amsg) // проверка по количеству зубов
                    func_error(4,amsg[1])
                  endif
                  //STappendDelZ(human->kod_k,mzf,mohu->date_u,mohu->u_kod)
                  select MOHU
                endif
              endif
              UNLOCK
              //
              pr1otd := m1otd
              /*if is_zf_stomat == 1
                STappend(iif(mn_base==0,1,7),mrec_hu,human->kod_k,hu->date_u,mu_kod,mkod_vr,mzf,mkod_diag)
              endif*/
              select TMP
              tmp->KOD     := human->kod
              tmp->DATE_U  := dtoc4(mdate_u1)
              tmp->DATE_NEXT := mdate_next
              tmp->U_KOD   := mu_kod
              tmp->U_CENA  := mu_cena
              tmp->KOD_VR  := mkod_vr
              tmp->KOD_AS  := mkod_as
              tmp->OTD     := m1otd
              tmp->KOL_1   := mkol_1
              tmp->STOIM_1 := mstoim_1
              tmp->kod_diag:= mkod_diag
              if is_zf_stomat == 1
                tmp->ZF    := mzf
              elseif tip_telemed2
                tmp->ZF    := iif(m1nmic > 0, lstr(m1nmic)+":"+lstr(m1nmic1), "")
              elseif pr_amb_reab .and. left(mshifr1,2)=='4.'
                tmp->ZF    := m1NPR_MO
              else
                tmp->ZF    := m1par_org
              endif
              tmp->PROFIL  := m1profil
              tmp->PRVS    := m1prvs
              tmp->date_u1 := mdate_u1
              tmp->shifr_u := mshifr
              tmp->shifr1  := mshifr1
              tmp->name_u  := mname_u
              tmp->is_nul  := mis_nul
              tmp->is_oms  := mis_oms
              tmp->is_edit := mis_edit
              if nKey == K_INS
                tmp->is_zf := is_usluga_zf
              endif
              tmp->par_org := tip_par_org
              tmp->n_base  := mn_base
              tmp->dom     := m1dom
              tmp->rec_hu  := mrec_hu
              last_date := tmp->date_u1
            endif
            aksg := f_usl_definition_KSG(human->kod)
            summa_usl()
            if mem_pom_va == 2
              skod_vr := mkod_vr
              skod_as := mkod_as
            endif
          endif
        endif
        exit
      enddo
      flag := 0
      if nKey == K_INS .and. !fl_found .and. !eq_any(lastkey(),K_CTRL_F10,K_F11)
        flag := 1
      endif
      restscreen(buf)
      f3oms_usl_sluch()
      vr_pr_1_den(1,,u_other)
      select TMP
      oBrow:goTop()
      goto (rec_tmp)
      setcolor(tmp_color)
    case nKey == K_DEL .and. tmp->kod > 0 .and. f_Esc_Enter(2)
      mywait()
      ++mvu[3,1]  // услуга удалена оператором
      if is_zf_stomat == 1  .and. tmp->n_base == 1 .and. !empty(mohu->zf)
        //STDelDelZ(human->kod_k,mohu->zf,mohu->u_kod)
      endif
      if tmp->n_base == 0
        select HU
        goto (tmp->rec_hu)
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
        //select HU_
        //goto (tmp->rec_hu)
        //DeleteRec(.t.,.f.)
      else
        select MOHU
        goto (tmp->rec_hu)
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      endif
      select TMP
      DeleteRec(.t.)  // с пометкой на удаление
      aksg := f_usl_definition_KSG(human->kod)
      summa_usl()
      vr_pr_1_den(1,,u_other)
      select TMP
      oBrow:goTop()
      go top
      if eof()
        fl_found := .f. ; keyboard chr(K_INS)
      endif
      flag := 0
      restscreen(buf)
      f3oms_usl_sluch()
    otherwise
      keyboard ""
  endcase
  restuchotd(uch_otd)
  return flag
  