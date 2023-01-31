/*
  ___ __  ____      _____      ______                _   _
 |  _|  \/  \ \    / /_  |    |  ____|              | | (_)
 | | | \  / |\ \  / /  | |    | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
 | | | |\/| | \ \/ /   | |    |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
 | | | |  | |  \  /    | |    | |  | |_| | | | | (__| |_| | (_) | | | \__ \
 | |_|_|  |_|   \/    _| |    |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
 |___|               |___|______
                         |______|
                         
Free to use on the following conditions:

	*Do not re-release edited versions without my permision
	*Do not and NEVER clame this as your own, not even an edit!
	*Say thanks on the sa-mp forums if you like ;)
	*Give me rep on the sa-mp forums if you think this is very useful.
	
----------------CREDITS:--------------------------------------------------------
- GetPlayersInVehicle(vehicleid);//by Tr1viUm
- UnCagePlayer(playerid);//by Yaheli_Faro
- CagePlayer(playerid);//by Yaheli_Faro
- RangeBan(playerid)//by Zezombia
- DeletePlayerWeapon(playerid, weaponid) //by RyDeR`
- GetSecondsBetweenAction(action) // By [03]Garsino
- Wesley !!! For +/- 5 stocks
- System64, Fixing dumb mistaces.
----------------UPDATES:--------------------------------------------------------
- Edited Clear(All)Chat(playerid)
- Edited CountTotalPlayers()
- Added ShowMessageDialog(playerid, caption[], info[])
----------------NATIVES:--------------------------------------------------------
native UnfreezePlayer(playerid);
native FreezePlayer(playerid);
native RemoveCranesForPlayer(playerid);
native RemoveSodaMachinesForPlayer(playerid);
native SetServerPassword(const password[]);
native strset(string[], input[]);
native SetPlayerPosEx(playerid, Float:x, Float:y, Float:z, Float:a);
native IsInvalidSkin(skinid);
native ShowMarkers( playerid, toggle );
native IsValidNosVehicle(vehicleid);
native GetXYInFrontOfPlayer(playerid, &Float:x2, &Float:y2, Float:distance);
native SendClientMessageToRconAdmin(msg[]);
native bool:IsValidNumber( const string[ ] );
native IsPlayerVehicleModded(playerid, vehicleid);
native DefaultGravity();
native GetSecondsBetweenAction(action);
native IsCharLower(c);
native IsCharUpper(c);
native IsPlayerOnFoot(playerid);
native IsPlayerOnAnyBike(playerid);
native IsPlayerOnAnyBoat(playerid);
native IsPlayerInAnyHelicopter(playerid);
native IsPlayerInAnyPlane(playerid);
native DeletePlayerWeapon(playerid, weaponid);
native KelvinToCelsius(value);
native CelsiusToKelvin(value);
native FahrenheitToCelsius(value);
native CelsiusToFahrenheit(value);
native RangeBan(playerid);
native ClearChatForAll();
native ClearChat(playerid);
native TeleportPlayerToPlayer(playerid1,playerid2);
native IsABicycle(carid);
native GetName(i);
native IsPlayerInZone(playerid, Float:minX, Float:minY, Float:maxX, Float:maxY);
native IsPlayerInWater(playerid);
native UnJailPlayer(playerid);
native JailPlayer(playerid);
native GetClosestVehicleFromPoint(Float:x,Float:y);
native PutPlayerInNearestVehicle(playerid, seatid);
native StopVehicle(vehicleid);
native GetVehicleType(vehicleid);
native AlarmStop(vehicleid);
native FlipVehicle(vehicleid);
native ExplodeVehicle(vehicleid);
native ToggleVehicleObjective(vehicleid, estate);
native ToggleVehicleEngine(vehicleid, estate);
native ToggleVehicleEngine(vehicleid, estate);
native IsPlayerPaused(playerid);
native ToggleVehicleLight(vehicleid, estate);
native ToggleVehicleTrunk(vehicleid, estate);
native GetDeathReason(killerid, reason);
native GetDisconnectReason(reason);
native FreezeVehicleEx(vehid,Float:X,Float:Y,Float:Z,Float:A);
native FreezeVehicle(vehid,time);
native GivePlayerVehicle(playerid, vehicleid);
native GetPlayersInVehicle(vehicleid);
native UnCagePlayer(playerid);
native CagePlayer(playerid);
native SaveInFile(filename[],text[]);
native GetVehicleSpeed(vehicleid);
native GetPlayerSpeed(playerid);
native LockVehicle(vehicleid);
native UnlockVehicle(vehicleid);
native ToggleVehicleBonnet(vehicleid, estate);
native SetVehicleToAlarm(vehicleid,time);
native IsVehicleAlarmOn(vehicleid);
native ToggleVehicleAlarm(vehicleid,toggle);
native AreVehicleLightsOn(vehicleid);
native ToggleVehicleLights(vehicleid,toggle);
native SetVehicleNumberPlateEx(vehicleid,numberplate[]);
native GetWeaponNameById(weaponid);
native GetVehicleNameByModelId(vehiclemodel);
native GetWeaponIdByName(weaponname[]);
native GetVehicleModelIdByName(vehiclename[]);
native Crash(playerid);
native ReturnPlayerIDFromIP(ip[]);
native KickAllPlayers();
native KickNPCs();
native CountTotalPlayers();
native CountTotalRCONAdmins();
native CountTotalNPC();
native Float:GetVehicleAngle(vehicleid);
native Float:GetVehicleHealthEx(vehicleid);
native Float:GetPlayerAngle(playerid);
native Float:GetPlayerArmourEx(playerid);
native Float:GetPlayerHealthEx(playerid);
native GetPlayerIpEx(playerid);
native ShowMessageDialog(playerid, caption[], info[]);
----------------CALLBACKS:------------------------------------------------------
- OnPlayerUnPause(playerid)
- OnPlayerPause(playerid)
*/



