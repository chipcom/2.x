#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 02.01.22 �㭪�� ��� when � valid �� ����� ��� � ���� ����
Function f5editkusl(get,when_valid,k)
  Local fl := .t., s, i, lu_cena, lshifr1, v, old_kod, amsg, fl1, fl2, ;
        msg1_err := "��� ��� ࠢ�� ���� ����⥭�! �� �������⨬�.",;
        msg2_err := "����㤭��� � ⠪�� ����� ��� � ���� ������ ���ᮭ���!",;
        blk_sum := {|| mstoim_1 := round_5(mu_cena * mkol_1, 2) }
  // local aImpl
  // local l_impl

  if when_valid == 1    // when
    if k == 2     // ���� ��㣨
      if !empty(mshifr)
        fl := .f.
      endif
    elseif k == 3 // ��� ���
      fl := vr_uva
    elseif k == 4 // ��� ����⥭�
      fl := as_uva
    elseif k == 5 // ������⢮ ���
      if empty(mshifr)
        fl := .f.
      endif
    elseif k == 10  // ��� �⤥�����
      SetKey( K_F3, {|p,l,v| get1_otd(p,l,v,get:Row,get:Col)} )
      @ r1,45 say "<F3> - �롮� �⤥����� �� ����" color color13
    endif
  else  // valid
    if k == 1     // ��� �������� ��㣨
      if !emptyany(human->n_data,mdate_u1) .and. mdate_u1 < human->n_data
        //fl := func_error(4,"��������� ��� ����� ���� ��砫� ��祭��!")
        func_error(4,"��������� ��� ����� ���� ��砫� ��祭��!")
      elseif !emptyany(human->k_data,mdate_u1) .and. mdate_u1 > human->k_data
        fl := func_error(4,"��������� ��� ����� ���� ����砭�� ��祭��!")
      endif
      if fl .and. is_zf_stomat == 1 .and. !empty(mzf)
        // ��९�룭��� �� ���� ��� ��㣨
        keyboard chr(K_TAB)
      endif
    elseif k == 2 // ���� ��㣨
      if !empty(mshifr) .and. !(mshifr == get:original)
                mshifr := transform_shifr(mshifr)
        // ᭠砫� �஢�ਬ �� ��� ���.��㣨, ���ࠢ�塞�� � ����
        if is_lab_usluga(mshifr) .and. !(type("is_oncology") == "N")
          fl := .f.
          if f1cena_oms(mshifr,;
                        mshifr,;
                        (human->vzros_reb==0),;
                        human->k_data,;
                        .t.,;
                        @mis_oms) == NIL
            select LUSL
            find (padr(mshifr,10))
            if found()
              func_error(4,"������ ������ୠ� ��㣠 �� ࠧ�襭� ��� �ᯮ�짮����� � ��襩 ��")
            else
              func_error(4,"������� ����������� ������ୠ� ��㣠")
            endif
            mshifr := space(20)
          else // ��㣠 ࠧ�襭� ������ ��
            if select("MOPROF") == 0
              R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
              //index on shifr+str(vzros_reb,1)+str(profil,3) to (sbase)
            endif
            m1profil := iif(left(mshifr,5) == "4.16.", 6, 34)
            select MOPROF
            find (padr(mshifr,20)+str(iif(human->vzros_reb == 0, 0, 1),1)+str(m1profil,3))
            if !found()
              find (padr(mshifr,20)+str(iif(human->vzros_reb == 0, 0, 1),1))
              if found()
                m1profil := moprof->profil
              endif
            endif
            select USL
            set order to 1
            find (padr(mshifr,10))
            if found() // 㦥 ����ᥭ� � ��� �ࠢ�筨� ���
              mu_kod  := usl->kod
            else // �� ����ᥭ� � ��� �ࠢ�筨� ���
              mu_kod := foundOurUsluga(mshifr,human->k_data,m1PROFIL,human->VZROS_REB,@mu_cena,2)
              select USL
              set order to 0
              goto (mu_kod)
            endif
            mname_u := usl->name
            mn_base := 0
            mstoim_1 := mu_cena := 0
            mis_nul := .t.
            mis_edit := -1 // �.�. ���.��㣠 ���ࠢ���� � ����
            mu_koef := 1
            mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
            mkod_vr := mtabn_vr := 0 ; mvrach := space(35)
            mkod_as := mtabn_as := 0 ; massist := space(35)
            mkol := mkol_1 := 1
            fl := update_gets()
          endif
          return fl
        endif
        // ᭠砫� �஢�ਬ �� ��� ����樨 �����
        fl1 := fl2 := .f.
        select LUSLF
        find (padr(mshifr,20))
        if found() .and. alltrim(mshifr) == alltrim(luslf->shifr)
          // if (c4tod(TMP->DATE_U2) >= d_01_01_2022) .and. ((aImpl := ret_impl_V036(mshifr, c4tod(TMP->DATE_U2))) != NIL)
          //   if flExistImplant
          //     if (l_impl := select_impl(arrImplant[2], arrImplant[3], arrImplant[4])) != NIL
          //       arrImplant[2] := l_impl[1]
          //       arrImplant[3] := l_impl[2]
          //       arrImplant[4] := l_impl[3]
          //     endif
          //   else
          //     if (l_impl := select_impl()) != NIL
          //       arrImplant[2] := l_impl[1]
          //       arrImplant[3] := l_impl[2]
          //       arrImplant[4] := l_impl[3]
          //     endif
          //   endif
          // endif
          is_usluga_zf := luslf->zf
          tip_onko_napr := luslf->onko_napr
          tip_onko_ksg := luslf->onko_ksg
          if (tip_telemed := luslf->telemed) == 1
            tip_telemed2 := (left(mshifr,4) == "B01.")
          endif
          tip_par_org := luslf->par_org
          fl1 := .t.
          select MOSU
          set order to 3
          find (padr(mshifr,20)) // ���饬 䥤�ࠫ�� ��� ����樨 �����
          if found()
            if mosu->tip == 0 // �஢��塞, �� ��� �� �⮬�⮫���� 2016 (㤠�񭭠�)
              mu_kod  := mosu->kod
              mname_u := mosu->name
              mshifr1 := mosu->shifr1
              if !empty(mosu->profil)
                m1PROFIL := mosu->profil
                mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
              endif
            else // ���� �⮬�⮫���� 2016
              fl1 := .f.
              fl2 := .T.
            endif
          else
            mu_kod  := 0
            mname_u := left(luslf->name,65)
            mshifr1 := mshifr
          endif
        endif
        if !fl1 // �� ��諨 � ������� �����
          select MOSU
          set order to 2
          find (padr(mshifr,10)) // ���饬 ᮡ�⢥��� ��� ����樨 �����
          if found()
            if mosu->tip == 0 // �஢��塞, �� ��� �� �⮬�⮫���� 2016 (㤠�񭭠�)
              fl1 := .t.
              mu_kod  := mosu->kod
              mname_u := mosu->name
              mshifr1 := mosu->shifr1
              if !empty(mosu->profil)
                m1PROFIL := mosu->profil
                mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
              endif
              select LUSLF
              find (padr(mshifr1,20))
              if found()
                is_usluga_zf := luslf->zf
                tip_onko_napr := luslf->onko_napr
                tip_onko_ksg := luslf->onko_ksg
                if (tip_telemed := luslf->telemed) == 1
                  tip_telemed2 := (left(mshifr1,4) == "B01.")
                endif
                tip_par_org := luslf->par_org
              endif
            else // ���� �⮬�⮫���� 2016
              fl1 := .f.
              fl2 := .T.
            endif
          endif
        endif
        if type("is_oncology") == "N"
          if !fl1
            fl := func_error(4,"���� "+alltrim(mshifr)+" ��� � ���� ������ 䥤�ࠫ��� ���.")
          endif
          return fl
        elseif fl1
          mn_base := 1
          mstoim_1 := mu_cena := 0
          if type("tip_telemed2") == "L" .and. is_telemedicina(mshifr1,@tip_telemed2) // ���� ��㣮� ⥫�����樭� - �� ���������� ��� ���
            tip_telemed := 1
            mis_edit := -1
          endif
          mis_nul := .t.
          mkol := mkol_1 := 1
          verify_uva(2)
          update_gets()
          if type("row_dom") == "N"
            if empty(tip_par_org)
              m1dom := 0 ; mdom := space(20)
              @ row_dom+1,1 say space(78) color color1
            endif
            if type("tip_telemed2") == "L" .and. tip_telemed2
              @ row_dom,2 say "��� ������� ��㣠" color color1
              @ row(),col()+1 say padr(mnmic,58) color color13
              @ row_dom+1,2 say " ����祭� �� १����� �� ���� ����砭�� ��祭��" color color1
              @ row(),col()+1 say padr(mnmic1,27) color color13
            endif
          endif
          return fl  // !!!!!!!!!!!!!!!!!!!!!
        endif
        if fl2
          fl := func_error(4,"������ ����������������� ���� ����饭� ������� ��᫥ 2016 ����!")
        else // ⥯��� �஢�ਬ �� ��஬� �������
          select USL
          set order to 1
          find (padr(mshifr,10))
          if found()
            lu_cena := iif(human->vzros_reb == 0, usl->cena, usl->cena_d)
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
            if (v := f1cena_oms(usl->shifr,;
                                lshifr1,;
                                (human->vzros_reb==0),;
                                human->k_data,;
                                usl->is_nul,;
                                @mis_oms)) != NIL
              lu_cena := v
            endif
            fl1 := .t.
            if empty(lu_cena)
              fl1 := .f.
              if NulUslugaTFOMS(iif(empty(lshifr1), usl->shifr, lshifr1))
                fl1 := .t.
              else
                fl1 := usl->is_nul
              endif
            endif
            if !fl1
              fl := func_error(4,"� ������ ��㣥 �� ���⠢���� 業�!")
            else
              if mem_otdusl == 2 .and. type("pr1arr_otd") == "A"
                // ��⮬���᪮� ��᢮���� �⤥����� �� ����� ࠡ��� ���ᮭ���
                fl := .t.
              else
                select UO
                find (str(usl->kod,4))
                if found() .and. !(chr(m1otd) $ uo->otdel)
                  fl := func_error(4,"������ ���� ����饭� ������� � ������ �⤥�����!")
                endif
              endif
              if fl
                mu_kod  := usl->kod
                mname_u := usl->name
                mshifr1 := iif(empty(lshifr1), mshifr, lshifr1)
                if left(mshifr1,5) == "60.8."
                  mgist := inieditspr(A__MENUVERT, mm_gist, m1gist)
                  is_gist := .t.
                endif
                mu_cena := lu_cena
                mis_nul := usl->is_nul
                mu_koef := 1
                if mis_nul  // ��㣠 � �㫥��� 業��
                  mu_cena := 0
                endif
                mkol := mkol_1 := 1
                fl_date_next := is_usluga_disp_nabl(mshifr,mshifr1)
                if !empty(usl->profil)
                  m1PROFIL := usl->profil
                  mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
                endif
                eval(blk_sum)
                verify_uva(2)
                update_gets()
                if type("row_dom") == "N" .and. !DomUslugaTFOMS(mshifr1) .and. !tip_telemed2
                  m1dom := 0 ; mdom := space(20)
                  @ row_dom,1 say space(34) color color1
                endif
                if type("row_dom") == "N" .and. !fl_date_next .and. !tip_telemed2
                  mdate_next := ctod("")
                  @ row_dom,35 say space(42) color color1
                endif
                if is_gist
                  @ row_dom,2 say " ��� �஢����� �� ��᫥�������"
                  update_get("mgist")
                endif
                if !empty(arr_usl1year)
                  f_usl1year(iif(empty(mshifr1),mshifr,mshifr1),mshifr,mname_u)
                endif
              endif
            endif
          elseif get_k_usluga(mshifr,human->vzros_reb,@fl)
            box_shadow(r1-5,40,r1-3,77,cColorStMsg,"�������᭠� ��㣠",cColorSt2Msg)
            @ r1-4,41 say padc("������⢮ ��� - "+lstr(len(pr_k_usl)),36) color cColorStMsg
            mkol := mkol_1 := 1
            if fl  // ᬥ���� ��� ��� � ����⥭�
              mvrach := space(35)
              mtabn_vr := 0
              if mkod_vr > 0
                select PERSO
                goto (mkod_vr)
                if !eof() .and. !deleted()
                  mvrach := padr(perso->fio,35)
                  mtabn_vr := perso->tab_nom
                endif
              endif
              massist := space(35)
              mtabn_as := 0
              if mkod_as > 0
                select PERSO
                goto (mkod_as)
                if !eof() .and. !deleted()
                  massist := padr(perso->fio,35)
                  mtabn_as := perso->tab_nom
                endif
              endif
            endif
            fl := update_gets()
          else
            fl := func_error(4,"������ ��� ��� � ���� ������ ���.")
          endif
        endif
      endif
    elseif k == 3 // ��� ���
      old_kod := mkod_vr
      if empty(mtabn_vr)
        mkod_vr := 0
        mvrach := space(35)
      else
        select PERSO
        find (str(mtabn_vr,5))
        if found()
          if type("mkod_as") == "N" .and. perso->kod == mkod_as
            fl := func_error(4,msg1_err)
          elseif mem_kat_va == 2 .and. perso->kateg != 1 .and. !UslugaFeldsher(iif(empty(mshifr1),mshifr,mshifr1))
            fl := func_error(4,"����� ���㤭�� �� ���� ������ �� ��⭮�� �ᯨᠭ��")
          else
            mkod_vr := perso->kod
            m1prvs := -ret_new_spec(perso->prvs,perso->prvs_new)
            mvrach := padr(fam_i_o(perso->fio)+" "+ret_tmp_prvs(m1prvs),57)
          endif
        else
          fl := func_error(4,msg2_err)
        endif
      endif
      if old_kod != mkod_vr
        update_get("mvrach")
      endif
    elseif k == 4 // ��� ����⥭�
      old_kod := mkod_as
      if empty(mtabn_as)
        mkod_as := 0
        massist := space(35)
      else
        select PERSO
        find (str(mtabn_as,5))
        if found()
          if perso->kod == mkod_vr
            fl := func_error(4,msg1_err)
          elseif mem_kat_va == 2 .and. perso->kateg != 2
            fl := func_error(4,"����� ���㤭�� �� ���� ������� ���.���������� �� ��⭮�� �ᯨᠭ��")
          else
            mkod_as := perso->kod
            massist := padr(perso->fio,35)
          endif
        else
          fl := func_error(4,msg2_err)
        endif
      endif
      if old_kod != mkod_as
        update_get("massist")
      endif
    elseif k == 5 // ������⢮ ���
      if mkol_1 != get:original
        eval(blk_sum)
        update_get("mstoim_1")
      endif
    elseif k == 10  // ��� �⤥�����
      if (i := ascan(pr_arr, {|x| x[1] == m1otd } )) > 0
        if type("mu_kod") == "N" .and. mu_kod > 0 .and. mn_base == 0
          select UO
          find (str(mu_kod,4))
          if found() .and. !(chr(m1otd) $ uo->otdel)
            fl := func_error(4,"������ ���� ����饭� ������� � ������ �⤥�����!")
          endif
        endif
        if fl
          motd := pr_arr[i,2] ; update_get("motd")
          SetKey( K_F3, NIL )
          @ r1,45 say space(30) color color13
        endif
      else
        fl := func_error(4,"����� ��� �⤥����� �� ������!")
      endif
    elseif k == 101  // �㡭�� ��㫠
      if !empty(mzf)
        amsg := {}
        if mu_kod > 0 .and. mn_base == 0
          usl->(dbGoto(mu_kod))
          if usl->zf == 0
            aadd(amsg, "� ������ ���� ����饭 ���� �㡭�� ����!")
          endif
        endif
        arr_zf := STverifyZF(mzf,human->date_r,human->n_data,@amsg)
        if len(arr_zf) > 0
          if empty(mkod_diag)
            aadd(amsg, '�� ������ �������!')
          endif
          STverDelZub(human->kod_k,arr_zf,dtoc4(mdate_u1),iif(mn_base==0,1,7),mrec_hu,@amsg)
          if len(amsg) > 0
            n_message(amsg,,"W/G","N/G",,,"GR/G")
          endif
        endif
      endif
    endif
    if !fl
      &(readvar()) := get:original
    elseif equalany(k,3,4) .and. mem_otdusl==2 .and. type("pr1arr_otd")=="A"
      if (old_kod := mkod_vr) == 0
        old_kod := mkod_as
      endif
      if old_kod > 0 .and. mn_base == 0
        select PERSO
        goto (old_kod)
        if iif(yes_many_uch, .t., perso->uch == glob_uch[1]) .and. ;
                perso->otd > 0 .and. (i := ascan(pr1arr_otd,{|x| x[1] == perso->otd})) > 0
          select UO
          find (str(mu_kod,4))
          if found() .and. !(chr(perso->otd) $ uo->otdel)
            fl := func_error(4,'������ ���� ����饭� ������� � �⤥����� "'+alltrim(pr1arr_otd[i,2])+'"!')
            &(readvar()) := get:original
          else
            m1otd := perso->otd ; motd := pr1arr_otd[i,2]
            update_get("m1otd") ; update_get("motd")
          endif
        else
          &(readvar()) := get:original
          if iif(yes_many_uch, .t., perso->uch == glob_uch[1])
            fl := func_error(4,"�� ���⠢���� �⤥�����, � ���஬ ࠡ�⠥� ����� 祫����!")
          else
            fl := func_error(4,"����� 祫���� ࠡ�⠥� � ��㣮� ��०�����!")
          endif
        endif
      endif
    endif
  endif
  return fl
  
