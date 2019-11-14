***** mo_mzxml.prg создание XML-файлов для загрузки на портал МинЗдрава РФ
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 09.10.19 создать XML-файл по несовершеннолетним
Function mo_mzxml_N(_regim,n_file,stitle,lvozrast)
Static oXmlDoc, _kol, ;
       arr_np := {0,1,2,3,4,5,6,7,8,9,10,11,12,15,18,24,36,48,60,72,84,96,108,120,132,144,156,168,180,192,204}
Local i, k, s, y, m, fl, arr, arr1, buf, blk_sex, arr_before
Private p_xml_code_page := "UTF-8"
if _regim == 1
  oXmlDoc := HXMLDoc():New(p_xml_code_page)
  oXmlDoc:Add( HXMLNode():New( "children") )
  _kol := 0
elseif _regim == 2
  ++_kol
  oChild := oXmlDoc:aItems[1]:Add( HXMLNode():New( "child" ) )
   mo_add_xml_stroke(oChild,"idInternal",human_->ID_PAC)
   s := iif(eq_any(p_tip_lu,TIP_LU_DDS,TIP_LU_DDSOP), "1", "3")
   mo_add_xml_stroke(oChild,"idType",s)
   arr := retFamImOt(2,.f.)
   oName := oChild:Add( HXMLNode():New( "name" ) )
    mo_add_xml_stroke(oName,"last",arr[1])
    mo_add_xml_stroke(oName,"first",arr[2])
    if !empty(arr[3])
      mo_add_xml_stroke(oName,"middle",arr[3])
    endif
   mo_add_xml_stroke(oChild,"idSex",iif(mpol=="М","1","2"))
   mo_add_xml_stroke(oChild,"dateOfBirth",date2xml(mdate_r))
   if !(type("m1kateg_uch") == "N") .or. !between(m1kateg_uch,0,3)
     m1kateg_uch := 3
   endif
   do case
     case m1kateg_uch == 0 // ребенок-сирота",0
       i := 1
     case m1kateg_uch == 1 // ребенок, оставшийся без попечения родителей",1
       i := 3
     case m1kateg_uch == 2 // ребенок, находящийся в трудной жизненной ситуации",2
       i := 2
     case m1kateg_uch == 3 // нет категории",3
       i := 4
   endcase
   mo_add_xml_stroke(oChild,"idCategory",lstr(i))
   mo_add_xml_stroke(oChild,"idDocument",iif(kart_->vid_ud==14,"14","3"))
   if empty(s := alltrim(kart_->ser_ud))
     s := "-"
   endif
   mo_add_xml_stroke(oChild,"documentSer",s)
   if empty(s := alltrim(kart_->nom_ud))
     s := "111111"
   endif
   mo_add_xml_stroke(oChild,"documentNum",s)
   if !empty(kart->snils)
     s := charrepl(" ",transform(kart->SNILS,picture_pf),"-")
     mo_add_xml_stroke(oChild,"snils",s)
   endif
   if !empty(human_->SPOLIS)
     mo_add_xml_stroke(oChild,"polisSer",human_->SPOLIS)
   endif
   if empty(s := alltrim(human_->NPOLIS))
     s := "3400000000000000"
   endif
   mo_add_xml_stroke(oChild,"polisNum",s)
   mo_add_xml_stroke(oChild,"idInsuranceCompany",iif(human_->smo=='34002','115','290'))
   mo_add_xml_stroke(oChild,"medSanName",ret_mo(m1MO_PR)[_MO_FULL_NAME])
   mo_add_xml_stroke(oChild,"medSanAddress",ret_mo(m1MO_PR)[_MO_ADRES])
   oAddress := oChild:Add( HXMLNode():New( "address" ) )
    //mo_add_xml_stroke(oAddress,"fiasAoid","") // код города проживания по ФИАС
    //mo_add_xml_stroke(oAddress,"cityName","")   // строковое наименование пункта проживания
    mo_add_xml_stroke(oAddress,"regionCode","34")   // код региона по ФИАС
    mo_add_xml_stroke(oAddress,"fiasAoid","af757d44-3438-4040-9b68-d95099318998") // код города проживания по ФИАС
   if eq_any(p_tip_lu,TIP_LU_PREDN,TIP_LU_PERN)  //if type("m1school") == "N" .and. m1school > 0
     mo_add_xml_stroke(oChild,"idEducationOrg",'90713')  // лицей 5
   endif
   if eq_any(p_tip_lu,TIP_LU_DDS,TIP_LU_DDSOP)
     s := '0'
     if type("m1gde_nahod") == "N" .and. between(m1gde_nahod,0,5)
       do case
         case m1gde_nahod == 3 // передан в приемную семью
           s := "4"
         case m1gde_nahod == 4 // передан в патронатную семью
           s := "8"
         case m1gde_nahod == 5 // усыновлен (удочерена)
           s := "3"
         otherwise
           s := lstr(m1gde_nahod)
       endcase
     endif
     mo_add_xml_stroke(oChild,"idOrphHabitation",s)
     if empty(mdate_post)
       mdate_post := mn_data - 1
     endif
     mo_add_xml_stroke(oChild,"dateOrphHabitation",date2xml(mdate_post))
   endif
   /*if type("m1stacionar") == "N" .and. m1stacionar > 0
     mo_add_xml_stroke(oChild,"idStacOrg",'0')
   endif*/
   oCards := oChild:Add( HXMLNode():New( "cards" ) )
   // будем делать одно лечение
    oCard := oCards:Add( HXMLNode():New( "card" ) )
     mo_add_xml_stroke(oCard,"idInternal",human_->ID_C)
     mo_add_xml_stroke(oCard,"dateOfObsled",date2xml(MN_DATA))
     if p_tip_lu == TIP_LU_PN
       mperiod := ret_period_PN(mdate_r,mn_data,mk_data)
       if !between(mperiod,1,31)
         mperiod := 31
       endif
       mo_add_xml_stroke(oCard,"ageObsled",lstr(arr_np[mperiod]))
       i := 2 // профилактика 1 и 2 этап
     elseif p_tip_lu == TIP_LU_PREDN
       i := 3 // пред.осмотры 1 и 2 этап
     elseif p_tip_lu == TIP_LU_PERN
       i := 4 // период.осмотры
     else
       y := m := 0
       count_ymd(mdate_r,mn_data,@y,@m,)
       mo_add_xml_stroke(oCard,"ageObsled",lstr(int(y*12)+m))
       i := 1 // дети-сироты
     endif
     mo_add_xml_stroke(oCard,"idType",lstr(i))
     if !(type("mHEIGHT") == "N")
       mHEIGHT := 0
     endif
     mo_add_xml_stroke(oCard,"height",lstr(mHEIGHT))
     if !(type("mWEIGHT") == "N")
       mWEIGHT := 0
     endif
     mo_add_xml_stroke(oCard,"weight",lstr(mWEIGHT))
     if !(type("mPER_HEAD") == "N")
       mPER_HEAD := 0
     endif
     mo_add_xml_stroke(oCard,"headSize",lstr(mPER_HEAD))
     if type("m1FIZ_RAZV") == "N" .and. m1FIZ_RAZV > 0 ;
               .and. (between(m1FIZ_RAZV1,1,2) .or. between(m1FIZ_RAZV2,1,2))
       oHealthProblems := oCard:Add( HXMLNode():New( "healthProblems" ) )
       if between(m1FIZ_RAZV1,1,2)
         mo_add_xml_stroke(oHealthProblems,"problem",lstr(m1FIZ_RAZV1))
       endif
       if between(m1FIZ_RAZV2,1,2)
         mo_add_xml_stroke(oHealthProblems,"problem",lstr(m1FIZ_RAZV2+2))
       endif
     endif
     if !(type("m1psih11") == "N")
       m1psih11 := m1psih12 := m1psih13 := m1psih14 := 0
       m1psih21 := m1psih22 := m1psih23 := 0
     endif
     if lvozrast < 5
       oPshycDevelopment := oCard:Add( HXMLNode():New( "pshycDevelopment" ) )
        mo_add_xml_stroke(oPshycDevelopment,"poznav",lstr(m1psih11))
        mo_add_xml_stroke(oPshycDevelopment,"motor" ,lstr(m1psih12))
        mo_add_xml_stroke(oPshycDevelopment,"emot"  ,lstr(m1psih13))
        mo_add_xml_stroke(oPshycDevelopment,"rech"  ,lstr(m1psih14))
     else
       oPshycState := oCard:Add( HXMLNode():New( "pshycState" ) )
        mo_add_xml_stroke(oPshycState,"psihmot",lstr(m1psih21))
        mo_add_xml_stroke(oPshycState,"intel"  ,lstr(m1psih22))
        mo_add_xml_stroke(oPshycState,"emotveg",lstr(m1psih23))
     endif
     if !(type("m141p") == "N")
       m141p := m141ax := m141fa := 0
       m142p := m142ma := m142ax := m142me := 0
     endif
     blk_sex := {|x| lstr(iif(between(x,0,3), x, 3)) }
     if mpol == "М" // если мальчик
       oSexFormulaMale := oCard:Add( HXMLNode():New( "sexFormulaMale" ) )
        mo_add_xml_stroke(oSexFormulaMale,"P" ,eval(blk_sex,m141p))
        mo_add_xml_stroke(oSexFormulaMale,"Ax",eval(blk_sex,m141ax))
        mo_add_xml_stroke(oSexFormulaMale,"Fa",eval(blk_sex,m141fa))
     else // если девочка
       oSexFormulaFemale := oCard:Add( HXMLNode():New( "sexFormulaFemale" ) )
        mo_add_xml_stroke(oSexFormulaFemale,"P" ,eval(blk_sex,m142p))
        mo_add_xml_stroke(oSexFormulaFemale,"Ma",eval(blk_sex,m142ma))
        mo_add_xml_stroke(oSexFormulaFemale,"Ax",eval(blk_sex,m142ax))
        mo_add_xml_stroke(oSexFormulaFemale,"Me",eval(blk_sex,m142me))
       if type("m142me1") == "N" .and. (i := int(m142me1*12)+m142me2) > 0
         oMenses := oCard:Add( HXMLNode():New( "menses" ) )
          mo_add_xml_stroke(oMenses,"menarhe",lstr(i))
          if emptyall(m142p,m142ax,m142ma,m142me,m142me1,m142me2)
            m1142me3 := m1142me4 := m1142me5 := -1
          endif
          if between(m1142me3,0,1) .or. between(m1142me4,0,2) .or. between(m1142me5,0,1)
            oCharacters := oMenses:Add( HXMLNode():New( "characters" ) )
            if between(m1142me3,0,1)
              mo_add_xml_stroke(oCharacters,"char",lstr(m1142me3+1))
            endif
            if between(m1142me4,0,2)
              if m1142me4 == 0     // {{"обильные",0},;
                i := 3
              elseif m1142me4 == 1 // {"умеренные",1},;
                i := 5
              else                 // {"скудные",2}}
                i := 4
              endif
              mo_add_xml_stroke(oCharacters,"char",lstr(i))
            endif
            if between(m1142me5,0,1)
              mo_add_xml_stroke(oCharacters,"char",lstr(m1142me5+6))
            endif
          endif
       endif
     endif
     if !(type("mGRUPPA_DO") == "N") .or. !between(mGRUPPA_DO,1,5)
       mGRUPPA_DO := 1
     endif
     mo_add_xml_stroke(oCard,"healthGroupBefore",lstr(mGRUPPA_DO))
     if type("m1GR_FIZ_DO") == "N" .and. between(m1GR_FIZ_DO,0,4)
       if m1GR_FIZ_DO == 0 ; m1GR_FIZ_DO := 4 ; endif
       if m1GR_FIZ_DO == 5 .and. m1GR_FIZ_DO < mGRUPPA_DO
         --m1GR_FIZ_DO
       endif
       mo_add_xml_stroke(oCard,"fizkultGroupBefore",lstr(m1GR_FIZ_DO))
     endif
     kol_DiagnosisBefore := 0 ; arr_before := {}
     if type("m1diag_15_1") == "N" .and. m1diag_15_1 == 0
       for i := 1 to 5
         fl := .f.
         for k := 1 to 14
           mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
           if k == 1
             fl := !empty(&mvar) .and. m1diag_15_1 == 0
           else
             m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
             if fl
               do case
                 case eq_any(k,4,5,6,7)
                   mvar := "m1diag_15_"+lstr(i)+"_3"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
                 case eq_any(k,9,10,11,12)
                   mvar := "m1diag_15_"+lstr(i)+"_8"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
                 case k == 14
                   mvar := "m1diag_15_"+lstr(i)+"_13"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
               endcase
             else
               &m1var := -1
             endif
           endif
         next
       next
       for i := 1 to 5
         arr := {}
         for k := 1 to 14
           mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
           if k == 1
             s := alltrim(&mvar)
             if !empty(s) .and. m1diag_15_1 == 0
               if len(s) > 5
                 s := left(s,5)
               endif
               arr := {s,3,1,2,1,2,0}
             else
               exit
             endif
           else
             m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
             do case
               case k == 2 // Диспансерное наблюдение
                 if eq_any(&m1var,1,2)
                   // На текущий момент для 17й учетной формы в разделе "Диагнозы до" (diagnosisBefore) в поле "Диспансерное наблюдение" (dispNablud) доступно к выбору только два значения: 1 - да, 3 - нет.
                   arr[2] := 1 // &m1var
                 endif
               case k == 3
                 fl := (&m1var == 1) // Лечение было назначено
               case k == 4 .and. fl
                 if between(&m1var,0,2)
                   arr[3] := &m1var+1
                 endif
               case k == 5 .and. fl
                 if &m1var == 1
                   arr[4] := 1
                 elseif &m1var == 2
                   arr[4] := 3
                 elseif &m1var == 3
                   arr[4] := 4
                 endif
               case k == 8
                 fl := (&m1var == 1) // Медицинская реабилитация и (или) санаторно-курортное лечение были назначены
               case k == 9 .and. fl
                 if between(&m1var,0,2)
                   arr[5] := &m1var+1
                 endif
               case k == 10 .and. fl
                 if &m1var == 1
                   arr[6] := 1
                 elseif &m1var == 2
                   arr[6] := 3
                 elseif &m1var == 3
                   arr[6] := 4
                 elseif &m1var == 4
                   arr[6] := 5
                 endif
               case k == 13 // ВМП
                 fl := (&m1var == 1)
               case k == 14 .and. fl // ВМП была рекомендована
                 arr[7] := iif(&m1var == 1, 1, 2) // 1-оказана, 2-не оказана
             endcase
           endif
         next
         if len(arr) > 0
           if kol_DiagnosisBefore == 0
             oDiagnosisBefore := oCard:Add( HXMLNode():New( "diagnosisBefore" ) )
           endif
           ++kol_DiagnosisBefore
           aadd(arr_before, {alltrim(arr[1]),arr[2]})
           oDiagnosis := oDiagnosisBefore:Add( HXMLNode():New( "diagnosis" ) )
            mo_add_xml_stroke(oDiagnosis,"mkb",arr[1])
            mo_add_xml_stroke(oDiagnosis,"dispNablud",lstr(arr[2]))
            oLechen := oDiagnosis:Add( HXMLNode():New( "lechen" ) )
             mo_add_xml_stroke(oLechen,"condition",lstr(arr[3]))
             mo_add_xml_stroke(oLechen,"organ",lstr(arr[4]))
             //oNotDone := oLechen:Add( HXMLNode():New( "notDone" ) )
             // mo_add_xml_stroke(oNotDone,"reason",)
             // mo_add_xml_stroke(oNotDone,"reasonOther",)
            oReabil := oDiagnosis:Add( HXMLNode():New( "reabil" ) )
             mo_add_xml_stroke(oReabil,"condition",lstr(arr[5]))
             mo_add_xml_stroke(oReabil,"organ",lstr(arr[6]))
             //oNotDone := oReabil:Add( HXMLNode():New( "notDone" ) )
             // mo_add_xml_stroke(oNotDone,"reason",)
             // mo_add_xml_stroke(oNotDone,"reasonOther",)
            mo_add_xml_stroke(oDiagnosis,"vmp",lstr(arr[7]))
         endif
       next
     endif
     if !(left(mkod_diag,1) == "Z")
       if lvozrast < 14
         MKOD_DIAG := "Z00.1"
       else
         MKOD_DIAG := "Z00.3"
       endif
     endif
     kol_DiagnosisAfter := 0
     if type("m1diag_16_1") == "N" .and. m1diag_16_1 == 0
       for i := 1 to 5
         fl := .f.
         for k := 1 to 16
           mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
           if k == 1
             fl := !empty(&mvar) .and. m1diag_16_1 == 0
           else
             m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
             if fl
               do case
                 case eq_any(k,5,6)
                   mvar := "m1diag_16_"+lstr(i)+"_4"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
                 case eq_any(k,8,9)
                   mvar := "m1diag_16_"+lstr(i)+"_7"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
                 case eq_any(k,11,12)
                   mvar := "m1diag_16_"+lstr(i)+"_10"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
                 case eq_any(k,14,15)
                   mvar := "m1diag_16_"+lstr(i)+"_13"
                   if &mvar != 1 // если не "да"
                     &m1var := -1
                   endif
               endcase
             else
               &m1var := -1
             endif
           endif
         next
       next
       for i := 1 to 5
         arr := {}
         for k := 1 to 16
           mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
           if k == 1
             s := alltrim(&mvar)
             if !empty(s) .and. m1diag_16_1 == 0
               if len(s) > 5
                 s := left(s,5)
               endif
               arr := {s,0,0,1,2,1,2,1,2,0,0,0,0}
             else
               exit
             endif
           else
             m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
             do case
               case k == 2 // Диагноз установлен впервые
                 arr[2] := &m1var
               case k == 3 // Диспансерное наблюдение
                 if eq_any(&m1var,1,2)
                   arr[3] := &m1var
                 endif
               case k == 4
                 fl := (&m1var == 1) // Дополнительные консультации и исследования назначены
               case k == 5 .and. fl
                 if between(&m1var,0,2)
                   arr[8] := &m1var+1
                 endif
               case k == 6 .and. fl
                 if &m1var == 1
                   arr[9] := 1
                 elseif &m1var == 2
                   arr[9] := 3
                 elseif &m1var == 3
                   arr[9] := 4
                 endif
               case k == 7
                 arr[10] := &m1var // Дополнительные консультации и исследования выполнены
               case k == 10
                 fl := (&m1var == 1) // Лечение было назначено
               case k == 11 .and. fl
                 if between(&m1var,0,2)
                   arr[4] := &m1var+1
                 endif
               case k == 12 .and. fl
                 if &m1var == 1
                   arr[5] := 1
                 elseif &m1var == 2
                   arr[5] := 3
                 elseif &m1var == 3
                   arr[5] := 4
                 endif
               case k == 13
                 fl := (&m1var == 1) // Медицинская реабилитация и (или) санаторно-курортное лечение были назначены
               case k == 14 .and. fl
                 if between(&m1var,0,2)
                   arr[6] := &m1var+1
                 endif
               case k == 15 .and. fl
                 if &m1var == 1
                   arr[7] := 1
                 elseif &m1var == 2
                   arr[7] := 3
                 elseif &m1var == 3
                   arr[7] := 4
                 elseif &m1var == 4
                   arr[7] := 5 ; arr[13] := 1
                 endif
               case k == 16 // Высокотехнологичная медицинская помощь была рекомендована
                 arr[11] := iif(&m1var==1,1,0)
             endcase
           endif
         next k
         if len(arr) > 0
           if kol_DiagnosisAfter == 0
             oDiagnosisAfter := oCard:Add( HXMLNode():New( "diagnosisAfter" ) )
           endif
           ++kol_DiagnosisAfter
           if (k := ascan(arr_before, {|x| x[1] == alltrim(arr[1]) })) > 0 // был такой диагноз до осмотра
