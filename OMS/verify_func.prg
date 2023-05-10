#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.05.23
function kol_dney_lecheniya(dBegin, dEnd, usl_ok)

  return dEnd - dBegin + iif(usl_ok == USL_OK_HOSPITAL, 0, 1)

// 25.02.21
// Проверка соответствия результата случая исходу обращения
function checkRSLT_ISHOD(result, ishod, arr)
  // result - код результата обращения
  // ishod - код исхода заболевания
  // arr - массив для сбора ошибок соответствий
  local str1 := 'для указанного результата обращения'
  local str2 := 'исход заболевания не может быть'
  local str3 := 'исход заболевания должен быть'
  local str4 := 'для указанного исхода заболевания'
  local str5 := 'результат обращения должен быть'
  local str := ''
  local strResult := ''
  local i, j

  strResult := getRSLT_V009(result)
  if strResult == NIL
    aadd(arr,'неизвестное значение результата обращения для кода ' + str(result))
    return
  endif

  if eq_any(result, 102, 103, 104, 105, 106, 107, 108, 110) .and. ishod == 101
    str += str1 + ' (' + strResult + ') ' + str2 + ' (' + getISHOD_V012(101) + ')'
    aadd(arr, str)
  endif
  if eq_any(result, 105, 106) .and. ishod != 104
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getISHOD_V012(104) + ')'
    aadd(arr, str)
  endif

  if eq_any(result, 202, 203, 204, 205, 206, 207, 208) .and. ishod == 201
    str += str1 + ' (' + strResult + ') ' + str2 + ' (' + getISHOD_V012(201) + ')'
    aadd(arr, str)
  endif
  if eq_any(result, 205, 206) .and. ishod != 204
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getISHOD_V012(204) + ')'
    aadd(arr, str)
  endif

  if (result == 313) .and. (ishod != 305)
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getISHOD_V012(305) + ')'
    aadd(arr, str)
  endif

  if eq_any(result, 407, 408, 409, 410, 411, 412, 413, 414) .and. ishod != 402
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getISHOD_V012(402) + ')'
    aadd(arr, str)
  endif
  if eq_any(result, 405, 406) .and. ishod != 403
    str += str1 + ' (' + strResult + ') ' + str3 + ' (' + getISHOD_V012(403) + ')'
    aadd(arr, str)
  endif
  return

// 25.03.23
function dublicate_diagnoze(arrDiagnoze)
  local aRet := {}
  local i, cDiagnose
  local aHash := hb_Hash()

  for i := 1 to len(arrDiagnoze)
    cDiagnose := alltrim(arrDiagnoze[i])
    if empty(cDiagnose)
      loop
    endif
    if ! hb_hHaskey( aHash, cDiagnose )
      hb_hSet( aHash, cDiagnose, .t. )
    else
      aadd(aRet, {cDiagnose, iif(i < 9, 'в группе "Сопутствующие диагнозы": ', 'в группе "Диагнозы осложнения": ')})
    endif
  next
  return aRet

