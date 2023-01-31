/*------------------------------------------------------------------------------
			######## ##        ######             ###     ######
			##       ##       ##    ##           ## ##   ##    ##
			##       ##       ##                ##   ##  ##
			######   ##       ##               ##     ## ##
			##       ##       ##               ######### ##
			##       ##       ##    ##         ##     ## ##    ##
			######## ########  ######  ####### ##     ##  ######


 							########  ##    ##
							##     ##  ##  ##
							##     ##   ####
							########     ##
							##     ##    ##
							##     ##    ##
							########     ##


		######## ##        #######   ######  ######## ########   #######
		##       ##       ##     ## ##    ##    ##    ##     ## ##     ##
		##       ##       ##     ## ##          ##    ##     ## ##     ##
		######   ##       ##     ## ##          ##    ########  ##     ##
		##       ##       ##     ## ##          ##    ##   ##   ##     ##
		##       ##       ##     ## ##    ##    ##    ##    ##  ##     ##
		######## ########  #######   ######     ##    ##     ##  #######

                             Anti-Cheat(ELC_AC)

                                PROTECTIONS :
                              Anti-Weapon HACK
                               Anti-Ammo HACK
                            Anti-Ammo Block HACK
                               Anti-Money HACKF
                               Anti-Speed HACK
				     	Anti-Teleport & Anti-Airbreak
				     		  Anti-Health HACK
				     		  Anti-Armour HACK

                                    BUG :
               					  Nothing

                                  VERSION :
							        V3.3

							     COMPATIBLE :
							     SA-MP 0.3c
									 &
							     SA-MP 0.3d

                                  CREDITS :
                              ELOCTRO (SCRIPT)
                         SIM (GetTickCount for linux)

				          ELC_AC THE BEST PROTECTION
		                              !

                                    \**/
/*/- Anti-Cheat By Eloctro -----------------------------------------------------

                            ELC PRODUCTION(FRANCE)

                         http://eloctro.blogspot.com/

*/
#include <a_samp>

/*----------------------------------------------------------------------------*/
//Anti-Cheat Statut defaut :
#define ANTI_WEAPON_&_AMMO_HACK     1
#define ANTI_AMMO_BLOCK_HACK        1
#define ANTI_MONEY_HACK             1
#define ANTI_SPEED_HACK             1
#define ANTI_TELEPORT/AIBREAK_HACK  1
#define ANTI_HEALTH_HACK            0//Not fix
#define ANTI_ARMOUR_HACK            0//Not fix
//Configuration :
#define MAX_SPEED_VEHICLE                   380.0 // SPEED VEHICLE MAX(380=default)
#define MAX_VEHICLE_DISTANCE_PER_SECOND     180   // DISTANCE PARCOUR MAX VEHICLE PER SECOND(180=default)
#define MAX_PED_DISTANCE_PER_SECOND         100   // DISTANCE PARCOUR MAX AT PED PER SECOND(100=default)
#define SPRINT_SPEED                        30.0  // (30=DEFAULT/BETA)
#define TIRE_RATE                           2000  // (2000=default)
#define TIMER_CHEAT_RATE                    3500
#define TIME_GRANULITY                      50    // Granulity GetTickCount
#define DELAY_LOAD_AFTER_SPAWN              5000
#define MAX_DELAY_SEND_STATS                2000
#define MAX_HEALTH                          100   // Max HEALTH
#define MAX_ARMOUR                          100   // Max ARMOUR
//STATUS MODE :
//#define NO_TICK_COUNT  //uncomment If GetTickCount() bug(linux?)
#define INCLUDE_BASE_MODE //uncomment to pass in mod include
#define MODE_DELAY_SEND_STATS //uncomment if the sending of stats is a bit slow(RECOMMANDED)
//Calcul(DON'T TOUCH)----------------------------------------------------------
#define XMAX_VEHICLE_DISTANCE_PER_SECOND MAX_VEHICLE_DISTANCE_PER_SECOND*(TIMER_CHEAT_RATE/1000)
#define XMAX_PED_DISTANCE_PER_SECOND MAX_PED_DISTANCE_PER_SECOND*(TIMER_CHEAT_RATE/1000)
#define SaveTime(%0,%1) %0=%1
#define IsPassTime(%0,%1) ((MAX_DELAY_SEND_STATS+%0)<%1)//Time Action ,Time Now
#define IsPlayerCheatPos(%0) (!IsPlayerInRangeOfPoint(%0,XMAX_VEHICLE_DISTANCE_PER_SECOND,CheatPlayerInfo[%0][aX],CheatPlayerInfo[%0][aY],CheatPlayerInfo[%0][aZ]))||((GetPlayerSurfingVehicleID(%0)==INVALID_VEHICLE_ID && !IsPlayerInAnyVehicle(%0)) && !IsPlayerInRangeOfPoint(%0,XMAX_PED_DISTANCE_PER_SECOND,CheatPlayerInfo[%0][aX],CheatPlayerInfo[%0][aY],CheatPlayerInfo[%0][aZ]))
/*----------------------------------------------------------------------------*/
enum aELCp
{
	aMoney,
	aAmmo[12],
	aWeapon[12],
	aTickFire,
	aAmmoFire,
	aWeaponFire,
	Float:aHealth,
	Float:aGainHealth,
	Float:aArmour,
	aTimer,
	Float:aX,
	Float:aY,
	Float:aZ,
	aAntiTeleportHack,
	aAntiWeaponHack,
	aAntiAmmoBlockHack,
	aAntiMoneyHack,
	aAntiSpeedHack,
	aAntiHealthHack,
	aAntiArmourHack,
#if defined MODE_DELAY_SEND_STATS
	aGiveWeaponTime,
	aGiveMoneyTime,
	aGiveHealthTime,
	aGiveArmourTime,
#endif
	aSetPositionTime,
	aSpawnPlayer
};
new CheatPlayerInfo[MAX_PLAYERS][aELCp];
#if defined NO_TICK_COUNT
enum aELCs
{
	TickCount,
	TimerTick
};
new CheatServerInfo[aELCs];
#endif
/*stock SENDPOS(playerid)
{
	new Float:Px[3],Ps[128];
	GetPlayerPos(playerid,Px[0],Px[1],Px[2]);
	format(Ps, 128,"ACUTEL : %f,%f,%f | AVANT : %f,%f,%f",Px[0],Px[1],Px[2],CheatPlayerInfo[playerid][aX],CheatPlayerInfo[playerid][aY],CheatPlayerInfo[playerid][aZ]);
	SendClientMessageToAll(0xBD0000FF,Ps);
}*/
/*----------------------------------------------------------------------------*/
stock Float:GetPlayerSpeedXY(playerid)
{
new Float:SpeedX, Float:SpeedY, Float:SpeedZ;
new Float:Speed;
if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), SpeedX, SpeedY, SpeedZ);
else GetPlayerVelocity(playerid, SpeedX, SpeedY, SpeedZ);
Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatpower(SpeedY, 2.0)));
return floatmul(Speed, 200.0);
}
#if defined NO_TICK_COUNT
	#define GetTickCount()                          (CheatServerInfo[TickCount])
	forward TimeUpdate();
	public TimeUpdate()
	{
		CheatServerInfo[TickCount] +=TIME_GRANULITY;
		return 1;
	}
