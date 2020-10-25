***** mo_main.prg - ������ �����
*******************************************************************************
* �㭪樨 ��� plug-in'��
*******************************************************************************
* my_mo_f_main()
* my_mo_f1main()
* my_mo_begin_task()
* my_mo_Reconstruct_BD()
* my_mo_init_array_files_DB()
*******************************************************************************
#include "set.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static _version := {2,11,12}
2.11Static char_version := "a"
Static _date_version := "25.10.20�."
Static __s_full_name := "��� + ���� ࠡ��� ����樭᪮� �࣠����樨"
Static __s_version

external ust_printer, ErrorSys, ReadModal, like, flstr, prover_dbf, net_monitor, pr_view, ne_real
// ���� (।�� �ᯮ��㥬�) ������ ����᪠�� �� hrb-䠩��� (��� 㬥��襭�� �����)
DYNAMIC i_new_boln
DYNAMIC i_kol_del_zub
DYNAMIC phonegram_15_kz
DYNAMIC forma_792_MIAC
DYNAMIC f1forma_792_MIAC
DYNAMIC monitoring_vid_pom
DYNAMIC b_25_perinat_2

*****
procedure main( ... )
Local r, s, is_create := .f., is_copy := .f., is_index := .f.
Local a_parol, buf, is_cur_dir
FOR EACH s IN hb_AParams() // ������ �室��� ��ࠬ��஢
  s := lower(s)
  DO CASE
    CASE s == "/create"
      is_create := .t.
    CASE s == "/copy"
      is_copy := .t.
    CASE s == "/index"
      is_index := .t.
  ENDCASE
NEXT
//
Public kod_VOUNC := '101004'
Public kod_LIS   := {'125901','805965'}
//
Public DELAY_SPRD := 0 // �६� ����প� ��� ࠧ���稢���� ��ப
Public sdbf := ".DBF", sntx := ".NTX", stxt := ".TXT", szip := ".ZIP",;
       smem := ".MEM", srar := ".RAR", sxml := ".XML", sini := ".INI",;
       sfr3 := ".FR3", sfrm := ".FRM", spdf := ".PDF", scsv := ".CSV",;
       sxls := ".xls", schip := ".CHIP", cslash := "\"
PUBLIC public_mouse := .f., pravo_write := .t., pravo_read := .t., ;
       MenuTo_Minut := 0, sys_date := DATE(), cScrMode := "COLOR", ;
       DemoMode := .f., picture_pf := "@R 999-999-999 99", ;
       pict_cena := "9999999.99", forever := "forever"
Public gpasskod := ret_gpasskod()
PUBLIC sem_task := "���� ࠡ��� ��"
PUBLIC sem_vagno := "���� ࠡ��� �� - �⢥��⢥��� ०��"
PUBLIC err_slock := "� ����� ������ � �⨬ ०���� ࠡ�⠥� ��㣮� ���짮��⥫�. ����� ������!"
PUBLIC err_admin := "����� � ����� ०�� ࠧ�襭 ⮫쪮 ������������ ��⥬�!"
PUBLIC err_sdemo := "�� ��������樮���� �����. ������ ����饭�!"
PUBLIC fr_data := "_data", fr_titl := "_titl"
Public dir_XML_MO := "XML_MO", dir_XML_TF := "XML_TF"
Public dir_NAPR_MO := "NAPR_MO", dir_NAPR_TF := "NAPR_TF"
Public _tmp_dir  := "TMP___"
Public _tmp_dir1 := _tmp_dir+cslash
Public _tmp2dir  := "TMP2___"
Public _tmp2dir1 := _tmp2dir+cslash
Public d_01_04_2013 := 0d20130401
Public d_01_04_2015 := 0d20150401
Public d_01_08_2016 := 0d20160801
Public d_01_08_2017 := 0d20170801
Public d_01_09_2017 := 0d20170901
Public d_01_05_2018 := 0d20180501
Public d_01_05_2019 := 0d20190501
Public d_01_11_2019 := 0d20191101
//
Public p_arr_prazdnik := {{2013,{;
                                 { 1,{1,2,3,4,5,6,7,8,12,13,19,20,26,27}},;
                                 { 2,{2,3,9,10,16,17,23,24}},;
                                 { 3,{2,3,8,9,10,16,17,23,24,30,31}},;
                                 { 4,{6,7,13,14,20,21,27,28}},;
                                 { 5,{1,2,3,4,5,9,10,11,12,18,19,25,26}},;
                                 { 6,{1,2,8,9,12,15,16,22,23,29,30}},;
                                 { 7,{6,7,13,14,20,21,27,28}},;
                                 { 8,{3,4,10,11,17,18,24,25,31}},;
                                 { 9,{1,7,8,14,15,21,22,28,29}},;
                                 {10,{5,6,12,13,19,20,26,27}},;
                                 {11,{2,3,4,9,10,16,17,23,24,30}},;
                                 {12,{1,7,8,14,15,21,22,28,29}}};
                          },;
                          {2014,{;
                                 { 1,{1,2,3,4,5,6,7,8,11,12,18,19,25,26}},;
                                 { 2,{1,2,8,9,15,16,22,23}},;
                                 { 3,{1,2,8,9,10,15,16,22,23,29,30}},;
                                 { 4,{5,6,12,13,19,20,26,27}},;
                                 { 5,{1,2,3,4,9,10,11,17,18,24,25,31}},;
                                 { 6,{1,7,8,12,13,14,15,21,22,28,29}},;
                                 { 7,{5,6,12,13,19,20,26,27}},;
                                 { 8,{2,3,9,10,16,17,23,24,30,31}},;
                                 { 9,{6,7,13,14,20,21,27,28}},;
                                 {10,{4,5,11,12,18,19,25,26}},;
                                 {11,{1,2,3,4,8,9,15,16,22,23,29,30}},;
                                 {12,{6,7,13,14,20,21,27,28}}};
                          },;
                          {2015,{;
                                 { 1,{1,2,3,4,5,6,7,8,9,10,11,17,18,24,25,31}},;
                                 { 2,{1,7,8,14,15,21,22,23,28}},;
                                 { 3,{1,7,8,9,14,15,21,22,28,29}},;
                                 { 4,{4,5,11,12,18,19,25,26}},;
                                 { 5,{1,2,3,4,9,10,11,16,17,23,24,30,31}},;
                                 { 6,{6,7,12,13,14,20,21,27,28}},;
                                 { 7,{4,5,11,12,18,19,25,26}},;
                                 { 8,{1,2,8,9,15,16,22,23,29,30}},;
                                 { 9,{5,6,12,13,19,20,26,27}},;
                                 {10,{3,4,10,11,17,18,24,25,31}},;
                                 {11,{1,4,7,8,14,15,21,22,28,29}},;
                                 {12,{5,6,12,13,19,20,26,27}}};
                          },;
                          {2016,{;
                                 { 1,{1,2,3,4,5,6,7,8,9,10,16,17,23,24,30,31}},;
                                 { 2,{6,7,13,14,21,22,23,27,28}},;
                                 { 3,{5,6,7,8,12,13,19,20,26,27}},;
                                 { 4,{2,3,9,10,16,17,23,24,30}},;
                                 { 5,{1,2,3,7,8,9,14,15,21,22,28,29}},;
                                 { 6,{4,5,11,12,13,18,19,25,26}},;
                                 { 7,{2,3,9,10,16,17,23,24,30,31}},;
                                 { 8,{6,7,13,14,20,21,27,28}},;
                                 { 9,{3,4,10,11,17,18,24,25}},;
                                 {10,{1,2,8,9,15,16,22,23,29,30}},;
                                 {11,{4,5,6,12,13,19,20,26,27}},;
                                 {12,{3,4,10,11,17,18,24,25,31}}};
                          },;
                          {2017,{;
                                 { 1,{1,2,3,4,5,6,7,8,14,15,21,22,28,29}},;
                                 { 2,{4,5,11,12,18,19,23,24,25,26}},;
                                 { 3,{4,5,8,11,12,18,19,25,26}},;
                                 { 4,{1,2,8,9,15,16,22,23,29,30}},;
                                 { 5,{1,6,7,8,9,13,14,20,21,27,28}},;
                                 { 6,{3,4,10,11,12,17,18,24,25}},;
                                 { 7,{1,2,8,9,15,16,22,23,29,30}},;
                                 { 8,{5,6,12,13,19,20,26,27}},;
                                 { 9,{2,3,9,10,16,17,23,24,30}},;
                                 {10,{1,7,8,14,15,21,22,28,29}},;
                                 {11,{4,5,6,11,12,18,19,25,26}},;
                                 {12,{2,3,9,10,16,17,23,24,30,31}}};
                          },;
                          {2018,{;
                                 { 1,{1,2,3,4,5,6,7,8,13,14,20,21,27,28}},;
                                 { 2,{3,4,10,11,17,18,23,24,25}},;
                                 { 3,{3,4,8,9,10,11,17,18,24,25,31}},;
                                 { 4,{1,7,8,14,15,21,22,29,30}},;
                                 { 5,{1,2,5,6,9,12,13,19,20,26,27}},;
                                 { 6,{2,3,10,11,12,16,17,23,24,30}},;
                                 { 7,{1,7,8,14,15,21,22,28,29}},;
                                 { 8,{4,5,11,12,18,19,25,26}},;
                                 { 9,{1,2,8,9,15,16,22,23,29,30}},;
                                 {10,{6,7,13,14,20,21,27,28}},;
                                 {11,{3,4,5,10,11,17,18,24,25}},;
                                 {12,{1,2,8,9,15,16,22,23,30,31}}};
                          },;
                          {2019,{;
                                 { 1,{1,2,3,4,5,6,7,8,12,13,19,20,26,27}},;
                                 { 2,{2,3,9,10,16,17,23,24}},;
                                 { 3,{2,3,8,9,10,16,17,23,24,30,31}},;
                                 { 4,{6,7,13,14,20,21,27,28}},;
                                 { 5,{1,2,3,4,5,9,10,11,12,18,19,25,26}},;
                                 { 6,{1,2,8,9,12,15,16,22,23,29,30}},;
                                 { 7,{6,7,13,14,20,21,27,28}},;
                                 { 8,{3,4,10,11,17,18,24,25,31}},;
                                 { 9,{1,7,8,14,15,21,22,28,29}},;
                                 {10,{5,6,12,13,19,20,26,27}},;
                                 {11,{2,3,4,9,10,16,17,23,24,30}},;
                                 {12,{1,7,8,14,15,21,22,28,29}}};
                          },;
                          {2020,{;
                                 { 1,{1,2,3,4,5,6,7,8,11,12,18,19,25,26}},;
                                 { 2,{1,2,8,9,15,16,22,23,24,29}},;
                                 { 3,{1,7,8,9,14,15,21,22,28,29}},;
                                 { 4,{4,5,11,12,18,19,25,26}},;
                                 { 5,{1,2,3,4,5,9,10,11,16,17,23,24,30,31}},;
                                 { 6,{6,7,12,13,14,20,21,27,28}},;
                                 { 7,{4,5,11,12,18,19,25,26}},;
                                 { 8,{1,2,8,9,15,16,22,23,29,30}},;
                                 { 9,{5,6,12,13,19,20,26,27}},;
                                 {10,{3,4,10,11,17,18,24,25,31}},;
                                 {11,{1,4,7,8,14,15,21,22,28,29}},;
                                 {12,{5,6,12,13,19,20,26,27}}};
                          };
                         }
