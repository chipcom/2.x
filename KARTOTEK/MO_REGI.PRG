***** mo_regi.prg функции подзадачи "Регистратура"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_regist()
Static n_zapusk := 0
Local fl := .t.
if n_zapusk == 0
  ++n_zapusk
  regi_nastr(1)
endif
if copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
else
  fl := .f.
endif
return fl

*

*****
Function regi_stat(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"~Количество листов учета",;
                "~Список листов учета",;
                "~Новые пациенты"}
    mas_msg := {"Подсчет количества листов учета",;
                "Список зарегистрированных и распечатанных листов учета",;
                "Журнал регистрации новых пациентов"}
    mas_fun := {"regi_stat(1)",;
                "regi_stat(2)",;
                "regi_stat(3)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 1
    f1regi_stat()
  case k == 2
    f2regi_stat(1)
  case k == 3
    f2regi_stat(2)
endcase
if k > 0
  si1 := k
endif
return NIL

*

*****
Function f1regi_stat()
Local arr_g, sh, HH := 57, reg_print := 1, n_file := "reg1stat"+stxt,;
      buf := save_maxrow(), arr_otd := {}, arr_vp := {}, i, j1, j2,;
      arr_p := {}, arr_title, ssumma := 0
if (arr_g := year_month()) != NIL
  mywait()
  j1 := j2 := j3 := 0
  R_Use(dir_server+"mo_regi",dir_server+"mo_regi2","RU")
  dbseek(arr_g[7],.t.)
  do while ru->pdate <= arr_g[8]
    k := asc(ru->kod_p)
    if (i := ascan(arr_p, {|x| x[2] == k} )) == 0
      aadd(arr_p, {ru->uch,k,0,""} )
      i := len(arr_p)
    endif
    arr_p[i,3] ++
    j3 := 1
    if ru->tip == 1
      if (i := ascan(arr_otd, {|x| x[2] == ru->op} )) == 0
        aadd(arr_otd, {ru->uch,ru->op,0,""} )
        i := len(arr_otd)
      endif
      arr_otd[i,3] ++
      j1 := 1
    else
      if (i := ascan(arr_vp, {|x| x[1] == ru->uch .and. x[2] == ru->op} )) == 0
        aadd(arr_vp, {ru->uch,ru->op,0,""} )
        i := len(arr_vp)
      endif
      arr_vp[i,3] ++
      j2 := 1
    endif
    skip
  enddo
  close databases
  if emptyall(j1,j2,j3)
    func_error(4,"Нет информации!")
  else
    aeval(arr_otd, {|x,i| arr_otd[i,4] := ;
         alltrim(inieditspr(A__POPUPMENU,dir_server+"mo_otd",x[2]))+;
         " ("+alltrim(inieditspr(A__POPUPMENU,dir_server+"mo_uch",x[1]))+")" })
    asort(arr_otd,,,{|x,y| x[4] < y[4] } )
    //
    aeval(arr_vp, {|x,i| arr_vp[i,4] := ;
         alltrim(inieditspr(A__POPUPMENU,dir_server+"p_priem",x[2]))+;
         " ("+alltrim(inieditspr(A__POPUPMENU,dir_server+"mo_uch",x[1]))+")" })
    asort(arr_vp,,,{|x,y| x[4] < y[4] } )
    //
    R_Use(dir_server+"base1",,"BASE1")
    for i := 1 to len(arr_p)
      goto (arr_p[i,2])
      if !eof() .and. !empty(base1->p1)
        arr_p[i,4] := alltrim(crypt(base1->p1,gpasskod))
      endif
    next
    use
    asort(arr_p,,,{|x,y| upper(x[4]) < upper(y[4]) } )
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    arr_title := {;
"─────────────────────────────────────────────────────────┬──────",;
"                                                         │Кол-во",;
"─────────────────────────────────────────────────────────┴──────"}
    sh := len(arr_title[1])
    add_string("")
    add_string(center("Количество листов учета",sh))
    add_string(center(arr_g[4],sh))
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    if j1 > 0
      for i := 1 to len(arr_otd)
        if arr_otd[i,3] > 0
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(arr_otd[i,4],57)+str(arr_otd[i,3],7))
          ssumma += arr_otd[i,3]
        endif
      next
    endif
    add_string(replicate("─",sh))
    if j2 > 0
      for i := 1 to len(arr_vp)
        if arr_vp[i,3] > 0
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(arr_vp[i,4],57)+str(arr_vp[i,3],7))
          ssumma += arr_vp[i,3]
        endif
      next
    endif
    add_string(replicate("─",sh))
    if j3 > 0
      for i := 1 to len(arr_p)
        if arr_p[i,3] > 0
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(arr_p[i,4],57)+str(arr_p[i,3],7))
        endif
      next
    endif
    add_string(replicate("─",sh))
    add_string(padl("И Т О Г О : ",57)+str(ssumma,7))
    fclose(fp)
    viewtext(n_file,,,,(sh>80),,,reg_print)
  endif
  rest_box(buf)
endif
return NIL

*

*****
Function f2regi_stat(par)
Local arr_g, sh, HH := 58, reg_print := 2, n_file := "reg2stat"+stxt,;
      buf := save_maxrow(), i, j1, j2, arr_title, a_f[10], a_a[10], kf, ka,;
      nf, na, a_o[10], ko
