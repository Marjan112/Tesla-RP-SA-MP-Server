#if defined H_INPUT_INCLUDED
	#endinput
#else
	#define H_INPUT_INCLUDED
#endif
#tryinclude <a_samp>
#pragma deprecated
native InputInit();

#define HID_INPUT_KEYPAD 2

forward OnPlayerSelectPlayer(playerid, targetid, event2);
forward OnPlayerKeypadInput(playerid, input[], event2);

/*      native time
native InputFromKeypad(playerid, event2, len);
native CancelInput(playerid);
*/

stock InputFromKeypad(playerid, event2, minlen, maxlen)
{
		//process init
	SetPVarInt(playerid, "hid_input_event2", event2);
	if(minlen > maxlen)
	{
		new temp = minlen;
		minlen = maxlen;
		maxlen = temp;
	}
	if(minlen <= 0 || maxlen > 16) minlen = 1;
	if(maxlen > 0 && maxlen <= 16) SetPVarInt(playerid, "hid_input_keypad_maxlen", maxlen);
	else SetPVarInt(playerid, "hid_input_keypad_maxlen", 16);
	SetPVarInt(playerid, "hid_input_keypad_minlen", minlen);
	new PlayerText:td;
   	new str[30];
	switch(GetPVarInt(playerid, "hid_input_active"))
	{
	    case HID_INPUT_KEYPAD:
	    {
	        DeletePVar(playerid, "hid_input_keypad_input");
	        PlayerTextDrawSetString(playerid, PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_input"), "-");
			return;
		}
	}
	
	    //actual init
	SetPVarInt(playerid, "hid_input_active", HID_INPUT_KEYPAD);
	
	td = CreatePlayerTextDraw(playerid, 320.000000, 90.000000, "~n~BANKOMAT~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	PlayerTextDrawAlignment(playerid, td, 2);
	PlayerTextDrawBackgroundColor(playerid, td, 255);
	PlayerTextDrawFont(playerid, td, 2);
	PlayerTextDrawLetterSize(playerid, td, 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, td, -1);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, 1);
	PlayerTextDrawSetShadow(playerid, td, 1);
	PlayerTextDrawUseBox(playerid, td, 1);
	PlayerTextDrawBoxColor(playerid, td, 150);
	PlayerTextDrawTextSize(playerid, td, 10.000000, 250.000000);
	PlayerTextDrawShow(playerid, td);
	SetPVarInt(playerid, "hid_input_keypad_td_box", _:td);

	for(new b = 0; b != 10; b++)
	{
	    switch(b)
	    {
			case 0: td = CreatePlayerTextDraw(playerid, 250.000000, 235.000000, "0");
			case 1: td = CreatePlayerTextDraw(playerid, 250.000000, 205.000000, "1");
			case 2: td = CreatePlayerTextDraw(playerid, 295.000000, 205.000000, "2");
			case 3: td = CreatePlayerTextDraw(playerid, 340.000000, 205.000000, "3");
			case 4: td = CreatePlayerTextDraw(playerid, 250.000000, 175.000000, "4");
			case 5: td = CreatePlayerTextDraw(playerid, 295.000000, 175.000000, "5");
			case 6: td = CreatePlayerTextDraw(playerid, 340.000000, 175.000000, "6");
			case 7: td = CreatePlayerTextDraw(playerid, 250.000000, 145.000000, "7");
			case 8: td = CreatePlayerTextDraw(playerid, 295.000000, 145.000000, "8");
			case 9: td = CreatePlayerTextDraw(playerid, 340.000000, 145.000000, "9");
		}
		PlayerTextDrawAlignment(playerid, td, 2);
		PlayerTextDrawBackgroundColor(playerid, td, 255);
		PlayerTextDrawFont(playerid, td, 2);
		PlayerTextDrawLetterSize(playerid, td, 0.659999, 2.599999);
		PlayerTextDrawColor(playerid, td, 0x808080FF);
		PlayerTextDrawSetOutline(playerid, td, 0);
		PlayerTextDrawSetProportional(playerid, td, 1);
		PlayerTextDrawSetShadow(playerid, td, 1);
		PlayerTextDrawUseBox(playerid, td, 1);
		PlayerTextDrawBoxColor(playerid, td, 255);
		PlayerTextDrawTextSize(playerid, td, 34.000000, 34.000000);
		PlayerTextDrawSetSelectable(playerid, td, true);
		PlayerTextDrawShow(playerid, td);
		format(str, sizeof str, "hid_input_keypad_td_%i", b);
		SetPVarInt(playerid, str, _:td);
	}

	td = CreatePlayerTextDraw(playerid, 405.000000, 165.000000, "C");
	PlayerTextDrawAlignment(playerid, td, 2);
	PlayerTextDrawBackgroundColor(playerid, td, 255);
	PlayerTextDrawFont(playerid, td, 2);
	PlayerTextDrawLetterSize(playerid, td, 1.059999, 2.599999);
	PlayerTextDrawColor(playerid, td, -16776961);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, 1);
	PlayerTextDrawSetShadow(playerid, td, 1);
	PlayerTextDrawUseBox(playerid, td, 1);
	PlayerTextDrawBoxColor(playerid, td, 255);
	PlayerTextDrawTextSize(playerid, td, 34.000000, 34.000000);
	PlayerTextDrawSetSelectable(playerid, td, true);
	PlayerTextDrawShow(playerid, td);
	SetPVarInt(playerid, "hid_input_keypad_td_clear", _:td);

	td = CreatePlayerTextDraw(playerid, 405.000000, 214.000000, "Ok");
	PlayerTextDrawAlignment(playerid, td, 2);
	PlayerTextDrawBackgroundColor(playerid, td, 255);
	PlayerTextDrawFont(playerid, td, 2);
	PlayerTextDrawLetterSize(playerid, td, 0.570000, 2.899999);
	PlayerTextDrawColor(playerid, td, 16711935);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, 1);
	PlayerTextDrawSetShadow(playerid, td, 1);
	PlayerTextDrawUseBox(playerid, td, 1);
	PlayerTextDrawBoxColor(playerid, td, 255);
	PlayerTextDrawTextSize(playerid, td, 34.000000, 34.000000);
	PlayerTextDrawSetSelectable(playerid, td, true);
	PlayerTextDrawShow(playerid, td);
	SetPVarInt(playerid, "hid_input_keypad_td_confirm", _:td);

	td = CreatePlayerTextDraw(playerid, 320.000000, 120.000000, "-");
	PlayerTextDrawAlignment(playerid, td, 2);
	PlayerTextDrawBackgroundColor(playerid, td, 255);
	PlayerTextDrawFont(playerid, td, 2);
	PlayerTextDrawLetterSize(playerid, td, 0.450000, 1.800000);
	PlayerTextDrawColor(playerid, td, -1);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, 1);
	PlayerTextDrawSetShadow(playerid, td, 1);
	PlayerTextDrawUseBox(playerid, td, 1);
	PlayerTextDrawBoxColor(playerid, td, 255);
	PlayerTextDrawTextSize(playerid, td, 420.000000, 230.000000);
	PlayerTextDrawShow(playerid, td);
	SetPVarInt(playerid, "hid_input_keypad_td_input", _:td);
	
	td = CreatePlayerTextDraw(playerid, 435.000000, 93.000000, "X");
	PlayerTextDrawAlignment(playerid, td, 2);
	PlayerTextDrawBackgroundColor(playerid, td, 255);
	PlayerTextDrawFont(playerid, td, 2);
	PlayerTextDrawLetterSize(playerid, td, 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, td, 0x707070FF);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, 1);
	PlayerTextDrawSetShadow(playerid, td, 0);
	PlayerTextDrawUseBox(playerid, td, 1);
	PlayerTextDrawBoxColor(playerid, td, 842150655);
	PlayerTextDrawTextSize(playerid, td, 11.000000, 11.000000);
	PlayerTextDrawSetSelectable(playerid, td, true);
	PlayerTextDrawShow(playerid, td);
	SetPVarInt(playerid, "hid_input_td_close", _:td);
	SelectTextDraw(playerid, 0xFFFFFFFF);
    GetPVarString(playerid, "hid_input_keypad_input", str, 16);
	    
}

