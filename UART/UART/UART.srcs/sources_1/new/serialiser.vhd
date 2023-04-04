----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2023 02:13:16 PM
-- Design Name: 
-- Module Name: serialiser - Behavioral
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serialiser is
  generic (
    g_DATA_WIDTH : natural := 8; --! Default number of counter bits
    g_CNT_WIDTH : natural := 3 --! Default number of counter bits
  );
  port (



    cnt    : in   std_logic_vector(g_DATA_WIDTH - 1 downto 0); --! Counter value
    data   : in    std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    serialised_bit : out std_logic
  );
end serialiser;

architecture Behavioral of serialiser is

begin

  p_serialise : process (cnt) is
  begin

     serialised_bit <= data(unsigned(cnt));

  end process p_serialise;

end Behavioral;
