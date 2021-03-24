library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.CONV2D_PKG.all;

entity CONV2D is
	generic(
		width          	: integer :=8;	
		width_o        	: integer :=16;	
		resolution_w   	: integer :=106;
		resolution_h   	: integer :=160
	);
	port (
		clk      		: in  std_logic;
		reset    		: in  std_logic;
		en_in   		: in  std_logic;
		data_in  		: in  std_logic_vector(width-1 downto 0);
		en_out   		: out std_logic;
		data_out 		: out std_logic_vector(width_o-1 downto 0)
	);
end CONV2D;

architecture struct of CONV2D is
	-- internal signal for kernel calculation 
	signal L0         		: pixel_buf;
	signal L1         		: pixel_buf;
	signal L2         		: pixel_buf;
	signal L3         		: pixel_buf;
	signal L4         		: pixel_buf;
	signal reset_kernel 	: std_logic;
	-- input register
	signal data_out_reg 	: std_logic_vector(width_o-1 downto 0);	
	signal enable			: std_logic;
	signal enable_reg		: std_logic;


begin
	-- reset
	reset_kernel <= not(en_in) or reset;		
----------------------------------------------------------------------------------------------
	process
	begin
		wait until rising_edge(clk);
        -- delay: last value of array is input enable
        enable <= en_in;
	end process;

----------------------------------------------------------------------------------------------
    -- current input pixel is right-bottom
    l4(4) <= data_in;
	process
	begin
		wait until rising_edge(clk);
		-- delay each line by 4 clock cycles:
		--    previous value of right pixels are going to left pixels
		L4(3) <= L4(4);
		L4(2) <= L4(3);
		L4(1) <= L4(2);
		L4(0) <= L4(1);

		L3(3) <= L3(4);
		L3(2) <= L3(3);
		L3(1) <= L3(2);
		L3(0) <= L3(1);

		L2(3) <= L2(4);
		L2(2) <= L2(3);
		L2(1) <= L2(2);
		L2(0) <= L2(1);

		L1(3) <= L1(4);
		L1(2) <= L1(3);
		L1(1) <= L1(2);
		L1(0) <= L1(1);	

		L0(3) <= L0(4);
		L0(2) <= L0(3);
		L0(1) <= L0(2);
		L0(0) <= L0(1);

	end process;  
 ---------------------------------------------------------------------------------------------- 
	mem0: entity work.BufferRow generic map (width, width_o, resolution_w, resolution_h)
	port map
		(clk      => clk,
		reset    => reset,
		write_en => en_in,
		data_in  => L4(4),
		data_out => L3(4));
	mem1: entity work.BufferRow generic map (width, width_o, resolution_w, resolution_h)
	port map
		(clk      => clk,
		reset    => reset,
		write_en => en_in,
		data_in  => L3(4),
		data_out => L2(4));
	mem2: entity work.BufferRow generic map (width, width_o, resolution_w, resolution_h)
	port map
		(clk      => clk,
		reset    => reset,
		write_en => en_in,
		data_in  => L2(4),
		data_out => L1(4));
	mem3: entity work.BufferRow generic map (width, width_o, resolution_w, resolution_h)
	port map
		(clk      => clk,
		reset    => reset,
		write_en => en_in,
		data_in  => L1(4),
		data_out => L0(4));

	-- kernel
	kernel : entity work.kernel generic map (width, width_o, resolution_w, resolution_h)
	port map
		(clk      => clk,
		reset    => reset_kernel,
		L0       => L0,
		L1       => L1,
		L2       => L2,
		L3       => L3,
		L4       => L4,
		data_out => data_out_reg);
----------------------------------------------------------------------------------------------
	process
		-- counter
	variable cnt_frame		: integer range 0 to (resolution_h*resolution_w);
	variable cnt_width		: integer range 0 to (resolution_w);
	begin
		wait until rising_edge(clk);
		enable_reg    <= enable;
		
		if enable_reg='0' and enable='1' then 
		    en_out        <= enable_reg;
		elsif enable_reg='1' and enable='0' then
		  en_out          <= enable;
		else
		    en_out        <= enable_reg;
		end if;
		if reset = '1' then
			cnt_frame := 0;
		elsif enable = '1' and cnt_frame<(resolution_h*resolution_w)then 
			cnt_frame := cnt_frame + 1; 
		elsif enable = '1' and cnt_frame = (resolution_h*resolution_w) then
            cnt_frame := 1;
		elsif enable = '0' then
			cnt_frame := 0;
		end if;
		
		if reset = '1' then
			cnt_width := 0;
		elsif enable = '1' and cnt_width<(resolution_w)then 
			cnt_width := cnt_width + 1; 
		elsif enable = '1' and cnt_width = (resolution_w) then
            cnt_width := 1;
		elsif enable = '0' then
			cnt_width := 0;
		end if;
		
		if (cnt_frame > 0) and (cnt_frame <= (resolution_w*4)) then
			data_out    <= (others => '0');
		elsif (cnt_frame > 0) and (cnt_frame <= (resolution_h*resolution_w)) then
			if (cnt_width > 0) and (cnt_width < 5) then
				data_out    <= (others => '0');
			else
				data_out	<= data_out_reg;
			end if;			
		else 
			data_out    <= (others => '0');
		end if;
	end process;			
----------------------------------------------------------------------------------------------		

	  
end struct;