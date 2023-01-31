/*----------------------------------------------------------------------------*\
					==============================
					Y Sever Includes - Player Core
					==============================
Description:
	Handles script player data.
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 (the "License"); you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the YSI player include.
	
	The Initial Developer of the Original Code is Alex "Y_Less" Cole.
	Portions created by the Initial Developer are Copyright (C) 2011
	the Initial Developer. All Rights Reserved.
	
	Contributors:
		ZeeX, koolk, JoeBullet/Google63, g_aSlice/Slice
	
	Thanks:
		JoeBullet/Google63 - Handy arbitrary ASM jump code using SCTRL.
		ZeeX - Very productive conversations.
		koolk - IsPlayerinAreaEx code.
		TheAlpha - Danish translation.
		breadfish - German translation.
		Fireburn - Dutch translation.
		yom - French translation.
		50p - Polish translation.
		Zamaroht - Spanish translation.
		Dracoblue, sintax, mabako, Xtreme, other coders - Producing other modes
			for me to strive to better.
		Pixels^ - Running XScripters where the idea was born.
		Matite - Pestering me to release it and using it.
	
	Very special thanks to:
		Thiadmer - PAWN, whose limits continue to amaze me!
		Kye/Kalcor - SA:MP.
		SA:MP Team past, present and future - SA:MP.
	
Version:
	0.1.1
Changelog:
	18/08/07:
		Made code functions remote for master interaction.
	02/05/07:
		Added YSI_ prefix to all globals.
	14/04/07:
		Added header documentation.
	13/04/07:
		First version.
Functions:
	Public:
		Player_GetPlayerLanguage - Returns the player's language.
		LoginDat_ysi_core - Saves the core data for a player.
	Core:
		Player_OnPlayerConnect - Called on connection to reset data.
		Player_Player - Sets up the player system.
		Player_OnPlayerDisconnect - Logs a player out.
	Stock:
		Player_SetPlayerLanguage - Sets a player's language.
		Player_FindShortCut - Gets a function from an entered character.
		Player_SetTag - Sets a subheading in a player's file for subsequent writes.
		Player_WriteString - Writes a string to a player's file.
		Player_WriteInt - Writes an int to a player's file.
		Player_WriteFloat - Writes a float to a player's file.
		Player_IsLoggedIn - Checks if a player is logged in.
		Player_GetID - Gets a player's unique ID.
	Static:
		Player_AddToGroup - Checks a player can join a nick group.
		Player_LoginCall - Calls the OnPlayerLogin functions.
		Player_AddUser - Adds a user to the system.
		Player_Login - Checks a player's login details.
	Inline:
		-
	API:
		-
Callbacks:
	OnPlayerLogin
	OnPlayerLogout
Definitions:
	MAX_PLAYER_SHORTCUTS - Number of chars which can be assigned a command.
	MAX_INDEX_LENGTH - Max number of digits in a user's uid (yid).
	MAX_PASSWORD_LENGTH - Max length of a password.
	INDEX_DATA_LINE_LENGTH - Length of one line in the index file.
	USER_FILE_PATH - Location of user data from scriptfiles.
Enums:
	E_PLAYER_GD - Data required by the script on a player.
	e_PLAYER_GD_FLAGS - Flags for the player.
Macros:
	-
Tags:
	e_PLAYER_GD_FLAGS - Flags for the player.
Variables:
	Global:
		-
	Static:
		YSI_g_sPlayerData - Data stored on a player.
		YSI_g_sPlayerShortcuts - Command shortcuts for each player.
Commands:
	login - Logs a player into the system.
	register - Registers a player with the system.
	groupnick - Adds a nickname to another nickname's stats.
Compile options:
	PP_ADLER32 - Use adler32 not jschash (bad idea, less secure).
	PP_SHA1 - Use SHA1 encryption.
	PP_MD5 - Use MD5 encryption.
	PP_SQLITE - Use SQLite databases to save data.
	PP_INI - Use INI files to save data.
Operators:
	-
\*----------------------------------------------------------------------------*/

forward OnPlayerLogin(playerid, uid);

forward OnPlayerLogout(playerid, uid);

