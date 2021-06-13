#include 'function.ch'
#include 'chip_mo.ch'

****** 13.06.2021  вернуть массив _mo_dbb.dbb
function getMo_mo(nfile)
  local i, arr, arr1
  local ret_arr := {}

  arr1 := rest_arr(nfile)
  for i := 1 to len(arr1)
    arr := array(_MO_LEN_ARR)
    if !(valtype(arr1[i]) == "A") .or. len(arr1[i]) < 12
      func_error(4,"Разрушен файл "+upper(nfile))
      loop
    endif
    arr[_MO_KOD_FFOMS]  := crypt(arr1[i,1],gpasskod)
    arr[_MO_KOD_TFOMS]  := crypt(arr1[i,2],gpasskod)
    arr[_MO_FULL_NAME]  := crypt(arr1[i,3],gpasskod)
    arr[_MO_SHORT_NAME] := crypt(arr1[i,4],gpasskod)
    arr[_MO_ADRES]      := crypt(arr1[i,5],gpasskod)
    arr[_MO_PROD]       := crypt(arr1[i,9],gpasskod)
    arr[_MO_DEND]       := ctod(crypt(arr1[i,10],gpasskod))
    arr[_MO_STANDART]   := arr1[i,11]
    arr[_MO_UROVEN]     := arr1[i,12]
    arr[_MO_IS_MAIN]    := (arr1[i,6]=='1')
    arr[_MO_IS_UCH]     := (arr1[i,7]=='1')
    arr[_MO_IS_SMP]     := (arr1[i,8]=='1')
    if valtype(arr[_MO_UROVEN]) != "A"
      arr[_MO_UROVEN] := {}
    endif
    aadd(ret_arr, aclone(arr))
  next

  return ret_arr

* 13.06.21 вернуть массив _mo_dbb.dbf
function getMo_mo_New(dbName, reload)
  // reload - флаг указывающий на перезагрузку справочника, .T. - перезагрузить, .F. - нет
  
  // _mo_mo.dbf - справочник медучреждений
  //  1 - MCOD(C)  2 - CODEM(C)  3 - NAMEF(C)  4 - NAMES(C) 5 - ADRES(C) 6 - MAIN(C)
  //  7 - PFA(C) 8 - PFS(C) 9 - PROD(C) 10 - DOLG(C) 
  //  11 - DEND(D)  12 - STANDART(C)  13 - UROVEN(C)
  static _arr := {}
  // local dbName := '_mo_mo'
  local standart, uroven
  local row, tmp
  
  DEFAULT reload TO .f.
  
  if reload
    // очистим массив для новой загрузки справочника
    _arr := {}
  endif
  
  if len(_arr) == 0
    dbUseArea( .t.,, dir_server + dbName, dbName, .f., .f. )
    // dbUseArea( .t., , dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      standart := {}
      uroven := {}

      hb_jsonDecode( (dbName)->STANDART, @standart )
      hb_jsonDecode( (dbName)->UROVEN, @uroven )

      for each row in standart
        row[1] := hb_SToD(row[1])
      next
      for each row in uroven
        row[1] := hb_SToD(row[1])
      next

      aadd(_arr, { ;
              alltrim((dbName)->NAMES), ;
              alltrim((dbName)->CODEM), ;
              (dbName)->PROD, ;
              (dbName)->DEND, ;
              alltrim((dbName)->MCOD), ;
              alltrim((dbName)->NAMEF), ;
              uroven, ; // уровень оплаты, с 2013 года 4 - индивидуальные тарифы
              standart, ;
              (dbName)->MAIN == '1', ;
              (dbName)->PFA == '1', ;
              (dbName)->PFS == '1', ;
              alltrim((dbName)->ADRES) ;
        } )

      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    // TODO - добавить из файла новых мед. учреждений
  endif
  
  return _arr
