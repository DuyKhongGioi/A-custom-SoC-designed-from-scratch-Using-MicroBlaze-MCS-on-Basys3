
#define _DEBUG
#include "timer_core.h"
#include "gpio_core.h"
#include "uart_core.h"
#include "xadc_core.h"
#include "pwm_core.h"
#include "spi_core.h"
#include "i2c_core.h"
#include "sseg_core.h"


//instantiate for switch, led
GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));
XADCCore adc(get_slot_addr(BRIDGE_BASE, S4_XADC));
PwmCore pwm(get_slot_addr(BRIDGE_BASE, S5_PWM));
SpiCore spi(get_slot_addr(BRIDGE_BASE, S6_SPI));
I2cCore i2c(get_slot_addr(BRIDGE_BASE, S7_I2C));
SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));

//default display pattern for sseg
const uint8_t DEFAULT_SSEG[] = {0xC0, 0xC7, 0x88, 0x89};

//check timer core
void timer_check(GpoCore *led_p) {
    int i;
    uart.disp("---------------TIMER CHECK---------------");
    uart.disp("\n\r");
    for (i = 0; i < 5; i++) {
        led_p->write(0xffff);
        sleep_ms(500);
        led_p->write(0x0000);
        sleep_ms(500);
        debug("timer check - (loop #)/now: ", i, now_ms());
    }
    uart.disp("----------------------------------------");
    uart.disp("\n\r");
}

//check each led op
void led_check(GpoCore *led_p, int n) {
    int i;
    uart.disp("---------------LED CHECK---------------");
    uart.disp("\n\r");
    for (i = 0; i < n; i++) {
        led_p->write(1, i);
        sleep_ms(200);
        led_p->write(0, i);
        sleep_ms(200);
    }
    uart.disp("----------------------------------------");
    uart.disp("\n\r");
}

void sw_check(GpoCore *led_p, GpiCore *sw_p) {
    int i, s;
    s = sw_p->read();
    uart.disp("---------------SWITCH CHECK---------------");
    uart.disp("\n\r");
    for (i = 0; i < 50; i++) {
        led_p->write(s);
        sleep_ms(100);
        led_p->write(0);
        sleep_ms(100);
    }
    uart.disp("----------------------------------------");
    uart.disp("\n\r");
}

void uart_check() {
    static int loop = 0;
    char str1_debug[] = "uart test";
    const char *str1 = str1_debug;
    uart.disp(str1);
    uart.disp(loop);
    uart.disp("\n\r");
    loop++;
}

void adc_check(XADCCore *adc_p, GpoCore *led_p) {
	double fpga_vcc;
	double die_temp;
	double adc_read;
	int n, i;
	uint16_t raw;
	uart.disp("---------------XADC CHECK---------------");
	uart.disp("\n\r");
	for (i = 0; i < 1; i++) {
		//display the 12 bit channel 0 reading in led
		raw = adc_p->read_raw(0);
		raw = raw >> 4;
		led_p->write(raw);
		//display on chip sensor and 4 channels in console
		uart.disp("FPGA core vcc: ");
		fpga_vcc = adc_p->read_fpga_vcc();
		uart.disp(fpga_vcc, 3);
		uart.disp("\n\r");
		uart.disp("Die temperature: ");
		die_temp = adc_p->read_die_tmpt();
		uart.disp(die_temp, 3);
		uart.disp("\n\r");

		for (n = 0; n < 4; n++) {
			uart.disp("analog channel/voltage: ");
			uart.disp(n);
			uart.disp(" / ");
			adc_read = adc_p->read_adc_in(n);
			uart.disp(adc_read, 3);
			uart.disp("\n\r");
		}
		sleep_ms(300);
	}
	uart.disp("----------------------------------------");
	uart.disp("\n\r");


	int temp_sseg = (int)(die_temp * 100);
	uint8_t temp_ptn[4];
	temp_ptn[0] = sseg.h2s(temp_sseg % 10);
	temp_ptn[1] = sseg.h2s((temp_sseg / 10) % 10);
	temp_ptn[2] = sseg.h2s((temp_sseg / 100) % 10);
	temp_ptn[3] = sseg.h2s((temp_sseg / 1000) % 10);
	int vcc_sseg = (int)(fpga_vcc * 1000);
	uint8_t vcc_ptn[4];
	vcc_ptn[0] = sseg.h2s(vcc_sseg % 10);
	vcc_ptn[1] = sseg.h2s((vcc_sseg / 10) % 10);
	vcc_ptn[2] = sseg.h2s((vcc_sseg / 100) % 10);
	vcc_ptn[3] = sseg.h2s((vcc_sseg / 1000) % 10);

	sseg.set_dp(0x08);
	sseg.write_4ptn(vcc_ptn);
	sleep_ms(5000);
	sseg.set_dp(0x04);
	sseg.write_4ptn(temp_ptn);
	sleep_ms(5000);
}

