***** mo_serv.prg - сервисы и настройки
#include "set.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 08.01.17
Function f_import(k)
Static si1 := 1, sds := 1, ssp := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 // КДП-2
  import_from_LIS()
else
  do case
    case k == 1
      mas_pmt := {"Импорт ~случаев ОМС",;
                  "Инте~грация с SDS",;
                  "Импорт из ~флюоротеки"}
      mas_msg := {"Импорт случаев ОМС (листов учёта) из других программ (в формате ЧИП плюс)",;
                  "Интеграция с программой Smart Delta Systems",;
                  'Импорт данных из программы "Флюоротека" фирмы "ЧИП плюс"'}
      mas_fun := {"f_import(11)",;
                  "f_import(12)",;
                  "f_import(13)"}
      popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
    case k == 11
      import_sluch_OMS()
    case k == 12
      integration_SDS()
    case k == 13
      import_fluoroteka()
  endcase
endif
if k > 10
  if between(k,11,19)
    si1 := int(val(right(lstr(k),1)))
  endif
endif
return NIL

***** 23.12.17
Function import_from_LIS()
Local full_o79
Private p_var_manager := "Read_from_LIS", cFileProtokol := "protokol"+stxt
//full_o79 := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"export*.o79")
full_o79 := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*.?79")
if !empty(full_o79) .and. hb_FileExists(full_o79)
  delete file (cur_dir+cFileProtokol)
  G_SPlus(f_name_task(X_OMS)) // плюс 1 пользователь зашёл в задачу ОМС
  if G_SIsLock(sem_vagno_task[X_OMS])
    f_err_sem_vagno_task(X_OMS)
  elseif lower(right(full_o79,3)) == "x79" // XML-файл
    f1_impXML_from_LIS(full_o79)
  elseif lower(right(full_o79,3)) == "o79" // текстовый файл с разделителями
    f1_import_from_LIS(full_o79)
  endif
  G_SMinus(f_name_task(X_OMS))  // минус 1 пользователь (вышел из задачи ОМС)
  if hb_FileExists(cur_dir+cFileProtokol)
    viewtext(Devide_Into_Pages(cur_dir+cFileProtokol,60,80),,,,.t.,,,2)
  endif
endif
return NIL

***** 02.03.18
Function f1_impXML_from_LIS(name_file)
Local buf := save_maxrow(), aerr := {}, arr, fl_exit := .f., fl := .f., i, j, t1, t2, s, s1
if !hb_FileExists(dir_server+"mo_flis"+sdbf)
  dbcreate(dir_server+"mo_flis", {; // Список принятых файлов из ЛИС
    {"KOD",         "N", 6,0},; // код;номер записи
    {"FNAME",       "C",50,0},; // имя файла
    {"DREAD",       "D", 8,0},; // дата чтения
    {"TREAD1",      "C", 5,0},; // время начала чтения
    {"TREAD2",      "C", 5,0},; // время окончания чтения
    {"KOLP",        "N", 6,0},; // количество пациентов
    {"KOLS",        "N", 6,0},; // количество случаев
    {"KOLU",        "N", 6,0};  // количество услуг
  })
endif
sname := StripPath(name_file)
G_Use(dir_server+"mo_flis",,"FL")
index on upper(fname) to tmp_fl
find (padr(upper(sname),50))
if found()
  if empty(fl->tread2)
    fl := f_alert({'Файл "'+alltrim(sname)+'".',;
                   "Чтение начато "+date_8(fl->dread)+" в "+fl->tread1+" и не было завершено.",;
                   "",;
                   "Выберите действие:"},;
                  {" Выход "," Попытка повторного чтения "},;
                  1,"GR+/R","W+/R",,,"GR+/R,N/BG") == 2
  else
    func_error(4,"Файл "+alltrim(sname)+" уже был прочитан "+date_8(fl->dread)+" в "+fl->tread2)
  endif
else
  fl := .t.
endif
if fl .and. f_Esc_Enter("чтения файла из ЛИС")
  select FL
  G_RLock(!found(),forever) // добавить ИЛИ заблокировать запись
  fl->KOD := recno()
  fl->FNAME := upper(sname)
  fl->DREAD := sys_date
  fl->TREAD1 := hour_min(seconds())
  fl->TREAD2 := ""
  fl->KOLP := fl->KOLS := fl->KOLU := 0
  UnLock
  Commit
  //
  t1 := seconds()
  @ maxrow(),0 say padl(sname,80) color "W/R"
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
  use_base("lusl")
  use_base("luslc")
  Use_base("uslugi")
  R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
  G_Use(dir_server+"human_u_",,"HU_")
  index on padr(zf,30) to (cur_dir+"tmp_hu_") progress
  set order to 0
  G_Use(dir_server+"human_u",{dir_server+"human_u",;
                              dir_server+"human_uk",;
                              dir_server+"human_ud",;
                              dir_server+"human_uv",;
                              dir_server+"human_ua"},"HU")
  G_Use(dir_server+"human_",,"HUMAN_")
  G_Use(dir_server+"human_2",,"HUMAN_2")
  //index on str(pn3,10) to (cur_dir+"tmp_human2") progress
  G_Use(dir_server+"human",{dir_server+"humank",;
                            dir_server+"humankk",;
                            dir_server+"humann",;
                            dir_server+"humand",;
                            dir_server+"humano",;
                            dir_server+"humans"},"HUMAN")
  G_Use(dir_server+"mo_pers",,"PERSO")
  index on snils to (cur_dir+"tmp_pers")
  set index to (cur_dir+"tmp_pers"),(dir_server+"mo_pers")
  G_Use(dir_server+"mo_kfio",,"KFIO")
  index on str(kod,7) to (cur_dir+"tmp_kfio")
  G_Use(dir_server+"mo_kismo",,"KSN")
  index on str(kod,7) to (cur_dir+"tmpkismo")
  G_Use(dir_server+"mo_hismo",,"HSN")
  index on str(kod,7) to (cur_dir+"tmphismo")
  G_Use(dir_server+"kartote_",,"KART_")
  G_Use(dir_server+"kartote2",,"KART2")
  index on kod_AK to (cur_dir+"tmp_kart2") progress
  G_Use(dir_server+"kartotek",{dir_server+"kartotek",;
                               dir_server+"kartoten",;
                               dir_server+"kartotep",;
                               dir_server+"kartoteu",;
                               dir_server+"kartotes"},"KART")
  Private such := 1, sotd := 1,; // код отделения "Лаборатория-ЛИС на Ангарском"
          sotd2 := 3 // код отделения "ЛИС в Краснооктябрьском р-не"
  Private _arr_otd := {{"MIH",1},{"ANG",2},{"MET",3}}
  for i := 1 to len(_arr_otd)
    if _arr_otd[i,1] $ upper(name_file)
      sotd2 := i
      exit
    endif
  next
  dbcreate("ttmp",{;
    {"nn","N",6,0},;
    {"ko","N",6,0},;
    {"ko1","N",6,0},;
    {"ku","N",6,0},;
    {"ku1","N",6,0},;
    {"t2","N",7,3},;
    {"t3","N",7,3},;
    {"t4","N",7,3},;
    {"fc","C",1,0}})
  use ttmp new alias TMP
  Private arr_pac[15], arr_order, arr_usl := {}, ip := 0, is := 0, isp := 0, iu := 0
  glob_podr := "" ; glob_otd_dep := 0
  fl_exit := .f.
  // читаем XML-файл
  lfp := fopen(name_file)
  do while !feof(lfp)
    s := Utf82Oem(fReadLn(lfp))
    if "<PAT " $ s
      arr := {s}
      do while !feof(lfp)
        s := fReadLn(lfp)
        aadd(arr,s)
        if "</PAT>" $ s
          exit
        endif
      enddo
      if !empty(aerr := f2_impXML_from_LIS(arr))
        fl_exit := .t.
        exit
      endif
    endif
    if inkey() == K_ESC
      fl_exit := .t.
      exit
    endif
  enddo
  fclose(lfp)
  if !fl_exit
    select FL
    G_RLock(forever) // заблокировать запись
    fl->TREAD2 := hour_min(seconds())
    fl->KOLP := ip
    fl->KOLS := is
    fl->KOLU := iu
  endif
  dbUnlockAll()
  dbCommitAll()
  close databases
  keyboard ""
  t2 := seconds() - t1
  rest_box(buf)
  if fl_exit
    arr := aclone(aerr)
    if !empty(arr)
      Ins_Array(arr,1,'Ошибка в файле "'+alltrim(sname)+'":')
    endif
    aadd(arr,"")
    aadd(arr,"Операция импорта прервана!")
  else
    arr := {'Файл "'+alltrim(sname)+'" импортирован.',;
            "",;
            "Время работы - "+sectotime(t2)+".",;
            "",;
            "Пациентов "+lstr(ip)+", случаев "+lstr(is)+iif(isp==0,""," (в т.ч.повторно "+lstr(isp)+")")+", услуг "+lstr(iu)+"."}
  endif
  n_message(arr,,"GR+/R","W+/R",,,"G+/R")
endif
close databases
rest_box(buf)
return NIL

***** 03.05.17
Function f1_import_from_LIS(name_file)
Local buf := save_maxrow(), aerr := {}, arr, fl_exit, fl := .f., i, j, t1, t2, s, s1, iencode
if !hb_FileExists(dir_server+"mo_flis"+sdbf)
  dbcreate(dir_server+"mo_flis", {; // Список принятых файлов из ЛИС
    {"KOD",         "N", 6,0},; // код;номер записи
    {"FNAME",       "C",50,0},; // имя файла
    {"DREAD",       "D", 8,0},; // дата чтения
    {"TREAD1",      "C", 5,0},; // время начала чтения
    {"TREAD2",      "C", 5,0},; // время окончания чтения
    {"KOLP",        "N", 6,0},; // количество пациентов
    {"KOLS",        "N", 6,0},; // количество случаев
    {"KOLU",        "N", 6,0};  // количество услуг
  })
endif
sname := StripPath(name_file)
G_Use(dir_server+"mo_flis",,"FL")
index on upper(fname) to tmp_fl
find (padr(upper(sname),50))
if found()
  if empty(fl->tread2)
    fl := f_alert({'Файл "'+alltrim(sname)+'".',;
                   "Чтение начато "+date_8(fl->dread)+" в "+fl->tread1+" и не было завершено.",;
                   "",;
                   "Выберите действие:"},;
                  {" Выход "," Попытка повторного чтения "},;
                  1,"GR+/R","W+/R",,,"GR+/R,N/BG") == 2
  else
    func_error(4,"Файл "+alltrim(sname)+" уже был прочитан "+date_8(fl->dread)+" в "+fl->tread2)
  endif
else
  fl := .t.
endif
if fl .and. f_Esc_Enter("чтения файла из ЛИС") .and. (iencode := f_define_LIS_coding(name_file)) > 0
  G_RLock(!found(),forever) // добавить ИЛИ заблокировать запись
  fl->KOD := recno()
  fl->FNAME := upper(sname)
  fl->DREAD := sys_date
  fl->TREAD1 := hour_min(seconds())
  fl->TREAD2 := ""
  fl->KOLP := fl->KOLS := fl->KOLU := 0
  UnLock
  Commit
  //
  t1 := seconds()
  @ maxrow(),0 say padl(sname,80) color "W/R"
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
  use_base("lusl")
  use_base("luslc")
  Use_base("uslugi")
  R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
  Use_base("human_u")
  G_Use(dir_server+"human_",,"HUMAN_")
  G_Use(dir_server+"human_2",,"HUMAN_2")
  index on str(pn3,10) to (cur_dir+"tmp_human2")
  G_Use(dir_server+"human",{dir_server+"humank",;
                            dir_server+"humankk",;
                            dir_server+"humann",;
                            dir_server+"humand",;
                            dir_server+"humano",;
                            dir_server+"humans"},"HUMAN")
  G_Use(dir_server+"mo_pers",,"PERSO")
  index on snils to (cur_dir+"tmp_pers")
  set index to (cur_dir+"tmp_pers"),(dir_server+"mo_pers")
  G_Use(dir_server+"mo_kfio",,"KFIO")
  index on str(kod,7) to (cur_dir+"tmp_kfio")
  G_Use(dir_server+"mo_kismo",,"KSN")
  index on str(kod,7) to (cur_dir+"tmpkismo")
  G_Use(dir_server+"mo_hismo",,"HSN")
  index on str(kod,7) to (cur_dir+"tmphismo")
  G_Use(dir_server+"kartote_",,"KART_")
  G_Use(dir_server+"kartote2",,"KART2")
  index on kod_AK to (cur_dir+"tmp_kart2")
  G_Use(dir_server+"kartotek",{dir_server+"kartotek",;
                               dir_server+"kartoten",;
                               dir_server+"kartotep",;
                               dir_server+"kartoteu",;
                               dir_server+"kartotes"},"KART")
  Private such := 1, sotd := 1 // код отделения "Лаборатория-ЛИС на Ангарском"
  if left(fl->FNAME,4) == "LAB2"
    sotd := 3 // код отделения "ЛИС в Краснооктябрьском р-не"
  endif
  Private arr_pac := {}, arr_order := {}, arr_usl := {}, ip := 0, is := 0, isp := 0, iu := 0
  glob_podr := "" ; glob_otd_dep := 0
  fl_exit := .f.
  ft_use(name_file)
  ft_gotop()
  do while !ft_eof()
    if !empty( s := ft_ReadLn() )
      if iencode == 1
        s := hb_AnsiToOem(s)
      else
        s := Utf82Oem(s)
      endif
      if upper(left(s,3)) == "PAT"
        if !empty(arr_pac)
          if !empty(aerr := f2_import_from_LIS(1))
            fl_exit := .t.
            exit
          endif
          arr_pac := {}
          arr_order := {}
        endif
        for i := 2 to numtoken(s,";",1)
          s1 := alltrim(token(s,";",i,1))
          aadd(arr_pac,s1)
        next
        do while len(arr_pac) < 15 // добавим пустые поля (вдруг что-то не так со строкой)
          aadd(arr_pac, " ")
        enddo
      elseif upper(left(s,5)) == "ORDER"
        aadd(arr_order, {}) ; j := len(arr_order)
        for i := 2 to numtoken(s,";",1)
          s1 := alltrim(token(s,";",i,1))
          aadd(arr_order[j],s1)
        next
        do while len(arr_order[j]) < 6 // 5 И 6 ЭЛЕМЕНТЫ ДЛЯ СРОКОВ ЛЕЧЕНИЯ
          aadd(arr_order[j], " ")
        enddo
        arr_order[j,4] := {} // для занесения услуг
      elseif upper(left(s,4)) == "EXAM" .and. len(arr_order) > 0
        arr := {}
        for i := 2 to numtoken(s,";",1)
          s1 := alltrim(token(s,";",i,1))
          aadd(arr,s1)
        next
        do while len(arr) < 7
          aadd(arr, " ")
        enddo
        aadd(arr_order[j,4],aclone(arr))
      endif
    endif
    ft_skip()
  enddo
  ft_use()
  if !fl_exit .and. !empty(arr_pac) .and. !empty(aerr := f2_import_from_LIS(1))
    fl_exit := .t.
  endif
  if !fl_exit
    select FL
    G_RLock(forever) // заблокировать запись
    fl->TREAD2 := hour_min(seconds())
    fl->KOLP := ip
    fl->KOLS := is
    fl->KOLU := iu
  endif
  dbUnlockAll()
  dbCommitAll()
  close databases
  t2 := seconds() - t1
  rest_box(buf)
  if fl_exit
    arr := aclone(aerr)
    Ins_Array(arr,1,'Ошибка в файле "'+alltrim(sname)+'":')
    aadd(arr,"")
    aadd(arr,"Операция импорта прервана!")
  else
    arr := {'Файл "'+alltrim(sname)+'" импортирован.',;
            "",;
            "Время работы - "+sectotime(t2)+".",;
            "",;
            "Пациентов "+lstr(ip)+", случаев "+lstr(is)+iif(isp==0,""," (в т.ч.повторно "+lstr(isp)+")")+", услуг "+lstr(iu)+"."}
  endif
  n_message(arr,,"GR+/R","W+/R",,,"G+/R")
endif
close databases
rest_box(buf)
return NIL

***** 02.01.17
Static Function Utf82Oem(s)
return hb_Utf8ToStr(s,"RU866")

#define LIS_KOD_AK     1
#define LIS_FAM        2
#define LIS_IMA        3
#define LIS_OTS        4
#define LIS_DATE_R     5
#define LIS_POL        6
#define LIS_VPOLIS     7
#define LIS_SPOLIS     8
#define LIS_NPOLIS     9
#define LIS_OKATO     10
#define LIS_VID_UD    11
#define LIS_SER_UD    12
#define LIS_NOM_UD    13
#define LIS_MESTO_R   14
#define LIS_SNILS     15
//
#define LISS_KOD       1
#define LISS_DIAG      2
#define LISS_MO        3
#define LISS_USL       4
#define LISS_NDATA     5
#define LISS_KDATA     6
#define LISS_OTD       7
//
#define LISU_SHIFR     1
#define LISU_DATE      2
#define LISU_SPEC      3
#define LISU_SNILS     4
#define LISU_KODU      5
#define LISU_CENA      6
#define LISU_UNIT      7
#define LISU_ID        8

***** 02.03.18
Function f2_impXML_from_LIS(ta)
Static arr[LISU_ID]
Local i, j := 1, s
s := afteratnum('Pat_code="',ta[1]) ; arr_pac[LIS_KOD_AK ] := beforatnum('"',s,1)
s := afteratnum('Last_name="',s)    ; arr_pac[LIS_FAM    ] := beforatnum('"',s,1)
s := afteratnum('First_name="',s)   ; arr_pac[LIS_IMA    ] := beforatnum('"',s,1)
s := afteratnum('Father_name="',s)  ; arr_pac[LIS_OTS    ] := beforatnum('"',s,1)
s := afteratnum('Birth_date="',s)   ; arr_pac[LIS_DATE_R ] := beforatnum('"',s,1)
s := afteratnum('Sex="',s)          ; arr_pac[LIS_POL    ] := beforatnum('"',s,1)
s := afteratnum('OMS_type="',s)     ; arr_pac[LIS_VPOLIS ] := beforatnum('"',s,1)
s := afteratnum('OMS_series="',s)   ; arr_pac[LIS_SPOLIS ] := beforatnum('"',s,1)
s := afteratnum('OMS_number="',s)   ; arr_pac[LIS_NPOLIS ] := beforatnum('"',s,1)
s := afteratnum('Ins_OKATO="',s)    ; arr_pac[LIS_OKATO  ] := beforatnum('"',s,1)
s := afteratnum('UDL_type="',s)     ; arr_pac[LIS_VID_UD ] := beforatnum('"',s,1)
s := afteratnum('UDL_series="',s)   ; arr_pac[LIS_SER_UD ] := beforatnum('"',s,1)
s := afteratnum('UDL_number="',s)   ; arr_pac[LIS_NOM_UD ] := beforatnum('"',s,1)
s := afteratnum('Birth_place="',s)  ; arr_pac[LIS_MESTO_R] := beforatnum('"',s,1)
s := afteratnum('SNILS="',s)        ; arr_pac[LIS_SNILS  ] := beforatnum('"',s,1)
arr_order := {}
for i := 2 to len(ta)
  ta[i] := ltrim(ta[i])
  if left(ta[i],7) == "<ORDER "
    aadd(arr_order, {}) ; j := len(arr_order)
    s := afteratnum('Number="',ta[i])  ; aadd(arr_order[j],beforatnum('"',s,1))
    s := afteratnum('DS="',s)          ; aadd(arr_order[j],beforatnum('"',s,1))
    s := afteratnum('Sender_code="',s) ; aadd(arr_order[j],beforatnum('"',s,1))
    aadd(arr_order[j],{}) // для занесения услуг
    aadd(arr_order[j]," ") // 5 И 6 ЭЛЕМЕНТЫ ДЛЯ СРОКОВ ЛЕЧЕНИЯ
    aadd(arr_order[j]," ")
    aadd(arr_order[j],sotd)
  endif
  if left(ta[i],6) == "<EXAM "
    afill(arr,"")
    s := afteratnum('ExamID="',ta[i]) ; arr[LISU_ID   ] := beforatnum('"',s,1)
    s := afteratnum('Exam_code="',s)  ; arr[LISU_SHIFR] := beforatnum('"',s,1)
    s := afteratnum('Exec_date="',s)  ; arr[LISU_DATE ] := beforatnum('"',s,1)
    s := afteratnum('Doc_spec="',s)   ; arr[LISU_SPEC ] := beforatnum('"',s,1)
    s := afteratnum('Doc_SNILS="',s)  ; arr[LISU_SNILS] := beforatnum('"',s,1)
    if j <= len(arr_order)
      aadd(arr_order[j,4],aclone(arr))
    endif
  endif
next j
return f2_import_from_LIS(2)

***** 02.01.18
Function f2_import_from_LIS(par)
Static siu := 0, jsiu := 0
Local i, j, k, fl, afio[3], mfio, aerr := {}, tmp_arr := {}, arr_unit, lvzros_reb, i_738, i_739
Local t1, t2, t3, t4, ku := 0, ku1 := 0, ko := len(arr_order)
t1 := seconds()
++ip
afio[1] := f_LIS_fio(arr_pac[LIS_FAM],1)
afio[2] := f_LIS_fio(arr_pac[LIS_IMA],2)
afio[3] := f_LIS_fio(arr_pac[LIS_OTS],3)
mfio := afio[1]+" "+afio[2]+" "+afio[3]
if empty(int(val(arr_pac[LIS_KOD_AK])))
  aadd(aerr, "Некорректный код PAT у пациента - "+mfio)
  return aerr
endif
if !val_fio(afio,aerr)
  aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'"')
  return aerr
endif
arr_pac[LIS_DATE_R] := ctod(arr_pac[LIS_DATE_R])
if empty(arr_pac[LIS_DATE_R])
  aadd(aerr,"Некорректная дата рождения у пациента")
  aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'"')
  return aerr
