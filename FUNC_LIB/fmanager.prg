#include 'function.ch'
#include 'inkey.ch'

Static smaska
Static sUpDir  := '<UP--DIR>'
Static sSubDir := ' < DIR > '

#define sh1 32  // 28 // ширина колонки под имя файла

#xtranslate    .filename     =>    \[1\]
#xtranslate    .filesize     =>    \[2\]
#xtranslate    .filedate     =>    \[3\]
#xtranslate    .filetime     =>    \[4\]
#xtranslate    .fileattrib   =>    \[5\]

#xtranslate    .boxTitle     =>    \[1\]
#xtranslate    .boxMessage   =>    \[2\]
#xtranslate    .boxFileName  =>    \[3\]
#xtranslate    .boxFirstOpt  =>    \[4\]
#xtranslate    .boxSecondOpt =>    \[5\]

// вернуть имя файла без расширения
#xtranslate RetNameFile(<f>)  =>  if('.' $ <f>, beforatnum('.', <f>), <f>)
// вернуть расширение файла без имени
#xtranslate RetExtFile(<f>)   =>  afteratnum('.', <f>)

// что-то типа Norton'а или FAR'а
Function manager( r1, c1, r2, name_disk, yes_floppy, file_or_dir, is_space, ;
                 /*@*/fl_space, blk_F3, maska )
  // r1,c1       - левый верхний угол рамки
  // r2          - нижний ряд рамки
  // name_disk   - если присутствует, то сразу встать на данный диск
  // yes_floppy  - выводить ли в меню дисководов гибкие дисководы
  // file_or_dir - выбор файла (1-умолчание) или директории (2)
  // is_space    - разрешается ли очистка поля по пробелу
  // fl_space    - можно вернуть .t./.f. по ссылке (был ли нажат пробел)

  Static ini_file := '_manager', ini_group := 'Read_Write'
  Local name_file := '', buf := savescreen()
  Local b, cVal, s_msg, up_dir, fl_esc := .f.
  Local nCursor, lScore, _aDir
  Local nKey, column, c2, tmp_drv, tmp_dir
  Local nSubscript, nLen, i, d, k, first_file := '', fl := .f.
  Local lReconfigure, tmp_color := SETCOLOR('BG+/B')

  smaska := maska
  fl_space := .f.
  DEFAULT file_or_dir TO 1  // по умолчанию выбор файла
  tmp_drv := DISKNAME()
  tmp_dir := DIRNAME( tmp_drv )
  if type( 'p_var_manager' ) == 'C'
    k := GetIniVar( ini_file, { { ini_group, p_var_manager, } } )
    if k[ 1 ] != NIL
      fl := DISKCHANGE( left( k[ 1 ], 1 ) )
      DIRCHANGE( '\' )   // встать в корень
      DIRCHANGE( KeepPath( k[ 1 ] ) )
      first_file := StripPath( k[ 1 ] )
    endif
  endif
  if ! fl .and. name_disk != NIL
    DISKCHANGE( name_disk )
    DIRCHANGE( '\' )   // встать в корень
  endif
  if ( c2 := ( c1 + 26 + sh1 ) ) > 77
    c2 := 77
    c1 := c2 - 26 - sh1
  endif
  if c1 < 2
    c1 := 2
    c2 := c1 + 26 + sh1
  endif
  // Load Array with directory information
  lReconfigure := .F.
  // Screen
  s_msg := '^<Esc>^ выход'
  if file_or_dir == 1
    s_msg += ' ^<Enter>^ выбор файла'
    if is_space != NIL .and. is_space
      s_msg += ' ^<Пробел>^ очистить'
    elseif maska == NIL
      s_msg += ' ^<F3>^ просмотр файла'
    endif
  else
    if is_space != NIL .and. is_space
      s_msg += ' ^<Пробел>^ очистить'
    endif
    s_msg += ' ^<Ctrl+Enter>^ выбор каталога'
  endif
  s_msg += ' ^<Alt+F1>^ смена диска'
  status_key( s_msg )
  PaintScr( r1, c1, r2, c2 )
  nSubscript := 1
  k          := 0
  nLen       := 1
  _aDir := MyDirec( @nLen, maska )
  if !empty( first_file ) .and. ;
     ( i := ascan( _aDir, { | x | upper( x[ 1 ] ) == upper( first_file ) } ) ) > 0
    keyboard replicate( chr( K_DOWN ), i - 1 )
  endif
  // Create Browse Object
  b := TBrowseNew( r1 + 2, c1 + 1, r2 - 1, c2 - 1 )
  //b := TBrowseNew(r1+2,c1+1,r2-3,c2-1)
  b:colSep    := '│'
  b:colorSpec := 'BG+/B,W+/BG,GR+/B,GR+/BG'
  b:skipBlock := { | x | k := if( ABS( x ) >= ;
                      if( x >= 0, nLen - nSubscript, nSubscript - 1 ), ;
                      if( x >= 0, nLen - nSubscript, 1 - nSubscript ), ;
                      x ), nSubscript += k, k ;
                  }
  b:goTopBlock    := { || nSubscript := 1 }
  b:goBottomBlock := { || nSubscript := nLen }
  blk_color := { || iif( empty( _aDir ) .or. 'D' $ _aDir[ nSubscript, 5 ], { 1, 2 }, { 3, 4 } ) }
  // TBColumn objects
  column := TBColumnNew( , { || if( empty( _aDir ), space( sh1 ), put_file_dir( _aDir[ nSubscript ] ) ) } )
  column:width := sh1
  column:colorBlock := blk_color
  b:addColumn( column )
  column := TBColumnNew( , { || if( empty( _aDir ), space( 9 ), _aDir[ nSubscript, 2 ] ) } )
  column:width :=  9
  column:colorBlock := blk_color
  b:addColumn( column )
  column := TBColumnNew( , { || if( empty( _aDir ), space( 8 ), _aDir[ nSubscript, 3 ] ) } )
  column:width :=  8
  column:colorBlock := blk_color
  b:addColumn( column )
  column := TBColumnNew( , { || if( empty( _aDir ), space( 5 ), _aDir[ nSubscript, 4 ] ) } )
  column:width :=  5
  column:colorBlock := blk_color
  b:addColumn( column )
  b:freeze := 3
  //
  do while .T.
    // Paint current line in unselected color
    //b:colorRect({b:rowPos, 1, b:rowPos, b:colCount}, {1, 1})
    DISPBEGIN()
    b:refreshCurrent()  // Устанавливает текущей строке стандартные цвета
    b:forcestable()  // стабилизация
    DISPEND()
    if b:stable()
      // Paint the entire line
      // Выделение цветом всей текущей строки
      i := eval( ( b:getColumn( 1 ) ):colorBlock )
      if valtype( i ) == 'A'
        i := i[ 2 ]
      else
        i := 2
      endif
      b:colorRect( { b:rowPos, 1, b:rowPos, b:colCount }, { i, i } )
      up_dir := ''
      nKey := INKEYTRAP( 0 )
      if !TBMoveCursor( nKey, b )
        // Keystroke was not handled by
        // TBMoveCursor(). So, lets try here!
        if nKey == K_ESC
          fl_esc := .t.
          EXIT
        elseif nKey == K_ALT_F1
          if !empty( d := menu_disk( r1, c1, r2, c2, yes_floppy ) )
            IF empty( dirname( d ) )
              func_error( 4, 'Дисковод не готов!' )
            ELSE
              DISKCHANGE( d )
              DIRCHANGE( '\' )
              lReconfigure := .T.
            ENDIF
          endif
        elseif nKey == K_F3 .AND. file_or_dir == 1
          cWork := eval( ( b:getColumn( 2 ) ):block )
          if !eq_any( cWork, sUpDir, sSubDir )
            cVal := upper( _aDir[ nSubscript, 1 ] )
            if !( '.OBJ' $ cVal .or. '.EXE' $ cVal .or. '.LIB' $ cVal ;
                             .or. '.ZIP' $ cVal .or. '.RAR' $ cVal ;
                             .or. '.DBF' $ cVal .or. '.NTX' $ cVal )
              fl := .t.
              if blk_f3 != NIL
                fl := eval( blk_f3, cVal )
              endif
              if fl
                viewtext( cVal, 'Просмотр текстового файла ' + cVal, '', '', .t., , -1 )
              endif
            endif
          endif
        elseif nKey == K_ENTER
          // Get the column and evaluate
          // its data retrieval block
          cWork := eval( ( b:getColumn( 2 ) ):block )
          if ( cWork == sUpDir )
            //up_dir := StripPath(hb_AnsiToOem(DIRNAME()))
            up_dir := StripPath( DIRNAME() )
            DIRCHANGE( '..' )
            lReconfigure := .T.
          elseif ( cWork == sSubDir )
            //DIRCHANGE( hb_OemToAnsi(_aDir[nSubscript, 1]) )
            DIRCHANGE( _aDir[ nSubscript, 1 ] )
            lReconfigure := .T.
          elseif !empty( _aDir ) .and. !empty( _aDir[ nSubscript, 1 ] )
            name_file := DISKNAME() + ':' + DIRNAME() + '\'
            if file_or_dir == 1
              name_file += _aDir[ nSubscript, 1 ]
            endif
            EXIT
          endif
        elseif nKey == K_SPACE .AND. is_space != NIL .and. is_space
          name_file := space( 10 )
          fl_space := .t.
          EXIT
        elseif nKey == K_CTRL_ENTER .AND. file_or_dir == 2
          name_file := DISKNAME() + ':' + DIRNAME() + '\'
          EXIT
        endif
      endif
      if lReconfigure
        lReconfigure := .F.
        _aDir := MyDirec( @nLen, maska )
        if empty( up_dir )
          b:goTop()
        else
          b:goBottom()
          for i := len(_aDir) to 1 step -1
            if ( 'D' $ _aDir[ i ].fileattrib ) .and. ;
                      upper(_aDir[ i ].filename ) == upper( up_dir )
              exit
            endif
            b:up()
          next
          up_dir := ''
        endif
        b:refreshCurrent()  // Устанавливает текущей строке стандартные цвета
        b:forcestable()  // стабилизация
        b:configure()
        b:refreshAll()
        man_put_dir( r1, c1, r2, c2 )
      endif
    endif
  enddo
  DISKCHANGE( tmp_drv )
  DIRCHANGE( tmp_dir )
  restscreen( buf )
  setcolor( tmp_color )
  // вернуть имя выбранного файла или каталога (диск и путь)
  if fl_esc
    name_file := ''
  else
    //name_file := charone('\',hb_AnsiToOem(name_file))
    name_file := charone( '\', name_file )
  endif
  if type( 'p_var_manager' ) == 'C' .and. !empty( name_file )
    SetIniVar( ini_file, { { ini_group, p_var_manager, name_file } } )
  endif
  return name_file

// Pads array elements
Static Function PadIt( aArray, nArrlen )
  Local nPos, i, nALen, nNewALen
  Local cTemp
  
  // Transverse array and its subarrays
  i := 1
  do while i <= len( aArray )
    //aArray[i].filename := hb_AnsiToOem(alltrim(aArray[i].filename))
    aArray[ i ].filename := alltrim( aArray[ i ].filename )
    if ( 'D' $ aArray[ i ].fileattrib )
      if ( aArray[ i ].filename == '.' )
        // Exclude current directory from list
        adel( aArray, i )
        // Shrink it!
        aArray := asize( aArray, len( aArray ) - 1 )
        loop
      elseif ( aArray[ i ].filename == '..' )
        aArray[ i ].filesize := sUpDir
      else
        aArray[ i ].filesize := sSubDir
      endif
    else
      //aArray[i].filename := lower(aArray[i].filename)
      // Pad size
      if aArray[ i ].filesize < 1000000000
        aArray[ i ].filesize := str( aArray[ i ].filesize, 9 )
      else
        aArray[ i ].filesize := str( aArray[ i ].filesize/1000000000, 6, 2 ) + ' Гб'
      endif
    endif
    // Pad date
    aArray[ i ].filedate := date_8( aArray[ i ].filedate )
    // Pad time
    aArray[ i ].filetime := substr( aArray[ i ].filetime, 1, 5 )
    // Keep counter updated
    i++
  enddo
  nArrLen := len( aArray )
  return ( NIL )

// Loads array with directory information and sorts it putting
//     directories at top of list
Static Function MyDirec( nLen, maska )
  
  Static cE := '*.*'
  Local _aDir, cFile

  DEFAULT maska TO cE
  // Текущий каталог
  _aDir := DIRECTORY( maska, 'D' )
  if !( maska == cE )  // если маска не пустая, то обработать каталоги
    cFile := FILESEEK( cE, 16, .f. )
    DO WHILE ! EMPTY( cFile )
      IF ISBIT( FILEATTR(), 5 )         // поддиректория ?
        aadd( _aDir, { cFile, ;
                  filesize(), ;
                  filedate(), ;
                  filetime(), ;
                  'D' } )
      endif
      cFile := FILESEEK()              // следующая поддиректория
    ENDDO
  endif
  asort( _aDir, , , { | x, y | f_sort_file( x, y ) } )
  // Pad some subarray elements
  PadIt( _aDir, @nLen )
  return ( _aDir )  // возврат массива с информацией о каталогах (файлах)

// сортировка файлов (и подкаталогов) в массиве
Static Function f_sort_file( x, y )
  
  Local _n1, _n2, _e1, _e2, ret

  _n1 := upper( RetNameFile( x.filename ) ) ; _e1 := upper( RetExtFile( x.filename ) )
  _n2 := upper( RetNameFile( y.filename ) ) ; _e2 := upper( RetExtFile( y.filename ) )
  if 'D' $ x.fileattrib .and. 'D' $ y.fileattrib
    if left( _n1, 1 ) == '.'
      ret := .t.
    elseif left( _n2, 1 ) == '.'
      ret := .f.
    else
      ret := ( _n1 < _n2 )
    endif
  elseif 'D' $ x.fileattrib
    ret := .t.
  elseif 'D' $ y.fileattrib
    ret := .f.
  elseif _e1 == _e2
    ret := ( _n1 < _n2 )
  else
    ret := ( _e1 < _e2 )
  endif
  return ret

//
Static Function man_put_dir( nTop, nLeft, nBottom, nRight )
  Local s, cur_drv := DISKNAME(), cur_dir, k := nRight - nLeft - 1, k1 := 0

  //cur_dir := hb_AnsiToOem(DIRNAME(cur_drv))
  cur_dir := DIRNAME( cur_drv )
  if !empty( smaska )
    k1 := 3 + len( smaska )
  endif
  if len( cur_dir ) + 2 > k - k1
    cur_dir := '..' + right( cur_dir, k - k1 - 4 )
  endif
  s := cur_drv + ':' + cur_dir
  if !empty( smaska )
    s += ' [' + smaska + ']'
  endif
  @ nTop,nLeft + 1 say padc( s, k, '═' )
  return ( NIL )

// Screen (section not handled by TBrowse)
Static Function PaintScr( nTop, nLeft, nBottom, nRight )
  
  Local nMaxRow

  DISPBEGIN()
  box_shadow( nTop, nLeft, nBottom, nRight )
  @ nTop + 1   ,nLeft + sh1 / 2 - 1 SAY 'Имя'    COLOR 'GR+/B'
  @ nTop       ,nLeft + sh1 + 1 SAY '╤'
  @ nTop + 1   ,nLeft + sh1 + 1 SAY '│'
  @ nBottom    ,nLeft + sh1 + 1 SAY '╧'
  @ nTop + 1   ,nLeft + sh1 + 4 SAY 'Размер' COLOR 'GR+/B'
  @ nTop       ,nLeft + sh1 + 11 SAY '╤'
  @ nTop + 1   ,nLeft + sh1 + 11 SAY '│'
  @ nBottom    ,nLeft + sh1 + 11 SAY '╧'
  @ nTop + 1   ,nLeft + sh1 + 14 SAY 'Дата'   COLOR 'GR+/B'
  @ nTop       ,nLeft + sh1 + 20 SAY '╤'
  @ nTop + 1   ,nLeft + sh1 + 20 SAY '│'
  @ nBottom    ,nLeft + sh1 + 20 SAY '╧'
  @ nTop + 1   ,nLeft + sh1 + 21 SAY 'Время'  COLOR 'GR+/B'
  man_put_dir( nTop, nLeft, nBottom, nRight )
  DISPEND()
  return ( NIL )

// Cursor Movement Methods for TBrowse Objects
Function TBMoveCursor( nKey, oObj )
  
  Local nFound
  Static aKeys := ;
    { K_DOWN      , { |b| b:down() }     , ;
      K_UP        , { |b| b:up() }       , ;
      K_PGDN      , { |b| b:pageDown() } , ;
      K_PGUP      , { |b| b:pageUp() }   , ;
      K_CTRL_PGUP , { |b| b:goTop() }    , ;
      K_CTRL_PGDN , { |b| b:goBottom() } , ;
      K_RIGHT     , { |b| b:right() }    , ;
      K_LEFT      , { |b| b:left() }     , ;
      K_HOME      , { |b| b:goTop() }    , ;  //{|b| b:home()}     , ;
      K_END       , { |b| b:goBottom() } , ;  //{|b| b:end()}      , ;
      K_CTRL_LEFT , { |b| b:panLeft() }  , ;
      K_CTRL_RIGHT, { |b| b:panRight() } , ;
      K_CTRL_HOME , { |b| b:panHome() }  , ;
      K_CTRL_END  , { |b| b:panEnd() }    }
  // Search into array
  nFound := ascan( aKeys, nKey )
  if ( nFound != 0 )
    eval( aKeys[ ++nFound ], oObj )
  endif
  return ( nFound != 0 )     // .T. or .F.

//
Static Function put_file_dir( arr )
  
  Local s := alltrim( arr.filename ), s1, k

  if !( 'D' $ arr.fileattrib ) .and. len( s ) > sh1 .and. ( k := rat( '.', s ) ) > 0
    s1 := substr( s, k )
    k := len( s1 )
    s := left( s, sh1 - k - 1 ) + '~' + s1
  endif
  return padr( s, sh1 )
