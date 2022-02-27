#include 'function.ch'
#include 'chip_mo.ch'

***** 23.10.19 ��������� 業 �� ��㣨 � ᮮ⢥��⢨� � �ࠢ�筨��� ��� �����
Function Change_Cena_OMS()
  Local buf := save_maxrow(), lshifr1, fl, lrec, rec_human, k_data2, kod_ksg, begin_date := addmonth(sys_date,-3)
  Local fl_ygl_disp := .F.
  if begin_date < boy(begin_date)
    begin_date := boy(begin_date)
  endif
  n_message({"����� ०�� �।�����祭 ��� ��������� 業 �� ��㣨",;
             "� �㬬� ��砥� � ����� ����, ����� �� ����祭�",;
             "� ॥���� (���), �� 業� �� �ࠢ�筨�� ��� �����.",;
             "�������� !!!",;
             "�� �६� �믮������ ������ ����樨",;
             "���� �� ������ ࠡ���� � ����� ���."},,;
             "GR+/R","W+/R",,,"G+/R")
  if f_Esc_Enter("��������� 業",.t.) .and. mo_Lock_Task(X_OMS)
    mywait()
    fl := .t.
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
      R_Use(dir_server+"human")
      index on str(schet,6)+str(tip_h,1)+upper(substr(fio,1,20)) to (dir_server+"humans") progress
      Use
      R_Use(dir_server+"human_u")
      index on str(kod,7)+date_u to (dir_server+"human_u") progress
      Use
    RECOVER USING error
      fl := func_error(10,"�������� ���।�������� �訡�� �� ��२�����஢����!")
    END
    ERRORBLOCK(bSaveHandler)
    close databases
    if fl
      WaitStatus()
      use_base("lusl")
      use_base("luslc")
      use_base("luslf")
      Use_base("mo_su")
      set order to 0
    //dbselectarea("luslc20")
  
      G_Use(dir_server+"uslugi",{dir_server+"uslugish",;
                                 dir_server+"uslugi"},"USL")
      set order to 0
      Use_base("mo_hu")
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"mo_uch",,"UCH")
      G_Use(dir_server+"human_u",dir_server+"human_u","HU")
      G_Use(dir_server+"human_2",,"HUMAN_2")
      G_Use(dir_server+"human_",,"HUMAN_")
      G_Use(dir_server+"human",dir_server+"humans","HUMAN")
      set relation to recno() into HUMAN_, to recno() into HUMAN_2
      sm_human := i_human := 0
      find (str(0,6))
      do while human->schet == 0 .and. !eof()
        // 横� �� ���
        UpdateStatus()
        k_data2 := human->k_data
        if human->ishod == 88
          rec_human := human->(recno())
          select HUMAN
          goto (human_2->pn4) // ��뫪� �� 2-� ���� ����
          k_data2 := human->k_data // ��९�ᢠ����� ���� ����砭�� ��祭��
          goto (rec_human)
        endif
        if human_->reestr == 0 .and. k_data2 > begin_date
          ++sm_human
          @ maxrow(),1  say lstr(i_human) color "G+/R"
          @ row(),col() say "/" color "R+/R"
          @ row(),col() say lstr(sm_human) color "GR+/R"
          uch->(dbGoto(human->LPU))
          otd->(dbGoto(human->OTD))
          f_put_glob_podr(human_->USL_OK,human->k_data) // ��������� ��� ���ࠧ�������
          sdial := mcena_1 := 0 ; fl := .f. ; kod_ksg := ""
          select HU
          find (str(human->kod,7))
          if human->ishod == 401 .or. human->ishod == 402
            fl_ygl_disp := .T.
          else 
            fl_ygl_disp := .F.
          endif
          do while hu->kod == human->kod .and. !eof()
            // 横� �� ��㣠�
            usl->(dbGoto(hu->u_kod))
            mdate := c4tod(hu->date_u)
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,k_data2)
            if is_usluga_TFOMS(usl->shifr,lshifr1,k_data2)
              lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              if human_->USL_OK < 3 .and. is_ksg(lshifr)
                kod_ksg := lshifr
                lrec := hu->(recno())
              else
                lu_cena := hu->u_cena
                fl_del := fl_uslc := .f.
                v := fcena_oms(lshifr,;
                               (human->vzros_reb==0),;
                               k_data2,;
                               @fl_del,;
                               @fl_uslc)
                if fl_uslc // �᫨ ��諨 � �ࠢ�筨�� �����
                  lu_cena := v
                endif
                mstoim_1 := round_5(lu_cena * hu->kol_1,2)
                select HU
                if !(round(hu->u_cena,2) == round(lu_cena,2) .and. round(hu->stoim_1,2) == round(mstoim_1,2))
                  G_RLock(forever)
                  replace u_cena  with lu_cena, stoim with mstoim_1, stoim_1 with mstoim_1
                  fl := .t.
                  // �������� ������� �� ��
                endif
                if fl_ygl_disp .and. hu->kod_vr == 0 .and. hu->kod_as == 0
                  // �� �㬬��㥬 
                else  
                   mcena_1 += hu->stoim_1
                endif
                //my_debug(,"�㬬� ������⥫쭠�")
                //my_debug(,mcena_1)
              endif
            endif
            select HU
            skip
          enddo
          if !empty(kod_ksg)
            if select("K006") != 0
              k006->(dbCloseArea())
            endif
            if year(human->k_data) > 2018
              arr_ksg := definition_KSG(1,k_data2)
            else
              arr_ksg := definition_KSG_18()
            endif
            fl1 := .t.
            if len(arr_ksg) == 7
              if valtype(arr_ksg[7]) == "N"
                sdial := arr_ksg[7] // ��� 2019 ����
              else
                fl1 := .f. // ��� 2018 ����
              endif
            endif
            if !fl1 // ������ 2018 ����
              //
            elseif empty(arr_ksg[2]) // ��� �訡��
              mcena_1 := arr_ksg[4]
              select HU
              goto (lrec)
              if !(round(mcena_1,2) == round(hu->u_cena,2))
                G_RLock(forever)
                replace u_cena  with mcena_1, stoim with mcena_1, stoim_1 with mcena_1
                fl := .t.
              endif
              put_str_kslp_kiro(arr_ksg)
            endif
          endif
          if fl .or. !(round(mcena_1+sdial,2) == round(human->cena_1,2))
            ++i_human
            human->(G_RLock(forever))
            human->cena := human->cena_1 := mcena_1+sdial
            human_->(G_RLock(forever))
            human_->OPLATA    := 0 // 㡥�� "2", �᫨ ��।���஢��� ������ �� ॥��� �� � ��
            human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
            UnLock ALL
          endif
          if sm_human % 1000 == 0
            COMMIT
          endif
        endif
        select HUMAN
        skip
      enddo
      close databases
      rest_box(buf)
      ///////////////////// ��������� ���������  //////////////////////////
      if sm_human == 0
        func_error(4,"� ���� ������ ��� ��樥�⮢, �� ������� � ॥���� (���)!")
      elseif i_human == 0
        func_error(4,"�� �����㦥�� ���⮢ ���� � ����室������� ������� 業")
      else
        n_message({"��������� 業 �ந������� - "+lstr(i_human)+" �/�"},,"W/RB","BG+/RB",,,"G+/RB")
      endif
    endif
    mo_UnLock_Task(X_OMS)
    close databases
  endif
  return NIL
  