#include 'hbhash.ch' 

#require 'hbsqlit3'

** 22.12.22 вернуть массив с описанием категории проверки по идентификатору категории проверки из справочника ФФОМС Q017.xml
function getCategoryCheckErrorByID_Q017(idCategory)
  // idError - идентификатор категории проверки
  // arr[1] - наименование категории проверки
  // arr[2] - комментарий
  // arr[3] - дата начала действия категории проверки
  // arr[4] - дата окончания действия категории проверки
  // arr[5] - идентификатор категории проверки

  // Q017 - Перечень категорий проверок ФЛК и МЭК (TEST_K)
  // ID_KTEST, Строчный(4),	Идентификатор категории проверки
  // NAM_KTEST, Строчный(400),	Наименование категории проверки
  // COMMENT, Строчный(500), Комментарий
  // DATEBEG, Строчный(10),	Дата начала действия записи
  // DATEEND, Строчный(10),	Дата окончания действия записи

  local db
  local stmt 
  local category := alltrim(upper(idCategory))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_ktest, nam_ktest, comment, datebeg, dateend FROM q017 WHERE id_ktest == :id_ktest')
  sqlite3_bind_text(stmt, 1, category)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 2), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 3), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 4)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 5)))
    AAdd(aRet, sqlite3_column_text(stmt, 1))
  enddo
  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')

  sqlite3_clear_bindings(stmt)
  sqlite3_finalize(stmt)

  db := nil

  if len(aRet) == 0
    AAdd(aRet, 'Неизвестная категория проверки с идентификатором: ' + category)
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, '')
  endif

  return aRet

* 22.12.22 вернуть массив с описанием технологиеского правила реализации ФЛК из справочника ФФОМС Q015.xml
function getRuleCheckErrorByID_Q015(idRule)
  // idRule - идентификатор правила проверки
  // arr[1] - наименование категории проверки
  // arr[2] - Код объекта НСИ, на соответствие с которым осуществляется проверка значения элемента
  // arr[3] - Имя элемента объекта НСИ, на соответствие с которым осуществляется проверка значения элемента
  // arr[4] - Условие проведения проверки элемента
  // arr[5] - Множество допустимых значений элемента
  // arr[6] - комментарий
  // arr[7] - дата начала действия категории проверки
  // arr[8] - дата окончания действия категории проверки
  // arr[8] - идентификатор правила проверки

  // Q015 - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)
  // ID_TEST, Строчный(12), Идентификатор проверки.
  //      Формируется по шаблону KKKK.00.TTTT, где
  //      KKKK - идентификатор категории проверки 
  //        в соответствии с классификатором Q017,
  //      TTTT - уникальный номер проверки в категории
  // ID_EL, Строчный(100),	Идентификатор элемента, 
  //      подлежащего проверке (Приложение А, классификатор Q018)
  // TYPE_MD	ОМ	Допустимые типы передаваемых данных, содержащих 
  //      элемент, подлежащий проверке
  // TYPE_D, Строчный(2),	Тип передаваемых данных, содержащих элемент,
  //      подлежащий проверке (Приложение А, классификатор Q019)
  // NSI_OBJ, Строчный(4), Код объекта НСИ, на соответствие с которым 
  //      осуществляется проверка значения элемента
  // NSI_EL, Строчный(20), Имя элемента объекта НСИ, на соответствие с 
  //      которым осуществляется проверка значения элемента
  // USL_TEST, Строчный(254),	Условие проведения проверки элемента
  // VAL_EL, Строчный(254),	Множество допустимых значений элемента
  // MIN_LEN, Целочисленный(4),	Минимальная длина значения элемента
  // MAX_LEN, Целочисленный(4),	Максимальная длина значения элемента
  // MASK_VAL, Строчный(254),	Маска значения элемента
  // COMMENT, Строчный(500), Комментарий
  // DATEBEG, Строчный(10),	Дата начала действия записи
  // DATEEND, Строчный(10),	Дата окончания действия записи

  local db
  local stmt 
  local rule := alltrim(upper(idRule))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q015 WHERE id_test == :id_test')
  sqlite3_bind_text(stmt, 1, rule)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    AAdd(aRet, sqlite3_column_text(stmt, 2))
    AAdd(aRet, sqlite3_column_text(stmt, 3))
    AAdd(aRet, sqlite3_column_text(stmt, 4))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 5), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 6), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 7), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 8)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 9)))
    AAdd(aRet, sqlite3_column_text(stmt, 1))
  enddo
  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')

  sqlite3_clear_bindings(stmt)
  sqlite3_finalize(stmt)

  db := nil

  if len(aRet) == 0
    AAdd(aRet, 'Неизвестное правило проверки с идентификатором: ' + rule)
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, '')
  endif

  return aRet

