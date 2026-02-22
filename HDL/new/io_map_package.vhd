----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2026 05:20:06 PM
-- Design Name: 
-- Module Name: io_map_package - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package io_map_package is
    --2D Data types for slot mplementation
    type slot_2d_data_type is array (63 downto 0) of
         std_logic_vector(31 downto 0);
    type slot_2d_reg_type is array (63 downto 0) of
         std_logic_vector(4 downto 0);
    
    --Base address of the io bridge
    constant BRIDGE_BASE: std_logic_vector(31 downto 0) := X"c7000000";
    
    --Slot definition for the MMIO subsystem
    constant S0_SYS_TIMER   :   INTEGER := 0;
    constant S1_UART1       :   INTEGER := 1;
    constant S2_LED         :   INTEGER := 2;
    constant S3_SW          :   INTEGER := 3;
    --constant S4_USER        :   INTEGER := 4;
end io_map_package;
