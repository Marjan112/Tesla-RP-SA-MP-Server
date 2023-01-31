#define FILTERSCRIPT

#include <a_samp>
#include <Double-O-Files_2>
 
#define MAX_GARAGENS 200 // MAXIMUM OF GARAGES
#define MAX_CARS 1 // MAXIMUM CAR GARAGE BY +1
#define COORDENADASGARAGEM -1232.7811279297,-74.612930297852,14.502492904663 // X,Y,Z THE GARAGE (DO NOT PUT SPACES BETWEEN COORDINATES)
#define COR_ERRO 0xAD0000AA
#define COR_SUCESSO 0x00AB00AA
 
forward CarregarGaragens();
forward SalvarGaragens();
forward CreateGarage(playerowner[64], garageid, Float:gx, Float:gy, Float:gz, coment[128], bool:lock);
forward DeletarGaragem(garageid);
forward PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z);
forward GarageToPoint(Float:radi, garageid, Float:x, Float:y, Float:z);
forward FecharGaragem(playerid, garageid);
forward AbrirGaragem(playerid, garageid);
forward SetGaragemComent(garageid, coment[128]);
forward SetGaragemDono(garageid, playerowner[64]);
forward SetGaragemPos(garageid, Float:gx, Float:gy, Float:gz);
forward Creditos();
 
enum pGaragem
{
    Float:cnX,
    Float:cnY,
    Float:cnZ,
    cnLock,
    cnCar,
}
 
new Garagem[MAX_GARAGENS][pGaragem];
new Text3D:LabelEntrada[MAX_GARAGENS];
new Text3D:LabelSaida[MAX_GARAGENS];
new LabelString[MAX_GARAGENS][128];
new NameString[MAX_GARAGENS][64];
new GaragemAtual;
new EditandoGaragem[MAX_PLAYERS];
new bool:Deletado[MAX_GARAGENS];
 
public OnFilterScriptInit()
{
    print("\n--------------------------------------");
    print("         FS by CidadeNovaRP ¬¬");
    print("--------------------------------------\n");
    CarregarGaragens();
    SetTimer("Creditos", 1000*1*60*15, true);
    CreateObject(14776,-1222.58178711,-73.19232178,20.01030540,0.00000000,0.00000000,315.19982910);
    CreateObject(2893,-1226.20849609,-78.41390991,14.47902775,4.00000000,0.00000000,314.72668457);
    CreateObject(2893,-1224.88500977,-79.58795166,14.47902775,4.00000000,0.00000000,315.72119141);
    CreateObject(2893,-1220.97375488,-75.61949158,14.47902679,344.00000000,0.00000000,315.64929199);
    CreateObject(2893,-1222.22424316,-74.27712250,14.47902679,344.00000000,0.00000000,315.22387695);
    CreateObject(1558,-1222.23022461,-74.30402374,14.07644463,0.00000000,0.00000000,315.19995117);
    CreateObject(1558,-1220.96813965,-75.57649994,14.07644463,0.00000000,0.00000000,134.84912109);
    CreateObject(2860,-1220.97290039,-75.57939911,14.53230476,0.00000000,0.00000000,245.51635742);
    return 1;
}
 
public OnFilterScriptExit()
{
    DOF2_Exit();
    return 1;
}
 
stock GetLockGaragem(garageid)
{
    new lock[64];
    if(Garagem[garageid][cnLock] == 0)
    {
        lock = "{00F600}Open";
    }
    else if(Garagem[garageid][cnLock] == 1)
    {
        lock = "{F60000}Close";
    }
    else if(Garagem[garageid][cnLock] == 2)
    {
        lock = "{F6F600}Opening";
    }
    else if(Garagem[garageid][cnLock] == 3)
    {
        lock = "{F6F600}Closing";
    }
    return lock;
}
 