void pwm_3_colors_led_check(PwmCore *pwm_p) {
	int i, n;
	double bright, duty;
	const double P20 = 1.2589;

	pwm_p->set_freq(50);
	uart.disp("---------------PWM CHECK---------------");
	uart.disp("\n\r");
	for (n = 0; n < 3; n++) {
		bright = 1.0;
		for (i = 0; i < 14; i++) {
			bright = bright * P20;
			duty = bright / 100.0;
			pwm_p->set_duty(duty, n);
			sleep_ms(150);
		}
		sleep_ms(300);
		pwm_p->set_duty(0.0, n);
	}
	uart.disp("----------------------------------------");
	uart.disp("\n\r");
}

void adxl362_spi_check(SpiCore *spi_p, GpoCore *led_p) {
	const uint8_t WR_CMD = 0x0a;
	const uint8_t POWER_CTL_REG = 0x2d;
	const uint8_t MEASURE_MODE = 0x02;
	const uint8_t RD_CMD	=	0x0b;
	const uint8_t PART_ID_REG = 0x02;
	const uint8_t DEVICE_ID_REG = 0x00;
	const uint8_t DATA_REG = 0x08;

	const float RAW_MAX = 127.0 / 2.0; //128 max 8 bit reading for +-2g
	int8_t xraw, yraw, zraw;
	float x, y, z;
	int dev_id, part_id;

	uart.disp("---------------SPI ADXL362 CHECK---------------");
	uart.disp("\n\r");

	spi_p->set_freq(400000);
	spi_p->set_mode(0, 0);
	//check device id
	spi_p->assert_ss(0);
	spi_p->transfer(RD_CMD);
	spi_p->transfer(DEVICE_ID_REG);
	dev_id = (int) spi_p->transfer(0x00);
	spi_p->deassert_ss(0);
	uart.disp("read ADXL362 device id: ");
	uart.disp(dev_id, 16);
	uart.disp("\n\r");
	//check part id
	spi_p->assert_ss(0);
	spi_p->transfer(RD_CMD);
	spi_p->transfer(PART_ID_REG);
	part_id = (int) spi_p->transfer(0x00);
	spi_p->deassert_ss(0);
	uart.disp("read ADXL362 part id: ");
	uart.disp(part_id, 16);
	uart.disp("\n\r");

	//turn on the ADXL362
	spi_p->assert_ss(0);
	spi_p->transfer(WR_CMD);
	spi_p->transfer(POWER_CTL_REG);
	spi_p->transfer(MEASURE_MODE);
	spi_p->deassert_ss(0);

	//read 8 bit x/y/z g values
	spi_p->assert_ss(0);
	spi_p->transfer(RD_CMD);
	spi_p->transfer(DATA_REG);
	//burst mode transfer
	xraw = spi_p->transfer(0x00);
	yraw = spi_p->transfer(0x00);
	zraw = spi_p->transfer(0x00);
	spi_p->deassert_ss(0);
	x = (float) xraw/RAW_MAX;
	y = (float) yraw/RAW_MAX;
	z = (float) zraw/RAW_MAX;
	uart.disp("Measured values: ");
	uart.disp("\n\r");
	uart.disp("x: ");
	uart.disp(x, 3);
	uart.disp("\n\r");
	uart.disp("y: ");
	uart.disp(y, 3);
	uart.disp("\n\r");
	uart.disp("z: ");
	uart.disp(z, 3);
	uart.disp("\n\r");
	uart.disp("Direction: ");

	float threshold = 0.2;

	// Check X
	if (x > threshold) {
		uart.disp("Tilting LEFT ");
	} else if (x < -threshold) {
		uart.disp("Tilting RIGHT ");
	}

	// check Y
	if (y > threshold) {
		uart.disp("Tilting FORWARD ");
	} else if (y < -threshold) {
		uart.disp("Tilting BACKWARD ");
	}


	if (x > -threshold && x < threshold && y > -threshold && y < threshold) {
		uart.disp("FLAT");
	}
	uart.disp("\n\r");
	uart.disp("----------------------------------------");
	uart.disp("\n\r");

}

