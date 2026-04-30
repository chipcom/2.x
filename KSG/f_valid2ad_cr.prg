#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 02.02.26
Function f_valid2ad_cr( k_date )

  Static mm_bartel := { ;
    { 'индекс Бартела 60 баллов и менее', '60' }, ;
    { 'индекс Бартела более 60 баллов',  '61' } }
  Static mm_mgi := { ;
    { 'не проставляется дополнительный критерий                  ', '   ' }, ;
    { 'mgi-выполнение биопсии при подозрении ЗНО и проведение МГИ', 'mgi' } }
  Static mm_rb := { ;
    { 'не оценивалось состояние по Шкале Реабилитационной Маршрутизации', '   ' }, ;
    { 'rb2 - оценка состояния пациента 2 балла по ШРМ', 'rb2' }, ;
    { 'rb3 - оценка состояния пациента 3 балла по ШРМ', 'rb3' }, ;
    { 'rb4 - оценка состояния пациента 4 балла по ШРМ', 'rb4' }, ;
    { 'rb5 - оценка состояния пациента 5 баллов по ШРМ', 'rb5' }, ;
    { 'rb6 - оценка состояния пациента 6 баллов по ШРМ', 'rb6' }, ;
    { 'rb2cov - оценка состояния пациента после COVID-19 2 балла по ШРМ', 'rb2cov' }, ;
    { 'rb3cov - оценка состояния пациента после COVID-19 3 балла по ШРМ', 'rb3cov' }, ;
    { 'rb4cov - оценка состояния пациента после COVID-19 4 балла по ШРМ', 'rb4cov' }, ;
    { 'rb5cov - оценка состояния пациента после COVID-19 5 балла по ШРМ', 'rb5cov' }, ;
    { 'rbs - медицинская реабилитация детей с нарушениями слуха', 'rbs' } }
  Static mm_rd_2023 := { ;
    { 'rb4d12 - 4 балла по ШРМ, не менее 12 дней', 'rb4d12' }, ;
    { 'rb4d14 - 4 балла по ШРМ, не менее 14 дней', 'rb4d14' }, ;
    { 'rb5d18 - 5 баллов по ШРМ, не менее 18 дней', 'rb5d18' }, ;
    { 'rb5d20 - 5 баллов по ШРМ, не менее 20 дней', 'rb5d20' }, ;
    { 'rbb2 - 2 балла по ШРМ, назначение ботулинического токсина', 'rbb2' }, ;
    { 'rbb3 - 3 балла по ШРМ, назначение ботулинического токсина', 'rbb3' }, ;
    { 'rbb4d14 - 4 балла по ШРМ, назначение ботулинического токсина, не менее 14 дней', 'rbb4d14' }, ;
    { 'rbb5d20 - 5 балла по ШРМ, назначение ботулинического токсина, не менее 20 дней', 'rbb5d20' }, ;
    { 'rbbp4 - мед. реаб. (30 дней), 4-балла по ШРМ, назначение ботулинического токсина', 'rbbp4' }, ;
    { 'rbbp5 -  мед. реаб.  (30 дней) , 5 баллов по ШРМ, назначение ботулинического токсина', 'rbbp5' }, ;
    { 'rbbprob4 - мед. реаб. (30 дней), 4-балла по ШРМ с применением роботизированных систем и назначение ботулинического токсина', 'rbbprob4' }, ;
    { 'rbbprob5 - мед. реаб. (30 дней), 5-баллов по ШРМ с применением роботизированных систем и назначение ботулинического токсина', 'rbbprob5' }, ;
    { 'rbbrob4d14 - 4 балла по ШРМ с применением роботизированных систем и назначение ботулинического токсина, не менее 14 дней', 'rbbrob4d14' }, ;
    { 'rbbrob5d20 - 5 баллов по ШРМ с применением роботизированных систем и назначение ботулинического токсина, не менее 20 дней', 'rbbrob5d20' }, ;
    { 'rbp4 - мед. реаб. (30 дней), 4-балла по ШРМ', 'rbp4' }, ;
    { 'rbp5 -  мед. реаб.  (30 дней) , 5 баллов по ШРМ', 'rbp5' }, ;
    { 'rbprob4 - мед. реаб. (30 дней), 4-балла по ШРМ с применением роботизированных систем', 'rbprob4' }, ;
    { 'rbprob5 -  мед. реаб.  (30 дней) , 5 баллов по ШРМ с применением роботизированных систем', 'rbprob5' }, ;
    { 'rbps5 -  мед. реаб. (сестринский уход) (30 дней), 5 баллов по ШРМ', 'rbps5' }, ;
    { 'rbrob4d12 - 4 балла по ШРМ с применением роботизированных систем, не менее 12 дней', 'rbrob4d12' }, ;
    { 'rbrob4d14 - 4 балла по ШРМ с применением роботизированных систем, не менее 14 дней', 'rbrob4d14' }, ;
    { 'rbrob5d18 - 5 баллов по ШРМ с применением роботизированных систем, не менее 18 дней', 'rbrob5d18' }, ;
    { 'rbrob5d20 - 5 баллов по ШРМ с применением роботизированных систем, не менее 20 дней', 'rbrob5d20' }, ;
    { 'rbtcs45d18 - 4-5 баллов по ШРМ транскраниальная магнитная стимуляция, не менее 18 дней', 'rbtcs45d18' }, ;
    { 'rbbrobсst4d17 - 4 баллов по ШРМ комплексная медицинская реабилитация, не менее 17 дней', 'rbbrobсst4d17' }, ;
    { 'rbbrobсst5d17 - 5 баллов по ШРМ комплексная медицинская реабилитация, не менее 17 дней', 'rbbrobсst5d17' } ;
    }
  Static mm_rd_deti := { ;
    { 'ykur1 - Уровень курации I', 'ykur1' }, ;
    { 'ykur2 - Уровень курации II', 'ykur2' }, ;
    { 'ykur3d12 - Уровень курации III, не менее 12 дней', 'ykur3d12' }, ;
    { 'ykur4d18 - Уровень курации IV, не менее 18 дней', 'ykur4d18' }, ;
    { 'ykur3 - Уровень курации III', 'ykur3' }, ;
    { 'ykur4 - Уровень курации IV', 'ykur4' } }
  Local i, j, arr_sop := {}, arr_osl := {}, fl
  Local arr_ad_criteria
  Local row

  arr_ad_criteria := getadditionalcriteria( k_date )  // загрузим доп. критерии на дату

  input_ad_cr := .f.
  mm_ad_cr := {}
  If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. m1vmp == 0
    If m1profil == 158 // реабилитация
      input_ad_cr := .t.
      AAdd( mm_ad_cr, mm_rb[ 1 ] )
      If m1usl_ok == USL_OK_HOSPITAL
        AAdd( mm_ad_cr, mm_rb[ 3 ] )
        AAdd( mm_ad_cr, mm_rb[ 4 ] )
        AAdd( mm_ad_cr, mm_rb[ 5 ] )
        AAdd( mm_ad_cr, mm_rb[ 6 ] )
        AAdd( mm_ad_cr, mm_rb[ 8 ] )
        AAdd( mm_ad_cr, mm_rb[ 9 ] )
        AAdd( mm_ad_cr, mm_rb[ 10 ] )
        AAdd( mm_ad_cr, mm_rb[ 11 ] )
      Else
        AAdd( mm_ad_cr, mm_rb[ 2 ] )
        AAdd( mm_ad_cr, mm_rb[ 3 ] )
        AAdd( mm_ad_cr, mm_rb[ 7 ] )
        AAdd( mm_ad_cr, mm_rb[ 8 ] )
        AAdd( mm_ad_cr, mm_rb[ 11 ] )
      Endif
      If k_date >= 0d20230101
        For Each row in mm_rd_2023
          AAdd( mm_ad_cr, row )
        Next
        If count_years( mdate_r, k_date ) < 18
          For Each row in mm_rd_deti
            AAdd( mm_ad_cr, row )
          Next
        Endif
      Endif
    Elseif m1usl_ok == USL_OK_HOSPITAL .and. !Empty( MKOD_DIAG )
      // заполним массивы arr_sop, arr_osl сопутствующими диагнозами и осложнениями
      If !Empty( MKOD_DIAG2 )
        AAdd( arr_sop, PadR( MKOD_DIAG2, 5 ) )
      Endif
      If !Empty( MKOD_DIAG3 )
        AAdd( arr_sop, PadR( MKOD_DIAG3, 5 ) )
      Endif
      If !Empty( MKOD_DIAG4 )
        AAdd( arr_sop, PadR( MKOD_DIAG4, 5 ) )
      Endif
      If !Empty( MSOPUT_B1 )
        AAdd( arr_sop, PadR( MSOPUT_B1, 5 ) )
      Endif
      If !Empty( MSOPUT_B2 )
        AAdd( arr_sop, PadR( MSOPUT_B2, 5 ) )
      Endif
      If !Empty( MSOPUT_B3 )
        AAdd( arr_sop, PadR( MSOPUT_B3, 5 ) )
      Endif
      If !Empty( MSOPUT_B4 )
        AAdd( arr_sop, PadR( MSOPUT_B4, 5 ) )
      Endif
      If !Empty( MOSL1 )
        AAdd( arr_osl, PadR( MOSL1, 5 ) )
      Endif
      If !Empty( MOSL2 )
        AAdd( arr_osl, PadR( MOSL2, 5 ) )
      Endif
      If !Empty( MOSL3 )
        AAdd( arr_osl, PadR( MOSL3, 5 ) )
      Endif

      For i := 1 To Len( arr_ad_criteria )
        If m1usl_ok == arr_ad_criteria[ i, 1 ] .and. AScan( mm_ad_cr, {| x| x[ 2 ] == arr_ad_criteria[ i, 2 ] } ) == 0
          If !Empty( arr_ad_criteria[ i, 3 ] ) .and. Empty( arr_ad_criteria[ i, 4 ] ) .and. Empty( arr_ad_criteria[ i, 5 ] ) // осн.диагноз
            If AScan( arr_ad_criteria[ i, 3 ], PadR( MKOD_DIAG, 5 ) ) > 0
              AAdd( mm_ad_cr, { AllTrim( arr_ad_criteria[ i, 2 ] ) + ' ' + arr_ad_criteria[ i, 6 ], arr_ad_criteria[ i, 2 ] } )
            Endif
          Endif
          If !Empty( arr_ad_criteria[ i, 3 ] ) .and. !Empty( arr_ad_criteria[ i, 4 ] ) .and. Empty( arr_ad_criteria[ i, 5 ] ) // осн.+сопут.диагнозы
            fl := .t.
            If eq_any( Left( arr_ad_criteria[ i, 2 ], 2 ), 'i3', 'i4' ) .and. mk_data >= 0d20200901
              fl := .f.
            Endif
            If eq_any( Left( arr_ad_criteria[ i, 2 ], 2 ), 'cr' ) .and. mk_data < 0d20200901
              fl := .f.
            Endif

            If fl .and. !Empty( arr_sop ) .and. AScan( arr_ad_criteria[ i, 3 ], PadR( MKOD_DIAG, 5 ) ) > 0
              For j := 1 To Len( arr_sop )
                If AScan( arr_ad_criteria[ i, 4 ], arr_sop[ j ] ) > 0
                  AAdd( mm_ad_cr, { AllTrim( arr_ad_criteria[ i, 2 ] ) + ' ' + arr_ad_criteria[ i, 6 ], arr_ad_criteria[ i, 2 ] } )
                  Exit
                Endif
              Next
            Endif
          Endif
          If !Empty( arr_ad_criteria[ i, 3 ] ) .and. Empty( arr_ad_criteria[ i, 4 ] ) .and. !Empty( arr_ad_criteria[ i, 5 ] ) // диагноз осложнения
            If !Empty( arr_osl )
              For j := 1 To Len( arr_osl )
                If AScan( arr_ad_criteria[ i, 5 ], arr_osl[ j ] ) > 0
                  AAdd( mm_ad_cr, { AllTrim( arr_ad_criteria[ i, 2 ] ) + ' ' + arr_ad_criteria[ i, 6 ], arr_ad_criteria[ i, 2 ] } )
                  Exit
                Endif
              Next
            Endif
          Endif
        Endif
      Next
    Elseif m1usl_ok == USL_OK_DAY_HOSPITAL .and. m1profil == 137  // ЭКО дневной стационар
      For i := 1 To Len( arr_ad_criteria )
        If m1usl_ok == arr_ad_criteria[ i, 1 ] .and. Lower( SubStr( arr_ad_criteria[ i, 2 ], 1, 3 ) ) == 'ivf'
          AAdd( mm_ad_cr, { AllTrim( arr_ad_criteria[ i, 2 ] ) + ' ' + arr_ad_criteria[ i, 6 ], arr_ad_criteria[ i, 2 ] } )
        Endif
      Next
    Elseif ( ( m1usl_ok == USL_OK_DAY_HOSPITAL ) .or. ( m1usl_ok == USL_OK_HOSPITAL ) ) .and. m1profil == 65  // офтольмология стационар
      For i := 1 To Len( arr_ad_criteria )
        If m1usl_ok == arr_ad_criteria[ i, 1 ] .and. Lower( SubStr( arr_ad_criteria[ i, 2 ], 1, 3 ) ) == 'icv'
          AAdd( mm_ad_cr, { AllTrim( arr_ad_criteria[ i, 2 ] ) + ' ' + arr_ad_criteria[ i, 6 ], arr_ad_criteria[ i, 2 ] } )
        Endif
      Next
    Elseif m1usl_ok == USL_OK_DAY_HOSPITAL .and. !Empty( MKOD_DIAG )
      For i := 1 To Len( arr_ad_criteria )
        If m1usl_ok == arr_ad_criteria[ i, 1 ] .and. AScan( arr_ad_criteria[ i, 3 ], PadR( MKOD_DIAG, 5 ) ) > 0
          AAdd( mm_ad_cr, { AllTrim( arr_ad_criteria[ i, 2 ] ) + ' ' + arr_ad_criteria[ i, 6 ], arr_ad_criteria[ i, 2 ] } )
        Endif
      Next
    Elseif eq_any( pr_ds_it, 1, 2 ) .and. m1usl_ok == USL_OK_HOSPITAL
      AAdd( mm_ad_cr, mm_it[ 1 ] )
      AAdd( mm_ad_cr, mm_it[ pr_ds_it + 1 ] )
    Elseif pr_ds_it == 4
      mm_ad_cr := mm_bartel
    Endif
    If ( input_ad_cr := !Empty( mm_ad_cr ) ) .and. Empty( mm_ad_cr[ 1, 1 ] )
      ASort( mm_ad_cr, , , {| x, y| x[ 2 ] < y[ 2 ] } )
      // заполним из справочника схем
      For i := 1 To Len( mm_ad_cr )
        Do Case
        Case mm_ad_cr[ i, 2 ] == 'cr4'
          mm_ad_cr[ i, 1 ] := 'cr4-п.4 прил.12 Приказа 198н/пульсоксиметрия<95%, T>=38C, ЧДД>22'
        Case mm_ad_cr[ i, 2 ] == 'cr5'
          mm_ad_cr[ i, 1 ] := 'cr5-п.5 прил.12 Приказа 198н/пульсоксиметрия<=93%, T>=39C, ЧДД>=30'
        Case mm_ad_cr[ i, 2 ] == 'cr6'
          mm_ad_cr[ i, 1 ] := 'cr6-п.6 прил.12 Приказа 198н/пульсоксиметрия<92%, наруш.сознания, ЧДД>35'
        Case mm_ad_cr[ i, 2 ] == 'cr8'
          mm_ad_cr[ i, 1 ] := 'cr8-пп.8-9 прил.12 Приказа 198н/пациенты, относящиеся к группе риска'
        Case mm_ad_cr[ i, 2 ] == 'it1'
          mm_ad_cr[ i, 1 ] := 'it1-непрерывное проведение ИВЛ в течение 72 часов и более'
        Case mm_ad_cr[ i, 2 ] == 'it2'
          mm_ad_cr[ i, 1 ] := 'it2-непрерывное проведение ИВЛ в течение 480 часов и более'
        Case mm_ad_cr[ i, 2 ] == 'i3 '
          mm_ad_cr[ i, 1 ] := 'i3-непрерывное проведение ИВЛ в течение менее 120 часов'
        Case mm_ad_cr[ i, 2 ] == 'i4 '
          mm_ad_cr[ i, 1 ] := 'i4-непрерывное проведение ИВЛ в течение 120 часов и более'
        Case mm_ad_cr[ i, 2 ] == 'if '
          mm_ad_cr[ i, 1 ] := 'if-назначение пегилированных интерферонов для лечения хрон.вирусного гепатита С'
        Case mm_ad_cr[ i, 2 ] == 'nif'
          mm_ad_cr[ i, 1 ] := 'nif-назначение лек.преп. для лечения хрон.вирусного гепатита С+пегилир.интерферон'
        Case mm_ad_cr[ i, 2 ] == 'pbt'
          mm_ad_cr[ i, 1 ] := 'pbt-назначение других генно-инженерных препаратов и селективных иммунодепрессантов'
        Case mm_ad_cr[ i, 2 ] == 'ep1'
          mm_ad_cr[ i, 1 ] := 'ep1-МРТ 3Тс видео ЭЭГ-мониторинг с включением сна не менее 4 час.'
        Case mm_ad_cr[ i, 2 ] == 'ep2'
          mm_ad_cr[ i, 1 ] := 'ep2-МРТ 3Тс, видео ЭЭГ, сон не менее 4 час., противоэпилептическая терапия'
        Case mm_ad_cr[ i, 2 ] == 'ep3'
          mm_ad_cr[ i, 1 ] := 'ep3-МРТ 3Тс, видео ЭЭГ, сон не менее 24 час., консультация врача-нейрохирурга'
        Case mm_ad_cr[ i, 2 ] == 'dcl'
          mm_ad_cr[ i, 1 ] := 'dcl-долечивание пациентов с COVID-19 на койках для пациентов средней тяжести'
        Endcase
      Next
      ins_array( mm_ad_cr, 1, mm_mgi[ 1 ] )
    Endif
    If !input_ad_cr .and. m1usl_ok == USL_OK_DAY_HOSPITAL // безусловно добавим МГИ для дневного стационара
      input_ad_cr := .t.
      AAdd( mm_ad_cr, mm_mgi[ 1 ] )
      AAdd( mm_ad_cr, mm_mgi[ 2 ] )
    Endif

    If input_ad_cr
      If ( i := AScan( mm_ad_cr, {| x| PadR( x[ 2 ], 10 ) == PadR( m1ad_cr, 10 ) } ) ) > 0
        mad_cr := PadR( mm_ad_cr[ i, 1 ], 65 )  // 66
      Else
        mad_cr := Space( 65 ) // 66
        m1ad_cr := Space( 10 )
      Endif
      If Type( 'p_nstr_ad_cr' ) == 'N'
        @ p_nstr_ad_cr, 1 Say p_str_ad_cr
        update_get( 'mad_cr' )
      Endif
    Endif
  Endif
  If m1profil != 0
    m1profil_m := soot_v002_m003( m1profil, m1vzros_reb )
    mprofil_m := SubStr( inieditspr( A__MENUVERT, getm003(),  m1PROFIL_M ), 1, 15 )
    update_get( 'mprofil_m' )
  Endif

  Return .t.
