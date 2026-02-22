----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2026 01:05:45 AM
-- Design Name: 
-- Module Name: timer_core - Behavioral
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

entity timer_core is
--  Port ( );
    port (
    clk:    in std_logic;
    reset:  in std_logic;
    --slot interface
    cs:     in std_logic;
    write:  in std_logic;
    read:   in std_logic;
    addr:   in std_logic_vector(4 downto 0);
    rd_data:out std_logic_vector(31 downto 0);
    wr_data:in std_logic_vector(31 downto 0)
    );
end timer_core;

architecture Behavioral of timer_core is
    signal count_reg    :   unsigned (47 downto 0);
    signal count_next   :   unsigned (47 downto 0);
    signal ctrl_reg     :   std_logic;
    signal wr_en        :   std_logic;
    signal clear, go    :   std_logic;
begin
    --COUNTER CIRCUIT
    process(clk, reset) begin
        if (reset = '1') then
            count_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            count_reg <= count_next;
        end if;
    end process;
    --next state
    count_next <= (others => '0') when clear = '1' else
                   count_reg + 1 when go = '1' else
                   count_reg;
    --WRAPPING CIRCUIT
    --control register (offset 2)
    process(clk, reset) begin
        if (reset = '1') then
            ctrl_reg <= '0';
        elsif (clk'event and clk = '1') then
            if (wr_en = '1') then
                ctrl_reg <= wr_data(0);
            end if;
        end if;
    end process;
    --decoding
    wr_en <= '1' when write = '1' and cs = '1' and addr(1 downto 0) = "10" else '0';
    clear <= '1' when wr_en = '1' and wr_data(1) = '1' else '0';
    go    <= ctrl_reg;
    --slot read mux
    rd_data <= std_logic_vector(count_reg(31 downto 0)) when addr(0) = '0' else
               x"0000" & std_logic_vector(count_reg(47 downto 32));
end Behavioral;