public CarregarGaragens()
{
    new string[256];
    new arquivo[64];
    new arquivoatual[64];
    for(new g=0; g<MAX_GARAGENS; g++)
    {
        format(arquivoatual, sizeof(arquivoatual), "GaragemAtual.inc", g);
        format(arquivo, sizeof(arquivo), "Garagem%d.inc", g);
        if(DOF2_FileExists(arquivo))
        {
            if(Deletado[g] == false)
            {
                new word = g + 10;
                Garagem[g][cnX] = DOF2_GetFloat(arquivo, "X");
                Garagem[g][cnY] = DOF2_GetFloat(arquivo, "Y");
                Garagem[g][cnZ] = DOF2_GetFloat(arquivo, "Z");
                Garagem[g][cnLock] = DOF2_GetInt(arquivo, "Lock");
                format(NameString[g], 64, "%s", DOF2_GetString(arquivo, "Owner", NameString[g]));
                LabelString[g] = DOF2_GetString(arquivo, "Coment", LabelString[g]);
                GaragemAtual = DOF2_GetInt(arquivoatual, "GGID");
                format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", g, LabelString[g], GetLockGaragem(g), NameString[g]);
                LabelEntrada[g] = Create3DTextLabel(string, 0xFFFFFFFF, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ], 30.0, 0, 1 );
                format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", g, LabelString[g], GetLockGaragem(g), NameString[g]);
                LabelSaida[g] = Create3DTextLabel(string, 0xFFFFFFFF, COORDENADASGARAGEM, 30.0, word, 1 );
                printf("Garagem Carregada: %d %d %d \nComentario: %s\nDono: %s", Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ], LabelString[g], NameString[g]);
            }
        }
    }
    return 1;
}
 
public SalvarGaragens()
{
    new arquivo[64];
    new arquivoatual[64];
    for(new g=0; g<MAX_GARAGENS; g++)
    {
        format(arquivoatual, sizeof(arquivoatual), "GaragemAtual.inc", g);
        format(arquivo, sizeof(arquivo), "Garagem%d.inc", g);
        if(DOF2_FileExists(arquivo))
        {
            if(Deletado[g] == false)
            {
                DOF2_CreateFile(arquivo);
                DOF2_SetFloat(arquivo, "X", Garagem[g][cnX]);
                DOF2_SetFloat(arquivo, "Y", Garagem[g][cnY]);
                DOF2_SetFloat(arquivo, "Z", Garagem[g][cnZ]);
                DOF2_SetInt(arquivo, "Lock", Garagem[g][cnLock]);
                DOF2_SetString(arquivo, "Coment", LabelString[g]);
                DOF2_SetString(arquivo, "Owner", NameString[g]);
                if(!DOF2_FileExists(arquivoatual))
                {
                    if(GaragemAtual <= MAX_GARAGENS)
                    {
                        DOF2_CreateFile(arquivoatual);
                        DOF2_SetInt(arquivoatual, "GGID", GaragemAtual);
                    }
                    else
                    {
                        printf("Reached Maximum Garages, increase the MAX_GARAGENS Garages and renew or delete the file 'GaragemAtual'!");
                    }
                }
                else
                {
                    if(GaragemAtual <= MAX_GARAGENS)
                    {
                        DOF2_SetInt(arquivoatual, "GGID", GaragemAtual);
                    }
                    else
                    {
                        printf("Reached Maximum Garages, increase the MAX_GARAGENS Garages and renew or delete the file 'GaragemAtual'!");
                    }
                }
            }
            DOF2_SaveFile();
        }
    }
    return 1;
}
 
