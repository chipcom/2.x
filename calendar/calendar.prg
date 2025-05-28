#include 'function.ch'

// 20.01.23 �஢��塞 ���� �� �宦����� � ��ਮ�, �����⨬� ���⮥ ���祭�� ����筮� ����
Function correct_date_dictionary( dt, date_begin, date_end )

  Return ( ( date_begin <= dt ) .and. ( Empty( date_end ) .or. date_end >= dt ) )

// 28.05.25
Function between_date_new( begin_date, end_date, checking_date )

  Local fl := .f.

  Default date1 To Date() //sys_date  // �� 㬮�砭�� �஢��塞 �� ᥣ����譨� ������
  If Empty( begin_date ) .and. Empty( end_date )
    Return fl
  Endif
  If ! Empty( begin_date ) .and. Empty( end_date ) .and. ( begin_date < checking_date )
    fl := .t.
  Endif
  If ( ! Empty( begin_date ) ) .and. ( ! Empty( end_date ) ) .and. ( begin_date <= checking_date ) .and. ( _end_date >= checking_date )
    fl := .t.
  Endif
  Return fl

// �������� �� date1 (�������� date1-date2) � �������� _begin_date-_end_date
Function between_date( _begin_date, _end_date, date1, date2, impossiblyEmptyRange )
  // _begin_date - ��砫� ����⢨�
  // _end_date   - ����砭�� ����⢨�
  // date1 - �஢��塞�� ���
  // date2 - ���� ��� ��������� (�᫨ = NIL, � �஢��塞 ⮫쪮 �� date1)
  // impossiblyEmptyRange - �᫨ .t. ���⮩ �������� ��� �� �����⨬
  Local fl := .f., fl2

  // �஢�ਬ �� �������⨬���� ���⮣� ��������� ���
  If ! HB_ISNIL( impossiblyEmptyRange ) .and. impossiblyEmptyRange
    If Empty( _begin_date ) .and. Empty( _end_date )
      Return fl
    Endif
  Endif
  Default date1 To Date() //sys_date  // �� 㬮�砭�� �஢��塞 �� ᥣ����譨� ������
  If Empty( _begin_date )
    _begin_date := SToD( '19930101' )  // �᫨ ��砫� ����⢨� = ����, � 01.01.1993
  Endif
  // �஢�ઠ ���� date1 �� ��������� � ��������
  If ( fl := ( date1 >= _begin_date ) ) .and. !Empty( _end_date )
    fl := ( date1 <= _end_date )
  Endif
  // �஢�ઠ ��������� date1-date2 �� ����祭�� � ����������
  If ValType( date2 ) == 'D'
    If ( fl2 := ( date2 >= _begin_date ) ) .and. !Empty( _end_date )
      fl2 := ( date2 <= _end_date )
    Endif
    fl := ( fl .or. fl2 )
  Endif
  Return fl

// 20.04.21 ��।����� ��� ���� 㪠������� ������
Function ageismorethan( age, DOB, dataCalc )

  Return count_years( DOB, dataCalc ) >= age

// 23.12.18 ������⢮ ���, ����楢 � ���� � ��ப�
Function count_ymd( _mdate, _sys_date, /*@*/y, /*@*/m, /*@*/d)
  // _mdate    - ��� ��� ��।������ ������⢠ ���, ����楢 � ����
  // _sys_date - '��⥬���' ���
  Local ret_s := '', md := _mdate

  y := m := d := 0
  If !Empty( _sys_date ) .and. !Empty( _mdate ) .and. _sys_date > _mdate
    Do While ( md := AddMonth( md, 12 ) ) <= _sys_date
      ++y
    Enddo
    If y > 0 .and. correct_count_ym( _mdate, _sys_date )
      --y
    Endif
    md := AddMonth( _mdate, 12 * y )
    Do While ( md := AddMonth( md, 1 ) ) <= _sys_date
      ++m
    Enddo
    If m > 0 .and. correct_count_ym( _mdate, _sys_date, 2 )
      --m
    Endif
    md := AddMonth( _mdate, 12 * y + m )
    Do While ( md := md + 1 ) <= _sys_date
      ++d
    Enddo
    If !emptyall( y, m ) .and. d > 0 // ⮫쪮 �� ��� ����஦�������
      --d
    Endif
  Endif
  If y > 0
    ret_s := lstr( y ) + ' ' + s_let( y ) + ' '
  Endif
  If m > 0
    ret_s += lstr( m ) + ' ' + mes_cev( m ) + ' '
  Endif
  If d > 0
    ret_s += lstr( d ) + ' ' + dnej( d )
  Endif
  Return RTrim( ret_s )

// 23.12.18 ��।������ ������⢠ ����楢 �� ��� (������ �᫠)
Function count_months( _mdate, _sys_date )
  // _mdate    - ��� ��� ��।������ ������⢠ ���
  // _sys_date - '��⥬���' ���
  Local k := 0, md := _mdate

  If !Empty( _sys_date ) .and. !Empty( _mdate ) .and. _sys_date > _mdate
    Do While ( md := AddMonth( md, 1 ) ) <= _sys_date
      k++
    Enddo
    If k > 0 .and. correct_count_ym( _mdate, _sys_date, 2 )
      --k
    Endif
  Endif
  Return k

// 22.07.18 ��।������ ������⢠ ��� �� ��� (������ �᫠)
Function count_years( _mdate, _sys_date )
  // _mdate    - ��� ��� ��।������ ������⢠ ���
  // _sys_date - '��⥬���' ���
  Local k := 0, md := _mdate

  If !Empty( _sys_date ) .and. !Empty( _mdate ) .and. _sys_date > _mdate
    Do While ( md := AddMonth( md, 12 ) ) <= _sys_date
      k++
    Enddo
    If k > 0 .and. correct_count_ym( _mdate, _sys_date )
      --k
    Endif
  Endif
  Return k

// 14.06.13 ��।������ ������⢠ ��� �� ��� (������ ��ப�)
Function ccount_years( _mdate, _sys_date )
  // _mdate    - ��� ��� ��।������ ������⢠ ������ ���
  // _sys_date - '��⥬���' ���
  Local ret_s := '', y

  If ( y := count_years( _mdate, _sys_date ) ) > 0
    ret_s := lstr( y ) + ' ' + s_let( y )
  Endif
  Return ret_s

// 23.12.18 ��� ��⠥��� ���⨣訬 ��।��񭭮�� ������ �� � ���� ஦�����, � ��稭�� � ᫥����� ��⮪
Function correct_count_ym( _mdate, _sys_date, y_m )
  Local s1 := Right( DToS( _mdate ), 4 ), s2 := Right( DToS( _sys_date ), 4 ), fl := .f.

  Default y_m To 1
  If s1 == s2 // �஢��塞 ࠢ���⢮ ��� � �����
    fl := .t.
  Elseif s1 == '0229' .and. s2 == '0228' .and. !IsLeap( _sys_date ) // _mdate - ��᮪��� ���, � _sys_date - ���
    fl := .t.
  Elseif y_m == 2 .and. Right( s1, 2 ) == Right( s2, 2 ) // �஢��塞 ࠢ���⢮ ��� (��� ���-�� ���-�� ����楢)
    fl := .t.
  Endif
  Return fl

// 28.07.16 �������� ��⥬��� ���� (��� ࠡ����� �� ��砬 �ࠢ��㭪⮢)
Function change_sys_date()

  sys_date := Date()
  sys1_date := sys_date
  c4sys_date := dtoc4( sys1_date )
  Return Nil