//my_debug(,print_array(arr_before[k]))
//my_debug(,print_array(arr))
             arr[2] := 0 // выявлен впервые - безусловно поставить "нет"
             if arr_before[k,2] == 1 // Диспансерное наблюдение 1 - было установлено ранее
               arr[3] := 1 // сейчас безусловно установлено ранее
             elseif arr_before[k,2] == 2 // 2 - было установлено впервые
               arr[3] := 1 // сейчас безусловно установлено ранее
             else // 0 - не было установлено
               if arr[3] == 1 // сейчас стоит установлено ранее
                 arr[3] := 2 // меняем на установлено впервые
               endif
             endif
//my_debug(,print_array(arr))
           endif
           oDiagnosis := oDiagnosisAfter:Add( HXMLNode():New( "diagnosis" ) )
            mo_add_xml_stroke(oDiagnosis,"mkb",arr[1])
            mo_add_xml_stroke(oDiagnosis,"firstTime",lstr(arr[2]))
            mo_add_xml_stroke(oDiagnosis,"dispNablud",lstr(arr[3]))
            oLechen := oDiagnosis:Add( HXMLNode():New( "lechen" ) )
             mo_add_xml_stroke(oLechen,"condition",lstr(arr[4]))
             mo_add_xml_stroke(oLechen,"organ",lstr(arr[5]))
            oReabil := oDiagnosis:Add( HXMLNode():New( "reabil" ) )
             mo_add_xml_stroke(oReabil,"condition",lstr(arr[6]))
             mo_add_xml_stroke(oReabil,"organ",lstr(arr[7]))
            oConsul := oDiagnosis:Add( HXMLNode():New( "consul" ) )
             mo_add_xml_stroke(oConsul,"condition",lstr(arr[8]))
             mo_add_xml_stroke(oConsul,"organ"    ,lstr(arr[9]))
             mo_add_xml_stroke(oConsul,"state"    ,lstr(arr[10]))
            mo_add_xml_stroke(oDiagnosis,"needVMP",lstr(arr[11]))
            mo_add_xml_stroke(oDiagnosis,"needSMP",lstr(arr[12]))
            mo_add_xml_stroke(oDiagnosis,"needSKL",lstr(arr[13]))
            mo_add_xml_stroke(oDiagnosis,"recommendNext","Рекомендации")
         endif
       next
     endif
     if kol_DiagnosisAfter == 0
       mo_add_xml_stroke(oCard,"healthyMKB",MKOD_DIAG)
     endif
     if type("m1invalid1") == "N" .and. m1invalid1 == 1
       oInvalid := oCard:Add( HXMLNode():New( "invalid" ) )
        mo_add_xml_stroke(oInvalid,"type",lstr(m1invalid2+1))
        if empty(minvalid3)
          minvalid3 := mdate_r
        endif
        mo_add_xml_stroke(oInvalid,"dateFirstDetected",date2xml(minvalid3))
        if empty(minvalid4)
          minvalid4 := mn_data
        endif
        mo_add_xml_stroke(oInvalid,"dateLastConfirmed",date2xml(minvalid4))
        arr := {}
        do case
          case m1invalid5 ==   1 // некоторые инфекционные и паразитарные,",1},;
            arr := {1}
          case m1invalid5 == 101 //  из них: туберкулез,",101},;
            arr := {1,2}
          case m1invalid5 == 201 //          сифилис,",201},;
            arr := {1,3}
          case m1invalid5 == 301 //          ВИЧ-инфекция;",301},;
            arr := {1,4}
          case m1invalid5 ==   2 // новообразования;",2},;
            arr := {5}
          case m1invalid5 ==   3 // болезни крови, кроветворных органов ...",3},;
            arr := {6}
          case m1invalid5 ==   4 // болезни эндокринной системы ...",4},;
            arr := {10}
          case m1invalid5 == 104 //  из них: сахарный диабет;",104},;
            arr := {10,13}
          case m1invalid5 ==   5 // психические расстройства и расстройства поведения,",5},;
            arr := {14}
          case m1invalid5 == 105 //  в том числе умственная отсталость;",105},;
            arr := {14,15}
          case m1invalid5 ==   6 // болезни нервной системы,",6},;
            arr := {16}
          case m1invalid5 == 106 //  из них: церебральный паралич,",106},;
            arr := {16,17}
          case m1invalid5 == 206 //          другие паралитические синдромы;",206},;
            arr := {16,17}
          case m1invalid5 ==   7 // болезни глаза и его придаточного аппарата;",7},;
            arr := {18}
          case m1invalid5 ==   8 // болезни уха и сосцевидного отростка;",8},;
            arr := {19}
          case m1invalid5 ==   9 // болезни системы кровообращения;",9},;
            arr := {20}
          case m1invalid5 ==  10 // болезни органов дыхания,",10},;
            arr := {21}
          case m1invalid5 == 110 //  из них: астма,",110},;
            arr := {21,22}
          case m1invalid5 == 210 //          астматический статус;",210},;
            arr := {21,23}
          case m1invalid5 ==  11 // болезни органов пищеварения;",11},;
            arr := {24}
          case m1invalid5 ==  12 // болезни кожи и подкожной клетчатки;",12},;
            arr := {25}
          case m1invalid5 ==  13 // болезни костно-мышечной системы и соединительной ткани;",13},;
            arr := {26}
          case m1invalid5 ==  14 // болезни мочеполовой системы;",14},;
            arr := {27}
          case m1invalid5 ==  15 // отдельные состояния, возникающие в перинатальном периоде;",15},;
            arr := {28}
          case m1invalid5 ==  16 // врожденные аномалии,",16},;
            arr := {29}
          case m1invalid5 == 116 //  из них: аномалии нервной системы,",116},;
            arr := {29,30}
          case m1invalid5 == 216 //          аномалии системы кровообращения,",216},;
            arr := {29,31}
          case m1invalid5 == 316 //          аномалии опорно-двигательного аппарата;",316},;
            arr := {29,32}
          case m1invalid5 ==  17 // последствия травм, отравлений и др.",17}}
            arr := {33}
        endcase
        if empty(arr)
          arr := {1}
        endif
        oIllnesses := oInvalid:Add( HXMLNode():New( "illnesses" ) )
        for i := 1 to len(arr) // заболевание по инвалидности
          mo_add_xml_stroke(oIllnesses,"illness",lstr(arr[i]))
        next
        if !between(m1invalid6,1,9) // виды нарушений в состоянии здоровья
          m1invalid6 := 9
        endif
        oDefects := oInvalid:Add( HXMLNode():New( "defects" ) )
         mo_add_xml_stroke(oDefects,"defect",lstr(m1invalid6))
     endif
     arr := {}
     arr1 := {}
     if p_tip_lu == TIP_LU_PN        // профилактика 1 и 2 этап
       arr := f4_inf_DNL_karta(1)
       arr1 := f4_inf_DNL_karta(2)
       if (i := ascan(arr1, {|x| x[5] == 7 })) > 0  // УЗИ сердца
         arr1[i,5] := 20                             // эхокардиография
       endif
     elseif p_tip_lu == TIP_LU_PREDN // пред.осмотры 1 и 2 этап
       arr := f4_inf_PREDN_karta(1)
       arr1 := f4_inf_PREDN_karta(2)
     elseif p_tip_lu == TIP_LU_PERN  // период.осмотры
       arr := f4_inf_PerN_karta(1)
       arr1 := f4_inf_PerN_karta(2)
     else                            // дети-сироты
       arr := f4_inf_DDS_karta(1)
       arr1 := f4_inf_DDS_karta(2)
     endif
     arr := make_unique_arr5(arr)
     arr1 := make_unique_arr5(arr1)
     //if len(arr1) == 0 // искусственно добавим одно исследование до 2018 года
       //aadd(arr1, {"общий анализ мочи", mn_data, "", 1, 2})
     //endif
    if len(arr1) > 0
     oIssled := oCard:Add( HXMLNode():New( "issled" ) )
      oBasic := oIssled:Add( HXMLNode():New( "basic" ) )
      for i := 1 to len(arr1) // исследования
        oRecord := oBasic:Add( HXMLNode():New( "record" ) )
         mo_add_xml_stroke(oRecord,"id",lstr(arr1[i,5]))
         mo_add_xml_stroke(oRecord,"date",date2xml(arr1[i,2]))
         if empty(arr1[i,3])
           arr1[i,3] := "норма"
         endif
         mo_add_xml_stroke(oRecord,"result",arr1[i,3])
      next
    endif
      //oOther := oIssled:Add( HXMLNode():New( "other" ) )
      //цикл oOther // дополнительные исследования
      //  oRecord := oOther:Add( HXMLNode():New( "record" ) )
      //   mo_add_xml_stroke(oRecord,"date",)
      //   mo_add_xml_stroke(oRecord,"name",)
      //   mo_add_xml_stroke(oRecord,"result",)
      //конец цикла oOther
     if !(type("mGRUPPA") == "N") .or. !between(mGRUPPA,1,5)
       mGRUPPA := 1
     endif
     mo_add_xml_stroke(oCard,"healthGroup",lstr(mGRUPPA))
     if type("m1GR_FIZ") == "N" .and. between(m1GR_FIZ,0,4)
       if m1GR_FIZ == 0 ; m1GR_FIZ := 4 ; endif
       if m1GR_FIZ == 5 .and. m1GR_FIZ < mGRUPPA
         --m1GR_FIZ
       endif
       mo_add_xml_stroke(oCard,"fizkultGroup",lstr(m1GR_FIZ))
     endif
     mo_add_xml_stroke(oCard,"zakluchDate",date2xml(mk_data))
     mfio := alltrim(p2->fio) ; s := "" ; k := 0 ; arr1 := {"","",""}
     for i := 1 to numtoken(mfio," .")
       s1 := alltrim(token(mfio," .",i))
       if !empty(s1)
         ++k
         if k < 3
           arr1[k] := s1
         else
           s += s1+" "
         endif
       endif
     next
     arr1[3] := alltrim(s)
     oZakluchVrachName := oCard:Add( HXMLNode():New( "zakluchVrachName" ) )
      mo_add_xml_stroke(oZakluchVrachName,"last",arr1[1])
      mo_add_xml_stroke(oZakluchVrachName,"first",arr1[2])
      mo_add_xml_stroke(oZakluchVrachName,"middle",arr1[3])
     if len(arr) == 0 // искусственно добавим один осмотр
       aadd(arr, {"педиатр", mk_data, "", 1, 1})
     endif
     oOsmotri := oCard:Add( HXMLNode():New( "osmotri" ) )
     for i := 1 to len(arr)
       oRecord := oOsmotri:Add( HXMLNode():New( "record" ) )
        mo_add_xml_stroke(oRecord,"id",lstr(arr[i,5]))
        mo_add_xml_stroke(oRecord,"date",date2xml(arr[i,2]))
     next
     if !(type("mrek_form") == "C") .or. empty(mrek_form)
       mrek_form := "Рекомендации"
     endif
     mo_add_xml_stroke(oCard,"recommendZOZH",mrek_form)
     if type("m1invalid1") == "N" .and. m1invalid1 == 1 .and. !empty(minvalid7)
       oReabilitation := oCard:Add( HXMLNode():New( "reabilitation" ) )
        mo_add_xml_stroke(oReabilitation,"date",date2xml(minvalid7))
        if !between(m1invalid8,1,3)
          m1invalid8 := 4
        endif
        mo_add_xml_stroke(oReabilitation,"state",lstr(m1invalid8))
     endif
     if !(type("m1privivki1") == "N") .or. !between(m1privivki1,0,2)
       m1privivki1 := 0
     endif
     if m1privivki1 == 0
       i := 1
     elseif m1privivki1 == 1
       i := iif(m1privivki2==1, 2, 3)
     else
       i := iif(m1privivki2==1, 4, 5)
     endif
     oPrivivki := oCard:Add( HXMLNode():New( "privivki" ) )
      mo_add_xml_stroke(oPrivivki,"state",lstr(i))
      //oPrivs := oPrivivki:Add( HXMLNode():New( "privs" ) )
      //цикл oPrivs // прививки
      //  mo_add_xml_stroke(oPrivs,"priv",)
      //конец цикла oPrivs
     i := s := 0
     select RPDSH
     find (str(human->kod,7))
     do while rpdsh->KOD_H == human->kod .and. !eof()
       s += rpdsh->S_SL
       skip
     enddo
     if round(mcena_1,2) == round(s,2) // полностью оплачен
       i := 1
     endif
     if emptyall(i,s)
       select RAKSH
       find (str(human->kod,7))
       do while raksh->KOD_H == human->kod .and. !eof()
         if raksh->oplata == 2
           i := 2 ; exit
         endif
         skip
       enddo
     endif
     mo_add_xml_stroke(oCard,"oms",lstr(i))
   //конец цикла oCards
