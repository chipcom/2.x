#include 'hbhash.ch'

// 21.11.22
function ret_V015_V021()
  static _hash_table

  if _hash_table == nil
    _hash_table := hb_hash()
    // hb_hSet(_hash_table, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
    hb_hSet(_hash_table, 1, 49) //    Педиатрия
    hb_hSet(_hash_table, 2, 96) //    Медико-профилактическое дело
    hb_hSet(_hash_table, 3, 69) //    Стоматология общей практики
    hb_hSet(_hash_table, 4, 101) //    Фармация
    hb_hSet(_hash_table, 5, 100) //    Сестринское дело
    hb_hSet(_hash_table, 6, 97) //    Медицинская биохимия
    hb_hSet(_hash_table, 7, 98) //    Медицинская биофизика
    hb_hSet(_hash_table, 8, 2) //    Акушерство и гинекология
    hb_hSet(_hash_table, 9, 4) //    Анестезиология-реаниматология
    hb_hSet(_hash_table, 10, 17) //    Дерматовенерология
    hb_hSet(_hash_table, 11, 21) //    Детская хирургия
    hb_hSet(_hash_table, 12, 10) //    Генетика
    hb_hSet(_hash_table, 13, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 14, 35) //    Неврология
    hb_hSet(_hash_table, 15, 37) //    Неонатология
    hb_hSet(_hash_table, 16, 39) //    Общая врачебная практика (семейная медицина)
    hb_hSet(_hash_table, 17, 41) //    Онкология
    hb_hSet(_hash_table, 18, 42) //    Организация здравоохранения и общественное здоровье
    hb_hSet(_hash_table, 19, 45) //    Оториноларингология
    hb_hSet(_hash_table, 20, 46) //    Офтальмология
    hb_hSet(_hash_table, 21, 48) //    Патологическая анатомия
    hb_hSet(_hash_table, 22, 49) //    Педиатрия
    hb_hSet(_hash_table, 23, 52) //    Психиатрия
    hb_hSet(_hash_table, 24, 60) //    Рентгенология
    hb_hSet(_hash_table, 25, 66) //    Скорая медицинская помощь
    hb_hSet(_hash_table, 26, 73) //    Судебно-медицинская экспертиза
    hb_hSet(_hash_table, 27, 76) //    Терапия
    hb_hSet(_hash_table, 28, 79) //    Травматология и ортопедия
    hb_hSet(_hash_table, 29, 88) //    Фтизиатрия
    hb_hSet(_hash_table, 30, 90) //    Хирургия
    hb_hSet(_hash_table, 31, 92) //    Эндокринология
    hb_hSet(_hash_table, 32, 24) //    Инфекционные болезни
    hb_hSet(_hash_table, 33, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 34, 87) //    Физиотерапия
    hb_hSet(_hash_table, 35, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 36, 93) //    Эндоскопия
    hb_hSet(_hash_table, 37, 77) //    Токсикология
    hb_hSet(_hash_table, 38, 80) //    Трансфузиология
    hb_hSet(_hash_table, 39, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 40, 17) //    Дерматовенерология
    hb_hSet(_hash_table, 41, 19) //    Детская онкология
    hb_hSet(_hash_table, 42, 20) //    Детская урология-андрология
    hb_hSet(_hash_table, 43, 28) //    Колопроктология
    hb_hSet(_hash_table, 44, 36) //    Нейрохирургия
    hb_hSet(_hash_table, 45, 65) //    Сердечно-сосудистая хирургия
    hb_hSet(_hash_table, 46, 78) //    Торакальная хирургия
    hb_hSet(_hash_table, 47, 80) //    Трансфузиология
    hb_hSet(_hash_table, 48, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 49, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 50, 91) //    Челюстно-лицевая хирургия
    hb_hSet(_hash_table, 51, 93) //    Эндоскопия
    hb_hSet(_hash_table, 52, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 53, 24) //    Инфекционные болезни
    hb_hSet(_hash_table, 54, 5) //    Бактериология
    hb_hSet(_hash_table, 55, 6) //    Вирусология
    hb_hSet(_hash_table, 56, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 57, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 58, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 59, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 61, 33) //    Мануальная терапия
    hb_hSet(_hash_table, 62, 62) //    Рефлексотерапия
    hb_hSet(_hash_table, 63, 87) //    Физиотерапия
    hb_hSet(_hash_table, 64, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 65, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 66, 11) //    Гериатрия
    hb_hSet(_hash_table, 67, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 69, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 70, 87) //    Физиотерапия
    hb_hSet(_hash_table, 71, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 72, 93) //    Эндоскопия
    hb_hSet(_hash_table, 73, 19) //    Детская онкология
    hb_hSet(_hash_table, 74, 57) //    Радиология
    hb_hSet(_hash_table, 75, 75) //    Сурдология-оториноларингология
    hb_hSet(_hash_table, 77, 3) //    Аллергология и иммунология
    hb_hSet(_hash_table, 78, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 79, 8) //    Гастроэнтерология
    hb_hSet(_hash_table, 80, 9) //    Гематология
    hb_hSet(_hash_table, 81, 18) //    Детская кардиология
    hb_hSet(_hash_table, 82, 19) //    Детская онкология
    hb_hSet(_hash_table, 83, 22) //    Детская эндокринология
    hb_hSet(_hash_table, 84, 23) //    Диетология
    hb_hSet(_hash_table, 85, 27) //    Клиническая фармакология
    hb_hSet(_hash_table, 86, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 88, 33) //    Мануальная терапия
    hb_hSet(_hash_table, 89, 38) //    Нефрология
    hb_hSet(_hash_table, 90, 55) //    Пульмонология
    hb_hSet(_hash_table, 91, 59) //    Ревматология
    hb_hSet(_hash_table, 92, 80) //    Трансфузиология
    hb_hSet(_hash_table, 93, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 94, 87) //    Физиотерапия
    hb_hSet(_hash_table, 95, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 96, 93) //    Эндоскопия
    hb_hSet(_hash_table, 97, 53) //    Психиатрия-наркология
    hb_hSet(_hash_table, 98, 54) //    Психотерапия
    hb_hSet(_hash_table, 99, 64) //    Сексология
    hb_hSet(_hash_table, 100, 74) //    Судебно-психиатрическая экспертиза
    hb_hSet(_hash_table, 102, 57) //    Радиология
    hb_hSet(_hash_table, 103, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 104, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 105, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 107, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 108, 87) //    Физиотерапия
    hb_hSet(_hash_table, 109, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 110, 1) //    Авиационная и космическая медицина
    hb_hSet(_hash_table, 112, 3) //    Аллергология и иммунология
    hb_hSet(_hash_table, 113, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 114, 8) //    Гастроэнтерология
    hb_hSet(_hash_table, 115, 9) //    Гематология
    hb_hSet(_hash_table, 116, 11) //    Гериатрия
    hb_hSet(_hash_table, 117, 23) //    Диетология
    hb_hSet(_hash_table, 118, 25) //    Кардиология
    hb_hSet(_hash_table, 119, 27) //    Клиническая фармакология
    hb_hSet(_hash_table, 120, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 122, 33) //    Мануальная терапия
    hb_hSet(_hash_table, 123, 38) //    Нефрология
    hb_hSet(_hash_table, 124, 51) //    Профпатология
    hb_hSet(_hash_table, 125, 55) //    Пульмонология
    hb_hSet(_hash_table, 126, 59) //    Ревматология
    hb_hSet(_hash_table, 127, 62) //    Рефлексотерапия
    hb_hSet(_hash_table, 128, 80) //    Трансфузиология
    hb_hSet(_hash_table, 129, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 130, 87) //    Физиотерапия
    hb_hSet(_hash_table, 131, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 132, 93) //    Эндоскопия
    hb_hSet(_hash_table, 133, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 134, 32) //    Лечебная физкультура и спортивная медицина
    hb_hSet(_hash_table, 136, 33) //    Мануальная терапия
    hb_hSet(_hash_table, 137, 87) //    Физиотерапия
    hb_hSet(_hash_table, 138, 55) //    Пульмонология
    hb_hSet(_hash_table, 139, 28) //    Колопроктология
    hb_hSet(_hash_table, 140, 36) //    Нейрохирургия
    hb_hSet(_hash_table, 141, 65) //    Сердечно-сосудистая хирургия
    hb_hSet(_hash_table, 142, 78) //    Торакальная хирургия
    hb_hSet(_hash_table, 143, 80) //    Трансфузиология
    hb_hSet(_hash_table, 144, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 145, 84) //    Урология
    hb_hSet(_hash_table, 146, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 147, 91) //    Челюстно-лицевая хирургия
    hb_hSet(_hash_table, 148, 93) //    Эндоскопия
    hb_hSet(_hash_table, 149, 22) //    Детская эндокринология
    hb_hSet(_hash_table, 150, 92) //    Эндокринология
    hb_hSet(_hash_table, 151, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 152, 40) //    Общая гигиена
    hb_hSet(_hash_table, 153, 67) //    Социальная гигиена и организация госсанэпидслужбы
    hb_hSet(_hash_table, 154, 94) //    Эпидемиология
    hb_hSet(_hash_table, 155, 5) //    Бактериология
    hb_hSet(_hash_table, 156, 6) //    Вирусология
    hb_hSet(_hash_table, 157, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 158, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 159, 12) //    Гигиена детей и подростков
    hb_hSet(_hash_table, 160, 13) //    Гигиена питания
    hb_hSet(_hash_table, 161, 14) //    Гигиена труда
    hb_hSet(_hash_table, 162, 15) //    Гигиеническое воспитание
    hb_hSet(_hash_table, 163, 29) //    Коммунальная гигиена
    hb_hSet(_hash_table, 164, 56) //    Радиационная гигиена
    hb_hSet(_hash_table, 165, 63) //    Санитарно-гигиенические лабораторные исследования
    hb_hSet(_hash_table, 167, 5) //    Бактериология
    hb_hSet(_hash_table, 168, 6) //    Вирусология
    hb_hSet(_hash_table, 169, 16) //    Дезинфектология
    hb_hSet(_hash_table, 170, 47) //    Паразитология
    hb_hSet(_hash_table, 171, 69) //    Стоматология общей практики
    hb_hSet(_hash_table, 172, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 173, 43) //    Ортодонтия
    hb_hSet(_hash_table, 174, 68) //    Стоматология детская
    hb_hSet(_hash_table, 175, 70) //    Стоматология ортопедическая
    hb_hSet(_hash_table, 176, 71) //    Стоматология терапевтическая
    hb_hSet(_hash_table, 177, 72) //    Стоматология хирургическая
    hb_hSet(_hash_table, 178, 91) //    Челюстно-лицевая хирургия
    hb_hSet(_hash_table, 179, 87) //    Физиотерапия
    hb_hSet(_hash_table, 180, 5) //    Бактериология
    hb_hSet(_hash_table, 181, 6) //    Вирусология
    hb_hSet(_hash_table, 182, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 183, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 184, 82) //    Управление и экономика фармации
    hb_hSet(_hash_table, 185, 86) //    Фармацевтическая химия и фармакогнозия
    hb_hSet(_hash_table, 186, 83) //    Управление сестринской деятельностью
    hb_hSet(_hash_table, 187, 10) //    Генетика
    hb_hSet(_hash_table, 188, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 189, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 190, 5) //    Бактериология
    hb_hSet(_hash_table, 191, 6) //    Вирусология
    hb_hSet(_hash_table, 192, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 193, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 194, 73) //    Судебно-медицинская экспертиза
    hb_hSet(_hash_table, 195, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 196, 60) //    Рентгенология
    hb_hSet(_hash_table, 197, 5) //    Бактериология
    hb_hSet(_hash_table, 198, 6) //    Вирусология
    hb_hSet(_hash_table, 199, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 200, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 201, 57) //    Радиология
    hb_hSet(_hash_table, 202, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 203, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 206, 206) //    Лечебное дело (средний медперсонал)
    hb_hSet(_hash_table, 207, 207) //    Акушерское дело (средний медперсонал)
    hb_hSet(_hash_table, 208, 208) //    Стоматология (средний медперсонал)
    hb_hSet(_hash_table, 209, 209) //    Стоматология ортопедическая
    hb_hSet(_hash_table, 215, 215) //    Лабораторная диагностика
    hb_hSet(_hash_table, 217, 217) //    Лабораторное дело
    hb_hSet(_hash_table, 219, 219) //    Сестринское дело
    hb_hSet(_hash_table, 221, 221) //    Сестринское дело в педиатрии
    hb_hSet(_hash_table, 223, 223) //    Анестезиология и реаниматология
    hb_hSet(_hash_table, 224, 224) //    Общая практика
    hb_hSet(_hash_table, 226, 226) //    Функциональная диагностика
    hb_hSet(_hash_table, 227, 227) //    Физиотерапия
    hb_hSet(_hash_table, 228, 228) //    Медицинский массаж
    hb_hSet(_hash_table, 229, 85) //    Фармацевтическая технология
    hb_hSet(_hash_table, 230, 230) //    Лечебная физкультура
    hb_hSet(_hash_table, 231, 231) //    Диетология
    hb_hSet(_hash_table, 233, 233) //    Стоматология профилактическая
    hb_hSet(_hash_table, 236, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 237, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 238, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 239, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 240, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 241, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 242, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 243, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 244, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 245, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 246, 34) //    Медико-социальная экспертиза
    hb_hSet(_hash_table, 247, 50) //    Пластическая хирургия
    hb_hSet(_hash_table, 248, 61) //    Рентгенэндоваскулярные диагностика и лечение
    hb_hSet(_hash_table, 249, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 250, 61) //    Рентгенэндоваскулярные диагностика и лечение
    hb_hSet(_hash_table, 251, 80) //    Трансфузиология
    hb_hSet(_hash_table, 252, 30) //    Косметология
    hb_hSet(_hash_table, 253, 61) //    Рентгенэндоваскулярные диагностика и лечение
    hb_hSet(_hash_table, 254, 61) //    Рентгенэндоваскулярные диагностика и лечение
    hb_hSet(_hash_table, 255, 3) //    Аллергология и иммунология
    hb_hSet(_hash_table, 256, 7) //    Водолазная медицина
    hb_hSet(_hash_table, 257, 8) //    Гастроэнтерология
    hb_hSet(_hash_table, 258, 9) //    Гематология
    hb_hSet(_hash_table, 259, 23) //    Диетология
    hb_hSet(_hash_table, 260, 25) //    Кардиология
    hb_hSet(_hash_table, 261, 38) //    Нефрология
    hb_hSet(_hash_table, 262, 55) //    Пульмонология
    hb_hSet(_hash_table, 263, 59) //    Ревматология
    hb_hSet(_hash_table, 264, 80) //    Трансфузиология
    hb_hSet(_hash_table, 265, 61) //    Рентгенэндоваскулярные диагностика и лечение
    hb_hSet(_hash_table, 266, 61) //    Рентгенэндоваскулярные диагностика и лечение
    hb_hSet(_hash_table, 267, 42) //    Организация здравоохранения и общественное здоровье
    hb_hSet(_hash_table, 268, 42) //    Организация здравоохранения и общественное здоровье
    hb_hSet(_hash_table, 269, 99) //    Медицинская кибернетика
    hb_hSet(_hash_table, 270, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 271, 60) //    Рентгенология
    hb_hSet(_hash_table, 272, 5) //    Бактериология
    hb_hSet(_hash_table, 273, 6) //    Вирусология
    hb_hSet(_hash_table, 274, 31) //    Лабораторная генетика
    hb_hSet(_hash_table, 275, 26) //    Клиническая лабораторная диагностика
    hb_hSet(_hash_table, 276, 57) //    Радиология
    hb_hSet(_hash_table, 277, 89) //    Функциональная диагностика
    hb_hSet(_hash_table, 278, 81) //    Ультразвуковая диагностика
    hb_hSet(_hash_table, 280, 280) //    Наркология
    hb_hSet(_hash_table, 281, 281) //    Реабилитационное сестринское дело
    hb_hSet(_hash_table, 283, 283) //    Скорая и неотложная помощь
    hb_hSet(_hash_table, 286, 87) //    Физиотерапия
    hb_hSet(_hash_table, 288, 98) //    Медицинская биофизика
    hb_hSet(_hash_table, 289, 98) //    Медицинская биофизика
    hb_hSet(_hash_table, 290, 99) //    Медицинская кибернетика
    hb_hSet(_hash_table, 3200, 97) //    Медицинская биохимия
    hb_hSet(_hash_table, 3201, 97) //    Медицинская биохимия

  endif
  return _hash_table