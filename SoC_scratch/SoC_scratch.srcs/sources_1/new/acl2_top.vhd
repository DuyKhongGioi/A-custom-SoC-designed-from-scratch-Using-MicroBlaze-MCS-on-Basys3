library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity acl2_top is
    Port ( 
        clk     : in  STD_LOGIC;  -- 100MHz
        btnC    : in  STD_LOGIC;  -- Nút nhấn làm Reset
        
        -- Cổng Pmod (ví dụ cổng JA)
        ja_cs   : out STD_LOGIC;
        ja_mosi : out STD_LOGIC;
        ja_miso : in  STD_LOGIC;
        ja_sclk : out STD_LOGIC;
        
        -- LED hiển thị (12 LED)
        led     : out STD_LOGIC_VECTOR(11 downto 0)
    );
end acl2_top;

architecture Behavioral of acl2_top is
    signal spi_din, spi_dout : std_logic_vector(7 downto 0);
    signal spi_start, spi_ready, spi_done : std_logic;
    signal accel_x, accel_y, accel_z : std_logic_vector(11 downto 0);
begin

    -- Ánh xạ dữ liệu trục X ra đèn LED để test
    led <= accel_x;

    -- 1. Gọi lõi SPI của bạn
    SPI_MASTER_INST : entity work.spi
        port map (
            clk      => clk,
            reset    => btnC,
            din      => spi_din,
            divisor  => x"0032", -- Hệ số chia 50 -> SCLK = 1MHz
            start    => spi_start,
            cpole    => '0',     -- Mode 0
            cphase   => '0',     -- Mode 0
            dout     => spi_dout,
            spi_done => spi_done,
            ready    => spi_ready,
            sclk     => ja_sclk,
            miso     => ja_miso,
            mosi     => ja_mosi
        );

    -- 2. Gọi máy trạng thái điều khiển
    CONTROLLER_INST : entity work.acl2_controller
        port map (
            clk        => clk,
            reset      => btnC,
            spi_ready  => spi_ready,
            spi_done   => spi_done,
            spi_dout   => spi_dout,
            spi_din    => spi_din,
            spi_start  => spi_start,
            cs         => ja_cs,
            accel_x    => accel_x,
            accel_y    => accel_y,
            accel_z    => accel_z
        );

end Behavioral;