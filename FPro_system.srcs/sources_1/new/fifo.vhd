----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2025 07:45:59 PM
-- Design Name: 
-- Module Name: fifo - arch
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
generic(
ADDR_W : integer := 2;
DATA_W : integer := 8
);
port(
clk, rst : in std_logic;
rd,wr : in std_logic;
wr_data : in std_logic_vector(DATA_W -1 downto 0);
full, empty : out std_logic;
rd_data : out std_logic_vector(DATA_W -1 downto 0)
);
end fifo;
architecture arch of fifo is
signal rd_addr, wr_addr : std_logic_vector(ADDR_W -1 downto 0);
signal full_reg, empty_reg : std_logic;
signal wr_data_reg, rd_data_reg : std_logic_vector(DATA_W-1 downto 0);
signal wr_en : std_logic;
begin

wr_data_reg <= wr_data;
--component imports
--ctrl unit
ctrl_unit : entity work.fifo_ctrl
generic map(ADDR_W => ADDR_W)
port map(
clk => clk,
rst => rst,
wr => wr,
rd => rd,
wr_addr => wr_addr,
rd_addr => rd_addr,
full => full_reg,
empty => empty_reg
);

--reg file 
register_file : entity work.reg_file
generic map(
addr_wid => ADDR_W,
data_wid => DATA_W
)
port map(
clk => clk,
rst => rst,
wr_en => wr_en,
rd_addr => rd_addr,
wr_addr => wr_addr,
wr_data => wr_data_reg,
rd_data => rd_data_reg
);

-- wr_en logic 
wr_en <= wr and (not full_reg);

--output assign
rd_data <= rd_data_reg;
empty <= empty_reg;
full <= full_reg;
end arch;