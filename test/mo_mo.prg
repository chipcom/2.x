#include 'function.ch'
#include 'chip_mo.ch'


//  https://github.com/APerricone/harbourCodeExtension/wiki/Debugger

procedure main()
  Local fl := .t., i, arr, arr1, cCode := ''
  local nfile := '_mo_mo.dbb'
  local glob_arr_mo := {}, glob_mo, glob_podr := '', glob_podr_2 := ''
  local gpasskod := ret_gpasskod()
  local arr_mo
  
  REQUEST HB_CODEPAGE_RU866
  HB_CDPSELECT("RU866")
  REQUEST HB_LANG_RU866
  HB_LANGSELECT("RU866")

  REQUEST DBFNTX
  RDDSETDEFAULT("DBFNTX")

  //SET(_SET_EVENTMASK,INKEY_KEYBOARD)
  SET SCOREBOARD OFF
  SET EXACT ON
  SET DATE GERMAN
  SET WRAP ON
  SET CENTURY ON
  SET EXCLUSIVE ON
  SET DELETED ON


  if hb_FileExists(nfile)
    arr_mo := getMo_mo_new()
    // так в массиве зашифрованы поля справочника МО
    //{"MCOD",       "C",      6,      0},;  1
    //{"CODEM",      "C",      6,      0},;  2
    //{"NAMEF",      "C", до 250,      0},;  3
    //{"NAMES",      "C", до  80,      0},;  4
    //{"ADRES",      "C",    250,      0},;  5
    //{"MAIN",       "C",      1,      0},;  6
    //{"PFA",        "C",      1,      0},;  7
    //{"PFS",        "C",      1,      0},;  8
    //{"PROD",       "C",     10,      0},;  9
    //{"DOLG",       "C",     10,      0},; 10
    //{"STANDART",   "A",     {},      0},; 11
    //{"UROVEN",     "A",     {},       };  12
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
      aadd(glob_arr_mo, aclone(arr))
    next

    alertx(len(arr_mo), 'arr_MO')
    alertx(len(glob_arr_mo), 'glob_arr_MO')

    // for i := 1 to len(glob_arr_mo[67])
    //   alertx(hb_valToExp(glob_arr_mo[67,i]), 'MO-' + alltrim(str(i)))
    // next
    
    for i := 1 to len(arr_mo[67])
      alertx(hb_valToExp(arr_mo[67,i]), 'MO 1-' + alltrim(str(i)))
    next

    // if hb_FileExists(dir_server+"organiz"+sdbf)
    //   R_Use(dir_server+"organiz",,"ORG")
    //   if lastrec() > 0
    //     cCode := left(org->kod_tfoms,6)
    //   endif
    // endif
    // close databases
    // if !empty(cCode)
    //   if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
    //     glob_mo := glob_arr_mo[i]
    //     if (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
    //       is_adres_podr := .t. ; glob_podr_2 := glob_adres_podr[i,2,2,1] // второй код для удалённого адреса
    //     endif
    //   else
    //     func_error(4,'У Вас в справочнике занесён несуществующий код МО "'+cCode+'". Введите его заново.')
    //     cCode := ""
    //   endif
    // endif
    // if empty(cCode)
    //   if (cCode := input_value(18,2,20,77,color1,;
    //                         "Введите код МО или обособленного подразделения, присвоенный ТФОМС",;
    //                         space(6),"999999")) != NIL .and. !empty(cCode)
    //     if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
    //       glob_mo := glob_arr_mo[i]
    //       if hb_FileExists(dir_server+"organiz"+sdbf)
    //         G_Use(dir_server+"organiz",,"ORG")
    //         if lastrec() == 0
    //           AddRecN()
    //         else
    //           G_RLock(forever)
    //         endif
    //         org->kod_tfoms := glob_mo[_MO_KOD_TFOMS]
    //         org->name_tfoms := glob_mo[_MO_SHORT_NAME]
    //         org->uroven := get_uroven()
    //       endif
    //       close databases
    //     else
    //       fl := func_error('Работа невозможна - введённый код МО "'+cCode+'" неверен.')
    //     endif
    //   endif
    // endif
    // if empty(cCode)
    //   fl := func_error('Работа невозможна - не введён код МО.')
    // endif
  else
    fl := func_error('Работа невозможна - не обнаружен файл "_MO_MO.DBB"')
  endif

  return

* 05.06.21 вернуть массив _mo_dbb.dbf
function getMo_mo_new(reload)
  // reload - флаг указывающий на перезагрузку справочника, .T. - перезагрузить, .F. - нет
  
    // _mo_mo.dbf - справочник медучреждений
    //  1 - MCOD(C)  2 - CODEM(C)  3 - NAMEF(C)  4 - NAMES(C)
    //  5 - PROD(C)  6 - DEND(D)  7 - STANDART(C)  8 - UROVEN(C)
    static _arr := {}
    local dbName := '_mo_mo'
    local standart, uroven
    local row, tmp
  
    DEFAULT reload TO .f.
  
    if reload
      // очистим массив для новой загрузки справочника
      _arr := {}
    endif
  
    if len(_arr) == 0
      // dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
      dbUseArea( .t., , dbName, dbName, .f., .f. )
      (dbName)->(dbGoTop())
      do while !(dbName)->(EOF())
        standart := {}
        uroven := {}

        hb_jsonDecode( (dbName)->STANDART, @standart )
        hb_jsonDecode( (dbName)->UROVEN, @uroven )

        for each row in standart
          tmp :=  substr(row[1],7,2) + '.' + substr(row[1],5,2) + '.' + substr(row[1],1,4)
          row[1] := ctod(tmp)
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
    endif
  
    return _arr