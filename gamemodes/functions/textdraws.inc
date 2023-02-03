#if defined _textdraws_included
    #endinput
#endif
#define _textdraws_included

#pragma library Textdraws

#if !defined _samp_included
    #tryinclude <a_samp>
#endif

#include "../gamemodes/data/tags.inc"

new Text: sdtd[3];

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