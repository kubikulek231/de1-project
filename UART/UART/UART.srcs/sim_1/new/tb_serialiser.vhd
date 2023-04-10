library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_serialiser is
--  Port ( );
end tb_serialiser;

architecture Behavioral of tb_serialiser is
  constant c_DATA_WIDTH        : natural := 8;
  constant c_CNT_WIDTH         : natural := 3;
  constant c_CLK_100MHZ_PERIOD : time    := 10 ns;
  
  -- outputs
  signal serialised_bit        : std_logic;
  -- inputs
  signal sig_clk_100mhz        : std_logic                                     := '0';
  signal sig_data              : std_logic_vector (c_DATA_WIDTH - 1 downto 0)  := "01101100";
  signal sig_rst               : std_logic                                     := '0';
  signal sig_en                : std_logic                                     := '1';
  signal sig_cnt_up            : std_logic                                     := '1';
  signal sig_data_pointer      : std_logic_vector(c_CNT_WIDTH - 1 downto 0);
  
begin

  uut_serialiser : entity work.serialiser
    generic map (
      g_CNT_WIDTH  => c_CNT_WIDTH,
      g_DATA_WIDTH => c_DATA_WIDTH
    )
    port map (
      clk                => sig_clk_100mhz,
      serialised_bit     => serialised_bit,
      data               => sig_data,
      data_pointer       => sig_data_pointer,
      rst                => sig_rst,
      en                 => sig_en
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
    wait;                                  -- Process is suspended forever

  end process p_clk_gen;
  
    --------------------------------------------------------
  -- Reset generation process
  --------------------------------------------------------
    p_reset_gen : process is
  begin

    sig_rst <= '1';
    wait for 10ns;
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
    wait for 500 ns;
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
