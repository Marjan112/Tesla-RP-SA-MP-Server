/*AC-Balkan Security v0.6 by Maki187 (Marko_Dimitrijevic)
http://www.balkan-rising.info/index.php?topic=10.0

http://balkan-samp.com/forum/index.php?topic=35102.0
Zamolio bi vas da nemenjate i neskalnjate creditse u skripti, sve ispod ovog teksta niposto nesmete da menjate,
odnosno ako promenite rizikujete da AC neradi!!*/
#include <a_players>
stock AC_BS_ResetPlayerMoney(playerid)
{
	ResetPlayerMoney(playerid);
	SetPVarInt(playerid, "SiguranNovac", 1);
	return 1;
}
stock AC_BS_GivePlayerMoney(playerid, novac)
{
	GivePlayerMoney(playerid, novac);
	SetPVarInt(playerid, "SiguranNovac", 1);
	return 1;
}
stock AC_BS_SetPlayerVirtualWorld(playerid, vw)
{
	SetPVarFloat(playerid,"ZastitaTeleporta",1);
	SetPlayerVirtualWorld(playerid,vw);
	SetPVarInt(playerid, "SiguranVW", vw);
	return 1;
}
stock AC_BS_SetPlayerInterior(playerid, intid)
{
	SetPVarFloat(playerid,"ZastitaTeleporta",1);
	SetPlayerInterior(playerid, intid);
	SetPVarInt(playerid, "SiguranInt", intid);
	return 1;
}
stock AC_BS_SetPlayerPos(playerid, Float:xx, Float:yy, Float:zz)
{
	SetPVarFloat(playerid,"ZastitaTeleporta",1);
	SetPlayerPos(playerid, xx,yy,zz);
	SetPVarInt(playerid, "SiguranTeleport", 1);
	return 1;
}
#define acime "[AC-Balkan Security]:"
stock AC_BS_SetPlayerHealth(playerid,Float:helti)
{
	SetPVarFloat(playerid,"ZastitaHelta",1);
	SetPlayerHealth(playerid,helti);
	SetPVarFloat(playerid,"SigurniHelti",helti);
}
stock AC_BS_SetPlayerArmour(playerid,Float:armor)
{
	SetPVarFloat(playerid,"ZastitaArmora",1);
	SetPlayerArmour(playerid,armor);
	SetPVarFloat(playerid,"SigurniArmor",armor);
}
#define ACCREDITS SendClientMessage(playerid,BELA, "");
/*SVA PRAVA ZADRZANA, www.balkan-rising.info (c) 2011-2012
Koriscenjem ovog AC-a slazete se sa tim da za sve gubitke koji nastanu na vasem serveru, nije kriv autor ovog AC-a!*/