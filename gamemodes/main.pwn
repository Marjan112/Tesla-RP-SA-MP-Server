///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma compress 0
//UBACIVANJE POTREBNIH BIBLIOTEKA
#include <a_samp>
#include <YSI\y_ini>
#include <YSI\y_iterate>
#include <sscanf2>
#include <streamer>
#include <zcmd>
#include "../gamemodes/data/structures.inc"
#include "../gamemodes/data/tags.inc"
////////////////////////////////////////////////////
#define ALL MAX_PLAYERS + MAX_PLAYERS
#define HOUSE 1
#define ORG 2
#define VEH 3
#define BANIP 4
#define SNEG 0
//--------------- DEFINISANJE MAKROA ---------------
#define function%1(%2) forward %1(%2); public %1(%2)
#define IsPlayerPoliceman(%1) !strcmp(PlayerInfo[%1][pOrganizacija], "LSPD") || !strcmp(PlayerInfo[%1][pOrganizacija], "FIB")
#define IsPlayerVillian(%1) !strcmp(PlayerInfo[%1][pOrganizacija], "Zemunski Klan") || !strcmp(PlayerInfo[%1][pOrganizacija], "Crveni") || !strcmp(PlayerInfo[%1][pOrganizacija], "Yakuza")
////////////////////////////////////////////////////
main() {
	print("--- TESLA ROLEPLAY ---");
	print("Mod je ucitan.");
}

enum {
	d_reg,
	d_log,
	d_alist,
	d_ban,
	d_stats,
	d_payday,
	d_port,
	d_rent,
	d_nevalidno_ime,
	d_promlist,
	d_orgime,
	d_orgdrzavna,
	d_orginfo,
	d_organizacije,
	d_hrentcena,
	d_bolnica,
	d_inventar,
	d_inv_oruzje,
	d_inv_org_bolnica,
	d_inv_org_fib,
	d_inv_org_lspd,
	d_inv_org_ilegalna,
	d_listaposlova,
	d_joblist,
	d_gps,
	d_gps_poslovi,
	d_prodavnica,
	d_ammu_nation,
	d_komande,
	d_dostupna_vozila,
	d_dostupna_jeftina_vozila,
	d_dostupna_skupa_vozila,
	d_askq,
	d_askq_to_admin
};

new IsPlayerSpec[MAX_PLAYERS];

new Text: lrtd[10];
new Text: sdtd[3];
new PlayerText: Fuel_t[MAX_PLAYERS][2];

new ZatvorVrata[4];
new Bool: ZakljucanaVrata[MAX_OBJECTS];
new Bool: ZatvorenaVrata[MAX_OBJECTS];

new ZemunciGate;

new rented[MAX_VEHICLES];
new renta[MAX_PLAYERS];
new rentvreme[MAX_PLAYERS];

new Float:pX[MAX_PLAYERS];
new Float:pY[MAX_PLAYERS];
new Float:pZ[MAX_PLAYERS];
new pI[MAX_PLAYERS];
new pW[MAX_PLAYERS];

new hPickup[MAX_HOUSES];
new Text3D: hLabel[MAX_HOUSES];
new orgPickup[MAX_ORGS];
new Text3D: orgLabel[MAX_ORGS];

new adminveh[MAX_PLAYERS];
new Text3D: admintext[MAX_VEHICLES];

new editaorg[MAX_PLAYERS];

// new snegobj[MAX_PLAYERS];

new policeDuty[MAX_PLAYERS];

new ACTOR[16];

new Iterator: Admins<MAX_PLAYERS>;
new Iterator: Houses<MAX_HOUSES>;
new Iterator: Orgs<MAX_ORGS>;
new Iterator: Proms<MAX_PLAYERS>;
new Iterator: Cops<MAX_PLAYERS>;
new Iterator: Fibs<MAX_PLAYERS>;
new Iterator: Yakuza<MAX_PLAYERS>;
new Iterator: Crveni<MAX_PLAYERS>;
new Iterator: Zemunski_Klan<MAX_PLAYERS>;

new UlogovanProvera[MAX_PLAYERS];

new j_bus[6];
new j_kombi[10];
new IsPlayerWorking[MAX_PLAYERS];
new jobprogress[MAX_PLAYERS];

new platatimer = 60;
new timer = 10;

new Bool: PokrenutaPljacka[MAX_PLAYERS] = false;

new RandomPoruke[][] = {
	"{03adfc}[INFO]: {ffffff}Server se ukljucuje u 11 ujutru, a iskljucuje u 23:30.",
	"{03adfc}[INFO]: {ffffff}Ako zelite da se zaposlite, morate otici na salteru za zaposljavanje u vladi!",
	"{03adfc}[INFO]: {ffffff}Platu ce te dobiti na svakih 60 minuta.",
	"{03adfc}[INFO]: {ffffff}Ako zelite da se prijavite za neku organizaciju morate uci u kanal za zeljenu organizaciju i popuniti upitnik!",
	"{03adfc}[INFO]: {ffffff}Ako Vam treba neka pomoc, ukucajte /askq."
};

stock IC(Float: radius, playerid, color, const str[]) {
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	foreach(new i : Player) if(IsPlayerInRangeOfPoint(i, radius, pos[0], pos[1], pos[2])) SCM(i, color, str);
	return 0;
}

stock CreateTransparentObject(modelid, Float:X, Float:Y, Float:Z, Float:rX=0.0, Float:rY=0.0, Float:rZ=0.0) {
    new obj_ID = CreateObject(modelid, X, Y, Z, rX, rY, rZ);
    for(new i; i< 10; i++) SetObjectMaterial(obj_ID, i, 0, "none", "none", 0x00000000);
    return obj_ID;
}
//19381
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
	INI_Close(File);
}

stock ProxDetectorf(Float: _radius_, playerid, const msg[], va_args<>) {
    new string[1024];
    va_format(string, sizeof(string), msg, va_start<3>);
	ProxDetector(_radius_, playerid, string);
}

stock Float:GetDistanceBetweenPoints(Float:pos1X, Float:pos1Y, Float:pos1Z, Float:pos2X, Float:pos2Y, Float:pos2Z) {
	return floatadd(floatadd(floatsqroot(floatpower(floatsub(pos1X, pos2X), 2)), floatsqroot(floatpower(floatsub(pos1Y, pos2Y), 2))), floatsqroot(floatpower(floatsub(pos1Z, pos2Z), 2)));
}

stock Float: SpeedVehicle(playerid) {
	new Float: ST[4];
	if (IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), ST[0], ST[1], ST[2]);
	else GetPlayerVelocity(playerid, ST[0], ST[1], ST[2]);
	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 180.0;
	return ST[3];
}

stock WeaponName(wid) {
	new str[128];
	GetWeaponName(wid, str, sizeof(str));
	return str;
}

stock SnijegObjekti(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
	new object = CreateDynamicObject(modelid, x + 0.05, y + 0.075, z + 0.1, rx, ry, rz, -1, -1, -1, 300.0, 0.0);
	for(new a = 0; a < 30; a++) SetDynamicObjectMaterial(object, a, 17944, "lngblok_lae2", "white64bumpy", 0);
	return object;
}

