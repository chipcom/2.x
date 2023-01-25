***** mo_func1.prg
#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 18.03.13 �ਧ��� ᥫ�
Function f_is_selo(_gorod_selo,_okatog)
Local arr, ret := .f., fl := .f., tmp_select
DEFAULT _gorod_selo TO kart_->gorod_selo, _okatog TO kart_->okatog
if _gorod_selo == 2 // �� ����⥪�
  fl := .t.  // ��諨
  ret := .t.   // ᥫ�
endif
if !fl .and. !empty(okato_rajon(_okatog,@arr))
  if arr[5] == 1 // ��த
    fl := .t.  // ��諨
    ret := .f.   // ��த
  endif
endif
if !fl
  tmp_select := select()
  R_Use(dir_exe+"_okatos",cur_dir+"_okats","SELO")
  find (padr(_okatog,11,'0'))
  if found()
    fl := .t.  // ��諨
    ret := (selo->selo == 0)
  endif
  use
  if !fl
    R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OBLAST")
    find (padr(_okatog,5,'0'))
    if found()
      fl := .t.  // ��諨
      ret := (oblast->selo == 0)
    endif
    use
  endif
  select (tmp_select)
endif
if !fl
endif
return ret

***** ������ ��த/�������/�����த���
Function okato_mi_git(_okato)
Local s := ""
if !empty(_okato)
  if left(_okato,5) == "18401"
    s := "�.������ࠤ"
  elseif left(_okato,2) == "18"
    s := "������ࠤ᪠� ���."
  else
    s := "�����த���"
  endif
endif
return s

***** ������ ࠩ�� �� �����
Function okato_rajon(tokato,/*@*/ret_arr)
Static arr_rajon := {;
  {"���訫��᪨�"    ,0 ,11, "18401363",1},;
  {"���ন�᪨�"      ,0 ,12, "18401365",1},;
  {"��஢᪨�"        ,0 ,13, "18401370",1},;
  {"��᭮�ଥ�᪨�"  ,0 ,14, "18401375",1},;
  {"��᭮������᪨�",0 ,15, "18401380",1},;
  {"�����᪨�"        ,0 ,16, "18401385",1},;
  {"�ࠪ�஧����᪮�",0 ,17, "18401390",1},;
  {"����ࠫ��"      ,0 ,18, "18401395",1},;
  {"�.����設"        ,1 ,21, "18415000",1},;
  {"�.��堩�����"     ,1 ,22, "18420000",1},;
  {"�.����"       ,1 ,23, "18425000",1},;
  {"�.�஫���"        ,1 ,24, "18428000",1},;
  {"�.����᪨�"       ,1 ,25, "18410000",1},;
  {"����ᥥ�᪨�"     ,1 ,30, "18202000",2},;
  {"�몮�᪨�"        ,1 ,31, "18204000",2},;
  {"��த�饭᪨�"    ,1 ,32, "18205000",2},;
  {"�������᪨�"      ,1 ,33, "18206000",2},;
  {"�㡮�᪨�"        ,1 ,34, "18208000",2},;
  {"����᪨�"         ,1 ,35, "18210000",2},;
  {"��୮�᪨�"       ,1 ,36, "18212000",2},;
  {"�������᪨�"      ,1 ,37, "18214000",2},;
  {"����祢᪨�"      ,1 ,38, "18216000",2},;
  {"����設᪨�"      ,1 ,39, "18218000",2},;
  {"���������᪨�"    ,1 ,40, "18220000",2},;
  {"����᪨�"         ,1 ,41, "18222000",2},;
  {"��⥫쭨���᪨�"  ,1 ,42, "18224000",2},;
  {"��⮢᪨�"        ,1 ,43, "18226000",2},;
  {"�����᪨�"        ,1 ,44, "18230000",2},;
  {"��堩���᪨�"     ,1 ,45, "18232000",2},;
  {"��堥�᪨�"       ,1 ,46, "18234000",2},;
  {"��������᪨�"     ,1 ,47, "18236000",2},;
  {"���������᪨�"    ,1 ,48, "18238000",2},;
  {"������������᪨�" ,1 ,49, "18240000",2},;
  {"������᪨�"      ,1 ,50, "18242000",2},;
  {"���客᪨�"       ,1 ,51, "18243000",2},;
  {"�����ᮢ᪨�"     ,1 ,52, "18245000",2},;
  {"��뫦��᪨�"     ,1 ,53, "18246000",2},;
  {"�㤭�᪨�"       ,1 ,54, "18247000",2},;
  {"���⫮��᪨�"     ,1 ,55, "18249000",2},;
  {"���䨬����᪨�" ,1 ,56, "18250000",2},;
  {"�।�����㡨�᪨�",1 ,57, "18251000",2},;
  {"��ய��⠢᪨�"  ,1 ,58, "18252000",2},;
  {"��஢����᪨�"    ,1 ,59, "18253000",2},;
  {"���᪨�"       ,1 ,60, "18254000",2},;
  {"�஫��᪨�"       ,1 ,61, "18256000",2},;
  {"����誮�᪨�"    ,1 ,62, "18258000",2};
 }
Local t1okato := padr(tokato,8), vozvr := "", t1
// ᭠砫� ���� �� ࠩ��� �.������ࠤ�
if (t1 := ascan(arr_rajon,{|x| padr(x[4],8) == t1okato})) > 0
  vozvr := arr_rajon[t1,1]
  ret_arr := arr_rajon[t1]
else // ⥯��� �� ࠩ��� ������
  t1okato := padr(tokato,5)
  if (t1 := ascan(arr_rajon,{|x| padr(x[4],5) == t1okato})) > 0
    vozvr := arr_rajon[t1,1]
    ret_arr := arr_rajon[t1]
  endif
