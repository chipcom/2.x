#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 04.07.23 ввод направлений при подозрении на ЗНО - профосмотры несовершеннолетних
Function fget_napr_ZNO(k, r, c)
  Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
  local strNeedTabNumber := 'Необходимо указать табельный направившего врача'
  local recNumberDoctor := 0
  
  buf := savescreen()
  change_attr() // сделать область экрана "бледной"
  tmp_keys := my_savekey()
  save gets to tmp_list
  //
  use_base('luslf')
  Use_base('mo_su')
  use (cur_dir + 'tmp_onkna') new alias TNAPR
  count_napr := lastrec()
  mNAPR_MO := space(6)
  if cur_napr > 0 .and. cur_napr <= count_napr
    goto (cur_napr) // номер текущего направления
    mNAPR_DATE := tnapr->NAPR_DATE
    mTab_Number := get_tabnom_vrach_by_kod(tnapr->KOD_VR)
    select TNAPR
    m1NAPR_MO := tnapr->NAPR_MO
    if empty(m1NAPR_MO)
      mNAPR_MO := space(60)
    else
      mNAPR_MO := ret_mo(m1NAPR_MO)[_MO_SHORT_NAME]
    endif
    m1NAPR_V := tnapr->NAPR_V
    m1MET_ISSL := tnapr->MET_ISSL
    mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
    mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
    mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
    mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
  else
    cur_napr := 1
    mNAPR_DATE := ctod('')
    mTab_Number := 0
    m1NAPR_MO := space(6)
    mNAPR_MO := space(60)
    m1NAPR_V := 0
    m1MET_ISSL := 0
    mu_kod := 0
    mshifr := space(20)
    mshifr1 := space(20)
    mname_u := space(65)
  endif
  mNAPR_V := inieditspr(A__MENUVERT, mm_napr_v, m1napr_v)
  mMET_ISSL := inieditspr(A__MENUVERT, mm_MET_ISSL, m1MET_ISSL)
  tip_onko_napr := 0
  j := r - 9
  box_shadow(j, 0, j + 9, maxcol() - 2, color1, 'Ввод направлений при подозрении на ЗНО', color8)
  @ ++j, 1 say 'НАПРАВЛЕНИЕ №' get cur_napr pict '99' when .f.
  @ j, col() say '(из' get count_napr pict '99' when .f.
  @ j, col() say ')'
  @ j, 29 say '(<F5> - добавление/редактирование направления №...)' color 'G/B'
  @ ++j, 3 say 'Дата направления' get mNAPR_DATE ;
        valid {|| iif(empty(mNAPR_DATE) .or. between(mNAPR_DATE, mn_data, mk_data), .t., ;
        func_error(4, 'Дата направления должна быть внутри сроков лечения')) }
  @ ++j, 3 say 'Табельный номер направившего врача' get mTab_Number pict '99999' ;
        valid {|g| iif(!v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) }
  @ ++j, 3 say 'В какую МО направлен' get mnapr_mo ;
        reader {|x|menu_reader(x,{{|k, r, c|f_get_mo(k, r, c)}} ,A__FUNCTION, , , .f.)}
  @ ++j, 3 say 'Вид направления' get mnapr_v ;
        reader {|x|menu_reader(x, mm_napr_v, A__MENUVERT, , , .f.)} //; color colget_menu
  @ ++j, 5 say 'Метод диагностического исследования' get mmet_issl ;
        reader {|x|menu_reader(x, mm_met_issl, A__MENUVERT, , , .f.)} ;
        when m1napr_v == 3 //; color colget_menu
  @ ++j, 5 say 'Медицинская услуга' get mshifr pict '@!' ;
        when {|g| m1napr_v == 3 .and. m1MET_ISSL > 0 } ;
        valid {|g|
                Local fl := f5editkusl(g, 2, 2)
                if empty(mshifr)
                  mu_kod  := 0
                  mname_u := space(65)
                  mshifr1 := mshifr
                elseif fl .and. tip_onko_napr > 0 .and. tip_onko_napr != m1MET_ISSL
                  func_error(4, 'Тип медуслуги не соответствует методу диагностического исследования')
                endif
                return fl
              }
  @ ++j, 7 say 'Услуга' get mname_u when .f. color color14
  //
  set key K_F5 TO change_num_napr
  myread()
  set key K_F5

  recNumberDoctor := get_kod_vrach_by_tabnom(mTab_Number)

  close databases
  if !(emptyany(mNAPR_DATE, m1NAPR_V) .and. count_napr == 0)
    if cur_napr == 0
      cur_napr := 1
    endif
    use (cur_dir + 'tmp_onkna') new alias TNAPR
    count_napr := lastrec()
    if cur_napr <= count_napr
      goto (cur_napr) // номер текущего направления
    else
      append blank
    endif
    tnapr->NAPR_DATE := mNAPR_DATE
    tnapr->KOD_VR := recNumberDoctor
    tnapr->NAPR_MO := m1NAPR_MO
    tnapr->NAPR_V := m1NAPR_V
    tnapr->MET_ISSL := iif(m1NAPR_V == 3, m1MET_ISSL, 0)
    tnapr->U_KOD := iif(m1NAPR_V == 3, mu_kod, 0)
    tnapr->shifr_u := iif(m1NAPR_V == 3, mshifr, '')
    tnapr->shifr1 := iif(m1NAPR_V == 3, mshifr1, '')
    tnapr->name_u := iif(m1NAPR_V == 3, mname_u, '')
    cur_napr := recno()
    count_napr := lastrec()
    use
  endif
  setcolor(tmp_color)
  restore gets from tmp_list
  my_restkey(tmp_keys)
  restscreen(buf)
  return {0, 'Количество направлений - ' + lstr(count_napr)}

