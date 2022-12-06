#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 26.05.22 �஢�ઠ �� ᮮ⢥��⢨� ��㣨 ��䨫�
Function UslugaAccordanceProfil(lshifr, lvzros_reb, lprofil, ta, short_shifr)
  Local s := '', s1 := ''

  if valtype(short_shifr) == 'C' .and. !empty(short_shifr) .and. !(alltrim(lshifr) == alltrim(short_shifr))
    s1 := '(' + alltrim(short_shifr) + ')'
  endif
  if select('MOPROF') == 0
    R_Use(dir_exe + '_mo_prof', cur_dir + '_mo_prof', 'MOPROF')
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
          s += '"' + lstr(moprof->profil) + '.' + inieditspr(A__MENUVERT, glob_V002, moprof->profil) + '", '
          skip
        enddo
        aadd(ta, rtrim(lshifr) + s1 + ' - ��䨫� "' + lstr(lprofil) + '.' + ;
                inieditspr(A__MENUVERT, glob_V002, lprofil) + ;
                '" ��� ' + {'���᫮��', 'ॡ񭪠'}[lvzros_reb + 1] + ;
                ' �������⨬' + iif(empty(s), '', ' (ࠧ�蠥��� ' + left(s, len(s) - 2) + ')'))
      endif
    endif
  endif
  return lprofil
  
** 06.12.22 �஢�ઠ �� ᮮ⢥��⢨� ��㣨 ᯥ樠�쭮��
Function UslugaAccordancePRVS(lshifr, lvzros_reb, lprvs, ta, short_shifr, lvrach)
  Local s := '', s1 := '', s2, i, k
  local arr_conv_V015_V021 := conversion_V015_V021()

  if valtype(short_shifr) == 'C' .and. !empty(short_shifr) .and. !(alltrim(lshifr) == alltrim(short_shifr))
    s1 := '(' + alltrim(short_shifr) + ')'
  endif
  if select('MOSPEC') == 0
    R_Use(dir_exe + '_mo_spec', cur_dir + '_mo_spec', 'MOSPEC')
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
        // if (i := ascan(glob_arr_V015_V021, {|x| x[2] == k})) > 0 // ��ॢ�� �� 21-�� �ࠢ�筨��
        //   k := glob_arr_V015_V021[i, 1]                          // � 15-� �ࠢ�筨�
        // endif
        if (i := ascan(arr_conv_V015_V021, {|x| x[2] == k})) > 0 // ��ॢ�� �� 21-�� �ࠢ�筨��
          k := arr_conv_V015_V021[i, 1]                          // � 15-� �ࠢ�筨�
        endif
        s += '"' + lstr(k) + '.' + inieditspr(A__MENUVERT, getV015(), k) + '", '
        skip
      enddo
      pers->(dbGoto(lvrach))
      aadd(ta, rtrim(lshifr) + s1 + ' - (' + fam_i_o(pers->fio) + ' [' + lstr(pers->tab_nom) + ;
              ']) ᯥ樠�쭮��� "' + s2 + '" ��� ' + {'���᫮��', 'ॡ񭪠'}[lvzros_reb + 1] + ;
              ' �������⨬�' + iif(empty(s), '', ' (ࠧ�蠥��� ' + left(s, len(s) - 2) + ')'))
    endif
  endif
  return nil
  
** 26.05.22 ᮡ��� ���� ��� � ��砥
function collect_uslugi(rec_human)
  local human_number, human_uslugi, mohu_usluga
  local tmp_select := select()
  local arrUslugi := {}

  human_number := hb_DefaultValue(rec_human, human->(recno()))
  human_uslugi := hu->(recno())
  mohu_usluga := mohu->(recno())
  dbSelectArea('HU')

  find (str(human_number, 7))
  do while hu->kod == human_number .and. !eof()
    aadd(arrUslugi, alltrim(usl->shifr))
    hu->(dbSkip())
  enddo

  hu->(dbGoto(human_uslugi))

  dbSelectArea('MOHU')
  set relation to u_kod into MOSU
  find (str(human_number, 7))
  do while mohu->kod == human_number .and. !eof()
    aadd(arrUslugi, alltrim(iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)))
    mohu->(dbSkip())
  enddo
  mohu->(dbGoto(mohu_usluga))

  select(tmp_select)
  return arrUslugi

