/*----------------------------------------------------------------------------*\
					===========================
					Y Sever Includes - INI Core
					===========================
Description:
	Reads the INI and also exports a number of functions to other "classes" for
	easy reading of data files there.
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
	
	The Original Code is the YSI ini include.
	
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
	1.0
Changelog:
	08/09/10:
		Started adding sscanf and file plugin compatibility.
		Added tagless data at the start of a file (dini compatible).
		Added new INI:file[tag]() syntax.
		Added options to default file load.
		Fixed bugs in default file load configuration.
		Modified to be stand alone.
	20/02/08:
		Added INI_RemoveEntry.
	18/08/07:
		Fixed bug reading identifiers starting with a tag (i.e. names).
		Added local file reading for non-serverwide broadcasting.
		Added tag passing instead of tag based functions option.
		Increased default pool size.
	30/07/07:
		Added auto creation of non-existant files.
	13/07/07:
		Fixed INI writing to actually work.
		Added support for blank lines in INIs decently and quickly.
	25/06/07:
		Altered file write options to use lists.
		Added buffer overwriting for updating values.
	24/06/07:
		Added file write options.
	21/06/07:
		Added INI_NEW_LINE for future writing functions.
	20/06/07:
		Added support for an optional parameter in broadcast data.
	15/04/07:
		Updated for more whitespaces.
		Added INI comment code.
		Added support for value-less entries.
		Modified entry extraction to use end of name location parameter.
		Removed INI_GetTagName, now done via INI_GetEntryName.
	14/04/07:
		Updated header documentation with more than changelog.
	24/03/07:
		First version.
Functions:
	Public:
		-
	Core:
		-
	Stock:
		INI_Load - Loads an INI file using standard features.
		INI_ParseFile - Loads a file as an ini and distributes data.
		INI_GetEntryName - Gets the name of an INI item.
		INI_GetEntryText - Gets the value of an INI item.
		INI_Open - Opens an INI for writing.
		INI_Close - Closes an INI being written to.
		INI_SetTag - Sets a subheading in an INI fo subsequent writes.
		INI_WriteString - Writes a string to an INI.
		INI_WriteInt - Writes an int to an INI.
		INI_WriteFloat - Writes a float to an INI.
		INI_WriteHex - Writes a hex to an INI.
		INI_WriteBin - Writes a binary to an INI.
		INI_WriteBool - Writes a boolean to an INI.
		INI_RemoveEntry - Remove an entry from a file.
	Static:
		INI_WriteBuffer - Writes an INI's buffer to the file.
		INI_AddToBuffer - Adds a string to an INI buffer.
	Inline:
		INI_Int - Parse an integer INI entry.
		INI_Float - Parse a float INI entry.
		INI_Hex - Parse a hex INI entry.
		INI_Bin - Parse a binary INI entry.
		INI_Bool - Parse a binary INI entry.
		INI_String - Parse a string INI entry.
	API:
		-
Callbacks:
	-
Definitions:
	MAX_INI_TAG - Maximum length of an INI tagname.
	MAX_INI_ENTRY_NAME - Maximum length of an INI entry name.
	MAX_INI_ENTRY_TEXT - Maximum length of an INI's entries' value.
	MAX_INI_LINE - Maximum length of a line in a file.
	INI_NEW_LINE - String for new lines.
	INI_MAX_WRITES - Maximum concurrent files open for writing.
	MAX_INI_TAGS - Number of tags the buffer can hold data for at once.
Enums:
	E_INI_WRITE - Storage for entries to be written.
	E_INI_TAGS - Data for tags with data.
Macros:
	INI_Parse - Header for ini parsing functions.
Tags:
	INI - Handle to an INI file being written to.
Variables:
	Global:
		-
	Static:
		YSI_g_sINIWriteBuffer - Basic data to be written.
		YSI_g_sINIWritePos - Next slot to write to.
		YSI_g_sINITagPos - Next slot to add a tag to.
		YSI_g_sINICurrentTag - Pointer to the tag been writen to.
		YSI_g_sINIWriteTag - Data for tags,
		YSI_g_sINIWriteFile - Current files been written to.
Commands:
	-
Compile options:
	-
Operators:
	-
\*----------------------------------------------------------------------------*/
#include <YSI\y_utils>
#include <YSI\y_colours>
#include <YSI\y_debug>
#include <YSI\internal\y_shortfunc>


