// mo_263.prg - общие режимы для задачи по приказу 263-ФФОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 10.09.25
Function begin_task_263()

  Static n_zapusk := 0
  Local ar, fl := .t., group_ini := 'OBMEN_263'
  Local sbase

  If n_zapusk == 0
    ++n_zapusk
    mywait()
    Public p_arr_stac_VO := {}, ; // список всех стационаров области
    dir_263_to, ;          // каталог, куда записываются созданные пакеты
      dir_263_from, ;        // каталог, откуда читаются полученные пакеты
      dir_263_copy, ;        // каталог, куда перезаписываются прочитанные пакеты
      work_otd_263          // 1-работать с отделениями в подзадаче
    ar := getinisect( tmp_ini(), group_ini )
    dir_263_to   := AllTrim( a2default( ar, 'dir_to', '' ) )
    dir_263_from := AllTrim( a2default( ar, 'dir_from', '' ) )
    dir_263_copy := AllTrim( a2default( ar, 'dir_copy', '' ) )
    work_otd_263 := Int( Val( a2default( ar, 'work_otd', '0' ) ) )
    ar := getinisect( tools_ini(), group_ini )
    work_otd_263 := Int( Val( a2default( ar, 'work_otd', lstr( work_otd_263 ) ) ) )

    sbase := prefixfilerefname( WORK_YEAR ) + 'uslc'
    r_use( dir_exe() + sbase, , 'USLC' )

    Index On codemo to ( cur_dir() + 'tmp_uslc' ) ;
      For datebeg == 0d20190101 .and. eq_any( Left( shifr, 5 ), '1.11.', '55.1.' ) ;
      UNIQUE
    dbEval( {|| AAdd( p_arr_stac_VO, uslc->codemo ) } )
    Use
  Endif
  If g_sislock( sem_vagno_task()[ X_263 ] )
    fl := f_err_sem_vagno_task( X_263 )
  Elseif copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
  Else
    fl := .f.
  Endif
  Return fl

// 11.08.14 редактирование картотеки
Function _263_kartoteka( k )

  Local mas_pmt := { '~Добавление', ;
    '~Редактирование' }
  Local mas_msg := { 'Добавление в картотеку информации о больном', ;
    'Редактирование информации из карточки больного' }
  Local mas_fun := { 'append_kart()', 'regi_kart()' }

  glob_task := X_REGIST
  If k == 2 // для стационара
    Private _task_263_ := .t.
  Endif
  popup_prompt( T_ROW, T_COL + 5, 2, mas_pmt, mas_msg, mas_fun )
  glob_task := X_263
  Return Nil

// 02.07.14 действия в ответ на выбор в меню 'Профиль койки'
Function f_valid_profil_k( get, old )

  If Empty( m1profil_k )
    mprofil := Space( 67 )
    m1profil := 0
    update_get( 'mprofil' )
  Elseif m1profil_k != old .and. old != Nil .and. get != NIL
    mprofil := Space( 67 )
    m1profil := 0
    update_get( 'mprofil' )
  Endif
  Return .t.

// 04.06.23 в GET-е вернуть профиль койки из Т007
Function f_get_profil_k( k, r, c )

  Static sprofil_k := 0
  Local ret, ret_arr

  If Empty( k )
    k := sprofil_k
  Endif
  popup_2array( arr_t007(), -r, c, k, 1, @ret_arr, 'Выбор профиля койки', 'B/BG' )
  If ValType( ret_arr ) == 'A'
    ret := Array( 2 )
    sprofil_k := ret_arr[ 2 ]
    ret[ 1 ] := ret_arr[ 2 ]
    ret[ 2 ] := ret_arr[ 1 ]
  Endif
  Return ret

// 05.06.23 в GET-е вернуть строку из getV002()
Function f_get_profil( k, r, c, lprofil_k )

  Local arr := {}, i, ret, ret_arr

  // local tmp_select := select()

  If Empty( lprofil_k )
    Return Nil
  Endif
  arr := ret_arr_v002_profil_k_t007( lprofil_k )
  If Empty( arr )
    func_error( 4, 'В справочнике T007 не найдено профилей мед.помощи для данного профиля койки' )
    Return Nil
  Endif
  popup_2array( arr, -r, c, k, 1, @ret_arr, 'Выбор профиля мед.помощи', 'B/BG' )
  If ValType( ret_arr ) == 'A'
    ret := Array( 2 )
    ret[ 1 ] := ret_arr[ 2 ]
    ret[ 2 ] := ret_arr[ 1 ]
  Endif
  Return ret

// 10.09.25 Проверка информации перед отправкой в ТФОМС
Function _263_to_proverka( yes_msg, /*@*/yes_I07)

  Local i, j, s, ikol := 0, lkod_k, ldate, buf := save_maxrow(), k1, k2, ;
    arr_i01 := {}, arr_i03 := {}, arr_i04 := {}, arr_i05 := {}, arr_i06 := {}, ;
    ldate_h_1, max_date, ta, arr_error := {}

  yes_I07 := .f.
  Default yes_msg To .t.
  mywait( 'Проверка перед составлением...' )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
  r_use( dir_exe() + '_mo_smo', cur_dir() + '_mo_smo2', 'SMO' )
  r_use( dir_server() + 'mo_pers', , 'P2' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into KART
  Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp_naprkodk' )
  // I01
  Select NAPR
  Index On kod to ( cur_dir() + 'tmp_napr' ) ;
    For n_napr > 0 .and. Empty( KOD_F_1out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i01, {| x| x[ 1 ] == napr->DATE_D } ) ) == 0
      AAdd( arr_i01, { napr->DATE_D, {} } )
      i := Len( arr_i01 )
    Endif
    AAdd( arr_i01[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  For i := 1 To Len( arr_i01 )
    Default max_date To BoY( sys_date )
    max_date := Max( max_date, arr_i01[ i, 1 ] )
    For j := 1 To Len( arr_i01[ i, 2 ] )
      ta := {}
      ++ikol
      Select NAPR
      Goto ( arr_i01[ i, 2, j ] )
      lkod_k := napr->kod_k
      lnomer := napr->N_NAPR
      ldate := napr->date_d
      ldate_h_1 := napr->date_h_1
      If !valid_guid( napr->ID_1 )
        g_rlock( forever )
        napr->ID_1 := mo_guid( 1, napr->kod )
        Unlock
      Endif
      If Empty( napr->num_d )
        AAdd( ta, 'не введён номер направления' )
      Endif
      If Empty( napr->date_d )
        AAdd( ta, 'не введена дата направления' )
      Elseif napr->date_d > sys_date
        AAdd( ta, 'дата направления больше системной даты ' + full_date( napr->date_d ) )
      Elseif napr->date_d < sys_date -180
        AAdd( ta, 'дата направления НЕКОРРЕКТНА ' + full_date( napr->date_d ) )
      Elseif _263_verify_year( napr->date_d, ta )
      Endif
      If emptyany( napr->S_MCOD, napr->S_CODEM )
        AAdd( ta, 'не введён код стационара для госпитализации' )
      Endif
      If Empty( napr->PROFIL_K_1 )
        AAdd( ta, 'не введён профиль койки' )
      Endif
      If Empty( napr->PROFIL_1 )
        AAdd( ta, 'не введён профиль медицинской помощи' )
      Endif
      If Empty( napr->DS_1 )
        AAdd( ta, 'не введён диагноз поликлиники' )
      Else
        Select MKB_10
        find ( PadR( napr->DS_1, 6 ) )
        If Found()
          If !between_date( mkb_10->dbegin, mkb_10->dend, napr->date_d )
            AAdd( ta, 'диагноз поликлиники не входит в ОМС' )
          Endif
          If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == kart->pol )
            AAdd( ta, 'несовместимость диагноза поликлиники по полу ' + AllTrim( napr->DS_1 ) )
          Endif
        Else
          AAdd( ta, 'не найден диагноз поликлиники ' + AllTrim( napr->DS_1 ) + ' в справочнике МКБ-10' )
        Endif
      Endif
      If Empty( napr->F_MEDC_1 )
        AAdd( ta, 'не введена форма оказания мед.помощи' )
      Endif
      If Empty( napr->VRACH_1 )
        AAdd( ta, 'не введен врач, выписавший направление' )
      Else
        Select P2
        Goto ( napr->VRACH_1 )
        mvrach := fam_i_o( p2->fio ) + ' [' + lstr( p2->tab_nom ) + ']'
        If Empty( p2->snils )
          AAdd( ta, 'не введен СНИЛС у врача - ' + mvrach )
        Else
          s := Space( 80 )
          If !val_snils( p2->snils, 2, @s )
            AAdd( ta, s + ' у врача - ' + mvrach )
          Endif
        Endif
      Endif
      If Empty( napr->DATE_H_1 )
        AAdd( ta, 'не введена дата госпитализации' )
      Elseif napr->DATE_H_1 - napr->date_d > 30
        AAdd( ta, 'дата госпитализации ' + full_date( napr->DATE_H_1 ) + ' более 30 дней от даты направления ' + full_date( napr->date_d ) )
      Endif
      val_fio( retfamimot( 1, .f. ), ta )
      If Year( kart->date_r ) < 1900
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ' ( < 1900г.)' )
      Endif
      If kart->date_r > napr->date_d
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ;
          ' > даты направления: ' + full_date( napr->date_d ) )
      Endif
      If !Empty( kart->snils )
        s := Space( 80 )
        If !val_snils( kart->snils, 2, @s )
          AAdd( ta, s + ' у пациента' )
        Endif
      Endif
      valid_sn_polis( kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, ta, Between( kart_->smo, '34001', '34007' ) )
      Select SMO
      If AllTrim( kart_->smo ) == '34'
        If Empty( kart_->KVARTAL_D )
          AAdd( ta, 'не введён субъект РФ, в котором застрахован пациент' )
        Elseif Empty( ret_inogsmo_name( 1 ) )
          AAdd( ta, 'не введена иногородняя страховая компания' )
        Endif
      Else
        Select SMO
        find ( kart_->smo )
        If !Found()
          AAdd( ta, 'не найдена СМО с кодом "' + kart_->smo + '"' )
        Endif
      Endif
      If emptyall( kart_->PHONE_M, kart_->PHONE_H, kart_->PHONE_W )
        AAdd( ta, 'не введён ни один телефон' )
      Else
        If !Empty( kart_->PHONE_M )
          _263_valid_phone( 1, kart_->PHONE_M, ta )
        Endif
        If !Empty( kart_->PHONE_H )
          _263_valid_phone( 2, kart_->PHONE_H, ta )
        Endif
        If !Empty( kart_->PHONE_W )
          _263_valid_phone( 3, kart_->PHONE_W, ta )
        Endif
      Endif
      Select NAPR
      Set Index to ( cur_dir() + 'tmp_naprkodk' )
      find ( Str( lkod_k, 7 ) )
      Do While napr->kod_k == lkod_k .and. !Eof()
        If napr->kod == arr_i01[ i, 2, j ] .or. napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
          // текущую запись или аннулирования пропустим
        Elseif !Empty( napr->date_h_4 )
          fl := .f.
          If Empty( napr->CODEM_FROM )
            If napr->TYPE_H_4 == 4 .and. napr->KOD_F_4out == -99 // не наша госпитализация
              s := ret_mo( napr->S_CODEM )[ _MO_SHORT_NAME ]
            Else
              s := 'нашем стационаре'
              fl := .t.
            Endif
          Else
            s := ret_mo( napr->CODEM_FROM )[ _MO_SHORT_NAME ]
            fl := ( napr->CODEM_FROM == glob_mo()[ _MO_KOD_TFOMS ] )
          Endif
          If Empty( napr->date_6 )
            If fl
              AAdd( ta, 'у пациента выписано направление №' + lstr( lnomer ) + ' от ' + full_date( ldate ) + ',' )
              AAdd( ta, ' но он уже госпитализирован в ' + s + ' ' + full_date( napr->date_h_4 ) + ' и ещё не выписан' )
            Endif
          Elseif ldate_h_1 > napr->DATE_H_4 .and. ldate < napr->DATE_6
            If fl
              AAdd( ta, 'у пациента выписано направление №' + lstr( lnomer ) + ' от ' + full_date( ldate ) + ',' )
              AAdd( ta, ' по текущему направлению планируемая дата госпитализации ' + full_date( ldate_h_1 ) )
              AAdd( ta, ' пересекается с госпитализацией в ' + s + ' ' + full_date( napr->date_h_4 ) + '-' + full_date( napr->date_6 ) )
            Endif
          Endif
        Else
          If Abs( ldate - napr->date_d ) < 20 .or. Abs( ldate_h_1 - napr->date_h_1 ) < 20 // ;
            // .or. (!empty(napr->date_h_2) .and. abs(ldate_h_1 - napr->date_h_2) < 20)
            AAdd( ta, 'у пациента 2 направления: №' + lstr( lnomer ) + ' от ' + full_date( ldate ) + ;
              ' и №' + lstr( napr->N_NAPR ) + ' от ' + full_date( napr->date_d ) )
          Endif
        Endif
        Skip
      Enddo
      If !Empty( ta )
        AAdd( arr_error, { 1, arr_i01[ i, 2, j ], AClone( ta ) } )
      Endif
    Next
  Next
  // I03
  Select NAPR
  Index On kod to ( cur_dir() + 'tmp_napr' ) ;
    For n_napr > 0 .and. KOD_F_1out > 0 .and. TIP_ANNUL == 3 .and. Empty( KOD_F_3out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i03, {| x| x[ 1 ] == napr->DATE_3 } ) ) == 0
      AAdd( arr_i03, { napr->DATE_3, {} } )
      i := Len( arr_i03 )
    Endif
    AAdd( arr_i03[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  Index On kod to ( cur_dir() + 'tmp_napr' ) ;
    for ( KOD_F_1in > 0 .or. ( T_ANS_1 == 1 .and. CODEM_1 == glob_mo()[ _MO_KOD_TFOMS ] ) ) ;
    .and. TIP_ANNUL == 2 .and. Empty( KOD_F_3out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i03, {| x| x[ 1 ] == napr->DATE_3 } ) ) == 0
      AAdd( arr_i03, { napr->DATE_3, {} } )
      i := Len( arr_i03 )
    Endif
    AAdd( arr_i03[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  For i := 1 To Len( arr_i03 )
    Default max_date To BoY( sys_date )
    max_date := Max( max_date, arr_i03[ i, 1 ] )
    For j := 1 To Len( arr_i03[ i, 2 ] )
      ta := {}
      ++ikol
      Select NAPR
      Goto ( arr_i03[ i, 2, j ] )
      lkod_k := napr->kod_k
      If !valid_guid( napr->ID_1, 2 )
        AAdd( ta, 'некорректное поле ID_D (GUID направления)' )
      Endif
      If napr->date_d > napr->date_3
        AAdd( ta, 'дата аннулирования меньше даты направления ' + full_date( napr->date_3 ) )
      Elseif napr->date_3 > sys_date
        AAdd( ta, 'дата аннулирования больше системной даты ' + full_date( napr->date_3 ) )
      Elseif napr->date_3 > napr->DATE_H_1
        AAdd( ta, 'дата госпитализации меньше даты аннулирования ' + full_date( napr->date_3 ) )
        // elseif !empty(napr->DATE_H_2) .and. napr->date_3 > napr->DATE_H_2
        // aadd(ta, 'дата госпитализации меньше даты аннулирования ' + full_date(napr->date_3))
      Elseif _263_verify_year( napr->date_3, ta )
      Endif
      If AScan( get_reason_annul(), {| x| x[ 2 ] == napr->REA_ANNUL } ) == 0
        AAdd( ta, 'не указана причина аннулирования' )
      Endif
      If !Empty( napr->date_h_4 )
        If Empty( napr->CODEM_FROM )
          s := 'нашем стационаре'
        Else
          s := ret_mo( napr->CODEM_FROM )[ _MO_SHORT_NAME ]
        Endif
        AAdd( ta, 'пациент уже госпитализирован в ' + s + ' ' + full_date( napr->date_h_4 ) )
      Endif
      If !Empty( ta )
        AAdd( arr_error, { 3, arr_i03[ i, 2, j ], AClone( ta ) } )
      Endif
    Next
  Next
  // I04
  Select NAPR
  Index On kod to ( cur_dir() + 'tmp_napr' ) For Between( TYPE_H_4, 1, 3 ) .and. Empty( KOD_F_4out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i04, {| x| x[ 1 ] == napr->DATE_H_4 } ) ) == 0
      AAdd( arr_i04, { napr->DATE_H_4, {} } )
      i := Len( arr_i04 )
    Endif
    AAdd( arr_i04[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  For i := 1 To Len( arr_i04 )
    Default max_date To BoY( sys_date )
    max_date := Max( max_date, arr_i04[ i, 1 ] )
    For j := 1 To Len( arr_i04[ i, 2 ] )
      ta := {}
      ++ikol
      Select NAPR
      Goto ( arr_i04[ i, 2, j ] )
      lkod_k := napr->kod_k
      ldate := napr->DATE_H_4
      If !valid_guid( napr->ID_4 )
        g_rlock( forever )
        napr->ID_4 := mo_guid( 1, napr->kod )
        Unlock
      Endif
      If napr->TYPE_H_4 == 1 .and. !valid_guid( napr->ID_1, 2 )
        AAdd( ta, 'некорректное поле ID_D (GUID направления)' )
      Endif
      If Empty( napr->CODEM_FROM )
        AAdd( ta, 'не введён код направившего учреждения' )
      Endif
      If Empty( napr->DATE_H_4 )
        AAdd( ta, 'не введена дата госпитализации' )
      Elseif napr->date_h_4 > sys_date
        AAdd( ta, 'дата госпитализации больше системной даты ' + full_date( napr->date_h_4 ) )
      Elseif napr->date_h_4 < sys_date -180
        AAdd( ta, 'дата госпитализации НЕКОРРЕКТНА ' + full_date( napr->date_h_4 ) )
      Elseif !Between( Int( Val( Left( napr->TIME_H_4, 2 ) ) ), 0, 23 ) .or. !Between( Int( Val( Right( napr->TIME_H_4, 2 ) ) ), 0, 59 )
        AAdd( ta, 'время госпитализации НЕКОРРЕКТНО ' + napr->TIME_H_4 )
      Elseif _263_verify_year( napr->date_h_4, ta )
      Endif
      If Empty( napr->TIME_H_4 )
        AAdd( ta, 'не введено время госпитализации' )
      Endif
      If Empty( napr->DS_4 )
        AAdd( ta, 'не введён диагноз приёмного покоя' )
      Else
        Select MKB_10
        find ( PadR( napr->DS_4, 6 ) )
        If Found()
          If !between_date( mkb_10->dbegin, mkb_10->dend, napr->DATE_H_4 )
            AAdd( ta, 'диагноз приёмного покоя не входит в ОМС' )
          Endif
          If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == kart->pol )
            AAdd( ta, 'несовместимость диагноза приёмного покоя по полу ' + AllTrim( napr->DS_4 ) )
          Endif
        Else
          AAdd( ta, 'не найден диагноз приёмного покоя ' + AllTrim( napr->DS_4 ) + ' в справочнике МКБ-10' )
        Endif
      Endif
      If Empty( napr->F_MEDC_4 )
        AAdd( ta, 'не введена форма оказания мед.помощи' )
      Endif
      If Empty( napr->PROFIL_K_4 )
        AAdd( ta, 'не введён профиль койки' )
      Endif
      If Empty( napr->PROFIL_4 )
        AAdd( ta, 'не введён профиль медицинской помощи' )
      Endif
      If Empty( napr->NUM_HIST_4 )
        AAdd( ta, 'не введен номер истории болезни' )
      Endif
      val_fio( retfamimot( 1, .f. ), ta )
      If Year( kart->date_r ) < 1900
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ' ( < 1900г.)' )
      Endif
      If kart->date_r > napr->DATE_H_4
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ' > даты госпитализации: ' + full_date( napr->DATE_H_4 ) )
      Endif
      If !Empty( kart->snils )
        s := Space( 80 )
        If !val_snils( kart->snils, 2, @s )
          AAdd( ta, s )
        Endif
      Endif
      valid_sn_polis( kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, ta, Between( kart_->smo, '34001', '34007' ) )
      Select SMO
      If AllTrim( kart_->smo ) == '34'
        If Empty( kart_->KVARTAL_D )
          AAdd( ta, 'не введён субъект РФ, в котором застрахован пациент' )
        Elseif Empty( ret_inogsmo_name( 1 ) )
          AAdd( ta, 'не введена иногородняя страховая компания' )
        Endif
      Else
        Select SMO
        find ( kart_->smo )
        If !Found()
          AAdd( ta, 'не найдена СМО с кодом "' + kart_->smo + '"' )
        Endif
      Endif
      Select NAPR
      Set Index to ( cur_dir() + 'tmp_naprkodk' )
      find ( Str( lkod_k, 7 ) )
      Do While napr->kod_k == lkod_k .and. !Eof()
        If napr->kod == arr_i04[ i, 2, j ]
          // текущую запись пропустим
        Elseif !Empty( napr->DATE_H_4 )
          fl := .f.
          If Empty( napr->CODEM_FROM )
            If napr->TYPE_H_4 == 4 .and. napr->KOD_F_4out == -99 // не наша госпитализация
              fl := ( napr->S_CODEM == glob_mo()[ _MO_KOD_TFOMS ] )
            Else
              fl := .t. // наша госпитализация
            Endif
          Else
            fl := ( napr->CODEM_FROM == glob_mo()[ _MO_KOD_TFOMS ] )
          Endif
          If !Empty( napr->DATE_6 ) // если уже выписан
            If ldate > napr->DATE_H_4 .and. ldate < napr->DATE_6
              If fl
                AAdd( ta, 'у данного пациента обнаружена госпитализация с ' + full_date( napr->DATE_H_4 ) + ' по ' + full_date( napr->DATE_6 ) )
              Endif
            Endif
          Else
            If fl
              AAdd( ta, 'у данного пациента обнаружена незавершённая госпитализация от ' + full_date( napr->DATE_H_4 ) )
            Endif
          Endif
        Endif
        Skip
      Enddo
      If !Empty( ta )
        AAdd( arr_error, { 4, arr_i04[ i, 2, j ], AClone( ta ) } )
      Endif
    Next
  Next
  // I05
  Select NAPR
  Index On kod to ( cur_dir() + 'tmp_napr' ) For TYPE_H_4 == 4 .and. Empty( KOD_F_4out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i05, {| x| x[ 1 ] == napr->DATE_H_4 } ) ) == 0
      AAdd( arr_i05, { napr->DATE_H_4, {} } )
      i := Len( arr_i05 )
    Endif
    AAdd( arr_i05[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  For i := 1 To Len( arr_i05 )
    Default max_date To BoY( sys_date )
    max_date := Max( max_date, arr_i05[ i, 1 ] )
    For j := 1 To Len( arr_i05[ i, 2 ] )
      ta := {}
      ++ikol
      Select NAPR
      Goto ( arr_i05[ i, 2, j ] )
      lkod_k := napr->kod_k
      ldate := napr->DATE_H_4
      If !valid_guid( napr->ID_4 )
        g_rlock( forever )
        napr->ID_4 := mo_guid( 1, napr->kod )
        Unlock
      Endif
      If Empty( napr->DATE_H_4 )
        AAdd( ta, 'не введена дата госпитализации' )
      Elseif napr->date_h_4 > sys_date
        AAdd( ta, 'дата госпитализации больше системной даты ' + full_date( napr->date_h_4 ) )
      Elseif napr->date_h_4 < sys_date -180
        AAdd( ta, 'дата госпитализации НЕКОРРЕКТНА ' + full_date( napr->date_h_4 ) )
      Elseif !Between( Int( Val( Left( napr->TIME_H_4, 2 ) ) ), 0, 23 ) .or. !Between( Int( Val( Right( napr->TIME_H_4, 2 ) ) ), 0, 59 )
        AAdd( ta, 'время госпитализации НЕКОРРЕКТНО ' + napr->TIME_H_4 )
      Elseif _263_verify_year( napr->date_h_4, ta )
      Endif
      If Empty( napr->TIME_H_4 )
        AAdd( ta, 'не введено время госпитализации' )
      Endif
      If Empty( napr->DS_4 )
        AAdd( ta, 'не введён диагноз приёмного покоя' )
      Else
        Select MKB_10
        find ( PadR( napr->DS_4, 6 ) )
        If Found()
          If !between_date( mkb_10->dbegin, mkb_10->dend, napr->DATE_H_4 )
            AAdd( ta, 'диагноз приёмного покоя не входит в ОМС' )
          Endif
          If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == kart->pol )
            AAdd( ta, 'несовместимость диагноза приёмного покоя по полу ' + AllTrim( napr->DS_4 ) )
          Endif
        Else
          AAdd( ta, 'не найден диагноз приёмного покоя ' + AllTrim( napr->DS_4 ) + ' в справочнике МКБ-10' )
        Endif
      Endif
      If Empty( napr->F_MEDC_4 )
        AAdd( ta, 'не введена форма оказания мед.помощи' )
      Endif
      If Empty( napr->PROFIL_K_4 )
        AAdd( ta, 'не введён профиль койки' )
      Endif
      If Empty( napr->PROFIL_4 )
        AAdd( ta, 'не введён профиль медицинской помощи' )
      Endif
      If Empty( napr->NUM_HIST_4 )
        AAdd( ta, 'не введен номер истории болезни' )
      Endif
      val_fio( retfamimot( 1, .f. ), ta )
      If Year( kart->date_r ) < 1900
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ' ( < 1900г.)' )
      Endif
      If kart->date_r > napr->DATE_H_4
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ;
          ' > даты госпитализации: ' + full_date( napr->DATE_H_4 ) )
      Endif
      If !Empty( kart->snils )
        s := Space( 80 )
        If !val_snils( kart->snils, 2, @s )
          AAdd( ta, s )
        Endif
      Endif
      If !Empty( kart_->NPOLIS )
        valid_sn_polis( kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, ta, Between( kart_->smo, '34001', '34007' ) )
        Select SMO
        If AllTrim( kart_->smo ) == '34'
          If Empty( kart_->KVARTAL_D )
            AAdd( ta, 'не введён субъект РФ, в котором застрахован пациент' )
          Elseif Empty( ret_inogsmo_name( 1 ) )
            AAdd( ta, 'не введена иногородняя страховая компания' )
          Endif
        Else
          Select SMO
          find ( kart_->smo )
          If !Found()
            AAdd( ta, 'не найдена СМО с кодом "' + kart_->smo + '"' )
          Endif
        Endif
      Endif
      Select NAPR
      Set Index to ( cur_dir() + 'tmp_naprkodk' )
      find ( Str( lkod_k, 7 ) )
      Do While napr->kod_k == lkod_k .and. !Eof()
        If napr->kod == arr_i05[ i, 2, j ]
          // текущую запись пропустим
        Elseif !Empty( napr->DATE_H_4 )
          fl := .f.
          If Empty( napr->CODEM_FROM )
            If napr->TYPE_H_4 == 4 .and. napr->KOD_F_4out == -99 // не наша госпитализация
              fl := ( napr->S_CODEM == glob_mo()[ _MO_KOD_TFOMS ] )
            Else
              fl := .t. // наша госпитализация
            Endif
          Else
            fl := ( napr->CODEM_FROM == glob_mo()[ _MO_KOD_TFOMS ] )
          Endif
          If !Empty( napr->DATE_6 ) // если уже выписан
            If ldate > napr->DATE_H_4 .and. ldate < napr->DATE_6
              If fl
                AAdd( ta, 'у данного пациента обнаружена госпитализация с ' + full_date( napr->DATE_H_4 ) + ' по ' + full_date( napr->DATE_6 ) )
              Endif
            Endif
          Else
            If fl
              AAdd( ta, 'у данного пациента обнаружена незавершённая госпитализация от ' + full_date( napr->DATE_H_4 ) )
            Endif
          Endif
        Endif
        Skip
      Enddo
      If !Empty( ta )
        AAdd( arr_error, { 5, arr_i05[ i, 2, j ], AClone( ta ) } )
      Endif
    Next
  Next
  // I06
  Select NAPR
  Index On kod to ( cur_dir() + 'tmp_napr' ) ;
    For KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. !Empty( DATE_6 ) .and. Empty( KOD_F_6out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i06, {| x| x[ 1 ] == napr->DATE_6 } ) ) == 0
      AAdd( arr_i06, { napr->DATE_6, {} } )
      i := Len( arr_i06 )
    Endif
    AAdd( arr_i06[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  For i := 1 To Len( arr_i06 )
    Default max_date To BoY( sys_date )
    max_date := Max( max_date, arr_i06[ i, 1 ] )
    For j := 1 To Len( arr_i06[ i, 2 ] )
      ta := {}
      ++ikol
      Select NAPR
      Goto ( arr_i06[ i, 2, j ] )
      If !valid_guid( napr->ID_6 )
        g_rlock( forever )
        napr->ID_6 := mo_guid( 1, napr->kod )
        Unlock
      Endif
      If Empty( napr->DATE_H_4 )
        AAdd( ta, 'не введена дата госпитализации' )
      Endif
      If Empty( napr->DATE_6 )
        AAdd( ta, 'не введена дата выбытия' )
      Elseif napr->date_6 < napr->date_h_4
        AAdd( ta, 'дата выбытия меньше даты госпитализации ' + full_date( napr->date_6 ) + ' < ' + full_date( napr->date_h_4 ) )
      Elseif napr->date_6 > napr->date_h_4 + 180
        AAdd( ta, 'дата выбытия НЕКОРРЕКТНА ' + full_date( napr->date_6 ) )
      Endif
      If Empty( napr->F_MEDC_4 )
        AAdd( ta, 'не введена форма оказания мед.помощи' )
      Endif
      If Empty( napr->PROFIL_K_4 )
        AAdd( ta, 'не введён профиль койки' )
      Endif
      If Empty( napr->PROFIL_4 )
        AAdd( ta, 'не введён профиль медицинской помощи' )
      Endif
      If Empty( napr->NUM_HIST_4 )
        AAdd( ta, 'не введен номер истории болезни' )
      Endif
      If napr->TYPE_H_4 == 1
        If !valid_guid( napr->ID_1, 2 )
          AAdd( ta, 'некорректное поле ID_D (GUID направления)' )
        Endif
        If Empty( napr->CODEM_FROM )
          AAdd( ta, 'не введён код направившего учреждения' )
        Endif
      Endif
      If Empty( napr->NUM_HIST_4 )
        AAdd( ta, 'не введен номер истории болезни' )
      Endif
      If Year( kart->date_r ) < 1900
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ' ( < 1900г.)' )
      Endif
      If kart->date_r > napr->date_6
        AAdd( ta, 'дата рождения: ' + full_date( kart->date_r ) + ' > даты выбытия: ' + full_date( napr->DATE_6 ) )
      Endif
      If !Empty( ta )
        AAdd( arr_error, { 6, arr_i06[ i, 2, j ], AClone( ta ) } )
      Endif
    Next
  Next
  // I07
  If is_napr_stac()
    ta1 := {}
    r_use( dir_server() + 'mo_n7d', , 'D7' )
    If LastRec() > 0 .and. !Empty( d7->DATE_R_EDI )
      If !emptyany( d7->DATE_R_EDI, d7->DATE_R_OUT, d7->DATE_OUT ) .and. ;
          d7->DATE_R_EDI == d7->DATE_R_OUT .and. d7->DATE_OUT == sys_date
        // ничего не делаем, т.к. уже сегодня отправили
      Elseif Empty( d7->END_EDIT )
        If !Empty( d7->DATE_R_OUT )
          AAdd( ta1, 'не подтверждено окончание редактирования' )
        Endif
      Else
        If !emptyany( d7->DATE_R_EDI, d7->DATE_R_OUT, d7->DATE_OUT ) .and. ;
            d7->DATE_R_EDI == d7->DATE_R_OUT .and. d7->DATE_OUT < sys_date
          AAdd( ta1, 'после последней отправки в ТФОМС не было входа в редактирование' )
        Endif
        If d7->DATE_R_EDI > sys_date
          AAdd( ta1, 'отчётная дата больше системной даты ' + full_date( d7->DATE_R_EDI ) )
        Elseif d7->DATE_R_EDI < sys_date -60
          AAdd( ta1, 'отчётная дата НЕКОРРЕКТНА ' + full_date( d7->DATE_R_EDI ) )
        Elseif _263_verify_year( d7->DATE_R_EDI, ta1 )
        Endif
        g_use( dir_server() + 'mo_n7out', , 'N7' )
        Index On PadR( inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ), 60 ) + Str( n7->PROFIL_K, 3 ) + ;
          PadR( inieditspr( A__MENUVERT, getv002(), n7->PROFIL ), 20 ) + Str( n7->PROFIL, 3 ) to ( cur_dir() + 'tmp_n7' )
        Go Top
        If !Eof()
          Do While !Eof()
            yes_I07 := .t.
            ta := {}
            If n7->QUANTITY == 0
              AAdd( ta, '-не введено количество коек' )
            Else
              k1 := n7->QUANTITY - ( n7->Q_P + n7->Q_AP - n7->Q_DP + n7->Q_HP )
              k2 := n7->PF_M + n7->PF_W + n7->PF_C
              If n7->PLACE_FREE < 0
                AAdd( ta, '-количество свободных коек меньше нуля' )
              Elseif k1 == k2
                If k1 != n7->PLACE_FREE
                  g_rlock( forever )
                  n7->PLACE_FREE := k1
                  Unlock
                  Commit
                Endif
              Else
                AAdd( ta, '-количество свободных коек по разным формулам: ' + lstr( k1 ) + ' != ' + lstr( k2 ) )
              Endif
            Endif
            If !Empty( ta )
              ins_array( ta, 1, AllTrim( inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ) ) + ;
                ' (' + AllTrim( inieditspr( A__MENUVERT, getv002(), n7->PROFIL ) ) + ')' )
              AAdd( arr_error, { 7, 0, AClone( ta ) } )
            Endif
            Select N7
            Skip
          Enddo
        Endif
      Endif
    Endif
    If !Empty( ta1 )
      AAdd( arr_error, { 7, 0, AClone( ta1 ) } )
    Endif
  Endif
  If Len( arr_error ) == 0
    If yes_msg
      stat_msg( 'Проверено пациентов - ' + lstr( ikol ) + '. Ошибок не обнаружено!' )
      mybell( 4, OK )
    Endif
  Else
    name_file := cur_dir() + '263error.txt'
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    add_string( full_date( sys_date ) + ' ' + hour_min( Seconds() ) )
    add_string( '' )
    add_string( Center( 'Список обнаруженных ошибок', 80 ) )
    Select NAPR
    Set Index To
    For i := 1 To Len( arr_error )
      Do Case
      Case arr_error[ i, 1 ] == 1
        s := 'Поликлиника/Направления'
      Case arr_error[ i, 1 ] == 3
        s := 'Поликлиника(Стационар)/Аннулирование'
      Case arr_error[ i, 1 ] == 4 .or. arr_error[ i, 1 ] == 5
        s := 'Стационар/Госпитализация'
      Case arr_error[ i, 1 ] == 6
        s := 'Стационар/Выбытие'
      Case arr_error[ i, 1 ] == 7
        s := 'Стационар/Свободные койки'
      Endcase
      verify_ff( 76, .t., 80 )
      add_string( '' )
      add_string( 'пакет I0' + lstr( arr_error[ i, 1 ] ) + '... режим "' + s + '"' )
      If arr_error[ i, 1 ] < 7
        Goto ( arr_error[ i, 2 ] )
        add_string( AllTrim( kart->fio ) + ' д.р.' + full_date( kart->date_r ) )
      Endif
      For j := 1 To Len( arr_error[ i, 3 ] )
        verify_ff( 80, .t., 80 )
        add_string( '- ' + arr_error[ i, 3, j ] )
      Next
    Next
    FClose( fp )
    Close databases
    viewtext( name_file, , , , .t., , , 5 )
  Endif
  Close databases
  rest_box( buf )
  Return Len( arr_error ) == 0

