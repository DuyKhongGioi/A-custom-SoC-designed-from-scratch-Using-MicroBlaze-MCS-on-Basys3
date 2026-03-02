----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2026 01:19:44 AM
-- Design Name: 
-- Module Name: spi - Behavioral
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

entity spi is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR (7 downto 0);
           divisor : in STD_LOGIC_VECTOR (15 downto 0);
           start : in STD_LOGIC;
           cpole : in STD_LOGIC;
           cphase : in STD_LOGIC;
           dout : out STD_LOGIC_VECTOR (7 downto 0);
           spi_done : out STD_LOGIC;
           ready : out STD_LOGIC;
           sclk : out STD_LOGIC;
           miso : in STD_LOGIC;
           mosi : out STD_LOGIC);
end spi;

architecture Behavioral of spi is
    type state_type is (idle, p0, p1);
    signal state_reg    :   state_type;
    signal state_next   :   state_type;
    signal p_clk        :   std_logic;
    signal c_reg, c_next:   unsigned(15 downto 0);
    signal spi_clk_next :   std_logic;
    signal spi_clk_reg  :   std_logic;
    signal n_reg        :   unsigned(2 downto 0);--store number of data processed
    signal n_next       :   unsigned(2 downto 0);
    signal si_reg       :   std_logic_vector(7 downto 0);
    signal si_next      :   std_logic_vector(7 downto 0);
    signal so_reg       :   std_logic_vector(7 downto 0);
    signal so_next      :   std_logic_vector(7 downto 0);
begin
    process(clk, reset) begin   --registers
        if (reset = '1') then
            state_reg   <=  idle;
            si_reg      <=  (others =>  '0');
            so_reg      <=  (others =>  '0');
            n_reg       <=  (others =>  '0');
            c_reg       <=  (others =>  '0');
        elsif (clk'event and clk = '1') then
            state_reg   <=  state_next;
            si_reg      <=  si_next;
            so_reg      <=  so_next;
            n_reg       <=  n_next;
            c_reg       <=  c_next;
            spi_clk_reg <=  spi_clk_next;
        end if;
    end process;
    
    --next state logic and datapath
    process(state_reg, si_reg, so_reg, n_reg, c_reg, din, divisor, start, cphase, miso) begin
            state_next  <=  state_reg;
            ready       <=  '0';
            spi_done    <=  '0';
            si_next     <=  si_reg;
            so_next     <=  so_reg;
            n_next      <=  n_reg;
            c_next      <=  c_reg;
            
            case state_reg is
                when idle   =>  
                    ready   <=  '1';
                    if (start = '1') then
                        so_next <=  din;
                        n_next  <=  (others =>  '0');
                        c_next  <=  (others =>  '0');
                        state_next  <=  p0;
                    end if;
                when p0 =>
                    if (c_reg = unsigned(divisor)) then --sclk 0 to 1
                        state_next  <=  p1;
                        si_next     <=  si_reg(6 downto 0) & miso;
                        c_next      <=  (others =>  '0');
                    else
                        c_next  <=  c_reg + 1;
                    end if;
                when p1 =>
                    if (c_reg = unsigned(divisor)) then --sclk 1 to 0
                        if (n_reg = 7) then
                            spi_done    <=  '1';
                            state_next  <=  idle;
                        else
                            so_next <=  so_reg(6 downto 0) & '0';
                            state_next  <=  p0;
                            n_next  <=  n_reg + 1;
                            c_next  <=  (others => '0');
                        end if;
                    else
                        c_next  <=  c_reg + 1;
                    end if;
            end case;
        end process;
        
        --lookahead output decoding
        p_clk <= '1' when ((state_next  = p1 and cphase = '0') or
                           (state_next  = p0 and cphase = '1')) else '0';
        spi_clk_next    <=  p_clk when (cpole = '0') else not p_clk;
        --output
        dout    <=  si_reg;
        mosi    <=  so_reg(7);
        sclk    <=  spi_clk_reg;
                    

end Behavioral;