stock NisteOvlasceni(playerid) {
	SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	return 1;
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

stock NewID(tip) {
	new id = -1, len;
	switch(tip) {
		case HOUSE: {
			len = MAX_HOUSES;
			for(new loop = (0), check = (-1), Data_[64] = "\0"; loop != len; ++loop) {
				check = (loop + 1);
				format(Data_, sizeof(Data_), HOUSEPATH, check);
				if(!fexist(Data_)) {
					id = (check);
					break;
				}
			}
		}
		case ORG: {
			len = MAX_ORGS;
			for(new loop = (0), check = (-1), Data_[64] = "\0"; loop != len; ++loop) {
				check = (loop + 1);
				format(Data_, sizeof(Data_), ORGPATH, check);
				if(!fexist(Data_)) {
					id = (check);
					break;
				}
			}
		}
		case VEH: {
			len = MAX_VEHICLES;
			for(new loop = (0), check = (-1), Data_[64] = "\0"; loop != len; ++loop) {
				check = (loop + 1);
				format(Data_, sizeof(Data_), VEHPATH, check);
				if(!fexist(Data_)) {
					id = (check);
					break;
				}
			}
		}
	}
	return (id);
}

stock SaveVr(id) {
	new vr_file[64];
	format(vr_file, sizeof(vr_file), VRPATH, id);
	new INI:File = INI_Open(vr_file);
	INI_WriteBool(File, "Zakljucano", ZakljucanaVrata[id]);
	INI_WriteBool(File, "Zatvoreno", ZatvorenaVrata[id]);
	INI_Close(File);
}

stock UzetPromSlot(id) {
	new str[128];
	format(str, sizeof(str), "Niko");
	if(!strcmp(str, PromInfo[id][promName])) return false;
	return true;
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

stock ProveraRPImena(playerid)
{
    new pname[MAX_PLAYER_NAME],underline=0;
    GetPlayerName(playerid, pname, sizeof(pname));
    if(strfind(pname,"[",true) != (-1)) return 0;
    else if(strfind(pname,"]",true) != (-1)) return 0;
    else if(strfind(pname,"$",true) != (-1)) return 0;
    else if(strfind(pname,"(",true) != (-1)) return 0;
    else if(strfind(pname,")",true) != (-1)) return 0;
    else if(strfind(pname,"=",true) != (-1)) return 0;
    else if(strfind(pname,"@",true) != (-1)) return 0;
    else if(strfind(pname,"1",true) != (-1)) return 0;
    else if(strfind(pname,"2",true) != (-1)) return 0;
    else if(strfind(pname,"3",true) != (-1)) return 0;
    else if(strfind(pname,"4",true) != (-1)) return 0;
    else if(strfind(pname,"5",true) != (-1)) return 0;
    else if(strfind(pname,"6",true) != (-1)) return 0;
    else if(strfind(pname,"7",true) != (-1)) return 0;
    else if(strfind(pname,"8",true) != (-1)) return 0;
    else if(strfind(pname,"9",true) != (-1)) return 0;
    else if(strfind(pname,".",true) != (-1)) return 0;
    else if(strfind(pname,",",true) != (-1)) return 0;
    else if(strfind(pname,"-",true) != (-1)) return 0;
	else if(strfind(pname, "YT", true) != (-1)) return 0;
	else if(strfind(pname, "yT", true) != (-1)) return 0;
	else if(strfind(pname, "Yt", true) != (-1)) return 0;
	else if(strfind(pname, "Gamer", true) != (-1)) return 0;
	else if(strfind(pname, "gAMer", true) != (-1)) return 0;
    new maxname = strlen(pname);
    for(new i = 0; i < maxname; i++) 
    {
       if(pname[i] == '_') underline ++;
    }
    if(underline != 1) return 0;
    pname[0] = toupper(pname[0]);
    for(new x = 1; x < maxname; x++)
    {
        if(pname[x] == '_') pname[x + 1] = toupper(pname[x + 1]);
        else if(pname[x] != '_' && pname[x - 1] != '_') pname[x] = tolower(pname[x]);
    }
	return 1;
}

stock UpdateBubble(playerid) {
	new str[128];
	if(pADuty[playerid]) {
		if(PlayerInfo[playerid][pAdmin] == 1) format(str, sizeof(str), "{03adfc}PROBNI ADMIN");
		if(PlayerInfo[playerid][pAdmin] == 2) format(str, sizeof(str), "{03adfc}ADMIN");
		if(PlayerInfo[playerid][pAdmin] == 3) format(str, sizeof(str), "{03adfc}HEAD ADMIN");
		if(PlayerInfo[playerid][pAdmin] == 4) format(str, sizeof(str), "{03adfc}SCRIPTER");
		if(PlayerInfo[playerid][pAdmin] == 5) format(str, sizeof(str), "{03adfc}VLASNIK");
		SetPlayerColor(playerid, PLAVA_NEBO);
	}
	if(PDuty[playerid]) {
		if(!strcmp(PlayerInfo[playerid][pPromoter], "Da")) format(str, sizeof(str), "{ffa500}PROMOTER");
		SetPlayerColor(playerid, NARANDZASTA);
	}
	SetPlayerChatBubble(playerid, str, -1, 30, 1000);
}

stock GETIP(playerid) {
	new IP[32];
	GetPlayerIp(playerid, IP, sizeof(IP));
	return IP;
}

stock UzetBanSlot(id) {
	new str[128];
	format(str, sizeof(str), "Niko");
	if(!strcmp(BannedInfo[id][bName], str)) return false;
	return true;
}

stock SaveBanned(id) {
	new b_file[64];
	format(b_file, sizeof(b_file), BANPATH, id);
	new INI:File = INI_Open(b_file);
	INI_WriteString(File, "Name", BannedInfo[id][bName]);
	INI_Close(File);
}

stock ClearChat(id = ALL, l = 500) {
	for(new i = 0; i < l; i++) {
		if(id == ALL) SCMTA(-1, " ");
		else SCM(id, -1, " ");
	}
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
	INI_Close(File);
}

stock GetPlayerID(name[]) {
	new ime[128];
	for(new i = 0; i <= MAX_PLAYERS; i++) {
		GetPlayerName(i, ime, sizeof(ime));
		if(!strcmp(name, ime)) return i;
	}
	return -1;
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
	INI_Close(File);
}

stock UzetSlot(id) {
	new str[128];
	format(str, sizeof(str), "Niko");
	if(!strcmp(AdminInfo[id][aName], str)) return false;
	return true;
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

stock GetName(playerid) {
	new str[128], name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	format(str, sizeof(str), name);
	return str;
}

stock UserPath(playerid) {
	new string[128],playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid,playername,sizeof(playername));
	format(string,sizeof(string),USERPATH,playername);
	return string;
}

stock udb_hash(buf[]) {
	new length=strlen(buf);
	new s1 = 1;
	new s2 = 0;
	new n;
	for (n=0; n<length; n++)
	{
		s1 = (s1 + buf[n]) % 65521;
		s2 = (s2 + s1)     % 65521;
	}
	return (s2 << 16) + s1;
}

public OnGameModeInit() {
//-----------------------------------------------------------
	SetGameModeText("Tesla Roleplay by Maki");
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	AddPlayerClass(6, 1682.4265,-2246.7871,13.5507,183.6684, 0, 0, 0, 0, 0, 0);
	AddStaticVehicle(487, 1291.1667,-788.3718,96.4609, 146.8603, 194, 0);
//----------------------- VOZILA ----------------------------
	//J_BUS -> JOB_BUS
	j_bus[0] = AddStaticVehicle(431, 1275.6406, -1796.2198, 13.5000, -89.8200, -1, -1);
	j_bus[1] = AddStaticVehicle(431, 1275.6406, -1803.0000, 13.5000, -89.8200, -1, -1);
	j_bus[2] = AddStaticVehicle(431, 1275.6406, -1810.0000, 13.5000, -89.8200, -1, -1);
	j_bus[3] = AddStaticVehicle(431, 1275.6406, -1817.0000, 13.5000, -89.8200, -1, -1);
	j_bus[4] = AddStaticVehicle(431, 1275.6406, -1824.0000, 13.5000, -89.8200, -1, -1);
	j_bus[5] = AddStaticVehicle(431, 1275.6406, -1831.0000, 13.5000, -89.8200, -1, -1);
	
	//J_KOMBI -> JOB_KOMBI
	j_kombi[0] = AddStaticVehicle(498, 1526.0002, -1012.4600, 23.9562, -130.0000, 128, -1);
	j_kombi[1] = AddStaticVehicle(498, 1528.6698, -1009.3649, 23.9562, -130.0000, 128, -1);
	j_kombi[2] = AddStaticVehicle(498, 1531.5457, -1006.1431, 23.9562, -130.0000, 128, -1);
	j_kombi[3] = AddStaticVehicle(498, 1537.2740, -1005.4114, 23.9562, 180.0000, 128, -1);
	j_kombi[4] = AddStaticVehicle(498, 1541.4963, -1005.6569, 23.9562, 180.0000, 128, -1);
	j_kombi[5] = AddStaticVehicle(498, 1545.5612, -1005.9648, 23.9562, 180.0000, 128, -1);
	j_kombi[6] = AddStaticVehicle(498, 1549.2892, -1006.9203, 23.9562, 180.0000, 128, -1);
	j_kombi[7] = AddStaticVehicle(498, 1523.5182, -1025.3003, 23.9562, -90.0000, 128, -1);
	j_kombi[8] = AddStaticVehicle(498, 1523.5408, -1021.5369, 23.9562, -90.0000, 128, -1);
	j_kombi[9] = AddStaticVehicle(498, 1523.5670, -1017.6931, 23.9562, -90.0000, 128, -1);
//----------------------- Timeri ----------------------------
	SetTimer("Fuel", 60000, true);
	SetTimer("PayDay", 3600000, true);
	SetTimer("Time", 100, true);
	SetTimer("CarUpdate", 1000, true);
	SetTimer("RandomMessages", 2700000, true);
//----------------------- Pickup i Label ----------------------------
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
//----------------------- Mape ----------------------------
	ZemunciGate = CreateDynamicObject(975, 1245.65881, -766.94067, 92.77000,   0.00000, 0.00000, 0.00000);
	//Za Zemunci
	CreateDynamicObject(19458, 1260.461791, -779.182739, 81.483238, 0.000000, 93.000015, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1263.654541, -779.238342, 81.359886, 0.099945, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1267.153930, -779.230590, 81.354347, 1.399945, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1270.604492, -779.206848, 81.210151, 1.199946, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1274.072875, -779.187011, 81.095367, 1.099946, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1277.551513, -779.165649, 81.000442, 1.299944, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1280.951782, -779.137573, 80.927986, 1.299945, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1284.431884, -779.124572, 80.862510, 1.599946, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1284.377929, -769.474243, 81.006042, -0.000052, -88.400001, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1280.889404, -769.495544, 81.091247, -0.000055, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1277.440551, -769.516540, 81.175476, 0.099945, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1274.181274, -769.536804, 81.245018, -0.100054, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1270.714111, -769.555847, 81.329795, -0.300054, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1267.235595, -769.578857, 81.394760, -0.400054, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1263.835937, -769.599609, 81.457778, -0.100052, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19458, 1260.398559, -769.620605, 81.591735, 0.199945, -88.600051, 0.300000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -769.330932, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -766.171020, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -772.460937, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -775.550781, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -778.491027, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -781.551208, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1285.977416, -782.301330, 82.421730, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1284.495483, -783.803894, 82.432983, -0.799998, 2.599994, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1281.285888, -783.787048, 82.477806, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(24, 1281.644042, -773.797668, 82.945053, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1278.135864, -783.770568, 82.521766, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1274.956420, -783.753967, 82.566162, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1271.756713, -783.737060, 82.610832, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1268.677001, -783.720947, 82.653854, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1265.606567, -783.704528, 82.696746, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1262.457153, -783.688232, 82.740737, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(353, 1262.704711, -778.164672, 82.423149, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1260.347167, -783.677368, 82.770202, -0.799997, 2.599993, -90.300018, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1258.902465, -781.969177, 82.838981, 1.399999, 2.499994, -1.500033, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1258.979370, -779.020996, 82.911010, 1.399999, 2.499994, -1.500033, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1259.059936, -775.922973, 82.986694, 1.399999, 2.499994, -1.500033, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1259.142333, -772.775207, 83.063629, 1.399999, 2.499994, -1.500033, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1259.223510, -769.677246, 83.139320, 1.399999, 2.499994, -1.500033, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19358, 1259.306274, -766.529174, 83.216232, 1.399999, 2.499994, -1.500033, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19786, 1273.265747, -785.108154, 1090.574462, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2028, 1275.201782, -785.604248, 1090.303710, 0.000000, 0.000000, -28.500017, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1836, 1269.821411, -786.044372, 1083.007812, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1836, 1273.001220, -786.044372, 1083.007812, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1836, 1276.181518, -786.044372, 1083.007812, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1836, 1278.711303, -786.044372, 1083.007812, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1271.073852, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1268.543090, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1269.193237, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1269.833496, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1270.443603, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1271.744018, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1272.334228, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1272.954345, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1273.644531, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1274.175048, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1274.844970, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1275.495361, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1276.155639, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1276.815917, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1277.446166, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1278.036743, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1278.716430, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1279.306396, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2350, 1279.946289, -786.612609, 1083.014892, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19893, 1231.728759, -809.809509, 1083.778320, 0.000000, 0.000000, 165.599960, -1, -1, -1, 300.00, 300.00); 
	ZatvorVrata[0] = CreateDynamicObject(19302, 1265.842651, -775.345886, 1084.255981, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	ZatvorVrata[1] = CreateDynamicObject(19302, 1261.842773, -775.345886, 1084.255981, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1723, 1264.316284, -771.831359, 1090.906250, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1723, 1274.296630, -771.781311, 1090.906250, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1723, 1285.306396, -771.781311, 1090.906250, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(628, 1261.727294, -772.170410, 1092.856567, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(628, 1270.366088, -772.170410, 1092.856567, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(628, 1280.965576, -772.170410, 1092.856567, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(367, 1232.150268, -809.874816, 1083.827514, 0.000000, 0.000000, 103.400016, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19787, 1276.313110, -794.226989, 1084.328857, 0.000000, 0.000000, 179.799957, -1, -1, -1, 300.00, 300.00);
	//CreateDynamicObject(19302, 1265.842651, -775.345886, 1081.783569, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	//CreateDynamicObject(19302, 1261.842773, -775.345886, 1081.754028, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	//Za milicajci
	CreateDynamicObject(19521, 255.897979, 75.929763, 1004.759521, -0.999996, -90.499938, 86.100021, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2616, 229.354537, 82.517768, 1005.979431, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2356, 240.171127, 78.796409, 1004.039062, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2356, 240.171127, 81.336402, 1004.039062, 2.000000, 0.000000, 179.200027, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19908, 226.328948, 76.626838, 1004.199218, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2180, 217.235153, 66.673233, 1004.039062, 0.000000, 0.000000, 90.499908, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2356, 251.433700, 67.420555, 1002.640625, 0.000000, 0.000000, 93.700004, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19893, 250.637100, 67.537124, 1003.870727, 0.000000, 0.000000, 57.300010, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2180, 217.225662, 68.642250, 1004.017211, 0.000000, 0.199999, 89.300003, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2180, 217.252609, 70.603401, 1004.039062, 0.000000, 0.000000, 89.899971, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(334, 216.934738, 66.636886, 1004.827026, 90.300010, 2.500004, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(11749, 217.354095, 66.440971, 1004.841491, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(18637, 217.261672, 67.409873, 1004.796691, -0.200000, -16.299997, -2.299999, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19141, 217.001449, 67.931938, 1004.912658, -39.399929, -90.800041, -89.099952, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(346, 217.377334, 69.131072, 1004.874206, -89.600036, -2.499999, 84.700004, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(356, 217.306915, 70.851745, 1004.890991, -82.700065, 12.899977, 94.100082, -1, -1, -1, 300.00, 300.00); 
	//zatvor
	ZatvorVrata[2] = CreateDynamicObject(19302, 266.395690, 87.476341, 1001.319213, 0.000000, 0.000000, 89.799964, -1, -1, -1, 300.00, 300.00); 
	// CreateDynamicObject(19302, 266.395690, 87.476341, 998.878662, 0.000000, 0.000000, 89.799964, -1, -1, -1, 300.00, 300.00); 
	ZatvorVrata[3] = CreateDynamicObject(19302, 266.379943, 82.966346, 1001.319213, 0.000000, 0.000000, 89.799964, -1, -1, -1, 300.00, 300.00); 
	// CreateDynamicObject(19302, 266.379943, 82.966346, 998.878601, 0.000000, 0.000000, 89.799964, -1, -1, -1, 300.00, 300.00); 
	//bolnica enterijer
	new bolnica;
	bolnica = CreateDynamicObject(1649, 1404.309448, -27.373491, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1397.645385, -27.373292, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(19381, 1402.732788, -34.017120, 1007.366088, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1396.169555, -28.200950, 1005.163635, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1400.976318, -27.373491, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1407.640502, -27.373491, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(19377, 1404.488891, -25.240951, 1005.163635, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1394.859130, -25.240951, 1005.163635, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1397.645385, -31.813295, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1400.975830, -31.813295, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14758, "sfmansion1", "AH_flroortile6", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1404.306274, -31.813295, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14758, "sfmansion1", "AH_flroortile6", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1407.635742, -31.813295, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1407.635742, -36.253280, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1404.305786, -36.253280, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14758, "sfmansion1", "AH_flroortile6", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1400.975830, -36.253280, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14758, "sfmansion1", "AH_flroortile6", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1397.647094, -36.253280, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1397.651000, -40.696590, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1400.983032, -40.696590, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1404.315063, -40.696590, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(1649, 1407.646240, -40.696590, 999.864013, 270.000000, 270.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 15055, "svlamid", "AH_flroortile3", 0xB4FFFFFF);
	bolnica = CreateDynamicObject(19360, 1396.164916, -34.610271, 1004.925048, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1396.169555, -41.020984, 1005.163635, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.279907, -41.020984, 1005.163635, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1409.274902, -34.610271, 1004.925048, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.279296, -28.190950, 1005.163635, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19376, 1390.857543, -34.373466, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18031, "cj_exp", "mp_furn_floor", 0x00000000);
	bolnica = CreateDynamicObject(19376, 1380.375610, -34.373466, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18031, "cj_exp", "mp_furn_floor", 0x00000000);
	bolnica = CreateDynamicObject(18809, 1402.669555, -44.951599, 1031.034545, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
	bolnica = CreateDynamicObject(19376, 1425.009887, -34.373466, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18031, "cj_exp", "mp_furn_floor", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1404.478881, -42.620971, 1005.163635, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1400.907104, -42.630970, 1005.163635, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1392.412719, -38.067108, 1006.465515, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1397.568481, -34.020980, 1011.633422, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 2423, "cj_ff_counters", "CJ_Laminate1", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1407.898071, -34.020980, 1011.633422, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 2423, "cj_ff_counters", "CJ_Laminate1", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1403.168457, -38.750949, 1011.633422, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 2423, "cj_ff_counters", "CJ_Laminate1", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1402.307617, -38.760948, 1011.633422, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 2423, "cj_ff_counters", "CJ_Laminate1", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1402.297607, -29.280946, 1011.633422, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 2423, "cj_ff_counters", "CJ_Laminate1", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1403.167968, -29.270946, 1011.633422, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 2423, "cj_ff_counters", "CJ_Laminate1", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1392.412719, -28.447111, 1006.465515, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1413.043701, -28.447111, 1006.465515, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1413.043701, -38.057125, 1006.465515, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1402.554077, -43.477142, 1006.465393, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1402.554077, -24.557146, 1006.465393, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1403.973144, -47.327140, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1393.473510, -47.327140, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1391.033691, -41.007144, 999.975280, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1391.033691, -28.207153, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1401.463867, -20.527153, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1411.933349, -20.527153, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1424.922485, -28.197170, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1414.432983, -40.997192, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19376, 1414.516845, -34.373466, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18031, "cj_exp", "mp_furn_floor", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1414.158203, -44.094821, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1381.658081, -44.094821, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1391.309326, -25.354824, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1380.532836, -28.207153, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1380.543579, -41.007144, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1381.670654, -25.354824, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1414.432983, -28.197170, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1424.914184, -40.997192, 999.985290, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1376.839111, -39.224811, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1376.839111, -29.594829, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1381.427124, -25.394859, 1006.954833, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1423.788940, -44.094821, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1414.139404, -25.354824, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1423.760498, -25.354824, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1428.571044, -30.174802, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1428.571044, -39.804821, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1413.043701, -39.257106, 1006.435485, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1413.033691, -38.057117, 1006.455505, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1425.005004, -29.627101, 1006.435485, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1414.524047, -39.257106, 1006.415466, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1390.845703, -39.257106, 1006.435485, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1390.845703, -29.637132, 1006.435485, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1380.356933, -29.637132, 1006.435485, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1380.356933, -39.267131, 1006.435485, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.281860, -28.204809, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.281860, -41.004840, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.458007, -28.214809, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.458007, -41.004806, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(14793, 1402.967163, -28.154233, 1007.144775, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1414.623046, -28.197170, 999.995300, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(644, 1427.372924, -34.577136, 1000.344482, 0.000000, 0.000000, -39.900005, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 4003, "cityhall_tr_lan", "foliage256", 0xFFFFFF66);
	bolnica = CreateDynamicObject(1897, 1409.225097, -36.259738, 1001.014587, 0.000000, 0.000007, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.225097, -36.259738, 1002.064514, 0.000000, 0.000007, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.325195, -36.259738, 1001.014587, 0.000000, 0.000007, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.325195, -36.259738, 1002.064636, 0.000000, 0.000007, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.103271, -36.259738, 1001.014587, 0.000000, 0.000014, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.103271, -36.259738, 1002.064514, 0.000000, 0.000014, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.203369, -36.259738, 1001.014587, 0.000000, 0.000014, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.203369, -36.259738, 1002.064636, 0.000000, 0.000014, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.223388, -32.949741, 1001.014587, 0.000000, 0.000014, 179.999893, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.223388, -32.949741, 1002.064514, 0.000000, 0.000014, 179.999893, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.123291, -32.949741, 1001.014587, 0.000000, 0.000014, 179.999893, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.123291, -32.949741, 1002.064636, 0.000000, 0.000014, 179.999893, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.123291, -32.949741, 1002.064636, 0.000000, 0.000014, 179.999893, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.334472, -32.949741, 1001.014587, 0.000000, 0.000007, 179.999847, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.334472, -32.949741, 1002.064514, 0.000000, 0.000007, 179.999847, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.234375, -32.949741, 1001.014587, 0.000000, 0.000007, 179.999847, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.234375, -32.949741, 1002.064636, 0.000000, 0.000007, 179.999847, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.334106, -34.084712, 1003.250610, -89.999992, -424.263793, 115.736152, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.334106, -35.134639, 1003.250610, -89.999992, -424.263793, 115.736152, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.234008, -34.114711, 1003.250610, -89.999992, -424.263793, 115.736152, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1409.234008, -35.094760, 1003.250610, -89.999992, -424.263793, 115.736152, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.228881, -34.124710, 1003.250610, -89.999992, -436.513366, 103.486541, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.228881, -35.084640, 1003.250610, -89.999992, -436.513366, 103.486541, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.128784, -34.084712, 1003.250610, -89.999992, -436.513366, 103.486541, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(1897, 1396.128784, -35.084762, 1003.250610, -89.999992, -436.513366, 103.486541, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1391.287841, -44.094821, 1005.225097, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1381.427124, -44.064933, 1006.954833, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1391.297119, -44.064933, 1006.954833, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(18075, 1402.866699, -24.739551, 1006.293823, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14786, "ab_sfgymbeams", "knot_wood128", 0x00000000);
	bolnica = CreateDynamicObject(18809, 1402.669555, -44.961597, 1028.945190, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18065, "ab_sfammumain", "shelf_glas", 0xFFCCFFFF);
	bolnica = CreateDynamicObject(19377, 1396.147216, -40.964931, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.297241, -28.214809, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.287841, -41.004806, 1005.225097, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.466552, -40.964931, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.286376, -40.964931, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.286376, -28.214942, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.476562, -28.214942, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.426513, -28.234943, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1376.846435, -30.264940, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1376.846435, -39.894962, 1006.954833, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1381.578247, -44.054821, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1391.267944, -44.054821, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1391.267944, -25.424825, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1381.419067, -25.424825, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1376.848022, -30.214836, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1396.127563, -28.184843, 1006.965393, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1376.848022, -39.714836, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1396.147583, -34.364868, 1008.385864, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.477050, -40.964843, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.306884, -40.964843, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.276855, -40.964843, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1391.256591, -25.394859, 1006.954833, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.276855, -28.224836, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.487060, -28.244836, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1386.416992, -28.244836, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1414.534545, -29.627101, 1006.415466, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1424.993408, -39.257106, 1006.415466, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_laglasswall2", 0x00000000);
	bolnica = CreateDynamicObject(2184, 1403.783935, -39.854305, 999.864013, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
	bolnica = CreateDynamicObject(2184, 1406.133178, -41.593799, 999.864013, 0.000000, 0.000000, 137.599960, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
	bolnica = CreateDynamicObject(2184, 1400.871093, -40.164043, 999.864013, 0.000000, 0.000000, -137.199996, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
	bolnica = CreateDynamicObject(631, 1408.669799, -41.977016, 1000.803955, 0.000000, 0.000000, -32.099994, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 17958, "burnsalpha", "plantb256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1396.751342, -41.985996, 1000.803955, 0.000000, 0.000000, -32.099994, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 17958, "burnsalpha", "plantb256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(1722, 1409.109863, -36.651313, 999.864013, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1409.109863, -37.281314, 999.864013, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1409.109863, -37.911300, 999.864013, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1409.109863, -38.531288, 999.864013, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1409.109863, -39.161273, 999.864013, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1396.379638, -36.581264, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1396.379638, -37.211257, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1396.379638, -37.841243, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1396.379638, -38.461242, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(1722, 1396.379638, -39.091236, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 18996, "mattextures", "sampwhite", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 19426, "all_walls", "vgsn_scrollsgn256", 0x00000000);
	bolnica = CreateDynamicObject(638, 1407.083496, -25.834327, 1000.584472, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 16136, "des_telescopestuff", "stoneclad1", 0x00000000);
	bolnica = CreateDynamicObject(638, 1398.364379, -25.834327, 1000.584472, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 16136, "des_telescopestuff", "stoneclad1", 0x00000000);
	bolnica = CreateDynamicObject(19538, 1384.041259, -54.108524, 999.864013, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, -1, "none", "none", 0x00FFFFFF);
	bolnica = CreateDynamicObject(19377, 1396.107421, -30.264833, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1396.107421, -39.884849, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.287597, -28.184843, 1006.965393, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.287597, -37.784854, 1008.415893, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.287597, -41.004837, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.268188, -40.994827, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.288208, -40.994842, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1428.559326, -39.204826, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1428.559326, -29.584835, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.269409, -28.214839, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.309448, -28.214839, 1006.965637, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1414.079589, -25.364812, 1006.965637, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1423.699462, -25.364812, 1006.965637, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1414.179565, -44.084785, 1006.965637, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1423.789184, -44.084785, 1006.965637, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14581, "ab_mafiasuitea", "walp45S", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1414.157836, -25.374824, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1423.758300, -25.374824, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1414.150024, -44.064823, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1423.770141, -44.064823, 1011.195129, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1428.541503, -39.284839, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1428.541503, -29.654846, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.241333, -28.224853, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.331420, -28.224853, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.331420, -40.984893, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1418.261352, -40.984889, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.321044, -39.174877, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19377, 1409.321044, -29.604871, 1011.195129, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(631, 1396.748291, -26.681325, 1000.803955, 0.000000, 0.000000, -92.499992, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 17958, "burnsalpha", "plantb256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1408.747314, -26.776283, 1000.803955, 0.000000, 0.000000, -48.200031, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 17958, "burnsalpha", "plantb256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(2266, 1408.690429, -32.152095, 1002.214294, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 3899, "hospital2", "hospitalboard_128a", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1409.257690, -32.123214, 1002.124206, 360.000000, 90.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1414.623779, -40.997192, 999.995300, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1390.903564, -41.007144, 999.995300, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(19381, 1390.963623, -28.207153, 999.995300, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14623, "mafcasmain", "casino_carp", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1409.257690, -37.073215, 1002.124206, 360.000000, 90.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1409.257690, -37.073215, 1002.124206, 360.000000, 90.000000, 450.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1409.257690, -32.123214, 1002.124206, 360.000000, 90.000000, 450.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1396.157714, -32.123214, 1002.124206, 360.000000, 90.000000, 450.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1396.157714, -37.133262, 1002.124206, 360.000000, 90.000000, 450.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1396.157714, -37.133262, 1002.124206, 360.000000, 90.000000, 630.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(1649, 1396.157714, -32.123214, 1002.124206, 360.000000, 90.000000, 630.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 8496, "lowbuild03_lvs", "vgshopwall03_64", 0xAAFFFFFF);
	SetDynamicObjectMaterial(bolnica, 1, 8396, "sphinx01", "luxorceiling02_128", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.265136, -33.781269, 1002.294494, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.265136, -33.781269, 1003.244995, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.265136, -35.421241, 1003.244995, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.265136, -35.421241, 1002.294494, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -35.451240, 1002.294494, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -35.451240, 1003.504577, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -33.781246, 1003.504577, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -33.781246, 1002.304138, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19172, 1402.670288, -42.516544, 1002.884460, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 19962, "samproadsigns", "streetsign", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "white", 0x00000000);
	bolnica = CreateDynamicObject(19329, 1402.715820, -42.495586, 1003.164428, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterialText(bolnica, 0, "{ffffff} LOS SANTOS", 80, "Ariel", 45, 1, 0x00000000, 0x00000000, 1);
	bolnica = CreateDynamicObject(19329, 1402.715820, -42.495586, 1002.633911, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterialText(bolnica, 0, "{ffffff} Central Hospital", 80, "Ariel", 39, 1, 0x00000000, 0x00000000, 1);
	bolnica = CreateDynamicObject(19325, 1424.206787, -33.043136, 1002.011718, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1412.677734, -33.043136, 1006.151489, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1412.677734, -33.043136, 1002.031494, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1419.316772, -33.043136, 1006.131469, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1425.957519, -33.043136, 1006.131469, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1430.847045, -33.043136, 1002.011718, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19087, 1416.002563, -33.040210, 1002.424987, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1416.002563, -33.040210, 1004.105285, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1416.002563, -33.040210, 1004.085266, 0.000000, 90.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1418.443847, -33.040210, 1004.085266, 0.000000, 90.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1420.894042, -33.040210, 1001.634948, 0.000000, 180.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1420.894042, -33.040210, 999.824401, 0.000000, 180.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1428.471923, -33.043037, 1007.007507, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1428.451782, -33.043037, 1013.307434, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1409.421020, -33.043037, 1013.307434, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1409.390991, -33.043037, 1007.326965, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1416.732543, -33.043037, 1006.316589, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1423.981323, -33.043037, 1006.316589, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1430.603637, -33.043037, 1006.316589, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19325, 1412.677734, -36.163082, 1002.031494, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1424.329345, -36.163082, 1002.031494, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1430.958618, -36.163082, 1002.031494, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1412.677734, -36.163082, 1006.151672, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1419.313964, -36.163082, 1006.151672, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1425.954467, -36.163082, 1006.151672, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19087, 1416.002563, -36.170200, 1004.105285, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1416.002563, -36.170200, 1002.424987, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1421.023437, -36.170200, 1002.424987, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1421.023437, -36.170200, 1004.104797, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1421.033447, -36.170200, 1004.104797, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1418.441894, -36.170200, 1004.104797, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1419.772460, -36.170200, 1004.104797, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1409.421020, -36.163032, 1013.307434, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1409.390991, -36.163032, 1007.296997, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1428.462524, -36.163032, 1007.296997, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1428.623046, -36.163032, 1006.317260, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1421.382568, -36.163032, 1006.317260, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1416.621704, -36.163032, 1006.317260, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19325, 1392.757080, -33.063129, 1002.061462, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1380.047607, -33.063129, 1002.061462, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1380.036499, -36.143123, 1002.061462, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1392.775634, -36.143123, 1002.061462, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1392.757080, -33.063129, 1006.181396, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1386.118164, -33.063129, 1006.181396, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1379.477905, -33.063129, 1006.181396, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1392.775634, -36.143123, 1006.181884, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1386.136474, -36.143123, 1006.181884, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19325, 1379.497192, -36.143123, 1006.181884, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 9583, "bigshap_sfw", "boatfunnel1_128", 0xC8FFFFFF);
	bolnica = CreateDynamicObject(19087, 1389.452270, -33.060207, 1002.424987, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1389.452270, -33.060207, 1004.165405, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1383.371093, -33.060207, 1004.165405, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1383.371093, -33.060207, 1002.484924, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1383.371093, -36.160194, 1002.484924, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1383.371093, -36.160194, 1004.144958, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1385.822021, -33.060207, 1004.135375, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1388.193115, -33.060207, 1004.135375, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1389.464233, -33.060207, 1004.135375, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1389.464233, -36.150199, 1004.135375, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1387.054199, -36.150199, 1004.135375, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1385.833251, -36.150199, 1004.135375, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1389.451293, -36.160194, 1002.484924, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1389.451293, -36.160194, 1004.155395, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1376.948120, -33.073032, 1007.195983, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1376.948120, -36.143013, 1007.195983, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1396.020263, -36.143013, 1013.295166, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1396.050292, -36.143013, 1007.194702, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1396.050292, -33.062984, 1007.194702, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1396.010253, -33.062984, 1013.295410, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1396.230346, -33.062984, 1006.324584, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1389.339355, -33.062984, 1006.324584, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1382.101318, -33.062984, 1006.324584, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1384.151000, -36.142951, 1006.324584, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1391.251586, -36.142951, 1006.324584, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(19089, 1396.083007, -36.142951, 1006.324584, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(644, 1378.202392, -34.656024, 1000.344482, 0.000000, 0.000000, -39.900005, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 4003, "cityhall_tr_lan", "planta256", 0xFFFFFF66);
	bolnica = CreateDynamicObject(19087, 1396.145385, -31.341234, 1002.774475, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -35.451274, 1002.774475, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -35.451274, 1000.244079, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -31.321271, 1000.244079, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.244262, -31.321271, 1002.764770, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.244262, -35.421295, 1002.764770, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.246582, -35.411277, 1000.244079, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.246582, -31.321277, 1000.244079, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -35.451274, 1002.634399, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1396.145385, -31.321279, 1002.634399, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.254638, -31.321279, 1002.634033, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19087, 1409.254638, -35.411296, 1002.634033, 0.000000, 90.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 13816, "lahills_safe1", "gry_roof", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1413.622192, -25.410261, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1423.142700, -25.410261, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1391.141845, -25.410261, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1381.522827, -25.410261, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1394.264892, -39.992561, 1000.104919, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1389.365600, -39.992561, 1000.104919, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1384.773193, -39.992561, 1000.104919, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1379.723876, -39.992561, 1000.104919, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1378.733886, -29.292543, 1000.104919, 0.000000, 0.000000, 1800.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1383.464721, -29.292543, 1000.104919, 0.000000, 0.000000, 1800.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1388.085693, -29.292543, 1000.104919, 0.000000, 0.000000, 1800.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1393.226074, -29.292543, 1000.104919, 0.000000, 0.000000, 1800.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(631, 1395.609497, -36.793190, 1001.031982, 0.000000, 0.000000, -82.600006, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14832, "lee_stripclub", "Strip_plant", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1395.419311, -32.563217, 1001.031982, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 17958, "burnsalpha", "plantb256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1377.729248, -32.563217, 1001.031982, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14832, "lee_stripclub", "Strip_plant", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1377.729248, -36.743232, 1001.031982, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 17958, "burnsalpha", "plantb256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(19360, 1391.332031, -44.000278, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1381.622192, -44.000278, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1413.782348, -43.940338, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(19360, 1423.593139, -43.940338, 1003.734863, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 3979, "civic01_lan", "sl_dwntwnshpfrnt1", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1412.256469, -39.992561, 1000.104919, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1421.017700, -39.992561, 1000.104919, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1420.017822, -29.222560, 1000.104919, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(1797, 1411.077880, -29.222560, 1000.104919, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 1, 10765, "airportgnd_sfse", "black64", 0x00000000);
	bolnica = CreateDynamicObject(631, 1409.883666, -36.949317, 1001.001464, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 4003, "cityhall_tr_lan", "foliage256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1409.883666, -32.529312, 1001.001464, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 4003, "cityhall_tr_lan", "foliage256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1427.964477, -32.529312, 1001.001464, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 14832, "lee_stripclub", "Strip_plant", 0xFFCCFF33);
	bolnica = CreateDynamicObject(631, 1427.964477, -36.779304, 1001.001464, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 0, 4003, "cityhall_tr_lan", "planta256", 0xFFCCFF33);
	bolnica = CreateDynamicObject(948, 1424.987670, -25.878849, 1000.071228, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 2, 4003, "cityhall_tr_lan", "foliage256", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 3, 3881, "apsecurity_sfxrf", "lostonclad1", 0xFFFFFFFF);
	bolnica = CreateDynamicObject(948, 1417.799072, -29.308860, 1000.071228, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 2, 4830, "airport2", "bevflower2", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 3, 3881, "apsecurity_sfxrf", "lostonclad1", 0xFFFFFFFF);
	bolnica = CreateDynamicObject(948, 1413.447998, -43.448860, 1000.071228, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 2, 4830, "airport2", "kbplanter_plants1", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 3, 3881, "apsecurity_sfxrf", "lostonclad1", 0xFFFFFFFF);
	bolnica = CreateDynamicObject(948, 1418.688720, -39.968872, 1000.071228, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	SetDynamicObjectMaterial(bolnica, 2, 4992, "airportdetail", "bevflower1", 0x00000000);
	SetDynamicObjectMaterial(bolnica, 3, 3881, "apsecurity_sfxrf", "lostonclad1", 0xFFFFFFFF);
	//jelka
	CreateDynamicObject(19076, 1432.422729, -830.832031, 56.613811, 9.999951, 0.899999, -0.199999, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19055, 1437.344848, -828.626953, 59.895458, 26.000009, -13.800000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19055, 1436.669677, -831.210510, 57.987468, 23.200008, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19055, 1435.979736, -833.851684, 56.583694, 23.200008, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19057, 1433.706054, -833.077880, 56.429080, 48.399993, -8.600000, -0.700000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19057, 1429.923950, -832.603393, 56.048843, 48.399993, -8.600000, -0.700000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19057, 1431.699462, -832.697570, 56.112976, 48.399993, -8.600000, -0.700000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19058, 1428.107910, -831.255004, 57.169391, 34.499992, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19058, 1430.147827, -827.429626, 60.429973, 34.499992, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19058, 1428.107910, -828.594726, 59.459304, 34.499992, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19059, 1432.155639, -832.911499, 59.495330, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19058, 1434.787719, -827.429626, 60.429973, 34.499992, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19058, 1432.158081, -827.429626, 60.429973, 34.499992, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	//fib stanica
    CreateDynamicObject(17559, 1310.222534, -1323.534790, -3.336741, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.342285, -1301.865356, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.342285, -1311.484619, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.342285, -1321.224243, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.342285, -1330.774169, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.342285, -1335.364379, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1321.587890, -1340.102783, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1312.177368, -1340.152099, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1302.558105, -1340.202148, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1298.617919, -1340.222534, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1293.881958, -1335.364379, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1293.881958, -1325.844482, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1293.881958, -1316.264282, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1293.881958, -1306.732421, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1293.881958, -1300.571899, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1298.717407, -1321.101684, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1308.318359, -1321.050048, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1317.755737, -1320.992065, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1324.407348, -1320.877563, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.701416, -1332.856933, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1315.781860, -1332.913696, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19387, 1321.134155, -1332.916625, -0.059583, 0.000000, 0.000000, -90.599983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1311.051757, -1337.664672, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1326.008789, -1333.361328, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.996337, -1333.990966, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.985107, -1334.591064, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.973388, -1335.220703, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.961547, -1335.841064, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.950195, -1336.451293, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.937866, -1337.091674, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.925781, -1337.721557, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.913208, -1338.361450, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.901611, -1338.981323, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(11729, 1325.888549, -1339.641601, -1.814133, 0.000000, 0.000000, -91.099952, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1313.432495, -1337.773681, -2.702438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1313.432495, -1337.773681, 1.787560, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1313.419555, -1339.822875, 1.830486, 88.799942, -1.099999, 1.100001, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1313.419555, -1334.742919, 1.724112, 88.799942, -1.099999, 1.100001, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19387, 1305.582275, -1332.942993, -0.059583, 0.000000, 0.000000, -90.599983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1311.820556, -1332.932739, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1299.241333, -1332.999511, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1289.631469, -1333.049804, -0.842438, 0.000000, 0.000000, -89.700126, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1309.479003, -1339.615112, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1307.478881, -1339.615112, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1305.479003, -1339.605102, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1303.479736, -1339.605102, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1301.479858, -1339.605102, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1299.389526, -1339.605102, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1297.299438, -1339.605102, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2180, 1295.319702, -1339.605102, -1.865661, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1309.938842, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1307.667968, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1305.767944, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1303.747314, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1301.657104, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1299.687255, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1297.417236, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19999, 1295.827392, -1338.705078, -1.793842, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1309.983520, -1339.491577, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1308.056884, -1339.609375, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1306.020629, -1339.733886, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1304.065063, -1339.853393, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1302.020141, -1339.678222, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1299.964233, -1339.803955, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1297.880126, -1339.630737, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1295.883666, -1339.752807, -1.075942, 0.000000, 0.000000, -176.499969, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19387, 1302.111938, -1331.465820, -0.059583, 0.000000, 0.000000, 179.700134, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1302.102050, -1325.844482, -0.842438, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2056, 1294.048583, -1331.930786, -0.260816, 0.000000, 0.000000, 91.099983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2056, 1294.015625, -1330.211425, -0.260816, 0.000000, 0.000000, 91.099983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2056, 1293.985839, -1328.661499, -0.260816, 0.000000, 0.000000, 91.099983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2056, 1294.020385, -1326.776367, -0.260816, 0.000000, 0.000000, 91.099983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2056, 1293.986572, -1324.495727, -0.260816, 0.000000, 0.000000, 91.099983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2056, 1294.052978, -1322.754272, -0.260816, 0.000000, 0.000000, 91.099983, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1299.961059, -1325.844482, -2.602437, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1299.961059, -1328.163818, -2.602437, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19054, 1303.407470, -1322.445922, -1.143917, 0.000000, 0.000000, 75.899986, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19055, 1302.987182, -1324.006469, -1.245745, 0.000000, 0.000000, -90.000007, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19057, 1304.986572, -1322.015258, -1.115745, 0.000000, 0.000000, -32.899997, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2964, 1311.635620, -1324.464355, -1.826891, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1723, 1323.195190, -1327.370239, -1.796245, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1723, 1320.075561, -1327.519165, -1.796245, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19786, 1324.097167, -1332.734619, -0.269866, 0.000000, 0.000000, 177.499984, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19054, 1325.345947, -1321.719604, -1.143917, 0.000000, 0.000000, 75.899986, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1324.679687, -1335.497680, 0.888697, 1.499999, -90.600006, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1321.340332, -1335.497314, 0.853733, 1.499999, -90.600006, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1318.030883, -1335.477783, 0.819606, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1314.601074, -1335.536621, 0.783700, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1311.242309, -1335.594726, 0.748526, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1307.833251, -1335.653442, 0.712829, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1304.353759, -1335.712524, 0.676399, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1300.944580, -1335.771484, 0.640702, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1297.535766, -1335.830078, 0.605005, 1.499999, -90.600006, 1.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1295.425170, -1335.865600, 0.582917, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1295.492431, -1326.149169, 0.837357, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1298.970703, -1326.256225, 0.921672, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1302.411621, -1326.199951, 0.909798, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1305.341430, -1326.220947, 0.940470, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1308.851928, -1326.166625, 0.979308, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1312.232055, -1326.191162, 1.014691, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1315.641235, -1326.215820, 1.050388, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1319.161499, -1326.241943, 1.087237, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1322.491943, -1326.265747, 1.122096, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1325.201904, -1326.285522, 1.150465, -1.000000, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1325.131958, -1322.195800, 1.107659, 1.900000, -90.600006, -89.000038, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1317.104858, -1322.333984, 0.991389, 0.899999, -90.800064, -86.800048, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1307.959594, -1322.489868, 1.017658, 0.400000, -90.600006, -89.000038, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1298.460815, -1322.652832, 0.972704, -0.099998, -90.600006, -89.000038, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1326.049926, -1326.741088, 1.057617, 1.499999, -90.600006, -0.399999, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19449, 1325.135986, -1322.196533, 0.987731, 1.900000, -90.600006, -89.000038, -1, -1, -1, 300.00, 300.00);
	bolnica = CreateDynamicObject(19376, 1390.857543, -44.013446, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19376, 1380.375610, -44.003425, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19376, 1414.586914, -44.003471, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19376, 1425.079956, -44.003486, 999.938903, 0.000000, 90.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(14793, 1402.967163, -39.804264, 1007.144775, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1569, 1401.232299, -25.364088, 999.864013, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1569, 1404.221923, -25.354087, 999.864013, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1409.175415, -27.706626, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1409.175415, -29.036640, 999.864013, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1409.175415, -29.036640, 1001.203735, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1396.305419, -28.046623, 999.864013, 0.000000, 0.000000, 450.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1396.305419, -29.386631, 999.864013, 0.000000, 0.000000, 450.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1396.307739, -30.502950, 999.873657, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2163, 1396.316894, -28.935007, 1001.214721, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19807, 1404.318603, -40.470829, 1000.704406, 0.000000, 0.000000, -19.200002, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2686, 1407.021240, -42.504325, 1002.144409, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2164, 1401.938964, -42.508110, 999.864013, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2162, 1403.731933, -42.535083, 999.864013, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1387.250854, -43.800529, 1000.054870, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1395.460815, -43.800529, 1000.054870, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1385.640869, -43.800529, 1000.054870, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1377.590209, -43.800529, 1000.054870, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1377.590209, -25.560518, 1000.054870, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1385.579711, -25.560518, 1000.054870, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1387.120239, -25.560518, 1000.054870, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1395.321411, -25.560518, 1000.054870, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1391.613281, -26.638280, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1381.883056, -26.638280, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1389.692504, -26.638280, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1380.332641, -26.638280, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1380.282592, -43.818264, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1382.092163, -43.818264, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1389.902832, -43.818264, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1823, 1391.683105, -43.818264, 1000.081237, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2162, 1396.027343, -29.851703, 1000.081237, 0.000000, 0.000000, 630.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1396.054565, -39.429363, 1000.081237, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1386.154052, -39.429363, 1000.081237, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1386.154052, -39.429363, 1001.421264, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2163, 1386.227050, -30.034534, 1000.084899, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1410.010375, -43.800529, 1000.054870, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1418.969726, -43.800529, 1000.054870, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1418.969726, -25.773492, 1000.054870, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2167, 1410.008666, -25.673492, 1000.054870, 0.000000, 0.000000, 360.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2166, 1417.675292, -26.133188, 1000.081237, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2166, 1427.845581, -26.133188, 1000.081237, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2166, 1427.845581, -42.333206, 1000.081237, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2166, 1417.614990, -42.333206, 1000.081237, 0.000000, 0.000000, 180.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1714, 1417.112182, -42.155689, 1000.081237, 0.000000, 0.000000, -32.599998, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1714, 1427.328369, -42.102752, 1000.081237, 0.000000, 0.000000, -32.599998, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1714, 1427.271850, -25.893779, 1000.081237, 0.000000, 0.000000, -20.999998, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(1714, 1416.914672, -25.772701, 1000.081237, 0.000000, 0.000000, -2.799996, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2164, 1409.554809, -39.153884, 1000.081237, 0.000000, 0.000000, 810.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2191, 1409.999023, -30.975894, 1000.024841, 0.000000, 0.000000, 90.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2191, 1427.809936, -30.445892, 1000.024841, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1428.324707, -38.208457, 1000.071228, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1418.194824, -39.118453, 1000.071228, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2161, 1418.194824, -39.118453, 1001.401184, 0.000000, 0.000000, 270.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19563, 1390.276367, -26.280147, 1000.581604, 0.000000, 0.000000, -11.399998, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19563, 1389.990356, -25.926689, 1000.581604, 0.000000, 0.000000, 8.100002, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19578, 1389.782958, -26.177251, 1000.631774, 0.000000, 0.000000, -75.999992, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19578, 1389.901611, -26.198293, 1000.611755, 0.000000, 0.000000, -40.199996, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19564, 1380.847167, -26.058771, 1000.601440, 0.000000, 0.000000, 170.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19576, 1380.722045, -26.248014, 1000.621520, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19576, 1380.621948, -26.098011, 1000.621520, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19576, 1380.661987, -26.458019, 1000.621520, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2831, 1382.515869, -26.176662, 1000.601440, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2832, 1382.587402, -43.437129, 1000.591674, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19563, 1380.709594, -43.432155, 1000.561645, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19575, 1380.481689, -43.294483, 1000.641662, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19575, 1380.621826, -43.104496, 1000.641662, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19578, 1381.005737, -43.288299, 1000.591552, 0.000000, 0.000000, 116.200004, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(2830, 1390.302490, -43.356319, 1000.571533, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19564, 1392.163330, -43.368152, 1000.631713, 0.000000, 0.000000, 0.000000, -1, -1, -1, 200.00, 200.00); 
	bolnica = CreateDynamicObject(19564, 1392.461669, -43.251449, 1000.631713, 0.000000, 0.000000, -28.700002, -1, -1, -1, 200.00, 200.00); 
	//Sneg
	#if SNEG == 1
	SnijegObjekti(5145, 2716.79687, -2447.87500, 2.15625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5146, 2498.19531, -2408.00781, 1.80468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5147, 2533.76562, -2330.82812, 22.19531, 0.00000, 0.00000, 315.00000);
	SnijegObjekti(3753, 2702.39843, -2324.25781, 3.03906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5333, 2374.38281, -2171.46875, 21.17968, 0.00000, 0.00000, 135.00000);
	SnijegObjekti(5191, 2381.44531, -2397.43750, 6.67187, 0.00000, 0.00000, 45.00000);
	SnijegObjekti(5176, 2521.53906, -2606.95312, 17.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3753, 2615.10937, -2464.61718, 3.03906, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(3753, 2748.01562, -2571.59375, 3.03906, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(5115, 2523.40625, -2217.46093, 12.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3753, 2511.47656, -2256.03125, 3.03906, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(5108, 2333.55468, -2308.71093, 3.27343, 0.00000, 0.00000, 45.00000);
	SnijegObjekti(5353, 2543.75000, -2163.78906, 14.20312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5250, 2743.43750, -2120.64062, 15.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5184, 2699.03125, -2227.74218, 31.42968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5125, 2397.82031, -2183.05468, 15.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5124, 2278.89843, -2286.31250, 15.33593, 0.00000, 0.00000, 45.00000);
	SnijegObjekti(3753, 2299.18750, -2405.39843, 3.03906, 0.00000, 0.00000, 225.00000);
	SnijegObjekti(3753, 2368.16406, -2523.86718, 3.03906, 0.00000, 0.00000, 90.00000);
	SnijegObjekti(3753, 2454.82812, -2702.91406, 3.03906, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(5109, 2219.33593, -2558.80468, 4.98437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4841, 2123.78906, -2576.32812, 15.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5003, 2018.43750, -2585.50000, 18.78125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4864, 1996.06250, -2677.55468, 14.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4822, 2179.89843, -2407.41406, 15.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5004, 2030.14062, -2417.69531, 12.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4867, 1780.80468, -2604.14062, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4842, 1383.79687, -2707.74218, 3.27343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4863, 1533.08593, -2677.43750, 11.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4865, 1515.40625, -2602.50781, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4843, 1274.56250, -2551.86718, 3.27343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4839, 1383.60937, -2633.05468, 15.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4883, 1339.23437, -2456.69531, 15.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4866, 1517.15625, -2449.64843, 12.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4816, 1210.71093, -2467.78906, 1.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4840, 1233.50000, -2438.00000, 8.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4845, 1222.82812, -2291.23437, 7.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4835, 1466.76562, -2286.43750, 16.58593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4838, 1411.57812, -2265.07031, 12.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4834, 1315.84375, -2286.33593, 13.43750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4833, 1528.74218, -2252.64062, 12.68750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4871, 1569.93750, -2378.24218, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4831, 1756.08593, -2286.50000, 16.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4830, 1687.78125, -2286.53906, 10.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4869, 1893.39062, -2269.60156, 14.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5002, 1780.35937, -2437.60156, 12.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5009, 2065.13281, -2269.60156, 15.32031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4868, 2139.60937, -2292.42187, 15.32031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5123, 2195.08593, -2266.61718, 12.56250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5276, 2219.60156, -2200.49218, 12.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4827, 2056.88281, -2187.35156, 6.27343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5314, 2085.17968, -2132.70312, 12.41406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5271, 2275.40625, -2095.26562, 12.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5274, 2317.71875, -2210.57812, 8.80468, 0.00000, 0.00000, 315.00000);
	SnijegObjekti(5277, 2235.91406, -2282.46093, 13.18750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5275, 2293.80468, -2172.77343, 11.71093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5106, 2390.24218, -2013.87500, 16.04687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5112, 2521.09375, -2049.24218, 18.73437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5297, 2393.06250, -2049.24218, 18.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5330, 2303.75000, -1982.78125, 12.42968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5311, 2287.34375, -2024.38281, 12.53906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5174, 2371.25781, -2024.32031, 16.58593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5149, 2479.82812, -2009.00000, 15.18750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5105, 2543.46093, -2142.28125, 10.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5120, 2243.64843, -2021.01562, 12.41406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5270, 2112.30468, -2001.79687, 9.76562, 0.00000, 0.00000, 45.00000);
	SnijegObjekti(5273, 2153.40625, -2051.42968, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5272, 2213.17187, -2033.06250, 12.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5343, 2136.50781, -1992.89062, 12.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5347, 2130.63281, -1987.89843, 13.14843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5122, 2184.43750, -1932.95312, 14.38281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5119, 2176.06250, -1911.87500, 12.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5329, 2216.18750, -1912.33593, 13.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5111, 2271.35937, -1912.38281, 14.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5513, 2200.72656, -1811.33593, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17595, 2217.48437, -1810.83593, 12.36718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5141, 2271.19531, -1928.39062, 12.49218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5349, 2143.67187, -1894.47656, 12.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5118, 2107.77343, -1958.81250, 12.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5182, 2115.00000, -1921.52343, 15.39062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5117, 2031.25000, -1962.31250, 13.28906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5121, 2041.65625, -1904.81250, 12.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5116, 2361.27343, -1918.74218, 16.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5168, 2385.18750, -1906.51562, 18.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5178, 2479.85156, -1930.21093, 12.41406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5187, 2439.28125, -1979.96093, 15.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5142, 2489.23437, -1962.01562, 19.03906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5355, 2582.42968, -1979.37500, 9.14843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5296, 2652.92968, -2049.24218, 18.12500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5143, 2639.40625, -2102.39843, 36.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5113, 2758.53906, -2104.89843, 18.28125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5188, 2718.44531, -1977.50000, 11.21875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5133, 2845.64843, -1969.99218, 9.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5173, 2768.44531, -2012.09375, 14.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5144, 2768.56250, -1942.69531, 11.30468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17582, 2739.21875, -1770.08593, 17.55468, 0.00000, 0.00000, 175.00000);
	SnijegObjekti(17927, 2771.17187, -1901.49218, 11.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17602, 2678.68750, -1849.80468, 9.90625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17606, 2848.87500, -1799.57031, 10.32031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17675, 2893.58593, -1586.53125, 10.22656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17605, 2798.70312, -1657.29687, 10.98437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17607, 2854.89843, -1525.40625, 9.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17541, 2803.39843, -1573.80468, 20.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17604, 2690.29687, -1657.30468, 10.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17609, 2730.14062, -1572.89843, 20.63281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17682, 2674.94531, -1622.54687, 14.17968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17680, 2642.69531, -1540.80468, 19.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17538, 2682.80468, -1507.41406, 44.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17603, 2642.79687, -1733.10156, 9.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17600, 2585.25781, -1732.34375, 11.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17601, 2674.18750, -1860.69531, 11.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5151, 2674.10156, -1990.78906, 15.18750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17500, 2478.60156, -1851.48437, 6.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5128, 2516.59375, -1875.55468, 11.67968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5110, 2443.63281, -1901.32031, 18.00781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5267, 2485.76562, -1900.43750, 18.53125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17599, 2522.19531, -1773.00000, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17548, 2482.32812, -1783.14843, 14.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17596, 2413.75000, -1820.83593, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17598, 2469.38281, -1732.21093, 12.57812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17613, 2489.29687, -1668.50000, 12.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17617, 2502.32031, -1649.58593, 15.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17616, 2521.68750, -1692.85937, 14.86718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17574, 2459.80468, -1714.88281, 12.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17612, 2408.09375, -1658.90625, 12.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17881, 2429.78906, -1681.84375, 12.64062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17615, 2459.59375, -1695.60156, 13.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17654, 2556.35156, -1612.91406, 15.90625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17655, 2433.07031, -1611.55468, 12.03125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17829, 2413.68750, -1576.64062, 16.20312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17657, 2431.03906, -1603.49218, 20.20312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17656, 2431.05468, -1677.42968, 20.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17597, 2314.95312, -1741.32812, 12.48437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17614, 2387.80468, -1695.64843, 13.74218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17621, 2342.59375, -1682.70312, 12.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17620, 2281.21093, -1695.64843, 13.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17611, 2284.66406, -1656.71093, 13.42968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17619, 2303.41406, -1622.42187, 9.05468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17622, 2342.60937, -1608.81250, 16.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17867, 2308.45312, -1599.38281, 4.63281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17866, 2339.78906, -1583.99218, 14.96093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17638, 2431.69531, -1514.35156, 22.90625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17624, 2386.78906, -1524.35937, 22.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17862, 2458.38281, -1532.43750, 22.99218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17623, 2342.50000, -1534.00000, 22.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17639, 2490.90625, -1504.32812, 22.92187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17921, 2560.86718, -1474.34375, 22.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17687, 2577.24218, -1447.23437, 30.77343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17640, 2461.39062, -1445.78125, 25.82031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17852, 2490.90625, -1474.34375, 27.34375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17920, 2295.01562, -1564.46875, 12.32031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5511, 2193.25000, -1543.54687, 9.70312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5478, 2269.08593, -1487.55468, 20.73437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5479, 2234.16406, -1590.25781, 16.66406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17513, 2288.89843, -1525.50000, 17.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17610, 2224.03906, -1680.64062, 13.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5480, 2208.37500, -1698.24218, 13.39062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5510, 2192.79687, -1665.03906, 13.73437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5440, 2207.67968, -1588.39062, 19.34375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5509, 2150.39062, -1741.82812, 12.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5419, 2078.15625, -1847.70312, 7.76562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5183, 2111.65625, -1873.36718, 16.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5180, 2163.67187, -1873.61718, 15.82031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5508, 2085.85937, -1812.77343, 13.17968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5528, 2101.29687, -1688.77343, 18.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5506, 2079.83593, -1699.94531, 12.46093, 0.00000, 0.00000, 275.57501);
	SnijegObjekti(5411, 2021.65625, -1810.72656, 18.60156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5139, 2021.15625, -1893.27343, 15.17968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5404, 1952.71875, -1856.78125, 7.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4895, 1899.15625, -1936.33593, 14.26562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5052, 1961.65625, -1863.11718, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5013, 1961.66406, -2001.89843, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5186, 2014.81250, -2041.14062, 12.53906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4807, 1964.64062, -2109.42187, 14.10937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4808, 1892.33593, -2037.64843, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4806, 1880.33593, -2001.92187, 12.57031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4859, 1868.95312, -2003.65625, 13.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5064, 1855.45312, -1958.46093, 12.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4858, 1891.74218, -1872.28125, 14.85937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5420, 1835.82031, -1815.14062, 7.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5489, 1932.59375, -1782.10156, 12.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5026, 1821.66406, -1872.31250, 12.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4819, 1815.45312, -1958.46093, 12.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4817, 1739.30468, -1951.95312, 12.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4837, 1823.00781, -2087.17187, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4849, 1892.33593, -2109.50781, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4861, 1873.01562, -2101.83593, 15.89062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4846, 1827.13281, -2158.85937, 14.51562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5036, 1694.60156, -2131.11718, 12.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5034, 1742.81250, -2292.75781, 3.92968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4829, 1645.38281, -2292.75781, 3.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4870, 1569.98437, -2194.72656, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4836, 1441.90625, -2166.64843, 13.27343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4872, 1610.92968, -2010.62500, 23.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5028, 1624.00000, -2113.61718, 23.10937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4820, 1738.39062, -2117.02343, 13.93750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4876, 1582.29687, -2002.23437, 26.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4878, 1530.82812, -1969.13281, 26.39062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4852, 1401.46093, -1994.58593, 35.43750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4823, 1338.32812, -1976.65625, 36.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4875, 1270.68750, -2196.78906, 42.56250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4824, 1224.42968, -2037.00781, 62.92968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4851, 1182.00781, -1987.63281, 39.99218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4810, 1095.06250, -2214.21875, 41.72656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5046, 1105.50000, -2355.95312, 16.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4809, 1036.52343, -2204.43750, 14.16406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4815, 1074.58593, -2321.74218, 10.85156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4898, 992.85937, -2126.61718, 12.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4896, 981.70312, -2155.85156, 1.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4814, 1071.03125, -2354.00781, 1.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4812, 1023.39843, -2166.10156, 23.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5023, 1046.05468, -2251.50781, 33.64062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4811, 1069.67187, -2270.89843, 23.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4897, 985.72656, -2050.53125, 3.04687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5021, 1044.91406, -2023.39062, 17.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4813, 1042.27343, -2029.80468, 23.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6065, 887.46093, -1878.39062, 3.12500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6118, 1050.07812, -1864.31250, 12.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6117, 1109.32031, -1852.37500, 12.56250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4168, 1217.45312, -1852.26562, 12.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4108, 1177.46093, -1782.25000, 12.66406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4182, 1304.98437, -1792.28125, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4107, 1360.75781, -1802.25000, 12.49218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4010, 1350.75781, -1802.28125, 12.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4165, 1469.52343, -1872.37500, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4207, 1603.81250, -1863.34375, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4133, 1625.09375, -1834.20312, 24.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4209, 1569.93750, -1802.28906, 12.32031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4122, 1629.46093, -1812.28906, 13.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4160, 1686.62500, -1806.42968, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3991, 1608.19531, -1721.80468, 26.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6116, 997.56250, -1798.51562, 12.95312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6054, 1036.41406, -1689.17968, 12.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6042, 952.34375, -1822.82031, 15.17968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6122, 798.09375, -1763.10156, 12.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6123, 917.39843, -1672.90625, 12.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6203, 956.19531, -1689.60156, 12.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6115, 1087.46093, -1712.26562, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6128, 1207.46093, -1712.19531, 12.66406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6126, 1149.89843, -1642.14843, 12.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3978, 1380.26562, -1655.53906, 10.80468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4197, 1380.26562, -1655.53906, 10.80468, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(4198, 1380.26562, -1655.53906, 10.80468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6127, 1306.51562, -1630.35937, 12.46875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4163, 1469.33593, -1732.28906, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4148, 1427.05468, -1662.28906, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4186, 1479.55468, -1693.14062, 19.57812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4158, 1609.55468, -1732.32812, 12.46875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4150, 1532.05468, -1662.28906, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4029, 1629.54687, -1756.08593, 8.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3985, 1479.56250, -1631.45312, 12.07812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4129, 1595.00000, -1603.02343, 27.03906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3989, 1646.00781, -1662.71875, 8.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3993, 1719.93750, -1662.28906, 12.46875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4013, 1654.59375, -1637.74218, 28.64062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3987, 1722.05468, -1702.28906, 12.81250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3992, 1755.60156, -1782.30468, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3983, 1722.50000, -1775.39843, 14.51562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3977, 1384.36718, -1511.43750, 10.10937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4146, 1371.00000, -1582.34375, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4144, 1442.15625, -1517.53125, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3994, 1479.55468, -1592.28906, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4020, 1544.83593, -1516.85156, 32.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4142, 1494.75781, -1410.87500, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4139, 1406.17187, -1418.10156, 12.78906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4712, 1546.98437, -1356.61718, 14.95312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3990, 1593.95312, -1416.35156, 26.66406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3996, 1596.35937, -1440.87500, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4131, 1588.44531, -1509.14062, 27.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4128, 1666.91406, -1456.75000, 26.04687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4127, 1664.12500, -1560.85156, 23.35156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4152, 1658.10937, -1516.69531, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4233, 1603.90625, -1592.29687, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4156, 1739.81250, -1602.19531, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4001, 1700.47656, -1517.69531, 17.93750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4125, 1769.51562, -1509.48437, 12.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4154, 1706.21093, -1432.35156, 12.44531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4645, 1605.72656, -1370.82812, 15.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4557, 1714.74218, -1350.87500, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5498, 1849.32812, -1373.39843, 12.48437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3995, 1797.16406, -1464.39062, 7.99218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5439, 1887.79687, -1536.60156, 7.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5501, 1884.66406, -1613.42187, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5502, 1822.89062, -1725.25781, 12.46875, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(5503, 1927.70312, -1754.31250, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5441, 1941.65625, -1682.57031, 12.47656, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(5505, 2002.48437, -1700.98437, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5507, 2041.66406, -1672.31250, 12.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5442, 2041.72656, -1752.31250, 12.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5518, 2137.98437, -1672.55468, 12.77343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5504, 2046.00000, -1613.00000, 12.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5512, 2069.92187, -1535.78125, 10.49218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5471, 2088.10937, -1568.11718, 11.05468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5472, 2117.29687, -1541.57812, 23.53906, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(5391, 2148.80468, -1627.12500, 13.42968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5519, 2159.81250, -1595.92187, 12.89062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5438, 2222.67187, -1462.91406, 22.78906, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(17509, 2511.75781, -1544.31250, 18.51562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17505, 2339.78906, -1583.99218, 12.76562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17877, 2374.30468, -1640.43750, 12.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5429, 2244.69531, -1518.75000, 22.23437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17625, 2315.35937, -1444.20312, 22.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17637, 2391.17968, -1414.32812, 22.92968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17636, 2411.16406, -1402.88281, 28.01562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17645, 2481.21875, -1350.49218, 27.77343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17644, 2511.76562, -1349.52343, 30.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17634, 2411.02343, -1301.75000, 25.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17642, 2411.08593, -1235.32812, 27.80468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17635, 2411.02343, -1352.10156, 23.70312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17630, 2371.07812, -1216.36718, 24.71093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17628, 2371.08593, -1320.45312, 22.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17976, 2414.39843, -1362.20312, 32.60156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17643, 2451.01562, -1230.28906, 29.18750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17646, 2511.00000, -1256.60156, 33.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17641, 2454.60156, -1350.46093, 22.82812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17627, 2347.67187, -1384.31250, 22.92968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17545, 2337.17968, -1342.62500, 23.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17626, 2303.43750, -1338.03906, 22.98437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5674, 2286.37500, -1371.27343, 22.95312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5428, 2252.00000, -1434.14062, 23.25781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5494, 2263.21093, -1368.70312, 22.92968, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(5437, 2155.00000, -1382.00000, 23.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5427, 2170.97656, -1461.12500, 25.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5496, 2120.00000, -1440.00000, 23.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5497, 2060.19531, -1463.40625, 18.94531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5495, 2066.00000, -1358.00000, 23.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5492, 2168.21093, -1300.80468, 22.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5477, 2287.09375, -1217.65625, 24.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17632, 2307.52343, -1225.10156, 23.80468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5490, 2269.78125, -1224.53125, 24.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5491, 2171.39062, -1220.82031, 22.88281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5424, 2218.89062, -1260.81250, 24.28906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5493, 2169.97656, -1260.46093, 22.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5482, 2172.57031, -1171.20312, 23.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5459, 2123.93750, -1159.00000, 24.16406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5650, 2213.50000, -1124.90625, 24.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5423, 2121.10156, -1260.87500, 26.15625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5435, 2069.36718, -1260.99218, 22.89843, 0.00000, 0.00000, 90.00000);
	SnijegObjekti(5434, 1946.82812, -1260.90625, 17.67968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5499, 1944.00000, -1341.00000, 18.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5487, 1972.60937, -1198.31250, 23.97656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5458, 1995.01562, -1198.35156, 21.10937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5483, 2069.29687, -1149.20312, 22.94531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5432, 2110.09375, -1098.80468, 23.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5485, 1950.59375, -1135.88281, 24.02343, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(5486, 2005.50000, -1081.30468, 24.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5443, 2019.40625, -1107.13281, 24.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5481, 2023.25781, -1034.48437, 29.12500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5445, 2105.96093, -1038.55468, 40.41406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5444, 2143.05468, -1048.40625, 48.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5446, 2086.29687, -1077.07812, 29.05468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5484, 2190.58593, -1063.07031, 45.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5456, 2185.09375, -1013.21093, 59.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13706, 2372.03125, -1056.34375, 57.03906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13823, 2284.00781, -929.46875, 88.18750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5451, 2256.03125, -1019.92187, 59.38281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13795, 2422.11718, -1093.34375, 48.15625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17631, 2336.93750, -1153.14062, 26.62500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17669, 2378.03125, -1110.17187, 33.61718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17906, 2440.30468, -1120.25000, 43.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17670, 2463.75000, -1151.64843, 34.96875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17647, 2420.95312, -1179.13281, 31.01562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17678, 2506.88281, -1167.06250, 46.24218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17648, 2511.03906, -1184.53906, 48.20312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17892, 2511.02343, -1220.26562, 42.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17893, 2553.97656, -1205.13281, 60.65625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17894, 2524.44531, -1205.61718, 56.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17651, 2636.89062, -1184.08593, 64.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17650, 2570.89843, -1230.30468, 52.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17652, 2646.79687, -1257.00000, 51.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17649, 2571.00000, -1350.40625, 33.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17679, 2540.82812, -1350.58593, 40.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17681, 2682.64843, -1456.39843, 29.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17653, 2642.78906, -1350.25781, 39.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17666, 2642.67187, -1217.78125, 58.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17658, 2730.13281, -1445.92187, 32.68750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17608, 2806.30468, -1488.45312, 19.58593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17556, 2804.71093, -1451.60937, 19.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17561, 2769.53125, -1446.67187, 22.06250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17683, 2866.69531, -1355.90625, 15.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17674, 2903.42968, -1336.88281, 9.97656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17676, 2928.05468, -1298.13281, 8.16406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17660, 2825.99218, -1386.36718, 15.17187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17685, 2810.67187, -1263.75000, 39.12500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17589, 2801.78125, -1392.64062, 20.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17661, 2796.89062, -1323.23437, 32.82812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17673, 2882.54687, -1146.64062, 10.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17684, 2847.09375, -1148.80468, 16.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17659, 2729.00000, -1330.70312, 47.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17663, 2730.19531, -1220.90625, 63.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17662, 2777.29687, -1259.00000, 52.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17664, 2685.25781, -1220.95312, 59.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17671, 2633.64843, -1152.68750, 47.90625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17696, 2690.39062, -1154.14062, 56.71093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17677, 2587.65625, -1101.25781, 56.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17849, 2642.73437, -1086.32031, 66.02343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17667, 2642.71875, -1164.50000, 59.16406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17693, 2730.23437, -1117.64843, 64.17187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17691, 2778.79687, -1099.79687, 41.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17672, 2789.42187, -1144.94531, 29.95312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13810, 2948.41406, -951.76562, -28.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13708, 2778.64843, -930.35156, 39.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13709, 2856.43750, -930.17968, 16.14843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13809, 2734.87500, -917.96093, 47.82031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13497, 2870.02343, -662.57812, 26.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13121, 2870.02343, -662.57812, 26.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12877, 2870.77343, -677.79687, 10.67968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13120, 2629.58593, -662.28906, 89.49218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13156, 2379.60156, -670.41406, 112.02343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13123, 2631.27343, -415.71875, 54.14843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13134, 2372.07031, -407.32812, 73.57031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13710, 2523.76562, -915.31250, 85.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13707, 2563.92187, -1047.17187, 68.17187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17692, 2681.78125, -1078.75000, 68.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17694, 2704.28906, -1095.78906, 62.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17668, 2506.70312, -1079.83593, 54.94531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13122, 2862.23437, -413.64062, -4.21875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12878, 2807.10937, -480.72656, 16.26562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12974, 2793.53125, -447.35937, 18.17968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12876, 2815.46875, -278.23437, 10.93750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12879, 2732.03906, -231.38281, 29.75781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13824, 2039.82031, -904.82031, 79.06250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13157, 2148.91406, -662.00000, 90.57031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13158, 1941.59375, -686.10156, 75.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13825, 1826.08593, -882.76562, 75.32031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5433, 2044.59375, -1007.20312, 38.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5448, 2068.20312, -965.95312, 47.88281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5656, 2046.64843, -1009.96875, 40.89062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4695, 1898.47656, -1016.67968, 29.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5431, 1914.17968, -1073.31250, 23.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5668, 1928.90625, -1026.75781, 28.71875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5457, 1923.60937, -1088.34375, 24.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5640, 1914.03125, -1198.32812, 19.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5488, 1852.26562, -1196.06250, 20.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4700, 1807.28125, -1049.87500, 23.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4604, 1757.00781, -1127.25781, 23.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4658, 1810.93750, -1001.45312, 34.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4692, 1702.95312, -1031.42968, 39.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4701, 1722.28906, -1043.25000, 23.01562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4595, 1634.42968, -1115.53125, 23.03125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4702, 1647.33593, -1033.16406, 22.99218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4666, 1614.67968, -1024.67968, 42.78125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4653, 1661.97656, -910.81250, 46.05468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4664, 1643.16406, -1128.23437, 41.56250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4662, 1624.82031, -1229.85937, 34.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4656, 1693.95312, -766.04687, 50.00781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13826, 1805.02343, -699.98437, 69.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13672, 1700.89062, -556.53906, 38.35937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13723, 1496.91406, -790.91406, 48.67968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13821, 1530.92187, -532.64062, 62.98437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13751, 1650.02343, -559.67187, 42.35156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13820, 1701.62500, -489.19531, 59.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13502, 1935.17968, -526.87500, 51.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13146, 1935.17968, -526.87500, 51.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13719, 1437.55468, -669.28906, 86.81250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13673, 1284.30468, -677.42187, 81.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13674, 1411.90625, -562.96875, 67.58593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13818, 1317.85937, -474.10156, 52.21875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13323, 1245.20312, -430.53906, 22.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13237, 1148.69531, -528.16406, 57.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13752, 1210.70312, -625.61718, 78.71093, 0.00000, 0.00000, 10.44999);
	SnijegObjekti(13720, 1192.34375, -669.16406, 52.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4660, 1507.78125, -966.94531, 33.83593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4703, 1569.92187, -1041.07812, 22.97656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13882, 1376.50000, -788.78906, 67.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4694, 1425.03906, -947.82812, 34.28125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5803, 1376.42968, -912.18750, 36.17968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13756, 1349.29687, -809.14062, 68.88281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13801, 1341.02343, -839.93750, 58.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13757, 1250.80468, -833.01562, 63.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5845, 1323.66406, -884.63281, 36.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5851, 1323.66406, -884.63281, 36.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5744, 1268.44531, -935.32031, 37.70312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13715, 1041.32031, -707.45312, 90.02343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13718, 1063.58593, -626.98437, 112.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13528, 1138.66406, -311.89062, 38.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13212, 1138.66406, -311.89062, 38.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13324, 979.50781, -500.17968, 33.12500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13213, 896.94531, -285.84375, 22.55468, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13214, 871.25781, -411.43750, 38.10156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13236, 953.02343, -569.69531, 68.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13211, 594.83593, -299.83593, 6.28125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13129, 786.71093, -539.52343, 15.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12999, 681.71093, -574.88281, 15.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3316, 769.21875, -558.86718, 18.67187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3353, 798.24218, -500.96875, 16.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(3314, 815.15625, -500.96875, 16.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12998, 811.71875, -580.96875, 15.25781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12981, 857.21093, -609.96875, 17.41406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13531, 797.70312, -707.14062, 64.24218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13235, 797.70312, -707.14062, 64.24218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13845, 667.54687, -853.20312, 52.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13704, 653.58593, -841.35156, 39.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13730, 767.57031, -927.32812, 48.36718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13702, 696.50781, -849.16406, 54.88281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13726, 809.36718, -778.78125, 80.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12976, 681.47656, -459.00000, 15.53125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13001, 701.06250, -507.64062, 15.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13127, 631.71093, -507.64062, 15.25000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13000, 563.56250, -438.88281, 36.09375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12989, 536.89062, -578.04687, 32.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13128, 640.57031, -660.17968, 12.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12971, 548.76562, -626.98437, 26.17187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13370, 543.13281, -807.58593, 52.84375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13371, 422.06250, -782.47656, 42.61718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13021, 387.11718, -941.69531, 51.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12864, 183.82812, -697.42968, 24.14843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13019, 141.58593, -858.93750, 5.67968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12973, 421.21093, -570.23437, 37.92187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13020, 317.19531, -869.16406, 33.00781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13342, 133.44531, -655.82812, 14.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12970, 310.78906, -591.55468, 33.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13017, 155.79687, -1140.15625, 6.23437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13683, 339.72656, -1086.42968, 73.91406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13871, 415.52343, -1080.00000, 76.90625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13789, 191.51562, -1207.74218, 52.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13692, 252.23437, -1211.92968, 64.96093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13685, 428.91406, -1103.67187, 77.15625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13735, 313.93750, -1203.23437, 74.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13678, 223.12500, -1150.96875, 64.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13736, 239.78906, -1283.89843, 61.64062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13733, 329.53906, -1237.81250, 62.83593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13738, 319.97656, -1289.57031, 52.48437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13734, 366.11718, -1226.23437, 58.15625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13732, 449.83593, -1233.48437, 33.21875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13684, 495.02343, -1153.19531, 62.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13742, 508.64062, -1244.42968, 40.16406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6509, 529.00781, -1268.35937, 15.51562, 0.00000, 0.00000, 39.00000);
	SnijegObjekti(6327, 377.28909, -1362.66406, 13.58593, 0.00000, 0.00000, 30.10199);
	SnijegObjekti(6330, 525.21093, -1443.21875, 14.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13741, 332.99218, -1331.38281, 32.97656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6356, 381.28125, -1323.17187, 24.49218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6328, 294.97656, -1366.74218, 18.92968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13740, 179.30468, -1448.42968, 28.01562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6326, 207.59375, -1484.50781, 11.90625, 0.00000, 0.00000, 207.04595);
	SnijegObjekti(6497, 227.78906, -1423.03125, 18.60937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13737, 252.86718, -1288.48437, 64.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13739, 216.09375, -1361.97656, 49.17187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13690, 135.64062, -1455.68750, 25.62500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13675, 116.01563, -1393.33593, 24.90625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6325, 128.12500, -1551.03125, 8.20312, 0.00000, 0.00000, 352.20999);
	SnijegObjekti(17281, -42.50780, -1476.89062, 4.31250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17121, -65.05467, -1572.94531, -3.89843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17118, -52.24219, -1395.50781, 4.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17186, -39.32030, -1566.71875, 1.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17279, -111.00781, -1362.33593, 5.23437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13676, 78.41406, -1270.49218, 13.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13677, 92.21875, -1291.65625, 14.11718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17301, -49.39062, -1140.86718, 5.20312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17297, -28.64842, -1020.34375, 16.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6292, 137.72656, -1026.68750, 24.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17117, 5.04687, -1000.33593, 17.08593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17305, -153.19531, -971.96093, 34.26562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(12851, -51.97655, -842.67187, 19.74218, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17115, -283.96875, -960.07031, 33.62500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17302, -160.82812, -1100.76562, 6.42968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17296, -178.11718, -1049.76562, 14.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17303, -114.95313, -1179.69531, 3.14843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17119, -226.96093, -1253.90625, 7.86718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6428, 245.19531, -1736.70312, 3.63281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6315, 205.46093, -1656.82031, 8.96875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6416, 95.64842, -1593.14843, -19.21093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6314, 127.64842, -1659.70312, 7.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6293, 125.69531, -1768.54687, -10.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6280, 260.02343, -1839.91406, -1.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6417, 156.53906, -1908.78125, -13.68750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6427, 293.21875, -1691.21875, 7.84375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6448, 335.30468, -1711.90625, 25.62500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6449, 387.76562, -1823.63281, 12.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6311, 400.69531, -1755.70312, 6.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6297, 432.81250, -1856.28906, 1.22656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6450, 379.72656, -1945.95312, -1.21875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6300, 379.53906, -2050.86718, -1.21875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6310, 437.89843, -1715.10156, 8.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6281, 570.74218, -1868.34375, 1.67968, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6443, 301.93750, -1657.81250, 19.64843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6313, 437.19531, -1679.44531, 19.22656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6316, 199.40629, -1626.73437, 12.37500, 0.00000, 0.00000, 133.05000);
	SnijegObjekti(6312, 202.71093, -1580.11718, 22.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6317, 270.29687, -1613.60156, 32.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6305, 328.57031, -1612.57812, 31.93750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6320, 297.50000, -1490.30468, 32.09375, 0.00000, 0.00000, 31.96500);
	SnijegObjekti(6345, 236.54690, -1498.31250, 21.75000, 0.00000, 0.00000, 337.82998);
	SnijegObjekti(6347, 238.17968, -1509.85156, 22.11718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6321, 270.69531, -1576.20312, 31.89843, 0.00000, 0.00000, 345.65499);
	SnijegObjekti(6341, 332.89062, -1500.06250, 29.87500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6323, 416.46881, -1446.08593, 30.79687, 0.00000, 0.00000, 36.04999);
	SnijegObjekti(6319, 444.21881, -1376.51562, 24.67187, 0.00000, 0.00000, 28.30500);
	SnijegObjekti(6318, 572.95312, -1328.72656, 13.07031, 0.00000, 0.00000, 14.27000);
	SnijegObjekti(6324, 632.57812, -1443.09375, 13.68750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6508, 624.70312, -1252.11718, 14.87500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6331, 473.82031, -1437.41406, 21.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6302, 576.14062, -1406.25781, 13.76562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6322, 496.27343, -1500.14062, 16.66406, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6304, 444.00000, -1521.40625, 27.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6303, 359.21090, -1523.76562, 31.59375, 0.00000, 0.00000, 38.40999);
	SnijegObjekti(6343, 389.48437, -1528.78906, 28.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6333, 422.00000, -1583.10156, 23.69531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6329, 557.53906, -1577.91406, 15.03125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6307, 491.46875, -1630.75000, 20.07812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6306, 428.05468, -1654.95312, 24.92187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6308, 565.81250, -1671.28125, 16.36718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6398, 552.53125, -1695.57812, 15.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6064, 688.53125, -1877.96093, 2.01562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6309, 576.64062, -1730.42187, 11.88281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6291, 631.66406, -1647.45312, 14.38281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6225, 724.81250, -1673.65625, 11.62500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6227, 676.61718, -1668.96093, 3.85156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6231, 753.04687, -1676.26562, 8.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6119, 810.87500, -1703.42968, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6229, 773.20312, -1667.99218, 2.93750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6188, 836.31250, -1866.75781, -0.53906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6120, 845.66406, -1607.29687, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6189, 836.44531, -2003.52343, -2.64062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6114, 1044.78906, -1572.26562, 12.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6121, 926.75000, -1572.27343, 12.51562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6124, 742.40625, -1595.16406, 13.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6111, 784.50000, -1496.20312, 12.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6135, 764.32031, -1509.04687, 16.82812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6094, 731.15625, -1506.53125, 3.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6301, 717.48437, -1362.77343, 12.51562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6487, 713.56250, -1236.21875, 17.82031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13703, 495.41406, -957.49218, 79.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13872, 587.67187, -958.76562, 65.35156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13689, 567.82812, -1031.39843, 71.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13688, 689.69531, -1023.00000, 50.46875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13698, 650.87500, -1076.07812, 38.83593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5765, 819.57812, -986.02337, 35.93750, 0.00000, 0.00000, 116.42299);
	SnijegObjekti(5753, 850.82812, -1013.78125, 30.25781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5755, 796.46093, -1111.12500, 23.18750, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6507, 696.89837, -1138.50000, 18.19531, 0.00000, 0.00000, 191.77600);
	SnijegObjekti(5756, 797.91406, -1234.44531, 17.71875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5805, 869.92187, -1144.73437, 22.75781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5871, 879.57031, -1092.87500, 26.15625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5864, 849.91406, -1196.68750, 19.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5865, 892.79687, -1268.61718, 19.72656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5863, 912.88281, -1194.32812, 20.73437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5705, 830.86718, -1269.12500, 20.85937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5796, 859.89062, -1323.78906, 12.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5798, 797.35156, -1357.64062, 12.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5862, 847.35156, -1400.48437, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13693, 560.28125, -1184.89843, 44.22656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13686, 553.59375, -1164.53125, 51.34375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5754, 962.60156, -1056.30468, 30.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5807, 1041.99218, -1039.29687, 30.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5875, 1022.64062, -1080.32812, 27.25781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5758, 1012.59375, -1145.08593, 22.75781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5757, 943.43750, -1220.53125, 17.61718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5759, 1058.11718, -1234.76562, 17.60156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5747, 1084.46875, -1048.88281, 32.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5748, 1133.00781, -1145.96875, 22.77343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5878, 1122.65625, -1080.45312, 26.73437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5752, 989.11718, -966.10156, 39.50781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5866, 916.57812, -952.71093, 43.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5718, 901.23437, -967.47662, 47.65625, 0.00000, 0.00000, 10.00000);
	SnijegObjekti(5987, 913.71875, -918.58593, 49.34375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5853, 1018.16412, -908.97662, 43.64843, 0.00000, 0.00000, 7.71999);
	SnijegObjekti(13711, 994.05468, -841.23437, 75.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5802, 1124.57031, -950.24218, 41.75781, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13814, 850.87500, -912.80468, 58.14062, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13813, 817.73437, -917.84375, 54.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13716, 849.37500, -828.64843, 73.56250, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13713, 970.15625, -818.52343, 90.96093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13887, 967.20312, -715.27343, 107.97656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(13804, 1077.60937, -651.60937, 114.28906, 0.00000, 0.00000, 144.86500);
	SnijegObjekti(13717, 1161.32031, -755.01562, 84.80468, 0.00000, 0.00000, 8.92500);
	SnijegObjekti(13784, 1156.85937, -852.75781, 49.35937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5743, 1265.29687, -889.95312, 40.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5746, 1163.17187, -1046.42968, 32.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5745, 1262.95312, -1037.64843, 32.07031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5801, 1266.13281, -1037.72656, 28.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5806, 1149.63281, -1039.24218, 30.94531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5793, 1365.47656, -998.26562, 30.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5887, 1212.76562, -1090.07812, 26.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5823, 1140.17968, -1207.25781, 18.82031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4649, 1425.16406, -1035.25781, 24.19531, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4650, 1482.25000, -1097.30468, 22.85937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5800, 1355.72656, -1089.84375, 24.33593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5799, 1350.15625, -1170.82031, 19.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6007, 1308.24218, -1088.84375, 26.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4651, 1539.85937, -1087.31250, 22.72656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4568, 1529.90625, -1096.78125, 22.40625, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4652, 1539.84375, -1161.74218, 23.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4567, 1646.46093, -1161.70312, 22.86718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4710, 1762.11718, -1170.89062, 22.76562, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(4591, 1753.75781, -1231.39843, 12.44531, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(4654, 1715.46093, -1230.87500, 18.26562, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4643, 1654.76562, -1246.28906, 16.17187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5436, 1987.00000, -1408.00000, 17.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5500, 1948.95312, -1461.20312, 12.46875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4589, 1780.00000, -1281.00000, 13.00000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4592, 1798.46093, -1223.46093, 17.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4556, 1660.04687, -1340.72656, 15.63281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4646, 1650.83593, -1300.85937, 15.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4684, 1661.54687, -1216.45312, 16.27343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4562, 1574.59375, -1248.10156, 15.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4685, 1572.59375, -1216.50000, 17.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4565, 1513.69531, -1204.80468, 18.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4648, 1419.67968, -1150.12500, 22.86718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4679, 1607.88281, -1324.62500, 32.72656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4553, 1530.83593, -1300.85156, 15.54687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4647, 1454.75781, -1309.12500, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4551, 1410.16406, -1333.39062, 9.92187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(4644, 1416.19531, -1210.87500, 17.59375, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5750, 1350.15625, -1250.83593, 14.13281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5859, 1350.14843, -1353.36718, 12.47656, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5751, 1283.73437, -1145.08593, 22.61718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5804, 1213.76562, -1177.09375, 19.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5707, 1269.39843, -1256.96093, 14.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6006, 1183.69531, -1241.35937, 16.27343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5857, 1259.43750, -1246.81250, 17.10937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5749, 1144.40625, -1251.48437, 15.10937, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5703, 998.15625, -1220.82031, 15.83593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5812, 1230.89062, -1337.98437, 12.53906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5794, 1200.90625, -1337.99218, 12.39843, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5810, 1114.31250, -1348.10156, 17.98437, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5994, 1259.22656, -1400.40625, 10.78125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5995, 1130.05468, -1400.70312, 12.52343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5860, 1058.14843, -1363.26562, 12.61718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5795, 985.72656, -1324.79687, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5732, 1014.02343, -1361.46093, 20.35156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5808, 1255.24218, -1337.96093, 12.32812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5809, 1281.43750, -1337.95312, 12.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6035, 1329.03125, -1479.07812, 12.46093, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6101, 1268.24218, -1467.84375, 11.82031, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6129, 1205.11718, -1572.27343, 12.42187, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6125, 1196.03906, -1489.07031, 12.37500, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6130, 1117.58593, -1490.00781, 32.71875, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5861, 979.94531, -1400.49218, 12.36718, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6055, 1050.08593, -1489.03906, 12.53906, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6113, 984.29687, -1491.40625, 12.50000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6152, 990.08593, -1450.08593, 12.77343, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6160, 982.61718, -1530.82812, 12.83593, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6112, 917.50000, -1489.10156, 12.29687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6217, 846.45312, -1523.52343, 12.35156, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(6059, 855.09375, -1461.80468, 12.79687, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5815, 877.16406, -1361.20312, 12.45312, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5797, 917.35937, -1361.24218, 12.38281, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5784, 988.27337, -1289.63281, 15.37500, 0.00000, 0.00000, 180.00000);
	SnijegObjekti(5760, 1016.92968, -1249.92968, 18.50000, 0.00000, 0.00000, 270.00000);
	SnijegObjekti(4879, 1374.25781, -2184.03906, 21.07812, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17665, 2604.34375, -1220.23437, 54.75000, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(17629, 2338.92968, -1299.60156, 23.03125, 0.00000, 0.00000, 0.00000);
	SnijegObjekti(5624, 2136.72656, -975.82812, 58.10937, 0.00000, 0.00000, 345.00500);
	#endif
	Create3DTextLabel("Pretisnite {03adfc}H {ffffff}da bi ste otvorili kapiju", -1, 1245.65881, -766.94067, 92.77000, 25.0, 0);
	CreatePickup(19132, 1, 1258.7070,-785.2449,92.0302);
	Create3DTextLabel("Pretisnite {03adfc}Enter {ffffff}ili {03adfc}F{ffffff}\nDa bi ste usli u kucu", -1, 1258.7070,-785.2449,92.0302, 5.0, 0);
	
	CreateDynamicObject(19370, 1235.281494, -1789.478271, -23.480491, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1235.281494, -1786.269165, -23.480491, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1235.281494, -1783.088989, -23.480491, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1235.281494, -1779.887573, -23.480491, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1235.281494, -1776.727172, -23.480491, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1238.722290, -1776.727172, -23.498498, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1242.163818, -1776.727172, -23.516523, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1245.614379, -1776.727172, -23.534576, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1249.104980, -1776.727172, -23.552856, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1249.104980, -1779.937500, -23.552856, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1249.104980, -1783.137695, -23.552856, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1249.104980, -1786.308349, -23.552856, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1249.104980, -1789.509277, -23.552856, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1245.625610, -1789.509277, -23.534620, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1242.124511, -1789.509277, -23.516290, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1238.784790, -1789.509277, -23.498800, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1238.784790, -1786.308837, -23.498800, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1238.784790, -1783.108398, -23.498800, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1238.784790, -1779.903930, -23.498800, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1242.285278, -1779.903930, -23.517110, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1245.765136, -1779.903930, -23.535326, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1245.765136, -1783.114501, -23.535326, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1245.765136, -1786.324707, -23.535326, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1242.284790, -1786.324707, -23.517099, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19370, 1242.284790, -1783.114135, -23.517099, 0.000000, -89.699981, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1233.609252, -1786.227172, -21.742046, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1233.609252, -1776.587036, -21.742046, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1250.770629, -1779.987670, -21.752046, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1250.770629, -1789.618652, -21.752046, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1250.775756, -1791.009155, -21.752046, 0.000000, 0.000000, -89.800041, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1241.145385, -1791.044067, -21.752046, 0.000000, 0.000000, -89.800041, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1231.554565, -1791.078979, -21.752046, 0.000000, 0.000000, -89.800041, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1238.488769, -1775.043701, -21.752046, 0.000000, 0.000000, -90.000038, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1238.488769, -1775.043701, -21.752046, 0.000000, 0.000000, -90.000038, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19452, 1248.127807, -1775.043701, -21.752046, 0.000000, 0.000000, -90.000038, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1235.277343, -1786.330810, -19.917633, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1235.277343, -1776.702270, -19.917633, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1238.767578, -1776.702270, -19.923723, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1238.767578, -1786.322387, -19.923723, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1242.228271, -1786.322387, -19.929758, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1242.228271, -1776.682250, -19.929758, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1245.709106, -1776.682250, -19.935823, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1245.709106, -1786.322509, -19.935823, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1249.160644, -1786.322509, -19.941833, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19448, 1249.160644, -1776.712524, -19.941833, 0.000000, 90.099945, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19362, 1246.577148, -1789.362792, -21.700532, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19391, 1248.084228, -1787.650634, -21.780008, 0.000000, 0.000000, 90.700035, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19362, 1251.278320, -1787.611572, -21.700532, 0.000000, 0.000000, -89.699928, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1502, 1247.286621, -1787.641723, -23.458011, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19391, 1246.581176, -1784.383911, -21.870389, 89.700004, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19391, 1246.661254, -1776.391113, -21.671686, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19362, 1246.577148, -1787.711669, -21.700532, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19391, 1246.618774, -1780.895385, -21.888635, 89.700004, 178.799896, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19362, 1246.637207, -1778.721679, -21.700532, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1502, 1246.697753, -1775.614746, -23.431461, 0.000000, 0.000000, -93.000007, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19433, 1247.345825, -1783.400756, -22.487894, 0.000000, 89.999938, 88.200050, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19433, 1247.388061, -1782.080810, -22.487894, 0.000000, 89.999938, 88.200050, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1569, 1233.655395, -1781.508911, -23.433593, 0.000000, 0.000000, -90.000030, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1569, 1233.644897, -1784.490722, -23.433593, 0.000000, 0.000000, 89.799926, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2282, 1250.211059, -1781.085083, -21.739063, 0.000000, 0.000000, -89.500045, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2282, 1250.207641, -1784.044799, -21.739063, 0.000000, 0.000000, -89.500045, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2161, 1250.674316, -1775.619750, -23.461893, 0.000000, 0.000000, -90.300025, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2161, 1250.667114, -1776.920288, -23.461893, 0.000000, 0.000000, -90.300025, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2161, 1250.670898, -1776.249633, -22.141885, 0.000000, 0.000000, -90.300025, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1251.183227, -1778.981201, -23.467884, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1250.505859, -1779.319702, -23.465040, 0.000000, 0.000000, -91.300010, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1250.368286, -1785.378173, -23.465040, 0.000000, 0.000000, -91.300010, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2282, 1250.205322, -1789.475952, -21.739063, 0.000000, 0.000000, -89.500045, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1233.968994, -1790.764282, -23.482440, 0.000000, 0.000000, 89.900032, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1233.996704, -1775.353027, -23.482440, 0.000000, 0.000000, 89.900032, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1247.522460, -1784.109008, -22.393617, 0.000000, 0.000000, 87.700004, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19893, 1247.635742, -1781.281860, -22.393617, 0.000000, 0.000000, 87.700004, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19447, 1246.405639, -1782.742187, -23.433933, 90.399978, -90.299995, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2282, 1237.645751, -1775.614379, -21.739063, 0.000000, 0.000000, 1.400007, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2282, 1240.845947, -1775.627197, -21.739063, 0.000000, 0.000000, 1.400007, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1764, 1240.539062, -1790.563232, -23.419589, 0.000000, 0.000000, -179.699905, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1242.119995, -1790.755126, -23.412443, 0.000000, 0.000000, -177.399917, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(1808, 1237.385620, -1790.779296, -23.412443, 0.000000, 0.000000, -177.399917, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2282, 1239.539672, -1790.386718, -21.739063, 0.000000, 0.000000, 178.599914, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2161, 1244.093139, -1790.906860, -23.411909, 0.000000, 0.000000, 179.000137, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2161, 1236.024414, -1790.765625, -23.411909, 0.000000, 0.000000, 179.000137, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2356, 1249.192138, -1784.180175, -23.466453, 0.000000, 0.000000, 87.799987, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(2356, 1249.301391, -1781.332275, -23.466453, 0.000000, 0.000000, 87.799987, -1, -1, -1, 300.00, 300.00);
	//Auto salon //19381
	CreateDynamicObject(3851, 1172.649047, -1123.549194, 24.843833, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateTransparentObject(19381, 1172.652099, -1122.529052, 21.597948, 0.000000, 0.000000, 0.000000); 
	CreateTransparentObject(19381, 1172.652099, -1124.350585, 21.597948, 0.000000, 0.000000, 0.000000); 
	CreateDynamicObject(3851, 1178.268310, -1129.195800, 24.863805, 0.000000, 0.000000, -90.000076, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1185.270751, -1129.195800, 24.863805, 0.000000, 0.000000, -90.000076, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1190.889648, -1123.549194, 24.843833, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1178.268310, -1117.955322, 24.863805, 0.000000, 0.000000, -90.000076, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1185.270751, -1117.945068, 24.863805, 0.000000, 0.000000, -90.000076, -1, -1, -1, 300.00, 300.00); 
	CreateTransparentObject(19381, 1190.901855, -1124.350585, 21.597948, 0.000000, 0.000000, 0.000000); 
	CreateTransparentObject(19381, 1190.862670, -1122.529052, 21.597948, 0.000000, 0.000000, 0.000000); 
	CreateTransparentObject(19381, 1177.473999, -1129.224365, 21.657991, 0.000000, 0.000000, -89.999977); 
	CreateTransparentObject(19381, 1186.114624, -1129.224365, 21.657991, 0.000000, 0.000000, -89.999977); 
	CreateTransparentObject(19381, 1177.473999, -1117.892700, 21.657991, 0.000000, 0.000000, -89.999977); 
	CreateTransparentObject(19381, 1186.114624, -1117.994873, 21.657991, 0.000000, 0.000000, -89.999977); 
	CreateDynamicObject(2180, 1189.493774, -1127.619262, 23.044153, 0.000000, 0.000000, -89.699958, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(2180, 1189.481201, -1125.058593, 23.044153, 0.000000, 0.000000, -89.699958, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19893, 1189.386840, -1125.407104, 23.830982, 0.000000, 0.000000, 86.399993, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(19893, 1189.516601, -1128.109008, 23.830982, 0.000000, 0.000000, 86.399993, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1566, 1172.586547, -1124.099609, 24.377912, 0.000000, 0.000000, -89.699981, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(1566, 1172.717163, -1124.099243, 24.377912, 0.000000, 0.000000, -89.699981, -1, -1, -1, 300.00, 300.00); 
	CreateTransparentObject(19381, 1172.652099, -1122.529052, 21.597948, 0.000000, 0.000000, 0.000000); 
	CreateDynamicObject(3851, 1174.595336, -1123.609130, 26.917764, 0.000000, 89.900024, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1178.565429, -1123.609130, 26.924697, 0.000000, 89.900024, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1182.535034, -1123.609130, 26.931632, 0.000000, 89.900024, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1186.485351, -1123.609130, 26.938526, 0.000000, 89.900024, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateDynamicObject(3851, 1188.736572, -1123.609130, 26.942436, 0.000000, 89.900024, 0.000000, -1, -1, -1, 300.00, 300.00); 
	CreateTransparentObject(19381, 1186.114624, -1124.166748, 26.982837, 0.000000, -88.800033, -89.999977); 
	CreateTransparentObject(19381, 1186.104858, -1123.456054, 26.997720, 0.000000, -88.800033, -89.999977); 
	CreateTransparentObject(19381, 1177.334838, -1123.456054, 26.997720, 0.000000, -88.800033, -89.999977); 
	CreateTransparentObject(19381, 1177.334838, -1124.045898, 26.985366, 0.000000, -88.800033, -89.999977); 
	//Glavna Banka
	new banka;
	banka = CreateDynamicObject(19377, 1105.771972, 1054.659057, -21.026899, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 15041, "bigsfsave", "AH_flroortile9", 0x00000000);
	banka = CreateDynamicObject(19377, 1114.917358, 1051.132324, -19.080720, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1105.352050, 1046.490234, -20.940299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19381, 1107.559692, 1058.105346, -20.940299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19381, 1100.534545, 1051.353271, -20.940299, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19381, 1100.533813, 1060.983764, -20.940299, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19381, 1096.426635, 1058.105346, -20.940299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19443, 1101.991943, 1058.106567, -16.678100, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.621826, 1048.201293, -20.212730, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 17025, "cuntrock", "rock_country128", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.622680, 1051.699218, -20.212730, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 17025, "cuntrock", "rock_country128", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.622436, 1055.199462, -20.212730, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 17025, "cuntrock", "rock_country128", 0x00000000);
	banka = CreateDynamicObject(19443, 1103.157958, 1055.195800, -20.947299, 90.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19443, 1103.158935, 1051.696899, -20.947299, 90.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19443, 1103.158203, 1048.198974, -20.947299, 90.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.627563, 1046.665527, -21.460430, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.625244, 1049.952758, -21.460399, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.623535, 1053.442260, -21.460399, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19443, 1102.622680, 1056.873291, -21.460399, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14650, "ab_trukstpc", "sa_wood08_128", 0x00000000);
	banka = CreateDynamicObject(19381, 1110.187988, 1051.246948, -25.778360, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1110.191528, 1060.865478, -20.940299, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19443, 1110.185791, 1053.127441, -19.620899, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19443, 1110.186157, 1051.525878, -19.620880, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19430, 1110.896362, 1052.339843, -17.797700, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19430, 1110.898071, 1052.343627, -19.564489, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19430, 1110.898193, 1050.702880, -19.564489, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19430, 1110.897827, 1053.990844, -19.564489, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1110.190917, 1051.234863, -20.940299, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "scratchedmetal", 0x00000000);
	banka = CreateDynamicObject(19381, 1110.189575, 1060.873535, -25.778400, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1107.559814, 1058.103393, -25.778400, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1096.426757, 1058.103393, -25.778400, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1100.535766, 1060.983154, -25.778400, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1100.536499, 1051.353149, -25.778400, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1105.352661, 1046.492187, -25.778400, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1114.918579, 1061.622070, -19.080720, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1102.765991, 1068.176513, -23.438840, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 1259, "billbrd", "ws_oldpainted2", 0x00000000);
	banka = CreateDynamicObject(19377, 1101.897460, 1069.697509, -20.335180, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_whiteplaster_top", 0x00000000);
	banka = CreateDynamicObject(19377, 1095.807250, 1052.770629, -19.080720, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1105.283569, 1041.329101, -19.080720, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(2010, 1109.688110, 1057.543945, -20.938280, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 4003, "cityhall_tr_lan", "foliage256", 0xFF66FF99);
	banka = CreateDynamicObject(2010, 1109.583740, 1047.039306, -20.938280, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 4003, "cityhall_tr_lan", "foliage256", 0xFF66FF99);
	banka = CreateDynamicObject(19430, 1110.844726, 1053.989135, -20.393070, 45.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19430, 1110.841796, 1050.703369, -20.393070, 45.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(2010, 1109.636718, 1054.454467, -20.937049, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 4830, "airport2", "kbplanter_plants1", 0xFF66FF66);
	banka = CreateDynamicObject(2010, 1109.636840, 1050.212036, -20.937049, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 4830, "airport2", "kbplanter_plants1", 0xFF66FF66);
	banka = CreateDynamicObject(2311, 1105.723144, 1056.061767, -20.938209, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14652, "ab_trukstpa", "CJ_WOOD1(EDGE)", 0x00000000);
	banka = CreateDynamicObject(2311, 1105.641357, 1048.572875, -20.938209, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14652, "ab_trukstpa", "CJ_WOOD1(EDGE)", 0x00000000);
	banka = CreateDynamicObject(19377, 1105.741210, 1051.064819, -21.024879, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 15041, "bigsfsave", "AH_flroortile9", 0x00000000);
	banka = CreateDynamicObject(19377, 1114.220703, 1052.195068, -16.485399, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19377, 1110.523803, 1059.590454, -16.487400, 0.000000, 90.000000, 45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19377, 1109.935546, 1045.149780, -16.487400, 0.000000, 90.000000, 45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19377, 1096.707153, 1052.473632, -16.487400, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19377, 1100.211425, 1045.274414, -16.485399, 0.000000, 90.000000, 45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19377, 1100.845947, 1059.418701, -16.485399, 0.000000, 90.000000, 45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(19377, 1101.866333, 1051.900146, -11.161600, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1104.440063, 1048.340087, -11.161600, 0.000000, 0.000000, 45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1108.219970, 1054.595825, -11.161600, 0.000000, 0.000000, 45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1107.494140, 1049.385620, -11.161600, 0.000000, 0.000000, -45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1102.492675, 1054.384277, -11.161600, 0.000000, 0.000000, -45.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19377, 1109.060424, 1052.047485, -11.161600, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19381, 1105.982666, 1052.150634, -15.849579, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 16640, "a51", "ws_stationfloor", 0x00000000);
	banka = CreateDynamicObject(18762, 1105.458496, 1055.813842, -13.512709, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(18762, 1105.415161, 1048.972778, -13.512709, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(18762, 1107.843994, 1052.557617, -13.512709, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(18762, 1103.119384, 1052.528686, -13.512709, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	banka = CreateDynamicObject(18980, 1110.562133, 1058.470336, -20.937160, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1110.560913, 1054.364746, -16.116100, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1110.562255, 1046.123291, -20.937160, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1098.921142, 1046.128662, -16.116100, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1100.165527, 1046.127685, -20.937160, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1100.169067, 1058.942626, -16.116100, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1100.169311, 1058.479980, -20.937160, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(18980, 1100.967651, 1058.479492, -16.116100, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
	banka = CreateDynamicObject(19377, 1107.560668, 1063.265625, -19.080720, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19370, 1102.830566, 1059.657348, -19.198099, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19370, 1101.156127, 1059.787475, -22.689699, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19370, 1101.156127, 1059.787475, -19.198099, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19370, 1101.152343, 1062.872558, -22.689699, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19370, 1102.830566, 1059.657348, -22.689699, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19370, 1102.829467, 1062.863647, -22.689699, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19370, 1102.829467, 1062.863647, -19.198099, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19377, 1102.791015, 1063.439819, -17.555940, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_whiteplaster_top", 0x00000000);
	banka = CreateDynamicObject(19377, 1103.056152, 1060.301147, -17.320240, 0.000000, 55.000000, 270.209167, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_whiteplaster_top", 0x00000000);
	banka = CreateDynamicObject(19377, 1096.424804, 1063.266479, -19.080720, 0.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 3096, "bbpcpx", "blugrad32", 0x00000000);
	banka = CreateDynamicObject(19370, 1101.157958, 1062.872924, -19.198099, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19381, 1107.559448, 1064.383544, -20.940299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19381, 1096.422973, 1064.391479, -20.940299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19381, 1100.552490, 1069.266479, -20.940299, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19381, 1105.673217, 1069.114135, -20.940299, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19381, 1102.163818, 1069.717041, -20.940299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19172, 1100.613281, 1055.232421, -17.938209, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 14489, "carlspics", "AH_landscap1", 0x00000000);
	banka = CreateDynamicObject(19443, 1101.991943, 1058.126586, -16.678100, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(banka, 0, 10765, "airportgnd_sfse", "ws_airpt_concrete", 0x00000000);
	banka = CreateDynamicObject(19174, 1100.627197, 1066.048583, -22.371633, 0.000000, -8.200001, 90.000053, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(banka, 0, "{000000} by  Kova", 120, "Ariel", 20, 1, 0x00000000, 0x00000000, 1);
	banka = CreateDynamicObject(19174, 1100.637207, 1066.057006, -22.360309, 0.000000, -8.200001, 90.000053, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(banka, 0, "{0000ff} by  Kova", 120, "Ariel", 20, 1, 0x00000000, 0x00000000, 1);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	banka = CreateDynamicObject(1502, 1101.228393, 1058.076538, -20.937009, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2161, 1100.613647, 1047.080810, -20.936899, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2161, 1100.612426, 1047.080322, -19.605619, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2161, 1100.614868, 1048.409912, -20.936899, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2161, 1100.625122, 1055.540405, -20.936899, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2167, 1100.619995, 1049.806762, -20.934700, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2197, 1101.476196, 1054.535888, -20.937799, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2197, 1101.476440, 1053.874023, -20.937799, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2197, 1101.362915, 1052.999633, -21.975650, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2164, 1100.655151, 1051.564575, -20.938600, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2190, 1102.379638, 1054.958740, -20.124500, 0.000000, 0.000000, 259.528930, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1714, 1101.334472, 1055.288940, -20.937200, 0.000000, 0.000000, 87.706146, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2190, 1102.465454, 1047.882934, -20.124500, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1714, 1101.405395, 1047.520263, -20.937200, 0.000000, 0.000000, 96.610786, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2190, 1102.490600, 1051.351562, -20.124500, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1714, 1101.372192, 1051.408203, -20.937200, 0.000000, 0.000000, 92.723876, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2816, 1102.915527, 1049.109008, -20.124799, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2826, 1103.015258, 1051.885620, -20.125419, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2816, 1103.135620, 1055.580688, -20.124799, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1897, 1111.184448, 1052.629516, -19.588209, 0.000000, 90.000000, 180.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1897, 1111.184814, 1052.067260, -19.610200, 180.000000, 90.000000, 180.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1723, 1105.447631, 1057.470825, -20.938409, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1723, 1107.375244, 1047.040039, -20.938400, 0.000000, 0.000000, 180.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2826, 1106.538085, 1056.084350, -20.434600, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2816, 1106.549560, 1048.639038, -20.434070, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(19172, 1100.613281, 1049.921630, -17.938209, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1232, 1103.127319, 1052.554565, -13.590600, 180.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1232, 1107.863037, 1052.533081, -13.590600, 180.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1232, 1105.469116, 1055.855590, -13.590600, 180.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1232, 1105.395629, 1048.962402, -13.590600, 180.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2258, 1104.770385, 1057.995605, -18.375129, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2260, 1106.091552, 1057.515014, -17.742050, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2256, 1107.305908, 1046.596801, -18.477510, 0.000000, 0.000000, 180.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2264, 1105.786865, 1047.212524, -17.912599, 0.000000, 0.000000, 180.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2262, 1108.719238, 1057.508422, -18.868560, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(14416, 1101.670776, 1061.624633, -24.130100, 0.000000, 0.000000, 180.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(19302, 1101.905883, 1064.387084, -19.690399, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(19305, 1102.532836, 1064.374511, -22.233980, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(19302, 1101.905883, 1064.387084, -22.115760, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1105.371826, 1068.373535, -22.949199, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1105.373168, 1067.513549, -22.949199, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1105.372924, 1066.656860, -22.949199, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1105.374145, 1069.230957, -22.949199, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1101.905883, 1069.561767, -22.949199, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1102.760009, 1069.563842, -22.949199, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1101.048339, 1069.558593, -22.949199, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1101.048339, 1069.558593, -22.031099, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1105.371826, 1068.373535, -22.031099, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1105.374145, 1069.230957, -22.031099, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2007, 1104.039062, 1069.240844, -23.351520, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2007, 1101.130981, 1065.362548, -23.351499, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2332, 1100.787719, 1066.259521, -22.949199, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2007, 1101.080444, 1068.131958, -23.351499, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2197, 1101.499145, 1067.288330, -23.351299, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2197, 1104.502807, 1065.921020, -23.351299, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(2197, 1104.505126, 1065.219970, -23.351299, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1893, 1102.464599, 1069.025878, -19.925729, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(1893, 1102.452270, 1065.936645, -19.925729, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(3017, 1100.862915, 1065.349853, -21.939399, 0.000000, 0.000000, 89.844200, -1, -1, -1, 300.00, 300.00);
	banka = CreateDynamicObject(3111, 1102.506347, 1069.622314, -21.493299, 90.000000, 90.000000, 270.000000, -1, -1, -1, 300.00, 300.00);
//Dinamicni sistemi
	//house
	for(new i = 0; i < MAX_HOUSES; i++) {
        new hfile[64];
        format(hfile, sizeof(hfile), HOUSEPATH, i);
        if(fexist(hfile)) {
			new string[512];
            INI_ParseFile(hfile, "LoadHouses", .bExtra = true, .extra = i);
            if(!strcmp(HouseInfo[i][hOnRent], "Da")) {
				format(string, sizeof(string), "{ffa500}[{ffffff}Kuca za rent{ffa500}]\nVlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}On Rent: {ffffff}%s\n{ffa500}Rent: {ffffff}%s\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d\n{ffa500}Ako zelite da rentate kucu kucajte /renthouse", HouseInfo[i][hOwner], HouseInfo[i][hCena], HouseInfo[i][hOnRent], HouseInfo[i][hRent], HouseInfo[i][hLevel], i);
				hPickup[i] = CreatePickup(19523, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
				hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 10.0, 0, 0);
			}
			if (HouseInfo[i][hOwned] == 0) {
                format(string, sizeof(string), "{ffa500}[{ffffff}Kuca na prodaju{ffa500}]\nVlasnik: {ffffff}Niko\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d\n{ffa500}Ako zelite da kupite kucu kucajte /kupikucu", HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
                hPickup[i] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
                hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 10.0, 0, 0);
            } else {
                format(string, sizeof(string), "{ffa500}[ {ffffff}Kuca {ffa500}]\n{ffa500}Vlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d", HouseInfo[i][hOwner], HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
                hPickup[i] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
                hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 10.0, 0, 0);
            }
			Itter_Add(Houses, i);
        }
    }
	//admin
	for(new i = 0; i < MAX_ADMINS; i++) {
		new afile[64];
		format(afile, sizeof(afile), ADMINPATH, i);
		if(!fexist(afile)) {
			INI_ParseFile(afile, "LoadAdmins", .bExtra = true, .extra = i);
			new str[128];
			format(str, sizeof(str), "Niko");
			AdminInfo[i][aName] = str;
			AdminInfo[i][aNeaktivnost] = 0;
			AdminInfo[i][aDuty] = 0;
			SaveAdmin(i);
		} else INI_ParseFile(afile, "LoadAdmins", .bExtra = true, .extra = i);
	}
	//ban
	for(new i = 0; i < MAX_PLAYERS; i++) {
		new bfile[64];
		format(bfile, sizeof(bfile), BANPATH, i);
		if(!fexist(bfile)) {
			INI_ParseFile(bfile, "LoadBanned", .bExtra = true, .extra = i);
			new str[128];
			format(str, sizeof(str), "Niko");
			BannedInfo[i][bName] = str;
			SaveBanned(i);
		} else INI_ParseFile(bfile, "LoadBanned", .bExtra = true, .extra = i);
	}
	//promoter
	for(new i = 0; i < MAX_PROMS; i++) {
		new promfile[64];
		format(promfile, sizeof(promfile), PROMPATH, i);
		if(!fexist(promfile)) {
			new niko[128];
			format(niko, sizeof(niko), "Niko");
			PromInfo[i][promName] = niko;
			PromInfo[i][promDuty] = 0;
			PromInfo[i][promNeaktivnost] = 0;
			SaveProm(i);
			INI_ParseFile(promfile, "LoadProm", .bExtra = true, .extra = i);
		} else INI_ParseFile(promfile, "LoadProm", .bExtra = true, .extra = i);
	}
	//vrata
	for(new i = 0; i < MAX_VR; i++) {
		new vrfile[64];
		format(vrfile, sizeof(vrfile), VRPATH, i);
		if(!fexist(vrfile)) {
			ZakljucanaVrata[ZatvorVrata[i]] = true;
			ZatvorenaVrata[ZatvorVrata[i]] = true;
			SaveVr(ZatvorVrata[i]);
			INI_ParseFile(vrfile, "LoadVr", .bExtra = true, .extra = i);
		} else INI_ParseFile(vrfile, "LoadVr", .bExtra = true, .extra = i);
	}
	//org
	for(new i = 0; i < MAX_ORGS; i++) {
		new orgfile[64];
		format(orgfile, sizeof(orgfile), ORGPATH, i);
		if(fexist(orgfile)) {
			INI_ParseFile(orgfile, "LoadOrgs", .bExtra = true, .extra = i);
			new string[128];
			format(string, sizeof(string), "{0000ff}[ {ffffff}%s {0000ff}]\n{ffffff}Leader: {0000ff}%s", OrgInfo[i][orgIme], OrgInfo[i][orgLeader]);
			orgLabel[i] = Create3DTextLabel(string, -1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ], 20.0, 0, 0);
			orgPickup[i] = CreatePickup(1314, 1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ]);
			Itter_Add(Orgs, i);
		}
	}
//----------------------- TextDraw ----------------------------
	lrtd[0] = TextDrawCreate(236.666671, 1.500000, "usebox");
	TextDrawLetterSize(lrtd[0], 0.000000, 49.415019);
	TextDrawTextSize(lrtd[0], -2.000000, 0.000000);
	TextDrawAlignment(lrtd[0], 1);
	TextDrawColor(lrtd[0], 0);
	TextDrawUseBox(lrtd[0], true);
	TextDrawBoxColor(lrtd[0], 102);
	TextDrawSetShadow(lrtd[0], 0);
	TextDrawSetOutline(lrtd[0], 0);
	TextDrawFont(lrtd[0], 0);

	lrtd[1] = TextDrawCreate(115.333259, 95.407310, "Tesla RolePlay");
	TextDrawLetterSize(lrtd[1], 0.461665, 2.558222);
	TextDrawAlignment(lrtd[1], 2);
	TextDrawColor(lrtd[1], 16777215);
	TextDrawSetShadow(lrtd[1], 2);
	TextDrawSetOutline(lrtd[1], 0);
	TextDrawBackgroundColor(lrtd[1], 51);
	TextDrawFont(lrtd[1], 2);
	TextDrawSetProportional(lrtd[1], 1);

	lrtd[2] = TextDrawCreate(236.333374, 132.996292, "usebox");
	TextDrawLetterSize(lrtd[2], 0.000000, -0.869751);
	TextDrawTextSize(lrtd[2], -2.000053, 0.000000);
	TextDrawAlignment(lrtd[2], 1);
	TextDrawColor(lrtd[2], 16777215);
	TextDrawUseBox(lrtd[2], true);
	TextDrawBoxColor(lrtd[2], -55);
	TextDrawSetShadow(lrtd[2], 0);
	TextDrawSetOutline(lrtd[2], 0);
	TextDrawFont(lrtd[2], 0);

	lrtd[3] = TextDrawCreate(9.000032, 136.888946, "Scripter:");
	TextDrawLetterSize(lrtd[3], 0.243999, 1.396739);
	TextDrawAlignment(lrtd[3], 1);
	TextDrawColor(lrtd[3], -1);
	TextDrawSetShadow(lrtd[3], 0);
	TextDrawSetOutline(lrtd[3], 1);
	TextDrawBackgroundColor(lrtd[3], 51);
	TextDrawFont(lrtd[3], 2);
	TextDrawSetProportional(lrtd[3], 1);

	lrtd[4] = TextDrawCreate(68.666648, 137.303710, "Maki");
	TextDrawLetterSize(lrtd[4], 0.269333, 1.342813);
	TextDrawAlignment(lrtd[4], 1);
	TextDrawColor(lrtd[4], 16777215);
	TextDrawSetShadow(lrtd[4], 0);
	TextDrawSetOutline(lrtd[4], 1);
	TextDrawBackgroundColor(lrtd[4], 51);
	TextDrawFont(lrtd[4], 2);
	TextDrawSetProportional(lrtd[4], 1);

	lrtd[5] = TextDrawCreate(9.666716, 170.903671, "Mapper:");
	TextDrawLetterSize(lrtd[5], 0.245665, 1.351111);
	TextDrawAlignment(lrtd[5], 1);
	TextDrawColor(lrtd[5], -1);
	TextDrawSetShadow(lrtd[5], 0);
	TextDrawSetOutline(lrtd[5], 1);
	TextDrawBackgroundColor(lrtd[5], 51);
	TextDrawFont(lrtd[5], 2);
	TextDrawSetProportional(lrtd[5], 1);

	lrtd[6] = TextDrawCreate(236.666671, 193.559249, "usebox");
	TextDrawLetterSize(lrtd[6], 0.000000, 0.282510);
	TextDrawTextSize(lrtd[6], -2.000000, 0.000000);
	TextDrawAlignment(lrtd[6], 1);
	TextDrawColor(lrtd[6], 0);
	TextDrawUseBox(lrtd[6], true);
	TextDrawBoxColor(lrtd[6], -1);
	TextDrawSetShadow(lrtd[6], 0);
	TextDrawSetOutline(lrtd[6], 0);
	TextDrawFont(lrtd[6], 0);

	lrtd[7] = TextDrawCreate(10.333334, 211.555572, "Verzija:");
	TextDrawLetterSize(lrtd[7], 0.223333, 1.326221);
	TextDrawAlignment(lrtd[7], 1);
	TextDrawColor(lrtd[7], -1);
	TextDrawSetShadow(lrtd[7], 0);
	TextDrawSetOutline(lrtd[7], 1);
	TextDrawBackgroundColor(lrtd[7], 51);
	TextDrawFont(lrtd[7], 2);
	TextDrawSetProportional(lrtd[7], 1);

	lrtd[8] = TextDrawCreate(59.666637, 211.970367, "0.1");
	TextDrawLetterSize(lrtd[8], 0.275332, 1.326221);
	TextDrawAlignment(lrtd[8], 1);
	TextDrawColor(lrtd[8], 16777215);
	TextDrawSetShadow(lrtd[8], 0);
	TextDrawSetOutline(lrtd[8], 1);
	TextDrawBackgroundColor(lrtd[8], 51);
	TextDrawFont(lrtd[8], 2);
	TextDrawSetProportional(lrtd[8], 1);

	lrtd[9] = TextDrawCreate(63.333335, 171.318511, "Savva");
	TextDrawLetterSize(lrtd[9], 0.226333, 1.309629);
	TextDrawAlignment(lrtd[9], 1);
	TextDrawColor(lrtd[9], 16777215);
	TextDrawSetShadow(lrtd[9], 0);
	TextDrawSetOutline(lrtd[9], 1);
	TextDrawBackgroundColor(lrtd[9], 51);
	TextDrawFont(lrtd[9], 2);
	TextDrawSetProportional(lrtd[9], 1);

	sdtd[0] = TextDrawCreate(38.999980, 429.748260, "00:00");
	TextDrawLetterSize(sdtd[0], 0.449999, 1.600000);
	TextDrawAlignment(sdtd[0], 1);
	TextDrawColor(sdtd[0], 16777215);
	TextDrawSetShadow(sdtd[0], 0);
	TextDrawSetOutline(sdtd[0], 1);
	TextDrawBackgroundColor(sdtd[0], 51);
	TextDrawFont(sdtd[0], 3);
	TextDrawSetProportional(sdtd[0], 1);

	sdtd[1] = TextDrawCreate(541.333190, 429.748138, "00/00/0000");
	TextDrawLetterSize(sdtd[1], 0.438665, 1.591704);
	TextDrawAlignment(sdtd[1], 1);
	TextDrawColor(sdtd[1], 16777215);
	TextDrawSetShadow(sdtd[1], 0);
	TextDrawSetOutline(sdtd[1], 1);
	TextDrawBackgroundColor(sdtd[1], 51);
	TextDrawFont(sdtd[1], 3);
	TextDrawSetProportional(sdtd[1], 1);

	sdtd[2] = TextDrawCreate(326.666778, 428.918426, "Tesla RolePlay");
	TextDrawLetterSize(sdtd[2], 0.449999, 1.600000);
	TextDrawAlignment(sdtd[2], 2);
	TextDrawColor(sdtd[2], -1);
	TextDrawSetShadow(sdtd[2], 0);
	TextDrawSetOutline(sdtd[2], 1);
	TextDrawBackgroundColor(sdtd[2], 51);
	TextDrawFont(sdtd[2], 2);
	TextDrawSetProportional(sdtd[2], 1);
//----------------------- [PODESAVANJA SVA VOZILA] ----------------------------
	for(new vehicleid = 0; vehicleid < MAX_VEHICLES; vehicleid++) {
		VehInfo[vehicleid][vEngine] = 0;
		VehInfo[vehicleid][vLights] = 0;
		VehInfo[vehicleid][vAlarm] = 0;
		VehInfo[vehicleid][vDoor] = 0;
		VehInfo[vehicleid][vBonnet] = 0;
		VehInfo[vehicleid][vBoot] = 0;
		VehInfo[vehicleid][vObj] = 0;
		VehInfo[vehicleid][vFuel] = 100;
		SetVehicleParamsEx(
			vehicleid, 
			VehInfo[vehicleid][vEngine], 
			VehInfo[vehicleid][vLights], 
			VehInfo[vehicleid][vAlarm],
			VehInfo[vehicleid][vDoor],
			VehInfo[vehicleid][vBonnet],
			VehInfo[vehicleid][vBoot],
			VehInfo[vehicleid][vObj]
		);
	}
//----------------------- ACTORI ----------------------------
	ACTOR[0] = CreateActor(76, 2308.8625,-11.0133,26.7422,177.9879); //ACTOR U BANCI
	ACTOR[1] = CreateActor(76, 2318.3066,-15.2257,26.7496,87.1073);	//ACTOR U BANCI (SALTER)
	ACTOR[2] = CreateActor(76, 2318.3066,-12.6831,26.7496,88.6740); //ACTOR U BANCI (SALTER)
	ACTOR[3] = CreateActor(76, 2318.3064,-9.9949,26.7496,89.3007); //ACTOR U BANCI (SALTER)
	ACTOR[4] = CreateActor(76, 2318.3064,-7.3824,26.7496,88.9874); //ACTOR U BANCI (SALTER)
	ACTOR[5] = CreateActor(70, 1402.6412,-41.3697,1000.8640,358.1200); //ACTOR U BOLNICI (BOLNICAR)
	ACTOR[6] = CreateActor(57, 356.2971,186.2106,1008.3762,267.7336); //ACTOR U VLADI (SALTER)
	ACTOR[7] = CreateActor(57, 356.2968,182.6558,1008.3762,269.6137); //ACTOR U VLADI (SALTER)
	ACTOR[8] = CreateActor(57, 356.2963,178.6558,1008.3762,270.8670); //ACTOR U VLADI (SALTER)
	ACTOR[9] = CreateActor(57, 359.7154,173.7350,1008.3893,266.8172); //ACTOR U VLADI (SALTER)
	ACTOR[10] = CreateActor(57, 356.2979,169.0176,1008.3762,266.1906); //ACTOR U VLADI (SALTER)
	ACTOR[11] = CreateActor(57, 356.2959,166.3219,1008.3762,269.0106); //ACTOR U VLADI (SALTER)
	ACTOR[12] = CreateActor(57, 356.2952,163.2074,1008.3762,269.3239); //ACTOR U VLADI (SALTER)
	ACTOR[13] = CreateActor(179, 290.1594,-104.4914,1001.5156, 175.1689); //ACTOR U AMMUNATIONU
	return 1;
}

public OnGameModeExit(){
	foreach(new i : Player) SavePlayer(i);
	foreach(new House : Houses) SaveHouse(House);
	foreach(new Org : Orgs) SaveOrg(Org);
	for(new i = 0; i < sizeof(ACTOR); i++) DestroyActor(ACTOR[i]);
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {	
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid) {
	if(!ProveraRPImena(playerid)) {
		new string[1024];
		format(string, sizeof(string), "{ffffff}Vase ime nije {ff0000}VALIDNO{ffffff}, jer nije u formatu {03adfc}Ime_Prezime{ffffff}.\nVase ime: {03adfc}%s{ffffff}. Morate da imate ime kao naprimer: {03adfc}Pera_Peric{ffffff}.\nVase ime ne sme sadrzati:\n\tuvredljive reci,\n\tspecijalne karaktere,\n\tbrojeve,\n\tYT - YouTuber ili Gamer u vasem imenu.\nAko mislite da je ovo greska obratite se na nasem forumu!", GetName(playerid));
		SPD(playerid, d_nevalidno_ime, DIALOG_STYLE_MSGBOX, "{03adfc}Provera Imena", string, "{03adfc}Izadji", "");
		return 0;
	}

	RemoveBuildingForPlayer(playerid, 1265, 1520.7734, -1016.2891, 23.4453, 0.25);
	RemoveBuildingForPlayer(playerid, 1265, 1519.8984, -1016.2344, 23.4453, 0.25);
	RemoveBuildingForPlayer(playerid, 1227, 1520.1563, -1018.5547, 23.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 1264, 1519.9609, -1012.8984, 23.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 1227, 1520.2109, -1014.6328, 23.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 5727, 1198.989, -1128.810, 27.843, 0.250);
	RemoveBuildingForPlayer(playerid, 5839, 1198.989, -1128.810, 27.843, 0.250);

	UlogovanProvera[playerid] = 0;

	// Fuel_t[playerid][0] = CreatePlayerTextDraw(playerid, 557.000122, 347.614501, "Gorivo:");
	// PlayerTextDrawLetterSize(playerid, Fuel_t[playerid][0], 0.092999, 0.741333);
	// PlayerTextDrawAlignment(playerid, Fuel_t[playerid][0], 1);
	// PlayerTextDrawColor(playerid, Fuel_t[playerid][0], -1);
	// PlayerTextDrawSetShadow(playerid, Fuel_t[playerid][0], 0);
	// PlayerTextDrawSetOutline(playerid, Fuel_t[playerid][0], 0);
	// PlayerTextDrawBackgroundColor(playerid, Fuel_t[playerid][0], 51);
	// PlayerTextDrawFont(playerid, Fuel_t[playerid][0], 2);
	// PlayerTextDrawSetProportional(playerid, Fuel_t[playerid][0], 1);

	// Fuel_t[playerid][1] = CreatePlayerTextDraw(playerid, 579.000122, 348.444549, "100L");
	// PlayerTextDrawLetterSize(playerid, Fuel_t[playerid][1], 0.104666, 0.621037);
	// PlayerTextDrawAlignment(playerid, Fuel_t[playerid][1], 2);
	// PlayerTextDrawColor(playerid, Fuel_t[playerid][1], -1);
	// PlayerTextDrawSetShadow(playerid, Fuel_t[playerid][1], 0);
	// PlayerTextDrawSetOutline(playerid, Fuel_t[playerid][1], 0);
	// PlayerTextDrawBackgroundColor(playerid, Fuel_t[playerid][1], 51);
	// PlayerTextDrawFont(playerid, Fuel_t[playerid][1], 2);
	// PlayerTextDrawSetProportional(playerid, Fuel_t[playerid][1], 1);

	// new Float:X, Float:Y, Float:Z;
	// GetPlayerCameraPos(playerid, X, Y, Z);
	// snegobj[playerid] = CreatePlayerObject(playerid, 18864, X, Y, Z - 5, 0, 0, 0, 300);

	SetPlayerMapIcon(playerid, HOSPITAL, 1172.0773,-1323.3525,15.4030, HOSPITAL, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, BANK, 1457.0255,-1009.9204,26.8438, BANK, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, POLICE, 1555.5020,-1675.6063,16.1953, POLICE, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, AMMUNATION, 1368.9985,-1279.7140,13.546, AMMUNATION, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, ZEMUNCI, 1244.688964, -738.394348, 95.340431, ZEMUNCI, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, FIBOVCI, 1286.794921, -1327.190795, 13.654617, FIBOVCI, -1, MAPICON_GLOBAL);

	RemoveBuildingForPlayer(playerid, 13759, 1413.4141, -804.7422, 83.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 13722, 1413.4141, -804.7422, 83.4375, 0.25);

	for(new i = 0; i < MAX_PROMS; i++) {
		if(!strcmp(PromInfo[i][promName], GetName(playerid))) {
			PromInfo[i][promNeaktivnost] = 0;
			SaveProm(i);
			break;
		}
	}

	renta[playerid] = -1;
	adminveh[playerid] = -1;
	editaorg[playerid] = -1;

	// for(new i = 0; i < 10; i++) TextDrawShowForPlayer(playerid, lrtd[i]);
	pADuty[playerid] = false;
	new ime[128];
	GetPlayerName(playerid, ime, sizeof(ime));
	for(new i = 0; i < MAX_ADMINS; i++) {
		if(!strcmp(AdminInfo[i][aName], ime)) {
			AdminInfo[i][aNeaktivnost] = 0;
			SaveAdmin(i);
			break;
		}
	}
	if(fexist(UserPath(playerid))) {
	    INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra=true, .extra=playerid);
		PlayerInfo[playerid][pIP] = GETIP(playerid);
		if(PlayerInfo[playerid][pBan] == 1) {
			SetTimerEx("BanMessage", 500, false, "i", playerid);
			return 0;
		}
		if(PlayerInfo[playerid][pAdmin] > 0) Itter_Add(Admins, playerid);
		if(!strcmp(PlayerInfo[playerid][pPromoter], "Da")) Itter_Add(Proms, playerid);
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) Itter_Add(Cops, playerid);
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "FIB")) Itter_Add(Fibs, playerid);
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Yakuza")) Itter_Add(Yakuza, playerid);
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Crveni")) Itter_Add(Crveni, playerid);
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) Itter_Add(Zemunski_Klan, playerid);
		SetPlayerScore(playerid, PlayerInfo[playerid][pGodine]);
		ShowPlayerDialog(playerid, d_log, DIALOG_STYLE_PASSWORD, "{03adfc}Tesla {ffffff}| {03adfc}Prijava na server", "{ffffff}Unesite vasu lozinku:", "{03adfc}Prijavi se", "{03adfc}Odustani");
		PlayerInfo[playerid][pNeededRep] = PlayerInfo[playerid][pGodine] * 2 + 4;
	}
	else ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "{03adfc}Tesla {ffffff}| {03adfc}Registracija na server", "{ffffff}Da bi ste se registrovali ukucajte\nvasu zelejenu sifru za vas {03adfc}nalog{ffffff}.\nSifra mora imati minimum 6 karaktera, maximum 26 karaktera.\nLozinka mora sadrzati brojeve i karaktere poput: \"@_-#\"", "{03adfc}Registruj se", "{03adfc}Odustani");
	SetTimer("TDUpdate", 1000, true);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	SavePlayer(playerid);
	UlogovanProvera[playerid] = 0;
	editaorg[playerid] = -1;
	if(pADuty[playerid]) {
		pADuty[playerid] = false;
		va_SCMTA(-1, "{03adfc}[DUTY]: {ffffff}Admin {03adfc}%s {ffffff}nije vise na duznosti.", GetName(playerid));
	}
	if(policeDuty[playerid]) {
		PDuty[playerid] = false;
		va_SCM(playerid, PLAVA, "[POLICE DUTY]: {ffffff}Policajac {0000ff}%s {ffffff}vise nije na duznosti.", GetName(playerid));
	}
	if(PDuty[playerid]) {
		PDuty[playerid] = false;
		va_SCMTA(NARANDZASTA, "[PROMOTER DUTY]: {ffffff}Promoter {ffa500}%s {ffffff}vise nije na duznosti.", GetName(playerid));
	}
	for(new i = 0; i < MAX_ADMINS; i++) { 
		AdminInfo[i][aDuty] = 0;
		SaveAdmin(i);
	}
	if(policeDuty[playerid]) policeDuty[playerid] = 0;
	if(PDuty[playerid]) PDuty[playerid] = false;
	if(PlayerInfo[playerid][pAdmin] > 0) Itter_Remove(Admins, playerid);
	if(!strcmp(PlayerInfo[playerid][pPromoter], "Da")) Itter_Remove(Proms, playerid);
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) Itter_Remove(Cops, playerid);
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "FIB")) Itter_Remove(Fibs, playerid);
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Yakuza")) Itter_Remove(Yakuza, playerid);
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Crveni")) Itter_Remove(Crveni, playerid);
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) Itter_Remove(Zemunski_Klan, playerid);
	IsPlayerSpec[playerid] = 0;
	// DestroyPlayerObject(playerid, snegobj[playerid]);
	if(!UlogovanProvera[playerid]) return UlogovanProvera[playerid];
	return 1;
}

public OnPlayerSpawn(playerid) {
	// for(new i = 0; i < 10; i++) TextDrawHideForPlayer(playerid, lrtd[i]);
	for(new i = 0; i < 3; i++) TextDrawShowForPlayer(playerid, sdtd[i]);
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(PlayerInfo[playerid][pKuca] == i) {
			SetPlayerVirtualWorld(playerid, HouseInfo[i][hVirtualWorld]);
			SetPlayerInterior(playerid, HouseInfo[i][hInterID]);
			SetPlayerPos(playerid, HouseInfo[i][hInterX], HouseInfo[i][hInterY], HouseInfo[i][hInterZ]);
			return 1;
		}
	}
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) {
		SetPlayerSkin(playerid, 2);
		SetPlayerInterior(playerid, 5);
		SetPlayerPos(playerid, 1262.6282,-785.3718,1091.9063);
		return 1;
	} else if(!strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) {
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		SetPlayerInterior(playerid, 6);
		SetPlayerPos(playerid, 246.783996,63.900199,1003.640625);
		return 1;
	}
	SetPlayerPos(playerid, 1682.222045, -2246.613281, 13.550828);
	return 1;
}

CMD:kill(playerid, params[]) {
	new id;
	if(PlayerInfo[playerid][pAdmin] < 2) return NisteOvlasceni(playerid);
	if(sscanf(params, "u", id)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/kill [id igraca]");
	if(!IsPlayerConnected(id)) return SCM(playerid, SIVA, "Igrac nije online!");
	SetPlayerHealth(playerid, 0);
	va_SCM(playerid, -1, "Uspesno ste killali igraca %s", GetName(id));
	return 1;
}

CMD:oc(playerid, params[]) {
	new str[128];
	if(sscanf(params, "s[128]", str)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/b [tekst]");
	ProxDetectorf(20, playerid, "{696969}(( [OCC] {ffffff}%s kaze: %s{696969} ))", GetName(playerid), str);
	return 1;
}

CMD:do(playerid, params[]) {
	new str[128];
	if(sscanf(params, "s[128]", str)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/do [tekst]");
	ProxDetectorf(20, playerid, "* %s (( %s ))", GetName(playerid), str);
	return 1;
}

CMD:me(playerid, params[]) {
	new str[128];
	if(sscanf(params, "s[128]", str)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/me [tekst]");
	ProxDetectorf(20, playerid, "* %s %s", GetName(playerid), str);
	return 1;
}

CMD:z_rover(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(579, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod Zemunskog spawna!");
	return 1;
}

CMD:garaza(playerid, params[]) {
	#pragma unused params
	if(!strcmp(GetName(playerid), "Sava_zemunac")) {
		CreateVehicle(451, 1010.2318,-658.3732,121.1434,217.1580, 157, 157, -1);
		SCM(playerid, -1, "");
	}
	else return 0;
	return 1;
}

//451
CMD:z_amg(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(451, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod Zemunskog spawna!");
	return 1;
}

CMD:askq(playerid, params[]) {
	#pragma unused params
	SPD(playerid, d_askq, DIALOG_STYLE_INPUT, "Askq", "Unesite pitanje koje zelite postaviti adminima:", "Posalji", "Odustani");
	return 1;
}

// Komanda nije gotova
CMD:pokrenipljacku(playerid, params[]) {
	#pragma unused params
	if(PokrenutaPljacka[playerid]) return SCM(playerid, SIVA, "Pljacka je vec pokrenuta!");
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Crveni") || !strcmp(PlayerInfo[playerid][pOrganizacija], "Yakuza") || !strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) {
		if(!IsPlayerInRangeOfPoint(playerid, 3, 1101.9955,1064.0131,-22.3529)) return SCM(playerid, SIVA, "Niste kod mesta za pocetak pljacke!");
		SCM(playerid, -1, "Uspesno ste zapoceli pljacku centralne banke!");
		foreach(new Cop : Cops) SCM(Cop, PLAVA, "Pljacka centralne banke je upravo zapoceta!");
		foreach(new Fib : Fibs) SCM(Fib, PLAVA, "Pljacka centralne banke je upravo zapoceta!");
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) foreach(new Zemunci : Zemunski_Klan) GivePlayerMoney(Zemunci, 150000);
	} else SCM(playerid, SIVA, "Vi niste u ilegalnoj organizaciji.");
	return 1;
}

CMD:f_tesla(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "FIB")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1284.8795,-1320.9938,13.6421)) {
		new car, Float:X, Float:Y, Float:Z, Float:R, /*edit,*/ vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		car = CreateVehicle(411, X, Y, Z, R, 0x000000ff, 0x000000ff, -1);
		// edit = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    	// AttachDynamicObjectToVehicle(edit, car, 0.000, 0.000, 0.879, 0.000, 0.000, 0.000);
		PutPlayerInVehicle(playerid, car, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehiclePaintjob(vehid, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		Attach3DTextLabelToVehicle(
			Create3DTextLabel(
				"{696969}[ FIB ]",
				-1,
				X,
				Y,
				Z,
				10,
				0
			),
			vehid,
			0,
			0,
			0
		);
	} else SCM(playerid, SIVA, "Niste blizu FIB stanice!");
	return 1;
}

//505
CMD:f_gklasa(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "FIB")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1284.8795,-1320.9938,13.6421)) {
		new car, Float:X, Float:Y, Float:Z, Float:R, /*edit,*/ vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		car = CreateVehicle(505, X, Y, Z, R, 0x000000ff, 0x000000ff, -1);
		// edit = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    	// AttachDynamicObjectToVehicle(edit, car, 0.000, 0.000, 0.879, 0.000, 0.000, 0.000);
		PutPlayerInVehicle(playerid, car, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehiclePaintjob(vehid, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		Attach3DTextLabelToVehicle(
			Create3DTextLabel(
				"{696969}[ FIB ]",
				-1,
				X,
				Y,
				Z,
				10,
				0
			),
			vehid,
			0,
			0,
			0
		);
	} else SCM(playerid, SIVA, "Niste blizu FIB stanice!");
	return 1;
}

//500
CMD:f_urus(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "FIB")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1284.8795,-1320.9938,13.6421)) {
		new car, Float:X, Float:Y, Float:Z, Float:R, /*edit,*/ vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		car = CreateVehicle(500, X, Y, Z, R, 0x000000ff, 0x000000ff, -1);
		// edit = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    	// AttachDynamicObjectToVehicle(edit, car, 0.000, 0.000, 0.879, 0.000, 0.000, 0.000);
		PutPlayerInVehicle(playerid, car, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehiclePaintjob(vehid, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		Attach3DTextLabelToVehicle(
			Create3DTextLabel(
				"{696969}[ FIB ]",
				-1,
				X,
				Y,
				Z,
				10,
				0
			),
			vehid,
			0,
			0,
			0
		);
	} else SCM(playerid, SIVA, "Niste blizu FIB stanice!");
	return 1;
}

CMD:dostupnavozila(playerid, params[]) {
	#pragma unused params
	SPD(playerid, d_dostupna_vozila, DIALOG_STYLE_LIST, "{03adfc}Dostupna Vozila", "Jeftina Vozila\nSkupa Vozila", "{03adfc}Izaberi", "{03adfc}Odustani");
	return 1;
}

CMD:leaveorg(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Nema")) return SCM(playerid, SIVA, "Vi niste ni u jednoj organizaciji!");
	new str[128];
	format(str, sizeof(str), "Nema");
	if(PlayerInfo[playerid][pLeader]) PlayerInfo[playerid][pLeader] = 0;
	va_SCMTA(SIVA, "Igrac {ffffff}%s {696969}je napustio organizaciju {ffffff}%s{696969}.", GetName(playerid), PlayerInfo[playerid][pOrganizacija]);
	PlayerInfo[playerid][pOrganizacija] = str;
	SavePlayer(playerid);
	return 1;
}

CMD:orgkick(playerid, params[]) {
	if(!PlayerInfo[playerid][pLeader]) return NisteOvlasceni(playerid);
	new name[128], razlog[128], str[128], id;
	if(sscanf(params, "s[128]s[128]", name, razlog)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/orgkick [IME IGRACA] [RAZLOG]");
	if(!strcmp(GetName(playerid), name)) return SCM(playerid, SIVA, "Ne mozete kikovati sami sebe iz vase organizacije!");
	format(str, sizeof(str), "Nema");
	id = GetPlayerID(name);
	if(id == -1) {
		new upath[128];
		format(upath, sizeof(upath), USERPATH, name);
		INI_ParseFile(upath, "LoadUser_%s", .bExtra = true, .extra = SKIDANJEID);
		if(strcmp(PlayerInfo[playerid][pOrganizacija], PlayerInfo[SKIDANJEID][pOrganizacija])) return SCM(playerid, SIVA, "Taj igrac nije u vasoj organizaciji!");
		va_SCMTA(SIVA, "Igrac {ffffff}%s {696969}je kickovan iz organizacije {ffffff}%s{696969}. Razlog: {ffffff}%s", name, PlayerInfo[SKIDANJEID][pOrganizacija], razlog);
		PlayerInfo[SKIDANJEID][pOrganizacija] = str;
		Sacuvaj(SKIDANJEID, name);
	} else {
		if(strcmp(PlayerInfo[playerid][pOrganizacija], PlayerInfo[id][pOrganizacija])) return SCM(playerid, SIVA, "Taj igrac nije u vasoj organizaciji!");
		va_SCMTA(SIVA, "Igrac {ffffff}%s {696969}je kickovan iz organizacije {ffffff}%s{696969}. Razlog: {ffffff}%s", name, PlayerInfo[SKIDANJEID][pOrganizacija], razlog);
		PlayerInfo[id][pOrganizacija] = str;
		SavePlayer(id);
	}
	return 1;
}

CMD:akomande(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 1) return NisteOvlasceni(playerid);
	SPD(playerid, d_komande, DIALOG_STYLE_MSGBOX, "Admin Komande", "{ffffff}/makeadmin, /skiniadmina, /v, /afv, /admini, /aduty, /ban,\n /unban, /tp, /rtp, /port, /makeprom, /skiniprom, /jp,\n/cc, /spec, /specoff, /makeleader, /skinilidera,\n/kick, /heal, /akomande", "{03adfc}Izadji", "");
	return 1;
}

CMD:setskin(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return NisteOvlasceni(playerid);
	new id, skinid;
	if(sscanf(params, "ui", id, skinid)) return SCM(playerid, -1, "/setskin [id igraca] [skin id]");
	SetPlayerSkin(id, skinid);
	SavePlayer(id);
	return 1;
}

CMD:heal(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 1) return NisteOvlasceni(playerid);
	if(!pADuty[playerid]) return SCM(playerid, SIVA, "Morate biti na duznosti!");
	new id;
	if(sscanf(params, "i", id)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/heal [id igraca]");
	SetPlayerHealth(id, 100);
	va_SCM(playerid, -1, "Uspesno ste heal-ali igraca %s", GetName(id));
	va_SCM(id, -1, "Admin %s Vas je heal-ovao.", GetName(playerid));
	return 1;
}

CMD:komande(playerid, params[]) {
	#pragma unused params
	SPD(playerid, d_komande, DIALOG_STYLE_MSGBOX, "{03adfc}Sve komande Tesla RP-a", "{03adfc}Osnovne komande: {ffffff}/me, /do, /oc, /givemoney, /engine, /toci, /rent, /unrent, /kupikucu, /enterhouse,\n/exithouse, /house, /stats, /organizacije, /sellhouse, /postavihrent,\n /skinihrent, /otvoriracun, /deposit, /withdraw, /kredit, /quitjob, /listaposlova\n, /inv, /getajob, /prevozputnika, /prekiniposao, /exitveh, /stuck, /prevoznovca, /gps, /komande\n{03adfc}Komande za LSPD: {ffffff}/otvori, /zatvori, /zakljucaj, /otkljucaj, /p_gklasa, /p_skodarapid, /p_teslas,\n /lisice, /skinilisice, /pduty\n{03adfc}Komande za FIB: /f_urus, /f_gklasa, /f_tesla{ffffff}\n{03adfc}Komande za Zemunski Klan: {ffffff}/z_urus, /z_aventador, /z_teslas, /z_gklasam, /z_cfmoto625, /z_rover, /lisice\n /otvori, /zatvori, /otkljucaj, /zakljucaj, /lisice, /skinilisice\n{03adfc}Komande za organizacije: {ffffff}/orginv, /leaveorg\n{03adfc}Komande za lidere: {ffffff}/orgkick\n{03adfc}Admin komande: {ffa500}/akomande", "{03adfc}Izadji", "");
	return 1;
}

CMD:pduty(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) return NisteOvlasceni(playerid);
	if(pADuty[playerid]) return SCM(playerid, SIVA, "Prvo iskljucite admin duznost!");
	if(PDuty[playerid]) return SCM(playerid, SIVA, "Prvo iskljucite promoter duznost!");
	if(IsPlayerInRangeOfPoint(playerid, 3, 254.6660,77.2368,1003.6406)) return SCM(playerid, SIVA, "Niste u policijskoj stanici!");
	if(!policeDuty[playerid]) {
		policeDuty[playerid] = 1;
		SetPlayerSkin(playerid, 280);
		va_SCM(playerid, PLAVA, "[{ffffff}Police Duty{0000ff}]: {ffffff}Policajac {0000ff}%s {ffffff}je sada na duznosti!", GetName(playerid));
	}
	else if(policeDuty[playerid]) {
		policeDuty[playerid] = 0;
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		va_SCM(playerid, PLAVA, "[{ffffff}Police Duty{0000ff}]: {ffffff}Policajac {0000ff}%s {ffffff}vise nije na duznosti.", GetName(playerid));
	}
	return 1;
}

CMD:kick(playerid, params[]) {
	new id, razlog[128];
	if(PlayerInfo[playerid][pAdmin] < 1) return NisteOvlasceni(playerid);
	if(!pADuty[playerid]) return SCM(playerid, SIVA, "Morate biti na duznosti (/aduty)");
	if(sscanf(params, "us[128]", id, razlog)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/kick [ID IGRACA] [RAZLOG]");
	if(!IsPlayerConnected(playerid)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(PlayerInfo[playerid][pAdmin] < PlayerInfo[id][pAdmin]) return SCM(playerid, SIVA, "Ne mozete kikovati admina veceg nivoa od Vas!");
	va_SCMTA(SIVA, "Admin {ffffff}%s {696969}je kikovao igraca {ffffff}%s{696969}. Razlog: {ffffff}%s.", GetName(playerid), GetName(id), razlog);
	SetTimerEx("KickPlayer", 1000, false, "i", id);
	return 1;
}

CMD:giveweaponall(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return 0;
	new weaponid;
	if(sscanf(params, "i", weaponid)) return SCM(playerid, -1, "/giveweapon [weapon id]");
	foreach(new i : Player) GivePlayerWeapon(i, weaponid, 500);
	return 1;
}

CMD:gps(playerid, params[]) {
	#pragma unused params
	SPD(playerid, d_gps, DIALOG_STYLE_LIST, "{03adfc}GPS", "{03adfc}1. {ffffff}Banka\n{696969}2. Auto skola(Nedostupno)\n{03adfc}3. Poslovi", "{03adfc}Izaberi", "{03adfc}Odustani");
	return 1;
}

CMD:lisice(playerid, params[]) {
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Nema")) return NisteOvlasceni(playerid);
	new id, Float: pos[2][3], str[128];
	if(sscanf(params, "u", id)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/lisice [ID IGRACA]");
	if(id == playerid) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Ne mozete staviti lisice sami sebi!");
	if(!IsPlayerConnected(playerid)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, SIVA, "Ne smete biti u vozilu!");
	if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, SIVA, "Igrac ne sme biti u vozilu!");
	if(!strcmp(PlayerInfo[playerid][pZatvoren], "Da")) return SCM(playerid, SIVA, "Ne mozete stavljati/skidate lisice, u zatvoru ste!");
	if(!strcmp(PlayerInfo[playerid][pZavezan], "Da")) return SCM(playerid, SIVA, "Vi ste zavezani ne mozete da stavljate/skidate lisice drugim igracima!");
	GetPlayerPos(playerid, pos[0][0], pos[0][1], pos[0][2]);
	GetPlayerPos(id, pos[1][0], pos[1][1], pos[1][2]);
	if(GetDistanceBetweenPoints(pos[0][0], pos[0][1], pos[0][2], pos[1][0], pos[1][1], pos[1][2]) > 5.0) return SCM(playerid, SIVA, "Taj igrac je previse daleko!");
	if(!strcmp(PlayerInfo[playerid][pZavezan], "Da")) {
		format(str, sizeof(str), "Ne");
		PlayerInfo[id][pZavezan] = str;
		ProxDetectorf(20, playerid, "* %s skida lisice igracu %s.", GetName(playerid), GetName(id));
		SetPlayerSpecialAction(id, SPECIAL_ACTION_NONE);
	} else if(!strcmp(PlayerInfo[playerid][pZavezan], "Ne")) {
		format(str, sizeof(str), "Da");
		PlayerInfo[id][pZavezan] = str;
		ProxDetectorf(20, playerid, "* %s vadi lisice i stavlja ih igracu %s.", GetName(playerid), GetName(id));
		SetPlayerAttachedObject(id, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
		SetPlayerSpecialAction(id, SPECIAL_ACTION_CUFFED);
	}
	return 1;
}

CMD:prevoznovca(playerid, params[]) {
	#pragma unused params
	new vehid =GetPlayerVehicleID(playerid);
	if(GetVehicleModel(vehid) != 498) return SCM(playerid, SIVA, "Niste u kombiju!");
	if(IsPlayerWorking[playerid]) return SCM(playerid, SIVA, "Vec radite posao, ako zelite da prevozite novac, ukucajte /prekiniposao, zatim /prevoznovca.");
	SCM(playerid, -1, "Posao je uspesno pokrenut, pratite markere.");
	SetPlayerCheckpoint(playerid, 1468.7570,-1025.2145,23.9290, 5);
	IsPlayerWorking[playerid] = 1;
	// jobprogress[playerid] = 1;
	TogglePlayerControllable(playerid, 1);
	return 1;
}

CMD:stuck(playerid, params) {
	#pragma unused params
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	TogglePlayerControllable(playerid, 1);
	SetPlayerPos(playerid, pos[0], pos[1], floatadd(pos[2], 5)); //pos[2] += 5;
	return 1;
}

CMD:exitveh(playerid, params[]) {
	#pragma unused params
	TogglePlayerControllable(playerid, 1);
	RemovePlayerFromVehicle(playerid);
	return 1;
}

CMD:prekiniposao(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pPosao], "Bus Vozac") || strcmp(PlayerInfo[playerid][pPosao], "Bankar")) return SCM(playerid, SIVA, "Nemate posao.");
	if(!IsPlayerWorking[playerid]) return SCM(playerid, SIVA, "Trenutno ne radite posao.");
	DisablePlayerCheckpoint(playerid);
	IsPlayerWorking[playerid] = 0;
	jobprogress[playerid] = 0;
	TogglePlayerControllable(playerid, 1);
	return 1;
}

CMD:prevozputnika(playerid, params[]) {
	#pragma unused params
	new vehid = GetPlayerVehicleID(playerid);
	if(strcmp(PlayerInfo[playerid][pPosao], "Bus Vozac")) return SCM(playerid, SIVA, "Niste bus vozac!");
	if(IsPlayerWorking[playerid]) return SCM(playerid, SIVA, "Vec radite posao, ako zelite da prevozite putnike, ukucajte /prekiniposao, zatim ukucajte /prevozputnika.");
	if(GetVehicleModel(vehid) != 431) return SCM(playerid, SIVA, "Niste u autobusu!");
	SCM(playerid, -1, "Posao je uspesno pokrenut, pratite markere.");
	SetPlayerCheckpoint(playerid, 1269.8174,-1844.3251,12.9815, 5);
	IsPlayerWorking[playerid] = 1;
	jobprogress[playerid] = 1;
	TogglePlayerControllable(playerid, 1);
	return 1;
}

CMD:getajob(playerid, params[]) {
	#pragma unused params
	if(!IsPlayerInRangeOfPoint(playerid, 3, 358.2361,178.6533,1008.3828)) SCM(playerid, SIVA, "Niste u vladi ili niste na salteru!");
	if(strcmp(PlayerInfo[playerid][pPosao], "Nema")) return SCM(playerid, SIVA, "Vi vec imate posao! Ako zelite da se zaposlite, dodjite na salter za otkaz i ukucajte /quitjob");
	SPD(playerid, d_joblist, DIALOG_STYLE_LIST, "{03adfc}Lista poslova", "{0000ff}1. {ffffff}Bus Vozac\n{0000ff}2. {ffffff}Bankar\n{696969}3. Farmer(Nedostupno)\n{696969}4. Taksista(Nedostupno)", "{03adfc}Izadji", "");
	return 1;
}

CMD:inv(playerid, params[]) {
	#pragma unused params
	new str[128];
	if(!strcmp(PlayerInfo[playerid][pVozackaDozvola], "Ima")) format(str, sizeof(str), "Oruzje\nVozacka Dozvola\nLicna Karta");
	else format(str, sizeof(str), "Oruzje\nVozacka Dozvola(%s)\nLicna Karta", PlayerInfo[playerid][pVozackaDozvola]);
	SPD(playerid, d_inventar, DIALOG_STYLE_LIST, "Inventar", str, "Izaberi", "Odustani");
	return 1;
}

CMD:orginv(playerid, params[]) {
	#pragma unused params
	new il[128], il2[128];
	format(il, sizeof(il), "%s Inventory", PlayerInfo[playerid][pOrganizacija]);
	foreach(new i : Orgs) {
		if(PlayerInfo[playerid][pOrganizacija] == OrgInfo[i][orgIme]) {
			format(il2, sizeof(il2), "Droga(%dg)\nLisice(%d)\nAK-47\nM4\nGlock 19", OrgInfo[i][orgDrugs], OrgInfo[i][orgLisice]);
			break;
		}
	}
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "FIB")) SPD(playerid, d_inv_org_fib, DIALOG_STYLE_LIST, "FIB Inventory", "Lisice\nAK-47\nM4", "Uzmi", "Odustani");
	else if(!strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) SPD(playerid, d_inv_org_lspd, DIALOG_STYLE_LIST, "LSPD Inventory", "Lisice\nAK-47\nM4", "Uzmi", "Odustani");
	else if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Bolnica")) SPD(playerid, d_inv_org_bolnica, DIALOG_STYLE_LIST, "Bolnica Inventory", "Med Kit\nGlock 19", "Uzmi", "Odustani");
	else if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Yakuza") || !strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan") || !strcmp(PlayerInfo[playerid][pOrganizacija], "Crveni")) SPD(playerid, d_inv_org_ilegalna, DIALOG_STYLE_LIST, il, il2, "Uzmi", "Odustani");
	else SCM(playerid, SIVA, "Da vidite Vas inventar kucajte /inv");
	return 1;
}

CMD:listaposlova(playerid, params[]) {
	#pragma unused params
	// if(!IsPlayerInRangeOfPoint(playerid, 3, 361.8299,173.6672,1008.3828)) return SCM(playerid, SIVA, "Niste u vladi ili niste na salteru!");
	SPD(playerid, d_listaposlova, DIALOG_STYLE_LIST, "{03adfc}Lista poslova", "{0000ff}1. {ffffff}Bus Vozac\n{0000ff}2. {ffffff}Bankar\n{696969}3. Farmer(Nedostupno)\n{696969}4. Taksista(Nedostupno)", "{03adfc}Izadji", "");
	return 1;
}

CMD:quitjob(playerid, params[]) {
	#pragma unused params
	new string[128];
	format(string, sizeof(string), "Nema");
	if(!IsPlayerInRangeOfPoint(playerid, 3, 358.2364,168.9949,1008.3828)) return SCM(playerid, SIVA, "Niste u vladi ili niste na salteru!");
	if(!strcmp(PlayerInfo[playerid][pPosao], string)) return SCM(playerid, SIVA, "Nemate posao!");
	if(IsPlayerWorking[playerid]) return SCM(playerid, SIVA, "Morate prekinuti posao da bi ste dali otkaz!");
	PlayerInfo[playerid][pPosao] = string;
	IsPlayerWorking[playerid] = 0;
	jobprogress[playerid] = 0;
	SCM(playerid, -1, "Uspesno ste dali otkaz!");
	return 1;
}

CMD:kredit(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 2.5, 2316.6208,-9.9597,26.7422) || IsPlayerInRangeOfPoint(playerid, 2.5, 1103.7697,1051.5986,-19.9389)) {
		if(!strcmp(PlayerInfo[playerid][pRacun], "Ne")) return SCM(playerid, SIVA, "Vi nemate racun!");
		new novac;
		if(sscanf(params, "i", novac)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/kredit [novac]");
		if(novac > 100000 && novac < 20000) return SCM(playerid, SIVA, "Ne mozete uzeti manje od $20000 ili vise od $100000");
		if(PlayerInfo[playerid][pBanka] < novac) return SCM(playerid, SIVA, "Trenutno, ne mozete da uzmete kredit!");
		if(PlayerInfo[playerid][pRate] > 0) return SCM(playerid, SIVA, "Vec imate neisplacen kredit!");
		PlayerInfo[playerid][pRate] = 10;
		PlayerInfo[playerid][pKredit] = novac;
		va_GameTextForPlayer(playerid, "~g~$%d", 2500, 1, novac);
		GivePlayerMoney(playerid, novac);
		va_SCM(playerid, ZELENA, "[BANKA]: {ffffff}Uzeli ste se kredit od $%d", novac);
	} else SCM(playerid, SIVA, "Niste u banci ili niste kod saltera za uzimanje kredita!");
	return 1;
}

CMD:withdraw(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 2.5, 2316.6213,-15.4728,26.7422) || IsPlayerInRangeOfPoint(playerid, 2.5, 1103.7705,1055.1908,-19.9389)) {
		if(!strcmp(PlayerInfo[playerid][pRacun], "Ne")) return SCM(playerid, SIVA, "Vi nemate racun!");
		new novac;
		if(sscanf(params, "i", novac)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/withdraw [novac]");
		if(novac > PlayerInfo[playerid][pBanka]) return SCM(playerid, SIVA, "Nemate dovoljno novca na racunu!");
		if(novac < 1) return SCM(playerid, SIVA, "Withdraw ne moze biti manji od $1!");
		GivePlayerMoney(playerid, novac);
		PlayerInfo[playerid][pBanka] -= novac;
		va_GameTextForPlayer(playerid, "~g~$%d", 2500, 1, novac);
		SavePlayer(playerid);
	} else SCM(playerid, SIVA, "Niste u banci ili niste kod saltera za withdraw!");
	return 1;
}

CMD:deposit(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 2.5, 2316.6211,-12.6467,26.7422) || IsPlayerInRangeOfPoint(playerid, 2.5, 1103.7705,1055.1908,-19.9389)) {
		if(!strcmp(PlayerInfo[playerid][pRacun], "Ne")) return SCM(playerid, SIVA, "Vi nemate racun!");
		new novac;
		if(sscanf(params, "i", novac)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/deposit [novac]");
		if(PlayerInfo[playerid][pRate] > 0) return SCM(playerid, SIVA, "Ne mozete koristiti ovu komandu dok ne isplatite sve rate!");
		if(novac > GetPlayerMoney(playerid)) return SCM(playerid, SIVA, "Nemate dovoljno novca!");
		if(novac < 1) return SCM(playerid, SIVA, "Deposit ne moze biti manji od $1!");
		GivePlayerMoney(playerid, -novac);
		PlayerInfo[playerid][pBanka] += novac;
		va_GameTextForPlayer(playerid, "~r~-$%d", 2500, 1, novac);
		SavePlayer(playerid);
	} else SCM(playerid, SIVA, "Niste u banci ili niste kod saltera za deposit!");
	return 1;
}

CMD:otvoriracun(playerid, params[]) {
	#pragma unused params
	if(IsPlayerInRangeOfPoint(playerid, 2.5, 2316.6213,-7.2423,26.7422) || IsPlayerInRangeOfPoint(playerid, 2.5, 1103.7693,1048.0475,-19.9389)) {
		if(GetPlayerScore(playerid) < 18) return SCM(playerid, SIVA, "Morate imati 18 godina da bi otvorili racun!");
		if(!strcmp(PlayerInfo[playerid][pRacun], "Da")) return SCM(playerid, SIVA, "Vi vec imate racun!");
		SCM(playerid, PLAVA_NEBO, "Uspesno ste otvorili racun, to ce Vas kostati $500!");
		GameTextForPlayer(playerid, "~r~-$500", 2500, 1);
		GivePlayerMoney(playerid, -500);
		PlayerInfo[playerid][pRacun] = "Da";
		SavePlayer(playerid);
	} else SCM(playerid, SIVA, "Niste u banci ili niste na salteru za otvaranje bankovnog racuna!");
	return 1;
}

CMD:skinihrent(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] == -1) return SCM(playerid, SIVA, "Vi nemate kucu!");
	new string[512], niko[128];
	format(niko, sizeof(niko), "Niko");
	for(new i = 0; i <= MAX_HOUSES; i++) {
		if(PlayerInfo[playerid][pKuca] == i) {
			HouseInfo[i][hRent] = niko;
			HouseInfo[i][hOnRent] = "Ne";
			HouseInfo[i][hRented] = 0;
			DestroyPickup(hPickup[i]);
			Delete3DTextLabel(hLabel[i]);
			format(string, sizeof(string), "{ffa500}[ {ffffff}Kuca {ffa500}]\n{ffa500}Vlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d", HouseInfo[i][hOwner], HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
            hPickup[i] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 10.0, 0, 0);
			SaveHouse(i);
			break;
		}
	}
	return 1;
}

CMD:postavihrent(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] == -1) return SCM(playerid, SIVA, "Vi nemate kucu!");
	SPD(playerid, d_hrentcena, DIALOG_STYLE_INPUT, "{ffa500}Cena rent kuce", "{ffffff}Unesite zeljenu cenu za rent vase kuce:", "{ffa500}U redu", "");
	return 1;
}

CMD:sellhouse(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] == -1) return SCM(playerid, SIVA, "Vi nemate kucu!");
	new niko[128];
	format(niko, sizeof(niko), "Niko");
	for(new i = 0; i <= MAX_HOUSES; i++) {
		if(PlayerInfo[playerid][pKuca] == i) {
			HouseInfo[i][hOwner] = niko;
			HouseInfo[i][hOwned] = 0;
			GivePlayerMoney(playerid, HouseInfo[i][hCena]);
			HouseInfo[i][hCena] -= 50000;
			PlayerInfo[playerid][pKuca] = -1;
			RefreshPickupLabel(i, HOUSE);
			SavePlayer(playerid);
			SaveHouse(i);
			break;
		}	
	}
	return 1;
}

CMD:organizacije(playerid, params[]) {
	#pragma unused params
	SPD(playerid, d_organizacije, DIALOG_STYLE_MSGBOX, "Lista organizacija", "{03adfc}1 - LSPD (drzavna organizacija)\n{ffff00}2 - FIB (drzavna organizacija)\n{ff0000}3 - Bolnica (drzavna organizacija)\n{00ff00}4 - Zemunski Klan (ilegalna organizacija)\n}{aa3333}5 - Crveni (ilegalna organizacija)\n{fffb00}6 - Yakuza (ilegalna organizacija)", "{ffffff}Zatvori", "");
	return 1;
}

CMD:skinilidera(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 2) return NisteOvlasceni(playerid);
	new id, orgfile[128], pid, pfile[128], niko[128];
	if(sscanf(params, "i", id)) {
		SCM(playerid, CRVENA, "[USAGE]: /skinilidera [id organizacije]");
		SCM(playerid, -1, "ID Organizacija:");
		SCM(playerid, PLAVA_NEBO, "1 - LSPD(drzavna organizacija)");
		SCM(playerid, ZUTA, "2 - FIB(drzavna organizacija)");
		SCM(playerid, CRVENA, "3 - Bolnica(drzavna organizacija)");
		SCM(playerid, ZELENA, "4 - Zemunski Klan(ilegalna organizacija)");
		SCM(playerid, SVETLA_CRVENA, "5 - Crveni(ilegalna organizacija)");
		SCM(playerid, SVETLA_ZUTA, "6 - Yakuza(ilegalna organizacija)");
		return 1;
	}
	format(orgfile, sizeof(orgfile), ORGPATH, id);
	format(niko, sizeof(niko), "Niko");
	if(id < 0 || id > 6) {
		SCM(playerid, PLAVA_NEBO, "1 - LSPD(drzavna organizacija)");
		SCM(playerid, ZUTA, "2 - FIB(drzavna organizacija)");
		SCM(playerid, CRVENA, "3 - Bolnica(drzavna organizacija)");
		SCM(playerid, ZELENA, "4 - Zemunski Klan(ilegalna organizacija)");
		SCM(playerid, SVETLA_CRVENA, "5 - Crveni(ilegalna organizacija)");
		SCM(playerid, SVETLA_ZUTA, "6 - Yakuza(ilegalna organizacija)");
		return 1;
	}
	pid = GetPlayerID(OrgInfo[id][orgLeader]);
	if(pid == -1) {
		new ime[128];
		format(ime, sizeof(ime), OrgInfo[id][orgLeader]);
		format(pfile, sizeof(pfile), ime);
		INI_ParseFile(pfile, "LoadUser_%s", .bExtra = true, .extra = SKIDANJEID);
		PlayerInfo[SKIDANJEID][pLeader] = 0;
		Sacuvaj(SKIDANJEID, ime);
	} else {
		PlayerInfo[pid][pLeader] = 0;
		SavePlayer(pid);
	}
	OrgInfo[id][orgLeader] = niko;
	RefreshPickupLabel(id, 2);
	SaveOrg(id);
	va_SCMTA(-1, "%s {696969}vise nije lider organizacije {ffffff}%s.", GetName(pid), OrgInfo[id][orgIme]);
	return 1;
} 

CMD:makeleader(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 2) return NisteOvlasceni(playerid);
	new id, orgid, string[128];
	if(sscanf(params, "ui", id, orgid)) { 
		SCM(playerid, CRVENA, "[USAGE]: {ffffff}/makeleader [id igraca] [id organizacije]");
		SCM(playerid, SIVA, "ID Organizacija:");
		SCM(playerid, PLAVA_NEBO, "1 - LSPD(drzavna organizacija)");
		SCM(playerid, ZUTA, "2 - FIB(drzavna organizacija)");
		SCM(playerid, CRVENA, "3 - Bolnica(drzavna organizacija)");
		SCM(playerid, ZELENA, "4 - Zemunski Klan(ilegalna organizacija)");
		SCM(playerid, SVETLA_CRVENA, "5 - Crveni(ilegalna organizacija)");
		SCM(playerid, SVETLA_ZUTA, "6 - Yakuza(ilegalna organizacija)");
		return 1;
	}
	if(PlayerInfo[playerid][pLeader] != 0) return va_SCM(playerid, SIVA, "[GRESKA]: {ffffff}Igrac %s je lider neke organizacije!", GetName(playerid));
	if(orgid < 0 || orgid > 6) {
		SCM(playerid, SIVA, "ID Organizacija:");
		SCM(playerid, PLAVA_NEBO, "1 - LSPD(drzavna organizacija)");
		SCM(playerid, ZUTA, "2 - FIB(drzavna organizacija)");
		SCM(playerid, CRVENA, "3 - Bolnica(drzavna organizacija)");
		SCM(playerid, ZELENA, "4 - Zemunski Klan(ilegalna organizacija)");
		SCM(playerid, SVETLA_CRVENA, "5 - Crveni(ilegalna organizacija)");
		SCM(playerid, SVETLA_ZUTA, "6 - Yakuza(ilegalna organizacija)");
		return 1;
	}
	PlayerInfo[playerid][pLeader] = orgid;
	OrgInfo[orgid][orgLeader] = GetName(id);
	switch(orgid) {
		case 1: format(string, sizeof(string), "LSPD");
		case 2: format(string, sizeof(string), "FIB");
		case 3: format(string, sizeof(string), "Bolnica");
		case 4: format(string, sizeof(string), "Zemunski Klan");
		case 5: format(string, sizeof(string), "Crveni");
		case 6: format(string, sizeof(string), "Yakuza");
	}
	PlayerInfo[playerid][pOrganizacija] = string;
	SavePlayer(id);
	SaveOrg(orgid);
	va_SCM(playerid, SIVA, "Uspesno ste postavili lidera organizacije {ffffff}%s {696969}igracu {ffffff}%s.", OrgInfo[orgid][orgIme], GetName(id));
	va_SCMTA(-1, "%s {696969}je postao leader organizacije {ffffff}%s.", GetName(id), OrgInfo[orgid][orgIme]);
	Delete3DTextLabel(orgLabel[orgid]);
	#define i orgid
	format(string, sizeof(string), "{0000ff}[ {ffffff}%s {0000ff}]\n{ffffff}Leader: {0000ff}%s", OrgInfo[i][orgIme], OrgInfo[i][orgLeader]);
	orgLabel[i] = Create3DTextLabel(string, -1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ], 20.0, 0, 0);
	#undef i
	return 1;
}

CMD:addmem(playerid, params[]) {
	new id, str[128];
	if(PlayerInfo[playerid][pLeader] == 0) return NisteOvlasceni(playerid);
	if(sscanf(params, "uii", id)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/addmem [id igraca]");
	if(!IsPlayerConnected(playerid)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(!strcmp(PlayerInfo[id][pOrganizacija], "Niko")) return SCM(playerid, SIVA, "Igrac je vec u nekoj organizaciji!");
	format(str, sizeof(str), "");
	PlayerInfo[id][pOrganizacija] = str;
	format(str, sizeof(str), "%s", PlayerInfo[playerid][pOrganizacija]);
	PlayerInfo[id][pOrganizacija] = str;
	va_SCMTA(SIVA, "Igrac {ffffff}%s {696969} je postao clan organizacije {ffffff}%s{696969}.", GetName(id), PlayerInfo[id][pOrganizacija]);
	SavePlayer(id);
	return 1;
}

CMD:napraviorg(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 4) return NisteOvlasceni(playerid);
	if(editaorg[playerid] != -1) return SCM(playerid, SIVA, "Vec pravite organizaciju!");
	new Float: X, Float: Y, Float: Z, i = NewID(ORG), niko[128];
	format(niko, sizeof(niko), "Niko");
	editaorg[playerid] = i;
	OrgInfo[i][orgLeader] = niko;
	OrgInfo[i][orgMember1] = niko;
	OrgInfo[i][orgMember2] = niko;
	OrgInfo[i][orgMember3] = niko;
	OrgInfo[i][orgMember4] = niko;
	OrgInfo[i][orgMember5] = niko;
	OrgInfo[i][orgMember6] = niko;
	OrgInfo[i][orgMember7] = niko;
	OrgInfo[i][orgMember8] = niko;
	OrgInfo[i][orgMember9] = niko;
	OrgInfo[i][orgMember10] = niko;
	OrgInfo[i][orgMember11] = niko;
	OrgInfo[i][orgMember12] = niko;
	OrgInfo[i][orgMember13] = niko;
	OrgInfo[i][orgMember14] = niko;
	OrgInfo[i][orgMember15] = niko;
	OrgInfo[i][orgMember16] = niko;
	OrgInfo[i][orgMember17] = niko;
	OrgInfo[i][orgMember18] = niko;
	OrgInfo[i][orgMember19] = niko;
	OrgInfo[i][orgMember20] = niko;
	OrgInfo[i][orgMember21] = niko;
	OrgInfo[i][orgMember22] = niko;
	OrgInfo[i][orgMember23] = niko;
	OrgInfo[i][orgMember24] = niko;
	OrgInfo[i][orgMember25] = niko;
	OrgInfo[i][orgMember26] = niko;
	OrgInfo[i][orgMember27] = niko;
	OrgInfo[i][orgMember28] = niko;
	OrgInfo[i][orgMember29] = niko;
	OrgInfo[i][orgMember30] = niko;
	OrgInfo[i][orgMember31] = niko;
	OrgInfo[i][orgMember32] = niko;
	OrgInfo[i][orgMember33] = niko;
	OrgInfo[i][orgMember34] = niko;
	OrgInfo[i][orgMember35] = niko;
	OrgInfo[i][orgMember36] = niko;
	OrgInfo[i][orgMember37] = niko;
	OrgInfo[i][orgMember38] = niko;
	OrgInfo[i][orgMember39] = niko;
	OrgInfo[i][orgMember40] = niko;
	OrgInfo[i][orgMember41] = niko;
	OrgInfo[i][orgMember42] = niko;
	OrgInfo[i][orgMember43] = niko;
	OrgInfo[i][orgMember44] = niko;
	OrgInfo[i][orgMember45] = niko;
	OrgInfo[i][orgMember46] = niko;
	OrgInfo[i][orgMember47] = niko;
	OrgInfo[i][orgMember48] = niko;
	OrgInfo[i][orgMember49] = niko;
	OrgInfo[i][orgMember50] = niko;
	OrgInfo[i][orgMoney] = 0;
	OrgInfo[i][orgDrugs] = 0;
	OrgInfo[i][orgMats] = 0;
	OrgInfo[i][orgGlock19] = -1;
	OrgInfo[i][orgAK_47] = -1;
	OrgInfo[i][orgM4] = -1;
	OrgInfo[i][orgLisice] = -1;
	GetPlayerPos(playerid, X, Y, Z);
	OrgInfo[i][orgX] = X;
	OrgInfo[i][orgY] = Y;
	OrgInfo[i][orgZ] = Z;
	SaveOrg(i);
	orgPickup[i] = CreatePickup(1314, 1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ]);
	SCM(playerid, PLAVA, "Uspesno ste zapoceli pravljenje organizacije!");
	Itter_Add(Houses, i);
	SPD(playerid, d_orgime, DIALOG_STYLE_INPUT, "{0000ff}Ime organizacije", "{ffffff}Unesite ime organizacije u polje za kucanje:", "{0000ff}U redu", "{0000ff}Odustani");
	return 1;
}

CMD:promovisi(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pPromoter], "Ne")) return NisteOvlasceni(playerid);
	SCMTA(ZELENA, "====================[ {ffffff}Tesla RP {00ff00}]====================");
	SCMTA(ZELENA, "Tesla Role Play je server na kome mogu igrati do cak 1000 igraca.");
	SCMTA(ZELENA, "Takodje ima 6 organizacija, prave marke automobila.");
	SCMTA(ZELENA, "Posaljite vasim prijateljima discord link!");
	va_SCMTA(ZELENA, "Promovisao: %s", GetName(playerid));
	SCMTA(ZELENA, "=================================================");
	return 1;
}

CMD:stats(playerid, params[]) {
	#pragma unused params
	new dialog[2048], str[512];
	format(str, sizeof(str), "------- {03adfc}Osnovni podaci {ffffff}-------\n");
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Ime_Prezime: {ffffff}%s\n", GetName(playerid));
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}ID: {ffffff}%d\n", playerid);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Godine: {ffffff}%d\n", PlayerInfo[playerid][pGodine]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Respekti: {ffffff}%d/%d\n", PlayerInfo[playerid][pRespekti], PlayerInfo[playerid][pNeededRep]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Posao: {ffffff}%s\n", PlayerInfo[playerid][pPosao]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Organizacija: {ffffff}%s\n", PlayerInfo[playerid][pOrganizacija]);
	strcat(dialog, str);
	format(str, sizeof(str), "------- {03adfc}Racun {ffffff}-------\n");
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Novac: {ffffff}%d\n", PlayerInfo[playerid][pBanka]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Rate kredita: {ffffff}%d\n", PlayerInfo[playerid][pRate]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Kredit: {ffffff}%d\n", PlayerInfo[playerid][pKredit]);
	strcat(dialog, str);
	format(str, sizeof(str), "------- {03adfc}Kuce {ffffff}-------\n");
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Adresa: {ffffff}%d\n", PlayerInfo[playerid][pKuca]);
	strcat(dialog, str);
	format(str, sizeof(str), "------- {03adfc}Ovlascenje {ffffff}-------\n");
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Admin: {ffffff}%d\n", PlayerInfo[playerid][pAdmin]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Promoter: {ffffff}%s\n", PlayerInfo[playerid][pPromoter]);
	strcat(dialog, str);
	format(str, sizeof(str), "{03adfc}Lider: {ffffff}%d\n", PlayerInfo[playerid][pLeader]);
	strcat(dialog, str);
	SPD(playerid, d_stats, DIALOG_STYLE_MSGBOX, "{03adfc}Licna Karta", dialog, "{03adfc}Izadji", "");
	format(str, sizeof(str), "* %s gleda svoju licnu kartu (/stats)", GetName(playerid));
	ProxDetector(20.0, playerid, str);
	return 1;
}

CMD:house(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] == -1) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Vi nemate kucu!");
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(PlayerInfo[playerid][pKuca] == i) {
			SetPlayerCheckpoint(playerid, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 3.0);
			SCM(playerid, ZELENA, "[GPS]: {ffffff}Pratite marker do odredista na mapi.");
			break;
		}
	}
	return 1;
}

CMD:exithouse(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] == -1) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Vi nemate kucu!");
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(PlayerInfo[playerid][pKuca] == i) {
			if(IsPlayerInRangeOfPoint(playerid, 3.0, HouseInfo[i][hInterX], HouseInfo[i][hInterY], HouseInfo[i][hInterZ])) {
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerInterior(playerid, 0);
				SetPlayerPos(playerid, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
				break;
			}
		}
	}
	return 1;
}

CMD:enterhouse(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] == -1) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Vi nemate kucu!");
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(PlayerInfo[playerid][pKuca] == i) {
			if(IsPlayerInRangeOfPoint(playerid, 3.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ])) {
				SetPlayerVirtualWorld(playerid, i);
				SetPlayerInterior(playerid, HouseInfo[i][hInterID]);
				SetPlayerPos(playerid, HouseInfo[i][hInterX], HouseInfo[i][hInterY], HouseInfo[i][hInterZ]);
				GameTextForPlayer(playerid, "~g~Dobrodosli kuci!", 2000, 3);
				break;
			} else {
				SCM(playerid, SIVA, "Niste kod svoje kuce!");
				break;
			}
		}
	}
	return 1;
}

CMD:kupikucu(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pKuca] != -1) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Vi vec imate kucu!");
	new Float:X, Float:Y, Float:Z;
	for(new i = 0; i < MAX_HOUSES; i++) {
		X = Float:HouseInfo[i][hX];
		Y = Float:HouseInfo[i][hY];
		Z = Float:HouseInfo[i][hZ];
		if(IsPlayerInRangeOfPoint(playerid, 3.0, X, Y, Z)) {
			if(HouseInfo[i][hOwned] == 1) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Kuca je vec kupljena!");
			if(GetPlayerMoney(playerid) < HouseInfo[i][hCena]) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Nemate dovoljno novca!");
			GivePlayerMoney(playerid, -HouseInfo[i][hCena]);
			PlayerInfo[playerid][pNovac] -= HouseInfo[i][hCena];
			va_GameTextForPlayer(playerid, "~r~-$%d", 2000, 1, HouseInfo[i][hCena]);
			PlayerInfo[playerid][pKuca] = i;
			HouseInfo[i][hOwner] = GetName(playerid);
			HouseInfo[i][hOwned] = 1;
			Delete3DTextLabel(hLabel[i]);
			DestroyPickup(hPickup[i]);
			new string[512];
			format(string, sizeof(string), "{ffa500}Vlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}Nivo: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d", HouseInfo[i][hOwner], HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
			hPickup[i] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
			hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 5.0, 0);
			va_SCM(playerid, PLAVA_NEBO, "Cestitamo, kupili ste kucu! Adresa kuce: %d", i);
			SavePlayer(playerid);
			SaveHouse(i);
		}
	}
	return 1;
}

CMD:napravikucu(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 3) return 0;
	new lvl, cena;
	if(sscanf(params, "ii", lvl, cena)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/napravikucu [nivo] [cena]");
	if(IsPlayerSpec[playerid]) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Ne mozete spawnovati vozilo dok spectatujete nekoga! (/specoff).");
	if(cena > MAX_HPRICE || cena < MIN_HPRICE) return va_SCM(playerid, CRVENA, "[USAGE]: {ffffff}Cena mora biti veca od %d i manja od %d", MIN_HPRICE/*+1*/, MAX_HPRICE/*+1*/);
	new Float:X, Float:Y, Float:Z, i = NewID(HOUSE), niko[128], string[512];
	GetPlayerPos(playerid, X, Y, Z);
	format(niko, sizeof(niko), "Niko");
	HouseInfo[i][hOwner] = niko;
	HouseInfo[i][hOwned] = 0;
	HouseInfo[i][hLevel] = lvl;
	HouseInfo[i][hCena] = cena;
	HouseInfo[i][hX] = X;
	HouseInfo[i][hY] = Y;
	HouseInfo[i][hZ] = Z;
	HouseInfo[i][hVirtualWorld] = i;
	if(lvl == 1) {
		HouseInfo[i][hInterID] = 11;
		HouseInfo[i][hInterX] = 2283.04;
		HouseInfo[i][hInterY] = -1140.28;
		HouseInfo[i][hInterZ] = 1050.90;
	} else if(lvl == 2) {
		HouseInfo[i][hInterID] = 2;
		HouseInfo[i][hInterX] = 491.07;
		HouseInfo[i][hInterY] = 1398.50;
		HouseInfo[i][hInterZ] = 1080.26;
	} else if(lvl == 3) {
		HouseInfo[i][hInterID] = 5;
		HouseInfo[i][hInterX] = 140.17;
		HouseInfo[i][hInterY] = 1366.07;
		HouseInfo[i][hInterZ] = 1083.65;
	}
	format(string, sizeof(string), "{ffa500}[{ffffff}Kuca na prodaju{ffa500}]\nVlasnik: {ffffff}Niko\n{ffa500}Cena: {ffffff}%d\n{ffa500}Nivo: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d\n{ffa500}Ako zelite da kupite kucu kucajte /kupikucu", HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
	hPickup[i] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
	hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 5.0, 0);
	SaveHouse(i);
	Itter_Add(Houses, i);
	SCM(playerid, PLAVA_NEBO, "Uspesno ste napravili kucu!");
	return 1;
}

CMD:specoff(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	if(IsPlayerSpec[playerid] == 0) return SCM(playerid, PLAVA_NEBO, "[INFO]: {ffffff}Trenutno nikog ne specate!");
	IsPlayerSpec[playerid] = 0;
	TogglePlayerSpectating(playerid, IsPlayerSpec[playerid]);
	SetPlayerPos(playerid, pX[playerid], pY[playerid], pZ[playerid]);
	SetPlayerInterior(playerid, pI[playerid]);
	SetPlayerVirtualWorld(playerid, pW[playerid]);
	return 1;
}

CMD:spec(playerid, params[]) {
	if(!pADuty[playerid]) return SCM(playerid, SIVA, "Morate biti na duznosti! (/aduty)");
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	new target, Float:X, Float:Y, Float:Z;
	if(sscanf(params, "u", target)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/spec [id igraca]");
	if(!IsPlayerConnected(target)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(target == playerid) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}ID nije validan!");
	IsPlayerSpec[playerid] = 1;
	GetPlayerPos(playerid, X, Y, Z);
	pX[playerid] = X;
	pY[playerid] = Y;
	pZ[playerid] = Z;
	pI[playerid] = GetPlayerInterior(playerid);
	pW[playerid] = GetPlayerVirtualWorld(playerid);
	SetTimerEx("SpecTimer", 1000, true, "ii", playerid, target);
	return 1;
}

CMD:z_cfmoto625(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(471, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod Zemunskog spawna!");
	return 1;
}

CMD:z_gklasam(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(489, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod Zemunskog spawna!");
	return 1;
}

CMD:z_teslas(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(411, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod Zemunskog spawna!");
	return 1;
}

CMD:z_aventador(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(402, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod Zemunskog spawna!");
	return 1;
}

CMD:z_urus(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1280.4720,-828.6748,83.1406)) {
		new veh, Float:X, Float:Y, Float:Z, Float:R, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		veh = CreateVehicle(500, X, Y, Z, R, 157, 157, -1);
		PutPlayerInVehicle(playerid, veh, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehicleColor(vehid, 0, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		// Attach3DTextLabelToVehicle(
		// 	Create3DTextLabel(
		// 		"{00ff00}[ Zemunski Klan ]",
		// 		-1,
		// 		X,
		// 		Y,
		// 		Z,
		// 		10,
		// 		0
		// 	),
		// 	vehid,
		// 	0,
		// 	0,
		// 	0
		// );
	} else SCM(playerid, SIVA, "Niste kod zemunske kuce.");
	return 1;
}

CMD:cc(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	ClearChat(.l = 1000);
	return 1;
}

CMD:p_teslas(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 80.0, 1538.7338,-1676.0779,5.8906)) {
		new Tesla, Float:X, Float:Y, Float:Z, Float:R, edit, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		Tesla = CreateVehicle(411, X, Y, Z, R, 0x000000ff, 0x000000ff, -1);
		edit = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    	AttachDynamicObjectToVehicle(edit, Tesla, 0.000, 0.000, 0.879, 0.000, 0.000, 0.000);
		PutPlayerInVehicle(playerid, Tesla, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehiclePaintjob(vehid, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		Attach3DTextLabelToVehicle(
			Create3DTextLabel(
				"{0000ff}[ LSPD ]",
				-1,
				X,
				Y,
				Z,
				10,
				0
			),
			vehid,
			0,
			0,
			0
		);
	} else SCM(playerid, SIVA, "Niste kod policijske stanice ili niste blizu kod parkinga.");
	return 1;
}

CMD:p_skodarapid(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 80.0, 1538.7338,-1676.0779,5.8906)) {
		new Skodarapid, Float:X, Float:Y, Float:Z, Float:R, edit, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		Skodarapid = CreateVehicle(421, X, Y, Z, R, 0xffffffff, 0xffffffff, -1);
		edit = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    	AttachDynamicObjectToVehicle(edit, Skodarapid, 0.000, 0.150, 0.679, 0.000, 0.000, 2.699);
		PutPlayerInVehicle(playerid, Skodarapid, 0);
		vehid = GetPlayerVehicleID(playerid);
		ChangeVehiclePaintjob(vehid, 0);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		Attach3DTextLabelToVehicle(
			Create3DTextLabel(
				"{0000ff}[ LSPD ]",
				-1,
				X,
				Y,
				Z,
				10,
				0
			),
			vehid,
			0,
			0,
			0
		);
	} else SCM(playerid, SIVA, "Niste kod policijske stanice ili niste blizu kod parkinga.");
	return 1;
}

CMD:p_gklasa(playerid, params[]) {
	#pragma unused params
	if(strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) return 0;
	if(IsPlayerInRangeOfPoint(playerid, 80.0, 1538.7338,-1676.0779,5.8906)) {
		new Gklasa, Float:X, Float:Y, Float:Z, Float:R, edit, vehid;
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		Gklasa = CreateVehicle(489, X, Y, Z, R, 0x000000ff, 0x000000ff, -1);
		edit = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    	AttachDynamicObjectToVehicle(edit, Gklasa, 0.000, 0.000, 1.200, 0.000, 0.000, 0.000);
		PutPlayerInVehicle(playerid, Gklasa, 0);
		vehid = GetPlayerVehicleID(playerid);
		VehInfo[vehid][vEngine] = 0;
		VehInfo[vehid][vFuel] = 100;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
		Attach3DTextLabelToVehicle(
			Create3DTextLabel(
				"{0000ff}[ LSPD ]",
				-1,
				X,
				Y,
				Z,
				10,
				0
			),
			vehid,
			0,
			0,
			0
		);
	} else SCM(playerid, SIVA, "Niste kod policijske stanice ili niste blizu kod parkinga.");
	return 1;
}

CMD:jp(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 2) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_USEJETPACK) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	else {
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		SetPlayerPos(playerid, X, Y, Z);
	}
	return 1;
}

CMD:otkljucaj(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1265.842651, -775.345886, 1084.255981)) {
			ZakljucanaVrata[ZatvorVrata[0]] = false;
			SaveVr(ZatvorVrata[0]);
		} else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1261.842773, -775.345886, 1084.255981)) {
			ZakljucanaVrata[ZatvorVrata[1]] = false;
			SaveVr(ZatvorVrata[1]);
		}
	}
	if(IsPlayerPoliceman(playerid)) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1261.842773, -775.345886, 1084.255981)) {
			ZakljucanaVrata[ZatvorVrata[2]] = false;
			SaveVr(ZatvorVrata[2]);
		} else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1261.842773, -775.345886, 1084.255981)) {
			ZakljucanaVrata[ZatvorVrata[3]] = false;
			SaveVr(ZatvorVrata[3]);
		}
	}
	return 1;
}

CMD:zakljucaj(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1265.842651, -775.345886, 1084.255981)) {
			if(!ZatvorenaVrata[ZatvorVrata[0]]) return SCM(playerid, SIVA, "Prvo zatvorite vrata.");
			ZakljucanaVrata[ZatvorVrata[0]] = true;
			SaveVr(ZatvorVrata[0]);
		} else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1261.842773, -775.345886, 1084.255981)) {
			if(!ZatvorenaVrata[ZatvorVrata[1]]) return SCM(playerid, SIVA, "Prvo zatvorite vrata.");
			ZakljucanaVrata[ZatvorVrata[1]] = true;
			SaveVr(ZatvorVrata[1]);
		} 
	}
	if(IsPlayerPoliceman(playerid)) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 266.395690, 87.476341, 998.878662)) {
			if(!ZatvorenaVrata[ZatvorVrata[2]]) return SCM(playerid, SIVA, "Prvo zatvorite vrata.");
			ZakljucanaVrata[ZatvorVrata[2]] = true;
			SaveVr(ZatvorVrata[2]);
		} else if(IsPlayerInRangeOfPoint(playerid, 3.0, 266.379943, 82.966346, 998.878601)) {
			if(!ZatvorenaVrata[ZatvorVrata[3]]) return SCM(playerid, SIVA, "Prvo zatvorite vrata.");
			ZakljucanaVrata[ZatvorVrata[3]] = true;
			SaveVr(ZatvorVrata[3]);
		}
	}
	return 1;
}

CMD:zatvori(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1265.842651, -775.345886, 1084.255981)) MoveDynamicObject(ZatvorVrata[0], 1265.842651, -775.345886, 1084.255981, 2.0, 0, 0, 0);
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1261.842773, -775.345886, 1084.255981)) MoveDynamicObject(ZatvorVrata[1], 1261.842773, -775.345886, 1084.255981, 2.0, 0, 0, 0);
	}
	if(IsPlayerPoliceman(playerid)) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 266.395690, 87.476341, 998.878662)) MoveDynamicObject(ZatvorVrata[2], 266.395690, 87.476341, 1001.319213, 2.0, 0, 0, 89.799964);
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 266.379943, 82.966346, 998.878601)) MoveDynamicObject(ZatvorVrata[3], 266.379943, 82.966346, 1001.319213, 2.0, 0, 0, 89.799964);
	}
	return 1;
}

CMD:otvori(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1265.842651, -775.345886, 1084.255981)) {
			if(ZakljucanaVrata[ZatvorVrata[0]]) return SCM(playerid, SIVA, "Vrata su zakljucana.");
			MoveDynamicObject(ZatvorVrata[0], 1265.842651, -775.345886, 1081.783569, 2.0, 0, 0, 0);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1261.842773, -775.345886, 1084.255981)) {
			if(ZakljucanaVrata[ZatvorVrata[1]]) return SCM(playerid, SIVA, "Vrata su zakljucana.");
			MoveDynamicObject(ZatvorVrata[1], 1261.842773, -775.345886, 1081.754028, 2.0, 0, 0, 0);
		}
	}
	if(IsPlayerPoliceman(playerid)) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 266.395690, 87.476341, 1001.319213)) {
			if(ZakljucanaVrata[ZatvorVrata[2]]) return SCM(playerid, SIVA, "Vrata su zakljucana.");
			MoveDynamicObject(ZatvorVrata[2], 266.395690, 87.476341, 998.878662, 2.0, 0, 0, 89.799964);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 266.379943, 82.966346, 1001.319213)) {
			if(ZakljucanaVrata[ZatvorVrata[3]]) return SCM(playerid, SIVA, "Vrata su zakljucana.");
			MoveDynamicObject(ZatvorVrata[3], 266.379943, 82.966346, 998.878601, 2.0, 0, 0, 89.799964);
		}
	}
	return 1;
}

CMD:promduty(playerid, params[]) {
	#pragma unused params
	if(!strcmp(PlayerInfo[playerid][pPromoter], "Ne")) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	if(pADuty[playerid]) return SCM(playerid, PLAVA, "[INFO]: {ffffff}Prvo ugasite {03adfc}Admin Duty {ffffff}kako bi ste mogli ukljuciti {ffa500}Promoter Duty.");
	if(!PDuty[playerid]) {
		PDuty[playerid] = true;
		SetPlayerHealth(playerid, 999999);
		va_SCMTA(-1, "{ffa500}[PROMOTER DUTY]: {ffffff}Promoter {ffa500}%s {ffffff}je sada na duznosti!", GetName(playerid));
	} else {
		PDuty[playerid] = false;
		SetPlayerHealth(playerid, 100);
		va_SCMTA(-1, "{ffa500}[PROMOTER DUTY]: {ffffff}Promoter {ffa500}%s {ffffff}nije vise na duznosti.", GetName(playerid));
	}
	return 1;
}

CMD:skiniprom(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 2) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	new slot, pfile[128], pid, promfile[128], niko[128], ime[128], razlog;
	if(sscanf(params, "is[128]", slot, razlog)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/skiniprom [slot] [razlog]");
	if(slot < 1 || slot > 20) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}Slot ne moze biti manji od 1 ili veci od 20");
	format(promfile, sizeof(pfile), PROMPATH, slot-1);
	format(niko, sizeof(niko), "Niko");
	if(!UzetPromSlot(slot-1)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Slot nije zauzet!");
	format(ime, sizeof(ime), PromInfo[slot-1][promName]);
	pid = GetPlayerID(ime);
	if(pid == -1) {
		format(pfile, sizeof(pfile), USERPATH, ime);
		INI_ParseFile(pfile, "LoadUser_%s", .bExtra = true, .extra = SKIDANJEID);
		PlayerInfo[SKIDANJEID][pPromoter] = "Ne";
		PromInfo[slot-1][promName] = niko;
		PromInfo[slot-1][promDuty] = 0;
		PromInfo[slot-1][promNeaktivnost] = 0;
		Sacuvaj(SKIDANJEID, ime);
		SaveProm(slot-1);
	} else {
		PlayerInfo[pid][pPromoter] = "Ne";
		if(PDuty[pid]) {
			va_SCMTA(-1, "{03adfc}[PROMOTER DUTY]: {ffffff}Promoter {03adfc}%s {ffffff}vise nije na duznosti!", GetName(playerid));
			PDuty[pid] = false;
		}
		PromInfo[slot-1][promName] = niko;
		PromInfo[slot-1][promDuty] = 0;
		PromInfo[slot-1][promNeaktivnost] = 0;
		SavePlayer(pid);
		SaveProm(slot-1);
		va_SCM(pid, NARANDZASTA, "Admin Vam je skinuo promotera! Razlog: %s", razlog);
	}
	va_SCM(playerid, PLAVA_NEBO, "Uspesno ste skinuli promotera %s na slotu %d.", ime, slot);
	return 0;
}

CMD:makeprom(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 2) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	new id, slot;
	if(sscanf(params, "ui", id, slot)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/makeprom [id] [slot]");
	else if(slot < 1 || slot > 20) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}Slot ne moze biti manji od 1 ili veci od 20");
	else if(UzetPromSlot(slot)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Slot je zauzet!");
	else {
		PlayerInfo[id][pPromoter] = "Da";
		PromInfo[slot-1][promName] = GetName(playerid);
		SaveProm(slot-1);
		va_SCM(playerid, NARANDZASTA, "[INFO]: {ffffff}Uspesno ste postavili novog promotera {ffa500}%s {ffffff}!", GetName(id));
		SCM(id, NARANDZASTA, "[INFO]: {ffffff}Postali ste Promoter, cestitamo! Zeli Vam ugnodnu igru {ffa500}Tesla RP Team.");
		Itter_Add(Proms, id);
	}
	return 1;
}

CMD:promoteri(playerid, params[]) {
	#pragma unused params
	new string[3500], str[256], onl[64];
	if(strcmp(PlayerInfo[playerid][pPromoter], "Da")) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Niste ovlasceni da koristite ovu komandu!");
	for(new i = 0; i < MAX_PROMS; i++) {
		if(GetPlayerID(PromInfo[i][promName]) == -1) format(onl, sizeof(onl), "{696969}Offline");
		else format(onl, sizeof(onl), "{00ff00}Offline");
		format(str, sizeof(str), "[{03adfc}%d{ffffff}] - Ime: {03adfc}%s {ffffff}| %s {ffffff}| Neaktivnost: {03adfc}%d{ffffff}min Duty: {03adfc}%d{ffffff}min\n", i, PromInfo[i][promName], onl, PromInfo[i][promNeaktivnost], PromInfo[i][promDuty]);
		strcat(string, str);
	}
	SPD(playerid, d_promlist, DIALOG_STYLE_MSGBOX, "{03adfc}Lista Promotera", string, "{03adfc}U redu", "");
	return 1;
}

CMD:unrent(playerid, params[]) {
	#pragma unused params
	if(renta[playerid] == -1) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Vec rentate neko vozilo!");
	new vehid = renta[playerid];
	DestroyVehicle(vehid);
	rented[vehid] = 0;
	renta[playerid] = -1;
	GameTextForPlayer(playerid, "~b~Unrentali ste vozilo!", 2000, 3);
	return 1;
}

CMD:rent(playerid, params[]) {
	#pragma unused params
	if(IsPlayerInRangeOfPoint(playerid, 3.0, 1561.0580,-2227.5750,13.5469) || IsPlayerInRangeOfPoint(playerid, 3, 1282.4895,-1265.0306,13.6425)) {
		if(renta[playerid] != -1) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Vi vec rentate neko vozilo!");
		SPD(playerid, d_rent, DIALOG_STYLE_LIST, "{03adfc}Vreme rentanja | Fiat 500", "10 min\t\t$1000\n20 min\t\t$2000\n30 min\t\t$3000", "{03adfc}Izaberi", "{03adfc}Odustani");
	} else SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Niste u blizini rent objekta!");
	return 1;
}

CMD:port(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komadnu!");
	SPD(playerid, d_port, DIALOG_STYLE_LIST, "{03adfc}Portovi", "[{03adfc}1{ffffff}] - {03adfc}Spawn\n{ffffff}[{03adfc}2{ffffff}] - {03adfc}Kuca Zemunaca1\n{ffffff}[{03adfc}3{ffffff}] - {03adfc}Spawn Rent\n{ffffff}[{03adfc}4{ffffff}] - {03adfc}Policijska Stanica\n{ffffff}[{03adfc}5{ffffff}] - {03adfc}Bolnica\n{ffffff}[{03adfc}6{ffffff}] - {03adfc}Vlada\n{ffffff}[{03adfc}7{ffffff}] - {03adfc}FIB\n{ffffff}[{03adfc}8{ffffff}] - {03adfc}Autobuska Stanica\n{ffffff}[{03adfc}9{ffffff}] - {03adfc}Banka", "{03adfc}Izaberi", "{03adfc}Odustani");
	return 1;
}

CMD:toci(playerid, params[]) {
	#pragma unused params
    if (
		IsPlayerInRangeOfPoint(playerid, 2.0, 1943.4155,-1767.3209,13.3906) || IsPlayerInRangeOfPoint(playerid, 2.0, 1943.2670,-1774.3669,13.3906)||\
		IsPlayerInRangeOfPoint(playerid, 2.0, 605.0720,1704.5323,6.5634) || IsPlayerInRangeOfPoint(playerid, 2.0, 608.8611,1700.0101,6.5656)||\
		IsPlayerInRangeOfPoint(playerid, 2.0, 611.7049,1694.6202,6.5492) || IsPlayerInRangeOfPoint(playerid, 2.0, 615.9272,1690.4963,6.5688)||\
		IsPlayerInRangeOfPoint(playerid, 2.0, 619.3588,1685.4036,6.5654) || IsPlayerInRangeOfPoint(playerid, 2.0, 621.6530,1679.8074,6.5675)
	) {
        new vehid = GetPlayerVehicleID(playerid), litar, novac;
    	if (!IsPlayerInAnyVehicle(playerid)) return SCM(playerid, CRVENA, "[PUMPA]: {ffffff}Niste u vozilu!");
		if (VehInfo[vehid][vEngine]) return SCM(playerid, CRVENA, "[PUMPA]: {ffffff}Prvo ugasite motor!");
        if(sscanf(params, "i", litar)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/fill [litar]");
        if(litar < 1 || litar > 100) return SCM(playerid, CRVENA, "[PUMPA]: {ffffff}Nivo litra mora biti izmedju 1 ili 100.");
		if (VehInfo[vehid][vFuel] == 100) return SCM(playerid, CRVENA, "[PUMPA]: {ffffff}Vase vozilo je vec napunjeno!");
        if (GetPlayerMoney(playerid) < novac) return SCM(playerid, CRVENA, "[PUMPA]: {ffffff}Nemate dovoljno novca!");
    	novac = litar * 224;
		GameTextForPlayer(playerid, "~b~SACEKAJTE DA SE GORIVO NAPUNI..", 3000, 3);
        VehInfo[vehid][vFuel] += litar;
		if(VehInfo[vehid][vFuel] > 100) VehInfo[vehid][vFuel] = 100;
    	va_GameTextForPlayer(playerid, "~b~Uspesno ste napunili %d litara goriva!", 3000, 3, litar);
		va_GameTextForPlayer(playerid, "~r~-$%d", 2000, 1, novac);
        GivePlayerMoney(playerid, -novac);
		PlayerInfo[playerid][pNovac] -= novac;
    } else SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Niste kod pumpe!");
    return 1;
}

CMD:rtp(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 2) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	new Float:X, Float:Y, Float:Z, Float:ZA, id, interid, vw;
	if(sscanf(params, "u", id)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/tp [id]");
	if(!IsPlayerConnected(id)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(id == playerid) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Nevazeci id!");
	interid = GetPlayerInterior(playerid);
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, ZA);
	if(interid != 0) SetPlayerInterior(id, interid);
	if(vw != 0) SetPlayerVirtualWorld(id, vw);
	SetPlayerPos(id, X, Y, Z);
	SetPlayerFacingAngle(id, ZA);
	va_SCM(playerid, PLAVA_NEBO, "Uspesno ste teleportovali igraca %s do Vas!", GetName(id));
	SCM(id, PLAVA_NEBO, "[INFO]: {ffffff}Teleportovani ste do Admina!");
	return 1;
}

CMD:tp(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	new Float:X, Float:Y, Float:Z, Float:ZA, vehid, id, interid, vw;
	if(sscanf(params, "u", id)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/tp [id]");
	if(!IsPlayerConnected(id)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(id == playerid) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Nevazeci id!");
	GetPlayerPos(id, X, Y, Z);
	GetPlayerFacingAngle(id, ZA);
	interid = GetPlayerInterior(id);
	vw = GetPlayerVirtualWorld(id);
	if(interid != 0) SetPlayerInterior(playerid, interid);
	if(vw != 0) SetPlayerVirtualWorld(playerid, vw);
	if(IsPlayerInAnyVehicle(playerid)) {
		vehid = GetPlayerVehicleID(playerid);
		SetVehiclePos(vehid, X, Y, Z);
		SetVehicleZAngle(vehid, ZA);
		PutPlayerInVehicle(playerid, vehid, 0);
	} else {
		SetPlayerPos(playerid, X, Y, Z);
		SetPlayerFacingAngle(playerid, ZA);
	}
	va_SCM(playerid, PLAVA_NEBO, "Uspesno ste se teleportovali do igraca %s", GetName(id));
	SCM(id, PLAVA_NEBO, "[INFO]: {ffffff}Admin se teleportovao do Vas!");
	return 1;
}

CMD:engine(playerid, params[]) {
	#pragma unused params
	new vehid = GetPlayerVehicleID(playerid), string[128];
	for(new i = 0; i < sizeof(j_kombi); i++) if(vehid == j_kombi[i]) return 0;
	for(new i = 0; i < sizeof(j_bus); i++) if(vehid == j_bus[i]) return 0;
	if(IsPlayerInAnyVehicle(playerid)) {
		if(!VehInfo[vehid][vEngine]) {
			SetTimerEx("StartEngine", 1000, false, "i", playerid);
			TogglePlayerControllable(playerid, 0);
			format(string, sizeof(string), "* %s pokusava da upali motor.", GetName(playerid));
		} else {
			format(string, sizeof(string), "* %s okrece kljuc i gasi motor.", GetName(playerid));
			VehInfo[vehid][vEngine] = 0;
			SetVehicleParamsEx(
				vehid, 
				VehInfo[vehid][vEngine], 
				VehInfo[vehid][vLights], 
				VehInfo[vehid][vAlarm],
				VehInfo[vehid][vDoor],
				VehInfo[vehid][vBonnet],
				VehInfo[vehid][vBoot],
				VehInfo[vehid][vObj]
			);
		}
		ProxDetector(20.0, playerid, string);
	} else SCM(playerid, PLAVA_NEBO, "[INFO]: {ffffff}Niste ni u jednom vozilu!");
	return 1;
}

CMD:unban(playerid, params[]) {
	if (PlayerInfo[playerid][pAdmin] < 2) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
	new slot, bfile[128], pfile[128], niko[128], ime[128];
	if(!pADuty[playerid]) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Morate biti na duznosti!");
	if(sscanf(params, "i", slot)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff} /ban [slot]");
	if(slot < 1 || slot > MAX_PLAYERS) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}Slot mora biti izmedju 1 i 20!");
	format(bfile, sizeof(bfile), BANPATH, slot-1);
	format(niko, sizeof(niko), "Niko");
	if(!strcmp(niko, BannedInfo[slot-1][bName])) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Slot nije zauzet!");
	format(ime, sizeof(ime), BannedInfo[slot-1][bName]);
	format(pfile, sizeof(pfile), USERPATH, ime);
	INI_ParseFile(pfile, "LoadUser_%s", .bExtra = true, .extra = SKIDANJEID);
	PlayerInfo[SKIDANJEID][pBan] = 0;
	format(niko, sizeof(niko), "Nema");
	PlayerInfo[SKIDANJEID][pBanRazlog] = niko;
	format(niko, sizeof(niko), "Niko");
	BannedInfo[slot - 1][bName] = niko;
	Sacuvaj(SKIDANJEID, ime);
	SaveBanned(slot-1);
	va_SCM(playerid, PLAVA_NEBO, "Uspesno ste unbanovali igraca sa slota {ffffff}%d{03adfc}! Ime: %s", slot, ime);
	return 1;
}

CMD:ban(playerid, params[]) {
	if (PlayerInfo[playerid][pAdmin] < 2) return SCM(playerid, CRVENA, "Niste ovlasceni da koristite ovu komandu!");
    if(!pADuty[playerid]) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Morate biti na duznosti!");
	new id, razlog[128], dialog[512], slot;
    if (sscanf(params, "uis[128]", id, slot, razlog)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/ban [id] [slot] [razlog]");
    if (!IsPlayerConnected(id)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	if(slot < 1 || slot > MAX_PLAYERS) return va_SCM(playerid, CRVENA, "[USAGE]: {ffffff}Slot mora biti izmedju 1 ili %d!", MAX_PLAYERS);
	BannedInfo[slot-1][bName] = GetName(id);
	PlayerInfo[id][pBan] = 1;
	PlayerInfo[id][pBanRazlog] = razlog;
	SavePlayer(id);
	SaveBanned(slot-1);
	va_SCMTA(PLAVA_NEBO, "Admin {ffffff}%s {03adfc}je banovao igraca {ffffff}%s{03adfc}! Razlog: {ffffff}%s", GetName(playerid), GetName(id), razlog);
	format(dialog, sizeof(dialog), "{ffffff}Banovani ste sa servera!\n{ffffff}Razlog: {03adfc}%s\n{ffffff}Ako mislite da je ovo greska obratite se na nasem forumu.", GETIP(id), razlog);
	SPD(id, d_ban, DIALOG_STYLE_MSGBOX, "{03adfc}BAN", dialog, "{03adfc}Izadji", "");
	return 1;
}

CMD:givemoney(playerid, params[]) {
	new id, suma, str[256], Float: pos[3];
	if(sscanf(params, "ui", id, suma)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/givemoney [id] [suma]");
	if(!IsPlayerConnected(id)) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Igrac nije online!");
	GetPlayerPos(id, pos[0], pos[1], pos[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 5, pos[0], pos[1], pos[2])) return va_SCM(playerid, SIVA, "Niste blizu igraca %s!", GetName(playerid));
	if(id == playerid) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Ne mozete sami sebi dati novac!");
	if(GetPlayerMoney(playerid) < suma) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Nemate dovoljno novca!");
	if(suma < 1) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}Suma novca mora biti veca od $1!");
	GivePlayerMoney(playerid, -suma);
	PlayerInfo[playerid][pNovac] -= suma;
	va_GameTextForPlayer(playerid, "{ff0000}-$%d", 2000, 1, suma);
	GivePlayerMoney(id, suma);
	PlayerInfo[id][pNovac] += suma;
	va_GameTextForPlayer(playerid, "~g~$%d", 2000, 1, suma);
	format(str, sizeof(str), "* %s daje $%d igracu %s", GetName(playerid), suma, GetName(id));
	ProxDetector(20.0, playerid, str);
	return 1;
}

CMD:setmoney(playerid, params[]) {
	new cmd_code = 0;
	if(PlayerInfo[playerid][pAdmin] >= 2) {
		new id, pare;
		if(sscanf(params, "ui", id, pare)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/setmoney [ID IGRACA] [MONEY]");
		GivePlayerMoney(id, pare);
		SavePlayer(playerid);
		cmd_code = 1;
	}
	return cmd_code;
}

CMD:aduty(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, 0xff0000ff, "Niste ovlasceni da koristite ovu komandu!");
	if(PDuty[playerid]) return SCM(playerid, PLAVA_NEBO, "[INFO]: {ffffff}Prvo ugasite {ffa500}Promoter Duty {ffffff}kako bi ste mogli ukljuciti {03adfc}Admin Duty.");
	if(policeDuty[playerid]) return SCM(playerid, PLAVA_NEBO, "[INFO]: {ffffff}Prvo ugasite {0000ff}Police Duty {ffffff}kako bi ste mogli ukljuciti {03adfc}Admin Duty.");
	if(!pADuty[playerid]) {
		pADuty[playerid] = true;
		SetPlayerHealth(playerid, 999999);
		va_SCMTA(-1, "{03adfc}[ADMIN DUTY]: {ffffff}Admin {03adfc}%s {ffffff}je sada na duznosti!", GetName(playerid));
	} else {
		pADuty[playerid] = false;
		SetPlayerHealth(playerid, 100);
		va_SCMTA(-1, "{03adfc}[ADMIN DUTY]: {ffffff}Admin {03adfc}%s {ffffff}Nije vise na duznosti.", GetName(playerid));
	}
	return 1;
}

CMD:admini(playerid, params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] < 1) return SCM(playerid, 0xff0000ff, "Niste ovlasceni da koristite ovu komandu!");
	new string[3580], str[256], onl[64];
	for(new i = 0; i < MAX_ADMINS; i++) {
		if(GetPlayerID(AdminInfo[i][aName]) == -1) format(onl, sizeof(onl), "{8b8989}Offline");
		else format(onl, sizeof(onl), "{7fff00}Online");
		format(str, sizeof(str), "{03adfc}[{ffffff}%d{03adfc}] {ffffff}- {03adfc}Ime: {03adfc}%s {ffffff}| %s {ffffff}| Neaktivnost: {03adfc}%d{ffffff}min {03adfc}| Duty Time: {03adfc}%d{ffffff}min\n", 1 + i, AdminInfo[i][aName], onl, AdminInfo[i][aNeaktivnost], AdminInfo[i][aDuty]);
		strcat(string, str);
	}
	SPD(playerid, d_alist, DIALOG_STYLE_MSGBOX, "{03adfc}Tesla {ffffff}| {03adfc}Lista Admina", string, "{03adfc}Izadji", "");
	return 1;
}

CMD:afv(playerid, params[]) {
	if(IsPlayerAdmin(playerid) || PlayerInfo[playerid][pAdmin] > 0) {
		new id, vehid;
		if(sscanf(params, "u", id)) return SCM(playerid, 0xff0000ff, "[USAGE]: {ffffff}/afv [id igraca]");
		if(id == playerid) {
			if(!IsPlayerInAnyVehicle(playerid)) return SCM(playerid, 0xff0000ff, "[GRESKA]: {ffffff}Niste u vozilu!");
			vehid = GetPlayerVehicleID(id);
			RepairVehicle(vehid);
			SCM(playerid, 0x03ADFCff, "Uspesno ste popravili vase vozilo.");
		} else {
			if(!IsPlayerConnected(id)) return SCM(id, 0xff0000ff, "[GRESKA]: {ffffff}Igrac nije povezan!");
			if(!IsPlayerInAnyVehicle(id)) return SCM(id, 0xff0000ff, "[GRESKA]: {ffffff}Igrac nije u vozilu!");
			vehid = GetPlayerVehicleID(id);
			RepairVehicle(vehid);
			va_SCM(playerid, 0x03adfcff, "Uspesno ste popravili vozilo igracu %s", GetName(id));
			SCM(id, 0x03adfcff, "[AFV]: {ffffff}Admin Vam je popravio vozilo!");
		}
	} else return 0;
	return 1;
}

CMD:v(playerid, params[]) {
	new vehid, Float:X, Float:Y, Float:Z, Float:R;
	if(PlayerInfo[playerid][pAdmin] > 1) {
		if(IsPlayerSpec[playerid]) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Ne mozete spawnovati vozilo dok spectatujete nekoga! (/specoff).");
		if(sscanf(params, "i", vehid)) return SCM(playerid, CRVENA, "[USAGE]: {ffffff}/v [vehicle id]");
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, R);
		adminveh[playerid] = CreateVehicle(vehid, X, Y, Z, R, 0, 0, -1);
		PutPlayerInVehicle(playerid, adminveh[playerid], 0);
		VehInfo[GetPlayerVehicleID(playerid)][vEngine] = 0;
		SetVehicleParamsEx(
			GetPlayerVehicleID(playerid), 
			VehInfo[GetPlayerVehicleID(playerid)][vEngine],
			VehInfo[GetPlayerVehicleID(playerid)][vLights], 
			VehInfo[GetPlayerVehicleID(playerid)][vAlarm],
			VehInfo[GetPlayerVehicleID(playerid)][vDoor],
			VehInfo[GetPlayerVehicleID(playerid)][vBonnet],
			VehInfo[GetPlayerVehicleID(playerid)][vBoot],
			VehInfo[GetPlayerVehicleID(playerid)][vObj]
		);
		admintext[adminveh[playerid]] = Create3DTextLabel("[ ADMIN ]", PLAVA_NEBO, X, Y, Z, 10.0, 0);
		Attach3DTextLabelToVehicle(admintext[adminveh[playerid]], adminveh[playerid], 0.0, 0.0, 0.0);
		SCM(playerid, 0x03adfcff, "[ADMIN VEHICLE]: {ffffff}Uspesno ste spawnovali admin vozlilo!");
	} else return 0;
	return 1;
}

CMD:skiniadmina(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return SCM(playerid, 0xff0000ff, "[SERVER]: Niste ovlasceni da koristite ovu komandu!");
	new slot, afile[128], pid, pfile[128], niko[128], ime[128], razlog[128];
	if(sscanf(params, "is[128]", slot, razlog)) return SCM(playerid, 0xff0000ff, "[USAGE]: {ffffff}/skiniadmina [slot]");
	format(afile, sizeof(afile), ADMINPATH, slot-1);
	format(niko, sizeof(niko), "Niko");
	if(!strcmp(niko, AdminInfo[slot-1][aName])) return SCM(playerid, CRVENA, "[GRESKA]: {ffffff}Slot nije zauzet!");
	pid = GetPlayerID(AdminInfo[slot-1][aName]);
	format(ime, sizeof(ime), AdminInfo[slot - 1][aName]);
	if(pid == -1) {
		format(pfile, sizeof(pfile), USERPATH, ime);
		INI_ParseFile(pfile, "LoadUser_%s", .bExtra = true, .extra = SKIDANJEID);
		PlayerInfo[SKIDANJEID][pAdmin] = 0;
		AdminInfo[slot - 1][aName] = niko;
		AdminInfo[slot - 1][aNeaktivnost] = 0;
		AdminInfo[slot - 1][aDuty] = 0;
		Sacuvaj(SKIDANJEID, ime);
		SaveAdmin(slot -1);
	} else {
		PlayerInfo[pid][pAdmin] = 0;
		AdminInfo[slot - 1][aName] = niko;
		AdminInfo[slot - 1][aNeaktivnost] = 0;
		AdminInfo[slot - 1][aDuty] = 0;
		SavePlayer(pid);
		SaveAdmin(slot -1);
		va_SCM(pid, PLAVA_NEBO, "Skinut Vam je Admin! Razlog: %s", razlog);
		Itter_Remove(Admins, playerid);
	}
	va_SCM(playerid, PLAVA_NEBO, "Uspesno ste skinuli Admina sa slota {ffffff}%d! {03adfc}Ime: {ffffff}%s", slot, ime);
	return 1;
}

CMD:makeadmin(playerid, params[]) {
	if(IsPlayerAdmin(playerid) || PlayerInfo[playerid][pAdmin] > 2) {
		new id, lvl, slot;
		if(sscanf(params, "uii", id, lvl, slot)) return SCM(playerid, 0xff0000ff, "[USAGE]: {ffffff}/makeadmin [id] [level] [slot]");
		else if(lvl < 1 || lvl > 5) return SCM(playerid, 0xff0000ff, "[USAGE]: {ffffff}Level Admina mora biti veci od 0 i manji od 6!");
		else if(slot < 1 || slot > 20) return SCM(playerid, 0xff0000ff, "[USAGE]: {ffffff}Slot moze biti samo izmedju 1 i 20!");
		else if(UzetSlot(slot)) return SCM(playerid, 0xff0000ff, "[USAGE]: {ffffff}Slot je zauzet!");
		else {
			new ime[128];
			PlayerInfo[id][pAdmin] = lvl;
			va_SCM(playerid, 0x03adfcff, "[ADMIN]: {ffffff}Uspesno ste postavili novog Admina {03adfc}%s{ffffff}!", GetName(id));
			SCM(id, 0x03adfcff, "[INFO]: {ffffff}Postali ste Admin, cestitamo! Zeli Vam ugodnu igru {03adfc}Tesla RP Team.");
			GetPlayerName(id, ime, sizeof(ime));
			AdminInfo[slot-1][aName] = ime;
			AdminInfo[slot-1][aNeaktivnost] = 0;
			AdminInfo[slot-1][aDuty] = 0;
			SaveAdmin(slot-1);
			SavePlayer(id);
			Itter_Add(Admins, id);
		}
	}
	else SCM(playerid, 0xff0000ff, "[SERVER]: Niste ovlasceni da koristite ovu komadnu!");
	return 1;
}

public OnPlayerText(playerid, text[]) {
	new str[1024];
	format(str, sizeof(str), "{696969}[%d] {03adfc}%s {ffffff}kaze: %s", playerid, GetName(playerid), text);
	IC(20, playerid, -1, str);
	return 0;
}

public OnPlayerCommandReceived(playerid, cmdtext[]) {
	if(!UlogovanProvera[playerid]) {
		SCM(playerid, SIVA, "Morate biti ulogovani!");
		return 0;
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
	for(new i = 0; i < 2; i++) PlayerTextDrawHide(playerid, Fuel_t[playerid][i]); 
	if(editaorg[playerid] != -1) {
		SCM(playerid, SIVA, "Vise ne editujete organizaciju zato sto ste umrli!");
		editaorg[playerid] = -1;
	}
	if(renta[playerid] != -1) {
		new vehid = renta[playerid];
		DestroyVehicle(vehid);
		rented[vehid] = 0;
		renta[playerid] = -1;
		SCM(playerid, SIVA, "Vozilo Vam je unrentano!");
	}
	pADuty[playerid] = false;
	return 1;
}

public OnVehicleDeath(vehicleid, killerid) {
	foreach(new playerid : Player) {
		if(renta[playerid] != -1) {
			new vehid = renta[playerid];
			DestroyVehicle(vehid);
			rented[vehid] = 0;
			renta[playerid] = -1;
			SCM(playerid, SIVA, "Vozilo Vam je unrentano.");
		}
	}
	return 1;
}
new m_temp = 1;
public OnPlayerEnterCheckpoint(playerid) {
	new vehid = GetPlayerVehicleID(playerid);
	if(!strcmp(PlayerInfo[playerid][pPosao], "Bus Vozac")) {
		if(GetVehicleModel(vehid) == 431) {
			DisablePlayerCheckpoint(playerid);
			SetTimerEx("BusTimer", 7000, false, "i", playerid);
			jobprogress[playerid]++;
			GameTextForPlayer(playerid, "Sacekajte 7 sekundi, da se putnici ukrcaju/iskrcaju.", 7000, 4);
			TogglePlayerControllable(playerid, 0);
		}
	}
	else if(!strcmp(PlayerInfo[playerid][pPosao], "Bankar")) {
		if(GetVehicleModel(vehid) == 498) {
			DisablePlayerCheckpoint(playerid);
			SetTimerEx("BankTimer", 5000, false, "i", playerid);
			jobprogress[playerid]++;
			if(m_temp) GameTextForPlayer(playerid, "Utovarate novac...", 5000, 4);
			m_temp = 0;
			TogglePlayerControllable(playerid, 0);
		}
	}
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	switch(dialogid) {
	    case d_reg: {
		    if(!response) {
				fremove(UserPath(playerid));
				SetTimerEx("KickPlayer", 500, false, "i", playerid);
			} else {
		        if(!strlen(inputtext)) return ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "{03adfc}Tesla {ffffff}| {03adfc}Registracija na server", "{ffffff}Da bi ste se registrovali ukucajte\nvasu zelejenu sifru za vas {03adfc}nalog{ffffff}.\nSifra mora imati minimum 6 karaktera, maximum 26 karaktera.\nLozinka mora sadrzati brojeve i karaktere poput: \"@_-#\"", "{03adfc}Registruj se", "{03adfc}Odustani");
		        else if(strlen(inputtext) < 6 || strlen(inputtext) > 26) {
					ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "{03adfc}Tesla {ffffff}| {03adfc}Registracija na server", "{ffffff}Da bi ste se registrovali ukucajte\nvasu zelejenu sifru za vas {03adfc}nalog{ffffff}.\nSifra mora imati minimum 6 karaktera, maximum 26 karaktera.\nLozinka mora sadrzati brojeve i karaktere poput: \"@_-#\"", "{03adfc}Registruj se", "{03adfc}Odustani");
					SCM(playerid, PLAVA_NEBO, "[REGISTRACIJA]: {ffffff}Lozinka mora imati minimum 6 karaktera i maximum 26 karaktera!");
				} else if(!strfind(inputtext, "@", true) || !strfind(inputtext, "_", true) || !strfind(inputtext, "-", true) || !strfind(inputtext, "#", true)) {
					ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "{03adfc}Tesla {ffffff}| {03adfc}Registracija na server", "{ffffff}Da bi ste se registrovali ukucajte\nvasu zelejenu sifru za vas {03adfc}nalog{ffffff}.\nSifra mora imati minimum 6 karaktera, maximum 26 karaktera.\nLozinka mora sadrzati brojeve i karaktere poput: \"@_-#\"", "{03adfc}Registruj se", "{03adfc}Odustani");
					SCM(playerid, PLAVA_NEBO, "[REGISTRACIJA]: {ffffff}Lozinka mora imati brojeve u sebi i karaktere poput: \"@_-#\"!");
				} else {
					new INI:File = INI_Open(UserPath(playerid)), fmat[128];
					format(fmat, sizeof(fmat), "Nema");
					INI_SetTag(File, "data");
					INI_WriteInt(File, "Lozinka", udb_hash(inputtext));
					INI_WriteInt(File, "Novac", 25000);
					INI_WriteInt(File, "Godine", 16);
					INI_WriteInt(File, "Respekti", 0);
					INI_WriteInt(File, "NeededRep", 8);
					INI_WriteInt(File, "Admin", 0);
					INI_WriteString(File, "Promoter", "Ne");
					INI_WriteString(File, "BanRazlog", fmat);
					INI_WriteFloat(File, "SpawnX", 1682.4265);
					INI_WriteFloat(File, "SpawnY", -2246.7871);
					INI_WriteFloat(File, "SpawnZ", 13.5507);
					INI_WriteFloat(File, "SpawnAng", 180.0);
					INI_WriteInt(File, "SpawnInter", 0);
					INI_WriteInt(File, "Kuca", -1);
					INI_WriteString(File, "Organizacija", fmat);
					INI_WriteInt(File, "Leader", 0);
					INI_WriteString(File, "Racun", "Ne");
					INI_WriteInt(File, "Banka", 10000);
					INI_WriteInt(File, "Rate", 0);
					INI_WriteInt(File, "Kredit", 0);
					INI_WriteInt(File, "Cigare", 0);
					INI_WriteInt(File, "Hrana", 0);
					INI_WriteInt(File, "Voda", 1);
					INI_WriteInt(File, "Municija", 0);
					INI_WriteString(File, "Posao", fmat);
					INI_WriteInt(File, "Glock19", -1);
					INI_WriteInt(File, "AK_47", -1);
					INI_WriteInt(File, "M4", -1);
					INI_WriteInt(File, "Glock19Municija", 0);
					INI_WriteInt(File, "AK_47Municija", 0);
					INI_WriteInt(File, "M4Municija", 0);
					INI_WriteString(File, "VozackaDozvola", fmat);
					format(fmat, sizeof(fmat), "Ne");
					INI_WriteString(File, "Zavezan", fmat);
					INI_WriteString(File, "Zatvoren", fmat);
					INI_WriteInt(File, "Skin", 6);
					INI_WriteString(File, "IP", GETIP(playerid));
					INI_Close(File);
					INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
					GivePlayerMoney(playerid, 25000);
					SetCameraBehindPlayer(playerid);
					UlogovanProvera[playerid] = 1;
				}
			}
	    }
	    case d_log: {
	        if(!response) return Kick(playerid);
		    if(response) {
		        if(udb_hash(inputtext) == PlayerInfo[playerid][pLozinka]) {
		            INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra=true, .extra=playerid);
		            GivePlayerMoney(playerid, PlayerInfo[playerid][pNovac]);
					UlogovanProvera[playerid] = 1;
				} else ShowPlayerDialog(playerid, d_log, DIALOG_STYLE_PASSWORD, "{03adfc}Tesla {ffffff}| {03adfc}Prijava na server", "{ffffff}Unesite vasu lozinku:", "{03adfc}Prijavi se", "{03adfc}Odustani");
		        return 1;
		    }
	    }
		case d_port: {
			if(response) {
				new vehid = GetPlayerVehicleID(playerid);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				switch(listitem + 1) {
					case 1: {
						if(IsPlayerInAnyVehicle(playerid)) {
							SetVehiclePos(vehid, 1682.222045, -2246.613281, 13.550828);
							SetVehicleZAngle(vehid, 178.891632);
							PutPlayerInVehicle(playerid, vehid, 0);
						} else {
							SetPlayerPos(playerid, 1682.222045, -2246.613281, 13.550828);
							SetPlayerFacingAngle(playerid, 178.891632);
						}
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Spawna.");
					}
					case 2: {
						if(IsPlayerInAnyVehicle(playerid)) {
							SetVehiclePos(vehid, 1240.984741, -740.342163, 95.079673);
							SetVehicleZAngle(vehid, 22.816354);
							PutPlayerInVehicle(playerid, vehid, 0);
						} else {
							SetPlayerPos(playerid, 1240.984741, -740.342163, 95.079673);
							SetPlayerFacingAngle(playerid, 178.891632);
						}
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Kuce Zemunaca1.");
					}
					case 3: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) {
							SetVehiclePos(vehid, 1561.0580,-2227.5750,13.5469);
							SetVehicleZAngle(vehid, 22.816354);
							PutPlayerInVehicle(playerid, vehid, 0);
						} else {
							SetPlayerPos(playerid, 1561.0580,-2227.5750,13.5469);
							SetPlayerFacingAngle(playerid, 178.891632);
						}
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Spawn rent-a.");
					}
					case 4: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) {
							SetVehiclePos(vehid, 1543.0642,-1675.9728,13.5557);
							SetVehicleZAngle(vehid, 154);
						} else {
							SetPlayerPos(playerid, 1543.0642,-1675.9728,13.5557);
							SetPlayerFacingAngle(playerid, 180);
						}
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Policjske stanice.");
					}
					case 5: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(vehid, 1172.0773,-1323.3525,15.4030);
						else SetPlayerPos(playerid, 1172.0773,-1323.3525,15.4030);
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Bolnice.");
					}
					case 6: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(vehid, 1481.1985,-1742.1227,13.6469);
						else SetPlayerPos(playerid, 1481.1985,-1742.1227,13.6469);
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Vlade.");
					}
					case 7: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(vehid, 1286.8000,-1329.2859,13.6546);
						else SetPlayerPos(playerid, 1286.8000,-1329.2859,13.6546);
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}FIB-a.");
					}
					case 8: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(vehid, 1219.1619,-1811.7039,16.5938);
						else SetPlayerPos(playerid, 1219.1619,-1811.7039,16.5938);
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Autobuske stanice.");
					}
					case 9: {
						SetPlayerInterior(playerid, 0);
						if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(vehid, 1456.9044,-1022.7017,23.8281);
						else SetPlayerPos(playerid, 1456.9044,-1022.7017,23.8281);
						SCM(playerid, -1, "Uspesno ste se teleportovali do {03adfc}Banke.");
					}
				}
			}
		}
		case d_rent: {
			if(response) {
				new Float:X, Float:Y, Float:Z, Float:FA, vehid, vehicle;
				GetPlayerPos(playerid, X, Y, Z);
				GetPlayerFacingAngle(playerid, FA);
				switch(listitem + 1) {
					case 1: {
						if(GetPlayerMoney(playerid) < 1000) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Nemate dovoljno novca!");
						else if(renta[playerid] != -1) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Vi vec rentate vozilo!");
						else {
							rentvreme[playerid] = 10;
							vehicle = CreateVehicle(496, X, Y, Z, FA, 137, 137, -1);
							PutPlayerInVehicle(playerid, vehicle, 0);
							vehid = GetPlayerVehicleID(playerid);
							VehInfo[vehid][vEngine] = 0;
                            VehInfo[vehid][vLights] = 0;
                            VehInfo[vehid][vAlarm] = 0;
                            VehInfo[vehid][vDoor] = 0;
                            VehInfo[vehid][vBonnet] = 0;
							VehInfo[vehid][vBoot] = 0;
                            VehInfo[vehid][vObj] = 0;
                            VehInfo[vehid][vFuel] = 100;
							SetVehicleParamsEx(
                                vehid,
                                VehInfo[vehid][vEngine],
                                VehInfo[vehid][vLights],
                                VehInfo[vehid][vAlarm],
                                VehInfo[vehid][vDoor],
                                VehInfo[vehid][vBonnet],
                                VehInfo[vehid][vBoot],
                                VehInfo[vehid][vObj]
                            );
							renta[playerid] = vehid;
							rented[vehid] = 1;
							GivePlayerMoney(playerid, -1000);
							PlayerInfo[playerid][pNovac] -= 1000;
							GameTextForPlayer(playerid, "~r~-$1000", 2000, 1);
							SCM(playerid, PLAVA, "Uspesno ste rentali vozilo!");
						}
					} //10 minuta
					case 2: {
						if(GetPlayerMoney(playerid) < 2000) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Nemate dovoljno novca!");
						else if(renta[playerid] != -1) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Vi vec rentate vozilo!");
						else {
							rentvreme[playerid] = 20;
							vehicle = CreateVehicle(496, X, Y, Z, FA, 137, 137, -1);
							PutPlayerInVehicle(playerid, vehicle, 0);
							vehid = GetPlayerVehicleID(playerid);
							VehInfo[vehid][vEngine] = 0;
                            VehInfo[vehid][vLights] = 0;
                            VehInfo[vehid][vAlarm] = 0;
                            VehInfo[vehid][vDoor] = 0;
                            VehInfo[vehid][vBonnet] = 0;
							VehInfo[vehid][vBoot] = 0;
                            VehInfo[vehid][vObj] = 0;
                            VehInfo[vehid][vFuel] = 100;
							SetVehicleParamsEx(
                                vehid,
                                VehInfo[vehid][vEngine],
                                VehInfo[vehid][vLights],
                                VehInfo[vehid][vAlarm],
                                VehInfo[vehid][vDoor],
                                VehInfo[vehid][vBonnet],
                                VehInfo[vehid][vBoot],
                                VehInfo[vehid][vObj]
                            );
							renta[playerid] = vehid;
							rented[vehid] = 1;
							GivePlayerMoney(playerid, -2000);
							PlayerInfo[playerid][pNovac] -= 2000;
							GameTextForPlayer(playerid, "~r~-$2000", 2000, 1);
							SCM(playerid, PLAVA, "Uspesno ste rentali vozilo!");
						}
					} //20 minuta
					case 3: {
						if(GetPlayerMoney(playerid) < 3000) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Nemate dovoljno novca!");
						else if(renta[playerid] != -1) return SCM(playerid, CRVENA, "[RENT]: {ffffff}Vi vec rentate vozilo!");
						else {
							rentvreme[playerid] = 30;
							vehicle = CreateVehicle(496, X, Y, Z, FA, 137, 137, -1);
							PutPlayerInVehicle(playerid, vehicle, 0);
							vehid = GetPlayerVehicleID(playerid);
							VehInfo[vehid][vEngine] = 0;
                            VehInfo[vehid][vLights] = 0;
                            VehInfo[vehid][vAlarm] = 0;
                            VehInfo[vehid][vDoor] = 0;
                            VehInfo[vehid][vBonnet] = 0;
							VehInfo[vehid][vBoot] = 0;
                            VehInfo[vehid][vObj] = 0;
                            VehInfo[vehid][vFuel] = 100;
							SetVehicleParamsEx(
                                vehid,
                                VehInfo[vehid][vEngine],
                                VehInfo[vehid][vLights],
                                VehInfo[vehid][vAlarm],
                                VehInfo[vehid][vDoor],
                                VehInfo[vehid][vBonnet],
                                VehInfo[vehid][vBoot],
                                VehInfo[vehid][vObj]
                            );
							renta[playerid] = vehid;
							rented[vehid] = 1;
							GivePlayerMoney(playerid, -3000);
							PlayerInfo[playerid][pNovac] -= 3000;
							GameTextForPlayer(playerid, "~r~-$3000", 2000, 1);
							SCM(playerid, PLAVA, "Uspesno ste rentali vozilo!");
						}
					} //30 minuta
				}
			} else SCM(playerid, SIVA, "Odustali ste od rentanja vozila!");
		}
		case d_orgime: {
			if(response) {
				new ime[128];
				format(ime, sizeof(ime), "%s", inputtext);
				OrgInfo[editaorg[playerid]][orgIme] = ime;
				SPD(playerid, d_orgdrzavna, DIALOG_STYLE_MSGBOX, "{0000ff}Vrsta organizacije", "{ffffff}Izaberite vrstu organizacije:", "{0000ff}Drzavna", "{0000ff}Ilegalna");
			} else {
				DestroyPickup(orgPickup[editaorg[playerid]]);
				SCM(playerid, SIVA, "Odustali ste od pravljenja organizacije!");
				editaorg[playerid] = -1;
			}
		}
		case d_orgdrzavna: {
			new string[128];
			if(response) OrgInfo[editaorg[playerid]][orgDrzavna] = "Da";
			else OrgInfo[editaorg[playerid]][orgDrzavna] = "Ne";
			format(string, sizeof(string), "{0000ff}Da li ste sigurni da zelite da napravite organizaciju:\n{ffffff}Ime: {0000ff}%s,\n{ffffff}Drzavna: {0000ff}%s", OrgInfo[editaorg[playerid]][orgIme], OrgInfo[editaorg[playerid]][orgDrzavna]);
			SPD(playerid, d_orginfo, DIALOG_STYLE_MSGBOX, "{0000ff}Potvrda", string, "{0000ff}Da", "{0000ff}Ne");
		}
		case d_orginfo: {
			if(response) {
				new i = editaorg[playerid], string[128];
				va_SCM(playerid, PLAVA_NEBO, "Uspesno ste napravili organizaciju {ffffff}%s{03adfc}.", OrgInfo[i][orgIme]);
				SaveOrg(i);
				format(string, sizeof(string), "{0000ff}[ {ffffff}%s {0000ff}]\n{ffffff}Leader: {0000ff}%s", OrgInfo[i][orgIme], OrgInfo[i][orgLeader]);
				orgLabel[i] = Create3DTextLabel(string, -1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ], 20.0, 0, 0);
				editaorg[playerid] = -1;
			} else {
				DestroyPickup(orgPickup[editaorg[playerid]]);
				SCM(playerid, SIVA, "Odustali ste od pravljenja organizacije!");
				editaorg[playerid] = -1;
			}
		}
		case d_hrentcena: {
			if(response) {
				new string[512], str[3], niko[128];
				format(niko, sizeof(niko), "Niko");
				for(new i = 0; i <= MAX_HOUSES; i++) {
					if(PlayerInfo[playerid][pKuca] == i) {
						HouseInfo[i][hRent] = niko;
						format(str, sizeof(str), "Da");
						HouseInfo[i][hOnRent] = str;
						DestroyPickup(hPickup[i]);
						Delete3DTextLabel(hLabel[i]);
						format(string, sizeof(string), "{ffa500}[{ffffff}Kuca za rent{ffa500}]\nVlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}On Rent: {ffffff}%s\n{ffa500}Rent: {ffffff}%s\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d\n{ffa500}Ako zelite da rentate kucu kucajte /renthouse", HouseInfo[i][hOwner], HouseInfo[i][hCena], HouseInfo[i][hOnRent], HouseInfo[i][hRent], HouseInfo[i][hLevel], i);
						hPickup[i] = CreatePickup(19523, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
						hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 10.0, 0, 0);
						SaveHouse(i);
						break;
					}
				}
			}
		}
		case d_inventar: {
			if(response) {
				switch(listitem + 1) {
					case 1: SPD(playerid, d_inv_oruzje, DIALOG_STYLE_LIST, "Oruzje", "Glock 19\nAK-47\nM4", "Izaberi", "Nazad");
					case 2: if(strcmp(PlayerInfo[playerid][pVozackaDozvola], "Nema")) return SCM(playerid, SIVA, "Nemate vozacku dozvolu, da bi ste dobili vozacku dozvolu morate polagati ispit u auto skoli! (/gps)");
					case 3: cmd_stats(playerid, "\0");
				}
			}
		}
		case d_inv_oruzje: {
			if(response) {
				switch(listitem + 1) {
					case 1: {
						if(PlayerInfo[playerid][pGlock19] == -1) return SCM(playerid, SIVA, "Nemate Glock 19, ali mozete ga kupiti u Gun Shop-u! (/gps)");
						GivePlayerWeapon(playerid, PlayerInfo[playerid][pGlock19], PlayerInfo[playerid][pGlock19Municija]);
						SetPlayerAmmo(playerid, PlayerInfo[playerid][pGlock19], PlayerInfo[playerid][pGlock19Municija]);
					}
					case 2: {
						if(PlayerInfo[playerid][pAK_47] == -1) return SCM(playerid, SIVA, "Nemate AK_47, ali mozete ga kupiti u Gun Shop-u! (/gps)");
						GivePlayerWeapon(playerid, PlayerInfo[playerid][pAK_47], PlayerInfo[playerid][pAK_47Municija]);
						SetPlayerAmmo(playerid, PlayerInfo[playerid][pAK_47], PlayerInfo[playerid][pAK_47Municija]);
					}
					case 3: {
						if(PlayerInfo[playerid][pM4] == -1) return SCM(playerid, SIVA, "Nemate M4, ali mozete ga kupiti u Gun Shop-u! (/gps)");
						GivePlayerWeapon(playerid, PlayerInfo[playerid][pM4], PlayerInfo[playerid][pM4Municija]);
						SetPlayerAmmo(playerid, PlayerInfo[playerid][pM4], PlayerInfo[playerid][pM4Municija]);
					}
				}
			} else SPD(playerid, d_inventar, DIALOG_STYLE_LIST, "Inventar", "Oruzje\nVozacka Dozvola\nLicna Karta", "Izaberi", "Odustani");
		}
		case d_joblist: {
			if(response) {
				new job[128];
				switch(listitem + 1) {
					case 1: format(job, sizeof(job), "Bus Vozac");
					case 2: format(job, sizeof(job), "Bankar");
				}
				PlayerInfo[playerid][pPosao] = job;
				va_SCM(playerid, -1, "Cestitamo! Uspesno ste zaposleni kao %s!", PlayerInfo[playerid][pPosao]);
				SavePlayer(playerid);
			}
		}
		case d_gps: {
			//SPD(playerid, d_gps, DIALOG_STYlE_LIST, "{03adfc}GPS", "{03adfc}1. {ffffff}Banka\n{03adfc}2. {ffffff}Banka 2\n{696969}3. Auto skola(Nedostupno)\n{03adfc}4. Poslovi", "{03adfc}Izaberi", "{03adfc}Odustani");
			if(response) {
				switch(listitem + 1) {
					case 1: {
						SetPlayerCheckpoint(playerid, 1457.0255,-1009.9204,26.8438, 5);
						SCM(playerid, ZELENA, "[GPS]: {ffffff}Pratite marker do odredista na mapi.");
					}
					case 2: SCM(playerid, SIVA, "Nedostupno!");
					case 3: SPD(playerid, d_gps_poslovi, DIALOG_STYLE_LIST, "{03adfc}GPS - Poslovi", "{03adfc}1. {ffffff}Bus Vozac\n{03adfc}2. {ffffff}Bankar", "{03adfc}Izaberi", "{03adfc}Nazad");
				}
			}
		}
		case d_gps_poslovi: {
			if(response) {
				switch(listitem + 1) {
					case 1: {
						SetPlayerCheckpoint(playerid, 1219.1619,-1811.7039,16.5938, 5);
						SCM(playerid, ZELENA, "[GPS]: {ffffff}Pratite marker do odredista na mapi.");
					}
					case 2: {
						SetPlayerCheckpoint(playerid, 1529.3566,-1029.8085,23.9814, 5);
						SCM(playerid, ZELENA, "[GPS]: {ffffff}Pratite marker do odredista na mapi.");
					}
				}
			}
		}
		case d_ammu_nation: {
			// SPD(playerid, d_ammu_nation, DIALOG_STYLE_LIST, "{696969}AMMU-NATION", "AK-47 - $7000\nM4 - $6000\nGLOCK19 - $4000\n100 metkova - $3000", "{696969}Kupi", "{696969}Odustani");
			if(response) {
				switch(listitem + 1) {
					case 1: {
						if(GetPlayerMoney(playerid) < 7000) return SCM(playerid, SIVA, "Nemate dovoljno novca!");
						PlayerInfo[playerid][pAK_47] = 30;
						PlayerInfo[playerid][pAK_47Municija] = 200;
						GivePlayerWeapon(playerid, PlayerInfo[playerid][pAK_47], PlayerInfo[playerid][pAK_47Municija]);
						SavePlayer(playerid);
						GivePlayerMoney(playerid, -7000);
						GameTextForPlayer(playerid, "~r~-$7000", 5000, 1);
						SCM(playerid, -1, "Uspesno ste kupili pusku marke AK-47!");
					}
					case 2: {
						if(GetPlayerMoney(playerid) < 6000) return SCM(playerid, SIVA, "Nemate dovoljno novca!");
						PlayerInfo[playerid][pM4] = 31;
						PlayerInfo[playerid][pM4Municija] = 200;
						GivePlayerWeapon(playerid, PlayerInfo[playerid][pM4], PlayerInfo[playerid][pM4Municija]);
						SavePlayer(playerid);
						GivePlayerMoney(playerid, -6000);
						GameTextForPlayer(playerid, "~r~-$6000", 5000, 1);
						SCM(playerid, -1, "Uspesno ste kupili pusku marke M4!");
					}
					case 3: {
						if(GetPlayerMoney(playerid) < 4000) return SCM(playerid, SIVA, "Nemate dovoljno novca!");
						PlayerInfo[playerid][pGlock19] = 24;
						PlayerInfo[playerid][pGlock19Municija] = 200;
						GivePlayerWeapon(playerid, PlayerInfo[playerid][pGlock19], PlayerInfo[playerid][pGlock19Municija]);
						SavePlayer(playerid);
						GivePlayerMoney(playerid, -4000);
						GameTextForPlayer(playerid, "~r~-$4000", 5000, 1);
						SCM(playerid, -1, "Uspesno ste kupili pistolj marke Glock19!");
					}
				}
			}
		}
		case d_bolnica: {
			if(response) {
				switch(listitem + 1) {
					case 1: {
						new Float: hp;
						GetPlayerHealth(playerid, hp);
						if(hp >= 100) return SCM(playerid, CRVENA, "BOLNICAR: {ffffff}Zdravi ste kao dren!");
						hp += 49.9;
						SetPlayerHealth(playerid, hp);
						SCM(playerid, CRVENA, "BOLNICAR: {ffffff}Izvolite, nadam se da sam Vam pomogao.");
					}
				}
			}
		}
		case d_askq: {
			if(response) {
				if(!strlen(inputtext)) {
					SPD(playerid, d_askq, DIALOG_STYLE_INPUT, "Askq", "Unesite pitanje koje zelite postaviti adminima:", "Posalji", "Odustani");
					return 0;
				}
				if(strlen(inputtext) < 10) {
					SCM(playerid, -1, "Pitanje mora imati vise od 10 karaktera!");
					SPD(playerid, d_askq, DIALOG_STYLE_INPUT, "Askq", "Unesite pitanje koje zelite postaviti adminima:", "Posalji", "Odustani");
					return 0;
				}
				foreach(new i : Admins) {
					
				}
			}
		}
		// case d_dostupna_vozila: {
		// 	if(response) {
				
		// 	}
		// }
		//
		case d_ban: if(response) Kick(playerid);
		case d_nevalidno_ime: if(response) Kick(playerid);                                      
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER) {
		for(new i = 0; i < 2; i++) PlayerTextDrawShow(playerid, Fuel_t[playerid][i]);
		new vehid = GetPlayerVehicleID(playerid);
		if(!VehInfo[vehid][vEngine]) SCM(playerid, PLAVA_NEBO, "Da bi ste upalili motor pretisnite 2 ili ukucajte /engine");
		if(renta[playerid] != -1) {
			if(vehid != renta[playerid]) {
				if(rented[playerid]) return SCM(playerid, -1, "Vi rentate vozilo! Prvo ukucujate /unrent");
				RemovePlayerFromVehicle(playerid);
				SCM(playerid, CRVENA, "[RENT]: {ffffff}Ovo vozilo nije Vas rent!");
			}
		} else {
			if(rented[playerid]) {
				RemovePlayerFromVehicle(playerid);
				SCM(playerid, CRVENA, "[RENT]: {ffffff}Ovo vozilo je rentano!");
			}
		}
		for(new i = 0; i < sizeof(j_bus); i++) {
			if(vehid == j_bus[i]) {
				if(!strcmp(PlayerInfo[playerid][pPosao], "Bus Vozac")) {
					if(!IsPlayerWorking[playerid]) {
						TogglePlayerControllable(playerid, 0);
						SCM(playerid, -1, "[POSAO]: {ffffff}Ako zelite da prevozite putnike ukucajte /prevozputnika, u suprotnom /exitveh");
					} else SCM(playerid, SIVA, "Vi vec prevozite putnike! Ako zelite da zapocnete nov posao ukucajte /prekiniposao, zatim /prevozputnika");
				} else {
					RemovePlayerFromVehicle(playerid);
					ClearAnimations(playerid);
					SCM(playerid, SIVA, "Ovo vozilo je namenjeno za poslovne upotrebe, ako zelite da prevozite putnike, morate se zaposliti u vladi!");
				}
			}
		}
		for(new i = 0; i < sizeof(j_kombi); i++) {
			if(vehid == j_kombi[i]) {
				if(!strcmp(PlayerInfo[playerid][pPosao], "Bankar")) {
					if(!IsPlayerWorking[playerid]) {
						TogglePlayerControllable(playerid, 0);
						SCM(playerid, -1, "[POSAO]: {ffffff}Ako zelite da prevozite novac ukucajte /prevoznovca, u suprotnom /exitveh");
					}
					else SCM(playerid, SIVA, "Vi vec prevozite novac! Ako zelite da zapocnete nov posao, ukucajte /prekiniposao, zatim /prevoznovca");
				} else {
					RemovePlayerFromVehicle(playerid);
					ClearAnimations(playerid);
					SCM(playerid, SIVA, "Ovo vozilo je namenjeno za poslovne upotrebe, ako zelite da prevozite novav, morate se zaposliti u vladi!");
				}
			}
		}
	}
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) for(new i = 0; i < 2; i++) PlayerTextDrawHide(playerid, Fuel_t[playerid][i]);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	new vehid = GetPlayerVehicleID(playerid);
	// if(newkeys & KEY_YES) {
	// 	SPD(playerid, d_inventar, DIALOG_STYLE_LIST, "{03adfc}Inventar", "Dzep\nRanac", "{03adfc}Izaberi", "{03adfc}Odustani");
	// }
	if(newkeys & KEY_SPRINT) {
		if(IsPlayerInRangeOfPoint(playerid, 3, 1402.7065,-39.0211,1000.8640)) {
			SPD(playerid, d_bolnica, DIALOG_STYLE_LIST, "{ff0000}Bolnica", "1. Potrebna mi je medicinska pomoc.\n2. Dovidjenja", "{ff0000}Izaberi", "{ff0000}Odustani");
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 291.3272,-106.2224,1001.5156)) {
			SPD(playerid, d_ammu_nation, DIALOG_STYLE_LIST, "{696969}AMMU-NATION", "AK-47 - $7000\nM4 - $6000\nGLOCK19 - $4000", "{696969}Kupi", "{696969}Odustani");
		}
	}
	if(newkeys & KEY_SECONDARY_ATTACK) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1258.7070,-785.2449,92.0302)) {
			// if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return SCM(playerid, SIVA, "Samo clanovi Zemunskog Klana!");
			SetPlayerInterior(playerid, 5);
			SetPlayerPos(playerid, 1262.6282,-785.3718,1091.9063);
			SetCameraBehindPlayer(playerid);
			SetPlayerFacingAngle(playerid, 180);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1262.6282,-785.3718,1091.9063)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1258.7070,-785.2449,92.0302);
			SetCameraBehindPlayer(playerid);
			SetPlayerFacingAngle(playerid, 264.7457);
		}
		//Milicijska Stanca
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1555.5020,-1675.6063,16.1953)) {
			// if(!IsPlayerPoliceman(playerid)) return SCM(playerid, SIVA, "Samo clanovi LSPD-a!");
			SetPlayerInterior(playerid, 6);
			SetPlayerPos(playerid, 246.783996,63.900199,1003.640625);
			SetCameraBehindPlayer(playerid);
			SetPlayerFacingAngle(playerid, 180);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 246.783996,63.900199,1003.640625)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1555.5020,-1675.6063,16.1953);
			SetCameraBehindPlayer(playerid);
			SetPlayerFacingAngle(playerid, 267.2057);
		}
		//Binco
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 2244.6240,-1664.3992,15.4766)) {
			SetPlayerInterior(playerid, 15);
			SetPlayerPos(playerid, 207.7175,-110.5605,1005.1328);
			SetCameraBehindPlayer(playerid);
			SetPlayerFacingAngle(playerid, -179.2283);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 207.7175,-110.5605,1005.1328)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 2244.6240,-1664.3992,15.4766);
			SetCameraBehindPlayer(playerid);
			SetPlayerFacingAngle(playerid, -175.5782);
		}
		//Banka
		if(IsPlayerInRangeOfPoint(playerid, 3, 1457.0255,-1009.9204,26.8438)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1109.5514,1052.3843,-19.9389);
			SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 1109.5514,1052.3843,-19.9389)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1457.0255,-1009.9204,26.8438);
			SetCameraBehindPlayer(playerid);
		}
		//Ona druga banka
		if(IsPlayerInRangeOfPoint(playerid, 3, 1325.1090,-1709.0313,13.6395)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 2306.38,-15.23,26.74);
			SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 2306.38,-15.23,26.74)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1325.1090,-1709.0313,13.6395);
			SetCameraBehindPlayer(playerid);
		}
		//Bolnica
		if(IsPlayerInRangeOfPoint(playerid, 3, 1172.0773,-1323.3525,15.4030)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1402.7532,-25.7685,1000.8640);
			SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 1402.7532,-25.7685,1000.8640)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1172.0773,-1323.3525,15.4030);
			SetCameraBehindPlayer(playerid);
		}
		//Vlada
		if(IsPlayerInRangeOfPoint(playerid, 3, 1481.0361,-1772.3120,18.7958)) {
			SetPlayerInterior(playerid, 3);
			SetPlayerPos(playerid, 384.808624,173.804992,1008.382812);
			SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 384.808624,173.804992,1008.382812)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1481.0361,-1772.3120,18.7958);
			SetCameraBehindPlayer(playerid);
		}
		//Fib stanica
		if(IsPlayerInRangeOfPoint(playerid, 3, 1286.8000,-1329.2859,13.6546)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1302.411621, -1326.199951, -0.909798);
			SetCameraBehindPlayer(playerid);
		}
		//Aftobuska stanica
		if(IsPlayerInRangeOfPoint(playerid, 3, 1219.1619,-1811.7039,16.5938)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1234.3916, -1782.9769, -22.3899);
			SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 1234.3916, -1782.9769, -22.3899)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1219.1619,-1811.7039,16.5938);
			SetCameraBehindPlayer(playerid);
		}
		// //Prodavnica
		// if(IsPlayerInRangeOfPoint(playerid, 3, 1315.4775,-897.6816,39.6781)) {
		// 	SetPlayerInterior(playerid, 17);
		// 	SetPlayerPos(playerid, -25.884498,-185.868988,1003.546875);
		// 	SetCameraBehindPlayer(playerid);
		// }
		// if(IsPlayerInRangeOfPoint(playerid, 3, -25.884498,-185.868988,1003.546875)) {
		// 	SetPlayerInterior(playerid, 0);
		// 	SetPlayerPos(playerid, 1315.4775,-897.6816,39.6781);
		// 	SetCameraBehindPlayer(playerid);
		// }
		//AMMU-NATION
		if(IsPlayerInRangeOfPoint(playerid, 3, 1368.9985,-1279.7140,13.5469)) {
			SetPlayerInterior(playerid, 6);
			SetPlayerPos(playerid, 296.919982,-108.071998,1001.515625);
			SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 3, 296.8170,-112.0710,1001.5156)) {
			SetPlayerInterior(playerid, 0);
			SetPlayerPos(playerid, 1368.9985,-1279.7140,13.5469);
			SetCameraBehindPlayer(playerid);
		}
	}
	if(newkeys & KEY_LOOK_BEHIND) {
		new string[128];
		if(IsPlayerInAnyVehicle(playerid)) {
			if(!VehInfo[vehid][vEngine]) {
				SetTimerEx("StartEngine", 1000, false, "i", playerid);
				TogglePlayerControllable(playerid, 0);
				format(string, sizeof(string), "* %s pokusava da upali motor.", GetName(playerid));
				ProxDetector(20.0, playerid, string);
			}
		}
	}
	if(newkeys == KEY_CROUCH) {
		if(IsPlayerInRangeOfPoint(playerid, 15.0, 1245.65881, -766.94067, 92.77000)) {
			if(strcmp(PlayerInfo[playerid][pOrganizacija], "Zemunski Klan")) return 0;
			if(IsPlayerInAnyVehicle(playerid)) {
				MoveDynamicObject(ZemunciGate, 1245.65881, -766.94067, 89.45000, 2.0, 0, 0, 0);
				SetTimer("ZatvoriGateZemunci", 5000, false);
			}
		}
	}
	// if(newkeys & KEY_FIRE) if(IsPlayerInAnyVehicle(playerid)) AddVehicleComponent(vehid, 1010);
	return 1;
}

