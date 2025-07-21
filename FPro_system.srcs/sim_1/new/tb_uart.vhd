-- VHDL Testbench for the UART entity
--
-- This testbench performs two simple tests:
-- 1. TX Test: Writes a byte (0x70) to the transmit FIFO and lets the UART send it.
--    You can monitor the 'tx' signal in your waveform viewer to see the serial data.
-- 2. RX Test: Simulates receiving a byte (0x70) on the 'rx' pin. It then reads
--    the byte from the receive FIFO. You can monitor 'r_data' to see the result.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The testbench entity is typically empty
entity uart_tb is
end uart_tb;

architecture behavior of uart_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    -- This should match the entity declaration in your uart.vhd file.
    component uart is
        generic (
            DBIT    : integer := 8;
            SB_TICK : integer := 16;
            FIFO_W  : integer := 4
        );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            rd_uart  : in  std_logic;
            wr_uart  : in  std_logic;
            dvsr     : in  std_logic_vector(10 downto 0);
            rx       : in  std_logic;
            w_data   : in  std_logic_vector(7 downto 0);
            tx_full  : out std_logic;
            rx_empty : out std_logic;
            r_data   : out std_logic_vector(7 downto 0);
            tx       : out std_logic
        );
    end component;

    -- Testbench Constants
    constant CLK_PERIOD : time    := 10 ns; -- System clock period (100 MHz)
    -- Divisor for 9600 baud rate with a 100 MHz clock and 16x oversampling
    -- Formula: (Clock_Frequency / (Baud_Rate * SB_TICK)) = (100e6 / (9600 * 16)) = 651.04
    constant DVSR_VAL   : integer := 53;
    -- The time duration for one bit on the serial line
    constant BIT_PERIOD : time    := CLK_PERIOD * DVSR_VAL * 16;

    -- Testbench Signals to connect to the UUT
    signal clk      : std_logic := '0';
    signal rst      : std_logic;
    signal rd_uart  : std_logic;
    signal wr_uart  : std_logic;
    signal dvsr     : std_logic_vector(10 downto 0);
    signal rx       : std_logic := '1'; -- UART line is idle high
    signal w_data   : std_logic_vector(7 downto 0);
    signal tx_full  : std_logic;
    signal rx_empty : std_logic;
    signal r_data   : std_logic_vector(7 downto 0);
    signal tx       : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : uart
        generic map(
            DBIT    => 8,
            SB_TICK => 16,
            FIFO_W  => 4
        )
        port map (
            clk      => clk,
            rst      => rst,
            rd_uart  => rd_uart,
            wr_uart  => wr_uart,
            dvsr     => dvsr,
            rx       => rx,
            w_data   => w_data,
            tx_full  => tx_full,
            rx_empty => rx_empty,
            r_data   => r_data,
            tx       => tx
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus process to drive the test
    stim_proc : process
    begin
        -- 1. Apply reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        -- 2. Initialize inputs to a known state after reset
        dvsr    <= std_logic_vector(to_unsigned(DVSR_VAL, 11));
        wr_uart <= '0';
        rd_uart <= '0';
        w_data  <= (others => '0');

        wait for 10 * CLK_PERIOD;

        -- ==========================================================
        -- TEST 1: Transmit "01110000" (ASCII 'p')
        -- ==========================================================
        report "Starting TX Test: Writing '01110000' to TX FIFO...";

        -- Place data into the TX FIFO
        w_data  <= "01110000";
        wr_uart <= '1';
        wait for CLK_PERIOD;
        wr_uart <= '0';
        w_data  <= (others => 'Z'); -- Stop driving the data bus

        -- The transmitter should now start sending automatically because the
        -- FIFO is no longer empty. We just need to wait long enough to
        -- observe the full transmission in the waveform.
        -- 1 start bit + 8 data bits + 1 stop bit = 10 bits total.
        wait for 12 * BIT_PERIOD; -- Wait a bit extra to be safe

        report "TX Test Finished. Check the 'tx' signal in the waveform.";
        wait for 10 * CLK_PERIOD;

        -- ==========================================================
        -- TEST 2: Receive "01110000" (ASCII 'p')
        -- ==========================================================
        report "Starting RX Test: Sending '01110000' to RX pin...";

        -- Data to send: "01110000"
        -- UART sends LSB first, so the bits are transmitted in reverse order:
        -- 0, 0, 0, 0, 1, 1, 1, 0

        -- Start Bit (always low)
        rx <= '0';
        wait for BIT_PERIOD;

        -- Data Bits (LSB first)
        rx <= '0'; -- Bit 0
        wait for BIT_PERIOD;
        rx <= '0'; -- Bit 1
        wait for BIT_PERIOD;
        rx <= '0'; -- Bit 2
        wait for BIT_PERIOD;
        rx <= '0'; -- Bit 3
        wait for BIT_PERIOD;
        rx <= '1'; -- Bit 4
        wait for BIT_PERIOD;
        rx <= '1'; -- Bit 5
        wait for BIT_PERIOD;
        rx <= '1'; -- Bit 6
        wait for BIT_PERIOD;
        rx <= '0'; -- Bit 7
        wait for BIT_PERIOD;

        -- Stop Bit (always high)
        rx <= '1';
        wait for BIT_PERIOD;

        report "Finished sending data to RX pin.";

        -- Wait a few clock cycles for the receiver to process the byte
        -- and write it to the RX FIFO.
        wait for 10 * CLK_PERIOD;

        -- Now, read the data from the RX FIFO.
        -- In a real testbench, we would check if rx_empty went low first.
        report "Reading from RX FIFO...";
        rd_uart <= '1';
        wait for CLK_PERIOD;
        rd_uart <= '0';

        -- The received data should now be stable on the 'r_data' output.
        -- You can add an assertion here to automatically check the value.
        -- For example: assert r_data = "01110000" report "RX data mismatch!" severity error;
        wait for 10 * CLK_PERIOD;
        report "RX Test Finished. Check 'r_data' in the waveform.";


        -- Stop the simulation
        report "Simulation finished." severity failure;
        wait;
    end process;

end behavior;
