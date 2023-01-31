// The new y_player library.

#include <YSI\y_remote>
#include <YSI\y_master>




new
	YSI_g_sPlayerIndexFile;

#define Player_GetIndexFile(%0,%1) ((YSI_g_sPlayerIndexFile=%1[0]),%0[sizeof(%0)-6]=(('a'<=(YSI_g_sPlayerIndexFile|0x20)<='z')?(YSI_g_sPlayerIndexFile|0x20):(('0'<=YSI_g_sPlayerIndexFile<='9')?('0'):('_'))))

/*----------------------------------------------------------------------------*\
Function:
	Player_TryLogin
Params:
	playerid - Player who is logging in.
	password[] - Password they entered.
Return:
	-
Notes:
	Tries to log in a player - hashes and checks their password and if it's
	right calls the core login code.
\*----------------------------------------------------------------------------*/

foreign Player_TryLogin(playerid, password[]);

global Player_TryLogin(playerid, password[])
{
	// First, find the player's file.  This should be the ONLY place where the
	// password is to be loaded.
	new
		name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof (name));
	//format(name, sizeof (name), "%" #MAX_PLAYER_NAME "s", name);
	new
		namelen = strlen(name),
		filename[] = USER_FILE_PATH "ind_X.YSI",
		File:fIndex;
	Player_GetIndexFile(filename, name);
	fIndex = fopen(filename, io_read);
	if (fIndex)
	{
		new
			line[INDEX_DATA_LINE_LENGTH];
		while (fread(fIndex, line))
		{
			new
				len = strlen(line);
			// Check if the line is the right length (could be one of three
			// lengths depending on newlines).  Skip blanks.
			if (len < INDEX_DATA_LINE_LENGTH - 3)
			{
				continue;
			}
			// Check the name on the line.
			if (!strcmp(line[MAX_INDEX_LENGTH + 1], name, false, namelen) && line[MAX_INDEX_LENGTH + 1 + namelen] == ' ')
			{
				// Found the section on this one player.
				new
					ret,
					hash[MAX_PASSWORD_LENGTH + 1];
				Player_HashPass(password, hash);
				// Check that the hashed passwords are the same.
				if (!strcmp(line[MAX_INDEX_LENGTH + 1 + MAX_PLAYER_NAME + 1], hash, false, MAX_PASSWORD_LENGTH))
				{
					// Extract the yid and call in to the login code.
					line[MAX_INDEX_LENGTH] = '\0';
					broadcast Player_DoLogin(playerid, strval(line));
				}
				else
				{
					Text_Send(playerid, YSI_LOGIN_WRONG);
				}
				fclose(fIndex);
				return;
			}
		}
		Text_Send(playerid, YSI_LOGIN_NOTF);
		fclose(fIndex);
	}
	else
	{
		Text_Send(playerid, YSI_LOGIN_INDERR);
	}
	//return 0;
}

remote Player_DoLogin(playerid, yid)
{
	// Called when a player logs in - either locally (new script) or globally
	// (actually only just logged in).
}

global Player_TryRegister(playerid, password[])
{
	// First, find the player's file.  This should be the ONLY place where the
	// password is to be loaded.
	new
		name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof (name));
	//format(name, sizeof (name), "%" #MAX_PLAYER_NAME "s", name);
	new
		namelen = strlen(name),
		filename[] = USER_FILE_PATH "ind_X.YSI",
		File:fIndex;
	Player_GetIndexFile(filename, name);
	fIndex = fopen(filename, io_read);
	if (fIndex)
	{
		new
			line[INDEX_DATA_LINE_LENGTH];
		while (fread(fIndex, line))
		{
			new
				len = strlen(line);
			// Check if the line is the right length (could be one of three
			// lengths depending on newlines).  Skip blanks.
			if (len < INDEX_DATA_LINE_LENGTH - 3)
			{
				continue;
			}
			// Check the name on the line.
			if (!strcmp(line[MAX_INDEX_LENGTH + 1], name, false, namelen) && line[MAX_INDEX_LENGTH + 1 + namelen] == ' ')
			{
				// Found the section on this one player.
				new
					ret,
					hash[MAX_PASSWORD_LENGTH + 1];
				Player_HashPass(password, hash);
				// Check that the hashed passwords are the same.
				if (!strcmp(line[MAX_INDEX_LENGTH + 1 + MAX_PLAYER_NAME + 1], hash, false, MAX_PASSWORD_LENGTH))
				{
					// Extract the yid and call in to the login code.
					line[MAX_INDEX_LENGTH] = '\0';
					broadcast Player_DoLogin(playerid, strval(line));
				}
				else
				{
					Text_Send(playerid, YSI_LOGIN_WRONG);
				}
				fclose(fIndex);
				return;
			}
		}
		Text_Send(playerid, YSI_LOGIN_NOTF);
		fclose(fIndex);
	}
	else
	{
		Text_Send(playerid, YSI_LOGIN_INDERR);
	}
}








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

static stock Player_HashPass(pass[], target[])
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
		//new
		//	target[MAX_PASSWORD_LENGTH + 1];
		format(target, sizeof (target), "%" #MAX_PASSWORD_LENGTH "d", (s2 << 16) + s1);
		//return target;
	#elseif defined PP_MD5 && defined MD5_Hash
		new
			You_REALLY_shouldnt_use_MD5;
		strcpy(target, MD5_Hash(pass, strlen(pass)));
	#elseif defined PP_SHA1
		#error SHA1 unsupported.
	#elseif defined PP_YSI
		static
			charset[] = "A,UbRgdnS#|rT_%5+ZvEK¬NF<9¦IH[(C)2O07 Y-Less]$Qw^?/om4;@'8k£Pp.c{&l\\3zay>DfxV:WXjuG6*!1\"i~=Mh`JB}qt",
			css = 99;
		new
			//target[MAX_PASSWORD_LENGTH + 1],
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
		//return target;
	#elseif defined WP_Hash
	#else
		#error Whirlpool (or other) hash not found.
	#endif
}

#if defined _YSIM_MANUAL_SET
	#define YSI_GROUPS_LAST 20
	#include <YSI\internal\y_grouprevert>
#else
	#define MASTER 23
	#include <YSI\y_master>
#endif
