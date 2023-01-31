// This provides server features for the minimode system.

#tryinclude <YSI\y_files>

#if !defined _inc_y_files
	#error The YSI minimode system requires the y_files plugin for file listing..
#endif

// List the modes, then load their text files to get important mode data.

// Mode folder sructure:
// 
// minimodes
//     - LVDM
//         - mode.amx
//         - mode.de
//         - mode.en
//         - mode.fr
//         - info.de
//         - info.en
//         - info.fr
//         - something.map
//         - other.map
//         - third.map
//     - SFTDM
//         - ...
//     - ...
// 

// Listing all minimodes:
// 
//  // Call this as infrequently as possible (maybe add a new command for it).
//  // This will reload all data on all available modes (title and description).
//  MM_RefreshList();
//  new
//      l = MM_Start(),
//      name[MAX_MM_NAME];
//  while (MM_Next(name, l))
//  {
//      MM_Title(name);
//      MM_Description(name);
//  }
// 
// Loading a minimode:
// 
//  MM_Load(name);
// 

foreign MM_Load(string:name[]);

global MM_Load(string:name[])
{
	P:2("MM_Load called: \"%s\"", name);
	// First load all the text data for this mode.
	Commands_SetProvider(Master_GetNext());
	// Then load the actual mode as a filterscript.
	
	// Check the mode is loaded (involves internal properties).
	
	// Finally clean up.
	Commands_SetProvider(0xFF);
}













