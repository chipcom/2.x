#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 24.12.25
function mm_SOC()

  local aSOC := { ;
    { 'категория отсутствует', 0 }, ;
    { 'участник СВО уволенный в запас (отставку)', 35 }, ;
    { 'член семьи участника СВО', 65 } ;
  }

  if Year( Date() ) >= 2026 // начиная с 2026 года
    AAdd( aSOC, { 'инвалид I группы', 83 } )
  endif

  return aSOC

// 12.01.25
function control_number_phone( get )

  local phoneTemplate := '^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$'  
//  local phoneTemplate := "^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$"
  local lRet := .f.

  lRet := hb_RegexLike( phoneTemplate, get:Buffer )
  if ! lRet
    func_error( 4, 'Не допустимый номер телефона!' )
  endif

  return lRet

// 08.08.24
function razbor_str_fio( mfio )

  local k := 0, i, s := '', s1 := '', aFIO := { '', '', '' }

  mfio := alltrim( mfio )
  For i := 1 To NumToken( mfio, ' ' )
    s1 := AllTrim( Token( mfio, ' ', i ) )
    If ! Empty( s1 )
      ++k
      If k < 3
        aFIO[ k ] := s1
      Else
        s += s1 + ' '
      Endif
    Endif
  Next
  aFIO[ 3 ] := AllTrim( s )
  return aFIO

// 09.08.24
function short_FIO( mfio )

  local aFIO := razbor_str_fio( mfio )

  return 	aFIO[ 1 ] + ' ' + Left( aFIO[2], 1 ) + '.' + if( Empty( aFIO[3] ), '', Left( aFIO[3], 1 ) + '.' )
    
// проверить отдельно фамилию, имя и отчество в GET'ах
Function valfamimot( ltip, s, par, /*@*/msg)

  Static arr_pole := { 'Фамилия', 'Имя', 'Отчество' }
  Static arr_char := { ' ', '-', '.', "'", '"' }
  Local fl := .t., i, c, s1 := '', nword := 0, get, r := Row()

  Default par To 1
  s := AllTrim( s )
  For i := 1 To Len( arr_char )
    s := CharOne( arr_char[ i ], s )
  Next
  If Len( s ) > 0
    s := Upper( Left( s, 1 ) ) + SubStr( s, 2 )
  Endif
  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    If isralpha( c )
      //
    Elseif AScan( arr_char, c ) > 0
      ++nword
    Else
      s1 += c
    Endif
  Next
  msg := ''
  If !Empty( s1 )
    msg := 'В поле "' + arr_pole[ ltip ] + '" обнаружены недопустимые символы "' + s1 + '"'
  Elseif Empty( s ) .and. ltip < 3
    msg := 'Пустое значение поля "' + arr_pole[ ltip ] + '" недопустимо'
  Endif
  If par == 1  // для GET-системы
    Private tmp := ReadVar()
    &tmp := PadR( s, 40 )
    If Empty( msg ) .and. nword > 0
      If ( get := get_pointer( tmp ) ) != NIL
        r := get:Row
      Endif
      fl := .f.
      mybell()
      If f_alert( { PadC( 'В поле "' + arr_pole[ ltip ] + '" занесено ' + lstr( nword + 1 ) + ' слова', 60, '.' ) }, ;
          { ' Возврат в редактирование ', ' Правильное поле ' }, ;
          1, 'W+/N', 'N+/N', r + 1, , 'W+/N,N/BG' ) == 2
        fl := .t.
      Endif
    Endif
  Endif
  If !Empty( msg )
    If par == 1  // для GET-системы
      fl := func_error( 4, msg )
    Else  // для проверки ТФОМС
      fl := .f.
    Endif
  Endif

  Return fl

