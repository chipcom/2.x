#include 'inkey.ch'
#include '..\function.ch'
#include 'common.ch'
#include '..\edit_spr.ch'
#include "..\chip_mo.ch"

#include 'tbox.ch'

* 21.01.21 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
function getf010()
    // F010.xml - Классификатор субъектов Российской Федерации
    //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)
    local dbName := "f010"
    local _f010 := {}

    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
        aadd(_f010, {(dbName)->SUBNAME,(dbName)->KOD_TF,Val((dbName)->OKRUG)})
        (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    aadd(_f010, {'Федерального подчинения', '99', 0})

    return _f010

* 20.01.21 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewF003( mkod, r, c, lusl, lpar )

    local nTop, nLeft, nBottom, nRight
    local tmp_select := select()
    local l := 0, fl
    Local ar, aStruct, dbName := 'F003', indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
    local oBox, oBoxRegion
    local strRegion := 'Выбор региона' 
    local lFileCreated := .f.
    local retMCOD := { '', space(10) }
    local ar_f010 := getf010()
    local selectedRegion := "34"

    DEFAULT lpar TO 1

    private nRegion := 34
    private tmpName := cur_dir + 'tmp_F003', tmpAlias := 'tF003'
    private oBoxCompany
    private fl_space := .f., fl_other_region := .f.
    private muslovie, ppar := lpar

    // уже было выбрано МО
    if valtype(mkod) == 'C' .and. !empty(mkod)
        selectedRegion := substr(mkod, 1, 2)
        nRegion := val(selectedRegion)
    endif
        
    ar := {}
    for i := 1 to len(ar_f010)
      aadd(ar, ar_f010[i,1])
      l := max(l,len(ar[i]))
    next

    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbName, .t., .f. )
    aStruct := (dbName)->(dbStruct())
    (dbName)->(dbCreateIndex( indexName, "substr(MCOD,1,2)", , NIL ))

    nTop := 4
    nLeft := 40 - l / 2
    nBottom := 9
    nRight := 40 + l / 2 + 1

    // окно выбора региона
    oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
    oBoxRegion:Caption := 'Регион'
    oBoxRegion:Frame := BORDER_SINGLE
    
    // окно полного наименования организации
    oBoxCompany := TBox():New( 19, 11, 21, 68 )
    oBoxCompany:Frame := BORDER_NONE
    oBoxCompany:Color := color5

    do while .t.
        // главное окно
        oBox := NIL // уничтожим окно
        if fl_other_region .and. selectedRegion != ''
            oBox := TBox():New( 2, 10, 11, 70 )
        else
            oBox := TBox():New( 2, 10, 22, 70 )
        endif
	    oBox:Color := color_say + ',' + color_get
	    oBox:Frame := BORDER_DOUBLE
        oBox:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
        oBox:Save := .t.

        if fl_other_region
            oBox:Caption := 'Выберите регион'
            oBox:View()
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
        endif
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
            (tmpAlias)->YEAR := (dbName)->YEAR
        
            (dbName)->(dbSkip())
        enddo
                
        oBox:Caption := 'Выбор направившей организации'
        oBox:View()
        dbCreateIndex( tmpName, "NAMEMOK", , NIL )

        (tmpAlias)->(dbGoTop())
        if valtype(mkod) == 'C' .and. !empty(mkod) .and. selectedRegion == SubStr(mcod,1,2)
            do while ! (tmpAlias)->(EOF())
                if (tmpAlias)->MCOD == mkod
                    exit
                endif
                (tmpAlias)->(dbSkip())
            enddo
        endif
        if valtype(mkod) == 'C' .and. !empty(mkod)
            retMCOD := { (tmpAlias)->MCOD, AllTrim((tmpAlias)->NAMEMOK) }
        endif
        if fl := Alpha_Browse(oBox:Top+1,oBox:Left+1,oBox:Bottom-5,oBox:Right-1,"ColumnF003",color0,,,,,,"ViewRecordF003","controlF003",,{"═","░","═","N/BG,W+/N,B/BG,BG+/B"} )
            retMCOD := { (tmpAlias)->MCOD, AllTrim((tmpAlias)->NAMEMOK) }
        endif
        if fl_space
            oBoxRegion := NIL
            oBoxCompany := nil
            oBox := nil
            retMCOD := { '', space(10) }
            exit
        endif
        if ! fl_other_region
            oBoxRegion := NIL
            oBoxCompany := nil
            oBox := nil
            exit
        else
            retMCOD := { '', space(10) }
        endif
        selectedRegion := ''
        (tmpAlias)->(dbCloseArea())
    enddo
    (tmpAlias)->(dbCloseArea())
    (dbName)->(dbCloseArea())
    select (tmp_select)
    return retMCOD

* 19.01.21
Function controlF003(nkey,oBrow)
    Local ret := -1, cCode, rec
    // if nKey == K_F2 .and. lmo3 == 0
    //   if (cCode := input_value(18,2,20,77,color1,;
    //                            "Введите код МО или обособленного подразделения, присвоенный ТФОМС",;
    //                            space(6),"999999")) != NIL .and. !empty(cCode)
    //     rec := rg->(recno())
    //     go top
    //     oBrow:gotop()
    //     Locate for rg->kodN == cCode .or. rg->kodF == cCode
    //     if !found()
    //       go top
    //       oBrow:gotop()
    //       goto (rec)
    //     endif
    //     ret := 0
    //   endif
    // if nKey == K_F2 .and. lmo3 == 0
    //   if (cCode := input_value(18,2,20,77,color1,;
    //                            "Введите код МО или обособленного подразделения, присвоенный ТФОМС",;
    //                            space(6),"999999")) != NIL .and. !empty(cCode)
    //     rec := rg->(recno())
    //     go top
    //     oBrow:gotop()
    //     Locate for rg->kodN == cCode .or. rg->kodF == cCode
    //     if !found()
    //       go top
    //       oBrow:gotop()
    //       goto (rec)
    //     endif
    //     ret := 0
    //   endif
    // elseif nKey == K_F3 .and. glob_task != X_263 .and. muslovie == NIL .and. ppar == 1
    if nKey == K_F3
      ret := 1
      fl_other_region := .t.
    //   p_mo := 1
    //   pkodN := rg->kodN
    //   lmo3 := iif(lmo3 == 0, 1, 0)
    //   if lmo3 == 1 .and. rg->mo3 != lmo3
    //     pkodN := ""
    //   endif
    elseif nKey == K_SPACE
        fl_space := .t.
        ret := 1
    endif
    return ret
    
***** 16.01.21
Function ColumnF003(oBrow)
    Local oColumn
    oColumn := TBColumnNew(center("Наименование",50), {|| left((tmpAlias)->NAMEMOK,50) })
    oBrow:addColumn(oColumn)
    if nRegion == 34
        status_key('^<Esc>^ - выход; ^<Enter>^ - выбор; ^<Пробел>^ - очистка поля; ^<F3>^ - все МО')
    else
        status_key('^<Esc>^ - выход; ^<Enter>^ - выбор; ^<Пробел>^ - очистка поля; ^<F3>^ - областные МО')
    endif
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

***** 21.01.21
Function getF003mo(mCode)
    // mCode - код МО по F003
    Local arr, dbName := 'F003', indexName := cur_dir + dbName + 'cod'
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

