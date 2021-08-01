#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

****** 31.07.21 ���� ���ࠢ����� ��᫥ ��ᯠ��ਧ�樨
function dispans_napr(mk_data, /*@*/j, lSanat)
  // mk_data - ��� ����砭�� ���� ��ᯠ��ਧ�樨
  // j - ���稪 ��ப �� �࠭�
  // lSanat - �������� ���ࠢ����� �� ᠭ��୮-����⭮� ��祭��
  // �ᯮ������� PRIVATE-��६����

  local strNeedTabNumber := '����室��� 㪠���� ⠡���� ���ࠢ��襣� ���'
  Default lSanat TO .f.

  if mk_data >= 0d20210801  // �� ������ ����
    @ j, 74 say "���"
    @ ++j, 1 say replicate("�",78) color color1
// ���ࠢ����� �� ���������쭮� ��᫥�������
    mdopo_na := iif(len(mdopo_na)>0,substr(mdopo_na,1,31),'')
    @ ++j,1 say "���ࠢ��� �� �������⥫쭮� ��᫥�������" get mdopo_na ;
        reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)} ;
        valid {|| iif(m1dopo_na==0, mtab_v_dopo_na := 0, ), update_get("mtab_v_dopo_na")}
    @ j,73 get mtab_v_dopo_na pict "99999" ;
        valid {|g| iif((mtab_v_dopo_na == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1dopo_na > 0
// ���ࠢ����� � ����樭��� �࣠������
    @ ++j,1 say "���ࠢ���" get mnapr_v_mo ;
        reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42),mtab_v_mo:=0), ), update_get("ma_mo_spec")}
    ma_mo_spec := iif(len(ma_mo_spec)>0,substr(ma_mo_spec,1,20),'')
    @ j,col()+1 say "� ᯥ樠���⠬" get ma_mo_spec ;
        reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
        when m1napr_v_mo > 0
    @ j,73 get mtab_v_mo pict "99999" ;
        valid {|g| iif((mtab_v_mo == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1napr_v_mo > 0
// ���ࠢ����� � ��樮���
    @ ++j,1 say "���ࠢ��� �� ��祭��" get mnapr_stac ;
        reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mtab_v_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
    mprofil_stac := iif(len(mprofil_stac)>0,substr(mprofil_stac,1,27),'')
    @ j,col()+1 say "�� ��䨫�" get mprofil_stac PICTURE '@S27';
        reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
        when m1napr_stac > 0
    @ j,73 get mtab_v_stac pict "99999" ;
        valid {|g| iif((mtab_v_stac == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1napr_stac > 0
// ���ࠢ��� �� ॠ�������
    @ ++j,1 say "���ࠢ��� �� ॠ�������" get mnapr_reab ;
        reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mtab_v_reab:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
    mprofil_kojki := iif(len(mprofil_kojki)>0,substr(mprofil_kojki,1,25),'')
    @ j,col()+1 say ", ��䨫� �����" get mprofil_kojki ;
        reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
        when m1napr_reab > 0
    @ j,73 get mtab_v_reab pict "99999" ;
        valid {|g| iif((mtab_v_reab == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber),.t.) } ;
        when m1napr_reab > 0
// ���ࠢ��� �� ᠭ��୮-����⭮� ��祭��
    if lSanat
      @ ++j,1 say "���ࠢ��� �� ᠭ��୮-����⭮� ��祭��" get msank_na ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          valid {|| iif(m1sank_na==0, mtab_v_sanat := 0, ), update_get("mtab_v_sank")}
      @ j,73 get mtab_v_sanat pict "99999" ;
          valid {|g| iif((mtab_v_sanat == 0) .and. v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) } ;
          when (m1sank_na > 0)
    endif
  else  // �� ���� �ࠢ���� ����
    @ ++j,1 say "���ࠢ��� �� �������⥫쭮� ��᫥�������" get mdopo_na ;
        reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
    @ ++j,1 say "���ࠢ���" get mnapr_v_mo ;
        reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
    @ j,col()+1 say "� ᯥ樠���⠬" get ma_mo_spec ;
        reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
        when m1napr_v_mo > 0
    @ ++j,1 say "���ࠢ��� �� ��祭��" get mnapr_stac ;
        reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
    @ j,col()+1 say "�� ��䨫�" get mprofil_stac ;
        reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
        when m1napr_stac > 0
    @ ++j,1 say "���ࠢ��� �� ॠ�������" get mnapr_reab ;
        reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
        valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
    @ j,col()+1 say ", ��䨫� �����" get mprofil_kojki ;
        reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
        when m1napr_reab > 0
    if lSanat
      @ ++j,1 say "���ࠢ��� �� ᠭ��୮-����⭮� ��祭��" get msank_na ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    endif
  endif
  return nil

****** 31.08.2021
function testingTabNumberDoctor(mk_data)
  local ret := .t.

  if mk_data >= 0d20210801
    if (m1dopo_na > 0) .and. (mtab_v_dopo_na == 0)
      func_error(4,'�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� �������⥫쭮� ��᫥�������')
      ret := .f.
      // loop
    endif
    if (m1napr_v_mo > 0) .and. (mtab_v_mo == 0)
      func_error(4,'�� �������� ⠡���� ����� ��� ���ࠢ��襣� � ᯥ樠���⠬')
      ret := .f.
      // loop
    endif
    if (m1napr_stac > 0) .and. (mtab_v_stac == 0)
      func_error(4,'�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� ��祭��')
      ret := .f.
      // loop
    endif
    if (m1napr_reab > 0) .and. (mtab_v_reab == 0)
      func_error(4,'�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� ॠ�������')
      ret := .f.
      // loop
    endif
    if (m1sank_na > 0) .and. (mtab_v_sanat == 0)
      func_error(4,'�� �������� ⠡���� ����� ��� ���ࠢ��襣� �� ᠭ��୮-����⭮� ��祭��')
      ret := .f.
      // loop
    endif
  endif
  return ret