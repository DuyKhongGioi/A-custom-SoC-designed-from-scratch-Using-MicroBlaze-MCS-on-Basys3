----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 04:33:48 PM
-- Design Name: 
-- Module Name: i2c - Behavioral
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

entity i2c_master is
--  Port ( );
    port(
        clk, reset: in std_logic;
        din:        in std_logic_vector(7 downto 0);
        cmd:        in std_logic_vector(2 downto 0);
        divisor:    in std_logic_vector(15 downto 0);
        wr_i2c:     in std_logic;
        scl:        out std_logic;
        sda:        inout std_logic;
        ready:      out std_logic;
        done:       out std_logic;
        ack:        out std_logic;
        dout:       out std_logic_vector(7 downto 0)
    );
end i2c_master;

architecture Behavioral of i2c_master is
    CONSTANT START_CMD  :   STD_LOGIC_VECTOR(2 DOWNTO 0)    :=  "000";
    CONSTANT WR_CMD     :   STD_LOGIC_VECTOR(2 DOWNTO 0)    :=  "001";
    CONSTANT RD_CMD     :   STD_LOGIC_VECTOR(2 DOWNTO 0)    :=  "010";
    CONSTANT STOP_CMD   :   STD_LOGIC_VECTOR(2 DOWNTO 0)    :=  "011";
    CONSTANT RESTART_CMD:   STD_LOGIC_VECTOR(2 DOWNTO 0)    :=  "100";
    
    type state_type is (
        idle, hold, start1, start2, data1, data2, data3, data4, data_end, restart, stop1, stop2);
    signal state_reg        :   state_type;
    signal state_next       :   state_type;
    signal c_reg, c_next    :   unsigned(15 downto 0);
    signal quarter          :   unsigned(15 downto 0);
    signal half             :   unsigned(15 downto 0);
    signal tx_reg, tx_next  :   std_logic_vector(8 downto 0);
    signal rx_reg, rx_next  :   std_logic_vector(8 downto 0);
    signal cmd_reg, cmd_next:   std_logic_vector(2 downto 0);
    signal n_reg, n_next    :   unsigned(3 downto 0);
    signal sda_out, scl_out :   std_logic;
    signal sda_reg, scl_reg :   std_logic;
    signal into             :   std_logic;
    signal nack             :   std_logic;
    signal data_phase       :   std_logic;
begin
    --output control logic
    --buffer for sda and scl lines
    process(clk, reset) begin
        if (reset = '1') then
            sda_reg <=  '1';
            scl_reg <=  '1';
        elsif(clk'event and clk = '1') then
            sda_reg <=  sda_out;
            scl_reg <=  scl_out;
        end if;
    end process;
    --only master drives scl lines
    scl <=  'Z' when scl_reg = '1' else '0';
    --sda are with pull up resistors
    --and becomes high when not driven
    into <= '1' when
        (data_phase = '1' and cmd_reg = RD_CMD and n_reg < 8) or
        (data_phase = '1' and cmd_reg = WR_CMD and n_reg = 8) else '0';
    sda <= 'Z' when into = '1' or sda_reg = '1' else '0';
    --output
    dout <= rx_reg(8 downto 1);
    ack  <= rx_reg(0);--from slave in write opr
    nack <= din(0);--used by master in read opr
    
    --register
    process(clk, reset) begin
        if (reset = '1') then
            state_reg <= idle;
            c_reg   <=  (others => '0');
            n_reg <= (others => '0');
            cmd_reg <= (others => '0');
            tx_reg <= (others => '0');
            rx_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
                state_reg <= state_next;
                c_reg  <=   c_next;
                n_reg   <=  n_next;
                cmd_reg <=  cmd_next;
                tx_reg  <=  tx_next;
                rx_reg  <=  rx_next;
        end if;
    end process;
    
    --intervals
    quarter <= unsigned(divisor);
    half <= quarter(14 downto 0) & '0';
    
    --next state logic
    process(state_reg, n_reg, tx_reg, c_reg, rx_reg, cmd_reg,
            cmd, din, wr_i2c, sda, nack, quarter, half) begin
        state_next  <=  state_reg;
        c_next  <=  c_reg + 1;--count continuously
        n_next  <=  n_reg;
        tx_next <=  tx_reg;
        rx_next <=  rx_reg;
        cmd_next<=  cmd_reg;
        done    <=  '0';
        ready   <=  '0';
        scl_out <=  '1';
        sda_out <=  '1';
        data_phase <=   '0';
        
        case state_reg is
            when idle => 
                ready <= '1';
                if (wr_i2c = '1' and cmd = START_CMD) then
                    state_next  <=  start1;
                    c_next  <=  (others => '0');
                end if;
            when start1 => 
                sda_out <= '0';
                if (c_reg = half) then
                    c_next <= (others => '0');
                    state_next  <=  start2;
                end if;
            when start2 =>  
                sda_out <= '0';
                scl_out <= '0';
                if (c_reg = quarter) then
                    c_next  <=  (others => '0');
                    state_next  <=  hold;
                end if;
            when hold => --in progress, prepare for the next opr
                ready   <=  '1';
                sda_out <=  '0';
                scl_out <=  '0';
                if (wr_i2c = '1') then
                    cmd_next    <=  cmd;
                    c_next      <=  (others => '0');
                    case cmd is
                        when RESTART_CMD | START_CMD =>
                            state_next  <=  restart;
                        when STOP_CMD =>
                            state_next <= stop1;
                        when others => --read/write a byte
                            n_next  <=  (others => '0');
                            state_next  <=  data1;
                            tx_next     <=  din & nack;-- nack used in read
                    end case;
                end if;
            when data1 =>
                sda_out <= tx_reg(8);
                scl_out <= '0';
                data_phase <= '1';
                if (c_reg = quarter) then
                    c_next <=   (others => '0');
                    state_next  <=  data2;
                end if;
            when data2 => 
                sda_out <= tx_reg(8);
                data_phase <= '1';
                if (c_reg = quarter) then
                    c_next  <=  (others => '0');
                    state_next  <=  data3;
                    rx_next <=  rx_reg(7 downto 0) & sda;
                end if;   
            when data3 =>
                sda_out <=  tx_reg(8);
                data_phase <= '1';
                if (c_reg = quarter) then
                    c_next  <=  (others => '0');
                    state_next  <=  data4;
                end if;
            when data4 =>
                sda_out <=  tx_reg(8);
                scl_out <=  '0';
                data_phase  <=  '1';
                if (c_reg = quarter) then
                    c_next  <=  (others => '0');
                    if (n_reg = 8) then --done with 8 data & 1 ack bit
                        state_next  <=  data_end;
                        done    <=  '1';
                    else
                        tx_next <=  tx_reg(7 downto 0) & '0';
                        n_next  <=  n_reg + 1;
                        state_next  <=  data1;
                    end if;
                end if;
            when data_end => 
                sda_out <=  '0';
                scl_out <=  '0';
                if (c_reg = quarter) then
                    c_next  <=  (others => '0');
                    state_next  <=  hold;
                end if;
            when restart => --generate idle condition
                if (c_reg = half) then
                    c_next  <=  (others => '0');
                    state_next  <=  start1;
                end if;
            when stop1 => --stop condition
                sda_out <= '0';
                if (c_reg = half) then
                    c_next  <=  (others => '0');
                    state_next <= stop2;
                end if;
            when stop2  =>
                if (c_reg = half) then
                    state_next  <=  idle;
                end if;                
        end case;
    end process;
end Behavioral;
