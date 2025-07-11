----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2025 08:03:49 PM
-- Design Name: 
-- Module Name: chu_io_map - Behavioral
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

package chu_io_map is 

--2D data types 
type std_2d_data_type is array (63 downto 0) of
         std_logic_vector(31 downto 0);-- for giving wr_data and rd_data to 64 slots
type std_2d_reg_type is array(63 downto 0) of
         std_logic_vector(4 downto 0);--for giving addr 5bit to all the 64 slots

--base address of io bridge for xilinx mcs 
constant BRIDGE_BASE : std_logic_vector(31 downto 0) := X"c7000000";

--slot defination of mmio subsystem 
constant S0_TIMER : integer := 0;
constant S1_UART : integer := 1;
constant S2_LED : integer := 2;
constant S3_SW : integer := 3;
constant S4_CUSTOM : integer := 4;

end chu_io_map;
