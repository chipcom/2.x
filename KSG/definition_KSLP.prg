#include 'function.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

// 27.02.21
Function buildstringkslp( row )

  // row - одномерный массив описывающий КСЛП
  Local ret

  ret := Str( row[ CODE_KSLP ], 2 ) + '.' + row[ NAME_KSLP ]

  Return ret

// 15.02.25 функция выбора состава КСЛП, возвращает { маска,строка количества КСЛП }, или nil
Function selectkslp( lkslp, savedKSLP, dateBegin, dateEnd, DOB, mdiagnoz )

  // lkslp - значение КСЛП (выбранные КСЛП)
  // savedKSLP - сохраненное в HUMAN_2 КСЛП или пусто
  // dateBegin - дата начала законченного случая
  // dateEnd - дата окончания законченного случая
  // DOB - дата рождения пациента
  // mdiagnoz - список выбранных диагнозов

  Local mlen, t_mas := {}, ret, ;
    i, tmp_select := Select()
  Local r1 := 0 // счетчик записей
  Local strArr := '', age

  Local m1var := '', s := '', countKSLP := 0
  Local row
  Local nLast, srok := dateEnd - dateBegin
  Local permissibleKSLP := {}, isPermissible
  Local sAsterisk := ' * ', sBlank := '   '
  Local fl := .f.

  Local aKSLP := getkslptable( dateEnd )  // список допустимых КСЛП для услуги
  Local aa := list2arr( savedKSLP ) // получим массив выбранных КСЛП

  Default DOB To sys_date
  Default dateBegin To sys_date
  Default dateEnd To sys_date

  permissibleKSLP := list2arr( lkslp )

  age := count_years( DOB, dateEnd )

  For Each row in aKSLP
    r1++

    isPermissible := AScan( permissibleKSLP, row[ CODE_KSLP ] ) > 0

    If ( AScan( aa, {| x| x == row[ CODE_KSLP ] } ) > 0 ) .and. isPermissible
      strArr := sAsterisk
    Else
      strArr := sBlank
    Endif
    If ( row[ CODE_KSLP ] == 3 .and. Year( dateEnd ) == 2023 ) ;    // старше 75 лет
      .or. ( row[ CODE_KSLP ] == 3 .and. Year( dateEnd ) == 2022 ) ;
        .or. ( row[ CODE_KSLP ] == 1 .and. Year( dateEnd ) == 2021 )
      If ( age >= 75 ) .and. ( Year( dateEnd ) == 2021 ) .and. isPermissible
        strArr := sAsterisk
        strArr += buildstringkslp( row )
      Elseif ( age >= 75 ) .and. ( Year( dateEnd ) == 2022 ) .and. isPermissible
        strArr += buildstringkslp( row )
      Else
        strArr := sBlank
        strArr += buildstringkslp( row )
      Endif
      AAdd( t_mas, { strArr, ( age >= 75 ), row[ CODE_KSLP ] } )
    Elseif ( ( row[ CODE_KSLP ] == 1 .and. Year( dateEnd ) == 2023 ) .or. ;
        ( row[ CODE_KSLP ] == 2 .and. Year( dateEnd ) == 2023 ) .or. ;
        ( row[ CODE_KSLP ] == 1 .and. Year( dateEnd ) == 2022 ) .or. ;
        ( row[ CODE_KSLP ] == 2 .and. Year( dateEnd ) == 2022 ) .or. ;
        ( row[ CODE_KSLP ] == 3 .and. Year( dateEnd ) == 2021 ) ) ;
        .and. isPermissible  // место законному представителю
      If ( age < 4 )
        strArr := sAsterisk
        strArr += buildstringkslp( row )
      Elseif ( age < 18 )
        strArr += buildstringkslp( row )
      Else
        strArr := sBlank
        strArr += buildstringkslp( row )
      Endif
      AAdd( t_mas, { strArr, ( age < 18 ), row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 4 .and. Year( dateEnd ) == 2021 ) .and. isPermissible  // иммунизация РСВ
      If ( age < 18 )
        strArr += buildstringkslp( row )
      Else
        strArr := sBlank
        strArr += buildstringkslp( row )
      Endif
      AAdd( t_mas, { strArr, ( age < 18 ), row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 9 .and. Year( dateEnd ) == 2021 ) // есть сопутствующие заболевания
      fl := conditionkslp_9_21(, DToC( DOB ), DToC( dateBegin ),,,, arr2slistn( mdiagnoz ), )
      If !fl
        strArr := sBlank
      Else
        // strArr := sAsterisk
      Endif
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, fl, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 10 .and. Year( dateEnd ) == 2021 ) .and. isPermissible // лечение свыше 70 дней согласно инструкции
      strArr := iif( srok > 70, sAsterisk, sBlank )
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, .f., row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 19 .and. Year( dateEnd ) == 2023 ) .and. isPermissible  // проведение 1 этапа медицинской реабилитации пациентов
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 20 .and. Year( dateEnd ) == 2023 ) .and. isPermissible   // проведение сопроводительной лекарственной терапии
      // при злокачественных новообразованиях у взрослых в
      // стационарных условиях в соответствии с клиническими рекомендациями
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 21 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // развертывание индивидуального поста
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 22 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // наличие у пациента тяжелой сопутствующей
      // патологии, требующей оказания медицинской
      // помощи в период госпитализации
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 23 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение сочетанных хирургических
      // вмешательств или проведение
      // однотипных операций на парных органах (уровень 1)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 24 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение сочетанных хирургических
      // вмешательств или проведение
      // однотипных операций на парных органах (уровень 2)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 25 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение сочетанных хирургических
      // вмешательств или проведение
      // однотипных операций на парных органах (уровень 3)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 26 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение сочетанных хирургических
      // вмешательств или проведение
      // однотипных операций на парных органах (уровень 4)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 27 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение сочетанных хирургических
      // вмешательств или проведение
      // однотипных операций на парных органах (уровень 5)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 28 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение сопроводительной
      // лекарственной терапии при злокачественных
      // новообразованиях у взрослых в условиях дневного
      // стационара в соответствии с клиническими рекомендациями
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 29 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // проведение тестирования на выявление
      // респираторных вирусных заболеваний (гриппа,
      // новой коронавирусной инфекции COVID-19) в период госпитализации
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Else
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Endif
  Next

  strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'

  mlen := Len( t_mas )

  // используем popupN из библиотеки FunLib
  If ( ret := popupn( 4, 10, 4 + mlen + 1, 71, t_mas, i, color0, .t., 'fmenu_readerN', , ;
      'Отметьте КСЛП', col_tit_popup,, strStatus ) ) > 0
    For i := 1 To mlen
      If '*' == SubStr( t_mas[ i, 1 ], 2, 1 )
        m1var += AllTrim( Str( t_mas[ i, 3 ] ) ) + ','
        countKSLP += 1
      Endif
    Next
    If ( nLast := RAt( ',', m1var ) ) > 0
      m1var := SubStr( m1var, 1, nLast -1 )  // удалим последнюю не нужную ','
    Endif
    s := m1var
  Endif

  Select( tmp_select )

  Return s

