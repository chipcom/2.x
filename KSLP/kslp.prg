#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

#include "tbox.ch"

function kslp(k,r,c,dateSl,DOB)
  // k - значение m1.....
  // r - строка экрана
  // c - колонка экрана
  // dateSl - дата случая
  // DOB - дата рождения пациента
  Local mlen, t_mas := {}, ret, ;
    i, tmp_color := setcolor(),;
    tmp_select := select(), a_uch := {}
  Local r1 := 0 // счетчик записей в файле
  Local strArr := '', age

  Local m1var := '', s := "", countKSLP := 0
  Local dbName, dbAlias := 'KSLP_'
  local oBox

  default DOB to sys_date
  default dateSl to sys_date

  age := count_years(DOB, dateSl)

  if year(dateSl) == 2021 // КСЛП на 2021 год
    dbName := '_mo1kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      r1++
      if SubStr(k,r1,1) == '1'
        strArr := ' * '
      else
        strArr := '   '
      endif
      if (dbAlias)->CODE == 1
        if (age >= 75)
          strArr := ' * '
        else
          strArr := '   '
        endif
        strArr += (dbAlias)->NAME
        aadd(t_mas, { strArr, .f.})
      elseif (dbAlias)->CODE == 3
        if (age < 18)
          strArr += (dbAlias)->NAME
          aadd(t_mas, { strArr, .t.})
        else
          strArr := '   '
          strArr += (dbAlias)->NAME
          aadd(t_mas, { strArr, .f.})
        endif
      else
        strArr += (dbAlias)->NAME
        aadd(t_mas, { strArr, .t.})
      endif
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
  else
    alertx('На указанную дату случая ' + DToC(dateSl) + ' КСЛП отсутствуют!')
  endif

  strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'

  mlen := len(t_mas)

  // используем popupN из библиотеки FunLib
  if (ret := popupN(5,14,15,67,t_mas,i,color0,.t.,"fmenu_readerN",,;
      "Отметьте КСЛП",col_tit_popup,,strStatus)) > 0
    for i := 1 to mlen
      if "*" == substr(t_mas[i, 1],2,1)
        // k := chr(int(val(right(t_mas[i],10))))
        // m1var += k
        m1var += '1'
        countKSLP += 1
      else
        m1var += '0'
      endif
    next
    // s := "= "+lstr(len(m1var))+"кслп. ="
    s := "= "+alltrim(str(countKSLP))+"кслп. ="
  endif

  Select(tmp_select)
  // alertx(age)
  // alertx(dateSl)
  // alertx(m1var)

  Return iif(ret==0, NIL, {m1var,s})
