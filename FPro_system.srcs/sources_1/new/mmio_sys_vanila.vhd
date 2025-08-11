----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/04/2025 06:50:17 PM
-- Design Name: 
-- Module Name: mmio_sys_vanilla - arch
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
use work.chu_io_map.all;
use IEEE.NUMERIC_STD.ALL;

entity mmio_sys_vanilla is
port(
clk, rst : in std_logic;
--FPRO bus
mmio_cs : in std_logic;
mmio_wr : in std_logic;
mmio_rd : in std_logic;
mmio_addr : in std_logic_vector(20 downto 0);
mmio_wr_data : in std_logic_vector(31 downto 0);
mmio_rd_data : out std_logic_vector(31 downto 0);
--led and switch
sw : in std_logic_vector(15 downto 0);
led : out std_logic_vector(15 downto 0);
--uart 
rx : in std_logic;
tx : out std_logic
);
end mmio_sys_vanilla;
architecture arch of mmio_sys_vanilla is
signal cs_array      : std_logic_vector( 63 downto 0);
signal mem_rd_data   : std_logic_vector(63 downto 0);
signal mem_wr_data   : std_logic_vector(63 downto 0);
signal addr_array    : std_2d_reg_type;
signal wr_data_array : std_2d_data_type;
signal rd_data_array : std_2d_data_type;
begin

-- compoenet imports 
--MMIO control unit 
ctrl_unit : entity work.mmio_controller(main)
port map(
--bus interfaces
bus_addr => mmio_addr,
bus_read => mmio_rd,
bus_write => mmio_wr,
bus_cs => mmio_cs,
bus_wr_data =>mmio_wr_data,
bus_rd_data => mmio_rd_data,
--slot interfaces
slot_rd_data_array => rd_data_array,
slot_wr_data_array => wr_data_array,
slot_addr_array => addr_array,
slot_cs_array => cs_array,
slot_write_array => mem_wr_data,
slot_read_array => mem_rd_data
);

--timer core 0
unit_timer_core : entity work.timer_core(main)
port map(
clk => clk,
rst => rst,
cs => cs_array(S0_TIMER),
read => mem_rd_data(S0_TIMER),
write => mem_wr_data(S0_TIMER),
addr => addr_array(S0_TIMER),
wr_data => wr_data_array(S0_TIMER),
rd_data => rd_data_array(S0_TIMER)
);

--uart core 1
unit_uart_core : entity work.uart_core(arch)
port map(
clk => clk,
rst => rst,
--mmio interface 
cs => cs_array(S1_UART),
write => mem_wr_data(S1_UART),
read => mem_rd_data(S1_UART),
addr => addr_array(S1_UART),
wr_data => wr_data_array(S1_UART),
rd_data => rd_data_array(S1_UART),
--uart 
rx => rx,
tx => tx
);

--gpo core
unit_gpo_core : entity work.gpo_core(arch)
generic map(
W => 16
)
port map(
clk => clk,
rst => rst,
--mmio interface 
cs => cs_array(S2_LED),
read => mem_rd_data(S2_LED),
write => mem_wr_data(S2_LED),
addr => addr_array(S2_LED),
wr_data => wr_data_array(S2_LED),
rd_data => rd_data_array(S2_LED),
--ouput
d_out => led
);
--gpi core 
unit_gpi_core : entity work.gpi_core(arch)
generic map(
 W => 16
)
port map(
clk => clk,
rst => rst,
--mmio interface 
cs => cs_array(S3_SW),
read => mem_rd_data(S3_SW),
write => mem_wr_data(S3_SW),
addr => addr_array(S3_SW),
wr_data => wr_data_array(S3_SW),
rd_data => rd_data_array(S3_SW),
--external input
d_in => sw
);

fill_0 : for i in 4 to 63 generate
    rd_data_array(i) <= (others => '0');
end generate fill_0;

end arch;