public OnPlayerUpdate(playerid) {
	// new Float:X, Float:Y, Float:Z;
	// GetPlayerCameraPos(playerid, X, Y, Z);
	// MovePlayerObject(playerid, snegobj[playerid], X - 0.5, Y + 0.5, Z - 5.5, 4000, 10, 10, 10);
	return 1;
}

function LoadUser_data(playerid,name[],value[]) {
	INI_Int("Lozinka",PlayerInfo[playerid][pLozinka]);
	INI_Int("Novac",PlayerInfo[playerid][pNovac]);
	INI_Int("Godine",PlayerInfo[playerid][pGodine]);
	INI_Int("Respekti", PlayerInfo[playerid][pRespekti]);
	INI_Int("NeededRep", PlayerInfo[playerid][pNeededRep]);
	INI_Int("Admin",PlayerInfo[playerid][pAdmin]);
	INI_Int("Ban", PlayerInfo[playerid][pBan]);
	INI_String("BanRazlog", PlayerInfo[playerid][pBanRazlog], 128);
	INI_String("Promoter", PlayerInfo[playerid][pPromoter], 3);
	INI_Float("SpawnX", PlayerInfo[playerid][pSpawnX]);
	INI_Float("SpawnY", PlayerInfo[playerid][pSpawnY]);
	INI_Float("SpawnZ", PlayerInfo[playerid][pSpawnZ]);
	INI_Float("SpawnAng", PlayerInfo[playerid][pSpawnAng]);
	INI_Int("SpawnInter", PlayerInfo[playerid][pSpawnInter]);
	INI_Int("Kuca", PlayerInfo[playerid][pKuca]);
	INI_String("Organizacija", PlayerInfo[playerid][pOrganizacija], 128);
	INI_Int("Leader", PlayerInfo[playerid][pLeader]);
	INI_Int("RentHouse", PlayerInfo[playerid][pRentHouse]);
	INI_String("Racun", PlayerInfo[playerid][pRacun], 3);
	INI_Int("Banka", PlayerInfo[playerid][pBanka]);
	INI_Int("Rate", PlayerInfo[playerid][pRate]);
	INI_Int("Kredit", PlayerInfo[playerid][pKredit]);
	INI_Int("Cigare", PlayerInfo[playerid][pCigare]);
	INI_Int("Hrana", PlayerInfo[playerid][pHrana]);
	INI_Int("Voda", PlayerInfo[playerid][pVoda]);
	INI_Int("Panciri", PlayerInfo[playerid][pPanciri]);
	INI_Int("Droga", PlayerInfo[playerid][pDroga]);
	INI_Int("Lisice", PlayerInfo[playerid][pLisice]);
	INI_String("Posao", PlayerInfo[playerid][pPosao], 128);
	INI_Int("Glock19", PlayerInfo[playerid][pGlock19]);
	INI_Int("AK_47", PlayerInfo[playerid][pAK_47]);
	INI_Int("M4", PlayerInfo[playerid][pM4]);
	INI_Int("Glock19Municija", PlayerInfo[playerid][pGlock19Municija]);
	INI_Int("AK_47Municija", PlayerInfo[playerid][pAK_47Municija]);
	INI_Int("M4Municija", PlayerInfo[playerid][pM4Municija]);
	INI_String("VozackaDozvola", PlayerInfo[playerid][pVozackaDozvola], 128);
	INI_String("Zatvoren", PlayerInfo[playerid][pZatvoren], 128);
	INI_String("Zavezan", PlayerInfo[playerid][pZavezan], 128);
	INI_Int("Skin", PlayerInfo[playerid][pSkin]);
	INI_String("IP", PlayerInfo[playerid][pIP], 32);
	return 1;
}

