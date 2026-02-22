----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 06:57:58 PM
-- Design Name: 
-- Module Name: reg_file - Behavioral
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

entity reg_file is
    GENERIC(
        ADDR_WIDTH  :   integer := 2;
        DATA_WIDTH  :   integer := 8
        );
    Port ( clk : in STD_LOGIC;
           wr_en  : in STD_LOGIC;
           w_addr : in STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
           r_addr : in STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
           w_data : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
           r_data : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
           );
end reg_file;

architecture Behavioral of reg_file is
    type mem_2d_type is array   (0 to 2**ADDR_WIDTH - 1) of
         std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal array_reg    :   mem_2d_type;
begin
    process(clk) begin
        if (clk'event and clk = '1') then
            if (wr_en = '1') then
                array_reg(to_integer(unsigned(w_addr))) <= w_data;
            end if;
        end if;
    end process;
    
    --read port
    r_data  <=  array_reg(to_integer(unsigned(r_addr)));

end Behavioral;
