// различные функции для КСГ - KSG_func.prg
#include 'function.ch'
#include 'chip_mo.ch'

// 02.05.26
function add_KSG_table( arr_KSG, mdate, lal, osn_diag, j, sds1, sds2, lvr, ldnej, lrslt, lDoubleSluch )

  local n_cena_oms, prioritet := 0
  local vkiro, akiro := {}
  local diag3, diag5

  osn_diag := AllTrim( osn_diag )
  diag3 := substr( osn_diag, 1, 3 )
  diag5 := substr( osn_diag, 1, 5 )
  if substr( k006->sy, 1, 4 ) == 'A16.' .or. ;
      eq_any( Lower( substr( k006->shifr, 1, 4 ) ), 'st37', 'ds37' ) .or. ;
      eq_any( Lower( substr( k006->shifr, 1, 4 ) ), 'st19', 'ds19' )
    prioritet := 1
  endif
  if substr( k006->los, 1, 1 ) == '1' .and. eq_any( Lower( AllTrim( k006->shifr ) ), 'st25.004', 'ds25.001' )
    prioritet := 1
  endif
  if ( diag3 == 'L26' .or. eq_any( diag5, 'L08.0', 'L27.0', 'L27.2' ) ) .and. lvr == 1
    prioritet := 1
  endif
  if ( diag5 == 'C84.0' ) .and. ;
      eq_any( Lower( substr( k006->ad_cr, 1, 5 ) ), 'derm4', 'derm5', 'derm7', 'derm8' )
    prioritet := 1
  endif
// определим цену КСГ с учетом КИРО
  n_cena_oms := ret_cena_ksg( k006->shifr, lvr, mdate )
  If ! Empty( ( lal )->kiros ) 
    vkiro := defenition_kiro( mdate, ( lal )->kiros, ldnej, lrslt, 0, k006->shifr, lDoubleSluch )
    If ( vkiro > 0 .and. mdate < 0d20260101 ) .or. ( mdate >= 0d20260101 )
      n_cena_oms := cena_with_kiro( n_cena_oms, vkiro, mdate, lrslt, ;
        iif( Year( mdate ) > 2025, ( lal )->TYPE_KSG, 0 ), akiro )
    Endif
  Endif

  default sds1 to '', sds2 to ''
  AAdd( arr_KSG, { ;
    k006->shifr, ;                // 1 шифр КСГ
    n_cena_oms, ;                 // 2 цена услуги в ОМС
    k006->kz, ;                   // 3 коэффициент затратоемкости
    AllTrim( ( lal )->kiros ), ;  // 4 список возможных КИРО
    osn_diag, ;                   // 5 основной диагноз
    k006->sy, ;                   // 6 Код услуги, соответствующий номенклатуре медицинских услуг V001. Если код услуги не участвует в правиле отнесения к КСГ, то передается ?пустой? тег.
    k006->age, ;                  // 7 Возрастная категория, в соответствии с которой проводится отнесение к КСГ. Если возраст не участвует в правиле отнесения к КСГ, то передается ?пустой? тег
    k006->sex, ;                  // 8 Пол, в соответствии с которым проводится отнесение к КСГ: 1- мужской, 2- женский. Если пол не участвует в правиле отнесения к КСГ, то передается ?пустой? тег
    k006->los, ;                  // 9 Длительность случая лечения. Если длительность случая не участвует в правиле, то передается ?пустой? тег.
    k006->ad_cr, ;                // 10 Код классификационного критерия в соответствии с ?Справочником дополнительных классификационных критериев? V024, за исключением показателя ?Количество фракций?, используемых при лучевой или химиолучевой терапии.
    sds1, ;                       // 11 Коды сопутствующих диагнозов по МКБ-10.
    sds2, ;                       // 12 Код диагнозов осложнений по МКБ10.
    j, ;                          // 13
    AllTrim( ( lal )->kslps ), ;  // 14 Список доступных КСЛП.
    k006->ad_cr1, ;               // 15 Иной классификационный критерий. Используется для передачи сведений о показателе ?Количество фракций? при лучевой или химиолучевой терапии.
    iif( Year( mdate ) > 2025, ( lal )->TYPE_KSG, 0 ), ;  // 16 тип КСГ ( 0 - терапевтическое, 1 - хирургическое ), до 26 года всегда 0
    lvr, ;                        // 17 Взрослый - 0/ребенок - 1
    prioritet ;                   // 18 приоритет -1, 0 1
  } ;
  )
