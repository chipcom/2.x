* 16.02.21 ขฅเญใโ์ ฌ แแจข  O001.xml
function getO001()
  static _O001 := {}
  // Local dbName, dbAlias := 'O001'
  // local tmp_select := select()


    // O001.dbf - ก้ฅเฎแแจฉแชจฉ ชซ แแจไจช โฎเ แโเ ญ ฌจเ  ()
    //  1 - NAME11(C)  2 - KOD(C)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - ALFA2(C)  6 - ALFA3(C)
    if len(_O001) == 0
      // dbName := '_moO001'
      // tmp_select := select()
      // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    // จแฏเ ขจโ์ ค ซฅฅ
    //     aadd(_O001, { (dbAlias)->SUBNAME, (dbAlias)->KOD_TF, Val((dbAlias)->OKRUG), (dbAlias)->KOD_OKATO, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //     (dbAlias)->(dbSkip())
    // enddo
    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)


    aadd(_O001, {"","004",stod(""),stod(""),"AF","AFG"})
    aadd(_O001, {"","008",stod(""),stod(""),"AL","ALB"})
    aadd(_O001, {"","010",stod(""),stod(""),"AQ","ATA"})
    aadd(_O001, {"","012",stod(""),stod(""),"DZ","DZA"})
    aadd(_O001, {" ","016",stod(""),stod(""),"AS","ASM"})
    aadd(_O001, {"","020",stod(""),stod(""),"AD","AND"})
    aadd(_O001, {"","024",stod(""),stod(""),"AO","AGO"})
    aadd(_O001, {"  ","028",stod(""),stod(""),"AG","ATG"})
    aadd(_O001, {"","031",stod(""),stod(""),"AZ","AZE"})
    aadd(_O001, {"","032",stod(""),stod(""),"AR","ARG"})
    aadd(_O001, {"","036",stod(""),stod(""),"AU","AUS"})
    aadd(_O001, {"","040",stod(""),stod(""),"AT","AUT"})
    aadd(_O001, {"","044",stod(""),stod(""),"BS","BHS"})
    aadd(_O001, {"","048",stod(""),stod(""),"BH","BHR"})
    aadd(_O001, {"","050",stod(""),stod(""),"BD","BGD"})
    aadd(_O001, {"","051",stod(""),stod(""),"AM","ARM"})
  aadd(_O001, {"","052",stod(""),stod(""),"BB","BRB"})
  aadd(_O001, {"","056",stod(""),stod(""),"BE","BEL"})
  aadd(_O001, {"","060",stod(""),stod(""),"BM","BMU"})
  aadd(_O001, {"","064",stod(""),stod(""),"BT","BTN"})
  aadd(_O001, {",  ","068",stod(""),stod(""),"BO","BOL"})
  aadd(_O001, {"  ","070",stod(""),stod(""),"BA","BIH"})
  aadd(_O001, {"","072",stod(""),stod(""),"BW","BWA"})
  aadd(_O001, {" ","074",stod(""),stod(""),"BV","BVT"})
  aadd(_O001, {"","076",stod(""),stod(""),"BR","BRA"})
  aadd(_O001, {"","084",stod(""),stod(""),"BZ","BLZ"})
  aadd(_O001, {"    ","086",stod(""),stod(""),"IO","IOT"})
  aadd(_O001, {" ","090",stod(""),stod(""),"SB","SLB"})
  aadd(_O001, {" , ","092",stod(""),stod(""),"VG","VGB"})
  aadd(_O001, {"-","096",stod(""),stod(""),"BN","BRN"})
  aadd(_O001, {"","100",stod(""),stod(""),"BG","BGR"})
  aadd(_O001, {"","104",stod(""),stod(""),"MM","MMR"})
  aadd(_O001, {"","108",stod(""),stod(""),"BI","BDI"})
  aadd(_O001, {"","112",stod(""),stod(""),"BY","BLR"})
  aadd(_O001, {"","116",stod(""),stod(""),"KH","KHM"})
  aadd(_O001, {"","120",stod(""),stod(""),"CM","CMR"})
  aadd(_O001, {"","124",stod(""),stod(""),"CA","CAN"})
  aadd(_O001, {"-","132",stod(""),stod(""),"CV","CPV"})
  aadd(_O001, {" ","136",stod(""),stod(""),"KY","CYM"})
  aadd(_O001, {"- ","140",stod(""),stod(""),"CF","CAF"})
  aadd(_O001, {"-","144",stod(""),stod(""),"LK","LKA"})
  aadd(_O001, {"","148",stod(""),stod(""),"TD","TCD"})
  aadd(_O001, {"","152",stod(""),stod(""),"CL","CHL"})
  aadd(_O001, {"","156",stod(""),stod(""),"CN","CHN"})
  aadd(_O001, {" ()","158",stod(""),stod(""),"TW","TWN"})
  aadd(_O001, {" ","162",stod(""),stod(""),"CX","CXR"})
  aadd(_O001, {" () ","166",stod(""),stod(""),"CC","CCK"})
  aadd(_O001, {"","170",stod(""),stod(""),"CO","COL"})
  aadd(_O001, {"","174",stod(""),stod(""),"KM","COM"})
  aadd(_O001, {"","175",stod(""),stod(""),"YT","MYT"})
  aadd(_O001, {"","178",stod(""),stod(""),"CG","COG"})
  aadd(_O001, {",  ","180",stod(""),stod(""),"CD","COD"})
  aadd(_O001, {" ","184",stod(""),stod(""),"CK","COK"})
  aadd(_O001, {"-","188",stod(""),stod(""),"CR","CRI"})
  aadd(_O001, {"","191",stod(""),stod(""),"HR","HRV"})
  aadd(_O001, {"","192",stod(""),stod(""),"CU","CUB"})
  aadd(_O001, {"","196",stod(""),stod(""),"CY","CYP"})
  aadd(_O001, {" ","203",stod(""),stod(""),"CZ","CZE"})
  aadd(_O001, {"","204",stod(""),stod(""),"BJ","BEN"})
  aadd(_O001, {"","208",stod(""),stod(""),"DK","DNK"})
  aadd(_O001, {"","212",stod(""),stod(""),"DM","DMA"})
  aadd(_O001, {" ","214",stod(""),stod(""),"DO","DOM"})
  aadd(_O001, {"","218",stod(""),stod(""),"EC","ECU"})
  aadd(_O001, {"-","222",stod(""),stod(""),"SV","SLV"})
  aadd(_O001, {" ","226",stod(""),stod(""),"GQ","GNQ"})
  aadd(_O001, {"","231",stod(""),stod(""),"ET","ETH"})
  aadd(_O001, {"","232",stod(""),stod(""),"ER","ERI"})
  aadd(_O001, {"","233",stod(""),stod(""),"EE","EST"})
  aadd(_O001, {" ","234",stod(""),stod(""),"FO","FRO"})
  aadd(_O001, {"  ()","238",stod(""),stod(""),"FK","FLK"})
  aadd(_O001, {"     ","239",stod(""),stod(""),"GS","SGS"})
  aadd(_O001, {"","242",stod(""),stod(""),"FJ","FJI"})
  aadd(_O001, {"","246",stod(""),stod(""),"FI","FIN"})
  aadd(_O001, {" ","248",stod(""),stod(""),"AX","ALA"})
  aadd(_O001, {"","250",stod(""),stod(""),"FR","FRA"})
  aadd(_O001, {" ","254",stod(""),stod(""),"GF","GUF"})
  aadd(_O001, {" ","258",stod(""),stod(""),"PF","PYF"})
  aadd(_O001, {"  ","260",stod(""),stod(""),"TF","ATF"})
  aadd(_O001, {"","262",stod(""),stod(""),"DJ","DJI"})
  aadd(_O001, {"","266",stod(""),stod(""),"GA","GAB"})
  aadd(_O001, {"","268",stod(""),stod(""),"GE","GEO"})
  aadd(_O001, {"","270",stod(""),stod(""),"GM","GMB"})
  aadd(_O001, {" , ","275",stod(""),stod(""),"PS","PSE"})
  aadd(_O001, {"","276",stod(""),stod(""),"DE","DEU"})
  aadd(_O001, {"","288",stod(""),stod(""),"GH","GHA"})
  aadd(_O001, {"","292",stod(""),stod(""),"GI","GIB"})
  aadd(_O001, {"","296",stod(""),stod(""),"KI","KIR"})
  aadd(_O001, {"","300",stod(""),stod(""),"GR","GRC"})
  aadd(_O001, {"","304",stod(""),stod(""),"GL","GRL"})
  aadd(_O001, {"","308",stod(""),stod(""),"GD","GRD"})
  aadd(_O001, {"","312",stod(""),stod(""),"GP","GLP"})
  aadd(_O001, {"","316",stod(""),stod(""),"GU","GUM"})
  aadd(_O001, {"","320",stod(""),stod(""),"GT","GTM"})
  aadd(_O001, {"","324",stod(""),stod(""),"GN","GIN"})
  aadd(_O001, {"","328",stod(""),stod(""),"GY","GUY"})
  aadd(_O001, {"","332",stod(""),stod(""),"HT","HTI"})
  aadd(_O001, {"    ","334",stod(""),stod(""),"HM","HMD"})
  aadd(_O001, {"  (- )","336",stod(""),stod(""),"VA","VAT"})
  aadd(_O001, {"","340",stod(""),stod(""),"HN","HND"})
  aadd(_O001, {"","344",stod(""),stod(""),"HK","HKG"})
  aadd(_O001, {"","348",stod(""),stod(""),"HU","HUN"})
  aadd(_O001, {"","352",stod(""),stod(""),"IS","ISL"})
  aadd(_O001, {"","356",stod(""),stod(""),"IN","IND"})
  aadd(_O001, {"","360",stod(""),stod(""),"ID","IDN"})
  aadd(_O001, {",  ","364",stod(""),stod(""),"IR","IRN"})
  aadd(_O001, {"","368",stod(""),stod(""),"IQ","IRQ"})
  aadd(_O001, {"","372",stod(""),stod(""),"IE","IRL"})
  aadd(_O001, {"","376",stod(""),stod(""),"IL","ISR"})
  aadd(_O001, {"","380",stod(""),stod(""),"IT","ITA"})
  aadd(_O001, {" `","384",stod(""),stod(""),"CI","CIV"})
  aadd(_O001, {"","388",stod(""),stod(""),"JM","JAM"})
  aadd(_O001, {"","392",stod(""),stod(""),"JP","JPN"})
  aadd(_O001, {"","398",stod(""),stod(""),"KZ","KAZ"})
  aadd(_O001, {"","400",stod(""),stod(""),"JO","JOR"})
  aadd(_O001, {"","404",stod(""),stod(""),"KE","KEN"})
  aadd(_O001, {", - ","408",stod(""),stod(""),"KP","PRK"})
  aadd(_O001, {", ","410",stod(""),stod(""),"KR","KOR"})
  aadd(_O001, {"","414",stod(""),stod(""),"KW","KWT"})
  aadd(_O001, {"","417",stod(""),stod(""),"KG","KGZ"})
  aadd(_O001, {" - ","418",stod(""),stod(""),"LA","LAO"})
  aadd(_O001, {"","422",stod(""),stod(""),"LB","LBN"})
  aadd(_O001, {"","426",stod(""),stod(""),"LS","LSO"})
  aadd(_O001, {"","428",stod(""),stod(""),"LV","LVA"})
  aadd(_O001, {"","430",stod(""),stod(""),"LR","LBR"})
  aadd(_O001, {"","434",stod(""),stod(""),"LY","LBY"})
  aadd(_O001, {"","438",stod(""),stod(""),"LI","LIE"})
  aadd(_O001, {"","440",stod(""),stod(""),"LT","LTU"})
  aadd(_O001, {"","442",stod(""),stod(""),"LU","LUX"})
  aadd(_O001, {"","446",stod(""),stod(""),"MO","MAC"})
  aadd(_O001, {"","450",stod(""),stod(""),"MG","MDG"})
  aadd(_O001, {"","454",stod(""),stod(""),"MW","MWI"})
  aadd(_O001, {"","458",stod(""),stod(""),"MY","MYS"})
  aadd(_O001, {"","462",stod(""),stod(""),"MV","MDV"})
  aadd(_O001, {"","466",stod(""),stod(""),"ML","MLI"})
  aadd(_O001, {"","470",stod(""),stod(""),"MT","MLT"})
  aadd(_O001, {"","474",stod(""),stod(""),"MQ","MTQ"})
  aadd(_O001, {"","478",stod(""),stod(""),"MR","MRT"})
  aadd(_O001, {"","480",stod(""),stod(""),"MU","MUS"})
  aadd(_O001, {"","484",stod(""),stod(""),"MX","MEX"})
  aadd(_O001, {"","492",stod(""),stod(""),"MC","MCO"})
  aadd(_O001, {"","496",stod(""),stod(""),"MN","MNG"})
  aadd(_O001, {", ","498",stod(""),stod(""),"MD","MDA"})
  aadd(_O001, {"","499",stod(""),stod(""),"ME","MNE"})
  aadd(_O001, {"","500",stod(""),stod(""),"MS","MSR"})
  aadd(_O001, {"","504",stod(""),stod(""),"MA","MAR"})
  aadd(_O001, {"","508",stod(""),stod(""),"Z","MOZ"})
  aadd(_O001, {"","512",stod(""),stod(""),"OM","OMN"})
  aadd(_O001, {"","516",stod(""),stod(""),"NA","NAM"})
  aadd(_O001, {"","520",stod(""),stod(""),"NR","NRU"})
  aadd(_O001, {"","524",stod(""),stod(""),"NP","NPL"})
  aadd(_O001, {"","528",stod(""),stod(""),"NL","NLD"})
  aadd(_O001, {"","531",stod(""),stod(""),"CW","CUW"})
  aadd(_O001, {"","533",stod(""),stod(""),"AW","ABW"})
  aadd(_O001, {"- (ญจคฅเซ ญคแช ๏ ็ แโ์)","534",stod(""),stod(""),"SX","SXM"})
  aadd(_O001, {", -  ","535",stod(""),stod(""),"BQ","BES"})
  aadd(_O001, {" ","540",stod(""),stod(""),"NC","NCL"})
  aadd(_O001, {"","548",stod(""),stod(""),"VU","VUT"})
  aadd(_O001, {" ","554",stod(""),stod(""),"NZ","NZL"})
  aadd(_O001, {"","558",stod(""),stod(""),"NI","NIC"})
  aadd(_O001, {"","562",stod(""),stod(""),"NE","NER"})
  aadd(_O001, {"","566",stod(""),stod(""),"NG","NGA"})
  aadd(_O001, {"","570",stod(""),stod(""),"NU","NIU"})
  aadd(_O001, {" ","574",stod(""),stod(""),"NF","NFK"})
  aadd(_O001, {"","578",stod(""),stod(""),"NO","NOR"})
  aadd(_O001, {"  ","580",stod(""),stod(""),"MP","MNP"})
  aadd(_O001, {"     ","581",stod(""),stod(""),"UM","UMI"})
  aadd(_O001, {",  ","583",stod(""),stod(""),"FM","FSM"})
  aadd(_O001, {" ","584",stod(""),stod(""),"MH","MHL"})
  aadd(_O001, {"","585",stod(""),stod(""),"PW","PLW"})
  aadd(_O001, {"","586",stod(""),stod(""),"PK","PAK"})
  aadd(_O001, {"","591",stod(""),stod(""),"PA","PAN"})
  aadd(_O001, {"- ","598",stod(""),stod(""),"PG","PNG"})
  aadd(_O001, {"","600",stod(""),stod(""),"PY","PRY"})
  aadd(_O001, {"","604",stod(""),stod(""),"PE","PER"})
  aadd(_O001, {"","608",stod(""),stod(""),"PH","PHL"})
  aadd(_O001, {"","612",stod(""),stod(""),"PN","PCN"})
  aadd(_O001, {"","616",stod(""),stod(""),"PL","POL"})
  aadd(_O001, {"","620",stod(""),stod(""),"PT","PRT"})
  aadd(_O001, {"-","624",stod(""),stod(""),"GW","GNB"})
  aadd(_O001, {"-","626",stod(""),stod(""),"TL","TLS"})
  aadd(_O001, {"-","630",stod(""),stod(""),"PR","PRI"})
  aadd(_O001, {"","634",stod(""),stod(""),"QA","QAT"})
  aadd(_O001, {"","638",stod(""),stod(""),"RE","REU"})
  aadd(_O001, {"","642",stod(""),stod(""),"RO","ROU"})
  aadd(_O001, {"","643",stod(""),stod(""),"RU","RUS"})
  aadd(_O001, {"","646",stod(""),stod(""),"RW","RWA"})
  aadd(_O001, {"-","652",stod(""),stod(""),"BL","BLM"})
  aadd(_O001, {" ,  , --","654",stod(""),stod(""),"SH","SHN"})
  aadd(_O001, {"-  ","659",stod(""),stod(""),"KN","KNA"})
  aadd(_O001, {"","660",stod(""),stod(""),"AI","AIA"})
  aadd(_O001, {"-","662",stod(""),stod(""),"LC","LCA"})
  aadd(_O001, {"-","663",stod(""),stod(""),"MF","MAF"})
  aadd(_O001, {"-  ","666",stod(""),stod(""),"PM","SPM"})
  aadd(_O001, {"-  ","670",stod(""),stod(""),"VC","VCT"})
  aadd(_O001, {"-","674",stod(""),stod(""),"SM","SMR"})
  aadd(_O001, {"-  ","678",stod(""),stod(""),"ST","STP"})
  aadd(_O001, {" ","682",stod(""),stod(""),"SA","SAU"})
  aadd(_O001, {"","686",stod(""),stod(""),"SN","SEN"})
  aadd(_O001, {"","688",stod(""),stod(""),"RS","SRB"})
  aadd(_O001, {"","690",stod(""),stod(""),"SC","SYC"})
  aadd(_O001, {"-","694",stod(""),stod(""),"SL","SLE"})
  aadd(_O001, {"","702",stod(""),stod(""),"SG","SGP"})
  aadd(_O001, {"","703",stod(""),stod(""),"SK","SVK"})
  aadd(_O001, {"","704",stod(""),stod(""),"VN","VNM"})
  aadd(_O001, {"","705",stod(""),stod(""),"SI","SVN"})
  aadd(_O001, {"","706",stod(""),stod(""),"SO","SOM"})
  aadd(_O001, {" ","710",stod(""),stod(""),"ZA","ZAF"})
  aadd(_O001, {"","716",stod(""),stod(""),"ZW","ZWE"})
  aadd(_O001, {"","724",stod(""),stod(""),"ES","ESP"})
  aadd(_O001, {" ","732",stod(""),stod(""),"EH","ESH"})
  aadd(_O001, {" ","728",stod(""),stod(""),"SS","SSD"})
  aadd(_O001, {"","729",stod(""),stod(""),"SD","SDN"})
  aadd(_O001, {"","740",stod(""),stod(""),"SR","SUR"})
  aadd(_O001, {"   ","744",stod(""),stod(""),"SJ","SJM"})
  aadd(_O001, {"","748",stod(""),stod(""),"SZ","SWZ"})
  aadd(_O001, {"","752",stod(""),stod(""),"SE","SWE"})
  aadd(_O001, {"","756",stod(""),stod(""),"CH","CHE"})
  aadd(_O001, {"  ","760",stod(""),stod(""),"SY","SYR"})
  aadd(_O001, {"","762",stod(""),stod(""),"TJ","TJK"})
  aadd(_O001, {"","764",stod(""),stod(""),"TH","THA"})
  aadd(_O001, {"","768",stod(""),stod(""),"TG","TGO"})
  aadd(_O001, {"","772",stod(""),stod(""),"TK","TKL"})
  aadd(_O001, {"","776",stod(""),stod(""),"TO","TON"})
  aadd(_O001, {"  ","780",stod(""),stod(""),"TT","TTO"})
  aadd(_O001, {"  ","784",stod(""),stod(""),"AE","ARE"})
  aadd(_O001, {"","788",stod(""),stod(""),"TN","TUN"})
  aadd(_O001, {"","792",stod(""),stod(""),"TR","TUR"})
  aadd(_O001, {"","795",stod(""),stod(""),"TM","TKM"})
  aadd(_O001, {"   ","796",stod(""),stod(""),"TC","TCA"})
  aadd(_O001, {"","798",stod(""),stod(""),"TV","TUV"})
  aadd(_O001, {"","800",stod(""),stod(""),"UG","UGA"})
  aadd(_O001, {"","804",stod(""),stod(""),"UA","UKR"})
  aadd(_O001, {" ","807",stod(""),stod(""),"MK","MKD"})
  aadd(_O001, {"","818",stod(""),stod(""),"EG","EGY"})
  aadd(_O001, {" ","826",stod(""),stod(""),"GB","GBR"})
  aadd(_O001, {"","831",stod(""),stod(""),"GG","GGY"})
  aadd(_O001, {"","832",stod(""),stod(""),"JE","JEY"})
  aadd(_O001, {" ","833",stod(""),stod(""),"IM","IMN"})
  aadd(_O001, {",  ","834",stod(""),stod(""),"TZ","TZA"})
  aadd(_O001, {" ","840",stod(""),stod(""),"US","USA"})
  aadd(_O001, {" , ","850",stod(""),stod(""),"VI","VIR"})
  aadd(_O001, {"-","854",stod(""),stod(""),"BF","BFA"})
  aadd(_O001, {"","858",stod(""),stod(""),"UY","URY"})
  aadd(_O001, {"","860",stod(""),stod(""),"UZ","UZB"})
  aadd(_O001, {",  ","862",stod(""),stod(""),"VE","VEN"})
  aadd(_O001, {"  ","876",stod(""),stod(""),"WF","WLF"})
  aadd(_O001, {"","882",stod(""),stod(""),"WS","WSM"})
  aadd(_O001, {"","887",stod(""),stod(""),"YE","YEM"})
  aadd(_O001, {"","894",stod(""),stod(""),"ZM","ZMB"})
  aadd(_O001, {"","895",stod(""),stod(""),"AB","ABH"})
  aadd(_O001, {" ","896",stod(""),stod(""),"OS","OST"})
  endif

  return _O001
