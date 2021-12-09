#include 'inkey.ch'
#include 'function.ch'
#include 'common.ch'
#include 'edit_spr.ch'
#include "chip_mo.ch"

#include 'tbox.ch'

* 20.01.21 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewF003()

  local nTop, nLeft, nBottom, nRight
  local tmp_select := select()
  local l := 0, fl
  Local ar, aStruct, dbName := '_mo_f003', indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
  local oBox, oBoxRegion
  local strRegion := 'Выбор региона' 
  local lFileCreated := .f.
  local retMCOD := { '', space(10) }
  local ar_f010 := getf010()
  local selectedRegion := "34"
  local sbase := 'mo_add'
  local prev_codem := 0, cur_codem := 0

  private nRegion := 34
  private tmpName := cur_dir + 'tmp_F003', tmpAlias := 'tF003'
  private oBoxCompany
  private fl_space := .f., fl_other_region := .f.

  ar := {}
  for i := 1 to len(ar_f010)
    aadd(ar, ar_f010[i,1])
    l := max(l,len(ar[i]))
  next

  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbName, .t., .f. )
  aStruct := (dbName)->(dbStruct())
  (dbName)->(dbCreateIndex( indexName, "substr(MCOD,1,2)", , NIL ))

  nTop := 4
  nLeft := 3
  nBottom := 23
  nRight := 77

  // окно выбора региона
  oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
  oBoxRegion:Caption := 'Выберите регион'
  oBoxRegion:Frame := BORDER_SINGLE
    
  // окно полного наименования организации
  oBoxCompany := TBox():New( 19, 11, 21, 68 )
  oBoxCompany:Frame := BORDER_NONE
  oBoxCompany:Color := color5

  // главное окно
  oBox := NIL // уничтожим окно
  oBox := TBox():New( 2, 10, 22, 70 )
	oBox:Color := color_say + ',' + color_get
	oBox:Frame := BORDER_DOUBLE
  oBox:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBox:Save := .t.

  oBoxRegion:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBoxRegion:Save := .t.
  oBoxRegion:View()
  nRegion := AChoice( oBoxRegion:Top+1, oBoxRegion:Left+1, oBoxRegion:Bottom-1, oBoxRegion:Right-1, ar, , , 34 )
  if nRegion == 0
    (dbName)->(dbCloseArea())
    (tmpAlias)->(dbCloseArea())
    select (tmp_select)
    return retMCOD
  else
    selectedRegion  := ar_f010[nRegion,2]
  endif
  fl_other_region := .f.

  // создадим временный файл для отбора организаций выбранного региона
  dbCreate(tmpName, aStruct)
  dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )
        
  (dbName)->(dbGoTop())
  (dbName)->(dbSeek(selectedRegion))
  do while substr((dbName)->MCOD,1,2) == selectedRegion
    (tmpAlias)->(dbAppend())
    (tmpAlias)->MCOD := (dbName)->MCOD
    (tmpAlias)->NAMEMOK := (dbName)->NAMEMOK
    (tmpAlias)->NAMEMOP := (dbName)->NAMEMOP
    (tmpAlias)->ADDRESS := (dbName)->ADDRESS
    (tmpAlias)->YEAR := (dbName)->YEAR
        
    (dbName)->(dbSkip())
  enddo
                
  oBox:Caption := 'Выбор направившей организации'
  oBox:View()
  dbCreateIndex( tmpName, "NAMEMOK", , NIL )

  (tmpAlias)->(dbGoTop())
  if fl := Alpha_Browse(oBox:Top+1,oBox:Left+1,oBox:Bottom-5,oBox:Right-1,"ColumnF003",color0,,,,,,"ViewRecordF003","controlF003",,{"═","░","═","N/BG,W+/N,B/BG,BG+/B"} )
    // проверяем выбор
    if (ifi := hb_ascan(glob_arr_mo,{|x| x[_MO_KOD_FFOMS] == (tmpAlias)->MCOD },,,.t.) ) > 0
      // нашли в файле
      alert('Медицинское учреждение уже добавлено в справочник!')
    else
      if G_Use(dir_server + sbase, dir_server + sbase, sbase, , .t.,)
        (sbase)->(dbGoTop())
        do while ! (sbase)->(Eof())
          prev_codem := (sbase)->CODEM
          (sbase)->(dbSkip())
          cur_codem := (sbase)->CODEM
          if (val(cur_codem) - val(prev_codem)) != 1
            (sbase)->(dbappend())
            (sbase)->MCOD := (tmpAlias)->MCOD
            (sbase)->CODEM := str(val(prev_codem) + 1, 6)
            (sbase)->NAMEF := (tmpAlias)->NAMEMOK
            (sbase)->NAMES := (tmpAlias)->NAMEMOP
            (sbase)->ADRES := (tmpAlias)->ADDRESS
            (sbase)->DEND := hb_SToD('20251231')
            exit
          endif
        enddo
        (sbase)->(dbCloseArea())
        retMCOD := { str(val(prev_codem) + 1, 6), AllTrim((tmpAlias)->NAMEMOK) }
      endif
    endif
        
  endif
  selectedRegion := ''

  oBoxRegion := NIL
  oBoxCompany := nil
  oBox := nil
  (tmpAlias)->(dbCloseArea())
  (dbName)->(dbCloseArea())
  select (tmp_select)
  return retMCOD

