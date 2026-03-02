----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2026 12:35:22 PM
-- Design Name: 
-- Module Name: pwm_core - Behavioral
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

entity pwm_core is
--  Port ( );
    GENERIC (
        W:  integer := 8;   --output port width
        R:  integer := 8    --number of PWM resolution (2^R levels)
        );
    port (
        clk         :   in std_logic;
        reset       :   in std_logic;
        --slot interface
        cs          :   in std_logic;
        write       :   in std_logic;
        read        :   in std_logic;
        addr        :   in std_logic_vector(4 downto 0);
        rd_data     :   out std_logic_vector(31 downto 0);
        wr_data     :   in std_logic_vector(31 downto 0);
        --external
        pwm_out     :   out std_logic_vector(W-1 downto 0)
        );
end pwm_core;

architecture Behavioral of pwm_core is
    type reg_file_type is array(W-1 downto 0) of
            std_logic_vector(R downto 0);
    signal duty_2d_reg  :   reg_file_type;
    signal wr_en, divisor_en    :   std_logic;
    signal duty_array_en        :   std_logic;
    signal q_reg, q_next        :   unsigned(31 downto 0);
    signal d_reg, d_next        :   unsigned(R-1 downto 0);
    signal d_ext                :   unsigned(R downto 0);
    signal pwm_next             :   std_logic_vector(W-1 downto 0);
    signal pwm_reg              :   std_logic_vector(W-1 downto 0);
    signal tick                 :   std_logic;
    signal divisor_reg          :   std_logic_vector(31 downto 0);
begin
    --wrapping circuit--
    --decoding circuit
    wr_en   <=  '1' when write = '1' and cs = '1' else '0';
    duty_array_en   <=  '1' when wr_en = '1' and addr(4) = '1' else '0';
    divisor_en  <=  '1' when wr_en = '1' and addr = "00000" else '0';
    
    --register for divisor
    process(clk, reset) begin
        if (reset = '1') then
            divisor_reg <=  (others => '0');
        elsif (clk'event and clk = '1') then
            if (divisor_en = '1') then
                divisor_reg <= wr_data;
            end if;
        end if;
    end process;
    
    --register file for duty cycle
    process(clk, reset) begin
        if (reset = '1') then
            duty_2d_reg <=  (others =>  (others =>  '0'));
        elsif (clk'event and clk = '1') then
            if (duty_array_en = '1') then
                duty_2d_reg(to_integer(unsigned(addr(3 downto 0)))) <= wr_data;
            end if;
        end if;
    end process;
    
    --multi bit pwm
    process(clk, reset) begin
        if (reset = '1') then
            q_reg   <=  (others => '0');
            d_reg   <=  (others =>  '0');
            pwm_reg <=  (others =>  '0');
        elsif(clk'event and clk = '1') then
            q_reg   <=  q_next;
            d_reg   <=  d_next;
            pwm_reg <=  pwm_next;
        end if;
    end process;
    --prescaler counter
    q_next  <=  (others =>  '0') when q_reg=unsigned(divisor_reg) else q_reg + 1;
    tick    <=  '1' when q_reg = 0 else '0';
    --duty cycle counter
    d_next  <=  d_reg + 1 when tick = '1' else d_reg;
    d_ext   <=  '0' & d_reg;
    --comparison circuit
    gen_comp_cell:  for i in 0 to W - 1 generate
        pwm_next(i) <=  '1' when d_ext<unsigned(duty_2d_reg(i)) else '0';
    end generate;
    
    pwm_out <= pwm_reg;
    --read data not used
    rd_data <=  (others =>  '0');
end Behavioral;
