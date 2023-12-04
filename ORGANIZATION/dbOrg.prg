// #include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// #require 'hbsqlit3'

// 04.12.23
// �� �� "�����������"
function is_VOLGOMEDLAB()

  return hb_main_curOrg:Kod_Tfoms == VOLGOMEDLAB

// 23.10.23
function getUCH()
  static arr
  static time_load
  local dbAlias
  local oldSelect

  if timeout_load(@time_load)
    oldSelect := Select()
    dbAlias := '__UCH'
    arr := {}
    R_Use(dir_server + 'mo_uch', , dbAlias)
    (dbAlias)->(dbGoTop())
    while ! (dbAlias)->(Eof())

      //   {'KOD',       'N', 3, 0}, ; // ���;;�� 'l_ucher'
      //   {'NAME',      'C', 30, 0}, ; // ������������;᮪�⨫� � 70 �� 30;'�� ''l_ucher'''
      //   {'SHORT_NAME', 'C', 5, 0}, ; // ᮪�饭��� ������������;;
      //   {'IS_TALON',  'N', 1, 0}, ; // ��०����� ࠡ�⠥� � ���⠫����?;0-���, 1-��;��⠢��� 0, ��� ���⠢��� 1 � ����ᨬ��� �� ���ᨢ� UCHER_TALON (�. c_allpub.prg ��ப� 273)
      //   {'IDCHIEF',   'N', 4, 0}, ; // ����� ����� � 䠩�� mo_pers. ��뫪� �� �㪮����⥫� ��०�����
      //   {'ADDRESS',  'C', 150, 0}, ; // ���� ��宦����� ��०�����
      //   {'COMPET',    'C', 40, 0}, ; // ���㬥�� �⢥ত���� �㪮����⥫�
      //   {'DBEGIN',    'D', 8, 0}, ; // ��� ��砫� ����⢨�;;���⠢��� 01.01.1993
      //   {'DEND',      'D', 8, 0} ;  // ��� ����砭�� ����⢨�;;���⠢��� 31.12.2000, ��� ��⠢��� ����� � ����ᨬ��� �� ���ᨢ� UCHER_ARRAY (�. b_init.prg)
      AAdd(arr, {(dbAlias)->NAME, (dbAlias)->KOD, (dbAlias)->SHORT_NAME, (dbAlias)->IS_TALON, (dbAlias)->IDCHIEF, ;
        (dbAlias)->ADDRESS, (dbAlias)->COMPET, (dbAlias)->DBEGIN, (dbAlias)->DEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseAre())
    Select(oldSelect)
  endif

  return arr

// 23.10.23
function getUCH_Name(kod)
  local cName := ''
  local i, arr := getUCH()

  if kod > 0 .and. kod <= len(arr)
    if (i := hb_Ascan(arr, {|x| x[2] == kod})) > 0
      cName := arr[i, 1]
    endif
  endif
  return cName

// 23.10.23
function getOTD()
  static arr
  static time_load
  local dbAlias
  local oldSelect

  if timeout_load(@time_load)
    oldSelect := Select()
    dbAlias := '__OTD'
    arr := {}
    R_Use(dir_server + 'mo_otd', , dbAlias)
    (dbAlias)->(dbGoTop())
    while ! (dbAlias)->(Eof())

      // {'KOD',       'N', 3, 0}, ; // ���
      // {'NAME',      'C', 30, 0}, ; // ������������
      // {'KOD_LPU',   'N', 3, 0}, ; // ��� ��०�����
      // {'SHORT_NAME', 'C', 5, 0}, ; // ᮪�饭��� ������������
      // {'DBEGIN',    'D', 8, 0}, ; // ��� ��砫� ����⢨� � ����� ���
      // {'DEND',      'D', 8, 0}, ; // ��� ����砭�� ����⢨� � ����� ���
      // {'DBEGINP',   'D', 8, 0}, ; // ��� ��砫� ����⢨� � ����� '����� ��㣨'
      // {'DENDP',     'D', 8, 0}, ; // ��� ����砭�� ����⢨� � ����� '����� ��㣨'
      // {'DBEGINO',   'D', 8, 0}, ; // ��� ��砫� ����⢨� � ����� '��⮯����'
      // {'DENDO',     'D', 8, 0}, ; // ��� ����砭�� ����⢨� � ����� '��⮯����'
      // {'PLAN_VP',   'N', 6, 0}, ; // ���� ��祡��� �ਥ���
      // {'PLAN_PF',   'N', 6, 0}, ; // ���� ��䨫��⨪
      // {'PLAN_PD',   'N', 6, 0}, ; // ���� �ਥ��� �� ����
      // {'PROFIL',    'N', 3, 0}, ; // ��䨫� ��� ������� �⤥����� �� �ࠢ�筨�� V002, �� 㬮�砭�� �ய��뢠�� ��� � ���� ��� � � ����
      // {'PROFIL_K',  'N', 3, 0}, ; // ��䨫� ����� ��� ������� �⤥����� �� �ࠢ�筨�� V020, �� 㬮�砭�� �ய��뢠�� ��� � ���� ���
      // {'IDSP',      'N', 2, 0}, ; // ��� ᯮᮡ� ������ ���.����� ��� ������� �⤥����� �� �ࠢ�筨�� V010
      // {'IDUMP',     'N', 2, 0}, ; // ��� �᫮��� �������� ����樭᪮� �����
      // {'IDVMP',     'N', 2, 0}, ; // ��� ����� ����樭᪮� �����
      // {'TIP_OTD',   'N', 2, 0}, ; // ⨯ ��-��: 1-���� �����
      // {'KOD_PODR',  'C', 25, 0}, ; // ��� ���ࠧ������� �� ��ᯮ��� ���
      // {'TIPLU',     'N', 2, 0}, ; // ⨯ ���� ����: 0-�⠭����, 1-���, 2-���, 3-���, � �.�.
      // {'CODE_DEP',  'N', 3, 0}, ; // ��� �⤥����� �� ����஢�� ����� �� �ࠢ�筨�� SprDep - 2018 ���
      // {'ADRES_PODR', 'N', 2, 0}, ; // ��� 㤠�񭭮�� ���ࠧ������� �� ���ᨢ� glob_arr_podr - 2017 ���
      // {'ADDRESS',  'C', 150, 0}, ; // ���� ��宦����� ��०�����
      // {'CODE_TFOMS', 'C', 6, 0}, ; // ��� ���ࠧ������� �� ����஢�� ����� - 2017 ���
      // {'KOD_SOGL',  'N', 10, 0}, ; // ��� ᮣ��ᮢ���� ������ �⤥����� � �ணࠬ��� SDS
      // {'SOME_SOGL', 'C', 255, 0} ;  // ��� ᮣ��ᮢ���� ��᪮�쪨� �⤥����� � �ணࠬ��� SDS
      AAdd(arr, {(dbAlias)->NAME, (dbAlias)->KOD, (dbAlias)->KOD_LPU, (dbAlias)->SHORT_NAME, (dbAlias)->DBEGIN, (dbAlias)->DEND, (dbAlias)->DBEGINP, (dbAlias)->DENDP, (dbAlias)->DBEGINO, (dbAlias)->DENDO, ;
        (dbAlias)->PLAN_VP, (dbAlias)->PLAN_PF, (dbAlias)->PLAN_PD, (dbAlias)->PROFIL, (dbAlias)->PROFIL_K, (dbAlias)->IDSP, (dbAlias)->IDUMP, (dbAlias)->IDVMP, (dbAlias)->TIP_OTD, (dbAlias)->KOD_PODR, ;
        (dbAlias)->TIPLU, (dbAlias)->CODE_DEP, (dbAlias)->ADRES_PODR, (dbAlias)->ADDRESS, ;
        (dbAlias)->CODE_TFOMS, (dbAlias)->KOD_SOGL, (dbAlias)->SOME_SOGL})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseAre())
    Select(oldSelect)
  endif

  return arr

// 24.10.23
function getOTD_Name(kod)
  local cName := ''
  local i, arr := getOTD()

  if kod > 0 .and. kod <= len(arr)
    if (i := hb_Ascan(arr, {|x| x[2] == kod})) > 0
      cName := arr[i, 1]
    endif
  endif
  return cName

// 24.10.23
function getOTD_record(kod)
  local retArr := {}
  local i, arr := getOTD()

  if kod > 0 .and. kod <= len(arr)
    if (i := hb_Ascan(arr, {|x| x[2] == kod})) > 0
      retArr := arr[i]
    endif
  endif
  return retArr

