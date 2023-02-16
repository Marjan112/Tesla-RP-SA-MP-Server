#if defined _save_included
    #endinput
#endif
#define _save_included

#pragma library Save

#if !defined _structures_included
    #tryinclude "../include/data/structures.inc"
#endif

#include "../include/data/g_var.inc"

stock SaveVehicles(id) {
	new vfile[64];
	format(vfile, sizeof(vfile), VEHPATH, id);
	new INI:File = INI_Open(vfile);
	INI_WriteInt(File, "Engine", VehInfo[id][vEngine]);
	INI_WriteInt(File, "Lights", VehInfo[id][vLights]);
	INI_WriteInt(File, "Alarm", VehInfo[id][vAlarm]);
	INI_WriteInt(File, "Door", VehInfo[id][vDoor]);
	INI_WriteInt(File, "Bonnet", VehInfo[id][vBonnet]);
	INI_WriteInt(File, "Boot", VehInfo[id][vBoot]);
	INI_WriteInt(File, "Obj", VehInfo[id][vObj]);
	INI_WriteInt(File, "Fuel", VehInfo[id][vFuel]);
	INI_WriteInt(File, "Lock", VehInfo[id][vLock]);
	INI_WriteString(File, "Owner", VehInfo[id][vOwner]);
	INI_WriteFloat(File, "X", VehInfo[id][vX]);
	INI_WriteFloat(File, "Y", VehInfo[id][vY]);
	INI_WriteFloat(File, "Z", VehInfo[id][vZ]);
	INI_WriteFloat(File, "RX", VehInfo[id][vRX]);
	INI_WriteFloat(File, "RY", VehInfo[id][vRY]);
	INI_WriteFloat(File, "RZ", VehInfo[id][vRZ]);
	INI_Close(File);
}

stock SaveHouse(id) {
	new hfile[64];
	format(hfile, sizeof(hfile), HOUSEPATH, id);
	new INI:File = INI_Open(hfile);
	INI_WriteString(File, "Owner", HouseInfo[id][hOwner]);
	INI_WriteInt(File, "Owned", HouseInfo[id][hOwned]);
	INI_WriteInt(File, "Cena", HouseInfo[id][hCena]);
	INI_WriteInt(File, "Level", HouseInfo[id][hLevel]);
	INI_WriteInt(File, "Neaktivnost", HouseInfo[id][hNeaktivnost]);
	INI_WriteFloat(File, "X", HouseInfo[id][hX]);
	INI_WriteFloat(File, "Y", HouseInfo[id][hY]);
	INI_WriteFloat(File, "Z", HouseInfo[id][hZ]);
	INI_WriteInt(File, "InterID", HouseInfo[id][hInterID]);
	INI_WriteFloat(File, "InterX", HouseInfo[id][hInterX]);
	INI_WriteFloat(File, "InterY", HouseInfo[id][hInterY]);
	INI_WriteFloat(File, "InterZ", HouseInfo[id][hInterZ]);
	INI_WriteString(File, "Rent", HouseInfo[id][hRent]);
	INI_WriteInt(File, "Rented", HouseInfo[id][hRented]);
	INI_WriteString(File, "OnRent", HouseInfo[id][hOnRent]);
	INI_WriteInt(File, "VirtualWorld", HouseInfo[id][hVirtualWorld]);
	INI_Close(File);
}

