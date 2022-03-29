
**** 01.10.21 - ������ �������� �६������ 䠩�� ��� ���ࠢ����� �� ���������
function create_struct_temporary_onkna()
  return {; // �������ࠢ�����
    {"KOD"      ,   "N",     7,     0},; // ��� ���쭮��
    {"NAPR_DATE",   "D",     8,     0},; // ��� ���ࠢ�����
    {"NAPR_MO",     "C",     6,     0},; // ��� ��㣮�� ��, �㤠 �믨ᠭ� ���ࠢ�����
    {"NAPR_V"  ,    "N",     1,     0},; // ��� ���ࠢ�����:1-� ��������,2-�� ������,3-�� ����᫥�������,4-��� ���.⠪⨪� ��祭��
    {"MET_ISSL" ,   "N",     1,     0},; // ��⮤ ���������᪮�� ��᫥�������(�� NAPR_V=3):1-���.�������⨪�;2-�����.�������⨪�;3-���.�������⨪�;4-��, ���, ���������
    {"shifr"  ,     "C",    20,     0},;
    {"shifr_u"  ,   "C",    20,     0},;
    {"shifr1"   ,   "C",    20,     0},;
    {"name_u"   ,   "C",    65,     0},;
    {"U_KOD"    ,   "N",     6,     0},;  // ��� ��㣨
    {"KOD_VR"   ,   "N",     5,     0};  // ��� ��� (�ࠢ�筨� mo_pers)
  }

**** 01.10.21
function get_kod_vrach_by_tabnom(tabnom)
  local aliasIsUse
  local oldSelect, ret := 0

  if tabnom == 0
    return 0
  endif

  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","TPERS") 
  endif

  if TPERS->(dbSeek(str(tabnom,5)))
    ret := TPERS->kod
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

**** 01.10.21
function get_tabnom_vrach_by_kod(kod)
  local aliasIsUse
  local oldSelect, ret := 0

  if kod == 0
    return ret
  endif
  
  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",,"TPERS") 
  endif

  TPERS->(dbGoto(kod))
  if ! (TPERS->(Eof()) .or. TPERS->(Bof()))
    ret := TPERS->tab_nom
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

**** 11.10.21
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
    R_Use(dir_server+"uslugi",,"__USL")
  endif

  aliasIsUseHU := aliasIsAlreadyUse('__HU')
  if ! aliasIsUseHU
    // R_Use_base(dir_server+"human_u","__HU")
    G_Use(dir_server+"human_u",{dir_server+"human_u",;
        dir_server+"human_uk",;
        dir_server+"human_ud",;
        dir_server+"human_uv",;
        dir_server+"human_ua"},"__HU",,.f.,.t.)
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
    if is_ksg(lshifr) .and. ascan({"st36.009","st36.010","st36.011"},alltrim(lshifr)) > 0
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

