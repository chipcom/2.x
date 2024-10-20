PROCEDURE Main

  LOCAL a, b, c, d
  LOCAL GetList := {}
  a := b := c := d := Space(20)

  SetMode(25,80)
  CLS
  @ 1, 0 GET a VALID OtherGet( @c, @d )
  @ 2, 0 GET b VALID OtherGet( @c, @d )
  READ
  RETURN


FUNCTION OtherGet( a, b )

  LOCAL GetList := {}

  SAVE SCREEN
  @ 5, 0 GET a
  @ 6, 0 GET b
  READ
  RESTORE SCREEN
  RETURN .T.

