#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 29.02.24
function arr_NO_YES()

  return { { 'нет', 0 }, { 'да ', 1 } }

// 20.02.24 формирование массива о смерти пациента
function arr_patient_died_during_treatment( mkod_k, loc_kod )
  // mkod_k - код пациента по БД картотеки kartotek.dbf
  // Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
  // должны быть открыты файлы HUMAN.DBF и HUMAN_.DBF и между ними
  // установлен relation
  // текущий alias должен быть HUMAN

  local a_smert := {}

  find ( Str( mkod_k, 7 ) )
  Do While human->kod_k == mkod_k .and. !Eof()
    If RecNo() != loc_kod .and. is_death( human_->RSLT_NEW ) .and. ;
        human_->oplata != 9 .and. human_->NOVOR == 0
      a_smert := { 'Данный больной умер!', ;
        'Лечение с ' + full_date( human->N_DATA ) + ' по ' + full_date( human->K_DATA ) }
      Exit
    Endif
    Skip
  Enddo 
  return a_smert

// 26.05.22 проверка на соответствие услуги профилю
Function UslugaAccordanceProfil(lshifr, lvzros_reb, lprofil, ta, short_shifr)

  Local s := '', s1 := ''

  if valtype(short_shifr) == 'C' .and. !empty(short_shifr) .and. !(alltrim(lshifr) == alltrim(short_shifr))
    s1 := '(' + alltrim(short_shifr) + ')'
  endif
  if select('MOPROF') == 0
    R_Use(dir_exe() + '_mo_prof', cur_dir() + '_mo_prof', 'MOPROF')
  endif
  lshifr := padr(lshifr, 20)
  lvzros_reb := iif(lvzros_reb == 0, 0, 1)
  select MOPROF
  find (lshifr)
  if found() // если данная услуга участвует в проверке по профилю
    find (lshifr + str(lvzros_reb, 1) + str(lprofil, 3))
    if !found()
      find (lshifr + str(lvzros_reb, 1))
      if human_->USL_OK == 4  // если скорая помощь
        if found()                // и нашли первый попавшийся профиль,
          lprofil := moprof->profil // то заменяем без всяких сообщений
        endif
      else // для всех остальных условий формируем сообщение об ошибке
        do while moprof->shifr==lshifr .and. moprof->vzros_reb == lvzros_reb .and. !eof()
          s += '"' + lstr(moprof->profil) + '.' + inieditspr(A__MENUVERT, getV002(), moprof->profil) + '", '
          skip
        enddo
        aadd(ta, rtrim(lshifr) + s1 + ' - профиль "' + lstr(lprofil) + '.' + ;
                  inieditspr(A__MENUVERT, getV002(), lprofil) + ;
                  '" для ' + {'взрослого', 'ребёнка'}[lvzros_reb + 1] + ;
                  ' недопустим' + iif(empty(s), '', ' (разрешается ' + left(s, len(s) - 2) + ')'))
      endif
    endif
  endif
  return lprofil
  
// 12.02.23 проверка на соответствие услуги специальности
Function UslugaAccordancePRVS(lshifr, lvzros_reb, lprvs, ta, short_shifr, lvrach)

  Local s := '', s1 := '', s2, k
  local arr_conv_V015_V021 := conversion_V015_V021()

  if valtype(short_shifr) == 'C' .and. !empty(short_shifr) .and. !(alltrim(lshifr) == alltrim(short_shifr))
    s1 := '(' + alltrim(short_shifr) + ')'
  endif
  if select('MOSPEC') == 0
    R_Use(dir_exe() + '_mo_spec', cur_dir() + '_mo_spec', 'MOSPEC')
  endif
  lshifr := padr(lshifr, 20)
  lvzros_reb := iif(lvzros_reb == 0, 0, 1)
  if lprvs < 0
    k := abs(lprvs)
  else
    k := ret_V004_V015(lprvs)
  endif
  s2 := lstr(k) + '.' + inieditspr(A__MENUVERT, getV015(), k)
  //
  lprvs := ret_prvs_V021(lprvs)
  select MOSPEC
  find (lshifr)
  if found() // если данная услуга участвует в проверке по специальности
    find (lshifr + str(lvzros_reb, 1) + str(lprvs, 6))
    if !found()
      find (lshifr + str(lvzros_reb, 1))
      // формируем сообщение об ошибке
      do while mospec->shifr==lshifr .and. mospec->vzros_reb == lvzros_reb .and. !eof()
        k := mospec->prvs_new
        // if (i := ascan(arr_conv_V015_V021, {|x| x[2] == k})) > 0 // перевод из 21-го справочника
        //   k := arr_conv_V015_V021[i, 1]                          // в 15-ый справочник
        // endif
        // s += '"' + lstr(k) + '.' + inieditspr(A__MENUVERT, getV015(), k) + '", '
        s += '"' + inieditspr(A__MENUVERT, getV021(), k) + '", '
        skip
      enddo
      pers->(dbGoto(lvrach))
      aadd(ta, rtrim(lshifr) + s1 + ' - (' + fam_i_o(pers->fio) + ' [' + lstr(pers->tab_nom) + ;
              ']) специальность "' + s2 + '" для ' + {'взрослого', 'ребёнка'}[lvzros_reb + 1] + ;
              ' недопустима' + iif(empty(s), '', ' (разрешается ' + left(s, len(s) - 2) + ')'))
    endif
  endif
  return nil
  
