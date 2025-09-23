#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 29.02.24
function arr_NO_YES()

  return { { '���', 0 }, { '�� ', 1 } }

// 20.02.24 �ନ஢���� ���ᨢ� � ᬥ�� ��樥��
function arr_patient_died_during_treatment( mkod_k, loc_kod )
  // mkod_k - ��� ��樥�� �� �� ����⥪� kartotek.dbf
  // Loc_kod - ��� �� �� human.dbf (�᫨ = 0 - ���������� ���� ���)
  // ������ ���� ������ 䠩�� HUMAN.DBF � HUMAN_.DBF � ����� ����
  // ��⠭����� relation
  // ⥪�騩 alias ������ ���� HUMAN

  local a_smert := {}

  find ( Str( mkod_k, 7 ) )
  Do While human->kod_k == mkod_k .and. !Eof()
    If RecNo() != loc_kod .and. is_death( human_->RSLT_NEW ) .and. ;
        human_->oplata != 9 .and. human_->NOVOR == 0
      a_smert := { '����� ���쭮� 㬥�!', ;
        '��祭�� � ' + full_date( human->N_DATA ) + ' �� ' + full_date( human->K_DATA ) }
      Exit
    Endif
    Skip
  Enddo 
  return a_smert

// 26.05.22 �஢�ઠ �� ᮮ⢥��⢨� ��㣨 ��䨫�
Function UslugaAccordanceProfil(lshifr, lvzros_reb, lprofil, ta, short_shifr)

  Local s := '', s1 := ''

  if valtype(short_shifr) == 'C' .and. !empty(short_shifr) .and. !(alltrim(lshifr) == alltrim(short_shifr))
    s1 := '(' + alltrim(short_shifr) + ')'
  endif
  if select('MOPROF') == 0
    R_Use(dir_exe() + '_mo_prof', cur_dir() + '_mo_prof', 'MOPROF')
  endif
  lshifr := padr(lshifr, 20)
  lvzros_reb := iif(lvzros_reb == 0, 0, 1)
  select MOPROF
  find (lshifr)
  if found() // �᫨ ������ ��㣠 ������ � �஢�થ �� ��䨫�
    find (lshifr + str(lvzros_reb, 1) + str(lprofil, 3))
    if !found()
      find (lshifr + str(lvzros_reb, 1))
      if human_->USL_OK == 4  // �᫨ ᪮�� ������
        if found()                // � ��諨 ���� �����訩�� ��䨫�,
          lprofil := moprof->profil // � �����塞 ��� ��直� ᮮ�饭��
        endif
      else // ��� ��� ��⠫��� �᫮��� �ନ�㥬 ᮮ�饭�� �� �訡��
        do while moprof->shifr==lshifr .and. moprof->vzros_reb == lvzros_reb .and. !eof()
          s += '"' + lstr(moprof->profil) + '.' + inieditspr(A__MENUVERT, getV002(), moprof->profil) + '", '
          skip
        enddo
        aadd(ta, rtrim(lshifr) + s1 + ' - ��䨫� "' + lstr(lprofil) + '.' + ;
                  inieditspr(A__MENUVERT, getV002(), lprofil) + ;
                  '" ��� ' + {'���᫮��', 'ॡ񭪠'}[lvzros_reb + 1] + ;
                  ' �������⨬' + iif(empty(s), '', ' (ࠧ�蠥��� ' + left(s, len(s) - 2) + ')'))
      endif
    endif
  endif
  return lprofil
  