// 13.01.22 если надо, перезаписать значения КСЛП и КИРО в HUMAN_2
Function put_str_kslp_kiro( arr, fl )

  Local lpc1 := '', lpc2 := ''

  If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
    If Year( human->k_data ) < 2021  // added 29.01.21
      lpc1 := lstr( arr[ 5, 1 ] ) + ',' + lstr( arr[ 5, 2 ], 5, 2 )
      If Len( arr[ 5 ] ) >= 4
        lpc1 += ',' + lstr( arr[ 5, 3 ] ) + ',' + lstr( arr[ 5, 4 ], 5, 2 )
      Endif
    Endif
  Endif
  If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
    lpc2 := lstr( arr[ 6, 1 ] ) + ',' + lstr( arr[ 6, 2 ], 5, 2 )
  Endif
  If !( PadR( lpc1, 20 ) == human_2->pc1 .and. PadR( lpc2, 10 ) == human_2->pc2 )
    Default fl To .t. // блокировать и разблокировать запись в HUMAN_2
    Select HUMAN_2
    If fl
      g_rlock( forever )
    Endif

    // запомним новое КСЛП
    tmSel := Select( 'HUMAN_2' )
    If ( tmSel )->( dbRLock() )
      If Year( human->k_data ) < 2021  // added 29.01.21
        human_2->pc1 := lpc1
      Endif
      human_2->pc2 := lpc2
      ( tmSel )->( dbRUnlock() )
    Endif
    Select( tmSel )
    If fl
      Unlock
    Endif
  Endif

  Return Nil