endif
return vozvr

***** 16.01.19 ����室��� �� �뢥�� �ࠪ�� ����������� � ॥���
Function need_reestr_c_zab(lUSL_OK,osn_diag)
Local fl := .f.
if lUSL_OK < 4
  if lUSL_OK == 3 .and. !(left(osn_diag,1) == "Z")
    fl := .t. // �᫮��� �������� <���㫠�୮> (USL_OK=3) � �᭮���� ������� �� �� ��㯯� Z00-Z99
  elseif is_oncology == 2
    fl := .t. // �� ��⠭�������� ���
  endif
endif
return fl

***** ࠡ�⠥� ��� �� ���� ��०����� � ⠫����
Function ret_is_talon()
Local is_talon := .f., tmp_select := select()
R_Use(dir_server+"mo_uch",,"_UCH")
go top
do while !eof()
  if between_date(_uch->dbegin,_uch->dend,sys_date) .and. _uch->IS_TALON == 1
    is_talon := .t. ; exit
  endif
  skip
enddo
_uch->(dbCloseArea())
select (tmp_select)
return is_talon

***** ���� ��� ��㣨
Function valid_shifr()
Private tmp := readvar()
&tmp := transform_shifr(&tmp)
return .t.

***** 15.01.19 �࠭��ନ஢���� ��� ��㣨 (������� �� ���, ���.��� ����)
Function transform_shifr(s)
Local n := len(s)  // ����� ���� ����� ���� 10 ��� 15 ᨬ�����
s := DelEndSymb(charrepl(",",s,"."),".") // ������� - �� ��� � 㤠���� ��᫥���� ���
// ������ �㪢� �,�
if eq_any(left(s,1),"�","�") .and. substr(s,4,1) == "." ;
               .and. EMPTY(CHARREPL("0123456789", substr(s,2,2), SPACE(10)))
  s := iif(left(s,1)=="�","A","B")+substr(s,2)  // ������� �� ��������� A,B
elseif eq_any(upper(left(s,2)),"ST","DS")
  s := lower(s)
endif
return padr(s,n)

***** 28.05.19 㤠���� �� ᯥ�ᨬ���� �� ��ப� � ��⠢��� �� ������ �஡���
Function del_spec_symbol(s)
Local i, c, s1 := ""
for i := 1 to len(s)
  c := substr(s,i,1)
  if asc(c) == 255 ; c := " " ; endif // ���塞 �� �஡��
  if asc(c) >= 32
    s1 += c
  endif
next
return charone(" ",s1)

***** ����⠢��� ���।� ��ப� �����-� ���-�� �஡����
Function st_nom_stroke(lstroke)
Local i, r := 0
lstroke := alltrim(lstroke)
for i := 1 to len(lstroke)
  if "." == substr(lstroke,i,1)
    ++r
  endif
next
if r == 1 .and. right(lstroke,2) == ".0"
  r := 0
endif
return space(r*2)

*****
Function a2default(arr,name,sDefault)
// arr - ��㬥�� ���ᨢ
// name - ���� �� ����� ��ࢮ�� �������
// sDefault - ���祭�� �� 㬮�砭�� ��� ��ண� �������
Local s := "", i
if valtype(sDefault) == "C"
  s := sDefault
endif
if (i := ascan(arr, {|x| upper(x[1]) == upper(name)})) > 0
  s := arr[i,2]
endif
return s

*****
Function uk_arr_dni(nKey)
Local buf := savescreen(), arr, d, mtitle, ldate := tmp->date_u1 + 1,;
      tmp_color := setcolor(), arr1, r
if eq_any(nkey,K_F4,K_F5)
  mtitle := "����஢���� ��㣨 "+alltrim(tmp->shifr_u)+" �� "+date_8(tmp->date_u1)+"�."
else
  mtitle := "����஢���� ��� ���, ��������� "+date_8(tmp->date_u1)+"�."
endif
setcolor(color0+",,,N/W")
if nKey == K_F4
  if ldate > human->k_data
    ldate := human->k_data
  endif
  box_shadow(18,5,21,74,color0)
  @ 19,6 say padc(mtitle,68)
  @ 20,18 say "������, ���� ��� ����� ��㣨" get ldate ;
            valid {|| between(ldate,human->n_data,human->k_data) }
  myread()
  if lastkey() != K_ESC
    arr := {{date_8(ldate),ldate}}
  endif
else
  Private mdni := 1, mdate := human->k_data
  if ldate < mdate
    mdni := mdate - ldate + 1
  endif
  box_shadow(18,5,21,74,color0,mtitle,"B/BG")
  status_key("^<Esc>^ - �⪠�;  ^<PgDn>^ - ����஢��� ��ப�")
  do while .t.
    @ 19,9 say "������, ᪮�쪮 �� ����� ����室��� ᤥ����" get mdni pict "99" ;
            valid {|| mdate := ldate + mdni - 1, .t. }
    @ 20,9 say "������, �� ����� ���� (�����⥫쭮) ����஢���" get mdate ;
            valid {|| mdni := mdate - ldate + 1, .t. }
    myread()
    if lastkey() == K_ESC
      exit
    elseif lastkey() == K_PGDN
      if mdate >= ldate
        arr1 := {}
        for d := ldate to mdate
          aadd(arr1, {date_8(d),d})
        next
        if (r := 21 - len(arr1)) < 2
          r := 2
        endif
        arr := bit_popup(r,63,arr1,,color5)
      endif
      exit
    endif
  enddo
endif
restscreen(buf)
setcolor(tmp_color)
return arr

*****
Function put_otch_period(full_year)
Local n := 5, s := strzero(schet_->nyear,4)
DEFAULT full_year TO .f.
if full_year
  n += 2
