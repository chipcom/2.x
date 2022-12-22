#include 'hbhash.ch' 

#require 'hbsqlit3'

* 21.12.22 вернуть массив с описанием технологиеского правила реализации ФЛК из справочника ФФОМС Q016.xml
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
  
  // local arrRules := loadQ016()
  local db
  local stmt 
  local rule := alltrim(upper(idRule))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q016 WHERE id_test == :id_test')
  sqlite3_bind_text(stmt, 1, rule)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    // AAdd(aRet, sqlite3_column_text(stmt, 1))
    AAdd(aRet, sqlite3_column_text(stmt, 2))
    AAdd(aRet, sqlite3_column_text(stmt, 3))
    AAdd(aRet, sqlite3_column_text(stmt, 4))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 5), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 6), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 7), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 8)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 9)))
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
  endif

  // if hb_hHaskey(arrRules, rule)
  //   aRet := arrRules[rule]
  // else
  //   AAdd(aRet, 'Неизвестное правило проверки с идентификатором: ' + rule)
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, ctod('  /  /    '))
  //   AAdd(aRet, ctod('  /  /    '))
  // endif

  return aRet

** 21.12.22 вернуть массив ФФОМС Q016.xml
function loadQ016()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор правила проверки
  // <value> - массив

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

  static _Q016
  local db
  local aTable
  local nI

  if _Q016 == nil
    _Q016 := hb_hash()

    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q016' )
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        hb_hSet(_Q016, alltrim(upper(aTable[nI, 1])), {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6]), alltrim(aTable[nI, 7]), ctod(aTable[nI, 8]), ctod(aTable[nI, 9])})
      next
    endif
    db := nil
  endif
  return _Q016

** 21.12.21 вернуть массив ФФОМС Q016.xml
function loadQ016_1()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор правила проверки
  // <value> - массив
  static _Q016
  Local dbName, dbAlias := 'Q016'
  local tmp_select := select()

  // Q016.dbf - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)
  //  1 - KOD(C)  2 - NAME(C) 3 - NSI_OBJ(C)  4 - NSI_EL(C) 5 - USL_TEST(M) 6 - VAL_EL(M) 7 - COMMENT(M)  8 - DATEBEG(D)  9 - DATEEND(D)

  if _Q016 == nil
    _Q016 := hb_hash()
    dbName := '_mo_Q016'
    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet(_Q016, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q016

* 21.05.21 вернуть массив с описанием технологиеского правила реализации ФЛК из справочника ФФОМС Q016.xml
function getRuleCheckErrorByID_Q016_1(idRule)
  // idRule - идентификатор правила проверки
  // arr[1] - наименование категории проверки
  // arr[2] - Код объекта НСИ, на соответствие с которым осуществляется проверка значения элемента
  // arr[3] - Имя элемента объекта НСИ, на соответствие с которым осуществляется проверка значения элемента
  // arr[4] - Условие проведения проверки элемента
  // arr[5] - Множество допустимых значений элемента
  // arr[6] - комментарий
  // arr[7] - дата начала действия категории проверки
  // arr[8] - дата окончания действия категории проверки
  local arrRules := loadQ016()
  local rule := alltrim(upper(idRule))
  local aRet := {}

  if hb_hHaskey(arrRules, rule)
    aRet := arrRules[rule]
  else
    AAdd(aRet, 'Неизвестное правило проверки с идентификатором: ' + rule)
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
  endif

  return aRet