function LoadAdmins(id, name[], value[]) {
	INI_String("Name", AdminInfo[id][aName], 128);
	INI_Int("Neaktivnost", AdminInfo[id][aNeaktivnost]);
	INI_Int("Duty", AdminInfo[id][aDuty]);
	return 1;
}

function Fuel() {
	if(platatimer <= 0) platatimer = 60;
	platatimer--;
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(VehInfo[i][vEngine]) {
			VehInfo[i][vFuel]--;
			if(VehInfo[i][vFuel] <= 0) {
				VehInfo[i][vFuel] = 0;
				VehInfo[i][vEngine] = 0;
				SetVehicleParamsEx(
					i, 
					VehInfo[i][vEngine], 
					VehInfo[i][vLights], 
					VehInfo[i][vAlarm],
					VehInfo[i][vDoor],
					VehInfo[i][vBonnet],
					VehInfo[i][vBoot],
					VehInfo[i][vObj]
				);
			}
		}
	}
	for(new i = 0; i < MAX_ADMINS; i++) {
		new id = GetPlayerID(AdminInfo[i][aName]);
		if(id == -1) {
			new str[128];
			format(str, sizeof(str), "Niko");
			if(strcmp(str, AdminInfo[i][aName])) {
				AdminInfo[i][aNeaktivnost]++;
			}
		} else 
			if(pADuty[id]) AdminInfo[i][aDuty]++;
		SaveAdmin(i);
	}
	for(new i = 0; i < MAX_PROMS; i++) {
		new id = GetPlayerID(PromInfo[i][promName]);
		if(id == -1) {
			new str[128];
			format(str, sizeof(str), "Niko");
			if(strcmp(PromInfo[i][promName], str)) {
				PromInfo[i][promNeaktivnost]++;
			} 
		} else 
			if(PDuty[id]) PromInfo[i][promDuty]++;
		SaveProm(i);
	}
	foreach(new i : Player) {
		if(renta[i] != -1) {
			rentvreme[i]--;
			if(rentvreme[i] <= 0) {
				new vehid = renta[i];
				DestroyVehicle(vehid);
				rented[vehid] = 0;
				renta[i] = -1;
				GameTextForPlayer(i, "~r~Vreme renta Vam je isteklo.", 2000, 3);
			}
		}
	}
	return 1;
}

