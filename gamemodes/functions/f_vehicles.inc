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