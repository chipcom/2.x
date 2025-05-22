#include 'inkey.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

// 19.05.25 создать файл Excel
function exportKartExcel( fName, aCondition, aFilter )
  // возвращает .t. - если построение прервано иначе .f.
  local workbook
  local header, header_wrap
  local worksheet
  local formatDate
  local fmtCellNumber, fmtCellString, fmtCellStringCenter
  local arr_fio, row, curr, i, j, fl_exit := .f., s, hGauge

  if aFilter == nil // пустое значение для фильтров
    return .t.
  endif

  if hb_FileExists( fName )
    filedelete( fName )
  endif

  workbook  := WORKBOOK_NEW( fName )
  worksheet := WORKBOOK_ADD_WORKSHEET( workbook, 'Пациенты' )

  formatDate := WORKBOOK_ADD_FORMAT( workbook )
  FORMAT_SET_NUM_FORMAT( formatDate, 'dd/mm/yyyy' )
  FORMAT_SET_ALIGN( formatDate, LXW_ALIGN_CENTER )
  FORMAT_SET_ALIGN( formatDate, LXW_ALIGN_VERTICAL_CENTER )
  FORMAT_SET_BORDER( formatDate, LXW_BORDER_THIN )

  header = WORKBOOK_ADD_FORMAT( workbook )
  FORMAT_SET_ALIGN( header, LXW_ALIGN_CENTER )
  FORMAT_SET_ALIGN( header, LXW_ALIGN_VERTICAL_CENTER )
  FORMAT_SET_FG_COLOR( header, 0xD7E4BC )
  FORMAT_SET_BOLD( header )
  FORMAT_SET_BORDER( header, LXW_BORDER_THIN )

  header_wrap = WORKBOOK_ADD_FORMAT( workbook )
  FORMAT_SET_ALIGN( header_wrap, LXW_ALIGN_CENTER )
  FORMAT_SET_ALIGN( header_wrap, LXW_ALIGN_VERTICAL_CENTER )
  FORMAT_SET_FG_COLOR( header_wrap, 0xD7E4BC )
  FORMAT_SET_BOLD( header_wrap )
  FORMAT_SET_BORDER( header_wrap, LXW_BORDER_THIN )
  FORMAT_SET_TEXT_WRAP( header_wrap )

  fmtCellNumber := WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(fmtCellNumber, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(fmtCellNumber, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_BORDER(fmtCellNumber, LXW_BORDER_THIN)

  fmtCellString := WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(fmtCellString, LXW_ALIGN_LEFT)
  FORMAT_SET_ALIGN(fmtCellString, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_TEXT_WRAP(fmtCellString)
  FORMAT_SET_BORDER(fmtCellString, LXW_BORDER_THIN)

  fmtCellStringCenter := WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(fmtCellStringCenter, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(fmtCellStringCenter, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_TEXT_WRAP(fmtCellStringCenter)
  FORMAT_SET_BORDER(fmtCellStringCenter, LXW_BORDER_THIN)

  // шапка
  /* Установить высоту строки */
  WORKSHEET_SET_ROW( worksheet, 0, 35.0 )
  WORKSHEET_SET_ROW( worksheet, 2, 35.0 )
  /* Заморозим 3-е верхние строки на закладке. */
  WORKSHEET_FREEZE_PANES( worksheet, 3, 0 )

  j := 0
  for i := 1 to len( aCondition )
    if aCondition[ i, 3 ]
      WORKSHEET_SET_COLUMN( worksheet, j, j, aCondition[ i, 5 ] )
      WORKSHEET_WRITE_STRING( worksheet, 2, j, hb_StrToUtf8( aCondition[ i, 1 ] ), header_wrap )
      j++
    endif
  next
  
  // устоновим автофильтр
  WORKSHEET_AUTOFILTER( worksheet, 2, 1, 2, j - 1 )

  R_Use(dir_server + 'kartote2', , 'KART2')
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_, to recno() into KART2

  hGauge := GaugeNew( , , , hb_Utf8ToStr( 'Экспорт картотеки в Excel', 'RU866' ), .t. )
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
      for i := 1 to len( aCondition )
        if i == 1
          WORKSHEET_WRITE_NUMBER( worksheet, row, j, row - 2, fmtCellNumber )
          j++
        endif
        if i == 2 .and. aCondition[ i, 3 ]
          WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( iif( ! empty( kart->uchast ), lstr( kart->uchast ), '' ) ), fmtCellStringCenter )
          j++
        endif
        if i == 3
          arr_fio := retFamImOt( 1, .f., .f. )
          WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( arr_fio[ 1 ] + ' ' + arr_fio[ 2 ] + ' ' + arr_fio[ 3 ] ), fmtCellString )
          j++
        endif
        if i == 4
          WORKSHEET_WRITE_DATETIME( worksheet, row, j, HB_STOT( DToS( KART->DATE_R ) ), formatDate )
          j++
        endif
        if i == 5
          WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( KART->POL ), fmtCellStringCenter )
          j++
        endif
        if i == 6 .and. aCondition[ i, 3 ]
          WORKSHEET_WRITE_NUMBER( worksheet, row, j, count_years( KART->DATE_R, date() ), fmtCellNumber )
          j++
        endif
        if i == 7 .and. aCondition[ i, 3 ]
          WORKSHEET_WRITE_STRING( worksheet, row, j, iif( empty( KART->SNILS ), '', transform( KART->SNILS, picture_pf ) ), fmtCellStringCenter )
          j++
        endif
        if i == 8 .and. aCondition[ i, 3 ]
          WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( smo_to_screen( 1 ) ), fmtCellString )
          j++
        endif
        if i == 9 .and. aCondition[ i, 3 ]
          WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( ltrim( KART_->NPOLIS ) ), fmtCellString )
          j++
        endif
        if i == 10 .and. aCondition[ i, 3 ]
          if empty( KART2->MO_PR )
            s := '?'
          elseif kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
            s := 'X'
          else
            s := '-'
          endif
          WORKSHEET_WRITE_STRING( worksheet, row, j, s, fmtCellStringCenter )
          j++
        endif
        if i == 11 .and. aCondition[ i, 3 ]  // адрес регистрации
          WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( ret_okato_ulica( KART->adres, KART_->okatog ) ), fmtCellString )
          j++
        endif
        if i == 12 .and. aCondition[ i, 3]  // адрес пребывания
          if empty( KART_->adresp ) .and. aCondition[ 11, 3 ]
            WORKSHEET_WRITE_STRING( worksheet, row, j, 'тот же', fmtCellString )
          elseif empty( KART_->adresp ) .and. ! aCondition[ 11, 3 ]
            WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( ret_okato_ulica( KART->adres, KART_->okatog ) ), fmtCellString )
          elseif ! empty( KART_->adresp )
            WORKSHEET_WRITE_STRING( worksheet, row, j, hb_StrToUtf8( ret_okato_ulica( KART_->adresp, KART_->okatop ) ), fmtCellString )
          endif
          j++
        endif
        if i == 13 .and. aCondition[ i, 3 ]
          s := ''
          if ! empty( kart_->PHONE_H )
            s += 'д.' + alltrim( kart_->PHONE_H ) + ' '
          endif
          if ! empty( kart_->PHONE_M )
            s += 'м.' + alltrim( kart_->PHONE_M ) + ' '
          endif
          if ! empty( kart_->PHONE_W )
            s += 'р.' + alltrim( kart_->PHONE_W )
          endif
          WORKSHEET_WRITE_STRING( worksheet, row, j, s, fmtCellString )
          j++
        endif
        if i == 14 .and. aCondition[ i, 3 ]
          WORKSHEET_WRITE_STRING( worksheet, row, j, KART->PC3, fmtCellStringCenter )
          j++
        endif
        if i == 15 .and. aCondition[ i, 3 ]
          s := ''
          if kart_->INVALID == 4
            s := 'дет'
          elseif kart_->INVALID >= 1 .and. kart_->INVALID <= 4
            s := str( kart_->INVALID, 1 )
          endif
          WORKSHEET_WRITE_STRING( worksheet, row, j, s, fmtCellStringCenter )
          j++
        endif
      next
      ++row
    endif
    KART->( dbSkip() )
  enddo
  KART->( dbCloseAll() )
  if fl_exit
    func_error( 4, hb_Utf8ToStr( 'Операция прервана!', 'RU866' ) )
  endif
  WORKBOOK_CLOSE( workbook )
  CloseGauge( hGauge )
  return fl_exit