function ProxDetector(Float:radie, playerid, string[]) {
	const col1 = PROXY, col2 = col1, col3 = col2, col4 = col3, col5 = col4;
    if (IsPlayerConnected(playerid)) {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        foreach(new i : Player) {
            if (IsPlayerConnected(i)) {
                if (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)) {
                    GetPlayerPos(i, posx, posy, posz);
                    tempposx = (oldposx - posx);
                    tempposy = (oldposy - posy);
                    tempposz = (oldposz - posz);
                    if (((tempposx < radie / 16) && (tempposx > -radie / 16)) && ((tempposy < radie / 16) && (tempposy > -radie / 16)) && ((tempposz < radie / 16) && (tempposz > -radie / 16))) {
                        SCM(i, col1, string);
                    } else if (((tempposx < radie / 8) && (tempposx > -radie / 8)) && ((tempposy < radie / 8) && (tempposy > -radie / 8)) && ((tempposz < radie / 8) && (tempposz > -radie / 8))) {
                        SCM(i, col2, string);
                    } else if (((tempposx < radie / 4) && (tempposx > -radie / 4)) && ((tempposy < radie / 4) && (tempposy > -radie / 4)) && ((tempposz < radie / 4) && (tempposz > -radie / 4))) {
                        SCM(i, col3, string);
                    } else if (((tempposx < radie / 2) && (tempposx > -radie / 2)) && ((tempposy < radie / 2) && (tempposy > -radie / 2)) && ((tempposz < radie / 2) && (tempposz > -radie / 2))) {
                        SCM(i, col4, string);
                    } else if (((tempposx < radie) && (tempposx > -radie)) && ((tempposy < radie) && (tempposy > -radie)) && ((tempposz < radie) && (tempposz > -radie))) {
                        SCM(i, col5, string);
                    }
                }
            }
        }
    }
    return 1;
}

