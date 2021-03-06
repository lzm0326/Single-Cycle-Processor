library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity combine_32bit is
  port( i_0 : in std_logic_vector(3 downto 0);
			i_1 : in std_logic_vector(31 downto 0);
  	    o_mux : out std_logic_vector(31 downto 0));
 end combine_32bit;

architecture beh of combine_32bit is 

begin

	o_mux(31 downto 28) <= i_0(3 downto 0);
	o_mux(27 downto 0) <= i_1(27 downto 0);
end beh;