// 04.02.21 возвращает сумму итогового КСЛП по маске КСЛП и дате случая
Function calckslp( cKSLP, dateSl )

  // cKSLP - строка выбранных КСЛП
  // dateSl - дата законченного случая
  Local summ := 1, i
  Local fl := .f.
  Local arrKSLP := getkslptable( dateSl )
  Local maxKSLP := 1.8  // по инструкции на 21 год
  Local aSelected := slist2arr( cKSLP )

  For i := 1 To Len( aSelected )
    summ += ( arrKSLP[ Val( aSelected[ i ] ), 4 ] -1 )
  Next
  If summ > maxKSLP
    summ := maxKSLP
  Endif

  Return summ

// 15.02.25 определить коэф-т сложности лечения пациента и пересчитать цену
Function f_cena_kslp( /*@*/_cena, _lshifr, _date_r, _n_data, _k_data, lkslp, arr_usl, lPROFIL_K, arr_diag, lpar_org, lad_cr, usl_ok )

  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  Static s_20 := 0d20201231
  Static s_kslp17 := { ;
    { 1, 1.1, 0,  3 }, ;   // до 4 лет
    { 2, 1.1, 75, 999 } ;    // 75 лет и старше
    }
  Static s_kslp16 := { ;
    { 1, 1.1, 0,  3 }, ;   // до 4 лет
    { 2, 1.05, 75, 999 } ;    // 75 лет и старше
    }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  Local countDays := _k_data - _n_data // кол-во дней лечения

  Local savedKSLP, newKSLP := '', nLast
  Local nameFunc := '', argc, row

  Default lad_cr To Space( 10 )

  _lshifr := AllTrim( _lshifr ) // перенес

  If _k_data > s_20
    If Empty( lkslp )
      Return _akslp
    Endif
    // п.3 инструкции
    // Возраст пациента определяется на момент поступления на стационарное лечение.
    // Все случаи применения КСЛП (за исключением КСЛП1) подвергаются экспертному контролю.
    count_ymd( _date_r, _n_data, @y )
    lkslp := list2arr( lkslp )  // преобразуем строку допустимых КСЛП в массив

    savedKSLP := iif( Empty( HUMAN_2->PC1 ), '"' + '"', '"' + AllTrim( HUMAN_2->PC1 ) + '"' )  // получим сохраненные КСЛП

    argc := '(' + savedKSLP + ',' + ;
      '"' + DToC( _date_r ) + '",' + '"' + DToC( _k_data ) + '",' + ;
      lstr( lPROFIL_K ) + ',' + '"' + _lshifr + '",' + lstr( lpar_org ) + ',' + ;
      '"' + arr2slistn( arr_diag ) + '",' + lstr( countDays ) + ',' + lstr( usl_ok ) + ',"' + ;
      + AllTrim( lad_cr ) + '")'

    For Each row in getkslptable( _k_data )
      nameFunc := 'conditionKSLP_' + AllTrim( Str( row[ 1 ], 2 ) ) + '_' + last_digits_year( _k_data )
      nameFunc := namefunc + argc

      If AScan( lkslp, row[ 1 ] ) > 0 .and. &nameFunc
        newKSLP += AllTrim( Str( row[ 1 ], 2 ) ) + ','
        AAdd( _akslp, row[ 1 ] )
        AAdd( _akslp, row[ 4 ] )
      Endif
    Next
    If ( nLast := RAt( ',', newKSLP ) ) > 0
      newKSLP := SubStr( newKSLP, 1, nLast -1 )  // удалим последнюю не нужную ','
    Endif
    // установим цену с учетом КСЛП
    If !Empty( _akslp )

      If Year( _k_data ) == 2021
        _cena := round_5( _cena * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )  // с 2019 года цена округляется до рублей
      Elseif Year( _k_data ) >= 2022
        _cena := round_5( _cena + baserate( _k_data, human_->USL_OK ) * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )
