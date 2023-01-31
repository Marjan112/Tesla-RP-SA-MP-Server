//#define FILTERSCRIPT

//#define YSI_NO_MODULES
//#define YSI_NO_OBJECTS
//#define YSI_NO_RACES
//#define YSI_NO_CHECKPOINTS
//#define YSI_NO_AREAS
//#define YSI_NO_GROUPS
//#define YSI_NO_PROPERTIES
//#define YSI_NO_ZONES

#include <a_samp>
#include <YSI/setup/YSI_master.own>
#include <YSI>

  /*===================
  Round Time in Minutes
  ===================*/
  
new gRoundTime = 20; // 20 minutes
//new gRoundTime = 15; // 15 minutes
//new gRoundTime = 10; // 10 minutes
//new gRoundTime = 5; // 5 minutes
//new gRoundTime = 2; // 2 minutes
//new gRoundTime = 1; // 1 minutes

  /*=================
  Randomized Spawning
  =================*/
  
enum PlayerSpawnInfo
{
	Float:PlayerX,
	Float:PlayerY,
	Float:PlayerZ,
	Float:PlayerAngle
}

new Float:gRandomSpawns[][PlayerSpawnInfo] =
{
	{2544.5032,	2805.8840,	19.9922,	257.5800},
	{2556.2554,	2832.5313,	19.9922,	1.9000},
	{2561.9175,	2848.5532,	19.9922,	256.6609},
	{2613.9866,	2848.4475,	19.9922,	102.2487},
	{2611.5500,	2845.7542,	16.7020,	87.5428},
	{2545.9243,	2839.1824,	10.8203,	176.2378},
	{2647.6553,	2805.0278,	10.8203,	285.1536},
	{2672.9387,	2800.3374,	10.8203,	60.4288},
	{2672.8306,	2792.1057,	10.8203,	121.8451},
	{2647.7834,	2697.5884,	19.3222,	353.1684},
	{2654.5427,	2720.3474,	19.3222,	303.5359},
	{2653.2063,	2738.2432,	19.3222,	342.1389},
	{2641.1350,	2703.2019,	25.8222,	191.6982},
	{2599.1304,	2700.7249,	25.8222,	76.3487},
	{2606.1384,	2721.5237,	25.8222,	261.2564},
	{2597.3745,	2748.0884,	23.8222,	273.2050},
	{2595.0657,	2776.6729,	23.8222,	254.3630},
	{2601.3640,	2777.8101,	23.8222,	253.4439},
	{2584.3940,	2825.1748,	27.8203,	244.5475},
	{2631.8110,	2834.2593,	40.3281,	213.2975},
	{2632.2852,	2834.9390,	122.9219,	197.6725},
	{2646.1997,	2817.7070,	36.3222,	182.0474},
	{2685.8875,	2816.6575,	36.3222,	129.9525},
	{2691.1233,	2787.7883,	59.0212,	208.0777},
	{2717.8071,	2771.3464,	74.8281,	72.3429},
	{2695.2622,	2699.5488,	22.9472,	66.3686},
	{2688.8206,	2689.0039,	28.1563,	14.8979},
	{2655.0229,	2650.6807,	36.9154,	341.8097},
	{2570.4668,	2701.2876,	22.9507,	204.0154},
	{2498.9915,	2704.6204,	10.9844,	168.9241},
	{2524.1584,	2743.3735,	10.9917,	150.3771},
	{2498.3167,	2782.3357,	10.8203,	251.7015},
	{2504.5142,	2805.9763,	14.8222,	108.6137},
	{2522.2144,	2814.7087,	24.9536,	265.9478},
	{2510.6292,	2849.6384,	14.8222,	191.4991},
	{2618.2646,	2720.8005,	36.5386,	346.6828},
	{2690.9980,	2741.9060,	19.0722,	91.6099}
};

  /*===================================
  Pickup Spawns(miniguns and parachutes
  ===================================*/
  
enum PickupSpawnInfo
{
	Float:PickupX,
	Float:PickupY,
	Float:PickupZ
}

new Float:gMinigunPickups[][PickupSpawnInfo] =
{
	{2629.6345,	2732.8936,	36.5386},
	{2635.4575,	2767.9346,	25.8222},
	{2685.5012,	2746.6240,	20.3222},
	{2668.6201,	2767.9753,	17.6896},
	{2553.7502,	2754.9238,	10.8203},
	{2524.9805,	2817.3428,	10.8203},
	{2564.5159,	2823.4812,	12.7568},
	{2594.1836,	2821.1226,	12.7647},
	{2601.4983,	2769.2195,	25.8222}
};

new Float:gParachutePickups[][PickupSpawnInfo] =
{
	{2632.7573,	2829.8999,	64.3359},
	{2632.3562,	2829.9094,	94.0156},
	{2632.3701,	2829.7065,	122.9219},
	{2719.7905,	2775.7646,	74.8281}
};

#if defined FILTERSCRIPT

Script_OnFilterScriptInit()
{
    print("\n------------------------------------");
    print(" YSI Filterscript by your name here");
    print("------------------------------------\n");

    ycmd(kill);
    ycmd("mycommand");
    Langs_AddLanguage("EN", "English");
    Langs_AddFile("core", "YSI");
    return 1;
}

Script_OnFilterScriptExit()
{
    return 1;
}

#else

main()
{
    print("\n--------------------------------");
    print("       YSI Minigun Madness!");
    print("        By [AU]Hell_Demon");
    print(" ");
    print("        Originaly by Mike!");
    print("--------------------------------\n");
}