endif
//my_debug(ip < 1000,"1"+print_array(arr_pac))
arr_pac[LIS_POL] := iif(arr_pac[LIS_POL]=="M", "М", "Ж")
f_LIS_polis()
f_LIS_pasport()
arr_pac[LIS_SNILS] := charrem("- ",arr_pac[LIS_SNILS])
//my_debug(ip < 1000,"2"+print_array(arr_pac))
for j := 1 to len(arr_order)
  arr_order[j,LISS_KOD] := int(val(arr_order[j,LISS_KOD]))
  if empty(arr_order[j,LISS_KOD])
    aadd(aerr,"Некорректный ORDER у пациента")
    aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'"')
    return aerr
  endif
  if empty(arr_order[j,LISS_MO])
    aadd(aerr,"Не заполнена направляющая мед.организация у пациента")
    aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
    return aerr
  elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == arr_order[j,LISS_MO] })) == 0
    aadd(aerr,"В справочнике МО не найдена направляющая мед.организация "+arr_order[j,LISS_MO]+" у пациента")
    aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
    return aerr
  else
    arr_order[j,LISS_MO] := ret_mo(arr_order[j,LISS_MO])[_MO_KOD_TFOMS]
  endif
  //asort(arr_order[j,LISS_USL],,,{|x,y| iif(x[2] == y[2], fsort_usl(x[1]) < fsort_usl(y[1]), x[2] < y[2])})
  i_738 := i_739 := 0
  if len(arr_order[j,LISS_USL]) == 0
    aadd(aerr,"Не введены услуги у пациента")
    aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
    return aerr
  endif
  for i := 1 to len(arr_order[j,LISS_USL])
    ++iu
    ++ku
    if empty(arr_order[j,LISS_USL,i,LISU_SHIFR])
      aadd(aerr, "Не введена услуга у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
      return aerr
    endif
    if par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
      if empty(arr_order[j,LISS_USL,i,LISU_ID])
        aadd(aerr,"Некорректное значение ExamID в услуге "+arr_order[j,LISS_USL,i,LISU_SHIFR]+" у пациента")
        aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
        return aerr
      endif
      //if eq_any(left(arr_order[j,LISS_USL,i,LISU_SHIFR],5),"4.16.","4.17.")
        //arr_order[j,LISS_OTD] := sotd2 // код отделения в Краснооктябрьском р-не
      //endif
    endif
    select LUSL
    find (padr(arr_order[j,LISS_USL,i,LISU_SHIFR],10))
    if found()
      arr_order[j,LISS_USL,i,LISU_UNIT] := lusl->unit_code
    else
      aadd(aerr, "В справочнике не найдена услуга "+arr_order[j,LISS_USL,i,LISU_SHIFR]+" у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
      return aerr
    endif
    if arr_order[j,LISS_USL,i,LISU_SHIFR] == "4.11.738"
      i_738 := i
    elseif arr_order[j,LISS_USL,i,LISU_SHIFR] == "4.11.739"
      i_739 := i
    endif
    arr_order[j,LISS_USL,i,LISU_DATE] := ctod(arr_order[j,LISS_USL,i,LISU_DATE])
    if empty(arr_order[j,LISS_USL,i,LISU_DATE])
      aadd(aerr, "Некорректная дата услуги у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER='+lstr(arr_order[j,LISS_KOD])+')')
      return aerr
    endif
    if empty(arr_order[j,LISS_NDATA])
      arr_order[j,LISS_NDATA] := arr_order[j,LISS_KDATA] := arr_order[j,LISS_USL,i,LISU_DATE]
    else
      arr_order[j,LISS_NDATA] := min(arr_order[j,LISS_NDATA],arr_order[j,LISS_USL,i,LISU_DATE])
      arr_order[j,LISS_KDATA] := max(arr_order[j,LISS_KDATA],arr_order[j,LISS_USL,i,LISU_DATE])
    endif
    arr_order[j,LISS_USL,i,LISU_SPEC] := int(val(arr_order[j,LISS_USL,i,LISU_SPEC]))
    if ascan(glob_V004, {|x| x[2] == arr_order[j,LISS_USL,i,LISU_SPEC] }) == 0
      arr_order[j,LISS_USL,i,LISU_SPEC] := 1107 // Клиническая лабораторная диагностика
    endif
    arr_order[j,LISS_USL,i,LISU_SNILS] := charrem("- ",arr_order[j,LISS_USL,i,LISU_SNILS])
    if empty(arr_order[j,LISS_USL,i,LISU_SNILS])
      arr_order[j,LISS_USL,i,LISU_SNILS] := 0
    else
      select PERSO
      set order to 1
      find (padr(arr_order[j,LISS_USL,i,LISU_SNILS],11))
      if !found()
        set order to 2
        AddRec(5)
        perso->kod := recno()
        perso->tab_nom := -perso->kod
        perso->fio  := "Сотрудник с кодом "+lstr(perso->kod)
        perso->uch  := such
        perso->otd  := sotd2
        //if par == 1
          //perso->otd := sotd
        //else
          //perso->otd := arr_order[j,LISS_OTD]
        //endif
        perso->prvs := arr_order[j,LISS_USL,i,LISU_SPEC]
        perso->snils := arr_order[j,LISS_USL,i,LISU_SNILS]
      endif
      arr_order[j,LISS_USL,i,LISU_SPEC] := perso->prvs
      arr_order[j,LISS_USL,i,LISU_SNILS] := perso->kod
    endif
  next i
  if i_738 > 0 .and. i_739 > 0 // если встречаются в одном случае "4.11.738" и "4.11.739"
    Del_Array(arr_order[j,LISS_USL],i_738) // то удаляем "4.11.738" (она дешевле)
  endif
  arr_order[j,LISS_DIAG] := "Z01.7" // всегда
  //my_debug(ip < 100,"  "+print_array({arr_order[j,1],arr_order[j,2],arr_order[j,3],arr_order[j,5],arr_order[j,6]}))
  //for i := 1 to len(arr_order[j,LISS_USL])
    //my_debug(ip < 100,"    "+print_array(arr_order[j,4,i]))
  //next
next
t2 := seconds()
Private mdate_r, m1vzros_reb := 0, M1NOVOR := 0, mprofil
select KART2
set order to 1
find (padr(arr_pac[LIS_KOD_AK],10))
if found()
  lkod_k := recno()
  select KART
  set order to 0
  goto (lkod_k)
  select KART_
  goto (lkod_k)
else
  select KART
  set order to 1
  Add1Rec(7)
  lkod_k := kart->kod := recno()
  kart->FIO := mfio
  kart->DATE_R := arr_pac[LIS_DATE_R]
  mdate_r := kart->DATE_R
  fv_date_r()
  kart->pol := arr_pac[LIS_POL]
  kart->VZROS_REB := m1VZROS_REB
  kart->POLIS := make_polis(arr_pac[LIS_SPOLIS],arr_pac[LIS_NPOLIS])
  kart->snils := arr_pac[LIS_SNILS]
  if TwoWordFamImOt(afio[1]) .or. TwoWordFamImOt(afio[2]) .or. TwoWordFamImOt(afio[3])
    kart->MEST_INOG := 9
  else
    kart->MEST_INOG := 0
  endif
  //
  dbf_equalization("KART_",lkod_k)
  kart_->VPOLIS := arr_pac[LIS_VPOLIS]
  kart_->SPOLIS := arr_pac[LIS_SPOLIS]
  kart_->NPOLIS := arr_pac[LIS_NPOLIS]
  kart_->vid_ud := arr_pac[LIS_VID_UD]
  kart_->ser_ud := arr_pac[LIS_SER_UD]
  kart_->nom_ud := arr_pac[LIS_NOM_UD]
  kart_->mesto_r:= arr_pac[LIS_MESTO_R]
  kart_->okatog := arr_pac[LIS_OKATO]
  kart_->okatop := kart_->okatog
  if left(kart_->okatog,2) == "18" // Волгоградская область
    kart_->SMO := "34007" // ООО "РГС-Медицина"
  else
    kart_->SMO := "34"    // ТФОМС
    kart_->KVARTAL_D := left(kart_->okatog,5) // ОКАТО субъекта РФ территории страхования
  endif
  //
  select KART2
  set order to 0
  dbf_equalization("KART2",lkod_k)
  kart2->kod_tf := 0
  kart2->kod_mis := ""
  kart2->kod_AK := arr_pac[LIS_KOD_AK]  // ключевое поле !!!
  kart2->MO_PR := ""
  kart2->TIP_PR := 0
  kart2->DATE_PR := ctod("")
  kart2->SNILS_VR := "" // уч.врач ещё не привязан
  kart2->PC1 := kod_polzovat+c4sys_date+hour_min(seconds())
  kart2->PC2 := ""
  kart2->PC3 := ""
  kart2->PC4 := ""
  //
  select KFIO
  find (str(lkod_k,7))
  if found()
    if kart->MEST_INOG == 9
      G_RLock(forever)
      kfio->FAM := afio[1]
      kfio->IM  := afio[2]
      kfio->OT  := afio[3]
    else
      DeleteRec(.t.)
    endif
  else
    if kart->MEST_INOG == 9
      AddRec(7)
      kfio->kod := lkod_k
      kfio->FAM := afio[1]
      kfio->IM  := afio[2]
      kfio->OT  := afio[3]
    endif
  endif
endif
if par == 1 // по-старому / из текстового файла / ключевое поле - номер наряда-заказа
  for j := 1 to len(arr_order)
    select HUMAN_2
    set order to 1
    find (str(arr_order[j,LISS_KOD],10))
    if found()
      arr_order[j,LISS_KOD] := 0 // т.е. данный случай заносили
    endif
  next
endif
for j := 1 to len(arr_order) // разбивка случаев по план-заказу
  arr_unit := {}
  for i := 1 to len(arr_order[j,LISS_USL])
    if ascan(arr_unit,arr_order[j,LISS_USL,i,LISU_UNIT]) == 0
      aadd(arr_unit,arr_order[j,LISS_USL,i,LISU_UNIT])
    endif
  next
  if len(arr_unit) > 1
    //my_debug(ip < 100,"    unit"+print_array(arr_unit))
    for k := 1 to len(arr_unit)
      //my_debug(ip < 100,"    unit="+lstr(arr_unit[k]))
      if par == 1
        aadd(tmp_arr,{arr_order[j,1],arr_order[j,2],arr_order[j,3],{},ctod(""),ctod("")})
      else
        aadd(tmp_arr,{arr_order[j,1],arr_order[j,2],arr_order[j,3],{},ctod(""),ctod(""),arr_order[j,7]})
      endif
      n := len(tmp_arr)
      //my_debug(ip < 100,"    tmp_arr"+print_array(tmp_arr[n]))
      for i := 1 to len(arr_order[j,LISS_USL])
        if arr_unit[k] == arr_order[j,LISS_USL,i,LISU_UNIT]
          aadd(tmp_arr[n,LISS_USL],aclone(arr_order[j,LISS_USL,i]))
          //my_debug(ip < 100,"    1tmp_arr"+print_array(tmp_arr[n]))
          if empty(tmp_arr[n,LISS_NDATA])
            tmp_arr[n,LISS_NDATA] := tmp_arr[n,LISS_KDATA] := arr_order[j,LISS_USL,i,LISU_DATE]
          else
            tmp_arr[n,LISS_NDATA] := min(tmp_arr[n,LISS_NDATA],arr_order[j,LISS_USL,i,LISU_DATE])
            tmp_arr[n,LISS_KDATA] := max(tmp_arr[n,LISS_KDATA],arr_order[j,LISS_USL,i,LISU_DATE])
          endif
        endif
      next
    next
  else
    aadd(tmp_arr,aclone(arr_order[j]))
  endif
next
arr_order := aclone(tmp_arr) ; tmp_arr := nil
t3 := seconds()
if par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
  select HU_
  set order to 1
  for j := 1 to len(arr_order)
    for i := 1 to len(arr_order[j,LISS_USL])
      find (padr(arr_order[j,LISS_USL,i,LISU_ID],30))
      if found() // данную услугу уже заносили
        arr_order[j,LISS_KOD] := 0 // значит считаем, что данный случай также заносили
        exit
      endif
    next i
  next j
  set order to 0
endif
select HUMAN
set order to 1
select HUMAN_2
set order to 0
aat := {}
for j := 1 to len(arr_order)
  ++is
  //my_debug(ip < 100,"  *"+lstr(j)+print_array({arr_order[j,1],arr_order[j,2],arr_order[j,3],arr_order[j,5],arr_order[j,6]}))
  //for i := 1 to len(arr_order[j,LISS_USL])
    //my_debug(ip < 100,"    *"+print_array(arr_order[j,4,i]))
  //next
  if arr_order[j,LISS_KOD] == 0 .or. len(arr_order[j,LISS_USL]) == 0
    ++isp
  else // т.е. данный случай ещё не заносили
    lvzros_reb := 1 // ребенок по умолчанию
    if (k := count_years(kart->DATE_R,arr_order[j,LISS_NDATA])) < 14
      m1vzros_reb := 1  // ребенок
    elseif k < 18
      m1vzros_reb := 2  // подросток
    else
      lvzros_reb := m1vzros_reb := 0  // взрослый
    endif
    mprofil := 34
    select MOPROF
    find (padr(arr_order[j,LISS_USL,1,LISU_SHIFR],20)+str(lvzros_reb,1))
    if found()
      mprofil := moprof->profil
    endif
    select HUMAN
    Add1Rec(7)
    mkod := human->kod := recno()
    dbf_equalization("HUMAN_",mkod)
    dbf_equalization("HUMAN_2",mkod)
    //
    human->kod_k      := lkod_k
    human->TIP_H      := B_STANDART
    human->FIO        := kart->FIO          // Ф.И.О. больного
    human->POL        := kart->POL          // пол
    human->DATE_R     := kart->DATE_R       // дата рождения больного
    human->VZROS_REB  := M1VZROS_REB        // 0-взрослый, 1-ребенок, 2-подросток
    human->KOD_DIAG   := arr_order[j,LISS_DIAG]
    human->KOD_DIAG2  := human->KOD_DIAG3 := human->KOD_DIAG4 := ""
    human->SOPUT_B1   := human->SOPUT_B2 := human->SOPUT_B3 := human->SOPUT_B4 := ""
    if len(arr_order[j,LISS_DIAG]) == 6
      human->diag_plus := padr(right(arr_order[j,LISS_DIAG],1),8)
    endif
    human->KOMU       := 0
    human->POLIS      := kart->polis
    human->LPU        := such
    human->OTD        := sotd2
    //if par == 1
      //human->OTD      := sotd
    //else
      //human->OTD      := arr_order[j,LISS_OTD]
    //endif
    human->UCH_DOC    := lstr(arr_order[j,LISS_KOD]) // ORDER по ЛИС
    human->N_DATA     := arr_order[j,LISS_NDATA]
    human->K_DATA     := arr_order[j,LISS_KDATA]
    //
    human_->SMO       := kart_->SMO
    human_->VPOLIS    := kart_->VPOLIS
    human_->SPOLIS    := kart_->SPOLIS
    human_->NPOLIS    := kart_->NPOLIS
    if alltrim(human_->smo) == '34'
      human_->OKATO   := kart_->KVARTAL_D
    endif
    human_->NOVOR     := 0
    human_->DATE_R2   := ctod("")
    human_->POL2      := ""
    human_->USL_OK    := 3  // амбулаторно
    human_->VIDPOM    := 13 // первичная специализированная
    human_->PROFIL    := mprofil // клиническая лабораторная диагностика или бактериология
    human_->IDSP      := 4  // лечебно-диагностическая процедура
    human_->NPR_MO    := arr_order[j,LISS_MO]
    human_->KOD_DIAG0 := ""
    human_->RSLT_NEW  := 314 // динамическое наблюдение
    human_->ISHOD_NEW := 304 // без перемен
    human_->VRACH     := 0
    human_->PRVS      := iif(mprofil == 34, -13, -54) // Клиническая лабораторная диагностика
    human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
    human_->ST_VERIFY := 0 // снова ещё не проверен
    human_->ID_PAC    := mo_guid(1,human_->(recno()))
    human_->ID_C      := mo_guid(2,human_->(recno()))
    human_->SUMP      := 0
    human_->OPLATA    := 0
    human_->SANK_MEK  := 0
    human_->SANK_MEE  := 0
    human_->SANK_EKMP := 0
    human_->REESTR    := 0
    human_->REES_ZAP  := 0
    human->schet      := 0
    human_->SCHET_ZAP := 0
    human->kod_p   := chr(0)
    human->date_e  := ''
    //
    human_2->OSL1 := human_2->OSL2 := human_2->OSL3 := ""
    human_2->VMP := 0
    human_2->VIDVMP := ""
    human_2->METVMP := 0
    human_2->VNR := human_2->VNR1 := human_2->VNR2 := human_2->VNR3 := 0
    human_2->PC1 := human_2->PC2 := human_2->PC3 := ""
    human_2->PN1 := human_2->PN2 := 0
    human_2->PN3 := arr_order[j,LISS_KOD] // ключевое поле (для par = 1)
    sstoim := 0
    for i := 1 to len(arr_order[j,LISS_USL])
      if (n := ascan(arr_usl, {|x| x[1]==arr_order[j,LISS_USL,i,LISU_SHIFR] .and. x[4]==lvzros_reb})) == 0
        ++ku1
        arr_order[j,LISS_USL,i,LISU_CENA] := 0
        arr_order[j,LISS_USL,i,LISU_KODU] := foundOurUsluga(arr_order[j,LISS_USL,i,LISU_SHIFR],;
                                                            arr_order[j,LISS_KDATA],;
                                                            mprofil,;
                                                            m1VZROS_REB,;
                                                            @arr_order[j,LISS_USL,i,LISU_CENA],1,.f.)
        aadd(arr_usl,{arr_order[j,LISS_USL,i,LISU_SHIFR],;
                      arr_order[j,LISS_USL,i,LISU_KODU],;
                      arr_order[j,LISS_USL,i,LISU_CENA],;
                      lvzros_reb})
      else
        arr_order[j,LISS_USL,i,LISU_KODU] := arr_usl[n,2]
        arr_order[j,LISS_USL,i,LISU_CENA] := arr_usl[n,3]
      endif
      sstoim += arr_order[j,LISS_USL,i,LISU_CENA]
      select HU
      Add1Rec(7)
      hu->kod     := human->kod
      hu->kod_vr  := arr_order[j,LISS_USL,i,LISU_SNILS]
      hu->kod_as  := 0
      hu->u_koef  := 1
      hu->u_kod   := arr_order[j,LISS_USL,i,LISU_KODU]
      hu->u_cena  := arr_order[j,LISS_USL,i,LISU_CENA]
      hu->is_edit := 0
      hu->date_u  := dtoc4(arr_order[j,LISS_USL,i,LISU_DATE])
      hu->otd     := human->OTD
      hu->kol := hu->kol_1 := 1
      hu->stoim := hu->stoim_1 := arr_order[j,LISS_USL,i,LISU_CENA]
      hu->KOL_RCP := 0
      //
      dbf_equalization("HU_",hu->(recno()))
      hu_->ID_U := mo_guid(3,hu_->(recno()))
      hu_->PROFIL := human_->PROFIL
      hu_->PRVS   := arr_order[j,LISS_USL,i,LISU_SPEC]
      hu_->kod_diag := human->KOD_DIAG
      if par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
        hu_->zf := arr_order[j,LISS_USL,i,LISU_ID]
      else
        hu_->zf := ""
      endif
      ++siu
    next
    human->CENA := human->CENA_1 := sstoim
    aadd(aat,{seconds(),len(arr_order[j,LISS_USL])})
  endif
next
t4 := seconds()
/*select TMP
append blank
tmp->nn := ip
tmp->ko := ko
tmp->ko1 := len(arr_order)
tmp->ku := ku
tmp->ku1 := ku1
tmp->t2 := t2-t1
tmp->t3 := t3-t1
tmp->t4 := t4-t1
if tmp->t4 > 5
  k := t3
  for i := 1 to len(aat)
    aat[i,1] -= k
    k += aat[i,1]
  next
  my_debug(,lstr(ip)+print_array(aat))
endif*/
@ maxrow(),0 say "пациентов "+lstr(ip) color "G+/R"
@ row(),col() say "/" color "W/R"
@ row(),col() say "случаев "+lstr(is)+iif(isp==0,""," (повтор "+lstr(isp)+")") color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say "услуг "+lstr(iu) color cColorStMsg
if siu > 500
  //tmp->fc := "t"
  @ maxrow(),0 say "запись... " color "W/R"
  dbUnlockAll()
  dbCommitAll()
  siu := 0
endif
return aerr

***** 14.01.17 проверить отдельно фамилию, имя или отчество при импорте из ЛИС
Function f_LIS_fio(s,n)
Static arr_char := {" ","-",".","'",'"'} // разрешённые спецсимволы
Local i, c, s1 := ""
s := alltrim(s) // убрать пробелы
for i := 1 to len(arr_char)
  s := charone(arr_char[i],s) // оставить 1 спецсимвол подряд
next
s := lat_rus(s)  // заменить латинские символы на соответствующие русские (если встретились)
s1 := charrem("0123456789",s) // убрать цифры
if empty(s1) .and. n < 3 // если в фамилии или имени были только цифры, - оставить их
  s1 := s
endif
s := s1 ; s1 := ""
for i := 1 to len(s)
  c := substr(s,i,1)
  if isralpha(c) // буква
    s1 += c
  elseif ascan(arr_char,c) > 0 // разрешённый спецсимвол
    s1 += c
  elseif between(asc(c),48,57) // в фамилии или имени были только цифры
    s1 += c
  endif
next
return s1

***** 15.01.17 проверить полис при импорте из ЛИС
Function f_LIS_polis()
Local n
if empty(arr_pac[LIS_OKATO]) .or. mo_nodigit(arr_pac[LIS_OKATO]) // пустое или не цифры
  arr_pac[LIS_OKATO] := "18"
endif
arr_pac[LIS_OKATO] := padr(arr_pac[LIS_OKATO],11,"0")
if ascan(glob_array_srf, {|x| x[2] == left(arr_pac[LIS_OKATO],2) }) == 0
  arr_pac[LIS_OKATO] := padr("18",11,"0")
endif
//
arr_pac[LIS_VPOLIS] := int(val(arr_pac[LIS_VPOLIS]))
if !between(arr_pac[LIS_VPOLIS],1,3)
  arr_pac[LIS_VPOLIS] := 3
endif
arr_pac[LIS_SPOLIS] := val_polis(arr_pac[LIS_SPOLIS])
arr_pac[LIS_NPOLIS] := val_polis(arr_pac[LIS_NPOLIS])
if !empty(arr_pac[LIS_SPOLIS]) .and. !mo_nodigit(arr_pac[LIS_SPOLIS]) // цифры в серии полиса
  arr_pac[LIS_NPOLIS] := arr_pac[LIS_SPOLIS] + arr_pac[LIS_NPOLIS] // склеим серию и номер = получим номер
  arr_pac[LIS_SPOLIS] := ""
endif
n := len(arr_pac[LIS_NPOLIS])
if n == 9 .and. empty(arr_pac[LIS_SPOLIS])
  arr_pac[LIS_VPOLIS] := 2  // то пусть это будет временный полис
endif
if n == 16 .and. !empty(arr_pac[LIS_SPOLIS])
  arr_pac[LIS_SPOLIS] := ""  // то очистим - какой-то мусор
endif
if arr_pac[LIS_VPOLIS] == 1
  if left(arr_pac[LIS_OKATO],2) == "18" .and. empty(arr_pac[LIS_SPOLIS]) .and. n != 16
    arr_pac[LIS_NPOLIS] := padr(arr_pac[LIS_NPOLIS],16,"0")
  endif
elseif arr_pac[LIS_VPOLIS] == 2
  if n != 9
    arr_pac[LIS_NPOLIS] := padr(arr_pac[LIS_NPOLIS],9,"0")
  endif
elseif arr_pac[LIS_VPOLIS] == 3
  if n != 16
    arr_pac[LIS_NPOLIS] := padr(arr_pac[LIS_NPOLIS],16,"0")
  endif
  if !f_checksum_polis(arr_pac[LIS_NPOLIS]) // если неверная контрольная сумма в новом полисе
    arr_pac[LIS_VPOLIS] := 1  // то пусть это будет старый полис
  endif
endif
return NIL

***** 15.01.17 проверить паспорт при импорте из ЛИС
Function f_LIS_pasport()
Local i, _sl, _sr
arr_pac[LIS_VID_UD] := int(val(arr_pac[LIS_VID_UD]))
if ascan(menu_vidud,{|x| x[2] == arr_pac[LIS_VID_UD] }) == 0
  arr_pac[LIS_VID_UD] := iif(arr_pac[LIS_VPOLIS] < 3, 14, 0)
endif
if arr_pac[LIS_VID_UD] == 0 // ели новый полис и нет документа, очистим серию и номер документа
  arr_pac[LIS_SER_UD] := ""
  arr_pac[LIS_NOM_UD] := ""
else
  arr_pac[LIS_SER_UD] := upper(arr_pac[LIS_SER_UD])
  if eq_any(arr_pac[LIS_VID_UD],1,3) // "Паспорт гражд.СССР" или "Свид-во о рождении"
    if "-" $ arr_pac[LIS_SER_UD]
      _sl := ALLTRIM(TOKEN(arr_pac[LIS_SER_UD], "-", 1))
      _sr := ALLTRIM(TOKEN(arr_pac[LIS_SER_UD], "-", 2))
      arr_pac[LIS_SER_UD] := _sl+"-"+lat_rus(_sr) // латынь -> в русский
    else
      if !mo_nodigit(charrem(" ",arr_pac[LIS_SER_UD])) // если только цифры в серии
        arr_pac[LIS_VID_UD] := 14 // то это паспорт РФ
      else
        arr_pac[LIS_VID_UD] := 18 // иначе "Иные документы"
      endif
    endif
  endif
  if arr_pac[LIS_VID_UD] == 14 .and. !(" " $ arr_pac[LIS_SER_UD]) // если серия в виде "1803" - без пробела
    arr_pac[LIS_SER_UD] := left(arr_pac[LIS_SER_UD],2)+" "+substr(arr_pac[LIS_SER_UD],3)
  endif
  if mo_nodigit(arr_pac[LIS_NOM_UD]) // не цифры
    arr_pac[LIS_VID_UD] := 18 // "Иные документы"
  else
    if (eq_any(arr_pac[LIS_VID_UD],1,3) .and. len(arr_pac[LIS_NOM_UD]) != 6) .or. ;
             (arr_pac[LIS_VID_UD] == 14 .and. !eq_any(len(arr_pac[LIS_NOM_UD]),6,7))
      arr_pac[LIS_NOM_UD] := padr(arr_pac[LIS_NOM_UD],6,"9") // т.е. делаем 6 знаков в длину
    endif
  endif
  if eq_any(arr_pac[LIS_VID_UD],3,14)
    if empty(arr_pac[LIS_MESTO_R])
      arr_pac[LIS_MESTO_R] := "г.Волгоград"
    else
      arr_pac[LIS_MESTO_R] := del_spec_symbol(arr_pac[LIS_MESTO_R])
    endif
  endif
endif
return NIL

***** 03.05.17
Function f_define_LIS_coding(name_file)
Local arr_pac, a1[3], a2[3], fl[3], i, j := 0, ret := {.t.,.t.}
//my_debug(,name_file)
ft_use(name_file)
ft_gotop()
do while !ft_eof()
  if !empty( s := ft_ReadLn() )
    if upper(left(s,3)) == "PAT"
      arr_pac := {}
      for i := 3 to numtoken(s,";",1)
        s1 := alltrim(token(s,";",i,1))
        aadd(arr_pac,s1)
        if len(arr_pac) == 3 ; exit ; endif
      next
      for i := 1 to 3
        a1[i] := hb_AnsiToOem(arr_pac[i])
        a2[i] := hb_OemToAnsi(a1[i])
        fl[i] := (arr_pac[i] == a2[i])
        if !fl[i]
          ret[1] := .f.
        endif
      next
      /*my_debug(,"Ansi"+print_array(fl))
      if fl[1]
        my_debug(,print_array(a1))
      endif*/
      for i := 1 to 3
        a1[i] := hb_Utf8ToStr(arr_pac[i],"RU866")
        a2[i] := hb_StrToUtf8(a1[i],"RU866")
        fl[i] := (arr_pac[i] == a2[i])
        if !fl[i]
          ret[2] := .f.
        endif
      next
      /*my_debug(,"Utf8"+print_array(fl))
      if fl[1]
        my_debug(,print_array(a1))
      endif*/
      if ++j == 5 ; exit ; endif
    endif
  endif
  ft_skip()
enddo
ft_use()
j := 0
if ret[1] == ret[2]
  func_error(4,"Не удалось автоматически определить кодировку файла "+StripPath(name_file))
else
  j := iif(ret[1], 1, 2)
endif
return j

***** Импорт случаев ОМС (листов учёта) из других программ
Function import_sluch_OMS()
Local full_dbf, name_dbf, i, s := "", fl := .t.
Private arr_f := {"_lpu","_otd","_sluch","_sluch_u"}, ;
        cFileProtokol := "protokol"+stxt
Private p_var_manager := "Read_sluch_OMS"
full_dbf := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*"+sdbf)
if !empty(full_dbf)
  name_dbf := StripPath(full_dbf)
  Private name_path := KeepPath(full_dbf)+cslash
  for i := 1 to len(arr_f)
    arr_f[i] := upper(arr_f[i])+sdbf
    s += iif(empty(s),"",",")+arr_f[i]
  next
  if ascan(arr_f,name_dbf) == 0
    fl := func_error(4,"Необходимо выбрать один из файлов: "+s)
  else
    for i := 1 to len(arr_f)
      //if !hb_FileExists(hb_OemToAnsi(name_path)+arr_f[i])
      if !hb_FileExists(name_path+arr_f[i])
        fl := func_error(4,"Не обнаружен файл: "+name_path+arr_f[i])
        exit
      endif
    next
  endif
  if fl
    G_SPlus(f_name_task(X_OMS)) // плюс 1 пользователь зашёл в задачу ОМС
    if G_SIsLock(sem_vagno_task[X_OMS])
      fl := f_err_sem_vagno_task(X_OMS)
    else
      fl := f1_import_sluch_OMS()
    endif
    G_SMinus(f_name_task(X_OMS))  // минус 1 пользователь (вышел из задачи ОМС)
  endif
  if hb_FileExists(cFileProtokol)
    //copy file (cFileProtokol) to (hb_OemToAnsi(name_path)+cFileProtokol)
    copy file (cFileProtokol) to (name_path+cFileProtokol)
    viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
  endif
endif
return NIL

*

***** 27.10.14
Function f1_import_sluch_OMS()
Local _lpu := {;
   {"KOD",     "N",  3, 0},; // ваш код учреждения
   {"NAME",    "C", 30, 0};  // наименование учреждения
 }
Local _otd := {;
   {"KOD",     "N",  3, 0},; // ваш код отделения
   {"NAME",    "C", 30, 0},; // наименование отделения
   {"KOD_LPU", "N",  3, 0};  // код учреждения, в котором находится отделение
 }
Local _sluch := {;
   {"REC_HUMAN",   "N",     8,     0},;
   {"YOUR_RECNO",  "N",    10,     0},;
   {"KOD"      ,   "N",     7,     0},;
   {"FIO"      ,   "C",    50,     0},;
   {"FAM"      ,   "C",    40,     0},;
   {"IM"       ,   "C",    40,     0},;
   {"OT"       ,   "C",    40,     0},;
   {"W"        ,   "N",     1,     0},;
   {"DR"       ,   "D",     8,     0},;
   {"VPOLIS"  ,    "N",     1,     0},;
   {"SPOLIS"  ,    "C",    10,     0},;
   {"NPOLIS"  ,    "C",    20,     0},;
   {"SMO",         "C",     5,     0},;
   {"SMO_OK",      "C",     5,     0},;
   {"SMO_NAM",     "C",   100,     0},; // наименование иногородней СМО
   {"DOCTYPE",     "N",     2,     0},;
   {"DOCSER",      "C",    10,     0},;
   {"DOCNUM",      "C",    20,     0},;
   {"MR",          "C",   100,     0},;
   {"OKATOG",      "C",    11,     0},;
   {"OKATOP",      "C",    11,     0},;
   {"ADRES",       "C",    50,     0},;
   {"ADRESP",      "C",    50,     0},;
   {"SNILS"    ,   "C",    11,     0},;
   {"OTD"      ,   "N",     3,     0},;
   {"PROFIL",      "N",     3,     0},;
   {"NHISTORY"  ,  "C",    10,     0},;
   {"DATE_1"   ,   "D",     8,     0},;
   {"DATE_2"   ,   "D",     8,     0},;
   {"DS0",         "C",     6,     0},;
   {"DS1" ,        "C",     5,     0},;
   {"DS2",         "C",     5,     0},;
   {"DS2_2",       "C",     5,     0},;
   {"DS2_3",       "C",     5,     0},;
   {"DS2_4",       "C",     5,     0},;
   {"DS2_5",       "C",     5,     0},;
   {"DS2_6",       "C",     5,     0},;
   {"DS2_7",       "C",     5,     0},;
   {"DS3",         "C",     5,     0},;
   {"DS3_2",       "C",     5,     0},;
   {"DS3_3",       "C",     5,     0},;
   {"NOVOR",       "N",     1,     0},;
   {"REB_NUMBER",  "N",     2,     0},;
   {"REB_DR",      "D",     8,     0},;
   {"REB_POL",     "N",     1,     0},;
   {"USL_OK",      "N",     2,     0},;
   {"VIDPOM",      "N",     4,     0},;
   {"IDSP",        "N",     2,     0},;
   {"NPR_MO",      "C",     6,     0},;
   {"EXTR",        "N",     1,     0},;
   {"F_SP",        "N",     1,     0},;
   {"RSLT",        "N",     3,     0},;
   {"ISHOD",       "N",     3,     0},;
   {"VRACH",       "N",     5,     0},;
   {"PRVS",        "N",     9,     0},;
   {"VRACH_FIO",   "C",    50,     0},;
   {"VID_HMP",     "C",    12,     0},; // вид ВМП по справочнику V018
   {"METOD_HMP",   "N",     4,     0},; // метод ВМП по справочнику V019
   {"AD_CR",       "C",    10,     0},;
   {"KSG",         "C",    10,     0},;
   {"CENA_KSG" ,   "N",    10,     2},;
   {"SUMV"     ,   "N",    10,     2};
  }
Local _sluch_u := {;
   {"REC_HUMANU",  "N",     8,     0},;
   {"YOUR_RECNO",  "N",    10,     0},;
   {"KOD"      ,   "N",     7,     0},;
   {"OTD"      ,   "N",     3,     0},;
   {"PROFIL",      "N",     3,     0},;
   {"DS",          "C",     6,     0},;
   {"CODE_USL"   , "C",    20,     0},;
   {"DATE_IN"   ,  "D",     8,     0},;
   {"KOL_USL"  ,   "N",     3,     0},;
   {"TARIF"   ,    "N",    10,     2},;
   {"SUMV_USL" ,   "N",    10,     2},;
   {"VRACH",       "N",     5,     0},;
   {"PRVS",        "N",     9,     0},;
   {"VRACH_FIO",   "C",    50,     0};
  }
Local i, j, k, arr_ksg, cType, cName, a_struct, fl := .t., buf := save_maxrow()
mywait()
a_struct := {_lpu,_otd,_sluch,_sluch_u}
strfile(space(10)+"Протокол импорта случаев "+;
        date_8(sys_date)+" "+hour_min(seconds())+;
        hb_eol()+hb_eol(),cFileProtokol)
for i := 1 to len(arr_f)
  //use (hb_OemToAnsi(name_path)+arr_f[i]) new alias TMP
  use (name_path+arr_f[i]) new alias TMP
  for j := 1 to len(a_struct[i])
    cName := a_struct[i,j,1]
    if (k := fieldpos(cName)) == 0
      fl := .f.
      strfile(upper(arr_f[i])+": не обнаружено поле "+cName+hb_eol(),cFileProtokol,.t.)
    else
      pole := "tmp->"+cName
      cType := valtype(&pole)
      if !(cType == a_struct[i,j,2])
        fl := .f.
        strfile(upper(arr_f[i])+", тип поля "+cName+": "+cType+;
                ", а должно быть "+a_struct[i,j,2]+hb_eol(),cFileProtokol,.t.)
      endif
    endif
  next
  use
next
if fl
  glob_podr := "" ; glob_otd_dep := 0 // пока без кодов подразделений
  dbcreate(cur_dir+"tmp_ksg",{;
   {"REC"      ,   "N",     7,     0},;
   {"CODE_USL"   , "C",    10,     0},;
   {"TARIF"   ,    "N",    10,     2}})
  use (cur_dir+"tmp_ksg") new
  R_Use(dir_exe+"_okator",cur_dir+"_okatr","REGION")
  R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OBLAST")
  R_Use(dir_exe+"_okatos",cur_dir+"_okats","SELO")
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
  use_base("lusl")
  use_base("luslc")
  use_base("luslf")
  G_Use(dir_server+"mo_uch",,"LPU")
  G_Use(dir_server+"mo_otd",,"OTD")
  Use_base("mo_su")
  Use_base("uslugi")
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
  Use_base("mo_hu")
  Use_base("human_u")
  Use_base("human")
  //
  R_Use(exe_dir+"_mo_smo",{cur_dir+"_mo_smo",cur_dir+"_mo_smo2"},"SMO")
  use (name_path+"_lpu") new alias ILPU
  index on str(kod,3) to (cur_dir+"tmp_ilpu")
  use (name_path+"_otd") new alias IOTD
  index on str(kod,3) to (cur_dir+"tmp_iotd")
  use (name_path+"_sluch_u") new alias IHU
  index on str(kod,10) to (cur_dir+"tmp_ihu")
  use (name_path+"_sluch") new alias IHUMAN
  index on str(kod,10) to (cur_dir+"tmp_ihum")
  go top
  do while !eof()
    select MKB_10
    find (padr(ihuman->ds1,6))
    if !between_date(mkb_10->dbegin,mkb_10->dend,ihuman->DATE_2)
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ', DS1="'+ihuman->DS1+'"-основной диагноз не входит в ОМС'+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(mkb_10->pol) .and. !(mkb_10->pol == iif(ihuman->W==1,"М","Ж"))
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ', DS1="'+ihuman->DS1+'"-несовместимость диагноза по полу'+hb_eol(),cFileProtokol,.t.)
    endif
    if ascan(menu_vidud,{|x| x[2] == ihuman->DOCTYPE }) == 0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ', DOCTYPE-не заполнено поле "ВИД удостоверения личности"'+hb_eol(),cFileProtokol,.t.)
    else
      if empty(ihuman->DOCNUM)
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ', DOCNUM-должно быть заполнено поле "НОМЕР удостоверения личности"'+hb_eol(),cFileProtokol,.t.)
      elseif !ver_number(ihuman->DOCNUM)
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ', DOCNUM-поле "НОМЕР удостоверения личности" должно быть цифровым'+hb_eol(),cFileProtokol,.t.)
      endif
      if !empty(ihuman->DOCNUM)
        s := space(80)
        if !val_ud_nom(2,ihuman->DOCTYPE,ihuman->DOCNUM,@s)
          fl := .f.
          strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                  ', DOCNUM-'+s+hb_eol(),cFileProtokol,.t.)
        endif
      endif
      if eq_any(ihuman->DOCTYPE,1,3,14) .and. empty(ihuman->DOCSER)
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ', DOCSER-должно быть заполнено поле "СЕРИЯ удостоверения личности"'+hb_eol(),cFileProtokol,.t.)
      endif
      if !empty(ihuman->DOCSER)
        s := space(80)
        if !val_ud_ser(2,ihuman->DOCTYPE,ihuman->DOCSER,@s)
          fl := .f.
          strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                  ', DOCSER-'+s+hb_eol(),cFileProtokol,.t.)
        endif
      endif
    endif
    fl_fio := .f. ; afio := array(3) ; afill(afio,"")
    if !empty(ihuman->fam) .and. !empty(ihuman->im)
      fl_fio := .t.
      afio[1] := ihuman->fam
      afio[2] := ihuman->im
      afio[3] := ihuman->ot
      mfio := alltrim(afio[1])+" "+alltrim(afio[2])+" "+alltrim(afio[3])
    endif
    if !fl_fio .and. !empty(ihuman->fio)
      k := 0 ; s := ""
      mfio := alltrim(ihuman->fio)
      for i := 1 to numtoken(mfio," .")
        s1 := alltrim(token(mfio," .",i))
        if !empty(s1)
          ++k
          if k < 3
            afio[k] := s1
          else
            s += s1+" "
          endif
        endif
      next
      afio[3] := alltrim(s)
    endif
    aerr := {}
    if !val_fio(afio,aerr)
      for i := 1 to len(aerr)
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                ', "'+alltrim(ihuman->fio)+'"-'+aerr[i]+hb_eol(),cFileProtokol,.t.)
      next
    endif
    if !empty(ihuman->SNILS)
      s := space(80)
      if !val_snils(ihuman->snils,2,@s)
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                ', SNILS="'+ihuman->SNILS+'"-'+s+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    if !empty(ihuman->NPR_MO)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == ihuman->NPR_MO })) > 0
        //
      elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == ihuman->NPR_MO })) > 0
        //
      endif
      if i == 0
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля NPR_MO = "+ihuman->NPR_MO+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    fl_okatosmo := .f. ; fl_nameismo := .f. ; fl_34 := .f.
    if empty(ihuman->SMO)
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
            ", не введен код СМО"+hb_eol(),cFileProtokol,.t.)
    else
      select SMO
      set order to 2
      find (ihuman->SMO)
      if found()
        //
      elseif int(val(ihuman->SMO)) == 34
        fl_34 := .t.
      else
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля SMO = "+ihuman->SMO+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    if fl_34 .and. !empty(ihuman->SMO_OK)
      select SMO
      set order to 1
      find (ihuman->SMO_OK)
      if found()
        fl_okatosmo := .t.
      else
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля SMO_OK = "+ihuman->SMO_OK+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    if fl_34 .and. !empty(ihuman->SMO_NAM)
      fl_nameismo := .t.
    endif
    if fl_34
      if !fl_okatosmo
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", не введено ОКАТО территории страхования"+hb_eol(),cFileProtokol,.t.)
      endif
      if !fl_nameismo
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", не введено наименование иногородней СМО"+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    if !empty(ihuman->OKATOG) .and. !import_verify_okato(ihuman->OKATOG)
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля OKATOG = "+ihuman->OKATOG+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(ihuman->OKATOP) .and. !import_verify_okato(ihuman->OKATOP)
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля OKATOP = "+ihuman->OKATOP+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(ihuman->PROFIL) .and. ascan(glob_V002,{|x| x[2]==ihuman->PROFIL})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля PROFIL = "+lstr(ihuman->PROFIL)+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(ihuman->USL_OK) .and. ascan(glob_V006,{|x| x[2]==ihuman->USL_OK})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля USL_OK = "+lstr(ihuman->USL_OK)+hb_eol(),cFileProtokol,.t.)
    endif
    /*if !empty(ihuman->IDSP) .and. ascan(glob_V010,{|x| x[2]==ihuman->IDSP})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля IDSP = "+lstr(ihuman->IDSP)+hb_eol(),cFileProtokol,.t.)
    endif*/
    if !empty(ihuman->RSLT) .and. ascan(glob_V009,{|x| x[2]==ihuman->RSLT})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля RSLT = "+lstr(ihuman->RSLT)+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(ihuman->ISHOD) .and. ascan(glob_V012,{|x| x[2]==ihuman->ISHOD})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля ISHOD = "+lstr(ihuman->ISHOD)+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(ihuman->PRVS) .and. ascan(glob_V004,{|x| x[2]==ihuman->PRVS})==0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", неверное значение поля PRVS = "+lstr(ihuman->PRVS)+hb_eol(),cFileProtokol,.t.)
    endif
    if ihuman->otd <= 0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", поле OTD = "+lstr(ihuman->otd)+hb_eol(),cFileProtokol,.t.)
    else
      select IOTD
      find (str(ihuman->otd,3))
      if found()
        select ILPU
        find (str(iotd->kod_lpu,3))
        if !found()
          fl := .f.
          strfile("_OTD: запись № "+lstr(iotd->(recno()))+;
                  ", KOD_LPU = "+lstr(iotd->kod_lpu)+" не найдено в справочнике _LPU"+hb_eol(),cFileProtokol,.t.)
        endif
      else
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                ", OTD = "+lstr(ihuman->otd)+" не найдено в справочнике _OTD"+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    if ihuman->kod <= 0
      fl := .f.
      strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
              ", поле KOD = "+lstr(ihuman->kod)+hb_eol(),cFileProtokol,.t.)
    else
      mdate_r := ihuman->dr ; m1VZROS_REB := 0 ; M1NOVOR := ihuman->novor
      mDATE_R2 := ctod("")
      fv_date_r(ihuman->DATE_1)
      s := 0
      select IHU
      find (str(ihuman->kod,10))
      do while ihu->kod == ihuman->kod .and. !eof()
        if !between(ihu->DATE_IN,ihuman->date_1,ihuman->date_2)
          fl := .f.
          strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
                  ", дата услуги "+full_date(ihu->DATE_IN)+" не попадает в диапазон лечения: "+;
                  full_date(ihuman->date_1)+"-"+full_date(ihuman->date_2)+hb_eol(),cFileProtokol,.t.)
        endif
        select LUSLF
        find (padr(ihu->CODE_USL,20))
        if !found()
          select LUSL
          find (padr(ihu->CODE_USL,10))
          if found()
            if (v := f1cena_oms(ihu->CODE_USL,;
                                '',;
                                (m1vzros_reb==0),;
                                ihuman->date_2)) != NIL .and. ;
                             !(round(ihu->TARIF,2) == round(v,2))
              fl := .f.
              strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
                      ", "+alltrim(ihu->CODE_USL)+" цена "+;
                      lstr(ihu->TARIF)+" != цене по ОМС "+lstr(v)+hb_eol(),cFileProtokol,.t.)
            endif
          else
            fl := .f.
            strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
                    ", "+alltrim(ihu->CODE_USL)+;
                    " не найдена услуга в справочниках ТФОМС (ФФОМС)"+hb_eol(),cFileProtokol,.t.)
          endif
        endif
        if !(round(ihu->TARIF*ihu->KOL_USL,2) == round(ihu->SUMV_USL,2))
          fl := .f.
          strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
                  ", "+alltrim(ihu->CODE_USL)+" "+;
                  lstr(ihu->TARIF)+"*"+lstr(ihu->KOL_USL)+" != "+;
                  lstr(ihu->SUMV_USL)+hb_eol(),cFileProtokol,.t.)
        endif
        s += ihu->SUMV_USL
        select IHU
        skip
      enddo
      if !(round(s,2) == round(ihuman->SUMV,2))
        fl := .f.
        strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                ", SUMV = "+lstr(ihuman->sumv)+" != "+lstr(s)+hb_eol(),cFileProtokol,.t.)
      endif
      if !empty(ihuman->VID_HMP)
        s := ""
        if ihuman->USL_OK == 1 // стационар
          make_V018_V019(ihuman->date_2)
          if ascan(glob_V018, {|x| x[1] == ihuman->VID_HMP }) == 0
            s := 'не найден вид ВМП "'+ihuman->VID_HMP+'" в справочнике V018'
          elseif empty(ihuman->METOD_HMP)
            s := 'ВМП оказана, введён вид ВМП, но не введён метод ВМП'
          elseif (i := ascan(glob_V019, {|x| x[1] == ihuman->METOD_HMP })) > 0
            if glob_V019[i,4] == ihuman->VID_HMP
              if ascan(glob_V019[i,3], {|x| left(ihuman->ds1,len(x))==x }) == 0
                s := 'основной диагноз не соответствует методу ВМП'
              endif
            else
              s := 'метод ВМП '+lstr(ihuman->METOD_HMP)+' не соответствует виду ВМП '+ihuman->VID_HMP
            endif
          else
            s := 'не найден метод ВМП '+lstr(ihuman->METOD_HMP)+' в справочнике V019'
          endif
        else
          s := "введен вид ВМП, а случай не стационарный"
        endif
        if !empty(s)
          fl := .f.
          strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+", "+s+hb_eol(),cFileProtokol,.t.)
        endif
      endif
      if empty(ihuman->SUMV)
        if eq_any(ihuman->USL_OK,1,2) // стационар и дневной стационар
          arr_ksg := definition_KSG(2) // уже 2018 год
          if len(arr_ksg) == 7 // диализ
            //
          elseif empty(arr_ksg[2]) // если нет ошибок
            aeval(arr_ksg[1],{|x| my_debug(,x) })
            select TMP_KSG
            append blank
            tmp_ksg->REC      := ihuman->(recno())
            tmp_ksg->CODE_USL := arr_ksg[3]
            tmp_ksg->TARIF    := arr_ksg[4]
          else
            aeval(arr_ksg[1],{|x| my_debug(,x) })
            my_debug(,"ОШИБКА:")
            aeval(arr_ksg[2],{|x| my_debug(,x) })
            fl := .f.
            strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+hb_eol(),cFileProtokol,.t.)
            aeval(arr_ksg[1],{|x| strfile(space(8)+x+hb_eol(),cFileProtokol,.t.) })
            aeval(arr_ksg[2],{|x| strfile(space(8)+x+hb_eol(),cFileProtokol,.t.) })
          endif
        elseif ihuman->USL_OK == 3 // не скорая помощь
          fl := .f.
          strfile("_SLUCH: запись № "+lstr(ihuman->(recno()))+;
                  ", SUMV = 0"+hb_eol(),cFileProtokol,.t.)
        endif
      endif
    endif
    select IHUMAN
    skip
  enddo
  select IHU
  go top
  do while !eof()
    if !empty(ihu->PROFIL) .and. ascan(glob_V002,{|x| x[2]==ihu->PROFIL})==0
      fl := .f.
      strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
              ", неверное значение поля PROFIL = "+lstr(ihu->PROFIL)+hb_eol(),cFileProtokol,.t.)
    endif
    if !empty(ihu->PRVS) .and. ascan(glob_V004,{|x| x[2]==ihu->PRVS})==0
      fl := .f.
      strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
              ", неверное значение поля PRVS = "+lstr(ihu->PRVS)+hb_eol(),cFileProtokol,.t.)
    endif
    if ihu->otd <= 0
      fl := .f.
      strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
              ", поле OTD = "+lstr(ihu->otd)+hb_eol(),cFileProtokol,.t.)
    else
      select IOTD
      find (str(ihu->otd,3))
      if found()
        select ILPU
        find (str(iotd->kod_lpu,3))
        if !found()
          fl := .f.
          strfile("_OTD: запись № "+lstr(iotd->(recno()))+;
                  ", KOD_LPU = "+lstr(iotd->kod_lpu)+" не найдено в справочнике _LPU"+hb_eol(),cFileProtokol,.t.)
        endif
      else
        fl := .f.
        strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
                ", OTD = "+lstr(ihu->otd)+" не найдено в справочнике _OTD"+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    if ihu->kod <= 0
      fl := .f.
      strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
              ", поле KOD = "+lstr(ihu->kod)+hb_eol(),cFileProtokol,.t.)
    else
      select IHUMAN
      find (str(ihu->kod,10))
      if !found()
        fl := .f.
        strfile("_SLUCH_U: запись № "+lstr(ihu->(recno()))+;
                ", KOD = "+lstr(ihu->kod)+" не обнаружен в _SLUCH"+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    select IHU
    skip
  enddo
  if fl
    iz := ip := 0
    lOldDeleted := SET(_SET_DELETED, .F.)
    select TMP_KSG
    index on str(rec,7) to (cur_dir+"tmp_ksg")
    G_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
    G_Use(dir_server+"mo_kfio",,"KFIO")
    index on str(kod,7) to (cur_dir+"tmp_kfio")
    G_Use(dir_server+"mo_kismo",,"KSN")
    index on str(kod,7) to (cur_dir+"tmpkismo")
    G_Use(dir_server+"mo_hismo",,"HSN")
    index on str(kod,7) to (cur_dir+"tmphismo")
    Use_base("kartotek")
    select IHUMAN
    go top
    do while !eof()
      fl_fio := .f. ; afio := array(3)
      if !empty(ihuman->fam) .and. !empty(ihuman->im)
        fl_fio := .t.
        afio[1] := ihuman->fam
        afio[2] := ihuman->im
        afio[3] := ihuman->ot
        mfio := alltrim(afio[1])+" "+alltrim(afio[2])+" "+alltrim(afio[3])
      endif
      if !fl_fio
        k := 0 ; s := ""
        mfio := alltrim(ihuman->fio)
        for i := 1 to numtoken(mfio," .")
          s1 := alltrim(token(mfio," .",i))
          if !empty(s1)
            ++k
            if k < 3
              afio[k] := s1
            else
              s += s1+" "
            endif
          endif
        next
        afio[3] := alltrim(s)
      endif
      lkod_k := 0 ; mfio := padr(mfio,50)
      select KART
      set order to 2
      find ("1"+upper(mfio)+dtos(ihuman->dr))
      if found()
        lkod_k := kart->kod
      endif
      set order to 1
      if empty(lkod_k)
        Add1Rec(7)
        lkod_k := kart->kod := recno()
        kart->FIO    := mFIO
        kart->DATE_R := ihuman->dr
      else
        goto (lkod_k)
        G_RLock(forever)
      endif
      mdate_r := kart->DATE_R ; m1VZROS_REB := M1NOVOR := 0
      fv_date_r()
      kart->pol       := iif(ihuman->W==1, "М","Ж")
      kart->VZROS_REB := m1VZROS_REB
      kart->POLIS     := make_polis(ihuman->spolis,ihuman->npolis)
      kart->snils     := ihuman->snils
      if !empty(ihuman->adres)
        kart->adres := ihuman->adres
      endif
      if TwoWordFamImOt(afio[1]) .or. TwoWordFamImOt(afio[2]) .or. TwoWordFamImOt(afio[3])
        kart->MEST_INOG := 9
      else
        kart->MEST_INOG := 0
      endif
      select KART2
      do while kart2->(lastrec()) < lkod_k
        APPEND BLANK
      enddo
      goto (lkod_k)
      G_RLock(forever)
      //
      select KART_
      do while kart_->(lastrec()) < lkod_k
        APPEND BLANK
      enddo
      goto (lkod_k)
      G_RLock(forever)
      //
      kart_->VPOLIS := ihuman->vpolis
      kart_->SPOLIS := ihuman->SPOLIS
      kart_->NPOLIS := ihuman->NPOLIS
      kart_->SMO    := ihuman->smo
      kart_->vid_ud := ihuman->DOCTYPE
      kart_->ser_ud := ihuman->DOCSER
      kart_->nom_ud := ihuman->DOCNUM
      kart_->mesto_r:= ihuman->MR
      kart_->okatog := ihuman->OKATOG
      kart_->okatop := ihuman->OKATOP
      if !empty(ihuman->adresp)
        kart_->adresp := ihuman->adresp
      endif
      //
      select KFIO
      find (str(lkod_k,7))
      if found()
        if kart->MEST_INOG == 9
          G_RLock(forever)
          kfio->FAM := afio[1]
          kfio->IM  := afio[2]
          kfio->OT  := afio[3]
        else
          DeleteRec(.t.)
        endif
      else
        if kart->MEST_INOG == 9
          AddRec(7)
          kfio->kod := lkod_k
          kfio->FAM := afio[1]
          kfio->IM  := afio[2]
          kfio->OT  := afio[3]
        endif
      endif
      fl_nameismo := .f.
      if int(val(ihuman->SMO)) == 34
        fl_nameismo := .t.
        kart_->KVARTAL_D := ihuman->SMO_OK // ОКАТО субъекта РФ территории страхования
      endif
      select KSN
      find (str(lkod_k,7))
      if found()
        if fl_nameismo
          G_RLock(forever)
          ksn->smo_name := ihuman->SMO_NAM
        else
          DeleteRec(.t.)
        endif
      else
        if fl_nameismo
          AddRec(7)
          ksn->kod := lkod_k
          ksn->smo_name := ihuman->SMO_NAM
        endif
      endif
      UnLock
      //
      select TMP_KSG
      find (str(ihuman->(recno()),7))
      if found()
        ihuman->KSG := tmp_ksg->CODE_USL
        ihuman->CENA_KSG := tmp_ksg->TARIF
      endif
      //
      fl_povtor := .f.
      select HUMAN
      set order to 2
      find (str(lkod_k,7))
      do while human->kod_k == lkod_k .and. !eof()
        v1 := iif(tmp_ksg->(found()), tmp_ksg->TARIF, ihuman->SUMV)
        if human->K_DATA == ihuman->DATE_2 .and. ;
           upper(human->uch_doc) == upper(padr(ihuman->NHISTORY,10)) .and. ;
           round(human->CENA_1,2) == round(v1,2)
          //
          ausl_i := {}
          select IHU
          find (str(ihuman->kod,10))
          do while ihu->kod == ihuman->kod .and. !eof()
            aadd(ausl_i,{padr(ihu->CODE_USL,20),ihu->PROFIL})
            skip
          enddo
          if tmp_ksg->(found()) // добавим в массив услугу КСГ
            aadd(ausl_i,{padr(tmp_ksg->CODE_USL,20),ihuman->PROFIL})
          endif
          asort(ausl_i,,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) })
          //
          ausl_o := {}
          select HU
          find (str(human->kod,7))
          do while hu->kod == human->kod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            aadd(ausl_o,{padr(usl->shifr,20),hu_->PROFIL})
            skip
          enddo
          select MOHU
          find (str(human->kod,7))
          do while mohu->kod == human->kod .and. !eof()
            mosu->(dbGoto(mohu->u_kod))
            aadd(ausl_o,{mosu->shifr1,hu_->PROFIL})
            skip
          enddo
          asort(ausl_o,,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) })
          //
          if !emptyany(ausl_i,ausl_o) .and. ausl_i[1,1] == ausl_o[1,1] ;
                                      .and. ausl_i[1,2] == ausl_o[1,2]
            strfile("запись № "+lstr(ihuman->(recno()))+;
                "(KOD = "+lstr(ihuman->kod)+;
                ") повторная: "+rtrim(ihuman->fio)+hb_eol(),cFileProtokol,.t.)
            fl_povtor := .t. ; exit
          endif
        endif
        select HUMAN
        skip
      enddo
      //
      if fl_povtor
        ++ip
      else
        ++iz
        select IOTD
        find (str(ihuman->otd,3))
        select OTD
        do while otd->(lastrec()) < ihuman->otd
          append blank
        enddo
        for i := 1 to ihuman->otd-1
          goto (i)
          if otd->kod == 0 .and. !deleted()
            DeleteRec(.t.)
          endif
        next
        goto (ihuman->otd)
        if deleted()
          G_RLock(forever)
          RECALL
        else
          G_RLock(forever)
        endif
        otd->KOD     := iotd->KOD
        otd->NAME    := iotd->NAME
        otd->KOD_LPU := iotd->KOD_LPU
        UnLock
        //
        select ILPU
        find (str(iotd->kod_lpu,3))
        select LPU
        do while lpu->(lastrec()) < iotd->kod_lpu
          append blank
        enddo
        for i := 1 to iotd->kod_lpu-1
          goto (i)
          if lpu->kod == 0 .and. !deleted()
            DeleteRec(.t.)
          endif
        next
        goto (iotd->kod_lpu)
        if deleted()
          G_RLock(forever)
          RECALL
        else
          G_RLock(forever)
        endif
        lpu->KOD  := ilpu->KOD
        lpu->NAME := ilpu->NAME
        UnLock
        //
        lvrach := 0
        if ihuman->VRACH > 0
          select PERSO
          find (str(ihuman->VRACH,5))
          if found()
            G_RLock(forever)
          else
            AddRecN()
            perso->kod := recno()
            perso->tab_nom := ihuman->VRACH
          endif
          lvrach := perso->kod
          perso->fio  := ihuman->VRACH_FIO
          perso->uch  := iotd->kod_lpu
          perso->otd  := ihuman->otd
          perso->prvs := ihuman->PRVS
          UnLock
        endif
        //
        M1NOVOR := ihuman->NOVOR ; mDATE_R2 := ihuman->REB_DR
        fv_date_r(ihuman->DATE_1)
        select HUMAN
        set order to 1
        Add1Rec(7)
        mkod := human->kod := recno()
        select HUMAN_
        do while human_->(lastrec()) < mkod
          APPEND BLANK
        enddo
        goto (mkod)
        G_RLock(forever)
        //
        select HUMAN_2
        do while human_2->(lastrec()) < mkod
          APPEND BLANK
        enddo
        goto (mkod)
        G_RLock(forever)
        //
        human->kod_k      := lkod_k
        human->TIP_H      := B_STANDART
        human->FIO        := kart->FIO          // Ф.И.О. больного
        human->POL        := kart->POL          // пол
        human->DATE_R     := kart->DATE_R       // дата рождения больного
        human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
        human->KOD_DIAG   := ihuman->ds1
        for i := 1 to 7
          pole := "ihuman->ds2"+iif(i==1,"","_"+lstr(i))
          if !empty(&pole)
            poleh := {"KOD_DIAG2","KOD_DIAG3","KOD_DIAG4",;
                      "SOPUT_B1","SOPUT_B2","SOPUT_B3","SOPUT_B4"}[i]
            poleh := "human->"+poleh
            &poleh := &pole
          endif
        next
        human->KOMU       := 0
        human_->SMO       := ihuman->smo
        human->POLIS      := make_polis(ihuman->spolis,ihuman->npolis)
        human->LPU        := iotd->kod_lpu
        human->OTD        := ihuman->otd
        human->UCH_DOC    := ihuman->NHISTORY
        human->N_DATA     := ihuman->DATE_1
        human->K_DATA     := ihuman->DATE_2
        if tmp_ksg->(found()) // тариф КСГ
          human->CENA := human->CENA_1 := tmp_ksg->TARIF
        else
          human->CENA := human->CENA_1 := ihuman->SUMV
        endif
        if otd->TIPLU == TIP_LU_G_CIT // жидкостная цитология рака шейки матки
          human->ishod := 98
        elseif otd->TIPLU == TIP_LU_PREND // пренатальная диагностика
          human->ishod := 99
        endif
        human_->VPOLIS    := ihuman->vpolis
        human_->SPOLIS    := ihuman->SPOLIS
        human_->NPOLIS    := ihuman->NPOLIS
        human_->OKATO     := ""
        if ihuman->novor == 0
          human_->NOVOR   := 0
          human_->DATE_R2 := ctod("")
          human_->POL2    := ""
        else
          human_->NOVOR   := ihuman->REB_NUMBER
          human_->DATE_R2 := ihuman->REB_DR
          human_->POL2    := iif(ihuman->REB_POL==1, "М","Ж")
        endif
        human_->USL_OK    := ihuman->USL_OK
        human_->VIDPOM    := 1//ihuman->VIDPOM
        human_->PROFIL    := ihuman->PROFIL
        human_->IDSP      := ihuman->IDSP
        human_->NPR_MO    := ihuman->NPR_MO
        if ihuman->USL_OK == 1
          v := iif(between(ihuman->EXTR,1,2), ihuman->EXTR, 1)
          human_->FORMA14 := str(v-1,1)+"000"
        elseif ihuman->USL_OK == 4
          v := iif(between(ihuman->F_SP,1,2), ihuman->F_SP, 1)
          human_->FORMA14 := str(v-1,1)+"000"
        endif
        human_->KOD_DIAG0 := ihuman->ds0
        human_->RSLT_NEW  := ihuman->rslt
        human_->ISHOD_NEW := ihuman->ishod
        human_->VRACH     := lvrach
        human_->PRVS      := ihuman->prvs
        human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
        human_->ST_VERIFY := 0 // снова ещё не проверен
        human_->ID_PAC    := mo_guid(1,human_->(recno()))
        human_->ID_C      := mo_guid(2,human_->(recno()))
        human_->SUMP      := 0
        human_->OPLATA    := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := chr(0)
        human->date_e  := ''
        if fl_nameismo
          human_->OKATO := ihuman->SMO_OK // ОКАТО субъекта РФ территории страхования
        endif
        for i := 1 to 3
          pole := "ihuman->ds3"+iif(i==1,"","_"+lstr(i))
          if !empty(&pole)
            poleh := "human_2->osl"+lstr(i)
            &poleh := &pole
          endif
        next
        if !empty(ihuman->VID_HMP)
          human_2->VMP := 1
          human_2->VIDVMP := ihuman->VID_HMP
          human_2->METVMP := ihuman->METOD_HMP
        endif
        select HSN
        find (str(mkod,7))
        if found()
          if fl_nameismo
            G_RLock(forever)
            hsn->smo_name := ihuman->SMO_NAM
          else
            DeleteRec(.t.)
          endif
        else
          if fl_nameismo
            AddRec(7)
            hsn->kod := mkod
            hsn->smo_name := ihuman->SMO_NAM
          endif
        endif
        UnLock
        //
        ihuman->REC_HUMAN := mkod
        if tmp_ksg->(found()) // добавить услугу - КСГ
          v1 := 0
          kod_usl := foundOurUsluga(tmp_ksg->CODE_USL,human->k_data,human_->profil,human->VZROS_REB,@v1)
          select HU
          Add1Rec(7)
          hu->kod     := human->kod
          hu->kod_vr  := human_->VRACH
          hu->kod_as  := 0
          hu->u_koef  := 1
          hu->u_koef  := 1
          hu->u_kod   := kod_usl
          hu->u_cena  := tmp_ksg->TARIF
          hu->is_edit := 0
          hu->date_u  := dtoc4(human->n_data)
          hu->otd     := human->otd
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := tmp_ksg->TARIF
          hu->KOL_RCP := 0
          select HU_
          do while hu_->(lastrec()) < hu->(recno())
            APPEND BLANK
          enddo
          goto (hu->(recno()))
          G_RLock(forever)
          hu_->ID_U := mo_guid(3,hu_->(recno()))
          hu_->PROFIL := human_->PROFIL
          hu_->PRVS   := human_->PRVS
          hu_->kod_diag := human->KOD_DIAG
          hu_->zf := ""
          UNLOCK
        endif
        //
        select IHU
        find (str(ihuman->kod,10))
        do while ihu->kod == ihuman->kod .and. !eof()
          select IOTD
          find (str(ihu->otd,3))
          select OTD
          do while otd->(lastrec()) < ihu->otd
            append blank
          enddo
          for i := 1 to ihu->otd-1
            goto (i)
            if otd->kod == 0 .and. !deleted()
              DeleteRec(.t.)
            endif
          next
          goto (ihu->otd)
          if deleted()
            G_RLock(forever)
            RECALL
          else
            G_RLock(forever)
          endif
          otd->KOD     := iotd->KOD
          otd->NAME    := iotd->NAME
          otd->KOD_LPU := iotd->KOD_LPU
          UnLock
          //
          lvrach := 0
          if ihu->VRACH > 0
            select PERSO
            find (str(ihu->VRACH,5))
            if found()
              G_RLock(forever)
            else
              AddRecN()
              perso->kod := recno()
              perso->tab_nom := ihu->VRACH
            endif
            lvrach := perso->kod
            perso->fio  := ihu->VRACH_FIO
            perso->uch  := iotd->kod_lpu
            perso->otd  := ihu->otd
            perso->prvs := ihu->PRVS
            UnLock
          endif
          lassis := 0
          if ihu->(fieldpos("assis")) > 0 ;
                          .and. ihu->(fieldtype("assis")) == "N" ;
                          .and. !empty(ihu->assis)
            select PERSO
            find (str(ihu->assis,5))
            if found()
              G_RLock(forever)
            else
              AddRecN()
              perso->kod := recno()
              perso->tab_nom := ihu->assis
            endif
            lassis := perso->kod
            perso->uch := iotd->kod_lpu
            perso->otd := ihu->otd
            if ihu->(fieldpos("assis_fio")) > 0 ;
                          .and. ihu->(fieldtype("assis_fio")) == "C" ;
                          .and. !empty(ihu->assis_fio)
              perso->fio := ihu->assis_fio
            endif
            UnLock
          endif
          //
          kod_usl := kod_uslf := 0
          if len(alltrim(ihu->CODE_USL)) > 9
            select MOSU
            set order to 3 // по шифру ФФОМС
            find (padr(ihu->CODE_USL,20))
            if found()
              kod_uslf := mosu->kod
            else
              select LUSLF
              find (padr(ihu->CODE_USL,20))
              if found()
                select MOSU
                set order to 1
                FIND (STR(-1,6))
                if found()
                  G_RLock(forever)
                else
                  AddRec(6)
                endif
                kod_uslf := mosu->kod := recno()
                mosu->name := luslf->name
                mosu->shifr1 := ihu->CODE_USL
                mosu->PROFIL := ihu->PROFIL
                UnLock
              endif
            endif
            if !empty(kod_uslf)
              select MOHU
              Add1Rec(7)
              mohu->kod     := human->kod
              mohu->kod_vr  := lvrach
              mohu->kod_as  := lassis
              mohu->u_kod   := kod_uslf
              mohu->u_cena  := 0//ihu->tarif
              mohu->date_u  := dtoc4(ihu->DATE_IN)
              mohu->otd     := ihu->otd
              mohu->kol_1   := ihu->KOL_USL
              mohu->stoim_1 := 0//ihu->SUMV_USL
              mohu->ID_U    := mo_guid(4,mohu->(recno()))
              mohu->PROFIL  := ihu->PROFIL
              mohu->PRVS    := ihu->PRVS
              mohu->kod_diag := ihu->ds
              UNLOCK
              //
              ihu->REC_HUMANU := mohu->(recno())
            endif
          endif
          if empty(kod_uslf)
            select USL
            set order to 2
            find (padr(ihu->CODE_USL,10))
            if found()
              kod_usl := usl->kod
            else
              v1 := v2 := 0 ; mname := ""
              select LUSL
              find (padr(ihu->CODE_USL,10))
              if found()
                mname := lusl->name
                v1 := fcena_oms(lusl->shifr,.t.,sys_date)
                v2 := fcena_oms(lusl->shifr,.f.,sys_date)
              endif
              select USL
              set order to 1
              FIND (STR(-1,4))
              if found()
                G_RLock(forever)
              else
                AddRec(4)
              endif
              kod_usl := usl->kod := recno()
              usl->name := mname
              usl->shifr := ihu->CODE_USL
              usl->PROFIL := ihu->PROFIL
              usl->cena   := v1
              usl->cena_d := v2
              UnLock
            endif
            //
            select HU
            Add1Rec(7)
            hu->kod     := human->kod
            hu->kod_vr  := lvrach
            hu->kod_as  := lassis
            hu->u_koef  := 1
            hu->u_kod   := kod_usl
            if ihu->(fieldpos("dom")) > 0 ;
                          .and. ihu->(fieldtype("dom")) == "N" ;
                          .and. eq_any(ihu->dom,1,2)
              hu->KOL_RCP := -ihu->dom
            endif
            hu->u_cena  := ihu->tarif
            hu->is_edit := 0
            hu->date_u  := dtoc4(ihu->DATE_IN)
            hu->otd     := ihu->otd
            hu->kol := hu->kol_1 := ihu->KOL_USL
            hu->stoim := hu->stoim_1 := ihu->SUMV_USL
            select HU_
            do while hu_->(lastrec()) < hu->(recno())
              APPEND BLANK
            enddo
            goto (hu->(recno()))
            G_RLock(forever)
            hu_->ID_U := mo_guid(3,hu_->(recno()))
            hu_->PROFIL := ihu->PROFIL
            hu_->PRVS   := ihu->PRVS
            hu_->kod_diag := ihu->ds
            UNLOCK
            //
            ihu->REC_HUMANU := hu->(recno())
          endif
          //
          select IHU
          skip
        enddo
      endif
      //
      select IHUMAN
      skip
    enddo
    SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
    if iz > 0
      strfile("Успешно импортировано "+lstr(iz)+" записей"+hb_eol(),cFileProtokol,.t.)
    endif
    if ip > 0
      strfile("Попытка повторно импортировать "+lstr(ip)+" записей"+hb_eol(),cFileProtokol,.t.)
    endif
  endif
  close databases
