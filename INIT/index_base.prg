// #include "inkey.ch"
#include "function.ch"
// #include "edit_spr.ch"
#include "chip_mo.ch"

***** 02.01.22
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
    case sBase == "mo_add"
      index on codem to (dir_server+sBase)
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
    case sBase == "human_im"
      index on str(kod_hum, 7) to (dir_server + "human_im") progress
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
  