library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CONV2D_PKG is
		constant width : integer := 8;
		constant width_o : integer := 16;
		constant resolution_w : integer := 106;
		constant resolution_h : integer := 160;
		constant kernel_width : integer := 9;
		type pixel_buf is array (0 to 4) of std_logic_vector(width-1 downto 0);
		type kernel_buf is array (0 to 4) of integer range -4 to 4;
		type ram_array is array (0 to resolution_w-1) of std_logic_vector(width-1 downto 0);
end package;

package body CONV2D_PKG is

end package body;