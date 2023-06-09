library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith;

entity tb_receiver is
--  Port ( );
end tb_receiver;

architecture Behavioral of tb_receiver is
  constant c_DATA_WIDTH        : natural := 9;
  constant c_CNT_WIDTH         : natural := 4;
  constant c_CLK_100MHZ_PERIOD : time    := 10 ns;

  signal sig_clk_100mhz        : std_logic                                     := '0';
  signal sig_data_frame        : std_logic_vector (c_DATA_WIDTH - 1 downto 0)  := "000000000";
  signal sig_rst               : std_logic                                     := '0';
  signal sig_en                : std_logic                                     := '1';
  signal sig_cnt_up            : std_logic                                     := '1';
  signal sig_data_bit          : std_logic                                     := '1';
  signal sig_received_bit      : std_logic                                     := '0';
  signal sig_data_pointer      : std_logic_vector(c_CNT_WIDTH - 1 downto 0)    := (others => '0');
  signal sig_data_frame_len    : unsigned(3 downto 0)                          := "0110";
  signal sig_is_ok             : boolean                                       := false;
  signal sig_is_finished       : boolean                                       := false;
  
  
begin

  uut_receiver : entity work.receiver
    generic map (
      g_CNT_WIDTH  => c_CNT_WIDTH,
      g_DATA_WIDTH => c_DATA_WIDTH
    )
    port map (
      clk                => sig_clk_100mhz,
      data_frame         => sig_data_frame,
      data_pointer       => sig_data_pointer,
      data_frame_len     => sig_data_frame_len,
      data_bit           => sig_data_bit,
      en                 => sig_en,
      rst                => '0',
      stop_one_bit       => '0',
      parity_bit         => '1',
      parity_odd         => '0',
      is_data_ok         => sig_is_ok,
      is_finished        => sig_is_finished,
      received_bit       => sig_received_bit
    );
    
  --------------------------------------------------------
  -- Clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 1500 ns loop            

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
    loop
        sig_rst <= '0';
        wait for 200ns;
        sig_rst <= '1';
        wait for 40ns;
        sig_rst <= '0';
        wait for 280ns;
    end loop;

  end process p_reset_gen;
  --------------------------------------------------------
  -- enable generation process
  --------------------------------------------------------
  p_en_gen : process is
  begin
    sig_en <= '1';
    wait for 500ns;
    sig_en <= '0';
    wait for 1300ns;
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
    --"1111111110001101";
    report "Stimulus process started";
    loop
        -- pull high, sync
        sig_data_bit  <= '1';
        wait for 50ns;
        -- send valid UART frame
        -- pull low - start bit
        sig_data_bit  <= '0';
        wait for 10ns;
        -- transmitted data frame (7 bits)
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        -- parity bit (odd)
        sig_data_bit  <= '1';
        wait for 10ns;
        -- stop bit (two)
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        -- pull high, sync
        sig_data_bit  <= '1';
        wait for 50ns;
        -- send invalid UART frame
        -- pull low - start bit
        sig_data_bit  <= '0';
        wait for 10ns;
        -- transmitted data frame (7 bits)
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '0';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        -- parity bit (odd)
        sig_data_bit  <= '1';
        wait for 10ns;
        -- stop bit (two)
        sig_data_bit  <= '1';
        wait for 10ns;
        sig_data_bit  <= '1';
        wait for 10ns;
        -- pull high, sync
        sig_data_bit  <= '1';
        wait for 50ns;
        
    end loop;
    report "Stimulus process finished";
    wait;

  end process p_stimulus;
end Behavioral;