stock SaveOrg(id) {
	new org_file[64];
	format(org_file, sizeof(org_file), ORGPATH, id);
	new INI:File = INI_Open(org_file);
	INI_WriteString(File, "Ime", OrgInfo[id][orgIme]);
	INI_WriteString(File, "Leader", OrgInfo[id][orgLeader]);
	INI_WriteString(File, "Member1", OrgInfo[id][orgMember1]);
	INI_WriteString(File, "Member2", OrgInfo[id][orgMember2]);
	INI_WriteString(File, "Member3", OrgInfo[id][orgMember3]);
	INI_WriteString(File, "Member4", OrgInfo[id][orgMember4]);
	INI_WriteString(File, "Member5", OrgInfo[id][orgMember5]);
	INI_WriteString(File, "Member6", OrgInfo[id][orgMember6]);
	INI_WriteString(File, "Member7", OrgInfo[id][orgMember7]);
	INI_WriteString(File, "Member8", OrgInfo[id][orgMember8]);
	INI_WriteString(File, "Member9", OrgInfo[id][orgMember9]);
	INI_WriteString(File, "Member10", OrgInfo[id][orgMember10]);
	INI_WriteString(File, "Member11", OrgInfo[id][orgMember11]);
	INI_WriteString(File, "Member12", OrgInfo[id][orgMember12]);
	INI_WriteString(File, "Member13", OrgInfo[id][orgMember13]);
	INI_WriteString(File, "Member14", OrgInfo[id][orgMember14]);
	INI_WriteString(File, "Member15", OrgInfo[id][orgMember15]);
	INI_WriteString(File, "Member16", OrgInfo[id][orgMember16]);
	INI_WriteString(File, "Member17", OrgInfo[id][orgMember17]);
	INI_WriteString(File, "Member18", OrgInfo[id][orgMember18]);
	INI_WriteString(File, "Member19", OrgInfo[id][orgMember19]);
	INI_WriteString(File, "Member20", OrgInfo[id][orgMember20]);
	INI_WriteString(File, "Member21", OrgInfo[id][orgMember21]);
	INI_WriteString(File, "Member22", OrgInfo[id][orgMember22]);
	INI_WriteString(File, "Member23", OrgInfo[id][orgMember23]);
	INI_WriteString(File, "Member24", OrgInfo[id][orgMember24]);
	INI_WriteString(File, "Member25", OrgInfo[id][orgMember25]);
	INI_WriteString(File, "Member26", OrgInfo[id][orgMember26]);
	INI_WriteString(File, "Member27", OrgInfo[id][orgMember27]);
	INI_WriteString(File, "Member28", OrgInfo[id][orgMember28]);
	INI_WriteString(File, "Member29", OrgInfo[id][orgMember29]);
	INI_WriteString(File, "Member30", OrgInfo[id][orgMember30]);
	INI_WriteString(File, "Member31", OrgInfo[id][orgMember31]);
	INI_WriteString(File, "Member32", OrgInfo[id][orgMember32]);
	INI_WriteString(File, "Member33", OrgInfo[id][orgMember33]);
	INI_WriteString(File, "Member34", OrgInfo[id][orgMember34]);
	INI_WriteString(File, "Member35", OrgInfo[id][orgMember35]);
	INI_WriteString(File, "Member36", OrgInfo[id][orgMember36]);
	INI_WriteString(File, "Member37", OrgInfo[id][orgMember37]);
	INI_WriteString(File, "Member38", OrgInfo[id][orgMember38]);
	INI_WriteString(File, "Member39", OrgInfo[id][orgMember39]);
	INI_WriteString(File, "Member40", OrgInfo[id][orgMember40]);
	INI_WriteString(File, "Member41", OrgInfo[id][orgMember41]);
	INI_WriteString(File, "Member42", OrgInfo[id][orgMember42]);
	INI_WriteString(File, "Member43", OrgInfo[id][orgMember43]);
	INI_WriteString(File, "Member44", OrgInfo[id][orgMember44]);
	INI_WriteString(File, "Member45", OrgInfo[id][orgMember45]);
	INI_WriteString(File, "Member46", OrgInfo[id][orgMember46]);
	INI_WriteString(File, "Member47", OrgInfo[id][orgMember47]);
	INI_WriteString(File, "Member48", OrgInfo[id][orgMember48]);
	INI_WriteString(File, "Member49", OrgInfo[id][orgMember49]);
	INI_WriteString(File, "Member50", OrgInfo[id][orgMember50]);
	INI_WriteInt(File, "Money", OrgInfo[id][orgMoney]);
	INI_WriteInt(File, "Mats", OrgInfo[id][orgMats]);
	INI_WriteInt(File, "Drugs", OrgInfo[id][orgDrugs]);
	INI_WriteString(File, "Drzavna", OrgInfo[id][orgDrzavna]);
	INI_WriteInt(File, "Glock19", OrgInfo[id][orgGlock19]);
	INI_WriteInt(File, "AK_47", OrgInfo[id][orgAK_47]);
	INI_WriteInt(File, "M4", OrgInfo[id][orgM4]);
	INI_WriteInt(File, "Lisice", OrgInfo[id][orgLisice]);
	INI_WriteFloat(File, "X", OrgInfo[id][orgX]);
	INI_WriteFloat(File, "Y", OrgInfo[id][orgY]);
	INI_WriteFloat(File, "Z", OrgInfo[id][orgZ]);
	INI_Close(File);
}

