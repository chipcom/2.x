#include 'function.ch'
#include 'chip_mo.ch'

function init_public()
  local   sbase, file_index


  public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}

  Public arr_12_VMP := {}
  Public is_napr_pol := .f., ; // работа с направлениями на госпитализацию в п-ке
         is_napr_stac := .f., ;  // работа с направлениями на госпитализацию в стационаре
         glob_klin_diagn := {} // работа со специальными лабораторными исследованиями
  Public is_ksg_VMP := .f., is_12_VMP := .f., is_14_VMP := .f., is_ds_VMP := .f.
  Public is_21_VMP := .f.     // ВМП для 21 года
  Public is_22_VMP := .f.     // ВМП для 22 года
  Public is_23_VMP := .f.     // ВМП для 23 года
  
  // справочник цен на услуги ТФОМС 2016-2017
  Public glob_MU_dializ := {}//'A18.05.002.001','A18.05.002.002','A18.05.002.003',;
                            //'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}
  Public glob_KSG_dializ := {}//'10000901','10000902','10000903','10000905','10000906','10000907','10000913',;
                             //'20000912','20000916','20000917','20000918','20000919','20000920'}
                             //'1000901','1000902','1000903','1000905','1000906','1000907','1000913',;
                             //'2000912','2000916','2000917','2000918','2000919','2000920'}
  
  Public is_vr_pr_pp := .f., is_hemodializ := .f., is_per_dializ := .f., is_reabil_slux := .f.,;
         is_ksg_1300098 := .f., is_dop_ob_em := .f., glob_yes_kdp2[10], glob_menu_mz_rf := {.f., .f., .f.}

  Public is_alldializ := .f.

  Public is_MO_VMP := (is_ksg_VMP .or. is_12_VMP .or. is_14_VMP .or. is_ds_VMP .or. is_21_VMP .or. is_22_VMP .or. is_23_VMP)


  afill(glob_yes_kdp2, .f.)

  Public arr_t007 := {}
  sbase := '_mo_t007'
  file_index := cur_dir + sbase + sntx
  R_Use(exe_dir + sbase, file_index, 'T7')
  dbeval({|| aadd(arr_t007, {alltrim(t7->name), t7->profil_k, t7->pk_V020})})
  use

  // справочник страховых компаний РФ
  Public glob_array_srf := {}
  sbase := '_mo_smo'
  file_index := cur_dir + sbase + sntx
  R_Use(exe_dir + sbase, file_index)
  dbeval({|| aadd(glob_array_srf, {'', field->okato})})
  use

  // справочник отделений на конкретный год
  sbase := prefixFileRefName(WORK_YEAR) + 'dep'
  file_index := cur_dir + sbase + sntx
  R_Use(exe_dir + sbase, file_index, 'DEP')
  dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short) + ' (' + alltrim(dep->name) + ')', dep->code, dep->place})})
  if (is_otd_dep := (len(mm_otd_dep) > 0))
    asort(mm_otd_dep, , , {|x, y| x[1] < y[1]})
  endif
  use

  return nil