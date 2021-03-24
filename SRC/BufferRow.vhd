library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.CONV2D_PKG.all;

entity BufferRow is
	generic(
		width          : integer;	
		width_o        : integer;		
		resolution_w   : integer;
		resolution_h   : integer
	);
	port (
		clk      : in  std_logic;
		reset    : in  std_logic;
		write_en : in  std_logic;
		data_in  : in  std_logic_vector(width-1 downto 0);
		data_out : out std_logic_vector(width-1 downto 0)
	);
end BufferRow;

architecture struct of BufferRow is
	signal ram : ram_array;
begin

	process
		variable wr_address : integer range 0 to resolution_w-1;
		variable rd_address : integer range 0 to resolution_w-1;
	begin
		wait until rising_edge(clk);

		if (write_en = '1') then
			data_out        <= ram(rd_address);
			ram(wr_address) <= data_in;
		end if;

		if (reset = '1') then
			wr_address := 0;
			rd_address := 1;
		elsif (write_en = '1') then
				wr_address := rd_address;
			if (rd_address = resolution_w-1) then
				rd_address := 0;
			else
				rd_address := rd_address + 1;
			end if;
		end if;
	end process;

end struct;