else
  buf := save_maxrow()
  mywait("Ждите! Производится сохранение XML-файла...")
  oXmlDoc:Save(n_file+sxml)
  rest_box(buf)
  n_message({stitle+"- "+lstr(_kol)+" чел.;",;
             "в каталоге "+upper(cur_dir)+" создан файл "+upper(n_file+sxml),;
             "для загрузки на портал Минздрава РФ."},,;
             cColorStMsg,cColorStMsg,,,cColorSt2Msg)
endif
return NIL

***** 25.11.13
Static Function make_unique_arr5(ar)
Local i, ret_arr := {}
for i := 1 to len(ar)
  if ar[i,5] > 0 .and. ascan(ret_arr, {|x| x[5] == ar[i,5] }) == 0
    aadd(ret_arr, ar[i])
  endif
next
return ret_arr

***** 14.11.19 Создание отчётов по иногородним / иностранцам для КЗВО
Function pr_inog_inostr()
Local arr_m, fl_exit := .f., buf := save_maxrow(), kh := 0, jh := 0
if (arr_m := year_month()) == NIL
  return NIL
endif
WaitStatus("ОМС")
dbcreate(cur_dir+"tmp_kart",{{"kod","N",7,0},;
                             {"vozr","N",2,0},;
                             {"vid","N",1,0},;
                             {"profil","N",3,0},;
                             {"region","C",3,0},;
                             {"osnov","N",2,0},;
                             {"kols","N",6,0},;
                             {"ist_fin","N",1,0},;
                             {"summa","N",10,2}})
