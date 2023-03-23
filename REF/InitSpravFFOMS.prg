#include 'function.ch'
#include 'chip_mo.ch'

** 22.03.23 ���樠������ �ࠢ�筨��� �����
Function InitSpravFFOMS()
  /////////////////////////////////////////////////
  initPZarray() // ���樠�����㥬 ���ᨢ� ������-������

  return NIL

** 23.03.23
function load_exists_uslugi()
  local countYear, lAlias, cVar
  local cSearch
  local fname, file_index

  for countYear := 2019 to WORK_YEAR
    lAlias := 'luslc' + iif(countYear == WORK_YEAR, '', substr(str(countYear, 4), 3))
    fName := prefixFileRefName(countYear) + substr('luslc', 2)

    file_index := prefixFileRefName(countYear) + substr('luslc', 2, 3) + 'u'

    if ! exists_file_TFOMS(countYear, 'uslc')
      loop
    endif

    R_Use(exe_dir + fname, cur_dir + file_index, lAlias)

    if select(lAlias) == 0
      loop
    endif

    if countYear == WORK_YEAR
      // ����樭᪠� ॠ������� ��⥩ � ����襭�ﬨ ��� ��� ������ �祢��� ������ ��⥬� ��嫥�୮� �������樨
      find (glob_mo[_MO_KOD_TFOMS] + 'st37.015')
      if found()
        is_reabil_slux := found()
      endif
  
      find (glob_mo[_MO_KOD_TFOMS] + '2.') // ��祡�� ����
      do while codemo == glob_mo[_MO_KOD_TFOMS] .and. left(shifr, 2) == '2.' .and. !eof()
        if left(shifr, 5) == '2.82.'
          is_vr_pr_pp := .t. // ��祡�� �ਥ� � ��񬭮� �⤥����� ��樮���
          if is_napr_pol
            exit
          endif
        else
          is_napr_pol := .t.
          if is_vr_pr_pp
            exit
          endif
        endif
        skip
      enddo
    
    //
      find (glob_mo[_MO_KOD_TFOMS] + '60.3.')
      if found()
        is_alldializ := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '60.3.1')
      if found()
        is_per_dializ := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '60.3.9')
      if found()
        is_hemodializ := .t.
      else
        find (glob_mo[_MO_KOD_TFOMS] + '60.3.10')
        if found()
          is_hemodializ := .t.
        endif
      endif
  
    //
      find (glob_mo[_MO_KOD_TFOMS] + 'st') // �����-���
      if (is_napr_stac := found())
        glob_menu_mz_rf[1] := .t.
      endif
    //
    //
      find (glob_mo[_MO_KOD_TFOMS] + 'ds') // ������� ��樮���
      if found()
        if !is_napr_stac
          is_napr_stac := .t.
        endif
        glob_menu_mz_rf[2] := found()
      endif
    
    //
      tmp_stom := {'2.78.54', '2.78.55', '2.78.56', '2.78.57', '2.78.58', '2.78.59', '2.78.60'}
      for i := 1 to len(tmp_stom)
        find (glob_mo[_MO_KOD_TFOMS] + tmp_stom[i]) //
        if found()
          glob_menu_mz_rf[3] := .t.
          exit
        endif
      next
    
    //
      find (glob_mo[_MO_KOD_TFOMS] + '4.20.702') // ������⭮� �⮫����
      if found()
        aadd(glob_klin_diagn, 1)
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '4.15.746') // �७�⠫쭮�� �ਭ����
      if found()
        aadd(glob_klin_diagn, 2)
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '70.5.15') // �����祭�� ��砩 ��ᯠ��ਧ�樨 ��⥩-��� (0-11 ����楢), 1 �⠯ ��� ����⮫����᪨� ��᫥�������
      if found()
        glob_yes_kdp2[TIP_LU_DDS] := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '70.6.13') // �����祭�� ��砩 ��ᯠ��ਧ�樨 ��⥩-��� (0-11 ����楢), 1 �⠯ ��� ����⮫����᪨� ��᫥�������
      if found()
        glob_yes_kdp2[TIP_LU_DDSOP] := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '70.3.123') // �����祭�� ��砩 ��ᯠ��ਧ�樨 ���騭 (� ������ 21,24,27 ���), 1 �⠯ ��� ����⮫����᪨� ��᫥�������
      if found()
        glob_yes_kdp2[TIP_LU_DVN] := .t.
      endif
          //
      find (glob_mo[_MO_KOD_TFOMS] + '72.2.41') // �����祭�� ��砩 ��䨫����᪮�� �ᬮ�� ��ᮢ��襭����⭨� (2 ���.) 1 �⠯ ��� ����⮫����᪮�� ��᫥�������
      if found()
        glob_yes_kdp2[TIP_LU_PN] := .t.
      endif
  
    endif
    cVar := 'is_' + substr(str(countYear, 4), 3) + '_VMP'
    (lAlias)->(dbSelectArea())
    cSearch := glob_mo[_MO_KOD_TFOMS] + code_services_VMP(countYear)
    (lAlias)->(dbSeek(cSearch))
    __mvPut( cVar, (lAlias)->(found()) )
    (lAlias)->(dbCloseArea())
    next
  return nil