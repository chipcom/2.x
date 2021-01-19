#include 'inkey.ch'
#include '..\function.ch'
#include 'common.ch'
#include '..\edit_spr.ch'

#include 'tbox.ch'

* 19.01.21 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
function getf010()
    // F010.xml - Классификатор субъектов Российской Федерации
    //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)
    local dbName := "f010"
    local _f010 := {}

    dbUseArea( .t.,, dir_server + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
        aadd(_f010, {(dbName)->SUBNAME,(dbName)->KOD_TF,Val((dbName)->OKRUG)})
        (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())

    return _f010

* 19.01.21
Function viewF003()
    local nTop, nLeft, nBottom, nRight
    local l := 0, fl
    Local ar, aStruct, dbName := "F003", indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
    local oBox, oBoxRegion
    local strRegion := "Выбор региона" 
    local lFileCreated := .f.
    local retMCOD := ''
    local ar_f010 := getf010()
    local selectedRegion := "34"

    private tmpName := cur_dir + "tmp_F003", tmpAlias := "tF003"
    private oBoxCompany
    private fl_space := .f., fl_other_region := .f.
    private nRegion := 34

    ar := {}
    for i := 1 to len(ar_f010)
      aadd(ar, ar_f010[i,1])
      l := max(l,len(ar[i]))
    next

    dbUseArea( .t.,, dir_server + dbName, dbName, .f., .f. )
    aStruct := (dbName)->(dbStruct())
    dbCreateIndex( indexName, "substr(MCOD,1,2)", , NIL )

    nTop := 4
    nLeft := 40 - l / 2
    nBottom := 9
    nRight := 40 + l / 2 + 1

    // окно выбора региона
    oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
    oBoxRegion:Caption := 'Регион'
    oBoxRegion:Frame := BORDER_SINGLE
    
    // окно полного наименования организации
    oBoxCompany := TBox():New( 19, 11, 21, 69 )
    oBoxCompany:Frame := BORDER_NONE
    oBoxCompany:Color := color5 // cDataCSay //color_say

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
        if fl := Alpha_Browse(oBox:Top+1,oBox:Left+1,oBox:Bottom-5,oBox:Right-1,"ColumnF003",color0,,,,,,"ViewRecordF003","drive_f003",,{"═","░","═","N/BG,W+/N,B/BG,BG+/B"} )
            retMCOD := (tmpAlias)->MCOD
        endif
        if ! fl_other_region
            oBoxRegion := NIL
            oBoxCompany := nil
            oBox := nil
            exit
        endif
        selectedRegion := ''
        (tmpAlias)->(dbCloseArea())
    enddo
    (tmpAlias)->(dbCloseArea())
    (dbName)->(dbCloseArea())
    return retMCOD

* 19.01.21
Function drive_f003(nkey,oBrow)
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
        AlertX("Press space")
        fl_space := .f.
        ret := 1
    endif
    return ret
    
***** 16.01.21
Function ColumnF003(oBrow)
    Local oColumn
    oColumn := TBColumnNew(center("Наименование",50), {|| left((tmpAlias)->NAMEMOK,50) })
    oBrow:addColumn(oColumn)
    if nRegion == 34
        status_key('^^ или нач.буква - просмотр; ^<Esc>^ - выход; ^<Enter>^ - выбор; ^<F3>^ - все МО')
    else
        status_key('^^ или нач.буква - просмотр; ^<Esc>^ - выход; ^<Enter>^ - выбор; ^<F3>^ - областные МО')
    endif
return nil

***** 17.01.21
Function ViewRecordF003()
    Local i, arr := {}

    oBoxCompany:View()
    // разобьем полное наменование на подстроки
    perenos(arr,(tmpAlias)->NAMEMOP,50)
    // oBoxCompany:Clear()
    for i := 1 to len(arr)
        @ oBoxCompany:Top+i-1,oBoxCompany:Left+1 say arr[i]// color color1
      next
  
    return nil

* 19.01.21
Function viewF003__()
    local nTop, nLeft, nBottom, nRight
    local l := 0, nRegion, fl
    Local ar, aStruct, dbName := "F003", indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
    local oBox, oBoxRegion
    local strRegion := "Выбор региона" 
    local lSelectedRegion := .f., lFileCreated := .f.
    local retMCOD := ''
    local ar_f010 := getf010()
    local selectedRegion := "34"

    private tmpName := cur_dir + "tmp_F003", tmpAlias := "tF003"
    private oBoxCompany

    ar := {}
    for i := 1 to len(ar_f010)
      aadd(ar, ar_f010[i,1])
      l := max(l,len(ar[i]))
    next

    nTop := 4
    nLeft := 40 - l / 2
    nBottom := 9
    nRight := 40 + l / 2 + 1

    // окно выбора региона
    oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
    oBoxRegion:Caption := 'Регион'
    oBoxRegion:Frame := BORDER_SINGLE
    
    // окно полного наименования организации
    oBoxCompany := TBox():New( 19, 11, 21, 69 )
    oBoxCompany:Frame := BORDER_NONE
    oBoxCompany:Color := color5 // cDataCSay //color_say

    do while .t.
        // главное окно
        oBox := NIL // уничтожим окно
        if lSelectedRegion
            oBox := TBox():New( 2, 10, 22, 70 )
        else
            oBox := TBox():New( 2, 10, 11, 70 )
        endif
	    oBox:Color := color_say + ',' + color_get
	    oBox:Frame := BORDER_DOUBLE
        oBox:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
        oBox:Save := .t.

        if ! lSelectedRegion
            oBox:Caption := 'Выберите регион'
            oBox:View()
            oBoxRegion:View()
            nRegion := AChoice( oBoxRegion:Top+1, oBoxRegion:Left+1, oBoxRegion:Bottom-1, oBoxRegion:Right-1, ar, , , 34 )
            if nRegion == 0
                (dbName)->(dbCloseArea())
                (tmpAlias)->(dbCloseArea())
                return retMCOD
            else
            // nRegion := selectedRegion   // добавил
                lSelectedRegion := .t.
                if ! lFileCreated
                    dbUseArea( .t.,, dir_server + dbName, dbName, .f., .f. )
                    dbCreateIndex( indexName, "substr(MCOD,1,2)", , NIL )
                    // создадим временный файл для отбора организаций выбранного региона
                    aStruct := (dbName)->(dbStruct())
                    dbCreate(tmpName, aStruct)
        
                    dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )
        
                    (dbName)->(dbGoTop())
                    // (dbName)->(dbSeek(str(nRegion,2)))
                    // do while substr((dbName)->MCOD,1,2) == str(nRegion,2)
                    (dbName)->(dbSeek(nRegion))
                    do while substr((dbName)->MCOD,1,2) == nRegion
                        (tmpAlias)->(dbAppend())
                        (tmpAlias)->MCOD := (dbName)->MCOD
                        (tmpAlias)->NAMEMOK := (dbName)->NAMEMOK
                        (tmpAlias)->NAMEMOP := (dbName)->NAMEMOP
                        (tmpAlias)->YEAR := (dbName)->YEAR
        
                        (dbName)->(dbSkip())
                    enddo
                    lFileCreated := .t.
                    (dbName)->(dbCloseArea())
                endif
                loop
            endif
        else
            if lFileCreated
                oBox:Caption := 'Выбор направившей организации'
                oBox:View()
                dbCreateIndex( tmpName, "NAMEMOK", , NIL )
                (tmpAlias)->(dbGoTop())
                if fl := Alpha_Browse(oBox:Top+1,oBox:Left+1,oBox:Bottom-5,oBox:Right-1,"ColumnF003",color0,,,,,,"ViewRecordF003",,,{"═","░","═","N/BG,W+/N,B/BG,BG+/B"} )
                    retMCOD := (tmpAlias)->MCOD
                endif
                oBoxRegion := NIL
                oBoxCompany := nil
                oBox := nil
                exit
            endif
        endif
    enddo
    (tmpAlias)->(dbCloseArea())
    return retMCOD
