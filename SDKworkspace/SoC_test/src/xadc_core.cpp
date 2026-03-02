/*
 * xadc_core.cpp
 *
 *  Created on: Feb 26, 2026
 *      Author: canguangamchua
 */
#include "inttypes.h"
#include "xadc_core.h"

XADCCore::XADCCore(uint32_t core_base_addr) {
	base_addr = core_base_addr;
}

XADCCore::~XADCCore(){};

uint16_t XADCCore::read_raw(int n) {
	uint16_t rd_data;
	rd_data = (uint16_t) io_read(base_addr, ADC_0_REG+n) & 0x0000ffff;
	return (rd_data);
}

double XADCCore::read_adc_in(int n) {
	uint16_t raw;
	raw = read_raw(n) >> 4;
	return ((double)raw/4096.0);
}

double XADCCore::read_die_tmpt() {
	return (read_adc_in(TMPT_REG)*503.975 - 273.15);
}

double XADCCore::read_fpga_vcc() {
	return (read_adc_in(VCC_REG) * 3.0);
}

