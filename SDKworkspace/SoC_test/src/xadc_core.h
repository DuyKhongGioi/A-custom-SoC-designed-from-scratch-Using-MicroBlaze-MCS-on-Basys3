/*
 * xadc_core.h
 *
 *  Created on: Feb 26, 2026
 *      Author: canguangamchua
 */

#ifndef SRC_XADC_CORE_H_
#define SRC_XADC_CORE_H_

#include "init_routines.h"

class XADCCore {
public:
	enum {
		ADC_0_REG = 0,
		TMPT_REG = 4,
		VCC_REG = 5,
	};
	XADCCore(uint32_t core_base_addr);
	~XADCCore(); //left
	uint16_t read_raw(int n);
	double read_adc_in(int n);
	double read_fpga_vcc();
	double read_die_tmpt();
private:
	uint32_t base_addr;
};



#endif /* SRC_XADC_CORE_H_ */