#include <YSI\internal\y_version>
#include <YSI\y_master>
#include <YSI\y_debug>
#include <YSI\y_hooks>
#include <YSI\y_text>

text core[ysi_players];

//#define MAX_PLAYER_SHORTCUTS 26
#define MAX_INDEX_LENGTH                (8)
#define MAX_PASSWORD_LENGTH             (128)

#define INDEX_DATA_LINE_LENGTH          (MAX_INDEX_LENGTH + 1 + MAX_PLAYER_NAME + 1 + MAX_PASSWORD_LENGTH + 3)

#define USER_FILE_PATH                  "YSI/users/"

enum e_PLAYER_GD_FLAGS (<<= 1)
{
	e_PLAYER_GD_FLAGS_LOGIN = 1/*,
	e_PLAYER_GD_FLAGS_DISCON,
	e_PLAYER_GD_FLAGS_CHECK*/
}

enum e_PLAYER_FILE_FLAGS (<<= 1)
{
	e_PLAYER_FILE_FLAGS_LOGIN_LOAD = 1
}

enum E_PLAYER_GD
{
	e_PLAYER_GD_FLAGS:E_PLAYER_GD_FLAGS,
	E_PLAYER_GD_YID
}

enum E_PLAYER_LOADED
{
	E_PLAYER_LOADED_YID,
	E_PLAYER_LOADED_IP,
	E_PLAYER_LOADED_TIME,
	E_PLAYER_LOADED_NAME[MAX_PLAYER_NAME]
}

/*enum e_login_fail
{
	e_login_fail_none = 0,
	e_login_fail_,
	e_login_fail_none,
	e_login_fail_none
}*/

static stock
	YSI_g_sPlayerData[MAX_PLAYERS][E_PLAYER_GD],
	//YSI_g_sPlayerYID[MAX_PLAYERS] = {-1, ...},
	INI:YSI_g_sLogoutFile = INI_NO_FILE;

/*----------------------------------------------------------------------------*\
Function:
	Player_OnPlayerConnect
Params:
	playerid - Player who connected.
Return:
	-
Notes:
	Resets variables when a new player connects.  Needs to cater for the case of
	loading a new filterscript after a player is already connected, and when the
	master script has already been assigned (and hence mhook won't be called).
\*----------------------------------------------------------------------------*/

mhook OnPlayerConnect(playerid)
{
	P:2("hook Player_OnPlayerConnect called: %d", playerid);
	//if (!(YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] & e_PLAYER_GD_FLAGS_CHECK))
	//{
	//CallRemoteFunction("Player_LoginCheck", "i", playerid);
	Player_LoginCheck(playerid);
	//}
}

/*----------------------------------------------------------------------------*\
Function:
	Player_LoginCheck
Params:
	playerid - Player who connected.
Return:
	-
Notes:
	Checks if a player just left the server and if so logs them back in.
\*----------------------------------------------------------------------------*/

static stock Player_LoginCheck(playerid)
{
	//YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] |= e_PLAYER_GD_FLAGS_CHECK;
	if (YSI_g_sIsMaster)
	{
		if (YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] & e_PLAYER_GD_FLAGS_LOGIN)
		{
			CallRemoteFunction("Player_ReloginCall", "ii", playerid, YSI_g_sPlayerData[playerid][E_PLAYER_GD_YID]);
		}
		else
		{
			if (!(YSI_g_sFileFlags & e_PLAYER_FILE_FLAGS_LOGIN_LOAD))
			{
				if (INI_ParseFile(USER_FILE_PATH "logins.ysi", "Player_PlayersLoggedIn", .bLocal = true, .bPassTag = true))
				{
					fremove(USER_FILE_PATH "logins.ysi");
				}
				YSI_g_sFileFlags |= e_PLAYER_FILE_FLAGS_LOGIN_LOAD;
			}
			if (timestamp() - YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_TIME] <= 15 && GetIP(playerid) == YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_IP] && !strcmp(ReturnPlayerName(playerid), YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_NAME]))
			{
				Player_LoginCall(playerid, YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_YID], 0);
			}
		}
	}
}

