// #include "inkey.ch"
#include "function.ch"
// #include "edit_spr.ch"
#include "chip_mo.ch"

// 14.01.25
Function index_base( sBase )

  Millisec( 100 )  // задержка на 0.1 с
  If Type( "fl_open" ) == "L" .and. fl_open
    If !hb_FileExists( dir_server + sBase + sdbf ) // если нет файла
      Return Nil                             // выйти из функции
    Endif
    Use ( dir_server + sBase ) New Alias __TMP__ READONLY
    If Select( "__TMP__" ) == 0
      n_message( { "Неудачная попытка открытия файла базы данных", ;
        Upper( dir_server + sBase + sdbf ), ;
        "Скорее всего, данный файл занят либо другим пользователем,", ;
        "либо каким-нибудь системным процессом.", ;
        "Попытайтесь войти в данный режим позже или", ;
        "перезагрузите компьютер (сервер) и попытайтесь снова.";
        },, "GR+/R", "W+/R",,, "G+/R" )
      Return Nil
    Endif
  Endif
  sBase := Lower( sBase )
  Do Case
  Case sBase == "mo_add"
    Index On codem to ( dir_server + sBase )
  Case sBase == "s_adres"
    Index On Upper( name ) to ( dir_server + sBase )
  Case sBase == "s_kemvyd"
    Index On Upper( SubStr( name, 1, 80 ) ) to ( dir_server + sBase )
  Case sBase == "mo_pers"
    Index On Str( tab_nom, 5 ) to ( dir_server + sBase )
  Case sBase == "mo_regi"
    Index On Str( tip, 1 ) to ( dir_server + "mo_regi1" ) progress
    Index On pdate to ( dir_server + "mo_regi2" ) progress
    Index On Str( kod_k, 7 ) + pdate + ctime to ( dir_server + "mo_regi3" ) descending progress
  Case sBase == "msek"
    Index On Str( kod_k, 7 ) + Str( Descend( date_kom ), 10 ) to ( dir_server + sBase ) progress
  Case sBase == "slugba"
    Index On Str( shifr, 3 ) to ( dir_server + sBase )
  Case sBase == "mo_su"
    Index On Str( kod, 6 ) to ( dir_server + "mo_su" ) progress
    Index On shifr to ( dir_server + "mo_sush" ) progress
    Index On shifr1 + Str( tip, 1 ) to ( dir_server + "mo_sush1" ) progress
  Case sBase == "uslugi"
    Index On Str( kod, 4 ) to ( dir_server + "uslugi" ) progress
    Index On shifr to ( dir_server + "uslugish" ) progress
    Index On iif( Empty( shifr1 ), shifr, shifr1 ) to ( dir_server + "uslugis1" ) progress
    Index On Str( slugba, 3 ) to ( dir_server + "uslugisl" ) progress
  Case sBase == "uslugi1"
    Index On Str( kod, 4 ) + DToS( date_b ) to ( dir_server + "uslugi1" ) progress
    Index On shifr1 + DToS( date_b ) to ( dir_server + "uslugi1s" ) progress
  Case sBase == "usl_otd"
    Index On Str( kod, 4 ) to ( dir_server + sBase ) progress
  Case sBase == "uslugi_k"
    Index On shifr to ( dir_server + sBase ) progress
  Case sBase == "uslugi1k"
    Index On shifr + shifr1 to ( dir_server + sBase ) progress
  Case sBase == "ns_usl_k"
    Index On Str( kod, 6 ) to ( dir_server + sBase ) progress
  Case sBase == "usl_uva"
    Index On shifr to ( dir_server + sBase ) progress
  Case sBase == "uch_usl"
    Index On Str( kod, 4 ) to ( dir_server + sBase ) progress
  Case sBase == "uch_usl1"
    Index On Str( kod, 4 ) + DToS( date_b ) to ( dir_server + sBase ) progress
  Case sBase == "uch_pers"
    Index On Str( kod, 4 ) + Str( god, 4 ) + Str( mes, 2 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_oper"
    Index On pd + po + Str( task, 1 ) + Str( app_edit, 1 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_opern"
    Index On pd + po + pt + tp + ae to ( dir_server + sBase ) progress
  Case sBase == "kartotek"
    Index On Str( kod, 7 ) to ( dir_server + "kartotek" ) progress
    Index On if( kod > 0, "1", "0" ) + Upper( fio ) + DToS( date_r ) to ( dir_server + "kartoten" ) progress
    Index On if( kod > 0, "1", "0" ) + polis to ( dir_server + "kartotep" ) progress
    Index On StrZero( uchast, 2 ) + StrZero( kod_vu, 5 ) to ( dir_server + "kartoteu" ) progress
    Index On if( kod > 0, "1", "0" ) + snils to ( dir_server + "kartotes" ) progress
    Index On if( kod > 0, "1", "0" ) + kod_mis to ( dir_server + "kartotee" ) progress
  Case sBase == "k_prim1"
    Index On Str( kod, 7 ) + Str( stroke, 1 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_kartp"
    Index On Str( kod_k, 7 ) + DToS( d_prik ) to ( dir_server + sBase ) progress
  Case sBase == "kartdelz"
    Index On Str( kod, 7 ) + Str( zf, 2 ) to ( dir_server + "kartdelz" ) progress
  Case sBase == "kart_st"
    Index On Str( kod, 7 ) + Str( zf, 2 ) + date_u to ( dir_server + "kart_st" ) progress
    Index On Str( tip_bd, 1 ) + Str( rec_bd, 8 ) to ( dir_server + "kart_st1" ) progress
  Case sBase == "mo_kpred"
    Index On Str( kod, 7 ) + Str( nn, 1 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_kinos"
    Index On Str( kod, 7 ) to ( dir_server + sBase ) progress
    //
  Case sBase == "mo_pp"
    Index On Str( kod, 7 ) to ( dir_server + "mo_pp_k" ) progress
    Index On DToS( n_data ) + n_time to ( dir_server + "mo_pp_d" ) progress
    Index On Str( kod_k, 7 ) + DToS( n_data ) to ( dir_server + "mo_pp_r" ) descending progress
    Index On Str( Year( n_data ), 4 ) + uch_doc to ( dir_server + "mo_pp_i" ) descending progress
    Index On Str( kod_h, 7 ) to ( dir_server + "mo_pp_h" ) progress
  Case sBase == "mo_ppdia"
    Index On Str( kod, 7 ) + Str( tip, 1 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_ppper"
    Index On Str( kod, 7 ) + DToS( n_data ) to ( dir_server + sBase ) progress
    //
  Case sBase == "human"
    Index On Str( kod, 7 ) to ( dir_server + "humank" ) progress
    Index On Str( if( kod > 0, kod_k, 0 ), 7 ) + Str( tip_h, 1 ) to ( dir_server + "humankk" ) progress
    Index On Str( tip_h, 1 ) + Str( otd, 3 ) + Upper( SubStr( fio, 1, 20 ) ) to ( dir_server + "humann" ) progress
    Index On DToS( k_data ) + uch_doc to ( dir_server + "humand" ) progress
    Index On date_opl to ( dir_server + "humano" ) progress
    Index On Str( schet, 6 ) + Str( tip_h, 1 ) + Upper( SubStr( fio, 1, 20 ) ) to ( dir_server + "humans" ) progress
  Case sBase == "human_3"
    Index On Str( kod, 7 ) to ( dir_server + "human_3" ) progress
    Index On Str( kod2, 7 ) to ( dir_server + "human_32" ) progress
  Case sBase == "human_u"
    Index On Str( kod, 7 ) + date_u to ( dir_server + "human_u" ) progress
    Index On Str( u_kod, 4 ) to ( dir_server + "human_uk" ) progress
    Index On date_u to ( dir_server + "human_ud" ) progress
    Index On Str( kod_vr, 4 ) + date_u to ( dir_server + "human_uv" ) progress
    Index On Str( kod_as, 4 ) + date_u to ( dir_server + "human_ua" ) progress
  Case sBase == "human_im"
    Index On Str( kod_hum, 7 ) + Str( mo_hu_k, 7 ) to ( dir_server + "human_im" ) progress
  Case sBase == "human_lek_pr"
    Index On Str( kod_hum, 7 ) to ( dir_server + "human_lek_pr" ) progress
  Case sBase == "human_ser_num"
    Index On type_fil + Str( rec_n, 7 ) to ( dir_server + "human_ser_num" ) progress
  Case sBase == "mo_hu"
    Index On Str( kod, 7 ) + date_u to ( dir_server + "mo_hu" ) progress
    Index On Str( u_kod, 6 ) to ( dir_server + "mo_huk" ) progress
    Index On date_u to ( dir_server + "mo_hud" ) progress
    Index On Str( kod_vr, 4 ) + date_u to ( dir_server + "mo_huv" ) progress
    Index On Str( kod_as, 4 ) + date_u to ( dir_server + "mo_hua" ) progress
  Case sBase == "mo_dnab"
    Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
  Case sBase == "mo_hdisp"
    Index On Str( kod, 7 ) + Str( ks, 2 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onkna"
    Index On Str( kod, 7 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onksl"
    Index On Str( kod, 7 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onkdi"
    Index On Str( kod, 7 ) + Str( diag_tip, 1 ) + Str( diag_code, 3 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onkpr"
    Index On Str( kod, 7 ) + Str( prot, 1 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onkus"
    Index On Str( kod, 7 ) + Str( usl_tip, 1 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onkco"
    Index On Str( kod, 7 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_onkle"
    Index On Str( kod, 7 ) + regnum + code_sh + DToS( date_inj ) to ( dir_server + sBase ) progress
  Case sBase == "humanst"
    Index On Str( tip_bd, 1 ) + Str( rec_bd, 8 ) to ( dir_server + sBase ) progress
  Case sBase == "mo_refr"
    Index On Str( tipd, 1 ) + Str( kodd, 6 ) + Str( tipz, 1 ) + Str( kodz, 8 ) to ( dir_server + sBase ) progress
  Case sBase == "schet"
    Index On Str( kod, 6 ) to ( dir_server + "schetk" ) progress
    Index On nomer_s + pdate to ( dir_server + "schetn" ) progress
    Index On Str( komu, 1 ) + Str( str_crb, 2 ) + nomer_s to ( dir_server + "schetp" ) progress
    Index On pdate + nomer_s to ( dir_server + "schetd" ) progress
    //
  Case sBase == "plat_ms"
    Index On Str( tip, 1 ) + Str( tab_nom, 5 ) to ( dir_server + sBase ) progress
  Case sBase == "plat_vz"
    Index On Str( tip, 1 ) + Str( pr_smo, 6 ) + Str( kod_k, 7 ) + DToS( date_opl ) to ( dir_server + sBase ) descending progress
  Case sBase == "hum_p"
    Index On Str( kod_k, 7 ) + DToS( k_data ) + Str( KV_CIA, 6 ) to ( dir_server + "hum_pkk" ) descending progress
    Index On Str( otd, 3 ) to ( dir_server + "hum_pn" ) progress
    Index On DToS( k_data ) to ( dir_server + "hum_pd" ) progress
    Index On Str( n_kvit, 5 ) to ( dir_server + "hum_pv" ) progress
    Index On Str( tip_usl, 1 ) + iif( Empty( date_close ), "0" + DToS( k_data ), "1" + DToS( date_close ) ) + ;
      DToS( k_data ) to ( dir_server + "hum_pc" ) progress
  Case sBase == "hum_p_u"
    Index On Str( kod, 7 ) to ( dir_server + "hum_p_u" ) progress
    Index On Str( u_kod, 4 ) to ( dir_server + "hum_p_uk" ) progress
    Index On date_u to ( dir_server + "hum_p_ud" ) progress
    Index On Str( kod_vr, 4 ) + date_u to ( dir_server + "hum_p_uv" ) progress
    Index On Str( kod_as, 4 ) + date_u to ( dir_server + "hum_p_ua" ) progress
  Case sBase == "hum_plat"
    Index On Str( kod, 7 ) to ( dir_server + sBase ) progress
//  Case sBase == "payments"
//    Index On Str( IDCONTR, 7 ) to ( dir_server + 'payments' ) progress
//    Index On DToS( DATE ) to ( dir_server + 'payments_date' ) progress
//    Index On Str( TYPEPAYER, 1 ) + Str( IDPAYER, 7 ) to ( dir_server + 'payments_payer' ) progress
//  Case sBase == "payer"
//    Index On NAME to ( dir_server + sBase ) progress

  Case sBase == "pu_date"
    Index On DToS( data ) to ( dir_server + sBase ) descending
  Case sBase == "pu_cena"
    Index On Str( kod_date, 4 ) + Str( kod_usl, 4 ) to ( dir_server + "pu_cena" ) progress
    Index On Str( kod_usl, 4 ) + Str( kod_date, 4 ) to ( dir_server + "pu_cenau" ) progress
    //
  Case sBase == "diag_ort"
    Index On shifr to ( dir_server + sBase )
  Case sBase == "orto_uva"
    Index On shifr to ( dir_server + sBase )
  Case sBase == "hum_ort"
    Index On Str( kod_k, 7 ) + DToS( data ) to ( dir_server + "hum_ortk" ) descending progress
    Index On Str( nar_z, 5 ) to ( dir_server + "hum_ortn" ) progress
    Index On DToS( k_data ) to ( dir_server + "hum_ortd" ) progress
    Index On DToS( data ) to ( dir_server + "hum_orto" ) progress
  Case sBase == "hum_oro"
    Index On Str( kod, 7 ) + pdate to ( dir_server + "hum_oro" ) progress
    Index On Str( n_kvit, 5 ) to ( dir_server + "hum_orov" ) progress
    Index On pdate to ( dir_server + "hum_orod" ) progress
  Case sBase == "hum_oru"
    Index On Str( kod, 7 ) to ( dir_server + "hum_oru" ) progress
    Index On Str( u_kod, 4 ) to ( dir_server + "hum_oruk" ) progress
    Index On date_u to ( dir_server + "hum_orud" ) progress
    Index On Str( kod_vr, 4 ) + date_u to ( dir_server + "hum_oruv" ) progress
    Index On Str( kod_as, 4 ) + date_u to ( dir_server + "hum_orua" ) progress
  Case sBase == "hum_orpl"
    Index On Str( kod, 7 ) to ( dir_server + sBase ) progress
  Case sBase == "ortoped2"
    Index On Str( kod_tip, 4 ) to ( dir_server + sBase ) progress
    //
  Case sBase == "kas_pl"
    Index On Str( kod_k, 7 ) + DToS( k_data ) + Str( n_chek, 8 ) to ( dir_server + "kas_pl1" ) descending progress
    Index On DToS( k_data ) to ( dir_server + "kas_pl2" ) progress
    Index On Str( n_chek, 8 ) to ( dir_server + "kas_pl3" ) progress
  Case sBase == "kas_pl_u"
    Index On Str( kod, 7 ) to ( dir_server + "kas_pl1u" ) progress
    Index On Str( u_kod, 4 ) to ( dir_server + "kas_pl2u" ) progress
  Case sBase == "kas_ort"
    Index On Str( kod_k, 7 ) + DToS( k_data ) + Str( nomer_n, 6 ) to ( dir_server + "kas_ort1" ) descending progress
    Index On DToS( k_data ) to ( dir_server + "kas_ort2" ) progress
    Index On Str( n_chek, 8 ) to ( dir_server + "kas_ort3" ) progress
    Index On Str( year_n, 4 ) + Str( nomer_n, 6 ) to ( dir_server + "kas_ort4" ) progress
    Index On Str( vid, 1 ) + DToS( k_data ) to ( dir_server + "kas_ort5" ) progress
  Case sBase == "kas_ortu"
    Index On Str( kod, 7 ) + Str( vid, 1 ) to ( dir_server + "kas_or1u" ) progress
    Index On Str( u_kod, 4 ) to ( dir_server + "kas_or2u" ) progress
  Case sBase == 'register_fns'
    Index On Str( kod_k, 7 ) + Str( nyear, 4 ) + Str( attribut, 1 ) + Str( num_s, 7 ) + Str( version, 3 ) to ( dir_server + 'reg_fns' ) progress
  Case sBase == 'reg_link_fns'
    Index On Str( kod_spr, 7 ) to ( dir_server + 'reg_link' ) progress
  Case sBase == 'reg_xml_fns'
    Index On Str( kod, 6 ) to ( dir_server + 'reg_xml' ) progress
  Case sBase == 'reg_people_fns'
    Index On str( kod, 7 ) to ( dir_server + sBase ) progress
    Index On fio to ( dir_server + sBase + '_fio' ) progress
  
  //
  // Case sBase == "mo_kekh"
  //   Index On Str( kod_lu, 7 ) to ( dir_server + sBase ) progress
  // Case sBase == "mo_keke"
  //   Index On Str( kod, 7 ) + Str( tip_eks, 1 ) to ( dir_server + "mo_keket" ) progress
  //   Index On Str( kod_eks, 3 ) + DToS( date_eks ) to ( dir_server + "mo_kekee" ) descending progress
  //   Index On DToS( date_eks ) to ( dir_server + "mo_keked" ) progress
  // Case sBase == "mo_kekez"
  //   Index On Str( kod, 7 ) + Str( stroke, 2 ) to ( dir_server + sBase ) progress
  Endcase
  If Type( "fl_open" ) == "L" .and. fl_open
    __tmp__->( dbCloseArea() )
  Endif

  Return Nil
