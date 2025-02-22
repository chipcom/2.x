#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 22.02.25
function is_work_day_new( mdate )

return ( AScan( getArrayHoliday( Year( mdate ) )[ Month( mdate ), 2 ], Day( mdate ) ) == 0 )

// 21.02.25
function getArrayHoliday( mYear )

  static hArray
  Local db
  local arr := {}, aTable, nI
  local nameView, strSQL, standart, fl := .f.

  if hArray == nil
    hArray := hb_Hash()
  Endif

  if ! hb_hHaskey( hArray, mYear )
    standart := {}
    nameView := 'year' + str( mYear, 4 )
  
    db := opensql_db()
    strSQL := 'SELECT m_month, description FROM ' + nameView // + ' WHERE m_month=' + alltrim( str( Month( mYear ), 4 ) )
    aTable := sqlite3_get_table( db, strSQL )
    If Len( aTable ) > 1

      For nI := 2 To Len( aTable )
        hb_jsonDecode( alltrim( aTable[ nI, 2 ] ), @standart )
        AAdd( arr, { val( aTable[ nI, 1 ] ), standart } )
        fl := .t.
      Next
      hb_HSet( hArray, mYear, arr )
    Endif
    db := nil
  else
    fl := .t.
  endif

  if fl
    arr := hArray[ mYear ]
  endif
  return arr

// 25.12.24
function check_next_visit_dn( gt, du )

  // gt - объект getlist
  // du - дата услуги

  local dt, addOneMonth, addOneYear
  local lRet := .f.

  dt := CToD( gt:buffer )

  addOneMonth := AddMonth( du, 1 )
  addOneYear := AddMonth( du, 12 )

  if addOneMonth <= dt .and. dt <= addOneYear
    lRet := .t.
  else
    func_error( 4, 'Дата следующей явки допустима от одного месяца до одного года!' )
  endif
  return lRet

