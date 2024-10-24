#include 'function.ch'
#include 'chip_mo.ch'

#define NUMBER_YEAR 3 // �᫮ ��� ��� ��२�����樨 �����
#define INDEX_NEED  2 // �᫮ ��� ��易⥫쭮� ��२�����樨

// 26.09.23 �஢�ઠ ������ �ࠢ�筨��� ���
function files_NSI_exists(dir_file)
  local lRet := .t.
  local i
  local sbase
  local aError := {}
  local cDbf := '.dbf'
  local cDbt := '.dbt'
  local arr_f  := {'_okator', '_okatoo', '_okatos', '_okatoo8', '_okatos8'}
  local arr_check := {}
  local countYear
  local prefix
  local arr_TFOMS
  local n_file := cur_dir + 'error_init' + stxt, sh := 80, HH := 60

  sbase := dir_file + FILE_NAME_SQL // 'chip_mo.db'
  if ! hb_FileExists(sbase)
    aadd(aError, '��������� 䠩�: ' + sbase)
  else
    if (nSize := hb_vfSize(sbase)) < 3362000
      aadd(aError, '������ 䠩�� "' + sbase + '" ����� 3362000 ����. ������� � ࠧࠡ��稪��.')
    endif
  endif

  fill_exists_files_TFOMS(dir_file)

  // �ࠢ�筨�� ���������
  sbase := dir_file + '_mo_mkb' + cDbf
  aadd(arr_check, sbase)
  sbase := dir_file + '_mo_mkbg' + cDbf
  aadd(arr_check, sbase)
  sbase := dir_file + '_mo_mkbk' + cDbf
  aadd(arr_check, sbase)

  // ��㣨 <-> ᯥ樠�쭮��
  sbase := dir_file + '_mo_spec' + cDbf
  aadd(arr_check, sbase)

  // ��㣨 <-> ��䨫�
  sbase := dir_file + '_mo_prof' + cDbf
  aadd(arr_check, sbase)

  // �ࠢ�筨� ���客�� �������� ��
  sbase := dir_file + '_mo_smo' + cDbf
  aadd(arr_check, sbase)

  // onkko_vmp
  sbase := dir_file + '_mo_ovmp' + cDbf
  aadd(arr_check, sbase)

  // N0__
  // for i := 1 to 21
  for i := 20 to 21
    sbase := dir_file + '_mo_N' + StrZero(i, 3) + cDbf
    aadd(arr_check, sbase)
  next

  // �ࠢ�筨� ���ࠧ������� �� ��ᯮ�� ���
  sbase := dir_file + '_mo_podr' + cDbf
  aadd(arr_check, sbase)

  // �ࠢ�筨� ᮮ⢥��⢨� ��䨫� ���.����� � ��䨫�� �����
  sbase := dir_file + '_mo_prprk' + cDbf
  aadd(arr_check, sbase)

  // �����
  for i := 1 to len(arr_f)
    sbase := dir_file + arr_f[i] + cDbf
    aadd(arr_check, sbase)
  next

  // �஢�ਬ ����⢮����� 䠩���
  for i := 1 to len(arr_check)
    if ! hb_FileExists(arr_check[i])
      aadd(aError, '��������� 䠩�: ' + arr_check[i])
    endif
  next

  prefix := dir_file + prefixFileRefName(WORK_YEAR)
  arr_TFOMS := array_exists_files_TFOMS(WORK_YEAR)
  for i := 1 to len(arr_TFOMS)
    if ! arr_TFOMS[i, 2]
      aadd(aError, '��������� 䠩�: ' + prefix + arr_TFOMS[i, 1] + cDbf)
    endif
  next

  if len(aError) > 0
    aadd(aError, '����� ����������!')
    f_message(aError, , 'GR+/R', 'W+/R', 13)
    inkey(0)

    lret := .f.
  endif

  return lRet