// 07.06.24 собрать шифры услуг в случае
function collect_uslugi( rec_number )

  local human_number, human_uslugi, mohu_usluga
  local tmp_select := select()
  local arrUslugi := {}

  human_number := hb_DefaultValue( rec_number, human->( recno() ) )
  human_uslugi := hu->( recno() )
  mohu_usluga := mohu->( recno() )
  dbSelectArea( 'HU' )

  find ( str( human_number, 7 ) )
  do while hu->kod == human_number .and. ! eof()
    aadd( arrUslugi, alltrim( usl->shifr ) )
    hu->( dbSkip() )
  enddo

  hu->( dbGoto( human_uslugi ) )

  dbSelectArea( 'MOHU' )
  set relation to u_kod into MOSU
  find ( str( human_number, 7 ) )
  do while mohu->kod == human_number .and. ! eof()
    aadd( arrUslugi, alltrim( iif( empty( mosu->shifr ), mosu->shifr1, mosu->shifr ) ) )
    mohu->( dbSkip() )
  enddo
  mohu->( dbGoto( mohu_usluga ) )

  select( tmp_select )
  return arrUslugi

// 07.06.24 собрать даты оказания услуг в случае
function collect_date_uslugi( rec_number )

  local human_number, human_uslugi, mohu_usluga
  local tmp_select := select()
  local arrDate := {}, aSortDate
  local i := 0, sDate, dDate

  human_number := hb_DefaultValue( rec_number, human->( recno() ) )
  human_uslugi := hu->( recno() )
  mohu_usluga := mohu->( recno() )
  dbSelectArea( 'HU' )

  find ( str( human_number, 7 ) )
  do while hu->kod == human_number .and. ! eof()
    dDate := c4tod( hu->date_u )
    sDate := dtoc( dDate )
    if ascan( arrDate, { | x | x[ 1 ] == sDate } ) == 0
      i++
      aadd( arrDate, { sDate, i, dDate } )
    endif
    hu->( dbSkip() )
  enddo

  hu->( dbGoto( human_uslugi ) )

  dbSelectArea( 'MOHU' )
  // set relation to u_kod into MOSU
  find ( str(human_number, 7 ) )
  do while mohu->kod == human_number .and. ! eof()
    dDate := c4tod( mohu->date_u )
    sDate := dtoc( dDate )
    if ascan( arrDate, { | x | x[ 1 ] == sDate } ) == 0
      i++
      aadd( arrDate, { sDate, i, dDate } )
    endif
    mohu->( dbSkip() )
  enddo
  mohu->( dbGoto( mohu_usluga ) )

  aSortDate := ASort( arrDate, , , { | x, y | x[ 3 ] < y[ 3 ] } )  
  select( tmp_select )
  return aSortDate