// 18.02.20
Function year_month( rr, cc, za_v, kmp, ch_mm, ret_time )
  // kmp = от 1 до 4(5) или массив {3,4}
  // za_v = .t. - строка в винит.падеже
  // za_v = .f. - строка в творит.падеже
  Local mas2_pmt := { 'За ~день', 'В диапа~зоне дат', 'За ~месяц', 'За ~период' }
  Local ky, km, kp, ret_arr, buf, s_mes_god, ret_year, dekad_date, blk, ;
    begin_date, end_date, old_set, fl, ar, r1, c1, r2, c2
  Local i, sy, smp, sm, mbeg, mend, sdate, sdek, s1date, s1time, s2time

  ar := getinisect( tmp_ini, 'ymonth' )
  sy     := Int( Val( a2default( ar, 'sy', lstr( Year( sys_date ) ) ) ) )
  sm     := Int( Val( a2default( ar, 'sm', lstr( Month( sys_date ) ) ) ) )
  smp    := Int( Val( a2default( ar, 'smp', '3' ) ) )
  mbeg   := Int( Val( a2default( ar, 'mbeg', '1' ) ) )
  mend   := Int( Val( a2default( ar, 'mend', lstr( sm ) ) ) )
  sdate  := SToD( a2default( ar, 'sdate', DToS( sys_date ) ) )
  s1date := SToD( a2default( ar, 's1date', DToS( sys_date ) ) )
  sdek   := Int( Val( a2default( ar, 'sdek', '1' ) ) )
  s1time := a2default( ar, 's1time', '00:00' )
  s2time := a2default( ar, 's2time', '24:00' )
  Default za_v To .t., rr To T_ROW, cc To T_COL - 5, ch_mm To 1
  ret_time := {, }
  Private k1, k2
  ym_kol_mes := 0  // определить количество месяцев
  If kmp == Nil .and. ( kmp := popup_prompt( rr, cc, smp, mas2_pmt ) ) == 0
    Return Nil
  Elseif ValType( kmp ) == 'A' // специально только третья и четвёртая строки меню
    If ( i := popup_prompt( rr, cc, smp - 2, { 'За ~месяц', 'За ~период' } ) ) == 0
      Return Nil
    Endif
    kmp := i + 2
  Endif
  Store 0 To r1, c1, r2, c2
  If eq_any( kmp, 3, 4 )
    get_row_col_max( 20, 15, @r1, @c1, @r2, @c2 )
    If ( ky := input_value( r1, c1, r2, c2, color1, 'За какой год желаете получить информацию', sy, '9999' ) ) == NIL
      Return Nil
    Endif
    ret_year := sy := ky
  Endif
  smp := iif( kmp == 5, 2, kmp )
  If kmp == 1
    get_row_col_max( 18, 5, @r1, @c1, @r2, @c2 )
    If ( dekad_date := input_value( r1, c1, r2, c2, color1, ;
        'Введите дату, за которую необходимо получить информацию', ;
        CToD( Left( DToC( sdate ), 6 ) + lstr( sy ) ) ) ) == NIL
      Return Nil
    Endif
    sdate := dekad_date
    sy := ret_year := Year( sdate )
    begin_date := end_date := dtoc4( sdate )
  Elseif eq_any( kmp, 2, 5 ) .and. ch_mm == 1
    begin_date := if( s1date > sdate, sdate, s1date )
    If kmp == 5
      begin_date := BoY( begin_date )
      kmp := 2
      If Type( 'b_year_month' ) == 'D' .and. Type( 'e_year_month' ) == 'D'
        begin_date := b_year_month ; sdate := e_year_month
      Endif
      Keyboard Chr( K_ENTER )
    Endif
    blk := {| x, y| if( x > y, func_error( 4, 'Начальная дата больше конечной!' ), .t. ) }
    get_row_col_max( 18, 0, @r1, @c1, @r2, @c2 )
    km := input_diapazon( r1, c1, r2, c2, cDataCGet, ;
      { 'Введите начальную', 'и конечную', 'даты для получения инф-ии' }, ;
      { begin_date, sdate },, blk )
    If km == NIL
      Return Nil
    Endif
    s1date := km[ 1 ] ; sdate := km[ 2 ]
    sy := ret_year := Year( sdate )
    begin_date := dtoc4( s1date ) ; end_date := dtoc4( sdate )
  Elseif kmp == 2 .and. ch_mm == 2
    Private m1date := s1date, m2date := sdate, m1time := s1time, m2time := s2time
    SetColor( cDataCGet )
    get_row_col_max( 18, 12, @r1, @c1, @r2, @c2 )
    buf := box_shadow( r1, c1, r2, c2 )
    fl := .f.
    Do While .t.
      @ r1 + 1, c1 + 1 Say 'Период времени: с' Get m1date
      @ Row(), Col() Say '/'
      @ Row(), Col() Get m1time Pict '99:99'
      @ Row(), Col() Say ' по' Get m2date
      @ Row(), Col() Say '/'
      @ Row(), Col() Get m2time Pict '99:99'
      myread( { 'confirm' } )
      If LastKey() != K_ESC
        If !v_date_time( m1date, m1time, m2date, m2time )
          Loop
        Endif
        s1date := m1date ; sdate := m2date
        sy := ret_year := Year( sdate )
        begin_date := dtoc4( s1date ) ; end_date := dtoc4( sdate )
        s1time := m1time ; s2time := m2time
        ret_time := { s1time, s2time }
        fl := .t.
      Endif
      Exit
    Enddo
    SetColor( color0 )
    rest_box( buf )
    If !fl
      Return Nil
    Endif
  Elseif kmp == 3
    If rr + 12 + 1 > MaxRow() -2
      rr := MaxRow() -12 -3
    Endif
    If ( km := popup_prompt( rr, cc, sm, mm_month ) ) == 0
      Return Nil
    Endif
    sm := km
    k1 := k2 := km
    ym_kol_mes := 1
  Elseif kmp == 4
    SetColor( color1 )
    get_row_col_max( 20, 10, @r1, @c1, @r2, @c2 )
    buf := box_shadow( r1, c1, r2, c2 )
    k1 := mbeg;  k2 := mend
    If k1 > k2
      k1 := k2
    Endif
    @ r1 + 1, c1 + 2 Say 'Введите начальный и конечный месяцы для периода' Get k1 Picture '99' valid {|| k1 >= 0 }
    @ Row(), Col() + 1 Say '-' Get k2 Picture '99' valid {|| k1 <= k2 .and. k2 <= 12 }
    myread( { 'confirm' } )
    rest_box( buf )
    If LastKey() == K_ESC
      SetColor( color0 )
      Return Nil
    Endif
    mbeg := k1;  mend := k2
    ym_kol_mes := k2 - k1 + 1
  Endif
  If za_v
    If kmp == 1
      s_mes_god := 'за ' + date_month( dekad_date, .t. )
    Elseif kmp == 2 .and. ch_mm == 1
      s_mes_god := 'в диапазоне дат от ' + date_8( s1date ) + 'г. по ' + date_8( sdate ) + 'г.'
    Elseif kmp == 2 .and. ch_mm == 2
      s_mes_god := 'с ' + date_8( s1date ) + '(' + s1time + ') по ' + date_8( sdate ) + '(' + s2time + ')'
    Else
      Do Case
      Case k1 == k2
        s_mes_god := 'за ' + mm_month[ k1 ] + ' месяц'
      Case k1 == 1 .and. k2 == 3
        s_mes_god := 'за I квартал'
      Case k1 == 4 .and. k2 == 6
        s_mes_god := 'за II квартал'
      Case k1 == 7 .and. k2 == 9
        s_mes_god := 'за III квартал'
      Case k1 == 10 .and. k2 == 12
        s_mes_god := 'за IV квартал'
      Case k1 == 1 .and. k2 == 6
        s_mes_god := 'за 1-ое полугодие'
      Case k1 == 7 .and. k2 == 12
        s_mes_god := 'за 2-ое полугодие'
      Case k1 == 1 .and. k2 == 12
        s_mes_god := ''
      Otherwise
        s_mes_god := 'за период с ' + lstr( k1 ) + '-го по ' + lstr( k2 ) + '-й месяцы'
      Endcase
      If k1 == 1 .and. k2 == 12
        s_mes_god := 'за' + Str( ret_year, 5 ) + ' год'
      Else
        s_mes_god += Str( ret_year, 5 ) + ' года'
      Endif
    Endif
  Else
    If kmp == 1
      s_mes_god := date_month( dekad_date, .t. )
    Elseif kmp == 2 .and. ch_mm == 1
      s_mes_god := 'в диапазоне дат от ' + date_8( s1date ) + 'г. по ' + date_8( sdate ) + 'г.'
    Elseif kmp == 2 .and. ch_mm == 2
      s_mes_god := 'с ' + date_8( s1date ) + '(' + s1time + ') по ' + date_8( sdate ) + '(' + s2time + ')'
    Else
      Do Case
      Case k1 == k2
        s_mes_god := 'в ' + mm_monthR[ k1 ] + ' месяце'
      Case k1 == 1 .and. k2 == 3
        s_mes_god := 'в I квартале'
      Case k1 == 4 .and. k2 == 6
        s_mes_god := 'во II квартале'
      Case k1 == 7 .and. k2 == 9
        s_mes_god := 'в III квартале'
      Case k1 == 10 .and. k2 == 12
        s_mes_god := 'в IV квартале'
      Case k1 == 1 .and. k2 == 6
        s_mes_god := 'в 1-ом полугодии'
      Case k1 == 7 .and. k2 == 12
        s_mes_god := 'во 2-ом полугодии'
      Case k1 == 1 .and. k2 == 12
        s_mes_god := ''
      Otherwise
        s_mes_god := 'в период с ' + lstr( k1 ) + '-го по ' + lstr( k2 ) + '-й месяцы'
      Endcase
      If k1 == 1 .and. k2 == 12
        s_mes_god := 'в' + Str( ret_year, 5 ) + ' году'
      Else
        s_mes_god += Str( ret_year, 5 ) + ' года'
      Endif
    Endif
  Endif
  If kmp > 2
    begin_date := end_date := Chr( Int( Val( Left( Str( ret_year, 4 ), 2 ) ) ) ) + Chr( Int( Val( SubStr( Str( ret_year, 4 ), 3 ) ) ) )
    begin_date += Chr( k1 ) + Chr( 1 )
    end_date += Chr( k2 ) + Chr( 1 )
    end_date := dtoc4( EoM( c4tod( end_date ) ) )
  Endif
  setinisect( tmp_ini, 'ymonth', ;
    { { 'sy', lstr( sy ) }, { 'sm', lstr( sm ) }, { 'smp', lstr( smp ) }, ;
    { 'mbeg', lstr( mbeg ) }, { 'mend', lstr( mend ) }, { 'sdate', DToS( sdate ) }, ;
    { 's1date', DToS( s1date ) }, { 'sdek', lstr( sdek ) }, ;
    { 's1time', s1time }, { 's2time', s2time } } )

  Return { ret_year, k1, k2, s_mes_god, c4tod( begin_date ), c4tod( end_date ), begin_date, end_date }

