#include 'function.ch'
#include 'chip_mo.ch'

** 26.01.23 ���樠������ ���ᨢ� ��, ����� ���� �� (�� ����室�����)
Function init_mo()
  Local fl := .t., i, arr, arr1, cCode := '', buf := save_maxrow()

//   local aaa
//   aaa := get_array_PZ_2023()
// altd()

  mywait()
  Public oper_parol := 30  // ��஫� ��� �᪠�쭮�� ॣ������
  Public oper_frparol := 30 // ��஫� ��� �᪠�쭮�� ॣ������ �����
  Public oper_fr_inn  := '' // ��� �����
  Public glob_arr_mo := {}, glob_mo, glob_podr := '', glob_podr_2 := ''
  Public is_adres_podr := .f., glob_adres_podr := {;
    {'103001',{{'103001',1,'�.������ࠤ, �.�����窨, �.78'},;
               {'103099',2,'�.��堩�����, �.����ਭ�, �.8'},;
               {'103099',3,'�.����᪨�, �.���ᮬ���᪠�, �.25'},;
               {'103099',4,'�.����᪨�, �.������檠�, �.33'},;
               {'103099',5,'�.����設, �.����஢᪠�, �.43'},;
               {'103099',6,'�.����設, �.���, �.51'},;
               {'103099',7,'�.����, �.�ਤ��-���⥪, �.8'}};
    },;
    {'101003',{{'101003',1,'�.������ࠤ, �.�������᪮��, �.1'},;
               {'101099',2,'�.������ࠤ, �.�����᪠�, �.47'}};
    },;
    {'131001',{{'131001',1,'�.������ࠤ, �.��஢�, �.10'},;
               {'131099',2,'�.������ࠤ, �.��� ��������, �.7'},;
               {'131099',3,'�.������ࠤ, �.��.����⮢�, �.18'}};
    },;
    {'171004',{{'171004',1,'�.������ࠤ, �.����祭᪠�, �.40'},;
               {'171099',2,'�.������ࠤ, �.�ࠪ����ந⥫��, �.13'}};
    };
  }

  create_mo_add()
  glob_arr_mo := getMo_mo_New('_mo_mo')

  if hb_FileExists(dir_server + 'organiz' +sdbf)
    R_Use(dir_server + 'organiz',,'ORG')
    if lastrec() > 0
      cCode := left(org->kod_tfoms,6)
    endif
  endif
  close databases
  if !empty(cCode)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
      glob_mo := glob_arr_mo[i]
      if (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
        is_adres_podr := .t.
        glob_podr_2 := glob_adres_podr[i, 2, 2, 1] // ��ன ��� ��� 㤠�񭭮�� ����
      endif
    else
      func_error(4,'� �ࠢ�筨� ������ ���������騩 ��� �� "' + cCode + '". ������ ��� ������.')
      cCode := ''
    endif
  endif
  if empty(cCode)
    if (cCode := input_value(18, 2, 20, 77, color1, ;
                              '������ ��� �� ��� ���ᮡ������� ���ࠧ�������, ��᢮���� �����', ;
                              space(6), '999999')) != NIL .and. !empty(cCode)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
        glob_mo := glob_arr_mo[i]
        if hb_FileExists(dir_server + 'organiz' + sdbf)
          G_Use(dir_server + 'organiz', , 'ORG')
          if lastrec() == 0
            AddRecN()
          else
            G_RLock(forever)
          endif
          org->kod_tfoms := glob_mo[_MO_KOD_TFOMS]
          org->name_tfoms := glob_mo[_MO_SHORT_NAME]
          org->uroven := get_uroven()
        endif
        close databases
      else
        fl := func_error('����� ���������� - ������ ��� �� "' + cCode + '" ����७.')
      endif
    endif
  endif
  if empty(cCode)
    fl := func_error('����� ���������� - �� ����� ��� ��.')
  endif

  rest_box(buf)

  if ! fl
    hard_err('delete')
    QUIT
  endif

  return main_up_screen()