#include <a_samp>
#include <YSI/y_hooks>
#include <foreach>

#define TIME_PAUSED 1000 //if he esced for 1 second...

#define IsOdd(%0)  ((%0)&1)
#define IsEven(%0) (!IsOdd(%0))
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))


#define COLOR_INVISIBLE 0xFFFFFF00
#define COLOR_BLACK 0x000000FF
#define COLOR_RED 0xAA3333AA
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_YELLOWORANGE 0xE8D600FF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_ORANGE 0xFF5F11FF
#define COLOR_BROWN 0x804000FF
#define COLOR_CYAN 0x00FFFFFF
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_PINK 0xFF80C0FF

forward C_Paused(playerid);
forward OnPlayerPause(playerid);
forward OnPlayerUnPause(playerid);

new Paused[MAX_PLAYERS];
new Timer[MAX_PLAYERS];
new bool:Requesting[MAX_PLAYERS];
new bool:IsPaused[MAX_PLAYERS];

new VehicleNames[212][] = {
"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel",
"Dumper", "Firetruck" , "Trashmaster" , "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
"Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection",
"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
"Reefer", "Tropic", "Flatbed","Yankee", "Caddy", "Solair","Berkley's RC Van",
"Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron","RC Raider","Glendale",
"Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
"Burrito", "Camper", "Marquis", "Baggage", "Dozer","Maverick","News Chopper",
"Rancher", "FBI Rancher", "Virgo", "Greenwood","Jetmax","Hotring","Sandking",
"Blista Compact", "Police Maverick", "Boxville", "Benson","Mesa","RC Goblin",
"Hotring Racer", "Hotring Racer", "Bloodring Banger", "Rancher", "Super GT",
"Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropdust", "Stunt",
"Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
"FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona",
"FBI Truck", "Willard", "Forklift","Tractor","Combine","Feltzer","Remington",
"Slamvan", "Blade", "Freight", "Streak","Vortex","Vincent","Bullet","Clover",
"Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa",
"Sunrise", "Merit", "Utility Truck", "Nevada", "Yosemite", "Windsor", "Monster",
"Monster","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RCTiger",
"Flash","Tahoma","Savanna", "Bandito", "Freight", "Trailer", "Kart", "Mower",
"Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley",
"Stafford", "BF-400", "Newsvan","Tug","Trailer","Emperor","Wayfarer","Euros",
"Hotdog", "Club", "Trailer", "Trailer","Andromada","Dodo","RC Cam", "Launch",
"Police Car LSPD", "Police Car SFPD","Police Car LVPD","Police Ranger",
"Picador", "S.W.A.T. Van", "Alpha", "Phoenix", "Glendale", "Sadler",
"Luggage Trailer","Luggage Trailer","Stair Trailer", "Boxville", "Farm Plow",
"Utility Trailer"
};

#pragma tabsize 0

Hook:P_OnPlayerConnect(playerid)
{
    IsPaused[playerid] = false;
    Requesting[playerid] = false;
    Timer[playerid] = SetTimerEx("C_Paused", 754, 1, "i", playerid);
    return 1;
}

Hook:P_OnPlayerUpdate(playerid)
{
    Paused[playerid] = GetTickCount();
    return 1;
}

Hook:P_OnPlayerRequestClass(playerid)
{
    Requesting[playerid] = true;
	IsPaused[playerid] = false;
    return 1;
}

