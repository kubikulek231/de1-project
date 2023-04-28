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
           LED       : out std_logic_vector (15 downto 0) := (others => '0');
           -- reset
           BTNC      : in std_logic;
           BTNU      : in std_logic;
           BTND      : in std_logic;
           BTNL      : in std_logic;
           BTNR      : in std_logic;
           -- serial in
           J_IN      : in std_logic; -- JA
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
  -- dataframe signal
  signal sig_data_frame  : std_logic_vector (15 downto 7);
  -- variable clock signal
  signal sig_clk         : std_logic;
  -- enable signals   
  signal sig_tx_en       : std_logic;
  signal sig_rx_en       : std_logic;
  -- reset signals
  signal sig_tx_rs       : std_logic;
  signal sig_rx_rs       : std_logic;
  -- data frame length signal
  signal sig_dframe_l    : unsigned(3 downto 0);
  -- clock enable g_max variable 
  signal sig_baudrate    : natural := 9600;    
  signal sig_baudrate_cycles  : natural := 10416;    
  -- display input hex signal   
  signal sig_hex         : std_logic_vector(3 downto 0) := "0000";
  -- display output seg signal
  signal sig_seg         : std_logic_vector(6 downto 0) := "1111111";
  -- received data verification signals
  signal sig_is_data_ok  : boolean := false;
  signal sig_is_received : boolean := false;

  -- used for extracting digit of the number
  function extract_digit(num : natural; digit : natural) return natural is
    variable target_digit : natural range 0 to 9;
  begin
    -- extract the specified digit
    target_digit := (num / 10**(digit-1)) mod 10;
    return target_digit;
  end function;

  -- used to tell how many digits in number
  function count_digits(num : natural) return natural is
    variable digits : natural range 0 to 9 := 0;
    variable temp_num : natural := num;
  begin
      if temp_num/10 = 0 then 
        return 1;
      end if;
      if temp_num/100 = 0 then 
        return 2;
      end if;
      if temp_num/1000 = 0 then 
        return 3;
      end if;
      if temp_num/10000 = 0 then 
        return 4;
      end if;
      if temp_num/100000 = 0 then 
        return 5;
      end if;
      if temp_num/1000000 = 0 then 
        return 6;
      end if;
      return 7;
  end function;
  
begin


  --------------------------------------------------------
  -- Instance of clock_enable entity
  --------------------------------------------------------
  clk_en : entity work.clock_enable
      port map(
          max => sig_baudrate_cycles,
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
            clk            => CLK100MHZ, -- change to sig_clk before implementing!!!
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
            clk            => CLK100MHZ, -- change to sig_clk before implementing!!!
            rst            => sig_rx_rs,
            data_frame_len => sig_dframe_l,
            parity_bit     => SW (3),
            parity_odd     => SW (2),
            stop_one_bit   => SW (1),
            
            is_data_ok     => sig_is_data_ok,
            is_finished    => sig_is_received,
            
            -- data out
            data_frame     => sig_data_frame,
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
  
  -- process for driving segmented displays
  p_display_driver : process (CLK100MHZ)
    variable i      : integer := 0;
    variable digits : integer := count_digits(sig_baudrate);
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
                if (digits >= 4) then
                  sig_hex <= std_logic_vector(to_unsigned(extract_digit(sig_baudrate/100, 4), 4));
                else
                  sig_hex <= "0000";
                end if;
              when 6 =>
                an  <= "11111011";
                if (digits >= 3) then
                  sig_hex <= std_logic_vector(to_unsigned(extract_digit(sig_baudrate/100, 3), 4));
                else
                  sig_hex <= "0000";
                end if;
              when 7 =>
                an  <= "11111101";
                if (digits >= 2) then
                  sig_hex <= std_logic_vector(to_unsigned(extract_digit(sig_baudrate/100, 2), 4));
                else
                  sig_hex <= "0000";
                end if;
              when 8 =>
                an  <= "11111110";
                if (digits >= 1) then
                  sig_hex <= std_logic_vector(to_unsigned(extract_digit(sig_baudrate/100, 1), 4));
                else
                  sig_hex <= "0000";
                end if;
                i := 0;
              when others =>
              -- do nothing
       end case;
    end if;
  end process p_display_driver;
  
  
  -- process for getting and controling the user input and indicators
  p_settings : process (CLK100MHZ) is
    variable i : integer := 0;
  begin
  if rising_edge(CLK100MHZ) then
      -- button press sense iterator
      i := i + 1;
      -- switch to transmitter
      if (SW(0) = '0') then
        sig_tx_en <= '1';
        sig_tx_rs <= '0';
        sig_rx_en <= '0';
        sig_rx_rs <= '1';
      -- switch to receiver
      else
        sig_tx_en <= '0';
        sig_tx_rs <= '1';
        sig_rx_en <= '1';
        sig_rx_rs <= '0';
      end if;
      -- reset when BTNC pressed
      if BTNC = '1' then
        sig_tx_rs <= '1';
        sig_rx_rs <= '1';
      else 
        sig_tx_rs <= '0';
        sig_rx_rs <= '0';
      end if;
      -- dataframe len settings
      if (SW (6 downto 4) > "100") then
          sig_dframe_l <= "1001";
      end if;
      if (SW (6 downto 4) <= "100") then
          sig_dframe_l <= "0101" + unsigned(SW (6 downto 4));
      end if;
      -- update led indicators - settings
      LED (6 downto 0) <= SW(6 downto 0);
      -- update led indicators - received data
      if (sig_is_received) then
        -- display data only when either parity is disabled or parity is ok
        if (sig_is_data_ok or SW (3) = '0') then
          LED (15 downto 7) <= sig_data_frame;
        end if;
      end if;
      -- baudrate button input
      if (i = 25000000) then
          if (BTND = '1') then
            if sig_baudrate - 100 >= 100 then
              sig_baudrate <= sig_baudrate - 100;
            end if;
          end if;
          if (BTNU = '1') then
            if sig_baudrate + 100 <= 115200 then
              sig_baudrate <= sig_baudrate + 100;
            end if;
          end if;
          if (BTNL = '1') then
            if sig_baudrate - 1000 >= 100 then
              sig_baudrate <= sig_baudrate - 1000;
            end if;
          end if;
          if (BTNR = '1') then
            if sig_baudrate + 1000 <= 115200 then
              sig_baudrate <= sig_baudrate + 1000;
            end if;
          end if;
          i := 0;
          sig_baudrate_cycles <= 100000000/sig_baudrate;    
      end if;
  end if;
  end process p_settings;
  
end architecture behavioral;
