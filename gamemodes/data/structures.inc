#if defined _structures_included
	#endinput
#endif
#define _structures_included

#include "../gamemodes/data/macros.inc"

#pragma library Structures

enum orgInfo {
	orgIme[128],
	orgLeader[128],
	orgMember1[128],
	orgMember2[128],
	orgMember3[128],
	orgMember4[128],
	orgMember5[128],
	orgMember6[128],
	orgMember7[128],
	orgMember8[128],
	orgMember9[128],
	orgMember10[128],
	orgMember11[128],
	orgMember12[128],
	orgMember13[128],
	orgMember14[128],
	orgMember15[128],
	orgMember16[128],
	orgMember17[128],
	orgMember18[128],
	orgMember19[128],
	orgMember20[128],
	orgMember21[128],
	orgMember22[128],
	orgMember23[128],
	orgMember24[128],
	orgMember25[128],
	orgMember26[128],
	orgMember27[128],
	orgMember28[128],
	orgMember29[128],
	orgMember30[128],
	orgMember31[128],
	orgMember32[128],
	orgMember33[128],
	orgMember34[128],
	orgMember35[128],
	orgMember36[128],
	orgMember37[128],
	orgMember38[128],
	orgMember39[128],
	orgMember40[128],
	orgMember41[128],
	orgMember42[128],
	orgMember43[128],
	orgMember44[128],
	orgMember45[128],
	orgMember46[128],
	orgMember47[128],
	orgMember48[128],
	orgMember49[128],
	orgMember50[128],
	orgMoney,
	orgMats,
	orgDrugs,
	orgGlock19,
	orgAK_47,
	orgM4,
	orgLisice,
	orgDrzavna[3],
	Float: orgX,
	Float: orgY,
	Float: orgZ
};
new OrgInfo[MAX_ORGS][orgInfo];

enum hInfo {
	hOwner[128],
	hOwned,
	hCena,
	hLevel,
	hNeaktivnost,
	hRent[128],
	hRented,
	hOnRent[3],
	Float: hX,
	Float: hY,
	Float: hZ,
	hInterID,
	Float: hInterX,
	Float: hInterY,
	Float: hInterZ,
	hVirtualWorld
};
new HouseInfo[MAX_HOUSES][hInfo];

enum promInfo {
	promName[128],
	promDuty,
	promNeaktivnost
};
new PromInfo[MAX_PROMS][promInfo];
new bool:PDuty[MAX_PLAYERS];

enum bInfo {
	bName[128]
}
new BannedInfo[MAX_PLAYERS+1][bInfo];

enum vInfo {
	vEngine,
	vLights,
	vAlarm,
	vDoor,
	vBonnet,
	vBoot,
	vObj,
	vFuel,
	vLock,
	vOwner[128],
	Float: vX,
	Float: vY,
	Float: vZ,
	Float: vRX,
	Float: vRY,
	Float: vRZ
};
new VehInfo[MAX_VEHICLES][vInfo];

enum aInfo {
	aName[128],
	aNeaktivnost,
	aDuty
};
new AdminInfo[MAX_ADMINS][aInfo];
new bool: pADuty[MAX_PLAYERS];

enum pInfo {
	pLozinka,
	pNovac,
	pGodine,
	pRespekti,
	pNeededRep,
	pAdmin,
	pBan,
	pBanRazlog[128],
	pPromoter[3],
	Float: pSpawnX,
	Float: pSpawnY,
	Float: pSpawnZ,
	Float: pSpawnAng,
	pSpawnInter,
	pKuca,
	pOrganizacija[128],
	pLeader,
	pRentHouse,
	pRacun[3],
	pBanka,
	pRate,
	pKredit,
	pCigare,
	pHrana,
	pVoda,
	pPanciri,
	pDroga,
	pLisice,
	pPosao[128],
	pVozackaDozvola[128],
	pGlock19,
	pAK_47,
	pM4,
	pGlock19Municija,
	pAK_47Municija,
	pM4Municija,
	pZatvoren[128],
	pZavezan[128],
	pSkin,
	pIP[32],
	pGraze,
	pAuto,
	pAuto1,
	pAuto2,
	pAuto3
};
new PlayerInfo[MAX_PLAYERS+1][pInfo];