Hook:P_OnPlayerDisconnect(playerid)
{
    KillTimer(Timer[playerid]);
    Requesting[playerid] = false;
    IsPaused[playerid] = false;
    return 1;
}

Hook:P_OnPlayerSpawn(playerid)
{
	Requesting[playerid] = false;
    IsPaused[playerid] = false;
    return 1;
}

public C_Paused(playerid)
{
    	if(GetTickCount()-Paused[playerid] > TIME_PAUSED && Requesting[playerid] != true && IsPaused[playerid] != true && InvalidStates(playerid) != 1)
        {
        	OnPlayerPause(playerid);
            IsPaused[playerid] = true;
        }
        else if(GetTickCount()-Paused[playerid] < TIME_PAUSED && Requesting[playerid] != true && IsPaused[playerid] != false && InvalidStates(playerid) != 1)
        {
            OnPlayerUnPause(playerid);
            IsPaused[playerid] = false;
        }
        return 1;
}

stock IsPlayerPaused(playerid)
{
        return IsPaused[playerid];
}

stock InvalidStates(playerid)
{
        new pState = GetPlayerState(playerid);
	    if(pState == 0 || pState == 7) return 1; else  return 0;
}

stock UnlockVehicle(vehicleid) {
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);
    return 1;
}

stock LockVehicle(vehicleid) {
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, VEHICLE_PARAMS_ON, bonnet, boot, objective);
    return 1;
}

stock ShowMessageDialog(playerid, caption[], info[]) // Shows a static dialog to the player.
{
    ShowPlayerDialog(playerid, STATIC_DIALOG, DIALOG_STYLE_MSGBOX, caption, info, "OK", "");
}

stock GetPlayerSpeed(playerid)
{
    new Float:ST[4];
    if(IsPlayerInAnyVehicle(playerid))
    GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);
    else GetPlayerVelocity(playerid,ST[0],ST[1],ST[2]);
    ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 179.28625;
    return floatround(ST[3]);
}

stock GetVehicleSpeed(vehicleid)
{
	new Float:MV[4];
	GetVehicleVelocity(vehicleid, MV[0], MV[1], MV[2]);
	MV[3] = floatsqroot((MV[0] * MV[0]) + (MV[1] * [1]) + (MV[2] * MV[2]));
	return float_round(MV[3], floatround_round);
}

stock SaveInFile(filename[],text[])
{
    new File:Lfile;
    new filepath[ 256 ];
    new string[ 256 ];
    new year,month,day,hour,minutes,seconds;
    getdate(year, month, day); gettime(hour, minutes, seconds);
    format(filepath,sizeof(filepath),"%s",filename);
    Lfile = fopen(filepath,io_append);
    format(string,sizeof(string),"[%02d/%02d/%02d - %02d:%02d:%02d] %s\r\n",day,month,year,hour,minutes,seconds,text);
    fwrite(Lfile,string);
    fclose(Lfile);
    return 1;
}

stock CagePlayer(playerid)//by Yaheli_Faro
{
      if(IsPlayerConnected(playerid))
      {
        if(caged[playerid] == 0)
        {
	      new Float:X, Float:Y, Float:Z;
	      GetPlayerPos(playerid, X, Y, Z);
	      cage[playerid] = CreateObject(985, X, Y+4, Z, 0.0, 0.0, 0.0);
	      cage2[playerid] = CreateObject(985, X+4, Y, Z, 0.0, 0.0, 90.0);
	      cage3[playerid] = CreateObject(985, X-4, Y, Z, 0.0, 0.0, 270.0);
	      cage4[playerid] = CreateObject(985, X, Y-4, Z, 0.0, 0.0, 180.0);
	      caged[playerid] = 1;
	      PlayerPlaySound(playerid, 1137, X, Y, Z);
        }
        else SendClientMessage(playerid, COLOR_RED,"You can not cage him twice !");
      }
}

stock UnCagePlayer(playerid)//by Yaheli_Faro
{
      cage[playerid] = DestroyObject(cage[playerid]);
      cage2[playerid] = DestroyObject(cage2[playerid]);
      cage3[playerid] = DestroyObject(cage3[playerid]);
      cage4[playerid] = DestroyObject(cage4[playerid]);
      caged[playerid] = 0;
}

stock GetPlayersInVehicle(vehicleid)//by Tr1viUm
{
  new amount = 0;
  for(new i = 0; i < GetMaxPlayers(); i++)
  {
    if(!IsPlayerConnected(i) || !IsPlayerInVehicle(i,vehicleid))
      continue;
    amount++;
  }
  return amount;
}

