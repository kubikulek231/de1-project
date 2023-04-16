library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith;

-- Define the transmitter entity
entity transmitter is
  generic (
    g_DATA_WIDTH : natural := 9;
    g_CNT_WIDTH  : natural := 4
  );
  
  port (
    -- global
    clk            : in  std_logic;
    -- counter part
    en             : in  std_logic;
    -- main part
    data_frame     : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    data_frame_len : in unsigned(3 downto 0);
    
    stop_one_bit   : in std_logic;
    parity_bit     : in std_logic;
    parity_odd     : in std_logic;
    
    serialised_bit : out std_logic;
    data_pointer   : out std_logic_vector(g_CNT_WIDTH - 1 downto 0) := (others => '0')
  );
end transmitter;

-- Define the architecture for the transmitter entity
architecture Behavioral of transmitter is
  type t_tx_state is (
    START,
    DATA,
    PARITY,
    STOP
  );

  -- Internal count signal
  signal sig_state      : t_tx_state                                 := START;
  signal sig_cnt        : std_logic_vector(g_CNT_WIDTH - 1 downto 0) := (others => '0');
  signal sig_rst        : std_logic                                  := '1';
  shared variable is_second : boolean := false;

  -- Function to check if the number of '1's in a std_logic_vector is odd
  function is_odd(s : std_logic_vector(g_DATA_WIDTH - 1 downto 0)) return boolean is
    variable temp_count : unsigned(3 downto 0)  := (others => '0');
    variable temp_odd   : boolean := true;
  begin
    for i in s'range loop
      if s(i) = '1' then 
        temp_count := temp_count + 1; 
      end if;
    end loop;
    
    if temp_count(0) = '0' then 
      temp_odd := false;
    end if;

    return temp_odd;
  end function is_odd;

  begin
  -- Instantiate the up-down counter
  uut_cnt : entity work.cnt_up_down
  generic map (
    g_CNT_WIDTH => g_CNT_WIDTH
  )
  port map (
    clk    => clk,
    rst    => sig_rst,
    en     => en,
    cnt_up => '1',
    cnt    => sig_cnt
  );

  -- Process to serialise the data
  p_serialise : process (clk) is
  begin
    if (rising_edge(clk)) then
      if (en = '1') then
        case sig_state is
          -- Outputs start bit
          when START =>
            sig_rst <= '0';
            serialised_bit <= '0';
            sig_state <= DATA;
          
          -- Serialises data sequence and outputs one bit by another with clk
          when DATA =>
            sig_rst <= '0';
            serialised_bit <= data_frame(to_integer(unsigned(sig_cnt)));
            data_pointer   <= sig_cnt;
            if (unsigned(sig_cnt) = data_frame_len - 1) then
                if (parity_bit = '1') then
                    sig_state <= PARITY;
                else
                    sig_state <= STOP;
                end if;
            end if;
          
          -- Outputs odd/even parity bits, or is omitted when required
          when PARITY =>
              data_pointer <= "0000";
              sig_rst <= '1';
              
              -- If odd parity is selected
              if (parity_odd = '1') then
                  -- If the number of '1's in the data frame is odd, the parity bit is 0 and otherwise
                  if (is_odd(data_frame)) then
                      serialised_bit <= '0';
                  else
                      serialised_bit <= '1';
                  end if;
              -- If even parity is selected
              else
                  -- If the number of '1's in the data frame is odd, the parity bit is 1 and otherwise
                  if (is_odd(data_frame)) then
                      serialised_bit <= '1';
                  else
                      serialised_bit <= '0';
                  end if;
              end if;
              
              -- Transition to the STOP state
              sig_state <= STOP;
          
          -- Outputs the required number of stop bits
          when STOP =>
              data_pointer <= "0000";
              sig_rst <= '1';
              
              -- If only one stop bit is required
              if (stop_one_bit = '1') then
                  serialised_bit <= '1';
                  sig_state <= START;
              else
                  -- Switches to start after 2 iterations
                  if (not is_second) then
                      serialised_bit <= '1';
                      is_second := true;
                  else
                      serialised_bit <= '1';
                      sig_state <= START;
                      is_second := false;
                  end if;
              end if;
          end case;
        else 
          serialised_bit <= '1';
          data_pointer  <= (others => '0');
        end if;
      end if;
    end process p_serialise;
   
end Behavioral;