//#define Y_RENDER_ONE_ARG 
//	if ((arg = getarg(curArg++) || TRUE))

// Loops through all possible arguments in lists, functions and singles.
#define Y_RENDER_ARG for(new _i=0,_b=4;_i!=2;++_i)if(_i==0){if(ch&_:e_COMPRESS_FORMAT_DATA_FUNC){_b=1,func="@yR_";for(new _k=4;_k!=32;++_k)if(!(func[_k]=getarg(curArg,_k-4)))break;if(funcidx(func)==-1)func[2]='r',_b=2;}else if(ch&_:e_COMPRESS_FORMAT_DATA_LIST)_b=3;}else for(new _j=0;(arg=_b==1?W@(func,"iii",pid,(_:l),_j):_b==2?W@(func,"ii",(_:l),_j):_b==3?getarg(curArg,_j++):getarg(curArg)),(_j!=-1&&_b)?TRUE:++curArg&&FALSE;_b=_b==4?0:_b)

#define MAKE_SPECIFIER(%0) ((ch&_:e_COMPRESS_FORMAT_DATA_ZERO)?((ch&_:e_COMPRESS_FORMAT_DATA_LEFT)?(scFormats[3]{6}='%0',scFormats[3]):(scFormats[2]{5}='%0',scFormats[2])):((ch&_:e_COMPRESS_FORMAT_DATA_LEFT)?(scFormats[1]{5}='%0',scFormats[1]):(scFormats[0]{4}='%0',scFormats[0])))

#define Y_FIX_NEGATIVE_SPECIFIER(%0:%1) if(width>%1)arg=(ch&_:e_COMPRESS_FORMAT_DATA_LEFT)?((ch&_:e_COMPRESS_FORMAT_DATA_ZERO)?format(ts,128,"%"#%0"%0-*"#%0,arg>>>32/%1,width-(%1-1),arg&(1<<32/%1)-1):format(ts,128,"%"#%0"%-*"#%0,arg>>>32/%1,width-(%1-1),arg&(1<<32/%1)-1)):(ch&_:e_COMPRESS_FORMAT_DATA_ZERO)?format(ts,128,"%0*"#%0"%"#%0,width-1,arg>>>32/%1,arg&(1<<32/%1)-1):format(ts,128,"%*"#%0"%"#%0,width-1,arg>>>32/%1,arg&(1<<32/%1)-1);else format(ts,128,"%"#%0"%"#%0,arg>>>32/%1,arg&(1<<32/%1)-1)

#define Y_TEXT_RENDER_ADD(%1) if(Format_DoAddString(pid,output,%1,p,sizeof(output)-1,llen,0xFF0000AA,colour,strlen(%1)))++one

#define Y_TEXT_LETTER(%0) ('a'<=(%0)<='z'||'A'<=(%0)<='Z')
#define Y_TEXT_NUMBER(%0) ('0'<=(%0)<='9')

/*static stock Format_HyphenationSkipColour(output[], &idx) <y_text_render:send_client_message>
{
	if (idx < 8)
	{
		return;
	}
	if (output[idx] == '}')
	{
		idx -= 8;
	}
}*/

static stock Format_DoHyphenation(output[], &idx, ch)
{
	P:4("Format_DoHyphenation called: \"%s\", %i, %i", output, idx, ch);
	// Need at least 5 characters besides "ch" to make hyphenation worthwhile,
	// otherwise just shift the lot to the next line.
	//new
	//	tmp = idx;
	if (Y_TEXT_LETTER(ch))
	{
		--idx;
		//Format_HyphenationSkipColour(output, idx);
		if (Y_TEXT_LETTER(output[idx]))
		{
			--idx;
			//Format_HyphenationSkipColour(output, idx);
			if (Y_TEXT_LETTER(output[idx]))
			{
				--idx;
				//Format_HyphenationSkipColour(output, idx);
				if (Y_TEXT_LETTER(output[idx]))
				{
					--idx;
					//Format_HyphenationSkipColour(output, idx);
					if (Y_TEXT_LETTER(output[idx]))
					{
						--idx;
						//Format_HyphenationSkipColour(output, idx);
						if (Y_TEXT_LETTER(output[idx]))
						{
							// Reprocess three characters.
							idx += 3;
							ch = output[idx];
							output[idx++] = '-';
							return ch;
						}
						++idx;
						return 1;
					}
					++idx;
					return 1;
				}
				++idx;
				return 1;
			}
			++idx;
			return 1;
		}
		++idx;
	}
	else if (Y_TEXT_NUMBER(ch))
	{
		for (ch = 0; ch != 11; ++ch)
		{
			--idx;
			if (!Y_TEXT_NUMBER(output[idx]))
			{
				++idx;
				return 1;
			}
		}
		// Simply break numbers which are too long.
		idx += 11; //tmp;
	}
	return 0;
}

