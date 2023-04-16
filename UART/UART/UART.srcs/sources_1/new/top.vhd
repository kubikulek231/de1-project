library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith;

entity top is
    Port ( 
           -- clock signal
           CLK100MHZ : in STD_LOGIC;
           -- settings/data in
           SW        : in std_logic_vector (15 downto 0);
           -- data in/out display
           LED       : out std_logic_vector (15 downto 0);
           -- reset
           BTNC      : in std_logic;
           -- serial in
           J_IN      : in std_logic;
           -- serial out
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
  signal   sig_tx_rs    : std_logic;
  signal   sig_rx_rs    : std_logic;
  signal   sig_dframe_l : unsigned(3 downto 0);
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
            rst            => sig_tx_rs,
            data_frame_len => sig_dframe_l,
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
            rst            => sig_rx_rs,
            data_frame_len => sig_dframe_l,
            parity_bit     => SW (3),
            parity_odd     => SW (2),
            stop_one_bit   => SW (1),
            
            -- data out
            data_frame     => LED (15 downto 7),
            -- serial in
            data_bit       => J_IN
      );
      
  p_set : process (CLK100MHZ) is
  begin
      if (rising_edge(CLK100MHZ)) then
          if (BTNC = '1') then
            sig_tx_rs <= '1';
            sig_rx_rs <= '1';
          else
            sig_tx_rs <= '0';
            sig_rx_rs <= '0';
          end if;
          sig_rx_en <= SW(0);
          sig_tx_en <= not SW(0);
          sig_rx_rs <= not SW(0);
          sig_tx_rs <= SW(0);
          -- set unused LEDs to 0 so they don't float
          LED(6 downto 0) <= SW(6 downto 0);
      end if;
  end process p_set;
  
  p_set_dframe_len : process (CLK100MHZ) is
  begin
      if (rising_edge(CLK100MHZ)) then
          if (SW (6 downto 4) > "100") then
            sig_dframe_l <= "1001";
          end if;
          if (SW (6 downto 4) <= "100") then
            sig_dframe_l <= "0101" + unsigned(SW (6 downto 4));
          end if;
      end if;
  end process p_set_dframe_len;
  
end architecture behavioral;