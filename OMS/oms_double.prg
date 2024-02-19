// ०��� ����� ������ ��� ����� ��� (�த�������) - mo_oms3.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 10.10.22 ࠡ�� � �����묨 ���ﬨ
Function oms_double(k)
  Static sk := 1
  Local mas_pmt, mas_msg, mas_fun, j

  DEFAULT k TO 0
  do case
    case k == 0
      mas_pmt := {'~������ ������� ��砩', ;
                '���᮪ ~������� ��砥�', ;
                '~��������� ������� ��砩'}
      mas_msg := {'���������� �������� ���� (��⠢��� �� ���� ��砥� ���� �������)', ;
                '��ᬮ�� ᯨ᪠ ������� ��砥�', ;
                '�������� �������� ���� (᭮�� ࠧ������ ������� ��砩 �� ��� �⤥����)'}
      mas_fun := {'oms_double(1)', ;
                'oms_double(2)', ;
                'oms_double(3)'}
      popup_prompt(T_ROW, T_COL + 5,sk,mas_pmt,mas_msg,mas_fun)
    case k == 1
      create_double_sl()
    case k == 2
      view_double_sl()
    case k == 3
      delete_double_sl()
  endcase
  if k > 0
    sk := k
  endif
  return NIL

// 19.02.24 ᪫���� ��� ����
Function create_double_sl()
  Local buf, str_sem, str_sem2, i, d, fl, lshifr, arr_m, mas_pmt, buf24, buf_scr, srec, old_yes_h_otd := yes_h_otd
  local fl_reserve_1, fl_reserve_2  // �᫨ � ��砥 ���������� 
                                    // {'st36.009 - A16.20.078',
                                    // 'st36.010 - A16.12.030',
                                    // 'st36.011 - A16.10.021.001',
                                    // 'st36.013', 'st36.014', 'st36.015'}
  local rslt_sl1, rslt_sl2, rslt_fl1 := .f., rslt_fl2 := .f.
  local tmp_pc2
  local rslt_kiro := {102, 105, 107, 110, 202, 205, 207}  // ���� �� �ࠢ�� �ਬ������ ���
  local cena_temp
  fl_reserve_1 := fl_reserve_2 := .f.

  if !myFileDeleted(cur_dir + 'tmp_h' + sdbf)
    return NIL
  endif
  buf := box_shadow(0, 41, 4, 77, color13)
  @ 1, 42 say padc('�롥�� ���� ��砩', 35) color color14
  if (arr_m := year_month(T_ROW, T_COL + 5, , 3)) != NIL
    buf24 := save_maxrow()
    mywait()
    dbcreate(cur_dir + 'tmp_h',{{'kod', 'N', 7, 0}})
    use (cur_dir + 'tmp_h') new
    R_Use(dir_server + 'human_2', , 'HUMAN_2')
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humand', 'HUMAN')
    set relation to recno() into HUMAN_, to recno() into HUMAN_2
    d := addmonth(arr_m[5], -2)  // ����� �।��騩 �����
    dbseek(dtos(d), .t.)
    index on upper(fio) to (cur_dir + 'tmp_h2') ;
        while human->k_data <= arr_m[6] ;
        for tip_h == B_STANDART .and. schet < 1 .and. human_->reestr == 0 .and. human_->USL_OK == 1 ;
                                .and. empty(human->ishod) .and. human_->profil != 158 .and. human_2->vmp == 0
    srec := 1
    go top
    do while !eof()
      select TMP_H
      append blank
      replace kod with human->kod
      if human->kod == glob_perso
        srec := tmp_h->(recno())
      endif
      select HUMAN
      skip
    enddo
    i := tmp_h->(lastrec())
    close databases
    rest_box(buf24)
    if i == 0
      func_error(4, '� ����� ������ ��� ��樮����� ��樥�⮢ � ��⮩ ����砭�� ' + arr_m[4])
    else
      Private mr1 := T_ROW, regim_vyb := 2
      R_Use(dir_server + 'mo_otd', , 'OTD')
      R_Use(dir_server + 'human_2', , 'HUMAN_2')
      R_Use(dir_server + 'human_', , 'HUMAN_')
      R_Use(dir_server + 'human', , 'HUMAN')
      set relation to recno() into HUMAN_, to recno() into HUMAN_2, to otd into OTD
      use (cur_dir + 'tmp_h') new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir + 'tmp_h')
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW, 2, maxrow() - 2, 77, 'f1ret_oms_human', color0, ;
                    '�� ��� ����砭�� ��祭�� "' + arr_m[4] + '"', 'B/BG', , .t., , , 'f2ret_oms_human', , ;
                    {'�', '�', '�', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R'} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4, '�� ������� �㦭�� ����ᥩ!')
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          ln_data := human->n_data
          lk_data := human->k_data
          ldiag := human->kod_diag
          lprofil := human_->profil
          lcena := human->cena_1
          rslt_sl1 := human_->RSLT_NEW
          rslt_fl1 := ascan(rslt_kiro, rslt_sl1) > 0
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', human->otd)
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server + 'mo_uch', human->LPU)
          fl := .f.
          use_base('lusl')
          fl_reserve_1 := exist_reserve_KSG(glob_perso, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
          if ! fl_reserve_1
            if lk_data == ln_data
              func_error(4, '��� ��砫� �� ����� ࠢ������ ��� ����砭�� ��祭��!')
              mkod := 0
            endif
          elseif left(ldiag, 1) == 'O' .and. (lk_data - ln_data < 6) .and. ! fl_reserve_1
            func_error(4, '��த���� ��ᯨ⠫����� ������ ���� �� ����� 6 ����!')
            mkod := 0
          endif
        endif
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        str_sem := '������஢���� 祫����� ' + lstr(glob_perso)
        if G_SLock(str_sem)
          @ 1, 42 say padc(glob_k_fio, 35) color color8
          @ 2, 42 say padc('1: � ' + date_8(ln_data)+ ' �� ' + date_8(lk_data), 35) color color8
          @ 3, 42 say padc('�롥�� ��ன ��砩', 35) color color14
          use (cur_dir + 'tmp_h') new
          zap
          R_Use(dir_server + 'human_2', , 'HUMAN_2')
          R_Use(dir_server + 'human_', , 'HUMAN_')
          R_Use(dir_server + 'human', dir_server + 'humand', 'HUMAN')
          set relation to recno() into HUMAN_, to recno() into HUMAN_2
          dbseek(dtos(arr_m[5]), .t.)
          index on upper(fio) to (cur_dir + 'tmp_h2') ;
              while human->k_data <= AddMonth(arr_m[6], 2) ;  // 11.03.21
              for kod_k == glob_kartotek .and. kod != glob_perso .and. schet < 1 .and. ;
                  tip_h == B_STANDART .and. human_->reestr == 0 .and. human_->USL_OK == 1 .and. ;
                  ishod == 0 .and. human_->profil != 158 .and. human_2->vmp == 0
          go top
          do while !eof()
            select TMP_H
            append blank
            replace kod with human->kod
            select HUMAN
            skip
          enddo
          i := tmp_h->(lastrec())
          close databases
          rest_box(buf24)
          if i == 0
            func_error(4, '� ����� ������ ����� ��� ��樮����� ��砥� �� ������� ��樥���')
          else
            R_Use(dir_server + 'mo_otd', , 'OTD')
            R_Use(dir_server + 'human_2', , 'HUMAN_2')
            R_Use(dir_server + 'human_', , 'HUMAN_')
            R_Use(dir_server + 'human', , 'HUMAN')
            set relation to recno() into HUMAN_, to recno() into HUMAN_2, to otd into OTD
            use (cur_dir + 'tmp_h') new
            set relation to kod into HUMAN
            index on dtos(human->k_data) to (cur_dir + 'tmp_h')
            go top
            mkod := 0
            buf_scr := savescreen()
            if Alpha_Browse(T_ROW, 2, maxrow() - 2, 77, 'f1ret_oms_human', color0, ;
                          '��ன ��砩 �� ��� ����砭�� ��祭�� "' + arr_m[4] + '"', 'B/BG', , .t., , , 'f2ret_oms_human', , ;
                          {'�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R'} )
              if (glob_perso2 := tmp_h->kod) == 0
                func_error(4, '�� ������� �㦭�� ����ᥩ!')
              elseif !(ldiag == human->kod_diag) .and. ! (diagnosis_for_replacement(ldiag, human_->USL_OK) .or. diagnosis_for_replacement(human->kod_diag, human_->USL_OK))
                func_error(4, '�᭮���� ������� � ����� ����� ������ ᮢ������!')
              elseif lprofil != human_->profil
                func_error(4, '��䨫� ����樭᪮� ����� � ����� ����� ������ ᮢ������!')
              else
                fl_reserve_2 := exist_reserve_KSG(glob_perso2, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
                if (lk_data != human->n_data) .and. ! fl_reserve_1 .and. ! fl_reserve_2
                  func_error(4, '��� ��砫� 2-�� ���� ������ ���� ࠢ�� ��� ����砭�� 1-�� ����!')
                else
                  mkod := glob_perso2
                  ln_data2 := human->n_data
                  lk_data2 := human->k_data
                  lcena2 := human->cena_1
                  lrslt := human_->RSLT_NEW
                  rslt_sl2 := human_->RSLT_NEW
                  rslt_fl2 := ascan(rslt_kiro, rslt_sl2) > 0
                  lishod := human_->ISHOD_NEW
                  lvnr1 := human_2->VNR1
                  lvnr2 := human_2->VNR2
                  lvnr3 := human_2->VNR3
                endif
              endif
            endif
            restscreen(buf_scr)
            close databases

            // �஢�ਬ �ᮡ� १����� �� ᮢ�������
            if rslt_fl1 .or. rslt_fl2
              if rslt_sl1 != rslt_sl2
                n_message({'�������� ��祭�� � ����� �⫨�����:', ;
                            '1-� ��砩 - ' + getRSLT_V009(rslt_sl1), ;
                            '2-�� ��砩 - ' + getRSLT_V009(rslt_sl2), ;
                            '', ;
                            '��।������ ' + iif(rslt_fl2, '1-�', '2-�') + ' ��砩 � ���஡�� ᭮��' ;
                          }, , ;
                          color1, cDataCSay, , , color8)
                
                G_SUnLock(str_sem)
                close databases
                rest_box(buf)
                return NIL
              endif
            endif

            if mkod > 0
              str_sem2 := '������஢���� 祫����� ' + lstr(glob_perso2)
              if G_SLock(str_sem2)
                @ 3, 42 say padc('2: � ' + date_8(ln_data2)+ ' �� ' + date_8(lk_data2), 35) color color8
                if f_Esc_Enter('ᮧ����� �������� ����', .t.)
                  mywait('�஢�ઠ (����⪠ �������) 業� ��� ��ࢮ�� ����.')
                  recount_double_sl(glob_perso, lk_data2)
                  mywait('�믮������ ������ ᫨ﭨ� ���� ���⮢ ���� � �������.')

                  use_base( "lusl" )
                  use_base( "luslc" )
                  use_base( "luslf" )
                  use_base( "mo_su" )
                  Set Order To 0
            
                  g_use( dir_server + "uslugi", { dir_server + "uslugish", ;
                    dir_server + "uslugi" }, "USL" )
                  Set Order To 0
            
                  use_base( 'human_u' ) // �᫨ �����������, �������� ���

                  use_base( 'human' )
                  goto (glob_perso)
                  lcena := human->cena_1
                  G_Use(dir_server + 'human_3', {dir_server + 'human_3', dir_server + 'human_32'}, 'HUMAN_3')
                  AddRec(7)
                  human_3->KOD       := glob_perso
                  human_3->KOD2      := glob_perso2
                  human_3->KOD_DIAG  := human->kod_diag
                  if fl_reserve_1
                    human_3->N_DATA    := ln_data2
                    human_3->K_DATA    := lk_data2
                  elseif fl_reserve_2
                    human_3->N_DATA    := ln_data
                    human_3->K_DATA    := lk_data
                  else
                    human_3->N_DATA    := ln_data
                    human_3->K_DATA    := lk_data2
                  endif
                  human_3->USL_OK    := human_->USL_OK
                  human_3->VIDPOM    := human_->VIDPOM
                  human_3->RSLT_NEW  := lrslt
                  human_3->ISHOD_NEW := lishod
                  human_3->VNR1      := lvnr1
                  human_3->VNR2      := lvnr2
                  human_3->VNR3      := lvnr3
                  human_3->CENA_1    := lcena+lcena2
                  human_3->DATE_E    := c4sys_date
                  human_3->KOD_P     := kod_polzovat    // ��� ������
                  human_3->PZTIP     := 0
                  human_3->PZKOL     := 0
                  human_3->ST_VERIFY := 0
                  human_3->KOD_UP    := 0
                  human_3->OPLATA    := 0
                  human_3->SUMP      := 0
                  human_3->SANK_MEK  := 0
                  human_3->SANK_MEE  := 0
                  human_3->SANK_EKMP := 0
                  human_3->REESTR    := 0
                  human_3->REES_NUM  := 0
                  human_3->REES_ZAP  := 0
                  human_3->SCHET     := 0
                  human_3->SCHET_NUM := 0
                  human_3->SCHET_ZAP := 0
                  if fl_reserve_1 .or. fl_reserve_2
                    human_3->ID_C := mo_guid(1, human_3->(recno()))
                  endif
                  //
                  select HUMAN
                  goto (glob_perso2)
                  G_RLock(forever)
                  human->ishod := 89 // �� 2-�� �/� � ������� ��砥
                  human_2->(G_RLock(forever))
                  human_2->pn4 := glob_perso // ��뫪� �� 1-� ���� ����
                  tmp_pc2 := human_2->pc2 // ��࠭�� ���� �� 2-�� ����
                  //
                  select HUMAN
                  goto ( glob_perso )
                  G_RLock( forever )
                  human->ishod := 88 // �� 1-� �/� � ������� ��砥
                  human_2->( G_RLock( forever ) )
                  human_2->pn4 := glob_perso2 // ��뫪� �� 2-� ���� ����

                  human_2->pc2 := tmp_pc2 // ���쬥� ���� 2-�� ���� � ������� ��砥

                  // �믮���� ������ �⮨���� ��� � 1-�� ����
                  Select HU
                  find ( Str( glob_perso, 7 ) )
                  Do While hu->kod == human->kod .and. !Eof()
                    // 横� �� ��㣠�
                    if hu->u_cena != 0
                      usl->( dbGoto( hu->u_kod ) )
                      cena_temp := ret_cena_KSG( usl->shifr, human->VZROS_REB, lk_data2 ) //, ta)
                      if ! empty( human_2->pc1 )  // �஢�ਬ ����
//                        cena_temp := round_5(cena_temp + baseRate( lk_data2, human_->USL_OK ) * ret_koef_kslp_21( List2Arr(human_2->pc1), year( lk_data2 ) ), 0 )
                        cena_temp := round_5(cena_temp + baseRate( lk_data2, human_->USL_OK ) * ret_koef_kslp_21( List2Arr(human_2->pc1), year( lk_data2 ) ), 0 )
                      endif
                      if ! empty( human_2->pc2 )  // �஢�ਬ ����
                        cena_temp := round_5( cena_temp * List2Arr(human_2->pc2)[ 2 ], 0 )
                      endif
//                      human->cena := human->cena_1 := cena_temp
                      hu->( g_rlock( forever ) )
                      hu->u_cena := cena_temp
                      hu->stoim := hu->stoim_1 := round_5( cena_temp * hu->kol_1, 2 )
                    endif
                    hu->(dbSkip())
                  enddo
                  human_3->CENA_1 := cena_temp + lcena2
                  human->CENA := human->CENA_1 := cena_temp
                
                  //
                  close databases

                  stat_msg('������ ᫨ﭨ� �����襭�!')
                  mybell(2, OK)
                  rest_box(buf24)
                endif
                G_SUnLock(str_sem2)
              else
                func_error(4, '� ����� ������ � ����窮� �⮣� ��樥�� ࠡ�⠥� ��㣮� ���짮��⥫�.')
              endif
            endif
          endif
          G_SUnLock(str_sem)
        else
          func_error(4, '� ����� ������ � ����窮� �⮣� ��樥�� ࠡ�⠥� ��㣮� ���짮��⥫�.')
        endif
      endif
    endif
    yes_h_otd := old_yes_h_otd
    close databases
  endif
  rest_box(buf)
  return NIL

// 05.03.23 �஢�ઠ (����⪠ �������) 業� ��� ��ࢮ�� ����
Function recount_double_sl(mkod_human, k_data2)
  Local aksg, lcena, adbf := { ;
    {'KOD'      ,   'N',     7,     0}, ; // ��� ���쭮��
    {'DATE_U'   ,   'C',     4,     0}, ; // ��� �������� ��㣨
    {'date_u2'  ,   'C',     4,     0}, ; // ��� ����砭�� �������� ��㣨
    {'date_u1'  ,   'D',     8,     0}, ;
    {'date_next',   'D',     8,     0}, ; // ��� ᫥�.����� ��� ���.�������
    {'shifr_u'  ,   'C',    20,     0}, ;
    {'shifr1'   ,   'C',    20,     0}, ;
    {'name_u'   ,   'C',    65,     0}, ;
    {'U_KOD'    ,   'N',     6,     0}, ; // ��� ��㣨
    {'U_CENA'   ,   'N',    10,     2}, ; // 業� ��㣨
    {'dom'      ,   'N',     2,     0}, ; // -1 - �� ����
    {'KOD_VR'   ,   'N',     4,     0}, ; // ��� ���
    {'KOD_AS'   ,   'N',     4,     0}, ; // ��� ����⥭�
    {'OTD'      ,   'N',     3,     0}, ; // ��� �⤥�����
    {'KOL_1'    ,   'N',     3,     0}, ; // ����稢����� ������⢮ ���
    {'STOIM_1'  ,   'N',    10,     2}, ; // ����稢����� �⮨����� ��㣨
    {'ZF'       ,   'C',    30,     0}, ; // �㡭�� ��㫠 ��� ���� �࣠��
    {'PAR_ORG'  ,   'C',    40,     0}, ; // ࠧ���� ���� �࣠��
    {'ID_U'     ,   'C',    36,     0}, ; // ��� ����� �� ��������� ��㣥;GUID ��������� ��㣨;ᮧ������ �� ���������� �����
    {'PROFIL'   ,   'N',     3,     0}, ; // ��䨫�;�� �ࠢ�筨�� V002
    {'PRVS'     ,   'N',     9,     0}, ; // ���樠�쭮��� ���;�� �ࠢ�筨�� V004;
    {'kod_diag' ,   'C',     6,     0}, ; // �������;��७��� �� �᭮����� ��������
    {'n_base'   ,   'N',     1,     0}, ; // ����� �ࠢ�筨�� ��� 0-����, 1-����
    {'is_nul'   ,   'L',     1,     0}, ;
    {'is_oms'   ,   'L',     1,     0}, ;
    {'is_zf'    ,   'N',     1,     0}, ;
    {'is_edit'  ,   'N',     2,     0}, ;
    {'number'   ,   'N',     3,     0}, ;
    {'rec_hu'   ,   'N',     8,     0}}

  use_base('lusl')
  use_base('luslc')
  use_base('luslf')
  Use_base('mo_su')
  set order to 0
  G_Use(dir_server + 'uslugi', {dir_server + 'uslugish', ;
                           dir_server + 'uslugi'}, 'USL')
  set order to 0
  Use_base('mo_hu')
  Use_base('human_u')
  G_Use(dir_server + 'human_2', , 'HUMAN_2')
  G_Use(dir_server + 'human_', , 'HUMAN_')
  G_Use(dir_server + 'human',{dir_server + 'humank', ;
                          dir_server + 'humankk', ;
                          dir_server + 'humano'}, 'HUMAN')
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
  find (str(mkod_human, 7))
  glob_kartotek := human->kod_k
  lcena := human->cena_1
  last_date := human->n_data
  R_Use(dir_server + 'mo_uch', , 'UCH')
  uch->(dbGoto(human->LPU))
  R_Use(dir_server + 'mo_otd', , 'OTD')
  otd->(dbGoto(human->OTD))
  f_put_glob_podr(human_->USL_OK, k_data2) // ��������� ��� ���ࠧ�������
  dbcreate(cur_dir + 'tmp_usl_', adbf)
  use (cur_dir + 'tmp_usl_') new alias TMP
  select HUMAN
  set order to 1
  find (str(mkod_human, 7))
  select HU
  set relation to u_kod into USL additive
  find (str(mkod_human, 7))
  if found()
    do while hu->kod == mkod_human .and. !eof()
      select TMP
      append blank
      tmp->KOD     := hu->kod
      tmp->DATE_U  := hu->date_u
      tmp->date_u2 := hu_->date_u2
      tmp->date_u1 := c4tod(hu->date_u)
      tmp->shifr_u := usl->shifr
      tmp->shifr1  := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
      if empty(lshifr := tmp->shifr1)
        lshifr := tmp->shifr_u
      endif
      tmp->name_u  := usl->name
      tmp->U_KOD   := hu->u_kod
      tmp->U_CENA  := hu->u_cena
      tmp->KOD_VR  := hu->kod_vr
      tmp->dom     := hu->KOL_RCP
      tmp->KOD_AS  := hu->kod_as
      tmp->OTD     := hu->otd
      tmp->KOL_1   := hu->kol_1
      tmp->STOIM_1 := hu->stoim_1
      tmp->ZF      := hu_->ZF
      tmp->ID_U    := hu_->ID_U
      tmp->PROFIL  := hu_->PROFIL
      tmp->PRVS    := hu_->PRVS
      tmp->kod_diag:= hu_->kod_diag
      tmp->n_base  := 0
      tmp->is_edit := hu->is_edit
      tmp->is_nul  := usl->is_nul
      tmp->rec_hu  := hu->(recno())
      last_date := max(tmp->date_u1, last_date)
      if human_->usl_ok < 3 .and. is_ksg(lshifr) // ��� ��� 業� �� ��८�।��塞 - ᤥ���� �������
        rec_ksg := tmp->(recno())
      else
        fl_oms := .f.
        // ��८�।������ 業�
        if (v := f1cena_oms(tmp->shifr_u, ;
                          tmp->shifr1, ;
                          (human->vzros_reb == 0), ;
                          k_data2, ;
                          tmp->is_nul, ;
                          @fl_oms)) != NIL
          tmp->is_oms := fl_oms
          if !(round(tmp->u_cena, 2) == round(v, 2))
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
      select HU
      skip
    enddo
    commit
  endif
  select MOHU
  set relation to u_kod into MOSU
  find (str(mkod_human, 7))
  if found()
    do while mohu->kod == mkod_human .and. !eof()
      select TMP
      append blank
      tmp->KOD     := mohu->kod
      tmp->DATE_U  := mohu->date_u
      tmp->date_u2 := mohu->date_u2
      tmp->date_u1 := c4tod(mohu->date_u)
      tmp->shifr_u := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
      tmp->shifr1  := mosu->shifr1
      tmp->name_u  := mosu->name
      tmp->U_KOD   := mohu->u_kod
      tmp->U_CENA  := mohu->u_cena
      tmp->KOD_VR  := mohu->kod_vr
      tmp->KOD_AS  := mohu->kod_as
      tmp->OTD     := mohu->otd
      tmp->KOL_1   := mohu->kol_1
      tmp->STOIM_1 := mohu->stoim_1
      tmp->ZF      := mohu->ZF
      tmp->ID_U    := mohu->ID_U
      tmp->PROFIL  := mohu->PROFIL
      tmp->PRVS    := mohu->PRVS
      tmp->kod_diag:= mohu->kod_diag
      tmp->n_base  := 1
      tmp->is_nul  := .t.
      tmp->is_oms  := .t.
      tmp->is_zf   := ret_is_zf(tmp->shifr1)
      tmp->rec_hu  := mohu->(recno())
      tmp->par_org := ret_par_org(tmp->shifr1, k_data2)
      last_date := max(tmp->date_u1, last_date)
      select MOHU
      skip
    enddo
    commit
  endif
  select TMP
  fl_found := (tmp->(lastrec()) > 0)
  is_1_vvod := (tmp->(lastrec()) == 0 .and. mem_ordu_1 == 1)
  if mem_ordusl == 1
    index on dtos(date_u1) + fsort_usl(shifr_u) to (cur_dir + 'tmp_usl_')
  else
    index on fsort_usl(shifr_u) + dtos(date_u1) to (cur_dir + 'tmp_usl_')
  endif
  //
  old_is_zf_stomat := is_zf_stomat
  select HU
  set relation to  // '���뢠��' human_u_
  select USL
  set order to 1
  is_zf_stomat := 0
  R_Use(dir_server + 'usl_otd', dir_server + 'usl_otd', 'UO')
  R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO')
  select TMP
  set relation to otd into OTD
  go top
  if rec_ksg > 0
    f_usl_definition_KSG(human->kod, k_data2, .t.)
  else
    func_error(4, '� ��ࢮ� ��砥 �� �����㦥�� ���!')
  endif
  close databases
  is_zf_stomat := old_is_zf_stomat
  return NIL

// 10.10.22 ��ᬮ�� ������� ��砥�
Function view_double_sl()
  Local k, s, buf, arr := {}

  if (k := input_double_sl(1)) != NIL
    buf := savescreen()
    G_Use(dir_server + 'human_3',{dir_server + 'human_3', dir_server + 'human_32'}, 'HUMAN_3')
    find (str(k[1], 7))
    R_Use(dir_server + 'mo_otd', , 'OTD')
    G_Use(dir_server + 'human_2', , 'HUMAN_2')
    G_Use(dir_server + 'human_', , 'HUMAN_')
    G_Use(dir_server + 'human', , 'HUMAN')
    set relation to recno() into HUMAN_, to recno() into HUMAN_2, to otd into OTD
    goto (k[1])
    aadd(arr, '������� ���� ���� �� ��樥���: ' +alltrim(k[2]))
    aadd(arr, '�� �㬬� ' + lstr(human_3->cena_1, 11, 2)+ ' ��.')
    aadd(arr, '1-� � ��. ' +alltrim(otd->name)+ ' �� �㬬� ' + lstr(human->cena_1, 11, 2)+ ' ��.')
    aadd(arr, 'c ' + date_8(human->n_data)+ ' �� ' + date_8(human->k_data)+ iif(human_->ST_VERIFY == 5, '', ' (� �訡���)'))
    fl := (human_->ST_VERIFY < 5)
    select HUMAN
    goto (human_3->kod2)
    aadd(arr, '2-�� � ��. ' +alltrim(otd->name)+ ' �� �㬬� ' + lstr(human->cena_1, 11, 2)+ ' ��.')
    aadd(arr, 'c ' + date_8(human->n_data)+ ' �� ' + date_8(human->k_data)+ iif(human_->ST_VERIFY == 5, '', ' (� �訡���)'))
    if !fl
      fl := (human_->ST_VERIFY < 5)
    endif
    if fl
      aadd(arr, '')
      aadd(arr, '����ନ��� ������� ���� ���� � ��।������ ��� ���� ����')
    endif
    close databases
    f_message(arr, , color8, color1)
    mybell(1) ; inkey(0)
    restscreen(buf)
  endif
  return NIL

// 10.10.22 ᭮�� ࠧ������ ��� ����
Function delete_double_sl()
  Local k, s, buf, arr := {}, str_sem := '����ନ஢���� �������� ���� ����'

  if (k := input_double_sl(2)) != NIL .and. G_SLock(str_sem)
    buf := savescreen()
    G_Use(dir_server + 'human_3',{dir_server + 'human_3', dir_server + 'human_32'}, 'HUMAN_3')
    find (str(k[1], 7))
    R_Use(dir_server + 'mo_otd', , 'OTD')
    G_Use(dir_server + 'human_2', , 'HUMAN_2')
    G_Use(dir_server + 'human_', , 'HUMAN_')
    G_Use(dir_server + 'human', , 'HUMAN')
    set relation to recno() into HUMAN_, to recno() into HUMAN_2, to otd into OTD
    goto (k[1])
    aadd(arr, '����ନ஢뢠���� ������� ���� ����')
    aadd(arr, '�� ��樥���: ' +alltrim(k[2]))
    aadd(arr, '�� �㬬� ' + lstr(human_3->cena_1, 11, 2)+ ' ��.')
    aadd(arr, '��᫥ ���ନ஢���� ���� ᮧ���� ��� ���� ����:')
    aadd(arr, '1-� � ��. ' +alltrim(otd->name)+ ' �� �㬬� ' + lstr(human->cena_1, 11, 2)+ ' ��.')
    select HUMAN
    goto (human_3->kod2)
    aadd(arr, '2-�� � ��. ' +alltrim(otd->name)+ ' �� �㬬� ' + lstr(human->cena_1, 11, 2)+ ' ��.')
    f_message(arr, , cColorSt2Msg, cColorSt1Msg)
    s := '���⢥न� ���ନ஢���� �������� ���� ����'
    stat_msg(s)
    mybell(1)
    if f_Esc_Enter('���ନ஢����', .t.)
      stat_msg(s+ ' ��� ࠧ.') ; mybell(3)
      if f_Esc_Enter('���ନ஢����', .t.)
        select HUMAN
        G_RLock(forever)
        human->ishod := 0 // �� 2-�� �/� � ������� ��砥
        human_2->(G_RLock(forever))
        human_2->pn4 := 0 // ��뫪� �� 1-� ���� ����
        select HUMAN
        goto (k[1])
        G_RLock(forever)
        human->ishod := 0 // �� 1-�� �/� � ������� ��砥
        human_2->(G_RLock(forever))
        human_2->pn4 := 0 // ��뫪� �� 2-� ���� ����
        select HUMAN_3
        DeleteRec()  // 㤠�塞 ������� ��砩
        close databases
        // stat_msg('������� ���� ���� �ᯥ譮 ���ନ஢��.')
        mybell(5)
        stat_msg('������ ���� �������.')
        arr := {}
        aadd(arr, '������� ���� ���� �ᯥ譮 ���ନ஢��.')
        aadd(arr, '�஢���� ��।������ �⮨���� �室���� � ������� ��砩')
        aadd(arr, '���⮢ ���.')
        f_message(arr, , cColorSt2Msg, cColorSt1Msg)
        inkey(0)
      endif
    endif
    close databases
    G_SUnLock(str_sem)
    restscreen(buf)
  endif
  return NIL

// 10.10.22
Function input_double_sl(par)
  Static srec := 0
  Local buf, i, arr_m, buf24, blk, t_arr[BR_LEN], ret

  if (arr_m := year_month(T_ROW, T_COL + 5, , 3)) != NIL
    buf24 := save_maxrow()
    mywait()
    R_Use(dir_server + 'human_3', dir_server + 'human_32', 'HUMAN_3')
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humand', 'HUMAN')
    set relation to kod into HUMAN_, to str(kod, 7) into HUMAN_3
    dbseek(dtos(arr_m[5]), .t.)
    index on upper(fio) to (cur_dir + 'tmp_h2') ;
        while human->k_data <= arr_m[6] ;
        for ishod == 89 .and. schet < 1 .and. human_->reestr == 0
    go top
    if eof()
      func_error(4, '�� ������� ������� ��砥� ' + arr_m[4])
    else
      if srec > 0
        Locate for kod == srec
        if !found()
          go top
        endif
      endif
      t_arr[BR_TOP] := T_ROW
      t_arr[BR_BOTTOM] := maxrow()-2
      t_arr[BR_LEFT] := 2
      t_arr[BR_RIGHT] := 77
      t_arr[BR_COLOR] := color0
      t_arr[BR_TITUL] := '������ ��砨 ' + arr_m[4]
      t_arr[BR_TITUL_COLOR] := 'B/BG'
      t_arr[BR_ARR_BROWSE] := {'�', '�', '�', 'N/BG,W+/N,R/BG,W+/R', .f.}
      blk := {|| iif(f1_input_double_sl(), {1, 2}, {3, 4}) }
      t_arr[BR_COLUMN] := {{ center('���', 42), {|| padr(human->fio, 42) },blk }, ;
                         { '  �ப� ��祭��',{|| date_8(human_3->N_DATA)+ '-' + date_8(human_3->K_DATA) },blk }, ;
                         { '   �㬬�',{|| put_kop(human_3->CENA_1, 11) },blk }}
      t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - ��室;  ^<Enter>^ - �롮� �������� ���� ��� ' + iif(par == 2, '���ନ஢����', '��ᬮ��')) }
      t_arr[BR_ENTER] := {|| ret := {human_3->kod, human->fio} }
      edit_browse(t_arr)
      if valtype(ret) == 'A'
        srec := ret[1]
      endif
    endif
    close databases
    rest_box(buf24)
  endif
  return ret

// 10.10.22
Function f1_input_double_sl()
  Local fl, rec, rec3

  if (fl := (human_->ST_VERIFY == 5))
    rec3 := human_3->(recno())
    select HUMAN
    rec := human->(recno())  // �� 2-�� ��砥
    set relation to
    set index to
    select HUMAN_3
    goto (rec3)
    select HUMAN_
    goto (human_3->kod) // ����� �� 1-� ��砩
    fl := (human_->ST_VERIFY == 5)
    select HUMAN
    set index to (cur_dir + 'tmp_h2')
    set relation to kod into HUMAN_, to str(kod, 7) into HUMAN_3
    goto (rec)
  endif
  return fl

// 28.12.23
function combined_KSG(cShifr, double_sl)
  // २��㧨� ��⮪஢� (��� st36.009, �롨ࠥ��� �� ��㣥 A16.20.078)
  // ��������� ����ਠ��⠫쭠� ���������� (��� st36.010, �롨ࠥ��� �� ��㣥 A16.12.030)
  // ���ࠪ�௮ࠫ쭠� ����࠭��� ��ᨣ����� (��� st36.011, �롨ࠥ��� �� ��㣥 A16.10.021.001)
  // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠������� (�஢��� 1) (��� st36.013)
  // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠������� (�஢��� 2) (��� st36.014)
  // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠������� (�஢��� 3) (��� st36.015)
  // �஢������ ���㭨��樨 ��⨢ �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� ��䥪樨 (��� st36.025, st36.026)
  local aKSG := { 'st36.009', ; // A16.20.078
                  'st36.010', ; // A16.12.030
                  'st36.011', ; // A16.10.021.001
                  'st36.013', ;
                  'st36.014', ;
                  'st36.015' ;  //, ;
                }
              //     'st36.025', ;
              //     'st36.026' ;
              //  }

  default double_sl to .f.
  if double_sl
    aadd( aKsg, 'st36.025' )
    aadd( aKsg, 'st36.026' )
  endif

  return ascan(aKSG, alltrim(cShifr)) > 0

// 19.11.23
function exist_reserve_KSG(kod_pers, aliasHUMAN)
  local aliasIsUseHU, aliasIsUseUSL
  local oldSelect, ret := .f.
  local lshifr

  if kod_pers == 0
    return ret
  endif

  aliasIsUseUSL := aliasIsAlreadyUse('__USL')
  if ! aliasIsUseUSL
    oldSelect := Select()
    R_Use(dir_server + 'uslugi', , '__USL')
  endif

  aliasIsUseHU := aliasIsAlreadyUse('__HU')
  if ! aliasIsUseHU
    G_Use(dir_server + 'human_u', {dir_server + 'human_u', ;
        dir_server + 'human_uk', ;
        dir_server + 'human_ud', ;
        dir_server + 'human_uv', ;
        dir_server + 'human_ua'}, '__HU', , .f., .t.)
  endif
  set relation to u_kod into __USL
  find (str(kod_pers,7))

  do while __HU->kod == kod_pers .and. !eof()
    if empty(lshifr := opr_shifr_TFOMS(__USL->shifr1, __USL->kod, (aliasHUMAN)->k_data))
      lshifr := __USL->shifr
    endif
    // २��㧨� ��⮪஢� (��� st36.009, �롨ࠥ��� �� ��㣥 A16.20.078)
    // ��������� ����ਠ��⠫쭠� ���������� (��� st36.010, �롨ࠥ��� �� ��㣥 A16.12.030)
    // ���ࠪ�௮ࠫ쭠� ����࠭��� ��ᨣ����� (��� st36.011, �롨ࠥ��� �� ��㣥 A16.10.021.001)
    // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠������� (�஢��� 1) (��� st36.013)
    // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠������� (�஢��� 2) (��� st36.014)
    // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠������� (�஢��� 3) (��� st36.015)
    // �஢������ ���㭨��樨 ��⨢ �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� ��䥪樨 (��� st36.025, st36.026)
    if is_ksg( lshifr ) .and. combined_KSG( lshifr, isPartDoubleSl( 'HUMAN' ) )
      ret := .t.
      exit
    endif
    select __HU
    skip
  enddo

  if ! aliasIsUseUSL
    __USL->(dbCloseArea())
  endif

  if ! aliasIsUseHU
    __HU->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

// 26.12.23
function diagnosis_for_replacement( cDiag, nUsl_ok, double_sl )
  local aDiag := {'Z92.2', ;
                  'Z92.4', ;
                  'Z92.8' ;
                }
                //   'Z25.8' ;
                //  }

  DEFAULT nUsl_ok TO USL_OK_POLYCLINIC
  default double_sl to .f.
  if eq_any( nUsl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. double_sl
    aadd( aDiag, 'Z25.8' )
  endif

  return ascan(aDiag, alltrim(cDiag)) > 0

function isPartDoubleSl( aliasHUMAN )

  return ( (aliasHUMAN)->ishod == 89 .or. (aliasHUMAN)->ishod == 88)