// 12.02.23 �஢�ઠ �� ᮮ⢥��⢨� ��㣨 ᯥ樠�쭮��
Function UslugaAccordancePRVS(lshifr, lvzros_reb, lprvs, ta, short_shifr, lvrach)

  Local s := '', s1 := '', s2, k
  local arr_conv_V015_V021 := conversion_V015_V021()

  if valtype(short_shifr) == 'C' .and. !empty(short_shifr) .and. !(alltrim(lshifr) == alltrim(short_shifr))
    s1 := '(' + alltrim(short_shifr) + ')'
  endif
  if select('MOSPEC') == 0
    R_Use(dir_exe() + '_mo_spec', cur_dir() + '_mo_spec', 'MOSPEC')
  endif
  lshifr := padr(lshifr, 20)
  lvzros_reb := iif(lvzros_reb == 0, 0, 1)
  if lprvs < 0
    k := abs(lprvs)
  else
    k := ret_V004_V015(lprvs)
  endif
  s2 := lstr(k) + '.' + inieditspr(A__MENUVERT, getV015(), k)
  //
  lprvs := ret_prvs_V021(lprvs)
  select MOSPEC
  find (lshifr)
  if found() // �᫨ ������ ��㣠 ������ � �஢�થ �� ᯥ樠�쭮��
    find (lshifr + str(lvzros_reb, 1) + str(lprvs, 6))
    if !found()
      find (lshifr + str(lvzros_reb, 1))
      // �ନ�㥬 ᮮ�饭�� �� �訡��
      do while mospec->shifr==lshifr .and. mospec->vzros_reb == lvzros_reb .and. !eof()
        k := mospec->prvs_new
        // if (i := ascan(arr_conv_V015_V021, {|x| x[2] == k})) > 0 // ��ॢ�� �� 21-�� �ࠢ�筨��
        //   k := arr_conv_V015_V021[i, 1]                          // � 15-� �ࠢ�筨�
        // endif
        // s += '"' + lstr(k) + '.' + inieditspr(A__MENUVERT, getV015(), k) + '", '
        s += '"' + inieditspr(A__MENUVERT, getV021(), k) + '", '
        skip
      enddo
      pers->(dbGoto(lvrach))
      aadd(ta, rtrim(lshifr) + s1 + ' - (' + fam_i_o(pers->fio) + ' [' + lstr(pers->tab_nom) + ;
              ']) ᯥ樠�쭮��� "' + s2 + '" ��� ' + {'���᫮��', 'ॡ񭪠'}[lvzros_reb + 1] + ;
              ' �������⨬�' + iif(empty(s), '', ' (ࠧ�蠥��� ' + left(s, len(s) - 2) + ')'))
    endif
  endif
  return nil
  
// 07.06.24 ᮡ��� ���� ��� � ��砥
function collect_uslugi( rec_number )

  local human_number, human_uslugi, mohu_usluga
  local tmp_select := select()
  local arrUslugi := {}

  human_number := hb_DefaultValue( rec_number, human->( recno() ) )
  human_uslugi := hu->( recno() )
  mohu_usluga := mohu->( recno() )
  dbSelectArea( 'HU' )

  find ( str( human_number, 7 ) )
  do while hu->kod == human_number .and. ! eof()
    aadd( arrUslugi, alltrim( usl->shifr ) )
    hu->( dbSkip() )
  enddo

  hu->( dbGoto( human_uslugi ) )

  dbSelectArea( 'MOHU' )
  set relation to u_kod into MOSU
  find ( str( human_number, 7 ) )
  do while mohu->kod == human_number .and. ! eof()
    aadd( arrUslugi, alltrim( iif( empty( mosu->shifr ), mosu->shifr1, mosu->shifr ) ) )
    mohu->( dbSkip() )
  enddo
  mohu->( dbGoto( mohu_usluga ) )

  select( tmp_select )
  return arrUslugi

// 07.06.24 ᮡ��� ���� �������� ��� � ��砥
function collect_date_uslugi( rec_number )

  local human_number, human_uslugi, mohu_usluga
  local tmp_select := select()
  local arrDate := {}, aSortDate
  local i := 0, sDate, dDate

  human_number := hb_DefaultValue( rec_number, human->( recno() ) )
  human_uslugi := hu->( recno() )
  mohu_usluga := mohu->( recno() )
  dbSelectArea( 'HU' )

  find ( str( human_number, 7 ) )
  do while hu->kod == human_number .and. ! eof()
    dDate := c4tod( hu->date_u )
    sDate := dtoc( dDate )
    if ascan( arrDate, { | x | x[ 1 ] == sDate } ) == 0
      i++
      aadd( arrDate, { sDate, i, dDate } )
    endif
    hu->( dbSkip() )
  enddo

  hu->( dbGoto( human_uslugi ) )

  dbSelectArea( 'MOHU' )
  // set relation to u_kod into MOSU
  find ( str(human_number, 7 ) )
  do while mohu->kod == human_number .and. ! eof()
    dDate := c4tod( mohu->date_u )
    sDate := dtoc( dDate )
    if ascan( arrDate, { | x | x[ 1 ] == sDate } ) == 0
      i++
      aadd( arrDate, { sDate, i, dDate } )
    endif
    mohu->( dbSkip() )
  enddo
  mohu->( dbGoto( mohu_usluga ) )

  aSortDate := ASort( arrDate, , , { | x, y | x[ 3 ] < y[ 3 ] } )  
  select( tmp_select )
  return aSortDate

