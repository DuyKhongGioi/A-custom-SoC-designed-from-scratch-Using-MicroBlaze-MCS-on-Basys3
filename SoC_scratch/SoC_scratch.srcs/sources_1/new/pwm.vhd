----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2026 02:20:52 AM
-- Design Name: 
-- Module Name: pwm - Behavioral
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

entity pwm is
--  Port ( );
    generic(R:  integer := 10);  --resolution
    port (
        clk:        in std_logic;
        reset:      in std_logic;
        divisor:    in std_logic_vector(31 downto 0);  
        duty   :    in std_logic_vector(R downto 0); 
        pwm_out:    out std_logic
    );
end pwm;

architecture Behavioral of pwm is
    signal q_reg,q_next         :   unsigned (31 downto 0);    --for prescaler
    signal d_reg,d_next         :   unsigned (R-1 downto 0);
    signal d_ext                :   unsigned (R downto 0);  --extend for 100% duty cycle
    signal pwm_reg, pwm_next    :   std_logic;
    signal tick                 :   std_logic;
begin
    process(clk, reset) begin
        if (reset = '1') then   
            q_reg <=    (others =>  '0');
            d_reg <=    (others =>  '0');
            pwm_reg <=  '0';
        elsif (clk'event and clk = '1') then
            q_reg <=    q_next;
            d_reg <=    d_next;
            pwm_reg <=  pwm_next;
        end if;
    end process;
    --prescaler counter
    q_next  <=  (others => '0') when q_reg = unsigned(divisor) else q_reg + 1;
    tick    <=  '1' when q_reg = 0 else '0';
    --duty cycle counter
    d_next  <=  d_reg + 1 when tick = '1' else d_reg;
    d_ext   <=  '0' & d_reg;
    
    pwm_next <= '1' when d_ext < unsigned(duty) else '0';
    pwm_out <= pwm_reg;
    

end Behavioral;
