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
	native PlayerTextDrawShow(playerid, PlayerText: text)
#endif

#include "../gamemodes/data/tags.inc"

new Text: sdtd[3];
new Text: Onogore[5];
new PlayerText:gNovac1[MAX_PLAYERS];
new PlayerText:gNovac2[MAX_PLAYERS];

new PlayerText:Loadingscreen0[MAX_PLAYERS];
new PlayerText:Loadingscreen1[MAX_PLAYERS];
new PlayerText:Loadingscreen2[MAX_PLAYERS];
new PlayerText:Loadingscreen3[MAX_PLAYERS];
new PlayerText:Loadingscreen4[MAX_PLAYERS];
new PlayerText:Loadingscreen5[MAX_PLAYERS];
new PlayerText:Loadingscreen6[MAX_PLAYERS];
new PlayerText:Loadingscreen7[MAX_PLAYERS];
new PlayerText:Loadingscreen8[MAX_PLAYERS];
new PlayerText:Loadingscreen9[MAX_PLAYERS];
new PlayerText:Loadingscreen10[MAX_PLAYERS];
new PlayerText:Loadingscreen11[MAX_PLAYERS];
new PlayerText:Loadingscreen12[MAX_PLAYERS];
new PlayerText:Loadingscreen13[MAX_PLAYERS];
new PlayerText:Loadingscreen14[MAX_PLAYERS];
new PlayerText:Loadingscreen15[MAX_PLAYERS];
new PlayerText:Loadingscreen16[MAX_PLAYERS];
new PlayerText:Loadingscreen17[MAX_PLAYERS];
new PlayerText:Loadingscreen18[MAX_PLAYERS];
new PlayerText:Loadingscreen19[MAX_PLAYERS];

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

