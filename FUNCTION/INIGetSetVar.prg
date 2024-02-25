#include 'ini.ch'

function getWorkAreaVar( cFile, cSection, cEntry )
	local oIni, ret

	INI oIni FILE cFile
		GET ret	SECTION cSection ENTRY cEntry		OF oIni DEFAULT nil
	ENDINI
	return ret

procedure setWorkAreaVar( cFile, cSection, cEntry, var )
	local oIni

	INI oIni FILE cFile
		SET SECTION cSection ENTRY cEntry	TO var	OF oIni
	ENDINI
	return
