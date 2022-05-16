#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

***** 15.04.22 создать файл Excel из картотеки
Function kartotekToExcel()
  Local mlen, t_mas := {}, i, ret
  Local strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'
  local sAsterisk := ' * ', sBlank := '   '

  local name_file := 'Пациенты'
  local name_file_full := name_file + '.xlsx'
  local aFilter

  // 1 - название столбца, 2 - выбор, 3 - отметка, что нужен, 4 - автофильтр,  5 - ширина столбца, 6 - гор. расположение
  aadd(t_mas, { sAsterisk + 'N п/п', .f., .f., .f., 8.0, 'C' })
  aadd(t_mas, { sBlank + 'Участок', glob_mo[_MO_IS_UCH], .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + 'Ф. И. О.', .f., .f., .f., 50.0, 'L' })
  aadd(t_mas, { sAsterisk + 'Дата рождения', .f., .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + 'Пол', .f., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + 'Возраст', .t., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + 'СНИЛС', .t., .f., .f., 15.0, 'C' })
  aadd(t_mas, { sBlank + 'Страховая организация', .t., .f., .f., 30.0, 'C' })
  aadd(t_mas, { sBlank + 'Страховой полис', .t., .f., .f., 17.0, 'C' })
  aadd(t_mas, { sBlank + 'Прикрепление', glob_mo[_MO_IS_UCH], .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + 'Адрес регистрации', .t., .f., .f., 50.0, 'C' })
  aadd(t_mas, { sBlank + 'Адрес пребывания', .t., .f., .f., 50.0, 'C' })
  aadd(t_mas, { sBlank + 'Телефон', .t., .f., .f., 17.0, 'C' })

  mlen := len(t_mas)

  // используем popupN из библиотеки FunLib
  if (ret := popupN( 5, 10, 15, 71, t_mas, i, color0, .t., 'fmenu_readerN',,;
      'Отметьте нужные поля', col_tit_popup,, strStatus)) > 0
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
  local notUsed := {'не применять', 1}
  local aGender := {notUsed, {'мужской', 2}, {'женский', 3}}
  local aDOB := {notUsed, {'по дате рождения', 2}, {'по возрасту', 3}}
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
	oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
	oBox:Caption := 'Выберите данные для фильтра'
	oBox:View()

	do while .t.
		iRow := 9

    @ ++iRow, 12 say 'Пол:' get mGender ;
          reader {|x| menu_reader(x, aGender, A__MENUVERT, , , .f.)}

    @ ++iRow, 12 say 'Дата рождения:' get mDOB ;
      reader {|x| menu_reader(x, aDOB, A__MENUVERT, , , .f.)}

    // @ ++iRow, 12 say 'Дата рождения (минимальная):' get minDOB
    // @ ++iRow, 12 say 'Дата рождения (максимальная):' get maxDOB
    if m1DOB == 2
      @ ++iRow, 15 say 'минимальная:' get minDOB when m1DOB == 2
      @ iRow, col() + 4 say 'максимальная:' get maxDOB when m1DOB == 2
    elseif m1DOB == 3
      @ ++iRow, 15 say 'возраст:' get nAge picture '999' when m1DOB == 3
      @ iRow, col() + 2 say 'условие:' get mCondition ;
          reader {|x| menu_reader(x, aCondition, A__MENUVERT, , , .f.)} ;
          when m1DOB == 3
      @ iRow, col() + 2 say 'дата отчета:' get dAge when m1DOB == 3
    endif

		myread()
		if lastkey() == K_PGDN
      aReturn[1] := m1Gender
      aReturn[2] := m1DOB
      if m1DOB == 2 // отбор по дате рождения
        aReturn[3] := minDOB
        aReturn[4] := maxDOB
      elseif m1DOB == 3 // отбор по возрасту
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

***** 18.04.22 проверка для фильтра на строку БД
function control_filter_kartotek(cAliasKart, cAliasKart2, cAliasKart_, aFilter)
  local lRet := .t.
  local age

  if (cAliasKart)->KOD == 0   // пропустим пустые записи
    lRet := .f.
  endif

  if left((cAliasKart2)->PC2, 1) == '1'  // выбираем только живых
    lRet := .f.
  endif

  if lRet .and. aFilter != nil
    if aFilter[1] != 1  // фильтр по полу
      if aFilter[1] == 2
        if (cAliasKart)->pol != 'М'
          lRet := .f.
        endif
      elseif lRet .and. aFilter[1] == 3
        if (cAliasKart)->pol != 'Ж'
            lRet := .f.
        endif
      endif
    endif
    if lRet .and. aFilter[2] == 2
      if !empty(aFilter[3])   // фильтр по дате рождения (мин)
        if (cAliasKart)->DATE_R < aFilter[3]
          lRet := .f.
        endif
      endif
      if !empty(aFilter[4])   // фильтр по дате рождения (макс)
        if (cAliasKart)->DATE_R > aFilter[4]
          lRet := .f.
        endif
      endif
    elseif lRet .and. aFilter[2] == 3
      age := count_years((cAliasKart)->DATE_R, aFilter[5])
      if aFilter[4] == 1
        if aFilter[3] != age  // возраст равен
          lRet := .f.
        endif
      elseif aFilter[4] == 2  // возраст больше
        if aFilter[3] < age
          lRet := .f.
        endif
      elseif aFilter[4] == 3  // возраст меньше
        if aFilter[3] > age
          lRet := .f.
        endif
      endif
    endif
  endif
  return lRet