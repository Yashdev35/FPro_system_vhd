----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2025 03:44:49 PM
-- Design Name: 
-- Module Name: uart - arch
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
generic(
DBIT : integer := 8;
SB_TICK : integer := 16;
FIFO_W : integer := 4
);
port(
clk, rst : in std_logic;
rd_uart : in std_logic;
wr_uart : in std_logic;
dvsr : in std_logic_vector(10 downto 0);
rx : in std_logic;
w_data : in std_logic_vector(7 downto 0);
tx_full : out std_logic;
rx_empty : out std_logic;
r_data : out std_logic_vector(7 downto 0);
tx : out std_logic
);
end uart;
architecture arch of uart is
signal tick : std_logic;
signal rx_done_tick : std_logic;
signal tx_fifo_out : std_logic_vector(7 downto 0);
signal rx_data_out : std_logic_vector(7 downto 0);
signal tx_empty : std_logic;
signal tx_fifo_not_empty : std_logic;
signal tx_done_tick : std_logic;
begin

--componenets 
--buad rate generator 
baud_rate_gen_unit : entity work.baud_gen(arch)
port map(
clk => clk,
rst => rst,
dvsr => dvsr,
tick => tick
);

--uart receiver 
uart_rx_unit : entity work.uart_rx(arch)
port map(
clk => clk,
rst => rst,
rx => rx,
tick => tick,
dout => rx_data_out,
rx_done => rx_done_tick
);

--uart transmitter 
uart_tx_unit : entity work.uart_tx(arch)
port map(
clk => clk,
rst => rst,
tx_start => tx_fifo_not_empty,
tick => tick,
din => tx_fifo_out,
tx => tx,
tx_done => tx_done_tick
);

-- rx fifo 
uart_fifo_rx : entity work.fifo(arch)
generic map(
DATA_W => DBIT,
ADDR_W => FIFO_W
)
port map(
clk => clk,
rst => rst,
rd => rd_uart,
wr => rx_done_tick,
wr_data => rx_data_out,
empty => rx_empty,
full => open,
rd_data => r_data
);

-- rx fifo 
uart_fifo_tx : entity work.fifo(arch)
generic map(
DATA_W => DBIT,
ADDR_W => FIFO_W
)
port map(
clk => clk,
rst => rst,
rd => tx_done_tick,
wr => wr_uart,
wr_data => w_data,
empty => tx_empty,
full => tx_full,
rd_data => tx_fifo_out
);

--signal logics 
tx_fifo_not_empty <= not tx_empty;

end arch;