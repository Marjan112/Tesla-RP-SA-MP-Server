#if defined _pickups_included
    #endinput
#endif
#define _pickup_included

#pragma library Pickups

#if !defined _samp_included
    #include <float>
    native CreatePickup(model, type, Float: X, Float: Y, Float: Z, virtualworld = 0);
    native Create3DTextLabel(text[], color, Float: X, Float: Y, Float: Z, Float: DrawDistance, virtualworld = 0, testLOS = 0);
#endif

stock CallPickups() {
    CreatePickup(19133, 1, 1943.4155,-1767.3209,13.3906);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 1943.4155,-1767.3209,13.3906, 10.0, 0);
	CreatePickup(19133, 1, 1943.2670,-1774.3669,13.3906);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 1943.2670,-1774.3669,13.3906, 10.0, 0);
	CreatePickup(19133, 1, 605.0720,1704.5323,6.5634);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 605.0720,1704.5323,6.5634, 10.0, 0);
	CreatePickup(19133, 1, 608.8611,1700.0101,6.5656);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 608.8611,1700.0101,6.5656, 10.0, 0);
	CreatePickup(19133, 1, 611.7049,1694.6202,6.5492);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 611.7049,1694.6202,6.5492, 10.0, 0);
	CreatePickup(19133, 1, 615.9272,1690.4963,6.5688);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 615.9272,1690.4963,6.5688, 10.0, 0);
	CreatePickup(19133, 1, 619.3588,1685.4036,6.5654);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 619.3588,1685.4036,6.5654, 10.0, 0);
	CreatePickup(19133, 1, 621.6530,1679.8074,6.5675);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 621.6530,1679.8074,6.5675, 10.0, 0);
	CreatePickup(19133, 1, -87.4072,-1163.9280,2.3447);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, -87.4072,-1163.9280,2.3447, 10.0, 0);
	CreatePickup(19133, 1, -92.0625,-1175.3973,2.3264);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, -92.0625,-1175.3973,2.3264, 10.0, 0);
	CreatePickup(19133, 1,-95.7507,-1174.4496,2.4173);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, -95.7507,-1174.4496,2.4173, 10.0, 0);
	CreatePickup(19133, 1, -91.2888,-1162.3960,2.3622);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, -91.2888,-1162.3960,2.3622, 10.0, 0);
	CreatePickup(19133, 1, 1004.2919,-939.7656,42.2797);
	Create3DTextLabel("{ffffff}Da bi ste napunili gorivo\n{03adfc}/toci", -1, 1004.2919,-939.7656,42.2797, 10.0, 0);

	CreatePickup(1239, 1, 1561.0580,-2227.5750,13.5469);
	Create3DTextLabel("{03adfc}[ RENT ]\n{ffffff}Da bi ste rentali vozilo {03adfc}/rent", -1, 1561.0580,-2227.5750,13.5469, 10.0, 0);
	CreatePickup(1239, 1, 1282.4895,-1265.0306,13.6425);
	Create3DTextLabel("{03adfc}[ RENT ]\n{ffffff}Da bi ste rentali vozilo {03adfc}/rent", -1, 1282.4895,-1265.0306,13.6425, 10.0, 0);

	CreatePickup(19132, 1, 1555.5020,-1675.6063,16.1953);
	Create3DTextLabel("{03adfc}[{ffffff}Policijska Stanica{03adfc}]\n{ffffff}Da bi ste usli u policijsku stanicu pretisnite {03adfc}F {ffffff}ili {03adfc}Enter", -1, 1555.5020,-1675.6063,16.1953, 7, 0);
	CreatePickup(19132, 1, 2244.6240,-1664.3992,15.4766);
	Create3DTextLabel("{fcfc09}[{ffffff}Binco{fcfc09}]\n{ffffff}Da bi ste usli u {fcfc09}Binco {ffffff}pretisnite {fcfc09}F {ffffff}ili {fcfc09}Enter", -1, 2244.6240,-1664.3992,15.4766, 7, 0);
	CreatePickup(19132, 1, 216.9796,-100.5289,1005.2578);
	Create3DTextLabel("Da kupite neku odecu ili obucu kliknite {fcfc09}Enter", -1, 216.9796,-100.5289,1005.2578, 7, 0);
	CreatePickup(19132, 1, 1457.0255,-1009.9204,26.8438);
	Create3DTextLabel("{00ff00}[ {ffffff}BANKA {00ff00}]\n{ffffff}Da bi ste usli u banku pretisnite {00ff00}Enter {ffffff}ili {00ff00}F", -1, 1457.0255,-1009.9204,26.8438, 7, 0);
	CreatePickup(19132, 1, 1325.1090,-1709.0313,13.6395);
	Create3DTextLabel("{00ff00}[ {ffffff}BANKA {00ff00}]\n{ffffff}Da bi ste usli u banku pretisnite {00ff00}Enter {ffffff}ili {00ff00}F", -1, 1325.1090,-1709.0313,13.6395, 7, 0);

	CreatePickup(19132, 1, 1368.9985,-1279.7140,13.5469);
	Create3DTextLabel("{696969}[ {ffffff}AMMU-NATION {696969}]\n{ffffff}Da bi ste usli u ammu-nation pretinsite {696969}Enter {ffffff}ili {696969}F", -1, 1368.9985,-1279.7140,13.5469, 5, 0);

	CreatePickup(1239, 1, 2316.6213,-7.2423,26.7422);
	Create3DTextLabel("Da bi ste napravili racun\nu banci kucajte {00ff00}/otvoriracun", -1, 2316.6213,-7.2423,26.7422, 7, 0);
	CreatePickup(1239, 1, 2316.6208,-9.9597,26.7422);
	Create3DTextLabel("Da bi ste uzeli kredit kucajte\n{00ff00}/kredit", -1, 2316.6208,-9.9597,26.7422, 7, 0);
	CreatePickup(1239, 1, 2316.6211,-12.6467,26.7422);
	Create3DTextLabel("Da bi ste stavili novac iz banke kucajte\n{00ff00}/deposit", -1, 2316.6211,-12.6467,26.7422, 5, 0);
	CreatePickup(1239, 1, 2316.6213,-15.4728,26.7422);
	Create3DTextLabel("Da bi ste uzeli novac u banci kucajte\n{00ff00}/withdraw", -1, 2316.6213,-15.4728,26.7422, 5, 0);
	CreatePickup(19132, 1, 1172.0773,-1323.3525,15.4030);

	CreatePickup(1239, 1, 1103.7693,1048.0475,-19.9389);
	Create3DTextLabel("Da bi ste napravili racun\nu banci kucajte {00ff00}/otvoriracun", -1, 1103.7693,1048.0475,-19.9389, 7, 0);
	CreatePickup(1239, 1, 1103.7697,1051.5986,-19.9389);
	Create3DTextLabel("Da bi ste uzeli kredit kucajte\n{00ff00}/kredit", -1, 1103.7697,1051.5986,-19.9389, 7, 0);
	CreatePickup(1239, 1, 1103.7705,1055.1908,-19.9389);
	Create3DTextLabel("Stavljate novac pomocu {00ff00}/deposit\n{ffffff}Uzimate novac pomocu {00ff00}/withdraw", -1, 1103.7705,1055.1908,-19.9389, 5, 0);

	Create3DTextLabel("{ff0000}[ {ffffff}Bolnica {ff0000}]\n{ffffff}Da bi ste usli u bolnicu pretisnite {ff0000}Enter {ffffff}ili {ff0000}F", -1, 1172.0773,-1323.3525,15.4030, 5, 0);
	CreatePickup(19132, 1, 1402.7065,-39.0211,1000.8640);
	Create3DTextLabel("Da bi ste pricali sa bolnicarom pretisnite {ff0000}SPACE", -1, 1402.7065,-39.0211,1000.8640, 5, 0);
	CreatePickup(19132, 1, 1481.0361,-1772.3120,18.7958);
	Create3DTextLabel("{ffff00}[ {ffffff}Vlada {ffff00}]\n{ffffff}Da bi ste usli u vladu pretsnite {ffff00}Enter {ffffff}ili {ffff00}F", -1, 1481.0361,-1772.3120,18.7958, 5, 0);
	
	CreatePickup(1239, 1, 361.8299,173.6672,1008.3828);
	Create3DTextLabel("Da bi videli listu poslova kucajte\n{ffff00}/listaposlova", -1, 361.8299,173.6672,1008.3828, 5, 0);
	CreatePickup(1239, 1, 358.2364,168.9949,1008.3828);
	Create3DTextLabel("Da bi ste dali otkaz kucajte\n{ffff00}/quitjob", -1, 358.2364,168.9949,1008.3828, 5, 0);
	CreatePickup(1239, 1, 358.2361,178.6533,1008.3828);
	Create3DTextLabel("Da bi ste se zaposlili kucajte\n{ffff00}/getajob", -1, 358.2361,178.6533,1008.3828, 5, 0);
	
	CreatePickup(19132, 1, 1286.8000,-1329.2859,13.6546);
	Create3DTextLabel("{ffff00}[ {ffffff}FIB {ffff00}]\n{ffffff}Da bi ste usli u FIB stanicu pretisnite {ffff00}Enter {ffffff}ili {ffff00}F", -1, 1286.8000,-1329.2859,13.6546, 5, 0);
	CreatePickup(19132, 1, 1219.1619,-1811.7039,16.5938);
	Create3DTextLabel("{03adfc}[ {ffffff}BUS STANICA {03adfc}]\n{ffffff}Da bi ste usli u bus stanicu pretisnite {03adfc}Enter {ffffff}ili {03adfc}F", -1, 1219.1619,-1811.7039,16.5938, 5, 0);

	CreatePickup(1239, 1, 1101.9955,1064.0131,-22.3529);
	Create3DTextLabel("Da bi ste zapoceli pljacku\n/pokrenipljacku", -1, 1101.9955,1064.0131,-22.3529, 6.5, 0);

	CreatePickup(1239, 1, 1248.8230,-800.9311,84.1406);
	Create3DTextLabel("Da bi ste usli u garazu pretisnite H ili C", -1, 1248.8230,-800.9311,84.1406, 10, 0);

	//Za auto salon
	CreatePickup(1239, 1, 2261.4954,-1919.0536,13.5508);
	Create3DTextLabel("Da bi ste videli listu dostupnih voizla\nukucajte /dostupnavozila", -1, 2261.4954,-1919.0536,13.5508, 5, 0, 1);

	//Za ammu-nation
	CreatePickup(1239, 1, 291.3272,-106.2224,1001.5156);
	Create3DTextLabel("Da bi ste kupili neko oruzje pretisnite {696969}SPACE", -1, 291.3272,-106.2224,1001.5156, 5.0, 0, 0);
}