// 13.12.21 проверить год, если вдруг 'сбита' системная дата в компьютере
Function _263_verify_year( mdate, arr )

  Local end_year := WORK_YEAR + iif( Month( sys_date ) == 12, 1, 0 )

  If !Between( Year( mdate ), 2019, end_year )
    AAdd( arr, 'в отчётной дате ' + full_date( mdate ) + ' НЕКОРРЕКТНЫЙ год' )
  Endif
  Return .f.


// 14.09.15 проверка на правильность номера телефона
Function _263_valid_phone( k, s, ta )

  Local s1

  If !Empty( s )
    s := CharRem( '-', s )
    s := CharRem( ' ', s )
    s1 := CharRepl( '0123456789', s, Space( 10 ) )
    If !Empty( s1 ) .or. !( Left( s, 1 ) == '8' )
      If k == 1
        AAdd( ta, 'Правильный номер мобильного телефона: "8" + ещё 10 цифр' )
      Else
        AAdd( ta, 'Правильный номер телефона: "8" + "код города" + "цифры" (всего 11 цифр)' )
      Endif
    Endif
    If Len( s ) < 11
      AAdd( ta, 'В номере телефона должно быть 11 знаков' )
    Endif
  Endif
  Return Nil

// 12.09.25 Составление информационных пакетов для отправкой в ТФОМС
Function _263_to_sostavlenie()

  Local i, j, k, mnn, nfile,  arr_f := {}, name_txt, file_error, buf := save_maxrow(), ;
    arr_i01 := {}, arr_i03 := {}, arr_i04 := {}, arr_i05 := {}, arr_i06 := {}, ;
    fl_error := .f., yes_i07 := .f.

  If Empty( dir_263_to )
    Return func_error( 4, 'Не настроен каталог обмена в режиме "Настройка каталогов"' )
  Endif
  If !_263_to_proverka( .f., @yes_i07 )
    Return Nil
  Endif
  If !mo_lock_task( X_263 )
    Return Nil
  Endif
  mywait()
  //
  Private cFileProtokol := cur_dir() + 'tmp.txt', cTimeBegin := hour_min( Seconds() )
  name_txt := DToS( sys_date ) + '_' + CharRem( ':', PadR( SecToTime( Seconds() ), 8 ) ) + stxt()
  //
  r_use( dir_server() + 'mo_pers', , 'P2' )
  r_use( dir_server() + 'kartote2', , 'KART2' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_, To RecNo() into KART2
  g_use( dir_server() + 'mo_nfina', , 'NFN' )
  g_use( dir_server() + 'mo_nfile', , 'NF' )
  Index On Str( tip_f, 1 ) + DToS( date_r ) + Str( in_out, 1 ) + Str( nn, 4 ) to ( cur_dir() + 'tmp_nf' )
  g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
  Set Relation To kod_k into KART

  // I01
  Select NAPR
  Index On kod to ( cur_dir() + 'tmp_napr' ) For n_napr > 0 .and. Empty( KOD_F_1out )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_i01, {| x| x[ 1 ] == napr->DATE_D } ) ) == 0
      AAdd( arr_i01, { napr->DATE_D, {} } ) ; i := Len( arr_i01 )
    Endif
    AAdd( arr_i01[ i, 2 ], napr->kod )
    Select NAPR
    Skip
  Enddo
  For i := 1 To Len( arr_i01 )
    mnn := 0
    Select NF
    find ( '1' + DToS( arr_i01[ i, 1 ] ) + '1' )
    Do While nf->tip_f == 1 .and. nf->date_r == arr_i01[ i, 1 ] .and. nf->in_out == 1 .and. !Eof()
      mnn := nf->nn
      Skip
    Enddo
    ++mnn // номер пакета
    nfile := 'I01T34M' + glob_mo()[ _MO_KOD_TFOMS ] + '_' + ;
      Right( Str( Year( arr_i01[ i, 1 ] ), 4 ), 2 ) + ;
      StrZero( Month( arr_i01[ i, 1 ] ), 2 ) + ;
      StrZero( Day( arr_i01[ i, 1 ] ), 2 ) + ;
      lstr( mnn )
    Select NF
    addrec( 1 )
    nf->KOD := RecNo()            // код файла
    nf->DATE_F := sys_date        // дата файла
    nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
    nf->DATE_R := arr_i01[ i, 1 ]    // отчётная дата
    nf->NN := mnn                 // порядковый номер пакета за отчётную дату
    nf->TIP_F := 1                // от 1 до 7 (пакеты от I01 до I07)
    nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
    nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
    nf->KOL := Len( arr_i01[ i, 2 ] )  // количество пациентов в файле
    nf->DWORK := sys_date         // дата обработки файла
    nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
    nf->TWORK2 := ''              // время окончания обработки
    nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
    //
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
    mo_add_xml_stroke( oXmlNode, 'VERSION', '2.0' )
    mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( nf->DATE_F ) )
    mo_add_xml_stroke( oXmlNode, 'NAME_F', nf->NAME_F )
    mo_add_xml_stroke( oXmlNode, 'DATE_R', date2xml( nf->DATE_R ) )
    oMo_d := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'MO_D' ) )
    mo_add_xml_stroke( oMo_d, 'MO', glob_mo()[ _MO_KOD_FFOMS ] )
    mo_add_xml_stroke( oMo_d, 'LPU', glob_mo()[ _MO_KOD_TFOMS ] )
    For j := 1 To Len( arr_i01[ i, 2 ] )
      Select NAPR
      Goto ( arr_i01[ i, 2, j ] )
      g_rlock( forever )
      napr->KOD_F_1out := nf->KOD // код файла - по файлу mo_nfile
      napr->T_ANS_1 := 0
      napr->DATE_R := kart->date_r // дата рождения
      napr->SEX := iif( kart->pol == 'М', 1, 2 ) // пол
      napr->ENP := iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) // единый номер полиса ОМС
      p2->( dbGoto( napr->VRACH_1 ) )
      //
      Select NFN
      Append Blank
      nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
      nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
      nfn->OSHIB := 0
      //
      arr_fio := retfamimot( 1, .f. ) ; cSMOname := ''
      If AllTrim( kart_->smo ) == '34'
        cSMOname := ret_inogsmo_name( 1 )
      Endif
      oDir := oMo_d:add( hxmlnode():new( 'DIR' ) )
      mo_add_xml_stroke( oDir, 'ID_D', napr->id_1 )
      mo_add_xml_stroke( oDir, 'NUM_D', napr->num_d )
      mo_add_xml_stroke( oDir, 'DATE_D', date2xml( napr->date_d ) )
      mo_add_xml_stroke( oDir, 'MO_H', napr->S_MCOD )
      mo_add_xml_stroke( oDir, 'LPU_H', napr->S_CODEM )
      mo_add_xml_stroke( oDir, 'USL_OK', lstr( iif( napr->usl_ok_1 == 2, 2, 1 ) ) )
      ar := _263_pr_prk( napr->PROFIL_K_1, napr->PROFIL_1, nf->DATE_R )
      mo_add_xml_stroke( oDir, 'PROFIL', ar[ 1 ] )
      mo_add_xml_stroke( oDir, 'PROFIL_K', ar[ 2 ] )
      mo_add_xml_stroke( oDir, 'DS', napr->DS_1 )
      mo_add_xml_stroke( oDir, 'IDDOKT', p2->snils )
      mo_add_xml_stroke( oDir, 'F_MEDC', lstr( napr->F_MEDC_1 ) )
      mo_add_xml_stroke( oDir, 'DATE_HOSP', date2xml( napr->DATE_H_1 ) )
      mo_add_xml_stroke( oDir, 'DISP', lstr( napr->disp_1 ) )
      oPAC := oDir:add( hxmlnode():new( 'PATIENT' ) )
      mo_add_xml_stroke( oPAC, 'SURNAME', arr_fio[ 1 ] )
      mo_add_xml_stroke( oPAC, 'NAME', arr_fio[ 2 ] )
      If !Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oPAC, 'PATRONYMIC', arr_fio[ 3 ] )
      Endif
      mo_add_xml_stroke( oPAC, 'BIRTHDAY', date2xml( kart->date_r ) )
      mo_add_xml_stroke( oPAC, 'SEX', iif( kart->pol == 'М', '1', '2' ) )
      If !Empty( kart->snils )
//        mo_add_xml_stroke( oPAC, 'SS', Transform( kart->SNILS, picture_pf ) )
        mo_add_xml_stroke( oPAC, 'SS', Transform_SNILS( kart->SNILS ) )
      Endif
      mo_add_xml_stroke( oPAC, 'TYPE_P', lstr( kart_->VPOLIS ) )
      If !Empty( kart_->SPOLIS )
        mo_add_xml_stroke( oPAC, 'SER_P', kart_->SPOLIS )
      Endif
      mo_add_xml_stroke( oPAC, 'NUM_P', kart_->NPOLIS )
      If kart_->VPOLIS == 3
        mo_add_xml_stroke( oPAC, 'ENP', kart_->NPOLIS )
      Endif
      If Empty( cSMOname )
        mo_add_xml_stroke( oPAC, 'SMO', kart_->smo )
      Else
        mo_add_xml_stroke( oPAC, 'NAME_SMO', cSMOname )
      Endif
      mokato := '18000'
      If !Empty( kart_->KVARTAL_D )
        mokato := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
      Endif
      mo_add_xml_stroke( oPAC, 'REG_OMS', mokato )
      oCon := oPAC:add( hxmlnode():new( 'CONTACT' ) )
      If !Empty( kart_->PHONE_M )
        mo_add_xml_stroke( oCon, 'TEL_M', Left( kart_->PHONE_M, 1 ) + '-' + SubStr( kart_->PHONE_M, 2, 3 ) + '-' + SubStr( kart_->PHONE_M, 5 ) )
      Endif
      If !Empty( kart_->PHONE_H )
        mo_add_xml_stroke( oCon, 'TEL_F', Left( kart_->PHONE_H, 1 ) + '-' + SubStr( kart_->PHONE_H, 2, 4 ) + '-' + SubStr( kart_->PHONE_H, 6 ) )
      Elseif !Empty( kart_->PHONE_W )
        mo_add_xml_stroke( oCon, 'TEL_F', Left( kart_->PHONE_W, 1 ) + '-' + SubStr( kart_->PHONE_W, 2, 4 ) + '-' + SubStr( kart_->PHONE_W, 6 ) )
      Endif
    Next
    oXmlDoc:save( nfile + sxml() )
    name_zip := nfile + szip()
    If chip_create_zipxml( name_zip, { nfile + sxml() }, .t., 2 )
      nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
      nf->TXT_F := name_txt
      AAdd( arr_f, { nfile, Len( arr_i01[ i, 2 ] ) } )
    Else
      file_error := nfile
      fl_error := .t. ; Exit
    Endif
    dbUnlockAll()
    Commit
  Next
  // I03
  For k := 2 To 3
    If !fl_error
      arr_i03 := {}
      Select NAPR
      If k == 2
        Index On kod to ( cur_dir() + 'tmp_napr' ) ;
          for ( KOD_F_1in > 0 .or. ( T_ANS_1 == 1 .and. CODEM_1 == glob_mo()[ _MO_KOD_TFOMS ] ) ) ;
          .and. TIP_ANNUL == 2 .and. Empty( KOD_F_3out )
      Else
        Index On kod to ( cur_dir() + 'tmp_napr' ) ;
          For n_napr > 0 .and. KOD_F_1out > 0 .and. TIP_ANNUL == 3 .and. Empty( KOD_F_3out )
      Endif
      Go Top
      Do While !Eof()
        If ( i := AScan( arr_i03, {| x| x[ 1 ] == napr->DATE_3 } ) ) == 0
          AAdd( arr_i03, { napr->DATE_3, {} } ) ; i := Len( arr_i03 )
        Endif
        AAdd( arr_i03[ i, 2 ], napr->kod )
        Select NAPR
        Skip
      Enddo
      For i := 1 To Len( arr_i03 )
        mnn := 0
        Select NF
        find ( '3' + DToS( arr_i03[ i, 1 ] ) + '1' )
        Do While nf->tip_f == 3 .and. nf->date_r == arr_i03[ i, 1 ] .and. nf->in_out == 1 .and. !Eof()
          mnn := nf->nn
          Skip
        Enddo
        ++mnn // номер пакета
        nfile := 'I03T34M' + glob_mo()[ _MO_KOD_TFOMS ] + '_' + ;
          Right( Str( Year( arr_i03[ i, 1 ] ), 4 ), 2 ) + ;
          StrZero( Month( arr_i03[ i, 1 ] ), 2 ) + ;
          StrZero( Day( arr_i03[ i, 1 ] ), 2 ) + ;
          lstr( mnn )
        Select NF
        addrec( 1 )
        nf->KOD := RecNo()            // код файла
        nf->DATE_F := sys_date        // дата файла
        nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
        nf->DATE_R := arr_i03[ i, 1 ]    // отчётная дата
        nf->NN := mnn                 // порядковый номер пакета за отчётную дату
        nf->TIP_F := 3                // от 1 до 7 (пакеты от I01 до I07)
        nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
        nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
        nf->KOL := Len( arr_i03[ i, 2 ] )  // количество пациентов в файле
        nf->DWORK := sys_date         // дата обработки файла
        nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
        nf->TWORK2 := ''              // время окончания обработки
        nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
        nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
        //
        oXmlDoc := hxmldoc():new()
        oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
        oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
        mo_add_xml_stroke( oXmlNode, 'VERSION', '2.0' )
        mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( nf->DATE_F ) )
        mo_add_xml_stroke( oXmlNode, 'NAME_F', nf->NAME_F )
        mo_add_xml_stroke( oXmlNode, 'DATE_R', date2xml( nf->DATE_R ) )
        oMo_d := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'SOURCE' ) )
        mo_add_xml_stroke( oMo_d, 'TYPE_S', lstr( k ) )
        mo_add_xml_stroke( oMo_d, 'CODE', glob_mo()[ _MO_KOD_FFOMS ] )
        For j := 1 To Len( arr_i03[ i, 2 ] )
          Select NAPR
          Goto ( arr_i03[ i, 2, j ] )
          g_rlock( forever )
          napr->KOD_F_3out := nf->KOD // код файла - по файлу mo_nfile
          napr->T_ANS_3 := 0
          //
          Select NFN
          Append Blank
          nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
          nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
          nfn->OSHIB := 0
          //
          oDate_hosp := oMo_d:add( hxmlnode():new( 'REF_HOSP' ) )
          mo_add_xml_stroke( oDate_hosp, 'ID_D', napr->id_1 )
          mo_add_xml_stroke( oDate_hosp, 'MO_D', napr->MCOD_1 )
          mo_add_xml_stroke( oDate_hosp, 'LPU_D', napr->CODEM_1 )
          mo_add_xml_stroke( oDate_hosp, 'DATE_REF', date2xml( napr->DATE_3 ) )
          mo_add_xml_stroke( oDate_hosp, 'REASON_REF', lstr( napr->REA_ANNUL ) )
        Next
        oXmlDoc:save( nfile + sxml() )
        name_zip := nfile + szip()
        If chip_create_zipxml( name_zip, { nfile + sxml() }, .t., 2 )
          nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
          nf->TXT_F := name_txt
          AAdd( arr_f, { nfile, Len( arr_i03[ i, 2 ] ) } )
        Else
          file_error := nfile
          fl_error := .t. ; Exit
        Endif
        dbUnlockAll()
        Commit
      Next
    Endif
  Next
  // I04
  If !fl_error
    Select NAPR
    Index On kod to ( cur_dir() + 'tmp_napr' ) For Between( TYPE_H_4, 1, 3 ) .and. Empty( KOD_F_4out )
    Go Top
    Do While !Eof()
      If ( i := AScan( arr_i04, {| x| x[ 1 ] == napr->DATE_H_4 } ) ) == 0
        AAdd( arr_i04, { napr->DATE_H_4, {} } ) ; i := Len( arr_i04 )
      Endif
      AAdd( arr_i04[ i, 2 ], napr->kod )
      Select NAPR
      Skip
    Enddo
    For i := 1 To Len( arr_i04 )
      mnn := 0
      Select NF
      find ( '4' + DToS( arr_i04[ i, 1 ] ) + '1' )
      Do While nf->tip_f == 4 .and. nf->date_r == arr_i04[ i, 1 ] .and. nf->in_out == 1 .and. !Eof()
        mnn := nf->nn
        Skip
      Enddo
      ++mnn // номер пакета
      nfile := 'I04T34M' + glob_mo()[ _MO_KOD_TFOMS ] + '_' + ;
        Right( Str( Year( arr_i04[ i, 1 ] ), 4 ), 2 ) + ;
        StrZero( Month( arr_i04[ i, 1 ] ), 2 ) + ;
        StrZero( Day( arr_i04[ i, 1 ] ), 2 ) + ;
        lstr( mnn )
      Select NF
      addrec( 1 )
      nf->KOD := RecNo()            // код файла
      nf->DATE_F := sys_date        // дата файла
      nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
      nf->DATE_R := arr_i04[ i, 1 ]    // отчётная дата
      nf->NN := mnn                 // порядковый номер пакета за отчётную дату
      nf->TIP_F := 4                // от 1 до 7 (пакеты от I01 до I07)
      nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
      nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
      nf->KOL := Len( arr_i04[ i, 2 ] )  // количество пациентов в файле
      nf->DWORK := sys_date         // дата обработки файла
      nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
      nf->TWORK2 := ''              // время окончания обработки
      nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
      nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
      //
      oXmlDoc := hxmldoc():new()
      oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
      mo_add_xml_stroke( oXmlNode, 'VERSION', '2.0' )
      mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( nf->DATE_F ) )
      mo_add_xml_stroke( oXmlNode, 'NAME_F', nf->NAME_F )
      mo_add_xml_stroke( oXmlNode, 'DATE_R', date2xml( nf->DATE_R ) )
      oMo_d := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'MO_HOSP' ) )
      mo_add_xml_stroke( oMo_d, 'MO', glob_mo()[ _MO_KOD_FFOMS ] )
      mo_add_xml_stroke( oMo_d, 'LPU', glob_mo()[ _MO_KOD_TFOMS ] )
      For j := 1 To Len( arr_i04[ i, 2 ] )
        Select NAPR
        Goto ( arr_i04[ i, 2, j ] )
        g_rlock( forever )
        napr->KOD_F_4out := nf->KOD // код файла - по файлу mo_nfile
        napr->T_ANS_4 := 0
        napr->DATE_R := kart->date_r // дата рождения
        napr->SEX := iif( kart->pol == 'М', 1, 2 ) // пол
        napr->ENP := iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) // единый номер полиса ОМС
        //
        Select NFN
        Append Blank
        nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
        nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
        nfn->OSHIB := 0
        //
        arr_fio := retfamimot( 1, .f. ) ; cSMOname := ''
        If AllTrim( kart_->smo ) == '34'
          cSMOname := ret_inogsmo_name( 1 )
        Endif
        oDir := oMo_d:add( hxmlnode():new( 'HOSP' ) )
        mo_add_xml_stroke( oDir, 'ID_H', napr->id_4 )
        mo_add_xml_stroke( oDir, 'USL_OK', lstr( iif( napr->usl_ok_4 == 2, 2, 1 ) ) )
        mo_add_xml_stroke( oDir, 'TYPE_H', lstr( napr->TYPE_H_4 ) )
        If napr->TYPE_H_4 == 1
          mo_add_xml_stroke( oDir, 'ID_D', napr->id_1 )
        Endif
        mo_add_xml_stroke( oDir, 'MO_D', ret_mo( napr->CODEM_FROM )[ _MO_KOD_FFOMS ] )
        mo_add_xml_stroke( oDir, 'LPU_D', napr->CODEM_FROM )
        mo_add_xml_stroke( oDir, 'DATE_H', date2xml( napr->DATE_H_4 ) )
        mo_add_xml_stroke( oDir, 'TIME_H', CharRepl( ':', napr->TIME_H_4, '-' ) )
        mo_add_xml_stroke( oDir, 'DS', napr->DS_4 )
        mo_add_xml_stroke( oDir, 'F_MEDC', lstr( napr->F_MEDC_4 ) )
        ar := _263_pr_prk( napr->PROFIL_K_4, napr->PROFIL_4, nf->DATE_R )
        mo_add_xml_stroke( oDir, 'PROFIL', ar[ 1 ] )
        mo_add_xml_stroke( oDir, 'PROFIL_K', ar[ 2 ] )
        mo_add_xml_stroke( oDir, 'NUM_HIST', napr->NUM_HIST_4 )
        oPAC := oDir:add( hxmlnode():new( 'PATIENT' ) )
        mo_add_xml_stroke( oPAC, 'SURNAME', arr_fio[ 1 ] )
        mo_add_xml_stroke( oPAC, 'NAME', arr_fio[ 2 ] )
        If !Empty( arr_fio[ 3 ] )
          mo_add_xml_stroke( oPAC, 'PATRONYMIC', arr_fio[ 3 ] )
        Endif
        mo_add_xml_stroke( oPAC, 'BIRTHDAY', date2xml( kart->date_r ) )
        mo_add_xml_stroke( oPAC, 'SEX', iif( kart->pol == 'М', '1', '2' ) )
        If !Empty( kart->snils )
