library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith;

entity receiver is
  generic (
    g_DATA_WIDTH : natural := 9; 
    g_CNT_WIDTH  : natural := 4 
  );
  
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    en             : in  std_logic;

    data_frame     : out  std_logic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
    data_frame_len : in unsigned(3 downto 0);
    
    stop_one_bit   : in std_logic;
    parity_bit     : in std_logic;
    parity_odd     : in std_logic;
    
    data_bit       : in std_logic;
    received_bit   : out std_logic;
    data_pointer   : out std_logic_vector(g_CNT_WIDTH - 1 downto 0) := (others => '0');
    
    is_finished    : out boolean := false;
    is_data_ok     : out boolean := false
    
  );
end receiver;

architecture Behavioral of receiver is

  -- enum for different receiver actions
  type t_rx_state is (
    IDLE,
    DATA,
    PARITY,
    STOP
  );
    -- internal count signal
  signal sig_state      : t_rx_state                                  := IDLE;
  signal sig_cnt        : std_logic_vector(g_CNT_WIDTH - 1 downto 0)  := (others => '0');
  signal sig_rst        : std_logic                                   := '1';
  signal sig_data_frame : std_logic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
  -- global variable to indicate what stop bit is next
  shared variable is_second : boolean                                 := false;
  -- frame ok signal
  signal sig_is_frame_ok    : boolean                                 := false;
  
  -- function to check if the number of '1's in a std_logic_vector is odd
  function is_odd(s : std_logic_vector(g_DATA_WIDTH - 1 downto 0)) return boolean is
   variable temp_count : unsigned(3 downto 0)  := (others => '0');
   variable temp_odd   : boolean := false;
  begin
    -- iterate for length of vector s
    for i in s'range loop
      -- increment 1 if symbol is 1
      if s(i) = '1' then 
        temp_count := temp_count + 1; 
      end if;
    end loop;
    
    if temp_count(0) = '1' then 
        temp_odd := true;
    end if;
    
    return temp_odd;
  end function is_odd;
    
  begin
  
  -- instantiate the up-down counter
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
  
  -- process to deserialise the received data
  p_deserialise : process (clk) is
  begin
      if (rising_edge(clk)) then
          if (rst = '1') then
            sig_rst <= '1';
            received_bit <= '0';
            sig_state <= IDLE;
            data_pointer <= "0000";
            is_finished <= false;
            is_data_ok <= false;
            sig_is_frame_ok <= true;
            is_second := false;
          else
              if (en = '1') then
                case sig_state is
                    
                    -- outputs start bit
                    when IDLE =>
                    if (data_bit = '0') then
                        sig_state <= DATA;
                        sig_rst <= '0';
                    else 
                    end if;
                    
                    -- serialises data seqeunce and outputs one bit by another with clk
                    when DATA =>
                    is_finished <= false;
                    is_data_ok <= false;
                    sig_is_frame_ok <= true;
                    sig_rst <= '0';
                    sig_data_frame(to_integer(unsigned(sig_cnt))) <= data_bit;
                    data_pointer   <= sig_cnt;
                    if (unsigned(sig_cnt) = data_frame_len - 1) then
                        if (parity_bit = '1') then
                            sig_state <= PARITY;
                        else
                            sig_state <= STOP;
                            data_frame <= sig_data_frame;
                        end if;
                    end if;
                    
                    -- outputs odd/even parity bits, or is omitted when required
                    when PARITY =>
                    data_pointer <= "0000";
                    sig_rst <= '1';
                      -- if odd parity
                      if (parity_odd = '1') then
                      -- if number of 1s in the data frame and parity bit is odd, data is ok
                        if ((is_odd(sig_data_frame) and data_bit = '0') or (not is_odd(sig_data_frame) and data_bit = '1')) then
                            is_data_ok <= true;
                        else
                            is_data_ok <= false;
                        end if;
                      -- if even parity
                      else
                      -- if number of 1s in the data frame and parity bit is even, data is ok
                        if ((not is_odd(sig_data_frame) and data_bit = '0') or (is_odd(sig_data_frame) and data_bit = '1')) then
                            is_data_ok <= true;
                        else
                            is_data_ok <= false;
                        end if;
                      end if;
                      sig_state <= STOP;
                      
                      when STOP =>
                      data_pointer <= "0000";
                      sig_rst <= '1';
                      
                      -- if only one stop bit is required
                      if (stop_one_bit = '1') then
                          if (data_bit = '1') then
                          is_finished <= true;
                          data_frame <= sig_data_frame;
                          sig_state <= IDLE;
                          end if;
                      else
                          -- switches to start after 2 iterations
                          if (not is_second) then
                              if (data_bit = '0') then
                                sig_is_frame_ok <= false;
                              end if;
                              is_second := true;
                          else
                              if (not sig_is_frame_ok or data_bit = '0') then
                                is_finished <= false;
                              else
                                data_frame <= sig_data_frame;
                                is_finished <= true;
                                sig_state <= IDLE;
                              end if;
                              is_second := false;
                          end if;
                      end if;
        
                end case;
              else 
                data_pointer  <= (others => '0');
                sig_rst <= '1';
                received_bit <= '1';
              end if;
          received_bit <= data_bit;
      end if;
    end if;
  end process p_deserialise;
  
 
end Behavioral;
