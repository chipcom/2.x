#include 'inkey.ch'
#include '..\function.ch'
#include 'common.ch'
#include '..\edit_spr.ch'

#include 'tbox.ch'

* 25.12.20 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
function f010()
    // F010.xml - Классификатор субъектов Российской Федерации
    //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)
    local _f010 := {}
    aadd(_f010, {"Республика Адыгея",1,2})
    aadd(_f010, {"Республика Башкортостан",2,7})
    aadd(_f010, {"Республика Бурятия",3,5})
    aadd(_f010, {"Республика Алтай",4,5})
    aadd(_f010, {"Республика Дагестан",5,8})
    aadd(_f010, {"Республика Ингушетия",6,8})
    aadd(_f010, {"Кабардино-Балкарская Республика",7,8})
    aadd(_f010, {"Республика Калмыкия",8,2})
    aadd(_f010, {"Карачаево-Черкесская Республика",9,8})
    aadd(_f010, {"Республика Карелия",10,3})
    aadd(_f010, {"Республика Коми",11,3})
    aadd(_f010, {"Республика Марий Эл",12,7})
    aadd(_f010, {"Республика Мордовия",13,7})
    aadd(_f010, {"Республика Саха (Якутия)",14,4})
    aadd(_f010, {"Республика Северная Осетия-Алания",15,8})
    aadd(_f010, {"Республика Татарстан",16,7})
    aadd(_f010, {"Республика Тыва",17,5})
    aadd(_f010, {"Удмуртская Республика",18,7})
    aadd(_f010, {"Республика Хакасия",19,5})
    aadd(_f010, {"Чеченская Республика",20,8})
    aadd(_f010, {"Чувашская Республика",21,7})
    aadd(_f010, {"Алтайский край",22,5})
    aadd(_f010, {"Краснодарский край",23,2})
    aadd(_f010, {"Красноярский край",24,5})
    aadd(_f010, {"Приморский край",25,4})
    aadd(_f010, {"Ставропольский край",26,8})
    aadd(_f010, {"Хабаровский край",27,4})
    aadd(_f010, {"Амурская область",28,4})
    aadd(_f010, {"Архангельская область",29,3})
    aadd(_f010, {"Астраханская область",30,2})
    aadd(_f010, {"Белгородская область",31,1})
    aadd(_f010, {"Брянская область",32,1})
    aadd(_f010, {"Владимирская область",33,1})
    aadd(_f010, {"Волгоградская область",34,2})
    aadd(_f010, {"Вологодская область",35,3})
    aadd(_f010, {"Воронежская область",36,1})
    aadd(_f010, {"Ивановская область",37,1})
    aadd(_f010, {"Иркутская область",38,5})
    aadd(_f010, {"Калининградская область",39,3})
    aadd(_f010, {"Калужская область",40,1})
    aadd(_f010, {"Камчатский край",41,4})
    aadd(_f010, {"Кемеровская область",42,5})
    aadd(_f010, {"Кировская область",43,7})
    aadd(_f010, {"Костромская область",44,1})
    aadd(_f010, {"Курганская область",45,6})
    aadd(_f010, {"Курская область",46,1})
    aadd(_f010, {"Ленинградская область",47,3})
    aadd(_f010, {"Липецкая область",48,1})
    aadd(_f010, {"Магаданская область",49,4})
    aadd(_f010, {"Московская область",50,1})
    aadd(_f010, {"Мурманская область",51,3})
    aadd(_f010, {"Нижегородская область",52,7})
    aadd(_f010, {"Новгородская область",53,3})
    aadd(_f010, {"Новосибирская область",54,5})
    aadd(_f010, {"Омская область",55,5})
    aadd(_f010, {"Оренбургская область",56,7})
    aadd(_f010, {"Орловская область",57,1})
    aadd(_f010, {"Пензенская область",58,7})
    aadd(_f010, {"Пермский край",59,7})
    aadd(_f010, {"Псковская область",60,3})
    aadd(_f010, {"Ростовская область",61,2})
    aadd(_f010, {"Рязанская область",62,1})
    aadd(_f010, {"Самарская область",63,7})
    aadd(_f010, {"Саратовская область",64,7})
    aadd(_f010, {"Сахалинская область",65,4})
    aadd(_f010, {"Свердловская область",66,6})
    aadd(_f010, {"Смоленская область",67,1})
    aadd(_f010, {"Тамбовская область",68,1})
    aadd(_f010, {"Тверская область",69,1})
    aadd(_f010, {"Томская область",70,5})
    aadd(_f010, {"Тульская область",71,1})
    aadd(_f010, {"Тюменская область",72,6})
    aadd(_f010, {"Ульяновская область",73,7})
    aadd(_f010, {"Челябинская область",74,6})
    aadd(_f010, {"Забайкальский край",75,5})
    aadd(_f010, {"Ярославская область",76,1})
    aadd(_f010, {"г. Москва",77,1})
    aadd(_f010, {"г. Санкт-Петербург",78,3})
    aadd(_f010, {"Еврейская АО",79,4})
    aadd(_f010, {"Ненецкий АО",80,3})
    aadd(_f010, {"Ханты-Мансийский АО",81,6})
    aadd(_f010, {"Чукотский АО",82,4})
    aadd(_f010, {"Ямало-Ненецкий АО",83,6})
    aadd(_f010, {"г. Байконур",84,0})
    aadd(_f010, {"Республика Крым",85,3})
    aadd(_f010, {"г. Севастополь",86,3})

    return _f010

* 17.01.21
Function viewF003()
    local nTop, nLeft, nBottom, nRight
    local l := 0, nRegion, fl
    Local ar, aStruct, dbName := "F003", indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
    local oBox, oBoxRegion
    local strRegion := "Выбор региона" 
    local lSelectedRegion := .f., lFileCreated := .f.
    local retMCOD := ''
    local ar_f010 := f010()

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
                lSelectedRegion := .t.
                if ! lFileCreated
                    dbUseArea( .t.,, dir_server + dbName, dbName, .f., .f. )
                    dbCreateIndex( indexName, "substr(MCOD,1,2)", , NIL )
                    // создадим временный файл для отбора организаций выбранного региона
                    aStruct := (dbName)->(dbStruct())
                    dbCreate(tmpName, aStruct)
        
                    dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )
        
                    (dbName)->(dbGoTop())
                    (dbName)->(dbSeek(str(nRegion,2)))
                    do while substr((dbName)->MCOD,1,2) == str(nRegion,2)
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

***** 16.01.21
Function ColumnF003(oBrow)
    Local oColumn
    oColumn := TBColumnNew(center("Наименование",50), {|| left((tmpAlias)->NAMEMOK,50) })
    oBrow:addColumn(oColumn)
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