// 20.06.19
Function is_usluga_dvn(ausl, _vozrast, arr, _etap, _pol, _spec_ter)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, j, s, fl := .f., as, lshifr := alltrim(ausl[1]), fl_19

  fl_19 := (type('is_disp_19') == 'L' .and. is_disp_19)
  if !fl_19 .and. ((lshifr == '2.3.3' .and. ausl[3] == 3) .or. ; // �����᪮�� ����
                  (lshifr == '2.3.1' .and. ausl[3] == 136))   // �������� � �����������
      //.and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
    if ((lshifr == '2.3.3' .and. eq_any(ret_old_prvs(ausl[4]), 2003, 2002)) .or. ;
      (lshifr == '2.3.1' .and. ret_old_prvs(ausl[4]) == 1101))
    else
      aadd(arr, '�� � ᯥ樠�쭮��� ��� � ��砥 ������������ �ᯮ�짮����� ��㣨:')
      aadd(arr, ' "4.1.12.�ᬮ�� ����મ�, ���⨥ ����� (�᪮��)"')
    endif
    fl := .t.
  endif
  if !fl
    for i := 1 to count_dvn_arr_umolch
      if dvn_arr_umolch[i, 2] == lshifr
        fl := .t.
        exit
      endif
    next
  endif
  if !fl
    DEFAULT _spec_ter to 0
    for i := 1 to count_dvn_arr_usl
      if valtype(dvn_arr_usl[i, 2]) == 'C'
        if dvn_arr_usl[i, 2] == '4.20.1' .and. lshifr == '4.20.2'
          fl := .t.
        elseif dvn_arr_usl[i, 2] == lshifr
          fl := .t.
        endif
      endif
      if !fl .and. len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i, 12]) == 'A'
        if ascan(dvn_arr_usl[i, 12], {|x| x[1] == lshifr .and. x[2] == ausl[3]}) > 0
          fl := .t.
        endif
      endif
      if fl
        s := '"' + lshifr + '.' + dvn_arr_usl[i, 1] + '"'
        if eq_any(_etap, 1, 4, 5)
          j := iif(_pol == '�', 6, 7)
          if _etap > 1 .and. len(dvn_arr_usl[i]) > 12
            j := iif(_pol == '�', 13, 14)
          endif
          if valtype(dvn_arr_usl[i, j]) == 'N'
            if dvn_arr_usl[i, j] == 0
              aadd(arr, '��ᮢ���⨬���� �� ���� � ��㣥 ' + s)
            endif
          else
            if ascan(dvn_arr_usl[i, j], _vozrast) == 0
              aadd(arr, '�����४�� ������ ��樥�� ��� ��㣨 ' + s)
            endif
          endif
        else
          j := iif(_pol == '�', 8, 9)
          if valtype(dvn_arr_usl[i, j]) == 'N'
            if dvn_arr_usl[i, j] == 0
              aadd(arr, '��ᮢ���⨬���� �� ���� � ��㣥 ' + s)
            endif
          elseif type('is_disp_19') == 'L' .and. is_disp_19
            if ascan(dvn_arr_usl[i, j], _vozrast) == 0
              aadd(arr,'�����४�� ������ ��樥�� ��� ��㣨 ' + s)
            endif
          else
            if !between(_vozrast, dvn_arr_usl[i, j, 1], dvn_arr_usl[i, j, 2])
              aadd(arr, '�����४�� ������ ��樥�� ��� ��㣨 ' + s)
            endif
          endif
        endif
        if valtype(dvn_arr_usl[i, 10]) == 'N'
          if ret_profil_dispans(dvn_arr_usl[i, 10], ausl[4]) != ausl[3]
          //if dvn_arr_usl[i, 10] != ausl[3]
            aadd(arr, '�� �� ��䨫� � ��㣥 ' + s)
          endif
        else
          if ascan(dvn_arr_usl[i, 10], ausl[3]) == 0
            aadd(arr,'�� �� ��䨫� � ��㣥 ' + s)
          endif
        endif
        as := aclone(dvn_arr_usl[i, 11])
        // "����७�� ����ਣ������� ��������","3.4.9"
        if _etap == 1 .and. as[1] == 1112 .and. _spec_ter > 0
          aadd(as, _spec_ter) // �������� ᯥ�-�� �࠯���
        endif
        /*if ascan(as, ausl[4]) == 0
          aadd(arr,'�� � ᯥ樠�쭮��� ��� � ��㣥 ' + s)
          aadd(arr, ' � ���: ' + lstr(ausl[4]) + ', ࠧ�襭�: ' + print_array(as))
        endif*/
        exit
      endif
    next
  endif
  return fl

