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
    arr_mo := getMo_mo()
    // ⠪ � ���ᨢ� ����஢��� ���� �ࠢ�筨�� ��
    //{"MCOD",       "C",      6,      0},;  1
    //{"CODEM",      "C",      6,      0},;  2
    //{"NAMEF",      "C", �� 250,      0},;  3
    //{"NAMES",      "C", ��  80,      0},;  4
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
        func_error(4,"�����襭 䠩� "+upper(nfile))
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

    // alertx(len(arr_mo), 'arr_MO')
    // alertx(len(glob_arr_mo), 'glob_arr_MO')

    // // for i := 1 to len(glob_arr_mo[67])
    // //   alertx(hb_valToExp(glob_arr_mo[67,i]), 'MO-' + alltrim(str(i)))
    // // next
    
    // for i := 1 to len(arr_mo[67])
    //   alertx(hb_valToExp(arr_mo[67,i]), 'MO 1-' + alltrim(str(i)))
    // next

    checkArray(glob_arr_mo, arr_mo)
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
    //       is_adres_podr := .t. ; glob_podr_2 := glob_adres_podr[i,2,2,1] // ��ன ��� ��� 㤠�񭭮�� ����
    //     endif
    //   else
    //     func_error(4,'� ��� � �ࠢ�筨�� ������ ���������騩 ��� �� "'+cCode+'". ������ ��� ������.')
    //     cCode := ""
    //   endif
    // endif
    // if empty(cCode)
    //   if (cCode := input_value(18,2,20,77,color1,;
    //                         "������ ��� �� ��� ���ᮡ������� ���ࠧ�������, ��᢮���� �����",;
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
    //       fl := func_error('����� ���������� - ������ ��� �� "'+cCode+'" ����७.')
    //     endif
    //   endif
    // endif
    // if empty(cCode)
    //   fl := func_error('����� ���������� - �� ����� ��� ��.')
    // endif
  else
    fl := func_error('����� ���������� - �� �����㦥� 䠩� "_MO_MO.DBB"')
  endif

  Inkey(0)
  return

* 05.06.21 ������ ���ᨢ _mo_dbb.dbf
function getMo_mo(reload)
  // reload - 䫠� 㪠�뢠�騩 �� ��१���㧪� �ࠢ�筨��, .T. - ��१���㧨��, .F. - ���
  
    // _mo_mo.dbf - �ࠢ�筨� �����०�����
    //  1 - MCOD(C)  2 - CODEM(C)  3 - NAMEF(C)  4 - NAMES(C) 5 - ADRES(C) 6 - MAIN(C)
    //  7 - PFA(C) 8 - PFS(C) 9 - PROD(C) 10 - DOLG(C) 
    //  11 - DEND(D)  12 - STANDART(C)  13 - UROVEN(C)
    static _arr := {}
    local dbName := '_mo_mo'
    local standart, uroven
    local row, tmp
  
    DEFAULT reload TO .f.
  
    if reload
      // ���⨬ ���ᨢ ��� ����� ����㧪� �ࠢ�筨��
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
              uroven, ; // �஢��� ������, � 2013 ���� 4 - �������㠫�� ����
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

function checkArray(arr1, arr2)
  local i, j

  if len(arr1) != len(arr2)
    ? '������ ����� ���ᨢ��'
  endif

  for i := 1 to len(arr1)
    for j := 1 to len(arr1[i])
      if j == 7 .or. j == 8
        if ! checkA(arr1[i,j],arr2[i,j])
          ? '�⫨稥 � ���ᨢ�:' + alltrim(str(i)) + ':' + alltrim(str(j))
        endif
      else
        if ( arr1[i, j] == arr2[i, j] )
        else
          ? '�⫨稥 � :' + alltrim(str(i)) + ':' + alltrim(str(j))
          ? arr1[i,j]
          ? arr2[i,j]
        endif
      endif
    next
  next
  return nil

function checkA( a1, a2)
  local ret := .t., i, j

  if len(a1) != len(a2)
    return .f.
  endif

  for i := 1 to len(a1)
    if (valtype(a1[i]) != 'A') .and. (valtype(a2[i]) != 'A')
      if (valtype(a1[i]) == valtype(a2[i]))
        if a1[i] != a2[i]
          return .f.
        endif
      else
        ? a1[i]
        ? a2[i]
        return .f.
      endif
    else
      if ! checkA(a1[i], a2[i])
        return .f.
      endif
    endif
  next
  return ret