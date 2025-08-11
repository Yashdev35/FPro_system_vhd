-- VHDL Testbench for mmio_sys_vanilla
-- This testbench performs a simple write to the LED register and a read from the switch register.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The testbench entity is typically empty
entity tb_mmio_sys_vanilla is
end tb_mmio_sys_vanilla;

architecture behavior of tb_mmio_sys_vanilla is

    -- Component Declaration for the Device Under Test (DUT)
    component mmio_sys_vanilla is
        port(
            clk, rst      : in std_logic;
            -- FPRO bus
            mmio_cs       : in std_logic;
            mmio_wr       : in std_logic;
            mmio_rd       : in std_logic;
            mmio_addr     : in std_logic_vector(20 downto 0);
            mmio_wr_data  : in std_logic_vector(31 downto 0);
            mmio_rd_data  : out std_logic_vector(31 downto 0);
            -- led and switch
            sw            : in std_logic_vector(15 downto 0);
            led           : out std_logic_vector(15 downto 0);
            -- uart  
            rx            : in std_logic;
            tx            : out std_logic
        );
    end component;

    -- Constants
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

    -- Signals to connect to the DUT
    signal clk          : std_logic := '0';
    signal rst          : std_logic;
    signal mmio_cs      : std_logic;
    signal mmio_wr      : std_logic;
    signal mmio_rd      : std_logic;
    signal mmio_addr    : std_logic_vector(20 downto 0);
    signal mmio_wr_data : std_logic_vector(31 downto 0);
    signal mmio_rd_data : std_logic_vector(31 downto 0);
    signal sw           : std_logic_vector(15 downto 0);
    signal led          : std_logic_vector(15 downto 0);
    signal rx           : std_logic;
    signal tx           : std_logic;

begin

    -- Instantiate the Device Under Test (DUT)
    dut_inst : mmio_sys_vanilla
        port map(
            clk          => clk,
            rst          => rst,
            mmio_cs      => mmio_cs,
            mmio_wr      => mmio_wr,
            mmio_rd      => mmio_rd,
            mmio_addr    => mmio_addr,
            mmio_wr_data => mmio_wr_data,
            mmio_rd_data => mmio_rd_data,
            sw           => sw,
            led          => led,
            rx           => rx,
            tx           => tx
        );

    -- Clock process definition
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- 1. Initialize all inputs to a known state
        report "Starting Simulation...";
        rst          <= '1'; -- Assert reset
        mmio_cs      <= '0';
        mmio_wr      <= '0';
        mmio_rd      <= '0';
        mmio_addr    <= (others => '0');
        mmio_wr_data <= (others => '0');
        sw           <= x"5555"; -- Set switches to a test value
        rx           <= '1';     -- UART idle state

        -- 2. Wait for a few clock cycles while in reset
        wait for CLK_PERIOD * 5;
        rst <= '0'; -- De-assert reset
        wait for CLK_PERIOD;

        -- 3. Perform an MMIO write to the LED register
        -- Assuming the LED register is at address 0x00000
        report "Performing MMIO write to LED register...";
        mmio_cs      <= '1';
        mmio_wr      <= '1';
        mmio_addr    <= x"00000"&'0';
        mmio_wr_data <= x"0000AAAA"; -- Data to write to LEDs
        wait for CLK_PERIOD;
        
        -- De-assert control signals after one cycle
        mmio_cs <= '0';
        mmio_wr <= '0';
        mmio_wr_data <= (others => '0');
        report "MMIO write complete. Check 'led' output in waveform.";
        
        wait for CLK_PERIOD * 10; -- Wait a bit

        -- 4. Perform an MMIO read from the Switch register
        -- Assuming the Switch register is at address 0x00004
        report "Performing MMIO read from Switch register...";
        mmio_cs   <= '1';
        mmio_rd   <= '1';
        mmio_addr <= x"00004"&'0';
        wait for CLK_PERIOD;

        -- De-assert control signals
        mmio_cs <= '0';
        mmio_rd <= '0';
        
        -- The read data will be valid on the bus on the next clock edge.
        -- We wait one more cycle to allow it to propagate to the mmio_rd_data signal.
        wait for CLK_PERIOD;
        report "MMIO read complete. Check 'mmio_rd_data' in waveform. It should be 0x00005555.";
        
        wait for CLK_PERIOD * 10;

        -- 5. End the simulation
        report "Simulation finished." severity failure;
        
    end process;

end behavior;
