----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2023 02:24:21 PM
-- Design Name: 
-- Module Name: tb_serialiser - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_serialiser is
--  Port ( );
end tb_serialiser;

architecture Behavioral of tb_serialiser is
    constant c_DATA_WIDTH         : natural := 8;
    constant c_CNT_WIDTH         : natural := 3;
    constant c_CLK_100MHZ_PERIOD : time    := 10 ns;
    signal sig_clk_100mhz : std_logic;
    signal cnt : std_logic_vector (2 downto 0);
    signal data        : std_logic_vector (7 downto 0);
    signal serialised_bit         : std_logic;
  signal sig_rst        : std_logic;
  signal sig_en         : std_logic;
  signal sig_cnt_up     : std_logic;
  signal sig_cnt        : std_logic_vector(c_CNT_WIDTH - 1 downto 0) := (others => '0');
begin
  uut_serialiser : entity work.serialiser
    generic map (
      g_CNT_WIDTH => c_CNT_WIDTH,
      g_DATA_WIDTH => c_DATA_WIDTH
    )
    port map (
      serialised_bit     => serialised_bit,
      data => data,
      cnt    => cnt
    );
    uut_cnt : entity work.cnt_up_down
    generic map (
      g_CNT_WIDTH => c_CNT_WIDTH
    )
    port map (
      clk    => sig_clk_100mhz,
      rst    => sig_rst,
      en     => sig_en,
      cnt_up => sig_cnt_up,
      cnt    => sig_cnt
    );
  --------------------------------------------------------
  -- Clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 800 ns loop             -- 75 periods of 100MHz clock

      sig_clk_100mhz <= '0';
      wait for c_CLK_100MHZ_PERIOD / 2;
      sig_clk_100mhz <= '1';
      wait for c_CLK_100MHZ_PERIOD / 2;

    end loop;
    wait;                               -- Process is suspended forever

  end process p_clk_gen;
    --------------------------------------------------------
  -- Reset generation process
  --------------------------------------------------------
    p_reset_gen : process is
  begin

    sig_rst <= '0';

    wait;

  end process p_reset_gen;
  --------------------------------------------------------
  -- enable generation process
  --------------------------------------------------------
  p_en_gen : process is
  begin

    -- Enable counting
    sig_en <= '1';
    wait;

  end process p_en_gen;
    --------------------------------------------------------
  -- direction generation process
  --------------------------------------------------------
  p_cnt_up : process is
  begin

    -- Change counter direction
    sig_cnt_up <= '1';
    wait;

  end process p_cnt_up;
  
    --------------------------------------------------------
  -- Data generation process
  --------------------------------------------------------
  p_stimulus : process is
  begin

    report "Stimulus process started";

    report "Stimulus process finished";
    wait;

  end process p_stimulus;
end Behavioral;
