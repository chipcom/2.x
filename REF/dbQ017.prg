#include "hbhash.ch" 

// На замену глобальной переменной glob_Q017
// проверит и заменить везде
//

* 19.02.21 вернуть массив ФФОМС Q017.xml
function loadQ017()
  // возвращает хэш-массив перечня категорий проверок ФЛК и МЭК
  // <key> - идентификатор категории проверки
  // <value> - массив {'наименование проверки', 'комментарий', 'дата начала применения', 'дата окончания применения'}
  static _Q017
  Local dbName, dbAlias := 'Q017'
  local tmp_select := select()

  // Q017.dbf - Перечень категорий проверок ФЛК и МЭК (TEST_K)
  //  1 - ID_KTEST(4)  2 - NAM_KTEST(C) 3 - COMMENT(M)  4 - DATEBEG(D)  5 - DATEEND(D)  5 - ALFA2(C)  6 - ALFA3(C)
  if _Q017 == nil
    _Q017 := hb_hash()
    hb_hSet( _Q017, 'Key', {'xValue',1} )      
    dbName := '_mo_Q017'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet( _Q017, alltrim(upper((dbAlias)->ID_KTEST)), {alltrim((dbAlias)->NAM_KTEST), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND} )
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q017

* 19.02.21 вернуть массив с описанием категории проверки по идентификатору категории проверки из справочника ФФОМС Q017.xml
function getCategoryCheckErrorByID_Q017(idCategory)
  // idError - идентификатор категории проверки
  // arr[1] - наименование категории проверки
  // arr[2] - комментарий
  // arr[3] - дата начала действия категории проверки
  // arr[4] - дата окончания действия категории проверки
  local arrCategory := loadQ017()
  local category := alltrim(upper(idCategory))
  local aRet := {}

  if hb_hHaskey( arrCategory, category )
    aRet := arrCategory[category]
  else
    AAdd(aRet, 'Неизвестная категория проверки с идентификатором: ' + category)
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
  endif

  return aRet