#endif

Text_RegisterTag(tag_with_MY_KILL_HELP);

forward ycmd_kill(playerid, params[], help);
forward AddThePickups();
forward GameModeExitFunc();

public ycmd_kill(playerid, params[], help)
{
    if (help) Text_Send(playerid, "MY_KILL_HELP");
    else SetPlayerHealth(playerid, 0.0);
    return 1;
}

Script_OnGameModeInit()
{
    // Don't use these lines if it's a filterscript
    SetGameModeText("Minigun Maddness!");
    ShowNameTags(0);
	ShowPlayerMarkers(0);
	Class_Add(0,0,0,0,0,0,0,0,0,0,0);
	AddThePickups();
	SetTimer("GameModeExitFunc", gRoundTime*60000, 0);
	
    ycmd(kill);
    ycmd("mycommand");
    Langs_AddLanguage("EN", "English");
    Langs_AddFile("core", "YSI");
    return 1;
}

Command_(mycommand)
{
    // Your code here
    return 1;
}

Script_OnGameModeExit()
{
	Master_@Master();
    return 1;
}

Script_OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 2495.0449, 2773.0566, 10.8158);
	SetPlayerFacingAngle(playerid, 88.0);
	SetPlayerCameraPos(playerid, 2490.9556, 2773.1326, 10.7968);
	SetPlayerCameraLookAt(playerid, 2495.0449, 2773.0566, 10.8158);
    return 1;
}

Script_OnPlayerRequestSpawnEx(playerid, classid)
{
    ResetSpawnInfo(playerid);
    return 1;
}

Script_OnPlayerConnect(playerid)
{
    return 1;
}

Script_OnPlayerDisconnect(playerid, reason)
{
    return 1;
}

Script_OnPlayerSpawn(playerid)
{
    return 1;
}

Script_OnPlayerDeath(playerid, killerid, reason)
{
    SendDeathMessage(killerid, playerid, reason);
	SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
	ResetSpawnInfo(playerid);
    return 1;
}

ResetSpawnInfo(playerid)
{
	new rand = random(sizeof(gRandomSpawns));
	SetSpawnInfo(playerid, 255, 0,
	gRandomSpawns[rand][PlayerX],
	gRandomSpawns[rand][PlayerY],
	gRandomSpawns[rand][PlayerZ],
	gRandomSpawns[rand][PlayerAngle], 38, 500, 0, 0, 0, 0);

}

Script_OnVehicleSpawn(vehicleid)
{
    return 1;
}

Script_OnVehicleDeath(vehicleid, killerid)
{
    return 1;
}

Script_OnPlayerText(playerid, text[])
{
    return 1;
}

Script_OnPlayerPrivmsg(playerid, recieverid, text[])
{
    return 1;
}

Script_OnPlayerCommandText(playerid, cmdtext[])
{
    return 0;
}

Script_OnPlayerInfoChange(playerid)
{
    return 1;
}

Script_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    return 1;
}

Script_OnPlayerExitVehicle(playerid, vehicleid)
{
    return 1;
}

Script_OnPlayerStateChange(playerid, newstate, oldstate)
{
    return 1;
}

Script_OnPlayerEnterCheckpointEx(playerid, cpid)
{
    return 1;
}

Script_OnPlayerLeaveCheckpointEx(playerid, cpid)
{
    return 1;
}

Script_OnPlayerEnterRaceCheckpoint(playerid)
{
    return 1;
}

Script_OnPlayerLeaveRaceCheckpoint(playerid)
{
    return 1;
}

Script_OnRconCommand(cmd[])
{
    return 1;
}

Script_OnObjectMoved(objectid)
{
    return 1;
}

Script_OnPlayerObjectMoved(playerid, objectid)
{
    return 1;
}

Script_OnPlayerPickUpPickup(playerid, pickupid)
{
    return 1;
}

Script_OnPlayerSelectedMenuRow(playerid, row)
{
    return 1;
}

Script_OnPlayerExitedMenu(playerid)
{
    return 1;
}

Script_OnVehicleMod(vehicleid, componentid)
{
    return 1;
}

Script_OnVehiclePaintjob(vehicleid, paintjobid)
{
    return 1;
}

Script_OnVehicleRespray(vehicleid, color1, color2)
{
    return 1;
}

Script_OnPlayerLogin(playerid, yid)
{
    return 1;
}

Script_OnPlayerLogout(playerid)
{
    return 1;
}

Script_OnPlayerEnterArea(playerid, areaid)
{
    return 1;
}

Script_OnPlayerLeaveArea(playerid, areaid)
{
    return 1;
}

Script_OnRaceEnd(raceid)
{
    return 1;
}

Script_OnPlayerExitRace(playerid, raceid)
{
    return 1;
}

Script_OnPlayerFinishRace(playerid, raceid, position, prize, time)
{
    return 1;
}


public AddThePickups()
{
    new i, j;

	for (i = 0, j = sizeof(gMinigunPickups); i < j; i++)
	{
		AddStaticPickup(362, 15,
		gMinigunPickups[i][PickupX],
		gMinigunPickups[i][PickupY],
		gMinigunPickups[i][PickupZ]);
	}
	for (i = 0, j = sizeof(gParachutePickups); i < j; i++)
	{
		AddStaticPickup(371, 15,
		gParachutePickups[i][PickupX],
		gParachutePickups[i][PickupY],
		gParachutePickups[i][PickupZ]);
	}
}

public GameModeExitFunc()
{
	GameModeExit();
}
