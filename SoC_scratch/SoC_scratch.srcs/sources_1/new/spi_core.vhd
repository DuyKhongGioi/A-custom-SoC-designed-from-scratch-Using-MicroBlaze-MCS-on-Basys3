----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2026 06:04:07 PM
-- Design Name: 
-- Module Name: spi_core - Behavioral
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

entity spi_core is
--  Port ( );
    generic (S: integer := 2);
    port(
        clk     :   in std_logic;
        reset   :   in std_logic;
        --io bridge
        cs      :   in std_logic;
        write   :   in std_logic;
        read    :   in std_logic;
        addr    :   in std_logic_vector(4 downto 0);
        rd_data :   out std_logic_vector(31 downto 0);
        wr_data :   in std_logic_vector(31 downto 0);
        --signals
        spi_sclk:   out std_logic;
        spi_mosi:   out std_logic;
        spi_miso:   in std_logic;
        spi_ss_n:   out std_logic_vector(S-1 downto 0)
    );
end spi_core;

architecture Behavioral of spi_core is
    signal wr_en, wr_ss :   std_logic;
    signal wr_ctrl      :   std_logic;
    signal wr_spi       :   std_logic;
    signal ctrl_reg     :   std_logic_vector(31 downto 0);
    signal ss_n_reg     :   std_logic_vector(S-1 downto 0);
    signal spi_out      :   std_logic_vector(7 downto 0);
    signal spi_ready    :   std_logic;
    signal divisor      :   std_logic_vector(15 downto 0);
    signal cpole        :   std_logic;
    signal cphase       :   std_logic;
begin
    spi_module  :   entity work.spi
    port map(
        clk =>  clk,
        reset   =>  reset,
        din =>  wr_data(7 downto 0),
        divisor =>  divisor,
        start   =>  wr_spi,
        cpole   =>  cpole,
        cphase  =>  cphase,
        dout    =>  spi_out,
        sclk    =>  spi_sclk,
        miso    =>  spi_miso,
        mosi    =>  spi_mosi,
        spi_done    =>  open,
        ready   =>  spi_ready
        );
    --reisters
    process(clk, reset) begin
        if (reset = '1') then
            ctrl_reg    <=  x"0000_0200";   --divisor = 1028 => 50kHz sclk
            ss_n_reg    <=  (others =>  '0');
        elsif (clk'event and clk = '1') then
            if (wr_ctrl = '1') then
                ctrl_reg    <=  wr_data;
            end if;
            if (wr_ss = '1') then
                ss_n_reg    <=  wr_data(S-1 downto 0);
            end if;
        end if;
    end process;
    --decoding
    wr_en   <=  '1' when cs = '1' and write = '1' else '0';
    wr_ss   <=  '1' when wr_en = '1' and addr(1 downto 0) = "01" else '0';
    wr_spi  <=  '1' when wr_en = '1' and addr(1 downto 0) = "10" else '0';
    wr_ctrl <=  '1' when wr_en = '1' and addr(1 downto 0) = "11" else '0';
    --control signals
    divisor <=  ctrl_reg(15 downto 0);
    cpole   <=  ctrl_reg(16);
    cphase  <=  ctrl_reg(17);
    spi_ss_n<=  ss_n_reg;
    --read output
    rd_data <=  X"00000" & "000" & spi_ready & spi_out;



end Behavioral;
