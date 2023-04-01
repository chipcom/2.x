#include 'set.ch'
#include 'dbstruct.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'common.ch'

// 01.04.23 �������/��
function get_komitet()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'name', 'C', 30, 0, nil, nil, ;
                       space(30), nil, '��������'})
    aadd(arr, {'fname', 'C', 70, 0, nil, nil, ;
                       space(70), nil, '������ ������������'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, ;
                       space(20), nil, '���/���'})
    aadd(arr, {'adres', 'C', 50, 0, nil, nil, ;
                       space(50), nil, '����'})
    aadd(arr, {'telefon', 'C', 8, 0, nil, nil, ;
                       '  -  -  ', nil, '����䮭'})
    aadd(arr, {'bank', 'C', 70, 0, nil, nil, ;
                       space(70), nil, '����'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, ;
                       '���'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, ;
                       '������ ���'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, ;
                       '����.���'})
    aadd(arr, {'okonh', 'C', 15, 0, nil, nil, space(15), nil, ;
                       '��� �� �����'})
    aadd(arr, {'okpo', 'C', 15, 0, nil, nil, space(15), nil, ;
                       '��� �� ����'})
    aadd(arr, {'parakl', 'N', 1, 0, nil, ;
                       {|x|menu_reader(x, mm_danet, A__MENUVERT)}, ;
                       0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
                       '������� ����������� � �㬬� ��� �� ������� ������� (��):'})
    aadd(arr, {'ist_fin', 'N', 1, 0, nil, ;
                       {|x|menu_reader(x, mm1ist_fin, A__MENUVERT)}, ;
                       0, {|x|inieditspr(A__MENUVERT, mm1ist_fin, x)}, ;
                       '���筨� 䨭���஢����:'})
  endif
  return arr

// 01.04.23 ��稥 ���客�
function get_strah()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'name', 'C', 30, 0, nil, nil, ;
      space(30), nil, '��������'})
    aadd(arr, {'fname', 'C', 70, 0, nil, nil, ;
      space(70), nil, '������ ������������'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, ;
      space(20), nil, '���/���'})
    aadd(arr, {'adres', 'C', 50, 0, nil, nil, ;
      space(50), nil, '����'})
    aadd(arr, {'telefon', 'C', 8, 0, nil, nil, ;
      '  -  -  ', nil, '����䮭'})
    aadd(arr, {'bank', 'C', 70, 0, nil, nil, ;
      space(70), nil, '����'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, ;
      '���'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, ;
      '������ ���'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, ;
      '����.���'})
    aadd(arr, {'okonh', 'C', 15, 0, nil, nil, space(15), nil, ;
      '��� �� �����'})
    aadd(arr, {'okpo', 'C', 15, 0, nil, nil, space(15), nil, ;
      '��� �� ����'})
    aadd(arr, {'tfoms', 'N', 2, 0, nil, nil, 0, nil, ;
      '��� �����', , {||.f.}})
    aadd(arr, {'parakl', 'N', 1, 0, nil, ;
      {|x|menu_reader(x, mm_danet, A__MENUVERT)}, ;
      0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
      '������� ����������� � �㬬� ��� �� ������ ��������:'})
    aadd(arr, {'ist_fin', 'N', 1, 0, nil, ;
      {|x|menu_reader(x, mm1ist_fin, A__MENUVERT)}, ;
      0, {|x|inieditspr(A__MENUVERT, mm1ist_fin, x)}, ;
     '���筨� 䨭���஢����:'})
  endif
  return arr

// 01.04.23 ���� � �।����� �� ������������ ��� ������ ���
function get_DMS()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'name', 'C', 30, 0, nil, nil, ;
      space(30), nil, '��������'})
    aadd(arr, {'fname', 'C', 70, 0, nil, nil, ;
      space(70), nil, '������ ������������'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, ;
      space(20), nil, '���/���'})
    aadd(arr, {'adres', 'C', 100, 0, nil, nil, ;
      space(100), nil, '����'})
    aadd(arr, {'telefon', 'C', 8, 0, nil, nil, ;
      '  -  -  ', nil, '����䮭'})
    aadd(arr, {'bank', 'C', 100, 0, nil, nil, ;
      space(100), nil, '����'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, ;
      '���'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, ;
      '������ ���'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, ;
      '����.���'})
    aadd(arr, {'n_dog', 'C', 30, 0, nil, nil, space(30), nil, ;
      '����� �������'})
    aadd(arr, {'d_dog', 'D', 8, 0, nil, nil, ctod(''), nil, ;
      '��� �������'})
  endif
  return arr

