#include <inttypes.h>   //need for uintN types
#include <init_routines.h>
class GpoCore {
    // register map of GPO
    enum {
        DATA_REG = 0 //Output Data register for GPO
    };
public:
    GpoCore(uint32_t core_base_addr);   // Constructor for GPO
    ~GpoCore();                         // Destructor; not use
    //GPO methods
    void write(uint32_t data);              //write a 32-bit word
    void write(int bit_value, int bit_pos);  //write 1 bit
private:
    uint32_t base_addr; //base of the core
    uint32_t wr_data;   //same as data reg
};

class GpiCore {
    //register map
    enum {
        DATA_REG = 0 //IDR
    };
public:
    GpiCore(uint32_t core_base_addr);
    ~GpiCore();
    //methods GPI
    uint32_t read();    //read a 32 bit word
    int read(int pos);  //read 1 bit
private:
    uint32_t base_addr;
};