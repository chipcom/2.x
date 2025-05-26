// mo_263s.prg - режимы стационара для задачи по приказу 263-ФФОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 01.08.14 Проверка того, что ещё не сделано в стационаре
Function _263_s_proverka()

  ne_real()
  Return Nil

// 08.03.17 добавление / редактирование госпитализаций в стационаре
Function for_263_s_gospit()

  Local fl := ( KOD_F_4out >= 0 .and. TYPE_H_4 > 0 )

  If fl
    fl := Between( date_h_4, arr_m[ 5 ], arr_m[ 6 ] )
  Endif
  If fl .and. not_out
    fl := Empty( KOD_F_4out )
  Endif
  Return fl

// 08.03.17 добавление / редактирование госпитализаций в стационаре
Function _263_s_gospit()

  Static str_sem := '_263_s_gospit', si := 2
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ], fl, i, n

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  If ( i := popup_prompt( T_ROW, T_COL + 5, si, ;
      { 'Добавить ~госпитализацию', ;
      'Поиск по ~дате госпитализации' } ) ) == 0
    g_sunlock( str_sem )
    Return Nil
  Endif
  Private arr_m, not_out := .f.
  If ( si := i ) == 1
    If !_263_edit_s_gospit( K_INS )
      g_sunlock( str_sem )
      Return Nil
    Endif
  Elseif si == 2
    If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) == NIL
      g_sunlock( str_sem )
      Return Nil
    Endif
    If ( i := popup_prompt( T_ROW, T_COL + 5, 1, { 'Все ~госпитализации', 'Ещё ~не отправленные в ТФОМС' } ) ) == 2
      not_out := .t.
    Endif
  Endif
  mywait()
  r_use( dir_server + 'kartotek', , '_KART' )
  r_use( dir_server + 'mo_nfile', , 'NF' )
  g_use( dir_server + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into _KART, To KOD_F_4out into NF
  Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
    For for_263_s_gospit()
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    rest_box( buf )
    Return func_error( 4, 'Не обнаружено госпитализаций ' + arr_m[ 4 ] )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Госпитализации ' + arr_m[ 4 ]
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R, N+/BG', .t. }
  blk := {|| iif( Empty( napr->KOD_F_4out ), { 3, 4 }, ;
    iif( napr->t_ans_4 == 1 .or. napr->KOD_F_4out < 0, { 1, 2 }, ;
    iif( napr->t_ans_4 == 0, { 5, 6 }, { 7, 8 } ) ) ) }
  n := iif( work_otd_263 == 1, 20, 26 )
  t_arr[ BR_COLUMN ] := { { ' Ф.И.О.', {|| PadR( iif( Empty( _kart->fio ), 'код ' + lstr( napr->kod_k ), _kart->fio ), n ) }, blk }, ;
    { ' Откуда поступил', {|| PadR( f0_263_s_gospit(), 17 ) }, blk }, ;
    { ' ', {|| iif( napr->usl_ok_4 == 2, 'д', 'с' ) }, blk }, ;
    { '  Дата;госп-ии', {|| date_8( napr->date_h_4 ) }, blk }, ;
    { ' Статус', {|| PadR( f1_263_s_gospit(), 22 ) }, blk } }
  If work_otd_263 == 1
    ins_array( t_arr[ BR_COLUMN ], 4, { ' Отд.', {|| _263_put_otd( napr->otd_4 ) }, blk } )
  Endif
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход ^<Enter>^ просмотр/ред-ие инф-ии по госпитализации ^<Del>^ удаление' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_s_gospit( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 06.11.22
Function f0_263_s_gospit()

  Local s := ''

  Do Case
  Case napr->TYPE_H_4 == 1 // госп-ия: 1-по направлению
    s := 'напр'
    If napr->CODEM_FROM == glob_mo[ _MO_KOD_TFOMS ]
      s += '-ие из нашей п-ки'
    Elseif Empty( napr->CODEM_FROM )
      s += napr->NUM_D
    Else
      s += ret_mo( napr->CODEM_FROM )[ _MO_SHORT_NAME ]
    Endif
  Case napr->TYPE_H_4 == 2 // госп-ия: 2-перевод из другого МО
    If !Empty( napr->CODEM_FROM )
      s := 'из ' + ret_mo( napr->CODEM_FROM )[ _MO_SHORT_NAME ]
    Endif
  Case napr->TYPE_H_4 == 3 // госп-ия: 3-перевод внутри нашего МО
    s := 'внутри нашего МО'
  Case napr->TYPE_H_4 == 4 // госп-ия: 4-экстр./неотл. (I05)
    s := inieditspr( A__MENUVERT, getv014(), napr->F_MEDC_4 ) + ' госпитализация'
  Endcase
  Return s

// 19.02.17
Function f1_263_s_gospit()

  Local s := 'ошибка'

  If Empty( napr->KOD_F_4out )
    s := 'ещё не отправлено в ТФОМС'
  Elseif napr->t_ans_4 == 0
    If napr->KOD_F_4out < 0
      s := 'госп-ия в др.стационар'
    Else
      s := 'не получен ответ из ТФОМС'
    Endif
  Elseif napr->t_ans_4 == 1
    s := 'получен ответ из ТФОМС'
    If napr->KOD_F_6out > 0
      s := ' выбытие ' + date_8( napr->date_6 )
    Elseif napr->KOD_F_4out > 0
      s := 'отправлено в ТФОМС'
    Endif
  Endif
  Return s

// 19.02.17
Function f2_263_s_gospit( nKey, oBrow, regim )

  Local ret := -1, fl, rec

  Do Case
  Case regim == 'edit'
    If nKey == K_ENTER
      If _263_edit_s_gospit( K_ENTER )
        ret := 0
      Else
        ret := 1
      Endif
    Elseif nKey == K_DEL // удаление
      If Empty( napr->KOD_F_4out ) .or. napr->t_ans_4 == 2
        fl := .t.
        Select NAPR
        Do Case
        Case napr->TYPE_H_4 == 1 // госп-ия: 1-по направлению
          If napr->KOD_PP > 0
            // fl := .f. проверим БД приёмного покоя
          Endif
          If fl .and. f_esc_enter( 2, .t. )
            g_rlock( forever )
            napr->CODEM_FROM := ''          // из какого МО направлен (п-ка, другой стационар или наш же стационар)
            napr->KOD_UP     := 0           // код пред.направления (после перевода в др.отд-ие)
            napr->KOD_PP     := 0           // код по БД приёмного покоя
            napr->TYPE_H_4   := 0           // госп-ия: 1-по направлению, 2-перевод из другого МО, 3-перевод внутри нашего МО, 5-экстр./неотл. (I05)
            napr->DATE_H_4   := CToD( '' )    // реальная дата госпитализации
            napr->TIME_H_4   := ''          // время госпитализации
            napr->DNEJ_H_4   := 0
            napr->usl_ok_4   := 0
            napr->ID_4       := ''          // GUID+lstr(mo_nnapr->KOD) ID госпитализации для tip_f=4 или 5
            napr->PROFIL_4   := 0           // профиль мед.помощи по справочнику V002
            napr->PROFIL_K_4 := 0           // профиль койки по справочнику T007
            napr->DS_4       := ''          // диагноз приёмного отделения стационара
            napr->F_MEDC_4   := 0           // форма оказания мед.помощи по V014 (1-экстренная, 2-неотложная, 3-плановая)
            napr->NUM_HIST_4 := ''          // номер истории болезни
            napr->T_ANS_4    := 0           // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
            napr->KOD_F_4out := 0           // код файла - по файлу mo_nfile
            napr->KOD_F_4in  := 0           // _код файла - по файлу mo_nfile
            Go Top
            ret := 1
          Endif
        Case napr->TYPE_H_4 == 2 // госп-ия: 2-перевод из другого МО
          If f_esc_enter( 2, .t. )
            deleterec()
            Go Top
            ret := 1
          Endif
        Case napr->TYPE_H_4 == 3 // госп-ия: 3-перевод внутри нашего МО
          rec := 0
          If napr->KOD_UP > 0
            rec := napr->KOD_UP
            // fl := .f. указать, что уже выписан и отправлен в ТФОМС
          Endif
          If fl .and. f_esc_enter( 2, .t. )
            deleterec()
            If rec > 0
              Set Index To
              Goto ( rec )
              g_rlock( forever )
              napr->TYPE_6 := 0         // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
              napr->KOD_NEXT := 0       // код следующей госпитализации (после перевода в др.отд-ие)
              napr->ID_6 := ''          // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
              napr->DATE_6 := CToD( '' )  // дата выбытия
              napr->T_ANS_6 := 0        // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
              napr->KOD_F_6out := 0     // _код файла - по файлу mo_nfile
              napr->KOD_F_6in := 0      // _код файла - по файлу mo_nfile
            Endif
            Go Top
            ret := 1
          Endif
        Case napr->TYPE_H_4 == 4 // госп-ия: 4-экстр./неотл. (I05)
          If f_esc_enter( 2, .t. )
            deleterec()
            Go Top
            ret := 1
          Endif
        Endcase
      Else
        If napr->KOD_F_4out < 0
          s := 'Это наш пациент госпитализирован в другой стационар'
        Else
          s := 'Ответ из ТФОМС ' + iif( napr->t_ans_4 == 0, 'ещё не', 'уже' ) + ' получен'
        Endif
        func_error( 4, s + '. Удаление запрещено!' )
      Endif
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

// 04.06.23 работа с направлениями на госпитализацию в стационаре
Function _263_edit_s_gospit( nKey )

  Static sk := 1
  Local bg := {| o, k| get_mkb10( o, k ) }
  Local flag := .t., i, k, mm_forma, s_error := '', tmp_color := SetColor(), buf := SaveScreen(), ;
    tmp_V006 := { { 'Стационар', 1 }, { 'Дневной стационар', 2 } }

  Private mkod := iif( nKey == K_INS, 0, napr->KOD ), ;
    m1kod_k := iif( nKey == K_INS, 0, napr->kod_k ), ; // код по картотеке
    mfio    := iif( nKey == K_INS, '', _kart->fio ), ;
    mdate_r := iif( nKey == K_INS, CToD( '' ), _kart->date_r ), ;
    mpol    := iif( nKey == K_INS, '', _kart->pol ), ;
    mnum_d  := iif( nKey == K_INS, '', napr->NUM_D ), ;
    md_napr := iif( nKey == K_INS, CToD( '' ), napr->DATE_D ), ; // дата направления
    motd := Space( 10 ), m1otd := if( nKey == K_INS, 0, napr->otd_4 ), ;
    mCODEM_FROM, m1CODEM_FROM := iif( nKey == K_INS, '', napr->CODEM_FROM ), ;
    mkod_diag := iif( nKey == K_INS, '', napr->ds_4 ), ; // диагноз
    musl_ok, m1usl_ok := iif( nKey == K_INS .or. napr->usl_ok_4 != 2, 1, napr->usl_ok_4 ), ; // условия оказания мед.помощи
    mforma, m1forma := iif( nKey == K_INS, 2, napr->F_MEDC_4 ), ; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
    mdate_h := iif( nKey == K_INS, sys_date, napr->DATE_H_4 ), ; // дата госпитализации
    mtime_h := iif( nKey == K_INS, '11:00', napr->TIME_H_4 ), ; // время госпитализации
    mprofil_k, m1profil_k := iif( nKey == K_INS, 0, napr->PROFIL_K_4 ), ; // профиль койки по справочнику T007
    mprofil, m1profil := iif( nKey == K_INS, 0, napr->PROFIL_4 ), ; // профиль мед.помощи по справочнику V002
    mnum_hist := iif( nKey == K_INS, Space( 10 ), Left( napr->NUM_HIST_4, 10 ) ), ;
    mTYPE_H_4 := iif( nKey == K_INS, 0, napr->TYPE_H_4 ), ;
    mDNEJ_H_4 := iif( nKey == K_INS, 0, napr->DNEJ_H_4 ), ;
    mTIP_ANNUL := iif( nKey == K_INS, 0, napr->TIP_ANNUL ), ;
    mdate_3 := iif( nKey == K_INS, CToD( '' ), napr->date_3 )
  If nKey == K_INS
    If ( k := popup_prompt( T_ROW, T_COL + 5, sk, ;
        { 'на основании ~направления из поликлиники', ;
        'переводом из другого ~стационара', ;
        'переводом из другого ~отделения нашего МО', ;
        'по неотложным или ~экстренным показаниям' } ) ) == 0
      Return .f.
    Endif
    sk := mTYPE_H_4 := k
    Do Case
    Case sk == 1 // на основании направления
      If ( mkod := _263_input_napr() ) > 0
        r_use( dir_server + 'mo_nnapr', , 'NAPR' )
        Goto ( mkod )
        m1kod_k := napr->kod_k
        mnum_d := napr->NUM_D
        md_napr := napr->DATE_D // дата направления
        m1otd := napr->otd_1
        m1CODEM_FROM := napr->CODEM_1 // код поликлиники
        mkod_diag := napr->ds_1
        m1usl_ok := napr->usl_ok_1 // переносим условия из направления поликлиники и не меняем
        m1forma :=  napr->F_MEDC_1
        mdate_h :=  napr->DATE_H_1
        m1profil_k :=  napr->PROFIL_K_1
        m1profil :=  napr->PROFIL_1
        mTIP_ANNUL := napr->TIP_ANNUL
        mdate_3 := napr->date_3
      Else
        flag := .f.
      Endif
    Case sk == 2 // переводом из другого стационара
      k := f_get_mo(, T_ROW, T_COL + 5 )
      If k == Nil .or. Empty( k[ 1 ] )
        flag := .f.
      Elseif k[ 1 ] == glob_mo[ _MO_KOD_TFOMS ]
        flag := func_error( 4, 'Нельзя выбирать наше МО - необходимо выбрать другой стационар!' )
      Else
        m1CODEM_FROM := k[ 1 ]
        If ( k := polikl1_kart() ) > 0
          m1kod_k := k
        Else
          flag := .f.
        Endif
      Endif
    Case sk == 3 // переводом из другого отделения нашего МО
      flag := func_error( 4, 'Воспользуйтесь режимом "Стационар/Выписка (выбытие)"' )
    Case sk == 4 // по неотложным или экстренным показаниям
      If ( k := polikl1_kart() ) > 0
        m1kod_k := k
      Else
        flag := .f.
      Endif
    Endcase
    Close databases // если вдруг вышли из картотеки по <Esc>
    //
    If m1kod_k > 0
      r_use( dir_server + 'kartotek', , '_KART' )
      Goto ( m1kod_k )
      mfio    := _kart->fio
      mdate_r := _kart->date_r
      mpol    := _kart->pol
    Endif
    Close databases
  Endif
  If flag
    If Empty( m1CODEM_FROM )
      mCODEM_FROM := Space( 10 )
    Else
      If m1CODEM_FROM == glob_mo[ _MO_KOD_TFOMS ]
        mCODEM_FROM := 'Поликлиники нашего МО'
      Else
        mCODEM_FROM := ret_mo( m1CODEM_FROM )[ _MO_SHORT_NAME ]
      Endif
    Endif
    mm_forma := AClone( getv014() )
    If mTYPE_H_4 > 1
      del_array( mm_forma, 3 ) // убираем 'плановую' помощь
    Endif
    mUSL_OK := inieditspr( A__MENUVERT, tmp_V006, m1USL_OK )
    mforma := inieditspr( A__MENUVERT, getv014(), m1forma )
    mprofil_k := inieditspr( A__MENUVERT, arr_t007(), M1PROFIL_K )
    mprofil := inieditspr( A__MENUVERT, getv002(), M1PROFIL )
    If work_otd_263 == 1
      Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
      make_arr_uch_otd( mdate_h )
      If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
        motd := pr_arr[ i, 2 ]
      Elseif nKey == K_ENTER .and. m1otd > 0
        motd := '! некорректное отделение !'
      Endif
    Endif
    If nKey == K_INS
      flag := .f.
    Elseif napr->t_ans_4 == 2
      r_use( dir_server + 'mo_nfina', , 'NFN' )
      Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == napr->KOD_F_4out
      find ( Str( napr->kod, 6 ) )
      If Found()
        s_error := 'ошибка ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
        If !Empty( nfn->IM_POL )
          s_error += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
        Endif
      Endif
      nfn->( dbCloseArea() )
      Select NAPR
    Endif
    Private r1 := MaxRow() -15
    If work_otd_263 == 1
      --r1
    Endif
    Do While .t.
      SetColor( cDataCGet )
      clrlines( r1, MaxRow() -1 )
      @ r1 -1, 0 Say PadC( iif( nKey == K_INS, 'Добавление', 'Редактирование' ) + ' госпитализации', 80 ) Color 'B/B*'
      i := r1
      @ ++i, 1 Say 'Пациент' Get mfio When .f.
      @ Row(), Col() + 2 Say 'Дата р.' Get mdate_r When .f.
      Do Case
      Case mTYPE_H_4 == 1
        @ ++i, 1 Say 'Направлен из' Color color8 Get mCODEM_FROM When .f.
        @ ++i, 1 Say ' направление: №' Color color8 Get mnum_d When .f.
        @ Row(), Col() + 1 Say 'от' Color color8 Get md_napr When .f.
      Case mTYPE_H_4 == 2
        @ ++i, 1 Say 'Переведён из' Color color8 Get mCODEM_FROM When .f.
      Case mTYPE_H_4 == 3
        @ ++i, 1 Say 'Переведён внутри МО из стационарного отделения в стационарное отделение' Color color8
      Case mTYPE_H_4 == 4
        @ ++i, 1 Say 'Госпитализация по неотложным или экстренным показаниям' Color color8
      Endcase
      @ ++i, 1 Say 'Условия оказания, в которые направляется пациент' Get musl_ok ;
        reader {| x| menu_reader( x, tmp_V006, A__MENUVERT, , , .f. ) } When Between( mTYPE_H_4, 2, 3 )
      @ ++i, 1 Say 'Дата фактической госпитализации' Get mdate_h
      @ Row(), Col() Say ', время' Get mtime_h Pict '99:99'
      If work_otd_263 == 1
        @ ++i, 1 Say '   госпитализирован в отделение'
        If mem_kodotd == 1
          @ Row(), Col() + 1 Get motd ;
            reader {| x| menu_reader( x, { {| k, r, c| get_otd( k, r + 1, c, .f. ) } }, A__FUNCTION, , , .f. ) }
        Else
          @ Row(), Col() + 1 Get m1otd Pict '99' ;
            when {| g| f5editkusl( g, 1, 10 ) } ;
            valid {| g| f5editkusl( g, 2, 10 ) }
          @ Row(), Col() + 2 Get motd Color color14 When .f.
        Endif
      Endif
      @ ++i, 1 Say 'Диагноз приёмного отделения' Get mkod_diag Picture '@K@!' ;
        reader {| o| mygetreader( o, bg ) } ;
        Valid val1_10diag( .t., .f., .f., mdate_h, mpol )
      @ ++i, 1 Say 'Форма оказания медицинской помощи' Get mforma ;
        reader {| x| menu_reader( x, mm_forma, A__MENUVERT, , , .f. ) } ;
        When mTYPE_H_4 > 1
      @ ++i, 1 Say 'Профиль койки' Get mprofil_k ;
        reader {| x| menu_reader( x, { {| k, r, c| f_get_profil_k( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o| f_valid_profil_k( g, o ) } ;
        When mTYPE_H_4 > 1
      @ ++i, 1 Say 'Профиль медицинской помощи' Get mprofil ;
        reader {| x| menu_reader( x, { {| k, r, c| f_get_profil( k, r, c, m1profil_k ) } }, A__FUNCTION, , , .f. ) } ;
        When m1profil_k > 0 .and. mTYPE_H_4 > 1
      @ ++i, 1 Say 'Планирумый срок лечения' Get mdnej_h_4 Pict '999' When f1_263_edit_s_gospit()
      @ Row(), Col() + 1 Say 'койко-дней'
      @ ++i, 1 Say 'Номер истории болезни' Get mnum_hist Pict '@!'
      If Between( mTIP_ANNUL, 1, 3 )
        s := 'Предупреждение! Данное направление аннулировано в '
        If mTIP_ANNUL == 1
          s += 'СМО'
        Elseif mTIP_ANNUL == 2
          s += 'стационаре'
        Else
          s += 'поликлинике'
        Endif
        @ ++i, 1 Say s + ' ' + date_8( mdate_3 ) Color color8
      Endif
      If !Empty( s_error )
        @ ++i, 1 Say s_error Color color8
      Endif
      If nKey == K_ENTER .and. !( Empty( napr->KOD_F_4out ) .or. napr->t_ans_4 == 2 )
        s := ''
        If !Empty( napr->KOD_F_4out ) .and. !Empty( nf->NAME_F )
          s := '(в файле ' + AllTrim( nf->NAME_F ) + ') '
        Endif
        If napr->KOD_F_6in > 0 .or. ( napr->KOD_F_6out > 0 .and. napr->t_ans_6 == 1;
            .and. napr->CODEM_1 == glob_mo[ _MO_KOD_TFOMS ] )
          s := 'выбыл из стационара ' + date_8( napr->date_6 )
        Endif
        @ ++i, 1 Say s Color color8
        If napr->KOD_F_4out < 0
          @ ++i, 1 Say 'стационар: ' + ret_mo( napr->S_CODEM )[ _MO_SHORT_NAME ] Color color14
          s := 'Это наш пациент госпитализирован в другой стационар'
        Else
          s := 'Ответ из ТФОМС ' + iif( napr->t_ans_4 == 0, 'ещё не', 'уже' ) + ' получен'
        Endif
        stat_msg( s + '. Редактирование запрещено!' )
        mybell( 0, ERR )
        clear_gets()
        Exit
      Endif
      status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
      myread()
      k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
        { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
        iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
      If k == 3
        Loop
      Elseif k == 2
        If Empty( CharRepl( '0', mnum_hist, Space( 10 ) ) )
          func_error( 4, 'Не заполнен номер истории болезни' )
          Loop
        Endif
        If Empty( mdate_h )
          func_error( 4, 'Не введена дата госпитализации.' )
          Loop
        Endif
        If Empty( m1profil_k )
          func_error( 4, 'Не введен профиль койки.' )
          Loop
        Endif
        If Empty( m1profil )
          func_error( 4, 'Не введен профиль медицинской помощи.' )
          Loop
        Endif
        If Empty( mkod_diag )
          func_error( 4, 'Не введен диагноз приёмного отделения.' )
          Loop
        Endif
        If nKey == K_INS
          g_use( dir_server + 'mo_nnapr', , 'NAPR' )
          If mTYPE_H_4 == 1
            Goto ( mkod )
            g_rlock( forever )
          Else
            g_rlock( .t., forever ) // бесконечная попытка добавить запись
            napr->KOD := RecNo() // код направления - номер записи
            rec := mkod := napr->KOD
            napr->KOD_K := m1kod_k // код по картотеке
            fl_found := .t.
          Endif
          napr->CODEM_FROM := m1CODEM_FROM
          napr->TYPE_H_4 := mTYPE_H_4
          napr->ID_4 := mo_guid( 1, mkod )
          napr->KOD_UP := 0
          napr->KOD_PP := 0
        Else
          Select NAPR
          g_rlock( forever )
        Endif
        napr->otd_4 := m1otd
        napr->DS_4 := mkod_diag // диагноз приёмного отделения
        napr->usl_ok_4 := m1usl_ok
        napr->F_MEDC_4 := m1forma // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
        napr->DATE_H_4 := mdate_h // дата госпитализации
        napr->TIME_H_4 := mtime_h // время госпитализации
        napr->DNEJ_H_4 := mDNEJ_H_4 // сроки госпитализации
        napr->PROFIL_K_4 := m1profil_k // профиль койки по справочнику T007
        napr->PROFIL_4 := m1profil // профиль мед.помощи по справочнику V002
        napr->NUM_HIST_4 := mnum_hist
        napr->KOD_F_4out := 0 // код файла - по файлу mo_nfile
        napr->KOD_F_4in := 0 // код файла - по файлу mo_nfile
        If nKey == K_INS
          Close databases
          arr_m := { Year( mdate_h ), 1, 1, 'за ' + date_month( mdate_h, .t. ), ;
            mdate_h, mdate_h, dtoc4( mdate_h ), dtoc4( mdate_h ) }
          flag := .t.
        Else
          dbUnlock()
          Commit
          flag := Between( mdate_h, arr_m[ 5 ], arr_m[ 6 ] )
        Endif
      Endif
      Exit
    Enddo
  Endif
  SetColor( tmp_color )
  RestScreen( buf )
  Return flag

// 14.09.16 подставить срок лечения по умолчанию для конкретного профиля
Function f1_263_edit_s_gospit()

  Local tmp_select := Select()

  If m1profil_k > 0 .and. m1profil > 0 .and. mDNEJ_H_4 <= 0
    r_use( dir_server + 'mo_n7out', , 'N7' )
    Index On Str( profil_k, 3 ) + Str( profil, 3 ) To tmpn7 memory
    find ( Str( m1profil_k, 3 ) + Str( m1profil, 3 ) )
    If Found() .and. n7->kol_kd > 0
      mDNEJ_H_4 := n7->kol_kd
    Endif
    n7->( dbCloseArea() )
    Select ( tmp_select )
  Endif
  Return .t.

// 08.03.17
Function for_263_input_napr()

  Local fl := !Empty( NUM_D )

  If fl
    If KOD_F_1in > 0
      //
    Elseif T_ANS_1 == 1 .and. CODEM_1 == glob_mo[ _MO_KOD_TFOMS ]
      //
    Else
      fl := .f.
    Endif
  Endif
  If fl
    fl := ( S_CODEM == glob_mo[ _MO_KOD_TFOMS ] .and. TYPE_H_4 == 0 )
  Endif
  If fl
    fl := ( AScan( arr_year, Year( date_h_1 ) ) > 0 )
  Endif
  If fl .and. is_annul
    fl := ( TIP_ANNUL == 0 )
  Endif
  Return fl

// * 08.03.17 выбор фильтра направлений для госпитализации
Function f1_263_input_napr()

  Static s_arr := {}, si := 2
  Local fl, i, y, arr_p := {}, sast, a

  For y := Year( sys_date ) To 2014 Step -1
    AAdd( arr_p, { 'дата госпитализации ' + lstr( y ) + ' год', y } )
  Next
  sast := Array( Len( arr_p ) )
  AFill( sast, .f. )
  fl := .t.
  For i := 1 To Len( arr_p )
    If AScan( s_arr, arr_p[ i, 2 ] ) > 0
      sast[ i ] := .t.
      fl := .f.
    Endif
  Next
  If fl
    sast[ 1 ] := .t.
  Endif
  If ( a := bit_popup( T_ROW, T_COL + 5, arr_p, sast, color0 ) ) == NIL
    Return .f.
  Else
    s_arr := {}
    For i := 1 To Len( a )
      AAdd( s_arr, a[ i, 2 ] )
    Next
    If Empty( s_arr )
      For i := 1 To Len( arr_p )
        AAdd( s_arr, arr_p[ i, 2 ] )
      Next
    Endif
    arr_year := AClone( s_arr )
    fl := .f.
    If ( i := popup_prompt( T_ROW, T_COL + 5, si, { 'все направления на госпитализацию', ;
        'без учёта аннулированных' } ) ) > 0
      fl := .t.
      si := i
      is_annul := ( i == 2 )
    Endif
  Endif
  Return fl

// * 08.03.17 выбор направления для госпитализации
Function _263_input_napr()

  Local lkod := 0, buf := save_maxrow(), i, y, blk, t_arr[ BR_LEN ]

  Private arr_year, is_annul

  If !f1_263_input_napr()
    Return lkod
  Endif
  mywait()
  r_use( dir_server + 'kartotek', , '_KART' )
  g_use( dir_server + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into _KART
  Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
    For for_263_input_napr()
  Go Top
  If Eof()
    Close databases
    rest_box( buf )
    func_error( 4, 'Не обнаружено направлений с ещё не оформленными госпитализациями' )
    Return lkod
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Выбор направления для госпитализации'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, RB/BG, W+/RB, R/BG, W+/R, R/BG*, W+/R*', .f. }
  blk := {|| iif( Between( napr->TIP_ANNUL, 1, 3 ), { 7, 8 }, { 1, 2 } ) }
  /*blk := {|| iif(between(napr->TIP_ANNUL, 1, 3), {7, 8}, ;
               iif(napr->t_ans_2 == 0, ;
                   iif(empty(napr->date_h_2), {5, 6}, {3, 4}), {1, 2})) }*/
  t_arr[ BR_COLUMN ] := { { ' Ф.И.О.', {|| Left( _kart->fio, 36 ) }, blk }, ;
    { '№ направления', {|| PadR( napr->NUM_D, 13 ) }, blk }, ;
    { '  Дата;направ-я', {|| date_8( napr->DATE_D ) }, blk }, ;
    { '  Дата;гос.п-ки', {|| iif( Between( napr->TIP_ANNUL, 1, 3 ), 'аннулир.', date_8( napr->date_h_1 ) ) }, blk }, ;
    { 'условия;оказания ', {|| iif( napr->usl_ok_1 == 2, 'днев.стац', 'стационар' ) }, blk } }
  // {'  Дата;госп-ии', {|| date_8(napr->date_h_2) }, blk }}
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор направления для госпитализации' ) }
  t_arr[ BR_ENTER ] := {|| iif( Between( napr->TIP_ANNUL, 1, 3 ), func_error( 4, 'Данное направление аннулировано в ' + ;
    { 'СМО', 'стационаре', 'поликлинике' }[ napr->TIP_ANNUL ] + ' ' + date_8( napr->date_3 ) ), nil ), ;
    lkod := napr->kod }
  /*t_arr[BR_ENTER] := {|| iif(napr->t_ans_2== 0, ;
                           iif(empty(napr->date_h_2), ;
                               func_error(4, 'Вы ещё не подтвердили дату госпитализации по этому направлению'), ;
                               func_error(4, 'Вы ещё не получили подтверждения из ТФОМС по дате госпитализации')), ;
                           (iif(between(napr->TIP_ANNUL, 1, 3), func_error(4, 'Данное направление аннулировано в '+{'СМО','стационаре','поликлинике'}[napr->TIP_ANNUL]+' ' + date_8(napr->date_3)), nil), ;
                            lkod := napr->kod)) }*/
  edit_browse( t_arr )
  Close databases
  rest_box( buf )
  Return lkod

// 16.03.17 выписка (выбытие) пациента из стационара
Function _263_s_vybytie()

  Static str_sem := '_263_s_vybytie', si := 3
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ], fl, i

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  If ( i := popup_prompt( T_ROW, T_COL + 5, si, ;
      { '~Не введена дата выбытия (ещё лечатся)', ;
      'Поиск по дате ~госпитализации', ;
      'Поиск по дате ~выбытия' } ) ) == 0
    g_sunlock( str_sem )
    Return Nil
  Endif
  Private arr_m
  If ( si := i ) > 1 .and. ( arr_m := year_month( T_ROW, T_COL + 5 ) ) == NIL
    g_sunlock( str_sem )
    Return Nil
  Endif
  mywait()
  r_use( dir_server + 'kartotek', , '_KART' )
  r_use( dir_server + 'mo_nfile', , 'NF' )
  g_use( dir_server + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into _KART, To KOD_F_6out into NF
  If si == 1
    Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
      For KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. Empty( DATE_6 )
  Elseif si == 2
    Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
      For KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. Between( date_h_4, arr_m[ 5 ], arr_m[ 6 ] )
  Else
    Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
      For KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. Between( date_6, arr_m[ 5 ], arr_m[ 6 ] )
  Endif
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    rest_box( buf )
    Return func_error( 4, 'Не обнаружено госпитализаций по запрашиваемому условию' )
  Endif
  dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 6, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  napr->( dbEval( {|| dbSelectArea( 'TMP' ), dbAppend(), tmp->kod := napr->kod } ) )
  Select NAPR
  Set Index To
  Select TMP
  Set Relation To kod into NAPR
  Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp' )
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Госпитализации - даты выбытия'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R, N+/BG', .t. }
  blk := {|| iif( Empty( napr->KOD_F_6out ), { 3, 4 }, ;
    iif( napr->t_ans_6 == 0, { 5, 6 }, ;
    iif( napr->t_ans_6 == 1, { 1, 2 }, { 7, 8 } ) ) ) }
  Private mm_tip_vyb := { { 'выписан', 1 }, { 'умер', 2 }, { 'перевод в другое отделение', 3 } }
  t_arr[ BR_COLUMN ] := { { ' Ф.И.О.', {|| Left( _kart->fio, 29 ) }, blk }, ;
    { '  дата;госп-ии', {|| date_8( napr->date_h_4 ) }, blk }, ;
    { '  дата;выбытия', {|| date_8( napr->date_6 ) }, blk }, ;
    { '  тип;выбытия', {|| PadR( inieditspr( A__MENUVERT, mm_tip_vyb, napr->type_6 ), 7 ) }, blk }, ;
    { ' Статус', {|| PadR( f1_263_s_vybytie(), 22 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход ^<Enter>^ ред-ие даты выписки ^<Del>^ очистка даты выписки ^<F9>^ печать' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_s_vybytie( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 19.02.17
Function f1_263_s_vybytie()

  Local s := 'ошибка'

  If Empty( napr->KOD_F_6out )
    s := iif( Empty( napr->date_6 ), 'не введена дата выбытия', 'ещё не отправлено в ТФОМС' )
  Elseif napr->t_ans_6 == 0
    s := 'не получен ответ из ТФОМС'
  Elseif napr->t_ans_6 == 1
    s := 'получен ответ из ТФОМС'
  Endif
  Return s

// 04.06.23
Function f2_263_s_vybytie( nKey, oBrow, regim )

  Local ret := -1, rec, i, k, r1, tmp_color, buf, fl, s_error := '', ;
    n_file := cur_dir() + 'spisokne' + stxt(), sh := 84, HH := 80, t_arr[ 3 ], s1

  Do Case
  Case regim == 'edit'
    If nKey == K_F9
      rec := tmp->( RecNo() )
      arr_title := { ;
        '─────────────────────────────────────────┬──────┬────────┬──┬───────────────────────', ;
        '                                         │ диаг-│  дата  │ус│                       ', ;
        '            ФИО                          │ ноз  │госп-ии │ло│     профиль койки     ', ;
        '─────────────────────────────────────────┴──────┴────────┴──┴───────────────────────' }
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( PadL( 'дата печати ' + date_8( sys_date ) + ' ' + hour_min( Seconds() ), sh ) )
      add_string( '' )
      add_string( Center( 'Список пациентов, ещё не выбывших из стационара', sh ) )
      AEval( arr_title, {| x| add_string( x ) } )
      k := 0
      Go Top
      Do While !Eof()
        If Empty( napr->KOD_F_6out ) .and. Empty( napr->date_6 )
          s1 := PadR( lstr( ++k ) + '. ' + AllTrim( _kart->fio ), 41 ) + ' '
          s1 += napr->ds_4 + ' ' + date_8( napr->DATE_H_4 ) + ' '
          s1 += iif( napr->usl_ok_4 == 2, 'дн', 'ст' ) + ' '
          s1 += inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_4 )
          If verify_ff( HH -2, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( s1 )
          add_string( Replicate( '─', sh ) )
        Endif
        Select TMP
        Skip
      Enddo
      Select TMP
      Goto ( rec )
      FClose( fp )
      viewtext( n_file, , , , ( sh > 80 ), , , 5 )
    Elseif nKey == K_ENTER
      Private mfio    := _kart->fio, ;
        mdate_r := _kart->date_r, ;
        mpol    := _kart->pol, ;
        mkod    := napr->KOD, ;
        m1kod_k := napr->kod_k, ; // код по картотеке
      mforma, m1forma := napr->F_MEDC_4, ; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
      mdate_h := napr->DATE_H_4, ; // дата госпитализации
      mprofil_k, m1profil_k := napr->PROFIL_K_4, ; // профиль койки по справочнику T007
      mprofil, m1profil := napr->PROFIL_4, ; // профиль мед.помощи по справочнику V002
      mCODEM_FROM, m1CODEM_FROM := napr->CODEM_FROM, ;
        mnum_d  := napr->NUM_D, ;
        md_napr := napr->DATE_D, ; // дата направления
      mTYPE_H_4 := napr->TYPE_H_4, ;
        mnum_hist := napr->NUM_HIST_4, ;
        mdate_6 := napr->date_6, ;
        mtip, m1tip := napr->type_6, ;
        gl_area := { 1, 0, 23, 79, 0 }
      mtip := inieditspr( A__MENUVERT, mm_tip_vyb, m1tip )
      mforma := inieditspr( A__MENUVERT, getv014(), m1forma )
      mprofil_k := inieditspr( A__MENUVERT, arr_t007(), M1PROFIL_K )
      mprofil := inieditspr( A__MENUVERT, getv002(), M1PROFIL )
      If Empty( m1CODEM_FROM )
        mCODEM_FROM := Space( 10 )
      Else
        If m1CODEM_FROM == glob_mo[ _MO_KOD_TFOMS ]
          mCODEM_FROM := 'Поликлиники нашего МО'
        Else
          mCODEM_FROM := ret_mo( m1CODEM_FROM )[ _MO_SHORT_NAME ]
        Endif
      Endif
      If napr->t_ans_6 == 2
        r_use( dir_server + 'mo_nfina', , 'NFN' )
        Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == napr->KOD_F_6out
        find ( Str( napr->kod, 6 ) )
        If Found()
          s_error := 'ошибка ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
          If !Empty( nfn->IM_POL )
            s_error += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
          Endif
        Endif
        nfn->( dbCloseArea() )
        Select TMP
      Endif
      buf := SaveScreen()
      r1 := MaxRow() -15
      Do While .t.
        SetColor( cDataCGet )
        clrlines( r1, MaxRow() -1 )
        @ r1, 0 Say PadC( 'Ввод/редактирование даты выбытия', 80 ) Color 'B/B*'
        i := 0
        ++i
        @ r1 + i, 1 Say 'Пациент' Get mfio When .f.
        @ Row(), Col() + 2 Say 'Дата р.' Get mdate_r When .f.
        Do Case
        Case mTYPE_H_4 == 1
          ++i
          @ r1 + i, 1 Say 'Направлен из' Color color8 Get mCODEM_FROM When .f.
          ++i
          @ r1 + i, 1 Say ' направление: №' Color color8 Get mnum_d When .f.
          @ Row(), Col() + 1 Say 'от' Color color8 Get md_napr When .f.
        Case mTYPE_H_4 == 2
          ++i
          @ r1 + i, 1 Say 'Переведён из' Color color8 Get mCODEM_FROM When .f.
        Case mTYPE_H_4 == 3
          ++i
          @ r1 + i, 1 Say 'Переведён внутри МО из стационарного отделения в стационарное отделение' Color color8
        Case mTYPE_H_4 == 4
          ++i
          @ r1 + i, 1 Say 'Госпитализация по неотложным или экстренным показаниям' Color color8
        Endcase
        ++i
        @ r1 + i, 1 Say 'Форма оказания медицинской помощи' Get mforma When .f.
        ++i
        @ r1 + i, 1 Say 'Профиль койки' Get mprofil_k When .f.
        ++i
        @ r1 + i, 1 Say 'Профиль медицинской помощи' Get mprofil When .f.
        ++i
        @ r1 + i, 1 Say 'Дата госпитализации (в нашем стационаре)' Get mdate_h When .f.
        ++i
        @ r1 + i, 1 Say 'Номер истории болезни' Get mnum_hist When .f.
        ++i
        @ r1 + i, 1 Say 'Тип выбытия' Get mtip ;
          reader {| x| menu_reader( x, mm_tip_vyb, A__MENUVERT, , , .f. ) }
        ++i
        @ r1 + i, 1 Say 'Дата выбытия' Get mdate_6
        If !Empty( s_error )
          ++i
          @ r1 + i, 1 Say s_error Color color8
        Endif
        fl := .t.
        If Empty( napr->KOD_F_6out )
          fl := .f.
        Elseif !Empty( nf->NAME_F )
          ++i
          @ r1 + i, 1 Say '(в файле ' + AllTrim( nf->NAME_F ) + ')' Color color8
        Endif
        If napr->t_ans_6 == 2
          fl := .f.
        Endif
        If !fl .and. m1tip == 3 .and. napr->KOD_NEXT > 0
          fl := .t.
        Endif
        If fl
          stat_msg( 'Ответ из ТФОМС ' + iif( napr->t_ans_6 == 0, 'ещё не', 'уже' ) + ' получен. Редактирование запрещено!' )
          mybell( 0, ERR )
          clear_gets()
          SetColor( tmp_color )
          RestScreen( buf )
          Return ret
        Endif
        status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
        myread()
        k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
          { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
          if( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
        If k == 3
          Loop
        Elseif k == 2
          If m1tip == 0
            func_error( 4, 'Не введён тип выбытия.' )
            Loop
          Endif
          If m1tip == 3
            func_error( 4, 'Режим перевода пока не реализован.' )
            Loop
          Endif
          If Empty( mdate_6 )
            func_error( 4, 'Не введена дата выбытия.' )
            Loop
          Endif
          If mdate_6 < mdate_h
            func_error( 4, 'Дата выбытия меньше даты госпитализации.' )
            Loop
          Endif
          Select NAPR
          g_rlock( forever )
          napr->TYPE_6 := m1tip         // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
          napr->KOD_NEXT := 0           // код следующей госпитализации (после перевода в др.отд-ие)
          napr->ID_6 := mo_guid( 1, mkod ) // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
          napr->DATE_6 := mdate_6       // дата выбытия
          napr->KOD_F_6out := 0         // код файла - по файлу mo_nfile
          napr->KOD_F_6in := 0          // код файла - по файлу mo_nfile
          dbUnlock()
          Commit
          Select TMP
          ret := 0
        Endif
        Exit
      Enddo
      SetColor( tmp_color )
      RestScreen( buf )
    Elseif nKey == K_DEL .and. !Empty( napr->DATE_6 )
      If Empty( napr->KOD_F_6out )
        If napr->TYPE_6 == 3 // выбытие: 3-перевод внутри нашего МО
          func_error( 4, 'Режим удаления перевода пока не реализован.' )
        Elseif f_esc_enter( 'очистки даты выписки', .t. )
          Select NAPR
          g_rlock( forever )
          napr->TYPE_6 := 0             // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
          napr->KOD_NEXT := 0           // код следующей госпитализации (после перевода в др.отд-ие)
          napr->ID_6 := ''              // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
          napr->DATE_6 := CToD( '' )      // дата выбытия
          napr->KOD_F_6out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_6in := 0 // код файла - по файлу mo_nfile
          dbUnlock()
          Commit
          Select TMP
          ret := 1
        Endif
      Elseif napr->t_ans_6 == 1
        func_error( 4, 'Ответ из ТФОМС уже получен. Очистка даты выписки запрещена!' )
      Endif
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

// 08.03.17
Function for_263_s_napr()

  Local fl := .t.

  If KOD_F_1in > 0
    //
  Elseif T_ANS_1 == 1 .and. CODEM_1 == glob_mo[ _MO_KOD_TFOMS ]
    //
  Else
    fl := .f.
  Endif
  If fl
    fl := ( S_CODEM == glob_mo[ _MO_KOD_TFOMS ] .and. TYPE_H_4 == 0 )
  Endif
  If fl
    fl := ( napr->KOD_F_4out == 0 .and. Between( date_d, arr_m[ 5 ], arr_m[ 6 ] ) )
  Endif
  Return fl

// 08.03.17 работа с направлениями на госпитализацию в стационаре
Function _263_s_napr()

  Static str_sem := '_263_s_napr', si := 1
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ], fl, i, n

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  /*if (i := popup_prompt(T_ROW, T_COL + 5,si, ;
            {'~Не подтверждена дата госпитализации пол-ки', ;
             'По дате ~госпитализации, введённой в стационаре', ;
             'По дате ~ввода даты госпитализации в стационаре', ;
             'Вернувшиеся с ~ошибкой из ТФОМС'})) == 0
    G_SUnLock(str_sem)
    return NIL
  endif*/
  Private arr_m
  // si := i
  If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) == NIL
    g_sunlock( str_sem )
    Return Nil
  Endif
  mywait()
  r_use( dir_server + 'kartotek', , '_KART' )
  r_use( dir_server + 'mo_nfile', , 'NF' )
  g_use( dir_server + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into _KART// , to KOD_F_2out into NF
  Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
    For for_263_s_napr()
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    rest_box( buf )
    Return func_error( 4, 'Не обнаружено направлений ' + arr_m[ 4 ] )
  Endif
  dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 6, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  napr->( dbEval( {|| dbSelectArea( 'TMP' ), dbAppend(), tmp->kod := napr->kod } ) )
  Select NAPR
  Set Index To
  Select TMP
  Set Relation To kod into NAPR
  Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp' )
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Список направлений ' + arr_m[ 4 ]
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R, R/BG*, W+/R*', .t. }
  blk := {|| iif( Between( napr->TIP_ANNUL, 1, 3 ), { 9, 10 }, iif( napr->type_h_4 > 0, { 1, 2 }, { 3, 4 } ) ) }
  /*blk := {|| iif(between(napr->TIP_ANNUL, 1, 3), {9, 10}, ;
               iif(empty(napr->KOD_F_2out), {3, 4}, ;
                   iif(napr->t_ans_2== 0, {5, 6}, ;
                       iif(napr->t_ans_2== 1, {1, 2}, {7, 8} )))) }*/
  n := iif( work_otd_263 == 1, 23, 29 )
  t_arr[ BR_COLUMN ] := { { '№ направления', {|| Left( napr->NUM_D, 13 ) }, blk }, ;
    { '  Дата', {|| date_8( napr->date_d ) }, blk }, ;
    { ' Ф.И.О.', {|| Left( _kart->fio, n ) }, blk }, ;
    { 'ус;ок', {|| iif( napr->usl_ok_1 == 2, 'дн', 'ст' ) }, blk }, ;
    { ' Статус', {|| PadR( f1_263_s_napr(), 22 ) }, blk } }
  If work_otd_263 == 1
    ins_array( t_arr[ BR_COLUMN ], 5, { ' Отд.', {|| _263_put_otd( iif( Empty( napr->otd_4 ), napr->otd_1, napr->otd_4 ) ) }, blk } )
  Endif
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход   ^<Enter>^ просмотр   ^<F9>^ печать' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_s_napr( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 13.05.22
Function f1_263_s_napr()

  Local s := ' направлено в стационар'

  If napr->KOD_F_6out > 0
    s := ' выбытие ' + date_8( napr->date_6 )
  Elseif napr->type_h_4 > 0
    s := 'госпитализир. ' + date_8( napr->date_h_4 )
  Elseif napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
    s := 'аннулировано ' + date_8( napr->date_3 )
  Endif
  Return s

// 04.06.23
Function f2_263_s_napr( nKey, oBrow, regim )

  Static s_arr
  Local ret := -1, rec, i, k, tmp_color, buf, s_error := '', arr_p := {}, sast := {}, a, fl, ;
    tmp_V006 := { { 'Стационар', 1 }, { 'Дневной стационар', 2 } }, ;
    n_file := cur_dir() + 'spisok' + stxt(), sh := 84, HH := 60, t_arr[ 3 ], s1, s2, s3

  Do Case
  Case regim == 'edit'
    If nKey == K_F9 .and. ( k := f_alert( { PadC( 'Выберите вариант печати списка направлений', 60, '.' ) }, ;
        { ' Без аннулированных ', ' Все направления ' }, ;
        1, 'W+/N', 'N+/N', MaxRow() -3, , 'W+/N, N/BG' ) ) > 0
      Select TMP
      rec := RecNo()
      Go Top
      Do While !Eof()
        If iif( k == 2, .t., !( napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0 ) ) .and. ;
            AScan( arr_p, {| x| x[ 2 ] == napr->PROFIL_K_1 } ) == 0
          AAdd( arr_p, { inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_1 ), ;
            napr->PROFIL_K_1 } )
        Endif
        Skip
      Enddo
      Goto ( rec )
      If Len( arr_p ) == 1
        s_arr := { arr_p[ 1, 2 ] }
      Else
        Default s_arr TO {}
        ASort( arr_p, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        sast := Array( Len( arr_p ) )
        AFill( sast, .f. )
        fl := .t.
        For i := 1 To Len( arr_p )
          If AScan( s_arr, arr_p[ i, 2 ] ) > 0
            sast[ i ] := .t.
            fl := .f.
          Endif
        Next
        If fl
          AFill( sast, .t. )
        Endif
        If ( a := bit_popup( T_ROW, T_COL + 5, arr_p, sast, color5 ) ) == NIL
          Return ret
        Else
          s_arr := {}
          For i := 1 To Len( a )
            AAdd( s_arr, a[ i, 2 ] )
          Next
        Endif
      Endif
      arr_title := { ;
        '────────────────────────────┬──────────────────────┬───────────────────────┬────────', ;
        '                            │                      │    диагноз, форма     │  дата  ', ;
        'ФИО и дата рождения пациента│     направление      │профиль койки(мед.пом.)│госп-ии ', ;
        '────────────────────────────┴──────────────────────┴───────────────────────┴────────' }
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( Center( 'Направления на госпитализацию ' + arr_m[ 4 ], sh ) )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      Do While !Eof()
        If iif( k == 2, .t., !( napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0 ) ) .and. AScan( s_arr, napr->PROFIL_K_1 ) > 0
          s := AllTrim( _kart->fio ) + ' д.р.' + full_date( _kart->date_r )
          perenos( t_arr, s, 28 )
          s1 := PadR( t_arr[ 1 ], 29 )
          s2 := PadR( t_arr[ 2 ], 29 )
          s3 := PadR( t_arr[ 3 ], 29 )
          s := PadR( napr->NUM_D, 14 ) + date_8( napr->DATE_D ) + ' ' + ret_mo( napr->CODEM_1 )[ _MO_SHORT_NAME ]
          perenos( t_arr, s, 22 )
          s1 += PadR( t_arr[ 1 ], 23 )
          s2 += PadR( t_arr[ 2 ], 23 )
          s3 += PadR( t_arr[ 3 ], 23 )
          s := RTrim( napr->ds_1 ) + ' ' + ;
            inieditspr( A__MENUVERT, getv014(), napr->F_MEDC_1 ) + ' ' + ;
            inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_1 ) + ' (' + ;
            inieditspr( A__MENUVERT, getv002(), napr->PROFIL_1 ) + ')'
          perenos( t_arr, s, 23 )
          s1 += PadR( t_arr[ 1 ], 24 ) + date_8( napr->DATE_H_1 )
          s2 += PadR( t_arr[ 2 ], 24 ) + iif( napr->usl_ok_1 == 2, 'дневной', 'стационар' )
          s3 += PadR( t_arr[ 3 ], 24 ) + iif( napr->usl_ok_1 == 2, 'стационар', '' )
          If verify_ff( HH -4, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( s1 )
          add_string( s2 )
          add_string( s3 )
          add_string( Replicate( '─', sh ) )
        Endif
        Select TMP
        Skip
      Enddo
      Select TMP
      Goto ( rec )
      FClose( fp )
      viewtext( n_file, , , , ( sh > 80 ), , , 2 )
    Elseif nKey == K_ENTER
      Private mn_napr := napr->NUM_D, md_napr := napr->DATE_D, ;
        mpol_mo := Space( 10 ), m1pol_mo := napr->CODEM_1, ;
        mfio    := _kart->fio, ;
        mdate_r := _kart->date_r, ;
        mpol    := _kart->pol, ;
        mkod    := napr->KOD, ;
        m1kod_k := napr->kod_k, ; // код по картотеке
      mkod_diag := napr->ds_1, ; // диагноз поликлиники
      mforma, m1forma := napr->F_MEDC_1, ; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
      mdate_hosp := napr->DATE_H_1, ; // планируемая дата госпитализации
      mprofil_k, m1profil_k := napr->PROFIL_K_1, ; // профиль койки по справочнику T007
      mprofil, m1profil := napr->PROFIL_1, ; // профиль мед.помощи по справочнику V002
      musl_ok, m1usl_ok := napr->usl_ok_1, ; // условия оказания мед.помощи
      mdate_2 := iif( Empty( napr->date_2 ), sys_date, napr->date_2 ), ;
        mdate_h_2 := iif( Empty( napr->date_h_2 ), napr->date_h_1, napr->date_h_2 ), ;
        motd := Space( 10 ), m1otd := napr->otd_2, ;
        gl_area := { 1, 0, 23, 79, 0 }
      If work_otd_263 == 1
        Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
        make_arr_uch_otd( mdate_h_2 )
        If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
          motd := pr_arr[ i, 2 ]
        Elseif nKey == K_ENTER .and. m1otd > 0
          motd := '! некорректное отделение !'
        Endif
      Endif
      mforma := inieditspr( A__MENUVERT, getv014(), m1forma )
      mprofil_k := inieditspr( A__MENUVERT, arr_t007(), M1PROFIL_K )
      mprofil := inieditspr( A__MENUVERT, getv002(), M1PROFIL )
      mUSL_OK := inieditspr( A__MENUVERT, tmp_V006, m1USL_OK )
      If !Empty( m1pol_mo )
        If m1pol_mo == glob_mo[ _MO_KOD_TFOMS ]
          mpol_mo := 'Поликлиника нашего МО'
        Else
          mpol_mo := ret_mo( m1pol_mo )[ _MO_SHORT_NAME ]
        Endif
      Endif
      If napr->t_ans_2 == 2
        r_use( dir_server + 'mo_nfina', , 'NFN' )
        Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == napr->KOD_F_2out
        find ( Str( napr->kod, 6 ) )
        If Found()
          s_error := 'ошибка ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
          If !Empty( nfn->IM_POL )
            s_error += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
          Endif
        Endif
        nfn->( dbCloseArea() )
        Select TMP
      Endif
      buf := SaveScreen()
      Private r1 := MaxRow() -15
      If work_otd_263 == 1
        --r1
      Endif
      SetColor( cDataCGet )
      clrlines( r1, MaxRow() -1 )
      @ r1 -1, 0 Say PadC( 'Просмотр направления на госпитализацию', 80 ) Color 'B/B*'
      i := r1
      @ ++i, 1 Say 'Пациент' Get mfio When .f.
      @ Row(), Col() + 2 Say 'Дата р.' Get mdate_r When .f.
      @ ++i, 1 Say 'направление: №' Get mn_napr When .f.
      @ Row(), Col() + 3 Say 'дата' Get md_napr When .f.
      @ ++i, 1 Say 'Диагноз направившего учреждения' Get mkod_diag When .f.
      @ ++i, 1 Say 'Направившее учреждение' Get mpol_mo When .f.
      @ ++i, 1 Say 'Форма оказания медицинской помощи' Get mforma When .f.
      @ ++i, 1 Say 'Условия оказания, в которые направляется пациент' Get musl_ok
      tmp_V006 := { { 'Стационар', 1 }, { 'Дневной стационар', 2 } }
      @ ++i, 1 Say 'Профиль койки' Get mprofil_k When .f.
      @ ++i, 1 Say 'Профиль медицинской помощи' Get mprofil When .f.
      @ ++i, 1 Say 'Планируемая дата госпитализации' Get mdate_hosp When .f.
      If work_otd_263 == 1
        @ ++i, 1 Say '  будет госпитализирован в отделение'
        If mem_kodotd == 1
          @ Row(), Col() + 1 Get motd ;
            reader {| x| menu_reader( x, { {| k, r, c| get_otd( k, r + 1, c, .f. ) } }, A__FUNCTION, , , .f. ) }
        Else
          @ Row(), Col() + 1 Get m1otd Pict '99' ;
            when {| g| f5editkusl( g, 1, 10 ) } ;
            valid {| g| f5editkusl( g, 2, 10 ) }
          @ Row(), Col() + 2 Get motd Color color14 When .f.
        Endif
      Endif
      If !Empty( s_error )
        @ ++i, 1 Say s_error Color color8
      Endif
      If !( Empty( napr->KOD_F_2out ) .or. napr->t_ans_2 == 2 )
        s := ''
        If napr->KOD_F_6out > 0
          s := 'выбыл из стационара ' + date_8( napr->date_6 )
        Elseif napr->KOD_F_4out > 0
          s := 'госпитализирован в стационар ' + date_8( napr->date_h_4 )
        Elseif napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
          s := 'направление аннулировано ' + date_8( napr->date_3 ) + ' в '
          If napr->TIP_ANNUL == 1
            s += 'СМО'
          Elseif napr->TIP_ANNUL == 2
            s += 'стационаре'
          Else
            s += 'поликлинике'
          Endif
        Endif
        @ ++i, 1 Say s Color color8
        stat_msg( 'Ответ из ТФОМС ' + iif( napr->t_ans_2 == 0, 'ещё не', 'уже' ) + ' получен. Редактирование запрещено!' )
      Else
        status_key( '^<Esc>^ - выход' )
      Endif
      clear_gets()
      Inkey( 0 )
      SetColor( tmp_color )
      RestScreen( buf )
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

// 08.03.17
Function for_263_s_annul()

  Local fl := ( S_CODEM == glob_mo[ _MO_KOD_TFOMS ] )

  If KOD_F_1in > 0
    //
  Elseif T_ANS_1 == 1 .and. CODEM_1 == glob_mo[ _MO_KOD_TFOMS ]
    //
  Else
    fl := .f.
  Endif
  If fl
    fl := ( !Empty( napr->date_3 ) .or. Empty( KOD_F_4out ) ) // и не госпитализирован
  Endif
  If fl
    fl := Between( date_h_1, arr_m[ 5 ], arr_m[ 6 ] )
  Endif
  Return fl

// 21.02.17 Аннулирование направлений, поступивших из поликлиник через ТФОМС
Function _263_s_annul()

  Static str_sem := '_263_s_annul', si := 1
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ], fl, i, n

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  /*if (i := popup_prompt(T_ROW, T_COL + 5,si, ;
            {'~Не подтверждена дата госпитализации пол-ки', ;
             'По дате ~госпитализации, введённой в стационаре', ;
             'По дате ~ввода даты госпитализации в стационаре'})) == 0
    G_SUnLock(str_sem)
    return NIL
  endif*/
  Private arr_m
  If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) == NIL
    g_sunlock( str_sem )
    Return Nil
  Endif
  mywait()
  r_use( dir_server + 'kartote_', , '_KART_' )
  r_use( dir_server + 'kartotek', , '_KART' )
  Set Relation To kod into _KART_
  r_use( dir_server + 'mo_nfile', , 'NF' )
  g_use( dir_server + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into _KART, To KOD_F_3out into NF
  Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
    For for_263_s_annul()
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    rest_box( buf )
    Return func_error( 4, 'Не обнаружено направлений по запрашиваемому условию' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Аннулирование направлений на госпитализацию в стационаре'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_OPEN ] := {|| f2_263_s_annul( , , 'open' ) }
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t. }
  blk := {|| iif( !Empty( napr->KOD_F_3in ), { 1, 2 }, ;
    iif( Empty( napr->KOD_F_3out ), { 3, 4 }, ;
    iif( napr->t_ans_3 == 0, { 5, 6 }, ;
    iif( napr->t_ans_3 == 1, { 1, 2 }, { 7, 8 } ) ) ) ) }
  n := iif( work_otd_263 == 1, 23, 29 )
  t_arr[ BR_COLUMN ] := { { '№ направления', {|| Left( napr->NUM_D, 13 ) }, blk }, ;
    { '  Дата', {|| date_8( napr->date_d ) }, blk }, ;
    { ' Ф.И.О.', {|| Left( _kart->fio, n ) }, blk }, ;
    { 'ус;ок', {|| iif( napr->usl_ok_1 == 2, 'дн', 'ст' ) }, blk }, ;
    { ' Статус', {|| PadR( f1_263_s_annul(), 22 ) }, blk } }
  If work_otd_263 == 1
    ins_array( t_arr[ BR_COLUMN ], 5, { ' Отд.', {|| _263_put_otd( napr->otd_1 ) }, blk } )
  Endif
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход ^<Enter>^ просмотр/аннулирование ^<Del>^ удаление аннулирования' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_s_annul( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 08.03.17
Function f1_263_s_annul()

  Local s := 'ошибка'

  If Empty( napr->date_3 )
    If napr->TYPE_H_4 == 0
      s := 'ещё не госпитализирован'
    Elseif Empty( napr->KOD_F_4out )
      s := 'ещё не отправлено в ТФОМС'
    Else
      s := 'отправлено в ТФОМС'
    Endif
  Elseif napr->TIP_ANNUL == 2
    If Empty( napr->KOD_F_3out )
      s := 'аннул/не отправлен в ТФ'
    Elseif napr->t_ans_3 == 0
      s := 'аннул/не получен ответ'
    Elseif napr->t_ans_3 == 1
      s := 'аннулировано ' + date_8( napr->date_3 )
    Endif
  Elseif napr->TIP_ANNUL == 1
    s := 'аннулировано в СМО'
  Elseif napr->TIP_ANNUL == 3
    s := 'аннулировано в поликлинике'
  Endif
  Return s

// 04.06.23
Function f2_263_s_annul( nKey, oBrow, regim )

  Local ret := -1, rec, i, k, s, tmp_color, buf, s_error := '', ;
    tmp_V006 := { { 'Стационар', 1 }, { 'Дневной стационар', 2 } }

  Do Case
  Case regim == 'open'
    Select NAPR
    Go Top
    ret := !Eof()
  Case regim == 'edit'
    If napr->KOD > 0 .and. nKey == K_ENTER
      rec := napr->( RecNo() )
      tmp_color := SetColor()
      buf := SaveScreen()
      mywait()
      Private ;
        mn_napr := napr->NUM_D, ; // уникальный номер направления (п-ка)
      md_napr := napr->DATE_D, ; // дата направления
      mpol_mo := Space( 10 ), m1pol_mo := napr->CODEM_1, ;
        mfio    := _kart->fio, ;
        mdate_r := _kart->date_r, ;
        mpol    := _kart->pol, ;
        mkod    := napr->KOD, ;
        m1kod_k := napr->kod_k, ; // код по картотеке
      mkod_diag := napr->ds_1, ; // диагноз поликлиники
      musl_ok, m1usl_ok := iif( napr->usl_ok_1 == 2, 2, 1 ), ; // условия оказания мед.помощи
      mforma, m1forma := napr->F_MEDC_1, ; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
      mdate_hosp := napr->DATE_H_1, ; // планируемая дата госпитализации
      mprofil_k, m1profil_k := napr->PROFIL_K_1, ; // профиль койки по справочнику T007
      mprofil, m1profil := napr->PROFIL_1, ; // профиль мед.помощи по справочнику V002
      motd := Space( 10 ), m1otd := napr->otd_1, ;
        mdate_3 := napr->date_3, ;
        mrea_annul := Space( 10 ), m1rea_annul := napr->rea_annul, ;
        gl_area := { 1, 0, 23, 79, 0 }
      If work_otd_263 == 1
        Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
        make_arr_uch_otd( md_napr )
        If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
          motd := pr_arr[ i, 2 ]
        Elseif m1otd > 0
          motd := '! некорректное отделение !'
        Endif
      Endif
      mUSL_OK := inieditspr( A__MENUVERT, tmp_V006, m1USL_OK )
      mforma := inieditspr( A__MENUVERT, getv014(), m1forma )
      mprofil_k := inieditspr( A__MENUVERT, arr_t007(), M1PROFIL_K )
      mprofil := inieditspr( A__MENUVERT, getv002(), M1PROFIL )
      mrea_annul := inieditspr( A__MENUVERT, get_reason_annul(), m1rea_annul )
      If !Empty( m1pol_mo )
        If m1pol_mo == glob_mo[ _MO_KOD_TFOMS ]
          mpol_mo := 'Поликлиника нашего МО'
        Else
          mpol_mo := ret_mo( m1pol_mo )[ _MO_SHORT_NAME ]
        Endif
      Endif
      Private r1 := MaxRow() -15
      // if work_otd_263 == 1
      // --r1
      // endif
      Do While .t.
        SetColor( cDataCGet )
        clrlines( r1, MaxRow() -1 )
        @ r1 -1, 0 Say PadC( 'Аннулирование направления на госпитализацию', 80 ) Color 'B/B*'
        i := r1
        @ ++i, 1 Say 'Пациент' Get mfio When .f.
        @ Row(), Col() + 2 Say 'Дата р.' Get mdate_r When .f.
        @ ++i, 1 Say 'направление: №' Get mn_napr When .f.
        @ Row(), Col() + 3 Say 'дата' Get md_napr When .f.
        @ ++i, 1 Say 'Направившее учреждение' Get mpol_mo When .f.
        @ ++i, 1 Say 'Диагноз направившего учреждения' Get mkod_diag When .f. Picture '@K@!'
        @ ++i, 1 Say 'Условия оказания, в которые направляется пациент' Get musl_ok When .f.
        @ ++i, 1 Say 'Форма оказания медицинской помощи' Get mforma When .f.
        @ ++i, 1 Say 'Профиль койки' Get mprofil_k When .f.
        @ ++i, 1 Say 'Профиль медицинской помощи' Get mprofil When .f.
        @ ++i, 1 Say 'Планируемая дата госпитализации направившего учреждения' Get mdate_hosp When .f.
          /*if !empty(napr->KOD_F_2out)
            @ ++i, 1 say 'Планируемая дата госпитализации (нашего стационара)' get mdate_h_2 when .f.
            @ ++i, 1 say 'Дата ввода даты госпитализации (в стационаре)' get mdate_2 when .f.
            if work_otd_263 == 1
              @ ++i, 1 say '       будет госпитализирован в отделение' get motd when .f.
            endif
          endif*/
        @ ++i, 1 Say 'Причина аннулирования' Get mrea_annul ;
          reader {| x| menu_reader( x, get_reason_annul(), A__MENUVERT, , , .f. ) }
        @ ++i, 1 Say 'Дата аннулирования' Get mdate_3
        If napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0 .or. eq_any( napr->TIP_ANNUL, 1, 3 )
          s_msg := ''
          s := 'Направление аннулировано в '
          If napr->TIP_ANNUL == 1
            s += 'СМО'
            s_msg := s
          Elseif napr->TIP_ANNUL == 2
            s += 'нашем стационаре'
          Else
            s += 'поликлинике'
            s_msg := s
          Endif
          If !Empty( napr->KOD_F_3out ) .and. !Empty( nf->NAME_F )
            s += ' (в файле ' + AllTrim( nf->NAME_F ) + ')'
          Endif
          @ ++i, 1 Say s Color color8
          If Empty( s_msg )
            s_msg := 'Ответ из ТФОМС ' + iif( napr->t_ans_3 == 0, 'ещё не', 'уже' ) + ' получен'
          Endif
          stat_msg( s_msg + '. Редактирование запрещено!' )
          mybell( 0, ERR )
          clear_gets()
          SetColor( tmp_color )
          RestScreen( buf )
          Return ret
        Endif
        status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
        myread()
        k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
          { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
          iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
        If k == 3
          Loop
        Elseif k == 2
          If Empty( mdate_3 )
            func_error( 4, 'Не введена дата аннулирования.' )
            Loop
          Endif
          If Empty( m1rea_annul )
            func_error( 4, 'Не введена причина аннулирования.' )
            Loop
          Endif
          If mdate_3 < md_napr
            func_error( 4, 'Дата аннулирования меньше даты направления.' )
            Loop
          Endif
            /*if !empty(mdate_h_2)
              if mdate_h_2 < mdate_3
                func_error(4, 'Дата госпитализации стационара меньше даты аннулирования.')
                loop
              endif
            elseif mdate_hosp < mdate_3
              func_error(4, 'Дата госпитализации поликлиники меньше даты аннулирования.')
              loop
            endif*/
          Select NAPR
          Goto ( rec )
          g_rlock( forever )
          napr->DATE_3 := mdate_3 // дата аннулирования
          napr->TIP_ANNUL := 2  // ануллировано в стационаре
          napr->rea_annul := m1rea_annul // причина аннулирования
          napr->KOD_F_3out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_3in := 0 // код файла - по файлу mo_nfile
          dbUnlock()
          Commit
          ret := 0
        Endif
        Exit
      Enddo
      SetColor( tmp_color )
      RestScreen( buf )
    Elseif nKey == K_DEL .and. napr->TIP_ANNUL == 2
      If Empty( napr->KOD_F_3out ) .or. napr->t_ans_3 == 2
        If f_esc_enter( 2, .t. )
          Select NAPR
          g_rlock( forever )
          napr->DATE_3 := CToD( '' ) // дата аннулирования
          napr->TIP_ANNUL := 0  // ануллировано в поликлинике
          napr->rea_annul := 0 // причина аннулирования
          napr->KOD_F_3out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_3in := 0 // код файла - по файлу mo_nfile
          dbUnlock()
          Commit
          ret := 0
        Endif
      Elseif !Empty( napr->KOD_F_3out )
        If napr->t_ans_3 == 1
          func_error( 4, 'Аннулирование данного направления уже отправлено в ТФОМС!' )
        Else
          func_error( 4, 'Ответ из ТФОМС ещё не получен. Удаление данного аннулирования запрещено!' )
        Endif
      Endif
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

// 04.06.23 Ввод / редактирование количества свободных коек по профилям в стационаре
Function _263_s_svob_kojki()

  Static str_sem := '_263_s_svob_kojki'
  Local buf, blk, t_arr[ BR_LEN ], fl := .t., k := 0

  If !g_slock( str_sem )
    Return func_error( 4, err_slock )
  Endif
  g_use( dir_server + 'mo_n7d', , 'D7' )
  If LastRec() == 0
    Append Blank
    Unlock
  Endif
  buf := SaveScreen()
  Private mdate_r := iif( Empty( d7->DATE_R_EDI ), sys_date, d7->DATE_R_EDI )
  box_shadow( T_ROW, 2, T_ROW + 7, 77, color1 )
  tmp_color := SetColor( cDataCGet )
  If Empty( d7->DATE_R_OUT )
    @ T_ROW + 2, 4 Say 'Данные ещё ни разу не отправлялись в ТФОМС'
  Else
    @ T_ROW + 2, 4 Say 'Последний раз данные в ТФОМС отправлены за отчётную дату ' + date_8( d7->DATE_R_OUT ) + 'г.'
  Endif
  @ T_ROW + 3, 4 Say 'Последний раз данные редактировались ' + date_8( d7->DATE_E ) + 'г. в ' + d7->TIME_E + ;
    ' - ' + iif( d7->END_EDIT == 1, '', 'не ' ) + 'завершено'
  If d7->KOD_OPER > 0
    r_use( dir_server + 'base1', , 'base1' )
    Goto ( d7->KOD_OPER )
    @ T_ROW + 4, 4 Say 'Данные редактировал пользователь: ' + Crypt( base1->p1, gpasskod )
    base1->( dbCloseArea() )
  Endif
  @ T_ROW + 5, 4 Say 'Отчётная дата для направления сведений (по состоянию на 09:00)' Get mdate_r
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода отчётной даты и ред-ие свободных коек' )
  myread()
  SetColor( tmp_color )
  If LastRec() == K_ESC
    fl := .f.
  Elseif Empty( mdate_r )
    fl := func_error( 4, 'Не введена отчётная дата' )
  Elseif mdate_r > sys_date + 1
    fl := func_error( 4, 'Отчётная дата больше системной' )
  Elseif !Empty( d7->DATE_R_OUT ) .and. mdate_r <= d7->DATE_R_OUT
    fl := func_error( 4, 'Некорректная отчётная дата. В ТФОМС уже был направлен пакет I07 за ' + date_8( d7->DATE_R_OUT ) + 'г.' )
  Endif
  RestScreen( buf )
  If !fl
    Close databases
    g_sunlock( str_sem )
    Return Nil
  Endif
  If mdate_r != d7->DATE_R_EDI
    Select D7
    g_rlock( forever )
    d7->DATE_R_EDI := mdate_r
    Unlock
    Commit
  Endif
  g_use( dir_server + 'mo_n7out', , 'N7' )
  Index On PadR( inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ), 60 ) + Str( PROFIL_K, 3 ) + Str( usl_ok, 1 ) + ;
    PadR( inieditspr( A__MENUVERT, getv002(), n7->PROFIL ), 20 ) + Str( PROFIL, 3 ) to ( cur_dir() + 'tmp_n7' )
  Go Top
  //
  box_shadow( 0, 0, 4, 79, color1, 'Редактирование количества свободных коек по профилям в стационаре', color14 )
  If Empty( d7->DATE_R_OUT )
    @ 1, 2 Say 'Данные ещё ни разу не отправлялись в ТФОМС' Color color1
  Else
    @ 1, 2 Say 'Последний раз данные в ТФОМС отправлены за отчётную дату ' + date_8( d7->DATE_R_OUT ) + 'г.' Color color1
  Endif
  @ 2, 2 Say 'Последний раз данные редактировались ' + date_8( d7->DATE_E ) + 'г. в ' + d7->TIME_E + ;
    ' - ' + iif( d7->END_EDIT == 1, '', 'не ' ) + 'завершено' Color color1
  @ 3, 2 Say 'Отчётная дата для направления сведений (по состоянию на 09:00) ' + date_8( d7->DATE_R_EDI ) Color color1
  t_arr[ BR_TOP ] := 5
  t_arr[ BR_BOTTOM ] := MaxRow() -5
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_OPEN ] := {|| f2_263_s_svob_kojki( , , 'open' ) }
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, R/BG, W+/R', .t. }
  blk := {|| f0_263_s_svob_kojki() }
  t_arr[ BR_COLUMN ] := { { ' ', {|| iif( n7->usl_ok == 2, 'д', 'с' ) }, blk }, ;
    { ' Профиль койки', {|| PadR( inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ), 16 ) }, blk }, ;
    { 'Профиль м/пом.', {|| PadR( inieditspr( A__MENUVERT, getv002(), n7->PROFIL ), 14 ) }, blk }, ;
    { 'сро;леч;к/д', {|| put_val( n7->kol_kd, 3 ) }, {|| { 5, 5 } } }, ; //
  { 'Кол.;коек', {|| put_val( n7->QUANTITY, 4 ) }, blk }, ; // количество коек
  { 'сост;на;пред', {|| put_val( n7->Q_P, 4 ) }, blk }, ; // состояло пациентов на начало пред.суток
  { 'пост;за;пред', {|| put_val( n7->Q_AP, 4 ) }, blk }, ; // поступило пациентов за пред.сутки
  { 'выбы;за;пред', {|| put_val( n7->Q_DP, 4 ) }, blk }, ; // выбыло пациентов за пред.сутки
  { 'зап;гос;тек', {|| put_val( n7->Q_HP, 3 ) }, blk }, ; // запланировано госпитализаций на тек.день
  { 'Кол.;своб;мест', {|| put_val( n7->PLACE_FREE, 4 ) }, blk }, ; // количество свободных мест
  { 'кол;для;муж', {|| put_val( n7->PF_M, 3 ) }, blk }, ; // --''-- для мужчин
  { 'кол;для;жен', {|| put_val( n7->PF_W, 3 ) }, blk }, ; // --''-- для женщин
  { 'кол;для;дет', {|| put_val( n7->PF_C, 3 ) }, blk } }  // --''-- для детей
  t_arr[ BR_STEP_FUNC ] := {|| f1_263_s_svob_kojki( 1 ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_s_svob_kojki( nk, ob, 'edit' ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать' ) }
  t_arr[ BR_FL_NOCLEAR ] := .t.
  f1_263_s_svob_kojki( 0 )
  edit_browse( t_arr )
  f1_263_s_svob_kojki( 2 )
  If n7->( LastRec() ) > 0
    Keyboard ''
    If ( k := input_value( MaxRow() -5, 2, MaxRow() -3, 77, color1, ;
        Space( 4 ) + 'Редактирование завершено и данные готовы к отправке в ТФОМС?', ;
        d7->END_EDIT, mm_danet ) ) == NIL
      k := 0
    Endif
  Endif
  Select D7
  g_rlock( forever )
  d7->DATE_E := sys_date            // дата редактирования
  d7->TIME_E := hour_min( Seconds() ) // время редактирования
  d7->END_EDIT := k                 // 0-не закончено, 1-закончено редактирование
  d7->KOD_OPER := Asc( kod_polzovat ) // код оператора
  Close databases
  g_sunlock( str_sem )
  RestScreen( buf )
  Return Nil

// 24.08.14
Function f0_263_s_svob_kojki()

  Local k1, k2

  If n7->QUANTITY == 0
    Return { 3, 4 }
  Else
    k1 := n7->QUANTITY - ( n7->Q_P + n7->Q_AP - n7->Q_DP + n7->Q_HP )
    k2 := n7->PF_M + n7->PF_W + n7->PF_C
    If n7->PLACE_FREE < 0
      Return { 5, 6 }
    Elseif k1 == k2
      If k1 != n7->PLACE_FREE
        g_rlock( forever )
        n7->PLACE_FREE := k1
        Unlock
        Commit
      Endif
    Else
      Return { 5, 6 }
    Endif
  Endif
  Return { 1, 2 }

// 04.06.23
Function f1_263_s_svob_kojki( k )

  Static buf
  Local ta[ 2 ], k1, k2

  If k == 0
    buf := box_shadow( MaxRow() -4, 0, MaxRow() -1, 79, color1, 'Профиль койки и профиль медицинской помощи', 'B+/B' )
  Elseif k == 1
    @ MaxRow() -3, 1 Say PadC( AllTrim( inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ) ), 78 ) Color color14
    @ MaxRow() -2, 1 Say PadC( AllTrim( inieditspr( A__MENUVERT, getv002(), n7->PROFIL ) ), 78 ) Color color14
  Elseif k == 2
    rest_box( buf )
  Endif
  Return Nil

// 04.06.23
Function f2_263_s_svob_kojki( nKey, oBrow, regim )

  Local lkod, buf, r1, rec, i, ret := -1, lcodem, n1, n2, tmp_color, arr_p := {}, ;
    n_file := cur_dir() + 'sv_kojki' + stxt(), sh := 80, HH := 80, t_arr[ 4 ], s1, s2, s3, s4, ;
    tmp_V006 := { { 'Стационар', 1 }, { 'Дневной стационар', 2 } }

  If regim == 'open'
    Select N7
    Go Top
    ret := !Eof()
  Elseif regim == 'edit'
    Do Case
    Case nKey == K_INS .or. nKey == K_ENTER
      If nKey == K_INS
        rec := n7->( RecNo() )
        dbEval( {|| AAdd( arr_p, { n7->PROFIL_K, n7->PROFIL, iif( n7->usl_ok == 2, 2, 1 ) } ) } )
        Goto ( rec )
      Endif
      Private ;
        musl_ok, m1usl_ok := iif( nKey == K_INS .or. n7->usl_ok != 2, 1, n7->usl_ok ), ; // условия оказания мед.помощи
      mprofil_k, m1profil_k := iif( nKey == K_INS, 0, n7->PROFIL_K ), ; // профиль койки по справочнику T007
      mprofil, m1profil := iif( nKey == K_INS, 0, n7->PROFIL ), ; // профиль мед.помощи по справочнику V002
      mkol_kd     := iif( nKey == K_INS, 0, n7->kol_kd    ), ;
        mQUANTITY   := iif( nKey == K_INS, 0, n7->QUANTITY  ), ;
        mQ_P        := iif( nKey == K_INS, 0, n7->Q_P       ), ;
        mQ_AP       := iif( nKey == K_INS, 0, n7->Q_AP      ), ;
        mQ_DP       := iif( nKey == K_INS, 0, n7->Q_DP      ), ;
        mQ_HP       := iif( nKey == K_INS, 0, n7->Q_HP      ), ;
        mPLACE_FREE := iif( nKey == K_INS, 0, n7->PLACE_FREE ), ;
        mPF_M       := iif( nKey == K_INS, 0, n7->PF_M      ), ;
        mPF_W       := iif( nKey == K_INS, 0, n7->PF_W      ), ;
        mPF_C       := iif( nKey == K_INS, 0, n7->PF_C      ), ;
        gl_area := { 1, 0, 23, 79, 0 }, mPLACE_FREE2
      mUSL_OK := inieditspr( A__MENUVERT, tmp_V006, m1USL_OK )
      mprofil_k := inieditspr( A__MENUVERT, arr_t007(), M1PROFIL_K )
      mprofil := inieditspr( A__MENUVERT, getv002(), M1PROFIL )
      mPLACE_FREE2 := mPF_M + mPF_W + mPF_C
      tmp_color := SetColor()
      buf := SaveScreen()
      r1 := 5// maxrow() - 18
      If nKey == K_ENTER
        Keyboard Chr( K_TAB ) + iif( Empty( mkol_kd ), '', Chr( K_TAB ) )
      Endif
      Do While .t.
        SetColor( cDataCGet )
        clrlines( r1, MaxRow() -1 )
        @ r1, 0 Say PadC( 'Свободные койки (' + iif( nKey == K_INS, 'добавление', 'редактирование' ) + ')', 80 ) Color 'B/B*'
        @ r1 + 1, 1  Say 'Условия оказания медицинской помощи' Get musl_ok ;
          reader {| x| menu_reader( x, tmp_V006, A__MENUVERT, , , .f. ) } ;
          When nKey == K_INS
        @ r1 + 2, 1  Say 'Профиль койки' Get mprofil_k ;
          reader {| x| menu_reader( x, { {| k, r, c| f_get_profil_k( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
          valid {| g, o| f_valid_profil_k( g, o ) } ;
          When nKey == K_INS
        @ r1 + 3, 1  Say 'Профиль медицинской помощи' Get mprofil ;
          reader {| x| menu_reader( x, { {| k, r, c| f_get_profil( k, r, c, m1profil_k ) } }, A__FUNCTION, , , .f. ) } ;
          When m1profil_k > 0 .and. nKey == K_INS
        @ r1 + 4, 1  Say 'Общее количество коек по данному профилю         ' Get mQUANTITY Pict '999' valid {|| count_place_free() }
        @ r1 + 5, 1  Say 'Планируемый средний срок лечения в койко-днях    ' Color color8 Get mkol_kd Color color8 Pict '999'
        @ r1 + 6, 1  Say 'Состояло пациентов на начало предшествующих суток' Get mQ_P Pict '999' valid {|| count_place_free() }
        @ r1 + 7, 1  Say 'Поступило пациентов за предшествующие сутки      ' Get mQ_AP Pict '999' valid {|| count_place_free() }
        @ r1 + 8, 1  Say 'Выбыло пациентов в течение предшествующих суток  ' Get mQ_DP Pict '999' valid {|| count_place_free() }
        @ r1 + 9, 1  Say 'Запланировано госпитализаций на отчётную дату    ' Get mQ_HP Pict '999' valid {|| count_place_free() }
        @ r1 + 10, 1  Say 'Общее количество свободных мест на текущие сутки ' Get mPLACE_FREE Color color8 Pict '999' When .f.
        @ r1 + 10, Col() + 1 Get mPLACE_FREE2 Color color14 Pict '999' When .f.
        @ r1 + 11, 1 Say 'Количество свободных мест на текущие сутки для мужчин' Get mPF_M Pict '999' valid {|| count_place_free() }
        @ r1 + 12, 1 Say 'количество свободных мест на текущие сутки для женщин' Get mPF_W Pict '999' valid {|| count_place_free() }
        @ r1 + 13, 1 Say 'количество свободных мест на текущие сутки для детей ' Get mPF_C Pict '999' valid {|| count_place_free() }
        status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
        myread()
        k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
          { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
          if( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
        If k == 3
          Loop
        Elseif k == 2
          If Empty( m1profil_k )
            func_error( 4, 'Не введен профиль койки.' )
            Loop
          Endif
          If Empty( m1profil )
            func_error( 4, 'Не введен профиль медицинской помощи.' )
            Loop
          Endif
          Select N7
          If nKey == K_INS
            If AScan( arr_p, {| x| x[ 1 ] == m1PROFIL_K .and. x[ 2 ] == m1PROFIL .and. x[ 3 ] == m1usl_ok } ) > 0
              func_error( 4, 'В таблице уже есть строка с данным профилем койки и медицинской помощи.' )
              Loop
            Endif
            addrecn()
            n7->usl_ok := m1usl_ok
            n7->PROFIL_K := m1profil_k // профиль койки по справочнику T007
            n7->PROFIL := m1profil // профиль мед.помощи по справочнику V002
            fl_found := .t.
          Else
            g_rlock( forever )
          Endif
          n7->QUANTITY   := mQUANTITY
          n7->kol_kd     := mkol_kd
          n7->Q_P        := mQ_P
          n7->Q_AP       := mQ_AP
          n7->Q_DP       := mQ_DP
          n7->Q_HP       := mQ_HP
          n7->PLACE_FREE := mPLACE_FREE
          n7->PF_M       := mPF_M
          n7->PF_W       := mPF_W
          n7->PF_C       := mPF_C
          dbUnlock()
          Commit
          ret := 0
        Endif
        Exit
      Enddo
      If !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      RestScreen( buf )
    Case nKey == K_DEL .and. f_esc_enter( 2, .t. )
      deleterec()
      Go Top
      ret := iif( Eof(), 1, 0 )
    Case nKey == K_F9
      rec := n7->( RecNo() )
      ad := _263_put_10_days( d7->DATE_R_EDI )
      arr_title := { ;
        '──┬──────────────────────┬───────────────────────┬────┬─────────────┬───────────', ;
        'ус│                      │                       │кол.│за пред.сутки│ свободных ', ;
        'ло│ профиль койки        │ профиль мед.помощи    │коек│и на тек.день│   коек    ', ;
        '──┴──────────────────────┴───────────────────────┴────┴─────────────┴───────────' }
      For i := 1 To 10
        arr_title[ 1 ] += '┬───'
        arr_title[ 2 ] += '│' + Left( DToC( ad[ i, 1 ] ), 3 )
        arr_title[ 3 ] += '│' + SubStr( DToC( ad[ i, 1 ] ), 4, 3 )
        arr_title[ 4 ] += '┴───'
      Next
      sh := Len( arr_title[ 1 ] )
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( Center( 'Количество стационарных коек на утро ' + date_8( d7->DATE_R_EDI ) + 'г.', sh ) )
      For i := 1 To perenos( t_arr, glob_mo[ _MO_FULL_NAME ], sh )
        add_string( Center( AllTrim( t_arr[ i ] ), sh ) )
      Next
      AEval( arr_title, {| x| add_string( x ) } )
      n1 := 23
      n2 := 23
      Select N7
      Go Top
      Do While !Eof()
        s1 := iif( n7->usl_ok == 2, 'дн', 'ст' ) + ' '
        s2 := s3 := s4 := Space( 3 )
        perenos( t_arr, inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ), n1 -1 )
        s1 += PadR( t_arr[ 1 ], n1 )
        s2 += PadR( t_arr[ 2 ], n1 )
        s3 += PadR( t_arr[ 3 ], n1 )
        s4 += PadR( t_arr[ 4 ], n1 )
        perenos( t_arr, inieditspr( A__MENUVERT, getv002(), n7->PROFIL ), n2 -1 )
        s1 += PadR( t_arr[ 1 ], n2 )
        s2 += PadR( t_arr[ 2 ], n2 )
        s3 += PadR( t_arr[ 3 ], n2 )
        s4 += PadR( t_arr[ 4 ], n2 )
        s1 += Str( n7->QUANTITY, 4 ) + '  состояло -' + Str( n7->Q_P, 3 )
        s2 += Space( 4 )           + '  поступило-' + Str( n7->Q_AP, 3 )
        s3 += Space( 4 )           + '  выбыло   -' + Str( n7->Q_DP, 3 )
        s4 += Space( 4 )           + '  поступит -' + Str( n7->Q_HP, 3 )
        s1 += ' всего  -' + Str( n7->PLACE_FREE, 3 )
        s2 += ' мужских-' + Str( n7->PF_M, 3 )
        s3 += ' женских-' + Str( n7->PF_W, 3 )
        s4 += ' детских-' + Str( n7->PF_C, 3 )
        For i := 1 To 10
          pole1 := 'n7->PLACE' + lstr( i )
          pole2 := 'n7->PF_M' + lstr( i )
          pole3 := 'n7->PF_W' + lstr( i )
          pole4 := 'n7->PF_C' + lstr( i )
          s1 += put_val( &pole1, 4 )
          s2 += put_val( &pole2, 4 )
          s3 += put_val( &pole3, 4 )
          s4 += put_val( &pole4, 4 )
        Next
        If verify_ff( HH -5, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        add_string( s4 )
        add_string( Replicate( '─', sh ) )
        Skip
      Enddo
      Goto ( rec )
      FClose( fp )
      viewtext( n_file, , , , ( sh > 80 ), , , 6 )
    Endcase
  Endif
  Return ret

// 24.08.14
Static Function count_place_free()

  mplace_free := mQUANTITY - ( mQ_P + mQ_AP - mQ_DP + mQ_HP )
  mPLACE_FREE2 := mPF_M + mPF_W + mPF_C
  update_get( 'mplace_free' )
  Return update_get( 'mplace_free2' )

// 19.02.17
Function _263_put_10_days( mdate )

  Local i := 0, j, d := mdate, d2, arr[ 10, 4 ]

  afillall( arr, 0 )
  Do While .t.
    If is_work_day( ++d )
      arr[ ++i, 1 ] := d
      If i == 10
        Exit
      Endif
    Endif
  Enddo
  r_use( dir_server + 'kartotek', , 'KART' )
  r_use( dir_server + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into KART
  Index On Str( profil_k_4, 3 ) + Str( profil_4, 3 ) + Str( usl_ok_4, 1 ) to ( cur_dir() + 'tmp_napr' ) ;
    For Empty( TIP_ANNUL ) .and. KOD_F_4out >= 0 .and. TYPE_H_4 > 0 .and. !Empty( date_h_4 ) .and. Empty( date_6 )
  Select N7
  Go Top
  Do While !Eof()
    Select NAPR
    find ( Str( n7->profil_k, 3 ) + Str( n7->profil, 3 ) + Str( n7->usl_ok, 1 ) )
    Do While napr->profil_k_4 == n7->profil_k .and. napr->profil_4 == n7->profil ;
        .and. napr->usl_ok_4 == n7->usl_ok .and. !Eof()
      If Empty( d2 := napr->DNEJ_H_4 )
        If Empty( d2 := n7->kol_kd )
          d2 := 7 // по умолчанию срок лечения 7 койко-дней
        Endif
      Endif
      d2 := mdate + d2
      If count_years( kart->date_r, napr->date_h_4 ) < 18
        j := 4
      Else
        j := iif( kart->pol == 'М', 2, 3 )
      Endif
      For d := mdate + 1 To d2 -1
        If ( i := AScan( arr, {| x| x[ 1 ] == d } ) ) > 0
          arr[ i, j ] --
        Endif
      Next
      If ( i := AScan( arr, {| x| x[ 1 ] == d2 } ) ) > 0
        arr[ i, j ] ++
      Endif
      Skip
    Enddo
    Select N7
    g_rlock( forever )
    For i := 1 To 10
      pole1 := 'n7->PLACE' + lstr( i )
      pole2 := 'n7->PF_M' + lstr( i )
      pole3 := 'n7->PF_W' + lstr( i )
      pole4 := 'n7->PF_C' + lstr( i )
      v2 := iif( n7->PF_M + arr[ i, 2 ] < 0, 0, n7->PF_M + arr[ i, 2 ] )
      v3 := iif( n7->PF_W + arr[ i, 3 ] < 0, 0, n7->PF_W + arr[ i, 3 ] )
      v4 := iif( n7->PF_C + arr[ i, 4 ] < 0, 0, n7->PF_C + arr[ i, 4 ] )
      If v2 > n7->PF_M
        v2 := n7->PF_M
      Endif
      If v3 > n7->PF_W
        v3 := n7->PF_W
      Endif
      If v4 > n7->PF_C
        v4 := n7->PF_C
      Endif
      &pole2 := v2
      &pole3 := v3
      &pole4 := v4
      &pole1 := v2 + v3 + v4
    Next i
    Unlock
    Skip
  Enddo
  Commit
  kart->( dbCloseArea() )
  napr->( dbCloseArea() )
  Return arr
