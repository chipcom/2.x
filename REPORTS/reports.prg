#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

***** 15.04.22 ᮧ���� 䠩� Excel �� ����⥪�
Function kartotekToExcel()
  Local mlen, t_mas := {}, i, ret
  Local strStatus := '^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - �⬥��� / ���� �⬥��'
  local sAsterisk := ' * ', sBlank := '   '

  local name_file := '��樥���'
  local name_file_full := name_file + '.xlsx'
  local aFilter

  // 1 - �������� �⮫��, 2 - �롮�, 3 - �⬥⪠, �� �㦥�, 4 - ���䨫���,  5 - �ਭ� �⮫��, 6 - ���. �ᯮ�������
  aadd(t_mas, { sAsterisk + 'N �/�', .f., .f., .f., 8.0, 'C' })
  aadd(t_mas, { sBlank + '���⮪', glob_mo[_MO_IS_UCH], .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + '�. �. �.', .f., .f., .f., 50.0, 'L' })
  aadd(t_mas, { sAsterisk + '��� ஦�����', .f., .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + '���', .f., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + '������', .t., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + '�����', .t., .f., .f., 15.0, 'C' })
  aadd(t_mas, { sBlank + '���客�� �࣠������', .t., .f., .f., 30.0, 'C' })
  aadd(t_mas, { sBlank + '���客�� �����', .t., .f., .f., 17.0, 'C' })
  aadd(t_mas, { sBlank + '�ਪ९�����', glob_mo[_MO_IS_UCH], .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + '���� ॣ����樨', .t., .f., .f., 50.0, 'C' })
  aadd(t_mas, { sBlank + '���� �ॡ뢠���', .t., .f., .f., 50.0, 'C' })
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

  aFilter := filter_to_kartotek_Excel()
  if exportKartExcel(hb_OemToAnsi(name_file_full), t_mas, aFilter)
    hb_vfErase(cur_dir + name_file_full)
  else
    SaveTo(cur_dir + name_file_full)
  endif

  return nil

****** 18.04.22
function filter_to_kartotek_Excel()
  local aCondition := {{' = ', 1}, {' > ', 2}, {' < ', 3}}
  local notUsed := {'�� �ਬ�����', 1}
  local aGender := {notUsed, {'��᪮�', 2}, {'���᪨�', 3}}
  local aDOB := {notUsed, {'�� ��� ஦�����', 2}, {'�� �������', 3}}
  local minDOB := CToD('')
  local maxDOB := minDOB
  local dAge := minDOB
  local nAge := 0
  local iRow := 9
  local oBox, tmp_keys, tmp_gets
  local aReturn := Array(5)

  private mGender, m1Gender
  private mDOB, m1DOB
  private mCondition, m1Condition

  m1Gender := 1
  mGender := inieditspr(A__MENUVERT, aGender, m1Gender)
  m1DOB := 1
  mDOB := inieditspr(A__MENUVERT, aDOB, m1DOB)
  m1Condition := 1
  mCondition := inieditspr(A__MENUVERT, aCondition, m1Condition)

	tmp_keys := my_savekey()
	save gets to tmp_gets

	oBox := TBox():New( iRow, 8, iRow + 5, 70, .t. )
	oBox:CaptionColor := 'B/B*'
	oBox:Color := cDataCGet
	oBox:MessageLine := '^<Esc>^ - ��室;  ^<PgDn>^ - ���⢥ত���� �����'
	oBox:Caption := '�롥�� ����� ��� 䨫���'
	oBox:View()

	do while .t.
		iRow := 9

    @ ++iRow, 12 say '���:' get mGender ;
          reader {|x| menu_reader(x, aGender, A__MENUVERT, , , .f.)}

    @ ++iRow, 12 say '��� ஦�����:' get mDOB ;
      reader {|x| menu_reader(x, aDOB, A__MENUVERT, , , .f.)}

    // @ ++iRow, 12 say '��� ஦����� (�������쭠�):' get minDOB
    // @ ++iRow, 12 say '��� ஦����� (���ᨬ��쭠�):' get maxDOB
    if m1DOB == 2
      @ ++iRow, 15 say '�������쭠�:' get minDOB when m1DOB == 2
      @ iRow, col() + 4 say '���ᨬ��쭠�:' get maxDOB when m1DOB == 2
    elseif m1DOB == 3
      @ ++iRow, 15 say '������:' get nAge picture '999' when m1DOB == 3
      @ iRow, col() + 2 say '�᫮���:' get mCondition ;
          reader {|x| menu_reader(x, aCondition, A__MENUVERT, , , .f.)} ;
          when m1DOB == 3
      @ iRow, col() + 2 say '��� ����:' get dAge when m1DOB == 3
    endif

		myread()
		if lastkey() == K_PGDN
      aReturn[1] := m1Gender
      aReturn[2] := m1DOB
      if m1DOB == 2 // �⡮� �� ��� ஦�����
        aReturn[3] := minDOB
        aReturn[4] := maxDOB
      elseif m1DOB == 3 // �⡮� �� �������
        aReturn[3] := nAge
        aReturn[4] := m1Condition
        aReturn[5] := dAge
      endif
			exit
		elseif lastkey() == K_ESC
      aReturn := nil
			exit
		endif
	enddo
	update_gets()

	oBox := nil
	restore gets from tmp_gets
	my_restkey( tmp_keys )
  return aReturn

***** 18.04.22 �஢�ઠ ��� 䨫��� �� ��ப� ��
function control_filter_kartotek(cAliasKart, cAliasKart2, cAliasKart_, aFilter)
  local lRet := .t.
  local age

  if (cAliasKart)->KOD == 0   // �ய��⨬ ����� �����
    lRet := .f.
  endif

  if left((cAliasKart2)->PC2, 1) == '1'  // �롨ࠥ� ⮫쪮 �����
    lRet := .f.
  endif

  if lRet .and. aFilter != nil
    if aFilter[1] != 1  // 䨫��� �� ����
      if aFilter[1] == 2
        if (cAliasKart)->pol != '�'
          lRet := .f.
        endif
      elseif lRet .and. aFilter[1] == 3
        if (cAliasKart)->pol != '�'
            lRet := .f.
        endif
      endif
    endif
    if lRet .and. aFilter[2] == 2
      if !empty(aFilter[3])   // 䨫��� �� ��� ஦����� (���)
        if (cAliasKart)->DATE_R < aFilter[3]
          lRet := .f.
        endif
      endif
      if !empty(aFilter[4])   // 䨫��� �� ��� ஦����� (����)
        if (cAliasKart)->DATE_R > aFilter[4]
          lRet := .f.
        endif
      endif
    elseif lRet .and. aFilter[2] == 3
      age := count_years((cAliasKart)->DATE_R, aFilter[5])
      if aFilter[4] == 1
        if aFilter[3] != age  // ������ ࠢ��
          lRet := .f.
        endif
      elseif aFilter[4] == 2  // ������ �����
        if aFilter[3] < age
          lRet := .f.
        endif
      elseif aFilter[4] == 3  // ������ �����
        if aFilter[3] > age
          lRet := .f.
        endif
      endif
    endif
  endif
  return lRet