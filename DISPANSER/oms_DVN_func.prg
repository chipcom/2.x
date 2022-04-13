#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 05.09.21
Function read_arr_DVN(lkod,is_all)
  Local arr, i, sk
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect

  Private mvar

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",,"TPERS") 
  endif

  arr := read_arr_DISPANS(lkod)
  DEFAULT is_all TO .t.
  for i := 1 to len(arr)
    if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
      do case
        case arr[i,1] == "VB" .and. valtype(arr[i,2]) == "N"
          m1veteran := arr[i,2]
        case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
          m1mobilbr := arr[i,2]
        case arr[i,1] == "1" .and. valtype(arr[i,2]) == "N"
          m1kurenie := arr[i,2]
        case arr[i,1] == "2" .and. valtype(arr[i,2]) == "N"
          m1riskalk := arr[i,2]
        case arr[i,1] == "3" .and. valtype(arr[i,2]) == "N"
          m1pod_alk := arr[i,2]
        case arr[i,1] == "3.1" .and. valtype(arr[i,2]) == "N"
          m1psih_na := arr[i,2]
        case arr[i,1] == "4" .and. valtype(arr[i,2]) == "N"
          m1fiz_akt := arr[i,2]
        case arr[i,1] == "5" .and. valtype(arr[i,2]) == "N"
          m1ner_pit := arr[i,2]
        case arr[i,1] == "6" .and. valtype(arr[i,2]) == "N"
          mWEIGHT := arr[i,2]
        case arr[i,1] == "7" .and. valtype(arr[i,2]) == "N"
          mHEIGHT := arr[i,2]
        case arr[i,1] == "8" .and. valtype(arr[i,2]) == "N"
          mOKR_TALII := arr[i,2]
        case arr[i,1] == "9" .and. valtype(arr[i,2]) == "N"
          mad1 := arr[i,2]
        case arr[i,1] == "10" .and. valtype(arr[i,2]) == "N"
          mad2 := arr[i,2]
        case arr[i,1] == "11" .and. valtype(arr[i,2]) == "N"
          m1addn := arr[i,2]
        case arr[i,1] == "12" .and. valtype(arr[i,2]) == "N"
          mholest := arr[i,2]
        case arr[i,1] == "13" .and. valtype(arr[i,2]) == "N"
          m1holestdn := arr[i,2]
        case arr[i,1] == "14" .and. valtype(arr[i,2]) == "N"
          mglukoza := arr[i,2]
        case arr[i,1] == "15" .and. valtype(arr[i,2]) == "N"
          m1glukozadn := arr[i,2]
        case arr[i,1] == "16" .and. valtype(arr[i,2]) == "N"
          mssr := arr[i,2]
        case is_all .and. eq_any(arr[i,1],"21","22","23","24","25") .and. ;
                             valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 7
          sk := right(arr[i,1],1)
          pole_diag := "mdiag"+sk
          pole_1pervich := "m1pervich"+sk
          pole_1stadia := "m1stadia"+sk
          pole_1dispans := "m1dispans"+sk
          pole_1dop := "m1dop"+sk
          pole_1usl := "m1usl"+sk
          pole_1san := "m1san"+sk
          pole_d_diag := "mddiag"+sk
          pole_d_dispans := "mddispans"+sk
          pole_dn_dispans := "mdndispans"+sk
          if valtype(arr[i,2,1]) == "C"
            &pole_diag := arr[i,2,1]
          endif
          if valtype(arr[i,2,2]) == "N"
            &pole_1pervich := arr[i,2,2]
          endif
          if valtype(arr[i,2,3]) == "N"
            &pole_1stadia := arr[i,2,3]
          endif
          if valtype(arr[i,2,4]) == "N"
            &pole_1dispans := arr[i,2,4]
          endif
          if valtype(arr[i,2,5]) == "N" .and. type(pole_1dop) == "N"
            &pole_1dop := arr[i,2,5]
          endif
          if valtype(arr[i,2,6]) == "N" .and. type(pole_1usl) == "N"
            &pole_1usl := arr[i,2,6]
          endif
          if valtype(arr[i,2,7]) == "N" .and. type(pole_1san) == "N"
            &pole_1san := arr[i,2,7]
          endif
          if len(arr[i,2]) >= 8 .and. valtype(arr[i,2,8]) == "D" .and. type(pole_d_diag) == "D"
            &pole_d_diag := arr[i,2,8]
          endif
          if len(arr[i,2]) >= 9 .and. valtype(arr[i,2,9]) == "D" .and. type(pole_d_dispans) == "D"
            &pole_d_dispans := arr[i,2,9]
          endif
          if len(arr[i,2]) >= 10 .and. valtype(arr[i,2,10]) == "D" .and. type(pole_dn_dispans) == "D"
            &pole_dn_dispans := arr[i,2,10]
          endif
        case is_all .and. arr[i,1] == "29" .and. valtype(arr[i,2]) == "A"
          arr_usl_otkaz := arr[i,2]
        case arr[i,1] == "30" .and. valtype(arr[i,2]) == "N"
          //m1GRUPPA := arr[i,2]
        case arr[i,1] == "31" .and. valtype(arr[i,2]) == "N"
          m1prof_ko := arr[i,2]
        case is_all .and. arr[i,1] == "40" .and. valtype(arr[i,2]) == "A"
          arr_otklon := arr[i,2]
        case arr[i,1] == "41" .and. valtype(arr[i,2]) == "N"
          m1ot_nasl1 := arr[i,2]
        case arr[i,1] == "42" .and. valtype(arr[i,2]) == "N"
          m1ot_nasl2 := arr[i,2]
        case arr[i,1] == "43" .and. valtype(arr[i,2]) == "N"
          m1ot_nasl3 := arr[i,2]
        case arr[i,1] == "44" .and. valtype(arr[i,2]) == "N"
          m1ot_nasl4 := arr[i,2]
        case arr[i,1] == "45" .and. valtype(arr[i,2]) == "N"
          m1dispans  := arr[i,2]
        case arr[i,1] == "46" .and. valtype(arr[i,2]) == "N"
          m1nazn_l   := arr[i,2]
        case arr[i,1] == "47"
          if valtype(arr[i,2]) == "N"
            m1dopo_na  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1dopo_na  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_dopo_na := TPERS->tab_nom
            endif
          endif
        case arr[i,1] == "48" .and. valtype(arr[i,2]) == "N"
          m1ssh_na   := arr[i,2]
        case arr[i,1] == "49" .and. valtype(arr[i,2]) == "N"
          m1spec_na  := arr[i,2]
        case arr[i,1] == "50"   // .and. valtype(arr[i,2]) == "N"
          if valtype(arr[i,2]) == "N"
            m1sank_na  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1sank_na  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_sanat := TPERS->tab_nom
            endif
          endif
        case arr[i,1] == "51" .and. valtype(arr[i,2]) == "N"
          m1p_otk  := arr[i,2]
        case arr[i,1] == "52"
          if valtype(arr[i,2]) == "N"
            m1napr_v_mo  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_v_mo  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_mo := TPERS->tab_nom
            endif
          endif
        case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
          arr_mo_spec := arr[i,2]
        case arr[i,1] == "54"
          if valtype(arr[i,2]) == "N"
            m1napr_stac := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_stac := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_stac := TPERS->tab_nom
            endif
          endif
        case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
          m1profil_stac := arr[i,2]
        case arr[i,1] == "56"
          if valtype(arr[i,2]) == "N"
            m1napr_reab := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_reab := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_reab := TPERS->tab_nom
            endif
          endif
        case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
          m1profil_kojki := arr[i,2]
      endcase
    endif
  next

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  return NIL

