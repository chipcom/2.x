#include 'function.ch'

** 07.02.23 ��।����� ��� ��� 1 ��樥�� � ����⨥� 䠩���
// ��������! �� ������ �������� �㭪樨, �ᯮ������ � PROCNAME() ��㣮� �㭪樨
Function f_1pac_definition_KSG(lkod, is_msg)
  Local arr, i, s, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t., sdial, fl

  DEFAULT is_msg TO .t.
  mywait('��।������ ���')
  R_Use(dir_server + 'mo_uch', , 'UCH')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  Use_base('lusl')
  Use_base('luslc')
  Use_base('uslugi')
  R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1',;
                              dir_server + 'uslugi1s'}, 'USL1')
  use_base('human_u') // �᫨ �����������, 㤠���� ���� ��� � �������� ����
  R_Use(dir_server + 'mo_su', , 'MOSU')
  R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
  set relation to u_kod into MOSU
  G_Use(dir_server + 'human_2', , 'HUMAN_2')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  G_Use(dir_server + 'human', , 'HUMAN') // ��१������ �㬬�
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
  goto (lkod)
  lyear := year(human->K_DATA)
  if human_->USL_OK < 3
    if lyear > 2018
      arr := definition_KSG()
    else
      arr := definition_KSG_18()
    endif
    sdial := 0 ; fl := .t.
    if len(arr) == 7
      if valtype(arr[7]) == 'N'
        sdial := arr[7] // ��� 2019 ���� � �����
        if emptyall(arr[1], arr[2], arr[3], arr[4])
          fl := .f. // ������ � ������� ��樮��� ��� ���
        endif
      else
        fl := .f. // ��� 2018 ����
      endif
    endif
    if fl // �� ������ 2018 ����
      aeval(arr[1],{|x| my_debug(,x) })
      if !empty(arr[2])
        my_debug(, '������:')
        aeval(arr[2],{|x| my_debug(,x) })
      endif
      lrec := lcena := 0
      select HU
      find (str(lkod, 7))
      do while hu->kod == lkod .and. !eof()
        usl->(dbGoto(hu->u_kod))
        if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
          lshifr := usl->shifr
        endif
        if !empty(arr[3]) .and. alltrim(lshifr) == arr[3] // 㦥 �⮨� �� �� ���
          not_ksg := .f.
          lcena := arr[4]
          if !(round(hu->u_cena, 2) == round(lcena, 2)) // ��१���襬 業�
            select HU
            G_RLock(forever)
            hu->u_cena := lcena
            hu->stoim := hu->stoim_1 := lcena
            UnLock
          endif
          exit
        endif
        if lyear > 2022 // add 29.12.22 ��ࠢ���
          select LUSL
          find (lshifr) // ����� lshifr 10 ������
          if found() .and. (eq_any(left(lshifr, 5), '1.21.') .or. is_ksg(lusl->shifr)) // �⮨� ��㣮� ���
            lrec := hu->(recno())
            exit
          endif
        elseif lyear == 2022 // add 11.02.22
          select LUSL22
          find (lshifr) // ����� lshifr 10 ������
          if found() .and. (eq_any(left(lshifr, 5), '1.21.') .or. is_ksg(lusl->shifr)) // �⮨� ��㣮� ���
            lrec := hu->(recno())
            exit
          endif
        elseif lyear == 2021 // add 07.02.21
          select LUSL21
          find (lshifr) // ����� lshifr 10 ������
          if found() .and. (eq_any(left(lshifr, 5), '1.20.') .or. is_ksg(lusl->shifr)) // �⮨� ��㣮� ���
            lrec := hu->(recno())
            exit
          endif
        elseif lyear > 2019
          select LUSL20
          find (lshifr) // ����� lshifr 10 ������
          if found() .and. (eq_any(left(lshifr, 5), '1.12.') .or. is_ksg(lusl->shifr)) // �⮨� ��㣮� ���
            lrec := hu->(recno())
            exit
          endif
        elseif lyear > 2018
          select LUSL19
          find (lshifr) // ����� lshifr 10 ������
          if found() .and. (eq_any(left(lshifr, 5), '1.12.') .or. is_ksg(lusl19->shifr)) // �⮨� ��㣮� ���
            lrec := hu->(recno())
            exit
          endif
        else
          select LUSL18
          find (lshifr) // ����� lshifr 10 ������
          if found() .and. (eq_any(left(lshifr, 5), '1.12.') .or. is_ksg(lusl18->shifr)) // �⮨� ��㣮� ���
            lrec := hu->(recno())
            exit
          endif
        endif
        select HU
        skip
      enddo
      if empty(arr[2])
        if empty(lcena)
          lu_kod := foundOurUsluga(arr[3], human->k_data, human_->profil, human->VZROS_REB, @lcena)
          if lyear > 2018  // ���㣫���� �� �㡫�� � 2019 ����
            if len(arr) > 4 .and. !empty(arr[5])
              if lyear > 2022
                lcena := round_5(lcena + 25986.7 * ret_koef_kslp_21(arr[5], year(human->k_data)), 0)
              else
                lcena := round_5(lcena * ret_koef_kslp(arr[5]), 0)
              endif
            endif
            if len(arr) > 5 .and. !empty(arr[6])
              lcena := round_5(lcena * arr[6, 2], 0)
            endif
          else
            if len(arr) > 4 .and. !empty(arr[5])
              lcena := round_5(lcena * arr[5, 2], 1)
            endif
            if len(arr) > 5 .and. !empty(arr[6])
              lcena := round_5(lcena * arr[6, 2], 1)
            endif
          endif
          if round(arr[4], 2) == round(lcena, 2) // 業� ��।����� �ࠢ��쭮
            select HU
            if lrec == 0
              Add1Rec(7)
              hu->kod := human->kod
            else
              goto (lrec)
              G_RLock(forever)
            endif
            mrec_hu := hu->(recno())
            hu->kod_vr  := human_->VRACH
            hu->kod_as  := 0
            hu->u_koef  := 1
            hu->u_kod   := lu_kod
            hu->u_cena  := lcena
            hu->is_edit := 0
            hu->date_u  := dtoc4(human->n_data)
            hu->otd     := human->otd
            hu->kol := hu->kol_1 := 1
            hu->stoim := hu->stoim_1 := lcena
            select HU_
            do while hu_->(lastrec()) < mrec_hu
              APPEND BLANK
            enddo
            goto (mrec_hu)
            G_RLock(forever)
            if lrec == 0 .or. !valid_GUID(hu_->ID_U)
              hu_->ID_U := mo_guid(3,hu_->(recno()))
            endif
            hu_->PROFIL := human_->PROFIL
            hu_->PRVS   := human_->PRVS
            hu_->kod_diag := human->KOD_DIAG
            hu_->zf := ''
          else
            func_error(4, '������: ࠧ��� � 業� ��㣨 ' + lstr(arr[4]) + ' != ' + lstr(lcena))
            not_ksg := .f.
            lcena := 0
          endif
        endif
      elseif lrec > 0 // �� 㤠���� ��।����� ���
        select HU
        goto (lrec)
        DeleteRec(.t.,.f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        lcena := 0
      endif
      if !(round(human->CENA_1, 2) == round(lcena+sdial, 2))
        select HUMAN
        G_RLock(forever)
        human->CENA := human->CENA_1 := lcena+sdial // ��१���襬 �⮨����� ��祭��
        UnLock
      endif
      put_str_kslp_kiro(arr)
      close databases
      if empty(arr[2])
        if not_ksg .and. is_msg
          i := len(arr[1])
          s := arr[1,i]
          if !('���������' $ arr[1,i]) .and. i > 1
            s := alltrim(arr[1,i-1] + s)
          endif
          stat_msg(s) ; mybell(2,OK)
        endif
      else
        func_error(4, '������: '+arr[2, 1])
      endif
    endif
  endif
  close databases
  rest_box(buf)
  return NIL  