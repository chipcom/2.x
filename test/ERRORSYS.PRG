/***
*	Errorsys.prg
*  Standard Clipper error handler
*     (добавления Бабенко К.В. 12.09.2001 для Clipper'а)
*     (добавления Бабенко К.В. 16.11.2011 для Harbour'а)
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*/

#include "function.ch"
#include "Directry.ch"
#include "error.ch"
#include "inkey.ch"

// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

Static err_file := "error.txt"

***** automatically executes at startup
proc ErrorSys()
ErrorBlock( {|e| DefError(e)} )
return

*****
Static Function DefError(e)
local i, k, s, cMessage, aOptions, nChoice, arr_error := {}
// По умолчанию деление на ноль дает ноль
if ( e:genCode == EG_ZERODIV )
  return (0)
end
// Для ошибки открытия файла в сетевом окружении..установка NETERR()
// и значения SUBSYSTEM по умолчанию
if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
  NetErr(.t.)
  return (.f.)                  // NOTE
end
// Для ошибки блокировки во время APPEND BLANK..установка NETERR()
// и значения SUBSYSTEM по умолчанию
if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
  NetErr(.t.)
  return (.f.)                  // NOTE
end
// Построение сообщения об ошибке
cMessage := ErrorMessage(e)
// Построение массива позиций для выбора
aOptions := {"Завершить"}                 // 1
if (e:canRetry)
  AAdd(aOptions, "Повторить")             // 2
endif
if (e:canDefault)
  AAdd(aOptions, "Пропустить")            // 3
endif
// активизация ALERT-меню
nChoice := 0
while ( nChoice == 0 )
  if ( Empty(e:osCode) )
    nChoice := Alert( cMessage, aOptions )
  else
    nChoice := Alert( cMessage + ;
            ";(Код DOS-ошибки: " + lstr(e:osCode) + ")", ;
            aOptions )
  end
  if ( nChoice == NIL )
    exit
  end
end
if ( !Empty(nChoice) )
  // Выполнение по инструкции оператора
  if ( aOptions[nChoice] == "Повторить" )
    return (.t.)
  elseif ( aOptions[nChoice] == "Пропустить" )
    return (.f.)
  end
end
// Отображение сообщения и стека вызова процедур (при Завершить)
if ( !Empty(e:osCode) )
  cMessage += " (Код DOS-ошибки: " + lstr(e:osCode) + ")"
end
aadd(arr_error, cMessage)
? cMessage
i := 0
while ( !Empty(s := alltrim(ProcName(i))) )
  k := ProcLine(i)
  if isFuncErr(s)   // если ф-ия не входит в список "ненужных" вызовов
    cMessage := "Вызов из "+s+"("+lstr(k)+")"
    ? cMessage
    aadd(arr_error, cMessage)
  endif
  ++i
end
// запись в файл информации об ошибке
set date german
s := exename()
cMessage := dtoc(date())+" "+sectotime(seconds())+" "+StripPath(s)
cMessage += "("+dtoc(directory(s)[1,F_DATE])+","+lstr(memory(1))+"Кб)"
if type("fio_polzovat") == "C" .and. !empty(fio_polzovat)
  cMessage += " ["+alltrim(fio_polzovat)+"]"
endif
if type("p_name_comp") == "C" .and. !empty(p_name_comp)
  cMessage += " ("+alltrim(p_name_comp)+")"
endif
cMessage += eos
aeval(arr_error, {|x| cMessage += x+eos})
cMessage += replicate("*",79)+eos
if type("DIR_SERVER") != "C"
  Private dir_server := ""
endif
if filesize(dir_server+err_file) > 500000  // если больше 0.5 Мб,
  delete file (dir_server+err_file)        // удаляем файл и начинаем с нуля
endif
strfile(cMessage,dir_server+err_file,.t.)
ErrorLevel(1)
f_end()
return (.f.)

*****
Function ErrorMessage(e)
local cMessage
// Начало сообщения об ошибке
cMessage := if( e:severity > ES_WARNING, "Ошибка ", "Предупреждение " )
// добавление имени подсистемы (если доступно)
if ( ValType(e:subsystem) == "C" )
  cMessage += e:subsystem()
else
  cMessage += "???"
end
// добавление SUBSYSTEM кода ошибки (если доступно)
if ( ValType(e:subCode) == "N" )
  cMessage += ("/" + lstr(e:subCode))
else
  cMessage += "/???"
end
// добавление описания ошибки (если доступно)
if ( ValType(e:description) == "C" )
  cMessage += ("  " + e:description)
end
// добавление либо FILENAME, либо названия операции
if ( !Empty(e:filename) )
  cMessage += (": " + StripPath(e:filename))
elseif ( !Empty(e:operation) )
  cMessage += (": " + e:operation)
end
return (cMessage)

***** входит ли функция в список тех, что нужно вывести в ERROR.TXT
Static Function isFuncErr(s)
Static delfunction := {"DEFERROR","ERRORSYS","LOCKERRHAN","INITHANDL"}
Local fl := .t., i
s := upper(s)
for i := 1 to len(delfunction)
  if delfunction[i] $ s
    fl := .f. ; exit
  endif
next
return fl

*

***** 28.05.17 просмотр файла ошибок (рекомендуется включать в меню "Сервис")
Function view_errors()
if !file(dir_server+err_file)
  return func_error(4,"Не обнаружен файл ошибок!")
endif
keyboard chr(K_END)
viewtext(Devide_Into_Pages(dir_server+err_file,80,84),,,,.t.,,,5,,,.f.)
return NIL

*

***** разбить текстовый файл на страницы
Function Devide_Into_Pages(cFile,HH,sh)
Local tmp_file := "_TMP_"+stxt
DEFAULT HH TO 60
fp := fcreate(tmp_file) ; n_list := 1 ; tek_stroke := 0
ft_use(cFile)
do while !ft_Eof()
  verify_FF(HH,valtype(sh)=="N",sh)
  add_string(ft_ReadLn())
  ft_Skip()
enddo
ft_use()
fclose(fp)
return tmp_file