#endif
forward OnPlayerCheckCheat(playerid);
forward OnPlayerCheat(playerid, cheatid);
forward ELC_AC_EnablePlayerCheatID(playerid,cheatid,enable);
forward ELC_AC_OnPlayerBuy(playerid,buyprice);
forward OnPlayerCheckFaceWall(playerid,Float:wall_x,Float:wall_y,Float:wall_z,Float:nwall_x,Float:nwall_y,Float:wall_he);
/*----------------------------------------------------------------------------*/
forward ELC_AC_GivePlayerMoney(playerid, money);
public ELC_AC_GivePlayerMoney(playerid, money)
{
    if(CheatPlayerInfo[playerid][aAntiMoneyHack]==1)CheatPlayerInfo[playerid][aAntiMoneyHack]=2;
	CheatPlayerInfo[playerid][aMoney] += money;
	GivePlayerMoney(playerid, money);
	#if defined MODE_DELAY_SEND_STATS
	SaveTime(CheatPlayerInfo[playerid][aGiveMoneyTime],GetTickCount());
	#endif
	if(CheatPlayerInfo[playerid][aAntiMoneyHack]==2)CheatPlayerInfo[playerid][aAntiMoneyHack]=1;
	return 1;
}
stock initial_GivePlayerMoney(playerid, money)
{
	return GivePlayerMoney(playerid, money);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_GivePlayerMoney
    #undef GivePlayerMoney
#else
    #define _ALS_GivePlayerMoney
#endif
#define GivePlayerMoney ELC_AC_GivePlayerMoney
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
forward ELC_AC_ResetPlayerMoney(playerid);
public ELC_AC_ResetPlayerMoney(playerid)
{
	if(CheatPlayerInfo[playerid][aAntiMoneyHack]==1)CheatPlayerInfo[playerid][aAntiMoneyHack]=2;
	ResetPlayerMoney(playerid);
	CheatPlayerInfo[playerid][aMoney] = 0;
	#if defined MODE_DELAY_SEND_STATS
	SaveTime(CheatPlayerInfo[playerid][aGiveMoneyTime],GetTickCount());
	#endif
	if(CheatPlayerInfo[playerid][aAntiMoneyHack]==2)CheatPlayerInfo[playerid][aAntiMoneyHack]=1;
	return 1;
}
stock initial_ResetPlayerMoney(playerid)
{
	return ResetPlayerMoney(playerid);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_ResetPlayerMoney
    #undef ResetPlayerMoney
#else
    #define _ALS_ResetPlayerMoney
#endif
#define ResetPlayerMoney ELC_AC_ResetPlayerMoney
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
forward ELC_AC_GetPlayerMoney(playerid);
public ELC_AC_GetPlayerMoney(playerid)
{
	return CheatPlayerInfo[playerid][aMoney];
}
stock initial_GetPlayerMoney(playerid)
{
	return GetPlayerMoney(playerid);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_GetPlayerMoney
    #undef GetPlayerMoney
#else
    #define _ALS_GetPlayerMoney
#endif
#define GetPlayerMoney ELC_AC_GetPlayerMoney
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
forward ELC_AC_SetPlayerPos(playerid, Float:ix, Float:iy, Float:iz);
public ELC_AC_SetPlayerPos(playerid, Float:ix, Float:iy, Float:iz)
{
    if(CheatPlayerInfo[playerid][aAntiTeleportHack]==1)CheatPlayerInfo[playerid][aAntiTeleportHack]=2;
	SaveTime(CheatPlayerInfo[playerid][aSetPositionTime],GetTickCount());
	CheatPlayerInfo[playerid][aX]=ix; CheatPlayerInfo[playerid][aY]=iy; CheatPlayerInfo[playerid][aZ]=iz;
	SetPlayerPos(playerid, ix, iy, iz);
    if(CheatPlayerInfo[playerid][aAntiTeleportHack]==2)CheatPlayerInfo[playerid][aAntiTeleportHack]=1;
	return 1;
}
stock initial_SetPlayerPos(playerid, Float:ix, Float:iy, Float:iz)
{
	return SetPlayerPos(playerid, ix, iy, iz);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_SetPlayerPos
    #undef SetPlayerPos
#else
    #define _ALS_SetPlayerPos
#endif
#define SetPlayerPos ELC_AC_SetPlayerPos
//ALS_OFF_SYSTEME ----------------
#endif
/*----------------------------------------------------------------------------*/
forward ELC_AC_PutPlayerInVehicle(playerid,vehicleid, seatid);
public ELC_AC_PutPlayerInVehicle(playerid,vehicleid, seatid)
{
    if(CheatPlayerInfo[playerid][aAntiTeleportHack]==1)CheatPlayerInfo[playerid][aAntiTeleportHack]=2;
	SaveTime(CheatPlayerInfo[playerid][aSetPositionTime],GetTickCount());
	CheatPlayerInfo[playerid][aSpawnPlayer]=1;
	PutPlayerInVehicle(playerid,vehicleid, seatid);
	if(CheatPlayerInfo[playerid][aAntiTeleportHack]==2)CheatPlayerInfo[playerid][aAntiTeleportHack]=1;
	return 1;
}
stock initial_PutPlayerInVehicle(playerid,vehicleid, seatid)
{
	return PutPlayerInVehicle(playerid,vehicleid, seatid);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_PutPlayerInVehicle
    #undef PutPlayerInVehicle
#else
    #define _ALS_PutPlayerInVehicle
#endif
#define PutPlayerInVehicle ELC_AC_PutPlayerInVehicle
//ALS_OFF_SYSTEME ----------------
#endif
/*----------------------------------------------------------------------------*/
forward ELC_AC_TogglePlayerSpectating(playerid, toggle);
public ELC_AC_TogglePlayerSpectating(playerid, toggle)
{
	if(toggle==1)
	{
		if(CheatPlayerInfo[playerid][aAntiSpeedHack]==0) CheatPlayerInfo[playerid][aAntiSpeedHack]=3;
		if(CheatPlayerInfo[playerid][aAntiTeleportHack]==0) CheatPlayerInfo[playerid][aAntiTeleportHack]=3;
	}
	else
	{
		if(CheatPlayerInfo[playerid][aAntiSpeedHack]==3) CheatPlayerInfo[playerid][aAntiSpeedHack]=1;
		if(CheatPlayerInfo[playerid][aAntiTeleportHack]==3)CheatPlayerInfo[playerid][aAntiTeleportHack]=1;
		CheatPlayerInfo[playerid][aSpawnPlayer]=1;
		SaveTime(CheatPlayerInfo[playerid][aSetPositionTime],GetTickCount());
	}
	return TogglePlayerSpectating(playerid, toggle);
}
stock initial_TogglePlayerSpectating(playerid, toggle)
{
	return TogglePlayerSpectating(playerid, toggle);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_TogglePlayerSpectating
    #undef TogglePlayerSpectating
#else
    #define _ALS_TogglePlayerSpectating
#endif
#define TogglePlayerSpectating ELC_AC_TogglePlayerSpectating
//ALS_OFF_SYSTEME ----------------
#endif
//Weapon------------------------------------------------------------------------
/*#define IsNotWeaponNoAmmo(%0) (%0!=0 && %0!=1 && %0!=10)
#define IsNotWeaponVise(%0,%1) (%0>1 && %0!=10 && %0!=6 && %0!=9 && %0!=11 && %0!=12 && %1!=35 && %1!=36 %1!=43)*/
stock IsNotWeaponNoAmmo(WeaponID)
{
	new slot=GetWeaponSlot(WeaponID);
	if(slot!=0 && slot!=1 && slot!=10)return 1;
	return 0;
}
stock IsNotWeaponVise(WeaponID)
{
	new slot=GetWeaponSlot(WeaponID);
	if(slot>1 && slot!=10 && slot!=6 && slot!=9 &&slot!=11 && slot!=12 && slot!=35 && slot!=36 && slot!=43) return 1;
	return 0;
}
stock IsGiveVehicleWeapon(WeaponID)
{
	if(WeaponID==25 || WeaponID==46 || WeaponID==2) return 1;
	return 0;
}
#define IsValidWeapon(%0) (%0>=1 && %0<=18 || %0>=21 && %0<=46)
stock GetWeaponSlot(weaponid)
{
	new slot;
	switch(weaponid)
	{
		case 0,1: slot = 0;
		case 2 .. 9: slot = 1;
		case 10 .. 15: slot = 10;
		case 16 .. 18, 39: slot = 8;
		case 22 .. 24: slot =2;
		case 25 .. 27: slot = 3;
		case 28, 29, 32: slot = 4;
		case 30, 31: slot = 5;
		case 33, 34: slot = 6;
		case 35 .. 38: slot = 7;
		case 40: slot = 12;
		case 41 .. 43: slot = 9;
		case 44 .. 46: slot = 11;
	}
	return slot;
}
/*----------------------------------------------------------------------------*/
forward ELC_AC_GivePlayerWeapon(playerid,Weapon,ammo);
public ELC_AC_GivePlayerWeapon(playerid,Weapon,ammo)
{
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==1)CheatPlayerInfo[playerid][aAntiWeaponHack]=2;
	new slot=GetWeaponSlot(Weapon);
	if(IsValidWeapon(Weapon))
	{
		CheatPlayerInfo[playerid][aWeapon][slot] = Weapon;
		CheatPlayerInfo[playerid][aAmmo][slot] += ammo;
		GivePlayerWeapon(playerid,Weapon,ammo);
		#if defined MODE_DELAY_SEND_STATS
		SaveTime(CheatPlayerInfo[playerid][aGiveWeaponTime],GetTickCount());
		#endif
	}
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==2)CheatPlayerInfo[playerid][aAntiWeaponHack]=1;
    return 1;
}
stock initial_GivePlayerWeapon(playerid,Weapon,ammo)
{
	return GivePlayerWeapon(playerid,Weapon,ammo);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_GivePlayerWeapon
    #undef GivePlayerWeapon
#else
    #define _ALS_GivePlayerWeapon
#endif
#define GivePlayerWeapon ELC_AC_GivePlayerWeapon
//ALS_OFF_SYSTEME ----------------
#endif
/*----------------------------------------------------------------------------*/
forward ELC_AC_SetPlayerAmmo(playerid,weapon,ammo);
public ELC_AC_SetPlayerAmmo(playerid,weapon,ammo)
{
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==1)CheatPlayerInfo[playerid][aAntiWeaponHack]=2;
 	if(weapon>0 && 47>weapon)
 	{
		CheatPlayerInfo[playerid][aAmmo][GetWeaponSlot(weapon)]=ammo;
		SetPlayerAmmo(playerid,weapon,ammo);
		#if defined MODE_DELAY_SEND_STATS
		SaveTime(CheatPlayerInfo[playerid][aGiveWeaponTime],GetTickCount());
		#endif
	}
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==2)CheatPlayerInfo[playerid][aAntiWeaponHack]=1;
    return 1;
}
stock initial_SetPlayerAmmo(playerid,weapon,ammo)
{
	return SetPlayerAmmo(playerid,weapon,ammo);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_SetPlayerAmmo
    #undef SetPlayerAmmo
#else
    #define _ALS_SetPlayerAmmo
#endif
#define SetPlayerAmmo ELC_AC_SetPlayerAmmo
//ALS_OFF_SYSTEME ----------------
#endif
/*----------------------------------------------------------------------------*/
forward ELC_AC_ResetPlayerWeapons(playerid);
public ELC_AC_ResetPlayerWeapons(playerid)
{
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==1)CheatPlayerInfo[playerid][aAntiWeaponHack]=2;
	for(new i = 0; i <12; i++)
	{
        CheatPlayerInfo[playerid][aWeapon][i]=0;
        CheatPlayerInfo[playerid][aAmmo][i]=0;
	}
	ResetPlayerWeapons(playerid);
	#if defined MODE_DELAY_SEND_STATS
	SaveTime(CheatPlayerInfo[playerid][aGiveWeaponTime],GetTickCount());
	#endif
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==2)CheatPlayerInfo[playerid][aAntiWeaponHack]=1;
    return 1;
}
stock initial_ResetPlayerWeapons(playerid)
{
	return ResetPlayerWeapons(playerid);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_ResetPlayerWeapons
    #undef ResetPlayerWeapons
#else
    #define _ALS_ResetPlayerWeapons
#endif
#define ResetPlayerWeapons ELC_AC_ResetPlayerWeapons
//ALS_OFF_SYSTEME ----------------
#endif
/*----------------------------------------------------------------------------*/
forward ELC_AC_SetPlayerHealth(playerid,Float:health);
public ELC_AC_SetPlayerHealth(playerid,Float:health)
{
	if(CheatPlayerInfo[playerid][aAntiHealthHack]==1)CheatPlayerInfo[playerid][aAntiHealthHack]=2;
	if(health>MAX_HEALTH)
	{
    	CheatPlayerInfo[playerid][aHealth]=MAX_HEALTH;
		SetPlayerHealth(playerid,MAX_HEALTH);
	}
	else
	{
	    CheatPlayerInfo[playerid][aHealth]=health;
		SetPlayerHealth(playerid,health);
	}
	#if defined MODE_DELAY_SEND_STATS
	SaveTime(CheatPlayerInfo[playerid][aGiveHealthTime],GetTickCount());
	#endif
	if(CheatPlayerInfo[playerid][aAntiHealthHack]==2)CheatPlayerInfo[playerid][aAntiHealthHack]=1;
    return 1;
}
stock initial_SetPlayerHealth(playerid,Float:health)
{
	return SetPlayerHealth(playerid,health);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_GivePlayerWeapon
    #undef GivePlayerWeapon
#else
    #define _ALS_GivePlayerWeapon
#endif
#define GivePlayerWeapon ELC_AC_GivePlayerWeapon
//ALS_OFF_SYSTEME ----------------
#endif
/*----------------------------------------------------------------------------*/
forward ELC_AC_SetPlayerArmour(playerid,Float:armour);
public ELC_AC_SetPlayerArmour(playerid,Float:armour)
{
	if(CheatPlayerInfo[playerid][aAntiArmourHack]==1)CheatPlayerInfo[playerid][aAntiArmourHack]=2;
	if(armour>MAX_ARMOUR)
	{
    	CheatPlayerInfo[playerid][aArmour]=MAX_ARMOUR;
		SetPlayerHealth(playerid,MAX_ARMOUR);
	}
	else
	{
	    CheatPlayerInfo[playerid][aArmour]=armour;
		SetPlayerHealth(playerid,armour);
	}
	#if defined MODE_DELAY_SEND_STATS
	SaveTime(CheatPlayerInfo[playerid][aGiveArmourTime],GetTickCount());
	#endif
	if(CheatPlayerInfo[playerid][aAntiArmourHack]==2)CheatPlayerInfo[playerid][aAntiArmourHack]=1;
    return 1;
}
stock initial_SetPlayerArmour(playerid,Float:armour)
{
	return SetPlayerArmour(playerid,armour);
}
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_GivePlayerWeapon
    #undef GivePlayerWeapon
#else
    #define _ALS_GivePlayerWeapon
#endif
#define GivePlayerWeapon ELC_AC_GivePlayerWeapon
//ALS_OFF_SYSTEME ----------------
#endif
//Core--------------------------------------------------------------------------
public OnPlayerCheckCheat(playerid)
{
	new IsTime=GetTickCount();
	#if defined MODE_DELAY_SEND_STATS
	if(CheatPlayerInfo[playerid][aAntiMoneyHack]==1 && IsPassTime(CheatPlayerInfo[playerid][aGiveMoneyTime],IsTime))
	#else
	if(CheatPlayerInfo[playerid][aAntiMoneyHack]==1)
	#endif
	{
		new elc_getmoney=initial_GetPlayerMoney(playerid);
		if(elc_getmoney!=CheatPlayerInfo[playerid][aMoney])
		{
			if (CheatPlayerInfo[playerid][aMoney] > elc_getmoney)
			{
                ELC_AC_OnPlayerBuy(playerid,CheatPlayerInfo[playerid][aMoney]-elc_getmoney);
			    CheatPlayerInfo[playerid][aMoney]=elc_getmoney;
			}
			else
			{
				initial_ResetPlayerMoney(playerid);
				initial_GivePlayerMoney(playerid, CheatPlayerInfo[playerid][aMoney]);
				CallRemoteFunction("OnPlayerCheat", "dd", playerid,1);
			}
		}
	}
	if(CheatPlayerInfo[playerid][aAntiSpeedHack]==1)
	{
		if((GetPlayerSurfingVehicleID(playerid)!=INVALID_VEHICLE_ID || GetPlayerState(playerid) == PLAYER_STATE_DRIVER) && (GetPlayerSpeedXY(playerid) > MAX_SPEED_VEHICLE)) CallRemoteFunction("OnPlayerCheat", "dd", playerid,5);
	}
	if(CheatPlayerInfo[playerid][aAntiTeleportHack]==1)
	{
		if(IsPlayerCheatPos(playerid))
		{
		    #if defined MODE_DELAY_SEND_STATS
		    if(CheatPlayerInfo[playerid][aSpawnPlayer]==0 && IsPassTime(CheatPlayerInfo[playerid][aSetPositionTime],IsTime))
            #else
            if(CheatPlayerInfo[playerid][aSpawnPlayer]==0)
            #endif
			{
				CallRemoteFunction("OnPlayerCheat", "dd", playerid,6);
			}
		    GetPlayerPos(playerid,CheatPlayerInfo[playerid][aX],CheatPlayerInfo[playerid][aY],CheatPlayerInfo[playerid][aZ]);
		}
		else
		{
		    GetPlayerPos(playerid,CheatPlayerInfo[playerid][aX],CheatPlayerInfo[playerid][aY],CheatPlayerInfo[playerid][aZ]);
		    #if defined MODE_DELAY_SEND_STATS
            if(CheatPlayerInfo[playerid][aSpawnPlayer]==1 && IsPassTime(CheatPlayerInfo[playerid][aSetPositionTime],IsTime))
            #else
            if(CheatPlayerInfo[playerid][aSpawnPlayer]==1)
            #endif
			{
                CheatPlayerInfo[playerid][aSpawnPlayer]=0;
			}
			#if defined MODE_DELAY_SEND_STATS
            else CheatPlayerInfo[playerid][aSetPositionTime]=0;
            #endif
		}
	}
	#if defined MODE_DELAY_SEND_STATS
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==1 && IsPassTime(CheatPlayerInfo[playerid][aGiveWeaponTime],IsTime))
	#else
	if(CheatPlayerInfo[playerid][aAntiWeaponHack]==1)
	#endif
	{
		//ANTI BLOCK MUNITIONS
		if(CheatPlayerInfo[playerid][aTickFire]!=0 && CheatPlayerInfo[playerid][aAntiAmmoBlockHack]==1)
		{
			if((IsTime-CheatPlayerInfo[playerid][aTickFire]) >= TIRE_RATE)
			{
				if(CheatPlayerInfo[playerid][aWeaponFire]==GetPlayerWeapon(playerid))
				{
					if(CheatPlayerInfo[playerid][aAmmoFire]==GetPlayerAmmo(playerid)) ELC_AC_StartCheckPlayerFaceWall(playerid);
					CheatPlayerInfo[playerid][aTickFire]=0;
					CheatPlayerInfo[playerid][aAmmoFire]=0;
					CheatPlayerInfo[playerid][aWeaponFire]=0;

				}
				else
				{

				    new keys,ud,lr;
				    GetPlayerKeys(playerid,keys,ud,lr);
					if(keys==4 && IsNotWeaponVise(GetPlayerWeapon(playerid)))
					{
						CheatPlayerInfo[playerid][aTickFire]=IsTime;
						CheatPlayerInfo[playerid][aAmmoFire]=GetPlayerAmmo(playerid);
						CheatPlayerInfo[playerid][aWeaponFire]=GetPlayerWeapon(playerid);
					}
					else if(keys==132 && IsNotWeaponNoAmmo(GetPlayerWeapon(playerid)) && (GetPlayerSpeedXY(playerid) < 1))
					{
						CheatPlayerInfo[playerid][aTickFire]=IsTime;
						CheatPlayerInfo[playerid][aAmmoFire]=GetPlayerAmmo(playerid);
						CheatPlayerInfo[playerid][aWeaponFire]=GetPlayerWeapon(playerid);
					}
					else
					{
						CheatPlayerInfo[playerid][aTickFire]=0;
						CheatPlayerInfo[playerid][aAmmoFire]=0;
						CheatPlayerInfo[playerid][aWeaponFire]=0;
					}
				}
			}
		}
		new WA_VAR[3];
		for(new i = 0; i <12; i++)
		{
		    WA_VAR[0]=0; WA_VAR[1]=0;
			GetPlayerWeaponData(playerid,i,WA_VAR[0],WA_VAR[1]);
			if((WA_VAR[0]!=CheatPlayerInfo[playerid][aWeapon][i] && WA_VAR[0]!=0 && WA_VAR[1]!=0))
			{
				//CHEAT WEAPON
				if(!IsGiveVehicleWeapon(WA_VAR[0])) CallRemoteFunction("OnPlayerCheat", "dd", playerid,2);
				SetPlayerAmmo(playerid, WA_VAR[0], 0);
			}
			else if(((CheatPlayerInfo[playerid][aAmmo][i]-WA_VAR[1]) < 0) && IsNotWeaponNoAmmo(WA_VAR[0]) && WA_VAR[0]!=0)
			{
				//CHEAT AMMO
				CallRemoteFunction("OnPlayerCheat", "dd", playerid,3);
				SetPlayerAmmo(playerid, WA_VAR[0], 0);
			}
			else if(CheatPlayerInfo[playerid][aWeapon][i]!=0 && WA_VAR[0]==0 && WA_VAR[1]==0)
			{
			    CheatPlayerInfo[playerid][aWeapon][i]=0;
			    CheatPlayerInfo[playerid][aAmmo][i]=0;
			}
			else CheatPlayerInfo[playerid][aAmmo][i]=WA_VAR[1];
		}
	}
	#if defined MODE_DELAY_SEND_STATS
	if(CheatPlayerInfo[playerid][aAntiHealthHack]==1 && IsPassTime(CheatPlayerInfo[playerid][aGiveHealthTime],IsTime) && IsPassTime(CheatPlayerInfo[playerid][aGiveMoneyTime],IsTime))
	#else
	if(CheatPlayerInfo[playerid][aAntiHealthHack]==1)
	#endif
	{
		new Float:elc_health;
		GetPlayerHealth(playerid,elc_health);
		if(elc_health!=CheatPlayerInfo[playerid][aHealth])
		{
			if(elc_health<=100 && CheatPlayerInfo[playerid][aHealth]==0) CheatPlayerInfo[playerid][aHealth]=elc_health;
			else if(elc_health>CheatPlayerInfo[playerid][aHealth])
			{
			    //Cheat Health
			    initial_SetPlayerHealth(playerid,CheatPlayerInfo[playerid][aHealth]);
			    CallRemoteFunction("OnPlayerCheat", "dd", playerid,7);
			}
			else CheatPlayerInfo[playerid][aHealth]=elc_health;
		}
	}
	#if defined MODE_DELAY_SEND_STATS
	if(CheatPlayerInfo[playerid][aAntiArmourHack]==1 && IsPassTime(CheatPlayerInfo[playerid][aGiveArmourTime],IsTime) && IsPassTime(CheatPlayerInfo[playerid][aGiveMoneyTime],IsTime))
	#else
	if(CheatPlayerInfo[playerid][aAntiArmourHack]==1)
	#endif
	{
		new Float:elc_armour;
		GetPlayerArmour(playerid,elc_armour);
		if(elc_armour!=CheatPlayerInfo[playerid][aArmour])
		{
			if(elc_armour>CheatPlayerInfo[playerid][aArmour])
			{
			    //Cheat Armour
			    initial_SetPlayerArmour(playerid,CheatPlayerInfo[playerid][aArmour]);
			    CallRemoteFunction("OnPlayerCheat", "dd", playerid,8);
			}
			else CheatPlayerInfo[playerid][aArmour]=elc_armour;
		}
	}
	return 1;
}
/*----------------------------------------------------------------------------*/
stock ELC_AC_StartCheckPlayerFaceWall(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(CheatPlayerInfo[playerid][aAntiAmmoBlockHack]==1)CheatPlayerInfo[playerid][aAntiAmmoBlockHack]=2;
		new Float:x,Float:y,Float:z,Float:a,Float:lx,Float:ly,Float:lhealth;
		GetPlayerPos(playerid, x, y ,z);
		GetPlayerFacingAngle(playerid, a);
		GetPlayerHealth(playerid,lhealth);
		lx = (0.5 * floatsin(-a, degrees));
		ly = (0.5 * floatcos(-a, degrees));
		SetPlayerVelocity(playerid,lx,ly,0.0);
		SetTimerEx("OnPlayerCheckFaceWall",500,0,"iffffff",playerid,x+lx,y+ly,z,x,y,lhealth);
	}
	return 1;
}
/*----------------------------------------------------------------------------*/
public OnPlayerCheckFaceWall(playerid,Float:wall_x,Float:wall_y,Float:wall_z,Float:nwall_x,Float:nwall_y,Float:wall_he)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid, x, y ,z);
		if(IsPlayerInRangeOfPoint(playerid,0.25,wall_x,wall_y,z))
		{
		    //Cheat Block Ammo
			CallRemoteFunction("OnPlayerCheat", "dd", playerid,4);
			initial_ResetPlayerWeapons(playerid);
		}
		SetPlayerHealth(playerid,wall_he);
		initial_SetPlayerPos(playerid, nwall_x,nwall_y,wall_z);
		if(CheatPlayerInfo[playerid][aAntiAmmoBlockHack]==2)CheatPlayerInfo[playerid][aAntiAmmoBlockHack]=1;
	}
	return 1;
}
/*----------------------------------------------------------------------------*/
public ELC_AC_OnPlayerBuy(playerid,buyprice)
{
	if(buyprice==1)
	{
		new Float:elc_health;
		GetPlayerHealth(playerid,elc_health);
		if(elc_health<=CheatPlayerInfo[playerid][aHealth]+35) CheatPlayerInfo[playerid][aGainHealth]+=35;//Buy Soda
	}
	return 1;
}
/*----------------------------------------------------------------------------*/
public OnPlayerUpdate(playerid)
{
	new elc_getmoney=initial_GetPlayerMoney(playerid);
	new Float:elc_health; GetPlayerHealth(playerid,elc_health);
	#if defined MODE_DELAY_SEND_STATS
	if(CheatPlayerInfo[playerid][aMoney] > elc_getmoney && CheatPlayerInfo[playerid][aAntiMoneyHack]!=2 && IsPassTime(CheatPlayerInfo[playerid][aGiveMoneyTime],GetTickCount()))
	#else
	if(CheatPlayerInfo[playerid][aMoney] > elc_getmoney && CheatPlayerInfo[playerid][aAntiMoneyHack]!=2)
	#endif
	{
		//printf("ARGENTV : %d,ARGENT : %d,TIME : %d",CheatPlayerInfo[playerid][aMoney],elc_getmoney,GetTickCount());
		ELC_AC_OnPlayerBuy(playerid,CheatPlayerInfo[playerid][aMoney]-elc_getmoney);
		if(elc_health!=CheatPlayerInfo[playerid][aHealth])
		{
		    if(CheatPlayerInfo[playerid][aGainHealth]+CheatPlayerInfo[playerid][aHealth]>=elc_health && elc_health<=MAX_HEALTH)
		    {
		        CheatPlayerInfo[playerid][aGainHealth]=0;
		        CheatPlayerInfo[playerid][aHealth]=elc_health;
		    }
		    else initial_SetPlayerHealth(playerid,CheatPlayerInfo[playerid][aHealth]);
		}
	    CheatPlayerInfo[playerid][aMoney]=elc_getmoney;

	}
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnPlayerUpdate", "i",playerid);
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate ELC_AC_OnPlayerUpdate
forward ELC_AC_OnPlayerUpdate(playerid);
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
public OnGameModeInit()
#else
public OnFilterScriptInit()
#endif
{
    #if defined NO_TICK_COUNT
	CheatServerInfo[TimerTick]=SetTimer("TimeUpdate", TIME_GRANULITY, true);
	#endif
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnGameModeInit", "");
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit ELC_AC_OnGameModeInit
forward ELC_AC_OnGameModeInit();
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
public OnGameModeExit()
#else
public OnFilterScriptExit()
#endif
{
	#if defined NO_TICK_COUNT
	KillTimer(CheatServerInfo[TimerTick]);
	#endif
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnGameModeExit", "");
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit ELC_AC_OnGameModeExit
forward ELC_AC_OnGameModeExit();
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
public OnPlayerConnect(playerid)
{
	if (!IsPlayerNPC(playerid))
	{
		CheatPlayerInfo[playerid][aTickFire]=0;
		CheatPlayerInfo[playerid][aAmmoFire]=0;
		CheatPlayerInfo[playerid][aWeaponFire]=0;
		for(new i = 0; i <12; i++)
		{
			CheatPlayerInfo[playerid][aWeapon][i]=0;
			CheatPlayerInfo[playerid][aAmmo][i]=0;
		}
		CheatPlayerInfo[playerid][aMoney] = 0;
		CheatPlayerInfo[playerid][aArmour]=100;
		CheatPlayerInfo[playerid][aHealth]=100;
		CheatPlayerInfo[playerid][aGainHealth]=0;
		CheatPlayerInfo[playerid][aTimer]=SetTimerEx("OnPlayerCheckCheat", TIMER_CHEAT_RATE, 1, "i", playerid);
		CheatPlayerInfo[playerid][aX] = 0; CheatPlayerInfo[playerid][aY] = 0; CheatPlayerInfo[playerid][aZ] = 0;
		CheatPlayerInfo[playerid][aSpawnPlayer]=1;
		CheatPlayerInfo[playerid][aAntiTeleportHack]=0;
		CheatPlayerInfo[playerid][aAntiWeaponHack]=ANTI_WEAPON_&_AMMO_HACK;
		CheatPlayerInfo[playerid][aAntiAmmoBlockHack]=ANTI_AMMO_BLOCK_HACK;
		CheatPlayerInfo[playerid][aAntiMoneyHack]=ANTI_MONEY_HACK;
		CheatPlayerInfo[playerid][aAntiSpeedHack]=0;
		CheatPlayerInfo[playerid][aAntiArmourHack]=ANTI_ARMOUR_HACK;
		CheatPlayerInfo[playerid][aAntiHealthHack]=ANTI_HEALTH_HACK;
		SendClientMessage(playerid,0xBD0000FF,"[ANTI-CHEAT]Ce serveur est protégé par ELC_AC(By Eloctro)");
	}
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnPlayerConnect", "d", playerid);
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect ELC_AC_OnPlayerConnect
forward ELC_AC_OnPlayerConnect(playerid);
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
public OnPlayerSpawn(playerid)
{
	if (!IsPlayerNPC(playerid))
	{
	    CheatPlayerInfo[playerid][aSpawnPlayer]=1;
		SaveTime(CheatPlayerInfo[playerid][aSetPositionTime],GetTickCount());
		if(CheatPlayerInfo[playerid][aAntiSpeedHack]!=2)
		{
			CheatPlayerInfo[playerid][aAntiTeleportHack]=ANTI_TELEPORT/AIBREAK_HACK;
			CheatPlayerInfo[playerid][aAntiSpeedHack]=ANTI_SPEED_HACK;
		}
		CheatPlayerInfo[playerid][aHealth]=100;
		CheatPlayerInfo[playerid][aArmour]=100;
	}
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnPlayerSpawn", "d", playerid);
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnPlayerSpawn
	#undef OnPlayerSpawn
#else
	#define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn ELC_AC_OnPlayerSpawn
forward ELC_AC_OnPlayerSpawn(playerid);
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
public OnPlayerDeath(playerid, killerid, reason)
{
	if (!IsPlayerNPC(playerid))
	{
		CheatPlayerInfo[playerid][aAntiTeleportHack]=0;
		CheatPlayerInfo[playerid][aAntiSpeedHack]=0;
	}
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnPlayerDeath", "ddd", playerid, killerid, reason);
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnPlayerDeath
	#undef OnPlayerDeath
#else
	#define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath ELC_AC_OnPlayerDeath
forward ELC_AC_OnPlayerDeath(playerid, killerid, reason);
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
public OnPlayerDisconnect(playerid, reason)
{
	CheatPlayerInfo[playerid][aAntiTeleportHack]=0;
	CheatPlayerInfo[playerid][aAntiWeaponHack]=0;
	CheatPlayerInfo[playerid][aAntiAmmoBlockHack]=0;
	CheatPlayerInfo[playerid][aAntiMoneyHack]=0;
	CheatPlayerInfo[playerid][aAntiSpeedHack]=0;
	CheatPlayerInfo[playerid][aAntiArmourHack]=0;
	CheatPlayerInfo[playerid][aAntiHealthHack]=0;
	if (!IsPlayerNPC(playerid))
	{
		KillTimer(CheatPlayerInfo[playerid][aTimer]);
		CheatPlayerInfo[playerid][aTickFire]=0;
		CheatPlayerInfo[playerid][aAmmoFire]=0;
		CheatPlayerInfo[playerid][aWeaponFire]=0;
	}
	CheatPlayerInfo[playerid][aX] = 0; CheatPlayerInfo[playerid][aY] = 0; CheatPlayerInfo[playerid][aZ] = 0;
	CheatPlayerInfo[playerid][aArmour]=0;
	CheatPlayerInfo[playerid][aHealth]=0;
	CheatPlayerInfo[playerid][aGainHealth]=0;
	CheatPlayerInfo[playerid][aSpawnPlayer]=0;
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnPlayerDisconnect", "dd", playerid, reason);
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect ELC_AC_OnPlayerDisconnect
forward ELC_AC_OnPlayerDisconnect(playerid, reason);
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid))
	{
		if(CheatPlayerInfo[playerid][aAntiWeaponHack]==1 && CheatPlayerInfo[playerid][aAntiAmmoBlockHack]==1)
		{
			if(newkeys==4)
			{
				new Float:XPOS[3]; GetPlayerPos(playerid,XPOS[0],XPOS[1],XPOS[2]);
				if(CheatPlayerInfo[playerid][aTickFire]==0 && IsNotWeaponVise(GetPlayerWeapon(playerid)) && CheatPlayerInfo[playerid][aZ]==XPOS[2])
				{
					CheatPlayerInfo[playerid][aTickFire]=GetTickCount();
					CheatPlayerInfo[playerid][aAmmoFire]=GetPlayerAmmo(playerid);
					CheatPlayerInfo[playerid][aWeaponFire]=GetPlayerWeapon(playerid);
				}
			}
			else if(newkeys==132)
			{
				if(CheatPlayerInfo[playerid][aTickFire]==0 && IsNotWeaponNoAmmo(GetPlayerWeapon(playerid)) && (GetPlayerSpeedXY(playerid) < 1))
				{
					CheatPlayerInfo[playerid][aTickFire]=GetTickCount();
					CheatPlayerInfo[playerid][aAmmoFire]=GetPlayerAmmo(playerid);
					CheatPlayerInfo[playerid][aWeaponFire]=GetPlayerWeapon(playerid);
				}
			}
			else if(oldkeys==4&&newkeys!=132 || oldkeys==132&&newkeys!=4)
			{
                if(CheatPlayerInfo[playerid][aTickFire]!=0)
                {
                    if((GetTickCount()-CheatPlayerInfo[playerid][aTickFire]) >= TIRE_RATE)
					{
						new Float:XPOS[3];
			            GetPlayerPos(playerid,XPOS[0],XPOS[1],XPOS[2]);
						if(CheatPlayerInfo[playerid][aZ]==XPOS[2] && CheatPlayerInfo[playerid][aWeaponFire]==GetPlayerWeapon(playerid)&& CheatPlayerInfo[playerid][aAmmoFire]==GetPlayerAmmo(playerid)) ELC_AC_StartCheckPlayerFaceWall(playerid);
					}
					CheatPlayerInfo[playerid][aTickFire]=0;
					CheatPlayerInfo[playerid][aAmmoFire]=0;
					CheatPlayerInfo[playerid][aWeaponFire]=0;
                }
			}
		}
	}
	#if defined INCLUDE_BASE_MODE
	return CallLocalFunction("ELC_AC_OnPlayerKeyStateChange", "ddd",playerid, newkeys, oldkeys);
	#else
	return 1;
	#endif
}
/*----------------------------------------------------------------------------*/
#if defined INCLUDE_BASE_MODE
//ALS_SYSTEME --------------------
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange ELC_AC_OnPlayerKeyStateChange
forward ELC_AC_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif
//ALS_OFF_SYSTEME ----------------
/*----------------------------------------------------------------------------*/
public ELC_AC_EnablePlayerCheatID(playerid,cheatid,enable)
{
	if(cheatid==1)//Money
	{
		if(enable==1)
		{
			CheatPlayerInfo[playerid][aAntiMoneyHack]=1;
		}
		else CheatPlayerInfo[playerid][aAntiMoneyHack]=0;
	}
	else if(cheatid==2)//Weapon
	{
		if(enable==1)
		{
			for(new i = 0; i <12; i++)
			{
				GetPlayerWeaponData(playerid,i,CheatPlayerInfo[playerid][aWeapon][i],CheatPlayerInfo[playerid][aAmmo][i]);
			}
			CheatPlayerInfo[playerid][aAntiWeaponHack]=1;
		}
		else CheatPlayerInfo[playerid][aAntiWeaponHack]=0;
	}
	else if(cheatid==3)//AirBreak/SpeedHack
	{
		if(enable==1) CheatPlayerInfo[playerid][aAntiSpeedHack]=1;
		else CheatPlayerInfo[playerid][aAntiSpeedHack]=0;
	}
	else if(cheatid==4)//Anti-Teleport
	{
		if(enable==1)
		{
			GetPlayerPos(playerid,CheatPlayerInfo[playerid][aX],CheatPlayerInfo[playerid][aY],CheatPlayerInfo[playerid][aZ]);
			CheatPlayerInfo[playerid][aAntiTeleportHack]=1;
		}
		else CheatPlayerInfo[playerid][aAntiTeleportHack]=0;
	}
	else if(cheatid==5)//Anti-Ammo_Block
	{
		if(enable==1)
		{
			CheatPlayerInfo[playerid][aTickFire]=0;
			CheatPlayerInfo[playerid][aAmmoFire]=0;
			CheatPlayerInfo[playerid][aWeaponFire]=0;
			CheatPlayerInfo[playerid][aAntiAmmoBlockHack]=1;
		}
		else CheatPlayerInfo[playerid][aAntiAmmoBlockHack]=0;
	}
	else if(cheatid==6)//Anti_HEALTH_HACK
	{
		if(enable==1)
		{
			CheatPlayerInfo[playerid][aAntiHealthHack]=1;
		}
		else CheatPlayerInfo[playerid][aAntiHealthHack]=0;
	}
	else if(cheatid==7)//Anti_ARMOUR_HACK
	{
		if(enable==1)
		{
			CheatPlayerInfo[playerid][aAntiArmourHack]=1;
		}
		else CheatPlayerInfo[playerid][aAntiArmourHack]=0;
	}
	return 1;
}
/*----------------------------------------------------------------------------*/
#define EnablePlayerCheatID ELC_AC_EnablePlayerCheatID
/*----------------------------------------------------------------------------*/

