----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2023 01:55:48 PM
-- Design Name: 
-- Module Name: transmitter - Behavioral
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

entity transmitter is
port (
    clk   : in    std_logic;                    --! Main clock
    rst   : in    std_logic                    --! High-active synchronous reset
  );

end transmitter;

architecture Behavioral of transmitter is
-- Internal clock enable
  signal sig_en : std_logic;
  constant c_DATA    : std_logic_vector(7 downto 0) := b"10010011"; --! RGB settings for red color

begin
  clk_en0 : entity work.clock_enable
    generic map (
      -- FOR SIMULATION, KEEP THIS VALUE TO 1
      -- FOR IMPLEMENTATION, CALCULATE VALUE: 250 ms / (1/100 MHz)
      -- 1   @ 10 ns
      -- ??? @ 250 ms
      g_MAX => 10416 -- probably 9600 baudrate
    )
    port map (
      clk => clk,
      rst => rst,
      ce  => sig_en
    );

end Behavioral;
