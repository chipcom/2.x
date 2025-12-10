#include 'function.ch'
#include 'chip_mo.ch'

// 10.12.25
Function index_base( sBase )

  Millisec( 100 )  // задержка на 0.1 с
  If Type( "fl_open" ) == "L" .and. fl_open
    If !hb_FileExists( dir_server() + sBase + sdbf() ) // если нет файла
      Return Nil                             // выйти из функции
    Endif
    Use ( dir_server() + sBase ) New Alias __TMP__ READONLY
    If Select( '__TMP__' ) == 0
      n_message( { 'Неудачная попытка открытия файла базы данных', ;
        Upper( dir_server() + sBase + sdbf() ), ;
        'Скорее всего, данный файл занят либо другим пользователем,', ;
        'либо каким-нибудь системным процессом.', ;
        'Попытайтесь войти в данный режим позже или', ;
        'перезагрузите компьютер (сервер) и попытайтесь снова.';
        },, 'GR+/R', 'W+/R',,, 'G+/R' )
      Return Nil
    Endif
  Endif
  sBase := Lower( sBase )
  Do Case
  Case sBase == "mo_add"
    Index On FIELD->codem to ( dir_server() + sBase )
  Case sBase == "s_adres"
    Index On Upper( FIELD->name ) to ( dir_server() + sBase )
  Case sBase == "s_kemvyd"
    Index On Upper( SubStr( FIELD->name, 1, 80 ) ) to ( dir_server() + sBase )
  Case sBase == "mo_pers"
    Index On Str( FIELD->tab_nom, 5 ) to ( dir_server() + sBase )
  Case sBase == "mo_regi"
    Index On Str( FIELD->tip, 1 ) to ( dir_server() + "mo_regi1" ) progress
    Index On FIELD->pdate to ( dir_server() + "mo_regi2" ) progress
    Index On Str( FIELD->kod_k, 7 ) + FIELD->pdate + FIELD->ctime to ( dir_server() + "mo_regi3" ) descending progress
  Case sBase == "msek"
    Index On Str( FIELD->kod_k, 7 ) + Str( Descend( FIELD->date_kom ), 10 ) to ( dir_server() + sBase ) progress
  Case sBase == "slugba"
    Index On Str( FIELD->shifr, 3 ) to ( dir_server() + sBase )
  Case sBase == "mo_su"
    Index On Str( FIELD->kod, 6 ) to ( dir_server() + "mo_su" ) progress
    Index On FIELD->shifr to ( dir_server() + "mo_sush" ) progress
    Index On FIELD->shifr1 + Str( FIELD->tip, 1 ) to ( dir_server() + "mo_sush1" ) progress
  Case sBase == "uslugi"
    Index On Str( FIELD->kod, 4 ) to ( dir_server() + "uslugi" ) progress
    Index On FIELD->shifr to ( dir_server() + "uslugish" ) progress
    Index On iif( Empty( FIELD->shifr1 ), FIELD->shifr, FIELD->shifr1 ) to ( dir_server() + "uslugis1" ) progress
    Index On Str( FIELD->slugba, 3 ) to ( dir_server() + "uslugisl" ) progress
  Case sBase == "uslugi1"
    Index On Str( FIELD->kod, 4 ) + DToS( FIELD->date_b ) to ( dir_server() + "uslugi1" ) progress
    Index On FIELD->shifr1 + DToS( FIELD->date_b ) to ( dir_server() + "uslugi1s" ) progress
  Case sBase == "usl_otd"
    Index On Str( FIELD->kod, 4 ) to ( dir_server() + sBase ) progress
  Case sBase == "uslugi_k"
    Index On FIELD->shifr to ( dir_server() + sBase ) progress
  Case sBase == "uslugi1k"
    Index On FIELD->shifr + FIELD->shifr1 to ( dir_server() + sBase ) progress
  Case sBase == "ns_usl_k"
    Index On Str( FIELD->kod, 6 ) to ( dir_server() + sBase ) progress
  Case sBase == "usl_uva"
    Index On FIELD->shifr to ( dir_server() + sBase ) progress
  Case sBase == "uch_usl"
    Index On Str( FIELD->kod, 4 ) to ( dir_server() + sBase ) progress
  Case sBase == "uch_usl1"
    Index On Str( FIELD->kod, 4 ) + DToS( FIELD->date_b ) to ( dir_server() + sBase ) progress
  Case sBase == "uch_pers"
    Index On Str( FIELD->kod, 4 ) + Str( FIELD->god, 4 ) + Str( FIELD->mes, 2 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_oper"
    Index On FIELD->pd + FIELD->po + Str( FIELD->task, 1 ) + Str( FIELD->app_edit, 1 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_opern"
    Index On FIELD->pd + FIELD->po + FIELD->pt + FIELD->tp + FIELD->ae to ( dir_server() + sBase ) progress
  Case sBase == "kartotek"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "kartotek" ) progress
    Index On if( FIELD->kod > 0, "1", "0" ) + Upper( FIELD->fio ) + DToS( FIELD->date_r ) to ( dir_server() + "kartoten" ) progress
    Index On if( FIELD->kod > 0, "1", "0" ) + FIELD->polis to ( dir_server() + "kartotep" ) progress
    Index On StrZero( FIELD->uchast, 2 ) + StrZero( FIELD->kod_vu, 5 ) to ( dir_server() + "kartoteu" ) progress
    Index On if( FIELD->kod > 0, "1", "0" ) + FIELD->snils to ( dir_server() + "kartotes" ) progress
    Index On if( FIELD->kod > 0, "1", "0" ) + FIELD->kod_mis to ( dir_server() + "kartotee" ) progress
  Case sBase == "k_prim1"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->stroke, 1 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_kartp"
    Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->d_prik ) to ( dir_server() + sBase ) progress
  Case sBase == "kartdelz"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->zf, 2 ) to ( dir_server() + "kartdelz" ) progress
  Case sBase == "kart_st"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->zf, 2 ) + FIELD->date_u to ( dir_server() + "kart_st" ) progress
    Index On Str( FIELD->tip_bd, 1 ) + Str( FIELD->rec_bd, 8 ) to ( dir_server() + "kart_st1" ) progress
  Case sBase == "mo_kpred"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->nn, 1 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_kinos"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
    //
  Case sBase == "mo_pp"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "mo_pp_k" ) progress
    Index On DToS( FIELD->n_data ) + FIELD->n_time to ( dir_server() + "mo_pp_d" ) progress
    Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->n_data ) to ( dir_server() + "mo_pp_r" ) descending progress
    Index On Str( Year( FIELD->n_data ), 4 ) + FIELD->uch_doc to ( dir_server() + "mo_pp_i" ) descending progress
    Index On Str( FIELD->kod_h, 7 ) to ( dir_server() + "mo_pp_h" ) progress
  Case sBase == "mo_ppdia"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->tip, 1 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_ppper"
    Index On Str( FIELD->kod, 7 ) + DToS( FIELD->n_data ) to ( dir_server() + sBase ) progress
    //
  Case sBase == "human"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "humank" ) progress
    Index On Str( if( FIELD->kod > 0, FIELD->kod_k, 0 ), 7 ) + Str( FIELD->tip_h, 1 ) to ( dir_server() + "humankk" ) progress
    Index On Str( FIELD->tip_h, 1 ) + Str( FIELD->otd, 3 ) + Upper( SubStr( FIELD->fio, 1, 20 ) ) to ( dir_server() + "humann" ) progress
    Index On DToS( FIELD->k_data ) + FIELD->uch_doc to ( dir_server() + "humand" ) progress
    Index On FIELD->date_opl to ( dir_server() + "humano" ) progress
    Index On Str( FIELD->schet, 6 ) + Str( FIELD->tip_h, 1 ) + Upper( SubStr( FIELD->fio, 1, 20 ) ) to ( dir_server() + "humans" ) progress
  Case sBase == "human_3"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "human_3" ) progress
    Index On Str( FIELD->kod2, 7 ) to ( dir_server() + "human_32" ) progress
  Case sBase == "human_u"
    Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + "human_u" ) progress
    Index On Str( FIELD->u_kod, 4 ) to ( dir_server() + "human_uk" ) progress
    Index On FIELD->date_u to ( dir_server() + "human_ud" ) progress
    Index On Str( FIELD->kod_vr, 4 ) + FIELD->date_u to ( dir_server() + "human_uv" ) progress
    Index On Str( FIELD->kod_as, 4 ) + FIELD->date_u to ( dir_server() + "human_ua" ) progress
  Case sBase == "human_im"
    Index On Str( FIELD->kod_hum, 7 ) + Str( FIELD->mo_hu_k, 7 ) to ( dir_server() + "human_im" ) progress
  Case sBase == "human_lek_pr"
    Index On Str( FIELD->kod_hum, 7 ) to ( dir_server() + "human_lek_pr" ) progress
  Case sBase == "human_ser_num"
    Index On FIELD->type_fil + Str( FIELD->rec_n, 7 ) to ( dir_server() + "human_ser_num" ) progress
  Case sBase == "mo_hu"
    Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + "mo_hu" ) progress
    Index On Str( FIELD->u_kod, 6 ) to ( dir_server() + "mo_huk" ) progress
    Index On FIELD->date_u to ( dir_server() + "mo_hud" ) progress
    Index On Str( FIELD->kod_vr, 4 ) + FIELD->date_u to ( dir_server() + "mo_huv" ) progress
    Index On Str( FIELD->kod_as, 4 ) + FIELD->date_u to ( dir_server() + "mo_hua" ) progress
  Case sBase == "mo_dnab"
    Index On Str( FIELD->KOD_K, 7 ) + FIELD->KOD_DIAG to ( dir_server() + "mo_dnab" )
  Case sBase == "mo_hdisp"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->ks, 2 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onkna"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onksl"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onkdi"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->diag_tip, 1 ) + Str( FIELD->diag_code, 3 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onkpr"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->prot, 1 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onkus"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->usl_tip, 1 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onkco"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_onkle"
    Index On Str( FIELD->kod, 7 ) + FIELD->regnum + FIELD->code_sh + DToS( FIELD->date_inj ) to ( dir_server() + sBase ) progress
  Case sBase == "humanst"
    Index On Str( FIELD->tip_bd, 1 ) + Str( FIELD->rec_bd, 8 ) to ( dir_server() + sBase ) progress
  Case sBase == "mo_refr"
    Index On Str( FIELD->tipd, 1 ) + Str( FIELD->kodd, 6 ) + Str( FIELD->tipz, 1 ) + Str( FIELD->kodz, 8 ) to ( dir_server() + sBase ) progress
  Case sBase == "schet"
    Index On Str( FIELD->kod, 6 ) to ( dir_server() + "schetk" ) progress
    Index On FIELD->nomer_s + FIELD->pdate to ( dir_server() + "schetn" ) progress
    Index On Str( FIELD->komu, 1 ) + Str( FIELD->str_crb, 2 ) + FIELD->nomer_s to ( dir_server() + "schetp" ) progress
    Index On FIELD->pdate + FIELD->nomer_s to ( dir_server() + "schetd" ) progress
    //
  Case sBase == "plat_ms"
    Index On Str( FIELD->tip, 1 ) + Str( FIELD->tab_nom, 5 ) to ( dir_server() + sBase ) progress
  Case sBase == "plat_vz"
    Index On Str( FIELD->tip, 1 ) + Str( FIELD->pr_smo, 6 ) + Str( FIELD->kod_k, 7 ) + DToS( FIELD->date_opl ) to ( dir_server() + sBase ) descending progress
  Case sBase == "hum_p"
    Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->k_data ) + Str( FIELD->KV_CIA, 6 ) to ( dir_server() + "hum_pkk" ) descending progress
    Index On Str( FIELD->otd, 3 ) to ( dir_server() + "hum_pn" ) progress
    Index On DToS( FIELD->k_data ) to ( dir_server() + "hum_pd" ) progress
    Index On Str( FIELD->n_kvit, 5 ) to ( dir_server() + "hum_pv" ) progress
    Index On Str( FIELD->tip_usl, 1 ) + iif( Empty( FIELD->date_close ), "0" + DToS( FIELD->k_data ), "1" + DToS( FIELD->date_close ) ) + ;
      DToS( FIELD->k_data ) to ( dir_server() + "hum_pc" ) progress
  Case sBase == "hum_p_u"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "hum_p_u" ) progress
    Index On Str( FIELD->u_kod, 4 ) to ( dir_server() + "hum_p_uk" ) progress
    Index On FIELD->date_u to ( dir_server() + "hum_p_ud" ) progress
    Index On Str( FIELD->kod_vr, 4 ) + FIELD->date_u to ( dir_server() + "hum_p_uv" ) progress
    Index On Str( FIELD->kod_as, 4 ) + FIELD->date_u to ( dir_server() + "hum_p_ua" ) progress
  Case sBase == "hum_plat"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