public Player_PlayersLoggedIn(tag[], identifier[], text[])
{
	if (YSI_g_sIsMaster)
	{
		if (!strcmp(tag, "logged_in_", false, 10))
		{
			new
				playerid = strval(tag[10]);
			if (playerid >= 0 && playerid < MAX_PLAYERS)
			{
				if (!strcmp(identifier, "IP"))
				{
					YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_IP] = strval(text);
				}
				else if (!strcmp(identifier, "name"))
				{
					strcpy(YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_NAME], text, MAX_PLAYER_NAME);
				}
				else if (!strcmp(identifier, "time"))
				{
					YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_TIME] = strval(text);
				}
				else if (!strcmp(identifier, "yid"))
				{
					YSI_g_sLoadedData[playerid][E_PLAYER_LOADED_YID] = strval(text);
				}
			}
		}
	}
}

/*----------------------------------------------------------------------------*\
Function:
	Player_IsLoggedIn
Params:
	playerid - Player to check.
Return:
	-
Notes:
	-
\*----------------------------------------------------------------------------*/

foreign bool:Player_IsLoggedIn(playerid);

global bool:Player_IsLoggedIn(playerid)
{
	P:2("bool:Player_IsLoggedIn called: %i", playerid);
	if (0 <= playerid < MAX_PLAYERS)
	{
		return YSI_g_sPlayerData[playerid][E_PLAYER_GD_YID] != -1;
	}
	return false;
}

/*----------------------------------------------------------------------------*\
Function:
	Player_GetID
Params:
	playerid - Player to get YID for.
Return:
	-
Notes:
	-
\*----------------------------------------------------------------------------*/

foreign Player_GetID(playerid);

global Player_GetID(playerid)
{
	P:2("Player_GetID called: %i", playerid);
	if (0 <= playerid < MAX_PLAYERS)
	{
		return YSI_g_sPlayerData[playerid][E_PLAYER_GD_YID];
	}
	return -1;
}

hook OnPlayerLogin(playerid, uid)
{
	P:2("ALS OnPlayerLogin called: %d, %d", playerid, uid);
	YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] |= e_PLAYER_GD_FLAGS_LOGIN;
	YSI_g_sPlayerData[playerid][E_PLAYER_GD_YID] = uid;
}

/*#if defined _ALS_OnPlayerLogin
	#undef OnPlayerLogin
#else
	#define _ALS_OnPlayerLogin
#endif
#define OnPlayerLogin*/

/*----------------------------------------------------------------------------*\
Function:
	Player_OnPlayerDisconnect
Params:
	playerid - Player who disconnected.
	reason - Why they left.
Return:
	-
Notes:
	Called last to save a player's stats.
\*----------------------------------------------------------------------------*/

mhook OnPlayerDisconnect(playerid, reason)
{
	P:2("ALS OnPlayerDisconnect called: %d, %d", playerid, reason);
	if (YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] & e_PLAYER_GD_FLAGS_LOGIN)
	{
		new
			filename[128],
			yid = YSI_g_sPlayerData[playerid][E_PLAYER_GD_YID];
		/*#if defined _YSI_SETUP_MASTER
			if (YSI_g_sIsMaster)
			{*/
		new
			INI:logins = INI_Open(USER_FILE_PATH "logins.ysi");
		if (logins != INI_NO_FILE)
		{
			format(filename, sizeof (filename), "logged_in_%d", playerid);
			INI_SetTag(logins, filename);
			new
				ip = GetIP(playerid);
			INI_WriteInt(logins, "IP", ip);
			INI_WriteString(logins, "name", ReturnPlayerName(playerid));
			INI_WriteInt(logins, "time", getdate());
			INI_WriteInt(logins, "yid", yid);
			INI_Close(logins);
		}
		/*	}
		#endif*/
		format(filename, sizeof (filename), USER_FILE_PATH "%0" #MAX_INDEX_LENGTH "d.INI", yid);
		YSI_g_sLogoutFile = INI_Open(filename);
		if (YSI_g_sLogoutFile != INI_NO_FILE)
		{
			// Core data.
			//INI_SetTag(YSI_g_sLogoutFile, "ysi_core");
			// Alternate names.
			INI_SetTag(YSI_g_sLogoutFile, "ysi_names");
			INI_WriteString(YSI_g_sLogoutFile, ReturnPlayerName(playerid), "name");
			// Blank the current tag.
			INI_SetTag(YSI_g_sLogoutFile, "");
			CallRemoteFunction("OnPlayerLogout", "ii", playerid, yid);
			INI_Close(YSI_g_sLogoutFile);
		}
	}
	YSI_g_sLogoutFile = INI_NO_FILE;
	YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] = e_PLAYER_GD_FLAGS:0;
	YSI_g_sPlayerData[playerid][E_PLAYER_GD_YID] = -1;
}

