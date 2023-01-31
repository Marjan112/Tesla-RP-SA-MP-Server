//Vehicle Exported with Texture Studio By: [uL]Pottus/////////////////////////////////////////////////////////////
//////////////////////////////////////////////////and Crayder/////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <a_samp>
#include <streamer>

new carvid_0;
new carvid_1;
new carvid_2;
new carvid_3;
new carvid_4;

public OnFilterScriptInit()
{ 
    new tmpobjid;

    carvid_0 = CreateVehicle(421,1552.989,-1686.672,6.218,157.749,-1,-1,-1,0);
    carvid_1 = CreateVehicle(421,1539.671,-1662.683,5.890,22.098,1,0,-1,0);
    carvid_2 = CreateVehicle(421,1544.121,-1696.661,5.896,244.922,1,1,-1,0);
    carvid_3 = CreateVehicle(489,1545.700,-1680.303,5.890,4.376,1,8,-1,0);
    carvid_4 = CreateVehicle(411,1533.147,-1652.278,5.890,19.012,1,8,-1,0);





    tmpobjid = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(tmpobjid, carvid_2, 0.000, 0.000, 0.700, 0.000, 0.000, 0.000);

    tmpobjid = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(tmpobjid, carvid_3, 0.000, 0.000, 1.200, 0.000, 0.000, 0.000);

    tmpobjid = CreateDynamicObject(19620,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(tmpobjid, carvid_4, 0.000, 0.000, 0.879, 0.000, 0.000, 0.000);
    return 1;

} 

public OnFilterScriptExit()
{ 
    DestroyVehicle(carvid_0);
    DestroyVehicle(carvid_1);
    DestroyVehicle(carvid_2);
    DestroyVehicle(carvid_3);
    DestroyVehicle(carvid_4);
    return 1;
} 

public OnVehicleSpawn(vehicleid)
{ 
    if(vehicleid == carvid_0)
    {
    }
    else if(vehicleid == carvid_1)
    {
    }
    else if(vehicleid == carvid_2)
    {
    }
    else if(vehicleid == carvid_3)
    {
    }
    else if(vehicleid == carvid_4)
    {
    }
} 
