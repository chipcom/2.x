#include 'inkey.ch'
#include 'fastreph.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'


// 08.11.23 ����㧪� ��������� ��ᯠ��୮�� ����
Function load_diagnoze_disp_nabl_from_file()
  Local diag := {}, lfp, s, file_form := exe_dir + 'DISP_NAB' + sfrm
  
  if hb_vfExists(file_form)
    lfp := FOpen( file_form )
    Do While ! feof( lfp )
      s := freadln( lfp )
      If !Empty( s )
        AAdd( diag, AllTrim( s ) )
      Endif
    Enddo
    FClose( lfp )
  else
    func_error(4, '�� �����㦥� 䠩� ' + file_form)
  endif
  Return diag

// 02.03.23
Function is_usluga_disp_nabl(_shifr, _shifr1)

  if empty(_shifr1)
    _shifr := alltrim(_shifr)
  else
    _shifr := alltrim(_shifr1)
  endif
  return between_shifr(_shifr, '2.78.61', '2.78.86') ;
    .or. between_shifr(_shifr, '2.88.52', '2.88.103') ;
    .or. between_shifr(_shifr, '2.88.105', '2.88.106') ;
    .or. between_shifr(_shifr, '2.88.120', '2.88.145') ;
    .or. _shifr == '2.5.2' ;  // ������� ᮣ��᭮ ����� ����� 09-30-376/1 �� 09.11.22 ����
    .or. _shifr == '2.78.106' ; // ������� ᮣ��᭮ ����� ����� 09-20-46 �� 13.02.23 ����
    .or. _shifr == '2.78.107'  // ������� ᮣ��᭮ ����� ����� 09-20-46 �� 13.02.23 ����


