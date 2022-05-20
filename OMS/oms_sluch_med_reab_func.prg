#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 20.05.22
function defenition_usluga_med_reab(lkod, vid, shrm)
  Local arr, i, s, lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, fl
  local buf := save_maxrow()
  local shifr_reab

  shifr_reab := type_reabilitacia()[vid, 3][shrm]

  mywait('Добавление услуги')
  R_Use(dir_server + 'mo_uch', , 'UCH')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  Use_base('lusl')
  Use_base('luslc')
  Use_base('uslugi')
  R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                              dir_server + 'uslugi1s'}, 'USL1')
  use_base('human_u') // если понадобится, удалить старую услугу и добавить новую
  R_Use(dir_server + 'mo_su', , 'MOSU')
  R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
  set relation to u_kod into MOSU
  G_Use(dir_server + 'human_2', , 'HUMAN_2')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  G_Use(dir_server + 'human', , 'HUMAN') // перезаписать сумму
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
  // goto (lkod)
  HUMAN->(dbGoto(lkod))
  lyear := year(human->K_DATA)

  lrec := lcena := 0
  dbSelectArea('HU')
  find (str(lkod, 7))
  do while hu->kod == lkod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
      lshifr := usl->shifr
    endif
    if !empty(shifr_reab) .and. alltrim(lshifr) == shifr_reab // уже стоит та же услуга
      lcena := iif(m1vzros_reb == 0, usl->CENA, usl->CENAD)
      if !(round(hu->u_cena,2) == round(lcena,2)) // перезапишем цену
        dbSelectArea('HU')
        G_RLock(forever)
        hu->u_cena := lcena
        hu->stoim := hu->stoim_1 := lcena
        UnLock
      endif
      exit
    endif
    if lyear > 2021
      dbSelectArea('LUSL')
      find (lshifr) // длина lshifr 10 знаков
      if found() .and. (eq_any(left(lshifr, 5), '2.89.')) // стоит другая услуга реабилитации
        lrec := hu->(recno())
        exit
      endif
    endif
    HU->(dbSkip())
    // dbSelectArea('HU')
    // skip
  enddo
  if empty(lcena)
    lu_kod := foundOurUsluga(shifr_reab, human->k_data, human_->profil, human->VZROS_REB, @lcena)
    lcena := round_5(lcena, 0)
    if ! empty(lcena)
      //// if round(arr[4],2) == round(lcena,2) // цена определена правильно
      dbSelectArea('HU')
      if lrec == 0
        Add1Rec(7)
        hu->kod := human->kod
      else
        HU->(dbGoto(lrec))
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
      hu->kol     := hu->kol_1 := 1
      hu->stoim   := hu->stoim_1 := lcena
      dbSelectArea('HU_')
      do while hu_->(lastrec()) < mrec_hu
        hu_->(dbAppend())
      enddo
      HU_->(dbGoto(mrec_hu))
      G_RLock(forever)
      if lrec == 0 .or. !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3, hu_->(recno()))
      endif
      hu_->PROFIL := human_->PROFIL
      hu_->PRVS   := human_->PRVS
      hu_->kod_diag := human->KOD_DIAG
    else
      func_error(4, 'ОШИБКА: для организации услуга ' + alltrim(shifr_reab) + ' не установлена!')
      lcena := 0
    endif
  endif
  if !(round(human->CENA_1, 2) == round(lcena, 2))
    dbSelectArea('HUMAN')
    G_RLock(forever)
    human->CENA := human->CENA_1 := lcena // перезапишем стоимость лечения
    HUMAN->(dbUnlock()) // UnLock
  endif

// return { ars, arerr, alltrim(lksg), lcena, akslp, akiro, s_dializ }

  close databases
  rest_box(buf)
  return nil

** 19.05.22
function type_reabilitacia()
  static ret := {}

  if len(ret) == 0
    aadd(ret, {'заболевания опорно-двигательного аппарата', 1, {'2.89.27', '2.89.28', '2.89.29'}})
    aadd(ret, {'сердечно-сосудистая потология', 2, {'2.89.30', '2.89.31', '2.89.32'}})
    aadd(ret, {'заболевания центральной нервной системы', 3, {'2.89.33', '2.89.34', '2.89.35'}})
    aadd(ret, {'заболевания периферической нервной системы', 4, {'2.89.36', '2.89.37', '2.89.38'}})
    aadd(ret, {'лечении органов дыхания, после COVID-19', 5, {'2.89.39', '2.89.40', '2.89.41'}})
    aadd(ret, {'лечении органов дыхания, после COVID-19, телемедицина', 6, {'2.89.42', '2.89.43', '2.89.44'}})
    aadd(ret, {'лечении органов дыхания', 7, {'2.89.45', '2.89.46', '2.89.47'}})
    aadd(ret, {'онкологическое лечение', 8, {'2.89.48', '2.89.49', '2.89.50'}})
  endif
  return ret

