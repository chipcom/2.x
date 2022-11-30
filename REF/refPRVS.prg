#include 'function.ch'
#include 'chip_mo.ch'
#include 'hbhash.ch'

** 25.01.16 ������ ��� ᯥ樠�쭮�� �� �ࠢ�筨�� V015 �� ���� �� �ࠢ�筨�� V004
Function ret_V004_V015(_PRVS)
  Local i, ret := 0
  if (i := ascan(glob_arr_V004_V015, {|x| x[1] == _PRVS })) > 0
    ret := glob_arr_V004_V015[i, 2]
  endif
  return ret
  
** 05.08.21 ������ ���祭�� ᯥ樠�쭮�� �� ����஢�� �ࠢ�筨�� V015 � ����஢�� �ࠢ�筨�� V021
Function ret_prvs_V015toV021(lkod)
  Local i, new_kod := 76 // �� 㬮�砭�� - �࠯��

  if (i := ascan(glob_arr_V015_V021, {|x| x[1] == lkod })) > 0
    new_kod := glob_arr_V015_V021[i, 2]
  endif
  return new_kod
  
** 26.05.22 ������ ��� ����� ����樭᪮� ᯥ樠�쭮�� � ����஢�� �ࠢ�筨�� V015
Function ret_new_spec(old_spec, new_spec)
  Local i, lkod := 0

  if empty(new_spec)
    if !empty(old_spec) .and. (i := ascan(glob_arr_V004_V015, {|x| x[1] == old_spec })) > 0
      lkod := glob_arr_V004_V015[i, 2]
    endif
  else
    lkod := new_spec
  endif
  return lkod
  
** 28.05.22 ������ ���祭�� ᯥ樠�쭮�� � ����஢�� �ࠢ�筨�� V004
Function ret_old_prvs(new_kod)
  Local i, old_kod := new_kod
  local arr_conv := conversion_V015_V004()

  if new_kod < 0
    new_kod := abs(new_kod)
    if (i := ascan(glob_arr_V004_V015, {|x| x[2] == new_kod })) > 0
      old_kod := glob_arr_V004_V015[i, 1]
    // elseif (i := ascan(glob_arr_V015_V004, {|x| x[3] == new_kod })) > 0
    //   old_kod := glob_arr_V015_V004[i, 1]
    elseif (i := ascan(arr_conv, {|x| x[3] == new_kod })) > 0
      old_kod := arr_conv[i, 1]
    endif
  endif
  return old_kod
  
** 26.05.22 ������ ���祭�� ᯥ樠�쭮�� � ����஢�� �ࠢ�筨�� V015
Function ret_new_prvs(_prvs)
  Local new_kod

  if _prvs < 0
    new_kod := abs(_prvs)
  else
    new_kod := ret_V004_V015(_prvs)
  endif
  return new_kod
  
** 26.05.22 ������ ���祭�� ᯥ樠�쭮�� �� ����஢�� �ࠢ�筨�� V015 � ����஢�� �ࠢ�筨�� V021
Function ret_prvs_V021(_prvs)
  Local i, new_kod := 76, ; // �� 㬮�砭�� - �࠯��
        lkod := ret_new_prvs(_prvs) // � ����஢�� �ࠢ�筨�� V015

  if (i := ascan(glob_arr_V015_V021, {|x| x[1] == lkod })) > 0
    new_kod := glob_arr_V015_V021[i, 2]
  endif
  return new_kod
  
** 26.05.22 ��ॢ��� ᯥ樠�쭮��� �� ����஢�� �ࠢ�筨�� V021 � V015
Function prvs_V021_to_V015(_prvs)
  Local i, new_kod := 27 // �� 㬮�砭�� - �࠯��

  if valtype(_prvs) == 'C'
    _prvs := int(val(_prvs))
  endif
  if (i := ascan(glob_arr_V015_V021, {|x| x[2] == _prvs })) > 0
    new_kod := glob_arr_V015_V021[i, 1]
  endif
  return new_kod
  
** 28.05.22 ������ ���ᨢ ᮮ⢥��⢨� ᯥ樠�쭮�� V015 ᯥ樠�쭮��� V0004
Function ret_arr_new_olds_prvs()
  Local i, j, np, op, arr := {}
  local arr_conv := conversion_V015_V004()

  for i := 1 to len(glob_arr_V004_V015)
    op := glob_arr_V004_V015[i, 1]
    np := glob_arr_V004_V015[i, 2]
    if (j := ascan(arr, {|x| x[1] == np })) == 0
      aadd(arr, {np, {}})
      j := len(arr)
    endif
    aadd(arr[j, 2], op)
  next
  // for i := 1 to len(glob_arr_V015_V004)
  for i := 1 to len(arr_conv)
    // op := glob_arr_V015_V004[i, 1]
    // np := glob_arr_V015_V004[i, 3]
    op := arr_conv[i, 1]
    np := arr_conv[i, 3]
    if (j := ascan(arr, {|x| x[1] == np })) == 0
      aadd(arr, {np, {}})
      j := len(arr)
    endif
    aadd(arr[j, 2], op)
  next
  return asort(arr, , , {|x, y| x[1] < y[1] })
  
