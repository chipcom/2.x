#include 'ver_date.ch'
#include 'set.ch'
#include 'function.ch'
#include 'chip_mo.ch'

static st_version := {2, 11, 28, ''}
static st_date_version := _DATA_VER
static st__s_full_name := '��� + ���� ࠡ��� ����樭᪮� �࣠����樨'

***** 24.06.21 ������ ����� ���ᨨ
function _version()

  return st_version

***** 24.06.21 ������ ���� ���ᨨ
function _date_version()
  
  return st_date_version

***** 24.06.21 ������ ������������ �ணࠬ����� ��������
function __s_full_name()
  
return st__s_full_name

***** 23.06.21 ������ ��ப����� �।�⠢����� ���ᨨ
function __s_version()
  return '  �. ' + fs_version(_version()) + ' �� ' + _date_version() + ' ⥫.(8442)23-69-56'