***** 05.09.21
Function save_arr_DVN(lkod)
  Local arr := {}, i, sk, ta
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","TPERS") 
  endif

  if type("mfio") == "C"
    aadd(arr,{"mfio",alltrim(mfio)})
  endif
  if type("mdate_r") == "D"
    aadd(arr,{"mdate_r",mdate_r})
  endif
  aadd(arr,{ "VB",m1veteran})  // "N",ветеран ВОВ (блокадник)
  aadd(arr,{ "0",m1mobilbr})   // "N",мобильная бригада
  aadd(arr,{ "1",m1kurenie})   // "N",Курение
  aadd(arr,{ "2",m1riskalk})   // "N",Алкоголь
  aadd(arr,{ "3",m1pod_alk})   // "N",наркотики
  aadd(arr,{ "3.1",m1psih_na})   // "N",        направлен к психиатру-наркологу
  aadd(arr,{ "4",m1fiz_akt})   // "N",Низкая физическая активность
  aadd(arr,{ "5",m1ner_pit})   // "N",Нерациональное питание
  aadd(arr,{ "6",mWEIGHT})     // "N",Вес
  aadd(arr,{ "7",mHEIGHT})     // "N",рост
  aadd(arr,{ "8",mOKR_TALII})  // "N",окружность талии
  aadd(arr,{ "9",mad1})        // "N",Артериальное давление
  aadd(arr,{"10",mad2})        // "N",Артериальное давление
  aadd(arr,{"11",m1addn})      // "N",Гипотензивная терапия
  aadd(arr,{"12",mholest})     // "N",Общий холестерин
  aadd(arr,{"13",m1holestdn})  // "N",Гиполипидемическая терапия
  aadd(arr,{"14",mglukoza})    // "N",Глюкоза
  aadd(arr,{"15",m1glukozadn}) // "N",Гипогликемическая терапия
  aadd(arr,{"16",mssr})        // "N",Суммарный сердечно-сосудистый риск
  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_1pervich := "m1pervich"+sk
    pole_1stadia := "m1stadia"+sk
    pole_1dispans := "m1dispans"+sk
    pole_1dop := "m1dop"+sk
    pole_1usl := "m1usl"+sk
    pole_1san := "m1san"+sk
    pole_d_diag := "mddiag"+sk
    pole_d_dispans := "mddispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    if !empty(&pole_diag)
      ta := {&pole_diag,;
             &pole_1pervich,;
             &pole_1stadia,;
             &pole_1dispans}
      if type(pole_1dop)=="N" .and. type(pole_1usl)=="N" .and. type(pole_1san)=="N"
        aadd(ta, &pole_1dop)
        aadd(ta, &pole_1usl)
        aadd(ta, &pole_1san)
      else
        aadd(ta,0)
        aadd(ta,0)
        aadd(ta,0)
      endif
      if type(pole_d_diag)=="D" .and. type(pole_d_dispans)=="D"
        aadd(ta, &pole_d_diag)
        aadd(ta, &pole_d_dispans)
      else
        aadd(ta,ctod(""))
        aadd(ta,ctod(""))
      endif
      if type(pole_dn_dispans)=="D"
        aadd(ta, &pole_dn_dispans)
      else
        aadd(ta,ctod(""))
      endif
      aadd(arr,{lstr(20+i),ta})
    endif
  next i
  if !empty(arr_usl_otkaz)
    aadd(arr,{"29",arr_usl_otkaz}) // массив
  endif
  aadd(arr,{"30",m1GRUPPA})    // "N1",группа здоровья после дисп-ии
  if type("m1prof_ko") == "N"
    aadd(arr,{"31",m1prof_ko})    // "N1",вид проф.консультирования
  endif
  // if type("m1ot_nasl1") == "N"
    aadd(arr,{"40",arr_otklon}) // массив
    aadd(arr,{"41",m1ot_nasl1})
    aadd(arr,{"42",m1ot_nasl2})
    aadd(arr,{"43",m1ot_nasl3})
    aadd(arr,{"44",m1ot_nasl4})
    aadd(arr,{"45",m1dispans})
    aadd(arr,{"46",m1nazn_l})
    if mk_data >= 0d20210801
      if mtab_v_dopo_na != 0
        if TPERS->(dbSeek(str(mtab_v_dopo_na,5)))
          aadd(arr,{"47",{m1dopo_na, TPERS->kod}})
        else
          aadd(arr,{"47",{m1dopo_na, 0}})
        endif
      else
        aadd(arr,{"47",{m1dopo_na, 0}})
      endif
    else
      aadd(arr,{"47",m1dopo_na})
    endif
    aadd(arr,{"48",m1ssh_na})
    aadd(arr,{"49",m1spec_na})
    if mk_data >= 0d20210801
      if mtab_v_sanat != 0
        if TPERS->(dbSeek(str(mtab_v_sanat,5)))
          aadd(arr,{"50",{m1sank_na, TPERS->kod}})
        else
          aadd(arr,{"50",{m1sank_na, 0}})
        endif
      else
        aadd(arr,{"50",{m1sank_na, 0}})
      endif
    else
      aadd(arr,{"50",m1sank_na})
    endif
  // endif
  if type("m1p_otk") == "N"
    aadd(arr,{"51",m1p_otk})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_v_mo") == "N"
      if mtab_v_mo != 0
        if TPERS->(dbSeek(str(mtab_v_mo,5)))
          aadd(arr,{"52",{m1napr_v_mo, TPERS->kod}})
        else
          aadd(arr,{"52",{m1napr_v_mo, 0}})
        endif
      else
        aadd(arr,{"52",{m1napr_v_mo, 0}})
      endif
    endif
  else
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",m1napr_v_mo})
    endif
  endif
  if type("arr_mo_spec") == "A"   // .and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // массив
  endif
  if mk_data >= 0d20210801
    if type("m1napr_stac") == "N"
      if mtab_v_stac != 0
        if TPERS->(dbSeek(str(mtab_v_stac,5)))
          aadd(arr,{"54",{m1napr_stac, TPERS->kod}})
        else
          aadd(arr,{"54",{m1napr_stac, 0}})
        endif
      else
        aadd(arr,{"54",{m1napr_stac, 0}})
      endif
    endif
  else
    if type("m1napr_stac") == "N"
      aadd(arr,{"54",m1napr_stac})
    endif
  endif
  if type("m1profil_stac") == "N"
    aadd(arr,{"55",m1profil_stac})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_reab") == "N"
      if mtab_v_reab != 0
        if TPERS->(dbSeek(str(mtab_v_reab,5)))
          aadd(arr,{"56",{m1napr_reab, TPERS->kod}})
        else
          aadd(arr,{"56",{m1napr_reab, 0}})
        endif
      else
        aadd(arr,{"56",{m1napr_reab, 0}})
      endif
    endif
  else
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",m1napr_reab})
    endif
  endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  save_arr_DISPANS(lkod,arr)
  return NIL
  
