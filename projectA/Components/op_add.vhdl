library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity op_add is
  port( 
  	    o_F : out std_logic_vector (3 downto 0));
 end op_add;

architecture mixed of op_add is 

begin

o_F <= "0000";

end mixed;