public CreateGarage(playerowner[64], garageid, Float:gx, Float:gy, Float:gz, coment[128], bool:lock)
{
    new string[256];
    new arquivo[64];
    format(arquivo, sizeof(arquivo), "Garagem%d.inc", garageid);
    if(!DOF2_FileExists(arquivo))
    {
        if(!GarageToPoint(7.0, garageid, gx, gy, gz))
        {
            if(GaragemAtual <= MAX_GARAGENS)
            {
                DOF2_CreateFile(arquivo);
                new word = garageid + 10;
                Garagem[garageid][cnX] = gx;
                Garagem[garageid][cnY] = gy;
                Garagem[garageid][cnZ] = gz;
                Garagem[garageid][cnLock] = lock;
                NameString[garageid] = playerowner;
                LabelString[garageid] = coment;
                GaragemAtual ++;
                format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
                LabelEntrada[garageid] = Create3DTextLabel(string, 0xFFFFFFFF, gx, gy, gz, 30.0, 0, 1 );
                format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
                LabelSaida[garageid] = Create3DTextLabel(string, 0xFFFFFFFF, COORDENADASGARAGEM, 30.0, word, 1 );
                printf("Garage Built: %d %d %d \nComent: %s\nOwner: %s", Garagem[garageid][cnX], Garagem[garageid][cnY], Garagem[garageid][cnZ], LabelString[garageid], NameString[garageid]);
                SalvarGaragens();
            }
            else
            {
                printf("Reached Maximum Garages, increase the MAX_GARAGENS Garages and renew or delete the file 'GaragemAtual'!");
            }
        }
        else
        {
            printf("There is already a garage at this radius.");
        }
    }
    else
    {
        printf("There is this GarageID.");
    }
    return 1;
}
 
public DeletarGaragem(garageid)
{
    new arquivo[64];
    new string[128];
    format(arquivo, sizeof(arquivo), "Garagem%d.inc", garageid);
    if(!DOF2_FileExists(arquivo))
    {
        printf("There is this GarageID.");
        return 1;
    }
    else
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            for(new v = 0; v < MAX_VEHICLES; v++)
            {
                if(garageid == GetVehicleVirtualWorld(v)-10)
                {
                    if(!IsPlayerInVehicle(i, v))
                    {
                        SetVehicleVirtualWorld(v, 0);
                        SetVehicleToRespawn(v);
                    }
                }
            }
            if(garageid == GetPlayerVirtualWorld(i)-10)
            {
                if(GetPlayerState(i) == PLAYER_STATE_ONFOOT)
                {
                    SetPlayerPos(i, Garagem[garageid][cnX], Garagem[garageid][cnY], Garagem[garageid][cnZ]);
                    SetPlayerVirtualWorld(i, 0);
                    SetPlayerInterior(i, 0);
                    format(string, sizeof(string), "The Garage %d{00AB00} was deleted.", garageid);
                    SendClientMessage(i, COR_SUCESSO, string);
                }
                else
                {
                    new tmpcar = GetPlayerVehicleID(i);
                    SetVehiclePos(tmpcar, Garagem[garageid][cnX], Garagem[garageid][cnY], Garagem[garageid][cnZ]);
                    SetVehicleVirtualWorld(tmpcar, 0);
                    SetPlayerVirtualWorld(i, 0);
                    SetPlayerInterior(i, 0);
                    format(string, sizeof(string), "The Garage %d{00AB00} was deleted.", garageid);
                    SendClientMessage(i, COR_SUCESSO, string);
                }
            }
        }
        DOF2_RemoveFile(arquivo);
        Deletado[garageid] = true;
        Delete3DTextLabel(LabelSaida[garageid]);
        Delete3DTextLabel(LabelEntrada[garageid]);
        printf("Garagem %d foi deletada", garageid);
        SalvarGaragens();
    }
    return 1;
}
 
public SetGaragemComent(garageid, coment[128])
{
    new arquivo[64];
    new string[128];
    format(arquivo, sizeof(arquivo), "Garagem%d.inc", garageid);
    if(!DOF2_FileExists(arquivo))
    {
        printf("There is this GarageID.");
        return 1;
    }
    else
    {
        if(Deletado[garageid] == false)
        {
            printf("The Comment of garage %d has changed", garageid);
            LabelString[garageid] = coment;
            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
            Update3DTextLabelText(LabelEntrada[garageid], 0xFFFFFFFF, string);
            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
            Update3DTextLabelText(LabelSaida[garageid], 0xFFFFFFFF, string);
            SalvarGaragens();
        }
    }
    return 1;
}
 
