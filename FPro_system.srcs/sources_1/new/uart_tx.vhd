----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2025 11:21:44 AM
-- Design Name: 
-- Module Name: uart_tx - arch
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

entity uart_tx is
port(
clk, rst : in std_logic;
tick : in std_logic;
din : in std_logic_vector(7 downto 0);
tx_start : in std_logic;
tx : out std_logic;
tx_done : out std_logic
);
end uart_tx;
architecture arch of uart_tx is
type states is (idle, start, data, stop);
signal cur_st, next_st : states;
signal d_reg, next_d_reg : std_logic_vector(7 downto 0);
signal cnt_sm, next_sm : unsigned(3 downto 0);
signal cnt_sz, next_sz : unsigned(3 downto 0);
signal out_tx, next_tx : std_logic;
signal sm7, sm15, sz7 :std_logic;
begin

--state reg 
state_reg: process(clk, rst)
begin 
    if(rst = '1') then 
        cur_st <= idle;
        d_reg <= (others => '0');
        cnt_sm <= (others => '0');
        cnt_sz <= (others => '0');
        out_tx <= '1';
    elsif(rising_edge(clk)) then
        cur_st <= next_st;
        d_reg <= next_d_reg;
        cnt_sm <= next_sm;
        cnt_sz <= next_sz;
        out_tx <= next_tx;
    end if;
end process state_reg;

--next state logic and data path
nsl_n_dp: process(cur_st, tick, din, tx_start, cnt_sm, cnt_sz, d_reg, out_tx)
begin 
next_st <= cur_st;
next_d_reg <= d_reg;
next_sm <= cnt_sm;
next_sz <= cnt_sz;
tx_done <= '0';

case cur_st is 
    when idle =>
        next_tx <= '1';
        if(tx_start = '1') then
            next_st <= start;
            next_sm <= (others => '0');
            next_d_reg <= din;
        end if;
    when start =>
        next_tx <= '0';
        if(tick = '1') then 
            if(sm15 = '1') then 
                next_st <= data;
                next_sm <= (others => '0');
                next_sz <= (others => '0');
            else 
                next_sm <= cnt_sm + 1;
            end if;
        end if;
    when data =>
            next_tx <= d_reg(0);
            if(tick = '1') then 
                if(sm15 = '1') then
                    next_d_reg <= '0'&d_reg(7 downto 1);
                    next_sm <= (others =>'0');
                    if(sz7 = '1') then
                        next_st <= stop;
                        next_sz <= (others => '0');
                    else 
                        next_sz <= cnt_sz +1;
                    end if;
                else
                    next_sm <= cnt_sm + 1;
                end if;
            end if;
    when stop =>
            next_tx <= '1';
            if(tick = '1') then
                if(sm15 = '1') then
                    tx_done <= '1';
                    next_st <= idle;
                else 
                    next_sm <= cnt_sm +1;
                end if;
            end if;
    end case;
end process nsl_n_dp;

--signals 
sm7 <= '1' when ( cnt_sm = "0111") else '0';
sm15 <= '1' when (cnt_sm = "1111") else '0';
sz7 <= '1' when ( cnt_sz = "0111") else '0';

-- output assignement 
tx <= out_tx;

end arch;