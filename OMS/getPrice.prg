
// строка 200 f5editkusl.prg
select USL
set order to 1
find (padr(mshifr,10))
if found()
  lu_cena := iif(human->vzros_reb == 0, usl->cena, usl->cena_d)
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if (v := f1cena_oms(usl->shifr,;
                      lshifr1,;
                      (human->vzros_reb==0),;
                      human->k_data,;
                      usl->is_nul,;
                      @mis_oms)) != NIL
    lu_cena := v
  endif
