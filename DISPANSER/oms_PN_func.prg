#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

** 07.02.23 
Function fget_spec_deti(k, r, c, a_spec)
  Local tmp_select := select(), i, j, as := {}, s, blk, t_arr[BR_LEN], n_file := cur_dir + 'tmpspecdeti'
  local arr_conv_V015_V021 := conversion_V015_V021()

  if !hb_fileExists(n_file + sdbf)
    if select('MOSPEC') == 0
      R_Use(dir_exe() + '_mo_spec', cur_dir + '_mo_spec', 'MOSPEC')
      //index on shifr+str(vzros_reb, 1)+str(prvs_new, 4) to (sbase)
    endif
    select MOSPEC
    find ('2.')
    do while left(mospec->shifr, 2) == '2.' .and. !eof()
      if mospec->vzros_reb == 1 // ���
        if ascan(as, mospec->prvs_new) == 0
          aadd(as, mospec->prvs_new)
        endif
      endif
      skip
    enddo
    if select('MOSPEC') > 0
      mospec->(dbCloseArea())
    endif
    for i := 1 to len(as)
      if (j := ascan(arr_conv_V015_V021,{|x| x[2] == as[i]})) > 0 // ��ॢ�� �� 21-�� �ࠢ�筨��
        as[i] := arr_conv_V015_V021[j, 1]                          // � 15-� �ࠢ�筨�
      endif
    next
    dbcreate(n_file, {{'name', 'C', 30, 0}, ;
                   {'kod', 'C', 4, 0}, ;
                   {'kod_up', 'C', 4, 0}, ;
                   {'name1', 'C', 50, 0}, ;
                   {'is', 'L', 1, 0}})
    use (n_file) new alias SDVN
    use (cur_dir + 'tmp_v015') index (cur_dir + 'tmpkV015') new alias tmp_ga
    go top
    do while !eof()
      if (i := ascan(as, int(val(tmp_ga->kod)))) > 0
        select SDVN
        append blank
        sdvn->name := afteratnum('.', tmp_ga->name, 1)
        sdvn->kod := tmp_ga->kod
        s := ''
        select TMP_GA
        rec := recno()
        do while !empty(tmp_ga->kod_up)
          find (tmp_ga->kod_up)
          if found()
            s += alltrim(afteratnum('.', tmp_ga->name, 1)) + '/'
          else
            exit
          endif
        enddo
        goto (rec)
        sdvn->name1 := s
      endif
      skip
    enddo
    sdvn->(dbCloseArea())
    tmp_ga->(dbCloseArea())
  endif
  use (n_file) new alias tmp_ga
  do while !eof()
    tmp_ga->is := (ascan(a_spec, int(val(tmp_ga->kod))) > 0)
    skip
  enddo
  index on upper(name) + kod to (n_file)
  if r <= maxrow() / 2
    t_arr[BR_TOP] := r + 1
    t_arr[BR_BOTTOM] := maxrow() - 2
  else
    t_arr[BR_BOTTOM] := r - 1
    t_arr[BR_TOP] := 2
  endif
  blk := {|| iif(tmp_ga->is, {1, 2}, {3, 4})}
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'�', '�', '�', 'N/BG, W+/N, B/BG, W+/B', .f.}
  t_arr[BR_COLUMN] := { ;
        {' ', {|| iif(tmp_ga->is, '', ' ')}, blk}, ;
        {'���', {|| left(tmp_ga->kod, 3)}, blk}, ;
        {center('����樭᪠� ᯥ樠�쭮���', 26), {|| padr(tmp_ga->name, 26)}, blk }, ;
        {center('���稭����', 45), {|| left(tmp_ga->name1, 45)}, blk} ;
      }
  t_arr[BR_EDIT] := {|nk, ob| f1get_spec_DVN(nk, ob, 'edit')}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - ��室;  ^<Ins>^ - �⬥��� ᯥ樠�쭮���/���� �⬥�� � ᯥ樠�쭮��')}
  go top
  edit_browse(t_arr)
  s := ''
  asize(a_spec, 0)
  go top
  do while !eof()
    if tmp_ga->is
      s += alltrim(tmp_ga->kod) + ','
      aadd(a_spec, int(val(tmp_ga->kod)))
    endif
    skip
  enddo
  if empty(s)
    s := '---'
  else
    s := left(s, len(s) - 1)
  endif
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  return {1, s}

