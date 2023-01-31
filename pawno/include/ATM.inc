#include <a_samp>
#define COLOR_BLUE 0x0000FFAA
#define MAX_ATMS 2000

enum AInfo
{
	aCreated,
    Float:aX,
    Float:aY,
    Float:aZ,
    Float:arX,
    Float:arY,
    Float:arZ,
    aObject,
};

new AtmInfo[MAX_ATMS][AInfo];

stock CreateAtm(Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    for(new i = 0; i < sizeof(AtmInfo); i++)
  	{
  	    if(AtmInfo[i][aCreated] == 0)
  	    {
            AtmInfo[i][aCreated]=1;
            AtmInfo[i][aX]=x;
            AtmInfo[i][aY]=y;
            AtmInfo[i][aZ]=z;
            AtmInfo[i][arX]=rx;
            AtmInfo[i][arY]=ry;
            AtmInfo[i][arZ]=rz;
            AtmInfo[i][aObject] = CreateObject(2942, x, y, z, rx, ry, rz);
            CreateDynamicMapIcon(x, y, z, 52, -1,-1,-1, -1, 250.0);
	        return 1;
  	    }
  	}
  	return 0;
}