/*----------------------------------------------------------------------------*\
Function:
	Player_WriteString
Params:
	name[] - Data name.
	data[] - String data.
Return:
	-
Notes:
	Wrapper for INI_WriteString.  Uses the internal ini pointer, designed for
	future seamless database migration.
\*----------------------------------------------------------------------------*/

foreign Player_WriteString(name[], data[]);

global Player_WriteString(name[], data[])
{
	P:2("Player_WriteString called: \"%s\", \"%s\"", name, data);
	INI_WriteString(YSI_g_sLogoutFile, name, data);
}

/*----------------------------------------------------------------------------*\
Function:
	Player_WriteInt
Params:
	name[] - Data name.
	data - Integer data.
Return:
	-
Notes:
	Wrapper for INI_WriteInt.  Uses the internal ini pointer, designed for
	future seamless database migration.
\*----------------------------------------------------------------------------*/

foreign Player_WriteInt(string:name[], data);

global Player_WriteInt(string:name[], data)
{
	P:2("Player_WriteInt called: \"%s\", %i", name, data);
	INI_WriteInt(YSI_g_sLogoutFile, name, data);
}

foreign Player_WriteHex(string:name[], data);

global Player_WriteHex(string:name[], data)
{
	INI_WriteHex(YSI_g_sLogoutFile, name, data);
}

foreign Player_WriteBin(string:name[], data);

global Player_WriteBin(string:name[], data)
{
	INI_WriteBin(YSI_g_sLogoutFile, name, data);
}

foreign Player_WriteBool(string:name[], bool:data);

global Player_WriteBool(string:name[], bool:data)
{
	INI_WriteBool(YSI_g_sLogoutFile, name, data);
}

/*----------------------------------------------------------------------------*\
Function:
	Player_WriteFloat
Params:
	name[] - Data name.
	Float:data - Float data.
	accuracy - number of decimal places to write.
Return:
	-
Notes:
	Wrapper for INI_WriteFloat.  Uses the internal ini pointer, designed for
	future seamless database migration.
\*----------------------------------------------------------------------------*/

stock Player_WriteFloat(string:name[], Float:data, accuracy = 6)
{
	P:3("Player_WriteFloat called: \"%s\", %i, %i", name, data, accuracy);
	Player_WriteFloatInt(name, data, accuracy);
}

foreign Player_WriteFloatInt(string:name[], Float:data, accuracy);

global Player_WriteFloatInt(string:name[], Float:data, accuracy)
{
	INI_WriteFloat(YSI_g_sLogoutFile, name, data, accuracy);
}

/*----------------------------------------------------------------------------*\
Function:
	Player_SetTag
Params:
	tag[] - Tag to add subsequent data to.
Return:
	-
Notes:
	Wrapper for INI_SetTag.  Uses the internal ini pointer, designed for
	future seamless database migration.
\*----------------------------------------------------------------------------*/

foreign Player_SetTag(string:tag[]);

global Player_SetTag(string:tag[])
{
	P:2("Player_SetTag called: \"%s\"", tag);
	INI_SetTag(YSI_g_sLogoutFile, tag);
}

/*----------------------------------------------------------------------------*\
Function:
	Player_AddToGroup
Params:
	playerid - Player to add.
	password[] - Entered password.
	group[] - Group to add the player to.
	reg - Registering for the first time.
Return:
	-
Notes:
	Adds a player to a registed nick group (like "ns group" on IRC), not to an
	internal group.  If reg is 1 then they are trying to register a new group.
	
	Verifies that the data is valid for the required action.  Uses multiple
	index files (one master for current user count and 28 others for grouping
	nicknames by start letter) for fast searching of usernames.
\*----------------------------------------------------------------------------*/