/*----------------------------------------------------------------------------*\
Function:
	Format_DoAddChar
Params:
	str[] - The string to write the data to.
	&idx - The index to write to.
	lastWhiteSpace - The start point of the current word.
	&llen - The maximum number of characters to write.
	ch - The value to write.
	&inputIdx - The current position in the input array.
	const input[] - The input array.
Return:
	-
Notes:
	Adds a single character to the end of the current line.
\*----------------------------------------------------------------------------*/

static stock Format_DoAddChar(const playerid, const style, str[], &idx, &llen, max, ch) <y_text_colour_fade:fake_render>
{
	#pragma unused playerid, style, str, idx, max, ch
	++llen;
	return true;
}

static stock Format_DoAddChar(const playerid, const style, str[], &idx, &llen, max, ch) <y_text_colour_fade:full_render>
{
	if (llen)
	{
		--llen;
		str[idx++] = ch;
		return false;
	}
	else
	{
		// Too long.  Using ONLY lookback figure out if the line can be split or
		// if we need a 
		new
			xc = Format_DoHyphenation(str, idx, ch);
		switch (xc)
		{
			case 0:
			{
				str[idx] = '\0';
				Format_DoDisplay(playerid, style, str);
				str[0] = ch;
				idx = 1;
				llen = max - 1;
			}
			case 1:
			{
				// Show the current string.
				llen = str[idx];
				str[idx] = '\0';
				Format_DoDisplay(playerid, style, str);
				// Put the new word on the new line.
				str[idx] = llen;
				xc = max - idx;
				str[xc] = ch;
				llen = xc;
				while (xc--)
				{
					str[xc] = str[idx + xc];
				}
				idx = llen + 1;
				llen = max - llen - 1;
			}
			default:
			{
				llen = str[idx];
				str[idx] = '\0';
				Format_DoDisplay(playerid, style, str);
				// Restore.
				str[idx] = llen;
				str[--idx] = xc;
				xc = max - idx;
				str[xc] = ch;
				llen = xc;
				while (xc--)
				{
					str[xc] = str[idx + xc];
				}
				idx = llen + 1;
				llen = max - llen - 1;
			}
		}
	}
	return true;
}

/*----------------------------------------------------------------------------*\
Function:
	Format_AddOct
Params:
	output[] - The string to write the data to.
	&maxlen - The maximum number of characters to write.
	val - The number to write.
	width - The minimum length of string to write.
	flags - FORMAT_LADJUST - pad left, FORMAT_ZEROPAD - pad with 0's.
Return:
	Format_AddNum
Notes:
	Wrapper for Format_AddNum in base 8.  See Format_AddNum.
\*----------------------------------------------------------------------------*/

#define Format_AddOct(%1,%2,%3,%4,%5) Format_AddNum((%1), (%2), (%3), (%4), (%5),   8, false)

/*----------------------------------------------------------------------------*\
Function:
	Format_AddNum
Params:
	output[] - The string to write the data to.
	&maxlen - The maximum number of characters to write.
	val - The number to write.
	width - The minimum length of string to write.
	flags - FORMAT_LADJUST - pad left, FORMAT_ZEROPAD - pad with 0's.
	base - The base to display the number in.
	sign - Wether or not sign should be shown.
Return:
	Length of the string added.
Notes:
	Adds a number to the output string according to the passed parameters. The
	original had separate, almost identical functions for each base, this
	combines them all into one.
\*----------------------------------------------------------------------------*/