// 17.09.21 проверка секции направлений пациента
function checkSectionPrescription( arr )
  local i := 0
  local lAdd := .f.
  local flDopObsledovanie := .f.

  R_Use(dir_server + 'mo_pers',dir_server + 'mo_pers', 'TPERS')

  if (m1dopo_na > 0)
    if (mtab_v_dopo_na == 0)
      lAdd := errorFillPrescription(lAdd, arr, 'не заполнен табельный номер врача направившего на дополнительное обследование')
    else
      lAdd := controlSNILS_Napr(lAdd, arr, 'TPERS', mtab_v_dopo_na, 1)
      for i := 1 to 4
        if isbit(m1dopo_na,i)
          flDopObsledovanie := .t.
          exit
        endif
      next
      if !flDopObsledovanie // не выбраны дополнительные исследования
        lAdd := errorFillPrescription(lAdd, arr, 'в направлении не выбрано ни одного дополнительного обследования')
      endif
    endif
  endif

  if (m1napr_v_mo > 0)
    if (mtab_v_mo == 0)
      lAdd := errorFillPrescription(lAdd, arr, 'не заполнен табельный номер врача направившего к специалистам')
    else
      lAdd := controlSNILS_Napr(lAdd, arr, 'TPERS', mtab_v_mo, 2)
      if empty(arr_mo_spec)
        lAdd := errorFillPrescription(lAdd, arr, 'в направлении к специалистам не выбраны специальности')
      endif
    endif
  endif

  if (m1napr_stac > 0)
    if (mtab_v_stac == 0)
      lAdd := errorFillPrescription(lAdd, arr, 'не заполнен табельный номер врача направившего на лечение')
    else
      lAdd := controlSNILS_Napr(lAdd, arr, 'TPERS', mtab_v_stac, 3)
      if !(m1profil_stac > 0)
        lAdd := errorFillPrescription(lAdd, arr, 'в направлении на лечение не выбран профиль')
      endif
    endif
  endif

  if (m1napr_reab > 0)
    if (mtab_v_reab == 0)
      lAdd := errorFillPrescription(lAdd, arr, 'не заполнен табельный номер врача направившего на реабилитацию')
    else
      lAdd := controlSNILS_Napr(lAdd, arr, 'TPERS', mtab_v_reab, 4)
      if !(m1profil_kojki > 0)
        lAdd := errorFillPrescription(lAdd, arr, 'в направлении на реабилитацию не выбран профиль')
      endif
    endif
  endif

  if (human->VZROS_REB == 0) .and. (m1sank_na > 0)
    if (mtab_v_sanat == 0)
      lAdd := errorFillPrescription(lAdd, arr, 'не заполнен табельный номер врача направившего на санаторно-курортное лечение')
    else
      lAdd := controlSNILS_Napr(lAdd, arr, 'TPERS', mtab_v_sanat, 5)
    endif
  endif
  TPERS->(dbCloseArea())
  return nil

// 03.09.21
function errorFillPrescription(lAdd, arr, strError)
  local strNapr := 'ПОДРАЗДЕЛ НАПРАВЛЕНИЙ:'
  local fl := lAdd

  default strError to 'ОШИБКА В ЗАПОЛНЕНИИ'
  if !fl
    aadd(arr,strNapr)
    fl := .t.
  endif
  aadd(arr,strError)
  return fl

// 17.09.21
function controlSNILS_Napr(lAdd, arr, cAlias, nTabNumber, type)
  local fl := lAdd
  local strError := ''
  local endError := ''

  default type to 0
  if (cAlias)->(dbSeek(str(nTabNumber, 5)))
    endError := fam_i_o((cAlias)->FIO) + ' [' + lstr((cAlias)->tab_nom) + ']' + ' не введен СНИЛС'

    if type == 1
      strError := 'у направившего на дополнительное обследование врача ' + endError
    elseif type == 2
      strError := 'у направившего к специалистам врача ' + endError
    elseif type == 3
      strError := 'у направившего на лечение врача ' + endError
    elseif type == 4
      strError := 'у направившего на реабилитацию врача ' + endError
    elseif type == 5
      strError := 'у направившего на санаторно-куротное лечение врача ' + endError
    endif

    if empty((cAlias)->SNILS)
      fl := errorFillPrescription(fl, arr, strError)
    endif
  else
    fl := errorFillPrescription(fl, arr, 'не найден врач с табельным номером: ' + lstr(nTabNumber))
  endif
  return fl

// 17.09.21
// добавляет код врача (номер записи в БД) в массив с проверкой, что еще отсутствует
function addKodDoctorToArray(arr, nCode)

  if ascan(arr,nCode) == 0
    aadd(arr,nCode)
  endif
  return arr

//
function valid_number_talon(g, dEnd, lMessage)
  local strCheck, ret := .f.

  if dEnd < 0d20220101
    return .t.
  endif

  if valtype(g) == 'O'
    strCheck := alltrim(g:buffer)
  elseif valtype(g) == 'C'
    strCheck := alltrim(g)
  else
    return ret
  endif
  // В соответствии с приказом Минздрава России от 30.01.2015 № 29н
  if !(ret := hb_Regexlike( '([0-9]{2,}[.][0-9]{4,}[.][0-9]{5,}[.][0-9]{3,})', strCheck, .f.))
    if lMessage
      func_error(4, 'Неверный номер талона (шаблон 99.9999.99999.999)')
      // g:buffer := g:original
    endif
  endif
  return ret