/*----------------------------------------------------------------------------*-
					==========================
					 y_colours - X11 colours!
					==========================
Description:
	This holds the colour information that used to be part of the text system
	but which is far more useful than just for text.  This now supports the full
	set of X11 colours, both by name and by definition.  You can also define
	your own if you so choose (up to 32 - should be enough given that this
	includes the X11 colours).
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
	
	The Original Code is the YSI format include.
	
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
	29/11/10:
		Added the ability to use "X11" prefixes in strings.
		Added colourspace resolution for converting {FF0000} to ~r~.
	25/11/10:
		First version.
-*----------------------------------------------------------------------------*/

enum e_COLOUR_TYPE
{
	colour_samp,
	colour_game_text,
	colour_text_draw,
	colour_text_draw_ex,
	colour_scm,
	colour_scm_pre_3c
}

// Because I'm anal about British/American spellings.
#define e_COLOR_TYPE                    e_COLOUR_TYPE

#define color_samp                      colour_samp
#define color_game_text                 colour_game_text
#define color_text_draw                 colour_text_draw
#define color_text_draw_accurate        colour_text_draw_accurate
#define colour_scm                      colour_scm
#define colour_scm_pre_3c               colour_scm_pre_3c

stock Colours_AddSAMPChange(output[], &idx, rem, cur, nu)
{
	P:3("Colours_AddSAMPChange called: \"%s\", %i, %i, %i, %i", output, idx, rem, cur, nu);
	if (cur == nu)
	{
		return 2;
	}
	#if defined Y_COLOUR_APPROXIMATE || defined Y_COLOR_APPROXIMATE
		if (-0x5 <= ((nu & 0x0FF) - (cur & 0xFF)) <= 0x5)
		{
			if (-0x500 <= ((nu & 0xFF00) - (cur & 0xFF00)) <= 0x500)
			{
				if (-0x50000 <= ((nu & 0xFF0000) - (cur & 0xFF0000)) <= 0x50000)
				{
					// Haven't changed the colour.
					return 1;
				}
			}
		}
	#endif
	// Need to add an update.
	if (rem <= 8)
	{
		// Not enough space.
		return -1;
	}
	format(output[idx], rem, "{%06x}", nu);
	idx += 8;
	// Added to output.
	return 0;
}

stock bool:Colours_AddGTChange(output[], &idx, rem, cur, nu)
{
	P:3("bool:Colours_AddGTChange called: \"%s\", %i, %i, %i, %i", output, idx, rem, cur, nu);
	// Add the GT text to change from the current colour to the new colour.
	new
		t = nu & 0xFF,
		o = cur & 0xFF;
	// Get the base colour.
	nu >>>= 8;
	cur >>>= 8;
	if (t == 'x' && o == 'y')
	{
		// Original.  Have to use yellow instead (though red is closer to the
		// plain original colour).  I tried to find a way to replicate the basic
		// orange but there is no way...
		t == 'y';
		nu = 0;
	}
	if (t == o)
	{
		// Stayed the same or will now stay the same.
		if (nu == cur)
		{
			return true;
		}
		if (nu > cur)
		{
			// Same colour, just lighter.
			do
			{
				if (rem <= 3)
				{
					return false;
				}
				// Add a fader.
				//output[idx] = '~';
				//output[idx + 1] = 'h';
				//output[idx + 2] = '~';
				strcat(output, "~h~", rem);
				rem -= 3;
				idx += 3;
				--nu;
			}
			while (nu > cur);
			return true;
		}
		// Same colour but darker - need to reset.
	}
	if (rem <= 3)
	{
		return false;
	}
	// Add the base colour.
	output[idx] = '~';
	output[idx + 1] = t;
	output[idx + 2] = '~';
	rem -= 3;
	idx += 3;
	while (nu)
	{
		if (rem <= 3)
		{
			return false;
		}
		// Add a fader.
		//output[idx] = '~';
		//output[idx + 1] = 'h';
		//output[idx + 2] = '~';
		strcat(output, "~h~", rem);
		rem -= 3;
		idx += 3;
		--nu;
	}
	return true;
}

#define _COLOUR_GT_SPACE_DEF_0(%0)      SAMP_GAME_TEXT_%0
#define _COLOUR_GT_SPACE_DEF_1(%0)      SAMP_GAME_TEXT_%0H
#define _COLOUR_GT_SPACE_DEF_2(%0)      SAMP_GAME_TEXT_%0HH
#define _COLOUR_GT_SPACE_DEF_3(%0)      SAMP_GAME_TEXT_%0HHH
#define _COLOUR_GT_SPACE_DEF_4(%0)      SAMP_GAME_TEXT_%0HHHH
#define _COLOUR_GT_SPACE_DEF_5(%0)      SAMP_GAME_TEXT_%0HHHHH

#define _COLOUR_GT_SPACE(%0,%1)         {('%0'|0x20)|(%1<<8),_COLOUR_GT_SPACE_DEF_%1(%0)>>>24,_COLOUR_GT_SPACE_DEF_%1(%0)>>16&0xFF,_COLOUR_GT_SPACE_DEF_%1(%0)>>8&0xFF}
#define _COLOUR_GT_SPACE_N(%1)          {'x'|(%1<<8),_COLOUR_GT_SPACE_DEF_%1()>>>24,_COLOUR_GT_SPACE_DEF_%1()>>16&0xFF,_COLOUR_GT_SPACE_DEF_%1()>>8&0xFF}