else
  s := right(s,2)
endif
s += "/"+strzero(schet_->nmonth,2)
if emptyany(schet_->nyear,schet_->nmonth)
  s := space(n)
endif
return s

***** ������ ���� ॣ����樨 ����
Function date_reg_schet()
// �᫨ ��� ���� ॣ����樨, ���� ���� ����
return iif(empty(schet_->dregistr), schet_->dschet, schet_->dregistr)

***** 23.11.21
Function ret_vid_pom(k,mshifr,lk_data)
  local svp, vp := 0, lal := 'lusl'
  local y := WORK_YEAR

  if valtype(lk_data) == 'D'
    y := year(lk_data)
  endif

  if select('LUSL') == 0
    Use_base('lusl')
  endif
  lal := create_name_alias(lal, y)

  dbSelectArea(lal)
  find (padr(mshifr, 10))
  if found()
    svp := alltrim(&lal.->VMP_F)
    if empty(svp)
      vp := 0
    elseif k == 1
      vp := int(val(svp))
    else
      vp := 1
      if svp == '2'
        vp := 2
      elseif '3' $ svp
        vp := 3
      endif
    endif
  endif
  return vp

*****
Function get_k_usluga(lshifr,lvzros_reb,lvr_as)
Local i, buf := save_maxrow(), lu_cena, lis_nul, v, fl, arr_k_usl := {}, fl_oms
mywait()
lshifr := padr(lshifr,10)
lvr_as := .f.
pr_k_usl := {}
if !is_open_u1
  G_Use(dir_server+"uslugi1k",dir_server+"uslugi1k","U1K")
  G_Use(dir_server+"uslugi_k",dir_server+"uslugi_k","UK")
  is_open_u1 := .t.
endif
select UK
find (lshifr)
if found()
  select U1K
  find (uk->shifr)
  do while u1k->shifr == uk->shifr .and. !eof()
    aadd(arr_k_usl,{u1k->shifr1,;
                    .f.,;  // 2 �� �� ���४⭮ ?
                    0,;    // 3 ��� ��㣨
                    "",;   // 4 ������������ ��㣨
                    0,;    // 5 業�
                    0,;    // 6 �����樥��
                    0,;    // 7 %% ��������� 業�
                    "",;   // 8 shifr1
                    .f.,;  // 9 is_nul
                    .f.})  //10 is_oms
    skip
  enddo
  for i := 1 to len(arr_k_usl)
    fl := .f. ; fl_oms := .f.
    select USL
    set order to 1
    find (arr_k_usl[i,1])
    if found()
      fl := .t. ; lu_cena := 0
      if glob_task == X_PLATN  // ��� ������ ���
        lu_cena := if(lvzros_reb==0, usl->pcena, usl->pcena_d)
        if human->tip_usl==PU_D_SMO .and. usl->dms_cena > 0
          lu_cena := usl->dms_cena
        endif
        lis_nul := usl->is_nulp
      elseif glob_task == X_KASSA  // ��� lpukassa.exe
        v := CenaUslDate(human->k_data,usl->kod)
        lu_cena := if(lvzros_reb==0, v[1], v[2])
        lis_nul := .f.
      else  // ��� ��� ���
        lu_cena := if(lvzros_reb==0, usl->cena, usl->cena_d)
        if (v := f1cena_oms(usl->shifr,;
                            opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data),;
                            (lvzros_reb==0),;
                            human->k_data,;
                            usl->is_nul,;
                            @fl_oms)) != NIL
          lu_cena := v
        endif
        lis_nul := usl->is_nul
      endif
      if empty(lu_cena) .and. !lis_nul
        fl := func_error(1,"� ��㣥 "+alltrim(arr_k_usl[i,1])+" �� ���⠢���� 業�!")
      else
        select UO
        find (str(usl->kod,4))
        if found() .and. glob_task != X_KASSA .and. !(chr(m1otd) $ uo->otdel)
          fl := func_error(1,"���� "+alltrim(arr_k_usl[i,1])+" ����饭� ������� � ������ �⤥�����!")
        else
          select USL
          arr_k_usl[i,3] := usl->kod
          arr_k_usl[i,4] := usl->name
          arr_k_usl[i,5] := iif(lis_nul, 0, lu_cena)
          arr_k_usl[i,6] := 1
          arr_k_usl[i,8] := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          arr_k_usl[i,9] := lis_nul
          arr_k_usl[i,10] := fl_oms
        endif
      endif
    endif
    arr_k_usl[i,2] := fl
  next
  for i := 1 to len(arr_k_usl)
    if arr_k_usl[i,2]
      aadd(pr_k_usl, aclone(arr_k_usl[i]) )
    endif
  next
  if len(pr_k_usl) > 0
    mname_u := uk->name
    if !emptyall(uk->kod_vr,uk->kod_as)
      lvr_as := .t.
      mkod_vr := uk->kod_vr
      mkod_as := uk->kod_as
    endif
  endif
endif
rest_box(buf)
return ( len(pr_k_usl) > 0 )

*****
Function CenaUslDate(ldate,lkod)
Local tmp_select := select(), rec_pud, rec_puc, arr := {0,0,0}
rec_pud := pud->(recno())
rec_puc := puc->(recno())
select PUD
dbseek(dtos(ldate),.t.)
do while !eof()
  select PUC
  find (str(pud->(recno()),4)+str(lkod,4))
  if found() .and. !emptyall(puc->pcena,puc->pcena_d,puc->dms_cena)
    arr := {puc->pcena,puc->pcena_d,puc->dms_cena}
    exit
  endif
  select PUD
  skip
