// mo_pp_setup.prg - режимы настройки работы для задачи 'Приёмный покой'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function pp_nastr( k )

  Static sk := 1, mas_pmt
  Local mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { ;
      'Экран ввода карточки пациента', ;
      'Экран ввода истории болезни', ;
      'Общие настройки', ;
      'Рабочее место' }
    mas_msg := { ;
      'Настройка экрана ввода карточки пациента в картотеке (в задаче "Приёмный покой")', ;
      'Настройка экрана ввода истории болезни', ;
      'Общие настройки работы с задачей "Приёмный покой"', ;
      'Настройка рабочего места оператора в задаче "Приёмный покой"' }
    mas_fun := { ;
      'pp_nastr(1)', ;
      'pp_nastr(2)', ;
      'pp_nastr(3)', ;
      'pp_nastr(4)' }
    popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    If currentuser():isadmin()
      ne_real()
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 2
    If currentuser():isadmin()
      pp_nastr_ist_bol()
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 3
    If currentuser():isadmin()
      f1nastr_all( mas_pmt[ k ], X_PPOKOJ )
    Else
      func_error( 4, err_admin() )
    Endif
  Case k == 4
    pp_nastr_rab_mesto()
  Endcase
  If k > 0
    sk := k
  Endif
  Return Nil

// 25.03.18
Function _pp_nastr( k )

  Static file_mem := 'pp_nastr'
  Local mm_tmp

  If k == 0 // инициализация файла и переменных
    mm_tmp := { ;  // справочник настроек приемного покоя
      { 'IST_BOL',  'N',  1, 0 }, ; // нумерация истории болезни
      { 'N_IST_BOL','N',  6, 0 }, ; // последний номер истории болезни
      { 'FILE_6',   'C', 12, 0 }, ; // шаблон согласия на обработку перс.данных
      { 'FILE_7',   'C', 12, 0 }, ; // шаблон листа учета
      { 'FILE_8',   'C', 12, 0 }, ; // шаблон истории болезни
      { 'FILE_9',   'C', 12, 0 }, ; // шаблон стат.карты
      { 'FILE_12',  'C', 12, 0 }, ; // шаблон титул истоии болезни
      { 'FILE_XX',  'C',  3, 0 };  // маска личных шаблонов приёмного покоя
    }
    reconstruct( dir_server() + file_mem, mm_tmp,,, .t. )
    If Type( 'pp_IST_BOL' ) == 'N'
      // второй раз зашли
    Else
      Public pp_IST_BOL    := 1, ;
        pp_N_IST_BOL  := 0, ;
        pp_FILE_6     := '', ;
        pp_FILE_7     := 'LU_STAC', ;
        pp_FILE_8     := 'IST_BOL', ;
        pp_FILE_9     := 'F066', ;
        pp_FILE_12    := 'MO_025uA5_2', ;
        pp_FILE_XX    := 'SMO'
    Endif
    g_use( dir_server() + file_mem,, 'MV' )
    If LastRec() == 0
      addrecn()
      mv->IST_BOL := pp_IST_BOL // да
    Else
      g_rlock( 'forever' )
    Endif
    If Empty( mv->file_7 )
      mv->file_7 := pp_FILE_7
    Endif
    If Empty( mv->file_8 )
      mv->file_8 := pp_FILE_8
    Endif
    If Empty( mv->file_9 )
      mv->file_9 := pp_FILE_9
    Endif
    If Empty( mv->file_XX )
      mv->file_XX := pp_FILE_XX
    Endif
    If Empty( mv->file_12 )
      mv->file_12 := pp_FILE_12
    Endif
    Use
  Elseif k == 1
    r_use( dir_server() + file_mem,, 'MV' )
    pp_IST_BOL    := mv->IST_BOL
    pp_N_IST_BOL  := mv->N_IST_BOL
    pp_FILE_6     := AllTrim( mv->FILE_6 )
    pp_FILE_7     := AllTrim( mv->FILE_7 )
    pp_FILE_8     := AllTrim( mv->FILE_8 )
    pp_FILE_9     := AllTrim( mv->FILE_9 )
    pp_FILE_12    := AllTrim( mv->FILE_12 )
    pp_FILE_XX    := AllTrim( mv->FILE_XX )
    Use
  Endif
  Return Nil

