#if defined _macros_included
    #endinput
#endif
#define _macros_included

#pragma library Macro

//K0NSTANTE
#define MAX_ADMINS 20
#define MAX_PROMS 20
#define MAX_HOUSES 200
#define MAX_ORGS 6
#define MAX_VR 4
#define SKIDANJEID MAX_PLAYERS
#define MAX_HPRICE 1500000
#define MIN_HPRICE 250000
#define MAX_ORG_MEMBERS 50
#define BUS_PLATA 30000
#define BANK_PLATA 35000
#define POLICE_PLATA 45000
#define BOLNICAR_PLATA 55000
//SKRACENICE
#define SCM SendClientMessage
#define va_SCM va_SendClientMessage
#define SPD ShowPlayerDialog
#define SCMTA SendClientMessageToAll
#define va_SCMTA va_SendClientMessageToAll
//BOJE
#define CRVENA 0xff0000ff
#define ZELENA 0x00ff00ff
#define PLAVA 0x0000ffff
#define CRNA 0x000000ff
#define BELA 0xffffffff
#define SIVA 0x69696969
#define NARANDZASTA 0xffa500ff
#define PLAVA_NEBO 0x03adfcff
#define ZUTA 0xffff00ff
#define SVETLA_ZUTA 0xfffb00ff
#define SVETLA_CRVENA 0xAA3333ff
#define PROXY 0xc2a2daaa
//CUVANJE PODATAKA U FAJLOVIMA
#define USERPATH "/korisnici/%s.ini"
#define ADMINPATH "/admini/%d.ini"
#define BANPATH "/banovani/%d.ini"
#define PROMPATH "/promoteri/%d.ini"
#define VRPATH "/vr/%d.ini"
#define HOUSEPATH "/kuce/%d.ini"
#define ORGPATH "/organizacije/%d.ini"
#define VEHPATH "/vozila/%d.ini"
#define BAN_IP_PATH "/ip_banovani/%d.ini"
#define HELPERPATH "/helperi/%d.ini"
//MAP ICONS
#define HOSPITAL 22
#define BANK 52
#define POLICE 30
#define AMMUNATION 6
#define ZEMUNCI 62
#define FIBOVCI 58
#define KUCA_NA_PRODAJU 31
#define KUCA_KUPLJENA 32
#define AUTO_SALON 55
//FUNCTION
#define function%1(%2) forward %1(%2); public %1(%2)