** 26.05.22 ᮡ��� ���� �������� ��� � ��砥
function collect_date_uslugi(rec_human)
  local human_number, human_uslugi, mohu_usluga
  local tmp_select := select()
  local arrDate := {}, aSortDate
  local i := 0, sDate, dDate

  human_number := hb_DefaultValue(rec_human, human->(recno()))
  human_uslugi := hu->(recno())
  mohu_usluga := mohu->(recno())
  dbSelectArea('HU')

  find (str(human_number, 7))
  do while hu->kod == human_number .and. !eof()
    dDate := c4tod(hu->date_u)
    sDate := dtoc(dDate)
    if ascan(arrDate, {|x| x[1] == sDate }) == 0
      i++
      aadd(arrDate, {sDate, i, dDate})
    endif
    hu->(dbSkip())
  enddo

  hu->(dbGoto(human_uslugi))

  dbSelectArea('MOHU')
  // set relation to u_kod into MOSU
  find (str(human_number, 7))
  do while mohu->kod == human_number .and. !eof()
    dDate := c4tod(mohu->date_u)
    sDate := dtoc(dDate)
    if ascan(arrDate, {|x| x[1] == sDate }) == 0
      i++
      aadd(arrDate, {sDate, i, dDate})
    endif
    mohu->(dbSkip())
  enddo
  mohu->(dbGoto(mohu_usluga))

  aSortDate := ASort(arrDate,,, { |x, y| x[3] < y[3] })  
  select(tmp_select)
  return aSortDate

** 27.05.22 - ������ �������� �६������ 䠩�� ��� ���ࠢ����� �� ���������
function create_struct_temporary_onkna()
  return { ; // �������ࠢ�����
    {'KOD'      , 'N',  7, 0}, ; // ��� ���쭮��
    {'NAPR_DATE', 'D',  8, 0}, ; // ��� ���ࠢ�����
    {'NAPR_MO'  , 'C',  6, 0}, ; // ��� ��㣮�� ��, �㤠 �믨ᠭ� ���ࠢ�����
    {'NAPR_V'   , 'N',  1, 0}, ; // ��� ���ࠢ�����:1-� ��������,2-�� ������,3-�� ����᫥�������,4-��� ���.⠪⨪� ��祭��
    {'MET_ISSL' , 'N',  1, 0}, ; // ��⮤ ���������᪮�� ��᫥�������(�� NAPR_V=3):1-���.�������⨪�;2-�����.�������⨪�;3-���.�������⨪�;4-��, ���, ���������
    {'SHIFR'    , 'C', 20, 0}, ;
    {'SHIFR_U'  , 'C', 20, 0}, ;
    {'SHIFR1'   , 'C', 20, 0}, ;
    {'NAME_U'   , 'C', 65, 0}, ;
    {'U_KOD'    , 'N',  6, 0}, ; // ��� ��㣨
    {'KOD_VR'   , 'N',  5, 0} ;  // ��� ��� (�ࠢ�筨� mo_pers)
  }

** 11.10.21
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
    // R_Use_base(dir_server+"human_u","__HU")
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
    * २��㧨� ��⮪஢� (��� st36.009, �롨ࠥ��� �� ��㣥 A16.20.078)
    * ��������� ����ਠ��⠫쭠� ���������� (��� st36.010, �롨ࠥ��� �� ��㣥 A16.12.030)
    * ���ࠪ�௮ࠫ쭠� ����࠭��� ��ᨣ����� (��� st36.011, �롨ࠥ��� �� ��㣥 A16.10.021.001)
    if is_ksg(lshifr) .and. ascan({'st36.009', 'st36.010', 'st36.011'}, alltrim(lshifr)) > 0
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