static stock Player_AddToGroup(playerid, password[], group[] = "", reg = 1)
{
	P:4("Player_AddToGroup called: %i, \"%s\", \"%s\", %i", playerid, password, group, reg);
	new
		name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof (name));
	new
		namelen = strlen(name),
		grouplen = strlen(group),
		filename[] = USER_FILE_PATH "ind_X.YSI",
		File:fIndex,
		ch = group[0],
		uid = -1;
	if (!ch) ch = name[0];
	filename[sizeof (filename) - 6] = ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) ? (ch | 0x20) : ((ch >= '0' && ch <= '9') ? ('0') : ('_'));
	fIndex = fopen(filename, io_read);
	if (fIndex)
	{
		new
			line[53];
		while (fread(fIndex, line))
		{
			new
				len = strlen(line);
			if (len != INDEX_DATA_LINE_LENGTH && len != INDEX_DATA_LINE_LENGTH + 1) continue;
			if (!strcmp(line[MAX_INDEX_LENGTH + 1], name, false, namelen) && line[MAX_INDEX_LENGTH + 1 + namelen] == ' ')
			{
				Text_Send(playerid, YSI_REG_TAKEN);
				fclose(fIndex);
				return 0;
			}
			else if (!reg && !strcmp(line[MAX_INDEX_LENGTH + 1], group, false, grouplen) && line[MAX_INDEX_LENGTH + 1 + namelen] == ' ')
			{
				new
					ret;
				if (!strcmp(line[MAX_INDEX_LENGTH + 1 + MAX_PLAYER_NAME + 1], password, false, MAX_PASSWORD_LENGTH))
				{
					line[MAX_INDEX_LENGTH] = '\0';
					uid = strval(line);
					if (Player_AddUser(playerid, name, password, uid)) ret = Player_LoginCall(playerid, uid);
				}
				else Text_Send(playerid, YSI_LOGIN_WRONG);
				fclose(fIndex);
				return ret;
			}
		}
		fclose(fIndex);
		if (Player_AddUser(playerid, name, password, uid)) return Player_LoginCall(playerid, uid);
	}
	else if (fexist(filename)) Text_Send(playerid, YSI_LOGIN_INDERR);
	else if (Player_AddUser(playerid, name, password, uid)) return Player_LoginCall(playerid, uid);
	return 0;
}

/*----------------------------------------------------------------------------*\
Function:
	Player_IsRegistered
Params:
	playerid - Player to check.
	&yid - Return for their ID.
Return:
	-
Notes:
	Check if a player's name is registered.
\*----------------------------------------------------------------------------*/

stock Player_IsRegistered(playerid, &yid = -1)
{
	P:3("Player_IsRegistered called: %i, %i", playerid, yid);
	new
		name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof (name));
	new
		namelen = strlen(name),
		filename[] = USER_FILE_PATH "ind_X.YSI",
		File:fIndex,
		uid = -1,
		ch = name[0];
	filename[sizeof (filename) - 6] = ('a' <= (ch | 0x20) <= 'z') ? (ch | 0x20) : (('0' <= ch <= '9') ? ('0') : ('_'));
	fIndex = fopen(filename, io_read);
	if (fIndex)
	{
		new
			line[53];
		while (fread(fIndex, line))
		{
			new
				len = strlen(line);
			if (len != INDEX_DATA_LINE_LENGTH && len != INDEX_DATA_LINE_LENGTH + 1) continue;
			if (!strcmp(line[MAX_INDEX_LENGTH + 1], name, false, namelen) && line[MAX_INDEX_LENGTH + 1 + namelen] == ' ')
			{
				yid = strval(line);
				fclose(fIndex);
				return 1;
			}
		}
		fclose(fIndex);
	}
	yid = -1;
	return 0;
}

/*----------------------------------------------------------------------------*\
Function:
	Player_LoginCall
Params:
	playerid - Player who's logged in.
	uid - Unique identifier for this player.
	text - Wether to display the messages (for invisible relogins).
Return:
	-
Notes:
	Calls OnPlayerLogin and parses data if required.  If the password is wrong
	their data is never even loaded.
\*----------------------------------------------------------------------------*/

