#define _DEBUG

#include "init_routines.h"
#include "gpio_core.h"
#include "uart_core.h"

//check timer core
void timer_check(GpoCore *led_p) {
    int i;

    for (i = 0; i < 5; i++) {
        led_p->write(0xffff);
        sleep_ms(500);
        led_p->write(0x0000);
        sleep_ms(500);
        debug("timer check - (loop #)/now: ", i, now_ms());
    }
}

//check each led op
void led_check(GpoCore *led_p, int n) {
    int i;

    for (i = 0; i < n; i++) {
        led_p->write(1, i);
        sleep_ms(200);
        led_p->write(0, i);
        sleep_ms(200);
    }
}

void sw_check(GpoCore *led_p, GpiCore *sw_p) {
    int i, s;
    s = sw_p->read();
    for (i = 0; i < 50; i++) {
        led_p->write(s);
        sleep_ms(100);
        led_p->write(0);
        sleep_ms(100);
    }
}

void uart_check() {
    static int loop = 0;
    char str1_debug[] = "uart test #";
    const char *str1 = str1_debug;
    uart.disp(str1);
    uart.disp(loop);
    uart.disp("\n\r");
    loop++;
}

//instantiate for switch, led
GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));

int main() {
    while (1) {
        timer_check(&led);
        led_check(&led, 16);
        sw_check(&led, &sw);
        uart_check();
        debug("main - switch value / up time: ", sw.read(), now_ms());
    }
}