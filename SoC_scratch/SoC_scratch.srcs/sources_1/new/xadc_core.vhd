----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2026 02:37:25 PM
-- Design Name: 
-- Module Name: xadc_core - Behavioral
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

entity xadc_core is
--  Port ( );
    port (
    clk     :   in std_logic;
    reset   :   in std_logic;
    --SLOT INTERFACE
    cs      :   in std_logic;
    write   :   in std_logic;
    read    :   in std_logic;
    addr    :   in std_logic_vector(4 downto 0);
    rd_data :   out std_logic_vector(31 downto 0);
    wr_data :   in std_logic_vector(31 downto 0);
    --external
    adc_p   :   in std_logic_vector(3 downto 0);
    adc_n   :   in std_logic_vector(3 downto 0)
    );
end xadc_core;

architecture Behavioral of xadc_core is
    signal channel      :   std_logic_vector(4 downto 0);
    signal daddr_in     :   std_logic_vector(6 downto 0);
    signal eoc          :   std_logic;
    signal rdy          :   std_logic;
    signal adc_data     :   std_logic_vector(15 downto 0);
    signal adc6_out_reg :   std_logic_vector(15 downto 0);
    signal adc7_out_reg :   std_logic_vector(15 downto 0);
    signal adc14_out_reg:   std_logic_vector(15 downto 0);
    signal adc15_out_reg:   std_logic_vector(15 downto 0);
    signal tmpt_out_reg :   std_logic_vector(15 downto 0); --die temperature sensor
    signal vcc_out_reg  :   std_logic_vector(15 downto 0); --supply voltage sensor
begin
    xadc:   entity work.xadc_xilinx
    port map(
    
    daddr_in => daddr_in,    -- Address bus for the dynamic reconfiguration port
    den_in   => eoc,                        -- Enable Signal for the dynamic reconfiguration port
    di_in    => (others => '0'),   -- Input data bus for the dynamic reconfiguration port
    dwe_in   => '0',--read only-- Write Enable for the dynamic reconfiguration port
    do_out   => adc_data,  -- Output data bus for dynamic reconfiguration port
    drdy_out => rdy,-- Data ready signal for the dynamic reconfiguration port
    dclk_in  => clk,-- Clock input for the dynamic reconfiguration port
    reset_in => reset,                        -- Reset signal for the System Monitor control logic
    vauxp6   => adc_p(0), -- Auxiliary Channel 6
    vauxn6   => adc_n(0),
    vauxp7   => adc_p(1), -- Auxiliary Channel 7
    vauxn7   => adc_n(1),
    vauxp14  => adc_p(2),-- Auxiliary Channel 14
    vauxn14  => adc_n(2),
    vauxp15  => adc_p(3),-- Auxiliary Channel 15
    vauxn15  => adc_n(3),
    busy_out => open,-- ADC Busy signal
    channel_out =>  channel,-- Channel Selection Outputs
    eoc_out  => eoc,-- End of Conversion Signal
    eos_out  => open,                        -- End of Sequence Signal
    alarm_out=> open,-- OR'ed output of all the Alarms
    vp_in   =>  '0',-- Dedicated Analog Input Pair
    vn_in   =>  '0'
    );
    
    --xadc DRP address
    daddr_in    <=  "00" & channel;
    --immediate registers ans decoding circuit
    process(clk, reset) begin
        if (reset = '1') then
            adc6_out_reg    <=  (others => '0');
            adc7_out_reg    <=  (others => '0');
            adc14_out_reg    <=  (others => '0');
            adc15_out_reg    <=  (others => '0');
            tmpt_out_reg    <=  (others => '0');
            vcc_out_reg     <=  (others => '0');
        elsif (clk'event and clk = '1') then
            if (rdy = '1' and channel = "10110") then
                adc6_out_reg <= adc_data;
            end if;
            if (rdy = '1' and channel = "10111") then
                adc7_out_reg <= adc_data;
            end if;
            if (rdy = '1' and channel = "11110") then
                adc14_out_reg <= adc_data;
            end if;
            if (rdy = '1' and channel = "11111") then
                adc15_out_reg <= adc_data;
            end if;
            if (rdy = '1' and channel = "00000") then
                tmpt_out_reg <= adc_data;
            end if;            
            if (rdy = '1' and channel = "00001") then
                vcc_out_reg <= adc_data;
            end if;
         end if;
     end process;
     
     --read mux
     with addr(2 downto 0) select  
        --registers map
        rd_data <=  
                    x"0000" & adc6_out_reg  when "000",
                    x"0000" & adc7_out_reg  when "001",
                    x"0000" & adc14_out_reg when "010",
                    x"0000" & adc15_out_reg when "011",
                    x"0000" & tmpt_out_reg  when "100",
                    x"0000" & vcc_out_reg   when others; 
end Behavioral;
