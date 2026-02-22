----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2026 09:49:06 PM
-- Design Name: 
-- Module Name: mcs_bridge - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module translates the MCS I/O bus's write and read transactions
--              to the corresponding operations on the System bus
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mcs_bridge is
--  Port ( );
    generic(BRIDGE_BASE:    std_logic_vector(31 downto 0)   := x"C000_0000");
    port(
    --MicroBlaze MCS bus
    io_addr_strobe      :   in std_logic;   --dont use
    io_read_strobe      :   in std_logic;
    io_write_strobe     :   in std_logic;
    io_byte_enable      :   in std_logic_vector(3 downto 0);
    io_address          :   in std_logic_vector(31 downto 0);
    io_write_data       :   in std_logic_vector(31 downto 0);
    io_read_data        :   out std_logic_vector(31 downto 0);
    io_ready            :   out std_logic;
    --System bus
    sys_video_cs        :   out std_logic;  --cs for VGA system
    sys_mmio_cs         :   out std_logic;
    sys_wr              :   out std_logic;
    sys_rd              :   out std_logic;
    sys_addr            :   out std_logic_vector(20 downto 0);
    sys_wr_data         :   out std_logic_vector(31 downto 0);
    sys_rd_data         :   in std_logic_vector(31 downto 0)
    );
end mcs_bridge;

architecture Behavioral of mcs_bridge is
    signal mcs_bridge_en    :   std_logic;
    signal word_addr        :   std_logic_vector(29 downto 0);
begin
    --address translation
    --2 LSB are "00" due to the word alignment
    word_addr   <=  io_address(31 downto 2);
    mcs_bridge_en <=    
                    '1' when io_address(31 downto 24) = BRIDGE_BASE(31 downto 24) else '0';
    sys_video_cs<=  
                    '1' when mcs_bridge_en = '1' and io_address(23) = '1' else '0';
    sys_mmio_cs <=
                    '1' when mcs_bridge_en = '1' and io_address(23) = '0' else '0';
    sys_addr    <=  word_addr(20 downto 0);
    
    --Control line conversion
    sys_wr      <=  io_write_strobe;
    sys_rd      <=  io_read_strobe;
    io_ready    <=  '1'; -- not used: transaction done in 1 clock
    -- Data line conversion
    sys_wr_data <=  io_write_data;
    io_read_data<=  sys_rd_data;
                   

end Behavioral;