//      Elseif Year( _k_data ) == 2023  // сообщил Мызгин 01.02.23
//        _cena := round_5( _cena + baserate( _k_data, human_->USL_OK ) * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )
//      Elseif Year( _k_data ) == 2024
//        _cena := round_5( _cena + baserate( _k_data, human_->USL_OK ) * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )
      Endif

      If Year( _k_data ) >= 2021
        // запомним новое КСЛП
        tmSel := Select( 'HUMAN_2' )
        If ( tmSel )->( dbRLock() )
          If Year( human->k_data ) < 2021  // added 29.01.21
            human_2->pc1 := newKSLP
          Endif
          ( tmSel )->( dbRUnlock() )
        Endif
        Select( tmSel )
      Endif
    Endif

  Elseif _k_data > s_19  // с 2019 года
    If !Empty( lkslp )
      If _lshifr == 'ds02.005' // ЭКО, lkslp = 12,13,14
        s_kslp := { ;
          { 12, 0.60 }, ;
          { 13, 1.10 }, ;
          { 14, 0.19 } ;
          }
        For i := 1 To Len( arr_usl )
          If ValType( arr_usl[ i ] ) == 'A'
            AAdd( ausl, AllTrim( arr_usl[ i, 1 ] ) )  // массив многомерный
          Else
            AAdd( ausl, AllTrim( arr_usl[ i ] ) )    // массив одномерный
          Endif
        Next i
        j := 0 // КСЛП - 1 схема
        If AScan( ausl, 'A11.20.031' ) > 0  // крио
          j := 13  // 6 схема
          If AScan( ausl, 'A11.20.028' ) > 0 // третий этап
            j := 0   // 2 схема
          Endif
        Elseif AScan( ausl, 'A11.20.025.001' ) > 0  // первый этап
          j := 12  // 3 схема
          If AScan( ausl, 'A11.20.036' ) > 0  // завершающий второй этап
            j := 12  // 4 схема
          Elseif AScan( ausl, 'A11.20.028' ) > 0  // завершающий третий этап
            j := 12  // 5 схема
          Endif
        Elseif AScan( ausl, 'A11.20.030.001' ) > 0  // только четвертый этап
          j := 14  // 7 схема
        Endif
        If ( i := AScan( s_kslp, {| x| x[ 1 ] == j } ) ) > 0
          AAdd( _akslp, s_kslp[ i, 1 ] )
          AAdd( _akslp, s_kslp[ i, 2 ] )
          _cena := round_5( _cena * s_kslp[ i, 2 ], 0 )  // с 2019 года цена округляется до рублей
        Endif
        If !Empty( _akslp ) .and. _k_data > 0d20191231 // с 2020 года
          _akslp[ 1 ] += 3 // т.е. с 2020 года КСЛП для ЭКО 15,16,17
        Endif
      Else // остальные КСГ
        s_kslp := { ;
          { 1, 1.10, 0,  0 }, ;  // до 1 года
          { 2, 1.10, 1,  3 }, ;  // от 1 до 3 лет включительно
          { 4, 1.02, 75, 999 }, ;  // 75 и старше
          { 5, 1.10, 60, 999 } ;   // 60 и старше и астения
        }
        count_ymd( _date_r, _n_data, @y )
        lkslp := list2arr( lkslp )
        For j := 1 To Len( lkslp )
          If ( i := AScan( s_kslp, {| x| x[ 1 ] == lkslp[ j ] } ) ) > 0 // стоит данный КСЛП в выбранной КСГ
            If Between( y, s_kslp[ i, 3 ], s_kslp[ i, 4 ] )
              fl := .t.
              If lkslp[ j ] == 4
                fl := ( lprofil_k != 16 ; // пациент лежит не на геронтологической койке
                .and. !( _lshifr == 'st38.001' ) )
              Elseif lkslp[ j ] == 5
                sop_diag := AClone( arr_diag )
                del_array( sop_diag, 1 )
                fl := ( lprofil_k == 16 .and. ; // пациент лежит на геронтологической койке
                !( _lshifr == 'st38.001' ) .and. ;// !(alltrim(arr_diag[1]) == 'R54') .and. ; // с основным диагнозом не <R54-старость>
                AScan( sop_diag, {| x| AllTrim( x ) == 'R54' } ) > 0 ) // в соп.диагнозах есть <R54-старость>
              Endif
              If fl
                AAdd( _akslp, s_kslp[ i, 1 ] )
                AAdd( _akslp, s_kslp[ i, 2 ] )
                Exit
              Endif
            Endif
          Endif
        Next
        If AScan( lkslp, 11 ) > 0 .and. lpar_org > 1 // разрешена КСЛП=11 и введены парные органы
          AAdd( _akslp, 11 )
          AAdd( _akslp, 1.2 )
        Endif
        If AScan( lkslp, 18 ) > 0 .and. 'cr6' $ lad_cr // разрешена КСЛП=18 и для сложного COVID-19
          AAdd( _akslp, 18 )
          AAdd( _akslp, 1.2 )
        Endif
        If !Empty( _akslp )
          _cena := round_5( _cena * ret_koef_kslp( _akslp ), 0 )  // с 2019 года цена округляется до рублей
        Endif
      Endif
    Endif
  Elseif _k_data > s_18  // с 2018 года
    If !Empty( lkslp )
      If _lshifr == '2005.0' // ЭКО, lkslp = 12,13,14
        s_kslp := { ;
          { 12, 0.60 }, ;
          { 13, 1.10 }, ;
          { 14, 0.19 } ;
          }
        For i := 1 To Len( arr_usl )
          If ValType( arr_usl[ i ] ) == 'A'
            AAdd( ausl, AllTrim( arr_usl[ i, 1 ] ) )  // массив многомерный
          Else
            AAdd( ausl, AllTrim( arr_usl[ i ] ) )    // массив одномерный
          Endif
        Next i
        j := 0 // КСЛП - 1 схема
        If AScan( ausl, 'A11.20.031' ) > 0  // крио
          j := 13  // 6 схема
          If AScan( ausl, 'A11.20.028' ) > 0 // третий этап
            j := 0   // 2 схема
          Endif
        Elseif AScan( ausl, 'A11.20.025.001' ) > 0  // первый этап
          j := 12  // 3 схема
          If AScan( ausl, 'A11.20.036' ) > 0  // завершающий второй этап
            j := 12  // 4 схема
          Elseif AScan( ausl, 'A11.20.028' ) > 0  // завершающий третий этап
            j := 12  // 5 схема
          Endif
        Elseif AScan( ausl, 'A11.20.030.001' ) > 0  // только четвертый этап
          j := 14  // 7 схема
        Endif
        If ( i := AScan( s_kslp, {| x| x[ 1 ] == j } ) ) > 0
          AAdd( _akslp, s_kslp[ i, 1 ] )
          AAdd( _akslp, s_kslp[ i, 2 ] )
          _cena := round_5( _cena * s_kslp[ i, 2 ], 1 )
        Endif
      Else // остальные КСГ
        s_kslp := { ;
          { 1, 1.10, 0,  0 }, ;  // до 1 года
          { 2, 1.10, 1,  3 }, ;  // от 1 до 3 лет включительно
          { 4, 1.05, 75, 999 }, ;  // 75 и старше
          { 5, 1.10, 60, 999 } ;   // 60 и старше и астения
        }
        count_ymd( _date_r, _n_data, @y )
        lkslp := list2arr( lkslp )
        For j := 1 To Len( lkslp )
          If ( i := AScan( s_kslp, {| x| x[ 1 ] == lkslp[ j ] } ) ) > 0
            If Between( i, 1, 5 ) .and. Between( y, s_kslp[ i, 3 ], s_kslp[ i, 4 ] )
              AAdd( _akslp, s_kslp[ i, 1 ] )
              AAdd( _akslp, s_kslp[ i, 2 ] )
              _cena := round_5( _cena * s_kslp[ i, 2 ], 1 )
              Exit
            Endif
          Endif
        Next
      Endif
    Endif
  Elseif _k_data > s_1_may ;                 // с 1 мая 2016 года
      .and. Left( _lshifr, 1 ) == '1' ; // круглосуточный стационар
      .and. !( '.' $ _lshifr )         // это шифр КСГ
    count_ymd( _date_r, _n_data, @y )
    vksg := Int( Val( Right( _lshifr, 3 ) ) ) // последние три цифры - код КСГ
    If ( fl := vksg < 900 ) // не диализ
      If Year( _k_data ) > 2016
        s_kslp := s_kslp17
        If y < 1 .and. Between( vksg, 105, 111 ) // до 1 года и малая масса при рождении
          fl := .f.
        Endif
      Else
        s_kslp := s_kslp16
      Endif
      If fl
        For i := 1 To Len( s_kslp )
          If Between( y, s_kslp[ i, 3 ], s_kslp[ i, 4 ] )
            AAdd( _akslp, s_kslp[ i, 1 ] )
            AAdd( _akslp, s_kslp[ i, 2 ] )
            _cena := round_5( _cena * s_kslp[ i, 2 ], 1 )
            Exit
          Endif
        Next
      Endif
    Endif
  Endif

  Return _akslp

