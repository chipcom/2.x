#include 'common.ch'
#include 'hbhash.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 20.02.26
function mm_ortispol()
  
  return { ;
    { 'Техник', 0 }, ;
    { 'Врач', 1 } }

// 11.09.25
function is_napr_pol( param )

  static lIs_napr_pol

  if HB_ISNIL( lIs_napr_pol )
    lIs_napr_pol := .f.
  endif
  if ! HB_ISNIL( param ) .and. ValType( param ) == 'L'
    lIs_napr_pol := param
  endif
  return lIs_napr_pol
  
// 11.09.25
function is_napr_stac( param )

  static lIs_napr_stac

  if HB_ISNIL( lIs_napr_stac )
    lIs_napr_stac := .f.
  endif
  if ! HB_ISNIL( param ) .and. ValType( param ) == 'L'
    lIs_napr_stac := param
  endif
  return lIs_napr_stac

// 10.09.25
function sem_vagno_task()

  static arr_sem
  local i, arr

  if HB_ISNIL( arr_sem )
    arr_sem := Array( 24 )
    AFill( arr_sem, '' )
    arr := array_tasks()
    for i := 1 to 7
      arr_sem[ arr[ i, 2 ] ] := 'Важный режим в задаче "' + arr[ i, 5 ] + '"'
    next
  endif
  return arr_sem

// 11.09.25
function array_tasks()

  static arr_tasks
  local i, k

  if HB_ISNIL( arr_tasks )
    arr_tasks := {}
    AAdd( arr_tasks, { 'Регистратура поликлиники', X_REGIST, , .t., 'РЕГИСТРАТУРА' } )
    AAdd( arr_tasks, { 'Приёмный покой стационара', X_PPOKOJ, , .t., 'ПРИЁМНЫЙ ПОКОЙ' } )
    AAdd( arr_tasks, { 'Обязательное медицинское страхование', X_OMS, , .t., 'ОМС' } )
    AAdd( arr_tasks, { 'Учёт направлений на госпитализацию', X_263, , .f., 'ГОСПИТАЛИЗАЦИЯ' } )
    AAdd( arr_tasks, { 'Платные услуги', X_PLATN, , .t., 'ПЛАТНЫЕ УСЛУГИ' } )
    AAdd( arr_tasks, { 'Ортопедические услуги в стоматологии', X_ORTO, , .t., 'ОРТОПЕДИЯ' } )
    AAdd( arr_tasks, { 'Касса медицинской организации', X_KASSA, , .t., 'КАССА' } )
//    AAdd( arr_tasks, { 'КЭК медицинской организации', X_KEK, , .f., 'КЭК' } )
    If glob_mo()[ _MO_KOD_TFOMS ] == TF_KOD_MO_VOUNC
      AAdd( arr_tasks, { 'ВОУНЦ - трансплантированные', X_MO, 'TABLET_ICON', .t. } )
    Endif
    AAdd( arr_tasks, { 'Редактирование справочников', X_SPRAV, , .t. } )
    AAdd( arr_tasks, { 'Сервисы и настройки', X_SERVIS, , .t. } )
    AAdd( arr_tasks, { 'Резервное копирование базы данных', X_COPY, , .t. } )
    AAdd( arr_tasks, { 'Переиндексирование базы данных', X_INDEX, , .t. } )

    for i := 1 to len( arr_tasks )
      If ( k := arr_tasks[ i, 2 ] ) < 10  // код задачи
        arr_tasks[ i, 4 ] := ( SubStr( glob_mo()[ _MO_PROD ], k, 1 ) == '1' )
      Endif
      // Учёт направлений на госпитализацию
      If k == X_263 .and. ( is_napr_pol() .or. is_napr_stac() ) // .and. ( substr( glob_mo()[ _MO_PROD ], X_263, 1 ) == '1' )
        arr_tasks[ i, 4 ] := .t.
      Endif
    next
  endif
  return arr_tasks 