use (cur_dir+"tmp_kart") new
index on str(kod,7)+str(vid,1)+str(profil,3)+region+str(osnov,2)+str(ist_fin,1) to (cur_dir+"tmp_kart")
//
Private _arr_if := {}, _what_if := _init_if(), _arr_komit := {}
R_Use(dir_exe+"_okator",cur_dir+"_okatr","REGION")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_kinos",dir_server+"mo_kinos","KIS")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",{dir_server+"humand",;
                          dir_server+"humank",;
                          dir_server+"humankk"},"HUMAN")
set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  @ maxrow(),71 say date_8(human->k_data) color "W/R"
  @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
  if jh > 0
    @ row(),col() say "/" color "W/R"
    @ row(),col() say lstr(jh) color cColorStMsg
  endif
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human_->oplata < 9
    lregion := space(3) ; losnov := 0
    if human->CENA_1 > 0 .and. f1pr_inog_inostr(human->kod_k,@lregion,@losnov,arr_m)
      lprofil := human_->profil
      lvid := 2
      do case
        case human_->USL_OK == 1
          lvid := 1
        case human_->USL_OK == 2
          lvid := 4
          /*select HU
          find (str(human->kod,7))
          do while hu->kod == human->kod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
              lshifr := usl->shifr
            endif
            lshifr := alltrim(lshifr)
            if lshifr == "55.1.1" .or. left(lshifr,3) == "63."
              lvid := 1 ; exit
            endif
            select HU
            skip
          enddo*/
        case human_->USL_OK == 3
          lvid := 2
        case human_->USL_OK == 4
          lvid := 3
      endcase
      list_fin := f2pr_inog_inostr(_what_if)
      select TMP_KART
      find (str(human->kod_k,7)+str(lvid,1)+str(lprofil,3)+lregion+str(losnov,2)+str(list_fin,1))
      if !found()
        append blank
        tmp_kart->kod := human->kod_k
        tmp_kart->vid := lvid
        tmp_kart->profil := lprofil
        tmp_kart->region := lregion
        tmp_kart->osnov := losnov
        tmp_kart->ist_fin := list_fin
      endif
      tmp_kart->kols ++
      tmp_kart->vozr := f0pr_inog_inostr(human->date_r,human->n_data)
      tmp_kart->summa += human->CENA_1
      ++jh
    endif
  endif
  select HUMAN
  skip
