#include 'hbclass.ch'
#include 'common.ch'
#include 'property.ch'

CREATE CLASS TSys_date

	VISIBLE:
		PROPERTY sys_date READ getSys_date
		PROPERTY sys1_date READ getSys1_date
		PROPERTY c4sys_date READ getC4Sys_date
		METHOD New()
		METHOD get()
		METHOD change_sys_date()

	HIDDEN:
		DATA FDate      INIT Date()
		DATA FDate1     INIT Date()
		DATA FDate_c4   INIT dtoc4( Date() )

        METHOD getSys_date      INLINE ::FDate
        METHOD getSys1_date      INLINE ::FDate1
        METHOD getC4Sys_date      INLINE ::FDate_c4

ENDCLASS

METHOD TSys_date:New()

	return self

METHOD TSys_date:get()

    static _instanceClass

    if HB_ISNIL( _instanceClass )
        _instanceClass := TSys_date():new()
    endif
	return _instanceClass

METHOD TSys_date:change_sys_date()

    ::FDate := Date()
    ::FDate1 := Date()
    ::FDate_c4 := dtoc4( Date() )
    return nil