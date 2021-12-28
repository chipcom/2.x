#include 'function.ch'
#include 'chip_mo.ch'

******* 28.12.21 �஢������ ��������� � ᮤ�ন��� �� �� ����������
function update_data_DB(aVersion)
  local snversion := int(aVersion[1]*10000 + aVersion[2]*100 + aVersion[3])
  local ver_base := get_version_DB()

  if ver_base < 21130 // ���室 �� ����� 2.11.30
    update_v21130()     // ᪮४�஥� ����� 㣫㡫����� ��ᯠ��ਧ�樨
  endif

  if ver_base < 21131 // ���室 �� ����� 2.11.31
    update_v21131()     // �������� ���� PRVS_V021 ������ �� �ࠢ�筨�� ���. ᯥ樠�쭮�⥩ V021
  endif
  return nil

***** 22.12.21
function update_v21131()
  local i := 0, j := 0
  // Local t1 := 0, t2 := 0

  // t1 := seconds()
  Stat_Msg('������塞 ᯥ樠�쭮���')
  use_base('mo_pers', 'PERS', .t.) // ��஥� 䠩� mo_pers

  pers->(dbSelectArea())
  pers->(dbGoTop())
  do while ! pers->(Eof())
    i++
    @ maxrow(),1 say pers->fio color cColorStMsg
    if ! empty(pers->PRVS_NEW)
      j := 0
      if (j := ascan(glob_arr_V015_V021, {|x| x[1] == pers->PRVS_NEW })) > 0
        pers->PRVS_021 := glob_arr_V015_V021[j, 2]
      endif
    elseif ! empty(pers->PRVS)
      pers->PRVS_021 := ret_prvs_V021(pers->PRVS)
    endif
    pers->(dbSkip())
  end do
  dbCloseAll()        // ���஥� ��

  // t2 := seconds() - t1
  // if t2 > 0
  //   n_message({"","�६� ��室� �� - "+sectotime(t2)},,;
  //         color1,cDataCSay,,,color8)
  // endif
  // alertx(i, '������⢮ ���㤭����')
  return nil

***** 17.12.21
function update_v21130()
  local is_DVN_COVID := .f.
  local mkod
  local begin_DVN_COVID := 0d20210701   // ��� ��砫� 㣫㡫����� ��ᯠ��ਧ�樨
  local i := 0, j := 0
  local lshifr := ''

  R_Use(dir_server + 'mo_otd', , 'otd')
  OTD->(dbGoTop())
  do while ! otd->(Eof())
    if otd->TIPLU == TIP_LU_DVN_COVID
      is_DVN_COVID := .t.
      exit
    endif
    otd->(dbSkip())
  end do
  otd->(dbCloseArea())

  if is_DVN_COVID

    Stat_Msg('�஢�ઠ � ��ࠢ����� ���� ��� � ����� ��� ���㡫����� ��ᯠ��ਧ�樨')

    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"mo_su",,"MOSU")

    use_base("mo_hu")
    use_base('human_u') // ��஥� 䠩� human_u � ᮯ������騥 䠩��

    use_base('human') // ��஥� 䠩� human_u � ᮯ������騥 䠩��

    human->(dbSelectArea())
    human->(dbGoTop())

    do while ! human->(Eof())
      mkod := human->kod
      if human->k_data >= begin_DVN_COVID
        if human->ishod == 401
          hu->(dbSelectArea())
          hu->(dbseek(str(mkod,7)))
          do while hu->kod == mkod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
              lshifr := usl->shifr
            endif
            lshifr := alltrim(lshifr)
      
            if lshifr == '70.8.1' .and. human_->VRACH != hu->KOD_VR
              i++
              @ maxrow(),1 say human->fio color cColorStMsg
              human_->(dbSelectArea())
              if human_->(dbRLock())
                human_->VRACH := hu->KOD_VR
              endif
              human_->(dbRUnlock())
              hu->(dbSelectArea())
            endif
            hu->(dbSkip())
          end do

        elseif human->ishod == 402
          select MOHU
          set relation to u_kod into MOSU 
          mohu->(dbseek(str(mkod,7)))
          do while MOHU->kod == mkod .and. !eof()
            MOSU->(dbGoto(MOHU->u_kod))
            lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
      
            if (lshifr == 'B01.026.002' .or. lshifr == 'B01.047.002' .or. lshifr == 'B01.047.006') .and. human_->VRACH != mohu->KOD_VR
              j++
              @ maxrow(),1 say human->fio color cColorStMsg
              human_->(dbSelectArea())
              if human_->(dbRLock())
                human_->VRACH := mohu->KOD_VR
              endif
              human_->(dbRUnlock())
              mohu->(dbSelectArea())
            endif
            mohu->(dbSkip())
          enddo
        endif
      endif
      human->(dbSelectArea())
      human->(dbSkip())
    end do
    dbCloseAll()        // ���஥� ��
  endif

  return nil