//
__s_version := "  �. "+fs_version(_version)+char_version+" �� "+_date_version+" ⥫.(8442)23-69-56"
SET(_SET_DELETED, .T.)
SETCLEARB(" ")
is_cur_dir := f_first(is_create)
put_icon(__s_full_name+__s_version,"MAIN_ICON")
set key K_F1 to f_help()
hard_err("create")
FillScreen(p_char_screen,p_color_screen) //FillScreen("�","N+/N")
cur_year := STR(YEAR(sys_date),4)
new_dir = ""
SETCOLOR(color1)
r := init_mo() // ���樠������ ���ᨢ� ��, ����� ���� �� (�� ����室�����)
a_parol := inp_password(is_cur_dir,is_create)
if tip_polzovat != TIP_ADM
  Private verify_fio_polzovat := .f.
endif
if !G_SOpen(sem_task,sem_vagno,fio_polzovat,p_name_comp)
  if type("verify_fio_polzovat") == "L" .and. verify_fio_polzovat
    func_error('� ����� ������ ࠡ�⠥� ��㣮� ������ ��� 䠬����� "'+fio_polzovat+'"')
  else
    func_error('����� ����饭! � ����� ������ ��㣮� ����祩 �믮������ �⢥��⢥��� ०��.')
  endif
  f_end()
endif
//
Public chm_help_code := 0
Init_first() // ��砫쭠� ���樠������ �ணࠬ�� (��६�����, ���ᨢ��,...)
if ControlBases(1,_version) // �᫨ ����室���
  if G_SLock1Task(sem_task,sem_vagno)  // ����� ����㯠 �ᥬ
    buf := savescreen()
    f_message({"���室 �� ����� ����� �ணࠬ�� "+fs_version(_version)+' �� '+_date_version},,,,8)
    // �஢��� ४�������� ��
    Reconstruct_BD(is_cur_dir,is_create)
    // �஢��� ४�������� �� ���� ���ࠢ����� �� ��ᯨ⠫�����
    _263_init()
    // ��� ��砫� ࠡ��� _first_run() (�ࠫ � NOT_USED)
    pereindex() // ��易⥫쭮
    // ������� ���� ����� ���ᨨ
    ControlBases(3)
    if glob_mo[_MO_IS_UCH]
      //correct_polis_from_sptk()  // ���४�஢�� ����ᮢ �� ॥��஢ ����
      //dubl_zap_kod_tf()          // 㤠���� �㡫����� ����ᥩ � ����⥪�
    endif
    // ࠧ�襭�� ����㯠 �ᥬ
    G_SUnLock(sem_vagno)
    restscreen(buf)
  else
    n_message({'�� �����⨫� ����� ����� ����� '+fs_version(_version)+' �� '+_date_version,;
               '�ॡ���� ४�������� (� ��२�����஢����) ���� ������.',;
               '�� � ����� ������ ࠡ���� ��㣨� �����.',;
               '����室���, �⮡� �� ���짮��⥫� ��諨 �� �����.'},;
              {'','��� �����襭�� ࠡ��� ������ ���� �������'},;
              cColorSt2Msg,cColorStMsg,,,"G+/R")
    f_end(.f.)
  endif
endif
Init_Program() // ���樠������ �ணࠬ�� (��६�����, ���ᨢ��,...)
f_main(r,a_parol)
f_end()
return

#define SW_SHOWNORMAL 1

*****
Function f_help()
Local spar := ""
if chm_help_code >= 0
  spar := '-mapid '+lstr(chm_help_code)+' '
endif
ShellExecute(GetDeskTopWindow(),;
             'open',;
             'hh.exe',;
             spar+exe_dir+cslash+'CHIP_MO.CHM',;
             ,;
             SW_SHOWNORMAL)
return NIL

*****
Function file_AdobeReader(cFile)
ShellExecute(GetDeskTopWindow(),;
             'open',;
             'AcroRd32.exe',;
             cFile,;
             ,;
             SW_SHOWNORMAL)
return NIL

*

***** 04.10.16
Function f_main(r0,a_parol)
Static arr1 := {;
  {"���������� �����������"            ,X_REGIST,,.t.,"������������"},;
  {"���� ����� ��樮���"           ,X_PPOKOJ,,.t.,"�������� �����"},;
  {"��易⥫쭮� ����樭᪮� ���客����",X_OMS   ,,.t.,"���"},;
  {"���� ���ࠢ����� �� ��ᯨ⠫�����"  ,X_263   ,,.F.,"��������������"},;
  {"����� ��㣨"                      ,X_PLATN ,,.t.,"������� ������"},;
  {"��⮯����᪨� ��㣨 � �⮬�⮫����",X_ORTO  ,,.t.,"���������"},;
  {"���� ����樭᪮� �࣠����樨"       ,X_KASSA ,,.t.,"�����"},;
  {"��� ����樭᪮� �࣠����樨"         ,X_KEK   ,,.F.,"���"};
 }
Static arr2 := {;
  {"������஢���� �ࠢ�筨���"         ,X_SPRAV ,,.t.},;
  {"��ࢨ�� � ����ன��"                 ,X_SERVIS,,.t.},;
  {"����ࢭ�� ����஢���� ���� ������"   ,X_COPY  ,,.t.},;
  {"��२�����஢���� ���� ������"      ,X_INDEX ,,.t.};
 }
Local i, lens := 0, r, c, oldTfoms, arr, ar, k, fl_exit := .t.
PUBLIC array_tasks := {}, sem_vagno_task[24]
afill(sem_vagno_task,"")
for i := 1 to len(arr1)
  aadd(array_tasks,arr1[i])
  sem_vagno_task[arr1[i,2]] := '����� ०�� � ����� "'+arr1[i,5]+'"'
next
arr := my_mo_f_main() // "᢮�" �����
for i := 1 to len(arr)
  aadd(array_tasks,arr[i])
next
for i := 1 to len(arr2)
  aadd(array_tasks,arr2[i])
next
//
arr := {}
for i := 1 to len(array_tasks)
  if (k := array_tasks[i,2]) < 10  // ��� �����
    array_tasks[i,4] := (substr(glob_mo[_MO_PROD],k,1)=='1')
    if array_tasks[i,4]
      fl_exit := .f.
    endif
  endif
  // ���� ���ࠢ����� �� ��ᯨ⠫�����
  if k == X_263 .and. (is_napr_pol .or. is_napr_stac)
    array_tasks[i,4] := .t.
    fl_exit := .f.
  endif
  if array_tasks[i,4]
    aadd(arr,array_tasks[i])
    lens := max(lens,len(array_tasks[i,1]))
  endif
next
Public glob_task, blk_ekran, g_arr_stand := {},;
       main_menu, main_message, first_menu,;
       first_message, func_menu, cmain_menu
if fl_exit
  func_error(4,"��� ࠧ�襭�� �� ࠡ��� �� � ����� �����!")
else
  // �뢥�� ���孨� ��ப� �������� ��࠭�
  r0 := main_up_screen()
  // �뢥�� 業�ࠫ�� ��ப� �������� ��࠭�
  main_center_screen(r0,a_parol)
  if tip_polzovat == TIP_ADM
    find_unfinished_reestr_sp_tk(.f.,.t.)
    find_time_limit_human_reestr_sp_tk()
    find_unfinished_R01()
    find_unfinished_R11()
  endif
  //
  r := int((maxrow()-r0-len(arr))/2)-1
  c := int((maxcol()+1-lens)/2)-1
  ar := GetIniSect(tmp_ini,"task")
  k := i := int(val(a2default(ar,"current_task",lstr(X_OMS))))
  do while .t.
    if (i := popup_2array(arr,r+r0,c,i,,,"�롮� �����","B+/W","N+/W,W+/N*")) == 0
      exit
    endif
    oldTfoms := glob_mo[_MO_KOD_TFOMS]
    buf := savescreen()
    k := i
    f1main(i)
    restscreen(buf)
    reRead_glob_MO()
    if !(oldTfoms == glob_mo[_MO_KOD_TFOMS])
      // �뢥�� ���孨� ��ப� �������� ��࠭�
      r0 := main_up_screen()
      // �뢥�� 業�ࠫ�� ��ப� �������� ��࠭�
      main_center_screen(r0)
    endif
    change_sys_date() // ������� ��⥬��� ����
    put_icon(__s_full_name+__s_version,"MAIN_ICON") // ��ॢ뢥�� ��������� ����
    @ r0,0 say full_date(sys_date) color "W+/N" // ��ॢ뢥�� ����
    @ r0,maxcol()-4 say hour_min(seconds()) color "W+/N" // ��ॢ뢥�� �६�
  enddo
  SetIniSect(tmp_ini,"task",{{"current_task",lstr(k)}})
endif
return NIL

***** �뢥�� ���孨� ��ப� �������� ��࠭�
Function main_up_screen()
Local i, k, s, arr[2]
FillScreen(p_char_screen,p_color_screen) //FillScreen("�","N+/N")
s := "��� "+iif(glob_mo[_MO_IS_MAIN],"��","���ᮡ������� ���ࠧ�������")+;
     ", ��᢮���� �����: "+glob_mo[_MO_KOD_TFOMS]+;
     " (॥��஢� � "+glob_mo[_MO_KOD_FFOMS]+")"
@ 0,0 say padc(s,maxcol()+1) color "W+/N"
s := iif(glob_mo[_MO_IS_MAIN],"","���ᮡ������ ���ࠧ�������: ")+;
     glob_mo[_MO_FULL_NAME]
k := perenos(arr,s,maxcol()+1)
for i := 1 to k
  @ i,0 say padc(alltrim(arr[i]),maxcol()+1) color "GR+/N"
next
i := get_uroven()
if between(i,1,3)
  s := "�஢��� 業 �� ����樭᪨� ��㣨: "+lstr(i)
else
  s := "�������㠫�� ���� �� ����樭᪨� ��㣨"
endif
@ k+1,0 say space(maxcol()+1) color "G+/N"
//@ k+1,0 say padc(s,maxcol()+1) color "G+/N"
@ k+1,0 say full_date(sys_date) color "W+/N"
@ k+1,maxcol()-4 say hour_min(seconds()) color "W+/N"
return k+1

***** �뢥�� 業�ࠫ�� ��ப� �������� ��࠭�
Function main_center_screen(r0,a_parol)
Static nLen := 11
Static arr_name := {"�����", "������", "���", "���������",;
                    "���������", "梨�", "த���� �ࠢ��",;
                    "����஦����� � ������ ���ᮩ ⥫�",;
                    "��⬠", "������","����ॠ��"}
Local s, i, c, k, t_arr, r1, buf, mst := ""
g_arr_stand := {}
if valtype(glob_mo[_MO_STANDART]) == "A"
  for k := 1 to len(glob_mo[_MO_STANDART])
    t_arr := {glob_mo[_MO_STANDART,k,1],{}}
    mst := padr(glob_mo[_MO_STANDART,k,2],nLen)
    for i := 1 to nLen
      c := substr(mst,i,1)
      if c == "1"
        aadd(t_arr[2],i)
      endif
    next
    aadd(g_arr_stand,aclone(t_arr))
  next
endif
if .t.//empty(mst)
  if valtype(a_parol) == "A" .and. (k := len(a_parol)) > 0
    r1 := r0+int((maxrow()-r0-k)/2)-1
    n_message(a_parol,,"W+/W*","R/W*",r1,,"N+/W*")
  endif
