#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

#include "tbox.ch"

function kslp(k,r,c)
    Local mlen, t_mas := {}, ret, ;
          i, tmp_color := setcolor(),;
          tmp_select := select(), r1, a_uch := {}

    Local m1var := '', s := "", countKSLP := 0
    local oBox
    // 1 ? Сложность лечения пациента, связанная с возрастом (лица 75 лет и старше) (в том числе, включая консультацию врача-гериатра);
    // 3 - Предоставление спального места и питания законному представителю (дети до 4 лет, дети старше 4 лет при наличии медицинских показаний);
    // 4 - Проведение первой иммунизации против респираторно-синцитиальной вирусной инфекции в период госпитализации по поводу лечения нарушений, возникающих в перинатальном периоде, являющихся показанием к иммунизации;
    // 5 - Развертывание индивидуального поста;
    // 6 - Проведение сочетанных хирургических вмешательств;
    // 7 - Проведение однотипных операций на парных органах;
    // 8 - Проведение антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами;
    // 9 - Наличие у пациента тяжелой сопутствующей патологии, осложнений заболеваний, сопутствующих заболеваний, влияющих на сложность лечения пациента (перечень указанных заболеваний и состояний;
    // 10 - Сверхдлительные сроки госпитализации, обусловленные медицинскими показаниями

    aadd(t_mas, { '   ' + ' 1-связанная с возрастом (лица 75 лет и старше) (в том числе, включая консультацию врача-гериатра)', .f. })
    aadd(t_mas, { '   ' + ' 3-Предоставление спального места и питания законному представителю (дети до 4 лет, дети старше 4 лет при наличии медицинских показаний)', .f. })
    aadd(t_mas, { '   ' + ' 4-Проведение первой иммунизации против респираторно-синцитиальной вирусной инфекции в период госпитализации по поводу лечения нарушений, возникающих в перинатальном периоде, являющихся показанием к иммунизации', .t. })
    aadd(t_mas, { '   ' + ' 5-Развертывание индивидуального поста', .t. })
    aadd(t_mas, { '   ' + ' 6-Проведение сочетанных хирургических вмешательств', .t. })
    aadd(t_mas, { '   ' + ' 7-Проведение однотипных операций на парных органах', .t. })
    aadd(t_mas, { '   ' + ' 8-Проведение антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами', .t. })
    aadd(t_mas, { '   ' + ' 9-Наличие у пациента тяжелой сопутствующей патологии, осложнений заболеваний, сопутствующих заболеваний, влияющих на сложность лечения пациента (перечень указанных заболеваний и состояний', .t. })
    aadd(t_mas, { '   ' + '10-Сверхдлительные сроки госпитализации, обусловленные медицинскими показаниями', .t. })

    status_key("^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - смена опции текущей альтернативы")

    mlen := len(t_mas)

    // oBox := TBox():New(4,18,16,63)
    // oBox:View()

    // используем popupN из библиотеки FunLib
    // if (ret := popupN(5,19,15,62,t_mas,i,color0,.t.,"fmenu_reader",,;
    if (ret := popupN(5,19,15,62,t_mas,i,color0,.t.,"fmenu_readerN",,;
        "Отметьте КСЛП",col_tit_popup,,,{.f.,.f.,.f.,.t.,.t.,.f.,.t.,.f.,.f.})) > 0
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
        alertx(countKSLP)
        s := "= "+alltrim(str(countKSLP))+"кслп. ="
    endif

    Select(tmp_select)

    @ 4, 10 say m1var picture '999999999999999'

Return iif(ret==0, NIL, {m1var,s})

Function inp_bit_otd__(k,r,c)
    Local mlen, t_mas := {}, buf := savescreen(), ret, ;
          i, tmp_color := setcolor(), m1var := "", s := "",;
          tmp_select := select(), r1, a_uch := {}
    mywait()
    R_Use(dir_server+"mo_uch",,"LPU")
    dbeval({|| iif(between_date(lpu->dbegin,lpu->dend,sys_date), ;
                   aadd(a_uch,lpu->(recno())), nil) })
    R_Use(dir_server+"mo_otd",,"OTD")
    set relation to kod_lpu into LPU
    dbeval({|| s := if(chr(recno()) $ k," * ","   ")+;
                    padr(otd->name,30)+" "+padr(lpu->short_name,5)+str(recno(),10),;
               aadd(t_mas,s);
           },;
           {|| between_date(otd->dbegin,otd->dend,sys_date) .and. ;
               ascan(a_uch,otd->kod_lpu) > 0 };
          )
    otd->(dbCloseArea())
    lpu->(dbCloseArea())
    if tmp_select > 0
      select(tmp_select)
    endif
    mlen := len(t_mas)
    asort(t_mas,,,{|x,y| if(substr(x,35,5) == substr(y,35,5), ;
                              (substr(x,4,30) < substr(y,4,30)), ;
                              (substr(x,35,5) < substr(y,35,5))) } )
    i := 1
    status_key("^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - смена опции текущей альтернативы")
    if (r1 := r-1-mlen-1) < 2
      r1 := 2
    endif
    if (ret := popup(r1,19,r-1,62,t_mas,i,color0,.t.,"fmenu_reader",,;
                     "В каких отделениях разрешается ввод услуги",col_tit_popup)) > 0
      for i := 1 to mlen
        if "*" == substr(t_mas[i],2,1)
          k := chr(int(val(right(t_mas[i],10))))
          m1var += k
        endif
      next
      s := "= "+lstr(len(m1var))+"отд. ="
    endif
    restscreen(buf)
    setcolor(tmp_color)
    Return iif(ret==0, NIL, {m1var,s})
    