** 05.09.21
Function save_arr_PN(lkod)
  Local arr := {}, k, ta
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","TPERS") 
  endif

  Private mvar
  if type("mfio") == "C"
    aadd(arr,{"mfio",alltrim(mfio)})
  endif
  if type("mdate_r") == "D"
    aadd(arr,{"mdate_r",mdate_r})
  endif
  aadd(arr,{"0",m1mobilbr})   // "N",�����쭠� �ਣ���
  aadd(arr,{"1",mperiod}) // "N",����� ��������� (�� 1 �� 33)
  aadd(arr,{"2",m1mesto_prov})   // "N",���� �஢������
  aadd(arr,{"5",m1kateg_uch}) // "N",��⥣��� ��� ॡ����: 0-ॡ����-���; 1-ॡ����, ��⠢訩�� ��� ����祭�� த�⥫��; 2-ॡ����, ��室�騩�� � ��㤭�� ��������� ���樨, 3-��� ��⥣�ਨ
  aadd(arr,{"6",m1MO_PR}) // "C6",��� �� �ਪ९�����
  aadd(arr,{"8",m1school}) // "N6",��� ��ࠧ���⥫쭮�� ��०�����
  aadd(arr,{"12.1",mWEIGHT})  // "N3",��� � ��
  aadd(arr,{"12.2",mHEIGHT})  // "N3",��� � �
  aadd(arr,{"12.3",mPER_HEAD})  // "N3",���㦭���� ������ � �
  aadd(arr,{"12.4",m1FIZ_RAZV})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  aadd(arr,{"12.4.2",m1FIZ_RAZV2})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  if mdvozrast < 5
    aadd(arr,{"13.1.1",m1psih11})  // "N1",�������⥫쭠� �㭪�� (������ ࠧ����)
    aadd(arr,{"13.1.2",m1psih12})  // "N1",���ୠ� �㭪�� (������ ࠧ����)
    aadd(arr,{"13.1.3",m1psih13})  // "N1",���樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����)
    aadd(arr,{"13.1.4",m1psih14})  // "N1",�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����)
  else
    aadd(arr,{"13.2.1",m1psih21})  // "N1",��宬��ୠ� ���: (��ଠ, �⪫������)
    aadd(arr,{"13.2.2",m1psih22})  // "N1",��⥫����: (��ଠ, �⪫������)
    aadd(arr,{"13.2.3",m1psih23})  // "N1",���樮���쭮-�����⨢��� ���: (��ଠ, �⪫������)
  endif
  if mpol == "�"
    aadd(arr,{"14.1.P"  ,m141p})     // "N1",������� ��㫠 ����稪�
    aadd(arr,{"14.1.Ax" ,m141ax})   // "N1",������� ��㫠 ����稪�
    aadd(arr,{"14.1.Fa" ,m141fa})   // "N1",������� ��㫠 ����稪�
  else
    aadd(arr,{"14.2.P"  ,m142p})     // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Ax" ,m142ax})   // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Ma" ,m142ma})   // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Me" ,m142me})   // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Me1",m142me1}) // "N2",������� ��㫠 ����窨 - menarhe (���)
    aadd(arr,{"14.2.Me2",m142me2}) // "N2",������� ��㫠 ����窨 - menarhe (����楢)
    aadd(arr,{"14.2.Me3",m1142me3}) // "N1",������� ��㫠 ����窨 - menses (�ࠪ���⨪�): ॣ����, ��ॣ����, ������, 㬥७��, �㤭�, ���������� � �������������
    aadd(arr,{"14.2.Me4",m1142me4}) // "N1",������� ��㫠 ����窨 - menses (�ࠪ���⨪�): ॣ����, ��ॣ����, ������, 㬥७��, �㤭�, ���������� � �������������
    aadd(arr,{"14.2.Me5",m1142me5}) // "N1",������� ��㫠 ����窨 - menses (�ࠪ���⨪�): ॣ����, ��ॣ����, ������, 㬥७��, �㤭�, ���������� � �������������
  endif
  aadd(arr,{"15.1",m1diag_15_1}) // "N1",����ﭨ� ���஢�� �� �஢������ ��ᯠ��ਧ�樨-�ࠪ��᪨ ���஢
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_1_1)
    ta := {mdiag_15_1_1}
    for k := 2 to 14
      mvar := "m1diag_15_1_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.2", ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_2_1)
    ta := {mdiag_15_2_1}
    for k := 2 to 14
      mvar := "m1diag_15_2_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.3", ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_3_1)
    ta := {mdiag_15_3_1}
    for k := 2 to 14
      mvar := "m1diag_15_3_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.4", ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_4_1)
    ta := {mdiag_15_4_1}
    for k := 2 to 14
      mvar := "m1diag_15_4_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.5", ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_5_1)
    ta := {mdiag_15_5_1}
    for k := 2 to 14
      mvar := "m1diag_15_5_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.6", ta})
  endif
  aadd(arr,{"15.9",mGRUPPA_DO}) // "N1",��㯯� ���஢�� �� ���-��
  aadd(arr,{"15.10",m1GR_FIZ_DO})  // "N1",��㯯� ���஢�� ��� 䨧�������
  aadd(arr,{"16.1",m1diag_16_1}) // "N1",����ﭨ� ���஢�� �� १���⠬ �஢������ ��ᯠ��ਧ�樨 (�ࠪ��᪨ ���஢)
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_1_1)
    ta := {mdiag_16_1_1}
    for k := 2 to 16
      mvar := "m1diag_16_1_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.2", ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_2_1)
    ta := {mdiag_16_2_1}
    for k := 2 to 16
      mvar := "m1diag_16_2_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.3", ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_3_1)
    ta := {mdiag_16_3_1}
    for k := 2 to 16
      mvar := "m1diag_16_3_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.4", ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_4_1)
    ta := {mdiag_16_4_1}
    for k := 2 to 16
      mvar := "m1diag_16_4_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.5", ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_5_1)
    ta := {mdiag_16_5_1}
    for k := 2 to 16
      mvar := "m1diag_16_5_" + lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.6", ta})
  endif
  if m1invalid1 == 1
    ta := {m1invalid1,m1invalid2,minvalid3,minvalid4,m1invalid5,m1invalid6,minvalid7,m1invalid8}
    aadd(arr,{"16.7", ta})   // ���ᨢ �� 8
  endif
  aadd(arr,{"16.8",mGRUPPA})    // "N1",��㯯� ���஢�� ��᫥ ���-��
  aadd(arr,{"16.9",m1GR_FIZ})    // "N1",��㯯� ���஢�� ��� 䨧�������
  if m1privivki1 > 0
    ta := {m1privivki1,m1privivki2,mprivivki3}
    aadd(arr,{"16.10", ta})  // ���ᨢ �� 4,�஢������ ��䨫����᪨� �ਢ����
  endif
  if !empty(mrek_form)
    aadd(arr,{"16.11",alltrim(mrek_form)}) // ���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன
  endif
  if !empty(mrek_disp)
    aadd(arr,{"16.12",alltrim(mrek_disp)}) // ���������樨 �� ��ᯠ��୮�� �������, ��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ �������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� (��������) ���
  endif
  // 18.१����� �஢������ ��᫥�������
  for i := 1 to count_pn_arr_iss
    mvar := "MREZi" + lstr(i)
    if !empty(&mvar)
      aadd(arr,{"18." + lstr(i),alltrim(&mvar)})
    endif
  next
  if !empty(arr_usl_otkaz)
    aadd(arr,{"29",arr_usl_otkaz}) // ���ᨢ
  endif
  if mk_data >= 0d20210801
    if mtab_v_dopo_na != 0
      if TPERS->(dbSeek(str(mtab_v_dopo_na, 5)))
        aadd(arr,{"47",{m1dopo_na, TPERS->kod}})
      else
        aadd(arr,{"47",{m1dopo_na, 0}})
      endif
    else
      aadd(arr,{"47",{m1dopo_na, 0}})
    endif
  else
    aadd(arr,{"47",m1dopo_na})
  endif
  if type("m1p_otk") == "N"
    aadd(arr,{"51",m1p_otk})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_v_mo") == "N"
      if mtab_v_mo != 0
        if TPERS->(dbSeek(str(mtab_v_mo, 5)))
          aadd(arr,{"52",{m1napr_v_mo, TPERS->kod}})
        else
          aadd(arr,{"52",{m1napr_v_mo, 0}})
        endif
      else
        aadd(arr,{"52",{m1napr_v_mo, 0}})
      endif
    endif
  else
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",m1napr_v_mo})
    endif
  endif
  if type("arr_mo_spec") == "A" .and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // ���ᨢ
  endif
  if mk_data >= 0d20210801
    if type("m1napr_stac") == "N"
      if mtab_v_stac != 0
        if TPERS->(dbSeek(str(mtab_v_stac, 5)))
          aadd(arr,{"54",{m1napr_stac, TPERS->kod}})
        else
          aadd(arr,{"54",{m1napr_stac, 0}})
        endif
      else
        aadd(arr,{"54",{m1napr_stac, 0}})
      endif
    endif
  else
    if type("m1napr_stac") == "N"
      aadd(arr,{"54",m1napr_stac})
    endif
  endif
  if type("m1profil_stac") == "N"
    aadd(arr,{"55",m1profil_stac})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_reab") == "N"
      if mtab_v_reab != 0
        if TPERS->(dbSeek(str(mtab_v_reab, 5)))
          aadd(arr,{"56",{m1napr_reab, TPERS->kod}})
        else
          aadd(arr,{"56",{m1napr_reab, 0}})
        endif
      else
        aadd(arr,{"56",{m1napr_reab, 0}})
      endif
    endif
  else
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",m1napr_reab})
    endif
  endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  save_arr_DISPANS(lkod,arr)
  return NIL
  