static stock Player_LoginCall(playerid, uid, text = 1)
{
	if (CallRemoteFunction("OnPlayerLogin", "ii", playerid, uid))
	{
		new
			line[128];
		format(line, sizeof (line), USER_FILE_PATH "%0" #MAX_INDEX_LENGTH "d.INI", uid);
		if (INI_ParseFile(line, "LoginDat_%s", false, true, playerid))
		{
			if (text) Text_Send(playerid, YSI_LOGIN_LOGIN);
			return 1;
		}
		else if (text) Text_Send(playerid, YSI_LOGIN_NOLOAD);
	}
	else if (text) Text_Send(playerid, YSI_LOGIN_FAILED);
	return 0;
}

#if defined _YSI_SETUP_MASTER
	/*----------------------------------------------------------------------------*\
	Function:
		Player_ReloginCall
	Params:
		playerid - Player who's logged in.
		uid - Unique identifier for this player.
	Return:
		-
	Notes:
		Called to log a player back in on GMX.
	\*----------------------------------------------------------------------------*/
	
	public Player_ReloginCall(playerid, uid)
	{
		if (!(YSI_g_sPlayerData[playerid][E_PLAYER_GD_FLAGS] & e_PLAYER_GD_FLAGS_LOGIN))
		{
			if (CallLocalFunction("OnPlayerLogin", "ii", playerid, uid))
			{
				new
					line[128];
				format(line, sizeof (line), USER_FILE_PATH "%0" #MAX_INDEX_LENGTH "d.INI", uid);
				if (INI_ParseFile(line, "LoginDat_%s", false, true, playerid, true))
				{
					return 1;
				}
			}
		}
		return 0;
	}
#endif

/*----------------------------------------------------------------------------*\
Function:
	Player_AddUser
Params:
	playerid - Player who is adding a user.
	name[] - Name of the user being added.
	password[] - Password of the user.
	&uid - Unique identifer.
Return:
	-
Notes:
	Creates the files for a registerd user.  If uid is -1 a new set of data
	is created and the new uid returned.  Otherwise the data is added to the
	specified uid group.
\*----------------------------------------------------------------------------*/

static stock Player_AddUser(playerid, name[], password[], &uid)
{
	P:4("Player_AddUser called: %i, \"%s\", \"%s\", %i", playerid, name, password, uid);
	//P:2("Player_AddUser() start %d", uid);
	new
		File:index = fopen(USER_FILE_PATH "index.YSI", io_read)/*,
		w = 0*/;
	if (uid == -1)
	{
		//w = 1;
		if (index)
		{
			new
				line[54];
			fread(index, line);
			if (line[0]) uid = strval(line);
			fclose(index);
			P:4("Player_AddUser() write");
			fremove(USER_FILE_PATH "index.YSI");
			index = fopen(USER_FILE_PATH "index.YSI", io_write);
			if (index)
			{
				new
					count[MAX_INDEX_LENGTH + 3];
				format(count, sizeof (count), "%d", uid + 1);
				fwrite(index, count);
				fclose(index);
			}
		}
		else if (fexist(USER_FILE_PATH "index.YSI"))
		{
			Text_Send(playerid, YSI_ADDU_INDER1);
			return 0;
		}
		else
		{
			uid = 0;
		}
	}
	//P:4("Player_AddUser() uid %d %d", uid, w);
	new
		filename[] = USER_FILE_PATH "ind_X.YSI",
		ch = name[0];
	filename[sizeof (filename) - 6] = ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) ? (ch | 0x20) : ((ch >= '0' && ch <= '9') ? ('0') : ('_'));
	index = fopen(filename, io_append);
	P:4("Player_AddUser() file: \"%s\"", filename);
	if (!index)
	{
		Text_Send(playerid, YSI_ADDU_INDER2);
		return 0;
	}
	else
	{
		P:4("Player_AddUser() opened");
		// Add the player to the list of player IDs.
		new
			line[INDEX_DATA_LINE_LENGTH + 3];
		format(line, sizeof (line), "%0" #MAX_INDEX_LENGTH "d %" #MAX_PLAYER_NAME "s %" #MAX_PASSWORD_LENGTH "s" INI_NEW_LINE, uid, name, password);
		fwrite(index, line);
		fclose(index);
		// Touch the player's data file.
		format(line, sizeof (line), USER_FILE_PATH "%0" #MAX_INDEX_LENGTH "d.ini", uid);
		index = fopen(filename, io_append);
		if (index) fclose(index);
	}
	/*P:4("Player_AddUser() closed %d", w);
	if (w)
	{
		P:4("Player_AddUser() write");
		fremove(USER_FILE_PATH "index.YSI");
		index = fopen(USER_FILE_PATH "index.YSI", io_write);
		if (index)
		{
			new
				count[MAX_INDEX_LENGTH + 3];
			format(count, sizeof (count), "%d", uid + 1);
			fwrite(index, count);
			fclose(index);
		}
	}*/
	Text_Send(playerid, YSI_ADDU_SUCC);
	return 1;
}

/*----------------------------------------------------------------------------*\
Function:
	Player_Login
Params:
	playerid - Player who is logging in.
	password[] - Hashed password they entered.
Return:
	-
Notes:
	Checks a player's login data is valid and logs them in if so.  Password
	should be hashed BEFORE this function is called.
\*----------------------------------------------------------------------------*/

foreign Player_Login(playerid, string:password[]);

global Player_Login(playerid, string:password[])
{
	P:2("Player_Login called: %i, \"%s\"", playerid, password);
	new
		name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof (name));
	//format(name, sizeof (name), "%" #MAX_PLAYER_NAME "s", name);
	new
		namelen = strlen(name),
		filename[] = USER_FILE_PATH "ind_X.YSI",
		File:fIndex,
		ch = name[0];
	filename[sizeof (filename) - 6] = ('a' <= (ch | 0x20) <= 'z') ? (ch | 0x20) : (('0' <= ch <= '9') ? ('0') : ('_'));
	fIndex = fopen(filename, io_read);
	if (fIndex)
	{
		new
			line[54];
		while (fread(fIndex, line))
		{
			new
				len = strlen(line);
			if (len != INDEX_DATA_LINE_LENGTH && len != INDEX_DATA_LINE_LENGTH + 1) continue;
			if (!strcmp(line[MAX_INDEX_LENGTH + 1], name, false, namelen) && line[MAX_INDEX_LENGTH + 1 + namelen] == ' ')
			{
				new
					ret;
				if (!strcmp(line[MAX_INDEX_LENGTH + 1 + MAX_PLAYER_NAME + 1], password, false, MAX_PASSWORD_LENGTH))
				{
					line[MAX_INDEX_LENGTH] = '\0';
					ret = Player_LoginCall(playerid, strval(line));
				}
				else Text_Send(playerid, YSI_LOGIN_WRONG);
				fclose(fIndex);
				return ret;
			}
		}
		Text_Send(playerid, YSI_LOGIN_NOTF);
		fclose(fIndex);
	}
	else Text_Send(playerid, YSI_LOGIN_INDERR);
	return 0;
}

/*----------------------------------------------------------------------------*\
Function:
	LoginDat_ysi_core
Params:
	playerid - Player who is recieving data.
	identifier[] - Name of data loaded.
	text[] - Data loaded.
Return:
	-
Notes:
	Parses the data under [ysi_core] in a player's user file when they login.
\*----------------------------------------------------------------------------*/

/*public LoginDat_ysi_core(playerid, identifier[], text[])
{
	#if defined _YSI_SETUP_MASTER
		if (YSI_g_sIsMaster)
	#endif
	{
		#if defined _YSI_SYSTEM_GROUPS
			if (!strcmp(identifier, "groups"))
			{
				new
					groups = strval(text),
					bit = 1,
					group;
				while (groups)
				{
					if (groups & bit) Group_AddPlayer(group, playerid);
					groups &= ~bit;
					bit <<= 1;
					group++;
				}
				return;
			}
		#endif
		#if defined _YSI_CORE_LANGUAGES
			if (!strcmp(identifier, "language"))
			{
				YSI_g_sPlayerData[playerid][E_PLAYER_GD_LANGUAGE] = Language:strval(text);
				return;
			}
		#endif
		#if defined _YSI_CORE_COMMANDS
			if (!strcmp(identifier, "command_", false, 8))
			{
				new
					comm = (identifier[8] | 0x20) - 'a';
				if (comm >= 0 && comm < MAX_PLAYER_SHORTCUTS) strcpy(YSI_g_sPlayerShortcuts[playerid][comm], text, MAX_COMMAND_LENGTH);
				return;
			}
		#endif
		#if defined _YSI_GAMEMODE_PROPERTIES
			if (!strcmp(identifier, "wslot", false, 5))
			{
				Property_SavePlayerWeapon(playerid, strval(identifier[5]), strval(text));
				return;
			}
			if (!strcmp(identifier, "bank", false, 4))
			{
				Property_Bank(playerid, strval(text));
				return;
			}
		#endif
	}
}*/

#if defined _YSI_CORE_LANGUAGES && 0

/*----------------------------------------------------------------------------*\
Function:
	Language:Player_GetPlayerLanguage
Params:
	playerid - Player to get language for
Return:
	playerid's language.
Notes:
	-
\*----------------------------------------------------------------------------*/

Language:Player_GetPlayerLanguage(playerid)
{
	return YSI_g_sPlayerData[playerid][E_PLAYER_GD_LANGUAGE];
}

/*----------------------------------------------------------------------------*\
Function:
	Player_SetPlayerLanguage
Params:
	playerid - Player to set language for
	Language:languageID - Language to set
Return:
	-
Notes:
	-
\*----------------------------------------------------------------------------*/

stock Player_SetPlayerLanguage(playerid, Language:languageID)
{
	P:3("Player_SetPlayerLanguage called: %i, %i", playerid, _:languageID);
	YSI_g_sPlayerData[playerid][E_PLAYER_GD_LANGUAGE] = languageID;
}

#endif

/*----------------------------------------------------------------------------*\
Function:
	Player_HashPass
Params:
	pass[] - Data to hash.
Return:
	-
Notes:
	Based on my Dad's hash system but slightly modifed.  Updated for reverse
	compatability with other login systems.  Needs more code for Whirlpool.
\*----------------------------------------------------------------------------*/

stock Player_HashPass(pass[])
{
	#if defined PP_ADLER32
		new
			s1 = 1,
			s2 = 0,
			i,
			You_REALLY_shouldnt_use_Adler32;
		while (pass[i])
		{
			s1 = (s1 + pass[i++]) % 65521;
			s2 = (s2 + s1) % 65521;
		}
		new
			target[MAX_PASSWORD_LENGTH + 1];
		format(target, sizeof (target), "%" #MAX_PASSWORD_LENGTH "d", (s2 << 16) + s1);
		return target;
	#elseif defined PP_MD5 && defined MD5_Hash
		new
			You_REALLY_shouldnt_use_MD5;
		return MD5_Hash(pass, strlen(pass));
	#elseif defined PP_SHA1
		#error SHA1 unsupported.
	#elseif defined PP_YSI
		static
			charset[] = "A,UbRgdnS#|rT_%5+ZvEK¬NF<9¦IH[(C)2O07 Y-Less]$Qw^?/om4;@'8k£Pp.c{&l\\3zay>DfxV:WXjuG6*!1\"i~=Mh`JB}qt",
			css = 99;
		new
			target[MAX_PASSWORD_LENGTH + 1],
			j = strlen(pass),
			sum = j,
			tmp = 0,
			i,
			mod;
		for (i = 0; i < MAX_PASSWORD_LENGTH || i < j; i++)
		{
			mod = i % MAX_PASSWORD_LENGTH;
			tmp = (i >= j) ? charset[(7 * i) % css] : pass[i];
			sum = (sum + chrfind(tmp, charset) + 1) % css;
			target[mod] = charset[(sum + target[mod]) % css];
		}
		target[MAX_PASSWORD_LENGTH] = '\0';
		return target;
	#elseif defined WP_Hash
	#else
		#error Whirlpool (or other) hash not found.
	#endif
}