// 18.05.15
Function is_usluga_dvn13(ausl, _vozrast, arr, _etap, _pol, _spec_ter)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, j, s, fl := .f., as, lshifr := alltrim(ausl[1])

  if ((lshifr == '2.3.3' .and. ausl[3] == 3) .or. ; // �����᪮�� ����
        (lshifr == '2.3.1' .and. ausl[3] == 136))   // �������� � �����������
        //.and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
    if ((lshifr == '2.3.3' .and. eq_any(ret_old_prvs(ausl[4]), 2003, 2002)) .or. ;
          (lshifr == '2.3.1' .and. ret_old_prvs(ausl[4]) == 1101))
    else
      aadd(arr, '�� � ᯥ樠�쭮��� ��� � ��砥 ������������ �ᯮ�짮����� ��㣨:')
      aadd(arr, ' "4.1.12.�ᬮ�� ����મ�, ���⨥ ����� (�᪮��)"')
    endif
    fl := .t.
  endif
  if !fl
    for i := 1 to count_dvn_arr_umolch13
      if dvn_arr_umolch13[i, 2] == lshifr
        fl := .t.
        exit
      endif
    next
  endif
  if !fl
    DEFAULT _spec_ter to 0
    for i := 1 to count_dvn_arr_usl13
      if len(dvn_arr_usl13[i]) < 12 .and. valtype(dvn_arr_usl13[i, 2]) == 'C'
        if dvn_arr_usl13[i, 2] == '4.20.1' .and. lshifr == '4.20.2'
          fl := .t.
        elseif dvn_arr_usl13[i, 2] == lshifr
          fl := .t.
        endif
      elseif len(dvn_arr_usl13[i]) > 11
        if ascan(dvn_arr_usl13[i, 12], {|x| x[1] == lshifr .and. x[2] == ausl[3]}) > 0
          fl := .t.
        endif
      endif
      if fl
        s := '"' + lshifr + '.' + dvn_arr_usl13[i, 1] + '"'
        if _etap == 1
          j := iif(_pol == '�', 6, 7)
          if valtype(dvn_arr_usl13[i, j]) == 'N'
            if dvn_arr_usl13[i, j] == 0
              aadd(arr, '��ᮢ���⨬���� �� ���� � ��㣥 ' + s)
            endif
          else
            if ascan(dvn_arr_usl13[i, j], _vozrast) == 0
              aadd(arr, '�����४�� ������ ��樥�� ��� ��㣨 ' + s)
            endif
          endif
        else
          j := iif(_pol == '�', 8, 9)
          if valtype(dvn_arr_usl13[i, j]) == 'N'
            if dvn_arr_usl13[i, j] == 0
              aadd(arr, '��ᮢ���⨬���� �� ���� � ��㣥 ' + s)
            endif
          else
            if !between(_vozrast, dvn_arr_usl13[i, j, 1], dvn_arr_usl13[i, j, 2])
              aadd(arr, '�����४�� ������ ��樥�� ��� ��㣨 ' + s)
            endif
          endif
        endif
        if valtype(dvn_arr_usl13[i, 10]) == 'N'
          if ret_profil_dispans(dvn_arr_usl13[i, 10], ausl[4]) != ausl[3]
          //if dvn_arr_usl13[i, 10] != ausl[3]
            aadd(arr, '�� �� ��䨫� � ��㣥 ' + s)
          endif
        else
          if ascan(dvn_arr_usl13[i, 10], ausl[3]) == 0
            aadd(arr, '�� �� ��䨫� � ��㣥 ' + s)
          endif
        endif
        as := aclone(dvn_arr_usl13[i, 11])
        // "����७�� ����ਣ������� ��������","3.4.9"
        if _etap == 1 .and. as[1] == 1112 .and. _spec_ter > 0
          aadd(as, _spec_ter) // �������� ᯥ�-�� �࠯���
        endif
        /*if ascan(as,ausl[4]) == 0
          aadd(arr,'�� � ᯥ樠�쭮��� ��� � ��㣥 ' + s)
          aadd(arr,' � ���: '+lstr(ausl[4])+', ࠧ�襭�: '+print_array(as))
        endif*/
        exit
      endif
    next
  endif
  return fl

