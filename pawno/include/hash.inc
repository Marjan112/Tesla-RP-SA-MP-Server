#if defined _hash_inc
	#endinput
#endif
#define _hash_inc
#pragma library hash

native hhash(algid, input[], buffer[], buflen);
native hhash_hmac(algid, input[], key[], buffer[], buflen);

#define H_MD5			1
#define H_SHA1			2
#define H_SHA256		3
#define H_SHA512		4
#define H_RIPEMD160		5
#define H_WHIRLPOOL		6

#define H_MD5_LEN	32
#define H_SHA1_LEN	40
#define H_SHA256_LEN	64
#define H_SHA512_LEN	128
#define H_RIPEMD160_LEN	40
#define H_WHIRLPOOL_LEN	128