// 09.09.25
function glob_adres_podr()

  static arr_address

  if isnil( arr_address )
    arr_address := { ;
      { '103001', { ;
        { '103001', 1, 'г.Волгоград, ул.Землячки, д.78' }, ;
        { '103099', 2, 'г.Михайловка, ул.Мичурина, д.8' }, ;
        { '103099', 3, 'г.Волжский, ул.Комсомольская, д.25' }, ;
        { '103099', 4, 'г.Волжский, ул.Оломоуцкая, д.33' }, ;
        { '103099', 5, 'г.Камышин, ул.Днепровская, д.43' }, ;
        { '103099', 6, 'г.Камышин, ул.Мира, д.51' }, ;
        { '103099', 7, 'г.Урюпинск, ул.Фридек-Мистек, д.8' } ;
        };
      }, ;
      { '101003', ;
        { ;
          { '101003', 1, 'г.Волгоград, ул.Циолковского, д.1' }, ;
          { '101099', 2, 'г.Волгоград, ул.Советская, д.47' } ;
        };
      }, ;
      { '131001', ;
        { ;
          { '131001', 1, 'г.Волгоград, ул.Кирова, д.10' }, ;
          { '131099', 2, 'г.Волгоград, ул.Саши Чекалина, д.7' }, ;
          { '131099', 3, 'г.Волгоград, ул.им.Федотова, д.18' } ;
        };
      }, ;
      { '171004', ;
        { ;
          { '171004', 1, 'г.Волгоград, ул.Ополченская, д.40' }, ;
          { '171099', 2, 'г.Волгоград, ул.Тракторостроителей, д.13' } ;
        };
      };
    }
  endif
  return arr_address
  
// 09.09.25
function glob_arr_mo( reload )

  static arr_mo
  local dbName := '_mo_mo'

  if isnil( arr_mo )
    create_mo_add()
    arr_mo := getmo_mo( dbName )
  elseif ! isnil( reload ) .and. reload
    arr_mo := getmo_mo( dbName, reload )
  endif
  return arr_mo

// 09.09.25
function is_adres_podr( param )

  static lAddressPodr

  if isnil( lAddressPodr )
    lAddressPodr := .f.
  else
    lAddressPodr := param
  endif
  return lAddressPodr

// 09.09.25
function glob_mo( param )

  static mo

  if isnil( mo ) .and. ValType( param ) == 'A'
    mo := param
  endif
  return mo

// 11.09.25
function glob_MU_dializ()

  local arr := {}     // 'A18.05.002.001','A18.05.002.002','A18.05.002.003', ;
  // 'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}

  return arr

// 11.09.25
function glob_KSG_dializ()

  local arr := {}     // '10000901','10000902','10000903','10000905','10000906','10000907','10000913', ;
  // '20000912','20000916','20000917','20000918','20000919','20000920'}
  // '1000901','1000902','1000903','1000905','1000906','1000907','1000913', ;
  // '2000912','2000916','2000917','2000918','2000919','2000920'}

  return arr

// 11.09.25
function is_alldializ( param )

  static is_dial

  if isnil( is_dial )
    is_dial := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_dial := param
  endif
  return is_dial

// 11.09.25
function is_dop_ob_em()

  static is_dop

  if isnil( is_dop )
    is_dop := .f.
  endif
  return is_dop

// 11.09.25
function is_reabil_slux( param )

  static is_reab

  if isnil( is_reab )
    is_reab := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_reab := param
  endif
  return is_reab

// 11.09.25
function is_hemodializ( param )

  static is_hemo

  if isnil( is_hemo )
    is_hemo := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_hemo := param
  endif
  return is_hemo

// 11.09.25
function is_per_dializ( param )

  static is_per

  if isnil( is_per )
    is_per := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_per := param
  endif
  return is_per

// 11.09.25
function glob_menu_mz_rf( index, param )

  static glob_menu

  if isnil( glob_menu )
    glob_menu := { .f., .f., .f. }
  endif
  if PCount() == 2 .and. ( ValType( index ) == 'N' ) .and. ( ValType( param ) == 'L' )
    glob_menu[ index ] := param
  endif
  return glob_menu

// 13.09.25
function glob_klin_diagn( param )

  static klin_diagn

  if isnil( klin_diagn )
    klin_diagn := {}
  endif
  if PCount() == 1 .and. ( ValType( param ) == 'N' )
    aadd( klin_diagn, param )
  endif
  return klin_diagn