stock GivePlayerVehicle(playerid, vehicleid)
{
    if(!IsPlayerInAnyVehicle(playerid) && vehicleid > 399 && vehicleid < 612)
    {
        new Float:x, Float:y, Float:z, Float:a, vehicle;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        vehicle = CreateVehicle(vehicleid, x, y, z, a, -1, -1, 50000);
        PutPlayerInVehicle(playerid, vehicle, 0);
    }
}

stock FreezeVehicle(vehid,time)
{
        if(time>0)
        {
                new Float:Pos[4];
                GetVehiclePos(vehid,Pos[0],Pos[1],Pos[2]);
                GetVehicleZAngle(vehid,Pos[3]);
                _FreezeSteps[vehid][0]=(time*1000)/500;
                _FreezeSteps[vehid][1]=1;
                _FreezeTimer[vehid]=SetTimerEx("FreezeVehicleEx",500,true,"dffff",vehid,Pos[0],Pos[1],Pos[2],Pos[3]);
                return true;
        }
        return printf("Function Error: Unknown Time used (%d) in FreezeVehicle!",time);
}

stock FreezeVehicleEx(vehid,Float:X,Float:Y,Float:Z,Float:A)
{
        new Float:Pos[4];
        GetVehiclePos(vehid,Pos[0],Pos[1],Pos[2]);
        GetVehicleZAngle(vehid,Pos[3]);
        if(Pos[0]!=X||Pos[1]!=Y||Pos[2]!=Z)SetVehiclePos(vehid,X,Y,Z);
        if(Pos[3]!=A)SetVehicleZAngle(vehid,A);
        _FreezeSteps[vehid][1]++;
        if(_FreezeSteps[vehid][1]>=_FreezeSteps[vehid][0])KillTimer(_FreezeTimer[vehid]);
        return true;
}

stock GetDisconnectReason(reason)
{
	new ReasonMsg[8];
	switch(reason)
	{
		case 0: ReasonMsg = "Timeout";
		case 1: ReasonMsg = "Quit";
		case 2: ReasonMsg = "Kicked";
	}
	return ReasonMsg;
}

stock GetDeathReason(killerid, reason)
{
	new Message[32];
	if(killerid != INVALID_PLAYER_ID)
	{
		switch(reason)
		{
			case 0: Message = "Unarmed";
			case 1: Message = "Brass Knuckles";
			case 2: Message = "Golf Club";
			case 3: Message = "Night Stick";
			case 4: Message = "Knife";
			case 5: Message = "Baseball Bat";
			case 6: Message = "Shovel";
			case 7: Message = "Pool Cue";
			case 8: Message = "Katana";
			case 9: Message = "Chainsaw";
			case 10: Message = "Dildo";
			case 11: Message = "Dildo";
			case 12: Message = "Vibrator";
			case 13: Message = "Vibrator";
			case 14: Message = "Flowers";
			case 15: Message = "Cane";
			case 22: Message = "Pistol";
			case 23: Message = "Silenced Pistol";
			case 24: Message = "Desert Eagle";
			case 25: Message = "Shotgun";
			case 26: Message = "Sawn-off Shotgun";
			case 27: Message = "Combat Shotgun";
			case 28: Message = "MAC-10";
			case 29: Message = "MP5";
			case 30: Message = "AK-47";
			case 31:
			{
				if(GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch(GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 447: Message = "Sea Sparrow Machine Gun";
						default: Message = "M4";
					}
				}
				else
				{
					Message = "M4";
				}
			}
			case 32: Message = "TEC-9";
			case 33: Message = "Rifle";
			case 34: Message = "Sniper Rifle";
			case 37: Message = "Fire";
			case 38:
			{
				if(GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch(GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 425: Message = "Hunter Machine Gun";
						default: Message = "Minigun";
					}
				}
				else
				{
					Message = "Minigun";
				}
			}
			case 41: Message = "Spraycan";
			case 42: Message = "Fire Extinguisher";
			case 49: Message = "Vehicle Collision";
			case 50:
			{
				if(GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch(GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 417, 425, 447, 465, 469, 487, 488, 497, 501, 548, 563: Message = "Helicopter Blades";
						default: Message = "Vehicle Collision";
					}
				}
				else Message = "Vehicle Collision";
			}
			case 51:
			{
				if(GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch(GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 425: Message = "Hunter Rockets";
						case 432: Message = "Rhino Turret";
						case 520: Message = "Hydra Rockets";
						default: Message = "Explosion";
					}
				}
				else
				{
					Message = "Explosion";
				}
			}
			default: Message = "Unknown";
		}
	}
	if(killerid == INVALID_PLAYER_ID)
	{
		switch (reason)
		{
			case 53: Message = "Drowned";
			case 54: Message = "Collision";
			default: Message = "Died";
		}
	}
	return Message;
}