static stock Format_AddNum(output[], maxlen, val, width, flags, base, sign)
{
	P:4("Format_AddNum called: \"%s\", %i, %i, %i, %i, %i, %i", output, maxlen, val, width, flags, base, sign);
	new
		text[33],
		digits,
		pos;
	if (sign)
	{
		new
			signedVal = val,
			num;
		if (val < 0) val = -val;
		do
		{
			num = '0' + (val % base);
			if (num > '9') num += 7;
			text[digits++] = num;
			val /= base;
		}
		while (val);
		if (signedVal & 0x80000000)
		{
			if (flags & _:e_COMPRESS_FORMAT_DATA_ZERO) output[pos++] = '-';
			else text[digits++] = '-';
		}
	}
	else
	{
		switch (base)
		{
			case 2:
			{
				do
				{
					text[digits++] = '0' + (val & 1);
					val >>>= 1;
				}
				while (val);
			}
			case 8:
			{
				do
				{
					text[digits++] = '0' + (val & 7);
					val >>>= 3;
				}
				while (val);
			}
			case 16:
			{
				new
					num;
				do
				{
					num = '0' + (val & 15);
					if (num > '9') num += 7;
					text[digits++] = num;
					val >>>= 4;
				}
				while (val);
			}
			default:
			{
				new
					num;
				do
				{
					if (val & 0x80000000)
					{
						num = '0' + ((((((val >>> 1) % base) << 1) % base) + (val & 1)) % base);
						if (num > '9') num += 7;
						text[digits++] = num;
						val = (val >>> 1) / (base >>> 1);
					}
					else
					{
						num = '0' + (val % base);
						if (num > '9') num += 7;
						text[digits++] = num;
						val /= base;
					}
				}
				while (val);
			}
		}
	}
	if(!(flags & _:e_COMPRESS_FORMAT_DATA_LEFT))
	{
		while (digits < width && maxlen)
		{
			output[pos++] = (flags & _:e_COMPRESS_FORMAT_DATA_ZERO) ? '0' : ' ';
			width--;
			maxlen--;
		}
	}
	while (digits-- && maxlen)
	{
		output[pos++] = text[digits];
		width--;
		maxlen--;
	}
	if (flags & _:e_COMPRESS_FORMAT_DATA_LEFT)
	{
		while (width-- && maxlen)
		{
			output[pos++] = (flags & _:e_COMPRESS_FORMAT_DATA_ZERO) ? '0' : ' ';
			maxlen--;
		}
	}
	return pos;
}

/*----------------------------------------------------------------------------*\
Function:
	Format_AddCommand
Params:
	output[] - String to add to.
	&maxlen - Length of string remaining.
	str[] - Function name to find.
	width - Minimum length.
	prec - Maximum length.
Return:
	Length of the string added.
Notes:
	-
\*----------------------------------------------------------------------------*/

static stock Format_AddCommand(output[], &maxlen, str[], width, prec)
{
	P:4("Format_AddCommand called: \"%s\", %i, \"%s\", %i, %i", output, maxlen, str, width, prec);
	new
		size,
		pos,
		pos2,
		string[YSI_MAX_STRING] = "FAIL";
	if (str[0] && CallRemoteFunction("Command_Name", "s", str))
	{
		getproperty(0, "", FORMAT_COMMAND, string);
		strunpack(string, string);
	}
	if (!string[0])
	{
		prec = -1;
	}
	if (prec >= 0)
	{
		for (size = 0; size < prec; size++) 
		{
			if (string[size] == '\0') break;
		}
	}
	else
	{
		while (string[size]) size++;
	}
	if (size > maxlen) size = maxlen;
	maxlen -= size;
	width -= size;
	while (size--)
	{
		output[pos++] = string[pos2++];
	}
	while (width-- > 0 && maxlen)
	{
		output[pos++] = ' ';
		maxlen--;
	}
	return pos;
}

/*----------------------------------------------------------------------------*\
Function:
	Format_AddSuffix
Params:
	output[] - String to add to.
	&maxlen - Length of string remaining.
	number - Number to add suffix of.
Return:
	-
Notes:
	Adds the ordinal suffix of a given number.  Does not support multiple
	languages atm.
\*----------------------------------------------------------------------------*/

static stock Format_AddSuffix(number, Language:lang)
{
	P:4("Format_AddSuffix called: %i, %i", number, _:lang);
	#pragma unused lang
	if (number < 0) number = -number;
	new
		suffix[3];
	// Restrict to only a range.
	number %= 100;
	if (number > 3 && number <= 20) suffix = "th";
	else switch (number % 10)
	{
		case 1: suffix = "st";
		case 2: suffix = "nd";
		case 3: suffix = "rd";
		default: suffix = "th";
	}
	return suffix;
}

// Takes a string in the YSI standardised format and outputs it.