// 13.09.25
function glob_yes_kdp2( index, param )

  static glob_kdp2

  if isnil( glob_kdp2 )
    glob_kdp2 := Array( 10 )
    AFill( glob_kdp2, .f. )
  endif
  if PCount() == 2 .and. ( ValType( index ) == 'N' ) .and. ( ValType( param ) == 'L' )
    glob_kdp2[ index ] := param
  endif
  return glob_kdp2

// 12.09.25
function pict_cena()
  return '9999999.99'

// 12.09.25
function picture_pf()

  return '@R 999-999-999 99'

// 12.09.25
function Transform_SNILS( param )

  return Transform( param, picture_pf() )

// 15.09.25
function g_arr_stand( param )

  static arr_stand

  if HB_ISNIL( arr_stand )
    arr_stand := {} 
  endif
  if PCount() == 1
    AAdd( arr_stand, param )
  endif
  return arr_stand

// 15.09.25
function arr_VMP( param )

  static vmp

  if HB_ISNIL( vmp )
    vmp := {} 
  endif
  if PCount() == 1
    AAdd( vmp, param )
  endif
  return vmp

// 15.09.25
function sem_task()
  return 'Учёт работы МО'
  
// 15.09.25
function sem_vagno()
  return 'Учёт работы МО - ответственный режим'
  
// 15.09.25
function err_slock()
  return 'В данный момент с этим режимом работает другой пользователь. Доступ запрещён!'

// 15.09.25
function err_admin()
  return 'Доступ в данный режим разрешен только администратору системы!'

// 16.09.25
function kod_LIS()
  return { '125901', '805965' }

// 20.09.25
function mm_danet()
  return { { 'нет', 0 }, { 'да ', 1 } }

// 08.07.26
function mm_ekst( usl_ok )

  local aRet := { ;
    { 'в плановом порядке', 0 }, ;
    { 'по экст.показаниям', 1 }, ;
    { 'неотложная помощь ', 2 } ;
  }

  if !HB_ISNIL( usl_ok )
    if eq_any( usl_ok, USL_OK_POLYCLINIC, USL_OK_DAY_HOSPITAL )
      hb_ADel( aRet, 2, .t. )
    endif
  endif
  return aRet

// 25.09.25
function glob_arr_usl_LIS()
  
  local arr_usl_LIS
  
  arr_usl_LIS := { ;
    '4.11.136', ;// "Клинический анализ крови (развёрнутый)"
    '4.11.137', ;// "Клинический анализ крови (3 показателя)"
    '4.12.169', ;// "Исследование уровня глюкозы в крови"
    '4.12.170', ;// "Определение гликированного гемоглобина крови"
    '4.12.171', ;// "Тест на толерантность к глюкозе"
    '4.12.172', ;// "Биохимический общетерапевтическ.анализ крови"
    '4.12.173', ;// "Исследование липидного спектра крови"
    '4.12.174', ;// "Исследование крови на общий холестерин"
    '4.14.66', ;// "Кровь на простат-специфический антиген"
    '4.14.67', ;// "пролактин (гормон)"
    '4.14.68', ;// "фолликулостимулирующий гормон"
    '4.14.69', ;// "лютеинизирующий гормон"
    '4.14.70', ;// "эстрадиол (гормон)"
    '4.14.71', ;// "прогестерон (гормон)"
    '4.14.72', ;// "тиреотропный гормон"
    '4.14.73', ;// "трийодтиронин (гормон)"
    '4.14.74', ;// "тироксин (гормон)"
    '4.14.75', ;// "соматотропный гормон"
    '4.14.76', ;// "кортизол (гормон)"
    '4.14.77' ; // "тестостерон (гормон)"
  }
  return arr_usl_LIS

// 09.07.26
function mmpp1ishod()
  
  return { ;
    { 'выписан', 1 }, ;
    { 'в т.ч. в дневной стационар', 2 }, ;
    { 'в круглосуточный стационар', 3 }, ;
    { 'переведен в другой стационар', 4 } }