enddo
if emptyall(arr[1],arr[2],arr[3])
  usl->(dbGoto(lkod))
  arr := {usl->pcena,usl->pcena_d,usl->dms_cena}
endif
pud->(dbGoto(rec_pud))
puc->(dbGoto(rec_puc))
select (tmp_select)
return arr

*****
Function get_otd(mkod,r,c,fl_usl)
Local k2, fl := .f., buf, r1, r2, c2, delta, mtitle, ;
      i, a_uch := {}, kol_uch := 1
DEFAULT fl_usl TO .f.
if len(pr_arr) == 0
  return NIL
endif
if mkod == 0
  mkod := glob_otd[1]
endif
k2 := ascan(pr_arr, {|x| x[1] == mkod } )
if len(pr_arr[1]) > 2
  for i := 1 to len(pr_arr)
    if ascan(a_uch,pr_arr[i,3]) == 0
      aadd(a_uch,pr_arr[i,3])
    endif
  next
  kol_uch := len(a_uch)
endif
if r > maxrow()-9
  r2 := r - 2
  if (r1 := r2-len(pr_arr)-1) < 2
    r1 := 2
  endif
else
  r1 := r
  if (r2 := r+len(pr_arr)+1) > maxrow()-2
    r2 := maxrow()-2
  endif
endif
delta := iif(kol_uch > 1, 41, 33)
mtitle := iif(kol_uch > 1, "�롮� �⤥�����", alltrim(glob_uch[2]))
c2 := c + delta
if c2 > maxcol()-2
  c2 := maxcol()-2 ; c := c2 - delta
endif
buf := savescreen(r1,0,maxrow(),maxcol())
status_key("^<Esc>^ - ��室 ��� �롮�;  ^<Enter>^ - �롮� �⤥�����")
if (k2 := popup(r1,c,r2,c2,pr_arr_otd,k2,color0,.t.,,,mtitle,col_tit_popup)) > 0
  fl := .t.
  if fl_usl .and. mu_kod > 0
    select UO
    find (str(mu_kod,4))
    if found() .and. !(chr(pr_arr[k2,1]) $ uo->otdel)
      fl := func_error(4,"������ ���� ����饭� ������� � ������ �⤥�����!")
    endif
  endif
  if fl
    glob_otd := { pr_arr[k2,1], pr_arr[k2,2] }
    //glob_otd := { pr_arr[k2,1], pr_arr_otd[k2] }
  endif
endif
restscreen(r1,0,maxrow(),maxcol(),buf)
return if(fl, glob_otd, NIL)

*****
Function get1_otd(_1,_2,_3,_r,_c)
Local fl
if get_otd(m1otd,_r+1,_c) != NIL
  fl := .t.
  if type("mu_kod") == "N" .and. mu_kod > 0
    select UO
    find (str(mu_kod,4))
    if found() .and. !(chr(glob_otd[1]) $ uo->otdel)
      fl := func_error(4,"������ ���� ����饭� ������� � ������ �⤥�����!")
    endif
  endif
  if fl
    m1otd := glob_otd[1] ; motd := glob_otd[2]
    update_get("m1otd") ; update_get("motd")
    keyboard chr(K_DOWN)
  endif
endif
setcursor()
return NIL

***** ��࠭��� ��०����� � �⤥�����
Function saveuchotd()
Local arr[2]
arr[1] := aclone(glob_uch)
arr[2] := aclone(glob_otd)
return arr

***** ����⠭����� ��०����� � �⤥�����
Function restuchotd(arr)
glob_uch := aclone(arr[1])
glob_otd := aclone(arr[2])
return NIL

***** 09.08.16 ��।����� ��� �� ⠡��쭮�� ������ �� ����� ���� ���, ��㣨,...
Function v_kart_vrach(get,is_prvs)
Local fl := .t., tmp_select
Private tmp := readvar()
if &tmp != get:original
  if &tmp == 0
    m1vrach := 0
    mvrach := space(30)
    m1prvs := 0
  elseif &tmp != 0
    DEFAULT is_prvs TO .f.
    tmp_select := select()
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    find (str(&tmp,5))
    if found()
      m1vrach := p2->kod
      m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
      if is_prvs
        mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(m1prvs),36)
      else
        mvrach := padr(fam_i_o(p2->fio),30)
      endif
    else
      fl := func_error(3,"�� ������ ���㤭�� � ⠡���� ����஬ "+lstr(&tmp)+" � �ࠢ�筨�� ���ᮭ���!")
    endif
    p2->(dbCloseArea())
    select (tmp_select)
  endif
  if !fl
    &tmp := get:original
    return .f.
  endif
  update_get("mvrach")
endif
return .t.

***** ������� ��� �� �� ����� � ��࠭��� � glob_MO
Function reRead_glob_MO()
Local i, cCode, tmp_select := select()
R_Use(dir_server+"organiz",,"ORG")
cCode := left(org->kod_tfoms,6)
ORG->(dbCloseArea())
if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
  glob_mo := glob_arr_mo[i]
endif
select (tmp_select)
return NIL

***** 28.12.21 �஢�ઠ �ࠢ��쭮�� ����� �ப�� ��祭��
Function f_k_data(get, k)
  // k = 1 - ��� ��砫� ��祭��
  // k = 2 - ��� ����砭�� ��祭��

  if k == 1 .and. year(mn_data) < 2015
    mn_data := get:original
    return func_error(3, "� ��� ��砫� ��祭�� ����୮ ������ ��� (࠭�� 2015 ����).")
  endif

  if k == 2 .and. empty(mk_data)
    mk_data := get:original
    return func_error(3, "�� ������� ��� ����砭�� ��祭��.")
  endif
  if k == 2 .and. ;
      !(year(mk_data) == year(sys_date) .or. year(mk_data) == year(sys_date)-1)
    mk_data := get:original
    return func_error(3, "� ��� ����砭�� ��祭�� ����୮ ������ ���.")
  endif
  if !empty(mk_data) .and. mn_data > mk_data
    if k == 1
      mn_data := get:original
    else
      mk_data := get:original
    endif
    return func_error(4, "��� ��砫� ��祭�� ����� ���� ����砭�� ��祭��. �訡��!")
  endif
  if k == 1 .and. type("mdate_r") == "D"
    fv_date_r(mn_data)
  endif
  return .t.