//    0, ;                          // 2
//       &lal.->kiros, ; // 4
//       &lal.->kslps, ; // 14
//       &lal.->TYPE_KSG } ; // 16

  return arr_KSG

// 15.02.25
function ksgInList( lshifr, strKSG )

  local arr := strKSGtoArray( strKSG )

  lshifr := lower( lshifr )
  return ( hb_AScan( arr, lshifr, , , .t. ) > 0 )

// 15.02.25
function strKSGtoArray( strKSG )

  local i, j, arr, aTmp, aResult := {}, beg, end, nPos, prefix

  strKSG := Lower( strKSG )
  arr := split( strKSG, ',' )
  for i := 1 to len( arr )
    arr[ i ] := alltrim( arr[ i ] )
    if Empty( arr[ i ] )
      loop
    endif
    aTmp := split( arr[ i ], '-' )
    if len( aTmp ) == 1 // одна услуга
      AAdd( aResult, arr[ i ] )
    else  // интервал услуг
      if Empty( aTmp[ 1 ] ) .or. Empty( aTmp[ 2 ] )
        loop
      endif
      nPos := 0
      nPos := At( '.', aTmp[ 1 ] )
      prefix := SubStr( aTmp[ 1 ], 1, nPos )
      beg := val( SubStr( aTmp[ 1 ], nPos + 1 ) )
      nPos := 0
      nPos := At( '.', aTmp[ 2 ] )
      end := val( SubStr( aTmp[ 2 ], nPos + 1 ) )
      for j := beg to end
        AAdd( aResult, prefix + StrZero( j, 3 ) )
      next
    endif
  next
  return aResult

// 28.01.20 вывести строку в отладочный массив о КСГ
Function f_put_debug_ksg( k, arr, ars )

  // k = 1 - терапевтическая
  // k = 2 - хирургическая
  Local s := ' ', i, s1, arr1 := {}

  If k == 1
    s += 'терап.'
  Elseif k == 2
    s += 'хирур.'
  Endif
  s += 'КСГ'
  If Len( arr ) == 0
    s += ' не определена'
  Else
    s += ': '
    For i := 1 To Len( arr )
      s1 := ''
      If k == 0 .and. !Empty( arr[ i, 5 ] )
        s1 += 'осн.диаг.,'
      Endif
      If eq_any( k, 0, 1 ) .and. !Empty( arr[ i, 6 ] )
        If AllTrim( arr[ i, 10 ] ) == 'mgi'
          //
        Else
          s1 += 'усл.,'
        Endif
      Endif
      If !Empty( arr[ i, 7 ] )
        s1 += 'возр.,'
      Endif
      If !Empty( arr[ i, 8 ] )
        s1 += 'пол,'
      Endif
      If !Empty( arr[ i, 9 ] )
        s1 += 'дл-ть,'
      Endif
      If !Empty( arr[ i, 10 ] )
        s1 += 'доп.критерий,'
      Endif
      If Len( arr[ i ] ) >= 15 .and. !Empty( arr[ i, 15 ] )
        s1 += 'иной критерий,'
      Endif
      If !Empty( arr[ i, 11 ] )
        s1 += 'соп.диаг.,'
      Endif
      If !Empty( arr[ i, 12 ] )
        s1 += 'диаг.осл.,'
      Endif
      If !Empty( s1 )
        s1 := ' (' + Left( s1, Len( s1 ) -1 ) + ')'
      Endif
      s1 := AllTrim( arr[ i, 1 ] ) + s1 + ' [КЗ=' + lstr( arr[ i, 3 ] ) + ']'
      If AScan( arr1, s1 ) == 0
        AAdd( arr1, s1 )
      Endif
    Next
    For i := 1 To Len( arr1 )
      s += arr1[ i ] + ' '
    Next
  Endif
  AAdd( ars, s )
  Return Len( arr1 )

// 20.01.14 вернуть цену КСГ
Function ret_cena_ksg( lshifr, lvr, ldate, ta )

  Local fl_del := .f., fl_uslc := .f., v := 0

  Default ta TO {}
  v := fcena_oms( lshifr, ;
    ( lvr == 0 ), ;
    ldate, ;
    @fl_del, ;
    @fl_uslc )
  If fl_uslc  // если нашли в справочнике ТФОМС
    If fl_del
      AAdd( ta, ' цена на услугу ' + RTrim( lshifr ) + ' отсутствует в справочнике ТФОМС' )
    Endif
  Else
    AAdd( ta, ' для Вашей МО в справочнике ТФОМС не найдена услуга: ' + lshifr )
  Endif
  Return v

