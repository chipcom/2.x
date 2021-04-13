#include 'hblibxlsxwriter.ch'

procedure main()
  local workbook
  local shTitul, sh1000, sh2000, sh3000, sh3001, sh4000, sh5000DVN, sh5000PO
  local sh6000, sh5000
  local fName := 'f131.xlsx'
  local error

  lxw_init() 

  // if hb_FileExists(fName)  
  //   filedelete(fName)
  // endif

  workbook  := lxw_workbook_new( 'f131.xlsx' )
  shTitul := lxw_workbook_add_worksheet(workbook, 'Титульный лист' )
  sh1000 := lxw_workbook_add_worksheet(workbook, '1000, 1001' )
  sh2000 := lxw_workbook_add_worksheet(workbook, '2000' )
  sh3000 := lxw_workbook_add_worksheet(workbook, '2001, 3000' )
  sh3001 := lxw_workbook_add_worksheet(workbook, '3001, 3002, 3003' )
  sh4000 := lxw_workbook_add_worksheet(workbook, '4000, 4001' )
  sh5000DVN := lxw_workbook_add_worksheet(workbook, '5000 и 5001 ДВН' )
  sh5000PO := lxw_workbook_add_worksheet(workbook, '5000 и 5001 ПО' )
  sh6000 := lxw_workbook_add_worksheet(workbook, '6000-6010' )
  sh5000 := lxw_workbook_add_worksheet(workbook, '5000, 5001' )

  /* Закрыть книгу, записать файл и освободить память. */
  error = lxw_workbook_close(workbook)

  /* Проверить наличие ошибки при создании xlsx файла. */
  if !EMPTY(error)
    sprintf("Error in workbook_close().\n"+;
           "Error %d = %s\n", error, HB_NTOS(error))
  endif

  return