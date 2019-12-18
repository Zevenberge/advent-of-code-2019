/* Generated by Nim Compiler v0.12.0 */
/*   (c) 2015 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Linux, amd64, gcc */
/* Command for C compiler:
   gcc -c  -w  -I/usr/lib/nim -o /home/marco/saus/advent-of-code-2019/17.nim/nimcache/hashes.o /home/marco/saus/advent-of-code-2019/17.nim/nimcache/hashes.c */
#define NIM_INTBITS 64

#include "nimbase.h"
typedef struct NimStringDesc NimStringDesc;
typedef struct TGenericSeq TGenericSeq;
struct  TGenericSeq  {
NI len;
NI reserved;
};
struct  NimStringDesc  {
  TGenericSeq Sup;
NIM_CHAR data[SEQ_DECL_SIZE];
};
static N_INLINE(NI, HEX21HEX26_142013)(NI h, NI val);
static N_INLINE(void, nimFrame)(TFrame* s);
N_NOINLINE(void, stackoverflow_23601)(void);
static N_INLINE(void, popFrame)(void);
static N_INLINE(NI, HEX21HEX24_142042)(NI h);
N_NIMCALL(NI, hashdata_142070)(void* data, NI size);
static N_INLINE(NI, addInt)(NI a, NI b);
N_NOINLINE(void, raiseOverflow)(void);
static N_INLINE(NI, subInt)(NI a, NI b);
static N_INLINE(NI, hash_142401)(void* x);
static N_INLINE(NI, hash_142804)(NI x);
static N_INLINE(NI, hash_142814)(NI64 x);
static N_INLINE(NI, hash_142824)(NIM_CHAR x);
N_NIMCALL(NI, hash_142851)(NimStringDesc* x);
N_NOINLINE(void, raiseIndexError)(void);
N_NIMCALL(NI, hash_142899)(NimStringDesc* sbuf, NI spos, NI epos);
N_NIMCALL(NI, hashignorestyle_142948)(NimStringDesc* x);
static N_INLINE(NIM_BOOL, ismagicidentseparatorrune_141020)(NCSTRING cs, NI i);
static N_INLINE(NI, chckRange)(NI i, NI a, NI b);
N_NOINLINE(void, raiseRangeError)(NI64 val);
N_NIMCALL(NI, hashignorestyle_143043)(NimStringDesc* sbuf, NI spos, NI epos);
N_NIMCALL(NI, hashignorecase_143139)(NimStringDesc* x);
N_NIMCALL(NI, hashignorecase_143226)(NimStringDesc* sbuf, NI spos, NI epos);
static N_INLINE(NI, hash_143314)(NF x);
extern TFrame* frameptr_20842;

static N_INLINE(void, nimFrame)(TFrame* s) {
	NI LOC1;
	LOC1 = 0;
	{
		if (!(frameptr_20842 == NIM_NIL)) goto LA4;
		LOC1 = ((NI) 0);
	}
	goto LA2;
	LA4: ;
	{
		LOC1 = ((NI) ((NI16)((*frameptr_20842).calldepth + ((NI16) 1))));
	}
	LA2: ;
	(*s).calldepth = ((NI16) (LOC1));
	(*s).prev = frameptr_20842;
	frameptr_20842 = s;
	{
		if (!((*s).calldepth == ((NI16) 2000))) goto LA9;
		stackoverflow_23601();
	}
	LA9: ;
}

static N_INLINE(void, popFrame)(void) {
	frameptr_20842 = (*frameptr_20842).prev;
}

static N_INLINE(NI, HEX21HEX26_142013)(NI h, NI val) {
	NI result;
	nimfr("!&", "hashes.nim")
	result = 0;
	nimln(53, "hashes.nim");
	result = (NI)((NU64)(h) + (NU64)(val));
	nimln(54, "hashes.nim");
	result = (NI)((NU64)(result) + (NU64)((NI)((NU64)(result) << (NU64)(((NI) 10)))));
	nimln(55, "hashes.nim");
	result = (NI)(result ^ (NI)((NU64)(result) >> (NU64)(((NI) 6))));
	popFrame();
	return result;
}