else
  s := "���������᪨� ���, �� ����� �� ������ � �믮������ �⠭���⮢:"
  for i := 1 to nLen
    c := substr(mst,i,1)
    if eq_any(c,"1","2")
      s += " "+arr_name[i]
      if c == "2"
        s += "[*]"
      endif
      s += ","
    endif
  next
  s := left(s,len(s)-1)
  t_arr := array(2)
  k := perenos(t_arr,s,64)
  r1 := r0+int((maxrow()-r0-k)/2)-1
  if (k := len(a_parol)) > 0
    if r1-r0 < k+4
      r1 := r0+k+4
    endif
    buf := save_box(r1-k-4,0,r1-1,maxcol())
    f_message(a_parol,,"W+/W*","R/W*",r1-k-3)
  endif
  n_message(t_arr,,"W/W","N/W",r1,,"N+/W")
  if buf != NIL
    rest_box(buf)
  endif
endif
return NIL

*

***** 21.07.14
Function f1main(n_Task)
Local it, s, k, fl := .t., cNameIcon
if (it := ascan(array_tasks, {|x| x[2] == n_Task})) == 0
  return func_error("�訡�� � �맮�� �����")
endif
cNameIcon := iif(array_tasks[it,3]==NIL, "MAIN_ICON", array_tasks[it,3])
glob_task := n_Task
sys_date := DATE()
c4sys_date := dtoc4(sys_date)
blk_ekran := {|| devpos(maxrow()-2,maxcol()-len(dir_server)), ;
                 devout(upper(dir_server),"W+/N*") }