#define COLOUR_FLOAT_INFINITY           (Float:0x7F800000)

static stock Colours_SAMPToGT(colour)
{
	P:4("Colours_SAMPToGT called: %i", colour);
	// Find the closest matching game text colour to the given SA:MP colour.
	static const
		sc_aColours[][4] =
		{
			// These can't be used as you can't set text to them.  You can
			// however use them at the start by not changing.
			_COLOUR_GT_SPACE(X,0), _COLOUR_GT_SPACE(X,1),
			_COLOUR_GT_SPACE(X,2),
			
			_COLOUR_GT_SPACE(R,0), _COLOUR_GT_SPACE(R,1),
			_COLOUR_GT_SPACE(R,2), _COLOUR_GT_SPACE(R,3),
			_COLOUR_GT_SPACE(R,4), _COLOUR_GT_SPACE(R,5),
			
			_COLOUR_GT_SPACE(G,0), _COLOUR_GT_SPACE(G,1),
			_COLOUR_GT_SPACE(G,2), _COLOUR_GT_SPACE(G,3),
			//_COLOUR_GT_SPACE(G,4), // Don't want this twice (see Y2).
			
			_COLOUR_GT_SPACE(B,0), _COLOUR_GT_SPACE(B,1),
			_COLOUR_GT_SPACE(B,2), _COLOUR_GT_SPACE(B,3),
			
			_COLOUR_GT_SPACE(Y,0), _COLOUR_GT_SPACE(Y,1),
			_COLOUR_GT_SPACE(Y,2),
			
			_COLOUR_GT_SPACE(P,0), _COLOUR_GT_SPACE(P,1),
			_COLOUR_GT_SPACE(P,2),
			
			_COLOUR_GT_SPACE(W,0),
			
			_COLOUR_GT_SPACE(L,0)
		};
	new
		Float:dist = COLOUR_FLOAT_INFINITY,
		found = '\0',
		r = colour >> 16,
		g = colour >> 8 & 0xFF,
		b = colour & 0xFF,
		Float:tr, Float:tg, Float:tb, Float:cur;
	for (new i = 0; i < sizeof (sc_aColours); ++i)
	{
		tr = r - sc_aColours[i][1];
		tg = g - sc_aColours[i][2];
		tb = b - sc_aColours[i][3];
		cur = (tr * tr) + (tg * tg) + (tb * tb);
		if (cur < dist)
		{
			// This may sometimes give odd results in fades for draw results.
			// Though I've not seen it happen yet.
			dist = cur;
			found = sc_aColours[i][0];
		}
	}
	return found;
}

/*static stock Colours_DoTextSAMP(const input[], output[], offset, size)
{
	P:4("Colours_DoTextSAMP called: \"%s\", \"%s\", %i, %i", input, output, offset, size);
	if (offset == 0)
	{
		// Get the next possible start point.
		new
			lastspace = -1,
			startc = strfind(input, "("),
			starts = strfind(input, "{"),
			startg = strfind(input, "~"),
			idx = 0;
		if (startc == -1) startc = cellmax;
		if (starts == -1) starts = cellmax;
		if (startg == -1) startg = cellmax;
		while (idx < size)
		{
			if (startc < startg)
			{
				if (startc < starts)
				{
					// startc lowest.  This is client style brackets.
					// We need to check for valid format.
					new
						curc,
						idx = startc + 1;
					if (input[idx] == '>')
					{
						// The start of a fade.
						++idx;
						curc = Colour_Resolve(input, ')', idx);
					}
					else
					{
						curc = Colour_Resolve(input, ')', idx);
					}
					continue;
				}
			}
			else if (starts < startg)
			{
				// starts lowest.  This is SA:MP style braces.
				continue;
			}
			// startg lowest.  This is game text style tildas.
			switch (input[startg + 1])
			{
				case 'b':
				case 'g':
				case 'h':
				case 'l':
				case 'r':
				case 'p':
				case 'w':
				case 'y':
					// Colours.
				case 'n':
					// Need to handle this.
				case 'a':
				case 'd':
				case 'k':
				case 'u':
				case '<':
				case '>':
				case '1':
				case ']':
					// Symbols.
				default:
					return -1;
			}
		}
	}
	//else
	//{
	//}
}

#define Colors_DoText                   Colours_DoText
stock Colours_DoText(const input[], output[], offset = -1, e_COLOUR_TYPE:type = colour_samp, size = sizeof (output))
{
	switch ()
	{
		case colour_samp:
			return Colours_DoTextSAMP(input, output, offset, size);
		case colour_game_text:
			return Colours_DoTextGT(input, output, offset, size);
		case colour_text_draw:
			return Colours_DoTextTD(input, output, offset, size);
		//case colour_text_draw_ex:
		//	return Colours_DoTextTDX();
		default:
			return -1;
	}
}*/
