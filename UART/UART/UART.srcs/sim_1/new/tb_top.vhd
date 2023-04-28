library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith;

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is
  constant c_CLK100MHZ_PERIOD : time    := 10 ns;
  
  -- clock signal
  signal CLK100MHZ    : std_logic                                     := '0';
  -- settings/data in                                                  -- dddddddddnnnppsm
  signal SW           : std_logic_vector (15 downto 0)                := "1111111110001100";
  -- data in/out display
  signal LED          : std_logic_vector (15 downto 0)                := (others => '0');
  -- 7 segmented display segments
  signal SEG          : std_logic_vector (6 downto 0)                 := "1111111";
  -- 7 segmented display anodes
  signal AN           : std_logic_vector (7 downto 0)                 := "11111111";
  -- reset
  signal BTNC         : std_logic                                     := '0';
  -- serial in
  signal J_IN         : std_logic                                     := '1';
  -- serial out
  signal J_OUT        : std_logic                                     := '1';
  
  
begin

  uut_top : entity work.top
    port map (
      CLK100MHZ          => CLK100MHZ,
      SW                 => SW,
      LED                => LED,
      BTNC               => BTNC,
      CA                 => SEG(0),
      CB                 => SEG(1),
      CC                 => SEG(2),
      CD                 => SEG(3),
      CE                 => SEG(4),
      CF                 => SEG(5),
      CG                 => SEG(6),
      AN                 => AN,
      BTNU               => '0',
      BTND               => '0',
      BTNL               => '0',
      BTNR               => '0',
      J_IN               => J_IN,
      J_OUT              => J_OUT
    );
    
  --------------------------------------------------------
  -- clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 1600 ns loop            

      CLK100MHZ <= '0';
      wait for c_CLK100MHZ_PERIOD / 2;
      CLK100MHZ <= '1';
      wait for c_CLK100MHZ_PERIOD / 2;

    end loop;
    wait;                                  -- Process is suspended forever

  end process p_clk_gen;
  
  --------------------------------------------------------
  -- sw generation process
  --------------------------------------------------------
  p_sw_gen : process is
  begin
    
    -- start out transmitting
    sw <= "0000001110001100";
    wait for 500 ns;
    -- switch to receiving
    sw <= "0001001110001101";
    wait for 1000 ns;

  end process p_sw_gen;
  
  --------------------------------------------------------
  -- Reset generation process
  --------------------------------------------------------
  p_reset_gen : process is
  begin
    loop
        BTNC <= '0';
        wait for 200ns;
        BTNC <= '1';
        wait for 40ns;
        BTNC <= '0';
        wait for 280ns;
    end loop;

  end process p_reset_gen;
  
  --------------------------------------------------------
  -- input data generation process
  --------------------------------------------------------
  p_stimulus : process is
  begin

    report "Stimulus process started";
    loop
        -- idle to sync
        J_IN  <= '1';
        wait for 100ns;
        -- send valid UART frame
        -- pull low - start bit
        J_IN  <= '0';
        wait for 10ns;
        -- transmitted data frame (5 bits)
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '0';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '0';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
        -- parity bit (odd)
        J_IN  <= '0';
        wait for 10ns;
        -- stop bit (two)
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
        -- idle to sync
        J_IN  <= '1';
        wait for 150ns;
        -- send invalid UART frame
        -- pull low - start bit
        J_IN  <= '0';
        wait for 10ns;
        -- transmitted data frame (5 bits)
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '0';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
        -- parity bit (odd)
        J_IN  <= '0';
        wait for 10ns;
        -- stop bit (two)
        J_IN  <= '1';
        wait for 10ns;
        J_IN  <= '1';
        wait for 10ns;
    end loop;
    report "Stimulus process finished";
    wait;

  end process p_stimulus;
end Behavioral;