stock GetPlayerIpEx(playerid)
{
    new pIP[16];
    GetPlayerIp(playerid, pIP, 16);
    return pIP;
}

stock Float:GetPlayerHealthEx(playerid)
{
    new Float:health;
    GetPlayerHealth(playerid, health);
    return health;
}

stock Float:GetPlayerArmourEx(playerid)
{
    new Float:armour;
    GetPlayerHealth(playerid, armour);
    return armour;
}

stock Float:GetPlayerAngle(playerid)
{
    new Float:angle;
    GetPlayerFacingAngle(playerid, angle);
    return angle;
}

stock Float:GetVehicleHealthEx(vehicleid)
{
    new Float:health;
    GetVehicleHealth(vehicleid, health);
    return health;
}

stock Float:GetVehicleAngle(vehicleid)
{
    new Float:angle;
    GetVehicleZAngle(vehicleid, angle);
    return angle;
}

stock CountTotalNPC()
{
	new count;
	foreach(Player,i) if(IsPlayerNPC(i)) count++;
	return count;
}

stock CountTotalRCONAdmins()
{
	new count;
	foreach(Player,i) if(IsPlayerAdmin(i)) count++;
	return count;
}

stock CountTotalPlayers()
{
	return Iter_Count(Players);
}

stock KickNPCs()
{
	foreach(Player,i) if(IsPlayerNPC(i)) Kick(i);
	return 1;
}


stock KickAllPlayers()
{
	foreach(Player,i) if(IsPlayerConnected(i))  Kick(i);
	return 1;
}

stock ReturnPlayerIDFromIP(ip[])
{
	foreach(Player,i) if(!strcmp(GetPlayerIpEx(i), ip, true)) return i;
	return INVALID_PLAYER_ID;
}

stock Crash(playerid)
{
    new Pos[3];
    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
    CreatePlayerObject(playerid, 385, Pos[0], Pos[1], Pos[2], 0, 0, 0);
}

stock GetVehicleModelIdByName(vehiclename[])
{
    for(new i = 0;i<sizeof(gVehicleNames);i++)
    {
        if(!strcmp(VehicleNames[i],vehiclename,true))
        {
            return i +400;
        }
    }
    return -1;
}

stock GetWeaponIdByName(weaponname[])
{
    for(new i = 0;i<sizeof(gWeaponNames);i++)
    {
        if(!strcmp(WeaponNames[i],weaponname,true))
        {
            return i;
        }
    }
    return -1;
}

stock GetVehicleNameByModelId(vehiclemodel)
{
	new str[32];format(str,sizeof str,"%s",VehicleNames[vehiclemodel -400]);return str;
}

stock GetWeaponNameById(weaponid)
{
	new str[32];format(str,sizeof str,"%s",WeaponNames[weaponid]);return str;
}

stock SetVehicleNumberPlateEx(vehicleid,numberplate[])
{
	new Float:pos[6];GetVehiclePos(vehicleid,pos[0],pos[1],pos[2]);
	SetVehicleNumberPlate(vehicleid,numberplate);SetVehicleToRespawn(vehicleid);
	GetVehiclePos(vehicleid,pos[3],pos[4],pos[5]);
	if(pos[3] != pos[0] || pos[4] != pos[1])
	{
	    SetVehiclePos(vehicleid,pos[0],pos[1],pos[2]);
	}
	return 1;
}

stock ToggleVehicleLights(vehicleid,toggle)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,toggle,alarm,doors,bonnet,boot,objective);
	return 1;
}

stock AreVehicleLightsOn(vehicleid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	return lights;
}

stock ToggleVehicleAlarm(vehicleid,toggle)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,lights,toggle,doors,bonnet,boot,objective);
	return 1;
}

stock IsVehicleAlarmOn(vehicleid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	return alarm;
}

stock SetVehicleToAlarm(vehicleid,time)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,lights,1,doors,bonnet,boot,objective);
	SetTimerEx("AlarmStop",time,false,"i",vehicleid);
	return 1;
}

stock ToggleVehicleBonnet(vehicleid, estate)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,estate,boot,objective);
	return 1;
}
stock ToggleVehicleTrunk(vehicleid, estate)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,estate,objective);
	return 1;
}
stock ToggleVehicleLight(vehicleid, estate)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,estate,alarm,doors,bonnet,boot,objective);
	return 1;
}
stock ToggleVehicleEngine(vehicleid, estate)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,estate,lights,alarm,doors,bonnet,boot,objective);
	return 1;
}