****** 02.01.22 - �롮� �������
function select_impl(date_ust, rzn, ser_num)
  local ret := NIL, oBox
  local buf, tmp_keys, iRow
  local sPicture

  private mVIDIMPL := 0, m1VIDIMPL := 0  //iif(nKey == K_INS, human_->profil, tmp->profil)
  private mDATE_INST, mNUMBER

  default date_ust to sys_date
  default rzn to 0
  default ser_num to space(100)

  mDATE_INST := date_ust
  m1VIDIMPL := rzn
  mNUMBER := ser_num

  mVIDIMPL := padr(inieditspr(A__MENUVERT, get_implant(), m1VIDIMPL), 69)

	buf := savescreen()
	change_attr()
	iRow := 10
	tmp_keys := my_savekey()
	save gets to tmp_gets

	oBox := TBox():New( iRow, 10, iRow + 5, 70, .t. )
	oBox:CaptionColor := 'B/B*'
	oBox:Color := cDataCGet
	oBox:MessageLine := '^<Esc>^ - ��室;  ^<PgDn>^ - ���⢥ত���� �����'
	oBox:Caption := '�롥�� �������'
	oBox:View()

	do while .t.
		iRow := 11

    @ ++iRow, 12 say "��� ��⠭����" get mDATE_INST

		@ ++iRow, 12 say '��� �������:' get mVIDIMPL ;
          reader {|x| menu_reader(x,get_implant(), A__MENUVERT, , , .f.)} ;
          valid {|| mVIDIMPL := padr(mVIDIMPL, 69), .t. }

    sPicture := '@S40'
		@ ++iRow, 12 say '��਩�� �����:' get mNUMBER picture sPicture //;
	
		myread()
		if lastkey() != K_ESC .and. m1VIDIMPL != 0
      ret := {mDATE_INST, m1VIDIMPL, mNUMBER}
			exit
		else
			exit
		endif
	enddo
	update_gets()

	oBox := nil
	restscreen( buf )
	restore gets from tmp_gets
	my_restkey( tmp_keys )
  return ret