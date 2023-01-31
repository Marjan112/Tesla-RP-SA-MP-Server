#include <a_samp>
#include <core>
#include <float>
#include <sampvoice>

#pragma tabsize 0

main() {}

//new SV_GSTREAM:gstream;
new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };

public SV_VOID:OnPlayerActivationKeyPress(
	SV_UINT:playerid,
	SV_UINT:keyid
) {
	if (keyid == 0x42 && lstream[playerid]) SvAttachSpeakerToStream(lstream[playerid], playerid);
	//if (keyid == 0x5A && gstream) SvAttachSpeakerToStream(gstream, playerid);
}

public SV_VOID:OnPlayerActivationKeyRelease(
	SV_UINT:playerid,
	SV_UINT:keyid
) {
	if (keyid == 0x42 && lstream[playerid]) SvDetachSpeakerFromStream(lstream[playerid], playerid);
	//if (keyid == 0x5A && gstream) SvDetachSpeakerFromStream(gstream, playerid);
}

public OnPlayerConnect(playerid) {

	if (!SvGetVersion(playerid)) {
		SendClientMessage(playerid, 0x69696969, "Nemate validnu verziju voice chat-a!");
		return 0;
	}
	else if (!SvHasMicro(playerid)) {
		SendClientMessage(playerid, 0x69696969, "Vi nemate mikrofon za voicechat!");
		return 0;
	}
 	else if (lstream[playerid] = SvCreateDLStreamAtPlayer(40.0, SV_INFINITY, playerid, 0xff0000ff, "L")) { // red color
		SendClientMessage(playerid, -1, "Voicechat je uspesno ucitan!");
		//if (gstream) SvAttachListenerToStream(gstream, playerid);
		SvAddKey(playerid, 0x42);
		//SvAddKey(playerid, 0x5A);
	}

	return 1;
	
}

public OnPlayerDisconnect(playerid, reason) {

	if (lstream[playerid]) {

		SvDeleteStream(lstream[playerid]);
		lstream[playerid] = SV_NULL;
	}

	return 1;
	
}
public OnFilterScriptInit() {

	//SvDebug(SV_TRUE);

	//gstream = SvCreateGStream(0xffff0000, "G"); // blue color

	return 1;
	
}