endif
rest_box(buf)
return fl

*****
Function import_verify_okato(s)
Local fl := .t.
if right(s,9) == replicate('0',9)
  select REGION
  find (left(s,2))
  fl := found()
elseif right(s,6) == replicate('0',6)
  select OBLAST
  find (left(s,5))
  fl := found()
else
  select SELO
  find (s)
  fl := found()
endif
return fl

*

***** Импорт данных из программы "Флюоротека" фирмы "ЧИП плюс"
Function import_fluoroteka()
Local full_zip, buf, k, str_sem := "Импорт флюоротеки"
if G_SLock(str_sem)
  Private p_var_manager := str_sem
  buf := box_shadow(T_ROW-2,T_COL+5,T_ROW-2,T_COL+5+26+28,color1,"Выбор архива REGI_FL.ZIP",,0)
  full_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*"+szip)
  if !empty(full_zip) .and. ;
      (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip))) != NIL
    rest_box(buf)
    if ascan(arr_f,{|x| upper(x) == "_REG.D"}) == 0
      func_error(4,"В архиве REGI_FL.ZIP нет необходимых файлов")
    else
      hGauge := GaugeNew(,,,"Синхронизация флюоротеки с картотекой",.t.)
      GaugeDisplay( hGauge )
      Use (_tmp_dir1+"_reg.d") new alias RG
      index on upper(fio)+dtos(data_r) to (cur_dir+"tmp_r") progress
      G_Use(dir_server+"kartote_",,"KART_")
      R_Use(dir_server+"kartotek",,"KART")
      go top
      do while !eof()
        GaugeUpdate( hGauge, recno()/lastrec() )
        select KART_
        if kart_->(lastrec()) < kart->(lastrec())
          k := 0 // Добавляем записи
          do while kart_->(lastrec()) < kart->(lastrec())
            append blank
            if ++k % 4000 == 0
              commit
            endif
          enddo
          Commit
        endif
        if len(alltrim(kart->fio)) > 5
          kart_->(dbGoto(kart->(recno())))
          select RG
          find (upper(kart->fio)+dtos(kart->date_r))
          if found()
            if !(kart_->date_fl == dtoc4(rg->data_i) .and. kart_->gr_risk == rg->gr_risk)
              select KART_
              G_RLock(forever)
              kart_->date_fl := dtoc4(rg->data_i)
              kart_->gr_risk := rg->gr_risk
              dbUnLock()
            endif
          else
            if !(kart_->date_fl == space(4) .and. kart_->gr_risk == 0)
              // очищаем
              select KART_
              G_RLock(forever)
              kart_->date_fl := ""
              kart_->gr_risk := 0
              dbUnLock()
            endif
          endif
        endif
        select KART
        if recno() % 4000 == 0
          commit
        endif
        skip
      enddo
      CloseGauge(hGauge)
      close databases
      n_message({"","Прием данных завершен"})
    endif
  endif
  G_SUnLock(str_sem)
  rest_box(buf)
else
  func_error(4,"Ошибка! Импорт флюоротеки производит другой пользователь.")
endif
return NIL

***** 23.07.19
Function f_export(k)
Static si1 := 1, sds := 1, ssp := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 // КДП-2
      mas_pmt := {"Экспорт в ~ЛИС",;
                  "Экспорт ~счетов в ВОМИАЦ"}
      mas_msg := {"Экспорт сведений в ЛИС",;
                  "Экспорт счетов за отчётный период январь 2018 - июнь 2019 года в ВОМИАЦ"}
      mas_fun := {"export_to_LIS()",;
                  "f_export(13)"}
    else
      mas_pmt := {"Экспорт ~военнослужащих",;
                  'Экспорт в программную систему "~БАРС"',;
                  "Экспорт ~счетов в ВОМИАЦ"}
      mas_msg := {"Экспорт в ТФОМС сведений о медицинской помощи, оказанной военнослужащим",;
                  "Экспорт всей картотеки в файл для передачи в программную систему БАРС",;
                  "Экспорт счетов за отчётный период январь 2018 - июнь 2019 года в ВОМИАЦ"}
      mas_fun := {"f_export(11)",;
                  "f_export(12)",;
                  "f_export(13)"}
      if glob_mo[_MO_IS_UCH]
        aadd(mas_pmt, "Экспорт прикрепленного населения в ВОМИАЦ")
        aadd(mas_msg, 'Создание файла для передачи в ВОМИАЦ (письмо №14-10-1/328 от 07.11.18г.)')
        aadd(mas_fun, "f_export(14)")
      endif
    endif
    popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    mas_pmt := {"~Просмотр/запись",;
                "~Создать файл отправки"}
    mas_msg := {"Просмотреть созданные файлы для отправки в ТФОМС и записать их на носитель",;
                "Создание файла экспорта сведений о медицинской помощи, оказанной военнослужащим"}
    mas_fun := {"f_export(21)",;
                "f_export(22)"}
    Private sbase := "mo_voen", goal_dir := dir_server+dir_XML_MO+cslash,;
            Svoenn_sem := "Работа с военнослужащими",;
            Svoenn_err := "В данный момент с военнослужащими работает другой пользователь"
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL+5,1,mas_pmt,mas_msg,mas_fun)
  case k == 12
    if tip_polzovat == TIP_ADM
      str_sem := "Создание файла отправки в систему БАРС"
      if G_SLock(str_sem)
        full_naselenie_create_BARS()
        G_SUnLock(str_sem)
      else
        func_error(4,err_slock)
      endif
    else
      func_error(4,err_admin)
    endif
  case k == 13
    if tip_polzovat == TIP_ADM
      str_sem := "Создание файла отправки в ОБЛЗДРАВ"
      if G_SLock(str_sem)
        create_schets_OBLSDRAV()
        G_SUnLock(str_sem)
      else
        func_error(4,err_slock)
      endif
    else
      func_error(4,err_admin)
    endif
  case k == 14
    if tip_polzovat == TIP_ADM
      str_sem := "Создание файла отправки в ОБЛЗДРАВ"
      if G_SLock(str_sem)
        pripisnoe_naselenie_create_OBLSDRAV()
        G_SUnLock(str_sem)
      else
        func_error(4,err_slock)
      endif
    else
      func_error(4,err_admin)
    endif
  case k == 21
    export_military()
  case k == 22
    f_create_military()
endcase
if k > 10
  if between(k,11,19)
    si1 := int(val(right(lstr(k),1)))
  endif
endif
return NIL

***** 08.05.17 Создание файла для ЛИС из БД КДП2 (пациенты с кодом ЛИС и, возможно, изменёнными реквизитами)
Function export_to_LIS()
create_DBF_for_LIS(2)
return NIL

***** 20.11.16
Function create_file_export_military()
if !hb_FileExists(dir_server+sbase+sdbf)
  adbf := {;
   {"period",      "C", 26,0},; // отчетный период
   {"KOL",         "N",  6,0},; // количество пациентов
   {"FNAME",       "C", 18,0},; // имя файла без расширения
   {"DFILE",       "D",  8,0},; // дата создания файла
   {"TFILE",       "C",  5,0},; // время создания файла
   {"DATE_OUT",    "D",  8,0},; // дата отправки в ТФОМС
   {"NUMB_OUT",    "N",  2,0},; // номер отправки в ТФОМС;сколько раз всего записывали файл на носитель;
   {"company",     "C",255,0};  // список компаний
  }
  reconstruct(dir_server+sbase,adbf,,,.t.)
endif
return NIL

***** 20.11.16
Function export_military()
Local adbf, buf := savescreen()
if !G_SLock(Svoenn_sem)
  return func_error(4,Svoenn_err)
endif
create_file_export_military()
G_Use(dir_server+sbase,,"VOEN")
index on dtos(dfile) to (cur_dir+"tmp_voen") DESCENDING
go top
if eof()
  keyboard chr(K_END)+chr(K_ENTER)