enddo
if is_task(X_PLATN)
  WaitStatus("Платные услуги")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMP")
  set relation to kod_k into KART
  dbseek(dtos(arr_m[5]),.t.)
  do while hump->k_data <= arr_m[6] .and. !eof()
    @ maxrow(),71 say date_8(hump->k_data) color "W/R"
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    lregion := space(3) ; losnov := 0
    if hump->CENA > 0 .and. f1pr_inog_inostr(hump->kod_k,@lregion,@losnov,arr_m)
      lprofil := 97 // терапии
      lvid := 2     // амбулаторно
      if hump->otd > 0
        otd->(dbGoto(hump->otd))
        if !empty(otd->profil)
          lprofil := otd->profil
        endif
        if otd->IDUMP == 1
          lvid := 1
        endif
      endif
      list_fin := iif(hump->tip_usl == 1, 2, 1)
      select TMP_KART
      find (str(hump->kod_k,7)+str(lvid,1)+str(lprofil,3)+lregion+str(losnov,2)+str(list_fin,1))
      if !found()
        append blank
        tmp_kart->kod := hump->kod_k
        tmp_kart->vid := lvid
        tmp_kart->profil := lprofil
        tmp_kart->region := lregion
        tmp_kart->osnov := losnov
        tmp_kart->ist_fin := list_fin
      endif
      kart->(dbGoto(hump->kod_k))
      tmp_kart->kols ++
      tmp_kart->vozr := f0pr_inog_inostr(kart->date_r,hump->n_data)
      tmp_kart->summa += hump->CENA
      ++jh
    endif
    select HUMP
    skip
  enddo
