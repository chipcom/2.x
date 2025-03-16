#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 13.02.25
Function f_valid2ad_cr( k_date )
  Static mm_bartel := { ;
    {'индекс Бартела 60 баллов и менее', '60'}, ;
    {'индекс Бартела более 60 баллов',  '61'}}
  Static mm_mgi := { ;
    {'не проставляется дополнительный критерий                  ', '   '}, ;
    {'mgi-выполнение биопсии при подозрении ЗНО и проведение МГИ', 'mgi'}}
  Static mm_rb := { ;
    {'не оценивалось состояние по Шкале Реабилитационной Маршрутизации', '   '}, ;
    {'rb2 - оценка состояния пациента 2 балла по ШРМ', 'rb2'}, ;
    {'rb3 - оценка состояния пациента 3 балла по ШРМ', 'rb3'}, ;
    {'rb4 - оценка состояния пациента 4 балла по ШРМ', 'rb4'}, ;
    {'rb5 - оценка состояния пациента 5 баллов по ШРМ', 'rb5'}, ;
    {'rb6 - оценка состояния пациента 6 баллов по ШРМ', 'rb6'}, ;
    {'rb2cov - оценка состояния пациента после COVID-19 2 балла по ШРМ', 'rb2cov'}, ;
    {'rb3cov - оценка состояния пациента после COVID-19 3 балла по ШРМ', 'rb3cov'}, ;
    {'rb4cov - оценка состояния пациента после COVID-19 4 балла по ШРМ', 'rb4cov'}, ;
    {'rb5cov - оценка состояния пациента после COVID-19 5 балла по ШРМ', 'rb5cov'}, ;
    {'rbs - медицинская реабилитация детей с нарушениями слуха', 'rbs'}}
  Static mm_rd_2023 := { ;
    {'rb4d12 - 4 балла по ШРМ, не менее 12 дней', 'rb4d12'}, ;
    {'rb4d14 - 4 балла по ШРМ, не менее 14 дней', 'rb4d14'}, ;
    {'rb5d18 - 5 баллов по ШРМ, не менее 18 дней', 'rb5d18'}, ;
    {'rb5d20 - 5 баллов по ШРМ, не менее 20 дней', 'rb5d20'}, ;
    {'rbb2 - 2 балла по ШРМ, назначение ботулинического токсина', 'rbb2'}, ;
    {'rbb3 - 3 балла по ШРМ, назначение ботулинического токсина', 'rbb3'}, ;
    {'rbb4d14 - 4 балла по ШРМ, назначение ботулинического токсина, не менее 14 дней', 'rbb4d14'}, ;
    {'rbb5d20 - 5 балла по ШРМ, назначение ботулинического токсина, не менее 20 дней', 'rbb5d20'}, ;
    {'rbbp4 - мед. реаб. (30 дней), 4-балла по ШРМ, назначение ботулинического токсина', 'rbbp4'}, ;
    {'rbbp5 -  мед. реаб.  (30 дней) , 5 баллов по ШРМ, назначение ботулинического токсина', 'rbbp5'}, ;
    {'rbbprob4 - мед. реаб. (30 дней), 4-балла по ШРМ с применением роботизированных систем и назначение ботулинического токсина', 'rbbprob4'}, ;
    {'rbbprob5 - мед. реаб. (30 дней), 5-баллов по ШРМ с применением роботизированных систем и назначение ботулинического токсина', 'rbbprob5'}, ;
    {'rbbrob4d14 - 4 балла по ШРМ с применением роботизированных систем и назначение ботулинического токсина, не менее 14 дней', 'rbbrob4d14'}, ;
    {'rbbrob5d20 - 5 баллов по ШРМ с применением роботизированных систем и назначение ботулинического токсина, не менее 20 дней', 'rbbrob5d20'}, ;
    {'rbp4 - мед. реаб. (30 дней), 4-балла по ШРМ', 'rbp4'}, ;
    {'rbp5 -  мед. реаб.  (30 дней) , 5 баллов по ШРМ', 'rbp5'}, ;
    {'rbprob4 - мед. реаб. (30 дней), 4-балла по ШРМ с применением роботизированных систем', 'rbprob4'}, ;
    {'rbprob5 -  мед. реаб.  (30 дней) , 5 баллов по ШРМ с применением роботизированных систем', 'rbprob5'}, ;
    {'rbps5 -  мед. реаб. (сестринский уход) (30 дней), 5 баллов по ШРМ', 'rbps5'}, ;
    {'rbrob4d12 - 4 балла по ШРМ с применением роботизированных систем, не менее 12 дней', 'rbrob4d12'}, ;
    {'rbrob4d14 - 4 балла по ШРМ с применением роботизированных систем, не менее 14 дней', 'rbrob4d14'}, ;
    {'rbrob5d18 - 5 баллов по ШРМ с применением роботизированных систем, не менее 18 дней', 'rbrob5d18'}, ;
    {'rbrob5d20 - 5 баллов по ШРМ с применением роботизированных систем, не менее 20 дней', 'rbrob5d20'}, ;
    {'rbtcs45d18 - 4-5 баллов по ШРМ транскраниальная магнитная стимуляция, не менее 18 дней', 'rbtcs45d18'}, ;
    {'rbbrobсst4d17 - 4 баллов по ШРМ комплексная медицинская реабилитация, не менее 17 дней', 'rbbrobсst4d17'}, ;
    {'rbbrobсst5d17 - 5 баллов по ШРМ комплексная медицинская реабилитация, не менее 17 дней', 'rbbrobсst5d17'} ;
  }
  Static mm_rd_deti := { ;
    {'ykur1 - Уровень курации I', 'ykur1'}, ;
    {'ykur2 - Уровень курации II', 'ykur2'}, ;
    {'ykur3d12 - Уровень курации III, не менее 12 дней', 'ykur3d12'}, ;
    {'ykur4d18 - Уровень курации IV, не менее 18 дней', 'ykur4d18'}, ;
    {'ykur3 - Уровень курации III', 'ykur3'}, ;
    {'ykur4 - Уровень курации IV', 'ykur4'}}
  Local i, j, arr_sop := {}, arr_osl := {}, fl
  local arr_ad_criteria
  local row

  arr_ad_criteria := getAdditionalCriteria(k_date)  // загрузим доп. критерии на дату

  input_ad_cr := .f.
  mm_ad_cr := {}
  // if m1usl_ok < 3 .and. m1vmp == 0
  if eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. m1vmp == 0
    if m1profil == 158 // реабилитация
      input_ad_cr := .t.
      aadd(mm_ad_cr, mm_rb[1])
      if m1usl_ok == USL_OK_HOSPITAL
        aadd(mm_ad_cr, mm_rb[3])
        aadd(mm_ad_cr, mm_rb[4])
        aadd(mm_ad_cr, mm_rb[5])
        aadd(mm_ad_cr, mm_rb[6])
        aadd(mm_ad_cr, mm_rb[8])
        aadd(mm_ad_cr, mm_rb[9])
        aadd(mm_ad_cr, mm_rb[10])
        aadd(mm_ad_cr, mm_rb[11])
      else
        aadd(mm_ad_cr, mm_rb[2])
        aadd(mm_ad_cr, mm_rb[3])
        aadd(mm_ad_cr, mm_rb[7])
        aadd(mm_ad_cr, mm_rb[8])
        aadd(mm_ad_cr, mm_rb[11])
      endif
      if k_date >= 0d20230101
        for each row in mm_rd_2023
          aadd(mm_ad_cr, row)
        next
        if count_years(mdate_r, k_date) < 18
          for each row in mm_rd_deti
            aadd(mm_ad_cr, row)
          next
        endif
      endif
    elseif m1usl_ok == USL_OK_HOSPITAL .and. !empty(MKOD_DIAG)
      // заполним массивы arr_sop, arr_osl сопутствующими диагнозами и осложнениями
      if !empty(MKOD_DIAG2)
        aadd(arr_sop, padr(MKOD_DIAG2, 5))
      endif
      if !empty(MKOD_DIAG3)
        aadd(arr_sop, padr(MKOD_DIAG3, 5))
      endif
      if !empty(MKOD_DIAG4)
        aadd(arr_sop, padr(MKOD_DIAG4, 5))
      endif
      if !empty(MSOPUT_B1)
        aadd(arr_sop, padr(MSOPUT_B1, 5))
      endif
      if !empty(MSOPUT_B2)
        aadd(arr_sop, padr(MSOPUT_B2, 5))
      endif
      if !empty(MSOPUT_B3)
        aadd(arr_sop, padr(MSOPUT_B3, 5))
      endif
      if !empty(MSOPUT_B4)
        aadd(arr_sop, padr(MSOPUT_B4, 5))
      endif
      if !empty(MOSL1)
        aadd(arr_osl, padr(MOSL1, 5))
      endif
      if !empty(MOSL2)
        aadd(arr_osl, padr(MOSL2, 5))
      endif
      if !empty(MOSL3)
        aadd(arr_osl, padr(MOSL3, 5))
      endif

      for i := 1 to len(arr_ad_criteria) 
        if m1usl_ok == arr_ad_criteria[i, 1] .and. ascan(mm_ad_cr, {|x| x[2] == arr_ad_criteria[i, 2] }) == 0
          if !empty(arr_ad_criteria[i, 3]) .and. empty(arr_ad_criteria[i, 4]) .and. empty(arr_ad_criteria[i, 5]) // осн.диагноз
            if ascan(arr_ad_criteria[i,3],padr(MKOD_DIAG, 5)) > 0
              aadd(mm_ad_cr, {alltrim(arr_ad_criteria[i, 2]) + ' ' + arr_ad_criteria[i, 6], arr_ad_criteria[i, 2]})
            endif
          endif
          if !empty(arr_ad_criteria[i, 3]) .and. !empty(arr_ad_criteria[i, 4]) .and. empty(arr_ad_criteria[i, 5]) // осн.+сопут.диагнозы
            fl := .t.
            if eq_any(left(arr_ad_criteria[i, 2], 2), 'i3', 'i4') .and. mk_data >= 0d20200901
              fl := .f.
            endif
            if eq_any(left(arr_ad_criteria[i, 2], 2), 'cr') .and. mk_data < 0d20200901
              fl := .f.
            endif
  
            if fl .and. !empty(arr_sop) .and. ascan(arr_ad_criteria[i, 3], padr(MKOD_DIAG, 5)) > 0
              for j := 1 to len(arr_sop)
                if ascan(arr_ad_criteria[i, 4], arr_sop[j]) > 0
                  aadd(mm_ad_cr, {alltrim(arr_ad_criteria[i, 2]) + ' ' + arr_ad_criteria[i, 6], arr_ad_criteria[i, 2]})
                  exit
                endif
              next
            endif
          endif
          if !empty(arr_ad_criteria[i, 3]) .and. empty(arr_ad_criteria[i, 4]) .and. !empty(arr_ad_criteria[i, 5]) // диагноз осложнения
            if !empty(arr_osl)
              for j := 1 to len(arr_osl)
                if ascan(arr_ad_criteria[i, 5], arr_osl[j]) > 0
                  aadd(mm_ad_cr, {alltrim(arr_ad_criteria[i, 2]) + ' ' + arr_ad_criteria[i, 6], arr_ad_criteria[i, 2]})
                  exit
                endif
              next
            endif
          endif
        endif
      next
    elseif m1usl_ok == USL_OK_DAY_HOSPITAL .and. m1profil == 137  // ЭКО дневной стационар
      for i := 1 to len(arr_ad_criteria) 
        if m1usl_ok == arr_ad_criteria[i, 1] .and. lower(substr(arr_ad_criteria[i, 2], 1, 3)) == 'ivf'
          aadd(mm_ad_cr, {alltrim(arr_ad_criteria[i, 2]) + ' ' + arr_ad_criteria[i, 6], arr_ad_criteria[i, 2]})
        endif
      next
    elseif ( ( m1usl_ok == USL_OK_DAY_HOSPITAL ) .or. ( m1usl_ok == USL_OK_HOSPITAL ) ) .and. m1profil == 65  // офтольмология стационар
      for i := 1 to len(arr_ad_criteria) 
        if m1usl_ok == arr_ad_criteria[i, 1] .and. lower(substr(arr_ad_criteria[i, 2], 1, 3)) == 'icv'
          aadd(mm_ad_cr, {alltrim(arr_ad_criteria[i, 2]) + ' ' + arr_ad_criteria[i, 6], arr_ad_criteria[i, 2]})
        endif
      next 
    elseif m1usl_ok == USL_OK_DAY_HOSPITAL .and. !empty(MKOD_DIAG)
      for i := 1 to len(arr_ad_criteria)
        if m1usl_ok == arr_ad_criteria[i, 1] .and. ascan(arr_ad_criteria[i, 3], padr(MKOD_DIAG, 5)) > 0
          aadd(mm_ad_cr, {alltrim(arr_ad_criteria[i, 2]) + ' ' + arr_ad_criteria[i, 6], arr_ad_criteria[i, 2]})
        endif
      next
    elseif eq_any(pr_ds_it, 1, 2) .and. m1usl_ok == USL_OK_HOSPITAL
      aadd(mm_ad_cr,mm_it[1])
      aadd(mm_ad_cr, mm_it[pr_ds_it + 1])
    elseif pr_ds_it == 4
      mm_ad_cr := mm_bartel
    endif
    if (input_ad_cr := !empty(mm_ad_cr)) .and. empty(mm_ad_cr[1, 1])
      asort(mm_ad_cr, , , {|x, y| x[2] < y[2]})
      // заполним из справочника схем
      for i := 1 to len(mm_ad_cr)
        do case
          case mm_ad_cr[i, 2] == 'cr4'
            mm_ad_cr[i, 1] := 'cr4-п.4 прил.12 Приказа 198н/пульсоксиметрия<95%, T>=38C, ЧДД>22'
          case mm_ad_cr[i, 2] == 'cr5'
            mm_ad_cr[i, 1] := 'cr5-п.5 прил.12 Приказа 198н/пульсоксиметрия<=93%, T>=39C, ЧДД>=30'
          case mm_ad_cr[i, 2] == 'cr6'
            mm_ad_cr[i, 1] := 'cr6-п.6 прил.12 Приказа 198н/пульсоксиметрия<92%, наруш.сознания, ЧДД>35'
          case mm_ad_cr[i, 2] == 'cr8'
            mm_ad_cr[i, 1] := 'cr8-пп.8-9 прил.12 Приказа 198н/пациенты, относящиеся к группе риска'
          case mm_ad_cr[i, 2] == 'it1'
            mm_ad_cr[i, 1] := 'it1-непрерывное проведение ИВЛ в течение 72 часов и более'
          case mm_ad_cr[i, 2] == 'it2'
            mm_ad_cr[i, 1] := 'it2-непрерывное проведение ИВЛ в течение 480 часов и более'
          case mm_ad_cr[i, 2] == 'i3 '
            mm_ad_cr[i, 1] := 'i3-непрерывное проведение ИВЛ в течение менее 120 часов'
          case mm_ad_cr[i, 2] == 'i4 '
            mm_ad_cr[i, 1] := 'i4-непрерывное проведение ИВЛ в течение 120 часов и более'
          case mm_ad_cr[i, 2] == 'if '
            mm_ad_cr[i, 1] := 'if-назначение пегилированных интерферонов для лечения хрон.вирусного гепатита С'
          case mm_ad_cr[i, 2] == 'nif'
            mm_ad_cr[i, 1] := 'nif-назначение лек.преп. для лечения хрон.вирусного гепатита С+пегилир.интерферон'
          case mm_ad_cr[i, 2] == 'pbt'
            mm_ad_cr[i, 1] := 'pbt-назначение других генно-инженерных препаратов и селективных иммунодепрессантов'
          case mm_ad_cr[i, 2] == 'ep1'
            mm_ad_cr[i, 1] := 'ep1-МРТ 3Тс видео ЭЭГ-мониторинг с включением сна не менее 4 час.'
          case mm_ad_cr[i, 2] == 'ep2'
            mm_ad_cr[i, 1] := 'ep2-МРТ 3Тс, видео ЭЭГ, сон не менее 4 час., противоэпилептическая терапия'
          case mm_ad_cr[i, 2] == 'ep3'
            mm_ad_cr[i, 1] := 'ep3-МРТ 3Тс, видео ЭЭГ, сон не менее 24 час., консультация врача-нейрохирурга'
          case mm_ad_cr[i, 2] == 'dcl'
            mm_ad_cr[i, 1] := 'dcl-долечивание пациентов с COVID-19 на койках для пациентов средней тяжести'
        endcase
      next
      Ins_Array(mm_ad_cr, 1, mm_mgi[1])
    endif
    if !input_ad_cr .and. m1usl_ok == USL_OK_DAY_HOSPITAL // безусловно добавим МГИ для дневного стационара
      input_ad_cr := .t.
      aadd(mm_ad_cr, mm_mgi[1])
      aadd(mm_ad_cr, mm_mgi[2])
    endif

    if input_ad_cr
      if (i := ascan(mm_ad_cr, {|x| padr(x[2], 10) == padr(m1ad_cr, 10)})) > 0
        mad_cr := padr(mm_ad_cr[i, 1], 65)  // 66
      else
        mad_cr := space(65) // 66
        m1ad_cr := space(10)
      endif
      if type('p_nstr_ad_cr') == 'N'
        @ p_nstr_ad_cr,1 say p_str_ad_cr
        update_get('mad_cr')
      endif
    endif
  endif
  return .t.