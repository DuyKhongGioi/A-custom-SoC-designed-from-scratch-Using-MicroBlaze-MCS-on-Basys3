----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2026 10:38:29 PM
-- Design Name: 
-- Module Name: gpo_core - Behavioral
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

entity gpo_core is
--  Port ( );
    generic(W: integer := 8);   --width for output port
    port (
    clk:        in std_logic;
    reset:      in std_logic;
    --SLOT INTERFACE
    cs:         in std_logic;
    write:      in std_logic;
    read:       in std_logic;
    addr:       in std_logic_vector(4 downto 0);
    rd_data:    out std_logic_vector(31 downto 0);
    wr_data:    in std_logic_vector(31 downto 0);
    --external signals
    dout:       out std_logic_vector(W-1 downto 0)
    );
end gpo_core;

architecture Behavioral of gpo_core is
    signal buf_reg: std_logic_vector(W-1 downto 0);
    signal wr_en:   std_logic;
begin
    -- slot write interface
    process(clk, reset) begin
        if (reset = '1') then
            buf_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (wr_en = '1') then
                buf_reg <= wr_data(W-1 downto 0);
            end if;
        end if;
    end process;
    ---
    --decoding circuit
    wr_en <= '1' when write = '1' and cs = '1' else '0';
    -- slot read interface
    rd_data <= (others => '0');
    --external output
    dout <= buf_reg;
end Behavioral;
