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
  signal SW           : std_logic_vector (15 downto 0)                := "0111001010001000";
  -- data in/out display
  signal LED          : std_logic_vector (15 downto 0)                := (others => '0');
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
    sw <= "0111001010001000";
    wait for 500 ns;
    -- switch to receiving
    sw <= "0111001010001001";
    wait for 500 ns;
    -- switch back to transmitting
    sw <= "0111001010001000";

  end process p_sw_gen;
  
  --------------------------------------------------------
  -- input data generation process
  --------------------------------------------------------
  p_stimulus : process is
  begin

    report "Stimulus process started";
    loop
        -- pull high - idle state
        J_IN  <= '1';
        wait for 10ns;
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
        J_IN  <= '1';
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
