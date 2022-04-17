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
  exportKartExcel(hb_OemToAnsi(name_file_full), t_mas, aFilter)
  SaveTo(cur_dir + name_file_full)

  return nil

****** 15.04.22
function filter_to_kartotek_Excel()
  local aGender := {{'все', 1}, {'мужской', 2}, {'женский', 3}}
  local minDOB := maxDOB := CToD('')
  local iRow := 11
  local oBox, tmp_keys, tmp_gets
  local aReturn := Array(3)

  private mGender, m1Gender

  m1Gender := 1
  mGender := inieditspr(A__MENUVERT, aGender, m1Gender)

	tmp_keys := my_savekey()
	save gets to tmp_gets

	oBox := TBox():New( iRow, 10, iRow + 5, 70, .t. )
	oBox:CaptionColor := 'B/B*'
	oBox:Color := cDataCGet
	oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
	oBox:Caption := 'Выберите данные для фильтра'
	oBox:View()

	do while .t.
		iRow := 12

    @ ++iRow, 12 say 'Пол:' get mGender ;
          reader {|x| menu_reader(x, aGender, A__MENUVERT, , , .f.)}

    @ ++iRow, 12 say 'Дата рождения (минимальная):' get minDOB
    @ ++iRow, 12 say 'Дата рождения (максимальная):' get maxDOB

		myread()
		if lastkey() == K_PGDN
      aReturn[1] := m1Gender
      aReturn[2] := minDOB
      aReturn[3] := maxDOB
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

***** 17.04.22 проверка для фильтра на строку БД
function control_filter_kartotek(cAliasKart, cAliasKart2, cAliasKart_, aFilter)
  local lRet := .t.

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
    if lRet .and. !empty(aFilter[2])   // фильтр по дате рождения (мин)
      if (cAliasKart)->DATE_R < aFilter[2]
        lRet := .f.
      endif
    endif
    if lRet .and. !empty(aFilter[3])   // фильтр по дате рождения (макс)
      if (cAliasKart)->DATE_R > aFilter[3]
        lRet := .f.
      endif
    endif
  endif
  return lRet