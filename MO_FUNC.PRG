***** различные функции общего пользования - mo_func.prg
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 21.08.17
Function run_my_hrb(name_hrb,name_func)
Local x, handle, n_file := dir_exe+name_hrb+".hrb"
if hb_FileExists(n_file)
  handle := hb_hrbLoad(n_file)
  x := &(name_func)   // функция из name_hrb.hrb
  hb_hrbUnload( handle )
else
  func_error(4,"Не обнаружен файл "+n_file)
endif
Return Nil

***** 28.10.18
Function index_base(sBase)
Millisec(100)  // задержка на 0.1 с
if type("fl_open") == "L" .and. fl_open
  if !hb_FileExists(dir_server+sBase+sdbf) // если нет файла
    return NIL                             // выйти из функции
  endif
  use (dir_server+sBase) new alias __TMP__ READONLY
  if select("__TMP__") == 0
    n_message({"Неудачная попытка открытия файла базы данных",;
               upper(dir_server+sBase+sdbf),;
               "Скорее всего, данный файл занят либо другим пользователем,",;
               "либо каким-нибудь системным процессом.",;
               "Попытайтесь войти в данный режим позже или",;
               "перезагрузите компьютер (сервер) и попытайтесь снова.";
              },,"GR+/R","W+/R",,,"G+/R")
    return NIL
  endif
endif
sBase := lower(sBase)
do case
  case sBase == "s_adres"
    index on upper(name) to (dir_server+sBase)
  case sBase == "s_kemvyd"
    index on upper(substr(name,1,80)) to (dir_server+sBase)
  case sBase == "mo_pers"
    index on str(tab_nom,5) to (dir_server+sBase)
  case sBase == "mo_regi"
    index on str(tip,1) to (dir_server+"mo_regi1") progress
    index on pdate to (dir_server+"mo_regi2") progress
    index on str(kod_k,7)+pdate+ctime to (dir_server+"mo_regi3") descending progress
  case sBase == "msek"
    index on str(kod_k,7)+str(descend(date_kom),10) to (dir_server+sBase) progress
  case sBase == "slugba"
    index on str(shifr,3) to (dir_server+sBase)
  case sBase == "mo_su"
    index on str(kod,6) to (dir_server+"mo_su") progress
    index on shifr to (dir_server+"mo_sush") progress
    index on shifr1+str(tip,1) to (dir_server+"mo_sush1") progress
  case sBase == "uslugi"
    index on str(kod,4) to (dir_server+"uslugi") progress
    index on shifr to (dir_server+"uslugish") progress
    index on iif(empty(shifr1),shifr,shifr1) to (dir_server+"uslugis1") progress
    index on str(slugba,3) to (dir_server+"uslugisl") progress
  case sBase == "uslugi1"
    index on str(kod,4)+dtos(date_b) to (dir_server+"uslugi1") progress
    index on shifr1+dtos(date_b) to (dir_server+"uslugi1s") progress
  case sBase == "usl_otd"
    index on str(kod,4) to (dir_server+sBase) progress
  case sBase == "uslugi_k"
    index on shifr to (dir_server+sBase) progress
  case sBase == "uslugi1k"
    index on shifr+shifr1 to (dir_server+sBase) progress
  case sBase == "ns_usl_k"
    index on str(kod,6) to (dir_server+sBase) progress
  case sBase == "usl_uva"
    index on shifr to (dir_server+sBase) progress
  case sBase == "uch_usl"
    index on str(kod,4) to (dir_server+sBase) progress
  case sBase == "uch_usl1"
    index on str(kod,4)+dtos(date_b) to (dir_server+sBase) progress
  case sBase == "uch_pers"
    index on str(kod,4)+str(god,4)+str(mes,2) to (dir_server+sBase) progress
  case sBase == "mo_oper"
    index on pd+po+str(task,1)+str(app_edit,1) to (dir_server+sBase) progress
  case sBase == "mo_opern"
    index on pd+po+pt+tp+ae to (dir_server+sBase) progress
  case sBase == "kartotek"
    index on str(kod,7) to (dir_server+"kartotek") progress
    index on if(kod>0,"1","0")+upper(fio)+dtos(date_r) to (dir_server+"kartoten") progress
    index on if(kod>0,"1","0")+polis to (dir_server+"kartotep") progress
    index on strzero(uchast,2)+strzero(kod_vu,5) to (dir_server+"kartoteu") progress
    index on if(kod>0,"1","0")+snils to (dir_server+"kartotes") progress
    index on if(kod>0,"1","0")+kod_mis to (dir_server+"kartotee") progress
  case sBase == "k_prim1"
    index on str(kod,7)+str(stroke,1) to (dir_server+sBase) progress
  case sBase == "mo_kartp"
    index on str(kod_k,7)+dtos(d_prik) to (dir_server+sBase) progress
  case sBase == "kartdelz"
    index on str(kod,7)+str(zf,2) to (dir_server+"kartdelz") progress
  case sBase == "kart_st"
    index on str(kod,7)+str(zf,2)+date_u to (dir_server+"kart_st") progress
    index on str(tip_bd,1)+str(rec_bd,8) to (dir_server+"kart_st1") progress
  case sBase == "mo_kpred"
    index on str(kod,7)+str(nn,1) to (dir_server+sBase) progress
  case sBase == "mo_kinos"
    index on str(kod,7) to (dir_server+sBase) progress
    //
  case sBase == "mo_pp"
    index on str(kod,7) to (dir_server+"mo_pp_k") progress
    index on dtos(n_data)+n_time to (dir_server+"mo_pp_d") progress
    index on str(kod_k,7)+dtos(n_data) to (dir_server+"mo_pp_r") descending progress
    index on str(year(n_data),4)+uch_doc to (dir_server+"mo_pp_i") descending progress
    index on str(kod_h,7) to (dir_server+"mo_pp_h") progress
  case sBase == "mo_ppdia"
    index on str(kod,7)+str(tip,1) to (dir_server+sBase) progress
  case sBase == "mo_ppper"
    index on str(kod,7)+dtos(n_data) to (dir_server+sBase) progress
    //
  case sBase == "human"
    index on str(kod,7) to (dir_server+"humank") progress
    index on str(if(kod>0,kod_k,0),7)+str(tip_h,1) to (dir_server+"humankk") progress
    index on str(tip_h,1)+str(otd,3)+upper(substr(fio,1,20)) to (dir_server+"humann") progress
    index on dtos(k_data)+uch_doc to (dir_server+"humand") progress
    index on date_opl to (dir_server+"humano") progress
    index on str(schet,6)+str(tip_h,1)+upper(substr(fio,1,20)) to (dir_server+"humans") progress
  case sBase == "human_3"
    index on str(kod,7) to (dir_server+"human_3") progress
    index on str(kod2,7) to (dir_server+"human_32") progress
  case sBase == "human_u"
    index on str(kod,7)+date_u to (dir_server+"human_u") progress
    index on str(u_kod,4) to (dir_server+"human_uk") progress
    index on date_u to (dir_server+"human_ud") progress
    index on str(kod_vr,4)+date_u to (dir_server+"human_uv") progress
    index on str(kod_as,4)+date_u to (dir_server+"human_ua") progress
  case sBase == "mo_hu"
    index on str(kod,7)+date_u to (dir_server+"mo_hu") progress
    index on str(u_kod,6) to (dir_server+"mo_huk") progress
    index on date_u to (dir_server+"mo_hud") progress
    index on str(kod_vr,4)+date_u to (dir_server+"mo_huv") progress
    index on str(kod_as,4)+date_u to (dir_server+"mo_hua") progress
  case sBase == "mo_dnab"
    index on str(KOD_K,7)+KOD_DIAG to (dir_server+"mo_dnab")
  case sBase == "mo_hdisp"
    index on str(kod,7)+str(ks,2) to (dir_server+sBase) progress
  case sBase == "mo_onkna"
    index on str(kod,7) to (dir_server+sBase) progress
  case sBase == "mo_onksl"
    index on str(kod,7) to (dir_server+sBase) progress
  case sBase == "mo_onkdi"
    index on str(kod,7)+str(diag_tip,1)+str(diag_code,3) to (dir_server+sBase) progress
  case sBase == "mo_onkpr"
    index on str(kod,7)+str(prot,1) to (dir_server+sBase) progress
  case sBase == "mo_onkus"
    index on str(kod,7)+str(usl_tip,1) to (dir_server+sBase) progress
  case sBase == "mo_onkco"
    index on str(kod,7) to (dir_server+sBase) progress
  case sBase == "mo_onkle"
    index on str(kod,7)+regnum+code_sh+dtos(date_inj) to (dir_server+sBase) progress
  case sBase == "humanst"
    index on str(tip_bd,1)+str(rec_bd,8) to (dir_server+sBase) progress
  case sBase == "mo_refr"
    index on str(tipd,1)+str(kodd,6)+str(tipz,1)+str(kodz,8) to (dir_server+sBase) progress
  case sBase == "schet"
    index on str(kod,6) to (dir_server+"schetk") progress
    index on nomer_s+pdate to (dir_server+"schetn") progress
    index on str(komu,1)+str(str_crb,2)+nomer_s to (dir_server+"schetp") progress
    index on pdate+nomer_s to (dir_server+"schetd") progress
    //
  case sBase == "plat_ms"
    index on str(tip,1)+str(tab_nom,5) to (dir_server+sBase) progress
  case sBase == "plat_vz"
    index on str(tip,1)+str(pr_smo,6)+str(kod_k,7)+dtos(date_opl) to (dir_server+sBase) descending progress
  case sBase == "hum_p"
    index on str(kod_k,7)+dtos(k_data)+str(KV_CIA,6) to (dir_server+"hum_pkk") descending progress
    index on str(otd,3) to (dir_server+"hum_pn") progress
    index on dtos(k_data) to (dir_server+"hum_pd") progress
    index on str(n_kvit,5) to (dir_server+"hum_pv") progress
    index on str(tip_usl,1)+iif(empty(date_close),"0"+dtos(k_data),"1"+dtos(date_close))+;
                                              dtos(k_data) to (dir_server+"hum_pc") progress
  case sBase == "hum_p_u"
    index on str(kod,7) to (dir_server+"hum_p_u") progress
    index on str(u_kod,4) to (dir_server+"hum_p_uk") progress
    index on date_u to (dir_server+"hum_p_ud") progress
    index on str(kod_vr,4)+date_u to (dir_server+"hum_p_uv") progress
    index on str(kod_as,4)+date_u to (dir_server+"hum_p_ua") progress
  case sBase == "hum_plat"
    index on str(kod,7) to (dir_server+sBase) progress
  case sBase == "payments"
    index on str(IDCONTR,7) to (dir_server+'payments') progress
    index on dtos(DATE) to (dir_server+'payments_date') progress
    index on str(TYPEPAYER,1)+str(IDPAYER,7) to (dir_server+'payments_payer') progress
  case sBase == "payer"
    index on upper(NAME) to (dir_server+sBase) progress
  case sBase == "pu_date"
    index on dtos(data) to (dir_server+sBase) descending
  case sBase == "pu_cena"
    index on str(kod_date,4)+str(kod_usl,4) to (dir_server+"pu_cena") progress
    index on str(kod_usl,4)+str(kod_date,4) to (dir_server+"pu_cenau") progress
    //
  case sBase == "diag_ort"
    index on shifr to (dir_server+sBase)
  case sBase == "orto_uva"
    index on shifr to (dir_server+sBase)
  case sBase == "hum_ort"
    index on str(kod_k,7)+dtos(data) to (dir_server+"hum_ortk") descending progress
    index on str(nar_z,5) to (dir_server+"hum_ortn") progress
    index on dtos(k_data) to (dir_server+"hum_ortd") progress
    index on dtos(data) to (dir_server+"hum_orto") progress
  case sBase == "hum_oro"
    index on str(kod,7)+pdate to (dir_server+"hum_oro") progress
    index on str(n_kvit,5) to (dir_server+"hum_orov") progress
    index on pdate to (dir_server+"hum_orod") progress
  case sBase == "hum_oru"
    index on str(kod,7) to (dir_server+"hum_oru") progress
    index on str(u_kod,4) to (dir_server+"hum_oruk") progress
    index on date_u to (dir_server+"hum_orud") progress
    index on str(kod_vr,4)+date_u to (dir_server+"hum_oruv") progress
    index on str(kod_as,4)+date_u to (dir_server+"hum_orua") progress
  case sBase == "hum_orpl"
    index on str(kod,7) to (dir_server+sBase) progress
  case sBase == "ortoped2"
    index on str(kod_tip,4) to (dir_server+sBase) progress
    //
  case sBase == "kas_pl"
    index on str(kod_k,7)+dtos(k_data)+str(n_chek,8) to (dir_server+"kas_pl1") descending progress
    index on dtos(k_data) to (dir_server+"kas_pl2") progress
    index on str(n_chek,8) to (dir_server+"kas_pl3") progress
  case sBase == "kas_pl_u"
    index on str(kod,7) to (dir_server+"kas_pl1u") progress
    index on str(u_kod,4) to (dir_server+"kas_pl2u") progress
  case sBase == "kas_ort"
    index on str(kod_k,7)+dtos(k_data)+str(nomer_n,6) to (dir_server+"kas_ort1") descending progress
    index on dtos(k_data) to (dir_server+"kas_ort2") progress
    index on str(n_chek,8) to (dir_server+"kas_ort3") progress
    index on str(year_n,4)+str(nomer_n,6) to (dir_server+"kas_ort4") progress
    index on str(vid,1)+dtos(k_data) to (dir_server+"kas_ort5") progress
  case sBase == "kas_ortu"
    index on str(kod,7)+str(vid,1) to (dir_server+"kas_or1u") progress
    index on str(u_kod,4) to (dir_server+"kas_or2u") progress
    //
  case sBase == "mo_kekh"
    index on str(kod_lu,7) to (dir_server+sBase) progress
  case sBase == "mo_keke"
    index on str(kod,7)+str(tip_eks,1) to (dir_server+"mo_keket") progress
    index on str(kod_eks,3)+dtos(date_eks) to (dir_server+"mo_kekee") descending progress
    index on dtos(date_eks) to (dir_server+"mo_keked") progress
  case sBase == "mo_kekez"
    index on str(kod,7)+str(stroke,2) to (dir_server+sBase) progress
endcase
if type("fl_open") == "L" .and. fl_open
  __tmp__->(dbCloseArea())
endif
return NIL

***** 31.01.17
Function R_Use_base(sBase,lalias)
return use_base(sBase,lalias,,.t.)

***** 28.10.18
Function use_base(sBase,lalias,lExcluUse,lREADONLY)
Local fl := .t., sind1, sind2
sBase := lower(sBase)
do case
  case sBase == "organiz"
    DEFAULT lalias TO "ORG"
    fl := G_Use(dir_server+"organiz",,lalias,,lExcluUse,lREADONLY)
  case sBase == "komitet"
    if (fl := G_Use(dir_server+"komitet",,lalias,,lExcluUse,lREADONLY))
      index on str(kod,2) to (cur_dir+"tmp_komi")
    endif
  case sBase == "str_komp"
    if (fl := G_Use(dir_server+"str_komp",,lalias,,lExcluUse,lREADONLY))
      index on str(kod,2) to (cur_dir+"tmp_strk")
    endif
  case sBase == "mo_pers"
    DEFAULT lalias TO "P2"
    fl := G_Use(dir_server+"mo_pers",dir_server+"mo_pers",lalias,,lExcluUse,lREADONLY)
  case sBase == "mo_su"
    DEFAULT lalias TO "MOSU"
    fl := G_Use(dir_server+"mo_su",{dir_server+"mo_su",;
                                    dir_server+"mo_sush",;
                                    dir_server+"mo_sush1"},lalias,,lExcluUse,lREADONLY)
  case sBase == "uslugi"
    DEFAULT lalias TO "USL"
    fl := G_Use(dir_server+"uslugi",{dir_server+"uslugi",;
                                     dir_server+"uslugish",;
                                     dir_server+"uslugis1",;
                                     dir_server+"uslugisl"},lalias,,lExcluUse,lREADONLY)
  case sBase == "kartotek"
    fl := G_Use(dir_server+"kartote_",,"KART_",,lExcluUse,lREADONLY) .and. ;
          G_Use(dir_server+"kartote2",,"KART2",,lExcluUse,lREADONLY) .and. ;
          G_Use(dir_server+"kartotek",{dir_server+"kartotek",;
                                       dir_server+"kartoten",;
                                       dir_server+"kartotep",;
                                       dir_server+"kartoteu",;
                                       dir_server+"kartotes",;
                                       dir_server+"kartotee"},"KART",,lExcluUse,lREADONLY)
    if fl
      set relation to recno() into KART_, to recno() into KART2
    endif
  case sBase == "human"
    DEFAULT lalias TO "HUMAN"
    fl := G_Use(dir_server+"human_",,"HUMAN_",,lExcluUse,lREADONLY) .and. ;
          G_Use(dir_server+"human_2",,"HUMAN_2",,lExcluUse,lREADONLY) .and. ;
          G_Use(dir_server+"human",{dir_server+"humank",;
                                    dir_server+"humankk",;
                                    dir_server+"humann",;
                                    dir_server+"humand",;
                                    dir_server+"humano",;
                                    dir_server+"humans"},lalias,,lExcluUse,lREADONLY)
    if fl
      set relation to recno() into HUMAN_, to recno() into HUMAN_2
    endif
  case sBase == "human_u"
    DEFAULT lalias TO "HU"
    fl := G_Use(dir_server+"human_u_",,"HU_",,lExcluUse,lREADONLY) .and. ;
          G_Use(dir_server+"human_u",{dir_server+"human_u",;
                                      dir_server+"human_uk",;
                                      dir_server+"human_ud",;
                                      dir_server+"human_uv",;
                                      dir_server+"human_ua"},lalias,,lExcluUse,lREADONLY)
    if fl
      set relation to recno() into HU_
    endif
  case sBase == "mo_hu"
    DEFAULT lalias TO "MOHU"
    fl := G_Use(dir_server+"mo_hu",{dir_server+"mo_hu",;
                                    dir_server+"mo_huk",;
                                    dir_server+"mo_hud",;
                                    dir_server+"mo_huv",;
                                    dir_server+"mo_hua"},lalias,,lExcluUse,lREADONLY)
  case sBase == "mo_dnab"
    DEFAULT lalias TO "DN"
    fl := G_Use(dir_server+"mo_dnab",dir_server+"mo_dnab",lalias,,lExcluUse,lREADONLY)
  case sBase == "mo_hdisp"
    DEFAULT lalias TO "HDISP"
    fl := G_Use(dir_server+"mo_hdisp",dir_server+"mo_hdisp",lalias,,lExcluUse,lREADONLY)
  case sBase == "schet"
    DEFAULT lalias TO "SCHET"
    fl := G_Use(dir_server+"schet_",,"SCHET_",,lExcluUse,lREADONLY) .and. ;
          G_Use(dir_server+"schet",{dir_server+"schetk",;
                                    dir_server+"schetn",;
                                    dir_server+"schetp",;
                                    dir_server+"schetd"},lalias,,lExcluUse,lREADONLY)
    if fl
      set relation to recno() into SCHET_
    endif
  case sBase == "kartdelz"
    fl := G_Use(dir_server+"kartdelz",dir_server+"kartdelz",,,lExcluUse,lREADONLY)
  case sBase == "kart_st"
    fl := G_Use(dir_server+"kart_st",{dir_server+"kart_st",;
                                      dir_server+"kart_st1"},,,lExcluUse,lREADONLY)
  case sBase == "humanst"
    fl := G_Use(dir_server+"humanst",dir_server+"humanst",,,lExcluUse,lREADONLY)
  case sBase == "mo_pp"
    DEFAULT lalias TO "HU"
    fl := G_Use(dir_server+"mo_pp",{dir_server+"mo_pp_k",;
                                    dir_server+"mo_pp_d",;
                                    dir_server+"mo_pp_r",;
                                    dir_server+"mo_pp_i",;
                                    dir_server+"mo_pp_h"},lalias,,lExcluUse,lREADONLY)
  case sBase == "hum_p"
    DEFAULT lalias TO "HU"
    fl := G_Use(dir_server+"hum_p",{dir_server+"hum_pkk",;
                                    dir_server+"hum_pn",;
                                    dir_server+"hum_pd",;
                                    dir_server+"hum_pv",;
                                    dir_server+"hum_pc"},lalias,,lExcluUse,lREADONLY)
  case sBase == "hum_p_u"
    DEFAULT lalias TO "HU"
    fl := G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                                      dir_server+"hum_p_uk",;
                                      dir_server+"hum_p_ud",;
                                      dir_server+"hum_p_uv",;
                                      dir_server+"hum_p_ua"},lalias,,lExcluUse,lREADONLY)
  case sBase == "hum_ort"
    fl := G_Use(dir_server+"hum_ort",{dir_server+"hum_ortk",;
                                      dir_server+"hum_ortn",;
                                      dir_server+"hum_ortd",;
                                      dir_server+"hum_orto"},"HUMAN",,lExcluUse,lREADONLY)
  case sBase == "hum_oru"
    fl := G_Use(dir_server+"hum_oru",{dir_server+"hum_oru",;
                                      dir_server+"hum_oruk",;
                                      dir_server+"hum_orud",;
                                      dir_server+"hum_oruv",;
                                      dir_server+"hum_orua"},"HU",,lExcluUse,lREADONLY)
  case sBase == "hum_oro"
    fl := G_Use(dir_server+"hum_oro",{dir_server+"hum_oro",;
                                      dir_server+"hum_orov",;
                                      dir_server+"hum_orod"},"HO",,lExcluUse,lREADONLY)
  case sBase == "kas_pl"
    fl := G_Use(dir_server+"kas_pl",{dir_server+"kas_pl1",;
                                     dir_server+"kas_pl2",;
                                     dir_server+"kas_pl3"},lalias,,lExcluUse,lREADONLY)
  case sBase == "kas_pl_u"
    fl := G_Use(dir_server+"kas_pl_u",{dir_server+"kas_pl1u",;
                                       dir_server+"kas_pl2u"},lalias,,lExcluUse,lREADONLY)
  case sBase == "kas_ort"
    fl := G_Use(dir_server+"kas_ort",{dir_server+"kas_ort1",;
                                      dir_server+"kas_ort2",;
                                      dir_server+"kas_ort3",;
                                      dir_server+"kas_ort4",;
                                      dir_server+"kas_ort5"},lalias,,lExcluUse,lREADONLY)
  case sBase == "kas_ortu"
    fl := G_Use(dir_server+"kas_ortu",{dir_server+"kas_or1u",;
                                       dir_server+"kas_or2u"},lalias,,lExcluUse,lREADONLY)
  case sBase == "mo_kekh"
    DEFAULT lalias TO "HU"
    fl := G_Use(dir_server+"mo_kekh",dir_server+"mo_kekh",lalias,,lExcluUse,lREADONLY)
  case sBase == "mo_keke"
    DEFAULT lalias TO "EKS"
    fl := G_Use(dir_server+"mo_keke",{dir_server+"mo_keket",;
                                      dir_server+"mo_kekee",;
                                      dir_server+"mo_keked"},lalias,,lExcluUse,lREADONLY)
  case sBase == "mo_kekez"
    DEFAULT lalias TO "EKSZ"
    fl := G_Use(dir_server+"mo_kekez",dir_server+"mo_kekez",lalias,,lExcluUse,lREADONLY)
  case sBase == "lusld"
    fl := R_Use(exe_dir+"_mo_usld",cur_dir+"_mo_usld",sBase)
  case sBase == "lusl"
    fl := R_Use(exe_dir+"_mo8usl",cur_dir+"_mo8usl",sBase+"18") .and. ;
          R_Use(exe_dir+"_mo9usl",cur_dir+"_mo9usl",sBase+"19") .and. ;
          R_Use(exe_dir+"_mo0usl",cur_dir+"_mo0usl",sBase)
  case sBase == "luslc"
    fl := R_Use(exe_dir+"_mo8uslc",{cur_dir+"_mo8uslc",cur_dir+"_mo8uslu"},sBase+"18") .and. ;
          R_Use(exe_dir+"_mo9uslc",{cur_dir+"_mo9uslc",cur_dir+"_mo9uslu"},sBase+"19") .and. ;
          R_Use(exe_dir+"_mo0uslc",{cur_dir+"_mo0uslc",cur_dir+"_mo0uslu"},sBase)
  case sBase == "luslf"
    fl := R_Use(exe_dir+"_mo8uslf",cur_dir+"_mo8uslf",sBase+"18") .and. ;
          R_Use(exe_dir+"_mo9uslf",cur_dir+"_mo9uslf",sBase+"19") .and. ;
          R_Use(exe_dir+"_mo0uslf",cur_dir+"_mo0uslf",sBase)
