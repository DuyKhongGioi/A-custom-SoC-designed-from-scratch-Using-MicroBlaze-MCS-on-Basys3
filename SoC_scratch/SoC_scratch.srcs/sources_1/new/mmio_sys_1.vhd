----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2026 11:41:05 PM
-- Design Name: 
-- Module Name: mmio_sys_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.io_map_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mmio_sys_1 is
--  Port ( );
    PORT (
    -- system bus
    clk             :   in std_logic;
    reset           :   in std_logic;
    mmio_cs         :   in std_logic;
    mmio_wr         :   in std_logic;
    mmio_rd         :   in std_logic;
    mmio_addr       :   in std_logic_vector(20 downto 0);
    mmio_wr_data    :   in std_logic_vector(31 downto 0);
    mmio_rd_data    :   out std_logic_vector(31 downto 0);
    --switch and led for gpio
    sw              :   in std_logic_vector(15 downto 0);
    led             :   out std_logic_vector(15 downto 0);
    --uart
    rx              :   in std_logic;
    tx              :   out std_logic;
    --analog input pair
    adc_p           :   in std_logic_vector(3 downto 0);
    adc_n           :   in std_logic_vector(3 downto 0);
    --pwm
    pwm             :   out std_logic_vector(7 downto 0);
    --spi accelerometer 
    acl_sclk        :   out std_logic;
    acl_mosi        :   out std_logic;
    acl_miso        :   in std_logic;
    acl_ss          :   out std_logic;
    --i2c HYGRO 
    hygro_i2c_scl   :   out std_logic;
    hygro_i2c_sda   :   inout std_logic;
    --sevent segment
    an              :   out std_logic_vector(3 downto 0);
    sseg            :   out std_logic_vector(7 downto 0)
    );
end mmio_sys_1;

architecture Behavioral of mmio_sys_1 is
    signal  cs_array        :   std_logic_vector(63 downto 0);
    signal  reg_addr_array  :   slot_2d_reg_type;
    signal  mem_rd_array    :   std_logic_vector(63 downto 0);
    signal  mem_wr_array    :   std_logic_vector(63 downto 0);
    signal  rd_data_array   :   slot_2d_data_type;
    signal  wr_data_array   :   slot_2d_data_type;
begin
    controller: entity work.mmio_controller
    port map(
    mmio_cs             =>  mmio_cs,
    mmio_wr             =>  mmio_wr,
    mmio_rd             =>  mmio_rd,
    mmio_addr           =>  mmio_addr,
    mmio_wr_data        =>  mmio_wr_data,
    mmio_rd_data        =>  mmio_rd_data,
    --64 slots interface
    slot_cs_array       =>  cs_array,
    slot_reg_addr_array =>  reg_addr_array,
    slot_mem_rd_array   =>  mem_rd_array,
    slot_mem_wr_array   =>  mem_wr_array,
    slot_rd_data_array  =>  rd_data_array,
    slot_wr_data_array  =>  wr_data_array
    );
    
    --SLOT INSTANTIATE
    slot0_timer:    entity work.timer_core
    port map(
    clk             =>  clk,
    reset           =>  reset,
    cs              =>  cs_array(S0_SYS_TIMER),
    read            =>  mem_rd_array(S0_SYS_TIMER),
    write           =>  mem_wr_array(S0_SYS_TIMER),
    addr            =>  reg_addr_array(S0_SYS_TIMER),
    rd_data         =>  rd_data_array(S0_SYS_TIMER),
    wr_data         =>  wr_data_array(S0_SYS_TIMER)
    );
    -- slot 1: uart1
    slot1_uart : entity work.uart_core
    generic map(FIFO_DEPTH_BIT => 6)
    port map(
        clk      => clk,
        reset    => reset,
        cs       => cs_array(S1_UART1),
        read     => mem_rd_array(S1_UART1),
        write    => mem_wr_array(S1_UART1),
        addr     => reg_addr_array(S1_UART1),
        rd_data  => rd_data_array(S1_UART1),
        wr_data  => wr_data_array(S1_UART1),
        -- external signals
        tx       => tx,
        rx       => rx
    );

