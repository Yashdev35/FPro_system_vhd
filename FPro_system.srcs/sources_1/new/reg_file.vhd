----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2025 07:44:21 PM
-- Design Name: 
-- Module Name: reg_file_4by8 - arch
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

entity reg_file is
generic(
addr_wid : integer := 2;
data_wid : integer := 8
);
port(
clk, rst : in std_logic;
wr_en : in std_logic;
rd_addr, wr_addr : in std_logic_vector(addr_wid-1 downto 0);
wr_data : in std_logic_vector(data_wid-1 downto 0);
rd_data : out std_logic_vector(data_wid-1 downto 0)
);
end reg_file;


architecture arch of reg_file is
type std_logic_2d is array( 0 to (2**addr_wid)-1) of std_logic_vector(data_wid -1 downto 0);
signal reg_array : std_logic_2d;
begin
write_logic : process(clk, rst)
begin
     if(rst = '1') then 
             for i in 0 to (2**addr_wid)-1 loop
                    reg_array(i) <= (others => '0');
             end loop;
     elsif(rising_edge(clk)) then
             if(wr_en = '1') then
                   reg_array(TO_INTEGER(unsigned(wr_addr))) <= wr_data;
             end if;
     end if;
end process write_logic;

---read logic 
rd_data <= reg_array(TO_INTEGER(unsigned(rd_addr)));
end arch;