endif
if is_task(X_ORTO)
  WaitStatus("Ортопедия")
  R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMO")
  set relation to kod_k into KART
  dbseek(dtos(arr_m[5]),.t.)
  do while humo->k_data <= arr_m[6] .and. !eof()
    @ maxrow(),71 say date_8(humo->k_data) color "W/R"
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    lregion := space(3) ; losnov := 0
    if humo->CENA > 0 .and. f1pr_inog_inostr(humo->kod_k,@lregion,@losnov,arr_m)
      lprofil := 88 // стоматологии ортопедической
      lvid := 2     // амбулаторно
      if humo->tip_usl == 1
        list_fin := 4
      elseif humo->tip_usl == 3
        list_fin := 2
      else
        list_fin := 1
      endif
      select TMP_KART
      find (str(humo->kod_k,7)+str(lvid,1)+str(lprofil,3)+lregion+str(losnov,2)+str(list_fin,1))
      if !found()
        append blank
        tmp_kart->kod := humo->kod_k
        tmp_kart->vid := lvid
        tmp_kart->profil := lprofil
        tmp_kart->region := lregion
        tmp_kart->osnov := losnov
        tmp_kart->ist_fin := list_fin
      endif
      kart->(dbGoto(humo->kod_k))
      tmp_kart->kols ++
      tmp_kart->vozr := f0pr_inog_inostr(kart->date_r,humo->n_data)
      tmp_kart->summa += humo->CENA
      ++jh
    endif
    select HUMO
    skip
  enddo
