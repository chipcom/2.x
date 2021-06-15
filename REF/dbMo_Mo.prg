#include 'function.ch'
#include 'chip_mo.ch'


***** 14.06.21
Function create_mo_add()
  local sbase := 'mo_add'

  if !hb_FileExists(dir_server+sbase+sdbf)
    adbf := {;
     { 'MCOD',      'C',   6, 0 }, ; // 
     { 'CODEM',     'C',   6, 0 }, ; // 
     { 'NAMEF',     'C', 250, 0 }, ; // 
     { 'NAMES',     'C',  80, 0 }, ; //
     { 'ADRES',     'C', 250, 0 }, ; // 
     { 'DEND',      'D',   8, 0 } ; // 
    }
    reconstruct(dir_server + sbase, adbf, "index_base('mo_add')", , .t.)
    fill_mo_add(sbase)

  endif
  return nil

***** 14.06.21
Function fill_mo_add(sbase)
  local aa := { ;
    {'080044','999919','�� �.����모� "���㡫����᪨� ���᪨� ���.業�� ��.���������� �����⨭� ����������"','�� �.����모� "���㡫����᪨� ���᪨� ���.業�� ��.���������� �����⨭� �������"','',,0d20251231}, ;
    {'080007','999928','�� �� "���⥭᪠� ��" ��㡫��� ����모�','�� �� "���⥭᪠� ��" ��㡫��� ����모�','',0d20251231}, ;
    {'080030','999918','��⭮� ��०����� ���㡫��� ����모� "��ਭ�⠫�� 業�� ��.�.�.�㭣�����"','��⭮� ��०����� ���㡫��� ����모� "��ਭ�⠫�� 業�� ��. �.�. �㭣�����"','',0d20251231}, ;
    {'772275','999998','���� "��த᪠� ����������� "107 ���"','���� ��த᪠� ����������� "107 ���"','','',0d20251231}, ;
    {'580046','999922','���� "������᪠� ��"','���� "������᪠� ��"','',0d20251231}, ;
    {'300034','999997','���� �� "�����⨭���᪠� ���⪮��� ���쭨�"','���� �� "�����⨭���᪠� ���⪮��� ���쭨�"','',0d20251231}, ;
    {'300049','999927','���� �� "����������� ��"','���� �� "����������� ��"','',0d20251231}, ;
    {'300026','999996','���� �� ���㡨�᪠� ��.','���� �� ���㡨�᪠� ���','',0d20251231}, ;
    {'300033','999917','���� ����堭᪮� ������ "���㡨�᪠� ࠩ����� ���쭨�"','���� ����堭᪮� ������ "���㡨�᪠� ࠩ����� ���쭨�"','',0d20251231}, ;
    {'772286','999921','���� ��த� ��᪢� "��த᪠� ������᪠� ���쭨� � 52 �����⠬��� ��ࠢ���࠭���� ��த� ��᪢�"','���� ��த� ��᪢� "��த᪠� ������᪠� ���쭨� � 52 �����⠬��� ��ࠢ���࠭"','',0d20251231}, ;
    {'481601','999924','��� "����檠� ��"','��� "����檠� ��"','','1','',0d20251231}, ;
    {'640251','999913','��� ��� N 14','��� ��� N 14','',0d20251231}, ;
    {'640961','999915','��� ��� N 16','��� ��� N 16','',0d20251231}, ;
    {'640431','999912','��� ��� N 17','��� ��� N 17','',0d20251231}, ;
    {'640261','999911','��� ��� N 19','��� ��� N 19','',0d20251231}, ;
    {'640680','999914','��� �� "������������� ��"','��� �� "������������� ��"','',0d20251231}, ;
    {'640040','999916','��� �� ��ᯨ⠫� ��� ���࠭��','��� �� ��ᯨ⠫� ��� ���࠭��','',0d20251231}, ;
    {'050081','999995','�����⠭ ��� �� "������᪠� 業�ࠫ쭠� ࠩ����� ���쭨�"','�����⠭ ��� �� "������᪠� 業�ࠫ쭠� ࠩ����� ���쭨�"','368870, ���㡫��� �����⠭, ������, �.����饢�, 7',0d20251231}, ;
    {'750046','999992','���������᪨� �ࠩ ��� ��২�᪠� ���','���������᪨� �ࠩ ��� "��২�᪠� ���"','674600, ���������᪨� �ࠩ, �.����, �.������, 10',0d20251231}, ;
    {'080005','999994','����모� �� �� "������ࡥ⮢᪠� ࠩ����� ���쭨�"','����모� �� �� "������ࡥ⮢᪠� ࠩ����� ���쭨�"','359420, ���㡫��� ����모�,������ࡥ�⮢᪨� ࠩ��, �.���� ��ࡥ���, �. ���쭨筠� �.1',0d20251231}, ;
    {'430173','999920','������ "�����᪠� ���"','������ "�����᪠� ���"','',0d20251231}, ;
    {'610155','999926','���� "���" ��஧��᪮�� ࠩ��� ���⮢᪮� ������','���� "���" ��஧��᪮�� ࠩ��� ���⮢᪮� ������','',0d20251231}, ;
    {'610159','999925','���� "���" �����᪮�� ࠩ��� ���⮢᪮� ������','���� "���" �����᪮�� ࠩ��� ���⮢᪮� ������','',0d20251231}, ;
    {'610176','999929','���� "���" �����᪮�� ࠩ��� ���⮢᪮� ������','���� "���" �����᪮�� ࠩ��� ���⮢᪮� ������','',0d20251231}, ;
    {'300050','999910','�� ���� �� "�� ���� ��������"','�� ���� �� "�� ���� ��������"','',0d20251231}, ;
    {'640471','999993','���⮢᪠� ������� ��� �� "��த᪠� ����������� #1 ��������"','���⮢᪠� ������� ��� �� "��த᪠� ����������� N1 ��������"','413841, ���⮢᪠� �������, �.��������, �.����஢�,126',0d20251231}, ;
    {'780153','999923','��� ���� "���᪨� ��த᪮� �������䨫�� ������᪨� ᯥ樠����஢���� 業�� ��᮪�� ����樭᪨� �孮�����"','��� ���� "���᪨� ��த᪮� �������䨫�� ������᪨� ᯥ樠����஢���� 業��"','',0d20251231}, ;
    {'260061','999991','�⠢ய���᪨� �ࠩ ���� �� "��த᪠� ���쭨�" �.�����������','�⠢ய���᪨� �ࠩ ���� �� "��த᪠� ���쭨�" �. �����������','357108, �⠢ய���᪨� �ࠩ, �.�����������, 㫨� �������, 5, ��.0',0d20251231}, ;
    {'150112','999930','���� "������᪠� ���"','���� "������᪠� ���"','',0d20251231} ;
  }

  if G_Use(dir_server + sbase, dir_server + sbase, sbase, , .t.,)
    for i := 1 to len(aa)
      (sbase)->(dbappend())
      (sbase)->MCOD := aa[i,1]
      (sbase)->CODEM := aa[i,2]
      (sbase)->NAMEF := aa[i,3]
      (sbase)->NAMES := aa[i,4]
      (sbase)->ADRES := aa[i,5]
      // (sbase)->DEND := aa[i,6]
    next
    (sbase)->(dbCloseArea())
  endif

  return nil

