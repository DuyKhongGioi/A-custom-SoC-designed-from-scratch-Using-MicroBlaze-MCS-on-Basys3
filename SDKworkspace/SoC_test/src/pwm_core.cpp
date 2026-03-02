/*
 * pwm_core.cpp
 *
 *  Created on: Feb 27, 2026
 *      Author: canguangamchua
 */

#include "pwm_core.h"

PwmCore::PwmCore(uint32_t core_base_addr) {
	base_addr = core_base_addr;
	set_freq(1000);
}

PwmCore::~PwmCore(){};

void PwmCore::set_freq(int fre) {
	uint32_t divisor;
	divisor = (uint32_t) SYS_CLK_FREQ * 1000000 / (MAX * fre);
	io_write(base_addr, DIVISOR_REG, divisor);
}

void PwmCore::set_duty(int duty, int channel) {
	uint32_t d;
	if (duty > MAX) {
		d = MAX;
	} else {
		d = duty;
	}
	io_write(base_addr, DUTY_REG_BASE + channel, d);
}

void PwmCore::set_duty(double f, int channel) {
	int duty;
	duty = (int) (f * MAX);
	set_duty(duty, channel);
}



