#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

  // public _version := {2, 11, 22, 'd+'}
  // public _date_version := '21.06.21�.'
  // public __s_full_name := '��� + ���� ࠡ��� ����樭᪮� �࣠����樨'

***** 23.06.21 ������ ����� ���ᨨ
function _version()

  // local version := {2, 11, 22, 'd+'}

  // return version
  return {2, 11, 22, 'd+'}

***** 23.06.21 ������ ���� ���ᨨ
function _date_version()
  
  // local _date := '21.06.21�.'

  // return _date
  return '21.06.21�.'

***** 23.06.21 ������ ������������ �ணࠬ����� ��������
function __s_full_name()
  
  return '��� + ���� ࠡ��� ����樭᪮� �࣠����樨'

***** 23.06.21 ������ ��ப����� �।�⠢����� ���ᨨ
function __s_version()
  return '  �. ' + fs_version(_version()) + ' �� ' + _date_version() + ' ⥫.(8442)23-69-56'