function KickPlayer(id) {
	Kick(id);
	return 1;
}

function BanMessage(playerid) {
	ClearChat(playerid);
	SCM(playerid, PLAVA_NEBO, "=========================[ {ffffff}BAN {03adfc}]=========================");
	va_SCM(playerid, PLAVA_NEBO, "Banovani ste sa servera! Razlog: {ffffff}%s.", PlayerInfo[playerid][pBanRazlog]);
	SCM(playerid, PLAVA_NEBO, "Ako mislite da je ovo neka greska, prijavite na nasem forumu!");
	SCM(playerid, PLAVA_NEBO, "========================================================");
	SetTimerEx("KickPlayer", 100, false, "i", playerid);
	return 1;
}

function LoadBanned(id, name[], value[]) {
	INI_String("Name", BannedInfo[id][bName], 128);
	return 1;
}

function StartEngine(playerid) {
	new broj = random(4), string[128], vehid = GetPlayerVehicleID(playerid);
	if(broj == 1) { 
		format(string, sizeof(string), "* Motor se nije upalio. (%s).", GetName(playerid));
		TogglePlayerControllable(playerid, 1);
		SetVehicleParamsEx(
			vehid,
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
	} else {
		format(string, sizeof(string), "* Motor se uspesno upalio. (%s).", GetName(playerid));
		TogglePlayerControllable(playerid, 1);
		VehInfo[vehid][vEngine] = 1;
		SetVehicleParamsEx(
			vehid, 
			VehInfo[vehid][vEngine], 
			VehInfo[vehid][vLights], 
			VehInfo[vehid][vAlarm],
			VehInfo[vehid][vDoor],
			VehInfo[vehid][vBonnet],
			VehInfo[vehid][vBoot],
			VehInfo[vehid][vObj]
		);
	}
	ProxDetector(20.0, playerid, string);
	return 1;
}

function TDUpdate() {
	new string[512], godina, mesec, dan, sat, minut;
	getdate(godina, mesec, dan), gettime(sat, minut);
	format(string, sizeof(string), "%s%d/%s%d/%s%d", ((dan < 10) ? ("0") : ("")), dan, ((mesec < 10) ? ("0") : ("")), mesec, ((godina < 10) ? ("0") : ("")), godina);
	TextDrawSetString(sdtd[0], string);
	format(string, sizeof(string), "%s%d:%s%d", ((sat < 10) ? ("0") : ("")), sat, ((minut < 10) ? ("0") : ("")), minut);
	TextDrawSetString(sdtd[1], string);
	foreach(new i : Player) UpdateBubble(i);
	return 1;
}

function ZatvoriGateZemunci() {
	MoveDynamicObject(ZemunciGate, 1245.65881, -766.94067, 92.77000, 2.0, 0, 0, 0);
	return 1;
}

function LoadProm(id, name[], value[]) {
	INI_String("Name", PromInfo[id][promName], 128);
	INI_Int("Duty", PromInfo[id][promDuty]);
	INI_Int("Neaktivnost", PromInfo[id][promNeaktivnost]);
	return 1;
}

function LoadVr(id, name[], value[]) {
	INI_Bool("Zakljucano", ZakljucanaVrata[ZatvorVrata[id]]);
	INI_Bool("Zatvoreno", ZatvorenaVrata[ZatvorVrata[id]]);
	return 1;
}

function SpecTimer(playerid, target) {
	if(IsPlayerSpec[playerid] == 0) return IsPlayerSpec[playerid];
	new interid, vwid;
	TogglePlayerSpectating(playerid, IsPlayerSpec[playerid]);
	interid = GetPlayerInterior(target);
	vwid = GetPlayerVirtualWorld(target);
	if(IsPlayerInAnyVehicle(target)) PlayerSpectateVehicle(playerid, GetPlayerVehicleID(target));
	else PlayerSpectatePlayer(playerid, target);
	SetPlayerInterior(playerid, interid);
	SetPlayerVirtualWorld(playerid, vwid);
	return 1;
}

function LoadHouses(id, name[], value[]) {
	INI_String("Owner", HouseInfo[id][hOwner], 128);
	INI_Int("Owned", HouseInfo[id][hOwned]);
	INI_Int("Cena", HouseInfo[id][hCena]);
	INI_Int("Level", HouseInfo[id][hLevel]);
	INI_Int("Neaktivnost", HouseInfo[id][hNeaktivnost]);
	INI_Float("X", HouseInfo[id][hX]);
	INI_Float("Y", HouseInfo[id][hY]);
	INI_Float("Z", HouseInfo[id][hZ]);
	INI_Int("InterID", HouseInfo[id][hInterID]);
	INI_Float("InterX", HouseInfo[id][hInterX]);
	INI_Float("InterY", HouseInfo[id][hInterY]);
	INI_Float("InterZ", HouseInfo[id][hInterZ]);
	INI_String("Rent", HouseInfo[id][hRent], 128);
	INI_Int("Rented", HouseInfo[id][hRented]);
	INI_String("OnRent", HouseInfo[id][hOnRent], 3);
	return 1;
}

function LoadOrgs(id, name[], value[]) {
	INI_String("Ime", OrgInfo[id][orgIme], 128);
	INI_String("Leader", OrgInfo[id][orgLeader], 128);
	INI_String("Member1", OrgInfo[id][orgMember1], 128);
	INI_String("Member2", OrgInfo[id][orgMember2], 128);
	INI_String("Member3", OrgInfo[id][orgMember3], 128);
	INI_String("Member4", OrgInfo[id][orgMember4], 128);
	INI_String("Member5", OrgInfo[id][orgMember5], 128);
	INI_String("Member6", OrgInfo[id][orgMember6], 128);
	INI_String("Member7", OrgInfo[id][orgMember7], 128);
	INI_String("Member8", OrgInfo[id][orgMember8], 128);
	INI_String("Member9", OrgInfo[id][orgMember9], 128);
	INI_String("Member10", OrgInfo[id][orgMember10], 128);
	INI_String("Member11", OrgInfo[id][orgMember11], 128);
	INI_String("Member12", OrgInfo[id][orgMember12], 128);
	INI_String("Member13", OrgInfo[id][orgMember13], 128);
	INI_String("Member14", OrgInfo[id][orgMember14], 128);
	INI_String("Member15", OrgInfo[id][orgMember15], 128);
	INI_String("Member16", OrgInfo[id][orgMember16], 128);
	INI_String("Member17", OrgInfo[id][orgMember17], 128);
	INI_String("Member18", OrgInfo[id][orgMember18], 128);
	INI_String("Member19", OrgInfo[id][orgMember19], 128);
	INI_String("Member20", OrgInfo[id][orgMember20], 128);
	INI_String("Member21", OrgInfo[id][orgMember21], 128);
	INI_String("Member22", OrgInfo[id][orgMember22], 128);
	INI_String("Member23", OrgInfo[id][orgMember23], 128);
	INI_String("Member24", OrgInfo[id][orgMember24], 128);
	INI_String("Member25", OrgInfo[id][orgMember25], 128);
	INI_String("Member26", OrgInfo[id][orgMember26], 128);
	INI_String("Member27", OrgInfo[id][orgMember27], 128);
	INI_String("Member28", OrgInfo[id][orgMember28], 128);
	INI_String("Member29", OrgInfo[id][orgMember29], 128);
	INI_String("Member30", OrgInfo[id][orgMember30], 128);
	INI_String("Member31", OrgInfo[id][orgMember31], 128);
	INI_String("Member32", OrgInfo[id][orgMember32], 128);
	INI_String("Member33", OrgInfo[id][orgMember33], 128);
	INI_String("Member34", OrgInfo[id][orgMember34], 128);
	INI_String("Member35", OrgInfo[id][orgMember35], 128);
	INI_String("Member36", OrgInfo[id][orgMember36], 128);
	INI_String("Member37", OrgInfo[id][orgMember37], 128);
	INI_String("Member38", OrgInfo[id][orgMember38], 128);
	INI_String("Member39", OrgInfo[id][orgMember39], 128);
	INI_String("Member40", OrgInfo[id][orgMember40], 128);
	INI_String("Member41", OrgInfo[id][orgMember41], 128);
	INI_String("Member42", OrgInfo[id][orgMember42], 128);
	INI_String("Member43", OrgInfo[id][orgMember43], 128);
	INI_String("Member44", OrgInfo[id][orgMember44], 128);
	INI_String("Member45", OrgInfo[id][orgMember45], 128);
	INI_String("Member46", OrgInfo[id][orgMember46], 128);
	INI_String("Member47", OrgInfo[id][orgMember47], 128);
	INI_String("Member48", OrgInfo[id][orgMember48], 128);
	INI_String("Member49", OrgInfo[id][orgMember49], 128);
	INI_String("Member50", OrgInfo[id][orgMember50], 128);
	INI_Int("Money", OrgInfo[id][orgMoney]);
	INI_Int("Mats", OrgInfo[id][orgMats]);
	INI_Int("Drugs", OrgInfo[id][orgDrugs]);
	INI_Int("Glock19", OrgInfo[id][orgGlock19]);
	INI_Int("AK_47", OrgInfo[id][orgAK_47]);
	INI_Int("M4", OrgInfo[id][orgM4]);
	INI_Int("Lisice", OrgInfo[id][orgLisice]);
	INI_String("Drzavna", OrgInfo[id][orgDrzavna], 3);
	INI_Float("X", OrgInfo[id][orgX]);
	INI_Float("Y", OrgInfo[id][orgY]);
	INI_Float("Z", OrgInfo[id][orgZ]);
	return 1;
}

function RefreshPickupLabel(id, tip) {
	new string[512];
	if(id == 0) {
		if(tip == 1) {
			for(new i = 0; i <= MAX_HOUSES; i++) {
				DestroyPickup(hPickup[i]);
				Delete3DTextLabel(hLabel[i]);
				if(HouseInfo[i][hOwned] == 0) format(string, sizeof(string), "{ffa500}[{ffffff}Kuca na prodaju{ffa500}]\nVlasnik: {ffffff}Niko\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d\n{ffa500}Ako zelite da kupite kucu kucajte /kupikucu", HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
				else format(string, sizeof(string), "{ffa500}Vlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d", HouseInfo[i][hOwner], HouseInfo[i][hCena], HouseInfo[i][hLevel], i);
				hPickup[i] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
				hLabel[i] = Create3DTextLabel(string, -1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 10.0, 0, 0);
			}
		} else if(tip == 2) {
			for(new i = 0; i <= MAX_ORGS; i++) {
				DestroyPickup(orgPickup[i]);
				Delete3DTextLabel(orgLabel[i]);
				format(string, sizeof(string), "{0000ff}[ {ffffff}%s {0000ff}]\n{ffffff}Leader: {0000ff}%s", OrgInfo[i][orgIme], OrgInfo[i][orgLeader]);
				orgLabel[i] = Create3DTextLabel(string, -1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ], 20.0, 0, 0);
				orgPickup[i] = CreatePickup(1314, 1, OrgInfo[i][orgX], OrgInfo[i][orgY], OrgInfo[i][orgZ]);
			}
		}
	} else {
		if(tip == 1) {
			DestroyPickup(hPickup[id]);
			Delete3DTextLabel(hLabel[id]);
			if(HouseInfo[id][hOwned] == 0) format(string, sizeof(string), "{ffa500}[{ffffff}Kuca na prodaju{ffa500}]\nVlasnik: {ffffff}Niko\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d\n{ffa500}Ako zelite da kupite kucu kucajte /kupikucu", HouseInfo[id][hCena], HouseInfo[id][hLevel], id);
			else format(string, sizeof(string), "{ffa500}Vlasnik: {ffffff}%s\n{ffa500}Cena: {ffffff}%d\n{ffa500}Level: {ffffff}%d\n{ffa500}Adresa: {ffffff}%d", HouseInfo[id][hOwner], HouseInfo[id][hCena], HouseInfo[id][hLevel], id);
			hPickup[id] = CreatePickup(1273, 1, HouseInfo[id][hX], HouseInfo[id][hY], HouseInfo[id][hZ]);
			hLabel[id] = Create3DTextLabel(string, -1, HouseInfo[id][hX], HouseInfo[id][hY], HouseInfo[id][hZ], 10.0, 0, 0);
		} else if(tip == 2) {
			DestroyPickup(orgPickup[id]);
			Delete3DTextLabel(orgLabel[id]);
			format(string, sizeof(string), "{0000ff}[ {ffffff}%s {0000ff}]\n{ffffff}Leader: {0000ff}%s", OrgInfo[id][orgIme], OrgInfo[id][orgLeader]);
			orgLabel[id] = Create3DTextLabel(string, -1, OrgInfo[id][orgX], OrgInfo[id][orgY], OrgInfo[id][orgZ], 20.0, 0, 0);
			orgPickup[id] = CreatePickup(1314, 1, OrgInfo[id][orgX], OrgInfo[id][orgY], OrgInfo[id][orgZ]);
		}
	}
	return 1;
}

function Time() {
	new sat;
	gettime(sat);
	SetWorldTime(sat);
	return 1;
}

function PayDay() {
	new h, m;
	gettime(h);
	if(h == 23 && m == 30) {
		SCMTA(PLAVA_NEBO, "Tesla Bot: {ffffff}Izvinjavam se, moram ugasiti server za 5 sekundi, vidimo se sutra!");
		SetTimer("ServerOff", 5000, false);
	}
	foreach(new playerid : Player) {
		new str[128];
		PlayerInfo[playerid][pRespekti]++;
		va_SCM(playerid, NARANDZASTA, "[DNEVNI RESPECT]: {ffffff}Sada imate %d/%d respecta.", PlayerInfo[playerid][pRespekti], PlayerInfo[playerid][pNeededRep]);
		if(!strcmp(PlayerInfo[playerid][pPosao], "Bus Vozac")) {
			format(str, sizeof(str), "{ffffff}Primili ste platu od {00ff00}$%d {ffffff}na Vas bankovni racun!\n", BUS_PLATA);
			SPD(playerid, d_payday, DIALOG_STYLE_MSGBOX, "{03adfc}Plata", str, "{03adfc}Izadji", "");
			PlayerInfo[playerid][pBanka] += BUS_PLATA;
		}
		if(!strcmp(PlayerInfo[playerid][pPosao], "Bankar")) {
			format(str, sizeof(str), "{ffffff}Primili ste platu od {00ff00}$%d {ffffff}na Vas bankovni racun!\n", BANK_PLATA);
			SPD(playerid, d_payday, DIALOG_STYLE_MSGBOX, "{03adfc}Plata", str, "{03adfc}Izadji", "");
			PlayerInfo[playerid][pBanka] += BANK_PLATA;
		}
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "LSPD")) {
			format(str, sizeof(str), "{ffffff}Primili ste platu od {00ff00}$%d {ffffff}na Vas bankovni racun!\n", POLICE_PLATA);
			SPD(playerid, d_payday, DIALOG_STYLE_MSGBOX, "{03adfc}Plata", str, "{03adfc}Izadji", "");
			PlayerInfo[playerid][pBanka] += POLICE_PLATA;
		}
		if(!strcmp(PlayerInfo[playerid][pOrganizacija], "Bolnica")) {
			format(str, sizeof(str), "{ffffff}Primili ste platu od {00ff00}$%d {ffffff}na Vas bankovni racun!\n", BOLNICAR_PLATA);
			SPD(playerid, d_payday, DIALOG_STYLE_MSGBOX, "{03adfc}Plata", str, "{03adfc}Izadji", "");
			PlayerInfo[playerid][pBanka] += BOLNICAR_PLATA;
		}
		if(PlayerInfo[playerid][pRespekti] >= PlayerInfo[playerid][pNeededRep]) {
			PlayerInfo[playerid][pRespekti] = 0;
			PlayerInfo[playerid][pGodine]++;
			PlayerInfo[playerid][pNeededRep] = PlayerInfo[playerid][pGodine] * 2 + 4;
			va_SCM(playerid, PLAVA_NEBO, "Cestitamo, napunili ste %d godina!", PlayerInfo[playerid][pGodine]);
			SetPlayerScore(playerid, PlayerInfo[playerid][pGodine]);
		}
		if(PlayerInfo[playerid][pRate] > 0) {
			new oduzmi;
			PlayerInfo[playerid][pRate]--;
			oduzmi = PlayerInfo[playerid][pKredit] / 10;
			PlayerInfo[playerid][pBanka] -= oduzmi;
			if(PlayerInfo[playerid][pRate] == 0) PlayerInfo[playerid][pKredit] = 0;
		}
		SavePlayer(playerid);
	}
	return 1;
}

