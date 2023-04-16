library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith;

entity top is
    Port ( CLK100MHZ : in STD_LOGIC;
           SW        : in std_logic_vector (15 downto 0);
           LED       : out std_logic_vector (15 downto 0);
           BTNC      : in std_logic;
           J_IN      : in std_logic;
           J_OUT     : out std_logic
           );
end top;

----------------------------------------------------------
-- Architecture body for top level
----------------------------------------------------------

architecture behavioral of top is

  signal   sig_clk      : std_logic;   
  signal   sig_tx_en    : std_logic;
  signal   sig_rx_en    : std_logic;
  constant c_9600_baud  : natural := 10416;            

begin

  --------------------------------------------------------
  -- Instance of clock_enable entity
  --------------------------------------------------------
  clk_en : entity work.clock_enable
      generic map(
          g_MAX => c_9600_baud
      )
      port map(
          clk => CLK100MHZ,
          rst => '0',
          ce  => sig_clk
      );

  --------------------------------------------------------
  -- Instance of transmitter entity
  --------------------------------------------------------
  transmitter : entity work.transmitter
     generic map(
          g_CNT_WIDTH => 4,
          g_DATA_WIDTH => 9
      )
      port map(
            -- in
            en             => sig_tx_en,
            clk            => CLK100MHZ,
            rst            => BTNC,
            data_frame_len => unsigned (SW (6 downto 4)),
            parity_bit     => SW (3),
            parity_odd     => SW (2),
            stop_one_bit   => SW (1),
            
            -- data in
            data_frame     => SW (15 downto 7),
            -- serial out
            serialised_bit => J_OUT
      );
  --------------------------------------------------------
  -- Instance of receiver entity
  --------------------------------------------------------
  receiver : entity work.receiver
     generic map(
          g_CNT_WIDTH => 4,
          g_DATA_WIDTH => 9
      )
      port map(
            -- in
            en             => sig_rx_en,
            clk            => CLK100MHZ,
            rst            => BTNC,
            data_frame_len => unsigned (SW (6 downto 4)),
            parity_bit     => SW (3),
            parity_odd     => SW (2),
            stop_one_bit   => SW (1),
            
            -- data out
            data_frame     => LED (15 downto 7),
            -- serial in
            data_bit       => J_IN
      );
      
  p_mode_switch : process (CLK100MHZ) is
  begin
      if (rising_edge(CLK100MHZ)) then
          sig_rx_en <= SW(0);
          sig_tx_en <= not SW(0);
      end if;
  end process p_mode_switch;
  
end architecture behavioral;