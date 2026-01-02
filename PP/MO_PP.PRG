// mo_pp.prg - режимы ввода данных для задачи 'Приёмный покой'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function begin_task_ppokoj()

  Static n_zapusk := 0
  Local i, ar, fl := .t.

  If n_zapusk == 0
    ++n_zapusk
    _pp_nastr( 0 )
    ar := getinisect( tmp_ini(), 'PP_RAB_MESTO' )
    Public memPPsvod     := Int( Val( a2default( ar, 'PRN_SVOD',  '3' ) ) )
    Public memPPdos_fast := Int( Val( a2default( ar, 'dos_fast',  '0' ) ) )
  Endif
  If g_sislock( sem_vagno_task()[ X_PPOKOJ ] )
    fl := f_err_sem_vagno_task( X_PPOKOJ )
  Elseif copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
    tools_ini_pp( 1, 0, 0 )
    _pp_nastr( 1 )
    If n_zapusk == 1 // только для первого запуска
      f_find_pp_oms() // поиск историй болезни, по которым не создан л/учёта (по каким-либо причинам)
    Endif
  Else
    fl := .f.
  Endif
  Return fl

//
Function pp_nastr( k )

  Static sk := 1, mas_pmt
  Local str_sem, mas_msg, mas_fun, j, n

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { 'Экран ввода карточки пациента', ;
      'Экран ввода истории болезни', ;
      'Общие настройки', ;
      'Рабочее место' }
    mas_msg := { 'Настройка экрана ввода карточки пациента в картотеке (в задаче "Приёмный покой")', ;
      'Настройка экрана ввода истории болезни', ;
      'Общие настройки работы с задачей "Приёмный покой"', ;
      'Настройка рабочего места оператора в задаче "Приёмный покой"' }
    mas_fun := { 'pp_nastr(1)', ;
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
  Local mm_tmp, smsg

  If k == 0 // инициализация файла и переменных
    mm_tmp := { ;  // справочник настроек приемного покоя
    { 'IST_BOL',     'N',     1,     0 }, ; // нумерация истории болезни
    { 'N_IST_BOL',   'N',     6,     0 }, ; // последний номер истории болезни
    { 'FILE_6',   'C',    12,     0 }, ; // шаблон согласия на обработку перс.данных
    { 'FILE_7',   'C',    12,     0 }, ; // шаблон листа учета
    { 'FILE_8',   'C',    12,     0 }, ; // шаблон истории болезни
    { 'FILE_9',   'C',    12,     0 }, ; // шаблон стат.карты
    { 'FILE_12',   'C',    12,     0 }, ; // шаблон титул истоии болезни
    { 'FILE_XX',   'C',     3,     0 };  // маска личных шаблонов приёмного покоя
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
      g_rlock( forever )
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

  Local ar, mm_tmp := {}, smsg, buf

  If tools_ini_pp( 1, 0, 0, .t. )
    smsg := 'настройкам экрана ввода истории болезни'
    buf := save_maxrow()
    mywait()
    Close databases
    Delete file tmp.dbf
    AAdd( mm_tmp, { 'NOVOR', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
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
      {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
      'Вводить побочное действие лекарств' } )
    AAdd( mm_tmp, { 'KOD_VR', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
      'Вводить табельный номер врача приёмного отделения' } )
    AAdd( mm_tmp, { 'TRAVMA', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
      'Вводить вид травмы' } )
    AAdd( mm_tmp, { 'NE_ZAK', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
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
  Static mm_prn_svod := { { 'Elita 12cpi', 2 }, ;
    { 'Condensed 17cpi', 3 } }, ;
    mm_list_066 := { { 'на обеих сторонах листа', 0 }, ;
    { 'на одной стороне листа ', 1 } }, ;
    mm_dos_fast := { { 'через шаблоны DOS      ', 0 }, ;
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
      g_rlock( forever )
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

//
Function f_pp_stol()

  Local blk, arr[ US_LEN ]

  blk := {|| iif( tip == 0, { 1, 2 }, { 3, 4 } ) }
  arr[ US_TOP      ] := T_ROW
  arr[ US_BOTTOM   ] := 22
  arr[ US_LEFT     ] := T_COL - 5
  arr[ US_RIGHT    ] := T_COL - 5 + 23
  arr[ US_BASE     ] := dir_server() + 'mo_ppst'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
  arr[ US_COLUMN   ] := { { ' Стол', {|| name }, blk }, ;
    { ' Тип', {|| inieditspr( A__MENUVERT, menu_stdnst, tip ) }, blk } }
  arr[ US_BLK_DEL  ] := {| _k| fdel_pp_stol( _k ) }
  arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'столы'
  arr[ US_ROD_PADEG ] := 'столов'
  arr[ US_EDIT_SPR ] := { { 'name', 'C', 10, 0,,, Space( 10 ),, 'Стол' }, ;
    { 'tip', 'N', 1, 0,, ;
    {| x| menu_reader( x, menu_stdnst, A__MENUVERT,,, .f. ) }, ;
    1, {| x| inieditspr( A__MENUVERT, menu_stdnst, x ) }, ;
    'Тип' };
    }
  edit_u_spr( 1, arr )
  Return Nil

//
Function fdel_pp_stol( mkod )

  Local fl := .t., buf := save_maxrow()

  stat_msg( 'Ждите! Производится проверка на допустимость удаления данного стола' )
  r_use( dir_server() + 'mo_pp',, 'HU' )
  Locate For hu->stol == mkod progress
  fl := !Found()
  Use
  If !fl
    func_error( 4, 'Данный стол встречается в других базах данных. Удаление запрещено!' )
  Endif
  rest_box( buf )
  Return fl

// Добавление истории болезни
Function add_ppokoj()

  Private pr_kod_pp

  ppokoj_kart( 1 )
  If pr_kod_pp != NIL
    view_human_pp( 1, pr_kod_pp )
  Endif
  Return Nil

// Редактирование истории болезни и печать медицинской и стат.карты
Function edit_ppokoj()

  Private pr_kod_pp

  Do While .t.
    view_human_pp( 1, pr_kod_pp )
    If pr_kod_pp == NIL
      Exit
    Endif
  Enddo
  Return Nil

// Перевод больного из одного отделения в другое
Function ppokoj_perevod()

  If view_human_pp( 3 )
    f1pp_perevod()
  Endif
  Return Nil

//
Function f1pp_perevod()

  Local buf := SaveScreen(), blk, t_arr[ BR_LEN ]
  Private last_rec, last_lpu, last_n_data, last_n_time, last_otd, last_stol

  r_use( dir_server() + 'mo_pp',, 'HU' )
  Goto ( glob_perso_pp )
  box_shadow( 1, 10, 4, 69, color1, glob_k_fio )
  @ 2, 11 Say PadC( 'поступил ' + full_date( hu->n_data ) + ' в ' + hu->n_time, 58 ) Color 'G+/B'
  @ 3, 11 Say PadC( 'в "' + ;
    AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', hu->otd ) ) + '" (' + ;
    AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', hu->lpu ) ) + ')', 58 ) Color color8
  //
  dbCreate( cur_dir() + 'tmp', { ;
    { 'rec_per',   'N',     7,     0 }, ;
    { 'N_DATA',   'D',     8,     0 }, ; // дата перевода
  { 'N_TIME',   'C',     5,     0 }, ; // время перевода
  { 'LPU',   'N',     3,     0 }, ; // код учреждения
  { 'OTD',   'N',     3,     0 }, ; // код отделения
  { 'STOL',   'N',     3,     0 }, ; // стол
    { 'DATE_VVOD',   'D',     8,     0 }, ; // дата ввода данных
  { 'KOD_P',   'C',     1,     0 };  // код пользователя
    } )
  Use ( cur_dir() + 'tmp' ) new
  Index On DToS( n_data ) + n_time to ( cur_dir() + 'tmp' ) descending
  Append Blank
  tmp->rec_per   := 0
  tmp->N_DATA    := hu->N_DATA
  tmp->N_TIME    := hu->N_TIME
  tmp->LPU       := hu->LPU
  tmp->OTD       := hu->OTD
  tmp->STOL      := hu->STOL
  tmp->DATE_VVOD := hu->DATE_VVOD
  tmp->KOD_P     := hu->KOD_P
  hu->( dbCloseArea() )
  //
  If yes_parol
    r_use( dir_server() + 'base1',, 'BASE1' )
  Endif
  g_use( dir_server() + 'mo_ppper', dir_server() + 'mo_ppper', 'PER' )
  find ( Str( glob_perso_pp, 7 ) )
  Do While per->kod == glob_perso_pp .and. !Eof()
    Select TMP
    Append Blank
    tmp->rec_per   := per->( RecNo() )
    tmp->N_DATA    := per->N_DATA
    tmp->N_TIME    := per->N_TIME
    tmp->LPU       := per->LPU
    tmp->OTD       := per->OTD
    tmp->STOL      := per->STOL
    tmp->DATE_VVOD := per->DATE_VVOD
    tmp->KOD_P     := per->KOD_P
    Select PER
    Skip
  Enddo
  Select TMP
  Go Top
  f4pp_perevod()
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -5
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Перевод из отделения в отделение'
  t_arr[ BR_TITUL_COLOR ] := 'W+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t., 300 }
  t_arr[ BR_STEP_FUNC ] := {|| f3pp_perevod() }
  blk := {|| if( Empty( tmp->rec_per ), { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := {}
  AAdd( t_arr[ BR_COLUMN ], { '  Дата и время', {|| full_date( tmp->n_data ) + ' ' + tmp->n_time }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { ' ', {|| iif( tmp->rec_per == 0, 'поступление', PadC( 'перевод', 11 ) ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { Center( 'в отделение', 30 ), {|| PadR( inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', tmp->otd ), 30 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { Center( 'Стол', 10 ), {|| PadR( inieditspr( A__POPUPMENU, dir_server() + 'mo_ppst', tmp->stol ), 10 ) }, blk } )
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( '^<Esc>^ выход; ^<Enter>^ редактирование; ^<Ins>^ добавление; ^<Del>^ удаление' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2pp_perevod( nk, ob, 'edit' ) }
  box_shadow( MaxRow() -4, 2, MaxRow() -2, 77, 'W/B' )
  edit_browse( t_arr )
  Close databases
  RestScreen( buf )
  Return Nil

// 14.03.18
Function f2pp_perevod( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, rec1, k := MaxRow() -10, tmp_color, ;
    old_n_data, old_n_time, old_otd

  Do Case
  Case regim == 'edit'
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->rec_per > 0 .and. ;
        tmp->( RecNo() ) == last_rec )
      Save Screen To buf
      rec := tmp->( RecNo() )
      If nKey == K_ENTER
        old_n_data := tmp->N_DATA
        old_n_time := tmp->N_TIME
        old_otd    := tmp->otd
        Skip  // встать на предпоследнюю запись
        If !Eof()
          old_n_data := tmp->N_DATA
          old_n_time := tmp->N_TIME
          old_otd    := tmp->otd
        Endif
        Goto ( rec )
      Endif
      Private much, m1uch := if( nkey == K_INS, last_lpu, tmp->lpu ), ;
        motd, m1otd := if( nkey == K_INS, 0, tmp->otd ), ;
        mn_data := if( nkey == K_INS, sys_date, tmp->n_data ), ;
        mn_time := if( nkey == K_INS, hour_min( Seconds() ), tmp->n_time ), ;
        mstol, m1stol := if( nkey == K_INS, last_stol, tmp->stol ), ;
        gl_area := { 1, 0, 23, 79, 0 }
      much := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1uch )
      motd := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
      mstol := inieditspr( A__POPUPMENU, dir_server() + 'mo_ppst', m1stol )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, MaxRow() -3, pc2 - 1,, ;
        iif( nKey == K_INS, 'Добавление', 'Редактирование' ), ;
        cDataPgDn )
      Do While .t.
        SetColor( cDataCGet )
        @ k + 1, pc1 + 4 Say 'Дата перевода' Get mn_data
        @ Row(), Col() Say ', время' Get mn_time Pict pict_time
        @ k + 2, pc1 + 4 Say 'в ЛПУ' Get much ;
          reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c ) } }, A__FUNCTION,,, .f. ) }
        @ k + 3, pc1 + 4 Say ' в отделение' Get motd When .f.
        @ k + 4, pc1 + 4 Say 'Стол' Get mstol ;
          reader {| x| menu_reader( x, { dir_server() + 'mo_ppst' }, A__POPUPEDIT,,, .f. ) }
        status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
        myread()
        If LastKey() != K_ESC
          If nKey == K_ENTER
            If !v_date_time( old_n_data, old_n_time, mn_data, mn_time )
              Loop
            Endif
            If old_n_data == mn_data .and. old_n_time == mn_time
              func_error( 4, 'Вы не сменили дату и время!' )
              Loop
            Endif
            If old_otd == m1otd
              func_error( 4, 'Вы повторно выбрали то же самое отделение. Это недопустимо!' )
              Loop
            Endif
          Else
            If !v_date_time( last_n_data, last_n_time, mn_data, mn_time )
              Loop
            Endif
            If last_n_data == mn_data .and. last_n_time == mn_time
              func_error( 4, 'Вы не сменили дату и время!' )
              Loop
            Endif
            If last_otd == m1otd
              func_error( 4, 'Вы повторно выбрали то же самое отделение. Это недопустимо!' )
              Loop
            Endif
          Endif
          If f_esc_enter( 1 )
            Select PER
            If nKey == K_INS
              addrec( 7 )
              per->kod := glob_perso_pp
            Else
              Goto ( rec )
              g_rlock( forever )
            Endif
            per->N_DATA    := mn_data
            per->N_TIME    := mn_time
            per->LPU       := m1uch
            per->OTD       := m1otd
            per->STOL      := m1stol
            per->DATE_VVOD := sys_date
            per->KOD_P     := kod_polzovat
            Select TMP
            If nKey == K_INS
              Append Blank
              tmp->rec_per := per->( RecNo() )
            Endif
            tmp->N_DATA    := per->N_DATA
            tmp->N_TIME    := per->N_TIME
            tmp->LPU       := per->LPU
            tmp->OTD       := per->OTD
            tmp->STOL      := per->STOL
            tmp->DATE_VVOD := per->DATE_VVOD
            tmp->KOD_P     := per->KOD_P
            Unlock
            Commit
            oBrow:gotop()
            f4pp_perevod()
            ret := 0
          Endif
        Endif
        Exit
      Enddo
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. tmp->rec_per > 0 .and. ;
        tmp->( RecNo() ) == last_rec .and. f_esc_enter( 2 )
      Select PER
      Goto ( tmp->rec_per )
      deleterec()
      Select TMP
      deleterec()
      oBrow:gotop()
      f4pp_perevod()
      ret := 0
    Endcase
  Endcase
  Return ret

//
Function f3pp_perevod()

  Local s1 := '', s2 := '', k, tmp_select := Select()

  If yes_parol .and. ( k := Asc( tmp->kod_p ) ) > 0
    Select BASE1
    Goto ( k )
    s1 := 'Оператор: ' + Crypt( base1->p1, gpasskod )
  Endif
  If !Empty( tmp->DATE_VVOD )
    s2 := 'Дата ввода: ' + full_date( tmp->DATE_VVOD )
  Endif
  @ MaxRow() -3, 4 Say PadR( s1, 30 ) Color color1
  @ MaxRow() -3, 41 Say PadL( s2, 35 ) Color color8
  Select ( tmp_select )
  Return Nil

//
Function f4pp_perevod()

  last_rec    := tmp->( RecNo() )
  last_lpu    := tmp->LPU
  last_n_data := tmp->N_DATA
  last_n_time := tmp->N_TIME
  last_otd    := tmp->OTD
  last_stol   := tmp->STOL
  Return Nil

// Удаление истории болезни
Function del_ppokoj()

  view_human_pp( 2 )
  Return Nil

// 17.11.25
Function f_kart_pp( Loc_kod, kod_kartotek )

  Static mm_gospit := { { 'да ', 0 }, { 'нет', 1 } }
  Static menu_bolnich := { { 'нет', 0 }, { 'да ', 1 }, { 'РОД', 2 } }
  Static st_rab_nerab := 0, st_reg_lech := 1, st_vrach := 0
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, is_mkb10 := .f., str_sem
  Local buf := SaveScreen(), tmp_color := SetColor(), str_1, fl, i, j, k, arr_rec := {}, ;
    tmp_help := chm_help_code, s_msg, arr, c, pict_vr := '99999', pos_read := 0, ;
    k_read := 0, count_edit := 0, lapp_edit, llen, ldec, fl_ppdia := .f.

  Default Loc_kod To 0, kod_kartotek To 0
  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0,,, .t. ) ) == 0
      Return Nil
    Endif
  Endif
  mywait()
  change_sys_date() // перечитать системную дату (для ПП, работающих ночами)
  If pp_ne_zak == 1 .and. Loc_kod == 0 .and. kod_kartotek > 0
    fl := 0
    r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_r', 'HU' )
    find ( Str( kod_kartotek, 7 ) )
    Do While hu->kod_k == kod_kartotek .and. !Eof()
      If Empty( hu->k_data ) .and. hu->is_gospit == 0
        fl := 1 ; Exit
      Endif
      If hu->ishod2 == 6
        fl := 2 ; Exit
      Endif
      Skip
    Enddo
    hu->( dbCloseArea() )
    If fl == 1
      Return func_error( 4, 'Данный больной еще не закончил лечение по предыдущему случаю!' )
    Elseif fl == 2
      Return func_error( 4, 'Данный больной умер!' )
    Endif
  Endif
  Private mdate_r, m1vzros_reb
  Private ;
    MKOD := Loc_kod,; // код (номер записи)
  MKOD_K := kod_kartotek,; // код по картотеке
  MKOD_H := 0,; // код по БД human
  MREG_LECH,; // 1-стационарно, 2,3,4-дневной стационар
  M1REG_LECH := st_reg_lech,; // 1-стационарно, 2,3,4-дневной стационар
  MUCH_DOC := Space( 10 ),; // номер медицинской карты
  M1FIO_KART := 1, MFIO_KART := Space( 50 ), ;
    mfio, mpol, ;
    m1novor := 0, mnovor, mcount_reb := 0, ;
    mDATE_R2 := CToD( '' ), mpol2 := ' ', ;
    MPPRAB_NERAB, M1PPRAB_NERAB := 0,; // социальный статус 5-работающий, 6-неработающий
  MKATEGOR, M1KATEGOR := 11,; // от 1 до ...
  m1company := 0, mcompany, mm_company, ;
    msmo := '', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС,1-компании,3-комитеты/МО,5-личный счет
  MVID_OPL, M1VID_OPL := 1,; // вид оплаты (1-ОМС,2-бюджет,3-платные,4-ДМС,5-другое)
  MKEM_NAPR := Space( 10 ),; // кем направлен (справочник ЛПУ)
  M1KEM_NAPR := '',; // кем направлен (справочник ЛПУ)
  MKEM_DOST, M1KEM_DOST := 0,; // кем доставлен
  MPOB_D_LEK := Space( 100 ),; // побочное действие лекарств
  MDIAG_NAPR := Space( 100 ),; // диагноз направившего учреждения
  MDIAG_PR_P := Space( 100 ),; // диагноз приемного отделения
  MVRACH := Space( 30 ),; // фамилия и инициалы врача приёмного покоя
  M1VRACH := st_vrach, MTAB_NOM := 0, ; // код, таб.№ врача приёмного покоя
  MSOST_OP, M1SOST_OP := 0,; // 0-нет,1-алкогольное,2-наркотическое
  MGOSPIT0, M1GOSPIT0 := 0,; // 0-первичн.,1-повторн.
  MGOSPIT1, M1GOSPIT1 := 0,; // 0-плановое,1-экстренное
  MGOSPIT2, M1GOSPIT2 := 0,; // 1-6часов,2-7\24часа,0-24часа\и\более
  MTRAVMA, M1TRAVMA := 0,; // тип травмы
  Much, M1uch := glob_uch[ 1 ],; // код учреждения
  MOTD, M1OTD := glob_otd[ 1 ],; // код отделения
  MN_DATA := sys_date,; // дата поступления
  MN_TIME := hour_min( Seconds() ),; // время поступления
    MIS_GOSPIT, M1IS_GOSPIT := 0,; // госпитализирован?
  MPR_GOSPIT, M1PR_GOSPIT := 0,; // почему не госпитализирован?
  MSTOL, M1STOL := 0,; // стол
  MG_DATA := sys_date,; // дата госпитализации
  MG_TIME := hour_min( Seconds() ),; // время госпитализации
    MK_DATA := CToD( '' ),; // дата окончания лечения
  MK_TIME := Space( 5 ),; // время выписки
  MKOJKO_DNI := 0,; // продолжительность госпитализации
  MISHOD1, M1ISHOD1 := 0,;
    MISHOD2, M1ISHOD2 := 0,;
    MBOLNICH, M1BOLNICH := 0,; // больничный (0-нет,1-да,2-по уходу)
  MDATE_B_1   := CToD( '' ),; // дата начала больничного
  MDATE_B_2   := CToD( '' ),; // дата окончания больничного
  mrodit_dr   := CToD( '' ),; // дата рождения родителя
  mrodit_pol  := ' ',; // пол родителя
  arr_perevod := {}
  _pp_nastr( 1 ) // перечитать номер последней истории болезни
  If pp_ist_bol == 1
    MUCH_DOC := PadR( lstr( pp_n_ist_bol + 1 ), 10 ) // номер медицинской карты
  Endif
  If Loc_kod > 0   // режим редактирования
    r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_k', 'HU' )
    find ( Str( Loc_kod, 7 ) )
    MKOD_K      := hu->KOD_K       // код по картотеке
    MKOD_H      := hu->kod_h       // код по БД human
    M1REG_LECH  := hu->REG_LECH    // 1-стационарно, 2,3,4-дневной стационар
    MUCH_DOC    := hu->UCH_DOC     // номер медицинской карты
    If hu->NOVOR > 0
      m1novor := 1
      mcount_reb := hu->NOVOR
      mDATE_R2 := hu->DATE_R2
      mpol2 := hu->POL2
    Endif
    M1PPRAB_NERAB := hu->RAB_NERAB   // битовое поле
    M1KATEGOR   := hu->KATEGOR     // от 1 до ...
    M1KOMU      := hu->KOMU        // от 0 до 5
    M1STR_CRB   := hu->STR_CRB     // код стр.компании, комитета и т.п.
    M1VID_OPL   := hu->VID_OPL     // вид оплаты (1-ОМС,2-ДМС,3-бюджет,4-платные,5-другое)
    M1KEM_NAPR  := hu->KEM_NAPR    // кем направлен (справочник ЛПУ)
    M1KEM_DOST  := hu->KEM_DOST    // кем доставлен
    M1VRACH     := hu->KOD_VR      // код врача
    M1SOST_OP   := hu->SOST_OP     // 0-нет,1-алкогольное,2-наркотическое
    M1GOSPIT0   := hu->GOSPIT0     //
    M1GOSPIT1   := hu->GOSPIT1     //
    M1GOSPIT2   := hu->GOSPIT2     //
    M1TRAVMA    := hu->TRAVMA      // тип травмы
    M1uch       := hu->LPU         // код учреждения
    M1OTD       := hu->OTD         // код отделения
    MN_DATA     := hu->N_DATA      // дата поступления
    MN_TIME     := hu->N_TIME      // время поступления
    M1IS_GOSPIT := hu->IS_GOSPIT   // госпитализирован?
    M1PR_GOSPIT := hu->PR_GOSPIT   // почему не госпитализирован?
    M1STOL      := hu->STOL        // стол
    MG_DATA     := hu->G_DATA      // дата госпитализации
    MG_TIME     := hu->G_TIME      // время госпитализации
    MK_DATA     := hu->K_DATA      // дата окончания лечения
    MK_TIME     := hu->K_TIME      // время выписки
    MKOJKO_DNI  := hu->KOJKO_DNI   // продолжительность госпитализации
    M1ISHOD1    := hu->ISHOD1      // исход лечения
    M1ISHOD2    := hu->ISHOD2      // исход лечения
    M1BOLNICH   := hu->BOLNICH     // больничный (0-нет,1-да,2-по уходу)
    If m1bolnich > 0
      MDATE_B_1 := hu->DATE_B_1    // дата начала больничного
      MDATE_B_2 := hu->DATE_B_2    // дата окончания больничного
      If m1bolnich == 2
        mrodit_dr  := hu->DATE_RODIT  // дата рождения родителя
        mrodit_pol := hu->POL_RODIT   // пол родителя
      Endif
    Endif
    r_use( dir_server() + 'mo_ppdia', dir_server() + 'mo_ppdia', 'HUS' )
    find ( Str( Loc_kod, 7 ) )
    Do While hus->kod == Loc_kod .and. !Eof()
      fl_ppdia := .t.
      Do Case
      Case hus->tip == 1
        MDIAG_NAPR := hus->name // диагноз направившего учреждения
      Case hus->tip == 2
        MDIAG_PR_P := hus->name // диагноз приемного отделения
      Case hus->tip == 3
        MPOB_D_LEK := hus->name // побочное действие лекарств
      Endcase
      Skip
    Enddo
    r_use( dir_server() + 'mo_ppper', dir_server() + 'mo_ppper', 'HUP' )
    find ( Str( Loc_kod, 7 ) )
    Do While Loc_kod == hup->kod .and. !Eof()
      AAdd( arr_perevod, { '', hup->otd, hup->n_data, n_time, DToS( hup->n_data ) + n_time } )
      Skip
    Enddo
    ASort( arr_perevod,,, {| x, y| x[ 5 ] < y[ 5 ] } )
    For i := 1 To Len( arr_perevod )
      arr_perevod[ i, 1 ] := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', arr_perevod[ i, 2 ] )
    Next
  Endif
  If kod_kartotek > 0   // ФИО из картотеки
    r_use( dir_server() + 'kartotek',, 'KART' )
    Goto ( kod_kartotek )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    Goto ( kod_kartotek )
    mfio := kart->FIO
    mpol := kart->pol
    mdate_r := kart->date_r
    MFIO_KART := _f_fio_kart()
    m1vzros_reb := kart->vzros_reb
    msmo := kart_->SMO
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1,, .t. ) // открыть и закрыть
    Endif
    If Loc_kod == 0
      If kart->MI_GIT == 9
        m1komu    := kart->KOMU
        m1str_crb := kart->STR_CRB
      Endif
      If kart->RAB_NERAB == 0
        m1PPRAB_NERAB := SetBit( m1PPRAB_NERAB, 5 )
      Else
        m1PPRAB_NERAB := SetBit( m1PPRAB_NERAB, 6 )
      Endif
      If kart_->PENSIONER == 1
        m1PPRAB_NERAB := SetBit( m1PPRAB_NERAB, 8 )
      Endif
      M1VID_OPL := 0
      Do Case
      Case m1komu == 0
        M1VID_OPL := SetBit( M1VID_OPL, 1 ) // ОМС
      Case eq_any( m1komu, 1, 3 ) .and. m1str_crb > 0
        r_use( dir_server() + iif( m1komu == 1, 'str_komp', 'komitet' ),, '_SK' )
        Goto ( m1str_crb )
        If eq_any( _sk->ist_fin, I_FIN_LPU, I_FIN_PLAT, I_FIN_DMS )
          M1VID_OPL := SetBit( M1VID_OPL, 3 ) // платные услуги
        Else
          M1VID_OPL := SetBit( M1VID_OPL, 2 ) // бюджет
        Endif
        _sk->( dbCloseArea() )
      Case m1komu == 5
        M1VID_OPL := SetBit( M1VID_OPL, 3 ) // платные услуги
      Endcase
    Endif
  Endif
  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo ; msmo := '34'
  Endif
  If m1vrach > 0
    r_use( dir_server() + 'mo_pers',, 'P2' )
    Goto ( m1vrach )
    mvrach := fam_i_o( p2->fio )
    MTAB_NOM := p2->tab_nom
  Endif
  Close databases
  Private gl_arr := { ;  // для битовых полей
  { 'vid_opl', 'N', 3, 0,,,, {| x| inieditspr( A__MENUBIT, menu_vid_opl, x ) } }, ;
    { 'pprab_nerab', 'N', 10, 0,,,, {| x| inieditspr( A__MENUBIT, mmpp_rab, x ) } };
    }
  much := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1uch )
  motd := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  MNOVOR := inieditspr( A__MENUVERT, mm_danet, M1NOVOR )
  If !Empty( M1KEM_NAPR )
    mKEM_NAPR := ret_mo( M1KEM_NAPR )[ _MO_SHORT_NAME ]
  Endif
  If m1is_gospit == 0
    m1pr_gospit := 0
  Endif
  Private OLD_IS_GOSPIT := M1IS_GOSPIT
  mvid_opl   := inieditspr( A__MENUBIT, menu_vid_opl, m1vid_opl )
  mpprab_nerab := inieditspr( A__MENUBIT, mmpp_rab, m1pprab_nerab )
  mreg_lech  := inieditspr( A__MENUVERT, mmpp_regim, m1reg_lech )
  mkategor   := inieditspr( A__MENUVERT, mmpp_kategor, m1kategor )
  If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
    MKEM_DOST  := inieditspr( A__MENUVERT, mmpp_kem1dost, M1KEM_DOST )
  Else
    MKEM_DOST  := inieditspr( A__MENUVERT, mmpp_kem_dost, M1KEM_DOST )
  Endif
  mis_gospit := inieditspr( A__MENUVERT, mm_gospit, m1is_gospit )
  mpr_gospit := inieditspr( A__MENUVERT, mmpp_pr_gospit, m1pr_gospit )
  msost_op   := inieditspr( A__MENUVERT, menu_sost_op, m1sost_op )
  mgospit0   := inieditspr( A__MENUVERT, menu0gospit, m1gospit0 )
  mgospit1   := inieditspr( A__MENUVERT, mm_ekst, m1gospit1 )
  mgospit2   := inieditspr( A__MENUVERT, menu2gospit, m1gospit2 )
  mishod1    := inieditspr( A__MENUVERT, mmpp1ishod, m1ishod1 )
  mishod2    := inieditspr( A__MENUVERT, mmpp2ishod, m1ishod2 )
  mtravma    := inieditspr( A__MENUVERT, mmpp_travma, m1travma )
  mbolnich   := inieditspr( A__MENUVERT, menu_bolnich, m1bolnich )
  mstol      := inieditspr( A__POPUPMENU, dir_server() + 'mo_ppst', m1stol )
  If !eq_any( m1komu, 0, 1, 3, 5 ) ; m1komu := 0 ; Endif
  mkomu      := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo      := init_ismo( m1ismo )
//  Private old_name_smo := PadR( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( msmo ) ) ), 38 )
  Private old_name_smo := PadR( inieditspr( A__MENUVERT, smo_volgograd(), Int( Val( msmo ) ) ), 38 )
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1komu == 0 .and. m1company == 34
    If !Empty( mismo )
      old_name_smo := mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      old_name_smo := mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  chm_help_code := 2002
  str_1 := ' медицинской карты стационарного больного'
  If Loc_kod == 0
    str_1 := 'Добавление' + str_1
  Else
    str_1 := 'Редактирование' + str_1
  Endif
  pr_1_str( str_1 )
  SetColor( color8 )
  myclear( 1 )
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запись;  ^<F1>^ - помощь' )
  SetColor( cDataCGet )
  Do While .t.
    j := 0
    //
    ++j; @ j, 1 Say 'ФИО' Get mfio_kart ;
      reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION,,, .f. ) } ;
      valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ) }
    ++j
    If pp_NOVOR == 1
      @ j, 1 Say 'Новорожденный?' Get mnovor ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_novor( g, o ) }
      @ j, Col() + 3 Say '№/пп ребёнка' Get mcount_reb Pict '99' Range 1, 99 ;
        when ( m1novor == 1 )
      @ j, Col() + 3 Say 'Д.р. ребёнка' Get mdate_r2 when ( m1novor == 1 )
      If mem_pol == 1
        @ j, Col() + 3 Say 'Пол ребёнка' Get mpol2 ;
          reader {| x| menu_reader( x, menupol, A__MENUVERT,,, .f. ) } ;
          when ( m1novor == 1 )
      Else
        @ j, Col() + 3 Say 'Пол ребёнка' Get mpol2 Pict '@!' ;
          valid {| g| mpol2 $ 'МЖ' } ;
          when ( m1novor == 1 )
      Endif
    Endif
    //
    ++j ; @ j, 1 Say 'Режим лечения' Get mreg_lech ;
      reader {| x| menu_reader( x, mmpp_regim, A__MENUVERT,,, .f. ) }
    //
    ++j ; @ j, 1 Say '№ истории болезни' Get much_doc Picture '@!'
    If pp_kod_vr == 1
      @ j, Col() + 1 Say 'Врач приёмного отд-ия' Get MTAB_NOM Pict '99999' ;
        valid {| g| v_kart_vrach( g ) }
      @ j, Col() + 1 Get mvrach When .f. Color color14
    Endif
    ++j ; @ j, 1 Say 'Категория льготности' Get mkategor ;
      reader {| x| menu_reader( x, mmpp_kategor, A__MENUVERT,,, .f. ) }
    //
    ++j ; @ j, 1 Say 'Вид оплаты' Get mvid_opl ;
      reader {| x| menu_reader( x, menu_vid_opl, A__MENUBIT,,, .f. ) }
    @ j, 40 Say 'Статус' Get mpprab_nerab ;
      reader {| x| menu_reader( x, mmpp_rab, A__MENUBIT,,, .f. ) }
    //
    ++j ; @ j, 1 Say 'Принадлежность счета' Get mkomu ;
      reader {| x| menu_reader( x, mm_komu, A__MENUVERT,,, .f. ) } ;
      valid {| g, o| f_valid_komu( g, o ), ;
      iif( m1komu == 0, mcompany := old_name_smo, nil ), ;
      update_get( 'mcompany' ) }
    @ Row(), Col() + 1 Say '==>' Get mcompany ;
      reader {| x| menu_reader( x, mm_company, A__MENUVERT,,, .f. ) } ;
      When eq_any( m1komu, 1, 3 )
    //
    If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
      ++j ; @ j, 1 Say 'Кем направлен' Get mkem_dost ;
        reader {| x| menu_reader( x, mmpp_kem1dost, A__MENUVERT,,, .f. ) }
    Else
      ++j ; @ j, 1 Say 'Кем доставлен' Get mkem_dost ;
        reader {| x| menu_reader( x, mmpp_kem_dost, A__MENUVERT,,, .f. ) }
    Endif
    ++j ; @ j, 1 Say 'Направившая МО' Get mkem_napr ;
      reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION,,, .f. ) }
    ++j ; @ j, 1 Say 'Диагноз направившей МО :' Get MDIAG_NAPR Pict '@S52'
    ++j ; @ j, 1 Say 'Диагноз приёмного отд. :' Get MDIAG_PR_P Pict '@S52'
    ++j
    If pp_POB_D_LEK == 1
      @ j, 1 Say 'Побочное дейст.лекарств:' Get MPOB_D_LEK Pict '@S52'
    Endif
    ++j ; @ j, 1 Say 'Доставлен в сост.опьянения' Get MSOST_OP ;
      reader {| x| menu_reader( x, menu_sost_op, A__MENUVERT,,, .f. ) }
    @ j, Col() Say ',' Get MGOSPIT2 ;
      reader {| x| menu_reader( x, menu2gospit, A__MENUVERT,,, .f. ) }
    @ j, Col() + 1 Say 'от нач.заболевания'
    ++j
    If pp_TRAVMA == 1
      @ j, 1 Say 'Вид травмы' Get mtravma ;
        reader {| x| menu_reader( x, mmpp_travma, A__MENUVERT,,, .f. ) }
    Endif
    ++j ; @ j, 1 Say 'ЛПУ' Get much ;
      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c ) } }, A__FUNCTION,,, .f. ) }
    @ j, 37 Say 'Отделение' Get motd When .f.
    ++j ; @ j, 1 Say 'Дата поступления' Get mn_data Valid valid_date_postup()
    @ j, Col() Say ', время' Get mn_time Pict pict_time Valid valid_date_postup()
    ++j ; @ j, 1 Say 'Госпитализирован' Get mis_gospit ;
      reader {| x| menu_reader( x, mm_gospit, A__MENUVERT,,, .f. ) } ;
      valid {| g, o| pp_valid_gospit( g, o ) }
    @ j, Col() + 3 Say '?' Get mpr_gospit ;
      reader {| x| menu_reader( x, mmpp_pr_gospit, A__MENUVERT,,, .f. ) } ;
      When m1is_gospit == 1
    ++j ; @ j, 1 Say 'Госпит. по поводу дан.забол. в тек.году' Get mgospit0 ;
      reader {| x| menu_reader( x, menu0gospit, A__MENUVERT,,, .f. ) } ;
      When m1is_gospit == 0
    @ j, Col() Say ',' Get mgospit1 ;
      reader {| x| menu_reader( x, mm_ekst, A__MENUVERT,,, .f. ) } ;
      When m1is_gospit == 0
    ++j ; @ j, 1 Say 'Дата госпитализации' Get mg_data ;
      When m1is_gospit == 0
    @ j, Col() Say ', время' Get mg_time Pict pict_time ;
      When m1is_gospit == 0
    @ j, 50 Say 'Стол' Get mstol ;
      reader {| x| menu_reader( x, { dir_server() + 'mo_ppst' }, A__POPUPEDIT,,, .f. ) } ;
      When m1is_gospit == 0
    If Loc_kod > 0 .and. m1is_gospit == 0  // режим редактирования
      ++j ; @ j, 1 Say 'Дата выписки (смерти)' Color color8 Get mk_data ;
        valid {| g| pp_val_k_data( g ) }
      @ j, Col() Say ', время' Color color8  Get mk_time Pict pict_time ;
        When !Empty( mk_data )
      ++j ; @ j, 1 Say 'Исход' Color color8  Get mishod1 ;
        reader {| x| menu_reader( x, mmpp1ishod, A__MENUVERT,,, .f. ) }
      @ j, 40 Say 'Результат' Color color8  Get mishod2 ;
        reader {| x| menu_reader( x, mmpp2ishod, A__MENUVERT,,, .f. ) }
      //
      ++j; @ j, 1 Say 'Больничный' Color color8  Get mbolnich ;
        reader {| x| menu_reader( x, menu_bolnich, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_bolnich( g, o ) }
      @ j, Col() + 1 Say '==> с' Color color8  Get mdate_b_1 When m1bolnich > 0
      @ j, Col() + 1 Say 'по' Color color8  Get mdate_b_2 When m1bolnich > 0
      @ j, Col() + 1 Say 'Д.р.родителя' Color color8  Get mrodit_dr When m1bolnich == 2
      If mem_pol == 1
        @ j, Col() + 1 Say 'Пол' Color color8  Get mrodit_pol ;
          reader {| x| menu_reader( x, menupol, A__MENUVERT,,, .f. ) } ;
          When m1bolnich == 2
      Else
        @ j, Col() + 1 Say 'Пол' Color color8  Get mrodit_pol Pict '@!' ;
          valid {| g| mrodit_pol $ 'МЖ' } ;
          When m1bolnich == 2
      Endif
      ++j ; @ j, 1 Say 'Продолжительность госпитализации (койко-дней)' Color color8 ;
        Get MKOJKO_DNI Picture '999'
    Endif
    count_edit := myread(, @pos_read, ++k_read )
    k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
      { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
      iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2,, 'W+/N,N/BG' )
    If k == 3
      Loop
    Elseif k == 2
      If !Empty( s_msg := pp_getmsg() )
        func_error( 4, s_msg + '!' )
        Loop
      Endif
      If Loc_kod == 0 .and. kod_kartotek > 0
        fl := .f.
        r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_r', 'HU' )
        find ( Str( kod_kartotek, 7 ) )
        Do While hu->kod_k == kod_kartotek .and. !Eof()
          If mn_data == hu->n_data .and. hu->is_gospit == 0
            fl := .t.
          Endif
          Skip
        Enddo
        hu->( dbCloseArea() )
        If fl
          func_error( 4, 'По данному больному уже был ввод с датой поступления ' + full_date( mn_data ) + 'г.' )
          Loop
        Endif
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, 'Не заполнен номер истории болезни' )
        Loop
      Endif
      err_date_diap( mn_data, 'Дата начала лечения' )
      err_date_diap( mk_data, 'Дата окончания лечения' )
      If !emptyany( mn_data, mk_data ) .and. mk_data - mn_data > 182
        func_error( 4, 'Диапазон времени лечения данного больного превышает полгода!' )
      Endif
      mywait()
      use_base( 'mo_pp' )
      If Loc_kod == 0 .and. pp_ist_bol == 1
        str_sem := 'Приёмный покой - номер истории болезни'
        i := 0 ; fl := .t.
        Do While++i < 20 // столько попыток
          If g_slock( str_sem )
            g_use( dir_server() + 'pp_nastr',, 'MV' )
            k := mv->n_ist_bol + 1
            Select HU
            Set Order To 4
            Do While .t.
              find ( Str( Year( mn_data ), 4 ) + PadR( lstr( k ), 10 ) )
              If !Found() ; exit ; Endif
              ++k
            Enddo
            Select MV
            g_rlock( forever )
            mv->n_ist_bol := k
            mv->( dbCloseArea() )
            MUCH_DOC := lstr( k )
            g_sunlock( str_sem )
            fl := .f. ; Exit
          Endif
        Enddo
        If fl
          Close databases
          func_error( 4, 'Не удалось определить следующий номер истории болезни! Попытайтесь снова.' )
          Loop
        Endif
      Endif
      Select HU
      Set Order To 1
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace hu->kod With mkod
      Endif
      pr_kod_pp      := mkod
      st_rab_nerab   := M1PPRAB_NERAB
      st_reg_lech    := M1REG_LECH
      st_vrach       := m1vrach
      //
      hu->KOD_K      := MKOD_K         // код по картотеке
      hu->REG_LECH   := M1REG_LECH     // 1-стационарно, 2,3,4-дневной стационар
      hu->UCH_DOC    := MUCH_DOC       // номер медицинской карты
      hu->NOVOR      := iif( m1novor == 0, 0, mcount_reb )
      hu->DATE_R2    := iif( m1novor == 0, CToD( '' ), mDATE_R2  )
      hu->POL2       := iif( m1novor == 0, '', mpol2     )
      hu->RAB_NERAB  := M1PPRAB_NERAB
      hu->KATEGOR    := M1KATEGOR       // от 1 до ...
      hu->KOMU       := M1KOMU          // от 1 до 5
      hu->STR_CRB    := iif( eq_any( M1KOMU, 1, 3 ), m1company, 0 ) // код стр.компании, комитета и т.п.
      hu->VID_OPL    := M1VID_OPL       // вид оплаты (1-ОМС,2--бюджет,3-платные,4-ДМС,5-другое)
      hu->KEM_NAPR   := M1KEM_NAPR      // кем направлен (справочник ЛПУ)
      hu->KEM_DOST   := M1KEM_DOST      // кем доставлен
      hu->kod_vr     := m1vrach         // код врача приемного отделения
      hu->SOST_OP    := M1SOST_OP       // 0-нет,1-алкогольное,2-наркотическое
      hu->GOSPIT0    := M1GOSPIT0       // 1-первичн.,2-повторн.
      hu->GOSPIT1    := M1GOSPIT1       // 0-в плановом порядке,1-по экстренн.показаниям
      hu->GOSPIT2    := M1GOSPIT2       // 1-6часов,2-7\24часа,3-24часа\и\более
      hu->TRAVMA     := M1TRAVMA        // тип травмы
      hu->LPU        := m1uch           // код учреждения
      hu->OTD        := m1otd           // код отделения
      hu->N_DATA     := MN_DATA        // дата поступления
      hu->N_TIME     := MN_TIME        // время поступления
      hu->IS_GOSPIT  := M1IS_GOSPIT    // 0-госпитализирован, 1-нет
      hu->PR_GOSPIT  := M1PR_GOSPIT    // почему не ГОСПИТАЛИЗИРОВАН?
      hu->STOL       := M1STOL         // стол
      hu->G_DATA     := MG_DATA        // дата госпитализации
      hu->G_TIME     := MG_TIME        // время госпитализации
      hu->K_DATA     := MK_DATA        // дата окончания лечения
      hu->K_TIME     := MK_TIME        // время выписки
      hu->KOJKO_DNI  := MKOJKO_DNI     // продолжительность госпитализации
      hu->ISHOD1     := M1ISHOD1       // исход
      hu->ISHOD2     := M1ISHOD2       // исход
      hu->BOLNICH    := M1BOLNICH      // больничный (0-нет,1-да,2-по уходу)
      hu->bolnich    := m1bolnich
      hu->date_b_1   := iif( m1bolnich == 0, CToD( '' ), mdate_b_1 )
      hu->date_b_2   := iif( m1bolnich == 0, CToD( '' ), mdate_b_2 )
      hu->DATE_RODIT := iif( m1bolnich < 2, CToD( '' ), mrodit_dr )
      hu->POL_RODIT  := iif( m1bolnich < 2, '', mrodit_pol )
      If Loc_kod == 0  // только при добавлении записывать дату ввода
        hu->kod_p     := kod_polzovat
        hu->DATE_VVOD := sys_date
      Endif
      Private flag_OMS := ( hu->KOD_H > 0 )
      hu->( dbUnlock() )
      If fl_ppdia .or. !emptyall( MDIAG_NAPR, MDIAG_PR_P, MPOB_D_LEK )
        g_use( dir_server() + 'mo_ppdia', dir_server() + 'mo_ppdia', 'HUS' )
        Do While .t.
          find ( Str( mkod, 7 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        arr := { MDIAG_NAPR, MDIAG_PR_P, MPOB_D_LEK }
        For i := 1 To Len( arr )
          If !Empty( arr[ i ] )
            addrec( 7 )
            hus->kod := mkod
            hus->tip := i
            hus->name := arr[ i ]
          Endif
        Next
      Endif
      If Loc_kod == 0 .and. ;
          pp_OMS .and. ( IsBit( M1VID_OPL, 1 ) .or. IsBit( M1VID_OPL, 2 ) ) ; // ОМС,бюджет
        .and. ( M1IS_GOSPIT == 0 ;  // ГОСПИТАЛИЗИРОВАН
        .or. ( M1IS_GOSPIT == 1 .and. M1PR_GOSPIT == 99 ) ) // оказана амб.помощь в пр.покое
        g_splus( f_name_task( X_OMS ) ) // плюс 1 пользователь зашёл в задачу ОМС
        // если в задаче ОМС не выполняется ОТВЕТСТВЕННАЯ операция
        If !g_sislock( sem_vagno_task()[ X_OMS ] )
          r_use( dir_server() + 'kartote_',, 'KART_' )
          r_use( dir_server() + 'kartotek',, 'KART' )
          Set Relation To RecNo() into KART_
          r_use( dir_server() + 'mo_kismo',, 'KSN' )
          g_use( dir_server() + 'mo_hismo',, 'HSN' )
          use_base( 'human' )
          f_write_pp_oms( mkod )
        Else // иначе запишем код истории болезни в промежуточный файл
          g_use( dir_server() + 'mo_ppadd',, 'PPA' )
          Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_ppad' )
          find ( Str( mkod, 7 ) )
          If !Found()
            addrec( 7 )
            ppa->kod := mkod
          Endif
        Endif
        g_sminus( f_name_task( X_OMS ) )  // минус 1 пользователь (вышел из задачи ОМС)
      Endif
      If Loc_kod == 0 // для контроля в регистратуре
        g_use( dir_server() + 'mo_regi', { dir_server() + 'mo_regi1', ;
          dir_server() + 'mo_regi2', ;
          dir_server() + 'mo_regi3' }, 'RU' )
        addrec( 1 )
        ru->kod_k := MKOD_K // код по картотеке
        ru->tip := 1 // т.е. заносим код отделения
        ru->uch := m1uch
        ru->op  := m1otd
        ru->pdate := dtoc4( iif( Empty( MG_DATA ), sys_date, MG_DATA ) )
        ru->CTIME := iif( Empty( MG_TIME ), hour_min( Seconds() ), MG_TIME )
        ru->kod_p := kod_polzovat // код оператора
        ru->( dbCloseArea() )
      Endif
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      Close databases
      If Loc_kod > 0 .and. flag_OMS .and. OLD_IS_GOSPIT == 0 .and. OLD_IS_GOSPIT != M1IS_GOSPIT
        stat_msg( 'Т.к. пациент более не госпитализирован, удалите лист учёта в подзадаче ОМС' ) ; mybell( 10, OK )
      Endif
      a_h := {}
      // проверка по датам
      If Year( mdate_r ) < 1900
        AAdd( a_h, 'дата рождения: ' + full_date( mdate_r ) + ' ( < 1900г.)' )
      Endif
      If mdate_r > mn_data
        AAdd( a_h, 'дата рождения: ' + full_date( mdate_r ) + ;
          ' > даты поступления: ' + full_date( mn_data ) )
      Endif
      If !Empty( mk_data ) .and. mn_data > mk_data
        AAdd( a_h, 'дата начала лечения: ' + full_date( mn_data ) + ;
          ' > даты окончания лечения: ' + full_date( mk_data ) )
      Endif
      If Empty( a_h )
        stat_msg( 'Запись завершена!', .f. )
        mybell( 0.5, OK )
      Else
        stat_msg( '', .f. )
        ta := { 'Запись завершена, но обнаружены неточности:', '' }
        For i := 1 To Len( a_h )
          AAdd( ta, '- ' + a_h[ i ] )
        Next
        n_message( ta,, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
      Endif
    Endif
    Exit
  Enddo
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  Return Nil

// 12.11.17 поиск историй болезни, по которым не создан л/учёта (по каким-либо причинам)
Function f_find_pp_oms()

  Static nday := 7 // поиск на 7 дней назад
  Local i, k, arr := {}, buf := save_maxrow()

  waitstatus( 'Поиск историй болезни, по которым в подзадаче ОМС не созданы листы учёта' )
  r_use_base( 'mo_pp' )
  Set Order To 2 // index on dtos(n_data)+n_time to (dir_server()+'mo_pp_d') progress
  dbSeek( DToS( sys_date - nday ), .t. )
  Do While !Eof()
    updatestatus()
    If pp_OMS .and. ( IsBit( hu->VID_OPL, 1 ) .or. IsBit( hu->VID_OPL, 2 ) ) ; // ОМС,бюджет
      .and. ( hu->IS_GOSPIT == 0 ;  // ГОСПИТАЛИЗИРОВАН
      .or. ( hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99 ) ) // оказана амб.помощь в пр.покое
      If emptyall( hu->TIP_H, hu->KOD_H ) .and. hu->n_data >= sys_date - nday
        AAdd( arr, hu->kod )
      Endif
    Endif
    Skip
  Enddo
  If Len( arr ) > 0 // запишем коды истории болезни в промежуточный файл
    g_use( dir_server() + 'mo_ppadd',, 'PPA' )
    Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_ppad' )
    For i := 1 To Len( arr )
      find ( Str( arr[ i ], 7 ) )
      If !Found()
        addrec( 7 )
        ppa->kod := arr[ i ]
      Endif
      If i % 50 == 0
        Commit
      Endif
    Next
  Endif
  Close databases
  rest_box( buf )
  Return Nil

// 11.11.17 записать заголовок листа учёта
Function f_write_pp_oms( mkod )

  Local fl, ldata, lUSL_OK, ret_kod_h := 0

  If mkod <= 0
    Return 0
  Endif
  Select HU
  If mkod != hu->kod   // если не стоим на записи в БД ПП
    find ( Str( mkod, 7 ) ) // ищем
  Endif
  If mkod != hu->kod   // не нашли
    Return 0 // что-то не так с поиском (индексами)
  Endif
  //
  ldata := iif( hu->IS_GOSPIT == 0 .and. !Empty( hu->G_DATA ), hu->G_DATA, hu->N_DATA )
  If ldata + 14 < sys_date
    Return 1 // не записывать л/у двухнедельной давности (и более поздние)
  Endif
  If hu->IS_GOSPIT == 0 // ГОСПИТАЛИЗИРОВАН
    lUSL_OK := pp_reg_lech_usl_ok( hu->reg_lech )
  Else // (M1IS_GOSPIT == 1 .and. M1PR_GOSPIT == 99)) // оказана амб.помощь в пр.покое
    lUSL_OK := 3 // поликлиника
  Endif
  If Empty( hu->kod_h ) // проверить, если ещё не записано (по данным в БД приёмного покоя)
    Select HUMAN
    Set Order To 2
    find ( Str( hu->kod_k, 7 ) )
    Do While human->kod_k == hu->kod_k .and. !Eof()
      If lUSL_OK == human_->USL_OK .and. human->n_data == ldata // этот л/у введён ручками
        ret_kod_h := human->( RecNo() )
        Exit
      Endif
      Skip
    Enddo
    If ret_kod_h > 0 // запишем ссылку на лист учёта в БД приёмного покоя
      Select HU
      g_rlock( forever )
      hu->TIP_H := 1      // 1-human,2-hum_p,3-...
      hu->KOD_H := ret_kod_h // код по БД human
      If hu->IS_GOSPIT == 0 .and. Empty( hu->G_DATA ) // 0-госпитализирован и не заполнена дата госпитализации
        hu->G_DATA := hu->N_DATA   // дата госпитализации
        hu->G_TIME := hu->N_TIME   // время госпитализации
      Endif
      dbUnlock()
      Return ret_kod_h
    Endif
  Endif
  m1novor := hu->NOVOR
  Select KART
  Goto ( hu->kod_k )
  mdate_r := kart->date_r
  If hu->IS_GOSPIT == 0
    fv_date_r( hu->g_data, .f. ) // переопределяем m1vzros_reb
  Else
    fv_date_r( hu->n_data, .f. ) // переопределяем m1vzros_reb
  Endif
  If !( Type( 'M1VZROS_REB' ) == 'N' )
    M1VZROS_REB := 0 // на всякий случай (т.к. до этого были сбои в определении)
  Endif
  Select HUMAN
  Set Order To 1
  If Empty( ret_kod_h := hu->kod_h ) // проверить, если ещё не записано
    add1rec( 7 )
    human->kod := RecNo()
    human->TIP_H := yes_vypisan
    ret_kod_h := human->kod
    // запишем ссылку на лист учёта в БД приёмного покоя
    Select HU
    g_rlock( forever )
    hu->TIP_H := 1      // 1-human,2-hum_p,3-...
    hu->KOD_H := human->kod // код по БД human
    If hu->IS_GOSPIT == 0 .and. Empty( hu->G_DATA ) // 0-госпитализирован и не заполнена дата госпитализации
      hu->G_DATA := hu->N_DATA   // дата госпитализации
      hu->G_TIME := hu->N_TIME   // время госпитализации
    Endif
  Else // иначе допишем запись, т.к., скорее всего, она недозаписалась
    fl := .t.
    Goto ( ret_kod_h )
    If human->kod_k != hu->KOD_K // уже не тот человек
      fl := .f.
    Endif
    If fl .and. human_->REESTR > 0 // попал в реестр
      fl := .f.
    Endif
    If fl .and. !Empty( human->K_DATA ) // заполнены даты
      fl := .f.
    Endif
    If fl
      Select HUMAN
      g_rlock( forever )
    Else
      Return ret_kod_h
    Endif
  Endif
  Select HUMAN_
  Do While human_->( LastRec() ) < human->kod
    Append Blank
  Enddo
  Goto ( human->kod )
  g_rlock( forever )
  //
  Select HUMAN_2
  Do While human_2->( LastRec() ) < human->kod
    Append Blank
  Enddo
  Goto ( human->kod )
  g_rlock( forever )
  //
  human->kod_k     := hu->KOD_K
  human->FIO       := kart->fio       // Ф.И.О. больного
  human->POL       := kart->pol       // пол
  human->DATE_R    := kart->date_r    // дата рождения больного
  human->VZROS_REB := M1VZROS_REB     // 0-взрослый, 1-ребенок, 2-подросток
  human->ADRES     := kart->ADRES     // адрес больного
  human->RAB_NERAB := kart->RAB_NERAB // 0-работающий, 1 -неработающий
  human->MR_DOL    := kart->MR_DOL    // место работы или причина безработности
  human->KOMU      := hu->KOMU        // от 0 до 5
  human_->SMO      := iif( hu->KOMU == 0, kart_->smo, '' )
  human->STR_CRB   := hu->STR_CRB // код прочей компании, комитета
  human->POLIS     := make_polis( kart_->spolis, kart_->npolis ) // серия и номер страхового полиса
  human->LPU       := hu->lpu           // код учреждения
  human->OTD       := hu->OTD           // код отделения
  human->UCH_DOC   := hu->UCH_DOC        // вид и номер учетного документа
  human->N_DATA    := iif( hu->IS_GOSPIT == 0 .and. !Empty( hu->G_DATA ), hu->G_DATA, hu->N_DATA ) // дата начала лечения
  human->K_DATA    := iif( hu->IS_GOSPIT == 0 .and. !Empty( hu->G_DATA ), hu->G_DATA, hu->N_DATA ) // дата начала лечения
  human->bolnich   := hu->bolnich
  human->date_b_1  := iif( hu->bolnich == 0, '', dtoc4( hu->date_b_1 ) )
  human->date_b_2  := iif( hu->bolnich == 0, '', dtoc4( hu->date_b_2 ) )
  human_->RODIT_DR := iif( hu->bolnich < 2, CToD( '' ), hu->rodit_dr )
  human_->RODIT_POL := iif( hu->bolnich < 2, '', hu->rodit_pol )
  human_->TRAVMA   := pp_travma_travma( hu->travma )
  human_->VPOLIS   := kart_->VPOLIS
  human_->SPOLIS   := kart_->SPOLIS
  human_->NPOLIS   := kart_->NPOLIS
  human_->OKATO    := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
  human_->NOVOR    := hu->NOVOR
  human_->DATE_R2  := hu->DATE_R2
  human_->POL2     := hu->POL2
  human_->USL_OK   := lUSL_OK
  // human_->idsp     := pp_reg_lech_idsp(hu->reg_lech)
  human_->NPR_MO   := hu->KEM_NAPR
  human_->FORMA14  := iif( hu->GOSPIT1 == 1, '1', '0' ) + ;
    iif( hu->GOSPIT1 == 1 .and. hu->KEM_DOST == 1, '1', '0' ) + '00'
  human->CENA := human->CENA_1 := 0 // стоимость лечения
  human_->OPLATA    := 0
  human_->ST_VERIFY := 0
  human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
  human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
  human_->SUMP      := 0
  human_->SANK_MEK  := 0
  human_->SANK_MEE  := 0
  human_->SANK_EKMP := 0
  human_->REESTR    := 0
  human_->REES_ZAP  := 0
  human->schet      := 0
  human_->SCHET_ZAP := 0
  human->kod_p      := hu->kod_p    // код оператора из приёмного покоя
  human->date_e     := dtoc4( hu->DATE_VVOD ) // дата добавления истории болезни в приёмном покое
  //
  put_0_human_2()
  human_2->P_PER := iif( eq_any( hu->KEM_DOST, 1, 2 ), 2, 1 ) // {'Поступил самостоятельно',1},{'Доставлен СМП',2},;
  If AllTrim( human_->SMO ) == '34'
    Select KSN
    Index On Str( kod, 7 ) to ( cur_dir() + 'tmpkismo' )
    find ( Str( human->kod_k, 7 ) )
    If Found()
      Select HSN
      Append Blank
      hsn->kod := human->kod
      hsn->smo_name := ksn->smo_name
    Endif
  Endif
  dbUnlockAll()
  Return ret_kod_h

// 10.09.25 записать незаписанные истории болезней из приёмного покоя
Function write_rest_pp()

  Local i, k, arr := {}, bSaveHandler, buf := save_maxrow()

  bSaveHandler := ErrorBlock( {| x| Break( x ) } )
  Begin Sequence
    If g_use( dir_server() + 'mo_ppadd',, 'PPA' )
      dbEval( {|| AAdd( arr, { ppa->kod, ppa->( RecNo() ) } ) }, {|| Empty( ppa->kod_h ) } )
      If !Empty( arr )
        g_splus( f_name_task( X_OMS ) ) // плюс 1 пользователь зашёл в задачу ОМС
        // если в задаче ОМС не выполняется ОТВЕТСТВЕННАЯ операция
        If !g_sislock( sem_vagno_task()[ X_OMS ] )
          r_use( dir_server() + 'kartote_',, 'KART_' )
          r_use( dir_server() + 'kartotek',, 'KART' )
          Set Relation To RecNo() into KART_
          r_use( dir_server() + 'mo_kismo',, 'KSN' )
          g_use( dir_server() + 'mo_hismo',, 'HSN' )
          use_base( 'human' )
          use_base( 'mo_pp' )
          waitstatus( 'Запись незаписанных историй болезни из ПРИЁМНОГО ПОКОЯ в ОМС' )
          Private mdate_r, m1vzros_reb, m1novor
          For i := 1 To Len( arr )
            updatestatus()
            If ( k := f_write_pp_oms( arr[ i, 1 ] ) ) > 0
              Select PPA
              Goto ( arr[ i, 2 ] )
              If ppa->kod_h != k
                g_rlock( forever )
                ppa->kod_h := k // записать на всякий случай
                Unlock
              Endif
              deleterec( .t. ) // а теперь очистим и пометим на удаление
            Endif
            If i % 20 == 0
              Commit
            Endif
          Next
          Close databases
        Endif
        g_sminus( f_name_task( X_OMS ) )  // минус 1 пользователь (вышел из задачи ОМС)
      Endif
    Endif
  RECOVER USING error
    //
  End
  ErrorBlock( bSaveHandler )
  Close databases
  rest_box( buf )
  Return Nil

//
Function pp_getmsg()

  Local s_msg := ''

  //
  If m1uch == 0
    s_msg := 'Не введено лечебное учреждение'
  Elseif m1otd == 0
    s_msg := 'Не введено отделение'
  Elseif !Empty( s := pp_ver_data( MN_DATA, 'Дата поступления' ) )
    s_msg := s
  Elseif !Empty( s := pp_ver_data( MG_DATA, 'Дата госпитализации' ) )
    s_msg := s
  Elseif !Empty( s := pp_ver_data( MK_DATA, 'Дата окончания лечения' ) )
    s_msg := s
  Elseif Empty( m1pprab_nerab )
    s_msg := 'Не введен социальный статус'
  Elseif Empty( m1vid_opl )
    s_msg := 'Не введен вид оплаты'
  Elseif m1bolnich > 0 .and. mdate_b_1 > mdate_b_2
    s_msg := 'Некорректные даты начала и окончания больничного'
  Elseif m1is_gospit == 1 .and. m1pr_gospit == 0
    s_msg := 'не заполнено поле "Почему не госпитализирован?"'
  Elseif m1is_gospit == 0
    If M1STOL == 0
      s_msg := 'не заполнено поле "Стол"'
    Else
      r_use( dir_server() + 'mo_ppst',, 'STOL' )
      Goto ( m1stol )
      If M1REG_LECH == 1
        If stol->tip == 1
          s_msg := 'режим лечения "Стационар", а СТОЛ введен для "Дневного стационара"'
        Endif
      Else
        If stol->tip == 0
          s_msg := 'режим лечения "Дневной стационар", а СТОЛ введен для "стационара"'
        Endif
      Endif
      Use
    Endif
  Endif
  Return s_msg

// замена травмы для БД ОМС
Function pp_travma_travma( ltravma )

  Local k := 0

  Do Case
  Case ltravma == 1  ; k := 1
  Case ltravma == 2  ; k := 4
  Case ltravma == 3  ; k := 4
  Case ltravma == 4  ; k := 2
  Case ltravma == 5  ; k := 5
  Case ltravma == 6  ; k := 6
  Case ltravma == 7  ; k := 7
  Case ltravma == 8  ; k := 8
  Case ltravma == 9  ; k := 8
  Case ltravma == 10 ; k := 9
  Case ltravma == 11 ; k := 10
  Case ltravma == 12 ; k := 11
  Case ltravma == 13 ; k := 11
  Endcase
  Return k

// замена условия оказания мед.помощи для БД ОМС
Function pp_reg_lech_usl_ok( lreg_lech )
  Return iif( lreg_lech > 1, 2, 1 )

// замена способа оплаты для БД ОМС
Function pp_reg_lech_idsp( lreg_lech )

  Local k := 5

  Do Case
  Case k == lreg_lech // стационар круглосуточного пребывания
    k := 5
  Case k == lreg_lech // дневной стационар при больнице
    k := 6
  Case k == lreg_lech // дневной стационар при поликлинике
    k := 7
  Case k == lreg_lech // дневной стационар на дому
    k := 8
  Endcase
  Return k

//
Function pp_ver_data( ldata, s )

  Local s1 := ''

  If !Empty( ldata )
    If ldata > sys_date
      s1 := '"' + s + '" превышает системную дату'
    Elseif ldata < sys_date - 365 * 5  // 5 лет назад
      s1 := 'Некорректное значение поля "' + s + '"'
    Endif
  Endif
  Return s1

//
Function valid_date_postup()

  If mn_data > mg_data .and. m1is_gospit == 0
    mg_data := mn_data
    mg_time := mn_time
    update_gets( 'mg_data' )
    update_gets( 'mg_time' )
  Endif
  Return .t.

//
Function pp_val_k_data( get )

  If !Empty( mk_data )
    If mn_data > mk_data
      mk_data := get:original
      Return func_error( 4, 'Дата начала лечения больше даты окончания лечения. Ошибка!' )
    Endif
    If mk_data != get:original
      mk_time := '11:00'
    Endif
  Endif
  Return .t.

// 07.11.17
Function pp_valid_gospit( get, old )

  If m1is_gospit != old .and. old != NIL
    If m1is_gospit == 0
      m1pr_gospit := 0 ; mpr_gospit := Space( 35 ) ; update_get( 'mpr_gospit' )
      If Empty( mg_data )
        mg_data := mn_data
        mg_time := mn_time
        update_gets( 'mg_data' )
        update_gets( 'mg_time' )
      Endif
    Else
      m1gospit0 := 0 ; mgospit0 := PadR( '', Len( menu0gospit[ 1, 1 ] ) )
      m1gospit1 := 0 ; mgospit1 := PadR( '', Len( mm_ekst[ 1, 1 ] ) )
      m1stol    := 0 ; mstol := Space( 10 )
      mg_data := CToD( '' )
      mg_time := Space( 5 )
      update_gets()
    Endif
  Endif
  Return .t.

// 12.09.25 выбрать карточку пациента из картотеки
Function ppokoj_kart( k )

  // k = 1 - начало лечения -> ввод карточки
  // k = 2 - возврат кода по картотеке
  Static sesc := '^<Esc>^ выход  '
  Static senter := '^<Enter>^ ввод  '
  Static sF10f := '^<F10>^ поиск по ФИО  '
  Static sF10p := '^<F10>^ поиск по полису  '
  Static sF10s := '^<F10>^ поиск по СНИЛС  '
  Static sF11 := '^<F11>^ читать электронный полис'
  Static _err_slock := 'В данный момент со стат.картой этого пациента работает другой пользователь.'
  Static s_regim := 1, s_shablon := '', s_polis := '', s_snils := ''
  Local tmp1, mkod := -1, i, fl_number := .t., s, append_or_edit := 0, ;
    k1 := 0, k2 := 1, str_sem, mbukva := '', tmp_color, buf, buf24, ar
  // обмен информацией с программой Smart Delta Systems
  import_kart_from_sds()
  // ///////////////////////////////////////////////////
  Private tmp, name_reader := ''
  ar := getinivar( tmp_ini(), { { 'polikl1','s_regim','1' }, ;
    { 'polikl1','s_shablon', '' }, ;
    { 'polikl1','s_polis','' }, ;
    { 'polikl1','s_snils','' }, ;
    { 'RAB_MESTO', 'sc_reader', '' } } )
  If !eq_any( s_regim := Int( Val( ar[ 1 ] ) ), 1, 2, 3 )
    s_regim := 1
  Endif
  s_shablon := ar[ 2 ]
  s_polis   := ar[ 3 ]
  s_snils   := ar[ 4 ]
  name_reader := ar[ 5 ]
  Do While .t.
    buf24 := save_maxrow()
    If s_regim == 1
      If Empty( s_shablon )
        s_shablon := '*'
      Endif
      tmp := PadR( s_shablon, 20 )
      tmp_color := SetColor( color1 )
      buf := box_shadow( 18, 9, 20, 70 )
      @ 19, 11 Say 'Введите шаблон для поиска в картотеке' Get tmp Pict '@K@!'
      s := sesc + senter + sF10p
      If !Empty( name_reader )
        s += sF11
      Endif
      status_key( AllTrim( s ) )
    Elseif s_regim == 2
      tmp := PadR( s_polis, 17 )
      tmp_color := SetColor( color8 )
      buf := box_shadow( 18, 9, 20, 70 )
      @ 19, 13 Say 'Введите ПОЛИС для поиска в картотеке' Get tmp Pict '@K@!'
      s := sesc + senter + sF10s
      If !Empty( name_reader )
        s += sF11
      Endif
      status_key( AllTrim( s ) )
    Else
      tmp := PadR( s_snils, 11 )
      tmp_color := SetColor( color14 )
      buf := box_shadow( 18, 9, 20, 70 )
      @ 19, 14 Say 'Введите СНИЛС для поиска в картотеке' Get tmp Pict '@K' + picture_pf() Valid val_snils( tmp, 1 )
      s := sesc + senter + sF10f
      If !Empty( name_reader )
        s += sF11
      Endif
      status_key( AllTrim( s ) )
    Endif
    Set Key K_F10 To clear_gets
    If !Empty( name_reader )
      Set Key K_F11 To clear_gets
    Endif
    myread( { 'confirm' } )
    Set Key K_F11 To
    Set Key K_F10 To
    SetColor( tmp_color )
    rest_box( buf24 )
    rest_box( buf )
    If LastKey() == K_F10
      s_regim := iif( ++s_regim == 4, 1, s_regim )
    Elseif LastKey() == K_F11 .and. !Empty( name_reader )
      If mo_read_el_polis( @append_or_edit )
        mkod := glob_kartotek
        Exit
      Endif
    Else
      If LastKey() == K_ESC
        tmp := NIL
      Else
        If s_regim == 1
          s_shablon := AllTrim( tmp )
        Elseif s_regim == 2
          s_polis := tmp
        Else
          s_snils := tmp
        Endif
      Endif
      Exit
    Endif
  Enddo
  If tmp == NIL
    //
  Elseif mkod > 0
    str_sem := 'ПП - Редактирование человека ' + lstr( glob_kartotek )
    If g_slock( str_sem )
      f_kart_pp(, glob_kartotek )
      g_sunlock( str_sem )
    Else
      func_error( 4, _err_slock )
    Endif
  Elseif s_regim == 1
    s_shablon := AllTrim( tmp )
    If Empty( tmp := AllTrim( tmp ) )
      mkod := 0
      If k == 1  // режим 'Добавление'
        f_kart_pp()
      Endif
    Elseif tmp == '*'
      If oms_view_kart( T_ROW )
        mkod := glob_kartotek
        If k == 1
          str_sem := 'ПП - Редактирование человека ' + lstr( glob_kartotek )
          If g_slock( str_sem )
            f_kart_pp(, glob_kartotek )
            g_sunlock( str_sem )
          Else
            func_error( 4, _err_slock )
          Endif
        Endif
      Endif
    Else
      If is_uchastok == 1
        tmp1 := tmp
        If !( Left( tmp, 1 ) $ '0123456789' )
          mbukva := Left( tmp1, 1 )
          tmp1 := SubStr( tmp1, 2 )  // отбросить первую букву
        Endif
        For i := 1 To Len( tmp1 )
          If !( SubStr( tmp1, i, 1 ) $ '0123456789/' )
            fl_number := .f. ; Exit
          Endif
        Next
        If fl_number
          If ( i := At( '/', tmp1 ) ) == 0
            fl_number := .f.
          Else
            tmp := PadL( AllTrim( SubStr( tmp1, 1, i - 1 ) ), 2, '0' ) + ;
              PadL( AllTrim( SubStr( tmp1, i + 1 ) ), 5, '0' )
          Endif
        Endif
      Else
        For i := 1 To Len( tmp )
          If !( SubStr( tmp, i, 1 ) $ '0123456789' )
            fl_number := .f. ; Exit
          Endif
        Next
      Endif
      If !fl_number
        If !( '*' $ tmp ) ; tmp += '*' ; Endif
      Endif
      If k == 1
        If fvalid_fio( 1, tmp, fl_number, mbukva )
          str_sem := 'ПП - Редактирование человека ' + lstr( glob_kartotek )
          If g_slock( str_sem )
            f_kart_pp(, glob_kartotek )
            g_sunlock( str_sem )
          Else
            func_error( 4, _err_slock )
          Endif
        Else
          Keyboard Chr( K_ENTER )  // 'нажать' кнопку 'Добавление'
        Endif
      Elseif k == 2
        If fvalid_fio( 1, tmp, fl_number, mbukva )
          mkod := glob_kartotek
        Else
          fl_bad_shablon := .t.
        Endif
      Endif
    Endif
  Elseif eq_any( s_regim, 2, 3 )  // поиск по полису/по СНИЛС
    If Empty( tmp )
      mkod := 0
      If k == 1  // режим 'Добавление' в задаче LPU
        f_kart_pp()
      Endif
    Elseif k == 1
      If fvalid_fio( s_regim, tmp, fl_number, mbukva )
        str_sem := 'ПП - Редактирование человека ' + lstr( glob_kartotek )
        If g_slock( str_sem )
          f_kart_pp(, glob_kartotek )
          g_sunlock( str_sem )
        Else
          func_error( 4, _err_slock )
        Endif
      Else
        Keyboard Chr( K_ENTER )  // 'нажать' кнопку 'Добавление'
      Endif
    Elseif k == 2
      If fvalid_fio( s_regim, tmp, fl_number, mbukva )
        mkod := glob_kartotek
      Else
        fl_bad_shablon := .t.
      Endif
    Endif
  Endif
  setinisect( tmp_ini(), 'polikl1', { { 's_regim',lstr( s_regim ) }, ;
    { 's_shablon', s_shablon    }, ;
    { 's_polis',s_polis      }, ;
    { 's_snils',s_snils      } } )
  Return mkod

// 19.03.18
Function view_human_pp( regim, lkod )

  // regim = 1 - редактирование
  // regim = 2 - удаление
  // regim = 3 - перевод из отделения в отделение
  Local buf := SaveScreen(), i, mkod := 0, k, l_color, t_arr[ BR_LEN ], ;
    fl := .f., mtitul, ind2, arr_blk, fl_schet := .f., str_sem, ;
    fl_ret := .f., tmp_help, fl_perevod, fl_human
  Default lkod To glob_perso_pp
  Private mr1 := T_ROW, pp_regim := regim, blk_open
  pr_kod_pp := NIL
  blk_open := {|| dbCloseAll(), ;
    iif( yes_parol, r_use( dir_server() + 'base1',, 'BASE1' ), nil ), ;
    r_use( dir_server() + 'mo_otd',, 'OTD' ), ;
    r_use( dir_server() + 'kartote2',, 'KART2' ), ;
    r_use( dir_server() + 'kartote_',, 'KART_' ), ;
    r_use( dir_server() + 'kartotek',, 'KART' ), ;
    dbSetRelation( 'KART_', {|| RecNo() }, 'recno()' ), ;
    r_use( dir_server() + 'mo_ppper', dir_server() + 'mo_ppper', 'HUP' ), ;
    r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' ), ;
    dbSetRelation( 'KART', {|| kod_k }, 'kod_k' ), ;
    dbGoTop();
    }
  Eval( blk_open )
  If Eof()
    func_error( 4, 'База данных приемного покоя пуста!' )
  Else
    If lkod == 0
      Go Bottom
    Else
      Goto ( lkod )
    Endif
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_STEP_FUNC ] := {|| f4_v_human_pp() }
    t_arr[ BR_BOTTOM ] := MaxRow() -5
    t_arr[ BR_LEFT ]   := 0
    t_arr[ BR_RIGHT ]  := 79
    t_arr[ BR_COLOR ]  := color0
    // t_arr[BR_TITUL]  := 'Выбор больного'
    // t_arr[BR_TITUL_COLOR] := 'BG+/GR'
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,' + ;
      'B/BG,W+/B,' + ;
      'N+/BG,W/N,' + ;
      'R/BG,W+/R,' + ;
      'W+/BG,N/W,' + ;
      'GR+/R,R/GR*', .f., 60 }
    Private nAddrLine := 1 // Номер рассматриваемой адресной строки
    blk := {|| f1_v_human_pp() }
    Private blk_rr := {|| 2 }
    t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F1>^ - помощь' ) }
    t_arr[ BR_ARR_BLOCK ] := { {|| gofirst( @nAddrLine, blk_rr ) }, ;
      {|| golast( @nAddrLine, blk_rr ) }, ;
      {| x| gonext( x, @nAddrLine, blk_rr ) }, ;
      '', '.t.';
      }
    t_arr[ BR_COLUMN ] := {}
    AAdd( t_arr[ BR_COLUMN ], { '№ ист.болезни,;время поступл.', ;
      {|| f3_v_human_pp( 1, nAddrLine ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { 'Дн/ст', ;
      {|| f3_v_human_pp( 3, nAddrLine ) }, {|| iif( hu->REG_LECH > 1, { 11, 11 }, { 1, 1 } ) } } )
    AAdd( t_arr[ BR_COLUMN ], { ' Фамилия, имя, отчество больного,; отделение, СМО', ;
      {|| f3_v_human_pp( 2, nAddrLine ) }, blk } )
    t_arr[ BR_EDIT ] := {| nk, ob| f2_v_human_pp( nk, ob ) }
    t_arr[ BR_ENTER ] := {|| glob_perso_pp := hu->kod, fl_ret := .t. }
    box_shadow( MaxRow() -4, 2, MaxRow() -2, 77, 'W/B' )
    tmp_help := chm_help_code
    chm_help_code := 202
    edit_browse( t_arr )
    chm_help_code := tmp_help
    RestScreen( buf )
    If fl_ret
      If ( glob_perso_pp := hu->kod ) == 0
        func_error( 4, 'Не найдено нужных записей!' )
      Else
        mkod := pr_kod_pp := glob_perso_pp
        glob_kartotek := hu->kod_k
        glob_k_fio := AllTrim( kart->fio )
        If eq_any( regim, 2, 3 )
          fl := .t.
          str_sem := 'ПП - Редактирование человека ' + lstr( glob_kartotek )
          If !g_slock( str_sem )
            fl := func_error( 4, 'В данный момент со стат.картой этого пациента работает другой пользователь.' )
          Endif
          If fl .and. !Empty( hu->K_DATA )
            fl := func_error( 4, 'Данный пациент уже выписан из больницы. Операция запрещена!' )
          Endif
          If fl .and. regim == 2  // удаление
            If ( fl_human := ( hu->kod_h > 0 ) )
              r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
              find ( Str( hu->kod_h, 7 ) )
              If Found() .and. human->cena > 0
                fl := func_error( 4, 'С данным пациентом уже работали в программе ОМС. Удаление запрещено!' )
              Endif
              human->( dbCloseArea() )
            Endif
            Select HUP
            find ( Str( hu->kod, 7 ) )
            If ( fl_perevod := Found() )
              n_message( { '', 'Данный больной уже переводился из отделения в отделение!' },, ;
                color1, cDataCSay,,, color8 )
            Endif
            If fl .and. f_esc_enter( 2, .t. ) .and. f_esc_enter( 2, .t. ) // удаление
              mywait()
              mkod := hu->( RecNo() )
              Close databases
              // переоткрыть для удаления
              use_base( 'mo_pp' )
              Set Order To 0
              Goto ( mkod )
              g_use( dir_server() + 'mo_ppadd',, 'PPA' )
              Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_ppad' )
              find ( Str( hu->kod, 7 ) )
              If Found()
                deleterec( .t. )
              Endif
              g_use( dir_server() + 'mo_ppdia', dir_server() + 'mo_ppdia', 'HUD' )
              Do While .t.
                find ( Str( hu->kod, 7 ) )
                If !Found() ; exit ; Endif
                deleterec( .t. )
              Enddo
              If fl_perevod
                g_use( dir_server() + 'mo_ppper', dir_server() + 'mo_ppper', 'HUP' )
                Do While .t.
                  find ( Str( hu->kod, 7 ) )
                  If !Found() ; exit ; Endif
                  deleterec( .t. )
                Enddo
              Endif
              If fl_human
                use_base( 'human' )
                find ( Str( hu->kod_h, 7 ) )
                If Found()
                  deleterec( .t. )
                Endif
                human->( dbCloseArea() )
              Endif
              Select HU
              deleterec( .t. )
              glob_perso_pp := 0
              write_work_oper( glob_task, OPER_LIST, 3 )
              stat_msg( 'Удаление завершено!' ) ; mybell( 2, OK )
            Endif
          Endif
          g_sunlock( str_sem )
        Endif
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )
  If mkod > 0 .and. regim == 1
    str_sem := 'ПП - Редактирование человека ' + lstr( glob_kartotek )
    If g_slock( str_sem )
      f_kart_pp( mkod, glob_kartotek )
      g_sunlock( str_sem )
    Else
      Return func_error( 4, 'В данный момент со стат.картой этого пациента работает другой пользователь.' )
    Endif
  Endif
  Return ( mkod > 0 )

//
Function f1_v_human_pp()

  Local ret := { 5, 6 }

  If nAddrLine == 1
    If hu->ishod2 == 6
      ret := { 7, 8 }
    Elseif hu->is_gospit == 1 .or. !Empty( hu->k_data )
      ret := { 3, 4 }
    Else
      ret := { 1, 2 }
      hup->( dbSeek( Str( hu->kod, 7 ) ) )
      If hup->( Found() )
        ret := { 9, 10 }
      Endif
    Endif
  Endif
  Return ret

//
Function f3_v_human_pp( k, line )

  Local s := '', s1, s2, n2 := 52, lotd, ltime

  If k == 1
    If line == 1
      s := PadC( AllTrim( hu->uch_doc ), 16 )
    Else
      s := full_date( hu->n_data ) + ' ' + hu->n_time
    Endif
  Elseif k == 2
    If line == 1
      s := ' ' + PadR( kart->fio, n2 )
    Else
      s2 := AllTrim( f4_view_list_schet( hu->komu, cut_code_smo( kart_->smo ), hu->str_crb ) )
      lotd := hu->otd
      hup->( dbSeek( Str( hu->kod, 7 ) ) )
      If hup->( Found() )
        lotd := hup->otd ; ltime := DToS( hup->n_data ) + n_time
        Do While hu->kod == hup->kod
          If ltime < DToS( hup->n_data ) + n_time
            lotd := hup->otd ; ltime := DToS( hup->n_data ) + n_time
          Endif
          hup->( dbSkip() )
        Enddo
      Endif
      otd->( dbGoto( lotd ) )
      s1 := ' ' + AllTrim( otd->name )
      If Len( s1 ) + Len( s2 ) + 1 <= n2
        s := PadR( s1, n2 - Len( s2 ) ) + s2
      Else
        s := PadR( s1 + ' ' + s2, n2 )
      Endif
    Endif
  Else
    s := Space( 5 )
    If hu->REG_LECH > 1
      s := iif( line == 1, 'днев.', 'стац.' )
    Endif
  Endif
  Return s

//
Function f4_v_human_pp()

  Local s1 := '', s2 := '', k, tmp_select := Select(), lc2 := color8

  If yes_parol .and. ( k := Asc( hu->kod_p ) ) > 0
    Select BASE1
    Goto ( k )
    s1 := 'Оператор: ' + Crypt( base1->p1, gpasskod )
  Endif
  If !Empty( hu->k_data )
    s2 := iif( hu->ishod2 == 6, 'Дата смерти: ', 'Дата выписки: ' ) + full_date( hu->k_data )
  Elseif !Empty( hu->date_vvod )
    s2 := 'дата ввода: ' + full_date( hu->date_vvod )
    lc2 := color14
  Endif
  @ MaxRow() -3, 4 Say PadR( s1, 35 ) Color color1
  @ MaxRow() -3, 41 Say PadL( s2, 35 ) Color lc2
  Select ( tmp_select )
  Return Nil

// 17.11.25
Function f2_v_human_pp( nkey, oBrow )

  // наименования файлов шаблонов
  Static sb1 := '<b><u>', sb2 := '</u></b>'
  Static stmp2 := '', stmp3 := ''
  Local buf := SaveScreen(), buf1, rec1 := RecNo(), ret := -1, fl, ch, ;
    arr, ap, i, j, k, s, lfio, sExt, mmo_pr, s1
  Local lnomer, l1nomer, muchastok, mdate_r, luchast
  If pp_regim == 1 .and. eq_any( nkey, K_F5, K_F6, K_F7, K_F8, K_F9, K_F10, K_F12 )
    _pp_nastr( 1 ) // перечитать имена шаблонов
    delfrfiles()
    dbCreate( fr_data, { ;
      { 'n_data',     'D',  8, 0 }, ;
      { 'n_time',     'C',  5, 0 }, ;
      { 'g_data',     'D',  8, 0 }, ;
      { 'g_time',     'C',  5, 0 }, ;
      { 'kod_k',      'N',  7, 0 }, ;
      { 'uch_doc',    'C', 10, 0 }, ;
      { 'org_name',   'C', 255, 0 }, ;
      { 'name_uch',   'C', 30, 0 }, ;
      { 'name_otd',   'C', 30, 0 }, ;
      { 'reg_lech',   'N',  1, 0 }, ;
      { 'regim_lu',   'C', 80, 0 }, ;
      { 'regim_66',   'C', 80, 0 }, ;
      { 'regim_ib',   'C', 80, 0 }, ;
      { 'regim_llu',  'C', 60, 0 }, ;
      { 'regim_l2u',  'C', 200, 0 }, ;
      { 'regim_l3u',  'C', 200, 0 }, ;
      { 'vidpolis',   'C', 12, 0 }, ;
      { 'mesto_rog',  'C', 100, 0 }, ;
      { 'gorod_selo', 'C', 20, 0 }, ;
      { 'gorodselo', 'C', 100, 0 }, ;
      { 'fio',        'C', 130, 0 }, ;
      { 'fio1',       'C', 130, 0 }, ;
      { 'polis',      'C', 25, 0 }, ;
      { 'beg_polis',  'C', 10, 0 }, ;
      { 'srok_polis', 'C', 10, 0 }, ;
      { 'snils',      'C', 14, 0 }, ;
      { 'pol',        'C',  1, 0 }, ;     // ВНИМАНИЕ 50
    { 'poll',       'C', 15, 0 }, ;
      { 'date_r',     'D',  8, 0 }, ;     // c10
    { 'count_ymd',  'C', 90, 0 }, ;
      { 'kategor',    'C', 40, 0 }, ;
      { 'vid_ud',     'C', 30, 0 }, ;
      { 'ser',        'C', 10, 0 }, ;
      { 'nom',        'C', 10, 0 }, ;
      { 'kogdavyd',   'D',  8, 0 }, ;     // c10
    { 'kemvyd',     'C', 150, 0 }, ;
      { 'adres',      'C', 200, 0 }, ;     // 120
    { 'adresp',     'C', 200, 0 }, ;     // 120
    { 'mr_dol',     'C', 50, 0 }, ;
      { 'phone',      'C', 90, 0 }, ;
      { 'rab_nerab',  'C', 20, 0 }, ;
      { 'vzros_reb',  'C', 20, 0 }, ;
      { 'mi_git',     'C', 90, 0 }, ;
      { 'rajon_git',  'C', 90, 0 }, ;
      { 'mest_inog',  'C', 90, 0 }, ;
      { 'rajon_fin',  'C', 90, 0 }, ;
      { 'novor',      'C', 90, 0 }, ;
      { 'gospit0',    'C', 30, 0 }, ;
      { 'gospit1',    'C', 30, 0 }, ;
      { 'gospit2',    'C', 30, 0 }, ;
      { 'dost_skor',  'C',  3, 0 }, ;
      { 'sost_op',    'C', 40, 0 }, ;
      { 'kem_dost',   'C', 100, 0 }, ;
      { 'kem_napr',   'C', 150, 0 }, ;
      { 'DIAG_NAPR',  'C', 100, 0 }, ;
      { 'DIAG_PR_P',  'C', 100, 0 }, ;
      { 'POB_D_LEK',  'C', 100, 0 }, ;
      { 'HEIGHT',     'C',  7, 0 }, ;
      { 'WEIGHT',     'C',  7, 0 }, ;
      { 'kol_pred',   'N',  1, 0 }, ;
      { 'DATE_ROD',   'D',  8, 0 }, ;
      { 'DATE_ROD2',  'D',  8, 0 }, ;
      { 'FIO_ROD',    'C', 65, 0 }, ;
      { 'FIO_ROD2',   'C', 65, 0 }, ;
      { 'uhod_rod',   'C', 50, 0 }, ;
      { 'ADRES_ROD',  'C', 50, 0 }, ;
      { 'ADRES_ROD2', 'C', 50, 0 }, ;
      { 'MR_ROD',     'C', 50, 0 }, ;
      { 'MR_ROD2',    'C', 50, 0 }, ;
      { 'phone_rod',  'C', 90, 0 }, ;
      { 'phone_rod2', 'C', 90, 0 }, ;
      { 'travma',     'C', 90, 0 }, ;
      { 'vid_opl',    'C', 60, 0 }, ;
      { 'vid_opl1',   'C', 60, 0 }, ;
      { 'vid_opl2',   'C', 255, 0 }, ;
      { 'pp_status',  'C', 60, 0 }, ;
      { 'pp_kategor', 'C', 60, 0 }, ;
      { 'vrach',      'C', 60, 0 }, ;
      { 'komu1',      'N',  1, 0 }, ;
      { 'komu',       'C', 90, 0 }, ;
      { 'pr_date',    'D',  8, 0 }, ;
      { 'pr_mo',      'C',  6, 0 }, ;
      { 'pr_nam_mo',  'C', 150, 0 }, ;
      { 'pr_kod_tf',  'C', 10, 0 }, ;  // заплатка для шаблона карты
    { 'name_org',   'C', 255, 0 }, ;
      { 'adres_org',  'C', 255, 0 }, ;
      { 'ogrn',       'C', 15, 0 }, ;
      { 'okpo',       'C', 12, 0 }, ;
      { 'date_sys',   'C', 10, 0 }, ;
      { 'd_sys',      'C',  2, 0 }, ;
      { 'm_sys',      'C',  2, 0 }, ;
      { 'y_sys',      'C',  4, 0 }, ;
      { 'nomer_kart', 'C', 25, 0 }, ;
      { 'fam',        'C', 50, 0 }, ;
      { 'ima',        'C', 50, 0 }, ;
      { 'ots',        'C', 50, 0 }, ;
      { 'd_dr',       'C',  2, 0 }, ;
      { 'm_dr',       'C',  2, 0 }, ;
      { 'y_dr',       'C',  4, 0 }, ;
      { 'subekt',     'C', 50, 0 }, ;
      { 'rajon',      'C', 50, 0 }, ;
      { 'gorod',      'C', 50, 0 }, ;
      { 'nas_p',      'C', 50, 0 }, ;
      { 'subektp',    'C', 50, 0 }, ;
      { 'rajonp',     'C', 50, 0 }, ;
      { 'gorodp',     'C', 50, 0 }, ;
      { 'nas_pp',     'C', 50, 0 }, ;
      { 'adresL',     'C', 200, 0 }, ; // {'phone',      'C', 15, 0},;
    { 'phones',     'C', 50, 0 }, ; // {'gorod_selo', 'C', 50, 0},;
    { 'ser_polis',  'C', 10, 0 }, ;
      { 'nom_polis',  'C', 20, 0 }, ;
      { 'smo',        'C', 100, 0 }, ;
      { 'kod_lgot',   'C',  2, 0 }, ;
      { 'name_doc',   'C', 20, 0 }, ;
      { 'ser_doc',    'C', 20, 0 }, ;
      { 'nom_doc',    'C', 20, 0 }, ;
      { 'zanyat',     'C', 255, 0 }, ;
      { 'invalid',    'C', 100, 0 }, ; // пусто  {'mr_dol',     'C', 50, 0},;
    { 'perv_priem', 'C', 50, 0 }, ; // пусто
    { 'registrato', 'C', 50, 0 }, ;
      { 'time_regi',  'C', 50, 0 }, ; // пусто
    { 'adrespL',    'C', 200, 0 }, ;
      { 'platel',     'C', 100, 0 }, ;
      { 'platel1',    'C', 100, 0 }, ;
      { 'bukva',      'C',  1, 0 }, ;
      { 'uchast',     'C',  2, 0 }, ;
      { 'kod_vu',     'C',  5, 0 }, ;
      { 'kod_kart',   'C',  7, 0 }, ;
      { 'strana',     'C', 50, 0 }, ;
      { 'shapka',     'C', 150, 0 }, ;
      { 'mestnost',   'C', 100, 0 };
      } )

    //
    Select KART2
    Goto ( kart->( RecNo() ) )
    //
    Use ( fr_data ) New Alias FRD
    Append Blank
    //
    If AllTrim( kart_->strana ) == '643' .or. AllTrim( kart_->strana ) == ''
      frd->strana := 'Российская Федерация'
    Else
      frd->strana := ''
    Endif
    s3 := ''
    //
    frd->name_org := frd->org_name
    s1 := full_date( sys_date )
    frd->date_sys := s1
    frd->d_sys := SubStr( s1, 1, 2 )
    frd->m_sys := SubStr( s1, 4, 2 )
    frd->y_sys := SubStr( s1, 7, 4 )
    mdate_r := full_date( kart->date_r )
    frd->d_dr := SubStr( mdate_r, 1, 2 )
    frd->m_dr := SubStr( mdate_r, 4, 2 )
    frd->y_dr := SubStr( mdate_r, 7, 4 )
    //
    lnomer := l1nomer := lstr( kart->kod )
    muchastok := put_val( kart->uchast, 2 )
    luchast := ''
    If is_uchastok == 1
      If !emptyall( kart->bukva, kart->uchast, kart->kod_vu )
        lnomer := ''
        If !Empty( kart->bukva )
          lnomer += kart->bukva
        Endif
        lnomer += lstr( kart->uchast, 2 )
        If kart->kod_vu > 0
          lnomer += '/' + lstr( kart->kod_vu )
        Endif
        l1nomer := lnomer
      Endif
    Elseif eq_any( is_uchastok, 2, 3 )
      If !emptyall( kart->bukva, kart->uchast )
        luchast := ' [уч-к '
        If !Empty( kart->bukva )
          luchast += kart->bukva
        Endif
        luchast += lstr( kart->uchast, 2 )
        luchast += '] '
      Endif
      If is_uchastok == 3
        luchast += AllTrim( kart2->kod_AK )
      Endif
    Endif
    lnomer := Expand( lnomer ) + luchast
    frd->nomer_kart := lnomer
    arr := retfamimot( 1, .f. )
    frd->fam := arr[ 1 ]
    frd->ima := arr[ 2 ]
    frd->ots := arr[ 3 ]
    arr := ret_okato_array( kart_->okatop )
    frd->subektp := arr[ 1 ]
    frd->rajonp  := arr[ 2 ]
    frd->gorodp  := arr[ 3 ]
    frd->nas_pp  := arr[ 4 ]
    arr := ret_okato_array( kart_->okatog )
    frd->subekt := arr[ 1 ]
    frd->rajon  := arr[ 2 ]
    frd->gorod  := arr[ 3 ]
    frd->nas_p  := arr[ 4 ]
    If f_is_selo()
      s4 := 'городская - 1, ' + sb1 + 'сельская - 2' + sb2
    Else
      s4 := sb1 + 'городская - 1' + sb2 + ', сельская - 2'
    Endif
    frd->gorod_selo := s4
    If Empty( kart->adres )
      s := 'улица' + Space( 30 ) + ' дом' + Space( 5 ) + ' квартира' + Space( 5 )
    Else
      s := PadR( kart->adres, 60 )
    Endif
    frd->adresL := s // +'   тел. '+frt->phones
    If !emptyall( kart_->PHONE_H, kart_->PHONE_M, kart_->PHONE_W )
      s := ''
      If !Empty( kart_->PHONE_M )
        s += 'моб.' + kart_->PHONE_M + ' '
      Endif
      If !Empty( kart_->PHONE_H )
        s += 'дом.' + kart_->PHONE_H + ' '
      Endif
      If !Empty( kart_->PHONE_W )
        s += 'раб.' + kart_->PHONE_W
      Endif
      // frd->phone := s
      frd->phones := s
    Endif
    If f_is_selo()
      frd->gorod_selo := 'городская - 1, ' + sb1 + 'сельская - 2' + sb2
    Else
      frd->gorod_selo := sb1 + 'городская - 1' + sb2 + ', сельская - 2'
    Endif
    frd->ser_polis := kart_->SPOLIS
    frd->nom_polis := kart_->NPOLIS
    frd->polis := LTrim( AllTrim( kart_->SPOLIS ) + ' ' + kart_->NPOLIS )
    If AllTrim( kart_->SMO ) == '34'
      If Empty( s := ret_inogsmo_name( 1 ) )
        s := 'иногородние'
      Endif
      frd->smo := '(' + AllTrim( kart_->KVARTAL_D ) + ') ' + s
    Elseif Left( kart_->SMO, 2 ) == '34'
//      frd->smo := AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( kart_->smo ) ) ) )
      frd->smo := AllTrim( inieditspr( A__MENUVERT, smo_volgograd(), Int( Val( kart_->smo ) ) ) )
    Elseif !Empty( kart_->SMO )
      frd->smo := '(' + AllTrim( kart_->KVARTAL_D ) + ') ' + init_ismo( kart_->SMO )
    Endif
    If ( i := AScan( stm_kategor, {| x| x[ 2 ] == kart_->kategor } ) ) > 0 ;
        .and. Between( stm_kategor[ i, 3 ], 1, 9 )
      frd->kod_lgot := lstr( stm_kategor[ i, 3 ] )
    Endif

    frd->name_doc := get_name_vid_ud( kart_->vid_ud )
    frd->ser_doc := kart_->ser_ud
    frd->nom_doc := kart_->nom_ud
    s := 'Занятость: ' + iif( kart->rab_nerab == 0, sb1, '' ) + 'работает - 1' + iif( kart->rab_nerab == 0, sb2, '' ) + ',    ' + ;
      'проходит военную службу и приравненную к ней службу - 2;    ' + ;
      iif( kart_->PENSIONER == 1, sb1, '' ) + 'пенсионер(ка) - 3' + iif( kart_->PENSIONER == 1, sb2, '' ) + ',    ' + ;
      iif( kart->rab_nerab == 2, sb1, '' ) + 'студент(ка) - 4' + iif( kart->rab_nerab == 2, sb2, '' ) + ',    ' + ;
      iif( kart->rab_nerab == 1, sb1, '' ) + 'не работает - 5' + iif( kart->rab_nerab == 1, sb2, '' ) + ',    ' + ;
      'прочие - 6'
    frd->zanyat := s
    If emptyall( kart_->okatop, kart_->adresp )
      If Empty( kart->adres )
        s := 'улица' + Space( 30 ) + ' дом' + Space( 5 ) + ' квартира' + Space( 5 )
      Else
        s := PadR( kart->adres, 60 )
      Endif
    Else
      s := PadR( kart_->adresp, 60 )
    Endif
    frd->adrespL := s // +'   тел. '+frd->phones
    Private m1company := 0, mcompany := ' ', mm_company := {}
    Private m1KOMU := 0, MKOMU, M1STR_CRB := 0
    If kart->MI_GIT == 9
      m1KOMU    := kart->KOMU
      M1STR_CRB := kart->STR_CRB
    Endif
    mkomu := inieditspr( A__MENUVERT, mm_komu, m1komu )
    If m1komu == 0
      m1company := Int( Val( kart_->SMO ) )
    Elseif eq_any( m1komu, 1, 3 )
      m1company := m1str_crb
    Endif
    If m1komu == 0 // ОМС
//      mm_company := AClone( glob_arr_smo )
      mm_company := AClone( smo_volgograd() )
    Elseif m1komu == 1 // Прочие компании
      r_use( dir_server() + 'str_komp' )
      Index On Upper( name ) To tmp_comp For !Between( tfoms, 44, 47 )
      dbEval( {|| AAdd( mm_company, { AllTrim( name ), kod } ) } )
      str_komp->( dbCloseArea() )
    Elseif m1komu == 3 // Комитеты/МО
      r_use( dir_server() + 'komitet' )
      Index On Upper( name ) To tmp_comp
      dbEval( {|| AAdd( mm_company, { AllTrim( name ), kod } ) } )
      komitet->( dbCloseArea() )
    Endif
    mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
    frd->platel  := mkomu
    If m1komu == 0  // ОМС
      frd->platel1 := frd->smo
    Else
      frd->platel1 := mcompany
    Endif
    frd->bukva    := kart->bukva
    frd->kod_kart := lstr( kart->kod )
    If kart->uchast > 0
      frd->uchast := lstr( kart->uchast )
    Endif
    If kart->kod_vu > 0
      frd->kod_vu := lstr( kart->kod_vu )
    Endif
    // конец ДОБАВКИ
    //
    frd->UCH_DOC := hu->UCH_DOC
    frd->kod_k := hu->kod_k
    frd->n_data := hu->n_data
    frd->n_time := hu->n_time
    frd->g_data := hu->g_data
    frd->g_time := hu->g_time
    If !Empty( hu->travma )
      frd->travma := inieditspr( A__MENUVERT, mmpp_travma, hu->travma )
    Endif
    frd->vid_opl    := inieditspr( 2, menu_vid_opl, hu->vid_opl )
    frd->vid_opl1    := inieditspr( 2, menu_vid_opl, hu->vid_opl )
    If hu->vid_opl == 1
      frd->vid_opl1 := 'обязательного'
      ss := sb1 + 'обязательное   медицинское   страхование - 1' + sb2 + ' ,   средства    бюджета  (всех    уровней) - 2, '
      ss += 'платные медицинские услуги - 3, в том числе добровольное медицинское страхование  - 4, другое - 5'
    Elseif hu->vid_opl == 2
      ss := 'обязательное   медицинское   страхование - 1' + sb1 + ' ,   средства    бюджета  (всех    уровней) - 2,' + sb2 + ' '
      ss += 'платные медицинские услуги - 3, в том числе добровольное медицинское страхование  - 4, другое - 5'
    Elseif hu->vid_opl == 3
      ss := 'обязательное   медицинское   страхование - 1,   средства    бюджета  (всех    уровней) - 2, '
      ss += sb1 + 'платные медицинские услуги - 3' + sb2 + ', в том числе добровольное медицинское страхование  - 4, другое - 5'
    Elseif hu->vid_opl == 4
      frd->vid_opl1 := 'добровольного'
      ss := 'обязательное   медицинское   страхование - 1,   средства    бюджета  (всех    уровней) - 2, '
      ss += 'платные медицинские услуги - 3' + sb1 + ', в том числе добровольное медицинское страхование  - 4 ' + sb2 + ', другое - 5'
    Else
      ss := 'обязательное   медицинское   страхование - 1,   средства    бюджета  (всех    уровней) - 2, '
      ss += 'платные медицинские услуги - 3, в том числе добровольное медицинское страхование  - 4 ' + sb1 + ', другое - 5' + sb2 + ' '
    Endif
    frd->vid_opl2 := ss
    frd->pp_status  := inieditspr( 2, mmpp_rab,     hu->rab_nerab )
    frd->pp_kategor := inieditspr( 1, mmpp_kategor, hu->kategor )
    If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
      frd->kem_dost   := inieditspr( 1, mmpp_kem1dost, hu->kem_dost )
    Else
      frd->kem_dost   := inieditspr( 1, mmpp_kem_dost, hu->kem_dost )
    Endif
    frd->sost_op    := inieditspr( 1, menu_sost_op, hu->sost_op )
    frd->reg_lech := hu->reg_lech
    s1 := 'Поступил в '
    Do Case
    Case hu->reg_lech == 1
      frd->regim_lu := 'СТАЦИОНАРНОГО БОЛЬНОГО'
      frd->regim_66 := 'ВЫБЫВШЕГО ИЗ СТАЦИОНАРА КРУГЛОСУТОЧНОГО ПРЕБЫВАНИЯ'
      frd->regim_ib := 'СТАЦИОНАРНОГО БОЛЬНОГО'
      frd->shapka   := 'МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА, ПОЛУЧАЮЩЕГО МЕДИЦИНСКУЮ ПОМОЩЬ В <b>СТАЦИОНАРНЫХ УСЛОВИЯХ</b>, В УСЛОВИЯХ ДНЕВНОГО СТАЦИОНАРА'
      frd->regim_llu :=  '<b>в стационар - 1</b>, в дневной стационар - 2 (указать): '
      s := 'Направлен  в  <b> стационар </b> (дневной  стационар): '
      s1 +=  ' <b> стационар </b> (дневной стационар) '
    Case hu->reg_lech == 2
      frd->regim_lu := 'БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА ПРИ БОЛЬНИЧНОМ УЧРЕЖДЕНИИ'
      frd->regim_66 := 'ВЫБЫВШЕГО ИЗ ДНЕВНОГО СТАЦИОНАРА ПРИ БОЛЬНИЧНОМ УЧРЕЖДЕНИИ'
      frd->regim_ib := 'БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА'
      frd->shapka   := 'МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА, ПОЛУЧАЮЩЕГО МЕДИЦИНСКУЮ ПОМОЩЬ В СТАЦИОНАРНЫХ УСЛОВИЯХ, В УСЛОВИЯХ <b> ДНЕВНОГО СТАЦИОНАРА</b>'
      frd->regim_llu :=  'в стационар - 1, <b>в дневной стационар - 2 </b>(указать): '
      s := 'Направлен  в стационар  <b>(дневной  стационар): </b> '
      s1 +=  ' стационар <b> (дневной стационар) </b> '
    Case hu->reg_lech == 3
      frd->regim_lu := 'БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА ПРИ ПОЛИКЛИНИКЕ'
      frd->regim_66 := 'ВЫБЫВШЕГО ИЗ ДНЕВНОГО СТАЦИОНАРА ПРИ АМБУЛАТОРНО-ПОЛИКЛИНИЧЕСКОМ УЧРЕЖДЕНИИ'
      frd->regim_ib := 'БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА'
      frd->shapka   := 'МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА, ПОЛУЧАЮЩЕГО МЕДИЦИНСКУЮ ПОМОЩЬ В СТАЦИОНАРНЫХ УСЛОВИЯХ, В УСЛОВИЯХ <b> ДНЕВНОГО СТАЦИОНАРА</b>'
      frd->regim_llu :=  'в стационар - 1, <b>в дневной стационар - 2 </b>(указать): '
      s := 'Направлен  в стационар  <b>(дневной  стационар): </b> '
      s1 +=  ' стационар <b> (дневной стационар) </b> '
    Case hu->reg_lech == 4
      frd->regim_lu := 'БОЛЬНОГО СТАЦИОНАРА НА ДОМУ'
      frd->regim_66 := 'ВЫБЫВШЕГО ИЗ СТАЦИОНАРА НА ДОМУ'
      frd->regim_ib := 'БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА'
      frd->shapka   := 'МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА, ПОЛУЧАЮЩЕГО МЕДИЦИНСКУЮ ПОМОЩЬ В СТАЦИОНАРНЫХ УСЛОВИЯХ, В УСЛОВИЯХ <b> ДНЕВНОГО СТАЦИОНАРА</b>'
      frd->regim_llu :=  'в стационар - 1, <b>в дневной стационар - 2 </b>(указать): '
      s := 'Направлен  в стационар  <b>(дневной  стационар): </b> '
      s1 +=  ' стационар <b> (дневной стационар) </b> '
    Endcase
    //
    frd->gospit0   := inieditspr( A__MENUVERT, menu0gospit, hu->gospit0 )
    If hu->IS_GOSPIT == 1 // не госпитализирован 02.05.18
      frd->gospit0 := ''
    Endif
    //
    // <b> поликлиникой  - 1 </b>, выездной бригадой   скорой   медицинской   помощи  -  2,  полицией  -  3,  обратился самостоятельно - 4, другое - 5 (указать) ____________________________________________
    s1 := s1 + ' для оказания медицинской  помощи в текущем году: по поводу  основного   заболевания, указанного в диагнозе при поступлении:'
    frd->regim_l3u := s1 + ' <b> ' + AllTrim( frd->gospit0 ) + ' </b> '
    frd->regim_l2u := s + ' <b> ' + inieditspr( 1, mmpp_kem1dost, hu->kem_dost ) + '</b> '
    // не госпитализирован и оказана амбулаторная помощь в приёмном покое
    If hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
      frd->regim_lu := 'АМБУЛАТОРНОГО БОЛЬНОГО'
    Endif
    frd->vidpolis := ' (' + AllTrim( inieditspr( A__MENUVERT, mm_vid_polis, kart_->vpolis ) ) + ')'
    frd->mesto_rog := AllTrim( kart_->mesto_r )
    frd->gorod_selo := inieditspr( A__MENUVERT, mm_gorod_selo, kart_->gorod_selo )
    frd->fio := Upper( kart->fio )
    frd->fio1 := fam_i_o( kart->fio )
    frd->polis := make_polis( kart_->spolis, kart_->npolis )
    frd->beg_polis := full_date( c4tod( kart_->beg_polis ) )
    frd->srok_polis := full_date( c4tod( kart->srok_polis ) )
    If !Empty( kart->SNILS )
//      frd->snils := Transform( kart->SNILS, picture_pf )
      frd->snils := Transform_SNILS( kart->SNILS )
    Endif
    frd->pol := kart->pol
    If frd->pol == 'Ж'
      frd->poll := 'ЖЕНСКИЙ -  2'
    Else
      frd->poll := 'МУЖСКОЙ - 1'
    Endif
    frd->date_r := kart->date_r
    frd->count_ymd := count_ymd( kart->date_r, hu->N_DATA )
    frd->HEIGHT := iif( Empty( kart_->HEIGHT ), '_______', lstr( kart_->HEIGHT ) + ' см' )
    frd->WEIGHT := iif( Empty( kart_->WEIGHT ), '_______', lstr( kart_->WEIGHT ) + ' кг' )
    If Empty( stm_kategor2 )
      frd->kategor := inieditspr( A__MENUVERT, stm_kategor, kart_->kategor )
    Else
      frd->kategor := inieditspr( A__MENUVERT, stm_kategor2, kart_->kategor2 )
    Endif
    frd->vid_ud := get_name_vid_ud( kart_->vid_ud )
    frd->ser := AllTrim( kart_->ser_ud )
    frd->nom := AllTrim( kart_->nom_ud )
    frd->kogdavyd := kart_->kogdavyd
    r_use( dir_server() + 's_kemvyd',, 'KVYD' )
    dbGoto( kart_->kemvyd )
    frd->kemvyd  :=  AllTrim( kvyd->name )
    kvyd->( dbCloseArea() )
    Select FRD
    frd->adres := iif( emptyall( kart_->okatog, kart->adres ), '', ;
      ret_okato_ulica( kart->adres, kart_->okatog ) )
    frd->adresp := iif( emptyall( kart_->okatop, kart_->adresp ), '', ;
      ret_okato_ulica( kart_->adresp, kart_->okatop ) )
    frd->mr_dol := kart->mr_dol
    s := ''
    If !emptyall( kart_->PHONE_H, kart_->PHONE_M, kart_->PHONE_W )
      If !Empty( kart_->PHONE_H )
        s += AllTrim( kart_->PHONE_H ) + '(дом.) '
      Endif
      If !Empty( kart_->PHONE_M )
        s += AllTrim( kart_->PHONE_M ) + '(моб.) '
      Endif
      If !Empty( kart_->PHONE_W )
        s += AllTrim( kart_->PHONE_W ) + '(раб.) '
      Endif
    Endif
    frd->phone := s
    frd->rab_nerab := Upper( inieditspr( A__MENUVERT, menu_rab, kart->rab_nerab ) )
    frd->vzros_reb := Upper( inieditspr( A__MENUVERT, menu_vzros, kart->vzros_reb ) )
    frd->mi_git    := okato_mi_git( kart_->okatog )
    frd->rajon_git := okato_rajon( kart_->okatog )
    frd->pr_date   := kart2->date_pr
    frd->pr_mo     := kart2->mo_pr
    frd->pr_kod_tf := lstr( kart2->kod_tf )
    // if glob_mo[_MO_IS_UCH]
    mmo_pr := ''
    If Left( kart2->PC2, 1 ) == '1'
      mmo_pr := 'По информации из ТФОМС пациент У_М_Е_Р'
    Elseif kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
      mmo_pr := 'Прикреплён '
      If !Empty( kart2->pc4 )
        mmo_pr += 'с ' + AllTrim( kart2->pc4 ) + ' '
      Elseif !Empty( kart2->DATE_PR )
        mmo_pr += 'с ' + date_8( kart2->DATE_PR ) + ' '
      Endif
      mmo_pr += 'к нашей МО'
    Else
      s := AllTrim( inieditspr( A__MENUVERT, glob_arr_mo(), kart2->mo_pr ) )
      If Empty( s )
        mmo_pr := 'Прикрепление --- неизвестно ---'
      Else
        If !Empty( kart2->pc4 )
          mmo_pr += 'с ' + AllTrim( kart2->pc4 ) + ' '
        Elseif !Empty( kart2->DATE_PR )
          mmo_pr += 'с ' + date_8( kart2->DATE_PR ) + ' '
        Endif
        mmo_pr += 'прикреплён к ' + s
      Endif
    Endif
    // endif
    frd->pr_nam_mo := mmo_pr
    If hu->NOVOR > 0
      frd->novor := '(Новорожденный: ' + lstr( hu->NOVOR ) + '-й ребёнок, д.р. ' + ;
        date_8( hu->DATE_R2 ) + ', пол ' + hu->POL2 + ')'
    Endif
    frd->gospit0   := inieditspr( A__MENUVERT, menu0gospit, hu->gospit0 )
    frd->gospit1   := inieditspr( A__MENUVERT, mm_ekst, hu->GOSPIT1 )
    If hu->IS_GOSPIT == 1 // не госпитализирован 02.05.18
      frd->gospit0 := ''
      frd->gospit1 := 'НЕТ'
    Endif
    //
    frd->gospit2   := inieditspr( A__MENUVERT, menu2gospit, hu->gospit2 )
    frd->name_uch := inieditspr( 6, dir_server() + 'mo_uch', hu->LPU )
    frd->name_otd := inieditspr( 6, dir_server() + 'mo_otd', hu->OTD )
    // 02.05.18
    // frd->dost_skor := iif(hu->GOSPIT1==1 .and. hu->KEM_DOST==1, 'ДА', 'НЕТ')
    If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
      frd->dost_skor := iif( hu->KEM_DOST == 2, 'ДА', 'НЕТ' )
    Else
      frd->dost_skor := iif( hu->KEM_DOST == 1, 'ДА', 'НЕТ' )
    Endif
    If !Empty( hu->kem_napr )
      arr := ret_mo( hu->kem_napr )
      frd->kem_napr := AllTrim( arr[ _MO_SHORT_NAME ] ) + ' (' + arr[ _MO_KOD_TFOMS ] + ' / ' + arr[ _MO_KOD_FFOMS ] + ')'
    Endif
    If hu->kod_vr > 0
      r_use( dir_server() + 'mo_pers',, 'PERSO' )
      dbGoto( hu->kod_vr )
      frd->vrach := flstr( perso->tab_nom ) + ' (' + fam_i_o( perso->fio ) + ')'
    Endif
    r_use( dir_server() + 'organiz',, 'ORG' )
    frd->org_name  := org->name
    frd->adres_org := org->adres
    frd->ogrn      := org->ogrn
    frd->okpo      := org->okpo
    r_use( dir_server() + 'mo_ppdia', dir_server() + 'mo_ppdia', 'HUS' )
    find ( Str( hu->kod, 7 ) )
    Do While hus->kod == hu->kod .and. !Eof()
      Do Case
      Case hus->tip == 1
        frd->DIAG_NAPR := AllTrim( hus->name ) // диагноз направившего учреждения
      Case hus->tip == 2
        frd->DIAG_PR_P := AllTrim( hus->name ) // диагноз приемного отделения
      Case hus->tip == 3
        frd->POB_D_LEK := AllTrim( hus->name ) // побочное действие лекарств
      Endcase
      Skip
    Enddo
    r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
    find ( Str( hu->kod_k, 7 ) )
    Do While hu->kod_k == kpr->kod .and. !Eof()
      If kpr->nn == 1
        ++frd->kol_pred
        frd->DATE_ROD := kpr->DATE_R
        frd->FIO_ROD := AllTrim( kpr->fio )
        If kpr->STATUS > 0
          frd->FIO_ROD := AllTrim( kpr->fio ) + ' (' + AllTrim( inieditspr( A__MENUVERT, menu_predst, kpr->STATUS ) ) + ')'
        Endif
        If kpr->is_uhod == 1
          frd->uhod_rod := 'ГОСПИТАЛИЗИРОВАН (' + iif( kpr->is_food == 1, 'с питанием', 'без питания' ) + ')'
        Endif
        frd->ADRES_ROD := kpr->ADRES
        frd->MR_ROD := kpr->MR_DOL
        s := ''
        If !Empty( kpr->PHONE )
          s += 'Телефон: ' + AllTrim( kpr->PHONE ) + Space( 3 )
        Endif
        If !Empty( kpr->PASPORT )
          s += 'Паспорт: ' + AllTrim( kpr->PASPORT ) + Space( 3 )
        Endif
        If !Empty( kpr->POLIS )
          s += 'Полис: ' + AllTrim( kpr->POLIS ) + Space( 3 )
        Endif
        frd->phone_rod := s
      Elseif kpr->nn == 2
        ++frd->kol_pred
        frd->DATE_ROD2 := kpr->DATE_R
        frd->FIO_ROD2 := AllTrim( kpr->fio )
        If kpr->STATUS > 0
          frd->FIO_ROD2 := AllTrim( kpr->fio ) + ' (' + AllTrim( inieditspr( A__MENUVERT, menu_predst, kpr->STATUS ) ) + ')'
        Endif
        frd->ADRES_ROD2 := kpr->ADRES
        frd->MR_ROD2 := kpr->MR_DOL
        s := ''
        If !Empty( kpr->PHONE )
          s += 'Телефон: ' + AllTrim( kpr->PHONE ) + Space( 3 )
        Endif
        If !Empty( kpr->PASPORT )
          s += 'Паспорт: ' + AllTrim( kpr->PASPORT ) + Space( 3 )
        Endif
        If !Empty( kpr->POLIS )
          s += 'Полис: ' + AllTrim( kpr->POLIS ) + Space( 3 )
        Endif
        frd->phone_rod2 := s
      Endif
      Skip
    Enddo
    Private m1komu := hu->komu, mkomu := ''
    If m1komu == 0
      mkomu := 'СМО - '
      If AllTrim( kart_->SMO ) == '34'
        s := ret_inogsmo_name( 1 )
        mkomu += iif( Empty( s ), 'ТФОМС (иногородние)', s )
        frd->mest_inog := 'Регион финансирования: ' + inieditspr( A__MENUVERT, glob_array_srf(), kart_->KVARTAL_D ) // ОКАТО субъекта РФ территории страхования
        frd->mestnost := s4 + ', область 3,' + sb1 + ' иногородние -4,' + sb2 + 'иностранцы -5'
      Elseif Left( kart_->SMO, 2 ) == '34'
//        mkomu += AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( kart_->smo ) ) ) )
        mkomu += AllTrim( inieditspr( A__MENUVERT, smo_volgograd(), Int( Val( kart_->smo ) ) ) )
        // frd->mest_inog := 'Регион финансирования: '+'Волгоградская область'
        frd->mestnost := s4 + ', область 3, иногородние -4, иностранцы -5'
      Elseif !Empty( kart_->SMO )
        mkomu += init_ismo( kart_->SMO )
        frd->mest_inog := 'Регион финансирования: ' + inieditspr( A__MENUVERT, glob_array_srf(), kart_->KVARTAL_D ) // ОКАТО субъекта РФ территории страхования
        frd->mestnost := s4 + ', область 3,' + sb1 + ' иногородние -4,' + sb2 + 'иностранцы -5'
      Endif
    Else
      mkomu := ''
      If m1komu == 1
        mkomu := 'пр.компания - '
      Elseif m1komu == 3
        mkomu := 'комитет/МО - '
      Endif
      mkomu += f4_view_list_schet( m1komu, '', hu->str_crb )
    Endif
    frd->komu := mkomu
    frd->komu1 := m1komu
    //
    fill_fr_ist_bol()
    //
    sExt := iif( memPPdos_fast == 0, '.shb', '.fr3' )
    arr := {}
    Do Case
    Case nKey == K_F6
      arr := { pp_FILE_6 }
    Case nKey == K_F7
      arr := { pp_FILE_7 }
    Case nKey == K_F8
      If hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
        func_error( 4, 'Пациент не госпитализирован. Нет смысла печатать историю болезни.' )
      Else
        arr := { pp_FILE_8 }
      Endif
    Case nKey == K_F9
      If hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
        func_error( 4, 'Пациент не госпитализирован. Нет смысла печатать стат.карту.' )
      Else
        arr := { pp_FILE_9 }
      Endif
    Case nKey == K_F5
      arr := { pp_FILE_XX }
    Case nKey == K_F10
      If hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
        arr := { pp_FILE_7 }
      Else
        arr := { pp_FILE_7, pp_FILE_8, pp_FILE_9 }
      Endif
      If !Empty( pp_FILE_6 )
        ins_array( arr, 1, pp_FILE_6 )
      Endif
    Case nKey == K_F12
      // frd->pol := iif(kart->pol=='М',sb1+'муж. - 1'+sb2+', жен. - 2','муж. - 1, '+sb1+'жен. - 2'+sb2)
      If !Empty( pp_FILE_12 )
        ins_array( arr, 1, pp_FILE_12 )
      Endif
      // теперь меняем файл данных для сохранения шаблона.
    Endcase
    //
    If ( k := Len( arr ) ) == 0
      //
    Elseif k == 1
      If nKey == K_F5
        Private file_sh
        If !Empty( file_sh := menu_shablon( 3, 3, dir_exe() + '*.' + AllTrim( arr[ 1 ] ), color8, .f. ) )
          print_shablon( file_sh )
        Endif
      Else
        If hb_FileExists( dir_exe() + arr[ 1 ] + sExt )
          If memPPdos_fast == 0
            print_shablon( arr[ 1 ] + sExt )
          Else
            Close databases
            Copy File ( cur_dir() + fr_data + '.dbf' ) to ( cur_dir() + fr_titl + '.dbf' )
            call_fr( arr[ 1 ] )
          Endif
        Else
          func_error( 4, 'Не обнаружен файл ' + Upper( arr[ 1 ] + sExt ) )
        Endif
      Endif
    Elseif f_esc_enter( 'печати ' + lstr( k ) + '-х документов' )
      If memPPdos_fast == 0 .and. !_upr_windows() // печать не через Windows
        For i := 1 To Len( arr )
          If !hb_FileExists( dir_exe() + arr[ i ] + sExt )
            func_error( 4, 'Не обнаружен файл ' + Upper( arr[ i ] + sExt ) )
            Loop
          Endif
          If i > 1
            Close databases
            Use ( fr_data ) New Alias FRD
          Endif
          ap := print_shablon( arr[ i ],,, .f. )  // без отображения
          // для справки: ap := {width,height,regim,_out_file}
          If ValType( ap ) == 'A'
            ft_use( ap[ 4 ] )
            pr_view( K_F9, ap[ 3 ],,,, .f. )  // без запроса на печать
            ft_use()
          Endif
        Next
      Else // через FastReport
        sExt := '.fr3'
        For i := Len( arr ) To 1 Step -1
          If !hb_FileExists( dir_exe() + arr[ i ] + sExt )
            func_error( 4, 'Не обнаружен файл ' + Upper( arr[ i ] + sExt ) )
            del_array( arr, i )
          Endif
        Next
        If Len( arr ) > 0
          Close databases
          call_fr( arr )  // несколько отчётов через FastReport
        Endif
      Endif
    Endif
    Close databases
    Eval( blk_open )
    Goto ( rec1 )
    Return -1
  Endif
  If nkey != K_F2
    Return -1
  Endif
  buf1 := SaveScreen( 13, 4, 19, 77 )
  Private pdate, m1date, mdate, tmp2, tmp3
  Do While .t.
    m1date := 0 ; mdate := Space( 10 )
    tmp2 := PadR( stmp2, 10 )
    tmp3 := PadR( stmp3, 40 )
    box_shadow( 13, 14, 17, 67, cDataPgDn, 'Поиск по ключу', cDataCSay )
    Keyboard Chr( K_TAB ) + Chr( K_TAB )  // встать на ФИО
    status_key( '^<Esc>^ - отказ;  ^<PgDn>^ - поиск;  ^<F1>^ - помощь' )
    SetColor( cDataCGet )
    @ 14, 16 Say 'Дата поступления' Get mdate ;
      reader {| x| menu_reader( x, ;
      { {| k, r, c| k := year_month( r + 1, c ), ;
      if( k == nil, nil, ( pdate := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION,,, .f. ) }
    @ 15, 16 Say 'Номер медицинской карты' Get tmp2 Picture '@K@!'
    @ 16, 16 Say 'Шаблон ФИО' Get tmp3 Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. emptyall( mdate, tmp2, tmp3 )
      Exit
    Endif
    mywait()
    stmp2 := tmp2
    stmp3 := tmp3 := AllTrim( tmp3 )
    Private is_date  := ( m1date > 0 )
    Private is_nomer := !Empty( tmp2 )
    Private is_fio   := !Empty( tmp3 )
    If is_fio .and. Right( tmp3, 1 ) != '*'
      tmp3 += '*'
    Endif
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, ;
      k2 := 21, tmp3_ := Upper( tmp3 )
    i := 0
    If is_fio  // поиск по ФИО
      Go Top
      Do While !Eof()
        f1f2_v_human( @i )
        Skip
      Enddo
    Elseif is_date  // поиск по дате начала лечения
      dbSeek( DToS( pdate[ 5 ] ), .t. )
      Do While hu->n_data <= pdate[ 6 ] .and. !Eof()
        f1f2_v_human( @i )
        Skip
      Enddo
    Elseif is_nomer  // поиск по номеру истории болезни
      Set Index to ( ( dir_server() + 'mo_pp_i' ) )
      k := Year( sys_date )
      For j := k - 10 To k  // просмотр на 10 лет назад
        find ( Str( j, 4 ) + tmp2 )
        Do While Year( n_data ) == j .and. hu->uch_doc == tmp2
          f1f2_v_human( @i )
          Skip
        Enddo
      Next
      Set Index to ( ( dir_server() + 'mo_pp_d' ) )
    Endif
    If ( t_len := Len( tmp_kod ) ) = 0
      stat_msg( 'Не найдено ни одной записи, удовлетворяющей данному шаблону!' )
      mybell( 2, ERR )
      RestScreen( 13, 4, 19, 77, buf1 )
      Loop
    Elseif t_len == 1
      rec1 := glob_perso_pp := tmp_kod[ 1 ]
      ret := 0
    Else
      box_shadow( mr1, 2, 22, 77 )
      SetColor( col_tit_popup )
      skey := mdate
      If !Empty( tmp2 )
        skey += iif( Empty( skey ), '', ' / ' ) + AllTrim( tmp2 )
      Endif
      If !Empty( tmp3 )
        skey += iif( Empty( skey ), '', ' / ' ) + tmp3
      Endif
      @ k1 - 2, 15 Say 'Ключ: ' + AllTrim( skey )
      SetColor( color0 )
      If k1 + t_len + 2 < MaxRow() -3
        k2 := k1 + t_len + 2
      Endif
      @ k1, 3 Say Center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
      i := AScan( tmp_kod, glob_perso_pp )
      status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
      If ( i := Popup( k1 + 1, 7, k2, 72, tmp_mas, i, color0 ) ) > 0
        rec1 := glob_perso_pp := tmp_kod[ i ]
        ret := 0
      Endif
    Endif
    Exit
  Enddo
  oBrow:gotop()
  Goto rec1
  RestScreen( buf )
  Return ret

//
Static Function f1f2_v_human( i )

  Local fl := .t.

  If fl .and. is_date
    fl := Between( hu->n_data, pdate[ 5 ], pdate[ 6 ] )
  Endif
  If fl .and. is_nomer
    fl := ( tmp2 == hu->uch_doc )
  Endif
  If fl .and. is_fio
    fl := Like( tmp3_, Upper( kart->fio ) )
  Endif
  If fl .and. ++i < 4000
    AAdd( tmp_mas, full_date( hu->n_data ) + ' ' + hu->n_time + ' ' + hu->uch_doc + ' ' + kart->fio )
    AAdd( tmp_kod, hu->kod )
  Endif
  Return Nil

//
Static Function fill_fr_ist_bol()

  Local sh := 83, i, k, arr[ 2 ]
  Private sb1 := '<b>', sb2 := '</b>'

  dbCreate( fr_data + '9', { ;
    { 'text1', 'C', 130, 0 };
    } )
  Use ( fr_data + '9' ) New Alias FRD1
  //
  If !Empty( frd->adresp )
    f1_fill_fr_ist_bol( 'Постоянное место жительства: ', frd->adresp, sh )
  Endif
  If !Empty( frd->phone )
    Append Blank
    frd1->text1 := 'Телефон: ' + sb1 + AllTrim( frd->phone ) + sb1
  Endif
  If frd->kol_pred > 0
    Append Blank
    Append Blank
    frd1->text1 := 'Сведения о представителях:'
    Append Blank
    frd1->text1 := 'Ф.И.О. ' + sb1 + AllTrim( frd->FIO_ROD ) + sb2 + Space( 20 ) + 'Дата р.: ' + sb1 + full_date( frd->DATE_ROD ) + sb2
    If !Empty( frd->uhod_rod )
      Append Blank
      frd1->text1 := Space( 12 ) + sb1 + AllTrim( frd->uhod_rod ) + sb2
    Endif
    If !Empty( frd->ADRES_ROD )
      Append Blank
      frd1->text1 := Space( 12 ) + 'Адрес: ' + sb1 + AllTrim( frd->ADRES_ROD ) + sb2
    Endif
    If !Empty( frd->MR_ROD )
      Append Blank
      frd1->text1 := Space( 12 ) + 'Место работы: ' + sb1 + AllTrim( frd->MR_ROD ) + sb2
    Endif
    If !Empty( frd->phone_rod )
      Append Blank
      frd1->text1 := Space( 12 ) + sb1 + AllTrim( frd->phone_rod ) + sb2
    Endif
    If frd->kol_pred > 1
      Append Blank
      frd1->text1 := 'Ф.И.О. ' + sb1 + AllTrim( frd->FIO_ROD2, 50 ) + sb2 + Space( 20 ) + 'Дата р.: ' + sb1 + full_date( frd->DATE_ROD2 ) + sb2
      If !Empty( frd->ADRES_ROD2 )
        Append Blank
        frd1->text1 := Space( 12 ) + 'Адрес: ' + sb1 + AllTrim( frd->ADRES_ROD2 ) + sb2
      Endif
      If !Empty( frd->MR_ROD2 )
        Append Blank
        frd1->text1 := Space( 12 ) + 'Место работы: ' + sb1 + AllTrim( frd->MR_ROD2 ) + sb2
      Endif
      If !Empty( frd->phone_rod2 )
        Append Blank
        frd1->text1 := Space( 12 ) + sb1 + AllTrim( frd->phone_rod2 ) + sb2
      Endif
    Endif
    Append Blank
  Endif
  Return Nil

//
Static Function f1_fill_fr_ist_bol( s1, s2, sh )

  Local i, j, k, arr[ 2 ]

  k := perenos( arr, s1 + AllTrim( s2 ), sh )
  j := Len( s1 )
  Append Blank
  frd1->text1 := Left( arr[ 1 ], j ) + sb1 + SubStr( arr[ 1 ], j + 1 ) + sb2
  If k > 1
    For i := 2 To k
      Append Blank
      frd1->text1 := sb1 + arr[ i ] + sb2
    Next
  Endif
  Return Nil
