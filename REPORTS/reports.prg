#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

***** 22.04.21 ᮧ���� 䠩� Excel �� ����⥪�
Function kartotekToExcel()
  Local mlen, t_mas := {}, i, ret
  Local strStatus := '^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - �⬥��� / ���� �⬥��'
  local sAsterisk := ' * ', sBlank := '   '

  local name_file := '��樥���'
  local name_file_full := name_file + '.xlsx'

  // if (dCreate := input_value( 20, 9, 22, 70, color1, ;
  //     '���, �� ������ ����室��� ������� ���ଠ��', ;
  //     sys_date)) != nil

  // 1 - �������� �⮫��, 2 - �롮�, 3 - �⬥⪠, �� �㦥�, 4 - ���䨫���,  5 - �ਭ� �⮫��, 6 - ���. �ᯮ�������
  aadd(t_mas, { sAsterisk + 'N �/�', .f., .f., .f., 8.0, 'C' })
  aadd(t_mas, { sBlank + '���⮪', glob_mo[_MO_IS_UCH], .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + '�. �. �.', .f., .f., .f., 50.0, 'L' })
  aadd(t_mas, { sAsterisk + '��� ஦�����', .f., .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + '���', .f., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + '������', .t., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + '�����', .t., .f., .f., 15.0, 'C' })
  aadd(t_mas, { sBlank + '���� ॣ����樨', .t., .f., .f., 50.0, 'C' })
  aadd(t_mas, { sBlank + '���客�� �࣠������', .t., .f., .f., 30.0, 'C' })
  aadd(t_mas, { sBlank + '���客�� �����', .t., .f., .f., 17.0, 'C' })
  aadd(t_mas, { sBlank + '����䮭', .t., .f., .f., 17.0, 'C' })

  mlen := len(t_mas)

  // �ᯮ��㥬 popupN �� ������⥪� FunLib
  if (ret := popupN( 5, 10, 15, 71, t_mas, i, color0, .t., 'fmenu_readerN',,;
      '�⬥��� �㦭� ����', col_tit_popup,, strStatus)) > 0
    for i := 1 to mlen
      if "*" == substr(t_mas[i, 1],2,1)
        t_mas[i,3] := .t.
      endif
      t_mas[i, 1] := substr(t_mas[i, 1], 4)
    next
  endif 

  exportKartExcel(hb_OemToAnsi(name_file_full), t_mas)
  SaveTo(cur_dir + name_file_full)
  // endif

  return nil

