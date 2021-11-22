***** ࠧ���� �㭪樨 ��饣� ���짮����� ��� ࠡ��� � 䠩���� �� - use_func.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 31.01.17
Function R_Use_base(sBase, lalias)
  return use_base(sBase, lalias, , .t.)

***** 02.01.21
Function use_base(sBase, lalias, lExcluUse, lREADONLY)
  Local fl := .t., sind1, sind2

  sBase := lower(sBase)
  do case
    case sBase == "lusl"
      fl := R_Use(exe_dir + "_mo8usl", cur_dir + "_mo8usl", sBase + "18") .and. ;
        R_Use(exe_dir + "_mo9usl", cur_dir + "_mo9usl", sBase + "19") .and. ;
        R_Use(exe_dir + "_mo0usl", cur_dir + "_mo0usl", sBase + "20") .and. ;
        R_Use(exe_dir + "_mo1usl", cur_dir + "_mo1usl", sBase)
    case sBase == "luslc"
      fl := R_Use(exe_dir + "_mo8uslc", {cur_dir + "_mo8uslc", cur_dir + "_mo8uslu"}, sBase + "18") .and. ;
        R_Use(exe_dir + "_mo9uslc", {cur_dir + "_mo9uslc", cur_dir + "_mo9uslu"}, sBase + "19") .and. ;
        R_Use(exe_dir + "_mo0uslc", {cur_dir + "_mo0uslc", cur_dir + "_mo0uslu"}, sBase + "20") .and. ;
        R_Use(exe_dir + "_mo1uslc", {cur_dir + "_mo1uslc", cur_dir + "_mo1uslu"}, sBase)
    case sBase == "luslf"
      fl := R_Use(exe_dir + "_mo8uslf", cur_dir + "_mo8uslf", sBase + "18") .and. ;
        R_Use(exe_dir + "_mo9uslf", cur_dir + "_mo9uslf", sBase + "19") .and. ;
        R_Use(exe_dir + "_mo0uslf", cur_dir + "_mo0uslf", sBase + "20") .and. ;
        R_Use(exe_dir + "_mo1uslf", cur_dir + "_mo1uslf", sBase)
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
  endcase
  return fl

*****
Function useUch_Usl()
  return G_Use(dir_server + "uch_usl", dir_server + "uch_usl", "UU") .and. ;
      G_Use(dir_server + "uch_usl1", dir_server + "uch_usl1", "UU1")


***** 21.01.19 �஢����, �������஢��� �� ������, �, �᫨ ���, � �������஢��� ��
Function my_Rec_Lock(n)
  if ascan(dbRLockList(), n) == 0
    G_RLock(forever)
  endif
  return NIL
  
***** ������ � ���ᨢ� ������ ���� ������
Function get_field()
  Local arr := array(fcount())
  aeval(arr, {|x, i| arr[i] := fieldget(i) }  )
  return arr
  

***** 04.04.18 �����஢��� ������, ��� ���� KOD == 0 (���� �������� ������)
Function Add1Rec(n, lExcluUse)
  Local fl := .t., lOldDeleted := SET(_SET_DELETED, .F.)

  DEFAULT lExcluUse TO .f.
  find (str(0, n))
  if found()
    do while kod == 0 .and. !eof()
      if iif(lExcluUse, .t., RLock())
        IF DELETED()
          RECALL
        ENDIF
        fl := .f.
        exit
      endif
      skip
    enddo
  endif
  if fl  // ���������� �����
    if lExcluUse
      APPEND BLANK
    else
      DO WHILE .t.
        APPEND BLANK
        IF !NETERR()
          exit
        ENDIF
      ENDDO
    endif
  endif
  SET(_SET_DELETED, lOldDeleted)  // ����⠭������� �।�
  return NIL

***** 11.04.18 ��ࠢ������� ���筮�� 䠩�� ���� ������ �� ��ࢨ筮��
Function dbf_equalization(lalias,lkod)
  Local fl := .t.

  dbSelectArea(lalias)
  do while lastrec() < lkod
    do while .t.
      APPEND BLANK
      fl := .f.
      if !NETERR()
        exit
      endif
    enddo
  enddo
  if fl  // �.�. �㦭�� ������ �� �������஢��� �� ����������
    goto (lkod)
    G_RLock(forever)
  endif
  return NIL