// 21.08.24 �㭪�� �஢�ન ��業��� �� ��ᯠ��ਧ���/��䨫��⨪�
Function license_for_dispans(_tip, _n_data, _ta)

  // ᯨ᮪ ��०����� � ��⮩ ��業��� �� ��ᯠ��ਧ���
  Static arr_date_disp := { ;
    {101003, 1, 0, 20130726}, ;  // 101003;���� "���� � 3";+;;26.07.2013
    {114504, 1, 0, 20130705}, ;  // 114504;��� "����������� � 4";+;;05.07.2013
    {114506, 1, 0, 20130704}, ;  // 114506;��� "����������� � 6";+;;04.07.2013
    {115506, 0, 1, 20130718}, ;  // 115506;��� "���᪠� ����������� � 6";;+;18.07.2013
    {115510, 0, 1, 20130719}, ;  // 115510;��� "�� � 10";;+;19.07.2013
    {121018, 1, 1, 20130806}, ;  // 121018;��� "���쭨� � 18";+;+;06.08.2013
    {124501, 1, 1, 20130829}, ;  // 124501;��� "��ࠪ᪠� ���㫠���";+;+;29.08.2013
    {124528, 1, 1, 20130805}, ;  // 124528;��� "������᪠� ����������� � 28";+;+;05.08.2013
    {124530, 1, 1, 20130703}, ;  // 124530;��� "����������� � 30";+;+;03.07.2013
    {125505, 0, 1, 20130719}, ;  // 125505;��� "���᪠� ����������� � 5";;+;19.07.2013
    {131020, 0, 1, 20130718}, ;  // 131020;��� "��� ��� ��⥩ � 1";;+;18.07.2013
    {134505, 1, 0, 20130719}, ;  // 134505;��� "����������� � 5";+;;19.07.2013
    {134510, 1, 0, 20130729}, ;  // 134510;��� "����������� � 10";+;;29.07.2013
    {135509, 0, 1, 20130805}, ;  // 135509;��� "���᪠� ����������� � 9";;+;05.08.2013
    {141016, 1, 0, 20130725}, ;  // 141016;��� "���쭨� � 16";+;;25.07.2013
    {141022, 1, 0, 20130726}, ;  // 141022;��� "���쭨� �22";+;;26.07.2013
    {141023, 1, 0, 20130712}, ;  // 141023;��� "����� � 15";+;;12.07.2013
    {141024, 1, 0, 20130712}, ;  // 141024;��� "���쭨� � 24";+;;12.07.2013
    {145516, 0, 1, 20130729}, ;  // 145516;��� "���᪠� ����������� � 16";;+;29.07.2013
    {145526, 0, 1, 20130727}, ;  // 145526;��� "���᪠� ����������� � 26";;+;27.07.2013
    {154602, 1, 0, 20130701}, ;  // 154602;��� "����������� � 2";+;;01.07.2013
    {154608, 1, 0, 20130729}, ;  // 154608;��� "����������� � 8";+;;29.07.2013
    {154620, 1, 0, 20130802}, ;  // 154620;��� "����������� � 20";+;;02.08.2013
    {155502, 0, 1, 20130730}, ;  // 155502;��� "���᪠� ����������� � 2";;+;30.07.2013
    {155601, 0, 1, 20130729}, ;  // 155601;��� "���᪠� ����������� � 1";;+;29.07.2013
    {161007, 1, 0, 20130725}, ;  // 161007;��� "�� ��� � 7";+;;25.07.2013
    {161015, 1, 0, 20130801}, ;  // 161015;��� "������᪠� ���쭨� � 11";+;;01.08.2013
    {165525, 0, 1, 20130802}, ;  // 165525;��� "���᪠� ����������� � 25";;+;02.08.2013
    {165531, 0, 1, 20130801}, ;  // 165531;��� "��� � 31";;+;01.08.2013
    {174601, 1, 0, 20130718}, ;  // 174601;��� �� � 1;+;;18.07.2013
    {175603, 0, 1, 20130725}, ;  // 175603;��� "���᪠� ����������� � 3";;+;25.07.2013
    {175617, 0, 1, 20130729}, ;  // 175617;��� "�� � 17";;+;29.07.2013
    {175627, 0, 1, 20130806}, ;  // 175627;��� "���᪠� ����������� � 27";;+;06.08.2013
    {175709, 1, 0, 20130624}, ;  // 175709;��� "������᪠� ����������� � 9";+;;24.06.2013
    {184512, 1, 0, 20130701}, ;  // 184512;��� "������᪠� ����������� � 12";+;;01.07.2013
    {184603, 1, 0, 20130701}, ;  // 184603;��� "������᪠� ����������� �3";+;;01.07.2013
    {185515, 0, 1, 20130730}, ;  // 185515;��� "��� � 15";;+;30.07.2013
    {251001, 1, 1, 20130713}, ;  // 251001;���� "��� � 1 ��. �.�.����";+;;13.07.2013
    {251002, 1, 0, 20130705}, ;  // 251002;���� "��� �3";+;;05.07.2013
    {251003, 1, 0, 20130730}, ;  // 251003;���� "��த᪠� ���쭨� � 2";+;;30.07.2013
    {251008, 0, 1, 20130805}, ;  // 251008;���� "��த᪠� ���᪠� ���쭨�";;+;05.08.2013
    {254504, 1, 0, 20130705}, ;  // 254504;���� "����������� � 4";+;;05.07.2013
    {254505, 1, 0, 20130711}, ;  // 254505;���� "��த᪠� ����������� �5";+;;11.07.2013
    {254506, 0, 1, 20130809}, ;  // 254506;���� "��த᪠� ����������� � 6";;+;09.08.2013
    {255601, 0, 1, 20130802}, ;  // 255601;���� "��� � 1";;+;02.08.2013
    {255627, 0, 1, 20130730}, ;  // 255627;���� "��� �2";;+;30.07.2013
    {255802, 1, 0, 20130703}, ;  // 255802;���� "��த᪠� ����������� � 3";+;;03.07.2013
    {301001, 1, 1, 20130730}, ;  // 301001;���� "����ᥥ�᪠� ���";+;+;30.07.2013
    {311001, 1, 1, 20130813}, ;  // 311001;���� "�몮�᪠� ���";+;+;13.08.2013
    {321001, 1, 1, 20130802}, ;  // 321001;���� "��த�饭᪠� ���";+;+;02.08.2013
    {331001, 1, 1, 20130709}, ;  // 331001;���� "�������᪠� ���";+;+;09.07.2013
    {341001, 1, 1, 20130802}, ;  // 341001;���� "��� �㡮�᪮�� �㭨樯��쭮�� ࠩ���";+;+;02.08.2013
    {351001, 1, 1, 20130730}, ;  // 351001;���� ����᪠� ���;+;+;30.07.2013
    {361001, 1, 1, 20130801}, ;  // 361001;��� "��୮�᪠� ���";+;+;01.08.2013
    {371001, 1, 1, 20130805}, ;  // 371001;���� "�������᪠� ���";+;+;05.08.2013
    {381001, 1, 1, 20130829}, ;  // 381001;���� "����祢᪠� ���";+;+;29.08.2013
    {391001, 1, 0, 20130802}, ;  // 391001;���� �.����設� "��த᪠� ���쭨� � 1";+;;02.08.2013
    {391002, 1, 0, 20130802}, ;  // 391002;���� ���;+;;02.08.2013
    {391003, 0, 1, 20130805}, ;  // 391003;���� "����";;+;05.08.2013
    {391015, 0, 1, 20131114}, ;  //+391015;��� ����設᪮�� �-��;;+;14.11.2013
    {395501, 0, 1, 20130809}, ;  // 395501;���� "���᪠� ����������� ����設᪮�� �㭨樯��쭮�� ࠩ��� ������ࠤ᪮� ������
    {401001, 1, 1, 20130801}, ;  // 401001;���� "���������᪠� ���";+;+;01.08.2013
    {411001, 1, 1, 20130713}, ;  // 411001;���� "��� ����᪮�� �㭨樯��쭮�� ࠩ���";+;+;13.07.2013
    {421001, 1, 1, 20130806}, ;  // 421001;���� "��⥫쭨���᪠� ���";+;+;06.08.2013
    {431001, 1, 1, 20130809}, ;  // 431001;���� ��� ��⮢᪮�� �㭨樯��쭮�� ࠩ���;+;+;09.08.2013
    {441001, 1, 1, 20130809}, ;  // 441001;���� "�����᪠� ���";+;+;09.08.2013
    {451001, 1, 0, 20130805}, ;  // 451001;���� "����";+;;05.08.2013
    {451002, 0, 1, 20130717}, ;  // 451002;���� "����";;+;17.07.2013
    {461001, 1, 1, 20130718}, ;  // 461001;���� "��堥�᪠� ���";+;+;18.07.2013
    {471001, 1, 1, 20130717}, ;  // 471001;���� "��������᪠� ���";+;+;17.07.2013
    {481001, 1, 1, 20130801}, ;  // 481001;���� "���������᪠� ���";+;+;01.08.2013
    {491001, 1, 1, 20130802}, ;  // 491001;���� "������������᪠� ���";+;+;02.08.2013
    {501001, 1, 1, 20130806}, ;  // 501001;���� "������᪠� ���";+;+;06.08.2013
    {511001, 1, 1, 20130809}, ;  // 511001;���� "��� ���客᪮�� �㭨樯��쭮�� ࠩ���";+;+;09.08.2013
    {521001, 1, 1, 20130716}, ;  // 521001;���� "�����ᮢ᪠� ���";+;+;16.07.2013
    {531001, 1, 1, 20130724}, ;  // 531001;���� "��뫦��᪠� ���";+;+;24.07.2013
    {541001, 1, 1, 20130813}, ;  // 541001;��� "��� �㤭�᪮�� �㭨樯��쭮�� ࠩ���";+;+;13.08.2013
    {551001, 1, 1, 20130809}, ;  // 551001;���� "���⫮��᪠� ���";+;+;09.08.2013
    {561001, 1, 1, 20130717}, ;  // 561001;���� "���䨬����᪠� ���";+;+;17.07.2013
    {571001, 1, 1, 20130802}, ;  // 571001;���� "�।�����㡨�᪠� ���";+;+;02.08.2013
    {571002, 1, 0, 20130829}, ;  // 571002;���� "��᭮᫮���᪠� ��த᪠� ���쭨�";+;;29.08.2013
    {581001, 1, 1, 20130711}, ;  // 581001;���� "��ய��⠢᪠� ���";+;+;11.07.2013
    {591001, 1, 1, 20130730}, ;  // 591001;���� "��� ��஢����᪮�� �㭨樯��쭮�� ࠩ���";+;+;30.07.2013
    {601001, 1, 1, 20130809}, ;  // 601001;���� ���᪠� ���;+;+;09.08.2013
    {611001, 1, 1, 20130802}, ;  // 611001;���� "�஫��᪠� ���";+;+;02.08.2013
    {621001, 1, 1, 20130805}, ;  // 621001;���� "����誮�᪠� ���";+;+;05.08.2013
    {711001, 1, 0, 20130731}, ;  // 711001;��� "�⤥����᪠� ������᪠� ���쭨� �� ��. ������ࠤ-1 ��� "���";+;;31.07.2013
    {101201, 1, 0, 20240430} ;   // 101201;���� ��ᯨ⠫� ���࠭�� ����;+;;30.04.2024
   }
  Static mm_tip := {'��ᯠ��ਧ���/��䨫��⨪� ������', ;
                    '��䨫��⨪� ��ᮢ��襭����⭨�'}
  Local i

  if valtype(arr_date_disp[1, 1]) == 'N' // ��� ��ࢮ�� ����᪠
    for i := 1 to len(arr_date_disp)
      arr_date_disp[i, 1] := lstr(arr_date_disp[i, 1])
      arr_date_disp[i, 4] := stod(lstr(arr_date_disp[i, 4]))
    next
  endif
  if (i := ascan(arr_date_disp, {|x| x[1] == glob_mo()[ _MO_KOD_TFOMS ] })) > 0
    if arr_date_disp[i, _tip + 1] == 0
      aadd(_ta, '� ��襩 �� ��� ��業��� �� ' + mm_tip[_tip])
    elseif arr_date_disp[i, 4] > _n_data
      aadd(_ta, '� ��襩 �� ��業��� �� ' + mm_tip[_tip] + ' � ' + date_8(arr_date_disp[i, 4]) + '�.')
    endif
  else
    aadd(_ta, '� ��襩 �� ��� ��業��� �� ' + mm_tip[_tip])
  endif
  return NIL
  
