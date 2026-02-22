#ifndef _IO_MAP_INCLUDED
#define _IO_MAP_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

#define SYS_CLK_FREQ 100

//io base address for microBlaze MCS
#define BRIDGE_BASE 0xc0000000

//slot module definition
#define S0_SYS_TIMER    0
#define S1_UART1        1
#define S2_LED          2
#define S3_SW           3

//..... for further slots

#ifdef __cplusplus
}   //extern C
#endif

#endif  //_IO_MAP_INCLUDED