stock ToggleVehicleObjective(vehicleid, estate)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,estate);
	return 1;
}
stock ExplodeVehicle(vehicleid)
{
	new Float:MV_Coord[4];
	GetVehiclePos(vehicleid, MV_Coord[0], MV_Coord[1], MV_Coord[2]);
	GetVehicleZAngle(vehicleid, MV_Coord[3]);
	CreateExplosion(MV_Coord[0], MV_Coord[1], MV_Coord[2], 0, 5.00);
	MV_Coord[0] += 5.00 * floatsin(-MV_Coord[3], degree);
	MV_Coord[1] += 5.00 * floatcos(-MV_Coord[3], degree);
	CreateExplosion(MV_Coord[0], MV_Coord[1], MV_Coord[2], 0, 5.00);
	return 1;
}

stock FlipVehicle(vehicleid)
{
	new Float:a;
	GetVehicleZAngle(vehicleid, a);
	SetVehicleZAngle(vehicleid, a);
	return 1;
}

stock AlarmStop(vehicleid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid,engine,lights,0,doors,bonnet,boot,objective);
}

stock GetVehicleType(vehicleid)
{
	new model = GetVehicleModel(vehicleid);
	switch(model)
	{
	    case 520 , 577 , 511 , 592 , 512 , 513 , 519 , 593 , 553 , 476, 425, 447, 469, 548, 417:
	    {
	        return 2;
	    }
	    case 430, 446, 452, 453, 454, 472, 473, 484, 493, 495:
	    {
	        return 1; 
	    }
	    default:
	    {
	        return 0; 
	    }
	}
	return -1;
}

stock StopVehicle(vehicleid)
{
	SetVehicleVelocity(vehicleid, 0.0, 0.0, 0.0);
	return 1;
}
stock PutPlayerInNearestVehicle(playerid, seatid)
{
	PutPlayerInVehicle(playerid, GetPlayerNearestVehicle(playerid), seatid);
	return GetPlayerNearestVehicle(playerid);
}

stock GetClosestVehicleFromPoint(Float:x,Float:y)
{
	new Float:distance = 2222,Float:tx,Float:ty,Float:z,vehicleid = -1;
	for(new i = 0;i<MAX_VEHICLES;i++)
	{
	    GetVehiclePos(i,tx,ty,z);
		new Float:temp = GetDistanceBetweenPoints(x,y,tx,ty);
		if(temp < distance)
		{
			vehicleid = i;
			distance = temp;
		}
	}
	return vehicleid;
}

stock JailPlayer(playerid)
{
	SetPlayerInterior(playerid,6);SetPlayerPos(playerid, 265.6881,76.6573,1001.0391);TogglePlayerControllable(playerid,0);
	SetPlayerCameraPos(playerid,269.5,77.5,1002);return SetPlayerCameraLookAt(playerid,264.6288,77.5742,1001.0391);
}

stock UnJailPlayer(playerid)
{
    SetPlayerPos(playerid, 267.6288,77.5742,1001.0391);TogglePlayerControllable(playerid,1);return SetCameraBehindPlayer(playerid);
}

stock IsPlayerInWater(playerid)
{
   new Float:MV_wpos[3];
   GetPlayerPos(playerid,MV_wpos[0],MV_wpos[1],MV_wpos[2]);
   if((MV_wpos[2] > 0.00) || IsPlayerInZone(playerid,1808.2019,1424.5392,-2230.5024,-2347.7979)) { return 0; }
   else if((MV_wpos[2] < 0.00) && (MV_wpos[2] > -1.00)) { return 1; }
   else if(MV_wpos[2] < -1.00) { return 2; }
   return 0;
}


stock IsPlayerInZone(playerid, Float:minX, Float:minY, Float:maxX, Float:maxY)
{
	new Float:MV_ZoneX, Float:MV_ZoneY, Float:MV_ZoneZ;
	GetPlayerPos(playerid, MV_ZoneX, MV_ZoneY, MV_ZoneZ);
	if((MV_ZoneX >= minX && MV_ZoneX <= maxX) && (MV_ZoneY >= minY && MV_ZoneY <= maxY) && MV_ZoneZ <= 500) { return 1; }
	return 0;
}

stock IsABicycle(carid)
{
    if(GetVehicleModel(carid)==509||GetVehicleModel(carid)==510||GetVehicleModel(carid)==481) return 1;
    return 0;
}

stock TeleportPlayerToPlayer(playerid1,playerid2)
{
	new Float:x,Float:y,Float:z,interior;
	GetPlayerPos(playerid2,x,y,z);
	interior=GetPlayerInterior(playerid2);
	return SetPlayerVehiclePos(playerid1,x,y,z+3,GetPlayerAngle(playerid2),interior);
}

stock ClearChat(playerid)
{
    for(new i = 0; i < 20; i++) SendClientMessage(playerid, COLOR_GRAY, " ");
    return 1;
}