// 09.07.26
function mmpp2ishod()

  return { ;
    { 'выздоровление', 1 }, ;
    { 'улучшение', 2 }, ;
    { 'без перемен', 3 }, ;
    { 'ухудшение', 4 }, ;
    { 'здоров', 5 }, ;
    { 'умер', 6 } }

// 09.07.26
function mmpp_kem_dost()
  
  return { ;
    { 'самостоятельно', 0 }, ;
    { 'скорой помощью', 1 }, ;
    { 'скорой помощью (транспорт)', 2 }, ;
    { 'прочее', 99 } }

// 09.07.26
function mmpp_kem1dost()
  
  return { ;
    { 'поликлиникой', 1 }, ;
    { 'скорой помощью', 2 }, ;
    { 'полицией', 3 }, ;
    { 'самостоятельно', 4 }, ;
    { 'прочее', 99 } }

// 09.07.26
function mmpp_pr_gospit()
  
  return { ;
    { 'отказался от госпитализации', 1 }, ;
    { 'карантин в отделении       ', 2 }, ;
    { 'отказ по сопутс.заболеванию', 3 }, ;
    { 'нет показаний для госпит-ии', 4 }, ;
    { 'направлен в другое МО      ', 5 }, ;
    { 'оказана амб.пом. в пр.покое', 99 } }

// 09.07.26
function mmpp_travma()
  
  return { ;   // ИСПРАВЛЕННОЕ меню видов травм
    { '--', 0 }, ;
    { 'Промышленная', 1 }, ;
    { 'Транспортная производственная', 2 }, ;
    { '  в т.ч. ДТП производственная', 3 }, ;
    { 'Сельскохозяйственная', 4 }, ;
    { 'Прочая производственная', 5 }, ;
    { 'Бытовая', 6 }, ;
    { 'Уличная', 7 }, ;
    { 'Трансп., не связанная с пр-ством', 8 }, ;
    { '  в т.ч. ДТП непроизводственная', 9 }, ;
    { 'Школьная', 10 }, ;
    { 'Спортивная', 11 }, ;
    { 'Противоправная травма', 12 }, ;
    { 'Прочая, не связанная с пр-ством', 13 } }

// 09.07.26
function menu_stdnst()
  
  return { ;
    { 'стационар ', 0 }, ;
    { 'днев.стац.', 1 } }

// 09.07.26
function menu_sost_op()
  
  return { ;
    { '--            ', 0 }, ;
    { 'алкогольного  ', 1 }, ;
    { 'наркотического', 2 } }

// 09.07.26
function menu0gospit()
  
  return { ;
    { 'первично', 0 }, ;
    { 'повторно', 1 } }

// 09.07.26
function menu2gospit()
  
  return { ;
    { 'в первые 6 часов', 1 }, ;
    { 'в теч.7-24 часов', 2 }, ;
    { 'позднее 24 часов', 0 } }

// 09.07.26
function mmpp_regim()
  
  return { ; // ИСПРАВЛЕННОЕ меню режима лечения
    { 'стационар круглосуточного пребывания', 1 }, ;   // 1
    { 'дневной стационар при больнице', 2 }, ;   // 3
    { 'дневной стационар при поликлинике', 3 }, ;   // 3
    { 'дневной стационар на дому', 4 } }    // 3

// 09.07.26
function menupol()
  
  return { 'М', 'Ж' }

// 03.10.25
function menu_vzros()
  return { { 'взрослый ', 0 }, { 'ребёнок  ', 1 }, { 'подросток', 2 } }

// 03.10.25
function mm_vid_polis()
  return { { 'старый', 1 }, { 'врем. ', 2 }, { 'новый ', 3 } }

// 09.07.26
function mm_gorod_selo()
  
  return { { 'город', 1 }, { 'село', 2 }, { 'р/поселок', 3 } }

// 10.07.26
function menu_vid_opl()
  
  return { ;
    { 'ОМС', 1 }, ;  // (битовое)
    { 'Бюджет', 2 }, ;
    { 'Пл.услуги', 3 }, ;
    { 'ДМС', 4 }, ;
    { 'Другое', 5 } }