// 12.02.23 �஢���� ������� ��� ��ᯠ��୮�� �������
// Function f_is_diag_dn(ldiag, /*@*/arr_dn, pr_168)
Function f_is_diag_dn(ldiag, /*@*/arr_dn, dUsluga)
  Static sarr_dn, narr_dn
  static len_diag
  static nYear
  Local i, j, d1, d2, s, fl := .f.

  // default pr_168 to .F.
  default dUsluga to sys_date

  if valtype(dUsluga) == 'D'
    dUsluga := year(dUsluga)
  endif

  if HB_ISNIL(nYear) .or. nYear != dUsluga
    sarr_dn := {}
    narr_dn := {}
    nYear := dUsluga
  endif

  // if sarr_dn == NIL
  if len(sarr_dn) == 0
  //   {'I00-I99','I21-I24','I26','I28-I44','I33','I39-I40','I46','I60-I64','I66','I71-I78','I80-I82'}, ;
  //   {'J12-J99','J15-J39','J60-J69','J80-J82','J93-J95'}, ;
  //   {'K15-K91','K30-K31','K35-K38','K40-K46','K57-K67','K70-K85'}, ;
  //   {'M02-M94','M3','M7-M9','M11-M14','M20-M29','M36-M44','M46-M80','M82-M99'}, ;
  
    sarr_dn := { ;
     {'B18-B24'}, ; 
     {'C00-C97'}, ;
     {'D00-D10'}, ;   // �� D09.9 ����� ���� ��������  {'D45-D47')
     {'D11'}, ;
     {'D11.0'}, ;
     {'D11.7'}, ;
     {'D12.6'}, ;
     {'D12.8'}, ;
     {'D13.4'}, ;
     {'D13.7'}, ;
     {'D14'}, ;
     {'D14.0'}, ;
     {'D14.1'}, ;
     {'D14.2'}, ;
     {'D14.3'}, ;
     {'D16-D16.9'}, ;
     {'D22-D23.9'}, ;
     {'D24'}, ;
     {'D29.1'}, ;
     {'D30.0'}, ;
     {'D30.3'}, ;
     {'D30.4'}, ;
     {'D31-D31.9'}, ;
     {'D35.0'}, ;
     {'D35.1'}, ;
     {'D35.2'}, ;
     {'D35.8'}, ;
     {'D37.6'}, ;
     {'D39.1'}, ;
     {'D41.0'}, ;
     {'D44.8'}, ;
     {'E04.1'}, ;
     {'E04.2'}, ;
     {'E05.1'}, ;
     {'E05.2'}, ;
     {'E11-E11.9'}, ;   // c E10.2 {'E10.2-E10.9'}, ; 
     {'E21.0'}, ;     
     {'E22.0'}, ; 
     {'E28.2'}, ; 
     {'E34.5'}, ; 
     {'E34.8'}, ; 
     {'E78-E78.9'}, ;
     {'I05'}, ;
     {'I05.0'}, ;
     {'I05.1'}, ;
     {'I05.2'}, ;
     {'I05.8'}, ;
     {'I05.9'}, ;
     {'I06'}, ;
     {'I06.0'}, ;
     {'I06.1'}, ;
     {'I06.2'}, ;
     {'I06.8'}, ;
     {'I06.9'}, ;
     {'I07'}, ;
     {'I07.0'}, ;
     {'I07.1'}, ;
     {'I07.2'}, ;
     {'I07.8'}, ;
     {'I07.9'}, ;
     {'I08'}, ;
     {'I08.0'}, ;
     {'I08.1'}, ;
     {'I08.2'}, ;
     {'I08.3'}, ;
     {'I08.8'}, ;
     {'I08.9'}, ;
     {'I09'}, ;
     {'I09.0'}, ;
     {'I09.1'}, ;
     {'I09.2'}, ;
     {'I09.8'}, ;
     {'I09.9'}, ;
     {'I10'}, ;
     {'I11.0'}, ;
     {'I11.9'}, ;
     {'I12'}, ;
     {'I12.0'}, ;
     {'I12.9'}, ;
     {'I13'}, ; 
     {'I13.0'}, ;
     {'I13.1'}, ;
     {'I13.2'}, ;
     {'I13.9'}, ;
     {'I15'}, ;
     {'I15.0'}, ;
     {'I15.1'}, ;
     {'I15.2'}, ;
     {'I15.8'}, ;
     {'I15.9'}, ;
     {'I20'}, ;
     {'I20.1'}, ;
     {'I20.8'}, ;
     {'I20.9'}, ;
     {'I21'}, ;
     {'I21.0'}, ;
     {'I21.1'}, ;
     {'I21.2'}, ;
     {'I21.3'}, ;
     {'I21.4'}, ;
     {'I21.9'}, ;
     {'I22'}, ;
     {'I22.0'}, ;
     {'I22.1'}, ;
     {'I22.8'}, ;
     {'I22.9'}, ;
     {'I23'}, ;
     {'I23.0'}, ;
     {'I23.1'}, ;
     {'I23.2'}, ;
     {'I23.3'}, ;
     {'I23.4'}, ;
     {'I23.5'}, ;
     {'I23.6'}, ;
     {'I23.8'}, ;
     {'I24'}, ;
     {'I24.0'}, ;
     {'I24.1'}, ; 
     {'I24.8'}, ;
     {'I25'}, ;
     {'I25.0'}, ;
     {'I25.1'}, ;
     {'I25.2'}, ;
     {'I25.3'}, ;
     {'I25.4'}, ;
     {'I25.5'}, ;
     {'I25.6'}, ;
     {'I25.8'}, ;
     {'I25.9'}, ;
     {'I26'}, ;
     {'I26.0'}, ;
     {'I26.9'}, ;
     {'I27.0'}, ;
     {'I27.2'}, ; 
     {'I27.8'}, ;
     {'I28'}, ;
     {'I28.0'}, ;
     {'I28.1'}, ;
     {'I28.8'}, ;
     {'I28.9'}, ;
     {'I33'}, ;
     {'I33.0'}, ;
     {'I33.9'}, ;
     {'I34'}, ;
     {'I34.0'}, ;
     {'I34.1'}, ;
     {'I34.2'}, ;
     {'I34.8'}, ;
     {'I34.9'}, ;
     {'I35'}, ;
     {'I35.0'}, ;
     {'I35.1'}, ;
     {'I35.2'}, ;
     {'I35.8'}, ;
     {'I35.9'}, ;
     {'I36'}, ;
     {'I36.0'}, ;
     {'I36.1'}, ;
     {'I36.2'}, ;
     {'I36.8'}, ;
     {'I36.9'}, ;
     {'I37'}, ;
     {'I37.0'}, ;
     {'I37.1'}, ;
     {'I37.2'}, ;
     {'I37.8'}, ;
     {'I37.9'}, ;
     {'I38'}, ;
     {'I39'}, ;
     {'I39.0'}, ;
     {'I39.1'}, ;
     {'I39.2'}, ;
     {'I39.3'}, ;
     {'I39.4'}, ;
     {'I39.8'}, ;
     {'I40'}, ;
     {'I40.0'}, ;
     {'I40.1'}, ;
     {'I40.8'}, ;
     {'I40.9'}, ;
     {'I41'}, ;
     {'I41.0'}, ;
     {'I41.1'}, ;   
     {'I41.2'}, ;
     {'I41.8'}, ;
     {'I42'}, ;
     {'I42.0'}, ;
     {'I42.1'}, ;
     {'I42.2'}, ;
     {'I42.3'}, ;
     {'I42.4'}, ;
     {'I42.5'}, ;
     {'I42.7'}, ;
     {'I42.8'}, ;
     {'I42.9'}, ; 
     {'I44'}, ; 
     {'I44.0'}, ; 
     {'I44.1'}, ;
     {'I44.2'}, ;
     {'I44.3'}, ;
     {'I44.4'}, ;
     {'I44.5'}, ;
     {'I44.6'}, ;
     {'I44.7'}, ;
     {'I45'}, ;
     {'I45.0'}, ;
     {'I45.1'}, ;
     {'I45.2'}, ;
     {'I45.3'}, ;
     {'I45.4'}, ;
     {'I45.5'}, ;
     {'I45.6'}, ;
     {'I45.8'}, ;
     {'I45.9'}, ;
     {'I46'}, ;
     {'I46.0'}, ;
     {'I46.1'}, ;
     {'I46.9'}, ;
     {'I47'}, ;
     {'I47.0'}, ;
     {'I47.1'}, ;
     {'I47.2'}, ;
     {'I47.9'}, ; 
     {'I48'}, ;
     {'I48.0'}, ;
     {'I48.1'}, ;
     {'I48.2'}, ;
     {'I48.3'}, ;
     {'I48.4'}, ;
     {'I48.9'}, ;
     {'I49'}, ;
     {'I49.0'}, ;
     {'I49.1'}, ;
     {'I49.2'}, ;
     {'I49.3'}, ;
     {'I49.4'}, ;
     {'I49.5'}, ;
     {'I49.8'}, ;
     {'I49.9'}, ;
     {'I50'}, ;
     {'I50.0'}, ;
     {'I50.1'}, ;
     {'I50.9'}, ;
     {'I51.0'}, ;
     {'I51.1'}, ;
     {'I51.2'}, ;
     {'I51.4'}, ;
     {'I65.2'}, ;
     {'I67.8'}, ;
     {'I69.0'}, ;
     {'I69.1'}, ;
     {'I69.2'}, ;
     {'I69.3'}, ;
     {'I69.4'}, ;
     {'I71'}, ;
     {'I71.0'}, ;
     {'I71.1'}, ;
     {'I71.2'}, ;
     {'I71.3'}, ;
     {'I71.4'}, ;
     {'I71.5'}, ;
     {'I71.6'}, ;
     {'I71.8'}, ;
     {'I71.9'}, ;
     {'J12'}, ;
     {'J12.0'}, ;
     {'J12.1'}, ;
     {'J12.2'}, ;
     {'J12.3'}, ;
     {'J12.8'}, ;
     {'J12.9'}, ;
     {'J13'}, ;
     {'J14'}, ;
     {'J31'}, ;
     {'J31.0'}, ; 
     {'J31.1'}, ;
     {'J31.2'}, ;
     {'J33'}, ;
     {'J33.0'}, ;
     {'J33.1'}, ;
     {'J33.8'}, ;
     {'J33.9'}, ;
     {'J37'}, ;
     {'J37.0'}, ;
     {'J37.1'}, ;
     {'J38.1'}, ;
     {'J41.0'}, ;
     {'J41.1'}, ;
     {'J41.8'}, ;
     {'J44.0'}, ;
     {'J44.8'}, ;
     {'J44.9'}, ;
     {'J45.0'}, ;
     {'J45.1'}, ;
     {'J45.8'}, ;
     {'J45.9'}, ;
     {'J47'}, ;
     {'J84.1'}, ;
     {'K13.0'}, ;
     {'K13.2'}, ;
     {'K13.7'}, ;
     {'K20'}, ;
     {'K21.0'}, ;
     {'K22.0'}, ;
     {'K22.2'}, ;
     {'K22.7'}, ;
     {'K25'}, ;
     {'K25.0'}, ;
     {'K25.1'}, ;
     {'K25.2'}, ;
     {'K25.3'}, ;
     {'K25.4'}, ;
     {'K25.5'}, ;
     {'K25.6'}, ;
     {'K25.7'}, ;
     {'K25.9'}, ;
     {'K26'}, ; 
     {'K26.0'}, ;
     {'K26.1'}, ;
     {'K26.2'}, ;
     {'K26.3'}, ;
     {'K26.4'}, ;
     {'K26.5'}, ;
     {'K26.6'}, ;
     {'K26.7'}, ;
     {'K26.9'}, ;
     {'K29.4'}, ;
     {'K29.5'}, ;
     {'K31.7'}, ;
     {'K50'}, ;
     {'K50.0'}, ;
     {'K50.1'}, ;
     {'K50.8'}, ;
     {'K50.9'}, ;
     {'K51'}, ;
     {'K51.0'}, ;
     {'K51.1'}, ;
     {'K51.2'}, ;
     {'K51.3'}, ;
     {'K51.4'}, ;
     {'K51.5'}, ;
     {'K51.8'}, ;
     {'K51.9'}, ;
     {'K62.1'}, ;
     {'K70.3'}, ;
     {'K74.3'}, ;
     {'K74.4'}, ;
     {'K74.5'}, ;
     {'K74.6'}, ;
     {'K86'}, ;
     {'K86.0'}, ;
     {'K86.1'}, ;
     {'K86.2'}, ;
     {'K86.3'}, ;
     {'K86.8'}, ;
     {'K86.9'}, ;
     {'L43'}, ;
     {'L43.0'}, ;    
     {'L43.1'}, ;
     {'L43.2'}, ;
     {'L43.3'}, ;
     {'L43.8'}, ;
     {'L43.9'}, ;
     {'L57.1'}, ;
     {'L82'}, ;
     {'M81.5'}, ;
     {'M85'}, ;
     {'M85.0'}, ;    
     {'M85.1'}, ;
     {'M85.2'}, ; 
     {'M85.3'}, ;
     {'M85.4'}, ;
     {'M85.5'}, ;
     {'M85.6'}, ;
     {'M85.8'}, ;
     {'M85.9'}, ;
     {'M88'}, ;
     {'M88.0'}, ;
     {'M88.8'}, ;
     {'M88.9'}, ;
     {'M96'}, ;
     {'M96.0'}, ; 
     {'M96.1'}, ;
     {'M96.2'}, ; 
     {'M96.3'}, ;
     {'M96.4'}, ;
     {'M96.5'}, ; 
     {'M96.6'}, ; 
     {'M96.8'}, ;
     {'M96.9'}, ;
     {'N18.1'}, ;
     {'N18.9'}, ;
     {'N48.0'}, ;
     {'N60'}, ; 
     {'N60.0'}, ;
     {'N60.1'}, ;
     {'N60.2'}, ;
     {'N60.3'}, ;
     {'N60.4'}, ;
     {'N60.8'}, ;
     {'N60.9'}, ;
     {'N84'}, ;
     {'N84.0'}, ;
     {'N84.1'}, ;
     {'N84.2'}, ;
     {'N84.3'}, ;
     {'N84.8'}, ;
     {'N84.9'}, ;
     {'N85.0'}, ;
     {'N85.1'}, ;
     {'N87.1'}, ;
     {'N87.2'}, ;
     {'N88.0'}, ;
     {'Q20'}, ; 
     {'Q20.0'}, ; 
     {'Q20.1'}, ; 
     {'Q20.2'}, ; 
     {'Q20.3'}, ; 
     {'Q20.4'}, ; 
     {'Q20.5'}, ; 
     {'Q20.6'}, ; 
     {'Q20.8'}, ; 
     {'Q20.9'}, ; 
     {'Q21'}, ; 
     {'Q21.0'}, ; 
     {'Q21.1'}, ; 
     {'Q21.2'}, ; 
     {'Q21.3'}, ; 
     {'Q21.4'}, ; 
     {'Q21.8'}, ; 
     {'Q21.9'}, ;
     {'Q22'}, ; 
     {'Q22.0'}, ;
     {'Q22.1'}, ;
     {'Q22.2'}, ;
     {'Q22.3'}, ;
     {'Q22.4'}, ;
     {'Q22.5'}, ;
     {'Q22.6'}, ;
     {'Q22.8'}, ;
     {'Q22.9'}, ; 
     {'Q23'}, ; 
     {'Q23.0'}, ; 
     {'Q23.1'}, ;
     {'Q23.2'}, ;
     {'Q23.3'}, ;
     {'Q23.4'}, ;
     {'Q23.8'}, ;
     {'Q23.9'}, ;
     {'Q24'}, ;
     {'Q24.0'}, ;
     {'Q24.1'}, ;
     {'Q24.2'}, ;
     {'Q24.3'}, ;
     {'Q24.4'}, ;
     {'Q24.5'}, ;
     {'Q24.6'}, ;
     {'Q24.8'}, ;
     {'Q24.9'}, ;
     {'Q25-Q25.9'}, ;
     {'Q26'}, ;
     {'Q26.0'}, ;
     {'Q26.1'}, ;
     {'Q26.2'}, ;
     {'Q26.3'}, ;
     {'Q26.4'}, ;
     {'Q26.5'}, ;
     {'Q26.6'}, ;
     {'Q26.8'}, ;
     {'Q26.9'}, ;
     {'Q27'}, ;
     {'Q27.0'}, ;
     {'Q27.1'}, ;
     {'Q27.2'}, ;
     {'Q27.3'}, ;
     {'Q27.4'}, ;
     {'Q27.8'}, ;
     {'Q27.9'}, ;
     {'Q28'}, ;
     {'Q28.0'}, ;
     {'Q28.1'}, ;
     {'Q28.2'}, ;
     {'Q28.3'}, ;
     {'Q28.8'}, ;
     {'Q28.9'}, ;
     {'Q78.1'}, ;
     {'Q78.4'}, ;
     {'Q82.1'}, ;
     {'Q82.5'}, ;
     {'Q85.1'}, ;
     {'R73.0'}, ;
     {'R73.9'}, ;
     {'Z95.0'}, ;
     {'Z95.1'}, ;
     {'Z95.2'}, ;
     {'Z95.3'}, ;
     {'Z95.4'}, ;
     {'Z95.5'}, ;
     {'Z95.8'}, ;
     {'Z95.9'};     
    }
    // if pr_168 
    if dUsluga >= 2023 
     // 㤠�塞 ��譥�
     sarr_dn := hb_ADel(sarr_dn, 2, .t.)
     sarr_dn := hb_ADel(sarr_dn, 2, .t.)
     // �������
     aadd(sarr_dn, {'D10.0-D10.7'})
     aadd(sarr_dn, {'D10.9'})
     aadd(sarr_dn, {'D11.9'})   
     aadd(sarr_dn, {'I11'})
     aadd(sarr_dn, {'I24.8'})
    endif  
    len_diag := len(sarr_dn)
    // narr_dn := {}
    for i := 1 to len_diag
      aadd(narr_dn, {})
      for j := 1 to len(sarr_dn[i])
        s := sarr_dn[i, j]
        if '-' $ s
          d1 := token(s, '-', 1)
          d2 := token(s, '-', 2)
        else
          d1 := d2 := s
        endif
        aadd(narr_dn[i], {diag_to_num(d1, 1), diag_to_num(d2, 2)} )
      next j
    next i
  endif
//
  if valtype(ldiag) == 'C'
    d1 := diag_to_num(ldiag, 1)
    for i := 1 to len_diag  // ����砥�� ��������
      if between(d1, narr_dn[i, 1, 1], narr_dn[i, 1, 2])
        fl := .t.
        for j := 2 to len(narr_dn[i]) // ��稭�� � 2-�� ������� - �᪫�砥�� ��������
          if between(d1,narr_dn[i, j, 1], narr_dn[i, j, 2])
            fl := .f.
            exit
          endif
        next j
        exit
      endif
    next i
  endif
  if arr_dn != NIL
    arr_dn := aclone(sarr_dn)
  endif
return fl