***** 17.01.14 ��८�।������ ����� "�����/ॡ񭮪" �� ��� ஦����� � "_date"
Function fv_date_r(_data,fl_end)
Local k, fl, cy, ldate_r := mdate_r
DEFAULT _data TO sys_date, fl_end TO .t.
if type("M1NOVOR") == "N" .and. M1NOVOR == 1 .and. type("mdate_r2") == "D"
  ldate_r := mdate_r2
  k := 1
endif
mvozrast := cy := count_years(ldate_r,_data)
mdvozrast := year(_data) - year(ldate_r)
if k == NIL
  if cy < 14     ; k := 1  // ॡ����
  elseif cy < 18 ; k := 2  // �����⮪
  else           ; k := 0  // �����
  endif
endif
if type("m1vzros_reb") == "N" .and. m1vzros_reb != k
  m1vzros_reb := k
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  update_get("mvzros_reb")
endif
if fl_end
  if type("M1RAB_NERAB") == "N" .and. m1vzros_reb == 1 .and. M1RAB_NERAB == 0
    M1RAB_NERAB := 1
    mrab_nerab := inieditspr(A__MENUVERT, menu_rab, m1rab_nerab)
    update_get("mrab_nerab")
  endif
  if type("m1vid_ud") == "N" .and. empty(m1vid_ud)
    m1vid_ud := iif(k == 1, 3, 14)
  endif
endif
return .t.


***** 14.01.17 ��祣� �� ������ � GET'�
Function get_without_input(oGet,nKey)
if between(nKey, 32, 255) .or. nKey == K_DEL
  oGet:right()  // ᬥ������ ��ࠢ�
  IF ( oGet:typeOut )
    IF ( SET( _SET_BELL ) )
      ?? CHR(7)
    ENDIF
    IF ( !SET( _SET_CONFIRM ) )
      oGet:exitState := GE_ENTER
    ENDIF
  ENDIF
ENDIF
return NIL


***** 09.02.14 �㭪�� ���஢�� ����� ���� (��� ������� INDEX)
Function fsort_schet(s1,s2)
Static cDelimiter := "-"
Local s
if empty(s1)
  s := str(val(alltrim(s2)),13)
else
  s1 := alltrim(s1)
  s := padl(alltrim(token(s1,cDelimiter,2)),6,'0')+;
       padr(alltrim(token(s1,cDelimiter,3)),2)+;
       padr(alltrim(token(s1,cDelimiter,1)),5,'9')
endif
return s

***** 15.01.14 �㭪�� ���஢�� ��஢ ��� �� �����⠭�� (��� ������� INDEX)
Function fsort_usl(sh_u)
Static _sg := 5
Local i, s := "", flag_z := .f., flag_0 := .f., arr
if left(sh_u,1) == "*"
  flag_z := .t.
elseif left(sh_u,1) == "0"
  flag_0 := .t.
endif
arr := usl2arr(sh_u)
for i := 1 to len(arr)
  if i == 2 .and. flag_z
    s += "9"+strzero(arr[i],_sg)  // ��� 㤠������ ��㣨
  elseif i == 1 .and. flag_0
    s += " "+strzero(arr[i],_sg)  // �᫨ ���।� �⮨� 0
  else
    s += strzero(arr[i],1+_sg)
  endif
next
return s

***** 15.01.19 �ॢ���� ��� ��㣨 � 5-���� �᫮��� ���ᨢ
Function usl2arr(sh_u,/*@*/j)
Local i, k, c, ascc, arr := {}, cDelimiter := ".", s := alltrim(sh_u), ;
      s1 := "", is_all_digit := .t.
if left(s,1) == "*"
  s := substr(s,2)
endif
for i := 1 to len(s)
  c := substr(s,i,1) ; ascc := asc(c)
  if between(ascc,48,57) // ����
    s1 += c
  elseif ISLETTER(c) // �㪢�
    is_all_digit := .f.
    if len(s1) > 0 .and. right(s1,1) != cDelimiter
      s1 += cDelimiter // �����⢥��� ��⠢�� ࠧ����⥫�
    endif
    s1 += lstr(ascc)
  else // �� ࠧ����⥫�
    is_all_digit := .f.
    s1 += cDelimiter
  endif
next
if is_all_digit .and. eq_any((k := len(s1)),8,7)  // ���
  if k == 8
    aadd(arr, int(val(substr(s1,1,1))))
    aadd(arr, int(val(substr(s1,2,1))))
    aadd(arr, int(val(substr(s1,3,1))))
    aadd(arr, int(val(substr(s1,6,3))))
    aadd(arr, int(val(substr(s1,4,1))))
  else
    aadd(arr, int(val(substr(s1,1,1))))
    aadd(arr, int(val(substr(s1,2,1))))
    aadd(arr, int(val(substr(s1,3,1))))
    aadd(arr, int(val(substr(s1,5,3))))
    aadd(arr, int(val(substr(s1,4,1))))
  endif
else // ��⠫�� ��㣨
  k := numtoken(alltrim(s1),cDelimiter)
  for i := 1 to k
    j := int(val(token(s1,cDelimiter,i)))
    aadd(arr,j)
  next
  if (j := len(arr)) < 5
    for i := j+1 to 5
      aadd(arr,0)
    next
  endif