// 25.08.13 �᫨ ��㣠 �� 1 �⠯�
Function is_issled_PerN(ausl, _period, arr, _pol)

  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, s := '', fl := .f., lshifr := alltrim(ausl[1])

  for i := 1 to count_pern_arr_iss
    if nper_arr_issled[i, 1] == lshifr
      s := '"' + lshifr + '.' + nper_arr_issled[i, 3] + '"'
      fl := .t.
      exit
    endif
  next
  if fl .and. nper_arr_issled[i, 4] < 2
    if nper_arr_issled[i, 5] != ausl[3]
      aadd(arr, '�� �� ��䨫� � ���-�� ' + s)
    endif
    /*if ascan(nper_arr_issled[i, 6],ausl[4]) == 0
      aadd(arr, '�� � ᯥ樠�쭮��� ��� � ���-�� ' + s)
      aadd(arr, ' � ���: '+lstr(ausl[4])+', ࠧ�襭�: '+print_array(nper_arr_issled[i, 6]))
    endif*/
  endif
  return fl
  
// 19.08.13 �᫨ ��㣠 �� 1 �⠯�
Function is_1_etap_PredN(ausl, _period, _etap)

  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, fl := .f., lshifr := alltrim(ausl[1])

  for i := 1 to count_predn_arr_osm
    if _etap == 1
      if npred_arr_osmotr[i, 4] == ausl[3]
        lshifr := npred_arr_osmotr[i, 1] // �����⢥���
        fl := .t.
        exit
      endif
    else
      if npred_arr_osmotr[i, 1] == lshifr
        fl := .t.
        exit
      endif
    endif
  next
  if fl
    fl := (ascan(npred_arr_1_etap[_period, 4], lshifr) > 0)
  endif
  return fl
  