endif
rest_box(buf)
close databases
if jh == 0
  func_error(4,"Не обнаружено информации по иногородним и иностранцам за указанный период")
else
  j := 0
  do while (j := popup_prompt(T_ROW,T_COL-5,j,;
                            {"Приложение ~1 - список иностранцев",;
                             "Приложение ~2 - список иногородних",;
                             "Приложение ~3 - сводная информация по иностранцам",;
                             "Приложение ~4 - сводная информация по иногородним"})) > 0
    f3pr_inog_inostr(j,arr_m)
  enddo
endif
return NIL

***** 12.08.18
Function f0pr_inog_inostr(ldate_r,_data)
Local cy := count_years(ldate_r,_data)
return iif(cy < 100, cy, 99)

***** 06.11.18
Function f1pr_inog_inostr(lkod,/*@*/lregion,/*@*/losnov,arr_m)
Local rec
select KART
goto (lkod)
if !empty(kart_->strana) .and. ascan(glob_O001, {|x| x[2] == kart_->strana }) > 0
  lregion := kart_->strana
  select KIS
  find (str(lkod,7))
  if found()
    losnov := kis->osn_preb
  endif
endif
if lregion == "643"
  lregion := space(3) ; losnov := 0
endif
if empty(lregion) .and. !eq_any(left(kart_->okatog,2),'  ','00','18')
  select REGION
  find (left(kart_->okatog,2))
  if found()
    lregion := left(kart_->okatog,2)+" "
    losnov := -1
  endif
  if !empty(lregion) // иногородний?
    select HUMAN
    rec := recno()
    set order to 3
    find (str(lkod,7))
    do while human->kod_k == lkod .and. !eof()
      if between(human->k_data,arr_m[5],arr_m[6]) .and. human->CENA_1 > 0 .and. human_->oplata < 9
        if human->komu == 0 .and. val(human_->smo) > 34000 .and. val(human_->smo) < 35000 // полис Волгоградский
          lregion := space(3) ; losnov := 0 ; exit                                        // не учитываем
        endif
      endif
      skip
    enddo
    set order to 1
    goto (rec)
  endif
endif
return !empty(lregion)

***** 14.11.19
Function f2pr_inog_inostr(_what_if)
Local list_fin := I_FIN_OMS, _ist_fin, i
if human->komu == 5
  list_fin := I_FIN_PLAT // личный счет = платные услуги
elseif eq_any(human->komu,1,3)
  if (i := ascan(_what_if[2], {|x| x[1]==human->komu .and. x[2]==human->str_crb})) > 0
    list_fin := _what_if[2,i,3]
  endif
