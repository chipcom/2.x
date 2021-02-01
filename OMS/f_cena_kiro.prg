

***** 01.02.21 
Function f_cena_kiro(/*@*/_cena, lkiro, dateSl )
  // _cena - изменяемая цена
  // lkiro - уровень КИРО
  // dateSl - дата случая
  Local _akiro := {0,1}
  local aKIRO, i

  if year(dateSl) == 2021
    aKIRO := getKIROtable( dateSl )
    if (i := ascan(aKIRO, {|x| x[1] == lkiro })) > 0
      if between_date(aKIRO[i, 5], aKIRO[i, 6], dateSl)
        _akiro := { lkiro, aKIRO[i, 4] }
      endif
    endif
  else
    do case
      case lkiro == 1 // менее 4-х дней, выполнено хирург.вмешательство
        _akiro := {lkiro,0.8}
      case lkiro == 2 // менее 4-х дней, хирург.лечение не проводилось
        _akiro := {lkiro,0.2}
      case lkiro == 3 // более 3-х дней, выполнено хирург.вмешательство, лечение прервано
        _akiro := {lkiro,0.9}
      case lkiro == 4 // более 3-х дней, хирург.лечение не проводилось, лечение прервано
        _akiro := {lkiro,0.9}
      case lkiro == 5 // менее 4-х дней, несоблюдение инструкции по приёму препарата
        _akiro := {lkiro,0.2}
      case lkiro == 6 // более 3-х дней, несоблюдение инструкции по приёму препарата, лечение прервано
        _akiro := {lkiro,0.9}
    endcase
  endif
  _cena := round_5(_cena*_akiro[2],0)  // округление до рублей с 2019 года
  return _akiro  