----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2026 01:19:30 PM
-- Design Name: 
-- Module Name: sseg_mux_core - Behavioral
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

entity sseg_mux_core is
--  Port ( );
    port(
        clk     :   in std_logic;
        reset   :   in std_logic;
        --io bridge interface
        cs      :   in std_logic;
        write   :   in std_logic;
        read    :   in std_logic;
        addr    :   in std_logic_vector(4 downto 0);
        rd_data :   out std_logic_vector(31 downto 0);
        wr_data :   in std_logic_vector(31 downto 0);
        --external interface
        an      :   out std_logic_vector(3 downto 0);
        sseg    :   out std_logic_vector(7 downto 0)
    );
end sseg_mux_core;

architecture Behavioral of sseg_mux_core is
    signal d_reg    :   std_logic_vector(31 downto 0);
    signal wr_en    :   std_logic;
    signal wr_d     :   std_logic;
    
begin
    sseg_mux_module :   entity work.sseg_mux
    port map(
        clk =>  clk,
        reset   =>  reset,
        in0 =>  d_reg(7 downto 0),
        in1 =>  d_reg(15 downto 8),
        in2 =>  d_reg(23 downto 16),
        in3 =>  d_reg(31 downto 24),
        an  =>  an,
        sseg    =>  sseg
        );
        
        --registers
        process(clk, reset) begin
            if (reset = '1') then  
                d_reg   <=  (others => '0');
            elsif (clk'event and clk = '1') then
                if (wr_d = '1') then
                    d_reg <=    wr_data(31 downto 0);
                end if;
            end if;
        end process;
        --decoding
        wr_en   <=  '1' when write = '1' and cs = '1' else '0';
        wr_d   <=  '1' when addr(0) = '0' and wr_en = '1' else '0';
        
        --unused read
        rd_data <=  (others => '0');

end Behavioral;