endif
// 1-пл.,2-ДМС,3-ОМС,4-бюджет
if list_fin == I_FIN_OMS
  _ist_fin := 3
elseif list_fin == I_FIN_PLAT
  _ist_fin := 1
elseif list_fin == I_FIN_DMS
  _ist_fin := 2
elseif list_fin == I_FIN_LPU
  _ist_fin := 5
else
  _ist_fin := 6
endif
return _ist_fin

***** 14.11.19
Function f3pr_inog_inostr(j,arr_m)
Static sprofil := "терапии"
Static mm_vid := {"Стационарная","Амбулаторная","Экстренная","Дневной стационар"}
Static mm_ist_fin := {"Личные средства гражданина","ДМС","ОМС","средства фед.бюджета","средства МО","средства субъекта РФ"}
Local name_fr := "mo_iipr", buf := save_maxrow()
mywait()
delFRfiles()
dbcreate(fr_titl, {{"name","C",255,0},;
                   {"period","C",255,0}})
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_FULL_NAME]
frt->period := arr_m[4]
dbcreate(fr_data,{;
        {"vid","C",20,0},;
        {"profil","C",255,0},;
        {"region","C",255,0},;
        {"ist_fin","C",30,0},;
        {"osnov","C",50,0},;
        {"fio","C",60,0},;
        {"kol","N",6,0},;
        {"kols","N",6,0},;
        {"vozr","N",2,0},;
        {"summa","N",15,2}})
use (fr_data) new alias FRD
R_Use(dir_exe+"_okator",cur_dir+"_okatr","REGION")
R_Use(dir_server+"kartotek",,"KART")
use (cur_dir+"tmp_kart") new
if j == 1 .or. j == 2
  set relation to kod into KART
  index on upper(kart->fio)+str(vid,1)+str(profil,3)+region+str(osnov,2)+str(ist_fin,1) to (cur_dir+"tmp_kart")
else
  index on region+str(osnov,2)+str(ist_fin,1)+str(vid,1)+str(profil,3) to (cur_dir+"tmp_kart")
endif
if j == 1 .or. j == 2
  select TMP_KART
  go top
  do while !eof()
    if j == 2
      if tmp_kart->osnov < 0
        select FRD
        append blank
        frd->vid := mm_vid[tmp_kart->vid]
        if empty(frd->profil := inieditspr(A__MENUVERT, glob_V002, tmp_kart->PROFIL))
          frd->profil := sprofil
        endif
        frd->ist_fin := mm_ist_fin[tmp_kart->ist_fin]
        select REGION
        find (left(tmp_kart->region,2))
        frd->region := charrem("*",name)
        frd->fio := kart->fio
        frd->kols += tmp_kart->kols
        frd->vozr := tmp_kart->vozr
        frd->summa := tmp_kart->summa
      endif
    else
      if tmp_kart->osnov >= 0
        select FRD
        append blank
        frd->vid := mm_vid[tmp_kart->vid]
        if empty(frd->profil := inieditspr(A__MENUVERT, glob_V002, tmp_kart->PROFIL))
          frd->profil := sprofil
        endif
        frd->ist_fin := mm_ist_fin[tmp_kart->ist_fin]
        frd->region := inieditspr(A__MENUVERT, glob_O001, tmp_kart->region)
        frd->osnov := inieditspr(A__MENUVERT, menu_osn_preb_RF, tmp_kart->osnov)
        frd->fio := kart->fio
        frd->kols += tmp_kart->kols
        frd->vozr := tmp_kart->vozr
        frd->summa := tmp_kart->summa
      endif
    endif
    select TMP_KART
    skip
  enddo
else
  dbcreate(cur_dir+"tmp1",{{"vid","N",1,0},;
                           {"profil","N",3,0},;
                           {"region","C",3,0},;
                           {"osnov","N",2,0},;
                           {"ist_fin","N",1,0},;
                           {"kol","N",6,0},;
                           {"kols","N",6,0},;
                           {"summa","N",15,2}})
  use (cur_dir+"tmp1") new
  index on region+str(osnov,2)+str(ist_fin,1)+str(vid,1)+str(profil,3) to (cur_dir+"tmp1")
  select TMP_KART
  go top
  do while !eof()
    fl := .f.
    if j == 4
      if tmp_kart->osnov < 0
        fl := .t.
      endif
    else
      if tmp_kart->osnov >= 0
        fl := .t.
      endif
    endif
    if fl
      select TMP1
      find (tmp_kart->region+str(tmp_kart->osnov,2)+str(tmp_kart->ist_fin,1)+str(tmp_kart->vid,1)+str(tmp_kart->profil,3))
      if !found()
        append blank
        tmp1->vid := tmp_kart->vid
        tmp1->profil := tmp_kart->profil
        tmp1->region := tmp_kart->region
        tmp1->osnov := tmp_kart->osnov
        tmp1->ist_fin := tmp_kart->ist_fin
      endif
      tmp1->kol ++
      tmp1->kols += tmp_kart->kols
      tmp1->summa += tmp_kart->summa
    endif
    select TMP_KART
    skip
  enddo
  select TMP1
  go top
  do while !eof()
    select FRD
    append blank
    frd->vid := mm_vid[tmp1->vid]
    if empty(frd->profil := inieditspr(A__MENUVERT, glob_V002, tmp1->PROFIL))
      frd->profil := sprofil
    endif
    frd->ist_fin := mm_ist_fin[tmp1->ist_fin]
    if tmp1->osnov < 0
      select REGION
      find (left(tmp1->region,2))
      frd->region := charrem("*",name)
    else
      frd->region := inieditspr(A__MENUVERT, glob_O001, tmp1->region)
      frd->osnov := inieditspr(A__MENUVERT, menu_osn_preb_RF, tmp1->osnov)
    endif
    frd->kols := tmp1->kols
    frd->kol := tmp1->kol
    frd->summa := tmp1->summa
    select TMP1
    skip
  enddo
endif
close databases
rest_box(buf)
call_fr(name_fr+lstr(j))
return NIL