// 13.02.17
Function is_osmotr_PredN(ausl, _period, arr, _etap, _pol)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, s, fl := .f., lshifr := alltrim(ausl[1])
  
  if _etap == 2 .and. (j := ascan(npred_arr_osmotr_KDP2, {|x| x[2] == lshifr})) > 0
    lshifr := npred_arr_osmotr_KDP2[j, 1]
  endif
  for i := 1 to count_predn_arr_osm
    if _etap == 1
      if npred_arr_osmotr[i, 4] == ausl[3]
        lshifr := npred_arr_osmotr[i, 1] // �����⢥���
        fl := .t.
        exit
      endif
    else
      if npred_arr_osmotr[i, 1] == lshifr
        fl := .t.
        exit
      endif
    endif
  next
  if fl
    s := '"' + lshifr + '.' + npred_arr_osmotr[i, 3] + '"'
    if _etap == 1 .and. ascan(npred_arr_1_etap[_period, 4], lshifr) == 0
      aadd(arr, '�����४�� �����⭮� ��ਮ� ��樥�� ��� ' + s)
    endif
    if !empty(npred_arr_osmotr[i, 2]) .and. !(npred_arr_osmotr[i, 2] == _pol)
      aadd(arr, '��ᮢ���⨬���� �� ���� � ��㣥 ' + s)
    endif
    if npred_arr_osmotr[i, 4] != ausl[3]
      aadd(arr, '�� �� ��䨫� � ��㣥 ' + s)
    endif
    /*if ascan(npred_arr_osmotr[i, 5],ausl[4]) == 0
      aadd(arr,'�� � ᯥ樠�쭮��� ��� � ��㣥 ' + s)
      aadd(arr,' � ���: '+lstr(ausl[4])+', ࠧ�襭�: '+print_array(npred_arr_osmotr[i, 5]))
    endif*/
  endif
  return fl
  