endcase
return fl

*****
Function useUch_Usl()
return G_Use(dir_server+"uch_usl",dir_server+"uch_usl","UU") .and. ;
       G_Use(dir_server+"uch_usl1",dir_server+"uch_usl1","UU1")

***** записать объём работы операторов
Function write_work_oper(_pt,_tp,_ae,_kk,_kp,_open)
// {"PD",      "C",   4,   0},; // дата ввода c4tod(pd)
// {"PO",      "C",   1,   0},; // код оператора asc(po)
// {"PT",      "C",   1,   0},; // код задачи
// {"TP",      "C",   1,   0},; // тип (1-карточка, 2-л/у, 3-услуги)
// {"AE",      "C",   1,   0},; // 1-добавление, 2-редактирование, 3-удаление
// {"KK",      "C",   3,   0},; // кол-во (карточек, л/у или услуг)
// {"KP",      "C",   3,   0};  // количество введённых полей
Static llen := 6
DEFAULT _kk TO 1, _kp TO 0, _open TO .t.
if yes_parol .and. hb_FileExists(dir_server+"mo_opern"+sdbf) .and.;
    iif(_open, G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP"), .t.)
  _pt := chr(_pt)
  _tp := chr(_tp)
  _ae := chr(_ae)
  find (c4sys_date+kod_polzovat+_pt+_tp+_ae)
  if found()
    G_RLock(forever)
    op->kk := ft_sqzn(_kk + ft_unsqzn(op->kk,llen), llen)
    op->kp := ft_sqzn(_kp + ft_unsqzn(op->kp,llen), llen)
  else
    G_RLock(.t.,forever)
    op->PD := c4sys_date
    op->PO := kod_polzovat
    op->pt := _pt
    op->tp := _tp
    op->ae := _ae
    op->kk := ft_sqzn(_kk, llen)
    op->kp := ft_sqzn(_kp, llen)
  endif
  if _open
    op->(dbCloseArea())
  endif
endif
return NIL

*

***** проверить, более одного ли слова отдельно в фамилии, имени и отчестве
Function TwoWordFamImOt(s)
Static arr_char := {" ","-",".","'",'"'}
Local i, fl := .f.
s := alltrim(s)
for i := 1 to len(arr_char)
  if arr_char[i] $ s
    fl := .t. ; exit
  endif
next
return fl

***** проверить отдельно фамилию, имя и отчество в GET'ах
Function valFamImOt(ltip,s,par,/*@*/msg)
Static arr_pole := {"Фамилия","Имя","Отчество"}
Static arr_char := {" ","-",".","'",'"'}
Local fl := .t., i, c, s1 := "", nword := 0, get, r := row()
DEFAULT par TO 1
s := alltrim(s)
for i := 1 to len(arr_char)
  s := charone(arr_char[i],s)
next
if len(s) > 0
  s := upper(left(s,1))+substr(s,2)
endif
for i := 1 to len(s)
  c := substr(s,i,1)
  if isralpha(c)
    //
  elseif ascan(arr_char,c) > 0
    ++nword
  else
    s1 += c
  endif
next
msg := ""
if !empty(s1)
  msg := 'В поле "'+arr_pole[ltip]+'" обнаружены недопустимые символы "'+s1+'"'
elseif empty(s) .and. ltip < 3
  msg := 'Пустое значение поля "'+arr_pole[ltip]+'" недопустимо'
endif
if par == 1  // для GET-системы
  Private tmp := readvar()
  &tmp := padr(s,40)
  if empty(msg) .and. nword > 0
    if (get := get_pointer(tmp)) != NIL
      r := get:Row
    endif
    fl := .f.
    MyBell()
    if f_alert({padc('В поле "'+arr_pole[ltip]+'" занесено '+lstr(nword+1)+' слова',60,'.')},;
               {' Возврат в редактирование ',' Правильное поле '},;
               1,"W+/N","N+/N",r+1,,"W+/N,N/BG") == 2
      fl := .t.
    endif
  endif
endif
if !empty(msg)
  if par == 1  // для GET-системы
    fl := func_error(4,msg)
  else  // для проверки ТФОМС
    fl := .f.
  endif
endif
return fl

***** 02.09.15 вернуть отдельно фамилию, имя и отчество в массиве
Function retFamImOt(ltip,fl_no,is_open_kfio)
Static cDelimiter := " ."
Local i, k := 0, s := "", s1, mfio, tmp_select, ret_arr := {"","",""}
DEFAULT fl_no TO .t., is_open_kfio TO .f.
if ltip == 1 // вызвали из картотеки
  mfio := kart->fio
else  // вызвали из листа учёта
  mfio := human->fio
  if human->kod_k != kart->kod // если не связаны по relation
    kart->(dbGoto(human->kod_k))
  endif
endif
if kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
  tmp_select := select()
  if is_open_kfio
    select KFIO
  else
    R_Use(dir_server+"mo_kfio",,"KFIO")
    index on str(kod,7) to (cur_dir+"tmp_kfio")
  endif
  find (str(kart->kod,7))
  if found()
    ret_arr[1] := alltrim(kfio->FAM)
    ret_arr[2] := alltrim(kfio->IM)
    ret_arr[3] := alltrim(kfio->OT)
  endif
  if !is_open_kfio
    kfio->(dbCloseArea())
  endif
  select (tmp_select)
endif
if empty(ret_arr[1]) // на всякий случай - вдруг не нашли в "mo_kfio"
  mfio := alltrim(mfio)
  for i := 1 to numtoken(mfio,cDelimiter)
    s1 := alltrim(token(mfio,cDelimiter,i))
    if !empty(s1)
      ++k
      if k < 3
        ret_arr[k] := s1
      else
        s += s1+" "
      endif
    endif
  next
  ret_arr[3] := alltrim(s)
endif
if fl_no .and. empty(ret_arr[3])
  ret_arr[3] := "НЕТ"
endif
return ret_arr

***** 26.10.14 проверка на правильность введённого ФИО
Function val_fio(afio,aerr)
Local i, k := 0, msg
DEFAULT aerr TO {}
for i := 1 to 3
  valFamImOt(i,afio[i],2,@msg)
  if !empty(msg)
    ++k ; aadd(aerr,msg)
  endif
next
return (k == 0)

*

***** 26.08.14 вернуть иногороднюю СМО
Function ret_inogSMO_name(ltip,/*@*/rec,fl_close)
Local s := space(100), fl := .f., tmp_select := select()
DEFAULT fl_close TO .f.
if select("SN") == 0
  R_Use(dir_server+iif(ltip==1,"mo_kismo","mo_hismo"),,"SN")
  index on str(kod,7) to (cur_dir+"tmp_ismo")
  fl := .t.
endif
select SN
find (str(iif(ltip==1,kart->kod,human->kod),7))
if found()
  s := sn->SMO_NAME
  rec := sn->(recno())
endif
if fl .and. fl_close
  sn->(dbCloseArea())
endif
select (tmp_select)
return s

***** 22.05.15 СМО на экран (печать)
Function smo_to_screen(ltip)
Local s := "", s1 := "", lsmo, nsmo, lokato
lsmo := iif(ltip==1,kart_->smo,human_->smo) ; nsmo := int(val(lsmo))
s := inieditspr(A__MENUVERT,glob_arr_smo,nsmo)
if empty(s) .or. nsmo == 34
  if nsmo == 34
    s1 := ret_inogSMO_name(ltip,,.t.)
  else
    s1 := init_ismo(lsmo)
  endif
  if !empty(s1)
    s := alltrim(s1)
  endif
  lokato := iif(ltip==1,kart_->KVARTAL_D,human_->okato)
  if !empty(lokato)
    s += "/"+inieditspr(A__MENUVERT, glob_array_srf, lokato)
  endif
endif
return s

*

***** 15.10.14 проверка корректности GUID
Function valid_GUID(s,par)
// par = 1 - GUID из моей программы
// par = 2 - GUID из чужой программы
Local fl := .t.
DEFAULT par TO 1
if par == 1
  if len(charrem(" ",s)) < 36
    fl := .f.
  else
    fl := empty(CHARREPL("0123456789ABCDEF-", upper(s), SPACE(17)))
  endif
else // par = 2 - GUID из чужой программы
  fl := !empty(s) // просто проверим на пустоту
endif
return fl

***** составить GUID
Function mo_guid(par1,par2)
// par1 - от 1 до 3
//        .XXXXX...... для par1 = 1
//        ....XXXXX... для par1 = 2
//        .......XXXXX для par1 = 3
//        .....XXXXXX. для par1 = 4
// par2 - номер записи
Local s, s1, s2, k, l
s := f1CreateGUID(8) + "-" + ;
     f1CreateGUID(4) + "-" + ;
     f1CreateGUID(4) + "-" + ;
     f1CreateGUID(4) + "-"
s1 := f1CreateGUID(12)
s2 := ntoc(par2,16) // номер записи -> в 16-ричное число (строку)
l := len(s2) // длина 16-ричной строки
k := {6,9,12,11}[par1] - l + 1 // номер позиции, с которой будем замещать
return s+stuff(s1,k,l,s2)

*****
Static Function f1CreateGUID(tmpLength)
Static strValid := "0123456789ABCDEF"
Local tmpCounter, tmpGUID := ""
For tmpCounter := 1 To tmpLength
  tmpGUID += substr(strValid, random()%16 + 1, 1)
Next
return tmpGUID

*

***** 21.01.17 определить диапазоны номеров пакетов
Function f_mb_me_nsh(_nyear,/*@*/mb,/*@*/me)
if mem_bnn13rees <= 0 .or. mem_enn13rees <= 0
  if mem_bnn_rees == 1
    mem_bnn13rees := mem_bnn_rees
  else
    mem_bnn13rees := int(val(lstr(mem_bnn_rees)+"0"))
  endif
  mem_enn13rees := int(val(lstr(mem_enn_rees)+"9"))
endif
mb := mem_bnn13rees
me := mem_enn13rees
/*if _nyear < 2013 .and. mem_bnn_rees == 1
  mb := 100
endif*/
return iif(_nyear < 2017, 3, 5) // начиная с 2017 года - 5 символов

***** 05.11.19 если это укрупнённый архив, распаковать и прочитать
Function Is_Our_ZIP(cName,/*@*/tip_csv_file,/*@*/kod_csv_reestr)
Static cStFile, si
Local fl := .f., arr := {}, arr_f, i, s := cName, s1, name_ext, _date, _time, c
DEFAULT cStFile TO cName
if left(s,3) == "RI0" .or. left(s,2) == "I0"
  fl := func_error(4,'Данный файл необходимо читать в подзадаче "Учёт направлений на госпитализацию"')
elseif eq_any(left(s,8),"RHRT34_M","RFRT34_M") .and. substr(s,9,6) == glob_MO[_MO_KOD_TFOMS]
  c := substr(s,2,1)
  if (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip),2)) != NIL
    for i := 1 to len(arr_f)
      s := upper(arr_f[i]) ; name_ext := Name_Extention(s)
      do case
        case left(s,8) == "P"+c+"RT34_M" .and. name_ext == spdf
          aadd(arr,{1,"протокол обработки поступивших сведений "+s,s,name_ext})
        case eq_any(left(s,4),"V"+c+"RM","P"+c+"RM") .and. name_ext == szip
          s1 := "протокол ФЛК "+s
          // проверим, читали ли уже данный файл
          if Verify_Is_Already_XML(Name_Without_Ext(s),@_date,@_time)
            s1 += " [прочитан в "+_time+" "+date_8(_date)+"г.]"
          endif
          aadd(arr,{2,s1,s,name_ext})
        case left(s,8) == "M"+c+"RT34_M" .and. name_ext == spdf
          aadd(arr,{3,"сведения о выполнении плана-задания "+s,s,name_ext})
        case left(s,7) == c+"RT34_M" .and. name_ext == szip
          s1 := "реестр СП и ТК "+s
          // проверим, читали ли уже данный файл
          if Verify_Is_Already_XML(Name_Without_Ext(s),@_date,@_time)
            s1 += " [прочитан в "+_time+" "+date_8(_date)+"г.]"
          endif
          aadd(arr,{4,s1,s,name_ext})
      endcase
    next
    asort(arr,,,{|x,y| x[1] < y[1] })
    arr_f := {} ; aeval(arr,{|x| aadd(arr_f,x[2])})
    i := iif(cStFile == cName, si, 1)
    if (i := popup_prompt(T_ROW,T_COL-5,i,arr_f)) > 0
      cStFile := cName ; si := i
      if arr[i,4] == spdf
        file_AdobeReader(_tmp2dir1+arr[i,3])
      elseif arr[i,4] == szip
        fl := .t.
        full_zip := _tmp2dir1+arr[i,3] // переопределяем Private-переменную
      endif
    endif
  endif
elseif left(s,6) == glob_MO[_MO_KOD_TFOMS]
  if (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip),2)) != NIL
    for i := 1 to len(arr_f)
      s := upper(arr_f[i]) ; name_ext := Name_Extention(s)
      do case
        case left(s,1) == "R" .and. name_ext == spdf
          aadd(arr,{1,"протокол приёма поступивших счетов ОМС "+s,s,name_ext})
        case left(s,2) == "NR" .and. name_ext == spdf
          aadd(arr,{2,"протокол отклонения поступивших счетов ОМС "+s,s,name_ext})
      endcase
    next
    asort(arr,,,{|x,y| x[1] < y[1] })
    arr_f := {} ; aeval(arr,{|x| aadd(arr_f,x[2])})
    if (i := popup_prompt(T_ROW,T_COL-5,1,arr_f)) > 0
      if arr[i,4] == spdf
        file_AdobeReader(_tmp2dir1+arr[i,3])
      endif
    endif
  endif
elseif eq_any(left(s,1),"A","D") // файлы РАК и РПД
  fl := .t.
  s := substr(s,2)
  if eq_any(left(s,1),"T","S")
    s := substr(s,2)
    cFrom := beforatnum("M",s) ; nSMO := int(val(cFrom))
    if ascan(glob_arr_smo,{|x| x[2] == nSMO }) > 0
      s := afteratnum("M",s)
      if beforatnum("_",s) == glob_MO[_MO_KOD_TFOMS] .and. ;
         (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip),2,"tmp"+szip)) != NIL
        for i := 1 to len(arr_f)
          if upper(cName+szip) == upper(arr_f[i])
            full_zip := _tmp2dir1+arr_f[i] // переопределяем Private-переменную
            exit
          endif
        next
      endif
    endif
  endif
