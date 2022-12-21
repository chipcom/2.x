#include 'hbhash.ch' 

#require 'hbsqlit3'

** 21.12.22 вернуть массив ФФОМС Q015.xml
function loadQ015()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор правила проверки
  // <value> - массив

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

  static _Q015
  local db
  local aTable
  local nI
  if _Q015 == nil
    _Q015 := hb_hash()

    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q015')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        hb_hSet(_Q015, alltrim(upper(aTable[nI, 1])), {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6]), alltrim(aTable[nI, 7]), ctod(aTable[nI, 8]), ctod(aTable[nI, 9])})
      next
    endif
    db := nil

  endif
  return _Q015

** 21.12.22 вернуть массив ФФОМС Q015.xml
function loadQ015_1()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор правила проверки
  // <value> - массив
  static _Q015
  Local dbName, dbAlias := 'Q015'
  local tmp_select := select()

  // Q015.dbf - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)
  //  1 - KOD(C)  2 - NAME(C) 3 - NSI_OBJ(C)  4 - NSI_EL(C) 5 - USL_TEST(M) 6 - VAL_EL(M) 7 - COMMENT(M)  8 - DATEBEG(D)  9 - DATEEND(D)

  if _Q015 == nil
    _Q015 := hb_hash()
    dbName := '_mo_Q015'
    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet(_Q015, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q015

* 20.02.21 вернуть массив с описанием технологиеского правила реализации ФЛК из справочника ФФОМС Q015.xml
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
  local arrRules := loadQ015()
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