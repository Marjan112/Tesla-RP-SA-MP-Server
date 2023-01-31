/*  
 *  Version: MPL 1.1
 *  
 *  The contents of this file are subject to the Mozilla Public License Version 
 *  1.1 (the "License"); you may not use this file except in compliance with 
 *  the License. You may obtain a copy of the License at 
 *  http://www.mozilla.org/MPL/
 *  
 *  Software distributed under the License is distributed on an "AS IS" basis,
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 *  for the specific language governing rights and limitations under the
 *  License.
 *  
 *  The Original Code is the BASS Spectrum Analyzer SA:MP plugin.
 *  
 *  The Initial Developer of the Original Code is Scott Reed ("h02").
 *  Portions created by the Initial Developer are Copyright (C) 2012
 *  the Initial Developer. All Rights Reserved.
 */

#define BASS_DATA_FFT256	0	// 256 sample FFT
#define BASS_DATA_FFT512	1	// 512 FFT
#define BASS_DATA_FFT1024	2	// 1024 FFT
#define BASS_DATA_FFT2048	3	// 2048 FFT
#define BASS_DATA_FFT4096	4	// 4096 FFT

native BASS_Init();
native BASS_Free();
native BASS_PlayStream(url[]); // Returns the handle ID created
native BASS_StopStream(handle);
native BASS_ErrorGetCode(); // www.un4seen.com/doc/bass/BASS_ErrorGetCode.html
native BASS_ChannelGetData(handle, Float:buffer[], length);
native BASS_ChannelGetLevel(handle, &left, &right);