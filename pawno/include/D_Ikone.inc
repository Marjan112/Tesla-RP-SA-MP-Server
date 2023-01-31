//******************************************************************************
//******************************************************************************
//**          ********   ***   *****   ***         ***   ****   ****           *
//**   ***     *******   ***   ***    ****   ***   ***   ****   ****   *********
//**   *****    ******   ***   *    ******   ***   ***   **     ****   *********
//**   *******   *****   ***      ********   ***   ***   *      ****   *********
//**   *******   *****   ***    **********   ***   ***      *   ****        ****
//**   *******   *****   ***      ********   ***   ***     **   ****   *********
//**   *****    ******   ***   *    ******   ***   ***    ***   ****   *********
//**   ***     *******   ***   ***    ****   ***   ***   ****   ****   *********
//**         ***    **   ***   *****   ***         ***   ****   ****           *
//******************************************************************************
//*                                               by Zoran aka Djuro_Zerocoolos*
//******************************************************************************
//verzija 1.0
//Datum pravljenja: 27.4.2010
#include <a_samp>
//Funkcije
// D_KreirajIkonu(Float:x, Float:y, Float:z, tipmarkera, boja);
// D_UnistiIkonu(idikone);
// UnistiSveIkone(playerid);

//******************************************************************************
//--------------- [ POSTAVKE ] -------------------------------------------------
#define MAX_BROJ_IKONA 300//ovdje upisite max broj mapikona  koliko imate u svom modu
#define VrijemeProvjereIkona 1843//ovdje podesite vrijeme provjere mapikona
#define UDALJENOST_STREAMANJA 200.0//udaljenost na kojoj se streamaju mapikona
#define MAX_PRIKAZANIH_IGRACU 15//koliko ce maksimalno biti prikazano mapikona igracu
//******************************************************************************
//Definiranje varijabli za ikone
new Float:LokacijaIkoneX[MAX_BROJ_IKONA];
new Float:LokacijaIkoneY[MAX_BROJ_IKONA];
new Float:LokacijaIkoneZ[MAX_BROJ_IKONA];
new TipIkone[MAX_BROJ_IKONA];
new BojaIkone[MAX_BROJ_IKONA];
new bool:JelIkonaKreirana[MAX_BROJ_IKONA];
//----------------------------------------
new IkonaPrikazana[MAX_PLAYERS][MAX_BROJ_IKONA];
new kolkoikonakreir[MAX_PLAYERS];
new imaihukupno = 0;
new ikonetimer;
new bool:jeltimerpokrenut;

forward ProvjeraIkonaTimer();
//kreiranje mapiconu
stock D_KreirajIkonu(Float:x, Float:y, Float:z, tipmarkera, boja)//definiranje
{
     new idikone = 0;
	 if(imaihukupno > MAX_BROJ_IKONA)
	 {
		 printf("[greska] - dosegnut maksimalan broj ikona");
		 return 1;
	 }
	 if(jeltimerpokrenut == false)//provjerava jel timer pokrenut ako nije pokrece ga
	 {
	      ikonetimer=SetTimer("ProvjeraIkonaTimer", VrijemeProvjereIkona, true);
	      printf("[NL:RPG] Ucitano %d ikona.", imaihukupno);
          jeltimerpokrenut = true;
	 }
     for(new i = 0; i < (MAX_BROJ_IKONA+1); i++)//trazi prvi slobodan id mapicone
     {
		if(JelIkonaKreirana[i]==false)
		{
     	    LokacijaIkoneX[i]=x;
         	LokacijaIkoneY[i]=y;
          	LokacijaIkoneZ[i]=z;
          	TipIkone[i]=tipmarkera;
          	BojaIkone[i]=boja;
          	JelIkonaKreirana[i]=true;
          	idikone =i;
          	imaihukupno +=1;
          	return 1;
		}
     }
     return idikone;
}
//unistava mapiconu igraca
stock D_UnistiIkonu(idikone)
{
	if(JelIkonaKreirana[idikone]==true)
	{
 		for(new i = 0; i < MAX_PLAYERS; i++)//provjera jel nekome prikazana ta mapikona
 		{
	 		if(IsPlayerConnected(i))
	 		{
	             if(IkonaPrikazana[i][idikone]==1)
	             {
	                IkonaPrikazana[i][idikone]=0;
	                RemovePlayerMapIcon(i, idikone);
                    kolkoikonakreir[i] -=1;
	             }
		 	}
	 	}
     	LokacijaIkoneX[idikone]=0.000000;
        LokacijaIkoneY[idikone]=0.000000;
        LokacijaIkoneZ[idikone]=0.000000;
        JelIkonaKreirana[idikone]=false;
        TipIkone[idikone]=999;
	}
	return 0;
}
//timer koji pokrece provjeru mapiconu za svakog online igraca
public ProvjeraIkonaTimer()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		     ProvjeriIkone(i);
		}
	}
    return 1;
}
//provjera prikazanih/onih koje treba prikazati mapiconu igracu
stock ProvjeriIkone(playerid)
{
    for(new i = 0; i < MAX_BROJ_IKONA; i++)
    {
        if(JelIkonaKreirana[i]==true)
        {
        	if(IsPlayerInRangeOfPoint(playerid, UDALJENOST_STREAMANJA, LokacijaIkoneX[i],LokacijaIkoneY[i],LokacijaIkoneZ[i]))
			{
		    	if(IkonaPrikazana[playerid][i]==0)
		    	{
				  	if(kolkoikonakreir[playerid] < MAX_PRIKAZANIH_IGRACU)
				  	{
                       	SetPlayerMapIcon(playerid, i, LokacijaIkoneX[i], LokacijaIkoneY[i], LokacijaIkoneZ[i], TipIkone[i], BojaIkone[i]);
                       	IkonaPrikazana[playerid][i] = 1;
				       	kolkoikonakreir[playerid]+=1;
				  	}
				}
			}
			else
			{
		    	if(IkonaPrikazana[playerid][i]==1)
		    	{
			    	RemovePlayerMapIcon(playerid, i);
                 	kolkoikonakreir[playerid] -=1;
                 	IkonaPrikazana[playerid][i]=0;
		    	}
			}
	    }
    }
//Debug - ukoliko zelite vidjeti u svakom trenutku koliko ima mapikona kreiranih za vas!
/*	if(IsPlayerAdmin(playerid))
	{
       new string[128];
       format(string, sizeof(string), "~n~~n~~n~~n~~r~Ikona Kreiranih: ~w~%d", kolkoikonakreir[playerid]);
       GameTextForPlayer(playerid, string, VrijemeProvjereIkona, 3);
    }*/
}
//Unistava sve mapicone za odredjenog igraca!
stock UnistiSveIkone(playerid)
{
    for(new i = 0; i < MAX_BROJ_IKONA; i++)
    {
        if(JelIkonaKreirana[i]==true)
        {
			 if(IkonaPrikazana[playerid][i]==1)
			 {
			     RemovePlayerMapIcon(playerid, i);
                 kolkoikonakreir[playerid] -=1;
			 }
		}
    }
    return 0;
}
