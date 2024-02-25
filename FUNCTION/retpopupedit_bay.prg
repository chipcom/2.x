#include "function.ch"
#include "edit_spr.ch"

***** вернуть наименование (name) чего-то по коду (kod) в базе данных
Function retpopupedit_bay
	Local mm := "", tmp_select := select()
	Local oItem := Nil, lExists := .F.
	parameters name_base, mkod
	
	If VALTYPE( name_base ) == "C"
		if R_Use(name_base)  // на чтение
			if fieldnum("KOD") > 0 // если в базе данных есть поле "KOD"
				locate for FIELD->kod == mkod
				mm := if(found(), rtrim(FIELD->name), "")
			else  // иначе работаем по номеру записи
				goto (mkod)
				mm := if(!eof() .and. !deleted(), rtrim(FIELD->name), "")
			endif
			use
		endif
		if tmp_select > 0
			select(tmp_select)
		endif
	Elseif valtype( name_base ) == "A" .AND. Len( name_base ) >  0
		If VALTYPE( name_base[1] ) == "O"
			lExists := __objHasMethod( name_base[1], "Code" )
			FOR EACH oItem IN name_base
				If lExists
					If oItem:Code() == mkod
						mm := AllTrim( oItem:Name() )
					EndIf
				Else
					If oItem:ID() == mkod
						mm := AllTrim( oItem:Name() )
					EndIf
				EndIf
			NEXT
		ElseIf VALTYPE( name_base[1] ) == "A"
		EndIf
	EndIf
	if empty(mm)
		mm := space(10)
	endif
	
	return mm