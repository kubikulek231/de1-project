----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2023 01:55:05 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( CLK100MHZ : in STD_LOGIC;
           -- SW : in STD_LOGIC_VECTOR (1 downto 0);

           BTNC : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (11 downto 0)
           );
end top;

----------------------------------------------------------
-- Architecture body for top level
----------------------------------------------------------

architecture behavioral of top is

  -- 4-bit counter @ 250 ms
  signal sig_en_9600 : std_logic;                    --! Clock enable signal for Counter0
  signal sig_cnt_3bit : std_logic_vector(2 downto 0); --! Counter0

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
          rst => BTNC,
          ce  => sig_en_9600
      );

  --------------------------------------------------------
  -- Instance (copy) of cnt_up_down entity
  --------------------------------------------------------
  bin_cnt0 : entity work.cnt_up_down
     generic map(
          g_CNT_WIDTH => 3
      )
      port map(
              clk    => CLK100MHZ,
              rst    => BTNC,
              en     => sig_en_9600,
              cnt_up => '1',
              cnt    => sig_cnt_3bit
      );

  --------------------------------------------------------
  -- Other settings
  --------------------------------------------------------
  -- Connect one common anode to 3.3V
  AN <= b"1111_1110";
  LED <= sig_cnt_12bit;

end architecture behavioral;