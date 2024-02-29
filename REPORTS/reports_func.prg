#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

//
Function titleN_uch(arr_u,lsh,c_uch)
  Local i, t_arr[2], s := ""
  if !(type("count_uch")=="N")
    count_uch := iif(c_uch==NIL,1,c_uch)
  endif
  if count_uch > 1
    if count_uch == len(arr_u)
      add_string(center("[ по всем учреждениям ]",lsh))
    else
      aeval(arr_u, {|x| s += '"'+alltrim(x[2])+'", ' } )
      s := substr(s,1,len(s)-2)
      for i := 1 to perenos(t_arr,s,lsh)
        add_string(center(alltrim(t_arr[i]),lsh))
      next
    endif
  endif
  return NIL
  