// 20.06.19
Function is_usluga_dvn(ausl, _vozrast, arr, _etap, _pol, _spec_ter)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, j, s, fl := .f., as, lshifr := alltrim(ausl[1]), fl_19

  fl_19 := (type('is_disp_19') == 'L' .and. is_disp_19)
  if !fl_19 .and. ((lshifr == '2.3.3' .and. ausl[3] == 3) .or. ; // акушерскому делу
                  (lshifr == '2.3.1' .and. ausl[3] == 136))   // акушерству и гинекологии
      //.and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
    if ((lshifr == '2.3.3' .and. eq_any(ret_old_prvs(ausl[4]), 2003, 2002)) .or. ;
      (lshifr == '2.3.1' .and. ret_old_prvs(ausl[4]) == 1101))
    else
      aadd(arr, 'не та специальность врача в случае невозможности использования услуги:')
      aadd(arr, ' "4.1.12.Осмотр акушеркой, взятие мазка (соскоба)"')
    endif
    fl := .t.
  endif
  if !fl
    for i := 1 to count_dvn_arr_umolch
      if dvn_arr_umolch[i, 2] == lshifr
        fl := .t.
        exit
      endif
    next
  endif
  if !fl
    DEFAULT _spec_ter to 0
    for i := 1 to count_dvn_arr_usl
      if valtype(dvn_arr_usl[i, 2]) == 'C'
        if dvn_arr_usl[i, 2] == '4.20.1' .and. lshifr == '4.20.2'
          fl := .t.
        elseif dvn_arr_usl[i, 2] == lshifr
          fl := .t.
        endif
      endif
      if !fl .and. len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i, 12]) == 'A'
        if ascan(dvn_arr_usl[i, 12], {|x| x[1] == lshifr .and. x[2] == ausl[3]}) > 0
          fl := .t.
        endif
      endif
      if fl
        s := '"' + lshifr + '.' + dvn_arr_usl[i, 1] + '"'
        if eq_any(_etap, 1, 4, 5)
          j := iif(_pol == 'М', 6, 7)
          if _etap > 1 .and. len(dvn_arr_usl[i]) > 12
            j := iif(_pol == 'М', 13, 14)
          endif
          if valtype(dvn_arr_usl[i, j]) == 'N'
            if dvn_arr_usl[i, j] == 0
              aadd(arr, 'несовместимость по полу в услуге ' + s)
            endif
          else
            if ascan(dvn_arr_usl[i, j], _vozrast) == 0
              aadd(arr, 'некорректный возраст пациента для услуги ' + s)
            endif
          endif
        else
          j := iif(_pol == 'М', 8, 9)
          if valtype(dvn_arr_usl[i, j]) == 'N'
            if dvn_arr_usl[i, j] == 0
              aadd(arr, 'несовместимость по полу в услуге ' + s)
            endif
          elseif type('is_disp_19') == 'L' .and. is_disp_19
            if ascan(dvn_arr_usl[i, j], _vozrast) == 0
              aadd(arr,'некорректный возраст пациента для услуги ' + s)
            endif
          else
            if !between(_vozrast, dvn_arr_usl[i, j, 1], dvn_arr_usl[i, j, 2])
              aadd(arr, 'некорректный возраст пациента для услуги ' + s)
            endif
          endif
        endif
        if valtype(dvn_arr_usl[i, 10]) == 'N'
          if ret_profil_dispans(dvn_arr_usl[i, 10], ausl[4]) != ausl[3]
          //if dvn_arr_usl[i, 10] != ausl[3]
            aadd(arr, 'не тот профиль в услуге ' + s)
          endif
        else
          if ascan(dvn_arr_usl[i, 10], ausl[3]) == 0
            aadd(arr,'не тот профиль в услуге ' + s)
          endif
        endif
        as := aclone(dvn_arr_usl[i, 11])
        // "Измерение внутриглазного давления","3.4.9"
        if _etap == 1 .and. as[1] == 1112 .and. _spec_ter > 0
          aadd(as, _spec_ter) // добавить спец-ть терапевта
        endif
        /*if ascan(as, ausl[4]) == 0
          aadd(arr,'Не та специальность врача в услуге ' + s)
          aadd(arr, ' у Вас: ' + lstr(ausl[4]) + ', разрешено: ' + print_array(as))
        endif*/
        exit
      endif
    next
  endif
  return fl

