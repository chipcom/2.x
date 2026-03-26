#include 'function.ch'

// Блокирование записи (или добавление с блокированием)
// G_RLock() - одноразовая попытка блокировать запись
// G_RLock('forever') - бесконечная попытка блокировать запись
// G_RLock(.t.) - одноразовая попытка добавить запись
// G_RLock('forever',.t.) - бесконечная попытка добавить запись
// G_RLock(.t.,'forever') - бесконечная попытка добавить запись
// 09.01.17
FUNCTION G_RLock( ... )

  local cArray := hb_AParams()
  LOCAL lAppend := .F., cMessage, i, lRetValue, nSec, lTryForever := .F.

  // Обработка переданных параметров
  FOR i := 1 TO len( cArray )
    IF VALTYPE( cArray[ i ] ) == 'L'
      lAppend := cArray[ i ]
    ELSE
      lTryForever := ( UPPER( cArray[ i ] ) == 'FOREVER' )
    ENDIF
  NEXT // i
  DO WHILE lRetValue == NIL
    nSec := SECONDS() + 3
    // Зацикливание на не более 3 секунд
    DO WHILE ( SECONDS() < nSec ) .AND. ( lRetValue == NIL )
      IF lAppend
        // Выполнение APPEND BLANK если указано
        APPEND BLANK
        IF !NETERR()
          lRetValue := .T.
        ENDIF
      ELSE
        // Блокировка текущей записи
        IF RLOCK()
          lRetValue := .T.
        ENDIF
      ENDIF
    ENDDO
    IF lRetValue == NIL
      // 3 секунды истекли
      cMessage := 'Невозможно блокировать запись в БД ' + ALIAS()
      cMessage += ';Вероятнее всего, она занята другим пользователем'
      IF lTryForever
        cArray := { '<Enter> - попытаться снова' }
      else
        cArray := { 'Попытаться снова','Завершить' }
      ENDIF
      IF ( ALERT( cMessage, cArray, color0 ) != 1 ) .AND. ! lTryForever
        lRetValue := .F.
      ENDIF
    ENDIF
  ENDDO
  
  RETURN ( lRetValue )