elseif eq_any(left(s,2),"E2","O2") // файлы протокола прикрепления и открепления
  fl := .t.
  tip_csv_file := iif(left(s,1)=="E",_CSV_FILE_ANSWER,_CSV_FILE_OTKREP)
  kod_csv_reestr := 0
  if (s1 := substr(s,3,6)) == glob_MO[_MO_KOD_TFOMS]
    R_Use(dir_server+"mo_krtf",,"KRTF")
    index on upper(fname) to (cur_dir+"tmp_krtf")
    find (padr(s,26)) // не принимали ли уже данный файл
    if found()
      fl := func_error(4,"Этот файл уже был прочитан в "+krtf->TFILE+" "+date_8(krtf->DFILE)+"г.")
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    elseif tip_csv_file == _CSV_FILE_ANSWER
      find (padr("MO"+substr(s,2),26)) // имя то же самое, начиная с третьего знака
      if found()
        kod_csv_reestr := krtf->REESTR
      else
        fl := func_error(4,"Файл прикрепления для данного протокола обработки мы не отправляли в ТФОМС!")
      endif
    endif
    krtf->(dbCloseArea())
  else
    fl := func_error(4,"Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+s1)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
      func_error(4,"Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
    endif
  endif
elseif left(s,3) == "SO2" // ответ на запрос сверки
  fl := .t.
  tip_csv_file := _CSV_FILE_SVERKAO
  kod_csv_reestr := 0
  if (s1 := substr(s,4,6)) == glob_MO[_MO_KOD_TFOMS]
    R_Use(dir_server+"mo_krtf",,"KRTF")
    index on upper(fname) to (cur_dir+"tmp_krtf")
    find (padr(s,26)) // не принимали ли уже данный файл
    if found()
      fl := func_error(4,"Этот файл уже был прочитан в "+krtf->TFILE+" "+date_8(krtf->DFILE)+"г.")
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    else
      find (padr("SZ"+substr(s,3),26)) // имя то же самое, начиная с третьего знака
      if found()
        kod_csv_reestr := krtf->REESTR
      else
        fl := func_error(4,"Файл запроса по сверке для данного протокола обработки мы не отправляли в ТФОМС")
      endif
    endif
    krtf->(dbCloseArea())
  else
    fl := func_error(4,"Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+;
                       " не соответствует коду получателя: "+s1)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
      func_error(4,"Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
    endif
  endif
else
  fl := .t.
endif
return fl

***** 17.06.15 если это файл с расширениием CSV - прочитать
Function Is_Our_CSV(cName,/*@*/tip_csv_file,/*@*/kod_csv_reestr)
Local fl := .f., i, s := cName, s1
if eq_any(left(s,3),"EO2","LO2") // файлы протокола прикрепления и открепления
  fl := .t.
  tip_csv_file := iif(left(s,1)=="E",_CSV_FILE_PRIKANS,_CSV_FILE_PRIKFLK)
  kod_csv_reestr := 0
  if (s1 := substr(s,4,6)) == glob_MO[_MO_KOD_TFOMS]
    R_Use(dir_server+"mo_krtf",,"KRTF")
    index on upper(fname) to (cur_dir+"tmp_krtf")
    find (padr(s,26)) // не принимали ли уже данный файл
    if found()
      fl := func_error(4,"Этот файл уже был прочитан в "+krtf->TFILE+" "+date_8(krtf->DFILE)+"г.")
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    else
      find (padr("M"+substr(s,2),26)) // имя то же самое, начиная со второго знака
      if found()
        kod_csv_reestr := krtf->REESTR
        R_Use(dir_server+"mo_krtr",,"KRTR")
        goto (kod_csv_reestr)
        if krtr->ANSWER == 0 .and. tip_csv_file == _CSV_FILE_PRIKANS
          fl := func_error(4,"Сначала необходимо прочитать файл L"+substr(s,2)+scsv)
        endif
        krtr->(dbCloseArea())
      else
        fl := func_error(4,"Файл прикрепления для данного протокола обработки мы не отправляли в ТФОМС!")
      endif
    endif
    krtf->(dbCloseArea())
  else
    fl := func_error(4,"Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+s1)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
      func_error(4,"Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
    endif
  endif
else
  fl := func_error(4,"Неизвестный файл")
endif
return fl

***** 17.12.19 проверить, нам ли предназначен данный XML-файл
Function Is_Our_XML(cName,ret_arr)
Local c, arr_err := {}, i, s, nSMO, nTypeFile, cFrom, cTo, _nYear, _nMonth, nNN, nReestr := 0
s := cName
if eq_any(left(s,3),"VHR","VFR","PHR","PFR") // файл протокола ФЛК
  nTypeFile := _XML_FILE_FLK
  R_Use(dir_server+"mo_rees",,"REES")
  R_Use(dir_server+"mo_xml",,"MO_XML")
  index on upper(fname) to (cur_dir+"tmpmoxml")
  find (padr(substr(s,2),26)) // имя то же самое, начиная со второго знака
  if found() .and. (nReestr := mo_xml->REESTR) > 0
    select REES
    goto (nReestr)
    cFrom   := glob_MO[_MO_KOD_TFOMS]
    cTo     := '34'
    _nYear  := rees->NYEAR
    _nMonth := rees->NMONTH
    nNN     := rees->NN
  else
    aadd(arr_err, "Это файл ФЛК, но мы не отправляли соответствующий реестр случаев в ТФОМС!")
  endif
  rees->(dbCloseArea())
  mo_xml->(dbCloseArea())
elseif eq_any(left(s,3),"D02","R02","R12","R06") // ответный файл на отосланный файл D01 R01 (R05)
  s := substr(s,4)
  if left(s,1) == "M"
    s := substr(s,2)
  else
    aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
  endif
  if len(arr_err) == 0
    cTo := left(s,6)
    if !(cTo == glob_MO[_MO_KOD_TFOMS])
      aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
        aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
      endif
    endif
    s := substr(s,7)
    if left(s,3) == "T34"
      s := afteratnum("_",s)
    else
      aadd(arr_err, "Неверный отправитель: "+s)
    endif
  endif
  if len(arr_err) == 0
    if left(cName,3) == "D02"
      nTypeFile := _XML_FILE_D02
      R_Use(dir_server+"mo_d01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("D01T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла D01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->MM
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на D01, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    elseif left(cName,3) == "R02"
      nTypeFile := _XML_FILE_R02
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("R01T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NQUARTER
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R01, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    elseif left(cName,3) == "R12"
      nTypeFile := _XML_FILE_R12
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("R11T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла R11
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NQUARTER
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R11, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    else // "R06"
      nTypeFile := _XML_FILE_R06
      R_Use(dir_server+"mo_dr05",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("R05T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла R05
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := 0
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    endif
  endif
elseif eq_any(left(s,4),"PR01","PR11","PR05") // ответный файл на отосланный файл R01 (R11) (R05)
  s := substr(s,8)
  if left(s,1) == "M"
    s := substr(s,2)
  else
    aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
  endif
  if len(arr_err) == 0
    cTo := left(s,6)
    if !(cTo == glob_MO[_MO_KOD_TFOMS])
      aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
        aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
      endif
    endif
    s := substr(cName,5,3)
    if !(left(s,3) == "T34")
      aadd(arr_err, "Неверный отправитель: "+s)
    endif
  endif
  if len(arr_err) == 0
    if left(cName,4) == "PR01"
      nTypeFile := _XML_FILE_R02
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NMONTH
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R01, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    elseif left(cName,4) == "PR11"
      nTypeFile := _XML_FILE_R12
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NMONTH
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R11, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    else // "R06"
      nTypeFile := _XML_FILE_R06
      R_Use(dir_server+"mo_dr05",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R05
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := 0
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    endif
  endif
elseif eq_any(left(s,4),"PR01","PR11","PR05") // ответный файл на отосланный файл R01 (R11) (R05)
  s := substr(s,8)
  if left(s,1) == "M"
    s := substr(s,2)
  else
    aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
  endif
  if len(arr_err) == 0
    cTo := left(s,6)
    if !(cTo == glob_MO[_MO_KOD_TFOMS])
      aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
        aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
      endif
    endif
    s := substr(cName,5,3)
    if !(left(s,3) == "T34")
      aadd(arr_err, "Неверный отправитель: "+s)
    endif
  endif
  if len(arr_err) == 0
    if eq_any(left(cName,4),"PR01","PR11")
      nTypeFile := _XML_FILE_R02
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NMONTH
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R01(R11), но мы не отправляли такой пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    else // "R06"
      nTypeFile := _XML_FILE_R06
      R_Use(dir_server+"mo_dr05",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R05
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := 0
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    endif
  endif
else
  if eq_any(left(s,2),"HR","FR") // файл реестра СП
    s := substr(s,3)
    nTypeFile := _XML_FILE_SP
  elseif left(s,1) == "A" // файл РАК
    s := substr(s,2)
    nTypeFile := _XML_FILE_RAK
  elseif left(s,1) == "D" // файл РПД
    s := substr(s,2)
    nTypeFile := _XML_FILE_RPD
  else
    aadd(arr_err, "Попытка прочитать незнакомый файл")
  endif
  if left(s,1) == "T"
    // из ТФОМС
  elseif left(s,1) == "S"
    // от СМО
  else
    aadd(arr_err, "Неверная буква в обозначении отправителя: "+s)
  endif
  if len(arr_err) == 0
    if nTypeFile == _XML_FILE_SP
      s := substr(s,2)
      cFrom := beforatnum("_",s) ; nSMO := int(val(cFrom))
      if ascan(glob_arr_smo,{|x| x[2] == nSMO }) == 0
        aadd(arr_err, "Неверный код отправителя: "+cFrom)
      endif
      if len(arr_err) == 0
        s := afteratnum("_",s)
        if left(s,1) == "M"
          s := substr(s,2)
        else
          aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
        endif
        if len(arr_err) == 0
          cTo := left(s,6)
          if !(cTo == glob_MO[_MO_KOD_TFOMS])
            aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+;
                          " не соответствует коду получателя: "+cTo)
            if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
              aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
            endif
          endif
        endif
        if len(arr_err) == 0
          s := substr(s,7)
          _nYear := int(val("20"+left(s,2)))
          _nMonth := int(val(substr(s,3,2)))
          nNN := int(val(substr(s,5))) // берём строку до конца
        endif
      endif
    elseif eq_any(nTypeFile,_XML_FILE_RAK,_XML_FILE_RPD)
      s := substr(s,2)
      cFrom := beforatnum("M",s) ; nSMO := int(val(cFrom))
      if ascan(glob_arr_smo,{|x| x[2] == nSMO }) == 0
        aadd(arr_err, "Неверный код отправителя: "+cFrom)
      endif
      if len(arr_err) == 0
        s := afteratnum("M",s)
        cTo := beforatnum("_",s)
        if !(cTo == glob_MO[_MO_KOD_TFOMS])
          aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
          if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
            aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
          endif
        endif
        if len(arr_err) == 0
          s := afteratnum("_",s)
          _nYear := int(val("20"+left(s,2)))
          _nMonth := int(val(substr(s,3,2)))
          nNN := int(val(substr(s,5))) // берём строку до конца
        endif
      endif
    endif
  endif
endif
if len(arr_err) == 0
  ret_arr[1] := nTypeFile
  ret_arr[2] := cFrom
  ret_arr[3] := cTo
  ret_arr[4] := _nYear
  ret_arr[5] := _nMonth
  ret_arr[6] := nNN
  ret_arr[7] := nReestr
else
  Ins_Array(arr_err,1,"")
  Ins_Array(arr_err,1,"Принимаемый файл: "+cName)
  n_message(arr_err,,"GR+/R","W+/R",,,"G+/R")
endif
return (len(arr_err) == 0)

*

***** проверить, занесен ли данный файл в "mo_xml"
Function Verify_Is_Already_XML(cName,/*@*/_date,/*@*/_time)
Local l, fl, tmp_select := select()
R_Use(dir_server+"mo_xml",,"MX")
index on upper(FNAME) to (cur_dir+"tmp_mxml")
l := fieldlen(fieldnum("FNAME"))
find (padr(cName,l))
if (fl := found())
  if mx->tip_in > 0  // если принимаемый файл
    _date := mx->DREAD  // то вернём дату последнего чтения (обработки)
    _time := mx->TREAD
  else               // если отсылаемый файл
    _date := mx->DFILE  // то вернём дату создания файла
    _time := mx->TFILE
  endif
endif
mx->(dbCloseArea())
select (tmp_select)
return fl

*

***** 20.10.14 зачитать CSV-файл в двумерный массив
Function read_CSV_to_array(cFile_csv)
Local arr := {}, _ar, i, s, s1, lfp
lfp := fopen(cFile_csv)
do while !feof(lfp)
  if !empty(s := fReadLn(lfp))
    _ar := {}
    for i := 1 to numtoken(s,";",1)
      s1 := alltrim(charrem('"',token(s,";",i,1)))
      aadd(_ar, hb_AnsiToOem(s1))
    next
    for i := 1 to 25
      aadd(_ar, " ") // добавим 25 полей (вдруг что-то не так со строкой)
    next
    aadd(arr,aclone(_ar))
  endif
enddo
fclose(lfp)
return arr

*

***** проверить, существует файл nfile, и попытаться удалить его
Function myFileDeleted(nfile)
Static sn := 100 // делаем 100 попыток
Local i := 0, fl := .f.
do while i < sn
  if hb_FileExists(nfile)
    delete file (nfile)
  else
    fl := .t. ; exit
  endif
  ++i
enddo
if !fl
  func_error(4,"Неудачная попытка удаления файла "+nfile+". Попытайтесь снова")
endif
return fl

*

***** 02.07.14 создать ZIP-архив из массива XML-файлов
Function chip_create_zipXML(zip_file,arr_f,is_delete_files,type_dir)
// zip_file - имя архива с расширением
// arr_f - массив файлов
// is_delete_files - удалять ли файлы после создания архива (по-умолчанию - нет)
Local hZip, i, cPassword, fl := .t., hGauge, s
DEFAULT is_delete_files TO .f., type_dir TO 1
delete file (zip_file)
if !empty(hZip := HB_ZIPOPEN(zip_file))
  for i := 1 To Len(arr_f)
    HB_ZipStoreFile( hZip, arr_f[i], arr_f[i])
  next
  HB_ZIPCLOSE( hZip )
else
  fl := func_error(4,"Возникла ошибка при создании "+zip_file)
endif
if fl .and. is_delete_files
  for i := 1 To Len(arr_f)
    delete file (arr_f[i])
  next
endif
if fl
  fl := chip_copy_zipXML(zip_file,dir_server+iif(type_dir==1,dir_XML_MO,dir_NAPR_MO),.t.)
endif
return fl

*

***** переписать ZIP-архив (с XML-файлами) в целевой каталог
Function chip_copy_zipXML(zip_file,goal_dir,is_delete_files)
// zip_file - имя архива с расширением (и м.б. с путём)
// goal_dir - имя каталога, куда надо переписать архив
// is_delete_files - удалять ли архив после переписывания (по-умолчанию - нет)
Local fl := .f., zip_file2
DEFAULT is_delete_files TO .f.
if !empty(goal_dir)
  dirmake(goal_dir)
  goal_dir += cslash
  zip_file2 := StripPath(zip_file) // если в имени присутствует путь - убрать
  delete file (goal_dir+zip_file2)
  copy file (zip_file) to (goal_dir+zip_file2)
  if hb_FileExists(goal_dir+zip_file2)
    fl := .t.
  else
    func_error(4,"Ошибка записи файла "+goal_dir+zip_file2)
  endif
endif
if fl .and. is_delete_files
  delete file (zip_file)
endif
return fl

*

***** строка даты для XML-файла
Function date2xml(mdate)
return strzero(year(mdate),4)+'-'+;
       strzero(month(mdate),2)+'-'+;
       strzero(day(mdate),2)

***** пребразовать дату из "2002-02-01" в тип "DATE"
Function xml2date(s)
return stod(charrem("-",s))

*

***** 30.01.14 проверить наличие тэга(ов) и вернуть его(их) значение(я) в массиве
Function mo_read_xml_array(_node,_title)
Local j1, oNode2, arr := {}
for j1 := 1 to len(_node:aitems)
  oNode2 := _node:aItems[j1]
  if upper(_title) == upper(oNode2:title) .and. !empty(oNode2:aItems) ;
                                          .and. valtype(oNode2:aItems[1]) == "C"
    aadd(arr, oNode2:aItems[1])
  endif
next
return arr

*

***** проверить наличие в узле _node XML-файла тэга _title и вернуть его значение
Function mo_read_xml_stroke(_node,_title,_aerr,_binding)
// _node - указатель на узел
// _title - наименование тэга
// _aerr - массив сообщений об ошибках
// _binding - обязателен ли атрибут (по-умолчанию .T.)
Local ret := "", oNode, yes_err := (valtype(_aerr) == "A"),;
      s_msg := 'Отсутствует значение обязательного тэга "'+_title+'"'
DEFAULT _binding TO .t.
// ищем необходимый "_title" тэг в узле "_node"
oNode := _node:Find(_title)
if oNode == NIL .and. _binding .and. yes_err
  aadd(_aerr,s_msg)
endif
if oNode != NIL
  ret := mo_read_xml_tag(oNode,_aerr,_binding)
endif
return ret

***** 11.12.17 вернуть значение тэга
Function mo_read_xml_tag(oNode,_aerr,_binding)
// oNode - указатель на узел
// _aerr - массив сообщений об ошибках
// _binding - обязателен ли атрибут (по-умолчанию .T.)
Local ret := "", c, yes_err := (valtype(_aerr) == "A"),;
      s_msg := 'Отсутствует значение обязательного тэга "'+oNode:title+'"'
DEFAULT _binding TO .t.
if empty(oNode:aItems)
  if _binding .and. yes_err
    aadd(_aerr,s_msg)
  endif
elseif (c := valtype(oNode:aItems[1])) == "C"
  if type("p_xml_code_page") == "C" .and. upper(p_xml_code_page) == "UTF-8"
    ret := hb_Utf8ToStr(alltrim(oNode:aItems[1]),"RU866")
  else
    ret := hb_AnsiToOem(alltrim(oNode:aItems[1]))
  endif
elseif yes_err
  aadd(_aerr,'Неверный тип данных у тэга "'+oNode:title+'": "'+c+'"')
endif
return ret

*

***** 22.11.13 записать в XML-файл строку (открыть тэг, записать значение, закрыть тэг)
Function mo_add_xml_stroke(oNode,sTag,sValue)
Local oXmlNode := oNode:Add( HXMLNode():New(sTag))
sValue := alltrim(sValue)
if type("p_xml_code_page") == "C" .and. upper(p_xml_code_page) == "UTF-8"
  sValue := hb_StrToUtf8(sValue,"RU866")
else
  sValue := hb_OemToAnsi(sValue)
endif
oXmlNode:Add(sValue)
return NIL

*

***** 15.12.13 корректен ли период для информации "по отчётному периоду"
Function is_otch_period(arr_m)
Local fl := .t.
if !(arr_m[5]==bom(arr_m[5]) .and. arr_m[6]==eom(arr_m[6]))
  fl := func_error(4,"Для отчётного периода необходимо выбирать кратный месяцу период!")
endif
return fl

*

***** попадает ли отч.период (_YEAR,_MONTH) в диапазон с _begin_date по _end_date
Function between_otch_period(_date,_YEAR,_MONTH,_begin_date,_end_date)
Local mdate
if emptyany(_YEAR,_MONTH)
  mdate := _date // по-старому, т.е. по дате счёта
else
  mdate := stod(strzero(_YEAR,4)+strzero(_MONTH,2)+'15')
endif
return between(mdate,_begin_date,_end_date)

*

***** попадает ли date1 (диапазон date1-date2) в диапазон _begin_date-_end_date
Function between_date(_begin_date,_end_date,date1,date2)
// _begin_date - начало действия
// _end_date   - окончание действия
// date1 - проверяемая дата
// date2 - вторая дата диапазона (если = NIL, то проверяем только по date1)
Local fl := .f., fl2
DEFAULT date1 TO sys_date  // по умолчанию проверяем на сегодняшний момент
if empty(_begin_date)
  _begin_date := stod("19930101")  // если начало действия = пусто, то 01.01.1993
endif
// проверка даты date1 на попадание в диапазон
if (fl := (date1 >= _begin_date)) .and. !empty(_end_date)
  fl := (date1 <= _end_date)
endif
// проверка диапазона date1-date2 на пересечение с диапазоном
if valtype(date2) == 'D'
  if (fl2 := (date2 >= _begin_date)) .and. !empty(_end_date)
    fl2 := (date2 <= _end_date)
  endif
  fl := (fl .or. fl2)
endif
return fl

*

***** 21.10.13 проверить перекрытие диапазонов p1-p2 с d1-d2 для стационара
Function overlap_diapazon(p1,p2,d1,d2)
Local fl := .f.
if p1 == d1 .and. p2 == d2 // абсолютно одинаковые диапазоны лечения
  fl := .t.
elseif p1 == p2 // первое лечение в один день
  if d1 < d2    // а второе лечение более одного дня
    fl := (d1 < p1 .and. p2 < d2) // первое лечение внутри второго
  endif
elseif d1 == d2 // второе лечение в один день
  if p1 < p2    // а первое лечение более одного дня
    fl := (p1 < d1 .and. d2 < p2) // второе лечение внутри первого
  endif
elseif p1 == d1 .or. p2 == d2 // начало ИЛИ окончание лечения в один день
  fl := .t.
else
  if !(fl := ((p1 < d1 .and. d1 < p2) .or. (p1 < d2 .and. d2 < p2)))
    fl := ((d1 < p1 .and. p1 < d2) .or. (d1 < p2 .and. p2 < d2))
  endif
endif
return fl

*

***** сделать из глобального массива укороченный (отсечь по дате действия)
Function cut_glob_array(_glob_array,_date)
Local i, tmp_array := {}
for i := 1 to len(_glob_array)
  if between_date(_glob_array[i,3],_glob_array[i,4],_date)
    aadd(tmp_array,_glob_array[i])
  endif
next
return tmp_array

***** создать (name_base).DBF из глобального массива (укороченную) (отсечь по дате действия)
FUNCTION init_tmp_glob_array(name_base,_glob_array,_date,is_all)
Local i, len1, len2, f2type, fl_is, tmp_select
DEFAULT name_base TO "tmp_ga", is_all TO .f.
if !myFileDeleted(cur_dir+name_base+sdbf)
  return .f.
endif
tmp_select := select()
len1 := len2 := 0
f2type := valtype(_glob_array[1,2])
for i := 1 to len(_glob_array)
  if iif(is_all, .t., between_date(_glob_array[i,3],_glob_array[i,4],_date))
    len1 := max(len1,len(alltrim(_glob_array[i,1])))
    if f2type == "N"
      len2 := max(len2,len(lstr(_glob_array[i,2])))
    else
      len2 := max(len2,len(alltrim(_glob_array[i,2])))
    endif
  endif
next
dbcreate(name_base,{{"name","C",len1,0},;
                    {"kod",f2type,len2,0},;
                    {"is","L",1,0}})
use (name_base) new alias tmp_ga
for i := 1 to len(_glob_array)
  fl_is := between_date(_glob_array[i,3],_glob_array[i,4],_date)
  if iif(is_all, .t., fl_is)
    append blank
    replace name with _glob_array[i,1], ;
            kod with _glob_array[i,2], ;
            is with fl_is
  endif
next
index on upper(name) to (name_base)
tmp_ga->(dbCloseArea())
select (tmp_select)
return .t.

***** 04.05.13 в GET'е выбрать значение из TMP_GA.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_ga(k,r,c,name_base,browTitle,is_F2,sTitle)
Local ret, fl, cRec, kolRec, nRec, len1, len2, f2type, tmp_select, blk, t_arr[BR_LEN]
DEFAULT name_base TO "tmp_ga", browTitle TO "Наименование", is_F2 TO .t.
tmp_select := select()
use (name_base) index (name_base) new alias tmp_ga
kolRec := lastrec()
len1 := fieldlen(1)
len2 := fieldlen(2)
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  if (t_arr[BR_BOTTOM] := t_arr[BR_TOP]+kolRec+3) > maxrow()-2
    t_arr[BR_BOTTOM] := maxrow()-2
  endif
else
  t_arr[BR_BOTTOM] := r-1
  if (t_arr[BR_TOP] := t_arr[BR_BOTTOM]-kolRec-3) < 1
    t_arr[BR_TOP] := 1
  endif
endif
t_arr[BR_LEFT] := c
if (t_arr[BR_RIGHT] := c+len1+3) > 77
  t_arr[BR_RIGHT] := 77
  t_arr[BR_LEFT] := t_arr[BR_RIGHT]-len1-3
  if t_arr[BR_LEFT] < 2
    t_arr[BR_LEFT] := 2
  endif
endif
len1 := t_arr[BR_RIGHT]-t_arr[BR_LEFT]-3
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
t_arr[BR_COLOR] := color0
if sTitle != NIL
  t_arr[BR_TITUL] := sTitle
  t_arr[BR_TITUL_COLOR] := "B/BG"
endif
t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {{ center(browTitle,len1), {|| left(tmp_ga->name,len1) },blk }}
if is_F2
  t_arr[BR_EDIT] := {|nk,ob| f1get_tmp_ga(nk,ob,"edit") }
endif
if fieldnum("IDUMP") > 0 //специально для отделений
  t_arr[BR_ENTER] := {|| ret := {tmp_ga->kod,alltrim(tmp_ga->name),tmp_ga->idump,tmp_ga->tiplu} }
else
  t_arr[BR_ENTER] := {|| ret := {tmp_ga->kod,alltrim(tmp_ga->name)} }
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор"+iif(is_F2,";  ^<F2>^ - поиск по подстроке","")) }
f2type := fieldtype(2)
fl := .f. ; nRec := 0
if k != NIL
  go top
  do while !eof()
    if f2type == "N"
      fl := (tmp_ga->kod == k)
    else
      fl := (alltrim(tmp_ga->kod) == alltrim(k))
    endif
    if fl
      cRec := recno()
      exit
    endif
    ++nRec
    skip
  enddo
endif
if !fl
  nRec := 0
endif
go top
if nRec > 0
  if kolRec-nRec < t_arr[BR_BOTTOM]-t_arr[BR_TOP]-3 // последняя страница?
    keyboard chr(K_END)+replicate(chr(K_UP),kolRec-nRec-1)
  else
    goto (cRec)
  endif
endif
edit_browse(t_arr)
tmp_ga->(dbCloseArea())
select (tmp_select)
return ret

***** 23.01.17
Function f1get_tmp_ga(nKey,oBrow,regim,arr)
Static tmp := ""
Local ret := -1, buf, buf1, tmp1, rec1 := recno()
if regim == "edit" .and. nkey == K_INS .and. valtype(arr) == "A" .and. fieldnum("ISN") > 0
  //специально для множественного выбора из справочника новых специальностей V015
  tmp_ga->isn := iif(tmp_ga->isn==1, 0, 1)
  keyboard chr(K_TAB)
  return 0
endif
if !(regim == "edit" .and. nKey == K_F2)
  return ret
endif
buf := savescreen()
do while .t.
  buf1 := save_box(pr2-3,pc1+1,pr2-1,pc2-1)
  box_shadow(pr2-3,pc1+1,pr2-1,pc2-1,color1,"Введите подстроку поиска",color8)
  tmp1 := padr(tmp,15)
  status_key("^<Esc>^ - отказ от ввода")
  @ pr2-2,pc1+(pc2-pc1-15)/2 get tmp1 picture "@K@!" color color8
  myread()
  if lastkey() == K_ESC .or. empty(tmp1)
    exit
  endif
  mywait()
  tmp := alltrim(tmp1)
  Private tmp_mas := {}, tmp_kod := {}, t_len, k1, k2
  i := 0
  go top
  do while !eof()
    if tmp $ upper(tmp_ga->name)
      aadd(tmp_mas,tmp_ga->name) ; aadd(tmp_kod,tmp_ga->(recno()))
    endif
    skip
  enddo
  rest_box(buf1)
  if (t_len := len(tmp_kod)) = 0
    stat_msg("Не найдено ни одной записи, удовлетворяющей данной подстроке!")
    mybell(2)
    loop
  elseif t_len == 1  // найдена одна строка
    goto (tmp_kod[1])
    ret := 0
    exit
  else
    status_key("^<Esc>^ - отказ от выбора")
    if (i := popup(pr1+3,pc1+1,pr2-1,pc2-1,tmp_mas,1,color1,.f.,,,;
                   'Кол-во записей с "'+tmp+'" - '+lstr(t_len),color8)) > 0
      goto (tmp_kod[i])
      ret := 0
    endif
    exit
  endif
enddo
restscreen(buf)
if ret == -1
  goto rec1
endif
return ret

***** 23.01.17 в GET'е выбрать значение из TMP_V015.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_V015(k,r,c,a_spec)
Local ret, fl, kolRec, nRec, tmp_select := select(), s, blk, t_arr[BR_LEN]
use (cur_dir+"tmp_v015") index (cur_dir+"tmpsV015"),(cur_dir+"tmpkV015") new alias tmp_ga
kolRec := lastrec()
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  if (t_arr[BR_BOTTOM] := t_arr[BR_TOP]+kolRec+3) > maxrow()-2
    t_arr[BR_BOTTOM] := maxrow()-2
  endif
else
  t_arr[BR_BOTTOM] := r-1
  if (t_arr[BR_TOP] := t_arr[BR_BOTTOM]-kolRec-3) < 1
    t_arr[BR_TOP] := 1
  endif
endif
if valtype(a_spec) == "A"
  blk := {|| iif(tmp_ga->isn==1, {1,2}, {3,4}) }
  if !empty(a_spec)
    go top
    do while !eof()
      if ascan(a_spec,int(val(tmp_ga->kod))) > 0
        tmp_ga->isn := 1
      endif
      skip
    enddo
  endif
else
  blk := {|| iif(tmp_ga->vs=="врач", {1,2}, {3,4}) }
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {;
  { "Код", {|| tmp_ga->kod },blk },;
  { center("Медицинская специальность",40), {|| padr(f1get_tmp_V015(),40) },blk },;
  { " ", {|| tmp_ga->vs },blk },;
  { center("подчинение",21), {|| left(tmp_ga->name_up,21) },blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1get_tmp_ga(nk,ob,"edit",a_spec) }
if valtype(a_spec) == "A"
  Ins_Array(t_arr[BR_COLUMN], 1, {" ", {|| iif(tmp_ga->isn==1,""," ") }, blk })
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Ins>^ - отметить специальность;  ^<F2>^ - поиск по подстроке") }
else
  t_arr[BR_ENTER] := {|| iif(tmp_ga->uroven==0, (func_error(4,"Запрещается выбирать данную специальность"),ret:=nil),;
                                                (ret := {tmp_ga->kod,alltrim(tmp_ga->name)})) }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
endif
fl := .f. ; nRec := 0
if !(valtype(a_spec) == "A") .and. k != NIL
  set order to 2
  find (k)
  if (fl := found())
    nRec := recno()
  endif
  set order to 1
endif
if !fl
  nRec := 0
endif
go top
if nRec > 0
  if kolRec-nRec < t_arr[BR_BOTTOM]-t_arr[BR_TOP]-3 // последняя страница?
    keyboard chr(K_END)+replicate(chr(K_UP),kolRec-nRec-1)
  else
    goto (nRec)
  endif
endif
edit_browse(t_arr)
if valtype(a_spec) == "A"
  s := ""
  asize(a_spec,0)
  go top
  do while !eof()
    if tmp_ga->isn == 1
      s += alltrim(tmp_ga->kod)+","
      aadd(a_spec,int(val(tmp_ga->kod)))
      tmp_ga->isn := 0
    endif
    skip
  enddo
  if empty(s)
    s := "---"
  else
    s := left(s,len(s)-1)
  endif
  ret := {1,s}
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
return ret

***** 07.08.16
Static Function f1get_tmp_V015()
Local s := afteratnum(".",tmp_ga->name,1)
s := space(2*tmp_ga->uroven)+s
return s

*****
Function is_up_usl(arr_usl,mkod)
Local i := 0, tmp_select := select()
select USL
do while .t.
  find (str(mkod,4))
  if !found() ; exit ; endif
  if usl->kod_up == 0 .or. i > 20
    exit
  endif
  mkod := usl->kod_up ; ++i
enddo
if tmp_select > 0
  select(tmp_select)
endif
return ( ascan(arr_usl,usl->kod) > 0 )

***** 03.01.19
Function input_usluga(arr_tfoms)
Local ar, musl, arr_usl, buf, fl_tfoms := (valtype(arr_tfoms)=="A")
ar := GetIniSect(tmp_ini,"uslugi")
musl := padr(a2default(ar,"shifr"),10)
if (musl := input_value(18,6,20,73,color1,;
          space(17)+"Введите шифр услуги",musl,"@K")) != NIL .and. !empty(musl)
  buf := save_maxrow()
  mywait()
  musl := transform_shifr(musl)
  SetIniSect(tmp_ini,"uslugi",{{"shifr",musl}})
  R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
  find (musl)
  if found()
    susl := musl
    arr_usl := {usl->kod,alltrim(usl->shifr)+". "+alltrim(usl->name),usl->shifr}
  else
    func_error(4,"Услуга с шифром "+alltrim(musl)+" не найдена в нашем справочнике!")
    if fl_tfoms
      arr_usl := {0,"",""}
    endif
  endif
  usl->(dbCloseArea())
  if fl_tfoms
    use_base("lusl")
    find (musl)
    if found()
      arr_tfoms[1] := lusl->(recno())
      arr_tfoms[2] := alltrim(lusl->shifr)+". "+alltrim(lusl->name)
      arr_tfoms[3] := lusl->shifr
    endif
    lusl->(dbCloseArea())
    lusl18->(dbCloseArea())
    lusl19->(dbCloseArea())
  endif
  rest_box(buf)
endif
return arr_usl

*****
Function ret_1st_otd(lkod_uch)
Local k, tmp_select := select()
R_Use(dir_server+"mo_otd",,"OTD")
Locate for otd->kod_lpu == lkod_uch
if found()
  k := {otd->(recno()),alltrim(otd->name)}
else
  func_error(3,"Нет отделений для данного учреждения!")
endif
otd->(dbCloseArea())
if tmp_select > 0
  select(tmp_select)
endif
return k

***** вернуть процент выполнения плана
Function ret_trudoem(lkod_vr,ltrudoem,kol_mes,arr_m,/*@*/plan)
Local i := 0, trd := 0, ltrud, tmp_select := select()
plan := 0
do while i < kol_mes
  ltrud := 0
  // сначала поиск конкретного месяца
  select UCHP
  find (str(lkod_vr,4)+str(arr_m[1],4)+str(arr_m[2]+i,2))
  if found()
    ltrud := uchp->m_trud
  endif
  if empty(ltrud)  // если не нашли
    // то поиск среднемесячного плана
    select UCHP
    find (str(lkod_vr,4)+str(0,4)+str(0,2))
    if found()
      ltrud := uchp->m_trud
    endif
  endif
  plan += ltrud
  ++i
enddo
if plan > 0
  trd := ltrudoem / plan * 100
endif
select (tmp_select)
return trd

***** 13.02.14
FUNCTION input_uch(r,c,date1,date2)
Local ret, k, fl_is, tmp_select := select()
if !myFileDeleted(cur_dir+"tmp_ga"+sdbf)
  return ret
endif
if empty(glob_uch[1])
  ar := GetIniVar(tmp_ini,{{"uch_otd","uch","0"},;
                           {"uch_otd","otd","0"}} )
  glob_uch[1] := int(val(ar[1]))
  glob_otd[1] := int(val(ar[2]))
endif
dbcreate(cur_dir+"tmp_ga",{{"name","C",30,0},;
                           {"kod","N",3,0},;
                           {"is","L",1,0}})
use (cur_dir+"tmp_ga") new
R_Use(dir_server+"mo_uch",,"UCH")
go top
do while !eof()
  fl_is := between_date(uch->DBEGIN,uch->DEND,date1,date2)
  if iif(date1==NIL, .t., fl_is)
    select TMP_GA
    append blank
    replace name with uch->name, ;
            kod with uch->kod, ;
            is with fl_is
  endif
  select UCH
  skip
enddo
uch->(dbCloseArea())
select TMP_GA
if (k := tmp_ga->(lastrec())) == 1
  ret := {tmp_ga->kod,alltrim(tmp_ga->name)}
else
  index on upper(name) to (cur_dir+"tmp_ga")
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
if k == 0
  func_error(4,"Пустой справочник учреждений")
elseif k > 1
  ret := fget_tmp_ga(glob_uch[1],r,c,,"Выбор учреждения",.f.)
endif
if ret != NIL
  glob_uch := ret
  st_a_uch := {glob_uch}
  SetIniVar(tmp_ini,{{"uch_otd","uch",glob_uch[1]}})
endif
return ret

*****
Function inputE_otd(r1,c1,r2)
return input_otd(r1,c1,sys_date)

***** 13.02.14
FUNCTION input_otd(r,c,date1,date2,nTask)
Local ret, k, fl_is, tmp_select := select()
DEFAULT nTask TO X_OMS
if !myFileDeleted(cur_dir+"tmp_ga"+sdbf)
  return ret
endif
dbcreate(cur_dir+"tmp_ga",{{"name","C",30,0},;
                           {"kod","N",3,0},;
                           {"idump","N",2,0},;
                           {"tiplu","N",2,0},;
                           {"is","L",1,0}})
use (cur_dir+"tmp_ga") new
R_Use(dir_server+"mo_otd",,"OTD")
go top
do while !eof()
  if otd->KOD_LPU == glob_uch[1]
    if nTask == X_ORTO
      fl_is := between_date(otd->DBEGINO,otd->DENDO,date1,date2)
    elseif nTask == X_PLATN
      fl_is := between_date(otd->DBEGINP,otd->DENDP,date1,date2)
    else
      fl_is := between_date(otd->DBEGIN,otd->DEND,date1,date2)
    endif
    if iif(date1==NIL, .t., fl_is)
      select TMP_GA
      append blank
      replace name with otd->name, ;
              kod with otd->kod, ;
              idump with otd->idump, ;
              tiplu with otd->tiplu, ;
              is with fl_is
    endif
  endif
  select OTD
  skip
enddo
otd->(dbCloseArea())
select TMP_GA
if (k := tmp_ga->(lastrec())) == 1
  ret := {tmp_ga->kod,alltrim(tmp_ga->name),tmp_ga->idump,tmp_ga->tiplu}
else
  index on upper(name) to (cur_dir+"tmp_ga")
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
if k == 0
  func_error(4,"Не найдено отделений для данного учреждения")
elseif k > 1
  ret := fget_tmp_ga(glob_otd[1],r,c,,"Выбор отделения",.f.,alltrim(glob_uch[2]))
endif
if ret != NIL
  glob_otd := ret
  SetIniVar(tmp_ini,{{"uch_otd","otd",glob_otd[1]}})
endif
return ret

***** 29.10.18
Function input_perso(r,c,is_null,is_rab)
Static si := 1
Local fl := .f., fl1 := .f., mas_pmt, s_input, s_glob, s_pict, tmp_help := 0,;
      arr_dolj := {}, arr_kod := {}, lr, r1, r2, i, buf := save_row(maxrow())
DEFAULT is_null TO .t., is_rab TO .f.
mas_pmt := {"Поиск сотрудника по ~таб.номеру","Поиск сотрудника по ~фамилии"}
s_input := space(10)+"Введите табельный номер сотрудника"
s_glob := glob_human[5]
s_pict := "99999"
if (i := popup_prompt(r,c,si,mas_pmt)) == 0
  return .f.
elseif i == 1
  si := 1
  if (i := input_value(18,6,20,73,color1,s_input,s_glob,s_pict)) == NIL
    return .f.
  elseif i == 0
    if is_null
      glob_human := {0,"",0,0,0,"",0,0}
      return .t.
    else
      return .f.
    endif
  elseif i < 0
    return func_error(4,"Неверный ввод - отрицательный код!")
  endif
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  find (str(i,5))
  if found()
    glob_human := {perso->kod,;
                   alltrim(perso->fio),;
                   perso->uch,;
                   perso->otd,;
                   i,;
                   alltrim(perso->name_dolj),;
                   perso->prvs,;
                   perso->prvs_new }
    fl1 := .t.
  else
    func_error(4,"Сотрудника с табельным номером "+lstr(i)+" нет в базе данных персонала!")
  endif
  close databases
  return fl1
endif
si := 2
Private mr := r
mywait()
//help_code := H_Input_fio
if R_Use(dir_server+"mo_pers",,"PERSO")
  index on upper(fio) to (cur_dir+"tmp_pers") for kod > 0
  if glob_human[1] > 0
    goto (glob_human[1])
    fl := !eof() .and. !deleted()
  endif
  if !fl ; go top ; endif
  if Alpha_Browse(r,9,maxrow()-2,70,"f1inp_perso",color0,,,,,,,,,{"═","░","═","N/BG,W+/N,B/BG,BG+/B"} )
    lr := row()
    if perso->kod == 0
      func_error(4,"База данных персонала пустая!")
    else
      glob_human := {perso->kod,;
                     alltrim(perso->fio),;
                     perso->uch,;
                     perso->otd,;
                     perso->tab_nom,;
                     alltrim(perso->name_dolj),;
                     perso->prvs,;
                     perso->prvs_new }
      fl1 := .t.
    endif
  endif
endif
close databases
//help_code := tmp_help
rest_box(buf)
return fl1

***** 29.10.18
Function f1inp_perso(oBrow)
Local oColumn
oColumn := TBColumnNew(center("Ф.И.О.",30), {|| left(perso->fio,30) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Таб.№", {|| perso->tab_nom })
oColumn:defColor := {3,3}
oColumn:colorBlock := {|| {3,3} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Специальность",21), {|| padr(ret_tmp_prvs(perso->prvs,perso->prvs_new),21) })
oBrow:addColumn(oColumn)
return NIL

***** вернуть учреждение и отделение в GET'е
FUNCTION ret_uch_otd(k,r,c,date1,date2,nTask)
Local ret, n := 1
if k != NIL .and. k > 0
  glob_uch[1] := k
endif
if input_uch(r,c,date1,date2) != NIL
  if type("m1otd") == "N" .and. m1otd > 0
    glob_otd[1] := m1otd
  endif
  if input_otd(r,c,date1,date2,nTask) != NIL
    if valtype(motd) == "C"
      n := len(motd)
    endif
    m1otd := glob_otd[1] ; motd := alltrim(glob_otd[2])
    if len(motd) < n
      motd := padr(motd,n)
    endif
    ret := glob_uch
  endif
endif
return ret

*

***** удаление данных по зубной формуле в HUMANST (для платных услуг)
Function STdelHuman(ltip,lrec)
select HUMANST
do while .t.
  find (str(ltip,1)+str(lrec,8))
  if !found() ; exit ; endif
  DeleteRec(.t.)
enddo
return NIL

***** удаление данных по зубной формуле в картотеке
Function STdelKart(ltip,lrec)
select KART_ST
set order to 2
do while .t.
  find (str(ltip,1)+str(lrec,8))
  if !found() ; exit ; endif
  DeleteRec(.t.)
enddo
return NIL

***** добавление данных по зубной формуле
Function STappend(ltip,lrec,lkod_k,ldate_u,lu_kod,lkod_vr,_zf,_diag)
Local i, arr_zf := STretArrZF(_zf)
STdelKart(ltip,lrec)
if ltip == 2 // платные услуги
  STdelHuman(ltip,lrec)
endif
if len(arr_zf) > 0
  if ltip == 2 // платные услуги
    select HUMANST
    AddRec(1)
    humanst->TIP_BD    := ltip
    humanst->REC_BD    := lrec
    humanst->KOD_DIAG  := _diag
    humanst->ZF        := _zf
    humanst->(dbUnLock())
  endif
  select KART_ST
  set order to 2
  for i := 1 to len(arr_zf)
    AddRec(1)
    kart_st->KOD       := lkod_k
    kart_st->ZF        := arr_zf[i]
    kart_st->KOD_DIAG  := _diag
    kart_st->TIP_BD    := ltip
    kart_st->REC_BD    := lrec
    kart_st->DATE_U    := ldate_u
    kart_st->U_KOD     := lu_kod
    kart_st->KOD_VR    := lkod_vr
    kart_st->(dbUnLock())
  next
endif
return NIL

***** 17.12.18 добавление удалённого зуба
Function STappendDelZ(lkod_k,_zf,ldate_u,lu_kod)
Static arr_STdelzub
Local i, arr_zf := STretArrZF(_zf)
DEFAULT arr_STdelzub TO ret_arr_STdelzub()
my_debug(,print_array(arr_zf))
my_debug(,print_array(arr_STdelzub))
my_debug(,print_array({lu_kod}))
if len(arr_zf) > 0 .and. ascan(arr_STdelzub,lu_kod) > 0 .and. select("KARTDELZ") > 0
  my_debug(,'t')
  select KARTDELZ
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    if found()
      if !(kartdelz->DATE_U == ldate_u)
        G_RLock(forever)
        kartdelz->DATE_U := ldate_u
        kartdelz->(dbUnLock())
      endif
    else
      AddRec(7)
      kartdelz->KOD    := lkod_k
      kartdelz->ZF     := arr_zf[i]
      kartdelz->DATE_U := ldate_u
      kartdelz->(dbUnLock())
    endif
  next
endif
return NIL

***** 17.12.18 удаление удалённого зуба
Function STDelDelZ(lkod_k,_zf,lu_kod)
Static arr_STdelzub
Local i, arr_zf := STretArrZF(_zf)
DEFAULT arr_STdelzub TO ret_arr_STdelzub()
if len(arr_zf) > 0 .and. ascan(arr_STdelzub,lu_kod) > 0 .and. select("KARTDELZ") > 0
  select KARTDELZ
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    if found()
      DeleteRec(.t.)
    endif
  next
endif
return NIL

***** 11.12.2018 вернуть массив с кодами услуг удаления зуба
Function ret_arr_STdelzub()
Static arr := {;
  {"A16.07.030.001", "Удаление временного зуба"},;
  {"A16.07.030.002", "Удаление постоянного зуба"},;
  {"A16.07.030.003", "Удаление зуба сложное с разъединением корней"},;
  {"A16.07.039"    , "Операция удаления ретинированного, дистопированного или сверхкомплектного зуба"};
}
Static akod := {}
Local i, s, lkod := 0
/*if len(akod) == 0
  use_base("mo_su","MOSU1")
  akod := {}
  for i := 1 to len(arr)
    s := arr[i,1]
    select MOSU1
    set order to 3
    find (padr(s,20))
    do while mosu1->shifr1 == padr(s,20) .and. !eof()
      if !("*" $ mosu1->shifr)
        lkod := mosu1->kod ; exit
      endif
      skip
    enddo
    if lkod == 0
      set order to 1
      FIND (STR(-1,6))
      if found()
        G_RLock(forever)
      else
        AddRec(6)
      endif
      lkod := mosu1->kod := recno()
      mosu1->name := arr[i,2]
      mosu1->shifr1 := s
    endif
    aadd(akod,lkod)
  next
  mosu1->(dbCloseArea())
endif*/
return akod

***** 17.12.18 проверка, не удалён ли зуб
Function STverDelZub(lkod_k,arr_zf,ldate_u,ltip,lrec,/*@*/amsg)
Static arr_STdelzub
Local i
DEFAULT arr_STdelzub TO ret_arr_STdelzub()
if len(arr_STdelzub) > 0 .and. select("KARTDELZ") > 0
  select KARTDELZ
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    if found() .and. kartdelz->DATE_U < ldate_u
      aadd(amsg, lstr(arr_zf[i])+': данный зуб удален '+full_date(c4tod(kartdelz->DATE_U)))
    endif
  next
endif
/*if len(arr_STdelzub) > 0
  select KART_ST
  set order to 1
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    do while kart_st->KOD == lkod_k .and. kart_st->ZF == arr_zf[i]
      if !(kart_st->TIP_BD == ltip .and. kart_st->REC_BD == lrec)
        if kart_st->DATE_U < ldate_u .and. ascan(arr_STdelzub,kart_st->U_KOD) > 0
          aadd(amsg, lstr(arr_zf[i])+': данный зуб удален '+full_date(c4tod(kart_st->DATE_U)))
        endif
      endif
      skip
    enddo
  next
endif*/
return NIL

***** 16.01.19 проверка правильности ввода зубной формулы
Function STVerifyKolZf(arr_zf,mkol,/*@*/amsg,lshifr)
if valtype(arr_zf) == "A" .and. valtype(mkol) == "N"
  DEFAULT lshifr TO ""
  if len(arr_zf) == 0 //
    aadd(amsg, 'не введена зубная формула '+lshifr)
  elseif len(arr_zf) != mkol
    aadd(amsg, 'количество зубов не соответствует количеству введённых зубных формул '+lshifr)
  endif
endif
return !empty(amsg)

***** 31.01.19 проверка правильности ввода зубной формулы
Function STverifyZF(_zf,_date_r,_sys_date,/*@*/amsg,lshifr)
Static fz := {{11,18},{21,28},{31,38},{41,48},{51,55},{61,65},{71,75},{81,85}}
//               возраст больного с 14 лет   |       возраст до 5 лет
Local i, j, k, v, arr_zf := STretArrZF(_zf,@amsg,lshifr)
if len(arr_zf) > 0
  DEFAULT lshifr TO ""
  v := count_years(_date_r,_sys_date)
  for i := 1 to len(arr_zf)
    k := 0
    for j := 1 to len(fz)
      if between(arr_zf[i],fz[j,1],fz[j,2])
        k := j ; exit
      endif
    next
    if k == 0
      aadd(amsg, lstr(arr_zf[i])+' - неверная зубная формула '+lshifr)
    //elseif v <= 5 .and. between(k,1,4)
      //aadd(amsg, lstr(arr_zf[i])+' - у ребенка зубная формула взрослого '+lshifr)
    //elseif v > 14 .and. between(k,5,8)
      //aadd(amsg, lstr(arr_zf[i])+' - у взрослого зубная формула ребенка '+lshifr)
    endif
  next
endif
return arr_zf

***** 16.01.19 синтаксический анализ зубной формулы, возврат массива зубов
Function STretArrZF(_zf,/*@*/amsg,lshifr)
//Static ssymb := "12345678,-МДВЖН", nsymb := 15  так было у Демиденко Татьяны
Static ssymb := "12345678,-", nsymb := 10
Local i, j, s, tmps, v1, v2, arr_zf := {}
DEFAULT amsg TO {}, lshifr TO ""
s := charrem(" ",_zf) // удалить все пробелы
// проверяем на допустимые символы
tmps := charrem(" ",CHARREPL(ssymb, s, SPACE(nsymb)))
if !empty(tmps)
  aadd(amsg, '"'+tmps+'" - зубная формула: некорректные символы '+lshifr)
endif
for i := 1 to numtoken(s,",")
  tmps := token(s,",",i)
  if "-" $ tmps // обработка диапазона
    v1 := token(tmps,"-",1)
    v2 := token(tmps,"-",2)
  else // одиночное значение
    v1 := v2 := tmps
  endif
  v1 := int(val(v1))
  v2 := int(val(v2))
  if v2 < v1
    aadd(amsg, '"'+tmps+'" - зубная формула: некорректный диапазон '+lshifr)
    v2 := v1
  endif
  for j := v1 to v2
    aadd(arr_zf,j) // массив зубов
  next
next
return arr_zf

***** 16.01.19 является ли случай стоматологическим для ввода зубной формулы
Function STisZF(_USL_OK,_PROFIL)
return (_USL_OK == 3 .and. eq_any(_PROFIL,85,86,87,88,89,90,140,171))

***** проверка на правильность серии удостоверения личности
Function val_ud_ser(par,k,s,/*@*/msg)
Local fl := .t., i, c, _sl, _sr, _n
DEFAULT msg TO ""
s := alltrim(s)
if k == 14
  _sl := ALLTRIM(TOKEN(s, " ", 1))
  _sr := ALLTRIM(TOKEN(s, " ", 2))
  IF (EMPTY(_sl) .OR. LEN(_sl) != 2 .OR. !yes_number(_sl)) .or. ;
     (EMPTY(_sr) .OR. LEN(_sr) != 2 .OR. !yes_number(_sr))
    msg := 'серия паспорта РФ должна состоять из двух двузначных чисел'
  ENDIF
elseif eq_any(k,1,3) // "Паспорт гражд.СССР" или "Свид-во о рождении"
  _n := NUMTOKEN(s, "-") - 1
  _sl := ALLTRIM(TOKEN(s, "-", 1)) ; _sl := gniRIMTORUS(_sl)
  _sr := ALLTRIM(TOKEN(s, "-", 2))
  IF _n == 0
    msg := 'отсутствует разделитель "-" частей серии'
  ELSEIF _n > 1
    msg := 'лишний разделитель "-"'
  ELSEIF EMPTY(_sl)
    msg := 'отсутствует числовая часть серии'
  ELSEIF !EMPTY(CHARREPL("1УХЛС", _sl, SPACE(10)))
    msg := 'числовая часть серии состоит из символов: 1 У Х Л С (I V X L C)'
  ELSEIF !(_sl == gniRIMTORUS(gniNOMTORIM(gniRIMTONOM(gniRUSTORIM(_sl)))))
    msg := 'некорректно введена числовая часть серии'
  ELSEIF EMPTY(_sr) .OR. LEN(_sr) != 2 .OR. !yes_rus_str(_sr)
    msg := 'после разделителя "-" должны быть ДВЕ pусcкие заглавные буквы'
  ENDIF
endif
if !empty(msg)
  msg := '"'+s+'" - '+msg
  if par == 1  // для GET-системы
    func_error(4,msg)
  else  // для проверки ТФОМС
    fl := .f.
  endif
endif
return fl

*

***** проверка на правильность номера удостоверения личности
Function val_ud_nom(par,k,s,/*@*/msg)
Static arr_d := {;
 { 1,6  },;
 { 3,6  },;
 { 4,7  },;
 { 6,6  },;
 { 7,6,7},;
 { 8,7  },;
 {14,6,7},;
 {15,7  },;
 {16,6,7},;
 {17,6  }}
Local fl := .t., d1, d2
DEFAULT msg TO ""
s := alltrim(s)
if (j := ascan(arr_d, {|x| x[1] == k })) > 0
  if !yes_number(s)
     msg := 'недопустимый символ в номере уд.личности "'+inieditspr(A__MENUVERT, menu_vidud, k)+'"'
  else
    d1 := arr_d[j,2]
    d2 := iif(len(arr_d[j]) == 2, d1, arr_d[j,3])
    if !between(len(s),d1,d2)
      msg := 'неверное кол-во цифр в номере уд.личности "'+inieditspr(A__MENUVERT, menu_vidud, k)+'"'
    endif
  endif
endif
if !empty(msg)
  msg := '"'+s+'" - '+msg
  if par == 1  // для GET-системы
    func_error(4,msg)
  else  // для проверки ТФОМС
    fl := .f.
  endif
endif
return fl

***** проверка: "в строке все символы цифры?"
Static Function yes_number(s)
return EMPTY(CHARREPL("0123456789", s, SPACE(10)))

***** проверка: "в строке все символы русские буквы?"
Static Function yes_rus_str(s)
return EMPTY(CHARREPL("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ", s, SPACE(33)))

***** рисмкое число, записанное латинскими символами, записать русскими символами
Static FUNCTION gniRIMTORUS(_s)
RETURN CHARREPL("IVXLC", _s, "1УХЛС")

***** рисмкое число, записанное русскими символами, записать латинскими символами
Static FUNCTION gniRUSTORIM(_s)
RETURN CHARREPL("1УХЛС", _s, "IVXLC")

***** перевести арабское число в римское
Static FUNCTION gniNOMTORIM(_s, _c1, _c2, _c3, _c4, _c5, _c6, _c7)
LOCAL _s1 := REPLALL(STR(_s, 3), "0"), _s2, _s3, _n1, _n2, _n3, _ret := ""
DEFAULT _c1 TO "I", _c2 TO "V", _c3 TO "X", _c4 TO "L",;
        _c5 TO "C", _c6 TO "D", _c7 TO "M"
_n3 := VAL(SUBSTR(_s1, LEN(_s1), 1))
_n2 := VAL(SUBSTR(_s1, LEN(_s1) - 1, 1))
_n1 := VAL(SUBSTR(_s1, LEN(_s1) - 2, 1))
_ret += gniDIGTORIM(_n1, _c5, _c6, _c7)
_ret += gniDIGTORIM(_n2, _c3, _c4, _c5)
_ret += gniDIGTORIM(_n3, _c1, _c2, _c3)
RETURN _ret

***** перевести римское число в арабское
Static FUNCTION gniRIMTONOM(_s, _c1, _c2, _c3, _c4, _c5, _c6, _c7)
LOCAL _ret := 0, i, _nl, aArr := {}
DEFAULT _c1 TO "I", _c2 TO "V", _c3 TO "X", _c4 TO "L",;
        _c5 TO "C", _c6 TO "D", _c7 TO "M"
_s := ALLTRIM(_s)
_nl := LEN(_s)
FOR i := 1 TO _nl
  AADD(aArr, SUBSTR(_s, i, 1))
NEXT
FOR i := 1 TO _nl
  IF aArr[i] == _c7
    _ret += 1000
  ELSEIF aArr[i] == _c6
    _ret += 500
  ELSEIF aArr[i] == _c5
    IF i < _nl .AND. (aArr[i + 1] == _c6 .OR. aArr[i + 1] == _c7)
      _ret -= 100
    ELSE
      _ret += 100
    ENDIF
  ELSEIF aArr[i] == _c4
    _ret += 50
  ELSEIF aArr[i] == _c3
    IF i < _nl .AND. (aArr[i + 1] == _c4 .OR. aArr[i + 1] == _c5)
      _ret -= 10
    ELSE
      _ret += 10
    ENDIF
  ELSEIF aArr[i] == _c2
    _ret += 5
  ELSEIF aArr[i] == _c1
    IF i < _nl .AND. (aArr[i + 1] == _c2 .OR. aArr[i + 1] == _c3)
      _ret -= 1
    ELSE
      _ret += 1
    ENDIF
  ENDIF
NEXT
RETURN _ret

***** перевести арабскую цифру в римскую
Static FUNCTION gniDIGTORIM(_s, _c1, _c2, _c3)
LOCAL _c := ""
DO CASE
  CASE _s == 1
    _c := _c1
  CASE _s == 2
    _c := _c1 + _c1
  CASE _s == 3
    _c := _c1 + _c1 + _c1
  CASE _s == 4
    _c := _c1 + _c2
  CASE _s == 5
    _c := _c2
  CASE _s == 6
    _c := _c2 + _c1
  CASE _s == 7
    _c := _c2 + _c1 + _c1
  CASE _s == 8
    _c := _c2 + _c1 + _c1 + _c1
  CASE _s == 9
    _c := _c1 + _c3
ENDCASE
RETURN _c

*

***** проверка СНИЛС
Function val_snils(s,par,/*@*/msg)
Local fl := .t., v1, v2, i, k := len(charrem(" ",s))
DEFAULT msg TO ""
if k == 0
  //
elseif k == 11
  if s == replicate("0",11)
    msg := 'В поле "СНИЛС" одни нули'
  else
    v1 := int(val(left(s,9)))
    if v1 > 1001998
      v1 := 0
      for i := 1 to 9
        v1 += int(val(substr(s,10-i,1))*i)
      next
      v1 := int(v1 % 101)
      if v1 == 100 ; v1 := 0 ; endif
      v2 := int(val(right(s,2)))
      if v1 != v2
        msg := 'Неверная контрольная сумма в коде "СНИЛС"'
      endif
    else
      msg := 'Значение поля "СНИЛС" меньше "001-001-998"'
    endif
  endif
else
  msg := 'Заполнены не все знаки поля "СНИЛС"'
endif
if !empty(msg)
  if par == 1  // для GET-системы
    func_error(4,msg)
  else  // для проверки ТФОМС
    fl := .f.
  endif
endif
return fl

*

***** ввод фразы для места работы из списка
Function v_vvod_mr()
Local k, nrow := row(), ncol := col(), fl := .f., tmp_keys, tmp_gets
tmp_keys := my_savekey()
if (get := get_pointer("MMR_DOL")) != NIL .and. get:hasFocus
  save gets to tmp_gets
  setcursor(0)
  if !empty(k := input_s_mr())
    fl := .t.
  else
    @ nrow,ncol say ""
  endif
  restore gets from tmp_gets
  if fl
    keyboard (alltrim(k))
  endif
  setcursor()
endif
my_restkey(tmp_keys)
return NIL

***** выбор фразы для места работы
Function input_s_mr()
Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret := ""
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 26
t_arr[BR_RIGHT] := 79
t_arr[BR_OPEN] := {|| f1_s_mr(,,"open") }
t_arr[BR_CLOSE] := {|| sa->(dbCloseArea()) }
t_arr[BR_COLOR] := color0
//t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
t_arr[BR_COLUMN] := {{ center("Список фраз для места работы",50),{|| sa->name} }}
s_msg := "^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление"
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление;  ^<F2>^ - поиск") }
t_arr[BR_EDIT] := {|nk,ob| f1_s_mr(nk,ob,"edit") }
t_arr[BR_ENTER] := {|| ret := alltrim(sa->name) }
edit_browse(t_arr)
if tmp_select > 0
  select(tmp_select)
endif
restscreen(buf)
return ret

*****
Function f1_s_mr(nKey,oBrow,regim)
Static tmp := " "
Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
      fl := .f., rec, mkod, tmp_color := setcolor()
do case
  case regim == "open"
    G_Use(dir_server+"s_mr",,"SA")
    index on upper(name) to (cur_dir+"tmp_mr")
    go top
    ret := !eof()
  case regim == "edit"
    if nKey == K_F2
      Private tmp1 := padr(tmp,30)
      if (tmp1 := input_value(pr2-2,pc1+1,pr2,pc2-1,color1,;
                              "Подстрока поиска",;
                              tmp1,"@K@!")) != NIL .and. !empty(tmp1)
        tmp := alltrim(tmp1)
        Private tmp_mas := {}, tmp_kod := {}
        rec := recno()
        go top
        locate for tmp $ upper(name)
        do while !eof()
          if ++j > 4000 ; exit ; endif
          aadd(tmp_mas,sa->name) ; aadd(tmp_kod,sa->(recno()))
          continue
        enddo
        goto (rec)
        if len(tmp_kod) == 0
          stat_msg("Неудачный поиск!") ; mybell(2)
        else
          status_key("^<Esc>^ - отказ от выбора")
          if (j := popup(pr1+1,pc1+1,pr2-1,pc2-1,tmp_mas,,color5,,,,;
                         'Результат поиска по подстроке "'+tmp+'"',"B/W")) > 0
            oBrow:gotop()
            goto (tmp_kod[j])
          endif
          ret := 0
        endif
      endif
    elseif nKey == K_INS
      rec := recno()
      Private mname := if(nKey == K_INS, space(50), sa->name),;
              gl_area := {1,0,23,79,0}
      buf1 := box_shadow(pr2-2,pc1+1,pr2,pc2-1,color8,;
                    iif(nKey==K_INS,"Добавление","Редактирование"),cDataPgDn)
      setcolor(cDataCGet)
      @ pr2-1,pc1+2 get mname
      status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи")
      myread()
      if lastkey() != K_ESC .and. !empty(mname)
        if nKey == K_INS
          AddRecN()
          rec := recno()
        else
          G_RLock(forever)
        endif
        replace name with mname
        COMMIT
        UNLOCK
        oBrow:goTop()
        goto (rec)
        ret := 0
      endif
      setcolor(tmp_color)
      rest_box(buf) ; rest_box(buf1)
    else
      keyboard ""
    endif
endcase
return ret

*

***** 07.02.13 ввод фразы для адреса из списка
Function v_vvod_adres()
Local k, nrow := row(), ncol := col(), fl := .f., tmp_keys, tmp_gets
tmp_keys := my_savekey()
if (get := get_pointer("MULICADOM")) != NIL .and. get:hasFocus
  save gets to tmp_gets
  setcursor(0)
  if !empty(k := input_s_adres())
    fl := .t.
  else
    @ nrow,ncol say ""
  endif
  restore gets from tmp_gets
  if fl
    keyboard (alltrim(k)+" ")
  endif
  setcursor()
endif
my_restkey(tmp_keys)
return NIL

***** выбор фразы для адреса
Function input_s_adres()
Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret := ""
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 36
t_arr[BR_RIGHT] := 79
t_arr[BR_OPEN] := {|| f1_s_adres(,,"open") }
t_arr[BR_CLOSE] := {|| sa->(dbCloseArea()) }
t_arr[BR_COLOR] := color0
//t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
t_arr[BR_COLUMN] := {{ center("Список фраз для адреса",40),{|| sa->name} }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление") }
t_arr[BR_EDIT] := {|nk,ob| f1_s_adres(nk,ob,"edit") }
t_arr[BR_ENTER] := {|| ret := alltrim(sa->name) }
edit_browse(t_arr)
if tmp_select > 0
  select(tmp_select)
endif
restscreen(buf)
return ret

*

***** форма настройки включаемых/исключаемых услуг
Function forma_nastr(s_titul,arr_strok,nfile,arr,fl)
Local i, j, r := 2, tmp_color := setcolor(cDataCGet)
Local buf := savescreen(), blk := {|| f9_f_nastr(s_titul,arr_strok) }
if nfile != NIL
  arr := rest_arr(nfile)
endif
if arr == NIL .or. empty(arr)
  arr := {{},{}}
endif
Private mda[15], mnet[15]
afill(mda,space(10))
aeval(arr[1], {|x,i| mda[i] := padr(x,10) } )
afill(mnet,space(10))
aeval(arr[2], {|x,i| mnet[i] := padr(x,10) } )
box_shadow(r,0,23,79,color1,s_titul,color8)
str_center(r+2,"Данный режим предназначен для настройки")
j := r + 2
aeval(arr_strok, {|x| str_center(++j,x,"G+/B") } )
++j
@ ++j,4 say "     Включаемые услуги (шаблон)          Исключаемые услуги (шаблон)"
for i := 1 to 15
  @ j+i,15 say str(i,2) get mda[i]
next
for i := 1 to 15
  @ j+i,52 say str(i,2) get mnet[i]
next
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запомнить настройки;  ^<F9>^ - печать списка услуг")
SETKEY(K_F9, blk)
myread()
SETKEY(K_F9, NIL)
fl := .f.
if lastkey() != K_ESC .and. f_Esc_Enter(1)
  fl := .t.
  arr := {{},{}}
  for i := 1 to 15
    if !empty(mda[i])
      aadd(arr[1],mda[i])
    endif
    if !empty(mnet[i])
      aadd(arr[2],mnet[i])
    endif
  next
  if nfile != NIL
    save_arr(arr,nfile)
  endif
endif
setcolor(tmp_color)
restscreen(buf)
return arr

*****
Function f9_f_nastr(l_titul,a_strok)
Local sh := 80, HH := 77, buf := save_maxrow(), n_file := "frm_nast"+stxt
Local i, k, nrow := row(), ncol := col(), tmp_keys, tmp_gets, ta := {}
mywait()
tmp_keys := my_savekey()
save gets to tmp_gets
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center(l_titul,sh))
add_string("")
add_string(center("Данный список услуг представляет содержание",sh))
aeval(a_strok, {|x| add_string(center(x,sh)) } )
add_string("")
add_string("      Включаемые услуги (шаблон)          Исключаемые услуги (шаблон)")
k := 0
for i := 1 to 15
  aadd(ta,space(20)+mda[i]+space(20)+mnet[i])
  if !emptyall(mda[i],mnet[i])
    k := i
  endif
next
for i := 1 to k
  add_string(ta[i])
next
R_Use(dir_server+"uslugi",,"USL")
index on fsort_usl(shifr) to (cur_dir+"tmpu")
go top
do while !eof()
  if _f_usl_danet(mda,mnet)
    verify_FF(HH,.t.,sh)
    add_string(usl->shifr+" "+rtrim(usl->name))
  endif
  skip
enddo
usl->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.f.,,,5)
//
restore gets from tmp_gets
my_restkey(tmp_keys)
setcursor()
return NIL

*****
Function ret_f_nastr(a_usl,lshifr)
Local i, shb, fl := .f.
for i := 1 to len(a_usl[1])
  if !empty(shb := a_usl[1,i])
    if "*" $ shb .or. "?" $ shb
      fl := like(alltrim(shb),lshifr)
    else
      fl := (shb == lshifr)
    endif
    if fl ; exit ; endif
  endif
next
if fl
  for i := 1 to len(a_usl[2])
    if !empty(shb := a_usl[2,i])
      if "*" $ shb .or. "?" $ shb
        fl := !like(alltrim(shb),lshifr)
      else
        fl := !(shb == lshifr)
      endif
      if !fl ; exit ; endif
    endif
  next
endif
return fl

*****
Function _f_usl_danet(a_da,a_net)
Local fl, i, shb
fl := usl->is_nul .or. !emptyall(usl->cena,usl->cena_d)
if !fl .and. is_task(X_PLATN) // для платных услуг
  fl := usl->is_nulp .or. !emptyall(usl->pcena,usl->pcena_d,usl->dms_cena)
endif
if fl
  fl := .f.
  for i := 1 to len(a_da)
    if !empty(shb := a_da[i])
      if "*" $ shb .or. "?" $ shb
        fl := like(alltrim(shb),usl->shifr)
      else
        fl := (shb == usl->shifr)
      endif
      if fl ; exit ; endif
    endif
  next
  if fl
    for i := 1 to len(a_net)
      if !empty(shb := a_net[i])
        if "*" $ shb .or. "?" $ shb
          fl := !like(alltrim(shb),usl->shifr)
        else
          fl := !(shb == usl->shifr)
        endif
        if !fl ; exit ; endif
      endif
    next
  endif
endif
return fl

***** 12.01.20 определение КСГ по остальным введённым полям ввода - 2019-20 год
Function definition_KSG(par,k_data2)
// файлы "human", "human_" и "human_2" открыты и стоят на нужной записи
//       "human" открыт для записи суммы случая
// выполнено use_base("human_u","HU") - для записи
// выполнено use_base("mo_hu","MOHU") - для записи
Static ver_year := 0 // последний проверяемый год
Static ad_ksg_3, ad_ksg_4
Static sp0, sp1, sp6, sp15
Static a_iskl_1 := {; // исключение из правил №1
  {"st02.010","st02.008"},;
  {"st02.011","st02.008"},;
  {"st02.010","st02.009"},;
  {"st14.001","st04.002"},;
  {"st14.004","st04.002"},;
  {"st21.001","st21.007"},;
  {"st34.002","st34.001"},;
  {"st34.002","st26.001"},;
  {"st34.006","st30.003"},;
  {"st09.001","st30.005"},;
  {"st31.002","st31.017"},;
  {"st37.001",""},;
  {"st37.002",""},;
  {"st37.003",""},;
  {"st37.004",""},;
  {"st37.005",""},;
  {"st37.006",""},;
  {"st37.007",""},;
  {"st37.008",""},;
  {"st37.009",""},;
  {"st37.010",""},;
  {"st37.011",""},;
  {"st37.012",""},;
  {"st37.013",""},;
  {"st37.014",""},;
  {"st37.015",""},;
  {"st37.016",""},;
  {"st37.017",""},;
  {"st37.018",""},;
  {"ds37.001",""},;
  {"ds37.002",""},;
  {"ds37.003",""},;
  {"ds37.004",""},;
  {"ds37.005",""},;
  {"ds37.006",""},;
  {"ds37.007",""},;
  {"ds37.008",""},;
  {"ds37.009",""},;
  {"ds37.010",""},;
  {"ds37.011",""},;
  {"ds37.012",""};
 }
Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0, lstentvmp := 0,;
      i, j, k, c, s, ar, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol, lprofil_k,;
      lfio, cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, ;
      lksg := "", lcena := 0, osn_diag3, lprofil, ldnej := 0, y := 0, m := 0, d := 0,;
      osn_diag := space(6), sop_diag := {}, osl_diag := {}, tmp, lrslt, akslp, akiro,;
      lad_cr := "", lad_cr1 := "", lis_err := 0, akslp2, lpar_org := 0, lyear,;
      kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, lkiro := 0, lkslp := "", lbartell := "",;
      lusl, susl, s_dializ := 0, ahu := {}, amohu := {}, date_usl := stod("20200101")
DEFAULT par TO 1, sp0 TO "", sp1 TO space(1), sp6 TO space(6), sp15 TO space(20)
Private pole
if par == 1
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  if (lvmp := human_2->VMP) == 1
    lvidvmp := human_2->METVMP
  endif
  lad_cr  := alltrim(human_2->pc3)
  lfio    := alltrim(human->fio)
  ln_data := human->n_data
  if valtype(k_data2) == "D"
    lk_data := k_data2
  else
    lk_data := human->k_data
  endif
  lusl    := human_->USL_OK
  ldate_r := iif(human_->NOVOR > 0, human_->date_r2, human->date_r)
  lpol    := iif(human_->NOVOR > 0, human_->pol2,    human->pol)
  lvr     := iif(human->VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := human_->profil
  lprofil_k := human_2->profil_k
  lrslt   := human_->rslt_new
  // массив диагнозов (минимум два)
  mdiagnoz := diag_to_array(,,,,.t.)
  if len(mdiagnoz) > 0
    osn_diag := mdiagnoz[1]
    if len(mdiagnoz) > 1
      sop_diag := aclone(mdiagnoz)
      Del_Array(sop_diag,1) // начиная со 2-го - сопутствующие диагнозы
    endif
  endif
  if !empty(human_2->OSL1)
    aadd(osl_diag,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(osl_diag,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(osl_diag,human_2->OSL3)
  endif
  if lusl < 3 .and. lVMP == 0 .and. f_is_oncology(1) == 2
    if select("ONKSL") == 0
      G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
    endif
    select ONKSL
    find (str(human->kod,7))
    lad_cr := alltrim(onksl->crit)
    if lad_cr == "нет"
      lad_cr := ""
    endif
    lad_cr1 := alltrim(onksl->crit2)
    lis_err := onksl->is_err
  endif
else // из режима импорта случаев
  if (lvmp := iif(empty(ihuman->VID_HMP), 0, 1)) == 1
    lvidvmp := ihuman->METOD_HMP
  endif
  lad_cr  := alltrim(ihuman->ad_cr)
  if lad_cr == "нет"
    lad_cr := ""
  endif
  lad_cr1 := alltrim(ihuman->ad_cr2)
  lis_err := ihuman->is_err
  lusl    := ihuman->USL_OK
  lfio    := alltrim(ihuman->fio)
  ln_data := ihuman->date_1
  if valtype(k_data2) == "D"
    lk_data := k_data2
  else
    lk_data := ihuman->date_2
  endif
  ldate_r := iif(ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr)
  lpol    := iif(ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w)
  lpol    := iif(lpol == 1, "М","Ж")
  lvr     := iif(m1VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := ihuman->profil
  lprofil_k := ihuman->profil_k
  lrslt   := ihuman->rslt
  osn_diag := padr(ihuman->DS1,6)
  if !empty(ihuman->DS2)
    aadd(sop_diag, padr(ihuman->DS2,6))
  endif
  if !empty(ihuman->DS2_2)
    aadd(sop_diag, padr(ihuman->DS2_2,6))
  endif
  if !empty(ihuman->DS2_3)
    aadd(sop_diag, padr(ihuman->DS2_3,6))
  endif
  if !empty(ihuman->DS2_4)
    aadd(sop_diag, padr(ihuman->DS2_4,6))
  endif
  if !empty(ihuman->DS2_5)
    aadd(sop_diag, padr(ihuman->DS2_5,6))
  endif
  if !empty(ihuman->DS2_6)
    aadd(sop_diag, padr(ihuman->DS2_6,6))
  endif
  if !empty(ihuman->DS2_7)
    aadd(sop_diag, padr(ihuman->DS2_7,6))
  endif
  mdiagnoz := aclone(sop_diag)
  Ins_Array(mdiagnoz,1,osn_diag)
  if !empty(ihuman->DS3)
    aadd(osl_diag, padr(ihuman->DS3,6))
  endif
  if !empty(ihuman->DS3_2)
    aadd(osl_diag, padr(ihuman->DS3_2,6))
  endif
  if !empty(ihuman->DS3_3)
    aadd(osl_diag, padr(ihuman->DS3_3,6))
  endif
endif
lyear := year(lk_data)
if eq_any(lad_cr,'60','61')
  lbartell := lad_cr
  lad_cr := ""
endif
ldni := ln_data - ldate_r // для ребёнка возраст в днях
count_ymd(ldate_r,ln_data,@y,@m,@d)
date_usl := lk_data //!!!!!!!!!!!!раскомментировать после теста!!!!!!!!!!!!!!!
if lusl == 1 // стационар
  if (ldnej := lk_data - ln_data) == 0
    ldnej := 1
  endif
endif
aadd(ars,lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.)")
s := iif(lVMP==1,'ВМП ',' ')
if par == 1
  s += alltrim(uch->name)+'/'+alltrim(otd->name)+'/'
endif
s += 'профиль "'+inieditspr(A__MENUVERT, glob_V002, lprofil)+'"'
aadd(ars,s)
aadd(ars,' д.р.'+full_date(ldate_r)+iif(lvr==0,'(взр.','(реб.')+'), '+iif(lpol=='М','муж.','жен.')+;
         ', осн.диаг.'+osn_diag+;
         iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
         iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag))))
if empty(osn_diag)
  aadd(arerr,' не введён основной диагноз')
  return {ars,arerr,lksg,lcena,{},{}}
endif
if f_put_glob_podr(lusl,date_usl,arerr) // если не заполнен код подразделения
  return {ars,arerr,lksg,lcena,{},{}}
endif
if lvmp > 0
  if lvidvmp == 0
    aadd(arerr,' не введён метод ВМП')
  elseif ascan(arr_12_VMP,lvidvmp) == 0
    aadd(arerr,' для метода ВМП '+lstr(lvidvmp)+' нет услуги ТФОМС')
  else
    lksg := "1.12."+lstr(lvidvmp)
    aadd(ars," для "+lstr(lvidvmp)+" метода ВМП введена услуга "+lksg)
    lcena := ret_cena_KSG(lksg,lvr,date_usl)
    if lcena > 0
      aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,0))
    else
      aadd(arerr,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lksg)
    endif
  endif
  return {ars,arerr,alltrim(lksg),lcena,{},{}}
endif
lal := "LUSL"+iif(lyear==2020,"","19")
lalf := "LUSLF"+iif(lyear==2020,"","19")
if select("LUSLF") == 0
  use_base("LUSLF")
endif
// составляем массив услуг и массив манипуляций
if par == 1
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,date_usl))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if left(lshifr,5) == "60.3."
      s_dializ += hu->stoim_1
    endif
    if ascan(ahu,lshifr) == 0
      aadd(ahu,lshifr)
    endif
    if lusl == 2 .and. left(lshifr,5)=='55.1.'
      ldnej += hu->kol_1
    endif
    select HU
    skip
  enddo
  if select("MOSU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if mosu->(recno()) != mohu->u_kod
      mosu->(dbGoto(mohu->u_kod))
    endif
    if ascan(amohu,mosu->shifr1) == 0
      aadd(amohu,mosu->shifr1)
    endif
    dbSelectArea(lalf)
    find (padr(mosu->shifr1,20))
    if found() .and. !empty(&lalf.->par_org)
      lpar_org += len(List2Arr(mohu->zf))
    endif
    select MOHU
    skip
  enddo
else
  select IHU
  find (str(ihuman->kod,10))
  do while ihu->kod == ihuman->kod .and. !eof()
    if eq_any(left(ihu->CODE_USL,1),"A","B")
      if ascan(amohu,ihu->CODE_USL)==0
        aadd(amohu,ihu->CODE_USL)
      endif
      dbSelectArea(lalf)
      find (padr(ihu->CODE_USL,20))
      if found() .and. !empty(&lalf.->par_org)
        lpar_org += len(List2Arr(ihu->par_org))
      endif
    else
      if ascan(ahu,alltrim(ihu->CODE_USL)) == 0
        aadd(ahu,alltrim(ihu->CODE_USL))
      endif
      if left(ihu->CODE_USL,5) == "60.3."
        s_dializ += ihu->SUMV_USL
      endif
      if lusl == 2 .and. left(ihu->CODE_USL,5)=='55.1.'
        ldnej += ihu->KOL_USL
      endif
    endif
    select IHU
    skip
  enddo
endif
if lvr == 0 //
  lage := '6'
  s := "взр."
else
  lage := '5'
  s := "дети"
  fl := .t.
  if ldni <= 28
    lage += '1' // дети до 28 дней
    s := "0-28дн."
    fl := .f.
  elseif ldni <= 90
    lage += '2' // дети до 90 дней
    s := "29-90дн."
    fl := .f.
  elseif y < 1 // до 1 года
    lage += '3' // дети от 91 дня до 1 года
    s := "91день-1год"
    fl := .f.
  endif
  if y <= 2 // до 2 лет включительно
    lage += '4' // дети до 2 лет
    if fl
      s := "до2лет включ."
    endif
  endif
endif
ars[1] := lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.)"
ars[3] := ' д.р.'+full_date(ldate_r)+'('+s+'), '+iif(lpol=='М','муж.','жен.')+;
          ', осн.диаг.'+osn_diag+;
          iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
          iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag)))
lsex := iif(lpol=='М','1','2')
llos := ''
if ldnej < 4
  llos += '1'
endif
/*
0 - КИРО не применяется
1 - длительность случая 3 койко-дня (дней лечения) и менее и пациенту выполнена хирургическая операция
    либо другое вмешательство, являющиеся классификационным критерием отнесения данного случая лечения
    к конкретной КСГ вне зависимости от сочетания с результатами обращения за медицинской помощью
2 - длительность случая 3 койко-дня (дней лечения) и менее, но хирургическое лечение либо другое вмешательство,
    определяющее отнесение к КСГ не проводилось и критерием отнесения в случае является код диагноза по МКБ 10
    вне зависимости от сочетания с результатами обращения за медицинской помощью;
3 - длительность случая 4 койко-дня (дней лечения) и более и пациенту выполнена хирургическая операция
    либо другое вмешательство, являющиеся классификационным критерием отнесения данного случая лечения
    к конкретной КСГ в сочетании с результатами обращения за медицинской помощью
    (Классификатор V009) 102, 105, 107, 110, 202, 205, 207
4 - длительность случая 4 койко-дня (дней лечения) и более, но хирургическое лечение либо другое вмешательство,
    определяющее отнесение к КСГ не проводилось, в сочетании с результатами обращения за медицинской помощью
    (Классификатор V009) 102, 105, 107, 110, 202, 205, 207
5 - случаи с несоблюдением режима введения лекарственного препарата (дней введения в схеме) согласно инструкции
    к препарату при длительности случая 3 койко-дня (дня лечения) и менее вне зависимости от результата обращения
    за медицинской помощью
6 - случаи с несоблюдением режима введения лекарственного препарата (дней введения в схеме) согласно инструкции
    к препарату при длительности случая 4 койко-дня (дня лечения) и более в сочетании с результатами обращения
    за медицинской помощью (Классификатор V009) 102, 105, 107, 110, 202, 205, 207
*/
//aadd(ars,'   ║age='+lage+' sex='+lsex+' los='+llos)
nfile := "_mo"+iif(lyear==2020,"0","9")+"k006"
if select("K006") == 0
  R_Use(exe_dir+nfile,{cur_dir+nfile,cur_dir+nfile+"_"},"K006")
  /*{"SHIFR",      "C",     10,      0},;
    {"DS",         "C",      6,      0},;
    {"DS1",        "M",     10,      0},;
    {"DS2",        "M",     10,      0},;
    {"SY",         "C",     20,      0},;
    {"AGE",        "C",      1,      0},;
    {"SEX",        "C",      1,      0},;
    {"LOS",        "C",      1,      0},;
    {"AD_CR",      "C",     10,      0},;
    {"AD_CR1",     "C",     10,      0},;
  index on substr(shifr,1,2)+ds+sy+age+sex+los to (cur_dir+sbase) // по диагнозу/операции
  index on substr(shifr,1,2)+sy+ds+age+sex+los to (cur_dir+sbase+"_") // по операции/диагнозу
  */
else
  if ver_year == lyear // проверяем: если тот же год, что только что проверяли
    // ничего не меняем
  else // иначе переоткрываем данный файл с необходимым годом и тем же алиасом
    k006->(dbCloseArea())
    R_Use(exe_dir+nfile,{cur_dir+nfile,cur_dir+nfile+"_"},"K006")
  endif
endif
ver_year := lyear
fl_reabil := (ascan(ahu,"1.11.2") > 0 .or. ascan(ahu,"55.1.4") > 0)
susl := iif(lusl == 1, "st", "ds")
// собираем КСГ по осн.диагнозу (терапевтические и комбинированные)
ar := {}
tmp := {}
select K006
set order to 1
find (susl+padr(osn_diag,6))
do while left(k006->shifr,2)==susl .and. k006->ds==padr(osn_diag,6) .and. !eof()
  lkoef := k006->kz
  dbSelectArea(lal)
  find (padr(k006->shifr,10))
  fl := lkoef > 0 .and. between_date(&lal.->DATEBEG,&lal.->DATEEND,date_usl)
  if fl
    fl := between_date(k006->DATEBEG,k006->DATEEND,date_usl)
  endif
  if fl
    sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
    sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
  endif
  j := 0
  if fl .and. !empty(k006->sy)
    if (i := ascan(amohu,k006->sy)) > 0
      j += 10
    else
      fl := .f.
    endif
  endif
  if fl .and. !empty(k006->age)
    if (fl := (k006->age $ lage))
      if k006->age == '1'
        j += 5
      elseif k006->age == '2'
        j += 4
      elseif k006->age == '3'
        j += 3
      elseif k006->age == '4'
        j += 2
      else
        j ++
      endif
    endif
  endif
  if fl .and. !empty(k006->sex)
    fl := (k006->sex == lsex)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->los)
    fl := (k006->los $ llos)
    if fl ; j ++ ; endif
  endif
  if fl
    if empty(lad_cr) // в случае нет доп.критерия
      if !empty(k006->ad_cr) // а в справочнике есть доп.критерий
        fl := .f.
      endif
    else // в случае есть доп.критерий
      if empty(k006->ad_cr) // а в справочнике нет доп.критерия
        fl := .f.
      else                  // а в справочнике есть доп.критерий
        fl := (lad_cr == alltrim(k006->ad_cr))
        if fl ; j ++ ; endif
      endif
    endif
  endif
  if fl
    if empty(lad_cr1) // в случае нет доп.критерия2
      if !empty(k006->ad_cr1) // а в справочнике есть доп.критерий2
        fl := .f.
      endif
    else // в случае есть доп.критерий2
      if empty(k006->ad_cr1) // а в справочнике нет доп.критерия2
        fl := .f.
      else                  // а в справочнике есть доп.критерий2
        fl := (lad_cr1 == alltrim(k006->ad_cr1))
        if fl ; j ++ ; endif
      endif
    endif
  endif
  if fl .and. !empty(sds1)
    fl := .f.
    for i := 1 to len(sop_diag)
      if alltrim(sop_diag[i]) $ sds1
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds2)
    fl := .f.
    for i := 1 to len(osl_diag)
      if alltrim(osl_diag[i]) $ sds2
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl
    if !empty(k006->sy) .and. (i := ascan(amohu,k006->sy)) > 0
      aadd(tmp,i)
    endif
    aadd(ar,{k006->shifr,; //  1
             0,;           //  2
             lkoef,;       //  3
             &lal.->kiros,; //  4
             osn_diag,;    //  5
             k006->sy,;    //  6
             k006->age,;   //  7
             k006->sex,;   //  8
             k006->los,;   //  9
             k006->ad_cr,; // 10
             sds1,;        // 11
             sds2,;        // 12
             j,;           // 13
             &lal.->kslps,; // 14
             k006->ad_cr1}) // 15
  endif
  select K006
  skip
enddo
if len(ar) > 0
  for i := 1 to len(tmp)
    im := tmp[i]
    amohu[im] := "" // очистить, чтобы не включать в хирургическую КСГ
  next
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aTerKSG := aclone(ar)
  if len(aTerKSG) > 1
    asort(aTerKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
  /*aadd(ars,"   ║КСГ: "+print_array(aTerKSG[1]))
  for j := 2 to len(aTerKSG)
    aadd(ars,"   ║     "+print_array(aTerKSG[j]))
  next*/
  if (kol_ter := f_put_debug_KSG(0,aTerKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+rtrim(aTerKSG[1,1])+" [КЗ="+lstr(aTerKSG[1,3])+"]")
  endif
endif
// собираем КСГ по манипуляциям (хирургические и комбинированные)
ar := {}
for im := 1 to len(amohu)
  if !empty(lshifr := alltrim(amohu[im]))
    _a1 := {}
    select K006
    set order to 2
    find (susl+padr(lshifr,20))
    do while left(k006->shifr,2)==susl .and. k006->sy==padr(lshifr,20) .and. !eof()
      lkoef := k006->kz
      dbSelectArea(lal)
      find (padr(k006->shifr,10))
      fl := lkoef > 0 .and. between_date(&lal.->DATEBEG,&lal.->DATEEND,date_usl)
      if fl
        fl := between_date(k006->DATEBEG,k006->DATEEND,date_usl)
      endif
      if fl
        sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
        sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
      endif
      j := 0
      if fl .and. !empty(k006->ds)
        fl := (k006->ds == osn_diag)
        if fl ; j += 10 ; endif
      endif
      if fl .and. !empty(k006->age)
        if (fl := (k006->age $ lage))
          if k006->age == '1'
            j += 5
          elseif k006->age == '2'
            j += 4
          elseif k006->age == '3'
            j += 3
          elseif k006->age == '4'
            j += 2
          else
            j ++
          endif
        endif
      endif
      if fl .and. !empty(k006->sex)
        fl := (k006->sex == lsex)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->los)
        fl := (k006->los $ llos)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->ad_cr)  // в справочнике есть доп.критерий
        fl := .f.
        if !empty(lad_cr)        // в случае есть доп.критерий
          fl := (lad_cr == alltrim(k006->ad_cr))
          if fl ; j ++ ; endif
        endif
      endif
      if fl .and. !empty(k006->ad_cr1)  // в справочнике есть доп.критерий2
        fl := .f.
        if !empty(lad_cr1)        // в случае есть доп.критерий2
          fl := (lad_cr1 == alltrim(k006->ad_cr1))
          if fl ; j ++ ; endif
        endif
      endif
      if fl .and. !empty(sds1)
        fl := .f.
        for i := 1 to len(sop_diag)
          if alltrim(sop_diag[i]) $ sds1
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds2)
        fl := .f.
        for i := 1 to len(osl_diag)
          if alltrim(osl_diag[i]) $ sds2
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl
        aadd(_a1,{k006->shifr,; //  1
                  0,;           //  2
                  lkoef,;       //  3
                  &lal.->kiros,; //  4
                  k006->ds,;    //  5
                  lshifr,;      //  6
                  k006->age,;   //  7
                  k006->sex,;   //  8
                  k006->los,;   //  9
                  k006->ad_cr,; // 10
                  sds1,;        // 11
                  sds2,;        // 12
                  j,;           // 13
                  &lal.->kslps,; // 14
                  k006->ad_cr1}) // 15
      endif
      select K006
      skip
    enddo
    if len(_a1) > 1 // если по данной услуге более одной КСГ, сортируем по убыванию критериев
      asort(_a1,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
    endif
    if len(_a1) > 0
      aadd(ar,aclone(_a1[1]))
    endif
  endif
next
if len(ar) > 0
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aHirKSG := aclone(ar)
  if len(aHirKSG) > 1
    asort(aHirKSG,,,{|x,y| iif(x[3]==y[3], x[13] > y[13], x[3] > y[3]) })
  endif
  /*aadd(ars,"   ║КСГ: "+print_array(aHirKSG[1]))
  for j := 2 to len(aHirKSG)
    aadd(ars,"   ║     "+print_array(aHirKSG[j]))
  next*/
  if (kol_hir := f_put_debug_KSG(0,aHirKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+rtrim(aHirKSG[1,1])+" [КЗ="+lstr(aHirKSG[1,3])+"]")
  endif
endif
if kol_ter > 0 .and. kol_hir > 0
  aTerKSG[1,1] := alltrim(aTerKSG[1,1])
  aHirKSG[1,1] := alltrim(aHirKSG[1,1])
  //i := int(val(substr(aTerKSG[1,1],2,3)))
  //j := int(val(substr(aHirKSG[1,1],2,3)))
  if !empty(aTerKSG[1,6]) // т.е. диагноз + услуга
    lksg  := aTerKSG[1,1]
    lcena := aTerKSG[1,2]
    lkiro := list2arr(aTerKSG[1,4])
    lkslp := aTerKSG[1,14]
    aadd(ars," выбираем КСГ="+lksg+" (осн.диагноз+услуга "+rtrim(aTerKSG[1,6])+")")
  //elseif ascan(a_iskl_1, {|x| x[1]==j .and. eq_any(x[2],0,i) .and. lusl==x[3] }) > 0 // исключение из правил №1
  elseif ascan(a_iskl_1, {|x| x[1]==aHirKSG[1,1] .and. (empty(x[2]) .or. x[2]==aTerKSG[1,1]) }) > 0 // исключение из правил №1
    lksg  := aHirKSG[1,1]
    lcena := aHirKSG[1,2]
    lkiro := list2arr(aHirKSG[1,4])
    lkslp := aHirKSG[1,14]
    aadd(ars," в соответствии с ИНСТРУКЦИЕЙ по КСГ выбираем "+aHirKSG[1,1]+" вместо "+aTerKSG[1,1])
  else
    if aTerKSG[1,3] > aHirKSG[1,3] // "если хирур.КЗ меньше терапевтического КЗ"
      lksg  := aTerKSG[1,1]
      lcena := aTerKSG[1,2]
      lkiro := list2arr(aTerKSG[1,4])
      lkslp := aTerKSG[1,14]
      aadd(ars," выбираем КСГ ="+aTerKSG[1,1]+" с БОЛЬШИМ коэффициентом затратоёмкости "+lstr(aTerKSG[1,3]))
    else
      lksg  := aHirKSG[1,1]
      lcena := aHirKSG[1,2]
      lkiro := list2arr(aHirKSG[1,4])
      lkslp := aHirKSG[1,14]
      aadd(ars," оставляем КСГ="+aHirKSG[1,1]+" с коэффициентом затратоёмкости "+lstr(aHirKSG[1,3]))
    endif
  endif
elseif kol_ter > 0
  aTerKSG[1,1] := alltrim(aTerKSG[1,1])
  lksg  := aTerKSG[1,1]
  lcena := aTerKSG[1,2]
  lkiro := list2arr(aTerKSG[1,4])
  lkslp := aTerKSG[1,14]
elseif kol_hir > 0
  aHirKSG[1,1] := alltrim(aHirKSG[1,1])
  lksg  := aHirKSG[1,1]
  lcena := aHirKSG[1,2]
  lkiro := list2arr(aHirKSG[1,4])
  lkslp := aHirKSG[1,14]
endif
akslp := {} ; akiro := {}
if !empty(lksg)
  s := " РЕЗУЛЬТАТ: выбрана КСГ="+lksg
  if empty(lcena)
    s += ", но не определена цена в справочнике ТФОМС"
    aadd(arerr,s)
  else
    s += ", цена "+lstr(lcena,11,0)+"р. "
    aadd(ars,s)
    s := ""
    if lksg == 'st38.001' .and. lbartell == '61' // Старческая астения (это правило уже устарело и не применяется)
      lkslp := ""                                                       // т.к. у данной КСГ нет КСЛП
    endif
    akslp := f_cena_kslp(@lcena,lksg,ldate_r,ln_data,lk_data,lkslp,amohu,lprofil_k,mdiagnoz,lpar_org)
    if !empty(akslp)
      s += "  (КСЛП = "+str(akslp[2],4,2)
      if len(akslp) >= 4
        s += "+"+str(akslp[4],4,2)
      endif
      s += ", цена "+lstr(lcena,11,0)+"р.)"
    endif
    if !empty(lkiro)
      vkiro := 0
      if ldnej < 4 // менее 4-х дней
        if ascan(lkiro,1) > 0
          vkiro := 1
        elseif ascan(lkiro,2) > 0
          vkiro := 2
          if lksg == 'ds02.005' //; // Экстракорпоральное оплодотворение
                 //.and. lk_data >= 0d20190301 // с 1 марта КИРО=2 не действует
            vkiro := 0
          endif
        elseif lis_err == 1 .and. ascan(lkiro,5) > 0 // добавляем ещё несоблюдение схемы химиотерапии (КИРО=5)
          vkiro := 5
        endif
      elseif ascan({102,105,107,110,202,205,207},lrslt) > 0 // более 3-х дней, лечение прервано
        if ascan(lkiro,3) > 0
          vkiro := 3
        elseif ascan(lkiro,4) > 0
          vkiro := 4
        elseif lis_err == 1 .and. ascan(lkiro,6) > 0 // добавляем ещё несоблюдение схемы химиотерапии (КИРО=6)
          vkiro := 6
        endif
      endif
      if vkiro > 0
        akiro := f_cena_kiro(@lcena,vkiro)
        s += "  (КИРО = "+str(akiro[2],4,2)+", цена "+lstr(lcena,11,0)+"р.)"
      endif
    endif
    if !empty(s)
      aadd(ars,s)
    endif
  endif
else
  aadd(arerr," РЕЗУЛЬТАТ: не получилось выбрать КСГ"+iif(fl_reabil,' для случая медицинской реабилитации',''))
endif
return {ars,arerr,alltrim(lksg),lcena,akslp,akiro,s_dializ}
//       1     2      3            4     5     6       7

***** 12.01.19
Function f_cena_kiro(/*@*/_cena,lkiro)
Local _akiro := {0,1}
do case
  case lkiro == 1 // менее 4-х дней, выполнено хирург.вмешательство
    _akiro := {lkiro,0.8}
  case lkiro == 2 // менее 4-х дней, хирург.лечение не проводилось
    _akiro := {lkiro,0.2}
  case lkiro == 3 // более 3-х дней, выполнено хирург.вмешательство, лечение прервано
    _akiro := {lkiro,0.9}
  case lkiro == 4 // более 3-х дней, хирург.лечение не проводилось, лечение прервано
    _akiro := {lkiro,0.9}
  case lkiro == 5 // менее 4-х дней, несоблюдение инструкции по приёму препарата
    _akiro := {lkiro,0.2}
  case lkiro == 6 // более 3-х дней, несоблюдение инструкции по приёму препарата, лечение прервано
    _akiro := {lkiro,0.9}
endcase
_cena := round_5(_cena*_akiro[2],0)  // округление до рублей с 2019 года
return _akiro

***** 30.01.19 вывести строку в отладочный массив о КСГ
Function f_put_debug_KSG(k,arr,ars)
// k = 1 - терапевтическая
// k = 2 - хирургическая
Local s := " ", i, s1, arr1 := {}
if k == 1
  s += "терап."
elseif k == 2
  s += "хирур."
endif
s += "КСГ"
if len(arr) == 0
  s += " не определена"
else
  s += ": "
  for i := 1 to len(arr)
    s1 := ""
    if k == 0 .and. !empty(arr[i,5])
      s1 += "осн.диаг.,"
    endif
    if eq_any(k,0,1) .and. !empty(arr[i,6])
      s1 += "усл.,"
    endif
    if !empty(arr[i,7])
      s1 += "возр.,"
    endif
    if !empty(arr[i,8])
      s1 += "пол,"
    endif
    if !empty(arr[i,9])
      s1 += "дл-ть,"
    endif
    if !empty(arr[i,10])
      s1 += "доп.критерий,"
    endif
    if len(arr[i]) >= 15 .and. !empty(arr[i,15])
      s1 += "иной критерий,"
    endif
    if !empty(arr[i,11])
      s1 += "соп.диаг.,"
    endif
    if !empty(arr[i,12])
      s1 += "диаг.осл.,"
    endif
    if !empty(s1)
      s1 := " ("+left(s1,len(s1)-1)+")"
    endif
    s1 := alltrim(arr[i,1])+s1+" [КЗ="+lstr(arr[i,3])+"]"
    if ascan(arr1,s1) == 0
      aadd(arr1,s1)
    endif
  next
  for i := 1 to len(arr1)
    s += arr1[i]+" "
  next
endif
aadd(ars,s)
return len(arr1)

*

***** 20.01.14 вернуть цену КСГ
Function ret_cena_KSG(lshifr,lvr,ldate,ta)
Local fl_del := .f., fl_uslc := .f., v := 0
DEFAULT ta TO {}
v := fcena_oms(lshifr,;
               (lvr==0),;
               ldate,;
               @fl_del,;
               @fl_uslc)
if fl_uslc  // если нашли в справочнике ТФОМС
  if fl_del
    aadd(ta,' цена на услугу '+rtrim(lshifr)+' отсутствует в справочнике ТФОМС')
  endif
else
  aadd(ta,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lshifr)
endif
return v

***** 20.01.19 определить КСГ для 1 пациента с открытием файлов
Function f_1pac_definition_KSG(lkod,is_msg)
Local arr, i, s, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t., sdial, fl
DEFAULT is_msg TO .t.
mywait("Определение КСГ")
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
Use_base("lusl")
Use_base("luslc")
Use_base("uslugi")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
use_base("human_u") // если понадобится, удалить старый КСГ и добавить новый
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
G_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",,"HUMAN") // перезаписать сумму
set relation to recno() into HUMAN_, to recno() into HUMAN_2
goto (lkod)
lyear := year(human->K_DATA)
if human_->USL_OK < 3
  if lyear > 2018
    arr := definition_KSG()
  else
    arr := definition_KSG_18()
  endif
  sdial := 0 ; fl := .t.
  if len(arr) == 7
    if valtype(arr[7]) == "N"
      sdial := arr[7] // для 2019 года
    else
      fl := .f. // для 2018 года
    endif
  endif
  if fl // не диализ 2018 года
    aeval(arr[1],{|x| my_debug(,x) })
    if !empty(arr[2])
      my_debug(,"ОШИБКА:")
      aeval(arr[2],{|x| my_debug(,x) })
    endif
    lrec := lcena := 0
    select HU
    find (str(lkod,7))
    do while hu->kod == lkod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      if !empty(arr[3]) .and. alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
        not_ksg := .f.
        lcena := arr[4]
        if !(round(hu->u_cena,2) == round(lcena,2)) // перезапишем цену
          select HU
          G_RLock(forever)
          hu->u_cena := lcena
          hu->stoim := hu->stoim_1 := lcena
          UnLock
        endif
        exit
      endif
      if lyear > 2019
        select LUSL
        find (lshifr) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // стоит другой КСГ
          lrec := hu->(recno())
          exit
        endif
      elseif lyear > 2018
        select LUSL19
        find (lshifr) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl19->shifr)) // стоит другой КСГ
          lrec := hu->(recno())
          exit
        endif
      else
        select LUSL18
        find (lshifr) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl18->shifr)) // стоит другой КСГ
          lrec := hu->(recno())
          exit
        endif
      endif
      select HU
      skip
    enddo
    if empty(arr[2])
      if empty(lcena)
        lu_kod := foundOurUsluga(arr[3],human->k_data,human_->profil,human->VZROS_REB,@lcena)
        if lyear > 2018  // округление до рублей с 2019 года
          if len(arr) > 4 .and. !empty(arr[5])
            lcena := round_5(lcena*ret_koef_kslp(arr[5]),0)
          endif
          if len(arr) > 5 .and. !empty(arr[6])
            lcena := round_5(lcena*arr[6,2],0)
          endif
        else
          if len(arr) > 4 .and. !empty(arr[5])
            lcena := round_5(lcena*arr[5,2],1)
          endif
          if len(arr) > 5 .and. !empty(arr[6])
            lcena := round_5(lcena*arr[6,2],1)
          endif
        endif
        if round(arr[4],2) == round(lcena,2) // цена определена правильно
          select HU
          if lrec == 0
            Add1Rec(7)
            hu->kod := human->kod
          else
            goto (lrec)
            G_RLock(forever)
          endif
          mrec_hu := hu->(recno())
          hu->kod_vr  := human_->VRACH
          hu->kod_as  := 0
          hu->u_koef  := 1
          hu->u_kod   := lu_kod
          hu->u_cena  := lcena
          hu->is_edit := 0
          hu->date_u  := dtoc4(human->n_data)
          hu->otd     := human->otd
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := lcena
          select HU_
          do while hu_->(lastrec()) < mrec_hu
            APPEND BLANK
          enddo
          goto (mrec_hu)
          G_RLock(forever)
          if lrec == 0 .or. !valid_GUID(hu_->ID_U)
            hu_->ID_U := mo_guid(3,hu_->(recno()))
          endif
          hu_->PROFIL := human_->PROFIL
          hu_->PRVS   := human_->PRVS
          hu_->kod_diag := human->KOD_DIAG
          hu_->zf := ""
        else
          func_error(4,"ОШИБКА: разница в цене услуги "+lstr(arr[4])+" != "+lstr(lcena))
          not_ksg := .f.
          lcena := 0
        endif
      endif
    elseif lrec > 0 // не удалось определить КСГ
      select HU
      goto (lrec)
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      lcena := 0
    endif
    if !(round(human->CENA_1,2) == round(lcena+sdial,2))
      select HUMAN
      G_RLock(forever)
      human->CENA := human->CENA_1 := lcena+sdial // перезапишем стоимость лечения
      UnLock
    endif
    put_str_kslp_kiro(arr)
    close databases
    if empty(arr[2])
      if not_ksg .and. is_msg
        i := len(arr[1])
        s := arr[1,i]
        if !("РЕЗУЛЬТАТ" $ arr[1,i]) .and. i > 1
          s := alltrim(arr[1,i-1] + s)
        endif
        stat_msg(s) ; mybell(2,OK)
      endif
    else
      func_error(4,"ОШИБКА: "+arr[2,1])
    endif
  endif
endif
close databases
rest_box(buf)
return NIL

***** 29.09.19 определить КСГ для 1 пациента из режима редактирования услуг
Function f_usl_definition_KSG(lkod,k_data2)
Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, not_ksg := .t.,;
      mrec_hu, tmp_rec := 0, tmp_select := select(), is_usl1 := .f.,;
      ret := {}, lyear := year(human->K_DATA), i, s, sdial, fl
if human_->USL_OK < 3
  mywait("Определение КСГ")
  usl->(dbCloseArea()) // переоткрыть справочник услуг
  Use_base("uslugi")
  if select("USL1") == 0
    is_usl1 := .t.
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
  endif
  select TMP
  if lastrec() > 0
    tmp_rec := recno()
  endif
  set relation to
  if lyear > 2018
    arr := definition_KSG(1,k_data2)
  else
    arr := definition_KSG_18()
  endif
  sdial := 0 ; fl := .t.
  if len(arr) == 7
    if valtype(arr[7]) == "N"
      sdial := arr[7] // для 2019 года
    else
      fl := .f. // для 2018 года
    endif
  endif
  if fl // не диализ 2018 года
    aeval(arr[1],{|x| my_debug(,x), aadd(ret,x) })
    if !empty(arr[2])
      my_debug(,"ОШИБКА:")
      aeval(arr[2],{|x| my_debug(,x), aadd(ret,x) })
    endif
    lrec := lcena := 0
    select TMP
    go top
    do while !eof()
      if empty(lshifr := tmp->shifr1)
        lshifr := tmp->shifr_u
      endif
      if !empty(arr[3]) .and. alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
        not_ksg := .f.
        lcena := arr[4]
        if !(round(tmp->u_cena,2) == round(lcena,2)) // перезапишем цену
          tmp->u_cena := lcena
          tmp->stoim_1 := lcena
          select HU
          goto (tmp->rec_hu)
          G_RLock(forever)
          hu->u_cena := lcena
          hu->stoim := hu->stoim_1 := lcena
          UnLock
        endif
        exit
      endif
      if lyear > 2019
        select LUSL
        find (padr(lshifr,10)) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // стоит другой КСГ
          lrec := tmp->(recno())
          exit
        endif
      elseif lyear > 2018
        select LUSL19
        find (padr(lshifr,10)) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl19->shifr)) // стоит другой КСГ
          lrec := tmp->(recno())
          exit
        endif
      else
        select LUSL18
        find (padr(lshifr,10)) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl18->shifr)) // стоит другой КСГ
          lrec := tmp->(recno())
          exit
        endif
      endif
      select TMP
      skip
    enddo
    if empty(arr[2])
      if empty(lcena)
        lu_kod := foundOurUsluga(arr[3],human->k_data,human_->profil,human->VZROS_REB,@lcena)
        if lyear > 2018  // округление до рублей с 2019 года
          if len(arr) > 4 .and. !empty(arr[5])
            lcena := round_5(lcena*ret_koef_kslp(arr[5]),0)
          endif
          if len(arr) > 5 .and. !empty(arr[6])
            lcena := round_5(lcena*arr[6,2],0)
          endif
        else
          if len(arr) > 4 .and. !empty(arr[5])
            lcena := round_5(lcena*arr[5,2],1)
          endif
          if len(arr) > 5 .and. !empty(arr[6])
            lcena := round_5(lcena*arr[6,2],1)
          endif
        endif
        if round(arr[4],2) == round(lcena,2) // цена определена правильно
          usl->(dbGoto(lu_kod))
          select HU
          if lrec == 0
            Add1Rec(7)
            hu->kod := human->kod
          else
            select TMP
            goto (lrec)
            select HU
            goto (tmp->rec_hu)
            G_RLock(forever)
          endif
          mrec_hu := hu->(recno())
          hu->kod_vr  := human_->VRACH
          hu->kod_as  := 0
          hu->u_koef  := 1
          hu->u_kod   := lu_kod
          hu->u_cena  := lcena
          hu->is_edit := 0
          hu->date_u  := dtoc4(human->n_data)
          hu->otd     := human->otd
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := lcena
          select HU_
          do while hu_->(lastrec()) < mrec_hu
            APPEND BLANK
          enddo
          goto (mrec_hu)
          G_RLock(forever)
          if lrec == 0 .or. !valid_GUID(hu_->ID_U)
            hu_->ID_U := mo_guid(3,hu_->(recno()))
          endif
          hu_->PROFIL := human_->PROFIL
          hu_->PRVS   := human_->PRVS
          hu_->kod_diag := human->KOD_DIAG
          hu_->zf := ""
          UnLock
          //
          select TMP
          if lrec == 0
            append blank
            hu->kod := human->kod
          else
            goto (lrec)
          endif
          tmp->KOD     := human->kod
          tmp->DATE_U  := hu->date_u
          tmp->U_KOD   := lu_kod
          tmp->U_CENA  := lcena
          tmp->KOD_VR  := human_->VRACH
          tmp->KOD_AS  := 0
          tmp->OTD     := human->otd
          tmp->KOL_1   := 1
          tmp->STOIM_1 := lcena
          tmp->kod_diag:= human->KOD_DIAG
          tmp->ZF      := ""
          tmp->PROFIL  := human_->PROFIL
          tmp->PRVS    := human_->PRVS
          tmp->date_u1 := human->n_data
          tmp->shifr_u := arr[3]
          tmp->shifr1  := arr[3]
          tmp->name_u  := usl->name
          tmp->is_nul  := usl->is_nul
          tmp->is_oms  := .t.
          tmp->n_base  := 0
          tmp->dom     := 0
          tmp->rec_hu  := mrec_hu
        else
          func_error(4,"ОШИБКА: разница в цене услуги "+lstr(arr[4])+" != "+lstr(lcena))
          not_ksg := .f.
          lcena := 0
        endif
      endif
    elseif lrec > 0 // не удалось определить КСГ
      select TMP
      goto (lrec)
      select HU
      goto (tmp->rec_hu)
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      select TMP
      DeleteRec(.t.)  // с пометкой на удаление
      lcena := 0
    endif
    if !(round(human->CENA_1,2) == round(lcena+sdial,2))
      select HUMAN
      G_RLock(forever)
      human->CENA := human->CENA_1 := lcena+sdial // перезапишем стоимость лечения
      UnLock
    endif
    put_str_kslp_kiro(arr)
    commit
    if empty(arr[2])
      if not_ksg
        i := len(arr[1])
        s := arr[1,i]
        if !("РЕЗУЛЬТАТ" $ arr[1,i]) .and. i > 1
          s := alltrim(arr[1,i-1] + s)
        endif
        stat_msg(s) ; mybell(2,OK)
      endif
    else
      func_error(4,"ОШИБКА: "+arr[2,1])
    endif
  endif
  if is_usl1
    usl1->(dbCloseArea())
  endif
  usl->(dbCloseArea()) // переоткрыть справочник услуг
  R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
  select TMP
  set relation to otd into OTD
  if tmp_rec > 0
    goto (tmp_rec)
  endif
  select (tmp_select)
  rest_box(buf)
