----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2026 05:32:06 PM
-- Design Name: 
-- Module Name: mmio_controller - Behavioral
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

--The inputs are the signals from the system bus
--The outputs are 64 slot interfaces connecting to 64 I/O cores

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.io_map_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mmio_controller is
--  Port ( );
    port(
    --system buses
    mmio_cs         :   in std_logic;
    mmio_wr         :   in std_logic;
    mmio_rd         :   in std_logic;
    mmio_addr       :   in std_logic_vector(20 downto 0);
    mmio_wr_data    :   in std_logic_vector(31 downto 0);
    mmio_rd_data    :   out std_logic_vector(31 downto 0);
    --slot interface
    slot_cs_array       :   out std_logic_vector(63 downto 0);
    slot_mem_rd_array   :   out std_logic_vector(63 downto 0);
    slot_mem_wr_array   :   out std_logic_vector(63 downto 0);
    slot_reg_addr_array :   out slot_2d_reg_type;
    slot_rd_data_array  :   in slot_2d_data_type;
    slot_wr_data_array  :   out slot_2d_data_type
    );
end mmio_controller;

architecture Behavioral of mmio_controller is
--6 bits is module bits for spec slots; 5 bits for spec registers in slot
    alias slot_addr :   std_logic_vector(5 downto 0) is
                        mmio_addr(10 downto 5);
    alias reg_addr  :   std_logic_vector(4 downto 0) is
                        mmio_addr(4 downto 0);
begin
    --address decoding
    process (slot_addr, mmio_cs) begin
        slot_cs_array <= (others => '0');
        if (mmio_cs = '1') then
            slot_cs_array(to_integer(unsigned(slot_addr))) <= '1';
        end if;
    end process;
    --broadcast to all slots
    slot_mem_rd_array   <=  (others =>  mmio_rd);
    slot_mem_wr_array   <=  (others =>  mmio_wr);
    slot_wr_data_array  <=  (others =>  mmio_wr_data);
    slot_reg_addr_array <=  (others =>  reg_addr);
    --mux for read data
    mmio_rd_data    <=  slot_rd_data_array(to_integer(unsigned(slot_addr)));
end Behavioral;
