#include 'inkey.ch'
#include '..\function.ch'
#include 'common.ch'
#include '..\edit_spr.ch'

#include 'tbox.ch'

static strCompanies := '���������� ����������� ����������'

* 25.12.20 ������ ���ᨢ ॣ����� �� �ࠢ�筨�� ॣ����� ����� F010.xml
function f010()
    // F010.xml - �����䨪��� ��ꥪ⮢ ���ᨩ᪮� �����樨
    //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)
    local _f010 := {}
    aadd(_f010, {"���㡫��� ��룥�",1,2})
    aadd(_f010, {"���㡫��� ��誮���⠭",2,7})
    aadd(_f010, {"���㡫��� ������",3,5})
    aadd(_f010, {"���㡫��� ��⠩",4,5})
    aadd(_f010, {"���㡫��� �����⠭",5,8})
    aadd(_f010, {"���㡫��� �������",6,8})
    aadd(_f010, {"����न��-������᪠� ���㡫���",7,8})
    aadd(_f010, {"���㡫��� ����모�",8,2})
    aadd(_f010, {"���砥��-��થ�᪠� ���㡫���",9,8})
    aadd(_f010, {"���㡫��� ��५��",10,3})
    aadd(_f010, {"���㡫��� ����",11,3})
    aadd(_f010, {"���㡫��� ��਩ ��",12,7})
    aadd(_f010, {"���㡫��� ��म���",13,7})
    aadd(_f010, {"���㡫��� ��� (�����)",14,4})
    aadd(_f010, {"���㡫��� ����ୠ� ����-������",15,8})
    aadd(_f010, {"���㡫��� �����⠭",16,7})
    aadd(_f010, {"���㡫��� �뢠",17,5})
    aadd(_f010, {"������᪠� ���㡫���",18,7})
    aadd(_f010, {"���㡫��� ������",19,5})
    aadd(_f010, {"��祭᪠� ���㡫���",20,8})
    aadd(_f010, {"�㢠�᪠� ���㡫���",21,7})
    aadd(_f010, {"��⠩᪨� �ࠩ",22,5})
    aadd(_f010, {"��᭮���᪨� �ࠩ",23,2})
    aadd(_f010, {"��᭮��᪨� �ࠩ",24,5})
    aadd(_f010, {"�ਬ��᪨� �ࠩ",25,4})
    aadd(_f010, {"�⠢ய���᪨� �ࠩ",26,8})
    aadd(_f010, {"����஢᪨� �ࠩ",27,4})
    aadd(_f010, {"����᪠� �������",28,4})
    aadd(_f010, {"��堭����᪠� �������",29,3})
    aadd(_f010, {"����堭᪠� �������",30,2})
    aadd(_f010, {"�����த᪠� �������",31,1})
    aadd(_f010, {"���᪠� �������",32,1})
    aadd(_f010, {"��������᪠� �������",33,1})
    aadd(_f010, {"������ࠤ᪠� �������",34,2})
    aadd(_f010, {"�������᪠� �������",35,3})
    aadd(_f010, {"��஭��᪠� �������",36,1})
    aadd(_f010, {"������᪠� �������",37,1})
    aadd(_f010, {"����᪠� �������",38,5})
    aadd(_f010, {"��������ࠤ᪠� �������",39,3})
    aadd(_f010, {"����᪠� �������",40,1})
    aadd(_f010, {"�����᪨� �ࠩ",41,4})
    aadd(_f010, {"����஢᪠� �������",42,5})
    aadd(_f010, {"��஢᪠� �������",43,7})
    aadd(_f010, {"����஬᪠� �������",44,1})
    aadd(_f010, {"��࣠�᪠� �������",45,6})
    aadd(_f010, {"���᪠� �������",46,1})
    aadd(_f010, {"������ࠤ᪠� �������",47,3})
    aadd(_f010, {"����檠� �������",48,1})
    aadd(_f010, {"�������᪠� �������",49,4})
    aadd(_f010, {"��᪮�᪠� �������",50,1})
    aadd(_f010, {"��ଠ�᪠� �������",51,3})
    aadd(_f010, {"������த᪠� �������",52,7})
    aadd(_f010, {"�����த᪠� �������",53,3})
    aadd(_f010, {"����ᨡ��᪠� �������",54,5})
    aadd(_f010, {"��᪠� �������",55,5})
    aadd(_f010, {"�७���᪠� �������",56,7})
    aadd(_f010, {"�૮�᪠� �������",57,1})
    aadd(_f010, {"������᪠� �������",58,7})
    aadd(_f010, {"���᪨� �ࠩ",59,7})
    aadd(_f010, {"�᪮�᪠� �������",60,3})
    aadd(_f010, {"���⮢᪠� �������",61,2})
    aadd(_f010, {"�易�᪠� �������",62,1})
    aadd(_f010, {"�����᪠� �������",63,7})
    aadd(_f010, {"���⮢᪠� �������",64,7})
    aadd(_f010, {"��堫��᪠� �������",65,4})
    aadd(_f010, {"���फ��᪠� �������",66,6})
    aadd(_f010, {"������᪠� �������",67,1})
    aadd(_f010, {"������᪠� �������",68,1})
    aadd(_f010, {"����᪠� �������",69,1})
    aadd(_f010, {"���᪠� �������",70,5})
    aadd(_f010, {"���᪠� �������",71,1})
    aadd(_f010, {"��᪠� �������",72,6})
    aadd(_f010, {"���ﭮ�᪠� �������",73,7})
    aadd(_f010, {"����᪠� �������",74,6})
    aadd(_f010, {"���������᪨� �ࠩ",75,5})
    aadd(_f010, {"��᫠�᪠� �������",76,1})
    aadd(_f010, {"�. ��᪢�",77,1})
    aadd(_f010, {"�. �����-������",78,3})
    aadd(_f010, {"��३᪠� ��",79,4})
    aadd(_f010, {"����檨� ��",80,3})
    aadd(_f010, {"�����-���ᨩ᪨� ��",81,6})
    aadd(_f010, {"�㪮�᪨� ��",82,4})
    aadd(_f010, {"�����-����檨� ��",83,6})
    aadd(_f010, {"�. ��������",84,0})
    aadd(_f010, {"���㡫��� ���",85,3})
    aadd(_f010, {"�. �����⮯���",86,3})

    return _f010

