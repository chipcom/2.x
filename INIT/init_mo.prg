#include 'function.ch'
#include 'chip_mo.ch'

** 26.01.23 инициализация массива МО, запрос кода МО (при необходимости)
Function init_mo()
  Local fl := .t., i, arr, arr1, cCode := '', buf := save_maxrow()

//   local aaa
//   aaa := get_array_PZ_2023()
// altd()

  mywait()
  Public oper_parol := 30  // пароль для фискального регистратора
  Public oper_frparol := 30 // пароль для фискального регистратора ОТЧЕТ
  Public oper_fr_inn  := '' // ИНН кассира
  Public glob_arr_mo := {}, glob_mo, glob_podr := '', glob_podr_2 := ''
  Public is_adres_podr := .f., glob_adres_podr := {;
    {'103001',{{'103001',1,'г.Волгоград, ул.Землячки, д.78'},;
               {'103099',2,'г.Михайловка, ул.Мичурина, д.8'},;
               {'103099',3,'г.Волжский, ул.Комсомольская, д.25'},;
               {'103099',4,'г.Волжский, ул.Оломоуцкая, д.33'},;
               {'103099',5,'г.Камышин, ул.Днепровская, д.43'},;
               {'103099',6,'г.Камышин, ул.Мира, д.51'},;
               {'103099',7,'г.Урюпинск, ул.Фридек-Мистек, д.8'}};
    },;
    {'101003',{{'101003',1,'г.Волгоград, ул.Циолковского, д.1'},;
               {'101099',2,'г.Волгоград, ул.Советская, д.47'}};
    },;
    {'131001',{{'131001',1,'г.Волгоград, ул.Кирова, д.10'},;
               {'131099',2,'г.Волгоград, ул.Саши Чекалина, д.7'},;
               {'131099',3,'г.Волгоград, ул.им.Федотова, д.18'}};
    },;
    {'171004',{{'171004',1,'г.Волгоград, ул.Ополченская, д.40'},;
               {'171099',2,'г.Волгоград, ул.Тракторостроителей, д.13'}};
    };
  }

  create_mo_add()
  glob_arr_mo := getMo_mo_New('_mo_mo')

  if hb_FileExists(dir_server + 'organiz' +sdbf)
    R_Use(dir_server + 'organiz',,'ORG')
    if lastrec() > 0
      cCode := left(org->kod_tfoms,6)
    endif
  endif
  close databases
  if !empty(cCode)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
      glob_mo := glob_arr_mo[i]
      if (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
        is_adres_podr := .t.
        glob_podr_2 := glob_adres_podr[i, 2, 2, 1] // второй код для удалённого адреса
      endif
    else
      func_error(4,'В справочник занесён несуществующий код МО "' + cCode + '". Введите его заново.')
      cCode := ''
    endif
  endif
  if empty(cCode)
    if (cCode := input_value(18, 2, 20, 77, color1, ;
                              'Введите код МО или обособленного подразделения, присвоенный ТФОМС', ;
                              space(6), '999999')) != NIL .and. !empty(cCode)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
        glob_mo := glob_arr_mo[i]
        if hb_FileExists(dir_server + 'organiz' + sdbf)
          G_Use(dir_server + 'organiz', , 'ORG')
          if lastrec() == 0
            AddRecN()
          else
            G_RLock(forever)
          endif
          org->kod_tfoms := glob_mo[_MO_KOD_TFOMS]
          org->name_tfoms := glob_mo[_MO_SHORT_NAME]
          org->uroven := get_uroven()
        endif
        close databases
      else
        fl := func_error('Работа невозможна - введённый код МО "' + cCode + '" неверен.')
      endif
    endif
  endif
  if empty(cCode)
    fl := func_error('Работа невозможна - не введён код МО.')
  endif

  rest_box(buf)

  if ! fl
    hard_err('delete')
    QUIT
  endif

  return main_up_screen()