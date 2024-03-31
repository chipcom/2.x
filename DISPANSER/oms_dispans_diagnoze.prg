#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 05.10.21 - ���������� ��� ।���஢���� ��������� � ��ᯠ��ਧ�樨
// j - ����� ��ப� ��� �뢮�� �� �࠭
Function oms_dispan_diagnoze(j)
  local mm_pervich := arr_mm_pervich()

  @ ++j, 1  say '������������������������������������������������������������������������������'
  @ ++j, 1  say '       �  �����  �   ���   ��⠤����⠭������ ��ᯠ��୮� ��� ᫥���饣�'
  @ ++j, 1  say '������������������� ������� ������.��������     (�����)     �����'
  @ ++j, 1  say '������������������������������������������������������������������������������'
  //                2      9            22           35       44        54
  @ ++j, 2  get mdiag1 picture pic_diag ;
            reader {|o| MyGetReader(o, bg)} ;
            valid  {|g| iif(val1_10diag(.t., .f., .f., mn_data, mpol), ;
                              f_valid_diag_oms_sluch_DVN(g, 1), .f.) }
  @ j, 9  get mpervich1 ;
            reader {|x|menu_reader(x, mm_pervich, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag1)
  @ j, 22 get mddiag1 when !empty(mdiag1)
  @ j, 35 get m1stadia1 pict '9' range 1, 4 ;
            when !empty(mdiag1)
  @ j, 44 get mdispans1 ;
            reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag1)
  @ j, 54 get mddispans1 when m1dispans1 == 1
  @ j, 67 get mdndispans1 when m1dispans1 == 1
  //
  @ ++j, 2  get mdiag2 picture pic_diag ;
            reader {|o| MyGetReader(o, bg)} ;
            valid  {|g| iif(val1_10diag(.t., .f., .f., mn_data, mpol), ;
                              f_valid_diag_oms_sluch_DVN(g, 2), .f.) }
  @ j, 9  get mpervich2 ;
            reader {|x|menu_reader(x,mm_pervich, A__MENUVERT,,, .f.)} ;
            when !empty(mdiag2)
  @ j, 22 get mddiag2 when !empty(mdiag2)
  @ j, 35 get m1stadia2 pict '9' range 1, 4 ;
            when !empty(mdiag2)
  @ j, 44 get mdispans2 ;
            reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag2)
  @ j, 54 get mddispans2 when m1dispans2 == 1
  @ j, 67 get mdndispans2 when m1dispans2 == 1
  //
  @ ++j, 2  get mdiag3 picture pic_diag ;
            reader {|o| MyGetReader(o, bg)} ;
            valid  {|g| iif(val1_10diag(.t., .f., .f., mn_data, mpol), ;
                              f_valid_diag_oms_sluch_DVN(g, 3), .f.) }
  @ j, 9  get mpervich3 ;
            reader {|x|menu_reader(x, mm_pervich, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag3)
  @ j, 22 get mddiag3 when !empty(mdiag3)
  @ j, 35 get m1stadia3 pict '9' range 1, 4 ;
            when !empty(mdiag3)
  @ j, 44 get mdispans3 ;
            reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag3)
  @ j, 54 get mddispans3 when m1dispans3 == 1
  @ j, 67 get mdndispans3 when m1dispans3 == 1
  //
  @ ++j, 2  get mdiag4 picture pic_diag ;
            reader {|o| MyGetReader(o, bg)} ;
            valid  {|g| iif(val1_10diag(.t., .f., .f., mn_data, mpol), ;
                              f_valid_diag_oms_sluch_DVN(g, 4), .f.) }
  @ j, 9  get mpervich4 ;
            reader {|x|menu_reader(x, mm_pervich, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag4)
  @ j, 22 get mddiag4 when !empty(mdiag4)
  @ j, 35 get m1stadia4 pict '9' range 1, 4 ;
            when !empty(mdiag4)
  @ j, 44 get mdispans4 ;
            reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag4)
  @ j, 54 get mddispans4 when m1dispans4 == 1
  @ j, 67 get mdndispans4 when m1dispans4 == 1
  //
  @ ++j, 2  get mdiag5 picture pic_diag ;
            reader {|o| MyGetReader(o, bg)} ;
            valid  {|g| iif(val1_10diag(.t., .f., .f., mn_data, mpol), ;
                              f_valid_diag_oms_sluch_DVN(g, 5), .f.) }
  @ j, 9  get mpervich5 ;
            reader {|x|menu_reader(x, mm_pervich, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag5)
  @ j, 22 get mddiag5 when !empty(mdiag5)
  @ j, 35 get m1stadia5 pict '9' range 1, 4 ;
            when !empty(mdiag5)
  @ j, 44 get mdispans5 ;
            reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
            when !empty(mdiag5)
  @ j, 54 get mddispans5 when m1dispans5 == 1
  @ j, 67 get mdndispans5 when m1dispans5 == 1
  //
  @ ++j, 1 say replicate('�', 78) color color1

  return nil
