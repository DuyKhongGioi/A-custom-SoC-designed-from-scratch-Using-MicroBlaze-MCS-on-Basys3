--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Command: generate_target bd_74a9_wrapper.bd
--Design : bd_74a9_wrapper
--Purpose: IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_74a9_wrapper is
  port (
    Clk : in STD_LOGIC;
    IO_addr_strobe : out STD_LOGIC;
    IO_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IO_byte_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
    IO_read_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IO_read_strobe : out STD_LOGIC;
    IO_ready : in STD_LOGIC;
    IO_write_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IO_write_strobe : out STD_LOGIC;
    Reset : in STD_LOGIC
  );
end bd_74a9_wrapper;

architecture STRUCTURE of bd_74a9_wrapper is
  component bd_74a9 is
  port (
    Clk : in STD_LOGIC;
    Reset : in STD_LOGIC;
    IO_addr_strobe : out STD_LOGIC;
    IO_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IO_byte_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
    IO_read_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IO_read_strobe : out STD_LOGIC;
    IO_ready : in STD_LOGIC;
    IO_write_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IO_write_strobe : out STD_LOGIC
  );
  end component bd_74a9;
begin
bd_74a9_i: component bd_74a9
     port map (
      Clk => Clk,
      IO_addr_strobe => IO_addr_strobe,
      IO_address(31 downto 0) => IO_address(31 downto 0),
      IO_byte_enable(3 downto 0) => IO_byte_enable(3 downto 0),
      IO_read_data(31 downto 0) => IO_read_data(31 downto 0),
      IO_read_strobe => IO_read_strobe,
      IO_ready => IO_ready,
      IO_write_data(31 downto 0) => IO_write_data(31 downto 0),
      IO_write_strobe => IO_write_strobe,
      Reset => Reset
    );
end STRUCTURE;