endif
return ret

*

***** 28.01.14 вывести в центре экрана протокол определения КСГ
Function f_put_arr_ksg(cLine)
Local buf := savescreen(), i, nLLen := 0, mc := maxcol()-1,;
      nLCol, nRCol, nTRow, nBRow, nNumRows := len(cLine)
AEVAL(cLine, {|x,i| nLLen := Max(nLLen,Len(x)) })
if nLLen > mc
  nLLen := mc
endif
// вычисление координат углов
nLCol := Int((mc-nLLen)/2)
nRCol := nLCol+nLLen+1
nTRow := Int((maxrow()-nNumRows)/2)
nBRow := nTRow+nNumRows+1
PUT_SHADOW(nTRow,nLCol,nBRow,nRCol)
@ nTRow,nLCol Clear to nBRow,nRCol
DispBox(nTRow,nLCol,nBRow,nRCol,2,"GR/GR*")
AEVAL(cLine, { |cSayStr,i|;
               nSayRow := nTRow+i,;
               nSayCol := nLCol+1,;
               setpos(nSayRow,nSayCol), dispout(padr(cSayStr,nLLen),"N/GR*");
             })
inkey(0)
restscreen(buf)
return NIL

***** 26.01.18 тест определения КСГ
Function test_definition_KSG()
Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t.
stat_msg("Определение КСГ")
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
Use_base("lusl")
Use_base("luslc")
Use_base("uslugi")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
use_base("human_u") // если понадобится, удалить старый КСГ и добавить новый
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",,"HUMAN") // перезаписать сумму
set relation to recno() into HUMAN_, to recno() into HUMAN_2
n_file := "test_ksg"+stxt
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
go top
do while !eof()
  @ maxrow(),0 say str(recno()/lastrec()*100,7,2)+"%" color cColorStMsg
  if inkey() == K_ESC
    exit
  endif
  if human->K_DATA > stod("20190930") .and. eq_any(human_->USL_OK,1,2)
    arr := definition_KSG()
    if len(arr) == 7 // диализ
      add_string("== диализ == ")
    else
      aeval(arr[1],{|x| add_string(x) })
      if !empty(arr[2])
        add_string("ОШИБКА:")
        aeval(arr[2],{|x| add_string(x) })
      endif
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        usl->(dbGoto(hu->u_kod))
        if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
          lshifr := usl->shifr
        endif
        if alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
          if !(round(hu->u_cena,2) == round(arr[4],2)) // не та цена
            add_string("в л/у для КСГ="+arr[3]+" стоит цена "+lstr(hu->u_cena,10,2)+", а должна быть "+lstr(arr[4],10,2))
            if human->schet > 0
              schet_->(dbGoto(human->schet))
              add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
            endif
          endif
          exit
        endif
        select LUSL
        find (lshifr) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // стоит другой КСГ
          add_string("в л/у стоит КСГ="+alltrim(lshifr)+"("+lstr(hu->u_cena,10,2)+;
                     "), а должна быть "+arr[3]+"("+lstr(arr[4],10,2)+")")
          if human->schet > 0
            schet_->(dbGoto(human->schet))
            add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
          endif
          exit
        endif
        select HU
        skip
      enddo
    endif
    add_string(replicate("*",80))
  endif
  select HUMAN
  skip