** 26.05.22 ������ ���祭�� ᯥ樠�쭮�� ��� XML-䠩�� ॥���
Function put_prvs_to_reestr(_PRVS, _YEAR)
  Local k := _PRVS

  if _YEAR > 2018             // � ����஢�� V021
    k := ret_prvs_V021(_PRVS)
  elseif _YEAR < 2016         // � ����஢�� V004
    k := ret_old_prvs(_PRVS)
  else                        // � ����஢�� V015
    if _PRVS < 0
      k := abs(_PRVS)
    else
      k := ret_V004_V015(_PRVS)
    endif
  endif
  return lstr(k)
  
** 24.11.22 ᮮ⢥��⢨� �ࠢ�筨�� V015 -> V021
function conversion_V015_V021()
  static arr

  if arr == nil
    arr := { ;
    {  1,  49  }, ; //    ��������
    {  2,  96  }, ; //    ������-��䨫����᪮� ����
    {  3,  69  }, ; //    �⮬�⮫���� ��饩 �ࠪ⨪�
    {  4,  101 }, ; //    ��ଠ��
    {  5,  100 }, ; //    ����ਭ᪮� ����
    {  6,  97  }, ; //    ����樭᪠� ���娬��
    {  7,  98  }, ; //    ����樭᪠� ���䨧���
    {  8,  2   }, ; //    ������⢮ � �����������
    {  9,  4   }, ; //    ����⥧�������-ॠ����⮫����
    { 10,  17  }, ; //    ��ଠ⮢���஫����
    { 11,  21  }, ; //    ���᪠� ���ࣨ�
    { 12,  10  }, ; //    ����⨪�
    { 13,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    { 14,  35  }, ; //    ���஫����
    { 15,  37  }, ; //    �����⮫����
    { 16,  39  }, ; //    ���� ��祡��� �ࠪ⨪� (ᥬ����� ����樭�)
    { 17,  41  }, ; //    ���������
    { 18,  42  }, ; //    �࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�
    { 19,  45  }, ; //    ��ਭ���ਭ�������
    { 20,  46  }, ; //    ��⠫쬮�����
    { 21,  48  }, ; //    ��⮫����᪠� ���⮬��
    { 22,  49  }, ; //    ��������
    { 23,  52  }, ; //    ��娠���
    { 24,  60  }, ; //    ���⣥�������
    { 25,  66  }, ; //    ����� ����樭᪠� ������
    { 26,  73  }, ; //    �㤥���-����樭᪠� ��ᯥ�⨧�
    { 27,  76  }, ; //    ��࠯��
    { 28,  79  }, ; //    �ࠢ��⮫���� � ��⮯����
    { 29,  88  }, ; //    �⨧�����
    { 30,  90  }, ; //    ����ࣨ�
    { 31,  92  }, ; //    �����ਭ������
    { 32,  24  }, ; //    ��䥪樮��� �������
    { 33,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    { 34,  87  }, ; //    ������࠯��
    { 35,  89  }, ; //    �㭪樮���쭠� �������⨪�
    { 36,  93  }, ; //    ����᪮���
    { 37,  77  }, ; //    ���ᨪ������
    { 38,  80  }, ; //    �࠭��㧨������
    { 39,  89  }, ; //    �㭪樮���쭠� �������⨪�
    { 40,  17  }, ; //    ��ଠ⮢���஫����
    { 41,  19  }, ; //    ���᪠� ���������
    { 42,  20  }, ; //    ���᪠� �஫����-���஫����
    { 43,  28  }, ; //    �����ப⮫����
    { 44,  36  }, ; //    �������ࣨ�
    { 45,  65  }, ; //    ��थ筮-��㤨��� ���ࣨ�
    { 46,  78  }, ; //    ��ࠪ��쭠� ���ࣨ�
    { 47,  80  }, ; //    �࠭��㧨������
    { 48,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    { 49,  89  }, ; //    �㭪樮���쭠� �������⨪�
    { 50,  91  }, ; //    �����⭮-��楢�� ���ࣨ�
    { 51,  93  }, ; //    ����᪮���
    { 52,  31  }, ; //    ������ୠ� ����⨪�
    { 53,  24  }, ; //    ��䥪樮��� �������
    { 54,  5   }, ; //    ����ਮ�����
    { 55,  6   }, ; //    ����᮫����
    { 56,  31  }, ; //    ������ୠ� ����⨪�
    { 57,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    { 58,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    { 59,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    { 61,  33  }, ; //    ���㠫쭠� �࠯��
    { 62,  62  }, ; //    ��䫥���࠯��
    { 63,  87  }, ; //    ������࠯��
    { 64,  89  }, ; //    �㭪樮���쭠� �������⨪�
    { 65,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    { 66,  11  }, ; //    ��ਠ���
    { 67,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    { 69,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    { 70,  87  }, ; //    ������࠯��
    { 71,  89  }, ; //    �㭪樮���쭠� �������⨪�
    { 72,  93  }, ; //    ����᪮���
    { 73,  19  }, ; //    ���᪠� ���������
    { 74,  57  }, ; //    ����������
    { 75,  75  }, ; //    ��म�����-��ਭ���ਭ�������
    { 77,  3   }, ; //    ����࣮����� � ���㭮�����
    { 78,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    { 79,  8   }, ; //    ��������஫����
    { 80,  9   }, ; //    ����⮫����
    { 81,  18  }, ; //    ���᪠� ��न������
    { 82,  19  }, ; //    ���᪠� ���������
    { 83,  22  }, ; //    ���᪠� �����ਭ������
    { 84,  23  }, ; //    ���⮫����
    { 85,  27  }, ; //    ������᪠� �ଠ�������
    { 86,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    { 88,  33  }, ; //    ���㠫쭠� �࠯��
    { 89,  38  }, ; //    ���஫����
    { 90,  55  }, ; //    ��쬮�������
    { 91,  59  }, ; //    �����⮫����
    { 92,  80  }, ; //    �࠭��㧨������
    { 93,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    { 94,  87  }, ; //    ������࠯��
    { 95,  89  }, ; //    �㭪樮���쭠� �������⨪�
    { 96,  93  }, ; //    ����᪮���
    { 97,  53  }, ; //    ��娠���-��મ�����
    { 98,  54  }, ; //    ����࠯��
    { 99,  64  }, ; //    ���᮫����
    {100,  74  }, ; //    �㤥���-��娠���᪠� ��ᯥ�⨧�
    {102,  57  }, ; //    ����������
    {103,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {104,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    {105,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    {107,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {108,  87  }, ; //    ������࠯��
    {109,  89  }, ; //    �㭪樮���쭠� �������⨪�
    {110,  1   }, ; //    ����樮���� � ��ᬨ�᪠� ����樭�
    {112,  3   }, ; //    ����࣮����� � ���㭮�����
    {113,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    {114,  8   }, ; //    ��������஫����
    {115,  9   }, ; //    ����⮫����
    {116,  11  }, ; //    ��ਠ���
    {117,  23  }, ; //    ���⮫����
    {118,  25  }, ; //    ��न������
    {119,  27  }, ; //    ������᪠� �ଠ�������
    {120,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    {122,  33  }, ; //    ���㠫쭠� �࠯��
    {123,  38  }, ; //    ���஫����
    {124,  51  }, ; //    ��䯠⮫����
    {125,  55  }, ; //    ��쬮�������
    {126,  59  }, ; //    �����⮫����
    {127,  62  }, ; //    ��䫥���࠯��
    {128,  80  }, ; //    �࠭��㧨������
    {129,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {130,  87  }, ; //    ������࠯��
    {131,  89  }, ; //    �㭪樮���쭠� �������⨪�
    {132,  93  }, ; //    ����᪮���
    {133,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    {134,  32  }, ; //    ��祡��� 䨧������ � ᯮ�⨢��� ����樭�
    {136,  33  }, ; //    ���㠫쭠� �࠯��
    {137,  87  }, ; //    ������࠯��
    {138,  55  }, ; //    ��쬮�������
    {139,  28  }, ; //    �����ப⮫����
    {140,  36  }, ; //    �������ࣨ�
    {141,  65  }, ; //    ��थ筮-��㤨��� ���ࣨ�
    {142,  78  }, ; //    ��ࠪ��쭠� ���ࣨ�
    {143,  80  }, ; //    �࠭��㧨������
    {144,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {145,  84  }, ; //    �஫����
    {146,  89  }, ; //    �㭪樮���쭠� �������⨪�
    {147,  91  }, ; //    �����⭮-��楢�� ���ࣨ�
    {148,  93  }, ; //    ����᪮���
    {149,  22  }, ; //    ���᪠� �����ਭ������
    {150,  92  }, ; //    �����ਭ������
    {151,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {152,  40  }, ; //    ���� �������
    {153,  67  }, ; //    ��樠�쭠� ������� � �࣠������ ���ᠭ�����㦡�
    {154,  94  }, ; //    �������������
    {155,  5   }, ; //    ����ਮ�����
    {156,  6   }, ; //    ����᮫����
    {157,  31  }, ; //    ������ୠ� ����⨪�
    {158,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {159,  12  }, ; //    ������� ��⥩ � �����⪮�
    {160,  13  }, ; //    ������� ��⠭��
    {161,  14  }, ; //    ������� ��㤠
    {162,  15  }, ; //    ��������᪮� ��ᯨ⠭��
    {163,  29  }, ; //    ����㭠�쭠� �������
    {164,  56  }, ; //    �����樮���� �������
    {165,  63  }, ; //    �����୮-��������᪨� �������� ��᫥�������
    {167,  5   }, ; //    ����ਮ�����
    {168,  6   }, ; //    ����᮫����
    {169,  16  }, ; //    �����䥪⮫����
    {170,  47  }, ; //    ��ࠧ�⮫����
    {171,  69  }, ; //    �⮬�⮫���� ��饩 �ࠪ⨪�
    {172,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {173,  43  }, ; //    ��⮤����
    {174,  68  }, ; //    �⮬�⮫���� ���᪠�
    {175,  70  }, ; //    �⮬�⮫���� ��⮯����᪠�
    {176,  71  }, ; //    �⮬�⮫���� �࠯����᪠�
    {177,  72  }, ; //    �⮬�⮫���� ���ࣨ�᪠�
    {178,  91  }, ; //    �����⭮-��楢�� ���ࣨ�
    {179,  87  }, ; //    ������࠯��
    {180,  5   }, ; //    ����ਮ�����
    {181,  6   }, ; //    ����᮫����
    {182,  31  }, ; //    ������ୠ� ����⨪�
    {183,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {184,  82  }, ; //    ��ࠢ����� � ��������� �ଠ樨
    {185,  86  }, ; //    ��ଠ楢��᪠� 娬�� � �ଠ��������
    {186,  83  }, ; //    ��ࠢ����� ���ਭ᪮� ���⥫쭮����
    {187,  10  }, ; //    ����⨪�
    {188,  31  }, ; //    ������ୠ� ����⨪�
    {189,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {190,  5   }, ; //    ����ਮ�����
    {191,  6   }, ; //    ����᮫����
    {192,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {193,  31  }, ; //    ������ୠ� ����⨪�
    {194,  73  }, ; //    �㤥���-����樭᪠� ��ᯥ�⨧�
    {195,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {196,  60  }, ; //    ���⣥�������
    {197,  5   }, ; //    ����ਮ�����
    {198,  6   }, ; //    ����᮫����
    {199,  31  }, ; //    ������ୠ� ����⨪�
    {200,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {201,  57  }, ; //    ����������
    {202,  89  }, ; //    �㭪樮���쭠� �������⨪�
    {203,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {206,  206 }, ; //    ��祡��� ���� (�।��� ������ᮭ��)
    {207,  207 }, ; //    �����᪮� ���� (�।��� ������ᮭ��)
    {208,  208 }, ; //    �⮬�⮫���� (�।��� ������ᮭ��)
    {209,  209 }, ; //    �⮬�⮫���� ��⮯����᪠�
    {215,  215 }, ; //    ������ୠ� �������⨪�
    {217,  217 }, ; //    ������୮� ����
    {219,  219 }, ; //    ����ਭ᪮� ����
    {221,  221 }, ; //    ����ਭ᪮� ���� � ������ਨ
    {223,  223 }, ; //    ����⥧������� � ॠ����⮫����
    {224,  224 }, ; //    ���� �ࠪ⨪�
    {226,  226 }, ; //    �㭪樮���쭠� �������⨪�
    {227,  227 }, ; //    ������࠯��
    {228,  228 }, ; //    ����樭᪨� ���ᠦ
    {229,  85  }, ; //    ��ଠ楢��᪠� �孮�����
    {230,  230 }, ; //    ��祡��� 䨧������
    {231,  231 }, ; //    ���⮫����
    {233,  233 }, ; //    �⮬�⮫���� ��䨫����᪠�
    {236,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {237,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {238,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {239,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {240,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {241,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {242,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {243,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {244,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {245,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {246,  34  }, ; //    ������-�樠�쭠� ��ᯥ�⨧�
    {247,  50  }, ; //    ������᪠� ���ࣨ�
    {248,  61  }, ; //    ���⣥������������ �������⨪� � ��祭��
    {249,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {250,  61  }, ; //    ���⣥������������ �������⨪� � ��祭��
    {251,  80  }, ; //    �࠭��㧨������
    {252,  30  }, ; //    ��ᬥ⮫����
    {253,  61  }, ; //    ���⣥������������ �������⨪� � ��祭��
    {254,  61  }, ; //    ���⣥������������ �������⨪� � ��祭��
    {255,  3   }, ; //    ����࣮����� � ���㭮�����
    {256,  7   }, ; //    ���������� ����樭�
    {257,  8   }, ; //    ��������஫����
    {258,  9   }, ; //    ����⮫����
    {259,  23  }, ; //    ���⮫����
    {260,  25  }, ; //    ��न������
    {261,  38  }, ; //    ���஫����
    {262,  55  }, ; //    ��쬮�������
    {263,  59  }, ; //    �����⮫����
    {264,  80  }, ; //    �࠭��㧨������
    {265,  61  }, ; //    ���⣥������������ �������⨪� � ��祭��
    {266,  61  }, ; //    ���⣥������������ �������⨪� � ��祭��
    {267,  42  }, ; //    �࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�
    {268,  42  }, ; //    �࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�
    {269,  99  }, ; //    ����樭᪠� ����୥⨪�
    {270,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {271,  60  }, ; //    ���⣥�������
    {272,  5   }, ; //    ����ਮ�����
    {273,  6   }, ; //    ����᮫����
    {274,  31  }, ; //    ������ୠ� ����⨪�
    {275,  26  }, ; //    ������᪠� ������ୠ� �������⨪�
    {276,  57  }, ; //    ����������
    {277,  89  }, ; //    �㭪樮���쭠� �������⨪�
    {278,  81  }, ; //    ����ࠧ�㪮��� �������⨪�
    {280,  280 }, ; //    ��મ�����
    {281,  281 }, ; //    ��������樮���� ���ਭ᪮� ����
    {283,  283 }, ; //    ����� � ���⫮���� ������
    {286,  87  }, ; //    ������࠯��
    {288,  98  }, ; //    ����樭᪠� ���䨧���
    {289,  98  }, ; //    ����樭᪠� ���䨧���
    {290,  99  }, ; //    ����樭᪠� ����୥⨪�
    {3200, 97  }, ; //    ����樭᪠� ���娬��
    {3201, 97  };  //    ����樭᪠� ���娬��
    }
  endif

  return arr

** 24.11.22 ᮮ⢥��⢨� �ࠢ�筨�� V004 -> V015
function conversion_V004_V015()
  static arr

  if arr == nil
    arr := { ;
    {     1,  0, '���襥 ����樭᪮� ��ࠧ������'}, ;
    {    11,  1, '��祡��� ����. ��������'}, ;
    {  1101,  8, '������⢮ � �����������'}, ;
    {110101, 33, '����ࠧ�㪮��� �������⨪�'}, ;
    {110102, 34, '������࠯��'}, ;
    {110103, 35, '�㭪樮���쭠� �������⨪�'}, ;
    {110104, 36, '����᪮���'}, ;
    {  1103,  9, '����⥧������� � ॠ����⮫����'}, ;
    {110301, 37, '���ᨪ������'}, ;
    {110302, 38, '�࠭��㧨������'}, ;
    {110303, 39, '�㭪樮���쭠� �������⨪�'}, ;
    {  1104, 10, '��ଠ⮢���஫����'}, ;
    {110401, 40, '������᪠� ���������'}, ;
    {  1105, 12, '����⨪�'}, ;
    {110501, 52, '������ୠ� ����⨪�'}, ;
    {  1106, 32, '��䥪樮��� �������'}, ;
    {110601, 53, '������᪠� ���������'}, ;
    {  1107, 13, '������᪠� ������ୠ� �������⨪�'}, ;
    {110701, 54, '����ਮ�����'}, ;
    {110702, 55, '����᮫����'}, ;
    {110703, 56, '������ୠ� ����⨪�'}, ;
    {110704, 57, '������ୠ� ���������'}, ;
    {  1109, 14, '���஫����'}, ;
    {110901, 61, '���㠫쭠� �࠯��'}, ;
    {110902, 62, '��䫥���࠯��'}, ;
    {110903, 58, '����⠭���⥫쭠� ����樭�'}, ;
    {110904, 59, '��祡��� 䨧������ � ᯮ�⨢��� ����樭�'}, ;
    {110905, 63, '������࠯��'}, ;
    {110906, 64, '�㭪樮���쭠� �������⨪�'}, ;
    {  1110, 16, '���� ��祡��� �ࠪ⨪� (ᥬ����� ����樭�)'}, ;
    {111001, 65, '����⠭���⥫쭠� ����樭�'}, ;
    {111002, 66, '��ਠ���'}, ;
    {111003, 67, '��祡��� 䨧������ � ᯮ�⨢��� ����樭�'}, ;
    {111004, 69, '����ࠧ�㪮��� �������⨪�'}, ;
    {111005, 70, '������࠯��'}, ;
    {111006, 71, '�㭪樮���쭠� �������⨪�'}, ;
    {111007, 72, '����᪮���'}, ;
    {  1111, 19, '�⮫�ਭ�������'}, ;
    {111101, 75, '��म�����-�⮫�ਭ�������'}, ;
    {  1112, 20, '��⠫쬮�����'}, ;
    {  1113, 21, '��⮫����᪠� ���⮬��'}, ;
    {  1115, 23, '��娠���'}, ;
    {111501, 98, '����࠯��'}, ;
    {111502, 99, '���᮫����'}, ;
    {111503, 100, '�㤥���-��娠���᪠� ��ᯥ�⨧�'}, ;
    {111504, 97, '��娠���-��મ�����'}, ;
    {  1118, 24, '���⣥�������'}, ;
    {111801, 102, '����������'}, ;
    {111802, 103, '����ࠧ�㪮��� �������⨪�'}, ;
    {  1119, 25, '����� ����樭᪠� ������'}, ;
    {111901, 104, '����⠭���⥫쭠� ����樭�'}, ;
    {111902, 105, '��祡��� 䨧������ � ᯮ�⨢��� ����樭�'}, ;
    {111903, 107, '����ࠧ�㪮��� �������⨪�'}, ;
    {111904, 108, '������࠯��'}, ;
    {111905, 109, '�㭪樮���쭠� �������⨪�'}, ;
    {  1120, 18, '�࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�'}, ;
    {  1121, 26, '�㤥���-����樭᪠� ��ᯥ�⨧�'}, ;
    {  1122, 27, '��࠯��'}, ;
    {112201, 114, '��������஫����'}, ;
    {112202, 115, '����⮫����'}, ;
    {112203, 116, '��ਠ���'}, ;
    {112204, 117, '���⮫����'}, ;
    {112205, 118, '��न������'}, ;
    {112206, 119, '������᪠� �ଠ�������'}, ;
    {112207, 123, '���஫����'}, ;
    {112208, 125, '��쬮�������'}, ;
    {112209, 126, '�����⮫����'}, ;
    {112210, 128, '�࠭��㧨������'}, ;
    {112211, 129, '����ࠧ�㪮��� �������⨪�'}, ;
    {112212, 131, '�㭪樮���쭠� �������⨪�'}, ;
    {112213, 110, '����樮���� � ��ᬨ�᪠� ����樭�'}, ;
    {112214, 112, '����࣮����� � ���㭮�����'}, ;
    {112215, 113, '����⠭���⥫쭠� ����樭�'}, ;
    {112216, 120, '��祡��� 䨧������ � ᯮ�⨢��� ����樭�'}, ;
    {112217, 122, '���㠫쭠� �࠯��'}, ;
    {112218, 124, '��䯠⮫����'}, ;
    {112219, 127, '��䫥���࠯��'}, ;
    {112220, 130, '������࠯��'}, ;
    {112221, 132, '����᪮���'}, ;
    {  1123, 28, '�ࠢ��⮫���� � ��⮯����'}, ;
    {112301, 136, '���㠫쭠� �࠯��'}, ;
    {112302, 133, '����⠭���⥫쭠� ����樭�'}, ;
    {112303, 134, '��祡��� 䨧������ � ᯮ�⨢��� ����樭�'}, ;
    {112304, 285, '����������'}, ;
    {  1124, 137, '������࠯��'}, ;
    {  1125, 29, '�⨧�����'}, ;
    {112501, 138, '��쬮�������'}, ;
    {  1126, 30, '����ࣨ�'}, ;
    {112601, 139, '�����ப⮫����'}, ;
    {112602, 140, '�������ࣨ�'}, ;
    {112603, 145, '�஫����'}, ;
    {112604, 141, '��थ筮-��㤨��� ���ࣨ�'}, ;
    {112605, 142, '��ࠪ��쭠� ���ࣨ�'}, ;
    {112606, 143, '�࠭��㧨������'}, ;
    {112608, 147, '�����⭮-��楢�� ���ࣨ�'}, ;
    {112609, 148, '����᪮���'}, ;
    {112610, 144, '����ࠧ�㪮��� �������⨪�'}, ;
    {112611, 146, '�㭪樮���쭠� �������⨪�'}, ;
    {  1127, 31, '�����ਭ������'}, ;
    {112701, 150, '�����⮫����'}, ;
    {112702, 149, '���᪠� �����ਭ������'}, ;
    {  1128, 17, '���������'}, ;
    {112801, 73, '���᪠� ���������'}, ;
    {112802, 74, '����������'}, ;
    {  1134, 22, '��������'}, ;
    {113401, 82, '���᪠� ���������'}, ;
    {113402, 83, '���᪠� �����ਭ������'}, ;
    {113403, 81, '���᪠� ��न������'}, ;
    {113404, 86, '��祡��� 䨧������ � ᯮ�⨢��� ����樭�'}, ;
    {113405, 77, '����࣮����� � ���㭮�����'}, ;
    {113406, 78, '����⠭���⥫쭠� ����樭�'}, ;
    {113407, 79, '��������஫����'}, ;
    {113408, 80, '����⮫����'}, ;
    {113409, 84, '���⮫����'}, ;
    {113410, 85, '������᪠� �ଠ�������'}, ;
    {113411, 88, '���㠫쭠� �࠯��'}, ;
    {113412, 89, '���஫����'}, ;
    {113413, 90, '��쬮�������'}, ;
    {113414, 91, '�����⮫����'}, ;
    {113415, 92, '�࠭��㧨������'}, ;
    {113416, 93, '����ࠧ�㪮��� �������⨪�'}, ;
    {113417, 94, '������࠯��'}, ;
    {113418, 95, '�㭪樮���쭠� �������⨪�'}, ;
    {113419, 96, '����᪮���'}, ;
    {  1135, 11, '���᪠� ���ࣨ�'}, ;
    {113501, 41, '���᪠� ���������'}, ;
    {113502, 42, '���᪠� �஫����-���஫����'}, ;
    {113503, 43, '�����ப⮫����'}, ;
    {113504, 44, '�������ࣨ�'}, ;
    {113505, 45, '��थ筮-��㤨��� ���ࣨ�'}, ;
    {113506, 46, '��ࠪ��쭠� ���ࣨ�'}, ;
    {113507, 47, '�࠭��㧨������'}, ;
    {113508, 48, '����ࠧ�㪮��� �������⨪�'}, ;
    {113509, 49, '�㭪樮���쭠� �������⨪�'}, ;
    {113510, 50, '�����⭮-��楢�� ���ࣨ�'}, ;
    {113511, 51, '����᪮���'}, ;
    {  1136, 15, '�����⮫����'}, ;
    {    13,  2, '������-��䨫����᪮� ����'}, ;
    {  1301, 151, '������᪠� ������ୠ� �������⨪�'}, ;
    {130101, 155, '����ਮ�����'}, ;
    {130102, 156, '����᮫����'}, ;
    {130103, 157, '������ୠ� ����⨪�'}, ;
    {130104, 158, '������ୠ� ���������'}, ;
    {  1302, 154, '�������������'}, ;
    {130201, 167, '����ਮ�����'}, ;
    {130203, 169, '�����䥪⮫����'}, ;
    {130204, 170, '��ࠧ�⮫����'}, ;
    {130205, 168, '����᮫����'}, ;
    {  1303, 152, '���� �������'}, ;
    {130301, 159, '������� ��⥩ � �����⪮�'}, ;
    {130302, 162, '��������᪮� ��ᯨ⠭��'}, ;
    {130303, 160, '������� ��⠭��'}, ;
    {130304, 161, '������� ��㤠'}, ;
    {130305, 163, '����㭠�쭠� �������'}, ;
    {130306, 164, '�����樮���� �������'}, ;
    {130307, 165, '�����୮-��������᪨� �������� ��᫥�������'}, ;
    {  1306, 153, '��樠�쭠� ������� � �࣠������ ���ᠭ�����㦡�'}, ;
    {    14,  3, '�⮬�⮫����'}, ;
    {  1401, 171, '�⮬�⮫���� ��饩 �ࠪ⨪�'}, ;
    {140101, 173, '��⮤����'}, ;
    {140102, 174, '�⮬�⮫���� ���᪠�'}, ;
    {140103, 176, '�⮬�⮫���� �࠯����᪠�'}, ;
    {140104, 175, '�⮬�⮫���� ��⮯����᪠�'}, ;
    {140105, 177, '�⮬�⮫���� ���ࣨ�᪠�'}, ;
    {140106, 178, '�����⭮-��楢�� ���ࣨ�'}, ;
    {140107, 179, '������࠯��'}, ;
    {  1402, 172, '������᪠� ������ୠ� �������⨪�'}, ;
    {140201, 180, '����ਮ�����'}, ;
    {140202, 181, '����᮫����'}, ;
    {140203, 182, '������ୠ� ����⨪�'}, ;
    {140204, 183, '������ୠ� ���������'}, ;
    {    15,  4, '��ଠ��'}, ;
    {  1501, 184, '��ࠢ����� � ��������� �ଠ樨'}, ;
    {  1502, 229, '��ଠ楢��᪠� �孮�����'}, ;
    {  1503, 185, '��ଠ楢��᪠� 娬�� � �ଠ��������'}, ;
    {    16,  5, '����ਭ᪮� ����'}, ;
    {  1601, 186, '��ࠢ����� ���ਭ᪮� ���⥫쭮����'}, ;
    {    17,  6, '����樭᪠� ���娬��'}, ;
    {  1701, 187, '����⨪�'}, ;
    {170101, 188, '������ୠ� ����⨪�'}, ;
    {  1702, 189, '������᪠� ������ୠ� �������⨪�'}, ;
    {170201, 190, '����ਮ�����'}, ;
    {170202, 191, '����᮫����'}, ;
    {170203, 193, '������ୠ� ����⨪�'}, ;
    {170204, 192, '������ୠ� ���������'}, ;
    {  1703, 194, '�㤥���-����樭᪠� ��ᯥ�⨧�'}, ;
    {    18,  7, '����樭᪠� ���䨧���. ����樭᪠� ����୥⨪�'}, ;
    {  1801, 195, '������᪠� ������ୠ� �������⨪�'}, ;
    {180101, 197, '����ਮ�����'}, ;
    {180102, 198, '����᮫����'}, ;
    {180103, 199, '������ୠ� ����⨪�'}, ;
    {180104, 200, '������ୠ� ���������'}, ;
    {  1802, 196, '���⣥�������'}, ;
    {180201, 201, '����������'}, ;
    {180202, 202, '�㭪樮���쭠� �������⨪�'}, ;
    {180203, 203, '����ࠧ�㪮��� �������⨪�'}, ;
    {     2, 204, '�।��� ����樭᪮� � �ଠ楢��᪮� ��ࠧ������'}, ;
    {  2001, 205, '�࣠������ ���ਭ᪮�� ����'}, ;
    {  2002, 206, '��祡��� ����'}, ;
    {  2003, 207, '�����᪮� ����'}, ;
    {  2004, 208, '�⮬�⮫����'}, ;
    {  2005, 209, '�⮬�⮫���� ��⮯����᪠�'}, ;
    {  2006, 210, '������������� (��ࠧ�⮫����)'}, ;
    {  2007, 211, '������� � ᠭ����'}, ;
    {  2008, 212, '�����䥪樮���� ����'}, ;
    {  2009, 213, '��������᪮� ��ᯨ⠭��'}, ;
    {  2010, 214, '��⮬������'}, ;
    {  2011, 215, '������ୠ� �������⨪�'}, ;
    {  2012, 216, '���⮫����'}, ;
    {  2013, 217, '������୮� ����'}, ;
    {  2014, 218, '��ଠ��'}, ;
    {  2015, 219, '����ਭ᪮� ����'}, ;
    {  2016, 221, '����ਭ᪮� ���� � ������ਨ'}, ;
    {  2017, 222, '����樮���� ����'}, ;
    {  2018, 223, '����⥧������� � ॠ����⮫����'}, ;
    {  2019, 224, '���� �ࠪ⨪�'}, ;
    {  2020, 225, '���⣥�������'}, ;
    {  2021, 226, '�㭪樮���쭠� �������⨪�'}, ;
    {  2022, 227, '������࠯��'}, ;
    {  2023, 228, '����樭᪨� ���ᠦ'}, ;
    {  2024, 230, '��祡��� 䨧������'}, ;
    {  2025, 231, '���⮫����'}, ;
    {  2026, 232, '����樭᪠� ����⨪�'}, ;
    {  2027, 233, '�⮬�⮫���� ��䨫����᪠�'}, ;
    {  2028, 234, '�㤥���-����樭᪠� ��ᯥ�⨧�'}, ;
    {  2029, 235, '����樭᪠� ��⨪�'}, ;
    {     3, 287, '����⢥��� ��㪨'}, ;
    {    31, 288, '���䨧���'}, ;
    {  3101, 289, '����樭᪠� ���䨧���'}, ;
    {  3102, 290, '����樭᪠� ����୥⨪�'}, ;
    {    32, 3200, '���娬��'}, ;
    {  3201, 3201, '����樭᪠� ���娬��'};
    }
  endif

  return arr

** 24.11.22 ᮮ⢥��⢨� �ࠢ�筨�� V015 -> V004
function conversion_V015_V004()
  static arr

  if arr == nil
    arr := { ;
    { 1122, '������-�樠�쭠� ��ᯥ�⨧�', 236, 27}, ;
    { 1123, '������-�樠�쭠� ��ᯥ�⨧�', 237, 28}, ;
    { 1125, '������-�樠�쭠� ��ᯥ�⨧�', 238, 29}, ;
    { 1126, '������-�樠�쭠� ��ᯥ�⨧�', 239, 30}, ;
    { 1127, '������-�樠�쭠� ��ᯥ�⨧�', 240, 31}, ;
    { 1135, '������-�樠�쭠� ��ᯥ�⨧�', 241, 11}, ;
    { 1109, '������-�樠�쭠� ��ᯥ�⨧�', 242, 14}, ;
    { 1128, '������-�樠�쭠� ��ᯥ�⨧�', 243, 17}, ;
    { 1111, '������-�樠�쭠� ��ᯥ�⨧�', 244, 19}, ;
    { 1112, '������-�樠�쭠� ��ᯥ�⨧�', 245, 20}, ;
    { 1134, '������-�樠�쭠� ��ᯥ�⨧�', 246, 22}, ;
    { 1126, '������᪠� ���ࣨ�', 247, 30}, ;
    { 1126, '���⣥������������ �������⨪� � ��祭��', 248, 30}, ;
    { 112610, '����ࠧ�㪮��� �������⨪�', 249, 31}, ;
    { 110103, '���⣥������������ �������⨪� � ��祭��', 250, 8}, ;
    { 1101, '�࠭��㧨������', 251, 8}, ;
    { 1104, '��ᬥ⮫����', 252, 10}, ;
    { 113509, '���⣥������������ �������⨪� � ��祭��', 253, 11}, ;
    { 110906, '���⣥������������ �������⨪� � ��祭��', 254, 14}, ;
    { 112214, '����࣮����� � ���㭮�����', 255, 16}, ;
    { 112215, '���������� ����樭�', 256, 16}, ;
    { 112201, '��������஫����', 257, 16}, ;
    { 112202, '����⮫����', 258, 16}, ;
    { 112204, '���⮫����', 259, 16}, ;
    { 112205, '��न������', 260, 16}, ;
    { 112207, '���஫����', 261, 16}, ;
    { 112208, '��쬮�������', 262, 16}, ;
    { 112209, '�����⮫����', 263, 16}, ;
    { 112210, '�࠭��㧨������', 264, 16}, ;
    { 1118, '���⣥������������ �������⨪� � ��祭��', 265, 17}, ;
    { 1118, '���⣥������������ �������⨪� � ��祭��', 266, 24}, ;
    { 13, '�࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�', 267, 2}, ;
    { 14, '�࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�', 268, 3}, ;
    { 18, '����樭᪠� ����୥⨪�', 269, 0}, ;
    { 1801, '������᪠� ������ୠ� �������⨪�', 270, 269}, ;
    { 1802, '���⣥�������', 271, 269}, ;
    { 180101, '����ਮ�����', 272, 270}, ;
    { 180102, '����᮫����', 273, 270}, ;
    { 180103, '������ୠ� ����⨪�', 274, 270}, ;
    { 180104, '������ୠ� ���������', 275, 270}, ;
    { 180201, '����������', 276, 271}, ;
    { 180202, '�㭪樮���쭠� �������⨪�', 277, 271}, ;
    { 180203, '����ࠧ�㪮��� �������⨪�', 278, 271}, ;
    { 2019, '������-�樠�쭠� ������', 279, 204}, ;
    { 2015, '��મ�����', 280, 204}, ;
    { 2015, '��������樮���� ���ਭ᪮� ����', 281, 204}, ;
    { 2015, '����ਭ᪮� ���� � ��ᬥ⮫����', 282, 204}, ;
    { 2002, '����� � ���⫮���� ������', 283, 204}, ;
    { 2006, '����ਮ�����', 284, 204}, ;
    { 2022, '������࠯��', 286, 1};
    }
  endif
  
  return arr