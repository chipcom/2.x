** различные функции общего пользования для работы с файлами БД - use_func.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 31.01.17
Function R_Use_base(sBase, lalias)
  return use_base(sBase, lalias, , .t.)

** 29.12.22
function close_use_base(sBase)

  sBase := lower(sBase) // проверим, что алиас открыт и выйдем если нет
  if select(sBase) == 0
    return nil
  endif
  do case
    case sBase == 'lusl'
      if lusl18->(used())
        lusl18->(dbCloseArea())
      endif
      if lusl19->(used())
        lusl19->(dbCloseArea())
      endif
      if lusl20->(used())
        lusl20->(dbCloseArea())
      endif
      if lusl21->(used())
        lusl21->(dbCloseArea())
      endif
      if lusl22->(used())
        lusl22->(dbCloseArea())
      endif
      if lusl->(used())
        lusl->(dbCloseArea())
      endif
    case sBase == 'luslc'
      if luslc18->(used())
        luslc18->(dbCloseArea())
      endif
      if luslc19->(used())
        luslc19->(dbCloseArea())
      endif
      if luslc20->(used())
        luslc20->(dbCloseArea())
      endif
      if luslc21->(used())
        luslc21->(dbCloseArea())
      endif
      if luslc22->(used())
        luslc22->(dbCloseArea())
      endif
      if luslc->(used())
        luslc->(dbCloseArea())
      endif
    case sBase == 'luslf'
      if luslf18->(used())
        luslf18->(dbCloseArea())
      endif
      if luslf19->(used())
        luslf19->(dbCloseArea())
      endif
      if luslf20->(used())
        luslf20->(dbCloseArea())
      endif
      if luslf21->(used())
        luslf21->(dbCloseArea())
      endif
      if luslf22->(used())
        luslf22->(dbCloseArea())
      endif
      if luslf->(used())
        luslf->(dbCloseArea())
      endif
    endcase
  return nil

** 28.02.23
function use_base_new(sBase, vYear)
  local fl := .f., fName, fIndex, fIndex_add

  sBase := lower(sBase)
  do case
    case sBase == 'lusl'
      fName := prefixFileRefName(vYear) + 'usl'
      fIndex := cur_dir + fName + sntx
      if hb_vfExists(exe_dir + fName + sdbf)
        if ! hb_vfExists(fIndex)
          R_Use(exe_dir + fName, , sBase)
          index on shifr to (fIndex)
          (sBase)->(dbCloseArea())
        endif
      else
        return fl
      endif
      fl := R_Use(exe_dir + fName, cur_dir + fName, sBase)
    case sBase == 'luslc'
      fName := prefixFileRefName(vYear) + 'uslc'
      fIndex := cur_dir + fName + sntx
      fIndex_add :=  prefixFileRefName(vYear) + 'uslu'  // 
      if hb_vfExists(exe_dir + fName + sdbf)
        if (! hb_vfExists(fIndex)) .or. (! hb_vfExists(cur_dir + fIndex_add + sntx))
          R_Use(exe_dir + fName, , sBase)
          index on shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + sbase) ;
              for codemo == glob_mo[_MO_KOD_TFOMS]
          index on codemo + shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + index_usl_name) ;
              for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
          (sBase)->(dbCloseArea())
        endif
      else
        return fl
      endif
      fl := R_Use(exe_dir + fName, {fIndex, cur_dir + fIndex_add}, sBase)
    case sBase == 'luslf'
      fName := prefixFileRefName(vYear) + 'uslf'
      fIndex := cur_dir + fName + sntx
      if hb_vfExists(exe_dir + fName + sdbf)
        if ! hb_vfExists(fIndex)
          R_Use(exe_dir + fName, , sBase)
          index on shifr to (cur_dir + fName)
          (sBase)->(dbCloseArea())
        endif
      else
        return fl
      endif
      fl := R_Use(exe_dir + fName, cur_dir + fName, sBase)
  endcase

  return fl

