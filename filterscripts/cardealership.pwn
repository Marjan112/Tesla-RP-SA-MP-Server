//Vehicle Exported with Texture Studio By: [uL]Pottus/////////////////////////////////////////////////////////////
//////////////////////////////////////////////////and Crayder/////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <a_samp>
#include <streamer>

new carvid_0;
new carvid_1;
new carvid_2;
new carvid_3;

public OnFilterScriptInit()
{

    carvid_0 = CreateVehicle(415,2235.439,-1910.486,14.149,254.649,-1,-1,-1,0);
    carvid_1 = CreateVehicle(496,2235.723,-1918.602,13.911,286.143,-1,-1,-1,0);
    carvid_2 = CreateVehicle(506,2286.413,-1918.924,13.943,74.172,0,0,-1,0);
    carvid_3 = CreateVehicle(560,2286.279,-1910.465,14.096,103.270,0,0,-1,0);
} 

public OnFilterScriptExit()
{ 
    DestroyVehicle(carvid_0);
    DestroyVehicle(carvid_1);
    DestroyVehicle(carvid_2);
    DestroyVehicle(carvid_3);
} 

public OnVehicleSpawn(vehicleid)
{
}