// 23.01.19 вернуть итоговый КСЛП
Function ret_koef_kslp( akslp )

  Local k := 1

  If ValType( akslp ) == 'A' .and. Len( akslp ) >= 2
    k := akslp[ 2 ]
    If Len( akslp ) >= 4
      k += akslp[ 4 ] -1
    Endif
  Endif

  Return k

// 03.05.24 вернуть итоговый КСЛП для 21 года
Function ret_koef_kslp_21( akslp, nYear )

  Local k := 1  // КСЛП равен 1
  Local i

  If ValType( akslp ) == 'A' .and. Len( akslp ) >= 2
    If nYear == 2021
      For i := 1 To Len( akslp ) Step 2
        If i == 1
          k := akslp[ 2 ]
        Else
          k += ( akslp[ i + 1 ] - 1 )
        Endif
      Next
      If k > 1.8
        k := 1.8  // согласно п.3 инструкции
      Endif
      // elseif nYear == 2022
    Elseif nYear >= 2022
      k := 0
      For i := 1 To Len( akslp ) Step 2
        If i == 1 // возможно только одно КСЛП
          k += akslp[ 2 ]
        else
          k += akslp[i + 1]
        Endif
      Next
    Endif
  Endif

  Return k

// 01.02.23 вернуть итоговый КСЛП для конкретного года
Function ret_koef_kslp_21_xml( akslp, tKSLP, nYear )

  Local k := 1  // КСЛП равен 1
  Local iAKSLP

  If ValType( akslp ) == 'A'
    If nYear == 2021
      For iAKSLP := 1 To Len( akslp )
        If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
          k += ( tKSLP[ cKSLP, 4 ] -1 )
        Endif
      Next
      If k > 1.8
        k := 1.8  // согласно п.3 инструкции
      Endif
    Elseif nYear >= 2022
      k := 0
      For iAKSLP := 1 To Len( akslp )
        If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
          k += tKSLP[ cKSLP, 4 ]
        Endif
      Next
    Endif
  Endif

  Return k