// 01.04.23 ��� �࣠������
function get_struct_organiz()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'kod_tfoms', 'C', 8, 0, nil, nil, ;
      space(8), nil, '�������樮��� ��� �� � �����', ;
      {|g| valid_kod_tfoms(g) }, {|| hb_user_curUser:IsAdmin()}})
    aadd(arr, {'name_tfoms', 'C', 60, 0, nil, , '', , '������������ (� �����)', , {|| .f.}})
    aadd(arr, {'uroven', 'N', 1, 0, nil, , 0, , '�஢��� 業 ��襩 ��', , {|| .f.}})
    aadd(arr, {'name', 'C', 130, 0, nil, nil, space(130), nil, '��������'})
    aadd(arr, {'name_schet', 'C', 130, 0, nil, nil, space(130), nil, '�������� ��� ����'})
    aadd(arr, {'name_xml', 'C', 255, 0, nil, nil, space(255), nil, '�������� ��� ���⠫� �� ��'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, space(20), nil, '���/���'})
    aadd(arr, {'adres', 'C', 70, 0, nil, nil, space(70), nil, '����'})
    aadd(arr, {'telefon', 'C', 20, 0, nil, nil, space(20), nil, '����䮭'})
    aadd(arr, {'bank', 'C', 130, 0, nil, nil, space(130), nil, '����'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, '���'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, '������ ���'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, '����.���'})
    aadd(arr, {'okonh', 'C', 15, 0, nil, nil, space(15), nil, '��� �� �����'})
    aadd(arr, {'okpo', 'C', 15, 0, nil, nil, space(15), nil, '��� �� ����'})
    aadd(arr, {'e_1', 'C', 1, 0, nil, nil, ;
      space(1), nil, '������᪨� ४������ ��� ����᫥��� ������ �� �।�� ��ᨤ�� �����:', , ;
      {|| .f.}})
    aadd(arr, {'name2', 'C', 130, 0, nil, nil, space(130), nil, space(5) + '- ��������'})
    aadd(arr, {'bank2', 'C', 130, 0, nil, nil, space(130), nil, space(5) + '- ����'})
    aadd(arr, {'smfo2', 'C', 10, 0, nil, nil, space(10), nil, space(5) + '- ���'})
    aadd(arr, {'r_schet2', 'C', 45, 0, nil, nil, space(45), nil, space(5) + '- ����� ���'})
    aadd(arr, {'k_schet2', 'C', 20, 0, nil, nil, space(20), nil, space(5) + '- ����.���'})
    aadd(arr, {'ogrn', 'C', 15, 0, ,, space(15), , '���� ���'})
    aadd(arr, {'ruk_fio', 'C', 60, 0, ,, space(60), , '�.�.�. �������� ���'})
    aadd(arr, {'ruk', 'C', 20, 0, ,, space(20), , '������� � ���樠�� �������� ��� (��.�����)'})
    aadd(arr, {'ruk_r', 'C', 20, 0, ,, space(20), , '������� � ���樠�� �������� ��� (த.�����)'})
    aadd(arr, {'bux', 'C', 20, 0, ,, space(20), , '������� � ���樠�� �������� ��壠���'})
    aadd(arr, {'ispolnit', 'C', 20, 0, ,, space(20), , '�.�.�. �ᯮ���⥫� ��� ��⮢ ���'})
    aadd(arr, {'name_d', 'C', 32, 0, ,, space(32), , '������������ ��-�� (��� �������)'})
    aadd(arr, {'filial_h', 'N', 1, 0, nil, ;
      {|x|menu_reader(x, mm_filial_tf, A__MENUVERT)}, ;
      0, {|x|inieditspr(A__MENUVERT, mm_filial_tf, x)}, ;
      '������ �����, � ����� ��ࠢ����� 䠩� � 室�⠩�⢠��'})
  endif
  return arr
