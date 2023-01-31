//#define FILTERSCRIPT

#include <YSI>

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
    print(" YSI Gamemode by your name here");
    print("--------------------------------\n");
}

#endif

Text_RegisterTag(tag_with_MY_KILL_HELP);

forward ycmd_kill(playerid, params[], help);
public ycmd_kill(playerid, params[], help)
{
    if (help) Text_Send(playerid, "MY_KILL_HELP");
    else SetPlayerHealth(playerid, 0.0);
    return 1;
}

Script_OnGameModeInit()
{
    // Don't use these lines if it's a filterscript
    SetGameModeText("Blank Script");
    AddStaticVehicleEx(487, 2040.0568, 1343.4222, 10.6719, 0.0, 0, 0, 20);
    AddStaticVehicleEx(435, 2040.0568, 1354.4222, 10.6719, 0.0, 0, 0, 20); // long trailer - 1
    AddStaticVehicleEx(515, 2040.0568, 1365.4222, 10.6719, 0.0, 0, 0, 20); // roadtrain
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
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
    return 1;
}

Script_OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    return 1;
}

Script_OnPlayerRequestSpawn(playerid)
{
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
    return 1;
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

Script_OnPlayerEnterCheckpoint(playerid)
{
    return 1;
}

Script_OnPlayerLeaveCheckpoint(playerid)
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

Script_OnPlayerEnterCheckpointEx(playerid, cpid)
{
    return 1;
}

Script_OnPlayerLeaveCheckpointEx(playerid, cpid)
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