enddo
close databases
rest_box(buf)
fclose(fp)
return NIL

*

/***** 28.10.15 тест определения периода ПН
Function test_definition_period_PN()
Local i, _m, _d, _y, _m2, _d2, _y2, s, s1, arr, buf := save_maxrow()
mywait("Определение периода для профилактических осмотров несовершеннолетних")
use_base("mo_hdisp")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
n_file := "testp_PN"+stxt
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
go top
do while !eof()
  @ 24,0 say str(recno()/lastrec()*100,7,2)+"%" color cColorStMsg
  if inkey() == K_ESC
    exit
  endif
  if human->k_data >= stod("20150301") .and. between(human->ishod,301,302) .and. human_->oplata != 9
    _mperiod := mperiod := 0
    add_string(alltrim(human->fio)+" "+date_8(human->n_data)+"-"+date_8(human->k_data)+;
               ", дата р."+date_8(human->date_r))
    s := ""
    select HDISP
    find (str(human->kod,7))
    do while hdisp->kod == human->kod .and. !eof()
      s += hdisp->name
      skip
    enddo
    arr := REST_ARR_MEM(s) // востановление массива из символьной переменной s
    for i := 1 to len(arr)
      if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
        if arr[i,1] == "1" .and. valtype(arr[i,2]) == "N"
          mperiod := arr[i,2]
          exit
        endif
      endif
    next
    s1 := " "
    mdvozrast := year(human->n_data) - year(human->date_r)
    Store 0 TO _m, _d, _y, _m2, _d2, _y2
    count_ymd(human->date_r,human->n_data,@_y,@_m,@_d) // реальный возраст
    count_ymd(human->date_r,human->k_data,@_y2,@_m2,@_d2) // реальный возраст
    add_string("mdvozrast = "+lstr(mdvozrast)+", _y = "+lstr(_y)+", _m = "+lstr(_m)+", _d = "+lstr(_d)+;
               "; _y2 = "+lstr(_y2)+", _m2 = "+lstr(_m2)+", _d2 = "+lstr(_d2))
    _mperiod := ret_period_PN(human->date_r,human->n_data,human->k_data,@s1)
    if _mperiod == mperiod
      add_string(lstr(mperiod)+" == "+lstr(_mperiod)+" "+s1)
    else
      add_string(lstr(mperiod)+" not "+lstr(_mperiod)+" "+s1)
    endif
    add_string(replicate("*",80))
  endif
  select HUMAN
  skip
enddo
close databases
rest_box(buf)
fclose(fp)
return NIL*/

