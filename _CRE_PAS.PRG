#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"

***** 22.02.19
proc main()
f_first()
n_reestr := 0
msmo := 34007
mgod := 0
mschet := space(15)
a1 := a2 := a3 := 0
cls
first_msg := "Процедура отката разных электронных документов в задаче CHIP_MO"
@ 1,1 say first_msg
mmenu := {"Откат реестра СП и ТК с удалением счетов",;
          "Откат реестра актов контроля",;
          "Откат счёта и создание XML-файла счёта",;
          "Удаление счёта и перевыставление случаев"}
if (par := popup_prompt(10,20,1,mmenu)) > 0
  do while .t.
    cls
    @ 1,1 say first_msg
    set cursor on
    if par == 1
      @ 10,10 say "Введите номер реестра" get n_reestr pict "999999"
    elseif par == 2
      @ 10,10 say "Введите имя файла - A(D)S(T)" get msmo pict "99999"
      @ row(),col() say "M999999_" get mgod pict "9999999"
    elseif eq_any(par,3,4)
      @ 10,10 say "Введите имя счёта (с буквой)" get mschet pict "@!"
    endif
    @ 12,10 say "Введите номер версии" get a1 pict "99"
    @ row(),col() say "," get a2 pict "99"
    @ row(),col() say "," get a3 pict "99"
    read
    if lastkey() == 27
      exit
    else
      if par == 1
        s := ltrim(str(n_reestr))
      elseif par == 2
        s := right(str(msmo),1)+ltrim(str(mgod))
      elseif eq_any(par,3,4)
        s := iif(par == 3, "", "1")
        s1 := substr(alltrim(mschet),3)
        for i := 1 to len(s1)
          c := substr(s1,i,1)
          if between(c,'0','9')
            s += c
          elseif between(c,'A','Z')
            s += lstr(asc(c))
          endif
        next
      endif
      s := charrem("0",s)+ltrim(str(a1))+ltrim(str(a2))+ltrim(str(a3*7,10,0))
      do while len(s) > 7
        s := left(s,len(s)-1)
      enddo
      n := ntoc(s,8)
      @ 14,10 say "Пароль: "+n
      wait
    endif
  enddo
endif
f_end()
return
