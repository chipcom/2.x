#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 21.01.19
Function read_arr_DVN(lkod,is_all)
  Local arr, i, sk
  Private mvar
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
        case arr[i,1] == "47" .and. valtype(arr[i,2]) == "N"
          m1dopo_na  := arr[i,2]
        case arr[i,1] == "48" .and. valtype(arr[i,2]) == "N"
          m1ssh_na   := arr[i,2]
        case arr[i,1] == "49" .and. valtype(arr[i,2]) == "N"
          m1spec_na  := arr[i,2]
        case arr[i,1] == "50" .and. valtype(arr[i,2]) == "N"
          m1sank_na  := arr[i,2]
        case arr[i,1] == "51" .and. valtype(arr[i,2]) == "N"
          m1p_otk  := arr[i,2]
        case arr[i,1] == "52" .and. valtype(arr[i,2]) == "N"
          m1napr_v_mo  := arr[i,2]
        case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
          arr_mo_spec := arr[i,2]
        case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
          m1napr_stac := arr[i,2]
        case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
          m1profil_stac := arr[i,2]
        case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
          m1napr_reab := arr[i,2]
        case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
          m1profil_kojki := arr[i,2]
      endcase
    endif
  next
  return NIL

***** 21.01.18
Function save_arr_DVN(lkod)
  Local arr := {}, i, sk, ta
  if type("mfio") == "C"
    aadd(arr,{"mfio",alltrim(mfio)})
  endif
  if type("mdate_r") == "D"
    aadd(arr,{"mdate_r",mdate_r})
  endif
  aadd(arr,{ "VB",m1veteran})  // "N",���࠭ ��� (���������)
  aadd(arr,{ "0",m1mobilbr})   // "N",�����쭠� �ਣ���
  aadd(arr,{ "1",m1kurenie})   // "N",��७��
  aadd(arr,{ "2",m1riskalk})   // "N",��������
  aadd(arr,{ "3",m1pod_alk})   // "N",��મ⨪�
  aadd(arr,{ "3.1",m1psih_na})   // "N",        ���ࠢ��� � ��娠���-��મ����
  aadd(arr,{ "4",m1fiz_akt})   // "N",������ 䨧��᪠� ��⨢�����
  aadd(arr,{ "5",m1ner_pit})   // "N",���樮���쭮� ��⠭��
  aadd(arr,{ "6",mWEIGHT})     // "N",���
  aadd(arr,{ "7",mHEIGHT})     // "N",���
  aadd(arr,{ "8",mOKR_TALII})  // "N",���㦭���� ⠫��
  aadd(arr,{ "9",mad1})        // "N",���ਠ�쭮� ��������
  aadd(arr,{"10",mad2})        // "N",���ਠ�쭮� ��������
  aadd(arr,{"11",m1addn})      // "N",����⥭������ �࠯��
  aadd(arr,{"12",mholest})     // "N",��騩 宫���ਭ
  aadd(arr,{"13",m1holestdn})  // "N",�������������᪠� �࠯��
  aadd(arr,{"14",mglukoza})    // "N",����
  aadd(arr,{"15",m1glukozadn}) // "N",������������᪠� �࠯��
  aadd(arr,{"16",mssr})        // "N",�㬬��� �थ筮-��㤨��� ��
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
    aadd(arr,{"29",arr_usl_otkaz}) // ���ᨢ
  endif
  aadd(arr,{"30",m1GRUPPA})    // "N1",��㯯� ���஢�� ��᫥ ���-��
  if type("m1prof_ko") == "N"
    aadd(arr,{"31",m1prof_ko})    // "N1",��� ���.�������஢����
  endif
  if type("m1ot_nasl1") == "N"
    aadd(arr,{"40",arr_otklon}) // ���ᨢ
    aadd(arr,{"41",m1ot_nasl1})
    aadd(arr,{"42",m1ot_nasl2})
    aadd(arr,{"43",m1ot_nasl3})
    aadd(arr,{"44",m1ot_nasl4})
    aadd(arr,{"45",m1dispans})
    aadd(arr,{"46",m1nazn_l})
    aadd(arr,{"47",m1dopo_na})
    aadd(arr,{"48",m1ssh_na})
    aadd(arr,{"49",m1spec_na})
    aadd(arr,{"50",m1sank_na})
  endif
  if type("m1p_otk") == "N"
    aadd(arr,{"51",m1p_otk})
  endif
  if type("m1napr_v_mo") == "N"
    aadd(arr,{"52",m1napr_v_mo})
  endif
  if type("arr_mo_spec") == "A" .and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // ���ᨢ
  endif
  if type("m1napr_stac") == "N"
    aadd(arr,{"54",m1napr_stac})
  endif
  if type("m1profil_stac") == "N"
    aadd(arr,{"55",m1profil_stac})
  endif
  if type("m1napr_reab") == "N"
    aadd(arr,{"56",m1napr_reab})
  endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif
  save_arr_DISPANS(lkod,arr)
  return NIL
  
  