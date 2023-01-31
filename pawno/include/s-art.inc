#pragma library SART
native CreateArt(text[], Float:sX, Float:sY, Float:sZ, Float:aX, Float:aY, Float:aZ, Float:dist, type);
native DestroyArt(artid);

forward InvokeFunction();
public InvokeFunction()
{
	new Var[ 256 ];
	new iVar;
	iVar = CreateObject(0,0.0,0.0,0.0,0.0,0.0,0.0);
    SetObjectMaterialText(iVar, Var, 0, OBJECT_MATERIAL_SIZE_512x512, "Webdings", 35, 0, 0, 0, 0);
	SetObjectMaterial(iVar, 1, -1, "none", "none", 0);
	DestroyObject(iVar);
	return 1;
}