// 18.05.15
Function is_usluga_dvn13(ausl, _vozrast, arr, _etap, _pol, _spec_ter)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, j, s, fl := .f., as, lshifr := alltrim(ausl[1])

  if ((lshifr == '2.3.3' .and. ausl[3] == 3) .or. ; // акушерскому делу
        (lshifr == '2.3.1' .and. ausl[3] == 136))   // акушерству и гинекологии
        //.and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
    if ((lshifr == '2.3.3' .and. eq_any(ret_old_prvs(ausl[4]), 2003, 2002)) .or. ;
          (lshifr == '2.3.1' .and. ret_old_prvs(ausl[4]) == 1101))
    else
      aadd(arr, 'Не та специальность врача в случае невозможности использования услуги:')
      aadd(arr, ' "4.1.12.Осмотр акушеркой, взятие мазка (соскоба)"')
    endif
    fl := .t.
  endif
  if !fl
    for i := 1 to count_dvn_arr_umolch13
      if dvn_arr_umolch13[i, 2] == lshifr
        fl := .t.
        exit
      endif
    next
  endif
  if !fl
    DEFAULT _spec_ter to 0
    for i := 1 to count_dvn_arr_usl13
      if len(dvn_arr_usl13[i]) < 12 .and. valtype(dvn_arr_usl13[i, 2]) == 'C'
        if dvn_arr_usl13[i, 2] == '4.20.1' .and. lshifr == '4.20.2'
          fl := .t.
        elseif dvn_arr_usl13[i, 2] == lshifr
          fl := .t.
        endif
      elseif len(dvn_arr_usl13[i]) > 11
        if ascan(dvn_arr_usl13[i, 12], {|x| x[1] == lshifr .and. x[2] == ausl[3]}) > 0
          fl := .t.
        endif
      endif
      if fl
        s := '"' + lshifr + '.' + dvn_arr_usl13[i, 1] + '"'
        if _etap == 1
          j := iif(_pol == 'М', 6, 7)
          if valtype(dvn_arr_usl13[i, j]) == 'N'
            if dvn_arr_usl13[i, j] == 0
              aadd(arr, 'Несовместимость по полу в услуге ' + s)
            endif
          else
            if ascan(dvn_arr_usl13[i, j], _vozrast) == 0
              aadd(arr, 'Некорректный возраст пациента для услуги ' + s)
            endif
          endif
        else
          j := iif(_pol == 'М', 8, 9)
          if valtype(dvn_arr_usl13[i, j]) == 'N'
            if dvn_arr_usl13[i, j] == 0
              aadd(arr, 'Несовместимость по полу в услуге ' + s)
            endif
          else
            if !between(_vozrast, dvn_arr_usl13[i, j, 1], dvn_arr_usl13[i, j, 2])
              aadd(arr, 'Некорректный возраст пациента для услуги ' + s)
            endif
          endif
        endif
        if valtype(dvn_arr_usl13[i, 10]) == 'N'
          if ret_profil_dispans(dvn_arr_usl13[i, 10], ausl[4]) != ausl[3]
          //if dvn_arr_usl13[i, 10] != ausl[3]
            aadd(arr, 'Не тот профиль в услуге ' + s)
          endif
        else
          if ascan(dvn_arr_usl13[i, 10], ausl[3]) == 0
            aadd(arr, 'Не тот профиль в услуге ' + s)
          endif
        endif
        as := aclone(dvn_arr_usl13[i, 11])
        // "Измерение внутриглазного давления","3.4.9"
        if _etap == 1 .and. as[1] == 1112 .and. _spec_ter > 0
          aadd(as, _spec_ter) // добавить спец-ть терапевта
        endif
        /*if ascan(as,ausl[4]) == 0
          aadd(arr,'Не та специальность врача в услуге ' + s)
          aadd(arr,' у Вас: '+lstr(ausl[4])+', разрешено: '+print_array(as))
        endif*/
        exit
      endif
    next
  endif
  return fl

