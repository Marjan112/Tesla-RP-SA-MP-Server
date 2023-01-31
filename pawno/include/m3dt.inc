#include <streamer>

#define CreateObject CreateDynamicObject

new Text3D:textue[250], txtid, tcolor[sizeof(textue)], stringetc1[256][sizeof(textue)], texton3dtext[256][sizeof(textue)];

stock CreateMoveable3DText(string[], speed, color, Float:distance, Float:x, Float:y, Float:z, virtualworld, testLOS)
{
	if(txtid < sizeof(textue))
	{
		if(speed < 1) return printf("Maximum Moveable 3DText's - %d", sizeof(textue));
		txtid++;
		tcolor[txtid] = color;
		format(texton3dtext[txtid], sizeof(texton3dtext), string);
		textue[txtid] = Create3DTextLabel(texton3dtext[txtid], tcolor[txtid], x,y,z, distance, virtualworld, testLOS);
		SetTimerEx("Move3DText", speed*100, true, "i",txtid);
	}
	return true;
}

stock AttachMoveable3DTextToVehicle(string[], speed, color, Float:distance, vehid, Float:x, Float:y, Float:z, virtualworld, testLOS)
{
	if(txtid < sizeof(textue))
	{
		if(speed < 1) return printf("Maximum Moveable 3DText's - %d", sizeof(textue));
		txtid++;
		tcolor[txtid] = color;
		format(texton3dtext[txtid], sizeof(texton3dtext), string);
		textue[txtid] = Create3DTextLabel(texton3dtext[txtid], tcolor[txtid], x,y,z, distance, virtualworld, testLOS);
		Attach3DTextLabelToVehicle(textue[txtid], vehid, x, y, z);
		SetTimerEx("Move3DText", speed*100, true, "i",txtid);
	}
	return true;
}

forward Move3DText(txtid2);
public Move3DText(txtid2)
{
	format(stringetc1[txtid2], 2, "%c", texton3dtext[txtid2]);
	strdel(texton3dtext[txtid2], 0, 1);
	strcat(texton3dtext[txtid2], stringetc1[txtid2]);
	Update3DTextLabelText(textue[txtid2], tcolor[txtid2], texton3dtext[txtid2]);
}