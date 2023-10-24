// https://groups.google.com/g/harbour-devel/c/ta7CL3H6aps

#include "hbclass.ch"
#include "fileio.ch"

#xcommand defer <exp,...> => iif( !__mvexist("__defer_" + __stackdepth() + lower(procname())), __mvput("__defer_" + __stackdepth() + lower(procname()), hbdefer():new(<exp>)), __mvget("__defer_" + __stackdepth() + lower(procname())):add(<exp>) )

function main()
    dosomething(.t.)
    ? "dosomething 1 executed"
return nil

function dosomething(lrecall)
    local cfile := "test.txt"
    local nhandle
    local err

    hb_default(@lrecall, .f.)

    defer { || qout("defer 1") }
    defer { || qout("defer 2") }
    defer @defer3()

    begin sequence

        if !file(cfile)
            nhandle := fcreate(cfile, FC_NORMAL)
            if nhandle == F_ERROR
                break ( "erro creating file: " + str(ferror()) )
            end
        else
            nhandle := fopen(cfile, FO_READWRITE + FO_DENYNONE)
            if nhandle == F_ERROR
                break ( "erro opening file: " + str(ferror()) )
            end
        end   
        defer { || fclose(nhandle) }

        fwrite(nhandle, time())

    recover using err
        ? err
    end sequence

    if lrecall
        dosomething(.f.)
        ? "dosomething 2 executed"
    end

return nil

class hbdefer
    data queue

    method new(exp) constructor
    method add(exp)

    destructor destroy()
endclass

method new(exp) class hbdefer
    ::queue := {}
    aadd(::queue, exp)
return self

method add(exp) class hbdefer
    aadd(::queue, exp)
return self

method destroy() class hbdefer
    local q
    for each q in ::queue
        
        eval(q)
    next
return self

function defer3()
    ? "defer 3"
return nil

static function __stackdepth()
  local n := 0
  do while ! Empty( ProcName( ++n ) )
  enddo
  return HB_NtoS( n ) + "_"
 