static N_INLINE(NI, HEX21HEX24_142042)(NI h) {
	NI result;
	nimfr("!$", "hashes.nim")
	result = 0;
	nimln(60, "hashes.nim");
	result = (NI)((NU64)(h) + (NU64)((NI)((NU64)(h) << (NU64)(((NI) 3)))));
	nimln(61, "hashes.nim");
	result = (NI)(result ^ (NI)((NU64)(result) >> (NU64)(((NI) 11))));
	nimln(62, "hashes.nim");
	result = (NI)((NU64)(result) + (NU64)((NI)((NU64)(result) << (NU64)(((NI) 15)))));
	popFrame();
	return result;
}

static N_INLINE(NI, addInt)(NI a, NI b) {
	NI result;
{	result = 0;
	result = (NI)((NU64)(a) + (NU64)(b));
	{
		NIM_BOOL LOC3;
		LOC3 = 0;
		LOC3 = (((NI) 0) <= (NI)(result ^ a));
		if (LOC3) goto LA4;
		LOC3 = (((NI) 0) <= (NI)(result ^ b));
		LA4: ;
		if (!LOC3) goto LA5;
		goto BeforeRet;
	}
	LA5: ;
	raiseOverflow();
	}BeforeRet: ;
	return result;
}

static N_INLINE(NI, subInt)(NI a, NI b) {
	NI result;
{	result = 0;
	result = (NI)((NU64)(a) - (NU64)(b));
	{
		NIM_BOOL LOC3;
		LOC3 = 0;
		LOC3 = (((NI) 0) <= (NI)(result ^ a));
		if (LOC3) goto LA4;
		LOC3 = (((NI) 0) <= (NI)(result ^ (NI)((NU64) ~(b))));
		LA4: ;
		if (!LOC3) goto LA5;
		goto BeforeRet;
	}
	LA5: ;
	raiseOverflow();
	}BeforeRet: ;
	return result;
}

