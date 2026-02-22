----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 02:50:09 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

entity uart_tx is
    generic (   DBIT    :   integer := 8;  
                SB_TICK :   integer := 16
            );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           tx_start : in STD_LOGIC;
           s_tick : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR (7 downto 0);
           tx_done : out STD_LOGIC;
           tx : out STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is
    type state_type is (idle, start, data, stop);
    signal state_reg    :   state_type;
    signal state_next   :   state_type;
    signal s_reg, s_next:   unsigned (4 downto 0);
    signal n_reg, n_next:   unsigned (2 downto 0);
    signal d_reg, d_next:   std_logic_vector(7 downto 0);
    signal tx_reg, tx_next  :   std_logic; --buffer- remove potential gltich for tx signal
begin

    process(clk, reset) begin
        if (reset = '1') then
            state_reg   <=  idle;
            s_reg       <=  (others => '0');
            n_reg       <=  (others => '0');
            d_reg       <=  (others => '0');
            tx_reg      <=  '1';
        elsif(clk'event and clk = '1') then
            state_reg   <=  state_next;
            s_reg       <=  s_next;
            n_reg       <=  n_next;
            d_reg       <=  d_next;
            tx_reg      <= tx_next;
        end if;
    end process;
    
    process(state_reg, s_reg, n_reg, d_reg, s_tick, tx_reg, tx_start, din) begin
        state_next  <=  state_reg;
        s_next      <=  s_reg;
        n_next      <=  n_reg;
        d_next      <=  d_reg;
        tx_next     <=  tx_reg;
        tx_done     <=  '0';
        
        --each bit during transaction is last for 16 ticks
        case state_reg is
            when idle   => 
                tx_next <= '1';
                if (tx_start = '1') then
                    state_next  <= start;
                    s_next      <= (others  =>  '0');
                    d_next      <=  din;
                end if;
            when start  =>
                tx_next <=  '0';    --signal the transaction
                if (s_tick = '1') then
                    if (s_reg = 15) then
                        state_next  <=  data;
                        s_next      <=  (others => '0');
                        n_next      <=  (others => '0');
                    else
                        s_next  <=  s_reg + 1;
                    end if;
                end if;
            when data   =>
                tx_next <=  d_reg(0);--transmit lsb
                if (s_tick = '1') then
                    if (s_reg = 15) then
                        s_next  <=  (others => '0');
                        d_next  <=  '0' & d_reg(7 downto 1);
                        if (n_reg = DBIT - 1) then
                            state_next  <=  stop;
                        else
                            n_next  <=  n_reg + 1;
                        end if;
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            when stop   =>
                tx_next <= '1';--signal the stop bit
                if(s_tick = '1') then
                    if (s_reg = (SB_TICK - 1)) then
                        state_next <= idle;
                        tx_done <=  '1';
                    else
                        s_next  <= s_reg + 1;
                    end if;
                end if;
            end case;
        end process;
        
        tx <= tx_reg;

end Behavioral;
