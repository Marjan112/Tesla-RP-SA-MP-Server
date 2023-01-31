//Vehicle Exported with Texture Studio By: [uL]Pottus/////////////////////////////////////////////////////////////
//////////////////////////////////////////////////and Crayder/////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <a_samp>
#include <streamer>

new carvid_0;
new carvid_1;

public OnFilterScriptInit()
{ 
    new tmpobjid;

    carvid_0 = CreateVehicle(421,1538.761,-1682.099,5.890,32.890,1,1,-1,1);
    carvid_1 = CreateVehicle(0,0.000,0.000,0.000,0.000,0,0,-1,0);


    ChangeVehiclePaintjob(carvid_0, 0);

    tmpobjid = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(tmpobjid, carvid_0, 0.000, 0.150, 0.679, 0.000, 0.000, 2.699);


} 

public OnFilterScriptExit()
{ 
    DestroyVehicle(carvid_0);
    DestroyVehicle(carvid_1);
} 

public OnVehicleSpawn(vehicleid)
{ 
    if(vehicleid == carvid_0)
    {
        ChangeVehiclePaintjob(carvid_0, 0);
    }
    else if(vehicleid == carvid_1)
    {
    }
} 
