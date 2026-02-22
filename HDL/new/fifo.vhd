----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 07:33:15 PM
-- Design Name: 
-- Module Name: fifo - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo is
    GENERIC(
        ADDR_WIDTH  :   integer := 2;
        DATA_WIDTH  :   integer := 8);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           rd : in STD_LOGIC;
           wr : in STD_LOGIC;
           empty : out STD_LOGIC;
           full : out STD_LOGIC;
           w_data:  in STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
           r_data : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
           );
end fifo;

architecture Behavioral of fifo is
    signal  full_tmp    :   std_logic;
    signal  wr_en       :   std_logic;
    signal  w_addr      :   std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal  r_addr      :   std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin
    --write enabled only when FIFO is not full
    wr_en   <=  wr and (not full_tmp);
    full    <=  full_tmp;
    --instantiate fifo controller
    control_unit    :   entity work.ctrl_fifo
    generic map(ADDR_WIDTH  =>  ADDR_WIDTH)
    port map(
        clk     =>  clk,
        reset   =>  reset,
        rd      =>  rd,
        wr      =>  wr,
        empty   =>  empty,
        full    =>  full_tmp,
        w_addr  =>  w_addr,
        r_addr  =>  r_addr
        );
    --instantiate registers file
    reg_file_unit   :   entity  work.reg_file
    generic map(
        ADDR_WIDTH  =>  ADDR_WIDTH,
        DATA_WIDTH  =>  DATA_WIDTH
        )
    port map(
        clk     =>  clk,
        w_addr  =>  w_addr,
        r_addr  =>  r_addr,
        w_data  =>  w_data,
        r_data  =>  r_data,
        wr_en   =>  wr_en
        );

end Behavioral;