main_menu := {}
main_message := {}
first_menu := {}
first_message := {}
func_menu := {}
cmain_menu := {}
put_icon(array_tasks[it,1]+" [��� + ���� ࠡ��� ��]"+__s_version,cNameIcon)
SETCOLOR(color1)
FillScreen(p_char_screen,p_color_screen)
do case
  case glob_task == X_REGIST //
    fl := begin_task_regist()
    aadd(cmain_menu,1)
    aadd(main_menu," ~���������� ")
    aadd(main_message,"���������� ���㫠�୮-����������᪮�� ��०�����")
    aadd(first_menu, {"~������஢����",;
                      "~����������",0,;
                      "~��������",;
                      "�㡫����騥�� ~�����",0; // "~����";
                     })
    aadd(first_message, { ;
       "������஢���� ���ଠ樨 �� ����窨 ���쭮�� � ����� ���⪠ ���",;
       "���������� � ����⥪� ���ଠ樨 � ���쭮�",;
       "�������� ����窨 ���쭮�� �� ����⥪�",;
       "���� � 㤠����� �㡫�������� ����ᥩ � ����⥪�"; // "���� ������ �� ����";
      })
    aadd(func_menu, {"regi_kart()",;
                     "append_kart()",;
                     "view_kart(2)",;
                     "dubl_zap()"; //  "func_msek()";
                    })
    if glob_mo[_MO_IS_UCH]
      aadd(first_menu[1],"�ਪ९�񭭮� ~��ᥫ����")
      aadd(first_message[1],"����� � �ਪ९��� ��ᥫ�����")
      aadd(func_menu[1],"pripisnoe_naselenie()")
    endif
    aadd(first_menu[1],"~��ࠢ�� ���")
    aadd(first_message[1],"���� � �ᯥ�⪠ �ࠢ�� � �⮨���� ��������� ����樭᪮� ����� � ��� ���")
    aadd(func_menu[1],"f_spravka_OMS()")
    //
    aadd(cmain_menu,34)
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ�� / ����� ����⨪� �� ��樥�⠬")
    aadd(first_menu, {"����⨪� �� �ਥ~���",;
                      "���ଠ�� �� ~����⥪�",;
                      "~�������ਠ��� ����";
                     })
    aadd(first_message, { ;
       "����⨪� �� ��ࢨ�� ��祡�� �ਥ���",;
       "��ᬮ�� / ����� ᯨ᪮� �� ��⥣���, ��������, ࠩ����, ���⪠�,...",;
       "�������ਠ��� ���� � ����⥪�";
      })
    aadd(func_menu, {"regi_stat()",;
                     "prn_kartoteka()",;
                     "ne_real()" ;       //     "reg_poisk()";
                    })                   //    })
    //
    aadd(cmain_menu,51)
    aadd(main_menu," ~��ࠢ�筨�� ")
    aadd(main_message,"������� �ࠢ�筨���")
    aadd(first_menu, {"��ࢨ�� ~�ਥ��",0,;
                      "~����ன�� (㬮�砭��)";
                     })
    aadd(first_message, { ;  // �ࠢ�筨��
       "������஢���� �ࠢ�筨�� �� ��ࢨ�� ��祡�� �ਥ���",;
       "����ன�� ���祭�� �� 㬮�砭��";
      })
    aadd(func_menu, {"edit_priem()",;
                     "regi_nastr(2)";
                    })
    if is_r_mu  // ॣ���� �죮⭨���
      Ins_Array(main_menu, 2, " ~�죮⭨�� ")
      Ins_Array(main_message, 2, "���� 祫����� � 䥤�ࠫ쭮� ॣ���� �죮⭨���")
      Ins_Array(cmain_menu, 2, 19)
      Ins_Array(first_menu, 2,;
                {"~����","~�������ਠ��� ����",0,'"~���" �죮⭨��'})
      Ins_Array(first_message, 2,;
                {"���� 祫����� � ॣ���� �죮⭨���, ����� ���.����� �� �ଥ 025/�-04",;
                 "�������ਠ��� ���� �� ॣ����� �죮⭨���",;
                 "������� ���ଠ�� �� ��襬� ���⨭����� �� 䥤�ࠫ쭮�� ॣ���� �죮⭨���"})
      Ins_Array(func_menu, 2, {"r_mu_human()","r_mu_poisk()","r_mu_svod()"})
    endif
  case glob_task == X_PPOKOJ  //
    fl := begin_task_ppokoj()
    aadd(cmain_menu,1)
    aadd(main_menu," ~���� ����� ")
    aadd(main_message,"���� ������ � ��񬭮� ����� ��樮���")
    aadd(first_menu, {"~����������",;
                      "~������஢����",0,;
                      "� ��㣮� ~�⤥�����",0,;
                      "~��������"})
    aadd(first_message, {;
        "���������� ���ਨ �������",;
        "������஢���� ���ਨ ������� � ����� ����樭᪮� � ���.�����",;
        "��ॢ�� ���쭮�� �� ������ �⤥����� � ��㣮�",;
        "�������� ���ਨ �������";
      } )
    aadd(func_menu, {"add_ppokoj()",;
                     "edit_ppokoj()",;
                     "ppokoj_perevod()",;
                     "del_ppokoj()"})
    aadd(cmain_menu,34)
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ�� / ����� ����⨪� �� �����")
    aadd(first_menu, {"~��ୠ� ॣ����樨",;
                      "��ୠ� �� ~������",0,;
                      "~������� ���ଠ��",0,;
                      "~��ॢ�� �/� �⤥����ﬨ",0,;
                      "���� ~�訡��"})
    aadd(first_message, {;
        "��ᬮ��/����� ��ୠ�� ॣ����樨 ��樮����� ������",;
        "��ᬮ��/����� ��ୠ�� ॣ����樨 ��樮����� ������ �� ������",;
        "������ ������⢠ �ਭ���� ������ � ࠧ������ �� �⤥�����",;
        "����祭�� ���ଠ樨 � ��ॢ��� ����� �⤥����ﬨ",;
        "���� �訡�� �����";
      } )
    aadd(func_menu, {"pr_gurnal_pp()",;
                     "z_gurnal_pp()",;
                     "pr_svod_pp()",;
                     "pr_perevod_pp()",;
                     "pr_error_pp()"})
    aadd(cmain_menu,51)
    aadd(main_menu," ~��ࠢ�筨�� ")
    aadd(main_message,"������� �ࠢ�筨���")
    aadd(first_menu, {"~�⮫�",;
                      "~����ன��"})
    aadd(first_message, {;
        "����� � �ࠢ�筨��� �⮫��",;
        "����ன�� ���祭�� �� 㬮�砭��";
      } )
    aadd(func_menu, {"f_pp_stol()",;
                     "pp_nastr()"})
  case glob_task == X_OMS  //
    fl := begin_task_oms()
    aadd(cmain_menu,1)
    aadd(main_menu," ~��� ")
    aadd(main_message,"���� ������ �� ��易⥫쭮�� ����樭᪮�� ���客����")
    aadd(first_menu, {"~����������",;
                      "~������஢����",;
                      "�~����� ��砨",;
                      "����� ~�⤥�����",;
                      "~��������"} )
    aadd(first_message, { ;
        "���������� ���⪠ ��� ��祭�� ���쭮��",;
        "������஢���� ���⪠ ��� ��祭�� ���쭮��",;
        "����������, ��ᬮ��, 㤠����� ������� ��砥�",;
        "������஢���� ���⪠ ��� ��祭�� ���쭮�� � ᬥ��� �⤥�����",;
        "�������� ���⪠ ��� ��祭�� ���쭮��";
      } )
    aadd(func_menu, {"oms_add()",;
                     "oms_edit()",;
                     "oms_double()",;
                     "oms_smena_otd()",;
                     "oms_del()"} )
    if yes_vypisan == B_END
      aadd(first_menu[1], "~�����襭�� ��祭��")
      aadd(first_message[1], "������ ࠡ��� � �����襭��� ��祭��")
      aadd(func_menu[1], "oms_zav_lech()")
    endif
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~����⥪�")
    aadd(first_message[1], "����� � ����⥪��")
    aadd(func_menu[1], "oms_kartoteka()")
    aadd(first_menu[1], 0)
    aadd(first_menu[1],"~��ࠢ�� ���")
    aadd(first_message[1],"���� � �ᯥ�⪠ �ࠢ�� � �⮨���� ��������� ����樭᪮� ����� � ��� ���")
    aadd(func_menu[1],"f_spravka_OMS()")
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~������� ")
    aadd(main_message,"����, ����� � ��� ॥��஢ ��砥�")
    aadd(first_menu, {"��~��ઠ",;
                      "~���⠢�����",;
                      "~��ᬮ��",0,;
                      "��~����",0})
    aadd(first_message, { ;
        "�஢�ઠ ��। ��⠢������ ॥��� ��砥�",;
        "���⠢����� ॥��� ��砥�",;
        "��ᬮ�� ॥��� ��砥�, ��ࠢ�� � �����",;
        "������ ॥��� ��砥�"})
    aadd(func_menu, {"verify_OMS()",;
                     "create_reestr()",;
                     "view_list_reestr()",;
                     "vozvrat_reestr()"})
    if glob_mo[_MO_IS_UCH]
      aadd(first_menu[2], "�~ਪ९�����")
      aadd(first_message[2], "��ᬮ�� 䠩��� �ਪ९����� (� �⢥⮢ �� ���), ������ 䠩��� ��� �����")
      aadd(func_menu[2], "view_reestr_pripisnoe_naselenie()")
      aadd(first_menu[2], "~��९�����")
      aadd(first_message[2], "��ᬮ�� ����祭��� �� ����� 䠩��� ��९�����")
      aadd(func_menu[2], "view_otkrep_pripisnoe_naselenie()")
    endif
    aadd(first_menu[2], "~����⠩�⢠")
    aadd(first_message[2], "��ᬮ��, ������ � �����, 㤠����� 䠩��� 室�⠩��")
    aadd(func_menu[2], "view_list_hodatajstvo()")
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~��� ")
    aadd(main_message,"��ᬮ��, ����� � ��� ��⮢ �� ���")
    aadd(first_menu, {"~�⥭�� �� �����",;
                      "���᮪ ~��⮢",;
                      "~���������",;
                      "~���� ����஫�",;
                      "������ ~���㬥���",0,;
                      "~��稥 ���"} )
    aadd(first_message, { ;
        "�⥭�� ���ଠ樨 �� ����� (�� ���)",;
        "��ᬮ�� ᯨ᪠ ��⮢ �� ���, ������ ��� �����, ����� ��⮢",;
        "�⬥⪠ � ॣ����樨 ��⮢ � �����",;
        "����� � ��⠬� ����஫� ��⮢ (� ॥��ࠬ� ��⮢ ����஫�)",;
        "����� � �����묨 ���㬥�⠬� �� ����� (� ॥��ࠬ� ������� ���㬥�⮢)",;
        "����� � ��稬� ��⠬� (ᮧ�����, ।���஢����, ������)",;
      } )
    aadd(func_menu, {"read_from_tf()",;
                     "view_list_schet()",;
                     "registr_schet()",;
                     "akt_kontrol()",;
                     "view_pd()",;
                     "other_schets()"} )
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ�� / ����� ���� �ࠢ�筨��� � ����⨪�")
    aadd(first_menu, {"���� ~���",;
                      "~����⨪�",;
                      "����-~�����",;
                      "~�஢�ન",;
                      "��ࠢ�~筨��",0,;
                      "����� ~�������"} )
    aadd(first_message, { ;
        "��ᬮ�� / ����� ���⮢ ��� ������",;
        "��ᬮ�� / ����� ����⨪�",;
        "����⨪� �� ����-������",;
        "������� �஢�ન",;
        "��ᬮ�� / ����� ���� �ࠢ�筨���",;
        "��ᯥ�⪠ �ᥢ�������� �������";
      } )
    aadd(func_menu, {"o_list_uch()",;
                     "e_statist()",;
                     "pz_statist()",;
                     "o_proverka()",;
                     "o_sprav()",;
                     "prn_blank()"} )
    if yes_parol
      aadd(first_menu[4], "����� ~�����஢")
      aadd(first_message[4], "����⨪� �� ࠡ�� �����஢ �� ���� � �� �����")
      aadd(func_menu[4], "st_operator()")
    endif
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~��ᯠ��ਧ��� ")
    aadd(main_message,"��ᯠ��ਧ���, ��䨫��⨪�, ����ᬮ��� � ��ᯠ��୮� �������")
    aadd(first_menu, {"~��ᯠ��ਧ��� � ���ᬮ���",0,;
                      "��ᯠ��୮� ~�������"} )
    aadd(first_message, { ;
        "��ᯠ��ਧ���, ��䨫��⨪� � ����ᬮ���",;
        "��ᯠ��୮� �������";
      } )
    aadd(func_menu, {"dispanserizacia()",;
                     "disp_nabludenie()"} )
  case glob_task == X_263 //
    fl := begin_task_263()
    if is_napr_pol
      aadd(cmain_menu,1)
      aadd(main_menu," ~����������� ")
      aadd(main_message,"���� / ।���஢���� ���ࠢ����� �� ��ᯨ⠫����� �� �����������")
      aadd(first_menu, {;//"~�஢�ઠ",0,;
                        "~���ࠢ�����",;
                        "~���㫨஢����",;
                        "~���ନ஢����",0,;
                        "~�������� �����",0,;
                        "~����⥪�"} )
      aadd(first_message, { ;//"�஢�ઠ ⮣�, �� ��� �� ᤥ���� � �����������",;
          "���� / ।���஢���� / ��ᬮ�� ���ࠢ����� �� ��ᯨ⠫����� �� �����������",;
          "���㫨஢���� �믨ᠭ��� ���ࠢ����� �� ��ᯨ⠫����� �� �����������",;
          "���ନ஢���� ���� ��樥�⮢ � ��� �।���饩 ��ᯨ⠫���樨",;
          "��ᬮ�� ������⢠ ᢮������ ���� �� ��䨫� � ��樮����/������� ��樮����",;
          "����� � ����⥪��";
        } )
      aadd(func_menu, {;//"_263_p_proverka()",;
                       "_263_p_napr()",;
                       "_263_p_annul()",;
                       "_263_p_inform()",;
                       "_263_p_svob_kojki()",;
                       "_263_kartoteka(1)"} )
    endif
    if is_napr_stac
      aadd(cmain_menu,15)
      aadd(main_menu," ~��樮��� ")
      aadd(main_message,"���� ���� ��ᯨ⠫���樨, ���� ��ᯨ⠫���஢����� � ����� �� ��樮����")
      aadd(first_menu, {;//"~�஢�ઠ",0,;
                        "~��ᯨ⠫���樨",;
                        "~�믨᪠ (���⨥)",;
                        "~���ࠢ�����",;
                        "~���㫨஢����",0,;
                        "~�������� �����",0,;
                        "~����⥪�"} )
      aadd(first_message, { ;// "�஢�ઠ ⮣�, �� ��� �� ᤥ���� � ��樮���",;
          "���������� / ।���஢���� ��ᯨ⠫���権 � ��樮���",;
          "�믨᪠ (���⨥) ��樥�� �� ��樮���",;
          "���᮪ ���ࠢ�����, �� ����� ��� �� �뫮 ��ᯨ⠫���樨",;
          "���㫨஢���� ���ࠢ�����, ����㯨��� �� ���������� �१ �����",;
          "���� / ।���஢���� ������⢠ ᢮������ ���� �� ��䨫� � ��樮���",;
          "����� � ����⥪��";
        } )
      aadd(func_menu, {;//"_263_s_proverka()",;
                       "_263_s_gospit()",;
                       "_263_s_vybytie()",;
                       "_263_s_napr()",;
                       "_263_s_annul()",;
                       "_263_s_svob_kojki()",;
                       "_263_kartoteka(2)"} )
    endif
    aadd(cmain_menu,29)
    aadd(main_menu," ~� ����� ")
    aadd(main_message,"��ࠢ�� � ����� 䠩��� ������ (��ᬮ�� ��ࠢ������ 䠩���)")
    aadd(first_menu, {"~�஢�ઠ ��। ��⠢������ ����⮢",;
                      "~���⠢����� ����⮢ ��� ��ࠢ�� � ��",;
                      "��ᬮ�� ��⮪���� ~�����",0})
    aadd(first_message,  { ;   // ���ଠ��
          "�஢�ઠ ���ଠ樨 ��। ��⠢������ ����⮢ � ��ࠢ��� � �����",;
          "���⠢����� ���ଠ樮���� ����⮢ ��� ��ࠢ�� � �����",;
          "��ᬮ�� ��⮪���� ��⠢����� ���ଠ樮���� ����⮢ ��� ��ࠢ�� � �����";
         })
    aadd(func_menu, {;    // ���ଠ��
          "_263_to_proverka()",;
          "_263_to_sostavlenie()",;
          "_263_to_protokol()";
         })
    k := len(first_menu)
    if is_napr_pol
      aadd(first_menu[k], "I0~1-�믨ᠭ�� ���ࠢ�����")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � �믨ᠭ�묨 ���ࠢ����ﬨ")
      aadd(func_menu[k], "_263_to_I01()")
    endif
    aadd(first_menu[k], "I0~3-���㫨஢���� ���ࠢ�����")
    aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ���㫨஢���묨 ���ࠢ����ﬨ")
    aadd(func_menu[k], "_263_to_I03()")
    if is_napr_stac
      aadd(first_menu[k], "I0~4-��ᯨ⠫���樨 �� ���ࠢ�����")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ �� ���ࠢ�����")
      aadd(func_menu[k], "_263_to_I04(4)")
      //
      aadd(first_menu[k], "I0~5-����७�� ��ᯨ⠫���樨")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ ��� ���ࠢ����� (�����.� ����.)")
      aadd(func_menu[k], "_263_to_I04(5)")
      //
      aadd(first_menu[k], "I0~6-���訥 ��樥���")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ᢥ����ﬨ � ����� ��樥���")
      aadd(func_menu[k], "_263_to_I06()")
    endif
    aadd(first_menu[k],0)
    aadd(first_menu[k], "~����ன�� ��⠫����")
    aadd(first_message[k], "����ன�� ��⠫���� ������ - �㤠 �����뢠�� ᮧ����� ��� ����� 䠩��")
    aadd(func_menu[k], "_263_to_nastr()")
    //
    aadd(cmain_menu,39)
    aadd(main_menu," �� ~����� ")
    aadd(main_message,"����祭�� �� ����� 䠩��� ������ � ��ᬮ�� ����祭��� 䠩���")
    aadd(first_menu, {"~�⥭�� �� �����",;
                      "~��ᬮ�� ��⮪���� �⥭��",0})
    aadd(first_message,  { ;   // ���ଠ��
          "����祭�� �� ����� 䠩��� ������ (���ଠ樮���� ����⮢)",;
          "��ᬮ�� ��⮪���� �⥭�� ���ଠ樮���� ����⮢ �� �����";
         })
    aadd(func_menu, {;
          "_263_from_read()",;
          "_263_from_protokol()";
         })
    k := len(first_menu)
    if is_napr_stac
      aadd(first_menu[k], "I0~1-����祭�� ���ࠢ�����")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ����祭�묨 ���ࠢ����ﬨ �� ����������")
      aadd(func_menu[k], "_263_from_I01()")
    endif
    aadd(first_menu[k], "I0~3-���㫨஢���� ���ࠢ�����")
    aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ���㫨஢���묨 ���ࠢ����ﬨ")
    aadd(func_menu[k], "_263_from_I03()")
    if is_napr_pol
      aadd(first_menu[k], "I0~4-��ᯨ⠫���樨 �� ���ࠢ�����")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ �� ���ࠢ�����")
      aadd(func_menu[k], "_263_from_I04()")
      //
      aadd(first_menu[k], "I0~5-����७�� ��ᯨ⠫���樨")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ ��� ���ࠢ����� (�����.� ����.)")
      aadd(func_menu[k], "_263_from_I05()")
      //
      aadd(first_menu[k], "I0~6-���訥 ��樥���")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ᢥ����ﬨ � ����� ��樥���")
      aadd(func_menu[k], "_263_from_I06()")
      //
      aadd(first_menu[k], "I0~7-����稥 ᢮������ ����")
      aadd(first_message[k], "���᮪ ���ଠ樮���� ����⮢ � ᢥ����ﬨ � ����稨 ᢮������ ����")
      aadd(func_menu[k], "_263_from_I07()")
    endif
    aadd(first_menu[k],0)
    aadd(first_menu[k], "~����ன�� ��⠫����")
    aadd(first_message[k], "����ன�� ��⠫���� ������ - ��㤠 ����뢠�� ����祭�� �� ����� 䠩��")
    aadd(func_menu[k], "_263_to_nastr()")
    //
  case glob_task == X_PLATN //
    fl := begin_task_plat()
    aadd(cmain_menu,1)
    aadd(main_menu," ~����� ��㣨 ")
    aadd(main_message,"���� / ।���஢���� ������ �� ���⮢ ��� ������ ����樭᪨� ���")
    aadd(first_menu, {"~���� ������"} )
    aadd(first_message, {"����������/������஢���� ���⪠ ��� ��祭�� ���⭮�� ���쭮��"} )
    aadd(func_menu, {"kart_plat()"} )
    if glob_pl_reg == 1
      aadd(first_menu[1], "~����/।-��")
      aadd(first_message[1], "����/������஢���� ���⮢ ��� ��祭�� ������ ������")
      aadd(func_menu[1], "poisk_plat()")
    endif
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~����⥪�")
    aadd(first_message[1], "����� � ����⥪��")
    aadd(func_menu[1], "oms_kartoteka()")
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~����� ��� � �/�")
    aadd(first_message[1], "����/।���஢���� ����� �� ����������� � ���஢��쭮�� ���.���客����")
    aadd(func_menu[1], "oplata_vz()")
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~�����⨥ �/���")
    aadd(first_message[1], "������� ���� ��� (���� �ਧ��� ������� � ���� ���)")
    aadd(func_menu[1], "close_lu()")
    //
    aadd(cmain_menu,34)
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ�� / ����� ���� �ࠢ�筨��� � ����⨪�")
    aadd(first_menu, {"~����⨪�",;
                      "���~��筨��",;
                      "~�஢�ન"})
    aadd(first_message,  { ;   // ���ଠ��
          "��ᬮ�� ����⨪�",;
          "��ᬮ�� ���� �ࠢ�筨���",;
          "������� �஢���� ०���";
         })
    aadd(func_menu, {;    // ���ଠ��
          "Po_statist()",;
          "o_sprav()",;
          "Po_proverka()";
         })
    if glob_kassa == 1
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "����� � ~���ᮩ")
      aadd(first_message[2], "���ଠ�� �� ࠡ�� � ���ᮩ")
      aadd(func_menu[2], "inf_fr()")
    endif
    if yes_parol
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "����� ~�����஢")
      aadd(first_message[2], "����⨪� �� ࠡ�� �����஢ �� ���� � �� �����")
      aadd(func_menu[2], "st_operator()")
    endif
    //
    aadd(cmain_menu,50)
    aadd(main_menu," ~��ࠢ�筨�� ")
    aadd(main_message,"������� �ࠢ�筨���")
    aadd(first_menu,{})
    aadd(first_message,{})
    aadd(func_menu,{})
    if is_oplata != 7
      aadd(first_menu[3], "~��������")
      aadd(first_message[3], "��ࠢ�筨� ������� ��� ������ ���")
      aadd(func_menu[3], "s_pl_meds(1)")
      //
      aadd(first_menu[3], "~�����ન")
      aadd(first_message[3], "��ࠢ�筨� ᠭ��ப ��� ������ ���")
      aadd(func_menu[3], "s_pl_meds(2)")
    endif
    aadd(first_menu[3], "�।����� (�/~����)")
    aadd(first_message[3], "��ࠢ�筨� �।���⨩, ࠡ����� �� �����������")
    aadd(func_menu[3], "edit_pr_vz()")
    //
    aadd(first_menu[3], "~���஢���� ���") ; aadd(first_menu[3], 0)
    aadd(first_message[3], "��ࠢ�筨� ���客�� ��������, �����⢫���� ���஢��쭮� ���.���客����")
    aadd(func_menu[3], "edit_d_smo()")
    //
    aadd(first_menu[3], "��㣨 �� ���~�")
    aadd(first_message[3], "������஢���� �ࠢ�筨�� ���, 業� �� ����� ������� � �����-� ����")
    aadd(func_menu[3], "f_usl_date()")
    if glob_kassa == 1
      aadd(first_menu[3], 0)
      aadd(first_menu[3], "����� � ~���ᮩ")
      aadd(first_message[3], "����ன�� ࠡ��� � ���ᮢ� �����⮬")
      aadd(func_menu[3], "fr_nastrojka()")
    endif
  case glob_task == X_ORTO  //
    fl := begin_task_orto()
    aadd(cmain_menu,1)
    aadd(main_menu," ~��⮯���� ")
    aadd(main_message,"���� ������ �� ��⮯����᪨� ��㣠� � �⮬�⮫����")
    aadd(first_menu, {"~����⨥ ���鸞",;
                      "~�����⨥ ���鸞",0,;
                      "~����⥪�"})
    aadd(first_message,  {;
         "����⨥ ���鸞-������ (���������� ���⪠ ��� ��祭�� ���쭮��)",;
         "�����⨥ ���鸞-������ (।���஢���� ���⪠ ��� ��祭�� ���쭮��)",;
         "����� � ����⥪��"} )
    aadd(func_menu, {"kart_orto(1)",;
                     "kart_orto(2)",;
                     "oms_kartoteka()"})
    //
    aadd(cmain_menu,34)
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ�� / ����� ���� �ࠢ�筨��� � ����⨪�")
    aadd(first_menu, {"~����⨪�",;
                      "���~��筨��",;
                      "~�஢�ન"})
    aadd(first_message,  { ;   // ���ଠ��
          "��ᬮ�� ����⨪�",;
          "��ᬮ�� ���� �ࠢ�筨���",;
          "������� �஢���� ०���";
         })
    aadd(func_menu, {;    // ���ଠ��
          "Oo_statist()",;
          "o_sprav(-5)",;   // X_ORTO = 5
          "Oo_proverka()";
         })
    if glob_kassa == 1   //10.10.14
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "����� � ~���ᮩ")
      aadd(first_message[2], "���ଠ�� �� ࠡ�� � ���ᮩ")
      aadd(func_menu[2], "inf_fr_orto()")
    endif
    if yes_parol
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "����� ~�����஢")
      aadd(first_message[2], "����⨪� �� ࠡ�� �����஢ �� ���� � �� �����")
      aadd(func_menu[2], "st_operator()")
    endif
    //
    aadd(cmain_menu,50)
    aadd(main_menu," ~��ࠢ�筨�� ")
    aadd(main_message,"������� �ࠢ�筨���")
    aadd(first_menu,;
      {"��⮯����᪨� ~��������",;
       "��稭� ~�������",;
       "~��㣨 ��� ��祩",0,;
       "�।����� (�/~����)",;
       "~���஢���� ���",0,;
       "~���ਠ��";
      })
    aadd(first_message,;
      {"������஢���� �ࠢ�筨�� ��⮯����᪨� ���������",;
       "������஢���� �ࠢ�筨�� ��稭 ������� ��⥧��",;
       "����/।���஢���� ���, � ������ �� �������� ��� (�孨�)",;
       "��ࠢ�筨� �।���⨩, ࠡ����� �� �����������",;
       "��ࠢ�筨� ���客�� ��������, �����⢫���� ���஢��쭮� ���.���客����",;
       "��ࠢ�筨� �ਢ������� ��室㥬�� ���ਠ���";
      })
    aadd(func_menu,;
      {"orto_diag()",;
       "f_prich_pol()",;
       "f_orto_uva()",;
       "edit_pr_vz()",;
       "edit_d_smo()",;
       "edit_ort()";
      })
    if glob_kassa == 1
      aadd(first_menu[3], 0)
      aadd(first_menu[3], "����� � ~���ᮩ")
      aadd(first_message[3], "����ன�� ࠡ��� � ���ᮢ� �����⮬")
      aadd(func_menu[3], "fr_nastrojka()")
    endif
  case glob_task == X_KASSA //
    fl := begin_task_kassa()
    //
    aadd(cmain_menu,1)
    aadd(main_menu," ~���� �� ")
    aadd(main_message,"���� ������ � ���� �� �� ����� ��㣠�")
    aadd(first_menu, {"~���� ������",0,;
                      "~����⥪�"})
    aadd(first_message,  {;
         "���������� ���⪠ ��� ��祭�� ���⭮�� ���쭮��",;
         "����/।���஢���� ����⥪� (ॣ�������)"})
    aadd(func_menu, {"kas_plat()",;
                     "oms_kartoteka()"})
    aadd(first_menu[1],0)
    aadd(first_menu[1],"~��ࠢ�� ���")
    aadd(first_message[1],"���� � �ᯥ�⪠ �ࠢ�� � �⮨���� ��������� ����樭᪮� ����� � ��� ���")
    aadd(func_menu[1],"f_spravka_OMS()")
    //
    if is_task(X_ORTO)
      aadd(cmain_menu,cmain_next_pos())
      aadd(main_menu," ~��⮯���� ")
      aadd(main_message,"���� ������ �� ��⮯����᪨� ��㣠�")
      aadd(first_menu,{"~���� ����",;
                       "~������஢���� ���鸞",0,;
                       "~����⥪�"})
      aadd(first_message,{;
           "����⨥ ᫮����� ���鸞 ��� ���� ���⮣� ��⮯����᪮�� ���鸞",;
           "������஢���� ��⮯����᪮�� ���鸞 (� �.�. ������ ��� ������ �����)",;
           "����/।���஢���� ����⥪� (ॣ�������)"})
      aadd(func_menu,{"f_ort_nar(1)",;
                      "f_ort_nar(2)",;
                      "oms_kartoteka()"})
    endif
    //
    aadd(cmain_menu,cmain_next_pos())
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ�� / �����")
    aadd(first_menu, {iif(is_task(X_ORTO),"~����� ��㣨","~����⨪�"),;
                      "������� �~���⨪�",; //10.05
                      "���~��筨��",;
                      "����� � ~���ᮩ"})
    aadd(first_message,  { ;   // ���ଠ��
          "��ᬮ�� / ����� ������᪨� ���⮢ �� ����� ��㣠�",;
          "��ᬮ�� / ����� ᢮���� ������᪨� ���⮢",;
          "��ᬮ�� ���� �ࠢ�筨���",;
          "���ଠ�� �� ࠡ�� � ���ᮩ";
         })
    aadd(func_menu, {;    // ���ଠ��
          "prn_k_plat()",;
          "regi_s_plat()",;
          "o_sprav()",;
          "prn_k_fr()";
         })
    if is_task(X_ORTO)
      Ins_Array(first_menu[3],2,"~��⮯����")
      Ins_Array(first_message[3],2,"��ᬮ�� / ����� ������᪨� ���⮢ �� ��⮯����")
      Ins_Array(func_menu[3],2,"prn_k_ort()")
    endif
    //
    aadd(cmain_menu,cmain_next_pos())
    aadd(main_menu," ~��ࠢ�筨�� ")
    aadd(main_message,"��ᬮ�� / ।���஢���� �ࠢ�筨���")
    aadd(first_menu,{"~��㣨 � ᬥ��� 業�",;
                     "~������ ��㣨",;
                     "����� � ~���ᮩ",0,;
                     "~����ன�� �ணࠬ��"})
    aadd(first_message,{;
         "������஢���� ᯨ᪠ ���, �� ����� ������ ࠧ�蠥��� ।���஢��� 業�",;
         "������஢���� ᯨ᪠ ���, �� �뢮����� � ��ୠ� ������஢ (�᫨ 1 � 祪�)",;
         "����ன�� ࠡ��� � ���ᮢ� �����⮬",;
         "����ன�� �ணࠬ�� (�������� ���祭�� �� 㬮�砭��)"})
    aadd(func_menu,{"fk_usl_cena()",;
                    "fk_usl_dogov()",;
                    "fr_nastrojka()",;
                    "nastr_kassa(2)"})
  case glob_task == X_KEK  //
    if !between(grup_polzovat,1,3)
      n_message({"�������⨬�� ��㯯� ��ᯥ�⨧� (���): "+lstr(grup_polzovat),;
                 '',;
                 '���짮��⥫�, ����� ࠧ�襭� ࠡ���� � �������� "��� ��",',;
                 '����室��� ��⠭����� ��㯯� ��ᯥ�⨧� (�� 1 �� 3)',;
                 '� �������� "������஢���� �ࠢ�筨���" � ०��� "��ࠢ�筨��/��஫�"'},,;
                "GR+/R","W+/R",,,"G+/R")
    else
      fl := begin_task_kek()
      aadd(cmain_menu,1)
      aadd(main_menu," ~��� ")
      aadd(main_message,"���� ������ �� ��� ����樭᪮� �࣠����樨")
      aadd(first_menu, {"~����������",;
                        "~������஢����",;
                        "~��������"} )
      aadd(first_message, { ;
          "���������� ������ �� �����⨧�",;
          "������஢���� ������ �� �����⨧�",;
          "�������� ������ �� �����⨧�";
        } )
      aadd(func_menu, {"kek_vvod(1)",;
                       "kek_vvod(2)",;
                       "kek_vvod(3)"} )
      aadd(cmain_menu,34)
      aadd(main_menu," ~���ଠ�� ")
      aadd(main_message,"��ᬮ�� / ����� ����⨪� �� ��ᯥ�⨧��")
      aadd(first_menu, {"~��ᯥ�⭠� ����",;
                        "�業�� ~����⢠"})
                        //"���ଠ�� �� 201~7 ���",0,;
                        //"���ଠ�� �� 201~6 ���"})
      aadd(first_message, {;
          "��ᯥ�⪠ ��ᯥ�⭮� �����",;
          "��ᯥ�⪠ ࠫ���� ����⮢ �� �楪� ����⢠ ��ᯥ�⨧�"})
          //"��ᯥ�⪠ ࠫ���� ����⮢ �� ������ ��ਮ� 2017 ���",;
          //"��ᯥ�⪠ ࠫ���� ����⮢ �� ������ ��ਮ� 2016 ��� � ����� ࠭���";
        //} )
      aadd(func_menu, {"kek_prn_eks()",;
                       "kek_info2017()"})//,;
                       //"kek_info2016()"})
      aadd(cmain_menu,51)
      aadd(main_menu," ~��ࠢ�筨�� ")
      aadd(main_message,"������� �ࠢ�筨���")
      aadd(first_menu, {"~����ன��"})
      aadd(first_message, {"����ன�� ���祭�� �� 㬮�砭��"} )
      aadd(func_menu, {"kek_nastr()"})
    endif
  case glob_task == X_MO //
    fl := my_mo_begin_task()
    my_mo_f1main()
  case glob_task == X_SPRAV //
    fl := begin_task_sprav()
    //
    aadd(cmain_menu,1)
    aadd(main_menu," ~��ࠢ�筨�� ")
    aadd(main_message,"������஢���� �ࠢ�筨���")
    aadd(first_menu, {"~������� �࣠����樨",;
                      "��ࠢ�筨� ~���",;
                      "�~�稥 �ࠢ�筨��",0,;
                      "~��஫�"} )
    aadd(first_message, { ;
        "������஢���� �ࠢ�筨��� ���ᮭ���, �⤥�����, ��०�����, �࣠����樨",;
        "������஢���� �ࠢ�筨�� ���",;
        "������஢���� ���� �ࠢ�筨���",;
        "������஢���� �ࠢ�筨�� ��஫�� ����㯠 � �ணࠬ��";
      } )
    aadd(func_menu, {"spr_struct_org()",;
                     "edit_spr_uslugi()",;
                     "edit_proch_spr()",;
                     "edit_password()"} )
    //
    aadd(cmain_menu,40)
    aadd(main_menu," ~���ଠ�� ")
    aadd(main_message,"��ᬮ��/����� �ࠢ�筨���")
    aadd(first_menu, {"~��騥 �ࠢ�筨��"} )
    aadd(first_message, { ;
        "��ᬮ��/����� ���� �ࠢ�筨���";
      } )
    aadd(func_menu, {"o_sprav()"} )
  case glob_task == X_SERVIS //
    aadd(cmain_menu,1)
    aadd(main_menu," ~��ࢨ�� ")
    aadd(main_message,"��ࢨ�� � ����ன��")
    //
    if glob_mo[_MO_KOD_TFOMS] == '395301' // ����設 ����
      aadd(first_menu, {"~�஢�ઠ 楫��⭮��",0,;
                        "��������� ~業 ���",0,;
                        "~������",;
                        "~��ᯮ��",;
                        "~���ਠ��"} )
      aadd(first_message, { ;
          "�஢�ઠ 楫��⭮�� ���� ������ �� 䠩�-�ࢥ�",;
          "��������� 業 �� ��㣨 � ᮮ⢥��⢨� � �ࠢ�筨��� ��� �����",;
          "������� ��ਠ��� ������ �� ��㣨� �ணࠬ�",;
          '������� ��ਠ��� ��ᯮ�� � ��㣨� �ணࠬ��/�࣠����樨',;
          "��ࠢ�筨� �ਢ������� ��室㥬�� ���ਠ���";
        } )
      aadd(func_menu, {"prover_dbf(,.f.,(tip_polzovat==0))",;
                       "Change_Cena_OMS()",;
                       "f_import()",;
                       "f_export()",;
                       "edit_ort()"} )

    else
      aadd(first_menu, {"~�஢�ઠ 楫��⭮��",0,;
                        "��������� ~業 ���",0,;
                        "~������",;
                        "~��ᯮ��"} )
      aadd(first_message, { ;
          "�஢�ઠ 楫��⭮�� ���� ������ �� 䠩�-�ࢥ�",;
          "��������� 業 �� ��㣨 � ᮮ⢥��⢨� � �ࠢ�筨��� ��� �����",;
          "������� ��ਠ��� ������ �� ��㣨� �ணࠬ�",;
          '������� ��ਠ��� ��ᯮ�� � ��㣨� �ணࠬ��/�࣠����樨';
        } )
      aadd(func_menu, {"prover_dbf(,.f.,(tip_polzovat==0))",;
                       "Change_Cena_OMS()",;
                       "f_import()",;
                       "f_export()"} )
    endif
    //
    aadd(cmain_menu,20)
    aadd(main_menu," ~����ன�� ")
    aadd(main_message,"����ன��")
    aadd(first_menu, {"~��騥 ����ன��",0,;
                      "��ࠢ�筨�� ~�����",0,;
                      "~����祥 ����"} )
    aadd(first_message, { ;
        "��騥 ����ன�� ������ �����",;
        "����ன�� ᮤ�ন���� �ࠢ�筨��� ����� (㬥��襭�� ������⢠ ��ப)",;
        "����ன�� ࠡ�祣� ����";
      } )
    aadd(func_menu, {"nastr_all()",;
                     "nastr_sprav_FFOMS()",;
                     "nastr_rab_mesto()"} )
    aadd(cmain_menu,50)
    aadd(main_menu," ��稥 ~������ ")
    aadd(main_message,"����� �ᯮ��㥬� (���ॢ訥) ������")
    //
    if glob_mo[_MO_KOD_TFOMS] == '395301' // ����設 ����
      aadd(first_menu, { ;
                  "~���� ��樥���",;
                  "���ଠ�� � ������⢥ 㤠���� ~�㡮�",;
                  "~����୨����",;
                  "���쬮 �792 �����~�",;
                  "�����ਭ~� �� ����� ���.�����",;
                  "����䮭��ࠬ�� �~15 �� ��",;
                  "�������� ��� �-�� ~25 � ���.業�� 2",;
                  "~���室 ���ਠ���"})
      aadd(first_message, { ;
                  "��ୠ� ॣ����樨 ����� ��樥�⮢",;
                  "���ଠ�� � ������⢥ 㤠���� ����ﭭ�� �㡮� � 2005 �� 2015 ����",;
                  "����⨪� �� ����୨��樨",;
                  "�����⮢�� ��� ᮣ��᭮ �ਫ������ � ����� ������ �792 �� 16.06.2017�.",;
                  "�����ਭ� �� ����� ����樭᪮� ����� ��� ������ ��ࠢ���࠭���� ��",;
                  "���ଠ�� �� ��樮��୮�� ��祭�� ��� �������� ������ �� 2017 ���",;
                  "�������� � 䠪��᪨� ������ �� �������� ����樭᪮� �����",;
                  "��������� �� ��室� ���ਠ��� �� ��⥧�஢����"})
      aadd(func_menu, {'run_my_hrb("mo_hrb1","i_new_boln()")',;
                       'run_my_hrb("mo_hrb1","i_kol_del_zub()")',;
                       "modern_statist()",;
                       'run_my_hrb("mo_hrb1","forma_792_MIAC()")',;
                       'run_my_hrb("mo_hrb1","monitoring_vid_pom()")',;
                       'run_my_hrb("mo_hrb1","phonegram_15_kz()")',;
                       'run_my_hrb("mo_hrb1","b_25_perinat_2()")',;
                       'Ort_OMS_material()'} )
    else
      aadd(first_menu, { ;
                  "~���� ��樥���",;
                  "���ଠ�� � ������⢥ 㤠���� ~�㡮�",;
                  "~����୨����",;
                  "���쬮 �792 �����~�",;
                  "�����ਭ~� �� ����� ���.�����",;
                  "����䮭��ࠬ�� �~15 �� ��",;
                  "�������� ��� �-�� ~25 � ���.業�� 2"})
      aadd(first_message, { ;
                  "��ୠ� ॣ����樨 ����� ��樥�⮢",;
                  "���ଠ�� � ������⢥ 㤠���� ����ﭭ�� �㡮� � 2005 �� 2015 ����",;
                  "����⨪� �� ����୨��樨",;
                  "�����⮢�� ��� ᮣ��᭮ �ਫ������ � ����� ������ �792 �� 16.06.2017�.",;
                  "�����ਭ� �� ����� ����樭᪮� ����� ��� ������ ��ࠢ���࠭���� ��",;
                  "���ଠ�� �� ��樮��୮�� ��祭�� ��� �������� ������ �� 2017 ���",;
                  "�������� � 䠪��᪨� ������ �� �������� ����樭᪮� �����"})
      aadd(func_menu, {'run_my_hrb("mo_hrb1","i_new_boln()")',;
                       'run_my_hrb("mo_hrb1","i_kol_del_zub()")',;
                       "modern_statist()",;
                       'run_my_hrb("mo_hrb1","forma_792_MIAC()")',;
                       'run_my_hrb("mo_hrb1","monitoring_vid_pom()")',;
                       'run_my_hrb("mo_hrb1","phonegram_15_kz()")',;
                       'run_my_hrb("mo_hrb1","b_25_perinat_2()")'} )
    endif
  case glob_task == X_COPY //
    aadd(cmain_menu,1)
    aadd(main_menu," ~����ࢭ�� ����஢���� ")
    aadd(main_message,"����ࢭ�� ����஢���� ���� ������")
    aadd(first_menu, {"����஢���� ~���� ������"})
    aadd(first_message, { ;
        "����ࢭ�� ����஢���� ���� ������";
      } )
    aadd(func_menu, {"m_copy_DB()"})
  case glob_task == X_INDEX //
    aadd(cmain_menu,1)
    aadd(main_menu," ~��२�����஢���� ")
    aadd(main_message,"��२�����஢���� ���� ������")
    aadd(first_menu, {"~��२�����஢����"} )
    aadd(first_message, { ;
        "��२�����஢���� ���� ������";
      } )
    aadd(func_menu, {"m_index_DB()"} )
