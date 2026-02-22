#include<inttypes.h>
class TimerCore {
    //registers map
    enum {
        COUNTER_LOWER_REG  = 0, //lower 32 bits of counter
        COUNTER_UPPER_REG  = 1, //upper 32 bits of counter
        CTRL_REG           = 2  //control register
    };
    //declare masks
    enum {
        GO_FIELD    =   0x00000001, //bit 0 of control reg is enable
        CLR_FIELD   =   0x00000010  //bit 1 of control reg is clear
    };

public:
    TimerCore(uint32_t core_base_addr); //constructor
    ~TimerCore();                       //destructor
    //methods
    void pause();                       //pause counter
    void go();                          //resume
    void clear();                       //clear the counter to 0
    uint64_t read_tick();               //number of clock elapsed
    uint64_t read_time();               //read time elapsed in us
    void sleep(uint64_t us);            

private:
    uint32_t base_addr;
    uint32_t ctrl;                      //current state of ctrl_reg
};