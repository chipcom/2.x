// mo_omsna.prg - ��ᯠ��୮� �������
#include "inkey.ch"
#include "fastreph.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

//
Function test_mkb_10()

  r_use( dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "MKB_10" )
  Go Top
  Do While !Eof()
    If mkb_10->ks == 0 .and. between_date( mkb_10->dbegin, mkb_10->dend, sys_date )
      If f_is_diag_dn( mkb_10->shifr,,, .f. )
      Endif
    Endif
    Skip
  Enddo
  Close databases

  Return Nil

// 01.02.24 ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
Function f_init_d01()

  Local mo_dnab := { ; // ��ᯠ��୮� �������
  { "KOD_K",    "N", 7, 0 }, ; // ��� �� ����⥪�
  { "VRACH",    "N", 4, 0 }, ; // ���騩 ���
  { "PRVS",     "N", 9, 0 }, ; // ���樠�쭮��� ��� �� �ࠢ�筨�� V004, � ����ᮬ - �� �ࠢ�筨�� V015
  { "KOD_DIAG","C", 5, 0 }, ; // ������� �����������, �� ������ ���ண� ��樥�� �������� ��ᯠ��୮�� �������
  { "N_DATA","D", 8, 0 }, ; // ��� ��砫� ��ᯠ��୮�� �������
  { "LU_DATA",  "D", 8, 0 }, ; // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
  { "NEXT_DATA", "D", 8, 0 }, ; // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
  { "FREQUENCY", "N", 2, 0 }, ; // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
  { "MESTO",    "N", 1, 0 }, ;  // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
  { "PEREHOD",  "N", 1, 0 }, ;  // ���室 2021
  { "PEREHOD1", "N", 1, 0 }, ;  // ���室 �����⪠ 2021
  { "PEREHOD2", "N", 1, 0 }, ;  // ���室 �����⪠ 2021
  { "PEREHOD3", "N", 1, 0 }, ;  // ���室 2022
  { "PEREHOD4", "N", 1, 0 }, ;  // ���室 2023 ��砫�
  { "PEREHOD5", "N", 1, 0 }, ;  // ���室 2023 �����
  { "PEREHOD6", "N", 1, 0 },;   // ���室 2024
  { "PEREHOD7", "N", 1, 0 },;   // ���室 2024 �������� �10
  { "PEREHOD8", "N", 1, 0 };   // ���室 2024 - �������⥫쭮� ���쬮 � 01.2024 
  }
  Local mo_d01 := { ; // ���뫠��� 䠩�� D01
  { "KOD",         "N", 6, 0 }, ; // ��� ॥��� (����� �����)
  { "DSCHET",      "D", 8, 0 }, ; // ��� 䠩��
  { "NYEAR",       "N", 4, 0 }, ; // ����� ���
  { "MM",          "N", 2, 0 }, ; // ����� �����
  { "NN",          "N", 3, 0 }, ; // ���浪��� ����� �����;����� �� ���浪� ����� � ������ ���⭮� ��ਮ�� (3 ����� � �������騬 �㫥�);
  { "NAME_XML",    "C", 26, 0 }, ; // ��� XML-䠩�� ��� ���७�� (� ZIP-��娢�)
  { "KOD_XML",     "N", 6, 0 }, ; // ��뫪� �� 䠩� "mo_xml"
  { "DATE_OUT",    "D", 8, 0 }, ; // ��� ��ࠢ�� � �����
  { "NUMB_OUT",    "N", 2, 0 }, ; // ᪮�쪮 ࠧ �ᥣ� �����뢠�� 䠩� �� ���⥫�;
  { "ANSWER",      "N", 1, 0 }, ; // 0-�� �뫮 �⢥�, 1-����祭 �⢥� (D02)
  { "KOL",         "N", 6, 0 }, ; // ������⢮ ��樥�⮢ � ॥���/䠩��
  { "KOL_ERR",     "N", 6, 0 };  // ������⢮ ��樥�⮢ � �訡���� � ॥���
  }
  Local mo_d01k := { ; // ᯨ᮪ ��樥�⮢ � ॥����
  { "REESTR",   "N", 6, 0 }, ; // ��� ॥��� �� 䠩�� "mo_d01"
  { "KOD_K",    "N", 7, 0 }, ; // ��� �� ����⥪�
  { "D01_ZAP",  "N", 6, 0 }, ; // ����� ����樨 ����� � ॥���;"ZAP" � D01
  { "ID_PAC",   "C", 36, 0 }, ; // GUID ��樥�� � D01 (ᮧ������ �� ���������� �����)
  { "MESTO",    "N", 1, 0 }, ; // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
  { "OPLATA",   "N", 1, 0 };  // ⨯ ������: ᭠砫� 0, ��⥬ �� ����� 1,2,3,4 
  }
  Local mo_d01d := { ; // ᯨ᮪ ��������� ��樥�⮢ � ॥����
  { "KOD_D",    "N", 6, 0 }, ; // ��� (����� �����) �� 䠩�� "mo_d01k"
  { "PRVS",     "N", 4, 0 }, ; // ���樠�쭮��� ��� �� �ࠢ�筨�� V021
  { "KOD_DIAG","C", 5, 0 }, ;  // ������� �����������, �� ������ ���ண� ��樥�� �������� ��ᯠ��୮�� �������
  { "N_DATA","D", 8, 0 }, ;    // ��� ��砫� ��ᯠ��୮�� �������
  { "NEXT_DATA", "D", 8, 0 }, ; // ��� � � 楫�� ��ᯠ��୮�� �������
  { "FREQUENCY", "N", 2, 0 },;  // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
  { "KOD_N",    "N", 6, 0 }, ; // ��� (����� �����) �� 䠩�� "mo_dnab"
  { "OPLATA",   "N", 1, 0 };   // ⨯ ������: ᭠砫� 0, ��⥬ �� ����� 1,2,3,4  - ��ࢨ筮 �����㥬 �� mo_d01k 
  }
  Local mo_d01e := { ; // ᯨ᮪ �訡�� � ॥���� ����� ��ᯠ��ਧ�権
  { "REESTR",   "N", 6, 0 }, ; // ��� ॥���;�� 䠩�� "mo_d01"
  { "D01_ZAP",  "N", 6, 0 }, ; // ����� ����樨 ����� � ॥���;"ZAP") � D01
  { "KOD_ERR",  "N", 3, 0 }, ; // ��� �訡�� ��
  { "MESTO",    "N", 1, 0 };  // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
  }
  reconstruct( dir_server + "mo_d01", mo_d01, , , .t. )
  reconstruct( dir_server + "mo_d01k", mo_d01k, , , .t. )
  reconstruct( dir_server + "mo_d01d", mo_d01d, , , .t. )
  reconstruct( dir_server + "mo_d01e", mo_d01e, , , .t. )
  reconstruct( dir_server + "mo_dnab", mo_dnab, "index_base('mo_dnab')", , .t. )

  Return Nil

// 03.10.24 ��ᯠ��୮� �������
Function disp_nabludenie( k )

  Static S_sem := "disp_nabludenie"
  Static si1 := 2, si2 := 1, si3 := 2, si4 := 1, si5 := 1, si6 := 1
  Local mas_pmt, mas_msg, mas_fun, j, buf, fl_umer := .f., zaplatka_D01 := .f., ;
        zaplatka_D02 := .f., zaplatka_D07 := .f., zaplatka_D08 := .f.,  zaplatka_D_OPL := .f.,;
        zaplatka_D09 := .f.   

  Default k To 1

  Do Case
  Case k == 1
    // �६����� ��砫�
    r_use( dir_server + "mo_d01d" )
    If FieldNum( "OPLATA" ) == 0 //
      zaplatka_D_OPL := .T.
    endif
    Close databases
    //
    r_use( dir_server + "mo_dnab" )
    If FieldNum( "PEREHOD7" ) == 0 //�������� E10
      zaplatka_D07 := .T.
    endif
    If FieldNum( "PEREHOD8" ) == 0 //�������⥫쭮� ���쬮 � 01.2024
      zaplatka_D08 := .T.
    endif
    If FieldNum( "PEREHOD9" ) == 0 //�������⥫쭮� ���쬮 � 01.2024
      zaplatka_D09 := .T.
    endif
    //
 /*   
    if zaplatka_D08 
      waitstatus( "����! ��ࠡ��뢠���� ᯨ᮪ �� ��ᯠ��୮�� ������� �� 2024 ���" )
      f_init_d01() // ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
      r_use( dir_server + "mo_D01",,   "D01" )  //॥����
      r_use( dir_server + "mo_D01K",,  "D01K" ) // ��樥��� � ॥����
      index on str(reestr,6)+str(kod_k,7) to (cur_dir +"tmp_D01")
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Go Top
      Do While !Eof()
        updatestatus()
        If dn->n_data > stod("20231201") 
          dn->n_data := stod("20231101") // �⠢�� �� 䮭���
        Endif
        //
        if dn->next_data < stod("20240201") 
          select D01
          go top
          do while !eof()
            if D01->NYEAR == 2023
              select D01K
              find (str(d01->kod,6)+str(dn->kod_k,7))  
              if found()     
                if d01k->OPLATA == 1 
                  //�ਭ��  
                else // �� ��㣨� ��ਠ���
                  dn->next_data := stod("20240201") // �⠢�� �� 䮭���
                endif
              endif 
            endif
            select D01
            skip 
          enddo
        endif  
        select DN 
        Skip
      Enddo
      Commit
    endif
 */   
    //