// 21.08.24 функция проверки лицензии на диспансеризацию/профилактику
Function license_for_dispans(_tip, _n_data, _ta)

  // список учреждений с датой лицензии на диспансеризацию
  Static arr_date_disp := { ;
    {101003, 1, 0, 20130726}, ;  // 101003;ГБУЗ "ВОКБ № 3";+;;26.07.2013
    {114504, 1, 0, 20130705}, ;  // 114504;ГУЗ "Поликлиника № 4";+;;05.07.2013
    {114506, 1, 0, 20130704}, ;  // 114506;ГУЗ "Поликлиника № 6";+;;04.07.2013
    {115506, 0, 1, 20130718}, ;  // 115506;ГУЗ "Детская поликлиника № 6";;+;18.07.2013
    {115510, 0, 1, 20130719}, ;  // 115510;ГУЗ "ДП № 10";;+;19.07.2013
    {121018, 1, 1, 20130806}, ;  // 121018;ГУЗ "Больница № 18";+;+;06.08.2013
    {124501, 1, 1, 20130829}, ;  // 124501;ГУЗ "Гумракская амбулатория";+;+;29.08.2013
    {124528, 1, 1, 20130805}, ;  // 124528;ГУЗ "Клиническая поликлиника № 28";+;+;05.08.2013
    {124530, 1, 1, 20130703}, ;  // 124530;ГУЗ "Поликлиника № 30";+;+;03.07.2013
    {125505, 0, 1, 20130719}, ;  // 125505;ГУЗ "Детская поликлиника № 5";;+;19.07.2013
    {131020, 0, 1, 20130718}, ;  // 131020;ГУЗ "КДЦ для детей № 1";;+;18.07.2013
    {134505, 1, 0, 20130719}, ;  // 134505;ГУЗ "Поликлиника № 5";+;;19.07.2013
    {134510, 1, 0, 20130729}, ;  // 134510;ГУЗ "Поликлиника № 10";+;;29.07.2013
    {135509, 0, 1, 20130805}, ;  // 135509;ГУЗ "Детская поликлиника № 9";;+;05.08.2013
    {141016, 1, 0, 20130725}, ;  // 141016;ГУЗ "Больница № 16";+;;25.07.2013
    {141022, 1, 0, 20130726}, ;  // 141022;ГУЗ "Больница №22";+;;26.07.2013
    {141023, 1, 0, 20130712}, ;  // 141023;ГУЗ "КБСМП № 15";+;;12.07.2013
    {141024, 1, 0, 20130712}, ;  // 141024;ГУЗ "Больница № 24";+;;12.07.2013
    {145516, 0, 1, 20130729}, ;  // 145516;ГУЗ "Детская поликлиника № 16";;+;29.07.2013
    {145526, 0, 1, 20130727}, ;  // 145526;ГУЗ "Детская поликлиника № 26";;+;27.07.2013
    {154602, 1, 0, 20130701}, ;  // 154602;ГУЗ "Поликлиника № 2";+;;01.07.2013
    {154608, 1, 0, 20130729}, ;  // 154608;ГУЗ "Поликлиника № 8";+;;29.07.2013
    {154620, 1, 0, 20130802}, ;  // 154620;ГУЗ "Поликлиника № 20";+;;02.08.2013
    {155502, 0, 1, 20130730}, ;  // 155502;ГУЗ "Детская поликлиника № 2";;+;30.07.2013
    {155601, 0, 1, 20130729}, ;  // 155601;ГУЗ "Детская поликлиника № 1";;+;29.07.2013
    {161007, 1, 0, 20130725}, ;  // 161007;ГУЗ "КБ СМП № 7";+;;25.07.2013
    {161015, 1, 0, 20130801}, ;  // 161015;ГУЗ "Клиническая больница № 11";+;;01.08.2013
    {165525, 0, 1, 20130802}, ;  // 165525;ГУЗ "Детская поликлиника № 25";;+;02.08.2013
    {165531, 0, 1, 20130801}, ;  // 165531;ГУЗ "ДКП № 31";;+;01.08.2013
    {174601, 1, 0, 20130718}, ;  // 174601;ГУЗ КП № 1;+;;18.07.2013
    {175603, 0, 1, 20130725}, ;  // 175603;ГУЗ "Детская поликлиника № 3";;+;25.07.2013
    {175617, 0, 1, 20130729}, ;  // 175617;ГУЗ "ДП № 17";;+;29.07.2013
    {175627, 0, 1, 20130806}, ;  // 175627;ГУЗ "Детская поликлиника № 27";;+;06.08.2013
    {175709, 1, 0, 20130624}, ;  // 175709;ГУЗ "Клиническая поликлиника № 9";+;;24.06.2013
    {184512, 1, 0, 20130701}, ;  // 184512;ГУЗ "Клиническая поликлиника № 12";+;;01.07.2013
    {184603, 1, 0, 20130701}, ;  // 184603;ГУЗ "Клиническая поликлиника №3";+;;01.07.2013
    {185515, 0, 1, 20130730}, ;  // 185515;ГУЗ "ДКП № 15";;+;30.07.2013
    {251001, 1, 1, 20130713}, ;  // 251001;ГБУЗ "ГКБ № 1 им. С.З.Фишера";+;;13.07.2013
    {251002, 1, 0, 20130705}, ;  // 251002;ГБУЗ "ГКБ №3";+;;05.07.2013
    {251003, 1, 0, 20130730}, ;  // 251003;ГБУЗ "Городская больница № 2";+;;30.07.2013
    {251008, 0, 1, 20130805}, ;  // 251008;ГБУЗ "Городская детская больница";;+;05.08.2013
    {254504, 1, 0, 20130705}, ;  // 254504;ГБУЗ "Поликлиника № 4";+;;05.07.2013
    {254505, 1, 0, 20130711}, ;  // 254505;ГБУЗ "Городская поликлиника №5";+;;11.07.2013
    {254506, 0, 1, 20130809}, ;  // 254506;ГБУЗ "Городская поликлиника № 6";;+;09.08.2013
    {255601, 0, 1, 20130802}, ;  // 255601;ГБУЗ "ГДП № 1";;+;02.08.2013
    {255627, 0, 1, 20130730}, ;  // 255627;ГБУЗ "ГДП №2";;+;30.07.2013
    {255802, 1, 0, 20130703}, ;  // 255802;ГБУЗ "Городская поликлиника № 3";+;;03.07.2013
    {301001, 1, 1, 20130730}, ;  // 301001;ГБУЗ "Алексеевская ЦРБ";+;+;30.07.2013
    {311001, 1, 1, 20130813}, ;  // 311001;ГБУЗ "Быковская ЦРБ";+;+;13.08.2013
    {321001, 1, 1, 20130802}, ;  // 321001;ГБУЗ "Городищенская ЦРБ";+;+;02.08.2013
    {331001, 1, 1, 20130709}, ;  // 331001;ГБУЗ "Даниловская ЦРБ";+;+;09.07.2013
    {341001, 1, 1, 20130802}, ;  // 341001;ГБУЗ "ЦРБ Дубовского муниципального района";+;+;02.08.2013
    {351001, 1, 1, 20130730}, ;  // 351001;ГБУЗ Еланская ЦРБ;+;+;30.07.2013
    {361001, 1, 1, 20130801}, ;  // 361001;ГУЗ "Жирновская ЦРБ";+;+;01.08.2013
    {371001, 1, 1, 20130805}, ;  // 371001;ГБУЗ "Иловлинская ЦРБ";+;+;05.08.2013
    {381001, 1, 1, 20130829}, ;  // 381001;ГБУЗ "Калачевская ЦРБ";+;+;29.08.2013
    {391001, 1, 0, 20130802}, ;  // 391001;ГБУЗ г.Камышина "Городская больница № 1";+;;02.08.2013
    {391002, 1, 0, 20130802}, ;  // 391002;ГБУЗ ЦГБ;+;;02.08.2013
    {391003, 0, 1, 20130805}, ;  // 391003;ГБУЗ "КДГБ";;+;05.08.2013
    {391015, 0, 1, 20131114}, ;  //+391015;ЦРБ Камышинского р-на;;+;14.11.2013
    {395501, 0, 1, 20130809}, ;  // 395501;ГБУЗ "Детская поликлиника Камышинского муниципального района Волгоградской области
    {401001, 1, 1, 20130801}, ;  // 401001;ГБУЗ "Киквидзенская ЦРБ";+;+;01.08.2013
    {411001, 1, 1, 20130713}, ;  // 411001;ГБУЗ "ЦРБ Клетского муниципального района";+;+;13.07.2013
    {421001, 1, 1, 20130806}, ;  // 421001;ГБУЗ "Котельниковская ЦРБ";+;+;06.08.2013
    {431001, 1, 1, 20130809}, ;  // 431001;ГБУЗ ЦРБ Котовского муниципального района;+;+;09.08.2013
    {441001, 1, 1, 20130809}, ;  // 441001;ГБУЗ "Ленинская ЦРБ";+;+;09.08.2013
    {451001, 1, 0, 20130805}, ;  // 451001;ГБУЗ "МЦРБ";+;;05.08.2013
    {451002, 0, 1, 20130717}, ;  // 451002;ГБУЗ "МГДБ";;+;17.07.2013
    {461001, 1, 1, 20130718}, ;  // 461001;ГБУЗ "Нехаевская ЦРБ";+;+;18.07.2013
    {471001, 1, 1, 20130717}, ;  // 471001;ГБУЗ "Николаевская ЦРБ";+;+;17.07.2013
    {481001, 1, 1, 20130801}, ;  // 481001;ГБУЗ "Новоаннинская ЦРБ";+;+;01.08.2013
    {491001, 1, 1, 20130802}, ;  // 491001;ГБУЗ "Новониколаевская ЦРБ";+;+;02.08.2013
    {501001, 1, 1, 20130806}, ;  // 501001;ГБУЗ "Октябрьская ЦРБ";+;+;06.08.2013
    {511001, 1, 1, 20130809}, ;  // 511001;ГБУЗ "ЦРБ Ольховского муниципального района";+;+;09.08.2013
    {521001, 1, 1, 20130716}, ;  // 521001;ГБУЗ "Палласовская ЦРБ";+;+;16.07.2013
    {531001, 1, 1, 20130724}, ;  // 531001;ГБУЗ "Кумылженская ЦРБ";+;+;24.07.2013
    {541001, 1, 1, 20130813}, ;  // 541001;ГБУ "ЦРБ Руднянского муниципального района";+;+;13.08.2013
    {551001, 1, 1, 20130809}, ;  // 551001;ГБУЗ "Светлоярская ЦРБ";+;+;09.08.2013
    {561001, 1, 1, 20130717}, ;  // 561001;ГБУЗ "Серафимовичская ЦРБ";+;+;17.07.2013
    {571001, 1, 1, 20130802}, ;  // 571001;ГБУЗ "Среднеахтубинская ЦРБ";+;+;02.08.2013
    {571002, 1, 0, 20130829}, ;  // 571002;ГБУЗ "Краснослободская городская больница";+;;29.08.2013
    {581001, 1, 1, 20130711}, ;  // 581001;ГБУЗ "Старополтавская ЦРБ";+;+;11.07.2013
    {591001, 1, 1, 20130730}, ;  // 591001;ГБУЗ "ЦРБ Суровикинского муниципального района";+;+;30.07.2013
    {601001, 1, 1, 20130809}, ;  // 601001;ГБУЗ Урюпинская ЦРБ;+;+;09.08.2013
    {611001, 1, 1, 20130802}, ;  // 611001;ГБУЗ "Фроловская ЦРБ";+;+;02.08.2013
    {621001, 1, 1, 20130805}, ;  // 621001;ГБУЗ "Чернышковская ЦРБ";+;+;05.08.2013
    {711001, 1, 0, 20130731}, ;  // 711001;НУЗ "Отделенческая клиническая больница на ст. Волгоград-1 ОАО "РЖД";+;;31.07.2013
    {101201, 1, 0, 20240430} ;   // 101201;ГБУЗ госпиталь ветеранов войн;+;;30.04.2024
   }
  Static mm_tip := {'диспансеризацию/профилактику взрослых', ;
                    'профилактику несовершеннолетних'}
  Local i

  if valtype(arr_date_disp[1, 1]) == 'N' // для первого запуска
    for i := 1 to len(arr_date_disp)
      arr_date_disp[i, 1] := lstr(arr_date_disp[i, 1])
      arr_date_disp[i, 4] := stod(lstr(arr_date_disp[i, 4]))
    next
  endif
  if (i := ascan(arr_date_disp, {|x| x[1] == glob_mo()[ _MO_KOD_TFOMS ] })) > 0
    if arr_date_disp[i, _tip + 1] == 0
      aadd(_ta, 'У Вашей МО нет лицензии на ' + mm_tip[_tip])
    elseif arr_date_disp[i, 4] > _n_data
      aadd(_ta, 'У Вашей МО лицензия на ' + mm_tip[_tip] + ' с ' + date_8(arr_date_disp[i, 4]) + 'г.')
    endif
  else
    aadd(_ta, 'У Вашей МО нет лицензии на ' + mm_tip[_tip])
  endif
  return NIL
  