endcase
// ��᫥���� ���� ��� ��� ���� � � ��
aadd(cmain_menu,maxcol()-9)
aadd(main_menu," ����~�� ")
aadd(main_message,"������, ����ன�� �ਭ��")
aadd(first_menu, {"~����� � �ணࠬ��",;
                  "����~��",;
                  "~�ਭ��",0,;
                  "��⥢�� ~������",;
                  "~�訡��"})
aadd(first_message, { ;
   "�뢮� �� ��࠭ ᮤ�ঠ��� 䠩�� README.RTF � ⥪�⮬ ������ � �ணࠬ��",;
   "�뢮� �� ��࠭ ��࠭� �����",;
   "��⠭���� ����� �ਭ��",;
   "����� ��ᬮ�� - �� ��室���� � ����� � � ����� ०���",;
   "��ᬮ�� 䠩�� �訡��"})
aadd(func_menu, {"readme2wordpad()",;
                 "m_help()",;
                 "ust_printer(T_ROW)",;
                 "net_monitor(T_ROW,T_COL-7,(tip_polzovat==0))",;
                 "view_errors()"})
// ������� ��२�����஢���� �������� 䠩��� ����� �����
if eq_any(glob_task,X_PPOKOJ,X_OMS,X_PLATN,X_ORTO,X_KASSA,X_KEK,X_263)
  aadd(atail(first_menu),0)
  aadd(atail(first_menu),"���~������஢����")
  aadd(atail(first_message),'��२�����஢���� ��� ���� ������ ��� ����� "'+array_tasks[ind_task(),5]+'"')
  aadd(atail(func_menu),"pereindex_task()")