else
  Alpha_Browse(T_ROW,2,22,77,"f1_export_military",color0,,,,,,,;
               "f2_export_military",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
G_SUnLock(Svoenn_sem)
restscreen(buf)
return NIL

***** 20.11.16
Function f1_export_military(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(voen->FNAME)+sxls), ;
                     iif(empty(voen->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew("Наименование файла",{|| voen->FNAME })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(voen->dfile) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" за период",{|| voen->period })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во", {|| put_val(voen->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_export_military() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход;  ^<F5>^ запись файла для ТФОМС;  ^<Del>^ удалить ещё не записанный файл")
return NIL

*****
Static Function f11_export_military()
Local s := ""
if !hb_fileExists(goal_dir+alltrim(voen->FNAME)+sxls)
  s := "нет файла"
elseif empty(voen->date_out)
  s := "не записан"
else
  s := "зап. "+lstr(voen->NUMB_OUT)+" раз"
endif
return padr(s,10)

***** 20.11.16
Function f2_export_military(nKey,oBrow)
Local ret := -1, s, buf := savescreen()
do case
  case nKey == K_F5
    if f_Esc_Enter("записи файла за "+date_8(voen->dfile))
      Private p_var_manager := "copy_schet"
      s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
      if !empty(s)
        if upper(s) == upper(goal_dir)
          func_error(4,"Вы выбрали каталог, в котором уже записан целевой файл! Это недопустимо.")
        else
          zip_file := alltrim(voen->FNAME)+sxls
          if hb_fileExists(goal_dir+zip_file)
            mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
            //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
            copy file (goal_dir+zip_file) to (s+zip_file)
            //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
            if hb_fileExists(s+zip_file)
              voen->(G_RLock(forever))
              voen->DATE_OUT := sys_date
              if voen->NUMB_OUT < 99
                voen->NUMB_OUT ++
              endif
              UnLock
              Commit
            else
              smsg := "Ошибка записи файла "+s+zip_file
              func_error(4,"Ошибка записи файла "+s+zip_file)
            endif
          else
            func_error(4,"Не обнаружен файл "+goal_dir+zip_file)
          endif
        endif
      endif
    endif
    ret := 0
  case nKey == K_DEL .and. empty(voen->DATE_OUT)
    if f_Esc_Enter("удаления файла за "+date_8(voen->dfile),.t.)
      stat_msg("Подтвердите удаление ещё раз.") ; mybell(2)
      if f_Esc_Enter("удаления файла за "+date_8(voen->dfile),.t.)
        mywait("Ждите. Производится удаление файла с военнослужащими.")
        zip_file := alltrim(voen->fname)+sxls
        if hb_fileExists(goal_dir+zip_file)
          delete file (goal_dir+zip_file)
        endif
        select VOEN
        DeleteRec(.t.)
        stat_msg("Файл с военнослужащими удалён!") ; mybell(2,OK)
        ret := 1
      endif
    endif
endcase
restscreen(buf)
return ret

***** 20.11.16
Function VoenList2arr(sList)
Local i, j, s, arr := {}, ar
if !empty(sList)
  for i := 1 to numtoken(sList,";")
    s := alltrim(token(sList,";",i))
    ar := {}
    for j := 1 to numtoken(s,",")
      aadd(ar, int(val(alltrim(token(s,",",j)))) )
    next
    aadd(arr, aclone(ar))
  next
endif
return arr

***** 20.11.16
Function f_create_military()
Local fl := .f., k, buf24 := save_maxrow(), t_arr[BR_LEN], blk, arr := {}, arr_m
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
if !G_SLock(Svoenn_sem)
  return func_error(4,Svoenn_err)
endif
mywait()
create_file_export_military()
G_Use(dir_server+sbase,,"VOEN")
go top
if !eof()
  go bottom
  arr := VoenList2arr(alltrim(voen->company))
  Locate for dfile == sys_date
  fl := found()
endif
close databases
if fl
  G_SUnLock(Svoenn_sem)
  return func_error(4,"Уже создан файл экспорта с датой "+full_date(sys_date)+"г.")
endif
dbcreate(cur_dir+"tmp",{{"kod","N",4,0},;
                        {"tip","N",1,0},;
                        {"name","C",30,0},;
                        {"is","L",1,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"komitet",,"KOM")
go top
do while !eof()
  select TMP
  append blank
  replace kod with kom->kod,;
          tip with 3,;
          name with kom->name,;
          is with (ascan(arr, {|x| x[1]==3 .and. x[2]==kom->kod }) > 0)
  select KOM
  skip
enddo
R_Use(dir_server+"str_komp",,"SK")
go top
do while !eof()
  if !between(sk->tfoms,44,47)
    select TMP
    append blank
    replace kod with sk->kod,;
            tip with 1,;
            name with sk->name,;
            is with (ascan(arr, {|x| x[1]==1 .and. x[2]==sk->kod }) > 0)
  endif
  select SK
  skip
enddo
k := tmp->(lastrec())
close databases
rest_box(buf24)
if k == 0
  func_error(4,"В Вашей МО не работают с комитетами и прочими компаниями.")
else
  close databases
  use (cur_dir+"tmp") new
  index on upper(name) to (cur_dir+"tmp")
  //
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := T_COL+5
  t_arr[BR_RIGHT] := t_arr[BR_LEFT]+44
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Выбор компаний (военнослужащих)"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(tmp->is, {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp->is, '', ' ') },blk },;
                       { " Наименование", {|| tmp->name },blk },;
                       { " ",{|| iif(tmp->tip==3," комитет","компания") },blk }}
  t_arr[BR_EDIT] := {|nk,ob| f1create_military(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход;  ^<+,-,Ins>^ отметить компанию для отправки военнослужащих в ТФОМС") }
  go top
  edit_browse(t_arr)
  arr := {}
  go top
  do while !eof()
    if tmp->is
      aadd(arr, {tmp->tip,tmp->kod,tmp->name})
    endif
    skip
  enddo
  k := len(arr)
  close databases
endif
if k == 0
  func_error(4,"Не выбрано ни одной компании")
elseif (arr_m := year_month(T_ROW,T_COL+5)) != NIL
  mywait()
  dbcreate(cur_dir+"tmp1",{;
    {"KOD"      ,   "N",     7,     0},; // код человека по kartotek.dbf
    {"DATE_R"   ,   "D",     8,     0},; // дата рождения больного
    {"KOMU"     ,   "N",     1,     0},; // от 1 до 5
    {"STR_CRB"  ,   "N",     2,     0},; // код стр.компании, комитета и т.п.
    {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
    {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
    {"name"     ,   "C",    40,     0},;
    {"FAM"      ,   "C",    40,     0},;
    {"IM"       ,   "C",    40,     0},;
    {"OT"       ,   "C",    40,     0}})
  use (cur_dir+"tmp1") new
  index on str(kod,7) to (cur_dir+"tmp1")
  R_Use(dir_server+"mo_kfio",,"KFIO")
  index on str(kod,7) to (cur_dir+"tmp_kfio")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to kod_k into KART
  old := arr_m[5]
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    if old != human->k_data
      old := human->k_data
      @ maxrow(),0 say date_8(old) color "W/R"
    endif
    if human->komu > 0 .and. (k := ascan(arr,{|x| x[1] == human->komu .and. x[2] == human->STR_CRB })) > 0
      arr_fio := retFamImOt(2,.f.,.t.)
      select TMP1
      find (str(human->kod_k,7))
      if !found()
        append blank
        tmp1->KOD := human->kod_k
        tmp1->DATE_R := kart->date_r
        tmp1->KOMU := arr[k,1]
        tmp1->STR_CRB := arr[k,2]
        tmp1->N_DATA := human->n_data
        tmp1->K_DATA := human->k_data
        tmp1->name := arr[k,3]
        tmp1->FAM := arr_fio[1]
        tmp1->IM  := arr_fio[2]
        tmp1->OT  := arr_fio[3]
      endif
    endif
    select HUMAN
    skip
  enddo
  k := tmp1->(lastrec())
  rest_box(buf24)
  if k == 0
    func_error(4,"Не найдено листов учёта военнослужащих "+arr_m[4])
  elseif f_alert({'Составляется таблица Excel с военнослужащими',;
                  '(количество пациентов - '+lstr(k)+').',;
                  '',;
                  'Выберите действие:'},;
                 {" Отказ "," Создание файла Excel "},;
                 2,"GR+/R","W+/R",16,,"GR+/R,N/BG") == 2
    s := ""
    for k := 1 to len(arr)
      s += lstr(arr[k,1])+","+lstr(arr[k,2])
      if k < len(arr)
        s += ";"
      endif
    next
    n_file := "V_"+glob_mo[_MO_KOD_TFOMS]+"_"+dtos(sys_date)
    delete file (n_file+sxls)
    delFRfiles()
    adbf := {{"name_f","C",30,0},;
             {"codemo","C",6,0},;
             {"name","C",60,0},;
             {"period","C",60,0},;
             {"data","C",10,0}}
    dbcreate(fr_titl, adbf)
    use (fr_titl) new alias FRT
    append blank
    frt->name_f := n_file+sxls
    frt->codemo := glob_mo[_MO_KOD_TFOMS]
    frt->name   := glob_mo[_MO_SHORT_NAME]
    frt->data   := full_date(sys_date)
    frt->period := arr_m[4]
    adbf := {{"nomer","N",4,0},;
             {"fam","C",50,0},;
             {"im","C",50,0},;
             {"ot","C",50,0},;
             {"date_r","C",10,0},;
             {"N_DATA","C",10,0},; // дата начала лечения
             {"K_DATA","C",10,0},; // дата окончания лечения
             {"name","C",40,0}}
    dbcreate(fr_data,adbf)
    use (fr_data) new alias FRD
    select TMP1
    index on upper(fam+im+ot) to tmp1
    k := 0
    go top
    do while !eof()
      select FRD
      append blank
      frd->nomer := ++k
      frd->fam := tmp1->fam
      frd->im := tmp1->im
      frd->ot := tmp1->ot
      frd->date_r := full_date(tmp1->date_r)
      frd->N_DATA := full_date(tmp1->n_data)
      frd->K_DATA := full_date(tmp1->k_data)
      frd->name := tmp1->name
      select TMP1
      skip
    enddo
    close databases
    call_fr("mo_voenn",3,n_file+sxls,,.f.)
    G_Use(dir_server+sbase,,"VOEN")
    AddRecN()
    voen->period := arr_m[4]
    voen->KOL := k
    voen->FNAME := n_file
    voen->DFILE := sys_date
    voen->TFILE := hour_min(seconds())
    voen->DATE_OUT := ctod("")
    voen->NUMB_OUT := 0
    voen->company := s
    close databases
    if chip_copy_zipXML(n_file+sxls,goal_dir,.t.)
      keyboard chr(K_HOME)+chr(K_ENTER)
    endif
  endif
  close databases
endif
G_SUnLock(Svoenn_sem)
rest_box(buf24)
return NIL

***** 20.11.16
Function f1create_military(nKey,oBrow,regim)
Local k := -1, rec, fl
if regim == "edit"
  do case
    case nkey == K_INS
      replace tmp->is with !tmp->is
      k := 0
      keyboard chr(K_TAB)
    case nkey == 43 .or. nkey == 45  // + или -
      rec := recno()
      tmp->(dbeval({|| tmp->is := (nkey == 43) }))
      goto (rec)
      k := 0
  endcase
endif
return k

***** 15.11.18 создать файл в БАРС
Function full_naselenie_create_BARS()
Local ii := 0, s, buf := savescreen(), fl, af := {}, arr_fio, ta, fl_polis, fl_pasport, tt
Local mo_bars :=  {;
   {"C_NAME",     "C",    160,      0},;
   {"CARD_NUMB",  "C",     26,      0},;
   {"SURNAME",    "C",     60,      0},;
   {"FIRSTNAME",  "C",     60,      0},;
   {"LASTNAME",   "C",     60,      0},;
   {"BIRTHDATE",  "D",      8,      0},;
   {"SEX",        "C",     10,      0},;
   {"SNILS",      "C",     11,      0},;
   {"OMS_TYPE",   "C",      1,      0},;
   {"OMS_SER",    "C",     60,      0},;
   {"OMS_NUM",    "C",     60,      0},;
   {"OMS_AGCODE", "C",    250,      0},;
   {"OMS_WHEN",   "D",      8,      0},;
   {"OMS_BEGIN",  "D",      8,      0},;
   {"OMS_END",    "D",      8,      0},;
   {"DMS_TYPE",   "C",      1,      0},;
   {"DMS_SER",    "C",     60,      0},;
   {"DMS_NUM",    "C",     60,      0},;
   {"DMS_AGCODE", "C",    250,      0},;
   {"DMS_WHEN",   "D",      8,      0},;
   {"DMS_BEGIN",  "D",      8,      0},;
   {"DMS_END",    "D",      8,      0},;
   {"REGLPUCOD",  "C",     20,      0},;
   {"SITE_CODE",  "C",     20,      0},;
   {"REGPURPCOD", "C",     20,      0},;
   {"RS_BEGIN",   "D",      8,      0},;
   {"RS_END",     "D",      8,      0},;
   {"SOC_STATE",  "C",    250,      0},;
   {"SOC_BEGIN",  "D",      8,      0},;
   {"SOC_END",    "D",      8,      0},;
   {"PHONE1",     "C",     60,      0},;
   {"PHONE2",     "C",     60,      0},;
   {"EMAIL",      "C",     60,      0},;
   {"FAX",        "C",     60,      0},;
   {"TELEX",      "C",     60,      0},;
   {"CONT_BEGIN", "D",      8,      0},;
   {"CONT_END",   "D",      8,      0},;
   {"IS_MAIN",    "C",      1,      0},;
   {"PD_TYPE",    "C",     60,      0},;
   {"PD_SER",     "C",     60,      0},;
   {"PD_NUMB",    "C",     60,      0},;
   {"PD_WHEN",    "D",      8,      0},;
   {"PD_WHO",     "C",    250,      0},;
   {"CITIZEN",    "C",    250,      0},;
   {"PD_BEGIN",   "D",      8,      0},;
   {"PD_END",     "D",      8,      0},;
   {"KLADR_CODE", "C",     20,      0},;
   {"RAION",      "C",    250,      0},;
   {"CITY",       "C",    250,      0},;
   {"STREET",     "C",     60,      0},;
   {"HOUSE",      "C",     11,      0},;
   {"HOUSELIT",   "C",      1,      0},;
   {"BLOCK",      "N",      5,      0},;
   {"FLAT",       "N",      5,      0},;
   {"FLATLIT",    "C",      1,      0},;
   {"ADDR_INDEX", "C",     10,      0},;
   {"ADDR_BEGIN", "D",      8,      0},;
   {"ADDR_END",   "D",      8,      0},;
   {"MANUAL_INP", "C",    250,      0},;
   {"MARITAL",    "C",     60,      0},;
   {"MAR_BEGIN",  "D",      8,      0},;
   {"MAR_END",    "D",      8,      0},;
   {"ADDR_MAIN",  "C",      1,      0},;
   {"WORK_PLACE", "C",     40,      0},;
   {"WORK_OKVED", "C",    250,      0},;
   {"WORK_RAION", "C",    250,      0},;
   {"WORK_DEP",   "C",    250,      0},;
   {"JOBTITLE",   "C",    250,      0},;
   {"WORK_HAND",  "C",    250,      0},;
   {"WORK_BEGIN", "D",      8,      0},;
   {"WORK_END",   "D",      8,      0},;
   {"CATEGORY",   "C",    250,      0},;
   {"CAT_SER",    "C",     60,      0},;
   {"CAT_NUM",    "C",     60,      0},;
   {"AC_DATE",    "D",      8,      0},;
   {"CAT_BEGIN",  "D",      8,      0},;
   {"CAT_END",    "D",      8,      0},;
   {"INAB_NUM",   "C",     60,      0},;
   {"INAB_TYPE",  "C",     60,      0},;
   {"INAB_GRADE", "C",     60,      0},;
   {"INAB_GROUP", "C",     60,      0},;
   {"DISAB_GRAD", "C",     60,      0},;
   {"INAB_BEGIN", "D",      8,      0},;
   {"INAB_END",   "D",      8,      0},;
   {"DEATHDATE",  "D",      8,      0},;
   {"DEATHTIME",  "C",      5,      0},;
   {"DEATH_DOC",  "C",     60,      0},;
   {"DEATH_NUM",  "C",     60,      0},;
   {"DEATH_DATE", "D",      8,      0},;
   {"PRIMECH",    "C",    250,      0},;
   {"REGTYPECOD", "C",     30,      0},;
   {"REGCATCOD",  "C",     20,      0},;
   {"REGDOCNUMB", "C",     15,      0},;
   {"F_KLADR",    "C",     20,      0},;
   {"F_RAION",    "C",    250,      0},;
   {"F_CITY",     "C",    250,      0},;
   {"F_STREET",   "C",     60,      0},;
   {"F_HOUSE",    "C",     11,      0},;
   {"F_HOUSELIT", "C",      1,      0},;
   {"F_BLOCK",    "N",      5,      0},;
   {"F_FLAT",     "N",      5,      0},;
   {"F_FLATLIT",  "C",      1,      0},;
   {"F_INDEX",    "C",     10,      0},;
   {"F_BEGIN",    "D",      8,      0},;
   {"F_END",      "D",      8,      0},;
   {"F_MANL_INP", "C",    250,      0};
  }
if !f_Esc_Enter("создания файла для БАРСа",.t.)
  return NIL
endif
ClrLine(maxrow(),color0)
dbcreate(cur_dir+"bars",mo_bars)
use (cur_dir+"bars") new
hGauge := GaugeNew(,,,"Составление файла для БАРСа",.t.)
GaugeDisplay( hGauge )
curr := 0
R_Use(dir_server+"s_kemvyd",,"VID")
R_Use(exe_dir+"_mo_smo",cur_dir+"_mo_smo2","SMO")
//index on smo to (cur_dir+sbase+'2')
//G_Use(dir_server+"mo_krtr",,"KRTR")
//index on str(kod,6) to (cur_dir+"tmp_krtr")
//G_Use(dir_server+"mo_krtf",,"KRTF")
//index on str(kod,6) to (cur_dir+"tmp_krtf")
//G_Use(dir_server+"mo_krtp",,"KRTP")
//index on str(reestr,6) to (cur_dir+"tmp_k")
//R_Use(dir_server+"mo_kfio",cur_dir+"tmp_kfio","KFIO")
R_Use_base("kartotek")
set order to 0
go top
do while  !eof()
  GaugeUpdate( hGauge, ++curr/lastrec() )
  if kart->kod > 0
    fl := .t.
    if empty(kart->date_r)
      fl := .f. // не заполнено поле "Дата рождения"
    elseif kart->date_r >= sys_date
      fl := .f. // дата рождения больше сегодняшней даты
    elseif year(kart->date_r) < 1900
      fl := .f. // дата рождения < 1900г.
    endif
    //a1[i] := hb_AnsiToOem(arr_pac[i])
    //a2[i] := hb_OemToAnsi(a1[i])
    if fl
      select BARS
      append blank
      bars->C_NAME       := hb_OemToAnsi("Пациенты")
      bars->CARD_NUMB    := lstr(kart->kod)
      arr_fio := retFamImOt(1,.f.,.F.)
      bars->SURNAME      := hb_OemToAnsi(arr_fio[1])
      bars->FIRSTNAME    := hb_OemToAnsi(arr_fio[2])
      bars->LASTNAME     := hb_OemToAnsi(arr_fio[3])
      bars->BIRTHDATE    := kart->DATE_R
      bars->SEX          := hb_OemToAnsi(iif(kart->pol=="М","Мужской","Женский"))
      bars->SNILS        := kart->snils
      bars->OMS_TYPE     := lstr(kart_->vpolis)
      bars->OMS_SER      := kart_->spolis
      bars->OMS_NUM      := kart_->npolis
      select SMO
      find (kart_->smo)
      if found()
        bars->OMS_AGCODE := hb_OemToAnsi(smo->name)   // наименование страховой
      endif
      bars->OMS_WHEN     := date()
      bars->OMS_BEGIN    := date()
      bars->OMS_END      := c4tod(kart->srok_polis)
     // bars->DMS_TYPE",   "C",      1,      0},;
     // bars->DMS_SER",    "C",     60,      0},;
     // bars->DMS_NUM",    "C",     60,      0},;
     // bars->DMS_AGCODE", "C",    250,      0},;
     // bars->DMS_WHEN",   "D",      8,      0},;
     // bars->DMS_BEGIN",  "D",      8,      0},;
     // bars->DMS_END",    "D",      8,      0},;
     // bars->REGLPUCOD",  "C",     20,      0},;
     // bars->SITE_CODE",  "C",     20,      0},;
     // bars->REGPURPCOD", "C",     20,      0},;
     // bars->RS_BEGIN",   "D",      8,      0},;
     // bars->RS_END",     "D",      8,      0},;
     // bars->SOC_STATE",  "C",    250,      0},;
     // bars->SOC_BEGIN",  "D",      8,      0},;
     // bars->SOC_END",    "D",      8,      0},;
      bars->PHONE1       := kart_->phone_h
      bars->PHONE2       := kart_->phone_m
     // bars->EMAIL",      "C",     60,      0},;
     // bars->FAX",        "C",     60,      0},;
     // bars->TELEX",      "C",     60,      0},;
      bars->CONT_BEGIN   := date()
     // bars->CONT_END",   "D",      8,      0},;
      bars->IS_MAIN      := "1"

      bars->PD_TYPE      := hb_OemToAnsi(inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud))// тип документа
      bars->PD_SER       := kart_->ser_ud
      bars->PD_NUMB      := kart_->nom_ud
      bars->PD_WHEN      := kart_->kogdavyd
      select VID
      goto (kart_->kemvyd)
      bars->PD_WHO       := hb_OemToAnsi(vid->name)
     //bars->CITIZEN",    "C",    250,      0},;
      bars->PD_BEGIN     := date()
     //bars->PD_END",     "D",      8,      0},;
     // bars->KLADR_CODE", "C",     20,      0},;
      tt := ret_okato_Array(kart_->okatog,.T.)
      bars->RAION        := hb_OemToAnsi(tt[2])
      bars->CITY         := hb_OemToAnsi(tt[3])
     // bars->STREET",     "C",     60,      0},;
     // bars->HOUSE",      "C",     11,      0},;
     // bars->HOUSELIT",   "C",      1,      0},;
     // bars->BLOCK",      "N",      5,      0},;
     // bars->FLAT",       "N",      5,      0},;
     //bars->FLATLIT",    "C",      1,      0},;
     //bars->ADDR_INDEX", "C",     10,      0},;
      bars->ADDR_BEGIN   := date()
     // bars->ADDR_END",   "D",      8,      0},;
      bars->MANUAL_INP   := hb_OemToAnsi(kart->adres)
     // bars->MARITAL",    "C",     60,      0},;
     // bars->MAR_BEGIN",  "D",      8,      0},;
     // bars->MAR_END",    "D",      8,      0},;
      bars->ADDR_MAIN       := iif(kart->rab_nerab==0,lstr(1),"")
     // bars->WORK_PLACE", "C",     40,      0},;
     // bars->WORK_OKVED", "C",    250,      0},;
     // bars->WORK_RAION", "C",    250,      0},;
     // bars->WORK_DEP",   "C",    250,      0},;
     // bars->JOBTITLE",   "C",    250,      0},;
      if kart->rab_nerab==0
        bars->WORK_HAND    := hb_OemToAnsi(kart->mr_dol)
        bars->WORK_BEGIN   := date()
      endif
     // bars->WORK_END",   "D",      8,      0},;
     // bars->CATEGORY",   "C",    250,      0},;
     // bars->CAT_SER",    "C",     60,      0},;
     // bars->CAT_NUM",    "C",     60,      0},;
     // bars->AC_DATE",    "D",      8,      0},;
     // bars->CAT_BEGIN",  "D",      8,      0},;
     // bars->CAT_END",    "D",      8,      0},;
     // bars->INAB_NUM",   "C",     60,      0},;
     // bars->INAB_TYPE",  "C",     60,      0},;
     // bars->INAB_GRADE", "C",     60,      0},;
     // bars->INAB_GROUP", "C",     60,      0},;
     // bars->DISAB_GRAD", "C",     60,      0},;
     // bars->INAB_BEGIN", "D",      8,      0},;
     // bars->INAB_END",   "D",      8,      0},;
     // bars->DEATHDATE",  "D",      8,      0},;
     // bars->DEATHTIME",  "C",      5,      0},;
     // bars->DEATH_DOC",  "C",     60,      0},;
     // bars->DEATH_NUM",  "C",     60,      0},;
     // bars->DEATH_DATE", "D",      8,      0},;
     // bars->PRIMECH",    "C",    250,      0},;
     // bars->REGTYPECOD", "C",     30,      0},;
     // bars->REGCATCOD",  "C",     20,      0},;
     // bars->REGDOCNUMB", "C",     15,      0},;
     // bars->F_KLADR",    "C",     20,      0},;
     // bars->F_RAION",    "C",    250,      0},;
     // bars->F_CITY",     "C",    250,      0},;
     // bars->F_STREET",   "C",     60,      0},;
     // bars->F_HOUSE",    "C",     11,      0},;
     // bars->F_HOUSELIT", "C",      1,      0},;
     // bars->F_BLOCK",    "N",      5,      0},;
     // bars->F_FLAT",     "N",      5,      0},;
     // bars->F_FLATLIT",  "C",      1,      0},;
     // bars->F_INDEX",    "C",     10,      0},;
     // bars->F_BEGIN",    "D",      8,      0},;
     // bars->F_END",      "D",      8,      0},;
     // bars->F_MANL_INP", "C",    250,      0};
      if bars->(recno()) % 100 == 0
        @ maxrow(),1 say lstr(bars->(recno())) color color0
        if bars->(recno()) % 2000 == 0
          Commit
        endif
      endif
    endif
  endif
  select KART
  skip
enddo
close databases
CloseGauge(hGauge)
n_message({"в каталоге "+upper(cur_dir)+" создан файл "+upper("bars"+sdbf),;
           "для загрузки в систему БАРС."},,;
           cColorStMsg,cColorStMsg,,,cColorSt2Msg)
return NIL

***** 14.07.19 создать файл счетов в Облздрав
Function create_schets_OBLSDRAV()
Local arr_f, ar, hZip, i, cPassword, fl := .t., hGauge, s, y, cFile, buf := savescreen()
f_message({"Ждите! Создаётся архив счетов",;
           "за отчётный период январь 2018 - июнь 2019 года.",;
           "",;
           "Ни в коем случае не прерывайте процесс",;
           "во избежание нежелательных последствий!"},,"GR+/R","W+/R",12)
zip_file := "СОМП_"+alltrim(glob_mo[_MO_SHORT_NAME])
zip_file := charrem('№",',zip_file)
zip_file := charone(" ",zip_file)
zip_file := charrepl(" ",zip_file,"_")
zip_file := charrepl(".",zip_file,"_")
zip_file := charrepl("-",zip_file,"_")
zip_file += szip
arr_f := {}
G_Use(dir_server+"schet_",,"SCHET_")
index on dtos(schet_->dschet) to (cur_dir+"tmp_sch") ;
      for schet_->nyear == 2018 .or. (schet_->nyear == 2019 .and. between(schet_->nmonth,1,6))
go top
do while !eof()
  cFile := dir_server+dir_XML_MO+cslash+alltrim(schet_->name_xml)+szip
  if hb_FileExists(cFile)
    aadd(arr_f,cFile)
  endif
  skip
enddo
close databases
my_debug(,zip_file)
delete file (zip_file)
if len(arr_f) == 0
  fl := func_error(4,"Не обнаружено файлов счетов для архивирования.")
elseif !empty(hZip := HB_ZIPOPEN(hb_OemtoAnsi(zip_file)))
  Private p_var_manager := "m_copy_DB"
  hGauge := GaugeNew(,,{"B/BG*","B/BG*","B/BG*"},"Создание архива счетов",.t.)
  GaugeDisplay( hGauge )
  for i := 1 To Len(arr_f)
    cFile := StripPath(arr_f[i])  // имя файла без пути
    GaugeUpdate( hGauge, i/Len(arr_f) )
    stat_msg("Добавление в архив файла "+cFile)
    HB_ZipStoreFile( hZip, arr_f[i], cFile)//, cPassword )
  next
  CloseGauge(hGauge) // Закроем окно отображения
  HB_ZIPCLOSE( hZip )
else
  fl := func_error(4,"Возникла ошибка при архивировании базы данных.")
endif
restscreen(buf)
if fl
  s := manager(T_ROW,T_COL+5,maxrow()-2,,.f.,2) // "norton" для выбора каталога
  if !empty(s)
    mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
    delete file (s+zip_file)
    copy file (zip_file) to (s+zip_file)
    if hb_fileExists(s+zip_file)
      stat_msg("Файл "+s+zip_file+" успешно записан!")
    else
      stat_msg("Ошибка записи файла "+s+zip_file+"!")
    endif
    mybell(2,OK)
  endif
endif
delete file (zip_file)
restscreen(buf)
return NIL

***** 16.11.18 создать файл приписного населения в Облздрав
Function pripisnoe_naselenie_create_OBLSDRAV()
Local buf := savescreen(),  arr_fio, pr_date, name_file, name_zip
Local mo_bars :=  {;
   {"UCHAST",     "C",     20,      0},; //У
   {"FAM",        "C",     40,      0},; //Да
   {"NAME",       "C",     40,      0},; //Да
   {"OTCH",       "C",     40,      0},; //Да
   {"POL",        "N",      1,      0},; //Да
   {"DATE_R",     "D",      8,      0},; //Да
   {"MESTO_R",    "C",    100,      0},; //У
   {"OKATOP",     "C",     11,      0},; //Да
   {"ADRESP",     "C",    120,      0},; //Да
   {"RABOTA",     "N",      1,      0},; //У
   {"BEG_POLIS",  "D",      8,      0},; //У
   {"END_POLIS",  "D",      8,      0},; //У
   {"VPOLIS",     "N",      1,      0},; //У
   {"POLIS",      "C",     16,      0},; //У
   {"KOD_SMO",    "C",      5,      0},; //У
   {"SMO",        "C",    250,      0},; //У
   {"SNILS",      "C",     14,      0},; //У XXX-XXX-XXX XX
   {"VID_UD",     "C",      2,      0},; //У
   {"SER_UD",     "C",     10,      0},; //У
   {"NOM_UD",     "C",     20,      0},; //У
   {"KEMVYD",     "C",     80,      0},; //У
   {"KOGDAVYD",   "D",      8,      0},; //У
   {"MO_PR",      "C",      6,      0},; //Да
   {"DATE_PR",    "D",      8,      0},; //Да
   {"SNILS_VR",   "C",     14,      0}; //У XXX-XXX-XXX XX
  }
if !f_Esc_Enter("создания файла для ВОМИАЦ",.t.)
  return NIL
endif
ClrLine(maxrow(),color0)
dbcreate(cur_dir+"tmpbars",mo_bars)
use (cur_dir+"tmpbars") new alias BARS
hGauge := GaugeNew(,,,"Составление файла для ВОМИАЦ",.t.)
GaugeDisplay( hGauge )
curr := 0
R_Use(dir_server+"s_kemvyd",,"VID")
R_Use(exe_dir+"_mo_smo",cur_dir+"_mo_smo2","SMO")
//index on smo to (cur_dir+sbase+'2')
//G_Use(dir_server+"mo_krtr",,"KRTR")
//index on str(kod,6) to (cur_dir+"tmp_krtr")
//G_Use(dir_server+"mo_krtf",,"KRTF")
//index on str(kod,6) to (cur_dir+"tmp_krtf")
//G_Use(dir_server+"mo_krtp",,"KRTP")
//index on str(reestr,6) to (cur_dir+"tmp_k")
//R_Use(dir_server+"mo_kfio",cur_dir+"tmp_kfio","KFIO")
R_Use_base("kartotek")
set order to 0
go top
do while  !eof()
  GaugeUpdate( hGauge, ++curr/lastrec() )
  if kart->kod > 0 .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
    //a1[i] := hb_AnsiToOem(arr_pac[i])
    //a2[i] := hb_OemToAnsi(a1[i])
    select BARS
    append blank
    bars->UCHAST       :=  lstr(kart->uchast)       //У
    arr_fio := retFamImOt(1,.f.,.F.)
    bars->FAM          := arr_fio[1]                //Да
    bars->NAME         := arr_fio[2]                //Да
    bars->OTCH         := arr_fio[3]                //Да
    bars->POL          := iif(kart->pol == "М",1,2)   //Да
    bars->DATE_R       := kart->DATE_R              //Да
    bars->MESTO_R      := kart_->mesto_r            //У
    if len(alltrim(kart_->okatop)) > 1
      bars->OKATOP     := kart_->okatop             //Да
      bars->ADRESP     := kart_->adresp             //Да
    else
      bars->OKATOP     := kart_->okatog             //Да
      bars->ADRESP     := kart->adres               //Да
    endif
    bars->RABOTA       := iif(kart->rab_nerab == 0,1,0)//У
    //bars->BEG_POLIS",  "D",      8,      0},; //У
    bars->END_POLIS    := c4tod(kart->srok_polis)   //У
    // 1 старый 2 - врем 3 новый == 1 новый 2 врем 3 старый
    if kart_->vpolis == 2
      bars->VPOLIS     := 2                       //У
    elseif kart_->vpolis == 1
      bars->VPOLIS     := 3                       //У
    else
      bars->VPOLIS     := 1                       //У
    endif
    bars->POLIS        := kart->polis               //У
    bars->KOD_SMO      := kart_->smo                //У
    select SMO
    find (kart_->smo)
    if found()
      bars->SMO        := smo->name                 //У
    endif
    bars->SNILS        := transform(kart->snils,picture_pf) //У XXX-XXX-XXX XX
    bars->VID_UD       := lstr(kart_->vid_ud)       //У
    bars->SER_UD       := kart_->ser_ud             //У
    bars->NOM_UD       := kart_->nom_ud             //У
    select VID
    goto (kart_->kemvyd)
    bars->KEMVYD       := vid->name                 //У
    bars->KOGDAVYD     := kart_->kogdavyd           //У
    bars->MO_PR        := glob_MO[_MO_KOD_TFOMS]    //Да
    pr_date := date()
    if !empty(kart2->pc4)
      pr_date := ctod(alltrim(left(kart2->pc4,6)+"20"+substr(kart2->pc4,7)))
    elseif !empty(kart2->DATE_PR)
      pr_date := kart2->DATE_PR
    endif
    bars->DATE_PR      := pr_date            //Да
    if !empty(kart2->snils_vr)
      bars->SNILS_VR     := transform(kart2->snils_vr,picture_pf) //У XXX-XXX-XXX XX
    endif
    if bars->(recno()) % 100 == 0
      @ maxrow(),1 say lstr(bars->(recno())) color color0
      if bars->(recno()) % 2000 == 0
        Commit
      endif
    endif
  endif
  select KART
  skip
enddo
close databases
CloseGauge(hGauge)
//
name_file := alltrim("ZLERPN2"+glob_MO[_MO_KOD_TFOMS]+dtos(date()))
name_zip := name_file+szip
copy file (cur_dir+"tmpbars"+sdbf) to (cur_dir+name_file+sdbf)
//
if hb_FileExists(name_file+sdbf)
  if chip_create_zipXML(name_zip,{name_file+sdbf},.t.)
    copy file (dir_server+dir_XML_MO+cslash+name_zip) to (cur_dir+name_zip)
    n_message({"В каталоге "+cur_dir+" создан файл "+upper(name_zip),;
               "c прикрепленным населением для отправки в ВОМИАЦ."},,;
               cColorSt2Msg,cColorStMsg,,,"G+/R")
    delete file (dir_server+dir_XML_MO+cslash+name_zip)
  endif
else
  func_error(4,"Ошибка создания файла "+name_file)
endif
return NIL

***** Общие настройки каждой задачи
Function nastr_all(k,nTask)
Static sk := 1, mas_pmt
Local str_sem, mas_msg, mas_fun, j, n
DEFAULT k TO 0
do case
  case k == 0
    if tip_polzovat != 0
      return func_error(4,err_admin)
    endif
    mas_pmt := {"Общие настройки"}
    mas_msg := {"Общие настройки работы с программой"}
    mas_fun := {"nastr_all(1,0)"}
    n := 1
    if is_task(X_PPOKOJ)
      ++n
      aadd(mas_pmt,array_tasks[ind_task(X_PPOKOJ),1])
      aadd(mas_msg,'Общие настройки задачи "'+array_tasks[ind_task(X_PPOKOJ),1]+'"')
      aadd(mas_fun,'nastr_all('+lstr(n)+','+lstr(X_PPOKOJ)+')')
    endif
    if is_task(X_PLATN) .or. is_task(X_KASSA)
      ++n
      aadd(mas_pmt,array_tasks[ind_task(X_PLATN),1])
      aadd(mas_msg,'Общие настройки задачи "'+array_tasks[ind_task(X_PLATN),1]+'"')
      aadd(mas_fun,'nastr_all('+lstr(n)+','+lstr(X_PLATN)+')')
    endif
    if is_task(X_ORTO)
      ++n
      aadd(mas_pmt,array_tasks[ind_task(X_ORTO),1])
      aadd(mas_msg,'Общие настройки задачи "'+array_tasks[ind_task(X_ORTO),1]+'"')
      aadd(mas_fun,'nastr_all('+lstr(n)+','+lstr(X_ORTO)+')')
    endif
    if n == 1
      j := &(mas_fun[1])
    elseif n > 1
      popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
    endif
  case k > 0
    f1nastr_all(mas_pmt[k],nTask)
endcase
if k > 0
  sk := k
endif
return NIL

*

***** 09.12.18 Общие настройки каждой задачи
Function f1nastr_all(nameTask,nTask)
Local mm_tmp := {}, ctitle
Local str_sem := "Редактирование общих настроек задачи "+lstr(nTask)
if G_SLock(str_sem)
  Private mm_uchastok := {{'Не работаем с участком',0},;
                          {'буква + № участка + № в участке "У25/123"',1},;
                          {'буква + № участка + код пациента "У25/456789"',2},;
                          {'буква + № участка + номер АК МИС "У25/765432"',3}}
  Private mm_oplata := {{"в зависимости от цены услуги (!рекомендуется!)",5},;
                        {"в зависимости от стоимости УЕТ",                6},;
                        {"% от услуги + зависимость от стоимости УЕТ",    7}}
  Private mm_h_otd := {{"с выбором отделения",1},;
                       {"без выбора отделения",2}}
  Private mm_close := {{"платные, ДМС и в/зачет вручную",1},;
                       {"платные и в/зачет вручную, ДМС по оплате",0}}
  Private mm_many_uch := {{"из списка отделений выбранного учреждения",1},;
                          {"из списка отделений всех доступных учреждений",2}}
  Private mm_num_lu := {{"не работаем с номерами листов учета",0},;
                        {"сквозной номер л/у равен номеру записи",1}}
  Private mm_kassa := {{"Нет кассового аппарата",0},;
                       {"Кассовый аппарат: Штрих-ФР-Ф",1}}
  Private mm_pol    := {{'Выбор из меню',1},{'Ввод буквы вручную',2}}
  Private mm_ordusl := {{"По дате",1},{"По шифру услуги",2}}
  Private mm_kodkrt := {{"Не выводить",1},{"Выводить",2}}
  Private mm_otdusl := {{"Ввод отделения вручную",1},;
                        {"Автоматический выбор отделения по месту работы персонала",2}}
  Private mm_stalon := {{'Выбор из меню',1},{'Ввод числового значения',2}}
  Private mm_zav_l  := {{"да",1},{"нет",2},{"запоминать предыдущий",3}}
  Private mm_da_net := {{"нет",1},{"да ",2}}
  Private mm_otdort := {{"Ввод отделения вручную",1},;
                        {"Использовать отделение по УМОЛЧАНИЮ",2}}
  Private mm_ort_f39 := {{"Три диагноза + итого протезов",0},;
                         {"Семь диагнозов + уточнение типов протезов",1}}
  delete file tmp.dbf
  do case
    case nTask == 0 .and. Tools_Ini_OMS(1,0,0,.t.) // настройка на все задачи
      ctitle := "настройке на все задачи"
      aadd(mm_tmp, {"_okato","C",11,0,NIL,;
                    {|x|menu_reader(x,;
                      {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
                    space(11),{|x| ret_okato_ulica('',x)},;
                    'ОКАТО по умолчанию'})
      aadd(mm_tmp, {"a_sound","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    2,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Использовать при работе программы звуковое сопровождение'})
      aadd(mm_tmp, {"a_pol","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_pol,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_pol,x)},;
                    'Каким образом вводится поле "Пол больного"'})
      aadd(mm_tmp, {"a_smp_inp","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Для СМП реквизиты пациента редактируются внутри листа учета?'})
      aadd(mm_tmp, {"a_smp_tel","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'В специализированном листе учёта по СМП вводим услуги телемедицины?'})
      aadd(mm_tmp, {"a_dom_akt","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Работаем с активными посещениями на дому (дом-АКТИВ)?'})
      aadd(mm_tmp, {"a_diagno","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Выводить наименование диагнозов при вводе листа учета?'})
      aadd(mm_tmp, {"a_diag4","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Проверять обязательность ввода четырехзначного диагноза?'})
      if yes_parol
        aadd(mm_tmp, {"a_op_out","N",1,0,NIL,;
                      {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                      1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                      'Выводить Ф.И.О. оператора при записи листа учета?'})
      endif
      aadd(mm_tmp, {"a_ordusl","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_ordusl,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_ordusl,x)},;
                    "Порядок сортировки при редактировании услуг"})
      aadd(mm_tmp, {"a_ordu_1","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    "Включать сортировку при добавлении услуг?"})
      aadd(mm_tmp, {"a_por_vr","N",1,0,NIL,;
                    nil,;
                    0,nil,;
                    'Порядок расположения полей при вводе услуги: "код врача"     '})
      aadd(mm_tmp, {"a_por_ass","N",1,0,NIL,;
                    nil,;
                    0,nil,;
                    '                                             "код ассистента"'})
      aadd(mm_tmp, {"a_por_kol","N",1,0,NIL,;
                    nil,;
                    0,nil,;
                    '                                             "кол-во услуг"  '})
      aadd(mm_tmp, {"a_vv_v_a","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Допускается не вводить и код врача и код ассистента?'})
      aadd(mm_tmp, {"a_pom_va","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Запоминать последние коды врача и ассистента для ввода в след.услуге?'})
      aadd(mm_tmp, {"a_coplec","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    "Копировать лечащего врача в первую услугу?"})
      aadd(mm_tmp, {"a_date_1","D",8,0,NIL,;
                    nil,;
                    ctod(""),nil,;
                    "Допустимая наименьшая дата для ввода информации"})
      aadd(mm_tmp, {"a_date_2","D",8,0,NIL,;
                    nil,;
                    ctod(""),nil,;
                    "Допустимая наибольшая дата для ввода информации"})
      aadd(mm_tmp, {"a_kodkrt","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_kodkrt,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_kodkrt,x)},;
                    "Выводить ли в меню код больного по картотеке?"})
      aadd(mm_tmp, {"a_trudoem","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    "Работать ли с коэффициентом трудоемкости услуги (УЕТ)?"})
      aadd(mm_tmp, {"a_tr_plan","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    "Подсчитывать процент выполнения плана по УЕТ?"})
      aadd(mm_tmp, {"a_kodotd","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    "Работать ли с кодами отделений?"})
      aadd(mm_tmp, {"e_2","C",1,0,NIL,;
                    nil,;
                    " ",nil,;
                    "Ввод поля ОТДЕЛЕНИЕ, ГДЕ ОКАЗАНА УСЛУГА при вводе услуг",,{||.f.}})
      aadd(mm_tmp, {"a_otdusl","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_otdusl,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_otdusl,x)},;
                    "  для больного"})
      aadd(mm_tmp, {"e_15","C",1,0,NIL,;
                    nil,;
                    " ",nil,;
                    "Проверять при вводе услуг врача(ассистента) на соответствие категории",,{||.f.}})
      aadd(mm_tmp, {"a_kat_va","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    "  врач(ср.мед.персонал) по штатному расписанию?"})
      aadd(mm_tmp, {"schet_nul","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Разрешается выписывать счета с нулевой суммой (по параклинике):'})
      aadd(mm_tmp, {"kart_error","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Разрешается администратору устанавливать статус карточки пациента:'})
      aadd(mm_tmp, {"uchastok","N",1,0,,;
                    {|x|menu_reader(x,mm_uchastok,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_uchastok,x)},;
                    'Работа с УЧАСТКАМИ:'})
      aadd(mm_tmp, {"a_edit_ist","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Разрешается редактировать поле "№ амб.карты (истории болезни)"?'})
      aadd(mm_tmp, {"a_e_istbol","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Редактировать номер истории болезни, присвоенный в задаче "Приёмный покой"'})
      aadd(mm_tmp, {"is_zf","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Работа с зубной формулой:'})
      aadd(mm_tmp, {"bukva","C",20,0,"@!",;
                    NIL,;
                    "",NIL,;
                    'Разрешённые БУКВЫ в поле "Стоматологический статус":'})
      aadd(mm_tmp, {"oplata","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_oplata,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_oplata,x)},;
                    'Режим ОПЛАТЫ по труду:'})
      aadd(mm_tmp, {"h_otd","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_h_otd,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_h_otd,x)},;
                    'Режим редактирования листа учета:'})
      aadd(mm_tmp, {"standart","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Работа с режимом НЕЗАВЕРШЕННОГО лечения:'})
      aadd(mm_tmp, {"v_zav_l","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_zav_l,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_zav_l,x)},;
                    '- вид поля "Лечение завершено" по умолчанию:'})
      aadd(mm_tmp, {"e_1","C",1,0,NIL,;
                    NIL,;
                    "",NIL,;
                    'При вводе оказанных услуг из какого СПИСКА выбирается',,;
                    {||.f.} })
      aadd(mm_tmp, {"many_uch","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_many_uch,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_many_uch,x)},;
                    ' отделение:'})
      aadd(mm_tmp, {"e_2","C",1,0,NIL,;
                    NIL,;
                    "",NIL,;
                    'При добавлении листа учета необходимо запоминать ПОРЯДКОВЫЙ НОМЕР последнего',,;
                    {||.f.} })
      aadd(mm_tmp, {"num_lu","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_num_lu,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_num_lu,x)},;
                    ' листа учета:'})
      aadd(mm_tmp, {"st_kat","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_stalon,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_stalon,x)},;
                    'Каким образом вводится поле "Категория"'})
      aadd(mm_tmp, {"st_pov","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_stalon,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_stalon,x)},;
                    'Каким образом вводится поле "Повод обращения"'})
      aadd(mm_tmp, {"st_trav","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_stalon,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_stalon,x)},;
                    'Каким образом вводится поле "Вид травмы"'})
      aadd(mm_tmp, {"ls_parakl","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Включать ПАРАКЛИНИКУ в сумму ЛИЧНОГО СЧЁТА:'})
      aadd(mm_tmp, {"path_rab","C",70,0,NIL,;
                    NIL,;
                    "",NIL,;
                    'Рабочий каталог:',,;
                    {||.f.} })
      aadd(mm_tmp, {"path_exe","C",70,0,NIL,;
                    NIL,;
                    "",NIL,;
                    'Каталог запуска задачи:',,;
                    {||.f.} })
      aadd(mm_tmp, {"path_dbf","C",70,0,NIL,;
                    NIL,;
                    "",NIL,;
                    'Каталог баз данных:',,;
                    {||.f.} })
      aadd(mm_tmp, {"beg_rees","N",6,0,NIL,;
                    nil,;
                    1,nil,;
                    "Допустимый наименьший номер реестра случаев",;
                    {|| mbeg_rees > 0 .and. mbeg_rees < mend_rees}})
      aadd(mm_tmp, {"end_rees","N",6,0,NIL,;
                    nil,;
                    999999,nil,;
                    "Допустимый наибольший номер реестра случаев",;
                    {|| mend_rees > 0 .and. mbeg_rees < mend_rees}})
      aadd(mm_tmp, {"bnn_rees","N",3,0,NIL,;
                    nil,;
                    1,nil,;
                    "Допустимый наименьший порядковый номер пакета в ТФОМС",;
                    {|| mbnn_rees > 0 .and. mbnn_rees < menn_rees}})
      aadd(mm_tmp, {"enn_rees","N",3,0,NIL,;
                    nil,;
                    999,nil,;
                    "Допустимый наибольший порядковый номер пакета в ТФОМС",;
                    {|| menn_rees > 0 .and. mbnn_rees < menn_rees}})
      aadd(mm_tmp, {"date_edit","D",8,0,NIL,;
                    NIL,;
                    ctod(""),NIL,;
                    "По какую дату (включительно) разрешается редактировать информацию"})
      init_base(cur_dir+"tmp",,mm_tmp,0)
      f_mb_me_nsh(2013)
      use (cur_dir+"tmp") new
      append blank
      tmp->_okato    := okato_umolch
      tmp->a_smp_inp := mem_smp_input
      tmp->a_smp_tel := mem_smp_tel
      tmp->a_dom_akt := mem_dom_aktiv
      tmp->standart  := iif(yes_vypisan==B_END, 2, 1) //
      tmp->many_uch  := iif(yes_many_uch, 2, 1)
      tmp->schet_nul := is_0_schet
      tmp->kart_error:= mem_kart_error
      tmp->uchastok  := is_uchastok
      tmp->a_edit_ist:= mem_edit_ist
      tmp->a_e_istbol:= mem_e_istbol
      tmp->bukva     := yes_d_plus
      tmp->oplata    := is_oplata
      tmp->h_otd     := yes_h_otd
      tmp->standart  := iif(yes_vypisan==B_END, 2, 1)
      tmp->many_uch  := iif(yes_many_uch, 2, 1)
      tmp->num_lu    := yes_num_lu
      tmp->is_zf     := is_zf_stomat  //
      tmp->a_sound   := mem_sound     //
      tmp->a_pol     := mem_pol       //
      tmp->a_diagno  := mem_diagno    //
      tmp->a_diag4   := mem_diag4     //
      tmp->a_pom_va  := mem_pom_va    //
      tmp->a_coplec  := mem_coplec    //
      if yes_parol
        tmp->a_op_out  := mem_op_out  //
      endif
      tmp->a_ordusl  := mem_ordusl    //
      tmp->a_ordu_1  := mem_ordu_1    //
      tmp->a_kodkrt  := mem_kodkrt    //
      tmp->a_trudoem := mem_trudoem   //
      tmp->a_tr_plan := mem_tr_plan   //
      tmp->a_kodotd  := mem_kodotd    //
      tmp->a_otdusl  := mem_otdusl    //
      tmp->a_kat_va  := mem_kat_va    //
      tmp->a_por_vr  := mem_por_vr    //
      tmp->a_por_ass := mem_por_ass   //
      tmp->a_por_kol := mem_por_kol   //
      tmp->a_vv_v_a  := mem_vv_v_a    //
      tmp->a_date_1  := mem_date_1    //
      tmp->a_date_2  := mem_date_2    //
      tmp->st_kat    := mem_st_kat    //
      tmp->st_pov    := mem_st_pov    //
      tmp->st_trav   := mem_st_trav   //
      tmp->v_zav_l   := mem_zav_l     //
      tmp->ls_parakl := mem_ls_parakl     //
      tmp->path_rab  := cur_dir
      tmp->path_exe  := dir_exe
      tmp->path_dbf  := upper(dir_server)
      tmp->beg_rees  := mem_beg_rees
      tmp->end_rees  := mem_end_rees
      tmp->bnn_rees  := mem_bnn13rees
      tmp->enn_rees  := mem_enn13rees
      tmp->date_edit := public_date        //
      close databases
    case nTask == X_PPOKOJ //  Приёмный покой
      ctitle := "настройке приёмного покоя"
      _pp_nastr(0) // проверить, а создан ли файл "pp_nastr.dbf"
      aadd(mm_tmp, {"ist_bol","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Вести сквозную нумерацию истории болезни'})
      aadd(mm_tmp, {"n_ist_bol","N",6,0,NIL,;
                    NIL,;
                    0,NIL,;
                    "Номер последней введенной истории болезни"})
      aadd(mm_tmp, {"file_6","C",8,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Имя файла шаблона согласия на обр-ку перс.данных (по <F6>)"})
      aadd(mm_tmp, {"file_7","C",12,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Имя файла шаблона листа учета................... (по <F7>)"})
      aadd(mm_tmp, {"file_8","C",12,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Имя файла шаблона истории болезни............... (по <F8>)"})
      aadd(mm_tmp, {"file_9","C",12,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Имя файла шаблона стат.карты (форма 066)........ (по <F9>)"})
      aadd(mm_tmp, {"file_12","C",12,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Наименование файла шаблона индивидуальной карты (по <F12>)"})
      aadd(mm_tmp, {"file_xx","C",3,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Расширение прочих файлов шаблонов организации... (по <F5>)"})
      init_base(cur_dir+"tmp",,mm_tmp,0)
      R_Use(dir_server+"pp_nastr",,"MV")
      use (cur_dir+"tmp") new
      append blank
      tmp->IST_BOL   := mv->IST_BOL
      tmp->N_IST_BOL := mv->N_IST_BOL
      tmp->FILE_6    := mv->FILE_6
      tmp->FILE_7    := mv->FILE_7
      tmp->FILE_8    := mv->FILE_8
      tmp->FILE_9    := mv->FILE_9
      tmp->FILE_12   := mv->FILE_12
      tmp->FILE_XX   := mv->FILE_XX
      close databases
    case nTask == X_PLATN .and. Tools_Ini_Platn(1,0,0,.t.) //  Платные услуги
      ctitle := "настройке платных услуг"
      aadd(mm_tmp, {"anonim","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Разрешается работать с АНОНИМами?'})
      aadd(mm_tmp, {"a_naprvr","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Работать с кодом направившего врача?'})
      aadd(mm_tmp, {"a_plsoput","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Работать с сопутствующими заболеваниями?'})
      aadd(mm_tmp, {"a_edit_s","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Редактировать поле "Стоимость услуги"?'})
      aadd(mm_tmp, {"a_dogovor","C",12,0,"@!",;
                    nil,;
                    space(12),nil,;
                    'Файл шаблона договора на платные услуги'})
      aadd(mm_tmp, {"a_proc_ms","N",5,2,NIL,;
                    nil,;
                    0,nil,;
                    "Процент оплаты МЕДСЕСТРАМ (от ст-ти услуги)"})
      aadd(mm_tmp, {"a_proc_sn","N",5,2,NIL,;
                    nil,;
                    0,nil,;
                    "Процент оплаты САНИТАРКАМ (от ст-ти услуги)"})
      aadd(mm_tmp, {"a_mfile8","C",12,0,"@!",;
                    nil,;
                    space(12),nil,;
                    'Наименование файла шаблона индивидуальной карты (по <F8>)'})
      aadd(mm_tmp, {"pl_reg","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                    'Вводим квитанционную книжку:'})
      aadd(mm_tmp, {"a_close","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_close,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_close,x)},;
                    'Закрытие листа учета:'})
      aadd(mm_tmp, {"kassa","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_kassa,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_kassa,x)},;
                    'Работа через кассовый аппарат:'})
      init_base(cur_dir+"tmp",,mm_tmp,0)
      use (cur_dir+"tmp") new
      append blank
      tmp->anonim    := mem_anonim
      tmp->a_edit_s  := mem_edit_s
      tmp->a_naprvr  := mem_naprvr
      tmp->a_plsoput := mem_plsoput
      tmp->a_dogovor := mem_dogovor
      tmp->a_proc_ms := mem_pl_ms
      tmp->a_proc_sn := mem_pl_sn
      tmp->a_mfile8  := mem_ort_f8
      tmp->a_close   := glob_close
      tmp->pl_reg    := glob_pl_reg
      tmp->kassa     := glob_kassa
      close databases
    case nTask == X_ORTO .and. Tools_Ini_Orto(1,0,0,.t.) // Ортопедические услуги в стоматологии
      ctitle := "настройке ортопедии"
      aadd(mm_tmp, {"ort_f39","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_ort_f39,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_ort_f39,x)},;
                    'Кол-во заполняемых полей'})
      aadd(mm_tmp, {"a_orto_na","C",10,0,NIL,;
                    nil,;
                    space(10),nil,;
                    'Шаблон для услуг "НАПЫЛЕНИЕ"'})
      aadd(mm_tmp, {"a_orto_sl","C",10,0,NIL,;
                    nil,;
                    space(10),nil,;
                    'Шаблон для услуг "СЛЕПКИ"'})
      aadd(mm_tmp, {"a_orto_ysl","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Разрешается добавлять услуги в режиме "Открытие наряда"?'})
      aadd(mm_tmp, {"a_ortootd","N",3,0,NIL,;
                    {|x|menu_reader(x,{dir_server+"mo_otd",,},A__POPUPEDIT)},;
                    0,{|x|inieditspr(A__POPUPEDIT,dir_server+"mo_otd",x)},;
                    'Отделение по умолчанию при вводе услуг'})
      aadd(mm_tmp, {"e_12","C",1,0,NIL,;
                    nil,;
                    " ",nil,;
                    'Каким образом вводится поле "ОТДЕЛЕНИЕ, ГДЕ ОКАЗАНА УСЛУГА"',,{||.f.}})
      aadd(mm_tmp, {"a_ort1otd","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_otdort,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_otdort,x)},;
                    ' при вводе услуг'})
      aadd(mm_tmp, {"a_edit_s","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Редактировать поле "Стоимость услуги"?'})
      aadd(mm_tmp, {"a_orto_ms","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Необходим ввод медсестры в ортопедических услугах?'})
      aadd(mm_tmp, {"a_orto_pl","C",12,0,"@!",;
                    nil,;
                    space(12),nil,;
                    'Наименование файла шаблона для платного наряда-заказа'})
      aadd(mm_tmp, {"a_orto_bp","C",12,0,"@!",;
                    nil,;
                    space(12),nil,;
                    'Наименование файла шаблона для бесплатного наряда-заказа'})
      aadd(mm_tmp, {"a_orto_dog","C",3,0,"@!",; //16.04.08
                    nil,;
                    space(12),nil,;
                    'Расширение файлов-шаблонов для печати договоров'})
      aadd(mm_tmp, {"a_orto_dat","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                    'Дата открытия наряда равна дате начала лечения ?'})
      aadd(mm_tmp, {"a_mfile8","C",12,0,"@!",;
                    nil,;
                    space(12),nil,;
                    'Наименование файла шаблона индивидуальной карты (по <F8>)'})
      aadd(mm_tmp, {"kassa","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_kassa,A__MENUVERT)},;
                    0,{|x|inieditspr(A__MENUVERT,mm_kassa,x)},;
                    'Работа через кассовый аппарат:'})
      init_base(cur_dir+"tmp",,mm_tmp,0)
      use (cur_dir+"tmp") new
      append blank
      tmp->ort_f39    := mem_ort_f39
      tmp->a_edit_s   := mem_edit_s
      tmp->a_orto_na  := mem_ort_na
      tmp->a_orto_sl  := mem_ort_sl
      tmp->a_orto_ysl := mem_ort_ysl
      tmp->a_ortootd  := mem_ortotd
      tmp->a_ort1otd  := mem_ortot1
      tmp->a_orto_ms  := mem_ort_ms
      tmp->a_orto_bp  := mem_ort_bp
      tmp->a_orto_pl  := mem_ort_pl
      tmp->a_orto_dat := mem_ort_dat
      tmp->a_orto_dog := mem_ort_dog //16.04.08
      tmp->a_mfile8   := mem_ort_f8
      tmp->kassa      := glob_kassa
      close databases
  endcase
  if f_edit_spr(A__EDIT,mm_tmp,ctitle,"g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
    use (cur_dir+"tmp") new
    do case
      case nTask == 0
        mem_smp_input:= tmp->a_smp_inp
        mem_smp_tel  := tmp->a_smp_tel
        mem_dom_aktiv:= tmp->a_dom_akt
        okato_umolch := tmp->_okato
        is_0_schet   := tmp->schet_nul
        is_uchastok  := tmp->uchastok
        mem_kart_error := tmp->kart_error
        mem_edit_ist := tmp->a_edit_ist
        mem_e_istbol := tmp->a_e_istbol
        yes_d_plus   := tmp->bukva
        is_oplata    := tmp->oplata
        yes_h_otd    := tmp->h_otd
        yes_vypisan  := iif(tmp->standart==1,B_STANDART,B_END)
        yes_many_uch := (tmp->many_uch == 2)
        yes_num_lu   := tmp->num_lu
        is_zf_stomat := tmp->is_zf
        mem_sound    := tmp->a_sound
        mem_pol      := tmp->a_pol
        mem_diagno   := tmp->a_diagno
        mem_diag4    := tmp->a_diag4
        mem_pom_va   := tmp->a_pom_va
        mem_coplec   := tmp->a_coplec
        if yes_parol
          mem_op_out := tmp->a_op_out
        endif
        mem_ordusl  := tmp->a_ordusl
        mem_ordu_1  := tmp->a_ordu_1
        mem_kodkrt  := tmp->a_kodkrt
        mem_trudoem := tmp->a_trudoem
        mem_tr_plan := tmp->a_tr_plan
        mem_kodotd  := tmp->a_kodotd
        mem_otdusl  := tmp->a_otdusl
        mem_kat_va  := tmp->a_kat_va
        mem_por_vr  := tmp->a_por_vr
        mem_por_ass := tmp->a_por_ass
        mem_por_kol := tmp->a_por_kol
        mem_vv_v_a  := tmp->a_vv_v_a
        mem_date_1  := tmp->a_date_1
        mem_date_2  := tmp->a_date_2
        mem_st_kat  := tmp->st_kat
        mem_st_pov  := tmp->st_pov
        mem_st_trav := tmp->st_trav
        mem_zav_l   := tmp->v_zav_l
        mem_ls_parakl := tmp->ls_parakl
        mem_beg_rees:= tmp->beg_rees
        mem_end_rees:= tmp->end_rees
        mem_bnn13rees:= tmp->bnn_rees
        mem_enn13rees:= tmp->enn_rees
        public_date := tmp->date_edit
        Tools_Ini_OMS(2,0,0)
      case nTask == X_PPOKOJ //  Приёмный покой
        G_Use(dir_server+"pp_nastr",,"MV")
        G_RLock(forever)
        mv->IST_BOL   := tmp->IST_BOL
        mv->N_IST_BOL := tmp->N_IST_BOL
        mv->FILE_6    := tmp->FILE_6
        mv->FILE_7    := tmp->FILE_7
        mv->FILE_8    := tmp->FILE_8
        mv->FILE_9    := tmp->FILE_9
        mv->FILE_12   := tmp->FILE_12
        mv->FILE_XX   := tmp->FILE_XX
      case nTask == X_PLATN
        mem_anonim  := tmp->anonim
        mem_edit_s  := tmp->a_edit_s
        mem_naprvr  := tmp->a_naprvr
        mem_plsoput := tmp->a_plsoput
        mem_dogovor := tmp->a_dogovor
        mem_pl_ms   := tmp->a_proc_ms
        mem_pl_sn   := tmp->a_proc_sn
        mem_ort_f8  := tmp->a_mfile8
        glob_close  := tmp->a_close
        glob_pl_reg := tmp->pl_reg
        glob_kassa  := tmp->kassa
        Tools_Ini_Platn(2,0,0)
      case nTask == X_ORTO
        mem_edit_s  := tmp->a_edit_s
        mem_ort_na  := tmp->a_orto_na
        mem_ort_sl  := tmp->a_orto_sl
        mem_ort_ysl := tmp->a_orto_ysl
        mem_ortotd  := tmp->a_ortootd
        mem_ortot1  := tmp->a_ort1otd
        mem_ort_ms  := tmp->a_orto_ms
        mem_ort_bp  := tmp->a_orto_bp
        mem_ort_pl  := tmp->a_orto_pl
        mem_ort_dat := tmp->a_orto_dat
        mem_ort_dog := tmp->a_orto_dog
        mem_ort_f8  := tmp->a_mfile8
        mem_ort_f39 := tmp->ort_f39
        glob_kassa  := tmp->kassa
        Tools_Ini_Orto(2,0,0)
    endcase
  endif
  close databases
  G_SUnLock(str_sem)
else
  func_error(4,err_slock)
endif
return NIL

*

***** сделать копию tools.ini с сервера в локальный каталог с именем loctools.ini
Function copy_Tools_Ini()
LOCAL i := 0, fl := .f., bSaveHandler
if !hb_FileExists(tools_ini) // если ни разу не заходили в режим настроек
  return .t.
endif
if (fl := Semaphor_Tools_Ini(1))
  do while ++i < 20
    //
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    //
    BEGIN SEQUENCE
      //if files_time(tools_ini,local_tools_ini)
        delete file (local_tools_ini)
        copy file (tools_ini) to (local_tools_ini)
      //endif
      if hb_FileExists(local_tools_ini)
        fl := .t.
      endif
    RECOVER USING error
      fl := .f.
    END
    //
    ERRORBLOCK(bSaveHandler)
    if fl
      exit
    endif
    millisec(20)
  enddo
  Semaphor_Tools_Ini(2)
endif
return fl

*****
Function Semaphor_Tools_Ini(k)
Static sem_tools := "Semaphor_Tools"
Local i := 0, buf, fl := .t.
if k == 1
  buf := save_maxrow()
  WaitStatus("Чтение/запись программных настроек")
  do while .t.
    UpdateStatus()
    if ++i > 100
      fl := func_error('Не удалось заблокировать семафор "'+sem_tools+'"! Попытайтесь снова.')
      exit
    endif
    if G_SLock(sem_tools)
      exit
    endif
    millisec(10)
  enddo
  rest_box(buf)
else
  G_SUnLock(sem_tools)
endif
return fl

*

***** 09.12.18
Function Tools_Ini_OMS(reg,k1,k2,fll)
Static arr := {{"okato_umolch",  "C"},;
               {"mem_smp_input", "N"},;
               {"mem_smp_tel",   "N"},;
               {"mem_dom_aktiv", "N"},;
               {"mem_kart_error","N"},;
               {"is_0_schet",    "N"},;
               {"is_uchastok",   "N"},;
               {"mem_edit_ist",  "N"},;
               {"mem_e_istbol",  "N"},;
               {"yes_d_plus",    "C"},;
               {"is_oplata",     "N"},;
               {"yes_h_otd",     "N"},;
               {"yes_vypisan",   "N"},;
               {"yes_many_uch",  "L"},;
               {"yes_num_lu",    "N"},;
               {"is_zf_stomat",  "N"},;
               {"mem_sound",     "N"},;
               {"mem_pol",       "N"},;
               {"mem_diagno",    "N"},;
               {"mem_diag4",     "N"},;
               {"mem_pom_va",    "N"},;
               {"mem_coplec",    "N"},;
               {"mem_op_out",    "N"},;
               {"mem_ordusl",    "N"},;
               {"mem_ordu_1",    "N"},;
               {"mem_kodkrt",    "N"},;
               {"mem_trudoem",   "N"},;
               {"mem_tr_plan",   "N"},;
               {"mem_kodotd",    "N"},;
               {"mem_otdusl",    "N"},;
               {"mem_kat_va",    "N"},;
               {"mem_por_vr",    "N"},;
               {"mem_por_ass",   "N"},;
               {"mem_por_kol",   "N"},;
               {"mem_vv_v_a",    "N"},;
               {"mem_date_1",    "D"},;
               {"mem_date_2",    "D"},;
               {"mem_st_kat",    "N"},;
               {"mem_st_pov",    "N"},;
               {"mem_st_trav",   "N"},;
               {"mem_zav_l",     "N"},;
               {"mem_ls_parakl", "N"},;
               {"mem_beg_rees",  "N"},;
               {"mem_end_rees",  "N"},;
               {"mem_bnn_rees",  "N"},;
               {"mem_enn_rees",  "N"},;
               {"mem_bnn13rees", "N"},;
               {"mem_enn13rees", "N"},;
               {"public_date",   "D"}}
Local name_section := "OMS"
Local i, j, ta := {}, v, fl
DEFAULT fll TO .f.
if (fl := iif(fll, Semaphor_Tools_Ini(1), .t.))
  name_section += "-"+lstr(k1)+"-"+lstr(k2)
  if reg == 1 // чтение
    ta := GetIniSect(iif(fll,tools_ini,local_tools_ini), name_section) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
    for j := 1 to len(ta)
      if (i := ascan(arr, {|x| upper(x[1]) == ta[j,1] })) > 0
        if arr[i,2] == "C"
          &(arr[i,1]) := ta[j,2]
        elseif arr[i,2] == "N"
          &(arr[i,1]) := int(val(ta[j,2]))
        elseif arr[i,2] == "L"
          &(arr[i,1]) := (ta[j,2]=='1')
        elseif arr[i,2] == "D"
          &(arr[i,1]) := stod(ta[j,2])
        endif
      endif
    next
    MUSIC_ON_OFF := (mem_sound == 2)
    mem_ff_lu := iif(_upr_yes_FF(), 1, 2)
    yes_bukva := .f.
    for i := 1 to len(yes_d_plus)
      if asc(substr(yes_d_plus,i,1)) > 64
        yes_bukva := .t. ; exit
      endif
    next
    if !yes_bukva
      yes_d_plus := "+-"  // вернуть значение по умолчанию
    endif
    i := GetIniVar(tmp_ini, {{"RAB_MESTO","okato_umolch",""}} )
    if i[1] != NIL .and. !empty(i[1])
      okato_umolch := i[1]
    endif
  else // запись
    for i := 1 to len(arr)
      v := &(arr[i,1])
      if arr[i,2] == "C"
        aadd(ta, {arr[i,1], v})
      elseif arr[i,2] == "N"
        aadd(ta, {arr[i,1], lstr(v)})
      elseif arr[i,2] == "L"
        aadd(ta, {arr[i,1], iif(v,'1','0')})
      elseif arr[i,2] == "D"
        aadd(ta, {arr[i,1], dtos(v)})
      endif
    next
    SetIniSect(tools_ini, name_section, ta) // запись секции в ini.файл
  endif
  if fll
    Semaphor_Tools_Ini(2)
  endif
endif
return fl

*

*****
Function Tools_Ini_PP(reg,k1,k2,fll)
Static arr := {{"pp_NOVOR",    "N"},;
               {"pp_KEM_NAPR", "C"},;
               {"pp_POB_D_LEK","N"},;
               {"pp_KOD_VR",   "N"},;
               {"pp_TRAVMA",   "N"},;
               {"pp_NE_ZAK",   "N"}}
Local name_section := "PPOKOJ"
Local i, j, ta := {}, v, fl
DEFAULT k1 TO 0 , k2 TO 0, fll TO .f.
if (fl := iif(fll, Semaphor_Tools_Ini(1), .t.))
  name_section += "-"+lstr(k1)+"-"+lstr(k2)
  if reg == 1 // чтение
    ta := GetIniSect(iif(fll,tools_ini,local_tools_ini), name_section) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
    for j := 1 to len(ta)
      if (i := ascan(arr, {|x| upper(x[1]) == ta[j,1] })) > 0
        &(arr[i,1]) := iif(arr[i,2]=="C", ta[j,2], int(val(ta[j,2])))
      endif
    next
    mem_ortfflu := iif(_upr_yes_FF(), 1, 2)
  else // запись
    for i := 1 to len(arr)
      v := &(arr[i,1])
      aadd(ta, {arr[i,1], iif(arr[i,2]=="C", v, lstr(v))})
    next
    SetIniSect(tools_ini, name_section, ta) // запись секции в ini.файл
  endif
  if fll
    Semaphor_Tools_Ini(2)
  endif
endif
return fl

*

*****
Function Tools_Ini_Platn(reg,k1,k2,fll)
Static arr := {{"mem_anonim", "N"},;
               {"mem_naprvr", "N"},;
               {"mem_edit_s", "N"},;
               {"mem_plsoput","N"},;
               {"mem_dogovor","C"},;
               {"mem_pl_ms",  "N",.t.},;
               {"mem_pl_sn",  "N",.t.},;
               {"mem_ort_f8", "C"},;
               {"glob_close", "N"},;
               {"glob_pl_reg","N"},;
               {"glob_kassa", "N"}}
Local name_section := "PLATN"
Local i, j, ta := {}, v, fl
DEFAULT fll TO .f.
if (fl := iif(fll, Semaphor_Tools_Ini(1), .t.))
  name_section += "-"+lstr(k1)+"-"+lstr(k2)
  if reg == 1 // чтение
    ta := GetIniSect(iif(fll,tools_ini,local_tools_ini), name_section) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
    for j := 1 to len(ta)
      if (i := ascan(arr, {|x| upper(x[1]) == ta[j,1] })) > 0
        &(arr[i,1]) := iif(arr[i,2]=="C", ta[j,2], val(ta[j,2]))
        if arr[i,2]=="N" .and. len(arr[i]) == 2
          &(arr[i,1]) := int(val(ta[j,2]))
        endif
      endif
    next
    mem_ortfflu := iif(_upr_yes_FF(), 1, 2)
  else // запись
    for i := 1 to len(arr)
      v := &(arr[i,1])
      aadd(ta, {arr[i,1], iif(arr[i,2]=="C", v, lstr(v))})
    next
    SetIniSect(tools_ini, name_section, ta) // запись секции в ini.файл
  endif
  if fll
    Semaphor_Tools_Ini(2)
  endif
endif
return fl

*

*****
Function Tools_Ini_Orto(reg,k1,k2,fll)
Static arr := {{"mem_ort_na", "C"},;
               {"mem_edit_s", "N"},;
               {"mem_ort_sl", "C"},;
               {"mem_ort_ysl","N"},;
               {"mem_ortotd", "N"},;
               {"mem_ortot1", "N"},;
               {"mem_ort_ms", "N"},;
               {"mem_ort_pl", "C"},;
               {"mem_ort_bp", "C"},;
               {"mem_ort_dog","C"},;
               {"mem_ort_dat","N"},;
               {"mem_ort_f39","N"},;
               {"mem_ort_f8", "C"},;
               {"glob_kassa", "N"}}
Local name_section := "ORTO"
Local i, j, ta := {}, v, fl
DEFAULT fll TO .f.
if (fl := iif(fll, Semaphor_Tools_Ini(1), .t.))
  name_section += "-"+lstr(k1)+"-"+lstr(k2)
  if reg == 1 // чтение
    ta := GetIniSect(iif(fll,tools_ini,local_tools_ini), name_section) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
    for j := 1 to len(ta)
      if (i := ascan(arr, {|x| upper(x[1]) == ta[j,1] })) > 0
        &(arr[i,1]) := iif(arr[i,2]=="C", ta[j,2], int(val(ta[j,2])))
      endif
    next
    mem_ortfflu := iif(_upr_yes_FF(), 1, 2)
  else // запись
    for i := 1 to len(arr)
      v := &(arr[i,1])
      aadd(ta, {arr[i,1], iif(arr[i,2]=="C", v, lstr(v))})
    next
    SetIniSect(tools_ini, name_section, ta) // запись секции в ini.файл
  endif
  if fll
    Semaphor_Tools_Ini(2)
  endif
endif
return fl

*

***** настройки по вводу данных в каждой задаче
Function nastr_input(k,nTask)
return NIL

***** 09.05.18 Настройка справочников ФФОМС
Function nastr_sprav_FFOMS(k)
Static arr_spr, arr_spr_name, sk := 1
Local str_sem, mas_pmt := {}, mas_msg := {}, mas_fun := {}, j
DEFAULT k TO 0
do case
  case k == 0
    if tip_polzovat != 0
      return func_error(4,err_admin)
    endif
    DEFAULT arr_spr TO {"V002","V020","V006"}
    DEFAULT arr_spr_name TO {;
      "Классификатор ПРОФИЛЕЙ оказанной медицинской помощи",;
      "Классификатор ПРОФИЛЕЙ КОЙКИ",;
      "Классификатор УСЛОВИЙ оказания медицинской помощи"}
    for j := 1 to len(arr_spr)
      aadd(mas_pmt, "Настройка "+arr_spr[j])
      aadd(mas_msg, arr_spr_name[j])
      aadd(mas_fun, "nastr_sprav_FFOMS("+lstr(j)+")")
    next
    popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
  case k > 0
    str_sem := "Настройка "+arr_spr[k]
    if G_SLock(str_sem)
      fnastr_sprav_FFOMS(0,arr_spr[k],arr_spr_name[k])
      G_SUnLock(str_sem)
    else
      func_error(4,err_slock)
    endif
endcase
if k > 0
  sk := k
endif
return NIL

*****
Function fnastr_sprav_FFOMS(k,_n,_m)
Static sk := 1, _name, _msg
Local str_sem, mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    _name := _n ; _msg := _m
    mas_pmt := {"~По организации",;
                "По ~учреждению",;
                "По ~отделению"}
    mas_msg := {"Настройка содержания классификатора "+_name+" в целом по организации",;
                "Уточнение настройки классификатора "+_name+" по учреждению",;
                "Уточнение настройки классификатора "+_name+" по отделению"}
    mas_fun := {"fnastr_sprav_FFOMS(1)",;
                "fnastr_sprav_FFOMS(2)",;
                "fnastr_sprav_FFOMS(3)"}
    popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
  case k == 1
    f1nastr_sprav_FFOMS(0,_name,_msg)
  case k == 2
    if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL
      f1nastr_sprav_FFOMS(1,_name,_msg)
    endif
  case k == 3
    if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                 input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
      f1nastr_sprav_FFOMS(2,_name,_msg)
    endif
endcase
if k > 0
  sk := k
endif
return NIL

*****
Function f1nastr_sprav_FFOMS(reg,_name,_msg)
Local buf, t_arr[BR_LEN], blk, len1, sKey, i, s, arr, arr1, arr2, fl := .t.
Private name_arr := "glob_"+_name, ob_kol, p_blk
if !init_tmp_glob_array(,&name_arr,sys_date,_name=="V002")
  return NIL
endif
use (cur_dir+"tmp_ga") new
ob_kol := lastrec()
sKey := lstr(reg)
s := "Настройка по "
do case
  case reg == 0
    s += 'организации'
  case reg == 1
    sKey += "-"+lstr(glob_uch[1])
    s += 'учреждению "'+glob_uch[2]+'"'
  case reg == 2
    sKey += "-"+lstr(glob_otd[1])
    s += 'отделению "'+glob_otd[2]+'"'
endcase
//
if (fl := Semaphor_Tools_Ini(1))
  arr := GetIniVar(tools_ini,{{_name,'0',""}})
  arr := list2arr(arr[1])
  if len(arr) > 0
    ob_kol := len(arr)
    tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr,kod) > 0) }))
  endif
  if reg > 0
    if empty(arr)
      fl := func_error(4,"Сначала необходимо сохранить настройку классификатора по ОРГАНИЗАЦИИ")
    else
      delete for !tmp_ga->is
      pack
      //
      arr1 := GetIniVar(tools_ini,{{_name,"1-"+lstr(glob_uch[1]),""}})
      arr1 := list2arr(arr1[1])
      if len(arr1) > 0
        ob_kol := len(arr1)
        tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr1,kod) > 0) }))
      endif
    endif
    if fl .and. reg == 2
      if empty(arr1)
        fl := func_error(4,"Сначала необходимо сохранить настройку классификатора по УЧРЕЖДЕНИЮ")
      else
        delete for !tmp_ga->is
        pack
        //
        arr2 := GetIniVar(tools_ini,{{_name,sKey,""}})
        arr2 := list2arr(arr2[1])
        if len(arr2) > 0
          ob_kol := len(arr2)
          tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr2,kod) > 0) }))
        endif
      endif
    endif
  endif
  Semaphor_Tools_Ini(2)
endif
if !fl
  close databases
  return NIL
endif
index on upper(name) to (cur_dir+"tmp_ga")
buf := savescreen()
box_shadow(0,50,2,77,color1)
p_blk := {|| SetPos(1,51), DispOut(padc("Выбрано строк: "+lstr(ob_kol),26),color8) }
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
eval(p_blk)
//
t_arr[BR_TOP] := 4
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
len1 := t_arr[BR_RIGHT]-t_arr[BR_LEFT]-3-4
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := _name+" "+_msg
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_FL_NOCLEAR] := .t.
t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.t.}
t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp_ga->is, '', ' ') },blk },;
                     { center(s,len1), {|| padr(tmp_ga->name,len1) },blk }}
t_arr[BR_EDIT] := {|nk,ob| f2nastr_sprav_FFOMS(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<+,-,Ins>^ - отметить;  ^<F2>^ - поиск по подстроке") }
go top
edit_browse(t_arr)
eval(p_blk)
if f_Esc_Enter("записи настройки")
  arr := {}
  tmp_ga->(dbeval({|| iif(tmp_ga->is, aadd(arr,tmp_ga->kod),nil) }))
  if Semaphor_Tools_Ini(1)
    SetIniVar(tools_ini,{{_name,sKey,arr2list(arr)}})
    Semaphor_Tools_Ini(2)
  endif
endif
close databases
restscreen(buf)
return NIL

*****
Function f2nastr_sprav_FFOMS(nKey,oBrow,regim)
Local k := -1, rec, fl
if regim == "edit"
  do case
    case nKey == K_F2
      k := f1get_tmp_ga(nKey,oBrow,regim)
    case nkey == K_INS
      replace tmp_ga->is with !tmp_ga->is
      if tmp_ga->is
        ob_kol++
      else
        ob_kol--
      endif
      eval(p_blk)
      k := 0
      keyboard chr(K_TAB)
    case nkey == 43 .or. nkey == 45  // + или -
      fl := (nkey == 43)
      rec := recno()
      tmp_ga->(dbeval({|| tmp_ga->is := fl}))
      goto (rec)
      if fl
        ob_kol := tmp_ga->(lastrec())
      else
        ob_kol := 0
      endif
      eval(p_blk)
      k := 0
  endcase
endif
return k

*

***** 01.12.16 настройка рабочего места
Function nastr_rab_mesto()
Static group_ini := "RAB_MESTO"
Static mm_wdir := {{'в папку рабочего каталога "OwnChipArchiv"',0},;
                   {"в другое место",1}}
Static mm_wokato := {{'использовать значение из "Общих настроек"',0},;
                     {"своя настройка на данном рабочем месте",1}}
Local ar, sr, mm_tmp := {}
delete file tmp.dbf
//
Private mm_reader := {{"нет",space(50)},{"подключить","1"}}
Private mm_oms_pole := {"сроки лечения",;    //  1
                        "леч.врач",;         //  2
                        "осн.диагноз",;      //  3
                        "профиль",;          //  4
                        "результат",;        //  5
                        "исход",;            //  6
                        "повод обращения",;  //  7
                        "способ оплаты"}     //  8
ar := GetIniSect(tmp_ini,group_ini)
sr := a2default(ar,"sc_reader")
if !empty(sr)
  mm_reader[2,1] := sr
  mm_reader[2,2] := padr(sr,50)
endif
aadd(mm_tmp, {"sc_reader","C",50,0,NIL,;
              {|x|menu_reader(x,mm_reader,A__MENUVERT)},;
              "",{|x|inieditspr(A__MENUVERT,mm_reader,x)},;
              'Устройство чтения смарт-карт (для эл.полиса)',;
              {|| iif(empty(m1sc_reader), .t., f_read_sc_reader()) },;
              {|| tip_polzovat == 0 }})
aadd(mm_tmp, {"base_copy","N",1,0,NIL,;
              {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
              'Выполнять автоматическое резервное копирование при выходе из программы',,;
              {|| tip_polzovat == 0 }})
aadd(mm_tmp, {"wdir","N",1,0,NIL,;
              {|x|menu_reader(x,mm_wdir,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_wdir,x)},;
              '└> куда выполняется копирование',;
              {|| iif(empty(m1wdir), (mpath_copy:=m1path_copy:=space(100),update_get("mpath_copy")), .t.) },;
              {|| tip_polzovat == 0 .and. m1base_copy == 1 }})
aadd(mm_tmp, {"path_copy","C",100,0,NIL,;
              {|x| menu_reader(x,{{|k,r,c| mng_dir(k,r,c,"path_copy") }},A__FUNCTION)},;
              " ",{|x| x },;
              ' └> каталог для копирования',,;
              {|| tip_polzovat == 0 .and. m1base_copy == 1 .and. m1wdir == 1 }})
aadd(mm_tmp, {"kart_polis","N",1,0,NIL,;
              {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
              'В режиме добавления в картотеку производить поиск пациента по полису'})
aadd(mm_tmp, {"e_1","C",1,0,NIL,,"",,;
              'Какие поля запоминать и переносить в следующий добавляемый случай при вводе',,;
              {|| .f. }})
aadd(mm_tmp, {"oms_pole","N",15,0,NIL,;
              {|x|menu_reader(x,mm_oms_pole,A__MENUBIT)},;
              0,{|x|inieditspr(A__MENUBIT,mm_oms_pole,x)},;
              'л/у ОМС:'})
aadd(mm_tmp, {"wokato","N",1,0,NIL,;
              {|x|menu_reader(x,mm_wokato,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_wokato,x)},;
              'Какое ОКАТО по умолчанию использовать',;
              {|| iif(empty(m1wokato), (m_okato:=space(70),m1_okato:=space(11),update_get("m_okato")), .t.) }})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| ret_okato_ulica('',x)},;
              '└> ОКАТО по умолчанию',,;
              {|| m1wokato == 1 }})
if is_obmen_sds()
  aadd(mm_tmp, {"e_2","C",1,0,NIL,,"",,;
                'Каталоги для обмена информацией с программой Smart Delta Systems:',,;
                {|| .f. }})
  aadd(mm_tmp, {"path1_sds","C",100,0,NIL,;
                {|x| menu_reader(x,{{|k,r,c| mng_dir(k,r,c,"path1_sds") }},A__FUNCTION)},;
                " ",{|x| x },;
                '==> для импорта картотеки',,;
                {|| tip_polzovat == 0 }})
  aadd(mm_tmp, {"path2_sds","C",100,0,NIL,;
                {|x| menu_reader(x,{{|k,r,c| mng_dir(k,r,c,"path2_sds") }},A__FUNCTION)},;
                " ",{|x| x },;
                '==> для обработанных файлов',,;
                {|| tip_polzovat == 0 }})
endif
init_base(cur_dir+"tmp",,mm_tmp,0)
use (cur_dir+"tmp") new
append blank
tmp->sc_reader := sr
tmp->base_copy := int(val(a2default(ar,"base_copy","1")))
tmp->path_copy := a2default(ar,"path_copy","")
tmp->wdir := iif(empty(tmp->path_copy), 0, 1)
tmp->kart_polis := int(val(a2default(ar,"kart_polis","1")))
tmp->oms_pole := int(val(a2default(ar,"oms_pole","0")))
tmp->_okato := a2default(ar,"okato_umolch","")
tmp->wokato := iif(empty(tmp->_okato), 0, 1)
if is_obmen_sds()
  tmp->path1_sds := a2default(ar,"path1_sds","")
  tmp->path2_sds := a2default(ar,"path2_sds","")
endif
close databases
if f_edit_spr(A__EDIT,mm_tmp,"настройке рабочего места","g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
  use (cur_dir+"tmp") new
  mm_tmp := {;
             {group_ini,"sc_reader",   tmp->sc_reader},;
             {group_ini,"base_copy",   tmp->base_copy},;
             {group_ini,"path_copy",   tmp->path_copy},;
             {group_ini,"kart_polis",  tmp->kart_polis},;
             {group_ini,"oms_pole",    tmp->oms_pole},;
             {group_ini,"okato_umolch",tmp->_okato};
            }
  if is_obmen_sds()
    aadd(mm_tmp, {group_ini,"path1_sds",alltrim(tmp->path1_sds)} )
    aadd(mm_tmp, {group_ini,"path2_sds",alltrim(tmp->path2_sds)} )
  endif
  SetIniVar(tmp_ini,mm_tmp)
endif
close databases
return NIL

*

#define SW_HIDE 0
#define SW_SHOWNORMAL 1

*****
Function f_read_sc_reader()
Static max_seconds := 20
Static name_ini := "SCreader.ini", group_ini := "SCreader"
Static task_polis := "ReadEPolis.exe"
Static smsg := "Неудачная попытка в определении списка ридеров"
Local fl := .f., t1 := seconds(), ar, sr, se, buf := save_maxrow()
mywait("Определение списка ридеров")
if hb_FileExists(dir_exe+task_polis)
  do while seconds() - t1 < max_seconds
    if hb_FileExists(name_ini)
      delete file (name_ini)
    else
      exit
    endif
  enddo
  ShellExecute(GetDeskTopWindow(),;
               'open',;
               dir_exe+task_polis,;
               '-rdl',;
               ,;
               SW_HIDE)
  t1 := seconds()
  do while seconds() - t1 < max_seconds
    if hb_FileExists(name_ini)
      if !empty(ar := GetIniSect(name_ini,group_ini))
        sr := a2default(ar,"reader")
        se := hb_AnsiToOem(a2default(ar,"error"))
        if !empty(sr)
          fl := .t.
          msc_reader := m1sc_reader := sr
          mm_reader[2,1] := mm_reader[2,2] := sr
        else
          fl := func_error(4,iif(empty(se),smsg+".",se))
        endif
        exit
      endif
    endif
    MILLISEC(10)
  enddo
  if !hb_FileExists(name_ini)
    fl := func_error(4,smsg+"!")
  endif
else
  fl := func_error(4,"Не обнаружен файл: "+dir_exe+task_polis)
endif
if !fl
  msc_reader := "нет"
  m1sc_reader := space(50)
endif
rest_box(buf)
return .t.

*****
Function f_read_sc_polis()
Static max_seconds := 20
Static name_ini := "SCreader.ini", group_ini := "SCreader"
Static task_polis := "ReadEPolis.exe"
Static smsg := "Неудачная попытка чтения электронного полиса"
Local fl := .t., t1 := seconds(), ar, se, buf := save_maxrow()
mywait("Чтение электронного полиса")
if hb_FileExists(dir_exe+task_polis)
  do while seconds() - t1 < max_seconds
    if hb_FileExists(name_ini)
      delete file (name_ini)
    else
      exit
    endif
  enddo
  ShellExecute(GetDeskTopWindow(),;
               'open',;
               dir_exe+task_polis,;
               '-roi="'+name_reader+'"',;
               ,;
               SW_HIDE)
  t1 := seconds()
  do while seconds() - t1 < max_seconds
    if hb_FileExists(name_ini)
      if !empty(ar := GetIniSect(name_ini,group_ini))
        arr_epolis[_EP_OGRN   ] :=              a2default(ar,"OGRN")
        arr_epolis[_EP_OKATO  ] :=              a2default(ar,"OKATO")
        arr_epolis[_EP_FAM    ] := hb_AnsiToOem(a2default(ar,"FAM"))
        arr_epolis[_EP_IM     ] := hb_AnsiToOem(a2default(ar,"IM"))
        arr_epolis[_EP_OT     ] := hb_AnsiToOem(a2default(ar,"OT"))
        arr_epolis[_EP_W      ] :=              a2default(ar,"W")
        arr_epolis[_EP_DR     ] :=              a2default(ar,"DR")
        arr_epolis[_EP_MR     ] := hb_AnsiToOem(a2default(ar,"MR"))
        arr_epolis[_EP_NPOLIS ] :=              a2default(ar,"NPOLIS")
        arr_epolis[_EP_D_BEGIN] :=              a2default(ar,"D_BEGIN")
        arr_epolis[_EP_D_END  ] :=              a2default(ar,"D_END")
        arr_epolis[_EP_SNILS  ] :=              a2default(ar,"SNILS")
                             se := hb_AnsiToOem(a2default(ar,"error"))
        exit
      endif
    endif
    MILLISEC(10)
  enddo
  if !hb_FileExists(name_ini)
    fl := func_error(4,smsg+"!")
  endif
else
  fl := func_error(4,"Не обнаружен файл: "+dir_exe+task_polis)
endif
if fl
  if emptyall(arr_epolis[_EP_OGRN],arr_epolis[_EP_OKATO],arr_epolis[_EP_FAM],;
              arr_epolis[_EP_IM],arr_epolis[_EP_NPOLIS])
    fl := func_error(4,iif(empty(se),smsg+".",se))
  else
    R_Use(exe_dir+"_mo_smo",cur_dir+"_mo_smo3","_SMO")
    find (arr_epolis[_EP_OKATO]+padr(arr_epolis[_EP_OGRN],13))
    if found()
      arr_epolis[_EP_SMO] := _smo->smo
      arr_epolis[_EP_NAMESMO] := alltrim(_smo->name)
    else
      func_error(4,"Не найдена СМО (ОКАТО="+arr_epolis[_EP_OKATO]+", ОГРН="+rtrim(arr_epolis[_EP_OGRN])+")")
    endif
    _smo->(dbCloseArea())
    arr_epolis[_EP_W      ] := iif(arr_epolis[_EP_W]=="1", "М","Ж")
    arr_epolis[_EP_DR     ] := xml2date(arr_epolis[_EP_DR])
    arr_epolis[_EP_D_BEGIN] := xml2date(arr_epolis[_EP_D_BEGIN])
    arr_epolis[_EP_D_END  ] := xml2date(arr_epolis[_EP_D_END])
    arr_epolis[_EP_SNILS  ] := charrem(" -",arr_epolis[_EP_SNILS])
  endif
endif
rest_box(buf)
return fl

***** 14.03.16
Function mo_read_el_polis(/*@*/k)
Local fl := .f., rec := 0, mfio, mdate_r, arr, buf := savescreen()
Private arr_epolis[_EP_LEN]
afill(arr_epolis,"")
if f_read_sc_polis()
  mfio := alltrim(arr_epolis[_EP_FAM])+" "+;
          alltrim(arr_epolis[_EP_IM])+" "+;
          alltrim(arr_epolis[_EP_OT])
  mdate_r := arr_epolis[_EP_DR]
  R_Use(dir_server+"kartotek",dir_server+"kartotep","KART")
  find ("1"+padr(arr_epolis[_EP_NPOLIS],17))
  if found()
    rec := recno()
  else
    mfio := padr(upper(mfio),50)
    set index to (dir_server+"kartoten")
    find ("1"+mfio+dtos(mdate_r))
    if found()
      rec := recno()
    endif
  endif
  if rec > 0
    R_Use(dir_server+"kartote2",,"KART2")
    goto (rec)
    R_Use(dir_server+"kartote_",,"KART_")
    goto (rec)
    kartotek_to_screen(1,8)
    @ 0,0 to 9,79 color "G+/B"
    str_center(0," В картотеке найден пациент ","G+/RB")
  endif
  ClrLines(10,19,color1)
  @ 11,2 say "Ф.И.О.: "+padr(mfio,50)+space(7)+iif(arr_epolis[_EP_W]=="М","мужчина","женщина") color color8
  @ 12,2 say "Дата рождения: "+full_date(arr_epolis[_EP_DR]) color color8
  @ 13,2 say "СНИЛС: "+transform(arr_epolis[_EP_SNILS],picture_pf) color color8
  @ 14,2 say "Место рождения: "+alltrim(arr_epolis[_EP_MR]) color color8
  @ 15,2 say "Полис ОМС: "+alltrim(arr_epolis[_EP_NPOLIS]) color color8
  @ 16,2 say "           действителен с "+full_date(arr_epolis[_EP_D_BEGIN])+" по "+full_date(arr_epolis[_EP_D_END]) color color8
  @ 17,2 say "СМО: "+iif(empty(arr_epolis[_EP_NAMESMO]), "не найдена, ОГРН: "+arr_epolis[_EP_OGRN], alltrim(arr_epolis[_EP_NAMESMO])) color color8
  @ 18,2 say "Субъект РФ территории страхования: "+inieditspr(A__MENUVERT, glob_array_srf, arr_epolis[_EP_OKATO]) color color8
  @ 10,0 to 19,79 double color color8
  str_center(10," Информация с электронного полиса ","GR+/R")
  FillScrArea(20,0,24,79,"░",color1)
  close databases
  k := 2 ; arr := {" Отказ от записи "," Добавить в картотеку "}
  if rec > 0
    k := 3 ; aadd(arr, " Перезаписать ")
  endif
  k := f_alert({padc("Выберите действие",60,".")},arr,;
                k,"W+/N","N+/N",20,,"W+/N,N/BG" )
  if k > 1
    if k == 2 // при добавлении
      rec := 0 // обнуляем значение номера записи
    endif
    Use_base("kartotek")
    if rec == 0  // добавление в картотеку
      Add1Rec(7)
      kart->kod := recno()
    else
      goto (rec)
      G_RLock(forever)
    endif
    glob_kartotek := kart->kod
    glob_k_fio    := alltrim(mfio)
    kart->FIO     := mfio
    kart->pol     := arr_epolis[_EP_W]
    kart->DATE_R  := arr_epolis[_EP_DR]
    kart->POLIS   := arr_epolis[_EP_NPOLIS]
    kart->srok_polis := dtoc4(arr_epolis[_EP_D_END])
    if !empty(arr_epolis[_EP_SNILS])
      kart->snils := arr_epolis[_EP_SNILS]
    endif
    newMEST_INOG := 0
    if TwoWordFamImOt(arr_epolis[_EP_FAM]) ;
                .or. TwoWordFamImOt(arr_epolis[_EP_IM]) ;
                .or. TwoWordFamImOt(arr_epolis[_EP_OT])
      newMEST_INOG := 9
    endif
    kart->MEST_INOG := newMEST_INOG
    select KART_
    do while kart_->(lastrec()) < glob_kartotek
      APPEND BLANK
    enddo
    goto (glob_kartotek)
    G_RLock(forever)
    kart_->VPOLIS := 3
    kart_->SPOLIS := ""
    kart_->NPOLIS := arr_epolis[_EP_NPOLIS]
    kart_->SMO    := arr_epolis[_EP_SMO]
    kart_->beg_polis := dtoc4(arr_epolis[_EP_D_BEGIN])
    kart_->mesto_r  := arr_epolis[_EP_MR]
    kart_->KVARTAL_D := arr_epolis[_EP_OKATO]
    if newMEST_INOG == 9
      G_Use(dir_server+"mo_kfio",,"KFIO")
      index on str(kod,7) to (cur_dir+"tmp_kfio")
      find (str(glob_kartotek,7))
      if found()
        G_RLock(forever)
      else
        AddRec(7)
        kfio->kod := glob_kartotek
      endif
      kfio->FAM := arr_epolis[_EP_FAM]
      kfio->IM  := arr_epolis[_EP_IM]
      kfio->OT  := arr_epolis[_EP_OT]
    endif
    close databases
    SetIniSect(tmp_ini,"polikl1",{{"s_regim","1"},{"s_shablon",""},{"s_polis",""},{"s_snils",""}})
    fl := .t.
  endif
endif
restscreen(buf)
return fl

*==============================================================================

***** 23.03.20 создание первичной БД из реестров
Function create_main_base_from_reestrs()
Local full_zip, name_zip, i, k, n, fl := .t., buf := save_maxrow(),;
      arr_r := {}, arr_rsptk := {}, arr_s := {}, a_reestr := {},;
      oXmlDoc, cFile, cbukva
R_Use(dir_server+"human")
k := lastrec()
use
Private p_lpu := 2, p_otd := 8 // для Камышинской детской больницы
Private flag_is_lu := .t. // для пустой БД поставить .f.
if flag_is_lu
  // уже есть (какие-то) листы учёта
elseif k > 0 // иначе работаем только с пустой БД листов учёта
  return NIL
endif
Private cImportProtokol := "protokol"+stxt, pr_array_schet := {}
Private p_var_manager := "Read_reestrs"
full_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*"+szip)
if !empty(full_zip)
  mywait()
  strfile(space(10)+"Протокол создания БД из реестров ТФОМС "+;
          date_8(sys_date)+" "+hour_min(seconds())+;
          hb_eol()+hb_eol(),cImportProtokol)
  name_zip := StripPath(full_zip)
  Private name_path := KeepPath(full_zip)+cslash
  scandirfiles(name_path, "HRM*"+szip, {|x| aadd(arr_r,x)     })
  scandirfiles(name_path, "FRM*"+szip, {|x| aadd(arr_r,x)     })
  scandirfiles(name_path, "HRT*"+szip, {|x| aadd(arr_rsptk,x) })
  scandirfiles(name_path, "FRT*"+szip, {|x| aadd(arr_rsptk,x) })
  scandirfiles(name_path, "HM*" +szip, {|x| aadd(arr_s,x)     })
  scandirfiles(name_path, "FM*" +szip, {|x| aadd(arr_s,x)     })
  if empty(arr_r)
    fl := .f.
    strfile("Не обнаружено реестров для импорта"+hb_eol(),cImportProtokol,.t.)
  else
    asort(arr_r)
    asort(arr_rsptk)
  endif
  // реестры
  for i := 1 to len(arr_r)
    s := substr(StripPath(arr_r[i]),4,6)
    if s == glob_MO[_MO_KOD_TFOMS]
      s := Name_Without_Ext(arr_r[i])
      if chip_copy_zipXML(arr_r[i],dir_server+dir_XML_MO)
        if extract_reestr(1,s,.t.,.f.)
          use (cur_dir+"tmp1file") new alias TMP1
          s1 := substr(afteratnum("_",Name_Without_Ext(StripPath(arr_r[i]))),5)
          n := int(val(s1))
          aadd(a_reestr,{arr_r[i],;       // 1
                         tmp1->_CODE,;    // 2
                         int(val(tmp1->_NSCHET)),;  // 3
                         tmp1->_DSCHET,;  // 4
                         tmp1->_YEAR,;    // 5
                         tmp1->_MONTH,;   // 6
                         {},;             // 7
                         0,;              // 8
                         n})              // 9 длина номера пакета - в 2017 году = 5
          use
        else
          strfile(arr_r[i]+": не удалось открыть реестр"+hb_eol(),cImportProtokol,.t.)
          fl := .f. ; exit
        endif
      else
        strfile(arr_r[i]+": ошибка записи реестра в XML_MO"+hb_eol(),cImportProtokol,.t.)
        fl := .f. ; exit
      endif
    else
      strfile(arr_r[i]+": несоответствие кода МО "+s+hb_eol(),cImportProtokol,.t.)
      fl := .f. ; exit
    endif
  next
  // счета
  dbcreate(cur_dir+"tmp_s_id",{{"KOD",    "N", 6,0},;
                               {"NIDCASE","N",12,0},;
                               {"IDCASE", "C",12,0},;
                               {"ID_C",   "C",36,0}})
  for i := 1 to len(arr_s)
    s := substr(StripPath(arr_s[i]),3,6)
    if s == glob_MO[_MO_KOD_TFOMS]
      s := Name_Without_Ext(arr_s[i])
      if chip_copy_zipXML(arr_s[i],dir_server+dir_XML_MO)
        k := len(pr_array_schet)+1
        if extract_reestr(k,s,.t.,.t.)
          use (cur_dir+"tmp1file") new alias TMP1
          s1 := substr(afteratnum("_",Name_Without_Ext(StripPath(arr_s[i]))),5)
          n := int(val(s1))
          cbukva := " "
          if asc(right(alltrim(tmp1->_NSCHET),1)) >= 65 // т.е. "A" и т.д.
            cbukva := right(alltrim(tmp1->_NSCHET),1)
          endif
          aadd(pr_array_schet,{s,;              // 1 имя файла
                               n,;              // 2 номер пакета
                               tmp1->_NSCHET,;  // 3 номер счёта
                               tmp1->_DSCHET,;  // 4 дата счёта
                               tmp1->_SUMMAV,;  // 5 сумма счёта
                               tmp1->_YEAR,;    // 6 год отчётного периода
                               tmp1->_KOL,;     // 7 кол-во пациентов
                               tmp1->_MAX,;     // 8 максимальный N_ZAP
                               len(s1),;        // 9 длина номера пакета (2,3,в 2017 году = 5)
                               cbukva,;         //10 буква счёта
                               k})              //11 код счёта в массиве
          use
          use (cur_dir+"tmp_s_id") new
          append from tmp_r_t1
          use
        else
          strfile(arr_s[i]+": не удалось открыть архив счетов"+hb_eol(),cImportProtokol,.t.)
          fl := .f. ; exit
        endif
        delete file (dir_server+dir_XML_MO+cslash+s+szip)
      else
        strfile(arr_s[i]+": ошибка записи счёта в XML_MO"+hb_eol(),cImportProtokol,.t.)
        fl := .f. ; exit
      endif
    else
      strfile(arr_s[i]+": несоответствие кода МО "+s+hb_eol(),cImportProtokol,.t.)
      fl := .f. ; exit
    endif
  next
  asort(pr_array_schet,,,{|x,y| iif(x[4] == y[4],;
                                    val(x[3]) < val(y[3]),;
                                    x[4] < y[4]) })
  for i := 1 to len(pr_array_schet)
    my_debug(,print_array(pr_array_schet[i]))
  next
  // реестры СП и ТК
  for i := 1 to len(arr_rsptk)
    s := afteratnum("_",StripPath(arr_rsptk[i]))
    if left(s,1) == "M"
      s := substr(s,2)
    else
      strfile(arr_rsptk[i]+": неверная буква в обозначении получателя"+hb_eol(),cImportProtokol,.t.)
      fl := .f. ; exit
    endif
    if fl
      s := left(s,6)
      if s == glob_MO[_MO_KOD_TFOMS]
        if Extract_Zip_XML(KeepPath(arr_rsptk[i]),StripPath(arr_rsptk[i])) != NIL
          s := Name_Without_Ext(arr_rsptk[i])
          cFile := s+sxml
          // читаем XML-файл в память
          oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
          reestr_sp_tk_tmpfile(oXmlDoc,,cFile)
          n := int(val(tmp1->_NSCHET))  // в число (отрезать всё, что после "-")
          if (k := ascan(a_reestr, {|x| x[3] == n .and. x[5] == tmp1->_YEAR})) > 0
            n := int(val(substr(afteratnum("_",Name_Without_Ext(StripPath(s))),12))) // номер пакета
            if empty(a_reestr[k,8])
              a_reestr[k,8] := n
            endif
            a_reestr[k,8] := min(a_reestr[k,8],n)
            aadd(a_reestr[k,7], {arr_rsptk[i],tmp1->_NSCHET,tmp1->_DSCHET,n})
          endif
          close databases
        endif
      else
        strfile(arr_rsptk[i]+": несоответствие кода МО"+hb_eol(),cImportProtokol,.t.)
        fl := .f. ; exit
      endif
    endif
  next
  if fl
    for i := 1 to len(a_reestr)
      if empty(a_reestr[i,8])  // если ещё не было реестров СП и ТК,
        a_reestr[i,8] := 1000  // то данный реестр обрабатывается последним
      endif
    next
    // реестры сортируем: отчётный период + min номер пакета реестров СП и ТК
    asort(a_reestr,,,{|x,y| iif(x[5] == y[5],;
                                iif(x[6] == y[6],;
                                    iif(x[3] == y[3], x[8] < y[8], x[3] < y[3]),;
                                    x[6] < y[6]),;
                                x[5] < y[5]) })
    for i := 1 to len(a_reestr)
      strfile(a_reestr[i,1]+", "+lstr(a_reestr[i,3])+", "+;
              dtoc(a_reestr[i,4])+", "+lstr(a_reestr[i,8])+hb_eol(),cImportProtokol,.t.)
      // реестры СП и ТК сортируем по номеру пакета СП и ТК
      asort(a_reestr[i,7],,,{|x,y| x[4] < y[4] })
      for k := 1 to len(a_reestr[i,7])
        strfile(" "+print_array(a_reestr[i,7,k])+hb_eol(),cImportProtokol,.t.)
      next
    next
    use (cur_dir+"tmp_s_id") new alias TS
    dbeval({|| ts->NIDCASE := int(val(ts->IDCASE)) })
    use
    fl := f1_create_main_base_from_reestrs(a_reestr)
  endif
  viewtext(Devide_Into_Pages(cImportProtokol,60,80),,,,.t.,,,2)
  rest_box(buf)
endif
return NIL

***** 22.11.19
Function f1_create_main_base_from_reestrs(a_reestr)
Local aerr, oXmlDoc, oXmlNode, oNode1, oNode2, cFile, old_sys_date,;
      i, j, n, s, arr_XML_info[7], fl := .t., arr_f, nCountWithErr
arr_XML_info[1] := _XML_FILE_SP
arr_XML_info[2] := '34'
arr_XML_info[3] := glob_MO[_MO_KOD_TFOMS]
Private cReadFile, cTimeBegin, mkod_reestr, mdate_schet, is_err_FLK, cFileProtokol, full_zip, mXML_REESTR
glob_podr := "" ; glob_otd_dep := 0 // пока без кода подразделения
for i := 1 to len(a_reestr)
  if chip_copy_zipXML(a_reestr[i,1],dir_server+dir_XML_MO)
    strfile(StripPath(a_reestr[i,1])+": обработка реестра № "+lstr(a_reestr[i,3])+hb_eol(),cImportProtokol,.t.)
    s := Name_Without_Ext(a_reestr[i,1])
    if extract_reestr(1,s,.t.)
      if (fl := f2_create_main_base_from_reestrs(s))
        //s := "P"+s // до 1 ноября
        s := "V"+s // после 1 ноября
        full_zip := name_path+s+szip
        if hb_FileExists(full_zip) // читать протокол ФЛК
          strfile(" "+StripPath(full_zip)+": обработка протокола ФЛК"+hb_eol(),cImportProtokol,.t.)
          if (arr_f := Extract_Zip_XML(KeepPath(full_zip),s+szip)) != NIL
            if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(s)})) > 0
              arr_XML_info[4] := a_reestr[i,5]
              arr_XML_info[5] := a_reestr[i,6]
              arr_XML_info[6] := a_reestr[i,9]
              arr_XML_info[7] := mkod_reestr
              // читаем файл в память
              cFile := arr_f[n]
              // читаем XML-файл в память
              oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
              if oXmlDoc == NIL .or. empty( oXmlDoc:aItems )
                strfile(full_zip+": ошибка в чтении файла"+hb_eol(),cImportProtokol,.t.)
                fl := .f. ; exit
              endif
              aerr := {}
              is_err_FLK := protokol_flk_tmpfile(arr_f,aerr)
              close databases
              if !empty(aerr)
                Ins_Array(aerr,1,"")
                Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
                aeval(aerr,{|x| strfile(x+hb_eol(),cImportProtokol,.t.) })
                fl := .f. ; exit
              endif
              old_sys_date := sys_date
              sys_date := a_reestr[i,4]
              //
              cReadFile := Name_Without_Ext(cFile)
              cTimeBegin := hour_min(seconds())
              cFileProtokol := cReadFile+stxt
              strfile(space(10)+"Протокол обработки файла: "+cFile+hb_eol(),cFileProtokol)
              strfile(space(10)+full_date(sys_date)+"г. "+cTimeBegin+hb_eol(),cFileProtokol,.t.)
              strfile(hb_eol()+"Тип файла: протокол ФЛК (форматно-логического контроля)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
              if read_XML_FILE_FLK(arr_XML_info,aerr)
                // запишем принимаемый файл (протокол ФЛК)
                //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
                chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
                use (cur_dir+"tmp1file") new alias TMP1
                G_Use(dir_server+"mo_xml",,"MO_XML")
                AddRecN()
                mo_xml->KOD := recno()
                mo_xml->FNAME := cReadFile
                mo_xml->DREAD := sys_date
                mo_xml->TREAD := hour_min(seconds())
                mo_xml->TIP_IN := _XML_FILE_FLK // тип принимаемого файла;3-ФЛК
                mo_xml->DWORK  := sys_date
                mo_xml->TWORK1 := cTimeBegin
                mo_xml->TWORK2 := hour_min(seconds())
                mo_xml->REESTR := mkod_reestr
                mo_xml->KOL2   := tmp1->KOL2
                close databases
              endif
              if empty(aerr)
                // запишем файл протокола обработки
                chip_copy_zipXML(cFileProtokol,dir_server+dir_XML_TF)
                delete file (cFileProtokol)
              else
                Ins_Array(aerr,1,"")
                Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
                aeval(aerr,{|x| strfile(x+hb_eol(),cImportProtokol,.t.) })
                fl := .f. ; exit
              endif
              //
              sys_date := old_sys_date
            else
              strfile(s+": нет файла "+s+sxml+hb_eol(),cImportProtokol,.t.)
              fl := .f. ; exit
            endif
          endif
        endif
        for j := 1 to len(a_reestr[i,7])
          s := Name_Without_Ext(a_reestr[i,7,j,1])
          arr_XML_info[6] := a_reestr[i,7,j,4]
          arr_XML_info[7] := 0
          if (arr_f := Extract_Zip_XML(KeepPath(a_reestr[i,7,j,1]),s+szip)) != NIL
            if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(s)})) > 0
              cFile := arr_f[n]
              // читаем XML-файл в память
              oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
              if oXmlDoc == NIL .or. empty( oXmlDoc:aItems )
                strfile(a_reestr[i,7,j,1]+": ошибка в чтении файла"+hb_eol(),cImportProtokol,.t.)
                fl := .f. ; exit
              endif
              aerr := {}
              reestr_sp_tk_tmpfile(oXmlDoc,aerr,cFile)
              close databases
              if !empty(aerr)
                Ins_Array(aerr,1,"")
                Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
                aeval(aerr,{|x| strfile(x+hb_eol(),cImportProtokol,.t.) })
                fl := .f. ; exit
              endif
              old_sys_date := sys_date
              use (cur_dir+"tmp1file") new alias TMP1
              sys_date := tmp1->_DSCHET
              use
              full_zip := a_reestr[i,7,j,1]
              strfile(" "+StripPath(a_reestr[i,7,j,1])+": обработка реестра СП и ТК "+a_reestr[i,7,j,2]+hb_eol(),cImportProtokol,.t.)
              cReadFile := Name_Without_Ext(cFile)
              cTimeBegin := hour_min(seconds())
              cFileProtokol := cReadFile+stxt
              strfile(space(10)+"Протокол обработки файла: "+cFile+hb_eol(),cFileProtokol)
              strfile(space(10)+full_date(sys_date)+"г. "+cTimeBegin+hb_eol(),cFileProtokol,.t.)
              strfile(hb_eol()+"Тип файла: реестр СП и ТК (страховой принадлежности и технологического контроля)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
              nCountWithErr := mXML_REESTR := 0
              if read_XML_FILE_SP(arr_XML_info,aerr,@nCountWithErr) > 0
                stat_msg("")
                create_schet_from_XML(arr_XML_info,aerr,.f.,,cReadFile)
                stat_msg("")
              elseif nCountWithErr > 0 // все пришли с ошибкой
                G_Use(dir_server+"mo_xml",,"MO_XML")
                goto (mXML_REESTR)
                G_RLock(forever)
                mo_xml->TWORK2 := hour_min(seconds())
                close databases
              endif
              if empty(aerr) .or. nCountWithErr > 0
                // запишем файл протокола обработки
                chip_copy_zipXML(cFileProtokol,dir_server+dir_XML_TF)
                delete file (cFileProtokol)
              endif
              if !empty(aerr)
                Ins_Array(aerr,1,"")
                Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
                aeval(aerr,{|x| strfile(x+hb_eol(),cImportProtokol,.t.) })
                fl := .f. ; exit
              endif
              sys_date := old_sys_date
            else
              strfile(a_reestr[i,7,j,1]+": нет файла "+s+sxml+hb_eol(),cImportProtokol,.t.)
              fl := .f. ; exit
            endif
          else
            strfile(a_reestr[i,7,j,1]+": ошибка Extract_Zip_XML "+s+sxml+hb_eol(),cImportProtokol,.t.)
            fl := .f. ; exit
          endif
          close databases
        next
      else
        strfile(a_reestr[i,1]+": ошибка f2_create_main_base_from_reestrs"+hb_eol(),cImportProtokol,.t.)
        exit
      endif
    else
      strfile(a_reestr[i,1]+": не удалось открыть реестр"+hb_eol(),cImportProtokol,.t.)
      fl := .f. ; exit
    endif
  else
    strfile(a_reestr[i,1]+": ошибка записи реестра в XML_MO"+hb_eol(),cImportProtokol,.t.)
    fl := .f. ; exit
  endif
  close databases
next
close databases
return fl

***** 11.04.19
Function f2_create_main_base_from_reestrs(mname_xml)
Local fl := .t., auch_otd, _tip_lu
use (cur_dir+"tmp_r_t1") new alias T1
use (cur_dir+"tmp_r_t2") new alias T2
index on IDCASE to (cur_dir+"tmp_t2")
use (cur_dir+"tmp_r_t3") new alias T3
index on upper(ID_PAC) to (cur_dir+"tmp_t3")
use (cur_dir+"tmp1file") new alias TMP1
use (cur_dir+"tmp_r_t4") new alias T4
index on IDCASE to (cur_dir+"tmp_t4")
//
mkod_reestr := 0
G_Use(dir_server+"mo_rees",,"REES")
if flag_is_lu
  Locate for NAME_XML == padr(mname_xml,26)
  if found()
    mkod_reestr := recno()
    close databases
    return fl
  endif
endif
AddRecN()
rees->KOD      := recno()
rees->NSCHET   := int(val(tmp1->_NSCHET))
rees->DSCHET   := tmp1->_DSCHET
rees->NYEAR    := tmp1->_YEAR
rees->NMONTH   := tmp1->_MONTH
rees->NN       := val(substr(afteratnum("_",mname_xml),5))
rees->NAME_XML := mname_xml
rees->SUMMA    := tmp1->_SUMMAV
rees->CODE     := tmp1->_CODE
rees->DATE_OUT := tmp1->_DSCHET
rees->NUMB_OUT := 1
mkod_reestr := recno()
//
G_Use(dir_server+"mo_xml",,"MO_XML")
AddRecN()
mo_xml->KOD    := recno()
mo_xml->FNAME  := mname_xml
mo_xml->FNAME2 := "L"+substr(mname_xml,2)
mo_xml->DFILE  := rees->DSCHET
mo_xml->TIP_OUT := _XML_FILE_REESTR // тип высылаемого файла;1-реестр
mo_xml->REESTR := mkod_reestr
mo_xml->DREAD := tmp1->_DSCHET
mo_xml->TREAD := '12:00'
rees->KOD_XML := mo_xml->KOD
UnLock
Commit
//
use_base("lusl")
use_base("luslc")
use_base("luslf")
G_Use(dir_server+"mo_rhum",,"RHUM")
G_Use(dir_server+"mo_pers",,"PERSO")
index on snils+str(prvs_new,4) to (cur_dir+"tmppsnils")
index on snils+str(prvs,9) to (cur_dir+"tmppsnils1")
set index to (cur_dir+"tmppsnils"),(cur_dir+"tmppsnils1")
Use_base("mo_su")
Use_base("uslugi")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
G_Use(dir_server+"mo_kfio",,"KFIO")
index on str(kod,7) to (cur_dir+"tmp_kfio")
G_Use(dir_server+"mo_kismo",,"KSN")
index on str(kod,7) to (cur_dir+"tmpkismo")
G_Use(dir_server+"mo_hismo",,"HSN")
index on str(kod,7) to (cur_dir+"tmphismo")
R_Use(dir_server+"mo_otd",,"OTD")
index on str(tiplu,2)+str(kod_lpu,3) to (cur_dir+"tmpotd1") ;
      for empty(dend) .and. kod > 0 .and. kod_lpu > 0
index on str(profil,3)+str(idump,2)+str(kod_lpu,3) to (cur_dir+"tmpotd2") ;
      for empty(dend) .and. kod > 0 .and. kod_lpu > 0
index on str(code_dep,3)+str(idump,2)+str(kod_lpu,3) to (cur_dir+"tmpotd3") ;
      for empty(dend) .and. kod > 0 .and. kod_lpu > 0
set index to (cur_dir+"tmpotd1"),(cur_dir+"tmpotd2"),(cur_dir+"tmpotd3")
Use_base("kartotek")
Use_base("mo_hu")
Use_base("human_u")
Use_base("human")
select HUMAN_
index on upper(ID_C) to (cur_dir+"tmp_h_")
//
stat_msg("Импорт из реестра "+mname_xml)
pkol := 0
select T1
go top
do while !eof()
  pkol++
  is_zak_sl := .f. ; a_usl := {}
  @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
  select T3
  find (upper(t1->ID_PAC))
  if found()
    afio := array(3)
    if left(t1->NOVOR,1) == '0' .or. empty(t3->FAM_P)
      afio[1] := t3->fam
      afio[2] := t3->im
      afio[3] := t3->ot
      mpol    := t3->W
      mdate_r := t3->DR
    else
      afio[1] := t3->FAM_P
      afio[2] := t3->IM_P
      afio[3] := t3->OT_P
      mpol    := t3->W_P
      mdate_r := t3->DR_P
    endif
    mfio := padr(alltrim(afio[1])+" "+alltrim(afio[2])+" "+alltrim(afio[3]),50)
    mpol := iif(mpol=='1',"М","Ж")
    mdate_r := xml2date(mdate_r)
    mpolis := padr(make_polis(t1->spolis,t1->npolis),17)
    if empty(mfio)
my_debug(,"реестр="+lstr(mkod_reestr)+", запись="+t1->IDCASE)
my_debug(,"|NOVOR|"+t1->NOVOR)
my_debug(,"|фио|"+rtrim(mfio))
my_debug(,"|д.рожд.|"+dtoc(mdate_r))
my_debug(,"|полис|"+rtrim(mpolis))
    endif
    //
    mkod := lkod_k := 0 ; _is_lu := .f.
    if flag_is_lu
      select HUMAN_
      find (upper(t1->ID_C))
      if found()
        _is_lu := .t. // уже есть такой л/у
        mkod := human_->(recno())
        human->(dbGoto(mkod))
        kart->(dbGoto(human->kod_k))
        lkod_k := kart->kod
      endif
    endif
    if _is_lu // если уже есть такой л/у
      f3_create_main_base_from_reestrs()
    else
      if empty(lkod_k)
        select KART
        set order to 2 // index on if(kod>0,"1","0")+upper(fio)+dtos(date_r) to (dir_server+"kartoten") progress
        find ("1"+upper(mfio)+dtos(mdate_r))
        if found()
          lkod_k := kart->kod
        endif
      endif
      select KART
      set order to 1 // index on str(kod,7) to (dir_server+"kartotek") progress
      if empty(lkod_k)
        Add1Rec(7)
        lkod_k := kart->kod := recno()
my_debug(,print_array({"добавление",lkod_k,mfio}))
      else
        find (str(lkod_k,7))
        G_RLock(forever)
      endif
      if !empty(mfio)
        kart->FIO    := mFIO
      endif
      if !empty(mdate_r)
        kart->DATE_R := mdate_r
      endif
      m1VZROS_REB := M1NOVOR := 0
      fv_date_r()
      kart->pol       := mpol
      kart->VZROS_REB := m1VZROS_REB
      kart->POLIS     := mpolis
      kart->snils     := charrem("- ",t3->SNILS)
      if TwoWordFamImOt(afio[1]) .or. TwoWordFamImOt(afio[2]) .or. TwoWordFamImOt(afio[3])
        kart->MEST_INOG := 9
      else
        kart->MEST_INOG := 0
      endif
      select KART_
      do while kart_->(lastrec()) < lkod_k
        APPEND BLANK
      enddo
      goto (lkod_k)
      G_RLock(forever)
      kart_->VPOLIS := val(t1->vpolis)
      kart_->SPOLIS := t1->SPOLIS
      kart_->NPOLIS := t1->NPOLIS
      kart_->SMO    := t1->smo
      kart_->vid_ud := val(t3->DOCTYPE)
      kart_->ser_ud := t3->DOCSER
      kart_->nom_ud := t3->DOCNUM
      kart_->mesto_r:= t3->MR
      kart_->okatog := t3->OKATOG
      kart_->okatop := iif(t3->OKATOG == t3->OKATOP, "", t3->OKATOP)
      kart_->KVARTAL_D := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
      //
      select KFIO
      find (str(lkod_k,7))
      if found()
        if kart->MEST_INOG == 9
          G_RLock(forever)
          kfio->FAM := afio[1]
          kfio->IM  := afio[2]
          kfio->OT  := afio[3]
        else
          DeleteRec(.t.)
        endif
      else
        if kart->MEST_INOG == 9
          AddRec(7)
          kfio->kod := lkod_k
          kfio->FAM := afio[1]
          kfio->IM  := afio[2]
          kfio->OT  := afio[3]
        endif
      endif
      //
      fl_nameismo := (empty(t1->SMO) .and. !empty(t1->SMO_NAM))
      if fl_nameismo
        kart_->SMO := "34"
      endif
      select KSN
      find (str(lkod_k,7))
      if found()
        if fl_nameismo
          G_RLock(forever)
          ksn->smo_name := t1->SMO_NAM
        else
          DeleteRec(.t.)
        endif
      else
        if fl_nameismo
          AddRec(7)
          ksn->kod := lkod_k
          ksn->smo_name := t1->SMO_NAM
        endif
      endif
      UnLock
      //
      lvrach := 0 ; n := prvs_V021_to_V015(t1->PRVS)
      if len(alltrim(t1->IDDOKT)) == 11
        lvrach := ret_perso_with_tab_nom(t1->IDDOKT,n)
        if empty(lvrach) .and. !flag_is_lu
          select PERSO
          AddRecN()
          lvrach := perso->kod := recno()
          perso->tab_nom := recno()
          perso->fio  := "Сотрудник с кодом "+lstr(lvrach)
          perso->uch  := p_lpu
          perso->otd  := p_otd
          perso->prvs_new := n
          perso->snils := t1->IDDOKT
          UnLock
        endif
      endif
      //
      mDATE_R2 := ctod("")
      if (M1NOVOR := int(val(left(t1->NOVOR,1)))) > 0
        mDATE_R2 := mdate_r
      endif
      fv_date_r(xml2date(t1->DATE_1))
      select HUMAN
      set order to 1
      if mkod == 0
        Add1Rec(7)
        mkod := human->kod := recno()
      else
        goto (mkod)
        G_RLock(forever)
        if human->kod_k != lkod_k
my_debug(,"  "+rtrim(human->fio)+"|фио|"+rtrim(mfio))
my_debug(,"  "+dtoc(human->date_r)+"|д.рожд.|"+dtoc(mdate_r))
my_debug(,"  "+rtrim(human->polis)+"|полис|"+rtrim(mpolis))
        endif
        if human_->REESTR == mkod_reestr
my_debug(,"  "+rtrim(human->fio)+"=второй раз в реестре="+lstr(mkod_reestr))
        endif
      endif
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      human->kod_k      := lkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := kart->FIO    // Ф.И.О. больного
      human->POL        := kart->POL    // пол
      human->DATE_R     := kart->DATE_R // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB  // 0-взрослый, 1-ребенок, 2-подросток
      human->KOD_DIAG   := t1->ds1
      s := right(t1->ds1,1)
      for i := 1 to 7
        pole := "t1->DS2"+iif(i==1, "", "_"+lstr(i))
        s += right(&pole,1)
        if !empty(&pole)
          poleh := {"KOD_DIAG2","KOD_DIAG3","KOD_DIAG4",;
                    "SOPUT_B1","SOPUT_B2","SOPUT_B3","SOPUT_B4"}[i]
          poleh := "human->"+poleh
          &poleh := &pole
        endif
      next
      human->DIAG_PLUS  := s
      human->KOMU       := 0
      human_->SMO       := kart_->smo
      human->POLIS      := kart->polis
      human->UCH_DOC    := t1->NHISTORY
      human->N_DATA     := xml2date(t1->DATE_1)
      human->K_DATA     := xml2date(t1->DATE_2)
      human->CENA := human->CENA_1 := val(t1->SUMV)
      human->OBRASHEN   := t1->ds_onk
      human_->VPOLIS    := val(t1->vpolis)
      human_->SPOLIS    := t1->SPOLIS
      human_->NPOLIS    := t1->NPOLIS
      human_->OKATO     := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
      if M1NOVOR == 0
        human_->NOVOR   := 0
        human_->DATE_R2 := ctod("")
        human_->POL2    := ""
      else
        human_->NOVOR   := val(right(t1->NOVOR,2))
        human_->DATE_R2 := stod("20"+substr(t1->NOVOR,6,2)+substr(t1->NOVOR,4,2)+substr(t1->NOVOR,2,2))
        human_->POL2    := iif(M1NOVOR==1,"М","Ж")
      endif
      human_->USL_OK    := val(t1->USL_OK)
      human_->VIDPOM    := val(t1->VIDPOM)
      human_->PROFIL    := val(t1->PROFIL)
      human_->IDSP      := val(t1->IDSP)
      human_->NPR_MO    := t1->NPR_MO
      s := '0'
      // 1 - экстренная, 2 - неотложная, 3 - плановая
      if human_->USL_OK == 1 // стационар
        s := iif(t1->FOR_POM=='1', '1', '0')
      elseif human_->USL_OK == 4 // скорая помощь
        s := iif(t1->FOR_POM=='1', '1', '0')
      endif
      human_->FORMA14   := s+"000"
      human_->KOD_DIAG0 := t1->ds0
      human_->RSLT_NEW  := val(t1->rslt)
      human_->ISHOD_NEW := val(t1->ishod)
      human_->VRACH     := lvrach
      human_->PRVS      := -prvs_V021_to_V015(t1->prvs)
      human_->OPLATA    := 0
      human_->ST_VERIFY := 0
      human_->ID_PAC    := t1->ID_PAC
      human_->ID_C      := t1->ID_C
      human_->REESTR    := mkod_reestr
      human_->REES_ZAP  := val(t1->N_ZAP)
      if human_->REES_NUM < 99
        human_->REES_NUM := human_->REES_NUM+1
      endif
      human->schet      := 0
      human_->SCHET_ZAP := 0
      human->kod_p      := chr(0)
      human->date_e     := ''
      if !empty(t1->CRIT)  // потом добавим t1->CRIT2 и онкологию
        human_2->pc3 := t1->CRIT
      endif
      if t1->SL_K == '1'
        s := lstr(int(val(t1->kod_kslp)))+","+lstr(val(t1->koef_kslp),5,2)
        if !empty(t1->kod_kslp2)
          s += ","+lstr(int(val(t1->kod_kslp2)))+","+lstr(val(t1->koef_kslp2),5,2)
        endif
        human_2->pc1 := s
      endif
      if !empty(t1->CODE_KIRO)
        human_2->pc2 := lstr(int(val(t1->CODE_KIRO)))+","+lstr(val(t1->VAL_K),5,2)
      endif
      _tip_lu := 0
      // проверяем диспансеризацию
      m1veteran := m1gruppa := m1etap := 0
      k := int(val(t1->COMENTSL))
      if eq_any(k,4,5)
        human_2->PN2 := 1
      elseif k == 20
        human->RAB_NERAB := 0
      elseif k == 10
        human->RAB_NERAB := 1
      elseif k == 14
        human->RAB_NERAB := 2
      elseif k == 21
        human->RAB_NERAB := 0 ; m1veteran := 1
      elseif k == 11
        human->RAB_NERAB := 1 ; m1veteran := 1
      endif
      if !empty(t1->DISP)
        do case
          case t1->DISP == "ДВ1" //"Первый этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
            m1etap := 1
            human->ishod := 201
            _tip_lu := TIP_LU_DVN
          case t1->DISP == "ДВ2" //"Второй этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
            m1etap := 2 // или 5
            human->ishod := 202 // или 205
            _tip_lu := TIP_LU_DVN
            mdvozrast := year(human->K_DATA) - year(human->date_r)
            /*if ascan(arr2m_vozrast_DVN,mdvozrast) > 0
              m1etap := 5
              human->ishod := 205
            elseif human->POL == "Ж" .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
              m1etap := 5
              human->ishod := 205
            endif*/
          case t1->DISP == "ОПВ" //"Профилактические медицинские осмотры взрослого населения",stod("2013-12-26")})
            m1etap := 3
            human->ishod := 203
            _tip_lu := TIP_LU_DVN
          case t1->DISP == "ДВ3" //"Первый этап диспансеризации определенных групп взрослого населения (1 раз в 2 года)",stod("2018-01-01")})
            m1etap := 4
            human->ishod := 204
            _tip_lu := TIP_LU_DVN
          case t1->DISP == "ДС1" //"Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации (состоящая из 1 этапа)",stod("2017-01-01")})
            m1etap := 1
            human->ishod := 101
            human->ZA_SMO := 1
            if between(human_->RSLT_NEW,321,325) // TIP_LU_DDS
              _tip_lu := TIP_LU_DDS
              m1gruppa := human_->RSLT_NEW - 321 + 1
            endif
          case t1->DISP == "ДС2" //"Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации  (состоящая из 2-х этапов)",stod("2017-01-01")})
            m1etap := 2
            human->ishod := 102
            human->ZA_SMO := 1
            if between(human_->RSLT_NEW,321,325) // TIP_LU_DDS
              _tip_lu := TIP_LU_DDS
              m1gruppa := human_->RSLT_NEW - 321 + 1
            endif
          case t1->DISP == "ДУ1" //"Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 1 этапа)",stod("2017-01-01")})
            m1etap := 1
            human->ishod := 101
            if between(human_->RSLT_NEW,347,351) // TIP_LU_DDSOP
              _tip_lu := TIP_LU_DDSOP
              m1gruppa := human_->RSLT_NEW - 347 + 1
            endif
          case t1->DISP == "ДУ2" //"Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 2-х этапов)",stod("2017-01-01")})
            m1etap := 2
            human->ishod := 102
            if between(human_->RSLT_NEW,347,351) // TIP_LU_DDSOP
              _tip_lu := TIP_LU_DDSOP
              m1gruppa := human_->RSLT_NEW - 347 + 1
            endif
          case t1->DISP == "ОН1" //"Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 1 этапа)",stod("2017-01-01")})
            m1etap := 1
            human->ishod := 301
            if between(human_->RSLT_NEW,332,336) // ПН - TIP_LU_PN
              _tip_lu := TIP_LU_PN
              m1gruppa := human_->RSLT_NEW - 332 + 1
            endif
          case t1->DISP == "ОН2" //"Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 2-х этапов)",stod("2017-01-01")})
            m1etap := 2
            human->ishod := 302
            if between(human_->RSLT_NEW,332,336) // ПН - TIP_LU_PN
              _tip_lu := TIP_LU_PN
              m1gruppa := human_->RSLT_NEW - 332 + 1
            endif
        endcase
      endif
      if human_->USL_OK == 4 // скорая помощь
        _tip_lu := TIP_LU_SMP
      endif
      auch_otd := ret_otd_with_lu_prof(int(val(t1->PODR)),human_->USL_OK,_tip_lu,human_->PROFIL,human_->VRACH)
      human->LPU := auch_otd[1]
      human->OTD := auch_otd[2]
      //if human->LPU == 6 .and. human->OTD == 25 // специально для онкологии
        //human->ishod := 98 // жидкостная цитология рака шейки матки
      //endif
      //
      for i := 1 to 3
        pole := "t1->ds3"+iif(i==1,"","_"+lstr(i))
        if !empty(&pole)
          poleh := "human_2->osl"+lstr(i)
          &poleh := &pole
        endif
      next
      if !empty(t1->VID_HMP)
        human_2->VMP    := 1
        human_2->VIDVMP := t1->VID_HMP
        human_2->METVMP := val(t1->METOD_HMP)
      endif
      if !empty(t1->VNOV_D)
        human_2->VNR  := val(t1->VNOV_D)
      endif
      if !empty(t1->VNOV_M)
        human_2->VNR1 := val(t1->VNOV_M)
      endif
      if !empty(t1->VNOV_M_2)
        human_2->VNR2 := val(t1->VNOV_M_2)
      endif
      if !empty(t1->VNOV_M_3)
        human_2->VNR3 := val(t1->VNOV_M_3)
      endif
      select HSN
      find (str(mkod,7))
      if found()
        if fl_nameismo
          G_RLock(forever)
          hsn->smo_name := t1->SMO_NAM
        else
          DeleteRec(.t.)
        endif
      else
        if fl_nameismo
          AddRec(7)
          hsn->kod := mkod
          hsn->smo_name := t1->SMO_NAM
        endif
      endif
      UnLock
      // если присутствует шифр законченного случая
      fl1 := .f.
      if t1->ED_COL == '1' .and. !empty(t1->CODE_MES1)
        fl1 := .t. ; s := t1->CODE_MES1
      elseif !empty(t1->n_ksg)
        fl1 := .t. ; s := t1->n_ksg
      endif
      if fl1
        kod_usl := foundOurUsluga(s,human->k_data,human_->profil,human->VZROS_REB)
        //
        select HU
        Add1Rec(7)
        hu->kod     := human->kod
        hu->kod_vr  := human_->VRACH
        hu->kod_as  := 0
        hu->u_koef  := 1
        hu->u_kod   := kod_usl
        hu->u_cena  := val(t1->TARIF)
        hu->is_edit := 0
        hu->date_u  := dtoc4(human->N_DATA)
        hu->otd     := human->OTD
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := human->CENA_1
        select HU_
        do while hu_->(lastrec()) < hu->(recno())
          APPEND BLANK
        enddo
        goto (hu->(recno()))
        G_RLock(forever)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
        hu_->date_u2 := dtoc4(human->K_DATA)
        hu_->PROFIL := val(t1->PROFIL)
        hu_->PRVS   := -prvs_V021_to_V015(t1->PRVS)
        hu_->kod_diag := t1->ds1
        UNLOCK
      endif
      // остальные услуги
      select T2
      find (t1->IDCASE)
      do while t1->IDCASE == t2->IDCASE .and. !eof()
        lvrach := 0 ; n := prvs_V021_to_V015(t2->PRVS)
        if len(alltrim(t2->CODE_MD)) == 11
          lvrach := ret_perso_with_tab_nom(t2->CODE_MD,n)
          if empty(lvrach) .and. !flag_is_lu
            select PERSO
            AddRecN()
            lvrach := perso->kod := recno()
            perso->tab_nom := recno()
            perso->fio  := "Сотрудник с кодом "+lstr(lvrach)
            perso->uch  := p_lpu
            perso->otd  := p_otd
            perso->prvs_new := n
            perso->snils := t2->CODE_MD
            UnLock
          endif
        endif
        if empty(lvrach) .and. !empty(human_->VRACH)
          lvrach := human_->VRACH
        endif
        //
        kod_usl := kod_uslf := 0
        if len(alltrim(t2->CODE_USL)) > 9
          select MOSU
          set order to 3 // по шифру ФФОМС
          find (padr(t2->CODE_USL,20))
          if found()
            kod_uslf := mosu->kod
          else
            select LUSLF
            find (padr(t2->CODE_USL,20))
            if found()
              select MOSU
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              kod_uslf := mosu->kod := recno()
              mosu->name := luslf->name
              mosu->shifr1 := t2->CODE_USL
              mosu->PROFIL := val(t2->PROFIL)
              UnLock
            endif
          endif
          if !empty(kod_uslf)
            select MOHU
            Add1Rec(7)
            mohu->kod     := human->kod
            mohu->kod_vr  := lvrach
            mohu->kod_as  := 0
            mohu->u_kod   := kod_uslf
            mohu->u_cena  := 0
            mohu->date_u  := dtoc4(xml2date(t2->DATE_IN))
            mohu->otd     := human->OTD
            mohu->kol_1   := val(t2->KOL_USL)
            mohu->stoim_1 := 0
            mohu->ID_U    := t2->ID_U
            mohu->PROFIL  := val(t2->PROFIL)
            mohu->PRVS    := -prvs_V021_to_V015(t2->PRVS)
            mohu->kod_diag := t2->ds
            UNLOCK
          endif
        endif
        if empty(kod_uslf) .and. !eq_any(t2->p_otk,'1','2')
          kod_usl := foundOurUsluga(t2->CODE_USL,human->k_data,val(t2->PROFIL),human->VZROS_REB)
          select HU
          Add1Rec(7)
          hu->kod     := human->kod
          hu->kod_vr  := lvrach
          hu->kod_as  := 0
          hu->u_koef  := 1
          hu->u_kod   := kod_usl
          hu->u_cena  := val(t2->TARIF)
          hu->is_edit := 0
          hu->date_u  := dtoc4(xml2date(t2->DATE_IN))
          hu->otd     := human->OTD
          hu->kol := hu->kol_1 := val(t2->KOL_USL)
          hu->stoim := hu->stoim_1 := val(t2->SUMV_USL)
          if human_->USL_OK == 3
            if t2->PODR == '0' .and. hu->KOL_RCP >= 0
              hu->KOL_RCP := -1 // на дому
            endif
            if !(alltrim(t2->CODE_USL) == "4.20.2")
              if (j := ascan({'125901','805965','103001'},t2->LPU)) > 0
                hu->is_edit := j
              endif
            endif
          endif
          select HU_
          do while hu_->(lastrec()) < hu->(recno())
            APPEND BLANK
          enddo
          goto (hu->(recno()))
          G_RLock(forever)
          hu_->ID_U := t2->ID_U
          hu_->date_u2 := dtoc4(xml2date(t2->DATE_OUT))
          hu_->PROFIL := val(t2->PROFIL)
          hu_->PRVS   := -prvs_V021_to_V015(t2->PRVS)
          hu_->kod_diag := t2->ds
          UNLOCK
        endif
        select T2
        skip
      enddo
    endif
    //
    select RHUM
    append blank
    rhum->REESTR := mkod_reestr
    rhum->KOD_HUM := human->kod
    rhum->REES_ZAP := human_->REES_ZAP
    UnLock
  else
    fl := .f.
    strfile(mname_xml+": не найден пациент в T3 "+t1->ID_PAC+hb_eol(),cImportProtokol,.t.)
  endif
  if pkol % 2000 == 0
    commit
  endif
  select T1
  skip
enddo
select REES
G_RLock(forever)
rees->KOL := pkol
close databases
return fl

***** 11.04.19 перезаписать лист учёта, если таковой уже есть в БД
Function f3_create_main_base_from_reestrs()
Local i, j, k, arr_hu, ta, arr_ne, fl
select KART
G_RLock(forever)
if !empty(mfio)
  kart->FIO := mFIO
endif
if !empty(mdate_r)
  kart->DATE_R := mdate_r
endif
m1VZROS_REB := M1NOVOR := 0
fv_date_r()
kart->pol       := mpol
kart->VZROS_REB := m1VZROS_REB
kart->POLIS     := mpolis
kart->snils     := charrem("- ",t3->SNILS)
if TwoWordFamImOt(afio[1]) .or. TwoWordFamImOt(afio[2]) .or. TwoWordFamImOt(afio[3])
  kart->MEST_INOG := 9
else
  kart->MEST_INOG := 0
endif
select KART_
do while kart_->(lastrec()) < lkod_k
  APPEND BLANK
enddo
goto (lkod_k)
G_RLock(forever)
kart_->VPOLIS := val(t1->vpolis)
kart_->SPOLIS := t1->SPOLIS
kart_->NPOLIS := t1->NPOLIS
kart_->SMO    := t1->smo
kart_->vid_ud := val(t3->DOCTYPE)
kart_->ser_ud := t3->DOCSER
kart_->nom_ud := t3->DOCNUM
kart_->mesto_r:= t3->MR
kart_->okatog := t3->OKATOG
kart_->okatop := iif(t3->OKATOG == t3->OKATOP, "", t3->OKATOP)
kart_->KVARTAL_D := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
//
select KFIO
find (str(lkod_k,7))
if found()
  if kart->MEST_INOG == 9
    G_RLock(forever)
    kfio->FAM := afio[1]
    kfio->IM  := afio[2]
    kfio->OT  := afio[3]
  else
    DeleteRec(.t.)
  endif
else
  if kart->MEST_INOG == 9
    AddRec(7)
    kfio->kod := lkod_k
    kfio->FAM := afio[1]
    kfio->IM  := afio[2]
    kfio->OT  := afio[3]
  endif
endif
//
fl_nameismo := (empty(t1->SMO) .and. !empty(t1->SMO_NAM))
if fl_nameismo
  kart_->SMO := "34"
endif
select KSN
find (str(lkod_k,7))
if found()
  if fl_nameismo
    G_RLock(forever)
    ksn->smo_name := t1->SMO_NAM
  else
    DeleteRec(.t.)
  endif
else
  if fl_nameismo
    AddRec(7)
    ksn->kod := lkod_k
    ksn->smo_name := t1->SMO_NAM
  endif
endif
UnLock
//
lvrach := human_->VRACH ; n := prvs_V021_to_V015(t1->PRVS)
if empty(lvrach) .and. len(alltrim(t1->IDDOKT)) == 11
  lvrach := ret_perso_with_tab_nom(t1->IDDOKT,n)
  if empty(lvrach) .and. !flag_is_lu
    select PERSO
    AddRecN()
    lvrach := perso->kod := recno()
    perso->tab_nom := recno()
    perso->fio  := "Сотрудник с кодом "+lstr(lvrach)
    perso->uch  := human->LPU
    perso->otd  := human->OTD
    perso->prvs_new := n
    perso->snils := t1->IDDOKT
    UnLock
  endif
endif
//
mDATE_R2 := ctod("")
if (M1NOVOR := int(val(left(t1->NOVOR,1)))) > 0
  mDATE_R2 := mdate_r
endif
fv_date_r(xml2date(t1->DATE_1))
//
select HUMAN
G_RLock(forever)
//
select HUMAN_
do while human_->(lastrec()) < mkod
  APPEND BLANK
enddo
goto (mkod)
G_RLock(forever)
//
select HUMAN_2
do while human_2->(lastrec()) < mkod
  APPEND BLANK
enddo
goto (mkod)
G_RLock(forever)
//
human->kod_k     := lkod_k
human->TIP_H     := B_STANDART
human->FIO       := kart->FIO    // Ф.И.О. больного
human->POL       := kart->POL    // пол
human->DATE_R    := kart->DATE_R // дата рождения больного
human->VZROS_REB := M1VZROS_REB  // 0-взрослый, 1-ребенок, 2-подросток
human->KOD_DIAG  := t1->ds1
s := right(t1->ds1,1)
for i := 1 to 7
  pole := "t1->DS2"+iif(i==1, "", "_"+lstr(i))
  s += right(&pole,1)
  if !empty(&pole)
    poleh := {"KOD_DIAG2","KOD_DIAG3","KOD_DIAG4","SOPUT_B1","SOPUT_B2","SOPUT_B3","SOPUT_B4"}[i]
    poleh := "human->"+poleh
    &poleh := &pole
  endif
next
human->DIAG_PLUS := s
human->KOMU      := 0
human_->SMO      := kart_->smo
human->POLIS     := kart->polis
if empty(human->LPU)
  human->LPU := p_lpu
endif
if empty(human->OTD)
  human->OTD := p_otd
endif
human->UCH_DOC := t1->NHISTORY
human->N_DATA  := xml2date(t1->DATE_1)
human->K_DATA  := xml2date(t1->DATE_2)
human_->VPOLIS := val(t1->vpolis)
human_->SPOLIS := t1->SPOLIS
human_->NPOLIS := t1->NPOLIS
human_->OKATO  := t1->SMO_OK // ОКАТО субъекта РФ территории страхования
human->CENA := human->CENA_1 := val(t1->SUMV)
human->OBRASHEN := t1->DS_ONK
if M1NOVOR == 0
  human_->NOVOR   := 0
  human_->DATE_R2 := ctod("")
  human_->POL2    := ""
else
  human_->NOVOR   := val(right(t1->NOVOR,2))
  human_->DATE_R2 := stod("20"+substr(t1->NOVOR,6,2)+substr(t1->NOVOR,4,2)+substr(t1->NOVOR,2,2))
  human_->POL2    := iif(M1NOVOR==1,"М","Ж")
endif
human_->USL_OK := val(t1->USL_OK)
human_->VIDPOM := val(t1->VIDPOM)
human_->PROFIL := val(t1->PROFIL)
human_->IDSP   := val(t1->IDSP)
human_->NPR_MO := t1->NPR_MO
s := '0'
// 1 - экстренная, 2 - неотложная, 3 - плановая
if human_->USL_OK == 1 // стационар
  s := iif(t1->FOR_POM=='1', '1', '0')
elseif human_->USL_OK == 4 // скорая помощь
  s := iif(t1->FOR_POM=='1', '1', '0')
endif
human_->FORMA14   := s+"000"
human_->KOD_DIAG0 := t1->ds0
human_->RSLT_NEW  := val(t1->rslt)
human_->ISHOD_NEW := val(t1->ishod)
human_->VRACH     := lvrach
human_->PRVS      := -prvs_V021_to_V015(t1->prvs)
human_->OPLATA    := 0
human_->ST_VERIFY := 0
human_->ID_PAC    := t1->ID_PAC
//human_->ID_C := t1->ID_C // данное поле заполнено - по нему искали
human_->REESTR    := mkod_reestr
human_->REES_ZAP  := val(t1->N_ZAP) //val(t1->IDCASE)
if human_->REES_NUM < 99
  human_->REES_NUM := human_->REES_NUM+1
endif
human->schet      := 0
human_->SCHET_ZAP := 0
if !empty(t1->CRIT)  // потом добавим t1->CRIT2 и онкологию
  human_2->pc3 := t1->CRIT
endif
if t1->SL_K == '1'
  s := lstr(int(val(t1->kod_kslp)))+","+lstr(val(t1->koef_kslp),5,2)
  if !empty(t1->kod_kslp2)
    s += ","+lstr(int(val(t1->kod_kslp2)))+","+lstr(val(t1->koef_kslp2),5,2)
  endif
  human_2->pc1 := s
endif
if !empty(t1->CODE_KIRO)
  human_2->pc2 := lstr(int(val(t1->CODE_KIRO)))+","+lstr(val(t1->VAL_K),5,2)
endif
//human->kod_p  := chr(0) // данное поле заполнено
//human->date_e := ''     // данное поле заполнено
// проверяем диспансеризацию
m1veteran := m1gruppa := m1etap := 0
k := int(val(t1->COMENTSL))
if eq_any(k,4,5)
  human_2->PN2 := 1
elseif k == 20
  human->RAB_NERAB := 0
elseif k == 10
  human->RAB_NERAB := 1
elseif k == 14
  human->RAB_NERAB := 2
elseif k == 21
  human->RAB_NERAB := 0 ; m1veteran := 1
elseif k == 11
  human->RAB_NERAB := 1 ; m1veteran := 1
endif
if !empty(t1->DISP)
  do case
    case t1->DISP == "ДВ1" //"Первый этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
      m1etap := 1
      human->ishod := 201
      _tip_lu := TIP_LU_DVN
    case t1->DISP == "ДВ2" //"Второй этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
      m1etap := 2 // или 5
      human->ishod := 202 // или 205
      _tip_lu := TIP_LU_DVN
      mdvozrast := year(human->K_DATA) - year(human->date_r)
      /*if ascan(arr2m_vozrast_DVN,mdvozrast) > 0
        m1etap := 5
        human->ishod := 205
      elseif human->POL == "Ж" .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
        m1etap := 5
        human->ishod := 205
      endif*/
    case t1->DISP == "ОПВ" //"Профилактические медицинские осмотры взрослого населения",stod("2013-12-26")})
      m1etap := 3
      human->ishod := 203
      if between(human_->RSLT_NEW,343,345) // ДВН(проф.) - TIP_LU_DVN
        _tip_lu := TIP_LU_DVN
        m1gruppa := human_->RSLT_NEW - 343 + 1
      endif
    case t1->DISP == "ДВ3" //"Первый этап диспансеризации определенных групп взрослого населения (1 раз в 2 года)",stod("2018-01-01")})
      m1etap := 4
      human->ishod := 204
      _tip_lu := TIP_LU_DVN
    case t1->DISP == "ДС1" //"Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации (состоящая из 1 этапа)",stod("2017-01-01")})
      m1etap := 1
      human->ishod := 101
      human->ZA_SMO := 1
      if between(human_->RSLT_NEW,321,325) // TIP_LU_DDS
        _tip_lu := TIP_LU_DDS
        m1gruppa := human_->RSLT_NEW - 321 + 1
      endif
    case t1->DISP == "ДС2" //"Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации  (состоящая из 2-х этапов)",stod("2017-01-01")})
      m1etap := 2
      human->ishod := 102
      human->ZA_SMO := 1
      if between(human_->RSLT_NEW,321,325) // TIP_LU_DDS
        _tip_lu := TIP_LU_DDS
        m1gruppa := human_->RSLT_NEW - 321 + 1
      endif
    case t1->DISP == "ДУ1" //"Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 1 этапа)",stod("2017-01-01")})
      m1etap := 1
      human->ishod := 101
      if between(human_->RSLT_NEW,347,351) // TIP_LU_DDSOP
        _tip_lu := TIP_LU_DDSOP
        m1gruppa := human_->RSLT_NEW - 347 + 1
      endif
    case t1->DISP == "ДУ2" //"Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 2-х этапов)",stod("2017-01-01")})
      m1etap := 2
      human->ishod := 102
      if between(human_->RSLT_NEW,347,351) // TIP_LU_DDSOP
        _tip_lu := TIP_LU_DDSOP
        m1gruppa := human_->RSLT_NEW - 347 + 1
      endif
    case t1->DISP == "ОН1" //"Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 1 этапа)",stod("2017-01-01")})
      m1etap := 1
      human->ishod := 301
      if between(human_->RSLT_NEW,332,336) // ПН - TIP_LU_PN
        _tip_lu := TIP_LU_PN
        m1gruppa := human_->RSLT_NEW - 332 + 1
      endif
    case t1->DISP == "ОН2" //"Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 2-х этапов)",stod("2017-01-01")})
      m1etap := 2
      human->ishod := 302
      if between(human_->RSLT_NEW,332,336) // ПН - TIP_LU_PN
        _tip_lu := TIP_LU_PN
        m1gruppa := human_->RSLT_NEW - 332 + 1
      endif
  endcase
endif
//
for i := 1 to 3
  pole := "t1->ds3"+iif(i==1,"","_"+lstr(i))
  if !empty(&pole)
    poleh := "human_2->osl"+lstr(i)
    &poleh := &pole
  endif
next
if !empty(t1->VID_HMP)
  human_2->VMP    := 1
  human_2->VIDVMP := t1->VID_HMP
  human_2->METVMP := val(t1->METOD_HMP)
endif
if !empty(t1->VNOV_D)
  human_2->VNR  := val(t1->VNOV_D)
endif
if !empty(t1->VNOV_M)
  human_2->VNR1 := val(t1->VNOV_M)
endif
if !empty(t1->VNOV_M_2)
  human_2->VNR2 := val(t1->VNOV_M_2)
endif
if !empty(t1->VNOV_M_3)
  human_2->VNR3 := val(t1->VNOV_M_3)
endif
select HSN
find (str(mkod,7))
if found()
  if fl_nameismo
    G_RLock(forever)
    hsn->smo_name := t1->SMO_NAM
  else
    DeleteRec(.t.)
  endif
else
  if fl_nameismo
    AddRec(7)
    hsn->kod := mkod
    hsn->smo_name := t1->SMO_NAM
  endif
endif
UnLock
//
arr_hu := {}
select HU
find (str(mkod,7))
do while hu->kod == mkod .and. !eof()
  aadd(arr_hu, {hu->(recno()),;      // номер записи
                "",;                 // занесём шифр услуги
                0,;                  // занесём номер записи по БД T2
                hu->u_kod})          // код услуги
  select HU
  skip
enddo
arr_mohu := {}
select MOHU
find (str(mkod,7))
do while mohu->kod == mkod .and. !eof()
  aadd(arr_mohu, {mohu->(recno()),;      // номер записи
                  "",;                   // занесём шифр услуги
                  0,;                    // занесём номер записи по БД T2
                  mohu->u_kod})          // код услуги
  select MOHU
  skip
enddo
arr_ne := {}
select T2
find (t1->IDCASE)
do while t1->IDCASE == t2->IDCASE .and. !eof()
  if !eq_any(t2->p_otk,'1','2') // не отказ и невозможность в диспансеризации
    fl := .t.
    for i := 1 to len(arr_hu)
      select HU
      goto (arr_hu[i,1])
      if upper(t2->ID_U) == upper(hu_->ID_U)
        arr_hu[i,2] := alltrim(t2->CODE_USL)
        arr_hu[i,3] := t2->(recno())
        fl := .f.
        exit
      endif
    next
    if fl
      for i := 1 to len(arr_mohu)
        select MOHU
        goto (arr_mohu[i,1])
        if upper(t2->ID_U) == upper(mohu->ID_U)
          arr_mohu[i,2] := alltrim(t2->CODE_USL)
          arr_mohu[i,3] := t2->(recno())
          fl := .f.
          exit
        endif
      next
    endif
    if fl
      aadd(arr_ne,t2->(recno()) ) // не найденные записи
    endif
  endif
  select T2
  skip
enddo
my_debug(,print_array(arr_mohu))
// если присутствует шифр законченного случая
fl := .f.
if t1->ED_COL == '1' .and. !empty(t1->CODE_MES1)
  fl := .t. ; s := t1->CODE_MES1
elseif !empty(t1->n_ksg)
  fl := .t. ; s := t1->n_ksg
endif
if fl
  ta := foundAllShifrTF(s,human->k_data)
  if len(ta) > 0 // попытаемся найти в массиве необходимый код услуг
    for i := 1 to len(arr_hu)
      if empty(arr_hu[i,3]) .and. ascan(ta,arr_hu[i,4]) > 0
        arr_hu[i,2] := alltrim(s)
        arr_hu[i,3] := -1
        exit
      endif
    next
  endif
  if ascan(arr_hu, {|x| x[3] < 0 }) == 0 // если не нашли
    kod_usl := foundOurUsluga(s,human->k_data,human_->profil,human->VZROS_REB)
    //
    select HU
    Add1Rec(7)
    hu->kod     := human->kod
    hu->kod_vr  := lvrach
    hu->kod_as  := 0
    hu->u_koef  := 1
    hu->u_kod   := kod_usl
    hu->u_cena  := val(t1->TARIF)
    hu->is_edit := 0
    hu->date_u  := dtoc4(human->N_DATA)
    hu->otd     := human->otd
    hu->kol := hu->kol_1 := 1
    hu->stoim := hu->stoim_1 := human->CENA_1
    select HU_
    do while hu_->(lastrec()) < hu->(recno())
      APPEND BLANK
    enddo
    goto (hu->(recno()))
    G_RLock(forever)
    hu_->ID_U := mo_guid(3,hu_->(recno()))
    hu_->date_u2 := dtoc4(human->K_DATA)
    hu_->PROFIL := val(t1->PROFIL)
    hu_->PRVS   := -prvs_V021_to_V015(t1->PRVS)
    hu_->kod_diag := t1->ds1
    UNLOCK
  endif
endif
for i := 1 to len(arr_hu)
  if empty(arr_hu[i,3]) // услуга есть в нашей БД, но нет в реестре
    select HU
    goto (arr_hu[i,1])
    DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
  else // услуга есть и в нашей БД, и в реестре
    select HU
    goto (arr_hu[i,1])
    G_RLock(forever)
    select HU_
    do while hu_->(lastrec()) < hu->(recno())
      APPEND BLANK
    enddo
    goto (hu->(recno()))
    G_RLock(forever)
    if arr_hu[i,3] < 0 // код законченного случая
      hu->u_cena  := val(t1->TARIF)
      hu->date_u  := dtoc4(human->N_DATA)
      hu->kol := hu->kol_1 := 1
      hu->stoim := hu->stoim_1 := human->CENA_1
      if empty(hu_->ID_U)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
      endif
      hu_->date_u2 := dtoc4(human->K_DATA)
      hu_->PROFIL := val(t1->PROFIL)
      hu_->PRVS   := -prvs_V021_to_V015(t1->PRVS)
      hu_->kod_diag := t1->ds1
    else
      select T2
      goto (arr_hu[i,3])
      hu->u_cena  := val(t2->TARIF)
      hu->date_u  := dtoc4(xml2date(t2->DATE_IN))
      hu->kol := hu->kol_1 := val(t2->KOL_USL)
      hu->stoim := hu->stoim_1 := val(t2->SUMV_USL)
      hu_->ID_U := t2->ID_U
      hu_->date_u2 := dtoc4(xml2date(t2->DATE_OUT))
      hu_->PROFIL := val(t2->PROFIL)
      hu_->PRVS   := -prvs_V021_to_V015(t2->PRVS)
      hu_->kod_diag := t2->ds
      if human_->USL_OK == 3
        if t2->PODR == '0' .and. hu->KOL_RCP >= 0
          hu->KOL_RCP := -1 // на дому
        endif
        if !(alltrim(arr_hu[i,2]) == "4.20.2")
          if (j := ascan({'125901','805965','103001'},t2->LPU)) > 0
            hu->is_edit := j
          endif
        endif
      endif
    endif
    if empty(hu->kod_vr)
      hu->kod_vr := human_->vrach
    endif
    hu->u_koef  := 1
    hu->is_edit := 0
    if empty(hu->otd)
      hu->otd := human->otd
    endif
    UNLOCK
  endif
next
for i := 1 to len(arr_mohu)
  if empty(arr_mohu[i,3]) // услуга есть в нашей БД, но нет в реестре
    select MOHU
    goto (arr_mohu[i,1])
    DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
  else // услуга есть и в нашей БД, и в реестре
    select MOHU
    goto (arr_mohu[i,1])
    G_RLock(forever)
    select T2
    goto (arr_mohu[i,3])
    mohu->u_cena  := val(t2->TARIF)
    mohu->date_u  := dtoc4(xml2date(t2->DATE_IN))
    mohu->kol_1 := val(t2->KOL_USL)
    mohu->stoim_1 := val(t2->SUMV_USL)
    mohu->ID_U := t2->ID_U
    mohu->date_u2 := dtoc4(xml2date(t2->DATE_OUT))
    mohu->PROFIL := val(t2->PROFIL)
    mohu->PRVS   := -prvs_V021_to_V015(t2->PRVS)
    mohu->kod_diag := t2->ds
    if empty(mohu->kod_vr)
      mohu->kod_vr := human_->vrach
    endif
    if empty(mohu->otd)
      mohu->otd := human->otd
    endif
    UNLOCK
  endif
next
// услуги, которые есть в реестре и нет в БД услуг
for i := 1 to len(arr_ne)
  select T2
  goto (arr_ne[i])
  lvrach := 0 ; n := prvs_V021_to_V015(t2->PRVS)
  if abs(human_->PRVS) == n // если спец-ть как в случае
    lvrach := human_->VRACH  // берём код врача из случая
    n := 0 // обнуляем, чтобы больше не искать врача
  endif
  if n > 0 .and. len(alltrim(t2->CODE_MD)) == 11
    lvrach := ret_perso_with_tab_nom(t2->CODE_MD,n)
    if empty(lvrach) .and. !flag_is_lu
      select PERSO
      AddRecN()
      lvrach := perso->kod := recno()
      perso->tab_nom := recno()
      perso->fio  := "Сотрудник с кодом "+lstr(lvrach)
      perso->uch  := human->uch
      perso->otd  := human->otd
      perso->prvs_new := n
      perso->snils := t2->CODE_MD
      UnLock
    endif
  endif
  //
  kod_usl := kod_uslf := 0
  if len(alltrim(t2->CODE_USL)) > 9
    select MOSU
    set order to 3 // по шифру ФФОМС
    find (padr(t2->CODE_USL,20))
    if found()
      kod_uslf := mosu->kod
    else
      select LUSLF
      find (padr(t2->CODE_USL,20))
      if found()
        select MOSU
        set order to 1
        FIND (STR(-1,6))
        if found()
          G_RLock(forever)
        else
          AddRec(6)
        endif
        kod_uslf := mosu->kod := recno()
        mosu->name := luslf->name
        mosu->shifr1 := t2->CODE_USL
        mosu->PROFIL := val(t2->PROFIL)
        UnLock
      endif
    endif
    if !empty(kod_uslf)
      select MOHU
      Add1Rec(7)
      mohu->kod     := human->kod
      mohu->kod_vr  := lvrach
      mohu->kod_as  := 0
      mohu->u_kod   := kod_uslf
      mohu->u_cena  := 0
      mohu->date_u  := dtoc4(xml2date(t2->DATE_IN))
      mohu->otd     := human->otd
      mohu->kol_1   := val(t2->KOL_USL)
      mohu->stoim_1 := 0
      mohu->ID_U    := t2->ID_U
      mohu->PROFIL  := val(t2->PROFIL)
      mohu->PRVS    := -prvs_V021_to_V015(t2->PRVS)
      mohu->kod_diag := t2->ds
      UNLOCK
    endif
  endif
  if empty(kod_uslf)
    kod_usl := foundOurUsluga(t2->CODE_USL,human->k_data,val(t2->PROFIL),human->VZROS_REB)
    select HU
    Add1Rec(7)
    hu->kod     := human->kod
    hu->kod_vr  := lvrach
    hu->kod_as  := 0
    hu->u_koef  := 1
    hu->u_kod   := kod_usl
    hu->u_cena  := val(t2->TARIF)
    hu->is_edit := 0
    hu->date_u  := dtoc4(xml2date(t2->DATE_IN))
    hu->otd     := human->otd
    hu->kol := hu->kol_1 := val(t2->KOL_USL)
    hu->stoim := hu->stoim_1 := val(t2->SUMV_USL)
    select HU_
    do while hu_->(lastrec()) < hu->(recno())
      APPEND BLANK
    enddo
    goto (hu->(recno()))
    G_RLock(forever)
    hu_->ID_U := t2->ID_U
    hu_->date_u2 := dtoc4(xml2date(t2->DATE_OUT))
    hu_->PROFIL := val(t2->PROFIL)
    hu_->PRVS   := -prvs_V021_to_V015(t2->PRVS)
    hu_->kod_diag := t2->ds
    UNLOCK
  endif
next
return NIL

***** 10.04.19 поискать врача по СНИЛС и, м.б., по специальности
Function ret_perso_with_tab_nom(lsnils,lprvs)
Static aprvs
Local i, j, lvrach := 0
DEFAULT aprvs TO ret_arr_new_olds_prvs() // массив соответствий специальности V015 специальностям V004
select PERSO
set order to 1
find (padr(lsnils,11)+str(lprvs,4)) // ищем по коду специальности V015
if found()
  lvrach := perso->kod
elseif (j := ascan(aprvs,{|x| x[1] == lprvs })) > 0
  set order to 2
  for i := 1 to len(aprvs[j,2])
    find (padr(lsnils,11)+str(aprvs[j,2,i],9))  // ищем по коду старой специальности
    if found()
      lvrach := perso->kod
      exit
    endif
  next
endif
if empty(lvrach)
  find (padr(lsnils,11))  // ищем просто по СНИЛС
  if found()
    lvrach := perso->kod
  endif
endif
return lvrach

***** 10.04.19 поискать отделение по типу л/у (и м.б.по профилю) (и м.б. по врачу)
Static Function ret_otd_with_lu_prof(lpodr,lump,llu,lprof,lvrach)
// lpodr  - код подразделения
// lump   - условия оказания мед.помощи
// llu    - тип листа учёта
// lprof  - профиль
// lvrach - врач
Static such_otd := {1,2} // для Калачевской ЦРБ
Local uch_otd := {0,0}
select OTD
if llu > 0
  set order to 1
  find (str(llu,2))
  if found()
    uch_otd := {otd->kod_lpu,otd->kod}
  endif
elseif lpodr > 0
  set order to 3
  find (str(lpodr,3)+str(lump,2))
  if found()
    uch_otd := {otd->kod_lpu,otd->kod}
  else
    find (str(lpodr,3))
    if found()
      uch_otd := {otd->kod_lpu,otd->kod}
    endif
  endif
elseif lvrach > 0 // в справочнике персонала стоит учреждение + отделение
  perso->(dbGoto(lvrach))
  if emptyany(perso->uch,perso->otd)
    if lprof > 0
      select OTD
      set order to 2
      find (str(lprof,3)+str(lump,2))
      if found()
        uch_otd := {otd->kod_lpu,otd->kod}
      else
        find (str(lprof,3))
        if found()
          uch_otd := {otd->kod_lpu,otd->kod}
        endif
      endif
    endif
  else
    uch_otd := {perso->uch,perso->otd}
  endif
elseif lprof > 0
  set order to 2
  find (str(lprof,3)+str(lump,2))
  if found()
    uch_otd := {otd->kod_lpu,otd->kod}
  else
    find (str(lprof,3))
    if found()
      uch_otd := {otd->kod_lpu,otd->kod}
    endif
  endif
endif
if emptyany(uch_otd[1],uch_otd[2])
  uch_otd := aclone(such_otd)
endif
return uch_otd

***** 23.10.19 Изменение цен на услуги в соответствии со справочником услуг ТФОМС
Function Change_Cena_OMS()
Local buf := save_maxrow(), lshifr1, fl, lrec, rec_human, k_data2, kod_ksg, begin_date := addmonth(sys_date,-3)
if begin_date < boy(begin_date)
  begin_date := boy(begin_date)
endif
n_message({"Данный режим предназначен для изменения цен на услуги",;
           "и суммы случаев в листах учёта, которые не включены",;
           "в реестры (счета), на цены из справочника услуг ТФОМС.",;
           "ВНИМАНИЕ !!!",;
           "Во время выполнения данной операции",;
           "никто не должен работать в задаче ОМС."},,;
           "GR+/R","W+/R",,,"G+/R")
if f_Esc_Enter("изменения цен",.t.) .and. mo_Lock_Task(X_OMS)
  mywait()
  fl := .t.
  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  BEGIN SEQUENCE
    R_Use(dir_server+"human")
    index on str(schet,6)+str(tip_h,1)+upper(substr(fio,1,20)) to (dir_server+"humans") progress
    Use
    R_Use(dir_server+"human_u")
    index on str(kod,7)+date_u to (dir_server+"human_u") progress
    Use
  RECOVER USING error
    fl := func_error(10,"Возникла непредвиденная ошибка при переиндексировании!")
  END
  ERRORBLOCK(bSaveHandler)
  close databases
  if fl
    WaitStatus()
    use_base("lusl")
    use_base("luslc")
    use_base("luslf")
    Use_base("mo_su")
    set order to 0
    G_Use(dir_server+"uslugi",{dir_server+"uslugish",;
                               dir_server+"uslugi"},"USL")
    set order to 0
    Use_base("mo_hu")
    R_Use(dir_server+"mo_otd",,"OTD")
    R_Use(dir_server+"mo_uch",,"UCH")
    G_Use(dir_server+"human_u",dir_server+"human_u","HU")
    G_Use(dir_server+"human_2",,"HUMAN_2")
    G_Use(dir_server+"human_",,"HUMAN_")
    G_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_, to recno() into HUMAN_2
    sm_human := i_human := 0
    find (str(0,6))
    do while human->schet == 0 .and. !eof()
      // цикл по людям
      UpdateStatus()
      k_data2 := human->k_data
      if human->ishod == 88
        rec_human := human->(recno())
        select HUMAN
        goto (human_2->pn4) // ссылка на 2-й лист учёта
        k_data2 := human->k_data // переприсваиваем дату окончания лечения
        goto (rec_human)
      endif
      if human_->reestr == 0 .and. k_data2 > begin_date
        ++sm_human
        @ maxrow(),1  say lstr(i_human) color "G+/R"
        @ row(),col() say "/" color "R+/R"
        @ row(),col() say lstr(sm_human) color "GR+/R"
        uch->(dbGoto(human->LPU))
        otd->(dbGoto(human->OTD))
        f_put_glob_podr(human_->USL_OK,human->k_data) // заполнить код подразделения
        sdial := mcena_1 := 0 ; fl := .f. ; kod_ksg := ""
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          // цикл по услугам
          usl->(dbGoto(hu->u_kod))
          mdate := c4tod(hu->date_u)
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,k_data2)
          if is_usluga_TFOMS(usl->shifr,lshifr1,k_data2)
            lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            if human_->USL_OK < 3 .and. is_ksg(lshifr)
              kod_ksg := lshifr
              lrec := hu->(recno())
            else
              lu_cena := hu->u_cena
              fl_del := fl_uslc := .f.
              v := fcena_oms(lshifr,;
                             (human->vzros_reb==0),;
                             k_data2,;
                             @fl_del,;
                             @fl_uslc)
              if fl_uslc // если нашли в справочнике ТФОМС
                lu_cena := v
              endif
              mstoim_1 := round_5(lu_cena * hu->kol_1,2)
              select HU
              if !(round(hu->u_cena,2) == round(lu_cena,2) .and. round(hu->stoim_1,2) == round(mstoim_1,2))
                G_RLock(forever)
                replace u_cena  with lu_cena, stoim with mstoim_1, stoim_1 with mstoim_1
                fl := .t.
              endif
              mcena_1 += hu->stoim_1
            endif
          endif
          select HU
          skip
        enddo
        if !empty(kod_ksg)
          if select("K006") != 0
            k006->(dbCloseArea())
          endif
          if year(human->k_data) > 2018
            arr_ksg := definition_KSG(1,k_data2)
          else
            arr_ksg := definition_KSG_18()
          endif
          fl1 := .t.
          if len(arr_ksg) == 7
            if valtype(arr_ksg[7]) == "N"
              sdial := arr_ksg[7] // для 2019 года
            else
              fl1 := .f. // для 2018 года
            endif
          endif
          if !fl1 // диализ 2018 года
            //
          elseif empty(arr_ksg[2]) // нет ошибок
            mcena_1 := arr_ksg[4]
            select HU
            goto (lrec)
            if !(round(mcena_1,2) == round(hu->u_cena,2))
              G_RLock(forever)
              replace u_cena  with mcena_1, stoim with mcena_1, stoim_1 with mcena_1
              fl := .t.
            endif
            put_str_kslp_kiro(arr_ksg)
          endif
        endif
        if fl .or. !(round(mcena_1+sdial,2) == round(human->cena_1,2))
          ++i_human
          human->(G_RLock(forever))
          human->cena := human->cena_1 := mcena_1+sdial
          human_->(G_RLock(forever))
          human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
          human_->ST_VERIFY := 0 // снова ещё не проверен
          UnLock ALL
        endif
        if sm_human % 1000 == 0
          COMMIT
        endif
      endif
      select HUMAN
      skip
    enddo
    close databases
    rest_box(buf)
    ///////////////////// ОБРАБОТКА ЗАВЕРШЕНА  //////////////////////////
    if sm_human == 0
      func_error(4,"В базе данных нет пациентов, не попавших в реестры (счета)!")
    elseif i_human == 0
      func_error(4,"Не обнаружено листов учёта с необходимостью пересчёта цен")
    else
      n_message({"Изменение цен произведено - "+lstr(i_human)+" л/у"},,"W/RB","BG+/RB",,,"G+/RB")
    endif
  endif
  mo_UnLock_Task(X_OMS)
  close databases
endif
return NIL