// 25.08.13 если услуга из 1 этапа
Function is_issled_PerN(ausl, _period, arr, _pol)

  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, s := '', fl := .f., lshifr := alltrim(ausl[1])

  for i := 1 to count_pern_arr_iss
    if nper_arr_issled[i, 1] == lshifr
      s := '"' + lshifr + '.' + nper_arr_issled[i, 3] + '"'
      fl := .t.
      exit
    endif
  next
  if fl .and. nper_arr_issled[i, 4] < 2
    if nper_arr_issled[i, 5] != ausl[3]
      aadd(arr, 'Не тот профиль в иссл-ии ' + s)
    endif
    /*if ascan(nper_arr_issled[i, 6],ausl[4]) == 0
      aadd(arr, 'Не та специальность врача в иссл-ии ' + s)
      aadd(arr, ' у Вас: '+lstr(ausl[4])+', разрешено: '+print_array(nper_arr_issled[i, 6]))
    endif*/
  endif
  return fl
  
// 19.08.13 если услуга из 1 этапа
Function is_1_etap_PredN(ausl, _period, _etap)

  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, fl := .f., lshifr := alltrim(ausl[1])

  for i := 1 to count_predn_arr_osm
    if _etap == 1
      if npred_arr_osmotr[i, 4] == ausl[3]
        lshifr := npred_arr_osmotr[i, 1] // искусственно
        fl := .t.
        exit
      endif
    else
      if npred_arr_osmotr[i, 1] == lshifr
        fl := .t.
        exit
      endif
    endif
  next
  if fl
    fl := (ascan(npred_arr_1_etap[_period, 4], lshifr) > 0)
  endif
  return fl
  
