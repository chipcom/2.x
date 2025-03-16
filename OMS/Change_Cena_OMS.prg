#include 'function.ch'
#include 'chip_mo.ch'

// 08.07.24 ��������� 業 �� ��㣨 � ᮮ⢥��⢨� � �ࠢ�筨��� ��� �����
Function change_cena_oms()

  Local buf := save_maxrow(), lshifr1, fl, lrec, rec_human, k_data2, kod_ksg, begin_date := AddMonth( sys_date, -3 )
  Local fl_ygl_disp := .f.
  Local nCena1, nCena2, tmpSelect

  If begin_date < BoY( begin_date )
    begin_date := BoY( begin_date )
  Endif
  n_message( { "����� ०�� �।�����祭 ��� ��������� 業 �� ��㣨", ;
    "� �㬬� ��砥� � ����� ����, ����� �� ����祭�", ;
    "� ॥���� (���), �� 業� �� �ࠢ�筨�� ��� �����.", ;
    "�������� !!!", ;
    "�� �६� �믮������ ������ ����樨", ;
    "���� �� ������ ࠡ���� � ����� ���." },, ;
    "GR+/R", "W+/R",,, "G+/R" )
  If f_esc_enter( "��������� 業", .t. ) .and. mo_lock_task( X_OMS )
    mywait()
    //
    fl := .t.
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    Begin Sequence
      r_use( dir_server + "human" )
      Index On Str( schet, 6 ) + Str( tip_h, 1 ) + Upper( SubStr( fio, 1, 20 ) ) to ( dir_server + "humans" ) progress
      Use
      r_use( dir_server + "human_u" )
      Index On Str( kod, 7 ) + date_u to ( dir_server + "human_u" ) progress
      Use
    RECOVER USING error
      fl := func_error( 10, "�������� ���।�������� �訡�� �� ��२�����஢����!" )
    End
    ErrorBlock( bSaveHandler )
    Close databases
    If fl
      waitstatus()
      use_base( "lusl" )
      use_base( "luslc" )
      use_base( "luslf" )
      use_base( "mo_su" )
      Set Order To 0

      g_use( dir_server + "uslugi", { dir_server + "uslugish", ;
        dir_server + "uslugi" }, "USL" )
      Set Order To 0
      use_base( "mo_hu" )
      r_use( dir_server + "mo_otd",, "OTD" )
      r_use( dir_server + "mo_uch",, "UCH" )
      g_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      g_use( dir_server + 'human_3', dir_server + 'human_32', 'HUMAN_3' )
      g_use( dir_server + "human_2",, "HUMAN_2" )
      g_use( dir_server + "human_",, "HUMAN_" )
      g_use( dir_server + "human", dir_server + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To Str( kod, 7 ) into HUMAN_3
      sm_human := i_human := 0
      find ( Str( 0, 6 ) )
      Do While human->schet == 0 .and. !Eof()
        // 横� �� ���
        nCena1 := nCena2 := 0
        updatestatus()
        k_data2 := human->k_data
        If human->ishod == 88
          rec_human := human->( RecNo() )
          Select HUMAN
          Goto ( human_2->pn4 ) // ��뫪� �� 2-� ���� ����
          k_data2 := human->k_data // ��९�ᢠ����� ���� ����砭�� ��祭��
          Goto ( rec_human )
        Endif
        If human_->reestr == 0 .and. k_data2 > begin_date
          ++sm_human
          @ MaxRow(), 1  Say lstr( i_human ) Color "G+/R"
          @ Row(), Col() Say "/" Color "R+/R"
          @ Row(), Col() Say lstr( sm_human ) Color "GR+/R"
          uch->( dbGoto( human->LPU ) )
          otd->( dbGoto( human->OTD ) )
          f_put_glob_podr( human_->USL_OK, human->k_data ) // ��������� ��� ���ࠧ�������
          sdial := mcena_1 := 0 ; fl := .f. ; kod_ksg := ""
          Select HU
          find ( Str( human->kod, 7 ) )
          // If human->ishod == 401 .or. human->ishod == 402
          If is_sluch_dispanser_COVID( human->ishod )
            fl_ygl_disp := .t.
          Else
            fl_ygl_disp := .f.
          Endif
          Do While hu->kod == human->kod .and. !Eof()
            // 横� �� ��㣠�
            usl->( dbGoto( hu->u_kod ) )
            mdate := c4tod( hu->date_u )
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, k_data2 )
            If is_usluga_tfoms( usl->shifr, lshifr1, k_data2 )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              If human_->USL_OK < 3 .and. is_ksg( lshifr )
                kod_ksg := lshifr
                lrec := hu->( RecNo() )
              Else
                lu_cena := hu->u_cena
                fl_del := fl_uslc := .f.
                v := fcena_oms( lshifr, ;
                  ( human->vzros_reb == 0 ), ;
                  k_data2, ;
                  @fl_del, ;
                  @fl_uslc )
                If fl_uslc // �᫨ ��諨 � �ࠢ�筨�� �����
                  lu_cena := v
                Endif
                mstoim_1 := round_5( lu_cena * hu->kol_1, 2 )
                Select HU
                If !( Round( hu->u_cena, 2 ) == Round( lu_cena, 2 ) .and. Round( hu->stoim_1, 2 ) == Round( mstoim_1, 2 ) )
                  g_rlock( forever )
                  Replace u_cena  With lu_cena, stoim With mstoim_1, stoim_1 With mstoim_1
                  fl := .t.
                  // �������� ������� �� ��
                Endif
                If fl_ygl_disp .and. hu->kod_vr == 0 .and. hu->kod_as == 0
                  // �� �㬬��㥬
                Else
                  mcena_1 += hu->stoim_1
                Endif
              Endif
            Endif
            Select HU
            Skip
          Enddo
          If !Empty( kod_ksg )
            If Select( "K006" ) != 0
              k006->( dbCloseArea() )
            Endif
            If Year( human->k_data ) > 2018
              arr_ksg := definition_ksg( 1, k_data2 )
            Else
              arr_ksg := definition_ksg( 1, k_data2 )  // definition_KSG_18() ���� ��������
            Endif
            fl1 := .t.
            If Len( arr_ksg ) == 7
              If ValType( arr_ksg[ 7 ] ) == "N"
                sdial := arr_ksg[ 7 ] // ��� 2019 ����
              Else
                fl1 := .f. // ��� 2018 ����
              Endif
            Endif
            If !fl1 // ������ 2018 ����
              //
            Elseif Empty( arr_ksg[ 2 ] ) // ��� �訡��
              mcena_1 := arr_ksg[ 4 ]
              Select HU
              Goto ( lrec )
              If !( Round( mcena_1, 2 ) == Round( hu->u_cena, 2 ) )
                g_rlock( forever )
                Replace u_cena  With mcena_1, stoim With mcena_1, stoim_1 With mcena_1
                fl := .t.
              Endif
              put_str_kslp_kiro( arr_ksg )
            Endif
          Endif
          // ������� ���ଠ�� � �� ������� ��砥�
          If human->ishod == 89
            tmpSelect := Select()
            nCena1 := human->cena
            rec_human := human->( RecNo() )
            human_->( g_rlock( forever ) )
            human_->ST_VERIFY := 5
            human_->( dbRUnlock() )
            Select HUMAN_3
            If ! Eof() .and. ! Bof()
              Select human
              Goto ( human_3->kod )
              nCena2 := human->cena
              human_->( g_rlock( forever ) )
              human_->ST_VERIFY := 5
              human_->( dbRUnlock() )
                Goto ( rec_human )
              human_3->( g_rlock( forever ) )
              human_3->CENA_1 := nCena1 + nCena2
              human_3->( dbRUnlock() )
            Endif
            Select( tmpSelect )
          Endif

          If fl .or. !( Round( mcena_1 + sdial, 2 ) == Round( human->cena_1, 2 ) )
            ++i_human
            human->( g_rlock( forever ) )
            human->cena := human->cena_1 := mcena_1 + sdial
            human_->( g_rlock( forever ) )
            human_->OPLATA    := 0 // 㡥�� "2", �᫨ ��।���஢��� ������ �� ॥��� �� � ��
            human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
            Unlock All
          Endif
          If sm_human % 1000 == 0
            Commit
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      Close databases
      rest_box( buf )
      // /////////////////// ��������� ���������  //////////////////////////
      If sm_human == 0
        func_error( 4, "� ���� ������ ��� ��樥�⮢, �� ������� � ॥���� (���)!" )
      Elseif i_human == 0
        func_error( 4, "�� �����㦥�� ���⮢ ���� � ����室������� ������� 業" )
      Else
        n_message( { "��������� 業 �ந������� - " + lstr( i_human ) + " �/�" },, "W/RB", "BG+/RB",,, "G+/RB" )
      Endif
    Endif
    mo_unlock_task( X_OMS )
    Close databases
  Endif

  Return Nil