***** 06.06.19 определить коэф-т сложности лечения пациента и пересчитать цену
Function f_cena_kslp(/*@*/_cena,_lshifr,_date_r,_n_data,_k_data,lkslp,arr_usl,lPROFIL_K,arr_diag,lpar_org)
Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
Static s_kslp17 := {;
  {1,1.1, 0,  3},;   // до 4 лет
  {2,1.1,75,999};    // 75 лет и старше
 }
Static s_kslp16 := {;
  {1,1.1 , 0,  3},;   // до 4 лет
  {2,1.05,75,999};    // 75 лет и старше
 }
Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
if _k_data > s_19  // с 2019 года
  if !empty(lkslp)
    _lshifr := alltrim(_lshifr)
    if _lshifr == "ds02.005" // ЭКО, lkslp = 12,13,14
      s_kslp := {;
        {12,0.60},;
        {13,1.10},;
        {14,0.19};
      }
      for i := 1 to len(arr_usl)
        if valtype(arr_usl[i]) == "A"
          aadd(ausl,alltrim(arr_usl[i,1]))  // массив многомерный
        else
          aadd(ausl,alltrim(arr_usl[i]))    // массив одномерный
        endif
      next i
      j := 0 // КСЛП - 1 схема
      if ascan(ausl,"A11.20.031") > 0  // крио
        j := 13  // 6 схема
        if ascan(ausl,"A11.20.028") > 0 // третий этап
          j := 0   // 2 схема
        endif
      elseif ascan(ausl,"A11.20.025.001") > 0  // первый этап
        j := 12  // 3 схема
        if ascan(ausl,"A11.20.036") > 0  // завершающий второй этап
          j := 12  // 4 схема
        elseif ascan(ausl,"A11.20.028") > 0  // завершающий третий этап
          j := 12  // 5 схема
        endif
      elseif ascan(ausl,"A11.20.030.001") > 0  // только четвертый этап
        j := 14  // 7 схема
      endif
      if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
        aadd(_akslp,s_kslp[i,1])
        aadd(_akslp,s_kslp[i,2])
        _cena := round_5(_cena*s_kslp[i,2],0)  // с 2019 года цена округляется до рублей
      endif
      if !empty(_akslp) .and. _k_data > 0d20191231 // с 2020 года
        _akslp[1] += 3 // т.е. с 2020 года КСЛП для ЭКО 15,16,17
      endif
    else // остальные КСГ
      s_kslp := {;
        { 1,1.10, 0,  0},;  // до 1 года
        { 2,1.10, 1,  3},;  // от 1 до 3 лет включительно
        { 4,1.02,75,999},;  // 75 и старше
        { 5,1.10,60,999};   // 60 и старше и астения
      }
      count_ymd(_date_r,_n_data,@y)
      lkslp := list2arr(lkslp)
      for j := 1 to len(lkslp)
        if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // стоит данный КСЛП в выбранной КСГ
          if between(y,s_kslp[i,3],s_kslp[i,4])
            fl := .t.
            if lkslp[j] == 4
              fl := (lprofil_k != 16 ; // пациент лежит не на геронтологической койке
                      .and. !(_lshifr == "st38.001"))
            elseif lkslp[j] == 5
              sop_diag := aclone(arr_diag)
              del_array(sop_diag,1)
              fl := (lprofil_k == 16 .and. ; // пациент лежит на геронтологической койке
                      !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // с основным диагнозом не <R54-старость>
                      ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // в соп.диагнозах есть <R54-старость>
            endif
            if fl
              aadd(_akslp,s_kslp[i,1])
              aadd(_akslp,s_kslp[i,2])
              exit
            endif
          endif
        endif
      next
      if ascan(lkslp,11) > 0 .and. lpar_org > 1 // разрешена КСЛП=11 и введены парные органы
        aadd(_akslp,11)
        aadd(_akslp,1.2)
      endif
      if !empty(_akslp)
        _cena := round_5(_cena*ret_koef_kslp(_akslp),0)  // с 2019 года цена округляется до рублей
      endif
    endif
  endif
elseif _k_data > s_18  // с 2018 года
  if !empty(lkslp)
    _lshifr := alltrim(_lshifr)
    if _lshifr == "2005.0" // ЭКО, lkslp = 12,13,14
      s_kslp := {;
        {12,0.60},;
        {13,1.10},;
        {14,0.19};
      }
      for i := 1 to len(arr_usl)
        if valtype(arr_usl[i]) == "A"
          aadd(ausl,alltrim(arr_usl[i,1]))  // массив многомерный
        else
          aadd(ausl,alltrim(arr_usl[i]))    // массив одномерный
        endif
      next i
      j := 0 // КСЛП - 1 схема
      if ascan(ausl,"A11.20.031") > 0  // крио
        j := 13  // 6 схема
        if ascan(ausl,"A11.20.028") > 0 // третий этап
          j := 0   // 2 схема
        endif
      elseif ascan(ausl,"A11.20.025.001") > 0  // первый этап
        j := 12  // 3 схема
        if ascan(ausl,"A11.20.036") > 0  // завершающий второй этап
          j := 12  // 4 схема
        elseif ascan(ausl,"A11.20.028") > 0  // завершающий третий этап
          j := 12  // 5 схема
        endif
      elseif ascan(ausl,"A11.20.030.001") > 0  // только четвертый этап
        j := 14  // 7 схема
      endif
      if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
        aadd(_akslp,s_kslp[i,1])
        aadd(_akslp,s_kslp[i,2])
        _cena := round_5(_cena*s_kslp[i,2],1)
      endif
    else // остальные КСГ
      s_kslp := {;
        { 1,1.10, 0,  0},;  // до 1 года
        { 2,1.10, 1,  3},;  // от 1 до 3 лет включительно
        { 4,1.05,75,999},;  // 75 и старше
        { 5,1.10,60,999};   // 60 и старше и астения
      }
      count_ymd(_date_r,_n_data,@y)
      lkslp := list2arr(lkslp)
      for j := 1 to len(lkslp)
        if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
          if between(i,1,5) .and. between(y,s_kslp[i,3],s_kslp[i,4])
            aadd(_akslp,s_kslp[i,1])
            aadd(_akslp,s_kslp[i,2])
            _cena := round_5(_cena*s_kslp[i,2],1)
            exit
          endif
        endif
      next
    endif
  endif
elseif _k_data > s_1_may ;                 // с 1 мая 2016 года
            .and. left(_lshifr,1) == '1' ; // круглосуточный стационар
            .and. !("." $ _lshifr)         // это шифр КСГ
  _lshifr := alltrim(_lshifr)
  count_ymd(_date_r,_n_data,@y)
  vksg := int(val(right(_lshifr,3))) // последние три цифры - код КСГ
  if (fl := vksg < 900) // не диализ
    if year(_k_data) > 2016
      s_kslp := s_kslp17
      if y < 1 .and. between(vksg,105,111) // до 1 года и малая масса при рождении
        fl := .f.
      endif
    else
      s_kslp := s_kslp16
    endif
    if fl
      for i := 1 to len(s_kslp)
        if between(y,s_kslp[i,3],s_kslp[i,4])
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],1)
          exit
        endif
      next
    endif
  endif
