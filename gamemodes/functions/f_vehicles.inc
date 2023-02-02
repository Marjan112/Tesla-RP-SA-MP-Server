#if defined _f_vehicles_included
    #endinput
#endif
#define _f_vehicles_included

#pragma library F_vehicles

#include "../gamemodes/data/tags.inc"
#if !defined _vehicles_included
    #tryinclude <a_vehicles>
#endif

stock Bool: IsVehicleBicycle(vehid) {
	return GetVehicleModel(vehid) == 481 || GetVehicleModel(vehid) == 509 || GetVehicleModel(vehid) == 510 ? true : false;
}

stock Float: SpeedVehicle(playerid) {
	new Float: ST[4];
	if (IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), ST[0], ST[1], ST[2]);
	else GetPlayerVelocity(playerid, ST[0], ST[1], ST[2]);
	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 180.0;
	return ST[3];
}