* 15.10.21
Function controlF003(nkey,oBrow)
  Local ret := -1, cCode, rec

  return ret
    
***** 15.10.21
Function ColumnF003(oBrow)
  Local oColumn
  
  oColumn := TBColumnNew(center("Наименование",50), {|| left((tmpAlias)->NAMEMOK,50) })
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ - выход; ^<Enter>^ - выбор')
  return nil

***** 21.01.21
Function ViewRecordF003()
  Local i, arr := {}, count

  if ! oBoxCompany:Visible
    oBoxCompany:View()
  else
    oBoxCompany:Clear()
  endif
  // разобьем полное наменование на подстроки
  // perenos(arr,(tmpAlias)->NAMEMOP,50)
  perenos(arr, (tmpAlias)->NAMEMOP, oBoxCompany:Width)
  count := iif(len(arr) > oBoxCompany:Height, oBoxCompany:Height, len(arr))

  for i := 1 to count
    @ oBoxCompany:Top+i-1,oBoxCompany:Left+1 say arr[i]
  next
  
  return nil

***** 15.10.21
Function getF003mo(mCode)
  // mCode - код МО по F003
  Local arr, dbName := '_mo_f003', indexName := cur_dir + dbName + 'cod'
  local tmp_select := Select()
  Local i // возьмём первое по порядку МО

  if SubStr(mCode,1,2) != "34"

    arr := aclone(glob_arr_mo[1])
    if empty(mCode) .or. (Len(mCode) != 6)
      for i := 1 to len(arr)
        if valtype(arr[i]) == "C"
          arr[i] := space(6) // и очистим строковые элементы
        endif
      next
      Select(tmp_select)
      return arr
    endif

    arr := array(_MO_LEN_ARR)

    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbName, .t., .f. )
    (dbName)->(dbCreateIndex( indexName, "MCOD", , NIL ))

    (dbName)->(dbGoTop())
    if (dbName)->(dbSeek(mCode))
      arr[_MO_KOD_FFOMS]  := (dbName)->MCOD
      arr[_MO_KOD_TFOMS]  := ''
      arr[_MO_FULL_NAME]  := AllTrim((dbName)->NAMEMOP)
      arr[_MO_SHORT_NAME] := AllTrim((dbName)->NAMEMOK)
      arr[_MO_ADRES]      := AllTrim((dbName)->ADDRESS)
      arr[_MO_PROD]       := ''
      arr[_MO_DEND]       := ctod('01-01-2021')
      arr[_MO_STANDART]   := 1
      arr[_MO_UROVEN]     := 1
      arr[_MO_IS_MAIN]    := .t.
      arr[_MO_IS_UCH]     := .t.
      arr[_MO_IS_SMP]     := .t.
    endif
    (dbName)->(dbCloseArea())
  else
    arr := aclone(glob_arr_mo[1])
    for i := 1 to len(arr)
      if valtype(arr[i]) == "C"
        arr[i] := space(6) // и очистим строковые элементы
      endif
    next
    if !empty(mCode)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == mCode })) > 0
        arr := glob_arr_mo[i]
      elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == mCode })) > 0
        arr := glob_arr_mo[i]
      endif
    endif
  endif
  Select(tmp_select)
  return arr