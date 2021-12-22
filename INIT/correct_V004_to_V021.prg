#include "function.ch"
#include "chip_mo.ch"

***** 22.12.21
function correct_V004_to_V021()
  local i := 0, j := 0
  Local t1 := 0, t2 := 0

  t1 := seconds()

  t2 := seconds() - t1

  Stat_Msg('Заполняем специальность')

  use_base('mo_pers', 'PERS', .t.) // откроем файл mo_pers

  pers->(dbSelectArea())
  pers->(dbGoTop())

  do while ! pers->(Eof())

    // if pers->(dbRLock())
      i++
      @ maxrow(),1 say pers->fio color cColorStMsg
      if ! empty(pers->PRVS_NEW)
        j := 0
        if (j := ascan(glob_arr_V015_V021, {|x| x[1] == pers->PRVS_NEW })) > 0
          pers->PRVS_021 := glob_arr_V015_V021[j, 2]
        endif
      elseif ! empty(pers->PRVS)
        pers->PRVS_021 := ret_prvs_V021(pers->PRVS)
      endif
    // endif
    // pers->(dbRUnlock())

    pers->(dbSkip())
  end do
  
  dbCloseAll()        // закроем все

  if t2 > 0
    n_message({"","Время обхода БД - "+sectotime(t2)},,;
          color1,cDataCSay,,,color8)
  endif
  alertx(i, 'Количество сотрудников')

  return nil