public SetGaragemDono(garageid, playerowner[64])
{
    new arquivo[64];
    new string[128];
    format(arquivo, sizeof(arquivo), "Garagem%d.inc", garageid);
    if(!DOF2_FileExists(arquivo))
    {
        printf("There is this GarageID.");
        return 1;
    }
    else
    {
        if(Deletado[garageid] == false)
        {
            printf("The owner of Garage %d has changed", garageid);
            NameString[garageid] = playerowner;
            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
            Update3DTextLabelText(LabelEntrada[garageid], 0xFFFFFFFF, string);
            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
            Update3DTextLabelText(LabelSaida[garageid], 0xFFFFFFFF, string);
            SalvarGaragens();
        }
    }
    return 1;
}
 
public SetGaragemPos(garageid, Float:gx, Float:gy, Float:gz)
{
    new arquivo[64];
    new string[128];
    format(arquivo, sizeof(arquivo), "Garagem%d.inc", garageid);
    if(!DOF2_FileExists(arquivo))
    {
        printf("There is this GarageID.");
        return 1;
    }
    else
    {
        if(Deletado[garageid] == false)
        {
            printf("The Post's Garage %d has changed", garageid);
            Garagem[garageid][cnX] = gx;
            Garagem[garageid][cnY] = gy;
            Garagem[garageid][cnZ] = gz;
            Delete3DTextLabel(LabelEntrada[garageid]);
            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
            LabelEntrada[garageid] = Create3DTextLabel(string, 0xFFFFFFFF, gx, gy, gz, 30.0, 0, 1 );
            SalvarGaragens();
        }
    }
    return 1;
}
 
public GarageToPoint(Float:radi, garageid, Float:x, Float:y, Float:z)
{
    for(new g=0; g<MAX_GARAGENS; g++)
    {
        if(Deletado[g] == false)
        {
            new Float:oldposx, Float:oldposy, Float:oldposz;
            new Float:tempposx, Float:tempposy, Float:tempposz;
            oldposx = Garagem[g][cnX];
            oldposy = Garagem[g][cnY];
            oldposz = Garagem[g][cnZ];
            tempposx = (oldposx -x);
            tempposy = (oldposy -y);
            tempposz = (oldposz -z);
            if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
            {
                return 1;
            }
        }
    }
    return 0;
}
 
public PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        tempposx = (oldposx -x);
        tempposy = (oldposy -y);
        tempposz = (oldposz -z);
        if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
        {
            return 1;
        }
    }
    return 0;
}
 
public FecharGaragem(playerid, garageid)
{
    if(Deletado[garageid] == false)
    {
        SendClientMessage(playerid, COR_SUCESSO, "The gate was {F60000}Close {00AB00}fully.");
        Garagem[garageid][cnLock] = 1;
        new string[256];
        format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
        Update3DTextLabelText(LabelEntrada[garageid], 0xFFFFFFFF, string);
        format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
        Update3DTextLabelText(LabelSaida[garageid], 0xFFFFFFFF, string);
        SalvarGaragens();
    }
    return 1;
}
 
public AbrirGaragem(playerid, garageid)
{
    if(Deletado[garageid] == false)
    {
        SendClientMessage(playerid, COR_SUCESSO, "The gate was {00F600}Open {00AB00}fully.");
        Garagem[garageid][cnLock] = 0;
        new string[256];
        format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
        Update3DTextLabelText(LabelEntrada[garageid], 0xFFFFFFFF, string);
        format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", garageid, LabelString[garageid], GetLockGaragem(garageid), NameString[garageid]);
        Update3DTextLabelText(LabelSaida[garageid], 0xFFFFFFFF, string);
        SalvarGaragens();
    }
    return 1;
}
 
public Creditos()
{
    // SendClientMessageToAll(-1, "Garage System made by CidadeNovaRP.");
    return 1;
}
 
public OnPlayerConnect(playerid)
{
    return 1;
}
 