void hygro_i2c_check (I2cCore *hygro_p) {
	const uint8_t DEV_ID = 0x40;
	uint8_t tempr_reg = 0x00; //temperature register; humidity register will increase automated
	uint8_t hygro_data[4];

	int ack;
	uart.disp("---------------I2C HYGRO CHECK---------------");
	uart.disp("\n\r");

	// write register address
	ack = hygro_p->write_transaction(DEV_ID, &tempr_reg, 1, 0);

	if (ack != 0) {
		uart.disp("HYGRO write error");
		uart.disp("\n\r");
		return;
	}

	// wait sensor conversion
	sleep_ms(20);

	// read 4 bytes
	ack = hygro_p->read_transaction(DEV_ID, hygro_data, 4, 0);

	if (ack != 0) {
		uart.disp("HYGRO read error");
		uart.disp("\n\r");
		return;
	}

	uint16_t temp_raw = ((uint16_t)hygro_data[0] << 8) | hygro_data[1];
	uint16_t hum_raw  = ((uint16_t)hygro_data[2] << 8) | hygro_data[3];

	float temperature = ((float)temp_raw / 65536.0) * 165.0 - 40.0;
	float humidity    = ((float)hum_raw  / 65536.0) * 100.0;
	uart.disp("TEMERATURE(Celcius): ");
	uart.disp(temperature, 2);
	uart.disp("\n\r");
	uart.disp("RELATIVE HUMIDITY (%)");
	uart.disp(humidity, 2);
	uart.disp("\n\r");

	uart.disp("----------------------------------------");
	uart.disp("\n\r");

	int temp_sseg = (int)(temperature * 100);
	uint8_t temp_ptn[4];
	temp_ptn[0] = sseg.h2s(temp_sseg % 10);
	temp_ptn[1] = sseg.h2s((temp_sseg / 10) % 10);
	temp_ptn[2] = sseg.h2s((temp_sseg / 100) % 10);
	temp_ptn[3] = sseg.h2s((temp_sseg / 1000) % 10);
	int hum_sseg = (int)(humidity * 100);
	uint8_t hum_ptn[4];
	hum_ptn[0] = sseg.h2s(hum_sseg % 10);
	hum_ptn[1] = sseg.h2s((hum_sseg / 10) % 10);
	hum_ptn[2] = sseg.h2s((hum_sseg / 100) % 10);
	hum_ptn[3] = sseg.h2s((hum_sseg / 1000) % 10);

	sseg.set_dp(0x04);
	sseg.write_4ptn(temp_ptn);
	sleep_ms(5000);
	sseg.write_4ptn(hum_ptn);
	sleep_ms(5000);

}



int main() {
	timer_check(&led);
	led_check(&led, 16);
	sw_check(&led, &sw);
	//uart_check();
    while (1) {
        pwm_3_colors_led_check(&pwm);
        adc_check(&adc, &led);
        adxl362_spi_check(&spi, &led);
        sleep_ms(3000);
        hygro_i2c_check(&i2c);

        sseg.set_dp(0x00);
        sseg.write_4ptn((uint8_t *)(DEFAULT_SSEG));
		sleep_ms(3000);

        //debug("main - switch value / up time: ", sw.read(), now_ms());
    }
}
