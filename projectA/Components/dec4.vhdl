library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity constant_4 is
  port( 
  	    o_F : out std_logic_vector(31 downto 0));
 end constant_4;

architecture mixed of constant_4 is 

begin

o_F <= "00000000000000000000000000000100";

end mixed;