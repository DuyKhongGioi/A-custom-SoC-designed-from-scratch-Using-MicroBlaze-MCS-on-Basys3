library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity acl2_controller is
    Port ( 
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        
        -- Giao tiếp với SPI Master
        spi_ready  : in  STD_LOGIC;
        spi_done   : in  STD_LOGIC;
        spi_dout   : in  STD_LOGIC_VECTOR(7 downto 0);
        spi_din    : out STD_LOGIC_VECTOR(7 downto 0);
        spi_start  : out STD_LOGIC;
        
        -- Điều khiển CS của Pmod
        cs         : out STD_LOGIC;
        
        -- Dữ liệu ngõ ra
        accel_x    : out STD_LOGIC_VECTOR(11 downto 0);
        accel_y    : out STD_LOGIC_VECTOR(11 downto 0);
        accel_z    : out STD_LOGIC_VECTOR(11 downto 0)
    );
end acl2_controller;

architecture Behavioral of acl2_controller is
    type state_type is (S_IDLE, S_WRITE_CONFIG, S_READ_DATA);
    signal state : state_type := S_IDLE;
    
    signal step : integer range 0 to 20 := 0;
    signal setup_done : std_logic := '0';
    
    -- Thanh ghi tạm
    signal xl, xh, yl, yh, zl, zh : std_logic_vector(7 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= S_IDLE;
            step <= 0;
            setup_done <= '0';
            cs <= '1';
            spi_start <= '0';
            spi_din <= x"00";
        elsif rising_edge(clk) then
            spi_start <= '0'; -- Xung start chỉ nảy 1 chu kỳ clock
            
            case state is
                when S_IDLE =>
                    if setup_done = '0' then
                        state <= S_WRITE_CONFIG;
                        step <= 0;
                    else
                        state <= S_READ_DATA;
                        step <= 0;
                    end if;

                -- QUÁ TRÌNH KHỞI TẠO (Ghi 0x02 vào 0x2D)
                when S_WRITE_CONFIG =>
                    case step is
                        when 0 => cs <= '0'; if spi_ready = '1' then spi_din <= x"0A"; spi_start <= '1'; step <= 1; end if;
                        when 1 => if spi_done = '1' then step <= 2; end if;
                        when 2 => if spi_ready = '1' then spi_din <= x"2D"; spi_start <= '1'; step <= 3; end if;
                        when 3 => if spi_done = '1' then step <= 4; end if;
                        when 4 => if spi_ready = '1' then spi_din <= x"02"; spi_start <= '1'; step <= 5; end if;
                        when 5 => if spi_done = '1' then step <= 6; end if;
                        when 6 => cs <= '1'; setup_done <= '1'; state <= S_IDLE;
                        when others => state <= S_IDLE;
                    end case;

                -- QUÁ TRÌNH ĐỌC DỮ LIỆU (Đọc từ 0x0E)
                when S_READ_DATA =>
                    case step is
                        when 0 => cs <= '0'; if spi_ready = '1' then spi_din <= x"0B"; spi_start <= '1'; step <= 1; end if;
                        when 1 => if spi_done = '1' then step <= 2; end if;
                        when 2 => if spi_ready = '1' then spi_din <= x"0E"; spi_start <= '1'; step <= 3; end if;
                        when 3 => if spi_done = '1' then step <= 4; end if;
                        
                        -- Lấy X LSB & MSB
                        when 4 => if spi_ready = '1' then spi_din <= x"00"; spi_start <= '1'; step <= 5; end if;
                        when 5 => if spi_done = '1' then xl <= spi_dout; step <= 6; end if;
                        when 6 => if spi_ready = '1' then spi_din <= x"00"; spi_start <= '1'; step <= 7; end if;
                        when 7 => if spi_done = '1' then xh <= spi_dout; step <= 8; end if;
                        
                        -- Lấy Y LSB & MSB
                        when 8 => if spi_ready = '1' then spi_din <= x"00"; spi_start <= '1'; step <= 9; end if;
                        when 9 => if spi_done = '1' then yl <= spi_dout; step <= 10; end if;
                        when 10=> if spi_ready = '1' then spi_din <= x"00"; spi_start <= '1'; step <= 11; end if;
                        when 11=> if spi_done = '1' then yh <= spi_dout; step <= 12; end if;
                        
                        -- Lấy Z LSB & MSB
                        when 12=> if spi_ready = '1' then spi_din <= x"00"; spi_start <= '1'; step <= 13; end if;
                        when 13=> if spi_done = '1' then zl <= spi_dout; step <= 14; end if;
                        when 14=> if spi_ready = '1' then spi_din <= x"00"; spi_start <= '1'; step <= 15; end if;
                        when 15=> if spi_done = '1' then zh <= spi_dout; step <= 16; end if;
                        
                        -- Cập nhật dữ liệu & Kéo CS lên
                        when 16=> 
                            cs <= '1';
                            accel_x <= xh(3 downto 0) & xl;
                            accel_y <= yh(3 downto 0) & yl;
                            accel_z <= zh(3 downto 0) & zl;
                            state <= S_IDLE;
                        when others => state <= S_IDLE;
                    end case;
            end case;
        end if;
    end process;
end Behavioral;