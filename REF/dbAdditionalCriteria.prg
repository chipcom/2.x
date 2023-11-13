#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 26.09.23
function loadCriteria21(val_year)
  local fl, ar, ar1, ar2, i
  local retCriteria := {}, lSchema := .f.
  local tmp_select := select()
  local sbaseIt1 := prefixFileRefName(val_year) + 'it1'
  local aV024, it, sIt1code

  // исходный файл T006 21 года и выше
  if hb_FileExists(dir_exe + sbaseIt1 + sdbf)
    aV024 := getV024(val_year)

    tmp_select := select()

    R_Use(dir_exe + sbaseIt1, ,'IT1')
    ('IT1')->(dbGoTop())
    do while !('IT1')->(eof())
      lSchema := .f.
      ar := {}
      ar1 := {}
      ar2 := {}
      if !empty(it1->ds)
        ar := Slist2arr(it1->ds)
        for i := 1 to len(ar)
          ar[i] := padr(ar[i], 5)
        next
      endif
      if !empty(it1->ds1)
        ar1 := Slist2arr(it1->ds1)
        for i := 1 to len(ar1)
          ar1[i] := padr(ar1[i], 5)
        next
      endif
      if !empty(it1->ds2)
        ar2 := Slist2arr(it1->ds2)
        for i := 1 to len(ar2)
          ar2[i] := padr(ar2[i], 5)
        next
      endif
  
      sIt1code := alltrim(it1->CODE)
      if (it := ascan(aV024, {|x| alltrim(x[1]) == sIt1code})) > 0
        lSchema := .t.
      endif

      if lSchema
        aadd(retCriteria, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, alltrim(aV024[it, 2])})
      else
        aadd(retCriteria, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, ''})
      endif
      ('IT1')->(dbskip()) 
    enddo
    ('IT1')->(dbCloseArea())

    asort(retCriteria, , , {|x, y| x[2] < y[2] })
  else
    fl := notExistsFileNSI( dir_exe + sbaseIt1 + sdbf )
  endif
  Select(tmp_select)

  return retCriteria

// 30.10.22
// возвращает массив параметров дополнительного критерия
function getArrayCriteria(dateSl, codeCriteria)
  local tmpArrCriteria, row := {}
  local arr

  tmpArrCriteria := getAdditionalCriteria(dateSl)
  for each row in tmpArrCriteria
    if alltrim(row[2]) == alltrim(codeCriteria)
      arr := row
      exit
    endif
  next
return arr

// 07.02.22
// возвращает массив дополнительных критериев на указанную дату
function getAdditionalCriteria( dateSl )
  Local dbName, dbAlias := '_ADCRIT'
  local tmp_select := select()
  local retCriteria := {}
  local aCriteria, row
  local yearSl := year(dateSl)

  static hCriteria, lHashCriteria := .f.
  // при отсутствии ХЭШ-массива создадим его
  if !lHashCriteria
    hCriteria := hb_Hash()
    lHashCriteria := .t.
  endif

  // получим массив критериев из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hCriteria, yearSl )
    retCriteria := hb_HGet(hCriteria, yearSl)
  else
    if yearSl >= 2021
      // поместим в ХЭШ-массив
      aCriteria := loadCriteria21(yearSl)
      hCriteria[yearSl] := aCriteria
      retCriteria := aCriteria
    elseif yearSl == 2020
        // поместим в ХЭШ-массив
        aCriteria := loadCriteria20(yearSl)
        hCriteria[yearSl] := aCriteria
        retCriteria := aCriteria
      elseif yearSl == 2019
        // поместим в ХЭШ-массив
        aCriteria := loadCriteria19(yearSl)
        hCriteria[yearSl] := aCriteria
        retCriteria := aCriteria
      elseif yearSl == 2018
        // поместим в ХЭШ-массив
        aCriteria := loadCriteria18(yearSl)
        hCriteria[yearSl] := aCriteria
        retCriteria := aCriteria
      endif
  endif

  if empty(retCriteria)
    alertx('На дату ' + DToC(dateSl) + ' дополнительные критерии отсутствуют!')
  endif
  return retCriteria