function CarUpdate() {
	foreach(new playerid : Player) {
		if(GetPlayerWeapon(playerid) == PlayerInfo[playerid][pAK_47]) {
			SetPlayerAmmo(playerid, PlayerInfo[playerid][pAK_47], PlayerInfo[playerid][pAK_47Municija]);
		}
		if(IsPlayerInAnyVehicle(playerid)) {
			new vehid = GetPlayerVehicleID(playerid), fuel[128];
			format(fuel, sizeof(fuel), "%dL", VehInfo[vehid][vFuel]);
			PlayerTextDrawSetString(playerid, Fuel_t[playerid][1], fuel);
		}
	}
	return 1;
}

function BusTimer(playerid) {
	switch(jobprogress[playerid]) {
		case 1: {
			SetPlayerCheckpoint(playerid, 1315.6774,-1637.1493,12.9704, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali", 7000, 4);
		}
		case 2: {
			SetPlayerCheckpoint(playerid, 1097.0704,-1278.5746,13.0779, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali/iskrcali", 7000, 4);
		}
		case 3: {
			SetPlayerCheckpoint(playerid, 1615.5275,-1164.2144,23.4863, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali/iskrcali", 7000, 4);
		}
		case 4: {
			SetPlayerCheckpoint(playerid, 2027.1211,-1074.5443,24.1709, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali/iskrcali", 7000, 4);
		}
		case 5: {
			SetPlayerCheckpoint(playerid, 2075.4597,-1609.0992,12.9598, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali/iskrcali", 7000, 4);
		}
		case 6: {
			SetPlayerCheckpoint(playerid, 1609.6073,-1589.6415,13.1351, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali/iskrcali", 7000, 4);
		}
		case 7: {
			SetPlayerCheckpoint(playerid, 1215.7935,-1845.0688,12.9700, 5);
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno ukrcali/iskrcali", 7000, 4);
		}
		case 8: {
			new vehid = GetPlayerVehicleID(playerid);
			jobprogress[playerid] = 0;
			IsPlayerWorking[playerid] = 0;
			TogglePlayerControllable(playerid, 1);
			GameTextForPlayer(playerid, "Putnici su se uspesno iskrcali", 7000, 4);
			va_SCM(playerid, -1, "Zavrsili ste prevozenje putnika! Platu ce te primiti za %d minuta.", platatimer);
			RemovePlayerFromVehicle(playerid);
			SetVehicleToRespawn(vehid);
		}
	}
	return 1;
}

function BankTimer(playerid) {
	switch(jobprogress[playerid]) {
		case 1: {
			GameTextForPlayer(playerid, "Pratite markere...", 5000, 4);
			SetPlayerCheckpoint(playerid, 1316.8466,-1713.1470,13.64833, 5);
			TogglePlayerControllable(playerid, 1);
		}
		case 2: {
			GameTextForPlayer(playerid, "Istovarili ste novac. Sada, pratite markere i vratite kombi.", 5000, 4);
			SetPlayerCheckpoint(playerid, 1550.4214,-1020.8382,24.0744, 5);
			TogglePlayerControllable(playerid, 1);
		}
		case 3: {
			new vehid = GetPlayerVehicleID(playerid);
			jobprogress[playerid] = 0;
			IsPlayerWorking[playerid] = 0;
			TogglePlayerControllable(playerid, 1);
			va_SCM(playerid, -1, "Zavrsili ste prevozenje novca! Platu ce te primiti za %d minuta!", platatimer);
			RemovePlayerFromVehicle(playerid);
			SetVehicleToRespawn(vehid);
		}
	}
	return 1;
}

function LoadVehs(id, name[], value[]) {
	INI_Int("Engine", VehInfo[id][vEngine]);
	INI_Int("Lights", VehInfo[id][vLights]);
	INI_Int("Alarm", VehInfo[id][vAlarm]);
	INI_Int("Door", VehInfo[id][vDoor]);
	INI_Int("Bonnet", VehInfo[id][vBonnet]);
	INI_Int("Boot", VehInfo[id][vBoot]);
	INI_Int("Obj", VehInfo[id][vObj]);
	INI_Int("Fuel", VehInfo[id][vFuel]);
	INI_Int("Lock", VehInfo[id][vLock]);
	INI_String("Owner", VehInfo[id][vOwner], 128);
	return 1;
}

function ServerOff() {
	SendRconCommand("exit");
	return 1;
}

function RandomMessages() {
	new RandPoruka = random(sizeof(RandomPoruke));
	SCMTA(-1, RandomPoruke[RandPoruka]);
	return 1;
}

function Timer() {
	if(timer <= 0) timer = 10;
	timer--;
	return 1;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////