stock SaveVr(id) {
	new vr_file[64];
	format(vr_file, sizeof(vr_file), VRPATH, id);
	new INI:File = INI_Open(vr_file);
	INI_WriteBool(File, "Zakljucano", ZakljucanaVrata[id]);
	INI_WriteBool(File, "Zatvoreno", ZatvorenaVrata[id]);
	INI_Close(File);
}

stock SaveProm(id) {
	new prom_file[64];
	format(prom_file, sizeof(prom_file), PROMPATH, id);
	new INI:File = INI_Open(prom_file);
	INI_WriteString(File, "Name", PromInfo[id][promName]);
	INI_WriteInt(File, "Duty", PromInfo[id][promDuty]);
	INI_WriteInt(File, "Neaktivnost", PromInfo[id][promNeaktivnost]);
	INI_Close(File);
}

stock SaveBanned(id) {
	new b_file[64];
	format(b_file, sizeof(b_file), BANPATH, id);
	new INI:File = INI_Open(b_file);
	INI_WriteString(File, "Name", BannedInfo[id][bName]);
	INI_Close(File);
}

stock Sacuvaj(playerid, ime[128]) {
	new upath[128];
	format(upath, sizeof(upath), USERPATH, ime);
	new INI:File = INI_Open(upath);
	INI_SetTag(File, "data");
 	INI_WriteInt(File, "Novac", PlayerInfo[playerid][pNovac]);
 	INI_WriteInt(File, "Godine", PlayerInfo[playerid][pGodine]);
	INI_WriteInt(File, "Respekti", PlayerInfo[playerid][pRespekti]);
	INI_WriteInt(File, "NeededRep", PlayerInfo[playerid][pNeededRep]);
 	INI_WriteInt(File, "Admin", PlayerInfo[playerid][pAdmin]);
 	INI_WriteInt(File, "Ban", PlayerInfo[playerid][pBan]);
 	INI_WriteString(File, "BanRazlog", PlayerInfo[playerid][pBanRazlog]);
	INI_WriteString(File, "Promoter", PlayerInfo[playerid][pPromoter]);
	INI_WriteFloat(File, "SpawnX", PlayerInfo[playerid][pSpawnX]);
	INI_WriteFloat(File, "SpawnY", PlayerInfo[playerid][pSpawnY]);
	INI_WriteFloat(File, "SpawnZ", PlayerInfo[playerid][pSpawnZ]);
	INI_WriteFloat(File, "SpawnAng", PlayerInfo[playerid][pSpawnAng]);
	INI_WriteInt(File, "SpawnInter", PlayerInfo[playerid][pSpawnInter]);
	INI_WriteInt(File, "Kuca", PlayerInfo[playerid][pKuca]);
	INI_WriteInt(File, "Leader", PlayerInfo[playerid][pLeader]);
	INI_WriteString(File, "Organizacija", PlayerInfo[playerid][pOrganizacija]);
	INI_WriteInt(File, "RentHouse", PlayerInfo[playerid][pRentHouse]);
	INI_WriteString(File, "Racun", PlayerInfo[playerid][pRacun]);
	INI_WriteInt(File, "Banka", PlayerInfo[playerid][pBanka]);
	INI_WriteInt(File, "Rate", PlayerInfo[playerid][pRate]);
	INI_WriteInt(File, "Kredit", PlayerInfo[playerid][pKredit]);
	INI_WriteInt(File, "Cigare", PlayerInfo[playerid][pCigare]);
	INI_WriteInt(File, "Hrana", PlayerInfo[playerid][pHrana]);
	INI_WriteInt(File, "Voda", PlayerInfo[playerid][pVoda]);
	INI_WriteInt(File, "Panciri", PlayerInfo[playerid][pPanciri]);
	INI_WriteInt(File, "Droga", PlayerInfo[playerid][pDroga]);
	INI_WriteInt(File, "Lisice", PlayerInfo[playerid][pLisice]);
	INI_WriteString(File, "Posao", PlayerInfo[playerid][pPosao]);
	INI_WriteInt(File, "Glock19Municija", PlayerInfo[playerid][pGlock19Municija]);
	INI_WriteInt(File, "AK_47Municija", PlayerInfo[playerid][pAK_47Municija]);
	INI_WriteInt(File, "M4Municija", PlayerInfo[playerid][pM4Municija]);
	INI_WriteString(File, "VozackaDozvola", PlayerInfo[playerid][pVozackaDozvola]);
	INI_WriteString(File, "Zatvoren", PlayerInfo[playerid][pZatvoren]);
	INI_WriteString(File, "Zavezan", PlayerInfo[playerid][pZavezan]);
	INI_WriteInt(File, "Skin", PlayerInfo[playerid][pSkin]);
	INI_WriteString(File, "IP", PlayerInfo[playerid][pIP]);
	INI_WriteInt(File, "Auto", PlayerInfo[playerid][pAuto]);
	INI_WriteInt(File, "Auto1", PlayerInfo[playerid][pAuto1]);
	INI_WriteInt(File, "Auto2", PlayerInfo[playerid][pAuto2]);
	INI_WriteInt(File, "Auto3", PlayerInfo[playerid][pAuto3]);
	INI_WriteInt(File, "Auto4", PlayerInfo[playerid][pAuto4]);
	INI_WriteInt(File, "Auto5", PlayerInfo[playerid][pAuto5]);
	INI_WriteInt(File, "Auto6", PlayerInfo[playerid][pAuto6]);
	INI_WriteInt(File, "Auto7", PlayerInfo[playerid][pAuto7]);
	INI_WriteInt(File, "Sniper", PlayerInfo[playerid][pSniper]);
	INI_WriteInt(File, "SniperMunicija", PlayerInfo[playerid][pSniperMunicija]);
	INI_Close(File);
}