// 06.09.21 редактировать другое направление (№...)
Function change_num_napr()
  Local r, n, fl := .f., tmp_keys, tmp_gets, buf, tmp_color := setcolor()
  local recNumberDoctor := 0

  if emptyany(mNAPR_DATE, m1NAPR_V)
    func_error(4, 'Ещё не заполнено направление № ' + lstr(cur_napr))
    return .t.
  endif
  tmp_keys := my_savekey()
  save gets to tmp_gets
  buf := savescreen()
  change_attr()
  r := 4
  if (n := input_value(r, 33, r + 2, 77, color5, 'Добавление/редактирование направления №', cur_napr, '99')) == NIL
    // отказ
  elseif eq_any(n, 0, cur_napr)
    // выбрали то же направление, что и редактируется
  else
    if cur_napr == 0
      cur_napr := 1
    endif
    recNumberDoctor := get_kod_vrach_by_tabnom(MTAB_NOM_NAPR) //0

    if select('TNAPR') == 0
      use (cur_dir + 'tmp_onkna') new alias TNAPR
    else
      select TNAPR
    endif
    count_napr := lastrec()
    if cur_napr <= count_napr
      goto (cur_napr) // номер текущего направления
    else
      append blank
    endif
    tnapr->NAPR_DATE := mNAPR_DATE
    tnapr->NAPR_MO := m1NAPR_MO
    tnapr->NAPR_V := m1NAPR_V
    tnapr->MET_ISSL := m1MET_ISSL
    tnapr->U_KOD := mu_kod
    tnapr->shifr_u := mshifr
    tnapr->shifr1 := mshifr1
    tnapr->name_u := mname_u
    tnapr->KOD_VR := recNumberDoctor
    count_napr := lastrec()
    //
    if n <= count_napr
      cur_napr := n
      goto (cur_napr) // номер текущего направления
      mNAPR_DATE := tnapr->NAPR_DATE

      mTab_Number := get_tabnom_vrach_by_kod(tnapr->KOD_VR)

      m1NAPR_MO := tnapr->NAPR_MO
      m1NAPR_V := tnapr->NAPR_V
      m1MET_ISSL := iif(m1napr_v == 3, tnapr->MET_ISSL, 0)
      mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
      mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
      mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
      mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
    else
      cur_napr := count_napr + 1
      mNAPR_DATE := ctod('')
      mTab_Number := 0
      m1NAPR_MO := space(6)
      mNAPR_MO := space(60)
      m1NAPR_V := 0
      m1MET_ISSL := 0
      mu_kod := 0
      mshifr := space(20)
      mshifr1 := space(20)
      mname_u := space(65)
    endif
    mNAPR_V := padr(inieditspr(A__MENUVERT, mm_napr_v, m1napr_v), 30)
    mMET_ISSL := padr(inieditspr(A__MENUVERT, mm_MET_ISSL, m1MET_ISSL), 45)
    tip_onko_napr := 0
  endif
  restscreen(buf)
  restore gets from tmp_gets
  my_restkey(tmp_keys)
  setcolor(tmp_color)
  setcursor()
  return update_gets()
  
