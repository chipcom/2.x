// Строки cRowText цветом cColor падают с ряда r1 до ряда r2
Function SayTop(cRowText, cColor, r1, r2, nCol)

  Local i, nNumCol := LEN( cRowText ), cOldRowText, mdelay

  For i := r1 TO r2 - 1
    cOldRowText := SCREENSTR( i, nCol, nNumCol )
    @ i,nCol SAY cRowText color cColor
    mdelay := ( MAXROW() - i ) / 2
    // если определена переменная "DELAY_SPRD"
    if type( 'DELAY_SPRD' ) == 'N' .and. DELAY_SPRD > 0
      mdelay := int( DELAY_SPRD )
    endif
    mdelay := int( mdelay )
    MILLISEC( mdelay )
    STRSCREEN( cOldRowText, i, nCol )
  Next i
  @ r2,nCol SAY cRowText color cColor

  Return NIL
