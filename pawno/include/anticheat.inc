
#include <a_samp>
#include <core>
#include <float>

// Anti Money / Anti Ban Weapon Cheat by FreshKilla

// Weapons
new COLT45 = 0;
new SILENCED = 0;
new DEAGLE = 0;
new SHOTGUN = 0;
new SAWNOFF = 0;
new SPAS12 = 0;
new UZI = 0;
new MP5 = 0;
new AK47 = 0;
new M4 = 0;
new TEC9 = 0;
new RIFLE = 0;
new SNIPER = 0;
new RPG = 1;
new HEATSEEKER = 1;
new FLAME = 1;
new MINIGUN = 1;
new SATCHEL = 0;

// Other
new CheatMsg = 1;
new PCash[MAX_PLAYERS];

// Forwards
forward cheats();
forward playermoney(playerid);
forward playerweapon(playerid);
forward playerfoundweapon(playerid);

public cheats()
{
	for(new i=0; i<MAX_PLAYERS; i++)
	{
	playermoney(i); // Anti Money Cheat
	playerweapon(i); // Anti Block Weapon
	}
	return 1;
}

public playermoney(playerid)
{
    ResetPlayerMoney(playerid);
    return GivePlayerMoney(playerid,PCash[playerid]);
}

public playerweapon(playerid)
{
    if(COLT45 == 1 && GetPlayerWeapon(playerid) == 22)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(SILENCED == 1 && GetPlayerWeapon(playerid) == 23)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(DEAGLE == 1 && GetPlayerWeapon(playerid) == 24)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(SHOTGUN == 1 && GetPlayerWeapon(playerid) == 25)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(SAWNOFF == 1 && GetPlayerWeapon(playerid) == 26)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(SPAS12 == 1 && GetPlayerWeapon(playerid) == 27)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(UZI == 1 && GetPlayerWeapon(playerid) == 28)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(MP5 == 1 && GetPlayerWeapon(playerid) == 29)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(AK47 == 1 && GetPlayerWeapon(playerid) == 30)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(M4 == 1 && GetPlayerWeapon(playerid) == 31)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(TEC9 == 1 && GetPlayerWeapon(playerid) == 32)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(RIFLE == 1 && GetPlayerWeapon(playerid) == 33)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(SNIPER == 1 && GetPlayerWeapon(playerid) == 34)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(RPG == 1 && GetPlayerWeapon(playerid) == 35)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(HEATSEEKER == 1 && GetPlayerWeapon(playerid) == 36)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(FLAME == 1 && GetPlayerWeapon(playerid) == 37)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(MINIGUN == 1 && GetPlayerWeapon(playerid) == 38)
    {
    playerfoundweapon(playerid);
    return 1;
    }
    if(SATCHEL == 1 && GetPlayerWeapon(playerid) == 39)
    {
    playerfoundweapon(playerid);
    return 1;
    }
	return 1;
}

public playerfoundweapon(playerid)
{
	if(CheatMsg == 1)
	{
	new sendername[MAX_PLAYER_NAME];
	new string[255];
   	GetPlayerName(playerid, sendername, sizeof(sendername));
    format(string, sizeof(string), "%s was kicked by Auto Kick, Reason: Unauthorized Weapon", sendername);
    SendClientMessageToAll(0xFF000096,string);
	}
    SendClientMessage(playerid,0xFF000096,"You are kicked for having a blocked weapon");
    ResetPlayerWeapons(playerid);
    return Kick(playerid);
}

stock GivePlayerPCash(playerid, money)
{
	PCash[playerid] = PCash[playerid] + money;
	return PCash[playerid];
}

stock ResetPlayerPCash(playerid)
{
	PCash[playerid] = 0;
	return PCash[playerid];
}

stock GetPlayerPCash(playerid)
{
	return PCash[playerid];
}
