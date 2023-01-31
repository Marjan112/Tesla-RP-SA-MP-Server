#include <a_samp>
#include <Dini>
enum tunerer
{
	tSPOILER,
	tHOOD,
	tROOF,
	tSIDESKIRT,
	tLAMPS,
	tNITRO,
	tEXHAUST,
	tWHEELS,
	tSTEREO,
	tHYDRAULICS,
	tFRONT_BUMPER,
	tREAR_BUMPER,
	tVENT_RIGHT,
	tVENT_LEFT,
	tPAINT_JOB,
	tCOLOR1,
	tCOLOR2,
};
new Tuninger[MAX_VEHICLES][tunerer];

stock Ongminit()
{
for(new s = 0; s < MAX_VEHICLES; s++)
{
Tuninger[s][tPAINT_JOB]=99;
Tuninger[s][tCOLOR1]=1;
Tuninger[s][tCOLOR2]=1;
}
for(new ri = 0; ri < MAX_VEHICLES; ri++)
{
new FileName[128];
format(FileName, sizeof(FileName), "auta/Auto_%d.ini",ri);
if(fexist(FileName) )
{
Tuninger[ri][tSPOILER] = dini_Int(FileName,"SPOILER");
Tuninger[ri][tHOOD]= dini_Int(FileName,"HOOD");
Tuninger[ri][tROOF]= dini_Int(FileName,"ROOF");
Tuninger[ri][tSIDESKIRT] = dini_Int(FileName,"SIDESKIRT");
Tuninger[ri][tLAMPS] = dini_Int(FileName,"LAMPS");
Tuninger[ri][tNITRO] = dini_Int(FileName,"NITRO");
Tuninger[ri][tEXHAUST] = dini_Int(FileName,"EXHAUST");
Tuninger[ri][tWHEELS] = dini_Int(FileName,"WHEELS");
Tuninger[ri][tSTEREO] = dini_Int(FileName,"STEREO" );
Tuninger[ri][tHYDRAULICS] = dini_Int(FileName,"HYDRAULICS" );
Tuninger[ri][tFRONT_BUMPER] = dini_Int(FileName,"FRONT_BUMPER");
Tuninger[ri][tREAR_BUMPER] = dini_Int(FileName,"REAR_BUMPER");
Tuninger[ri][tVENT_RIGHT] = dini_Int(FileName, "VENT_RIGHT");
Tuninger[ri][tVENT_LEFT] = dini_Int(FileName, "VENT_LEFT");
Tuninger[ri][tPAINT_JOB] = dini_Int(FileName,"PAINT_JOB");
Tuninger[ri][tCOLOR1] = dini_Int(FileName,"COLOR1");
Tuninger[ri][tCOLOR2] = dini_Int(FileName,"COLOR2");
ChangeVehicleColor(ri, Tuninger[ri][tCOLOR1],Tuninger[ri][tCOLOR2]);
if(Tuninger[ri][tPAINT_JOB]!= 99)
{
ChangeVehiclePaintjob(ri,Tuninger[ri][tPAINT_JOB]);
}
AddVehicleComponent(ri,Tuninger[ri][tSPOILER]);
AddVehicleComponent(ri,Tuninger[ri][tHOOD]);
AddVehicleComponent(ri,Tuninger[ri][tROOF]);
AddVehicleComponent(ri,Tuninger[ri][tSIDESKIRT]);
AddVehicleComponent(ri,Tuninger[ri][tLAMPS]);
AddVehicleComponent(ri,Tuninger[ri][tNITRO]);
AddVehicleComponent(ri,Tuninger[ri][tEXHAUST]);
AddVehicleComponent(ri,Tuninger[ri][tWHEELS]);
AddVehicleComponent(ri,Tuninger[ri][tSTEREO]);
AddVehicleComponent(ri,Tuninger[ri][tHYDRAULICS]);
AddVehicleComponent(ri,Tuninger[ri][tFRONT_BUMPER]);
AddVehicleComponent(ri,Tuninger[ri][tREAR_BUMPER]);
AddVehicleComponent(ri,Tuninger[ri][tVENT_RIGHT]);
AddVehicleComponent(ri,Tuninger[ri][tVENT_LEFT]);
}
}
}
public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
Tuninger[vehicleid][tSPOILER]      = GetVehicleComponentInSlot(vehicleid,0);
Tuninger[vehicleid][tHOOD]         = GetVehicleComponentInSlot(vehicleid,1);
Tuninger[vehicleid][tROOF]         = GetVehicleComponentInSlot(vehicleid,2);
Tuninger[vehicleid][tSIDESKIRT]    = GetVehicleComponentInSlot(vehicleid,3);
Tuninger[vehicleid][tLAMPS]        = GetVehicleComponentInSlot(vehicleid,4);
Tuninger[vehicleid][tNITRO]        = GetVehicleComponentInSlot(vehicleid,5);
Tuninger[vehicleid][tEXHAUST]      = GetVehicleComponentInSlot(vehicleid,6);
Tuninger[vehicleid][tWHEELS]       = GetVehicleComponentInSlot(vehicleid,7);
Tuninger[vehicleid][tSTEREO]       = GetVehicleComponentInSlot(vehicleid,8);
Tuninger[vehicleid][tHYDRAULICS]   = GetVehicleComponentInSlot(vehicleid,9);
Tuninger[vehicleid][tFRONT_BUMPER] = GetVehicleComponentInSlot(vehicleid,10);
Tuninger[vehicleid][tREAR_BUMPER]  = GetVehicleComponentInSlot(vehicleid,11);
Tuninger[vehicleid][tVENT_RIGHT]   = GetVehicleComponentInSlot(vehicleid,12);
Tuninger[vehicleid][tVENT_LEFT]    = GetVehicleComponentInSlot(vehicleid,13);
Tuninger[vehicleid][tPAINT_JOB]=paintjobid;
sacuvajjednom(vehicleid);
return 1;
}
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
Tuninger[vehicleid][tSPOILER]      = GetVehicleComponentInSlot(vehicleid,0);
Tuninger[vehicleid][tHOOD]         = GetVehicleComponentInSlot(vehicleid,1);
Tuninger[vehicleid][tROOF]         = GetVehicleComponentInSlot(vehicleid,2);
Tuninger[vehicleid][tSIDESKIRT]    = GetVehicleComponentInSlot(vehicleid,3);
Tuninger[vehicleid][tLAMPS]        = GetVehicleComponentInSlot(vehicleid,4);
Tuninger[vehicleid][tNITRO]        = GetVehicleComponentInSlot(vehicleid,5);
Tuninger[vehicleid][tEXHAUST]      = GetVehicleComponentInSlot(vehicleid,6);
Tuninger[vehicleid][tWHEELS]       = GetVehicleComponentInSlot(vehicleid,7);
Tuninger[vehicleid][tSTEREO]       = GetVehicleComponentInSlot(vehicleid,8);
Tuninger[vehicleid][tHYDRAULICS]   = GetVehicleComponentInSlot(vehicleid,9);
Tuninger[vehicleid][tFRONT_BUMPER] = GetVehicleComponentInSlot(vehicleid,10);
Tuninger[vehicleid][tREAR_BUMPER]  = GetVehicleComponentInSlot(vehicleid,11);
Tuninger[vehicleid][tVENT_RIGHT]   = GetVehicleComponentInSlot(vehicleid,12);
Tuninger[vehicleid][tVENT_LEFT]    = GetVehicleComponentInSlot(vehicleid,13);
Tuninger[vehicleid][tCOLOR1]=color1;
Tuninger[vehicleid][tCOLOR2]=color2;
sacuvajjednom(vehicleid);
return 1;
}
public OnVehicleSpawn(vehicleid)
{
new FileName[128];
format(FileName, sizeof(FileName), "auta/Auto_%d.ini",vehicleid);
if(fexist(FileName) )
{
ChangeVehicleColor(vehicleid, Tuninger[vehicleid][tCOLOR1],Tuninger[vehicleid][tCOLOR2]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tSPOILER]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tHOOD]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tROOF]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tSIDESKIRT]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tLAMPS]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tNITRO]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tEXHAUST]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tWHEELS]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tSTEREO]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tHYDRAULICS]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tFRONT_BUMPER]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tREAR_BUMPER]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tVENT_RIGHT]);
AddVehicleComponent(vehicleid,Tuninger[vehicleid][tVENT_LEFT]);
if(Tuninger[vehicleid][tPAINT_JOB]!= 99)
{
ChangeVehiclePaintjob(vehicleid,Tuninger[vehicleid][tPAINT_JOB]);
}
}
return 1;
}
stock sacuvajjednom(di)
{
new FileName[128];
format(FileName, sizeof(FileName), "auta/Auto_%d.ini",di);
if(!fexist(FileName))
{
dini_Create(FileName);
}
dini_IntSet(FileName,"SPOILER",GetVehicleComponentInSlot(di,0));
dini_IntSet(FileName,"HOOD",GetVehicleComponentInSlot(di,1));
dini_IntSet(FileName,"ROOF",GetVehicleComponentInSlot(di,2));
dini_IntSet(FileName,"SIDESKIRT",GetVehicleComponentInSlot(di,3));
dini_IntSet(FileName,"LAMPS",GetVehicleComponentInSlot(di,4));
dini_IntSet(FileName,"NITRO",GetVehicleComponentInSlot(di,5));
dini_IntSet(FileName,"EXHAUST",GetVehicleComponentInSlot(di,6));
dini_IntSet(FileName,"WHEELS",GetVehicleComponentInSlot(di,7));
dini_IntSet(FileName,"STEREO",GetVehicleComponentInSlot(di,8));
dini_IntSet(FileName,"HYDRAULICS",GetVehicleComponentInSlot(di,9));
dini_IntSet(FileName,"FRONT_BUMPER",GetVehicleComponentInSlot(di,10));
dini_IntSet(FileName,"REAR_BUMPER",GetVehicleComponentInSlot(di,11));
dini_IntSet(FileName,"VENT_RIGHT",GetVehicleComponentInSlot(di,12));
dini_IntSet(FileName,"VENT_LEFT",GetVehicleComponentInSlot(di,13));
dini_IntSet(FileName,"PAINT_JOB",Tuninger[di][tPAINT_JOB]);
dini_IntSet(FileName,"COLOR1",Tuninger[di][tCOLOR1]);
dini_IntSet(FileName,"COLOR2",Tuninger[di][tCOLOR2]);
}
stock Tuner_ChangeVehicleColor(vehicleid,color1,color2)
{
ChangeVehicleColor(vehicleid,color1,color2);
Tuninger[vehicleid][tCOLOR1]=color1;
Tuninger[vehicleid][tCOLOR2]=color2;
sacuvajjednom(vehicleid);
}
