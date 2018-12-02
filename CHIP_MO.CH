#define NET
// список задач
#define X_REGIST  1
#define X_PPOKOJ  2
#define X_OMS     3
#define X_PLATN   4
#define X_ORTO    5
#define X_KASSA   6
#define X_KEK     7
#define X_RISZ    8  // интеграция с программой Smart Delta Systems
#define X_MO     11  // своя задача ??????
#define X_263    12  // для задачи по приказу 263-ФФОМС
#define X_SPRAV  21
#define X_SERVIS 22
#define X_COPY   23
#define X_INDEX  24
*******************************************************************************
#define TIP_LU_SMP    1 // скорая помощь
#define TIP_LU_DDS    2 // диспансеризация детей-сирот в стационарах
#define TIP_LU_DVN    3 // диспансеризация взрослого населения
#define TIP_LU_DDSOP  4 // диспансеризация детей-сирот под опекой
#define TIP_LU_PN     5 // профилактика несовершеннолетних
#define TIP_LU_PREDN  6 // предварительные осмотры несовершеннолетних
#define TIP_LU_PERN   7 // периодические осмотры несовершеннолетних
#define TIP_LU_PREND  8 // пренатальная диагностика
#define TIP_LU_VR_PP  9 // врачебные приёмы в приёмном покое
#define TIP_LU_H_DIA 10 // гемодиализ
#define TIP_LU_P_DIA 11 // перитонеальный диализ
#define TIP_LU_G_CIT 12 // жидкостная цитология
#define TIP_LU_NMP   13 // неотложная медицинская помощь
*******************************************************************************
#define OPER_KART  1
#define OPER_LIST  2
#define OPER_USL   3
*******************************************************************************
#define _MO_SHORT_NAME 1
#define _MO_KOD_TFOMS  2
#define _MO_PROD       3
#define _MO_DOLG       4
#define _MO_KOD_FFOMS  5
#define _MO_FULL_NAME  6
#define _MO_UROVEN     7
#define _MO_STANDART   8
#define _MO_IS_MAIN    9
#define _MO_IS_UCH    10
#define _MO_IS_SMP    11
#define _MO_ADRES     12
#define _MO_LEN_ARR   12
*******************************************************************************
#define _XML_FILE_REESTR  1 // тип высылаемого файла;1-реестр
#define _XML_FILE_SCHET   2 // тип высылаемого файла;2-счет
#define _XML_FILE_FLK     3 // тип принимаемого файла;3-ФЛК
#define _XML_FILE_SP      4 // тип принимаемого файла;4-СП
#define _XML_FILE_RAK     5 // тип принимаемого файла;5-РАК
#define _XML_FILE_RPD     6 // тип принимаемого файла;6-РПД
#define _XML_FILE_R01    11 // тип высылаемого файла;11-R01
#define _XML_FILE_R02    12 // тип принимаемого файла;12-R02
#define _XML_FILE_R05    13 // тип высылаемого файла;13-R05
#define _XML_FILE_R06    14 // тип принимаемого файла;14-R06
#define _XML_FILE_D01    21 // тип высылаемого файла;21-D01
#define _XML_FILE_D02    22 // тип принимаемого файла;22-D02
*******************************************************************************
#define _CSV_FILE_REESTR  1 // тип высылаемого файла;1-реестр
#define _CSV_FILE_ANSWER  2 // тип принимаемого файла;2-ответ на реестр
#define _CSV_FILE_OTKREP  3 // тип принимаемого файла;3-открепление
#define _CSV_FILE_SVERKAZ 5 // тип высылаемого файла;5-запрос для сверки
#define _CSV_FILE_SVERKAO 4 // тип принимаемого файла;4-ответ на запрос для сверки
#define _CSV_FILE_PRIKFLK 6 // тип принимаемого файла;6-ФЛК на реестр
#define _CSV_FILE_PRIKANS 7 // тип принимаемого файла;7-протокол на реестр
*******************************************************************************
// dostup для входа в ф-ию view_human
#define B_BOLEN    1 // лечится (не введена дата окончания лечения)
#define B_END      2 // введена дата окончания лечения, лечение не завершено
#define B_STANDART 3 // лечение завершено
#define B_SCHET    4 // включен в счет
#define B_OPL      5 // оплачен
#define B_NE_OPL   6 // больной по какой-то причине не оплачивается
#define B_REESTR   31// включен в реестр
*******************************************************************************
// массив для копирования услуг
#define _HU_DATE_U1   1
#define _HU_U_KOD     2
#define _HU_U_CENA    3
#define _HU_SHIFR_U   4
#define _HU_SHIFR1    5
#define _HU_NAME_U    6
#define _HU_IS_NUL    7
#define _HU_IS_OMS    8
#define _HU_KOD_VR    9
#define _HU_KOD_AS   10
#define _HU_OTD      11
#define _HU_KOL_1    12
#define _HU_STOIM_1  13
#define _HU_KOD_DIAG 14
#define _HU_PROFIL   15
#define _HU_PRVS     16
#define _HU_N_BASE   17
#define _HU_IS_EDIT  18
#define _HU_KOL_RCP  19
#define _HU_LEN      19
*******************************************************************************
// переменная PZTIP - тип план-заказа
#define _PZ_POL 1 // план-заказ амбулаторно-поликлинических посещений
#define _PZ_STA 2 // план-заказ койко-дней в стационаре
#define _PZ_DNS 3 // план-заказ пациенто-дней в дневных стационарах
#define _PZ_UET 4 // план-заказ УЕТ в стоматологии
#define _PZ_KT  5 // компьютерная томография
*******************************************************************************
// массив для чтения электронного полиса
#define _EP_SMO      1
#define _EP_NAMESMO  2
#define _EP_OGRN     3
#define _EP_OKATO    4
#define _EP_FAM      5
#define _EP_IM       6
#define _EP_OT       7
#define _EP_W        8
#define _EP_DR       9
#define _EP_MR      10
#define _EP_NPOLIS  11
#define _EP_D_BEGIN 12
#define _EP_D_END   13
#define _EP_SNILS   14
#define _EP_LEN     14
*******************************************************************************
// переменная TIP_USL в платных услугах
#define PU_PLAT   0 // платный больной
#define PU_D_SMO  1 // добровольное страхование
#define PU_PR_VZ  2 // взаимозачет

