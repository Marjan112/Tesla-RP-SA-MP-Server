// y_scripttrace

#include <YSI\y_amx>
#include <YSI\y_master>
#include <YSI\y_hooks>

// TODO: Make this work when there is no master system.

#define Y_SCRIPT_TRACE_PATTERN (0x21495359)
// 0x20656854 = The 
// 0x21646E65 = End!
// 0x21495359 = YSI!

// Improve the scan speed by using a large array to increase the step size in
// scanning.  Once the pattern is found, slow down and reverse to find the start
// of the array.  Alternate between forwards and backwards through the memory
// space.  Worst case scenario, this will take 8388608 steps, but it shouldn't
// take anywhere near that long!  This array is 128 x search pattern, following
// the string "The end!", itself following what will become the master ID.
static
	YSI_g_sPatternArray[131] = {0, 0x20656854, 0x21646E45, Y_SCRIPT_TRACE_PATTERN, Y_SCRIPT_TRACE_PATTERN, ...};

hook OnScriptInit()
{
	//MAHOOSIVE_ARRAY[0] = 0, TEST_ARRAY[0] = 0;
	#if !defined YSI_NO_MASTER
		if (_@ == -1) P:E("Master_OnScriptInit not called before ScriptTrace_OnScriptInit");
	#endif
	YSI_g_sPatternArray[0] = _@;
	new
		//bool:is_first = true,
		masters = getproperty(8, YSIM_MASTER),
		addrup,
		addrdn,
		data;
	printf("HI");
	// Clever little trick to detect if only one bit is set in a number, if
	// there is only one bit, then there is only one master.
	//if (masters != masters & -masters)
	if (masters == masters & -masters)
	{
		printf("NO OTHER SCRIPTS");
	}
	else
	{
		// More than one master, find just one of them.
		// Get the address after the local array for the upwards varaible,
		#emit CONST.pri                 YSI_g_sPatternArray
		#emit CONST.alt                 524 // 131 * 4
		#emit ADD
		#emit STOR.S.pri                addrup
		// Get the address of the start of the AMX for the downwards variable.
		#emit LCTRL                     1
		#emit NEG
		#emit STOR.S.pri                addrdn
		//#emit STOR.S.pri                addrup
		printf("HI");
		// Now scan through memory.
		for ( ; ; )
		{
			//#if defined FILTERSCRIPT
				#emit LREF.S.pri            addrup
				#emit STOR.S.pri            data
				printf("up: %08x", data);
				if (data == Y_SCRIPT_TRACE_PATTERN)
				{
					//if (!is_first)
					//{
						printf("FOUND!");
						break;
					//}
					//is_first = false;
				}
			addrup += 128 * 4;
			//#else
			#emit LREF.S.pri            addrdn
			#emit STOR.S.pri            data
			printf("dn: %08x", data);
			if (data == Y_SCRIPT_TRACE_PATTERN)
			{
				printf("FOUND!");
				break;
			}
			addrdn -= 128 * 4;
			#emit LREF.S.pri            addrdn
			#emit STOR.S.pri            data
			printf("dn: %08x", data);
			if (data == Y_SCRIPT_TRACE_PATTERN)
			{
				printf("FOUND!");
				break;
			}
			addrdn -= 128 * 4;
			#emit LREF.S.pri            addrdn
			#emit STOR.S.pri            data
			printf("dn: %08x", data);
			if (data == Y_SCRIPT_TRACE_PATTERN)
			{
				printf("FOUND!");
				break;
			}
			addrdn -= 128 * 4;
			#emit LREF.S.pri            addrdn
			#emit STOR.S.pri            data
			printf("dn: %08x", data);
			if (data == Y_SCRIPT_TRACE_PATTERN)
			{
				printf("FOUND!");
				break;
			}
			addrdn -= 128 * 4;
		}
	}
}

// Highly optimised assembly based 





