* 14.01.21
Function viewF003()
    local nTop, nLeft, nBottom, nRight
    local l := 0, nChoice
    Local ar
	local color_say := 'N/W', color_get := 'W/N*'
    local oBox, oBoxRegion
    local strRegion := "�롮� ॣ����" 
    local ar_f010 := f010()

    ar := {}
    for i := 1 to len(ar_f010)
      aadd(ar, ar_f010[i,1])
      l := max(l,len(ar[i]))
    next

    // ������� ����
    oBox := TBox():New( 2, 10, 22, 70, .t. )
    oBox:Caption := '�롮� ���ࠢ��襩 �࣠����樨'
	oBox:Color := color_say + ',' + color_get
	oBox:Frame := BORDER_DOUBLE
    oBox:MessageLine := '^<Esc>^ - �⬥��;  ^<Enter>^ - �롮�'
    oBox:Save := .t.
	oBox:View()

    nTop := 4
    nLeft := 40 - l / 2
    nBottom := 9
    nRight := 40 + l / 2 + 1

    // ���� �롮� ॣ����
    oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight, .f. )
    oBoxRegion:Caption := '������'
	oBoxRegion:Frame := BORDER_SINGLE
	oBoxRegion:View()
    nChoice := AChoice( oBoxRegion:Top+1, oBoxRegion:Left+1, oBoxRegion:Bottom-1, oBoxRegion:Right-1, ar, , , 34 )
    IF nChoice == 0
        @ 14, 12 SAY "��� �롮�:" + hb_ntos(nChoice)
    ELSE
        @ 14, 12 SAY "��� �롮�:" + hb_ntos(nChoice) + ", " + ar[ nChoice ]
    ENDIF    
    inkey(0)
    return NIL

    
* 25.12.20 �롮� ����樭᪮�� ��०����� �� ᯨ᪠
function viewF003_old()
    Local buf := savescreen()
    Local r1 := T_ROW
    Private pr1 := r1, pc1 := 5, pc2 := 75, fl_found := .t.
   

    // G_Use(dir_server+"f003",dir_server+"f003","F003")
    // �����⮢�� 䠩�� ��

    G_Use(dir_server+"f003",,"F003")
    index on substr(mcode,1,2) to (cur_dir+"tmp_f003")
    
    SET FILTER TO substr(F003->mcode,1,2) = "34"
    dbGoTop()
    Alpha_Browse(pr1,pc1,maxrow()-2,pc2,"f1_f003",color0,,,,,,,"f2_f003",,{,,,,.t.} )
    close databases
    
    restscreen(buf)
    return nil

* 29.12.20 ****
Function f1_f003(oBrow)
    Local oColumn
    oColumn := TBColumnNew(center("������������ �࣠����樨",30), {|| F003->short_name })
    oBrow:addColumn(oColumn)
    status_key("^<Esc>^ ��室; ^<Enter>^ �롮� ��०�����; ^F2^ �⡮� �� ॣ����")
    return NIL
            

* 29.12.20 ****
Function f2_f003(nKey,oBrow)
    Local buf, fl := .f., rec, rec1, k := -1, r := maxrow()-7, tmp_color
    Local sh := 80, HH := 57
    do case
        case nKey == K_ESC
        case nKey == K_ENTER
        case nKey == K_F2
    endcase
    return k
    