****** 13.06.2021  ������ ���ᨢ _mo_dbb.dbb
function getMo_mo(nfile)
  local i, arr, arr1
  local ret_arr := {}

  arr1 := rest_arr(nfile)
  for i := 1 to len(arr1)
    arr := array(_MO_LEN_ARR)
    if !(valtype(arr1[i]) == 'A') .or. len(arr1[i]) < 12
      func_error(4,'�����襭 䠩� '+upper(nfile))
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
    if valtype(arr[_MO_UROVEN]) != 'A'
      arr[_MO_UROVEN] := {}
    endif
    aadd(ret_arr, aclone(arr))
  next

  return ret_arr

* 13.06.21 ������ ���ᨢ _mo_dbb.dbf
function getMo_mo_New(dbName, reload)
  // reload - 䫠� 㪠�뢠�騩 �� ��१���㧪� �ࠢ�筨��, .T. - ��१���㧨��, .F. - ���
  
  // _mo_mo.dbf - �ࠢ�筨� �����०�����
  //  1 - MCOD(C)  2 - CODEM(C)  3 - NAMEF(C)  4 - NAMES(C) 5 - ADRES(C) 6 - MAIN(C)
  //  7 - PFA(C) 8 - PFS(C) 9 - PROD(C) 10 - DOLG(C) 
  //  11 - DEND(D)  12 - STANDART(C)  13 - UROVEN(C)
  static _arr := {}
  // local dbName := '_mo_mo'
  local standart, uroven
  local row, tmp
  local sbase := 'mo_add'
  
  DEFAULT reload TO .f.
  
  if reload
    // ���⨬ ���ᨢ ��� ����� ����㧪� �ࠢ�筨��
    _arr := {}
  endif
  
  if len(_arr) == 0
    dbUseArea( .t.,, dir_exe + dbName, dbName, .f., .f. )
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

    if hb_FileExists(dir_server + sbase + sdbf)
      dbUseArea( .t.,, dir_server + sbase, sbase, .f., .f. )
      // dbUseArea( .t., , dbName, dbName, .f., .f. )
      (sbase)->(dbGoTop())
      do while !(sbase)->(EOF())

      aadd(_arr, { ;
              alltrim((sbase)->NAMES), ;
              alltrim((sbase)->CODEM), ;
              '', ;
              (sbase)->DEND, ;
              alltrim((sbase)->MCOD), ;
              alltrim((sbase)->NAMEF), ;
              {}, ; // �஢��� ������, � 2013 ���� 4 - �������㠫�� ����
              {}, ;
              '1', ;
              '0', ;
              '0', ;
              alltrim((sbase)->ADRES) ;
        } )
        (sbase)->(dbSkip())
      enddo
      (sbase)->(dbCloseArea())
      endif
  endif

  
  return _arr