** 22.12.22 вернуть массив с описанием технологиеского правила реализации ФЛК из справочника ФФОМС Q016.xml
function getRuleCheckErrorByID_Q016(idRule)
  // idRule - идентификатор правила проверки
  // arr[1] - наименование категории проверки
  // arr[2] - Код объекта НСИ, на соответствие с которым осуществляется проверка значения элемента
  // arr[3] - Имя элемента объекта НСИ, на соответствие с которым осуществляется проверка значения элемента
  // arr[4] - Условие проведения проверки элемента
  // arr[5] - Множество допустимых значений элемента
  // arr[6] - комментарий
  // arr[7] - дата начала действия категории проверки
  // arr[8] - дата окончания действия категории проверки
  // arr[8] - идентификатор правила проверки

  // Q016 - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)
  // ID_TEST, Строчный(12),	Идентификатор проверки. 
  //      Формируется по шаблону KKKK.RR.TTTT, где
  //      KKKK - идентификатор категории проверки 
  //        в соответствии с классификатором Q017,
  //      RR код ТФОМС в соответствии с классификатором F010.
  //        Для проверок федерального уровня RR принимает значение 00.
  //      TTTT - уникальный номер проверки в категории
  // ID_EL, Строчный(100),	Идентификатор элемента, 
  //      подлежащего проверке (Приложение А, классификатор Q018)
  
  // DESC_TEST, Строчный(500),	Описание проверки
  // TYPE_MD	ОМ	Допустимые типы передаваемых данных, содержащих 
  //      элемент, подлежащий проверке
  // TYPE_D, Строчный(2),	Тип передаваемых данных, содержащих элемент,
  //      подлежащий проверке (Приложение А, классификатор Q019)
  // NSI_OBJ, Строчный(4), Код объекта НСИ, на соответствие с которым 
  //      осуществляется проверка значения элемента
  // NSI_EL, Строчный(20), Имя элемента объекта НСИ, на соответствие с 
  //      которым осуществляется проверка значения элемента
  // USL_TEST, Строчный(254),	Условие проведения проверки элемента
  // VAL_EL, Строчный(254),	Множество допустимых значений элемента
  // COMMENT, Строчный(500), Комментарий
  // DATEBEG, Строчный(10),	Дата начала действия записи
  // DATEEND, Строчный(10),	Дата окончания действия записи
  
  local db
  local stmt 
  local rule := alltrim(upper(idRule))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q016 WHERE id_test == :id_test')
  sqlite3_bind_text(stmt, 1, rule)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    AAdd(aRet, sqlite3_column_text(stmt, 2))
    AAdd(aRet, sqlite3_column_text(stmt, 3))
    AAdd(aRet, sqlite3_column_text(stmt, 4))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 5), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 6), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 7), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 8)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 9)))
    AAdd(aRet, sqlite3_column_text(stmt, 1))
  enddo
  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')

  sqlite3_clear_bindings(stmt)
  sqlite3_finalize(stmt)

  db := nil
  if len(aRet) == 0
      AAdd(aRet, 'Неизвестное правило проверки с идентификатором: ' + rule)
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, ctod('  /  /    '))
      AAdd(aRet, ctod('  /  /    '))
      AAdd(aRet, '')
  endif

  return aRet
