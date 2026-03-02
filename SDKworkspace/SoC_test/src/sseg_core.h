/*
 * SsegCore.h
 *
 *  Created on: Mar 2, 2026
 *      Author: canguangamchua
 */

#ifndef SRC_SSEG_CORE_H_
#define SRC_SSEG_CORE_H_

#include "init_routines.h"

class SsegCore {
public:
	enum {
		DATA_REG	=	0
	};

	SsegCore(uint32_t core_base_addr);
	~SsegCore();
	void write_1ptn(uint8_t pattern, int pos);
	void write_4ptn(uint8_t *ptn_array);
	void set_dp(uint8_t pt);
	uint8_t h2s(int hex);

private:
	uint32_t base_addr;
	uint8_t ptn_buf[4];
	int8_t dp;//decimal point
	void write_led();
	void write_led_def();
};







#endif /* SRC_SSEG_CORE_H_ */
