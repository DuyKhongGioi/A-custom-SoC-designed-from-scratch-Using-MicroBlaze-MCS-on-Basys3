/*
 * pwm_core.h
 *
 *  Created on: Feb 27, 2026
 *      Author: canguangamchua
 */

#ifndef SRC_PWM_CORE_H_
#define SRC_PWM_CORE_H_

#include "init_routines.h"
class PwmCore {
	enum {
		DIVISOR_REG	=	0x00,
		DUTY_REG_BASE = 0x10
	};
	enum {
		RESOLUTION_BITS = 10,
		MAX = 1 << RESOLUTION_BITS
	};

public:
	PwmCore(uint32_t core_base_addr);
	~PwmCore();
	void set_freq(int fre);
	void set_duty(int duty, int channel);
	void set_duty(double f, int channel);
private:
	uint32_t base_addr;
};




#endif /* SRC_PWM_CORE_H_ */
