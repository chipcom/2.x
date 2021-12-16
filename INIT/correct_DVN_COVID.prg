#include "function.ch"
#include "chip_mo.ch"

***** 16.12.21
function correct_DVN_COVID()
  local i := 0, j := 0
  local is_DVN_COVID := .f.
  local mkod
  Local t1 := 0, t2 := 0
  local begin_DVN_COVID := 0d20210701   // дата начала углубленной диспансеризации
  local lshifr := ''


  R_Use(dir_server + 'mo_otd', , 'otd')
  OTD->(dbGoTop())
  do while ! otd->(Eof())
    if otd->TIPLU == TIP_LU_DVN_COVID
      is_DVN_COVID := .t.
      exit
    endif

    otd->(dbSkip())
  end do
  otd->(dbCloseArea())

  t1 := seconds()

  if is_DVN_COVID

    Stat_Msg('Проверка и исправление кода врача в листах учета Углубленной диспансеризации')

    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"mo_su",,"MOSU")

    use_base("mo_hu")
    use_base('human_u') // откроем файл human_u и сопутствующие файлы

    R_Use(dir_server + 'human', , 'human')

    human->(dbSelectArea())
    human->(dbGoTop())

    do while ! human->(Eof())
      mkod := human->kod
      if human->k_data >= begin_DVN_COVID
        if human->ishod == 401
          hu->(dbSelectArea())
          hu->(dbseek(str(mkod,7)))
          do while hu->kod == mkod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
              lshifr := usl->shifr
            endif
            lshifr := alltrim(lshifr)
      
            if lshifr == '70.8.1'
              i++
              @ maxrow(),1 say human->fio color cColorStMsg
            endif
            hu->(dbSkip())
          end do

        elseif human->ishod == 402
          j++
        endif
      endif
      human->(dbSelectArea())
      human->(dbSkip())
    end do

    dbCloseAll()        // закроем все

    t2 := seconds() - t1

    if t2 > 0
      n_message({"","Время обхода БД - "+sectotime(t2)},,;
            color1,cDataCSay,,,color8)
    endif
  endif
  alertx(i, 'Количество листов обхода БД этап 1')
  alertx(j, 'Количество листов обхода БД этап 2')

  return nil