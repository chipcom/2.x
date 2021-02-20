#include "hbhash.ch" 

// На замену глобальной переменной glob_Q015
// проверит и заменить везде
//

* 20.02.21 вернуть массив ФФОМС Q015.xml
function loadQ015()
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
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet( _Q015, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND} )
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

  if hb_hHaskey( arrRules, rule )
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