endif
return arr

***** 22.04.19 �-�� between ��� ��஢ ���
Function between_shifr(lshifr,lshifr1,lshifr2)
Local fl := .f., k, k1, k2, k3, v, v1, v2
lshifr  := alltrim(lshifr)
lshifr1 := alltrim(lshifr1)
lshifr2 := alltrim(lshifr2)
if len(lshifr) == len(lshifr1) .and. len(lshifr) == len(lshifr2)
  fl := between(lshifr,lshifr1,lshifr2)
else // ��� ��ਠ�� between_shifr(_shifr,"2.88.52","2.88.103")
  k := rat(".",lshifr)
  k1 := rat(".",lshifr1)
  k2 := rat(".",lshifr2)
  if left(lshifr,k) == left(lshifr1,k1) .and. k == k1 .and. k1 == k2
    v := int(val(substr(lshifr,k+1)))
    v1 := int(val(substr(lshifr1,k1+1)))
    v2 := int(val(substr(lshifr2,k2+1)))
    fl := between(v,v1,v2)
  endif
endif
return fl

***** 03.01.19 ���� �� ��� ��㣨 ����� ���
Function is_ksg(lshifr,k)
// k = nil - �� ���
// k = 1 - ��樮���
// k = 2 - ������� ��樮���
Static ss := "0123456789"
Local i, fl := .f.
lshifr := alltrim(lshifr)
if left(lshifr,2) == "st"
  if valtype(k) == "N"
    fl := (int(k) == 1)
  else
    fl := .t.
  endif
elseif left(lshifr,2) == "ds"
  if valtype(k) == "N"
    fl := (int(k) == 2)
  else
    fl := .t.
  endif
endif
if fl
  return fl // ��� 2019 ����
endif
if left(lshifr,1) $ "12" .and. substr(lshifr,5,1) == "." .and. len(lshifr) == 6 // 18 ���
  fl := .t.
  for i := 2 to 6
    if i == 5
      loop
    elseif !(substr(lshifr,i,1) $ ss)
      fl := .f. ; exit
    endif
  next
elseif !("." $ lshifr) .and. eq_any(len(lshifr),8,7) // ��� �� ���� ����
  fl := empty(CHARREPL(ss, lshifr, SPACE(10)))
endif
if fl .and. valtype(k) == "N"
  fl := (left(lshifr,1) == lstr(k))
endif
return fl

***** ��ࠢ����� ����񭭮�� �����
Function val_polis(s)
  Local fl := .t., i, c, s1 := ""

  s := alltrim(s)
  for i := 1 to len(s)
    c := substr(s,i,1)
    if between(c,'0','9') .or. isalpha(c) .or. c $ " -"
      s1 += c
    endif
  next
  return ltrim(charone(" ",s1))

***** ������ ��� 䠩�� ��� ��� � ���७��
Function Name_Without_Ext(cFile)
  LOCAL cName

  //LOCAL cPath, cName, cExt, cDrive
  //IF hb_FileExists( cFile )
    //HB_FNameSplit( cFile, @cPath, @cName, @cExt, @cDrive )
  //ENDIF
  HB_FNameSplit(cFile,,@cName)
  return cName

***** ������ ���७�� 䠩��
Function Name_Extention(cFile)
  LOCAL cExt

  //LOCAL cPath, cName, cExt, cDrive
  //IF hb_FileExists( cFile )
    //HB_FNameSplit( cFile, @cPath, @cName, @cExt, @cDrive )
  //ENDIF
  HB_FNameSplit(cFile,,,@cExt)
  return cExt

***** ��ॢ�� ������ ���孥�� 㣫� ��אַ㣮�쭨�� �� ���न��� 25�80 � "maxrow(maxcol)"
Function get_row_col_max(r,c,/*@*/r1,/*@*/c1,/*@*/r2,/*@*/c2)
Local d := 24-r
r1 := maxrow()-d ; r2 := r1+2
d := int(79-2*c)
c1 := int((maxcol()-d)/2) ; c2 := c1 + d
return NIL

***** �஢���� ���� � �६� �� �ࠢ��쭮��� ��ਮ��
function v_date_time(date1,time1,date2,time2)
Local fl := .t.
if date1 > date2
  fl := func_error(4,"��砫쭠� ��� ����� ����筮�!")
elseif date1 == date2 .and. time1 > time2
  fl := func_error(4,"��砫쭮� �६� ����� ����筮��!")
endif
return fl

*****
Function between_time(_mdate,_mtime,date1,time1,date2,time2)
// _mdate,_mtime - �஢��塞�� �६�
// date1,time1,date2,time2 - �஢��塞� ��ਮ�
Local fl
DEFAULT time1 TO "00:00", time2 TO "24:00"
if (fl := between(_mdate,date1,date2))
  if _mdate == date1 .and. _mdate == date2
    fl := (f_time(_mtime) >= f_time(time1) .and. f_time(_mtime) <= f_time(time2))
  elseif _mdate == date1
    fl := (f_time(_mtime) >= f_time(time1))
  elseif _mdate == date2
    fl := (f_time(_mtime) <= f_time(time2))
  endif
endif
return fl

*****
Static Function f_time(t)
return round_5(val(substr(t,1,2))+val(substr(t,4,2))/60,5)

***** ������ ��� �� ��� �������� ��㣨
Function opr_uet(lvzros_reb,k)
Local muet,mvkoef_v,makoef_v,mvkoef_r,makoef_r,mkoef_v,mkoef_r,mdate,arr,i
DEFAULT k TO 0
Store 0 TO muet,mvkoef_v,makoef_v,mvkoef_r,makoef_r,mkoef_v,mkoef_r
if select("UU") == 0
  useUch_Usl()