-- slot 2: GPO for 16 LEDs
    slot2_gpo: entity work.gpo_core
    generic map(W => 16)
    port map(
        clk      => clk,
        reset    => reset,
        cs       => cs_array(S2_LED),
        read     => mem_rd_array(S2_LED),
        write    => mem_wr_array(S2_LED),
        addr     => reg_addr_array(S2_LED),
        rd_data  => rd_data_array(S2_LED),
        wr_data  => wr_data_array(S2_LED),
        -- external signal
        dout     => led
    );

-- slot 3: input port for 16 slide switches
    gpi_slot3 : entity work.gpi_core
    generic map(W => 16)
    port map(
        clk      => clk,
        reset    => reset,
        cs       => cs_array(S3_SW),
        read     => mem_rd_array(S3_SW),
        write    => mem_wr_array(S3_SW),
        addr     => reg_addr_array(S3_SW),
        rd_data  => rd_data_array(S3_SW),
        wr_data  => wr_data_array(S3_SW),
        -- external signal
        din      => sw
    );
    
    --slot 4: XADC
    XADC_slot4: entity work.xadc_core
    port map(
        clk =>  clk,
        reset   =>  reset,
        cs      =>  cs_array(S4_XADC),
        read    =>  mem_rd_array(S4_XADC),
        write   =>  mem_wr_array(S4_XADC),
        addr    =>  reg_addr_array(S4_XADC),
        rd_data =>  rd_data_array(S4_XADC),
        wr_data =>  wr_data_array(S4_XADC),
        adc_p   =>  adc_p,
        adc_n   =>  adc_n);
    --slot 5: PWM
    PWM_slot5:  entity work.pwm_core
    generic map (W => 8,
    R   =>  10)
    port map(
        clk =>  clk,
        reset   =>  reset,
        cs      =>  cs_array(S5_PWM),
        read    =>  mem_rd_array(S5_PWM),
        write   =>  mem_wr_array(S5_PWM),
        addr    =>  reg_addr_array(S5_PWM),
        rd_data =>  rd_data_array(S5_PWM),
        wr_data =>  wr_data_array(S5_PWM),
        pwm_out =>  pwm
    );
    SPI_slot6:  entity work.spi_core
    generic map(S => 1)
    port map(
        clk =>  clk,
        reset   =>  reset,
        --io bridge
        cs  =>   cs_array(S6_SPI),
        write   =>  mem_wr_array(S6_SPI),
        read    =>  mem_rd_array(S6_SPI),
        addr    =>  reg_addr_array(S6_SPI),
        rd_data =>  rd_data_array(S6_SPI),
        wr_data =>  wr_data_array(S6_SPI),
        --signals
        spi_sclk    =>  acl_sclk,
        spi_mosi    =>  acl_mosi,
        spi_miso    =>  acl_miso,
        spi_ss_n(0)    =>  acl_ss);
    I2C_slot:   entity work.i2c_core
    port map(
        clk =>  clk,
        reset   =>  reset,
        --io bridge
        cs  =>   cs_array(S7_I2C),
        write   =>  mem_wr_array(S7_I2C),
        read    =>  mem_rd_array(S7_I2C),
        addr    =>  reg_addr_array(S7_I2C),
        rd_data =>  rd_data_array(S7_I2C),
        wr_data =>  wr_data_array(S7_I2C),
        
        scl     =>  hygro_i2c_scl,
        sda     =>  hygro_i2c_sda
    );
    
    SSEG_slot:   entity work.sseg_mux_core
    port map(
        clk =>  clk,
        reset   =>  reset,
        --io bridge
        cs  =>   cs_array(S8_SSEG),
        write   =>  mem_wr_array(S8_SSEG),
        read    =>  mem_rd_array(S8_SSEG),
        addr    =>  reg_addr_array(S8_SSEG),
        rd_data =>  rd_data_array(S8_SSEG),
        wr_data =>  wr_data_array(S8_SSEG),
        
        an      =>  an,
        sseg     =>  sseg
    );
    --need to assign as unused for other slots rd_data signal
    --these will be optimized away in the synthesis
    gen_unuse_slots:    for i in 9 to 63 generate
        rd_data_array(i)    <=  (others =>  '0');
    end generate gen_unuse_slots;
end Behavioral;