static stock Format_DoDisplay(const playerid, const style, const str[]) <y_text_render:send_client_message>
{
	// Use the state for exactly that - global state.
	P:2("Format_DoDisplay<send_client_message>, %d, %d, %s", playerid, style, str);
	SendClientMessage(playerid, style, str);
}

static stock Format_DoDisplay(const playerid, const style, const str[]) <y_text_render:debug_only>
{
	// Use the state for exactly that - global state.
	printf("Format_DoDisplay<debug_only>, %d, %d, %s", playerid, style, str);
}

static stock bool:Format_DoAddString(const playerid, out[], const in[], &oidx, const omax, &orem, const len, step = 0) <y_text_colour_fade:fake_render>
{
	#pragma unused playerid, out, in, omax, orem, colour, initial, step, inc
	oidx += len;
	return true;
}

/*----------------------------------------------------------------------------*\
Function:
	Format_DoAddString
Params:
	inc - The amount to increase a colour fade by each step.
Return:
	-
Notes:
	-
\*----------------------------------------------------------------------------*/

static stock bool:Format_DoAddString(const playerid, out[], const in[], &oidx, const omax, &orem, const len, step = 0) <y_text_colour_fade:full_render>
{
	P:4("Format_DoAddString <y_text_colour_fade:full_render> called: %i, %s, %s, %i, %i, %i, %i", playerid, out, in, oidx, omax, orem, len);
	// For now don't worry about fades over boundaries - they're just too hard
	// to get the code working on to start with, maybe later once this is all
	// working they can be added in.  It is a shame though as it will mean fades
	// don't always work.  I can cheat slightly though and have the full fade on
	// both halves of the break.  Or just warn people about fades like that.
	// 
	// NOTE: This code assumes that orem (output remaining) is always 1 less
	// than the true value.  This avoids awkward calculations when appending the
	// NULL terminator to strings.  When we run out of space it simply appends
	// it regardless of wether it thinks there is space or not.
	// 
	new
		tlen = len;
	if (step > 0)
	{
		// Account for the extra colour formats for a fade.  Only fades are
		// worried about here as everything else is easy to handle elsewhere!
		// In rare cases this will waste a few characters.  All SA:MP colour
		// definitions are 8 characters long, the average length of a GameText
		// colour definition is 6.96 characters (including "X"s), so 8 is good,
		// there is no good way to determine the needed length of GameText space
		// for colours, an average is good enough, above average is better!
		tlen += (len / step + 1) * 8;
	}
	if (tlen <= orem)
	{
		P:5("Format_DoStringSCM: p0.");
		memcpy(out[oidx], in, 0, len * 4, orem);
		orem -= len;
		oidx += len;
		// The whole string fit in - return true.
		return false;
	}
	else
	{
		P:5("Format_DoStringSCM: p1.");
		// Copy as much data as possible.
		memcpy(out[oidx], in, 0, orem * 4, orem);
		//orem -= orem;
		//oidx += orem;
		// Don't need to adjust this further down as all the characters will be
		// added before the recursive call.
		len -= orem;
		oidx = omax;
		new
			tidx = orem + 1,
			ch = in[orem],
			xc = Format_DoHyphenation(out, oidx, ch);
		switch (xc)
		{
			case 0:
			{
				out[oidx] = '\0';
				Format_DoDisplay(playerid, colour, out);
				out[0] = ch;
				oidx = 1;
				orem = omax - 1;
			}
			case 1:
			{
				// Show the current string.
				xc = out[oidx];
				out[oidx] = '\0';
				Format_DoDisplay(playerid, colour, out);
				// Put the new word on the new line.
				out[oidx] = xc;
				xc = omax - oidx;
				out[xc] = ch;
				orem = xc;
				while (xc--)
				{
					out[xc] = out[oidx + xc];
				}
				oidx = orem + 1;
				orem = omax - orem - 1;
			}
			default:
			{
				orem = out[oidx];
				out[oidx] = '\0';
				Format_DoDisplay(playerid, colour, out);
				// Restore.
				out[oidx] = orem;
				out[--oidx] = xc;
				xc = omax - oidx;
				out[xc] = ch;
				orem = xc;
				while (xc--)
				{
					out[xc] = out[oidx + xc];
				}
				oidx = orem + 1;
				orem = omax - orem - 1;
			}
		}
		Format_DoAddString(playerid, out, in[tidx], oidx, omax, orem, len, step);
		return true;
	}
}

