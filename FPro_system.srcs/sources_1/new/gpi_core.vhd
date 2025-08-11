----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2025 02:58:25 PM
-- Design Name: 
-- Module Name: gpi_core - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gpi_core is
generic(W : integer := 8);
port(
rst,clk : in std_logic;
--external input
d_in : in std_logic_vector(w-1 downto 0);
--wraper ckt
cs,read,write : in std_logic;
addr : in std_logic_vector(4 downto 0);
wr_data : in std_logic_vector(31 downto 0);
rd_data : out std_logic_vector(31 downto 0)
);
end gpi_core;
architecture arch of gpi_core is
signal buffer_reg : std_logic_vector(W-1 downto 0);
signal wr_en : std_logic;
begin
--sync
sync : process(rst,clk)
    begin 
      if(rst = '1') then
           buffer_reg <= (others =>'0');
      elsif( rising_edge(clk)) then 
           buffer_reg <= d_in;
      end if;
    end process sync;
    
--output assign
rd_data(w-1 downto 0) <= buffer_reg;
rd_data(31 downto w) <= (others => '0');

end arch;
