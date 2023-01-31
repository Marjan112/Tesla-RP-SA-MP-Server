#include <a_samp>
////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                //
//  ++////////////////////////////////////////////////////////////////////////////////////////++  //
//  //                                                                                        //  //
//  //    Smoothly Rotate Objects                                                             //  //
//  //    _________________________                                                           //  //
//  //    By NoZer0                                                                           //  //
//  //                                                                                        //  //
//  //    Functions:                                                                          //  //
//  //                                                                                        //  //
//  //    native RotateObject(Objectid, Float:RotX, Float:RotY, Float:RotZ, Float:Speed=2.0)  //  //
//  //                                                                                        //  //
//  ++////////////////////////////////////////////////////////////////////////////////////////++  //
//                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////

forward Core_UpdateRotating(Objectid, Float:RotX, Float:RotY, Float:RotZ, Float:Speed, LastUpdate, xDone, yDone, zDone);
forward OnObjectRotated(objectid);

////////////////////////////////////////////////////////////////////////////////////////////////////

#if !defined SRO_UPDATE_TIME
	#define SRO_UPDATE_TIME 5
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////

stock RotateObject(Objectid, Float:RotX, Float:RotY, Float:RotZ, Float:Speed=5.0)
{
	SetTimerEx("Core_UpdateRotating", SRO_UPDATE_TIME, 0, "dffffdddddd", Objectid, RotX, RotY, RotZ, Speed/100, GetTickCount(), 0, 0, 0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

public Core_UpdateRotating(Objectid, Float:RotX, Float:RotY, Float:RotZ, Float:Speed, LastUpdate, xDone, yDone, zDone)
{
	new Float:curxic, Float:curyic, Float:curzic;
	GetObjectRot(Objectid, curxic, curyic, curzic);
	if (!xDone)
	{
		if (curxic < RotX)
		{
			curxic += (Speed * (GetTickCount() - LastUpdate));
			if (curxic >= RotX)
			{
			    xDone = true;
			    curxic = RotX;
			}
		}
		else
		{
			curxic -= (Speed * (GetTickCount() - LastUpdate));
			if (curxic <= RotX)
			{
			    xDone = true;
				curxic = RotX;
			}
		}
	}
	if (!yDone)
	{
		if (curyic < RotY)
		{
			curyic += (Speed * (GetTickCount() - LastUpdate));
			if (curyic >= RotY)
			{
			    yDone = true;
			    curyic = RotY;
			}
		}
		else
		{
			curyic -= (Speed * (GetTickCount() - LastUpdate));
			if (curyic <= RotY)
			{
			    yDone = true;
				curyic = RotY;
			}
		}
	}
	if (!zDone)
	{
		if (curzic < RotZ)
		{
			curzic += (Speed * (GetTickCount() - LastUpdate));
			if (curzic >= RotZ)
			{
			    zDone = true;
			    curzic = RotZ;
			}
		}
		else
		{
			curzic -= (Speed * (GetTickCount() - LastUpdate));
			if (curzic <= RotZ)
			{
			    zDone = true;
				curzic = RotZ;
			}
		}
	}
	SetObjectRot(Objectid, curxic, curyic, curzic);
	if (!xDone || !yDone || !zDone)
	{
		SetTimerEx("Core_UpdateRotating", SRO_UPDATE_TIME, 0, "dffffdddd", Objectid, RotX, RotY, RotZ, Speed, GetTickCount(), xDone, yDone, zDone);
	}
	else
	{
		SetTimerEx("OnObjectRotated", 500, 0, "d", Objectid);
	}
	return 1;
}
