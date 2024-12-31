#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

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
    r_use( dir_server + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartotek', , 'KART' )
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
    mokato      := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
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
// 30.12.24 - функция проверки правильности ввода ИНН для физ.лица (12 знаков)
Function check_INN_person(cInn, is_msg)
  Local a[12], i, val1, v, val2, d11, d12 := -1

  DEFAULT is_msg TO .f.
  if empty(cInn)
    if is_msg
      func_error( 4, 'Поле ИНН должно быть заполнено 12-тизначным кодом' )
    endif
    return .f.
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
