/*
 * sseg_core.h
 *
 *  Created on: Mar 2, 2026
 *      Author: canguangamchua
 */
#include "sseg_core.h"

SsegCore::SsegCore(uint32_t core_base_addr) {
	const uint8_t DEF_PTN[] = {0xC0, 0xC7, 0x88, 0x89};
	base_addr = core_base_addr;
	write_4ptn((uint8_t *)DEF_PTN);
	set_dp(0x00);
}

SsegCore::~SsegCore(){};

void SsegCore::write_4ptn(uint8_t *ptn_array) {
	int i;

	for (i = 0; i < 4; i++) {
		ptn_buf[i] = *ptn_array;
		ptn_array++;
	}

	write_led();
}

void SsegCore::write_1ptn(uint8_t pattern, int pos) {
	ptn_buf[pos] = pattern;
	write_led();
}

void SsegCore::set_dp(uint8_t pt) {
	dp = ~pt;
	write_led();
}

//convert a hex digit
uint8_t SsegCore::h2s(int hex) {
	//active low hex digit 7 segment pattern
	//msb assigned to 1
	static const uint8_t PTN_TABLE[16] =
	{
			0xc0, 0xf9, 0xa4, 0xb0,
			0x99, 0x92, 0x82, 0xf8,
			0x80, 0x90, 0x88, 0x83,
			0xc6, 0xa1, 0x86, 0x8e
	};
	uint8_t ptn;
	if (hex < 16)
		ptn = PTN_TABLE[hex];
	else
		ptn = 0xff;
	return (ptn);
}

void SsegCore::write_led() {
	int i, p;
	uint32_t word = 0;

	//pack 4 patterns into a word
	//ptn[0] is the leftmost led
	for (i = 0; i < 4; i++) {
		word = (word << 8) | ptn_buf[3-i];
	}
	if (bit_read(dp, 2) == 0) {        // digit 2
		bit_write(word, 7 + 8 * 2, 0);
	}

	if (bit_read(dp, 3) == 0) {        // digit 3
		bit_write(word, 7 + 8 * 3, 0);
	}


	//incorporate decimal point (bit 7 of pattern)
	io_write(base_addr, DATA_REG, word);
}