stock ClearChatForAll()
{
	for(new i = 0; i < 20; i++) SendClientMessageToAll(playerid,COLOR_GRAY," ");
}

stock RangeBan(playerid)//by Zezombia
{
    new pos, oldpos, ip[15], ip2[15], tmp[21];

    GetPlayerIp(playerid, ip, sizeof(ip));

    pos = strfind(ip, ".", true);
    pos++;

    for(new i = 0; i < pos; i++)
    {
        ip2[i] = ip[pos-pos+i];
    }

    pos--;

    ip[pos] = ' ';

    oldpos = pos;
    oldpos++;

    pos = strfind(ip, ".", true);
    pos++;

    for(new i = oldpos; i < pos; i++)
    {
        ip2[i] = ip[pos-pos+i];
    }

    format(ip2, sizeof(ip2), "%s*.*", ip2);
    format(tmp, sizeof(tmp), "banip %s", ip2);

    SendRconCommand(tmp);
    return ip2;
}

stock CelsiusToFahrenheit(value)
{
	new Fahrenheit;
	Fahrenheit = value + 32;
	return Fahrenheit;
}

stock FahrenheitToCelsius(value)
{
	new Celcius;
	Celcius = value - 32;
	return Celcius;
}

stock CelsiusToKelvin(value)
{
	new Kelvin;
	Kelvin = value + 273;
	return Kelvin;
}

stock KelvinToCelsius(value)
{
	new Celsius;
	Celsius = value - 273;
	return Celsius;
}

stock DeletePlayerWeapon(playerid, weaponid) //by RyDeR`
{
    new
        gWeaponData[13][2]
    ;

    for(new i; i != sizeof(gWeaponData); ++i)
    {
        GetPlayerWeaponData(playerid, i, gWeaponData[i][0], gWeaponData[i][1]);

        gWeaponData[i][1] = gWeaponData[i][1] < 0 ? -gWeaponData[i][1] : gWeaponData[i][1];
    }
    ResetPlayerWeapons(playerid);

    for(new i; i != sizeof(gWeaponData); ++i)
    {
        if(gWeaponData[i][0] != weaponid)
        {
            GivePlayerWeapon(playerid, gWeaponData[i][0], gWeaponData[i][1]);
        }
    }
    return 1;
}

stock IsPlayerInAnyPlane(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
    	new vehicle = GetVehicleModel(GetPlayerVehicleID(playerid));
        if(vehicle == 460 || vehicle == 476 || vehicle == 511 || vehicle == 512 || vehicle == 513 || vehicle == 519 || vehicle == 520 || vehicle == 553 || vehicle == 577 || vehicle == 592 || vehicle == 593)
		{
 			return 1;
	 	}
	 }
  	return 0;
}
stock IsPlayerInAnyHelicopter(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
    	new vehicle = GetVehicleModel(GetPlayerVehicleID(playerid));
        if(vehicle == 417 || vehicle == 425 || vehicle == 447 || vehicle == 469 || vehicle == 487 || vehicle == 488 || vehicle == 497 || vehicle == 548 || vehicle == 563)
		{
  			return 1;
  		}
  	}
    return 0;
}
stock IsPlayerOnAnyBoat(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
 		new vehicle = GetVehicleModel(GetPlayerVehicleID(playerid));
        if(vehicle == 430 || vehicle == 446 || vehicle == 452 || vehicle == 453 || vehicle == 454 || vehicle == 472 || vehicle == 473 || vehicle == 484 || vehicle == 493 || vehicle == 595)
		{
        	return 1;
		}
	}
    return 0;
}

stock IsPlayerOnAnyBike(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
 		new vehicle = GetVehicleModel(GetPlayerVehicleID(playerid));
        if(vehicle == 448 || vehicle == 461 || vehicle == 462 || vehicle == 463 || vehicle == 468 || vehicle == 471 || vehicle == 481 || vehicle == 409 || vehicle == 510 || vehicle == 521 || vehicle == 522 || vehicle == 523 || vehicle == 581 || vehicle == 586)
		{
        	return 1;
		}
	}
    return 0;
}

stock IsPlayerOnFoot(playerid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) return 1;
    return 0;
}

stock IsCharUpper(c)
{
    return ('A' <= c <= 'Z');
}

stock IsCharLower(c)
{
    return ('a' <= c <= 'z');
}

stock GetSecondsBetweenAction(action) // By [03]Garsino | Ye we miss him
{
    new timestamp = GetTickCount(), TimeBetween, Float:fTime;
    TimeBetween = timestamp - action;
    fTime = floatdiv(TimeBetween, 1000);
    return floatround(fTime, floatround_tozero);
}

stock DefaultGravity() //simple lol
{
	SetGravity(0.008);
}

