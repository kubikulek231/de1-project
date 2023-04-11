library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( CLK100MHZ : in STD_LOGIC;
           SW        : in std_logic_vector (15 downto 0);
           LED       : out std_logic
           );
end top;

----------------------------------------------------------
-- Architecture body for top level
----------------------------------------------------------

architecture behavioral of top is

  signal sig_clk_9600   : std_logic;   
  constant start_seq    : std_logic_vector := "1";
  constant end_seq      : std_logic_vector := "1";                 

begin

  --------------------------------------------------------
  -- Instance (copy) of clock_enable entity
  --------------------------------------------------------
  clk_en0 : entity work.clock_enable
      generic map(
          g_MAX => 10416
      )
      port map(
          clk => CLK100MHZ,
          rst => '0',
          ce  => sig_clk_9600
      );

  --------------------------------------------------------
  -- Instance (copy) of cnt_up_down entity
  --------------------------------------------------------
  bin_cnt0 : entity work.serialiser
     generic map(
          g_CNT_WIDTH => 3,
          g_DATA_WIDTH => 8
      )
      port map(
              en     => '1',
              clk    => sig_clk_9600,
              rst    => '0',
              data   => SW (15 downto 8),
              serialised_bit    => LED
      );

  --------------------------------------------------------
  -- Other settings
  --------------------------------------------------------
  -- Connect one common anode to 3.3V

end architecture behavioral;