***** 01.02.17
Function fget_spec_DVN(k,r,c,a_spec)
  Static as := {;
    {8,2},;
    {255,1},;
    {112,1},;
    {58,1},;
    {65,1},;
    {113,1},;
    {133,1},;
    {257,1},;
    {114,1},;
    {258,1},;
    {115,1},;
    {66,1},;
    {116,1},;
    {10,1},;
    {32,1},;
    {260,1},;
    {118,1},;
    {139,2},;
    {59,1},;
    {67,1},;
    {120,1},;
    {134,1},;
    {14,2},;
    {140,1},;
    {261,1},;
    {123,1},;
    {17,1},;
    {19,2},;
    {20,2},;
    {23,1},;
    {262,1},;
    {125,1},;
    {138,1},;
    {263,1},;
    {126,1},;
    {141,1},;
    {75,1},;
    {28,1},;
    {145,2},;
    {29,1},;
    {30,2},;
    {31,1},;
    {97,1};
  }
  Local tmp_select := select(), s, blk, t_arr[BR_LEN], n_file := cur_dir+"tmpspecdvn"
  
  if !hb_fileExists(n_file+sdbf)
    dbcreate(n_file,{{"name","C",30,0},;
                     {"kod","C",4,0},;
                     {"kod_up","C",4,0},;
                     {"name1","C",50,0},;
                     {"isn","N",1,0},;
                     {"is","L",1,0}})
    use (n_file) new alias SDVN
    use (cur_dir+"tmp_v015") index (cur_dir+"tmpkV015") new alias tmp_ga
    go top
    do while !eof()
      if (i := ascan(as,{|x| lstr(x[1]) == rtrim(tmp_ga->kod)})) > 0
        select SDVN
        append blank
        sdvn->name := afteratnum(".",tmp_ga->name,1)
        sdvn->kod := tmp_ga->kod
        sdvn->isn := as[i,2]
        s := ""
        select TMP_GA
        rec := recno()
        do while !empty(tmp_ga->kod_up)
          find (tmp_ga->kod_up)
          if found()
            s += alltrim(afteratnum(".",tmp_ga->name,1))+"/"
          else
            exit
          endif
        enddo
        goto (rec)
        sdvn->name1 := s
      endif
      skip
    enddo
    sdvn->(dbCloseArea())
    tmp_ga->(dbCloseArea())
  endif
  use (n_file) new alias tmp_ga
  do while !eof()
    tmp_ga->is := (ascan(a_spec,int(val(tmp_ga->kod))) > 0)
    skip
  enddo
  if metap == 3
    index on upper(name)+kod to (n_file)
  else
    index on upper(name)+kod to (n_file) for isn == 1
  endif
  if r <= maxrow()/2
    t_arr[BR_TOP] := r+1
    t_arr[BR_BOTTOM] := maxrow()-2
  else
    t_arr[BR_BOTTOM] := r-1
    t_arr[BR_TOP] := 2
  endif
  blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.}
  t_arr[BR_COLUMN] := {;
    { " ", {|| iif(tmp_ga->is,""," ") }, blk },;
    { "Код", {|| left(tmp_ga->kod,3) },blk },;
    { center("Медицинская специальность",26), {|| padr(tmp_ga->name,26) },blk },;
    { center("подчинение",45), {|| left(tmp_ga->name1,45) },blk };
  }
  t_arr[BR_EDIT] := {|nk,ob| f1get_spec_DVN(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности") }
  go top
  edit_browse(t_arr)
  s := ""
  asize(a_spec,0)
  go top
  do while !eof()
    if iif(metap == 3, .t., tmp_ga->isn==1) .and. tmp_ga->is
      s += alltrim(tmp_ga->kod)+","
      aadd(a_spec,int(val(tmp_ga->kod)))
    endif
    skip
  enddo
  if empty(s)
    s := "---"
  else
    s := left(s,len(s)-1)
  endif
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  return {1,s}
  
***** 11.11.17
Function f1get_spec_DVN(nKey,oBrow,regim)

  if regim == "edit" .and. nkey == K_INS
    tmp_ga->is := !tmp_ga->is
    keyboard chr(K_TAB)
  endif
  return 0
  
***** 19.06.19 рабочая ли услуга ДВН в зависимости от этапа, возраста и пола
Function f_is_usl_oms_sluch_DVN(i,_etap,_vozrast,_pol,/*@*/_diag,/*@*/_otkaz,/*@*/_ekg)
  Local fl := .f., ars := {}, ar := dvn_arr_usl[i]
  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  _diag := (ar[4] == 1)
  _otkaz := 0
  _ekg := .f.
  if valtype(ar[2]) == "C"
    aadd(ars,ar[2])
  else
    ars := aclone(ar[2])
  endif
  if eq_any(_etap,1,3) .and. ar[5] == 1 .and. ascan(ars,"4.20.1") == 0
    _otkaz := 1 // можно ввести отказ
    if valtype(ar[2]) == "C" .and. eq_ascan(ars,"7.57.3","7.61.3","4.1.12")
      _otkaz := 2 // можно ввести невозможность
      if ascan(ars,"4.1.12") > 0 // взятие мазка
        _otkaz := 3 // заменить на приём фельдшера-акушера
      endif
    endif
  endif
  if fl .and. eq_any(_etap,1,4,5)
    if _etap == 1
      i := iif(_pol == "М", 6, 7)
    elseif len(ar) < 14
      return .f.
    else
      i := iif(_pol == "М", 13, 14)
    endif
    if valtype(ar[i]) == "N" // специально для услуги "Электрокардиография","13.1.1" ранее 18 года
      fl := (ar[i] != 0)
      if ar[i] < 0  // ЭКГ
        _ekg := (_vozrast < abs(ar[i])) // необязательный возраст
      endif
    else // для 1,4,5 этапа возраст указан массивом
      fl := ascan(ar[i],_vozrast) > 0
    endif
  endif
  if fl .and. eq_any(_etap,2,3)
    i := iif(_pol=="М", 8, 9)
    if valtype(ar[i]) == "N"
      fl := (ar[i] != 0)
    elseif type("is_disp_19") == "L" .and. is_disp_19
      fl := ascan(ar[i],_vozrast) > 0
    else // для 2 этапа и профилактики возраст указан диапазоном
      fl := between(_vozrast,ar[i,1],ar[i,2])
    endif
  endif
  return fl
  
  