#include "set.ch"
#include "function.ch"
#include "chip_mo.ch"

function initPZarray()
  local nameArray
  local i, sbase

  Public glob_array_PZ_18 := {;
    { 1,207,"��砩 ��ᯨ⠫���樨 ��� 18-01","���-01","�/�",""},;
    { 2,208,"��砩 ��ᯨ⠫���樨 ��� 18-02","���-02","�/�",""},;
    { 3,209,"��砩 ��ᯨ⠫���樨 ��� 18-03","���-03","�/�",""},;
    { 4,210,"��砩 ��ᯨ⠫���樨 ��� 18-04","���-04","�/�",""},;
    { 5,211,"��砩 ��ᯨ⠫���樨 ��� 18-05","���-05","�/�",""},;
    { 6,212,"��砩 ��ᯨ⠫���樨 ��� 18-06","���-06","�/�",""},;
    { 7,213,"��砩 ��ᯨ⠫���樨 ��� 18-07","���-07","�/�",""},;
    { 8,214,"��砩 ��ᯨ⠫���樨 ��� 18-08","���-08","�/�",""},;
    { 9,215,"��砩 ��ᯨ⠫���樨 ��� 18-09","���-09","�/�",""},;
    {10,216,"��砩 ��ᯨ⠫���樨 ��� 18-10","���-10","�/�",""},;
    {11,217,"��砩 ��ᯨ⠫���樨 ��� 18-11","���-11","�/�",""},;
    {12,218,"��砩 ��ᯨ⠫���樨 ��� 18-12","���-12","�/�",""},;
    {13,219,"��砩 ��ᯨ⠫���樨 ��� 18-13","���-13","�/�",""},;
    {14,220,"��砩 ��ᯨ⠫���樨 ��� 18-14","���-14","�/�",""},;
    {15,221,"��砩 ��ᯨ⠫���樨 ��� 18-15","���-15","�/�",""},;
    {16,222,"��砩 ��ᯨ⠫���樨 ��� 18-16","���-16","�/�",""},;
    {17,223,"��砩 ��ᯨ⠫���樨 ��� 18-17","���-17","�/�",""},;
    {18,224,"��砩 ��ᯨ⠫���樨 ��� 18-18","���-18","�/�",""},;
    {19,225,"��砩 ��ᯨ⠫���樨 ��� 18-19","���-19","�/�",""},;
    {20,226,"��砩 ��ᯨ⠫���樨 ��� 18-20","���-20","�/�",""},;
    {21,227,"��砩 ��ᯨ⠫���樨 ��� 18-21","���-21","�/�",""},;
    {22,228,"��砩 ��ᯨ⠫���樨 ��� 18-22","���-22","�/�",""},;
    {23,229,"��砩 ��ᯨ⠫���樨 ��� 18-23","���-23","�/�",""},;
    {24,230,"��砩 ��ᯨ⠫���樨 ��� 18-24","���-24","�/�",""},;
    {25,231,"��砩 ��ᯨ⠫���樨 ��� 18-25","���-25","�/�",""},;
    {26,232,"��砩 ��ᯨ⠫���樨 ��� 18-26","���-26","�/�",""},;
    {27,233,"��砩 ��ᯨ⠫���樨 ��� 18-27","���-27","�/�",""},;
    {28,234,"��砩 ��ᯨ⠫���樨 ��� 18-28","���-28","�/�",""},;
    {29,235,"��砩 ��ᯨ⠫���樨 ��� 18-29","���-29","�/�",""},;
    {30,236,"��砩 ��ᯨ⠫���樨 ��� 18-30","���-30","�/�",""},;
    {31,237,"��砩 ��ᯨ⠫���樨 ��� 18-31","���-31","�/�",""},;
    {32,238,"��砩 ��ᯨ⠫���樨 ��� 18-32","���-32","�/�",""},;
    {33,239,"��砩 ��ᯨ⠫���樨 ��� 18-33","���-33","�/�",""},;
    {34,240,"��砩 ��ᯨ⠫���樨 ��� 18-34","���-34","�/�",""},;
    {35,241,"��砩 ��ᯨ⠫���樨 ��� 18-35","���-35","�/�",""},;
    {36,242,"��砩 ��ᯨ⠫���樨 ��� 18-36","���-36","�/�",""},;
    {37,243,"��砩 ��ᯨ⠫���樨 ��� 18-37","���-37","�/�",""},;
    {38,244,"��砩 ��ᯨ⠫���樨 ��� 18-38","���-38","�/�",""},;
    {39,245,"��砩 ��ᯨ⠫���樨 ��� 18-39","���-39","�/�",""},;
    {40,246,"��砩 ��ᯨ⠫���樨 ��� 18-40","���-40","�/�",""},;
    {41,247,"��砩 ��ᯨ⠫���樨 ��� 18-41","���-41","�/�",""},;
    {42,248,"��砩 ��ᯨ⠫���樨 ��� 18-42","���-42","�/�",""},;
    {43,249,"��砩 ��ᯨ⠫���樨 ��� 18-43","���-43","�/�",""},;
    {44,250,"��砩 ��ᯨ⠫���樨 ��� 18-44","���-44","�/�",""},;
    {45,251,"��砩 ��ᯨ⠫���樨 ��� 18-45","���-45","�/�",""},;
    {46,252,"��砩 ��ᯨ⠫���樨 ��� 18-46","���-46","�/�",""},;
    {47,253,"��砩 ��ᯨ⠫���樨 ��� 18-47","���-47","�/�",""},;
    {48,254,"��砩 ��ᯨ⠫���樨 ��� 18-48","���-48","�/�",""},;
    {49,255,"��砩 ��ᯨ⠫���樨 ��� 18-49","���-49","�/�",""},;
    {50,256,"��砩 ��ᯨ⠫���樨 ��� 18-50","���-50","�/�",""},;
    {51,257,"��砩 ��ᯨ⠫���樨 ��� 18-51","���-51","�/�",""},;
    {52,258,"��砩 ��ᯨ⠫���樨 ��� 18-52","���-52","�/�",""},;
    {60, 26,"�맮� ���","�맮����","",{"71.*"}},; //
    {61, 29,"��砩 ��ᯨ⠫���樨","��烮ᯨ�","�/�",""},; //
    {62,142,"��砩 ��ᯨ⠫���樨 �� ॠ�����樨","��烮ᯐ���","�/�",""},; //
    {63,205,"���饭�� ��� ���","���.���","",""},;
    {64,206,"१��-䠪�� �����","�/� �����","",""},;
    {65,141,"��砩 ���","��砩���","",""},;
    {66,143,"��砩 ��祭��","��狥祭��","�/�",""},;
    {67,259,"��砩 �������","��焨�����","�/�",""},; //
    {68, 30,"���饭�� ��䨫����᪮�","�����䨫.","",{"2.79.*","2.81.*","2.88.*"},{"2.79.52","2.79.53","2.79.54","2.79.55","2.79.56","2.79.57","2.79.58","2.88.40","2.88.41","2.88.42","2.88.43","2.88.44","2.88.45"}},;
    {69, 31,"���饭�� ���⫮����","������⫮�.","",{"2.80.*","2.82.*"},{"2.80.29","2.80.30","2.80.31","2.80.32","2.80.33"}},;
    {70, 32,"���饭��","������饭.","",{"2.78.*","2.89.*"},{"2.78.47","2.78.48","2.78.49","2.78.50","2.78.51","2.78.52","2.78.53"}},;
    {71, 38,"���饭�� ��䨫����᪮� ����� ���஢��","����䖇","",{"2.76.*"}},;
    {72,260,"�������᭮� ���饭�� �� ��ᯠ��ਧ�樨","��ᄨᯠ��.","",""},; //
    {73,261,"�������᭮� ���饭�� �� ��� 1 �⠯","��� 1","",""},; //
    {74,262,"�������᭮� ���饭�� �� ��� 2 �⠯","��� 2","",""},; //
    {75,145,"���饭�� ��䨫����᪮� � �⮬�⮫����","�⮬���.","",""},;
    {76,146,"���饭�� ���⫮���� � �⮬�⮫����","�⮬����.","",""},;
    {77,147,"���饭�� � �⮬�⮫����","�⮬����.","",""},;
    {78, 33,"�-��᫥�������","�-��᫥�.","",{"60.2.*"}},;
    {79,153,"�७�⠫�� �ਭ���","�७��ਭ���","",{"4.15.746"}},;
    {80, 69,"������⭠� �⮫����","������⮫����","",{"4.20.702"}},;
    {81,148,"��᫥������� ���娬��᪮�","��᫁��娬.","",""},;
    {82,149,"��᫥������� ����⮫����᪮�","��᫃���⮫.","",""},;
    {83,150,"��᫥������� ����㫮���᪮�","��᫊����.","",""},;
    {84,151,"��᫥������� ���","��᫈��","",""},;
    {85,161,"��᫥������� ���஡�������᪮�","��ᫌ��஡���","",""},;
    {86,162,"��᫥������� ���","��᫏��","",""};
  }

  Public glob_array_PZ_19 := {;
    { 1,263,"��砩 ��ᯨ⠫���樨 ��� 19-01","���-01","�/�",""},;
    { 2,264,"��砩 ��ᯨ⠫���樨 ��� 19-02","���-02","�/�",""},;
    { 3,265,"��砩 ��ᯨ⠫���樨 ��� 19-03","���-03","�/�",""},;
    { 4,266,"��砩 ��ᯨ⠫���樨 ��� 19-04","���-04","�/�",""},;
    { 5,267,"��砩 ��ᯨ⠫���樨 ��� 19-05","���-05","�/�",""},;
    { 6,268,"��砩 ��ᯨ⠫���樨 ��� 19-06","���-06","�/�",""},;
    { 7,269,"��砩 ��ᯨ⠫���樨 ��� 19-07","���-07","�/�",""},;
    { 8,270,"��砩 ��ᯨ⠫���樨 ��� 19-08","���-08","�/�",""},;
    { 9,271,"��砩 ��ᯨ⠫���樨 ��� 19-09","���-09","�/�",""},;
    {10,272,"��砩 ��ᯨ⠫���樨 ��� 19-10","���-10","�/�",""},;
    {11,273,"��砩 ��ᯨ⠫���樨 ��� 19-11","���-11","�/�",""},;
    {12,274,"��砩 ��ᯨ⠫���樨 ��� 19-12","���-12","�/�",""},;
    {13,275,"��砩 ��ᯨ⠫���樨 ��� 19-13","���-13","�/�",""},;
    {14,276,"��砩 ��ᯨ⠫���樨 ��� 19-14","���-14","�/�",""},;
    {15,277,"��砩 ��ᯨ⠫���樨 ��� 19-15","���-15","�/�",""},;
    {16,278,"��砩 ��ᯨ⠫���樨 ��� 19-16","���-16","�/�",""},;
    {17,279,"��砩 ��ᯨ⠫���樨 ��� 19-17","���-17","�/�",""},;
    {18,280,"��砩 ��ᯨ⠫���樨 ��� 19-18","���-18","�/�",""},;
    {19,281,"��砩 ��ᯨ⠫���樨 ��� 19-19","���-19","�/�",""},;
    {20,282,"��砩 ��ᯨ⠫���樨 ��� 19-20","���-20","�/�",""},;
    {21,283,"��砩 ��ᯨ⠫���樨 ��� 19-21","���-21","�/�",""},;
    {22,284,"��砩 ��ᯨ⠫���樨 ��� 19-22","���-22","�/�",""},;
    {23,285,"��砩 ��ᯨ⠫���樨 ��� 19-23","���-23","�/�",""},;
    {24,286,"��砩 ��ᯨ⠫���樨 ��� 19-24","���-24","�/�",""},;
    {25,287,"��砩 ��ᯨ⠫���樨 ��� 19-25","���-25","�/�",""},;
    {26,288,"��砩 ��ᯨ⠫���樨 ��� 19-26","���-26","�/�",""},;
    {27,289,"��砩 ��ᯨ⠫���樨 ��� 19-27","���-27","�/�",""},;
    {28,290,"��砩 ��ᯨ⠫���樨 ��� 19-28","���-28","�/�",""},;
    {29,291,"��砩 ��ᯨ⠫���樨 ��� 19-29","���-29","�/�",""},;
    {30,292,"��砩 ��ᯨ⠫���樨 ��� 19-30","���-30","�/�",""},;
    {31,293,"��砩 ��ᯨ⠫���樨 ��� 19-31","���-31","�/�",""},;
    {32,294,"��砩 ��ᯨ⠫���樨 ��� 19-32","���-32","�/�",""},;
    {33,295,"��砩 ��ᯨ⠫���樨 ��� 19-33","���-33","�/�",""},;
    {34,296,"��砩 ��ᯨ⠫���樨 ��� 19-34","���-34","�/�",""},;
    {35,297,"��砩 ��ᯨ⠫���樨 ��� 19-35","���-35","�/�",""},;
    {36,298,"��砩 ��ᯨ⠫���樨 ��� 19-36","���-36","�/�",""},;
    {37,299,"��砩 ��ᯨ⠫���樨 ��� 19-37","���-37","�/�",""},;
    {38,300,"��砩 ��ᯨ⠫���樨 ��� 19-38","���-38","�/�",""},;
    {39,301,"��砩 ��ᯨ⠫���樨 ��� 19-39","���-39","�/�",""},;
    {40,302,"��砩 ��ᯨ⠫���樨 ��� 19-40","���-40","�/�",""},;
    {41,303,"��砩 ��ᯨ⠫���樨 ��� 19-41","���-41","�/�",""},;
    {42,304,"��砩 ��ᯨ⠫���樨 ��� 19-42","���-42","�/�",""},;
    {43,305,"��砩 ��ᯨ⠫���樨 ��� 19-43","���-43","�/�",""},;
    {44,306,"��砩 ��ᯨ⠫���樨 ��� 19-44","���-44","�/�",""},;
    {45,307,"��砩 ��ᯨ⠫���樨 ��� 19-45","���-45","�/�",""},;
    {46,308,"��砩 ��ᯨ⠫���樨 ��� 19-46","���-46","�/�",""},;
    {47,309,"��砩 ��ᯨ⠫���樨 ��� 19-47","���-47","�/�",""},;
    {48,310,"��砩 ��ᯨ⠫���樨 ��� 19-48","���-48","�/�",""},;
    {49,311,"��砩 ��ᯨ⠫���樨 ��� 19-49","���-49","�/�",""},;
    {50,312,"��砩 ��ᯨ⠫���樨 ��� 19-50","���-50","�/�",""},;
    {51,313,"��砩 ��ᯨ⠫���樨 ��� 19-51","���-51","�/�",""},;
    {52,314,"��砩 ��ᯨ⠫���樨 ��� 19-52","���-52","�/�",""},;
    {53,315,"��砩 ��ᯨ⠫���樨 ��� 19-53","���-53","�/�",""},;
    {54,316,"��砩 ��ᯨ⠫���樨 ��� 19-54","���-54","�/�",""},;
    {60, 26,"�맮� ���","�맮����","",""},; //
    {61, 29,"��砩 ��ᯨ⠫���樨","��烮ᯨ�","�/�",""},; //
    {62,142,"��砩 ��ᯨ⠫���樨 �� ॠ�����樨","��烮ᯐ���","�/�",""},; //
    {63,205,"���饭�� ��� ���","���.���","",""},;
    {64,206,"१��-䠪�� �����","�/� �����","",""},;
    {65,141,"��砩 ���","��砩���","",""},;
    {66,143,"��砩 ��祭��","��狥祭��","�/�",""},;
    {67,259,"��砩 �������","��焨�����","�/�",""},; //
    {68, 30,"���饭�� ��䨫����᪮�","�����䨫.","",""},;
    {69, 31,"���饭�� ���⫮����","������⫮�.","",""},;
    {70, 32,"���饭��","������饭.","",""},;
    {71, 38,"���饭�� ��䨫����᪮� ����� ���஢��","����䖇","",""},;
    {72,260,"�������᭮� ���饭�� �� ��ᯠ��ਧ�樨","��ᄨᯠ��.","",""},; //
    {73,261,"�������᭮� ���饭�� �� ��� 1 �⠯","��� 1","",""},; //
    {74,262,"�������᭮� ���饭�� �� ��� 2 �⠯","��� 2","",""},; //
    {75,145,"���饭�� ��䨫����᪮� � �⮬�⮫����","�⮬���.","",""},;
    {76,146,"���饭�� ���⫮���� � �⮬�⮫����","�⮬����.","",""},;
    {77,147,"���饭�� � �⮬�⮫����","�⮬����.","",""},;
    {78, 33,"�-��᫥�������","�-��᫥�.","",""},;
    {79,153,"�७�⠫�� �ਭ���","�७��ਭ���","",""},;
    {80, 69,"������⭠� �⮫����","������⮫����","",""},;
    {81,148,"��᫥������� ���娬��᪮�","��᫁��娬.","",""},;
    {82,149,"��᫥������� ����⮫����᪮�","��᫃���⮫.","",""},;
    {83,150,"��᫥������� ����㫮���᪮�","��᫊����.","",""},;
    {84,151,"��᫥������� ���","��᫈��","",""},;
    {85,161,"��᫥������� ���஡�������᪮�","��ᫌ��஡���","",""},;
    {86,162,"��᫥������� ���","��᫏��","",""},;
    {87,317,"���饭�� ��䨫����᪮� �� ��","��ᯍ��.","",""};
  }

  Public glob_array_PZ_20 := {;
    { 1,330,"��砩 ��ᯨ⠫���樨 ��� 20-01","���-01","�/�",""},;
    { 2,331,"��砩 ��ᯨ⠫���樨 ��� 20-02","���-02","�/�",""},;
    { 3,332,"��砩 ��ᯨ⠫���樨 ��� 20-03","���-03","�/�",""},;
    { 4,333,"��砩 ��ᯨ⠫���樨 ��� 20-04","���-04","�/�",""},;
    { 5,334,"��砩 ��ᯨ⠫���樨 ��� 20-05","���-05","�/�",""},;
    { 6,335,"��砩 ��ᯨ⠫���樨 ��� 20-06","���-06","�/�",""},;
    { 7,336,"��砩 ��ᯨ⠫���樨 ��� 20-07","���-07","�/�",""},;
    { 8,337,"��砩 ��ᯨ⠫���樨 ��� 20-08","���-08","�/�",""},;
    { 9,338,"��砩 ��ᯨ⠫���樨 ��� 20-09","���-09","�/�",""},;
    {10,339,"��砩 ��ᯨ⠫���樨 ��� 20-10","���-10","�/�",""},;
    {11,340,"��砩 ��ᯨ⠫���樨 ��� 20-11","���-11","�/�",""},;
    {12,341,"��砩 ��ᯨ⠫���樨 ��� 20-12","���-12","�/�",""},;
    {13,342,"��砩 ��ᯨ⠫���樨 ��� 20-13","���-13","�/�",""},;
    {14,343,"��砩 ��ᯨ⠫���樨 ��� 20-14","���-14","�/�",""},;
    {15,344,"��砩 ��ᯨ⠫���樨 ��� 20-15","���-15","�/�",""},;
    {16,345,"��砩 ��ᯨ⠫���樨 ��� 20-16","���-16","�/�",""},;
    {17,346,"��砩 ��ᯨ⠫���樨 ��� 20-17","���-17","�/�",""},;
    {18,347,"��砩 ��ᯨ⠫���樨 ��� 20-18","���-18","�/�",""},;
    {19,348,"��砩 ��ᯨ⠫���樨 ��� 20-19","���-19","�/�",""},;
    {20,349,"��砩 ��ᯨ⠫���樨 ��� 20-20","���-20","�/�",""},;
    {21,350,"��砩 ��ᯨ⠫���樨 ��� 20-21","���-21","�/�",""},;
    {22,351,"��砩 ��ᯨ⠫���樨 ��� 20-22","���-22","�/�",""},;
    {23,352,"��砩 ��ᯨ⠫���樨 ��� 20-23","���-23","�/�",""},;
    {24,353,"��砩 ��ᯨ⠫���樨 ��� 20-24","���-24","�/�",""},;
    {25,354,"��砩 ��ᯨ⠫���樨 ��� 20-25","���-25","�/�",""},;
    {26,355,"��砩 ��ᯨ⠫���樨 ��� 20-26","���-26","�/�",""},;
    {27,356,"��砩 ��ᯨ⠫���樨 ��� 20-27","���-27","�/�",""},;
    {28,357,"��砩 ��ᯨ⠫���樨 ��� 20-28","���-28","�/�",""},;
    {29,358,"��砩 ��ᯨ⠫���樨 ��� 20-29","���-29","�/�",""},;
    {30,359,"��砩 ��ᯨ⠫���樨 ��� 20-30","���-30","�/�",""},;
    {31,360,"��砩 ��ᯨ⠫���樨 ��� 20-31","���-31","�/�",""},;
    {32,361,"��砩 ��ᯨ⠫���樨 ��� 20-32","���-32","�/�",""},;
    {33,362,"��砩 ��ᯨ⠫���樨 ��� 20-33","���-33","�/�",""},;
    {34,363,"��砩 ��ᯨ⠫���樨 ��� 20-34","���-34","�/�",""},;
    {35,364,"��砩 ��ᯨ⠫���樨 ��� 20-35","���-35","�/�",""},;
    {36,365,"��砩 ��ᯨ⠫���樨 ��� 20-36","���-36","�/�",""},;
    {37,366,"��砩 ��ᯨ⠫���樨 ��� 20-37","���-37","�/�",""},;
    {38,367,"��砩 ��ᯨ⠫���樨 ��� 20-38","���-38","�/�",""},;
    {39,368,"��砩 ��ᯨ⠫���樨 ��� 20-39","���-39","�/�",""},;
    {40,369,"��砩 ��ᯨ⠫���樨 ��� 20-40","���-40","�/�",""},;
    {41,370,"��砩 ��ᯨ⠫���樨 ��� 20-41","���-41","�/�",""},;
    {42,371,"��砩 ��ᯨ⠫���樨 ��� 20-42","���-42","�/�",""},;
    {43,372,"��砩 ��ᯨ⠫���樨 ��� 20-43","���-43","�/�",""},;
    {44,373,"��砩 ��ᯨ⠫���樨 ��� 20-44","���-44","�/�",""},;
    {45,374,"��砩 ��ᯨ⠫���樨 ��� 20-45","���-45","�/�",""},;
    {46,375,"��砩 ��ᯨ⠫���樨 ��� 20-46","���-46","�/�",""},;
    {47,376,"��砩 ��ᯨ⠫���樨 ��� 20-47","���-47","�/�",""},;
    {48,377,"��砩 ��ᯨ⠫���樨 ��� 20-48","���-48","�/�",""},;
    {49,378,"��砩 ��ᯨ⠫���樨 ��� 20-49","���-49","�/�",""},;
    {50,379,"��砩 ��ᯨ⠫���樨 ��� 20-50","���-50","�/�",""},;
    {51,380,"��砩 ��ᯨ⠫���樨 ��� 20-51","���-51","�/�",""},;
    {52,381,"��砩 ��ᯨ⠫���樨 ��� 20-52","���-52","�/�",""},;
    {53,382,"��砩 ��ᯨ⠫���樨 ��� 20-53","���-53","�/�",""},;
    {54,383,"��砩 ��ᯨ⠫���樨 ��� 20-54","���-54","�/�",""},;
    {55,384,"��砩 ��ᯨ⠫���樨 ��� 20-55","���-55","�/�",""},;
    {56,385,"��砩 ��ᯨ⠫���樨 ��� 20-56","���-56","�/�",""},;
    {57,386,"��砩 ��ᯨ⠫���樨 ��� 20-57","���-57","�/�",""},;
    {60, 26,"�맮� ���","�맮����","",""},; //
    {61, 29,"��砩 ��ᯨ⠫���樨","��烮ᯨ�","�/�",""},; //
    {62,142,"��砩 ��ᯨ⠫���樨 �� ॠ�����樨","��烮ᯐ���","�/�",""},; //
    {63,205,"���饭�� ��� ���","���.���","",""},;
    {64,206,"१��-䠪�� �����","�/� �����","",""},;  //   {65,141,"��砩 ���","��砩���","",""},;
    {66,143,"��砩 ��祭��","��狥祭��","�/�",""},;
    {67,259,"��砩 �������","��焨�����","�/�",""},; //
    {68, 30,"���饭�� ��䨫����᪮�","�����䨫.","",""},;
    {69, 31,"���饭�� ���⫮����","������⫮�.","",""},;
    {70, 32,"���饭��","������饭.","",""},;
    {71, 38,"���饭�� ��䨫����᪮� ����� ���஢��","����䖇","",""},; // {72,260,"�������᭮� ���饭�� �� ��ᯠ��ਧ�樨","��ᄨᯠ��.","",""},; //
    {73,261,"�������᭮� ���饭�� �� ��� 1 �⠯","��� 1","",""},; //
    {74,262,"�������᭮� ���饭�� �� ��� 2 �⠯","��� 2","",""},; //
    {75,145,"���饭�� ��䨫����᪮� � �⮬�⮫����","�⮬���.","",""},;
    {76,146,"���饭�� ���⫮���� � �⮬�⮫����","�⮬����.","",""},;
    {77,147,"���饭�� � �⮬�⮫����","�⮬����.","",""},;
    {79,153,"�७�⠫�� �ਭ���","�७��ਭ���","",""},;
    {80, 69,"������⭠� �⮫����","������⮫����","",""},;
    {81,148,"��᫥������� ���娬��᪮�","��᫁��娬.","",""},;
    {82,149,"��᫥������� ����⮫����᪮�","��᫃���⮫.","",""},;
    {83,150,"��᫥������� ����㫮���᪮�","��᫊����.","",""},;
    {84,151,"��᫥������� ���","��᫈��","",""},;
    {85,161,"��᫥������� ���஡�������᪮�","��ᫌ��஡���","",""},;
    {86,162,"��᫥������� ���","��᫏��","",""},;  //  {87,317,"���饭�� ��䨫����᪮� �� ��","��ᯍ��.","",""};
    {87,318,"�������᭮� ���饭�� �� ����","����","",""},;
    {88,319,"�������᭮� ���饭�� �� ���","���","",""},;
    {89,320,"�������᭮� ���饭�� �� ���","���","",""},;
    {90,321,"�������᭮� ���饭�� �� ���","���","",""},;
    {91,322,"���饭�� � ����","��������","",""},;
    {92,323,"���饭�� ��� ॠ�����樨","ॠ�����","",""},;
    {93,324,"��","��","",""},;
    {94,325,"���","���","",""},;
    {95,326,"��� ���","��� ���","",""},;
    {96,327,"����᪮���","����᪮���","",""},;
    {97,328,"���⮫����","���⮫����","",""},;
    {98,329,"���","���","",""},;
    {99,387,"��᫥������� ���","��᫥������� ���","",""};
  }

  Public glob_array_PZ_21 := {;
  { 1,389,"��砩 ��ᯨ⠫���樨 ��� 21-01","���-01","�/�",""},;
  { 2,390,"��砩 ��ᯨ⠫���樨 ��� 21-02","���-02","�/�",""},;
  { 3,391,"��砩 ��ᯨ⠫���樨 ��� 21-03","���-03","�/�",""},;
  { 4,392,"��砩 ��ᯨ⠫���樨 ��� 21-04","���-04","�/�",""},;
  { 5,393,"��砩 ��ᯨ⠫���樨 ��� 21-05","���-05","�/�",""},;
  { 6,394,"��砩 ��ᯨ⠫���樨 ��� 21-06","���-06","�/�",""},;
  { 7,395,"��砩 ��ᯨ⠫���樨 ��� 21-07","���-07","�/�",""},;
  { 8,396,"��砩 ��ᯨ⠫���樨 ��� 21-08","���-08","�/�",""},;
  { 9,397,"��砩 ��ᯨ⠫���樨 ��� 21-09","���-09","�/�",""},;
  {10,398,"��砩 ��ᯨ⠫���樨 ��� 21-10","���-10","�/�",""},;
  {11,399,"��砩 ��ᯨ⠫���樨 ��� 21-11","���-11","�/�",""},;
  {12,400,"��砩 ��ᯨ⠫���樨 ��� 21-12","���-12","�/�",""},;
  {13,401,"��砩 ��ᯨ⠫���樨 ��� 21-13","���-13","�/�",""},;
  {14,402,"��砩 ��ᯨ⠫���樨 ��� 21-14","���-14","�/�",""},;
  {15,403,"��砩 ��ᯨ⠫���樨 ��� 21-15","���-15","�/�",""},;
  {16,404,"��砩 ��ᯨ⠫���樨 ��� 21-16","���-16","�/�",""},;
  {17,405,"��砩 ��ᯨ⠫���樨 ��� 21-17","���-17","�/�",""},;
  {18,406,"��砩 ��ᯨ⠫���樨 ��� 21-18","���-18","�/�",""},;
  {19,407,"��砩 ��ᯨ⠫���樨 ��� 21-19","���-19","�/�",""},;
  {20,408,"��砩 ��ᯨ⠫���樨 ��� 21-20","���-20","�/�",""},;
  {21,409,"��砩 ��ᯨ⠫���樨 ��� 21-21","���-21","�/�",""},;
  {22,410,"��砩 ��ᯨ⠫���樨 ��� 21-22","���-22","�/�",""},;
  {23,411,"��砩 ��ᯨ⠫���樨 ��� 21-23","���-23","�/�",""},;
  {24,412,"��砩 ��ᯨ⠫���樨 ��� 21-24","���-24","�/�",""},;
  {25,413,"��砩 ��ᯨ⠫���樨 ��� 21-25","���-25","�/�",""},;
  {26,414,"��砩 ��ᯨ⠫���樨 ��� 21-26","���-26","�/�",""},;
  {27,415,"��砩 ��ᯨ⠫���樨 ��� 21-27","���-27","�/�",""},;
  {28,416,"��砩 ��ᯨ⠫���樨 ��� 21-28","���-28","�/�",""},;
  {29,417,"��砩 ��ᯨ⠫���樨 ��� 21-29","���-29","�/�",""},;
  {30,418,"��砩 ��ᯨ⠫���樨 ��� 21-30","���-30","�/�",""},;
  {31,419,"��砩 ��ᯨ⠫���樨 ��� 21-31","���-31","�/�",""},;
  {32,420,"��砩 ��ᯨ⠫���樨 ��� 21-32","���-32","�/�",""},;
  {33,421,"��砩 ��ᯨ⠫���樨 ��� 21-33","���-33","�/�",""},;
  {34,422,"��砩 ��ᯨ⠫���樨 ��� 21-34","���-34","�/�",""},;
  {35,423,"��砩 ��ᯨ⠫���樨 ��� 21-35","���-35","�/�",""},;
  {36,424,"��砩 ��ᯨ⠫���樨 ��� 21-36","���-36","�/�",""},;
  {37,425,"��砩 ��ᯨ⠫���樨 ��� 21-37","���-37","�/�",""},;
  {38,426,"��砩 ��ᯨ⠫���樨 ��� 21-38","���-38","�/�",""},;
  {39,427,"��砩 ��ᯨ⠫���樨 ��� 21-39","���-39","�/�",""},;
  {40,428,"��砩 ��ᯨ⠫���樨 ��� 21-40","���-40","�/�",""},;
  {41,429,"��砩 ��ᯨ⠫���樨 ��� 21-41","���-41","�/�",""},;
  {42,430,"��砩 ��ᯨ⠫���樨 ��� 21-42","���-42","�/�",""},;
  {43,431,"��砩 ��ᯨ⠫���樨 ��� 21-43","���-43","�/�",""},;
  {44,432,"��砩 ��ᯨ⠫���樨 ��� 21-44","���-44","�/�",""},;
  {45,433,"��砩 ��ᯨ⠫���樨 ��� 21-45","���-45","�/�",""},;
  {46,434,"��砩 ��ᯨ⠫���樨 ��� 21-46","���-46","�/�",""},;
  {47,435,"��砩 ��ᯨ⠫���樨 ��� 21-47","���-47","�/�",""},;
  {48,436,"��砩 ��ᯨ⠫���樨 ��� 21-48","���-48","�/�",""},;
  {49,437,"��砩 ��ᯨ⠫���樨 ��� 21-49","���-49","�/�",""},;
  {50,438,"��砩 ��ᯨ⠫���樨 ��� 21-50","���-50","�/�",""},;
  {51,439,"��砩 ��ᯨ⠫���樨 ��� 21-51","���-51","�/�",""},;
  {52,440,"��砩 ��ᯨ⠫���樨 ��� 21-52","���-52","�/�",""},;
  {53,441,"��砩 ��ᯨ⠫���樨 ��� 21-53","���-53","�/�",""},;
  {54,442,"��砩 ��ᯨ⠫���樨 ��� 21-54","���-54","�/�",""},;
  {55,443,"��砩 ��ᯨ⠫���樨 ��� 21-55","���-55","�/�",""},;
  {56,444,"��砩 ��ᯨ⠫���樨 ��� 21-56","���-56","�/�",""},;
  {57,445,"��砩 ��ᯨ⠫���樨 ��� 21-57","���-57","�/�",""},;
  {58,446,"��砩 ��ᯨ⠫���樨 ��� 21-58","���-58","�/�",""},;  // �����
  {59,447,"�� 1 �⠯","�� 1","",""},;  // ����� 21.10.21
  {60, 26,"�맮� ���","�맮����","",""},;                        // 1
  {61, 29,"��砩 ��ᯨ⠫���樨","��烮ᯨ�","�/�",""},;       // 1
  {62,142,"��砩 ��ᯨ⠫���樨 �� ॠ�����樨","��烮ᯐ���","�/�",""},; //1
  {63,205,"���饭�� ��� ���","���.���","",""},;   // 1
  {64,206,"१��-䠪�� �����","�/� �����","",""},;  // 1   {65,141,"��砩 ���","��砩���","",""},;
  {65,388,"��᫥������� �� COVID-19","COVID-19","",""},;   //  �����
  {66,143,"��砩 ��祭��","��狥祭��","�/�",""},;  // 1
  {67,259,"��砩 �������","��焨�����","�/�",""},; //  1
  {68, 30,"���饭�� ��䨫����᪮�","�����䨫.","",""},;  // 1
  {69, 31,"���饭�� ���⫮����","������⫮�.","",""},;       // 1
  {70, 32,"���饭��","������饭.","",""},;                  // 1
  {71, 38,"���饭�� ��䨫����᪮� ����� ���஢��","����䖇","",""},; //1 // {72,260,"�������᭮� ���饭�� �� ��ᯠ��ਧ�樨","��ᄨᯠ��.","",""},; //
  {72,448,"�� 2 �⠯","�� 2","",""},; // ����� 21.10.21
  {73,261,"�������᭮� ���饭�� �� ��� 1 �⠯","��� 1","",""},; //  1
  {74,262,"�������᭮� ���饭�� �� ��� 2 �⠯","��� 2","",""},; //  1
  {75,145,"���饭�� ��䨫����᪮� � �⮬�⮫����","�⮬���.","",""},; // 1
  {76,146,"���饭�� ���⫮���� � �⮬�⮫����","�⮬����.","",""},;      // 1
  {77,147,"���饭�� � �⮬�⮫����","�⮬����.","",""},;                 // 1
  {78,449,"�� (������� �࠭���)","KT","",""},; // ����� 21.10.21
  {79,153,"�७�⠫�� �ਭ���","�७��ਭ���","",""},;                  // 1
  {80, 69,"������⭠� �⮫����","������⮫����","",""},;                  // 1
  {81,148,"��᫥������� ���娬��᪮�","��᫁��娬.","",""},;              // 1
  {82,149,"��᫥������� ����⮫����᪮�","��᫃���⮫.","",""},;          // 1
  {83,150,"��᫥������� ����㫮���᪮�","��᫊����.","",""},;            // 1
  {84,151,"��᫥������� ���","��᫈��","",""},;                            // 1
  {85,161,"��᫥������� ���஡�������᪮�","��ᫌ��஡���","",""},;       // 1
  {86,162,"��᫥������� ���","��᫏��","",""},;  // 1 //  {87,317,"���饭�� ��䨫����᪮� �� ��","��ᯍ��.","",""};
  {87,318,"�������᭮� ���饭�� �� ����","����","",""},;   //  1
  {88,319,"�������᭮� ���饭�� �� ���","���","",""},;     //  1
  {89,320,"�������᭮� ���饭�� �� ���","���","",""},;     //  1
  {90,321,"�������᭮� ���饭�� �� ���","���","",""},;     //  1
  {91,322,"���饭�� � ����","��������","",""},;            //  1
  {92,323,"���饭�� ��� ॠ�����樨","ॠ�����","",""},;  //  1
  {93,324,"��","��","",""},;                                 //  1
  {94,325,"���","���","",""},;                               //  1
  {95,326,"��� ���","��� ���","",""},;                       //  1
  {96,327,"����᪮���","����᪮���","",""},;                 //  1
  {97,328,"���⮫����","���⮫����","",""},;                 //  1
  {98,329,"���","���","",""},;                               //  1
  {99,387,"��᫥������� ���","��᫥������� ���","",""};      //  1
  }

  Public glob_array_PZ_22 := {;
  { 1,389,"��砩 ��ᯨ⠫���樨 ��� 21-01","���-01","�/�",""},;
  { 2,390,"��砩 ��ᯨ⠫���樨 ��� 21-02","���-02","�/�",""},;
  { 3,391,"��砩 ��ᯨ⠫���樨 ��� 21-03","���-03","�/�",""},;
  { 4,392,"��砩 ��ᯨ⠫���樨 ��� 21-04","���-04","�/�",""},;
  { 5,393,"��砩 ��ᯨ⠫���樨 ��� 21-05","���-05","�/�",""},;
  { 6,394,"��砩 ��ᯨ⠫���樨 ��� 21-06","���-06","�/�",""},;
  { 7,395,"��砩 ��ᯨ⠫���樨 ��� 21-07","���-07","�/�",""},;
  { 8,396,"��砩 ��ᯨ⠫���樨 ��� 21-08","���-08","�/�",""},;
  { 9,397,"��砩 ��ᯨ⠫���樨 ��� 21-09","���-09","�/�",""},;
  {10,398,"��砩 ��ᯨ⠫���樨 ��� 21-10","���-10","�/�",""},;
  {11,399,"��砩 ��ᯨ⠫���樨 ��� 21-11","���-11","�/�",""},;
  {12,400,"��砩 ��ᯨ⠫���樨 ��� 21-12","���-12","�/�",""},;
  {13,401,"��砩 ��ᯨ⠫���樨 ��� 21-13","���-13","�/�",""},;
  {14,402,"��砩 ��ᯨ⠫���樨 ��� 21-14","���-14","�/�",""},;
  {15,403,"��砩 ��ᯨ⠫���樨 ��� 21-15","���-15","�/�",""},;
  {16,404,"��砩 ��ᯨ⠫���樨 ��� 21-16","���-16","�/�",""},;
  {17,405,"��砩 ��ᯨ⠫���樨 ��� 21-17","���-17","�/�",""},;
  {18,406,"��砩 ��ᯨ⠫���樨 ��� 21-18","���-18","�/�",""},;
  {19,407,"��砩 ��ᯨ⠫���樨 ��� 21-19","���-19","�/�",""},;
  {20,408,"��砩 ��ᯨ⠫���樨 ��� 21-20","���-20","�/�",""},;
  {21,409,"��砩 ��ᯨ⠫���樨 ��� 21-21","���-21","�/�",""},;
  {22,410,"��砩 ��ᯨ⠫���樨 ��� 21-22","���-22","�/�",""},;
  {23,411,"��砩 ��ᯨ⠫���樨 ��� 21-23","���-23","�/�",""},;
  {24,412,"��砩 ��ᯨ⠫���樨 ��� 21-24","���-24","�/�",""},;
  {25,413,"��砩 ��ᯨ⠫���樨 ��� 21-25","���-25","�/�",""},;
  {26,414,"��砩 ��ᯨ⠫���樨 ��� 21-26","���-26","�/�",""},;
  {27,415,"��砩 ��ᯨ⠫���樨 ��� 21-27","���-27","�/�",""},;
  {28,416,"��砩 ��ᯨ⠫���樨 ��� 21-28","���-28","�/�",""},;
  {29,417,"��砩 ��ᯨ⠫���樨 ��� 21-29","���-29","�/�",""},;
  {30,418,"��砩 ��ᯨ⠫���樨 ��� 21-30","���-30","�/�",""},;
  {31,419,"��砩 ��ᯨ⠫���樨 ��� 21-31","���-31","�/�",""},;
  {32,420,"��砩 ��ᯨ⠫���樨 ��� 21-32","���-32","�/�",""},;
  {33,421,"��砩 ��ᯨ⠫���樨 ��� 21-33","���-33","�/�",""},;
  {34,422,"��砩 ��ᯨ⠫���樨 ��� 21-34","���-34","�/�",""},;
  {35,423,"��砩 ��ᯨ⠫���樨 ��� 21-35","���-35","�/�",""},;
  {36,424,"��砩 ��ᯨ⠫���樨 ��� 21-36","���-36","�/�",""},;
  {37,425,"��砩 ��ᯨ⠫���樨 ��� 21-37","���-37","�/�",""},;
  {38,426,"��砩 ��ᯨ⠫���樨 ��� 21-38","���-38","�/�",""},;
  {39,427,"��砩 ��ᯨ⠫���樨 ��� 21-39","���-39","�/�",""},;
  {40,428,"��砩 ��ᯨ⠫���樨 ��� 21-40","���-40","�/�",""},;
  {41,429,"��砩 ��ᯨ⠫���樨 ��� 21-41","���-41","�/�",""},;
  {42,430,"��砩 ��ᯨ⠫���樨 ��� 21-42","���-42","�/�",""},;
  {43,431,"��砩 ��ᯨ⠫���樨 ��� 21-43","���-43","�/�",""},;
  {44,432,"��砩 ��ᯨ⠫���樨 ��� 21-44","���-44","�/�",""},;
  {45,433,"��砩 ��ᯨ⠫���樨 ��� 21-45","���-45","�/�",""},;
  {46,434,"��砩 ��ᯨ⠫���樨 ��� 21-46","���-46","�/�",""},;
  {47,435,"��砩 ��ᯨ⠫���樨 ��� 21-47","���-47","�/�",""},;
  {48,436,"��砩 ��ᯨ⠫���樨 ��� 21-48","���-48","�/�",""},;
  {49,437,"��砩 ��ᯨ⠫���樨 ��� 21-49","���-49","�/�",""},;
  {50,438,"��砩 ��ᯨ⠫���樨 ��� 21-50","���-50","�/�",""},;
  {51,439,"��砩 ��ᯨ⠫���樨 ��� 21-51","���-51","�/�",""},;
  {52,440,"��砩 ��ᯨ⠫���樨 ��� 21-52","���-52","�/�",""},;
  {53,441,"��砩 ��ᯨ⠫���樨 ��� 21-53","���-53","�/�",""},;
  {54,442,"��砩 ��ᯨ⠫���樨 ��� 21-54","���-54","�/�",""},;
  {55,443,"��砩 ��ᯨ⠫���樨 ��� 21-55","���-55","�/�",""},;
  {56,444,"��砩 ��ᯨ⠫���樨 ��� 21-56","���-56","�/�",""},;
  {57,445,"��砩 ��ᯨ⠫���樨 ��� 21-57","���-57","�/�",""},;
  {58,446,"��砩 ��ᯨ⠫���樨 ��� 21-58","���-58","�/�",""},;  //
  {59,447,"�� 1 �⠯","�� 1","",""},;  // 
  {60, 26,"�맮� ���","�맮����","",""},;                        // 1
  {61, 29,"��砩 ��ᯨ⠫���樨","��烮ᯨ�","�/�",""},;       // 1
  {62,142,"��砩 ��ᯨ⠫���樨 �� ॠ�����樨","��烮ᯐ���","�/�",""},; //1
  {63,205,"���饭�� ��� ���","���.���","",""},;   // 1
  {64,206,"१��-䠪�� �����","�/� �����","",""},;  // 1
  {65,388,"��᫥������� �� COVID-19","COVID-19","",""},;   // 
  {66,143,"��砩 ��祭��","��狥祭��","�/�",""},;  // 1
  {67,259,"��砩 �������","��焨�����","�/�",""},; //  1
  {68, 30,"���饭�� ��䨫����᪮�","�����䨫.","",""},;  // 1
  {69, 31,"���饭�� ���⫮����","������⫮�.","",""},;       // 1
  {70, 32,"���饭��","������饭.","",""},;                  // 1
  {71, 38,"���饭�� ��䨫����᪮� ����� ���஢��","����䖇","",""},; //1 
  {72,448,"�� 2 �⠯","�� 2","",""},; // 
  {73,261,"�������᭮� ���饭�� �� ��� 1 �⠯","��� 1","",""},; //  1
  {74,262,"�������᭮� ���饭�� �� ��� 2 �⠯","��� 2","",""},; //  1
  {75,145,"���饭�� ��䨫����᪮� � �⮬�⮫����","�⮬���.","",""},; // 1
  {76,146,"���饭�� ���⫮���� � �⮬�⮫����","�⮬����.","",""},;      // 1
  {77,147,"���饭�� � �⮬�⮫����","�⮬����.","",""},;                 // 1
  {78,449,"�� (������� �࠭���)","KT","",""},; //
  {79,153,"�७�⠫�� �ਭ���","�७��ਭ���","",""},;                  // 1
  {80, 69,"������⭠� �⮫����","������⮫����","",""},;                  // 1
  {81,148,"��᫥������� ���娬��᪮�","��᫁��娬.","",""},;              // 1
  {82,149,"��᫥������� ����⮫����᪮�","��᫃���⮫.","",""},;          // 1
  {83,150,"��᫥������� ����㫮���᪮�","��᫊����.","",""},;            // 1
  {84,151,"��᫥������� ���","��᫈��","",""},;                            // 1
  {85,161,"��᫥������� ���஡�������᪮�","��ᫌ��஡���","",""},;       // 1
  {86,162,"��᫥������� ���","��᫏��","",""},;  // 
  {87,318,"�������᭮� ���饭�� �� ����","����","",""},;   //  1
  {88,319,"�������᭮� ���饭�� �� ���","���","",""},;     //  1
  {89,320,"�������᭮� ���饭�� �� ���","���","",""},;     //  1
  {90,321,"�������᭮� ���饭�� �� ���","���","",""},;     //  1
  {91,322,"���饭�� � ����","��������","",""},;            //  1
  {92,323,"���饭�� ��� ॠ�����樨","ॠ�����","",""},;  //  1
  {93,324,"��","��","",""},;                                 //  1
  {94,325,"���","���","",""},;                               //  1
  {95,326,"��� ���","��� ���","",""},;                       //  1
  {96,327,"����᪮���","����᪮���","",""},;                 //  1
  {97,328,"���⮫����","���⮫����","",""},;                 //  1
  {98,329,"���","���","",""},;                               //  1
  {99,387,"��᫥������� ���","��᫥������� ���","",""};      //  1
  }

  sbase :=  prefixFileRefName(WORK_YEAR) + 'unit'  // �ࠢ�筨� �� ������� ���
  
  G_Use(exe_dir + sbase, cur_dir + sbase, 'UNIT')
  for i := 1 to len(glob_array_PZ_21)
    find (str(glob_array_PZ_21[i,2],3))
    if found() .and. !(unit->pz == glob_array_PZ_21[i,1] .and. unit->ii == i)
      G_RLock(forever)
      unit->pz := glob_array_PZ_21[i,1]
      unit->ii := i
    endif
  next
  unit->(dbCloseArea())
return nil