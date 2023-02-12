#if defined _textdraws_included
    #endinput
#endif
#define _textdraws_included

#pragma library Textdraws

#if !defined _samp_included
    #include <float>
	native Text: TextDrawCreate(Float: x, Float: y, text[]);
	native TextDrawLetterSize(Text:text, Float:x, Float:y);
	native TextDrawAlignment(Text:text, alignment);
	native TextDrawColor(Text:text, color);
	native TextDrawSetShadow(Text:text, size);
	native TextDrawSetOutline(Text:text, size);
	native TextDrawBackgroundColor(Text:text, color);
	native TextDrawFont(Text:text, font);
	native TextDrawSetProportional(Text:text, set);
#endif

#include "../gamemodes/data/tags.inc"

new Text: sdtd[3];
new Text: Onogore[5];
new PlayerText:gNovac1[MAX_PLAYERS];
new PlayerText:gNovac2[MAX_PLAYERS];

stock Void: CallSDTD() {
    sdtd[0] = TextDrawCreate(38.999980, 429.748260, "00:00");
	TextDrawLetterSize(sdtd[0], 0.449999, 1.600000);
	TextDrawAlignment(sdtd[0], 1);
	TextDrawColor(sdtd[0], 16777215);
	TextDrawSetShadow(sdtd[0], 0);
	TextDrawSetOutline(sdtd[0], 1);
	TextDrawBackgroundColor(sdtd[0], 51);
	TextDrawFont(sdtd[0], 3);
	TextDrawSetProportional(sdtd[0], 1);

	sdtd[1] = TextDrawCreate(541.333190, 429.748138, "00/00/0000");
	TextDrawLetterSize(sdtd[1], 0.438665, 1.591704);
	TextDrawAlignment(sdtd[1], 1);
	TextDrawColor(sdtd[1], 16777215);
	TextDrawSetShadow(sdtd[1], 0);
	TextDrawSetOutline(sdtd[1], 1);
	TextDrawBackgroundColor(sdtd[1], 51);
	TextDrawFont(sdtd[1], 3);
	TextDrawSetProportional(sdtd[1], 1);

	sdtd[2] = TextDrawCreate(326.666778, 428.918426, "Tesla RolePlay");
	TextDrawLetterSize(sdtd[2], 0.449999, 1.600000);
	TextDrawAlignment(sdtd[2], 2);
	TextDrawColor(sdtd[2], -1);
	TextDrawSetShadow(sdtd[2], 0);
	TextDrawSetOutline(sdtd[2], 1);
	TextDrawBackgroundColor(sdtd[2], 51);
	TextDrawFont(sdtd[2], 2);
	TextDrawSetProportional(sdtd[2], 1);
}

stock CallOnoGore() {
	Onogore[0] = TextDrawCreate(551.666687, 9.125926, "Tesla RP");
	TextDrawLetterSize(Onogore[0], 0.489998, 1.753479);
	TextDrawAlignment(Onogore[0], 1);
	TextDrawColor(Onogore[0], 255);
	TextDrawSetShadow(Onogore[0], 1);
	TextDrawSetOutline(Onogore[0], 0);
	TextDrawBackgroundColor(Onogore[0], 51);
	TextDrawFont(Onogore[0], 3);
	TextDrawSetProportional(Onogore[0], 1);

	Onogore[1] = TextDrawCreate(608.667358, 101.885147, "usebox");
	TextDrawLetterSize(Onogore[1], 0.000000, 2.292793);
	TextDrawTextSize(Onogore[1], 462.999908, 0.000000);
	TextDrawAlignment(Onogore[1], 1);
	TextDrawColor(Onogore[1], 0);
	TextDrawUseBox(Onogore[1], true);
	TextDrawBoxColor(Onogore[1], 102);
	TextDrawSetShadow(Onogore[1], 91);
	TextDrawSetOutline(Onogore[1], 0);
	TextDrawFont(Onogore[1], 0);
	TextDrawSetSelectable(Onogore[1], true);

	Onogore[2] = TextDrawCreate(465.332977, 99.970268, "DZEP:");
	TextDrawLetterSize(Onogore[2], 0.449999, 1.600000);
	TextDrawAlignment(Onogore[2], 1);
	TextDrawColor(Onogore[2], 16777215);
	TextDrawSetShadow(Onogore[2], 0);
	TextDrawSetOutline(Onogore[2], 1);
	TextDrawBackgroundColor(Onogore[2], 255);
	TextDrawFont(Onogore[2], 1);
	TextDrawSetProportional(Onogore[2], 1);

	Onogore[3] = TextDrawCreate(608.999938, 132.996292, "usebox");
	TextDrawLetterSize(Onogore[3], 0.000000, 2.172223);
	TextDrawTextSize(Onogore[3], 463.333312, 0.000000);
	TextDrawAlignment(Onogore[3], 1);
	TextDrawColor(Onogore[3], 0);
	TextDrawUseBox(Onogore[3], true);
	TextDrawBoxColor(Onogore[3], 102);
	TextDrawSetShadow(Onogore[3], 0);
	TextDrawSetOutline(Onogore[3], 0);
	TextDrawFont(Onogore[3], 0);

	Onogore[4] = TextDrawCreate(465.333465, 129.837097, "BANKA:");
	TextDrawLetterSize(Onogore[4], 0.449999, 1.600000);
	TextDrawAlignment(Onogore[4], 1);
	TextDrawColor(Onogore[4], 16777215);
	TextDrawSetShadow(Onogore[4], 1);
	TextDrawSetOutline(Onogore[4], 0);
	TextDrawBackgroundColor(Onogore[4], 255);
	TextDrawFont(Onogore[4], 1);
	TextDrawSetProportional(Onogore[4], 1);
}

stock CallNovac(playerid) {
	gNovac1[playerid] = CreatePlayerTextDraw(playerid, 509.000061, 100.799980, "10000000");
	PlayerTextDrawLetterSize(playerid, gNovac1[playerid], 0.390666, 1.616592);
	PlayerTextDrawAlignment(playerid, gNovac1[playerid], 1);
	PlayerTextDrawColor(playerid, gNovac1[playerid], -1);
	PlayerTextDrawSetShadow(playerid, gNovac1[playerid], -3);
	PlayerTextDrawSetOutline(playerid, gNovac1[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, gNovac1[playerid], 51);
	PlayerTextDrawFont(playerid, gNovac1[playerid], 1);
	PlayerTextDrawSetProportional(playerid, gNovac1[playerid], 1);

	gNovac2[playerid] = CreatePlayerTextDraw(playerid, 519.000122, 129.837036, "10000000");
	PlayerTextDrawLetterSize(playerid, gNovac2[playerid], 0.387665, 1.575111);
	PlayerTextDrawAlignment(playerid, gNovac2[playerid], 1);
	PlayerTextDrawColor(playerid, gNovac2[playerid], -1);
	PlayerTextDrawSetShadow(playerid, gNovac2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, gNovac2[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, gNovac2[playerid], 51);
	PlayerTextDrawFont(playerid, gNovac2[playerid], 1);
	PlayerTextDrawSetProportional(playerid, gNovac2[playerid], 1);
}