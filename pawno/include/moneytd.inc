#include <a_samp>

new Text:nekitext[MAX_PLAYERS];
new str56[24];
new tajmer[MAX_PLAYERS];
new bool:Postoji56[MAX_PLAYERS] = false;

stock Novac56(playerid,koliko)
{
	if(koliko == 0) return 1;
	if(Postoji56[playerid] == true) return 1;
	Postoji56[playerid]=true;
	nekitext[playerid] = TextDrawCreate(608.000000, 92.000000, " ");
    TextDrawAlignment(nekitext[playerid], 3);
    TextDrawBackgroundColor(nekitext[playerid], 255);
    TextDrawFont(nekitext[playerid], 3);
    TextDrawLetterSize(nekitext[playerid], 0.300000, 1.200000);
    TextDrawColor(nekitext[playerid], -1);
    TextDrawSetOutline(nekitext[playerid], 1);
    TextDrawSetProportional(nekitext[playerid], 1);
	if(koliko < 0) format(str56,sizeof str56,"~r~-$%d",-koliko);
	if(koliko >  0) format(str56,sizeof str56,"~g~+$%d",koliko);
	if(koliko ==  0) format(str56,sizeof str56,"~g~$%d",koliko);
	TextDrawSetString(nekitext[playerid],str56);
	TextDrawShowForPlayer(playerid,nekitext[playerid]);
	tajmer[playerid] = SetTimerEx("removetd56",5000,false,"i",playerid);
	return 1;
}

forward removetd56(playerid);
public removetd56(playerid)
{
    Postoji56[playerid]=false;
	TextDrawDestroy(nekitext[playerid]);
	KillTimer(tajmer[playerid]);
	return 1;
}