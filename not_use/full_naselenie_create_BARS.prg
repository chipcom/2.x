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
  