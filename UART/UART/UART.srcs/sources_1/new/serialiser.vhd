library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith;

entity serialiser is
  generic (
    g_DATA_WIDTH : natural := 9; 
    g_CNT_WIDTH  : natural := 4 
  );
  
  port (
    -- global
    clk            : in  std_logic;
    -- counter part
    rst            : in  std_logic;
    en             : in  std_logic;
    -- main part
    data           : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    data_pointer   : out std_logic_vector(g_CNT_WIDTH - 1 downto 0);
    serialised_bit : out std_logic;
    data_bit_num   : in std_logic_vector(3 downto 0);
    stop_bit       : in std_logic;
    parity_bit     : in std_logic;
    parity_odd     : in std_logic
  );
end serialiser;

architecture Behavioral of serialiser is
    -- internal count signal
    signal sig_cnt : std_logic_vector(g_CNT_WIDTH - 1 downto 0);
begin
    uut_cnt : entity work.cnt_up_down
    generic map (
      g_CNT_WIDTH => g_CNT_WIDTH
    )
    port map (
      clk    => clk,
      rst    => rst,
      en     => en,
      cnt_up => '1',
      cnt    => sig_cnt
    );

  p_serialise : process (clk) is
  begin
    -- when enabled, outputs serialised data
    if (en = '1') then
        serialised_bit <= data(to_integer(unsigned(sig_cnt)));
        data_pointer   <= sig_cnt;
    -- when disabled, reset pointer, outputs HIGH - idle
    else 
        serialised_bit <= '1';
        data_pointer  <= (others => '0');
    end if;
  end process p_serialise;
  
 
end Behavioral;