N_NIMCALL(NI, hashdata_142070)(void* data, NI size) {
	NI result;
	NI h;
	NCSTRING p;
	NI i;
	NI s;
	nimfr("hashData", "hashes.nim")
	result = 0;
	nimln(66, "hashes.nim");
	h = ((NI) 0);
	nimln(71, "hashes.nim");
	p = ((NCSTRING) (data));
	nimln(72, "hashes.nim");
	i = ((NI) 0);
	nimln(73, "hashes.nim");
	s = size;
	{
		nimln(74, "hashes.nim");
		while (1) {
			NI TMP537;
			NI TMP538;
			nimln(357, "system.nim");
			if (!(((NI) 0) < s)) goto LA2;
			nimln(75, "hashes.nim");
			h = HEX21HEX26_142013(h, ((NI) (((NU8)(p[i])))));
			nimln(76, "hashes.nim");
			TMP537 = addInt(i, ((NI) 1));
			i = (NI)(TMP537);
			nimln(77, "hashes.nim");
			TMP538 = subInt(s, ((NI) 1));
			s = (NI)(TMP538);
		} LA2: ;
	}
	nimln(78, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

static N_INLINE(NI, hash_142401)(void* x) {
	NI result;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(97, "hashes.nim");
	result = (NI)((NU64)(((NI) (x))) >> (NU64)(((NI) 3)));
	popFrame();
	return result;
}

static N_INLINE(NI, hash_142804)(NI x) {
	NI result;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(109, "hashes.nim");
	result = x;
	popFrame();
	return result;
}

static N_INLINE(NI, hash_142814)(NI64 x) {
	NI result;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(113, "hashes.nim");
	result = ((NI) (((NI32)(NU32)(NU64)(x))));
	popFrame();
	return result;
}

static N_INLINE(NI, hash_142824)(NIM_CHAR x) {
	NI result;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(117, "hashes.nim");
	result = ((NI) (((NU8)(x))));
	popFrame();
	return result;
}

N_NIMCALL(NI, hash_142851)(NimStringDesc* x) {
	NI result;
	NI h;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(125, "hashes.nim");
	h = ((NI) 0);
	{
		NI i_142866;
		NI HEX3Atmp_142877;
		NI TMP539;
		NI res_142880;
		i_142866 = 0;
		HEX3Atmp_142877 = 0;
		nimln(126, "hashes.nim");
		TMP539 = subInt((x ? x->Sup.len : 0), ((NI) 1));
		HEX3Atmp_142877 = (NI)(TMP539);
		nimln(1874, "system.nim");
		res_142880 = ((NI) 0);
		{
			nimln(1875, "system.nim");
			while (1) {
				NI TMP540;
				if (!(res_142880 <= HEX3Atmp_142877)) goto LA3;
				nimln(1876, "system.nim");
				i_142866 = res_142880;
				nimln(127, "hashes.nim");
				if ((NU)(i_142866) > (NU)(x->Sup.len)) raiseIndexError();
				h = HEX21HEX26_142013(h, ((NI) (((NU8)(x->data[i_142866])))));
				nimln(1895, "system.nim");
				TMP540 = addInt(res_142880, ((NI) 1));
				res_142880 = (NI)(TMP540);
			} LA3: ;
		}
	}
	nimln(128, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

N_NIMCALL(NI, hash_142899)(NimStringDesc* sbuf, NI spos, NI epos) {
	NI result;
	NI h;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(135, "hashes.nim");
	h = ((NI) 0);
	{
		NI i_142916;
		NI res_142929;
		i_142916 = 0;
		nimln(1874, "system.nim");
		res_142929 = spos;
		{
			nimln(1875, "system.nim");
			while (1) {
				NI TMP541;
				if (!(res_142929 <= epos)) goto LA3;
				nimln(1876, "system.nim");
				i_142916 = res_142929;
				nimln(137, "hashes.nim");
				if ((NU)(i_142916) > (NU)(sbuf->Sup.len)) raiseIndexError();
				h = HEX21HEX26_142013(h, ((NI) (((NU8)(sbuf->data[i_142916])))));
				nimln(1895, "system.nim");
				TMP541 = addInt(res_142929, ((NI) 1));
				res_142929 = (NI)(TMP541);
			} LA3: ;
		}
	}
	nimln(138, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

static N_INLINE(NIM_BOOL, ismagicidentseparatorrune_141020)(NCSTRING cs, NI i) {
	NIM_BOOL result;
	NIM_BOOL LOC1;
	NIM_BOOL LOC2;
	NI TMP543;
	NI TMP544;
	nimfr("isMagicIdentSeparatorRune", "etcpriv.nim")
	result = 0;
	nimln(21, "etcpriv.nim");
	nimln(22, "etcpriv.nim");
	LOC1 = 0;
	nimln(21, "etcpriv.nim");
	LOC2 = 0;
	LOC2 = ((NU8)(cs[i]) == (NU8)(226));
	if (!(LOC2)) goto LA3;
	nimln(22, "etcpriv.nim");
	TMP543 = addInt(i, ((NI) 1));
	LOC2 = ((NU8)(cs[(NI)(TMP543)]) == (NU8)(128));
	LA3: ;
	LOC1 = LOC2;
	if (!(LOC1)) goto LA4;
	nimln(23, "etcpriv.nim");
	TMP544 = addInt(i, ((NI) 2));
	LOC1 = ((NU8)(cs[(NI)(TMP544)]) == (NU8)(147));
	LA4: ;
	result = LOC1;
	popFrame();
	return result;
}

static N_INLINE(NI, chckRange)(NI i, NI a, NI b) {
	NI result;
{	result = 0;
	{
		NIM_BOOL LOC3;
		LOC3 = 0;
		LOC3 = (a <= i);
		if (!(LOC3)) goto LA4;
		LOC3 = (i <= b);
		LA4: ;
		if (!LOC3) goto LA5;
		result = i;
		goto BeforeRet;
	}
	goto LA1;
	LA5: ;
	{
		raiseRangeError(((NI64) (i)));
	}
	LA1: ;
	}BeforeRet: ;
	return result;
}

N_NIMCALL(NI, hashignorestyle_142948)(NimStringDesc* x) {
	NI result;
	NI h;
	NI i;
	NI xlen;
	nimfr("hashIgnoreStyle", "hashes.nim")
	result = 0;
	nimln(142, "hashes.nim");
	h = ((NI) 0);
	nimln(143, "hashes.nim");
	i = ((NI) 0);
	nimln(144, "hashes.nim");
	xlen = (x ? x->Sup.len : 0);
	{
		nimln(145, "hashes.nim");
		while (1) {
			NIM_CHAR c;
			if (!(i < xlen)) goto LA2;
			nimln(146, "hashes.nim");
			if ((NU)(i) > (NU)(x->Sup.len)) raiseIndexError();
			c = x->data[i];
			nimln(147, "hashes.nim");
			{
				NI TMP542;
				if (!((NU8)(c) == (NU8)(95))) goto LA5;
				nimln(148, "hashes.nim");
				TMP542 = addInt(i, ((NI) 1));
				i = (NI)(TMP542);
			}
			goto LA3;
			LA5: ;
			{
				NIM_BOOL LOC8;
				NI TMP545;
				nimln(149, "hashes.nim");
				LOC8 = 0;
				LOC8 = ismagicidentseparatorrune_141020(x->data, i);
				if (!LOC8) goto LA9;
				nimln(150, "hashes.nim");
				TMP545 = addInt(i, ((NI) 3));
				i = (NI)(TMP545);
			}
			goto LA3;
			LA9: ;
			{
				NI TMP547;
				nimln(152, "hashes.nim");
				{
					NI TMP546;
					nimln(1098, "system.nim");
					if (!(((NU8)(c)) >= ((NU8)(65)) && ((NU8)(c)) <= ((NU8)(90)))) goto LA14;
					nimln(153, "hashes.nim");
					TMP546 = addInt(((NI) (((NU8)(c)))), ((NI) 32));
					c = ((NIM_CHAR) (((NI)chckRange((NI)(TMP546), ((NI) 0), ((NI) 255)))));
				}
				LA14: ;
				nimln(154, "hashes.nim");
				h = HEX21HEX26_142013(h, ((NI) (((NU8)(c)))));
				nimln(155, "hashes.nim");
				TMP547 = addInt(i, ((NI) 1));
				i = (NI)(TMP547);
			}
			LA3: ;
		} LA2: ;
	}
	nimln(157, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

N_NIMCALL(NI, hashignorestyle_143043)(NimStringDesc* sbuf, NI spos, NI epos) {
	NI result;
	NI h;
	NI i;
	nimfr("hashIgnoreStyle", "hashes.nim")
	result = 0;
	nimln(165, "hashes.nim");
	h = ((NI) 0);
	nimln(166, "hashes.nim");
	i = spos;
	{
		nimln(167, "hashes.nim");
		while (1) {
			NIM_CHAR c;
			if (!(i <= epos)) goto LA2;
			nimln(168, "hashes.nim");
			if ((NU)(i) > (NU)(sbuf->Sup.len)) raiseIndexError();
			c = sbuf->data[i];
			nimln(169, "hashes.nim");
			{
				NI TMP548;
				if (!((NU8)(c) == (NU8)(95))) goto LA5;
				nimln(170, "hashes.nim");
				TMP548 = addInt(i, ((NI) 1));
				i = (NI)(TMP548);
			}
			goto LA3;
			LA5: ;
			{
				NIM_BOOL LOC8;
				NI TMP549;
				nimln(171, "hashes.nim");
				LOC8 = 0;
				LOC8 = ismagicidentseparatorrune_141020(sbuf->data, i);
				if (!LOC8) goto LA9;
				nimln(172, "hashes.nim");
				TMP549 = addInt(i, ((NI) 3));
				i = (NI)(TMP549);
			}
			goto LA3;
			LA9: ;
			{
				NI TMP551;
				nimln(174, "hashes.nim");
				{
					NI TMP550;
					nimln(1098, "system.nim");
					if (!(((NU8)(c)) >= ((NU8)(65)) && ((NU8)(c)) <= ((NU8)(90)))) goto LA14;
					nimln(175, "hashes.nim");
					TMP550 = addInt(((NI) (((NU8)(c)))), ((NI) 32));
					c = ((NIM_CHAR) (((NI)chckRange((NI)(TMP550), ((NI) 0), ((NI) 255)))));
				}
				LA14: ;
				nimln(176, "hashes.nim");
				h = HEX21HEX26_142013(h, ((NI) (((NU8)(c)))));
				nimln(177, "hashes.nim");
				TMP551 = addInt(i, ((NI) 1));
				i = (NI)(TMP551);
			}
			LA3: ;
		} LA2: ;
	}
	nimln(178, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

N_NIMCALL(NI, hashignorecase_143139)(NimStringDesc* x) {
	NI result;
	NI h;
	nimfr("hashIgnoreCase", "hashes.nim")
	result = 0;
	nimln(182, "hashes.nim");
	h = ((NI) 0);
	{
		NI i_143154;
		NI HEX3Atmp_143204;
		NI TMP552;
		NI res_143207;
		i_143154 = 0;
		HEX3Atmp_143204 = 0;
		nimln(183, "hashes.nim");
		TMP552 = subInt((x ? x->Sup.len : 0), ((NI) 1));
		HEX3Atmp_143204 = (NI)(TMP552);
		nimln(1874, "system.nim");
		res_143207 = ((NI) 0);
		{
			nimln(1875, "system.nim");
			while (1) {
				NIM_CHAR c;
				NI TMP554;
				if (!(res_143207 <= HEX3Atmp_143204)) goto LA3;
				nimln(1876, "system.nim");
				i_143154 = res_143207;
				nimln(184, "hashes.nim");
				if ((NU)(i_143154) > (NU)(x->Sup.len)) raiseIndexError();
				c = x->data[i_143154];
				nimln(185, "hashes.nim");
				{
					NI TMP553;
					nimln(1098, "system.nim");
					if (!(((NU8)(c)) >= ((NU8)(65)) && ((NU8)(c)) <= ((NU8)(90)))) goto LA6;
					nimln(186, "hashes.nim");
					TMP553 = addInt(((NI) (((NU8)(c)))), ((NI) 32));
					c = ((NIM_CHAR) (((NI)chckRange((NI)(TMP553), ((NI) 0), ((NI) 255)))));
				}
				LA6: ;
				nimln(187, "hashes.nim");
				h = HEX21HEX26_142013(h, ((NI) (((NU8)(c)))));
				nimln(1895, "system.nim");
				TMP554 = addInt(res_143207, ((NI) 1));
				res_143207 = (NI)(TMP554);
			} LA3: ;
		}
	}
	nimln(188, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

N_NIMCALL(NI, hashignorecase_143226)(NimStringDesc* sbuf, NI spos, NI epos) {
	NI result;
	NI h;
	nimfr("hashIgnoreCase", "hashes.nim")
	result = 0;
	nimln(196, "hashes.nim");
	h = ((NI) 0);
	{
		NI i_143243;
		NI res_143295;
		i_143243 = 0;
		nimln(1874, "system.nim");
		res_143295 = spos;
		{
			nimln(1875, "system.nim");
			while (1) {
				NIM_CHAR c;
				NI TMP556;
				if (!(res_143295 <= epos)) goto LA3;
				nimln(1876, "system.nim");
				i_143243 = res_143295;
				nimln(198, "hashes.nim");
				if ((NU)(i_143243) > (NU)(sbuf->Sup.len)) raiseIndexError();
				c = sbuf->data[i_143243];
				nimln(199, "hashes.nim");
				{
					NI TMP555;
					nimln(1098, "system.nim");
					if (!(((NU8)(c)) >= ((NU8)(65)) && ((NU8)(c)) <= ((NU8)(90)))) goto LA6;
					nimln(200, "hashes.nim");
					TMP555 = addInt(((NI) (((NU8)(c)))), ((NI) 32));
					c = ((NIM_CHAR) (((NI)chckRange((NI)(TMP555), ((NI) 0), ((NI) 255)))));
				}
				LA6: ;
				nimln(201, "hashes.nim");
				h = HEX21HEX26_142013(h, ((NI) (((NU8)(c)))));
				nimln(1895, "system.nim");
				TMP556 = addInt(res_143295, ((NI) 1));
				res_143295 = (NI)(TMP556);
			} LA3: ;
		}
	}
	nimln(202, "hashes.nim");
	result = HEX21HEX24_142042(h);
	popFrame();
	return result;
}

static N_INLINE(NI, hash_143314)(NF x) {
	NI result;
	NF y;
	nimfr("hash", "hashes.nim")
	result = 0;
	nimln(206, "hashes.nim");
	y = ((NF)(x) + (NF)(1.0000000000000000e+00));
	nimln(207, "hashes.nim");
	result = (*((NI*) ((&y))));
	popFrame();
	return result;
}
NIM_EXTERNC N_NOINLINE(void, HEX00_hashesInit000)(void) {
	nimfr("hashes", "hashes.nim")
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, HEX00_hashesDatInit000)(void) {
}