// 26.09.13 запрос года
Function input_year()
  Local ky, begin_date, end_date, r1, c1, r2, c2

  Store 0 To r1, c1, r2, c2
  get_row_col_max( 20, 15, @r1, @c1, @r2, @c2 )
  If ( ky := input_value( r1, c1, r2, c2, color1, 'За какой год желаете получить информацию', Year( sys_date ), '9999' ) ) == NIL
    Return Nil
  Endif
  begin_date := end_date := Chr( Int( Val( Left( Str( ky, 4 ), 2 ) ) ) ) + Chr( Int( Val( SubStr( Str( ky, 4 ), 3 ) ) ) )
  begin_date += Chr( 1 ) + Chr( 1 )
  end_date += Chr( 12 ) + Chr( 1 )
  end_date := dtoc4( EoM( c4tod( end_date ) ) )

  Return { ky, 1, 12, 'за' + Str( ky, 5 ) + ' год', c4tod( begin_date ), c4tod( end_date ), begin_date, end_date }

// 18.01.22 функция выбора используемых дат из диапазона
Function select_arr_days( begin_date, end_date )
  // // begin_date: начало диапазона
  // // end_date: конец диапазона
  // // возвращаемое значение: двумерный массив выбранных дат (1 колонка-дата в формате строки, 2 колонка-дата в формате даты), или NIL
  Local arr, arr1
  Local d, r

  If end_date >= begin_date
    arr1 := {}
    For d := begin_date To end_date
      AAdd( arr1, { date_8( d ), d } )
    Next
    If ( r := 21 - Len( arr1 ) ) < 2
      r := 2
    Endif
    arr := bit_popup( r, 63, arr1, , color5 )
  Endif

  Return arr

// 24.05.22 количество дней между датами
Function count_days( d1, d2 )
  Local mdni

  If d1 <= d2
    mdni := d2 - d1 + 1
  Endif

  Return mdni

// 16.02.2020 является ли выходным (праздничным) днём проведения диспансеризации
Function f_is_prazdnik_dvn( _n_data )
  Return !is_work_day( _n_data )
