// mo_omsid.prg - информация по диспансеризации в ОМС
#include 'inkey.ch'
#include 'fastreph.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static lcount_uch  := 1
//Static mas1pmt := { '~все оказанные случаи', ;
//    'случаи в выставленных ~счетах', ;
//    'случаи в за~регистрированных счетах' }

// 07.11.25
function mas1pmt()

  local arr_mas

  arr_mas := { ;
    '~все оказанные случаи', ;
    'случаи в выставленных ~счетах', ;
    'случаи в за~регистрированных счетах' ;
  }

  return arr_mas

// 12.04.24 Диспансеризация, профилактика и медосмотры
Function dispanserizacia( k )

  Static si1 := 1, si2 := 1, sj := 1, sj1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { ;
      '~Дети-сироты', ;
      '~Взрослое население', ;
      '~Несовершеннолетние', ;
      '~Сводная информация', ;
      '~Репродуктивное здоровье' }
    mas_msg := { ;
      'Информация по диспансеризации детей-сирот', ;
      'Информация по диспансеризации и профилактике взрослого населения', ;
      'Информация по медицинским осмотрам несовершеннолетних', ;
      'Сводные документы по всем видам диспансеризации и профилактики', ;
      'Проведение диспансеризации репродуктивного здоровья' }
    mas_fun := { ;
      'dispanserizacia(11)', ;
      'dispanserizacia(12)', ;
      'dispanserizacia(13)', ;
      'dispanserizacia(14)', ;
      'dispanserizacia(15)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    inf_dds()
  Case k == 12
    inf_dvn()
  Case k == 13
    inf_dnl()
  Case k == 14
    inf_disp()
  Case k == 15
    inf_drz()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 23.01.25 Информация по диспансеризации и профилактике взрослого населения
Function inf_dvn( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 2, si6 := 2, si7 := 2, sj := 1, sj1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { 'Карта учёта №131/~у', ;
      '~Список пациентов', ;
      'Многовариантный ~запрос', ;
      'Своды для ~Облздрава', ;
      'Своды по УД для ~Облздрава', ;
      'Отчётная форма №~131', ;
      'Обмен ~файлами R0... с ТФ' }
    mas_msg := { 'Распечатка карты учёта диспансеризации (профилактических мед.осмотров) №131/у', ;
      'Распечатка списка пациентов, прошедших диспансеризацию/профилактику', ;
      'Многовариантный запрос по диспансеризации/профилактике взрослого населения', ;
      'Распечатка сводов для Волгоградского областного Комитета здравоохранения', ;
      'Распечатка сводов по углубленной диспансеризации для Волгоградского облздрава', ;
      'Сведения о диспансеризации определённых групп взрослого населения', ;
      'Информационное сопровождение при орг-ции прохождения профилактических мероприятий' }
    mas_fun := { 'inf_DVN(11)', ;
      'inf_DVN(12)', ;
      'inf_DVN(13)', ;
      'inf_DVN(14)', ;
      'inf_DVN(17)', ;
      'inf_DVN(15)', ;
      'inf_DVN(16)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f_131_u()
  Case k == 12
    mas_pmt := AClone( mas1pmt() )
    AAdd( mas_pmt, 'случаи, ещё ~не попавшие в счета' )
    If ( j := popup_prompt( T_ROW, T_COL -5, sj, mas_pmt ) ) > 0
      sj := j
      If ( j := popup_prompt( T_ROW, T_COL -5, sj1, ;
          { 'Диспансеризация ~1 этап', ;
          'Направлены на 2 этап - ещё ~не прошли', ;
          'Диспансеризация ~2 этап', ;
          '~Профилактика' } ) ) > 0
        sj1 := j
        f2_inf_dvn( sj, sj1 )
      Endif
    Endif
  Case k == 13
    /*mas_pmt := {'~Лица, подлежащие диспансеризации'}
    mas_msg := {'Запрос лиц, подлежащих диспасеризации, методом многовариантного поиска'}
    mas_fun := {'inf_DVN(31)'}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)*/
    inf_dvn( 31 )
  Case k == 14
    mas_pmt := { '~Сведения о диспансеризации по состоянию на ...', ;
      '~Индикаторы мониторинга диспансеризации взрослых' }
    mas_msg := { 'Приложение к Приказу МЗВО №2066 от 01.08.2013г.', ;
      'Индикаторы мониторинга диспансеризации взрослых' }
    mas_fun := { 'inf_DVN(21)', ;
      'inf_DVN(22)' }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    If ( j := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
      forma_131( j )
    Endif
  Case k == 16
    mas_pmt := { 'План-график (R0~5)', ;
      'Файлы обмена (R0~1)', ;
      '~Файлы обмена (R11)' }
    mas_msg := { 'Создание и просмотр файлов обмена R05...', ;
      'Создание и просмотр файлов обмена R01...', ;
      'Создание и просмотр файлов обмена R11...' }
    mas_fun := { 'inf_DVN(41)', ;
      'inf_DVN(42)', ;
      'inf_DVN(43)' }
    str_sem := 'ИСОМП'
    If g_slock( str_sem )
      fff_init_r01() // открыл
      popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
      g_sunlock( str_sem )
    Else
      func_error( 4, 'В данный момент с этим режимом работает другой пользователь.' )
    Endif
  Case k == 17
    inf_ydvn()
  Case k == 41
    // ne_real()
    // if glob_mo()[_MO_KOD_TFOMS] == '711001' // ЖД-больница
    mas_pmt := { '~Создание плана-графика', ;
      '~Просмотр файлов обмена' }
    mas_msg := { 'Создание файла обмена R05... с планом-графиком по месяцам', ;
      'Просмотр файлов обмена R05... и результатов работы с ними' }
    mas_fun := { 'inf_DVN(51)', ;
      'inf_DVN(52)' }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
    // endif
  Case k == 42
    // ne_real()
    // if glob_mo()[_MO_KOD_TFOMS] == '711001' // ЖД-больница
    mas_pmt := { '~Создание файлов обмена', ;
      '~Просмотр файлов обмена' }
    mas_msg := { 'Создание файлов обмена R01... по всем месяцам', ;
      'Просмотр файлов обмена R01... и результатов работы с ними' }
    mas_fun := { 'inf_DVN(61)', ;
      'inf_DVN(62)' }
    If need_delete_reestr_r01()
      AAdd( mas_pmt, '~Аннулирование пакета' )
      AAdd( mas_msg, 'Аннулирование недописанного пакета файлов R01' )
      AAdd( mas_fun, 'delete_reestr_R01()' )
    Endif
    // set key K_CTRL_F10 to delete_month_R01()
    popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, mas_msg, mas_fun )
    // set key K_CTRL_F10 to
    // endif
  Case k == 21
    If ( j := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
      f21_inf_dvn( j )
    Endif
  Case k == 22
    f22_inf_dvn( j )
  Case k == 31
    mnog_poisk_dvn1()
  Case k == 51
    f_create_r05()
  Case k == 52
    f_view_r05()
  Case k == 61
    f_create_r01()
  Case k == 62
    f_view_r01()
  Case k == 43
//    If glob_mo()[ _MO_KOD_TFOMS ] == '711001' // ЖД-больница
      mas_pmt := { '~Создание файлов обмена', ;
        '~Просмотр файлов обмена' }
      mas_msg := { 'Создание файлов обмена R11... за конкретный месяц', ;
        'Просмотр файлов обмена R11... и результатов работы с ними' }
      mas_fun := { 'inf_DVN(71)', ;
        'inf_DVN(72)' }
      If need_delete_reestr_r01()
        AAdd( mas_pmt, '~Аннулирование пакета' )
        AAdd( mas_msg, 'Аннулирование недописанного пакета R11' )
        AAdd( mas_fun, 'delete_reestr_R11()' )
      Endif
      AAdd( mas_pmt, '~Повторный подбор пациентов' )
      AAdd( mas_msg, 'Повторный подбор пациентов' )
      AAdd( mas_fun, 'find_new_R00()' )
      AAdd( mas_pmt, 'П~одбор "НЕ НАШИХ" пациентов' )
      AAdd( mas_msg, 'Подбор пациентов, прикрепленных к другим МО или БЕЗ прикрепления' )
      AAdd( mas_fun, 'find_new_R000()' )

      // set key K_CTRL_F10 to delete_month_R11()
      popup_prompt( T_ROW, T_COL - 5, si7, mas_pmt, mas_msg, mas_fun )
      // set key K_CTRL_F10 to
//    Endif
  Case k == 71
    f_create_r11()
  Case k == 72
    f_view_r01( _XML_FILE_R11 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Elseif Between( k, 61, 69 )
      si6 := j
    Elseif Between( k, 71, 79 )
      si7 := j
    Endif
  Endif

  Return Nil

// 15.08.19
Function f0_inf_dvn( arr_m, is_schet, is_reg, is_1_2 )

  Local fl := .t., j := 0, n, buf := save_maxrow()

  Default is_schet To .t., is_reg To .f., is_1_2 To .f.
  If !del_dbf_file( cur_dir() + 'tmp' + sdbf() )
    Return .f.
  Endif
  mywait()
  dbCreate( cur_dir() + 'tmp', { { 'kod_k', 'N', 7, 0 }, ;
    { 'kod1h', 'N', 7, 0 }, ;
    { 'date1', 'D', 8, 0 }, ;
    { 'kod2h', 'N', 7, 0 }, ;
    { 'date2', 'D', 8, 0 }, ;
    { 'kod3h', 'N', 7, 0 }, ;
    { 'date3', 'D', 8, 0 }, ;
    { 'kod4h', 'N', 7, 0 }, ;
    { 'date4', 'D', 8, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp' )
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  n := iif( is_1_2, 204, 203 )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + 'tmp_h' ) ;
    For Between( ishod, 201, n ) .and. human->cena_1 > 0 .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := f_is_uch( st_a_uch, human->lpu )
    If fl .and. is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      find ( Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp->kod_k := human->kod_k
      Endif
      Do Case
      Case human->ishod == 201
        If ( Empty( tmp->date1 ) .or. human->k_data > tmp->date1 )
          tmp->kod1h := human->kod
          tmp->date1 := human->k_data
        Endif
      Case human->ishod == 202
        If ( Empty( tmp->date2 ) .or. human->k_data > tmp->date2 )
          tmp->kod2h := human->kod
          tmp->date2 := human->k_data
        Endif
      Case human->ishod == 203
        If ( Empty( tmp->date3 ) .or. human->k_data > tmp->date3 )
          tmp->kod3h := human->kod
          tmp->date3 := human->k_data
        Endif
      Case human->ishod == 204
        tmp->kod4h := human->kod
        tmp->date4 := human->k_data
      Endcase
      If++j % 1000 == 0
        Commit
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  rest_box( buf )
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, 'Не найдено л/у по диспансеризации взрослого населения ' + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 20.10.16 карта учёта диспансеризации по форме №131/у
Function f_131_u()

  Local arr_m, buf := save_maxrow(), k, blk, t_arr[ BR_LEN ], rec := 0

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != Nil .and. f0_inf_dvn( arr_m, .f. )
    mywait()
    r_use( dir_server() + 'kartotek',, 'KART' )
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmp' ) new
    If glob_kartotek > 0
      find ( Str( glob_kartotek, 7 ) )
      If Found()
        rec := tmp->( RecNo() )
      Endif
    Endif
    Set Relation To kod_k into KART
    Index On Upper( kart->fio ) to ( cur_dir() + 'tmp' )
    Private ;
      blk_open := {|| dbCloseAll(), ;
      r_use( dir_server() + 'uslugi',, 'USL' ), ;
      r_use( dir_server() + 'human_u_',, 'HU_' ), ;
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' ), ;
      dbSetRelation( 'HU_', {|| RecNo() }, 'recno()' ), ;
      r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
      r_use( dir_server() + 'human',, 'HUMAN' ), ;
      dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
      r_use( dir_server() + 'kartote_',, 'KART_' ), ;
      r_use( dir_server() + 'kartotek',, 'KART' ), ;
      dbSetRelation( 'KART_', {|| RecNo() }, 'recno()' ), ;
      r_use( cur_dir() + 'tmp', cur_dir() + 'tmp' ), ;
      dbSetRelation( 'KART', {|| kod_k }, 'kod_k' );
      }
    Eval( blk_open )
    Go Top
    If rec > 0
      Goto ( rec )
    Endif
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := 23
    t_arr[ BR_LEFT ] := 0
    t_arr[ BR_RIGHT ] := 79
    t_arr[ BR_TITUL ] := 'Взрослое население ' + arr_m[ 4 ]
    t_arr[ BR_TITUL_COLOR ] := 'B/BG'
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB', .t. }
    blk := {|| iif( emptyall( tmp->kod1h, tmp->kod2h ), { 5, 6 }, iif( Empty( tmp->kod2h ), { 1, 2 }, { 3, 4 } ) ) }
    t_arr[ BR_COLUMN ] := { { ' Ф.И.О.',     {|| PadR( kart->fio, 39 ) }, blk }, ;
      { 'Дата рожд.',  {|| full_date( kart->date_r ) }, blk }, ;
      { '№ ам.карты',  {|| PadR( __f_131_u( 1 ), 10 ) }, blk }, ;
      { 'Сроки леч-я', {|| PadR( __f_131_u( 2 ), 11 ) }, blk }, ;
      { 'Этап',        {|| PadR( __f_131_u( 3 ), 4 ) }, blk } }
    t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - распечатать карту учёта дисп-ии (проф.осмотра)' ) }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_131_u( nk, ob, 'edit' ) }
    edit_browse( t_arr )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 20.09.15
Static Function __f_131_u( k )

  Local s := '', ie := 1

  If emptyall( tmp->kod1h, tmp->kod2h ) // значит профилактика
    human->( dbGoto( tmp->kod3h ) )
    ie := 3
  Else // диспансеризация
    If Empty( tmp->kod1h ) // почему-то нет первого этапа
      human->( dbGoto( tmp->kod2h ) )
    Else
      human->( dbGoto( tmp->kod1h ) )
    Endif
    If !Empty( tmp->kod2h ) // есть второй этап
      ie := 2
    Endif
  Endif
  If k == 1
    s := human->uch_doc
  Elseif k == 2
    s := Left( date_8( human->n_data ), 5 ) + '-'
    If ie == 2
      human->( dbGoto( tmp->kod2h ) )
    Endif
    s += Left( date_8( human->k_data ), 5 )
  Else
    s := { 'I эт', 'I-II', 'проф' }[ ie ]
  Endif

  Return s

// 27.09.24
Function f1_131_u( nKey, oBrow, regim )

  Static lV := 'V', sb1 := '<b><u>', sb2 := '</u></b>'
  Static s_smg := 'Не удалось определить группу здоровья'
  Local ret := -1, rec := tmp->( RecNo() ), buf := save_maxrow(), ;
    i, j, k, fl, lshifr, au := {}, ar, metap, m1gruppa, is_disp := .t., ;
    mpol := kart->pol, fl_dispans := .f., adbf, s, y, m, d, arr, ;
    blk := {| s| __dbAppend(), field->stroke := s }

  If regim == 'edit' .and. nKey == K_ENTER
    glob_kartotek := tmp->kod_k
    delfrfiles()
    mywait()
    Private arr_otklon := {}, arr_usl_otkaz := {}, mvozrast, mdvozrast, ;
      M1RAB_NERAB, m1veteran := 0, m1mobilbr := 0, ;
      m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0, ;
      m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
      mholest := 0, mglukoza := 0, ;
      m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
      m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0, ;
      m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0, ;
      m1spec_na := 0, m1sank_na := 0, ;
      pole_diag, pole_1pervich, pole_1stadia, pole_1dispans, ;
      mWEIGHT := 0, mHEIGHT := 0, mn_data, mk_data, mk_data1
    For i := 1 To 5
      pole_diag := 'mdiag' + lstr( i )
      pole_d_diag := 'mddiag' + lstr( i )
      pole_1pervich := 'm1pervich' + lstr( i )
      pole_1stadia := 'm1stadia' + lstr( i )
      pole_1dispans := 'm1dispans' + lstr( i )
      pole_d_dispans := 'mddispans' + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_d_diag := CToD( '' )
      Private &pole_1pervich := 0
      Private &pole_1stadia := 0
      Private &pole_1dispans := 0
      Private &pole_d_dispans := CToD( '' )
    Next
    If emptyall( tmp->kod1h, tmp->kod2h ) // значит профилактика
      is_disp := .f.
      human->( dbGoto( tmp->kod3h ) )
      If Between( human_->RSLT_NEW, 343, 345 )
        m1GRUPPA := human_->RSLT_NEW - 342
      Elseif Between( human_->RSLT_NEW, 373, 374 )
        m1GRUPPA := human_->RSLT_NEW - 370
      Endif
      If !Between( m1gruppa, 1, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
    Else // I этап
      If Empty( tmp->kod1h )
        func_error( 4, 'Присутствует II этап, но отсутствует I этап' )
        rest_box( buf )
        Return ret
      Endif
      human->( dbGoto( tmp->kod1h ) )
      m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
      If !Between( m1gruppa, 0, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
    Endif
    M1RAB_NERAB := human->RAB_NERAB
    mn_data := human->n_data
    mk_data := mk_data1 := human->k_data
    Private is_disp_19 := !( mk_data < 0d20190501 )
    Private is_disp_21 := !( mk_data < 0d20210101 )
    Private is_disp_24 := !( mk_data < 0d20240901 )
    mdate_r := full_date( human->date_r )
    read_arr_dvn( human->kod )
    ret_arr_vozrast_dvn( mk_data )

    mvozrast := count_years( human->date_r, human->n_data )
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    If m1veteran == 1
      mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
    Endif

    ret_arrays_disp( mk_data )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If !eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        AAdd( au, { AllTrim( lshifr ), ;
          hu_->PROFIL, ;
          iif( Left( hu_->kod_diag, 1 ) == 'Z', '', hu_->kod_diag ), ;
          c4tod( hu->date_u );
          } )
      Endif
      Select HU
      Skip
    Enddo
    k_nev_4_1_12 := 0
    For k := 1 To Len( au )
      lshifr := au[ k, 1 ]
      If is_disp_19
        //
      Elseif ( ( lshifr == '2.3.3' .and. au[ k, 2 ] == 3 ) .or.  ; // акушерскому делу
        ( lshifr == '2.3.1' .and. au[ k, 2 ] == 136 ) )    // акушерству и гинекологии
        k_nev_4_1_12 := k
      Endif
      If AScan( arr_otklon, au[ k, 1 ] ) > 0
        au[ k, 3 ] := '+' // отклонения в исследовании
        If eq_any( lshifr, '4.20.1', '4.20.2' ) // если отклонения в исследовании цитологич.материала
          If ( i := AScan( au, {| x| x[ 1 ] == '4.1.12' } ) ) > 0
            au[ i, 3 ] := '+' // занесём отклонения в осмотр фельдшера '4.1.12'
          Endif
        Endif
      Endif
    Next
    If is_disp_19
      arr_10 := { ;
        { 1, '56.1.16', 'Опрос (анкетирование) на выявление хронических неинфекционных заболеваний, факторов риска их развития, потребления наркотических средств и психотропных веществ без назначения врача' }, ;
        { 2, '3.1.19', 'Антропометрия (измерение роста стоя, массы тела, окружности талии), расчет индекса массы тела' }, ;
        { 3, '3.1.5', 'Измерение артериального давления' }, ;
        { 4, '3.4.9', 'Измерение внутриглазного давления' }, ;
        { 5, '4.12.174', 'Исследование крови на общий холестерин' }, ;
        { 6, '4.12.169', 'Исследование уровня глюкозы в крови' }, ;
        { 7, '4.11.137', 'Клинический анализ крови (3 показателя)' }, ;
        { 8, '4.8.4', 'Исследование кала на скрытую кровь' }, ;
        { 9, '4.14.66', 'Исследование крови на простат-специфический антиген' }, ;
        { 10, { { '2.3.1', 136 }, { '2.3.3', 3 }, { '2.3.3', 42 } }, 'Осмотр акушеркой или акушером-гинекологом' }, ;
        { 11, { '4.1.12', '4.20.1', '4.20.2' }, 'Взятие мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование' }, ;
        { 12, '7.57.3', 'Маммография обеих молочных желез' }, ;
        { 13, '7.61.3', 'Флюорография лёгких профилактическая' }, ;
        { 14, '13.1.1', 'Электрокардиография (в покое)' }, ;
        { 15, '10.3.13', 'Фиброэзофагогастродуоденоскопия' }, ;
        { 16, '56.1.18', 'Определение относительного суммарного сердечно-сосудистого риска', 'mdvozrast < 40' }, ;
        { 17, '56.1.19', 'Определение абсолютного суммарного сердечно-сосудистого риска', '39 < mdvozrast .and. mdvozrast < 65' }, ;
        { 18, '56.1.14', 'Краткое индивидуальное профилактическое консультирование' }, ;
        { 19, { { '2.3.7', 57 }, { '2.3.7', 97 }, { '2.3.2', 57 }, { '2.3.2', 97 }, { '2.3.4', 42 } }, 'Прием (осмотр) врача-терапевта' };
        }
    Else
      arr_10 := { ;
        { 1, '56.1.16', 'Опрос (анкетирование) на выявление хронических неинфекционных заболеваний, факторов риска их развития, потребления наркотических средств и психотропных веществ без назначения врача' }, ;
        { 2, '3.1.19', 'Антропометрия (измерение роста стоя, массы тела, окружности талии), расчет индекса массы тела' }, ;
        { 3, '3.1.5', 'Измерение артериального давления' }, ;
        { 4, '4.12.174', 'Определение уровня общего холестерина в крови' }, ;
        { 5, '4.12.169', 'Определение уровня глюкозы в крови экспресс-методом' }, ;
        { 6, { '56.1.17', '56.1.18' }, 'Определение относительного суммарного сердечно-сосудистого риска', 'mdvozrast < 40' }, ;
        { 7, { '56.1.17', '56.1.19' }, 'Определение абсолютного суммарного сердечно-сосудистого риска', '39 < mdvozrast .and. mdvozrast < 66' }, ;
        { 8, '13.1.1', 'Электрокардиография (в покое)' }, ;
        { 9, { '4.1.12', '4.20.1', '4.20.2' }, 'Осмотр фельдшером (акушеркой), включая взятие мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование' }, ;
        { 10, '7.61.3', 'Флюорография легких' }, ;
        { 11, '7.57.3', 'Маммография обеих молочных желез' }, ;
        { 12, '4.11.137', 'Клинический анализ крови' }, ;
        { 13, '4.11.136', 'Клинический анализ крови развернутый' }, ;
        { 14, '4.12.172', 'Анализ крови биохимический общетерапевтический' }, ;
        { 15, '4.2.153', 'Общий анализ мочи' }, ;
        { 16, '4.8.4', 'Исследование кала на скрытую кровь иммунохимическим методом' }, ;
        { 17, { '8.2.1', '8.2.4', '8.2.5' }, 'Ультразвуковое исследование (УЗИ) на предмет исключения новообразований органов брюшной полости, малого таза' }, ;
        { 18, '8.1.5', 'Ультразвуковое исследование (УЗИ) в целях исключения аневризмы брюшной аорты' }, ;
        { 19, '3.4.9', 'Измерение внутриглазного давления' }, ;
        { 20, { { '2.3.1', 97 }, { '2.3.1', 57 }, { '2.3.2', 97 }, { '2.3.2', 57 }, { '2.3.3', 42 }, { '2.3.5', 57 }, { '2.3.5', 97 }, { '2.3.6', 57 }, { '2.3.6', 97 } }, 'Прием (осмотр) врача-терапевта' };
        }
      If is_disp .and. Year( mk_data ) > 2017 // с 18 года
        arr_10[ 13 ] := { 13, '4.14.66', 'Исследование крови на простат-специфический антиген' }
        del_array( arr_10, 18 )
        del_array( arr_10, 17 )
        del_array( arr_10, 15 )
        del_array( arr_10, 14 )
      Endif
    Endif
    dbCreate( fr_data, { { 'name', 'C', 200, 0 }, ;
      { 'ns', 'N', 2, 0 }, ;
      { 'vv', 'C', 10, 0 }, ;
      { 'vo', 'C', 10, 0 }, ;
      { 'vd', 'C', 20, 0 } } )
    Use ( fr_data ) New Alias FRD
    For n := 1 To Len( arr_10 )
      Append Blank
      frd->name := arr_10[ n, 3 ]
      frd->ns := arr_10[ n, 1 ]
    Next
    Index On Str( ns, 2 ) To tmp_frd
    For i := 1 To Len( arr_10 )
      fl := fl_nev := .f. ;  date_o := CToD( '' )
      If ValType( arr_usl_otkaz ) == 'A'
        For k1 := 1 To Len( arr_usl_otkaz )
          ar := arr_usl_otkaz[ k1 ]
          If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C' ;
              .and. ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
            lshifr := AllTrim( ar[ 5 ] )
            If ValType( arr_10[ i, 2 ] ) == 'C'
              If lshifr == arr_10[ i, 2 ]
                fl := .t.
                If ar[ 10 ] == 1 // отказ
                  date_o := ar[ 9 ]
                Else // невозможность
                  fl_nev := .t.
                Endif
              Endif
            Elseif ValType( arr_10[ i, 2, 1 ] ) == 'C' // шифры в массиве
              For j := 1 To Len( arr_10[ i, 2 ] )
                If lshifr == arr_10[ i, 2, j ]
                  fl := .t.
                  If ar[ 10 ] == 1 // отказ
                    date_o := ar[ 9 ]
                  Else // невозможность
                    fl_nev := .t.
                  Endif
                  Exit
                Endif
              Next
            Else
              For j := 1 To Len( arr_10[ i, 2 ] )
                If lshifr == arr_10[ i, 2, j, 1 ] .and. ar[ 4 ] == arr_10[ i, 2, j, 2 ]
                  fl := .t.
                  If ar[ 10 ] == 1 // отказ
                    date_o := ar[ 9 ]
                  Else // невозможность
                    fl_nev := .t.
                  Endif
                  Exit
                Endif
              Next
            Endif
          Endif
          If fl ; exit ; Endif
        Next
      Endif
      If !fl
        If ValType( arr_10[ i, 2 ] ) == 'C' // один шифр
          If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2 ] } ) ) > 0
            fl := .t.
          Endif
        Elseif ValType( arr_10[ i, 2, 1 ] ) == 'C' // шифры в массиве
          For j := 1 To Len( arr_10[ i, 2 ] )
            If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2, j ] } ) ) > 0
              fl := .t. ; Exit
            Endif
          Next
        Else // в массиве пары: шифр и профиль
          For j := 1 To Len( arr_10[ i, 2 ] )
            If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2, j, 1 ] .and. x[ 2 ] == arr_10[ i, 2, j, 2 ] } ) ) > 0
              fl := .t. ; Exit
            Endif
          Next
        Endif
      Endif
      If fl .and. Len( arr_10[ i ] ) > 3
        fl := &( arr_10[ i, 4 ] )
      Endif
      If fl
        find ( Str( arr_10[ i, 1 ], 2 ) )
        If ValType( arr_10[ i, 2 ] ) == 'A' .and. ValType( arr_10[ i, 2, 1 ] ) == 'C' ;
            .and. arr_10[ i, 2, 1 ] == '4.1.12' .and. k_nev_4_1_12 > 0
          frd->vv := full_date( au[ k_nev_4_1_12, 4 ] )
          frd->vd := 'невозможно'
        Elseif fl_nev
          frd->vv := 'невозможно'
        Elseif !Empty( date_o )
          frd->vv := 'отказ'
          frd->vo := full_date( date_o )
        Else
          frd->vv := full_date( au[ k, 4 ] )
          If au[ k, 4 ] < human->n_data
            frd->vo := full_date( au[ k, 4 ] )
          Endif
          frd->vd := iif( Empty( au[ k, 3 ] ), '-', '<b>' + au[ k, 3 ] + '</b>' )
        Endif
      Endif
    Next
    Select FRD
    Set Index To
    Go Top
    Do While !Eof()
      If emptyall( frd->vv, frd->vd, frd->vo )
        Delete
      Endif
      Skip
    Enddo
    Pack
    n := 0
    Go Top
    Do While !Eof()
      frd->ns := ++n
      Skip
    Enddo
    //
    adbf := { { 'titul', 'C', 50, 0 }, ;
      { 'titul2', 'C', 50, 0 }, ;
      { 'fio', 'C', 100, 0 }, ;
      { 'fio2', 'C', 60, 0 }, ;
      { 'pol', 'C', 50, 0 }, ;
      { 'date_r', 'C', 10, 0 }, ;
      { 'd_dr', 'C', 2, 0 }, ;
      { 'm_dr', 'C', 2, 0 }, ;
      { 'y_dr', 'C', 4, 0 }, ;
      { 'vozrast', 'N', 4, 0 }, ;
      { 'subekt', 'C', 50, 0 }, ;
      { 'rajon', 'C', 50, 0 }, ;
      { 'gorod', 'C', 50, 0 }, ;
      { 'nas_p', 'C', 50, 0 }, ;
      { 'adres', 'C', 200, 0 }, ;
      { 'gorod_selo', 'C', 50, 0 }, ;
      { 'kod_lgot', 'C', 2, 0 }, ;
      { 'sever', 'C', 30, 0 }, ;
      { 'zanyat', 'C', 200, 0 }, ;
      { 'mobil', 'C', 30, 0 }, ;
      { 'n_data', 'C', 10, 0 }, ;
      { 'k_data', 'C', 10, 0 }, ;
      { 'v13_1', 'C', 10, 0 }, ;
      { 'v13_2', 'C', 10, 0 }, ;
      { 'v13_3', 'C', 10, 0 }, ;
      { 'v13_4', 'C', 10, 0 }, ;
      { 'v13_5', 'C', 10, 0 }, ;
      { 'v13_6', 'C', 10, 0 }, ;
      { 'v13_7', 'C', 10, 0 }, ;
      { 'v13_8', 'C', 10, 0 }, ;
      { 'v13_9', 'C', 10, 0 }, ;
      { 'v14', 'C', 2, 0 }, ;
      { 'v14_1', 'C', 1, 0 }, ;
      { 'v14_2', 'C', 1, 0 }, ;
      { 'v15', 'C', 2, 0 }, ;
      { 'v15_1', 'C', 1, 0 }, ;
      { 'v15_2', 'C', 1, 0 }, ;
      { 'v16_1', 'C', 1, 0 }, ;
      { 'v16_2', 'C', 1, 0 }, ;
      { 'v16_3', 'C', 1, 0 }, ;
      { 'v16_4', 'C', 1, 0 }, ;
      { 'v17', 'C', 30, 0 }, ;
      { 'v18', 'C', 30, 0 }, ;
      { 'v18_1', 'C', 30, 0 }, ;
      { 'v18_2', 'C', 30, 0 }, ;
      { 'v19', 'C', 30, 0 }, ;
      { 'v20', 'C', 30, 0 }, ;
      { 'vrach', 'C', 100, 0 } }
    dbCreate( fr_titl, adbf )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->titul := iif( !emptyall( tmp->kod1h, tmp->kod2h ), 'диспансеризации', 'профилактического медицинского осмотра' )
    frt->titul2 := iif( !emptyall( tmp->kod1h, tmp->kod2h ), 'Диспансеризация', 'Профилактический медицинский осмотр' )
    arr := retfamimot( 1, .f. )
    frt->fio2 := arr[ 1 ] + ' ' + arr[ 2 ] + ' ' + arr[ 3 ]
    frt->fio := Expand( Upper( RTrim( frt->fio2 ) ) )
    frt->pol := iif( kart->pol == 'М', sb1 + 'муж. - 1' + sb2 + ', жен. - 2', 'муж. - 1, ' + sb1 + 'жен. - 2' + sb2 )
    frt->date_r := mdate_r
    frt->d_dr := SubStr( mdate_r, 1, 2 )
    frt->m_dr := SubStr( mdate_r, 4, 2 )
    frt->y_dr := SubStr( mdate_r, 7, 4 )
    frt->vozrast := mvozrast
    If f_is_selo()
      frt->gorod_selo := 'городская - 1, ' + sb1 + 'сельская - 2' + sb2
    Else
      frt->gorod_selo := sb1 + 'городская - 1' + sb2 + ', сельская - 2'
    Endif
    arr := ret_okato_array( kart_->okatog )
    frt->subekt := arr[ 1 ]
    frt->rajon  := arr[ 2 ]
    frt->gorod  := arr[ 3 ]
    frt->nas_p  := arr[ 4 ]
    If Empty( kart->adres )
      frt->adres := 'улица' + sb1 + Space( 30 ) + sb2 + ' дом' + sb1 + Space( 5 ) + sb2 + ' квартира' + sb1 + Space( 5 ) + sb2
    Else
      frt->adres := sb1 + PadR( kart->adres, 60 ) + sb2
    Endif
    If ( i := AScan( stm_kategor(), {| x| x[ 2 ] == kart_->kategor } ) ) > 0 .and. Between( stm_kategor()[ i, 3 ], 1, 8 )
      frt->kod_lgot := lstr( stm_kategor()[ i, 3 ] )
    Endif
    frt->mobil := f_131_u_da_net( m1mobilbr, sb1, sb2 )
    frt->n_data := full_date( mn_data )
    frt->v13_1 := iif( mad1 > 140 .and. mad2 > 90, frt->n_data, '-' )
    frt->v13_2 := iif( m1glukozadn == 1 .or. mglukoza > 6.1, frt->n_data, '-' )
    frt->v13_3 := iif( m1tip_mas >= 3, frt->n_data, '-' )
    frt->v13_4 := iif( m1kurenie == 1, frt->n_data, '-' )
    frt->v13_5 := iif( m1riskalk == 1, frt->n_data, '-' )
    frt->v13_6 := iif( m1pod_alk == 1, frt->n_data, '-' )
    frt->v13_7 := iif( m1fiz_akt == 1, frt->n_data, '-' )
    frt->v13_8 := iif( m1ner_pit == 1, frt->n_data, '-' )
    frt->v13_9 := iif( m1ot_nasl1 == 1 .or. m1ot_nasl2 == 1 .or. m1ot_nasl3 == 1 .or. m1ot_nasl4 == 1, frt->n_data, '-' )
    If mdvozrast < 66
      If mdvozrast > 39
        frt->v15 := lstr( mssr )
        If 5 <= mssr .and. mssr < 10 // Высокий абс.суммарный сердечно-сосудистый риск
          frt->v15_1 := lV
        Elseif mssr >= 10 // Очень высокий абс.суммарный сердечно-сосудистый риск
          frt->v16_2 := lV
        Endif
      Else
        frt->v14 := lstr( mssr )
        If mssr < 1 // низкий отн.суммарный сердечно-сосудистый риск
          frt->v14_1 := lV
        Elseif 5 <= mssr .and. mssr < 10 // низкий отн.суммарный сердечно-сосудистый риск
          frt->v14_2 := lV
        Endif
      Endif
    Endif
    dbCreate( fr_data + '1', { { 'name', 'C', 200, 0 }, ;
      { 'ns', 'N', 2, 0 }, ;
      { 'vn', 'C', 10, 0 }, ;
      { 'vv', 'C', 10, 0 }, ;
      { 'vd', 'C', 20, 0 } } )
    If !Empty( tmp->kod2h ) // II этап
      human->( dbGoto( tmp->kod2h ) )
      M1RAB_NERAB := human->RAB_NERAB
      mk_data := human->k_data
      is_disp_19 := !( mk_data < 0d20190501 )
      m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
      If !Between( m1gruppa, 1, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
      read_arr_dvn( human->kod )
      //
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
          lshifr := usl->shifr
        Endif
        AAdd( au, { AllTrim( lshifr ), ;
          hu_->PROFIL, ;
          iif( Left( hu_->kod_diag, 1 ) == 'Z', '', hu_->kod_diag ), ;
          c4tod( hu->date_u );
          } )
        Select HU
        Skip
      Enddo
      For k := 1 To Len( au )
        If AScan( arr_otklon, au[ k, 1 ] ) > 0
          au[ k, 3 ] := '+' // отклонения в исследовании
        Endif
      Next
      If is_disp_19
        arr_11 := { ;
          { 1, 'Дуплексное сканирование брахиоцефальных артерий', '8.23.706' }, ;
          { 2, 'Рентгенография органов грудной клетки', '7.2.702' }, ;
          { 3, 'КТ органов грудной полости', '7.2.701' }, ;
          { 4, 'Спиральная КТ легких', '7.2.703' }, ;
          { 5, 'КТ органов грудной полости (с контрастир-ием)', '7.2.704' }, ;
          { 6, 'Однофотонная эмиссионная КТ легких', '7.2.705' }, ;
          { 7, 'Ректосигмоколоноскопия диагностическая', '10.6.710' }, ;
          { 8, 'Ректороманоскопия', '10.4.701' }, ;
          { 9, 'Фиброэзофагогастродуоденоскопия', '10.3.713' }, ;
          { 10, 'Спирометрия', '16.1.717' }, ;
          { 11, 'Осмотр (консультация) врачом-неврологом', '2.84.1' }, ;
          { 12, 'Осмотр (консультация) врачом-хирургом или врачом-урологом', '2.84.10' }, ;
          { 13, 'Осмотр (консультация) врачом-хирургом или врачом-колопроктологом', '2.84.6' }, ;
          { 14, 'Осмотр (консультация) врачом-акушером-гинекологом', '2.84.5' }, ;
          { 15, 'Осмотр (консультация) врачом-оториноларингологом', '2.84.8' }, ;
          { 16, 'Осмотр (консультация) врачом-офтальмологом', '2.84.3' }, ;
          { 17, 'Углубленное профилактическое консультирование', '56.1.723' }, ;
          { 18, 'Прием (осмотр) врача-терапевта', '2.84.11' };
          }
      Else
        arr_11 := { ;
          { 1, 'Дуплексное сканирование брахиоцефальных артерий', { '8.23.6', '8.23.706' } }, ;
          { 2, 'Осмотр (консультация) врачом-неврологом', '2.84.1' }, ;
          { 3, 'Эзофагогастродуоденоскопия', '10.3.13' }, ;
          { 4, 'Осмотр (консультация) врачом-хирургом или врачом-урологом', '2.84.10' }, ;
          { 5, 'Осмотр (консультация) врачом-хирургом или врачом-колопроктологом', '2.84.6' }, ;
          { 6, 'Колоноскопия или ректороманоскопия', { '10.4.1', '10.6.10' } }, ;
          { 7, 'Определение липидного спектра крови', '4.12.173' }, ;
          { 8, 'Спирометрия', { '16.1.17', '16.1.717' } }, ;
          { 9, 'Осмотр (консультация) врачом-акушером-гинекологом', '2.84.5' }, ;
          { 10, 'Определение концентрации гликированного гемоглобина в крови или тест на толерантность к глюкозе', { '4.12.170', '4.12.171' } }, ;
          { 11, 'Осмотр (консультация) врачом-оториноларингологом', '2.84.8' }, ;
          { 12, 'Анализ крови на уровень содержания простатспецифического антигена', '4.14.66' }, ;
          { 13, 'Осмотр (консультация) врачом-офтальмологом', '2.84.3' }, ;
          { 14, 'Индивидуальное углубленное профилактическое консультирование', { '56.1.15', '56.1.20' } }, ;
          { 15, 'Групповое профилактическое консультирование (школа пациента)', '0' }, ;
          { 16, 'Прием (осмотр) врача-терапевта', { '2.84.2', '2.84.7', '2.84.9', '2.84.11' } };
          }
        If is_disp .and. Year( mk_data ) > 2017 // с 18 года
          arr_11[ 6 ] := { 6, 'Ректосигмоколоноскопия диагностическая', '10.6.710' }
          arr_11[ 14 ] := { 14, 'Индивидуальное или групповое (школа для пациента) углубленное профилактическое консультирование', '56.1.723' }
          del_array( arr_11, 15 )
          del_array( arr_11, 12 )
          del_array( arr_11, 10 )
          del_array( arr_11, 7 )
          del_array( arr_11, 3 )
        Endif
      Endif
      Use ( fr_data + '1' ) New Alias FRD1
      For n := 1 To Len( arr_11 )
        Append Blank
        frd1->name := arr_11[ n, 2 ]
        frd1->ns := arr_11[ n, 1 ]
      Next
      Index On Str( ns, 2 ) To tmp_frd1
      For k := 1 To Len( au )
        fl := .f.
        For i := 1 To Len( arr_11 )
          If ValType( arr_11[ i, 3 ] ) == 'A'
            fl := ( AScan( arr_11[ i, 3 ], au[ k, 1 ] ) > 0 )
          Else
            fl := ( au[ k, 1 ] == arr_11[ i, 3 ] )
          Endif
          If fl ; exit ; Endif
        Next
        If fl
          find ( Str( arr_11[ i, 1 ], 2 ) )
          frd1->vn := full_date( mk_data1 )
          frd1->vv := full_date( au[ k, 4 ] )
          frd1->vd := iif( Empty( au[ k, 3 ] ), '-', '<b>' + au[ k, 3 ] + '</b>' )
        Endif
      Next
      Select FRD1
      Set Index To
      Go Top
      Do While !Eof()
        If emptyall( frd1->vv, frd1->vd, frd1->vn )
          Delete
        Endif
        Skip
      Enddo
      Pack
      n := 0
      Go Top
      Do While !Eof()
        frd1->ns := ++n
        Skip
      Enddo
    Endif
    frt->k_data := full_date( mk_data )
    frt->zanyat := iif( M1RAB_NERAB == 0, sb1, '' ) + '1 - работает' + iif( M1RAB_NERAB == 0, sb2, '' ) + ';  ' + ;
      iif( M1RAB_NERAB == 1, sb1, '' ) + '2 - не работает' + iif( M1RAB_NERAB == 1, sb2, '' ) + ';  ' + ;
      iif( M1RAB_NERAB == 2, '<u>', '' ) + '3 - обучающийся в образовательной организации по очной форме' + iif( M1RAB_NERAB == 2, '</u>', '' ) + '.'
    frt->sever := f_131_u_da_net( 0, sb1, sb2 )
    Do Case
    Case m1gruppa == 1
      frt->v16_1 := lV
    Case m1gruppa == 2
      frt->v16_2 := lV
    Case m1gruppa == 3
      frt->v16_3 := lV
    Case m1gruppa == 4
      frt->v16_4 := lV
    Endcase
    frt->v17   := f_131_u_da_net( m1nazn_l, sb1, sb2 )
    frt->v18   := f_131_u_da_net( m1dopo_na, sb1, sb2 )
    frt->v18_1 := f_131_u_da_net( m1ssh_na, sb1, sb2 )
    frt->v18_2 := f_131_u_da_net( m1psih_na, sb1, sb2 )
    frt->v19   := f_131_u_da_net( m1spec_na, sb1, sb2 )
    frt->v20   := f_131_u_da_net( m1sank_na, sb1, sb2 )
    r_use( dir_server() + 'mo_pers',, 'P2' )
    Goto ( human_->vrach )
    frt->vrach := p2->fio
    //
    arr_12 := { ;
      { 7, '1', 'Некоторые инфекционные и паразитарные болезни', 'A00-B99' }, ;
      { 8, '1.1', '  в том числе: туберкулез', 'A15-A19' }, ;
      { 9, '2', 'Новообразования', 'C00-D48' }, ;
      { 10, '2.1', 'в том числе: злокачественные новообразования и новообразования in situ', 'C00-D09' }, ;
      { 11, '2.2', 'в том числе: пищевода', 'C15,D00.1' }, ;
      { 12, '2.2.1', ' из них в 1-2 стадии', 'C15,D00.1', '1' }, ;
      { 13, '2.3', 'желудка', 'C16,D00.2' }, ;
      { 14, '2.3.1', ' из них в 1-2 стадии', 'C16,D00.2', '1' }, ;
      { 15, '2.4', 'ободочной кишки', 'C18,D01.0' }, ;
      { 16, '2.4.1', ' из них в 1-2 стадии', 'C18,D01.0', '1' }, ;
      { 17, '2.5', 'ректосигмоидного соединения, прямой кишки, заднего прохода (ануса) и анального канала', 'C19-C21,D01.1-D01.3' }, ;
      { 18, '2.5.1', ' из них в 1-2 стадии', 'C19-C21,D01.1-D01.3', '1' }, ;
      { 19, '2.6', 'поджелудочной железы', 'C25' }, ;
      { 20, '2.6.1', ' из них в 1-2 стадии', 'C25', '1' }, ;
      { 21, '2.7', 'трахеи, бронхов и легкого', 'C33,C34,D02.1-D02.2' }, ;
      { 22, '2.7.1', ' из них в 1-2 стадии', 'C33,C34,D02.1-D02.2', '1' }, ;
      { 23, '2.8', 'молочной железы', 'C50,D05' }, ;
      { 24, '2.8.1', ' из них в 1-2 стадии', 'C50,D05', '1' }, ;
      { 25, '2.9', 'шейки матки', 'C53,D06' }, ;
      { 26, '2.9.1', ' из них в 1-2 стадии', 'C53,D06', '1' }, ;
      { 27, '2.10', 'тела матки', 'C54' }, ;
      { 28, '2.10.1', ' из них в 1-2 стадии', 'C54', '1' }, ;
      { 29, '2.11', 'яичника', 'C56' }, ;
      { 30, '2.11.1', ' из них в 1-2 стадии', 'C56', '1' }, ;
      { 31, '2.12', 'предстательной железы', 'C61,D07.5' }, ;
      { 32, '2.12.1', ' из них в 1-2 стадии', 'C61,D07.5', '1' }, ;
      { 33, '2.13', 'почки, кроме почечной лоханки', 'C64' }, ;
      { 34, '2.13.1', ' из них в 1-2 стадии', 'C64', '1' }, ;
      { 35, '3', 'Болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм', 'D50-D89' }, ;
      { 36, '3.1', 'в том числе: анемии, связанные с питанием, гемолитические анемии, апластические и другие анемии', 'D50-D64' }, ;
      { 37, '4', 'Болезни эндокринной системы, расстройства питания и нарушения обмена веществ', 'E00-E90' }, ;
      { 38, '4.1', 'в том числе: сахарный диабет', 'E10-E14' }, ;
      { 39, '4.2', 'ожирение', 'E66' }, ;
      { 40, '4.3', 'нарушения обмена липопротеинов и другие липидемии', 'E78' }, ;
      { 41, '5', 'Болезни нервной системы', 'G00-G99' }, ;
      { 42, '5.1', 'в том числе: преходящие церебральные ишемические приступы [атаки] и родственные синдромы', 'G45' }, ;
      { 43, '6', 'Болезни глаза и его придаточного аппарата', 'H00-H59' }, ;
      { 44, '6.1', 'в том числе: старческая катаракта и другие катаракты', 'H25,H26' }, ;
      { 45, '6.2', 'глаукома', 'H40' }, ;
      { 46, '6.3', 'слепота и пониженное зрение', 'H54' }, ;
      { 47, '7', 'Болезни системы кровообращения', 'I00-I99' }, ;
      { 48, '7.1', 'в том числе: болезни, характеризующиеся повышенным кровяным давлением', 'I10-I15' }, ;
      { 49, '7.2', 'ишемическая болезнь сердца', 'I20-I25' }, ;
      { 50, '7.2.1', 'в том числе: стенокардия (грудная жаба)', 'I20' }, ;
      { 51, '7.2.2', 'в том числе нестабильная стенокардия', 'I20.0' }, ;
      { 52, '7.2.3', 'хроническая ишемическая болезнь сердца', 'I25' }, ;
      { 53, '7.2.4', 'в том числе: перенесенный в прошлом инфаркт миокарда', 'I25.2' }, ;
      { 54, '7.3', 'другие болезни сердца', 'I30-I52' }, ;
      { 55, '7.4', 'цереброваскулярные болезни', 'I60-I69' }, ;
      { 56, '7.4.1', 'в том числе: закупорка и стеноз прецеребральных артерий, не приводящие к инфаркту мозга, и закупорка и стеноз церебральных артерий, не приводящие к инфаркту мозга', 'I65,I66' }, ;
      { 57, '7.4.2', 'другие цереброваскулярные болезни', 'I67' }, ;
      { 58, '7.4.3', 'последствия субарахноидального кровоизлияния, последствия внутричерепного кровоизлияния, последствия другого нетравматического внутричерепного кровоизлияния, последствия инфаркта мозга, последствия инсульта, не уточненные как кровоизлияние или инфаркт мозга', 'I69.0-I69.4' }, ;
      { 59, '7.4.4', 'аневризма брюшной аорты', 'I71.3-I71.4' }, ;
      { 60, '8', 'Болезни органов дыхания', 'J00-J98' }, ;
      { 61, '8.1', 'в том числе: вирусная пневмония, пневмония, вызванная Streptococcus pneumonia, пневмония, вызванная Haemophilus influenza, бактериальная пневмония, пневмония, вызванная другими инфекционными возбудителями, пневмония при болезнях, классифицированных в других рубриках, пневмония без уточнения возбудителя', 'J12-J18' }, ;
      { 62, '8.2', 'бронхит, не уточненный как острый и хронический, простой и слизисто-гнойный хронический бронхит, хронический бронхит неуточненный, эмфизема', 'J40-J43' }, ;
      { 63, '8.3', 'другая хроническая обструктивная легочная болезнь, астма, астматический статус, бронхоэктатическая болезнь', 'J44-J47' }, ;
      { 64, '9', 'Болезни органов пищеварения', 'K00-K93' }, ;
      { 65, '9.1', 'в том числе: язва желудка, язва двенадцатиперстной кишки', 'K25,K26' }, ;
      { 66, '9.2', 'гастрит и дуоденит', 'K29' }, ;
      { 67, '9.3', 'неинфекционный энтерит и колит', 'K50-K52' }, ;
      { 68, '9.4', 'другие болезни кишечника', 'K55-K63' }, ;
      { 69, '10', 'Болезни мочеполовой системы', 'N00-N99' }, ;
      { 70, '10.1', 'в том числе: гиперплазия предстательной железы, воспалительные болезни предстательной железы, другие болезни предстательной железы', 'N40-N42' }, ;
      { 71, '10.2', 'доброкачественная дисплазия молочной железы', 'N60' }, ;
      { 72, '10.3', 'воспалительные болезни женских тазовых органов', 'N70-N77' }, ;
      { 73, '11', 'Прочие заболевания', '' };
      }
    len12 := Len( arr_12 )
    diag12 := Array( len12 )
    dbCreate( fr_data + '2', { { 'name', 'C', 350, 0 }, ;
      { 'diagnoz', 'C', 50, 0 }, ;
      { 'ns', 'N', 2, 0 }, ;
      { 'stroke', 'C', 8, 0 }, ;
      { 'vz', 'C', 10, 0 }, ;
      { 'v1', 'C', 10, 0 }, ;
      { 'vd', 'C', 10, 0 }, ;
      { 'vp', 'C', 10, 0 } } )
    Use ( fr_data + '2' ) New Alias FRD2
    For n := 1 To len12
      Append Blank
      frd2->name := iif( '.' $ arr_12[ n, 2 ], '', '<b>' ) + arr_12[ n, 3 ] + iif( '.' $ arr_12[ n, 2 ], '', '</b>' )
      frd2->ns := n
      frd2->stroke := arr_12[ n, 2 ]
      If Len( arr_12[ n ] ) < 5
        frd2->diagnoz := arr_12[ n, 4 ]
      Endif
      s2 := arr_12[ n, 4 ]
      If Len( arr_12[ n ] ) > 4
        frd2->vp := '-'
      Endif
      diag12[ n ] := {}
      For i := 1 To NumToken( s2, ',' )
        s3 := Token( s2, ',', i )
        If '-' $ s3
          d1 := Token( s3, '-', 1 )
          d2 := Token( s3, '-', 2 )
        Else
          d1 := d2 := s3
        Endif
        AAdd( diag12[ n ], { diag_to_num( d1, 1 ), diag_to_num( d2, 2 ) } )
      Next
    Next
    For i := 1 To 5
      pole_diag := 'mdiag' + lstr( i )
      pole_d_diag := 'mddiag' + lstr( i )
      pole_1pervich := 'm1pervich' + lstr( i )
      pole_1stadia := 'm1stadia' + lstr( i )
      pole_1dispans := 'm1dispans' + lstr( i )
      pole_d_dispans := 'mddispans' + lstr( i )
      If !Empty( &pole_diag ) .and. !( Left( &pole_diag, 1 ) == 'Z' )
        au := {}
        d := diag_to_num( &pole_diag, 1 )
        For n := 1 To len12
          r := diag12[ n ]
          For j := 1 To Len( r )
            fl := Between( d, r[ j, 1 ], r[ j, 2 ] )
            If fl .and. Len( arr_12[ n ] ) > 4 // надо проверить стадию
              If human->k_data < 0d20150401 // до 1.04.2015
                fl := ( &pole_1stadia == 0 ) // ранняя
              Else
                fl := ( &pole_1stadia < 3 ) // 1 и 2 стадия
              Endif
            Endif
            If fl
              AAdd( au, n )
            Endif
          Next
        Next
        If Empty( au ) // заносим в прочие заболевания
          AAdd( au, len12 )
        Endif
        For j := 1 To Len( au )
          Goto ( au[ j ] )
          if &pole_1pervich == 1 // впервые
            frd2->vz := frd2->v1 := frt->k_data // дата приёма терапевта
            if &pole_1dispans == 1
              frd2->vd := frt->k_data
            Endif
          elseif &pole_1pervich == 0 // ранее выявленный
            frd2->vz := full_date( &pole_d_diag )
            if &pole_1dispans == 1
              frd2->vd := iif( Empty( &pole_d_dispans ), frd2->vz, full_date( &pole_d_dispans ) )
            Endif
          Else // предварительный диагноз
            If Empty( frd2->vp )
              frd2->vp := frt->k_data
            Endif
          Endif
        Next
      Endif
    Next
    Close databases
    call_fr( 'mo_131_u' ) // печать
    Close databases
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 01.07.17
Static Function f_131_u_da_net( k, sb1, sb2 )

  If k > 1 ; k := 1 ; Endif // если вместо 'да' битовый ответ

  Return f3_inf_dds_karta( { { 'да - 1', 1 }, { 'нет - 2', 0 } }, k, ';  ', sb1, sb2, .f. )

// 28.05.24 Приложение к Приказу ГБУЗ 'ВОМИАЦ' от 12.05.2017г. №1615
Function f21_inf_dvn( par ) // свод

  Local arr_m, buf := save_maxrow(), s, as := {}, as1[ 14 ], i, j, k, n, ar, at, ii, g1, sh := 65, fl, mdvozrast, adbf
  Local kol_2_year_dvn := 0, kol_2_year_prof := 0
  Local kol_2_year_dvn_40 := 0, kol_2_year_prof_40 := 0

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != Nil .and. f0_inf_dvn( arr_m, par > 1, par == 3, .t. )
    Private arr_usl_bio := { { ;
      'A11.20.010', ;// Биопсия молочной железы чрескожная
      'A11.20.010.001', ;// Биопсия новообразования молочной железы прицельная пункционная под контролем рентгенографического исследования
      'A11.20.010.002', ;// Биопсия новообразования молочной железы аспирационная вакуумная под контролем рентгенографического исследования
      'A11.20.010.004' ;// Биопсия непальпируемых новообразования молочной железы аспирационная вакуумная под контролем ультразвукового исследования
    }, ;
    { ;
      'A11.18.001', ;// Биопсия ободочной кишки эндоскопическая
      'A11.18.002', ;// Биопсия ободочной кишки оперативная
      'A11.19.001', ;// Биопсия сигмовидной кишки с помощью видеоэндоскопических технологий
      'A11.19.002', ;// Биопсия прямой кишки с помощью видеоэндоскопических технологий
      'A11.19.003', ;// Биопсия ануса и перианальной области
      'A11.19.009' ;// Биопсия толстой кишки при лапароскопии
    }, ;
    { ;
      'A11.20.011', ;// Биопсия шейки матки
      'A11.20.011.001', ;// Биопсия шейки матки радиоволновая
      'A11.20.011.002', ;// Биопсия шейки матки радиоволновая конусовидная
      'A11.20.011.003' ;// Биопсия шейки матки ножевая
    }, ;
    { ;
      'A11.01.001', ;// Биопсия кожи
      'A11.07.001', ;// Биопсия слизистой полости рта
      'A11.07.002', ;// Биопсия языка
      'A11.07.003', ;// Биопсия миндалины, зева и аденоидов
      'A11.07.004', ;// Биопсия глотки, десны и язычка
      'A11.07.005', ;// Биопсия слизистой преддверия полости рта
      'A11.07.006', ;// Биопсия пульпы
      'A11.07.007', ;// Биопсия тканей губы
      'A11.07.016', ;// Биопсия слизистой ротоглотки
      'A11.07.016.001', ;// Биопсия слизистой ротоглотки под контролем эндоскопического исследования
      'A11.07.020', ;// Биопсия слюнной железы
      'A11.07.020.001', ;// Биопсия околоушной слюнной железы
      'A11.08.001', ;// Биопсия слизистой оболочки гортани
      'A11.08.001.001', ;// Биопсия тканей гортани под контролем ларингоскопического исследования
      'A11.08.002', ;// Биопсия слизистой оболочки полости носа
      'A11.08.003', ;// Биопсия слизистой оболочки носоглотки
      'A11.08.003.001', ;// Биопсия слизистой оболочки носоглотки под контролем эндоскопического исследования
      'A11.08.015', ;// Биопсия слизистой оболочки околоносовых пазух
      'A11.08.016', ;// Биопсия тканей грушевидного кармана
      'A11.08.016.001', ;// Биопсия тканей грушевидного кармана под контролем эндоскопического исследования
      'A11.26.001' ;// Биопсия новообразования век, конъюнктивы или роговицы
    };
      }
    Private arr_21[ 50 ], arr_316 := {}, arr_ne := {}
    AFill( arr_21, 0 )
    mywait( 'Сбор статистики' )
    adbf := { { 'name', 'C', 80, 0 }, ;
      { 'NN', 'N', 2, 0 }, ;
      { 'g1', 'N', 6, 0 }, ;
      { 'g2', 'N', 6, 0 }, ;
      { 'g3', 'N', 6, 0 }, ;
      { 'g4', 'N', 6, 0 }, ;
      { 'g5', 'N', 6, 0 }, ;
      { 'g6', 'N', 6, 0 }, ;
      { 'g7', 'N', 6, 0 }, ;
      { 'g8', 'N', 6, 0 }, ;
      { 'g9', 'N', 6, 0 } }
    dbCreate( cur_dir() + 'tmp1', adbf )
    Use ( cur_dir() + 'tmp1' ) new
    Index On Str( nn, 2 ) to ( cur_dir() + 'tmp1' )
    Append Blank
    tmp1->nn := 2 ;  tmp1->name := 'Осмотрено всего (завершили I этап)'
    Append Blank
    tmp1->nn := 3 ;  tmp1->name := 'из гр.2 после 18:00'
    Append Blank
    tmp1->nn := 4 ;  tmp1->name := 'из гр.2 в субботу'
    Append Blank
    tmp1->nn := 5 ;  tmp1->name := 'из гр.2 прошедшие все исследования в один день'
    Append Blank
    tmp1->nn := 6 ;  tmp1->name := 'из гр.2 всего сельских жителей'
    Append Blank
    tmp1->nn := 7 ;  tmp1->name := 'из гр.6 сельских жителей после 18:00'
    Append Blank
    tmp1->nn := 8 ;  tmp1->name := 'из гр.6 сельских жителей в субботу'
    Append Blank
    tmp1->nn := 9 ;  tmp1->name := 'ГРАЖДАН с впервые выявлен.неинф.заболеваниями'
    Append Blank
    tmp1->nn := 10 ; tmp1->name := 'всего впервые выявлено неинф.заболеваний'
    Append Blank
    tmp1->nn := 11 ; tmp1->name := 'из гр.9 ГРАЖДАН болезни сист.кровообращения'
    Append Blank
    tmp1->nn := 12 ; tmp1->name := 'из гр.9 ГРАЖДАН ЗНО'
    Append Blank
    tmp1->nn := 13 ; tmp1->name := '        из гр.12 в т.ч. в 1 и 2 стадиях'
    Append Blank
    tmp1->nn := 14 ; tmp1->name := 'из гр.9 ГРАЖДАН сахарный диабет'
    Append Blank
    tmp1->nn := 15 ; tmp1->name := '        в т.ч. сахарный диабет I типа'
    Append Blank
    tmp1->nn := 16 ; tmp1->name := 'из гр.9 ГРАЖДАН глаукома'
    Append Blank
    tmp1->nn := 17 ; tmp1->name := 'из гр.9 ГРАЖДАН хрон.болезни органов дыхания'
    Append Blank
    tmp1->nn := 18 ; tmp1->name := 'из гр.9 ГРАЖДАН болезни органов пищеварения'
    Append Blank
    tmp1->nn := 19 ; tmp1->name := 'из гр.9 ГРАЖДАН взяты на дисп.наблюдение'
    Append Blank
    tmp1->nn := 20 ; tmp1->name := 'из гр.9 ГРАЖДАН было начато лечение'
    Append Blank
    tmp1->nn := 21 ; tmp1->name := '   из гр.19 из них сельских жителей'
    dbCreate( cur_dir() + 'tmp11', adbf )
    Use ( cur_dir() + 'tmp11' ) new
    Index On Str( nn, 2 ) to ( cur_dir() + 'tmp11' )
    Append Blank
    tmp11->nn :=  1 ; tmp11->name := 'впервые взяты на диспансерный учёт'
    Append Blank
    tmp11->nn :=  2 ; tmp11->name := 'оказана специализированная мед.помощь'
    Append Blank
    tmp11->nn :=  3 ; tmp11->name := 'оказаны реабилитационные мероприятия'
    Append Blank
    tmp11->nn :=  4 ; tmp11->name := 'отказались от проведения дисп-ии в целом'
    Append Blank
    tmp11->nn :=  5 ; tmp11->name := 'выявлено пациентов с онкопатологией'
    Append Blank
    tmp11->nn :=  6 ; tmp11->name := '  в т.ч. 1 стадия'
    Append Blank
    tmp11->nn :=  7 ; tmp11->name := '         2 стадия'
    Append Blank
    tmp11->nn :=  8 ; tmp11->name := '         3 стадия'
    Append Blank
    tmp11->nn :=  9 ; tmp11->name := '         4 стадия'
    Append Blank
    tmp11->nn := 10 ; tmp11->name := 'направлено на индивид.углубл.профилакт.конс-ие'
    Append Blank
    tmp11->nn := 11 ; tmp11->name := 'кол-во прошедших индивид.углубл.профилакт.конс-ие'
    Append Blank
    tmp11->nn := 12 ; tmp11->name := 'процент охвата индивид.углубл.профилакт.конс-ием'
    Append Blank
    tmp11->nn := 13 ; tmp11->name := 'направлено граждан на групповое профилакт.конс-ие'
    Append Blank
    tmp11->nn := 14 ; tmp11->name := 'кол-во прошедших групповое профилакт.конс-ие'
    Append Blank
    tmp11->nn := 15 ; tmp11->name := 'процент охвата групповым профилакт.конс-ием'
    //
    dbCreate( cur_dir() + 'tmp12', adbf )
    Use ( cur_dir() + 'tmp12' ) new
    Index On Str( nn, 2 ) to ( cur_dir() + 'tmp12' )
    Append Blank
    tmp12->nn :=  1 ; tmp12->name := 'Кол-во маммографий в рамках диспансеризации'
    Append Blank
    tmp12->nn :=  2 ; tmp12->name := '  кол-во застрахованных'
    Append Blank
    tmp12->nn :=  3 ; tmp12->name := '    выявлена патология в молочной железе'
    Append Blank
    tmp12->nn :=  4 ; tmp12->name := '      направлено на 2 этап диспансеризации'
    Append Blank
    tmp12->nn :=  5 ; tmp12->name := '      выполнена биопсия молочной железы'
    Append Blank                        // C50,D05
    tmp12->nn :=  6 ; tmp12->name := '    выявлено ЗНО молочной железы, всего'
    Append Blank
    tmp12->nn :=  7 ; tmp12->name := '      in situ'
    Append Blank
    tmp12->nn :=  8 ; tmp12->name := '      из них 1 стадия'
    Append Blank
    tmp12->nn :=  9 ; tmp12->name := '      из них 2 стадия'
    Append Blank
    tmp12->nn := 10 ; tmp12->name := '      из них 3 стадия'
    Append Blank
    tmp12->nn := 11 ; tmp12->name := '      из них 4 стадия'
    Append Blank
    tmp12->nn := 12 ; tmp12->name := 'Кол-во анализов кала на скрытую кровь'
    Append Blank
    tmp12->nn := 13 ; tmp12->name := '  кол-во застрахованных'
    Append Blank
    tmp12->nn := 14 ; tmp12->name := '    выявлен положительный тест на скрытую кровь в кале'
    Append Blank
    tmp12->nn := 15 ; tmp12->name := '      направлено на 2 этап диспансеризации'
    Append Blank
    tmp12->nn := 16 ; tmp12->name := '        выполнена колоноскопия'
    Append Blank
    tmp12->nn := 17 ; tmp12->name := '        выполнена ректороманоскопия'
    Append Blank
    tmp12->nn := 18 ; tmp12->name := '        выполнена биопсия при колоноскопии или ректороманоскопии'
    Append Blank                     // C18-C21,D01.0-D01.3
    tmp12->nn := 19 ; tmp12->name := '    выявлено ЗНО толстой/прямой кишки, всего'
    Append Blank
    tmp12->nn := 20 ; tmp12->name := '      in situ'
    Append Blank
    tmp12->nn := 21 ; tmp12->name := '      из них 1 стадия'
    Append Blank
    tmp12->nn := 22 ; tmp12->name := '      из них 2 стадия'
    Append Blank
    tmp12->nn := 23 ; tmp12->name := '      из них 3 стадия'
    Append Blank
    tmp12->nn := 24 ; tmp12->name := '      из них 4 стадия'
    Append Blank
    tmp12->nn := 25 ; tmp12->name := 'Кол-во ПАП-тестов  в рамках диспансеризации'
    Append Blank
    tmp12->nn := 26 ; tmp12->name := '  кол-во застрахованных'
    Append Blank
    tmp12->nn := 27 ; tmp12->name := '    выялена патология шейки матки'
    Append Blank
    tmp12->nn := 28 ; tmp12->name := '      направлено на 2 этап диспансеризации'
    Append Blank
    tmp12->nn := 29 ; tmp12->name := '      выполнена биопсия шейки матки'
    Append Blank                    // С53,D06
    tmp12->nn := 30 ; tmp12->name := '    выявлено ЗНО шейки матки, всего'
    Append Blank
    tmp12->nn := 31 ; tmp12->name := '      in situ'
    Append Blank
    tmp12->nn := 32 ; tmp12->name := '      из них 1 стадия'
    Append Blank
    tmp12->nn := 33 ; tmp12->name := '      из них 2 стадия'
    Append Blank
    tmp12->nn := 34 ; tmp12->name := '      из них 3 стадия'
    Append Blank
    tmp12->nn := 35 ; tmp12->name := '      из них 4 стадия'
    Append Blank
    tmp12->nn := 36 ; tmp12->name := 'Кол-во застр-ых, у которых выявлена патология кожи и видимых слизистых'
    Append Blank
    tmp12->nn := 37 ; tmp12->name := '  направлены на биопсию кожи и видимых слизистых'
    Append Blank                      // C00,C14.8,C43,C44,D00.0,D03,D04
    tmp12->nn := 38 ; tmp12->name := '  выявлено ЗНО кожи и видимых слизистых, всего'
    Append Blank
    tmp12->nn := 39 ; tmp12->name := '    in situ'
    Append Blank
    tmp12->nn := 40 ; tmp12->name := '    из них 1 стадия'
    Append Blank
    tmp12->nn := 41 ; tmp12->name := '    из них 2 стадия'
    Append Blank
    tmp12->nn := 42 ; tmp12->name := '    из них 3 стадия'
    Append Blank
    tmp12->nn := 43 ; tmp12->name := '    из них 4 стадия'
    //
    dbCreate( cur_dir() + 'tmp2', { { 'kod_k', 'N', 7, 0 }, ;
      { 'rslt1', 'N', 3, 0 }, ;
      { 'rslt2', 'N', 3, 0 } } )
    Use ( cur_dir() + 'tmp2' ) new
    Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp2' )
    r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
    Index On Str( KOD_H, 7 ) to ( cur_dir() + 'tmprpdsh' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'uslugi',, 'USL' )
    r_use( dir_server() + 'human_u_',, 'HU_' )
    r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
    Set Relation To RecNo() into HU_
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human',, 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To kod_k into KART_
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmp' ) new
    f_error_dvn( 1 )
    ii := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
      If !Empty( tmp->kod4h ) // Диспансеризация 1 раз в 2 года
        human->( dbGoto( tmp->kod4h ) )
        mdvozrast := Year( human->n_data ) - Year( human->date_r )
        g1 := ret_gruppa_dvn( human_->RSLT_NEW )
      /*if between(g1, 1, 4)
        arr_21[31] ++
        if human->pol == 'М'
          arr_21[32] ++
        else
          arr_21[33] ++
        endif
        if human->pol == 'Ж' .and. human->k_data < 0d20190501 .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
          arr_21[34] ++
        else
          arr_21[35] ++
        endif
      endif*/
      Elseif emptyall( tmp->kod1h, tmp->kod2h ) // профилактика
        human->( dbGoto( tmp->kod3h ) )
        mdvozrast := Year( human->n_data ) - Year( human->date_r )
        g1 := 0
        If Between( human_->RSLT_NEW, 343, 345 )
          g1 := human_->RSLT_NEW - 342
        Elseif Between( human_->RSLT_NEW, 373, 374 )
          g1 := human_->RSLT_NEW - 370
        Endif
        If Between( g1, 1, 4 )
          arr_21[ 14 ] ++
          If f_is_selo( kart_->gorod_selo, kart_->okatog )
            arr_21[ 15 ] ++
          Endif
          If g1 == 3
            arr_21[ 41 ] ++
          Elseif g1 == 4
            arr_21[ 42 ] ++
          Endif
          If g1 == 4 ; g1 := 3 ; Endif // Итого III группа
          arr_21[ 15 + g1 ]++   // профосмотры по группам здоровья
          If f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
            arr_21[ 40 ] ++
          Endif
          f2_f21_inf_dvn( 2 )
        Endif
      Else
        f1_f21_inf_dvn()
      Endif
      f_error_dvn( 2 )
      Select TMP
      Skip
    Enddo
    Close databases
    // проверим посещения 2 года назад
    mywait( 'Проверка на посещение учреждения в ближайшие 2 года' )
    r_use( dir_server() + 'human',, 'HUMAN' )
    Index On Str( KOD_k, 7 ) + DToS( n_data ) to ( cur_dir() + 'tmp_2year' ) For n_data > ( Date() -800 )
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmp' ) new
    ii := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
      If !Empty( tmp->kod4h ) // Диспансеризация 1 раз в 2 года
        //
      Elseif emptyall( tmp->kod1h, tmp->kod2h ) // профилактика
        Select human
        human->( dbGoto( tmp->kod3h ) )
        t_kod_k :=  human->kod_k
        t_date  :=  human->n_data
        Skip -1
        If human->kod_k == t_kod_k
          If ( ( t_date - human->n_data ) > 730 )
            kol_2_year_prof++
            If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
              kol_2_year_prof_40++
            Endif
          Endif
        Else
          kol_2_year_prof++
          If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
            kol_2_year_prof_40++
          Endif
        Endif
      Else// диспансеризация
        If ( tmp->kod1h > 0 )
          Select human
          human->( dbGoto( tmp->kod1h ) )
          t_kod_k :=  human->kod_k
          t_date  :=  human->n_data
          Skip -1
          If human->kod_k == t_kod_k
            If ( ( t_date - human->n_data ) > 730 )
              kol_2_year_dvn++
              If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
                kol_2_year_dvn_40++
              Endif
            Endif
          Else
            kol_2_year_dvn++
            If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 )  .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
              kol_2_year_dvn_40++
            Endif
          Endif
        Endif
      Endif
      Select TMP
      Skip
    Enddo
    Close databases
    dbCreate( cur_dir() + 'tmp3', { { 'et2', 'N', 1, 0 }, ;
      { 'gr1', 'N', 1, 0 }, ;
      { 'gr2', 'N', 1, 0 }, ;
      { 'kol1', 'N', 6, 0 }, ;
      { 'kol2', 'N', 6, 0 } } )
    Use ( cur_dir() + 'tmp3' ) new
    Index On Str( et2, 1 ) + Str( gr1, 1 ) + Str( gr2, 1 ) to ( cur_dir() + 'tmp3' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    Use ( cur_dir() + 'tmp2' ) new
    Go Top
    Do While !Eof()
      fl := .f.
      g1 := ret_gruppa_dvn( tmp2->rslt1, @fl )
      If Between( g1, 0, 4 )
        k := iif( fl, 1, 0 )
        g2 := ret_gruppa_dvn( tmp2->rslt2 )
        If !Between( g2, 1, 4 )
          g2 := 0
        Endif
        Select TMP3
        find ( Str( k, 1 ) + Str( g1, 1 ) + Str( g2, 1 ) )
        If !Found()
          Append Blank
          tmp3->et2 := k
          tmp3->gr1 := g1
          tmp3->gr2 := g2
        Endif
        tmp3->kol1++
        If g2 > 0
          tmp3->kol2++
        Endif
      Endif
      If tmp2->rslt1 == 316 .and. Empty( tmp2->rslt2 )
        kart->( dbGoto( tmp2->kod_k ) )
        AAdd( arr_316, AllTrim( kart->fio ) + ' д.р.' + full_date( kart->date_r ) )
      Endif
      If tmp2->rslt1 == 0 .and. !Empty( tmp2->rslt2 )
        kart->( dbGoto( tmp2->kod_k ) )
        AAdd( arr_ne, AllTrim( kart->fio ) + ' д.р.' + full_date( kart->date_r ) )
      Endif
      Select TMP2
      Skip
    Enddo
    Close databases
    //
    at := { glob_mo()[ _MO_SHORT_NAME ], '[ ' + CharRem( '~', mas1pmt()[ par ] ) + ' за вычетом отказов в оплате ]', arr_m[ 4 ] }
    print_shablon( 'svod_dvn', { arr_21, at, ar }, 'tmp1.txt', .f. )
    fp := FCreate( 'tmp2.txt' ) ; n_list := 1 ; tek_stroke := 0
    fl := f_error_dvn( 3, 60, 80 )
    StrFile( 'Лица прошедшие диспансеризацию/профосмотр, ранее не посещавшие учреждение более 2-х лет' + hb_eol(), 'tmp1.txt', .t. )
    StrFile( ' Диспансеризация == ' + lstr( kol_2_year_dvn ) + ' чел. из них 40-65 лет == ' +  lstr( kol_2_year_dvn_40 )  + ' чел.'  + hb_eol(), 'tmp1.txt', .t. )
    StrFile( ' Профосмотр      == ' + lstr( kol_2_year_prof ) + ' чел. из них 40-65 лет == ' +  lstr( kol_2_year_prof_40 )  + ' чел.'  +  + hb_eol(), 'tmp1.txt', .t. )
    FClose( fp )
    If fl
      StrFile( 'FF', 'tmp1.txt', .t. )
      feval( 'tmp2.txt', {| s| StrFile( s + hb_eol(), 'tmp1.txt', .t. ) } )
    Endif
    viewtext( 'tmp1.txt',,,,,,, 3 )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 08.07.24
Function inf_ydvn()

  Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}, is_all
  Local sh, HH := 53,  n_file := cur_dir() + 'gor_YDVN.txt', reg_print, arr_itog[ 20 ]
  Local t_rec, t_poisk, t_rezult, is_pesia