//          mo_add_xml_stroke( oPAC, 'SS', Transform( kart->SNILS, picture_pf ) )
          mo_add_xml_stroke( oPAC, 'SS', Transform_SNILS( kart->SNILS ) )
        Endif
        mo_add_xml_stroke( oPAC, 'TYPE_P', lstr( kart_->VPOLIS ) )
        If !Empty( kart_->SPOLIS )
          mo_add_xml_stroke( oPAC, 'SER_P', kart_->SPOLIS )
        Endif
        mo_add_xml_stroke( oPAC, 'NUM_P', kart_->NPOLIS )
        If kart_->VPOLIS == 3
          mo_add_xml_stroke( oPAC, 'ENP', kart_->NPOLIS )
        Endif
        If Empty( cSMOname )
          mo_add_xml_stroke( oPAC, 'SMO', kart_->smo )
        Else
          mo_add_xml_stroke( oPAC, 'NAME_SMO', cSMOname )
        Endif
        mokato := '18000'
        If !Empty( kart_->KVARTAL_D )
          mokato := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
        Endif
        mo_add_xml_stroke( oPAC, 'REG_OMS', mokato )
      Next
      oXmlDoc:save( nfile + sxml() )
      name_zip := nfile + szip()
      If chip_create_zipxml( name_zip, { nfile + sxml() }, .t., 2 )
        nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
        nf->TXT_F := name_txt
        AAdd( arr_f, { nfile, Len( arr_i04[ i, 2 ] ) } )
      Else
        file_error := nfile
        fl_error := .t. ; Exit
      Endif
      dbUnlockAll()
      Commit
    Next
  Endif
  // I05
  If !fl_error
    Select NAPR
    Index On kod to ( cur_dir() + 'tmp_napr' ) For TYPE_H_4 == 4 .and. Empty( KOD_F_4out )
    Go Top
    Do While !Eof()
      If ( i := AScan( arr_i05, {| x| x[ 1 ] == napr->DATE_H_4 } ) ) == 0
        AAdd( arr_i05, { napr->DATE_H_4, {} } ) ; i := Len( arr_i05 )
      Endif
      AAdd( arr_i05[ i, 2 ], napr->kod )
      Select NAPR
      Skip
    Enddo
    For i := 1 To Len( arr_i05 )
      mnn := 0
      Select NF
      find ( '5' + DToS( arr_i05[ i, 1 ] ) + '1' )
      Do While nf->tip_f == 5 .and. nf->date_r == arr_i05[ i, 1 ] .and. nf->in_out == 1 .and. !Eof()
        mnn := nf->nn
        Skip
      Enddo
      ++mnn // номер пакета
      nfile := 'I05T34M' + glob_mo()[ _MO_KOD_TFOMS ] + '_' + ;
        Right( Str( Year( arr_i05[ i, 1 ] ), 4 ), 2 ) + ;
        StrZero( Month( arr_i05[ i, 1 ] ), 2 ) + ;
        StrZero( Day( arr_i05[ i, 1 ] ), 2 ) + ;
        lstr( mnn )
      Select NF
      addrec( 1 )
      nf->KOD := RecNo()            // код файла
      nf->DATE_F := sys_date        // дата файла
      nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
      nf->DATE_R := arr_i05[ i, 1 ]    // отчётная дата
      nf->NN := mnn                 // порядковый номер пакета за отчётную дату
      nf->TIP_F := 5                // от 1 до 7 (пакеты от I01 до I07)
      nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
      nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
      nf->KOL := Len( arr_i05[ i, 2 ] )  // количество пациентов в файле
      nf->DWORK := sys_date         // дата обработки файла
      nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
      nf->TWORK2 := ''              // время окончания обработки
      nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
      nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
      //
      oXmlDoc := hxmldoc():new()
      oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
      mo_add_xml_stroke( oXmlNode, 'VERSION', '2.0' )
      mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( nf->DATE_F ) )
      mo_add_xml_stroke( oXmlNode, 'NAME_F', nf->NAME_F )
      mo_add_xml_stroke( oXmlNode, 'DATE_R', date2xml( nf->DATE_R ) )
      oMo_d := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'MO_EXTR' ) )
      mo_add_xml_stroke( oMo_d, 'MO', glob_mo()[ _MO_KOD_FFOMS ] )
      mo_add_xml_stroke( oMo_d, 'LPU', glob_mo()[ _MO_KOD_TFOMS ] )
      For j := 1 To Len( arr_i05[ i, 2 ] )
        Select NAPR
        Goto ( arr_i05[ i, 2, j ] )
        g_rlock( forever )
        napr->KOD_F_4out := nf->KOD // код файла - по файлу mo_nfile
        napr->T_ANS_4 := 0
        napr->DATE_R := kart->date_r // дата рождения
        napr->SEX := iif( kart->pol == 'М', 1, 2 ) // пол
        napr->ENP := iif( kart_->VPOLIS == 3, kart_->NPOLIS, '' ) // единый номер полиса ОМС
        //
        Select NFN
        Append Blank
        nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
        nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
        nfn->OSHIB := 0
        //
        arr_fio := retfamimot( 1, .f. ) ; cSMOname := ''
        If AllTrim( kart_->smo ) == '34'
          cSMOname := ret_inogsmo_name( 1 )
        Endif
        oDir := oMo_d:add( hxmlnode():new( 'HOSP' ) )
        mo_add_xml_stroke( oDir, 'ID_H', napr->id_4 )
        mo_add_xml_stroke( oDir, 'DATE_H', date2xml( napr->DATE_H_4 ) )
        mo_add_xml_stroke( oDir, 'TIME_H', CharRepl( ':', napr->TIME_H_4, '-' ) )
        mo_add_xml_stroke( oDir, 'DS', napr->DS_4 )
        mo_add_xml_stroke( oDir, 'F_MEDC', lstr( napr->F_MEDC_4 ) )
        ar := _263_pr_prk( napr->PROFIL_K_4, napr->PROFIL_4, nf->DATE_R )
        mo_add_xml_stroke( oDir, 'PROFIL', ar[ 1 ] )
        mo_add_xml_stroke( oDir, 'PROFIL_K', ar[ 2 ] )
        mo_add_xml_stroke( oDir, 'NUM_HIST', napr->NUM_HIST_4 )
        oPAC := oDir:add( hxmlnode():new( 'PATIENT' ) )
        mo_add_xml_stroke( oPAC, 'SURNAME', arr_fio[ 1 ] )
        mo_add_xml_stroke( oPAC, 'NAME', arr_fio[ 2 ] )
        If !Empty( arr_fio[ 3 ] )
          mo_add_xml_stroke( oPAC, 'PATRONYMIC', arr_fio[ 3 ] )
        Endif
        mo_add_xml_stroke( oPAC, 'BIRTHDAY', date2xml( kart->date_r ) )
        mo_add_xml_stroke( oPAC, 'SEX', iif( kart->pol == 'М', '1', '2' ) )
        If !Empty( kart->snils )