endif
select UU
find (str(hu->u_kod,4))
if found()
  mvkoef_v := uu->vkoef_v // ��� - ��� ��� ���᫮��
  makoef_v := uu->akoef_v // ���. - ��� ��� ���᫮��
  mvkoef_r := uu->vkoef_r // ��� - ��� ��� ॡ����
  makoef_r := uu->akoef_r // ���. - ��� ��� ॡ����
  mkoef_v  := uu->koef_v  // �⮣� ��� ��� ���᫮��
  mkoef_r  := uu->koef_r  // �⮣� ��� ��� ॡ����
  //
  mdate := c4tod(hu->date_u) ; arr := {}
  select UU1
  find (str(hu->u_kod,4))
  do while uu1->kod == hu->u_kod .and.!eof()
    aadd(arr, {uu1->date_b,uu1->(recno())})
    skip
  enddo
  if len(arr) > 0
    asort(arr,,,{|x,y| x[1] >= y[1] })
    for i := 1 to len(arr)
      if mdate >= arr[i,1]
        goto (arr[i,2])
        mvkoef_v := uu1->vkoef_v // ��� - ��� ��� ���᫮��
        makoef_v := uu1->akoef_v // ���. - ��� ��� ���᫮��
        mvkoef_r := uu1->vkoef_r // ��� - ��� ��� ॡ����
        makoef_r := uu1->akoef_r // ���. - ��� ��� ॡ����
        mkoef_v  := uu1->koef_v  // �⮣� ��� ��� ���᫮��
        mkoef_r  := uu1->koef_r  // �⮣� ��� ��� ॡ����
        exit
      endif
    next
  endif
endif
if lvzros_reb == 0
  do case
    case k == 0
      muet := iif(empty(mkoef_v),mkoef_r,mkoef_v)
    case k == 1
      muet := iif(empty(mvkoef_v),mvkoef_r,mvkoef_v)
    case k == 2
      muet := iif(empty(makoef_v),makoef_r,makoef_v)
  endcase
else
  do case
    case k == 0
      muet := iif(empty(mkoef_r),mkoef_v,mkoef_r)
    case k == 1
      muet := iif(empty(mvkoef_r),mvkoef_v,mvkoef_r)
    case k == 2
      muet := iif(empty(makoef_r),makoef_v,makoef_r)
  endcase
endif
return muet

***** ������ ��� ����� �� ��� ����砭�� ��祭��
Function opr_shifr_TFOMS(lshifr,lkod,ldate)
Local tmp_select := select()
DEFAULT ldate TO sys_date
if select("USL1") == 0
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
endif
select USL1
set order to 1
find (str(lkod,4))
if found()
  lshifr := space(10)
  do while usl1->kod == lkod .and. !eof()
    if usl1->date_b > ldate
      exit
    endif
    lshifr := usl1->shifr1
    skip
  enddo
endif
select (tmp_select)
return lshifr

***** 31.12.17 ���� ���� �� ���� ����� � ��襬 �ࠢ�筨�� ���
Function foundOurUsluga(lshifr,ldate,lprofil,lvzros_reb,/*@*/lu_cena,ipar,not_cycle)
Local au := {}, s, v1, v2, mname := space(65), fl := .t., lu_kod
DEFAULT ipar TO 1, not_cycle TO .t.
lshifr := padr(lshifr,10)
select LUSL
find (lshifr)
if found()
  mname := alltrim(lusl->name)
  if len(mname) > 65 .and. eq_any(left(lshifr,2),"2.","70","72")
    mname := right(mname,65)
  endif
endif
if ipar == 1 // ᭠砫� �஢�ਬ ᮡ�⢥��� ��� ��㣨, ࠢ�� ���� �����
  select USL
  set order to 2
  find (lshifr)
  if found()
    s := space(10)
    select USL1
    set order to 1
    find (str(usl->kod,4))
    if found()
      do while usl1->kod == usl->kod .and. !eof()
        if usl1->date_b > ldate
          exit
        endif
        s := usl1->shifr1
        skip
      enddo
    endif
    if empty(s) .or. s == lshifr // ���� "��� �����" ���⮥ ��� ࠢ�� "lshifr"
      fl := .f.
    endif
  endif
  if fl // �஢�ਬ ��, �� ���짮����� ��஬ �����
    select USL1
    set order to 2
    find (lshifr)
    do while usl1->shifr1 == lshifr .and. !eof()
      if usl1->date_b <= ldate
        aadd(au,usl1->kod)
      endif
      skip
    enddo
    select USL1
    set order to 1
    for i := 1 to len(au) // 横� �� ����� ���, �� ����� �⮨� �㦭� ��� �����
      s := space(10)
      find (str(au[i],4))
      do while usl1->kod == au[i] .and. !eof()
        if usl1->date_b > ldate
          exit
        endif
        s := usl1->shifr1
        skip
      enddo
      if s == lshifr
        usl->(dbGoto(au[i]))
        fl := .f. ; exit
      endif
    next
  endif
endif
if fl
  v1 := v2 := 0 // �᫨ ��� ��㣨 � �ࠢ�筨�� �����
  select LUSL
  find (padr(lshifr,10))
  if found()
    v1 := fcena_oms(lusl->shifr,.t.,ldate)
    v2 := fcena_oms(lusl->shifr,.f.,ldate)
  endif
  select USL
  if ipar == 1
    set order to 1
  else
    set order to 2 // �.�. �� ����� ���� ���� ������� ������ �������
  endif
  FIND (STR(-1,4))
  if found()
    G_RLock(forever)
  else
    AddRec(4)
  endif
  usl->kod := recno()
  usl->name := mname
  usl->shifr := lshifr
  usl->PROFIL := lprofil
  usl->cena   := v1
  usl->cena_d := v2
  if not_cycle
    UnLock
  endif
