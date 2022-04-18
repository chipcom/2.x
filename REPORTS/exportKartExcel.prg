#include 'inkey.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hblibxlsxwriter.ch'

***** 18.04.22 создать файл Excel
function exportKartExcel(fName, aCondition, aFilter)
  *** возвращает .t. - если построение прервано иначе .f.
  local workbook
  local header
  local worksheet
  local formatDate
  local fmtCellNumber, fmtCellString, fmtCellStringCenter
  local arr_fio, row, curr, i, j, fl_exit := .f., s

  if aFilter == nil // пустое значение для фильтров
    return .t.
  endif

  lxw_init() 

  if hb_FileExists(fName)  
    filedelete(fName)
  endif

  workbook  := lxw_workbook_new(fName)
  worksheet := lxw_workbook_add_worksheet(workbook, 'Пациенты' )

  formatDate := lxw_workbook_add_format(workbook)
  lxw_format_set_num_format(formatDate, 'dd/mm/yyyy')
  lxw_format_set_align(formatDate, LXW_ALIGN_CENTER)
  lxw_format_set_align(formatDate, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_border(formatDate, LXW_BORDER_THIN)

  header = lxw_workbook_add_format(workbook)
  lxw_format_set_align(header, LXW_ALIGN_CENTER)
  lxw_format_set_align(header, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_fg_color(header, 0xD7E4BC)
  lxw_format_set_bold(header)
  lxw_format_set_border(header, LXW_BORDER_THIN)

  header_wrap = lxw_workbook_add_format(workbook)
  lxw_format_set_align(header_wrap, LXW_ALIGN_CENTER)
  lxw_format_set_align(header_wrap, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_fg_color(header_wrap, 0xD7E4BC)
  lxw_format_set_bold(header_wrap)
  lxw_format_set_border(header_wrap, LXW_BORDER_THIN)
  lxw_format_set_text_wrap(header_wrap)

  fmtCellNumber := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmtCellNumber, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmtCellNumber, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_border(fmtCellNumber, LXW_BORDER_THIN)

  fmtCellString := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmtCellString, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmtCellString, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmtCellString)
  lxw_format_set_border(fmtCellString, LXW_BORDER_THIN)

  fmtCellStringCenter := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmtCellStringCenter, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmtCellStringCenter, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmtCellStringCenter)
  lxw_format_set_border(fmtCellStringCenter, LXW_BORDER_THIN)

  // шапка
  /* Установить высоту строки */
  lxw_worksheet_set_row(worksheet, 0, 35.0)
  lxw_worksheet_set_row(worksheet, 2, 35.0)
  /* Заморозим 3-е верхние строки на закладке. */
  lxw_worksheet_freeze_panes(worksheet, 3, 0)

  j := 0
  for i := 1 to len(aCondition)
    if aCondition[i, 3]
      lxw_worksheet_set_column(worksheet, j, j, aCondition[i, 5])
      lxw_worksheet_write_string(worksheet, 2, j, hb_StrToUtf8( aCondition[i, 1] ), header_wrap)
      j++
    endif
  next

  R_Use(dir_server + 'kartote2', , 'KART2')
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_, to recno() into KART2

  hGauge := GaugeNew(, , , hb_Utf8ToStr('Экспорт картотеки в Excel','RU866'), .t.)
  GaugeDisplay( hGauge )
  row := 3
  curr := 0

  KART->(dbGoTop())
  do while  ! KART->(eof())
    GaugeUpdate( hGauge, ++curr / KART->(lastrec()) )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif

    if control_filter_kartotek('KART', 'KART2', 'KART_', aFilter)
      j := 0
      for i := 1 to len(aCondition)
        if i == 1
          lxw_worksheet_write_number(worksheet, row, j, row - 2, fmtCellNumber)
          j++
        endif
        if i == 2 .and. aCondition[i,3]
          lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( iif(!empty(kart->uchast), lstr(kart->uchast), '') ), fmtCellStringCenter)
          j++
        endif
        if i == 3
          arr_fio := retFamImOt( 1, .f., .f. )
          lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( arr_fio[1] + ' ' + arr_fio[2] + ' ' + arr_fio[3] ), fmtCellString)
          j++
        endif
        if i == 4
          lxw_worksheet_write_datetime(worksheet, row, j, HB_STOT(DToS(KART->DATE_R)), formatDate)
          j++
        endif
        if i == 5
          lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( KART->POL ), fmtCellStringCenter)
          j++
        endif
        if i == 6 .and. aCondition[i,3]
          lxw_worksheet_write_number(worksheet, row, j, count_years(KART->DATE_R, date()), fmtCellNumber)
          j++
        endif
        if i == 7 .and. aCondition[i,3]
          lxw_worksheet_write_string(worksheet, row, j, iif(empty(KART->SNILS), '', transform(KART->SNILS, picture_pf)), fmtCellStringCenter)
          j++
        endif
        if i == 8 .and. aCondition[i,3]
          lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( smo_to_screen(1) ), fmtCellString)
          j++
        endif
        if i == 9 .and. aCondition[i,3]
          lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( ltrim(KART_->NPOLIS) ), fmtCellString)
          j++
        endif
        if i == 10 .and. aCondition[i,3]
          if empty(KART2->MO_PR)
            s := '?'
          elseif kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
            s := 'X'
          else
            s := '-'
          endif
          lxw_worksheet_write_string(worksheet, row, j, s, fmtCellStringCenter)
          j++
        endif
        if i == 11 .and. aCondition[i,3]  // адрес регистрации
          lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( ret_okato_ulica(KART->adres, KART_->okatog) ), fmtCellString)
          j++
        endif
        if i == 12 .and. aCondition[i,3]  // адрес пребывания
          if empty(KART_->adresp) .and. aCondition[11,3]
            lxw_worksheet_write_string(worksheet, row, j, 'тот же', fmtCellString)
          elseif empty(KART_->adresp) .and. ! aCondition[11, 3]
            lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( ret_okato_ulica(KART->adres, KART_->okatog) ), fmtCellString)
          elseif ! empty(KART_->adresp)
            lxw_worksheet_write_string(worksheet, row, j, hb_StrToUtf8( ret_okato_ulica(KART_->adresp, KART_->okatop) ), fmtCellString)
          endif
          j++
        endif
        if i == 13 .and. aCondition[i,3]
          s := ''
          if !empty(kart_->PHONE_H)
            s += 'д.' + alltrim(kart_->PHONE_H) + ' '
          endif
          if !empty(kart_->PHONE_M)
            s += 'м.' + alltrim(kart_->PHONE_M) + ' '
          endif
          if !empty(kart_->PHONE_W)
            s += 'р.' + alltrim(kart_->PHONE_W)
          endif
          lxw_worksheet_write_string(worksheet, row, j, s, fmtCellString)
          j++
        endif
      next
      ++row
    endif
    
    KART->(dbSkip())
  enddo
  KART->(dbCloseAll())

  // lxw_worksheet_autofilter(worksheet, 2, 3, row - 1, 4)
  // 1 - название столбца, 2 - выбор, 3 - отметка, что нужен, 4 - автофильтр,  5 - ширина столбца, 6 - гор. расположение
  // j := 0
  // for i := 1 to len(aCondition)
  //   if aCondition[i, 3]
  //     if aCondition[i, 4] // включить автофильтр
  //       lxw_worksheet_autofilter(worksheet, 2, j, row - 1, j)
  //     endif
  //     j++
  //   endif
  // next

  if fl_exit
    func_error(4, hb_Utf8ToStr('Операция прервана!','RU866'))
  endif

  lxw_workbook_close(workbook)

  CloseGauge(hGauge)

  return fl_exit
