#if defined _g_var_included
    #endinput
#endif
#define _g_var_included

#pragma library gVar

new ZatvorVrata[4];

#if !defined _samp_included
    #tryinclude <a_samp>
#endif

new Bool: ZakljucanaVrata[MAX_OBJECTS];
new Bool: ZatvorenaVrata[MAX_OBJECTS];