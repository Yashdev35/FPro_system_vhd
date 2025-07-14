----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2025 04:35:24 PM
-- Design Name: 
-- Module Name: fifo_ctrl - arch
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

entity fifo_ctrl is
generic(
ADDR_W : integer := 4
);
port(
clk, rst : in std_logic;
wr, rd : in std_logic;
full, empty : out std_logic;
wr_addr, rd_addr : out std_logic_vector(ADDR_W-1 downto 0)
);
end fifo_ctrl;
architecture arch of fifo_ctrl is
signal op : std_logic_vector(1 downto 0);
signal cur_wr_add, succ_wr_add, next_wr_add : std_logic_vector(ADDR_W-1 downto 0);
signal cur_rd_add, succ_rd_add, next_rd_add : std_logic_vector(ADDR_W-1 downto 0);
signal full_reg, full_next : std_logic;
signal empty_reg, empty_next : std_logic;
begin

--synchronous processes
sync: process(clk, rst)
begin
     if(rst = '1') then 
              cur_wr_add <= (others => '0');
              cur_rd_add <= (others => '0');
              full_reg <= '0';
              empty_reg <= '1';
     elsif(rising_edge(clk)) then 
              cur_wr_add <= next_wr_add;
              cur_rd_add <= next_rd_add;
              full_reg <= full_next;
              empty_reg <= empty_next;
     end if;
end process sync;

--op signal assignment 
op <= wr & rd;

-- successor 
succ_wr_add <= std_logic_vector(unsigned(cur_wr_add) +1);
succ_rd_add <= std_logic_vector(unsigned(cur_rd_add) +1);

-- next values logic
next_logic : process(op, cur_rd_add, cur_wr_add, succ_rd_add, succ_wr_add, full_reg, empty_reg)
begin 
next_wr_add <= cur_wr_add;
next_rd_add <= cur_rd_add;
full_next <= full_reg;
empty_next <= empty_reg;

case op is 
      when "00" => null;
      when "01" =>
            if(empty_reg /= '1') then 
                 next_rd_add <= succ_rd_add;
                 full_next <= '0';
                 if(succ_rd_add = cur_wr_add) then
                       empty_next <= '1';
                 end if;
            end if;
      when "10" =>
            if(full_reg /= '1') then
                 next_wr_add <= succ_wr_add;
                 empty_next <= '0';
                 if(succ_wr_add = cur_rd_add) then
                       full_next <= '1'; 
                 end if;
            end if;
      when "11" =>
            next_wr_add <= succ_wr_add;
            next_rd_add <= succ_rd_add;
      when others => null;
      end case;
end process next_logic;

-- output assignment 
wr_addr <= cur_wr_add;
rd_addr <= cur_rd_add;
full <= full_reg;
empty <= empty_reg;
end arch;