***** 05.09.21
Function read_arr_PN(lkod,is_all)
  Local arr, i, k
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",,"TPERS") 
  endif

  DEFAULT is_all TO .t.
  Private mvar
  arr := read_arr_DISPANS(lkod)
  for i := 1 to len(arr)
    if valtype(arr[i]) == "A" .and. valtype(arr[i, 1]) == "C"
      if arr[i, 1] == "1" .and. valtype(arr[i, 2]) == "N"
        mperiod := arr[i, 2]
      elseif is_all
        do case
          case arr[i, 1] == "0" .and. valtype(arr[i, 2]) == "N"
            m1mobilbr := arr[i, 2]
          case arr[i, 1] == "2" .and. valtype(arr[i, 2]) == "N"
            m1mesto_prov := arr[i, 2]
          case arr[i, 1] == "5" .and. valtype(arr[i, 2]) == "N"
            m1kateg_uch := arr[i, 2]
          case arr[i, 1] == "6" .and. valtype(arr[i, 2]) == "C"
            m1MO_PR := arr[i, 2]
          case arr[i, 1] == "8" .and. valtype(arr[i, 2]) == "N"
            m1school := arr[i, 2]
          case arr[i, 1] == "12.1" .and. valtype(arr[i, 2]) == "N"
            mWEIGHT := arr[i, 2]
          case arr[i, 1] == "12.2" .and. valtype(arr[i, 2]) == "N"
            mHEIGHT := arr[i, 2]
          case arr[i, 1] == "12.3" .and. valtype(arr[i, 2]) == "N"
            mPER_HEAD := arr[i, 2]
          case arr[i, 1] == "12.4" .and. valtype(arr[i, 2]) == "N"
            m1FIZ_RAZV := arr[i, 2]
          case arr[i, 1] == "12.4.1" .and. valtype(arr[i, 2]) == "N"
            m1FIZ_RAZV1 := arr[i, 2]
          case arr[i, 1] == "12.4.2" .and. valtype(arr[i, 2]) == "N"
            m1FIZ_RAZV2 := arr[i, 2]
          case arr[i, 1] == "13.1.1" .and. valtype(arr[i, 2]) == "N"
            m1psih11 := arr[i, 2]
          case arr[i, 1] == "13.1.2" .and. valtype(arr[i, 2]) == "N"
            m1psih12 := arr[i, 2]
          case arr[i, 1] == "13.1.3" .and. valtype(arr[i, 2]) == "N"
            m1psih13 := arr[i, 2]
          case arr[i, 1] == "13.1.4" .and. valtype(arr[i, 2]) == "N"
            m1psih14 := arr[i, 2]
          case arr[i, 1] == "13.2.1" .and. valtype(arr[i, 2]) == "N"
            m1psih21 := arr[i, 2]
          case arr[i, 1] == "13.2.2" .and. valtype(arr[i, 2]) == "N"
            m1psih22 := arr[i, 2]
          case arr[i, 1] == "13.2.3" .and. valtype(arr[i, 2]) == "N"
            m1psih23 := arr[i, 2]
          case arr[i, 1] == "14.1.P" .and. valtype(arr[i, 2]) == "N"
            m141p := arr[i, 2]
          case arr[i, 1] == "14.1.Ax" .and. valtype(arr[i, 2]) == "N"
            m141ax := arr[i, 2]
          case arr[i, 1] == "14.1.Fa" .and. valtype(arr[i, 2]) == "N"
            m141fa := arr[i, 2]
          case arr[i, 1] == "14.2.P" .and. valtype(arr[i, 2]) == "N"
            m142p := arr[i, 2]
          case arr[i, 1] == "14.2.Ax" .and. valtype(arr[i, 2]) == "N"
            m142ax := arr[i, 2]
          case arr[i, 1] == "14.2.Ma" .and. valtype(arr[i, 2]) == "N"
            m142ma := arr[i, 2]
          case arr[i, 1] == "14.2.Me" .and. valtype(arr[i, 2]) == "N"
            m142me := arr[i, 2]
          case arr[i, 1] == "14.2.Me1" .and. valtype(arr[i, 2]) == "N"
            m142me1 := arr[i, 2]
          case arr[i, 1] == "14.2.Me2" .and. valtype(arr[i, 2]) == "N"
            m142me2 := arr[i, 2]
          case arr[i, 1] == "14.2.Me3" .and. valtype(arr[i, 2]) == "N"
            m1142me3 := arr[i, 2]
          case arr[i, 1] == "14.2.Me4" .and. valtype(arr[i, 2]) == "N"
            m1142me4 := arr[i, 2]
          case arr[i, 1] == "14.2.Me5" .and. valtype(arr[i, 2]) == "N"
            m1142me5 := arr[i, 2]
          case arr[i, 1] == "15.1" .and. valtype(arr[i, 2]) == "N"
            m1diag_15_1 := arr[i, 2]
          case arr[i, 1] == "15.2" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 14
            mdiag_15_1_1 := arr[i, 2, 1]
            for k := 2 to 14
              if len(arr[i, 2]) >= k
                mvar := "m1diag_15_1_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "15.3" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 14
            mdiag_15_2_1 := arr[i, 2, 1]
            for k := 2 to 14
              if len(arr[i, 2]) >= k
                mvar := "m1diag_15_2_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "15.4" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 14
            mdiag_15_3_1 := arr[i, 2, 1]
            for k := 2 to 14
              if len(arr[i, 2]) >= k
                mvar := "m1diag_15_3_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "15.5" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 14
            mdiag_15_4_1 := arr[i, 2, 1]
            for k := 2 to 14
              if len(arr[i, 2]) >= k
                mvar := "m1diag_15_4_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "15.6" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 14
            mdiag_15_5_1 := arr[i, 2, 1]
            for k := 2 to 14
              if len(arr[i, 2]) >= k
                mvar := "m1diag_15_5_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "15.9" .and. valtype(arr[i, 2]) == "N"
            mGRUPPA_DO := arr[i, 2]
          case arr[i, 1] == "15.10" .and. valtype(arr[i, 2]) == "N"
            m1GR_FIZ_DO := arr[i, 2]
          case arr[i, 1] == "16.1" .and. valtype(arr[i, 2]) == "N"
            m1diag_16_1 := arr[i, 2]
          case arr[i, 1] == "16.2" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 16
            mdiag_16_1_1 := arr[i, 2, 1]
            for k := 2 to 16
              if len(arr[i, 2]) >= k
                mvar := "m1diag_16_1_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "16.3" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 16
            mdiag_16_2_1 := arr[i, 2, 1]
            for k := 2 to 16
              if len(arr[i, 2]) >= k
                mvar := "m1diag_16_2_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "16.4" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 16
            mdiag_16_3_1 := arr[i, 2, 1]
            for k := 2 to 16
              if len(arr[i, 2]) >= k
                mvar := "m1diag_16_3_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "16.5" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 16
            mdiag_16_4_1 := arr[i, 2, 1]
            for k := 2 to 16
              if len(arr[i, 2]) >= k
                mvar := "m1diag_16_4_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "16.6" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 16
            mdiag_16_5_1 := arr[i, 2, 1]
            for k := 2 to 16
              if len(arr[i, 2]) >= k
                mvar := "m1diag_16_5_" + lstr(k)
                &mvar := arr[i, 2,k]
              endif
            next
          case arr[i, 1] == "16.7" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 8
            m1invalid1 := arr[i, 2, 1]
            m1invalid2 := arr[i, 2, 2]
            minvalid3  := arr[i, 2, 3]
            minvalid4  := arr[i, 2, 4]
            m1invalid5 := arr[i, 2, 5]
            m1invalid6 := arr[i, 2, 6]
            minvalid7  := arr[i, 2, 7]
            m1invalid8 := arr[i, 2, 8]
          case arr[i, 1] == "16.8" .and. valtype(arr[i, 2]) == "N"
            //mGRUPPA := arr[i, 2]
          case arr[i, 1] == "16.9" .and. valtype(arr[i, 2]) == "N"
            m1GR_FIZ := arr[i, 2]
          case arr[i, 1] == "16.10" .and. valtype(arr[i, 2]) == "A" .and. len(arr[i, 2]) >= 3
            m1privivki1 := arr[i, 2, 1]
            m1privivki2 := arr[i, 2, 2]
            mprivivki3  := arr[i, 2, 3]
          case arr[i, 1] == "16.11" .and. valtype(arr[i, 2]) == "C"
            mrek_form := padr(arr[i, 2],255)
          case arr[i, 1] == "16.12" .and. valtype(arr[i, 2]) == "C"
            mrek_disp := padr(arr[i, 2],255)
          case is_all .and. arr[i, 1] == "29" .and. valtype(arr[i, 2]) == "A"
            arr_usl_otkaz := arr[i, 2]
          case arr[i, 1] == "47"
            if valtype(arr[i, 2]) == "N"
              m1dopo_na  := arr[i, 2]
            elseif valtype(arr[i, 2]) == "A"
              m1dopo_na  := arr[i, 2][1]
              if arr[i, 2][2] > 0
                TPERS->(dbGoto(arr[i, 2][2]))
                mtab_v_dopo_na := TPERS->tab_nom
              endif
            endif
          case arr[i, 1] == "51" .and. valtype(arr[i, 2]) == "N"
            m1p_otk  := arr[i, 2]
          case arr[i, 1] == "52" 
            if valtype(arr[i, 2]) == "N"
              m1napr_v_mo  := arr[i, 2]
            elseif valtype(arr[i, 2]) == "A"
              m1napr_v_mo  := arr[i, 2][1]
              if arr[i, 2][2] > 0
                TPERS->(dbGoto(arr[i, 2][2]))
                mtab_v_mo := TPERS->tab_nom
              endif
            endif
          case arr[i, 1] == "53" .and. valtype(arr[i, 2]) == "A"
            arr_mo_spec := arr[i, 2]
          case arr[i, 1] == "54"
            if valtype(arr[i, 2]) == "N"
              m1napr_stac := arr[i, 2]
            elseif valtype(arr[i, 2]) == "A"
              m1napr_stac := arr[i, 2][1]
              if arr[i, 2][2] > 0
                TPERS->(dbGoto(arr[i, 2][2]))
                mtab_v_stac := TPERS->tab_nom
              endif
            endif
          case arr[i, 1] == "55" .and. valtype(arr[i, 2]) == "N"
            m1profil_stac := arr[i, 2]
          case arr[i, 1] == "56"
            if valtype(arr[i, 2]) == "N"
              m1napr_reab := arr[i, 2]
            elseif valtype(arr[i, 2]) == "A"
              m1napr_reab := arr[i, 2][1]
              if arr[i, 2][2] > 0
                TPERS->(dbGoto(arr[i, 2][2]))
                mtab_v_reab := TPERS->tab_nom
              endif
            endif
          case arr[i, 1] == "57" .and. valtype(arr[i, 2]) == "N"
            m1profil_kojki := arr[i, 2]
          otherwise
            for k := 1 to count_pn_arr_iss
              if arr[i, 1] == "18." + lstr(k) .and. valtype(arr[i, 2]) == "C"
                mvar := "MREZi" + lstr(k)
                &mvar := padr(arr[i, 2],17)
              endif
            next
        endcase
      endif
    endif
  next

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  return NIL
  