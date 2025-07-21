----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/18/2025 04:32:53 PM
-- Design Name: 
-- Module Name: uart_rx - arch
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

entity uart_rx is
port(
clk, rst : in std_logic;
tick : in std_logic;
rx : in std_logic;
dout : out std_logic_vector(7 downto 0);
rx_done : out std_logic
);
end uart_rx;
architecture arch of uart_rx is
type states is (idle, start, data, stop);
signal cur_st, next_st : states;
signal sz_cnt, next_sz : unsigned(3 downto 0);
signal sm_cnt, next_sm : unsigned(3 downto 0);
signal d_reg, next_d_reg : std_logic_vector(7 downto 0);
signal sync1_reg, sync2_reg : std_logic;
signal sync_reg : std_logic;
signal sz7, sm7, sm15 : std_logic;
begin


--sync process to handle asynchronous rx 
sync_rx : process(clk, rst)
begin
    if(rst = '1') then 
           sync1_reg <= '0';
           sync2_reg <= '0';
    elsif(rising_edge(clk)) then 
           sync1_reg <= rx;
           sync2_reg <= sync1_reg;
    end if ;
end process sync_rx;

--rx value is synchronized using 2 ffs 
sync_reg <= sync2_reg;

--state registers 
state_reg : process(clk, rst, next_st)
begin
       if(rst = '1' ) then 
              cur_st <= idle;
              sz_cnt <= (others => '0');
              sm_cnt <= (others => '0');
              d_reg <= (others => '0');
       elsif(rising_edge(clk)) then 
              cur_st <= next_st;
              sz_cnt <= next_sz;
              sm_cnt <= next_sm;
              d_reg <= next_d_reg;
       end if;
end process state_reg;

--next_state logic and data path 
nsl_n_dp : process(sync_reg , cur_st, sz_cnt, sm_cnt, d_reg,tick)
begin 
next_st <= cur_st;
next_sz <= sz_cnt;
next_sm <= sm_cnt;
next_d_reg <= d_reg;
rx_done <= '0';

case cur_st is 
          when idle =>
               if(sync_reg = '0') then 
                       next_st <= start;
                       next_sz <= (others => '0');
                       next_sm <= (others => '0');
               end if;
          when start =>
               if(tick = '1') then 
                       if(sm7 = '1') then 
                             next_st <= data;
                             next_sm <= (others => '0');
                             next_sz <= (others => '0');
                       else
                             next_sm <= sm_cnt + 1;
                       end if;
               end if;
          when data =>
               if(tick = '1') then 
                       if(sm15 = '1') then 
                             next_d_reg <= sync_reg & d_reg(7 downto 1);
                             next_sm <= (others => '0');
                             if(sz7 = '1') then 
                                     next_st <= stop;
                                     next_sz <= (others => '0');
                             else
                                     next_sz <= sz_cnt +1;
                             end if;
                       else 
                             next_sm <= sm_cnt +1;
                       end if;
               end if;
         when stop => 
               if(tick = '1' ) then 
                      if(sm15 = '1') then 
                             rx_done <= '1';
                             next_st <= idle;
                      else 
                             next_sm <= sm_cnt +1;
                      end if;
               end if;
         end case;
end process nsl_n_dp;

--size and sample cnt logic
sm7 <= '1' when (sm_cnt(3) = '0' and sm_cnt(2 downto 0) = "111")else '0';
sm15 <= '1' when ( sm_cnt = "1111") else '0';
sz7 <= '1' when (sz_cnt(3) = '0' and sz_cnt(2 downto 0) = "111")else '0';

--output assign
dout <= d_reg;

end arch; 