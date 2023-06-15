#include 'hbhash.ch'

// 21.11.22
function ret_V015_V021()
  static _hash_table

  if _hash_table == nil
    _hash_table := hb_hash()
    // hb_hSet(_hash_table, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
    hb_hSet(_hash_table, 1, 49) //    ��������
    hb_hSet(_hash_table, 2, 96) //    ������-��䨫����᪮� ����
    hb_hSet(_hash_table, 3, 69) //    �⮬�⮫���� ��饩 �ࠪ⨪�
    hb_hSet(_hash_table, 4, 101) //    ��ଠ��
    hb_hSet(_hash_table, 5, 100) //    ����ਭ᪮� ����
    hb_hSet(_hash_table, 6, 97) //    ����樭᪠� ���娬��
    hb_hSet(_hash_table, 7, 98) //    ����樭᪠� ���䨧���
    hb_hSet(_hash_table, 8, 2) //    ������⢮ � �����������
    hb_hSet(_hash_table, 9, 4) //    ����⥧�������-ॠ����⮫����
    hb_hSet(_hash_table, 10, 17) //    ��ଠ⮢���஫����
    hb_hSet(_hash_table, 11, 21) //    ���᪠� ���ࣨ�
    hb_hSet(_hash_table, 12, 10) //    ����⨪�
    hb_hSet(_hash_table, 13, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 14, 35) //    ���஫����
    hb_hSet(_hash_table, 15, 37) //    �����⮫����
    hb_hSet(_hash_table, 16, 39) //    ���� ��祡��� �ࠪ⨪� (ᥬ����� ����樭�)
    hb_hSet(_hash_table, 17, 41) //    ���������
    hb_hSet(_hash_table, 18, 42) //    �࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�
    hb_hSet(_hash_table, 19, 45) //    ��ਭ���ਭ�������
    hb_hSet(_hash_table, 20, 46) //    ��⠫쬮�����
    hb_hSet(_hash_table, 21, 48) //    ��⮫����᪠� ���⮬��
    hb_hSet(_hash_table, 22, 49) //    ��������
    hb_hSet(_hash_table, 23, 52) //    ��娠���
    hb_hSet(_hash_table, 24, 60) //    ���⣥�������
    hb_hSet(_hash_table, 25, 66) //    ����� ����樭᪠� ������
    hb_hSet(_hash_table, 26, 73) //    �㤥���-����樭᪠� �ᯥ�⨧�
    hb_hSet(_hash_table, 27, 76) //    ��࠯��
    hb_hSet(_hash_table, 28, 79) //    �ࠢ��⮫���� � ��⮯����
    hb_hSet(_hash_table, 29, 88) //    �⨧�����
    hb_hSet(_hash_table, 30, 90) //    ����ࣨ�
    hb_hSet(_hash_table, 31, 92) //    �����ਭ������
    hb_hSet(_hash_table, 32, 24) //    ��䥪樮��� �������
    hb_hSet(_hash_table, 33, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 34, 87) //    ������࠯��
    hb_hSet(_hash_table, 35, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 36, 93) //    ����᪮���
    hb_hSet(_hash_table, 37, 77) //    ���ᨪ������
    hb_hSet(_hash_table, 38, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 39, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 40, 17) //    ��ଠ⮢���஫����
    hb_hSet(_hash_table, 41, 19) //    ���᪠� ���������
    hb_hSet(_hash_table, 42, 20) //    ���᪠� �஫����-���஫����
    hb_hSet(_hash_table, 43, 28) //    �����ப⮫����
    hb_hSet(_hash_table, 44, 36) //    �������ࣨ�
    hb_hSet(_hash_table, 45, 65) //    ��थ筮-��㤨��� ���ࣨ�
    hb_hSet(_hash_table, 46, 78) //    ��ࠪ��쭠� ���ࣨ�
    hb_hSet(_hash_table, 47, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 48, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 49, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 50, 91) //    �����⭮-��楢�� ���ࣨ�
    hb_hSet(_hash_table, 51, 93) //    ����᪮���
    hb_hSet(_hash_table, 52, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 53, 24) //    ��䥪樮��� �������
    hb_hSet(_hash_table, 54, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 55, 6) //    ����᮫����
    hb_hSet(_hash_table, 56, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 57, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 58, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 59, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 61, 33) //    ���㠫쭠� �࠯��
    hb_hSet(_hash_table, 62, 62) //    ��䫥���࠯��
    hb_hSet(_hash_table, 63, 87) //    ������࠯��
    hb_hSet(_hash_table, 64, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 65, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 66, 11) //    ��ਠ���
    hb_hSet(_hash_table, 67, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 69, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 70, 87) //    ������࠯��
    hb_hSet(_hash_table, 71, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 72, 93) //    ����᪮���
    hb_hSet(_hash_table, 73, 19) //    ���᪠� ���������
    hb_hSet(_hash_table, 74, 57) //    ����������
    hb_hSet(_hash_table, 75, 75) //    ��म�����-��ਭ���ਭ�������
    hb_hSet(_hash_table, 77, 3) //    ����࣮����� � ���㭮�����
    hb_hSet(_hash_table, 78, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 79, 8) //    �������஫����
    hb_hSet(_hash_table, 80, 9) //    ����⮫����
    hb_hSet(_hash_table, 81, 18) //    ���᪠� ��न������
    hb_hSet(_hash_table, 82, 19) //    ���᪠� ���������
    hb_hSet(_hash_table, 83, 22) //    ���᪠� ���ਭ������
    hb_hSet(_hash_table, 84, 23) //    ���⮫����
    hb_hSet(_hash_table, 85, 27) //    ������᪠� �ଠ�������
    hb_hSet(_hash_table, 86, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 88, 33) //    ���㠫쭠� �࠯��
    hb_hSet(_hash_table, 89, 38) //    ���஫����
    hb_hSet(_hash_table, 90, 55) //    ��쬮�������
    hb_hSet(_hash_table, 91, 59) //    �����⮫����
    hb_hSet(_hash_table, 92, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 93, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 94, 87) //    ������࠯��
    hb_hSet(_hash_table, 95, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 96, 93) //    ����᪮���
    hb_hSet(_hash_table, 97, 53) //    ��娠���-��મ�����
    hb_hSet(_hash_table, 98, 54) //    ����࠯��
    hb_hSet(_hash_table, 99, 64) //    ���᮫����
    hb_hSet(_hash_table, 100, 74) //    �㤥���-��娠���᪠� �ᯥ�⨧�
    hb_hSet(_hash_table, 102, 57) //    ����������
    hb_hSet(_hash_table, 103, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 104, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 105, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 107, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 108, 87) //    ������࠯��
    hb_hSet(_hash_table, 109, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 110, 1) //    ����樮���� � ��ᬨ�᪠� ����樭�
    hb_hSet(_hash_table, 112, 3) //    ����࣮����� � ���㭮�����
    hb_hSet(_hash_table, 113, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 114, 8) //    �������஫����
    hb_hSet(_hash_table, 115, 9) //    ����⮫����
    hb_hSet(_hash_table, 116, 11) //    ��ਠ���
    hb_hSet(_hash_table, 117, 23) //    ���⮫����
    hb_hSet(_hash_table, 118, 25) //    ��न������
    hb_hSet(_hash_table, 119, 27) //    ������᪠� �ଠ�������
    hb_hSet(_hash_table, 120, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 122, 33) //    ���㠫쭠� �࠯��
    hb_hSet(_hash_table, 123, 38) //    ���஫����
    hb_hSet(_hash_table, 124, 51) //    ��䯠⮫����
    hb_hSet(_hash_table, 125, 55) //    ��쬮�������
    hb_hSet(_hash_table, 126, 59) //    �����⮫����
    hb_hSet(_hash_table, 127, 62) //    ��䫥���࠯��
    hb_hSet(_hash_table, 128, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 129, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 130, 87) //    ������࠯��
    hb_hSet(_hash_table, 131, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 132, 93) //    ����᪮���
    hb_hSet(_hash_table, 133, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 134, 32) //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    hb_hSet(_hash_table, 136, 33) //    ���㠫쭠� �࠯��
    hb_hSet(_hash_table, 137, 87) //    ������࠯��
    hb_hSet(_hash_table, 138, 55) //    ��쬮�������
    hb_hSet(_hash_table, 139, 28) //    �����ப⮫����
    hb_hSet(_hash_table, 140, 36) //    �������ࣨ�
    hb_hSet(_hash_table, 141, 65) //    ��थ筮-��㤨��� ���ࣨ�
    hb_hSet(_hash_table, 142, 78) //    ��ࠪ��쭠� ���ࣨ�
    hb_hSet(_hash_table, 143, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 144, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 145, 84) //    �஫����
    hb_hSet(_hash_table, 146, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 147, 91) //    �����⭮-��楢�� ���ࣨ�
    hb_hSet(_hash_table, 148, 93) //    ����᪮���
    hb_hSet(_hash_table, 149, 22) //    ���᪠� ���ਭ������
    hb_hSet(_hash_table, 150, 92) //    �����ਭ������
    hb_hSet(_hash_table, 151, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 152, 40) //    ���� �������
    hb_hSet(_hash_table, 153, 67) //    ��樠�쭠� ������� � �࣠������ ���ᠭ���㦡�
    hb_hSet(_hash_table, 154, 94) //    �������������
    hb_hSet(_hash_table, 155, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 156, 6) //    ����᮫����
    hb_hSet(_hash_table, 157, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 158, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 159, 12) //    ������� ��⥩ � �����⪮�
    hb_hSet(_hash_table, 160, 13) //    ������� ��⠭��
    hb_hSet(_hash_table, 161, 14) //    ������� ��㤠
    hb_hSet(_hash_table, 162, 15) //    ��������᪮� ��ᯨ⠭��
    hb_hSet(_hash_table, 163, 29) //    ����㭠�쭠� �������
    hb_hSet(_hash_table, 164, 56) //    �����樮���� �������
    hb_hSet(_hash_table, 165, 63) //    �����୮-��������᪨� �������� ��᫥�������
    hb_hSet(_hash_table, 167, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 168, 6) //    ����᮫����
    hb_hSet(_hash_table, 169, 16) //    �����䥪⮫����
    hb_hSet(_hash_table, 170, 47) //    ��ࠧ�⮫����
    hb_hSet(_hash_table, 171, 69) //    �⮬�⮫���� ��饩 �ࠪ⨪�
    hb_hSet(_hash_table, 172, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 173, 43) //    ��⮤����
    hb_hSet(_hash_table, 174, 68) //    �⮬�⮫���� ���᪠�
    hb_hSet(_hash_table, 175, 70) //    �⮬�⮫���� ��⮯����᪠�
    hb_hSet(_hash_table, 176, 71) //    �⮬�⮫���� �࠯����᪠�
    hb_hSet(_hash_table, 177, 72) //    �⮬�⮫���� ���ࣨ�᪠�
    hb_hSet(_hash_table, 178, 91) //    �����⭮-��楢�� ���ࣨ�
    hb_hSet(_hash_table, 179, 87) //    ������࠯��
    hb_hSet(_hash_table, 180, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 181, 6) //    ����᮫����
    hb_hSet(_hash_table, 182, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 183, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 184, 82) //    ��ࠢ����� � ������� �ଠ樨
    hb_hSet(_hash_table, 185, 86) //    ��ଠ楢��᪠� 娬�� � �ଠ��������
    hb_hSet(_hash_table, 186, 83) //    ��ࠢ����� ���ਭ᪮� ���⥫쭮����
    hb_hSet(_hash_table, 187, 10) //    ����⨪�
    hb_hSet(_hash_table, 188, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 189, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 190, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 191, 6) //    ����᮫����
    hb_hSet(_hash_table, 192, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 193, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 194, 73) //    �㤥���-����樭᪠� �ᯥ�⨧�
    hb_hSet(_hash_table, 195, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 196, 60) //    ���⣥�������
    hb_hSet(_hash_table, 197, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 198, 6) //    ����᮫����
    hb_hSet(_hash_table, 199, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 200, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 201, 57) //    ����������
    hb_hSet(_hash_table, 202, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 203, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 206, 206) //    ��祡��� ���� (�।��� ������ᮭ��)
    hb_hSet(_hash_table, 207, 207) //    �����᪮� ���� (�।��� ������ᮭ��)
    hb_hSet(_hash_table, 208, 208) //    �⮬�⮫���� (�।��� ������ᮭ��)
    hb_hSet(_hash_table, 209, 209) //    �⮬�⮫���� ��⮯����᪠�
    hb_hSet(_hash_table, 215, 215) //    ������ୠ� �������⨪�
    hb_hSet(_hash_table, 217, 217) //    ������୮� ����
    hb_hSet(_hash_table, 219, 219) //    ����ਭ᪮� ����
    hb_hSet(_hash_table, 221, 221) //    ����ਭ᪮� ���� � ������ਨ
    hb_hSet(_hash_table, 223, 223) //    ����⥧������� � ॠ����⮫����
    hb_hSet(_hash_table, 224, 224) //    ���� �ࠪ⨪�
    hb_hSet(_hash_table, 226, 226) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 227, 227) //    ������࠯��
    hb_hSet(_hash_table, 228, 228) //    ����樭᪨� ���ᠦ
    hb_hSet(_hash_table, 229, 85) //    ��ଠ楢��᪠� �孮�����
    hb_hSet(_hash_table, 230, 230) //    ��祡��� 䨧������
    hb_hSet(_hash_table, 231, 231) //    ���⮫����
    hb_hSet(_hash_table, 233, 233) //    �⮬�⮫���� ��䨫����᪠�
    hb_hSet(_hash_table, 236, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 237, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 238, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 239, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 240, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 241, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 242, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 243, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 244, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 245, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 246, 34) //    ������-�樠�쭠� �ᯥ�⨧�
    hb_hSet(_hash_table, 247, 50) //    ������᪠� ���ࣨ�
    hb_hSet(_hash_table, 248, 61) //    ���⣥���������� �������⨪� � ��祭��
    hb_hSet(_hash_table, 249, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 250, 61) //    ���⣥���������� �������⨪� � ��祭��
    hb_hSet(_hash_table, 251, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 252, 30) //    ��ᬥ⮫����
    hb_hSet(_hash_table, 253, 61) //    ���⣥���������� �������⨪� � ��祭��
    hb_hSet(_hash_table, 254, 61) //    ���⣥���������� �������⨪� � ��祭��
    hb_hSet(_hash_table, 255, 3) //    ����࣮����� � ���㭮�����
    hb_hSet(_hash_table, 256, 7) //    ���������� ����樭�
    hb_hSet(_hash_table, 257, 8) //    �������஫����
    hb_hSet(_hash_table, 258, 9) //    ����⮫����
    hb_hSet(_hash_table, 259, 23) //    ���⮫����
    hb_hSet(_hash_table, 260, 25) //    ��न������
    hb_hSet(_hash_table, 261, 38) //    ���஫����
    hb_hSet(_hash_table, 262, 55) //    ��쬮�������
    hb_hSet(_hash_table, 263, 59) //    �����⮫����
    hb_hSet(_hash_table, 264, 80) //    �࠭��㧨������
    hb_hSet(_hash_table, 265, 61) //    ���⣥���������� �������⨪� � ��祭��
    hb_hSet(_hash_table, 266, 61) //    ���⣥���������� �������⨪� � ��祭��
    hb_hSet(_hash_table, 267, 42) //    �࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�
    hb_hSet(_hash_table, 268, 42) //    �࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�
    hb_hSet(_hash_table, 269, 99) //    ����樭᪠� ����୥⨪�
    hb_hSet(_hash_table, 270, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 271, 60) //    ���⣥�������
    hb_hSet(_hash_table, 272, 5) //    ����ਮ�����
    hb_hSet(_hash_table, 273, 6) //    ����᮫����
    hb_hSet(_hash_table, 274, 31) //    ������ୠ� ����⨪�
    hb_hSet(_hash_table, 275, 26) //    ������᪠� ������ୠ� �������⨪�
    hb_hSet(_hash_table, 276, 57) //    ����������
    hb_hSet(_hash_table, 277, 89) //    �㭪樮���쭠� �������⨪�
    hb_hSet(_hash_table, 278, 81) //    ����ࠧ�㪮��� �������⨪�
    hb_hSet(_hash_table, 280, 280) //    ��મ�����
    hb_hSet(_hash_table, 281, 281) //    ��������樮���� ���ਭ᪮� ����
    hb_hSet(_hash_table, 283, 283) //    ����� � ���⫮���� ������
    hb_hSet(_hash_table, 286, 87) //    ������࠯��
    hb_hSet(_hash_table, 288, 98) //    ����樭᪠� ���䨧���
    hb_hSet(_hash_table, 289, 98) //    ����樭᪠� ���䨧���
    hb_hSet(_hash_table, 290, 99) //    ����樭᪠� ����୥⨪�
    hb_hSet(_hash_table, 3200, 97) //    ����樭᪠� ���娬��
    hb_hSet(_hash_table, 3201, 97) //    ����樭᪠� ���娬��

  endif
  return _hash_table