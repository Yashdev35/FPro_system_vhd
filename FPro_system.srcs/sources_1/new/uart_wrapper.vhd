----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/25/2025 10:34:21 PM
-- Design Name: 
-- Module Name: uart_core - arch
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

entity uart_core is
generic (
FIFO_DEPTH_BIT : integer := 8
);
port(
clk,rst : in std_logic;
--wrapping clk for bus
cs : in std_logic;
write : in std_logic;
read : in std_logic;
addr : in std_logic_vector(4 downto 0);
wr_data : in std_logic_vector(31 downto 0);
rd_data : out std_logic_vector(31 downto 0);
--external inputs
rx : in std_logic;
tx : out std_logic
);
end uart_core;
architecture arch of uart_core is
signal wr_en : std_logic;
signal rd_uart : std_logic;
signal wr_uart : std_logic;
signal tx_full : std_logic;
signal rx_empty : std_logic;
signal wr_dvsr : std_logic;
signal r_data : std_logic_vector(7 downto 0);
signal dvsr_data : std_logic_vector(10 downto 0);
begin

-- compoenet uart controller 
uart_ctrl : entity work.uart(arch)
generic map(
DBIT => 8,
SB_TICK => 16,
FIFO_W => FIFO_DEPTH_BIT
)
port map(
clk => clk,
rst => rst,
rd_uart =>rd_uart,
wr_uart => wr_uart,
dvsr => dvsr_data,
rx => rx,
tx => tx,
w_data => wr_data(7 downto 0),
r_data => r_data,
tx_full => tx_full,
rx_empty => rx_empty
);

--sync clk process
sync : process(clk, rst)
begin
    if(rst = '1') then 
        dvsr_data <= (others => '0');
    elsif(rising_edge(clk)) then
        if(wr_dvsr = '1') then
            dvsr_data <= wr_data(10 downto 0);
        end if;
    end if;
end process sync;

--writing signals  
wr_en <= '1' when (cs ='1' and write ='1') else '0';
rd_uart <= '1' when (read = '1' and cs = '1') else '0';
wr_uart <= '1' when(wr_en = '1' and addr(1 downto 0) = "10") else '0';
wr_dvsr <= '1' when(wr_en = '1' and addr(1 downto 0) = "01") else '0';

--read data assign to wrapper ckt
rd_data <= x"00000" &"00"& tx_full & rx_empty & r_data;

end arch;