// переменная TIP_USL в задаче ОРТОПЕДИЯ
#define OU_PLAT   0 // платный больной
#define OU_B_PLAT 1 // бесплатный больной
#define OU_PR_VZ  2 // взаимозачет
#define OU_D_SMO  3 // добровольное страхование

// переменная tip в справочнике u_usl_5 (оплата по способу 5)
#define O5_VR_OMS  1  // врач(ОМС)
#define O5_AS_OMS  2  // асс.(ОМС)
#define O5_VR_PLAT 3  // врач(пл.)
#define O5_AS_PLAT 4  // асс.(пл.)
#define O5_MS_PLAT 5  // м/с(пл.)
#define O5_SN_PLAT 6  // сан.(пл.)
#define O5_VR_NAPR 7  // врач(за направление)
#define O5_AS_NAPR 8  // асс.(за направление)
#define O5_VR_DMS  9  // врач(ДМС)
#define O5_AS_DMS 10  // асс.(ДМС)

// массивы для работы с правилами статистики
#define D_RULE_N_DATA  1
#define D_RULE_K_DATA  2
#define D_RULE_BUKVA   3
//
#define D_RULE_N_PRINT 1
#define D_RULE_N_VVOD  2
#define D_RULE_N_DIAGN 3
#define D_RULE_N_F12   4
#define D_RULE_N_F57   5
//
#define I_FIN_OMS    9  // ОМС
#define I_FIN_PLAT   0  // платные
#define I_FIN_BUD    1  // бюджет
#define I_FIN_LPU    2  // взаиморасчеты с другими ЛПУ
#define I_FIN_NEOPL  3  // не оплачивается
#define I_FIN_OWN    4  // за свой счёт
#define I_FIN_DMS    5  // ДМС
//
#define F_YES_OMS 1
#define F_YES_PL  2
// переменные для задачи LPUKASSA
#define LPU_KAS_B_PL   1   // бесплатные
#define LPU_KAS_PLAT   2   // платные
#define LPU_KAS_PL_S   3   // платные со скидкой
#define LPU_KAS_DMS    4   // ДМС
#define LPU_KAS_VZ     5   // взаимозачет
//
#define LPU_KAS_EDIT   0   // редактирование наряда
#define LPU_KAS_SLOG   1   // открытие сложного наряда
#define LPU_KAS_PROS   2   // открытие простого наряда