stock Format_Render(pid, Language:l, string[], {Float,_}:...) //<text_render:send_client_message>
{
	P:3("Format_Render called: %i, %i, %s (+%i)", pid, _:l, string, numargs() - 3);
	state y_text_colour_fade:full_render;
	new
		colour = 0x00FF00AA;
	static
		scFormats[][] =
			{
				"%*.*d",  // 6 (6)
				"%-*.*d", // 7 (13)
				"%0*.*d", // 7 (20)
				"%0-*.*d" // 8 (28)
			},
		scSpecifier[8];
	// "one" is one when there are no "per-player" function calls and the
	// string can be shown all at once.
	new
		idx = 0,
		ch,
		output[128], // Always 128.
		ts[128], // UPDATE Y_FIX_NEGATIVE_SPECIFIER MACRO ON CHANGE!!!!!!!
		func[32],
		p = 0,
		curArg = 4,
		numArgs = numargs(),
		llen = sizeof (output) - 1,
		arg,
		one = 0;
	new
		fadeCurArg,
		fadeArg,
		fadeIdx;
	while ((ch = string[idx++]))
	{
		// TODO: Add {*} and #* format for variable colours.
		switch (ch)
		{
			case '\01':
			{
				// Null.
				break;
			}
			case '\02':
			{
				P:6("Text_Render: Format specifier %d", curArg);
				if (curArg == numArgs)
				{
					// Skip.
					P:W("Insufficient parameters to YSI format.");
					Y_TEXT_RENDER_ADD("(null)");
				}
				// Format.
				ch = string[idx++];
				new
					width = (ch & _:e_COMPRESS_FORMAT_DATA_WIDTH),
					prec  = (ch & _:e_COMPRESS_FORMAT_DATA_PREC) >>> 12;
				// Get the true values of the various data bits.
				if (width == 0x0800)
				{
					width = getarg(curArg++);
				}
				if (prec == 0x0800)
				{
					prec = getarg(curArg++);
				}
				else if (prec == 0x0FFF)
				{
					prec = -1;
				}
				// Output the correct data type.
				switch (ch & 0xF0000000)
				{
					case e_COMPRESS_FORMAT_DATA_DEC:
					{
						P:6("Text_Render: Add d");
						scSpecifier = MAKE_SPECIFIER(d);
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							format(ts, sizeof (ts), scSpecifier, width, prec, arg);
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_HEX:
					{
						// This completely fixes (I hope) the problems with
						// displaying negative numbers as %h/%x numbers.
						P:6("Text_Render: Add h");
						scSpecifier = MAKE_SPECIFIER(x);
						Y_RENDER_ARG
						{
							if (arg & 0x80000000)
							{
								Y_FIX_NEGATIVE_SPECIFIER(x:8);
							}
							else
							{
								format(ts, sizeof (ts), scSpecifier, width, prec, arg);
							}
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_BIN:
					{
						P:6("Text_Render: Add b");
						scSpecifier = MAKE_SPECIFIER(b);
						Y_RENDER_ARG
						{
							if (arg & 0x80000000)
							{
								Y_FIX_NEGATIVE_SPECIFIER(b:32);
							}
							else
							{
								format(ts, sizeof (ts), scSpecifier, width, prec, arg);
							}
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_CHAR:
					{
						scSpecifier = MAKE_SPECIFIER(c);
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							format(ts, sizeof (ts), scSpecifier, width, prec, arg);
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_FLOAT:
					{
						scSpecifier = MAKE_SPECIFIER(f);
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							format(ts, sizeof (ts), scSpecifier, width, prec, arg);
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_IEEE:
					{
						Y_RENDER_ARG
						{
							if ((arg & 0x7F800000) == 0x7F800000)
							{
								scSpecifier = MAKE_SPECIFIER(s);
								// One of the special numbers.
								if (arg & 0x007FFFFF)
								{
									// NAN.
									if (arg & 0x00400000)
									{
										// QNAN
										format(ts, sizeof (ts), scSpecifier, width, cellmax, "QNAN");
										Y_TEXT_RENDER_ADD(ts);
									}
									else
									{
										// SNAN
										format(ts, sizeof (ts), scSpecifier, width, cellmax, "SNAN");
										Y_TEXT_RENDER_ADD(ts);
									}
								}
								else
								{
									if (arg & 0x80000000)
									{
										// -INFINITY
										format(ts, sizeof (ts), scSpecifier, width, cellmax, "-INFINITY");
										Y_TEXT_RENDER_ADD(ts);
									}
									else
									{
										// INFINITY
										format(ts, sizeof (ts), scSpecifier, width, cellmax, "INFINITY");
										Y_TEXT_RENDER_ADD(ts);
									}
								}
							}
							else
							{
								scSpecifier = MAKE_SPECIFIER(f);
								format(ts, sizeof (ts), scSpecifier, width, prec, arg);
								Y_TEXT_RENDER_ADD(ts);
							}
						}
					}
					case e_COMPRESS_FORMAT_DATA_STRING:
					{
						scSpecifier = MAKE_SPECIFIER(s);
						if (ch & _:e_COMPRESS_FORMAT_DATA_FUNC)
						{
							func = "@yR_";
							// Get the function name.
							for (new _k = 4; _k != 32; ++_k)
							{
								if (!(func[_k] = getarg(curArg, _k - 4)))
								{
									break;
								}
							}
							if (funcidx(func) == -1)
							{
								// Normal version.  This is ended by a null.
								// Other functions get the count in advance when
								// an index of -1 is passed.
								func[2] = 'r';
								// This code mimicks much of the internal
								// y_master code because wrapping this in a
								// macro is a) pointless and b) hard.  This code
								// is ALWAYS like this because of the nature of
								// it.
								new
									lst = setproperty(8, YSIM_CALLER),
									_j = 0;
								setproperty(8, YSIM_CALLER, _@);
								for ( ; ; )
								{
									CallRemoteFunction(func, "ii", _:l, _j);
									// Resolve the string.
									getproperty(9, "", YSIM_STRING, Q@);
									strunpack(Q@, Q@);
									if (Q@[0])
									{
										if (_j)
										{
											// Separate the strings - hard coded
											// list format currently I'm afraid.
											Y_TEXT_RENDER_ADD(", ");
										}
										format(ts, sizeof (ts), scSpecifier, width, prec, Q@);
										Y_TEXT_RENDER_ADD(ts);
									}
									else
									{
										break;
									}
									++_j;
								}
								setproperty(8, YSIM_CALLER, lst);
							}
							else
							{
								// Player specific version.
								// Normal version.  This is ended by a null.
								// Other functions get the count in advance when
								// an index of -1 is passed.
								func[2] = 'r';
								// This code mimicks much of the internal
								// y_master code because wrapping this in a
								// macro is a) pointless and b) hard.  This code
								// is ALWAYS like this because of the nature of
								// it.
								new
									lst = setproperty(8, YSIM_CALLER),
									_j = 0;
								setproperty(8, YSIM_CALLER, _@);
								for ( ; ; )
								{
									CallRemoteFunction(func, "iii", pid, _:l, _j);
									// Resolve the string.
									getproperty(9, "", YSIM_STRING, Q@);
									strunpack(Q@, Q@);
									if (Q@[0])
									{
										if (_j)
										{
											// Separate the strings - hard coded
											// list format currently I'm afraid.
											Y_TEXT_RENDER_ADD(", ");
										}
										// Could do with configuring this to not
										// need to call "MAKE_SPECIFIER" every
										// time.
										format(ts, sizeof (ts), scSpecifier, width, prec, Q@);
										Y_TEXT_RENDER_ADD(ts);
									}
									else
									{
										break;
									}
									++_j;
								}
								setproperty(8, YSIM_CALLER, lst);
								// Force the string to be rebuilt every time.
								++one;
							}
						}
						else
						{
							// Single parameter.
							for (new _k = 0; _k != sizeof (ts); ++_k)
							{
								if (!(ts[_k] = getarg(curArg, _k)))
								{
									break;
								}
							}
							format(ts, sizeof (ts), scSpecifier, width, prec, ts);
							Y_TEXT_RENDER_ADD(ts);
						}
						++curArg;
					}
					case e_COMPRESS_FORMAT_DATA_OCT:
					{
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							//format(ts, sizeof (ts), MAKE_SPECIFIER(f), width, prec, arg);
							ts[Format_AddOct(ts, sizeof (ts) - 1, arg, width, ch)] = '\0';
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_COMM:
					{
					}
					case e_COMPRESS_FORMAT_DATA_SUFFIX:
					{
						scSpecifier = MAKE_SPECIFIER(s);
						// TODO: Add language to this.
						//p += Format_AddSuffix(output[p], llen, getarg(curArg++), l);
						Y_RENDER_ARG
						{
							format(ts, sizeof (ts), scSpecifier, width, cellmax, Format_AddSuffix(arg, l));
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_UNSIGNED:
					{
						if (prec < 0) prec = 10;
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							//format(ts, sizeof (ts), MAKE_SPECIFIER(f), width, prec, arg);
							//ts[Format_AddOct(ts, sizeof (ts) - 1, arg, width, ch)] = '\0';
							ts[Format_AddNum(ts, sizeof (ts) - 1, arg, width, ch, prec, false)] = '\0';
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_SIGNED:
					{
						if (prec < 0) prec = 10;
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							//format(ts, sizeof (ts), MAKE_SPECIFIER(f), width, prec, arg);
							ts[Format_AddNum(ts, sizeof (ts) - 1, arg, width, ch, prec, true)] = '\0';
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_PLAYER:
					{
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							GetPlayerName(arg, ts, sizeof (ts));
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_LOGICAL: 
					{
						scSpecifier = MAKE_SPECIFIER(s);
						Y_RENDER_ARG
						{
							//p += Format_AddInt(output[p], llen, arg, width, ch);
							format(ts, sizeof (ts), scSpecifier, width, prec, arg ? ("true") : ("false"));
							Y_TEXT_RENDER_ADD(ts);
						}
					}
					case e_COMPRESS_FORMAT_DATA_DATE:
					{
						// Hard one - needs more interaction.
					}
				}
			}
			case '\03':
			{
				Format_DoAddColour
				P:6("Text_Render: Colour");
				++idx;
			}
			case '\04':
			{
				P:6("Text_Render: Key");
				++idx;
			}
			case '\05':
			{
				// String extension.
				P:6("Text_Render: Extension");
				++idx;
				// TODO!
			}
			case '\n':
			{
				P:6("Text_Render: NL");
				// Check for 2 character new lines (\n\r).
				if (string[idx] == '\r') ++idx;
				// Output the last string.
				output[p] = '\0';
				Format_DoDisplay(pid, colour, output);
				output[0] = '\0';
				p = 0;
				llen = sizeof (output) - 1;
			}
			case '\r':
			{
				P:6("Text_Render: NL");
				// Check for 2 character new lines (\r\n).
				if (string[idx] == '\n') ++idx;
				// Output the last string.
				output[p] = '\0';
				Format_DoDisplay(pid, colour, output);
				output[0] = '\0';
				p = 0;
				llen = sizeof (output) - 1;
			}
			case '\t':
			{
				// Somehow display a tab.  Maybe keep track of characters
				// displayed and show "n % 4" spaces.
				arg = (p & ~0x03) + 4; // The number of spaces to add.
				if (arg >= llen)
				{
					// Just show the message (without the space).
					output[p] = '\0';
					Format_DoDisplay(pid, colour, output);
					output[0] = '\0';
					p = 0;
					llen = sizeof (output) - 1;
				}
				else
				{
					// Add a tab.
					while (p < arg)
					{
						output[p++] = ' ';
						--llen;
					}
				}
			}
			case '\06' .. '\08', '\11', '\12', '\14' .. '\32':
			{
				// Whitespace.  Just show a space, not the fancy character, no
				// idea what it could do.  Note that this range includes spaces.
				P:6("Text_Render: Space");
				if (llen == 0)
				{
					// Just show the message (without the space).
					output[p] = '\0';
					Format_DoDisplay(pid, colour, output);
					output[0] = '\0';
					p = 0;
					llen = sizeof (output) - 1;
				}
				else if (p != 0)
				{
					// Don't put whitespace at the START of a line.
					output[p++] = ' ';
					--llen;
				}
			}
			default:
			{
				P:6("Text_Render: Char");
				//p += Format_AddChar(output[p], llen, ch);
				if (Format_DoAddChar(pid, colour, output, p, llen, sizeof (output) - 1, ch))
				{
					++one;
				}
			}
		}
		P:6("Text_Render: Loop: p = %d, llen = %d, output = \"%s\"", p, llen, output);
	}
	if (p)
	{
		output[p] = '\0';
		Format_DoDisplay(pid, colour, output);
		++one;
	}
	return one;
	P:5("Text_Render: p = %d, output = \"%s\"", p, output);
	P:C(idx=0;while ((ch = output[idx++]))printf("%04x%04x = %c", ch >>> 16, ch & 0xFFFF, ch););
	P:5("Text_Render end");
}
