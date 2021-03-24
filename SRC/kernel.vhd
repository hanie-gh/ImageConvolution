library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CONV2D_PKG.all;

entity kernel is
	generic(
		width      : integer;	
		width_o    : integer;	
		resolution_w : integer;
		resolution_h : integer
	);
	port ( 
		clk   : in  std_logic;
		reset : in  std_logic;
		L0    : in  pixel_buf;
		L1    : in  pixel_buf;
		L2    : in  pixel_buf;
		L3    : in  pixel_buf;
		L4    : in  pixel_buf;
		--en_out  : out std_logic;
		data_out  : out std_logic_vector(width_o-1 downto 0)
	);
end kernel;

architecture struct of kernel is
	constant K0: kernel_buf:= (1,1,1,1,1);
	constant K1: kernel_buf:= (1,1,1,1,1);
	constant K2: kernel_buf:= (1,1,1,1,1);
	constant K3: kernel_buf:= (1,1,1,1,1);
	constant K4: kernel_buf:= (1,1,1,1,1);
begin

	process
		variable sum : integer range 0 to 16384;
	begin
		-- adding all the input 
		if reset = '1' then 
		sum := 0;
		data_out <= (others=>'0');
		--        en_out   <= '0';
		else
		sum :=   
		K0(0)*to_integer( unsigned(L0(0)) )+ K0(1)*to_integer( unsigned(L0(1)) )+ K0(2)*to_integer( unsigned(L0(2)) )+ K0(3)*to_integer( unsigned(L0(3)) )+ K0(4)*to_integer( unsigned(L0(4)) )+
		K1(0)*to_integer( unsigned(L1(0)) )+ K1(1)*to_integer( unsigned(L1(1)) )+ K1(2)*to_integer( unsigned(L1(2)) )+ K1(3)*to_integer( unsigned(L1(3)) )+ K1(4)*to_integer( unsigned(L1(4)) )+
		K2(0)*to_integer( unsigned(L2(0)) )+ K2(1)*to_integer( unsigned(L2(1)) )+ K2(2)*to_integer( unsigned(L2(2)) )+ K2(3)*to_integer( unsigned(L2(3)) )+ K2(4)*to_integer( unsigned(L2(4)) )+
		K3(0)*to_integer( unsigned(L3(0)) )+ K3(1)*to_integer( unsigned(L3(1)) )+ K3(2)*to_integer( unsigned(L3(2)) )+ K3(3)*to_integer( unsigned(L3(3)) )+ K3(4)*to_integer( unsigned(L3(4)) )+
		K4(0)*to_integer( unsigned(L4(0)) )+ K4(1)*to_integer( unsigned(L4(1)) )+ K4(2)*to_integer( unsigned(L4(2)) )+ K4(3)*to_integer( unsigned(L4(3)) )+ K4(4)*to_integer( unsigned(L4(4)) );

		data_out <= std_logic_vector(to_unsigned(sum, data_out'length));
		--        en_out   <= '1'; 
		end if;
		wait until rising_edge(clk);
	end process;

end struct;