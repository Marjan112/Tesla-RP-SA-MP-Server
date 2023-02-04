#if defined _mapicons_included
    #endinput
#endif
#define _mapicons_included

#pragma library Mapicons

#include "../gamemodes/data/tags.inc"

#if !defined _samp_included
    #tryinclude <a_samp>
#endif

stock CallMapIcons(playerid) {
    SetPlayerMapIcon(playerid, HOSPITAL, 1172.0773,-1323.3525,15.4030, HOSPITAL, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, BANK, 1457.0255,-1009.9204,26.8438, BANK, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, POLICE, 1555.5020,-1675.6063,16.1953, POLICE, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, AMMUNATION, 1368.9985,-1279.7140,13.546, AMMUNATION, -1, MAPICON_GLOBAL);
	// SetPlayerMapIcon(playerid, ZEMUNCI, 1244.688964, -738.394348, 95.340431, ZEMUNCI, -1, MAPICON_GLOBAL);
	// SetPlayerMapIcon(playerid, FIBOVCI, 1286.794921, -1327.190795, 13.654617, FIBOVCI, -1, MAPICON_GLOBAL);
	SetPlayerMapIcon(playerid, AUTO_SALON, 2261.2512,-1902.8901,13.5469, AUTO_SALON, -1, MAPICON_GLOBAL);
}