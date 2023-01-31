/*
 *
 * Dialog Controller
 * Enhances the default SA-MP dialog system by allowing dialog data to be saved and dynamically shown
 *
 * NAME         Dialog Controller
 * AUTHOR		ev0lution
 * FILE         dialog.inc
 * VERSION      1.0.0
 * LICENSE      GNU General Public License (see below)
 * COPYRIGHT    Copyright © 2010 ev0lution
 *
 * 	Dialog Controller is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 * 	Dialog Controller is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with Dialog Controller.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// CallRemoteFunction (for OnDialogResponse) crashes with an empty string, so \1 has to be passed, which can be detected as empty by isnull
#if !defined isnull
	#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define INVALID_DIALOG -1

/*	GetPlayerDialog(playerid)
	Get the ID of the current dialog shown to [playerid]
	RETURNS: Dialog Controller ID (NOT dialog ID) of the dialog being shown to [playerid], INVALID_DIALOG if none
	NOTE: This will only return an ID of a dialog created by Dialog Controller. All other dialogs which may be shown will return INVALID_DIALOG (-1)
*/
#define GetPlayerDialog(%1) CallRemoteFunction("GetPlayerDialog","i",(%1))

/*  GetDialogCount()
	Get the number of dialogs created and stored by Dialog Controller
	RETURNS: The number of valid dialogs created by Dialog Controller
*/
#define GetDialogCount() CallRemoteFunction("GetDialogCount","")

/*  ResetDialogs()
	Reset all dialog data, and hide any dialogs shown to players
	RETURNS: 1 (true)
	NOTE: This function should not be used in your script, it is only used to reset data when Dialog Controller is unloaded.
*/
#define ResetDialogs() CallRemoteFunction("ResetDialogs","") // You should never have to call this

/*  CreateDialog(style,caption[],info[],button1[],button2[])
	Create a dialog to be stored by Dialog Controller with properties specified by [style], [caption], [info], [button1] and [button2]
	RETURNS: The Dialog Controller ID of the dialog created (NOT dialog ID), INVALID_DIALOG if creation failed
*/
#define CreateDialog(%1,%2,%3,%4,%5) CallRemoteFunction("CreateDialog","issss",%1,%2,%3,%4,%5)

/*  DestroyDialog(id)
	Destroy dialog [id] created by Dialog Controller, and hide it to any players which currently see it
	RETURNS: 1 (true) on success, 0 (false) on fail (eg. if the dialog didn't exist)
*/
#define DestroyDialog(%1) CallRemoteFunction("DestroyDialog","i",%1)

/*  ShowDialog(playerid,id)
	Show dialog [id] created by Dialog Controller to [playerid]
	RETURNS: 1 (true) on success, 0 (false) on fail (eg. if the dialog didn't exist)
*/
#define ShowDialog(%1,%2) CallRemoteFunction("ShowDialog","ii",%1,%2)

// OnDialogResponse must be redefined so that the correct dialog ID is passed
// _OnDialogResponse will be called remotely by Dialog Controller
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	return 1;
}
#define OnDialogResponse _OnDialogResponse
forward _OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
