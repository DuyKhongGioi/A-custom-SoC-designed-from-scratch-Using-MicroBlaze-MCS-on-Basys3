/*
 * spi_core.h
 *
 *  Created on: Feb 28, 2026
 *      Author: canguangamchua
 */

#ifndef SRC_SPI_CORE_H_
#define SRC_SPI_CORE_H_

#include "init_routines.h"

class SpiCore {
public:
	enum {
		RD_DATA_REG		=	0,
		SS_REG			=	1,
		WRITE_DATA_REG	=	2,
		CTRL_REG		=	3
	};
	enum {
		READY_FIELD		=	0x00000100,
		RX_DATA_FIELD	=	0x000000ff
	};

	SpiCore(uint32_t core_base_addr);
	~SpiCore();
	int ready();
	void set_freq(int freq);
	void set_mode(int setcpole, int setcphase);
	void write_ss_n(uint32_t data);
	void write_ss_n(int bit_value, int pos);
	void assert_ss(int n);
	void deassert_ss(int n);
	uint8_t transfer(uint8_t wr_data);
private:
	uint32_t base_addr;
	uint32_t ss_n_data;
	uint16_t divisor;
	int cpole;
	int cphase;
};




#endif /* SRC_SPI_CORE_H_ */