// 13.02.17
Function is_osmotr_PredN(ausl, _period, arr, _etap, _pol)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, s, fl := .f., lshifr := alltrim(ausl[1])
  
  if _etap == 2 .and. (j := ascan(npred_arr_osmotr_KDP2, {|x| x[2] == lshifr})) > 0
    lshifr := npred_arr_osmotr_KDP2[j, 1]
  endif
  for i := 1 to count_predn_arr_osm
    if _etap == 1
      if npred_arr_osmotr[i, 4] == ausl[3]
        lshifr := npred_arr_osmotr[i, 1] // искусственно
        fl := .t.
        exit
      endif
    else
      if npred_arr_osmotr[i, 1] == lshifr
        fl := .t.
        exit
      endif
    endif
  next
  if fl
    s := '"' + lshifr + '.' + npred_arr_osmotr[i, 3] + '"'
    if _etap == 1 .and. ascan(npred_arr_1_etap[_period, 4], lshifr) == 0
      aadd(arr, 'Некорректный возрастной период пациента для ' + s)
    endif
    if !empty(npred_arr_osmotr[i, 2]) .and. !(npred_arr_osmotr[i, 2] == _pol)
      aadd(arr, 'Несовместимость по полу в услуге ' + s)
    endif
    if npred_arr_osmotr[i, 4] != ausl[3]
      aadd(arr, 'Не тот профиль в услуге ' + s)
    endif
    /*if ascan(npred_arr_osmotr[i, 5],ausl[4]) == 0
      aadd(arr,'Не та специальность врача в услуге ' + s)
      aadd(arr,' у Вас: '+lstr(ausl[4])+', разрешено: '+print_array(npred_arr_osmotr[i, 5]))
    endif*/
  endif
  return fl
  