endif
return _akslp

***** 22.01.18 если надо, перезаписать значения КСЛП и КИРО в HUMAN_2
Function put_str_kslp_kiro(arr,fl)
Local lpc1 := "", lpc2 := ""
if len(arr) > 4 .and. !empty(arr[5])
  lpc1 := lstr(arr[5,1])+","+lstr(arr[5,2],5,2)
  if len(arr[5]) >= 4
    lpc1 += ","+lstr(arr[5,3])+","+lstr(arr[5,4],5,2)
  endif
endif
if len(arr) > 5 .and. !empty(arr[6])
  lpc2 := lstr(arr[6,1])+","+lstr(arr[6,2],5,2)
endif
if !(padr(lpc1,20) == human_2->pc1 .and. padr(lpc2,10) == human_2->pc2)
  DEFAULT fl TO .t. // блокировать и разблокировать запись в HUMAN_2
  select HUMAN_2
  if fl
    G_RLock(forever)
  endif
  human_2->pc1 := lpc1
  human_2->pc2 := lpc2
  if fl
    UnLock
  endif
endif
return NIL

***** 23.01.19 вернуть итоговый КСЛП
Function ret_koef_kslp(akslp)
Local k := 1
if valtype(akslp) == "A" .and. len(akslp) >= 2
  k := akslp[2]
  if len(akslp) >= 4
    k += akslp[4] - 1
  endif
endif
return k

***** 21.01.19 проверить, заблокирована ли запись, и, если нет, то заблокировать её
Function my_Rec_Lock(n)
if ascan(dbRLockList(),n) == 0
  G_RLock(forever)
endif
return NIL