public OnPlayerCommandText(playerid, cmdtext[])
{
 
    if(strcmp(cmdtext, "/cnedit", true) == 0)
    {
        if(IsPlayerAdmin(playerid))
        {
            for(new g=0; g<MAX_GARAGENS; g++)
            {
                if(PlayerToPoint(3.0, playerid, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]))
                {
                    if(Deletado[g] == false)
                    {
                        EditandoGaragem[playerid] = g;
                        ShowPlayerDialog(playerid, 5555, DIALOG_STYLE_MSGBOX, "Create/Edit Garage","Click on 'My Name' for you are the owner or 'Edit' to change the Owner", "My Name", "Edit");
                    }
                }
            }
        }
        return 1;
    }
 
    if(strcmp(cmdtext, "/cncreate", true) == 0)
    {
        if(IsPlayerAdmin(playerid))
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(playerid, x, y, z);
            EditandoGaragem[playerid] = GaragemAtual+1;
            if(!GarageToPoint(7.0, EditandoGaragem[playerid], x, y, z))
            {
                ShowPlayerDialog(playerid, 5555, DIALOG_STYLE_MSGBOX, "Create/Edit Garage","Click on 'My Name' for you are the owner or 'Edit' to change the Owner", "My Name", "Edit");
                CreateGarage("", GaragemAtual+1, x, y, z, "", true);
            }
        }
        return 1;
    }
 
    if(strcmp(cmdtext, "/cndelet", true) == 0)
    {
        if(IsPlayerAdmin(playerid))
        {
            for(new g=0; g<MAX_GARAGENS; g++)
            {
                if(PlayerToPoint(3.0, playerid, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]))
                {
                    if(Deletado[g] == false)
                    {
                        DeletarGaragem(g);
                    }
                }
            }
        }
        return 1;
    }
 
    if (strcmp("/cnclose", cmdtext, true, 10) == 0)
    {
        new string[256];
        new playername[24];
        for(new g=0; g<MAX_GARAGENS; g++)
        {
            if(PlayerToPoint(3.0, playerid, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]) || PlayerToPoint(3.0, playerid, COORDENADASGARAGEM) && g == GetPlayerVirtualWorld(playerid)-10)
            {
                GetPlayerName(playerid,playername,24);
                if(!strcmp(NameString[g],playername,true) || IsPlayerAdmin(playerid))
                {
                    if(Deletado[g] == false)
                    {
                        if(Garagem[g][cnLock] == 0)
                        {
                            SetTimerEx("FecharGaragem", 5000, false, "ii", playerid, g);
                            Garagem[g][cnLock] = 3;
                            SendClientMessage(playerid, COR_SUCESSO, "The Gate is {F6F600}Closing{00AB00}.");
                            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", g, LabelString[g], GetLockGaragem(g), NameString[g]);
                            Update3DTextLabelText(LabelEntrada[g], 0xFFFFFFFF, string);
                            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", g, LabelString[g], GetLockGaragem(g), NameString[g]);
                            Update3DTextLabelText(LabelSaida[g], 0xFFFFFFFF, string);
                            break;
                        }
                        else
                        {
                            format(string, sizeof(string), "The Gate is %s{AD0000}.", GetLockGaragem(g));
                            SendClientMessage(playerid, COR_ERRO, string);
                        }
                    }
                }
                else
                {
                    SendClientMessage(playerid, COR_ERRO, "You are not owner of this garage.");
                }
            }
        }
        return 1;
    }
 
    if (strcmp("/cnopen", cmdtext, true, 10) == 0)
    {
        new string[256];
        new playername[24];
        for(new g=0; g<MAX_GARAGENS; g++)
        {
            if(PlayerToPoint(3.0, playerid, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]) || PlayerToPoint(3.0, playerid, COORDENADASGARAGEM) && g == GetPlayerVirtualWorld(playerid)-10)
            {
                GetPlayerName(playerid,playername,24);
                if(!strcmp(NameString[g],playername,true) || IsPlayerAdmin(playerid))
                {
                    if(Deletado[g] == false)
                    {
                        if(Garagem[g][cnLock] == 1)
                        {
                            SetTimerEx("AbrirGaragem", 5000, false, "ii", playerid, g);
                            Garagem[g][cnLock] = 2;
                            SendClientMessage(playerid, COR_SUCESSO, "The Gate is {F6F600}Opening{00AB00}.");
                            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Entry\n%s\n{ED6B79}Owner: %s%s", g, LabelString[g], GetLockGaragem(g), NameString[g]);
                            Update3DTextLabelText(LabelEntrada[g], 0xFFFFFFFF, string);
                            format(string, sizeof(string), "{0000F6}[GARAGE ID: %d]\n{00F6F6}%s\n{0000F6}Exit\n%s\n{ED6B79}Owner: %s%s", g, LabelString[g], GetLockGaragem(g), NameString[g]);
                            Update3DTextLabelText(LabelSaida[g], 0xFFFFFFFF, string);
                            break;
                        }
                        else
                        {
                            format(string, sizeof(string), "The Gate is %s{AD0000}.", GetLockGaragem(g));
                            SendClientMessage(playerid, COR_ERRO, string);
                        }
                    }
                }
                else
                {
                    SendClientMessage(playerid, COR_ERRO, "You are not owner of this garage.");
                }
            }
        }
        return 1;
    }
 
    if (strcmp("/cnentry", cmdtext, true, 10) == 0)
    {
        new string[64];
        for(new g=0; g<MAX_GARAGENS; g++)
        {
            if(PlayerToPoint(3.0, playerid, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]))
            {
                if(Garagem[g][cnLock] == 0)
                {
                    if(Deletado[g] == false)
                    {
                        if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
                        {
                            SetPlayerPos(playerid, COORDENADASGARAGEM);
                            SetPlayerVirtualWorld(playerid, g+10);
                            SetPlayerInterior(playerid, 2);
                            format(string, sizeof(string), "Welcome to Garage %d.", g);
                            SendClientMessage(playerid, COR_SUCESSO, string);
                        }
                        else
                        {
                            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
                            {
                                if(Garagem[g][cnCar] <= MAX_CARS)
                                {
                                    for(new i = 0; i < MAX_PLAYERS; i++)
                                    {
                                        new tmpcar = GetPlayerVehicleID(playerid);
                                        if(IsPlayerInVehicle(i, tmpcar))
                                        {
                                            SetPlayerVirtualWorld(i, g+10);
                                            SetPlayerInterior(playerid, 2);
                                            Garagem[g][cnCar] ++;
                                            SetVehicleVirtualWorld(tmpcar, g+10);
                                            LinkVehicleToInterior(tmpcar, 2);
                                            SetVehiclePos(tmpcar, COORDENADASGARAGEM);
                                            format(string, sizeof(string), "Welcome to Garage %d.", g);
                                            SendClientMessage(i, COR_SUCESSO, string);
                                        }
                                    }
                                }
                                else
                                {
                                    SendClientMessage(playerid, COR_ERRO, "You already have the maximum accepted vehicles in the garage.");
                                }
                            }
                            else
                            {
                                SendClientMessage(playerid, COR_ERRO, "Drivers can only enter and exit the garage.");
                            }
                        }
                    }
                }
                else
                {
                    format(string, sizeof(string), "The Gate is %s{AD0000}.", GetLockGaragem(g));
                    SendClientMessage(playerid, COR_ERRO, string);
                    break;
                }
            }
        }
        return 1;
    }
 
    if (strcmp("/cnexit", cmdtext, true, 10) == 0)
    {
        new string[128];
        for(new g=0; g<MAX_GARAGENS; g++)
        {
            if(g == GetPlayerVirtualWorld(playerid)-10)
            {
                if(PlayerToPoint(3.0, playerid, COORDENADASGARAGEM))
                {
                    if(Garagem[g][cnLock] == 0)
                    {
                        if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
                        {
                            SetPlayerPos(playerid, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]);
                            SetPlayerVirtualWorld(playerid, 0);
                            SetPlayerInterior(playerid, 0);
                            format(string, sizeof(string), "Return always the Garage %d.", g);
                            SendClientMessage(playerid, COR_SUCESSO, string);
                        }
                        else
                        {
                            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
                            {
                                for(new i = 0; i < MAX_PLAYERS; i++)
                                {
                                    new tmpcar = GetPlayerVehicleID(playerid);
                                    if(IsPlayerInVehicle(i, tmpcar))
                                    {
                                        SetPlayerVirtualWorld(i, 0);
                                        SetPlayerInterior(playerid, 0);
                                        Garagem[g][cnCar] --;
                                        SetVehicleVirtualWorld(tmpcar, 0);
                                        LinkVehicleToInterior(tmpcar, 0);
                                        SetVehiclePos(tmpcar, Garagem[g][cnX], Garagem[g][cnY], Garagem[g][cnZ]);
                                        format(string, sizeof(string), "Return always the Garage %d.", g);
                                        SendClientMessage(i, COR_SUCESSO, string);
                                    }
                                }
                            }
                            else
                            {
                                SendClientMessage(playerid, COR_ERRO, "Drivers can only enter and exit the garage.");
                            }
                        }
                    }
                    else
                    {
                        format(string, sizeof(string), "The Gate is %s{AD0000}.", GetLockGaragem(g));
                        SendClientMessage(playerid, COR_ERRO, string);
                        break;
                    }
                }
            }
        }
        return 1;
    }
    return 0;
}
 