if (arr_g := year_month()) != NIL
  mywait()
  j1 := 0
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  arr_title := {;
"──────────┬─────────────────────────┬──────────┬─────────────────────┬──────────────",;
"  Номер   │         Ф.И.О.          │   Дата   │        Адрес        │ Регистратор  ",;
"амб.карты │                         │ рождения │                     │              ",;
"──────────┴─────────────────────────┴──────────┴─────────────────────┴──────────────"}
  nf := 25 ; na := 21 ; no := 14
  sh := len(arr_title[1])
  add_string("")
  if par == 1
    add_string(center("Список зарегистрированных листов учета",sh))
  else
    add_string(center("Журнал регистрации новых больных",sh))
    R_Use(dir_server+"human",dir_server+"humankk","HU")
  endif
  add_string(center(arr_g[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  R_Use(dir_server+"base1",,"BASE1")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"mo_regi",dir_server+"mo_regi2","RU")
  set relation to kod_k into KART
  dbseek(arr_g[7],.t.)
  index on upper(kart->fio) to (cur_dir+"tmp_ru") while ru->pdate <= arr_g[8]
  go top
  do while !eof()
    fl := .t.
    if par == 2
      select HU
      find (str(ru->kod_k,7))
      fl := !found()
    endif
    if fl
      lnomer := amb_kartaN()
      kf := perenos(a_f,kart->fio,nf)
      ka := perenos(a_a,charone(" ",kart->adres),na)
      if ru->tip == 1
        ko := perenos(a_o,inieditspr(A__POPUPMENU,dir_server+"mo_otd",ru->op),no)
      else
        ko := perenos(a_o,inieditspr(A__POPUPMENU,dir_server+"p_priem",ru->op),no)
      endif
      s := padr(lnomer,10)+" "+;
           padr(a_f[1],nf)+" "+;
           full_date(kart->date_r)+" "+;
           padr(a_a[1],na)+" "
      if asc(ru->kod_p) > 0
        select BASE1
        goto (asc(ru->kod_p))
        if !eof() .and. !empty(base1->p1)
          s += alltrim(crypt(base1->p1,gpasskod))
        endif
      endif
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      ++j1
      add_string(s)
      for i := 2 to min(10,max(kf,ka,ko+1))
        add_string(space(11)+;
                   padr(a_f[i],nf)+" "+;
                   space(11)+;
                   padr(a_a[i],na)+" "+;
                   a_o[i-1])
      next
    endif
    select RU
    skip
  enddo
  close databases
  add_string(replicate("─",sh))
  add_string(padc("Итого: "+lstr(j1)+" человек",sh))
  fclose(fp)
  viewtext(n_file,,,,(sh>80),,,reg_print)
  rest_box(buf)
endif
return NIL

*

*****
Function edit_priem()
popup_edit(dir_server+"p_priem",T_ROW,T_COL-10,T_ROW+11,,1,,;
           "fdel_priem",,,,,,"Первичные приемы",col_tit_popup)
return NIL

*****
Function fdel_priem(mkod)
Local fl := .t., buf := save_maxrow()
stat_msg("Ждите! Производится проверка на допустимость удаления данного приема")
R_Use(dir_server+"mo_regi",,"RU")
Locate for ru->tip == 2 .and. ru->op == mkod progress
fl := !found()
Use
if !fl
  func_error(4,"Данный первичный прием встречается в других базах данных. Удаление запрещено!")
endif
rest_box(buf)
return fl

*

***** 14.04.15
Function regi_nastr(k)
Static cgreen := "G+/B"
Local buf := savescreen(), i, arr,;
      mm_lu_stt := {{"в виде ЛИСТА УЧЕТА",1},{"в виде СТАТ.ТАЛОНА",2}},;
      mm_op := {{"Отделение",1},{"Первичный врачебный прием",2}},;
      mm_regi_p := {{"Всегда регистрировать посещение",1},;
                    {"Запрос: регистрация / просто печать",2}},;
      mm_razmer := {{"формат A4",1},;
                    {"1/2 формата A4 (вертикально)",2},;
                    {"1/2 формата A4 (горизонтально)",3},;
                    {"ф.A4, отрывные талоны на платные услуги",5},;
                    {"Собственный шаблон",6}},;
      mm_razmt12 := {{"формат A4",1},;
                     {"1/2 формата A4 (горизонтально) (A5)",2}},;
      mm_025u := {{"медицинская амбулаторная карта в упрощённом текстовом виде",0},;
                  {"стр.1 формы 025/у на листе А5",1},;
                  {"стр.1,2 формы 025/у каждая на своей стороне листа А5",2},;
                  {"стр.1 формы 025/у на листе А4",3},;
                  {"стр.1,2 формы 025/у каждая на своей стороне листа А4",4},;
                  {"стр.1,2 формы 025/у на одной стороне листа А4 друг под другом",5},;
                  {"Ваш вариант графической формы 025/у",6}},;
      mm_025_1u := {{"стр.1,2 формы 025-1/у каждая на своей стороне листа А4",1},;
                    {"стр.1 формы 025-1/у на листе А4",2},;
                    {"Ваш вариант графической формы 025-1/у",6}},;
      mm_da_net := {{"да",1},{"нет",2}}, mm_6op, mm_6regi_p
mm_6op:= aclone(mm_op)
  Ins_Array(mm_6op,1,{"Ничего не печатать",0})
mm_6regi_p := aclone(mm_regi_p)
  Ins_Array(mm_6regi_p,1,{"Не регистрировать посещение",0})
Private is_talon := ret_is_talon()
//help_code := H_Edit_scroll
if k == 1
  Public mem_lu_stt := 1, ;
         mem_op     := 2,;
         mem_6op     := 0,;
         mem_fio_r  := 2,;
         mem_6fio_r  := 2,;
         mem_time   := 2,;
         mem_6time   := 2,;
         mem_razmer := 1,;
         mem_file5  := "SMY",;
         mem_t_025u := 0,;
         mem_razt12 := 1,;
         mem_2_lt12 := 2,;
         mem_2_l066 := 1,;
         mem_file4  := "LIST_066.SHB",;
         mem_file6  := "TALON12.SHB",;
         mem_file7  := "LIST_ULR.SHB",;
         mem_file8  := "LIST_U_8.SHB",;
         mem_file9  := "LIST_U_9.SHB",;
         mem_file9l := "",;
         mem_filg6  := "",;
         mem_filg8  := "",;
         mem_reg_lr := space(100),; // путь к регистру федеральных льготников
         mem_2_list := 1,;
         mem_posl_p := 1,;
         mem_regi_p := 1,;
         mem_regi6p := 0,;
         mem_fluor  := 2
  if hb_fileExists("memvar"+smem)
    restore from memvar additive
  else
    save all like mem_* to memvar
  endif
  if !is_talon
    mem_lu_stt := 1
  endif
  ***************
elseif k == 2
  ***************
  Private m1a_op    := mem_op, ma_op,;
          m1a_fio_r := mem_fio_r, ma_fio_r,;
          m1a_time  := mem_time, ma_time,;
          m1a_razmer:= mem_razmer, ma_razmer,;
          m1a_razmt12:= mem_razt12, ma_razmt12,;
          m1a_2_lt12:= mem_2_lt12, ma_2_lt12,;
          m1a_2_l066:= mem_2_l066, ma_2_l066,;
          m1a_t_025u := mem_t_025u, ma_t_025u,;
          mfile5    := padr(mem_file5, 3),;
          mfile4    := padr(mem_file4,12),;
          mfile6    := padr(mem_file6,12),;
          mgfile6   := padr(mem_filg6,8),;
          mfile7    := padr(mem_file7,12),;
          mfile8    := padr(mem_file8,12),;
          mgfile8   := padr(mem_filg8,8),;
          mfile9    := padr(mem_file9,12),;
          mfile9l   := padr(mem_file9l,12),;
          mreg_lr   := m1reg_lr := padr(mem_reg_lr,100),;
          m1a_2_list:= mem_2_list, ma_2_list,;
          m1a_posl_p:= mem_posl_p, ma_posl_p,;
          m1a_regi_p:= mem_regi_p, ma_regi_p,;
          m1a_6op    := mem_6op, ma_6op,;
          m1a_6fio_r := mem_6fio_r, ma_6fio_r,;
          m1a_6time  := mem_6time, ma_6time,;
          m1a_6regi_p:= mem_regi6p, ma_6regi_p,;
          m1a_fluor := mem_fluor, ma_fluor
  ma_op     := inieditspr(A__MENUVERT,mm_op,m1a_op)
  ma_fio_r  := inieditspr(A__MENUVERT,mm_da_net,m1a_fio_r)
  ma_time   := inieditspr(A__MENUVERT,mm_da_net,m1a_time)
  ma_razmer := inieditspr(A__MENUVERT,mm_razmer,m1a_razmer)
  ma_razmt12:= inieditspr(A__MENUVERT,mm_razmt12,m1a_razmt12)
  ma_2_list := inieditspr(A__MENUVERT,mm_da_net,m1a_2_list)
  ma_t_025u := inieditspr(A__MENUVERT,mm_025u,m1a_t_025u)
  ma_2_lt12 := inieditspr(A__MENUVERT,mm_025_1u,m1a_2_lt12)
  ma_2_l066 := inieditspr(A__MENUVERT,mm_da_net,m1a_2_l066)
  ma_posl_p := inieditspr(A__MENUVERT,mm_da_net,m1a_posl_p)
  ma_regi_p := inieditspr(A__MENUVERT,mm_regi_p,m1a_regi_p)
  ma_6op    := inieditspr(A__MENUVERT,mm_6op,m1a_6op)
  ma_6fio_r := inieditspr(A__MENUVERT,mm_da_net,m1a_6fio_r)
  ma_6time  := inieditspr(A__MENUVERT,mm_da_net,m1a_6time)
  ma_6regi_p:= inieditspr(A__MENUVERT,mm_6regi_p,m1a_6regi_p)
  ma_fluor  := inieditspr(A__MENUVERT,mm_da_net,m1a_fluor)
  if is_talon
    Private m1a_lu_stt := mem_lu_stt
    Private ma_lu_stt  := inieditspr(A__MENUVERT,mm_lu_stt,m1a_lu_stt)
  endif
  //
  pr_1_str("Редактирование настроек по умолчанию для регистратуры")
  setcolor(cDataCGet)
  myclear(1)
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись;  ^<F1>^ - помощь")
  init_VGET()
  j := 0
  ++j ; @ j,1 VSAY "Расширение для файлов шаблонов сокращенных листов учета (по <F5>)" VGET mfile5 pict "@!"
  ++j ; @ j,1 VSAY "Отображать данные по флюорографии больного?" VGET ma_fluor ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "Печать листа учета (<F9>):" color cgreen
  if is_talon
    ++j ; @ j,1 VSAY "- в каком виде печатать лист учета больного?" VGET ma_lu_stt ;
          reader {|x|menu_reader(x,mm_lu_stt,A__MENUVERT,,,.f.)}
  endif
  ++j ; @ j,1 VSAY "- что печатать в правом верхнем углу листа учета" VGET ma_op ;
        reader {|x|menu_reader(x,mm_op,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- печатать на листе учета ФИО регистратора?" VGET ma_fio_r ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- печатать на листе учета время выдачи?" VGET ma_time ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- на каком листе печать" VGET ma_razmer ;
        reader {|x|menu_reader(x,mm_razmer,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- наименование файла шаблона листа учета (по <F9>)" VGET mfile9 pict "@!"
  //++j ; @ j,1 VSAY "- файл шаблона листа учета (по <F9>) для федеральных льготников" VGET mfile9l pict "@!"
  ++j ; @ j,1 VSAY "- печатать оборотную сторону листа учета (стат.талона)?" VGET ma_2_list ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- выводить при распечатке листа учета дату последнего посещения?" VGET ma_posl_p ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- выводить или нет перед распечаткой листа учета запрос на регистрацию"
  ++j ; @ j,1 VSAY "  данного л/учета как посещения?" VGET ma_regi_p ;
        reader {|x|menu_reader(x,mm_regi_p,A__MENUVERT,,,.f.)}
  //
  ++j ; @ j,1 VSAY "Печать медицинской амбулаторной карты (<F8>):" color cgreen
  ++j ; @ j,1 VSAY "- наименование файла шаблона упрощённой амбулаторной карты" VGET mfile8 pict "@!"
  ++j ; @ j,1 VSAY "- в каком виде и на каком листе распечатывается медицинская амбулаторная"
  ++j ; @ j,1 VSAY "  карта?" VGET ma_t_025u ;
        reader {|x|menu_reader(x,mm_025u,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- наименование шаблона (.FR3) Вашей графической амбулаторной карты" VGET mgfile8 pict "@!" ;
        when m1a_t_025u == 6
  //
  ++j ; @ j,1 VSAY "Печать талона амбулаторного пациента №025-1/у (приказ №834н) (<F6>):" color cgreen
  ++j ; @ j,1 VSAY "- что печатать?" VGET ma_2_lt12 ;
        reader {|x|menu_reader(x,mm_025_1u,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- наименование шаблона (.FR3) Вашего графического талона амб.пациента" VGET mgfile6 pict "@!" ;
        when m1a_2_lt12 == 6
  ++j ; @ j,1 VSAY "- что запрашивать (печатать в определенном месте талона)" VGET ma_6op ;
        reader {|x|menu_reader(x,mm_6op,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- печатать на талона ФИО регистратора?" VGET ma_6fio_r ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- печатать на талона время выдачи?" VGET ma_6time ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 VSAY "- выводить или нет перед распечаткой талона запрос на регистрацию"
  ++j ; @ j,1 VSAY "  данного талона как посещения?" VGET ma_6regi_p ;
        reader {|x|menu_reader(x,mm_6regi_p,A__MENUVERT,,,.f.)}
  //
  ++j ; @ j,1 VSAY "Печать статистической карты выбывшего из стационара (приказ №413) (<F4>):" color cgreen
  ++j ; @ j,1 VSAY "- наименование файла шаблона стат.карты выбывшего из стационара" VGET mfile4 pict "@!"
  ++j ; @ j,1 VSAY "- печатать оборотную сторону стат.карты выбывшего из стационара?" VGET ma_2_l066 ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
  //++j ; @ j,1 VSAY "Печать листа учета льготных рецептов (<F7>):" color cgreen
  //++j ; @ j,1 VSAY "- наименование файла шаблона листа учета льготных рецептов" VGET mfile7 pict "@!"
  //++j
  //@ j,1 VSAY "- путь к регистру федеральных льготников (это файл с наименованием"
  //++j
  //@ j,1 VSAY "  R_MU.DBF)" VGET mreg_lr ;
  //      reader {|x| menu_reader(x,{{|k,r,c| mng_file(k,r,c,"LR_Registr",,"*.dbf") }},A__FUNCTION,,,.f.)}
  if scrollread(1,0,maxrow()-1,maxcol(),cDataCGet)
    mem_op      := m1a_op
    mem_fio_r   := m1a_fio_r
    mem_time    := m1a_time
    mem_razmer  := m1a_razmer
    mem_razt12  := m1a_razmt12
    mem_file4   := alltrim(mfile4)
    mem_file5   := alltrim(mfile5)
    mem_file6   := alltrim(mfile6)
    mem_filg6   := alltrim(mgfile6)
    mem_file7   := alltrim(mfile7)
    mem_file8   := alltrim(mfile8)
    mem_filg8   := alltrim(mgfile8)
    mem_file9   := alltrim(mfile9)
    mem_file9l  := alltrim(mfile9l)
    mem_reg_lr  := alltrim(mreg_lr)
    mem_2_list  := m1a_2_list
    mem_t_025u  := m1a_t_025u
    mem_2_lt12  := m1a_2_lt12
    mem_2_l066  := m1a_2_l066
    mem_posl_p  := m1a_posl_p
    mem_regi_p  := m1a_regi_p
    mem_6op     := m1a_6op
    mem_6fio_r  := m1a_6fio_r
    mem_6time   := m1a_6time
    mem_regi6p  := m1a_6regi_p
    mem_fluor   := m1a_fluor
    if is_talon
      mem_lu_stt := m1a_lu_stt
    endif
    save all like mem_* to memvar
    //if !empty(mem_reg_lr) .and. !("R_MU.DBF" $ upper(mem_reg_lr))
      //func_error(4,"Неверно выбран регистр федеральных льготников (должен быть файл R_MU.DBF)")
    //endif
    arr := {mem_file4,mem_file8,mem_file9}
    if m1a_t_025u == 6
      aadd(arr,mem_filg8+sfr3)
    endif
    if m1a_2_lt12 == 6
      aadd(arr,mem_filg6+sfr3)
    endif
    for i := 1 to len(arr)
      if !empty(arr[i]) .and. search_file(arr[i]) == NIL
        func_error(4,"Не обнаружен файл шаблона "+arr[i])
      endif
    next
  endif
  close databases
endif
help_code := -1
/*if !empty(mem_reg_lr) .and. "R_MU.DBF" $ upper(mem_reg_lr)
  is_r_mu := .t.
  sbase := mem_reg_lr
  sind1 := beforatnum(".",mem_reg_lr)
  sind2 := sind1+"f"
  sind1 += sntx
  sind2 += sntx
  fl := hb_fileExists(sind1)
  if fl  // пересоздать индекс, если обновили БД
    fl := files_time(sind1,sbase)
  endif
  if !fl
    if hb_fileExists(mem_reg_lr)
      use (sbase) new readonly
      index on ss to (sind1) progress
      index on upper(substr(fam,1,12)+substr(im,1,5)+substr(ot,1,3)) to (sind2) progress
      use
      // изменить дату и время создания файлов
      SetDateFile(sind1,mem_reg_lr,1)
      SetDateFile(sind2,mem_reg_lr,1)
    else
      func_error(4,"Не обнаружен файл "+mem_reg_lr+". Проверьте настройку!")
    endif
  endif
  sbase := beforatnum(cslash,mem_reg_lr)+cslash+"l_mu"
  sind1 := sbase+sntx
  sbase += sdbf
  G_Use(sbase,,,,,.t.)
  if is_field("c_kat")
    dlo_version := 4  // версия регистра
  else
    dlo_version := 3  // версия регистра
  endif
  Use
  fl := hb_fileExists(sind1)
  if fl  // пересоздать индекс, если обновили БД
    fl := files_time(sind1,sbase)
  endif
  if !fl
    if hb_fileExists(sbase)
      use (sbase) new readonly
      if is_field("c_kat")
        dlo_version := 4
        index on ss+c_kat to (sind1) progress
      else
        dlo_version := 3
        index on ss+c_katl to (sind1) progress
      endif
      use
      // изменить дату и время создания файлов
      SetDateFile(sind1,sbase,1)
    else
      func_error(4,"Не обнаружен файл "+sbase+". Проверьте настройку!")
    endif
  endif
  sbase := "_katl"
  fl := hb_fileExists(exe_dir+sbase+sntx)
  if fl  // пересоздать индекс, если обновили БД
    fl := files_time(exe_dir+sbase+sntx,exe_dir+sbase+sdbf)
  endif
  if !fl
    use (exe_dir+sbase) new readonly
    index on c_katl to (exe_dir+sbase)
    use
  endif
  sbase := beforatnum(cslash,mem_reg_lr)+cslash+"r_mushrt"
  if !hb_fileExists(sbase+sdbf) ; // если нет сокр.реестра
      .or. !files_time(sbase+sdbf,mem_reg_lr)  // или обновили БД реестра
    cre_r_mushrt(sbase)
  endif
endif*/
restscreen(buf)
return NIL

*

***** 03.03.13
Function r_list_uch(par,name_func)
// 0 - "ind_karta" инд.карта или "f_f025u" форма 025
// 1 - "list_uch" лист учета (отделение)
// 2 - "list_uch" лист учета (первичный прием)
// 3 - "f_list_ulr" лист учета льготных рецептов
// 4 - "talon12" талон амб.пациента
// 5 - "f_f066" стат.карта выбывшего из стационара

Local i := 1, j, k, s, fl, buf := save_maxrow()
Local luchast := "", arr, m1vid_ud, ;
      m1kategor := atail(stm_kategor)[2]  // т.е. прочие (последнее значение)
Private name_lpu, name_otd, mvzros_reb, mreg_lech, mmest_inog, mrab_nerab,;
        m1komu := 0, mkomu, name_org, mmi_git, mkategor, mvid_ud, mnom, mser, ;
        l1nomer, lnomer, mrajon_git, mrajon_fin, mpolis, msrok_polis, ;
        mregistrator := "", mtime, mfio, mpol, mdate_r, madres, madresp, mmr_dol, ;
        muchastok, s_prim1 := {}, mfio1 := "", mvid_ud1 := "", mser1 := "",;
        mnom1 := "", msnils := "", mbeg_polis := "", ;
        mvidpolis := "", mmesto_rog := "", mphone := ""
menu_mest  := {{"город",0},{"область",1},{"иногородний",2}}
mywait()
//
name_lpu := alltrim(glob_uch[2])
name_otd := alltrim(glob_otd[2])
if eq_any(par,1,2,4)
  j := 1
  if mem_regi_p == 2
    rest_box(buf)
    j := f_alert({"",;
                  "Необходима регистрация и печать листа учета или только печать",;
                  ""},;
                 {" ~Регистрация и печать "," Только ~печать "},;
                 1,"W/RB","G+/RB",18,,"BG+/RB,W+/R,W+/RB,GR+/R" )
    mywait()
  endif
  if j == 0
    rest_box(buf)
    return NIL
  endif
  if j == 1
    G_Use(dir_server+"mo_regi",{dir_server+"mo_regi1",;
                                dir_server+"mo_regi2",;
                                dir_server+"mo_regi3"},"RU")
    AddRec(1)
    ru->kod_k := kart->kod
    ru->tip := par
    ru->uch := glob_uch[1]
    ru->pdate := dtoc4(sys_date)
    ru->CTIME := hour_min(seconds())
    if par == 1
      ru->op := glob_otd[1]
      name_otd := alltrim(glob_otd[2])
    else
      ru->op := glob_priem[1]
      name_otd := alltrim(glob_priem[2])
    endif
    ru->kod_p := kod_polzovat // код оператора записывать всегда
    ru->(dbCloseArea())
  endif
endif
R_Use(dir_server+"k_prim1",dir_server+"k_prim1","K_PRIM1")
find (str(kart->kod,7))
do while k_prim1->kod == kart->kod .and. !eof()
  aadd(s_prim1, rtrim(k_prim1->name))
  skip
enddo
k_prim1->(dbCloseArea())
if len(s_prim1) == 0
  aadd(s_prim1, "")
endif
if !(kod_polzovat == chr(0))
  mregistrator := alltrim(fio_polzovat)
endif
mfio := upper(kart->fio)
mpolis := kart->polis
//
msnils := expand(transform(kart->SNILS,picture_pf))
mpol := kart->pol
mdate_r := full_date(kart->date_r)
madres := iif(emptyall(kart_->okatog,kart->adres), "",;
              ret_okato_ulica(kart->adres,kart_->okatog))
madresp := iif(emptyall(kart_->okatop,kart_->adresp), "",;
               ret_okato_ulica(kart_->adresp,kart_->okatop))
mmr_dol := kart->mr_dol
mtime := hour_min(seconds())
mbeg_polis := full_date(c4tod(kart_->beg_polis))
msrok_polis := full_date(c4tod(kart->srok_polis))
mvzros_reb := upper(inieditspr(A__MENUVERT, menu_vzros, kart->vzros_reb))
mmi_git    := okato_mi_git(kart_->okatog)
mrajon_git := okato_rajon(kart_->okatog)
if !emptyall(kart_->PHONE_H,kart_->PHONE_M,kart_->PHONE_W)
  if !empty(kart_->PHONE_H)
    mphone += " дом."+kart_->PHONE_H
  endif
  if !empty(kart_->PHONE_M)
    mphone += " моб."+kart_->PHONE_M
  endif
  if !empty(kart_->PHONE_W)
    mphone += " раб."+kart_->PHONE_W
  endif
endif
mmest_inog := mrajon_fin := ""
if kart->MI_GIT == 9
  m1komu := kart->KOMU
endif
if m1komu == 0
  mkomu := "СМО - "
  if alltrim(kart_->SMO) == '34'
    s := ret_inogSMO_name(1)
    mkomu += iif(empty(s), "ТФОМС (иногородние)", s)
    mmest_inog := inieditspr(A__MENUVERT,glob_array_srf,kart_->KVARTAL_D) // ОКАТО субъекта РФ территории страхования
  elseif left(kart_->SMO,2) == '34'
    mkomu += alltrim(inieditspr(A__MENUVERT, glob_arr_smo, int(val(kart_->smo))))
    mmest_inog := 'Волгоградская область'
  elseif !empty(kart_->SMO)
    mkomu += init_ismo(kart_->SMO)
    mmest_inog := inieditspr(A__MENUVERT,glob_array_srf,kart_->KVARTAL_D) // ОКАТО субъекта РФ территории страхования
  endif
else
  mkomu := ""
  if m1komu == 1
    mkomu := "пр.компания - "
  elseif m1komu == 3
    mkomu := "комитет/МО - "
  endif
  mkomu += f4_view_list_schet(m1komu,"",kart->str_crb)
endif
mrab_nerab := upper(inieditspr(A__MENUVERT, menu_rab, kart->rab_nerab))
m1vid_ud := kart_->vid_ud
mnom     := kart_->nom_ud
mser     := kart_->ser_ud
mvidpolis := " ("+alltrim(inieditspr(A__MENUVERT,mm_vid_polis,kart_->vpolis))+")"
mmesto_rog := alltrim(kart_->mesto_r)
if empty(stm_kategor2)
  m1kategor := kart_->kategor
  mkategor := upper(inieditspr(A__MENUVERT, stm_kategor, m1kategor))
else
  m1kategor := kart_->kategor2
  mkategor := upper(inieditspr(A__MENUVERT, stm_kategor2, m1kategor))
endif
mvid_ud := ""
if (j := ascan(menu_vidud, {|x| x[2] == m1vid_ud})) > 0
  mvid_ud := menu_vidud[j,4]
endif
if empty(mser) ; mser := space(10) ; endif
if empty(mnom) ; mnom := space(10) ; endif
//
lnomer := l1nomer := lstr(kart->kod)
muchastok := put_val(kart->uchast,2)
if is_uchastok == 1
  if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
    lnomer := ""
    if !empty(kart->bukva)
      lnomer += kart->bukva
    endif
    lnomer += lstr(kart->uchast,2)
    if kart->kod_vu > 0
      lnomer += "/"+lstr(kart->kod_vu)
    endif
    l1nomer := lnomer
  endif
elseif eq_any(is_uchastok,2,3)
  if !emptyall(kart->bukva,kart->uchast)
    luchast := " [уч-к "
    if !empty(kart->bukva)
      luchast += kart->bukva
    endif
    luchast += lstr(kart->uchast,2)
    luchast += "] "
  endif
  if is_uchastok == 3
    luchast += alltrim(kart2->kod_AK)
  endif
endif
lnomer := expand(lnomer)+luchast
if !empty(name_func) .and. !("(" $ name_func)
  name_func += "()"
endif
k := &name_func
rest_box(buf)
return NIL

*

***** 13.11.16
Function new_list_uch(par,name_func)
// 0 - "f_f025u" форма 025/у
// 4 - "talon025" талон амб.пациента 025-1/у
Static sb1 := "<b><u>", sb2 := "</u></b>"
Local i := 1, j, k, s, fl, buf := save_maxrow()
Local luchast := "", arr, m1vid_ud
mywait()
//
if iif(par==4, mem_6op, mem_op) == 1
  name_otd := alltrim(glob_otd[2])
else
  name_otd := alltrim(glob_priem[2])
endif
if eq_any(par,1,2,4)
  j := iif(par==4, mem_regi6p, mem_regi_p)
  if j == 2
    rest_box(buf)
    j := f_alert({"",;
                  "Необходима регистрация и печать талона или только печать",;
                  ""},;
                 {" ~Регистрация и печать "," Только ~печать "},;
                 1,"W/RB","G+/RB",18,,"BG+/RB,W+/R,W+/RB,GR+/R" )
    mywait()
  endif
  if j == 1
    G_Use(dir_server+"mo_regi",{dir_server+"mo_regi1",;
                                dir_server+"mo_regi2",;
                                dir_server+"mo_regi3"},"RU")
    AddRec(1)
    ru->kod_k := kart->kod
    ru->uch := glob_uch[1]
    ru->pdate := dtoc4(sys_date)
    ru->CTIME := hour_min(seconds())
    if iif(par==4, mem_6op, mem_op) == 1
      ru->tip := 1
      ru->op := glob_otd[1]
    else
      ru->tip := 2
      ru->op := glob_priem[1]
    endif
    ru->kod_p := kod_polzovat // код оператора записывать всегда
    ru->(dbCloseArea())
  endif
endif
if !(kod_polzovat == chr(0))
  mregistrator := alltrim(fio_polzovat)
endif
delFRfiles()
R_Use(dir_server+"organiz",,"ORG")
adbf := {{"name_org","C",255,0},;
         {"adres_org","C",255,0},;
         {"ogrn","C",15,0},;
         {"okpo","C",12,0},;
         {"date_sys","C",10,0},;
         {"d_sys","C",2,0},;
         {"m_sys","C",2,0},;
         {"y_sys","C",4,0},;
         {"nomer_kart","C",25,0},;
         {"fio","C",130,0},;
         {"fam","C",50,0},;
         {"ima","C",50,0},;
         {"ots","C",50,0},;
         {"pol","C",50,0},;
         {"date_r","C",10,0},;
         {"d_dr","C",2,0},;
         {"m_dr","C",2,0},;
         {"y_dr","C",4,0},;
         {"subekt","C",50,0},;
         {"rajon","C",50,0},;
         {"gorod","C",50,0},;
         {"nas_p","C",50,0},;
         {"adres","C",200,0},;
         {"adresL","C",200,0},;
         {"phone","C",15,0},;
         {"phones","C",50,0},;
         {"gorod_selo","C",50,0},;
         {"ser_polis","C",10,0},;
         {"nom_polis","C",20,0},;
         {"polis","C",25,0},;
         {"snils","C",14,0},;
         {"smo","C",100,0},;
         {"kod_lgot","C",2,0},;
         {"name_doc","C",20,0},;
         {"ser_doc","C",20,0},;
         {"nom_doc","C",20,0},;
         {"zanyat","C",255,0},;
         {"invalid","C",100,0},;
         {"mr_dol","C",50,0},;
         {"perv_priem","C",50,0},;
         {"registrato","C",50,0},;
         {"time_regi","C",50,0},;
         {"mesto_rog","C",100,0},;
         {"kategor","C",40,0},;
         {"subektp","C",50,0},;
         {"rajonp","C",50,0},;
         {"gorodp","C",50,0},;
         {"nas_pp","C",50,0},;
         {"adresp","C",200,0},;
         {"adrespL","C",200,0},;
         {"platel","C",100,0},;
         {"platel1","C",100,0},;
         {"fio1","C",130,0},;
         {"kemvyd","C",150,0},;
         {"kogdavyd","C",10,0},;
         {"bukva","C",1,0},;
         {"uchast","C",2,0},;
         {"kod_vu","C",5,0},;
         {"kod_kart","C",7,0};
         }
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name_org := glob_mo[_MO_FULL_NAME]
frt->adres_org := glob_mo[_MO_ADRES]
frt->ogrn := org->ogrn
frt->okpo := org->okpo
org->(dbCloseArea())
//
s := full_date(sys_date)
frt->date_sys := s
frt->d_sys := substr(s,1,2)
frt->m_sys := substr(s,4,2)
frt->y_sys := substr(s,7,4)
arr := retFamImOt(1,.f.)
frt->fam := arr[1]
frt->ima := arr[2]
frt->ots := arr[3]
frt->fio := expand(upper(arr[1]+" "+arr[2]+" "+arr[3]))
frt->fio1 := upper(arr[1]+" "+arr[2]+" "+arr[3])
frt->ser_polis := kart_->SPOLIS
frt->nom_polis := kart_->NPOLIS
frt->polis := ltrim(alltrim(kart_->SPOLIS)+" "+kart_->NPOLIS)
frt->snils := transform(kart->SNILS,picture_pf)
frt->pol := iif(kart->pol=="М",sb1+"муж. - 1"+sb2+", жен. - 2","муж. - 1, "+sb1+"жен. - 2"+sb2)
mdate_r := full_date(kart->date_r)
frt->date_r := mdate_r
frt->d_dr := substr(mdate_r,1,2)
frt->m_dr := substr(mdate_r,4,2)
frt->y_dr := substr(mdate_r,7,4)
arr := ret_okato_Array(kart_->okatop)
frt->subektp := arr[1]
frt->rajonp  := arr[2]
frt->gorodp  := arr[3]
frt->nas_pp  := arr[4]
arr := ret_okato_Array(kart_->okatog)
frt->subekt := arr[1]
frt->rajon  := arr[2]
frt->gorod  := arr[3]
frt->nas_p  := arr[4]
if f_is_selo()
  frt->gorod_selo := "городская - 1, "+sb1+"сельская - 2"+sb2
else
  frt->gorod_selo := sb1+"городская - 1"+sb2+", сельская - 2"
endif
frt->mr_dol   := kart->mr_dol
frt->bukva    := kart->bukva
frt->kod_kart := lstr(kart->kod)
if kart->uchast > 0
  frt->uchast := lstr(kart->uchast)
endif
if kart->kod_vu > 0
  frt->kod_vu := lstr(kart->kod_vu)
endif
if !emptyall(kart_->PHONE_H,kart_->PHONE_M,kart_->PHONE_W)
  s := ""
  if !empty(kart_->PHONE_M)
    s += "моб."+kart_->PHONE_M+" "
  endif
  if !empty(kart_->PHONE_H)
    s += "дом."+kart_->PHONE_H+" "
  endif
  if !empty(kart_->PHONE_W)
    s += "раб."+kart_->PHONE_W
  endif
  frt->phone := s
  frt->phones := s
endif
if empty(kart->adres)
  s := "улица"+sb1+space(30)+sb2+" дом"+sb1+space(5)+sb2+" квартира"+sb1+space(5)+sb2
else
  s := sb1+padr(kart->adres,60)+sb2
endif
frt->adres := s+"   тел. "+sb1+frt->phones+sb2
if empty(kart->adres)
  s := "улица"+space(30)+" дом"+space(5)+" квартира"+space(5)
else
  s := padr(kart->adres,60)
endif
frt->adresL := s //+"   тел. "+frt->phones
// второй адрес
if emptyall(kart_->okatop,kart_->adresp)
  if empty(kart->adres)
    s := "улица"+sb1+space(30)+sb2+" дом"+sb1+space(5)+sb2+" квартира"+sb1+space(5)+sb2
  else
    s := sb1+padr(kart->adres,60)+sb2
  endif
else
  s := sb1+padr(kart_->adresp,60)+sb2
endif
frt->adresp := s+"   тел. "+sb1+frt->phones+sb2
if emptyall(kart_->okatop,kart_->adresp)
  if empty(kart->adres)
    s := "улица"+space(30)+" дом"+space(5)+" квартира"+space(5)
  else
    s := padr(kart->adres,60)
  endif
else
  s := padr(kart_->adresp,60)
endif
frt->adrespL := s //+"   тел. "+frt->phones
//
if (i := ascan(stm_kategor, {|x| x[2] == kart_->kategor })) > 0 ;
                                       .and. between(stm_kategor[i,3],1,9)
  frt->kod_lgot := lstr(stm_kategor[i,3])
endif
if alltrim(kart_->SMO) == '34'
  if empty(s := ret_inogSMO_name(1))
    s := "иногородние"
  endif
  frt->smo := "("+alltrim(kart_->KVARTAL_D)+") "+s
elseif left(kart_->SMO,2) == '34'
  frt->smo := alltrim(inieditspr(A__MENUVERT, glob_arr_smo, int(val(kart_->smo))))
elseif !empty(kart_->SMO)
  frt->smo := "("+alltrim(kart_->KVARTAL_D)+") "+init_ismo(kart_->SMO)
endif
s := iif(kart->rab_nerab==0,sb1,"")+"работает - 1"+iif(kart->rab_nerab==0,sb2,"")+",    "+;
     "проходит военную службу и приравненную к ней службу - 2;    "+;
     iif(kart_->PENSIONER==1,sb1,"")+"пенсионер(ка) - 3"+iif(kart_->PENSIONER==1,sb2,"")+",    "+;
     iif(kart->rab_nerab==2,sb1,"")+"студент(ка) - 4"+iif(kart->rab_nerab==2,sb2,"")+",    "+;
     iif(kart->rab_nerab==1,sb1,"")+"не работает - 5"+iif(kart->rab_nerab==1,sb2,"")+",    "+;
     "прочие - 6"
frt->zanyat := s
if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
  frt->name_doc := menu_vidud[j,4]
endif
frt->ser_doc := kart_->ser_ud
frt->nom_doc := kart_->nom_ud
//
lnomer := l1nomer := lstr(kart->kod)
muchastok := put_val(kart->uchast,2)
if is_uchastok == 1
  if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
    lnomer := ""
    if !empty(kart->bukva)
      lnomer += kart->bukva
    endif
    lnomer += lstr(kart->uchast,2)
    if kart->kod_vu > 0
      lnomer += "/"+lstr(kart->kod_vu)
    endif
    l1nomer := lnomer
  endif
elseif eq_any(is_uchastok,2,3)
  if !emptyall(kart->bukva,kart->uchast)
    luchast := " [уч-к "
    if !empty(kart->bukva)
      luchast += kart->bukva
    endif
    luchast += lstr(kart->uchast,2)
    luchast += "] "
  endif
  if is_uchastok == 3
    luchast += alltrim(kart2->kod_AK)
  endif
endif
lnomer := expand(lnomer)+luchast
frt->nomer_kart := lnomer
frt->mesto_rog  := alltrim(kart_->mesto_r)
if empty(stm_kategor2)
  frt->kategor := inieditspr(A__MENUVERT, stm_kategor, kart_->kategor)
else
  frt->kategor := inieditspr(A__MENUVERT, stm_kategor2, kart_->kategor2)
endif
if iif(par==4, mem_6op > 0, .t.)
  frt->perv_priem := name_otd
endif
if iif(par==4, mem_6fio_r == 1, .t.)
  frt->registrato := mregistrator
endif
if iif(par==4, mem_6time == 1, .t.)
  frt->time_regi := date_8(sys_date)+"г.  "+hour_min(seconds())
endif
Private m1company := 0, mcompany := " ", mm_company := {}
Private m1KOMU := 0, MKOMU, M1STR_CRB := 0
if kart->MI_GIT == 9
  m1KOMU    := kart->KOMU
  M1STR_CRB := kart->STR_CRB
endif
mkomu := inieditspr(A__MENUVERT, mm_komu, m1komu)
if m1komu == 0
  m1company := int(val(kart_->SMO))
elseif eq_any(m1komu,1,3)
  m1company := m1str_crb
endif
if m1komu == 0 // ОМС
  mm_company := aclone(glob_arr_smo)
elseif m1komu == 1 // Прочие компании
  R_Use(dir_server+"str_komp")
  index on upper(name) to tmp_comp for !between(tfoms,44,47)
  dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
  str_komp->(dbCloseArea())
elseif m1komu == 3 // Комитеты/МО
  R_Use(dir_server+"komitet")
  index on upper(name) to tmp_comp
  dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
  komitet->(dbCloseArea())
endif
mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
frt->platel  := mkomu
if m1komu == 0  // ОМС
  frt->platel1 := frt->smo
else
  frt->platel1 := mcompany
endif
// кем выдан паспорт
R_Use(dir_server+"s_kemvyd")
goto(kart_->kemvyd)
frt->kemvyd := s_kemvyd->name
s_kemvyd->(dbCloseArea())
frt->kogdavyd := full_date(kart_->kogdavyd)
frt->(dbCloseArea())
if !empty(name_func) .and. !("(" $ name_func)
  name_func += "()"
endif
k := &name_func
rest_box(buf)
return NIL

*

***** инд.карта
Function ind_karta()
Local file_sh, k := 10, arr, sh, HH, reg_print, n_file
Local tmp_file := "___tmp"+stxt, lfp, s
if (file_sh := search_file(f_file8())) == NIL
  return func_error(4,"Не обнаружен файл шаблона "+f_file8())
endif
n_file := StripPath(beforatnum(".",file_sh)) + stxt
arr := print_shablon(file_sh,,n_file,.f.)
if valtype(arr) == "A"
  sh := arr[1]
  HH := arr[2]
  reg_print := arr[3]
  Private yes_albom := arr[5]
  viewtext(n_file,,,,(k+sh>80),,,reg_print,,,.f.,(f_ff_lu()==1))
endif
return NIL

*****
Static Function f_file8()
Local k := mem_file8
if eq_any(glob_task,X_PLATN,X_ORTO)
  k := mem_ort_f8
endif
return k

*****
Static Function f_ff_lu()
Local k := mem_ff_lu
if eq_any(glob_task,X_PLATN,X_ORTO)
  k := mem_ortfflu
endif
return k

*

*****
Function pr_sh_F5()
Private file_sh
if !empty(mem_file5) .and. ;
     !empty(file_sh := menu_shablon(3,3,dir_exe+"*."+mem_file5,color8,.f.,.f.))
  Private msnils := "", mlgota := "",;
          madres_lpu := "", mogrn := "", name_lpu
  R_Use(dir_server+"organiz",,"ORG")
  name_lpu := alltrim(org->name)
  madres_lpu := alltrim(org->adres)
  mogrn := alltrim(org->ogrn)
  /*if is_r_mu .and. !r_mushrt->(eof())
    msnils := alltrim(r_mushrt->snils)
    mlgota := alltrim(r_mushrt->lgota)
    if select("katl") == 0
      use_base("katl")
    endif
    select KATL
    find (mlgota)
    if len(alltrim(katl->name_katl)) > 3
      mlgota += " "+alltrim(katl->name_katl)
    endif
    if len(mlgota) > 48
      mlgota := left(mlgota,45)+"..."
    endif
  endif
  */
  if empty(msnils) .and. !empty(kart->SNILS)
    msnils := transform(kart->SNILS,picture_pf)
  endif
  r_list_uch(0,"f1_pr_shab(file_sh)")
endif
return NIL

*****
Function f1_pr_shab(lsh)
Local arr := print_shablon(lsh,,,.f.)
Local width, regim, n_file
width := arr[1]
regim := arr[3]
n_file := StripPath(beforatnum(".",lsh)) + stxt
Private yes_albom := arr[5]
if glob_mo[_MO_KOD_TFOMS] == '175303' //ксп-3
  if regim == 6
    regim := 8
  endif
endif
viewtext(n_file,,,,(width > 80),,,regim,,,,(mem_ff_lu==1))
return NIL

*

***** стат.карта выбывшего из стационара
Function f_f066()
Local file_sh
if (file_sh := search_file(mem_file4)) == NIL
  return func_error(4,"Не обнаружен файл шаблона "+mem_file4)
endif
R_Use(dir_server+"organiz",,"ORG")
name_lpu := alltrim(org->name)
f1_pr_shab(file_sh)
return NIL

***** 15.10.15 форма 025
Function f_f025u()
Static arr_f := {"mo_025uA5_1","mo_025uA5_2","mo_025uA4_1","mo_025uA4_2",;
                 "mo_025uA4_k"}
Local i := mem_t_025u
if !between(i,1,6)
  i := 1
endif
if i == 6
  if empty(mem_filg8)
    func_error(4,"Не настроено имя файла шаблона для печати амбулаторной карты")
  elseif hb_fileExists(mem_filg8+sfr3)
    call_fr(mem_filg8)
  else
    func_error(4,"Не обнаружен файл шаблона "+mem_filg8+sfr3)
  endif
else
  call_fr(arr_f[i])
endif
return NIL

***** 15.10.15 талон 025
Function f_talon025()
if mem_2_lt12 == 1
  call_fr("mo_025_1u")
elseif mem_2_lt12 == 2
  call_fr("mo_025_1u_")
else
  if empty(mem_filg6)
    func_error(4,"Не настроено имя файла шаблона для печати талона")
  elseif hb_fileExists(mem_filg6+sfr3)
    call_fr(mem_filg6)
  else
    func_error(4,"Не обнаружен файл шаблона "+mem_filg6+sfr3)
  endif
endif
return NIL

*

***** лист учета (1 - отделение), (2 - первичный прием)
Function list_uch(is_lgotnik)
Local sh := 80, HH := 55, buf := save_maxrow(), regim_print := 2
Local i := 1, j, k, tmp[2], tmp1, w1 := 65, s, fl, rec
Local n_file := "list_uch"+stxt, arr, mfam1, mima1, mots1, m1vid_ud, ;
      m1kategor := atail(stm_kategor)[2]  // т.е. прочие (последнее значение)
//
DEFAULT is_lgotnik TO .f.
is_lgotnik := .f. //временно
if is_lgotnik .and. (file_sh := search_file(mem_file9l)) != NIL
 /* rec := kart->(recno())
  if select("r_mu") == 0
    use_base("r_mu")
  endif
  select R_MU
  find (r_mushrt->snils)
  Private msnils := alltrim(r_mu->ss), ;
          mlgota := "", m1lgota := "", minvalid := ""
  if select("l_mu") == 0
    use_base("l_mu")
  endif
  select L_MU
  find (msnils)
  if select("katl") == 0
    use_base("katl")
  endif
  select KATL
 // find (l_mu->(__c_katl()))
 // mlgota := l_mu->(__c_katl())
  if len(alltrim(katl->name_katl)) > 3
    mlgota += " ("+alltrim(katl->name_katl)+")"
  endif
  //m1lgota := l_mu->(__c_katl())+": "
  // (наименование, N, серия, дата, кем выдан)
  //m1lgota += alltrim(l_mu->NAME_DL)+" серия "+alltrim(l_mu->(__ser_dl()))+" N "+;
  //           alltrim(l_mu->(__numb_dl()))
  if dlo_version==3 .and. !empty(l_mu->DATE_VD)
    m1lgota += " дата "+date_8(s_2_d(l_mu->DATE_VD))+"г."
  endif
  if dlo_version==3 .and. !empty(l_mu->NAME_VD)
    m1lgota += " выдан "+alltrim(l_mu->NAME_VD)
  endif
  if eq_any(l_mu->(__c_katl()),"010","081","082","083","084")
    minvalid := alltrim(katl->name_katl)
  endif
  f1_pr_shab(file_sh)
  use_base("kartotek")
  goto (rec)
  return NIL*/
else
  do case
    case mem_razmer == 1   // формат A4
      //
    case mem_razmer == 2   // 1/2 формата A4 (вертикально)
      HH := 53 ; regim_print := 6
    case mem_razmer == 3   // 1/2 формата A4 (горизонтально)
      HH := 37 ; regim_print := 5
    case mem_razmer == 4   // 1/2 ф.A4 (горизонально - впечатывание)
      HH := 37 ; regim_print := 5
    case mem_razmer == 5   // ф.A4, отрывные талоны на платные услуги
      HH := 53 ; regim_print := 5
    case mem_razmer == 6   // собственный шаблон
      if (file_sh := search_file(mem_file9)) == NIL
        return func_error(4,"Не обнаружен файл шаблона "+mem_file9)
      endif
      rec := kart->(recno())
      f1_pr_shab(file_sh)
      use_base("kartotek")
      goto (rec)
      return NIL
  endcase
endif
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
// ЮРА
Private msnils := transform(kart->SNILS,picture_pf)
if mem_lu_stt == 1
  add_string(padr(name_lpu,sh/2)+padl(name_otd,sh/2))
  add_string("")
  add_string(center("Л_И_С_Т  У_Ч_Е_Т_А",sh))
  add_string(center("М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  N  "+lnomer,sh))
  add_string("")
else
  add_string(padr(name_lpu+" ("+name_otd+")",sh-18)+padl("Форма 025-10у-97",18))
  if !eq_any(mem_razmer,3,4) ; add_string("") ; endif
  add_string(center("ТАЛОН  АМБУЛАТОРНОГО  ПАЦИЕНТА  N  "+lnomer,sh))
  if !eq_any(mem_razmer,3,4) ; add_string("") ; endif
endif
add_string("  Ф.И.О.: "+mfio+"          Пол: "+mpol)
//ЮРА
add_string("  Дата рождения: "+mdate_r+" ("+alltrim(mvzros_reb)+")    СНИЛС: "+msnils)
s := "  Место жительства: "+mmi_git
if !empty(mrajon_git)
  s += " ("+alltrim(mrajon_git)+")"
endif
add_string(s)
k := perenos(tmp,"Адрес регистрации: "+madres,sh-2)
add_string("  "+tmp[1])
for i := 2 to k
  add_string(padl(alltrim(tmp[2]),sh))
next
if !empty(madresp)
  k := perenos(tmp,"Адрес пребывания: "+madresp,sh-2)
  add_string("  "+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[2]),sh))
  next
endif
s := "  Статус пациента: "+mrab_nerab
if mem_lu_stt == 2 .and. !empty(mkategor)
  s += space(11)+"Код категории льготы: "+mkategor
endif
add_string(s)
if !empty(mmr_dol)
  add_string("  Место работы/учебы: "+mmr_dol)
endif
if m1komu == 0  // 27.06.12
  add_string("  Регион финансирования: "+mmest_inog)
endif
add_string("  Принадлежность счета: "+mkomu)
if m1komu == 0  // 27.06.12
  add_string("  Страховой полис: "+mpolis+mvidpolis+"     действителен до: "+msrok_polis)
endif
if !(mem_lu_stt == 2 .and. eq_any(mem_razmer,2,3,4,5)) ; add_string("") ; endif
add_string("  Условия оказания мед.помощи: ______________")
if mem_razmer != 4
  if mem_lu_stt == 1
    add_string("  Шифр основного заболевания: _____.")
    add_string("  Сопутствующие заболевания : _____, _____, _____, _____, _____, _____, _____.")
  else
    add_string("  ------------------------------------------------------------------------------")
    add_string("    Код  |                                                     |Характер|Диспан.")
    add_string("   МКБ-10| Диагноз основной (уточненный)                       |заболев.| учет  ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         | Сопутствующие                                       |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  -------|-----------------------------------------------------|--------|-------")
    add_string("         |                                                     |  1  2  | 1 2 3 ")
    add_string("  ------------------------------------------------------------------------------")
    if !(mem_lu_stt == 2 .and. eq_any(mem_razmer,2,3,4,5)) ; add_string("") ; endif
  endif
endif
  add_string("  Результат обращения: ______________       Исход заболевания: _____________")
if mem_lu_stt == 2
  add_string("           Повод обращения: ______________       Вид травмы: _______________")
endif
if !(mem_lu_stt == 2 .and. eq_any(mem_razmer,3,4)) ; add_string("") ; endif
add_string(center("Срок лечения с  "+expand(full_date(sys_date))+"  по  ____.____.____",sh))
if !(mem_lu_stt == 2 .and. eq_any(mem_razmer,3,4)) ; add_string("") ; endif
add_string("  Временная нетрудоспособность (больничный) ___ [ с ___.___.___ по ___.___.___ ]")
add_string("  Уд-ие: "+mvid_ud+"  серия: "+mser+" номер: "+mnom)
if !empty(mmesto_rog)
  add_string("  Место рождения: "+mmesto_rog)
endif
if mem_razmer != 4
  if !empty(s_prim1[1])
  add_string("  Примечание: "+s_prim1[1])
    for k := 2 to len(s_prim1)
      add_string(space(14)+s_prim1[k])
    next
  endif
  if tek_stroke < HH-7
    add_string("")
    add_string(center("О_К_А_З_А_Н_Ы   У_С_Л_У_Г_И",sh))
    reg_title(2,1)
  endif
  do while tek_stroke < HH
    reg2title()
  enddo
endif
if mem_fio_r == 1 .and. !(kod_polzovat == chr(0))
  s := "Регистратор: "+mregistrator
  if mem_time == 1
    s += " ["+mtime+"]"
  endif
  add_string(padl(s,sh))
endif
if mem_razmer == 5   // ф.A4, отрывные талоны на платные услуги
  tmp := f_otr_plat(name_otd,l1nomer,mfio)
  for j := 1 to 2
    add_string(replicate("-",sh))
    for k := 1 to len(tmp)
      if tek_stroke < 80
        add_string(tmp[k]+"|"+tmp[k])
      endif
    next
  next
endif
if mem_ff_lu == 1 .and. mem_2_list == 1
  add_string(chr(12))
  tek_stroke := 0 ; n_list++
  reg_title(2,2)
  do while tek_stroke < HH-7
    reg2title()
  enddo
  add_string("                                                                  _____________ ")
  add_string("                                            Общая сумма лечения: |             |")
  add_string("                                                                 |_____________|")
  add_string("")
  add_string(center("Оператор ________________________",sh))
endif
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.f.,,,regim_print,,,,(mem_ff_lu==1))
return NIL

*****
Function reg_title(k1,k2)
DEFAULT k1 TO 1
if k1 == 2
  add_string("--------------------------------------------------------------------------------")
  add_string(" Отде-|Дата оказа-|  Код  |   Шифр   | На  |           |           | Количество ")
  add_string(" ление|ния услуги |  МКБ  |  услуги  |дому?|   Врач    | Ассистент |   услуг    ")
  add_string("--------------------------------------------------------------------------------")
  if k2 == 1
    reg2title()
  endif
  if k2 == 2
    reg2title()
  endif
endif
return NIL

*****
Function reg2title()
    add_string("      |           |       |          |     |           |           |            ")
    add_string("______|___________|_______|__________|_____|___________|___________|____________")
return NIL

*****
Function f_otr_plat(lotd,lnomer,lfio)
Local sh := 39, arr[12], i
afill(arr,space(sh))
arr[1] := padr(lotd,sh-15)+"   ___.___."+lstr(year(date()))
arr[3] := padr(" "+lnomer+" "+fam_i_o(lfio),sh-14)+" Диагноз _____"
arr[4] := "----+--------+------+------+-----+-----"
arr[5] := "Отд.| Услуга | Врач |Кол-во| м/с | сан."
arr[6] := "----+--------+------+------+-----+-----"
for i := 8 to len(arr) step 2
  arr[i] := replicate("-",sh)
next
return arr



*****
Function f_msek_do_posle(lcel,lgrup)
Local s := ""
if lcel == 1
  s := lstr(lgrup)+" гр."
elseif lcel == 2 .and. lgrup > 0
  s := str(lgrup,3)+" %"
endif
return padc(s,5)

*****
Function fluorogr_lpu()
Local date_end, s, lcolor
if type("mem_fluor") == "N" .and. mem_fluor == 1
  s := " Флюорография: " ; lcolor := "W+/GR"
  if !eof() .and. !empty(kart_->date_fl)
    if kart_->gr_risk > 0 // есть группа риска - период полгода
      date_end := c4tod(kart_->date_fl)+183
    else // период год
      date_end := c4tod(kart_->date_fl)+365
    endif
    s += full_date(c4tod(kart_->date_fl))
    if date_end > sys_date
      lcolor := "W+/G"
    else
      lcolor := "W+/R"
    endif
  endif
  @ 1,51 say padr(s,26) color lcolor
endif
return NIL

* специально для Поликлиники №4

*****
Function p4_travma(r,c)
Static snomer := 0, sdost, svrach, stravma := 11, sd_obr, sd_travm
Local buf := savescreen(), mtitul, k, fl_dost := (type("arr_dost")=="A"),;
      fl := .f.
DEFAULT sdost TO space(10), svrach TO space(10), ;
        sd_obr TO sys_date, sd_travm TO sys_date
Private m1travma := stravma
mnomer := snomer
mdate_obr := sd_obr
mdate_travm := sd_travm
mtravma := inieditspr(A__MENUVERT, stm_travma, stravma)
mvrach := svrach
mdost := sdost
mtitul := alltrim(kart->fio)
k := maxrow()-14
box_shadow(k,0,maxrow()-1,maxcol(),color1,mtitul,color8)
str_center(k+1,"Ввод реквизитов для печати в Травматологическом отделении","G+/B")
setcolor(cDataCGet)
++k
@ ++k,4 say "Порядковый номер по журналу" get mnomer pict "999999"
@ ++k,4 say "Врач" get mvrach ;
        reader {|x|menu_reader(x,arr_vrach,A__MENUVERT,,,.f.)}
@ ++k,4 say "Дата обращения" get mdate_obr
@ ++k,4 say "Дата получения травмы" get mdate_travm
@ ++k,4 say "Вид травмы" get mtravma ;
        reader {|x|menu_reader(x,stm_travma,A__MENUVERT,,,.f.)}
if fl_dost
  @ ++k,4 say "Как доставлен" get mdost ;
          reader {|x|menu_reader(x,arr_dost,A__MENUVERT,,,.f.)}
endif
status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение печати")
myread()
setcolor(color0)
restscreen(buf)
if lastkey() != K_ESC
  fl := .t.
  if fl_dost
    sdost := mdost
  endif
  snomer := mnomer
  svrach := mvrach
  stravma := m1travma
  sd_obr := mdate_obr
  sd_travm := mdate_travm
endif
return fl

*

***** 27.02.20
Function prn_kartoteka(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1
Local mas_pmt, mas_msg, mas_fun, j, r, nuch, nsmo
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Сводный DBF-~файл"}
    mas_msg := {"Сводная информация (создание DBF-файла по участку/по СМО)"}
    mas_fun := {"prn_kartoteka(11)"}
    if glob_mo[_MO_IS_UCH]
      aadd(mas_pmt, "Создание файла для ~ЛИС")
      aadd(mas_msg, 'Создание файла для ЛИС в ГБУЗ "ВОМИАЦ" (письмо №1337 от 30.11.15г.)')
      aadd(mas_fun, "prn_kartoteka(12)")
      aadd(mas_pmt, "Прикреплённое ~население")
      aadd(mas_msg, "Просмотр прикреплённого населения")
      aadd(mas_fun, "prn_kartoteka(13)")
    endif
    aadd(mas_pmt, "Информация по ~инвалидам")
    aadd(mas_msg, "Просмотр сводной информации по инвалидам")
    aadd(mas_fun, "prn_kartoteka(14)")
    // выгрузка в Excel
    aadd(mas_pmt, "Выгрузка в Excel")
    aadd(mas_msg, "Выгрузка картотеки в Excel")
    aadd(mas_fun, "prn_kartoteka(41)")
    if T_ROW > 8
      r := T_ROW-len(mas_pmt)-3
    else
      r := T_ROW
    endif
    popup_prompt(r,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    if (j := popup_prompt(T_ROW,T_COL+5,si2,{"по ~участку","по ~СМО"})) > 0
      si2 := j
      if j == 1
        if (nuch := input_uchast()) != NIL
          f0_prn_kartotek(1,nuch)
        endif
      elseif j == 2
        if (j := popup_prompt(T_ROW,T_COL+5,si2,;
            {'КапиталЪ Медстрах','ОАО "СОГАЗ-Мед"','ООО "МСК-Максимус"','ООО "РГС-Медицина"'})) > 0
          f0_prn_kartotek(2,,{'34001','34002','34006','34007'}[j])
        endif
      endif
    endif
  case k == 12
    create_DBF_for_LIS()
  case k == 13
    mas_pmt := {"~Сводная информация",;
                "Прикреплённые к нашей ~МО",;
                "Прикреплённые к ~другим МО",;
                "~Не прикреплённые ни к одной МО"}
    mas_msg := {"Итоговая информация по прикреплённому населению из нашей картотеки",;
                "Просмотр/печать населения, прикреплённого к нашей МО",;
                "Просмотр/печать населения, прикреплённого к другим МО",;
                "Просмотр/печать населения, не прикреплённого ни к одной МО"}
    mas_fun := {"prn_kartoteka(21)",;
                "prn_kartoteka(22)",;
                "prn_kartoteka(23)",;
                "prn_kartoteka(24)"}
    Private arr_mo := {}, arr_no := {}
    popup_prompt(T_ROW-3-len(mas_pmt),T_COL+5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 14
    pr_invalid()
  case k == 21
    pripisnoe_naselenie_view()
  case k == 22
    mas_pmt := {"Весь список прикреплённых к ~МО",;
                "~Итого по участковым врачам",;
                "Количество по ~участкам"}
    mas_msg := {"Просмотр/печать населения, прикреплённого к нашей МО",;
                "Подсчёт количества пациентов, прикреплённых к участковым врачам",;
                "Подсчёт количества прикреплённого населения по участкам"}
    mas_fun := {"prn_kartoteka(31)",;
                "prn_kartoteka(32)",;
                "prn_kartoteka(33)"}
    popup_prompt(T_ROW,T_COL+5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 23
    spisok_pripisnoe_naselenie(2)
  case k == 24
    spisok_pripisnoe_naselenie(3)
  case k == 31
    spisok_pripisnoe_naselenie(1)
  case k == 32
    prn_itogo_uch_vrach()
  case k == 33
    kol_uch_pripisnoe_naselenie()
  case k == 41
    kartotekToExcel()
  case k == 42
  case k == 43
  case k == 44
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  endif
endif
return NIL

***** 17.03.20
Function pr_invalid()
Static suchast := 0, sinvalid := 0, sprik := 1, sspisok := 1,;
       mm_invalid := {{"все",0},{"1 группа",1},{"2 группа",2},{"3 группа",3},{"дети-инвалиды",4}},;
       mm_prik := {{"все",0},{"прикреплён к нашей МО",1},{"прикреплён к другим МО",2},{"прикрепление неизвестно",3}},;
       mm_pol := {{"все",0},{"мужчины",1},{"женщины",2}},;
       mm_rab := {{"все",0},{"работающие",1},{"неработающие",2}},;
       mm_pens := {{"все",0},{"пенсионеры",1},{"не пенсионеры",2}},;
       mm_gorod := {{"все",0},{"город",1},{"село",2}},;
       mm_spisok := {{"список инвалидов",1},{"общее количество",2}}
Local buf := savescreen(), r := 14, sh, HH := 60, name_file := "invalid"+stxt, k_fio, tt_fio[2]
setcolor(cDataCGet)
myclear(r)
Private muchast := suchast,;
        m1INVALID := sinvalid, mINVALID,;
        m1prik := sprik, mprik,;
        m1pol := 0, mpol := "все",;
        m1rab := 0, mrab := "все",;
        m1pens := 0, mpens := "все",;
        m1gorod := 0, mgorod := "все",;
        m1spisok := sspisok, mspisok := mm_spisok[sspisok,1],;
        gl_area := {r,0,maxrow()-1,maxcol(),0}
minvalid := inieditspr(A__MENUVERT, mm_invalid, m1invalid)
mprik := inieditspr(A__MENUVERT, mm_prik, m1prik)
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запустить поиск")
//
@ r,0 to r+9,maxcol() COLOR color8
str_center(r," Запрос в картотеке информации по инвалидам ",color14)
@ r+1,2 SAY "Инвалидность" GET minvalid reader {|x| menu_reader(x,mm_invalid,A__MENUVERT,,,.f.)}
@ r+2,2 SAY "Прикрепление" GET mprik reader {|x| menu_reader(x,mm_prik,A__MENUVERT,,,.f.)}
@ r+3,2 say "Номер участка (0 - по всем участкам)" get muchast pict "99999"
@ r+4,2 say "Пол" get mpol reader {|x|menu_reader(x,mm_pol,A__MENUVERT,,,.f.)}
@ r+5,2 say "Работающий?" get mrab reader {|x|menu_reader(x,mm_rab,A__MENUVERT,,,.f.)}
@ r+6,2 say "Пенсионер?" get mpens ;
       reader {|x|menu_reader(x,mm_pens,A__MENUVERT,,,.f.)}
@ r+7,2 say "Город/село" GET mgorod ;
               reader {|x| menu_reader(x,mm_gorod,A__MENUVERT,,,.f.)}
@ r+8,2 say "Как выводить результат поиска?" get mspisok ;
        reader {|x|menu_reader(x,mm_spisok,A__MENUVERT,,,.f.)}
myread()
if lastkey() != K_ESC
  mywait()
  suchast := muchast
  sinvalid := m1invalid
  sprik := m1prik
  sspisok := m1spisok
  //
  dbcreate(cur_dir+"tmp",{;
    {"kod",       "N",  7,0},;
    {"INVALID",   "N",  1,0},; // группа инвалидности
    {"UCHAST" ,   "N",  2,0},; // номер участка
    {"POL"    ,   "C",  1,0},; // пол
    {"DATE_R"   , "D",  8,0},; // дата рождения пациента
    {"pens"   ,   "N",  1,0},; //
    {"rab"    ,   "N",  1,0},; //
    {"gorod"  ,   "N",  1,0},; //
    {"LET"    ,   "N",  2,0},; // сколько лет в этом году
    {"MO_PR",     "C",  6,0}; // код МО приписки
  },,.t.,"TMP")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  set relation to recno() into KART, recno() into KART2
  index on str(kart->kod,7) to (cur_dir+"tmp_kart") for between(kart_->INVALID,1,4)
  go top
  do while !eof()
    f1_pr_invalid()
    select KART_
    skip
  enddo
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"Нет сведений!")
    endif
  else
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("ИНФОРМАЦИЯ ПО ИНВАЛИДАМ"),sh))
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    if m1spisok == 1 // список инвалидов
      arr_title := {"","","",""}
      if muchast == 0
        arr_title[1] += "──┬"
        arr_title[2] += "№№│"
        arr_title[3] += "уч│"
        arr_title[4] += "──┴"
      endif
      arr_title[1] += "───────────────────────────────────────────┬──┬──────────┬───┬───────────────────────────────────"
      arr_title[2] += "             Ф.И.О. пациента               │Ле│   дата   │Гр.│              Адрес                "
      arr_title[3] += "                (телефон)                  │т │ рождения │инв│                                   "
      arr_title[4] += "───────────────────────────────────────────┴──┴──────────┴───┴───────────────────────────────────"
      reg_print := f_reg_print(arr_title,@sh,2)
    else
      sh := 2
      reg_print := 2
    endif
    if m1invalid > 0
      add_string("Группа инвалидности: "+inieditspr(A__MENUVERT, mm_invalid, m1invalid))
    endif
    if !empty(muchast)
      add_string("Участок: "+lstr(muchast))
    endif
    if !empty(m1prik)
      add_string("Отношение к прикреплению: "+inieditspr(A__MENUVERT, mm_prik, m1prik))
    endif
    if m1gorod > 0
      add_string("Место жительства: "+inieditspr(A__MENUVERT, mm_gorod, m1gorod))
    endif
    if !empty(m1pol)
      add_string("Пол: "+inieditspr(A__MENUVERT, mm_pol, m1pol))
    endif
    if m1rab > 0
      add_string(upper(inieditspr(A__MENUVERT, mm_rab, m1rab)))
    endif
    if m1pens > 0
      add_string(upper(inieditspr(A__MENUVERT, mm_pens, m1pens)))
    endif
    add_string("")
    if m1spisok == 1 // список инвалидов
      aeval(arr_title, {|x| add_string(x) } )
      ii := 0
      R_Use(dir_server+"kartote2",,"KART2")
      R_Use(dir_server+"kartote_",,"KART_")
      R_Use(dir_server+"kartotek",,"KART")
      set relation to recno() into KART_, to recno() into KART2
      use (cur_dir+"tmp") new
      set relation to kod into KART
      index on upper(kart->fio) to (cur_dir+"tmp")
      select TMP
      go top
      do while !eof()
        ++ii
        @ maxrow(),1 say str(ii/tmp->(lastrec())*100,6,2)+"%" color cColorSt2Msg
        s1 := ""
        if muchast == 0
          s1 += put_val(kart->uchast,2)+" "
        endif
        s := ""
        if !empty(kart_->PHONE_H)
          s += "д."+alltrim(kart_->PHONE_H)+" "
        endif
        if !empty(kart_->PHONE_M)
          s += "м."+alltrim(kart_->PHONE_M)+" "
        endif
        if !empty(kart_->PHONE_W)
          s += "р."+alltrim(kart_->PHONE_W)
        endif
        s := alltrim(kart->fio)+" "+s
        k_fio := perenos(tt_fio,s,43)
        s1 += padr(tt_fio[1],43)+str(tmp->let,3)+" "+full_date(kart->date_r)
        if tmp->INVALID < 4
          s1 += str(tmp->INVALID,3)+"  "
        else
          s1 += " дет "
        endif
        s1 += alltrim(kart->adres)
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(s1)
        for i := 2 to k_fio
          s1 := ""
          if muchast == 0
            s1 += space(3)
          endif
          s1 += padr(tt_fio[i],44)
          add_string(s1)
        next
        select TMP
        skip
      enddo
    else //общее количество
      arr := array(4)
      afillall(arr,0)
      use (cur_dir+"tmp") new
      go top
      do while !eof()
        arr[tmp->INVALID] ++
        select TMP
        skip
      enddo
      add_string("1 группа      "+lstr(arr[1]))
      add_string("2 группа      "+lstr(arr[2]))
      add_string("3 группа      "+lstr(arr[3]))
      add_string("дети-инвалиды "+lstr(arr[4]))
    endif
    add_string("")
    add_string("Итого количество пациентов: "+lstr(tmp->(lastrec()))+" чел.")
    fclose(fp)
    close databases
    restscreen(buf)
    viewtext(name_file,,,,.t.,,,reg_print)
  endif
endif
close databases
restscreen(buf)
return NIL

***** 17.03.20
Static Function f1_pr_invalid()
Local i, j, k, n, s, arr, fl := .t., god_r, arr1
// За исключением умерших (по сведению ТФОМС)
fl := !(left(kart2->PC2,1) == "1")
if fl
  if fl .and. !empty(m1prik)
    if m1prik == 1 // к нашей МО
      fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
    elseif m1prik == 2 // к другим МО
      fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
    else // прикрепление неизвестно
      fl := empty(kart2->MO_PR) .or. kart2->MO_PR == '000000'
    endif
  endif
  if muchast > 0
    fl := (kart->uchast == muchast)
  endif
  if fl .and. !empty(m1pol)
    if kart->pol == "М"
      fl := (m1pol == 1)
    else
      fl := (m1pol == 2)
    endif
  endif
  is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)
  if fl .and. m1gorod > 0
    if is_selo
      fl := (m1gorod == 1)
    else
      fl := (m1gorod == 2)
    endif
  endif
  if fl .and. m1pens > 0
    if kart_->PENSIONER == 1
      fl := (m1pens == 1)
    else
      fl := (m1pens == 2)
    endif
  endif
  if fl .and. m1invalid > 0
    fl := (m1invalid == kart_->INVALID)
  endif
  if fl .and. m1rab > 0
    fl := (kart->rab_nerab == m1rab-1)
  endif
  //
  if fl
    if (k := year(sys_date) - year(kart->date_r)) > 99
      k := 99
    endif
    select TMP
    append blank
    tmp->kod     := kart->kod
    tmp->INVALID := kart_->INVALID
    tmp->UCHAST  := kart->uchast
    tmp->POL     := kart->pol
    tmp->DATE_R  := kart->date_r
    tmp->pens    := iif(kart_->PENSIONER==1, 1, 2)
    tmp->rab     := kart->rab_nerab+1
    tmp->gorod   := iif(is_selo, 2, 1)
    tmp->LET     := k
    tmp->MO_PR   := kart2->MO_PR
  endif
endif
return NIL

***** 25.03.18 Подсчёт количества прикреплённого населения по участкам
Function kol_uch_pripisnoe_naselenie()
Local sh, HH := 60, name_file := "uch_prik"+stxt, arr_title, i, j, k, arr1 := {}, arr2 := {},;
      fl, arr, buf := save_maxrow()
mywait()
R_Use(dir_exe+"_okatos",cur_dir+"_okats","SELO")
R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OBLAST")
R_Use_base("kartotek")
set order to
go top
do while !eof()
  @ maxrow(),0 say str(recno()/lastrec()*100,6,2)+"%" color cColorWait
  if kart->kod > 0 .and. !(left(kart2->PC2,1)=='1') .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS] // прикреплён к НАМ
    v := iif(count_years(kart->date_r,sys_date) < 18, 2, 1)
    j := iif(kart->pol == "М", 2, 3)
    k := 4 // город
    fl := .f.
    if kart_->gorod_selo == 2
      fl := .t.  // нашли
      k := 5   // село
    endif
    if !fl .and. !empty(okato_rajon(kart_->okatog,@arr))
      if arr[5] == 1 // город
        fl := .t.  // нашли
        k := 4   // город
      endif
    endif
    if !fl
      select SELO
      find (padr(kart_->okatog,11,'0'))
      if found()
        fl := .t.  // нашли
        k := iif(selo->selo == 0, 5, 4)
      endif
      if !fl
        select OBLAST
        find (padr(kart_->okatog,5,'0'))
        if found()
          fl := .t.  // нашли
          k := iif(oblast->selo == 0, 5, 4)
        endif
      endif
    endif
    if v == 1
      if (i := ascan(arr1, {|x| x[1] == kart->uchast })) == 0
        aadd(arr1, {kart->uchast,0,0,0,0}) ; i := len(arr1)
      endif
      arr1[i,j] ++
      arr1[i,k] ++
    else
      if (i := ascan(arr2, {|x| x[1] == kart->uchast })) == 0
        aadd(arr2, {kart->uchast,0,0,0,0}) ; i := len(arr2)
      endif
      arr2[i,j] ++
      arr2[i,k] ++
    endif
  endif
  select KART
  skip
enddo
close databases
rest_box(buf)
if len(arr1) == 0 .and. len(arr2) == 0
  func_error(4,"Не обнаружено пациентов, прикреплённых к нашей МО")
else
  arr := array(5)
  asort(arr1,,,{|x,y| x[1] < y[1] })
  asort(arr2,,,{|x,y| x[1] < y[1] })
  arr_title := {;
    "─────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
    "№ участка│  мужчины  │  женщины  │   город   │   село    │   Всего   ",;
    "─────────┴───────────┴───────────┴───────────┴───────────┴───────────"}
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  sh := len(arr_title[1])
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string("")
  add_string(center("Количество прикреплённых пациентов",sh))
  add_string(center("[ по состоянию на "+date_8(sys_date)+"г. ]",sh))
  aeval(arr_title, {|x| add_string(x) } )
  if len(arr1) > 0
    if verify_FF(HH-2,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    afill(arr,0)
    add_string("")
    add_string(padc("взрослые",sh,"_"))
    for i := 1 to len(arr1)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(str(arr1[i,1],7)+put_val(arr1[i,2],12)+put_val(arr1[i,3],12)+;
                                  put_val(arr1[i,4],12)+put_val(arr1[i,5],12)+put_val(arr1[i,2]+arr1[i,3],12))
      for j := 2 to 5
        arr[j] += arr1[i,j]
      next
    next
    add_string(replicate("─",sh))
    add_string(" Итого:"+put_val(arr[2],12)+put_val(arr[3],12)+;
                         put_val(arr[4],12)+put_val(arr[5],12)+put_val(arr[2]+arr[3],12))
  endif
  if len(arr2) > 0
    if verify_FF(HH-2,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    afill(arr,0)
    add_string("")
    add_string(padc("дети",sh,"_"))
    for i := 1 to len(arr2)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(str(arr2[i,1],7)+put_val(arr2[i,2],12)+put_val(arr2[i,3],12)+;
                                  put_val(arr2[i,4],12)+put_val(arr2[i,5],12)+put_val(arr2[i,2]+arr2[i,3],12))
      for j := 2 to 5
        arr[j] += arr2[i,j]
      next
    next
    add_string(replicate("─",sh))
    add_string(" Итого:"+put_val(arr[2],12)+put_val(arr[3],12)+;
                         put_val(arr[4],12)+put_val(arr[5],12)+put_val(arr[2]+arr[3],12))
  endif
  fclose(fp)
  viewtext(name_file,,,,.t.,,,1)
endif
return NIL

***** 08.05.17 Создание файла для ЛИС в ГБУЗ "ВОМИАЦ" (письмо №1337 от 30.11.15г.)
Function create_DBF_for_LIS(par)
Local adbf := {;
   {"FAM"    ,   "C", 50,0},; // Ф. пациента
   {"IM"     ,   "C", 50,0},; // И. пациента
   {"OT"     ,   "C", 50,0},; // О. пациента
   {"POL"    ,   "C",  1,0},; // пол
   {"DATE_R"   , "C", 10,0},; // дата рождения пациента
   {"vid_ud",    "N",  2,0},; // вид удостоверения личности;по кодировке ФФОМС
   {"ser_ud",    "C", 10,0},; // серия удостоверения личности
   {"nom_ud",    "C", 20,0},; // номер удостоверения личности
   {"mesto_r",   "C",100,0},; // место рождения
   {"VPOLIS",    "N",  1,0},; // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый;по умолчанию 1 - старый
   {"SPOLIS",    "C", 10,0},; // серия полиса
   {"NPOLIS",    "C", 25,0},; // номер полиса
   {"OKATO"   ,  "C", 11,0},; //
   {"SNILS"  ,   "C", 14,0},;
   {"KOD_SMO",   "C",  5,0};  //
  }
Local i := 0, hGauge, n_file, arr_fio, fl_exit := .f.
DEFAULT par TO 1
if par == 2 // Создание файла для ЛИС из БД КДП2 (пациенты с кодом ЛИС и, возможно, изменёнными реквизитами)
  aadd(adbf, {"KOD_LIS",   "C", 10,0} )
endif
n_file := "L"+glob_mo[_MO_KOD_TFOMS]
dbcreate(n_file,adbf)
use (n_file) new alias TMP
hGauge := GaugeNew(,,,"Создание файла "+upper(n_file+sdbf),.t.)
GaugeDisplay( hGauge )
R_Use(dir_server+"mo_kfio",,"KFIO")
index on str(kod,7) to (cur_dir+"tmp_kfio")
R_Use_base("kartotek")
set order to 2
go top
do while !eof()
  GaugeUpdate( hGauge, ++i/lastrec() )
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if !kart2->(eof()) .and. iif(par == 1, kart2->mo_pr == glob_mo[_MO_KOD_TFOMS], !empty(int(val(kart2->kod_AK))))
    select TMP
    append blank
    arr_fio := retFamImOt(1,.f.,.t.)
    tmp->fam := f_s_csv(arr_fio[1])
    tmp->im  := f_s_csv(arr_fio[2])
    tmp->ot  := f_s_csv(arr_fio[3])
    tmp->POL := kart->pol                   // пол
    tmp->DATE_R := full_date(kart->date_r)  // дата рождения пациента
    tmp->mesto_r := f_s_csv(kart_->mesto_r) // место рождения
    tmp->OKATO := kart_->okatog
    tmp->KOD_SMO := kart_->smo
    tmp->vpolis := kart_->vpolis
    tmp->spolis := ltrim(kart_->SPOLIS)
    tmp->npolis := ltrim(kart_->NPOLIS)
    tmp->SNILS  := iif(empty(kart->SNILS),"",transform(kart->SNILS,picture_pf))
    tmp->vid_ud := kart_->vid_ud        // вид удостоверения личности по кодировке ФФОМС
    tmp->ser_ud := ltrim(kart_->ser_ud) // серия удостоверения личности
    tmp->nom_ud := ltrim(kart_->nom_ud) // номер удостоверения личности
    if par == 2
      tmp->KOD_LIS := kart2->kod_AK
    endif
    if tmp->(recno()) % 500 == 0
      commit
    endif
  endif
  select KART
  skip
enddo
i := tmp->(lastrec())
close databases
CloseGauge(hGauge)
if fl_exit
  func_error(4,"Операция прервана!")
elseif i  == 0
  func_error(4,"Некого включать в файл!")
else
  n_message({"В каталоге "+cur_dir+" создан файл "+upper(n_file+sdbf),;
             lstr(i)+" пациентов."},,;
            cColorSt2Msg,cColorStMsg,,,"G+/R")
endif
return NIL

*

***** 14.09.21
Function f0_prn_kartotek(par,nuch,nsmo)
Static si1 := 2
Local adbf := {;
   {"UCHAST" ,   "N",  2,0},; // номер участка
   {"KOD_VU" ,   "C", 10,0},; // код в участке
   {"FIO"    ,   "C", 50,0},; // Ф.И.О. больного
   {"POL"    ,   "C",  1,0},; // пол
   {"DATE_R"   , "C", 10,0},; // дата рождения больного
   {"VZROS_REB", "C",  9,0},; // 0-взрослый, 1-ребенок, 2-подросток
   {"mesto_r",   "C",100,0},; // место рождения;;
   {"OKATOR"  ,  "C", 11,0},; //
   {"ADRESR"  ,  "C",100,0},; // адрес больного
   {"OKATOP"  ,  "C", 11,0},; //
   {"ADRESP"  ,  "C",100,0},; // адрес больного
   {"MR_DOL" ,   "C", 50,0},; // место работы или причина безработности
   {"RABOTA" ,   "C", 12,0},; // {"RAB_NERAB","N",1,0}0-работ,1-нераб
   {"beg_polis", "C", 10,0},; // дата начала действия полиса ;в формате dtoc4();"поле ""beg_polis"" из файла ""k_inog"" для иногородних"
   {"end_polis", "C", 10,0},; // срок действия полиса
   {"VPOLIS",    "C",  6,0},; // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый;по умолчанию 1 - старый
   {"POLIS",     "C", 30,0},; // серия полиса;;для наших - разделить по пробелу
   {"KOD_SMO",   "C",  5,0},; //
   {"SMO",       "C", 80,0},; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
   {"SNILS"  ,   "C", 14,0},;
   {"vid_ud",    "C", 30,0},; // вид удостоверения личности;по кодировке ФФОМС;"PKRT_VID из ""APP_BASE"""
   {"ser_ud",    "C", 10,0},; // серия удостоверения личности;;"PKRT_SER из ""APP_BASE"""
   {"nom_ud",    "C", 20,0},; // номер удостоверения личности;;"PKRT_NOM из ""APP_BASE"""
   {"kemvyd",    "C",150,0},; // кем выдан документ - справочник "s_kemvyd"
   {"kogdavyd",  "C", 10,0},; // когда выдан документ;;"PKRT_KOGDA из ""APP_BASE"""
   {"PENSIONER", "C", 11,0},; // является пенсионером?;0-нет, 1-да;
   {"MO_PR",     "C",  6,0},; // код МО приписки
   {"MONAME_PR", "C", 60,0},; // наименование МО приписки
   {"DATE_PR"  , "C", 10,0},;  // дата приписки
   {"PHONE_H",   "C", 11,0},; // телефон домашний;;
   {"PHONE_M",   "C", 11,0},; // телефон мобильный;;
   {"PHONE_W",   "C", 11,0}; // телефон рабочий;;
  }
Local i := 0, hGauge, pr_uchast, n_file, fl_exit := .f.
Private mdate_r, m1vzros_reb := 0
do case
  case par == 1
    if (pr_uchast := popup_prompt(T_ROW,T_COL+5,si1,;
             {"Сортировка по ~Ф.И.О.","Сортировка по ~коду"})) == 0
      return NIL
    endif
    si1 := pr_uchast
    n_file := "uchast"+strzero(nuch,2)
    dbcreate(n_file,adbf)
    use (n_file) new alias TMP
    hGauge := GaugeNew(,,,"Создание файла "+upper(n_file+sdbf),.t.)
    GaugeDisplay( hGauge )
    //
    R_Use(dir_server+"s_kemvyd",,"SKEM")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    set relation to kemvyd into SKEM
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    if pr_uchast == 1 //по фио
      set index to (dir_server+"kartoten")
      //index on if(kod>0,"1","0")+upper(fio)+dtos(date_r) to (dir_server+"kartoten") progress
    else
      if is_uchastok == 1
        set index to (dir_server+"kartoteu")
        //index on strzero(uchast,2)+strzero(kod_vu,5) to (dir_server+"kartoteu") progress
      else
        set index to (dir_server+"kartotek")
        //index on str(kod,7) to (dir_server+"kartotek") progress
      endif
    endif
    select KART
    go top
    do while !eof()
      GaugeUpdate( hGauge, ++i/lastrec() )
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if kart->uchast == nuch
        select TMP
        append blank
        tmp->UCHAST := kart->UCHAST
        if is_uchastok == 1
          tmp->KOD_VU := ltrim(kart->BUKVA+lstr(kart->UCHAST)+"/"+lstr(kart->KOD_VU))
        elseif is_uchastok == 2
          tmp->KOD_VU := ltrim(kart->BUKVA+lstr(kart->UCHAST)+"/"+lstr(kart->KOD))
        else
          tmp->KOD_VU := ltrim(kart->BUKVA+"/"+lstr(kart->KOD))
        endif
        tmp->FIO        := kart->fio               // Ф.И.О. больного
        tmp->POL        := kart->pol               // пол
        tmp->DATE_R     := full_date(kart->date_r) // дата рождения больного
        mdate_r := kart->date_r
        fv_date_r(,.f.)
        tmp->VZROS_REB  := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
        tmp->mesto_r    := kart_->mesto_r // место рождения;;
        tmp->OKATOR     := kart_->okatog
        tmp->ADRESR     := ret_okato_ulica(kart->adres,kart_->okatog) // адрес больного
        tmp->OKATOP     := kart_->okatop
        tmp->ADRESP     := ret_okato_ulica(kart_->adresp,kart_->okatop) // адрес больного
        tmp->MR_DOL     := kart->MR_DOL // место работы или причина безработности
        tmp->RABOTA     := inieditspr(A__MENUVERT, menu_rab, kart->RAB_NERAB)
        tmp->beg_polis  := full_date(c4tod(kart_->beg_polis)) // дата начала действия полиса ;в формате dtoc4();"поле ""beg_polis"" из файла ""k_inog"" для иногородних"
        tmp->END_POLIS  := full_date(c4tod(kart->SROK_POLIS)) // срок действия полиса
        tmp->KOD_SMO    := kart_->smo
        tmp->SMO        := smo_to_screen(1)
        tmp->vpolis     := inieditspr(A__MENUVERT, mm_vid_polis, kart_->vpolis)
        tmp->polis      := ltrim(kart_->NPOLIS)
        tmp->SNILS      := iif(empty(kart->SNILS),"",transform(kart->SNILS,picture_pf))
        tmp->vid_ud     := inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud) // вид удостоверения личности;по кодировке ФФОМС;"PKRT_VID из ""APP_BASE"""
        tmp->ser_ud     := ltrim(kart_->ser_ud) // серия удостоверения личности;;"PKRT_SER из ""APP_BASE"""
        tmp->nom_ud     := ltrim(kart_->nom_ud) // номер удостоверения личности;;"PKRT_NOM из ""APP_BASE"""
        tmp->kemvyd     := skem->name
        tmp->kogdavyd   := full_date(kart_->kogdavyd)
        tmp->PENSIONER  := iif(kart_->PENSIONER==1,"пенсионер","")
        tmp->PHONE_H    := kart_->PHONE_H // телефон домашний;;
        tmp->PHONE_M    := kart_->PHONE_M // телефон мобильный;;
        tmp->PHONE_W    := kart_->PHONE_W // телефон рабочий;;
        if !empty(tmp->mo_pr := kart2->mo_pr)
          tmp->MONAME_PR := ret_mo(kart2->mo_pr)[_MO_SHORT_NAME]
          if !empty(kart2->pc4)
            tmp->DATE_PR := kart2->pc4
          else
            tmp->DATE_PR := full_date(kart2->DATE_PR)
          endif
        endif
        if tmp->(recno()) % 2000 == 0
          commit
        endif
      endif
      select KART
      skip
    enddo
    i := tmp->(lastrec())
    close databases
    CloseGauge(hGauge)
  case par == 2
    n_file := "smo"+nsmo
    dbcreate(n_file,adbf)
    use (n_file) new alias TMP
    hGauge := GaugeNew(,,,"Создание файла "+upper(n_file+sdbf),.t.)
    GaugeDisplay( hGauge )
    //
    R_Use(dir_server+"s_kemvyd",,"SKEM")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    set relation to kemvyd into SKEM
    R_Use(dir_server+"kartotek",dir_server+"kartoten","KART")
    set relation to recno() into KART_, to recno() into KART2
    go top
    do while !eof()
      GaugeUpdate( hGauge, ++i/lastrec() )
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if kart_->smo == nsmo
        select TMP
        append blank
        tmp->UCHAST := kart->UCHAST
        if is_uchastok == 1
          tmp->KOD_VU := ltrim(kart->BUKVA+lstr(kart->UCHAST)+"/"+lstr(kart->KOD_VU))
        elseif is_uchastok == 2
          tmp->KOD_VU := ltrim(kart->BUKVA+lstr(kart->UCHAST)+"/"+lstr(kart->KOD))
        else
          tmp->KOD_VU := ltrim(kart->BUKVA+"/"+lstr(kart->KOD))
        endif
        tmp->FIO        := kart->fio               // Ф.И.О. больного
        tmp->POL        := kart->pol               // пол
        tmp->DATE_R     := full_date(kart->date_r) // дата рождения больного
        mdate_r := kart->date_r
        fv_date_r(,.f.)
        tmp->VZROS_REB  := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
        tmp->mesto_r    := kart_->mesto_r // место рождения;;
        tmp->OKATOR     := kart_->okatog
        tmp->ADRESR     := ret_okato_ulica(kart->adres,kart_->okatog) // адрес больного
        tmp->OKATOP     := kart_->okatop
        tmp->ADRESP     := ret_okato_ulica(kart_->adresp,kart_->okatop) // адрес больного
        tmp->MR_DOL     := kart->MR_DOL // место работы или причина безработности
        tmp->RABOTA     := inieditspr(A__MENUVERT, menu_rab, kart->RAB_NERAB)
        tmp->beg_polis  := full_date(c4tod(kart_->beg_polis)) // дата начала действия полиса ;в формате dtoc4();"поле ""beg_polis"" из файла ""k_inog"" для иногородних"
        tmp->END_POLIS  := full_date(c4tod(kart->SROK_POLIS)) // срок действия полиса
        tmp->KOD_SMO    := kart_->smo
        tmp->SMO        := smo_to_screen(1)
        tmp->vpolis     := inieditspr(A__MENUVERT, mm_vid_polis, kart_->vpolis)
        tmp->polis      := ltrim(kart_->NPOLIS)
        tmp->SNILS      := iif(empty(kart->SNILS),"",transform(kart->SNILS,picture_pf))
        tmp->vid_ud     := inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud) // вид удостоверения личности;по кодировке ФФОМС;"PKRT_VID из ""APP_BASE"""
        tmp->ser_ud     := ltrim(kart_->ser_ud) // серия удостоверения личности;;"PKRT_SER из ""APP_BASE"""
        tmp->nom_ud     := ltrim(kart_->nom_ud) // номер удостоверения личности;;"PKRT_NOM из ""APP_BASE"""
        tmp->kemvyd     := skem->name
        tmp->kogdavyd   := full_date(kart_->kogdavyd)
        tmp->PENSIONER  := iif(kart_->PENSIONER==1,"пенсионер","")
        tmp->PHONE_H    := kart_->PHONE_H // телефон домашний;;
        tmp->PHONE_M    := kart_->PHONE_M // телефон мобильный;;
        tmp->PHONE_W    := kart_->PHONE_W // телефон рабочий;;
        if !empty(tmp->mo_pr := kart2->mo_pr)
          tmp->MONAME_PR := ret_mo(kart2->mo_pr)[_MO_SHORT_NAME]
          if !empty(kart2->pc4)
            tmp->DATE_PR := kart2->pc4
          else
            tmp->DATE_PR := full_date(kart2->DATE_PR)
          endif
        endif
        if tmp->(recno()) % 2000 == 0
          commit
        endif
      endif
      select KART
      skip
    enddo
    i := tmp->(lastrec())
    close databases
    CloseGauge(hGauge)
endcase
if fl_exit
  func_error(4,"Операция прервана!")
endif
n_message({"Создан файл "+upper(n_file+sdbf),;
           lstr(i)+" человек."})
return NIL

*

***** 09.09.15
Function pripisnoe_naselenie_view()
Local i, j, s, arr_mo := {}, n_file := "pr_nas"+stxt, ;
      sh := 80, HH := 60, buf := save_maxrow()
mywait()
R_use_base("kartotek")
go top
do while !eof()
  if (i := ascan(arr_mo, {|x| x[1] == kart2->mo_pr })) == 0
    aadd(arr_mo, {kart2->mo_pr,0,0}) ; i := len(arr_mo)
  endif
  arr_mo[i,2] ++
  if left(kart2->PC2,1) == "1"
    arr_mo[i,3] ++
  endif
  skip
enddo
close databases
asort(arr_mo,,,{|x,y| x[1] < y[1] })
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Состав картотеки (прикреплённое население)",sh))
add_string("──────┬──────┬──────┬───────────────────────────────────────────────────────────")
add_string("припи-│в т.ч.│      │                                                           ")
add_string("сано  │умерло│Код МО│ Наименование МО                                           ")
add_string("──────┴──────┴──────┴───────────────────────────────────────────────────────────")
for i := 1 to len(arr_mo)
  s := str(arr_mo[i,2],6)+put_val(arr_mo[i,3],7)+" "+arr_mo[i,1]+" "
  if (j := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == arr_mo[i,1]})) > 0
    s += glob_arr_mo[j,_MO_SHORT_NAME]
  else
    s += "не прикреплено к медицинской организации"
  endif
  verify_FF(HH, .t., sh)
  if arr_mo[i,1] == glob_MO[_MO_KOD_TFOMS]
    add_string(replicate("=",sh))
  endif
  add_string(s)
  if arr_mo[i,1] == glob_MO[_MO_KOD_TFOMS]
    add_string(replicate("=",sh))
  endif
next
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,5)
return NIL

*

***** 09.09.15 Просмотр/печать прикреплённого населения
Function spisok_pripisnoe_naselenie(par)
Static sj, smo := "      "
Local i, j, k, s, arr := {}, n_file := "pr_nas"+lstr(par)+stxt, ;
      ret_arr, sh := 81, HH := 80, buf := save_maxrow()
if empty(arr_mo)
  mywait()
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"kartote2",,"KART2")
  set relation to recno() into KART
  index on mo_pr to (cur_dir+"tmp_kart2") for !kart->(eof()) .and. kart->kod > 0
  go top
  do while !eof()
    if (i := ascan(arr_mo, {|x| x[2] == kart2->mo_pr })) == 0
      aadd(arr_mo, {"",kart2->mo_pr,0,0}) ; i := len(arr_mo)
    endif
    arr_mo[i,3] ++
    if left(kart2->PC2,1) == "1"
      arr_mo[i,4] ++
    endif
    skip
  enddo
  close databases
  for i := 1 to len(arr_mo)
    if (j := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == arr_mo[i,2]})) > 0
      arr_mo[i,1] := str(arr_mo[i,3],6)+" чел. "+arr_mo[i,2]+" "+glob_arr_mo[j,_MO_SHORT_NAME]
      if arr_mo[i,2] == glob_MO[_MO_KOD_TFOMS]
        aadd(arr,i)
      endif
    else
      aadd(arr_no,arr_mo[i,2])
      aadd(arr,i)
    endif
  next
  asort(arr)
  for i := len(arr) to 1 step -1
    del_array(arr_mo,arr[i])
  next
  asort(arr_mo,,,{|x,y| x[2] < y[2] })
  rest_box(buf)
endif
if (j := f_alert({"",;
                  "Выберите порядок сортировки выходного документа",;
                  ""},;
                 {" По ~ФИО "," По ~участку "},;
                 sj,"W/RB","G+/RB",18,,"BG+/RB,W+/R,W+/RB,GR+/R" )) == 0
  return NIL
endif
sj := j
mywait()
fl := .t.
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"kartote2",,"KART2")
set relation to recno() into KART
set index to (cur_dir+"tmp_kart2")
do case
  case par == 1
    find (glob_MO[_MO_KOD_TFOMS])
    index on iif(sj==1,"",str(kart->uchast,2))+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_kart") ;
          while kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
  case par == 2
    popup_2array(arr_mo,2,2,smo,1,@ret_arr,"Выбор МО прикрепления","B/BG")
    if valtype(ret_arr) == "A"
      smo := ret_arr[2]
      find (ret_arr[2])
      index on iif(sj==1,"",str(kart->uchast,2))+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_kart") ;
            while kart2->mo_pr == ret_arr[2]
    else
      fl := .f.
    endif
  case par == 3
    index on iif(sj==1,"",str(kart->uchast,2))+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_kart") ;
          for !kart->(eof()) .and. kart->kod > 0 .and. ascan(arr_no,kart2->mo_pr) > 0
endcase
if fl
  arr_title := {;
"──┬──────────────────────────────────────────────────┬──────────┬──────────────────────────────────────────────────┬──────────",;
"Уч│                    Ф.И.О                         │Дата рожд.│                      Адрес                       │Прикреплен",;
"──┴──────────────────────────────────────────────────┴──────────┴──────────────────────────────────────────────────┴──────────"}
  sh := len(arr_title[1])
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  do case
    case par == 1
      add_string(center("Состав картотеки (прикреплённые к нашей МО)",sh))
    case par == 2
      add_string(center("Состав картотеки (прикреплённые к "+substr(ret_arr[1],13)+")",sh))
    case par == 3
      add_string(center("Состав картотеки (не прикреплённые ни к одной МО)",sh))
  endcase
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  k := k1 := 0
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(put_val(kart->uchast,2)+" "+;
               iif(left(kart2->PC2,1)=="1", padr(kart->fio,45)+" УМЕР", padr(kart->fio,50))+" "+;
               full_date(kart->date_r)+" "+padr(kart->adres,50)+" "+;
               iif(par==3, "", iif(empty(kart2->pc4),full_date(kart2->DATE_PR),alltrim(kart2->pc4))))
    ++k
    if left(kart2->PC2,1)=="1"
      ++k1
    endif
    skip
  enddo
  add_string(replicate("-",sh))
  add_string("Итого: "+lstr(k)+" чел. (в т.ч. умерло - "+lstr(k1)+")")
  fclose(fp)
  viewtext(n_file,,,,.t.,,,6)
endif
close databases
rest_box(buf)
return NIL

*

***** 13.07.15
Function pripisnoe_naselenie(k)
Static si1 := 1, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j, r, nuch, nsmo
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Просмотр ~файлов прикрепления",;
                "~Подготовка и создание файлов прикрепления",;
                "Печать ~заявления на прикрепление",;
                "Создание файла ~сверки с ТФОМС",;
                "~Редактирование участков списком",;
                "~Импорт WQ2...DBF, простановка участков, отправка"}
    mas_msg := {"Просмотр файлов прикрепления (и ответов на них), запись файлов для ТФОМС",;
                "Подготовка файлов прикрепления и создание их для отправки в ТФОМС",;
                "Печать заявления на прикрепление по пациенту, ещё не прикреплённому к Вашей МО",;
                "Создание файла сверки с ТФОМС по прикреплённому населению (письмо № 04-18-20)",;
                "Редактирование номера участка для выбранного списка пациентов",;
                "Импорт DBF-файла из ТФОМС, простановка участков, создание файла прикрепления"}
    mas_fun := {"pripisnoe_naselenie(11)",;
                "pripisnoe_naselenie(12)",;
                "pripisnoe_naselenie(13)",;
                "pripisnoe_naselenie(14)",;
                "pripisnoe_naselenie(15)",;
                "pripisnoe_naselenie(16)"}
    if T_ROW > 8
      r := T_ROW-len(mas_pmt)-3
    else
      r := T_ROW
    endif
    popup_prompt(r,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    view_reestr_pripisnoe_naselenie()
  case k == 12
    preparation_for_pripisnoe_naselenie()
  case k == 13
    kartoteka_z_prikreplenie()
  case k == 14
    if tip_polzovat == TIP_ADM
      str_sem := "Создание файла сверки с ТФОМС"
      if G_SLock(str_sem)
        pripisnoe_naselenie_create_SVERKA()
        G_SUnLock(str_sem)
      else
        func_error(4,err_slock)
      endif
    else
      func_error(4,err_admin)
    endif
  case k == 15
    edit_uchast_spisok()
  case k == 16 // Импорт WQ2...DBF
    mas_pmt := {"~Импорт WQ2...ZIP",;
                "~Просмотр последнего импортированного файла",;
                "Редактирование ~участков",;
                "~Создание файлов прикрепления"}
    mas_msg := {"Импорт нового файла WQ2...ZIP (после всех операций с предыдущим прочитанным)",;
                "Просмотр прикреплённым к нашему МО пациентов, присланных в последнем файле",;
                "Редактирование участков пациентам, присланным в последнем файле",;
                "Создание файла прикрепления из пациентов последнего файла WQ... для отправки"}
    mas_fun := {"pripisnoe_naselenie(31)",;
                "pripisnoe_naselenie(32)",;
                "pripisnoe_naselenie(33)",;
                "pripisnoe_naselenie(34)"}
    popup_prompt(T_ROW-3-len(mas_pmt),T_COL+5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 21
    spisok_pripisnoe_naselenie(1)
  case k == 22
    spisok_pripisnoe_naselenie(2)
  case k == 23
    spisok_pripisnoe_naselenie(3)
  case k == 31
    wq_import()
  case k == 32
    wq_view()
  case k == 33
    wq_edit_uchast()
  case k == 34
    wq_prikreplenie()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si2 := j
  endif
endif
return NIL

*

***** 11.03.13
Function view_reestr_pripisnoe_naselenie()
Local buf := savescreen()
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_krtf",,"KRTF")
G_Use(dir_server+"mo_krtr",,"KRTR")
index on dtos(dfile) to (cur_dir+"tmp_krtr") DESCENDING
go top
if eof()
  func_error(4,"Нет составленных файлов прикрепления")
else
  Alpha_Browse(T_ROW,0,23,79,"f1_view_r_pr_nas",color0,,,,,,,;
               "f2_view_r_pr_nas",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
restscreen(buf)
return NIL

***** 14.07.15
Function f1_view_r_pr_nas(oBrow)
Local oColumn, ;
      blk := {|_s| _s := goal_dir+alltrim(krtr->FNAME), ;
                   iif(hb_fileExists(_s+scsv) .or. hb_fileExists(_s+szip), ;
                     iif(empty(krtr->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew("Дата файла",{|| full_date(krtr->dfile) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во;пац-ов", {|| str(krtr->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(krtr->FNAME,20) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_view_r_pr_nas() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Ответ;получен", {|| padc(iif(krtr->ANSWER==1,"да",""),7) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Прикре;плено", {|| put_val(krtr->kol_p,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" WQ", {|| krtr->wq })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<F5>^ - запись для ТФОМС;  ^<F3>^ - информация о файле прикрепления")
return NIL

***** 03.11.14
Static Function f11_view_r_pr_nas()
Local s := ""
if !(hb_fileExists(goal_dir+alltrim(krtr->FNAME)+scsv) .or. ;
         hb_fileExists(goal_dir+alltrim(krtr->FNAME)+szip))
  krtf->(dbGoto(krtr->kod_f))
  if empty(krtf->TWORK2)
    s := "не завершён"
  else
    s := "нет файла"
  endif
elseif empty(krtr->date_out)
  s := "не записан"
else
  s := "зап. "+lstr(krtr->NUMB_OUT)+" раз"
endif
return padr(s,11)

*

***** 24.03.15
Function f2_view_r_pr_nas(nKey,oBrow)
Local pss := space(10), tmp_pss := my_parol()
Local ret := -1, rec := krtr->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
krtf->(dbGoto(krtr->kod_f))
do case
  case nKey==K_CTRL_F10 .and. eq_any(krtf->TIP_OUT,_CSV_FILE_REESTR,_CSV_FILE_SVERKAZ) .and. krtr->ANSWER==0
    pss := get_parol(,,,,,"N/W","W/N*")
    if lastkey() == K_ENTER .and. ascan(tmp_pss, crypt(pss,gpasskod)) > 0 ;
                                  .and. f_Esc_Enter("аннулирования файла",.t.)
      krtf->(dbGoto(krtr->kod_f))
      zip_file := alltrim(krtr->FNAME)+iif(krtf->TIP_OUT==_CSV_FILE_REESTR,scsv,szip)
      str_sem := "f2_view_r_pr_nas_K_CTRL_F12"
      if G_SLock(str_sem)
        mywait()
        i := 0
        Use (dir_server+"mo_krtp") new alias KRTP
        index on str(reestr,6) to (cur_dir+"tmp_k")
        do while .t.
          @ maxrow(),0 say str(i/krtr->KOL*100,6,2)+"%" color cColorWait
          find (str(krtr->KOD,6))
          if !found() ; exit ; endif
          DeleteRec(.t.)
          if ++i % 5000 == 0
            Commit
          endif
        enddo
        Commit
        pack
        krtp->(dbCloseArea())
        select KRTF
        DeleteRec()
        select KRTR
        DeleteRec()
        delete file (goal_dir+zip_file)
        G_SUnLock(str_sem)
        stat_msg("Файл успешно аннулирован!") ; mybell(2,OK)
        return 1
      endif
    endif
  case nKey == K_CTRL_F12
    if empty(krtf->TWORK2) // не дописан
      zip_file := alltrim(krtr->FNAME)+iif(krtf->TIP_OUT==_CSV_FILE_REESTR,scsv,szip)
      if krtr->ANSWER > 0
        func_error(4,"Ответ для данного файла уже был прочитан - аннулирование запрещено!")
      elseif hb_fileExists(goal_dir+zip_file)
        func_error(4,"Данный файл уже создан в целевом каталоге - аннулирование запрещено!")
      elseif f_Esc_Enter("аннулирования файла",.t.)
        str_sem := "f2_view_r_pr_nas_K_CTRL_F12"
        if G_SLock(str_sem)
          mywait()
          i := 0
          Use (dir_server+"mo_krtp") new alias KRTP
          index on str(reestr,6) to (cur_dir+"tmp_k")
          do while .t.
            @ maxrow(),0 say str(i/krtr->KOL*100,6,2)+"%" color cColorWait
            find (str(krtr->KOD,6))
            if !found() ; exit ; endif
            DeleteRec(.t.)
            if ++i % 5000 == 0
              Commit
            endif
          enddo
          Commit
          pack
          krtp->(dbCloseArea())
          select KRTF
          DeleteRec()
          select KRTR
          DeleteRec()
          delete file (goal_dir+zip_file)
          G_SUnLock(str_sem)
          stat_msg("Файл успешно аннулирован!") ; mybell(2,OK)
          return 1
        endif
      endif
    else
      func_error(4,"Данный файл аннулировать запрещено!")
    endif
  case nKey == K_F5
    if f_Esc_Enter("записи файла за "+date_8(krtr->dfile))
      Private p_var_manager := "copy_schet"
      s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
      if !empty(s)
        if upper(s) == upper(goal_dir)
          func_error(4,"Вы выбрали каталог, в котором уже записан данный файл! Это недопустимо.")
        else
          zip_file := alltrim(krtr->FNAME)+iif(left(krtr->FNAME,2)=="MO",scsv,szip)
          if hb_fileExists(goal_dir+zip_file)
            mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
            //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
            copy file (goal_dir+zip_file) to (s+zip_file)
            //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
            if hb_fileExists(s+zip_file)
              krtr->(G_RLock(forever))
              krtr->DATE_OUT := sys_date
              if krtr->NUMB_OUT < 99
                krtr->NUMB_OUT ++
              endif
              //
              krtf->(dbGoto(krtr->kod_f))
              krtf->(G_RLock(forever))
              krtf->DREAD := sys_date
              krtf->TREAD := hour_min(seconds())
            else
              func_error(4,"Ошибка записи файла "+s+zip_file)
            endif
          else
            func_error(4,"Не обнаружен файл "+goal_dir+zip_file )
          endif
          UnLock
          Commit
          stat_msg("Запись завершена!") ; mybell(2,OK)
        endif
      endif
    endif
    select KRTR
    ret := 0
  case nKey == K_F3
    f3_view_r_pr_nas(oBrow)
    ret := 0
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

*

***** 24.10.18
Function f3_view_r_pr_nas(oBrow)
Static si := 1, snfile := "", sarr_mo, sarr_err, sjmo, sjerr
Local i, j, r := row(), r1, r2, buf := save_maxrow(), fl := .f., ii,;
      mm_func := {-1}, mm_menu
Private fl_csv := .f., mm_err := {}
if krtf->TIP_OUT == _CSV_FILE_SVERKAZ
  mm_err := {{'Не имеет текущего страхования',708},; // !!!
             {'Прикрепление к МО отсутствует',709},; //
             {'ТФОМС не вернул никакой информации',-99}} // !!!
endif
if left(krtr->FNAME,2) == "MO"
  fl_csv := .t.
  mm_menu := {"~Список пациентов в файле прикрепления"}
  if krtr->ANSWER == 1
    aadd(mm_func, -2) ; aadd(mm_menu, "Список ~прикреплённых пациентов")
    aadd(mm_func, -3) ; aadd(mm_menu, "Список ~не прикреплённых пациентов")
  endif
else
  mm_menu := {"~Список пациентов в файле сверки"}
  if !(snfile == alltrim(krtr->FNAME))
    fl := .t.
    snfile := alltrim(krtr->FNAME)
    sarr_mo := {} ; sjmo := 1
    sarr_err := {} ; sjerr := 1
  endif
endif
mywait()
select KRTF
index on FNAME to (cur_dir+"tmp_krtf") for reestr==krtr->kod .and. empty(TIP_OUT)
go top
do while !eof()
  aadd(mm_func, krtf->kod)
  aadd(mm_menu, "Протокол ~чтения "+rtrim(krtf->FNAME)+iif(empty(krtf->TWORK2),"-ЧТЕНИЕ НЕ ЗАВЕРШЕНО",""))
  skip
enddo
select KRTF
set index to
if !fl_csv .and. krtr->ANSWER == 1
  aadd(mm_func, -2) ; aadd(mm_menu, "Список пациентов, прикреплённых к ~нашей МО")
  aadd(mm_func, -4) ; aadd(mm_menu, "Список пациентов, прикреплённых к ~другим МО")
  aadd(mm_func, -3) ; aadd(mm_menu, "Список вернувшихся из ТФОМС с кодом ~ошибки")
  if fl
    ii := 0
    R_Use(dir_server+"mo_krte",,"KRTE")
    index on str(rees_zap,6) to (cur_dir+"tmp_krte") for reestr == krtr->kod
    R_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
    R_Use(dir_server+"mo_krtp",,"KRTP")
    index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == krtr->kod
    go top
    do while !eof()
      @ maxrow(),0 say str(++ii/krtr->kol*100,6,2)+"%" color cColorWait
      if empty(md_prik := krtp->D_PRIK1)
        if empty(md_prik := krtp->D_PRIK)
          md_prik := krtr->DFILE // для совместимости со старой версией
        endif
      endif
      select KRTE
      find (str(krtp->REES_ZAP,6))
      do while krtp->REES_ZAP == krte->REES_ZAP .and. !eof()
        if ascan(sarr_err,krte->REFREASON) == 0
          aadd(sarr_err,krte->REFREASON)
        endif
        skip
      enddo
      if krtp->OPLATA == 3
        select KARTP
        find (str(krtp->KOD_K,7)+dtos(md_prik))
        if found() .and. ascan(sarr_mo,kartp->MO_PR) == 0
          aadd(sarr_mo,kartp->MO_PR)
        endif
      endif
      select KRTP
      skip
    enddo
    krte->(dbCloseArea())
    kartp->(dbCloseArea())
    krtp->(dbCloseArea())
    asort(sarr_err)
    for j := 1 to len(sarr_err)
      if ascan(mm_err,{|x| x[2] == sarr_err[j]}) > 0
        sarr_err[j] := str(sarr_err[j],3)+" "+inieditspr(A__MENUVERT,mm_err,sarr_err[j])
      else
        sarr_err[j] := str(sarr_err[j],3)+" "+inieditspr(A__MENUVERT,mm_err_csv_prik,sarr_err[j])
      endif
    next
    asort(sarr_mo)
    for j := 1 to len(sarr_mo)
      sarr_mo[j] += " "+ret_mo(sarr_mo[j])[_MO_SHORT_NAME]
    next
  endif
endif
if r <= 12
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
rest_box(buf)
if len(mm_menu) == 1
  i := 1
else
  i := popup_prompt(r1,10,si,mm_menu,,,color5)
endif
if i > 0
  si := i
  if mm_func[i] < 0
    if !fl_csv .and. mm_func[i] == -4
      if !empty(sarr_mo)
        if r <= 12
          r1 := r+1 ; r2 := r1+len(sarr_mo)+1
          if r2 > maxrow()-2
            r2 := maxrow()-2
          endif
        else
          r2 := r-1 ; r1 := r2-len(sarr_mo)-1
          if r1 < 2
            r1 := 2
          endif
        endif
        do while (j := popup_SCR(r1,10,r2,77,sarr_mo,sjmo,color5,.t.,,,;
                         'Выберите, к какому МО прикреплён пациент',"B/W")) > 0
          sjmo := j
          f31_view_r_pr_nas(abs(mm_func[i]),mm_menu[i],sarr_mo[j])
        enddo
      endif
    elseif !fl_csv .and. mm_func[i] == -3
      if !empty(sarr_err)
        if r <= 12
          r1 := r+1 ; r2 := r1+len(sarr_err)+1
          if r2 > maxrow()-2
            r2 := maxrow()-2
          endif
        else
          r2 := r-1 ; r1 := r2-len(sarr_err)-1
          if r1 < 2
            r1 := 2
          endif
        endif
        do while (j := popup_SCR(r1,10,r2,77,sarr_err,sjerr,color5,.t.,,,;
                         'Выберите код ошибки возврата из ТФОМС',"B/W")) > 0
          sjerr := j
          f31_view_r_pr_nas(abs(mm_func[i]),mm_menu[i],sarr_err[j])
        enddo
      endif
    else
      f31_view_r_pr_nas(abs(mm_func[i]),mm_menu[i])
    endif
  else
    krtf->(dbGoto(mm_func[i]))
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(krtf->FNAME)+stxt,60,80),,,,.t.,,,2)
  endif
endif
select KRTR
return NIL

***** 04.11.14
Function f31_view_r_pr_nas(reg,s,s1)
Local fl := .t., buf := save_maxrow(), n_file := "prikspis"+stxt, lmo, lerr, ;
      i, j, k, ii, ar[2]
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center(charrem("~",s),80))
if fl_csv
  add_string(center("( файл прикрепления от "+full_date(krtr->dfile)+" )",80))
else
  DEFAULT s1 TO ""
  s1 := alltrim(s1)
  add_string(center("( файл сверки от "+full_date(krtr->dfile)+" )",80))
  if reg == 4
    lmo := left(s1,6)
    add_string(center(charone('"','Список прикреплённых к "'+s1+'"'),80))
  elseif reg == 3
    lerr := int(val(s1))
    for i := 1 to perenos(ar,'Список вернувшихся из ТФОМС с ошибкой "'+s1+'"',80)
      add_string(center(alltrim(ar[i]),80))
    next
  endif
endif
add_string("")
R_Use(dir_server+"mo_krte",,"KRTE")
if reg == 3 .or. !fl_csv
  index on str(rees_zap,6) to (cur_dir+"tmp_krte") for reestr == krtr->kod
endif
// список прикреплений по пациенту во времени
R_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
R_Use(dir_server+"kartote2",,"KART2")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART2
R_Use(dir_server+"mo_krtp",,"KRTP")
set relation to kod_k into KART
index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == krtr->kod
ii := k := 0
go top
do while !eof()
  @ maxrow(),0 say str(++ii/krtr->kol*100,6,2)+"%" color cColorWait
  if empty(md_prik := krtp->D_PRIK1)
    if empty(md_prik := krtp->D_PRIK)
      md_prik := krtr->DFILE // для совместимости со старой версией
    endif
  endif
  fl := .f.
  do case
    case reg == 1
      fl := .t.
    case reg == 2
      fl := (krtp->OPLATA == 1)
    case reg == 3 .and. fl_csv
      fl := (krtp->OPLATA == 2)
    case reg == 3 .and. !fl_csv
      select KRTE
      find (str(krtp->REES_ZAP,6))
      do while krtp->REES_ZAP == krte->REES_ZAP .and. !eof()
        if lerr == krte->REFREASON
          fl := .t. ; exit
        endif
        skip
      enddo
    case reg == 4
      if krtp->OPLATA == 3
        select KARTP
        find (str(krtp->KOD_K,7)+dtos(md_prik))
        fl := found() .and. lmo == kartp->MO_PR
      endif
  endcase
  if fl
    ++k
    s := lstr(krtp->REES_ZAP)+". "+alltrim(kart->fio)+;
         " (д.р."+full_date(kart->date_r)+") "
    if reg == 1
      if fl_csv
        s += "заказ на прикрепление с "+date_8(md_prik)
      endif
    elseif krtp->OPLATA == 2 .and. !empty(kart2->MO_PR)
      if kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
        s += 'ранее прикреплён к Вашей МО'
      else
        s += 'ранее прикреплён к '+ret_mo(kart2->MO_PR)[_MO_SHORT_NAME]
      endif
    elseif eq_any(krtp->OPLATA,1,3) //    reg == 2
      s += "ПРИКРЕПЛ"+iif(kart->pol=="М","ЁН","ЕНА")+" с "+date_8(md_prik)
    endif
    verify_FF(60,.t.,80)
    add_string(s)
    if reg == 3 .and. fl_csv
      select KRTE
      find (str(krtp->REES_ZAP,6))
      do while krtp->REES_ZAP == krte->REES_ZAP .and. !eof()
        s := space(len(lstr(krtp->REES_ZAP))+2)+lstr(krte->REFREASON)+" "+;
             inieditspr(A__MENUVERT,mm_err_csv_prik,krte->REFREASON)
        verify_FF(60,.t.,80)
        add_string(s)
        skip
      enddo
    endif
  endif
  select KRTP
  skip
enddo
if reg == 3 .and. !fl_csv
  add_string("=== Итого пациентов - "+lstr(k)+" чел.")
endif
krte->(dbCloseArea())
kartp->(dbCloseArea())
kart2->(dbCloseArea())
kart->(dbCloseArea())
krtp->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

*

***** 03.09.15
Function preparation_for_pripisnoe_naselenie()
Local i, j, k, aerr, buf := savescreen(), blk, t_arr[BR_LEN], cur_year,;
      str_sem := "preparation_for_pripisnoe_naselenie"
mywait()
G_Use(dir_server+"mo_krtp",,"KRTP")
index on kod_k to (cur_dir+"tmp_k") for reestr == 0
dbcreate(cur_dir+"tmp_krtp",{;
  {"rec",   "N",8,0},; // номер записи в файле "mo_krtp"
  {"uchast","N",2,0},; // участок
  {"D_PRIK","D",8,0},; // дата прикрепления
  {"S_PRIK","N",1,0},; // способ прикрепления: 1-по месту регистрации, 2-по личному заявлению, 3-
  {"KOD_K", "N",7,0};  // код пациента по файлу "kartotek"
 })
use (cur_dir+"tmp_krtp") new
use_base("kartotek")
set order to 0
select KRTP
go top
do while !eof()
  if empty(krtp->d_prik)
    G_RLock(forever)
    krtp->d_prik := sys_date
    UnLock
  endif
  kart->(dbGoto(krtp->kod_k))
  select TMP_KRTP
  append blank
  tmp_krtp->rec := krtp->(recno())
  tmp_krtp->kod_k := krtp->kod_k
  tmp_krtp->uchast := kart->uchast
  tmp_krtp->s_prik := krtp->s_prik
  tmp_krtp->d_prik := krtp->d_prik
  select KRTP
  skip
enddo
commit
select KRTP
index on str(reestr,6) to (cur_dir+"tmp_k")
select TMP_KRTP
set relation to kod_k into KART
index on str(kod_k,7) to (cur_dir+"tmp_krtp")
index on upper(kart->fio)+dtos(kart->date_r)+str(kod_k,7) to (cur_dir+"tmp2krtp")
set index to (cur_dir+"tmp2krtp"),(cur_dir+"tmp_krtp")
go top
restscreen(buf)
if lastrec() == 0 .and. ;
   f_alert({"В данный момент не отмечено ни одного пациента",;
            "для прикрепления",""},;
           {" Отказ "," Начать подготовку файла прикрепления "},;
           1,"N+/G*","N/G*",maxrow()-8,,"N/G*") != 2
  close databases
  return NIL
endif
if !G_SLock(str_sem)
  close databases
  return func_error(4,"В данный момент с этим режимом работает другой пользователь.")
endif
Private tr := T_ROW
box_shadow(tr-4,47,tr-2,77,"B/W*")
t_arr[BR_TOP] := tr
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color5
t_arr[BR_TITUL] := "Подготовка файла прикрепления"
t_arr[BR_TITUL_COLOR] := "B/W"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/W,W+/N,B/W,W+/B,RB/W,W+/RB",.t.,72}
blk := {|| iif(kart->uchast > 0, iif(tmp_krtp->s_prik==2,{1,2},{3,4}), {5,6}) }
Private arr_prik := {{"по месту регистрации",1},;
                     {"лич/з-е без изм. м/ж",2},;
                     {"лич/з-е с измен. м/ж",3}}
Private arr_prik1 := {{"по личному заявлению (без изменения места жительства)",2},;
                      {"по личному заявлению (в связи с изменением места жительства)",3}}
t_arr[BR_COLUMN] := {{ center("Ф.И.О.",32),{|| left(kart->fio,32) }, blk },;
                     {"   Дата; рождения", {|| full_date(kart->date_r) }, blk },;
                     {"Уч", {|| str(kart->uchast) }, blk },;
                     {"   Дата; заявления", {|| full_date(tmp_krtp->d_prik) }, blk },;
                     {"Способ прикрепления", {|| padr(inieditspr(A__MENUVERT,arr_prik,tmp_krtp->s_prik),20) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ ред-ние даты и способа/просмотр ^<Ins>^ добавить ^<Del>^ удалить") }
t_arr[BR_STEP_FUNC] := {|| f3_p_f_prikreplenie() }
t_arr[BR_EDIT] := {|nk,ob| f1_p_f_prikreplenie(nk,ob,"edit") }
if lastrec() == 0
  keyboard chr(K_INS)
endif
edit_browse(t_arr)
restscreen(buf)
if tmp_krtp->(lastrec()) > 0
  mywait()
  cur_year := year(sys_date)
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  go bottom
  if !empty(human->k_data)
    cur_year := year(human->k_data)
  endif
  Use
  cFileProtokol := "prot"+stxt
  strfile(space(10)+"Список ошибок"+hb_eol()+hb_eol(),cFileProtokol)
  ii := i := 0
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"mo_pers",,"P2")
  R_Use(dir_server+"mo_uchvr",,"UV")
  index on str(uch,2) to (cur_dir+"tmp_uv")
  select TMP_KRTP
  go top
  do while !eof()
    ++ii
    aerr := {}
    if empty(kart->date_r)
      aadd(aerr,'не заполнено поле "Дата рождения"')
    elseif kart->date_r >= sys_date
      aadd(aerr,'дата рождения больше сегодняшней даты')
    elseif year(kart->date_r) < 1900
      aadd(aerr, "дата рождения: "+full_date(kart->date_r)+" ( < 1900г.)")
    endif
    if kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
      aadd(aerr,'данный пациент уже прикреплён к Вашей МО с '+;
                iif(empty(kart2->pc4),full_date(kart2->DATE_PR),alltrim(kart2->pc4))+"г.")
    endif
    if empty(tmp_krtp->uchast)
      aadd(aerr,'не заполнено поле "Номер участка"')
    else
      select UV
      find (str(tmp_krtp->uchast,2))
      if found() .and. !emptyall(uv->vrach,uv->vrachv,uv->vrachd)
        if count_years(kart->date_r,sys_date) < 18 // дети
          if emptyall(uv->vrach,uv->vrachd)
            aadd(aerr,"на участке "+lstr(kart->uchast)+" не привязан участковый врач к детям")
          else
            if !empty(uv->vrach)
              p2->(dbGoto(uv->vrach))
            else
              p2->(dbGoto(uv->vrachd))
            endif
            f1_p_f_pripisnoe_naselenie(aerr)
          endif
        else
          if emptyall(uv->vrach,uv->vrachv)
            aadd(aerr,"на участке "+lstr(kart->uchast)+" не привязан участковый врач к взрослым")
          else
            if !empty(uv->vrach)
              p2->(dbGoto(uv->vrach))
            else
              p2->(dbGoto(uv->vrachv))
            endif
            f1_p_f_pripisnoe_naselenie(aerr)
          endif
        endif
      else
        aadd(aerr,"к участку "+lstr(kart->uchast)+" не привязан участковый врач")
      endif
    endif
    Valid_SN_Polis(kart_->vpolis,kart_->SPOLIS,kart_->NPOLIS,aerr,between(kart_->smo,'34001','34007'))
    if ascan(menu_vidud,{|x| x[2] == kart_->vid_ud }) == 0
      aadd(aerr,'не заполнено поле "ВИД удостоверения личности"')
    else
      if empty(kart_->nom_ud)
        aadd(aerr,'должно быть заполнено поле "НОМЕР удостоверения личности"')
      elseif !ver_number(kart_->nom_ud)
        aadd(aerr,'поле "НОМЕР удостоверения личности" должно быть цифровым')
      endif
      if !empty(kart_->nom_ud)
        s := space(80)
        if !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud,@s)
          aadd(aerr,s)
        endif
      endif
      if eq_any(kart_->vid_ud,1,3,14) .and. empty(kart_->ser_ud)
        aadd(aerr,'не заполнено поле "СЕРИЯ удостоверения личности"')
      endif
      if eq_any(kart_->vid_ud,3,14) .and. empty(del_spec_symbol(kart_->mesto_r))
        aadd(aerr,iif(kart_->vid_ud==3,'для свид-ва о рождении','для паспорта РФ')+;
                                       ' обязательно заполнение поля "Место рождения"')
      endif
      if !empty(kart_->ser_ud)
        s := space(80)
        if !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud,@s)
          aadd(aerr,s)
        endif
      endif
    endif
    if !empty(kart_->kogdavyd) .and. kart_->kogdavyd < kart->date_r
      aadd(aerr,'дата выдачи документа, удостоверяющего личность, меньше даты рождения')
    endif
    val_fio(retFamImOt(1,.f.),aerr)
    if !empty(kart->snils)
      s := space(80)
      if !val_snils(kart->snils,2,@s)
        aadd(aerr,s)
      endif
    endif
    select KRTP
    goto (tmp_krtp->rec)
    if !eq_any(krtp->S_PRIK,1,2,3)
      aadd(aerr,'неверный способ прикрепления')
    endif
    if empty(krtp->D_PRIK)
      aadd(aerr,'не заполнено поле "Дата заявления"')
    elseif krtp->D_PRIK > sys_date
      aadd(aerr,'дата заявления больше сегодняшней даты')
    elseif year(krtp->D_PRIK) < cur_year
      aadd(aerr, "дата заявления: "+full_date(krtp->D_PRIK)+" - прошлый год")
    endif
    if !empty(aerr)
      strfile(lstr(++i)+". "+alltrim(kart->fio)+" "+full_date(kart->date_r)+hb_eol(),cFileProtokol,.t.)
      aeval(aerr,{|x| strfile(" - "+x+hb_eol(),cFileProtokol,.t.) })
    endif
    select TMP_KRTP
    skip
  enddo
  j := tmp_krtp->(lastrec())
  close databases
  restscreen(buf)
  k := 1
  if i > 0
    viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
  else
    k := f_alert({"В данный момент отмечено "+lstr(ii)+" пациентов для прикрепления",;
                  ""},;
                 {" Отказ "," Создать файл прикрепления "},;
                 1,"N+/GR*","N/GR*",maxrow()-7,,"N/GR*")
  endif
  j := 0
  if k == 2
    k := f_alert({padc("Выберите, каким образом создавать файл прикрепления",70,"."),;
                  ""},;
                 {" Только по заявлению "," Включать пациентов с изменением № участка "},;
                 1,"N+/G*","N/G*",maxrow()-7,,"N/G*")
    if k == 1
      k := 2
    elseif k == 2
      if (k := find_change_snils(@j)) == 3
        k := f_alert({padc("Выберите, каким образом создавать файл прикрепления",70,"."),;
                      ""},;
                     {" Только по заявлению "," Включить "+lstr(j)+" пациентов с изменением уч-ка "},;
                     1,"N+/G*","N/G*",maxrow()-7,,"N/G*")
        if k == 1
          k := 2 ; j := 0
        elseif k == 2
          k := 3
        endif
      endif
    endif
  endif
  if k > 1
    s := "MO2"
    G_Use(dir_server+"mo_krtr",,"KRTR")
    Locate for DFILE == sys_date .and. left(FNAME,3) == s
    if found()
      func_error(4,"Файл прикрепления с датой "+full_date(sys_date)+"г. уже был создан")
    elseif f_Esc_Enter("создания файла прикрепления",.t.)
      mywait()
      s += glob_mo[_MO_KOD_TFOMS]+dtos(sys_date)
      n_file := s+scsv
      R_Use(exe_dir+"_mo_podr",cur_dir+"_mo_podr","PODR")
      find (glob_mo[_MO_KOD_TFOMS])
      loidmo := alltrim(podr->oidmo)
      select KRTR
      index on str(kod,6) to (cur_dir+"tmp_krtr")
      AddRec(6)
      krtr->KOD := recno()
      krtr->FNAME := s
      krtr->DFILE := sys_date
      krtr->DATE_OUT := ctod("")
      krtr->NUMB_OUT := 0
      krtr->KOL := ii+j
      krtr->KOL_P := 0
      krtr->ANSWER := 0  // 0-не было ответа, 1-был прочитан ответ
      G_Use(dir_server+"mo_krtf",,"KRTF")
      index on str(kod,6) to (cur_dir+"tmp_krtf")
      AddRec(6)
      krtf->KOD   := recno()
      krtf->FNAME := krtr->FNAME
      krtf->DFILE := krtr->DFILE
      krtf->TFILE := hour_min(seconds())
      krtf->TIP_IN := 0
      krtf->TIP_OUT := _CSV_FILE_REESTR
      krtf->REESTR := krtr->KOD
      krtf->DWORK := sys_date
      krtf->TWORK1 := hour_min(seconds()) // время начала обработки
      krtf->TWORK2 := ""                  // время окончания обработки
      //
      krtr->KOD_F := krtf->KOD
      UnLock
      Commit
      //
      blk := {|_s| iif(empty(_s), '', '"'+_s+'"') }
      delete file (n_file)
      fp := fcreate(n_file)
      //
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"mo_pers",,"P2")
      R_Use(dir_server+"mo_uchvr",,"UV")
      index on str(uch,2) to (cur_dir+"tmp_uv")
      G_Use(dir_server+"mo_krtp",,"KRTP")
      use_base("kartotek")
      set order to 0
      use (cur_dir+"tmp_krtp") new
      set relation to kod_k into KART
      index on upper(kart->fio)+dtos(kart->date_r)+str(kod_k,7) to (cur_dir+"tmp2krtp")
      i := 0
      go top
      do while !eof()
        ++i
        @ maxrow(),0 say str(i/(ii+j)*100,6,2)+"%" color cColorWait
        if !empty(tmp_krtp->uchast)
          select UV
          find (str(tmp_krtp->uchast,2))
          if found()
            if count_years(kart->date_r,sys_date) < 18 // дети
              if !empty(uv->vrach)
                p2->(dbGoto(uv->vrach))
              else
                p2->(dbGoto(uv->vrachd))
              endif
            else
              if !empty(uv->vrach)
                p2->(dbGoto(uv->vrach))
              else
                p2->(dbGoto(uv->vrachv))
              endif
            endif
          endif
          select OTD
          goto (p2->otd)
        endif
        select KRTP
        goto (tmp_krtp->rec)
        G_RLock(forever)
        krtp->REESTR   := krtr->KOD
        krtp->REES_ZAP := i
        krtp->OPLATA   := 0
        krtp->UCHAST   := tmp_krtp->uchast     // номер участка
        krtp->SNILS_VR := p2->snils      // СНИЛС участкового врача
        krtp->KOD_PODR := alltrim(otd->kod_podr) // код подразделения по паспорту ЛПУ
        krtp->D_PRIK1  := ctod("")       // дата прикрепления
        UnLock
        //
        s1 := iif(i==1, "", hb_eol())
        // 1 - Номер записи в файле с 10.06.19г.
        s1 += eval(blk,lstr(i))+";"
        // 1 - Действие
        s := "Р"
        s1 += eval(blk,s)+";"
        // 2 - Код типа ДПФС
        s := iif(kart_->vpolis==3, "П", iif(kart_->vpolis==2, "В", "С"))
        s1 += eval(blk,s)+";"
        // 3 - Серия и номер ДПФС
        s := iif(kart_->vpolis==3, "", ;
                 iif(kart_->vpolis==2, alltrim(kart_->NPOLIS),;
                     alltrim(kart_->SPOLIS)+" № "+alltrim(kart_->NPOLIS)))
        s1 += eval(blk,f_s_csv(s))+";"
        // 4 - Единый номер полиса ОМС
        s := iif(kart_->vpolis==3, alltrim(kart_->NPOLIS), "")
        s1 += eval(blk,s)+";"
        arr_fio := retFamImOt(1,.f.)
        // 5 - Фамилия застрахованного лица
        s1 += eval(blk,f_s_csv(arr_fio[1]))+";"
        // 6 - Имя застрахованного лица
        s1 += eval(blk,f_s_csv(arr_fio[2]))+";"
        // 7 - Отчество застрахованного лица
        s1 += eval(blk,f_s_csv(arr_fio[3]))+";"
        // 8 - Дата рождения застрахованного лица
        s1 += eval(blk,dtos(kart->date_r))+";"
        // 9 - Место рождения застрахованного лица
        s := iif(eq_any(kart_->vid_ud,3,14), alltrim(del_spec_symbol(kart_->mesto_r)), "")
        s1 += eval(blk,f_s_csv(s))+";"
        // 10 - Тип документа, удостоверяющего личность
        s1 += eval(blk,lstr(kart_->vid_ud))+";"
        // 11 - Номер или серия и номер документа, удостоверяющего личность.
        s := alltrim(kart_->ser_ud)+" № "+alltrim(kart_->nom_ud)
        s1 += eval(blk,f_s_csv(s))+";"
        // 12 - Дата выдачи документа, удостоверяющего личность
        s := iif(empty(kart_->kogdavyd), "", dtos(kart_->kogdavyd))
        s1 += eval(blk,s)+";"
        // 13 - Наименование органа, выдавшего документ
        s := alltrim(inieditspr(A__POPUPMENU,dir_server+"s_kemvyd",kart_->kemvyd))
        s1 += eval(blk,f_s_csv(s))+";"
        // 14 - СНИЛС застрахованного лица
        s1 += eval(blk,alltrim(kart->snils))+";"
        // 15 - Идентификатор МО
        s1 += eval(blk,glob_mo[_MO_KOD_TFOMS])+";"
        // 16 - Способ прикрепления
        s1 += eval(blk,lstr(krtp->S_PRIK))+";"
        // 17 - Тип прикрепления (Зарезервированное поле)
        s := ""
        s1 += eval(blk,s)+";"
        // 18 - Дата заявления
        s1 += eval(blk,dtos(krtp->D_PRIK))+";"
        // 19 - Дата открепления
        s1 += eval(blk,"")+";"
        // 20 ОИД МО
        s1 += eval(blk,f_s_csv(loidmo))+";"
        // 21 код подразделения
        s := alltrim(otd->kod_podr)
        s1 += eval(blk,f_s_csv(s))+";"
        // 22 номер участка
        s := lstr(tmp_krtp->uchast)
        s1 += eval(blk,s)+";"
        // 23 СНИЛС врача
        s := p2->snils
        s1 += eval(blk,s)+";"
        // 24 категория врача
        s := iif(p2->kateg==1,"1","2")
        s1 += eval(blk,s)
        //
        fwrite(fp,hb_OemToAnsi(s1))
        //
        select TMP_KRTP
        skip
      enddo
      if k == 3 // после смены участка
        select KRTP
        index on str(reestr,6) to (cur_dir+"tmp_krtp")
        use (cur_dir+"tmpu") new
        set relation to kod into KART
        go top
        do while !eof()
          ++i
          @ maxrow(),0 say str(i/(ii+j)*100,6,2)+"%" color cColorWait
          p2->(dbGoto(tmpu->kodp))
          otd->(dbGoto(p2->otd))
          select KRTP
          AddRec(6)
          krtp->REESTR   := krtr->KOD      // код реестра;по файлу "mo_krtr"
          krtp->KOD_K    := tmpu->kod      // код пациента по файлу "kartotek"
          krtp->D_PRIK   := sys_date       // дата прикрепления (заявления)
          krtp->S_PRIK   := 2              // способ прикрепления: 1-по месту регистрации, 2-по личному заявлению (без изменения м/ж), 3-по личному заявлению (в связи с изменением м/ж)
          krtp->UCHAST   := kart->uchast   // номер участка
          krtp->SNILS_VR := p2->snils      // СНИЛС участкового врача
          krtp->KOD_PODR := alltrim(otd->kod_podr) // код подразделения по паспорту ЛПУ
          krtp->REES_ZAP := i              // номер строки в реестре
          krtp->OPLATA   := 0              // тип оплаты;сначала 0, 1-прикреплён, 2-ошибки
          krtp->D_PRIK1  := ctod("")       // дата прикрепления
          UnLock
          //
          s1 := iif(i==1, "", hb_eol())
          // 1 - Номер записи в файле с 10.06.19г.
          s1 += eval(blk,lstr(i))+";"
          // 1 - Действие
          s := "И" // !!!!!!!!!!!!!! с версии 2.2.12
          s1 += eval(blk,s)+";"
          // 2 - Код типа ДПФС
          s := iif(kart_->vpolis==3, "П", iif(kart_->vpolis==2, "В", "С"))
          s1 += eval(blk,s)+";"
          // 3 - Серия и номер ДПФС
          s := iif(kart_->vpolis==3, "", ;
                   iif(kart_->vpolis==2, alltrim(kart_->NPOLIS),;
                       alltrim(kart_->SPOLIS)+" № "+alltrim(kart_->NPOLIS)))
          s1 += eval(blk,f_s_csv(s))+";"
          // 4 - Единый номер полиса ОМС
          s := iif(kart_->vpolis==3, alltrim(kart_->NPOLIS), "")
          s1 += eval(blk,s)+";"
          arr_fio := retFamImOt(1,.f.)
          // 5 - Фамилия застрахованного лица
          s1 += eval(blk,f_s_csv(arr_fio[1]))+";"
          // 6 - Имя застрахованного лица
          s1 += eval(blk,f_s_csv(arr_fio[2]))+";"
          // 7 - Отчество застрахованного лица
          s1 += eval(blk,f_s_csv(arr_fio[3]))+";"
          // 8 - Дата рождения застрахованного лица
          s1 += eval(blk,dtos(kart->date_r))+";"
          // 9 - Место рождения застрахованного лица
          s := iif(eq_any(kart_->vid_ud,3,14), alltrim(del_spec_symbol(kart_->mesto_r)), "")
          s1 += eval(blk,f_s_csv(s))+";"
          fl := ascan(menu_vidud,{|x| x[2] == kart_->vid_ud }) == 0
          if !fl
            if empty(kart_->nom_ud)
              fl := .t. //должно быть заполнено поле "НОМЕР удостоверения личности"
            elseif !ver_number(kart_->nom_ud)
              fl := .t. //поле "НОМЕР удостоверения личности" должно быть цифровым
            elseif !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud)
              fl := .t.
            endif
          endif
          if !fl .and. eq_any(kart_->vid_ud,1,3,14) .and. empty(kart_->ser_ud)
            fl := .t. //не заполнено поле "СЕРИЯ удостоверения личности"
          endif
          if !fl .and. !empty(kart_->ser_ud) .and. !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud)
            fl := .t.
          endif
          if fl
            // 10 - Тип документа, удостоверяющего личность
            s1 += eval(blk,"")+";"
            // 11 - Номер или серия и номер документа, удостоверяющего личность.
            s1 += eval(blk,"")+";"
          else
            // 10 - Тип документа, удостоверяющего личность
            s1 += eval(blk,lstr(kart_->vid_ud))+";"
            // 11 - Номер или серия и номер документа, удостоверяющего личность.
            s := alltrim(kart_->ser_ud)+" № "+alltrim(kart_->nom_ud)
            s1 += eval(blk,f_s_csv(s))+";"
          endif
          // 12 - Дата выдачи документа, удостоверяющего личность
          lkogdavyd := kart_->kogdavyd
          if !empty(kart_->kogdavyd) .and. !between(kart_->kogdavyd,kart->date_r,sys_date)
            if kart_->vid_ud == 3 // свид_во о рождении
              lkogdavyd := kart->date_r
            else
              lkogdavyd := ctod("")
            endif
          endif
          s := iif(empty(lkogdavyd), "", dtos(lkogdavyd))
          s1 += eval(blk,s)+";"
          // 13 - Наименование органа, выдавшего документ
          s := alltrim(inieditspr(A__POPUPMENU,dir_server+"s_kemvyd",kart_->kemvyd))
          s1 += eval(blk,f_s_csv(s))+";"
          // 14 - СНИЛС застрахованного лица
          if !empty(lsnils := kart->snils) .and. !val_snils(kart->snils,2)
            lsnils := ""
          endif
          s1 += eval(blk,alltrim(lsnils))+";"
          // 15 - Идентификатор МО
          s1 += eval(blk,glob_mo[_MO_KOD_TFOMS])+";"
          // 16 - Способ прикрепления
          s1 += eval(blk,lstr(krtp->S_PRIK))+";"
          // 17 - Тип прикрепления (Зарезервированное поле)
          s := ""
          s1 += eval(blk,s)+";"
          // 18 - Дата заявления
          s1 += eval(blk,dtos(krtp->D_PRIK))+";"
          // 19 - Дата открепления
          s1 += eval(blk,"")+";"
          // 20 ОИД МО
          s1 += eval(blk,f_s_csv(loidmo))+";"
          // 21 код подразделения
          s := alltrim(otd->kod_podr)
          s1 += eval(blk,f_s_csv(s))+";"
          // 22 номер участка
          s := lstr(kart->uchast)
          s1 += eval(blk,s)+";"
          // 23 СНИЛС врача
          s := p2->snils
          s1 += eval(blk,s)+";"
          // 24 категория врача
          s := iif(p2->kateg==1,"1","2")
          s1 += eval(blk,s)
          //
          fwrite(fp,hb_OemToAnsi(s1))
          //
          select TMPU
          skip
        enddo
      endif
      fclose(fp)
      if hb_FileExists(n_file)
        chip_copy_zipXML(n_file,dir_server+dir_XML_MO,.t.)
        keyboard chr(K_HOME)+chr(K_ENTER)
        select KRTF
        G_RLock(forever)
        krtf->KOL := ii+j
        krtf->TWORK2 := hour_min(seconds()) // время окончания обработки
      else
        func_error(4,"Ошибка создания файла "+n_file)
      endif
    endif
  endif
endif
close databases
G_SUnLock(str_sem)
return NIL

***** 11.10.15
Static Function f1_p_f_pripisnoe_naselenie(aerr)
Local s := space(80), lfio := '"'+alltrim(p2->fio)+'"'
if p2->kateg != 1
  aadd(aerr,"у специалиста "+lfio+" в справочнике персонала категория должна быть ВРАЧ")
elseif empty(p2->snils)
  aadd(aerr,"не введен СНИЛС у врача "+lfio+" в справочнике персонала")
elseif !val_snils(p2->snils,2,@s)
  aadd(aerr,s+" у врача "+lfio+" в справочнике персонала")
endif
if empty(p2->otd)
  aadd(aerr,"не проставлено отделение у врача "+lfio+" в справочнике персонала")
else
  select OTD
  goto (p2->otd)
  if empty(otd->kod_podr)
    aadd(aerr,'в отд."'+alltrim(otd->name)+'" не проставлен код подразделения')
  endif
endif
return NIL

*

***** 12.10.15 поиск пациентов в картотеке с изменившимися участками (СНИЛС участкового врача)
Function find_change_snils(/*@*/curr)
Local k := 2, hGauge
ClrLine(maxrow(),color0)
dbcreate(cur_dir+"tmpu",{{"kod","N",7,0},{"kodp","N",5,0}})
use (cur_dir+"tmpu") new
hGauge := GaugeNew(,,,"Поиск пациентов в картотеке с изменившимися участками",.t.)
GaugeDisplay( hGauge )
curr := 0
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"mo_uchvr",,"UV")
index on str(uch,2) to (cur_dir+"tmp_uv")
R_Use_base("kartotek")
set order to 2
find ("1")
do while kart->kod > 0 .and. !eof()
  GaugeUpdate( hGauge, ++curr/lastrec() )
  if kart->uchast > 0 .and. !kart2->(eof() .and. !(left(kart2->PC2,1)=='1')) ;
     .and. kart2->MO_PR == glob_MO[_MO_KOD_TFOMS] .and. !empty(kart2->SNILS_VR)
    fl := .f.
    select UV
    find (str(kart->uchast,2))
    if found() .and. !emptyall(uv->vrach,uv->vrachv,uv->vrachd)
      if count_years(kart->date_r,sys_date) < 18 // дети
        if emptyall(uv->vrach,uv->vrachd)
          //aadd(aerr,"на участке "+lstr(kart->uchast)+" не привязан участковый врач к детям")
        else
          if !empty(uv->vrach)
            p2->(dbGoto(uv->vrach))
          else
            p2->(dbGoto(uv->vrachd))
          endif
          fl := p2->kateg == 1 .and. !empty(p2->snils) .and. !(p2->snils == kart2->SNILS_VR)
        endif
      else
        if emptyall(uv->vrach,uv->vrachv)
          //aadd(aerr,"на участке "+lstr(kart->uchast)+" не привязан участковый врач к взрослым")
        else
          if !empty(uv->vrach)
            p2->(dbGoto(uv->vrach))
          else
            p2->(dbGoto(uv->vrachv))
          endif
          fl := p2->kateg == 1 .and. !empty(p2->snils) .and. !(p2->snils == kart2->SNILS_VR)
        endif
      endif
    else
      //aadd(aerr,"к участку "+lstr(kart->uchast)+" не привязан участковый врач")
    endif
    if fl
      select TMPU
      append blank
      tmpu->kod := kart->kod
      tmpu->kodp := p2->kod
      @ maxrow(),1 say lstr(tmpu->(recno())) color color0
      if tmpu->(recno()) % 500 == 0
        Commit
      endif
    endif
  endif
  select KART
  skip
enddo
curr := tmpu->(lastrec())
close databases
CloseGauge(hGauge)
if curr == 0
  func_error(4,"Не найдено пациентов с изменившимися участками (СНИЛС участкового врача)")
else
  k := 3
endif
ClrLine(maxrow(),color0)
return k

*

***** 26.07.15
Function f1_p_f_prikreplenie(nKey,oBrow,regim)
Local lkod, luchast := 0, buf, r1, rec, i, ret := -1, tmp_color
if regim == "edit"
  do case
    case nKey == K_ENTER
      buf := save_maxrow()
      Private md_prik := tmp_krtp->d_prik, muchast := kart->uchast
      if muchast > 0
        keyboard chr(K_TAB)
      endif
      tmp_color := setcolor("W+/B*,W+/R*,,,BG+/B*")
      r1 := row()
      @ r1,45 get muchast pict "99"
      @ r1,48 get md_prik
      status_key("^<Esc>^ - отказ от редактирования;  ^<Enter>^ - запись даты прикрепления")
      myread()
      rest_box(buf)
      setcolor(tmp_color)
      if lastkey() != K_ESC
        if krtp->D_PRIK != md_prik
          select KRTP
          goto (tmp_krtp->rec)
          G_RLock(forever)
          krtp->D_PRIK := md_prik
          UnLock
          Commit
        endif
        if kart->uchast != muchast
          select KART
          G_RLock(forever)
          kart->uchast := muchast
          UnLock
          Commit
        endif
        select TMP_KRTP
        tmp_krtp->d_prik := md_prik
        tmp_krtp->uchast := muchast
        if (i := popup_2array(arr_prik1,r1-5,56,tmp_krtp->s_prik)) > 0 .and. ;
                                                           tmp_krtp->s_prik != i
          if krtp->S_PRIK != i
            select KRTP
            goto (tmp_krtp->rec)
            G_RLock(forever)
            krtp->S_PRIK := i
            UnLock
            Commit
          endif
          select TMP_KRTP
          tmp_krtp->s_prik := i
        endif
      endif
      buf := savescreen()
      kartotek_to_screen(14,23)
      @ 13,0 to 13,79 color "G+/B"
      str_center(13," Просмотр карточки пациента ","G+/B")
      stat_msg("Нажмите любую клавишу...")
      inkey(0)
      restscreen(buf)
      ret := 0
    case nKey == K_INS
      select TMP_KRTP
      rec := lkod := tmp_krtp->kod_k
      set relation to
      if (lkod := f2_p_f_prikreplenie(lkod,@luchast)) > 0
        select TMP_KRTP
        set order to 2
        find (str(lkod,7))
        if found()
          func_error(1,"Данный пациент уже добавлен в этот список")
        else
          i := 2 ; md_prik := sys_date
          if kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
            lkod := rec
            func_error(4,'Данный пациент уже прикреплён к Вашей МО с '+;
                         iif(empty(kart2->pc4),full_date(kart2->DATE_PR),alltrim(kart2->pc4))+"г.")
            /*i := 1
            if !empty(kart2->DATE_PR)
              md_prik := kart2->DATE_PR
            endif
            func_error(1,"Данный пациент уже прикреплён к Вашему МО с "+full_date(md_prik)+"г.")*/
          else
            rec := lkod
            select KRTP
            AddRec(6)
            krtp->REESTR := 0
            krtp->S_PRIK := i
            krtp->D_PRIK := md_prik
            krtp->KOD_K := lkod
            UnLock
            Commit
            select TMP_KRTP
            append blank
            replace rec with krtp->(recno()), kod_k with krtp->kod_k,;
                    s_prik with krtp->S_PRIK, d_prik with krtp->D_PRIK,;
                    uchast with luchast
          endif
        endif
      endif
      select KART
      set order to 0
      select TMP_KRTP
      set relation to kod_k into KART
      set order to 2
      oBrow:gotop()
      if lastrec() == 0
        ret := 1
      else
        find (str(lkod,7))
        set order to 1
        ret := 0
      endif
    case nKey == K_DEL .and. f_Esc_Enter(2)
      select KRTP
      goto (tmp_krtp->rec)
      DeleteRec()
      select TMP_KRTP
      Delete
      pack
      oBrow:gotop()
      ret := 0
      if lastrec() == 0
        ret := 1
      endif
  endcase
endif
return ret

***** 26.07.15
Function f2_p_f_prikreplenie(lkod,/*@*/luchast)
Local blk, t_arr[BR_LEN]
Private str_find := "1", muslovie := "kart->kod > 0"
select KART
set order to 2
if lkod > 0
  goto (lkod)
else
  find (str_find)
endif
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 33
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Картотека - прикрепление"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.,72}
t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                        {| | FindLast(str_find)},;
                        {|_n| SkipPointer(_n,muslovie)},;
                        str_find,muslovie;
                       }
blk := {|| iif(kart2->mo_pr==glob_MO[_MO_KOD_TFOMS], {1,2}, {3,4}) }
t_arr[BR_COLUMN] := {{ center("Ф.И.О.",35),{|| left(kart->fio,32) }, blk },;
                     {"Дата рожд.", {|| full_date(kart->date_r) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход; ^^ или нач.буква - поиск; ^<Enter>^ - выбрать для прикрепления") }
lkod := 0
t_arr[BR_ENTER] := {|| lkod := kart->kod, luchast := kart->uchast }
edit_browse(t_arr)
return lkod

***** 11.03.13
Function f3_p_f_prikreplenie()
@ tr-3,48 say padc("Отмечено пациентов: "+lstr(tmp_krtp->(lastrec())),29) color "B/W*"
return NIL

*

***** 05.03.13
Function kartoteka_z_prikreplenie()
Static srec := 0
Local blk, t_arr[BR_LEN]
Private str_find := "1", muslovie := "kart->kod > 0", z_rec := 0
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := maxcol()
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Картотека - прикрепление"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B,R/BG,W+/R",.t.,72}
t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                        {| | FindLast(str_find)},;
                        {|_n| SkipPointer(_n,muslovie)},;
                        str_find,muslovie;
                       }
blk := {|| iif(kart2->mo_pr==glob_MO[_MO_KOD_TFOMS], {1,2},;
               iif(empty(kart2->mo_pr), {3,4}, {5,6})) }
t_arr[BR_COLUMN] := {{ center("Ф.И.О.",35),{|| left(kart->fio,32) }, blk },;
                     {"Дата рожд.", {|| full_date(kart->date_r) }, blk },;
                     {" Прикрепление", {|| padr(inieditspr(A__MENUVERT,glob_arr_mo,kart2->mo_pr),34) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход; ^^ или нач.буква - поиск; ^<F9>^ - печать заявления на прикрепление") }
t_arr[BR_EDIT] := {|nk,ob| f1_k_z_prikreplenie(nk,ob,"edit") }
use_base("kartotek")
set order to 2
if srec > 0
  goto (srec)
else
  find (str_find)
endif
edit_browse(t_arr)
if z_rec > 0
  srec := z_rec
endif
close databases
return NIL

***** 05.03.13
Function f1_k_z_prikreplenie(nKey,oBrow,regim)
Local j, s, ret := -1
if regim == "edit" .and. nKey == K_F9
  if kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
    func_error(1,"Данный пациент уже прикреплён к Вашему МО")
  endif
  z_rec := kart->(recno())
  delFRfiles()
  dbcreate(fr_titl, {;
       {"name_org","C",130,0},;
       {"adres_org","C",110,0},;
       {"fio","C",60,0},;
       {"fam_io","C",30,0},;
       {"pol","C",10,0},;
       {"date_r","C",120,0},;
       {"pasport","C",250,0},;
       {"adres_p","C",250,0},;
       {"adres_g","C",250,0},;
       {"smo","C",100,0},;
       {"ruk_fio","C",60,0},;
       {"ruk","C",20,0}})
  R_Use(dir_server+"organiz",,"ORG")
  use (fr_titl) new alias FRT
  append blank
  frt->name_org := glob_MO[_MO_SHORT_NAME]+" ("+glob_MO[_MO_KOD_TFOMS]+")"
  frt->adres_org := alltrim(org->adres)
  frt->fio := kart->fio
  frt->fam_io := fam_i_o(kart->fio)
  frt->pol := iif(kart->pol=="М", "мужской", "женский")
  frt->date_r := full_date(kart->date_r)+"г. "+alltrim(kart_->mesto_r)
  s := ""
  if kart_->vid_ud > 0
    if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
      s := menu_vidud[j,4]+": "
    endif
    if !empty(kart_->ser_ud)
      s += charone(" ",alltrim(kart_->ser_ud))+" "
    endif
    if !empty(kart_->nom_ud)
      s += alltrim(kart_->nom_ud)+" "
    endif
    if !empty(kart_->kogdavyd)
      s += "выдан "+full_date(kart_->kogdavyd)+"г. "
    endif
    if !empty(kart_->kemvyd)
      s += inieditspr(A__POPUPMENU, dir_server+"s_kemvyd", kart_->kemvyd)
    endif
  endif
  frt->pasport := s
  frt->adres_g := ret_okato_ulica(kart->adres,kart_->okatog)
  if emptyall(kart_->okatop,kart_->adresp)
    frt->adres_p := frt->adres_g
  else
    frt->adres_p := ret_okato_ulica(kart_->adresp,kart_->okatop)
  endif
  s := alltrim(inieditspr(A__MENUVERT,glob_arr_smo,int(val(kart_->smo))))+", полис "
  s += alltrim(rtrim(kart_->SPOLIS)+" "+kart_->NPOLIS)+" ("+;
        alltrim(inieditspr(A__MENUVERT, mm_vid_polis, kart_->VPOLIS))+")"
  frt->smo := s
  frt->ruk_fio := alltrim(iif(empty(org->ruk_fio), org->ruk, org->ruk_fio))
  frt->ruk := alltrim(org->ruk)
  close databases
  call_fr("mo_zprik")
  //
  use_base("kartotek")
  set order to 2
  goto (z_rec)
  ret := 0
endif
return ret

*

***** 11.09.17 создать файл(ы) сверки
Function pripisnoe_naselenie_create_SVERKA()
Local ii := 0, s, buf := savescreen(), fl, af := {}, arr_fio, ta, fl_polis, fl_pasport
if !f_Esc_Enter("создания файла сверки",.t.)
  return NIL
endif
ClrLine(maxrow(),color0)
dbcreate(cur_dir+"tmp",{{"kod","N",7,0}})
use (cur_dir+"tmp") new
hGauge := GaugeNew(,,,"Составление списка для включения в файл сверки",.t.)
GaugeDisplay( hGauge )
curr := 0
R_Use(dir_server+"mo_kfio",,"KFIO")
index on str(kod,7) to (cur_dir+"tmp_kfio")
R_Use_base("kartotek")
set order to 2
find ("1")
do while kart->kod > 0 .and. !eof()
  GaugeUpdate( hGauge, ++curr/lastrec() )
  fl := .t.
  if empty(kart->date_r)
    fl := .f. // не заполнено поле "Дата рождения"
  elseif kart->date_r >= sys_date
    fl := .f. // дата рождения больше сегодняшней даты
  elseif year(kart->date_r) < 1900
    fl := .f. // дата рождения < 1900г.
  endif
  if fl
    fl := between(kart_->vpolis,1,3) .and. !empty(kart_->NPOLIS)
  endif
  if fl
    arr_fio := retFamImOt(1,.f.,.t.)
    if val_fio(arr_fio) .and. !(len(arr_fio[2]) < 2 .and. len(arr_fio[3]) < 2)
      //
    else
      fl := .f.
    endif
  endif
  if !fl .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
    fl := .t.
  endif
  if fl
    select TMP
    append blank
    tmp->kod := kart->kod
    if tmp->(recno()) % 100 == 0
      @ maxrow(),1 say lstr(tmp->(recno())) color color0
      if tmp->(recno()) % 2000 == 0
        Commit
      endif
    endif
  endif
  select KART
  skip
enddo
ii := tmp->(lastrec())
close databases
CloseGauge(hGauge)
i := -1
arr := {}
do while ii > 0
  k := min(ii,99999) ; i++
  aadd(arr,{k,sys_date-i,0})
  ii -= k
enddo
fl := .f.
s := "SZ2"
R_Use(dir_server+"mo_krtr",,"KRTR")
index on dtos(DFILE) to (cur_dir+"tmp_krtr") for left(FNAME,3) == s
ar := {}
for i := 1 to len(arr)
  n_file := s+glob_mo[_MO_KOD_TFOMS]+dtos(arr[i,2])+scsv
  s1 := ""
  find (dtos(arr[i,2]))
  if found()
    s1 := " - уже был создан"
    fl := .t.
  endif
  aadd(ar,n_file+" ("+lstr(arr[i,1])+" чел.)"+s1)
next
close databases
ClrLine(maxrow(),color0)
ar2 := {" Выход "} ; s1 := "файл"+iif(len(arr)==1,"а","ов")
if fl
  Ins_Array(ar,1,"Запрет создания "+s1+" сверки:")
else
  Ins_Array(ar,1,"Подтвердите создание "+s1+" сверки:")
  aadd(ar2," Создание "+s1+" сверки ")
endif
if len(ar) < 8
  aadd(ar,"")
  if len(ar) < 8
    Ins_Array(ar,2,"")
  endif
endif
if f_alert(ar,ar2,1,"GR+/R","W+/R",,,"GR+/R,N/BG") == 2
  mywait()
  blk := {|_s| iif(empty(_s), '', '"'+_s+'"') }
  G_Use(dir_server+"mo_krtr",,"KRTR")
  index on str(kod,6) to (cur_dir+"tmp_krtr")
  G_Use(dir_server+"mo_krtf",,"KRTF")
  index on str(kod,6) to (cur_dir+"tmp_krtf")
  G_Use(dir_server+"mo_krtp",,"KRTP")
  index on str(reestr,6) to (cur_dir+"tmp_k")
  R_Use(dir_server+"mo_kfio",cur_dir+"tmp_kfio","KFIO")
  R_Use_base("kartotek")
  set order to 0
  use (cur_dir+"tmp") new
  set relation to kod into KART
  curr := 0
  restscreen(buf)
  for i := 1 to len(arr)
    n_file := "SZ2"+glob_mo[_MO_KOD_TFOMS]+dtos(arr[i,2])
    select KRTR
    AddRec(6)
    krtr->KOD := recno()
    krtr->FNAME := n_file
    krtr->DFILE := arr[i,2]
    krtr->DATE_OUT := ctod("")
    krtr->NUMB_OUT := 0
    krtr->KOL := arr[i,1]
    krtr->KOL_P := 0
    krtr->ANSWER := 0  // 0-не было ответа, 1-был прочитан ответ
    //
    select KRTF
    AddRec(6)
    krtf->KOD   := recno()
    krtf->FNAME := krtr->FNAME
    krtf->DFILE := krtr->DFILE
    krtf->TFILE := hour_min(seconds())
    krtf->TIP_IN := 0
    krtf->TIP_OUT := _CSV_FILE_SVERKAZ
    krtf->REESTR := krtr->KOD
    krtf->DWORK := sys_date
    krtf->TWORK1 := hour_min(seconds()) // время начала обработки
    krtf->TWORK2 := ""                  // время окончания обработки
    //
    krtr->KOD_F := krtf->KOD
    dbUnLockAll()
    Commit
    //
    n_file += scsv
    delete file (n_file)
    fp := fcreate(n_file)
    //
    hGauge := GaugeNew(,,,"Создание файла сверки "+n_file,.t.)
    GaugeDisplay( hGauge )
    for ii := 1 to arr[i,1]
      GaugeUpdate( hGauge, ii/arr[i,1] )
      ++curr
      select TMP
      goto (curr)
      arr_fio := retFamImOt(1,.f.,.t.)
      fl_polis := fl_pasport := .t.
      if empty(kart_->SPOLIS)
        ta := {}
        Valid_SN_Polis(kart_->vpolis,"",kart_->NPOLIS,ta,.t.)
        fl_polis := empty(ta) // функция проверки не вернула ошибок
      else
        fl_polis := .f. // есть серия полиса => иногородний
      endif
      if !eq_any(kart_->vid_ud,1,3,14)
        fl_pasport := .f. // не то в поле "ВИД удостоверения личности"
      else
        if empty(kart_->nom_ud)
          fl_pasport := .f. // должно быть заполнено поле "НОМЕР удостоверения личности"
        elseif !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud)
          fl_pasport := .f.
        endif
        if fl_pasport .and. !empty(kart_->ser_ud) .and. !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud)
          fl_pasport := .f.
        endif
      endif
      select KRTP
      AddRec(6)
      krtp->REESTR   := krtr->KOD // код реестра;по файлу "mo_krtr"
      krtp->KOD_K    := kart->kod // код пациента по файлу "kartotek"
      krtp->D_PRIK   := sys_date  // дата прикрепления (заявления)
      krtp->S_PRIK   := 0         // способ прикрепления: 1-по месту регистрации, 2-по личному заявлению (без изменения м/ж), 3-по личному заявлению (в связи с изменением м/ж)
      krtp->REES_ZAP := ii        // номер строки в реестре
      krtp->OPLATA   := 0         // тип оплаты;сначала 0, 1-прикреплён, 2-ошибки
      krtp->D_PRIK1  := ctod("")  // дата прикрепления
      //
      s1 := iif(ii==1, "", hb_eol()) + eval(blk,lstr(ii))+";" // в начале - номер по порядку
      // 1 - Код типа ДПФС
      s := iif(kart_->vpolis==3, "П", iif(kart_->vpolis==2, "В", "С"))
      s1 += eval(blk,s)+";"
      if kart_->vpolis < 3
        s := alltrim(kart_->SPOLIS)+alltrim(kart_->NPOLIS)
        if empty(s)
          s :=  iif(kart_->vpolis == 2, "123456789", "34")
        endif
        if kart_->vpolis == 2
          s := padr(s,9,"0")
        else
          s := padr(s,16,"0")
        endif
      else
        s := ""
      endif
      s1 += eval(blk,s)+";"
      // 3 - Единый номер полиса ОМС
      s := iif(kart_->vpolis == 3, alltrim(kart_->NPOLIS), "")
      s1 += eval(blk,s)+";"
      /*if fl_polis
        // 2 - Серия и номер ДПФС (только номер - наша область)
        s := iif(kart_->vpolis < 3, alltrim(kart_->NPOLIS), "")
        s1 += eval(blk,s)+";"
        // 3 - Единый номер полиса ОМС
        s := iif(kart_->vpolis == 3, alltrim(kart_->NPOLIS), "")
        s1 += eval(blk,s)+";"
      else
        s1 += ";;"
      endif*/
      // 4 - Фамилия застрахованного лица
      s1 += eval(blk,arr_fio[1])+";"
      // 5 - Имя застрахованного лица
      s1 += eval(blk,arr_fio[2])+";"
      // 6 - Отчество застрахованного лица
      s1 += eval(blk,arr_fio[3])+";"
      // 7 - Дата рождения застрахованного лица
      s1 += eval(blk,dtos(kart->date_r))+";"
      if fl_pasport
        // 8 - Тип документа, удостоверяющего личность
        s := lstr(kart_->vid_ud)
        s1 += eval(blk,s)+";"
        // 9 - Номер или серия и номер документа, удостоверяющего личность.
        s := alltrim(kart_->ser_ud)+" № "+alltrim(kart_->nom_ud)
        s1 += eval(blk,s)+";"
      else
        s1 += ";;"
      endif
      // 10 - СНИЛС застрахованного лица
      s := ""
      if !empty(kart->snils) .and. val_snils(kart->snils,2)
        s := kart->snils
      endif
      s1 += eval(blk,s)  // нет ";", т.к. последнее поле
      //
      fwrite(fp,hb_OemToAnsi(s1))
      if ii % 3000 == 0
        dbUnLockAll()
        Commit
      endif
    next ii
    fclose(fp)
    name_zip := alltrim(krtr->FNAME)+szip
    select KRTR
    G_RLock(forever)
    krtr->KOL := arr[i,1]
    select KRTF
    G_RLock(forever)
    krtf->KOL := arr[i,1]
    krtf->TWORK2 := hour_min(seconds()) // время окончания обработки
    dbUnLockAll()
    Commit
    if hb_FileExists(n_file)
      if chip_create_zipXML(name_zip,{n_file},.t.)
        stat_msg("Файл сверки "+n_file+" создан!") ; mybell(1,OK)
      endif
    else
      func_error(4,"Ошибка создания файла "+n_file)
    endif
  next i
  close databases
  keyboard chr(K_HOME)+chr(K_ENTER)
endif
restscreen(buf)
return NIL

*

***** 10.06.14
Function view_otkrep_pripisnoe_naselenie()
Local buf := savescreen()
Private goal_dir := dir_server+dir_XML_TF+cslash
R_Use(dir_server+"mo_krtf",,"KRTF")
index on dtos(dfile) to (cur_dir+"tmp_krtf") for TIP_IN == _CSV_FILE_OTKREP DESCENDING
go top
if eof()
  func_error(4,"Нет принятых файлов открепления")
else
  Alpha_Browse(T_ROW,0,23,79,"f1_view_otkrep_pr_nas",color0,,,,,,,;
               "f2_view_otkrep_pr_nas",,{'═','░','═',"N/BG,W+/N,R/BG,BG+/R",.t.,180} )
endif
close databases
restscreen(buf)
return NIL

***** 10.06.14
Function f1_view_otkrep_pr_nas(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(krtf->FNAME)+szip), {1,2}, {3,4}) }
oColumn := TBColumnNew("Дата файла",{|| full_date(krtf->dfile) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Кол-во;пациентов", {|| str(krtf->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(krtf->FNAME,20) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" К какому МО прикреплены",{|| padr(ret_mo(krtf->mo_pr)[_MO_SHORT_NAME],36) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<F3>^ - информация о файле открепления")
return NIL

*

***** 10.06.14
Function f2_view_otkrep_pr_nas(nKey,oBrow)
Local ret := -1, buf := savescreen()
do case
  case nKey == K_F3
    viewtext(Devide_Into_Pages(goal_dir+alltrim(krtf->FNAME)+stxt,60,80),,,,.t.,,,2)
    ret := 0
endcase
restscreen(buf)
return ret

*

***** 17.06.15 чтение в память и анализ CSV-файла
Function read_CSV_from_TF(cFile,nTypeFile,nkod_reestr)
Local aerr := {}, j, nCountWithErr := 0, adbf, go_to_answer := .f.,;
      go_to_otkrep := .f., buf := save_maxrow()
mywait("Производится анализ файла "+cFile)
Private cReadFile := Name_Without_Ext(cFile), ;
        cTimeBegin := hour_min(seconds())
Private cFileProtokol := cReadFile+stxt
strfile(space(10)+"Протокол обработки файла: "+cFile+;
        hb_eol(),cFileProtokol)
strfile(space(10)+full_date(sys_date)+"г. "+cTimeBegin+;
        hb_eol(),cFileProtokol,.t.)
// читаем файл в память
if eq_any(nTypeFile,_CSV_FILE_PRIKFLK,_CSV_FILE_PRIKANS) // тип принимаемого файла;6-ФЛК на реестр
  aadd(aerr,"Данный тип файлов *.CSV больше не обрабатывается")
  //read_CSV_FILE_PRIK_FLK_ANS(cFile,aerr,nTypeFile,nkod_reestr)
  go_to_answer := empty(aerr)
elseif nTypeFile == _CSV_FILE_ANSWER // тип принимаемого файла;2-ответ на реестр
  read_CSV_FILE_ANSWER(_tmp_dir1+cFile,aerr,nkod_reestr)
  go_to_answer := empty(aerr)
elseif nTypeFile == _CSV_FILE_OTKREP // тип принимаемого файла;3-открепление
  read_CSV_FILE_OTKREP(_tmp_dir1+cFile,aerr)
  go_to_otkrep := empty(aerr)
elseif nTypeFile == _CSV_FILE_SVERKAO // тип принимаемого файла;4-ответ на запрос для сверки
  read_CSV_FILE_SVERKAO(_tmp_dir1+cFile,aerr,nkod_reestr)
  go_to_answer := empty(aerr)
endif
close databases
rest_box(buf)
if empty(aerr)
  // запишем принимаемый файл
  chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
  // запишем файл протокола обработки
  chip_copy_zipXML(cFileProtokol,dir_server+dir_XML_TF)
endif
if !empty(aerr)
  aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
endif
viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
delete file (cFileProtokol)
if go_to_answer // если
  keyboard chr(K_ESC)+chr(K_LEFT)+chr(K_ENTER)+chr(K_HOME)+replicate(chr(K_TAB),4)+chr(K_ENTER)
elseif go_to_otkrep // если
  keyboard chr(K_ESC)+chr(K_LEFT)+chr(K_ENTER)+chr(K_HOME)+replicate(chr(K_TAB),5)+chr(K_ENTER)
endif
return NIL

*

#define CSV_A_NREC   1
#define CSV_A_ENP    2
#define CSV_A_CERR   3

***** 23.07.15 чтение и анализ CSV-файла ответа на новый файл прикрепления
Function read_CSV_FILE_PRIK_FLK_ANS(cFile,aerr,nTypeFile,nkod_reestr,nkod_file)
Local i, j, k, jp := 0, je := 0, s, arr_csv, buf := save_maxrow()
mywait()
if nTypeFile == _CSV_FILE_PRIKFLK
  strfile(space(10)+"Журнал форматно-логического контроля для файла прикрепления"+;
          hb_eol()+hb_eol(),cFileProtokol,.t.)
else
  strfile(space(10)+"Протокол обработки для файла прикрепления"+;
          hb_eol()+hb_eol(),cFileProtokol,.t.)
endif
Use_base("kartotek")
// список карточек в реестрах на прикрепление
G_Use(dir_server+"mo_krtp",,"KRTP")
index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == nkod_reestr
// список ошибок в реестрах на прикрепление
G_Use(dir_server+"mo_krte",,"KRTE")
index on str(reestr,6)+str(REES_ZAP,6)+str(REFREASON,3) to (cur_dir+"tmp_krte")
// Реестр сведений о прикреплении
G_Use(dir_server+"mo_krtr",,"KRTR")
goto (nkod_reestr)
// Список отосланных и принятых CSV-файлов
G_Use(dir_server+"mo_krtf",,"KRTF")
if nkod_file == NIL
  index on str(kod,6) to (cur_dir+"tmp_krtf")
endif
arr_csv := read_CSV_to_array(cFile)
k := len(arr_csv)
if k == 1 .and. alltrim(arr_csv[1,1]) == "N"
  arr_csv := {} // т.е. нет ошибок
  strfile(hb_eol()+space(10)+"Ошибок не обнаружено."+;
          hb_eol(),cFileProtokol,.t.)
  k := 0
  jp := krtr->KOL
else
  for i := 1 to k
    arr_csv[i,CSV_A_NREC] := int(val(arr_csv[i,CSV_A_NREC]))
    select KRTP
    find (str(arr_csv[i,CSV_A_NREC],6))
    if !found()
      aadd(aerr,"Не найден пациент с номером записи "+lstr(arr_csv[i,CSV_A_NREC]))
    endif
    // сбор ошибок в массив
    s := arr_csv[i,CSV_A_CERR]
    arr_csv[i,CSV_A_CERR] := {}
    if !empty(s)
      for j := 1 to numtoken(s,",",1)
        aadd(arr_csv[i,CSV_A_CERR], int(val(alltrim(token(s,",",j,1)))))
      next
    endif
    if !empty(aerr) ; exit ; endif
  next
endif
if empty(aerr)
  select KRTF
  if nkod_file == NIL
    AddRec(6)
    krtf->KOD   := recno()
    krtf->FNAME := cReadFile
    krtf->DFILE := krtr->DFILE
    krtf->TFILE := hour_min(seconds())
    krtf->TIP_IN := nTypeFile
    krtf->TIP_OUT := 0
    krtf->DREAD := sys_date
    krtf->TREAD := hour_min(seconds())
    krtf->KOL := len(arr_csv)
    krtf->REESTR := nkod_reestr
    krtf->MO_PR := ""
  else
    goto (nkod_file)
    G_RLock(forever)
  endif
  krtf->DWORK := sys_date
  krtf->TWORK1 := cTimeBegin
  for i := 1 to k
    select KRTP
    find (str(arr_csv[i,CSV_A_NREC],6))
    G_RLock(forever)
    if empty(arr_csv[i,CSV_A_CERR])
      if nTypeFile == _CSV_FILE_PRIKFLK
        ++jp
        krtp->OPLATA := 1
        krtp->D_PRIK1 := krtp->D_PRIK
      endif
    else
      ++je
      krtp->OPLATA := 2
      krtp->D_PRIK1 := ctod("")
    endif
    dbUnLock()
    if len(arr_csv[i,CSV_A_CERR]) > 0
      select KART
      goto (krtp->KOD_K)
      s := lstr(arr_csv[i,CSV_A_NREC])+". "+alltrim(kart->fio)+" - ошибка"
      strfile(s+hb_eol(),cFileProtokol,.t.)
      for j := 1 to len(arr_csv[i,CSV_A_CERR])
        select KRTE
        find (str(nkod_reestr,6)+str(arr_csv[i,CSV_A_NREC],6)+str(arr_csv[i,CSV_A_CERR,j],3))
        if !found()
          AddRec(6)
          krte->REESTR := nkod_reestr
          krte->REES_ZAP := arr_csv[i,CSV_A_NREC]
          krte->KOD_K := krtp->KOD_K
          krte->REFREASON := arr_csv[i,CSV_A_CERR,j]
          dbUnLock()
        endif
        strfile(space(len(lstr(arr_csv[i,CSV_A_NREC]))+2)+lstr(krte->REFREASON)+" "+;
                inieditspr(A__MENUVERT,mm_err_csv_prik,krte->REFREASON)+;
                hb_eol(),cFileProtokol,.t.)
      next
    endif
  next
  if nTypeFile == _CSV_FILE_PRIKFLK
    select KRTR
    goto (nkod_reestr)
    if jp == krtr->kol
      k := krtr->kol
    endif
    if k != krtr->kol
      select KRTP
      go top
      do while !eof()
        if krtp->OPLATA == 0 // т.е. не было в файле ответа
          G_RLock(forever)
          ++je
          krtp->OPLATA := 2
          krtp->D_PRIK1 := ctod("")
          dbUnLock()
          select KART
          goto (krtp->KOD_K)
          s := lstr(krtp->REES_ZAP)+". "+alltrim(kart->fio)+" - ошибка"
          strfile(s+hb_eol(),cFileProtokol,.t.)
          select KRTE
          find (str(nkod_reestr,6)+str(krtp->REES_ZAP,6)+str(99,3))
          if !found()
            AddRec(6)
            krte->REESTR := nkod_reestr
            krte->REES_ZAP := krtp->REES_ZAP
            krte->KOD_K := krtp->KOD_K
            krte->REFREASON := 99
            dbUnLock()
          endif
          strfile(space(len(lstr(krtp->REES_ZAP))+2)+lstr(krte->REFREASON)+" "+;
                  inieditspr(A__MENUVERT,mm_err_csv_prik,krte->REFREASON)+;
                  hb_eol(),cFileProtokol,.t.)
        endif
        select KRTP
        skip
      enddo
    endif
  endif
  select KRTR
  goto (nkod_reestr)
  G_RLock(forever)
  krtr->ANSWER := 1  // 1-был прочитан ответ
  if nTypeFile == _CSV_FILE_PRIKFLK
    krtr->KOL_P := jp
  endif
  //
  krtf->TWORK2 := hour_min(seconds())
  dbUnLockAll()
  Commit
endif
rest_box(buf)
return NIL

*

#define CSV_A_NREC   1
#define CSV_A_PID    2
#define CSV_A_ENP    3
#define CSV_A_MO     4
#define CSV_A_DT     5
#define CSV_A_D_PRIK 6
#define CSV_A_STATUS 7
#define CSV_A_CERR   8

***** 05.08.18 чтение в память и анализ CSV-файла ответа на файл прикрепления
Function read_CSV_FILE_ANSWER(cFile,aerr,nkod_reestr)
Local i, j, s, arr_csv, kol1 := 0, mmo_pr, md_prik, ar[2], fl_et, buf := save_maxrow()
stat_msg("Чтение файла "+upper(StripPath(cFile)))
fp := fcreate(cFileProtokol) ; tek_stroke := 0 ; n_list := 1
add_string(space(10)+"Протокол обработки файла "+upper(StripPath(cFile)))
add_string(space(10)+full_date(sys_date)+"г. "+cTimeBegin)
add_string(space(10)+"Протокол обработки для файла прикрепления")
add_string("")
Use_base("kartotek")
// список прикреплений по пациенту во времени
G_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
// список карточек в реестрах на прикрепление
G_Use(dir_server+"mo_krtp",,"KRTP")
index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == nkod_reestr
// список ошибок в реестрах на прикрепление
G_Use(dir_server+"mo_krte",,"KRTE")
index on str(reestr,6)+str(rees_zap,6)+str(REFREASON,3) to (cur_dir+"tmp_krte")
// открыть собственный сегмент застрахованных
G_Use(dir_server+"kart_et")
index on str(kod_tf,10) to (cur_dir+"tmp_kart_et")
G_Use(dir_server+"kart_etk")
index on str(kod_k,7) to (cur_dir+"tmp_kart_etk")
// Реестр сведений о прикреплении
G_Use(dir_server+"mo_krtr",,"KRTR")
goto (nkod_reestr)
// Список отосланных и принятых CSV-файлов
G_Use(dir_server+"mo_krtf",,"KRTF")
index on str(kod,6) to (cur_dir+"tmp_krtf")
arr_csv := read_CSV_to_array(cFile)
k := len(arr_csv)
if k != krtr->kol
  fclose(fp)
  aadd(aerr,"В файле запроса "+lstr(krtr->kol)+" пациентов, а в файле ответа "+lstr(k)+". Ошибка!")
  return NIL
endif
for i := 1 to k
  arr_csv[i,CSV_A_NREC]   := int(val(arr_csv[i,CSV_A_NREC]))
  arr_csv[i,CSV_A_PID]    := int(val(arr_csv[i,CSV_A_PID]))
  arr_csv[i,CSV_A_DT]     := stod(arr_csv[i,CSV_A_DT])
  arr_csv[i,CSV_A_D_PRIK] := stod(arr_csv[i,CSV_A_D_PRIK])
  arr_csv[i,CSV_A_STATUS] := int(val(arr_csv[i,CSV_A_STATUS]))
  select KRTP
  find (str(arr_csv[i,CSV_A_NREC],6))
  if found()
    select KART
    goto (krtp->KOD_K)
    if !eq_any(arr_csv[i,CSV_A_STATUS],1,2)
      aadd(aerr,"У пациента с номером записи "+lstr(arr_csv[i,CSV_A_NREC])+" не тот статус операции = "+lstr(arr_csv[i,CSV_A_STATUS]))
    elseif arr_csv[i,CSV_A_STATUS] == 1 .and. empty(arr_csv[i,CSV_A_D_PRIK])
      aadd(aerr,"У пациента с номером записи "+lstr(arr_csv[i,CSV_A_NREC])+" статус операции = 1 и нет даты прикрепления")
    endif
  else
    aadd(aerr,"Не найден пациент с номером записи "+lstr(arr_csv[i,CSV_A_NREC]))
  endif
  // сбор ошибок в массив
  s := arr_csv[i,CSV_A_CERR]
  arr_csv[i,CSV_A_CERR] := {}
  if !empty(s)
    for j := 1 to numtoken(s,",",1)
      aadd(arr_csv[i,CSV_A_CERR], int(val(alltrim(token(s,",",j,1)))))
    next
  endif
next
if empty(aerr)
  select KRTF
  AddRec(6)
  krtf->KOD   := recno()
  krtf->FNAME := cReadFile
  krtf->DFILE := krtr->DFILE
  krtf->TFILE := hour_min(seconds())
  krtf->TIP_IN := _CSV_FILE_ANSWER
  krtf->TIP_OUT := 0
  krtf->DREAD := sys_date
  krtf->TREAD := hour_min(seconds())
  krtf->DWORK := sys_date
  krtf->TWORK1 := cTimeBegin
  krtf->KOL := k
  krtf->REESTR := nkod_reestr
  krtf->MO_PR := ""
  for i := 1 to k
    @ maxrow(),0 say str(i/k*100,6,2)+"%" color cColorSt2Msg
    select KRTP
    find (str(arr_csv[i,CSV_A_NREC],6))
    G_RLock(forever)
    krtp->OPLATA := arr_csv[i,CSV_A_STATUS]
    krtp->D_PRIK1 := iif(arr_csv[i,CSV_A_STATUS]==1, arr_csv[i,CSV_A_D_PRIK], ctod(""))
    dbUnLock()
    select KART
    goto (krtp->KOD_K)
    s := lstr(arr_csv[i,CSV_A_NREC])+". "+alltrim(kart->fio)+" (д.р."+full_date(kart->date_r)+") "
    s_death := '0' ; n_del := 0 ; fl_et := .f.
    if krtp->OPLATA == 1
      if empty(arr_csv[i,CSV_A_PID])
        s += "не прикрепл"+iif(kart->pol=="М","ён","ена")+hb_eol()+;
             space(len(lstr(i))+2)+"(проверьте реквизиты пациента / отправьте ХОДАТАЙСТВО в ТФОМС)"
        add_string(s)
      else
        s += "ПРИКРЕПЛ"+iif(kart->pol=="М","ЁН","ЕНА")+" с "+date_8(arr_csv[i,CSV_A_D_PRIK])
        add_string(s)
        ++kol1
        // если прикреплён к нам - запоминаем
        select KARTP
        find (str(krtp->KOD_K,7)+dtos(arr_csv[i,CSV_A_D_PRIK]))
        if found()
          G_RLock(forever)
        else
          AddRec(7)
          kartp->KOD_K := krtp->KOD_K
          kartp->D_PRIK := arr_csv[i,CSV_A_D_PRIK]
        endif
        kartp->MO_PR := glob_mo[_MO_KOD_TFOMS]
        kartp->DFILE := krtr->DFILE
        kartp->SNILS_VR := krtp->SNILS_VR
        fl_et := f_put_et_etk(arr_csv[i,CSV_A_PID],arr_csv[i,CSV_A_ENP],;
                              arr_csv[i,CSV_A_D_PRIK],krtp->UCHAST,;
                              glob_mo[_MO_KOD_TFOMS],krtp->SNILS_VR,kart->kod,2)
      endif
    else
      if !emptyany(arr_csv[i,CSV_A_MO],arr_csv[i,CSV_A_DT])
        // если прислано прикрепление (м.б.не наше) - запоминаем
        select KARTP
        find (str(krtp->KOD_K,7)+dtos(arr_csv[i,CSV_A_DT]))
        if found()
          G_RLock(forever)
        else
          AddRec(7)
          kartp->KOD_K := krtp->KOD_K
          kartp->D_PRIK := arr_csv[i,CSV_A_DT]
        endif
        kartp->MO_PR := arr_csv[i,CSV_A_MO]
        kartp->DFILE := krtr->DFILE     // заносим дату файла
        if !(kartp->MO_PR == glob_mo[_MO_KOD_TFOMS])
          kartp->SNILS_VR := ""
        endif
        s += hb_eol()+;
             space(len(lstr(i))+2)+"(уже прикрепл"+iif(kart->pol=="М","ён","ена")+;
             " с "+date_8(arr_csv[i,CSV_A_DT])+;
             " к "+ret_mo(arr_csv[i,CSV_A_MO])[_MO_SHORT_NAME]+")"
        fl_et := f_put_et_etk(arr_csv[i,CSV_A_PID],arr_csv[i,CSV_A_ENP],;
                              arr_csv[i,CSV_A_DT],0,;
                              arr_csv[i,CSV_A_MO],"",kart->kod,0)
      else
        s += "не прикрепл"+iif(kart->pol=="М","ён","ена")
        // в этом случае в kart_et(k) не удаляем/не изменяем ничего
      endif
      add_string(s)
      for j := 1 to len(arr_csv[i,CSV_A_CERR])
        select KRTE
        find (str(nkod_reestr,6)+str(arr_csv[i,CSV_A_NREC],6)+str(arr_csv[i,CSV_A_CERR,j],3))
        if found()
          G_RLock(forever)
        else
          AddRec(6)
          krte->REESTR := nkod_reestr
          krte->REES_ZAP := arr_csv[i,CSV_A_NREC]
          krte->REFREASON := arr_csv[i,CSV_A_CERR,j]
        endif
        krte->KOD_K := krtp->KOD_K
        dbUnLock()
        s := lstr(krte->REFREASON)+" "+rtrim(inieditspr(A__MENUVERT,mm_err_csv_prik,krte->REFREASON))
        if krte->REFREASON == 525
          s += " ("+alltrim(arr_csv[i,CSV_A_ENP])+")"
        elseif krte->REFREASON == 704 // Дата прикрепления больше даты смерти
          s_death := '1' // Застрахованный умер до отправки файла MO2...
        elseif eq_any(krte->REFREASON,404,703)
          n_del := 1
        endif
        n := len(lstr(i))+2
        for j1 := 1 to perenos(ar,s,80-n)
          add_string(space(n)+ar[j1])
        next
      next
      if fl_et // если найден или добавлен в "kart_et"
        kart_et->PC2 := s_death
      endif
    endif
    f_put_date_prik(krtp->KOD_K,arr_csv[i,CSV_A_PID],arr_csv[i,CSV_A_ENP],3,s_death,n_del)
    if i % 2000 == 0
      dbUnLockAll()
      Commit
    endif
  next
  dbUnLockAll()
  Commit
  select KRTR
  goto (nkod_reestr)
  G_RLock(forever)
  krtr->KOL_P := kol1
  krtr->ANSWER := 1  // 0-не было ответа, 1-был прочитан ответ
  //
  select KRTF
  G_RLock(forever)
  krtf->TWORK2 := hour_min(seconds())
  dbUnLockAll()
  Commit
endif
fclose(fp)
rest_box(buf)
return NIL

*

#define CSV_O_PID    1
#define CSV_O_ENP    2
#define CSV_O_MO1    3
#define CSV_O_DT1    4
#define CSV_O_TIPP   5
#define CSV_O_SNP    6
#define CSV_O_ENP_   7
#define CSV_O_FAM    8
#define CSV_O_IM     9
#define CSV_O_OT    10
#define CSV_O_DR    11
#define CSV_O_MR    12
#define CSV_O_TIPD  13
#define CSV_O_SND   14
#define CSV_O_DVD   15
#define CSV_O_OVD   16
#define CSV_O_SNILS 17
#define CSV_O_MO    18
#define CSV_O_SPR   19
#define CSV_O_TPR   20
#define CSV_O_DPR   21

***** 05.11.15 чтение в память и анализ CSV-файла открепления
Function read_CSV_FILE_OTKREP(cFile,aerr)
Local i, j, s, arr_csv, kol1 := 0, md_prik, mmo1, mmo2, buf := save_maxrow()
mmo1 := substr(cReadFile,3,6)  // предыдущее МО прикрепления
mywait()
strfile(space(10)+"Протокол обработки для файла открепления"+;
        hb_eol()+hb_eol(),cFileProtokol,.t.)
Use_base("kartotek")
// список прикреплений по пациенту во времени
G_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
// список карточек в реестрах на открепление
G_Use(dir_server+"mo_krto",,"KRTO")
index on str(kod_krtf,6) to (cur_dir+"tmp_krto")
// открыть собственный сегмент застрахованных
G_Use(dir_server+"kart_et")
index on str(kod_tf,10) to (cur_dir+"tmp_kart_et")
G_Use(dir_server+"kart_etk")
index on str(kod_k,7) to (cur_dir+"tmp_kart_etk")
// Список отосланных и принятых CSV-файлов
G_Use(dir_server+"mo_krtf",,"KRTF")
index on str(kod,6) to (cur_dir+"tmp_krtf")
arr_csv := read_CSV_to_array(cFile)
for i := 1 to len(arr_csv)
  arr_csv[i,CSV_O_PID] := int(val(arr_csv[i,CSV_O_PID]))
  arr_csv[i,CSV_O_TIPD] := int(val(arr_csv[i,CSV_O_TIPD]))
  if empty(arr_csv[i,CSV_O_MO1])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введено предыдущее МО прикрепления")
  elseif !(arr_csv[i,CSV_O_MO1] == mmo1)
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" неверное предыдущее МО прикрепления="+arr_csv[i,CSV_O_MO1])
  endif
  arr_csv[i,CSV_O_DT1] := stod(arr_csv[i,CSV_O_DT1])
  if empty(arr_csv[i,CSV_O_DT1])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введена дата открепления от пред.МО")
  endif
  if empty(arr_csv[i,CSV_O_FAM])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введена фамилия")
  endif
  if empty(arr_csv[i,CSV_O_IM])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введено имя")
  endif
  arr_csv[i,CSV_O_DR] := stod(arr_csv[i,CSV_O_DR])
  if empty(arr_csv[i,CSV_O_DR])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введена дата рождения")
  endif
  if empty(arr_csv[i,CSV_O_MO])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введено МО прикрепления")
  else
    mmo2 := arr_csv[i,CSV_O_MO]
  endif
  arr_csv[i,CSV_O_DPR] := stod(arr_csv[i,CSV_O_DPR])
  if empty(arr_csv[i,CSV_O_DPR])
    aadd(aerr,"У пациента с номером записи "+lstr(i)+" не введена дата прикрепления")
  endif
next
if empty(aerr)
  select KRTF
  AddRec(6)
  krtf->KOD   := recno()
  krtf->FNAME := cReadFile
  krtf->DFILE := stod(substr(cReadFile,9,8))
  krtf->TFILE := hour_min(seconds())
  krtf->TIP_IN := _CSV_FILE_OTKREP
  krtf->TIP_OUT := 0
  krtf->DREAD := sys_date
  krtf->TREAD := hour_min(seconds())
  krtf->DWORK := sys_date
  krtf->TWORK1 := cTimeBegin
  krtf->REESTR := 0
  krtf->MO_PR := mmo2
  for i := 1 to len(arr_csv)
    afio := {arr_csv[i,CSV_O_FAM],arr_csv[i,CSV_O_IM],arr_csv[i,CSV_O_OT]}
    mfio := alltrim(afio[1])+" "+alltrim(afio[2])+" "+alltrim(afio[3])
    lkod_k := 0 ; mfio := padr(mfio,50)
    select KART
    set order to 2
    s := upper(left(mfio,20))
    find ("1"+s)
    do while s == upper(left(kart->fio,20)) .and. !eof()
      if upper(mfio)==upper(kart->fio) .and. arr_csv[i,CSV_O_DR]==kart->DATE_R
        lkod_k := kart->kod ; exit
      endif
      skip
    enddo
    select KRTO
    AddRec(6)
    krto->kod_krtf := krtf->KOD // код по файлу "mo_krtf"
    krto->kod_tf := arr_csv[i,CSV_O_PID] // код по кодировке ТФОМС (PID)
    krto->KOD_K := lkod_k // код пациента по файлу "kartotek", если найден
    krto->MO_PR  := arr_csv[i,CSV_O_MO]  // код МО прикрепления
    krto->D_PRIK := arr_csv[i,CSV_O_DPR] // дата прикрепления
    krto->FILE_ZAP := i  // номер строки в файле
    s := lstr(i)+". "+alltrim(mfio)+;
         " (д.р."+full_date(arr_csv[i,CSV_O_DR])+") "+date_8(arr_csv[i,CSV_O_DT1])+" откреплён от Вашего МО"
    strfile(s+hb_eol(),cFileProtokol,.t.)
    s := space(len(lstr(i))+2)+"и прикреплён "+date_8(arr_csv[i,CSV_O_DPR])+" к: "+ret_mo(arr_csv[i,CSV_O_MO])[_MO_SHORT_NAME]
    strfile(s+hb_eol(),cFileProtokol,.t.)
    if lkod_k > 0 // нашли в картотеке
      // старое прикрепление даже не проверяем
      if valtype(arr_csv[i,CSV_O_DPR]) == "D"
        // занесём новое прикрепление
        select KARTP
        find (str(lKOD_K,7)+dtos(arr_csv[i,CSV_O_DPR]))
        if found()
          G_RLock(forever)
        else
          AddRec(7)
          kartp->KOD_K := lKOD_K
          kartp->D_PRIK := arr_csv[i,CSV_O_DPR]
        endif
        kartp->MO_PR := arr_csv[i,CSV_O_MO]
        kartp->DFILE := krtf->DFILE
        if !(kartp->MO_PR == glob_mo[_MO_KOD_TFOMS])
          kartp->SNILS_VR := ""
        endif
        dbUnLock()
      endif
      select kart_et
      find (str(arr_csv[i,CSV_O_PID],10))
      if found()
        G_RLock(forever)
        kart_et->kod_mis := arr_csv[i,CSV_O_ENP]
        kart_et->DATE_PR := arr_csv[i,CSV_O_DPR]
        kart_et->MO_PR   := arr_csv[i,CSV_O_MO] // не к нам
        dbUnLock()
      endif
      select kart_etk
      find (str(lkod_k,7))
      if found()
        G_RLock(forever)
        kart_etk->kod_tf := arr_csv[i,CSV_O_PID] // перезаписать PID
        kart_etk->PRIOR := 0
        dbUnLock()
      endif
      f_put_date_prik(lKOD_K,arr_csv[i,CSV_O_PID],arr_csv[i,CSV_O_ENP],4)
    else
      j := len(lstr(i))+2
      s := space(j)+"!!! данный пациент не найден в нашей картотеке по ключу ФИО+дата рождения"
      strfile(s+hb_eol(),cFileProtokol,.t.)
      s := space(j)+"PID: "+lstr(arr_csv[i,CSV_O_PID])
      strfile(s+hb_eol(),cFileProtokol,.t.)
      s := space(j)+"ЕНП: "+arr_csv[i,CSV_O_ENP]
      strfile(s+hb_eol(),cFileProtokol,.t.)
      s := space(j)+"Полис: "+iif(empty(arr_csv[i,CSV_O_SNP]), arr_csv[i,CSV_O_ENP_], arr_csv[i,CSV_O_SNP])
      strfile(s+hb_eol(),cFileProtokol,.t.)
      s := space(j)+"Место рождения: "+arr_csv[i,CSV_O_MR]
      strfile(s+hb_eol(),cFileProtokol,.t.)
      s := space(j)+inieditspr(A__MENUVERT, menu_vidud,  arr_csv[i,CSV_O_TIPD])+" "+arr_csv[i,CSV_O_SND]
      strfile(s+hb_eol(),cFileProtokol,.t.)
    endif
  next
  //
  krtf->KOL := len(arr_csv)
  krtf->TWORK2 := hour_min(seconds())
  dbUnLockAll()
endif
rest_box(buf)
return NIL

*

#define CSV_A_NREC   1
#define CSV_A_PID    2
#define CSV_A_ENP    3
#define CSV_A_MO     4
#define CSV_A_PODR   5
#define CSV_A_UCH    6
#define CSV_A_VRACH  7
#define CSV_A_DT     8
#define CSV_A_DT_MO  9
#define CSV_A_CERR  10

***** 15.10.17 чтение в память и анализ CSV-файла ответа на запрос для сверки
Function read_CSV_FILE_SVERKAO(cFile,aerr,nkod_reestr)
Local i, j, k1, k, s, arr_csv, te := {}, kol1 := 0, kol2 := 0, kol3 := kol4 := 0,;
      fl_et, au := {}, mmo_pr, md_prik, buf := save_maxrow()
stat_msg("Предварительная обработка")
strfile(space(10)+"Протокол обработки для файла ответа на запрос по сверке"+;
        hb_eol()+hb_eol(),cFileProtokol,.t.)
Use_base("kartotek")
// список прикреплений по пациенту во времени
G_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
// список карточек в реестрах на прикрепление
G_Use(dir_server+"mo_krtp",,"KRTP")
index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == nkod_reestr
// список ошибок в реестрах на прикрепление
G_Use(dir_server+"mo_krte",,"KRTE")
index on str(reestr,6)+str(rees_zap,6)+str(REFREASON,3) to (cur_dir+"tmp_krte")
// открыть собственный сегмент застрахованных
G_Use(dir_server+"kart_et")
index on str(kod_tf,10) to (cur_dir+"tmp_kart_et")
G_Use(dir_server+"kart_etk")
index on str(kod_k,7) to (cur_dir+"tmp_kart_etk")
// Реестр сведений о прикреплении
G_Use(dir_server+"mo_krtr",,"KRTR")
goto (nkod_reestr)
// Список отосланных и принятых CSV-файлов
G_Use(dir_server+"mo_krtf",,"KRTF")
index on str(kod,6) to (cur_dir+"tmp_krtf")
arr_csv := read_CSV_to_array(cFile)
k := len(arr_csv)
if k != krtr->kol
  aadd(aerr,"В файле запроса "+lstr(krtr->kol)+" пациентов, а в файле ответа "+lstr(k)+". Ошибка!")
  return NIL
endif
for i := 1 to k
  @ maxrow(),0 say str(i/k*100,6,2)+"%" color cColorSt2Msg
  arr_csv[i,CSV_A_NREC]  := int(val(arr_csv[i,CSV_A_NREC]))
  arr_csv[i,CSV_A_PID]   := int(val(arr_csv[i,CSV_A_PID]))
  arr_csv[i,CSV_A_UCH]   := int(val(arr_csv[i,CSV_A_UCH]))
  arr_csv[i,CSV_A_DT]    := stod(arr_csv[i,CSV_A_DT])
  arr_csv[i,CSV_A_DT_MO] := stod(arr_csv[i,CSV_A_DT_MO])
  select KRTP
  find (str(arr_csv[i,CSV_A_NREC],6))
  if !found()
    aadd(aerr,"Не найден пациент с номером записи "+lstr(arr_csv[i,CSV_A_NREC]))
  endif
  // сбор ошибок в массив
  s := arr_csv[i,CSV_A_CERR]
  arr_csv[i,CSV_A_CERR] := {}
  if !empty(s)
    for j := 1 to numtoken(s,",",1)
      aadd(arr_csv[i,CSV_A_CERR], int(val(alltrim(token(s,",",j,1)))))
    next
  endif
next
kol_death := 0
if empty(aerr)
  stat_msg("Запись в базу данных")
  select KRTF
  AddRec(6)
  krtf->KOD   := recno()
  krtf->FNAME := cReadFile
  krtf->DFILE := krtr->DFILE
  krtf->TFILE := hour_min(seconds())
  krtf->TIP_IN := _CSV_FILE_SVERKAO
  krtf->TIP_OUT := 0
  krtf->DREAD := sys_date
  krtf->TREAD := hour_min(seconds())
  krtf->DWORK := sys_date
  krtf->TWORK1 := cTimeBegin
  krtf->KOL := k
  krtf->REESTR := nkod_reestr
  krtf->MO_PR := ""
  for i := 1 to k
    @ maxrow(),0 say str(i/k*100,6,2)+"%" color cColorSt2Msg
    mstatus := 2
    if !emptyany(arr_csv[i,CSV_A_MO],arr_csv[i,CSV_A_DT])
      if arr_csv[i,CSV_A_MO] == glob_mo[_MO_KOD_TFOMS]
        mstatus := 1
      else
        mstatus := 3
        if (j := ascan(au, {|x| x[1] == arr_csv[i,CSV_A_MO]})) == 0
          aadd(au, {arr_csv[i,CSV_A_MO],0}) ; j := len(au)
        endif
        au[j,2] ++
      endif
    endif
    select KRTP
    find (str(arr_csv[i,CSV_A_NREC],6))
    G_RLock(forever)
    krtp->OPLATA := mstatus
    krtp->UCHAST   := arr_csv[i,CSV_A_UCH] // номер участка
    krtp->SNILS_VR := arr_csv[i,CSV_A_VRACH] // СНИЛС участкового врача
    krtp->KOD_PODR := arr_csv[i,CSV_A_PODR] // код подразделения по паспорту ЛПУ
    krtp->D_PRIK1 := iif(eq_any(mstatus,1,3), arr_csv[i,CSV_A_DT], ctod(""))
    select KART
    goto (krtp->KOD_K)
    s := lstr(arr_csv[i,CSV_A_NREC])+". "+alltrim(kart->fio)+;
         " (д.р."+full_date(kart->date_r)+") "
    fl_et := .f.
    if mstatus == 2  // не прикреплён ни к кому
      ++kol2
      if empty(len(arr_csv[i,CSV_A_CERR]))
        aadd(arr_csv[i,CSV_A_CERR], -99)
      endif
      if !empty(arr_csv[i,CSV_A_PID]) // всё-таки найден в регистре застрахованных
        select kart_et
        find (str(arr_csv[i,CSV_A_PID],10))
        if found()
          G_RLock(forever)
          kart_et->kod_mis := arr_csv[i,CSV_A_ENP]
          kart_et->MO_PR   := "" // не прикреплён ни к кому
          fl_et := .t.
        endif
        select kart_etk
        find (str(kart->kod,7))
        if found()
          DeleteRec(.t.) // если ни к кому не прикреплён, - удалить совсем
        endif
      endif
    else // !emptyany(arr_csv[i,CSV_A_MO],arr_csv[i,CSV_A_DT])
      if mstatus == 1 // прикреплен к нам
        fl_et := f_put_et_etk(arr_csv[i,CSV_A_PID],arr_csv[i,CSV_A_ENP],;
                              arr_csv[i,CSV_A_DT],arr_csv[i,CSV_A_UCH],;
                              glob_mo[_MO_KOD_TFOMS],arr_csv[i,CSV_A_VRACH],;
                              kart->kod,1)
      elseif arr_csv[i,CSV_A_PID] > 0  // прикреплён не к нам
        select kart_et
        find (str(arr_csv[i,CSV_A_PID],10))
        if found()
          G_RLock(forever)
          kart_et->kod_mis := arr_csv[i,CSV_A_ENP]
          kart_et->DATE_PR := arr_csv[i,CSV_A_DT]
          kart_et->MO_PR   := arr_csv[i,CSV_A_MO]
          fl_et := .t.
        endif
        select kart_etk
        find (str(kart->kod,7))
        if found()
          G_RLock(forever)
          kart_etk->kod_tf := arr_csv[i,CSV_A_PID]
          kart_etk->PRIOR := 0 // приоритет = 0
        endif
      endif
      // занесём указанное прикрепление
      select KARTP
      find (str(krtp->KOD_K,7)+dtos(arr_csv[i,CSV_A_DT]))
      if found()
        G_RLock(forever)
      else
        AddRec(7)
        kartp->KOD_K := krtp->KOD_K
        kartp->D_PRIK := arr_csv[i,CSV_A_DT]
      endif
      kartp->DFILE := krtr->DFILE
      kartp->MO_PR := arr_csv[i,CSV_A_MO]
      if kartp->MO_PR == glob_mo[_MO_KOD_TFOMS]
        kartp->SNILS_VR := krtp->SNILS_VR
      else
        kartp->SNILS_VR := ""
      endif
      if krtp->OPLATA == 1
        ++kol1
      else
        ++kol3
      endif
    endif
    s_death := '0' ; n_del := 0
    for j := 1 to len(arr_csv[i,CSV_A_CERR])
      select KRTE
      find (str(nkod_reestr,6)+str(arr_csv[i,CSV_A_NREC],6)+str(arr_csv[i,CSV_A_CERR,j],3))
      if found()
        G_RLock(forever)
      else
        AddRec(6)
        krte->REESTR := nkod_reestr
        krte->REES_ZAP := arr_csv[i,CSV_A_NREC]
        krte->REFREASON := arr_csv[i,CSV_A_CERR,j]
      endif
      krte->KOD_K := krtp->KOD_K
      if (j1 := ascan(te,{|x| x[1] == krte->REFREASON})) == 0
        aadd(te,{krte->REFREASON,0}) ; j1 := len(te)
      endif
      te[j1,2] ++
      if krte->REFREASON == 706
        s_death := '1' // Застрахованный умер
      endif
      if eq_any(krte->REFREASON,706,708,709,802,803)
        n_del := 1
      endif
    next
    if fl_et // если найден или добавлен в "kart_et"
      kart_et->PC2 := s_death
    endif
    kol4 := f_put_date_prik(krtp->KOD_K,;
                            arr_csv[i,CSV_A_PID],;
                            arr_csv[i,CSV_A_ENP],;
                            5,;
                            s_death,;
                            n_del,;
                            arr_csv[i,CSV_A_MO],arr_csv[i,CSV_A_DT_MO])
    if i % 2000 == 0
      dbUnLockAll()
      Commit
    endif
  next
  dbUnLockAll()
  Commit
  select KRTR
  goto (nkod_reestr)
  G_RLock(forever)
  krtr->KOL_P := kol1
  krtr->ANSWER := 1  // 0-не было ответа, 1-был прочитан ответ
  //
  select KRTF
  G_RLock(forever)
  krtf->TWORK2 := hour_min(seconds())
  dbUnLockAll()
  Commit
  strfile(hb_eol()+;
          "Обработано всего       : "+lstr(k)+hb_eol(),cFileProtokol,.t.)
  strfile("Прикреплено к нашей  МО: "+lstr(kol1)+hb_eol(),cFileProtokol,.t.)
  //strfile("---прикреплено к нашей  МО: "+lstr(kol4)+hb_eol(),cFileProtokol,.t.)
  strfile("Прикреплено к другим МО: "+lstr(kol3)+hb_eol(),cFileProtokol,.t.)
  asort(au,,,{|x,y| x[1] < y[1] })
  for j := 1 to len(au)
    strfile(padl(iif(j==1,"в т.ч.",""),15)+str(au[j,2],6)+" - "+ret_mo(au[j,1])[_MO_SHORT_NAME]+hb_eol(),cFileProtokol,.t.)
  next
  asort(te,,,{|x,y| x[1] < y[1] })
  strfile("Список ошибок:"+hb_eol(),cFileProtokol,.t.)
  Private mm_err := {{'Не имеет текущего страхования',708},; // !!!
                     {'ТФОМС не вернул никакой информации',-99}} // !!!
  for j1 := 1 to len(te)
    if ascan(mm_err,{|x| x[2] == te[j1,1]}) > 0
      s := inieditspr(A__MENUVERT,mm_err,te[j1,1])
    else
      s := inieditspr(A__MENUVERT,mm_err_csv_prik,te[j1,1])
    endif
    strfile(str(te[j1,2],6)+" чел. - "+str(te[j1,1],3)+" "+s+hb_eol(),cFileProtokol,.t.)
  next
endif
rest_box(buf)
return NIL

*

***** 05.11.15
Function f_put_et_etk(lpid,lenp,ld_prik,luchast,lmo,lsnils,lkod_k,lprior)
Local fl_et := .f.
if lpid > 0
  select kart_et
  find (str(lpid,10))
  if found()
    G_RLock(forever)
  else
    AddRec(10)
    kart_et->kod_tf := lpid
  endif
  kart_et->MO_PR := lmo
  if iif(between(lprior,1,2), .t., empty(kart_et->kod_mis))
    kart_et->kod_mis := lenp
  endif
  if iif(between(lprior,1,2), .t., empty(kart_et->DATE_PR))
    kart_et->DATE_PR := ld_prik
  endif
  if !empty(luchast)
    kart_et->UCHAST := luchast // номер участка
  endif
  if !empty(lsnils)
    kart_et->SNILS_VR := lsnils  // СНИЛС участкового врача
  endif
  //
  fl_et := .t.
  select kart_etk
  find (str(lkod_k,7))
  if found()
    G_RLock(forever)
  else
    AddRec(10)
    kart_etk->kod_k := lkod_k
    if lprior == 1
      kart_etk->PRIOR := lprior // приоритет = 1 для сверки
    endif
  endif
  kart_etk->kod_tf := lpid
  if eq_any(lprior,0,2)
    kart_etk->PRIOR := lprior // приоритет = 2 для MO2 (или 0 для не наших)
  endif
endif
return fl_et

*

***** 10.03.18
Function f_put_date_prik(lkod_k,lpid,lenp,ltip_pr,ldeath,_n_del,lprik_mo,ldate_prik_mo)
Static j := 0
Local old_pr, arr := {}
DEFAULT _n_del TO 0, lprik_mo TO "", ldate_prik_mo TO ctod("")
select KARTP
find (str(lkod_k,7))
do while kartp->KOD_K == lkod_k .and. !eof()
  aadd(arr,{kartp->MO_PR,;
            kartp->D_PRIK,;
            kartp->SNILS_VR,;
            iif(empty(kartp->DFILE),kartp->D_PRIK,kartp->DFILE);
           };
      )
  skip
enddo
select KART2
do while kart2->(lastrec()) < lkod_k
  G_RLock(.t.,forever) // бесконечная попытка добавить запись
  kart2->kod_tf := 0
  kart2->MO_PR := ""
  kart2->SNILS_VR := "" // уч.врач ещё не привязан
  kart2->PC2 := ""      // не умер
  kart2->PC4 := ""
enddo
goto (lkod_k)
G_RLock(forever)
if !empty(lpid)
  kart2->kod_tf := lpid
endif
if !empty(lenp)
  kart2->kod_mis := lenp
endif
if ldeath != NIL
  kart2->PC2 := ldeath
endif
if empty(arr)
  if _n_del == 1
    kart2->MO_PR := ""
  endif
else
  old_pr := kart2->MO_PR // то, что было записано
  //if len(arr) > 1 .and. !empty(arr[2,1])
    //old_pr := arr[2,1] // предыдущее прикрепление
  //endif
  asort(arr,,,{|x,y| x[4] > y[4]}) // в порядке убывания даты файла
  kart2->TIP_PR   := ltip_pr
  kart2->MO_PR    := iif(_n_del == 1, "", arr[1,1])
  kart2->DATE_PR  := arr[1,2]
  kart2->SNILS_VR := arr[1,3]
  if ltip_pr == 3
    if !empty(kart2->MO_PR) .and. (!(old_pr == kart2->MO_PR) .or. empty(kart2->pc4))
      kart2->pc4 := date_8(kart2->DATE_PR)
    endif
  elseif ltip_pr == 4
    kart2->pc4 := date_8(kart2->DATE_PR)
  elseif !emptyany(lprik_mo,ldate_prik_mo) .and. lprik_mo == kart2->MO_PR
    kart2->pc4 := date_8(ldate_prik_mo)
  endif
endif
if kart2->MO_PR == glob_MO[_MO_KOD_TFOMS]
  ++j
endif
return j

*

***** 05.07.15 быстрое редактирование участков списком
Function edit_uchast_spisok()
Local flag := .T. //фильтр
Local arr_pr := {{"к нашему МО",0},;
                 {"все пациенты",1}}
Local arr_sr := {{"по ФИО",0},;
                 {"по адресу",1},;
                 {"по месту работы",2}}
Local arr_voz := {{"все пациенты",0},;
                  {"взрослые",1},;
                  {"дети",2}}
Local t_okato, t_rec, len_fio, buf := savescreen()
// Номер участка
Local fl_uchast := 0
// Взрослый/Ребёнок
Local fl_vzros_reb := 0 //по умолчанию взрослый
// Окато - населённый пункт прописка
Local fl_okato := okato_umolch
// Прикрепление
Local fl_pr := 0 //
// фильтр АДРЕС
Local fl_adres := space(20) //
// фильтр ДОЛЖНОСТЬ
Local fl_dol := space(20) //
// фильтр ФИО
Local fl_fio := space(20) //
//Сортировать
Local fl_sort := 0
// ДИАЛОГ -заготовка
Private mfl_vzros_reb, m1fl_vzros_reb := fl_vzros_reb,;
        muchast := "все пациенты", m1uchast := 0,;
        mokatog := space(10), m1okatog := space(11),;
        mokatop := space(10), m1okatop := space(11),;
        mfl_pr, m1fl_pr := fl_pr,;
        mfl_adres := fl_adres, mfl_dol := fl_dol,;
        mfl_fio := fl_fio ,;
        mfl_sort, m1fl_sort := fl_sort
mfl_vzros_reb := inieditspr(A__MENUVERT,arr_voz,m1fl_vzros_reb)
mfl_pr   := inieditspr(A__MENUVERT,arr_pr,m1fl_pr)
mfl_sort := inieditspr(A__MENUVERT,arr_sr,m1fl_sort)
//
Private arr_uchast := {}
setcolor(cDataCGet)
ix := 12
ClrLines(ix,23)
@ ix,0 to ix,79
str_center(ix," Запрос для составления списка ")
++ix
@ ++ix,3 say "Участок (участки)" get muchast ;
              reader {|x|menu_reader(x,;
                         {{ |k,r,c| get_uchast(r+1,c) }},A__FUNCTION,,,.f.)}
@ ++ix,3 say "Прикрепление" get mfl_pr ;
                  reader {|x|menu_reader(x,arr_pr,A__MENUVERT,,,.f.)}
@ ++ix,3 say "Возраст" get mfl_vzros_reb  ;
                  reader {|x|menu_reader(x,arr_voz,A__MENUVERT,,,.f.)}
@ ++ix,3 say "Адрес регистрации (ОКАТО)" get mokatog ;
  reader {|x| menu_reader(x,{{|k,r,c| get_okato_ulica(k,r,c,{k,mokatog,})}},A__FUNCTION,,,.f.)}
@ ++ix,3 say "Адрес пребывания (ОКАТО)" get mokatop ;
  reader {|x| menu_reader(x,{{|k,r,c| get_okato_ulica(k,r,c,{k,mokatop,})}},A__FUNCTION,,,.f.)}
@ ++ix,3 say "Улица (подстрока или шаблон)" get mfl_adres pict "@!"
@ ++ix,3 say "Место работы (подстрока или шаблон)" get mfl_dol pict "@!"
@ ++ix,3 say "Фамилия (начальные буквы)" get mfl_fio pict "@!"
@ ++ix,3 say "Как сортировать список пациентов" get mfl_sort  ;
                  reader {|x|menu_reader(x,arr_sr,A__MENUVERT,,,.f.)}
status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода и создание списка пациентов")
myread()
if lastkey() == K_ESC .or. !f_Esc_Enter(1)
  restscreen(buf)
  return NIL
endif
mywait()
dbcreate(cur_dir+"tmp_krtp",{{"KOD_K","N",7,0}})
use (cur_dir+"tmp_krtp") new
// Фильтр по ФИО
if !empty(mfl_fio)
  mfl_fio := upper(alltrim(mfl_fio))
  len_fio := len(mfl_fio)
endif
index on str(kod_k,7) to (cur_dir+"tmp_wq")
Use_base("kartotek")
go top
do while !eof()
  flag := (kart->kod > 0 .and. !(left(kart2->PC2,1)=='1'))
  //участки
  if flag .and. !empty(muchast)
    flag := f_is_uchast(arr_uchast,kart->uchast)
  endif
  // Взрослый/Ребёнок
  if flag .and. m1fl_vzros_reb > 0
    if m1fl_vzros_reb == 1 // взрослые
      if !(count_years(kart->date_r,sys_date) >= 18)
        flag := .F.
      endif
    else // дети
      if !(count_years(kart->date_r,date()) < 18)
        flag := .F.
      endif
    endif
  endif
  // Окато
  if flag .and. !empty(m1okatog)
    s := m1okatog
    for i := 1 to 3
      if right(s,3)=='000'
        s := left(s,len(s)-3)
      else
        exit
      endif
    next
    flag := (left(kart_->okatog,len(s))==s)
  endif
  if flag .and. !empty(m1okatop)
    s := m1okatop
    for i := 1 to 3
      if right(s,3)=='000'
        s := left(s,len(s)-3)
      else
        exit
      endif
    next
    flag := (left(kart_->okatop,len(s))==s)
  endif
  if flag .and. m1fl_pr == 0 // прикреплён к НАМ
    flag := (kart2->mo_pr == glob_MO[_MO_KOD_TFOMS])
  endif
  // Фильтр по адресу
  if flag .and. !empty(mfl_adres)
    if "*" $  mfl_adres .or. "?" $ mfl_adres
      flag := like(alltrim(mfl_adres),upper(kart->adres))
    else
      flag := (alltrim(mfl_adres) $ upper(kart->adres))
    endif
  endif
  // Фильтр по работе
  if flag .and. !empty(mfl_dol)
    if "*" $  mfl_dol .or. "?" $ mfl_dol
      flag := like(alltrim(mfl_dol),upper(kart->mr_dol))
    else
      flag := (alltrim(mfl_dol) $ upper(kart->mr_dol))
    endif
  endif
  // Фильтр по ФИО
  if flag .and. !empty(mfl_fio)
    flag := (mfl_fio == upper(left(kart->fio,len_fio)))
  endif
  // Добавляем запись
  if flag
    select TMP_KRTP
    append blank
    tmp_krtp->KOD_K := kart->(recno())
  endif
  select KART
  skip
enddo
Private ku := tmp_krtp->(lastrec())
close databases
if ku == 0
  restscreen(buf)
  return func_error(4,"По данному условию отбора ничего не найдено!")
endif
//
Private TIP_uchast  := 1 // 1-адрес 2-работа
G_Use(dir_server+"kartotek",{dir_server+"kartotek",;
                             dir_server+"kartoten",;
                             dir_server+"kartotep",;
                             dir_server+"kartoteu"},"KART")
set order to 0
use (cur_dir+"tmp_krtp") new
set relation to kod_k into KART
// устанавливаем реляцию
if m1fl_sort ==  0 //по фио
  index on upper(kart->fio) to (cur_dir+"tmp_ru")
elseif m1fl_sort ==  1 // по адресу
  index on upper(kart->adres) to (cur_dir+"tmp_ru")
else
  index on upper(kart->mr_dol) to (cur_dir+"tmp_ru")
  TIP_uchast := 2 // 1-адрес 2-работа
endif
Alpha_Browse(2,0,23,79,"f1_vvod_uchast_spisok",color0,"Редактирование участка ("+lstr(ku)+" чел.)","BG+/GR",;
             .t.,.t.,,,"f2_vvod_uchast_spisok",,;
             {"═","░","═","N/BG,W+/N,B/BG,W+/B,R/BG,BG/R",.t.,180,"*+"} )
close databases
restscreen(buf)
return NIL

*

***** 29.05.15
Function f1_vvod_uchast_spisok(oBrow)
Local oColumn, blk
oColumn := TBColumnNew(center("ФИО",30),{|| padr(kart->fio,30) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дата рожд.",{|| full_date(kart->date_r) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Уч",{|| str(kart->uchast,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if TIP_uchast  == 1
  oColumn := TBColumnNew(center("Адрес",31),{|| padr(kart->adres,31) })
else
  oColumn := TBColumnNew(center("Место работы",31),{|| padr(kart->mr_dol,31) })
endif
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование участка;  ^<F9>^ - печать списка")
return NIL

*

***** 31.05.15
Function f2_vvod_uchast_spisok(nKey,oBrow)
Local j := 0, flag := -1, buf := save_maxrow(), buf1, fl := .f.,;
      nr := row(), c1, rec, mkod, buf0, tmp_color := setcolor(), t_vr,;
      vp := int(val(lstr(day(sys_date))+strzero(month(sys_date),2)))
Private  much, old_uch
do case
  case nKey == K_F10
    if ku > 10000
      func_error(4,"Слишком много пациентов в списке")
    elseif tip_polzovat != TIP_ADM
      func_error(4,err_admin)
    elseif (much := input_value(18,5,20,74,color1,;
        "Введите номер участка для простановки всем пациентам из списка",0,"99")) != NIL ;
      .and. much > 0 ;// .and. involved_password(1,vp,"смены номера участка всем пациентам из списка") ;
          .and. f_alert({padc("Выберите действие",60,".")},;
                        {" Отказ "," Сменить номер участка всем пациентам "},;
                        1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" ) == 2
      mywait()
      rec := tmp_krtp->(recno())
      go top
      do while !eof()
        kart->(G_RLock(forever))
        kart->uchast := much
        kart->(dbunlock())
        skip
      enddo
      rest_box(buf)
      select TMP_KRTP
      goto (rec)
      flag := 0
      stat_msg('Участок заменён всем пациентам!') ; mybell(1,OK)
    endif
  case nKey == K_F9
    mywait()
    rec := tmp_krtp->(recno())
    f3_vvod_uchast_spisok(TIP_uchast)
    rest_box(buf)
    select TMP_KRTP
    goto (rec)
    flag := 0
  case nKey == K_ENTER
    old_uch := much := kart->uchast
    c1 := 44
    @ nr,c1 get much pict "99" color "GR+/R"
    myread()
    if lastkey() != K_ESC .and. old_uch != much
      kart->(G_RLock(forever))
      kart->uchast := much
      kart->(dbunlock())
      keyboard chr(K_TAB)
    endif
    flag := 0
  otherwise
    keyboard ""
endcase
return flag

*

***** 28.05.15
Function f3_vvod_uchast_spisok(tip)
//tip - 1 адрес
//      2 место работы
Local sh, HH := 78, name_file := "reg_prip"+stxt,i := 0, arr_title, s
s := {"Адрес","Место работы"}[tip]
arr_title := {;
"─────┬────┬────────────────────────────────────────┬──────────┬─────────────────────────────────────────────────",;
"№ п/п│Уч-к│               Ф.И.О                    │Дата рожд.│"+center(s,50),;
"─────┴────┴────────────────────────────────────────┴──────────┴─────────────────────────────────────────────────"}
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
sh := len(arr_title[1])
add_string("")
add_string(center("Список пациентов (для ввода участка)",sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
select TMP_KRTP
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(str(++i,5)+str(kart->uchast,4)+"  "+padr(kart->fio,40)+" "+;
               full_date(kart->date_r)+" "+;
               alltrim(iif(tip==1,kart->adres,kart->mr_dol)))
  select TMP_KRTP
  skip
enddo
fclose(fp)
viewtext(name_file,,,,.t.,,,6)
return NIL
