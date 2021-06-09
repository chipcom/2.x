// https://groups.google.com/g/harbour-users/c/5dpZQxe3wSU/m/MIzvkZeBmG8J

#define HB_ISDIGIT( c )         ( ( c ) >= '0' && ( c ) <= '9' )

procedure main()
  local arr := {10,20,{'привет', 1.1, date()}}
  local arr1, xValue, ar

  arr1 := hb_jsonEncode(arr, .f.)
  ? hb_jsonEncode(arr, .f.)
  nLengthDecoded := hb_jsonDecode( arr1, @xValue )
  // correct(xValue)
  ? hb_valToExp(xValue)
  ar := xValue[3]
  ? ValType(stod(ar[3]))
  ? stod(ar[3])
  wait

return

function correct(aR)

  AEval(aR, {|elem| ;
      iif(ValType(elem) == 'A', ;
        correct(aR), ;
        iif(mayBeDate(elem), ;
          elem := SToD(elem), ''  ;
        )  ;
      ) ;
    } ;
  )

  return nil

function mayBeDate(str)
  local ret := .f.

  if ( ValType(str) == 'C' .and. len(str) == 8 )
    // if (HB_ISDIGIT(str[1])) .and. (HB_ISDIGIT(str[8]))
      ret := .t.
    // endif
  endif

  return ret

// FUNCTION PrintArray(aR, cTitle)
//   LOCAL i := 0, cHeading
  
//   cTitle := iif(cTitle # NIL,cTitle,"a")
//     // Step through every array element. If the element is
//     // itself an array, recurse to print the subarray,
//     // just print the element name and subscript.
//     AEval(aR, {|elem|  ;
//            i++,  ;
//            cHeading := cTitle + "[" + Ltrim(Str(i)) + "]", ;
//                 Iif(ValType(elem) = "A",        ;
//                     PrintArray(elem, cHeading), ;
//                     iif(valtype(elem) == "B",Qout(cHeading,"{||...}"),Qout(cHeading, elem))) ;
//               })
  
//   RETURN NIL