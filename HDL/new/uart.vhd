----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 08:15:13 PM
-- Design Name: 
-- Module Name: uart - Behavioral
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

entity uart is
    Generic(    
        DBIT    :   integer := 8;
        SB_TICK :   integer := 16;
        FIFO_W  :   integer := 4    --fifo addr bits
        );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           rd_uart : in STD_LOGIC;
           wr_uart : in STD_LOGIC;
           divisor : in STD_LOGIC_VECTOR (10 downto 0);
           rx : in STD_LOGIC;
           w_data : in STD_LOGIC_VECTOR (7 downto 0);
           tx_full : out STD_LOGIC;
           rx_empty : out STD_LOGIC;
           r_data : out STD_LOGIC_VECTOR (7 downto 0);
           tx : out STD_LOGIC);
end uart;

architecture Behavioral of uart is
    signal tick                 :   std_logic;
    signal rx_done              :   std_logic;
    signal tx_fifo_out          :   std_logic_vector(7 downto 0);
    signal rx_data_out          :   std_logic_vector(7 downto 0);
    signal tx_empty             :   std_logic;
    signal tx_fifo_not_empty    :   std_logic;
    signal tx_done              :   std_logic;
begin
    baud_gen_unit   :   entity work.baud_gen
    port map (
        clk     =>  clk,
        reset   =>  reset,
        divisor =>  divisor,
        tick    =>  tick
    );
    
    uart_rx_unit    :   entity  work.uart_rx
    generic map(DBIT    =>  DBIT,
                SB_TICK =>  SB_TICK
                )
    port map(
        clk     =>  clk,
        reset   =>  reset,
        rx      =>  rx,
        s_tick  =>  tick,
        rx_done =>  rx_done,
        dout    =>  rx_data_out
        );
    uart_tx_unit    :   entity  work.uart_tx
    generic map(DBIT    =>  DBIT,
                SB_TICK =>  SB_TICK
                )
    port map (  
        clk         =>  clk,
        reset       =>  reset,
        tx_start    =>  tx_fifo_not_empty,
        s_tick      =>  tick,
        din         =>  tx_fifo_out,
        tx_done     =>  tx_done,
        tx          =>  tx
        );
    fifo_rx_unit    :   entity  work.fifo
    generic map(
        DATA_WIDTH  =>  DBIT,
        ADDR_WIDTH  =>  FIFO_W
        )
    port map(
        clk =>  clk,
        reset   =>  reset,
        rd  =>  rd_uart,
        wr  =>  rx_done,
        w_data  =>  rx_data_out,
        empty   =>  rx_empty,
        full    =>  open,
        r_data  =>  r_data
    );
    fifo_tx_unit    :   entity  work.fifo
    generic map (
        DATA_WIDTH  =>  DBIT,
        ADDR_WIDTH  =>  FIFO_W
        )
    port map(
        clk =>  clk,
        reset   =>  reset,
        rd  =>  tx_done,
        wr  =>  wr_uart,
        w_data  =>  w_data,
        empty   =>  tx_empty,
        full    =>  tx_full,
        r_data  =>  tx_fifo_out
    );
    
    tx_fifo_not_empty   <=  not tx_empty;
    
end Behavioral;