** 02.03.23
Function use_base(sBase, lalias, lExcluUse, lREADONLY)
  static lLUSL18, lLUSL19, lLUSL20, lLUSL21, lLUSL22, lLUSL
  static lLUSL_C18, lLUSL_C19, lLUSL_C20, lLUSL_C21, lLUSL_C22, lLUSL_C
  static lLUSL_F18, lLUSL_F19, lLUSL_F20, lLUSL_F21, lLUSL_F22, lLUSL_F
  Local fl := .t., sind1, sind2
  local fname

  sBase := lower(sBase)
  do case
    case sBase == 'lusl'
      if hb_isnil(lLUSL)
        fName := prefixFileRefName(2023) + 'usl'
        lLUSL := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL22)
        fName := prefixFileRefName(2022) + 'usl'
        lLUSL22 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL21)
        fName := prefixFileRefName(2021) + 'usl'
        lLUSL21 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL20)
        fName := prefixFileRefName(2020) + 'usl'
        lLUSL20 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL19)
        fName := prefixFileRefName(2019) + 'usl'
        lLUSL19 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL18)
        fName := prefixFileRefName(2018) + 'usl'
        lLUSL18 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      // if lLUSL
      //   fl := R_Use(exe_dir + '_mo3usl', cur_dir + '_mo3usl', sBase)
      // endif
      // if lLUSL22
      //   R_Use(exe_dir + '_mo2usl', cur_dir + '_mo2usl', sBase + '22')
      // endif
      // if lLUSL21
      //   R_Use(exe_dir + '_mo1usl', cur_dir + '_mo1usl', sBase + '21')
      // endif
      // if lLUSL20
      //   R_Use(exe_dir + '_mo0usl', cur_dir + '_mo0usl', sBase + '20')
      // endif
      // if lLUSL19
      //   R_Use(exe_dir + '_mo9usl', cur_dir + '_mo9usl', sBase + '19')
      // endif
      // if lLUSL18
      //   R_Use(exe_dir + '_mo8usl', cur_dir + '_mo8usl', sBase + '18')
      // endif
      fl := R_Use(exe_dir + '_mo8usl', cur_dir + '_mo8usl', sBase + '18') .and. ;
        R_Use(exe_dir + '_mo9usl', cur_dir + '_mo9usl', sBase + '19') .and. ;
        R_Use(exe_dir + '_mo0usl', cur_dir + '_mo0usl', sBase + '20') .and. ;
        R_Use(exe_dir + '_mo1usl', cur_dir + '_mo1usl', sBase + '21') .and. ;
        R_Use(exe_dir + '_mo2usl', cur_dir + '_mo2usl', sBase + '22') .and. ;
        R_Use(exe_dir + '_mo3usl', cur_dir + '_mo3usl', sBase)
    case sBase == 'luslc'
      if hb_isnil(lLUSL_C)
        fName := prefixFileRefName(2023) + 'uslc'
        lLUSL_C := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_C22)
        fName := prefixFileRefName(2022) + 'uslc'
        lLUSL_C22 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_C21)
        fName := prefixFileRefName(2021) + 'uslc'
        lLUSL_C21 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_C20)
        fName := prefixFileRefName(2020) + 'uslc'
        lLUSL_C20 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_C19)
        fName := prefixFileRefName(2019) + 'uslc'
        lLUSL_C19 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_C18)
        fName := prefixFileRefName(2018) + 'uslc'
        lLUSL_C18 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      // if lLUSL_C
      //   fl := R_Use(exe_dir + '_mo3uslc', {cur_dir + '_mo3uslc', cur_dir + '_mo3uslu'}, sBase)
      // endif
      // if lLUSL_C22
      //   R_Use(exe_dir + '_mo2uslc', {cur_dir + '_mo2uslc', cur_dir + '_mo2uslu'}, sBase + '22')
      // endif
      // if lLUSL_C21
      //   R_Use(exe_dir + '_mo1uslc', {cur_dir + '_mo1uslc', cur_dir + '_mo1uslu'}, sBase + '21')
      // endif
      // if lLUSL_C20
      //   R_Use(exe_dir + '_mo0uslc', {cur_dir + '_mo0uslc', cur_dir + '_mo0uslu'}, sBase + '20')
      // endif
      // if lLUSL_C19
      //   R_Use(exe_dir + '_mo9uslc', {cur_dir + '_mo9uslc', cur_dir + '_mo9uslu'}, sBase + '19')
      // endif
      // if lLUSL_C18
      //   R_Use(exe_dir + '_mo8uslc', {cur_dir + '_mo8uslc', cur_dir + '_mo8uslu'}', sBase + '18')
      // endif
      fl := R_Use(exe_dir + '_mo8uslc', {cur_dir + '_mo8uslc', cur_dir + '_mo8uslu'}, sBase + '18') .and. ;
        R_Use(exe_dir + '_mo9uslc', {cur_dir + '_mo9uslc', cur_dir + '_mo9uslu'}, sBase + '19') .and. ;
        R_Use(exe_dir + '_mo0uslc', {cur_dir + '_mo0uslc', cur_dir + '_mo0uslu'}, sBase + '20') .and. ;
        R_Use(exe_dir + '_mo1uslc', {cur_dir + '_mo1uslc', cur_dir + '_mo1uslu'}, sBase + '21') .and. ;
        R_Use(exe_dir + '_mo2uslc', {cur_dir + '_mo2uslc', cur_dir + '_mo2uslu'}, sBase + '22') .and. ;
        R_Use(exe_dir + '_mo3uslc', {cur_dir + '_mo3uslc', cur_dir + '_mo3uslu'}, sBase)
    case sBase == 'luslf'
      if hb_isnil(lLUSL_F)
        fName := prefixFileRefName(2023) + 'uslf'
        lLUSL_F := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_F22)
        fName := prefixFileRefName(2022) + 'uslf'
        lLUSL_F22 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_F21)
        fName := prefixFileRefName(2021) + 'uslf'
        lLUSL_F21 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_F20)
        fName := prefixFileRefName(2020) + 'uslf'
        lLUSL_F20 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_F19)
        fName := prefixFileRefName(2019) + 'uslf'
        lLUSL_F19 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      if hb_isnil(lLUSL_F18)
        fName := prefixFileRefName(2018) + 'uslf'
        lLUSL_F18 := hb_vfExists(exe_dir + fName + sdbf)
      endif
      // if lLUSL_F
      //   fl := R_Use(exe_dir + '_mo3uslf', cur_dir + '_mo3uslf', sBase)
      // endif
      // if lLUSL_F22
      //   R_Use(exe_dir + '_mo2uslf', cur_dir + '_mo2uslf', sBase + '22')
      // endif
      // if lLUSL_F21
      //   R_Use(exe_dir + '_mo1uslf', cur_dir + '_mo1uslf', sBase + '21')
      // endif
      // if lLUSL_F20
      //   R_Use(exe_dir + '_mo0uslf', cur_dir + '_mo0uslf', sBase + '20')
      // endif
      // if lLUSL_F19
      //   R_Use(exe_dir + '_mo9uslf', cur_dir + '_mo9uslf', sBase + '19')
      // endif
      // if lLUSL_F18
      //   R_Use(exe_dir + '_mo8uslf', cur_dir + '_mo8uslf', sBase + '18')
      // endif
      fl := R_Use(exe_dir + '_mo8uslf', cur_dir + '_mo8uslf', sBase + '18') .and. ;
        R_Use(exe_dir + '_mo9uslf', cur_dir + '_mo9uslf', sBase + '19') .and. ;
        R_Use(exe_dir + '_mo0uslf', cur_dir + '_mo0uslf', sBase + '20') .and. ;
        R_Use(exe_dir + '_mo1uslf', cur_dir + '_mo1uslf', sBase + '21') .and. ;
        R_Use(exe_dir + '_mo2uslf', cur_dir + '_mo2uslf', sBase + '22') .and. ;
        R_Use(exe_dir + '_mo3uslf', cur_dir + '_mo3uslf', sBase)
    case sBase == 'organiz'
      DEFAULT lalias TO 'ORG'
      fl := G_Use(dir_server + 'organiz', , lalias, , lExcluUse, lREADONLY)
    case sBase == 'komitet'
      if (fl := G_Use(dir_server + 'komitet', , lalias, , lExcluUse, lREADONLY))
        index on str(kod, 2) to (cur_dir + 'tmp_komi')
      endif
    case sBase == 'str_komp'
      if (fl := G_Use(dir_server + 'str_komp', , lalias, , lExcluUse, lREADONLY))
        index on str(kod, 2) to (cur_dir + 'tmp_strk')
      endif
    case sBase == 'mo_pers'
      DEFAULT lalias TO 'P2'
      fl := G_Use(dir_server + 'mo_pers',dir_server + 'mo_pers', lalias, , lExcluUse, lREADONLY)
    case sBase == 'mo_su'
      DEFAULT lalias TO 'MOSU'
      fl := G_Use(dir_server + 'mo_su', {dir_server + 'mo_su', ;
                                    dir_server + 'mo_sush', ;
                                    dir_server + 'mo_sush1'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'uslugi'
      DEFAULT lalias TO 'USL'
      fl := G_Use(dir_server + 'uslugi', {dir_server + 'uslugi', ;
                                    dir_server + 'uslugish', ;
                                    dir_server + 'uslugis1', ;
                                    dir_server + 'uslugisl'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'kartotek'
      fl := G_Use(dir_server + 'kartote_', ,'KART_', , lExcluUse, lREADONLY) .and. ;
          G_Use(dir_server + 'kartote2', ,'KART2', , lExcluUse, lREADONLY) .and. ;
          G_Use(dir_server + 'kartotek', {dir_server + 'kartotek', ;
                                       dir_server + 'kartoten', ;
                                       dir_server + 'kartotep', ;
                                       dir_server + 'kartoteu', ;
                                       dir_server + 'kartotes', ;
                                       dir_server + 'kartotee'},'KART', , lExcluUse, lREADONLY)
      if fl
        set relation to recno() into KART_, to recno() into KART2
      endif
    case sBase == 'human'
      DEFAULT lalias TO 'HUMAN'
      fl := G_Use(dir_server + 'human_', ,'HUMAN_', , lExcluUse, lREADONLY) .and. ;
          G_Use(dir_server + 'human_2', ,'HUMAN_2', , lExcluUse, lREADONLY) .and. ;
          G_Use(dir_server + 'human', {dir_server + 'humank', ;
                                    dir_server + 'humankk', ;
                                    dir_server + 'humann', ;
                                    dir_server + 'humand', ;
                                    dir_server + 'humano', ;
                                    dir_server + 'humans'}, lalias, , lExcluUse, lREADONLY)
      if fl
        set relation to recno() into HUMAN_, to recno() into HUMAN_2
      endif
    case sBase == 'human_im'
      DEFAULT lalias TO 'IMPL'
      fl := G_Use(dir_server + 'human_im', dir_server + 'human_im', lalias, , lExcluUse, lREADONLY)
    case sBase == 'human_u'
      DEFAULT lalias TO 'HU'
      fl := G_Use(dir_server + 'human_u_', ,'HU_', , lExcluUse, lREADONLY) .and. ;
          G_Use(dir_server + 'human_u', {dir_server + 'human_u', ;
                                      dir_server + 'human_uk', ;
                                      dir_server + 'human_ud', ;
                                      dir_server + 'human_uv', ;
                                      dir_server + 'human_ua'}, lalias, , lExcluUse, lREADONLY)
      if fl
        set relation to recno() into HU_
      endif
    case sBase == 'mo_hu'
      DEFAULT lalias TO 'MOHU'
      fl := G_Use(dir_server + 'mo_hu', {dir_server + 'mo_hu', ;
                                    dir_server + 'mo_huk', ;
                                    dir_server + 'mo_hud', ;
                                    dir_server + 'mo_huv', ;
                                    dir_server + 'mo_hua'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'mo_dnab'
      DEFAULT lalias TO 'DN'
      fl := G_Use(dir_server + 'mo_dnab',dir_server + 'mo_dnab', lalias, , lExcluUse, lREADONLY)
    case sBase == 'mo_hdisp'
      DEFAULT lalias TO 'HDISP'
      fl := G_Use(dir_server + 'mo_hdisp',dir_server + 'mo_hdisp', lalias, , lExcluUse, lREADONLY)
    case sBase == 'schet'
      DEFAULT lalias TO 'SCHET'
      fl := G_Use(dir_server + 'schet_', ,'SCHET_', , lExcluUse, lREADONLY) .and. ;
          G_Use(dir_server + 'schet', {dir_server + 'schetk', ;
                                    dir_server + 'schetn', ;
                                    dir_server + 'schetp', ;
                                    dir_server + 'schetd'}, lalias, , lExcluUse, lREADONLY)
      if fl
        set relation to recno() into SCHET_
      endif
    case sBase == 'kartdelz'
      fl := G_Use(dir_server + 'kartdelz',dir_server + 'kartdelz', ,, lExcluUse, lREADONLY)
    case sBase == 'kart_st'
      fl := G_Use(dir_server + 'kart_st', {dir_server + 'kart_st', ;
                                      dir_server + 'kart_st1'}, ,, lExcluUse, lREADONLY)
    case sBase == 'humanst'
      fl := G_Use(dir_server + 'humanst',dir_server + 'humanst', ,, lExcluUse, lREADONLY)
    case sBase == 'mo_pp'
      DEFAULT lalias TO 'HU'
      fl := G_Use(dir_server + 'mo_pp', {dir_server + 'mo_pp_k', ;
                                    dir_server + 'mo_pp_d', ;
                                    dir_server + 'mo_pp_r', ;
                                    dir_server + 'mo_pp_i', ;
                                    dir_server + 'mo_pp_h'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'hum_p'
      DEFAULT lalias TO 'HU'
      fl := G_Use(dir_server + 'hum_p', {dir_server + 'hum_pkk', ;
                                    dir_server + 'hum_pn', ;
                                    dir_server + 'hum_pd', ;
                                    dir_server + 'hum_pv', ;
                                    dir_server + 'hum_pc'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'hum_p_u'
      DEFAULT lalias TO 'HU'
      fl := G_Use(dir_server + 'hum_p_u', {dir_server + 'hum_p_u', ;
                                      dir_server + 'hum_p_uk', ;
                                      dir_server + 'hum_p_ud', ;
                                      dir_server + 'hum_p_uv', ;
                                      dir_server + 'hum_p_ua'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'hum_ort'
      fl := G_Use(dir_server + 'hum_ort', {dir_server + 'hum_ortk', ;
                                      dir_server + 'hum_ortn', ;
                                      dir_server + 'hum_ortd', ;
                                      dir_server + 'hum_orto'},'HUMAN', , lExcluUse, lREADONLY)
    case sBase == 'hum_oru'
      fl := G_Use(dir_server + 'hum_oru', {dir_server + 'hum_oru', ;
                                      dir_server + 'hum_oruk', ;
                                      dir_server + 'hum_orud', ;
                                      dir_server + 'hum_oruv', ;
                                      dir_server + 'hum_orua'},'HU', , lExcluUse, lREADONLY)
    case sBase == 'hum_oro'
      fl := G_Use(dir_server + 'hum_oro', {dir_server + 'hum_oro', ;
                                      dir_server + 'hum_orov', ;
                                      dir_server + 'hum_orod'},'HO', , lExcluUse, lREADONLY)
    case sBase == 'kas_pl'
      fl := G_Use(dir_server + 'kas_pl', {dir_server + 'kas_pl1', ;
                                     dir_server + 'kas_pl2', ;
                                     dir_server + 'kas_pl3'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'kas_pl_u'
      fl := G_Use(dir_server + 'kas_pl_u', {dir_server + 'kas_pl1u', ;
                                       dir_server + 'kas_pl2u'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'kas_ort'
      fl := G_Use(dir_server + 'kas_ort', {dir_server + 'kas_ort1', ;
                                      dir_server + 'kas_ort2', ;
                                      dir_server + 'kas_ort3', ;
                                      dir_server + 'kas_ort4', ;
                                      dir_server + 'kas_ort5'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'kas_ortu'
      fl := G_Use(dir_server + 'kas_ortu', {dir_server + 'kas_or1u', ;
                                       dir_server + 'kas_or2u'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'mo_kekh'
      DEFAULT lalias TO 'HU'
      fl := G_Use(dir_server + 'mo_kekh',dir_server + 'mo_kekh', lalias, , lExcluUse, lREADONLY)
    case sBase == 'mo_keke'
      DEFAULT lalias TO 'EKS'
      fl := G_Use(dir_server + 'mo_keke', {dir_server + 'mo_keket', ;
                                      dir_server + 'mo_kekee', ;
                                      dir_server + 'mo_keked'}, lalias, , lExcluUse, lREADONLY)
    case sBase == 'mo_kekez'
      DEFAULT lalias TO 'EKSZ'
      fl := G_Use(dir_server + 'mo_kekez',dir_server + 'mo_kekez', lalias, , lExcluUse, lREADONLY)
    case sBase == 'lusld'
      fl := R_Use(exe_dir+'_mo_usld',cur_dir + '_mo_usld',sBase)
  endcase
  return fl

**
Function useUch_Usl()
  return G_Use(dir_server + 'uch_usl', dir_server + 'uch_usl', 'UU') .and. ;
      G_Use(dir_server + 'uch_usl1', dir_server + 'uch_usl1', 'UU1')


** 21.01.19 проверить, заблокирована ли запись, и, если нет, то заблокировать её
Function my_Rec_Lock(n)
  if ascan(dbRLockList(), n) == 0
    G_RLock(forever)
  endif
  return NIL
  
** вернуть в массиве запись базы данных
Function get_field()
  Local arr := array(fcount())
  aeval(arr, {|x, i| arr[i] := fieldget(i) }  )
  return arr
  

** 04.04.18 блокировать запись, где поле KOD == 0 (иначе добавить запись)
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
  if fl  // добавление записи
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
  SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
  return NIL

** 11.04.18 выравнивание вторичного файла базы данных до первичного
Function dbf_equalization(lalias, lkod)
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
  if fl  // т.е. нужная запись не заблокирована при добавлении
    goto (lkod)
    G_RLock(forever)
  endif
  return NIL