// 28.01.14 вывести в центре экрана протокол определения КСГ
Function f_put_arr_ksg( cLine )

  Local buf := SaveScreen(), i, nLLen := 0, mc := MaxCol() -1, ;
    nLCol, nRCol, nTRow, nBRow, nNumRows := Len( cLine )

  AEval( cLine, {| x, i| nLLen := Max( nLLen, Len( x ) ) } )
  If nLLen > mc
    nLLen := mc
  Endif
  // вычисление координат углов
  nLCol := Int( ( mc - nLLen ) / 2 )
  nRCol := nLCol + nLLen + 1
  nTRow := Int( ( MaxRow() - nNumRows ) / 2 )
  nBRow := nTRow + nNumRows + 1
  put_shadow( nTRow, nLCol, nBRow, nRCol )
  @ nTRow, nLCol Clear To nBRow, nRCol
  DispBox( nTRow, nLCol, nBRow, nRCol, 2, 'GR/GR*' )
  AEval( cLine, {| cSayStr, i| ;
    nSayRow := nTRow + i, ;
    nSayCol := nLCol + 1, ;
    SetPos( nSayRow, nSayCol ), DispOut( PadR( cSayStr, nLLen ), 'N/GR*' ) ;
    } )
  Inkey( 0 )
  RestScreen( buf )
  Return Nil

// // 26.01.18 тест определения КСГ
// Function test_defenition_KSG()
// Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t.
// stat_msg("Определение КСГ")
// R_Use(dir_server() + "mo_uch",,'UCH')
// R_Use(dir_server() + 'mo_otd',,'OTD')
// Use_base("lusl")
// Use_base("luslc")
// Use_base('uslugi')
// R_Use(dir_server() + "schet_",,"SCHET_")
// R_Use(dir_server() + "uslugi1",{dir_server() + "uslugi1", ;
// dir_server() + "uslugi1s"},"USL1")
// use_base("human_u") // если понадобится, удалить старый КСГ и добавить новый
// R_Use(dir_server() + "mo_su",,"MOSU")
// R_Use(dir_server() + "mo_hu",dir_server() + "mo_hu","MOHU")
// set relation to u_kod into MOSU
// R_Use(dir_server() + "human_2",,"HUMAN_2")
// R_Use(dir_server() + "human_",,"HUMAN_")
// G_Use(dir_server() + "human",,"HUMAN") // перезаписать сумму
// set relation to recno() into HUMAN_, to recno() into HUMAN_2
// n_file := cur_dir() + "test_ksg.txt"
// fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
// go top
// do while !eof()
// @ maxrow(),0 say str(recno()/lastrec()*100,7,2)+"%" color cColorStMsg
// if inkey() == K_ESC
// exit
// endif
// if human->K_DATA > stod("20190930") .and. eq_any(human_->USL_OK,1,2)
// arr := defenition_ksg()
// if len(arr) == 7 // диализ
// add_string("== диализ == ")
// else
// aeval(arr[1],{|x| add_string(x) })
// if !empty(arr[2])
// add_string("ОШИБКА:")
// aeval(arr[2],{|x| add_string(x) })
// endif
// select HU
// find (str(human->kod,7))
// do while hu->kod == human->kod .and. !eof()
// usl->(dbGoto(hu->u_kod))
// if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
// lshifr := usl->shifr
// endif
// if alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
// if !(round(hu->u_cena,2) == round(arr[4],2)) // не та цена
// add_string("в л/у для КСГ="+arr[3]+" стоит цена "+lstr(hu->u_cena,10,2)+", а должна быть "+lstr(arr[4],10,2))
// if human->schet > 0
// schet_->(dbGoto(human->schet))
// add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
// endif
// endif
// exit
// endif
// select LUSL
// find (lshifr) // длина lshifr 10 знаков
// if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // стоит другой КСГ
// add_string("в л/у стоит КСГ="+alltrim(lshifr)+"("+lstr(hu->u_cena,10,2)+;
// "), а должна быть "+arr[3]+"("+lstr(arr[4],10,2)+")")
// if human->schet > 0
// schet_->(dbGoto(human->schet))
// add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
// endif
// exit
// endif
// select HU
// skip
// enddo
// endif
// add_string(replicate("*",80))
// endif
// select HUMAN
// skip
// enddo
// close databases
// rest_box(buf)
// fclose(fp)
// return NIL