//          mo_add_xml_stroke( oPAC, 'SS', Transform( kart->SNILS, picture_pf ) )
          mo_add_xml_stroke( oPAC, 'SS', Transform_SNILS( kart->SNILS ) )
        Endif
        If !Empty( kart_->NPOLIS )
          mo_add_xml_stroke( oPAC, 'TYPE_P', lstr( kart_->VPOLIS ) )
          If !Empty( kart_->SPOLIS )
            mo_add_xml_stroke( oPAC, 'SER_P', kart_->SPOLIS )
          Endif
          mo_add_xml_stroke( oPAC, 'NUM_P', kart_->NPOLIS )
          If Empty( cSMOname )
            mo_add_xml_stroke( oPAC, 'SMO', kart_->smo )
            If kart_->VPOLIS == 3
              mo_add_xml_stroke( oPAC, 'ENP', kart_->NPOLIS )
            Endif
          Else
            If kart_->VPOLIS == 3
              mo_add_xml_stroke( oPAC, 'ENP', kart_->NPOLIS )
            Endif
            mo_add_xml_stroke( oPAC, 'NAME_SMO', cSMOname )
          Endif
          mokato := '18000'
          If !Empty( kart_->KVARTAL_D )
            mokato := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
          Endif
          mo_add_xml_stroke( oPAC, 'REG_OMS', mokato )
        Endif
      Next
      oXmlDoc:save( nfile + sxml() )
      name_zip := nfile + szip()
      If chip_create_zipxml( name_zip, { nfile + sxml() }, .t., 2 )
        nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
        nf->TXT_F := name_txt
        AAdd( arr_f, { nfile, Len( arr_i05[ i, 2 ] ) } )
      Else
        file_error := nfile
        fl_error := .t. ; Exit
      Endif
      dbUnlockAll()
      Commit
    Next
  Endif
  // I06
  If !fl_error
    Select NAPR
    Index On kod to ( cur_dir() + 'tmp_napr' ) ;
      For KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. !Empty( DATE_6 ) .and. Empty( KOD_F_6out )
    Go Top
    Do While !Eof()
      If ( i := AScan( arr_i06, {| x| x[ 1 ] == napr->DATE_6 } ) ) == 0
        AAdd( arr_i06, { napr->DATE_6, {} } ) ; i := Len( arr_i06 )
      Endif
      AAdd( arr_i06[ i, 2 ], napr->kod )
      Select NAPR
      Skip
    Enddo
    For i := 1 To Len( arr_i06 )
      mnn := 0
      Select NF
      find ( '6' + DToS( arr_i06[ i, 1 ] ) + '1' )
      Do While nf->tip_f == 6 .and. nf->date_r == arr_i06[ i, 1 ] .and. nf->in_out == 1 .and. !Eof()
        mnn := nf->nn
        Skip
      Enddo
      ++mnn // номер пакета
      nfile := 'I06T34M' + glob_mo()[ _MO_KOD_TFOMS ] + '_' + ;
        Right( Str( Year( arr_i06[ i, 1 ] ), 4 ), 2 ) + ;
        StrZero( Month( arr_i06[ i, 1 ] ), 2 ) + ;
        StrZero( Day( arr_i06[ i, 1 ] ), 2 ) + ;
        lstr( mnn )
      Select NF
      addrec( 1 )
      nf->KOD := RecNo()            // код файла
      nf->DATE_F := sys_date        // дата файла
      nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
      nf->DATE_R := arr_i06[ i, 1 ]    // отчётная дата
      nf->NN := mnn                 // порядковый номер пакета за отчётную дату
      nf->TIP_F := 6                // от 1 до 7 (пакеты от I01 до I07)
      nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
      nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
      nf->KOL := Len( arr_i06[ i, 2 ] )  // количество пациентов в файле
      nf->DWORK := sys_date         // дата обработки файла
      nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
      nf->TWORK2 := ''              // время окончания обработки
      nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
      nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
      //
      oXmlDoc := hxmldoc():new()
      oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
      mo_add_xml_stroke( oXmlNode, 'VERSION', '2.0' )
      mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( nf->DATE_F ) )
      mo_add_xml_stroke( oXmlNode, 'NAME_F', nf->NAME_F )
      mo_add_xml_stroke( oXmlNode, 'DATE_R', date2xml( nf->DATE_R ) )
      oMo_d := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'MO_DC' ) )
      mo_add_xml_stroke( oMo_d, 'MO', glob_mo()[ _MO_KOD_FFOMS ] )
      mo_add_xml_stroke( oMo_d, 'LPU', glob_mo()[ _MO_KOD_TFOMS ] )
      For j := 1 To Len( arr_i06[ i, 2 ] )
        Select NAPR
        Goto ( arr_i06[ i, 2, j ] )
        g_rlock( forever )
        napr->KOD_F_6out := nf->KOD // код файла - по файлу mo_nfile
        napr->T_ANS_6 := 0
        //
        Select NFN
        Append Blank
        nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
        nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
        nfn->OSHIB := 0
        //
        oDir := oMo_d:add( hxmlnode():new( 'DISCH' ) )
        mo_add_xml_stroke( oDir, 'ID_DISCH', napr->id_6 )
        mo_add_xml_stroke( oDir, 'DATE_H', date2xml( napr->DATE_H_4 ) )
        mo_add_xml_stroke( oDir, 'DATE_D', date2xml( napr->DATE_6 ) )
        mo_add_xml_stroke( oDir, 'F_MEDC', lstr( napr->F_MEDC_4 ) )
        ar := _263_pr_prk( napr->PROFIL_K_4, napr->PROFIL_4, nf->DATE_R )
        mo_add_xml_stroke( oDir, 'PROFIL', ar[ 1 ] )
        mo_add_xml_stroke( oDir, 'PROFIL_K', ar[ 2 ] )
        mo_add_xml_stroke( oDir, 'USL_OK', lstr( iif( napr->usl_ok_4 == 2, 2, 1 ) ) )
        If napr->TYPE_H_4 == 1
          mo_add_xml_stroke( oDir, 'ID_D', napr->id_1 )
          mo_add_xml_stroke( oDir, 'MO_D', ret_mo( napr->CODEM_FROM )[ _MO_KOD_FFOMS ] )
          mo_add_xml_stroke( oDir, 'LPU_D', napr->CODEM_FROM )
        Endif
        mo_add_xml_stroke( oDir, 'NUM_HIST', napr->NUM_HIST_4 )
        oPAC := oDir:add( hxmlnode():new( 'PATIENT' ) )
        mo_add_xml_stroke( oPAC, 'BIRTHDAY', date2xml( iif( Empty( napr->DATE_R ), kart->date_r, napr->DATE_R ) ) )
        mo_add_xml_stroke( oPAC, 'SEX', iif( Empty( napr->SEX ), iif( kart->pol == 'М', '1', '2' ), lstr( napr->SEX ) ) )
        If !Empty( napr->ENP )
          mo_add_xml_stroke( oPAC, 'ENP', napr->ENP )
        Elseif kart_->VPOLIS == 3
          mo_add_xml_stroke( oPAC, 'ENP', kart_->NPOLIS )
        Endif
      Next
      oXmlDoc:save( nfile + sxml() )
      name_zip := nfile + szip()
      If chip_create_zipxml( name_zip, { nfile + sxml() }, .t., 2 )
        nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
        nf->TXT_F := name_txt
        AAdd( arr_f, { nfile, Len( arr_i06[ i, 2 ] ) } )
      Else
        file_error := nfile
        fl_error := .t. ; Exit
      Endif
      dbUnlockAll()
      Commit
    Next
  Endif
  // I07
  If !fl_error .and. yes_i07
    kart_->( dbCloseArea() )
    kart->( dbCloseArea() )
    napr->( dbCloseArea() )
    g_use( dir_server() + 'mo_n7d', , 'D7' )
    nfile := 'I07T34M' + glob_mo()[ _MO_KOD_TFOMS ]
    Select NF
    Index On Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) For in_out == 1
    find ( Upper( nfile ) ) // наверное уже отправляли I07 в ТФОМС
    If Found()
      g_rlock( forever ) // бесконечная попытка блокировать запись
      // удалим предыдущий XML-файл
      Delete File ( dir_server() + dir_NAPR_MO() + hb_ps() + AllTrim( nf->NAME_F ) + szip() )
    Else
      g_rlock( .t., forever ) // бесконечная попытка добавить запись
      nf->KOD := RecNo()            // код файла
    Endif
    nfile += '_' + Right( Str( Year( d7->DATE_R_EDI ), 4 ), 2 ) + ;
      StrZero( Month( d7->DATE_R_EDI ), 2 ) + ;
      StrZero( Day( d7->DATE_R_EDI ), 2 ) + '1'
    nf->DATE_F := sys_date        // дата файла
    nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
    nf->DATE_R := d7->DATE_R_EDI  // отчётная дата
    nf->NN := 1                   // порядковый номер пакета за отчётную дату
    nf->TIP_F := 7                // от 1 до 7 (пакеты от I01 до I07)
    nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
    nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
    nf->KOL := 0                  // количество пациентов в файле
    nf->DWORK := sys_date         // дата обработки файла
    nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
    nf->TWORK2 := ''              // время окончания обработки
    nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
    //
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
    mo_add_xml_stroke( oXmlNode, 'VERSION', '2.0' )
    mo_add_xml_stroke( oXmlNode, 'DATE_F', date2xml( nf->DATE_F ) )
    mo_add_xml_stroke( oXmlNode, 'NAME_F', nf->NAME_F )
    mo_add_xml_stroke( oXmlNode, 'DATE_R', date2xml( nf->DATE_R ) )
    oMo_d := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'MO_PLACE' ) )
    mo_add_xml_stroke( oMo_d, 'MO', glob_mo()[ _MO_KOD_FFOMS ] )
    mo_add_xml_stroke( oMo_d, 'LPU', glob_mo()[ _MO_KOD_TFOMS ] )
    //
    g_use( dir_server() + 'mo_n7out', , 'N7' )
    Index On PadR( inieditspr( A__MENUVERT, arr_t007(), n7->PROFIL_K ), 60 ) + Str( n7->PROFIL_K, 3 ) + ;
      PadR( inieditspr( A__MENUVERT, getv002(), n7->PROFIL ), 20 ) + Str( n7->PROFIL, 3 ) to ( cur_dir() + 'tmp_n7' )
    _263_put_10_days( nf->DATE_R )
    Select N7
    Go Top
    Do While !Eof()
      oDir := oMo_d:add( hxmlnode():new( 'PLACES' ) )
      mo_add_xml_stroke( oDir, 'ID_PL', mo_guid( 1, n7->( RecNo() ) ) )
      mo_add_xml_stroke( oDir, 'USL_OK', lstr( iif( n7->usl_ok == 2, 2, 1 ) ) )
      ar := _263_pr_prk( n7->PROFIL_K, n7->PROFIL, nf->DATE_R )
      mo_add_xml_stroke( oDir, 'PROFIL', ar[ 1 ] )
      mo_add_xml_stroke( oDir, 'PROFIL_K', ar[ 2 ] )
      mo_add_xml_stroke( oDir, 'QUANTITY', lstr( n7->QUANTITY ) )
      mo_add_xml_stroke( oDir, 'Q_P', lstr( n7->Q_P ) )
      mo_add_xml_stroke( oDir, 'Q_AP', lstr( n7->Q_AP ) )
      mo_add_xml_stroke( oDir, 'Q_DP', lstr( n7->Q_DP ) )
      mo_add_xml_stroke( oDir, 'Q_HP', lstr( n7->Q_HP ) )
      oFP := oDir:add( hxmlnode():new( 'FREE_PLACES' ) )
      ifp := 0
      For d := nf->DATE_R To nf->DATE_R + 100
        If d == nf->DATE_R .or. is_work_day( d )
          oZAP := oFP:add( hxmlnode():new( 'ZAP' ) )
          mo_add_xml_stroke( oZAP, 'DATE_PL', date2xml( d ) )
          pole := iif( ifp == 0, 'n7->PLACE_FREE', 'n7->PLACE' + lstr( ifp ) )
          mo_add_xml_stroke( oZAP, 'PLACE_FREE', lstr( &pole ) )
          pole := 'n7->PF_M' + iif( ifp == 0, '', lstr( ifp ) )
          mo_add_xml_stroke( oZAP, 'PF_M', lstr( &pole ) )
          pole := 'n7->PF_W' + iif( ifp == 0, '', lstr( ifp ) )
          mo_add_xml_stroke( oZAP, 'PF_W', lstr( &pole ) )
          pole := 'n7->PF_C' + iif( ifp == 0, '', lstr( ifp ) )
          mo_add_xml_stroke( oZAP, 'PF_C', lstr( &pole ) )
          If++ifp > 10
            Exit
          Endif
        Endif
      Next
      oSMO := oDir:add( hxmlnode():new( 'SMO_V' ) )
      mo_add_xml_stroke( oSMO, 'SMO', '34001' )
      mo_add_xml_stroke( oSMO, 'V_H', '0' )
      oSMO := oDir:add( hxmlnode():new( 'SMO_V' ) )
      mo_add_xml_stroke( oSMO, 'SMO', '34002' )
      mo_add_xml_stroke( oSMO, 'V_H', '0' )
      oSMO := oDir:add( hxmlnode():new( 'SMO_V' ) )
      mo_add_xml_stroke( oSMO, 'SMO', '34006' )
      mo_add_xml_stroke( oSMO, 'V_H', '0' )
      oSMO := oDir:add( hxmlnode():new( 'SMO_V' ) )
      mo_add_xml_stroke( oSMO, 'SMO', '34007' )
      mo_add_xml_stroke( oSMO, 'V_H', '0' )
      Select N7
      Skip
    Enddo
    oXmlDoc:save( nfile + sxml() )
    name_zip := nfile + szip()
    If chip_create_zipxml( name_zip, { nfile + sxml() }, .t., 2 )
      nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
      nf->TXT_F := name_txt
      Select D7
      g_rlock( forever )
      d7->DATE_R_OUT := d7->DATE_R_EDI
      d7->DATE_OUT := sys_date
      AAdd( arr_f, { nfile, 0 } )
      dbUnlockAll()
      Commit
    Else
      file_error := nfile
      fl_error := .t.
    Endif
  Endif
  If fl_error
    dbUnlockAll()
    Commit
  Endif
  If Len( arr_f ) > 0 .or. fl_error
    StrFile( Space( 10 ) + 'Протокол создания информационных пакетов для ТФОМС' + ;
      hb_eol(), cFileProtokol )
    StrFile( Space( 10 ) + full_date( sys_date ) + 'г. ' + cTimeBegin + ;
      hb_eol(), cFileProtokol, .t. )
    If Len( arr_f ) > 0
      ASort( arr_f, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      For i := 1 To Len( arr_f )
        chip_copy_zipxml( dir_server() + dir_NAPR_MO() + hb_ps() + arr_f[ i, 1 ] + szip(), Left( dir_263_to, Len( dir_263_to ) -1 ) )
        StrFile( hb_eol() + ;
          'Создан файл пакета ' + arr_f[ i, 1 ] + iif( arr_f[ i, 2 ] == 0, '', ' - ' + lstr( arr_f[ i, 2 ] ) + ' чел.' ) + ;
          hb_eol(), cFileProtokol, .t. )
      Next
    Endif
    If fl_error
      StrFile( hb_eol() + ;
        'Произошла ошибка при создании файла пакета ' + file_error + hb_eol() + ;
        'Обратитесь к разработчикам!' + ;
        hb_eol(), cFileProtokol, .t. )
    Endif
    If Len( arr_f ) > 0
      StrFile( hb_eol() + ;
        'Все файлы информационных пакетов записаны в каталог обмена' + hb_eol() + ;
        dir_263_to + ' для отправки в ТФОМС' + ;
        hb_eol(), cFileProtokol, .t. )
      Copy File ( cFileProtokol ) to ( name_txt )
      // запишем файл протокола записи
      chip_copy_zipxml( name_txt, dir_server() + dir_NAPR_MO(), .t. )
    Endif
    viewtext( devide_into_pages( cFileProtokol, 60, 80 ), , , , .t., , , 2 )
  Else
    func_error( 4, 'Не обнаружено подготовленной информации для создания информационных пакетов' )
  Endif
  Close databases
  rest_box( buf )
  mo_unlock_task( X_263 )
  Return Nil

// 03.08.14 Просмотр протоколов записи информационных пакетов в ТФОМС
Function _263_to_protokol()

  Local i, d, s, blk, t_arr[ BR_LEN ], buf := save_maxrow()

  mywait()
  dbCreate( cur_dir() + 'tmp', { ;
    { 'named', 'D', 8, 0 }, ;
    { 'namet', 'C', 9, 0 }, ;
    { 'txt_f', 'C', 15, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  blk := {| x| s := name_without_ext( strippath( x ) ), ;
    dbAppend(), ;
    tmp->named := SToD( Left( s, 8 ) ), ;
    tmp->namet := Left( Right( s, 6 ), 2 ) + ':' + Left( Right( s, 4 ), 2 ) + ':' + Right( s, 2 ), ;
    tmp->txt_f := s }
  scandirfiles( dir_server() + dir_NAPR_MO() + hb_ps(), '*' + stxt(), blk )
  If LastRec() == 0
    Close databases
    rest_box( buf )
    Return func_error( 4, 'Пока ещё не создавали информационные пакеты для отправки в ТФОМС' )
  Endif
  Index On Descend( txt_f ) to ( cur_dir() + 'tmp' )
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL -5
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 23
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  blk := nil
  t_arr[ BR_COLUMN ] := { { '   Дата', {|| full_date( tmp->named ) }, blk }, ;
    { ' Время', {|| tmp->namet }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - просмотр файла протокола записи' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_to_protokol( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  rest_box( buf )
  Return Nil

// 03.08.14
Function f2_263_to_protokol( nKey, oBrow, regim )

  Local ret := -1

  Do Case
  Case regim == 'edit'
    If nKey == K_ENTER
      viewtext( devide_into_pages( dir_server() + dir_NAPR_MO() + hb_ps() + tmp->txt_f + stxt(), 60, 80 ), , , , .t., , , 2 )
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

// 19.02.17 Список информационных пакетов с выписанными направлениями
Function _263_to_i01()

  Static str_sem := '263_to_I01'
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Private goal_dir := dir_server() + dir_NAPR_MO() + hb_ps()
  g_use( dir_server() + 'mo_nfile', , 'NF' )
  Index On DToS( date_r ) + Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) ;
    For in_out == 1 .and. tip_f == 1 DESCENDING
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    Return func_error( 4, 'Пока не было записи пакетов I01 в ТФОМС' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Информационные пакеты I01, отправленные в ТФОМС'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t. }
  blk := {|| iif( Empty( nf->TWORK2 ) .or. nf->t_ans == 2, { 7, 8 }, iif( nf->t_ans == 0, { 5, 6 }, { 1, 2 } ) ) }
  t_arr[ BR_COLUMN ] := { { ' Имя файла', {|| Left( nf->name_f, 22 ) }, blk }, ;
    { ' Отч.дата', {|| full_date( nf->date_r ) }, blk }, ;
    { ' Кол.', {|| Str( nf->kol, 5 ) }, blk }, ;
    { 'Дата и время записи', {|| PadR( f1_263_to_i01( 3 ), 38 ) }, blk } }
  // t_arr[BR_STEP_FUNC] := {|| f1_263_to_I01(1) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_to_i01( nk, ob, 'edit' ) }
  // f1_263_to_I01(0)
  edit_browse( t_arr )
  // f1_263_to_I01(2)
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 19.02.17
Function f1_263_to_i01( k )

  Static buf
  Local s, ta[ 2 ], k1, k2

  If k == 0
    buf := box_shadow( MaxRow() -4, 0, MaxRow() -1, 79, color1, 'Полное наименование стационара', 'B+/B' )
  Elseif k == 1
    perenos( ta, ret_mo( SubStr( nf->name_f, 12, 6 ) )[ _MO_FULL_NAME ], 78 )
    @ MaxRow() -3, 1 Say PadC( AllTrim( ta[ 1 ] ), 78 ) Color color14
    @ MaxRow() -2, 1 Say PadC( AllTrim( ta[ 2 ] ), 78 ) Color color14
  Elseif k == 2
    rest_box( buf )
  Elseif k == 3
    s := date_8( nf->dwork ) + ' ' + nf->twork1
    If Empty( nf->TWORK2 )
      s += ' ЗАПИСЬ НЕ ЗАВЕРШЕНА'
    Elseif nf->T_ANS == 0
      s += ' ответ не получен'
    Elseif nf->T_ANS == 2
      s += ' ошибка (из ТФОМС)'
    Endif
    If !hb_FileExists( goal_dir + AllTrim( nf->name_f ) + szip() )
      s += ' нет файла'
    Endif
    Return s
  Endif
  Return Nil

// 10.09.25
Function f2_263_to_i01( nKey, oBrow, regim )

  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, ;
    n_file := cur_dir() + 'i01.txt', sh := 80, HH := 60, t_arr[ 4 ], s, s1, s2, s3, s4

  If regim == 'edit'
    Do Case
    Case nKey == K_F5
      copy_i0_file_once_more()
    Case nKey == K_CTRL_F12
      If Empty( nf->TWORK2 )
        buf := SaveScreen()
        arr := {}
        AAdd( arr, 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
        AAdd( arr, 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
        AAdd( arr, '' )
        AAdd( arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I01' )
        AAdd( arr, '' )
        AAdd( arr, 'После подтверждения аннулирования все последствия записи данного' )
        AAdd( arr, 'файла, а также сам файл, будут удалены (а направления останутся)' )
        f_message( arr, , cColorSt2Msg, cColorSt1Msg )
        s := 'Подтвердите аннулирование информационного пакета I01'
        stat_msg( s )
        mybell( 2 )
        If f_esc_enter( 'аннулирования', .t. )
          mywait()
          g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
          Index On kod to ( cur_dir() + 'tmp_napr' ) For KOD_F_1out == nf->kod
          arr := {}
          dbEval( {|| AAdd( arr, napr->( RecNo() ) ) } )
          Set Index To
          For i := 1 To Len( arr )
            Goto ( arr[ i ] )
            g_rlock( forever )
            napr->KOD_F_1out := 0 // код файла - по файлу mo_nfile
          Next
          napr->( dbCloseArea() )
          Select NF
          deleterec()
          stat_msg( 'Аннулирование завершено! Можете записать файл снова' )
          mybell( 2 )
          Go Top
          ret := 1
        Endif
        RestScreen( buf )
      Else
        func_error( 4, 'Данный файл был успешно записан. Аннулирование запрещено!' )
      Endif
    Case nKey == K_ENTER
      buf := save_maxrow()
      mywait()
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
      If Empty( nf->TWORK2 )
        add_string( 'ЗАПИСЬ НЕ ЗАВЕРШЕНА' )
      Elseif nf->T_ANS == 0
        add_string( 'ответ из ТФОМС не получен' )
      Elseif nf->T_ANS == 2
        add_string( 'ответ из ТФОМС получен - ОШИБКА' )
      Endif
      add_string( 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
      add_string( '' )
      add_string( 'Это информационный пакет со сведениями о выписанных в поликлинике направлениях' )
      r_use( dir_server() + 'kartote_', , '_KART_' )
      r_use( dir_server() + 'kartotek', , '_KART' )
      Set Relation To kod into _KART_
      r_use( dir_server() + 'mo_nfina', , 'NFN' )
      Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == nf->kod
      r_use( dir_server() + 'mo_nnapr', , 'NAPR' )
      Set Relation To kod_k into _KART
      Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) For KOD_F_1out == nf->kod
      i := 0
      Go Top
      Do While !Eof()
        verify_ff( HH -5, .t., sh )
        add_string( '' )
        add_string( lstr( ++i ) + '. Направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) )
        If napr->S_CODEM == glob_mo()[ _MO_KOD_TFOMS ]
          add_string( Space( 3 ) + 'в стационар нашего МО' )
        Else
          add_string( Space( 3 ) + 'в стационар МО ' + ret_mo( napr->S_CODEM )[ _MO_SHORT_NAME ] )
        Endif
        add_string( Space( 3 ) + AllTrim( _kart->fio ) + ', д.р.' + full_date( _kart->date_r ) )
        add_string( Space( 3 ) + 'планируемая дата госпитализации ' + date_8( napr->DATE_H_1 ) + ' по диагнозу ' + AllTrim( napr->DS_1 ) )
        add_string( Space( 3 ) + inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_1 ) + ;
          ' (' + inieditspr( A__MENUVERT, getv002(), napr->PROFIL_1 ) + ')' )
        Select NFN
        find ( Str( napr->kod, 6 ) )
        If Found() .and. nfn->OSHIB > 0
          s := Space( 3 ) + 'ОШИБКА ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
          If !Empty( nfn->IM_POL )
            s += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
          Endif
          add_string( s )
        Endif
        If napr->t_ans_1 == 2
          add_string( Space( 3 ) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована' )
        Endif
        Select NAPR
        Skip
      Enddo
      FClose( fp )
      _kart->( dbCloseArea() )
      _kart_->( dbCloseArea() )
      nfn->( dbCloseArea() )
      napr->( dbCloseArea() )
      rest_box( buf )
      viewtext( n_file, , , , .t., , , 2 )
      Select NF
    Endcase
  Endif
  Return ret

// 06.07.22 Список информационных пакетов с аннулированными направлениями
Function _263_to_i03()

  Static str_sem := '263_to_I03'
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Private goal_dir := dir_server() + dir_NAPR_MO() + hb_ps()
  g_use( dir_server() + 'mo_nfile', , 'NF' )
  Index On DToS( date_r ) + Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) ;
    For in_out == 1 .and. tip_f == 3 DESCENDING
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    Return func_error( 4, 'Пока не было записи пакетов I03 в ТФОМС' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Информационные пакеты I03, отправленные в ТФОМС'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t. }
  blk := {|| iif( Empty( nf->TWORK2 ) .or. nf->t_ans == 2, { 7, 8 }, iif( nf->t_ans == 0, { 5, 6 }, { 1, 2 } ) ) }
  t_arr[ BR_COLUMN ] := { { ' Имя файла', {|| Left( nf->name_f, 22 ) }, blk }, ;
    { ' Отч.дата', {|| full_date( nf->date_r ) }, blk }, ;
    { ' Кол.', {|| Str( nf->kol, 5 ) }, blk }, ;
    { 'Дата и время записи', {|| PadR( f1_263_to_i01( 3 ), 38 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_to_i03( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 10.09.25
Function f2_263_to_i03( nKey, oBrow, regim )

  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, ;
    n_file := cur_dir() + 'I03.txt', sh := 80, HH := 60, t_arr[ 4 ], s1, s2, s3, s4

  If regim == 'edit'
    Do Case
    Case nKey == K_F5
      copy_i0_file_once_more()
    Case nKey == K_CTRL_F12
      If Empty( nf->TWORK2 )
        buf := SaveScreen()
        arr := {}
        AAdd( arr, 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
        AAdd( arr, 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
        AAdd( arr, '' )
        AAdd( arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I03' )
        AAdd( arr, '' )
        AAdd( arr, 'После подтверждения аннулирования все последствия записи данного' )
        AAdd( arr, 'файла, а также сам файл, будут удалены (а направления останутся)' )
        f_message( arr, , cColorSt2Msg, cColorSt1Msg )
        s := 'Подтвердите аннулирование информационного пакета I03'
        stat_msg( s )
        mybell( 2 )
        If f_esc_enter( 'аннулирования', .t. )
          mywait()
          g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
          Index On kod to ( cur_dir() + 'tmp_napr' ) For KOD_F_3out == nf->kod
          arr := {}
          dbEval( {|| AAdd( arr, napr->( RecNo() ) ) } )
          Set Index To
          For i := 1 To Len( arr )
            Goto ( arr[ i ] )
            g_rlock( forever )
            napr->KOD_F_3out := 0 // код файла - по файлу mo_nfile
          Next
          napr->( dbCloseArea() )
          Select NF
          deleterec()
          stat_msg( 'Аннулирование завершено! Можете записать файл снова' )
          mybell( 2 )
          Go Top
          ret := 1
        Endif
        RestScreen( buf )
      Else
        func_error( 4, 'Данный файл был успешно записан. Аннулирование операции запрещено!' )
      Endif
    Case nKey == K_ENTER
      buf := save_maxrow()
      mywait()
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
      If Empty( nf->TWORK2 )
        add_string( 'ЗАПИСЬ НЕ ЗАВЕРШЕНА' )
      Elseif nf->T_ANS == 0
        add_string( 'ответ из ТФОМС не получен' )
      Elseif nf->T_ANS == 2
        add_string( 'ответ из ТФОМС получен - ОШИБКА' )
      Endif
      add_string( 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
      add_string( '' )
      add_string( 'Это информационный пакет с аннулированными направлениями' )
      r_use( dir_server() + 'kartote_', , '_KART_' )
      r_use( dir_server() + 'kartotek', , '_KART' )
      Set Relation To kod into _KART_
      r_use( dir_server() + 'mo_nfina', , 'NFN' )
      Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == nf->kod
      r_use( dir_server() + 'mo_nnapr', , 'NAPR' )
      Set Relation To kod_k into _KART
      Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) For KOD_F_3out == nf->kod
      i := 0
      Go Top
      Do While !Eof()
        verify_ff( HH -5, .t., sh )
        add_string( '' )
        add_string( lstr( ++i ) + '. Направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) )
        If napr->TIP_ANNUL == 3
          If napr->S_CODEM == glob_mo()[ _MO_KOD_TFOMS ]
            add_string( Space( 3 ) + 'в стационар нашего МО' )
          Else
            add_string( Space( 3 ) + 'в стационар МО ' + ret_mo( napr->S_CODEM )[ _MO_SHORT_NAME ] )
          Endif
          add_string( Space( 3 ) + 'направление аннулировано в нашей ПОЛИКЛИНИКЕ' )
        Else
          If napr->CODEM_1 == glob_mo()[ _MO_KOD_TFOMS ]
            add_string( Space( 3 ) + 'из поликлиники нашего МО' )
          Else
            add_string( Space( 3 ) + 'из поликлиники МО ' + ret_mo( napr->CODEM_1 )[ _MO_SHORT_NAME ] )
          Endif
          add_string( Space( 3 ) + 'направление аннулировано в нашем СТАЦИОНАРЕ' )
        Endif
        add_string( Space( 3 ) + AllTrim( _kart->fio ) + ', д.р.' + full_date( _kart->date_r ) )
        add_string( Space( 3 ) + 'форма оказания медицинской помощи - ' + inieditspr( A__MENUVERT, getv014(), napr->F_MEDC_1 ) )
        add_string( Space( 3 ) + inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_1 ) + ;
          ' (' + inieditspr( A__MENUVERT, getv002(), napr->PROFIL_1 ) + ')' )
        add_string( Space( 3 ) + 'причина аннулирования: ' + inieditspr( A__MENUVERT, get_reason_annul(), napr->rea_annul ) )
        add_string( Space( 3 ) + 'дата аннулирования ' + full_date( napr->date_3 ) )
        Select NFN
        find ( Str( napr->kod, 6 ) )
        If Found() .and. nfn->OSHIB > 0
          s := Space( 3 ) + 'ОШИБКА ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
          If !Empty( nfn->IM_POL )
            s += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
          Endif
          add_string( s )
        Endif
        If napr->t_ans_3 == 2
          add_string( Space( 3 ) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована' )
        Endif
        Select NAPR
        Skip
      Enddo
      FClose( fp )
      _kart->( dbCloseArea() )
      _kart_->( dbCloseArea() )
      nfn->( dbCloseArea() )
      napr->( dbCloseArea() )
      rest_box( buf )
      viewtext( n_file, , , , .t., , , 2 )
      Select NF
    Endcase
  Endif
  Return ret

// 19.02.17 Список информационных пакетов с госпитализациями по направлениям
Function _263_to_i04( k )

  Static str_sem := '263_to_I04'
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  Private ppaket := k

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Private goal_dir := dir_server() + dir_NAPR_MO() + hb_ps()
  g_use( dir_server() + 'mo_nfile', , 'NF' )
  Index On DToS( date_r ) + Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) ;
    For in_out == 1 .and. tip_f == ppaket DESCENDING
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    Return func_error( 4, 'Пока не было записи пакетов I0' + lstr( ppaket ) + ' в ТФОМС' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Информационные пакеты I0' + lstr( ppaket ) + ', отправленные в ТФОМС'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t. }
  blk := {|| iif( Empty( nf->TWORK2 ) .or. nf->t_ans == 2, { 7, 8 }, iif( nf->t_ans == 0, { 5, 6 }, { 1, 2 } ) ) }
  t_arr[ BR_COLUMN ] := { { ' Имя файла', {|| Left( nf->name_f, 22 ) }, blk }, ;
    { ' Отч.дата', {|| full_date( nf->date_r ) }, blk }, ;
    { ' Кол.', {|| Str( nf->kol, 5 ) }, blk }, ;
    { 'Дата и время записи', {|| PadR( f1_263_to_i01( 3 ), 38 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_to_i04( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 10.09.25
Function f2_263_to_i04( nKey, oBrow, regim )

  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, s1, s2, s3, s4, ;
    n_file := cur_dir() + 'i0' + lstr( ppaket ) + stxt(), sh := 80, HH := 60, t_arr[ 4 ]

  If regim == 'edit'
    Do Case
    Case nKey == K_F5
      copy_i0_file_once_more()
    Case nKey == K_CTRL_F12
      If Empty( nf->TWORK2 )
        buf := SaveScreen()
        arr := {}
        AAdd( arr, 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
        AAdd( arr, 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
        AAdd( arr, '' )
        AAdd( arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I0' + lstr( ppaket ) )
        AAdd( arr, '' )
        AAdd( arr, 'После подтверждения аннулирования все последствия записи данного' )
        AAdd( arr, 'файла, а также сам файл, будут удалены (а госпитализации останутся)' )
        f_message( arr, , cColorSt2Msg, cColorSt1Msg )
        s := 'Подтвердите аннулирование информационного пакета I0' + lstr( ppaket )
        stat_msg( s )
        mybell( 2 )
        If f_esc_enter( 'аннулирования', .t. )
          mywait()
          g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
          Index On kod to ( cur_dir() + 'tmp_napr' ) For KOD_F_4out == nf->kod
          arr := {}
          dbEval( {|| AAdd( arr, napr->( RecNo() ) ) } )
          Set Index To
          For i := 1 To Len( arr )
            Goto ( arr[ i ] )
            g_rlock( forever )
            napr->KOD_F_4out := 0 // код файла - по файлу mo_nfile
          Next
          napr->( dbCloseArea() )
          Select NF
          deleterec()
          stat_msg( 'Аннулирование завершено! Можете записать файл снова' )
          mybell( 2 )
          Go Top
          ret := 1
        Endif
        RestScreen( buf )
      Else
        func_error( 4, 'Данный файл был успешно записан. Аннулирование запрещено!' )
      Endif
    Case nKey == K_ENTER
      buf := save_maxrow()
      mywait()
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
      If Empty( nf->TWORK2 )
        add_string( 'ЗАПИСЬ НЕ ЗАВЕРШЕНА' )
      Elseif nf->T_ANS == 0
        add_string( 'ответ из ТФОМС не получен' )
      Elseif nf->T_ANS == 2
        add_string( 'ответ из ТФОМС получен - ОШИБКА' )
      Endif
      add_string( 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
      add_string( '' )
      If ppaket == 4
        add_string( 'Это информационный пакет с госпитализациями по направлениям' )
      Else
        add_string( 'Это информационный пакет с госпитализациями без направлений (экстренно/неотложно)' )
      Endif
      r_use( dir_server() + 'kartote_', , '_KART_' )
      r_use( dir_server() + 'kartotek', , '_KART' )
      Set Relation To kod into _KART_
      r_use( dir_server() + 'mo_nfina', , 'NFN' )
      Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == nf->kod
      r_use( dir_server() + 'mo_nnapr', , 'NAPR' )
      Set Relation To kod_k into _KART
      Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) For KOD_F_4out == nf->kod
      i := 0
      Go Top
      Do While !Eof()
        verify_ff( HH -5, .t., sh )
        add_string( '' )
        add_string( lstr( ++i ) + '. ' + AllTrim( _kart->fio ) + ', д.р.' + full_date( _kart->date_r ) )
        Do Case
        Case napr->TYPE_H_4 == 1
          s := 'Направлен из '
          If napr->CODEM_1 == glob_mo()[ _MO_KOD_TFOMS ]
            s += 'поликлиники нашего МО'
          Else
            s += ret_mo( napr->CODEM_1 )[ _MO_SHORT_NAME ]
          Endif
          add_string( Space( 3 ) + s )
          add_string( Space( 3 ) + 'направление: № ' + AllTrim( napr->NUM_D ) + ' от ' + full_date( napr->DATE_D ) )
        Case napr->TYPE_H_4 == 2
          add_string( Space( 3 ) + 'Переведён из ' + ret_mo( napr->CODEM_FROM )[ _MO_SHORT_NAME ] )
        Case napr->TYPE_H_4 == 3
          add_string( Space( 3 ) + 'Переведён внутри МО из стационарного отделения в стационарное отделение' )
        Endcase
        add_string( Space( 3 ) + 'Дата фактической госпитализации ' + full_date( napr->DATE_H_4 ) + ;
          ', время ' + napr->TIME_H_4 )
        add_string( Space( 3 ) + 'Диагноз приёмного отделения ' + AllTrim( napr->DS_4 ) )
        add_string( Space( 3 ) + inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_4 ) + ;
          ' (' + inieditspr( A__MENUVERT, getv002(), napr->PROFIL_4 ) + ')' )
        add_string( Space( 3 ) + 'Форма оказания медицинской помощи - ' + inieditspr( A__MENUVERT, getv014(), napr->F_MEDC_4 ) )
        add_string( Space( 3 ) + 'Номер истории болезни - ' + AllTrim( napr->NUM_HIST_4 ) )
        Select NFN
        find ( Str( napr->kod, 6 ) )
        If Found() .and. nfn->OSHIB > 0
          s := Space( 3 ) + 'ОШИБКА ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
          If !Empty( nfn->IM_POL )
            s += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
          Endif
          add_string( s )
        Endif
        If napr->t_ans_4 == 2
          add_string( Space( 3 ) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована' )
        Endif
        Select NAPR
        Skip
      Enddo
      FClose( fp )
      _kart->( dbCloseArea() )
      _kart_->( dbCloseArea() )
      nfn->( dbCloseArea() )
      napr->( dbCloseArea() )
      rest_box( buf )
      viewtext( n_file, , , , .t., , , 2 )
      Select NF
    Endcase
  Endif
  Return ret

// 19.02.17 Список информационных пакетов со сведениями о выбывших пациентах
Function _263_to_i06()

  Static str_sem := '263_to_I06'
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Private goal_dir := dir_server() + dir_NAPR_MO() + hb_ps(), ;
    mm_tip_vyb := { { 'выписан', 1 }, { 'умер', 2 }, { 'перевод в другое отделение', 3 } }

  g_use( dir_server() + 'mo_nfile', , 'NF' )
  Index On DToS( date_r ) + Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) ;
    For in_out == 1 .and. tip_f == 6 DESCENDING
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    Return func_error( 4, 'Пока не было записи пакетов I06 в ТФОМС' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Информационные пакеты I06, отправленные в ТФОМС'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t. }
  blk := {|| iif( Empty( nf->TWORK2 ) .or. nf->t_ans == 2, { 7, 8 }, iif( nf->t_ans == 0, { 5, 6 }, { 1, 2 } ) ) }
  t_arr[ BR_COLUMN ] := { { ' Имя файла', {|| Left( nf->name_f, 22 ) }, blk }, ;
    { ' Отч.дата', {|| full_date( nf->date_r ) }, blk }, ;
    { ' Кол.', {|| Str( nf->kol, 5 ) }, blk }, ;
    { 'Дата и время записи', {|| PadR( f1_263_to_i01( 3 ), 38 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_to_i06( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 10.09.25
Function f2_263_to_i06( nKey, oBrow, regim )

  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, s1, s2, s3, s4, ;
    n_file := cur_dir() + 'i06.txt', sh := 80, HH := 60, t_arr[ 4 ]

  If regim == 'edit'
    Do Case
    Case nKey == K_F5
      copy_i0_file_once_more()
    Case nKey == K_CTRL_F12
      If Empty( nf->TWORK2 )
        buf := SaveScreen()
        arr := {}
        AAdd( arr, 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
        AAdd( arr, 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
        AAdd( arr, '' )
        AAdd( arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I06' )
        AAdd( arr, '' )
        AAdd( arr, 'После подтверждения аннулирования все последствия записи данного' )
        AAdd( arr, 'файла, а также сам файл, будут удалены (а выбытия останутся)' )
        f_message( arr, , cColorSt2Msg, cColorSt1Msg )
        s := 'Подтвердите аннулирование информационного пакета I06'
        stat_msg( s )
        mybell( 2 )
        If f_esc_enter( 'аннулирования', .t. )
          mywait()
          g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
          Index On kod to ( cur_dir() + 'tmp_napr' ) For KOD_F_6out == nf->kod
          arr := {}
          dbEval( {|| AAdd( arr, napr->( RecNo() ) ) } )
          Set Index To
          For i := 1 To Len( arr )
            Goto ( arr[ i ] )
            g_rlock( forever )
            napr->KOD_F_6out := 0 // код файла - по файлу mo_nfile
          Next
          napr->( dbCloseArea() )
          Select NF
          deleterec()
          stat_msg( 'Аннулирование завершено! Можете записать файл снова' )
          mybell( 2 )
          Go Top
          ret := 1
        Endif
        RestScreen( buf )
      Else
        func_error( 4, 'Данный файл был успешно записан. Аннулирование запрещено!' )
      Endif
    Case nKey == K_ENTER
      buf := save_maxrow()
      mywait()
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
      If Empty( nf->TWORK2 )
        add_string( 'ЗАПИСЬ НЕ ЗАВЕРШЕНА' )
      Elseif nf->T_ANS == 0
        add_string( 'ответ из ТФОМС не получен' )
      Elseif nf->T_ANS == 2
        add_string( 'ответ из ТФОМС получен - ОШИБКА' )
      Endif
      add_string( 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
      add_string( '' )
      add_string( 'Это информационный пакет с выписанными пациентами' )
      r_use( dir_server() + 'kartote_', , '_KART_' )
      r_use( dir_server() + 'kartotek', , '_KART' )
      Set Relation To kod into _KART_
      r_use( dir_server() + 'mo_nfina', , 'NFN' )
      Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For kod_f == nf->kod
      r_use( dir_server() + 'mo_nnapr', , 'NAPR' )
      Set Relation To kod_k into _KART
      Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) For KOD_F_6out == nf->kod
      i := 0
      Go Top
      Do While !Eof()
        verify_ff( HH -5, .t., sh )
        add_string( '' )
        add_string( lstr( ++i ) + '. ' + AllTrim( _kart->fio ) + ', д.р.' + full_date( _kart->date_r ) )
        Do Case
        Case napr->TYPE_H_4 == 1
          s := 'Направлен из '
          If napr->CODEM_1 == glob_mo()[ _MO_KOD_TFOMS ]
            s += 'поликлиники нашего МО'
          Else
            s += ret_mo( napr->CODEM_1 )[ _MO_SHORT_NAME ]
          Endif
          add_string( Space( 3 ) + s )
          add_string( Space( 3 ) + 'направление: № ' + AllTrim( napr->NUM_D ) + ' от ' + full_date( napr->DATE_D ) )
        Case napr->TYPE_H_4 == 2
          add_string( Space( 3 ) + 'Переведён из ' + ret_mo( napr->CODEM_FROM )[ _MO_SHORT_NAME ] )
        Case napr->TYPE_H_4 == 3
          add_string( Space( 3 ) + 'Переведён внутри МО из стационарного отделения в стационарное отделение' )
        Endcase
        add_string( Space( 3 ) + 'Дата фактической госпитализации ' + full_date( napr->DATE_H_4 ) + ;
          ', время ' + napr->TIME_H_4 )
        add_string( Space( 3 ) + 'Диагноз приёмного отделения ' + AllTrim( napr->DS_4 ) )
        add_string( Space( 3 ) + inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_4 ) + ;
          ' (' + inieditspr( A__MENUVERT, getv002(), napr->PROFIL_4 ) + ')' )
        add_string( Space( 3 ) + 'Форма оказания медицинской помощи - ' + inieditspr( A__MENUVERT, getv014(), napr->F_MEDC_4 ) )
        add_string( Space( 3 ) + 'Номер истории болезни - ' + AllTrim( napr->NUM_HIST_4 ) )
        add_string( Space( 3 ) + 'Тип выбытия - ' + inieditspr( A__MENUVERT, mm_tip_vyb, napr->type_6 ) )
        add_string( Space( 3 ) + 'Дата выбытия - ' + full_date( napr->date_6 ) )
        Select NFN
        find ( Str( napr->kod, 6 ) )
        If Found() .and. nfn->OSHIB > 0
          s := Space( 3 ) + 'ОШИБКА ' + lstr( nfn->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nfn->OSHIB )
          If !Empty( nfn->IM_POL )
            s += ' (в поле ' + AllTrim( nfn->IM_POL ) + ')'
          Endif
          add_string( s )
        Endif
        If napr->t_ans_6 == 2
          add_string( Space( 3 ) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована' )
        Endif
        Select NAPR
        Skip
      Enddo
      FClose( fp )
      _kart->( dbCloseArea() )
      _kart_->( dbCloseArea() )
      nfn->( dbCloseArea() )
      napr->( dbCloseArea() )
      rest_box( buf )
      viewtext( n_file, , , , .t., , , 2 )
      Select NF
    Endcase
  Endif
  Return ret

// 24.09.14 записать файл любого пакета в каталог обмена
Function copy_i0_file_once_more()

  Local buf, t_arr, zip_file := AllTrim( nf->name_f ) + szip()

  If Empty( dir_263_to )
    func_error( 4, 'Не настроен каталог обмена в режиме "Настройка каталогов"' )
  Elseif hb_FileExists( goal_dir + zip_file )
    buf := SaveScreen()
    t_arr := { 'Файл ' + zip_file + ' ещё раз', ;
      'записывается в каталог ' + dir_263_to, ;
      'для отправки в ТФОМС' }
    f_message( t_arr, , color1, color8 )
    If f_esc_enter( 'записи файла', .t. )
      Copy File ( goal_dir + zip_file ) to ( dir_263_to + zip_file )
      If hb_FileExists( dir_263_to + zip_file )
        stat_msg( 'Файл ' + zip_file + ' записан в каталог ' + dir_263_to )
        mybell( 4, OK )
      Else
        func_error( 4, 'Произошла ошибка записи файла ' + zip_file )
      Endif
    Endif
    RestScreen( buf )
  Else
    func_error( 4, 'Не обнаружен файл ' + goal_dir + zip_file )
  Endif
  Return Nil


// 29.12.21 Настройка каталогов обмена - куда записывать созданные для ТФОМС файлы
Function _263_to_nastr()

  Static group_ini := 'OBMEN_263'
  Local ar, sr, mm_tmp := {}

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin() )
  Endif

  Delete file tmp.dbf
  //
  AAdd( mm_tmp, { 'work_otd', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
    'Работаем с отделениями в данной подзадаче?', , ;
    {|| hb_user_curUser:isadmin() } } )
  AAdd( mm_tmp, { 'e_1', 'C', 1, 0, NIL, , '', , ;
    ' ', , ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'e_2', 'C', 1, 0, NIL, , '', , ;
    'Каталоги для обмена информационными пакетами:', , ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'path1', 'C', 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| mng_dir( k, r, c, 'path1_263' ) } }, A__FUNCTION ) }, ;
    ' ', {| x| x }, ;
    '==> для записи пакетов в ТФОМС', , ;
    {|| hb_user_curUser:isadmin() } } )
  AAdd( mm_tmp, { 'path2', 'C', 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| mng_dir( k, r, c, 'path2_263' ) } }, A__FUNCTION ) }, ;
    ' ', {| x| x }, ;
    '==> для чтения пакетов из ТФОМС', , ;
    {|| hb_user_curUser:isadmin() } } )
  AAdd( mm_tmp, { 'path3', 'C', 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| mng_dir( k, r, c, 'path3_263' ) } }, A__FUNCTION ) }, ;
    ' ', {| x| x }, ;
    '==> для перезаписи прочитанных пакетов', , ;
    {|| hb_user_curUser:isadmin() } } )
  init_base( cur_dir() + 'tmp', , mm_tmp, 0 )
  Use ( cur_dir() + 'tmp' ) new
  Append Blank
  ar := getinisect( tmp_ini(), group_ini )
  tmp->path1 := a2default( ar, 'dir_to', '' )
  tmp->path2 := a2default( ar, 'dir_from', '' )
  tmp->path3 := a2default( ar, 'dir_copy', '' )
  ar := getinisect( tools_ini(), group_ini )
  tmp->work_otd := Int( Val( a2default( ar, 'work_otd', lstr( work_otd_263 ) ) ) )
  Close databases
  If f_edit_spr( A__EDIT, mm_tmp, 'настройке каталогов обмена', 'g_use(cur_dir() + "tmp", , , .t., .t.)', 0, 1 ) > 0
    Use ( cur_dir() + 'tmp' ) new
    If Upper( tmp->path1 ) == Upper( tmp->path2 ) .or. ;
        Upper( tmp->path2 ) == Upper( tmp->path3 ) .or. ;
        Upper( tmp->path1 ) == Upper( tmp->path3 )
      func_error( 4, 'Два раза выбран один и тот же каталог - это недопустимо!' )
    Else
      mm_tmp := { ;
        { group_ini, 'dir_to',  tmp->path1 }, ;
        { group_ini, 'dir_from', tmp->path2 }, ;
        { group_ini, 'dir_copy', tmp->path3 } ;
        }
      setinivar( tmp_ini(), mm_tmp )
      work_otd_263 := tmp->work_otd
      dir_263_to   := AllTrim( tmp->path1 )
      dir_263_from := AllTrim( tmp->path2 )
      dir_263_copy := AllTrim( tmp->path3 )
      setinivar( tools_ini(), { { group_ini, 'work_otd', tmp->work_otd } } )
    Endif
  Endif
  Close databases
  Return Nil

// 11.09.25 Получение из ТФОМС файлов обмена (информационных пакетов)
Function _263_from_read()

  Static nerrf := 999
  Local i, j, k, n, s, af := {}, arr_f := {}, aerr := {}, blk := {| x| AAdd( af, x ) }, ii, ;
    name_zip, cName, is_err, buf := save_maxrow(), name_txt, fl, is_read := .f., nerr

  If Empty( dir_263_from )
    Return func_error( 4, 'Не настроен каталог обмена в режиме "Настройка каталогов"' )
  Endif
  If !myfiledeleted( cur_dir() + 'tmp1file' + sdbf() )
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + 'tmp2file' + sdbf() )
    Return Nil
  Endif
  scandirfiles( dir_263_from, '*' + szip(), blk )
  If Empty( af )
    Return func_error( 4, 'Не обнаружено необходимых файлов обмена в каталоге ' + dir_263_from )
  Endif
  If !mo_lock_task( X_263 )
    Return Nil
  Endif
  mywait()
  For i := 1 To Len( af )
    s := strippath( af[ i ] )  // имя файла без пути
    If Left( s, 3 ) == 'RI0'
      AAdd( arr_f, af[ i ] )
    Endif
  Next
  For i := 1 To Len( af )
    s := strippath( af[ i ] )  // имя файла без пути
    If Left( s, 2 ) == 'I0'
      AAdd( arr_f, af[ i ] )
    Endif
  Next
  Private cFileProtokol := cur_dir() + 'tmp.txt', cTimeBegin := hour_min( Seconds() )
  StrFile( Space( 10 ) + 'Протокол чтения информационных пакетов из ТФОМС' + hb_eol(), cFileProtokol )
  StrFile( Space( 10 ) + full_date( sys_date ) + 'г. ' + cTimeBegin + hb_eol(), cFileProtokol, .t. )
  name_txt := DToS( sys_date ) + '_' + CharRem( ':', PadR( SecToTime( Seconds() ), 8 ) ) + stxt()
  //
  g_use( dir_server() + 'mo_kfio', , 'KFIO' )
  Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_kfio' )
  g_use( dir_server() + 'mo_kismo', , 'KSN' )
  Index On Str( kod, 7 ) to ( cur_dir() + 'tmpkismo' )
  use_base( 'kartotek' )
  g_use( dir_server() + 'mo_n7in', , 'N7' )
  Index On Str( kod_f, 6 ) to ( cur_dir() + 'tmp7in' )
  g_use( dir_server() + 'mo_nfina', , 'NFN' )
  g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
  Index On Upper( id_1 ) to ( cur_dir() + 'tmp_napr' )
  g_use( dir_server() + 'mo_nfile', , 'NF' )
  For ii := 1 To Len( arr_f )
    name_zip := strippath( arr_f[ ii ] )  // имя файла без пути
    cName := name_without_ext( name_zip )
    If ( af := extract_zip_xml( keeppath( arr_f[ ii ] ), name_zip ) ) == NIL
      AAdd( aerr, 'Возникла ошибка при разархивировании ' + name_zip )
    Else
      If Len( af ) > 1
        AAdd( aerr, 'В архиве ' + name_zip + ' более одного файла' )
      Elseif ( n := AScan( af, {| x| Upper( name_without_ext( x ) ) == Upper( cName ) } ) ) > 0
        // нормально
      Else
        AAdd( aerr, 'В архиве ' + name_zip + ' нет файла ' + cName + sxml() )
      Endif
    Endif
    If Empty( aerr )
      StrFile( hb_eol() + 'Чтение файла ' + cName + hb_eol(), cFileProtokol, .t. )
      stat_msg( 'Обрабатывается файл ' + cName )
      If Left( cName, 1 ) == 'R' // протокол ответа на наш пакет
        type_paket := Int( Val( SubStr( cName, 4, 1 ) ) )
        Select NF
        Index On Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) For in_out == 1
        find ( PadR( SubStr( Upper( cName ), 2 ), 26 ) ) // поиск нашего первичного пакета
        If Found()
          StrFile( Space( 5 ) + 'обрабатывается ПРОТОКОЛ обработки информационного пакета' + hb_eol() + ;
            Space( 5 ) + AllTrim( nf->NAME_F ) + ' от ' + date_8( nf->DATE_F ) + 'г. (отчётная дата ' + date_8( nf->DATE_R ) + 'г.)' + ;
            hb_eol(), cFileProtokol, .t. )
          If emptyany( nf->d_ans, nf->t_ans ) // если ответа ещё не было
            is_read := .t.
            Select NF
            g_rlock( forever )
            nf->DWORK := sys_date         // дата обработки файла
            nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
            // читаем протокол
            is_err := _263_protokol_tmpfile( af[ 1 ], aerr )
            //
            If tmp1->OSHIB == 0 // файл уже был загружен в ТФОМС
              // ???????????????nf->T_ANS := 2  // тип ответа (2-ошибка)
              AAdd( aerr, 'Файл ' + AllTrim( nf->NAME_F ) + sxml() + ' уже был загружен в ТФОМС (а у нас нет информации об этом)?' )
            Elseif is_err // ошибки
              If tmp1->kol2 == 0
                Select TMP2
                Go Top
                StrFile( Space( 5 ) + 'обнаружена ошибка в файле:' + hb_eol() + ;
                  Space( 5 ) + '- ' + lstr( tmp2->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), tmp2->OSHIB ) + ;
                  hb_eol(), cFileProtokol, .t. )
              Else
                StrFile( Space( 5 ) + 'обнаружены ошибки:' + hb_eol(), cFileProtokol, .t. )
              Endif
              Do Case
              Case nf->TIP_F == 1
                Select NFN
                Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For KOD_F == nf->KOD
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_1out == nf->KOD
                Go Top
                Do While !Eof()
                  nerr := iif( tmp1->kol2 == 0, 2, 1 )
                  If tmp1->kol2 > 0
                    Select TMP2
                    find ( Upper( napr->ID_1 ) )
                    If Found()
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( tmp2->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), tmp2->OSHIB ) + hb_eol() + ;
                        Space( 7 ) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := tmp2->OSHIB
                        nfn->IM_POL := tmp2->IM_POL
                        dbUnlock()
                      Endif
                    Else
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( nerrf ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nerrf )  + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := nerrf
                        dbUnlock()
                      Endif
                    Endif
                  Endif
                  Select NAPR
                  g_rlock( forever )
                  napr->T_ANS_1 := nerr
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 3
                Select NFN
                Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For KOD_F == nf->KOD
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_3out == nf->KOD
                Go Top
                Do While !Eof()
                  nerr := iif( tmp1->kol2 == 0, 2, 1 )
                  If tmp1->kol2 > 0
                    Select TMP2
                    find ( Upper( napr->ID_1 ) )
                    If Found()
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( tmp2->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), tmp2->OSHIB ) + hb_eol() + ;
                        Space( 7 ) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := tmp2->OSHIB
                        nfn->IM_POL := tmp2->IM_POL
                        dbUnlock()
                      Endif
                    Else
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr ( nerrf ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nerrf ) + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := nerrf
                        dbUnlock()
                      Endif
                    Endif
                  Endif
                  Select NAPR
                  g_rlock( forever )
                  napr->T_ANS_3 := nerr
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 4 .or. nf->TIP_F == 5
                Select NFN
                Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For KOD_F == nf->KOD
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_4out == nf->KOD
                Go Top
                Do While !Eof()
                  nerr := iif( tmp1->kol2 == 0, 2, 1 )
                  If tmp1->kol2 > 0
                    Select TMP2
                    find ( Upper( napr->ID_4 ) )
                    If Found()
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( tmp2->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), tmp2->OSHIB ) + hb_eol() + ;
                        Space( 7 ) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := tmp2->OSHIB
                        nfn->IM_POL := tmp2->IM_POL
                        dbUnlock()
                      Endif
                    Else
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date ( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( nerrf ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nerrf ) + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := nerrf
                        dbUnlock()
                      Endif
                    Endif
                  Endif
                  Select NAPR
                  g_rlock( forever )
                  napr->T_ANS_4 := nerr
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 6
                Select NFN
                Index On Str( kod_n, 6 ) to ( cur_dir() + 'tmp_nfn' ) For KOD_F == nf->KOD
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_6out == nf->KOD
                Go Top
                Do While !Eof()
                  nerr := iif( tmp1->kol2 == 0, 2, 1 )
                  If tmp1->kol2 > 0
                    Select TMP2
                    find ( Upper( napr->ID_6 ) )
                    If Found()
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( tmp2->OSHIB ) + ' - ' + inieditspr( A__MENUVERT, gett008(), tmp2->OSHIB ) + hb_eol() + ;
                        Space( 7 ) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := tmp2->OSHIB
                        nfn->IM_POL := tmp2->IM_POL
                        dbUnlock()
                      Endif
                    Else
                      Select KART
                      Goto ( napr->KOD_K )
                      StrFile( Space( 5 ) + '- ' + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + hb_eol() + ;
                        Space( 7 ) + lstr( nerrf ) + ' - ' + inieditspr( A__MENUVERT, gett008(), nerrf ) + hb_eol() + ;
                        hb_eol(), cFileProtokol, .t. )
                      nerr := 2
                      Select NFN
                      find ( Str( napr->kod, 6 ) )
                      If Found()
                        g_rlock( forever )
                        nfn->OSHIB := nerrf
                        dbUnlock()
                      Endif
                    Endif
                  Endif
                  Select NAPR
                  g_rlock( forever )
                  napr->T_ANS_6 := nerr
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 7
              Endcase
              nf->T_ANS := 2  // тип ответа (2-ошибка)
            Else // нет ошибок
              StrFile( Space( 5 ) + 'ошибок не обнаружено' + ;
                hb_eol(), cFileProtokol, .t. )
              Do Case
              Case nf->TIP_F == 1
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_1out == nf->KOD
                Go Top
                Do While !Eof()
                  g_rlock( forever )
                  napr->T_ANS_1 := 1
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 3
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_3out == nf->KOD
                Go Top
                Do While !Eof()
                  g_rlock( forever )
                  napr->T_ANS_3 := 1
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 4 .or. nf->TIP_F == 5
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_4out == nf->KOD
                Go Top
                Do While !Eof()
                  g_rlock( forever )
                  napr->T_ANS_4 := 1
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 6
                Select NAPR
                Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_naprkod' ) For KOD_F_6out == nf->KOD
                Go Top
                Do While !Eof()
                  g_rlock( forever )
                  napr->T_ANS_6 := 1
                  dbUnlock()
                  Skip
                Enddo
              Case nf->TIP_F == 7
                //
              Endcase
              nf->T_ANS := 1  // тип ответа (1-всё хорошо)
            Endif
            nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
            nf->TXT_F := name_txt
            nf->D_ANS := tmp1->DATE_F // дата протокола ответа из ТФОМС
            dbUnlockAll()
            Commit
            tmp2->( dbCloseArea() )
            tmp1->( dbCloseArea() )
          Else
            StrFile( Space( 5 ) + 'данный файл уже был прочитан (дата протокола ответа из ТФОМС ' + date_8( nf->d_ans ) + 'г.)' + hb_eol() + ;
              Space( 5 ) + iif( nf->t_ans == 1, 'ошибок не обнаружено', 'обнаружены ошибки' ) + ;
              hb_eol(), cFileProtokol, .t. )
          Endif
        Elseif type_paket != 7
          StrFile( Space( 5 ) + 'мы не отправляли в ТФОМС пакет ' + SubStr( cName, 2 ) + ;
            hb_eol(), cFileProtokol, .t. )
          If '_' $ cName
            s := Right( BeforAtNum( '_', cName ), 6 )
            If s == glob_mo()[ _MO_KOD_TFOMS ]
              // наше МО
            Elseif ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == s } ) ) > 0
              StrFile( Space( 5 ) + 'это пакет МО "' + glob_arr_mo()[ i, _MO_SHORT_NAME ] + '"' + ;
                hb_eol(), cFileProtokol, .t. )
            Endif
          Endif
        Endif
      Else // полученный файл информационного пакета
        type_paket := Int( Val( SubStr( cName, 3, 1 ) ) )
        Select NF
        Index On Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) For in_out == 2
        find ( PadR( Upper( cName ), 26 ) ) // поиск, м.б. уже читали?
        If Found()
          StrFile( Space( 5 ) + 'данный файл уже был прочитан ' + date_8( nf->DWORK ) + 'г. в ' + nf->TWORK2 + ;
            iif( nf->kol == 0, '', hb_eol() + Space( 5 ) + 'количество пациентов - ' + lstr( nf->kol ) ) + ;
            hb_eol(), cFileProtokol, .t. )
        Else
          s := SubStr( cName, 5, 6 )
          If s == glob_mo()[ _MO_KOD_TFOMS ] // наше МО
            s := BeforAtNum( '_', SubStr( cName, 11 ) )
            If ( c := Left( s, 1 ) ) == 'M'
              sFrom := SubStr( s, 2 )
              If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == sFrom } ) ) > 0
                s := 'от МО "' + glob_arr_mo()[ i, _MO_SHORT_NAME ] + '"'
              Else
                AAdd( aerr, 'Файл ' + cName + sxml() + ' неизвестно от кого (неизвестный код МО ' + sFrom + ')' )
              Endif
            Elseif c == 'S'
              s := SubStr( s, 2 )
              If s == '34007'
                s := 'от АСП ООО "Капитал МС"'
              Elseif s == '34002'
                s := 'от СМО "Согаз"'
              Elseif s == '34001'
                s := 'от СМО "Капитал"'
              Elseif s == '34006'
                s := 'от СМО "Максимус"'
              Else
                AAdd( aerr, 'Файл ' + cName + sxml() + ' от неизвестной СМО (код ' + s + ')' )
              Endif
            Else
              AAdd( aerr, 'Файл ' + cName + sxml() + ' неизвестно от кого' )
            Endif
            If Empty( aerr )
              ar := { 'о выписанных в поликлинике направлениях', ;
                'об установленных стационаром датах плановой госпитализации по направлениям', ;
                'об аннулировании направлений', ;
                'о госпитализациях пациентов по направлениям или в результате перевода', ;
                'о госпитализациях по экстренным или неотложным показаниям (без направлений)', ;
                'о выбывших из стационара пациентах', ;
                'о наличии в стационарах свободных мест' }
              StrFile( Space( 5 ) + 'это информационный пакет со сведениями' + hb_eol() + ;
                Space( 5 ) + ar[ type_paket ] + hb_eol() + ;
                Space( 5 ) + CharOne( '"', s ) + ;
                hb_eol(), cFileProtokol, .t. )
              Do Case
              Case type_paket == 1
                If _263_i01_tmpfile( af[ 1 ], aerr )
                  is_read := .t.
                  Select NAPR
                  Index On num_d to ( cur_dir() + 'tmp_naprnum' )
                  // добавим запись о принимаемом файле
                  Select NF
                  g_rlock( .t., forever ) // бесконечная попытка добавить запись
                  nf->KOD := RecNo()            // код файла
                  nf->DATE_F := tmp1->DATE_F    // дата файла
                  nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                  nf->DATE_R := tmp1->DATE_R    // отчётная дата
                  nf->NN := 0                   // порядковый номер пакета за отчётную дату
                  nf->TIP_F := 1                // от 1 до 7 (пакеты от I01 до I07)
                  nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                  nf->DATE_OUT := CToD( '' )      // дата отправки в ТФОМС
                  nf->KOL := tmp1->kol          // количество пациентов в файле
                  nf->DWORK := sys_date         // дата обработки файла
                  nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
                  nf->TWORK2 := ''              // время окончания обработки
                  nf->TXT_F := name_txt
                  nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
                  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                  //
                  Select TMP2
                  Go Top
                  Do While !Eof()
                    mfio := AllTrim( AllTrim( tmp2->SURNAME ) + ' ' + AllTrim( tmp2->NAME ) + ' ' + AllTrim( tmp2->PATRONYMIC ) )
                    StrFile( Space( 5 ) + '- обрабатывается направление № ' + AllTrim( tmp2->NUM_D ) + ;
                      ' от ' + date_8( tmp2->DATE_D ) + hb_eol() + ;
                      Space( 7 ) + mfio + ' д.р.' + full_date( tmp2->BIRTHDAY ) + hb_eol() + ;
                      Space( 7 ) + 'Условия оказания, в которые направляется пациент: ' + ;
                      iif( tmp2->usl_ok == 2, 'дневной ', '' ) + 'стационар' + hb_eol() + ;
                      Space( 7 ) + 'Направление выдано по результатам диспансеризации/профосмотра взрослых: ' + ;
                      iif( tmp2->disp == 1, 'нет', 'да' ) + hb_eol() + ;
                      Space( 7 ) + 'планируемая дата госпитализации ' + date_8( tmp2->DATE_HOSP ) + ;
                      ' по диагнозу ' + AllTrim( tmp2->DS ) + hb_eol() + ;
                      Space( 7 ) + inieditspr( A__MENUVERT, arr_t007(), tmp2->PROFIL_K ) + ;
                      ' (' + inieditspr( A__MENUVERT, getv002(), tmp2->PROFIL ) + ')' + ;
                      hb_eol(), cFileProtokol, .t. )
                    m1kod_k := 0
                    Select NAPR
                    find ( tmp2->NUM_D )
                    If Found()
                      g_rlock( forever )
                      If napr->KOD_K > 0
                        m1kod_k := napr->KOD_K
                      Endif
                    Else
                      If sFrom == glob_mo()[ _MO_KOD_TFOMS ] // направление из нашей п-ки
                        StrFile( Space( 7 ) + 'это наше направление - почему-то не найдено в отправленных - добавляем' + ;
                          hb_eol(), cFileProtokol, .t. )
                      Endif
                      g_rlock( .t., forever ) // бесконечная попытка добавить запись
                      napr->KOD := RecNo() // код направления - номер записи
                      napr->NUM_D := tmp2->NUM_D
                      napr->DATE_D := tmp2->DATE_D
                    Endif
                    // добавим запись в картотеке (или перезапишем)
                    m1kod_k := _263_add_kart( m1kod_k, mfio, cFileProtokol )
                    //
                    napr->KOD_K := m1kod_k // код по картотеке
                    napr->MCOD_1 := tmp2->MO // код поликлиники
                    napr->CODEM_1 := tmp2->LPU // код поликлиники
                    napr->DS_1 := tmp2->DS // диагноз поликлиники
                    napr->usl_ok_1 := tmp2->usl_ok
                    napr->disp_1 := tmp2->disp
                    napr->F_MEDC_1 := tmp2->F_MEDC // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
                    napr->ID_1 := tmp2->ID_D // GUID30+lstr(mo_nnapr->KOD) ID направления
                    napr->DATE_H_1 := tmp2->DATE_HOSP // планируемая дата госпитализации
                    napr->PROFIL_K_1 := tmp2->PROFIL_K // профиль койки по справочнику T007
                    napr->PROFIL_1 := tmp2->PROFIL // профиль мед.помощи по справочнику V002
                    // napr->VRACH_1 := ??IDDOKT // лечащий врач по mo_pers
                    napr->S_MCOD := tmp2->MO_H // код стационара
                    napr->S_CODEM := tmp2->LPU_H // _код стационара
                    napr->KOD_F_1in := nf->KOD // код файла - по файлу mo_nfile
                    If Empty( napr->KOD_F_1out )
                      napr->KOD_F_1out := -99 // не наш
                    Endif
                    //
                    Select TMP2
                    Skip
                  Enddo
                  nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
                  chip_copy_zipxml( arr_f[ ii ], dir_server() + dir_NAPR_TF() )
                Endif
              Case type_paket == 3
                If _263_i03_tmpfile( af[ 1 ], aerr )
                  is_read := .t.
                  Select NAPR
                  Set Index to ( cur_dir() + 'tmp_napr' )
                  // добавим запись о принимаемом файле
                  Select NF
                  g_rlock( .t., forever ) // бесконечная попытка добавить запись
                  nf->KOD := RecNo()            // код файла
                  nf->DATE_F := tmp1->DATE_F    // дата файла
                  nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                  nf->DATE_R := tmp1->DATE_R    // отчётная дата
                  nf->NN := 0                   // порядковый номер пакета за отчётную дату
                  nf->TIP_F := 3                // от 1 до 7 (пакеты от I01 до I07)
                  nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                  nf->DATE_OUT := CToD( '' )      // дата отправки в ТФОМС
                  nf->KOL := tmp1->kol          // количество пациентов в файле
                  nf->DWORK := sys_date         // дата обработки файла
                  nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
                  nf->TWORK2 := ''              // время окончания обработки
                  nf->TXT_F := name_txt
                  nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
                  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                  //
                  Select TMP2
                  Go Top
                  Do While !Eof()
                    Select NAPR
                    find ( Upper( tmp2->ID_D ) )
                    If Found()
                      g_rlock( forever )
                      kart->( dbGoto( napr->KOD_K ) )
                      mfio := AllTrim( kart->fio )
                      //
                      s := Space( 5 ) + '- обрабатывается направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) + hb_eol() + ;
                        Space( 7 ) + mfio + ' д.р.' + full_date( kart->date_r ) + hb_eol() + ;
                        Space( 7 ) + 'планируемая дата госпитализации (п-ка) - ' + full_date( napr->DATE_H_1 ) + hb_eol()
                        /*if !empty(napr->DATE_H_2)
                          s+=space(7) + 'планируемая дата госпитализации (стац) - ' + full_date(napr->DATE_H_2) + hb_eol() + ;
                             space(7) + '(дата госпитализации введена в стационаре - ' + full_date(napr->DATE_2) + ')' + hb_eol()
                        endif*/
                      s += Space( 7 ) + 'причина аннулирования: ' + inieditspr( A__MENUVERT, get_reason_annul(), tmp2->REASON_REF ) + hb_eol() + ;
                        Space( 7 ) + 'дата аннулирования ' + full_date( tmp2->DATE_REF ) + hb_eol()
                      If Empty( napr->DATE_3 )
                        napr->DATE_3 := tmp2->DATE_REF // дата аннулирования
                        napr->TIP_ANNUL := tmp2->TYPE_S  // где ануллировано
                        napr->rea_annul := tmp2->REASON_REF // причина аннулирования
                      Elseif !( napr->DATE_3    == tmp2->DATE_REF .and. ;
                          napr->TIP_ANNUL == tmp2->TYPE_S   .and. ;
                          napr->rea_annul == tmp2->REASON_REF )
                        s += Space( 8 ) + 'у нас УЖЕ ЗАНЕСЕНО аннулирование в '
                        If napr->TIP_ANNUL == 1
                          s += 'СМО'
                        Elseif napr->TIP_ANNUL == 2
                          s += 'стационаре'
                        Else
                          s += 'поликлинике'
                        Endif
                        s += hb_eol()
                        s += Space( 8 ) + 'причина аннулирования: ' + inieditspr( A__MENUVERT, get_reason_annul(), napr->rea_annul ) + hb_eol() + ;
                          Space( 8 ) + 'дата аннулирования ' + full_date( napr->date_3 ) + hb_eol()
                      Endif
                      If Empty( napr->KOD_F_3in )
                        napr->KOD_F_3in := nf->KOD // код файла - по файлу mo_nfile
                      Endif
                      If Empty( napr->KOD_F_3out )
                        napr->KOD_F_3out := -99 // не наш
                      Endif
                      StrFile( s + hb_eol(), cFileProtokol, .t. )
                    Else
                      StrFile( Space( 5 ) + '- не найдено направление с ID_D=' + AllTrim( tmp2->ID_D ) + ;
                        hb_eol(), cFileProtokol, .t. )
                    Endif
                    //
                    Select TMP2
                    Skip
                  Enddo
                  nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
                  chip_copy_zipxml( arr_f[ ii ], dir_server() + dir_NAPR_TF() )
                Endif
              Case type_paket == 4 .or. type_paket == 5
                If _263_i04_tmpfile( af[ 1 ], aerr )
                  is_read := .t.
                  Select NAPR
                  Index On Upper( id_4 ) to ( cur_dir() + 'tmp_naprid4' )
                  If !( sFrom == glob_mo()[ _MO_KOD_TFOMS ] ) .and. is_napr_pol()
                    Index On Upper( id_1 ) to ( cur_dir() + 'tmp_naprid1' )
                    Set Index to ( cur_dir() + 'tmp_naprid4' ), ( cur_dir() + 'tmp_naprid1' )
                  Endif
                  // добавим запись о принимаемом файле
                  Select NF
                  g_rlock( .t., forever ) // бесконечная попытка добавить запись
                  nf->KOD := RecNo()            // код файла
                  nf->DATE_F := tmp1->DATE_F    // дата файла
                  nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                  nf->DATE_R := tmp1->DATE_R    // отчётная дата
                  nf->NN := 0                   // порядковый номер пакета за отчётную дату
                  nf->TIP_F := type_paket       // от 1 до 7 (пакеты от I01 до I07)
                  nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                  nf->DATE_OUT := CToD( '' )      // дата отправки в ТФОМС
                  nf->KOL := tmp1->kol          // количество пациентов в файле
                  nf->DWORK := sys_date         // дата обработки файла
                  nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
                  nf->TWORK2 := ''              // время окончания обработки
                  nf->TXT_F := name_txt
                  nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
                  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                  //
                  Select TMP2
                  Go Top
                  Do While !Eof()
                    mfio := AllTrim( AllTrim( tmp2->SURNAME ) + ' ' + AllTrim( tmp2->NAME ) + ' ' + AllTrim( tmp2->PATRONYMIC ) )
                    s := '- обрабатывается госпитализация '
                    s1 := iif( Empty( tmp2->LPU_D ) .or. tmp2->TYPE_H == 3, '', 'из ' + ret_mo( tmp2->LPU_D )[ _MO_SHORT_NAME ] )
                    Do Case
                    Case tmp2->TYPE_H == 1
                      s += 'по направлению'
                    Case tmp2->TYPE_H == 2
                      s += 'переводом из другого стационара'
                    Case tmp2->TYPE_H == 3
                      s += 'переводом внутри нашего МО'
                    Case tmp2->TYPE_H == 4
                      s += 'по неотложным или экстренным показаниям'
                    Endcase
                    StrFile( Space( 5 ) + s + hb_eol() + ;
                      iif( Empty( s1 ), '', Space( 7 ) + s1 + hb_eol() ) + ;
                      Space( 7 ) + mfio + ' д.р.' + full_date( tmp2->BIRTHDAY ) + hb_eol() + ;
                      Space( 7 ) + 'условия оказания медицинской помощи: ' + ;
                      iif( tmp2->usl_ok == 2, 'дневной ', '' ) + 'стационар' + hb_eol(), cFileProtokol, .t. )
                    If sFrom == glob_mo()[ _MO_KOD_TFOMS ] // если пациент лёг в наш стационар
                      Select NAPR
                      find ( Upper( tmp2->ID_H ) ) // ищем GUID госпитализации
                      If Found()
                        If tmp2->TYPE_H == 1 .and. !Empty( napr->NUM_D )
                          StrFile( Space( 7 ) + 'направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                        g_rlock( forever )
                        napr->KOD_F_4in := nf->KOD // код файла - по файлу mo_nfile
                        Unlock
                      Else
                        StrFile( Space( 7 ) + 'это наша госпитализация - почему-то не найдена в отправленных ?' + ;
                          hb_eol(), cFileProtokol, .t. )
                      Endif
                    Else // из другого стационара к нам в п-ку пришло уведомление
                      If tmp2->TYPE_H == 1 .and. !Empty( tmp2->ID_D )
                        Select NAPR
                        Set Order To 2
                        find ( Upper( tmp2->ID_D ) )
                        If Found()
                          If tmp2->TYPE_H == 1 .and. !Empty( napr->NUM_D )
                            StrFile( Space( 7 ) + 'направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) + ;
                              hb_eol(), cFileProtokol, .t. )
                          Endif
                          g_rlock( forever )
                          napr->CODEM_FROM := iif( Empty( tmp2->LPU_D ), glob_mo()[ _MO_KOD_TFOMS ], tmp2->LPU_D )
                          napr->TYPE_H_4 := tmp2->TYPE_H
                          napr->ID_4 := tmp2->ID_H
                          napr->KOD_UP := 0
                          napr->KOD_PP := 0
                          napr->DS_4 := tmp2->ds // диагноз приёмного отделения
                          napr->F_MEDC_4 := tmp2->F_MEDC // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
                          napr->DATE_H_4 := tmp2->DATE_H // дата госпитализации
                          napr->TIME_H_4 := tmp2->TIME_H // время госпитализации
                          napr->PROFIL_K_4 := tmp2->PROFIL_K // профиль койки по справочнику T007
                          napr->PROFIL_4 := tmp2->PROFIL // профиль мед.помощи по справочнику V002
                          napr->NUM_HIST_4 := tmp2->NUM_HIST
                          napr->KOD_F_4in := nf->KOD // код файла - по файлу mo_nfile
                          If Empty( napr->KOD_F_4out )
                            napr->KOD_F_4out := -99 // не наша госпитализация
                          Endif
                          Unlock
                        Else
                          StrFile( Space( 7 ) + 'это наше направление - почему-то не найдено в отправленных ?' + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                        Set Order To 1
                      Elseif Empty( tmp2->BIRTHDAY ) // нет даты рождения
                        StrFile( Space( 7 ) + 'нет даты рождения, поэтому не добавляем к себе в базу данных' + ;
                          hb_eol(), cFileProtokol, .t. )
                      Else
                        If ( m1kod_k := _263_add_kart( 0, mfio, cFileProtokol, .f. ) ) > 0
                          // добавим запись в картотеке (или перезапишем)
                          Select NAPR
                          g_rlock( .t., forever ) // бесконечная попытка добавить запись
                          napr->KOD := RecNo() // код направления - номер записи
                          //
                          napr->KOD_K := m1kod_k // код по картотеке
                          napr->CODEM_FROM := tmp2->LPU_D
                          napr->TYPE_H_4 := tmp2->TYPE_H
                          napr->ID_4 := tmp2->ID_H
                          napr->KOD_UP := 0
                          napr->KOD_PP := 0
                          napr->usl_ok_4 := tmp2->usl_ok
                          napr->DS_4 := tmp2->ds // диагноз приёмного отделения
                          napr->F_MEDC_4 := tmp2->F_MEDC // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
                          napr->DATE_H_4 := tmp2->DATE_H // дата госпитализации
                          napr->TIME_H_4 := tmp2->TIME_H // время госпитализации
                          napr->PROFIL_K_4 := tmp2->PROFIL_K // профиль койки по справочнику T007
                          napr->PROFIL_4 := tmp2->PROFIL // профиль мед.помощи по справочнику V002
                          napr->NUM_HIST_4 := tmp2->NUM_HIST
                          napr->S_MCOD := tmp2->MO // код стационара
                          napr->S_CODEM := tmp2->LPU // _код стационара
                          napr->KOD_F_4in := nf->KOD // код файла - по файлу mo_nfile
                          If Empty( napr->KOD_F_4out )
                            napr->KOD_F_4out := -99 // не наша госпитализация
                          Endif
                          //
                          napr->DATE_R := tmp2->BIRTHDAY
                          napr->SEX    := tmp2->SEX
                          napr->ENP    := tmp2->ENP
                          Unlock
                        Else
                          StrFile( Space( 7 ) + 'по ФИО и дате рождения пациент не найден в нашей картотеке - не добавляем' + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                      Endif
                    Endif
                    //
                    Select TMP2
                    Skip
                  Enddo
                  nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
                  chip_copy_zipxml( arr_f[ ii ], dir_server() + dir_NAPR_TF() )
                Endif
              Case type_paket == 6
                If _263_i06_tmpfile( af[ 1 ], aerr )
                  is_read := .t.
                  Select NAPR
                  Index On Upper( id_6 ) to ( cur_dir() + 'tmp_naprid6' )
                  If !( sFrom == glob_mo()[ _MO_KOD_TFOMS ] ) .and. is_napr_pol()
                    Index On Upper( id_1 ) to ( cur_dir() + 'tmp_naprid1' )
                    Index On DToS( DATE_H_4 ) to ( cur_dir() + 'tmp_naprd4' )
                    Set Index to ( cur_dir() + 'tmp_naprid6' ), ( cur_dir() + 'tmp_naprid1' ), ( cur_dir() + 'tmp_naprd4' )
                  Endif
                  // добавим запись о принимаемом файле
                  Select NF
                  g_rlock( .t., forever ) // бесконечная попытка добавить запись
                  nf->KOD := RecNo()            // код файла
                  nf->DATE_F := tmp1->DATE_F    // дата файла
                  nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                  nf->DATE_R := tmp1->DATE_R    // отчётная дата
                  nf->NN := 0                   // порядковый номер пакета за отчётную дату
                  nf->TIP_F := 6                // от 1 до 7 (пакеты от I01 до I07)
                  nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                  nf->DATE_OUT := CToD( '' )      // дата отправки в ТФОМС
                  nf->KOL := tmp1->kol          // количество пациентов в файле
                  nf->DWORK := sys_date         // дата обработки файла
                  nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
                  nf->TWORK2 := ''              // время окончания обработки
                  nf->TXT_F := name_txt
                  nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
                  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                  //
                  Select TMP2
                  Go Top
                  Do While !Eof()
                    StrFile( Space( 5 ) + '- обрабатывается выбытие из стационара' + hb_eol() + ;
                      Space( 7 ) + 'госпитализация - ' + date_8( tmp2->DATE_H ) + ', выбытие ' + date_8( tmp2->DATE_D ) + hb_eol() + ;
                      Space( 7 ) + iif( tmp2->SEX == 1, 'мужчина', 'женщина' ) + ' д.р.' + full_date( tmp2->BIRTHDAY ) + ;
                      iif( Empty( tmp2->ENP ), '', ' полис ' + tmp2->ENP ) + hb_eol() + ;
                      Space( 7 ) + 'условия оказания медицинской помощи: ' + ;
                      iif( tmp2->usl_ok == 2, 'дневной ', '' ) + 'стационар' + hb_eol(), cFileProtokol, .t. )
                    If sFrom == glob_mo()[ _MO_KOD_TFOMS ] // если пациент лежал в нашем стационар
                      Select NAPR
                      Set Order To 1
                      find ( Upper( tmp2->ID_DISCH ) ) // ищем GUID выбытия
                      If Found()
                        If napr->kod_k > 0
                          kart->( dbGoto( napr->kod_k ) )
                          StrFile( Space( 7 ) + kart->fio + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                        If !Empty( napr->NUM_D )
                          StrFile( Space( 7 ) + 'направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                        g_rlock( forever )
                        napr->KOD_F_6in := nf->KOD // код файла - по файлу mo_nfile
                        If Empty( napr->KOD_F_6out )
                          napr->KOD_F_6out := -99 // не наш
                        Endif
                        Unlock
                      Else
                        StrFile( Space( 7 ) + 'это наша госпитализация/выбытие - почему-то не найдена в отправленных ?' + ;
                          hb_eol(), cFileProtokol, .t. )
                      Endif
                    Else // из другого стационара к нам в п-ку пришло уведомление
                      If !Empty( tmp2->ID_D )
                        Select NAPR
                        Set Order To 2
                        find ( Upper( tmp2->ID_D ) )
                        If Found()
                          If napr->kod_k > 0
                            kart->( dbGoto( napr->kod_k ) )
                            StrFile( Space( 7 ) + kart->fio + ;
                              hb_eol(), cFileProtokol, .t. )
                          Endif
                          If !Empty( napr->NUM_D )
                            StrFile( Space( 7 ) + 'направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) + ;
                              hb_eol(), cFileProtokol, .t. )
                          Endif
                          g_rlock( forever )
                          napr->DATE_6 := tmp2->DATE_D // дата выписки
                          napr->KOD_F_6in := nf->KOD // код файла - по файлу mo_nfile
                          If Empty( napr->KOD_F_6out )
                            napr->KOD_F_6out := -99 // не наш
                          Endif
                          Unlock
                        Else
                          StrFile( Space( 7 ) + 'это наше направление - почему-то не найдено в отправленных ?' + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                      Else
                        fl := .f.
                        Select NAPR
                        Set Order To 3
                        find ( DToS( tmp2->DATE_H ) )
                        Do While tmp2->DATE_H == napr->DATE_H_4 .and. !Eof()
                          If napr->kod_k > 0
                            kart->( dbGoto( napr->kod_k ) )
                            If tmp2->BIRTHDAY == iif( Empty( napr->DATE_R ), kart->DATE_R, napr->DATE_R )
                              If Upper( tmp2->NUM_HIST ) == Upper( napr->NUM_HIST_4 )
                                fl := .t.
                                StrFile( Space( 7 ) + kart->fio + ;
                                  hb_eol(), cFileProtokol, .t. )
                                Select NAPR
                                g_rlock( forever )
                                napr->DATE_6 := tmp2->DATE_D // дата выписки
                                napr->KOD_F_6in := nf->KOD   // код файла - по файлу mo_nfile
                                If Empty( napr->KOD_F_6out )
                                  napr->KOD_F_6out := -99 // не наш
                                Endif
                                Unlock
                                Exit
                              Endif
                            Endif
                          Endif
                          Select NAPR
                          Skip
                        Enddo
                        If !fl
                          StrFile( Space( 7 ) + 'данная госпитализация не найдена в нашей базе данных ?' + ;
                            hb_eol(), cFileProtokol, .t. )
                        Endif
                      Endif
                    Endif
                    //
                    Select TMP2
                    Skip
                  Enddo
                  nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
                  chip_copy_zipxml( arr_f[ ii ], dir_server() + dir_NAPR_TF() )
                Endif
              Case type_paket == 7
                fl := .t.
                luch := BeforAtNum( '_', cName )
                ldate := SToD( '20' + Left( AfterAtNum( '_', cName ), 6 ) )
                lrec_nf := 0
                Select NF
                // index on upper(name_f) to tmp_nf for in_out == 2
                find ( Upper( luch ) ) // м.б. уже читали I07 от данного МО?
                If Found()
                  lrec_nf := nf->kod
                  If nf->DATE_R > ldate
                    fl := .f.
                    StrFile( Space( 5 ) + 'у нас уже прочитан более поздний файл от ' + date_8( nf->DATE_R ) + ;
                      hb_eol(), cFileProtokol, .t. )
                  Endif
                Endif
                If fl .and. _263_i07_tmpfile( af[ 1 ], aerr )
                  // добавим запись о принимаемом файле
                  is_read := .t.
                  Select NF
                  If lrec_nf == 0
                    g_rlock( .t., forever ) // бесконечная попытка добавить запись
                    nf->KOD := RecNo()            // код файла
                    lrec_nf := nf->KOD
                  Else
                    Goto ( lrec_nf )
                    g_rlock( forever ) // бесконечная попытка блокировать запись
                  Endif
                  nf->DATE_F := tmp1->DATE_F    // дата файла
                  nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                  nf->DATE_R := tmp1->DATE_R    // отчётная дата
                  nf->NN := 0                   // порядковый номер пакета за отчётную дату
                  nf->TIP_F := 7                // от 1 до 7 (пакеты от I01 до I07)
                  nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                  nf->DATE_OUT := CToD( '' )      // дата отправки в ТФОМС
                  nf->KOL := tmp1->kol          // количество
                  nf->DWORK := sys_date         // дата обработки файла
                  nf->TWORK1 := hour_min( Seconds() ) // время начала обработки
                  nf->TWORK2 := ''              // время окончания обработки
                  nf->TXT_F := name_txt
                  nf->D_ANS := CToD( '' )         // дата протокола ответа из ТФОМС
                  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                  //
                  If lrec_nf > 0
                    Select N7
                    Do While !Eof()
                      find ( Str( lrec_nf, 6 ) )
                      If !Found()
                        Exit
                      Endif
                      deleterec( .t. )
                    Enddo
                  Endif
                  Select TMP2
                  Go Top
                  Do While !Eof()
                    Select N7
                    addrec( 6 )
                    n7->KOD_F      := nf->KOD          // код файла - по файлу mo_nfile
                    n7->CODEM      := tmp2->LPU        // код стационара
                    n7->ID_PL      := tmp2->ID_PL      // GUID записи
                    n7->USL_OK     := tmp2->USL_OK     //
                    n7->PROFIL_K   := tmp2->PROFIL_K   // профиль койки
                    n7->PROFIL     := tmp2->PROFIL     // профиль мед.помощи
                    n7->QUANTITY   := tmp2->QUANTITY   // количество коек
                    n7->Q_P        := tmp2->Q_P        // состояло пациентов на начало пред.суток
                    n7->Q_AP       := tmp2->Q_AP       // поступило пациентов за пред.сутки
                    n7->Q_DP       := tmp2->Q_DP       // выбыло пациентов за пред.сутки
                    n7->Q_HP       := tmp2->Q_HP       // запланировано госпитализаций на тек.день
                    n7->PLACE_FREE := tmp2->PLACE_FREE // количество свободных мест
                    n7->PF_M       := tmp2->PF_M       // --''-- для мужчин
                    n7->PF_W       := tmp2->PF_W       // --''-- для женщин
                    n7->PF_C       := tmp2->PF_C       // --''-- для детей
                    n7->PLACE1     := tmp2->PLACE1     // количество свободных мест
                    n7->PF_M1      := tmp2->PF_M1      // --''-- для мужчин
                    n7->PF_W1      := tmp2->PF_W1      // --''-- для женщин
                    n7->PF_C1      := tmp2->PF_C1      // --''-- для детей
                    n7->PLACE2     := tmp2->PLACE2     // количество свободных мест
                    n7->PF_M2      := tmp2->PF_M2      // --''-- для мужчин
                    n7->PF_W2      := tmp2->PF_W2      // --''-- для женщин
                    n7->PF_C2      := tmp2->PF_C2      // --''-- для детей
                    n7->PLACE3     := tmp2->PLACE3     // количество свободных мест
                    n7->PF_M3      := tmp2->PF_M3      // --''-- для мужчин
                    n7->PF_W3      := tmp2->PF_W3      // --''-- для женщин
                    n7->PF_C3      := tmp2->PF_C3      // --''-- для детей
                    n7->PLACE4     := tmp2->PLACE4     // количество свободных мест
                    n7->PF_M4      := tmp2->PF_M4      // --''-- для мужчин
                    n7->PF_W4      := tmp2->PF_W4      // --''-- для женщин
                    n7->PF_C4      := tmp2->PF_C4      // --''-- для детей
                    n7->PLACE5     := tmp2->PLACE5     // количество свободных мест
                    n7->PF_M5      := tmp2->PF_M5      // --''-- для мужчин
                    n7->PF_W5      := tmp2->PF_W5      // --''-- для женщин
                    n7->PF_C5      := tmp2->PF_C5      // --''-- для детей
                    n7->PLACE6     := tmp2->PLACE6     // количество свободных мест
                    n7->PF_M6      := tmp2->PF_M6      // --''-- для мужчин
                    n7->PF_W6      := tmp2->PF_W6      // --''-- для женщин
                    n7->PF_C6      := tmp2->PF_C6      // --''-- для детей
                    n7->PLACE7     := tmp2->PLACE7     // количество свободных мест
                    n7->PF_M7      := tmp2->PF_M7      // --''-- для мужчин
                    n7->PF_W7      := tmp2->PF_W7      // --''-- для женщин
                    n7->PF_C7      := tmp2->PF_C7      // --''-- для детей
                    n7->PLACE8     := tmp2->PLACE8     // количество свободных мест
                    n7->PF_M8      := tmp2->PF_M8      // --''-- для мужчин
                    n7->PF_W8      := tmp2->PF_W8      // --''-- для женщин
                    n7->PF_C8      := tmp2->PF_C8      // --''-- для детей
                    n7->PLACE9     := tmp2->PLACE9     // количество свободных мест
                    n7->PF_M9      := tmp2->PF_M9      // --''-- для мужчин
                    n7->PF_W9      := tmp2->PF_W9      // --''-- для женщин
                    n7->PF_C9      := tmp2->PF_C9      // --''-- для детей
                    n7->PLACE10    := tmp2->PLACE10    // количество свободных мест
                    n7->PF_M10     := tmp2->PF_M10     // --''-- для мужчин
                    n7->PF_W10     := tmp2->PF_W10     // --''-- для женщин
                    n7->PF_C10     := tmp2->PF_C10     // --''-- для детей
                    n7->V_H34001   := tmp2->V_H34001   // количество госпитализаций реабилитаций СНГ
                    n7->V_H34002   := tmp2->V_H34002   // количество госпитализаций реабилитаций СНГ
                    n7->V_H34006   := tmp2->V_H34006   // количество госпитализаций реабилитаций СНГ
                    n7->V_H34007   := tmp2->V_H34007   // количество госпитализаций реабилитаций СНГ
                    Select TMP2
                    Skip
                  Enddo
                  nf->TWORK2 := hour_min( Seconds() ) // время окончания обработки
                  // chip_copy_zipXML(arr_f[ii], dir_server() + dir_NAPR_TF())
                Endif
              Endcase
              dbUnlockAll()
              Commit
              If Select( 'TMP2' ) != 0
                tmp2->( dbCloseArea() )
              Endif
              If Select( 'TMP1' ) != 0
                tmp1->( dbCloseArea() )
              Endif
            Endif
          Elseif ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == s } ) ) > 0
            StrFile( Space( 5 ) + 'это пакет не для нас, а для МО "' + glob_arr_mo()[ i, _MO_SHORT_NAME ] + '"' + ;
              hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
      Endif
    Endif
    If !Empty( aerr )
      Exit
    Endif
  Next ii
  Close databases
  rest_box( buf )
  If Empty( aerr )
    If is_read
      Copy File ( cFileProtokol ) to ( name_txt )
      // запишем файл протокола обработки
      chip_copy_zipxml( name_txt, dir_server() + dir_NAPR_TF(), .t. )
    Endif
    If !Empty( dir_263_copy )
      StrFile( hb_eol() + 'Перезапись прочитанных файлов в каталог ' + dir_263_copy + hb_eol() + ;
        'и удаление прочитанных файлов из каталога ' + dir_263_from + ;
        hb_eol(), cFileProtokol, .t. )
      For ii := 1 To Len( arr_f )
        name_zip := strippath( arr_f[ ii ] )  // имя файла без пути
        Copy File ( arr_f[ ii ] ) to ( dir_263_copy + name_zip )
        Delete File ( arr_f[ ii ] )
        StrFile( '- ' + name_zip + ' переписан' + ;
          hb_eol(), cFileProtokol, .t. )
      Next ii
    Endif
  Else
    AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
  Endif
  viewtext( devide_into_pages( cFileProtokol, 60, 80 ), , , , .t., , , 2 )
  Delete File ( cFileProtokol )
  mo_unlock_task( X_263 )
  Return Nil

// 22.07.14 Просмотр протоколов чтения информационных пакетов из ТФОМС
Function _263_from_protokol()

  Local i, d, s, blk, t_arr[ BR_LEN ], buf := save_maxrow()

  mywait()
  dbCreate( cur_dir() + 'tmp', { { 'named', 'D', 8, 0 }, ;
    { 'namet', 'C', 9, 0 }, ;
    { 'txt_f', 'C', 15, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  blk := {| x| s := name_without_ext( strippath( x ) ), ;
    dbAppend(), ;
    tmp->named := SToD( Left( s, 8 ) ), ;
    tmp->namet := Left( Right( s, 6 ), 2 ) + ':' + Left( Right( s, 4 ), 2 ) + ':' + Right( s, 2 ), ;
    tmp->txt_f := s }
  scandirfiles( dir_server() + dir_NAPR_TF() + hb_ps(), '*' + stxt(), blk )
  If LastRec() == 0
    Close databases
    rest_box( buf )
    Return func_error( 4, 'Пока ещё не читали информационные пакеты из ТФОМС' )
  Endif
  Index On Descend( txt_f ) to ( cur_dir() + 'tmp' )
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL -5
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 23
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  blk := nil
  t_arr[ BR_COLUMN ] := { { '   Дата', {|| full_date( tmp->named ) }, blk }, ;
    { ' Время', {|| tmp->namet }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - просмотр файла протокола чтения' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_from_protokol( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  rest_box( buf )
  Return Nil

// 22.07.14
Function f2_263_from_protokol( nKey, oBrow, regim )

  Local ret := -1

  Do Case
  Case regim == 'edit'
    If nKey == K_ENTER
      viewtext( devide_into_pages( dir_server() + dir_NAPR_TF() + hb_ps() + tmp->txt_f + stxt(), 60, 80 ), , , , .t., , , 2 )
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

// 10.09.25 Список информационных пакетов с полученными направлениями от поликлиник
Function _263_from_i01()

  Static str_sem := '263_from_I01'
  Local buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  g_use( dir_server() + 'mo_nfile', , 'NF' )
  Index On DToS( date_r ) + Upper( name_f ) to ( cur_dir() + 'tmp_nf' ) ;
    For in_out == 2 .and. tip_f == 1 DESCENDING
  Go Top
  If Eof()
    Close databases
    g_sunlock( str_sem )
    Return func_error( 4, 'Пока не было чтения информационных пакетов I01 из ТФОМС' )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -5
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := 'Информационные пакеты I01, полученные из ТФОМС'
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, R/BG, W+/R', .t. }
  blk := {|| iif( Empty( nf->TWORK2 ), { 5, 6 }, ;
    iif( SubStr( nf->name_f, 12, 6 ) == glob_mo()[ _MO_KOD_TFOMS ], { 3, 4 }, { 1, 2 } ) ) }
  t_arr[ BR_COLUMN ] := { { ' Имя файла', {|| nf->name_f }, blk }, ;
    { ' Отч.дата', {|| full_date( nf->date_r ) }, blk }, ;
    { ' Кол.', {|| Str( nf->kol, 5 ) }, blk }, ;
    { 'Дата и время чтения', {|| PadR( f1_263_from_i01( 3 ), 34 ) }, blk } }
  t_arr[ BR_STEP_FUNC ] := {|| f1_263_from_i01( 1 ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход  ^<Enter>^ просмотр' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_263_from_i01( nk, ob, 'edit' ) }
  f1_263_from_i01( 0 )
  edit_browse( t_arr )
  f1_263_from_i01( 2 )
  Close databases
  g_sunlock( str_sem )
  rest_box( buf )
  Return Nil

// 26.08.14
Function f1_263_from_i01( k )

  Static buf
  Local ta[ 2 ], k1, k2

  If k == 0
    buf := box_shadow( MaxRow() -4, 0, MaxRow() -1, 79, color1, 'Полное наименование направившей поликлиники', 'B+/B' )
  Elseif k == 1
    perenos( ta, ret_mo( SubStr( nf->name_f, 12, 6 ) )[ _MO_FULL_NAME ], 78 )
    @ MaxRow() -3, 1 Say PadC( AllTrim( ta[ 1 ] ), 78 ) Color color14
    @ MaxRow() -2, 1 Say PadC( AllTrim( ta[ 2 ] ), 78 ) Color color14
  Elseif k == 2
    rest_box( buf )
  Elseif k == 3
    Return date_8( nf->dwork ) + ' ' + nf->twork1 + iif( Empty( nf->TWORK2 ), ' ЧТЕНИЕ НЕ ЗАВЕРШЕНО', '' )
  Endif
  Return Nil

// 04.06.23
Function f2_263_from_i01( nKey, oBrow, regim )

  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, ;
    n_file := cur_dir() + 'i01.txt', sh := 80, HH := 60, t_arr[ 4 ], s1, s2, s3, s4

  If regim == 'edit'
    Do Case
    Case nKey == K_CTRL_F12
      If Empty( nf->TWORK2 )
        buf := SaveScreen()
        arr := {}
        AAdd( arr, 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
        AAdd( arr, 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
        AAdd( arr, '' )
        AAdd( arr, 'Аннулируется НЕДОЧИТАННЫЙ информационный пакет I01' )
        AAdd( arr, '' )
        AAdd( arr, 'После подтверждения аннулирования все последствия чтения данного' )
        AAdd( arr, 'файла, а также сам файл, будут удалены.' )
        f_message( arr, , cColorSt2Msg, cColorSt1Msg )
        s := 'Подтвердите аннулирование информационного пакета I01'
        stat_msg( s ) ; mybell( 1 )
        If f_esc_enter( 'аннулирования', .t. )
          mywait()
          g_use( dir_server() + 'mo_nnapr', , 'NAPR' )
          Index On kod to ( cur_dir() + 'tmp_napr' ) For KOD_F_1in == nf->kod
          arr := {}
          dbEval( {|| AAdd( arr, napr->( RecNo() ) ) } )
          Set Index To
          For i := 1 To Len( arr )
            If napr->CODEM_1 == napr->S_CODEM // код поликлиники == код стационара
              g_rlock( forever )
              napr->KOD_F_1in := 0 // код файла - по файлу mo_nfile
            Else
              deleterec( .t. )
            Endif
          Next
          napr->( dbCloseArea() )
          Select NF
          deleterec()
          stat_msg( 'Аннулирование завершено! Можете прочитать файл снова' )
          mybell( 2 )
          Go Top
          ret := 1
        Endif
        RestScreen( buf )
      Else
        func_error( 4, 'Данный файл был успешно прочитан. Аннулирование запрещено!' )
      Endif
    Case nKey == K_ENTER
      buf := save_maxrow()
      mywait()
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( 'Файл ' + AllTrim( nf->name_f ) + ', отчётная дата ' + full_date( nf->date_r ) + 'г.' )
      add_string( 'количество пациентов ' + lstr( nf->kol ) + ' чел.' )
      add_string( '' )
      add_string( 'Это информационный пакет со сведениями о выписанных в поликлинике направлениях' )
      add_string( 'от МО ' + CharOne( '"', ret_mo( SubStr( nf->name_f, 12, 6 ) )[ _MO_SHORT_NAME ] ) )
      r_use( dir_server() + 'kartote_', , '_KART_' )
      r_use( dir_server() + 'kartotek', , '_KART' )
      Set Relation To kod into _KART_
      r_use( dir_server() + 'mo_nnapr', , 'NAPR' )
      Set Relation To kod_k into _KART
      Index On Upper( _kart->fio ) + Str( _kart->kod, 7 ) to ( cur_dir() + 'tmp_napr' ) ;
        For KOD_F_1in == nf->kod
      i := 0
      Go Top
      Do While !Eof()
        verify_ff( HH -5, .t., sh )
        add_string( '' )
        add_string( lstr( ++i ) + '. Направление № ' + AllTrim( napr->NUM_D ) + ' от ' + date_8( napr->DATE_D ) )
        add_string( Space( 3 ) + AllTrim( _kart->fio ) + ', д.р.' + full_date( _kart->date_r ) )
        add_string( Space( 3 ) + 'Условия оказания, в которые направляется пациент: ' + iif( napr->usl_ok_1 == 2, 'дневной ', '' ) + 'стационар' )
        add_string( Space( 3 ) + 'Направление выдано по результатам диспансеризации/профосмотра взрослых: ' + iif( napr->disp_1 == 1, 'нет', 'да' ) )
        add_string( Space( 3 ) + 'планируемая дата госпитализации ' + date_8( napr->DATE_H_1 ) + ' по диагнозу ' + AllTrim( napr->DS_1 ) )
        add_string( Space( 3 ) + inieditspr( A__MENUVERT, arr_t007(), napr->PROFIL_K_1 ) + ;
          ' (' + inieditspr( A__MENUVERT, getv002(), napr->PROFIL_1 ) + ')' )
        Select NAPR
        Skip
      Enddo
      FClose( fp )
      _kart->( dbCloseArea() )
      _kart_->( dbCloseArea() )
      napr->( dbCloseArea() )
      rest_box( buf )
      viewtext( n_file, , , , .t., , , 2 )
      Select NF
    Endcase
  Endif
  Return ret

// Список информационных пакетов с аннулированными направлениями
Function _263_from_i03()

  ne_real()
  Return Nil

// Список информационных пакетов с госпитализациями по направлениям
Function _263_from_i04()

  ne_real()
  Return Nil

// Список информационных пакетов с госпитализациями без направлений (экстр.и неотл.)
Function _263_from_i05()

  ne_real()
  Return Nil

// Список информационных пакетов со сведениями о выбывших пациентах
Function _263_from_i06()

  ne_real()
  Return Nil

// Список информационных пакетов со сведениями о наличии свободных мест
Function _263_from_i07()

  ne_real()
  Return Nil

// 20.01.16 добавим или перезапишем запись в картотеке
Function _263_add_kart( lkod_k, lfio, cFileProtokol, yes_append )

  Local s, fl_nameismo := .f., mfio := PadR( Upper( lfio ), 50 )

  Default yes_append To .t.
  Select KART
  If Empty( lkod_k )
    Set Order To 2
    find ( '1' + mfio + DToS( tmp2->BIRTHDAY ) )
    If Found()
      lkod_k := kart->kod
    Endif
  Else
    Goto ( lkod_k )
    If !( mfio == Upper( kart->fio ) .and. tmp2->BIRTHDAY == kart->DATE_R )
      StrFile( Space( 7 ) + 'в нашей картотеке данный пациент записан как:' + ;
        Space( 9 ) + AllTrim( kart->fio ) + ' д.р.' + full_date( kart->DATE_R ) + ;
        hb_eol(), cFileProtokol, .t. )
      lkod_k := 0
    Endif
  Endif
  Select KART
  Set Order To 1
  If Empty( lkod_k )
    If yes_append
      StrFile( Space( 7 ) + 'добавляем этого пациента в нашу картотеку как нового' + ;
        hb_eol(), cFileProtokol, .t. )
      add1rec( 7 )
      lkod_k := kart->kod := RecNo()
      kart->FIO    := lfio
      kart->DATE_R := tmp2->BIRTHDAY
    Else
      Return lkod_k
    Endif
  Else
    StrFile( Space( 7 ) + 'данный пациент найден в нашей картотеке' + ;
      hb_eol(), cFileProtokol, .t. )
    Goto ( lkod_k )
    g_rlock( forever )
  Endif
  Private mdate_r := kart->DATE_R, m1VZROS_REB := 0, M1NOVOR := 0
  fv_date_r()
  kart->pol       := iif( tmp2->SEX == 1, 'М', 'Ж' )
  kart->VZROS_REB := m1VZROS_REB
  kart->POLIS     := make_polis( tmp2->SER_P, tmp2->NUM_P )
  kart->snils     := CharRem( '- ', tmp2->SS )
  If twowordfamimot( tmp2->SURNAME ) .or. twowordfamimot( tmp2->NAME ) ;
      .or. twowordfamimot( tmp2->PATRONYMIC )
    kart->MEST_INOG := 9
  Else
    kart->MEST_INOG := 0
  Endif
  Select KART_
  Do While kart_->( LastRec() ) < lkod_k
    Append Blank
  Enddo
  Goto ( lkod_k )
  g_rlock( forever )
  kart_->VPOLIS    := tmp2->TYPE_P
  kart_->SPOLIS    := tmp2->SER_P
  kart_->NPOLIS    := tmp2->NUM_P
  kart_->SMO       := tmp2->SMO
  kart_->KVARTAL_D := tmp2->REG_OMS // ОКАТО субъекта РФ территории страхования
  If !Empty( tmp2->TEL_M )
    kart_->PHONE_M := CharRem( '-', tmp2->TEL_M )
  Endif
  If !Empty( tmp2->TEL_F )
    kart_->PHONE_H := CharRem( '-', tmp2->TEL_F )
  Endif
  //
  Select KART2
  Do While kart2->( LastRec() ) < lkod_k
    Append Blank
  Enddo
  If !Empty( tmp2->ENP )
    Goto ( lkod_k )
    g_rlock( forever )
    kart2->kod_mis := tmp2->ENP
  Endif
  //
  Select KFIO
  find ( Str( lkod_k, 7 ) )
  If Found()
    If kart->MEST_INOG == 9
      g_rlock( forever )
      kfio->FAM := tmp2->SURNAME
      kfio->IM  := tmp2->NAME
      kfio->OT  := tmp2->PATRONYMIC
    Else
      deleterec( .t. )
    Endif
  Else
    If kart->MEST_INOG == 9
      addrec( 7 )
      kfio->kod := lkod_k
      kfio->FAM := tmp2->SURNAME
      kfio->IM  := tmp2->NAME
      kfio->OT  := tmp2->PATRONYMIC
    Endif
  Endif
  If Empty( tmp2->SMO ) .and. !Empty( tmp2->NAME_SMO )
    fl_nameismo := .t.
  Endif
  Select KSN
  find ( Str( lkod_k, 7 ) )
  If Found()
    If fl_nameismo
      g_rlock( forever )
      ksn->smo_name := tmp2->NAME_SMO
    Else
      deleterec( .t. )
    Endif
  Else
    If fl_nameismo
      addrec( 7 )
      ksn->kod := lkod_k
      ksn->smo_name := tmp2->NAME_SMO
    Endif
  Endif
  Return lkod_k

// 15.10.24 зачитать протокол обработки информационного пакета (любого)
Function _263_protokol_tmpfile( nfile, aerr )

  Local adbf, j, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
    { 'NAME_F', 'C', 26, 0 }, ;
    { 'DATE_F', 'D',  8, 0 }, ;
    { 'OSHIB',  'N',  3, 0 }, ;  // код ошибки T008 для всего файла
    { 'KOL2',   'N',  6, 0 } ;   // кол-во ошибок
  }
  dbCreate( cur_dir() + 'tmp1file', adbf, , .t., 'TMP1' )
  Append Blank
  tmp1->OSHIB := -1
  //
  adbf := { ; // элементы PR
  { 'OSHIB',      'N',  3, 0 }, ;  // код ошибки  T008
  { 'IM_POL',     'C', 20, 0 }, ;  // имя поля, в котором ошибка
  { 'BAS_EL',     'C', 20, 0 }, ;  // имя базового элемента
  { 'ID_BAS',     'C', 36, 0 }, ;  // GUID базового элемента
  { 'KOD_NAPR',   'N',  6, 0 } ;   // код по БД направлений
  }
  dbCreate( cur_dir() + 'tmp2file', adbf, , .t., 'TMP2' )  // элементы PR
  If Upper( Right( nfile, 4 ) ) == sxml()
    // читаем файл в память
    oXmlDoc := hxmldoc():read( _tmp_dir1() + nfile )
    is_err_FLK := ( oXmlDoc == NIL )
  Endif
  If !is_err_FLK
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      Do Case
      Case 'NAME_F' == oXmlNode:title
        tmp1->NAME_F := mo_read_xml_tag( oXmlNode, aerr, .t. )
      Case 'DATE_F' == oXmlNode:title
        tmp1->DATE_F := xml2date( mo_read_xml_tag( oXmlNode, aerr, .t. ) )
      Case 'PR' == oXmlNode:title
        Select TMP2
        Append Blank
        tmp2->OSHIB := Val( mo_read_xml_stroke( oXmlNode, 'OSHIB', aerr ) )
        If tmp2->OSHIB == 0
          tmp1->OSHIB := 0
        Else
          is_err_FLK := .t.
        Endif
        tmp2->IM_POL := mo_read_xml_stroke( oXmlNode, 'IM_POL', aerr, .f. )
        tmp2->BAS_EL := mo_read_xml_stroke( oXmlNode, 'BAS_EL', aerr, .f. )
        tmp2->ID_BAS := mo_read_xml_stroke( oXmlNode, 'ID_BAS', aerr, .f. )
        If !Empty( tmp2->BAS_EL ) .and. !Empty( tmp2->ID_BAS )
          tmp1->KOL2++
        Endif
      Endcase
    Next j
  Endif
  Select TMP2
  Index On Upper( ID_BAS ) to ( cur_dir() + 'tmp2file' )
  Commit
  Return is_err_FLK

// 15.10.24 зачитать информационный пакет I01
Function _263_i01_tmpfile( nfile, aerr )

  Local _table1 := { ;
    { 'VERSION',   'C',  5, 0 }, ; // версия взаимодействия
    { 'DATE_F',    'D',  8, 0 }, ; // дата формирования файла
    { 'NAME_F',    'C', 26, 0 }, ; // имя файла
    { 'DATE_R',    'D',  8, 0 }, ; // отчетная дата
    { 'KOL',       'N',  6, 0 } ;  // кол-во направлений в файле
  }
  Local _table2 := { ;
    { 'MO',        'C',  6, 0 }, ; // mcod п-ки
    { 'LPU',       'C',  6, 0 }, ; // codem п-ки
    { 'ID_D',      'C', 36, 0 }, ; //
    { 'NUM_D',     'C', 15, 0 }, ; // номер направления
    { 'DATE_D',    'D',  8, 0 }, ; // дата направления
    { 'MO_H',      'C',  6, 0 }, ; // mcod стационара
    { 'LPU_H',     'C',  6, 0 }, ; // codem стационара
    { 'USL_OK',    'N',  1, 0 }, ; //
    { 'DISP',      'N',  1, 0 }, ; //
    { 'PROFIL',    'N',  3, 0 }, ; // профиль медпомощи
    { 'PROFIL_K',  'N',  3, 0 }, ; // профиль койки
    { 'DS',        'C',  6, 0 }, ; // диагноз
    { 'IDDOKT',    'C', 16, 0 }, ; // код медработника
    { 'F_MEDC',    'N',  1, 0 }, ; // форма оказания медпомощи
    { 'DATE_HOSP', 'D',  8, 0 }, ; // планируемая дата госпитализации
    { 'COMMENT_D', 'C', 250, 0 }, ; //
    { 'SURNAME',   'C', 40, 0 }, ; //
    { 'NAME',      'C', 40, 0 }, ; //
    { 'PATRONYMIC', 'C', 40, 0 }, ; //
    { 'BIRTHDAY',  'D',  8, 0 }, ; //
    { 'SEX',       'N',  1, 0 }, ; //
    { 'SS',        'C', 14, 0 }, ; //
    { 'TYPE_P',    'N',  1, 0 }, ; //
    { 'SER_P',     'C', 10, 0 }, ; //
    { 'NUM_P',     'C', 20, 0 }, ; //
    { 'ENP',       'C', 16, 0 }, ; //
    { 'SMO',       'C',  5, 0 }, ; //
    { 'NAME_SMO',  'C', 100, 0 }, ; //
    { 'REG_OMS',   'C',  5, 0 }, ; //
    { 'COMMENT_P', 'C', 250, 0 }, ; //
    { 'TEL_M',     'C', 13, 0 }, ; //
    { 'TEL_F',     'C', 13, 0 } ;  //
  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., ;
    sMO, sLPU, oNode1, oNode2, oNode3

  //
  dbCreate( cur_dir() + 'tmp1file', _table1, , .t., 'TMP1' )
  Append Blank
  dbCreate( cur_dir() + 'tmp2file', _table2, , .t., 'TMP2' )
  If Upper( Right( nfile, 4 ) ) == sxml()
    fl := .t.
    // читаем файл в память
    oXmlDoc := hxmldoc():read( _tmp_dir1() + nfile )
    If oXmlDoc == NIL
      fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
    Endif
  Endif
  If fl
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      If Empty( oXmlDoc:aItems )
        fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
        Exit
      Endif
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      If 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
        tmp1->DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr ) )
        tmp1->NAME_F  :=          mo_read_xml_stroke( oXmlNode, 'NAME_F', aerr )
        tmp1->DATE_R  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_R', aerr ) )
        tmp1->KOL     := 0
      Elseif 'MO_D' == oXmlNode:title
        sMO  := mo_read_xml_stroke( oXmlNode, 'MO', aerr, .f. )
        sLPU := mo_read_xml_stroke( oXmlNode, 'LPU', aerr )
        If !Empty( sLPU ) .and. Empty( sMO )
          sMO  := ret_mo( sLPU )[ _MO_KOD_FFOMS ]
        Endif
        For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
          oNode2 := oXmlNode:aItems[ j1 ]     // т.к. направлений м.б. несколько
          If ValType( oNode2 ) != 'C' .and. oNode2:title == 'DIR'
            tmp1->KOL++
            Select TMP2
            Append Blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_D     :=          mo_read_xml_stroke( oNode2, 'ID_D', aerr )
            tmp2->NUM_D    :=          mo_read_xml_stroke( oNode2, 'NUM_D', aerr )
            tmp2->DATE_D   := xml2date( mo_read_xml_stroke( oNode2, 'DATE_D', aerr ) )
            tmp2->MO_H     :=          mo_read_xml_stroke( oNode2, 'MO_H', aerr )
            tmp2->LPU_H    :=          mo_read_xml_stroke( oNode2, 'LPU_H', aerr )
            tmp2->DISP     :=      Val( mo_read_xml_stroke( oNode2, 'DISP', aerr, .f. ) )
            tmp2->USL_OK   :=      Val( mo_read_xml_stroke( oNode2, 'USL_OK', aerr, .f. ) )
            If Empty( tmp2->USL_OK ) // для файлов старой версии
              tmp2->USL_OK := 1
            Endif
            tmp2->PROFIL   :=      Val( mo_read_xml_stroke( oNode2, 'PROFIL', aerr ) )
            tmp2->PROFIL_K := f_profil_k_v020_t007( mo_read_xml_stroke( oNode2, 'PROFIL_K', aerr ), tmp2->PROFIL, tmp1->DATE_R )
            tmp2->DS       :=          mo_read_xml_stroke( oNode2, 'DS', aerr )
            tmp2->IDDOKT   :=          mo_read_xml_stroke( oNode2, 'IDDOKT', aerr, .f. )
            tmp2->F_MEDC   :=      Val( mo_read_xml_stroke( oNode2, 'F_MEDC', aerr ) )
            tmp2->DATE_HOSP := xml2date( mo_read_xml_stroke( oNode2, 'DATE_HOSP', aerr ) )
            tmp2->COMMENT_D :=          mo_read_xml_stroke( oNode2, 'COMMENT_D', aerr, .f. )
            If ( oNode1 := oNode2:find( 'PATIENT' ) ) != NIL
              tmp2->SURNAME   :=          mo_read_xml_stroke( oNode1, 'SURNAME', aerr )
              tmp2->NAME      :=          mo_read_xml_stroke( oNode1, 'NAME', aerr )
              tmp2->PATRONYMIC :=          mo_read_xml_stroke( oNode1, 'PATRONYMIC', aerr, .f. )
              tmp2->BIRTHDAY  := xml2date( mo_read_xml_stroke( oNode1, 'BIRTHDAY', aerr ) )
              tmp2->SEX       :=      Val( mo_read_xml_stroke( oNode1, 'SEX', aerr ) )
              tmp2->SS        :=          mo_read_xml_stroke( oNode1, 'SS', aerr, .f. )
              tmp2->TYPE_P    :=      Val( mo_read_xml_stroke( oNode1, 'TYPE_P', aerr ) )
              tmp2->SER_P     :=          mo_read_xml_stroke( oNode1, 'SER_P', aerr, .f. )
              tmp2->NUM_P     :=          mo_read_xml_stroke( oNode1, 'NUM_P', aerr )
              tmp2->ENP       :=          mo_read_xml_stroke( oNode1, 'ENP', aerr, .f. )
              tmp2->SMO       :=          mo_read_xml_stroke( oNode1, 'SMO', aerr, .f. )
              tmp2->NAME_SMO  :=          mo_read_xml_stroke( oNode1, 'NAME_SMO', aerr, .f. )
              tmp2->REG_OMS   :=          mo_read_xml_stroke( oNode1, 'REG_OMS', aerr )
              tmp2->COMMENT_P :=          mo_read_xml_stroke( oNode1, 'COMMENT_P', aerr, .f. )
              If ( oNode3 := oNode1:find( 'CONTACT' ) ) != NIL
                tmp2->TEL_M := mo_read_xml_stroke( oNode3, 'TEL_M', aerr, .f. )
                tmp2->TEL_F := mo_read_xml_stroke( oNode3, 'TEL_F', aerr, .f. )
              Endif
            Endif
          Endif
        Next j1
      Endif
    Next j
  Endif
  rest_box( buf )
  Return fl .and. Empty( aerr )

// 15.10.24 зачитать информационный пакет I03
Function _263_i03_tmpfile( nfile, aerr )

  Local _table1 := { ;
    { 'VERSION',   'C',  5, 0 }, ; // версия взаимодействия
    { 'DATE_F',    'D',  8, 0 }, ; // дата формирования файла
    { 'NAME_F',    'C', 26, 0 }, ; // имя файла
    { 'DATE_R',    'D',  8, 0 }, ; // отчетная дата
    { 'KOL',       'N',  6, 0 } ;  // кол-во направлений в файле
  }
  Local _table2 := { ;
    { 'TYPE_S',    'N',  1, 0 }, ; // тип отправителя: 1-СМО, 2-стационар, 3-поликлиника
    { 'CODE',      'C',  6, 0 }, ; // регистрационный код отправителя
    { 'ID_D',      'C', 36, 0 }, ; // код записи направления
    { 'MO_D',      'C',  6, 0 }, ; // mcod п-ки
    { 'LPU_D',     'C',  6, 0 }, ; // codem п-ки
    { 'DATE_REF',  'D',  8, 0 }, ; // дата аннулирования
    { 'REASON_REF', 'N',  6, 0 } ;  // (от 1 до 9) причина аннулирования
  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., ;
    sMO, sLPU, oNode1, oNode2, oNode3

  //
  dbCreate( cur_dir() + 'tmp1file', _table1, , .t., 'TMP1' )
  Append Blank
  dbCreate( cur_dir() + 'tmp2file', _table2, , .t., 'TMP2' )
  If Upper( Right( nfile, 4 ) ) == sxml()
    fl := .t.
    // читаем файл в память
    oXmlDoc := hxmldoc():read( _tmp_dir1() + nfile )
    If oXmlDoc == NIL
      fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
    Endif
  Endif
  If fl
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      If Empty( oXmlDoc:aItems )
        fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
        Exit
      Endif
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      If 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
        tmp1->DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr ) )
        tmp1->NAME_F  :=          mo_read_xml_stroke( oXmlNode, 'NAME_F', aerr )
        tmp1->DATE_R  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_R', aerr ) )
        tmp1->KOL     := 0
      Elseif 'SOURCE' == oXmlNode:title
        sTYPE_S := Int( Val( mo_read_xml_stroke( oXmlNode, 'TYPE_S', aerr ) ) )
        sCODE   :=         mo_read_xml_stroke( oXmlNode, 'CODE', aerr )
        For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
          oNode2 := oXmlNode:aItems[ j1 ]     // т.к. направлений м.б. несколько
          If ValType( oNode2 ) != 'C' .and. oNode2:title == 'REF_HOSP'
            tmp1->KOL++
            Select TMP2
            Append Blank
            tmp2->TYPE_S     := sTYPE_S
            tmp2->CODE       := sCODE
            tmp2->ID_D       := mo_read_xml_stroke( oNode2, 'ID_D', aerr )
            tmp2->MO_D       := mo_read_xml_stroke( oNode2, 'MO_D', aerr )
            tmp2->LPU_D      := mo_read_xml_stroke( oNode2, 'LPU_D', aerr )
            tmp2->DATE_REF   := xml2date( mo_read_xml_stroke( oNode2, 'DATE_REF', aerr ) )
            tmp2->REASON_REF := Val( mo_read_xml_stroke( oNode2, 'REASON_REF', aerr ) )
          Endif
        Next j1
      Endif
    Next j
  Endif
  rest_box( buf )
  Return fl .and. Empty( aerr )

// 15.10.24 зачитать информационный пакет I04 или I05
Function _263_i04_tmpfile( nfile, aerr )

  Local _table1 := { ;
    { 'VERSION',   'C',  5, 0 }, ; // версия взаимодействия
    { 'DATE_F',    'D',  8, 0 }, ; // дата формирования файла
    { 'NAME_F',    'C', 26, 0 }, ; // имя файла
    { 'DATE_R',    'D',  8, 0 }, ; // отчетная дата
    { 'KOL',       'N',  6, 0 } ;  // кол-во направлений в файле
  }
  Local _table2 := { ;
    { 'MO',        'C',  6, 0 }, ; // mcod п-ки
    { 'LPU',       'C',  6, 0 }, ; // codem п-ки
    { 'ID_H',      'C', 36, 0 }, ; //
    { 'TYPE_H',    'N',  1, 0 }, ; //
    { 'ID_D',      'C', 36, 0 }, ; //
    { 'MO_D',      'C',  6, 0 }, ; // mcod
    { 'LPU_D',     'C',  6, 0 }, ; // codem
    { 'DATE_H',    'D',  8, 0 }, ; // дата госпитализации
    { 'TIME_H',    'C',  5, 0 }, ; // время госпитализации
    { 'USL_OK',    'N',  1, 0 }, ; //
    { 'PROFIL',    'N',  3, 0 }, ; // профиль медпомощи
    { 'PROFIL_K',  'N',  3, 0 }, ; // профиль койки
    { 'DS',        'C',  6, 0 }, ; // диагноз
    { 'F_MEDC',    'N',  1, 0 }, ; // форма оказания медпомощи
    { 'NUM_HIST',  'C', 50, 0 }, ; //
    { 'COMMENT',   'C', 250, 0 }, ; //
    { 'SURNAME',   'C', 40, 0 }, ; //
    { 'NAME',      'C', 40, 0 }, ; //
    { 'PATRONYMIC', 'C', 40, 0 }, ; //
    { 'BIRTHDAY',  'D',  8, 0 }, ; //
    { 'SEX',       'N',  1, 0 }, ; //
    { 'SS',        'C', 14, 0 }, ; //
    { 'TYPE_P',    'N',  1, 0 }, ; //
    { 'SER_P',     'C', 10, 0 }, ; //
    { 'NUM_P',     'C', 20, 0 }, ; //
    { 'ENP',       'C', 16, 0 }, ; //
    { 'SMO',       'C',  5, 0 }, ; //
    { 'NAME_SMO',  'C', 100, 0 }, ; //
    { 'REG_OMS',   'C',  5, 0 }, ; //
    { 'COMMENT_P', 'C', 250, 0 }, ; //
    { 'TEL_M',     'C', 13, 0 }, ; //
    { 'TEL_F',     'C', 13, 0 } ;  //
  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., sMO, ;
    sLPU, oNode1, oNode2, oNode3

  //
  dbCreate( cur_dir() + 'tmp1file', _table1, , .t., 'TMP1' )
  Append Blank
  dbCreate( cur_dir() + 'tmp2file', _table2, , .t., 'TMP2' )
  If Upper( Right( nfile, 4 ) ) == sxml()
    fl := .t.
    // читаем файл в память
    oXmlDoc := hxmldoc():read( _tmp_dir1() + nfile )
    If oXmlDoc == NIL
      fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
    Endif
  Endif
  If fl
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      If Empty( oXmlDoc:aItems )
        fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
        Exit
      Endif
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      If 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
        tmp1->DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr ) )
        tmp1->NAME_F  :=          mo_read_xml_stroke( oXmlNode, 'NAME_F', aerr )
        tmp1->DATE_R  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_R', aerr ) )
        tmp1->KOL     := 0
      Elseif eq_any( oXmlNode:title, 'MO_HOSP', 'MO_EXTR' )
        sMO  := mo_read_xml_stroke( oXmlNode, 'MO', aerr, .f. )
        sLPU := mo_read_xml_stroke( oXmlNode, 'LPU', aerr )
        If !Empty( sLPU ) .and. Empty( sMO )
          sMO  := ret_mo( sLPU )[ _MO_KOD_FFOMS ]
        Endif
        For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
          oNode2 := oXmlNode:aItems[ j1 ]     // т.к. направлений м.б. несколько
          If ValType( oNode2 ) != 'C' .and. oNode2:title == 'HOSP'
            tmp1->KOL++
            Select TMP2
            Append Blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_H     :=          mo_read_xml_stroke( oNode2, 'ID_H', aerr )
            tmp2->TYPE_H   :=      Val( mo_read_xml_stroke( oNode2, 'TYPE_H', aerr, .f. ) )
            tmp2->USL_OK   :=      Val( mo_read_xml_stroke( oNode2, 'USL_OK', aerr, .f. ) )
            If Empty( tmp2->USL_OK ) // для файлов старой версии / или пакет I05
              tmp2->USL_OK := 1
            Endif
            If Empty( tmp2->TYPE_H )
              tmp2->TYPE_H := 4 // т.е. это информационный пакет I05
            Endif
            tmp2->ID_D     :=          mo_read_xml_stroke( oNode2, 'ID_D', aerr, .f. )
            tmp2->MO_D     :=          mo_read_xml_stroke( oNode2, 'MO_D', aerr, .f. )
            tmp2->LPU_D    :=          mo_read_xml_stroke( oNode2, 'LPU_D', aerr, .f. )
            tmp2->DATE_H   := xml2date( mo_read_xml_stroke( oNode2, 'DATE_H', aerr ) )
            tmp2->TIME_H   :=          mo_read_xml_stroke( oNode2, 'TIME_H', aerr )
            If '-' $ tmp2->TIME_H
              tmp2->TIME_H := CharRepl( '-', tmp2->TIME_H, ':' ) // время в моём формате
            Endif
            tmp2->DS       :=          mo_read_xml_stroke( oNode2, 'DS', aerr )
            tmp2->F_MEDC   :=      Val( mo_read_xml_stroke( oNode2, 'F_MEDC', aerr ) )
            tmp2->PROFIL   :=      Val( mo_read_xml_stroke( oNode2, 'PROFIL', aerr ) )
            tmp2->PROFIL_K := f_profil_k_v020_t007( mo_read_xml_stroke( oNode2, 'PROFIL_K', aerr ), tmp2->PROFIL, tmp1->DATE_R )
            tmp2->NUM_HIST :=          mo_read_xml_stroke( oNode2, 'NUM_HIST', aerr )
            tmp2->COMMENT  :=          mo_read_xml_stroke( oNode2, 'COMMENT', aerr, .f. )
            If ( oNode1 := oNode2:find( 'PATIENT' ) ) != NIL
              tmp2->SURNAME   :=          mo_read_xml_stroke( oNode1, 'SURNAME', aerr )
              tmp2->NAME      :=          mo_read_xml_stroke( oNode1, 'NAME', aerr )
              tmp2->PATRONYMIC :=          mo_read_xml_stroke( oNode1, 'PATRONYMIC', aerr, .f. )
              tmp2->BIRTHDAY  := xml2date( mo_read_xml_stroke( oNode1, 'BIRTHDAY', aerr, .f. ) )
              tmp2->SEX       :=      Val( mo_read_xml_stroke( oNode1, 'SEX', aerr ) )
              tmp2->SS        :=          mo_read_xml_stroke( oNode1, 'SS', aerr, .f. )
              tmp2->TYPE_P    :=      Val( mo_read_xml_stroke( oNode1, 'TYPE_P', aerr, .f. ) )
              tmp2->SER_P     :=          mo_read_xml_stroke( oNode1, 'SER_P', aerr, .f. )
              tmp2->NUM_P     :=          mo_read_xml_stroke( oNode1, 'NUM_P', aerr, .f. )
              tmp2->ENP       :=          mo_read_xml_stroke( oNode1, 'ENP', aerr, .f. )
              tmp2->SMO       :=          mo_read_xml_stroke( oNode1, 'SMO', aerr, .f. )
              tmp2->NAME_SMO  :=          mo_read_xml_stroke( oNode1, 'NAME_SMO', aerr, .f. )
              tmp2->REG_OMS   :=          mo_read_xml_stroke( oNode1, 'REG_OMS', aerr, .f. )
              tmp2->COMMENT_P :=          mo_read_xml_stroke( oNode1, 'COMMENT_P', aerr, .f. )
            Endif
          Endif
        Next j1
      Endif
    Next j
  Endif
  rest_box( buf )
  Return fl .and. Empty( aerr )

// 15.10.24 зачитать информационный пакет I06
Function _263_i06_tmpfile( nfile, aerr )

  Local _table1 := { ;
    { 'VERSION',   'C',  5, 0 }, ; // версия взаимодействия
    { 'DATE_F',    'D',  8, 0 }, ; // дата формирования файла
    { 'NAME_F',    'C', 26, 0 }, ; // имя файла
    { 'DATE_R',    'D',  8, 0 }, ; // отчетная дата
    { 'KOL',       'N',  6, 0 } ;  // кол-во направлений в файле
  }
  Local _table2 := { ;
    { 'MO',        'C',  6, 0 }, ; // mcod п-ки
    { 'LPU',       'C',  6, 0 }, ; // codem п-ки
    { 'ID_DISCH',  'C', 36, 0 }, ; //
    { 'ID_D',      'C', 36, 0 }, ; //
    { 'MO_D',      'C',  6, 0 }, ; // mcod
    { 'LPU_D',     'C',  6, 0 }, ; // codem
    { 'DATE_H',    'D',  8, 0 }, ; // дата госпитализации
    { 'DATE_D',    'D',  8, 0 }, ; // дата госпитализации
    { 'USL_OK',    'N',  1, 0 }, ; //
    { 'PROFIL',    'N',  3, 0 }, ; // профиль медпомощи
    { 'PROFIL_K',  'N',  3, 0 }, ; // профиль койки
    { 'F_MEDC',    'N',  1, 0 }, ; // форма оказания медпомощи
    { 'NUM_HIST',  'C', 50, 0 }, ; //
    { 'COMMENT',   'C', 250, 0 }, ; //
    { 'BIRTHDAY',  'D',  8, 0 }, ; //
    { 'SEX',       'N',  1, 0 }, ; //
    { 'ENP',       'C', 16, 0 } ;  //
  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., sMO, sLPU, ;
    oNode1, oNode2, oNode3

  //
  dbCreate( cur_dir() + 'tmp1file', _table1, , .t., 'TMP1' )
  Append Blank
  dbCreate( cur_dir() + 'tmp2file', _table2, , .t., 'TMP2' )
  If Upper( Right( nfile, 4 ) ) == sxml()
    fl := .t.
    // читаем файл в память
    oXmlDoc := hxmldoc():read( _tmp_dir1() + nfile )
    If oXmlDoc == NIL
      fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
    Endif
  Endif
  If fl
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      If Empty( oXmlDoc:aItems )
        fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
        Exit
      Endif
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      If 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
        tmp1->DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr ) )
        tmp1->NAME_F  :=          mo_read_xml_stroke( oXmlNode, 'NAME_F', aerr )
        tmp1->DATE_R  := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_R', aerr ) )
        tmp1->KOL     := 0
      Elseif oXmlNode:title == 'MO_DC'
        sMO  := mo_read_xml_stroke( oXmlNode, 'MO', aerr, .f. )
        sLPU := mo_read_xml_stroke( oXmlNode, 'LPU', aerr )
        If !Empty( sLPU ) .and. Empty( sMO )
          sMO  := ret_mo( sLPU )[ _MO_KOD_FFOMS ]
        Endif
        For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
          oNode2 := oXmlNode:aItems[ j1 ]     // т.к. направлений м.б. несколько
          If ValType( oNode2 ) != 'C' .and. oNode2:title == 'DISCH'
            tmp1->KOL++
            Select TMP2
            Append Blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_DISCH :=          mo_read_xml_stroke( oNode2, 'ID_DISCH', aerr )
            tmp2->DATE_H   := xml2date( mo_read_xml_stroke( oNode2, 'DATE_H', aerr ) )
            tmp2->DATE_D   := xml2date( mo_read_xml_stroke( oNode2, 'DATE_D', aerr ) )
            tmp2->F_MEDC   :=      Val( mo_read_xml_stroke( oNode2, 'F_MEDC', aerr ) )
            tmp2->USL_OK   :=      Val( mo_read_xml_stroke( oNode2, 'USL_OK', aerr, .f. ) )
            If Empty( tmp2->USL_OK ) // для файлов старой версии
              tmp2->USL_OK := 1
            Endif
            tmp2->PROFIL   :=      Val( mo_read_xml_stroke( oNode2, 'PROFIL', aerr ) )
            tmp2->PROFIL_K := f_profil_k_v020_t007( mo_read_xml_stroke( oNode2, 'PROFIL_K', aerr ), tmp2->PROFIL, tmp1->DATE_R )
            tmp2->ID_D     :=          mo_read_xml_stroke( oNode2, 'ID_D', aerr, .f. )
            tmp2->MO_D     :=          mo_read_xml_stroke( oNode2, 'MO_D', aerr, .f. )
            tmp2->LPU_D    :=          mo_read_xml_stroke( oNode2, 'LPU_D', aerr, .f. )
            tmp2->NUM_HIST :=          mo_read_xml_stroke( oNode2, 'NUM_HIST', aerr )
            tmp2->COMMENT  :=          mo_read_xml_stroke( oNode2, 'COMMENT', aerr, .f. )
            If ( oNode1 := oNode2:find( 'PATIENT' ) ) != NIL
              tmp2->BIRTHDAY  := xml2date( mo_read_xml_stroke( oNode1, 'BIRTHDAY', aerr ) )
              tmp2->SEX       :=      Val( mo_read_xml_stroke( oNode1, 'SEX', aerr ) )
              tmp2->ENP       :=          mo_read_xml_stroke( oNode1, 'ENP', aerr, .f. )
            Endif
          Endif
        Next j1
      Endif
    Next j
  Endif
  rest_box( buf )
  Return fl .and. Empty( aerr )

// 15.10.24 зачитать информационный пакет I07
Function _263_i07_tmpfile( nfile, aerr )

  Local _table1 := { ;
    { 'VERSION',   'C',  5, 0 }, ; // версия взаимодействия
    { 'DATE_F',    'D',  8, 0 }, ; // дата формирования файла
    { 'NAME_F',    'C', 26, 0 }, ; // имя файла
    { 'DATE_R',    'D',  8, 0 }, ; // отчетная дата
    { 'KOL',       'N',  6, 0 } ;  // кол-во учреждений в файле
  }
  Local _table2 := { ;
    { 'MO',        'C',  6, 0 }, ; // mcod п-ки
    { 'LPU',       'C',  6, 0 }, ; // codem п-ки
    { 'ID_PL',     'C', 36, 0 }, ; // GUID записи
    { 'USL_OK',    'N',  1, 0 }, ; //
    { 'PROFIL_K',  'N',  3, 0 }, ; // профиль койки
    { 'PROFIL',    'N',  3, 0 }, ; // профиль мед.помощи
    { 'QUANTITY',  'N',  3, 0 }, ; // количество коек
    { 'Q_P',       'N',  3, 0 }, ; // состояло пациентов на начало пред.суток
    { 'Q_AP',      'N',  3, 0 }, ; // поступило пациентов за пред.сутки
    { 'Q_DP',      'N',  3, 0 }, ; // выбыло пациентов за пред.сутки
    { 'Q_HP',      'N',  3, 0 }, ; // запланировано госпитализаций на тек.день
    { 'PLACE_FREE', 'N',  3, 0 }, ; // количество свободных мест
    { 'PF_M',      'N',  3, 0 }, ; // --''-- для мужчин
    { 'PF_W',      'N',  3, 0 }, ; // --''-- для женщин
    { 'PF_C',      'N',  3, 0 }, ; // --''-- для детей
    { 'PLACE1',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M1',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W1',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C1',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE2',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M2',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W2',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C2',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE3',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M3',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W3',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C3',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE4',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M4',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W4',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C4',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE5',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M5',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W5',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C5',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE6',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M6',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W6',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C6',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE7',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M7',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W7',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C7',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE8',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M8',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W8',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C8',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE9',      'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M9',       'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W9',       'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C9',       'N', 3, 0 }, ; // --''-- для детей
    { 'PLACE10',     'N', 3, 0 }, ; // количество свободных мест
    { 'PF_M10',      'N', 3, 0 }, ; // --''-- для мужчин
    { 'PF_W10',      'N', 3, 0 }, ; // --''-- для женщин
    { 'PF_C10',      'N', 3, 0 }, ; // --''-- для детей
    { 'COMMENT',   'C', 250, 0 }, ; //
    { 'V_H34001',  'N', 15, 0 }, ; // количество госпитализаций реабилитаций СНГ
    { 'V_H34002',  'N', 15, 0 }, ; // количество госпитализаций реабилитаций СНГ
    { 'V_H34006',  'N', 15, 0 }, ; // количество госпитализаций реабилитаций СНГ
    { 'V_H34007',  'N', 15, 0 } ; // количество госпитализаций реабилитаций СНГ
  }
  Local arr_f, ii, oXmlDoc, j, j1, j2, ifp, d, _ar, buf := save_maxrow(), fl := .f., ;
    sMO, sLPU, oNode1, oNode2, oNode3, oNode4, ssmo, arr

  //
  dbCreate( cur_dir() + 'tmp1file', _table1, , .t., 'TMP1' )
  Append Blank
  dbCreate( cur_dir() + 'tmp2file', _table2, , .t., 'TMP2' )
  If Upper( Right( nfile, 4 ) ) == sxml()
    fl := .t.
    // читаем файл в память
    oXmlDoc := hxmldoc():read( _tmp_dir1() + nfile )
    If oXmlDoc == NIL
      fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
    Endif
  Endif
  If fl
    For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
      If Empty( oXmlDoc:aItems )
        fl := func_error( 4, 'Ошибка в чтении файла ' + nfile )
        Exit
      Endif
      oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
      If 'ZGLV' == oXmlNode:title
        tmp1->VERSION := mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
        tmp1->DATE_F := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr ) )
        tmp1->NAME_F :=          mo_read_xml_stroke( oXmlNode, 'NAME_F', aerr )
        tmp1->DATE_R := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_R', aerr ) )
        tmp1->KOL    := 0
      Elseif oXmlNode:title == 'MO_PLACE'
        sMO  := mo_read_xml_stroke( oXmlNode, 'MO', aerr, .f. )
        sLPU := mo_read_xml_stroke( oXmlNode, 'LPU', aerr )
        If !Empty( sLPU ) .and. Empty( sMO )
          sMO  := ret_mo( sLPU )[ _MO_KOD_FFOMS ]
        Endif
        For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
          oNode2 := oXmlNode:aItems[ j1 ]     // т.к. профилей больше одного
          If ValType( oNode2 ) != 'C' .and. oNode2:title == 'PLACES'
            Select TMP2
            Append Blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_PL    :=     mo_read_xml_stroke( oNode2, 'ID_PL', aerr )
            tmp2->USL_OK   := Val( mo_read_xml_stroke( oNode2, 'USL_OK', aerr, .f. ) )
            If Empty( tmp2->USL_OK ) // для файлов старой версии
              tmp2->USL_OK := 1
            Endif
            tmp2->PROFIL   := Val( mo_read_xml_stroke( oNode2, 'PROFIL', aerr ) )
            tmp2->PROFIL_K := f_profil_k_v020_t007( mo_read_xml_stroke( oNode2, 'PROFIL_K', aerr ), tmp2->PROFIL, tmp1->DATE_R )
            tmp2->QUANTITY := Val( mo_read_xml_stroke( oNode2, 'QUANTITY', aerr ) )
            tmp2->Q_P      := Val( mo_read_xml_stroke( oNode2, 'Q_P', aerr ) )
            tmp2->Q_AP     := Val( mo_read_xml_stroke( oNode2, 'Q_AP', aerr ) )
            tmp2->Q_DP     := Val( mo_read_xml_stroke( oNode2, 'Q_DP', aerr ) )
            tmp2->Q_HP     := Val( mo_read_xml_stroke( oNode2, 'Q_HP', aerr ) )
            If ( oNode3 := oNode2:find( 'FREE_PLACES' ) ) != NIL
              arr := {}
              For j2 := 1 To Len( oNode3:aItems )
                oNode4 := oNode3:aItems[ j2 ]
                If 'ZAP' == oNode4:title
                  d := xml2date( mo_read_xml_stroke( oNode4, 'DATE_PL', aerr ) )
                  v1 := Val( mo_read_xml_stroke( oNode4, 'PLACE_FREE', aerr ) )
                  v2 := Val( mo_read_xml_stroke( oNode4, 'PF_M', aerr ) )
                  v3 := Val( mo_read_xml_stroke( oNode4, 'PF_W', aerr ) )
                  v4 := Val( mo_read_xml_stroke( oNode4, 'PF_C', aerr ) )
                  AAdd( arr, { v1, v2, v3, v4, d } )
                Endif
              Next j2
              ASort( arr, , , {| x, y| x[ 5 ] < y[ 5 ] } ) // если у других не отсортированы даты
              For j2 := 1 To Min( 11, Len( arr ) )
                ifp := j2 -1
                pole := iif( ifp == 0, 'tmp2->PLACE_FREE', 'tmp2->PLACE' + lstr( ifp ) )
                &pole := arr[ j2, 1 ]
                pole := 'tmp2->PF_M' + iif( ifp == 0, '', lstr( ifp ) )
                &pole := arr[ j2, 2 ]
                pole := 'tmp2->PF_W' + iif( ifp == 0, '', lstr( ifp ) )
                &pole := arr[ j2, 3 ]
                pole := 'tmp2->PF_C' + iif( ifp == 0, '', lstr( ifp ) )
                &pole := arr[ j2, 4 ]
              Next j2
            Endif
            tmp2->COMMENT := mo_read_xml_stroke( oNode2, 'COMMENT', aerr, .f. )
            For j2 := 1 To Len( oNode2:aitems ) // последовательный просмотр
              oNode3 := oNode2:aItems[ j2 ]     // т.к. СМО м.б. несколько
              If ValType( oNode3 ) != 'C' .and. oNode3:title == 'SMO_V'
                ssmo := AllTrim( mo_read_xml_stroke( oNode3, 'SMO', aerr ) )
                If eq_any( ssmo, '34001', '34002', '34006', '34007' )
                  &( 'tmp2->V_H' + ssmo ) := Val( mo_read_xml_stroke( oNode3, 'V_H', aerr ) )
                Endif
              Endif
            Next j2
          Endif
        Next j1
      Endif
    Next j
  Endif
  rest_box( buf )
  Return fl .and. Empty( aerr )

// 11.02.19 вернуть профиль и профиль койки в виде строк в массиве
Function _263_pr_prk( lprk, lpr, ldate_r )

  Local ar[ 2 ]

  ar[ 2 ] := f_profil_k_t007_v020( lprk, @lpr, ldate_r )
  ar[ 1 ] := lstr( lpr )
  Return ar

// 05.06.23 профиль койки из t007 в v020 и в строку
Function f_profil_k_t007_v020( lprk, /*@*/lpr, ldate_r)

  Local lprk20 := lprk
  Local arrT007 := loadt007()
  Local row := {}, lFound := .f.

  If ldate_r > 0d20190115 // с 16 января
    For Each row in arrT007
      If row[ 1 ] == lprk .and. row[ 3 ] == lpr
        lprk20 := row[ 2 ]
        lFound := .t.
        Exit
      Endif
    Next
    If ! lFound
      For Each row in arrT007
        If row[ 1 ] == lprk
          lprk20 := row[ 2 ]
          Exit
        Endif
      Next
    Endif

    If lprk20 == 50
      lpr := 162
    Elseif lprk20 == 51
      lpr := 163
    Endif
  Endif
  Return lstr( lprk20 )

// 05.06.23 профиль койки из строки в число, затем из v020 в t007
Function f_profil_k_v020_t007( sprk20, lpr, ldate_r )

  Local lprk, lprk20 := Int( Val( sprk20 ) )
  Local arrT007 := loadt007()
  Local row := {}, lFound := .f.

  lprk := lprk20
  If ldate_r > 0d20190115 // с 16 января
    // if select('T7') > 0
    // t7->(dbCloseArea())
    // endif
    // R_Use(dir_exe() + '_mo_t007', cur_dir() + '_mo_t0072', 'T7')
    // find (str(lprk20, 3) + str(lpr, 3))
    // if found()
    // lprk := t7->profil_k
    // else
    // find (str(lprk20, 3))
    // if found()
    // lprk := t7->profil_k
    // endif
    // endif
    // t7->(dbCloseArea())

    For Each row in arrT007
      If row[ 2 ] == lprk20 .and. row[ 3 ] == lpr
        lprk := row[ 1 ]
        lFound := .t.
        Exit
      Endif
    Next
    If ! lFound
      For Each row in arrT007
        If row[ 2 ] == lprk20
          lprk := row[ 1 ]
          Exit
        Endif
      Next
    Endif

  Endif
  Return lprk