endif
if fl
  G_SPlus(f_name_task())   // ���� 1 ���짮��⥫� ���� � ������
  func_main(.t.,blk_ekran)
  G_SMinus(f_name_task())  // ����� 1 ���짮��⥫� (��襫 �� �����)
endif
return NIL

***** 25.05.13 �������� ᫥������ ������ ��� �������� ���� �����
Static Function cmain_next_pos(n)
DEFAULT n TO 5
return atail(cmain_menu)+len(atail(main_menu))+n

***** 18.08.18
Function readme2wordpad(rtf_file)
DEFAULT rtf_file TO exe_dir+cslash+'README.RTF'
ShellExecute(GetDeskTopWindow(),;
             'open',;
             'wordpad.exe',;
             rtf_file,;
             ,;
             SW_SHOWNORMAL)
return NIL

*

*****
Function m_help()
Local tmp_help, pt
tmp_help := chm_help_code
chm_help_code := 100  // ?????
f_help()
chm_help_code := tmp_help
return NIL

*

***** 24.10.17
FUNCTION f_first(is_create)
Local is_cur_dir := .t.
REQUEST HB_CODEPAGE_RU866
HB_CDPSELECT("RU866")
REQUEST HB_LANG_RU866
HB_LANGSELECT("RU866")

REQUEST DBFNTX
RDDSETDEFAULT("DBFNTX")

