----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2025 02:58:25 PM
-- Design Name: 
-- Module Name: timer_core - Behavioral
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
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--entity declaration 
entity timer_core is
generic(w :integer := 8);
port(
clk,rst : in std_logic;
--wrapping ckt
cs,read,write : in std_logic;
addr : in std_logic_vector(4 downto 0);
wr_data : in std_logic_vector(31 downto 0);
rd_data : out std_logic_vector(31 downto 0)
);
end timer_core;

--architecture 
architecture main of timer_core is
signal go,wr_en,clear : std_logic;
signal count,next_count : unsigned(47 downto 0);
signal ctrl : std_logic;
begin

--sync
sync : process(rst,clk)
     begin 
         if(rst = '1') then
            count <= (others =>'0');
         elsif(rising_edge(clk)) then 
            count <= next_count;
         end if;
end process sync;

--next state logic
next_count <= (others => '0') when (clear ='1') else
              next_count+1 when (go = '1') else
              next_count;
              
-- ctrl reg
ctrl_assign : process(clk, rst)
    begin 
        if(rst = '1') then
             ctrl <= '0';
        elsif(rising_edge(clk)) then
             if(wr_en = '1') then  
             ctrl <= wr_data(0);
             end if;
        end if;
end process ctrl_assign;

--wrapping ckt
wr_en <= '1' when ( cs = '1' and write = '1' and addr(1 downto 0) = "10") else '0';
clear <= '1' when (wr_data(1) = '1' and wr_en = '1') else '0';
go <= ctrl;

--output 
rd_data <= std_logic_vector(count(31 downto 0)) when (addr(0) = '0') else
           x"0000" & std_logic_vector(count(47 downto 32));
end main;
