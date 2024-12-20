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
Function getv002( work_date )

  // V002.dbf - Классификатор профилей оказанной медицинской помощи
  // 1 - PRNAME(C)  2 - IDPR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idpr, ' + ;
      'prname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v002' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, V002_PRNAME ] ), Val( aTable[ nI, V002_IDPR ] ), CToD( aTable[ nI, V002_DATEBEG ] ), CToD( aTable[ nI, V002_DATEEND ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// =========== V004 ===================
//
// 20.12.24 вернуть массив по справочнику регионов ТФОМС V004.xml
Function getv004_new()

  // V004.xml - Классификатор медицинских специальностей
  // MSPNAME(C), IDMSP(N), DATEBEG(D), DATEEND(D)
  Static _arr := {}
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'mspname, ' + ;
      'idmsp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v004' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  return _arr

// 22.10.22 вернуть массив по справочнику регионов ТФОМС V004.xml
Function getv004()

  // V004.xml - Классификатор медицинских специальностей
  // 1 - MSPNAME(C)  2 - IDMSP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Высшее медицинское образование', 1, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебное дело. Педиатрия', 11, date_20110101, empty_date } )
    AAdd( _arr, { 'Акушерство и гинекология', 1101, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 110101, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 110102, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 110103, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндоскопия', 110104, date_20110101, empty_date } )
    AAdd( _arr, { 'Анестезиология и реаниматология', 1103, date_20110101, empty_date } )
    AAdd( _arr, { 'Токсикология', 110301, date_20110101, empty_date } )
    AAdd( _arr, { 'Трансфузиология', 110302, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 110303, date_20110101, empty_date } )
    AAdd( _arr, { 'Дерматовенерология', 1104, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая микология', 110401, date_20110101, empty_date } )
    AAdd( _arr, { 'Генетика', 1105, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 110501, date_20110101, empty_date } )
    AAdd( _arr, { 'Инфекционные болезни', 1106, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая микология', 110601, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая лабораторная диагностика', 1107, date_20110101, empty_date } )
    AAdd( _arr, { 'Бактериология', 110701, date_20110101, empty_date } )
    AAdd( _arr, { 'Вирусология', 110702, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 110703, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная микология', 110704, date_20110101, empty_date } )
    AAdd( _arr, { 'Неврология', 1109, date_20110101, empty_date } )
    AAdd( _arr, { 'Мануальная терапия', 110901, date_20110101, empty_date } )
    AAdd( _arr, { 'Рефлексотерапия', 110902, date_20110101, empty_date } )
    AAdd( _arr, { 'Восстановительная медицина', 110903, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура и спортивная медицина', 110904, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 110905, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 110906, date_20110101, empty_date } )
    AAdd( _arr, { 'Общая врачебная практика (семейная медицина)', 1110, date_20110101, empty_date } )
    AAdd( _arr, { 'Восстановительная медицина', 111001, date_20110101, empty_date } )
    AAdd( _arr, { 'Гериатрия', 111002, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура и спортивная медицина', 111003, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 111004, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 111005, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 111006, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндоскопия', 111007, date_20110101, empty_date } )
    AAdd( _arr, { 'Отоларингология', 1111, date_20110101, empty_date } )
    AAdd( _arr, { 'Сурдология-отоларингология', 111101, date_20110101, empty_date } )
    AAdd( _arr, { 'Офтальмология', 1112, date_20110101, empty_date } )
    AAdd( _arr, { 'Патологическая анатомия', 1113, date_20110101, empty_date } )
    AAdd( _arr, { 'Психиатрия', 1115, date_20110101, empty_date } )
    AAdd( _arr, { 'Психотерапия', 111501, date_20110101, empty_date } )
    AAdd( _arr, { 'Сексология', 111502, date_20110101, empty_date } )
    AAdd( _arr, { 'Судебно-психиатрическая экспертиза', 111503, date_20110101, empty_date } )
    AAdd( _arr, { 'Психиатрия-наркология', 111504, date_20110101, empty_date } )
    AAdd( _arr, { 'Рентгенология', 1118, date_20110101, empty_date } )
    AAdd( _arr, { 'Радиология', 111801, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 111802, date_20110101, empty_date } )
    AAdd( _arr, { 'Скорая медицинская помощь', 1119, date_20110101, empty_date } )
    AAdd( _arr, { 'Восстановительная медицина', 111901, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура и спортивная медицина', 111902, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 111903, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 111904, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 111905, date_20110101, empty_date } )
    AAdd( _arr, { 'Организация здравоохранения и общественное здоровье', 1120, date_20110101, empty_date } )
    AAdd( _arr, { 'Судебно-медицинская экспертиза', 1121, date_20110101, empty_date } )
    AAdd( _arr, { 'Терапия', 1122, date_20110101, empty_date } )
    AAdd( _arr, { 'Гастроэнтерология', 112201, date_20110101, empty_date } )
    AAdd( _arr, { 'Гематология', 112202, date_20110101, empty_date } )
    AAdd( _arr, { 'Гериатрия', 112203, date_20110101, empty_date } )
    AAdd( _arr, { 'Диетология', 112204, date_20110101, empty_date } )
    AAdd( _arr, { 'Кардиология', 112205, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая фармакология', 112206, date_20110101, empty_date } )
    AAdd( _arr, { 'Нефрология', 112207, date_20110101, empty_date } )
    AAdd( _arr, { 'Пульмонология', 112208, date_20110101, empty_date } )
    AAdd( _arr, { 'Ревматология', 112209, date_20110101, empty_date } )
    AAdd( _arr, { 'Трансфузиология', 112210, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 112211, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 112212, date_20110101, empty_date } )
    AAdd( _arr, { 'Авиационная и космическая медицина', 112213, date_20110101, empty_date } )
    AAdd( _arr, { 'Аллергология и иммунология', 112214, date_20110101, empty_date } )
    AAdd( _arr, { 'Восстановительная медицина', 112215, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура и спортивная медицина', 112216, date_20110101, empty_date } )
    AAdd( _arr, { 'Мануальная терапия', 112217, date_20110101, empty_date } )
    AAdd( _arr, { 'Профпатология', 112218, date_20110101, empty_date } )
    AAdd( _arr, { 'Рефлексотерапия', 112219, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 112220, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндоскопия', 112221, date_20110101, empty_date } )
    AAdd( _arr, { 'Травматология и ортопедия', 1123, date_20110101, empty_date } )
    AAdd( _arr, { 'Мануальная терапия', 112301, date_20110101, empty_date } )
    AAdd( _arr, { 'Восстановительная медицина', 112302, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура и спортивная медицина', 112303, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиология', 112304, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 1124, date_20110101, empty_date } )
    AAdd( _arr, { 'Фтизиатрия', 1125, date_20110101, empty_date } )
    AAdd( _arr, { 'Пульмонология', 112501, date_20110101, empty_date } )
    AAdd( _arr, { 'Хирургия', 1126, date_20110101, empty_date } )
    AAdd( _arr, { 'Колопроктология', 112601, date_20110101, empty_date } )
    AAdd( _arr, { 'Нейрохирургия', 112602, date_20110101, empty_date } )
    AAdd( _arr, { 'Урология', 112603, date_20110101, empty_date } )
    AAdd( _arr, { 'Сердечно-сосудистая хирургия', 112604, date_20110101, empty_date } )
    AAdd( _arr, { 'Торакальная хирургия', 112605, date_20110101, empty_date } )
    AAdd( _arr, { 'Трансфузиология', 112606, date_20110101, empty_date } )
    AAdd( _arr, { 'Челюстно-лицевая хирургия', 112608, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндоскопия', 112609, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 112610, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 112611, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндокринология', 1127, date_20110101, empty_date } )
    AAdd( _arr, { 'Диабетология', 112701, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская эндокринология', 112702, date_20110101, empty_date } )
    AAdd( _arr, { 'Онкология', 1128, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская онкология', 112801, date_20110101, empty_date } )
    AAdd( _arr, { 'Радиология', 112802, date_20110101, empty_date } )
    AAdd( _arr, { 'Педиатрия', 1134, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская онкология', 113401, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская эндокринология', 113402, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская кардиология', 113403, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура и спортивная медицина', 113404, date_20110101, empty_date } )
    AAdd( _arr, { 'Аллергология и иммунология', 113405, date_20110101, empty_date } )
    AAdd( _arr, { 'Восстановительная медицина', 113406, date_20110101, empty_date } )
    AAdd( _arr, { 'Гастроэнтерология', 113407, date_20110101, empty_date } )
    AAdd( _arr, { 'Гематология', 113408, date_20110101, empty_date } )
    AAdd( _arr, { 'Диетология', 113409, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая фармакология', 113410, date_20110101, empty_date } )
    AAdd( _arr, { 'Мануальная терапия', 113411, date_20110101, empty_date } )
    AAdd( _arr, { 'Нефрология', 113412, date_20110101, empty_date } )
    AAdd( _arr, { 'Пульмонология', 113413, date_20110101, empty_date } )
    AAdd( _arr, { 'Ревматология', 113414, date_20110101, empty_date } )
    AAdd( _arr, { 'Трансфузиология', 113415, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 113416, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 113417, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 113418, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндоскопия', 113419, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская хирургия', 1135, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская онкология', 113501, date_20110101, empty_date } )
    AAdd( _arr, { 'Детская урология-андрология', 113502, date_20110101, empty_date } )
    AAdd( _arr, { 'Колопроктология', 113503, date_20110101, empty_date } )
    AAdd( _arr, { 'Нейрохирургия', 113504, date_20110101, empty_date } )
    AAdd( _arr, { 'Сердечно-сосудистая хирургия', 113505, date_20110101, empty_date } )
    AAdd( _arr, { 'Торакальная хирургия', 113506, date_20110101, empty_date } )
    AAdd( _arr, { 'Трансфузиология', 113507, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 113508, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 113509, date_20110101, empty_date } )
    AAdd( _arr, { 'Челюстно-лицевая хирургия', 113510, date_20110101, empty_date } )
    AAdd( _arr, { 'Эндоскопия', 113511, date_20110101, empty_date } )
    AAdd( _arr, { 'Неонатология', 1136, date_20110101, empty_date } )
    AAdd( _arr, { 'Медико-профилактическое дело', 13, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая лабораторная диагностика', 1301, date_20110101, empty_date } )
    AAdd( _arr, { 'Бактериология', 130101, date_20110101, empty_date } )
    AAdd( _arr, { 'Вирусология', 130102, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 130103, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная микология', 130104, date_20110101, empty_date } )
    AAdd( _arr, { 'Эпидемиология', 1302, date_20110101, empty_date } )
    AAdd( _arr, { 'Бактериология', 130201, date_20110101, empty_date } )
    AAdd( _arr, { 'Дезинфектология', 130203, date_20110101, empty_date } )
    AAdd( _arr, { 'Паразитология', 130204, date_20110101, empty_date } )
    AAdd( _arr, { 'Вирусология', 130205, date_20110101, empty_date } )
    AAdd( _arr, { 'Общая гигиена', 1303, date_20110101, empty_date } )
    AAdd( _arr, { 'Гигиена детей и подростков', 130301, date_20110101, empty_date } )
    AAdd( _arr, { 'Гигиеническое воспитание', 130302, date_20110101, empty_date } )
    AAdd( _arr, { 'Гигиена питания', 130303, date_20110101, empty_date } )
    AAdd( _arr, { 'Гигиена труда', 130304, date_20110101, empty_date } )
    AAdd( _arr, { 'Коммунальная гигиена', 130305, date_20110101, empty_date } )
    AAdd( _arr, { 'Радиационная гигиена', 130306, date_20110101, empty_date } )
    AAdd( _arr, { 'Санитарно-гигиенические лабораторные исследования', 130307, date_20110101, empty_date } )
    AAdd( _arr, { 'Социальная гигиена и организация госсанэпидслужбы', 1306, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология', 14, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология общей практики', 1401, date_20110101, empty_date } )
    AAdd( _arr, { 'Ортодонтия', 140101, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология детская', 140102, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология терапевтическая', 140103, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология ортопедическая', 140104, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология хирургическая', 140105, date_20110101, empty_date } )
    AAdd( _arr, { 'Челюстно-лицевая хирургия', 140106, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 140107, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая лабораторная диагностика', 1402, date_20110101, empty_date } )
    AAdd( _arr, { 'Бактериология', 140201, date_20110101, empty_date } )
    AAdd( _arr, { 'Вирусология', 140202, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 140203, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная микология', 140204, date_20110101, empty_date } )
    AAdd( _arr, { 'Фармация', 15, date_20110101, empty_date } )
    AAdd( _arr, { 'Управление и экономика фармации', 1501, date_20110101, empty_date } )
    AAdd( _arr, { 'Фармацевтическая технология', 1502, date_20110101, empty_date } )
    AAdd( _arr, { 'Фармацевтическая химия и фармакогнозия', 1503, date_20110101, empty_date } )
    AAdd( _arr, { 'Сестринское дело', 16, date_20110101, empty_date } )
    AAdd( _arr, { 'Управление сестринской деятельностью', 1601, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская биохимия', 17, date_20110101, empty_date } )
    AAdd( _arr, { 'Генетика', 1701, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 170101, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая лабораторная диагностика', 1702, date_20110101, empty_date } )
    AAdd( _arr, { 'Бактериология', 170201, date_20110101, empty_date } )
    AAdd( _arr, { 'Вирусология', 170202, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 170203, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная микология', 170204, date_20110101, empty_date } )
    AAdd( _arr, { 'Судебно-медицинская экспертиза', 1703, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская биофизика. Медицинская кибернетика', 18, date_20110101, empty_date } )
    AAdd( _arr, { 'Клиническая лабораторная диагностика', 1801, date_20110101, empty_date } )
    AAdd( _arr, { 'Бактериология', 180101, date_20110101, empty_date } )
    AAdd( _arr, { 'Вирусология', 180102, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная генетика', 180103, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная микология', 180104, date_20110101, empty_date } )
    AAdd( _arr, { 'Рентгенология', 1802, date_20110101, empty_date } )
    AAdd( _arr, { 'Радиология', 180201, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 180202, date_20110101, empty_date } )
    AAdd( _arr, { 'Ультразвуковая диагностика', 180203, date_20110101, empty_date } )
    AAdd( _arr, { 'Среднее медицинское и фармацевтическое образование', 2, date_20110101, empty_date } )
    AAdd( _arr, { 'Организация сестринского дела', 2001, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебное дело', 2002, date_20110101, empty_date } )
    AAdd( _arr, { 'Акушерское дело', 2003, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология', 2004, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология ортопедическая', 2005, date_20110101, empty_date } )
    AAdd( _arr, { 'Эпидемиология (паразитология)', 2006, date_20110101, empty_date } )
    AAdd( _arr, { 'Гигиена и санитария', 2007, date_20110101, empty_date } )
    AAdd( _arr, { 'Дезинфекционное дело', 2008, date_20110101, empty_date } )
    AAdd( _arr, { 'Гигиеническое воспитание', 2009, date_20110101, empty_date } )
    AAdd( _arr, { 'Энтомология', 2010, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторная диагностика', 2011, date_20110101, empty_date } )
    AAdd( _arr, { 'Гистология', 2012, date_20110101, empty_date } )
    AAdd( _arr, { 'Лабораторное дело', 2013, date_20110101, empty_date } )
    AAdd( _arr, { 'Фармация', 2014, date_20110101, empty_date } )
    AAdd( _arr, { 'Сестринское дело', 2015, date_20110101, empty_date } )
    AAdd( _arr, { 'Сестринское дело в педиатрии', 2016, date_20110101, empty_date } )
    AAdd( _arr, { 'Операционное дело', 2017, date_20110101, empty_date } )
    AAdd( _arr, { 'Анестезиология и реаниматология', 2018, date_20110101, empty_date } )
    AAdd( _arr, { 'Общая практика', 2019, date_20110101, empty_date } )
    AAdd( _arr, { 'Рентгенология', 2020, date_20110101, empty_date } )
    AAdd( _arr, { 'Функциональная диагностика', 2021, date_20110101, empty_date } )
    AAdd( _arr, { 'Физиотерапия', 2022, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинский массаж', 2023, date_20110101, empty_date } )
    AAdd( _arr, { 'Лечебная физкультура', 2024, date_20110101, empty_date } )
    AAdd( _arr, { 'Диетология', 2025, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская статистика', 2026, date_20110101, empty_date } )
    AAdd( _arr, { 'Стоматология профилактическая', 2027, date_20110101, empty_date } )
    AAdd( _arr, { 'Судебно-медицинская экспертиза', 2028, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская оптика', 2029, date_20110101, empty_date } )
    AAdd( _arr, { 'Естественные науки', 3, date_20110101, empty_date } )
    AAdd( _arr, { 'Биофизика', 31, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская биофизика', 3101, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская кибернетика', 3102, date_20110101, empty_date } )
    AAdd( _arr, { 'Биохимия', 32, date_20110101, empty_date } )
    AAdd( _arr, { 'Медицинская биохимия', 3201, date_20110101, empty_date } )
  Endif

  Return _arr

// =========== V005 ===================
//
// 22.10.22 вернуть Классификатор пола застрахованного V005.xml
Function getv005()

  // V005.xml - Классификатор пола застрахованного
  // 1 - POLNAME(C)  2 - IDPOL(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Мужской', 1, empty_date, empty_date } )
    AAdd( _arr, { 'Женский', 2, empty_date, empty_date } )
  Endif

  Return _arr

// =========== V006 ===================
//
// 18.05.22 вернуть условиt оказания медицинской помощи по коду
Function getuslovie_v006( kod )

  Local ret := NIL
  Local i

  If ( i := AScan( getv006(), {| x| x[ 2 ] == kod } ) ) > 0
    ret := getv006()[ i, 1 ]
  Endif

  Return ret

// 28.02.21 вернуть Классификатор условий оказания медицинской помощи V006.xml
Function getv006()

  // V006.xml - Классификатор условий оказания медицинской помощи
  // 1 - UMPNAME(C)  2 - IDUMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Стационар', 1, date_20110101, empty_date } )
    AAdd( _arr, { 'Дневной стационар', 2, date_20110101, empty_date } )
    AAdd( _arr, { 'Поликлиника', 3, date_20110101, empty_date } )
    AAdd( _arr, { 'Скорая помощь', 4, SToD( '20130101' ), empty_date } )
  Endif

  Return _arr

// =========== V008 ===================
//
// 22.10.22 вернуть Классификатор видов медицинской помощи V008.xml
Function getv008()

  // V008.xml - Классификатор видов медицинской помощи
  // 1 - VMPNAME(C)  2 - IDVMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Первичная медико-санитарная помощь', 1, date_20110101, empty_date } )
    AAdd( _arr, { 'Скорая, в том числе специализированная (санитарно-авиационная), медицинская помощь', 2, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { 'Специализированная, в том числе высокотехнологичная, медицинская помощь', 3, date_20110101, empty_date } )
  Endif

  Return _arr

// =========== V009 ===================
//
#define V009_IDRMP    1
#define V009_RMPNAME  2
#define V009_DL_USLOV 3
#define V009_DATEBEG  4
#define V009_DATEEND  5

// 23.01.23 вернуть массив по справочнику ТФОМС V009.xml
Function getv009( work_date )

  // V009.xml - Классификатор результатов обращения за медицинской помощью
  Static _arr
  Local stroke := '', vid := ''
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idrmp, ' + ;
      'rmpname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v009' )  // WHERE dateend == "    -  -  "')
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If Val( aTable[ nI, V009_DL_USLOV ] ) == 1
          vid := '/ст-р/'
        Elseif Val( aTable[ nI, V009_DL_USLOV ] ) == 2
          vid := '/дн.с/'
        Elseif Val( aTable[ nI, V009_DL_USLOV ] ) == 3
          vid := '/п-ка/'
        Else
          vid := '/'
        Endif
        stroke := Str( Val( aTable[ nI, V009_IDRMP ] ), 3 ) + vid + AllTrim( aTable[ nI, V009_RMPNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V009_IDRMP ] ), CToD( aTable[ nI, V009_DATEBEG ] ), CToD( aTable[ nI, V009_DATEEND ] ), Val( aTable[ nI, V009_DL_USLOV ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// 04.11.22 вернуть результат обращения за медицинской помощью по коду
Function getrslt_v009( result )

  Local ret := NIL
  Local i

  If ( i := AScan( getv009(), {| x| x[ 2 ] == result } ) ) > 0
    ret := getv009()[ i, 1 ]
  Endif

  Return ret

// 23.01.23 вернуть результат обращения по условию оказания и дате
Function getrslt_usl_date( uslovie, date )

  Local ret := {}
  Local row

  For Each row in getv009( date )
    If uslovie == row[ 5 ]
      AAdd( ret, row )
    Endif
  Next

  Return ret

// =========== V010 ===================
//
#define V010_IDSP     1
#define V010_SPNAME   2
#define V010_DATEBEG  3
#define V010_DATEEND  4

// 26.01.23 вернуть массив по справочнику ФФОМС V010.xml
Function getv010( work_date )

  // V010.xml - Классификатор способов оплаты медицинской помощи
  Static _arr
  Static time_load
  Local stroke := ''
  Local db
  Local aTable
  Local nI
  Local ret_array, row

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idsp, ' + ;
      'spname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v010' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        stroke := StrZero( Val( aTable[ nI, V010_IDSP ] ), 2, 0 ) + '/' + AllTrim( aTable[ nI, V010_SPNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V010_IDSP ] ), AllTrim( aTable[ nI, V010_SPNAME ] ), CToD( aTable[ nI, V010_DATEBEG ] ), CToD( aTable[ nI, V010_DATEEND ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// =========== V012 ===================
//
#define V012_IDIZ     1
#define V012_IZNAME   2
#define V012_DL_USLOV 3
#define V012_DATEBEG  4
#define V012_DATEEND  5

// 23.01.23 вернуть массив по справочнику ФФОМС V012.xml
Function getv012( work_date )

  // V012.xml - Классификатор исходов заболевания
  Static _arr
  Static time_load
  Local stroke := '', vid := ''
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idiz, ' + ;
      'izname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v012' )   // WHERE dateend == "    -  -  "')
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        // if empty(ctod(aTable[nI, 5]))  // только если поле окончания действия пусто
        If Val( aTable[ nI, V012_DL_USLOV ] ) == 1
          vid := '/ст-р/'
        Elseif Val( aTable[ nI, V012_DL_USLOV ] ) == 2
          vid := '/дн.с/'
        Elseif Val( aTable[ nI, V012_DL_USLOV ] ) == 3
          vid := '/п-ка/'
        Else
          vid := '/'
        Endif
        stroke := Str( Val( aTable[ nI, V012_IDIZ ] ), 3 ) + vid + AllTrim( aTable[ nI, V012_IZNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V012_IDIZ ] ), CToD( aTable[ nI, V012_DATEBEG ] ), CToD( aTable[ nI, V012_DATEEND ] ), Val( aTable[ nI, V012_DL_USLOV ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// 06.11.22 вернуть исход заболевания по коду
Function getishod_v012( ishod )

  Local ret := NIL
  Local i

  If ( i := AScan( getv012(), {| x| x[ 2 ] == ishod } ) ) > 0
    ret := getv012()[ i, 1 ]
  Endif

  Return ret

// 23.01.23 вернуть исход заболевания по условию оказания и дате
Function getishod_usl_date( uslovie, date )

  Local ret := {}
  Local row

  For Each row in getv012( date )
    If uslovie == row[ 5 ]
      AAdd( ret, row )
    Endif
  Next

  Return ret

// =========== V014 ===================
//
// 21.10.22 вернуть Классификатор форм медицинской помощи V014.xml
Function getv014()

  // V014.xml - Классификатор форм медицинской помощи
  // 1 - FRMMPNAME(C)  2 - IDFRMMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Экстренная', 1, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { 'Неотложная', 2, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { 'Плановая', 3, SToD( '20130101' ), empty_date } )
  Endif

  Return _arr

// =========== V015 ===================
//
// 26.01.23 вернуть массив по справочнику V015.xml
// возвращает массив V015
Function getv015()

  // V015.xml - Классификатор медицинских специальностей
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'recid, ' + ;
      'code, ' + ;
      'name, ' + ;
      'high, ' + ;
      'okso, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v015' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 4 ] ), AllTrim( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ), CToD( aTable[ nI, 7 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

    ASort( _arr, , , {| x, y| x[ 2 ] < y[ 2 ] } )
  Endif

  Return _arr

// =========== V016 ===================
//
// 26.01.23 вернуть Классификатор видов диспансеризации/профосмотров V016.xml
Function getv016()

  // V016.xml - Классификатор видов диспансеризации/профосмотров
  Static _arr
  Static time_load
  Local ar := {}
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT iddt, dtname, rule, datebeg, dateend FROM v016' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        ar := list2arr( aTable[ nI, 3 ] )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ar, CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 13.12.21 вернуть описатель типа диспнсеризации по коду
Function get_type_dispt( mdate, codeDispT )

  Local dispT := Upper( AllTrim( codeDispT ) )
  Local _arr := {}, i
  Local tmpArr := getv016()
  Local lengthArr := Len( tmpArr )

  For i := 1 To lengthArr
    If dispT == tmpArr[ i, 1 ] .and. between_date( tmpArr[ i, 4 ], tmpArr[ i, 5 ], mdate )
      AAdd( _arr, tmpArr[ i, 1 ] )
      AAdd( _arr, tmpArr[ i, 2 ] )
      AAdd( _arr, tmpArr[ i, 3 ] )
    Endif
  Next

  Return _arr

// =========== V017 ===================
//
// 26.01.23 вернуть Классификатор результатов диспансеризации (DispR) V017.xml
Function getv017()

  // V017.xml - Классификатор результатов диспансеризации (DispR)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT iddr, drname, datebeg, dateend FROM v017' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 13.12.21 вернуть список результатов диспансеризации на дату в соответствии со списком кодов
Function get_list_dispr( mdate, arrDR )

  Local _arr := {}, code, i
  Local tmpArr := getv017()
  Local lenArr := Len( tmpArr )

  For Each code in arrDR
    For i := 1 To lenArr
      If code == tmpArr[ i, 1 ] .and. between_date( tmpArr[ i, 3 ], tmpArr[ i, 4 ], mdate )
        AAdd( _arr, tmpArr[ i, 2 ] )
      Endif
    Next
  Next

  Return _arr

// =========== V018 ===================
//
// 25.01.23 возвращает массив V018 на указанную дату
Function getv018( dateSl )

  Local yearSl := Year( dateSl )
  Local _arr
  Local db
  Local aTable, stmt
  Local nI

  Static hV018, lHashV018 := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashV018
    hV018 := hb_Hash()
    lHashV018 := .t.
  Endif

  // получим массив V018 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hV018, yearSl )
    _arr := hb_HGet( hV018, yearSl )
  Else
    _arr := {}

    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idhvid, ' + ;
      'hvidname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v018' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If ( Year( CToD( aTable[ nI, 3 ] ) ) <= yearSl ) .and. ( Empty( CToD( aTable[ nI, 4 ] ) ) .or. Year( CToD( aTable[ nI, 4 ] ) ) >= yearSl )   // только если поле окончания действия пусто
          AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
        Endif
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    // поместим в ХЭШ-массив
    hV018[ yearSl ] := _arr
  Endif
  If Empty( _arr )
    alertx( 'На дату ' + DToC( dateSl ) + ' V018 отсутствуют!' )
  Endif

  Return _arr

// =========== V019 ===================
//
// 25.01.23 возвращает массив V019
Function getv019( dateSl )

  Local yearSl := Year( dateSl )
  Local _arr
  Local db
  Local aTable, stmt
  Local nI

  Static hV019, lHashV019 := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashV019
    hV019 := hb_Hash()
    lHashV019 := .t.
  Endif

  // получим массив V019 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hV019, yearSl )
    _arr := hb_HGet( hV019, yearSl )
  Else
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idhm, ' + ;
      'hmname, ' + ;
      'diag, ' + ;
      'hvid, ' + ;
      'hgr, ' + ;
      'hmodp, ' + ;
      'idmodp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v019' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If ( Year( CToD( aTable[ nI, 8 ] ) ) <= yearSl ) .and. ( Empty( CToD( aTable[ nI, 9 ] ) ) .or. Year( CToD( aTable[ nI, 9 ] ) ) >= yearSl )   // только если поле окончания действия пусто
          AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ;
            AClone( split( AllTrim( aTable[ nI, 3 ] ), ', ' ) ), ;
            AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 8 ] ), CToD( aTable[ nI, 9 ] ), ;
            Val( aTable[ nI, 5 ] ), Val( aTable[ nI, 7 ] ) ;
            } )
        Endif
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    hV019[ yearSl ] := _arr
  Endif

  Return _arr

// =========== V020 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V020.xml - Классификатор профилей койки
Function getv020()

  Static _arr
  Static time_load
  Local db
  Local aTable, stmt
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idk_pr, ' + ;
      'k_prname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v020' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V021 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V021.xml
Function getv021()

  // V021.xml - Классификатор медицинских специальностей (должностей) (MedSpec)
  // 1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - POSTNAME(C)  6 - IDPOST_MZ(C)

  Static _arr   // := {}
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idspec, ' + ;
      'idspec || "." || trim(specname), ' + ;
      'postname, ' + ;
      'idpost_mz, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v021 WHERE dateend == "    -  -  "' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 27.02.23 вернуть массив описывающий специальность
Function doljbyspec_v021( idspec )

  Local i, retArray := ''
  Local aV021 := getv021()

  If !Empty( idspec ) .and. ( ( i := AScan( aV021, {| x| x[ 2 ] == idspec } ) ) > 0 )
    retArray := aV021[ i, 5 ]
  Endif

  Return retArray

// 25.06.24
Function ret_str_spec( kod )

  Local i, s := '', aV021 := getv021()

  If ! Empty( kod ) .and. ( ( i := AScan( aV021, {| x | x[ 2 ] == kod } ) ) > 0 )
    s := aV021[ i, 1 ]
  Endif

  Return s


// =========== V022 ===================
//
// 26.01.23 возвращает массив V022
Function getv022()

  Static _arr
  Static time_load
  Local db
  Local aTable, stmt
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idmpac, ' + ;
      'mpacname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v022' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Endif

  Return _arr

// 11.02.21 вернуть строку модели пациента ВМП
Function ret_v022( idmpac, lk_data )

  Local i, s := Space( 10 )
  Local aV022 := getv022()

  If !Empty( idmpac ) .and. ( ( i := AScan( aV022, {| x| x[ 1 ] == idmpac } ) ) > 0 )
    s := aV022[ i, 2 ]
  Endif

  Return s

// =========== V025 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V025 Классификатор целей посещения (KPC)
Function getv025()

  Static _arr
  Static time_load
  Local i
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idpc, ' + ;
      'n_pc, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v025' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ) + '-' + AllTrim( aTable[ nI, 2 ] ), nI -1, AllTrim( aTable[ nI, 1 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

Function get_idpc_from_v025_by_number( num )

  Local tableV025 := getv025()
  Local row
  Local retIDPC := ''

  For Each row in tableV025
    If row[ 2 ] == num
      retIDPC := row[ 3 ]
      Exit
    Endif
  Next

  Return retIDPC

// =========== V030 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V030.xml
Function getv030()

  // V030.xml - Схемы лечения заболевания COVID-19 (TreatReg)
  // 1 - SCHEMCOD(C) 2 - SCHEME(C) 3 - DEGREE(N) 4 - COMMENT(M)  5 - DATEBEG(D)  6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'schemcode, ' + ;
      'scheme, ' + ;
      'degree, ' + ;
      'comment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v030' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), ;
          Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), ;
          CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 11.01.22 вернуть схемы лечения согласно тяжести пациента
Function get_schemas_lech( _degree, ldate )

  Local _arr := {}, row

  If ValType( _degree ) == 'C' .and. Empty( _degree )
    Return _arr
  Endif
  If ValType( _degree ) == 'N' .and. _degree == 0
    Return _arr
  Endif

  For Each row in getv030()
    If ( row[ 3 ] == _degree ) .and. between_date( row[ 5 ], row[ 6 ], ldate )
      AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ], row[ 6 ] } )
    Endif
  Next

  Return _arr

// 07.01.22 вернуть наименование схемы
Function ret_schema_v030( s_code )

  // s_code - код схемы
  Local i, ret := ''
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv030(), {| x| x[ 2 ] == code } ) ) > 0 )
    ret := getv030()[ i, 1 ]
  Endif

  Return ret

// =========== V031 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V031.xml
Function getv031()

  // V031.xml - Группы препаратов для лечения заболевания COVID-19 (GroupDrugs)
  // 1 - DRUGCODE(N) 2 - DRUGGRUP(C) 3 - INDMNN(N)  4 - DATEBEG(D)  5 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT drugcode, druggrup, indmnn, datebeg, dateend FROM v031' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 29.08.22 вернуть группу препаратов
Function get_group_prep_by_kod( _code, ldate )

  Local _arr, row, code

  If ValType( _code ) == 'C'
    code := Val( SubStr( _code, Len( _code ) ) )
  Elseif ValType( _code ) == 'N'
    code := _code
  Else
    Return _arr
  Endif

  For Each row in getv031()
    If ( row[ 1 ] == code ) .and. between_date( row[ 4 ], row[ 5 ], ldate )
      _arr := { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ] }
    Endif
  Next

  Return _arr

// =========== V032 ===================
//
// 26.01.22 вернуть массив по справочнику ФФОМС V032.xml
Function getv032()

  // V032.xml - Сочетание схемы лечения и группы препаратов (CombTreat)
  // 1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT schedrug, name, schemcode, datebeg, dateend FROM v032' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 04.01.22 вернуть сочетание схемы и группы препаратов
Function get_group_by_schema_lech( _scheme, ldate )

  Local _arr := {}, row

  For Each row in getv032()
    If ( row[ 3 ] == AllTrim( _scheme ) ) .and. between_date( row[ 4 ], row[ 5 ], ldate )
      AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ] } )
    Endif
  Next

  Return _arr

// 08.01.22 вернуть наименование кода схемы
Function ret_schema_v032( s_code )

  // s_code - код схемы
  Local i, ret := ''
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv032(), {| x| x[ 2 ] == code } ) ) > 0 )
    ret := getv032()[ i, 1 ]
  Endif

  Return ret

// =========== V033 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V033.xml
Function getv033()

  // V033.xml - Соответствие кода препарата схеме лечения (DgTreatReg)
  // 1 - SCHEDRUG(C) 2 - DRUGCODE(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT schedrug, drugcode, datebeg, dateend FROM v033' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V036 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V036.xml
Function getv036()

  // V036.xml - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)
  // 1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT s_code, name, param, comment, datebeg, dateend FROM v036' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V024 ===================
//
// 25.09.23 вернуть массив по справочнику ФФОМС V036.xml
Function getv024( dk )

  // V024.xml - Классификатор классификационных критериев (DopKr)
  // 1 - IDDKK(C) 2 - DKKNAME(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  Local arr
  Local db
  Local aTable
  Local nI
  Local dBeg, dEnd

  arr := {}
  If ValType( dk ) == 'N'
    dBeg := "'" + Str( dk, 4 ) + "-01-01 00:00:00'"
    dEnd := "'" + Str( dk, 4 ) + "-12-31 00:00:00'"
  Elseif ValType( dk ) == 'D'
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    dBeg := "'" + DToS( dk ) + "-01-01 00:00:00'"
    dEnd := "'" + DToS( dk ) + "-12-31 00:00:00'"
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  db := opensql_db()
  aTable := sqlite3_get_table( db, "SELECT " + ;
    "iddkk, " + ;
    "dkkname, " + ;
    "datebeg, " + ;
    "dateend " + ;
    "FROM v024 " + ;
    "WHERE datebeg <= " + dBeg + ;
    "AND dateend >= " + dEnd )
  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
      dBeg := CToD( aTable[ nI, 3 ] )
      dEnd := CToD( aTable[ nI, 4 ] )
      Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )

      AAdd( arr, { aTable[ nI, 1 ], aTable[ nI, 2 ], dBeg, dEnd } )
    Next
  Endif
  db := nil

  Return arr
