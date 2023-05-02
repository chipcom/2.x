#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static sadiag1 := {}

// 02.05.23
Function verify_1_sluch(fl_view)
  Local _ocenka := 5, ta := {}, u_other := {}, ssumma := 0, auet, fl, lshifr1, ;
        i, j, k, c, s := ' ', a_srok_lech := {}, a_period_stac := {}, a_disp := {}, ;
        d1, d2, cd1, cd2, ym2, a_period_amb := {}, a_1_11, u_1_stom := '', lprofil, ;
        lbukva, lst, lidsp, a_idsp := {}, a_bukva := {}, t_arr[2], ltip, lkol, ;
        a_dializ := {}, is_2_88 := .f., a_rec_ffoms := {}, arr_povod := {}, mpovod := 0, ; // 1.0
        lal, lalf

  local reserveKSG_1 := .f., reserveKSG_2 := .f.
  local sbase
  local arr_uslugi_geriatr := {'B01.007.001', 'B01.007.003', 'B01.007.003' }, row, rowTmp
  local flGeriatr := .f.
  local arrV018, arrV019
  local arrImplant
  local arrLekPreparat, arrGroupPrep, mMNN
  local flLekPreparat := .f.
  local arrUslugi := {} // ���ᨢ ᮤ�ঠ訩 ���� ��� � ��砥
  local lTypeLUMedReab := .f.
  local aUslMedReab
  local obyaz_uslugi_med_reab, iUsluga
  local lTypeLUOnkoDisp := .f.
  local lDoubleSluch := .f.
  local iVMP
  local aDiagnoze_for_check := {}
  local fl_zolend := .f.
  local header_error
  local vozrast, lu_type
  local kol_dney
  local is_2_92_ := .f., kol_2_93_1 := 0  // 誮�� ������, ���쬮 12-20-154 �� 28.04.23

  if empty(human->k_data)
    return .t.  // �� �஢�����
  endif
  DEFAULT fl_view TO .t.
  rec_human := human->(recno())
  Private mdate_r := human->date_r, mvozrast, mdvozrast, M1VZROS_REB := human->VZROS_REB, ;
          arr_usl_otkaz := {}, m1novor := 0, mpol := human->pol, mDATE_R2 := ctod(''), ;
          is_oncology := 0, is_oncology_smp := 0

  arrUslugi := collect_uslugi(rec_human)   // �롥६ �� ���� ��� ����


  if human_->NOVOR > 0
    m1novor := 1 // ��� ��८�।������ M1VZROS_REB
    mDATE_R2 := human_->DATE_R2
    mpol := human_->POL2
  endif

  fv_date_r(human->n_data) // ��८�।������ M1VZROS_REB
  m1novor := human_->NOVOR // ��� ����� ����祭�� ��⥩ �� ������
  if M1VZROS_REB != human->VZROS_REB  // �᫨ ����୮,
    human->(G_RLock(forever))
    human->VZROS_REB := M1VZROS_REB   // � ��१����뢠��
    UnLock
  endif

  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  lu_type := otd->TIPLU

  header_error := fio_plus_novor() + ' ' + alltrim(human->kod_diag) + ' ' + ;
             date_8(human->n_data) + '-' + date_8(human->k_data) + ;
             ' (' + count_ymd(human->date_r, human->n_data) + ')' + hb_eol()
  header_error += alltrim(uch->name) + '/' + alltrim(otd->name) + '/��䨫� �� "' + ;
                 alltrim(inieditspr(A__MENUVERT, getV002(), human_->profil)) + '"'

  lTypeLUOnkoDisp := (otd->tiplu == TIP_LU_ONKO_DISP)

  if ! lTypeLUOnkoDisp
    is_oncology := f_is_oncology(1, @is_oncology_smp)
  endif
  //
  glob_kartotek := human->kod_k
  d1 := human->n_data
  d2 := human->k_data
  kol_dney := human->k_data - human->n_data
  cuch_doc := human->uch_doc

  arrV018 := getV018(human->k_data)
  arrV019 := getV019(human->k_data)

  reserveKSG_1 := exist_reserve_KSG(human->kod, 'HUMAN')

  ym2 := left(dtos(d2), 6)
  d1_year := year(d1)
  d2_year := year(d2)
  lal := 'lusl'
  lalf := 'luslf'

  lal := create_name_alias(lal, d2_year)
  lalf := create_name_alias(lalf, d2_year)
  //
  cd1 := dtoc4(d1)
  cd2 := dtoc4(d2)
  gnot_disp := (human->ishod < 100)
  gkod_diag := human->kod_diag
  gusl_ok := human_->usl_ok
  Private is_disp_19 := !(d2 < d_01_05_2019)
  //
  if gusl_ok == USL_OK_AMBULANCE // 4 - �᫨ '᪮�� ������'
    select HUMAN
    set order to 3
    find (dtos(d2) +cuch_doc)
    do while human->k_data == d2 .and. cuch_doc == human->uch_doc .and. !eof()
      fl := human_->usl_ok == USL_OK_AMBULANCE .and. glob_kartotek == human->kod_k .and. rec_human != human->(recno())
      if fl .and. human->schet > 0 .and. eq_any(human_->oplata, 2, 9)
        fl := .f. // ���� ���� ��� �� ���� ��� ���⠢��� ����୮
      endif
      if fl
        aadd(ta, '"' + alltrim(cuch_doc) + '" ����� � ����� �맮�� �� ' + ;
                 date_8(human->k_data) + ' ' + alltrim(human->fio))
      endif
      skip
    enddo
  endif
  // ��ᬮ�� ��㣨� ��砥� ������� ���쭮��
  select HUMAN
  set order to 2
  find (str(glob_kartotek, 7))
  do while human->kod_k == glob_kartotek .and. !eof()
    fl := (rec_human != human->(recno()) .and. year(human->k_data) > 2019) // ���� ��� �� ᬮ�ਬ �����
    if fl .and. human->schet > 0 .and. eq_any(human_->oplata, 2, 9)
      fl := .f. // ���� ���� ��� �� ���� (� ���⠢��� ����୮)
    endif
    if fl .and. m1novor != human_->NOVOR
      fl := .f. // ���� ���� �� ����஦������� (��� �������)
    endif
    if fl .and. gnot_disp .and. human->ishod < 100 ; // �᫨ �� ��ᯠ��ਧ���
          .and. gusl_ok == human_->usl_ok ; // �᫨ � �� �᫮��� �������� �����
          .and. !empty(gkod_diag) .and. left(gkod_diag, 3) == left(human->kod_diag, 3)  // �� �� �᭮���� �������
      if (k := d1 - human->k_data) >= 0 // � ��砩 ������ ࠭�� �஢��塞���
        if gusl_ok == USL_OK_AMBULANCE  // 4 - ᪮�� ������
          if k < 2
            aadd(a_rec_ffoms, {human->(recno()), 0, k})
          endif
        else // �����������, ��㣫������ � ������� ��樮���
          if k < 31 // � �祭�� 30 ����
            aadd(a_rec_ffoms, {human->(recno()), 0, k})
          endif
        endif
      endif
    endif
    // �᫨ �������� ��祭�� ��४�뢠���� � ��樮��� � ������� ��樮���
    if fl .and. eq_any(human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL)

      reserveKSG_2 := exist_reserve_KSG(human->kod, 'HUMAN')

      fl1 := (left(dtos(human->k_data), 6) == ym2)   // ���� � �� �� ����� ����砭�� ��祭��
      fl2 := overlap_diapazon(human->n_data, human->k_data, d1, d2) // ��४�뢠���� �������� ��祭��
      fl3 := .t.
      k := 0
      if is_alldializ .and. (fl1 .or. fl2) .and. year(human->k_data) > 2018 // ���� ��� �� ᬮ�ਬ �����
        select HU
        find (str(human->kod, 7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
          if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            if left(lshifr, 5) == '60.3.' .or. left(lshifr, 6) == '60.10.' // ������
              if human_->USL_OK == USL_OK_DAY_HOSPITAL  // 2 - ������ � ������� ��樮���
                fl3 := .f.
                if fl1
                  k := 2
                endif
              elseif fl2 // ������ � ��樮���
                k := 1
              endif
              exit
            endif
          endif
          select HU
          skip
        enddo
        if k > 1
          aadd(a_dializ, {human->n_data, human->k_data, human_->USL_OK, human->OTD, k}) // ������� �� � ��㣫.��樮���
        endif
      endif
      if k < 2 .and. fl2 .and. fl3 .and. iif(is_alldializ, year(human->k_data) > 2018, .t.) .and. ! (reserveKSG_1 .or. reserveKSG_2) // � ��⮬ ��������� ��������� ������� ��砥�
        aadd(a_srok_lech, {human->n_data, human->k_data, human_->USL_OK, human->OTD, k})
      endif
    endif
    // �᫨ �������� ��祭�� ���筮 ��४�뢠����
    if fl .and. human->n_data <= d2 .and. d1 <= human->k_data
      is_period_amb := .f.
      // ��樮���
      if human_->USL_OK == USL_OK_HOSPITAL  // 1
        aadd(a_period_stac, {human->n_data, ;
                            human->k_data, ;
                            human_->USL_OK, ;
                            human->OTD, ;
                            human->kod_diag, ;
                            human_->profil, ;
                            human_->RSLT_NEW, ;
                            human_->ISHOD_NEW, ;
                            k})
      // �����������
      elseif human_->USL_OK == USL_OK_POLYCLINIC .and. human->ishod < 101 ;
               .and. !(human_->profil == 60 .and. glob_mo[_MO_KOD_TFOMS] == '103001') // �� ���������
        is_period_amb := .t.
      endif
      select HU
      find (str(human->kod, 7))
      do while hu->kod == human->kod .and. !eof()
        // �᫨ ��㣠 � ⮬ �� ��������� ��祭��
        if between(hu->date_u, cd1, cd2)
          aadd(u_other, {hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0, human->n_data, human->k_data, human->OTD})
        endif
        if is_period_amb
          lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
          if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            if eq_any(left(lshifr, 5), '2.80.', '2.82.', '60.4.', '60.5.', '60.6.', '60.7.', '60.8.', '60.9.')
              is_period_amb := .f.
              exit
            // elseif lshifr == '60.3.1' // ����.������
            elseif eq_any(lshifr, '60.3.1', '60.3.12', '60.3.13')  // 04.12.22
              aadd(a_dializ, {human->n_data, human->k_data, human_->USL_OK, human->OTD, 3}) // ������� �� � ��㣫.��樮���
              exit
            endif
          endif
        endif
        select HU
        skip
      enddo
      if is_period_amb
        aadd(a_period_amb, {human->n_data, human->k_data, human_->profil, human->OTD, human->(recno())})
      endif
      select MOHU
      find (str(human->kod, 7))
      do while mohu->kod == human->kod .and. !eof()
        if between(mohu->date_u,cd1,cd2) // ��㣠 � ⮬ �� ��������� ��祭��
          aadd(u_other, {mohu->u_kod,mohu->date_u,mohu->kol_1,mohu->profil, 1})
        endif
        skip
      enddo
    endif
    // ��ᯠ��ਧ���/��䨫��⨪� ���᫮�� ��ᥫ����
    if fl .and. between(human->ishod, 201, 205)
      // �᫨ ��� ��砫� ⥪�饣� ��祭�� = ���� ��砫� ��諮�� ��祭��
      if year(human->n_data) == year(d1) // ��� ��ᯠ��ਧ�樨
        aadd(a_disp, {human->ishod - 200, human->n_data, human->k_data, human_->RSLT_NEW})
      endif
      // ��� ��䨫��⨪�
      if human->ishod == 203 .and. count_years(human->date_r, human->n_data) == mvozrast
        aadd(a_disp, {human->ishod - 200, human->n_data, human->k_data, human_->RSLT_NEW})
      endif
    endif
    select HUMAN
    skip
  enddo
  select HUMAN
  set order to 1
  dbGoto(rec_human)
  G_RLock(forever)
  human_->(G_RLock(forever))
  human_2->(G_RLock(forever))
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  s := fam_i_o(human->fio) + ' '
  if !empty(otd->short_name)
    s += '[' + alltrim(otd->short_name) + '] '
  endif

  lTypeLUMedReab := (otd->tiplu == TIP_LU_MED_REAB)

  s += date_8(human->n_data) + '-' + date_8(human->k_data)
  @ maxrow(), 0 say padr(' ' + s, 50) color 'G+/R'
  if human_->usl_ok == USL_OK_POLYCLINIC
    s := '���㫠�୮� �����'
  elseif human_->usl_ok == USL_OK_AMBULANCE // 4
    s := '����� �맮��'
  else
    s := '���ਨ �������'
  endif
  if empty(CHARREPL('0', human->uch_doc,space(10)))
    aadd(ta, '�� �������� ����� ' + s + ': ' +human->uch_doc)
  else
    for i := 1 to len(human->uch_doc)
      c := substr(human->uch_doc, i, 1)
      if between(c,'0','9')
        // ����,
      elseif ISLETTER(c)
        // �㪢� ���᪮�� � ��⨭᪮�� ��䠢��,
      elseif empty(c)
        // �஡��,
      elseif eq_any(c,'.','/','\','-','|','_',' + ')
        // �窠,��ਧ��⠫�� ࠧ����⥫�, ���⨪���� � �������� ࠧ����⥫�,������ ����ન�����, ���� ' + '
      else
        aadd(ta, '�������⨬� ᨬ��� "' + c + '" � ����� ' + s + ': ' + human->uch_doc)
      endif
    next
  endif
  // �஢�ઠ �� ��⠬
  if year(human->date_r) < 1900
    aadd(ta, '��� ஦�����: ' + full_date(human->date_r) + ' ( < 1900�.)')
  endif
  if human->date_r > human->n_data
    aadd(ta, '��� ஦�����: ' + full_date(human->date_r) + ;
              ' > ���� ��砫� ��祭��: ' + full_date(human->n_data))
  endif
  if human->n_data > human->k_data
    aadd(ta, '��� ��砫� ��祭��: ' + full_date(human->n_data) + ;
              ' > ���� ����砭�� ��祭��: ' + full_date(human->k_data))
  endif
  if d2_year - d1_year > 1
    aadd(ta, '�६� ��祭�� ��⠢��� ' + lstr(human->k_data - human->n_data) + ' ����')
  endif
  if human->k_data > sys_date
    aadd(ta, '��� ����砭�� ��祭�� > ��⥬��� ����: ' + full_date(human->k_data))
  endif
  if human_->NOVOR > 0
    if empty(human_->DATE_R2)
      aadd(ta, '�� ������� ��� ஦����� ����஦�������')
    elseif human_->DATE_R2 > human->n_data
      aadd(ta, '��� ஦����� ����஦�������: ' + full_date(human_->DATE_R2) + ' ����� ���� ��砫� ��祭��: ' + full_date(human->n_data))
    elseif human->n_data - human_->DATE_R2 > 60
      aadd(ta, '����஦������� ����� ���� ����楢')
    endif
  endif

  // ��।��塞 ������, �᫨ 0 � ������ �� ����
  vozrast := count_years(iif(human_->NOVOR == 0, human->DATE_R, human_->DATE_R2), human->N_DATA)


  //
  // ��������� ��������
  //
  mdiagnoz := diag_to_array(, , , , .t.)
  if len(mdiagnoz) == 0 .or. empty(mdiagnoz[1])
    aadd(ta, '�� ��������� ���� "�������� �������"')
  endif

  if mdiagnoz[1] == 'Z00.2' .and. !(vozrast >= 1 .and. vozrast < 14)
    aadd(ta, '�᭮���� ������� Z00.2 �����⨬ ⮫쪮 ��� ������ �� ���� �� 14 ���')
  elseif mdiagnoz[1] == 'Z00.3' .and. !(vozrast >= 14 .and. vozrast < 18)
    aadd(ta, '�᭮���� ������� Z00.3 �����⨬ ⮫쪮 ��� ������ �� 14 �� 18 ���')
  elseif mdiagnoz[1] == 'Z00.1' .and. (vozrast >= 1)
    aadd(ta, '�᭮���� ������� Z00.1 �����⨬ ⮫쪮 ��� ������ �� ����')
  endif
  
  if len(aDiagnoze_for_check := dublicate_diagnoze(fill_array_diagnoze())) > 0
    for i := 1 to len(aDiagnoze_for_check)
      aadd(ta, 'ᮢ�����騩 ������� ' + aDiagnoze_for_check[i, 2] + aDiagnoze_for_check[i, 1])
    next
  endif

  if select('MKB_10') == 0
    R_Use(dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
  endif
  select MKB_10
  for i := 1 to len(mdiagnoz)
    mdiagnoz[i] := padr(mdiagnoz[i], 6)
    find (mdiagnoz[i])
    if found()
      if !between(human->ishod, 101, 305) .and. i == 1 .and. !between_date(mkb_10->dbegin,mkb_10->dend, human->k_data)
        aadd(ta, '�᭮���� ������� �� �室�� � ���')
      endif
      if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
        aadd(ta, '��ᮢ���⨬���� �������� �� ���� ' + alltrim(mdiagnoz[i]))
      endif
    else
      aadd(ta, '�� ������ ������� ' + alltrim(mdiagnoz[i]) + ' � �ࠢ�筨�� ���-10')
    endif
  next
  mdiagnoz3 := {}
  if !empty(human_2->OSL1)
    aadd(mdiagnoz3, human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(mdiagnoz3, human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(mdiagnoz3, human_2->OSL3)
  endif
  ar := {}
  select MKB_10
  for i := 1 to len(mdiagnoz3)
    if left(mdiagnoz3[i], 3) == 'R52'
      aadd(ar, i)
    endif
    mdiagnoz3[i] := padr(mdiagnoz3[i], 6)
    find (mdiagnoz3[i])
    if found()
      if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
        aadd(ta, '��ᮢ���⨬���� �������� �� ���� ' + alltrim(mdiagnoz3[i]))
      endif
    else
      aadd(ta, '�� ������ ������� ' + alltrim(mdiagnoz3[i]) + ' � �ࠢ�筨�� ���-10')
    endif
  next
  if human_->USL_OK == USL_OK_HOSPITAL ; // 1 - ��樮���
       .and. (ascan(mdiagnoz, {|x| left(x, 3) == 'P07' }) > 0 .or. ascan(mdiagnoz3, {|x| left(x, 3) == 'P07' }) > 0) ;
             .and. mvozrast == 0 .and. human_2->VNR == 0
    aadd(ta, '��� �������� P07.* �� 㪠��� ��� ������襭���� (������᭮��) ॡ񭪠')
  endif
  if mvozrast > 0 .and. len(mdiagnoz) > 0 .and. left(mdiagnoz[1], 1) == 'P'
    aadd(ta, '��� �᭮����� �������� ' + mdiagnoz[1] + ' ������ ������ ���� ����� ����')
  endif
  if human_->USL_OK == USL_OK_HOSPITAL ; // 1 - ��樮���
      .and. (mdiagnoz[1] = 'U07.1' .or. mdiagnoz[1] = 'U07.2') ;  // �஢�ਬ �� ������� COVID-19
      .and. empty(HUMAN_2->PC4) ;                                 // ��� ���������
      .and. (count_years(human->DATE_R, human->k_data) >= 18) ;   // �஢�ਬ �� ������ ����� 18 ���
      .and. !check_diag_pregant()   // �஢�ਬ, �� �� ��६����
    aadd(ta, '��� �������� U07.1 ��� U07.2 ��� �᫮��� ��樮��� �� 㪠��� ��� ��樥��')
  endif
  if !empty(HUMAN_2->PC4) .and. val(HUMAN_2->PC4) < 0.3
    aadd(ta, '��� ��樥�� �� ����� ���� ����� 300 �ࠬ�')
  endif

  if year(human->k_data) == 2022 .and. !empty(HUMAN_2->PC1)
    if alltrim(human_2->PC1) == '2' // ���� 2 - ���� ��������� �।�⠢�⥫� ��� 2022 ����
      if human_->PROFIL != 12 .and. human_->PROFIL != 18  // �����⨬� ��� ��䨫�� '����⮫����' � '���᪠� ���������'
        aadd(ta, '��� ��࠭���� ���� = 2, ��䨫� �������� ��� ������ ���� ��� "����⮫����" ��� "���᪠� ���������"')
      endif
    endif
  endif

  if year(human->k_data) == 2022 .and. !empty(HUMAN_2->PC1)
    if alltrim(human_2->PC1) == '3' // ���� 3 - ���� 75 ��� ��� 2022 ����
      for each row in arr_uslugi_geriatr
        if ascan(arrUslugi, row) > 0 // �஢�ਬ �� ��㣨 ����
          flGeriatr := .t.
        endif
      next
      if !flGeriatr
        aadd(ta, '��� ��࠭���� ���� = 3, � ᯨ᪥ ��� ��� ���� ����室��� ����稥 ����� �� ��� B01.007.001, B01.007.002 ��� B01.007.003')
      endif
    endif
  endif

  s := ''
  if len(mdiagnoz) > 0 .and. f_oms_beremenn(mdiagnoz[1]) == 3 .and. between(human_2->pn2, 1, 4)
    s := 'R52.' + {'0', '1', '2', '9'}[human_2->pn2]
  endif
  if !emptyall(s, ar)
    if empty(ar)
      human_2->OSL3 := s
    else
      fl := .t.
      for i := 3 to 1 step -1
        pole := 'human_2->OSL' + lstr(i)
        if left(&pole, 3) == 'R52'
          if fl
            fl := .f.
            if !(alltrim(pole) == s)
              &pole := s  // ᠬ� ��᫥���� - ��१���襬
            endif
          else
            &pole := ''   // ��⠫�� - ���⨬
          endif
        endif
      next
    endif
  endif

  //
  // ��������� ������������� ��������
  //
  if ascan(getVidUd(), {|x| x[2] == kart_->vid_ud }) == 0
    if human_->vpolis < 3
      aadd(ta, '�� ��������� ���� "��� 㤮�⮢�७�� ��筮��"')
    endif
  else
    if empty(kart_->nom_ud)
      if human_->vpolis < 3
        aadd(ta, '������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��" ��� "' + ;
                inieditspr(A__MENUVERT, getVidUd(), kart_->vid_ud) + '"')
      endif
    //elseif !eq_any(kart_->vid_ud, 9, 18, 21, 24) .and. !ver_number(kart_->nom_ud)
      //aadd(ta, '���� '����� 㤮�⮢�७�� ��筮��' ������ ���� ��஢�')
    endif
    if !empty(kart_->nom_ud)
      s := space(80)
      if !val_ud_nom(2, kart_->vid_ud, kart_->nom_ud, @s)
        aadd(ta,s)
      endif
    endif
    if eq_any(kart_->vid_ud, 1, 3, 14) .and. empty(kart_->ser_ud)
      aadd(ta, '�� ��������� ���� "����� 㤮�⮢�७�� ��筮��" ��� "' + ;
              inieditspr(A__MENUVERT, getVidUd(), kart_->vid_ud) + '"')
    endif
    if human_->usl_ok < USL_OK_AMBULANCE .and. eq_any(kart_->vid_ud, 3, 14) .and. ;
           !empty(kart_->ser_ud) .and. empty(del_spec_symbol(kart_->mesto_r)) .and. human_->vpolis < 3
      aadd(ta,iif(kart_->vid_ud == 3, '��� ᢨ�-�� � ஦�����', '��� ��ᯮ�� ��') + ;
              ' ��易⥫쭮 ���������� ���� "���� ஦�����"')
    endif
    if !empty(kart_->ser_ud)
      s := space(80)
      if !val_ud_ser(2, kart_->vid_ud, kart_->ser_ud, @s)
        aadd(ta,s)
      endif
    endif
    if human_->usl_ok < USL_OK_AMBULANCE .and. human_->vpolis < 3 .and. !eq_any(left(human_->OKATO, 2), '  ', '18') // �����த���
      if empty(kart_->kogdavyd)
        aadd(ta, '��� �����த��� ��� ������ ����� ��易⥫쭮 ���������� ���� "��� �뤠� ���㬥��, 㤮�⮢����饣� ��筮���"')
      endif
      if empty(kart_->kemvyd) .or. ;
         empty(del_spec_symbol(inieditspr(A__POPUPMENU, dir_server + 's_kemvyd', kart_->kemvyd)))
        aadd(ta, '��� �����த��� ��� ������ ����� ��易⥫쭮 ���������� ���� "������������ �࣠��, �뤠�襣� ���㬥��, 㤮�⮢����騩 ��筮���"')
      endif
    endif
  endif
  val_fio(retFamImOt(2,.f.), ta)
  kart_->(G_RLock(forever))
  s := alltrim(kart_->okatog)
  if mo_nodigit(s)
    aadd(ta, '����஢� ᨬ���� � ����� ॣ����樨')
  endif
  if len(s) == 0
    if human_->vpolis < 3
      aadd(ta, '�� �������� ��� ����� � ���� "���� ॣ����樨"')
    endif
  elseif len(s) > 0 .and. len(s) < 11
    kart_->okatog := padr(s, 11, '0')
  endif
  s := alltrim(kart_->okatop)
  if mo_nodigit(s)
    aadd(ta, '����஢� ᨬ���� � ����� �ॡ뢠���')
  endif
  if len(s) > 0 .and. len(s) < 11
    kart_->okatop := padr(s, 11, '0')
  endif
  if !empty(kart->snils)
    s := space(80)
    if !val_snils(kart->snils, 2, @s)
      aadd(ta, s + ' � ��樥��')
    endif
  endif
  human_->SPOLIS := val_polis(human_->SPOLIS)
  human_->NPOLIS := val_polis(human_->NPOLIS)
  Valid_SN_Polis(human_->vpolis, human_->SPOLIS, human_->NPOLIS, ta,between(human_->smo, '34001', '34007'))
  //
  if select('SMO') == 0
    R_Use(dir_exe + '_mo_smo', cur_dir + '_mo_smo2', 'SMO')
    //index on smo to (sbase+ '2')
  endif
  select SMO
  if alltrim(human_->smo) == '34'
    if empty(human_->OKATO)
      aadd(ta, '�� ����� ��ꥪ� ��, � ���஬ �����客�� ��樥��')
    elseif empty(ret_inogSMO_name(2))
      aadd(ta, '�� ������� �����த��� ���客�� ��������')
    endif
  else
    select SMO
    find (human_->smo)
    if found()
      human_->OKATO := smo->okato
    else
      aadd(ta, '�� ������� ��� � ����� "' + human_->smo + '"')
    endif
  endif
  //
  d := human->k_data - human->n_data
  adiag := {}
  kkd := kds := kvp := kuet := kkt := ksmp := 0
  mpztip := mpzkol := kol_uet := 0
  kkd_1_11 := kkd_1_12 := kol_ksg := 0
  is_reabil := is_dializ := is_perito := is_s_dializ := is_eko := fl_stom := fl_dop_ob_em := .f.
  if is_dop_ob_em
    fl_dop_ob_em := (human->reg_lech == 9)
  endif
  au_lu := {} ; au_flu := {} ; au_lu_ne := {} ; arr_perso := {} ; arr_unit := {}
  arr_onkna := {} ; arr_mo_spec := {}
  m1dopo_na := m1napr_v_mo := m1napr_stac := m1profil_stac := m1napr_reab := m1profil_kojki := 0

  m1sank_na := 0
  mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  is_kt := is_mrt := is_uzi := is_endo := is_gisto := is_mgi := is_g_cit := is_pr_skr := is_covid := .f.
  is_71_1 := is_71_2 := is_71_3 := is_dom := .f.
  kvp_2_78 := kvp_2_79 := kvp_2_89 := kol_2_3 := kol_2_60 := kol_2_4 := kol_2_6 := kol_55_1 := 0
  kvp_70_5 := kvp_70_6 := kvp_70_3 := kvp_72_2 := kvp_72_3 := kvp_72_4 := 0
  is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f.
  is_2_83 := is_2_84 := is_2_85 := is_2_86 := is_2_87 := is_2_88 := is_2_89 := .f.
  a_2_89 := array(15) ; afill(a_2_89, 0)
  is_disp_DDS := is_disp_DVN := is_disp_DVN3 := is_prof_PN := is_neonat := is_pren_diagn := .f.

  is_disp_DVN_COVID := .f.
  is_exist_Prescription := .f.  // ������� ���� ���ࠢ����� ��� ��ᯠ��ਧ�権

  is_70_3 := is_70_5 := is_70_6 := is_72_2 := is_72_3 := is_72_4 := .f.
  lstkol := 0 ; lstshifr := shifr_ksg := '' ; cena_ksg := 0
  midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := m1lis := 0
  lvidpoms := ''
  // ॠ������� - ��� 䨧�����୮�� ��ᯠ��� � ��㣨�
  arr_lfk := {'3.1.5', '3.1.19', '3.4.31', ;
              '4.2.153', '4.11.136', ;
              '7.12.5', '7.12.6', '7.12.7', '7.2.2', ;
              '13.1.1', ;
              '14.2.3', ;
              '16.1.17', '16.1.18', ;
              '19.1.1', '19.1.2', '19.1.3', '19.1.5', '19.1.6', '19.1.7', '19.1.9', '19.1.11', '19.1.12', '19.1.29', '19.1.30', '19.1.31', ;
              '19.2.1', '19.2.2', '19.2.4', '19.3.1', '19.5.1', '19.5.2', '19.5.19', '19.6.1', ;
              '19.3.1', ;
              '20.1.1', '20.1.2', '20.1.3', '20.1.4', '20.1.5', '20.1.6', '20.2.1', '20.2.2', '20.2.3', ;
              '21.1.1', '21.1.2', '21.1.3', '21.1.4', '21.1.5', '21.2.1', ;
              '22.1.1', '22.1.2', '22.1.3'}
  //
  f_put_glob_podr(human_->USL_OK, d2, ta) // ��������� ��� ���ࠧ�������
  musl_ok := USL_OK_POLYCLINIC  // 3 - �-�� �� 㬮�砭��
  ldnej := 0
  pr_amb_reab := .f.
  if human_->USL_OK < USL_OK_AMBULANCE  // 4
    select HU
    find (str(human->kod, 7))
    do while hu->kod == human->kod .and. !eof()
      lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
      if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data)
        lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
        if eq_any(left(lshifr, 5), '1.11.', '55.1.')
          ldnej += hu->kol_1
        elseif left(lshifr, 5) == '2.89.'
          pr_amb_reab := .t.
        endif
      endif
      select HU
      skip
    enddo
  endif
  // �஢�ਬ �� �⠯ �� �� 㣫㡫����� ��ᯠ��ਧ�樨 ��᫥ COVID
  if eq_any(human->ishod, 401, 402)
    is_disp_DVN_COVID := .t.
    is_exist_Prescription := .t.
  endif

  d_sroks := ''

  select HU
  find (str(human->kod, 7))

  if ! found()
    add_string(header_error)
    aadd(ta, '��� ���� ��������� ᯨ᮪ ��������� ���')
    // verify_FF(80 - len(ta) - 3, .t., 80)
    // add_string('')
    // uch->(dbGoto(human->LPU))
    // otd->(dbGoto(human->OTD))
    // add_string(fio_plus_novor() + ' ' + alltrim(human->kod_diag) + ' ' + ;
    //            date_8(human->n_data) + '-' + date_8(human->k_data) + ;
    //            ' (' + count_ymd(human->date_r, human->n_data) + ')')
    // Ins_Array(ta, 1, alltrim(uch->name) + '/' + alltrim(otd->name) + '/��䨫� �� "' + ;
    //                alltrim(inieditspr(A__MENUVERT, getV002(), human_->profil)) + '"')
    for i := 1 to len(ta)
      for j := 1 to perenos(t_arr, ta[i], 78)
        if j == 1
          add_string(iif(i == 1, ' ', '- ') + t_arr[j])
        else
          add_string(padl(alltrim(t_arr[j]), 80))
        endif
      next
    next
    return .f.
    // altd()
  endif

  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
    if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data, @auet, @lbukva, @lst, @lidsp, @s)
      if empty(hu->kol_1)
        aadd(ta, '�� ��������� ���� "������⢮ ���" ��� "' + alltrim(usl->shifr) + '"')
      endif
      lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
      if hu->STOIM_1 > 0 .or. lTypeLUOnkoDisp .or. left(lshifr, 3) == '71.'  // ᪮�� ������
        if !empty(lbukva) .and. ascan(a_bukva, {|x| x[1] == lbukva }) == 0
          aadd(a_bukva, {lbukva, lshifr})
        endif
        if !empty(lidsp) .and. ascan(a_idsp, {|x| x[1] == lidsp }) == 0
          aadd(a_idsp, {lidsp, lshifr})
        endif
      endif
      if lst == 1
        k := 0 ; lstshifr := '' ; lstkol := hu->kol_1
        for i := 1 to len(lshifr)
          if !empty(c := substr(lshifr, i, 1))
            lstshifr += c
            if c == '.' ; ++k ; endif
            if k == 2 ; exit ; endif // ��� �窨 � ��� ��㣨
          endif
        next
      endif
      otd->(dbGoto(hu->OTD))
      hu->(G_RLock(forever))
      hu_->(G_RLock(forever))
      if hu->is_edit == -1 .and. alltrim(lshifr) == '4.27.2'
        hu->is_edit := 0 // ��ࠢ����� ��砫쭮� �訡��
      elseif hu->is_edit == 0 .and. is_lab_usluga(lshifr)
        hu->is_edit := -1
        hu->kod_vr := hu->kod_as := 0
        lprofil := iif(left(lshifr, 5) == '4.16.', 6, 34)
        if select('MOPROF') == 0
          R_Use(dir_exe + '_mo_prof', cur_dir + '_mo_prof', 'MOPROF')
          //index on shifr+ str(vzros_reb, 1) + str(profil, 3) to (sbase)
        endif
        select MOPROF
        find (padr(lshifr, 20) + str(iif(human->vzros_reb == 0, 0, 1), 1))
        if found()
          lprofil := moprof->profil
        endif
        hu_->profil := lprofil
      endif
      if left(lshifr, 5) == '60.8.'
        hu_->profil := 15   // ���⮫����
        mprvs := hu_->PRVS := -13 // ������᪠� ������ୠ� �������⨪�
      elseif empty(hu->kod_vr)
        if eq_any(alltrim(lshifr), '4.20.2')
          // �� ���������� ��� ���
        elseif pr_amb_reab .and. left(lshifr, 2)=='4.' .and. (left(hu_->zf, 6)=='999999' .or. left(hu_->zf, 6)!=glob_mo[_MO_KOD_TFOMS])
          // �� ���������� ��� ���
        elseif hu->is_edit == -1
          if human_->USL_OK == USL_OK_POLYCLINIC
            hu_->PRVS := iif(hu_->profil == 34, -13, -54)
          else
            aadd(ta, '������ୠ� ��㣠 "' + alltrim(usl->shifr) + '" ����� ���� ������� ⮫쪮 � �����������')
          endif
        elseif hu->is_edit == 0 .and. (! is_disp_DVN_COVID) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨
          aadd(ta, '�� ��������� ���� "���, ������訩 ���� ' + alltrim(usl->shifr) + '"')
        endif
      else
        if empty(mvrach) .and. !(ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34))
          mvrach := hu->kod_vr
        endif
        pers->(dbGoto(hu->kod_vr))
        mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
        if empty(mprvs) .and. (! is_disp_DVN_COVID) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨
          aadd(ta, '��� ᯥ樠�쭮�� � �ࠢ�筨�� ���ᮭ��� � "' + alltrim(pers->fio) + '"')
        elseif hu_->PRVS != mprvs
          hu_->PRVS := mprvs
        endif
        if hu_->PRVS > 0 .and. ret_V004_V015(hu_->PRVS) == 0
          aadd(ta, '�� ������� ᯥ樠�쭮�� � �ࠢ�筨�� V015 � "' + alltrim(pers->fio) + '"')
        endif
        if alltrim(lshifr) == '1.11.1' .and. human_->profil == 28 .and. human_2->profil_k == 24
          // ��䨫� '��䥪樮��� �������' � ��䨫� ����� '��䥪樮���'
        else // �஢��塞 �� ᯥ樠�쭮���
          UslugaAccordancePRVS(lshifr , human->vzros_reb, hu_->prvs, ta, usl->shifr, hu->kod_vr)
        endif
      endif
      if empty(mprofil)
        mprofil := usl->profil
        if empty(mprofil)
          mprofil := hu_->profil
        endif
      endif
      if empty(hu_->profil)
        hu_->profil := usl->profil
        if empty(hu_->profil)
          hu_->profil := otd->profil
        endif
      endif
      if hu_->profil > 0 .and. hu_->profil != correct_profil(hu_->profil)
        hu_->profil := correct_profil(hu_->profil)
      endif
      if !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
      endif
      mdate := c4tod(hu->date_u)

      if !empty(hu->kod_vr) .and. mdate >= human->n_data
        arr_perso := addKodDoctorToArray(arr_perso, hu->kod_vr)
      endif

      mdate_u1 := dtoc4(human->n_data)
      mdate_u2 := hu->date_u
      alltrim_lshifr := alltrim(lshifr)
      left_lshifr_2 := left(lshifr, 2)
      left_lshifr_3 := left(lshifr, 3)
      left_lshifr_4 := left(lshifr, 4)
      left_lshifr_5 := left(lshifr, 5)
      if hu->kol_1 > 1 .and. ascan(arr_lfk, alltrim_lshifr) > 0
        mdate_u2 := dtoc4(mdate + hu->kol_1 - 1)
      endif
      // �஢��塞 �� ��䨫�
      lprofil := UslugaAccordanceProfil(lshifr, human->vzros_reb, hu_->profil, ta, usl->shifr)
      if human_->USL_OK == USL_OK_AMBULANCE .and. lprofil != hu_->profil
        hu_->profil := lprofil
      endif
      dbSelectArea(lal)
      find (padr(lshifr, 10))
      if found() .and. !empty(&lal.->unit_code) .and. ascan(arr_unit, &lal.->unit_code) == 0
        aadd(arr_unit, &lal.->unit_code)
      endif
      aadd(au_lu, {lshifr, ;              // 1 ��� ��㣨
                  mdate, ;               // 2 ��� �।��⠢�����
                  hu_->profil, ;         // 3 ��䨫� ��㣨
                  hu_->PRVS, ;           // 4 ��� ᯥ樠�쭮�� ���
                  alltrim(usl->shifr), ; // 5
                  hu->kol_1, ;           // 6 ������⢮ �।��⠢�����
                  c4tod(mdate_u2), ;     // 7
                  hu_->kod_diag, ;       // 8
                  hu->(recno()), ;       // 9 - ����� �����
                  hu->is_edit, ;         // 10
                  hu_->date_end  })      // 11 - ��� ����砭�� �।��⠢����� ��㣨
      kodKSG := ''
      if is_ksg(lshifr)
        if !empty(s) .and. ',' $ s
          lvidpoms := s
        endif
        shifr_ksg := kodKSG := alltrim_lshifr
        cena_ksg := hu->u_cena
        if substr(kodKSG, 3, 2) == '37'
          is_reabil := .t.
        elseif kodKSG == 'ds02.005'
          is_eko := .t.
        endif
        kol_ksg += hu->kol_1
      endif
      if !empty(kodKSG) // ���
        if left(kodKSG, 2) == 'st'
          musl_ok := USL_OK_HOSPITAL  // 1 - ��樮���
          midsp := 33
        else
          musl_ok := USL_OK_DAY_HOSPITAL  // 2 - ������� ��樮���
          midsp := 33
        endif
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_2 == '1.'
        musl_ok := USL_OK_HOSPITAL  // 1 - ��樮���
        mdate_u2 := dtoc4(human->k_data)
        if left_lshifr_5 == '1.11.'
          kkd += hu->kol_1
          kkd_1_11 += hu->kol_1
          hu_->PZKOL := hu->kol_1
          if mdate+hu->kol_1 <= d2
            mdate_u2 := dtoc4(mdate + hu->kol_1)
          endif
        // elseif left_lshifr_5 == '1.12.' // ���
        //   midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
        //   kkd_1_12 += hu->kol_1
        //   kol_ksg += hu->kol_1
        //   hu_->PZKOL := d
        //   if !is_12_VMP
        //     aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr+ ' ����饭� � ��襩 ��')
        //   endif
        else
          for iVMP := 2021 to WORK_YEAR
            if left_lshifr_5 == code_services_VMP(iVMP)
              midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
              kkd_1_12 += hu->kol_1
              kol_ksg += hu->kol_1
              hu_->PZKOL := d
              if ! value_public_is_VMP(iVMP)
                aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr + ' ����饭� � ��襩 ��')
              endif
            endif
          next
        // elseif left_lshifr_5 == '1.12.' .and. (year(human->k_data) == 2019) // ���
        //   midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
        //   kkd_1_12 += hu->kol_1
        //   kol_ksg += hu->kol_1
        //   hu_->PZKOL := d
        //   if !is_19_VMP
        //     aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr+ ' ����饭� � ��襩 ��')
        //   endif
        // elseif left_lshifr_5 == '1.12.' .and. (year(human->k_data) == 2020) // ���
        //   midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
        //   kkd_1_12 += hu->kol_1
        //   kol_ksg += hu->kol_1
        //   hu_->PZKOL := d
        //   if !is_20_VMP
        //     aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr+ ' ����饭� � ��襩 ��')
        //   endif
        // elseif (left_lshifr_5 == '1.20.') // ���  // 11.02.22
        //   midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
        //   kkd_1_12 += hu->kol_1
        //   kol_ksg += hu->kol_1
        //   hu_->PZKOL := d
        //   if !is_21_VMP
        //     aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr+ ' ����饭� � ��襩 ��')
        //   endif
        // elseif (left_lshifr_5 == '1.21.') // ���  // 11.02.22
        //   midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
        //   kkd_1_12 += hu->kol_1
        //   kol_ksg += hu->kol_1
        //   hu_->PZKOL := d
        //   if !is_22_VMP
        //     aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr+ ' ����饭� � ��襩 ��')
        //   endif
        // elseif (left_lshifr_5 == '1.22.') // ���  // 01.03.23
        //   midsp := 18 // �����祭�� ��砩 � ��㣫����筮� ��樮���
        //   kkd_1_12 += hu->kol_1
        //   kol_ksg += hu->kol_1
        //   hu_->PZKOL := d
        //   if !is_23_VMP
        //     aadd(ta, 'ࠡ�� � ��㣮� ' + alltrim_lshifr+ ' ����饭� � ��襩 ��')
        //   endif
        // else
        //   // �訡��
        endif
        hu_->PZTIP := 1
      elseif left_lshifr_3 == '55.'
        musl_ok := USL_OK_DAY_HOSPITAL  // 2  // ��.��樮���
        mdate_u2 := dtoc4(human->k_data)
        if left_lshifr_5 == '55.1.' // ���-�� ��樥��-����
          kds += hu->kol_1
          kol_55_1 += hu->kol_1
          hu_->PZKOL := hu->kol_1
          if mdate + hu->kol_1-1 <= d2
            mdate_u2 := dtoc4(mdate + hu->kol_1 - 1)
          endif
        else
          // �訡��
        endif
        hu_->PZTIP := 2
      elseif alltrim_lshifr == '56.1.723' .and. human->ishod == 202 .and. !is_disp_19 // ��ன �⠯ ��� - ���� ��㣠
        is_disp_DVN := .t.
        is_exist_Prescription := .t.
        // elseif alltrim_lshifr == '70.8' .and. eq_any(human->ishod, 401, 402) // �⠯ 㣫㡫����� ��ᯠ��ਧ�樨 ��᫥ COVID
      //   is_disp_DVN_COVID := .t.
      elseif eq_any(left_lshifr_5, '60.4.', '60.5.', '60.6.', '60.7.', '60.8.', '60.9.') .or. ;
             eq_any(alltrim_lshifr, '4.20.702', '4.15.746') // ���
        if alltrim_lshifr == '4.15.746' // �७�⠫�� �ਭ���
          mpovod := 1 // 1.0-���饭�� �� �����������
        else
          mpovod := 7 // 2.3-�������᭮� ��᫥�������
        endif
        mIDSP := 4 // ��祡��-���������᪠� ��楤��
        kkt += hu->kol_1
        hu_->PZTIP := 5
        hu_->PZKOL := hu->kol_1
        musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
        if left_lshifr_5 == '60.4.'
          is_kt := .t.
        elseif left_lshifr_5 == '60.5.'
          is_mrt := .t.
        elseif left_lshifr_5 == '60.6.'
          is_uzi := .t.
        elseif left_lshifr_5 == '60.7.'
          is_endo := .t.
        elseif left_lshifr_5 == '60.8.'
          is_gisto := .t.
        elseif left_lshifr_5 == '60.9.'
          is_mgi := .t.
          shifr_mgi := alltrim_lshifr
        elseif alltrim_lshifr == '4.20.702'
          is_g_cit := .t.
        elseif alltrim_lshifr == '4.15.746'
          is_pr_skr := .t.
        endif
      elseif left_lshifr_5 == '60.3.' .or. left_lshifr_5 == '60.10'// ������
        mIDSP := 4 // ��祡��-���������᪠� ��楤��
        kkt += hu->kol_1
        hu_->PZTIP := 5
        hu_->PZKOL := hu->kol_1
        mdate_u2 := dtoc4(human->k_data)
        if eq_any(alltrim_lshifr, '60.3.1', '60.3.12', '60.3.13')  // 04.12.22
          mpovod := 10 // 3.0
          musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
          is_perito := .t.
        elseif eq_any(alltrim_lshifr, '60.3.9', '60.3.10', '60.3.11') //01.12.21 
          musl_ok := USL_OK_DAY_HOSPITAL  // 2 - ������� ��樮���
          is_dializ := .t.
        else
          musl_ok := USL_OK_HOSPITAL  // 1 - ��樮���
          is_s_dializ := .t.
        endif
      elseif eq_any(left_lshifr_5, '71.1.', '71.2.', '71.3.')  // ᪮�� ������
        musl_ok := USL_OK_AMBULANCE // 4 - ���
        mIDSP := 24 // �맮� ᪮ன ����樭᪮� �����
        if left_lshifr_5 == '71.1.'
          is_71_1 := .t.
        elseif left_lshifr_5 == '71.2.'
          is_71_2 := .t.
        else
          is_71_3 := .t.
        endif
        hu_->PZTIP := 6
        hu_->PZKOL := hu->kol_1
        ksmp += hu->kol_1
      elseif left_lshifr_2 == '4.'
        if left_lshifr_5 == '4.26.'
          is_neonat := .t.
        endif
        if alltrim_lshifr == '4.17.785' // �������୮-��������᪮� ��᫥������� ������ � ᫨���⮩ �����窨 ��ᮣ��⪨, �⮣��⪨ � �⤥�塞��� ���孨� ���⥫��� ��⥩ �� ���� ��஭������ COVID-19 (�� �᪫�祭��� ���-��⥬)
          is_covid := .t.
        endif
        if eq_any(hu->is_edit, 1, 2) .and. d1 <= c4tod(mdate_u2)
          m1lis := hu->is_edit
        endif
      else
        musl_ok := USL_OK_POLYCLINIC  // 3 - �-��
        mIDSP := 1 // ���饭�� � �����������
        mpztip := 3
        mpzkol := hu->kol_1
        if hu->KOL_RCP < 0
          is_dom := .t.
        endif
        if left_lshifr_4 == '2.3.'
          kol_2_3++
        elseif left_lshifr_4 == '2.6.'
          kol_2_6++
        elseif left_lshifr_5 == '2.60.'
          kol_2_60++
        elseif eq_any(alltrim_lshifr, '2.4.1', '2.4.2')
          kol_2_4++
        elseif eq_any(alltrim_lshifr, '2.92.1', '2.92.2', '2.92.3')
          is_2_92_ := .t.
          if vozrast >= 18 .and. alltrim_lshifr == '2.92.3'
            aadd(ta, '��㣠 2.92.3 ����뢠���� ⮫쪮 ���� ��� �����⪠�')
          elseif vozrast < 18 .and. eq_any(alltrim_lshifr, '2.92.1', '2.92.2')
            aadd(ta, '��㣠 ' + alltrim_lshifr + ' ����뢠���� ⮫쪮 �����')
          endif
        elseif alltrim_lshifr == '2.93.1'
          kol_2_93_1++
        elseif left_lshifr_5 == '2.76.'
          mpovod := 7 // 2.3
          mIDSP := 12 // �������᭠� ��㣠 業�� ���஢��
        elseif left_lshifr_5 == '2.78.'
          mpovod := 10 // 3.0 ���饭�� �� �����������
          d_sroks := AfterAtNum('.', alltrim_lshifr)
          if between_shifr(alltrim_lshifr, '2.78.54', '2.78.60')
            fl_stom := .t.
            mpztip := 4
          else
            ++kvp_2_78
            is_2_78 := .t.
            mIDSP := 17 // �����祭�� ��砩 � �����������
            if eq_any(alltrim_lshifr, '2.78.90', '2.78.91') .and. len(mdiagnoz) > 0 .and. left(mdiagnoz[1], 1) == 'Z'
              mpovod := 11 // 3.1 ���饭�� � ���.楫��
            elseif alltrim_lshifr == '2.78.107' .and. (human->k_data >= 0d20230101)
              // ��������� �������᭠� ��㣠 2.78.107 02.2023
              mpovod := 4 // 1.3
              if ! f_is_diag_dn(mdiagnoz[1], , human->k_data)
                aadd(ta, '� ��㣥 ' + alltrim_lshifr + ' ������ ����� �����⨬� ������� ��� ��ᯠ��୮�� �������')
              endif
            endif
          endif
          mdate_u2 := dtoc4(human->k_data)
        elseif left_lshifr_5 == '2.79.'
          d_sroks := AfterAtNum('.', alltrim_lshifr)
          if between_shifr(alltrim_lshifr, '2.79.44', '2.79.50')
            mpovod := 8 // 2.5 - ���஭��
          else
            mpovod := 9 // 2.6
          endif
          if between_shifr(alltrim_lshifr, '2.79.59', '2.79.64')
            fl_stom := .t.
            mpztip := 4
          else
            is_2_79 := .t.
            if alltrim_lshifr == '2.79.51'
              is_pren_diagn := .t.
            else
              kvp_2_79++
            endif
          endif
        elseif left_lshifr_5 == '2.80.'
          d_sroks := AfterAtNum('.', alltrim_lshifr)
          mpovod := 2 // 1.1
          if between_shifr(alltrim_lshifr, '2.80.34', '2.80.38')
            fl_stom := .t.
            mpztip := 4
          else
            is_2_80 := .t.
          endif
        elseif left_lshifr_5 == '2.81.'
          mpovod := 1 // 1.0
          is_2_81 := .t.
        elseif left_lshifr_5 == '2.82.'
          if alltrim_lshifr == '2.82.10' .and. hu_->profil == 90
            aadd(ta, '��� ��㣨 2.82.10 ४�������� ���⠢���� ��䨫� "祫��⭮-��楢�� ���ࣨ�"')
          endif
          mpovod := 2 // 1.1
          is_2_82 := .t.
          mIDSP := 22 // ���饭�� � ��񬭮� �����
        elseif left_lshifr_5 == '2.83.'
          is_disp_DDS := .t.
          is_2_83 := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '2.84.'
          mIDSP := 11 // ��ᯠ��ਧ���
          is_disp_DVN := .t.
          is_2_84 := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '7.80.'
          mIDSP := 30 // 㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID
          is_disp_DVN_COVID := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '2.85.' // ��䨫��⨪� ��ᮢ��襭����⭨�
          is_prof_PN := .t.
          is_2_85 := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '2.87.'
          is_disp_DDS := .t.
          is_2_87 := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '2.88.'
          d_sroks := AfterAtNum('.', alltrim_lshifr)
          mpovod := 1 // 1.0
          if between_shifr(alltrim_lshifr, '2.88.46', '2.88.51')
            fl_stom := .t.
            mpztip := 4
          else
            is_2_88 := .t.
            if between_shifr(alltrim_lshifr, '2.88.111', '2.88.118') .and. (human->k_data < 0d20220201)
              if is_dom
                is_dom := .f. // �⮡� ��� ��㣨 � ��஭�����ᮬ (�� ����) �� ������ ����� ���饭��
              else
                aadd(ta, '��㣠 ' + alltrim_lshifr + ' ����� ���� ������� ⮫쪮 "�� ����"')
              endif
            endif
          endif
        elseif left_lshifr_5 == '2.89.'
          mpovod := 10 // 3.0
          ++kvp_2_89
          is_2_89 := .t.
          i := 3
          k := int(val(AfterAtNum('.', alltrim_lshifr)))
          if     eq_any(k, 1, 13)
            i := 1  // ��.����.������
          elseif eq_any(k, 3, 14)
            i := 3  // �थ筮-��㤨��� ��⮫����
          elseif eq_any(k, 4, 15)
            i := 4  // 業�ࠫ쭠� ��ࢭ�� ��⥬�
          elseif eq_any(k, 5, 16)
            i := 5  // ������᪠� ��ࢭ�� ��⥬�
          elseif eq_any(k, 6, 17)
            i := 6  // ࠪ ����筮� ������
          elseif eq_any(k, 7, 18)
            i := 7  // ࠪ ���᪨� ������� �࣠���
          elseif eq_any(k, 8, 19)
            i := 8  // �ண���⠫�� ࠪ
          elseif eq_any(k, 9, 20)
            i := 9  // ����४⠫�� ࠪ
          elseif eq_any(k, 10, 21)
            i := 10 // ࠪ ������ � �஭客
          elseif eq_any(k, 11, 22)
            i := 11 // ���宫� ������ � 襨
          elseif eq_any(k, 12, 23)
            i := 12 // ���宫� ��饢���, ���㤪�
          elseif k == 24
            i := 13 // 2.89.24 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��, ��᫥ COVID-19'
          elseif k == 25
            i := 14 // 2.89.25 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��'
          elseif k == 26
            i := 15 // 2.89.26 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��, ��᫥ COVID-19 � ��-�� ⥫�����樭�'
          endif
          a_2_89[i] := 1
          mdate_u2 := dtoc4(human->k_data)
        elseif left_lshifr_5 == '2.90.'
          mIDSP := 11 // ��ᯠ��ਧ���
          is_disp_DVN := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '7.80.'  // 㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID
          mIDSP := 30 // '��� ᯮᮡ� ������' '30 - �� ���饭�� (�����祭�� ��砩)'
          is_disp_DVN_COVID := .t.
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '2.91.'
          mIDSP := 29 // �� ���饭�� � �����������
          is_prof_PN := .t.
          is_exist_Prescription := .t.
        elseif eq_any(left_lshifr_5, '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.') // ��ᯠ��ਧ��� ������
          is_disp_DVN := .t.
          is_exist_Prescription := .t.
          if eq_any(left_lshifr_5, '70.3.', '70.7.')
            mIDSP := 11 // ��ᯠ��ਧ���
          else
            is_disp_DVN3 := .t.
            is_exist_Prescription := .t.
            mIDSP := 17 // �����祭�� ��砩 � �����������
          endif
          ++kvp_70_3
          is_70_3 := .t.
          mdate_u2 := dtoc4(human->k_data)
        elseif left_lshifr_5 == '72.2.' // ��䨫��⨪� ��ᮢ��襭����⭨�
          is_prof_PN := .t.
          ++kvp_72_2
          is_72_2 := .t.
          mdate_u2 := dtoc4(human->k_data)
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '70.5.' // ��ᯠ��ਧ��� ��⥩-���
          is_disp_DDS := .t.
          mIDSP := 11 // ��ᯠ��ਧ���
          ++kvp_70_5
          is_70_5 := .t.
          mdate_u2 := dtoc4(human->k_data)
          is_exist_Prescription := .t.
        elseif left_lshifr_5 == '70.6.' // ��ᯠ��ਧ��� ��⥩-���
          is_disp_DDS := .t.
          mIDSP := 11 // ��ᯠ��ਧ���
          ++kvp_70_6
          is_70_6 := .t.
          mdate_u2 := dtoc4(human->k_data)
          is_exist_Prescription := .t.
        endif
        if is_usluga_disp_nabl(alltrim_lshifr)
          mpovod := 4 // 1.3-��ᯠ��୮� �������
          ldate_next := c4tod(human->DATE_OPL)
          if empty(ldate_next)
            aadd(ta, '��� ��㣨 ' + alltrim_lshifr+ ' �� ��������� "��� ᫥���饩 � ��樥�� ��� ��ᯠ��୮�� �������"')
          elseif ldate_next < d2
            aadd(ta, '��� ��㣨 ' + alltrim_lshifr+ ' "��� ᫥���饩 � ��樥�� ��� ��ᯠ��୮�� �������" ����� ���� ����砭�� ��祭��')
          endif
        endif
        kvp += hu->kol_1
        hu_->PZTIP := mPZTIP
        hu_->PZKOL := mPZKOL
      endif
      if musl_ok == USL_OK_POLYCLINIC // 3
        if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID
          //
        elseif mpovod > 0 .and. ascan(arr_povod, {|x| x[1] == mpovod }) == 0
          aadd(arr_povod, {mpovod, alltrim_lshifr})
        endif
      elseif !(hu->date_u==mdate_u1) .and. len(au_lu) == 1
        aadd(ta, '��� ��㣨 ' + alltrim_lshifr+ ' ������ ࠢ������ ��� ��砫� ��祭��')
      endif
      hu_->date_u2 := mdate_u2
      if empty(hu_->kod_diag) .and. len(mdiagnoz) > 0
        hu_->kod_diag := mdiagnoz[1]
      endif
      select MKB_10
      find (padr(hu_->kod_diag, 6))
      if !found()
        aadd(ta, '�� ������ ������� ' + alltrim(hu_->kod_diag) + '(' + alltrim(usl->shifr) + ') � �ࠢ�筨�� ���-10')
      endif
      aadd(adiag, hu_->kod_diag)
      atail(au_lu)[7] := c4tod(mdate_u2)
      atail(au_lu)[8] := hu_->kod_diag
      if empty(kodKSG) // ��� ��� 業� ��९஢�ਬ ��⮬ �१ definition_ksg()
        fl_del := fl_uslc := .f.
        v := fcena_oms(lshifr, (human->vzros_reb == 0), human->k_data, @fl_del, @fl_uslc)
        if fl_uslc  // �᫨ ��諨 � �ࠢ�筨�� �����
          if fl_del
            aadd(ta, '���� �� ���� ' + rtrim(lshifr) + ' ��������� � �ࠢ�筨�� �����')
          elseif !(round(v, 2) == round(hu->u_cena, 2))
            aadd(ta, '�訡�� � 業� ��㣨[' + ;
                    iif(human->vzros_reb == 0, '���', 'ॡ') + ;
                    ']: ' + rtrim(lshifr) + ': ' + lstr(hu->u_cena, 9, 2) + ;
                    ', ������ ����: ' + lstr(v, 9, 2))
          endif
          if !(round(hu->u_cena * hu->kol_1, 2) == round(hu->stoim_1, 2))
            aadd(ta, '��㣠 ' + rtrim(lshifr) + ': �㬬� ��ப� ' + ;
                    lstr(hu->stoim_1) + ' �� ࠢ�� �ந�������� ' + ;
                    lstr(hu->u_cena) + ' * ' + lstr(hu->kol_1))
          endif
        elseif is_disp_DVN_COVID .and. eq_any(alltrim(lshifr), 'A12.09.005', 'A12.09.001', 'B03.016.003', 'B03.016.004', ;
                              'A06.09.007', 'B01.026.002', 'B01.047.002', 'B01.047.006')
          ////////
        else
          aadd(ta, '�� ������� ��㣠 ' + rtrim(lshifr) + iif(human->vzros_reb==0, ' ��� ������', ' ��� ��⥩') + ' � �ࠢ�筨�� �����')
        endif
      endif
      if is_disp_DVN_COVID
        if hu->kod_vr != 0  // ��������� ��� ���
          ssumma += hu->stoim_1
        endif
      else
        ssumma += hu->stoim_1
      endif
    else
      aadd(au_lu_ne, {usl->shifr, ;        // 1
                     lshifr1, ;           // 2
                     usl->name, ;         // 3
                     c4tod(hu->date_u), ; // 4
                     hu->kol_1})         // 5
    endif
    
    select HU
    skip
  enddo
  if !is_mgi .and. ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0
    if eq_any(human_->profil, 6, 34)
      human->KOD_DIAG := 'Z01.7' // �ᥣ��
    endif
    mdiagnoz := diag_to_array(, , , , .t.)
    select HU
    find (str(human->kod, 7))
    do while hu->kod == human->kod .and. !eof()
      hu_->(G_RLock(forever))
      if eq_any(human_->profil, 6, 34)
        hu_->kod_diag := mdiagnoz[1]
      endif
      skip
    enddo
  elseif is_covid
    if len(mdiagnoz) > 0 .and. !(padr(mdiagnoz[1], 5) == 'Z01.7')
      aadd(ta, '��� ��㣨 4.17.785 �᭮���� ������� ������ ���� Z01.7')
    endif
    if empty(human_->NPR_MO)
      aadd(ta, '��� ��㣨 4.17.785 ������ ���� ��������� ���� "���ࠢ���� ��"')
    elseif empty(human_2->NPR_DATE)
      if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
        human_2->NPR_DATE := d1
      else
        aadd(ta, '������ ���� ��������� ���� "��� ���ࠢ�����"')
      endif
    elseif human_2->NPR_DATE > d1
      aadd(ta, '"��� ���ࠢ�����" ����� "���� ��砫� ��祭��"')
    elseif human_2->NPR_DATE+60 < d1
      aadd(ta, '���ࠢ����� ����� ���� ����楢')
    endif
    if !eq_any(human_->RSLT_NEW, 314)
      aadd(ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"')
    endif
    if !eq_any(human_->ISHOD_NEW, 304)
      aadd(ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"')
    endif
  endif

  checkRSLT_ISHOD(human_->RSLT_NEW, human_->ISHOD_NEW, ta)

  if len(arr_povod) > 0
    if len(arr_povod) > 1
      aadd(ta, 'ᬥ訢���� 楫�� ���饭�� � ��砥 ' + print_array(arr_povod))
    else
      if is_dom .and. arr_povod[1, 1] == 1
        arr_povod[1, 1] := 3 // 1.2 - ��⨢��� ���饭��, �.�. �� ����
      endif
      if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID
        //
      elseif human_->usl_ok == USL_OK_POLYCLINIC .and. len(mdiagnoz) > 0
        if len(a_idsp) == 1 .and. a_idsp[1, 1] != 28 // �.�. idsp �� ࠢ�� '�� ����樭��� ���� � �����������'
          if eq_any(arr_povod[1, 1], 1, 2, 4, 10) // 1.0, 1.1, 1.3, 3.0
            if !between(left(mdiagnoz[1], 1),'A','U')
              aadd(ta, '��� ���饭�� (���饭��) �� ������ ����������� �᭮���� ������� ������ ���� A00-T98 ��� U04,U07')
            endif
          elseif eq_any(arr_povod[1, 1], 9, 11) // 2.6, 3.1
            if !(left(mdiagnoz[1], 1) == 'Z')
              aadd(ta, '��� ���饭�� (���饭��) � ��䨫����᪮� 楫�� �᭮���� ������� ������ ���� Z00-Z99')
            endif
          endif
        endif
        if arr_povod[1, 1] == 4  .and. (left(mdiagnoz[1], 1) == 'C' .or. between(left(mdiagnoz[1], 3), 'D00', 'D09') .or. between(left(mdiagnoz[1], 3), 'D45', 'D47'))
          k := ret_prvs_V021(human_->PRVS)
          if !eq_any(k, 9, 19, 41)  // ��� �᪫�祭�� ������� ����⮫����, ᯥ樠�쭮��� - 9
            aadd(ta, '��ᯠ��୮� ������� �� ��� �����⢫��� ⮫쪮 ���-�������� (���᪨� ��������), � � ���� ���� �⮨� ᯥ樠�쭮��� "' + inieditspr(A__MENUVERT, getV021(), k) + '"')
          endif
        endif
      endif
    endif
  endif
  //
  if human->OBRASHEN == '1'
    for i := 1 to len(mdiagnoz)
      if left(mdiagnoz[i], 1) == 'C' .or. between(left(mdiagnoz[i], 3), 'D00', 'D09') .or. between(left(mdiagnoz[i], 3), 'D45', 'D47')
        aadd(ta, alltrim(mdiagnoz[i]) + ' �᭮���� (��� ᮯ������騩) ������� - ���������, ���⮬� � ���� "�����७�� �� ���" �� ������ ����� "��"')
        exit
      endif
    next
    for i := 1 to len(mdiagnoz3)
      if left(mdiagnoz3[i], 1) == 'C' .or. between(left(mdiagnoz3[i], 3), 'D00', 'D09') .or. between(left(mdiagnoz3[i], 3), 'D45', 'D47')
        aadd(ta, alltrim(mdiagnoz3[i]) + ' ������� �᫮������ - ���������, ���⮬� � ���� "�����७�� �� ���" �� ������ ����� "��"')
        exit
      endif
    next
  endif
  fl := (ascan(mdiagnoz, {|x| padr(x, 5) == 'Z03.1' }) > 0)
  if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID
    if is_oncology == 2
      is_oncology := 1
    endif
    if fl
      aadd(ta, '�� ��ᯠ��ਧ�樨 �� ������ ���� �᭮����� (��� ᮯ������饣�) �������� Z03.1 "������� �� �����७�� �� �������⢥���� ���宫�"')
    endif
  else
    for i := 1 to len(au_lu)
      if !between(au_lu[i, 2], d1, d2)
        aadd(ta, '��㣠 ' + au_lu[i, 5] + '(' + date_8(au_lu[i, 2]) + ') �� �������� � �������� ��祭��')
      endif
    next
    if human_->usl_ok < USL_OK_AMBULANCE .and. fl .and. !(human->OBRASHEN == '1')
      if is_oncology > 0 // ��������� - ���ࠢ�����
        aadd(ta, '�᭮���� (��� ᮯ������騩) ������� Z03.1 "������� �� �����७�� �� �������⢥���� ���宫�", �� ���� ���� � ⠪ ���������᪨�')
      else
        aadd(ta, '�᫨ �᭮���� (��� ᮯ������騩) ������� Z03.1 "������� �� �����७�� �� �������⢥���� ���宫�", � � ���� "�����७�� �� ���" ������ ����� "��"')
      endif
    endif
  endif
  if is_oncology_smp > 0 // ᯥ樠�쭮 ��� ᪮ன �����
    select ONKCO
    find (str(human->kod, 7))
    if found()
      if between(onkco->PR_CONS, 1, 3) .and. !between(onkco->DT_CONS, d1, d2)
        aadd(ta, '��� ���ᨫ�㬠 �� ��������� ������ ���� ����� �ப�� ��祭��')
      endif
    else
      AddRec(7)
      onkco->kod := human->kod
      onkco->PR_CONS := 0 // 0-��������� ����室������
      onkco->DT_CONS := ctod('')
      UnLock
    endif
  endif
  if is_oncology > 0 // ��������� - ���ࠢ�����
    if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
      //
    elseif human->OBRASHEN == '1' .and. ascan(mdiagnoz, {|x| padr(x, 5) == 'Z03.1' }) == 0
      aadd(ta, '�� "�����७�� �� ���" � ���� ���� ��易⥫쭮 ������ ���� �᭮���� (��� ᮯ������騩) ������� "Z03.1 ������� �� �����७�� �� �������⢥���� ���宫�"')
    endif
    i := 0
    arr := {}
    select ONKNA // �������ࠢ�����
    find (str(human->kod, 7))
    do while onkna->kod == human->kod .and. !eof()
      ++i
      aadd(arr, {onkna->NAPR_DATE, ;
                 onkna->NAPR_MO, ;
                 onkna->NAPR_V, ;
                 iif(onkna->NAPR_V == 3, onkna->MET_ISSL, 0), ;
                 iif(onkna->NAPR_V == 3, onkna->U_KOD, 0), ;
                 '', ;
                 onkna->(recno()), ;
                 onkna->KOD_VR })
      if !between(onkna->NAPR_DATE, d1, d2)
        aadd(ta, '��� ���ࠢ����� ������ ���� ����� �ப�� ��祭�� (���ࠢ����� ' + lstr(i) + ')')
      elseif !empty(s := verify_dend_mo(onkna->NAPR_MO, onkna->NAPR_DATE))
        aadd(ta, '�������ࠢ����� � ��: ' + s)
      endif
      if onkna->NAPR_V == 3
        if empty(onkna->MET_ISSL)
          aadd(ta, '�� ��।��� "��⮤ �����.��᫥�������" ��� ���ࠢ����� ' + lstr(i))
        elseif empty(onkna->KOD_VR)
          aadd(ta, '��������� ⠡���� ����� ���ࠢ��襣� ��� ��� ���ࠢ����� ' + lstr(i))
        elseif empty(onkna->U_KOD)
          aadd(ta, '�� ��।����� "����樭᪠� ��㣠" ��� ���ࠢ����� ' + lstr(i))
        else
          select MOSU
          goto (onkna->U_KOD)
          if empty(mosu->shifr1)
            aadd(ta, '�� ��।����� "����樭᪠� ��㣠" ��� ���ࠢ����� ' + lstr(i))
          else
            dbSelectArea(lalf)
            find (padr(mosu->shifr1, 20))
            if found()
              if onkna->MET_ISSL != &lalf.->onko_napr
                aadd(ta, '�� �� ��⮤ ���������᪮�� ��᫥������� � ��㣥 ' + ;
                        alltrim(iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)) + ' ��� ���ࠢ����� ' + lstr(i))
              endif
            else
              aadd(ta, '��㣠 ' + alltrim(iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)) + ;
                      ' �� ������� � �ࠢ�筨�� (��� ���ࠢ����� ' + lstr(i) + ')')
            endif
          endif
        endif
      endif
      select ONKNA
      skip
    enddo
    if eq_any(human_->RSLT_NEW, 308, 309)
      if ascan(arr, {|x| eq_any(x[3], 1, 4) }) == 0
        aadd(ta, '�� "�����७�� �� ���" ��� ���������᪮� �������� � ���� ���� � १����� ��祭�� "308 ���ࠢ��� �� ���������" ��� "309 ���ࠢ��� �� ��������� � ��㣮� ���" ��易⥫쭮 ������ ���� ���ࠢ����� "� ��������" ��� "��� ��।������ ⠪⨪� ��祭��"')
      endif
    elseif human_->RSLT_NEW == 315
      if ascan(arr, {|x| x[3] == 3 }) == 0
        aadd(ta, '�� "�����७�� �� ���" ��� ���������᪮� �������� � ���� ���� � १���� ��祭�� "315 ���ࠢ��� �� ��᫥�������" ��易⥫쭮 ������ ���� ���ࠢ����� "�� ����᫥�������"')
      endif
    endif
    if len(arr) > 0
      arr_onkna := aclone(arr)
    endif
    for i := 1 to len(arr)  // �饬 �㡫����� ���ࠢ�����
      s := dtos(arr[i, 1]) + arr[i, 2] + str(arr[i, 3], 1) + str(arr[i, 4], 1) + str(arr[i, 5], 6)
      arr[i, 6] := s
      if i > 1 .and. (j := ascan(arr, {|x| s == x[6] }, 1, i-1)) > 0
        select ONKNA
        goto (arr[i, 7])
        DeleteRec(.t.)  // 㤠�塞 �㡫���� ���ࠢ�����
      endif
    next
  endif
  //
  select MOHU
  find (str(human->kod, 7))
  do while mohu->kod == human->kod .and. !eof()
    lshifr := mosu->shifr1
    dbSelectArea(lalf)
    find (padr(lshifr, 20))
    usl_found := found()
    s := alltrim(mosu->shifr1) + iif(empty(mosu->shifr), '', '(' + alltrim(mosu->shifr) + ')')
    if mosu->tip == 5
      aadd(ta, '��㣠 "' + s + '" 㤠���� � 2017 ����')
    endif
    if empty(mohu->kol_1)
      aadd(ta, '�� ��������� ���� "������⢮ ���" ��� "' + s + '"')
    endif
    mdate := c4tod(mohu->date_u)
    if !between(mdate, d1, d2)
      if usl_found .and. &lalf.->telemed == 1 .and. mdate < d1
        // ࠧ��蠥��� ����뢠�� ࠭��
      elseif eq_any(left(lshifr, 4), 'A06.', 'A12.', 'B01.', 'B03.')
        // ࠧ��蠥��� ����뢠�� ࠭��
      else
        aadd(ta, '��㣠 ' + s + ' (' + date_8(mdate) + ') �� �������� � �������� ��祭��')
      endif
    endif
    otd->(dbGoto(mohu->OTD))
    mohu->(G_RLock(forever))
    if empty(mohu->kod_vr) .and. (! is_disp_DVN_COVID) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨
      if usl_found .and. &lalf.->telemed == 1
        if !(mohu->PRVS == human_->PRVS)
          mohu->PRVS := human_->PRVS // ��� ⥫�����樭� ᯥ樠�쭮��� �����㥬 �� ����
        endif
        if !(mohu->profil == human_->profil)
          mohu->profil := human_->profil // ��� ⥫�����樭� ��䨫� �����㥬 �� ����
        endif
      else
        aadd(ta, '�� ��������� ���� "���, ������訩 ���� ' + s + '"')
      endif
    else

      arr_perso := addKodDoctorToArray(arr_perso, mohu->kod_vr)

      if empty(mvrach) .and. !(ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34))
        mvrach := mohu->kod_vr
      endif
      pers->(dbGoto(mohu->kod_vr))
      mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
      if empty(mprvs) .and. (! is_disp_DVN_COVID) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨
        aadd(ta, '��� ᯥ樠�쭮�� � �ࠢ�筨�� ���ᮭ��� � "' + alltrim(pers->fio) + '"')
      elseif mohu->PRVS != mprvs
        mohu->PRVS := mprvs
      endif
      if mohu->PRVS > 0 .and. ret_V004_V015(mohu->PRVS) == 0
        aadd(ta, '�� ������� ᯥ樠�쭮�� � �ࠢ�筨�� V015 � "' + alltrim(pers->fio) + '"')
      endif
    endif
    if empty(mprofil)
      mprofil := mosu->profil
      if empty(mprofil)
        mprofil := mohu->profil
      endif
    endif
    if empty(mohu->profil)
      mohu->profil := mosu->profil
      if empty(mohu->profil)
        mohu->profil := otd->profil
      endif
    endif
    if empty(mohu->profil)
      aadd(ta, '��� ��㣨 ' + s + ' �� ��������� ���� "��䨫�"')
    elseif mohu->profil != correct_profil(mohu->profil)
      mohu->profil := correct_profil(mohu->profil)
    endif
    ltip_onko := 0
    if usl_found
      if !empty(&lalf.->par_org)
        if empty(mohu->zf)
          aadd(ta, '� ��㣥 ' + s + ' �� ������� �࣠�� (��� ⥫�), �� ������ �믮����� ������')
        else
          a1 := List2Arr(mohu->zf)
          a2 := List2Arr(&lalf.->par_org)
          s1 := ''
          for i := 1 to len(a2)
            if ascan(a1, a2[i]) > 0
              s1 += lstr(a2[i]) + ','
            endif
          next
          if !empty(s1)
            s1 := left(s1, len(s1) - 1)
          endif
          if empty(s1) .or. !(s1 == alltrim(mohu->zf))
            aadd(ta, '� ��㣥 ' + s + ' �����४⭮ ������� �࣠�� (��� ⥫�) ' + alltrim(mohu->zf))
          endif
        endif
      endif
      ltip_onko := &lalf.->onko_ksg
      do case
        case human_->usl_ok == USL_OK_HOSPITAL  // 1
          if &lalf.->tip == 2
            aadd(ta, '��㣠 ' + s + ' �⭮���� � �⮬�⮫����᪨�')
          endif
        case human_->usl_ok == USL_OK_DAY_HOSPITAL  // 2
          if &lalf.->tip == 2
            aadd(ta, '��㣠 ' + s + ' �⭮���� � �⮬�⮫����᪨�')
          endif
        case human_->usl_ok == USL_OK_POLYCLINIC
          if fl_stom
            if empty(&lalf.->tip)
              aadd(ta, '��㣠 ' + s + ' �� �⭮���� � �⮬�⮫����᪨�')
            else
              // �஢��塞 �� ��䨫�
              UslugaAccordanceProfil(lshifr, human->vzros_reb, mohu->profil, ta, mosu->shifr)
              // �஢��塞 �� ᯥ樠�쭮���
              UslugaAccordancePRVS(lshifr, human->vzros_reb, mohu->prvs, ta, mosu->shifr, mohu->kod_vr)
            endif
            if &lalf.->zf == 1  // ��易⥫�� ���� �㡭�� ����
              arr_zf := STverifyZF(mohu->zf, human->date_r, d1, ta, s)
              STVerifyKolZf(arr_zf, mohu->kol_1, ta, s)
            endif
          elseif &lalf.->telemed == 0 .and. ! eq_any(alltrim(&lalf.->shifr), ;
              'A12.09.005', 'A12.09.001', 'B03.016.003', 'B03.016.004', 'A06.09.007', 'B01.026.001', 'B01.026.002', ;
              'A23.30.023','A09.05.051.001','A04.10.002','A06.09.005','A04.12.006.002')
            aadd(ta, '���� ' + s + ' ����� ������� ��� ���㫠�୮� �����')
          endif
        case human_->usl_ok == USL_OK_AMBULANCE // 4
          if &lalf.->telemed == 0
            aadd(ta, '���� ' + s + ' ����� ������� ��� ᪮ன �����')
          endif
      endcase
    else
      aadd(ta, '��㣠 ' + s + ' �� ������� � �ࠢ�筨��')
    endif
    if !valid_GUID(mohu->ID_U)
      mohu->ID_U := mo_guid(4,mohu->(recno()))
    endif
    mohu->date_u2 := mohu->date_u
    if empty(mohu->kod_diag) .and. len(mdiagnoz) > 0
      mohu->kod_diag := mdiagnoz[1]
    endif
    select MKB_10
    find (padr(mohu->kod_diag, 6))
    if !found()
      aadd(ta, '�� ������ ������� ' + alltrim(mohu->kod_diag) + ' � �ࠢ�筨�� ���-10')
    endif
    aadd(au_flu, {lshifr, ;               // 1
                 mdate, ;                // 2
                 mohu->profil, ;         // 3
                 mohu->PRVS, ;           // 4
                 mosu->shifr, ;          // 5
                 mohu->kol_1, ;          // 6
                 c4tod(mohu->date_u2), ; // 7
                 mohu->kod_diag, ;       // 8
                 mohu->(recno()), ;      // 9
                 ltip_onko, ;            // 10 ⨯ ���������᪮�� ��祭��
                 .f.})                  // 11 ⨯ ���������᪮�� ��祭�� �⠢�� � ����
    select MOHU
    skip
  enddo
  v := 0
  if is_oncology == 2 // ���������
    select ONKSL
    find (str(human->kod, 7))
    select ONKCO
    find (str(human->kod, 7))
    if found()
      if between(onkco->PR_CONS, 1, 3) .and. !between(onkco->DT_CONS, d1, d2)
        aadd(ta, '��� ���ᨫ�㬠 �� ��������� ������ ���� ����� �ப�� ��祭��')
      endif
    else
      AddRec(7)
      onkco->kod := human->kod
      onkco->PR_CONS := 0 // 0-��������� ����室������
      onkco->DT_CONS := ctod('')
      UnLock
    endif
    fl := .t.
    if between(onksl->ds1_t, 0, 4)
      if empty(onksl->STAD)
        aadd(ta, '���������: �� ������� �⠤�� �����������')
      else
        f_verify_tnm(2,onksl->STAD, mdiagnoz[1], ta)
      endif
    endif
    if kkt > 0 .and. onksl->ds1_t != 5
      aadd(ta, '���������: ��� �⤥���� ���������᪨� ��� � ���� "����� ���饭��" ������ ���� ���⠢���� "�������⨪�"')
    endif
    if len(arr_povod) > 0 .and. arr_povod[1, 1] == 4 .and. onksl->ds1_t != 4
      aadd(ta, '���������: � ��砥 ��ᯠ��୮�� ������� � ���� "����� ���饭��" ������ ���� ���⠢���� "��ᯠ��୮� �������"')
    endif
    if onksl->ds1_t == 0 .and. human->vzros_reb == 0
      if empty(onksl->ONK_T)
        fl := .f. ; aadd(ta, '���������: �� ������� �⠤�� ����������� T')
      endif
      if empty(onksl->ONK_N)
        fl := .f. ; aadd(ta, '���������: �� ������� �⠤�� ����������� N')
      endif
      if empty(onksl->ONK_M)
        fl := .f. ; aadd(ta, '���������: �� ������� �⠤�� ����������� M')
      endif
      if fl
        fl := f_verify_tnm(3,onksl->ONK_T, mdiagnoz[1], ta)
      endif
      if fl
        fl := f_verify_tnm(4,onksl->ONK_N, mdiagnoz[1], ta)
      endif
      if fl
        fl := f_verify_tnm(5,onksl->ONK_M, mdiagnoz[1], ta)
      endif
    endif
    // ���⮫����
    if is_gisto .and. onksl->b_diag != 98
      aadd(ta, '��� ���� ���� �� ���⮫���� ��易⥫�� ���� १���⮢ ���⮫����')
    endif
    if is_mgi .and. onksl->b_diag != 98
      aadd(ta, '��� ���� ���� �� �������୮� ����⨪� ��易⥫�� ���� १���⮢ ���㭮����娬��')
    endif
    if onksl->b_diag == 0 // �⪠�
      // �� ��⠢����� ॥��� ᠬ����⥫쭮 ��������� ���� ��⨢���������� id_prot = 0
    elseif onksl->b_diag == 7 // �� ��������
      // �� ��⠢����� ॥��� ᠬ����⥫쭮 ��������� ���� ��⨢���������� id_prot = 7
    elseif onksl->b_diag == 8 // ��⨢���������
      // �� ��⠢����� ॥��� ᠬ����⥫쭮 ��������� ���� ��⨢���������� id_prot = 8
    elseif onksl->b_diag == -1 // �믮����� (�� 1 ᥭ���� 2018 ����)
      // �� ��⠢����� ॥��� ���� B_DIAG �� ����������
    elseif eq_any(onksl->b_diag, 97, 98) // �믮�����
      ar_N009 := {}
      if select('N9') == 0
        R_Use(dir_exe + '_mo_N009', , 'N9')
      endif
      if !is_mgi
        select N9
        dbeval({|| aadd(ar_N009, {'', n9->id_mrf, {}}) }, ;
               {|| between_date(n9->datebeg, n9->dateend, d2) .and. padr(mdiagnoz[1], 3) == n9->ds_mrf })
      endif
      // ���㭮����娬��/��થ��
      ar_N012 := {}
      if select('N12') == 0
        R_Use(dir_exe + '_mo_N012', , 'N12')
      endif
      select N12
      dbeval({|| aadd(ar_N012, {'',n12->id_igh, {}}) }, ;
             {|| between_date(n12->datebeg,n12->dateend, d2) .and. padr(mdiagnoz[1], 3) == n12->ds_igh })
      if is_mgi
        if (i := ascan(glob_MGI, {|x| x[1] == shifr_mgi })) > 0 // ��㣠 �室�� � ᯨ᮪ �����
          if (j := ascan(ar_N012, {|x| x[2] == glob_MGI[i, 2] })) > 0 // �� ������� �������� ��������� ����室��� ��થ�
            tmp_arr := {}
            aadd(tmp_arr, aclone(ar_N012[j]))
            ar_N012 := aclone(tmp_arr) // ��⠢�� � ���ᨢ� ⮫쪮 ���� �㦭� ��� ��થ�
          else
            ar_N012 := {}
          endif
        else
          ar_N012 := {}
        endif
      endif
      arr_onkdi0 := {}
      arr_onkdi1 := {}
      arr_onkdi2 := {}
      ngist := nimmun := 0 ; fl_krit_date := .f.
      select ONKDI
      find (str(human->kod, 7))
      if found()
        if empty(onkdi->DIAG_DATE)
          aadd(arr_onkdi0, .f.)
        else
          if is_gisto .and. onkdi->DIAG_DATE != d1
            aadd(ta, '��� ���⮫���� ��� ����� ���ਠ�� ' + date_8(onkdi->DIAG_DATE) + '�. �� ࠢ����� ��� ��砫� ��祭�� ' + date_8(d1) + '�.')
          elseif onkdi->DIAG_DATE < 0d20180901
            fl_krit_date := .t.
            //aadd(ta, '��� ����� ���ਠ�� ' + date_8(onkdi->DIAG_DATE) + '�. ����� ����������� ����')
          endif
        endif
        do while onkdi->kod == human->kod .and. !eof()
          if onkdi->DIAG_TIP == 1
            aadd(arr_onkdi1, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
            if onkdi->DIAG_RSLT > 0
              ++ngist
            endif
          elseif onkdi->DIAG_TIP == 2
            aadd(arr_onkdi2, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
            if onkdi->DIAG_RSLT > 0
              ++nimmun
            endif
          endif
          skip
        enddo
      endif
      if fl_krit_date // �믮����� (�� 1 ᥭ���� 2018 ����)
        select ONKDI // �� ��⠢����� ॥��� ���� B_DIAG �� ����������
        do while .t.
          find (str(human->kod, 7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        select ONKSL
        G_RLock(forever)
        onksl->b_diag := -1
        UnLock
      else
        if len(arr_onkdi0) > 0
          aadd(ta, '�� ��������� ��� ����� ���ਠ��')
        endif
        if is_gisto .and. emptyall(len(ar_N009),len(ar_N012))  // ���⨥ ���⮫���� � �ࠢ�筨�� �����
          if empty(ngist)
            aadd(ta, '��� ���㫠�୮�� ���� �� ����� ���⮫����᪮�� ���ਠ�� ��易⥫쭮 ���������� ���� "�������� ���⮫����"')
          endif
        else
          if is_mgi
            if len(arr_onkdi1) > 0
              aadd(ta, '��� ���� ���� �� �������୮� ����⨪� �� ������ ����������� ⠡��� ���⮫����')
            endif
          elseif len(arr_onkdi1) != len(ar_N009)
            aadd(ta, '�訡�� ���������� ⠡���� ���⮫����')
          endif
          if len(arr_onkdi2) != len(ar_N012)
            aadd(ta, '�訡�� ���������� ⠡���� ���㭮����娬��')
          elseif is_mgi .and. len(ar_N012) > 0 .and. len(arr_onkdi2) != 1
            aadd(ta, '��� ���� ���� �� �������୮� ����⨪� ��������� ⮫쪮 ���� ��થ� �� ���㭮����娬��')
          endif
          if onksl->b_diag == 98
            if ngist != len(ar_N009)
              aadd(ta, '�� �� ���⮫���� ���������')
            endif
            if nimmun != len(ar_N012)
              aadd(ta, '�� �� ���㭮����娬�� ���������')
            endif
          endif
        endif
      endif
    endif
    //
    if select('N1') == 0
      R_Use(dir_exe + '_mo_N001', , 'N1')
    endif
    select ONKPR
    find (str(human->kod, 7))
    do while onkpr->kod == human->kod .and. !eof()
      if !between(onkpr->PROT, 0, 8)
        aadd(ta, '�����४⭮ ����ᠭ� ��⨢���������� � �஢������ (�⪠� �� �஢������)')
      elseif onkpr->D_PROT > d2
        n1->(dbGoto(onkpr->PROT))
        aadd(ta, alltrim(lower(n1->prot_name)) + ' - ��� ॣ����樨 ����� ���� ����砭�� ��祭��')
      endif
      select ONKPR
      skip
    enddo
    // ��㣠 ��易⥫쭠 ��� ��樮��� � �������� ��樮��� �� �஢������ ��⨢����宫����� ��祭��
    if human_->usl_ok < USL_OK_POLYCLINIC // 3
      arr_onk_usl := {}
      select ONKUS
      find (str(human->kod, 7))
      do while onkus->kod == human->kod .and. !eof()
        if between(onkus->USL_TIP, 1, 6)
          aadd(arr_onk_usl,onkus->USL_TIP)
          k := iif(onkus->USL_TIP == 4, 3, onkus->USL_TIP)
          if (i := ascan(au_flu, {|x| x[10] == k })) > 0
            if onkus->USL_TIP == 1
              if empty(onkus->HIR_TIP)
                aadd(ta, '�� �������� ⨯ ���ࣨ�᪮�� ��祭��')
              endif
            elseif onkus->USL_TIP == 2
              if empty(onkus->LEK_TIP_V)
                aadd(ta, '�� �������� 横� ������⢥���� �࠯��')
              endif
              if empty(onkus->LEK_TIP_L)
                aadd(ta, '�� ��������� ����� ������⢥���� �࠯��')
              endif
            elseif between(onkus->USL_TIP, 3, 4)
              if empty(onkus->LUCH_TIP)
                aadd(ta, '�� �������� ⨯ ' + iif(onkus->USL_TIP==3,'','娬��') + '��祢�� �࠯��')
              endif
            endif
            au_flu[i, 11] := .t.
          elseif eq_any(onkus->USL_TIP, 1, 3, 4)
            aadd(ta, '�� ������� ��㣠 ��� ��࠭���� ⨯� ���������᪮�� ��祭�� (' + ;
                    {'����.', '', '��祢��', '娬����祢��'}[onkus->USL_TIP] + ')')
          endif
          if onkus->USL_TIP == 5 .and. onksl->ds1_t != 6
            aadd(ta, '��� ��࠭���� ������ ���饭�� ����� ������� "ᨬ�⮬���᪮� ��祭��"')
          elseif onkus->USL_TIP == 6 .and. onksl->ds1_t != 5
            aadd(ta, '��� ��࠭���� ������ ���饭�� ����� ������� ��祭�� "�������⨪�"')
          endif
        endif
        select ONKUS
        skip
      enddo
      if empty(arr_onk_usl)
        //
        // ���������஢�� �६���� 13.02.22 ���� �� ࠧ������
        //
        // if iif(human_2->VMP == 1, .t., between(onksl->ds1_t, 0, 2)) .and. empty(alltrim(human_2->PC3))
        //   aadd(ta, '�� ������� ���������᪮� ��祭��')
        // endif
      elseif eq_ascan(arr_onk_usl, 2, 4)
        if empty(onksl->crit)
          aadd(ta, '�� ������� �奬� ������⢥���� �࠯��')
        else
          // ��ࠢ���� ��室� �� ������ �ࠢ�筨�� Q015 13.01.23
          // if human->vzros_reb  > 0 .or. is_lymphoid(mdiagnoz[1]) // �᫨ ॡ񭮪 ��� ��� �஢�⢮ୠ� ��� ���䮨����
          if human->vzros_reb  > 0 // �᫨ ॡ񭮪
            if alltrim(onksl->crit) == '���'
              // ��� �ࠢ��쭮
            else
              // aadd(ta, '��� ����⮫���� �/��� ��⥩ ����� �奬� ��祭�� ����室��� 㪠�뢠�� "��� �奬� ������⢥���� �࠯��"')
              aadd(ta, '��� ��⥩ ����� �奬� ��祭�� ����室��� 㪠�뢠�� "��� �奬� ������⢥���� �࠯��"')
            endif
          else
            if alltrim(onksl->crit) == '���'
              aadd(ta, '����� 㪠�뢠�� "��� �奬�", ����室��� 㪠�뢠�� �奬�')
            else
              // ��� �ࠢ��쭮
            endif
          endif
        endif
        if empty(onksl->wei)
          aadd(ta, '�� ������� ���� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��')
        elseif !(onksl->wei < 500)
          aadd(ta, '᫨誮� ������ ���� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��')
        endif
        if empty(onksl->hei)
          aadd(ta, '�� ������ ��� ��樥�� ��� ��࠭���� ⨯� ���������᪮�� ��祭��')
        elseif !(onksl->hei < 260)
          aadd(ta, '᫨誮� ����让 ��� ��樥�� ��� ��࠭���� ⨯� ���������᪮�� ��祭��')
        endif
        if empty(onksl->bsa)
          aadd(ta, '�� ������� ���頤� �����孮�� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��')
        elseif !(onksl->bsa < 6)
          aadd(ta, '᫨誮� ������ ���頤� �����孮�� ⥫� ��� ��࠭���� ⨯� ���������᪮�� ��祭��')
        endif
        arr_lek := {}
        fl := .t.
        // fl_zolend := .t.
        Select ONKLE
        find (str(human->kod, 7))
        do while onkle->kod == human->kod .and. !eof()
          if empty(onkle->REGNUM)
            aadd(ta, '�� ������ �����䨪��� ������⢥����� �९��� - ��।������ c��᮪ ������⢥���� �९��⮢')
            fl := .f.
            exit
          else
            // if ascan({'000764', '000895', '000903', '001151', '001652'}, onkle->REGNUM) == 0
            //   fl_zolend := .f.
            // endif
            if empty(onkle->CODE_SH)
              aadd(ta, '�� ������� �奬� ������⢥���� �࠯�� � ������⢠� - ��।������ c��᮪ ������⢥���� �९��⮢')
              fl := .f.
              exit
            else
              if (i := ascan(arr_lek, {|x| x[1] == onkle->REGNUM .and. x[2] == onkle->CODE_SH })) == 0
                aadd(arr_lek, {onkle->REGNUM,onkle->CODE_SH})
              endif
            endif
            if empty(onkle->DATE_INJ)
              aadd(ta, '�� ������� ��� �������� �९��� - ��।������ c��᮪ ������⢥���� �९��⮢')
              fl := .f.
              exit
            elseif !between(onkle->DATE_INJ, d1, d2)
              aadd(ta, '��� �������� �९��� ��室�� �� �ப� ��祭�� - ��।������ c��᮪ ������⢥���� �९��⮢')
              fl := .f.
              exit
            endif
          endif
          Select ONKLE
          skip
        enddo
        if fl
          if empty(arr_lek)
            aadd(ta, '�� �������� c��᮪ ������⢥���� �९��⮢')
          else
            // if fl_zolend
            //   aadd(ta, '� ��⠢� ���� �������� 娬���࠯�� �� ����� ���� �ਬ���� ������ ���� �९��� �� ᯨ᪠ (�����஭���� ��᫮�, �����஭���� ��᫮�, �����஭���� ��᫮�, ����஭���� ��᫮� ��� �����㬠�)')
            // endif
            if select('N20') == 0
              R_Use(exe_dir+ '_mo_N020', cur_dir + '_mo_N020', 'N20')
              set filter to between_date(datebeg, dateend, d2)
            endif
            if select('N21') == 0
              R_Use(exe_dir+ '_mo_N021', cur_dir + '_mo_N021', 'N21')
              set filter to between_date(datebeg, dateend, d2)
            endif
            select N21
            find (onksl->crit)
            if found()
              n := 0
              do while n21->code_sh == onksl->crit .and. !eof()
                if (i := ascan(arr_lek, {|x| x[1] == n21->id_lekp })) > 0
                  ++n
                //elseif onksl->is_err == 0
                  //aadd(ta, '�� �� �ᥬ �९��⠬ ������� ���� - ��।������ c��᮪ ������⢥���� �९��⮢')
                  //fl := .f.
                  //exit
                endif
                select N21
                skip
              enddo
              if n != len(arr_lek)
                aadd(ta, '��।������ c��᮪ ������⢥���� �९��⮢')
              endif
            endif
          endif
        endif
      endif
    endif
  endif
  if is_mgi .and. len(mdiagnoz) > 0 .and. !(left(mdiagnoz[1], 1) == 'C')
    aadd(ta, '��� ���� ���� �� �������୮� ����⨪� �᭮���� ������� ������ ���� C00-C97')
  endif
  mpztip := mpzkol := 0
  if !(round(human->cena_1, 2) == round(ssumma, 2))
    aadd(ta, '�㬬� ���� ' + lstr(human->cena_1) + ' �� ࠢ�� �㬬� ��� ' + lstr(ssumma))
    aadd(ta, '�믮���� ������������������ � ��।������ ��㣨 � ���� ����')
  endif
  if empty(au_lu)
    if empty(au_flu)
      aadd(ta, '�� ������� �� ����� ��㣨')
    else
      aadd(ta, '�� ������� �᭮���� ��㣠, �� ������� ��������� �����ࠢ� ��')
    endif
  endif
  if empty(human_->profil)
    human_->profil := mprofil  // ᭠砫� ��䨫� �� ��ࢮ� ��㣨
  endif
  if empty(human_->profil)
    otd->(dbGoto(human->OTD))
    human_->profil := otd->profil  // �᫨ ���, � �� �⤥�����
  endif
  if !empty(human_->profil) .and. human_->profil != correct_profil(human_->profil)
    human_->profil := correct_profil(human_->profil)
  endif
  if len(mdiagnoz) > 0 .and. left(mdiagnoz[1], 3) == 'O04' .and. eq_any(human_->profil, 136, 137) // �������� � �����������
    if !between(human_2->pn2, 1, 2)
      aadd(ta, '��� �������� ' + alltrim(mdiagnoz[1]) + ' ��易⥫쭮 ���������, �����⢥���� ���뢠��� ��६������ �஢������� �� ����樭᪨� ��������� ��� ���')
    elseif human_2->pn2 == 1 .and. (len(mdiagnoz) < 2 .or. empty(mdiagnoz[2]))
      aadd(ta, '��� �������� ' + alltrim(mdiagnoz[1]) + ' (�����⢥���� ���뢠��� ��६������ �� ����樭᪨� ���������) �� 㪠��� ᮯ������騩 �������')
    endif
  endif
  if empty(human_->VRACH) .and. !(ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34))
    human_->VRACH := mvrach // ��� �� ��ࢮ� ��㣨
  endif
  if ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34)
    mpzkol := len(au_lu)
  endif
  if ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34)
    if !empty(human_2->PN3)
      human->UCH_DOC := lstr(human_2->PN3) // ORDER �� ��� ��१����뢠�� (���� ��ࠢ���)
    endif
    if !is_mgi
      human_->VRACH := 0
    endif
    human_->PRVS := iif(human_->profil == 34, -13, -54)
  elseif human_->profil == 15   // ���⮫����
    human_->PRVS := -13 // ������᪠� ������ୠ� �������⨪�
  elseif empty(human_->VRACH)
    aadd(ta, '�� ��������� ���� "���騩 ���"')
  else
    pers->(dbGoto(human_->VRACH))
    mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
    if empty(mprvs) .and. (! is_disp_DVN_COVID) // ��ࠢ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨
      aadd(ta, '��� ᯥ樠�쭮�� � �ࠢ�筨�� ���ᮭ��� � "' + alltrim(pers->fio) + '"')
    elseif human_->PRVS != mprvs
      human_->PRVS := mprvs
    endif
    if human_->PRVS > 0 .and. ret_V004_V015(human_->PRVS) == 0
      aadd(ta, '�� ������� ᯥ樠�쭮�� � �ࠢ�筨�� � "' + alltrim(pers->fio) + '"')
    endif

    arr_perso := addKodDoctorToArray(arr_perso, human_->VRACH)

  endif
  for i := 1 to len(arr_perso)
    pers->(dbGoto(arr_perso[i]))
    if pers->tab_nom != 0 // �������� ��� 㣫㡫����� ��ᯠ��ਧ�樨
      mvrach := fam_i_o(pers->fio) + ' [' + lstr(pers->tab_nom) + ']'
      if empty(pers->snils)
        aadd(ta, '�� ������ ����� � ��� - ' +mvrach)
      else
        s := space(80)
        if !val_snils(pers->snils, 2, @s)
          aadd(ta, s + ' � ��� - ' +mvrach)
        endif
      endif
    endif
  next
  if empty(human_->USL_OK)
    human_->USL_OK := musl_ok
  elseif mUSL_OK > 0 .and. human_->USL_OK != mUSL_OK
    aadd(ta, '� ���� "�᫮��� ��������" ������ ���� "' + inieditspr(A__MENUVERT, getV006(), mUSL_OK) + '"')
  endif
  if human_->USL_OK == USL_OK_POLYCLINIC // ��� �����������
    s := space(80)
    if !vr_pr_1_den(2, @s,u_other)
      aadd(ta,s)
    endif
  endif
  if human_->USL_OK == USL_OK_HOSPITAL .and. substr(human_->FORMA14, 1, 1) == '0'
    if empty(human_->NPR_MO)
      aadd(ta, '�� �������� ��ᯨ⠫���樨 ������ ���� ��������� ���� "���ࠢ���� ��"')
    elseif empty(human_2->NPR_DATE)
      if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
        human_2->NPR_DATE := d1
      else
        aadd(ta, '������ ���� ��������� ���� "��� ���ࠢ����� �� ��ᯨ⠫�����"')
      endif
    elseif human_2->NPR_DATE > d1
      aadd(ta, '"��� ���ࠢ����� �� ��ᯨ⠫�����" ����� "���� ��砫� ��祭��"')
    elseif human_2->NPR_DATE+60 < d1
      aadd(ta, '���ࠢ����� �� ��ᯨ⠫����� ����� ���� ����楢')
    endif
  endif
  if eq_any(human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL)
    i := human_2->p_per
    if !between(human_2->p_per, 1, 4) // �᫨ �� �������
      i := iif(substr(human_->FORMA14, 2, 1) == '1', 2, 1)
    elseif substr(human_->FORMA14, 2, 1) == '1' // �᫨ ᪮�� ������
      i := 2
    elseif !(substr(human_->FORMA14, 2, 1) == '1') // �᫨ �� ᪮�� ������
      if i == 2 // �᫨ ᪮�� ������
        i := 1
      endif
    endif
    if i != human_2->p_per
      human_2->p_per := i
    endif
  endif
  if kkt == 0 .and. eq_any(human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL) .and. len(a_srok_lech) > 0
    for i := 1 to len(a_srok_lech)
      otd->(dbGoto(a_srok_lech[i, 4]))
      if a_srok_lech[i, 5] == 0
        otd->(dbGoto(a_srok_lech[i, 4]))
        aadd(ta, '����祭�� ' + date_8(a_srok_lech[i, 1]) + '-' + date_8(a_srok_lech[i, 2]) + ;
                iif(empty(otd->short_name), '', ' [' + alltrim(otd->short_name) + ']'))
      endif
    next
  endif
  if fl_stom
    mpzkol := 1
    if f_vid_p_stom(au_lu, ta, , , d2, @ltip, @lkol, @is_2_88, au_flu)
      do case
        case ltip == 1 // � ��祡��� 楫��
          mpztip := 65
          if lkol < 2
            aadd(ta, '�� ���饭�� �� ������ ����������� ������ ���� �� ����� ���� ���饭�� � ����-�⮬�⮫���')
          elseif ascan(au_lu, {|x| alltrim(x[1]) == '2.78.55' }) > 0 .and. ;
                 eq_any(left(human->KOD_DIAG, 3), 'K05', 'K06') .and. lkol < 5
            aadd(ta, '�� ���饭�� �� ������ ����������� ��த��� ������ ���� �� ����� ���� ���饭�� � ����-�⮬�⮫���')
          elseif human->KOD_DIAG == 'Z01.2'
            aadd(ta, '�᭮���� ������� Z01.2 �ਬ������ �� ���饭�� � ��䨫����᪮� 楫�� � �⮬�⮫����, � � ��砥 - �� ������ �����������')
          endif
        case ltip == 2 // � ��䨫����᪮� 楫�� ��� ࠧ���� �� ������ �����������
          mpztip := 63
          if lkol != 1
            aadd(ta, '�� ���饭�� � ��䨫����᪮� 楫�� ������ ���� ���� ���饭�� � ����-�⮬�⮫���')
          elseif is_2_88 .and. human->KOD_DIAG == 'Z01.2'
            aadd(ta, '�� ࠧ���� ���饭�� �� ������ ����������� � �⮬�⮫���� �᭮���� ������� �� ������ ���� Z01.2')
          elseif !is_2_88 .and. !(human->KOD_DIAG == 'Z01.2')
            aadd(ta, '�� ���饭�� � ��䨫����᪮� 楫�� � �⮬�⮫���� �᭮���� ������� �ᥣ�� Z01.2')
          endif
          if !is_2_88
            human_->RSLT_NEW := 314
            human_->ISHOD_NEW := 304
          endif
        case ltip == 3 // �� �������� ���⫮���� �����
          mpztip := 64
          if lkol != 1
            aadd(ta, '�� ���⫮���� ���饭�� ������ ���� ���� ���饭�� � ����-�⮬�⮫���')
          elseif human->KOD_DIAG == 'Z01.2'
            aadd(ta, '�᭮���� ������� Z01.2 �ਬ������ �� ���饭�� � ��䨫����᪮� 楫�� � �⮬�⮫����, � � ��砥 - ���⫮����')
          endif
      endcase
      if ltip > 1 .and. d1 != d2
        aadd(ta,iif(ltip==2,'�� ���饭�� � ��䨫����᪮� 楫��','�� ���⫮���� ���饭��') + ' ��� ����砭�� ������ ࠢ������ ��� ��砫� ��祭��')
      endif
    endif
  endif
  if human_->USL_OK == USL_OK_HOSPITAL  // 1 - ��樮���
    if human_2->VNR > 0 .and. !between(human_2->VNR, 301, 2499)
      aadd(ta, '��� ������襭���� ॡ񭪠 ������ ���� ����� 300 � � ����� 2500 �')
    endif
    for i := 1 to 3
      pole := 'human_2->VNR' + lstr(i)
      if &pole > 0 .and. !between(&pole, 301, 2499)
        aadd(ta, '��� ' + lstr(i) + '-�� ������襭���� ॡ񭪠 ������ ���� ����� 300 � � ����� 2500 �')
      endif
    next
    if kol_ksg > 1
      aadd(ta, '������� ����� ����� ���')
    endif
    mpztip := 52 // 52, '���砩 ��ᯨ⠫���樨', '���.���.'}, ;
    mpzkol := kkd_1_11
    if (i := d2 - d1) == 0
      i := 1
    endif
    if kkd_1_11 != i
      aadd(ta, '������⢮ �����-���� 1.11.* ������ ࠢ������ ' + lstr(i))
    elseif is_reabil // ॠ�������
      mpztip := 53 // 53, '��砩 ��ᯨ⠫���樨 �� ॠ�����樨', '���.ॠ�.'}, ;
      if human_2->VMP == 1 // �᫨ ��⠭����� ���
        aadd(ta, '�� ॠ�����樨 �� ����� ���� ������� ���')
      endif
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '1.11.'
          if !(alltrim(au_lu[i, 1]) == '1.11.2')
            aadd(ta, '����ୠ� ��㣠 ' + au_lu[i, 1])
          endif
          aadd(a_1_11, {au_lu[i, 2], ;
                       au_lu[i, 7], ;
                       au_lu[i, 3], ;
                       au_lu[i, 4], ;
                       au_lu[i, 6]})
        endif
      next
      if len(a_1_11) == 1
        if a_1_11[1, 1] != d1
          aadd(ta, '��� ��砫� ��㣨 1.11.2 ������ ࠢ������ ��� ��砫� ��祭��')
        endif
        if a_1_11[1, 2] != d2
          aadd(ta, '��� ����砭�� ��㣨 1.11.2 ������ ࠢ������ ��� ����砭�� ��祭��')
        endif
      else
        aadd(ta, '��㣠 1.11.2 ������ ��������� ���� ࠧ')
      endif
    else // ��⠫�� �����-���
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '1.11.'
          if !(alltrim(au_lu[i, 1]) == '1.11.1')
            aadd(ta, '����ୠ� ��㣠 ' + au_lu[i, 1])
          endif
          aadd(a_1_11, {au_lu[i, 2], ;
                       au_lu[i, 7], ;
                       au_lu[i, 3], ;
                       au_lu[i, 4], ;
                       au_lu[i, 6]})
        endif
      next
      if len(a_1_11) > 0
        asort(a_1_11, , , {|x,y| x[1] < y[1] })
        if a_1_11[1, 1] != d1
          aadd(ta, '��� ��砫� ��ࢮ� ��㣨 1.11.1 ������ ࠢ������ ��� ��砫� ��祭��')
        endif
        for i := 2 to len(a_1_11)
          if a_1_11[i-1, 2] != a_1_11[i, 1]
            aadd(ta, '��� ��砫� ' + lstr(i) + '-� ��㣨 1.11.1 ������ ࠢ������ ' + date_8(a_1_11[i-1, 2]))
          endif
        next
        if atail(a_1_11)[2] != d2
          aadd(ta, '��� ����砭�� ��᫥���� ��㣨 1.11.1 ������ ࠢ������ ��� ����砭�� ��祭��')
        endif
      endif
    endif
    fl := .t.
    if empty(human_->profil)
      aadd(ta, '� ��砥 �� ���⠢��� ��䨫�')
    elseif empty(human_->PRVS)
      aadd(ta, '� ���饣� ��� � ��砥 �� ���⠢���� ᯥ樠�쭮���')
    elseif is_reabil // ॠ�������
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '1.11.'
          aadd(a_1_11, {alltrim(au_lu[i, 8]), ;
                       au_lu[i, 3], ;
                       au_lu[i, 4]})
        endif
      next
      fl := .f.
      for i := 1 to len(a_1_11)
        if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i, 1] .and. human_->PRVS == a_1_11[i, 3]
          fl := .t. ; exit
        endif
      next
      //if !fl
        //aadd(ta, '� ��㣥 1.11.2 ������ ��������� �������+��� �� ����')
      //endif
    else // ��⠫�� �����-���
      if human_->profil == 158
        aadd(ta, '� ��砥 ����� �ᯮ�짮���� ��䨫� ��: ' + inieditspr(A__MENUVERT, getV002(), 158))
      endif
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '1.11.'
          aadd(a_1_11, {alltrim(au_lu[i, 8]), ;
                       au_lu[i, 3], ;
                       au_lu[i, 4]})
        endif
      next
      for i := 1 to len(au_flu)
        aadd(a_1_11, {alltrim(au_flu[i, 8]), ;
                     au_flu[i, 3], ;
                     au_flu[i, 4]})
      next
      fl := .f.
      for i := 1 to len(a_1_11)
        if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i, 1] .and. ;
                human_->profil == a_1_11[i, 2] .and. human_->PRVS == a_1_11[i, 3]
          if a_1_11[i, 2] == 158
            aadd(ta, '� ��㣥 ����� �ᯮ�짮���� ��䨫� ��: ' + inieditspr(A__MENUVERT, getV002(), 158))
          endif
          fl := .t. ; exit
        endif
      next
      //if !fl
        //aadd(ta, '� ����� �� ��� ������ ��������� �������+��䨫�+��� �� ����')
      //endif
    endif
    ar_1_19_1 := {} ; fl_19 := .f.
    for i := 1 to len(au_lu)
      if left(au_lu[i, 1], 5) == '1.19.'
        if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == alltrim(au_lu[i, 8]) .and. ;
                human_->profil == au_lu[i, 3] .and. human_->PRVS == au_lu[i, 4]
          fl_19 := .t.
        endif
        aadd(ar_1_19_1, au_lu[i, 2])
        if au_lu[i, 6] > 1
          aadd(ta, '� ��㣥 1.19.1 (' + dtoc(au_lu[i, 2]) + ') ������⢮ ����� 1')
        endif
      endif
    next
    if !(fl .or. fl_19)
      aadd(ta, '� ����� �� ��� 1.11.*(1.19.1) ������ ��������� �������+��䨫�+��� �� ����')
    endif
    for j := 1 to len(ar_1_19_1)
      fl := .t.
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '1.11.' .and. eq_any(ar_1_19_1[j], au_lu[i, 2], au_lu[i, 7])
          fl := .f.
          exit
        endif
      next
      if fl
        aadd(ta, '��� ��㣨 1.19.1 (' +dtoc(ar_1_19_1[j]) + ') ��易⥫쭮 ������ ࠢ������ ��� ��砫�/����砭�� ����� �� ��� 1.11.1/1.11.2')
      endif
    next
    if human_2->VMP == 1 // �஢�ਬ ���
      if is_MO_VMP
        // if is_19_VMP .or. is_20_VMP .or. is_21_VMP .or. is_22_VMP .or. is_23_VMP  // ��� ��-������ 08.02.21
        // if is_12_VMP .or. is_21_VMP .or. is_22_VMP .or. is_23_VMP  // ��� ��-������ 08.02.21
        // if is_12_VMP  // ��� ��-������
        if !empty(ar_1_19_1)
          aadd(ta, '�� �������� ��� �� ����� ���� �ਬ����� ��㣠 1.19.1')
        endif
        if empty(human_2->TAL_NUM)
          aadd(ta, '��� �������, �� �� ������ ����� ⠫��� �� ���')
        elseif (human->k_data > 0d20220101) .and. !empty(human_2->TAL_NUM) .and. !valid_number_talon(human_2->TAL_NUM, human->k_data, .f.)
          aadd(ta, '��� �������, �� �ଠ� ����� ⠫��� �� ��� �� ��७ (蠡��� 99.9999.99999.999)')
        endif
        if empty(human_2->TAL_D)
          aadd(ta, '��� �������, �� �� ������� ��� �뤠� ⠫��� �� ���')
        elseif !eq_any(year(human_2->TAL_D), d2_year-1, d2_year, d2_year+1)
          aadd(ta, '��� �뤠� ⠫��� �� ��� (' + date_8(human_2->TAL_D) + ') ������ ���� � ⥪�饬 ��� ��諮� ����')
        endif
        if empty(human_2->TAL_P)
          aadd(ta, '��� �������, �� �� ������� ��� ������㥬�� ��ᯨ⠫���樨 � ᮮ⢥��⢨� � ⠫���� �� ���')
        elseif !eq_any(year(human_2->TAL_P), d2_year-1, d2_year, d2_year+1)
          aadd(ta, '��� ������㥬�� ��ᯨ⠫���樨 � ᮮ⢥��⢨� � ⠫���� �� ��� (' + date_8(human_2->TAL_P) + ') ������ ���� � ⥪�饬 ��� ��諮� ����')
        endif
        if empty(human_2->VIDVMP)
          aadd(ta, '��� �������, �� �� ����� ��� ���')
        elseif ascan(arrV018, {|x| x[1] == alltrim(human_2->VIDVMP) }) == 0
          aadd(ta, '�� ������ ��� ��� "' + human_2->VIDVMP + '" � �ࠢ�筨�� V018')
        elseif empty(human_2->METVMP)
          aadd(ta, '��� �������, ����� ��� ���, �� �� ����� ��⮤ ���')
        elseif ((i := ascan(arrV019, {|x| x[1] == human_2->METVMP})) > 0) .and. (year(human->k_data)==2020)
          if arrV019[i, 4] == alltrim(human_2->VIDVMP)
            if !(len(mdiagnoz) == 0 .or. empty(mdiagnoz[1]))
              fl := .f. ; s := padr(mdiagnoz[1], 6)
              for j := 1 to len(arrV019[i, 3])
                if left(s, len(arrV019[i, 3, j])) == arrV019[i, 3, j]
                  fl := .t. ; exit
                endif
              next
              if fl
                if empty(mpztip := ret_PZ_VMP(human_2->METVMP, human->k_data))
                  mpztip := 1
                endif
              else
                aadd(ta, '�᭮���� ������� ' + s + ', � � ��⮤� ��� "' + lstr(human_2->METVMP) + '.' + alltrim(arrV019[i, 2]) + '"')
                aadd(ta, '�Ĥ����⨬� ��������: ' + print_array(arrV019[i, 3]))
              endif
            endif
          else
            aadd(ta, '��⮤ ��� ' + lstr(human_2->METVMP) + ' �� ᮮ⢥����� ���� ��� ' +human_2->VIDVMP)
          endif
        // elseif ((i := ascan(arrV019, {|x| x[1] == human_2->METVMP .and. x[8] == human_2->PN5 })) > 0) .and. (year(human->k_data)>=2021)
        elseif ((i := ascan(arrV019, {|x| x[1] == human_2->METVMP .and. x[8] == human_2->PN5 .and. x[4] == alltrim(human_2->VIDVMP) })) > 0) .and. (year(human->k_data)>=2021)
          if (arrV019[i, 4] == alltrim(human_2->VIDVMP)) //.or. (arrV019[i, 4] == '26' .and. alltrim(human_2->VIDVMP) == '27')

            if !(len(mdiagnoz) == 0 .or. empty(mdiagnoz[1]))
              fl := .f. ; s := padr(mdiagnoz[1], 6)
              for j := 1 to len(arrV019[i, 3])
                if left(s,len(arrV019[i, 3, j])) == arrV019[i, 3, j]
                  fl := .t. ; exit
                endif
              next
              if fl
                if empty(mpztip := ret_PZ_VMP(human_2->METVMP, human->k_data))
                  mpztip := 1
                endif
              else
                aadd(ta, '�᭮���� ������� ' + s + ', � � ��⮤� ��� "' + lstr(human_2->METVMP) + '.' + alltrim(arrV019[i, 2]) + '"')
                aadd(ta, '�Ĥ����⨬� ��������: ' + print_array(arrV019[i, 3]))
              endif
            endif
          else
            aadd(ta, '��⮤ ��� ' + lstr(human_2->METVMP) + ' �� ᮮ⢥����� ���� ��� ' +human_2->VIDVMP)
          endif
        else
          aadd(ta, '�� ������ ��⮤ ��� ' + lstr(human_2->METVMP) + ' � �ࠢ�筨�� V019')
        endif
      else
        human_2->VMP     := 0
        human_2->VIDVMP  := ''
        human_2->METVMP  := 0
        human_2->TAL_NUM := ''
        human_2->TAL_D   := ctod('')
        human_2->TAL_P   := ctod('')
      endif
    endif
    // ������� ��ਮ�, �᫨ ��稫�� � ��樮���
    aadd(a_period_stac, {human->n_data, ;
                        human->k_data, ;
                        human_->USL_OK, ;
                        human->OTD, ;
                        human->kod_diag, ;
                        human_->profil, ;
                        human_->RSLT_NEW, ;
                        human_->ISHOD_NEW, ;
                        iif(is_s_dializ, 1, 0)})
  elseif human_->USL_OK == USL_OK_DAY_HOSPITAL .and. kol_ksg > 0 // ������� ��樮���
    if kol_ksg > 1
      aadd(ta, '������� ����� ����� ���')
    endif
    mpztip := 55 // 55, '��砩 ��祭��', '���.��祭'}, ;
    mpzkol := kol_55_1
    if empty(kol_55_1)
      aadd(ta, '�� ������� ��㣠 ��樥��-���� 55.1.*')
    elseif is_reabil // ॠ�������
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '55.1.'
          if !(alltrim(au_lu[i, 1]) == '55.1.4')
            aadd(ta, '����ୠ� ��㣠 ' + rtrim(au_lu[i, 1]) + ', ������ ���� 55.1.4')
          endif
          aadd(a_1_11, {au_lu[i, 2], ;  // 1-mdate
                       au_lu[i, 7], ;  // 2-c4tod(mdate_u2)
                       au_lu[i, 3], ;  // 3-hu_->profil
                       au_lu[i, 4], ;  // 4-hu_->PRVS
                       au_lu[i, 6], ;  // 5-hu->kol_1
                       au_lu[i, 9]})  // 6-����� �����
        endif
      next
      if len(a_1_11) == 1
        if a_1_11[1, 1] != d1
          aadd(ta, '��� ��砫� ��㣨 55.1.4 ������ ࠢ������ ��� ��砫� ��祭��')
        endif
        if a_1_11[1, 2] != d2
          select HU
          goto (a_1_11[1, 6])
          hu_->(my_Rec_Lock(a_1_11[1, 6]))
          hu_->date_u2 := cd2
        endif
      else
        aadd(ta, '��㣠 55.1.4 ������ ��������� ���� ࠧ')
      endif
    else // ��⠫�� �����-���
      a_1_11 := {}
      s := ''
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '55.1.'
          if empty(s)
            s := au_lu[i, 1]
          endif
          if !(au_lu[i, 1] == s) // �� ᬥ訢��� ࠧ�� 55.1.*
            aadd(ta, '����ୠ� ��㣠 ' + au_lu[i, 1])
          elseif !eq_any(alltrim(au_lu[i, 1]), '55.1.1', '55.1.2', '55.1.3')
            aadd(ta, '����ୠ� ��㣠 ' + rtrim(au_lu[i, 1]))
          endif
          aadd(a_1_11, {au_lu[i, 2], ;   // 1-mdate
                       au_lu[i, 7], ;   // 2-c4tod(mdate_u2)
                       au_lu[i, 3], ;   // 3-hu_->profil
                       au_lu[i, 4], ;   // 4-hu_->PRVS
                       au_lu[i, 6], ;   // 5-hu->kol_1
                       au_lu[i, 9]})   // 6-����� �����
        endif
      next
      if (k := len(a_1_11)) > 0
        asort(a_1_11, , , {|x,y| x[1] < y[1] })
        if a_1_11[1, 1] != d1
          aadd(ta, '��� ��砫� ��ࢮ� ��㣨 55.1.* ������ ࠢ������ ��� ��砫� ��祭��')
        endif
        for i := 2 to k
          // 1-��� ����砭�� �।.��㣨 = ��� ��砫� ᫥�.��㣨 ����� 1
          a_1_11[i-1, 2] := a_1_11[i, 1] - 1
          // 2-��� ����砭�� �।.��㣨 = ��� ��砫� �।.��㣨 + ��� - 1
          d := a_1_11[i-1, 1] + a_1_11[i-1, 5] - 1
          if d > a_1_11[i-1, 2]
            aadd(ta, '��� ��砫� ' + lstr(i) + '-� ��㣨 55.1.* ������ ࠢ������ ' + date_8(d+1))
          endif
        next
        if empty(ta) // ��� �訡��
          for i := 1 to k
            select HU
            goto (a_1_11[i, 6])
            hu_->(my_Rec_Lock(a_1_11[i, 6]))
            if i == k
              a_1_11[i, 2] := d2   // ��� ��᫥���� ��㣨
              hu_->date_u2 := cd2 // ���⠢�� ���� ����砭�� ��祭��
              d := a_1_11[i, 1] + a_1_11[i, 5] - 1
              if d > d2
                aadd(ta, '��� ����砭�� ��᫥���� ��㣨 55.1.* ����� ���� ����砭�� ��祭�� ' + date_8(d))
              endif
            else
              hu_->date_u2 := dtoc4(a_1_11[i, 2]) // ��९�襬 ���� ����砭��
            endif
          next
        endif
      endif
    endif
    if empty(human_->profil)
      aadd(ta, '� ��砥 �� ���⠢��� ��䨫�')
    elseif empty(human_->PRVS)
      aadd(ta, '� ���饣� ��� � ��砥 �� ���⠢���� ᯥ樠�쭮���')
    elseif is_reabil // ॠ�������
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '55.1.'
          aadd(a_1_11, {alltrim(au_lu[i, 8]), ;
                       au_lu[i, 3], ;
                       au_lu[i, 4]})
        endif
      next
      fl := .f.
      for i := 1 to len(a_1_11)
        if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i, 1] .and. human_->PRVS == a_1_11[i, 3]
          fl := .t. ; exit
        endif
      next
      if !fl
        aadd(ta, '� ��㣥 55.1.4 ������ ��������� �������+��� �� ����')
      endif
    else // ��⠫�� �����-���
      a_1_11 := {}
      for i := 1 to len(au_lu)
        if left(au_lu[i, 1], 5) == '55.1.'
          aadd(a_1_11, {alltrim(au_lu[i, 8]), ;
                       au_lu[i, 3], ;
                       au_lu[i, 4]})
        endif
      next
      for i := 1 to len(au_flu)
        aadd(a_1_11, {alltrim(au_flu[i, 8]), ;
                     au_flu[i, 3], ;
                     au_flu[i, 4]})
      next
      fl := .f.
      for i := 1 to len(a_1_11)
        if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i, 1] .and. ;
                human_->profil == a_1_11[i, 2] .and. human_->PRVS == a_1_11[i, 3]
          fl := .t. ; exit
        endif
      next
      if !fl
        aadd(ta, '� ����� �� ��� 55.1.* ������ ��������� �������+��䨫�+��� �� ����')
      endif
    endif
    if !empty(lvidpoms)
      if ascan(au_lu, {|x| alltrim(x[1]) == '55.1.2'}) > 0 .or. ;
         ascan(au_lu, {|x| alltrim(x[1]) == '55.1.3'}) > 0
         //
         //
        if ascan(au_lu, {|x| alltrim(x[1]) == '55.1.3'}) > 0
          lvidpoms := ret_vidpom_st_dom_licensia(human_->USL_OK, lvidpoms, lprofil)
        endif
      else // ⮫쪮 ��� ��.��樮��� �� ��樮��� ᬮ�ਬ ��業���
        lvidpoms := ret_vidpom_licensia(human_->USL_OK, lvidpoms)
      endif
      if ',' $ lvidpoms
        if ascan(au_lu, {|x| alltrim(x[1]) == '55.1.1'}) > 0 .or. ;
           ascan(au_lu, {|x| alltrim(x[1]) == '55.1.4'}) > 0 .or. ;
           ascan(au_lu, {|x| alltrim(x[1]) == '55.1.6'}) > 0
          if !('31' $ lvidpoms)
            aadd(ta, '��� ���=' + shifr_ksg+ ' � �ࠢ�筨�� �006 �� ����� ��� ����� 31')
          endif
        else
          if eq_any(human_->PROFIL, 57, 68, 97) //�࠯��,�������,��� ���.�ࠪ⨪�
            if !('12' $ lvidpoms)
              aadd(ta, '��� ���=' + shifr_ksg+ ' � �ࠢ�筨�� �006 �� ����� ��� ����� 12; ' + ;
                      '����⭮, � ��砥 �� ����� ����� ��䨫� "�࠯���", "�������", "��� ���.�ࠪ⨪�"')
            endif
          else
            if !('13' $ lvidpoms)
              aadd(ta, '��� ���=' + shifr_ksg+ ' � �ࠢ�筨�� �006 �� ����� ��� ����� 13; ' + ;
                      '���⠢�� � ��砥 ��䨫� "�࠯���", "�������", "��� ���.�ࠪ⨪�" ' + ;
                      '��� ������ � ����� �� �訡�� � �ࠢ�筨��')
            endif
          endif
        endif
      endif
    endif
  endif
  if len(a_period_stac) > 0 //.and. !is_s_dializ .and. !is_dializ .and. !is_perito
    select HU
    find (str(human->kod, 7))
    do while hu->kod == human->kod .and. !eof()
      aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil, 0, human->n_data, human->k_data, human->OTD})
      select HU
      skip
    enddo
    select HU
    set relation to
    for i := 1 to len(u_other)
      if u_other[i, 5] == 0
        usl->(dbGoto(u_other[i, 1]))
        lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
        if is_usluga_TFOMS(usl->shifr, lshifr1,u_other[i, 7])
          mdate := c4tod(u_other[i, 2])
          if (k := ascan(a_period_stac, {|x| x[1] < mdate .and. mdate < x[2]})) > 0
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            if (left(lshifr, 2)=='2.' .or. eq_any(left(lshifr, 3), '60.', '70.', '71.', '72.')) ;
                            .and. !(left(lshifr, 5)=='60.3.') ;
                            .and. !(left(lshifr, 6)=='60.10.') ;
                            .and. is_2_stomat(lshifr, , .t.) == 0 // �� �⮬�⮫����
              otd->(dbGoto(u_other[i, 8]))
              aadd(ta, '��㣠 ' + alltrim(usl->shifr) + ' �� ' + date_8(mdate) + ' � ��砥 ' + ;
                   date_8(u_other[i, 6]) + '-' + date_8(u_other[i, 7]) + ;
                   iif(empty(otd->short_name), '', ' [' + alltrim(otd->short_name) + ']'))
              otd->(dbGoto(a_period_stac[k, 4]))
              aadd(ta, '�>���ᥪ����� 222 � ��砥� ���.��祭�� ' + ;
                   date_8(a_period_stac[k, 1]) + '-' + date_8(a_period_stac[k, 2]) + ;
                   iif(empty(otd->short_name), '', ' [' + alltrim(otd->short_name) + ']'))
            endif
          endif
        endif
      endif
    next i
    select HU
    set relation to recno() into HU_, to u_kod into USL
  endif
  if eq_any(human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL) .and. kol_ksg > 0 .and. human_2->VMP == 0 // �� ���
    k_data2 := human->k_data
    if human->ishod == 88
      s := '�� ������� ��砩 - �� ����稢����� ' + date_8(k_data2) + '; '
      select HUMAN
      goto (human_2->pn4) // ��뫪� �� 2-� ���� ����
      k_data2 := human->k_data // ��९�ᢠ����� ���� ����砭�� ��祭��
      goto (rec_human)
      lDoubleSluch := .t.
    else
      s := ''
    endif
    arr_ksg := definition_KSG(1, k_data2, lDoubleSluch)
    if empty(arr_ksg[2]) // ��� �訡��
      if shifr_ksg == arr_ksg[3] // ��� ��।����� �ࠢ��쭮
        if !(round(cena_ksg, 2) == round(arr_ksg[4], 2)) // �� � 業�
          aadd(ta, s + '� �/� ��� ���=' + arr_ksg[3] + ' �⮨� 業� ' + lstr(cena_ksg, 10, 2) + ', � ������ ���� ' + lstr(arr_ksg[4], 10, 2))
        else
          put_str_kslp_kiro(arr_ksg,.f.)
        endif
      else // �� �� ��� ���
        aadd(ta, s + '� �/� �⮨� ���=' + alltrim(shifr_ksg) + '(' + lstr(cena_ksg, 10, 2) + '), � ������ ���� ' + arr_ksg[3] + '(' + lstr(arr_ksg[4], 10, 2) + ')')
      endif
    else
      aeval(arr_ksg[2], {|x| aadd(ta, s +x) })
    endif
  endif
  // �஢�ਬ ��ਮ�, �᫨ ��稫�� ���㫠�୮
  if human_->USL_OK == USL_OK_POLYCLINIC .and. human->ishod < 101 ;// �� ��ᯠ��ਧ���
                          .and. m1novor == human_->NOVOR ;
                           .and. !(is_2_80 .or. is_2_82) ;// �� ���⫮���� ������
                            .and. !(ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34)) ; // �� ���2
                             .and. kkt == 0 ; // �� �⤥�쭮 ����� ���.��楤��
                              .and. len(a_period_amb) > 0
    for i := 1 to len(a_period_amb)
      if a_period_amb[i, 3] == human_->profil
        aadd(ta, '����� ��砩 ���ᥪ����� � ��砥� ���㫠�୮�� ��祭��')
        otd->(dbGoto(a_period_amb[i, 4]))
        aadd(ta, '�>� ⥬ �� ��䨫�� ' + ;
                date_8(a_period_amb[i, 1]) + '-' + date_8(a_period_amb[i, 2]) + ;
                iif(empty(otd->short_name), '', ' [' + alltrim(otd->short_name) + ']'))
        //aadd(ta, '�>����� �/� - ������ � ' + lstr(human->(recno())) + ', ���� �/� - ������ � ' + lstr(a_period_amb[i, 5]))
      endif
    next
  endif
  if mRSLT_NEW > 0
    human_->RSLT_NEW := mRSLT_NEW // ������� ���.��ᯠ��ਧ���
  endif
  //
  if is_2_78
    mIDSP := 17 // �����祭�� ��砩 � �����������
    if kvp_2_78 > 1
      aadd(ta, '� ��砥 �ਬ����� ' + lstr(kvp_2_78) + ' ��㣨 "2.78.*" (������ ���� ����)')
    endif
  endif
  if is_disp_DDS // is_70_5 .or. is_70_6
    mIDSP := 11 // ��ᯠ��ਧ���
    if kvp_70_5 > 1
      aadd(ta, '� ��砥 �ਬ����� ' + lstr(kvp_70_5) + ' ��㣨 "70.5.*" (������ ���� ����)')
    endif
    if kvp_70_6 > 1
      aadd(ta, '� ��砥 �ਬ����� ' + lstr(kvp_70_6) + ' ��㣨 "70.6.*" (������ ���� ����)')
    endif
  endif
  if is_disp_DVN // is_70_3
    mIDSP := 11 // ��ᯠ��ਧ���
    if is_disp_DVN3 // ��䨫��⨪�
      mIDSP := 17 // �����祭�� ��砩 � �����������
    endif
    if kvp_70_3 > 1
      aadd(ta, '� ��砥 �ਬ����� ' + lstr(kvp_70_3) + ' ��� "���.�." (������ ���� ����)')
    endif
  endif
  if is_prof_PN // is_72_2
    if is_72_2
      a_idsp := {{30, '�� �����祭�� ��砩 � �����������'}}
    else
      a_idsp := {{29, '�� ���饭�� � �����������'}}
    endif
    if kvp_72_2 > 1
      aadd(ta, '� ��砥 �ਬ����� ' + lstr(kvp_72_2) + ' ��㣨 "72.2.*" (������ ���� ����)')
    endif
  endif
  if (k := len(a_idsp)) == 0 .and. is_dializ
    if empty(kodKSG)
      a_idsp := {{28, '�� ����樭��� ����'}}
    else // ���
      a_idsp := {{33, '�� �����祭�� ��砩'}}
    endif
    k := 1
  endif
  if lTypeLUOnkoDisp
    a_idsp := {{29, '�� ���饭�� � �����������'}}
    k := 1
  endif
  if k == 0
    aadd(ta, '�� � ����� �� ��� � �ࠢ�筨�� ����� �� ��⠭����� ᯮᮡ ������')
  elseif k == 1
    midsp := human_->IDSP := a_idsp[1, 1]
  else
    asort(a_idsp, , , {|x, y| x[1] < y[1] })
    if len(a_idsp) == 2 .and. a_idsp[1, 1] == 28 .and. a_idsp[2, 1] == 33 .and. is_dializ
      Del_Array(a_idsp, 1) // 㤠���� 1-� ����� ���ᨢ�
      midsp := human_->IDSP := a_idsp[1, 1]
    else
      aadd(ta, 'ᬥ訢���� ᯮᮡ�� ������: ' + ;
              lstr(a_idsp[1, 1]) + '-' + alltrim(a_idsp[1, 2]) + ' � ' + ;
              lstr(a_idsp[2, 1]) + '-' + alltrim(a_idsp[2, 2]))
    endif
  endif
  if (k := len(a_bukva)) == 0
    aadd(ta, '�� � ����� �� ��� � �ࠢ�筨�� T002 �� ��⠭������ �㪢� ����')
  elseif k == 1
    //
  else
    aadd(ta, 'ᬥ訢���� �㪢 ����: ' + ;
            a_bukva[1, 1] + '-' + alltrim(a_bukva[1, 2]) + ' � ' + ;
            a_bukva[2, 1] + '-' + alltrim(a_bukva[2, 2]))
  endif
  if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_disp_DVN_COVID
    //
  elseif len(mdiagnoz) > 0 .and. ascan(adiag, mdiagnoz[1]) == 0
    aadd(ta, '�᭮���� ������� ' + rtrim(mdiagnoz[1]) + ' �� ����砥��� �� � ����� ��㣥')
  endif
  //
  if empty(human_->USL_OK)
    aadd(ta, '�� ��������� ���� "�᫮��� ��������"')
  endif
  if empty(human_->PROFIL)
    aadd(ta, '�� ��������� ���� "��䨫�"')
  elseif eq_any(human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL)
    if empty(human_2->profil_k)
      aadd(ta, '� ��砥 �� ���⠢��� ��䨫� �����')
    else
      if select('PRPRK') == 0
        R_Use(dir_exe + '_mo_prprk', cur_dir + '_mo_prprk', 'PRPRK')
        //index on str(profil, 3) + str(profil_k, 3) to (cur_dir+ sbase)
      endif
      select PRPRK
      find (str(human_->profil, 3) + str(human_2->profil_k, 3))
      if found()
        if !empty(prprk->vozr)
          if human->vzros_reb == 0
            if prprk->vozr == '�'
              aadd(ta, '������ ��樥�� �� ᮮ⢥����� ��䨫� �����')
            endif
          else
            if prprk->vozr == '�'
              aadd(ta, '������ ��樥�� �� ᮮ⢥����� ��䨫� �����')
            endif
          endif
        endif
        if !empty(prprk->pol) .and. !(human->pol == prprk->pol)
          aadd(ta, '���祭�� ���� "���" �� ᮮ⢥����� ��䨫� �����')
        endif
      else
        s := ''
        select PRPRK
        find (str(human_->profil, 3))
        do while prprk->profil == human_->profil .and. !eof()
          s += '"' +inieditspr(A__MENUVERT, getV020(), prprk->profil_k) + '" '
          skip
        enddo
        if empty(s)
          aadd(ta, '��䨫� ����樭᪮� ����� �� ����稢����� � ���')
        else
          aadd(ta, '��䨫� ���.����� �� ᮮ⢥����� ��䨫� �����; �����⨬� ��䨫� �����: ' + s)
        endif
      endif
    endif
  endif
  if empty(human_->IDSP)
    aadd(ta, '�� ��������� ���� "���ᮡ ������"')
  endif
  if empty(human_->RSLT_NEW)
    aadd(ta, '�� ��������� ���� "������� ���饭��"')
  elseif int(val(left(lstr(human_->RSLT_NEW), 1))) != human_->USL_OK
    aadd(ta, '� ���� "������� ���饭��" �⮨� ����୮� ���祭��')
  endif
  if empty(human_->ISHOD_NEW)
    aadd(ta, '�� ��������� ���� "��室 �����������"')
  elseif int(val(left(lstr(human_->ISHOD_NEW), 1))) != human_->USL_OK
    aadd(ta, '� ���� "��室 �����������" �⮨� ����୮� ���祭��')
  endif
  if is_2_82
    if human_->profil == 134
      aadd(ta, '� ��砥 �� ������ ���� ��䨫� "��񬭮�� �⤥�����"')
    endif
  endif
  if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_pren_diagn .or. kol_ksg > 0 ;
                                                  .or. is_2_89 .or. is_reabil ;
                                                  .or. is_disp_DVN_COVID  //.or. is_s_dializ
    if is_reabil  // �஢���� �஢��� �� ��䨫� �� ॠ�����樨
      if human_->profil != 158
        aadd(ta, '� ��砥 ���� �ᯮ�짮���� ��䨫� ��: ' + inieditspr(A__MENUVERT, getV002(), 158))
      endif

      for i := 1 to len(au_lu)
        if au_lu[i, 3] == 158 .and. alltrim(au_lu[i, 1]) != shifr_ksg
          aadd(ta, '����� � ��㣥 ' + alltrim(au_lu[i, 1]) + ' �ᯮ�짮���� ��䨫� ��: ' + inieditspr(A__MENUVERT, getV002(), au_lu[i, 3]))
        endif
      next

      if is_reabil_slux
        t_arr := {'1331.0', '1332.0', '1333.0', '1335.0', '2127.0', '2128.0', '2130.0'}
        for i := 1 to len(t_arr)
          if t_arr[i] == shifr_ksg .and. !between(human_2->PN1, 1, 3)
            human_2->PN1 := 1
            //aadd(ta, '� ��砥 ॠ�����樨 ��� ���=' + shifr_ksg+ ' ����室��� ��������� ���� '��� ���.ॠ�����樨'')
          endif
        next
      endif
    endif
  else
    if human_->profil == 158
      aadd(ta, '� ��砥 ����� �ᯮ�짮���� ��䨫� ��: ' + inieditspr(A__MENUVERT, getV002(), 158))
    endif
    arr_profil := {human_->profil}
    for i := 1 to len(au_lu)
      if au_lu[i, 10] >= 0 .and. ascan(arr_profil, au_lu[i, 3]) == 0
        aadd(arr_profil, au_lu[i, 3])
      endif
    next
    for i := 1 to len(au_flu)
      if ascan(arr_profil, au_flu[i, 3]) == 0
        aadd(arr_profil, au_flu[i, 3])
      endif
    next
    if len(arr_profil) > 1
      if human_->USL_OK == USL_OK_AMBULANCE // 4 - �᫨ ᪮�� ������
        human_->profil := au_lu[1, 3]
      else
        aadd(ta, '� ��砥 �ᯮ�짮��� ��䨫� ��: ' + inieditspr(A__MENUVERT, getV002(), arr_profil[1]))
        for i := 2 to len(arr_profil)
          aadd(ta, '                  � � ��㣥 ��: ' + inieditspr(A__MENUVERT, getV002(), arr_profil[i]))
        next
      endif
    elseif empty(arr_profil[1])
      aadd(ta, '� ��砥 �� ���⠢��� ��䨫�')
    endif
    //
    if ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34)
      // �� �஢�����
    else
      arr_prvs := {human_->PRVS}
      for i := 1 to len(au_lu)
        if au_lu[i, 10] >= 0 .and. ascan(arr_prvs, au_lu[i, 4]) == 0
          aadd(arr_prvs, au_lu[i, 4])
        endif
      next
      for i := 1 to len(au_flu)
        if ascan(arr_prvs, au_flu[i, 4]) == 0
          aadd(arr_prvs, au_flu[i, 4])
        endif
      next
      if len(arr_prvs) > 1 .and. !is_gisto
        aadd(ta, '� ��砥 �ᯮ�짮���� ࠧ�� ᯥ樠�쭮�� ��祩')
      endif
    endif
  endif
  if lstkol > 0
    lstshifr += '*'
    if lstkol > 1
      aadd(ta, '���-�� ��� ' + lstshifr + ' (' + lstr(lstkol) + ') ����� 1')
    endif
    if len(au_lu) > 1 .and. kol_ksg == 0
      if is_2_78 .or. is_2_89 .or. is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2 .or. is_2_92_
        //
      else
        aadd(ta, '�஬� ��㣨 ' + lstshifr + ' � ���� ��� �� ������ ���� ��㣨� ��� �����')
      endif
    endif
    if is_2_92_
      if alltrim_lshifr == '2.92.3' .and. vozrast >= 18
        aadd(ta, '��㣠 2.92.3 ����뢠���� ⮫쪮 ���� ��� �����⪠�')
      elseif eq_any(alltrim_lshifr, '2.92.1', '2.92.2') .and. vozrast < 18
        aadd(ta, '��㣠 ' + alltrim_lshifr + ' ����뢠���� ⮫쪮 �����')
      endif

      if !eq_any(human_->RSLT_NEW, 314)
        aadd(ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"')
      endif
      if !eq_any(human_->ISHOD_NEW, 304)
        aadd(ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"')
      endif
  
      s := '��㣠 2.93.1 ����뢠���� �� ����� '
      if vozrast < 18 .and. kol_2_93_1 < 10
        aadd(ta, s + ' 10 ࠧ')
      elseif vozrast >= 18 .and. kol_2_93_1 < 5
        aadd(ta, s + ' 5 ࠧ')
      endif
      if vozrast < 18 .and. kol_dney < 10
        aadd(ta, s + ' 10 ����')
      elseif vozrast >= 18 .and. kol_dney < 5
        aadd(ta, s + ' 5 ����')
      endif

    endif
  endif
  s := '2.60.*'
  if is_2_78
    is_1_den := is_last_den := .f.
    zs := oth_usl := 0
    am := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i, 1], 5) == '2.78.'
        ++zs
      elseif left(au_lu[i, 1], 4) == '2.60'
        if d1 == au_lu[i, 2]
          is_1_den := .t.
        endif
        if d2 == au_lu[i, 2]
          is_last_den := .t.
        endif
        if (j := ascan(am, {|x| x[1] == month(au_lu[i, 2])} )) == 0
          aadd(am, {month(au_lu[i, 2]), 0}) ; j := len(am)
        endif
        am[j, 2] ++
      elseif au_lu[i, 10] >= 0 .and. !(alltrim(au_lu[i, 1]) == '4.27.2')
        ++ oth_usl
      endif
    next
    j := len(am)
    if !is_last_den .and. j > 0
      asort(am, , , {|x,y| x[1] < y[1]})
      if month(d2) - am[j, 1] > 1 .and. year(d1) == year(d2)
        aadd(ta, '� �।��饬 ����� �� ������� ��祡��� ��񬮢')
      endif
    endif
    if zs > 1
      aadd(ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"')
    endif
    if oth_usl > 0
      aadd(ta, '�஬� ��㣨 ' + lstshifr + ' � ' + s + ' � ���� ��� �� ������ ���� ��㣨� ���')
    endif
    if kol_2_60 == 0
      aadd(ta, '�� ������� �� ����� ��㣨 ' + s)
    else
      if !is_1_den
        aadd(ta, '��ࢠ� ��㣠 ' + s + ' ������ ���� ������� � ���� ���� ��祭��')
      elseif human_->RSLT_NEW != 302
        if kol_2_60 < 2
          aadd(ta, '�஬� ��㣨 ' + lstshifr + ' � ���� ��� ������ ���� �� ����� ���� ��� ' + s)
        endif
        if !is_last_den
          aadd(ta, '��᫥���� ��㣠 ' + s + ' ������ ���� ������� � ��᫥���� ���� ��祭��')
        endif
      endif
    endif
  elseif kvp_2_79 > 1
    s := '2.79.*'
    aadd(ta, '��㣠 ' + s + ' ������ ���� �����⢥���� � ��砥')
  elseif is_2_89 // ����樭᪠� ॠ������� (䨧������� ��ᯠ��� � ��㣨�)
    if d1 == d2
      aadd(ta, '�६� ��祭�� �� ������ ࠢ������ ������ ���')
    endif
    if empty(human_->NPR_MO)
      aadd(ta, '�� ��������� "���ࠢ���� ��", � ���ன ��樥�� ���� �ਪ९�����')
    else
      if empty(human_2->NPR_DATE)
        aadd(ta, '������ ���� ��������� ���� "��� ���ࠢ����� �� ��祭��"')
      elseif human_2->NPR_DATE > d1
        aadd(ta, '"��� ���ࠢ����� �� ��祭��" ����� "���� ��砫� ��祭��"')
      elseif human_2->NPR_DATE + 60 < d1
        aadd(ta, '���ࠢ����� �� ��祭�� ����� ���� ����楢')
      endif
      if !(eq_any(glob_mo[_MO_KOD_TFOMS], '103001', '104401') .or. ret_mo(human_->NPR_MO)[_MO_IS_UCH])
        aadd(ta, '������� "���ࠢ���� ��", ����� �� ����� �ࠢ� �ਪ९���� ��樥�⮢')
      endif
    endif
    aps := {} // ��⠭�� ��䨫� � ᯥ樠�쭮��
    human_->profil := 158  // ����樭᪮� ॠ�����樨
    is_1_den := is_last_den := .f.
    zs := km := oth_usl := 0
    s := ''
    shifr_zs := ''
    for i := 1 to len(au_lu)
      if left(au_lu[i, 1], 5) == '2.89.'
        shifr_zs := au_lu[i, 1]
        exit
      endif
    next
    for i := 1 to len(au_lu)
      alltrim_lshifr := alltrim(au_lu[i, 1])
      left_lshifr_2 := left(au_lu[i, 1], 2)
      left_lshifr_3 := left(au_lu[i, 1], 3)
      left_lshifr_4 := left(au_lu[i, 1], 4)
      left_lshifr_5 := left(au_lu[i, 1], 5)
      if !between(au_lu[i, 2], d1, d2)
        aadd(ta, '��� ��㣨 ' + alltrim_lshifr + ' ��� ��������� ��祭�� (' + date_8(au_lu[i, 2]) + ')')
      endif
      if len(mdiagnoz) > 0 .and. !(alltrim(mdiagnoz[1]) == alltrim(au_lu[i, 8]))
        aadd(ta, '� ��㣥 ' + alltrim_lshifr + ' ������ ����� �᭮���� �������')
      endif
      if left_lshifr_5 == '2.89.'
        zs += au_lu[i, 6]
      elseif left_lshifr_4 == '2.6.'  // .and. (! lTypeLUMedReab)
        if d1 == au_lu[i, 2]
          is_1_den := .t.
        elseif d2 == au_lu[i, 2]
          is_last_den := .t.
        endif
        if au_lu[i, 6] != 1
          aadd(ta, '� ��㣥 ' + alltrim_lshifr + ' ������⢮ �� ������ ���� ����� 1')
        endif
      elseif ascan(arr_lfk, alltrim_lshifr) > 0
        ++km
        if eq_any(alltrim_lshifr, '4.2.153', '4.11.136', '3.4.31') .and. au_lu[i, 6] != 1
          aadd(ta, '� ��㣥 ' + alltrim_lshifr + ' ������⢮ �� ������ ���� ����� 1')
        endif
        if au_lu[i, 6] > 1 .and. au_lu[i, 2] + au_lu[i, 6] - 1 > d2
          aadd(ta, '��� ����砭�� ��㣨 ' + alltrim_lshifr + ' ����� ���� ����砭�� ��祭��')
        endif
        //
        fl_not_2_89 := .f.
        if lTypeLUMedReab
          obyaz_uslugi_med_reab := compulsory_services(list2arr(human_2->PC5)[1], list2arr(human_2->PC5)[2])
          for each row in arrUslugi // �஢�ਬ �� ��㣨 ����
            if (iUsluga := ascan(obyaz_uslugi_med_reab, {|x| alltrim(x) == alltrim(row) })) > 0
              hb_ADel(obyaz_uslugi_med_reab, iUsluga, .t.)
            endif
          next
          if len(obyaz_uslugi_med_reab) > 0
            for each row in obyaz_uslugi_med_reab
              aadd(ta, '��������� ��易⥫쭠� ��㣠 ��� ����樭᪮� ॠ�����樨 "' + alltrim(row) + '"')
            next
          endif

          aUslMedReab := ret_usluga_med_reab(alltrim_lshifr, list2arr(human_2->PC5)[1], list2arr(human_2->PC5)[2])
          if aUslMedReab != nil .and. len(aUslMedReab) != 0
            if aUslMedReab[3] > au_lu[i, 6]
              aadd(ta, '��� ��㣨 ' + alltrim_lshifr + ' �ॡ���� ������ ' + lstr(aUslMedReab[3]) + ' �।��⠢�����!')
            endif
            if aUslMedReab[3] > 1 .and. (count_days(au_lu[i, 2], au_lu[i, 11]) < aUslMedReab[3])
              aadd(ta, '������⢮ ���� �믮������ ��㣨 ����� ������⢠ ����७�� ��㣨!')
            endif
          endif
        else
          if left_lshifr_3 == '20.' // ���
            atmp := {'20.1.2', '20.1.1', '20.1.3', '20.1.1', '20.1.1'}
            for j := 6 to 12
              aadd(atmp, '20.1.4')
            next
            for j := 13 to 14
              aadd(atmp, '20.1.5')
            next
            aadd(atmp,'20.2.3') // j=15 ��� � ��-��� ⥫�����樭�
            if ascan(atmp, alltrim_lshifr) > 0
              for j := 1 to 15
                if a_2_89[j] == 1 .and. !(alltrim_lshifr == atmp[j])
                  fl_not_2_89 := .t.
                endif
              next
            endif
            if alltrim_lshifr == '20.2.1' .and. emptyall(a_2_89[1], a_2_89[4], a_2_89[5])
              fl_not_2_89 := .t.
            elseif alltrim_lshifr == '20.2.2' .and. empty(a_2_89[3])
              fl_not_2_89 := .t.
            endif
          elseif left_lshifr_3 == '21.' // ���ᠦ
            // �஬� ���������
            atmp := {'21.1.2', '21.1.1', '21.1.3', '21.1.1', '21.1.1'}
            if ascan(atmp, alltrim_lshifr) > 0
              for j := 1 to len(atmp)
                if a_2_89[j] == 1 .and. !(alltrim_lshifr == atmp[j])
                  fl_not_2_89 := .t.
                endif
              next
            endif
            // ���������
            if alltrim_lshifr == '21.1.4' .and. emptyall(a_2_89[6], a_2_89[7], a_2_89[9], a_2_89[10])
              fl_not_2_89 := .t.
            endif
            if alltrim_lshifr == '21.2.1' .and. emptyall(a_2_89[6], a_2_89[7], a_2_89[8], a_2_89[9], a_2_89[11])
              fl_not_2_89 := .t.
            endif
            // 2.89.25 '���饭�� � 楫�� ����樭᪮� ॠ�����樨 ��樥�⮢ �� ��祭�� �࣠��� ��堭��'
            if alltrim_lshifr == '21.1.5' .and. empty(a_2_89[14])
              fl_not_2_89 := .t.
            endif
          elseif left_lshifr_3 == '22.' // �䫥���࠯��
            // �஬� ���������
            atmp := {'22.1.2', '22.1.1', '22.1.3', '22.1.1', '22.1.1'}
            if ascan(atmp, alltrim_lshifr) > 0
              for j := 1 to 5
                if a_2_89[j] == 1 .and. !(alltrim_lshifr == atmp[j])
                  fl_not_2_89 := .t.
                endif
              next
            endif
          endif
          if zs > 1
            aadd(ta, '� ���� ��� ����� ����� ��㣨 2.89.* "�����祭�� ��砩"')
          endif
          if kol_2_6 < 2
            aadd(ta, '�஬� ��㣨 ' + lstshifr + ' � ���� ��� ������ ���� ��� � ����� ��� 2.6.*')
          endif
        endif
        if fl_not_2_89
          aadd(ta, '��㣠 ' + alltrim_lshifr + ' �� �室�� � ����� ��� ��� ���饭�� � 楫�� ����樭᪮� ॠ�����樨 ' + shifr_zs)
        endif
      else
        s += alltrim_lshifr + ' '
        ++ oth_usl
      endif
    next
    if oth_usl > 0
      aadd(ta, '� ���� ��� �� ������ ���� ������ ���: ' + s)
    endif
    if kol_2_6 > 0
      if !is_1_den
        aadd(ta, '��ࢠ� ��㣠 2.6.* ������ ���� ������� � ���� ���� ��祭��')
      endif
      if !is_last_den
        aadd(ta, '��᫥���� ��㣠 2.6.* ������ ���� ������� � ��᫥���� ���� ��祭��')
      endif
    endif
    if km == 0
      aadd(ta, '� ���� ��� ��� �� ����� ��㣨 "���������"')
    endif
  elseif is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
    //
  elseif kol_2_60 > 0
    aadd(ta, '����� � ��㣠�� ' + s + ' ������ ���� ��㣠 "�����祭�� ��砩"')
  endif
  d := human->k_data - human->n_data
  if kkd > 0
    if empty(d) .and. kkd == 1
      // ��-������ ���� �����-����
    elseif kkd > d
      aadd(ta, '���-�� �����-���� (' + lstr(kkd) + ') �ॢ�蠥� �ப ��祭�� �� ' + lstr(kkd - d))
    elseif kkd < d
      aadd(ta, '���-�� �����-���� (' + lstr(kkd) + ') ����� �ப� ��祭�� �� ' + lstr(d - kkd))
    endif
  elseif kds > 0
    if kds > (d + 1)
      aadd(ta, '���-�� ��� �������� ��樮��� (' + lstr(kds) + ') �ॢ�蠥� �ப ��祭�� �� ' + lstr(kds - (d + 1)))
    endif
    if is_eko
      if human_->PROFIL != 137
        aadd(ta, '��� ���=' + shifr_ksg + ' ��䨫� ������ ���� �� "�������� � ����������� (�ᯮ�짮����� �ᯮ����⥫��� ९த�⨢��� �孮�����)"')
      endif
      a_1_11 := {}
      for i := 1 to len(au_flu)
        aadd(a_1_11, alltrim(au_flu[i, 1]))
      next
      j := 1 // ���� - 1 �奬�
      if ascan(a_1_11, 'A11.20.031') > 0  // �ਮ
        j := 6  // 6 �奬�
        if ascan(a_1_11, 'A11.20.028') > 0 // ��⨩ �⠯
          j := 2   // 2 �奬�
        endif
      elseif ascan(a_1_11, 'A11.20.025.001') > 0  // ���� �⠯
        j := 3  // 3 �奬�
        if ascan(a_1_11, 'A11.20.036') > 0  // �������騩 ��ன �⠯
          j := 4  // 4 �奬�
        elseif ascan(a_1_11, 'A11.20.028') > 0  // �������騩 ��⨩ �⠯
          j := 5  // 5 �奬�
        endif
      elseif ascan(a_1_11, 'A11.20.030.001') > 0  // ⮫쪮 �⢥��� �⠯
        j := 7  // 7 �奬�
      endif
      ashema := {;
        {'A11.20.017'}, ;
        {'A11.20.017', 'A11.20.028', 'A11.20.031'}, ;
        {'A11.20.017', 'A11.20.025.001'}, ;
        {'A11.20.017', 'A11.20.025.001', 'A11.20.036'}, ;
        {'A11.20.017', 'A11.20.025.001', 'A11.20.028'}, ;
        {'A11.20.017', 'A11.20.031'}, ;
        {'A11.20.017', 'A11.20.030.001'};
      }
      if (k := len(ashema[j])) == (n := len(a_1_11))
        //
      elseif k > n
        aadd(ta, '� ���� ���� �� ��� �� 墠⠥� ��� ' + print_array(a_1_11))
      elseif k < n
        for i := 1 to k
          if (n := ascan(a_1_11, ashema[j, i])) > 0
            Del_Array(a_1_11, n)
          endif
        next
        if len(a_1_11) > 0
          aadd(ta, '� ���� ���� �� ��� ��譨� ��㣨 ' + print_array(a_1_11))
        endif
      endif
    endif
  elseif kkt > 0 .and. !is_s_dializ .and. !is_dializ .and. !is_perito
    mPZTIP := 66 // 66, '�-��᫥�������', '�-��᫥�.'}, ;
    mPZKOL := kkt
    if !emptyall(kkd, kds, kvp, ksmp)
      aadd(ta, '�஬� ��� 60.* � ���� ��� �� ������ ���� ��㣨� ��� �����')
    endif
    if human_->USL_OK != USL_OK_POLYCLINIC
      aadd(ta, '� ���� "�᫮��� ��������" ������ ���� "�����������"')
    endif
    if is_kt
      s := '��'
    elseif is_mrt
      s := '���'
    elseif is_uzi
      s := '��� ���'
    elseif is_endo
      s := '��᪮���'
    elseif is_gisto
      s := '���⮫����'
    elseif is_mgi
      s := '�������୮� ����⨪�'
    elseif is_g_cit
      s := '������⭮� �⮫����'
      mPZTIP := 68 // 68, '������⭠� �⮫����', '����.�⮫'}, ;
    elseif is_pr_skr
      s := '�७�⠫쭮�� �ਭ����'
      mPZTIP := 67 // 67, '�७�⠫�� �ਭ���', '�७.�ਭ'}, ;
    endif
    if empty(human_->NPR_MO)
      aadd(ta, '��� ' + s + ' ������ ���� ��������� "���ࠢ���� ��"')
    elseif empty(human_2->NPR_DATE)
      if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
        human_2->NPR_DATE := d1
      else
        aadd(ta, '������ ���� ��������� ���� "��� ���ࠢ�����"')
      endif
    elseif human_2->NPR_DATE > d1
      aadd(ta, '"��� ���ࠢ�����" ����� "���� ��砫� ��祭��"')
    elseif human_2->NPR_DATE+60 < d1
      aadd(ta, '���ࠢ����� ����� ���� ����楢')
    endif
    if !eq_any(human_->RSLT_NEW, 314)
      aadd(ta, '� ���� "������� ���饭��" ������ ���� "314 �������᪮� �������"')
    endif
    if !eq_any(human_->ISHOD_NEW, 304)
      aadd(ta, '� ���� "��室 �����������" ������ ���� "304 ��� ��६��"')
    endif
    if is_g_cit .or. is_pr_skr
      if kkt > 1
        aadd(ta, '���-�� ��� ' + s + ' (' + lstr(kkt) + ') �� ������ ���� ����� 1')
      endif
      if human_->PROFIL != 34
        aadd(ta, '��� ' + s + ' ��䨫� ������ ���� ����������� ������������ �����������')
      endif
    else
      if is_oncology == 2
        // ����� ���饭�� - �������⨪� 㦥 �஢�७ ���
      elseif padr(mdiagnoz[1], 5) == 'Z03.1'
        //if is_gisto
          //aadd(ta, '��� ' + s + ' �� ����� ���� ��⠭����� �᭮���� ������� 'Z03.1 ������� �� �����७�� �� �������⢥���� ���宫�'')
        //endif
      elseif is_kt
        if !(padr(mdiagnoz[1], 5) == 'Z01.6')
          aadd(ta, '��� ' + s + ' �᭮���� ������� ������ ���� Z01.6')
        endif
      elseif is_mrt .or. is_uzi .or. is_endo
        if !(padr(mdiagnoz[1], 5) == 'Z01.8')
          aadd(ta, '��� ' + s + ' �᭮���� ������� ������ ���� Z01.8')
        endif
      elseif is_gisto
        aadd(ta, '��� ' + s + ' �᭮���� ������� �� ����� ���� ' + rtrim(mdiagnoz[1]) + ;
                ' (�஬� ���������᪮�� �������� ࠧ�蠥��� �ᯮ�짮���� ⮫쪮 Z03.1)')
      endif
    endif
    fl := .t.
    for i := 1 to len(au_lu)
      if au_lu[i, 2] == d1
        fl := .f. ; exit
      endif
    next
    if fl
      aadd(ta, '��� ' + s + ' ���� �� ��� ������ ���� ������� � ���� ��砫� ��祭��')
    endif
  elseif kvp > 0
    mPZKOL := kvp-kvp_2_78-kvp_2_89
    if mIDSP == 12
      mPZTIP := 60 // 60, '���饭�� ��䨫����᪮� ����� ���஢��', '�����.��'}, ;
      if kvp > 1 // �������᭠� ��㣠 業�� ���஢��
        aadd(ta, '� 業�� ���஢�� ������� ' + lstr(kvp) + ' ��㣨 (������ ���� ����)')
      endif
    endif
    if d2 > d1
      if is_2_88
        if month(d1) == month(d2)
          aadd(ta, '��� ������ ��㣨 �ப ��祭�� - ���� ����')
        elseif month(d2) - month(d1) > 1 .and. year(d1) == year(d2)
          aadd(ta, '��� ������ ��㣨 �ப ��祭�� �� ����� ���� ����� �����')
        endif
      elseif is_2_80 .or. is_2_81 .or. is_2_82 .or. is_pren_diagn
        aadd(ta, '��� ������ ��㣨 �ப ��祭�� - ���� ����')
      endif
    endif
    if kvp > 1 .and. (is_2_80 .or. is_2_81 .or. is_2_82 .or. is_2_88)
      aadd(ta, '������⢮ ��� ������ ���� ࠢ�� 1')
    endif
    if is_2_78 .or. is_2_89
      //mpztip := 59 // 59, '���饭��', '���.����.'}, ;
      mPZKOL := 1 // ???
    elseif is_2_79 .or. is_2_81 .or. is_2_88
      //mpztip := 57 // 57, '���饭�� ��䨫����᪮�', '���.���.'}, ;
    elseif is_2_80 .or. is_2_82
      //mpztip := 58 // 58, '���饭�� ���⫮����', '���.����.'}, ;
    endif
  elseif ksmp > 0
    mpztip := 51 // 51, '�맮� ���', '�맮� ���'}, ;
    mpzkol := ksmp
    if ksmp > 1
      aadd(ta, '������⢮ ��� ��� ������ ���� ࠢ�� 1')
    endif
    if len(au_lu) > 1
      aadd(ta, '�஬� ��㣨 71.* � ���� ��� �� ������ ���� ��㣨� ��� �����')
    endif
    if human_->USL_OK != USL_OK_AMBULANCE // 4
      aadd(ta, '��� ��㣨 ��� �᫮��� ������ ���� "����� ������"')
    endif
    if human_->IDSP != 24
      aadd(ta, '��� ��㣨 ��� ᯮᮡ ������ ������ ���� "�맮� ᪮ன ����樭᪮� �����"')
    endif
    if d1 < d2
      aadd(ta, '��� ᪮ன ����� ��� ��砫� ������ ࠢ������ ��� ����砭�� ��祭��')
    endif
    if (is_komm_SMP() .and. d2 < 0d20190501) .or. (is_komm_SMP() .and. d2 > 0d20220101) // �᫨ �� �������᪠� ᪮��
      if is_71_1
        aadd(ta, '��� �������᪮� ��� ����室��� �ਬ����� ��㣨 71.2.*')
      endif
    elseif empty(human_->OKATO) .or. human_->OKATO == '18000'
      if is_71_2
        aadd(ta, '��� ��樥�⮢, �����客����� �� ����ਨ ������ࠤ᪮� ������,')
        aadd(ta, '����室��� �ਬ����� ��㣨 71.1.*')
      endif
    else
      if is_71_1
        aadd(ta, '��� ��樥�⮢, �����客����� �� �।����� ������ࠤ᪮� ������,')
        aadd(ta, '����室��� �ਬ����� ��㣨 71.2.*')
      endif
    endif
  endif
  if is_dializ
    s := '�����������'
    if kds > 0 .and. kol_ksg == 0
      aadd(ta, '��� ' + s + ' �� �������� ��樥��-����')
    endif
    if !eq_any(human_->PROFIL, 56) // ����������
      aadd(ta, '��� ' + s + ' ��䨫� ������ ���� ����������')
    endif
    if !eq_any(ret_old_prvs(human_->PRVS), 112207, 113412) // ����������
      aadd(ta, '��� ' + s + ' ᯥ樠�쭮��� ��� ������ ���� ����������')
    endif
    if glob_mo[_MO_KOD_TFOMS] == '101004' // ���
      if empty(alltrim(human_->NPR_MO))
        human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
        human_2->(G_RLock(forever))
        human_2->NPR_DATE := d1
        human_2->(dbunlock())
      endif
    else
      human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
      human_2->(G_RLock(forever))
      human_2->NPR_DATE := d1
      human_2->(dbunlock())
    endif
    mpztip := 56 // 56, '��砩 �������', '���.����.'}, ;
    mpzkol := kkt
  endif
  if is_perito
    s := '��� ��������������� ������� '
    if human_->PROFIL != 56
      aadd(ta, s + '��䨫� ������ ���� ����������')
    endif
    if !eq_any(ret_old_prvs(human_->PRVS), 112207, 113412) // ����������
      aadd(ta, s + 'ᯥ樠�쭮��� ��� ������ ���� ����������')
    endif
    if glob_mo[_MO_KOD_TFOMS] == '101004' // ���
      if empty(alltrim(human_->NPR_MO))
        human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
        human_2->(G_RLock(forever))
        human_2->NPR_DATE := d1
        human_2->(dbunlock())
      endif
    else
      human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
      human_2->(G_RLock(forever))
      human_2->NPR_DATE := d1
      human_2->(dbunlock())
    endif
    mpztip := 56 // 56, '��砩 �������', '���.����.'}, ;
    mpzkol := kkt
  endif
  if is_s_dializ
    s := '��㣨 ������� � ��樮���'
    if glob_mo[_MO_KOD_TFOMS] == '101004' // ���
      if empty(alltrim(human_->NPR_MO))
        human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
        human_2->(G_RLock(forever))
        human_2->NPR_DATE := d1
        human_2->(dbunlock())
      endif
    else
      human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
      human_2->(G_RLock(forever))
      human_2->NPR_DATE := d1
      human_2->(dbunlock())
    endif
    //human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // ����᫮��� ���⠢�塞 ���ࠢ����� ��
    //human_2->(G_RLock(forever))
    //human_2->NPR_DATE := d1
    //human_2->(dbunlock())
    mpztip := 54 // 54, '��砩 ���', '��砩 ���'}, ;
    mpzkol := kkt
    for i := 1 to len(a_dializ)
      j := a_dializ[i, 5] - 1
      if !between(j, 1, 2)
        j := 1
      endif
      if overlap_diapazon(a_dializ[i, 1], a_dializ[i, 2], d1, d2) .or. eq_any(d1, a_dializ[i, 1], a_dializ[i, 2]) ;
                                                             .or. eq_any(d2, a_dializ[i, 1], a_dializ[i, 2])
        aadd(ta, '��㣠 ������� � ��樮��� ���ᥪ����� � ��砥� ' + {'����', '���⮭���쭮�� '}[j] + '������� ' + date_8(a_dializ[i, 1]) + '-' + date_8(a_dializ[i, 2]))
      endif
    next
    for i := 1 to len(a_srok_lech)
      otd->(dbGoto(a_srok_lech[i, 4]))
      if a_srok_lech[i, 5] == 1
        otd->(dbGoto(a_srok_lech[i, 4]))
        aadd(ta, '����祭�� � ��������� �������� ' + date_8(a_srok_lech[i, 1]) + '-' + date_8(a_srok_lech[i, 2]) + ;
                iif(empty(otd->short_name), '', ' [' + alltrim(otd->short_name) + ']'))
      endif
    next
  endif
  if is_disp_DDS //
    metap := 1
    m1mobilbr := 0
    human->OBRASHEN := ''
    tip_lu := iif(!empty(human->ZA_SMO), TIP_LU_DDS, TIP_LU_DDSOP)
    if d1_year != d2_year
      aadd(ta, '��� ��砫� � ����砭�� ���� ������ ���� � ����� ����')
    endif
    if eq_any(human->ishod, 101, 102)
      metap := human->ishod - 100
      read_arr_DDS(human->kod)
    else
      aadd(ta, '��ᯠ��ਧ��� ��⥩-��� ���� ������� �१ ᯥ樠��� �࠭ �����')
    endif
    is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := ''
    for i := 1 to len(au_lu)
      if au_lu[i, 3] == 0
        aadd(ta, '� ��㣥 ' + alltrim(au_lu[i, 1]) + ' �� ���⠢��� ��䨫�')
      endif
      if au_lu[i, 4] == 0
        aadd(ta, '� ��㣥 ' + alltrim(au_lu[i, 1]) + ' �� ���⠢���� ᯥ�-�� ���')
      endif
      if au_lu[i, 2] > d2
        aadd(ta, '��㣠 ' + au_lu[i, 5] + '(' + date_8(au_lu[i, 2]) + ') �� �������� � �������� ��祭��')
      endif
      if is_issl_DDS(au_lu[i], mvozrast, ta)
        s := '��㣠 ' + au_lu[i, 5] + '(' + date_8(au_lu[i, 2]) + ')'
        if alltrim(au_lu[i, 1]) == '7.61.3'
          if au_lu[i, 2] < addmonth(d1, -12)
            aadd(ta, '��ண��� ������� ����� 1 ���� �����')
          endif
        elseif mvozrast < 2
          if au_lu[i, 2] < addmonth(d1, -1)
            aadd(ta, s + ' ������� ����� 1 ����� �����')
          endif
        else
          if au_lu[i, 2] < addmonth(d1, -3)
            aadd(ta, s + ' ������� ����� 3 ����楢 �����')
          endif
        endif
        if d1 == au_lu[i, 2]
          is_1_den := .t.
        endif
      else
        s := '��㣠 ' + au_lu[i, 5] + '-' +inieditspr(A__MENUVERT, getV002(), au_lu[i, 3]) + '(' + date_8(au_lu[i, 2]) + ')'
        if is_osmotr_DDS_1_etap(au_lu[i], mvozrast, metap, mpol, tip_lu) //eq_any(alltrim(au_lu[i, 5]),'2.3.1','2.4.1') // + 2.4.1-��娠��
          if eq_any(au_lu[i, 3], 68, 57) // ������� (��� ��饩 �ࠪ⨪�)
            if au_lu[i, 2] < d1
              aadd(ta, '��� �ᬮ�� ������� �� I �⠯� �� �������� � �������� ��祭��')
            endif
          elseif mvozrast < 2
            if au_lu[i, 2] < addmonth(d1, -1)
              aadd(ta, s + ' ������� ����� 1 ����� �����')
            endif
          else
            if au_lu[i, 2] < addmonth(d1, -3)
              aadd(ta, s + ' ������� ����� 3 ����楢 �����')
            endif
          endif
        elseif au_lu[i, 2] < d1
          aadd(ta, s + ' �� �������� � �������� ��祭��')
        endif
        if eq_any(left(au_lu[i, 1], 5), '70.5.', '70.6.')
          ++zs
          s := ret_shifr_zs_DDS(tip_lu)
          if !(alltrim(au_lu[i, 1]) == s)
            aadd(ta, '� �/� ��㣠 ' + alltrim(au_lu[i, 1]) + ', � ������ ���� ' + s + ;
                    ' ��� ������ ' + lstr(mvozrast) + ' ' + s_let(mvozrast))
          endif
        elseif is_osmotr_DDS(au_lu[i], mvozrast, ta, metap, mpol, tip_lu)
          if eq_any(left(au_lu[i, 1], 5), '2.83.', '2.87.')
            ++kvp
          elseif left(au_lu[i, 1], 4) == '2.3.'
            ++kvp
          endif
          if d1 == au_lu[i, 2]
            is_1_den := .t.
          endif
          if d2 == au_lu[i, 2]
            is_last_den := .t.
          endif
        else
          oth_usl += alltrim(au_lu[i, 1]) + ' '
        endif
      endif
    next
    if metap == 1 .and. zs > 1
      aadd(ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"')
    elseif metap == 2 .and. zs > 0
      aadd(ta, '��� I � II �⠯�� ��� �� ������ ���� ��� "�����祭�� ��砩"')
    endif
    if !empty(oth_usl)
      aadd(ta, '� ���� ��� ��� ��譨� ��㣨: ' + oth_usl)
    endif
    if !is_1_den
      //aadd(ta, '���� ��祡�� �ᬮ�� ������ ���� ������ � ���� ���� ��祭��')
    endif
    if !is_last_den
      aadd(ta, '��᫥���� ��祡�� �ᬮ�� ������ ���� ������ � ��᫥���� ���� ��祭��')
    endif
    k := 0
    for d := d1 to d2
      if is_work_day(d)
        ++k
      endif
    next
    if metap == 1 .and. k > 10
      aadd(ta, '�ப ��� I �⠯� ������ ��⠢���� �� ����� 10 ࠡ��� ���� (� ��� ' + lstr(k) + ')')
    elseif metap == 2 .and. k > 45
      aadd(ta, '�ப ��� I � II �⠯� ������ ��⠢���� �� ����� 45 ࠡ��� ���� (� ��� ' + lstr(k) + ')')
    endif
  endif
  if is_prof_PN //
    human_->profil := 151  // ����樭᪨� �ᬮ�ࠬ ��䨫����᪨�
    metap := 1
    m1mobilbr := 0
    if d1_year != d2_year
      aadd(ta, '��� ��砫� � ����砭�� ���� ������ ���� � ����� ����')
    endif
    if eq_any(human->ishod, 301, 302)
      metap := human->ishod - 300
      license_for_dispans(2, d1, ta)
    else
      aadd(ta, '��䨫��⨪� ��ᮢ��襭����⭨� ���� ������� �१ ᯥ樠��� �࠭ �����')
    endif
    mperiod := ret_period_PN(mdate_r, d1, d2)
    if between(mperiod, 1, 31)
      np_oftal_2_85_21(mperiod, d2) // �������� ��� 㤠���� ��⠫쬮���� � ���ᨢ ��� ��ᮢ��襭����⭨� ��� 12 ����楢
      read_arr_PN(human->kod)
      kol_d_otkaz := 0
      if valtype(arr_usl_otkaz) == 'A'
        for j := 1 to len(arr_usl_otkaz)
          ar := arr_usl_otkaz[j]
          if valtype(ar) == 'A' .and. len(ar) > 9 .and. valtype(ar[5]) == 'C' .and. ;
                                                       valtype(ar[10]) == 'C' .and. ar[10] $ 'io'
            lshifr := alltrim(ar[5])
            if ar[10] == 'i' // ��᫥�������
              if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == 'C' .and. x[1] == lshifr})) > 0
                if is_issled_PN({lshifr, ar[6], ar[4], ar[2]}, mperiod, ta, human->pol)
                  ++kol_d_otkaz
                endif
              endif
            elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == 'C' .and. x[1] == lshifr})) > 0 // �ᬮ���
              if is_osmotr_PN({lshifr, ar[6], ar[4], ar[2]}, mperiod, ta, metap, human->pol)
                ++kol_d_otkaz
              endif
            endif
          endif
        next j
      endif
      is_1_den := is_last_den := .f.
      zs := kvp := 0
      oth_usl := kod_zs := ''
      is_neonat := .f.
      for i := 1 to len(au_lu)
        if au_lu[i, 3] == 0
          aadd(ta, '� ��㣥 ' + alltrim(au_lu[i, 1]) + ' �� ���⠢��� ��䨫�')
        endif
        if au_lu[i, 4] == 0
          aadd(ta, '� ��㣥 ' + alltrim(au_lu[i, 1]) + ' �� ���⠢���� ᯥ�-�� ���')
        endif
        if au_lu[i, 2] > d2
          aadd(ta, '��㣠 ' + au_lu[i, 5] + '(' + date_8(au_lu[i, 2]) + ') �� �������� � �������� ��祭��')
        endif
        if is_issled_PN(au_lu[i], mperiod, ta, mpol)
          s := '��㣠 ' + au_lu[i, 5] + '(' + date_8(au_lu[i, 2]) + ')'
          if mvozrast < 2
            if left(au_lu[i, 5], 5) == '4.26.'
              is_neonat := .t.
            endif
            if au_lu[i, 2] < addmonth(d1, -1)
              aadd(ta, s + ' ������� ����� 1 ����� �����')
            endif
          else
            if au_lu[i, 2] < addmonth(d1, -3)
              aadd(ta, s + ' ������� ����� 3 ����楢 �����')
            endif
          endif
          if d1 == au_lu[i, 2]
            is_1_den := .t.
          endif
        else
          s := '��㣠 ' + au_lu[i, 5] + '-' + inieditspr(A__MENUVERT, getV002(), au_lu[i, 3]) + '(' + date_8(au_lu[i, 2]) + ')'
          if eq_any(au_lu[i, 3], 68, 57) .and. !(au_lu[i, 5] == '2.4.2')// ��祡�� ��� - ������� (��� ��饩 �ࠪ⨪�)
            if au_lu[i, 2] < d1
              aadd(ta, '��� �ᬮ�� ������� �� �������� � �������� ��祭��')
            endif
          elseif is_1_etap_PN(au_lu[i],mperiod,metap) // �᫨ ��㣠 �� 1 �⠯�
            if mvozrast < 2
              if au_lu[i, 2] < addmonth(d1, -1)
                aadd(ta, s + ' ������� ����� 1 ����� �����')
              endif
            else
              if au_lu[i, 2] < addmonth(d1, -3)
                aadd(ta, s + ' ������� ����� 3 ����楢 �����')
              endif
            endif
          elseif au_lu[i, 2] < d1
            aadd(ta, s + ' �� �������� � �������� ��祭��')
          endif
          if left(au_lu[i, 1], 5) == '72.2.'
            ++zs
            kod_zs := alltrim(au_lu[i, 1])
          elseif eq_any(au_lu[i, 3], 68, 57) // ������� (��� ��饩 �ࠪ⨪�)
            ++kvp
            if d1 == au_lu[i, 2]
              is_1_den := .t.
            endif
            if d2 == au_lu[i, 2]
              is_last_den := .t.
            endif
          elseif is_osmotr_PN(au_lu[i],mperiod, ta, metap, mpol)
            if eq_any(left(au_lu[i, 1], 4), '2.3.', '2.4.', '2.85', '2.91')
              ++kvp
            endif
            if d1 == au_lu[i, 2]
              is_1_den := .t.
            endif
            if d2 == au_lu[i, 2]
              is_last_den := .t.
            endif
          elseif !(metap == 2 .and. is_lab_usluga(au_lu[i, 1]))
            oth_usl += alltrim(au_lu[i, 1]) + ' '
          endif
        endif
      next
      if metap == 1 .and. zs == 1
        s := ret_shifr_zs_PN(mperiod)
        if !(kod_zs == s)
          aadd(ta, '� �/� ��㣠 ' +kod_zs+ ', � ������ ���� ' + s + ' ��� ������ ' + lstr(mvozrast) + ' ' + s_let(mvozrast))
        endif
      elseif metap == 1 .and. zs > 1
        aadd(ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"')
      elseif metap == 2 .and. zs > 0
        aadd(ta, '��� �����⠯��� ��䨫��⨪� ��ᮢ��襭����⭨� �� ������ ���� ��� "�����祭�� ��砩"')
      endif
      if !empty(oth_usl)
        aadd(ta, '� ���� ��� �� ��譨� ��㣨: ' + oth_usl)
      endif
      if !is_1_den
        //aadd(ta, '���� ��祡�� �ᬮ�� ������ ���� ������ � ���� ���� ��祭��')
      endif
      if !is_last_den
        aadd(ta, '��᫥���� ��祡�� �ᬮ�� ������ ���� ������ � ��᫥���� ���� ��祭��')
      endif
      k := 0
      for d := d1 to d2
        if is_work_day(d)
          ++k
        endif
      next
      if metap == 1 .and. k > 20
        aadd(ta, '�ப �� I �⠯� ������ ��⠢���� 20 ࠡ��� ���� (� ��� ' + lstr(k) + ')')
      elseif metap == 2 .and. k > 45
        aadd(ta, '�ப �� I � II �⠯� ������ ��⠢���� 45 ࠡ��� ���� (� ��� ' + lstr(k) + ')')
      endif
      // �஢�ਬ, �믮����� ��易⥫�� ��㣨 (� �������)
      ar := aclone(np_arr_1_etap[mperiod, 5])
      for i := 1 to len(ar) // ��᫥�������
        lshifr := alltrim(ar[i])
        if ascan(au_lu, {|x| alltrim(x[1]) == lshifr}) > 0
          // ��㣠 �������
        elseif ascan(arr_usl_otkaz, {|x| valtype(x)=='A' .and. valtype(x[5])=='C' .and. alltrim(x[5])==lshifr}) > 0
          // ��㣠 � �⪠���
        else
          s := ''
          if (j := ascan(np_arr_issled, {|x| x[1] == lshifr})) > 0
            s := np_arr_issled[j, 3]
          endif
          aadd(ta, '�����४⭮ ����ᠭ� ��᫥������� ' + lshifr + ' ' + s + ' (��।������)')
        endif
      next
      ar := aclone(np_arr_1_etap[mperiod, 4])
      for i := 1 to len(ar) // �ᬮ��� 1 -�� �⠯�
        lshifr := alltrim(ar[i])
        if (j := ascan(np_arr_osmotr, {|x| x[1] == lshifr})) > 0
          fl := .f.
          if ascan(au_lu, {|x| alltrim(x[1]) == lshifr}) > 0
            fl := .t. // ��㣠 �������
          elseif ascan(arr_usl_otkaz, {|x| valtype(x)=='A' .and. valtype(x[5])=='C' .and. alltrim(x[5])==lshifr}) > 0
            fl := .t. // ��㣠 � �⪠���
          elseif !empty(np_arr_osmotr[j, 2]) .and. !(np_arr_osmotr[j, 2] == human->pol)
            loop
          else
            for k := 1 to len(au_lu)
              // �஢��塞 ⮫쪮 �㫥�� ��㣨
              if eq_any(left(au_lu[k, 1], 4), '2.3.', '2.4.')
                if valtype(np_arr_osmotr[j, 4]) == 'N'
                  if au_lu[k, 3] == np_arr_osmotr[j, 4]
                    fl := .t. // ��㣠 ������� (��諨 �� ��䨫�)
                    exit
                  endif
                elseif ascan(np_arr_osmotr[j, 4], au_lu[k, 3]) > 0
                  fl := .t. // ��㣠 ������� (��諨 �� ��䨫�)
                  exit
                endif
              endif
            next k
          endif
          if !fl .and. d2 < d_01_11_2019
            if mperiod == 16 .and. np_arr_osmotr[j, 1] == '2.4.2' // 2 ����
              fl := .t. // ��㣠 �� ������ ���� �������
            elseif mperiod == 20 .and. np_arr_osmotr[j, 1] == '2.85.24' // 6 ���
              fl := .t. // ��㣠 �� ������ ���� �������
            endif
          endif
          if !fl
            aadd(ta, '�����४⭮ ����ᠭ ��祡�� �ᬮ�� 1-�� �⠯� "' + np_arr_osmotr[j, 3] + ' (��।������)')
          endif
        endif
      next i
      if empty(ta) // �᫨ ���� ��� �訡��
        fl := .f.
        for i := 1 to len(au_lu)
          if eq_any(au_lu[i, 3], 68, 57) ; // ������� (��� ��饩 �ࠪ⨪�)
                    .and. left(au_lu[i, 1], 4) == '2.3.' // �� 1-�� �⠯�
            fl := .t. ; exit
          endif
        next i
        if !fl
          aadd(ta, '�����४⭮ ����ᠭ ��祡�� �ᬮ�� ������� �� 1-�� �⠯� (��।������)')
        endif
      endif
    else
      aadd(ta, '�� 㤠���� ��।����� �����⭮� ��ਮ� ��� ��䨫��⨪� ��ᮢ��襭����⭥��')
    endif
  endif
  if is_disp_DVN //
    m1mobilbr := 0
    human_->profil := 151  // ����樭᪨� �ᬮ�ࠬ ��䨫����᪨�
    ret_arr_vozrast_DVN(d2)
    ret_arrays_disp(is_disp_19)
    m1g_cit := m1veteran := m1dispans := 0 ; is_prazdnik := f_is_prazdnik_DVN(d1)
    if empty(sadiag1)
      Private file_form, diag1 := {}, len_diag := 0
      if (file_form := search_file('DISP_NAB' + sfrm)) == NIL
        aadd(ta, '�� �����㦥� 䠩� DISP_NAB' + sfrm)
      endif
      f2_vvod_disp_nabl('A00')
      sadiag1 := diag1
    endif
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := 'mdiag' + sk
      pole_1pervich := 'm1pervich' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      Private &pole_diag := space(6)
      Private &pole_1pervich := 0
      Private &pole_1dispans := 0
      Private &pole_dn_dispans := ctod('')
    next
    m1dopo_na := 0
    m1napr_v_mo := 0 // {{'-- ��� --', 0}, {'� ���� ��', 1}, {'� ���� ��', 2}}, ;
    arr_mo_spec := {}
    m1napr_stac := 0 // {{'--- ��� ---', 0}, {'� ��樮���', 1}, {'� ��. ���.', 2}}, ;
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_DVN(human->kod)
    if m1dopo_na > 0
      aadd(arr_nazn, {3, {}}) ; j := len(arr_nazn)
      for i := 1 to 4
        if isbit(m1dopo_na, i)
          aadd(arr_nazn[j, 2], i)
        endif
      next
    endif
    if between(m1napr_v_mo, 1, 2) .and. !empty(arr_mo_spec) // {{'-- ��� --', 0}, {'� ���� ��', 1}, {'� ���� ��', 2}}, ;
      aadd(arr_nazn, {m1napr_v_mo, {}}) ; j := len(arr_nazn)
      for i := 1 to min(3,len(arr_mo_spec))
        aadd(arr_nazn[j, 2], arr_mo_spec[i])
      next
    endif
    if between(m1napr_stac, 1, 2) .and. m1profil_stac > 0 // {{'--- ��� ---', 0}, {'� ��樮���', 1}, {'� ��. ���.', 2}}, ;
      aadd(arr_nazn, {iif(m1napr_stac==1, 5, 4),m1profil_stac})
    endif
    if m1napr_reab == 1 .and. m1profil_kojki > 0
      aadd(arr_nazn, {6,m1profil_kojki})
    endif
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := 'mdiag' + sk
      pole_1pervich := 'm1pervich' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      arr_diag := {alltrim(&pole_diag),&pole_1pervich,&pole_1dispans,&pole_dn_dispans}
      // ����⢨� �� ����� � ���� ����
      if arr_diag[2] == 0 // '࠭�� �����'
        arr_diag[2] := 2  // �����塞, ��� � ���� ���� ���
      endif
      if arr_diag[3] > 0 // '���.������� ��⠭������' � '࠭�� �����'
        if arr_diag[2] == 2 // '࠭�� �����'
          arr_diag[3] := 1 // � '���⮨�'
        else
          arr_diag[3] := 2 // � '����'
        endif
      endif
      // ����⢨� �� ����� � ॥���
      s := 3 // �� �������� ��ᯠ��୮�� �������
      if arr_diag[2] == 1 // �����
        if arr_diag[3] == 2
          s := 2 // ���� �� ��ᯠ��୮� �������
        endif
      elseif arr_diag[2] == 2 // ࠭��
        if arr_diag[3] == 1
          s := 1 // ��⮨� �� ��ᯠ��୮� �������
        elseif arr_diag[3] == 2
          s := 2 // ���� �� ��ᯠ��୮� �������
        endif
      endif
      if !empty(arr_diag[1]) .and. ascan(sadiag1, arr_diag[1]) > 0
        if empty(arr_diag[4])
          if s == 2
            aadd(ta, '�� ������� ��� ᫥���饣� ����� ��� ' + arr_diag[1])
          endif
        elseif arr_diag[4] > d2
          if s == 1
            is_disp_nabl := .t.
          endif
        else
          aadd(ta, '�����४⭠� ��� ᫥���饣� ����� ��� ' + arr_diag[1])
        endif
      endif
    next
    if d1_year != d2_year
      aadd(ta, '��� ��砫� � ����砭�� ���� ������ ���� � ����� ����')
    endif
    for i := 1 to len(au_lu_ne)
      s := alltrim(au_lu_ne[i, 1])
      if !empty(au_lu_ne[i, 2])
        s += '(' + alltrim(au_lu_ne[i, 2]) + ')'
      endif
      s += ' ' + alltrim(au_lu_ne[i, 3])
      aadd(ta, '����ୠ� ��㣠 "' + s + '" �� ' + date_8(au_lu_ne[i, 4]) + '�.')
    next
    metap := 3
    if between(human->ishod, 201, 205)
      metap := human->ishod - 200
      license_for_dispans(1, d1, ta)
    else
      aadd(ta, '��ᯠ��ਧ���/��䨫��⨪� ������ ���� ������� �१ ᯥ樠��� �࠭ �����')
    endif
    if m1veteran == 1
      if metap == 3
        aadd(ta, '��䨫��⨪� ������ �� �஢���� ���࠭�� ��� (�����������)')
      else
        mdvozrast := ret_vozr_DVN_veteran(mdvozrast, d2)
      endif
    endif
    is_prof_disp := .f.
    // �᫨ �� ���ᬮ��
    if metap == 3 .and. ascan(ret_arr_vozrast_DVN(d2),mdvozrast) > 0 // � ������ ��ᯠ��ਧ�樨
      metap := 1 // �ॢ�頥� � ��ᯠ��ਧ���
      is_prof_disp := .t.
    endif
    for i := 1 to len(a_disp)
      // {human->ishod-200, human->n_data, human->k_data, human_->RSLT_NEW}
      if overlap_diapazon(a_disp[i, 2], a_disp[i, 3], d1, d2)
        aadd(ta, '����祭�� � ' + iif(a_disp[i, 1]==3, '��䨫��⨪�� ', '��ᯠ��ਧ�樥� ') + ;
                date_8(a_disp[i, 2]) + '-' + date_8(a_disp[i, 3]))
      endif
    next
    if metap == 2 .and. ascan(a_disp, {|x| x[1] == 1 }) == 0
      aadd(ta, '�� II �⠯ ��ᯠ��ਧ�樨, �� ��������� ��砩 I �⠯� ��ᯠ��ਧ�樨')
    elseif metap == 5 .and. ascan(a_disp, {|x| x[1] == 4 }) == 0
      aadd(ta, '�� II �⠯ ��ᯠ��ਧ�樨, �� ��������� ��砩 I �⠯� ��ᯠ��ਧ�樨 ࠧ � 2 ����')
    endif
    // �⬥⨬ ��易⥫�� ��㣨
    arr1 := array(count_dvn_arr_usl, 5)
    afillall(arr1, 0)
    arr2 := array(count_dvn_arr_umolch, 5)
    afillall(arr2, 0)
    for i := 1 to count_dvn_arr_usl
      fl_ekg := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN(i, metap, iif(metap == 3.and.!is_disp_19, mvozrast, mdvozrast), mpol, , @i_otkaz, @fl_ekg)
        arr1[i, 2] := 1
        arr1[i, 3] := i_otkaz
        arr1[i, 5] := iif(fl_ekg, 1, 0) // 1 - ����易⥫�� ������
      endif
    next
    for i := 1 to count_dvn_arr_umolch
      if f_is_umolch_sluch_DVN(i, metap, iif(metap == 3.and.!is_disp_19, mvozrast, mdvozrast), mpol)
        arr2[i, 2] := 1
      endif
    next
    // �⬥⨬ �믮������ ��㣨
    for j := 1 to len(au_lu)
      lshifr := alltrim(au_lu[j, 1])
      fl := .t.
      if !is_disp_19 .and. ((lshifr == '2.3.3' .and. au_lu[j, 3] == 3) .or.  ; // �����᪮�� ����
                            (lshifr == '2.3.1' .and. au_lu[j, 3] == 136))  ; // �������� � �����������
          .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=='C' .and. x[2]=='4.1.12'})) > 0
        arr1[i, 1] ++
        fl := .f.
      endif
      if fl
        for i := 1 to count_dvn_arr_umolch
          if arr2[i, 1] == 0 .and. dvn_arr_umolch[i, 2] == lshifr
            arr2[i, 1] ++
            fl := .f.
            exit
          endif
        next
      endif
      if fl
        for i := 1 to count_dvn_arr_usl
          if metap == 2 .and. valtype(dvn_arr_usl[i, 2]) == 'C' .and. dvn_arr_usl[i, 2] == lshifr
            s := '"' +dvn_arr_usl[i, 2] + ' ' +dvn_arr_usl[i, 1] + '"'
            if valtype(dvn_arr_usl[i, 3]) == 'N'
              if dvn_arr_usl[i, 3] != 2
                aadd(ta, '�� ���� �믮�����, � �믮����� ' + s)
              endif
            else
              if ascan(dvn_arr_usl[i, 3], 2) == 0
                aadd(ta, '�� ���� �믮�����, � �믮����� ' + s)
              endif
            endif
          endif
          if arr1[i, 1] == 0
            if valtype(dvn_arr_usl[i, 2]) == 'C'
              if dvn_arr_usl[i, 2] == '4.20.1'
                if lshifr == '4.20.1'
                  m1g_cit := 1
                elseif lshifr == '4.20.2'
                  m1g_cit := 2 ; fl := .f.
                endif
              endif
              if dvn_arr_usl[i, 2] == lshifr
                fl := .f.
              endif
            endif
            if fl .and. len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i, 12]) == 'A'
              if ascan(dvn_arr_usl[i, 12], {|x| x[1] == lshifr .and. x[2] == au_lu[j, 3]}) > 0
                fl := .f.
              endif
            endif
            if !fl
              arr1[i, 1] ++
              exit
            endif
          endif
        next
      endif
      if fl .and. !is_disp_19 .and. ascan(dvn_700, {|x| x[2] == lshifr}) > 0
        fl := .f. // � �㫥��� ��㣥 ��������� ��㣠 � 業�� �� '700'
      endif
      if fl .and. !eq_any(left(lshifr, 5), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.')
        aadd(ta, lshifr + ' - �����४⭠� ����ன�� � �ࠢ�筨�� ��� ��� �����')
      endif
    next j
    is_1_den := is_last_den := .f.
    zs := kvp := 0
    oth_usl := ''
    mv := iif(metap == 3 .and. !is_disp_19, mvozrast, mdvozrast)
    kod_spec_ter := 0
    if eq_any(metap, 1, 4)
      for i := 1 to len(au_lu)
        if eq_any(au_lu[i, 3], 97, 57, 42) // ��䨫� �࠯��� (��� ��饩 �ࠪ⨪�)
          kod_spec_ter := au_lu[i, 4]  // ᯥ樠�쭮��� �࠯��� (��� ��饩 �ࠪ⨪�)
          exit
        endif
      next
    elseif eq_any(metap, 2, 5) // ����ઠ �� ��易⥫쭮� ��⠭�� ��� ��ண� �⠯�
      ar := array(len(dvn_2_etap), 2)
      afillall(ar, 0)
      for i := 1 to len(au_lu)
        lshifr := alltrim(au_lu[i, 1])
        for j := 1 to len(dvn_2_etap)
          if ascan(dvn_2_etap[j, 1], lshifr) > 0 .and. between(mdvozrast, dvn_2_etap[j, 3], dvn_2_etap[j, 4])
            ar[j, 1] := 1
          elseif ascan(dvn_2_etap[j, 2], lshifr) > 0 .and. between(mdvozrast, dvn_2_etap[j, 3], dvn_2_etap[j, 4])
            ar[j, 2] := 1
          endif
        next
      next
      for j := 1 to len(dvn_2_etap)
        if empty(ar[j, 1]) .and. !empty(ar[j, 2])
          if len(dvn_2_etap[j, 2]) == 1
            s := '��� ��㣨 ' + dvn_2_etap[j, 2, 1]
          else
            s := '��� ��� ' + print_array(dvn_2_etap[j, 2])
          endif
          s += ' ��易⥫쭮 ����稥 ��㣨 '
          if len(dvn_2_etap[j, 1]) == 1
            s += dvn_2_etap[j, 1, 1]
          else
            s += print_array(dvn_2_etap[j, 1])
          endif
          s += ' (� ������ �� ' + lstr(dvn_2_etap[j, 3]) + ' �� ' + lstr(dvn_2_etap[j, 4]) + ' ���)'
          aadd(ta,s)
        //elseif !empty(ar[j, 1]) .and. empty(ar[j, 2])
          //aadd(ta, '��� ��㣨 ' + print_array(dvn_2_etap[j, 1]) + ' ��易⥫쭮 ����稥  ��� ' + print_array(dvn_2_etap[j, 2]))
        endif
      next
    endif
    a_4_20_1 := {0, 0}
    for i := 1 to len(au_lu)
      lshifr := alltrim(au_lu[i, 1])
      do case
        case lshifr == '4.1.12' // �ᬮ�� ����મ�, ���⨥ ����� (�᪮��)
          a_4_20_1[1] := 3
        case eq_any(lshifr, '4.20.1', '4.20.2') // ���-� ���⮣� �⮫����᪮�� ���ਠ��
          a_4_20_1[2] := 3
          if lshifr == '4.20.2' .and. au_lu[i, 7] < d1
            m1g_cit := 1
          endif
      endcase
    next
    // ���� � �஢�ઠ �⪠���
    kol_d_usl := kol_d_otkaz := kol_n_date := kol_ob_otkaz := 0
    if valtype(arr_usl_otkaz) == 'A'
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == 'A' .and. len(ar) >= 10 .and. valtype(ar[5]) == 'C'
          lshifr := alltrim(ar[5])
          for i := 1 to count_dvn_arr_usl
            if valtype(dvn_arr_usl[i, 2]) == 'C' .and. ;
              (dvn_arr_usl[i, 2] == lshifr .or. (len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i, 12]) == 'A' ;
                                                                 .and. ascan(dvn_arr_usl[i, 12], {|x| x[1] == lshifr}) > 0))
              if valtype(ar[10]) == 'N' .and. between(ar[10], 1, 2)
                ++kol_d_usl
                arr1[i, 4] := ar[10] // 1-�⪠�, 2-�������������
                if lshifr == '4.1.12' // �ᬮ�� ����મ�, ���⨥ ����� (�᪮��)
                  a_4_20_1[1] := ar[10]
                endif
                if ar[10] == 1
                  ++kol_d_otkaz
                  if is_disp_19 .and. eq_any(lshifr, '4.8.4', '4.14.66', '7.57.3', '2.3.1', '2.3.3', '4.1.12', '4.20.1', '4.20.2')
                    ++kol_ob_otkaz // ���-�� �⪠��� �� ��易⥫��� ���
                  endif
                  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
                  is_usluga_dvn({lshifr, ar[9], ar[4], ar[2]}, mv, ta, metap, mpol, kod_spec_ter)
                  // �஢��塞 �� ᯥ樠�쭮���
                  UslugaAccordancePRVS(lshifr, human->vzros_reb, ar[2], ta, lshifr, iif(valtype(ar[1])=='N', ar[1], 0))
                endif
              endif
            endif
          next i
        endif
      next j
    endif
    if kol_ob_otkaz > 0 .and. metap == 1 .and. !is_prof_disp
      aadd(ta, '�����४⭮ ����ᠭ ��砩 ��䮮ᬮ�� � ��� ��ᯠ��ਧ�樨 - ��।������')
    endif
    if !eq_any(metap, 2, 5) // �஢�ਬ, �믮����� ��易⥫�� ��㣨 (� �������)
      for i := 1 to count_dvn_arr_usl
        s := '"' + iif(valtype(dvn_arr_usl[i, 2]) == 'C', dvn_arr_usl[i, 2] + ' ', '')
        s += dvn_arr_usl[i, 1] + '"'
        if arr1[i, 2] == 0 // �� ���� �믮�����
          if arr1[i, 1] > 1
            aadd(ta, '�� ���� �믮�����, � �믮����� ' + s)
          endif
        elseif arr1[i, 2] == 1 // ���� �믮�����
          if eq_any(arr1[i, 4], 1, 2) ;// �⪠�, ����������
                    .and. valtype(dvn_arr_usl[i, 2]) == 'C' .and. dvn_arr_usl[i, 2] == '4.1.12'
            if a_4_20_1[2] == 3
              aadd(ta, '�� ������ ���� ��㣨 "4.20.1 ��᫥������� ���⮣� �⮫����᪮�� ���ਠ��", �.�. � ��㣥 ' + s + ' �⮨� ' + {'�����', '�������������'}[arr1[i, 4]] + ' - ��।������')
            endif
          endif
          if arr1[i, 1] == 0 .and. arr1[i, 5] == 0 // ��� + ��易⥫�� ������
            if arr1[i, 4] == 2 .and. arr1[i, 3] < 2 // '����������', ࠧ��� '�⪠�'
              aadd(ta, '������� ��⠭������ "�������������" �������� ��㣨 ' + s)
            elseif arr1[i, 4] == 0 // �� �⪠�
              fl := .t.
              if valtype(dvn_arr_usl[i, 2]) == 'C'
                if dvn_arr_usl[i, 2] == '4.20.1' .and. a_4_20_1[1] < 3
                  fl := .f.
                endif
              endif
              if fl
                aadd(ta, '�� ������� ��㣠 ' + s)
              endif
            endif
          elseif arr1[i, 1] > 1
            aadd(ta, '�믮����� ����� ����� ��㣨 ' + s)
          endif
        endif
      next
      for i := 1 to count_dvn_arr_umolch
        s := '"' + dvn_arr_umolch[i, 2] + ' ' + dvn_arr_umolch[i, 1] + '"'
        if arr2[i, 2] == 0 // �� ���� �믮�����
          if arr2[i, 1] > 1
            aadd(ta, '�� ���� �믮�����, � �믮����� ' + s)
          endif
        elseif arr2[i, 2] == 1 // ���� �믮�����
          if empty(arr2[i, 1])
            aadd(ta, '��� ��㣨 ' + s)
          elseif arr2[i, 1] > 1
            aadd(ta, '����� ����� ��㣨 ' + s)
          endif
        endif
      next
    endif
    k700 := kkt := kzad := 0
    for i := 1 to len(au_lu)
      hu->(dbGoto(au_lu[i, 9]))       // 9 - ����� �����
      lshifr := alltrim(au_lu[i, 1])
      if left(lshifr, 4) == '2.3.' .and. !empty(au_lu[i, 3])
        s := '��㣠 ' + au_lu[i, 5] + '-' + inieditspr(A__MENUVERT, getV002(), au_lu[i, 3]) + '(' + date_8(au_lu[i, 2]) + ')'
      else
        s := '��㣠 ' + au_lu[i, 5] + '(' + date_8(au_lu[i, 2]) + ')'
      endif
      if au_lu[i, 3] == 0
        aadd(ta, s + ' - �� ���⠢��� ��䨫�')
      endif
      if au_lu[i, 4] == 0
        aadd(ta, s + ' - �� ���⠢���� ᯥ�-�� ���')
      endif
      if au_lu[i, 2] > d2
        aadd(ta, s + ' �� �������� � �������� ��祭��')
      endif
      if is_usluga_dvn(au_lu[i], mv, ta, metap, mpol, kod_spec_ter)
        if metap == 1 .and. empty(hu->u_cena) .and. !eq_any(left(lshifr, 5), '4.20.', '2.90.')
          ++kol_d_usl
        elseif metap == 3 .and. !(lshifr == '56.1.14')
          ++kol_d_usl
        endif
        if d1 == au_lu[i, 2]
          is_1_den := .t.
        endif
        if metap == 2
          if eq_any(lshifr, '7.2.701', '7.2.702', '7.2.703', '7.2.704', '7.2.705')
            ++kkt
          endif
          if eq_any(lshifr, '10.6.710', '10.4.701')
            ++kzad
          endif
        endif
        if !eq_any(metap, 2, 5) .and. au_lu[i, 2] < d1 .and. !eq_any(lshifr, '4.20.1', '4.20.2')
          if is_disp_19
            if year(au_lu[i, 2]) < year(d1) // ���-�� ��� ��� �⪠�� �믮����� ࠭��
              ++kol_n_date                 // ��砫� �஢������ ��ᯠ��ਧ�樨 � �� �ਭ������� ⥪�饬� �������୮�� ����
            endif
          else
            ++kol_n_date // ��⥭� ࠭�� ��������� ��㣠
          endif
        endif
        if eq_any(metap, 2, 5) .and. au_lu[i, 2] < d1
          aadd(ta, s + ' �� �������� � �������� ��祭��')
        elseif left(lshifr, 2) == '2.' .and. eq_any(au_lu[i, 3], 97, 57, 42)
          if au_lu[i, 2] != d2
            aadd(ta, s + ' - �࠯��� ������ �஢����� �ᬮ�� ��᫥����')
          endif
        elseif alltrim(au_lu[i, 1]) == '7.61.3' .and. !is_disp_19
          if eq_any(year(au_lu[i, 2]), d1_year, d1_year - 1)
            // � �祭�� �।�����饣� �������୮�� ���� ���� ���� �஢������ ��ᯠ��ਧ�樨 �஢������� ��ண���
          else
            aadd(ta, '��ண��� ������� � ������諮� �������୮� ����')
          endif
        else
          if au_lu[i, 2] < addmonth(d1, -12)
            aadd(ta, s + ' ������� ����� 1 ���� �����')
          endif
        endif
        if left(lshifr, 5) == '2.84.'
          ++kvp
        elseif eq_any(left(lshifr, 4), '2.3.', '2.90')
          ++kvp
        endif
        if d1 == au_lu[i, 2]
          is_1_den := .t.
        endif
        if d2 == au_lu[i, 2]
          is_last_den := .t.
        endif
      elseif ascan(dvn_700, {|x| x[2] == lshifr}) > 0
        ++k700 // � �㫥��� ��㣥 ��������� ��㣠 � 業�� �� '700'
      elseif eq_any(left(lshifr, 5), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.')
        ++zs
        if is_prof_disp
          s := ret_shifr_zs_DVN(3, mv, mpol, d2)
        else
          s := ret_shifr_zs_DVN(metap, mv, mpol, d2)
        endif
        if !(lshifr == s)
          aadd(ta, '� �/� ��㣠 ' + lshifr + ', � ������ ���� ' + s + ' ��� ������ ' + lstr(mv) + ' ' + s_let(mv) + '. ��।������!')
        endif
      else
        oth_usl += lshifr + ' '
      endif
    next
    if kkt > 1
      aadd(ta, 'ࠧ�蠥��� �믮����� ⮫쪮 ���� ��楤��� ७⣥����䨨� ��� �� �࣠��� ��㤭�� ���⪨')
    endif
    if kzad > 1
      aadd(ta, '�� ࠧ�蠥��� ᮢ���⭮ �ਬ����� ४�ᨣ��������᪮��� � ४�஬���᪮���')
    endif
    if ascan(ret_arr_vozrast_DVN(d2),mdvozrast) > 0
      if metap > 2
        aadd(ta, '� ' + lstr(mdvozrast) + s_let(mdvozrast) + ' �஢������ ��ᯠ��ਧ���, � �஢����� ��䨫��⨪�')
      endif
    else
      if eq_any(metap, 1, 2)
        aadd(ta, '� ' + lstr(mvozrast) + s_let(mvozrast) + ' �஢������ ��䨫��⨪�, � �஢����� ��ᯠ��ਧ���')
      endif
    endif
    do case
      case metap == 1 .or. (metap == 3 .and. is_disp_19)
        if zs > 1
          aadd(ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"')
        elseif emptyall(zs, k700) .and. !is_disp_19
          aadd(ta, '� ���� ��� ��� � 業��')
        endif
        if (i := ascan(dvn_85, {|x| x[1] == kol_d_usl })) > 0
          if is_disp_19
            k := dvn_85[i, 1] - dvn_85[i, 2]
            if kol_n_date + kol_d_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
              if zs == 0
                aadd(ta, '� ���� ��� ������ ���� ��㣠 "�����祭�� ��砩" - ��।������')
              endif
            else
              aadd(ta, '����� ��砩 �� ����� ���� ��ࠢ��� � �����, �.�. ������� ����� 85% ��� (������� � ��諮� �������୮� ����-' + lstr(kol_n_date) + ', �⪠���-' + lstr(kol_d_otkaz) + ', �ᥣ� ���뢠���� ���-' + lstr(kol_d_usl) + ')')
            endif
          else
            if (k := dvn_85[i, 1] - dvn_85[i, 2]) < kol_d_otkaz
              aadd(ta, '�⪠�� ��樥�� ��⠢���� ' + lstr(kol_d_otkaz / kol_d_usl * 100, 5, 0) + '% (������ ���� �� ����� 15%)')
              aadd(ta, '�⪠���-' + lstr(kol_d_otkaz) + ', �ᥣ� ���뢠���� ���-' + lstr(kol_d_usl))
            elseif kol_n_date + kol_d_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
              if zs == 0 .or. k700 > 0
                aadd(ta, '� ���� ��� ������ ���� ��㣠 "�����祭�� ��砩" - ��।������')
              endif
            else
              if zs > 0 .or. empty(k700)
                aadd(ta, '� ���� ��� �� ������ ���� ��㣨 "�����祭�� ��砩" - ��।������')
              endif
            endif
          endif
        else
          aadd(ta, '᫨誮� ����� �⪠���-' + lstr(kol_d_otkaz) + ' ���-' + lstr(kol_d_usl))
        endif
      case metap == 4
        if zs > 1
          aadd(ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"')
        elseif emptyall(zs, k700)
          aadd(ta, '� ���� ��� ��� ��� � 業��')
        endif
      case eq_any(metap, 2, 5)
        if zs > 0
          aadd(ta, '��� II �⠯� ��� �� ������ ���� ��� "�����祭�� ��砩"')
        endif
      case metap == 3 .and.  !is_disp_19
        if zs > 1
          aadd(ta, '� ���� ��� ����� ����� ��㣨 "�����祭�� ��砩"')
        endif
        if (i := ascan(prof_vn_85, {|x| x[1] == kol_d_usl })) > 0
          if prof_vn_85[i, 1] - prof_vn_85[i, 2] < kol_d_otkaz
            aadd(ta, '�⪠�� ��樥�� ��⠢���� ' + lstr(kol_d_otkaz / kol_d_usl * 100, 5, 0) + '% (������ ���� �� ����� 15%)')
            aadd(ta, '�⪠���-' + lstr(kol_d_otkaz) + ', �ᥣ� ���뢠���� ���-' + lstr(kol_d_usl))
          endif
        else
          aadd(ta, '᫨誮� ����� �⪠���-' + lstr(kol_d_otkaz))
        endif
    endcase
    if !empty(oth_usl)
      aadd(ta, '� ���� ��� ��� ��譨� ��㣨: ' + oth_usl)
    endif
    if !is_1_den
      //aadd(ta, '���� ��祡�� �ᬮ�� ������ ���� ������ � ���� ���� ��祭��')
    endif
    if !is_last_den
      aadd(ta, '��᫥���� ��祡�� �ᬮ�� ������ ���� ������ � ��᫥���� ���� ��祭��')
    endif
    if metap != 3 .and. eq_any(human_->RSLT_NEW, 317, 318, 355, 356)
      adiag_talon := array(16)
      for i := 1 to 16
        adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
      next
      am := {}
      for i := 1 to len(mdiagnoz)
        if !empty(mdiagnoz[i]) .and. eq_any(adiag_talon[i * 2], 1, 2)
          aadd(am, mdiagnoz[i]) // ���ᨢ ��������� � ��ᯠ��ਧ�樥�
        endif
      next
      do case
        case human_->RSLT_NEW == 317 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� I ��㯯� ���஢��'   , 1, 317}
          if !empty(am)
            aadd(ta, '��� I ��㯯� ���஢�� �� ������ ���� ��⠭������� ��ᯠ��୮�� ���� ' + print_array(am))
          endif
        case human_->RSLT_NEW == 318 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� II ��㯯� ���஢��'  , 2, 318}
          fl := .f.
          for i := 1 to len(am)
            if left(am[i], 3) == 'E78'
              fl := .t.
            else
              aadd(ta, '��� II ��㯯� ���஢�� ��ᯠ���� ���� ����� ���� ��⠭����� ⮫쪮 ��� �����宫���ਭ����, � �� ��� ' + am[i])
            endif
          next
          if fl .and. m1dispans != 3 // {'���⪮�� �࠯��⮬', 3}
            aadd(ta, '��� II ��㯯� ���஢�� "��ᯠ��୮� ������� ��⠭������" ����� ���� ⮫쪮 "���⪮�� �࠯��⮬"')
          endif
        case human_->RSLT_NEW == 355 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��', 3, 355}
          if empty(am)
            aadd(ta, '��� III� ��㯯� ���஢�� ��易⥫쭮 ������ ���� ��⠭����� ��ᯠ���� ����')
          endif
        case human_->RSLT_NEW == 356 // {'�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��', 4, 356}
          if empty(am)
            aadd(ta, '��� III� ��㯯� ���஢�� ��易⥫쭮 ������ ���� ��⠭����� ��ᯠ���� ����')
          endif
      endcase
    endif
  endif

  if is_disp_DVN_COVID
    if (human->k_data < 0d20210701)
      aadd(ta, '㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID ��砫��� � 01 ��� 2021 ����')
    endif
    m1dopo_na := 0
    m1napr_v_mo := 0 // {{'-- ��� --', 0}, {'� ���� ��', 1}, {'� ���� ��', 2}}, ;
    arr_mo_spec := {}
    m1napr_stac := 0 // {{'--- ��� ---', 0}, {'� ��樮���', 1}, {'� ��. ���.', 2}}, ;
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    is_disp_nabl := .f.
    arr_nazn := {}
    read_arr_DVN_COVID(human->kod)
  endif

  //
  // �������� ������������� ����������
  //
  if eq_any(alltrim(mdiagnoz[1]), 'U07.1', 'U07.2') .and. (count_years(human->DATE_R, human->k_data) >= 18) ;
        .and. !check_diag_pregant()
    if (human_->USL_OK == USL_OK_HOSPITAL) .and. (human->k_data >= 0d20220101)
      flLekPreparat := (human_->PROFIL != 158) .and. (human_->VIDPOM != 32) ;
          .and. (lower(alltrim(human_2->PC3)) != 'stt5')
    elseif (human_->USL_OK == USL_OK_POLYCLINIC) .and. (human->k_data >= d_01_04_2022)
      flLekPreparat := (human_->PROFIL != 158) .and. (human_->VIDPOM != 32) ;
         .and. (get_IDPC_from_V025_by_number(human_->povod) == '3.0')
    endif
  endif

  if flLekPreparat
    arrLekPreparat := collect_lek_pr(rec_human) // �롥६ ������⢥��� �९����
    if len(arrLekPreparat) == 0  // ���⮩ ᯨ᮪ ������⢥���� �९��⮢
      aadd(ta, '��� ��������� U07.1 � U07.2 ����室�� ���� ������⢥���� �९��⮢')
    else  // �� ���⮩ �஢�ਬ ���
      for each row in arrLekPreparat
        if empty(row[1])
          aadd(ta, '�� 㪠���� ��� ��ꥪ樨')
        endif
        if ! between_date(human->n_data, human->k_data, row[1])
          aadd(ta, '��� ��ꥪ樨 �� �室�� � ��ਮ� ����')
        endif
        if empty(row[2])
          aadd(ta, '����� �奬� ��祭��')
        endif
        if empty(row[8])
          aadd(ta, '����� �奬� ᮮ⢥��⢨� �९��⠬')
        endif
        if (arrGroupPrep := get_group_prep_by_kod(alltrim(row[8]), row[1])) != nil
          mMNN := iif(arrGroupPrep[3] == 1, .t., .f.)
          if mMNN
            if empty(row[3])
              aadd(ta, '��� "' + alltrim(arrGroupPrep[2]) + '" �� ��࠭ ������⢥��� �९���')
            endif
            if empty(row[4])
              aadd(ta, '��� "' + alltrim(arrGroupPrep[2]) + '" �� ��࠭� ������ ����७��')
            endif
            if empty(row[5])
              aadd(ta, '��� "' + alltrim(arrGroupPrep[2]) + '" �� ��࠭� ���� �९���')
            endif
            if empty(row[6])
              aadd(ta, '��� "' + alltrim(arrGroupPrep[2]) + '" �� ��࠭ ᯮᮡ �������� �९���')
            endif
            if empty(row[7])
              aadd(ta, '��� "' + alltrim(arrGroupPrep[2]) + '" �� ������⢮ ��ꥪ権 � ����')
            endif
          endif
        endif
      next
    endif
  endif

  //
  // �������� ����������� ���. ����������, ������ 348
  //
  // if ((substr(human_->OKATO, 1, 2) != '34') .and. (human_->USL_OK == USL_OK_HOSPITAL .or. human_->USL_OK == USL_OK_DAY_HOSPITAL)  ;
  //           .and. substr(human_->FORMA14, 1, 1) == '0')
  //   if  substr(ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS], 1, 2) == '34'
  //     aadd(ta, '��� �������� ��ᯨ⠫���樨 �����த��� ��樥�⮢ �ॡ���� ���ࠢ����� �� ����樭᪮�� ��०����� ��㣮�� ॣ����')
  //   endif
  // endif

  //
  // �������� ��� ������� ��������� Z00-Z99 � �����������
  //
  if human_->USL_OK == USL_OK_POLYCLINIC .and. between_diag(mdiagnoz[1], 'Z00', 'Z99') ;
          .and. alltrim(mdiagnoz[1]) != 'Z92.2' .and. alltrim(mdiagnoz[1]) != 'Z92.4'
    
    if lu_type == TIP_LU_STD .and. human_->RSLT_NEW != 314 .and. human_->RSLT_NEW != 308 .and. human_->RSLT_NEW != 309 ;
      .and. human_->RSLT_NEW != 311 .and. human_->RSLT_NEW != 315 .and. human_->RSLT_NEW != 305 .and. human_->RSLT_NEW != 306
      aadd(ta, '��� �������� "' + mdiagnoz[1] + '" १���� ���饭�� ������ ���� 314 ��� 308 ��� 309 ��� 311 ��� 315 ��� 305 ��� 306')
    endif
    if lu_type == TIP_LU_STD .and. human_->ISHOD_NEW != 304 .and. human_->ISHOD_NEW != 306
      aadd(ta, '��� �������� "' + mdiagnoz[1] + '" ��室 ����������� ������ ���� "304-��� ��६��" ��� "306-�ᬮ��"')
    endif

  endif

  //
  // �������� ������������� ���������
  //
  if year(human->k_data) > 2021
    for each row in arrUslugi // �஢�ਬ �� ��㣨 ����
      if service_requires_implants(row, human->k_data)
        // �஢�ਬ ����稥 ������⮢
        arrImplant := collect_implantant(human->kod)
        if ! empty(arrImplant)
          for each rowTmp in arrImplant
            if empty(rowTmp[3])
              aadd(ta, '�� 㪠���� ��� ��⠭���� ������⠭�')
            endif
            if ! between_date(human->n_data, human->k_data, rowTmp[3])
              aadd(ta, '��� ��⠭���� ������⠭� �� �室�� � ��ਮ� ����')
            endif
            if empty(rowTmp[4])
              aadd(ta, '��� ������⠭� ����室��� 㪠���� ��� ���')
            endif
            if empty(rowTmp[5])
              aadd(ta, '��� ������⠭� ����室��� 㪠���� �਩�� �����')
            endif
          next
        else
          aadd(ta, '��� ��㣨 ' + row + ' ��易⥫쭮 㪠����� ������⠭⮢')
        endif
      endif
    next
  endif

  //
  // �������� ����������� ������
  //
  if is_exist_Prescription
    if human->k_data >= 0d20210801
      checkSectionPrescription( ta )
    endif
  endif
  //

  if is_pren_diagn //
    human_->PROFIL := 106 // ���ࠧ�㪮��� �������⨪�
    if human->n_data != human->k_data
      aadd(ta, '��� ����砭�� ��祭�� ������ ᮢ������ � ��⮩ ��砫� ��祭��')
    endif
    if human->ishod != 99
      aadd(ta, '�७�⠫쭠� �������⨪� �������� �१ ᯥ樠��� �࠭ �����')
    endif
    k1 := k2 := 0 ; oth_usl := ''
    for i := 1 to len(au_lu)
      if eq_any(alltrim(au_lu[i, 1]), '2.79.51', '8.30.3')
        k1 += au_lu[i, 6]
      elseif alltrim(au_lu[i, 1]) == '4.26.6'
        k1 += au_lu[i, 6]
      elseif alltrim(au_lu[i, 1]) == '2.5.1'
        k2 += au_lu[i, 6]
      else
        oth_usl += alltrim(au_lu[i, 1]) + ' '
      endif
    next
    if k1 != 3
      aadd(ta, '� ���� ��� ����୮� ������⢮ ��易⥫��� ���')
    endif
    if k2 > 1
      aadd(ta, '� ���� ��� ������ ���� �� ����� ����� ��㣨 2.5.1')
    endif
    if !empty(oth_usl)
      aadd(ta, '� ���� ��� �७�⠫쭮� �������⨪� ��譨� ��㣨: ' + oth_usl)
    endif
  endif
  if human_->USL_OK == USL_OK_AMBULANCE .and. !(is_71_1 .or. is_71_2 .or. is_71_3)
    aadd(ta, '��� �᫮��� "����� ������" �� ������� ��㣨 ���')
  endif
  if !empty(u_1_stom)
    // ��ᬮ�� ��㣨� ��砥� ������� ���쭮��
    select HUMAN
    set order to 2
    find (str(glob_kartotek, 7))
    do while human->kod_k == glob_kartotek .and. !eof()
      if (fl := (d2_year == year(human->k_data) .and. rec_human!=human->(recno())))
        //
      endif
      if fl .and. human->schet > 0 .and. eq_any(human_->oplata, 2, 9)
        fl := .f. // ���� ���� ��� �� ���� ��� ���⠢��� ����୮
      endif
      if fl .and. m1novor != human_->NOVOR
        fl := .f. // ���� ���� �� ����஦������� (��� �������)
      endif
      if fl .and. human_->idsp == 4 // ��祡��-���������᪠� ��楤��
        select HU
        find (str(human->kod, 7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
          if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            if f_is_1_stom(lshifr)
              aadd(ta, '������� ��㣠 ��ࢨ筮�� �⮬�⮫����᪮�� ��� ' + u_1_stom + ',')
              aadd(ta, ' � � ��砥 ' + date_8(human->n_data) + '-' + date_8(human->k_data) + ' 㦥 �뫠 ������� ��㣠 ' + lshifr)
            endif
          endif
          select HU
          skip
        enddo
      endif
      select HUMAN
      skip
    enddo
    select HUMAN
    set order to 1
    human->(dbGoto(rec_human))
  endif


  if human_->oplata == 2
    aadd(ta, '������ �� ����� � �訡��� � ��� �� ��।���஢��')
  endif
  if len(arr_unit) > 1
    if select('MOUNIT') == 0
      sbase := prefixFileRefName(d2_year) + 'unit'
      R_Use(dir_exe + sbase, cur_dir + sbase, 'MOUNIT')
    endif
    s := 'ᮢ��㯭���� ��� ������ ���� �� ����� ���⭮� ������� ����, � � ������ ��砥: '
    select MOUNIT
    for i := 1 to len(arr_unit)
      find (str(arr_unit[i], 3))
      if found()
        s += alltrim(mounit->name) + ', '
      endif
    next
    aadd(ta, left(s, len(s) - 2))
  endif
  if fl_view .and. !is_s_dializ .and. !is_dializ .and. !is_perito .and. len(a_rec_ffoms) > 0 // ����� ��������
    ltip := 0
    s := ''
    i := 1
    asort(a_rec_ffoms, , , {|x, y| x[3] < y[3] })
    if gusl_ok == USL_OK_POLYCLINIC // 3 - �����������
      if is_2_78
        ltip := 1
      elseif is_2_80
        ltip := 2
      elseif is_2_88
        ltip := 3
      elseif is_2_89
        ltip := 4
      endif
      if ltip == 0
        i := 0
      else
        fl := .f.
        for i := 1 to len(a_rec_ffoms)
          select HU
          find (str(a_rec_ffoms[i, 1], 7))
          do while hu->kod == a_rec_ffoms[i, 1] .and. !eof()
            lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
            if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data)
              lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
              left_lshifr_5 := left(lshifr, 5)
              if left_lshifr_5 == '2.78.'
                if !between_shifr(lshifr, '2.78.54', '2.78.60')
                  a_rec_ffoms[i, 2] := 1
                  s := AfterAtNum('.', lshifr)
                  fl := .t.
                endif
              elseif left_lshifr_5 == '2.80.'
                if !between_shifr(lshifr, '2.80.34', '2.80.38')
                  if ltip == 2 // �᫨ ��諮� � ����� ��祭�� '2.80.'
                    a_rec_ffoms[i, 2] := 2
                    s := AfterAtNum('.', lshifr)
                    fl := .t.
                  endif
                endif
              elseif left_lshifr_5 == '2.88.'
                if !between_shifr(lshifr, '2.88.46', '2.88.51')
                  a_rec_ffoms[i, 2] := 3
                  s := AfterAtNum('.', lshifr)
                  fl := .t.
                endif
              elseif left_lshifr_5 == '2.89.'
                a_rec_ffoms[i, 2] := 4
                s := AfterAtNum('.', lshifr)
                fl := .t.
              endif
            endif
            if fl
              exit
            endif
            select HU
            skip
          enddo
          if fl
            exit
          endif
        next
        if !fl
          i := 0
        endif
      endif
    endif
    if i > 0
      select D_SROK
      append blank
      d_srok->kod   := human->kod
      d_srok->tip   := ltip
      d_srok->tips  := d_sroks
      d_srok->otd   := human->otd
      d_srok->kod1  := a_rec_ffoms[i, 1]
      d_srok->tip1  := a_rec_ffoms[i, 2]
      d_srok->tip1s := s
      d_srok->dni   := a_rec_ffoms[i, 3]
    endif
  endif
  if len(arr_unit) == 0 .and. ! lTypeLUOnkoDisp // .and. ! is_disp_DVN_COVID
    aadd(ta, '�� � ����� �� ��� �� �����㦥� ��� ����-������')
  endif
  if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
    if eq_any(human_->RSLT_NEW, 317, 321, 332, 343, 347)
      if human->OBRASHEN == '1' // �����७�� �� ���
        aadd(ta, '��ࢠ� ��㯯� �� ����� ���� ��᢮��� ��樥��� � �����७��� �� ���')
      endif
    elseif eq_any(human_->RSLT_NEW, 323, 324, 325, 334, 335, 336, 349, 350, 351, 355, 356, 373, 374, 357, 358)
      fl := !empty(arr_onkna)
      if !fl .and. m1dopo_na > 0
        fl := .t.
      endif
      if !fl .and. between(m1napr_v_mo, 1, 2) .and. !empty(arr_mo_spec)
        fl := .t.
      endif
      if !fl .and. between(m1napr_stac, 1, 2) .and. m1profil_stac > 0
        fl := .t.
      endif
      if !fl .and. m1napr_reab == 1 .and. m1profil_kojki > 0
        fl := .t.
      endif
      if !fl
        aadd(ta, '��樥�� � ��㯯�� ���஢�� ����襩 2 ������ ���� ���ࠢ��� �� ���.��᫥�������, � ᯥ樠���⠬, �� ��祭�� ��� �� ॠ�������')
      endif
    endif
  endif
  arr := {301, 305, 308, 314, 315, 317, 318, 321, 322, 323, 324, 325, 332, 333, 334, 335, 336, 343, 344, 347, 348, 349, 350, ;
          351, 353, 355, 356, 357, 358, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374}
  if human_->ISHOD_NEW == 306 .and. ascan(arr, human_->RSLT_NEW) == 0
    aadd(ta, '��� ��室� ����������� "306/�ᬮ��" �����४�� १���� ���饭�� "' + ;
      inieditspr(A__MENUVERT, getV009(), human_->RSLT_NEW) + '"')
  endif
  if !emptyany(human_->NPR_MO, human_2->NPR_DATE) .and. !empty(s := verify_dend_mo(human_->NPR_MO, human_2->NPR_DATE, .t.))
    aadd(ta, '���ࠢ���� ��: ' + s)
  endif
  //mpovod := iif(len(arr_povod) == 1, arr_povod[1, 1], 0)
  if (is_disp_DDS .or. is_disp_DVN .or. is_prof_PN) .and. ;
     (between(d2, 0d20200320, 0d20200906) .or. between(d1, 0d20200320, 0d20200906))
    aadd(ta, '��砩 �� ����� ���� ���� ࠭�� 7 ᥭ����')
  endif
  if len(ta) > 0
    _ocenka := 0
    if ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. type('old_npr_mo') == 'C'
      if !(old_npr_mo == human_->NPR_MO)
        if !(old_npr_mo == '000000')
          verify_FF(-1, .t., 80) // ����᫮��� ��ॢ�� ��࠭���
        endif
        add_string(replicate('=', 80))
        add_string('���ࠢ����� �� ��: ' + human_->NPR_MO + ' ' + ret_mo(human_->NPR_MO)[_MO_SHORT_NAME])
        add_string(replicate('=', 80))
      endif
      old_npr_mo := human_->NPR_MO
    endif
    verify_FF(80 - len(ta) - 3, .t., 80)
    add_string('')
    // add_string(header_error)

    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    add_string(fio_plus_novor() + ' ' + alltrim(human->kod_diag) + ' ' + ;
               date_8(human->n_data) + '-' + date_8(human->k_data) + ;
               ' (' + count_ymd(human->date_r, human->n_data) + ')')
    Ins_Array(ta, 1, alltrim(uch->name) + '/' + alltrim(otd->name) + '/��䨫� �� "' + ;
                   alltrim(inieditspr(A__MENUVERT, getV002(), human_->profil)) + '"')
    if human->cena_1 == 0 ; // �᫨ 業� �㫥���
        .and. eq_any(human->ishod, 201, 202) // ��ᯠ��ਧ��� ���᫮�� ��ᥫ����
      asize(ta, 1) // �⮡� �� �뢮���� �����᫥��� ��ப�
      aadd(ta, '�� ��।����� �㬬� ���� - ��।������')
    endif
    for i := 1 to len(ta)
      for j := 1 to perenos(t_arr, ta[i], 78)
        if j == 1
          add_string(iif(i == 1, ' ', '- ') + t_arr[j])
        else
          add_string(padl(alltrim(t_arr[j]), 80))
        endif
      next
    next
  else
    if is_disp_DDS .or. is_prof_PN .or. is_disp_DVN
      mpzkol := 1
    elseif ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil, 6, 34)
      mpzkol := len(au_lu) // ���-�� ��������
    endif
    if len(arr_unit) == 1
      if select('MOUNIT') == 0
        sbase := prefixFileRefName(d2_year) + 'unit'
        R_Use(dir_exe + sbase, cur_dir + sbase, 'MOUNIT')
      endif
      select MOUNIT
      find (str(arr_unit[1], 3))
      if found() .and. mounit->pz > 0
        mpztip := mounit->pz
      endif
    endif
    human_->POVOD := iif(len(arr_povod) > 0, arr_povod[1, 1], 1)
    human_->PZTIP := mpztip
    human_->PZKOL := iif(mpzkol > 0, mpzkol, 1)
  endif

  if between_shifr(alltrim_lshifr, '2.88.111', '2.88.119') .and. (human->k_data >= 0d20220201)
    arr_povod[1, 1] := 1
    human_->POVOD := arr_povod[1, 1]
  endif

  if !valid_GUID(human_->ID_PAC)
    human_->ID_PAC := mo_guid(1, human_->(recno()))
  endif
  if !valid_GUID(human_->ID_C)
    human_->ID_C := mo_guid(2, human_->(recno()))
  endif
  human_->ST_VERIFY := _ocenka // �஢�७
  if fl_view
    //dbUnLockAll()
  endif
  return (_ocenka >= 5)