/*    
    If FieldNum( "PEREHOD6" ) == 0
      Close databases
      If !g_slock( S_sem )
        Return func_error( 4, "����� � ����� ०�� ���� ������" )
      Endif
      buf := save_maxrow()
      waitstatus( "����! ���⠢����� ᯨ᮪ �� ��ᯠ��୮�� ������� �� 2024 ���" )
      f_init_d01() // ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
      // �஢��塞 �� ��������� �ਪ��� - �᫨ �������� ��� - 㤠�塞 ��樥�� �� ᯨ᪠
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Go Top
      Do While !Eof()
        updatestatus()
        If dn->kod_k > 0 .and. !f_is_diag_dn( dn->KOD_DIAG,,, .f. )
          dn->kod_k := 0
          Delete
        Endif
        Select DN
        Skip
      Enddo
      Commit
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      // ���⪠ �����襭�
      //
      r_use( dir_server + "uslugi",, "USL" )
      r_use( dir_server + "human_u_",, "HU_" )
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      Set Relation To RecNo() into HU_, To u_kod into USL
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_hfio" ) For human_->usl_ok == 3 .and. k_data > 0d20201231 // ��
      // ��ࠡ��뢠�� 2021...2022...2023 �.�. ��� ����
      Go Top
      Do While !Eof()
        updatestatus()
        If 0 == fvdn_date_r( sys_date, human->date_r )  // ����஫� �� ��
          mdiagnoz := diag_for_xml(, .t.,,, .t. )
          ar_dn := {}
          If Between( human->ishod, 201, 205 )
            adiag_talon := Array( 16 )
            AFill( adiag_talon, 0 )
            For i := 1 To 16
              adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
            Next
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
                s := 3 // �� �������� ��ᯠ��୮�� �������
                If adiag_talon[ i * 2 -1 ] == 1 // �����
                  If adiag_talon[ i * 2 ] == 2
                    s := 2 // ���� �� ��ᯠ��୮� �������
                  Endif
                Elseif adiag_talon[ i * 2 -1 ] == 2 // ࠭��
                  If adiag_talon[ i * 2 ] == 1
                    s := 1 // ��⮨� �� ��ᯠ��୮� �������
                  Elseif adiag_talon[ i * 2 ] == 2
                    s := 2 // ���� �� ��ᯠ��୮� �������
                  Endif
                Endif
                If eq_any( s, 1, 2 ) // ���� ��� ��⮨� �� ��ᯠ��୮� �������
                  AAdd( ar_dn, AllTrim( mdiagnoz[ i ] ) )
                Endif
              Endif
            Next
            If !Empty( ar_dn ) // ���� �� ��ᯠ��୮� �������
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := "mdiag" + sk
                pole_1dispans := "m1dispans" + sk
                pole_dn_dispans := "mdndispans" + sk
                &pole_diag := Space( 6 )
                &pole_1dispans := 0
                &pole_dn_dispans := CToD( "" )
              Next
              read_arr_dvn( human->kod )
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := "mdiag" + sk
                pole_1dispans := "m1dispans" + sk
                pole_dn_dispans := "mdndispans" + sk
                If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. !Empty( &pole_dn_dispans ) ;
                    .and. ( j := AScan( ar_dn, AllTrim( &pole_diag ) ) ) > 0
                  Select DN
                  find ( Str( human->KOD_K, 7 ) + PadR( ar_dn[ j ], 5 ) )
                  If !Found()
                    addrec( 7 )
                    dn->KOD_K := human->KOD_K
                    dn->KOD_DIAG := ar_dn[ j ]
                  Endif
                  dn->VRACH := human_->vrach
                  dn->PRVS := human_->prvs
                  If Empty( dn->N_DATA )
                    dn->N_DATA := human->k_data // ��� ��砫� ��ᯠ��୮�� �������
                  Endif
                  //
                  dn->LU_DATA := human->k_data // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
                  dn->NEXT_DATA := &pole_dn_dispans // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
                  If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                    n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
                    If Between( n, 1, 99 )
                      dn->FREQUENCY := n
                    Endif
                  Endif
                Endif
              Next
            Endif
          Else
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
                AAdd( ar_dn, PadR( mdiagnoz[ i ], 5 ) )
              Endif
            Next
            If !Empty( ar_dn ) // �������� �� ᯨ᪠ ��ᯠ��୮�� �������
              Select HU
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
                If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                  lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                  If is_usluga_disp_nabl( lshifr )
                    For i := 1 To Len( ar_dn )
                      Select DN
                      find ( Str( human->KOD_K, 7 ) + ar_dn[ i ] )
                      If !Found()
                        addrec( 7 )
                        dn->KOD_K := human->KOD_K
                        dn->KOD_DIAG := ar_dn[ i ]
                      Endif
                      dn->VRACH := hu->KOD_VR
                      dn->PRVS := hu_->prvs // ���樠�쭮��� ��� �� �ࠢ�筨�� V004, � ����ᮬ - �� �ࠢ�筨�� V015
                      If Empty( dn->N_DATA )
                        dn->N_DATA := human->k_data // ��� ��砫� ��ᯠ��୮�� �������
                      Endif
                      //
                      dn->LU_DATA := human->k_data // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
                      dn->NEXT_DATA := c4tod( human->DATE_OPL ) // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
                      If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                        n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
                        If Between( n, 1, 99 )
                          dn->FREQUENCY := n
                        Endif
                      Endif
                      dn->MESTO := iif( hu->KOL_RCP < 0, 1, 0 ) // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
                    Next i
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      Commit
      Select DN
      Go Top
      Do While !Eof()
        updatestatus()
        If !Empty( dn->LU_DATA )
          If dn->FREQUENCY == 0
            dn->FREQUENCY := 1
          Endif
          k := Year( dn->NEXT_DATA )
          If !Between( k, 2023, 2025 ) // �� �᫨ �����४⭠� ��� ᫥�.�����
            dn->NEXT_DATA := AddMonth( dn->LU_DATA, 12 )
          Endif
          Do While dn->NEXT_DATA < 0d20240101 // ��
            dn->NEXT_DATA := AddMonth( dn->NEXT_DATA, dn->FREQUENCY )
          Enddo
          If dn->NEXT_DATA < 0d20240101
            dn->FREQUENCY := 0
          Endif
        Endif
        Skip
      Enddo
      Close databases
      //
      waitstatus( "�� ᯨ᪠ �� ��ᯠ��୮�� ������� �� 2024 ��� 㤠������ ��� � 㬥�訥" )
      r_use( dir_server + "kartote2",, "_KART2" )
      r_use( dir_server + "kartotek",, "_KART" )
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Go Top
      Do While !Eof()
        updatestatus()
        If dn->kod_k > 0
          Select _KART
          Goto ( dn->kod_k )
          Select _KART2
          Goto ( dn->kod_k )
          fl := .f.
          If Left( _kart2->PC2, 1 ) == "1"  // ���� �� १���⠬ ᢥન
            fl := .t.
          Endif
          If fl
            Select DN
            dn->NEXT_DATA :=  dn->NEXT_DATA - 365
            dn->FREQUENCY := 0
          Endif
        Endif
        Select DN
        Skip
      Enddo
      Commit
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      Close databases
      //
      rest_box( buf )
      g_sunlock( S_sem )
    Endif
*/
/*
    If zaplatka_D07  //�������� E10
      Close databases
      If !g_slock( S_sem )
        Return func_error( 4, "����� � ����� ०�� ���� ������" )
      Endif
      buf := save_maxrow()
      waitstatus( "����! ���⠢����� ᯨ᮪ �� ��ᯠ��୮�� ������� �� 2024 ���" )
      //
      f_init_d01() // ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
      //
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      //
      r_use( dir_server + "uslugi",, "USL" )
      r_use( dir_server + "human_u_",, "HU_" )
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      Set Relation To RecNo() into HU_, To u_kod into USL
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_hfio" ) For human_->usl_ok == 3 .and. k_data > 0d20201231 // ��
      // ��ࠡ��뢠�� 2021...2022...2023 �.�. ��� ����
      Go Top
      Do While !Eof()
        updatestatus()
        If 0 == fvdn_date_r( sys_date, human->date_r )  // ����஫� �� ��
          mdiagnoz := diag_for_xml(, .t.,,, .t. )
          ar_dn := {}
          If Between( human->ishod, 201, 205 )
            adiag_talon := Array( 16 )
            AFill( adiag_talon, 0 )
            For i := 1 To 16
              adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
            Next
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. padr(alltrim(mdiagnoz[ i ]),3) == "E10"
                  AAdd( ar_dn, AllTrim( mdiagnoz[ i ] ) )
              Endif
            Next
            If !Empty( ar_dn ) // ���� �� ��ᯠ��୮� �������
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := "mdiag" + sk
                pole_1dispans := "m1dispans" + sk
                pole_dn_dispans := "mdndispans" + sk
                &pole_diag := Space( 6 )
                &pole_1dispans := 0
                &pole_dn_dispans := CToD( "" )
              Next
              read_arr_dvn( human->kod )
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := "mdiag" + sk
                pole_1dispans := "m1dispans" + sk
                pole_dn_dispans := "mdndispans" + sk
                If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. !Empty( &pole_dn_dispans ) ;
                    .and. ( j := AScan( ar_dn, AllTrim( &pole_diag ) ) ) > 0
                  Select DN
                  find ( Str( human->KOD_K, 7 ) + PadR( ar_dn[ j ], 5 ) )
                  If !Found()
                    addrec( 7 )
                    dn->KOD_K := human->KOD_K
                    dn->KOD_DIAG := ar_dn[ j ]
                  Endif
                  dn->VRACH := human_->vrach
                  dn->PRVS := human_->prvs
                  If Empty( dn->N_DATA )
                    dn->N_DATA := human->k_data // ��� ��砫� ��ᯠ��୮�� �������
                  Endif
                  //
                  dn->LU_DATA := human->k_data // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
                  dn->NEXT_DATA := &pole_dn_dispans // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
                  If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                    n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
                    If Between( n, 1, 99 )
                      dn->FREQUENCY := n
                    Endif
                  Endif
                Endif
              Next
            Endif
          Else
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. padr(alltrim(mdiagnoz[ i ]),3) == "E10"
                AAdd( ar_dn, PadR( mdiagnoz[ i ], 5 ) )
              Endif
            Next
            If !Empty( ar_dn ) // �������� �� ᯨ᪠ ��ᯠ��୮�� �������
              Select HU
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
                If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                  lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                  If is_usluga_disp_nabl( lshifr )
                    For i := 1 To Len( ar_dn )
                      Select DN
                      find ( Str( human->KOD_K, 7 ) + ar_dn[ i ] )
                      If !Found()
                        addrec( 7 )
                        dn->KOD_K := human->KOD_K
                        dn->KOD_DIAG := ar_dn[ i ]
                      Endif
                      dn->VRACH := hu->KOD_VR
                      dn->PRVS := hu_->prvs // ���樠�쭮��� ��� �� �ࠢ�筨�� V004, � ����ᮬ - �� �ࠢ�筨�� V015
                      If Empty( dn->N_DATA )
                        dn->N_DATA := human->k_data // ��� ��砫� ��ᯠ��୮�� �������
                      Endif
                      //
                      dn->LU_DATA := human->k_data // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
                      dn->NEXT_DATA := c4tod( human->DATE_OPL ) // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
                      If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                        n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
                        If Between( n, 1, 99 )
                          dn->FREQUENCY := n
                        Endif
                      Endif
                      dn->MESTO := iif( hu->KOL_RCP < 0, 1, 0 ) // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
                    Next i
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      Commit
      Select DN
      Go Top
      Do While !Eof()
        updatestatus()
        If !Empty( dn->LU_DATA )
          If dn->FREQUENCY == 0
            dn->FREQUENCY := 1
          Endif
          k := Year( dn->NEXT_DATA )
          If !Between( k, 2023, 2025 ) // �� �᫨ �����४⭠� ��� ᫥�.�����
            dn->NEXT_DATA := AddMonth( dn->LU_DATA, 12 )
          Endif
          Do While dn->NEXT_DATA < 0d20240101 // ��
            dn->NEXT_DATA := AddMonth( dn->NEXT_DATA, dn->FREQUENCY )
          Enddo
          If dn->NEXT_DATA < 0d20240101
            dn->FREQUENCY := 0
          Endif
        Endif
        Skip
      Enddo
      //
      rest_box( buf )
      g_sunlock( S_sem )
    Endif

    */
    Close databases
    Private mdate_r, M1VZROS_REB
    /*
    If fl_umer
      If !g_slock( S_sem )
        Return func_error( 4, "����� � ����� ०�� ���� ������" )
      Endif
      buf := save_maxrow()
      waitstatus( "�� ᯨ᪠ �� ��ᯠ��୮�� ������� �� 2024 ��� 㤠������ ��� � 㬥�訥" )
      f_init_d01() // ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
      r_use( dir_server + "kartote2",, "_KART2" )
      r_use( dir_server + "kartotek",, "_KART" )
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Go Top
      Do While !Eof()
        updatestatus()
        If dn->kod_k > 0
          Select _KART
          Goto ( dn->kod_k )
          Select _KART2
          Goto ( dn->kod_k )
          fl := .f.
          If Left( _kart2->PC2, 1 ) == "1"  // ���� �� १���⠬ ᢥન
            fl := .t.
          Elseif !( _kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
            //
          Endif
         // if !fl
         //   mdate_r := _kart->date_r ; M1VZROS_REB := _kart->VZROS_REB
         //   fv_date_r(sys_date) // ��८�।������ M1VZROS_REB
         //   fl := (M1VZROS_REB > 0)
         // endif

          If fl
            Select DN
            // dn->kod_k := 0
            // DELETE
            dn->NEXT_DATA :=  dn->NEXT_DATA - 365
            dn->FREQUENCY := 0
          Endif
        Endif
        Select DN
        Skip
      Enddo
      Commit
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      Close databases
      rest_box( buf )
      g_sunlock( S_sem )
    Endif
*/
    if zaplatka_D_OPL
      If !g_slock( S_sem )
        Return func_error( 4, "����� � ����� ०�� ���� ������" )
      Endif
      buf := save_maxrow()
      waitstatus( "���室 �� ��ᯠ��୮� ������� �� 2024 ���" )
      f_init_d01() // ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      //
      g_use( dir_server + "mo_d01d" ,,"mo_d01d",.T.,.T.) // ᯨ᮪ ��������� ��樥�⮢
      Index On Str( kod_d, 7 ) to ( cur_dir + "tmp_kodd" ) 
      //{ "KOD_D",    "N", 6, 0 }, ; // ��� (����� �����) �� 䠩�� "mo_d01k"
      r_use( dir_server + "mo_d01k"  ) // ᯨ᮪ ��樥�⮢ � ॥����
      r_use( dir_server + "mo_d01"  ) // ᯨ᮪ ॥��஢
      //
      select MO_D01
      do while !eof()
        if year(MO_D01->dschet) > 2022
          select mo_D01K
          go Top
          do while !eof()
            if MO_D01K->reestr == MO_D01->kod
              // ��諨 �� ��樥�� �� ॥���
              select MO_D01D
              find (str(mo_d01k->(recno()),7))
              do while mo_d01d->kod_d == mo_d01k->(recno()) .and. !eof()
                // ���� �� ��������� ������� ��樥��
                t_rec := 0
                select DN 
                find(Str( mo_d01k->kod_k, 7 ) + mo_d01d->KOD_DIAG )
                if found()
                  t_rec := dn->(recno())
                endif 
                select MO_D01D
                g_rlock( forever )
                mo_d01d->oplata := mo_d01k->oplata
                mo_d01d->kod_n  := t_rec
                Unlock
                skip  // ��������
              enddo    
            endif     
            select MO_D01K // �
            skip  
          enddo
        Endif
        select mo_d01 // ॥����
        skip
      enddo    
      Close databases
      rest_box( buf )
      g_sunlock( S_sem )
    endif  

   /* if zaplatka_D09 
      
    endif  
  */  
    // �६���� �����
    //
    mas_pmt := { "~����� � 䠩���� ������ D01", ;
      "~���ଠ�� �� ���.�������" }
    mas_msg := { "�������� 䠩�� ������ D01... � ��� �� ��ࠢ����묨 ��樥�⠬� (����������)", ;
      "��ᬮ�� ���ଠ樨 �� १���⠬ ��ᯠ��୮�� �������" }
    mas_fun := { "disp_nabludenie(11)", ;
      "disp_nabludenie(12)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    mas_pmt := { "��ࢨ�� ~����", ;
      "~���ଠ��", ;
      "~����� � �����" }
    mas_msg := { "��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��", ;
      "���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����", ;
      "����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������" }
    mas_fun := { "disp_nabludenie(21)", ;
      "disp_nabludenie(22)", ;
      "disp_nabludenie(23)" }
    popup_prompt( T_ROW, T_COL - 5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 21
    mas_pmt := { "���� � ���᪮� �� ���饬� ~����", ;
      "���� � ���᪮� �� ~��樥���", ;
      "�����㧪� ��樥��~�� 2024"  }
    mas_msg := { "��ࢨ�� ���� ᢥ����� � ������ �� ���.���� � ���᪮� �� ���饬� ����", ;
      "��ࢨ�� ���� ᢥ����� � ������ �� ���.���� � ���᪮� �� ��樥���", ;
      "�����㧪� ����� ��樥�⮢ ��⠢�� �� �� � 2024 ���� "  }
    mas_fun := { "disp_nabludenie(51)", ;
      "disp_nabludenie(52)", ;
      "disp_nabludenie(53)"   }
    popup_prompt( T_ROW, T_COL - 5, si5, mas_pmt, mas_msg, mas_fun )
  Case k == 22
    mas_pmt := { "���ଠ�� �� ~��ࢨ筮�� �����", ;
      "���᮪ ��易⥫��� ~���������", ; // "~��樥��� � ���������� ��� ��ᯠ��୮�� ����"   "~���ଠ�� � �믮������",;
    "�������⥫�� ���� ��樥�⮢" }
    mas_msg := { "���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����", ;
      "���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������", ; // "���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)"              "���ଠ�� � �믮������ ��ᯠ��୮�� �������",;
    "�������⥫�� ���� ��樥�⮢ (���⨢�� ����������� � ���������� ��)" }
    mas_fun := { "disp_nabludenie(41)", ;
      "disp_nabludenie(42)", ;
      "disp_nabludenie(43)" }
    popup_prompt( T_ROW, T_COL - 5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 23
    // ne_real()
    mas_pmt := { "~�������� 䠩�� ������ D01", ;
      "~��ᬮ�� 䠩��� ������ D01" }
    mas_msg := { "�������� 䠩�� ������ D01... � ��� �� ��ࠢ����묨 ��樥�⠬� (����������)", ;
      "��ᬮ�� 䠩��� ������ D01... � १���⮢ ࠡ��� � ����" }
    mas_fun := { "disp_nabludenie(31)", ;
      "disp_nabludenie(32)" }
    popup_prompt( T_ROW, T_COL - 5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 41
    inf_disp_nabl()
  Case k == 42
    spr_disp_nabl()
  Case k == 43
    f_inf_dop_disp_nabl()
    // pac_disp_nabl()
  Case k == 31
    // ne_real()
    f_create_d01()
  Case k == 32
    f_view_d01()
  Case k == 51
    vvod_disp_nabl()
  Case k == 52
    vvodp_disp_nabl()
  Case k == 53
    vvodn_disp_nabl()  
  Case k == 12
    mas_pmt := { "~�� �뫮 �/� � ��ᯠ���� ��������", ;
                 "~�뫨 �/� � ��ᯠ���� ��������"}
    mas_msg := { "���᮪ ��樥�⮢, �� ����� �� �뫮 �/� � ��ᯠ���� ��������", ;
                 "���᮪ ��樥�⮢, �� ����� �뫨 �/� � ��ᯠ���� ��������"}
    mas_fun := { "disp_nabludenie(61)", ;
                 "disp_nabludenie(62)"}
  popup_prompt( T_ROW, T_COL - 5, si6, mas_pmt, mas_msg, mas_fun )
  Case k == 61
    f_inf_disp_nabl( 1 )
  Case k == 62
    f_inf_disp_nabl( 2 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Endif
  Endif

  Return Nil

// 17.01.14 ��८�।������ ����� "�����/ॡ񭮪" �� ��� ஦����� � "_date"
Function fvdn_date_r( _data, mdate_r )

  Local k,  cy, ldate_r := mdate_r

  Default _data To sys_date

  cy := count_years( ldate_r, _data )

  If cy < 14     ; k := 1  // ॡ����
  Elseif cy < 18 ; k := 2  // �����⮪
  else           ; k := 0  // �����
  Endif

  Return k


// 03.12.23
Function f_inf_dop_disp_nabl()

  Local arr, adiagnoz, sh := 80, HH := 60, buf := save_maxrow(), name_file := cur_dir + "disp_nabl" + stxt, ;
    buf1, ii1 := 0, s, s2, i, t_arr[ 2 ], ar, ausl, fl
  Private mm_dopo_na := { { "2.78", 1 }, { "2.79", 2 }, { "2.88 ��", 3 }, { "2.88 �� ��", 4 } }
  Private gl_arr := { ;  // ��� ��⮢�� �����
  { "dopo_na", "N", 10, 0,,,, {| x| inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
    }
  Private mdopo_na, m1dopo_na := 0, muchast, m1uchast := 0, arr_uchast := {}, ;
    m1period := 0, mperiod := Space( 10 ), parr_m
  m1dopo_na := SetBit( m1dopo_na, 3 )
  mdopo_na  := inieditspr( A__MENUBIT, mm_dopo_na, m1dopo_na )
  muchast := init_uchast( arr_uchast )
  buf1 := box_shadow( 15, 2, 19, 77, color1 )
  SetColor( cDataCGet )
  @ 16, 10 Say "�� ����� ��㣠� �஢����� ���.����" Get mdopo_na ;
    reader {| x| menu_reader( x, mm_dopo_na, A__MENUBIT,,, .f. ) }
  @ 17, 10 Say "���⮪ (���⪨)" Get muchast ;
    reader {| x| menu_reader( x, { {|k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION,,, .f. ) }
  @ 18, 10 Say "�� ����� ��ਮ� �६��� ���� ����" Get mperiod ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( parr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION,,, .f. ) }
  myread()
  rest_box( buf1 )
  If LastKey() == K_ESC .or. Empty( m1dopo_na )
    Return Nil
  Endif
  If !( ValType( parr_m ) == "A" )
    parr_m := Array( 8 )
    parr_m[ 5 ] := 0d20220101    // ��
    parr_m[ 6 ] := 0d20241231    // ��
  Endif
  stat_msg( "���� ���ଠ樨..." )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  arr_title := { ;
    "���������������������������������������������������������������������������������������������", ;
    "NN�  ��� ��樥��                               �   ���   ���� ��-� ���.� ��������         ", ;
    "��    ���� ��樥��                           � ஦����� ��饭�� ������ ��� ��           ", ;
    "���������������������������������������������������������������������������������������������" }
  sh := Len( arr_title[ 1 ] )
  s := "��樥���, �� �����訥 � ��ࢨ�� ᯨ᮪"
  add_string( "" )
  add_string( Center( s, sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  use_base( "lusl" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "mo_pers",, "PERS" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server + "human_",, "HUMAN_" )
  Set Relation To vrach into PERS
  r_use( dir_server + "human", dir_server + "humankk", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  Index On Str( kod_k, 7 ) + Descend( DToS( k_data ) ) to ( cur_dir + "tmp_humankk" ) ;
    For human_->USL_OK == 3 .and. Between( human->k_data, parr_m[ 5 ], parr_m[ 6 ] ) ;
    progress
  //
  r_use( dir_server + "mo_dnab",, "DD" )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_dd" ) For kod_k > 0
  r_use( dir_server + "kartote2",, "KART2" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART2
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kart->kod, 7 ) to ( cur_dir + "tmp_rhum" ) ;
    For kart->kod > 0
  Go Top
  Do While !Eof()
    fl := .t.
    If Left( kart2->PC2, 1 ) == "1"
      fl := .f.
    Elseif !( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
      fl := .f.
    Endif
    If fl
      mdate_r := kart->date_r ; M1VZROS_REB := kart->VZROS_REB
      fv_date_r( 0d20231201 ) // ��८�।������ M1VZROS_REB // ��
      fl := ( M1VZROS_REB == 0 )
    Endif
    If fl .and. !Empty( m1uchast )
      fl := f_is_uchast( arr_uchast, kart->uchast )
    Endif
    If fl
      Select DD
      find ( Str( kart->kod, 7 ) )
      fl := !Found() // ��� � 䠩�� ��� ���.�������
    Endif
    If fl
      Select HUMAN
      find ( Str( kart->kod, 7 ) )
      Do While human->kod_k == kart->kod .and. !Eof()
        ar := {}
        adiagnoz := diag_to_array()
        For i := 1 To Len( adiagnoz )
          If !Empty( adiagnoz[ i ] )
            s := PadR( adiagnoz[ i ], 5 )
            If f_is_diag_dn( s,,, .f. )
              AAdd( ar, s )
              fl := .t.
            Endif
          Endif
        Next i
        If Len( ar ) > 0 // ���� �᭮����, ���� ᮯ������騥 �������� �� ᯨ᪠
          ausl := ""
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
              left_lshifr_5 := Left( lshifr, 5 )
              If IsBit( m1dopo_na, 1 ) .and. left_lshifr_5 == "2.78."
                ausl := lshifr
              Elseif IsBit( m1dopo_na, 2 ) .and. left_lshifr_5 == "2.79."
                ausl := lshifr
              Elseif left_lshifr_5 == "2.88."
                If is_usluga_disp_nabl( lshifr )
                  If IsBit( m1dopo_na, 3 )
                    ausl := lshifr
                  Endif
                Else
                  If IsBit( m1dopo_na, 4 )
                    ausl := lshifr
                  Endif
                Endif
              Endif
            Endif
            If !Empty( ausl ) ; exit ; Endif
            Select HU
            Skip
          Enddo
          If !Empty( ausl )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ++ii1
            perenos( t_arr, arr2slist( ar ), 18 )
            add_string( Str( kart->uchast, 2 ) + " " + PadR( kart->fio, 45 ) + " " + full_date( kart->date_r ) + " " + date_8( human->k_data ) + ;
              Str( pers->tab_nom, 6 ) + " " + t_arr[ 1 ] )
            add_string( Space( 3 ) + PadR( kart->adres, 45 + 12 ) + PadR( ausl, 15 ) + t_arr[ 2 ] )
            Exit
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    @ MaxRow(), 1 Say lstr( ii1 ) Color cColorStMsg
    Select KART
    Skip
  Enddo
  Close databases
  rest_box( buf )
  If ii1 == 0
    FClose( fp )
    func_error( 4, "�� ������� ��樥�⮢, �� ����� �뫨 ��㣨� ����� ���� � ��������� �� ᯨ᪠" )
  Else
    add_string( "=== �������⥫쭮 ������� ��樥�⮢ - " + lstr( ii1 ) )
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, 2 )
  Endif

  Return Nil

  //02.10.24
  Function  vvodn_disp_nabl()  
    Static S_sem := "disp_nabludenie"
    
    if f_esc_enter( "�����㧪� ����� ��", .t. )
      
      Close databases
      If !g_slock( S_sem )
        Return func_error( 4, "����� � ����� ०�� ���� ������" )
      Endif
      buf := save_maxrow()
      waitstatus( "����! ���⠢����� ᯨ᮪ �� ��ᯠ��୮�� ������� �� 2024 ���" )
      //f_init_d01() // ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��୮�� �������
      // �஢��塞 �� ��������� �ਪ��� - �᫨ �������� ��� - 㤠�塞 ��樥�� �� ᯨ᪠
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      // ���⪠ �����襭�
      //
      r_use( dir_server + "uslugi",, "USL" )
      r_use( dir_server + "human_u_",, "HU_" )
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      Set Relation To RecNo() into HU_, To u_kod into USL
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_hfio" ) For human_->usl_ok == 3 .and. k_data > 0d20240101 // ��
      // ��ࠡ��뢠�� 2024 �������
      Go Top
      Do While !Eof()
        updatestatus()
        If 0 == fvdn_date_r( sys_date, human->date_r )  // ����஫� �� ��
          mdiagnoz := diag_for_xml(, .t.,,, .t. )
          ar_dn := {}
          If Between( human->ishod, 201, 205 )
            adiag_talon := Array( 16 )
            AFill( adiag_talon, 0 )
            For i := 1 To 16
              adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
            Next
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
                s := 3 // �� �������� ��ᯠ��୮�� �������
                If adiag_talon[ i * 2 -1 ] == 1 // �����
                  If adiag_talon[ i * 2 ] == 2
                    s := 2 // ���� �� ��ᯠ��୮� �������
                  Endif
                Elseif adiag_talon[ i * 2 -1 ] == 2 // ࠭��
                  If adiag_talon[ i * 2 ] == 1
                    s := 1 // ��⮨� �� ��ᯠ��୮� �������
                  Elseif adiag_talon[ i * 2 ] == 2
                    s := 2 // ���� �� ��ᯠ��୮� �������
                  Endif
                Endif
                If eq_any( s, 1, 2 ) // ���� ��� ��⮨� �� ��ᯠ��୮� �������
                  AAdd( ar_dn, AllTrim( mdiagnoz[ i ] ) )
                Endif
              Endif
            Next
            If !Empty( ar_dn ) // ���� �� ��ᯠ��୮� �������
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := "mdiag" + sk
                pole_1dispans := "m1dispans" + sk
                pole_dn_dispans := "mdndispans" + sk
                &pole_diag := Space( 6 )
                &pole_1dispans := 0
                &pole_dn_dispans := CToD( "" )
              Next
              read_arr_dvn( human->kod )
              For i := 1 To 5
                sk := lstr( i )
                pole_diag := "mdiag" + sk
                pole_1dispans := "m1dispans" + sk
                pole_dn_dispans := "mdndispans" + sk
                If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. !Empty( &pole_dn_dispans ) ;
                    .and. ( j := AScan( ar_dn, AllTrim( &pole_diag ) ) ) > 0
                  Select DN
                  find ( Str( human->KOD_K, 7 ) + PadR( ar_dn[ j ], 5 ) )
                  If !Found()
                    addrec( 7 )
                    dn->KOD_K := human->KOD_K
                    dn->KOD_DIAG := ar_dn[ j ]
                  Endif
                  dn->VRACH := human_->vrach
                  dn->PRVS := human_->prvs
                  If Empty( dn->N_DATA )
                    dn->N_DATA := human->k_data // ��� ��砫� ��ᯠ��୮�� �������
                  Endif
                  //
                  dn->LU_DATA := human->k_data // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
                  dn->NEXT_DATA := &pole_dn_dispans // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
                  If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                    n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
                    If Between( n, 1, 99 )
                      dn->FREQUENCY := n
                    Endif
                  Endif
                Endif
              Next
            Endif
          Else
            For i := 1 To Len( mdiagnoz )
              If !Empty( mdiagnoz[ i ] ) .and. f_is_diag_dn( mdiagnoz[ i ],,, .f. )
                AAdd( ar_dn, PadR( mdiagnoz[ i ], 5 ) )
              Endif
            Next
            If !Empty( ar_dn ) // �������� �� ᯨ᪠ ��ᯠ��୮�� �������
              Select HU
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
                If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                  lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                  If is_usluga_disp_nabl( lshifr )
                    For i := 1 To Len( ar_dn )
                      Select DN
                      find ( Str( human->KOD_K, 7 ) + ar_dn[ i ] )
                      If !Found()
                        addrec( 7 )
                        dn->KOD_K := human->KOD_K
                        dn->KOD_DIAG := ar_dn[ i ]
                      Endif
                      dn->VRACH := hu->KOD_VR
                      dn->PRVS := hu_->prvs // ���樠�쭮��� ��� �� �ࠢ�筨�� V004, � ����ᮬ - �� �ࠢ�筨�� V015
                      If Empty( dn->N_DATA )
                        dn->N_DATA := human->k_data // ��� ��砫� ��ᯠ��୮�� �������
                      Endif
                      //
                      dn->LU_DATA := human->k_data // ��� ���� ���� � 楫�� ��ᯠ��୮�� �������
                      dn->NEXT_DATA := c4tod( human->DATE_OPL ) // ��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������
                      If !emptyany( dn->LU_DATA, dn->NEXT_DATA ) .and. dn->NEXT_DATA > dn->LU_DATA
                        n := Round( ( dn->NEXT_DATA - dn->LU_DATA ) / 30, 0 ) // ������⢮ ����楢 � �祭�� ������ �।���������� ���� � ��樥��
                        If Between( n, 1, 99 )
                          dn->FREQUENCY := n
                        Endif
                      Endif
                      dn->MESTO := iif( hu->KOL_RCP < 0, 1, 0 ) // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
                    Next i
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      Commit
      Select DN
      Go Top
      Do While !Eof()
        updatestatus()
        If !Empty( dn->LU_DATA )
          If dn->FREQUENCY == 0
            dn->FREQUENCY := 1
          Endif
          k := Year( dn->NEXT_DATA )
          If !Between( k, 2023, 2025 ) // �� �᫨ �����४⭠� ��� ᫥�.�����
            dn->NEXT_DATA := AddMonth( dn->LU_DATA, 12 )
          Endif
          Do While dn->NEXT_DATA < 0d20240101 // ��
            dn->NEXT_DATA := AddMonth( dn->NEXT_DATA, dn->FREQUENCY )
          Enddo
          If dn->NEXT_DATA < 0d20240101
            dn->FREQUENCY := 0
          Endif
        Endif
        Skip
      Enddo
      Close databases
      //
      waitstatus( "�� ᯨ᪠ �� ��ᯠ��୮�� ������� �� 2024 ��� 㤠������ ��� � 㬥�訥" )
      r_use( dir_server + "kartote2",, "_KART2" )
      r_use( dir_server + "kartotek",, "_KART" )
      Use ( dir_server + "mo_dnab" ) New Alias DN
      Go Top
      Do While !Eof()
        updatestatus()
        If dn->kod_k > 0
          Select _KART
          Goto ( dn->kod_k )
          Select _KART2
          Goto ( dn->kod_k )
          fl := .f.
          If Left( _kart2->PC2, 1 ) == "1"  // ���� �� १���⠬ ᢥન
            fl := .t.
          Endif
          If fl
            Select DN
            dn->NEXT_DATA :=  dn->NEXT_DATA - 365
            dn->FREQUENCY := 0
          Endif
        Endif
        Select DN
        Skip
      Enddo
      Commit
      Index On Str( KOD_K, 7 ) + KOD_DIAG to ( dir_server + "mo_dnab" )
      Close databases
      //
      rest_box( buf )
      g_sunlock( S_sem )
      func_error( 4, "���������� ��樥�⮢ � �� �����襭� " )
    Endif
  Return Nil

// 02.12.19 ��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��
Function vvodp_disp_nabl()

  Local buf := SaveScreen(), k, s, s1, t_arr := Array( BR_LEN ), str_sem1, lcolor

  mywait()
  dbCreate( "tmp_kart", { ;
    { "KOD_K",    "N", 7, 0 }, ; // ��� �� ����⥪�
  { "FIO",      "C", 50, 0 }, ;
    { "POL",      "C", 1, 0 }, ;
    { "DATE_R",   "D", 8, 0 };
    } )
  Use ( cur_dir + "tmp_kart" ) new
  r_use( dir_server + "kartotek",, "_KART" )
  use_base( "mo_dnab" )
  Index On Str( kod_k, 7 ) to ( "tmp_dnab" ) For kod_k > 0 UNIQUE
  Go Top
  Do While !Eof()
    Select _kart
    Goto ( dn->kod_k )
    Select TMP_KART
    Append Blank
    tmp_kart->kod_k := dn->kod_k
    tmp_kart->fio := _kart->fio
    tmp_kart->pol := _kart->pol
    tmp_kart->date_r := _kart->date_r
    Select DN
    Skip
  Enddo
  _kart->( dbCloseArea() )
  dn->( dbCloseArea() )
  Select TMP_KART
  If LastRec() == 0
    Close databases
    RestScreen( buf )
    Return func_error( 4, "���᮪ ��� ��ᯠ��୮�� ������� ����. ���������� �१ ���� �� ���.����" )
  Endif
  Index On Upper( fio ) to ( cur_dir + "tmp_kart" )
  Go Top
  Do While alpha_browse( T_ROW, 7, MaxRow() -2, 71, "f1vvodP_disp_nabl", color8,,,,,,,,, { "�", "�", "�", } )
    f2vvodp_disp_nabl( tmp_kart->kod_k )
  Enddo
  Close databases
  RestScreen( buf )

  Return Nil

// 02.12.19
Function f1vvodp_disp_nabl( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( '�.�.�.', 50 ), {|| tmp_kart->fio } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '��� ஦�.', {|| full_date( tmp_kart->date_r ) } )
  oBrow:addcolumn( oColumn )

  Return Nil




// 23.12.22 ��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��
Function f2vvodp_disp_nabl( lkod_k )

  Local buf := SaveScreen(), k, s, s1, t_arr := Array( BR_LEN ), str_sem1, lcolor

  Private str_find, muslovie

  glob_kartotek := lkod_k
  str_sem1 := lstr( glob_kartotek ) + 'f2vvodP_disp_nabl'
  If g_slock( str_sem1 )
    str_find := Str( glob_kartotek, 7 ) ; muslovie := 'dn->kod_k == glob_kartotek'
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := MaxCol() -2
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := AllTrim( tmp_kart->fio ) + ' ' + full_date( tmp_kart->date_r )
    t_arr[ BR_TITUL_COLOR ] := 'B/BG'
    t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B', .t. }
    t_arr[ BR_OPEN ] := {| nk, ob| f1_vvod_disp_nabl( nk, ob, 'open' ) }
    t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find ) }, ;
      {| n| skippointer( n, muslovie ) }, ;
      str_find, muslovie ;
      }
    blk := {|| iif( emptyany( dn->vrach, dn->next_data, dn->frequency ) .or. dn->NEXT_DATA <= 0d20191201, { 3, 4 }, { 1, 2 } ) }
    t_arr[ BR_COLUMN ] := { { '���.;�����;���', {|| iif( dn->vrach > 0, ( p2->( dbGoto( dn->vrach ) ), p2->tab_nom ), 0 ) }, blk } }
    AAdd( t_arr[ BR_COLUMN ], { '�������;�����������', {|| dn->kod_diag }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { '   ���;���⠭����; �� ����', {|| full_date( dn->n_data ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { '   ���;᫥���饣�;���饭��', {|| full_date( dn->next_data ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { '���-��;����楢 �����;����⠬�', {|| put_val( dn->frequency, 7 ) }, blk } )
    AAdd( t_arr[ BR_COLUMN ], { '���� �஢������;��ᯠ��୮��;�������', {|| iif( Empty( dn->kod_diag ), Space( 7 ), iif( dn->mesto == 0, ' � ��  ', '�� ����' ) ) }, blk } )
    t_arr[ BR_EDIT ] := {| nk, ob| f3vvodp_disp_nabl( nk, ob, 'edit' ) }
    r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2' )
    use_base( 'mo_dnab' )
    edit_browse( t_arr )
    g_sunlock( str_sem1 )
    dn->( dbCloseArea() )
    p2->( dbCloseArea() )
  Else
    func_error( 4, "�� �⮬� ��樥��� � ����� ������ ������ ���ଠ�� ��㣮� ���짮��⥫�" )
  Endif
  Select TMP_KART
  RestScreen( buf )

  Return Nil

// 03.12.23
Function f3vvodp_disp_nabl( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec := 0, rec1, r1, r2, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }
  Local mm_dom := { { "� ��   ", 0 }, ;
    { "�� ����", 1 } }

  Do Case
  Case regim == "open"
    find ( str_find )
    ret := Found()
  Case regim == "edit"
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. dn->kod_k > 0 )
      If nKey == K_ENTER
        rec := RecNo()
      Endif
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 5, pc1, pr1 + 5, pc2, "N/N", "W+/N" )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
        mKOD_DIAG := iif( nKey == K_INS, Space( 5 ), dn->kod_diag ), ;
        mN_DATA := iif( nKey == K_INS, sys_date - 1, dn->n_data ), ;
        mNEXT_DATA := iif( nKey == K_INS, 0d20240101, dn->next_data ), ;  // ��
      mfrequency := iif( nKey == K_INS, 3, dn->frequency ), ;
        MVRACH := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
      M1VRACH := iif( nKey == K_INS, 0, dn->vrach ), MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
      mMESTO, m1mesto := iif( nKey == K_INS, 0, dn->mesto )
      mmesto := inieditspr( A__MENUVERT, mm_dom, m1mesto )
      If M1VRACH > 0
        p2->( dbGoto( dn->vrach ) )
        MTAB_NOM := p2->tab_nom
        m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
        mvrach := PadR( fam_i_o( p2->fio ) + " " + ret_tmp_prvs( m1prvs ), 36 )
      Endif
      p2->( dbCloseArea() )
      r1 := pr2 - 8 ; r2 := pr2 - 1
      tmp_color := SetColor( cDataCScr )
      box_shadow( r1, pc1 + 1, r2, pc2 - 1,, iif( nKey == K_INS, "����������", "������஢����" ), cDataPgDn )
      SetColor( cDataCGet )
      Do While .t.
        @ r1 + 1, pc1 + 3 Say "���騩 ���" Get MTAB_NOM Pict "99999" ;
          valid {| g| v_kart_vrach( g, .t. ) }
        @ Row(), Col() + 1 Get mvrach When .f. Color color14
        @ r1 + 2, pc1 + 3 Say "�������, �� ������ ���ண� ��樥�� �������� ���.�������" Get mkod_diag ;
          Pict "@K@!" reader {| o| mygetreader( o, bg ) } ;
          Valid val1_10diag( .t., .f., .f., 0d20191201, tmp_kart->pol )
        @ r1 + 3, pc1 + 3 Say "��� ��砫� ��ᯠ��୮�� �������" Get mn_data
        @ r1 + 4, pc1 + 3 Say "��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������" Get mnext_data
        @ r1 + 5, pc1 + 3 Say "���-�� ����楢 �� ������� ᫥���饣� �����" Get mfrequency Pict "99"
        @ r1 + 6, pc1 + 3 Say "���� �஢������ ��ᯠ��୮�� �������" Get mmesto ;
          reader {| x| menu_reader( x, mm_dom, A__MENUVERT,,, .f. ) }
        status_key( "^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����" )
        myread()
        If LastKey() != K_ESC .and. f_esc_enter( 1 )
          mKOD_DIAG := PadR( mKOD_DIAG, 5 )
          fl := .t.
          If Empty( mKOD_DIAG )
            fl := func_error( 4, "�� ����� �������" )
          Elseif !f_is_diag_dn( mKOD_DIAG,,, .f. )
            fl := func_error( 4, "������� �� �室�� � ᯨ᮪ �����⨬��" )
          Else
            Select DN
            find ( Str( glob_kartotek, 7 ) )
            Do While dn->kod_k == glob_kartotek .and. !Eof()
              If rec != RecNo() .and. mKOD_DIAG == dn->kod_diag
                fl := func_error( 4, "����� ������� 㦥 ����� ��� ������� ��樥��" )
                Exit
              Endif
              Skip
            Enddo
          Endif
          If Empty( mN_DATA )
            fl := func_error( 4, "�� ������� ��� ��砫� ��ᯠ��୮�� �������" )
          Elseif mN_DATA >= 0d20231201  // ��
            fl := func_error( 4, "��� ��砫� ��ᯠ��୮�� ������� ᫨誮� ������" )
          Endif
          If Empty( mNEXT_DATA )
            fl := func_error( 4, "�� ������� ��� ᫥���饩 �" )
          Elseif mN_DATA >= mNEXT_DATA
            fl := func_error( 4, "��� ᫥���饩 � ����� ���� ��砫� ��ᯠ��୮�� �������" )
          Elseif mNEXT_DATA <= 0d20240201  // ��
            fl := func_error( 4, "��� ᫥���饩 � ������ ���� �� ࠭�� 1 �������" ) // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! �६����
          Endif
          If !fl
            Loop
          Endif
          Select DN
          If nKey == K_INS
            fl_found := .t.
            addrec( 7 )
            dn->kod_k := glob_kartotek
            rec := RecNo()
          Else
            Goto ( rec )
            g_rlock( forever )
          Endif
          dn->vrach := m1vrach
          dn->prvs  := m1prvs
          dn->kod_diag := mKOD_DIAG
          dn->n_data := mN_DATA
          dn->next_data := mNEXT_DATA
          dn->frequency := mfrequency
          dn->mesto := m1mesto
          Unlock
          Commit
          oBrow:gotop()
          Goto ( rec )
          ret := 0
        Elseif nKey == K_INS .and. !fl_found
          ret := 1
        Endif
        Exit
      Enddo
      r_use( dir_server + "mo_pers", dir_server + "mo_pers", "P2" )
      Select DN
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof() .or. !&muslovie
        ret := 1
      Endif
    Endcase
  Endcase

  Return ret

  // 25.06.24  ������ ⨯� �������� 
  Function  check_tip_disp_nabl(diag)
  Local vozvr := 0  
   
    if check_diag_usl_disp_nabl( diag, "2.78.109") //��稥
      vozvr := 109
    endif  
    if vozvr == 0
      if check_diag_usl_disp_nabl( diag, "2.78.110") //���������
        vozvr := 110
      endif
    endif  
    if vozvr == 0
      if check_diag_usl_disp_nabl( diag, "2.78.111") //���� �.
        vozvr := 111
      endif
    endif  
    if vozvr == 0
      if check_diag_usl_disp_nabl( diag, "2.78.112") // ���
        vozvr := 112
      endif
    endif  
  return vozvr

// 01.07.24 ���᮪ ��樥�⮢, �� ����� �뫨 �/� � ��ᯠ���� ��������
Function f_inf_disp_nabl( par )

  // 1 -  "~�� �뫮 �/� � ��ᯠ���� ��������",;
  // 2 -  "~�뫨 �/� � ��ᯠ���� ��������"

   Local arr, arr_full_name, adiagnoz, sh := 120, HH := 60, buf := save_maxrow(), name_file := cur_dir + "disp_nabl" + stxt, ;
    ii1 := 0, ii2 := 0, ii3 := 0, s, name_dbf := "___DN" + sdbf, arr_fl, fl_prikrep := Space( 6 ), kol_kartotek := 0, ;
    t_kartotek := 0, s1
   Local arr_tip_DN := {"��稥 �� (2.78.109)","���������᪮� �� (2.78.110)","����� ������ �� (2.78.111)","��थ筮-��㤨�⮥ �� (2.78.112)"}
   Local arr_tip_DN1 := {"2.78.109","2.78.110","2.78.111","2.78.112"}
   Local arr_tip_KOD_USL := {109,110,111,112}
   Local mas_str_ot := {}, mas_str_ot_FULL := {}
   local flag_BILO := .F., flag_NAL := .T.
   dbCreate( cur_dir + "_disp_NB", { ;
       { "FIO",        "c", 50, 0 }, ;
       { "UCHAST",     "c",  3, 0 }, ;
       { "date_r",     "c", 10, 0 }, ;   
       { "Arr_d",      "c", 10, 0 }, ;
       { "prikrep",    "c",  3, 0 }, ;
       { "usluga",     "c",  8, 0 }, ;
       { "adres",      "c", 50, 0 }} )
  Use ( cur_dir + '_disp_NB' ) new
  stat_msg( "���� ���ଠ樨..." )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  arr_title := { ;
    "�������������������������������������������������������������������������������������������������������������������", ;
    "                                             �  � �   ���   ���������  ��   �                                     ", ;
    "              ��� ��樥��                   ���-�� ஦����� �  ��   ��ਪ९�             ����                   ", ;
    "�������������������������������������������������������������������������������������������������������������������" }
  sh := Len( arr_title[ 1 ] )
  If par == 1
    s := "���᮪ ��樥�⮢, ������ �� ��, �� ����� �� �뫮 �/� � ��ᯠ���� ��������"
  Elseif par == 2
    s := "���᮪ ��樥�⮢, ������ �� ��, ���������� �/� � ��ᯠ���� ��������"
  Endif
  s1 := '⮫쪮 "2.78.109", "2.78.110", "2.78.111", "2.78.112" '  
  add_string( "" )
  add_string( Center( s, sh ) )
  add_string( Center( s1, sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  use_base( "lusl" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "mo_pers",, "PERS" )
  r_use( dir_server + "schet_",, "SCHET_" )
  r_use( dir_server + "schet",, "SCHET" )
  Set Relation To RecNo() into SCHET_
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server + "human_",, "HUMAN_" )
  Set Relation To vrach into PERS
  r_use( dir_server + "human", dir_server + "humankk", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  Index On Str( kod_k, 7 ) + DToS( k_data ) to ( cur_dir + "tmp_humankk" ) ;
    For human_->USL_OK == 3 .and. human->k_data >= 0d20240101 ; // �.�. ⥪�騩 ���
  progress
  //
  r_use( dir_server + "mo_d01d",, "DD" )
  Index On Str( kod_d, 6 ) to ( cur_dir + "tmp_dd" )
  r_use( dir_server + "kartotek",, "KART" )
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartote2",, "KART2" )
  r_use( dir_server + "mo_d01k",, "RHUM" )
  Set Relation To kod_k into KART
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kart->kod, 7 ) to ( cur_dir + "tmp_rhum" ) ;
    For kart->kod > 0 .and. rhum->oplata == 1
  //
  for iii := 1 to 4    
    add_string( "" )
    add_string( Center( arr_tip_DN[iii], sh ) )
    add_string( "" )
  Go Top
  Do While !Eof()  // 横� �� �ᥩ ���� ����⥪� ������������� ����������
    arr := {}
    arr_fl := {}
    arr_full_name := {}
    Select DD
    find ( Str( rhum->( RecNo() ), 6 ) )
    // �᫨ 祫���� �⮨� �� �-��� - ᮧ���� ���ᨢ ��� � ���������
    Do While dd->kod_d == rhum->( RecNo() ) .and. !Eof()
      If dd->next_data >= 0d20240101 // !!!!!!! �������� ���
        if arr_tip_KOD_USL[iii] == check_tip_disp_nabl(dd->kod_diag)
          AAdd( arr, padr(dd->kod_diag,4) )   // �뫮 5
          AAdd( arr_fl, .f. )
          AAdd( arr_full_name, dd->kod_diag ) 
        endif  
      Endif
      Skip
    Enddo
    If Len( arr ) > 0
      // ���� ��
      fl1 := .f.
      // �஢��塞 ��樥�� �� �ਪ९�����
      fl_prikrep := Space( 6 )
      Select KART2
      Goto kart->kod
      If kart2->mo_pr != glob_mo[ _MO_KOD_TFOMS ]
        fl_prikrep := kart2->mo_pr
      Endif
      If Left( kart2->PC2, 1 ) == "1"
        fl_prikrep := " ���� "
      Endif
      Select KART_
      Goto kart->kod
      Select HUMAN
      find ( Str( kart->kod, 7 ) )
      Do While human->kod_k == kart->kod .and. !Eof()
        If human->k_data >= 0d20240101 // !!!!!!! �������� ���
          // �஢��塞 ⮫쪮 �� �᭮����� ��������
          fl := .f. ; ar := {}; zz := 0
          s := PadR( human->kod_diag, 4 )   // �뫮 5
          If ( zz := AScan( arr, s ) ) > 0
            fl := .t.
          Endif
          //
          If fl // ���� �᭮����, ���� ᮯ������騥 �������� �� ᯨ᪠
            fl1 := .t.
            fl_disp := .f. ; ausl := {}
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              // ��ᥪ��� ⮫쪮 ⥪�騩 ���
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                left_lshifr_8 := Left( lshifr, 8 )
                left_lshifr_6 := Left( lshifr, 7 )
                //left_lshifr_6 == "2.78.6" .or. left_lshifr_6 == "2.78.7" .or. left_lshifr_6 == "2.78.8" // (2.78.61__2.78.86)
                if iii == 1 .and. left_lshifr_8 == "2.78.109"
                  fl_disp := .t.
                  arr_fl[ zz ] := .t.
                elseif  iii == 2 .and. left_lshifr_8 == "2.78.110" 
                  fl_disp := .t.
                  arr_fl[ zz ] := .t.
                elseif  iii == 3 .and. left_lshifr_8 == "2.78.111"
                  fl_disp := .t.
                  arr_fl[ zz ] := .t.
                elseif  iii == 4 .and. left_lshifr_8 == "2.78.112"  
                  fl_disp := .t.
                  arr_fl[ zz ] := .t.
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      If par == 1 // �� �뫮 �/� � ��ᯠ���� �������� �� ����稨 ��
        mas_str_ot := {}
        mas_str_ot_FULL := {}
        flag_BILO := .F.
        flag_NAL := .T.
        For i := 1 To Len( arr )
          If !arr_fl[ i ]
            if flag_NAL
              ttt :=  PadR( ". " + kart->fio, 40 ) + " " + PadL( lstr( kart->uchast ), 4 ) + " " + full_date( kart->date_r ) + "  " + PadR( arr_full_name[ i ], 5 ) + "   " + fl_prikrep + " " + ;
                PadR( iif(len(alltrim(kart->adres))<3,AllTrim( ret_okato_ulica( "", kart_->okatog, 3, 2 ) ) + " " + LTrim( kart->adres ),kart->adres ), 40 ) 
            else
              ttt :=  space(45 ) + " " + space( 4 ) + " " + space(10) + "  " + PadR( arr_full_name[ i ], 5 ) 
            endif  
            aadd(mas_str_ot, ttt)
            aadd(mas_str_ot_FULL,{kart->fio,kart->uchast,kart->date_r,arr_full_name[ i ],;
              fl_prikrep,iif(len(alltrim(kart->adres))<3,AllTrim( ret_okato_ulica( "", kart_->okatog, 3, 2 ) ) + " " + LTrim( kart->adres ),PadR( kart->adres, 40 ) )})
            flag_NAL := .F.
    //        If t_kartotek != kart->kod
    //          t_kartotek := kart->kod
    //          kol_kartotek++
    //        Endif
          else
            flag_BILO := .T.
          Endif
        Next
        if !flag_BILO
          for i := 1 to len(mas_str_ot)
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            if i == 1
              add_string(padl(lstr( ++ii2 ),5)+mas_str_ot[i])
            else  
              add_string(mas_str_ot[i])
            endif  
            if i == 1
              select _disp_NB
              append blank 
              _disp_NB->fio     := mas_str_ot_FULL[i,1]              
              _disp_NB->UCHAST  := alltrim(str(mas_str_ot_FULL[i,2]))
              _disp_NB->date_r  := alltrim(full_date(mas_str_ot_FULL[i,3]))
              _disp_NB->arr_d   := mas_str_ot_FULL[i,4] 
              _disp_NB->prikrep := iif(mas_str_ot_FULL[i,5] == glob_mo[_MO_KOD_TFOMS].or.len(alltrim(mas_str_ot_FULL[i,5]))<1,"��","���") 
              _disp_NB->adres   := mas_str_ot_FULL[i,6]  
              _disp_NB->usluga  := arr_tip_DN1[iii]
            endif  
          next  
        endif  
      Endif
      If par == 2 // �뫨 �/� � ��ᯠ���� �������� �� ����稨 ��
        mas_str_ot := {}
        mas_str_ot_FULL := {}
        flag_BILO := .F.
        flag_NAL := .T.
        For i := 1 To Len( arr )
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          If arr_fl[ i ]
            if flag_NAL
              ttt :=  PadR( ". " + kart->fio, 40 ) + " " + PadL( lstr( kart->uchast ), 4 ) + " " + full_date( kart->date_r ) + "  " + PadR(arr_full_name [ i ], 5 ) + "   " + fl_prikrep + " " + ;
                PadR( iif(len(alltrim(kart->adres))<3,AllTrim( ret_okato_ulica( "", kart_->okatog, 3, 2 ) ) + " " + LTrim( kart->adres ),kart->adres ), 40 ) 
            else
              ttt :=  space(45 ) + " " + space( 4 ) + " " + space(10) + "  " + PadR(arr_full_name [ i ], 5 ) 
            endif  
            aadd(mas_str_ot, ttt)
            aadd(mas_str_ot_FULL,{kart->fio,kart->uchast,kart->date_r,arr_full_name[ i ],;
              fl_prikrep,iif(len(alltrim(kart->adres))<3,AllTrim( ret_okato_ulica( "", kart_->okatog, 3, 2 ) ) + " " + LTrim( kart->adres ),PadR( kart->adres, 40 ) )})
            flag_NAL := .F.
  //          If t_kartotek != kart->kod
  //            t_kartotek := kart->kod
  //            kol_kartotek++
  //          Endif
          else
            flag_BILO := .T.
          Endif
        Next
        if !flag_BILO
          for i := 1 to len(mas_str_ot)
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            if i == 1
              add_string(padl(lstr( ++ii2 ),5)+mas_str_ot[i])
            else  
              add_string(mas_str_ot[i])
            endif  
            if i == 1
              select _disp_NB
              append blank 
              _disp_NB->fio     := mas_str_ot_FULL[i,1]              
              _disp_NB->UCHAST  := alltrim(str(mas_str_ot_FULL[i,2]))
              _disp_NB->date_r  := alltrim(full_date(mas_str_ot_FULL[i,3]))
              _disp_NB->arr_d   := mas_str_ot_FULL[i,4] 
              _disp_NB->prikrep := iif(mas_str_ot_FULL[i,5] == glob_mo[_MO_KOD_TFOMS].or.len(alltrim(mas_str_ot_FULL[i,5]))<1,"��","���") 
              _disp_NB->adres   := mas_str_ot_FULL[i,6]  
              _disp_NB->usluga  := arr_tip_DN1[iii]
            endif  
          next  
        endif  
      Endif
    Endif
    Select RHUM
    Skip
  Enddo // kartotek
next
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, 3 )
  n_message( { "������ 䠩� ��� ����㧪� � Excel: _disp_NB" },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
  Return Nil




// 09.12.18 ��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��
Function vvod_disp_nabl()

  Local buf := SaveScreen(), k, s, s1, t_arr := Array( BR_LEN ), str_sem1, lcolor
  Private str_find, muslovie

  If input_perso( T_ROW, T_COL - 5 )
    Do While .t.
      buf := SaveScreen()
      k := -ret_new_spec( glob_human[ 7 ], glob_human[ 8 ] )
      box_shadow( 0, 0, 2, 49, color13,,, 0 )
      @ 0, 0 Say PadC( "[" + lstr( glob_human[ 5 ] ) + "] " + glob_human[ 2 ], 50 ) Color color14
      @ 1, 0 Say PadC( ret_tmp_prvs( k ), 50 ) Color color14
      @ 2, 0 Say PadC( "... �롮� ��樥�� ...", 50 ) Color color1
      k := polikl1_kart()
      Close databases
      //
      str_sem1 := lstr( glob_kartotek ) + "f2vvodP_disp_nabl"
      If k == 0
        Exit
      Elseif g_slock( str_sem1 )
        s1 := f0_vvod_disp_nabl()
        r_use( dir_server + "kartote2",, "_KART2" )
        Goto ( glob_kartotek )
        r_use( dir_server + "kartotek",, "_KART" )
        Goto ( glob_kartotek )
        s := AllTrim( PadR( _kart->fio, 37 ) ) + " (" + full_date( _kart->date_r ) + ")"
        lcolor := color1
        If Left( _kart2->PC2, 1 ) == "1"
          s := "���� " + s ; lcolor := color8
        Elseif !( _kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
          s := "�� ��� " + s ; lcolor := color8
        Endif
        @ 2, 0 Say PadC( s, 50 ) Color lcolor
        mdate_r := _kart->date_r ; M1VZROS_REB := _kart->VZROS_REB
        fv_date_r( sys_date ) // ��८�।������ M1VZROS_REB
        If M1VZROS_REB > 0
          func_error( 4, "����� ०�� ⮫쪮 ��� ������, � ��࠭�� ��樥�� ���� �������!" )
        Else
          If .f. // !empty(s1)
            box_shadow( 3, 0, 3, 49, color13, Center( s1, 50 ), "BG+/B", 0 )
          Endif
          str_find := Str( glob_kartotek, 7 ) ; muslovie := "dn->kod_k == glob_kartotek"
          t_arr[ BR_TOP ] := T_ROW
          t_arr[ BR_BOTTOM ] := MaxRow() -2
          t_arr[ BR_LEFT ] := 2
          t_arr[ BR_RIGHT ] := MaxCol() -2
          t_arr[ BR_COLOR ] := color0
          t_arr[ BR_ARR_BROWSE ] := {,,,, .t. }
          t_arr[ BR_OPEN ] := {| nk, ob| f1_vvod_disp_nabl( nk, ob, "open" ) }
          t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
            {|| findlast( str_find ) }, ;
            {| n| skippointer( n, muslovie ) }, ;
            str_find, muslovie;
            }
          t_arr[ BR_COLUMN ] := { { "�������;�����������", {|| dn->kod_diag } } }
          AAdd( t_arr[ BR_COLUMN ], { "   ���;���⠭����; �� ����", {|| full_date( dn->n_data ) } } )
          AAdd( t_arr[ BR_COLUMN ], { "   ���;᫥���饣�;���饭��", {|| full_date( dn->next_data ) } } )
          AAdd( t_arr[ BR_COLUMN ], { "���-��;����楢 �����;����⠬�", {|| put_val( dn->frequency, 7 ) } } )
          AAdd( t_arr[ BR_COLUMN ], { "���� �஢������;��ᯠ��୮��;�������", {|| iif( Empty( dn->kod_diag ), Space( 7 ), iif( dn->mesto == 0, " � ��  ", "�� ����" ) ) } } )
          t_arr[ BR_EDIT ] := {| nk, ob| f1_vvod_disp_nabl( nk, ob, "edit" ) }
          use_base( "mo_dnab" )
          edit_browse( t_arr )
        Endif
        g_sunlock( str_sem1 )
      Else
        func_error( 4, "�� �⮬� ��樥��� � ����� ������ ������ ���ଠ�� ��㣮� ���짮��⥫�" )
      Endif
      Close databases
      RestScreen( buf )
    Enddo
  Endif
  Close databases
  RestScreen( buf )

  Return Nil


// 09.12.18
Function f0_vvod_disp_nabl()

  Local s := ""

  r_use( dir_server + "mo_d01k",, "DK" )
  Index On Str( reestr, 6 ) to ( cur_dir + "tmp_dk" ) For kod_k == glob_kartotek
  Go Top
  Do While !Eof()
    If dk->oplata == 0
      s := "��ࠢ��� � ����� - �⢥� ��� �� ����祭"
      Exit
    Elseif dk->oplata == 1
      s := "��ࠢ��� � ����� - ��� �訡��"
      Exit
    Else
      s := "������ �� ����� � �訡����"
    Endif
    Skip
  Enddo
  dk->( dbCloseArea() )

  Return s



// 03.12.23
Function f1_vvod_disp_nabl( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec := 0, rec1, r1, r2, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }
  Local mm_dom := { { "� ��   ", 0 }, ;
    { "�� ����", 1 } }

  Do Case
  Case regim == "open"
    find ( str_find )
    ret := Found()
  Case regim == "edit"
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. dn->kod_k > 0 )
      If nKey == K_ENTER .and. dn->vrach != glob_human[ 1 ]
        func_error( 4, "������ ��ப� ������� ��㣨� ��箬!" )
        Return ret
      Endif
      If nKey == K_ENTER
        rec := RecNo()
      Endif
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 5, pc1, pr1 + 5, pc2, "N/N", "W+/N" )
      Endif
      Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
        mKOD_DIAG := iif( nKey == K_INS, Space( 5 ), dn->kod_diag ), ;
        mN_DATA := iif( nKey == K_INS, sys_date - 1, dn->n_data ), ;
        mNEXT_DATA := iif( nKey == K_INS, 0d20240201, dn->next_data ), ; // �� - ��������
      mfrequency := iif( nKey == K_INS, 3, dn->frequency ), ;
        mMESTO, m1mesto := iif( nKey == K_INS, 0, dn->mesto )
      mmesto := inieditspr( A__MENUVERT, mm_dom, m1mesto )
      r1 := pr2 - 7 ; r2 := pr2 - 1
      tmp_color := SetColor( cDataCScr )
      box_shadow( r1, pc1 + 1, r2, pc2 - 1,, iif( nKey == K_INS, "����������", "������஢����" ), cDataPgDn )
      SetColor( cDataCGet )
      Do While .t.
        @ r1 + 1, pc1 + 3 Say "�������, �� ������ ���ண� ��樥�� �������� ���.�������" Get mkod_diag ;
          Pict "@K@!" reader {| o| mygetreader( o, bg ) } ;
          Valid val1_10diag( .t., .f., .f., 0d20231201, _kart->pol )  // ��
        @ r1 + 2, pc1 + 3 Say "��� ��砫� ��ᯠ��୮�� �������" Get mn_data
        @ r1 + 3, pc1 + 3 Say "��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������" Get mnext_data
        @ r1 + 4, pc1 + 3 Say "���-�� ����楢 �� ������� ᫥���饣� �����" Get mfrequency Pict "99"
        @ r1 + 5, pc1 + 3 Say "���� �஢������ ��ᯠ��୮�� �������" Get mmesto ;
          reader {| x| menu_reader( x, mm_dom, A__MENUVERT,,, .f. ) }
        status_key( "^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����" )
        myread()
        If LastKey() != K_ESC .and. f_esc_enter( 1 )
          mKOD_DIAG := PadR( mKOD_DIAG, 5 )
          fl := .t.
          If Empty( mKOD_DIAG )
            fl := func_error( 4, "�� ����� �������" )
          Elseif !f_is_diag_dn( mKOD_DIAG,,, .f. )
            fl := func_error( 4, "������� �� �室�� � ᯨ᮪ �����⨬��" )
          Else
            Select DN
            find ( Str( glob_kartotek, 7 ) )
            Do While dn->kod_k == glob_kartotek .and. !Eof()
              If rec != RecNo() .and. mKOD_DIAG == dn->kod_diag
                fl := func_error( 4, "����� ������� 㦥 ����� ��� ������� ��樥��" )
                Exit
              Endif
              Skip
            Enddo
          Endif
          If Empty( mN_DATA )
            fl := func_error( 4, "�� ������� ��� ��砫� ��ᯠ��୮�� �������" )
          Elseif mN_DATA >= 0d20231201  // ��
            fl := func_error( 4, "��� ��砫� ��ᯠ��୮�� ������� ᫨誮� ������" )
          Endif
          If Empty( mNEXT_DATA )
            fl := func_error( 4, "�� ������� ��� ᫥���饩 �" )
          Elseif mN_DATA >= mNEXT_DATA
            fl := func_error( 4, "��� ᫥���饩 � ����� ���� ��砫� ��ᯠ��୮�� �������" )
          Elseif mNEXT_DATA <= 0d20240201  // �� - �६����
            fl := func_error( 4, "��� ᫥���饩 � ������ ���� �� ࠭�� 1 ﭢ���" )
          Endif
          If !fl
            Loop
          Endif
          Select DN
          If nKey == K_INS
            fl_found := .t.
            addrec( 7 )
            dn->kod_k := glob_kartotek
            rec := RecNo()
          Else
            Goto ( rec )
            g_rlock( forever )
          Endif
          dn->vrach := glob_human[ 1 ]
          dn->prvs  := iif( Empty( glob_human[ 8 ] ), glob_human[ 7 ], -glob_human[ 8 ] )
          dn->kod_diag := mKOD_DIAG
          dn->n_data := mN_DATA
          dn->next_data := mNEXT_DATA
          dn->frequency := mfrequency
          dn->mesto := m1mesto
          Unlock
          Commit
          oBrow:gotop()
          Goto ( rec )
          ret := 0
        Elseif nKey == K_INS .and. !fl_found
          ret := 1
        Endif
        Exit
      Enddo
      Select DN
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof() .or. !&muslovie
        ret := 1
      Endif
    Endcase
  Endcase

  Return ret



// 09.12.18 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function f2_vvod_disp_nabl( ldiag )

  Local fl := .f., lfp, i, s, d1, d2

  If len_diag == 0
    lfp := FOpen( file_form )
    Do While !feof( lfp )
      s := freadln( lfp )
/*for i := 1 to len(s) // �஢�ઠ �� ���᪨� �㪢� � ���������
  if ISRALPHA(substr(s,i,1))
    strfile(s+eos,"ttt.ttt",.t.)
    exit
  endif
next*/
      If !Empty( s )
        AAdd( diag1, AllTrim( s ) )
      Endif
    Enddo
    FClose( lfp )
    len_diag := Len( diag1 )
  Endif

  Return AScan( diag1, AllTrim( ldiag ) ) > 0



// 17.12.23 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function inf_disp_nabl()

  Static suchast := 0, svrach := 0, sdiag := '', ;
    mm_spisok := { { "���� ᯨ᮪ ��樥�⮢", 0 }, { "� ������� ������", 1 }, { "� ���४�� ������", 2 } }
  Local bg := {| o, k| get_mkb10( o, k, .f. ) }
  Local buf := SaveScreen(), r := 12, sh, HH := 60, name_file := cur_dir + "info_dn" + stxt, ru := 0, ;
    rd := 0, rd1 := 0, rpr := 0, ro_f := .f., ro := 0, rod := 0
  Local mas_tip_dz := { 0, 0, 0, 0, 0 }, mas_tip_pc := { 0, 0, 0, 0, 0, 0 }, fl_1 := 0, fl_2 := 0, fl_3 := 0, fl_4 := 0, ;
    fl_5 := 0, fl_31 := 0, fl_32 := 0, fl_33 := 0, fl_umer := .t., otvet := "      ", fl_prinet := .F.,;
    mas_tip_prin := { 0, 0, 0, 0, 0, 0 } , t_mo_prik := "", iii := 0, iii1 := 0, iii2 := 0 

  SetColor( cDataCGet )
  myclear( r )
  Private muchast := suchast, ;
    mvrach := svrach, ;
    mkod_diag := PadR( sdiag, 5 ), ;
    mkod_diag1 := "   ", mkod_diag2 := "   ", ;
    m1spisok := 0, mspisok := mm_spisok[ 1, 1 ], ;
    m1adres := 0, madres := mm_danet[ 1, 1 ], ;
    m1umer := mm_danet[1, 2], mumer := mm_danet[ 1, 1 ], ;   
    m1period := 0, mperiod := Space( 10 ), parr_m, ;
    gl_area := { r, 0, MaxRow() -1, MaxCol(), 0 }
  status_key( "^<Esc>^ - ��室;  ^<PgDn>^ - ��⠢����� ���㬥��" )
  //
  @ r, 0 To r + 11, MaxCol() Color color8
  str_center( r, " ����� ���ଠ樨 �� ���񭭮�� ��ᯠ��୮�� ������� ", color14 )
  @ r + 2, 2 Say "����� ���⪠ (0 - �� �ᥬ ���⪠�)" Get muchast Pict "99999"
  @ r + 3, 2 Say "������� ����� ��� (0 - �� �ᥬ ��砬)" Get mvrach Pict "99999"
  @ r + 4, 2 Say "������� (��� ��砫�� 1-2 ᨬ����, ��� ����� ��ப�)" Get mkod_diag ;
    Pict "@K@!" reader {| o| mygetreader( o, bg ) }
  @ r + 5, 2 Say "  ��� �������� ���������" Get mkod_diag1 ;
    Pict "@K@!" reader {| o| mygetreader( o, bg ) } When Empty( mkod_diag )
  @ Row(), Col() Say " -" Get mkod_diag2 ;
    Pict "@K@!" reader {| o| mygetreader( o, bg ) } When Empty( mkod_diag )
  @ r + 6, 2 Say "������ ᯨ᪠" Get mspisok ;
    reader {| x| menu_reader( x, mm_spisok, A__MENUVERT,,, .f. ) }
  @ r + 7, 2 Say "��� ���⠭���� �� ��ᯠ��୮� �������" Get mperiod ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( parr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION,,, .f. ) }
  @ r + 8, 2 Say "�뢮���� ���� ��樥�⮢" Get madres ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
  @ r + 9, 2 Say "�뢮���� ������ ��樥�⮢" Get mumer ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
  myread()
  If LastKey() != K_ESC
    If !( ValType( parr_m ) == "A" )
      parr_m := Array( 8 )
      parr_m[ 5 ] := 0d19000101    // ��
      parr_m[ 6 ] := 0d20241231    // ��
    Endif
    If mvrach > 0
      r_use( dir_server + "mo_pers", dir_server + "mo_pers", "PERSO" )
      find ( Str( mvrach, 5 ) )
      If Found()
        glob_human := { perso->kod, ;
          AllTrim( perso->fio ), ;
          perso->uch, ;
          perso->otd, ;
          mvrach, ;
          AllTrim( perso->name_dolj ), ;
          perso->prvs, ;
          perso->prvs_new }
        fl1 := .t.
      Else
        func_error( 4, "����㤭��� � ⠡���� ����஬ " + lstr( i ) + " ��� � ���� ������ ���ᮭ���!" )
        mvrach := 0
      Endif
      Close databases
    Endif
    d1 := d2 := 0
    If Empty( mkod_diag )
      mkod_diag1 := AllTrim( mkod_diag1 )
      mkod_diag2 := AllTrim( mkod_diag2 )
      If Len( mkod_diag1 ) == 3 .and. Len( mkod_diag2 ) == 3
        d1 := diag_to_num( mkod_diag1, 1 )
        d2 := diag_to_num( mkod_diag2, 2 )
      Endif
    Else
      fl_all_diag := .f.
      mkod_diag := AllTrim( mkod_diag ) ; l := Len( mkod_diag )
      If f_is_diag_dn( mkod_diag,,, .f. )
        fl_all_diag := .t.
      Endif
    Endif
    //
    suchast := muchast
    svrach := mvrach
    sdiag := mkod_diag
    //
    arr_title := { ;
      "�����������������������������������������������������������������������������������������������������������������", ;
      " �⢥�                                      �   ���   �  ��  ��� ���.�����-���� ��-���� ��-�_������騩_�����", ;
      "      �        ��� ��樥��                  � ஦����� ��ਪ-ﳠ᳭���೭��  �᫥�������⠭�����        ��१ N", ;
      " ������                                      �   ���   �      �⮳��砳     �   ��   ��� ���� �  ���  �����楢", ;
      "�����������������������������������������������������������������������������������������������������������������" }
    sh := Len( arr_title[ 1 ] )
    mywait()
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "���᮪ ��樥�⮢, ������ �� ��ᯠ��୮� ����", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //r_use( dir_server + "mo_D01",,   "D01" )  //॥����
    //r_use( dir_server + "mo_D01K",,  "D01K" ) // ��樥��� � ॥����
    //index on str(reestr,6)+str(kod_k,7) to (cur_dir +"tmp_D01")
    r_use( dir_server + "mo_D01D",,  "D01D" ) // �������� � ��樥�⮢   
    index on str(kod_n,6)+str(kod_d,7) to (cur_dir +"tmp_D01") DESCENDING
    r_use( dir_server + "mo_pers",,  "PERS" )
    r_use( dir_server + "kartote2",, "KART2" )
    r_use( dir_server + "kartote_",, "KART_" )
    r_use( dir_server + "kartotek",, "KART" )
    r_use_base( "mo_dnab" )
    Set Relation To kod_k into KART, To kod_k into KART_, To vrach into PERS
    Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( dn->kod_k, 7 ) + dn->kod_diag to ( cur_dir + "tmp_dn" ) ;
      For kart->kod > 0
    old := r := rs := ro := 0
    sadres := ""
    fl_umer := .t.
    waitstatus( "����! ���⠢����� ᯨ᮪, ������ �� ��ᯠ��୮� ����" )
    Go Top
    Do While !Eof()  // ���� �� 䠩�� � �ᥬ� ��
      updatestatus()
      otvet := "       "
      ro_f := .f.
      fl := .t.
      //fl_umer := .t.
      If Between( dn->n_data, parr_m[ 5 ], parr_m[ 6 ] )
        fl := .t.
      Else
        fl := .f.
      Endif
      If muchast > 0
        fl := ( kart->uchast == muchast )
      Endif
      If fl .and. mvrach > 0
        fl := ( glob_human[ 1 ] == dn->vrach )
      Endif
      If fl .and. !Empty( mkod_diag )
        If fl_all_diag
          fl := ( AllTrim( dn->kod_diag ) == mkod_diag )
        Else
          fl := ( Left( dn->kod_diag, l ) == mkod_diag )
        Endif
      Endif
      If fl .and. !emptyany( d1, d2 )
        fl := Between( diag_to_num( dn->kod_diag, 1 ), d1, d2 )
      Endif
      If fl .and. m1spisok > 0
        If dn->next_data < 0d20240101 .or. Empty( dn->frequency )  // ��
          fl := iif( m1spisok == 1, .t., .f. )
        Else
          fl := iif( m1spisok == 2, .t., .f. )
        Endif
      Endif
      If fl .and. ( 1 == fvdn_date_r( sys_date, kart->date_r ) .or. 2 == fvdn_date_r( sys_date, kart->date_r ) )
        fl := .f.
      Endif
     //
      If fl 
        If old == dn->kod_k // �� ��ࢠ� ��ப� � ��樥��
          If !Empty( sadres )
            s := PadR( "  " + sadres, 38 + 1 + 10 + 3 + 7 )
            sadres := ""
          Else
            s := Space( 38 ) + Space( 1 + 10 + 3 + 7 )
          Endif
        Else
          fl_prinet := .F. // �� 㬮�砭�� - �� �ਭ��
          If !Empty( sadres )
            add_string( "  " + sadres )
          Endif
          s := PadR( kart->fio, 38 ) + " " + full_date( kart->date_r )
          Select KART2
          Goto kart->kod
          If !Empty( kart2->mo_pr )
            If glob_mo[ _MO_KOD_TFOMS ] == kart2->mo_pr
              s := s + " � ��� "
            Else
              s := s + " " + kart2->mo_pr
              ++rpr
              ro_f := .t.
            Endif
            t_mo_prik := kart2->mo_pr
          Else
            s := s + Space( 7 )
          Endif
          If Left( kart2->PC2, 1 ) == "1"
            s := s + "���"
            ++ru
            ro_f := .t.
            fl_umer := .f.  // �⬥⪠ ��樥�� 㬥�
          Else
            s := s + Str( kart->uchast, 3 )
            fl_umer := .T.  // �⬥⪠ ��樥�� 㬥�
          Endif
          If m1adres == 1
            sadres := ret_okato_ulica( kart->adres, kart_->okatog, 0, 1 )
          Endif
          ++r
          If !ro_f
            ++ro
          Endif
        Endif
        s += Str( pers->tab_nom, 6 ) + " " + dn->kod_diag + " " + date_8( dn->lu_data ) + " " + date_8( dn->n_data ) + " " + date_8( dn->next_data )
        s += iif( dn->next_data < 0d20240101, "___", "   " )   // ��
        If dn->next_data < 0d20240101
          s += "_____"
        Else
          s += iif( Empty( dn->frequency ), "_____", Str( dn->frequency, 5 ) )
        Endif
        If f_is_diag_dn_neobez( dn->kod_diag )
          s += " **"
        Endif
        //
        t_vr := select()
        select D01D
        //r_use( dir_server + "mo_D01D",,  "D01D" ) // �������� � ��樥�⮢   
        //index on str(kod_n,6)+str(kod_d,7) to (cur_dir +"tmp_D01") DESCENDING
        fl_prinet := .F.
        otvet  :=  "       "
        find(str(dn->(recno()),6))
        if found()
          if d01d->OPLATA == 1 
             fl_prinet := .T.
             otvet  := "�ਭ�� " 
          elseif d01d->OPLATA == 0    
             otvet  := "       "
          else 
             otvet  := "������ " 
          endif
        else
          otvet  := "       "
        endif  
        select(t_vr)
        s := otvet + s
        //
        If dn->next_data < 0d20240101  // ��
          ++rd
        Endif
        If Empty( dn->frequency )
          ++rd1
        Endif
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        if m1umer == 1
          //add_string( s )
          //++iii1 
        else
          if fl_umer
            add_string( s )
            ++iii1 
          endif 
        endif  
        old := dn->kod_k
        ++rs
        If !ro_f
          ++rod
        Endif
        // �롮ન �� �⤥��� ��㯯�� ��������� 
        // �������  !!! �� �������
        // ⮫쪮 ������ �� � �����
        If fl_umer 
          //my_debug(,str(dn->(recno()))+" -----  "+ t_mo_prik + " --- "+ dtos(dn->next_data) )
          //my_debug(,fl_prinet)
          If glob_mo[ _MO_KOD_TFOMS ] ==  t_mo_prik  .and. dn->next_data >= 0d20240101
            //++iii
            //my_debug(,iii)
            // ��������� �� �ਪ��� �168�
            if f_is_diag_dn( dn->kod_diag,,, .f. )     
              mas_tip_dz[ 3 ] := mas_tip_dz[ 3 ] + 1
              if fl_prinet 
                mas_tip_prin[ 3 ] := mas_tip_prin[ 3 ] + 1
              endif  
              If fl_3 != dn->kod_k
                mas_tip_pc[ 3 ] := mas_tip_pc[ 3 ] + 1
                fl_3 := dn->kod_k
              Endif
            endif   
            // ��������� ���-10 E10
            If PadR( dn->kod_diag, 3 ) == "E10"
              mas_tip_dz[ 4 ] := mas_tip_dz[ 4 ] + 1  
              if fl_prinet 
                mas_tip_prin[ 4 ] := mas_tip_prin[ 4 ] + 1
              endif  
              If fl_4 != dn->kod_k
                mas_tip_pc[ 4 ] := mas_tip_pc[ 4 ] + 1
                fl_4 := dn->kod_k
              Endif
            Endif
            // ��������� ���-10 E11
            If PadR( dn->kod_diag, 3 ) == "E11"
              mas_tip_dz[ 5 ] := mas_tip_dz[ 5 ] + 1
              if fl_prinet 
                mas_tip_prin[ 5 ] := mas_tip_prin[ 5 ] + 1
              endif  
              If fl_5 != dn->kod_k
                mas_tip_pc[ 5 ] := mas_tip_pc[ 5 ] + 1
                fl_5 := dn->kod_k
              Endif
            Endif
            // ��������� ���
            //If PadR( dn->kod_diag, 3 ) == "E78" .or. PadR( dn->kod_diag, 1 ) == "I" .or. PadR( dn->kod_diag, 1 ) == "Q" .or. PadR( dn->kod_diag, 1 ) == "Z"
              If f_is_diag_dn_serdce( dn->kod_diag )
                mas_tip_dz[ 1 ] := mas_tip_dz[ 1 ] + 1  
                if fl_prinet 
                  mas_tip_prin[ 1 ] := mas_tip_prin[ 1 ] + 1
                endif  
                If fl_1 != dn->kod_k
                  mas_tip_pc[ 1 ] := mas_tip_pc[ 1 ] + 1
                  fl_1 := dn->kod_k
                Endif
              Endif
            //Endif
            // ��������� ���-10 �00-D09 
            If PadR( dn->kod_diag, 1 ) == "C" .or. PadR( dn->kod_diag, 3 ) == "D09"
              mas_tip_dz[ 2 ] := mas_tip_dz[ 2 ] + 1 
              if fl_prinet 
                mas_tip_prin[ 2 ] := mas_tip_prin[ 2 ] + 1
              endif  
              If fl_2 != dn->kod_k
                mas_tip_pc[ 2 ] := mas_tip_pc[ 2 ] + 1
                fl_2 := dn->kod_k
              Endif
            Endif
          Endif
        Endif
        // ����� �������
      Endif
      Select DN
      Skip
    Enddo
    //my_debug(,iii1)
    //my_debug(,iii2)
    If !Empty( sadres )
      add_string( "  " + sadres )
    Endif
    If Empty( r )
      add_string( "�� ������� ��樥�⮢ �� ��������� �᫮���" )
    Else
      add_string( "=== �⮣� ��樥�⮢ - " + lstr( r ) + " 祫., �⮣� ��������� - " + lstr( rs ) + " ===" )
      add_string( "=== �� ��� ������   - " + lstr( ru ) + " 祫., � ����� ��ࠢ���� �� ���� ===" )
      add_string( "=== ��樥�⮢ �ਪ९������ �� � ��襬� �� - " + lstr( rpr ) + " 祫. ===" )
      add_string( "      ������� ����⭮ �ਭ��� �� ���� " )
      add_string( "===   ����⭮ ���� �ਭ���: " )
      add_string( "===   ��������� ���              - " + PadL( lstr( mas_tip_dz[ 1 ] ), 8 ) + " �� ��� �ਭ�� " +padl(lstr( mas_tip_prin[ 1 ] ),8) + " ��樥�⮢ - " + padl(lstr( mas_tip_pc[ 1 ] ),8) )
      add_string( "===   ��������� ���-10 �00-D09   - " + PadL( lstr( mas_tip_dz[ 2 ] ), 8 ) + " �� ��� �ਭ�� " +padl(lstr( mas_tip_prin[ 2 ] ),8) + " ��樥�⮢ - " + padl(lstr( mas_tip_pc[ 2 ] ),8) )
      add_string( "===   ��������� �� �ਪ��� �168� - " + PadL( lstr( mas_tip_dz[ 3 ] ), 8 ) + " �� ��� �ਭ�� " +padl(lstr( mas_tip_prin[ 3 ] ),8) + " ��樥�⮢ - " + padl(lstr( mas_tip_pc[ 3 ] ),8) )
      add_string( "===   ��������� ���-10 E10       - " + PadL( lstr( mas_tip_dz[ 4 ] ), 8 ) + " �� ��� �ਭ�� " +padl(lstr( mas_tip_prin[ 4 ] ),8) + " ��樥�⮢ - " + padl(lstr( mas_tip_pc[ 4 ] ),8) )
      add_string( "===   ��������� ���-10 E11       - " + PadL( lstr( mas_tip_dz[ 5 ] ), 8 ) + " �� ��� �ਭ�� " +padl(lstr( mas_tip_prin[ 5 ] ),8) + " ��樥�⮢ - " + padl(lstr( mas_tip_pc[ 5 ] ),8) )
      add_string( "** ���᭮�������� ���⠭���� �� �� � ⠪��� ���������� ����室��� �஢���� ����, �.�. " )
      add_string( "����� ������� �� ���� ��ண� ��易⥫�� ��� ���⠭���� �� ��ᯠ��୮� �������" )
    Endif
    Close databases
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, 3 )
  Endif
  RestScreen( buf )

  Return Nil



// 03.12.23 ���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������
Function spr_disp_nabl()

  Local i, j, s := "", c := "  ", sh := 80, HH := 60, diag1 := {}, buf := save_maxrow(), name_file := cur_dir + "diagn_dn" + stxt

  f_is_diag_dn(, @diag1,, .f. )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( "" )
  add_string( Center( "���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� ������� �� 2024 �.", sh ) )
  add_string( "" )
  For i := 1 To Len( diag1 )
    verify_ff( HH, .t., sh )
    add_string( diag1[ i, 1 ] )
    If Len( diag1[ i ] ) > 1
      s := "  (�஬�"
      For j := 2 To Len( diag1[ i ] )
        s += " " + diag1[ i, j ]
      Next
      s += ")"
      add_string( s )
    Endif
  Next
  FClose( fp )
  viewtext( name_file,,,, .t.,,, 2 )
  rest_box( buf )

  Return Nil



// 03.12.23 ����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������
Function f_create_d01()

  Local fl := .t., arr, id01 := 0, lspec, lmesto, buf := save_maxrow()

  mywait()
  r_use( dir_server + "mo_xml",, "MO_XML" )
  Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) ;
    For DFILE > 0d20231202 .and. tip_in == _XML_FILE_D02 .and. Empty( TIP_OUT ) // ��
  r_use( dir_server + "mo_d01",, "REES" )
  Index On Str( nn, 3 ) to ( cur_dir + "tmp_d01" ) For nyear == 2023 // ��

  Go Top
  Do While !Eof()
    // aadd(a_reestr, rees->kod)
    If rees->kol_err < 0
      // fl := func_error(4,"� 䠩�� D02 �訡�� �� �஢�� 䠩��! ������ ����饭�")
    Elseif Empty( rees->answer )
      fl := func_error( 4, "���� D02 �� �� ���⠭! ������ ����饭�" )
    Else
      Select MO_XML
      find ( Str( rees->kod, 6 ) )
      If Found()
        If Empty( mo_xml->TWORK2 )
          fl := func_error( 4, "��ࢠ�� �⥭�� 䠩�� " + AllTrim( mo_xml->FNAME ) + "! ���㫨��� (Ctrl+F12) � ���⠩� ᭮��" )
        Else
          // aadd(arr_rees,rees->kod)
        Endif
      Endif
    Endif
    Select REES
    Skip
  Enddo
  If !fl
    Close databases
    rest_box( buf )
    Return Nil
  Endif

  Select REES
  Set Index To
  g_use( dir_server + "mo_d01d",, "DD" )
  Index On Str( kod_d, 6 ) to ( cur_dir + "tmp_d01d" )
  g_use( dir_server + "mo_d01k",, "DK" )
  Index On Str( reestr, 6 ) to ( cur_dir + "tmp_d01k" )
  Do While .t.
    Select DK
    find ( Str( 0, 6 ) ) // �᫨ �� �६� ᮧ����� D01...XML ������ �� �뫠 ���४⭮ �����襭�
    If Found()
      Select DD
      Do While .t.
        find ( Str( dk->( RecNo() ), 6 ) )
        If Found()
          deleterec( .t. )
        Else
          Exit
        Endif
      Enddo
      Select DK
      deleterec( .t. )
    Else
      Exit
    Endif
  Enddo
  Commit

  dbCreate( cur_dir + "tmp", { { "KOD_K", "N", 7, 0 },;
                               { "KOD_DN", "N", 7, 0 },;
                               { "KOD_DIAG", "C", 5, 0 },;
                               { "KOD_T", "N", 7, 0 }  } )
  Use ( cur_dir + "tmp" ) new
  dbCreate( cur_dir + "tmp1", { { "KOD_K", "N", 7, 0 },;
                                { "KOD_DN", "N", 7, 0 },;
                                { "KOD_DIAG", "C", 5, 0 },;
                                { "KOD_T", "N", 7, 0 }  } )
Use ( cur_dir + "tmp1" ) new
  Select DK
  Set Relation To reestr into REES
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_d01k" ) For rees->nyear == 2023 // ��
  r_use( dir_server + "kartotek",, "KART" )
  r_use( dir_server + "kartote2",, "KART2" )
  r_use( dir_server + "mo_dnab",, "DN" )
  Set Relation To kod_k into KART
  Index On Upper( kart->fio ) + DToS( kart->date_r ) + Str( kod_k, 7 ) to ( cur_dir + "tmp_dn" ) For kart->kod > 0 .and. dn->next_data > 0d20240101 // �६���� 
   //unique - ���室�� - ���� ������ - ���� �������
  Go Top
  Do While !Eof()
    //my_debug(,dn->kod_k)
    //my_debug(,dn->next_data)
    //my_debug(,dn->kod_diag)
    fl := .t.
    Select DK
    find ( Str( dn->kod_k, 7 ) )
    Do While dk->kod_k == dn->kod_k .and. !Eof()
      If dk->oplata < 1 // �᫨ oplata = 0 (�⢥� ��� �� ����祭) // ��� oplata = 1 (����祭) - ����祭 �-�� ���᪠�� �뫮 2
        fl := .f.
      Endif
      Skip
      //my_debug(,"1")
      //my_debug(,fl)
    Enddo
    // �஢��塞 ���� �� 24 ���
    If dn->next_data > 0d20240101 .and. dn->next_data < 0d20250101
      //
    Else
      fl := .f.
    Endif
    //my_debug(,"2")
    //my_debug(,fl)
    // �� ���� ����஫� �� �������
    If fl
      If ( 1 == fvdn_date_r( sys_date, kart->date_r ) .or. 2 == fvdn_date_r( sys_date, kart->date_r ) )
        fl := .f.
      Endif
      if fl 
        if kart->date_r < 0d19000101
          fl := .f.
        endif  
      endif  
    Endif
    //my_debug(,"3")
    //my_debug(,fl)
    // �� ���� ����஫� �� ᬥ��
    If fl
      Select KART2
      Goto dn->kod_k
      If Left( kart2->PC2, 1 ) == "1"
        fl := .f.
      Endif
    Endif
    //my_debug(,"4")
    //my_debug(,fl)
    //
    If fl
      Select TMP
      Append Blank
      tmp->kod_k    := dn->kod_k
      tmp->kod_dn   := dn->(recno())
      tmp->kod_diag := dn->kod_diag
      tmp->kod_t    := tmp->(recno())
      //my_debug(,"��������")
    Endif
    Select DN
    Skip
  Enddo
  kart2->( dbCloseArea() )
//  quit
  // �����⮢�� �����襭� � ࠧ१� ��樥�⮢
  // ��頥� �� 㦥 �ਭ���� ��樥�⮢/���������
  select TMP
  Index On Str( kod_dn, 7 ) to ( cur_dir + "tmp_dnn" ) 
  r_use( dir_server + "mo_d01d" ,,"mo_d01d") // ᯨ᮪ ��������� ��樥�⮢
  go Top
  do while !eof()
    if year(mo_d01d->next_data) == 2024
      if mo_d01d->kod_n > 0 .and. mo_d01d->oplata == 1 // �ਭ���
        select TMP
        find (str(mo_d01d->kod_n,7)) 
        if found()
          delete 
        endif  
      endif 
    endif 
    select MO_D01D
    skip
  enddo
  // ���⨬ �� �� �㦭��
  select TMP 
  pack
  // ��頥� �� �㡫�� �� ��������
  select TMP 
  Index On Str( kod_k, 7 )+kod_diag to ( cur_dir + "tmp_dnn" ) unique
  go top
  do while !eof()
    If f_is_diag_dn( tmp->kod_diag,,, .f. ) .or. padr(alltrim(tmp->kod_diag),3) == "E10"// ⮫쪮 �������� �� ��᫥����� ᯨ᪠ �� 21 ����� + E10
      select TMP1
      append blank
      tmp1->KOD_K    := tmp->KOD_K
      tmp1->KOD_DN   := tmp->KOD_DN
      tmp1->KOD_DIAG := tmp->KOD_DIAG
      tmp1->KOD_T    := tmp->KOD_T 
    endif  
    select TMP
    skip
  enddo
  select TMP 
  set index to
  zap
  select TMP1 
  Index On Str( kod_t, 7 ) to ( cur_dir + "tmp_dnn" ) 
  go top
  do while !eof()
    select TMP
    append blank
    tmp->KOD_K    := tmp1->KOD_K
    tmp->KOD_DN   := tmp1->KOD_DN
    tmp->KOD_DIAG := tmp1->KOD_DIAG
    tmp->KOD_T    := tmp1->KOD_T 
    select TMP1
    skip
  enddo
  //
  //
  If tmp->( LastRec() ) == 0
    func_error( 4, "�� �����㦥�� ��樥�⮢, ������ ��� ���.��������, ��� �� ��ࠢ������ � �����" )
  Else
   /* Select DK
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_d01k" )
    r_use( dir_server + "mo_pers",, "PERSO" )
    Select DN
    Set Relation To vrach into PERSO
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_dn" )
    Select TMP
    Go Top
    Do While !Eof()
      arr := {} ; lmesto := 0
      Select DN
      find ( Str( tmp->kod_k, 7 ) )
      Do While dn->kod_k == tmp->kod_k .and. !Eof()
        If f_is_diag_dn( dn->kod_diag,,, .f. ) .or. padr(alltrim(dn->kod_diag),3) == "E10"// ⮫쪮 �������� �� ��᫥����� ᯨ᪠ �� 21 ����� + E10
          If dn->next_data > SToD( "20231231" )   // 11.12.2023
            lspec := ret_prvs_v021( iif( Empty( perso->prvs_new ), perso->prvs, -perso->prvs_new ) )
            AAdd( arr, { lspec, dn->kod_diag, dn->n_data, BoM( dn->next_data ), dn->FREQUENCY } )
            i := Len( arr )
            If Empty( arr[ i, 4 ] ) .or. !Between( arr[ i, 4 ], 0d20210101, 0d20250101 ) // ��
              arr[ i, 4 ] := 0d20230101  // ��
            Endif
            If !Between( arr[ i, 5 ], 1, 36 )
              arr[ i, 5 ] := 3
            Endif
            If dn->mesto == 1
              lmesto := 1
            Endif
          Endif
        Endif
        Select DN
        Skip
      Enddo
      ar1 := {} ; ar2 := {}
      For i := 1 To Len( arr )
        fl := .t.
        If AScan( ar1, Left( arr[ i, 2 ], 3 ) ) == 0
          AAdd( ar1, Left( arr[ i, 2 ], 3 ) )
        Else
          fl := .f.
        Endif
        If fl
          AAdd( ar2, arr[ i ] )
        Endif
      Next i
      */
    Select DK
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_d01k" )
    r_use( dir_server + "mo_pers",, "PERSO" )
    Select DN
    Set Relation To vrach into PERSO
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_dn" )
    Select TMP
    Go Top
    Do While !Eof()
      arr := {} ; lmesto := 0
      Select DN
      goto (tmp->kod_dn)
      If dn->next_data > SToD( "20240101" )   // 11.12.2024
        lspec := ret_prvs_v021( iif( Empty( perso->prvs_new ), perso->prvs, -perso->prvs_new ) )
        If Empty( dn->next_data ) .or. !Between( dn->next_data, 0d20240101, 0d20250101 ) 
          tnext_data := 0d20240201  
        else
          tnext_data := dn->next_data  
        Endif
        If !Between( dn->FREQUENCY, 1, 36 )
          tFREQUENCY := 3
        else
          tFREQUENCY := dn->FREQUENCY
        Endif
        If dn->mesto == 1
          lmesto := 1
        Endif
         // 
        Select DK
        addrec( 7 )
        dk->REESTR  := 0                     // ��� ॥��� �� 䠩�� "mo_d01"
        dk->KOD_K   := tmp->kod_k            // ��� �� ����⥪�
        dk->D01_ZAP := ++id01                // ����� ����樨 ����� � ॥���;"ZAP" � D01
        dk->ID_PAC  := mo_guid( 1, tmp->kod_k ) // GUID ��樥�� � D01 (ᮧ������ �� ���������� �����)
        dk->MESTO   := lmesto                // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
        dk->OPLATA  := 0                     // ⨯ ������: ᭠砫� 0, ��⥬ �� ����� 1,2,3,4
        Select DD
        addrec( 6 )
        dd->KOD_D     := dk->( RecNo() ) // ��� (����� �����) �� 䠩�� "mo_d01k"
        dd->PRVS      := lspec  //ar2[ i, 1 ]     // ���樠�쭮��� ��� �� �ࠢ�筨�� V021
        dd->KOD_DIAG  := dn->kod_diag   //ar2[ i, 2 ]      // ������� �����������, �� ������ ���ண� ��樥�� �������� ��ᯠ��୮�� �������
        dd->N_DATA    := dn->n_data     //ar2[ i, 3 ]      // ��� ��砫� ��ᯠ��୮�� �������
        dd->NEXT_DATA := tnext_data  //ar2[ i, 4 ]      // ��� � � 楫�� ��ᯠ��୮�� �������
        dd->FREQUENCY := tFREQUENCY     //ar2[ i, 5 ]
        dd->KOD_N     := tmp->kod_dn    // kod DISP_NAB
        dd->oplata    := 0
        If id01 % 500 == 0
          Commit
        Endif
      Endif
      Select TMP
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  //quit
  //
  If id01 > 0 .and. f_esc_enter( "ᮧ����� D01 (" + lstr( id01 ) + " ����-��)", .t. ) // ������
    mywait()
    inn := 0 ; nsh := 3
    g_use( dir_server + "mo_d01",, "REES" )
    Index On Str( nn, 3 ) to ( cur_dir + "tmp_d01" ) For nyear == 2023 // ��
    Go Top
    Do While !Eof()
      inn := rees->nn
      Skip
    Enddo
    Set Index To
    r_use( dir_server + "kartote2",, "KART2" )
    r_use( dir_server + "kartote_",, "KART_" )
    r_use( dir_server + "kartotek",, "KART" )
    g_use( dir_server + "mo_xml",, "MO_XML" )
    smsg := "���⠢����� 䠩�� D01..."
    stat_msg( smsg )
    Select REES
    addrecn()
    rees->KOD    := RecNo()
    rees->DSCHET := sys_date
    rees->NYEAR  := 2023 // ��
    rees->MM     := 12
    rees->NN     := inn + 1
    s := "D01" + "T34M" + glob_mo[ _MO_KOD_TFOMS ] + "_2312" + StrZero( rees->NN, nsh ) // ��
    rees->NAME_XML := s
    mkod_reestr := rees->KOD
    //
    Select MO_XML
    addrecn()
    mo_xml->KOD    := RecNo()
    mo_xml->FNAME  := s
    mo_xml->FNAME2 := ""
    mo_xml->DFILE  := rees->DSCHET
    mo_xml->TFILE  := hour_min( Seconds() )
    mo_xml->TIP_IN := 0
    mo_xml->TIP_OUT := _XML_FILE_D01  // ⨯ ���뫠����� 䠩�� - D01
    mo_xml->REESTR := mkod_reestr
    mo_xml->DWORK := sys_date
    mo_xml->TWORK1 := hour_min( Seconds() )
    //
    rees->KOD_XML := mo_xml->KOD
    Unlock
    Commit
    pkol := 0
    g_use( dir_server + "mo_d01d", cur_dir + "tmp_d01d", "DD" )
    g_use( dir_server + "mo_d01k",, "RHUM" )
    Index On Str( REESTR, 6 ) + Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" )
    Do While .t.
      find ( Str( 0, 6 ) )
      If Found()
        ++pkol
        @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
        //
        g_rlock( forever )
        rhum->REESTR := mkod_reestr
        If pkol % 2000 == 0
          dbUnlockAll()
          dbCommitAll()
        Endif
      Else
        Exit
      Endif
    Enddo
    Select REES
    g_rlock( forever )
    rees->KOL := pkol
    rees->KOL_ERR := 0
    dbUnlockAll()
    dbCommitAll()
    //
    stat_msg( smsg )
    //
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( "ZL_LIST" ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "ZGLV" ) )
    mo_add_xml_stroke( oXmlNode, "VERSION", '1.0' )
    mo_add_xml_stroke( oXmlNode, "CODE_MO", glob_mo[ _MO_KOD_FFOMS ] )
    mo_add_xml_stroke( oXmlNode, "CODEM", glob_mo[ _MO_KOD_TFOMS ] )
    mo_add_xml_stroke( oXmlNode, "DATE_F", date2xml( mo_xml->DFILE ) )
    mo_add_xml_stroke( oXmlNode, "NAME_F", mo_xml->FNAME )
    mo_add_xml_stroke( oXmlNode, "SMO", '34' )
    mo_add_xml_stroke( oXmlNode, "YEAR", lstr( rees->NYEAR ) )
    mo_add_xml_stroke( oXmlNode, "MONTH", lstr( rees->MM ) )
    mo_add_xml_stroke( oXmlNode, "N_PACK", lstr( rees->NN ) )
    //
    Select RHUM
    Set Relation To kod_k into KART, To kod_k into KART_, To kod_k into KART2
    Index On Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( rhum->D01_ZAP / pkol * 100, 6, 2 ) + "%" Color cColorSt2Msg
      arr_fio := retfamimot( 1, .f. )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "PERSONS" ) )
      mo_add_xml_stroke( oXmlNode, "ZAP", lstr( rhum->D01_ZAP ) )
      mo_add_xml_stroke( oXmlNode, "IDPAC", rhum->ID_PAC )
      mo_add_xml_stroke( oXmlNode, "SURNAME", arr_fio[ 1 ] )
      mo_add_xml_stroke( oXmlNode, "NAME", arr_fio[ 2 ] )
      If !Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oXmlNode, "PATRONYMIC", arr_fio[ 3 ] )
      Endif
      mo_add_xml_stroke( oXmlNode, "BIRTHDAY", date2xml( kart->date_r ) )
      mo_add_xml_stroke( oXmlNode, "SEX", iif( kart->pol == "�", '1', '2' ) )
      If !Empty( kart->snils )
        mo_add_xml_stroke( oXmlNode, "SS", Transform( kart->SNILS, picture_pf ) )
      Endif
      // �஢�ਬ ����稥 ��� - ���� ���� ��ਠ��
      If Len( AllTrim( kart2->KOD_MIS ) ) > 14
        mo_add_xml_stroke( oXmlNode, "TYPE_P", lstr( 3 ) ) // ⮫쪮 �����
        s := AllTrim( kart2->KOD_MIS )
        s := PadR( s, 16, "0" )
        //
        mo_add_xml_stroke( oXmlNode, "NUM_P", s )
        mo_add_xml_stroke( oXmlNode, "ENP", s )
      Else
        mo_add_xml_stroke( oXmlNode, "TYPE_P", lstr( iif( Between( kart_->VPOLIS, 1, 3 ), kart_->VPOLIS, 1 ) ) )
        If !Empty( kart_->SPOLIS )
          mo_add_xml_stroke( oXmlNode, "SER_P", kart_->SPOLIS )
        Endif
        s := AllTrim( kart_->NPOLIS )
        If kart_->VPOLIS == 3 .and. Len( s ) != 16
          s := PadR( s, 16, "0" )
        Endif
        //
        mo_add_xml_stroke( oXmlNode, "NUM_P", s )
        If kart_->VPOLIS == 3
          mo_add_xml_stroke( oXmlNode, "ENP", s )
        Endif
      Endif
      mo_add_xml_stroke( oXmlNode, "DOCTYPE", lstr( kart_->vid_ud ) )
      If !Empty( kart_->ser_ud )
        mo_add_xml_stroke( oXmlNode, "DOCSER", kart_->ser_ud )
      Endif
      mo_add_xml_stroke( oXmlNode, "DOCNUM", kart_->nom_ud )
      If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
        mo_add_xml_stroke( oXmlNode, "MR", smr )
      Endif
      mo_add_xml_stroke( oXmlNode, "PLACE", lstr( rhum->mesto ) )
      oCONTACTS := oXmlNode:add( hxmlnode():new( "CONTACTS" ) )
      If !Empty( kart_->PHONE_H )
        mo_add_xml_stroke( oCONTACTS, "TEL_F", Left( kart_->PHONE_H, 1 ) + "-" + SubStr( kart_->PHONE_H, 2, 4 ) + "-" + SubStr( kart_->PHONE_H, 6 ) )
      Endif
      If !Empty( kart_->PHONE_M )
        mo_add_xml_stroke( oCONTACTS, "TEL_M", Left( kart_->PHONE_M, 1 ) + "-" + SubStr( kart_->PHONE_M, 2, 3 ) + "-" + SubStr( kart_->PHONE_M, 5 ) )
      Endif
      oADDRESS := oCONTACTS:add( hxmlnode():new( "ADDRESS" ) )
      s := "18000"
      If Len( AllTrim( kart_->okatop ) ) == 11
        s := Left( kart_->okatop, 5 )
      Elseif Len( AllTrim( kart_->okatog ) ) == 11
        s := Left( kart_->okatog, 5 )
      Endif
      mo_add_xml_stroke( oADDRESS, "SUBJ", s )
      If !Empty( kart->adres )
        mo_add_xml_stroke( oADDRESS, "UL", kart->adres )
      Endif
      arr := {}
      Select DD
      find ( Str( rhum->( RecNo() ), 6 ) )
      Do While dd->kod_d == rhum->( RecNo() ) .and. !Eof()
        If ( i := AScan( arr, {| x| x[ 1 ] == dd->prvs } ) ) == 0
          AAdd( arr, { dd->prvs, {} } ) ; i := Len( arr )
        Endif
        AAdd( arr[ i, 2 ], { dd->KOD_DIAG, dd->N_DATA, dd->NEXT_DATA, dd->FREQUENCY } )
        Skip
      Enddo
      oSPECs := oXmlNode:add( hxmlnode():new( "SPECIALISATIONS" ) )
      For i := 1 To Len( arr )
        oSPEC := oSPECs:add( hxmlnode():new( "SPECIALISATION" ) )
        mo_add_xml_stroke( oSPEC, "SPECIALIST", lstr( arr[ i, 1 ] ) )
        oREASONS := oSPEC:add( hxmlnode():new( "REASONS" ) )
        For j := 1 To Len( arr[ i, 2 ] )
          oREASON := oREASONS:add( hxmlnode():new( "REASON" ) )
          mo_add_xml_stroke( oREASON, "DS", arr[ i, 2, j, 1 ] )
          mo_add_xml_stroke( oREASON, "DATE_B", date2xml( arr[ i, 2, j, 2 ] ) )
          mo_add_xml_stroke( oREASON, "DATE_VISIT", date2xml( arr[ i, 2, j, 3 ] ) )
          mo_add_xml_stroke( oREASON, "FREQUENCY", lstr( arr[ i, 2, j, 4 ] ) )
        Next j
      Next i
      Select RHUM
      Skip
    Enddo
    stat_msg( "������ XML-䠩��" )
    oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml )
    chip_create_zipxml( AllTrim( mo_xml->FNAME ) + szip, { AllTrim( mo_xml->FNAME ) + sxml }, .t. )
    mo_xml->( g_rlock( forever ) )
    mo_xml->TWORK2 := hour_min( Seconds() )
    Close databases
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
    rest_box( buf )
  Endif

  Return Nil



// 03.12.23 ����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������
Function f_view_d01()

  Local i, k, buf := SaveScreen()
  Private goal_dir := dir_server + dir_XML_MO + cslash

  g_use( dir_server + "mo_xml",, "MO_XML" )
  g_use( dir_server + "mo_d01",, "REES" )
  Index On Descend( StrZero( nn, 3 ) ) to ( cur_dir + "tmp_rees" ) For nyear == 2023 // ��
  Go Top
  If Eof()
    func_error( 4, "�� �뫮 ᮧ���� 䠩��� D01... ��� 2024 ����" ) // ��
  Else
    Private reg := 1
    alpha_browse( T_ROW, 2, MaxRow() -2, 77, "f1_view_D01", color0,,,,,,, ;
      "f2_view_D01",, { '�', '�', '�', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil



// 29.11.18
Function f1_view_d01( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip ), ;
    iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( " ��", {|| Str( rees->nn, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  ���", {|| date_8( rees->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "���-��;����-��", {|| Str( rees->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ���-��; �訡��", {|| iif( rees->kol_err < 0, "� 䠩��", put_val( rees->kol_err, 7 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "��-;���", {|| iif( rees->answer == 1, "�� ", "���" ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ������������ 䠩��", {|| PadR( rees->NAME_XML, 21 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "�ਬ�砭��", {|| f11_view_d01() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If reg == 1
    status_key( "^<Esc>^ ��室; ^<F5>^ ������ ��� �����; ^<F3>^ ���ଠ�� � 䠩��" )
  Else
    status_key( "^<Esc>^ - ��室;  ^<Enter>^ - �롮� ॥��� ��� ������" )
  Endif

  Return Nil



// 03.12.18
Static Function f11_view_d01()

  Local s := ""

  If rees->kod_xml > 0
    mo_xml->( dbGoto( rees->kod_xml ) )
    If Empty( mo_xml->twork2 )
      s := "�� ������"
    Endif
  Endif
  If Empty( s )
    If !hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip )
      s := "��� 䠩��"
    Elseif Empty( rees->date_out )
      s := "�� ����ᠭ"
    Else
      s := "���. " + lstr( rees->NUMB_OUT ) + " ࠧ"
    Endif
  Endif

  Return PadR( s, 10 )



// 03.12.18
Function f2_view_d01( nKey, oBrow )

  Local ret := -1, rec := rees->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr := {}, i := 1, k, mdate, t_arr[ 2 ], arr_pmt := {}

  Do Case
  Case nKey == K_F5
    mdate := rees->dschet
    AAdd( arr, { rees->name_xml, rees->kod_xml, rees->( RecNo() ) } )
    s := "�����뢠���� 䠩� " + AllTrim( arr[ i, 1 ] ) + szip + "."
    perenos( t_arr, s, 74 )
    f_message( t_arr,, color1, color8 )
    If f_esc_enter( "����� 䠩�� D01" )
      Private p_var_manager := "copy_schet"
      s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" ��� �롮� ��⠫���
      If !Empty( s )
        If Upper( s ) == Upper( goal_dir )
          func_error( 4, "�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ 楫���� 䠩�! �� �������⨬�." )
        Else
          cFileProtokol := cur_dir + "prot_sch" + stxt
          StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
          smsg := "���� D01 ����ᠭ ��: " + s + " (" + full_date( sys_date ) + "�. " + hour_min( Seconds() ) + ")"
          StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
          k := 0
          For i := 1 To Len( arr )
            zip_file := AllTrim( arr[ i, 1 ] ) + szip
            If hb_FileExists( goal_dir + zip_file )
              mywait( '����஢���� "' + zip_file + '" � ��⠫�� "' + s + '"' )
              // copy file (goal_dir + zip_file) to (hb_OemToAnsi(s) + zip_file)
              Copy File ( goal_dir + zip_file ) to ( s + zip_file )
              // if hb_fileExists(hb_OemToAnsi(s) + zip_file)
              If hb_FileExists( s + zip_file )
                ++k
                rees->( dbGoto( arr[ i, 3 ] ) )
                smsg := "����� D01 � " + lstr( rees->nn ) + " �� " + date_8( mdate ) + "�. " + AllTrim( rees->name_xml ) + szip
                StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                smsg := "   ������⢮ ��樥�⮢ - " + lstr( rees->kol )
                StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                rees->( g_rlock( forever ) )
                rees->DATE_OUT := sys_date
                If rees->NUMB_OUT < 99
                  rees->NUMB_OUT++
                Endif
                //
                mo_xml->( dbGoto( arr[ i, 2 ] ) )
                mo_xml->( g_rlock( forever ) )
                mo_xml->DREAD := sys_date
                mo_xml->TREAD := hour_min( Seconds() )
              Else
                smsg := "! �訡�� ����� 䠩�� " + s + zip_file
                func_error( 4, smsg )
                StrFile( smsg + hb_eol(), cFileProtokol, .t. )
              Endif
            Else
              smsg := "! �� �����㦥� 䠩� " + goal_dir + zip_file
              func_error( 4, smsg )
              StrFile( smsg + hb_eol(), cFileProtokol, .t. )
            Endif
          Next i
          Unlock
          Commit
          viewtext( cFileProtokol,,,, .t.,,, 2 )
        Endif
      Endif
    Endif
    Select REES
    Goto ( rec )
    ret := 0
  Case nKey == K_F3
    f3_view_d01( oBrow )
    ret := 0
  Case nKey == K_CTRL_F12
    If rees->ANSWER == 0
      mo_xml->( dbGoto( rees->kod_xml ) )
      If Empty( mo_xml->twork2 )
        ret := delete_reestr_d01( rees->( RecNo() ) )
      Else
        func_error( 4, "���� " + AllTrim( rees->NAME_XML ) + sxml + " ᮧ��� ���४⭮. ���㫨஢���� ����饭�!" )
      Endif
    Else
      ret := delete_reestr_d02( rees->( RecNo() ), AllTrim( rees->NAME_XML ) )
    Endif
    Close databases
    g_use( dir_server + "mo_xml",, "MO_XML" )
    g_use( dir_server + "mo_d01", cur_dir + "tmp_rees", "REES" )
    If ret != 1
      Goto ( rec )
    Endif
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret



// 29.11.18
Function f3_view_d01( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), fl, s, ;
    mm_func := { -99 }, ;
    mm_menu := { "���᮪ ~��� ��樥�⮢ �� D01" }

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir + "tmp_xml" ) ;
    For reestr == rees->kod .and. tip_in == _XML_FILE_D02 .and. Empty( TIP_OUT )
  Go Top
  Do While !Eof()
    AAdd( mm_func, -1 )
    AAdd( mm_menu, "1-��⠭������ ����.�ਭ����������, ���⢥ত��� �ਪ९����� � ��" )
    AAdd( mm_func, -2 )
    AAdd( mm_menu, "2-���������� �訡�� �孮�����᪮�� ����஫�" )
    AAdd( mm_func, -3 )
    AAdd( mm_menu, "3-�� ��⠭������ ���客�� �ਭ����������" )
    AAdd( mm_func, -4 )
    AAdd( mm_menu, "4-�� ��⠭������ ����.�ਭ����������, �� ���⢥ত��� �ਪ९����� � ��" )
    s := "��⮪�� �⥭�� " + RTrim( mo_xml->FNAME ) + " ���⠭ " + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      s += "-������� �� ��������"
    Else
      s += " � " + mo_xml->TWORK1
    Endif
    AAdd( mm_func, mo_xml->kod )
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  If r <= 12
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  rest_box( buf )
  If Len( mm_menu ) == 1
    i := 1
    si := i
    If mm_func[ i ] < 0
      f31_view_d01( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Endif
  Elseif ( i := popup_prompt( r1, 10, si, mm_menu,,, color5 ) ) > 0
    si := i
    If mm_func[ i ] < 0
      f31_view_d01( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Else
      mo_xml->( dbGoto( mm_func[ i ] ) )
      viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + AllTrim( mo_xml->FNAME ) + stxt, 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif
  Select REES

  Return Nil



// 29.11.18
Function  f31_view_d01( reg, s )

  Local fl := .t., buf := save_maxrow(), k := 0, n_file := cur_dir + "D01_spis" + stxt

  mywait()
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "���᮪ ��樥�⮢ 䠩�� " + AllTrim( rees->NAME_XML ) + " �� " + date_8( rees->dschet ), 80 ) )
  If reg == 99
    s := "�� ��樥���"
  Endif
  add_string( Center( "[ " + s + " ]", 80 ) )
  add_string( "" )
  r_use( dir_server + "mo_d01d",, "DD" )
  Index On Str( kod_d, 6 ) to ( cur_dir + "tmp_dd" )
  r_use( dir_server + "kartotek",, "KART" )
  r_use( dir_server + "mo_d01k",, "RHUM" )
  Set Relation To kod_k into KART
  Index On Str( rhum->D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For reestr == rees->kod
  Go Top
  Do While !Eof()
    If iif( reg == 99, .t., rhum->OPLATA == reg )
      // �������� 䨫��� �� ॥����
      If rhum->reestr == rees->kod // 19.12.2020
        ++k
        s := Str( rhum->D01_ZAP, 5 ) + ". "
        If Empty( kart->fio )
          s += "㤠�� �㡫���� � ����⥪� (���=" + lstr( kod_k ) + ")"
        Else
          s += PadR( Upper( kart->fio ), 35 ) + " " + full_date( kart->date_r )
        Endif
        s += " ("
        Select DD
        find ( Str( rhum->( RecNo() ), 6 ) )
        Do While dd->kod_d == rhum->( RecNo() ) .and. !Eof()
          s += " " + AllTrim( dd->kod_diag )
          Skip
        Enddo
        s += " )"
        verify_ff( 60, .t., 80 )
        add_string( s )
      Endif
    Endif
    Select RHUM
    Skip
  Enddo
  add_string( "" )
  add_string( "�ᥣ� " + lstr( k ) + " 祫." )
  kart->( dbCloseArea() )
  rhum->( dbCloseArea() )
  dd->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 2 )

  Return Nil



// 03.12.19 ������ D01 �� �६���� 䠩��
Function reestr_d01_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "��ᯠ�����/�⥭��/������ 䠩�� " + mname_xml )
  dbCreate( cur_dir + "tmp4file", { ;
    { "ZAP",        "N",  6, 0 }, ;
    { "IDPAC",      "C", 36, 0 }, ;
    { "SURNAME",    "C", 40, 0 }, ;
    { "NAME",       "C", 40, 0 }, ;
    { "PATRONYMIC", "C", 40, 0 }, ;
    { "BIRTHDAY",   "C", 10, 0 }, ;
    { "SEX",        "C",  1, 0 }, ;
    { "SS",         "C", 14, 0 }, ;
    { "TYPE_P",     "C",  1, 0 }, ;
    { "SER_P",      "C", 10, 0 }, ;
    { "NUM_P",      "C", 20, 0 }, ;
    { "ENP",        "C", 16, 0 }, ;
    { "DOCTYPE",    "C",  2, 0 }, ;
    { "DOCSER",     "C", 10, 0 }, ;
    { "DOCNUM",     "C", 20, 0 }, ;
    { "MR",         "C", 100, 0 }, ;
    { "PLACE",      "C",  1, 0 }, ;
    { "TEL_F",      "C", 13, 0 }, ;
    { "TEL_M",      "C", 13, 0 }, ;
    { "SUBJ",       "C",  5, 0 }, ;
    { "UL",         "C", 120, 0 }, ;
    { "kod_k",      "N",  7, 0 }, ;
    { "OPLATA",     "N",  1, 0 };
    } )
  dbCreate( cur_dir + "tmp5file", { ;
    { "ZAP",        "N",  6, 0 }, ;
    { "PRVS",   "C",  4, 0 }, ;
    { "DS",   "C",  5, 0 }, ;
    { "DATE_B",   "C", 10, 0 }, ;
    { "DATE_VIZIT", "C", 10, 0 }, ;
    { "FREQUENCY",  "N",  2, 0 };
    } )
  Use ( cur_dir + "tmp4file" ) New Alias TMP2
  Use ( cur_dir + "tmp5file" ) New Alias TMP5
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    If "PERSONS" == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->ZAP       := Val( mo_read_xml_stroke( oXmlNode, "ZAP", aerr ) )
      tmp2->IDPAC     :=     mo_read_xml_stroke( oXmlNode, "IDPAC", aerr, .f. )
      tmp2->SURNAME   :=     mo_read_xml_stroke( oXmlNode, "SURNAME", aerr, .f. )
      tmp2->NAME      :=     mo_read_xml_stroke( oXmlNode, "NAME", aerr, .f. )
      tmp2->PATRONYMIC :=     mo_read_xml_stroke( oXmlNode, "PATRONYMIC", aerr, .f. )
      tmp2->BIRTHDAY  :=     mo_read_xml_stroke( oXmlNode, "BIRTHDAY", aerr, .f. )
      tmp2->SEX       :=     mo_read_xml_stroke( oXmlNode, "SEX", aerr, .f. )
      tmp2->SS        :=     mo_read_xml_stroke( oXmlNode, "SS", aerr, .f. )
      tmp2->TYPE_P    :=     mo_read_xml_stroke( oXmlNode, "TYPE_P", aerr, .f. )
      tmp2->SER_P     :=     mo_read_xml_stroke( oXmlNode, "SER_P", aerr, .f. )
      tmp2->NUM_P     :=     mo_read_xml_stroke( oXmlNode, "NUM_P", aerr, .f. )
      tmp2->ENP       :=     mo_read_xml_stroke( oXmlNode, "ENP", aerr, .f. )
      tmp2->DOCTYPE   :=     mo_read_xml_stroke( oXmlNode, "DOCTYPE", aerr, .f. )
      tmp2->DOCSER    :=     mo_read_xml_stroke( oXmlNode, "DOCSER", aerr, .f. )
      tmp2->DOCNUM    :=     mo_read_xml_stroke( oXmlNode, "DOCNUM", aerr, .f. )
      tmp2->MR        :=     mo_read_xml_stroke( oXmlNode, "MR", aerr, .f. )
      tmp2->PLACE     :=     mo_read_xml_stroke( oXmlNode, "PLACE", aerr, .f. )
      If ( oNode1 := oXmlNode:find( "CONTACTS" ) ) != NIL
        tmp2->TEL_F   :=     mo_read_xml_stroke( oNode1, "TEL_F", aerr, .f. )
        tmp2->TEL_M   :=     mo_read_xml_stroke( oNode1, "TEL_M", aerr, .f. )
        If ( oNode2 := oNode1:find( "ADDRESS" ) ) != NIL
          tmp2->SUBJ  :=     mo_read_xml_stroke( oNode2, "SUBJ", aerr, .f. )
          tmp2->UL    :=     mo_read_xml_stroke( oNode2, "UL", aerr, .f. )
        Endif
      Endif
      If ( oNode1 := oXmlNode:find( "SPECIALISATIONS" ) ) != NIL
        _ar := mo_read_xml_array( oNode1, "SPECIALISATION" )
        For j1 := 1 To Len( _ar )
          lprvs := mo_read_xml_stroke( oNode1, "SPECIALIST", aerr, .f. )
          If ( oNode2 := oXmlNode:find( "REASONS" ) ) != NIL
            _ar2 := mo_read_xml_array( oNode2, "REASON" )
            For j2 := 1 To Len( _ar2 )
              Select TMP5
              Append Blank
              tmp5->N_ZAP := tmp2->_N_ZAP
              tmp5->PRVS := lprvs
              tmp5->DS := mo_read_xml_stroke( oNode2, "DS", aerr, .f. )
              tmp5->DATE_B := mo_read_xml_stroke( oNode2, "DATE_B", aerr, .f. )
              tmp5->DATE_VISIT := mo_read_xml_stroke( oNode2, "DATE_VISIT", aerr, .f. )
              tmp5->FREQUENCY := Val( mo_read_xml_stroke( oNode2, "FREQUENCY", aerr, .f. ) )
            Next j2
          Endif
        Next j1
      Endif
    Endif
  Next j
  tmp2->( dbCloseArea() )
  tmp5->( dbCloseArea() )
  rest_box( buf )

  Return Nil



// 27.11.18 ������ D02 �� �६���� 䠩��
Function reestr_d02_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "��ᯠ�����/�⥭��/������ 䠩�� " + mname_xml )
  dbCreate( cur_dir + "tmp1file", { ;
    { "_VERSION",   "C",  5, 0 }, ;
    { "_DATE_F",    "D",  8, 0 }, ;
    { "_NAME_F",    "C", 26, 0 }, ;
    { "_NAME_FE",   "C", 26, 0 }, ;
    { "KOL",        "N",  6, 0 }, ; // ������⢮ ��樥�⮢ � ॥���/䠩��
    { "KOL_ERR",    "N",  6, 0 };  // ������⢮ ��樥�⮢ � �訡���� � ॥���
  } )
  dbCreate( cur_dir + "tmp2file", { ;
    { "_N_ZAP",     "N",  6, 0 }, ;
    { "_SMO",       "C",  5, 0 }, ;
    { "_ENP",       "C", 16, 0 }, ;
    { "_OPLATA",    "N",  1, 0 }, ;
    { "_ERROR",     "N",  3, 0 };   
    } )
  dbCreate( cur_dir + "tmp3file", { ;
    { "_N_ZAP",     "N",  6, 0 }, ;
    { "_ERROR",     "N",  3, 0 };
    } )
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  Append Blank
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  Use ( cur_dir + "tmp3file" ) New Alias TMP3
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION", aerr )
      tmp1->_DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, "DATE_F", aerr ) )
      tmp1->_NAME_F  :=          mo_read_xml_stroke( oXmlNode, "NAME_F", aerr )
      tmp1->_NAME_FE :=          mo_read_xml_stroke( oXmlNode, "NAME_FE", aerr )
    Case "ERRS" == oXmlNode:title
      Select TMP3
      Append Blank
      tmp3->_N_ZAP := 0
      tmp3->_ERROR := Val( mo_read_xml_tag( oXmlNode, aerr ) )
    Case "ZAPS" == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->_N_ZAP  := Val( mo_read_xml_stroke( oXmlNode, "ZAP", aerr ) )
      tmp2->_ENP    :=     mo_read_xml_stroke( oXmlNode, "ENP", aerr, .f. )
      tmp2->_SMO    :=     mo_read_xml_stroke( oXmlNode, "SMO", aerr, .f. )
      tmp2->_OPLATA := Val( mo_read_xml_stroke( oXmlNode, "RESULT", aerr ) )
      If tmp2->_OPLATA > 1 .and. ( oNode1 := oXmlNode:find( "ERRORS" ) ) != NIL
        _ar := mo_read_xml_array( oNode1, "ERROR" )
        For j1 := 1 To Len( _ar )
          Select TMP3
          Append Blank
          tmp3->_N_ZAP := tmp2->_N_ZAP
          tmp3->_ERROR := Val( _ar[ j1 ] )
          tmp2->_ERROR := Val( _ar[ j1 ] ) // ����砥� ��᫥���� �訡��
        Next
      Endif
    Endcase
  Next j
  Commit
  rest_box( buf )

  Return Nil

// 26.12.22 ������ � "ࠧ����" �� ����� ������ 䠩� D02
Function read_xml_file_d02( arr_XML_info, aerr, /*@*/current_i2,lrec_xml)

  Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[ 2 ], ldate_D02, s, err_file := .f.

  Default lrec_xml To 0
  mkod_reestr := arr_XML_info[ 7 ]
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  ldate_D02 := tmp1->_DATE_F
  r_use( dir_server + "mo_d01",, "REES" )
  Goto ( arr_XML_info[ 7 ] )
  StrFile( "��ࠡ��뢠���� �⢥� ����� (D02) �� ���ଠ樮��� ����� " + AllTrim( rees->NAME_XML ) + sxml + hb_eol() + ;
    "�� " + date_8( rees->DSCHET ) + "�. (" + lstr( rees->kol ) + " 祫.)" + hb_eol() + hb_eol(), cFileProtokol, .t. )
  rees_kol := rees->kol
  //
  r_use( dir_server + "mo_d01k",, "RHUM" )
  Index On Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  i := 0 ; k := LastRec()
  // ᭠砫� �஢�ઠ
  ii1 := ii2 := 0
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + "%" Color cColorWait
    If tmp2->_OPLATA == 1
      ++ii1
      If !Empty( tmp2->_SMO ) .and. AScan( glob_arr_smo, {| x| x[ 2 ] == Int( Val( tmp2->_SMO ) ) } ) == 0
        AAdd( aerr, "�����४⭮� ���祭�� ��ਡ�� SMO: " + tmp2->_SMO )
      Endif
    Elseif Between( tmp2->_OPLATA, 2, 4 )
      if tmp2->_OPLATA == 2 .and. tmp2->_ERROR == 131 // �ࠢ�� 01.02.24
        g_rlock( forever )
        tmp2->_OPLATA := 1
        Unlock
        ++ii1
      else  
        ++ii2
      endif  
    Else
      AAdd( aerr, "�����४⭮� ���祭�� ��ਡ�� RESULT: " + lstr( tmp2->_OPLATA ) )
    Endif
    Select RHUM
    find ( Str( tmp2->_N_ZAP, 6 ) )
    If !Found()
      AAdd( aerr, "�� ������ ��砩 � N_ZAP = " + lstr( tmp2->_N_ZAP ) )
    Endif
    Select TMP2
    Skip
  Enddo
  tmp1->kol := ii1
  tmp1->kol_err := ii2
  If Empty( ii2 )
    Use ( cur_dir + "tmp3file" ) New Alias TMP3
    Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp3" )
    find ( Str( 0, 6 ) )
    err_file := Found() // �訡�� �� �஢�� 䠩��
  Endif
  Close databases
  If Empty( aerr ) // �᫨ �஢�ઠ ��諠 �ᯥ譮
    // ����襬 �ਭ������ 䠩� (॥��� ��)
    // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
    chip_copy_zipxml( full_zip, dir_server + dir_XML_TF )
    g_use( dir_server + "mo_xml",, "MO_XML" )
    If Empty( lrec_xml )
      addrecn()
    Else
      Goto ( lrec_xml )
      g_rlock( forever )
    Endif
    mo_xml->KOD := RecNo()
    mo_xml->KOD := RecNo()
    mo_xml->FNAME := cReadFile
    mo_xml->DFILE := ldate_D02
    mo_xml->TFILE := ""
    mo_xml->DREAD := sys_date
    mo_xml->TREAD := hour_min( Seconds() )
    mo_xml->TIP_IN := _XML_FILE_D02 // ⨯ �ਭ�������� 䠩��
    mo_xml->DWORK  := sys_date
    mo_xml->TWORK1 := cTimeBegin
    mo_xml->REESTR := mkod_reestr
    mo_xml->KOL1 := ii1
    mo_xml->KOL2 := ii2
    //
    mXML_REESTR := mo_xml->KOD
    Use
    g_use( dir_server + "mo_d01",, "REES" )
    Goto ( mkod_reestr )
    g_rlock( forever )
    rees->answer := 1
    If ii2 > 0
      rees->kol_err := ii2
    Elseif err_file
      rees->kol_err := -1
    Endif
    Use
    If ii2 > 0 .or. err_file
      Use ( cur_dir + "tmp3file" ) New Alias TMP3
      Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp3" )
      g_use( dir_server + "mo_d01e",, "REFR" )
      Index On Str( REESTR, 6 ) + Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_D01e" )
      If err_file
        Select REFR
        Do While .t.
          find ( Str( mkod_reestr, 6 ) + Str( 0, 6 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        StrFile( "�訡�� �� �஢�� 䠩��:" + hb_eol(), cFileProtokol, .t. )
        Select TMP3
        find ( Str( 0, 6 ) )
        Do While tmp3->_N_ZAP == 0 .and. !Eof()
          Select REFR
          addrec( 6 )
          refr->reestr := mkod_reestr
          refr->D01_ZAP := 0
          refr->KOD_ERR := tmp3->_ERROR
          // if (j := ascan(getT012(), {|x| x[2] == tmp3->_ERROR })) > 0
          // strfile(space(8) + "�訡�� " + lstr(tmp3->_ERROR) + " - " + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
          // else
          // strfile(space(8)+"�訡�� "+lstr(tmp3->_ERROR)+" (�������⭠� �訡��)"+hb_eol(),cFileProtokol,.t.)
          // endif
          if tmp3->_ERROR != 131
            StrFile( Space( 8 ) + geterror_t012( tmp3->_ERROR ) + hb_eol(), cFileProtokol, .t. )
          endif  
          Select TMP3
          Skip
        Enddo
      Endif
      tmp3->( dbCloseArea() )
    Endif
    g_use( dir_server + "kartote2",, "KART2" )
    g_use( dir_server + "kartote_",, "KART_" )
    g_use( dir_server + "kartotek",, "KART" )
    g_use( dir_server + "mo_d01k",, "RHUM" )
    Index On Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
    i := 0
    If err_file
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( ++i / rees_kol * 100, 6, 2 ) + "%" Color cColorWait
        g_rlock( forever )
        rhum->OPLATA := 2 // �����⢥��� ��ᢠ����� �訡�� "2"
        Skip
      Enddo
    Else
      Use ( cur_dir + "tmp3file" ) New Alias TMP3
      Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp3" )
      Use ( cur_dir + "tmp2file" ) New Alias TMP2
      Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp2" )
      count_in_schet := LastRec() ; current_i2 := 0
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + "%" Color cColorWait
        Select RHUM
        find ( Str( tmp2->_N_ZAP, 6 ) )
        g_rlock( forever )
        rhum->OPLATA := tmp2->_OPLATA
        If !Empty( tmp2->_enp )
          Select KART2
          Do While kart2->( LastRec() ) < rhum->kod_k
            Append Blank
          Enddo
          Goto ( rhum->kod_k )
          If Len( AllTrim( kart2->kod_mis ) ) != 16
            g_rlock( forever )
            kart2->kod_mis := tmp2->_enp
            dbUnlock()
          Endif
        Endif
        If tmp2->_OPLATA > 1
          --count_in_schet    // �� ����砥��� � ���,
          If current_i2 == 0
            StrFile( Space( 10 ) + "���᮪ ��砥� � �訡����:" + hb_eol() + hb_eol(), cFileProtokol, .t. )
          Endif
          ++current_i2
          kart->( dbGoto( rhum->kod_k ) )
          If Empty( kart->fio )
            StrFile( Str( tmp2->_N_ZAP, 6 ) + ". ��樥�� � ����� �� ����⥪� " + lstr( kart->( RecNo() ) ) + hb_eol(), cFileProtokol, .t. )
          Else
            StrFile( Str( tmp2->_N_ZAP, 6 ) + ". " + AllTrim( kart->fio ) + ", " + full_date( kart->date_r ) + hb_eol(), cFileProtokol, .t. )
          Endif
          Select REFR
          Do While .t.
            find ( Str( mkod_reestr, 6 ) + Str( tmp2->_N_ZAP, 6 ) )
            If !Found() ; exit ; Endif
            deleterec( .t. )
          Enddo
          Select TMP3
          find ( Str( tmp2->_N_ZAP, 6 ) )
          Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. !Eof()
            Select REFR
            addrec( 6 )
            refr->reestr := mkod_reestr
            refr->D01_ZAP := tmp2->_N_ZAP
            refr->KOD_ERR := tmp3->_ERROR
            // if (j := ascan(getT012(), {|x| x[2] == tmp3->_ERROR })) > 0
            // strfile(space(8) + "�訡�� " + lstr(tmp3->_ERROR) + " - " + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
            // else
            // strfile(space(8)+"�訡�� "+lstr(tmp3->_ERROR)+" (�������⭠� �訡��)"+hb_eol(),cFileProtokol,.t.)
            // endif
            StrFile( Space( 8 ) + geterror_t012( tmp3->_ERROR ) + hb_eol(), cFileProtokol, .t. )
            Select TMP3
            Skip
          Enddo
          If tmp2->_OPLATA == 3
            StrFile( Space( 8 ) + "�� ��⠭������ ���客�� �ਭ����������" + hb_eol(), cFileProtokol, .t. )
          Elseif tmp2->_OPLATA == 4
            StrFile( Space( 8 ) + "�� ��⠭������ ���客�� �ਭ����������, �� ���⢥ত��� �ਪ९����� � ��" + hb_eol(), cFileProtokol, .t. )
          Endif
        Endif
        Unlock All
        Select TMP2
        If RecNo() % 1000 == 0
          Commit
        Endif
        Skip
      Enddo
    Endif
  Endif
  Close databases
  // ��⠢��� ��७�� ������ �� DK � DD
  g_use( dir_server + "mo_d01d" ,,"mo_d01d",.T.,.T.) // ᯨ᮪ ��������� ��樥�⮢ � ॥����
  Index On Str( kod_d, 7 ) to ( cur_dir + "tmp_kodd" ) 
  //{ "KOD_D",    "N", 6, 0 }, ; // ��� (����� �����) �� 䠩�� "mo_d01k"
  r_use( dir_server + "mo_d01k"  ) // ᯨ᮪ ��樥�⮢ � ॥����
  Index On Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
  //
  go top
  do while !eof()
    // ��樥��� �� ॥���
    select MO_D01D
    find (str(mo_d01k->(recno()),7))
    do while mo_d01d->kod_d == mo_d01k->(recno()) .and. !eof()
      // ���� �� ��������� ������� ��樥��
      g_rlock( forever )
      mo_d01d->oplata := mo_d01k->oplata
      Unlock
      select MO_D01D
      skip  // ��������
    enddo    
    select MO_D01K // �
    skip  
  enddo
  Close databases

  Return count_in_schet



// 03.12.18
Function delete_reestr_d01( mkod_reestr )

  Local ret := -1, rec, ir, fl := .t.

  If f_esc_enter( "���㫨஢���� D01" )
    mywait()
    Select REES
    Goto ( mkod_reestr )
    g_use( dir_server + "mo_d01d",, "DD" )
    Index On Str( kod_d, 6 ) to ( cur_dir + "tmp_d01d" )
    g_use( dir_server + "mo_d01k",, "DK" )
    Index On Str( reestr, 6 ) to ( cur_dir + "tmp_d01k" )
    Do While .t.
      Select DK
      find ( Str( mkod_reestr, 6 ) )
      If Found()
        Select DD
        Do While .t.
          find ( Str( dk->( RecNo() ), 6 ) )
          If Found()
            deleterec( .t. )
          Else
            Exit
          Endif
        Enddo
        Select DK
        deleterec( .t. )
      Else
        Exit
      Endif
    Enddo
    Select MO_XML
    Goto ( rees->KOD_XML )
    deleterec( .t. )
    Select REES
    deleterec( .t. )
    dbUnlockAll()
    dbCommitAll()
    stat_msg( "���㫨஢���� �����襭�!" ) ; mybell( 2, OK )
    ret := 1
  Endif

  Return ret



// 29.11.18 ���㫨஢��� �⥭�� �����⠭���� ॥��� D02
Function delete_reestr_d02( mkod_reestr, mname_reestr )

  Local i, s, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
    arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
    cFileProtokol := cur_dir + "tmp" + stxt

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir + "tmp_xml" ) ;
    For reestr == mkod_reestr .and. tip_in == _XML_FILE_D02 .and. TIP_OUT == 0
  Go Top
  Do While !Eof()
    AAdd( mm_func, mo_xml->kod )
    s := "��⮪�� �⥭�� " + RTrim( mo_xml->FNAME ) + " ���⠭ " + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      AAdd( mm_flag, .t. )
      s += "-������� �� ��������"
    Else
      AAdd( mm_flag, .f. )
      s += " � " + mo_xml->TWORK1
    Endif
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  rest_box( buf )
  If Len( mm_menu ) == 0
    func_error( 4, "�� �뫮 �⥭�� 䠩�� D02..." )
    Return 0
  Endif
  If r <= 18
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  If ( i := popup_prompt( r1, 10, 1, mm_menu,,, color5 ) ) > 0
    is_allow_delete := mm_flag[ i ]
    mreestr_sp_tk := mm_func[ i ]
    Select MO_XML
    Goto ( mreestr_sp_tk )
    cFile := AllTrim( mo_xml->FNAME )
    mtip_in := mo_xml->TIP_IN
    Close databases
    If !is_allow_delete
      func_error( 4, "���� " + cFile + sxml + " ���४⭮ ���⠭. ���㫨஢���� ����饭�!" )
      Return 0
    Endif
    If ( arr_f := extract_zip_xml( dir_server + dir_XML_TF, cFile + szip ) ) != NIL
      cFile += sxml
      // �⠥� 䠩� � ������
      oXmlDoc := hxmldoc():read( _tmp_dir1 + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        func_error( 4, "�訡�� � �⥭�� 䠩�� " + cFile )
      Else // �⠥� � �����뢠�� XML-䠩� �� �६���� TMP-䠩��
        reestr_d02_tmpfile( oXmlDoc, aerr, cFile )
        If !Empty( aerr )
          ins_array( aerr, 1, "" )
          ins_array( aerr, 1, Center( "�訡�� � �⥭�� 䠩�� " + cFile, 80 ) )
          AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
          viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
          Delete File ( cFileProtokol )
        Else
          If !is_allow_delete .and. involved_password( 2, cFile, "���㫨஢���� �⥭�� 䠩�� D02" )
            is_allow_delete := .t.
          Endif
          If is_allow_delete
            Close databases
            g_use( dir_server + "mo_d01",, "REES" )
            Goto ( mkod_reestr )
            Use ( cur_dir + "tmp1file" ) New Alias TMP1
            Use ( cur_dir + "tmp2file" ) New Alias TMP2
            arr := {}
            AAdd( arr, "���ଠ樮��� ����� " + AllTrim( rees->NAME_XML ) + sxml + " �� " + date_8( rees->DSCHET ) + "�." )
            AAdd( arr, "�� " + lstr( rees->NYEAR ) + " ���, ���-�� ��樥�⮢ " + lstr( rees->kol ) + " 祫." )
            AAdd( arr, "" )
            g_use( dir_server + "mo_xml",, "MO_XML" )
            Goto ( mreestr_sp_tk )
            AAdd( arr, "���㫨����� 䠩� �⢥� " + cFile + " �� " + date_8( mo_xml->DFILE ) + "�." )
            AAdd( arr, "��᫥ ���⢥ত���� ���㫨஢���� �� ��᫥��⢨� �⥭�� �������" )
            AAdd( arr, "䠩�� D02, � ⠪�� ᠬ 䠩� D02, ���� 㤠����." )
            f_message( arr,, cColorSt2Msg, cColorSt1Msg )
            s := "���⢥न� ���㫨஢���� 䠩�� D02"
            stat_msg( s ) ; mybell( 1 )
            is_allow_delete := .f.
            If f_esc_enter( "���㫨஢����", .t. )
              stat_msg( s + " ��� ࠧ." ) ; mybell( 3 )
              If f_esc_enter( "���㫨஢����", .t. )
                mywait()
                is_allow_delete := .t.
              Endif
            Endif
            Close databases
          Endif
          If is_allow_delete
            g_use( dir_server + "mo_xml",, "MO_XML" )
            g_use( dir_server + "mo_d01",, "REES" )
            Goto ( mkod_reestr )
            g_rlock( forever )
            rees->answer := 0
            rees->kol_err := 0
            g_use( dir_server + "mo_d01e",, "REFR" )
            Index On Str( REESTR, 6 ) + Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_D01e" )
            Select REFR
            Do While .t.
              find ( Str( mkod_reestr, 6 ) + Str( 0, 6 ) ) // 㤠��� �訡�� �� �஢�� 䠩��
              If !Found() ; exit ; Endif
              deleterec( .t. )
            Enddo
            g_use( dir_server + "mo_d01k",, "RHUM" )
            Index On Str( D01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For reestr == mkod_reestr
            Use ( cur_dir + "tmp2file" ) New Alias TMP2
            Go Top
            Do While !Eof()
              Select RHUM
              find ( Str( tmp2->_N_ZAP, 6 ) )
              g_rlock( forever )
              rhum->OPLATA := 0
              Unlock
              Select REFR
              Do While .t.
                find ( Str( mkod_reestr, 6 ) + Str( tmp2->_N_ZAP, 6 ) )
                If !Found() ; exit ; Endif
                deleterec( .t. )
              Enddo
              Select TMP2
              Skip
            Enddo
            Select MO_XML
            Goto ( mreestr_sp_tk )
            deleterec()
            Close databases
            stat_msg( "���� " + cFile + " �ᯥ譮 ���㫨஢��. ����� ������ ��� ࠧ." ) ; mybell( 5 )
          Endif
        Endif
      Endif
    Endif
  Endif
  rest_box( buf )

  Return 0