//SET(_SET_EVENTMASK,INKEY_KEYBOARD)
SET SCOREBOARD OFF
SET EXACT ON
SET DATE GERMAN
SET WRAP ON
SET CENTURY ON
SET EXCLUSIVE ON
SET DELETED ON
setblink(.f.)

PUBLIC help_code := -1

PUBLIC yes_color := .t.

PUBLIC color0, color1, cColorWait, cColorSt2Msg, cColorStMsg,;
       cCalcMain, cHelpCMain, cColorText,;
       cHelpCTitle, cHelpCStatus, cDataCScr, cDataCGet, cDataCSay,;
       cDataCMenu, color13, color14, cColorSt1Msg, cDataPgDn, col_tit_popup,;
       color5, color8, col1menu := "", col2menu := "",;
       color_uch, col_tit_uch
Public n_list := 1, tek_stroke := 0, fp
Public p_color_screen := "W/N*", p_char_screen := " " // ���������� ��࠭�
Public c__cw := "N+/N" // 梥� ⥭��
//
color0 := "N/BG,W+/N"
color1 := "W+/B,W+/R"
color_uch := "B/BG,W+/B" ; col_tit_uch := "B+/BG"
col1menu := color0+",B/BG,BG+/N"
col2menu := color0+",B/BG,BG+/N"
col_tit_popup := "B/BG"
//
cColorStMsg := "W+/R,,,,B/W"                 //    Stat_msg
cColorSt1Msg := "W+/R,,,,B/W"                //    Stat_msg
cColorSt2Msg := "GR+/R,,,,B/W"               //    Stat_msg
cColorWait := "W+/R*,,,,B/W"                 //    ����
//
cCalcMain := "N/W,GR+/R"                     //    ��������
//
cColorText := "W+/N,BG+/N,,,B/W"
//
cHelpCMain := "W+/RB,W+/N,,,B/W"             //    ������
cHelpCTitle := "G+/RB"
cHelpCStatus := "BG+/RB"
//                                           //     ���� ������
cDataCScr  := "W+/B,B/BG"
cDataCGet  := "W+/B,W+/R,,,BG+/B"
cDataCSay  := "BG+/B,W+/R,,,BG+/B"
cDataCMenu := "N/BG,W+/N,,,B/W"
cDataPgDn  := "BG/B"
color5     := "N/W,GR+/R,,,B/W"
color8     := "GR+/B,W+/R"
color13    := "W/B,W+/R,,,BG+/B"             // �����p�� �뤥�����
color14    := "G+/B,W+/R"
//
delete file ttt.ttt
//
Public cur_drv := DISKNAME()
Public cur_dir := cur_drv+":"+DIRNAME(cur_drv)+cslash
//Public cur_dir := hb_DirBase()
Public dir_server := "", p_name_comp := ""
Public dir_exe := upper(beforatnum(cslash,exename()))+cslash
//Public dir_exe := upper(beforatnum(cslash,hb_ProgName()))+cslash
Public exe_dir := dir_exe
// �஢����, ����饭� �� 㦥 ������ �����, �᫨ "��" - ��室 �� �����
verify_1_task()
//
if hb_FileExists("server.mem")
  ft_use("server.mem")
  dir_server := alltrim(ft_readln())
  if !ft_eof()
    ft_skip()
    p_name_comp := alltrim(ft_readln())
    if cslash $ p_name_comp
      p_name_comp := ""
    endif
  endif
  if len(p_name_comp) < 2
    p_name_comp := alltrim(netname())+cslash+hb_username()
  endif
  ft_use()
  is_cur_dir := .f.
else // ���� = ⥪�騩 ��⠫��
  dir_server := cur_dir
endif
if right(dir_server,1) != cslash
  dir_server += cslash
endif
is_server(dir_server,cur_dir)
if !is_create .and. !hb_FileExists(dir_server+"human"+sdbf)
  func_error("�� �����㦥�� 䠩�� ���� ������! ������� � ��⥬���� ������������.")
  QUIT
endif
//
if hb_FileExists(dir_server+"plat.dbf")
  func_error("����⭥� �ᥣ�, �� ����᪠�� �ணࠬ�� � ��⠫��� �����. �� �������⨬�!")
  QUIT
endif
SET KEY K_ALT_F3 TO calendar
SET KEY K_ALT_F2 TO calc
SET KEY K_ALT_X  TO f_end
Public flag_chip := .f.
READINSERT(.T.) // ०�� ।���஢���� �� 㬮�砭�� Insert
KEYBOARD ""
ksetnum(.t.)    // ������� NumLock
SETCURSOR(0)
SET COLOR TO
RETURN is_cur_dir

*

***** 02.11.15
Function hard_err(p)
// k = 1 - �஢�ઠ ��᪠ �� ����稥 �६������ 䠩�� hard_err.meh
//         �, �᫨ �� ����, �뢮� ⥪�� � ����室����� ��२�����஢����;
//         ᮧ����� �६������ 䠩�� hard_err.meh "CREATE"
// k = 2 - 㤠����� �६������ 䠩�� hard_err.meh "DELETE"
Local k := 3, arr := {}
if valtype(p) == "N"
  k := p
elseif valtype(p) == "C"
  p := upper(p)
  do case
    case p == "CREATE"
      k := 1
    case p == "DELETE"
      k := 2
  endcase
endif
do case
  case k == 1
    if file("hard_err.meh")
      FillScreen(p_char_screen,p_color_screen)
      aadd(arr,"��᫥���� ࠧ �� ��室� �� ����� �� ᡮ� �� ��⠭��.")
      aadd(arr,". . .")
      aadd(arr,"���⮬� ��� �����⥫쭮 ४��������� �믮�����")
      aadd(arr,'०�� "��२�����஢����", �.�. ������ ����⭮, ��')
      aadd(arr,"������� ������� 䠩�� �뫨 �ᯮ�祭� ��� ࠧ��襭�.")
      keyboard ""
      f_message(arr,,color1,color8,,,color1)
      if f_alert({padc("�롥�� ����⢨�",60,".")},;
               {" ��室 �� ����� "," �த������� ࠡ��� "},;
               1,"W+/N","N+/N",20,,"W+/N,N/BG" ) != 2
        SET COLOR TO
        SET CURSOR ON
        CLS
        QUIT
      endif
      FillScreen(p_char_screen,p_color_screen)
    endif
    strfile("hard_error","hard_err.meh")
  case k == 2
    delete file hard_err.meh
endcase
return NIL

*

***** 06.10.19
FUNCTION f_end(yes_copy)
Static group_ini := "RAB_MESTO"
Local i, spath := "", bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  write_rest_pp() // ������� ������ᠭ�� ���ਨ �������� �� ��񬭮�� �����
  CLOSE ALL
  DEFAULT yes_copy TO .t.
  if yes_copy
    i := GetIniVar(tmp_ini, {{group_ini,"base_copy","1"},;
                             {group_ini,"path_copy",""}} )
    if i[1] != NIL .and. i[1]=="1" .and. G_SLock1Task(sem_task,sem_vagno)
      if len(i) > 1 .and. i[2] != NIL .and. !empty(i[2])
        spath := i[2]
      endif
      m_copy_DB_from_end(.f.,spath) // १�ࢭ�� ����஢����
      G_SUnLock(sem_vagno) // ࠧ�襭�� ����㯠 �ᥬ
    endif
  endif
RECOVER USING error
  //
END
//
BEGIN SEQUENCE
  G_SClose(sem_task) // 㤠���� �� ᥬ���� ��� ������ �����
RECOVER USING error
  //
END
ERRORBLOCK(bSaveHandler)
//
hard_err("delete")
filedelete(cur_dir+"tmp*.dbf")
filedelete(cur_dir+"tmp*.ntx")
filedelete(_tmp_dir1+"*.*")
if hb_DirExists(cur_dir+_tmp_dir) .and. hb_DirDelete(cur_dir+_tmp_dir) != 0
  //func_error(4,"�� ���� 㤠���� ��⠫�� "+cur_dir+_tmp_dir)
ENDIF
filedelete(_tmp2dir1+"*.*")
if hb_DirExists(cur_dir+_tmp2dir) .and. hb_DirDelete(cur_dir+_tmp2dir) != 0
  //func_error(4,"�� ���� 㤠���� ��⠫�� "+cur_dir+_tmp2dir)
ENDIF
SET KEY K_ALT_F3 TO
SET KEY K_ALT_F2 TO
SET KEY K_ALT_X  TO
SET COLOR TO
SET CURSOR ON
CLS
QUIT
RETURN NIL

*

***** 03.12.13
Function f_err_sem_vagno_task(n_Task)
return func_error(4,'� ����� "'+array_tasks[ind_task(n_Task),5]+;
                    '" �믮������ ������������� ������. ����� �६���� ������!')

***** 03.12.13
Function mo_Lock_Task(n_Task)
Local i, fl := .t., n := 0
DEFAULT n_Task TO glob_task
if glob_task == n_Task // �᫨ ��뢠���� �� ����� n_Task,
  ++n                  // � ���ᨬ� 1 ���짮��⥫�
endif
i := ind_task(n_Task)
if !G_SValueNLock(f_name_task(n_Task),n,sem_vagno_task[n_Task])
  fl := func_error('� ����� "'+array_tasks[i,5]+'" ࠡ���� ���짮��⥫�. ������ �६���� ����饭�!')
endif
return fl

***** 03.12.13
Function mo_UnLock_Task(n_Task)
return G_SUnLock(sem_vagno_task[n_Task])

*

***** ������ ��� ����� �� ��஢��� ����
Function f_name_task(n_Task)
Local it, s
DEFAULT n_Task TO glob_task
s := lstr(n_Task)
if (it := ascan(array_tasks, {|x| x[2] == n_Task})) > 0
  s := array_tasks[it,1]
endif
return s

***** �஢����, ����㯭� �� ������� �� �����⭠� �����
Function is_task(n_Task)
Local it
if !(type("array_tasks") == "A") // � ��砫� �����  ��� �� ��।��� ���ᨢ
  return .f.
endif
DEFAULT n_Task TO glob_task
if (it := ascan(array_tasks, {|x| x[2] == n_Task})) == 0
  return .f.
endif
return array_tasks[it,4]

***** ������ ������ ���ᨢ� �����⭮� �����
Function ind_task(n_Task)
Local it
DEFAULT n_Task TO glob_task
if (it := ascan(array_tasks, {|x| x[2] == n_Task})) == 0
  it := 3 // ���
endif
return it

*

***** 22.02.19 ����� "��ண�" ��஫� ��� ����㯠 � ����樨 ���㫨஢����
Function involved_password(par,_n_reestr,smsg)
Local fl := .f., c, c1, n := 0, n1, s, i, i_p := 0, n_reestr
DEFAULT smsg TO ""
smsg := "������ ��஫� ��� "+smsg
if (n := len(smsg)) > 61
  smsg := padr(smsg,61)
elseif n < 59
  smsg := space((61-n)/2)+smsg
endif
c1 := int((maxcol()-75)/2)
n := 0
do while i_p < 3  // �� 3� ����⮪
  ++i_p
  n_reestr := _n_reestr
  if (n := input_value(maxrow()-6,c1,maxrow()-4,maxcol()-c1,color1,smsg,n,"9999999999")) != NIL
    if par == 1 // ॥���
      s := lstr(n_reestr)
    elseif par == 2 // ��� ��� ���
      s := substr(n_reestr,3)
      s := right(beforatnum("M",s),1)+left(afteratnum("_",s),7)
    elseif eq_any(par,3,4) // ����
      s := iif(par == 3, "", "1")
      n_reestr := substr(alltrim(upper(n_reestr)),3)
      for i := 1 to len(n_reestr)
        c := substr(n_reestr,i,1)
        if between(c,'0','9')
          s += c
        elseif between(c,'A','Z')
          s += lstr(asc(c))
        endif
      next
    endif
    s := charrem("0",s)+lstr(_version[1])+lstr(_version[2])+lstr(_version[3]*7,10,0)
    do while len(s) > 7
      s := left(s,len(s)-1)
    enddo
    n1 := int(val(ntoc(s,8)))
    if n == n1
      fl := .t. ; exit
    else
      func_error(4,"��஫� ����७. ��� ����㯠 � ������� ०���!")
    endif
  else
    exit
  endif
enddo
return fl

***** 04.07.18
Function find_unfinished_reestr_sp_tk(is_oper,is_count)
Static max_rec := 9900000 // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Local fl := .t., s, buf := save_maxrow(), arr, rech := 0, af := {}, bSaveHandler
DEFAULT is_oper TO .t., is_count TO .t.
mywait()
bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  if is_count
    R_Use(dir_server+"human",,"HUMAN")
    rech := lastrec()
    Use
  endif
  R_Use(dir_server+"mo_rees",,"REES")
  R_Use(dir_server+"mo_xml",,"MO_XML")
  set relation to REESTR into REES
  index on FNAME to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_SP .and. empty(TWORK2)
  go top
  do while !eof()
    aadd(af, {rtrim(mo_xml->FNAME),lstr(rees->NSCHET)})
    skip
  enddo
  close databases
  rest_box(buf)
  if (fl := (len(af) > 0 .or. rech > max_rec))
    if rech > max_rec
      arr := {"�� ���௠��� ����� ���� ������ � ���",;
              "��⠫��� ����������� �������� "+lstr(10000000 - rech)+" ���⮢ ����."}
    endif
    if len(af) > 0
      s := "�� �����襭� �⥭�� "
      if len(af) == 1
        s += "॥��� �� � �� "+af[1,1]+" (॥��� "+af[1,2]+")"
      else
        s += lstr(len(af))+" ॥��஢ �� � ��"
      endif
      arr := {"",s}
    endif
    if is_oper
      aadd(arr,"")
      aadd(arr,"������ ����饭�!")
    endif
    n_message(arr,{"","������� � ࠧࠡ��稪��"},"GR+/R","W+/R",,,"G+/R")
  endif
RECOVER USING error
  close databases
  rest_box(buf)
END
ERRORBLOCK(bSaveHandler)
return fl

***** 28.09.17 �஢����, ���� �� ����᫠��� ����祭�� ����� ����
Function find_time_limit_human_reestr_sp_tk()
Local buf := savescreen(), arr[10,2], i, mas_pmt, r, c, n, d := sys_date-23
Local fl := .f., bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
mywait()
BEGIN SEQUENCE
  dbcreate(cur_dir+"tmp_tl",{{"kod_h","N",8,0},;
                             {"kod_xml","N",6,0},;
                             {"dni","N",2,0}})
  use (cur_dir+"tmp_tl") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"mo_refr",dir_server+"mo_refr","REFR")
  R_Use(dir_server+"mo_xml",,"MO_XML")
  R_Use(dir_server+"mo_rees",,"REES")
  set relation to KOD_XML into MO_XML
  R_Use(dir_server+"mo_rhum",,"RHUM")
  set relation to reestr into REES
  index on str(reestr,6) to (cur_dir+"tmp_rhum") for OPLATA == 2 .and. d < rees->DSCHET
  go top
  do while !eof()
    if (r := sys_date - rees->DSCHET) <= 0
      r := 1
    endif
    human->(dbGoto(rhum->kod_hum))
    // �஢�ਬ, �� ����� �� ��� � ��㣮� ॥��� (��� ��稩 ����)
    if emptyall(human->schet,human_->REESTR) .and. rhum->REES_ZAP == human_->REES_ZAP
      select REFR
      find (str(1,1)+str(mo_xml->REESTR,6)+str(1,1)+str(rhum->kod_hum,8))
      do while refr->TIPD == 1 .and. refr->KODD == mo_xml->REESTR .and. ;
               refr->TIPZ == 1 .and. refr->KODZ == rhum->kod_hum  .and. !eof()
        if !eq_any(refr->REFREASON,50,57)
          select TMP_TL
          append blank
          tmp_tl->kod_h   := rhum->kod_hum
          tmp_tl->kod_xml := mo_xml->kod
          tmp_tl->dni     := r
          if lastrec() % 1000 == 0
            Commit
          endif
        endif
        select REFR
        skip
      enddo
    endif
    select RHUM
    skip
  enddo
RECOVER USING error
  fl := .t.
END
ERRORBLOCK(bSaveHandler)
if fl
  close databases
  restscreen(buf)
  return func_error(4,"������⭠� �訡��. �믮���� ��२�����஢���� � �������� ���")
endif
select TMP_TL
if lastrec() > 0
  afillall(arr,0)
  i := 0
  index on dni to (cur_dir+"tmp_tl") unique
  go top
  if tmp_tl->dni <= 10 // �� ����� 10 ���� ����祭�, ���� �� �뢮���
    do while !eof()
      ++i
      if i == 10
        arr[i,1] := -1
        exit
      endif
      arr[i,1] := tmp_tl->dni
      skip
    enddo
    set index to
    go top
    do while !eof()
      if (i := ascan(arr, {|x| x[1] == tmp_tl->dni})) == 0
        i := 10
      endif
      arr[i,2] ++
      skip
    enddo
    close databases
    mas_pmt := {} ; n := 0
    for i := 1 to 10
      if emptyany(arr[i,1],arr[i,2])
        exit
      elseif arr[i,1] == -1
        aadd(mas_pmt, lstr(arr[i,2])+" 祫. - ����祭� ����� "+lstr(arr[9,1])+" ��.")
      else
        aadd(mas_pmt, lstr(arr[i,2])+" 祫. - ����祭� "+lstr(arr[i,1])+" ��.")
      endif
      n := max(n,len(atail(mas_pmt)))
    next
    if len(mas_pmt) > 0
      i := 1
      r := maxrow()-len(mas_pmt)-4 ; c := int((80-n-3)/2)
      status_key("^<Esc>^ ��室 �� ०��� � �室 � ������  ^<Enter>^ ��ᬮ�� ����祭��� ��砥�")
      str_center(r-1,"�����㦥�� ����祭�� ��砨:","W+/N*")
      do while (i := popup_prompt(r,c,i,mas_pmt)) > 0
        f1find_time_limit_human_reestr_sp_tk(i,arr)
      enddo
    endif
  endif
endif
close databases
restscreen(buf)
return NIL

*****
Function f1find_time_limit_human_reestr_sp_tk(i,arr)
Local n_file := "time_lim"+stxt, sh := 80, HH := 60
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("���᮪ ��砥�, �������� � �訡��� � ��� �� ��᫠���� � �����",sh))
if i == 10
  add_string(center("(����祭� ����� "+lstr(arr[9,1])+" ��.)",sh))
else
  add_string(center("(����祭� "+lstr(arr[i,1])+" ��.)",sh))
endif
add_string(center("�� ���ﭨ� �� "+full_date(sys_date)+" "+hour_min(seconds()),sh))
add_string("")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
use (cur_dir+"tmp_tl") new
set relation to kod_h into HUMAN
if i == 10
  index on upper(human->fio) to (cur_dir+"tmp_tl") for dni > arr[9,1]
else
  index on upper(human->fio) to (cur_dir+"tmp_tl") for dni == arr[i,1]
endif
i := 0
go top
do while !eof()
  verify_FF(HH, .t., sh)
  add_string(lstr(++i)+". "+alltrim(human->fio)+", "+full_date(human->date_r)+;
             iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
             " "+date_8(human->n_data)+"-"+date_8(human->k_data))
  select TMP_TL
  skip
enddo
close databases
fclose(fp)
viewtext(n_file,,,,.f.,,,2)
return NIL

*

*****
Function my_mo_f_main()
Local arr := {}
if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
  aadd(arr,{"����� - �࠭ᯫ���஢����",X_MO,"TABLET_ICON",.T.})
endif
return arr

*****
Function my_mo_begin_task()
Local fl := .t.
if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
  fl := vounc_begin_task()
endif
return fl

*****
Function my_mo_Reconstruct_BD()
if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
  vounc_Reconstruct_BD()
endif
return NIL

***** 05.11.15
Function my_mo_f1main()
Local old := is_uchastok
if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
  is_uchastok := 1 // �㪢� + � ���⪠ + � � ���⪥ "�25/123"
  vounc_f1main()
  is_uchastok := old
endif
return NIL

*****
Function my_mo_init_array_files_DB()
Local arr := {}
if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
  arr := vounc_init_array_files_DB()
endif
return arr

***** 28.07.16 �������� ��⥬��� ���� (��� ࠡ����� �� ��砬 �ࠢ��㭪⮢)
Function change_sys_date()
sys_date := DATE()
sys1_date := sys_date
c4sys_date := dtoc4(sys1_date)
return NIL
