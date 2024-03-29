/*
    SA-MP IRC Plugin v1.4.2
    Copyright � 2011 Incognito

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#if defined _irc_included
	#endinput
#endif
#define _irc_included

#include <a_samp>

// Enumerator

enum
{
	E_IRC_CONNECT_ATTEMPTS,
	E_IRC_CONNECT_DELAY,
	E_IRC_CONNECT_TIMEOUT
}

// Natives

native IRC_Connect(const server[], port, const nickname[], const realname[], const username[], bool:ssl = false, localip[] = "");
native IRC_Quit(botid, const message[] = "");
native IRC_JoinChannel(botid, const channel[], const key[] = "");
native IRC_PartChannel(botid, const channel[], const message[] = "");
native IRC_ChangeNick(botid, const nick[]);
native IRC_SetMode(botid, const target[], const mode[]);
native IRC_Say(botid, const target[], const message[]);
native IRC_Notice(botid, const target[], const message[]);
native IRC_IsUserOnChannel(botid, const channel[], const user[]);
native IRC_InviteUser(botid, const channel[], const user[]);
native IRC_KickUser(botid, const channel[], const user[], const message[] = "");
native IRC_GetUserChannelMode(botid, const channel[], const user[], dest[]);
native IRC_GetChannelUserList(botid, const channel[], dest[], maxlength = sizeof dest);
native IRC_SetChannelTopic(botid, const channel[], const topic[]);
native IRC_RequestCTCP(botid, const user[], const message[]);
native IRC_ReplyCTCP(botid, const user[], const message[]);
native IRC_SendRaw(botid, const message[]);
native IRC_CreateGroup();
native IRC_DestroyGroup(groupid);
native IRC_AddToGroup(groupid, botid);
native IRC_RemoveFromGroup(groupid, botid);
native IRC_GroupSay(groupid, const target[], const message[]);
native IRC_GroupNotice(groupid, const target[], const message[]);
native IRC_SetIntData(botid, data, value);

// Callbacks

forward IRC_OnConnect(botid, ip[], port);
forward IRC_OnDisconnect(botid, ip[], port, reason[]);
forward IRC_OnConnectAttempt(botid, ip[], port);
forward IRC_OnConnectAttemptFail(botid, ip[], port, reason[]);
forward IRC_OnJoinChannel(botid, channel[]);
forward IRC_OnLeaveChannel(botid, channel[], message[]);
forward IRC_OnKickedFromChannel(botid, channel[], oppeduser[], oppedhost[], message[]);
forward IRC_OnUserDisconnect(botid, user[], host[], message[]);
forward IRC_OnUserJoinChannel(botid, channel[], user[], host[]);
forward IRC_OnUserLeaveChannel(botid, channel[], user[], host[], message[]);
forward IRC_OnUserKickedFromChannel(botid, channel[], kickeduser[], oppeduser[], oppedhost[], message[]);
forward IRC_OnUserNickChange(botid, oldnick[], newnick[], host[]);
forward IRC_OnUserSetChannelMode(botid, channel[], user[], host[], mode[]);
forward IRC_OnUserSetChannelTopic(botid, channel[], user[], host[], topic[]);
forward IRC_OnUserSay(botid, recipient[], user[], host[], message[]);
forward IRC_OnUserNotice(botid, recipient[], user[], host[], message[]);
forward IRC_OnUserRequestCTCP(botid, user[], host[], message[]);
forward IRC_OnUserReplyCTCP(botid, user[], host[], message[]);
forward IRC_OnReceiveRaw(botid, message[]);

// Stock Functions

stock IRC_IsVoice(botid, channel[], user[])
{
	new mode[2];
	IRC_GetUserChannelMode(botid, channel, user, mode);
	switch (mode[0])
	{
		case '+', '%', '@', '&', '!', '*', '~', '.':
		{
			return 1;
		}
	}
	return 0;
}

stock IRC_IsHalfop(botid, channel[], user[])
{
	new mode[2];
	IRC_GetUserChannelMode(botid, channel, user, mode);
	switch (mode[0])
	{
		case '%', '@', '&', '!', '*', '~', '.':
		{
			return 1;
	
		}
	}
	return 0;
}

stock IRC_IsOp(botid, channel[], user[])
{
	new mode[2];
	IRC_GetUserChannelMode(botid, channel, user, mode);
	switch (mode[0])
	{
		case '@', '&', '!', '*', '~', '.':
		{
			return 1;
	
		}
	}
	return 0;
}

stock IRC_IsAdmin(botid, channel[], user[])
{
	new mode[2];
	IRC_GetUserChannelMode(botid, channel, user, mode);
	switch (mode[0])
	{
		case '&', '!', '*', '~', '.':
		{
			return 1;
	
		}
	}
	return 0;
}

stock IRC_IsOwner(botid, channel[], user[])
{
	new mode[2];
	IRC_GetUserChannelMode(botid, channel, user, mode);
	switch (mode[0])
	{
		case '~', '.':
		{
			return 1;
	
		}
	}
	return 0;
}

// Command system for users in IRC channels
// Slightly modified zcmd by Zeex

#define CHANNEL_PREFIX '#'
#define COMMAND_PREFIX '!'

#define IRCCMD:%1(%2) \
	forward irccmd_%1(%2); \
	public irccmd_%1(%2)

#define irccmd(%1,%2,%3,%4,%5,%6) \
	IRCCMD:%1(%2, %3, %4, %5, %6)

#if !defined isnull
	#define isnull(%1) \
		((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

static bool:IRC_g_OUS = false;

public OnFilterScriptInit()
{
	IRC_g_OUS = funcidx("IRC_OUS") != -1;
	if (funcidx("IRC_OnFilterScriptInit") != -1)
	{
		return CallLocalFunction("IRC_OnFilterScriptInit", "");
	}
	return 1;
}

#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit IRC_OnFilterScriptInit

forward IRC_OnFilterScriptInit();

public OnGameModeInit()
{
	IRC_g_OUS = funcidx("IRC_OUS") != -1;
	if (funcidx("IRC_OnGameModeInit") != -1)
	{
		return CallLocalFunction("IRC_OnGameModeInit", "");
	}
	return 1;
}

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit IRC_OnGameModeInit

forward IRC_OnGameModeInit();

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	if (recipient[0] == CHANNEL_PREFIX && message[0] == COMMAND_PREFIX)
	{
		new function[32], pos = 0;
		while (message[++pos] > ' ')
		{
			function[pos - 1] = tolower(message[pos]);
		} 
		format(function, sizeof(function), "irccmd_%s", function);
		while (message[pos] == ' ')
		{
			pos++;
		}
		if (!message[pos])
		{
			CallLocalFunction(function, "dssss", botid, recipient, user, host, "\1");
		}
		else
		{
			CallLocalFunction(function, "dssss", botid, recipient, user, host, message[pos]);
		}
	}
	if (IRC_g_OUS)
	{
		return CallLocalFunction("IRC_OUS", "dssss", botid, recipient, user, host, message);
	}
	return 1;
}

#if defined _ALS_IRC_OnUserSay
	#undef IRC_OnUserSay
#else
	#define _ALS_IRC_OnUserSay
#endif
#define IRC_OnUserSay IRC_OUS

forward IRC_OUS(botid, recipient[], user[], host[], message[]);
