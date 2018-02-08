// Для Фискального регистратора "Штрих"
// управляющие коды
#define FR_COM_ENQ  chr(5)
#define FR_COM_ACK  chr(6)
#define FR_COM_STX  chr(2)
#define FR_COM_ETX  chr(3)
#define FR_COM_EOT  chr(4)
#define FR_COM_NAK  chr(21)
#define FR_COM_DLE  chr(16)
// нормированные промежутки времени
#define FR_TIME_1 200  // для пробы (4 сек вместо 1 сек)
#define FR_TIME_2 200
#define FR_TIME_3 200
#define FR_TIME_4 100
#define FR_TIME_5 200  // правка 4 сек вместо 2 сек
#define FR_TIME_6 100
#define FR_TIME_7 100
#define FR_TIME_8 100
//
// описание массива состояния ФР
#define FR_R_ERROR     1
#define FR_R_KASSIR    2
#define FR_R_VERSIAFR  3
#define FR_R_SBORKAFR  4
#define FR_R_POFR_DATE 5
#define FR_R_ZAL_NOM   6
#define FR_R_NOMER     7
#define FR_R_FLAG      8
#define FR_R_REGIM     9
#define FR_R_PODREGIM  10
#define FR_R_PORT      11
#define FR_R_VERSIAFP  12
#define FR_R_SBORKAFP  13
#define FR_R_POFP_DATE 14
#define FR_R_DATE      15
#define FR_R_TIME      16
#define FR_R_FLAGFP    17
#define FR_R_ZAVNOMER  18
#define FR_R_SMEN_NOM  19
#define FR_R_FREE_FP   20
#define FR_R_KOL_FISK  21
#define FR_R_FREE_FISK 22
#define FR_R_INN       23
#define FR_R_LEN       23   // общая длина массива