//  Case sBase == "payments"
//    Index On Str( FIELD->IDCONTR, 7 ) to ( dir_server() + 'payments' ) progress
//    Index On DToS( FIELD->DATE ) to ( dir_server() + 'payments_date' ) progress
//    Index On Str( FIELD->TYPEPAYER, 1 ) + Str( FIELD->IDPAYER, 7 ) to ( dir_server() + 'payments_payer' ) progress
//  Case sBase == "payer"
//    Index On FIELD->NAME to ( dir_server() + sBase ) progress

  Case sBase == "pu_date"
    Index On DToS( FIELD->data ) to ( dir_server() + sBase ) descending
  Case sBase == "pu_cena"
    Index On Str( FIELD->kod_date, 4 ) + Str( FIELD->kod_usl, 4 ) to ( dir_server() + "pu_cena" ) progress
    Index On Str( FIELD->kod_usl, 4 ) + Str( FIELD->kod_date, 4 ) to ( dir_server() + "pu_cenau" ) progress
    //
  Case sBase == "diag_ort"
    Index On FIELD->shifr to ( dir_server() + sBase )
  Case sBase == "orto_uva"
    Index On FIELD->shifr to ( dir_server() + sBase )
  Case sBase == "hum_ort"
    Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->data ) to ( dir_server() + "hum_ortk" ) descending progress
    Index On Str( FIELD->nar_z, 5 ) to ( dir_server() + "hum_ortn" ) progress
    Index On DToS( FIELD->k_data ) to ( dir_server() + "hum_ortd" ) progress
    Index On DToS( FIELD->data ) to ( dir_server() + "hum_orto" ) progress
  Case sBase == "hum_oro"
    Index On Str( FIELD->kod, 7 ) + FIELD->pdate to ( dir_server() + "hum_oro" ) progress
    Index On Str( FIELD->n_kvit, 5 ) to ( dir_server() + "hum_orov" ) progress
    Index On FIELD->pdate to ( dir_server() + "hum_orod" ) progress
  Case sBase == "hum_oru"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "hum_oru" ) progress
    Index On Str( FIELD->u_kod, 4 ) to ( dir_server() + "hum_oruk" ) progress
    Index On FIELD->date_u to ( dir_server() + "hum_orud" ) progress
    Index On Str( FIELD->kod_vr, 4 ) + FIELD->date_u to ( dir_server() + "hum_oruv" ) progress
    Index On Str( FIELD->kod_as, 4 ) + FIELD->date_u to ( dir_server() + "hum_orua" ) progress
  Case sBase == "hum_orpl"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
  Case sBase == "ortoped2"
    Index On Str( FIELD->kod_tip, 4 ) to ( dir_server() + sBase ) progress
    //
  Case sBase == "kas_pl"
    Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->k_data ) + Str( FIELD->n_chek, 8 ) to ( dir_server() + "kas_pl1" ) descending progress
    Index On DToS( FIELD->k_data ) to ( dir_server() + "kas_pl2" ) progress
    Index On Str( FIELD->n_chek, 8 ) to ( dir_server() + "kas_pl3" ) progress
  Case sBase == "kas_pl_u"
    Index On Str( FIELD->kod, 7 ) to ( dir_server() + "kas_pl1u" ) progress
    Index On Str( FIELD->u_kod, 4 ) to ( dir_server() + "kas_pl2u" ) progress
  Case sBase == "kas_ort"
    Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->k_data ) + Str( FIELD->nomer_n, 6 ) to ( dir_server() + "kas_ort1" ) descending progress
    Index On DToS( FIELD->k_data ) to ( dir_server() + "kas_ort2" ) progress
    Index On Str( FIELD->n_chek, 8 ) to ( dir_server() + "kas_ort3" ) progress
    Index On Str( FIELD->year_n, 4 ) + Str( FIELD->nomer_n, 6 ) to ( dir_server() + "kas_ort4" ) progress
    Index On Str( FIELD->vid, 1 ) + DToS( FIELD->k_data ) to ( dir_server() + "kas_ort5" ) progress
  Case sBase == "kas_ortu"
    Index On Str( FIELD->kod, 7 ) + Str( FIELD->vid, 1 ) to ( dir_server() + "kas_or1u" ) progress
    Index On Str( FIELD->u_kod, 4 ) to ( dir_server() + "kas_or2u" ) progress
  Case sBase == 'register_fns'
    Index On Str( FIELD->kod_k, 7 ) + Str( FIELD->nyear, 4 ) + Str( FIELD->attribut, 1 ) + Str( FIELD->num_s, 7 ) + Str( FIELD->version, 3 ) to ( dir_server() + 'reg_fns' ) progress
  Case sBase == 'reg_link_fns'
    Index On Str( FIELD->kod_spr, 7 ) to ( dir_server() + 'reg_link' ) progress
  Case sBase == 'reg_xml_fns'
    Index On Str( FIELD->kod, 6 ) to ( dir_server() + 'reg_xml' ) progress
  Case sBase == 'reg_people_fns'
//    Index On str( FIELD->kod, 7 ) to ( dir_server() + sBase ) progress
    Index On FIELD->kod to ( dir_server() + sBase ) progress
    Index On FIELD->fio to ( dir_server() + sBase + '_fio' ) progress
  
  //
  // Case sBase == "mo_kekh"
  //   Index On Str( FIELD->kod_lu, 7 ) to ( dir_server() + sBase ) progress
  // Case sBase == "mo_keke"
  //   Index On Str( FIELD->kod, 7 ) + Str( FIELD->tip_eks, 1 ) to ( dir_server() + "mo_keket" ) progress
  //   Index On Str( FIELD->kod_eks, 3 ) + DToS( FIELD->date_eks ) to ( dir_server() + "mo_kekee" ) descending progress
  //   Index On DToS( FIELD->date_eks ) to ( dir_server() + "mo_keked" ) progress
  // Case sBase == "mo_kekez"
  //   Index On Str( FIELD->kod, 7 ) + Str( FIELD->stroke, 2 ) to ( dir_server() + sBase ) progress
  Endcase
  If Type( "fl_open" ) == "L" .and. fl_open
    __tmp__->( dbCloseArea() )
  Endif
  Return Nil