// 02.09.15 вернуть отдельно фамилию, имя и отчество в массиве
Function retfamimot( ltip, fl_no, is_open_kfio )

  Static cDelimiter := ' .'
  Local i, k := 0, s := '', s1, mfio, tmp_select, ret_arr := { '', '', '' }

  Default fl_no To .t., is_open_kfio To .f.
  If ltip == 1 // вызвали из картотеки
    mfio := kart->fio
  Else  // вызвали из листа учёта
    mfio := human->fio
    If human->kod_k != kart->kod // если не связаны по relation
      kart->( dbGoto( human->kod_k ) )
    Endif
  Endif
  If kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
    tmp_select := Select()
    If is_open_kfio
      Select KFIO
    Else
      r_use( dir_server() + 'mo_kfio', , 'KFIO' )
      Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_kfio' )
    Endif
    find ( Str( kart->kod, 7 ) )
    If Found()
      ret_arr[ 1 ] := AllTrim( kfio->FAM )
      ret_arr[ 2 ] := AllTrim( kfio->IM )
      ret_arr[ 3 ] := AllTrim( kfio->OT )
    Endif
    If !is_open_kfio
      kfio->( dbCloseArea() )
    Endif
    Select ( tmp_select )
  Endif
  If Empty( ret_arr[ 1 ] ) // на всякий случай - вдруг не нашли в "mo_kfio"
    mfio := AllTrim( mfio )
    For i := 1 To NumToken( mfio, cDelimiter )
      s1 := AllTrim( Token( mfio, cDelimiter, i ) )
      If !Empty( s1 )
        ++k
        If k < 3
          ret_arr[ k ] := s1
        Else
          s += s1 + ' '
        Endif
      Endif
    Next
    ret_arr[ 3 ] := AllTrim( s )
  Endif
  If fl_no .and. Empty( ret_arr[ 3 ] )
    ret_arr[ 3 ] := 'НЕТ'
  Endif

  Return ret_arr

// 26.10.14 проверка на правильность введённого ФИО
Function val_fio( afio, aerr )

  Local i, k := 0, msg

  Default aerr TO {}
  For i := 1 To 3
    valfamimot( i, afio[ i ], 2, @msg )
    If !Empty( msg )
      ++k
      AAdd( aerr, msg )
    Endif
  Next

  Return ( k == 0 )

function input_polis_OMS(cur_row, mkod)

  // переменные mvidpolis, m1vidpolis, mspolis, mnpolis объявлены ранее как PRIVATE
  default mkod to 0
  @ cur_row, 1 say 'Полис ОМС: вид' get mvidpolis ;
    reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)}
  @ row(), col() + 3 say 'серия' get mspolis when m1vidpolis == 1
  @ row(), col() + 3 say 'номер' get mnpolis ;
    picture iif(m1vidpolis == 3 .or. m1vidpolis == 1, '9999999999999999', '999999999');
    valid {|| findKartoteka(2, @mkod) ,func_valid_polis(m1vidpolis, mspolis, mnpolis)}

  return nil