** 18.05.22
function type_shrm_reabilitacia()
  static ret := {}

  if len(ret) == 0
    aadd(ret, {'ШРМ 1', 1})
    aadd(ret, {'ШРМ 2', 2})
    aadd(ret, {'ШРМ 3', 3})
  endif
  return ret

** 19.05.22
function ret_array_med_reab(vid, shrm)
  local arr_uslugi_med_reab := { ;
    { ;   // заболевания опорно-двигательного аппарата
      {'2.6.15',	1,	1,	1,	1,	1,	1}, ;
      {'2.6.13',	0.25,	1,	0.5,	1,	0.55,	1}, ;
      {'2.6.16',	1,	1,	1,	2,	1,	2}, ;
      {'2.6.17',	0.45,	1,	0.5,	1,	0.5,	1}, ;
      {'2.6.14',	0.25,	1,	0.35,	1,	0.45,	1}, ;
      {'2.6.19',	0.45,	1,	0.5,	1,	0.5,	1}, ;
      {'2.6.5',	1,	1,	1,	1,	1,	1}, ;
      {'2.6.6',	0.5,	1,	0.75,	1,	1,	2}, ;
      {'2.6.7',	1,	1,	1,	1,	1,	1}, ;
      {'2.6.8',	0.5,	1,	0.75,	2,	1,	1}, ;
      {'3.4.31',	0.1,	1,	0.15,	1,	0.15,	1}, ;
      {'4.11.136',	1,	1,	1,	1,	1,	1}, ;
      {'4.2.153',	1,	1,	1,	1,	1,	1}, ;
      {'13.1.1',	1,	1,	1,	1,	1,	1}, ;
      {'14.2.3',	0.1,	1,	0.1,	1,	0.1,	1}, ;
      {'7.12.5',	0.2,	1,	0.3,	1,	0.4,	1}, ;
      {'7.12.6',	0.2,	1,	0.3,	1,	0.4,	1}, ;
      {'7.2.2',	0.1,	1,	0.1,	1,	0.2,	1}, ;
      {'20.1.2',	1,	9,	1,	11,	1,	13}, ;
      {'20.2.1',	0.6,	9,	0.75,	11,	0.85,	13}, ;
      {'21.1.2',	0.7,	9,	0.85,	9,	0.85,	11}, ;
      {'19.1.2',	0.3,	9,	0.35,	10,	0.45,	10}, ;
      {'19.1.5',	0.1,	9,	0.2,	9,	0.25,	11}, ;
      {'19.1.36',	0.3,	9,	0.4,	9,	0.45,	11}, ;
      {'19.1.30',	0.2,	9,	0.3,	9,	0.35,	11}, ;
      {'19.1.29',	0.2,	9,	0.5,	9,	0.55,	11}, ;
      {'19.1.33',	0.1,	9,	0.25,	9,	0.35,	11}, ;
      {'19.1.34',	0.1,	9,	0.25,	9,	0.35,	11}, ;
      {'19.1.35',	0.1,	9,	0.25,	9,	0.35,	11}, ;
      {'19.1.9',	0.1,	9,	0.25,	9,	0.35,	11}, ;
      {'19.7.1',	0.2,	9,	0.25,	10,	0.35,	10}, ;
      {'19.1.7',	0.3,	9,	0.35,	10,	0.45,	10}, ;
      {'19.1.6',	0.3,	9,	0.35,	10,	0.45,	10}, ;
      {'19.1.37',	0.3,	9,	0.45,	10,	0.55,	10}, ;
      {'19.3.1',	0.2,	9,	0.45,	10,	0.55,	10}, ;
      {'20.2.4',	0.1,	9,	0.45,	9,	0.45,	11}, ;
      {'22.1.2',	0.1,	9,	0.35,	9,	0.35,	11}, ;
      {'19.1.38',	0.1,	9,	0.35,	9,	0.35,	11}, ;
      {'19.6.1',	0.2,	9,	0.35,	9,	0.35,	11}, ;
      {'19.2.2',	0.1,	5.5,	0.35,	9,	0.35,	11}, ;
      {'19.2.5',	0.25,	7.5,	0.25,	9,	0.35,	11}, ;
      {'19.6.2',	0.35,	7.5,	0.45,	9,	0.45,	11}, ;
      {'19.1.32',	0.35,	7.5,	0.45,	9,	0.45,	11} ;
    } ;
  }

  return nil