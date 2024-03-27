local nLoopVal1 := -1
local nLoopVal2 := -2
local cChar1    := "?"
local cChar2
local hItem     := {=>}
local cStringUTF8
local cString1 := "hello world"
local hArray := {=>}

set century on

for each nLoopVal1,nLoopVal2 in {1,3,5,7},{2,4,6,8,10,12,14} DESCEND
	?"For each val1: ",nLoopVal1," (",nLoopVal1:__enumindex,") val2: ",nLoopVal2," (",nLoopVal2:__enumindex,")"
endfor
?"nLoopVal1 = ",nLoopVal1,"  nLoopVal2 = ",nLoopVal2
?

cStringUTF8 := "Hello élève"  // This loop will prove bytes are extracted, not characters.
?cStringUTF8," Byte Length=",len(cStringUTF8)," UTF Length=",hb_utf8Len(cStringUTF8)
for each cChar1,cChar2 in cStringUTF8,@cString1
	?cChar1:__enumindex," ",cChar1
	if empty(mod(cChar2:__enumindex,2))
		cChar2 := upper(cChar2)
	endif
endfor
?"cChar1 = ",cChar1
?"cString1 = ",cString1

hb_HKeepOrder(hArray,.t.)
hb_HCaseMatch(hArray,.f.)
hArray["City"]    := "Seattle"
hArray["State"]   := "WA"
hArray["Country"] := "USA"
for each hItem in hArray DESCEND
	?"HPosition = ",hb_HPos(hArray,hItem:__enumkey)," enumindex = ",hItem:__enumindex," Key = ",hItem:__enumkey," Value = ",hItem:__enumvalue
endfor
