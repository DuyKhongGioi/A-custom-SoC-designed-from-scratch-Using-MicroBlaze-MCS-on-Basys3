----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2026 09:32:15 PM
-- Design Name: 
-- Module Name: baud_gen - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity baud_gen is
--  Port ( );
    PORT (
    clk     :   in std_logic;
    reset   :   in std_logic;
    divisor :   in std_logic_vector(10 downto 0);
    tick    :   out std_logic
    );
end baud_gen;

architecture Behavioral of baud_gen is
    constant N      :   integer := 11;
    signal   r_reg  :   unsigned(N-1 downto 0);
    signal   r_next :   unsigned(N-1 downto 0);
begin
    --register
    process(clk, reset) begin
        if (reset = '1') then
            r_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            r_reg <= r_next;
        end if;
    end process;
    
    r_next <= (others => '0') when r_reg = unsigned(divisor) else r_reg + 1;
    
    tick <= '1' when r_reg = 1 else '0';


end Behavioral;
