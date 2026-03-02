----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2026 11:20:15 PM
-- Design Name: 
-- Module Name: mcs_top_sys - Architecture
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- --------------------------------------------------------------------------------------------------------
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- -------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

library IEEE;---------
use IEEE.STD_LOGIC_1164.ALL;
use work.io_map_package.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mcs_top_sys is
--  Port ( );
    generic(BRIDGE_BASE :   std_logic_vector(31 downto 0)   :=  x"C000_0000");
    
    port(
    clk:            in std_logic;
    --reset_n:        in std_logic;
    --switches and leds
    sw:             in std_logic_vector(15 downto 0);
    led:            out std_logic_vector(15 downto 0);
    --uart core
    rx:             in std_logic;
    tx:             out std_logic;
    --xadc
    adc_p:          in std_logic_vector(3 downto 0);
    adc_n:          in std_logic_vector(3 downto 0);
    
    --PMOD JA (for PWM)
    ja_top:         out std_logic_vector(4 downto 1);
    ja_bot:         out std_logic_vector(10 downto 7);
    
    --SPI ACL2
    acl_sclk:       out std_logic;
    acl_mosi:       out std_logic;
    acl_miso:       in std_logic;
    acl_ss_n:       out std_logic;
    --I2C HYGRO
    hygro_i2c_scl:  out std_logic;
    hygro_i2c_sda:  inout std_logic;
    --4 digit 7 segment
    an           :  out std_logic_vector(3 downto 0);
    sseg         :  out std_logic_vector(7 downto 0)
    );
end mcs_top_sys;

architecture Arch of mcs_top_sys is
  component ublaze_up 
  PORT (
    Clk : IN STD_LOGIC;
    Reset : IN STD_LOGIC;
    IO_addr_strobe : OUT STD_LOGIC;
    IO_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    IO_byte_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    IO_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    IO_read_strobe : OUT STD_LOGIC;
    IO_ready : IN STD_LOGIC;
    IO_write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    IO_write_strobe : OUT STD_LOGIC
  );
   END component;
   
   signal clk_100M          :   std_logic;
   signal reset_sys         :   std_logic;
   --pwm
   signal pwm               : std_logic_vector(7 downto 0);
   --MCS IO BUS
   signal io_addr_strobe    :   std_logic;
   signal io_address        :   std_logic_vector(31 downto 0);
   signal io_byte_enable    :   std_logic_vector(3 downto 0);
   signal io_read_data      :   std_logic_vector(31 downto 0);
   signal io_read_strobe    :   std_logic;
   signal io_ready          :   std_logic;
   signal io_write_data     :   std_logic_vector(31 downto 0);
   signal io_write_strobe   :   std_logic;
   --System bus
   signal sys_mmio_cs       :   std_logic;
   signal sys_wr            :   std_logic;
   signal sys_rd            :   std_logic;
   signal sys_addr          :   std_logic_vector(20 downto 0);
   signal sys_wr_data       :   std_logic_vector(31 downto 0);
   signal sys_rd_data       :   std_logic_vector(31 downto 0);
   
begin
    clk_100M    <= clk;
    reset_sys   <= '0';
    
    --pmod JA
    ja_top  <=  pwm(7 downto 4);
    ja_bot  <=  pwm(3 downto 0);
    
    cpu_instantiate:   ublaze_up
    port map(
    Clk =>  clk_100M,
    Reset   =>  reset_sys,
    IO_addr_strobe  =>  io_addr_strobe,
    IO_address  =>  io_address,
    IO_byte_enable  =>  io_byte_enable,
    IO_read_data    =>  io_read_data,
    IO_read_strobe =>   io_read_strobe,
    IO_ready => io_ready,
    IO_write_data   =>  io_write_data,
    IO_write_strobe =>  io_write_strobe
    );
    
    -- MCS IO bus to System bus
    bridge_connector:   entity work.mcs_bridge
    generic map(BRIDGE_BASE => BRIDGE_BASE)
    port map(
        --MicroBlaze MCS bus
    io_addr_strobe      =>  io_addr_strobe,
    io_read_strobe      =>  io_read_strobe,
    io_write_strobe     =>  io_write_strobe,
    io_byte_enable      =>  io_byte_enable,
    io_address          =>  io_address,
    io_write_data       =>  io_write_data, 
    io_read_data        =>  io_read_data,
    io_ready            =>  io_ready,
    --System bus
    sys_video_cs        =>  open,--dont wire
    sys_mmio_cs         =>  sys_mmio_cs,
    sys_wr              =>  sys_wr,
    sys_rd              =>  sys_rd,
    sys_addr            =>  sys_addr,
    sys_wr_data         =>  sys_wr_data,
    sys_rd_data         =>  sys_rd_data  
    );
    
    mmio_system_1:  entity work.mmio_sys_1
    port map(
    clk             =>  clk_100M,
    reset           =>  reset_sys,
    mmio_cs         =>  sys_mmio_cs,
    mmio_wr         =>  sys_wr,
    mmio_rd         =>  sys_rd,
    mmio_addr       =>  sys_addr,
    mmio_wr_data    =>  sys_wr_data,
    mmio_rd_data    =>  sys_rd_data,
    --switch and led for gpio
    sw              =>  sw,
    led             =>  led,
    --uart
    rx              =>  rx,
    tx              =>  tx,
    --xadc
    adc_p           =>  adc_p,
    adc_n           =>  adc_n,
    --pwm
    pwm             =>  pwm,
    --spi acl2
    acl_sclk        =>  acl_sclk,
    acl_mosi        =>  acl_mosi,
    acl_miso        =>  acl_miso,
    acl_ss          =>  acl_ss_n,
    --i2c hygro
    hygro_i2c_scl   =>  hygro_i2c_scl,
    hygro_i2c_sda   =>  hygro_i2c_sda,
    an              =>  an,
    sseg            =>  sseg
    );

end Architecture;
