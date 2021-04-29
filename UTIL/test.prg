#xtranslate <alias>.<xField> => <alias>-><xField>
#xtranslate <alias>.gotop => <alias>->( dbGotop() )
#xtranslate <alias>.gobottom => <alias>->( dbGoBottom() )

proc main
local cCode
use _mo1kiro alias kiro new
kiro.gotop
cCode := kiro.Code
? cCode
kiro.gobottom
cCode := kiro.Code
? cCode
return