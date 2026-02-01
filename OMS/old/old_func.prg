#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'


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
    for i := 1 to Len( dvn_arr_umolch13() )
      if dvn_arr_umolch13()[i, 2] == lshifr
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

