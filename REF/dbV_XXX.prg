#include 'hbhash.ch' 
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== V002 ===================
//
#define V002_IDPR     1
#define V002_PRNAME   2
#define V002_DATEBEG  3
#define V002_DATEEND  4

// 23.01.23 вернуть массив по справочнику регионов ТФОМС V002.xml
function getV002(work_date)
  // V002.dbf - Классификатор профилей оказанной медицинской помощи
  //  1 - PRNAME(C)  2 - IDPR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI
  local ret_array

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'idpr, ' + ;
        'prname, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v002')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, V002_PRNAME]), val(aTable[nI, V002_IDPR]), ctod(aTable[nI, V002_DATEBEG]), ctod(aTable[nI, V002_DATEEND])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  return ret_array

// =========== V004 ===================
//
// 22.10.22 вернуть массив по справочнику регионов ТФОМС V004.xml
function getV004()
  //  V004.xml - Классификатор медицинских специальностей
  //  1 - MSPNAME(C)  2 - IDMSP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}
  local empty_date := stod('')
  local date_20110101 := stod('20110101')

  if len(_arr) == 0
    aadd(_arr, {'Высшее медицинское образование', 1, date_20110101, empty_date})
    aadd(_arr, {'Лечебное дело. Педиатрия', 11, date_20110101, empty_date})
    aadd(_arr, {'Акушерство и гинекология', 1101, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 110101, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 110102, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 110103, date_20110101, empty_date})
    aadd(_arr, {'Эндоскопия', 110104, date_20110101, empty_date})
    aadd(_arr, {'Анестезиология и реаниматология', 1103, date_20110101, empty_date})
    aadd(_arr, {'Токсикология', 110301, date_20110101, empty_date})
    aadd(_arr, {'Трансфузиология', 110302, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 110303, date_20110101, empty_date})
    aadd(_arr, {'Дерматовенерология', 1104, date_20110101, empty_date})
    aadd(_arr, {'Клиническая микология', 110401, date_20110101, empty_date})
    aadd(_arr, {'Генетика', 1105, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 110501, date_20110101, empty_date})
    aadd(_arr, {'Инфекционные болезни', 1106, date_20110101, empty_date})
    aadd(_arr, {'Клиническая микология', 110601, date_20110101, empty_date})
    aadd(_arr, {'Клиническая лабораторная диагностика', 1107, date_20110101, empty_date})
    aadd(_arr, {'Бактериология', 110701, date_20110101, empty_date})
    aadd(_arr, {'Вирусология', 110702, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 110703, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная микология', 110704, date_20110101, empty_date})
    aadd(_arr, {'Неврология', 1109, date_20110101, empty_date})
    aadd(_arr, {'Мануальная терапия', 110901, date_20110101, empty_date})
    aadd(_arr, {'Рефлексотерапия', 110902, date_20110101, empty_date})
    aadd(_arr, {'Восстановительная медицина', 110903, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура и спортивная медицина', 110904, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 110905, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 110906, date_20110101, empty_date})
    aadd(_arr, {'Общая врачебная практика (семейная медицина)', 1110, date_20110101, empty_date})
    aadd(_arr, {'Восстановительная медицина', 111001, date_20110101, empty_date})
    aadd(_arr, {'Гериатрия', 111002, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура и спортивная медицина', 111003, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 111004, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 111005, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 111006, date_20110101, empty_date})
    aadd(_arr, {'Эндоскопия', 111007, date_20110101, empty_date})
    aadd(_arr, {'Отоларингология', 1111, date_20110101, empty_date})
    aadd(_arr, {'Сурдология-отоларингология', 111101, date_20110101, empty_date})
    aadd(_arr, {'Офтальмология', 1112, date_20110101, empty_date})
    aadd(_arr, {'Патологическая анатомия', 1113, date_20110101, empty_date})
    aadd(_arr, {'Психиатрия', 1115, date_20110101, empty_date})
    aadd(_arr, {'Психотерапия', 111501, date_20110101, empty_date})
    aadd(_arr, {'Сексология', 111502, date_20110101, empty_date})
    aadd(_arr, {'Судебно-психиатрическая экспертиза', 111503, date_20110101, empty_date})
    aadd(_arr, {'Психиатрия-наркология', 111504, date_20110101, empty_date})
    aadd(_arr, {'Рентгенология', 1118, date_20110101, empty_date})
    aadd(_arr, {'Радиология', 111801, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 111802, date_20110101, empty_date})
    aadd(_arr, {'Скорая медицинская помощь', 1119, date_20110101, empty_date})
    aadd(_arr, {'Восстановительная медицина', 111901, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура и спортивная медицина', 111902, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 111903, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 111904, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 111905, date_20110101, empty_date})
    aadd(_arr, {'Организация здравоохранения и общественное здоровье', 1120, date_20110101, empty_date})
    aadd(_arr, {'Судебно-медицинская экспертиза', 1121, date_20110101, empty_date})
    aadd(_arr, {'Терапия', 1122, date_20110101, empty_date})
    aadd(_arr, {'Гастроэнтерология', 112201, date_20110101, empty_date})
    aadd(_arr, {'Гематология', 112202, date_20110101, empty_date})
    aadd(_arr, {'Гериатрия', 112203, date_20110101, empty_date})
    aadd(_arr, {'Диетология', 112204, date_20110101, empty_date})
    aadd(_arr, {'Кардиология', 112205, date_20110101, empty_date})
    aadd(_arr, {'Клиническая фармакология', 112206, date_20110101, empty_date})
    aadd(_arr, {'Нефрология', 112207, date_20110101, empty_date})
    aadd(_arr, {'Пульмонология', 112208, date_20110101, empty_date})
    aadd(_arr, {'Ревматология', 112209, date_20110101, empty_date})
    aadd(_arr, {'Трансфузиология', 112210, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 112211, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 112212, date_20110101, empty_date})
    aadd(_arr, {'Авиационная и космическая медицина', 112213, date_20110101, empty_date})
    aadd(_arr, {'Аллергология и иммунология', 112214, date_20110101, empty_date})
    aadd(_arr, {'Восстановительная медицина', 112215, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура и спортивная медицина', 112216, date_20110101, empty_date})
    aadd(_arr, {'Мануальная терапия', 112217, date_20110101, empty_date})
    aadd(_arr, {'Профпатология', 112218, date_20110101, empty_date})
    aadd(_arr, {'Рефлексотерапия', 112219, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 112220, date_20110101, empty_date})
    aadd(_arr, {'Эндоскопия', 112221, date_20110101, empty_date})
    aadd(_arr, {'Травматология и ортопедия', 1123, date_20110101, empty_date})
    aadd(_arr, {'Мануальная терапия', 112301, date_20110101, empty_date})
    aadd(_arr, {'Восстановительная медицина', 112302, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура и спортивная медицина', 112303, date_20110101, empty_date})
    aadd(_arr, {'Физиология', 112304, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 1124, date_20110101, empty_date})
    aadd(_arr, {'Фтизиатрия', 1125, date_20110101, empty_date})
    aadd(_arr, {'Пульмонология', 112501, date_20110101, empty_date})
    aadd(_arr, {'Хирургия', 1126, date_20110101, empty_date})
    aadd(_arr, {'Колопроктология', 112601, date_20110101, empty_date})
    aadd(_arr, {'Нейрохирургия', 112602, date_20110101, empty_date})
    aadd(_arr, {'Урология', 112603, date_20110101, empty_date})
    aadd(_arr, {'Сердечно-сосудистая хирургия', 112604, date_20110101, empty_date})
    aadd(_arr, {'Торакальная хирургия', 112605, date_20110101, empty_date})
    aadd(_arr, {'Трансфузиология', 112606, date_20110101, empty_date})
    aadd(_arr, {'Челюстно-лицевая хирургия', 112608, date_20110101, empty_date})
    aadd(_arr, {'Эндоскопия', 112609, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 112610, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 112611, date_20110101, empty_date})
    aadd(_arr, {'Эндокринология', 1127, date_20110101, empty_date})
    aadd(_arr, {'Диабетология', 112701, date_20110101, empty_date})
    aadd(_arr, {'Детская эндокринология', 112702, date_20110101, empty_date})
    aadd(_arr, {'Онкология', 1128, date_20110101, empty_date})
    aadd(_arr, {'Детская онкология', 112801, date_20110101, empty_date})
    aadd(_arr, {'Радиология', 112802, date_20110101, empty_date})
    aadd(_arr, {'Педиатрия', 1134, date_20110101, empty_date})
    aadd(_arr, {'Детская онкология', 113401, date_20110101, empty_date})
    aadd(_arr, {'Детская эндокринология', 113402, date_20110101, empty_date})
    aadd(_arr, {'Детская кардиология', 113403, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура и спортивная медицина', 113404, date_20110101, empty_date})
    aadd(_arr, {'Аллергология и иммунология', 113405, date_20110101, empty_date})
    aadd(_arr, {'Восстановительная медицина', 113406, date_20110101, empty_date})
    aadd(_arr, {'Гастроэнтерология', 113407, date_20110101, empty_date})
    aadd(_arr, {'Гематология', 113408, date_20110101, empty_date})
    aadd(_arr, {'Диетология', 113409, date_20110101, empty_date})
    aadd(_arr, {'Клиническая фармакология', 113410, date_20110101, empty_date})
    aadd(_arr, {'Мануальная терапия', 113411, date_20110101, empty_date})
    aadd(_arr, {'Нефрология', 113412, date_20110101, empty_date})
    aadd(_arr, {'Пульмонология', 113413, date_20110101, empty_date})
    aadd(_arr, {'Ревматология', 113414, date_20110101, empty_date})
    aadd(_arr, {'Трансфузиология', 113415, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 113416, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 113417, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 113418, date_20110101, empty_date})
    aadd(_arr, {'Эндоскопия', 113419, date_20110101, empty_date})
    aadd(_arr, {'Детская хирургия', 1135, date_20110101, empty_date})
    aadd(_arr, {'Детская онкология', 113501, date_20110101, empty_date})
    aadd(_arr, {'Детская урология-андрология', 113502, date_20110101, empty_date})
    aadd(_arr, {'Колопроктология', 113503, date_20110101, empty_date})
    aadd(_arr, {'Нейрохирургия', 113504, date_20110101, empty_date})
    aadd(_arr, {'Сердечно-сосудистая хирургия', 113505, date_20110101, empty_date})
    aadd(_arr, {'Торакальная хирургия', 113506, date_20110101, empty_date})
    aadd(_arr, {'Трансфузиология', 113507, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 113508, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 113509, date_20110101, empty_date})
    aadd(_arr, {'Челюстно-лицевая хирургия', 113510, date_20110101, empty_date})
    aadd(_arr, {'Эндоскопия', 113511, date_20110101, empty_date})
    aadd(_arr, {'Неонатология', 1136, date_20110101, empty_date})
    aadd(_arr, {'Медико-профилактическое дело', 13, date_20110101, empty_date})
    aadd(_arr, {'Клиническая лабораторная диагностика', 1301, date_20110101, empty_date})
    aadd(_arr, {'Бактериология', 130101, date_20110101, empty_date})
    aadd(_arr, {'Вирусология', 130102, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 130103, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная микология', 130104, date_20110101, empty_date})
    aadd(_arr, {'Эпидемиология', 1302, date_20110101, empty_date})
    aadd(_arr, {'Бактериология', 130201, date_20110101, empty_date})
    aadd(_arr, {'Дезинфектология', 130203, date_20110101, empty_date})
    aadd(_arr, {'Паразитология', 130204, date_20110101, empty_date})
    aadd(_arr, {'Вирусология', 130205, date_20110101, empty_date})
    aadd(_arr, {'Общая гигиена', 1303, date_20110101, empty_date})
    aadd(_arr, {'Гигиена детей и подростков', 130301, date_20110101, empty_date})
    aadd(_arr, {'Гигиеническое воспитание', 130302, date_20110101, empty_date})
    aadd(_arr, {'Гигиена питания', 130303, date_20110101, empty_date})
    aadd(_arr, {'Гигиена труда', 130304, date_20110101, empty_date})
    aadd(_arr, {'Коммунальная гигиена', 130305, date_20110101, empty_date})
    aadd(_arr, {'Радиационная гигиена', 130306, date_20110101, empty_date})
    aadd(_arr, {'Санитарно-гигиенические лабораторные исследования', 130307, date_20110101, empty_date})
    aadd(_arr, {'Социальная гигиена и организация госсанэпидслужбы', 1306, date_20110101, empty_date})
    aadd(_arr, {'Стоматология', 14, date_20110101, empty_date})
    aadd(_arr, {'Стоматология общей практики', 1401, date_20110101, empty_date})
    aadd(_arr, {'Ортодонтия', 140101, date_20110101, empty_date})
    aadd(_arr, {'Стоматология детская', 140102, date_20110101, empty_date})
    aadd(_arr, {'Стоматология терапевтическая', 140103, date_20110101, empty_date})
    aadd(_arr, {'Стоматология ортопедическая', 140104, date_20110101, empty_date})
    aadd(_arr, {'Стоматология хирургическая', 140105, date_20110101, empty_date})
    aadd(_arr, {'Челюстно-лицевая хирургия', 140106, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 140107, date_20110101, empty_date})
    aadd(_arr, {'Клиническая лабораторная диагностика', 1402, date_20110101, empty_date})
    aadd(_arr, {'Бактериология', 140201, date_20110101, empty_date})
    aadd(_arr, {'Вирусология', 140202, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 140203, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная микология', 140204, date_20110101, empty_date})
    aadd(_arr, {'Фармация', 15, date_20110101, empty_date})
    aadd(_arr, {'Управление и экономика фармации', 1501, date_20110101, empty_date})
    aadd(_arr, {'Фармацевтическая технология', 1502, date_20110101, empty_date})
    aadd(_arr, {'Фармацевтическая химия и фармакогнозия', 1503, date_20110101, empty_date})
    aadd(_arr, {'Сестринское дело', 16, date_20110101, empty_date})
    aadd(_arr, {'Управление сестринской деятельностью', 1601, date_20110101, empty_date})
    aadd(_arr, {'Медицинская биохимия', 17, date_20110101, empty_date})
    aadd(_arr, {'Генетика', 1701, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 170101, date_20110101, empty_date})
    aadd(_arr, {'Клиническая лабораторная диагностика', 1702, date_20110101, empty_date})
    aadd(_arr, {'Бактериология', 170201, date_20110101, empty_date})
    aadd(_arr, {'Вирусология', 170202, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 170203, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная микология', 170204, date_20110101, empty_date})
    aadd(_arr, {'Судебно-медицинская экспертиза', 1703, date_20110101, empty_date})
    aadd(_arr, {'Медицинская биофизика. Медицинская кибернетика', 18, date_20110101, empty_date})
    aadd(_arr, {'Клиническая лабораторная диагностика', 1801, date_20110101, empty_date})
    aadd(_arr, {'Бактериология', 180101, date_20110101, empty_date})
    aadd(_arr, {'Вирусология', 180102, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная генетика', 180103, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная микология', 180104, date_20110101, empty_date})
    aadd(_arr, {'Рентгенология', 1802, date_20110101, empty_date})
    aadd(_arr, {'Радиология', 180201, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 180202, date_20110101, empty_date})
    aadd(_arr, {'Ультразвуковая диагностика', 180203, date_20110101, empty_date})
    aadd(_arr, {'Среднее медицинское и фармацевтическое образование', 2, date_20110101, empty_date})
    aadd(_arr, {'Организация сестринского дела', 2001, date_20110101, empty_date})
    aadd(_arr, {'Лечебное дело', 2002, date_20110101, empty_date})
    aadd(_arr, {'Акушерское дело', 2003, date_20110101, empty_date})
    aadd(_arr, {'Стоматология', 2004, date_20110101, empty_date})
    aadd(_arr, {'Стоматология ортопедическая', 2005, date_20110101, empty_date})
    aadd(_arr, {'Эпидемиология (паразитология)', 2006, date_20110101, empty_date})
    aadd(_arr, {'Гигиена и санитария', 2007, date_20110101, empty_date})
    aadd(_arr, {'Дезинфекционное дело', 2008, date_20110101, empty_date})
    aadd(_arr, {'Гигиеническое воспитание', 2009, date_20110101, empty_date})
    aadd(_arr, {'Энтомология', 2010, date_20110101, empty_date})
    aadd(_arr, {'Лабораторная диагностика', 2011, date_20110101, empty_date})
    aadd(_arr, {'Гистология', 2012, date_20110101, empty_date})
    aadd(_arr, {'Лабораторное дело', 2013, date_20110101, empty_date})
    aadd(_arr, {'Фармация', 2014, date_20110101, empty_date})
    aadd(_arr, {'Сестринское дело', 2015, date_20110101, empty_date})
    aadd(_arr, {'Сестринское дело в педиатрии', 2016, date_20110101, empty_date})
    aadd(_arr, {'Операционное дело', 2017, date_20110101, empty_date})
    aadd(_arr, {'Анестезиология и реаниматология', 2018, date_20110101, empty_date})
    aadd(_arr, {'Общая практика', 2019, date_20110101, empty_date})
    aadd(_arr, {'Рентгенология', 2020, date_20110101, empty_date})
    aadd(_arr, {'Функциональная диагностика', 2021, date_20110101, empty_date})
    aadd(_arr, {'Физиотерапия', 2022, date_20110101, empty_date})
    aadd(_arr, {'Медицинский массаж', 2023, date_20110101, empty_date})
    aadd(_arr, {'Лечебная физкультура', 2024, date_20110101, empty_date})
    aadd(_arr, {'Диетология', 2025, date_20110101, empty_date})
    aadd(_arr, {'Медицинская статистика', 2026, date_20110101, empty_date})
    aadd(_arr, {'Стоматология профилактическая', 2027, date_20110101, empty_date})
    aadd(_arr, {'Судебно-медицинская экспертиза', 2028, date_20110101, empty_date})
    aadd(_arr, {'Медицинская оптика', 2029, date_20110101, empty_date})
    aadd(_arr, {'Естественные науки', 3, date_20110101, empty_date})
    aadd(_arr, {'Биофизика', 31, date_20110101, empty_date})
    aadd(_arr, {'Медицинская биофизика', 3101, date_20110101, empty_date})
    aadd(_arr, {'Медицинская кибернетика', 3102, date_20110101, empty_date})
    aadd(_arr, {'Биохимия', 32, date_20110101, empty_date})
    aadd(_arr, {'Медицинская биохимия', 3201, date_20110101, empty_date})
  endif

  return _arr

// =========== V005 ===================
//
// 22.10.22 вернуть Классификатор пола застрахованного V005.xml
function getV005()
  // V005.xml - Классификатор пола застрахованного
  //  1 - POLNAME(C)  2 - IDPOL(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}
  local empty_date := stod('')

  if len(_arr) == 0
    aadd(_arr, {'Мужской', 1, empty_date, empty_date})
    aadd(_arr, {'Женский', 2, empty_date, empty_date})
  endif

  return _arr

// =========== V006 ===================
//
// 18.05.22 вернуть условиt оказания медицинской помощи по коду
function getUSLOVIE_V006( kod )
  local ret := NIL
  local i

  if (i := ascan(getV006(), {|x| x[2] == kod })) > 0
    ret := getV006()[i,1]
  endif
  return ret

// 28.02.21 вернуть Классификатор условий оказания медицинской помощи V006.xml
function getV006()
  // V006.xml - Классификатор условий оказания медицинской помощи
  //  1 - UMPNAME(C)  2 - IDUMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}
  local empty_date := stod('')
  local date_20110101 := stod('20110101')

  if len(_arr) == 0
    aadd(_arr, {'Стационар', 1, date_20110101, empty_date})
    aadd(_arr, {'Дневной стационар', 2, date_20110101, empty_date})
    aadd(_arr, {'Поликлиника', 3, date_20110101, empty_date})
    aadd(_arr, {'Скорая помощь', 4, stod('20130101'), empty_date})
  endif

  return _arr

// =========== V008 ===================
//
// 22.10.22 вернуть Классификатор видов медицинской помощи V008.xml
function getV008()
  // V008.xml - Классификатор видов медицинской помощи
  //  1 - VMPNAME(C)  2 - IDVMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}
  local empty_date := stod('')
  local date_20110101 := stod('20110101')

  if len(_arr) == 0
    aadd(_arr, {'Первичная медико-санитарная помощь', 1, date_20110101, empty_date})
    aadd(_arr, {'Скорая, в том числе специализированная (санитарно-авиационная), медицинская помощь', 2, stod('20130101'), empty_date})
    aadd(_arr, {'Специализированная, в том числе высокотехнологичная, медицинская помощь', 3, date_20110101, empty_date})
  endif

  return _arr

// =========== V009 ===================
//
#define V009_IDRMP    1
#define V009_RMPNAME  2
#define V009_DL_USLOV 3
#define V009_DATEBEG  4
#define V009_DATEEND  5

// 23.01.23 вернуть массив по справочнику ТФОМС V009.xml
function getV009(work_date)
  // V009.xml - Классификатор результатов обращения за медицинской помощью
  static _arr
  local stroke := '', vid := ''
  static time_load
  local db
  local aTable, row
  local nI
  local ret_array

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idrmp, ' + ;
      'rmpname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v009')  // WHERE dateend == "    -  -  "')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if val(aTable[nI, V009_DL_USLOV]) == 1
          vid := '/ст-р/'
        elseif val(aTable[nI, V009_DL_USLOV]) == 2
          vid := '/дн.с/'
        elseif val(aTable[nI, V009_DL_USLOV]) == 3
          vid := '/п-ка/'
        else
          vid := '/'
        endif
        stroke := str(val(aTable[nI, V009_IDRMP]), 3) + vid + alltrim(aTable[nI, V009_RMPNAME])
        aadd(_arr, {stroke, val(aTable[nI, V009_IDRMP]), ctod(aTable[nI, V009_DATEBEG]), ctod(aTable[nI, V009_DATEEND]), val(aTable[nI, V009_DL_USLOV])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

  endif
  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  return ret_array

// 04.11.22 вернуть результат обращения за медицинской помощью по коду
function getRSLT_V009(result)
  local ret := NIL
  local i

  if (i := ascan(getV009(), {|x| x[2] == result})) > 0
      ret := getV009()[i, 1]
  endif
  return ret

// 23.01.23 вернуть результат обращения по условию оказания и дате
function getRSLT_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV009(date)
    if uslovie == row[5]
      aadd(ret, row)
    endif
  next
  return ret

// =========== V010 ===================
//
#define V010_IDSP     1
#define V010_SPNAME   2
#define V010_DATEBEG  3
#define V010_DATEEND  4

// 26.01.23 вернуть массив по справочнику ФФОМС V010.xml
function getV010(work_date)
  // V010.xml - Классификатор способов оплаты медицинской помощи
  static _arr
  static time_load
  local stroke := ''
  local db
  local aTable
  local nI
  local ret_array, row

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'idsp, ' + ;
        'spname, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v010')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        stroke := StrZero(val(aTable[nI, V010_IDSP]), 2, 0) + '/' + alltrim(aTable[nI, V010_SPNAME])
        aadd(_arr, {stroke, val(aTable[nI, V010_IDSP]), alltrim(aTable[nI, V010_SPNAME]), ctod(aTable[nI, V010_DATEBEG]), ctod(aTable[nI, V010_DATEEND])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  return ret_array

// =========== V012 ===================
//
#define V012_IDIZ     1
#define V012_IZNAME   2
#define V012_DL_USLOV 3
#define V012_DATEBEG  4
#define V012_DATEEND  5

// 23.01.23 вернуть массив по справочнику ФФОМС V012.xml
function getV012(work_date)
  // V012.xml - Классификатор исходов заболевания
  static _arr
  static time_load
  local stroke := '', vid := ''
  local db
  local aTable, row
  local nI
  local ret_array

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'idiz, ' + ;
        'izname, ' + ;
        'dl_uslov, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v012')   // WHERE dateend == "    -  -  "')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        // if empty(ctod(aTable[nI, 5]))  // только если поле окончания действия пусто
        if val(aTable[nI, V012_DL_USLOV]) == 1
          vid := '/ст-р/'
        elseif val(aTable[nI, V012_DL_USLOV]) == 2
          vid := '/дн.с/'
        elseif val(aTable[nI, V012_DL_USLOV]) == 3
          vid := '/п-ка/'
        else
          vid := '/'
        endif
        stroke := str(val(aTable[nI, V012_IDIZ]), 3) + vid + alltrim(aTable[nI, V012_IZNAME])
        aadd(_arr, { stroke, val(aTable[nI, V012_IDIZ]), ctod(aTable[nI, V012_DATEBEG]), ctod(aTable[nI, V012_DATEEND]), val(aTable[nI, V012_DL_USLOV])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  return ret_array

// 06.11.22 вернуть исход заболевания по коду
function getISHOD_V012(ishod)
  local ret := NIL
  local i

  if (i := ascan(getV012(), {|x| x[2] == ishod})) > 0
    ret := getV012()[i, 1]
  endif
  return ret

// 23.01.23 вернуть исход заболевания по условию оказания и дате
function getISHOD_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV012(date)
    if uslovie == row[5]
      aadd(ret, row)
    endif
  next
  return ret

// =========== V014 ===================
//
// 21.10.22 вернуть Классификатор форм медицинской помощи V014.xml
function getV014()
  // V014.xml - Классификатор форм медицинской помощи
  //  1 - FRMMPNAME(C)  2 - IDFRMMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}
  local empty_date := stod('')

  if len(_arr) == 0
    aadd(_arr, {'Экстренная', 1, stod('20130101'), empty_date})
    aadd(_arr, {'Неотложная', 2, stod('20130101'), empty_date})
    aadd(_arr, {'Плановая', 3, stod('20130101'), empty_date})
  endif

  return _arr

// =========== V015 ===================
//
// 26.01.23 вернуть массив по справочнику V015.xml
// возвращает массив V015
function getV015()
  // V015.xml - Классификатор медицинских специальностей
  static _arr
  static time_load
  local db
  local aTable
  local nI
  
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'recid, ' + ;
        'code, ' + ;
        'name, ' + ;
        'high, ' + ;
        'okso, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v015')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 2]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), ctod(aTable[nI, 6]), ctod(aTable[nI, 7]), val(aTable[nI, 1])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

    asort(_arr, , ,{|x, y| x[2] < y[2]})
  endif
  return _arr

// =========== V016 ===================
//
// 26.01.23 вернуть Классификатор видов диспансеризации/профосмотров V016.xml
function getV016()
  // V016.xml - Классификатор видов диспансеризации/профосмотров
  static _arr
  static time_load
  local ar := {}
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT iddt, dtname, rule, datebeg, dateend FROM v016')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        ar := list2Arr(aTable[nI, 3])
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ar, ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  return _arr

// 13.12.21 вернуть описатель типа диспнсеризации по коду
function get_type_DispT(mdate, codeDispT)
  local dispT := Upper(alltrim(codeDispT))
  local _arr := {}, i
  local tmpArr := getV016()
  local lengthArr := len(tmpArr)

  for i := 1 to lengthArr
    if dispT == tmpArr[i, 1] .and. between_date(tmpArr[i, 4], tmpArr[i, 5], mdate)
      aadd(_arr, tmpArr[i, 1])
      aadd(_arr, tmpArr[i, 2])
      aadd(_arr, tmpArr[i, 3])
    endif
  next
  return _arr

// =========== V017 ===================
//
// 26.01.23 вернуть Классификатор результатов диспансеризации (DispR) V017.xml
function getV017()
  // V017.xml - Классификатор результатов диспансеризации (DispR)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT iddr, drname, datebeg, dateend FROM v017')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// 13.12.21 вернуть список результатов диспансеризации на дату в соответствии со списком кодов
function get_list_DispR(mdate, arrDR)
  local _arr := {}, code, i
  local tmpArr := getV017()
  local lenArr := len(tmpArr)

  for each code in arrDR
    for i := 1 to lenArr
      if code == tmpArr[i, 1] .and. between_date(tmpArr[i, 3], tmpArr[i, 4], mdate)
        aadd(_arr, tmpArr[i, 2])
      endif
    next
  next

  return _arr

// =========== V018 ===================
//
// 25.01.23 возвращает массив V018 на указанную дату
function getV018( dateSl )
  local yearSl := year(dateSl)
  local _arr
  local db
  local aTable, stmt
  local nI

  static hV018, lHashV018 := .f.

  // при отсутствии ХЭШ-массива создадим его
  if !lHashV018
    hV018 := hb_Hash()
    lHashV018 := .t.
  endif

  // получим массив V018 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hV018, yearSl )
    _arr := hb_HGet(hV018, yearSl)
  else
    _arr := {}

    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idhvid, ' + ;
      'hvidname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v018')

    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if (year(ctod(aTable[nI, 3])) <= yearSl) .and. (empty(ctod(aTable[nI, 4])) .or. year(ctod(aTable[nI, 4])) >= yearSl)   // только если поле окончания действия пусто
          aadd(_arr, { alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
        endif
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    asort(_arr,,,{|x,y| x[1] < y[1] })
    // поместим в ХЭШ-массив
    hV018[yearSl] := _arr
  endif
  if empty(_arr)
    alertx('На дату ' + DToC(dateSl) + ' V018 отсутствуют!')
  endif
  return _arr

// =========== V019 ===================
//
// 25.01.23 возвращает массив V019
function getV019( dateSl )
  local yearSl := year(dateSl)
  local _arr
  local db
  local aTable, stmt
  local nI

  static hV019, lHashV019 := .f.

  // при отсутствии ХЭШ-массива создадим его
  if !lHashV019
    hV019 := hb_Hash()
    lHashV019 := .t.
  endif

  // получим массив V019 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hV019, yearSl )
    _arr := hb_HGet(hV019, yearSl)
  else
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idhm, ' + ;
      'hmname, ' + ;
      'diag, ' + ;
      'hvid, ' + ;
      'hgr, ' + ;
      'hmodp, ' + ;
      'idmodp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v019')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
      if (year(ctod(aTable[nI, 8])) <= yearSl) .and. (empty(ctod(aTable[nI, 9])) .or. year(ctod(aTable[nI, 9])) >= yearSl)   // только если поле окончания действия пусто
          aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ;
            aclone(Split(alltrim(aTable[nI, 3]), ', ')), ;
            alltrim(aTable[nI, 4]), ctod(aTable[nI, 8]), ctod(aTable[nI, 9]), ;
            val(aTable[nI, 5]), val(aTable[nI, 7]) ;
          })
        endif
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    asort(_arr, , , {|x, y| x[1] < y[1] })
    hV019[yearSl] := _arr
  endif
  return _arr

// =========== V020 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V020.xml - Классификатор профилей койки
function getV020()
  static _arr
  static time_load
  local db
  local aTable, stmt
  local nI


  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idk_pr, ' + ;
      'k_prname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v020')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// =========== V021 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V021.xml
function getV021()
  // V021.xml - Классификатор медицинских специальностей (должностей) (MedSpec)
  //  1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - POSTNAME(C)  6 - IDPOST_MZ(C)

  static _arr   // := {}
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
        'idspec, ' + ;
        'idspec || "." || trim(specname), ' +;
        'postname, ' + ;
        'idpost_mz, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v021 WHERE dateend == "    -  -  "')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
          aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// 27.02.23 вернуть массив описывающий специальность
Function DoljBySpec_V021(idspec)
  Local i, retArray := ''
  local aV021 := getV021()

  if !empty(idspec) .and. ((i := ascan(aV021, {|x| x[2] == idspec})) > 0)
    retArray := aV021[i, 5]
  endif
  return retArray

// =========== V022 ===================
//
// 26.01.23 возвращает массив V022
function getV022()
  static _arr
  static time_load
  local db
  local aTable, stmt
  local nI
  
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idmpac, ' + ;
      'mpacname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v022')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    asort(_arr, , , {|x, y| x[1] < y[1] })
  endif
  return _arr

// 11.02.21 вернуть строку модели пациента ВМП
Function ret_V022(idmpac, lk_data)
  Local i, s := space(10)
  local aV022 := getV022()

  if !empty(idmpac) .and. ((i := ascan(aV022, {|x| x[1] == idmpac })) > 0)
    s := aV022[i, 2]
  endif
  return s

// =========== V025 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V025 Классификатор целей посещения (KPC)
function getV025()
  static _arr
  static time_load
  local i
  local db
  local aTable
  local nI
  
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idpc, ' + ;
      'n_pc, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v025')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]) + '-' + alltrim(aTable[nI, 2]), nI - 1, alltrim(aTable[nI, 1]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

function get_IDPC_from_V025_by_number(num)
  local tableV025 := getV025()
  local row
  local retIDPC := ''

  for each row in tableV025
    if row[2] == num
      retIDPC := row[3]
      exit
    endif
  next
  return retIDPC

// =========== V030 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V030.xml
function getV030()
  // V030.xml - Схемы лечения заболевания COVID-19 (TreatReg)
  //  1 - SCHEMCOD(C) 2 - SCHEME(C) 3 - DEGREE(N) 4 - COMMENT(M)  5 - DATEBEG(D)  6 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'schemcode, ' + ;
      'scheme, ' + ;
      'degree, ' + ;
      'comment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v030')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1]), ;
            val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ;
            ctod(aTable[nI, 5]), ctod(aTable[nI, 6]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// 11.01.22 вернуть схемы лечения согласно тяжести пациента
function get_schemas_lech(_degree, ldate)
  local _arr := {}, row

//  local db
//  local stmt
//  local d1, d2

  if ValType(_degree) == 'C' .and. empty(_degree)
    return _arr
  endif
  if ValType(_degree) == 'N' .and. _degree == 0
    return _arr
  endif

//  db := openSQL_DB()
//  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
///  stmt := sqlite3_prepare( db, 'SELECT ' + ;
//    'schemcode, ' + ;
//    'scheme, ' + ;
//    'degree, ' + ;
//    'comment, ' + ;
//    'datebeg, ' + ;
//    'dateend ' + ;
//    'FROM v030 WHERE ( degree = :degree )' )
//    // 'FROM v030 WHERE ( degree = :degree ) AND ( DATE(:l_date) BETWEEN dategeg AND dateend)' )

//  sqlite3_reset( stmt )  
//  if sqlite3_bind_int( stmt, 1, _degree ) == SQLITE_OK
//    // .AND. sqlite3_bind_text( stmt, 2, dtoc( ldate ) ) == SQLITE_OK
//    do while sqlite3_step( stmt ) == SQLITE_ROW
//      d1 := ctod(sqlite3_column_text( stmt, 5 ))
//      d2 := ctod(sqlite3_column_text( stmt, 6 ))
//      if between_date(d1, d2, ldate)
//        aadd(_arr, {alltrim(sqlite3_column_text( stmt, 2 )), alltrim(sqlite3_column_text( stmt, 1 )), ;
//          sqlite3_column_int( stmt, 3 ), alltrim( hb_Utf8ToStr( sqlite3_column_blob( stmt, 4 ), 'RU866' ) ), ;
//          d1, d2 ;
//        })
//      endif
//    enddo
//  endif

//  sqlite3_clear_bindings( stmt )
//  sqlite3_finalize( stmt )
//  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
//  db := nil

  for each row in getV030()
    if (row[3] == _degree) .and. between_date(row[5], row[6], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next
  return _arr

// 07.01.22 вернуть наименование схемы
Function ret_schema_V030(s_code)
  // s_code - код схемы
  Local i, ret := ''
  local code := alltrim(s_code)
  
  if !empty(code) .and. ((i := ascan(getV030(), {|x| x[2] == code })) > 0)
    ret := getV030()[i, 1]
  endif
  return ret

// =========== V031 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V031.xml
function getV031()
  // V031.xml - Группы препаратов для лечения заболевания COVID-19 (GroupDrugs)
  //  1 - DRUGCODE(N) 2 - DRUGGRUP(C) 3 - INDMNN(N)  4 - DATEBEG(D)  5 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT drugcode, druggrup, indmnn, datebeg, dateend FROM v031')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// 29.08.22 вернуть группу препаратов
function get_group_prep_by_kod(_code, ldate)
  local _arr, row, code

  if ValType(_code) == 'C'
    code := val(substr(_code, len(_code)))
  elseif ValType(_code) == 'N'
    code := _code
  else
    return _arr
  endif
    
  for each row in getV031()
    if (row[1] == code) .and. between_date(row[4], row[5], ldate)
      _arr := { row[1], row[2], row[3], row[4], row[5] }
    endif
  next
  return _arr

// =========== V032 ===================
//
// 26.01.22 вернуть массив по справочнику ФФОМС V032.xml
function getV032()
  // V032.xml - Сочетание схемы лечения и группы препаратов (CombTreat)
  //  1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT schedrug, name, schemcode, datebeg, dateend FROM v032')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  return _arr

// 04.01.22 вернуть сочетание схемы и группы препаратов
function get_group_by_schema_lech(_scheme, ldate)
  local _arr := {}, row

  for each row in getV032()
    if (row[3] == alltrim(_scheme)) .and. between_date(row[4], row[5], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4], row[5] })
    endif
  next
  return _arr

// 08.01.22 вернуть наименование кода схемы
Function ret_schema_V032(s_code)
  // s_code - код схемы
  Local i, ret := ''
  local code := alltrim(s_code)
  
  if !empty(code) .and. ((i := ascan(getV032(), {|x| x[2] == code })) > 0)
    ret := getV032()[i, 1]
  endif
  return ret

// =========== V033 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V033.xml
function getV033()
  // V033.xml - Соответствие кода препарата схеме лечения (DgTreatReg)
  //  1 - SCHEDRUG(C) 2 - DRUGCODE(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT schedrug, drugcode, datebeg, dateend FROM v033')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  return _arr

// 04.01.22 вернуть соответствие кода препарата схеме лечения
function get_drugcode_by_schema_lech(_schemeDrug, ldate)
  local _arr := {}, row

  for each row in getV033()
    if (row[1] == alltrim(_schemeDrug)) .and. between_date(row[3], row[4], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4] })
    endif
  next
  return _arr

// =========== V036 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V036.xml
function getV036()
  // V036.xml - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)
  //  1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT s_code, name, param, comment, datebeg, dateend FROM v036')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// =========== V024 ===================
//
// 25.09.23 вернуть массив по справочнику ФФОМС V036.xml
function getV024(dk)
  // V024.xml - Классификатор классификационных критериев (DopKr)
  //  1 - IDDKK(C) 2 - DKKNAME(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  local arr
  local db
  local aTable
  local nI
  local dBeg, dEnd

  arr := {}
  if ValType(dk) == 'N'
    dBeg := "'" + str(dk, 4) + "-01-01 00:00:00'"
    dEnd := "'" + str(dk, 4) + "-12-31 00:00:00'"
  elseif ValType(dk) == 'D'
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    dBeg := "'" + dtos(dk) + "-01-01 00:00:00'"
    dEnd := "'" + dtos(dk) + "-12-31 00:00:00'"
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  endif

  db := openSQL_DB()
  aTable := sqlite3_get_table(db, "SELECT " + ;
      "iddkk, " + ;
      "dkkname, " + ;
      "datebeg, " + ;
      "dateend " + ;
      "FROM v024 " + ;
      "WHERE datebeg <= " + dBeg + ;
      "AND dateend >= " + dEnd)
  if len(aTable) > 1
    for nI := 2 to Len( aTable )
      Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
      dBeg := ctod(aTable[nI, 3])
      dEnd := ctod(aTable[nI, 4])
      Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )

      aadd(arr, {aTable[nI, 1], aTable[nI, 2], dBeg, dEnd})
    next
  endif
  db := nil
  return arr
