#include 'hbhash.ch' 

#require 'hbsqlit3'

** 21.12.22 вернуть массив ФФОМС Q017.xml
function loadQ017()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор категории проверки
  // <value> - массив {'наименование проверки', 'комментарий', 'дата начала применения', 'дата окончания применения'}

  // Q017 - Перечень категорий проверок ФЛК и МЭК (TEST_K)
  // ID_KTEST, Строчный(4),	Идентификатор категории проверки
  // NAM_KTEST, Строчный(400),	Наименование категории проверки
  // COMMENT, Строчный(500), Комментарий
  // DATEBEG, Строчный(10),	Дата начала действия записи
  // DATEEND, Строчный(10),	Дата окончания действия записи

  static _Q017
  local db
  local aTable
  local nI

  if _Q017 == nil
    _Q017 := hb_hash()
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT id_ktest, nam_ktest, comment, datebeg, dateend FROM q017')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        hb_hSet(_Q017, alltrim(upper(aTable[nI, 1])), {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _Q017

** 21.12.22 вернуть массив ФФОМС Q017.xml
function loadQ017_1()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор категории проверки
  // <value> - массив {'наименование проверки', 'комментарий', 'дата начала применения', 'дата окончания применения'}
  static _Q017
  Local dbName, dbAlias := 'Q017'
  local tmp_select := select()

  // Q017.dbf - Перечень категорий проверок ФЛК и МЭК (TEST_K)
  //  1 - ID_KTEST(4)  2 - NAM_KTEST(C) 3 - COMMENT(M)  4 - DATEBEG(D)  5 - DATEEND(D)
  if _Q017 == nil
    _Q017 := hb_hash()
    dbName := '_mo_Q017'
    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet(_Q017, alltrim(upper((dbAlias)->ID_KTEST)), {alltrim((dbAlias)->NAM_KTEST), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q017

* 19.02.21 вернуть массив с описанием категории проверки по идентификатору категории проверки из справочника ФФОМС Q017.xml
function getCategoryCheckErrorByID_Q017(idCategory)
  // idError - идентификатор категории проверки
  // arr[1] - идентификатор категории проверки
  // arr[2] - наименование категории проверки
  // arr[3] - комментарий
  // arr[4] - дата начала действия категории проверки
  // arr[5] - дата окончания действия категории проверки
  local arrCategories := loadQ017()
  local category := alltrim(upper(idCategory))
  local aRet := {}

  if hb_hHaskey(arrCategories, category)
    aRet := arrCategories[category]
  else
    AAdd(aRet, 'Неизвестная категория проверки с идентификатором: ' + category)
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
  endif

  return aRet