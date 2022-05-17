#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 17.05.22 ���㫠�ୠ� ����樭᪠� ॠ������� - ���������� ��� ।���஢���� ���� (���� ���)
function oms_sluch_MED_REAB(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����

  Static SKOD_DIAG := '     ', st_l_z := 1, st_N_DATA, st_K_DATA, st_rez_gist,;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0, st_povod := 9

  local str_1, pos_read := 0, buf, tmp_color := setcolor()
  local j // ���稪 ��ப �࠭�

  Private mkod := Loc_kod, mtip_h, is_talon := .f., ibrm := 0, ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    m1lpu := glob_uch[1], mlpu, ;
    m1otd := glob_otd[1], motd, ;
    mfio := space(50), mpol, mdate_r, madres, mmr_dol, ;
    m1fio_kart := 1, mfio_kart, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, m1komu := 0, m1str_crb := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
    m1npr_mo := '', mnpr_mo := space(10), mnpr_date := ctod(''), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20), ;
    MN_DATA     := st_N_DATA         ,; // ��� ��砫� ��祭��
    MK_DATA     := st_K_DATA         ,; // ��� ����砭�� ��祭��
    M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;
    much_doc    := space(10)         //,; // ��� � ����� ��⭮�� ���㬥��

  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0
  
  str_1 := " ���� (���� ����)"
  if Loc_kod == 0
    str_1 := "����������"+str_1
  else
    str_1 := "������஢����"+str_1
  endif
  pr_1_str(str_1)
  setcolor(color8)
  myclear(1)

  setcolor(cDataCGet)
  make_diagP(1)  // ᤥ���� "��⨧����" ��������

  do while .t.
    pr_1_str(str_1)
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl("���� ��� � " + lstr(Loc_kod), 29) color color14
    endif
    // diag_screen(0)
    pos_read := 0
    // put_dop_diag(0)
    @ ++j, 1 say "��०�����" get mlpu when .f. color cDataCSay
    @ row(),col()+2 say "�⤥�����" get motd when .f. color cDataCSay
    //
    @ ++j, 1 say "���" get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        valid {|g, o| update_get("mkomu"),update_get("mcompany"),;
          update_get("mspolis"),update_get("mnpolis"),;
          update_get("mvidpolis") }
    //
    @ ++j, 1 say "���ࠢ�����: ���" get mnpr_date
    @ ++j, col() + 1 say "�� ��" get mnpr_mo ;
        reader {|x|menu_reader(x, {{|k, r, c| f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        color colget_menu

    @ ++j, 1 say "�ப� ��祭��" get mn_data valid {|g| f_k_data(g, 1)}
    @ row() ,col() + 1 say "-"   get mk_data valid {|g| f_k_data(g, 2)}
    // @ row(),col()+3 get mvzros_reb when .f. color cDataCSay

    @ maxrow(), 0 say padc("<Esc> - ��室;  <PgDn> - ������;  <F1> - ������", maxcol() + 1) color color0
    mark_keys({"<F1>", "<Esc>", "<PgDn>"}, "R/BG")

    count_edit += myread(,@pos_read)

    k := f_alert({padc("�롥�� ����⢨�",60,".")},;
      {" ��室 ��� ����� "," ������ "," ������ � ।���஢���� "},;
      iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )

    if k == 3
      loop
    elseif k == 2
      // �஢�ન � ������
    endif

    exit
  enddo

  setcolor(tmp_color)
  restscreen(buf)

  // if !empty(f_print)
  //   return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ')')
  // endif
  return nil