// настройка экрана ввода истории болезни
Function pp_nastr_ist_bol()

  Local mm_tmp := {}, smsg, buf

  If tools_ini_pp( 1, 0, 0, .t. )
    smsg := 'настройкам экрана ввода истории болезни'
    buf := save_maxrow()
    mywait()
    Close databases
    Delete file tmp.dbf
    AAdd( mm_tmp, { 'NOVOR', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet(), A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet(), x ) }, ;
      'Вводить новорожденного' } )
    AAdd( mm_tmp, { 'e_01', 'C', 1, 0, NIL, ;
      NIL, ;
      '', NIL, ;
      'Список наиболее часто встречающихся направляющих МО',, ;
      {|| .f. } } )
    AAdd( mm_tmp, { 'KEM_NAPR', 'C', 1500, 0, NIL, ;
      {| x| menu_reader( x, { {| k, r, c| inp_bit_mo( k, r, c ) } }, A__FUNCTION ) }, ;
      '', {| x| ini_ed_mo( x ) }, ;
      '==>' } )
    AAdd( mm_tmp, { 'POB_D_LEK', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet(), A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet(), x ) }, ;
      'Вводить побочное действие лекарств' } )
    AAdd( mm_tmp, { 'KOD_VR', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet(), A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet(), x ) }, ;
      'Вводить табельный номер врача приёмного отделения' } )
    AAdd( mm_tmp, { 'TRAVMA', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet(), A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet(), x ) }, ;
      'Вводить вид травмы' } )
    AAdd( mm_tmp, { 'NE_ZAK', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet(), A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet(), x ) }, ;
      'Запрещать ввод, если не закончено лечение по предыдущему случаю' } )
    init_base( cur_dir() + 'tmp',, mm_tmp, 0 )
    Use ( cur_dir() + 'tmp' ) new
    Append Blank
    tmp->NOVOR     := pp_NOVOR
    tmp->KEM_NAPR  := pp_KEM_NAPR
    tmp->POB_D_LEK := pp_POB_D_LEK
    tmp->KOD_VR    := pp_KOD_VR
    tmp->TRAVMA    := pp_TRAVMA
    tmp->NE_ZAK    := pp_NE_ZAK
    Close databases
    If f_edit_spr( A__EDIT, mm_tmp, smsg, 'g_use(cur_dir()+"tmp",,,.t.,.t.)', 0, 1 ) > 0
      Use ( cur_dir() + 'tmp' ) new
      pp_NOVOR     := tmp->NOVOR
      pp_KEM_NAPR  := RTrim( tmp->KEM_NAPR )
      pp_POB_D_LEK := tmp->POB_D_LEK
      pp_KOD_VR    := tmp->KOD_VR
      pp_TRAVMA    := tmp->TRAVMA
      pp_NE_ZAK    := tmp->NE_ZAK
      tools_ini_pp( 2, 0, 0 )
    Endif
    Close databases
    rest_box( buf )
  Endif
  Return Nil

//
Function pp_nastr_rab_mesto()

  Static group_ini := 'PP_RAB_MESTO'
  Static mm_prn_svod := { ;
      { 'Elita 12cpi', 2 }, ;
      { 'Condensed 17cpi', 3 } }, ;
    mm_list_066 := { ;
      { 'на обеих сторонах листа', 0 }, ;
      { 'на одной стороне листа ', 1 } }, ;
    mm_dos_fast := { ;
      { 'через шаблоны DOS      ', 0 }, ;
      { 'через отчёты FastReport', 1 } }
  Local ar, mm_tmp := {}, smsg, buf, old_ib

  smsg := 'настройкам рабочего места приёмного покоя'
  buf := save_maxrow()
  mywait()
  Close databases
  Delete file tmp.dbf
  ar := getinisect( tmp_ini(), group_ini )
  If pp_IST_BOL == 1 // да
    AAdd( mm_tmp, { 'n_ist_bol', 'N', 6, 0, NIL, ;
      NIL, ;
      0, NIL, ;
      'Номер последней введенной истории болезни (мед.карты)' } )
    AAdd( mm_tmp, { 'e_date_01', 'C', 1, 0, NIL, ;
      NIL, ;
      ' ', NIL, ;
      Replicate( '-', 78 ),, ;
      {|| .f. } } )
  Endif
  AAdd( mm_tmp, { 'prn_svod', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_prn_svod, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_prn_svod, x ) }, ;
    'Режим печати сводов по направившим ЛПУ и по столам' } )
  AAdd( mm_tmp, { 'dos_fast', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_dos_fast, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_dos_fast, x ) }, ;
    'Каким образом печатать документы' } )
  init_base( cur_dir() + 'tmp',, mm_tmp, 0 )
  Use ( cur_dir() + 'tmp' ) new
  Append Blank
  If pp_IST_BOL == 1 // да
    r_use( dir_server() + 'pp_nastr',, 'MV' )
    old_ib := tmp->N_IST_BOL := mv->N_IST_BOL
  Endif
  tmp->PRN_SVOD   := Int( Val( a2default( ar, 'PRN_SVOD',  '3' ) ) )
  tmp->dos_fast   := Int( Val( a2default( ar, 'dos_fast',  '0' ) ) )
  Close databases
  If f_edit_spr( A__EDIT, mm_tmp, smsg, 'g_use(cur_dir()+"tmp",,,.t.,.t.)', 0, 1 ) > 0
    Use ( cur_dir() + 'tmp' ) new
    If pp_IST_BOL == 1 .and. old_ib != tmp->N_IST_BOL
      g_use( dir_server() + 'pp_nastr',, 'MV' )
      g_rlock( 'forever' )
      pp_N_IST_BOL := mv->N_IST_BOL := tmp->N_IST_BOL
    Endif
    memPPsvod     := tmp->PRN_SVOD
    memPPdos_fast := tmp->dos_fast
    setinivar( tmp_ini(), { ;
      { group_ini, 'PRN_SVOD',  tmp->PRN_SVOD  }, ;
      { group_ini, 'dos_fast',  tmp->dos_fast  };
      } )
  Endif
  Close databases
  rest_box( buf )
  Return Nil