// 10.02.17
Function get_fio_kart( k, r, c )

  Local s := '', ret, buf, tmp_keys

  Private fl_write_kartoteka := .f.

  buf := SaveScreen()
  tmp_keys := my_savekey()
  edit_kartotek( mkod_k, r + 1, , .t., mkod )
  my_restkey( tmp_keys )
  If fl_write_kartoteka
    r_use( dir_server() + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO := 1
    mfio := kart->fio
    mpol := kart->pol
    mdate_r := kart->date_r
    mfio_kart := _f_fio_kart()
    If Type( 'mn_data' ) == 'D'
      If Type( 'm1novor' ) == 'N' .and. Type( 'mdate_r2' ) == 'D' .and. m1novor > 0
        mvozrast := count_years( mdate_r2, mn_data )
      Else
        mvozrast := count_years( mdate_r, mn_data )
      Endif
    Endif
    If Type( 'm1novor' ) == 'N' .and. m1novor > 0
      M1VZROS_REB := 1 // ребенок
    Else
      M1VZROS_REB := kart->VZROS_REB
    Endif
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    m1komu      := kart->komu
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    msmo        := kart_->SMO
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
    mokato      := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
    mkomu       := inieditspr( A__MENUVERT, mm_komu, m1komu )
    mvidpolis   := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
    If !Empty( mn_data )
      fv_date_r( mn_data, .f. )
    Endif
    f_valid_komu(, -1 )
    m1company   := Int( Val( msmo ) )
    mcompany    := inieditspr( A__MENUVERT, mm_company, m1company )
    If m1company == 34
      mnameismo := ret_inogsmo_name( 1, , .t. ) // открыть и закрыть
    Elseif !( Left( msmo, 2 ) == '34' )
      m1ismo := msmo
      msmo := '34'
      m1company := 34
      mismo := init_ismo( m1ismo )
    Endif
    If m1company == 34
      If !Empty( mismo )
        mcompany := mismo
      Elseif !Empty( mnameismo )
        mcompany := mnameismo
      Endif
    Endif
    If !Empty( mcompany )
      old_name_smo := PadR( mcompany, 38 )
    Endif
    If m1komu > 0
      m1company := 0
      mcompany := ''
      If eq_any( m1komu, 1, 3 )
        m1company := m1str_crb := kart->STR_CRB
        mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
      Endif
    Endif
    mcompany := PadR( mcompany, 38 )
    If eq_any( is_uchastok, 1, 3 )
      s := amb_kartan()
    Elseif mem_kodkrt == 2
      s := lstr( mkod_k )
    Endif
    If !Empty( s ) .and. ValType( MUCH_DOC ) == 'C'
      If Empty( MUCH_DOC )
        MUCH_DOC := PadR( s, 10 )
      Elseif is_uchastok == 3 .and. !( MUCH_DOC == PadR( s, 10 ) )
        MUCH_DOC := PadR( s, 10 )
      Endif
    Endif
    Close databases
  Endif
  RestScreen( buf )

  Return ret

// 24.02.16
Function _f_fio_kart()

  Return PadR( AllTrim( mfio ) + ' ' + iif( mpol == 'М', '(муж.)', '(жен.)' ), 50 )

// 30.12.24
function check_input_INN( get )


  return check_INN_person( get:buffer, .t. )

/*
Алгоритм проверки ИНН1.Алгоритм проверки 10-го значного ИНН.
ИНН.10. 1) Находим произведения первых 9-ти цифр ИНН на специальные множители
           соотственно. 9 множителей ( 2 4 10 3 5 9 4 6 8 ).
ИНН.10. 2) Складываем все 9-ть получившихся произведений.
ИНН.10. 3) Получившуюся сумму делим на число 11 и извлекаем целую часть
           частного от деления.
ИНН.10. 4) Умножаем получившееся число на 11.
ИНН.10. 5) Сравниваем числа получившиеся на шаге 2 и шаге 4, их разница,
           и есть контрольное число, которое и должно равняться 10-й цифре
           в ИНН. (Если контрольное число получилось равным 10-ти, в этом
           случае принимаем контрольное число равным 0.)
*/
// 11.01.25 - функция проверки правильности ввода ИНН для физ.лица (12 знаков)
Function check_INN_person(cInn, is_msg)
  Local a[12], i, val1, v, val2, d11, d12 := -1

  DEFAULT is_msg TO .f.
  if empty(cInn)
//    if is_msg
//      func_error( 4, 'Поле ИНН должно быть заполнено 12-тизначным кодом' )
//    endif
    return .t.    //  .f.
  elseif len(alltrim(cInn)) < 12
    if is_msg
      func_error(4, 'ИНН для физического лица должен быть 12-тизначным')
    endif
    return .f.
  endif
  for i := 1 to 12
    a[i] := int(val(substr(cInn, i, 1)))
  next
  // 1) Находим произведения первых 10-ти цифр ИНН на специальные множители
  //    соотственно (10-ю цифру принимаем за 0 ????????).
  //    10 множителей ( 7 2 4 10 3 5 9 4 6 8 ).
  // 2) Складываем все 10-ть получившихся произведений.
  val1 := a[ 1] * 7 + ;
          a[ 2] * 2 + ;
          a[ 3] * 4 + ;
          a[ 4] * 10 + ;
          a[ 5] * 3 + ;
          a[ 6] * 5 + ;
          a[ 7] * 9 + ;
          a[ 8] * 4 + ;
          a[ 9] * 6 + ;
          a[10] * 8
  // 3) Получившуюся сумму делим на число 11 и извлекаем целую часть
  //    частного от деления.
  // 4) Умножаем получившееся число на 11.
  v := int(int(val1 / 11) * 11)
  // 5) Сравниваем числа получившиеся на шаге 2 и шаге 4, их разница,
  //    и есть первое контрольное число, которое и должно равняться
  //    11-й цифре в ИНН.(Если контрольное число получилось равным 10-ти,
  //    в этом случае принимаем контрольное число равным 0.)
  //    Если получившееся число не не равно 11-ой цифре ИНН, значит
  //    ИНН не верный, если же совпадает, тогда высчитываем следующее
  //    контрольное число, которое должно быть равным 12-ой цифре ИНН
  if (d11 := val1 - v) == 10
    d11 := 0
  endif
  if d11 == a[11]
    // 6) Находим произведения первых 11-ти цифр ИНН на специальные множители
    //    соотственно (10-ю цифру принимаем за 0).
    //    11 множителей ( 3 7 2 4 10 3 5 9 4 6 8 ).
    // 7) Складываем все 11-ть получившихся произведений.
    val2 := a[ 1] * 3 + ;
            a[ 2] * 7 + ;
            a[ 3] * 2 + ;
            a[ 4] * 4 + ;
            a[ 5] * 10 + ;
            a[ 6] * 3 + ;
            a[ 7] * 5 + ;
            a[ 8] * 9 + ;
            a[ 9] * 4 + ;
            a[10] * 6 + ;
            a[11] * 8
    // 8) Получившуюся сумму делим на число 11 и извлекаем целую часть
    //    частного от деления.
    // 9) Умножаем получившееся число на 11.
    v := int(int(val2 / 11) * 11)
    //10) Сравниваем числа получившиеся на шаге 7 и шаге 9, их разница и есть
    //    контрольное число, которое и должно равняться 12-й цифре в ИНН.
    //    (Если контрольное число получилось равным 10-ти, в этом случае
    //    принимаем контрольное число равным 0.) Если высчитанное число
    //    равно 12-ой цифре ИНН, и на первом этапе все контрольное число
    //    совпало с 11-ой цифрой ИНН, следовательно ИНН считается верным.
    if (d12 := val2 - v) == 10
      d12 := 0
    endif
  endif
  if d11 != a[11] .or. d12 != a[12]
    if is_msg
      func_error(2, 'Ошибка в подсчете контрольной суммы ИНН')
    endif
    return .f.
  endif
  return .t.

// 14.09.16 поправить номер полиса из реестров СПТК
Function correct_polis_from_sptk()

  Local ii := 0, jj := 0, fl, buf := save_maxrow()

  stat_msg( "Поиск/попытка исправления полисов в картотеке" )
  Use ( dir_server() + "human_" ) new
  Use ( dir_server() + "human" ) new
  Set Relation To RecNo() into HUMAN_
  Private mdate := SToD( "20190630" )
  Index On Str( kod_k, 7 ) + Str( Descend( k_data ), 10 ) to ( cur_dir() + "tmp_human" ) For k_data > mdate
  use_base( "kartotek",, .t. ) // открываем в монопольном режиме
  Set Order To 2
  find ( "1" )
  Do While kart->kod > 0 .and. !Eof()
    If++ii % 500 == 0
      @ MaxRow(), 0 Say Str( ii / LastRec() * 100, 6, 2 ) + "%" Color cColorStMsg
    Endif
    Select HUMAN
    find ( Str( kart->kod, 7 ) )
    Do While human->kod_k == kart->kod .and. !Eof()
      If !Empty( k_data ) .and. kod > 0 .and. ;
          Between( human_->VPOLIS, 1, 3 ) .and. schet > 0 .and. ; // в счете
        human_->REESTR > 0 .and. Between( human_->smo, '34001', '34007' )
        fl := .f.
        If human_->VPOLIS == kart_->VPOLIS
          fl := !( kart_->NPOLIS == human_->NPOLIS )
        Elseif human_->VPOLIS > kart_->VPOLIS
          fl := .t.
        Endif
        If fl
          kart->POLIS   := make_polis( human_->spolis, human_->npolis )
          kart_->VPOLIS := human_->VPOLIS
          kart_->SPOLIS := human_->SPOLIS
          kart_->NPOLIS := human_->NPOLIS
          If++jj % 2000 == 0
            Commit
          Endif
        Endif
        Exit
      Endif
      Select HUMAN
      Skip
    Enddo
    Select KART
    Skip
  Enddo
  Close databases
  rest_box( buf )
  Return Nil

