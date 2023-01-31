#if defined _xcmd_included
	#endinput
#endif
#define _xcmd_included

#define MAX_FUNC_NAME (32)

#define X_COMMAND:%1(%2)          \
			forward x_cmd_%1(%2); \
			public x_cmd_%1(%2)

#define X_CMD:%1(%2) \
			X_COMMAND:%1(%2)

#define x_command(%1,%2,%3) \
			X_COMMAND:%1(%2, %3)

#define x_cmd(%1,%2,%3) \
			X_COMMAND:%1(%2, %3)

#if !defined isnull
	#define isnull(%1) \
				((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif


forward OnPlayerCommandReceived(playerid, cmdtext[]);
forward OnPlayerCommandPerformed(playerid, cmdtext[], success);


static
	bool:xcmd_g_HasOPCS = false,
	bool:xcmd_g_HasOPCE = false;

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	xcmd_g_HasOPCS = funcidx("OnPlayerCommandReceived") != -1;
	xcmd_g_HasOPCE = funcidx("OnPlayerCommandPerformed") != -1;
    return CallLocalFunction("xcmd_OnFilterScriptInit", "");
}

#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit xcmd_OnFilterScriptInit
forward xcmd_OnFilterScriptInit();

#else /*not a filterscript*/

public OnGameModeInit()
{
	xcmd_g_HasOPCS = funcidx("OnPlayerCommandReceived") != -1;
	xcmd_g_HasOPCE = funcidx("OnPlayerCommandPerformed") != -1;
	if (funcidx("xcmd_OnGameModeInit") != -1)
	{
		return CallLocalFunction("xcmd_OnGameModeInit", "");
	}
	return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit xcmd_OnGameModeInit
forward xcmd_OnGameModeInit();

#endif /*if defined FILTERSCRIPT*/

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (xcmd_g_HasOPCS && !CallLocalFunction("OnPlayerCommandReceived", "is", playerid, cmdtext))
    {
        return 1;
    }
    new
        pos,
        funcname[MAX_FUNC_NAME];
    while (cmdtext[++pos] > ' ')
	{
		funcname[pos-1] = tolower(cmdtext[pos]);
	}
	format(funcname, sizeof(funcname), "x_cmd_%s", funcname);
    while (cmdtext[pos] == ' ') pos++;
	if (!cmdtext[pos])
	{
		if (xcmd_g_HasOPCE)
		{
			return CallLocalFunction("OnPlayerCommandPerformed", "isi", playerid, cmdtext, CallLocalFunction(funcname, "is", playerid, "\1"));
		}
		return CallLocalFunction(funcname, "is", playerid, "\1");
	}
	if (xcmd_g_HasOPCE)
	{
		return CallLocalFunction("OnPlayerCommandPerformed", "isi", playerid, cmdtext, CallLocalFunction(funcname, "is", playerid, cmdtext[pos]));
	}
	return CallLocalFunction(funcname, "is", playerid, cmdtext[pos]);
}

#if defined _ALS_OnPlayerCommandText
    #undef OnPlayerCommandText
#else
    #define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText xcmd_OnPlayerCommandText
forward xcmd_OnPlayerCommandText(playerid, cmdtext[]);