#include 'inkey.ch'
#include '..\function.ch'
#include 'common.ch'
#include '..\edit_spr.ch'

#include 'tbox.ch'

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

* 17.01.21
Function viewF003()
    local nTop, nLeft, nBottom, nRight
    local l := 0, nRegion, fl
    Local ar, aStruct, dbName := "F003", indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
    local oBox, oBoxRegion
    local strRegion := "�롮� ॣ����" 
    local lSelectedRegion := .f., lFileCreated := .f.
    local retMCOD := ''
    local ar_f010 := f010()

    private tmpName := cur_dir + "tmp_F003", tmpAlias := "tF003"
    private oBoxCompany

    ar := {}
    for i := 1 to len(ar_f010)
      aadd(ar, ar_f010[i,1])
      l := max(l,len(ar[i]))
    next

    nTop := 4
    nLeft := 40 - l / 2
    nBottom := 9
    nRight := 40 + l / 2 + 1

    // ���� �롮� ॣ����
    oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
    oBoxRegion:Caption := '������'
    oBoxRegion:Frame := BORDER_SINGLE
    
    // ���� ������� ������������ �࣠����樨
    oBoxCompany := TBox():New( 19, 11, 21, 69 )
    oBoxCompany:Frame := BORDER_NONE
    oBoxCompany:Color := color5 // cDataCSay //color_say

    do while .t.
        // ������� ����
        oBox := NIL // 㭨�⮦�� ����
        if lSelectedRegion
            oBox := TBox():New( 2, 10, 22, 70 )
        else
            oBox := TBox():New( 2, 10, 11, 70 )
        endif
	    oBox:Color := color_say + ',' + color_get
	    oBox:Frame := BORDER_DOUBLE
        oBox:MessageLine := '^^ ��� ���.�㪢� - ��ᬮ��;  ^<Esc>^ - ��室;  ^<Enter>^ - �롮�'
        oBox:Save := .t.

        if ! lSelectedRegion
            oBox:Caption := '�롥�� ॣ���'
            oBox:View()
            oBoxRegion:View()
            nRegion := AChoice( oBoxRegion:Top+1, oBoxRegion:Left+1, oBoxRegion:Bottom-1, oBoxRegion:Right-1, ar, , , 34 )
            if nRegion == 0
                (dbName)->(dbCloseArea())
                (tmpAlias)->(dbCloseArea())
                return retMCOD
            else
                lSelectedRegion := .t.
                if ! lFileCreated
                    dbUseArea( .t.,, dir_server + dbName, dbName, .f., .f. )
                    dbCreateIndex( indexName, "substr(MCOD,1,2)", , NIL )
                    // ᮧ����� �६���� 䠩� ��� �⡮� �࣠����権 ��࠭���� ॣ����
                    aStruct := (dbName)->(dbStruct())
                    dbCreate(tmpName, aStruct)
        
                    dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )
        
                    (dbName)->(dbGoTop())
                    (dbName)->(dbSeek(str(nRegion,2)))
                    do while substr((dbName)->MCOD,1,2) == str(nRegion,2)
                        (tmpAlias)->(dbAppend())
                        (tmpAlias)->MCOD := (dbName)->MCOD
                        (tmpAlias)->NAMEMOK := (dbName)->NAMEMOK
                        (tmpAlias)->NAMEMOP := (dbName)->NAMEMOP
                        (tmpAlias)->YEAR := (dbName)->YEAR
        
                        (dbName)->(dbSkip())
                    enddo
                    lFileCreated := .t.
                    (dbName)->(dbCloseArea())
                endif
                loop
            endif
        else
            if lFileCreated
                oBox:Caption := '�롮� ���ࠢ��襩 �࣠����樨'
                oBox:View()
                dbCreateIndex( tmpName, "NAMEMOK", , NIL )
                (tmpAlias)->(dbGoTop())
                if fl := Alpha_Browse(oBox:Top+1,oBox:Left+1,oBox:Bottom-5,oBox:Right-1,"ColumnF003",color0,,,,,,"ViewRecordF003",,,{"�","�","�","N/BG,W+/N,B/BG,BG+/B"} )
                    retMCOD := (tmpAlias)->MCOD
                endif
                oBoxRegion := NIL
                oBoxCompany := nil
                oBox := nil
                exit
            endif
        endif
    enddo
    (tmpAlias)->(dbCloseArea())
    return retMCOD

***** 16.01.21
Function ColumnF003(oBrow)
    Local oColumn
    oColumn := TBColumnNew(center("������������",50), {|| left((tmpAlias)->NAMEMOK,50) })
    oBrow:addColumn(oColumn)
    return nil

***** 17.01.21
Function ViewRecordF003()
    Local i, arr := {}

    oBoxCompany:View()
    // ࠧ��쥬 ������ ����������� �� �����ப�
    perenos(arr,(tmpAlias)->NAMEMOP,50)
    // oBoxCompany:Clear()
    for i := 1 to len(arr)
        @ oBoxCompany:Top+i-1,oBoxCompany:Left+1 say arr[i]// color color1
      next
  
    return nil