* 25.05.21 вернуть исход заболевания по коду
function getISHOD_V012( ishod )
  local ret := NIL
  local i

  if (i := ascan(glob_V012, {|x| x[2] == ishod })) > 0
    ret := glob_V012[i,1]
  endif
  return ret

* 11.12.21 вернуть массив по справочнику ФФОМС V012.xml
function getV012()
  // V012.xml - Классификатор исходов заболевания
  Local dbName, dbAlias := 'V012'
  local tmp_select := select()
  local stroke := '', vid := ''
  static _arr := {}

  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v012'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IZNAME(C)  2 - IDIZ(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND)  // только если поле окончания действия пусто
        if (dbAlias)->DL_USLOV == 1
          vid := '/ст-р/'
        elseif (dbAlias)->DL_USLOV == 2
          vid := '/дн.с/'
        elseif (dbAlias)->DL_USLOV == 3
          vid := '/п-ка/'
        else
          vid := '/'
        endif
        stroke := str((dbAlias)->IDIZ, 3) + vid + alltrim((dbAlias)->IZNAME)
        aadd(_arr, { stroke, (dbAlias)->IDIZ, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->DL_USLOV })
      endif
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)

    // aadd(_arr, {"101/ст-р/Выздоровление",101,stod("20110101"),stod(""),1})
    // aadd(_arr, {"102/ст-р/Улучшение",102,stod("20110101"),stod(""),1})
    // aadd(_arr, {"103/ст-р/Без перемен",103,stod("20110101"),stod(""),1})
    // aadd(_arr, {"104/ст-р/Ухудшение",104,stod("20110101"),stod(""),1})
    // aadd(_arr, {"201/дн.с/Выздоровление",201,stod("20110101"),stod(""),2})
    // aadd(_arr, {"202/дн.с/Улучшение",202,stod("20110101"),stod(""),2})
    // aadd(_arr, {"203/дн.с/Без перемен",203,stod("20110101"),stod(""),2})
    // aadd(_arr, {"204/дн.с/Ухудшение",204,stod("20110101"),stod(""),2})
    // aadd(_arr, {"301/п-ка/Выздоровление",301,stod("20110101"),stod(""),3})
    // aadd(_arr, {"302/п-ка/Ремиссия",302,stod("20110101"),stod(""),3})
    // aadd(_arr, {"303/п-ка/Улучшение",303,stod("20110101"),stod(""),3})
    // aadd(_arr, {"304/п-ка/Без перемен",304,stod("20110101"),stod(""),3})
    // aadd(_arr, {"305/п-ка/Ухудшение",305,stod("20110101"),stod(""),3})
    // aadd(_arr, {"306/п-ка/Осмотр",306,stod("20120123"),stod(""),3})
    // aadd(_arr, {"401/Улучшение",401,stod("20110101"),stod(""),4})
    // aadd(_arr, {"402/Без эффекта",402,stod("20110101"),stod(""),4})
    // aadd(_arr, {"403/Ухудшение",403,stod("20110101"),stod(""),4})
  endif

  return _arr 