// 10.07.26
function rule_section()
  
  return { ;
    'СПИСОК ОСТРЫХ ЗАБОЛЕВАНИЙ - ВСЕГДА ПЕРВИЧНЫЕ', ;
    'СПИСОК ЗАБОЛЕВАНИЙ, ПО КОТОРЫМ ДОЛЖНА БЫТЬ ДИСПАНСЕНРИЗАЦИЯ', ;
    'СПИСОК ОГРАНИЧЕНИЙ ДИАГНОЗОВ ПО ПОЛОВОМУ ПРИЗНАКУ', ;
    'СПИСОК ДИАГНОЗОВ, КОТОРЫЕ ВООБЩЕ НЕ ДОЛЖНЫ ВВОДИТЬСЯ', ;
    'ДАННЫЕ БУКВЫ У ОДНОГО БОЛЬНОГО ВСТРЕЧАЮТСЯ ТОЛЬКО РАЗ В ГОДУ', ;
    'ТОЛЬКО ОДНА ИЗ ДАННЫХ БУКВ У БОЛЬНОГО ВСТРЕЧАЕТСЯ РАЗ В ГОД' }

// 10.07.26
function mm_vid_reab()
  
  return { ;
    { '- не вводился -', 0 }, ;
    { 'без наличия системы кохлеарной имплантации у пациента', 1 }, ;
    { 'после кохлеарной имплантации, за исключением замены речевого процессора', 2 }, ;
    { 'после замены речевого процессора', 3 } }

// 10.07.26
function mm_ekst_smp()
  
  return { ;
    { 'неотложная', 0 }, ;
    { 'экстренная', 1 } }

// 10.07.26
function mm_vskrytie()
  
  return { ;
    { 'не проводилось', 0 }, ;
    { 'паталого-анатомическое', 1 }, ;
    { 'судебно-медицинское', 2 } }

// 10.07.26
function glob_MGI()
  
  return { ;
      { '60.9.1', 12, 26, 25 }, ; // Молекулярно-генетическое исследование мутаций в генах BRCA1 и BRCA2 в крови
      { '60.9.13', 5, 12, 11 }, ; // Молекулярно-генетическое исследование мутаций в гене EGFR в биопсийном (операционном) материале
      { '60.9.31', 1, 2, 1 }, ; // Определение амплификации гена HER2 методом флюоресцентной гибридизации in situ (FISH)
      { '60.9.32', 1, 2, 1 }, ; // Определение амплификации гена HER2 методом хромогенной гибридизации in situ (CISH)
      { '60.9.5',  4, 10, 9 }, ; // Молекулярно-генетическое исследование мутаций в гене KRAS в биопсийном (операционном) материале
      { '60.9.6',  4, 10, 9 }, ; // Молекулярно-генетическое исследование мутаций в гене NRAS в биопсийном (операционном) материале
      { '60.9.7',  2, 5, 4 } ;  // Молекулярно-генетическое исследование мутаций в гене BRAF в биопсийном (операционном) материале
    }  // второй эл-т массива - код по справочнику N010

// 11.07.26
function stm_travma()
  
  return { ;
    { '__ нет __', 0 }, ;
    { 'Промышленная', 1 }, ;
    { 'Сельскохозяйственная', 2 }, ;
    { 'Строительная', 3 }, ;
    { 'Дорожно-транспортная пр-венная', 4 }, ;
    { 'Прочая производственная', 5 }, ;
    { 'Бытовая', 6 }, ;
    { 'Уличная', 7 }, ;
    { 'Дор.трансп., не связанная с пр-вом', 8 }, ;
    { 'Школьная', 9 }, ;
    { 'Спортивная', 10 }, ;
    { 'Прочая, не связанная с пр-вом', 11 } }

// 11.07.26
function stm_povod()
  
  return { ;
    { 'Лечебно-диагностический', 1 }, ;
    { 'Консультативный', 2 }, ;
    { 'Диспансерное наблюдение', 3 }, ;
    { 'Профилактический', 4 }, ;
    { 'Профессиональный осмотр', 5 }, ;
    { 'Реабилитационный', 6 }, ;
    { 'Зубопротезный', 7 }, ;
    { 'Протезно-ортопедический', 8 }, ;
    { 'Прочий', 9 } }