// 31.07.21 блок направлений после диспансеризации
function dispans_napr(mk_data, /*@*/j, lAdult)
  // mk_data - дата окончания случая диспансеризации
  // j - счетчик строк на экране
  // lAdult - возможно направление на санаторно-курортное лечение
  // используются PRIVATE-переменные
  local strNeedTabNumber := 'Необходимо указать табельный направившего врача'
  
  Default lAdult TO .f.

  if mk_data >= 0d20210801  // по новому ПУМП
    @ j, 74 say 'Врач'
    @ ++j, 1 say replicate('─', 78) color color1
// направление на дополниельное обследование
    mdopo_na := iif(len(mdopo_na)>0, substr(mdopo_na, 1, 31), '')
    @ ++j, 1 say 'Направлен на дополнительное обследование' get mdopo_na ;
        reader {|x|menu_reader(x, mm_dopo_na, A__MENUBIT, , , .f.)} ;
        valid {|| iif(m1dopo_na == 0, mtab_v_dopo_na := 0, ), update_get('mtab_v_dopo_na')}
    @ j, 73 get mtab_v_dopo_na pict '99999' ;
        valid {|g| iif((mtab_v_dopo_na == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
        when m1dopo_na > 0
// направление в медицинскую организацию
    @ ++j, 1 say 'Направлен' get mnapr_v_mo ;
        reader {|x|menu_reader(x, mm_napr_v_mo, A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1napr_v_mo == 0, (arr_mo_spec := {}, ma_mo_spec := padr('---', 42), mtab_v_mo := 0), ), update_get('ma_mo_spec')}
    ma_mo_spec := iif(len(ma_mo_spec) > 0, substr(ma_mo_spec, 1, 20), '')
    // @ j,col()+1 say 'к специалистам' get ma_mo_spec ;
    //     reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
    //     when m1napr_v_mo > 0
    if lAdult
      @ j, col() + 1 say 'к специалистам' get ma_mo_spec ;
          reader {|x|menu_reader(x, {{|k, r, c| fget_spec_DVN(k, r, c, arr_mo_spec)}}, A__FUNCTION, , , .f.)} ;
          when m1napr_v_mo > 0
    else
      @ j, col() + 1 say 'к специалистам' get ma_mo_spec ;
          reader {|x|menu_reader(x, {{|k, r, c| fget_spec_deti(k, r, c, arr_mo_spec)}}, A__FUNCTION, , , .f.)} ;
          when m1napr_v_mo > 0
    endif
    @ j, 73 get mtab_v_mo pict '99999' ;
        valid {|g| iif((mtab_v_mo == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
        when m1napr_v_mo > 0
// направление в стационар
    @ ++j, 1 say 'Направлен на лечение' get mnapr_stac ;
        reader {|x|menu_reader(x, mm_napr_stac, A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1napr_stac == 0, (m1profil_stac := 0, mtab_v_stac := 0, mprofil_stac := space(32)), ), update_get('mprofil_stac')}
    mprofil_stac := iif(len(mprofil_stac) > 0, substr(mprofil_stac, 1, 27), '')
    @ j, col() + 1 say 'по профилю' get mprofil_stac PICTURE '@S27' ;
        reader {|x|menu_reader(x, getV002(), A__MENUVERT, , , .f.)} ;
        when m1napr_stac > 0
    @ j, 73 get mtab_v_stac pict '99999' ;
        valid {|g| iif((mtab_v_stac == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
        when m1napr_stac > 0
// направлен на реабилитацию
    @ ++j, 1 say 'Направлен на реабилитацию' get mnapr_reab ;
        reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1napr_reab == 0, (m1profil_kojki := 0, mtab_v_reab := 0, mprofil_kojki := space(30)), ), update_get('mprofil_kojki')}
    mprofil_kojki := iif(len(mprofil_kojki) > 0, substr(mprofil_kojki, 1, 25), '')
    @ j, col() + 1 say ', профиль койки' get mprofil_kojki ;
        reader {|x|menu_reader(x, getV020(), A__MENUVERT, , , .f.)} ;
        when m1napr_reab > 0
    @ j, 73 get mtab_v_reab pict '99999' ;
        valid {|g| iif((mtab_v_reab == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
        when m1napr_reab > 0
// направлен на санаторно-курортное лечение
    if lAdult
      @ ++j, 1 say 'Направлен на санаторно-курортное лечение' get msank_na ;
          reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
          valid {|| iif(m1sank_na == 0, mtab_v_sanat := 0, ), update_get('mtab_v_sank')}
      @ j, 73 get mtab_v_sanat pict '99999' ;
          valid {|g| iif((mtab_v_sanat == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
          when (m1sank_na > 0)
    endif
  else  // по старым правилам ПУМП
    @ ++j, 1 say 'Направлен на дополнительное обследование' get mdopo_na ;
        reader {|x|menu_reader(x, mm_dopo_na, A__MENUBIT, , , .f.)}
    @ ++j, 1 say 'Направлен' get mnapr_v_mo ;
        reader {|x|menu_reader(x, mm_napr_v_mo, A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1napr_v_mo == 0, (arr_mo_spec := {}, ma_mo_spec := padr('---', 42)), ), update_get('ma_mo_spec')}
    if lAdult
      @ j, col()+1 say 'к специалистам' get ma_mo_spec ;
          reader {|x|menu_reader(x, {{|k, r, c| fget_spec_DVN(k, r, c, arr_mo_spec)}}, A__FUNCTION, , , .f.)} ;
          when m1napr_v_mo > 0
    else
      @ j, col()+1 say 'к специалистам' get ma_mo_spec ;
          reader {|x|menu_reader(x, {{|k, r, c| fget_spec_deti(k, r, c, arr_mo_spec)}}, A__FUNCTION, , , .f.)} ;
          when m1napr_v_mo > 0
    endif
    @ ++j, 1 say 'Направлен на лечение' get mnapr_stac ;
        reader {|x|menu_reader(x, mm_napr_stac, A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1napr_stac == 0, (m1profil_stac := 0, mprofil_stac := space(32)), ), update_get('mprofil_stac')}
    @ j, col() + 1 say 'по профилю' get mprofil_stac ;
        reader {|x|menu_reader(x, getV002(), A__MENUVERT, , , .f.)} ;
        when m1napr_stac > 0
    @ ++j, 1 say 'Направлен на реабилитацию' get mnapr_reab ;
        reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1napr_reab == 0, (m1profil_kojki := 0, mprofil_kojki := space(30)), ), update_get('mprofil_kojki')}
    @ j, col() + 1 say ', профиль койки' get mprofil_kojki ;
        reader {|x|menu_reader(x, getV020(), A__MENUVERT, , , .f.)} ;
        when m1napr_reab > 0
    if lAdult
      @ ++j, 1 say 'Направлен на санаторно-курортное лечение' get msank_na ;
          reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
    endif
  endif
  return nil

// 27.06.23
function checkTabNumberDoctor(mk_data, lAdult)
  local ret := .t.
  local sBeginMsg := 'Не заполнен табельный номер врача направившего '

  Default lAdult TO .f.

  if mk_data >= 0d20210801
    if (m1dopo_na > 0) .and. (mtab_v_dopo_na == 0)
      func_error(4, sBeginMsg + 'на дополнительное обследование')
      ret := .f.
    endif
    if (m1napr_v_mo > 0) .and. (mtab_v_mo == 0)
      func_error(4, sBeginMsg + 'к специалистам')
      ret := .f.
    endif
    if (m1napr_stac > 0) .and. (mtab_v_stac == 0)
      func_error(4, sBeginMsg + 'на лечение')
      ret := .f.
    endif
    if (m1napr_reab > 0) .and. (mtab_v_reab == 0)
      func_error(4, sBeginMsg + 'на реабилитацию')
      ret := .f.
    endif
    if lAdult .and. (m1sank_na > 0) .and. (mtab_v_sanat == 0)
        func_error(4, sBeginMsg + 'на санаторно-курортное лечение')
        ret := .f.
    endif
  endif
  return ret

// 27.05.22 - возврат структуры временного файла для направлений на онкологию
function create_struct_temporary_onkna()
return { ; // онконаправления
  {'KOD'      , 'N',  7, 0}, ; // код больного
  {'NAPR_DATE', 'D',  8, 0}, ; // Дата направления
  {'NAPR_MO'  , 'C',  6, 0}, ; // код другого МО, куда выписано направление
  {'NAPR_V'   , 'N',  1, 0}, ; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
  {'MET_ISSL' , 'N',  1, 0}, ; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
  {'SHIFR'    , 'C', 20, 0}, ;
  {'SHIFR_U'  , 'C', 20, 0}, ;
  {'SHIFR1'   , 'C', 20, 0}, ;
  {'NAME_U'   , 'C', 65, 0}, ;
  {'U_KOD'    , 'N',  6, 0}, ; // код услуги
  {'KOD_VR'   , 'N',  5, 0} ;  // код врача (справочник mo_pers)
}