public OnVehicleSpawn(vehicleid)
{
    for(new g=0; g<MAX_GARAGENS; g++)
    {
        if(g == GetVehicleVirtualWorld(vehicleid)-10)
        {
            SetVehicleVirtualWorld(vehicleid, 0);
            Garagem[g][cnCar] --;
        }
    }
    return 1;
}
 
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 5555)
    {
        if(response)
        {
            new playername[64];
            GetPlayerName(playerid, playername, sizeof(playername));
            SetGaragemDono(EditandoGaragem[playerid], playername);
            ShowPlayerDialog(playerid, 5557, DIALOG_STYLE_INPUT, "Create/Edit Garage", "Enter a Comment that will appear in the Label\nNote: If you do not want to leave the space blank and go", "End", "");
        }
        else
        {
            ShowPlayerDialog(playerid, 5556, DIALOG_STYLE_INPUT, "Create/Edit Garage", "Enter Nick the owner (not the ID)\nNote: Whether the player is online or not\nNote: If you do not want to leave the space blank and go", "Next", "");
        }
    }
    if(dialogid == 5556)
    {
        if(response)
        {
            if(!strlen(inputtext))
            {
                SetGaragemDono(EditandoGaragem[playerid], "Nobody");
                ShowPlayerDialog(playerid, 5557, DIALOG_STYLE_INPUT, "Create/Edit Garage", "Enter a Comment that will appear in the Label\nNote: If you do not want to leave the space blank and go", "End", "");
            }
            else
            {
                new string[64];
                format(string, sizeof(string), "%s", inputtext);
                SetGaragemDono(EditandoGaragem[playerid], string);
                ShowPlayerDialog(playerid, 5557, DIALOG_STYLE_INPUT, "Create/Edit Garage", "Enter a Comment that will appear in the Label\nNote: If you do not want to leave the space blank and go", "End", "");
            }
        }
        else
        {
        }
    }
    if(dialogid == 5557)
    {
        if(response)
        {
            if(!strlen(inputtext))
            {
                new string[128];
                format(string, sizeof(string), "No Comment");
                SetGaragemComent(EditandoGaragem[playerid], string);
            }
            else
            {
                new string[128];
                format(string, sizeof(string), "%s", inputtext);
                SetGaragemComent(EditandoGaragem[playerid], string);
            }
        }
        else
        {
        }
    }
    return 1;
}