// 19.08.13
Function is_issled_PredN(ausl, _period, arr, _pol)
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, s := '', fl := .f., lshifr := alltrim(ausl[1])

  for i := 1 to count_predn_arr_iss
    if npred_arr_issled[i, 1] == lshifr
      s := '"' + lshifr + '.' + npred_arr_issled[i, 3] + '"'
      if valtype(npred_arr_issled[i, 2]) == 'C' .and. !(npred_arr_issled[i, 2] == _pol)
        aadd(arr, 'Несовместимость по полу в услуге ' + s)
      endif
      fl := .t.
      exit
    endif
  next
  if fl .and. npred_arr_issled[i, 4] < 2
    if ascan(npred_arr_1_etap[_period, 5], lshifr) == 0
      aadd(arr, 'Некорректный возрастной период пациента для ' + s)
    endif
    if npred_arr_issled[i, 5] != ausl[3]
      aadd(arr, 'Не тот профиль в иссл-ии ' + s)
    endif
    /*if ascan(npred_arr_issled[i, 6],ausl[4]) == 0
      aadd(arr,'Не та специальность врача в иссл-ии ' + s)
      aadd(arr,' у Вас: '+lstr(ausl[4])+', разрешено: '+print_array(npred_arr_issled[i, 6]))
    endif*/
  endif
  return fl
  
// проверка, умер ли пациент
Function is_death(_rslt)
  return eq_any(_rslt, 105, 106, 205, 206, 313, 405, 406, 411) // по результату лечения

// 16.09.25
function message_save_LU()

  If mem_op_out == 2 .and. yes_parol
    box_shadow( 19, 10, 22, 69, cColorStMsg )
    str_center( 20, 'Оператор "' + AllTrim( hb_user_curUser:FIO ) + '".', cColorSt2Msg )
    str_center( 21, 'Ввод данных за ' + date_month( Date() ), cColorStMsg )
  Endif
  return nil
