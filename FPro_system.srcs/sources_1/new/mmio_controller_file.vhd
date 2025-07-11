----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2025 10:35:39 PM
-- Design Name: 
-- Module Name: mmio_controller_file - Behavioral
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
use work.chu_io_map.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mmio_controller is
port(
--Bus 
bus_addr : in std_logic_vector(23 downto 0);
bus_read :in std_logic;
bus_write : in std_logic;
bus_cs : in std_logic;
bus_wr_data :in std_logic_vector(31 downto 0);
bus_rd_data : out std_logic_vector(31 downto 0);
--Slot interface 
slot_cs_array : out std_logic_vector(63 downto 0);
slot_write_array : out std_logic_vector(63 downto 0);
slot_read_array : out std_logic_vector(63 downto 0);
slot_addr_array : out std_2d_reg_type;
slot_wr_data_array : out std_2d_data_type;
slot_rd_data_array: in std_2d_data_type
);
end mmio_controller;
architecture main of mmio_controller is
alias slot_addr : std_logic_vector(5 downto 0) is bus_addr(10 downto 5);
alias reg_addr : std_logic_vector(4 downto 0) is bus_addr(4 downto 0);
begin

-- decoding, slot addr and enabling target slots cs demux
decode_slot_addr: process(slot_addr,bus_cs) 
  begin 
  slot_cs_array <= (others =>'0');
  if(bus_cs = '1') then
          slot_cs_array(TO_INTEGER(unsigned(slot_addr))) <= '1';
  end if;
end process decode_slot_addr;

--other signal are directly just scaled and only cs controls who gets to write
slot_read_array <= (others => bus_read);
slot_write_array <= (others => bus_write);
slot_addr_array <= (others => reg_addr);
slot_wr_data_array <= (others => bus_wr_data);

--decoding the slots for read data (64 to 1 mux)
bus_rd_data <= slot_rd_data_array(TO_INTEGER(unsigned(slot_addr)));

end main;