/*local arr_title := {;
'──────┬───────┬────────┬───────┬─────────┬──────┬──────┬──────┬──────┬──────┬───────┬──────┬──────┬──────┬──────┬──────┬──────┬───────', ;
'прошли│ в том │   в    │   в   │прошли за│      │      │      │      │      │направ-│прошли│      │      │      │      │      │впервые', ;
'1 этап│ числе │вечернее│субботу│  ОДИН   │   I  │  II  │  III │ IIIa │ IIIb │лено на│2 этап│   I  │  II  │  III │ IIIa │ IIIb │  взято', ;
'      │ село  │ время  │       │  день   │группа│группа│группа│группа│группа│ 2 этап│      │группа│группа│группа│группа│группа│ Д учет', ;
'──────┼───────┼────────┼───────┼─────────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼───────', ;
'   2  │  2.1  │   3    │   4   │    5    │   6  │   7  │   8  │   9  │  10  │   11  │  12  │  13  │  14  │  15  │  16  │  17  │   18  ', ;
'──────┴───────┴────────┴───────┴─────────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴───────'}*/
/*local arr_title := {;
'──────┬───────┬───────┬────────┬───────┬─────────┬──────┬──────┬──────┬──────┬──────┬───────┬──────┬──────┬──────┬──────┬──────┬──────┬───────', ;
'прошли│ старше│ в том │   в    │   в   │прошли за│      │      │      │      │      │направ-│прошли│      │      │      │      │      │впервые', ;
'1 этап│трудосп│ числе │вечернее│субботу│  ОДИН   │   I  │  II  │  III │ IIIa │ IIIb │лено на│2 этап│   I  │  II  │  III │ IIIa │ IIIb │  взято', ;
'      │ возр. │ село  │ время  │       │  день   │группа│группа│группа│группа│группа│ 2 этап│      │группа│группа│группа│группа│группа│ Д учет', ;
'──────┼───────┼───────┼────────┼───────┼─────────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼───────', ;
'   2  │  2.1  │  2.2  │   3    │   4   │    5    │   6  │   7  │   8  │   9  │  10  │   11  │  12  │  13  │  14  │  15  │  16  │  17  │   18  ', ;
'──────┴───────┴───────┴────────┴───────┴─────────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴───────'}
*/
  Local arr_title := { ;
    '──────────────────────┬─────────────────────────────────────────────────────────────┬───────┬──────┬──────────────────────────────────┬───────', ;
    '    Прошли 1-й этап   │                     Из графы 2                              │       │      │              Из Графы 2.1        │       ', ;
    '──────┬───────┬───────┼────────┬───────┬─────────┬──────┬──────┬──────┬──────┬──────┼       │      ┼──────┬──────┬──────┬──────┬──────┼       ', ;
    'прошли│ старше│ в том │   в    │   в   │прошли за│      │      │      │      │      │направ-│прошли│      │      │      │      │      │впервые', ;
    '1 этап│трудосп│ числе │вечернее│субботу│  ОДИН   │   I  │  II  │  III │ IIIa │ IIIb │лено на│2 этап│   I  │  II  │  III │ IIIa │ IIIb │  взято', ;
    '      │ возр. │ село  │ время  │       │  день   │группа│группа│группа│группа│группа│ 2 этап│      │группа│группа│группа│группа│группа│ Д учет', ;
    '──────┼───────┼───────┼────────┼───────┼─────────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼───────', ;
    '   2  │  2.1  │       │   3    │   4   │    5    │   6  │   7  │   8  │   9  │  10  │   11  │  12  │  13  │  14  │  15  │  16  │  17  │   18  ', ;
    '──────┴───────┴───────┴────────┴───────┴─────────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴───────' }

  Local title_zagol := { ;
    'Иные граждане', ;
    'с коморбидным фоном (наличие двух и более хронических неинфекционных заболеваний - 1 группа', ;
    'не более чем с одним сопутствующим хроническим неинфекционным заболеванием - 2 группа', ;
    'Итого' }
  Local mas_n_otchet[ 15 ]
  Private  pole_pervich, pole_1pervich, pole_dispans, pole_1dispans

  AFill( mas_n_otchet, 0 )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )

  For i := 1 To 5
    sk := lstr( i )
    // pole_pervich := 'mpervich'+sk
    pole_1pervich := 'm1pervich' + sk
    // pole_dispans := 'mdispans'+sk
    pole_1dispans := 'm1dispans' + sk
    // Private &pole_pervich := space(7)
    Private &pole_1pervich := 0
    // Private &pole_dispans := space(10)
    Private &pole_1dispans := 0
  Next

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + 'tmp', { { 'gruppa_1', 'N', 1, 0 }, ;// 1-группа 2- группа 3 - без группа
    { 'etap_1', 'N', 1, 0 }, ;  // Этап 1-й 2-й
    { 'sub_day', 'N', 1, 0 }, ; // Выполнение в субботу 0-нет 1-да
    { 'one_day', 'N', 1, 0 }, ; // Выполнение в 1 день 0-нет 1-да
    { 'gruppa', 'N', 3, 0 }, ;  // Группа здоровья 1, 2.3a, 3b
    { 'napr2', 'N', 1, 0 }, ;   // Направлен на 2-й этап 0-нет 1-да
    { 'selo', 'N', 1, 0 }, ;    // Село 0-нет 1-да
      { 'pensia', 'N', 1, 0 }, ;  // Пенсия 0-нет 1-да _pol=='М', 62, 57 по ЗАКОНУ за 2022 год - так в таблице
    { 'd_one', 'N', 1, 0 }, ;   // Впервые взято на Д-учет 0-нет 1-да
    { 'kod_k', 'N', 7, 0 } } )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    Use ( cur_dir() + 'tmp' ) new
    //
    Select HUMAN
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      // If Between( human->ishod, 401, 402 )
      If is_sluch_dispanser_covid( human->ishod )
        // read_arr_DVN_COVID(human->kod)
        // is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // признак села
        Select KART_
        Goto ( HUMAN->kod_k )
        Select KART
        Goto ( HUMAN->kod_k )
        Select HUMAN
        is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // признак села
        is_pensia := f_starshe_trudosp( kart->pol, kart->date_r, human->n_data, 3 ) // признак пенсионеров
        Select TMP
        Append Blank
        tmp->kod_k := HUMAN->kod_k
        If is_selo
          tmp->selo := 1
        Endif
        If is_pensia
          tmp->pensia := 1
        Endif
        If DoW( human->n_data ) == 7
          tmp->sub_day := 1
        Else
          tmp->sub_day := 0
        Endif
        If human->k_data == human->n_data
          tmp->one_day := 1
        Else
          tmp->one_day := 0
        Endif
        If human->ishod == 401
          tmp->etap_1 := 1
        Else
          tmp->etap_1 := 2
        Endif
        // выбираем услуги
        // larr := array(2, len(uslugiEtap_DVN_COVID(metap)))
        // arr_usl := {} // array(len(uslugiEtap_DVN_COVID(metap)))
        //
        arr := read_arr_dispans( human->kod )
        //
        For i := 1 To Len( arr )
          If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
            Do Case
            Case arr[ i, 1 ] == '5' .and. ValType( arr[ i, 2 ] ) == 'N'
              tmp->gruppa_1 := arr[ i, 2 ]
            Case eq_any( arr[ i, 1 ], '11', '12', '13', '14' )
              sk := Right( arr[ i, 1 ], 1 )
              pole_1pervich := 'm1pervich' + sk
              pole_1dispans := 'm1dispans' + sk
              If ValType( arr[ i, 2, 4 ] ) == 'N'
                &pole_1dispans := arr[ i, 2, 4 ]
              Endif
              If ValType( arr[ i, 2, 2 ] ) == 'N'
                &pole_1pervich := arr[ i, 2, 2 ]
              Endif
              if &pole_1dispans == 1 .and. &pole_1pervich == 1
                tmp->d_one := 1
              Endif
            Case arr[ i, 1 ] == '40'
              tmp_mas := arr[ i, 2 ]
              fl_t := .f.
              fl_t1 := .f.
              For jj := 1 To Len( tmp_mas )
                If AllTrim( tmp_mas[ jj ] )     == '70.8.2'     // 70- Проведение теста с 6 минутной ходьбой
                  fl_t := .t.
                  mas_n_otchet[ 3 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == 'A12.09.001' // 71- 'Проведение спирометрии или спирографии'
                  fl_t := .t.
                  mas_n_otchet[ 4 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == 'A12.09.005' // '69- Пульсооксиметрия'
                  fl_t := .t.
                  mas_n_otchet[ 2 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == 'A06.09.007' // 72- Рентгенография легких
                  fl_t := .t.
                  mas_n_otchet[ 5 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == 'B03.016.003'// 73- 'Общий (клинический) анализ крови развернутый'
                  fl_t := .t.
                  mas_n_otchet[ 6 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == 'B03.016.004'// 74- Анализ крови биохимический общетерапевтический
                  fl_t := .t.
                  mas_n_otchet[ 7 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == '70.8.3'     // 75 'Определение концентрации Д-димера в крови'
                  fl_t := .t.
                  mas_n_otchet[ 8 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == '70.8.52'    // 2 - 78 Дуплексное сканир-ие вен нижних конечностей
                  fl_t1 := .t.
                  mas_n_otchet[ 10 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == '70.8.51'    // 2 - 79 Проведение КТ легких
                  fl_t1 := .t. // mas_n_otchet[9] ++
                  mas_n_otchet[ 11 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == '70.8.50'    // 2 - 80 Проведение Эхокардиографии
                  fl_t1 := .t.
                  mas_n_otchet[ 12 ] ++
                Endif
              Next
              If fl_t
                mas_n_otchet[ 1 ] ++
              Endif
              If fl_t1
                mas_n_otchet[ 9 ] ++
              Endif
            Case arr[ i, 1 ] == '56'  // реабилитация
              If ValType( arr[ i, 2 ] ) == 'N'
                // mas_n_otchet[14] ++
              Elseif ValType( arr[ i, 2 ] ) == 'A'
                If arr[ i, 2 ][ 2 ] > 0
                  mas_n_otchet[ 14 ] ++
                Endif
              Endif
            Endcase
          Endif
        Next
        //
        If human_->RSLT_NEW == 317
          tmp->gruppa := 1
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 318
          tmp->gruppa := 2
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 355
          tmp->gruppa := 3
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 356
          tmp->gruppa := 4
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 352
          tmp->gruppa := 1
          tmp->napr2  := 1
        Elseif human_->RSLT_NEW == 353
          tmp->gruppa := 2
          tmp->napr2  := 1
        Elseif human_->RSLT_NEW == 357
          tmp->gruppa := 3
          tmp->napr2  := 1
        Else // if human_->RSLT_NEW == 358
          tmp->gruppa := 4
          tmp->napr2  := 1
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Select TMP
    Index On Str( kod_k, 7 ) + Str( etap_1, 1 )  To tmp_kk
    //
    Go Top
    Do While !Eof()
      If etap_1 == 2
        t_rec := tmp->( RecNo() )
        t_poisk := Str( tmp->kod_k, 7 ) + Str( 1, 1 )
        t_rezult := 0 // по умолчанию ИНЫЕ
        find( t_poisk )
        If Found()
          t_rezult := tmp->gruppa_1
        Endif
        Goto t_rec
        g_rlock( forever )
        tmp->gruppa_1  := t_rezult
        Unlock
      Endif
      Select TMP
      Skip
    Enddo
    // создаем отчет
    reg_print := f_reg_print( arr_title, @sh, 2 )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    // add_string('')
    //
    For II := 0 To 3
      AFill( arr_itog, 0 )
      Select TMP
      Go Top
      Do While !Eof()
        If iif( II == 3, .t., tmp->Gruppa_1 == II )
          If tmp->etap_1 == 1
            arr_itog[ 2 ] ++
            If tmp->sub_day == 1
              arr_itog[ 4 ] ++
            Endif
            If tmp->one_day == 1
              arr_itog[ 5 ] ++
            Endif
            If tmp->gruppa == 1
              arr_itog[ 6 ] ++
            Endif
            If tmp->gruppa == 2
              arr_itog[ 7 ] ++
            Endif
            If tmp->gruppa == 3
              arr_itog[ 8 ] ++
              arr_itog[ 9 ] ++
            Endif
            If tmp->gruppa == 4
              arr_itog[ 8 ] ++
              arr_itog[ 10 ] ++
            Endif
            If tmp->napr2 == 1
              arr_itog[ 11 ] ++
            Endif
            // доработка 28.09.2023
            If tmp->gruppa == 1 .and. tmp->pensia == 1
              arr_itog[ 13 ] ++
            Endif
            If tmp->gruppa == 2  .and. tmp->pensia == 1
              arr_itog[ 14 ] ++
            Endif
            If tmp->gruppa == 3 .and. tmp->pensia == 1
              arr_itog[ 15 ] ++
              arr_itog[ 16 ] ++
            Endif
            If tmp->gruppa == 4 .and. tmp->pensia == 1
              arr_itog[ 15 ] ++
              arr_itog[ 17 ] ++
            Endif
          Else
            arr_itog[ 12 ] ++
         /* if tmp->gruppa == 1
            arr_itog[13] ++
          endif
          if tmp->gruppa == 2
            arr_itog[14] ++
          endif
          if tmp->gruppa == 3
            arr_itog[15] ++
            arr_itog[16] ++
          endif
          if tmp->gruppa == 4
            arr_itog[15] ++
            arr_itog[17] ++
          endif
          */
          Endif
          If tmp->d_one == 1
            arr_itog[ 18 ] ++
          Endif
          If tmp->selo == 1
            arr_itog[ 19 ]++
          Endif
          If tmp->pensia == 1
            arr_itog[ 20 ]++
          Endif
        Endif
        Skip
      Enddo
      // Выводим
      add_string( Center( 'Лица, перенесшие COVID-19', sh ) )
      If II == 3
        add_string( Center( 'ИТОГО', sh ) )
      Else
        add_string( Center( title_zagol[ II + 1 ], sh ) )
      Endif
      add_string( Center( arr_m[ 4 ], sh ) )
      // add_string('')
      AEval( arr_title, {| x| add_string( x ) } )
      add_string( PadL( lstr( arr_itog[ 2 ] ), 6 ) + ;
        PadL( lstr( arr_itog[ 20 ] ), 8 ) + ;
        PadL( lstr( arr_itog[ 19 ] ), 8 ) + ;
        PadL( '', 8 ) + ;
        PadL( lstr( arr_itog[ 4 ] ), 9 ) + ;
        PadL( lstr( arr_itog[ 5 ] ), 10 ) + ;
        PadL( lstr( arr_itog[ 6 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 7 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 8 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 9 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 10 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 11 ] ), 8 ) + ;
        PadL( lstr( arr_itog[ 12 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 13 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 14 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 15 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 16 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 17 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 18 ] ), 8 ) )
      // add_string('')
      add_string( '' )
    Next
    If verify_ff( HH, .t., sh )
      // aeval(arr_title, {|x| add_string(x) } )
    Endif
    // endif
    add_string( 'Доля лиц с отклонениями  от нормы, выявленными у граждан, перенсеших новую коронавирусную инфекцию' )
    add_string( 'COVID-19 по результатам I этапа углубленной диспансеризации (доля от количества граждан, завершивших' )
    add_string( ' I этап углубленной диспансеризации и прошедших конкретное исследование, %)' )
    add_string( '' )
    add_string( '68- Всего лиц с отконениями I этап              = ' + PadL( lstr( mas_n_otchet[ 1 ] ), 9 ) + ' чел.' )
    add_string( '69- Сатурация                                   = ' + PadL( lstr( mas_n_otchet[ 2 ] ), 9 ) + ' чел.' )
    add_string( '70- Тест с 6 минутной ходьбой                   = ' + PadL( lstr( mas_n_otchet[ 3 ] ), 9 ) + ' чел.' )
    add_string( '71- Спирометрия                                 = ' + PadL( lstr( mas_n_otchet[ 4 ] ), 9 ) + ' чел.' )
    add_string( '72- Рентгенография легких                       = ' + PadL( lstr( mas_n_otchet[ 5 ] ), 9 ) + ' чел.' )
    add_string( '73- Общий анализ крови                          = ' + PadL( lstr( mas_n_otchet[ 6 ] ), 9 ) + ' чел.' )
    add_string( '74- Биохимический анализ крови                  = ' + PadL( lstr( mas_n_otchet[ 7 ] ), 9 ) + ' чел.' )
    add_string( '75- Определение концентрации Д-димера в крови   = ' + PadL( lstr( mas_n_otchet[ 8 ] ), 9 ) + ' чел.' )
    add_string( '' )
    add_string( 'Доля лиц с отклонениями  от нормы, выявленными у граждан, перенсеших новую коронавирусную инфекцию ' )
    add_string( 'COVID-19 по результатам II этапа углубленной диспансеризации (доля от количества граждан, завершивших ' )
    add_string( ' II этап углубленной диспансеризации и прошедших конкретное исследование, %)' )
    add_string( '' )
    add_string( '77- Всего лиц с отконениями II этап             = ' + PadL( lstr( mas_n_otchet[ 9 ] ), 9 ) + ' чел.' )
    add_string( '78- Дуплексное сканир-ие вен нижних конечностей = ' + PadL( lstr( mas_n_otchet[ 10 ] ), 9 ) + ' чел.' )
    add_string( '79- Проведение КТ легких                        = ' + PadL( lstr( mas_n_otchet[ 11 ] ), 9 ) + ' чел.' )
    add_string( '80- Проведение Эхокардиографии                  = ' + PadL( lstr( mas_n_otchet[ 12 ] ), 9 ) + ' чел.' )
    add_string( '' )
    add_string( 'Число граждан, взятых на диспансерное наблюдение и направленных на реабилитацию по' )
    add_string( 'результатам углубленной диспансеризации  (абс.ч.)' )
    add_string( '' )
    add_string( '83- Всего подлежат Диспансерному наблюдению     = ' + PadL( lstr( arr_itog[ 18 ] ), 9 ) + ' чел.' )
    add_string( '85- Направлен на реабилитацию                   = ' + PadL( lstr( mas_n_otchet[ 14 ] ), 9 ) + ' чел.' )
    Close databases
    FClose( fp )
    Private yes_albom := .t.
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  rest_box( buf )
  Close databases

  Return Nil


// 27.04.20
Function f1_f21_inf_dvn()

  Local sumr := 0, m1GRUPPA, fl2 := .f., is_selo

  Select TMP2
  Append Blank
  tmp2->kod_k := tmp->kod_k
  // диспансеризация I этап
  If Empty( tmp->kod1h )
    // нет 1 этапа, но есть второй
  Else
    human->( dbGoto( tmp->kod1h ) )
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
    If Between( m1gruppa, 0, 4 )
      tmp2->rslt1 := human_->RSLT_NEW
      If m1gruppa == 0
        fl2 := .t. // направлен на 2 этап
      Endif
      Private m1veteran := 0, m1mobilbr := 0
      read_arr_dvn( human->kod, .f. )
      arr_21[ 3 ] ++
      If m1veteran == 1
        arr_21[ 4 ] ++
      Endif
      If m1mobilbr == 1
        arr_21[ 5 ] ++
      Endif
      If mdvozrast == 65
        arr_21[ 32 ] ++
      Elseif mdvozrast > 65
        arr_21[ 33 ] ++
      Endif
      If Between( m1gruppa, 1, 4 )
        arr_21[ 5 + m1gruppa ] ++
      Endif
      If ( is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ) )
        arr_21[ 47 ] ++
      Endif
      If f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
        arr_21[ 19 ] ++
        If is_selo
          arr_21[ 20 ] ++
        Endif
        If Between( m1gruppa, 1, 4 )
          arr_21[ 42 + m1gruppa ] ++
        Endif
      Endif
      f2_f21_inf_dvn( 1 )
      If human->schet > 0
        Select SCHET_
        Goto ( human->schet )
        If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
          arr_21[ 10 ] ++
          Select RPDSH
          find ( Str( human->kod, 7 ) )
          Do While rpdsh->KOD_H == human->kod .and. !Eof()
            sumr += rpdsh->S_SL
            Skip
          Enddo
          If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // полностью оплачен
            arr_21[ 11 ] ++
          Endif
        Endif
      Endif
    Else
      // почему-то неправильная группа
    Endif
  Endif
  If fl2 // направлен на 2 этап
    arr_21[ 12 ]++    // направлен на 2 этап
  Endif
  If !Empty( tmp->kod2h ) // диспансеризация II этап
    human->( dbGoto( tmp->kod2h ) )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa, 1, 4 )
      tmp2->rslt2 := human_->RSLT_NEW
      If Empty( tmp2->rslt1 )
      Else
        arr_21[ 13 ] ++
        If !fl2  // не был направлен, но всё равно прошёл
          arr_21[ 12 ]++    // направлен на 2 этап
        Endif
      Endif
    Else
      // почему-то неправильная группа
    Endif
  Endif

  Return Nil

// 07.04.22
Function f2_f21_inf_dvn( par )

  Local is_selo, i, j, k, k1 := 9, fl2 := .f., ar[ 21 ], arr11[ 15 ], arr12[ 43 ], au := {}, fl_pens
  Private arr_otklon := {}, arr_usl_otkaz := {}, ;
    M1RAB_NERAB := human->RAB_NERAB, m1veteran := 0, m1mobilbr := 0, ;
    m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0, ;
    m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
    mholest := 0, mglukoza := 0, ;
    m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
    m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0, ;
    m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0, ;
    m1spec_na := 0, m1sank_na := 0, ;
    pole_diag, pole_1pervich, pole_1stadia, pole_1dispans, ;
    mWEIGHT := 0, mHEIGHT := 0

  AFill( ar, 0 ) ; ar[ 2 ] := 1
  AFill( arr11, 0 )
  AFill( arr12, 0 )
  If kart_->invalid > 0
    arr_21[ 21 ] ++
  Endif
  If par == 1
    If mdvozrast < 35
      k1 := 1
    Elseif mdvozrast < 40
      k1 := 2
    Elseif mdvozrast < 55
      k1 := 3
    Elseif mdvozrast < 60
      k1 := 4
    Elseif mdvozrast < 65
      k1 := 5
    Elseif mdvozrast < 75
      k1 := 6
    Else
      k1 := 7
    Endif
    // g5
  Endif
  If human->n_data == human->k_data // за один день
    ar[ 5 ] := 1
  Endif
  If ( is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ) )
    ar[ 6 ] := 1
  Endif
  If DoW( human->k_data ) == 7 // суббота
    ar[ 4 ] := 1
    If is_selo
      ar[ 8 ] := 1
    Endif
  Endif
  fl_pens := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
  For i := 1 To 5
    pole_diag := 'mdiag' + lstr( i )
    pole_1pervich := 'm1pervich' + lstr( i )
    pole_1stadia := 'm1stadia' + lstr( i )
    pole_1dispans := 'm1dispans' + lstr( i )
    Private &pole_diag := Space( 6 )
    Private &pole_1pervich := 0
    Private &pole_1stadia := 0
    Private &pole_1dispans := 0
  Next
  read_arr_dvn( human->kod )
  m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
  If Between( m1gruppa, 0, 4 )
    If m1gruppa == 0
      fl2 := .t. // направлен на 2 этап
    Endif
  Endif
  If !Empty( tmp->kod2h )
    fl2 := .t. // прошел 2 этап
  Endif
  Select HU
  find ( Str( tmp->kod1h, 7 ) )
  Do While hu->kod == tmp->kod1h .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
      lshifr := usl->shifr
    Endif
    AAdd( au, { AllTrim( lshifr ), ;
      hu_->PROFIL, ;
      0, ;
      c4tod( hu->date_u );
      } )
    Select HU
    Skip
  Enddo
  For k := 1 To Len( au )
    If AScan( arr_otklon, au[ k, 1 ] ) > 0
      au[ k, 3 ] := 1 // отклонения в исследовании
    Endif
    If au[ k, 1 ] == '7.57.3'
      arr12[ 1 ] := arr12[ 2 ] := 1
      arr12[ 3 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 4 ] := 1
      Endif
    Elseif au[ k, 1 ] == '4.8.4'
      arr12[ 12 ] := arr12[ 13 ] := 1
      arr12[ 14 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 15 ] := 1
      Endif
    Elseif eq_any( au[ k, 1 ], '4.20.1', '4.20.2' )
      arr12[ 25 ] := arr12[ 26 ] := 1
      arr12[ 27 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 28 ] := 1
      Endif
      // elseif eq_any(au[k, 1],'56.1.15','56.1.20','56.1.21','56.1.721')
      // arr11[10] := arr11[11] := 1
      // elseif au[k, 1] == '56.1.723'
      // arr11[13] := arr11[14] := 1
    Endif
  Next
  // диспансеризация II этап
  If !Empty( tmp->kod2h )
    human->( dbGoto( tmp->kod2h ) )
    m1GRUPPA2 := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa2, 1, 4 ) // точно прошёл 2 этап
      read_arr_dvn( human->kod ) // перечитать диагнозы и т.п.
    Endif
    au := {}
    Select HU
    find ( Str( tmp->kod1h, 7 ) )
    Do While hu->kod == tmp->kod1h .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      AAdd( au, { AllTrim( lshifr ), ;
        hu_->PROFIL, ;
        0, ;
        c4tod( hu->date_u );
        } )
      Select HU
      Skip
    Enddo
    For k := 1 To Len( au )
      If AScan( arr_otklon, au[ k, 1 ] ) > 0
        au[ k, 3 ] := 1 // отклонения в исследовании
      Endif
      If eq_any( au[ k, 1 ], '10.6.10', '10.6.710' )
        arr12[ 16 ] := 1
      Elseif eq_any( au[ k, 1 ], '10.4.1', '10.4.701' )
        arr12[ 17 ] := 1
      Elseif eq_any( au[ k, 1 ], '56.1.15', '56.1.20', '56.1.21', '56.1.721' )
        arr11[ 10 ] := arr11[ 11 ] := 1
      Elseif au[ k, 1 ] == '56.1.723'
        arr11[ 13 ] := arr11[ 14 ] := 1
      Endif
    Next
  Endif
  For i := 1 To 5
    pole_diag := 'mdiag' + lstr( i )
    pole_1pervich := 'm1pervich' + lstr( i )
    pole_1stadia := 'm1stadia' + lstr( i )
    pole_1dispans := 'm1dispans' + lstr( i )
    if &pole_1pervich == 1 .and. &pole_1dispans == 1
      arr11[ 1 ] := 1
    Endif
    If !( Left( &pole_diag, 1 ) == 'A' .or. Left( &pole_diag, 1 ) == 'B' ) .and. &pole_1pervich == 1 // неинфекционные заболевания уст.впервые
      ar[ 9 ] := 1
      ar[ 10 ] ++
      If Left( &pole_diag, 1 ) == 'I' // болезни системы кровообращения
        ar[ 11 ] := 1
      Elseif Left( &pole_diag, 1 ) == 'J' // болезни органов дыхания
        ar[ 17 ] := 1
      Elseif Left( &pole_diag, 1 ) == 'K' // болезни органов пищеварения
        ar[ 18 ] := 1
      Endif
      If Left( &pole_diag, 1 ) == 'C' .or. Between( Left( &pole_diag, 3 ), 'D00', 'D09' ) // ЗНО
        ar[ 12 ] := 1
        if &pole_1stadia < 3 // 1 и 2 стадия
          ar[ 13 ] := 1
        Endif
        arr11[ 5 ] := 1
        If Between( &pole_1stadia, 1, 4 )
          arr11[ 5 + &pole_1stadia ] := 1
        Endif
        If Left( &pole_diag, 3 ) == 'C50'
          arr12[ 6 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 7 + &pole_1stadia ] := 1
          Endif
        Elseif Left( &pole_diag, 3 ) == 'D05'
          arr12[ 6 ] := 1
          arr12[ 7 ] := 1 // in situ
        Endif
        If eq_any( Left( &pole_diag, 3 ), 'C18', 'C19', 'C20', 'C21' )
          arr12[ 19 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 20 + &pole_1stadia ] := 1
          Endif
        Elseif eq_any( Left( &pole_diag, 5 ), 'D01.0', 'D01.1', 'D01.2', 'D01.3' )
          arr12[ 19 ] := 1
          arr12[ 20 ] := 1 // in situ
        Endif
        If Left( &pole_diag, 3 ) == 'C53'
          arr12[ 30 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 31 + &pole_1stadia ] := 1
          Endif
        Elseif Left( &pole_diag, 3 ) == 'D06'
          arr12[ 30 ] := 1
          arr12[ 31 ] := 1 // in situ
        Endif
        If eq_any( Left( &pole_diag, 3 ), 'C00', 'C43', 'C44' ) .or. Left( &pole_diag, 5 ) == 'C14.8'
          arr12[ 36 ] := 1
          arr12[ 38 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 39 + &pole_1stadia ] := 1
          Endif
        Elseif eq_any( Left( &pole_diag, 3 ), 'D03', 'D04' ) .or. Left( &pole_diag, 5 ) == 'D00.0'
          arr12[ 36 ] := 1
          arr12[ 38 ] := 1
          arr12[ 39 ] := 1
        Endif
      Endif
      If Between( Left( &pole_diag, 3 ), 'E10', 'E14' ) // сахарный диабет
        ar[ 14 ] := 1
        If Left( &pole_diag, 3 ) == 'E10' // I стадия
          ar[ 15 ] := 1
        Endif
      Endif
      If eq_any( Left( &pole_diag, 3 ), 'H40', 'H42' ) .or. Left( &pole_diag, 5 ) == 'Q15.0' // глаукома
        ar[ 16 ] := 1
      Endif
      if &pole_1dispans == 1
        ar[ 19 ] := 1
        If is_selo
          ar[ 21 ] := 1
        Endif
      Endif
      If .f. // 1-лечение назначено
        ar[ 20 ] := 1 // ?? было начато лечение
      Endif
    Endif
  Next
  pole := 'tmp1->g' + lstr( k1 )
  Select TMP1
  For i := 1 To Len( ar )
    If ar[ i ] > 0
      find ( Str( i, 2 ) )
      &pole := &pole + ar[ i ]
      If k1 < 8 .and. fl_pens
        tmp1->g8 += ar[ i ]
      Endif
    Endif
  Next
  Select TMP11
  For i := 1 To Len( arr11 )
    If arr11[ i ] > 0
      find ( Str( i, 2 ) )
      tmp11->g3 += arr11[ i ]
    Endif
  Next
  Select TMP12
  For i := 1 To Len( arr12 )
    If arr12[ i ] > 0
      find ( Str( i, 2 ) )
      tmp12->g3 += arr12[ i ]
    Endif
  Next

  Return Nil

// 20.10.16 Индикаторы мониторинга диспансеризации взрослых
Function f22_inf_dvn()

  Static group_ini := 'f22_inf_DVN'
  Static as := { ;
    { 1, 0, 0, 'Общее число граждан, подлежащих диспансеризации в текущем году' }, ;
    { 2, 0, 0, 'Количество граждан от числа подлежащих диспансеризации в текущем году, прошедших 1-й этап диспансеризации за отчетный период' }, ;
    { 3, 0, 0, 'Количество граждан от числа подлежащих диспансеризации в текущем году, прошедших 2-й этап диспансеризации за отчетный период' }, ;
    { 4, 0, 0, 'Количество граждан от числа подлежащих диспансеризации в текущем году, полностью завершивших диспансеризацию за отчетный период, из них:' }, ;
    { 4, 1, 0, 'имеют I группу здоровья' }, ;
    { 4, 2, 0, 'имеют II группу здоровья' }, ;
    { 4, 3, 0, 'имеют IIIа группу здоровья' }, ;
    { 4, 4, 0, 'имеют IIIб группу здоровья' }, ;
    { 5, 0, 0, 'Количество граждан с впервые выявленными хроническими неинфекционными заболеваниями, из них:' }, ;
    { 5, 1, 0, 'со стенокардией' }, ;
    { 5, 2, 0, 'с хронической ишемической болезнью сердца' }, ;
    { 5, 3, 0, 'с артериальной гипертонией' }, ;
    { 5, 4, 0, 'со стенозом сонных артерий >50%' }, ;
    { 5, 5, 0, 'с острым нарушением мозгового кровообращения в анамнезе' }, ;
    { 5, 6, 0, 'с подозрением на злокачественное новообразование желудка по результатам фиброгастроскопии' }, ;
    { 5, 6, 1, 'на ранней стадии' }, ;
    { 5, 7, 0, 'с подозрением на злокачественным новообразованием матки и ее придатков' }, ;
    { 5, 7, 1, 'на ранней стадии' }, ;
    { 5, 8, 0, 'с подозрением на злокачественное новообразование простаты по данным осмотра врача-хирурга (уролога) и теста на простатспецифический антиген' }, ;
    { 5, 8, 1, 'на ранней стадии' }, ;
    { 5, 9, 0, 'с подозрением на злокачественное новообразование грудной железы по данным маммографии' }, ;
    { 5, 9, 1, 'на ранней стадии' }, ;
    { 5, 10, 0, 'с подозрением на колоректальный рак по данным ректоромано- и колоноскопии' }, ;
    { 5, 10, 1, 'на ранней стадии' }, ;
    { 5, 11, 0, 'с подозрением на злокачественные заболевания других локализаций' }, ;
    { 5, 11, 1, 'на ранней стадии' }, ;
    { 5, 12, 0, 'с сахарным диабетом' }, ;
    { 6, 0, 0, 'Количество граждан с впервые выявленным туберкулезом легких' }, ;
    { 7, 0, 0, 'Количество граждан с впервые выявленной глаукомой, из них:' }, ;
    { 7, 0, 1, 'на ранней стадии' }, ;
    { 8, 0, 0, 'Количество граждан с впервые выявленными заболеваниями других органов и систем за отчетный период' }, ;
    { 9, 0, 0, 'Количество граждан, имеющих факторы риска хронических неинфекционных заболеваний за отчетный период, из них:' }, ;
    { 9, 1, 0, 'потребляют табак (курение)' }, ;
    { 9, 2, 0, 'повышенное АД' }, ;
    { 9, 3, 0, 'избыточная масса тела' }, ;
    { 9, 4, 0, 'ожирение' }, ;
    { 9, 5, 0, 'гиперхолестеринемия, дислипидемия' }, ;
    { 9, 6, 0, 'гипергликемия' }, ;
    { 9, 7, 0, 'недостаточная физическая активность' }, ;
    { 9, 8, 0, 'нерациональное питание' }, ;
    { 9, 9, 0, 'подозрением на пагубное потребление алкоголя' }, ;
    { 9, 10, 0, 'имеющие 2 фактора риска и более' }, ;
    { 10, 0, 0, 'Количество граждан с подозрением на зависимость от алкоголя, наркотиков и психотропных средств, из них:' }, ;
    { 11, 0, 1, 'число граждан, направленных к психиатру-наркологу' }, ;
    { 12, 0, 0, 'Количество граждан 2-й группы здоровья, прошедших углубленное профилактическое консультирование' }, ;
    { 13, 0, 0, 'Количество граждан 2-й группы здоровья, прошедших групповое профилактическое консультирование' }, ;
    { 14, 0, 0, 'Количество граждан 3-й группы здоровья, прошедших углубленное профилактическое консультирование' }, ;
    { 15, 0, 0, 'Количество граждан 3-й группы здоровья, прошедших групповое профилактическое консультирование' };
    }
  Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    Private mk1, mispoln, mtel_isp
    ar := getinisect( tmp_ini(), group_ini )
    mk1 := Int( Val( a2default( ar, 'mk1', '0' ) ) )
    mispoln := PadR( a2default( ar, 'mispoln', '' ), 20 )
    mtel_isp := PadR( a2default( ar, 'mtel_isp', '' ), 20 )
    s := ' \' + ;
      '      Общее число граждан, подлежащих диспансеризации @          \' + ;
      '      Фамилия и инициалы исполнителя @                           \' + ;
      '      Телефон исполнителя            @                           \' + ;
      ' \'
    displbox( s, ;
      , ;                   // цвет окна (умолч. - cDataCGet)
      { 'mk1', 'mispoln', 'mtel_isp' }, ; // массив Private-переменных для редактирования
    { '999999',, }, ; // массив Picture для редактирования
    17 )
    If LastKey() != K_ESC
      setinisect( tmp_ini(), group_ini, { { 'mk1', mk1 }, ;
        { 'mispoln', mispoln }, ;
        { 'mtel_isp', mtel_isp };
        } )
      mywait()
      If f0_inf_dvn( arr_m, .f. )
        mywait( 'Сбор статистики' )
        delfrfiles()
        dbCreate( fr_data, { ;
          { 'nomer', 'C', 5, 0 }, ;
          { 'nn1', 'N', 2, 0 }, ;
          { 'nn2', 'N', 2, 0 }, ;
          { 'nn3', 'N', 2, 0 }, ;
          { 'name', 'C', 250, 0 }, ;
          { 'v1', 'N', 6, 0 }, ;
          { 'v2', 'N', 6, 0 } } )
        Use ( fr_data ) New Alias FRD
        For i := 1 To Len( as )
          Append Blank
          If !Empty( as[ i, 1 ] ) .and. Empty( as[ i, 2 ] )
            frd->nomer := lstr( as[ i, 1 ] ) + '.'
          Endif
          frd->nn1 := as[ i, 1 ]
          frd->nn2 := as[ i, 2 ]
          frd->nn3 := as[ i, 3 ]
          frd->name := iif( !Empty( as[ i, 1 ] ), '', Space( 10 ) ) + ;
            iif( Empty( as[ i, 2 ] ), '', Space( 10 ) ) + ;
            iif( Empty( as[ i, 3 ] ), '', Space( 10 ) ) + ;
            as[ i, 4 ]
          If i == 1
            frd->v1 := frd->v2 := mk1
          Endif
        Next
        Index On Str( nn1, 2 ) + Str( nn2, 2 ) + Str( nn3, 2 ) to ( cur_dir() + 'tmp_frd' )
        //
        r_use( dir_server() + 'human_',, 'HUMAN_' )
        r_use( dir_server() + 'human',, 'HUMAN' )
        Set Relation To RecNo() into HUMAN_
        r_use( dir_server() + 'schet_',, 'SCHET_' )
        ii := 0
        Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmp' ) new
        Go Top
        Do While !Eof()
          @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
          If !emptyall( tmp->kod1h, tmp->kod2h ) // только диспансеризация
            f1_f22_inf_dvn()
          Endif
          Select TMP
          Skip
        Enddo
        Close databases
        r_use( dir_server() + 'organiz',, 'ORG' )
        dbCreate( fr_titl, { { 'name', 'C', 130, 0 }, ;
          { 'period', 'C', 100, 0 }, ;
          { 'ispoln', 'C', 100, 0 }, ;
          { 'glavn', 'C', 100, 0 } } )
        Use ( fr_titl ) New Alias FRT
        Append Blank
        frt->name := glob_mo()[ _MO_SHORT_NAME ]
        frt->period := arr_m[ 4 ]
        frt->glavn :=  'Главный врач __________________ ' + fam_i_o( org->ruk )
        frt->ispoln := 'исполнитель: ' + AllTrim( mispoln ) + ' __________________ тел.' + AllTrim( mtel_isp )
        //
        ar := {}
        AAdd( ar, { 2, 3, Month( arr_m[ 6 ] + 1 ) } )
        AAdd( ar, { 2, 4, '.' + lstr( Year( arr_m[ 6 ] + 1 ) ) } )
        Use ( fr_data ) New Alias FRD
        For i := 1 To Len( as )
          Goto ( i )
          If i != 4
            AAdd( ar, { 8 + i, 3, frd->v1 } )
          Endif
          If !eq_any( i, 1, 4 )
            AAdd( ar, { 8 + i, 5, frd->v2 } )
          Endif
        Next
        AAdd( ar, { 59, 1, frt->glavn } )
        AAdd( ar, { 61, 1, frt->ispoln } )
        AAdd( arr_excel, { 'форма отчета', AClone( ar ) } )
        Close databases
        call_fr( 'mo_dvnMZ' )
      Endif
    Endif
  Endif

  Return Nil

// 23.09.15
Function f1_f22_inf_dvn() // сводная информация

  Local i, ar := {}, fl_reg1 := .f., fl_reg2 := .f., is_d := .f., is_pr := .f., ;
    k5 := 0, k9 := 0, m1gruppa, fl

  // диспансеризация I этап
  If Empty( tmp->kod1h )
    // нет 1 этапа, но есть второй
  Else
    human->( dbGoto( tmp->kod1h ) )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If !Between( m1gruppa, 0, 4 )
      Return Nil
    Endif
    Private m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
      mholest := 0, mglukoza := 0, ;
      m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
      m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
      pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
    For i := 1 To 5
      pole_diag := 'mdiag' + lstr( i )
      pole_1stadia := 'm1stadia' + lstr( i )
      pole_1pervich := 'm1pervich' + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_1stadia := 0
      Private &pole_1pervich := 0
    Next
    read_arr_dvn( human->kod )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
    If human->schet > 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl_reg1 := .t.
      Endif
    Endif
    //
    AAdd( ar, { 2, 0, 0, fl_reg1 } )
    If m1kurenie == 1
      AAdd( ar, { 9, 1, 0, fl_reg1 } ) ; ++k9
    Endif
    If mad1 > 140 .and. mad2 > 90
      AAdd( ar, { 9, 2, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1tip_mas == 3
      AAdd( ar, { 9, 3, 0, fl_reg1 } ) ; ++k9
    Elseif m1tip_mas > 3
      AAdd( ar, { 9, 4, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1holestdn == 1 .or. mholest > 5
      AAdd( ar, { 9, 5, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1glukozadn == 1 .or. mglukoza > 6.1
      AAdd( ar, { 9, 6, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1fiz_akt == 1
      AAdd( ar, { 9, 7, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1ner_pit == 1
      AAdd( ar, { 9, 8, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1riskalk == 1
      AAdd( ar, { 9, 9, 0, fl_reg1 } ) ; ++k9
    Endif
    If k9 > 1
      AAdd( ar, { 9, 10, 0, fl_reg1 } )
    Endif
    If k9 > 0
      AAdd( ar, { 9, 0, 0, fl_reg1 } )
    Endif
    If m1pod_alk == 1
      AAdd( ar, { 10, 0, 0, fl_reg1 } )
      If m1psih_na == 1
        AAdd( ar, { 11, 0, 1, fl_reg1 } )
      Endif
    Endif
    If !Empty( tmp->kod2h ) // диспансеризация II этап
      human->( dbGoto( tmp->kod2h ) )
      i := ret_gruppa_dvn( human_->RSLT_NEW )
      If Between( i, 1, 4 )
        m1gruppa := i
        If human->schet > 0
          Select SCHET_
          Goto ( human->schet )
          If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
            fl_reg2 := .t.
          Endif
        Endif
        AAdd( ar, { 3, 0, 0, fl_reg2 } )
        If i == 2
          If m1prof_ko == 0
            AAdd( ar, { 12, 0, 0, fl_reg2 } )
          Elseif m1prof_ko == 1
            AAdd( ar, { 13, 0, 0, fl_reg2 } )
          Endif
        Elseif eq_any( i, 3, 4 )
          If m1prof_ko == 0
            AAdd( ar, { 14, 0, 0, fl_reg2 } )
          Elseif m1prof_ko == 1
            AAdd( ar, { 15, 0, 0, fl_reg2 } )
          Endif
        Endif
      Else // если что-то не так со вторым этапом
        human->( dbGoto( tmp->kod1h ) ) // вернуться на 1 этап
      Endif
    Endif
    If Between( m1gruppa, 1, 4 )
      fl := fl_reg1 .or. fl_reg2
      AAdd( ar, { 4, 0, 0, fl } )
      AAdd( ar, { 4, m1gruppa, 0, fl } )
      For i := 1 To 5
        pole_diag := 'mdiag' + lstr( i )
        pole_1stadia := 'm1stadia' + lstr( i )
        pole_1pervich := 'm1pervich' + lstr( i )
        If !Empty( &pole_diag ) .and. &pole_1pervich == 1
          is_d := .t.
          If Left( &pole_diag, 3 ) == 'I20'
            AAdd( ar, { 5, 1, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 3 ) == 'I25'
            AAdd( ar, { 5, 2, 0, fl } ) ; ++k5
          Elseif eq_any( Left( &pole_diag, 3 ), 'I10', 'I11', 'I12', 'I13', 'I15' )
            AAdd( ar, { 5, 3, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 5 ) == 'I65.2'
            AAdd( ar, { 5, 4, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 3 ) == 'I66'
            AAdd( ar, { 5, 5, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 1 ) == 'C'
            If Left( &pole_diag, 3 ) == 'C16'
              AAdd( ar, { 5, 6, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 6, 1, fl } )
              Endif
            Elseif eq_any( Left( &pole_diag, 3 ), 'C53', 'C54', 'C55' )
              AAdd( ar, { 5, 7, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 7, 1, fl } )
              Endif
            Elseif Left( &pole_diag, 3 ) == 'C61'
              AAdd( ar, { 5, 8, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 8, 1, fl } )
              Endif
            Elseif Left( &pole_diag, 3 ) == 'C50'
              AAdd( ar, { 5, 9, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 9, 1, fl } )
              Endif
            Elseif eq_any( Left( &pole_diag, 3 ), 'C17', 'C18', 'C19', 'C20', 'C21' )
              AAdd( ar, { 5, 10, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 10, 1, fl } )
              Endif
            Else
              AAdd( ar, { 5, 11, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 11, 1, fl } )
              Endif
            Endif
          Elseif eq_any( Left( &pole_diag, 3 ), 'E10', 'E11', 'E12', 'E13', 'E14' )
            AAdd( ar, { 5, 12, 0, fl } ) ; ++k5
          Elseif eq_any( Left( &pole_diag, 3 ), 'A15', 'A16' )
            AAdd( ar, { 6, 0, 0, fl } ) ; is_pr := .t.
          Elseif Left( &pole_diag, 3 ) == 'H40'
            AAdd( ar, { 7, 0, 0, fl } ) ; is_pr := .t.
            if &pole_1stadia == 1
              AAdd( ar, { 7, 1, 1, fl } )
            Endif
          Endif
        Endif
      Next
      If k5 > 0
        AAdd( ar, { 5, 0, 0, fl } )
      Endif
      If is_d .and. Empty( k5 ) .and. !is_pr
        AAdd( ar, { 8, 0, 0, fl } )
      Endif
    Endif
  Endif
  If !Empty( ar )
    Select FRD
    For i := 1 To Len( ar )
      find ( Str( ar[ i, 1 ], 2 ) + Str( ar[ i, 2 ], 2 ) + Str( ar[ i, 3 ], 2 ) )
      If Found()
        frd->v1++
        If ar[ i, 4 ]
          frd->v2++
        Endif
      Endif
    Next
  Endif

  Return Nil

// 27.09.24 список пациентов
Function f2_inf_dvn( is_schet, par )

  Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, as := {}, ;
    a, sh, HH := 53, n, n_file := cur_dir() + 'spis_dvn.txt', reg_print
  Private ppar := par, p_is_schet := is_schet

  If par > 1
    ppar--
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != Nil .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    If f0_inf_dvn( arr_m, eq_any( is_schet, 2, 3 ), is_schet == 3 )
      adbf := { ;
        { 'nomer',   'N',     6,     0 }, ;
        { 'KOD',   'N',     7,     0 }, ; // код (номер записи)
        { 'KOD_K',   'N',     7,     0 }, ; // код по картотеке
        { 'FIO',   'C',    50,     0 }, ; // Ф.И.О. больного
        { 'DATE_R',   'D',     8,     0 }, ; // дата рождения больного
        { 'N_DATA',   'D',     8,     0 }, ; // дата начала лечения
        { 'K_DATA',   'D',     8,     0 }, ; // дата окончания лечения
        { 'sroki',   'C',    35,     0 }, ; // сроки лечения
        { 'CENA_1',   'N',    10,     2 }, ; // оплачиваемая сумма лечения
        { 'KOD_DIAG',   'C',     5,     0 }, ; // шифр 1-ой осн.болезни
        { 'etap',   'N',     1,     0 }, ; //
        { 'gruppa',   'N',     1,     0 }, ; //
        { 'vrach',   'C',    15,     0 }, ; // врач
        { 'DATA_O',   'C',    35,     0 } ; // сроки другого этапа
      }
      ret_arrays_disp()
      Private count_dvn_arr_usl18 := Len( dvn_arr_usl18() )
      Private count_dvn_arr_umolch18 := Len( dvn_arr_umolch18() )
      ret_arrays_disp()
      For i := 1 To Max( count_dvn_arr_usl18, count_dvn_arr_usl )
        AAdd( adbf, { 'd_' + lstr( i ), 'C', 24, 0 } )
      Next
      For i := 1 To Max( count_dvn_arr_umolch18, count_dvn_arr_umolch )
        AAdd( adbf, { 'du_' + lstr( i ), 'C', 8, 0 } )
      Next
      AAdd( adbf, { 'fl_2018', 'L', 1, 0 } )
      AAdd( adbf, { 'd_zs', 'C', 8, 0 } )
      dbCreate( cur_dir() + 'tmpfio', adbf )
      Use ( cur_dir() + 'tmpfio' ) New Alias TF
      r_use( dir_server() + 'uslugi',, 'USL' )
      use_base( 'human_u' )
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human',, 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + 'mo_pers',, 'PERS' )
      r_use( dir_server() + 'schet_',, 'SCHET_' )
      Use ( cur_dir() + 'tmp' ) new
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( tmp->( RecNo() ) / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
        Do Case
        Case par == 1
          If tmp->kod1h > 0
            f2_inf_dvn_svod( 1, tmp->kod1h )
          Endif
        Case par == 2
          If tmp->kod1h > 0 .and. tmp->kod2h == 0
            f2_inf_dvn_svod( 0, tmp->kod1h )
          Endif
        Case par == 3
          If tmp->kod1h > 0 .and. tmp->kod2h > 0
            f2_inf_dvn_svod( 2, tmp->kod2h )
          Endif
        Case par == 4
          If tmp->kod3h > 0
            f2_inf_dvn_svod( 3, tmp->kod3h )
          Endif
        Endcase
        Select TMP
        Skip
      Enddo
      Close databases
      mywait()
      at := { ;
        { 'Внутриглазное давление', { { 1, .t., 1 }, { 1, .f., 1 } }, 0 }, ;
        { 'Кровь на общий холестерин', { { 1, .t., 2 }, { 1, .f., 2 }, { 3, .t., 2 }, { 3, .f., 2 } }, 0 }, ;
        { 'Уровень глюкозы в крови', { { 1, .t., 3 }, { 1, .f., 3 }, { 3, .t., 3 }, { 3, .f., 3 } }, 0 }, ;
        { 'Клинический анализ мочи', { { 1, .t., 4 }, { 1, .f., 4 } }, 0 }, ;
        { 'Анализ крови (3 показателя)', { { 1, .t., 5 }, { 1, .f., 5 }, { 3, .t., 5 }, { 3, .f., 5 } }, 0 }, ;
        { 'Анализ крови (развёрнутый)', { { 1, .t., 6 }, { 1, .f., 6 } }, 0 }, ;
        { 'Биохимический анализ крови', { { 1, .t., 7 }, { 1, .f., 7 } }, 0 }, ;
        { 'Кровь на простат-специфический антиген', { { 1, .t., 8 }, { 2, .f., 21 } }, 0 }, ;
        { 'Исследование кала на скрытую кровь', { { 1, .t., 9 }, { 1, .f., 8 }, { 3, .t., 9 }, { 3, .f., 8 } }, 0 }, ;
        { 'Осмотр акушеркой, взятие мазка (соскоба)', { { 1, .t., 10 }, { 1, .f., 9 } }, 0 }, ;
        { 'Маммография молочных желез', { { 1, .t., 11 }, { 1, .f., 11 }, { 3, .t., 11 }, { 3, .f., 11 } }, 0 }, ;
        { 'Флюорография лёгких', { { 1, .t., 12 }, { 1, .f., 12 }, { 3, .t., 12 }, { 3, .f., 12 } }, 0 }, ;
        { 'УЗИ брюшной полости', { { 1, .t., 13 }, { 1, .f., 13 }, { 1, .f., 15 } }, 0 }, ;
        { 'Электрокардиография (в покое)', { { 1, .t., 14 }, { 1, .f., 16 } }, 0 }, ;
        { 'Спирометрия', { { 2, .f., 17 } }, 0 }, ;
        { 'Гликированный гемоглобин крови', { { 2, .t., 15 }, { 2, .f., 18 } }, 0 }, ;
        { 'Толерантность к глюкозе', { { 2, .t., 16 }, { 2, .f., 19 } }, 0 }, ;
        { 'Липидный спектр крови', { { 2, .t., 17 }, { 2, .f., 20 } }, 0 }, ;
        { 'Сканир-ие брахиоцефальных артерий', { { 2, .t., 18 }, { 2, .f., 22 } }, 0 }, ;
        { 'Фиброэзофагогастродуоденоскопия', { { 2, .t., 19 }, { 2, .f., 23 } }, 0 }, ;
        { 'Ректоскопия диагностическая', { { 2, .t., 20 }, { 2, .f., 24 } }, 0 }, ;
        { 'Ректосигмоколоноскопия диагностическая', { { 2, .t., 21 }, { 2, .f., 25 } }, 0 }, ;
        { 'Приём врача невролога', { { 1, .t., 22 }, { 2, .t., 22 }, { 2, .f., 26 } }, 0 }, ;
        { 'Приём врача офтальмолога', { { 2, .t., 23 }, { 2, .f., 27 } }, 0 }, ;
        { 'Приём врача оториноларинголога', { { 2, .f., 28 } }, 0 }, ;
        { 'Приём врача уролога (хирурга)', { { 2, .t., 24 }, { 2, .f., 29 } }, 0 }, ;
        { 'Приём врача акушера-гинеколога', { { 2, .t., 25 }, { 2, .f., 30 } }, 0 }, ;
        { 'Приём врача колопроктолога (хирурга)', { { 2, .t., 26 }, { 2, .f., 31 } }, 0 }, ;
        { 'Приём врача терапевта', { { 1, .t., 27 }, { 1, .f., 32 }, { 2, .t., 27 }, { 2, .f., 32 }, { 3, .t., 27 }, { 3, .f., 32 } }, 0 };
      }
      lat := Len( at )
      aitog := Array( lat ) ; AFill( aitog, 0 ) ; is_zs := 0
      Use ( cur_dir() + 'tmpfio' ) New Alias TF
      Index On Upper( fio ) to ( cur_dir() + 'tmpfio' )
      Go Top
      Do While !Eof()
        For i := 1 To iif( tf->fl_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
          pole := 'tf->d_' + lstr( i )
          If !Empty( &pole )
            For j := 1 To lat
              If at[ j, 3 ] == 0 .and. AScan( at[ j, 2 ], {| x| x[ 1 ] == ppar .and. x[ 2 ] == tf->fl_2018 .and. x[ 3 ] == i } ) > 0
                at[ j, 3 ] := 1 ; Exit
              Endif
            Next
          Endif
        Next
        If Empty( is_zs ) .and. !Empty( tf->d_zs )
          is_zs := 1
        Endif
        Skip
      Enddo
      arr_title := { ;
        '────────────┬────┬──────────┬─────', ;
        '            │Дата│  Сроки   │ Осн.', ;
        '    Ф.И.О   │рожд│ лечения  │диаг-', ;
        '            │ения│          │ ноз ', ;
        '────────────┴────┴──────────┴─────' }
      If ppar == 2
        arr_title[ 1 ] += '┬──────────'
        arr_title[ 2 ] += '│Информация'
        arr_title[ 3 ] += '│о I этапе '
        arr_title[ 4 ] += '│диспан-ции'
        arr_title[ 5 ] += '┴──────────'
      Endif
      For i := 1 To lat
        If at[ i, 3 ] > 0
          arr_title[ 1 ] += '┬────────'
          arr_title[ 2 ] += '│' + PadR( SubStr( at[ i, 1 ], 1, 8 ), 8 )
          arr_title[ 3 ] += '│' + PadR( SubStr( at[ i, 1 ], 9, 8 ), 8 )
          arr_title[ 4 ] += '│' + PadR( SubStr( at[ i, 1 ], 17, 8 ), 8 )
          arr_title[ 5 ] += '┴────────'
        Endif
      Next
      If is_zs > 0
        arr_title[ 1 ] += '┬────────'
        arr_title[ 2 ] += '│  шифр  '
        arr_title[ 3 ] += '│закончен'
        arr_title[ 4 ] += '│ случая '
        arr_title[ 5 ] += '┴────────'
      Endif
      If ppar == 1
        arr_title[ 1 ] += '┬──────────'
        arr_title[ 2 ] += '│Информация'
        arr_title[ 3 ] += '│о II этапе'
        arr_title[ 4 ] += '│диспан-ции'
        arr_title[ 5 ] += '┴──────────'
      Endif
      arr_title[ 1 ] += '┬─┬───────'
      arr_title[ 2 ] += '│Г│ Сумма '
      arr_title[ 3 ] += '│р│ случая'
      arr_title[ 4 ] += '│у│ Врач'
      arr_title[ 5 ] += '┴─┴───────'
      reg_print := f_reg_print( arr_title, @sh, 2 )
      fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
      add_string( '' )
      If ppar == 1
        add_string( Center( 'Диспансеризация взрослого населения 1 этап', sh ) )
        If par == 2
          add_string( Center( 'направлены на 2 этап, но ещё не прошли', sh ) )
        Endif
      Elseif ppar == 2
        add_string( Center( 'Диспансеризация взрослого населения 2 этап', sh ) )
      Else
        add_string( Center( 'Профилактика взрослого населения', sh ) )
      Endif
      If is_schet == 4
        add_string( Center( '[ случаи, ещё не попавшие в счета ]', sh ) )
      Else
        add_string( Center( '[ ' + CharRem( '~', mas1pmt()[ is_schet ] ) + ' ]', sh ) )
      Endif
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      j1 := ss := 0
      Go Top
      Do While !Eof()
        s := lstr( ++j1 ) + '. ' + tf->fio
        s1 := SubStr( s, 1, 12 ) + ' '
        s2 := SubStr( s, 13, 12 ) + ' '
        s3 := SubStr( s, 25, 12 ) + ' '
        s := full_date( tf->date_r )
        s1 += PadR( SubStr( s, 1, 3 ), 5 )
        s2 += PadR( SubStr( s, 4, 3 ), 5 )
        s3 += PadR( SubStr( s, 7 ), 5 )
        //
        s1 += PadR( SubStr( tf->sroki, 1, 9 ), 11 )
        s2 += PadR( SubStr( tf->sroki, 10, 9 ), 11 )
        s3 += PadR( SubStr( tf->sroki, 19 ), 11 )
        //
        s1 += PadR( tf->KOD_DIAG, 6 )
        s2 += Space( 6 )
        s3 += Space( 6 )
        If ppar == 2
          s1 += PadR( SubStr( tf->data_o, 1, 9 ), 11 )
          s2 += PadR( SubStr( tf->data_o, 10, 9 ), 11 )
          s3 += PadR( SubStr( tf->data_o, 19 ), 11 )
        Endif
        For i := 1 To lat
          If at[ i, 3 ] > 0
            fl := .t.
            For j := 1 To Len( at[ i, 2 ] )
              If at[ i, 2, j, 1 ] == ppar .and. at[ i, 2, j, 2 ] == tf->fl_2018
                pole := 'tf->d_' + lstr( at[ i, 2, j, 3 ] ) // номер элемента из массива ф-ии mo_init
                If !Empty( &pole )
                  s1 += PadR( SubStr( &pole, 1, 8 ), 9 )
                  s2 += PadR( SubStr( &pole, 9, 8 ), 9 )
                  s3 += PadR( SubStr( &pole, 17 ), 9 )
                  If Between( Left( &pole, 1 ), '0', '9' )
                    aitog[ i ] ++
                  Endif
                  fl := .f.
                  Exit
                Endif
              Endif
            Next
            If fl
              s1 += Space( 9 )
              s2 += Space( 9 )
              s3 += Space( 9 )
            Endif
          Endif
        Next
        If is_zs > 0
          s1 += PadR( tf->d_zs, 9 )
          s2 += Space( 9 )
          s3 += Space( 9 )
        Endif
        If ppar == 1
          s1 += PadR( SubStr( tf->data_o, 1, 9 ), 11 )
          s2 += PadR( SubStr( tf->data_o, 10, 9 ), 11 )
          s3 += PadR( SubStr( tf->data_o, 19 ), 11 )
        Endif
        s1 += iif( tf->gruppa == 4, '3', put_val( tf->gruppa, 1 ) ) + Str( tf->CENA_1, 8, 2 )
        If tf->gruppa > 2
          s2 += iif( tf->gruppa == 3, 'а', 'б' )
        Endif
        s3 += AllTrim( tf->vrach )
        ss += tf->CENA_1
        If verify_ff( HH -3, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        add_string( Replicate( '─', sh ) )
        Skip
      Enddo
      s1 := PadR( 'Итого:', 13 + 5 + 11 + 6 )
      If ppar == 2
        s1 += Space( 11 )
      Endif
      For i := 1 To lat
        If at[ i, 3 ] > 0
          If Empty( aitog[ i ] )
            Space( 9 )
          Else
            s1 += PadC( lstr( aitog[ i ] ), 8 ) + ' '
          Endif
        Endif
      Next
      i := 0
      If is_zs > 0
        i += 9
      Endif
      If ppar == 1
        i += 11
      Endif
      i += 2
      s1 += Str( ss, 7 + i, 2 )
      add_string( s1 )
      Close databases
      FClose( fp )
      Private yes_albom := .t.
      viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 27.09.24
Function f2_inf_dvn_svod( par, kod_h ) // сводная информация

  Static P_BEGIN_RSLT := 342
  Local i, j, c, s, pole, ar, arr := {}, fl, lshifr, arr_usl := {}
  Private metap := ppar, m1gruppa, mvozrast, mdvozrast, mpol, mn_data, mk_data, ;
    arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1veteran := 0, mvar, ;
    fl2 := .f., mshifr_zs := '', is_2019

  Select HUMAN
  Goto ( kod_h )
  mpol    := human->pol
  mn_data := human->n_data
  mk_data := human->k_data
  is_2018 := p := ( mk_data < 0d20190501 )
  is_2021 := p := ( mk_data < 0d20210101 )
  is_2019 := !is_2018
  ret_arr_vozrast_dvn( mk_data )
  ret_arrays_disp( mk_data )
  If ppar == 1 // диспансеризация 1 этап
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
    If Between( m1gruppa, 0, 4 )
      If m1gruppa == 0
        fl2 := .t. // направлен на 2 этап
      Endif
    Else
      Return Nil
    Endif
    If par == 0 .and. !fl2
      Return Nil
    Endif
  Elseif ppar == 2 // диспансеризация 2 этап
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa, 1, 4 )
      //
    Else
      Return Nil
    Endif
  Elseif ppar == 3 // профилактика
    m1GRUPPA := 0
    If Between( human_->RSLT_NEW, 343, 345 )
      m1GRUPPA := human_->RSLT_NEW - 342
    Elseif Between( human_->RSLT_NEW, 373, 374 )
      m1GRUPPA := human_->RSLT_NEW - 370
    Endif
    If !Between( m1gruppa, 1, 4 )
      Return Nil
    Endif
  Else
    Return Nil
  Endif
  read_arr_dvn( kod_h )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  If m1veteran == 1
    mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
  Endif
  For i := 1 To iif( is_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
    mvar := 'MTAB_NOMv' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATE' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'M1OTKAZ' + lstr( i )
    Private &mvar := 0
  Next
  fl := .f.
  If ppar == 1 .and. tmp->kod2h > 0
    Select HUMAN
    Goto ( tmp->kod2h )
    fl := ( human_->oplata != 9 )
  Elseif ppar == 2 .and. tmp->kod1h > 0
    Select HUMAN
    Goto ( tmp->kod1h )
    fl := ( human_->oplata != 9 )
  Endif
  If fl
    s := 'не в счёте'
    If human->schet > 0
      s := 'незарег.сч'
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // зарегистрированные
        s := 'счёт зарег'
      Endif
    Endif
    AAdd( arr, { human->n_data, human->k_data, s } )
  Endif
  Select HUMAN
  Goto ( kod_h )
  If p_is_schet == 4 .and. human->schet > 0
    Return Nil
  Endif
  s := 'не в счёте'
  If human->schet > 0
    s := 'незарег.сч'
    Select SCHET_
    Goto ( human->schet )
    If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // зарегистрированные
      s := 'счёт зарег'
    Endif
  Endif
  Select TF
  Append Blank
  tf->KOD    := human->kod
  tf->KOD_K  := tmp->kod_k
  tf->FIO    := human->fio
  tf->DATE_R := human->date_r
  tf->N_DATA := mN_DATA
  tf->K_DATA := mK_DATA
  tf->sroki  := date_8( mN_DATA ) + '-' + date_8( mK_DATA ) + ' ' + s
  tf->CENA_1 := human->CENA_1
  tf->etap   := metap
  tf->gruppa := m1gruppa
  tf->KOD_DIAG := human->kod_diag
  If Len( arr ) > 0
    tf->data_o := date_8( arr[ 1, 1 ] ) + '-' + date_8( arr[ 1, 2 ] ) + ' ' + arr[ 1, 3 ]
  Endif
  pers->( dbGoto( human_->vrach ) )
  tf->vrach := fam_i_o( pers->fio )
  lcount := iif( is_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
  larr_dvn := iif( is_2018, dvn_arr_usl18(), dvn_arr_usl )
  lcount_u := iif( is_2018, count_dvn_arr_umolch18, count_dvn_arr_umolch )
  larr_dvn_u := iif( is_2018, dvn_arr_umolch18(), dvn_arr_umolch )
  larr := Array( 2, lcount ) ; afillall( larr, 0 )
  Select HU
  find ( Str( kod_h, 7 ) )
  Do While hu->kod == kod_h .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
      lshifr := usl->shifr
    Endif
    lshifr := AllTrim( lshifr )
    If !eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.', '2.90.' )
      mshifr_zs := lshifr
    Else
      fl := .t.
      If metap != 2
        If is_2018
          If lshifr == '2.3.3' .and. hu_->PROFIL == 3 ; // акушерскому делу
            .and. ( i := AScan( dvn_arr_usl18(), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.20.1' } ) ) > 0
            fl := .f. ; larr[ 1, i ] := hu->( RecNo() )
          Endif
        Else
        /*if ((lshifr == '2.3.3' .and. hu_->PROFIL == 3) .or.  ; // акушерскому делу
              (lshifr == '2.3.1' .and. hu_->PROFIL == 136))  ; // акушерству и гинекологии
            .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=='C' .and. x[2]=='4.1.12'})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif*/
        Endif
      Endif
      If fl
        For i := 1 To lcount_u
          If Empty( larr[ 2, i ] ) .and. larr_dvn_u[ i, 2 ] == lshifr
            fl := .f. ; larr[ 2, i ] := hu->( RecNo() ) ; Exit
          Endif
        Next
      Endif
      If fl
        For i := 1 To lcount
          If Empty( larr[ 1, i ] )
            If ValType( larr_dvn[ i, 2 ] ) == 'C'
              If larr_dvn[ i, 2 ] == lshifr
                fl := .f.
              Elseif larr_dvn[ i, 2 ] == '4.20.1' .and. lshifr == '4.20.2'
                fl := .f.
              Endif
            Elseif Len( larr_dvn[ i ] ) > 11
              If AScan( larr_dvn[ i, 12 ], {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu_->PROFIL } ) > 0
                fl := .f.
              Endif
            Endif
            If !fl
              larr[ 1, i ] := hu->( RecNo() ) ; Exit
            Endif
          Endif
        Next
      Endif
    Endif
    AAdd( arr_usl, hu->( RecNo() ) )
    Select HU
    Skip
  Enddo
  For i := 1 To lcount
    If !Empty( larr[ 1, i ] )
      hu->( dbGoto( larr[ 1, i ] ) )
      If hu->kod_vr > 0
        mvar := 'MTAB_NOMv' + lstr( i )
        &mvar := hu->kod_vr
      Endif
      mvar := 'MDATE' + lstr( i )
      &mvar := c4tod( hu->date_u )
      mvar := 'M1OTKAZ' + lstr( i )
      If metap != 2
        If is_2018
          If hu_->PROFIL == 3 .and. ;
              AScan( dvn_arr_usl18(), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.20.1' } ) > 0
            &mvar := 2 // невозможность выполнения
          Endif
        Else
        /*if (hu_->PROFIL == 3 .or. hu_->PROFIL == 136)  ;
            .and. ascan(dvn_arr_usl, {|x| valtype(x[2])=='C' .and. x[2]=='4.1.12'}) > 0
          &mvar := 2 // невозможность выполнения
        endif*/
        Endif
      Endif
    Endif
  Next
  If metap != 2 .and. ValType( arr_usl_otkaz ) == 'A'
    For j := 1 To Len( arr_usl_otkaz )
      ar := arr_usl_otkaz[ j ]
      If ValType( ar ) == 'A' .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == 'C'
        lshifr := AllTrim( ar[ 5 ] )
        If ( i := AScan( larr_dvn, {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
          If ValType( ar[ 1 ] ) == 'N' .and. ar[ 1 ] > 0
            mvar := 'MTAB_NOMv' + lstr( i )
            &mvar := ar[ 1 ]
          Endif
          mvar := 'MDATE' + lstr( i )
          &mvar := mn_data
          If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == 'D'
            &mvar := ar[ 9 ]
          Endif
          mvar := 'M1OTKAZ' + lstr( i )
          &mvar := 1
          If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
            &mvar := ar[ 10 ]
          Endif
        Endif
      Endif
    Next
  Endif
  //
  If is_2018
    arr := f21_inf_dvn_svod18( 1 )
  Else
    arr := f21_inf_dvn_svod( 1 )
  Endif
  For i := 1 To Len( arr )
    pole := 'tf->d_' + lstr( arr[ i, 4 ] )
    If arr[ i, 5 ] == 1
      &pole := 'отказ   пациента'
    Elseif arr[ i, 5 ] == 2
      &pole := 'невозможность выполнения'
    Else
      &pole := date_8( arr[ i, 2 ] )
    Endif
  Next
  tf->d_zs := mshifr_zs
  tf->fl_2018 := is_2018
  If is_2018
    arr := f21_inf_dvn_svod18( 2 )
  Else
    arr := f21_inf_dvn_svod( 2 )
  Endif
  For i := 1 To Len( arr )
    pole := 'tf->du_' + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next

  Return Nil

// 10.11.19
Function f21_inf_dvn_svod18( par )

  Local i, arr := {}

  If par == 1
    For i := 1 To count_dvn_arr_usl18
      mvart := 'MTAB_NOMv' + lstr( i )
      mvard := 'MDATE' + lstr( i )
      mvaro := 'M1OTKAZ' + lstr( i )
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dvn_arr_usl18()[ i, 1 ], &mvard, '', i, &mvaro } )
        Endif
      Endif
    Next
  Else
    For i := 1 To count_dvn_arr_umolch18
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        AAdd( arr, { dvn_arr_umolch18()[ i, 1 ], iif( dvn_arr_umolch18()[ i, 8 ] == 0, mn_data, mk_data ), '', i, 0 } )
      Endif
    Next
  Endif

  Return arr

// 08.12.15
Function f21_inf_dvn_svod( par )

  Local i, arr := {}

  If par == 1
    For i := 1 To count_dvn_arr_usl
      mvart := 'MTAB_NOMv' + lstr( i )
      mvard := 'MDATE' + lstr( i )
      mvaro := 'M1OTKAZ' + lstr( i )
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dvn_arr_usl[ i, 1 ], &mvard, '', i, &mvaro } )
        Endif
      Endif
    Next
  Else
    For i := 1 To count_dvn_arr_umolch
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        AAdd( arr, { dvn_arr_umolch[ i, 1 ], iif( dvn_arr_umolch[ i, 8 ] == 0, mn_data, mk_data ), '', i, 0 } )
      Endif
    Next
  Endif

  Return arr


// 25.11.13
Function f4_inf_predn_karta( par, _etap )

  Local i, k, fl, arr := {}, ar := npred_arr_1_etap()[ mperiod ]

  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To Len( npred_arr_osmotr() )
        mvart := 'MTAB_NOMov' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        fl := .t.
        If fl .and. !Empty( npred_arr_osmotr()[ i, 2 ] )
          fl := ( mpol == npred_arr_osmotr()[ i, 2 ] )
        Endif
        If fl
          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], npred_arr_osmotr()[ i, 1 ] ) > 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { npred_arr_osmotr()[ i, 3 ], &mvard, '', i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
    Endif
    AAdd( arr, { 'педиатр (врач общей практики)', MDATEp1, '', -1, 1 } )
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      For i := 1 To Len( npred_arr_osmotr() )
        mvart := 'MTAB_NOMov' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        fl := .t.
        If fl .and. !Empty( npred_arr_osmotr()[ i, 2 ] )
          fl := ( mpol == npred_arr_osmotr()[ i, 2 ] )
        Endif
        If fl
          fl := ( AScan( ar[ 4 ], npred_arr_osmotr()[ i, 1 ] ) == 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { npred_arr_osmotr()[ i, 3 ], &mvard, '', i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
      AAdd( arr, { 'педиатр (врач общей практики)', MDATEp2, '', -2, 1 } )
    Endif
  Else
    For i := 1 To Len( npred_arr_issled() ) // исследования
      mvart := 'MTAB_NOMiv' + lstr( i )
      mvard := 'MDATEi' + lstr( i )
      mvarr := 'MREZi' + lstr( i )
      fl := .t.
      If fl .and. !Empty( npred_arr_issled()[ i, 2 ] )
        fl := ( mpol == npred_arr_issled()[ i, 2 ] )
      Endif
      If fl
        fl := ( AScan( ar[ 5 ], npred_arr_issled()[ i, 1 ] ) > 0 )
      Endif
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i ==  1 // {'4.2.153' ,   , 'Общий анализ мочи', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
        Case i ==  2 // {'4.11.136',   , 'Клинический анализ крови', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
        Case i ==  3 // {'4.12.169',   , 'Исследование уровня глюкозы в крови', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 4
        Case i ==  4 // {'4.8.12'  ,   , 'Анализ кала на яйца глистов', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 16
        Case i ==  5 // {'7.61.3'  ,   , 'Флюорография легких в 1-й проекции', 0, 78,{1118, 1802} }, ;
          k := 12
        Case i ==  6 // {'8.1.2'   ,   , 'УЗИ щитовидной железы', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 8
        Case i ==  7 // {'8.1.3'   ,   , 'УЗИ сердца', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 7
        Case i ==  8 // {'8.2.1'   ,   , 'УЗИ органов брюшной полости', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 6
        Case i ==  9 // {'8.2.2'   ,'М', 'УЗИ органов репродуктивной системы', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 9
        Case i == 10 // {'8.2.3'   ,'Ж', 'УЗИ органов репродуктивной системы', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 9
        Case i == 11 // {'13.1.1'  ,   , 'Электрокардиография', 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
          k := 13
        Endcase
        AAdd( arr, { npred_arr_issled()[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
  Endif

  Return arr

// 25.11.13
Function f4_inf_pern_karta( par )

  Local i, k, fl, arr := {}, ar := nper_arr_1_etap[ mperiod ]

  If par == 1
    AAdd( arr, { 'педиатр (врач общей практики)', MDATEp1, '', -1, 1 } )
  Else
    For i := 1 To Len( nper_arr_issled() ) // исследования
      mvart := 'MTAB_NOMiv' + lstr( i )
      mvard := 'MDATEi' + lstr( i )
      mvarr := 'MREZi' + lstr( i )
      fl := ( AScan( ar[ 5 ], nper_arr_issled()[ i, 1 ] ) > 0 )
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i ==  1 // {'4.2.153' ,   , 'Общий анализ мочи', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
        Case i ==  1 // {'4.11.136',   , 'Клинический анализ крови', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
        Case i ==  1 // {'16.1.16' ,   , 'Анализ окиси углерода выдыхаем.воздуха', 0, 34,{1107, 1301, 1402, 1702} };
          k := 17
        Endcase
        AAdd( arr, { nper_arr_issled()[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
  Endif

  Return arr


// 18.12.13 Сводные документы по всем видам диспансеризации и профилактики
Function inf_disp( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { '~Итоги для ТФОМС' }
    mas_msg := { 'Итоги за период времени для ТФОМС' }
    mas_fun := { 'inf_DISP(11)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    itog_svod_disp_tf()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif

  Return Nil

// 18.12.13 Итоги за период времени для ТФОМС
Function itog_svod_disp_tf()

  Local i, k, arr_m, buf := save_maxrow(), ;
    sh := 80, hh := 60, n_file := cur_dir() + 'svod_dis.txt'

  If ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + 'tmpk', { { 'kod', 'N', 7, 0 }, ;
      { 'tip', 'N', 1, 0 } } )
    Use ( cur_dir() + 'tmpk' ) new
    Index On Str( tip, 1 ) + Str( kod, 7 ) to ( cur_dir() + 'tmpk' )
    dbCreate( cur_dir() + 'tmp', { { 'tip',  'N', 1, 0 }, ;
      { 'kol_s', 'N', 6, 0 }, ;
      { 'kol_o', 'N', 6, 0 }, ;
      { 'kol_p', 'N', 6, 0 } } )
    Use ( cur_dir() + 'tmp' ) new
    Index On Str( tip, 1 ) to ( cur_dir() + 'tmp' )
    r_use( dir_server() + 'mo_rak',, 'RAK' )
    r_use( dir_server() + 'mo_raks',, 'RAKS' )
    Set Relation To akt into RAK
    r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
    Set Relation To kod_raks into RAKS
    Index On Str( kod_h, 7 ) + DToS( rak->dakt ) to ( cur_dir() + 'tmpraksh' )
    r_use( dir_server() + 'mo_rpd',, 'RPD' )
    r_use( dir_server() + 'mo_rpds',, 'RPDS' )
    Set Relation To pd into RPD
    r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
    Set Relation To kod_rpds into RPDS
    Index On Str( kod_h, 7 ) + DToS( rpd->d_pd ) to ( cur_dir() + 'tmprpdsh' )
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Index On kod to ( cur_dir() + 'tmp_h' ) ;
      For ishod > 100 .and. human_->oplata != 9 .and. schet > 0 ;
      While human->k_data <= arr_m[ 6 ] ;
      PROGRESS
    i := 0
    Go Top
    Do While !Eof()
      ++i
      @ MaxRow(), 1 Say lstr( i ) Color cColorWait
      ltip := 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        If eq_any( human->ishod, 101, 102 )
          ltip := iif( Empty( human->za_smo ), 2, 1 )
        Elseif eq_any( human->ishod, 301, 302 )
          ltip := 3
        Elseif eq_any( human->ishod, 303, 304 )
          m1gruppa := human_->RSLT_NEW - 316
          If Between( m1gruppa, 1, 3 )
            ltip := 4
          Endif
        Elseif human->ishod == 305
          ltip := 5
        Elseif eq_any( human->ishod, 201, 202 )
          ltip := 6
        Elseif human->ishod == 203
          ltip := 7
        Endif
      Endif
      If ltip > 0
        Select TMPK
        find ( Str( ltip, 1 ) + Str( human->kod_k, 7 ) )
        If !Found()
          Append Blank
          tmpk->tip := ltip
          tmpk->kod := human->kod_k
          If LastRec() % 2000 == 0
            Commit
          Endif
        Endif
        Select TMP
        find ( Str( ltip, 1 ) )
        If !Found()
          Append Blank
          tmp->tip := ltip
        Endif
        tmp->kol_s++
        //
        k := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While raksh->kod_h == human->kod .and. !Eof()
          If raksh->IS_REPEAT < 1
            k := iif( raksh->SUMP > 0, 1, 0 )
          Endif
          Skip
        Enddo
        If k == 1
          tmp->kol_o++
        Endif
        //
        k := 0
        Select RPDSH
        find ( Str( human->kod, 7 ) )
        Do While rpdsh->kod_h == human->kod .and. !Eof()
          k += rpdsh->S_SL
          Skip
        Enddo
        If k > 0
          tmp->kol_p++
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    //
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( glob_mo()[ _MO_SHORT_NAME ] )
    add_string( '' )
    add_string( Center( 'Итоги по диспансеризации, профилактике и медосмотрам', sh ) )
    add_string( Center( '[ ' + CharRem( '~', mas1pmt()[ 3 ] ) + ' ]', sh ) )
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( '' )
    add_string( '────────────────────────────────────────┬─────────┬─────────┬─────────┬─────────' )
    add_string( '                                        │ Кол-во  │ Кол-во  │ Кол-во  │ Кол-во  ' )
    add_string( '                                        │ случаев │ человек │ случаев,│ случаев,' )
    add_string( '                                        │         │         │ принятых│оплаченн.' )
    add_string( '                                        │         │         │ к оплате│полностью' )
    add_string( '                                        │         │         │         │или част.' )
    add_string( '────────────────────────────────────────┴─────────┴─────────┴─────────┴─────────' )
    For i := 1 To 7
      s :=    { 'диспансеризация детей-сирот в стационаре', ;
        'диспансеризация детей-сирот под опекой', ;
        'профилактич.осмотры несовершеннолетних', ;
        'предварительн.осмотры несовершеннолетних', ;
        'периодические осмотры несовершеннолетних', ;
        'диспансеризация взрослого населения', ;
        'профилактика взрослого населения' }[ i ]
      Select TMP
      find ( Str( i, 1 ) )
      If Found()
        k := 0
        Select TMPK
        find ( Str( i, 1 ) )
        Do While tmpk->tip == i .and. !Eof()
          ++k
          Skip
        Enddo
        s := PadR( s, 40 ) + put_val( tmp->kol_s, 9 ) + ;
          put_val( k, 10 ) + ;
          put_val( tmp->kol_o, 10 ) + ;
          put_val( tmp->kol_p, 10 )
      Endif
      add_string( s )
      add_string( Replicate( '─', sh ) )
    Next
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( n_file,,,, .f.,,, 2 )
  Endif

  Return Nil