stock CallLoadingScreen(playerid) {
	Loadingscreen0[playerid] = CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Loadingscreen0[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Loadingscreen0[playerid], 640.000000, 448.000000);
	PlayerTextDrawAlignment(playerid, Loadingscreen0[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen0[playerid], -2139062144);
	PlayerTextDrawSetShadow(playerid, Loadingscreen0[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen0[playerid], 0);
	PlayerTextDrawFont(playerid, Loadingscreen0[playerid], 4);

	Loadingscreen1[playerid] = CreatePlayerTextDraw(playerid, 1.333333, 34.429630, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Loadingscreen1[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Loadingscreen1[playerid], 638.666687, 12.444437);
	PlayerTextDrawAlignment(playerid, Loadingscreen1[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen1[playerid], 16777215);
	PlayerTextDrawSetShadow(playerid, Loadingscreen1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen1[playerid], 0);
	PlayerTextDrawFont(playerid, Loadingscreen1[playerid], 4);

	Loadingscreen2[playerid] = CreatePlayerTextDraw(playerid, 1.333333, 214.459259, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Loadingscreen2[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Loadingscreen2[playerid], 638.666687, 13.688899);
	PlayerTextDrawAlignment(playerid, Loadingscreen2[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen2[playerid], 16777215);
	PlayerTextDrawSetShadow(playerid, Loadingscreen2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen2[playerid], 0);
	PlayerTextDrawFont(playerid, Loadingscreen2[playerid], 4);

	Loadingscreen3[playerid] = CreatePlayerTextDraw(playerid, 10.000000, 397.807403, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Loadingscreen3[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Loadingscreen3[playerid], 1250.666870, 15.762967);
	PlayerTextDrawAlignment(playerid, Loadingscreen3[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen3[playerid], 16777215);
	PlayerTextDrawSetShadow(playerid, Loadingscreen3[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen3[playerid], 0);
	PlayerTextDrawFont(playerid, Loadingscreen3[playerid], 4);

	Loadingscreen4[playerid] = CreatePlayerTextDraw(playerid, 273.000579, 213.214797, "Tesla Roleplay");
	PlayerTextDrawLetterSize(playerid, Loadingscreen4[playerid], 0.444330, 1.570960);
	PlayerTextDrawAlignment(playerid, Loadingscreen4[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen4[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen4[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen4[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen4[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen4[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen4[playerid], 1);

	Loadingscreen5[playerid] = CreatePlayerTextDraw(playerid, 158.333343, 356.740936, "ovo ce mozda potrajati nekoliko minuta");
	PlayerTextDrawLetterSize(playerid, Loadingscreen5[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen5[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen5[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen5[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen5[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen5[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen5[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen5[playerid], 1);

	Loadingscreen6[playerid] = CreatePlayerTextDraw(playerid, 249.999984, 322.311096, "ucitavanje servera");
	PlayerTextDrawLetterSize(playerid, Loadingscreen6[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen6[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen6[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen6[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen6[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen6[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen6[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen6[playerid], 1);

	Loadingscreen7[playerid] = CreatePlayerTextDraw(playerid, 407.666717, 62.222225, "dobra optimizacija");
	PlayerTextDrawLetterSize(playerid, Loadingscreen7[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen7[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen7[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen7[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen7[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen7[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen7[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Loadingscreen7[playerid], 1);

	Loadingscreen8[playerid] = CreatePlayerTextDraw(playerid, 383.666259, 99.555625, "slobodne organizacije");
	PlayerTextDrawLetterSize(playerid, Loadingscreen8[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen8[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen8[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen8[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen8[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen8[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen8[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Loadingscreen8[playerid], 1);

	Loadingscreen9[playerid] = CreatePlayerTextDraw(playerid, 446.332885, 141.037033, "voice chat");
	PlayerTextDrawLetterSize(playerid, Loadingscreen9[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen9[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen9[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen9[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen9[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen9[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen9[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Loadingscreen9[playerid], 1);

	Loadingscreen10[playerid] = CreatePlayerTextDraw(playerid, 372.666564, 176.296264, "vozila iz pravog zivota");
	PlayerTextDrawLetterSize(playerid, Loadingscreen10[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen10[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen10[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen10[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen10[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen10[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen10[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Loadingscreen10[playerid], 1);

	Loadingscreen11[playerid] = CreatePlayerTextDraw(playerid, 27.666666, 98.725921, "vlasnici:");
	PlayerTextDrawLetterSize(playerid, Loadingscreen11[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen11[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen11[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen11[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen11[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen11[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen11[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen11[playerid], 1);

	Loadingscreen12[playerid] = CreatePlayerTextDraw(playerid, 34.333335, 118.222229, "Savva#8002");
	PlayerTextDrawLetterSize(playerid, Loadingscreen12[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen12[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen12[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen12[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen12[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen12[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen12[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen12[playerid], 1);

	Loadingscreen13[playerid] = CreatePlayerTextDraw(playerid, 28.666658, 134.814804, "Marjan#2928");
	PlayerTextDrawLetterSize(playerid, Loadingscreen13[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen13[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen13[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen13[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen13[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen13[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen13[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen13[playerid], 1);

	Loadingscreen14[playerid] = CreatePlayerTextDraw(playerid, 26.999996, 232.296295, "Pesma:");
	PlayerTextDrawLetterSize(playerid, Loadingscreen14[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen14[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen14[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen14[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen14[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen14[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen14[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen14[playerid], 1);

	Loadingscreen15[playerid] = CreatePlayerTextDraw(playerid, 24.333326, 249.303726, "JMTRADEE - Hurrracan");
	PlayerTextDrawLetterSize(playerid, Loadingscreen15[playerid], 0.367000, 1.521185);
	PlayerTextDrawAlignment(playerid, Loadingscreen15[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen15[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen15[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen15[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen15[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen15[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Loadingscreen15[playerid], 1);

	Loadingscreen16[playerid] = CreatePlayerTextDraw(playerid, 471.333251, 234.785064, "HINT: Ne klikcite \"spawn\"");
	PlayerTextDrawLetterSize(playerid, Loadingscreen16[playerid], 0.299666, 1.583407);
	PlayerTextDrawAlignment(playerid, Loadingscreen16[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen16[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen16[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen16[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen16[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen16[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen16[playerid], 1);

	Loadingscreen17[playerid] = CreatePlayerTextDraw(playerid, 450.333648, 248.888900, "dok se ne ulogujete na server");
	PlayerTextDrawLetterSize(playerid, Loadingscreen17[playerid], 0.336666, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen17[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen17[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen17[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen17[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen17[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen17[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen17[playerid], 1);

	Loadingscreen18[playerid] = CreatePlayerTextDraw(playerid, 465.000000, 263.822052, "da ne bi ste izgubili");
	PlayerTextDrawLetterSize(playerid, Loadingscreen18[playerid], 0.418666, 1.624888);
	PlayerTextDrawAlignment(playerid, Loadingscreen18[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen18[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen18[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen18[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen18[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen18[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen18[playerid], 1);

	Loadingscreen19[playerid] = CreatePlayerTextDraw(playerid, 465.666778, 278.755493, "sve sto posedujete");
	PlayerTextDrawLetterSize(playerid, Loadingscreen19[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Loadingscreen19[playerid], 1);
	PlayerTextDrawColor(playerid, Loadingscreen19[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Loadingscreen19[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Loadingscreen19[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Loadingscreen19[playerid], 51);
	PlayerTextDrawFont(playerid, Loadingscreen19[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Loadingscreen19[playerid], 1);

	PlayerTextDrawShow(playerid, Loadingscreen0[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen1[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen2[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen3[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen4[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen5[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen6[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen7[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen8[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen9[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen10[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen11[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen12[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen13[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen14[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen15[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen16[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen17[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen18[playerid]);
	PlayerTextDrawShow(playerid, Loadingscreen19[playerid]);
}