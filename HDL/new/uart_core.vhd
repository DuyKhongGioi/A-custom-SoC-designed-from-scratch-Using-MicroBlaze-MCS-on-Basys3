----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2026 10:15:30 PM
-- Design Name: 
-- Module Name: uart_core - Behavioral
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

entity uart_core is
    generic(FIFO_DEPTH_BIT: INTEGER:= 8); --fifo addr bits
    Port ( 
    clk:    in std_logic;
    reset:  in std_logic;
    -- UART SLOT INTERFACE
    cs:     in std_logic;
    write:  in std_logic;
    read:   in std_logic;
    addr:   in std_logic_vector(4 downto 0);
    rd_data:out std_logic_vector(31 downto 0);
    wr_data:in std_logic_vector(31 downto 0);
    --external signals
    tx:     out std_logic;
    rx:     in std_logic
    );
end uart_core;

architecture Behavioral of uart_core is
    signal wr_en        :   std_logic;
    signal wr_uart      :   std_logic;
    signal rd_uart      :   std_logic;
    signal wr_divisor   :   std_logic;
    signal tx_full      :   std_logic;
    signal rx_empty     :   std_logic;
    signal r_data       :   std_logic_vector(7 downto 0);
    signal divisor_reg  :   std_logic_vector(10 downto 0);   
begin
    --instantiate uart controller
    uart_unit   :   entity work.uart
    generic map(
        DBIT    =>  8,
        SB_TICK =>  16,
        FIFO_W  =>  FIFO_DEPTH_BIT)
    port map(
        clk         => clk,
        reset       =>  reset,
        rd_uart     =>  rd_uart,
        wr_uart     =>  wr_uart,
        divisor     =>  divisor_reg,
        rx          =>  rx,
        tx          =>  tx,
        w_data      =>  wr_data(7 downto 0),
        r_data      =>  r_data,
        tx_full     =>  tx_full,
        rx_empty    =>  rx_empty
    );
    --baud rate register
    process(clk, reset) begin
        if(reset = '1')  then
            divisor_reg <=  (others =>  '0');
        elsif (clk'event and clk = '1') then
            if (wr_divisor = '1') then
                divisor_reg <= wr_data(10 downto 0);
            end if;
        end if;
    end process;
    
    --decoding
    wr_en       <=  '1' when write = '1' and cs = '1' else '0';
    wr_divisor  <=  '1' when addr(1 downto 0) = "01" and wr_en = '1' else '0';--divisor_reg of uart core, offset 1
    wr_uart     <=  '1' when addr(1 downto 0) = "10" and wr_en = '1' else '0';--offset 2
    rd_uart     <=  '1' when addr(1 downto 0) = "11" and wr_en = '1' else '0';--offset 3
    
    --read mux
    rd_data <=  x"00000" & "00" & tx_full & rx_empty & r_data;
end Behavioral;
