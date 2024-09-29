/*
  ; Current field type mappings are:
  C; Character,n     HB_FT_STRING,n                      ADS_STRING
  N; Numeric,n,d     HB_FT_LONG,n,d                      ADS_NUMERIC
  D; Date,n          HB_FT_DATE,3 or 4 or 8              ADS_COMPACTDATE; ADS_DATE
  ShortDate          HB_FT_DATE,3                        ADS_COMPACTDATE
  L; Logical         HB_FT_LOGICAL,1                     ADS_LOGICAL
  M; Memo,n          HB_FT_MEMO,4 or 9 or 8              ADS_MEMO
  B; Double,,d       HB_FT_DOUBLE,8,d                    ADS_DOUBLE
  I; Integer,n       HB_FT_INTEGER, 2 or 4 or 8          ADS_SHORTINT; ADS_INTEGER; ADS_LONGLONG
  ShortInt           HB_FT_INTEGER,2                     ADS_SHORTINT
  Longlong           HB_FT_INTEGER,8                     ADS_LONGLONG
  P; Image           HB_FT_IMAGE,9 or 10                 ADS_IMAGE
  W; Binary          HB_FT_BLOB,4 or 9 or 10             ADS_BINARY
  Y; Money           HB_FT_CURRENCY,8,4                  ADS_MONEY
  Z; CurDouble,,d    HB_FT_CURDOUBLE,8,d                 ADS_CURDOUBLE
  T,4; Time          HB_FT_TIME,4                        ADS_TIME
  @; T,8; TimeStamp  HB_FT_TIMESTAMP,8                   ADS_TIMESTAMP
  +; AutoInc         HB_FT_AUTOINC,4                     ADS_AUTOINC
  ^; RowVersion      HB_FT_ROWVER,8                      ADS_ROWVERSION
  =; ModTime         HB_FT_MODTIME,8                     ADS_MODTIME
  Raw,n              HB_FT_STRING,n (+HB_FF_BINARY)      ADS_RAW
  Q; VarChar,n       HB_FT_VARLENGTH,n                   ADS_VARCHAR; ADS_VARCHAR_FOX
  VarBinary,n        HB_FT_VARLENGTH,n (+HB_FF_BINARY)   ADS_VARBINARY_FOX; ADS_RAW
  CICharacter,n      HB_FT_STRING,n                      ADS_CISTRING
*/

#include 'common.ch'

procedure main()

  local adbf := { { 'numeric', 'N', 5, 0 }, ;
    { 'string', 'C', 15, 0 }, ;
    { 'date', 'D', 8, 0 } , ;
    { 'money', 'Y', 8, 4 }, ;
    { 'incrtest', '+', 3, 0 }, ;
    { 'rowversion', '^', 8, 0 }, ;
    { 'modtime', '=', 8, 0 }, ;
    { 'timest', '@', 8, 0 } ;
    }
  local i

  dbCreate( 'testDB', adbf )
  Use ( 'testDB' ) New Alias TMP

  for i := 1 to 10
    dbAppend()
    TMP->numeric  := i
    TMP->string   := 'str' + AllTrim( str( i ) )
    TMP->date     := date()
    TMP->money    := 1000010000.01
    TMP->timest   := hb_datetime()
  next

  dbGoto( 5 )
  dbDelete()
  dbCommit()

  Pack

  dbAppend()
  TMP->numeric  := 5
  TMP->string   := 'str' + AllTrim( str( 5 ) )
  TMP->date     := date()

  dbCloseAll()

  ?hb_socketResolveAddr( 'chipplus.ru' )

  wait
  return