// 29.09.23 �஢�ઠ � ��२�����஢���� �ࠢ�筨��� �����
Function index_work_dir(dir_spavoch, cur_dir, flag)
  Local fl := .t., i, arr, buf := save_maxrow()
  local arrRefFFOMS := {}, row, row_flag := .t.
  local lSchema := .f.
  local countYear
  local file_index, sbase
  local nSize
  local cVar

  DEFAULT flag TO .f.

  afill(glob_yes_kdp2, .f.)

  if flag
    mywait('��������, ���� ��२������� 䠩��� ��� � ࠡ�祩 ������...')
  else
    mywait('��������, ���� �஢�ઠ �㦥���� ������ � ࠡ�祬 ��⠫���...')
  endif

  // �ࠢ�筨� ���������
  sbase := '_mo_mkb'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on shifr + str(ks, 1) to (cur_dir + sbase)
  close databases

  // ��㣨 <-> ᯥ樠�쭮��
  sbase := '_mo_spec'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on shifr + str(vzros_reb, 1) + str(prvs_new, 6) to (cur_dir + sbase)
  use

  // ��㣨 <-> ��䨫�
  sbase := '_mo_prof'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on shifr + str(vzros_reb, 1) + str(profil, 3) to (cur_dir + sbase)
  use

  if flag
    for countYear = 2018 to WORK_YEAR
      fl := dep_index_and_fill(countYear, dir_spavoch, cur_dir, flag)  // �ࠢ�筨� �⤥����� �� countYear ���
      fl := usl_Index(countYear, dir_spavoch, cur_dir, flag)    // �ࠢ�筨� ��� ����� �� countYear ���
      fl := uslc_Index(countYear, dir_spavoch, cur_dir, flag)   // 業� �� ��㣨 �� countYear ���
      fl := uslf_Index(countYear, dir_spavoch, cur_dir, flag)   // �ࠢ�筨� ��� ����� countYear
      fl := unit_Index(countYear, dir_spavoch, cur_dir, flag)   // ����-�����
      fl := k006_index(countYear, dir_spavoch, cur_dir, flag)
    next
  else
    fl := dep_index_and_fill(WORK_YEAR, dir_spavoch, cur_dir, flag)  // �ࠢ�筨� �⤥����� �� countYear ���
    fl := usl_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)    // �ࠢ�筨� ��� ����� �� countYear ���
    fl := uslc_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)   // 業� �� ��㣨 �� countYear ���
    fl := uslf_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)   // �ࠢ�筨� ��� ����� countYear
    fl := unit_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)   // ����-�����
    fl := k006_index(WORK_YEAR, dir_spavoch, cur_dir, flag)
  endif

  load_exists_uslugi()

  for i := 2019 to WORK_YEAR
    cVar := 'is_' + substr(str(i, 4), 3) + '_VMP'
    is_MO_VMP := is_MO_VMP .or. __mvGet( cVar )
  next

  // �ࠢ�筨� ���客�� �������� ��
  sbase := '_mo_smo'
  file_index := cur_dir + sbase + sntx
  // Public glob_array_srf := {}
  glob_array_srf := {}
  R_Use(dir_spavoch + sbase )
  index on okato to (cur_dir + sbase) UNIQUE
  dbeval({|| aadd(glob_array_srf, {'', field->okato})})
  index on okato + smo to (cur_dir + sbase)
  index on smo to (cur_dir + sbase + '2')
  index on okato + ogrn to (cur_dir + sbase + '3')
  use

  // onkko_vmp
  sbase := '_mo_ovmp'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on str(metod, 3) to (cur_dir + sbase)
  use

  // N020
  sbase := '_mo_N020'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on id_lekp to (cur_dir + sbase)
  index on upper(mnn) to (cur_dir + sbase + 'n')
  use

  // �ࠢ�筨� ���ࠧ������� �� ��ᯮ�� ���
  sbase := '_mo_podr'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on codemo + padr(upper(kodotd), 25) to (cur_dir + sbase)
  use

  // �ࠢ�筨� ᮮ⢥��⢨� ��䨫� ���.����� � ��䨫�� �����
  sbase := '_mo_prprk'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on str(profil, 3) + str(profil_k, 3) to (cur_dir + sbase)
  use

  // �ࠢ�筨� �����
  okato_index(flag)
  //
  dbcreate(cur_dir + 'tmp_srf', {{'okato', 'C', 5, 0}, {'name', 'C', 80, 0}})
  use (cur_dir + 'tmp_srf') new alias TMP
  R_Use(dir_spavoch + '_okator', cur_dir + '_okatr', 'RE')
  R_Use(dir_spavoch + '_okatoo', cur_dir + '_okato', 'OB')
  for i := 1 to len(glob_array_srf)
    select OB
    find (glob_array_srf[i, 2])
    if found()
      glob_array_srf[i, 1] := rtrim(ob->name)
    else
      select RE
      find (left(glob_array_srf[i, 2], 2))
      if found()
        glob_array_srf[i, 1] := rtrim(re->name)
      elseif left(glob_array_srf[i, 2], 2) == '55'
        glob_array_srf[i, 1] := '�.��������'
      endif
    endif
    select TMP
    append blank
    tmp->okato := glob_array_srf[i, 2]
    tmp->name  := iif(substr(glob_array_srf[i, 2], 3, 1) == '0', '', '  ') + glob_array_srf[i, 1]
  next
  close databases
  rest_box(buf)

  return nil