// 04.02.23
function loadCriteria21_old(val_year)
  local fl, ar, ar1, ar2, i
  local retCriteria := {}, lSchema := .f.
  local tmp_select := select()
  local sbaseIt1 := prefixFileRefName(val_year) + 'it1'
  local sbaseShema := prefixFileRefName(val_year) + 'shema'

  // исходный файл T006 21 года и выше
  if hb_FileExists(dir_exe + sbaseIt1 + sdbf)
    tmp_select := select()
    R_Use(dir_exe + sbaseShema, , 'SCHEMA')
    index on KOD to tmpit memory  //(cur_dir + sbaseShema)

    R_Use(dir_exe + sbaseIt1, ,'IT1')
    ('IT1')->(dbGoTop())
    do while !('IT1')->(eof())
      lSchema := .f.
      ar := {}
      ar1 := {}
      ar2 := {}
      if !empty(it1->ds)
        ar := Slist2arr(it1->ds)
        for i := 1 to len(ar)
          ar[i] := padr(ar[i], 5)
        next
      endif
      if !empty(it1->ds1)
        ar1 := Slist2arr(it1->ds1)
        for i := 1 to len(ar1)
          ar1[i] := padr(ar1[i], 5)
        next
      endif
      if !empty(it1->ds2)
        ar2 := Slist2arr(it1->ds2)
        for i := 1 to len(ar2)
          ar2[i] := padr(ar2[i], 5)
        next
      endif
  
      ('SCHEMA')->(dbGoTop())
      if ('SCHEMA')->(dbSeek( padr(it1->CODE, 6) ))
        lSchema := .t.
      endif

      if lSchema
        aadd(retCriteria, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, alltrim(SCHEMA->NAME)})
      else
        aadd(retCriteria, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, ''})
      endif
      ('IT1')->(dbskip()) 
    enddo
    ('SCHEMA')->(dbCloseArea())
    ('IT1')->(dbCloseArea())

    asort(retCriteria, , , {|x, y| x[2] < y[2] })
  else
    fl := notExistsFileNSI( dir_exe + sbaseIt1 + sdbf )
  endif
  Select(tmp_select)

  return retCriteria

// 06.02.22
function loadCriteria20(val_year)
  local fl, ar, ar1, ar2, i
  local retCriteria := {}
  local tmp_select := select()
  local sbaseIt1 := prefixFileRefName(val_year) + 'it1'

  // исходный файл T006 20 года
  if hb_FileExists(dir_exe + sbaseIt1 + sdbf)
    tmp_select := select()
    R_Use(dir_exe + sbaseIt1, , 'IT1')
    ('IT1')->(dbGoTop())
    do while !('IT1')->(eof())
      ar := {}
      ar1 := {}
      ar2 := {}
      if !empty(it1->ds)
        ar := Slist2arr(it1->ds)
        for i := 1 to len(ar)
          ar[i] := padr(ar[i], 5)
        next
      endif
      if !empty(it1->ds1)
        ar1 := Slist2arr(it1->ds1)
        for i := 1 to len(ar1)
          ar1[i] := padr(ar1[i], 5)
        next
      endif
      if !empty(it1->ds2)
        ar2 := Slist2arr(it1->ds2)
        for i := 1 to len(ar2)
          ar2[i] := padr(ar2[i], 5)
        next
      endif
      aadd(retCriteria, {it1->USL_OK, padr(it1->CODE, 3), ar, ar1, ar2})
      ('IT1')->(dbskip()) 
    enddo
    ('IT1')->(dbCloseArea())
  else
    fl := notExistsFileNSI( dir_exe + sbaseIt1 + sdbf )
  endif
  Select(tmp_select)
  return retCriteria

// 06.02.22
function loadCriteria19(val_year)
  local retCriteria := {}
  local tmp_select := select()
  local sbaseIt := prefixFileRefName(val_year) + 'it'

  // исходный файл T006 19 года
  if hb_FileExists(dir_exe + sbaseIt + sdbf)
    tmp_select := select()
    R_Use(dir_exe + sbaseIt, ,'IT')
    index on ds to tmpit memory
    dbeval({|| aadd(retCriteria, {it->ds, it->it}) })
    ('IT')->(dbCloseArea())
  else
    fl := notExistsFileNSI( dir_exe + sbaseIt + sdbf )
  endif
  Select(tmp_select)
  return retCriteria

// 06.02.22
function loadCriteria18(val_year)
  local retCriteria := {}
  local tmp_select := select()
  local sbaseIt := prefixFileRefName(val_year) + 'it'

  // исходный файл T006 18 года
  if hb_FileExists(dir_exe + sbaseIt + sdbf)
    tmp_select := select()
    R_Use(dir_exe + sbaseIt, ,'IT')
    index on ds to tmpit memory
    dbeval({|| aadd(retCriteria, {it->ds, it->it}) })
    ('IT')->(dbCloseArea())
  else
    fl := notExistsFileNSI( dir_exe + sbaseIt + sdbf )
  endif
  Select(tmp_select)
  return retCriteria
