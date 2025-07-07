----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2025 02:58:25 PM
-- Design Name: 
-- Module Name: gpo_core - Behavioral
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

entity gpo_core is
generic(w : integer := 8);
port(
clk,rst :in std_logic;
--external output
d_out : out std_logic_vector(w-1 downto 0);
--wrapping ckt
cs,read,write : in std_logic;
addr : in std_logic_vector(4 downto 0);
wr_data : in std_logic_vector(31 downto 0);
rd_data : out std_logic_vector(31 downto 0)
);
end gpo_core;
architecture Behavioral of gpo_core is
signal buffer_reg : std_logic_vector(w-1 downto 0);
signal wr_en : std_logic;
begin
--sync
sync : process(clk,rst)
     begin 
         if(rst = '1') then 
              buffer_reg <= (others =>'0');
         elsif(rising_edge(clk)) then
              if(wr_en = '1') then 
                  buffer_reg <= wr_data(w-1 downto 0);
              end if;
         end if;
     end process sync;

--wr_en assignment 
wr_en <= '1' when (cs = '1' and write ='1') else
         '0' ;
rd_data <= (others => '0');--not used
--output assign
d_out <= buffer_reg;
end Behavioral;
