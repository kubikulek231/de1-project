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
           J_OUT     : out std_logic;
           -- segmented display out
           CA        : out std_logic;
           CB        : out std_logic;
           CC        : out std_logic;
           CD        : out std_logic;
           CE        : out std_logic;
           CF        : out std_logic;
           CG        : out std_logic;
           AN        : out std_logic_vector (7 downto 0)
           );
end top;

----------------------------------------------------------
-- Architecture body for top level
----------------------------------------------------------

architecture behavioral of top is

  -- variable clock signal
  signal sig_clk       : std_logic;
  -- enable signals   
  signal sig_tx_en     : std_logic;
  signal sig_rx_en     : std_logic;
  -- reset signals
  signal sig_tx_rs     : std_logic;
  signal sig_rx_rs     : std_logic;
  -- data frame length signal
  signal sig_dframe_l  : unsigned(3 downto 0);
  -- clock enable g_max variable 
  shared variable var_baudrate  : natural := 9600;    
  
  -- display input hex signal   
  signal sig_hex       : std_logic_vector(3 downto 0) := "0000";
  -- display output seg signal
  signal sig_seg       : std_logic_vector(6 downto 0) := "1111111";

  -- used for extracting first digit of number
  function extract_digit(num : natural; digit : natural) return natural is
    variable target_digit : natural range 0 to 9;
  begin
    -- check whether specified digit is within range
    assert digit < integer(log10(real(num))) + 1
      report "specified digit is out of range" severity failure;
    -- extract the specified digit
    target_digit := (num / 10**(digit-1)) mod 10;
    return target_digit;
  end function;

begin


  --------------------------------------------------------
  -- Instance of clock_enable entity
  --------------------------------------------------------
  clk_en : entity work.clock_enable
      generic map(
          -- calculate number of ticks needed for given baudrate
          g_MAX => 100000000 / var_baudrate
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
      
  --------------------------------------------------------
  -- Instance of hex_7seg entity
  --------------------------------------------------------
      
  hex_7seg : entity work.hex_7seg
  port map(
      blank    => '0',
      hex      => sig_hex,
      seg(6)   => CA,
      seg(5)   => CB,
      seg(4)   => CC,
      seg(3)   => CD,
      seg(2)   => CE,
      seg(1)   => CF,
      seg(0)   => CG
  );
  
  p_display_driver : process (CLK100MHZ)
    variable i : integer := 0;
  begin
    if rising_edge(CLK100MHZ) then
      i := i + 1;
        case i is
              -- display TX / RX mode
              when 1 =>
                an  <= "01111111";
                if SW(0) = '0' then
                  sig_hex <= "1010"; -- Tx
                else
                  sig_hex <= "1011"; -- Rx
                end if;
              -- display data frame length
              when 2 =>
                an  <= "10111111";
                sig_hex <= std_logic_vector(sig_dframe_l);
              -- display parity N/O/E
              when 3 =>
                an  <= "11011111";
                if SW (3) = '1' then
                  if SW (2) = '1' then
                    sig_hex <= "1101"; -- Odd
                  else 
                    sig_hex <= "1110"; -- Even
                  end if;
                else
                  sig_hex <= "1100"; -- No
                end if;
              -- display stop bit/s
              when 4 =>
                an  <= "11101111";
                if SW (1) = '1' then
                    sig_hex <= "0001"; -- 1
                  else 
                    sig_hex <= "0010"; -- 2
                end if;
              -- display first 4 numbers from baudrate
              when 5 =>
                an  <= "11110111";
                sig_hex <= std_logic_vector(to_unsigned(extract_digit(var_baudrate, 1), 4));
              when 6 =>
                an  <= "11111011";
                sig_hex <= std_logic_vector(to_unsigned(extract_digit(var_baudrate, 2), 4));
              when 7 =>
                an  <= "11111101";
                sig_hex <= std_logic_vector(to_unsigned(extract_digit(var_baudrate, 3), 4));
              when 8 =>
                an  <= "11111110";
                sig_hex <= std_logic_vector(to_unsigned(extract_digit(var_baudrate, 4), 4));
                i := 0;
              when others =>
              -- do nothing
       end case;
    end if;
  end process p_display_driver;
  
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