#include 'function.ch'
#include 'chip_mo.ch'

// 26.01.23 ���樠������ ���ᨢ� ��, ����� ���� �� (�� ����室�����)
Function init_mo()
  Local fl := .t., i, arr, arr1, cCode := '', buf := save_maxrow()

//    local aaa
//    aaa := loadQ015()
//  altd()

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

// 11.06.23
function delete_base_dict(dir_exe, dir_cur)
  local aDbf := { ;
      dir_exe + '_mo_mo.dbb', ;
      dir_exe + '_mo_o001.dbf', ;
      dir_exe + '_mo_f006.dbf', ;
      dir_exe + '_mo_f010.dbf', ;
      dir_exe + '_mo_f014.dbf', ;
      dir_exe + 'not_lev.dbf', ;
      dir_exe + 'not_usl.dbf', ;
      dir_exe + '_mo_v002.dbf', ;
      dir_exe + '_mo_v009.dbf', ;
      dir_exe + '_mo_v010.dbf', ;
      dir_exe + '_mo_v012.dbf', ;
      dir_exe + '_mo_v015.dbf', ;
      dir_exe + '_mo_v016.dbf', ;
      dir_exe + '_mo_v017.dbf', ;
      dir_exe + '_mo_v018.dbf', ;
      dir_exe + '_mo_v019.dbf', ;
      dir_exe + '_mo_v020.dbf', ;
      dir_exe + '_mo_v021.dbf', ;
      dir_exe + '_mo_v022.dbf', ;
      dir_exe + '_mo_v025.dbf', ;
      dir_exe + '_mo_v030.dbf', ;
      dir_exe + '_mo_v031.dbf', ;
      dir_exe + '_mo_v032.dbf', ;
      dir_exe + '_mo_v033.dbf', ;
      dir_exe + '_mo_v036.dbf', ;
      dir_exe + '_mo_ed_izm.dbf', ;
      dir_exe + '_mo_impl.dbf', ;
      dir_exe + '_mo_method_inj.dbf', ;
      dir_exe + '_mo_severity.dbf', ;
      dir_exe + '_mo_t005.dbf', ;
      dir_exe + '_mo_t006.dbf', ;
      dir_exe + '_mo_t007.dbf', ;
      dir_exe + '_mo_unit.dbf', ;
      dir_exe + '_mo_usl.dbf', ;
      dir_exe + '_mo_uslc.dbf', ;
      dir_exe + '_mo5k006.dbf', ;
      dir_exe + '_mo5t006.dbf', ;
      dir_exe + '_mo5uslc.dbf', ;
      dir_exe + '_mo5uslf.dbf', ;
      dir_exe + '_mo6k006.dbf', ;
      dir_exe + '_mo6t006.dbf', ;
      dir_exe + '_mo6uslc.dbf', ;
      dir_exe + '_mo6uslf.dbf', ;
      dir_exe + '_mo7k006.dbf', ;
      dir_exe + '_mo7t006.dbf', ;
      dir_exe + '_mo7uslc.dbf', ;
      dir_exe + '_mo7uslf.dbf', ;
      dir_exe + 't006_2.dbf', ;
      dir_exe + 't006_d.dbf', ;
      dir_exe + 't006_u.dbf', ;
      dir_exe + 'telemed.dbf', ;
      dir_exe + 'v001.dbf', ;
      dir_exe + '_mo_t005.dbt', ;
      dir_exe + '_mo_v019.dbt', ;
      dir_exe + '_mo_v020.dbt', ;
      dir_exe + '_mo_v030.dbt', ;
      dir_exe + '_mo0k006.dbt', ;
      dir_exe + '_mo1k006.dbt', ;
      dir_exe + '_mo8k006.dbt', ;
      dir_exe + '_mo9k006.dbt', ;
      dir_exe + 't006_2.dbt', ;
      dir_exe + '_mo_f006.dbt', ;
      dir_exe + '_mo_f014.dbt' ;
    }
    // dir_exe + '_mo_q015.dbf', ;
    // dir_exe + '_mo_q016.dbf', ;
    // dir_exe + '_mo_q017.dbf', ;
    // dir_exe + '_mo_q015.dbt', ;
    // dir_exe + '_mo_q016.dbt', ;
    // dir_exe + '_mo_q017.dbt', ;
    local aNtx := { ;
      dir_cur + '_mo_t005.ntx', ;
      dir_cur + '_mo_t007.ntx', ;
      dir_cur + '_mo_t0072.ntx', ;
      dir_cur + '_mo_impl.ntx' ;
    }
  local row

  for each row in aDbf
    if hb_vfExists(row)
      hb_vfErase(row)
    endif
  next

  for each row in aNtx
    if hb_vfExists(row)
      hb_vfErase(row)
    endif
  next

  return nil