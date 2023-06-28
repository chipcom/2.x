#include 'ver_date.ch'
#include 'set.ch'
#include 'inkey.ch'
#include 'dbstruct.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

static st_version := {3, 6, 3, 'a+'}
static st_date_version := _DATA_VER
static st__s_full_name := '��� + ���� ࠡ��� ����樭᪮� �࣠����樨'

// 24.06.21 ������ ����� ���ᨨ
function _version()

  return st_version

// 24.06.21 ������ ���� ���ᨨ
function _date_version()
  
  return st_date_version

// 24.06.21 ������ ������������ �ணࠬ����� ��������
function __s_full_name()
  
  return st__s_full_name

// 23.06.21 ������ ��ப����� �।�⠢����� ���ᨨ
function __s_version()
  return '  �. ' + fs_version(_version()) + ' �� ' + _date_version() + ' ⥫.(8442)23-69-56'

// ������ ��ப� � ����஬ ���ᨨ
Function fs_version(aVersion)
  // aVersion - 4-���� ���ᨢ
  return lstr(aVersion[1]) + '.' + lstr(aVersion[2]) + '.' + lstr(aVersion[3]) + iif(len(aVersion) == 4, aVersion[4], '')

// 17.12.21 ������� �᫮��� ���祭�� ���ᨨ �� �����
function get_version_DB()
  local nfile := "ver_base"
  local ver__base := 0

  if hb_FileExists(dir_server + nfile + sdbf)
    R_Use(dir_server + nfile, , 'ver' )
    ver__base := ver->version
    ver->(dbCloseArea())
  endif
  return ver__base

// 15.02.23 ��࠭��� ����� �᫮��� ���祭�� ���ᨨ �� �����
function save_version_DB(nVersion)
  local nfile := 'ver_base'

  reconstruct(dir_server + nfile, {{'version', 'N', 10, 0}}, , , .t.)
  G_Use(dir_server + nfile, , 'ver')
  if lastrec() == 0
    AddRecN()
  else
    G_RLock(forever)
  endif
  replace version with nVersion
  ver->(dbCloseArea())
  return .t.

// 15.02.23 ����஫� ���ᨨ ���� ������
Function ControlVersion(aVersion, oldVersion)
  // aVersion - �஢��塞�� �����
  local ver__base
  local snversion := int(aVersion[1]*10000 + aVersion[2]*100 + aVersion[3])

  if (ver__base := get_version_DB()) != 0
    if snversion > ver__base
      return .t.
    elseif snversion == ver__base
      if asc(substr( oldVersion[4], 1, 1) ) < asc( aVersion[4] )
        return .t.
      endif
    endif
  endif
  return .f.

// 15.02.23 ����஫� ���ᨨ ���� ������
Function ControlBases(type_oper,aVersion)
  // type_oper  - ⨯ ����樨
  //    1 - ��᫥ ����᪠ �ணࠬ�� ����� ����� �� �� 䠩��
  //    2 - ���⢥न�� ࠧ�襭�� �� ४�������� (�� reconstruct)
  //    3 - ������� ��� ����� ���ᨨ �� (��᫥ ���樠����樨)
  // aVersion - ����� ��, ᮮ⢥������� ������ ᡮથ �ணࠬ��
  //            ��易⥫쭠 ��� ��ࢮ�� �맮�� (���ᨢ �� ���� ����⮢)
  Static sl_reconstr, snversion, sl_smena, nfile := 'ver_base'
  Local ret_value, ver__base

  DEFAULT sl_reconstr TO .t., sl_smena TO .f.
  do case
    case type_oper == 1
      DEFAULT snversion TO int(aVersion[1] * 10000 + aVersion[2] * 100 + aVersion[3])
      if (ver__base := get_version_DB()) != 0
        if snversion < ver__base
          func_error('�� �����⨫� ����� ����� �ணࠬ��. ����� ����饭�!')
          f_end()
        else
          sl_smena := (snversion != ver__base)
          sl_reconstr := .T.
        endif
      else
        sl_smena := .t.
      endif
      ret_value := sl_smena
    case type_oper == 2
      if !sl_reconstr
        func_error('�� �����⨫� ����� ����� �ணࠬ��. ����� ����饭�!')
        f_end()
      endif
      ret_value := sl_reconstr
    case type_oper == 3 .and. sl_smena
      save_version_DB(snversion)
  endcase
  return ret_value