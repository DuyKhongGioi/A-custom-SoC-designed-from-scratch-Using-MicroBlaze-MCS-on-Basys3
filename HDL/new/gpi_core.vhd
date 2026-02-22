----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2026 12:04:59 AM
-- Design Name: 
-- Module Name: gpi_core - Behavioral
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

entity gpi_core is
--  Port ( );
    generic(W:  integer := 8);
    port(
    clk :   in std_logic;
    reset:  in std_logic;
    --slot interface
    cs:     in std_logic;
    write:  in std_logic;
    read:   in std_logic;
    addr:   in std_logic_vector(4 downto 0);
    rd_data: out std_logic_vector(31 downto 0);
    wr_data: in std_logic_vector(31 downto 0);
    --external data
    din    : in std_logic_vector(W-1 downto 0)
    );
end gpi_core;

architecture Behavioral of gpi_core is
    signal rd_data_reg  :   std_logic_vector(W-1 downto 0);
begin
    -- input register
    process(clk, reset) begin
        if (reset = '1') then
            rd_data_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            rd_data_reg <= din;
        end if;
    end process;
    -- slot read interface
    rd_data(W-1 downto 0) <= rd_data_reg;
    rd_data(31 downto W)  <= (others => '0');
end Behavioral;
