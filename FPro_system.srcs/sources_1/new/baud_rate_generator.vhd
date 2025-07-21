----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/16/2025 04:44:59 AM
-- Design Name: 
-- Module Name: baud_rate_gen - arch
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

entity baud_gen is
generic( N : integer := 11);
port(
clk, rst : in std_logic;
dvsr : in std_logic_vector(N-1 downto 0);
tick : out std_logic
);
end baud_gen;
architecture arch of baud_gen is
signal cur_reg, next_reg : unsigned(N-1 downto 0);
begin

--synchronus process
sync : process(clk, rst)
begin 
        if(rst = '1' ) then 
              cur_reg <= (others => '0');
        elsif(rising_edge(clk)) then
              cur_reg <= next_reg;
        end if;
end process sync;

--next reg value logic 
next_reg <= (others => '0') when ( cur_reg = unsigned(dvsr)) else cur_reg + 1;

--output 
tick <= '1' when ( cur_reg = 1 ) else '0';
end arch;