// 09.03.23
function dep_index_and_fill(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index
  
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'dep'  // �ࠢ�筨� �⤥����� �� ������� ���
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase, , 'DEP')
    index on str(code, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]

    if val_year == WORK_YEAR
      dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short) + ' (' + alltrim(dep->name) + ')', dep->code, dep->place})})
      if (is_otd_dep := (len(mm_otd_dep) > 0))
        asort(mm_otd_dep, , , {|x, y| x[1] < y[1]})
      endif
    endif
    use
    if is_otd_dep
      lIndex := .f.
      sbase := prefixFileRefName(val_year) + 'deppr' // �ࠢ�筨� �⤥����� + ��䨫�  �� ������� ���
      if hb_vfExists(dir_spavoch + sbase + sdbf)
        file_index := cur_dir + sbase + sntx
        R_Use(dir_spavoch + sbase, , 'DEP')
        index on str(code, 3) + str(pr_mp, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]
        use
      endif
    endif
  endif
  return nil

// 14.03.23
function usl_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index
  local shifrVMP

  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'usl'  // �ࠢ�筨� ��� ����� �� ������� ���
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase, ,'LUSL')
    index on shifr to (cur_dir + sbase)
    if val_year == WORK_YEAR
      shifrVMP := code_services_VMP(WORK_YEAR)
      find (shifrVMP)
      // find ('1.22.') // ��� 䥤�ࠫ쭮�   // 01.03.23 ������ ��� � 1.21 �� 1.22 ���쬮
      // find ('1.21.') // ��� 䥤�ࠫ쭮�   // 10.02.22 ������ ��� � 1.20 �� 1.21 ���쬮 12-20-60 �� 01.02.22
      // find ('1.20.') // ��� 䥤�ࠫ쭮�   // 07.02.21 ������ ��� � 1.12 �� 1.20 ���쬮 12-20-60 �� 01.02.21
      // do while left(lusl->shifr,5) == '1.20.' .and. !eof()
      // do while left(lusl->shifr,5) == '1.21.' .and. !eof()
      // do while left(lusl->shifr, 5) == '1.22.' .and. !eof()
      do while left(lusl->shifr, 5) == shifrVMP .and. !eof()
        aadd(arr_12_VMP, int(val(substr(lusl->shifr, 6))))
        skip
      enddo
    endif
    close databases
  endif
  return nil

// 23.03.23
function uslc_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase, prefix
  local index_usl_name
  local file_index
  
  DEFAULT flag TO .f.
  prefix := prefixFileRefName(val_year)
  sbase :=  prefix + 'uslc'  // 業� �� ��㣨 �� ������� ���
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    index_usl_name :=  prefix + 'uslu'  // 
    file_index := cur_dir + sbase + sntx

    R_Use(dir_spavoch + sbase, , 'LUSLC')
    index on shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + sbase) ;
              for codemo == glob_mo[_MO_KOD_TFOMS]
    index on codemo + shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + index_usl_name) ;
              for codemo == glob_mo[_MO_KOD_TFOMS] // ��� ᮢ���⨬��� � ��ன ���ᨥ� �ࠢ�筨��
  
    close databases
  endif
  return nil

// 09.03.23
function uslf_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local lIndex := .f.
  local file_index
  
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'uslf'  // �ࠢ�筨� ��� ����� �� ������� ���
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase, , 'LUSLF')
    index on shifr to (cur_dir + sbase)
    use
  endif
  return nil

// 09.03.23
function unit_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index
      
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'unit'  // ����-����� �� ������� ���
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase )
    index on str(code, 3) to (cur_dir + sbase)
    use
  endif
  return nil

// 05.11.23
function k006_index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index

  DEFAULT flag TO .f.

  sbase := prefixFileRefName(val_year) + 'k006'  // 
  if hb_vfExists(dir_spavoch + sbase + sdbf) .and. hb_vfExists(dir_spavoch + sbase + sdbt)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase)
    index on substr(shifr, 1, 2) + ds + sy + age + sex + los to (cur_dir + sbase) // �� ��������/����樨
    index on substr(shifr, 1, 2) + sy + ds + age + sex + los to (cur_dir + sbase + '_') // �� ����樨/��������
    index on ad_cr to (cur_dir + sbase + 'AD') // �� �������⥫쭮�� ����� ������
    // index on ad_cr1 to (cur_dir + sbase + 'AD1') // �� ��������� �ࠪ権, �� ����饥
    use
  endif
  return nil