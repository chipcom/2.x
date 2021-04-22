#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

***** 22.04.21 создать файл Excel из картотеки
Function kartotekToExcel()
  Local mlen, t_mas := {}, i, ret
  Local strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'
  local sAsterisk := ' * ', sBlank := '   '

  local name_file := 'Пациенты'
  local name_file_full := name_file + '.xlsx'

  // if (dCreate := input_value( 20, 9, 22, 70, color1, ;
  //     'Дата, на которую необходимо получить информацию', ;
  //     sys_date)) != nil

  // 1 - название столбца, 2 - выбор, 3 - отметка, что нужен, 4 - автофильтр,  5 - ширина столбца, 6 - гор. расположение
  aadd(t_mas, { sAsterisk + 'N п/п', .f., .f., .f., 8.0, 'C' })
  aadd(t_mas, { sBlank + 'Участок', glob_mo[_MO_IS_UCH], .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + 'Ф. И. О.', .f., .f., .f., 50.0, 'L' })
  aadd(t_mas, { sAsterisk + 'Дата рождения', .f., .f., .f., 10.0, 'C' })
  aadd(t_mas, { sAsterisk + 'Пол', .f., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + 'Возраст', .t., .f., .t., 10.0, 'C' })
  aadd(t_mas, { sBlank + 'СНИЛС', .t., .f., .f., 15.0, 'C' })
  aadd(t_mas, { sBlank + 'Адрес регистрации', .t., .f., .f., 50.0, 'C' })
  aadd(t_mas, { sBlank + 'Страховая организация', .t., .f., .f., 30.0, 'C' })
  aadd(t_mas, { sBlank + 'Страховой полис', .t., .f., .f., 17.0, 'C' })
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

  exportKartExcel(hb_OemToAnsi(name_file_full), t_mas)
  SaveTo(cur_dir + name_file_full)
  // endif

  return nil