// 19.08.13
Function is_issled_PredN(ausl, _period, arr, _pol)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, s := '', fl := .f., lshifr := alltrim(ausl[1])

  for i := 1 to count_predn_arr_iss
    if npred_arr_issled[i, 1] == lshifr
      s := '"' + lshifr + '.' + npred_arr_issled[i, 3] + '"'
      if valtype(npred_arr_issled[i, 2]) == 'C' .and. !(npred_arr_issled[i, 2] == _pol)
        aadd(arr, '��ᮢ���⨬���� �� ���� � ��㣥 ' + s)
      endif
      fl := .t.
      exit
    endif
  next
  if fl .and. npred_arr_issled[i, 4] < 2
    if ascan(npred_arr_1_etap[_period, 5], lshifr) == 0
      aadd(arr, '�����४�� �����⭮� ��ਮ� ��樥�� ��� ' + s)
    endif
    if npred_arr_issled[i, 5] != ausl[3]
      aadd(arr, '�� �� ��䨫� � ���-�� ' + s)
    endif
    /*if ascan(npred_arr_issled[i, 6],ausl[4]) == 0
      aadd(arr,'�� � ᯥ樠�쭮��� ��� � ���-�� ' + s)
      aadd(arr,' � ���: '+lstr(ausl[4])+', ࠧ�襭�: '+print_array(npred_arr_issled[i, 6]))
    endif*/
  endif
  return fl
  
// �஢�ઠ, 㬥� �� ��樥��
Function is_death(_rslt)
  return eq_any(_rslt, 105, 106, 205, 206, 313, 405, 406, 411) // �� १����� ��祭��

// 16.09.25
function message_save_LU()

  If mem_op_out == 2 .and. yes_parol
    box_shadow( 19, 10, 22, 69, cColorStMsg )
    str_center( 20, '������ "' + AllTrim( hb_user_curUser:FIO ) + '".', cColorSt2Msg )
    str_center( 21, '���� ������ �� ' + date_month( Date() ), cColorStMsg )
  Endif
  return nil
