/*
 * spi_core.cpp
 *
 *  Created on: Feb 28, 2026
 *      Author: canguangamchua
 */

#include "spi_core.h"

SpiCore::SpiCore(uint32_t core_base_addr) {
	base_addr = core_base_addr;
	//set default spi configuration to be 100KHz, mode 0
	set_freq(100000);
	set_mode(0, 0);
	write_ss_n(0xffffffff); //de-assert all slaves
}

SpiCore::~SpiCore(){};

int SpiCore::ready() {
	uint32_t rd_word;
	int ready;

	rd_word = io_read(base_addr, RD_DATA_REG);
	ready = (int)(rd_word & READY_FIELD) >> 8;
	return ready;
}

void SpiCore::set_freq(int freq) {
	uint32_t ctrl_word;
	divisor = (uint16_t) (SYS_CLK_FREQ * 1000000 / (2 * freq));
	divisor = divisor - 1; //counts 0 to divisor - 1
	ctrl_word = cphase << 17 | cpole << 16 | divisor;
	io_write(base_addr, CTRL_REG, ctrl_word);
}

void SpiCore::set_mode(int setcpole, int setcphase) {
	uint32_t ctrl_word;

	cpole = setcpole;
	cphase = setcphase;

	ctrl_word = cphase << 17 | cpole << 16 | divisor;
	io_write(base_addr, CTRL_REG, ctrl_word);
}

void SpiCore::write_ss_n(uint32_t data) {
	ss_n_data = data;
	io_write(base_addr, SS_REG, ss_n_data);
}

void SpiCore::write_ss_n(int bit_value, int pos) {
	bit_write(ss_n_data, pos, bit_value);
	io_write(base_addr, SS_REG, ss_n_data);
}

void SpiCore::assert_ss(int n) {
	write_ss_n(0, n);
}

void SpiCore::deassert_ss(int n) {
	write_ss_n(1, n);
}

uint8_t SpiCore::transfer(uint8_t wr_data) {
	uint32_t rd_data;

	while(!ready()) {};
	io_write(base_addr, WRITE_DATA_REG, (uint32_t) wr_data);

	while(!ready()) {};
	rd_data = io_read(base_addr, RD_DATA_REG) & RX_DATA_FIELD;

	return ((uint8_t) rd_data);
}






