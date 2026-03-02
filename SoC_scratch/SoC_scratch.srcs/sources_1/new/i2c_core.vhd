----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2026 01:29:55 AM
-- Design Name: 
-- Module Name: i2c_core - Behavioral
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

entity i2c_core is
--  Port ( );
    port (
        clk     :   in std_logic;
        reset   :   in std_logic;
        --slot interface
        cs      :   in std_logic;
        write   :   in std_logic;
        read    :   in std_logic;
        addr    :   in std_logic_vector(4 downto 0);
        rd_data :   out std_logic_vector(31 downto 0);
        wr_data :   in std_logic_vector(31 downto 0);
        --external data
        scl     :   out std_logic;
        sda     :   inout std_logic
    );
end i2c_core;

architecture Behavioral of i2c_core is
    signal ready, ack   :   std_logic;
    signal dout         :   std_logic_vector(7 downto 0);
    signal divisor_reg  :   std_logic_vector(15 downto 0);
    signal wr_en        :   std_logic;
    signal wr_i2c       :   std_logic;
    signal wr_divisor   :   std_logic;
begin
    i2c_module: entity work.i2c_master 
    port map(
        clk =>  clk,
        reset   =>  reset,
        din =>  wr_data(7 downto 0),
        cmd =>  wr_data(10 downto 8),
        divisor =>  divisor_reg,
        wr_i2c  =>  wr_i2c,
        scl =>  scl,
        sda =>  sda,
        ready   =>  ready,
        done    =>  open,
        ack =>  ack,
        dout    =>  dout
        );
        --registers
        process(clk, reset) begin
            if (reset = '1') then
                divisor_reg <= (others => '0');
            elsif (clk'event and clk = '1') then
                if (wr_divisor = '1') then
                    divisor_reg <= wr_data(15 downto 0);
                end if;
            end if;
        end process;
        --decoding logic
        wr_en   <=  '1' when write = '1' and cs = '1' else '0';
        wr_divisor <= '1' when addr(0) = '0' and wr_en = '1' else '0';
        wr_i2c  <=  '1' when addr(0) = '1' and wr_en = '1' else '0';
        --read data
        rd_data <=  x"00000" & "00" & ack & ready & dout;

end Behavioral;