stock IsPlayerVehicleModded(playerid, vehicleid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 0;
    for(new slot = 0; slot < 13; slot++)
    {
        if(GetVehicleComponentInSlot(vehicleid, slot)) return 1;

    }
    return 0;
}

stock bool:IsValidNumber( string[ ] )
{
    if ( !string[ 0 ] )
        return false;

    new
        iLength = strlen( string ),
        i
    ;

    if ( string[ 0 ] == '-' && string[ 1 ] )
        i = 1;

    for ( ; i < iLength; i++ )
    {
        if ( !( '0' <= string[ i ] <= '9' ) )
            return false;
    }

    return true;
}
stock SendClientMessageToRconAdmin(msg[])
{
	foreach(Player,i) if(IsPlayerAdmin(i)) SendClientMessage(i,COLOR_GREEN,msg);
}

//=====================Thanks to Wesley==========================================
stock GetXYInFrontOfPlayer(playerid, &Float:x2, &Float:y2, Float:distance)
{
        new Float:a;
        GetPlayerPos( playerid, x2, y2, a );
        GetPlayerFacingAngle( playerid, a );
        if( GetPlayerVehicleID( playerid ) )
        {
                GetVehicleZAngle( GetPlayerVehicleID( playerid ), a );
        }
        x2 += ( distance * floatsin( -a, degrees ) );
        y2 += ( distance * floatcos( -a, degrees ) );
}

stock IsValidNosVehicle(vehicleid)
{
    switch( GetVehicleModel(vehicleid) )
    {
        case 417, 425, 430, 432, 441, 446, 447, 448, 449, 450, 452, 453, 454,
             460, 461, 462, 463, 464, 465, 468, 469, 472, 473, 476, 481, 484,
             487, 488, 493, 497, 501, 509, 510, 511, 512, 513, 519, 520, 521,
             522, 523, 537, 538, 539, 548, 553, 563, 564, 569, 570, 577, 581,
             584, 586, 590, 591, 592, 593, 594, 595, 606, 607, 608, 610, 611: return 0;
        default:                                                              return 1;
    }
    return 0;
}

stock ShowMarkers( playerid, toggle )
{
    if( toggle == 1 )
    {
        for( new i = 0; i < MAX_PLAYERS; i ++ )
        {
            SetPlayerMarkerForPlayer( playerid, i, GetPlayerColor( i ) );
        }
    }
    else if( toggle == 0 )
    {
        for( new i = 0; i < MAX_PLAYERS; i ++ )
        {
            SetPlayerMarkerForPlayer( playerid, i, ( GetPlayerColor( 1 ) & 0xFFFFFF00 ) );
        }
    }
    return 1;
}

stock IsInvalidSkin(skinid)
{
	#define	MAX_BAD_SKINS   14

	new badSkins[MAX_BAD_SKINS] =
	{
		3, 4, 5, 6, 8, 42, 65, 74, 86,
		119, 149, 208, 273, 289
	};

	for ( new i = 0; i < MAX_BAD_SKINS; i++ )
	{
	    if ( skinid == badSkins[i] ) return 1;
	}

	return 0;
}

stock SetPlayerPosEx(playerid, Float:x, Float:y, Float:z, Float:a)
{
	SetPlayerPos( playerid, x, y, z );
	SetPlayerFacingAngle( playerid, a );
	return 1;
}

stock strset(string[], input[])
{
    strdel( string, 0, strlen( string ) );
    strcat( string, input, strlen( input ) + 1 );
    return 1;
}
///=============================================================================
stock SetServerPassword(const password[])
{
        if(strlen(password)>100)return printf("Function Error: Server Passwort is to long (%d cells to much) in SetServerPassword!",strlen(password)-100);
        new string[100+9];
        format(string,sizeof string,"password %s",password);
        return SendRconCommand(string);
}

stock RemoveSodaMachinesForPlayer(playerid)
{
        RemoveBuildingForPlayer(playerid,955,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,956,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1209,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1302,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1775,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1776,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1302,0,0,0,3000);
}

stock RemoveCranesForPlayer(playerid)
{
        RemoveBuildingForPlayer(playerid,1376,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1378,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1380,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1383,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1384,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1386,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1387,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1388,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1389,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1390,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1391,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1392,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1394,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,1395,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,3474,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,5126,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,11400,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,11401,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,11406,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,16328,0,0,0,3000);
        RemoveBuildingForPlayer(playerid,16332,0,0,0,3000);
}

stock FreezePlayer(playerid)
{
	TogglePlayerControllable( playerid, 0 );
}

stock UnfreezePlayer(playerid)
{
	TogglePlayerControllable( playerid, 1 );
}