endif
if empty(usl->name) .and. !empty(mname)
  select USL
  G_RLock(forever)
  usl->name := mname
  if not_cycle
    UnLock
  endif
endif
lu_kod := usl->kod
lu_cena := iif(lvzros_reb==0, usl->cena, usl->cena_d)
if (v1 := f1cena_oms(usl->shifr,;
                     lshifr,;
                     (lvzros_reb==0),;
                     ldate,;
                     usl->is_nul)) != NIL
  lu_cena := v1
endif
return lu_kod

***** 07.04.14 ���� �� ��㣨 �� ���� ����� � ��襬 �ࠢ�筨�� ���
Function foundAllShifrTF(lshifr,ldate)
Local au := {}, s, ret_u := {}
lshifr := padr(lshifr,10)
// ᭠砫� �஢�ਬ ᮡ�⢥��� ��� ��㣨, ࠢ�� ���� �����
select USL
set order to 2
find (lshifr)
if found()
  s := space(10)
  select USL1
  set order to 1
  find (str(usl->kod,4))
  if found()
    do while usl1->kod == usl->kod .and. !eof()
      if usl1->date_b > ldate
        exit
      endif
      s := usl1->shifr1
      skip
    enddo
  endif
  if empty(s) .or. s == lshifr // ���� "��� �����" ���⮥ ��� ࠢ�� "lshifr"
    aadd(ret_u,usl->kod)
  endif
endif
// �஢�ਬ ��, �� ���짮����� ��஬ �����
select USL1
set order to 2
find (lshifr)
do while usl1->shifr1 == lshifr .and. !eof()
  if usl1->date_b <= ldate
    aadd(au,usl1->kod)
  endif
  skip
enddo
select USL1
set order to 1
for i := 1 to len(au) // 横� �� ����� ���, �� ����� �⮨� �㦭� ��� �����
  s := space(10)
  find (str(au[i],4))
  do while usl1->kod == au[i] .and. !eof()
    if usl1->date_b > ldate
      exit
    endif
    s := usl1->shifr1
    skip
  enddo
  if s == lshifr
    aadd(ret_u,au[i])
  endif
next
return ret_u

***** 23.12.15 � GET'� ������ ������⢥��� �롮� ��०�����/�⤥�����
Function ret_Nuch_Notd(k,r,c)
Local lcount_uch, lcount_otd, s
pr_a_uch := {} ; pr_a_otd := {}
if (st_a_uch := inputN_uch(-r,c,,,@lcount_uch)) != NIL
  pr_a_uch := aclone(st_a_uch)
  if len(st_a_uch) == 1
    glob_uch := st_a_uch[1]
    if (st_a_otd := inputN_otd(-r,c,.f.,.t.,glob_uch,@lcount_otd)) != NIL
      pr_a_otd := aclone(st_a_otd)
    endif
  else
    R_Use(dir_server+"mo_otd",,"OTD")
    go top
    do while !eof()
      if f_is_uch(st_a_uch,otd->kod_lpu)
        aadd(pr_a_otd, {otd->(recno()),otd->name})
      endif
      skip
    enddo
    otd->(dbCloseArea())
  endif
endif
if (k := len(pr_a_uch)) == 0
  s := "��祣� �� ��࠭�"
elseif k == 1
  if (k := len(pr_a_otd)) == 1
    s := '"'+alltrim(pr_a_otd[1,2])+'" � "'+alltrim(glob_uch[2])+'"'
  else
    s := "��࠭� �⤥�����: "+lstr(k)+' � "'+alltrim(glob_uch[2])+'"'
  endif
else
  s := "��࠭� ��०�����: "+lstr(k)
endif
return {k,charone('"',s)}

***** 23.12.15 ���樠������ �롮ન ��᪮�쪨� ⨯�� ����
Function ini_ed_tip_schet(lval)
Local s := lval
if empty(lval)
  s := "�� ��࠭� ⨯� ��⮢"
elseif len(lval) == 18
  s := "�� ⨯� ��⮢"
endif
return s

***** 22.12.15 �롮� ��᪮�쪨� ⨯�� ����
Function inp_bit_tip_schet(k,r,c)
Local mlen, t_mas := {}, buf := savescreen(), ret, ;
      i, tmp_color := setcolor(), m1var := "", s := "", r1, r2,;
      top_bottom := (r < maxrow()/2)
mywait()
aeval(mm_bukva, {|x| aadd(t_mas,iif(x[2] $ k," * ","   ")+x[1]) })
mlen := len(t_mas)
i := 1
status_key("^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins,+,->^ - ᬥ�� �롮� ⨯� ����")
if top_bottom     // ᢥ��� ����
  r1 := r+1
  if (r2 := r1+mlen+1) > maxrow()-2
    r2 := maxrow()-2
  endif
else
  r2 := r-1
  if (r1 := r2-mlen-1) < 2
    r1 := 2
  endif
endif
if (ret := popup(r1,2,r2,77,t_mas,i,color0,.t.,"fmenu_reader",,;
                 "�롮� ������/��᪮�쪨�/��� ⨯�� ��⮢","B/BG")) > 0
  for i := 1 to mlen
    if "*" == substr(t_mas[i],2,1)
      m1var += mm_bukva[i,2]
    endif
  next
  s := ini_ed_tip_schet(m1var)
endif
restscreen(buf)
setcolor(tmp_color)
return iif(ret==0, NIL, {m1var,s})