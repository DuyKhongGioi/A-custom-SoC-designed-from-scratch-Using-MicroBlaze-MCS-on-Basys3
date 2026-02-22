----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2026 10:05:53 PM
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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

entity uart_rx is
    GENERIC(
        DBIT    :   integer := 8;   --data bits
        SB_TICK :   integer := 16 --ticks (oversample) for stop bits
        );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           rx : in STD_LOGIC;
           s_tick : in STD_LOGIC;
           rx_done : out STD_LOGIC;
           dout : out STD_LOGIC_VECTOR (7 downto 0));
end uart_rx;

architecture Behavioral of uart_rx is
    type state_type is (idle, start, data, stop);
    signal state_reg        :   state_type;
    signal state_next       :   state_type;
    signal s_reg, s_next    :   unsigned(4 downto 0);--sampling count
    signal n_reg, n_next    :   unsigned(2 downto 0);--count number of data bit
    signal d_reg, d_next    :   std_logic_vector(7 downto 0);
    signal sync1_reg        :   std_logic;
    signal sync2_reg        :   std_logic;
    signal sync_rx          :   std_logic;
begin
    --synchronization for rx signal
    process(clk, reset) begin
        if (reset = '1') then
            sync1_reg <= '0';
            sync2_reg <= '0';
        elsif (clk'event and clk = '1') then
            sync1_reg <= rx;
            sync2_reg <= sync1_reg;
        end if;
    end process;
    sync_rx <= sync2_reg;
    
    process(clk, reset) begin
        if (reset = '1') then
            state_reg <= idle;
            s_reg <= (others => '0');
            n_reg <= (others => '0');
            d_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            d_reg <= d_next;
        end if;
    end process;
    
    --next state logic
    process (state_reg, s_reg, n_reg, d_reg, s_tick, sync_rx) begin
        state_next <= state_reg;
        s_next <= s_reg;
        n_next <= n_reg;
        d_next <= d_reg;
        rx_done <= '0';
        case state_reg is
            when idle =>   
                if (sync_rx = '0') then
                    state_next <= start;
                    s_next <= (others => '0');
                end if;
            when start =>
                if (s_tick = '1') then
                    if (s_reg = 7) then
                        state_next <= data;
                        s_next <= (others => '0');
                        n_next <= (others => '0');
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            when data =>
                if (s_tick = '1') then
                    if (s_reg = 15) then
                        s_next <= (others => '0');
                        d_next <= sync_rx & d_reg(7 downto 1); --shift the lsb out, recieve the data into lsb
                        if (n_reg = (DBIT - 1)) then
                            state_next <= stop;
                        else
                            n_next <= n_reg + 1;
                        end if;
                    else
                        s_next <= s_reg + 1;
                    end if;
                 end if;
            when stop =>
                if (s_tick = '1') then
                    if (s_reg = (SB_TICK - 1)) then
                        state_next <= idle;
                        rx_done <= '1';
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            end case;
      end process;
      
      dout <= d_reg;

end Behavioral;
