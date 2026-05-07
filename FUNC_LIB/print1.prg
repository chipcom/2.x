#include 'function.ch'
#include 'inkey.ch'

// проверка готовности к работе принтера
FUNCTION print_flag( k )

  // k - номер порта, целое число от 1 до 3 - (LPT1,LPT2,LPT3)
  LOCAL fl := .F., bbuf := save_maxrow()

  DO WHILE .T.
    status_key( 'Если принтер готов к работе, нажмите любую клавишу. ^<Esc>^ - отказ от печати.' )
    IF inkeytrap( 0 ) == K_ESC
      EXIT
    ENDIF
    IF !PRINTREADY( k )
      stat_msg( 'Принтер не готов.' )
      mybell( 1 )
    ELSE
      fl := .T.
      EXIT
    ENDIF
  ENDDO
  REST_BOX( bbuf )

  RETURN fl