stock SavePlayer(playerid) {
	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File, "data");
 	INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
 	INI_WriteInt(File, "Godine", GetPlayerScore(playerid));
	INI_WriteInt(File, "Respekti", PlayerInfo[playerid][pRespekti]);
	INI_WriteInt(File, "NeededRep", PlayerInfo[playerid][pNeededRep]);
 	INI_WriteInt(File, "Admin", PlayerInfo[playerid][pAdmin]);
	INI_WriteInt(File, "Ban", PlayerInfo[playerid][pBan]);
 	INI_WriteString(File, "BanRazlog", PlayerInfo[playerid][pBanRazlog]);
	INI_WriteString(File, "Promoter", PlayerInfo[playerid][pPromoter]);
	INI_WriteFloat(File, "SpawnX", PlayerInfo[playerid][pSpawnX]);
	INI_WriteFloat(File, "SpawnY", PlayerInfo[playerid][pSpawnY]);
	INI_WriteFloat(File, "SpawnZ", PlayerInfo[playerid][pSpawnZ]);
	INI_WriteFloat(File, "SpawnAng", PlayerInfo[playerid][pSpawnAng]);
	INI_WriteInt(File, "SpawnInter", GetPlayerInterior(playerid));
	INI_WriteInt(File, "Kuca", PlayerInfo[playerid][pKuca]);
	INI_WriteString(File, "Organizacija", PlayerInfo[playerid][pOrganizacija]);
	INI_WriteInt(File, "Leader", PlayerInfo[playerid][pLeader]);
	INI_WriteInt(File, "RentHouse", PlayerInfo[playerid][pRentHouse]);
	INI_WriteString(File, "Racun", PlayerInfo[playerid][pRacun]);
	INI_WriteInt(File, "Banka", PlayerInfo[playerid][pBanka]);
	INI_WriteInt(File, "Rate", PlayerInfo[playerid][pRate]);
	INI_WriteInt(File, "Kredit", PlayerInfo[playerid][pKredit]);
	INI_WriteInt(File, "Cigare", PlayerInfo[playerid][pCigare]);
	INI_WriteInt(File, "Hrana", PlayerInfo[playerid][pHrana]);
	INI_WriteInt(File, "Voda", PlayerInfo[playerid][pVoda]);
	INI_WriteInt(File, "Panciri", PlayerInfo[playerid][pPanciri]);
	INI_WriteInt(File, "Droga", PlayerInfo[playerid][pDroga]);
	INI_WriteInt(File, "Lisice", PlayerInfo[playerid][pLisice]);
	INI_WriteString(File, "Posao", PlayerInfo[playerid][pPosao]);
	INI_WriteInt(File, "Glock19", PlayerInfo[playerid][pGlock19]);
	INI_WriteInt(File, "AK_47", PlayerInfo[playerid][pAK_47]);
	INI_WriteInt(File, "M4", PlayerInfo[playerid][pM4]);
	INI_WriteInt(File, "Glock19Municija", PlayerInfo[playerid][pGlock19Municija]);
	INI_WriteInt(File, "AK_47Municija", PlayerInfo[playerid][pAK_47Municija]);
	INI_WriteInt(File, "M4Municija", PlayerInfo[playerid][pM4Municija]);
	INI_WriteString(File, "VozackaDozvola", PlayerInfo[playerid][pVozackaDozvola]);
	INI_WriteString(File, "Zatvoren", PlayerInfo[playerid][pZatvoren]);
	INI_WriteString(File, "Zavezan", PlayerInfo[playerid][pZavezan]);
	INI_WriteInt(File, "Skin", GetPlayerSkin(playerid));
	INI_WriteString(File, "IP", PlayerInfo[playerid][pIP]);
	INI_WriteInt(File, "Auto", PlayerInfo[playerid][pAuto]);
	INI_WriteInt(File, "Auto1", PlayerInfo[playerid][pAuto1]);
	INI_WriteInt(File, "Auto2", PlayerInfo[playerid][pAuto2]);
	INI_WriteInt(File, "Auto3", PlayerInfo[playerid][pAuto3]);
	INI_WriteInt(File, "Auto4", PlayerInfo[playerid][pAuto4]);
	INI_WriteInt(File, "Auto5", PlayerInfo[playerid][pAuto5]);
	INI_WriteInt(File, "Auto6", PlayerInfo[playerid][pAuto6]);
	INI_WriteInt(File, "Auto7", PlayerInfo[playerid][pAuto7]);
	INI_WriteInt(File, "Sniper", PlayerInfo[playerid][pSniper]);
	INI_WriteInt(File, "SniperMunicija", PlayerInfo[playerid][pSniperMunicija]);
	INI_Close(File);
}

stock SaveAdmin(id) {
	new a_file[64];
	format(a_file, sizeof(a_file), ADMINPATH, id);
	new INI:File = INI_Open(a_file);
	INI_WriteString(File, "Name", AdminInfo[id][aName]);
	INI_WriteInt(File, "Neaktivnost", AdminInfo[id][aNeaktivnost]);
	INI_WriteInt(File, "Duty", AdminInfo[id][aDuty]);
	INI_Close(File);
}