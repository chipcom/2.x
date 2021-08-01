#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

****** 31.07.21 блок направлений после диспансеризации
function dispans_napr(mk_data, /*@*/j, lSanat)
  // mk_data - дата окончания случая диспансеризации
  // j - счетчик строк на экране
  // lSanat - возможно направление на санаторно-курортное лечение
  // используются PRIVATE-переменные

  local strNeedTabNumber := 'Необходимо указать табельный направившего врача'
  Default lSanat TO .f.

  if mk_data >= 0d20210801  // по новому ПУМП
    @ j, 74 say "Врач"
    @ ++j, 1 say replicate("─",78) color color1
// направление на дополниельное обследование
    mdopo_na := iif(len(mdopo_na)>0,substr(mdopo_na,1,31),'')
    @ ++j,1 say "Направлен на дополнительное обследование" get mdopo_na ;
        reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)} ;
        valid {|| iif(m1dopo_na==0, mtab_v_dopo_na := 0, ), update_get("mtab_v_dopo_na")}
    @ j,73 get mtab_v_dopo_na pict "99999" ;
        valid {|g| iif((mtab_v_dopo_na == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1dopo_na > 0
// направление в медицинскую организацию
    @ ++j,1 say "Направлен" get mnapr_v_mo ;
        reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42),mtab_v_mo:=0), ), update_get("ma_mo_spec")}
    ma_mo_spec := iif(len(ma_mo_spec)>0,substr(ma_mo_spec,1,20),'')
    @ j,col()+1 say "к специалистам" get ma_mo_spec ;
        reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
        when m1napr_v_mo > 0
    @ j,73 get mtab_v_mo pict "99999" ;
        valid {|g| iif((mtab_v_mo == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1napr_v_mo > 0
// направление в стационар
    @ ++j,1 say "Направлен на лечение" get mnapr_stac ;
        reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mtab_v_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
    mprofil_stac := iif(len(mprofil_stac)>0,substr(mprofil_stac,1,27),'')
    @ j,col()+1 say "по профилю" get mprofil_stac PICTURE '@S27';
        reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
        when m1napr_stac > 0
    @ j,73 get mtab_v_stac pict "99999" ;
        valid {|g| iif((mtab_v_stac == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1napr_stac > 0
// направлен на реабилитацию
    @ ++j,1 say "Направлен на реабилитацию" get mnapr_reab ;
        reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mtab_v_reab:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
    mprofil_kojki := iif(len(mprofil_kojki)>0,substr(mprofil_kojki,1,25),'')
    @ j,col()+1 say ", профиль койки" get mprofil_kojki ;
        reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
        when m1napr_reab > 0
    @ j,73 get mtab_v_reab pict "99999" ;
        valid {|g| iif((mtab_v_reab == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1napr_reab > 0
// направлен на санаторно-курортное лечение
    if lSanat
      @ ++j,1 say "Направлен на санаторно-курортное лечение" get msank_na ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          valid {|| iif(m1sank_na==0, mtab_v_sanat := 0, ), update_get("mtab_v_sank")}
      @ j,73 get mtab_v_sanat pict "99999" ;
          valid {|g| iif((mtab_v_sanat == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
          when (m1sank_na > 0)
    endif
  else  // по старым правилам ПУМП
    @ ++j,1 say "Направлен на дополнительное обследование" get mdopo_na ;
        reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
    @ ++j,1 say "Направлен" get mnapr_v_mo ;
        reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
    @ j,col()+1 say "к специалистам" get ma_mo_spec ;
        reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
        when m1napr_v_mo > 0
    @ ++j,1 say "Направлен на лечение" get mnapr_stac ;
        reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
    @ j,col()+1 say "по профилю" get mprofil_stac ;
        reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
        when m1napr_stac > 0
    @ ++j,1 say "Направлен на реабилитацию" get mnapr_reab ;
        reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
    @ j,col()+1 say ", профиль койки" get mprofil_kojki ;
        reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
        when m1napr_reab > 0
    if lSanat
      @ ++j,1 say "Направлен на санаторно-курортное лечение" get msank_na ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    endif
  endif
  return nil

****** 31.08.2021
function testingTabNumberDoctor(mk_data)
  local ret := .t.

  if mk_data >= 0d20210801
    if (m1dopo_na > 0) .and. (mtab_v_dopo_na == 0)
      func_error(4,'Не заполнен табельный номер врача направившего на дополнительное обследование')
      ret := .f.
      // loop
    endif
    if (m1napr_v_mo > 0) .and. (mtab_v_mo == 0)
      func_error(4,'Не заполнен табельный номер врача направившего к специалистам')
      ret := .f.
      // loop
    endif
    if (m1napr_stac > 0) .and. (mtab_v_stac == 0)
      func_error(4,'Не заполнен табельный номер врача направившего на лечение')
      ret := .f.
      // loop
    endif
    if (m1napr_reab > 0) .and. (mtab_v_reab == 0)
      func_error(4,'Не заполнен табельный номер врача направившего на реабилитацию')
      ret := .f.
      // loop
    endif
    if (m1sank_na > 0) .and. (mtab_v_sanat == 0)
      func_error(4,'Не заполнен табельный номер врача направившего на санаторно-курортное лечение')
      ret := .f.
      // loop
    endif
  endif
  return ret