stock CancelInput(playerid)
{
	switch(GetPVarInt(playerid, "hid_input_active"))
	{
	    case 0: return;
	    case HID_INPUT_KEYPAD:
	    {
	        new str[30], PlayerText:td;
	        td = PlayerText:GetPVarInt(playerid, "hid_input_td_close");
			if(_:td != 0)
			{
			    PlayerTextDrawDestroy(playerid, td);
				DeletePVar(playerid, "hid_input_td_close");
			}
			for(new c; c != 10; c++)
			{
			    format(str, sizeof str, "hid_input_keypad_td_%i", c);
			    td = PlayerText:GetPVarInt(playerid, str);
				PlayerTextDrawDestroy(playerid, td);
				DeletePVar(playerid, str);
			}
			td = PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_box");
			PlayerTextDrawDestroy(playerid, td);
			DeletePVar(playerid, "hid_input_keypad_td_box");
			td = PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_clear");
			PlayerTextDrawDestroy(playerid, td);
			DeletePVar(playerid, "hid_input_keypad_td_clear");
			td = PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_confirm");
			PlayerTextDrawDestroy(playerid, td);
			DeletePVar(playerid, "hid_input_keypad_td_confirm");
			td = PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_input");
			PlayerTextDrawDestroy(playerid, td);
			DeletePVar(playerid, "hid_input_keypad_input");
			DeletePVar(playerid, "hid_input_keypad_maxlen");
			DeletePVar(playerid, "hid_input_keypad_minlen");
			DeletePVar(playerid, "hid_input_event2");
			DeletePVar(playerid, "hid_input_active");
			CancelSelectTextDraw(playerid);
	    }
	}
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	switch(GetPVarInt(playerid, "hid_input_active"))
	{
		case HID_INPUT_KEYPAD:
		{
		    if(PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_confirm") == playertextid)
		    {
		        new str[16];
		        GetPVarString(playerid, "hid_input_keypad_input", str, 16);
				if(strlen(str) < GetPVarInt(playerid, "hid_input_keypad_minlen")) return 1;
				CallRemoteFunction("OnPlayerKeypadInput", "isi", playerid, str, GetPVarInt(playerid, "hid_input_event2"));
				CancelInput(playerid);
				return 1;
		    }
		    else if(PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_clear") == playertextid)
		    {
		        DeletePVar(playerid, "hid_input_keypad_input");
		        PlayerTextDrawSetString(playerid, PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_input"), "-");
		        return 1;
		    }
		    else if(PlayerText:GetPVarInt(playerid, "hid_input_td_close") == playertextid)
		    {
				CallRemoteFunction("OnPlayerKeypadInput", "iii", playerid, -1, GetPVarInt(playerid, "hid_input_event2"));
				CancelInput(playerid);
				return 1;
		    }
		    else
		    {
		        new str[30], PlayerText:td;
		        for(new b; b != 10; b++)
		        {
				    format(str, sizeof str, "hid_input_keypad_td_%i", b);
				    td = PlayerText:GetPVarInt(playerid, str);
				    if(td == playertextid)
				    {
				        for(new i; i != 30; i++) str[i] = '\0';
				        GetPVarString(playerid, "hid_input_keypad_input", str, 16);
				        if(strlen(str) >= GetPVarInt(playerid, "hid_input_keypad_maxlen")) return 1;
						str[strlen(str)] = b + 48;
				        SetPVarString(playerid, "hid_input_keypad_input", str);
				        td = PlayerText:GetPVarInt(playerid, "hid_input_keypad_td_input");
				        PlayerTextDrawSetString(playerid, td, str);
				        PlayerTextDrawShow(playerid, td);
						return 1;
				    }
				}
		    }
		
		}
		default: return CallLocalFunction("S@@_OnPlayerClickPlayerTextDraw", "ii", playerid, _:playertextid);
	}
	return CallLocalFunction("S@@_OnPlayerClickPlayerTextDraw", "ii", playerid, _:playertextid);
}

#if defined ALS_OnPlayerClickPlayerTextDraw
    #undef OnPlayerClickPlayerTextDraw
#else
    #define ALS_OnPlayerClickPlayerTextDraw
#endif
#define OnPlayerClickPlayerTextDraw S@@_OnPlayerClickPlayerTextDraw
forward OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(_:clickedid == 65535 && GetPVarInt(playerid, "hid_input_active") != 0)
	{
		if(GetPVarInt(playerid, "hid_input_td_close") != 0) CancelInput(playerid);
		else SelectTextDraw(playerid, 0xFFFFFFFF);
		return 1;
	}
	return CallLocalFunction("S@@_OnPlayerClickTextDraw", "ii", playerid, _:clickedid);
}

#if defined ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw S@@_OnPlayerClickTextDraw
forward OnPlayerClickTextDraw(playerid, Text:clickedid);
