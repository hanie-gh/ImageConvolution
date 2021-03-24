library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;

entity TestBench is
end TestBench;

architecture Behavioral of TestBench is
-- define constants for simulation
    constant origin_file_name   : string  := "H:\Projects\FPGA\PLC2_test\Python\origin_file.txt";
    constant ground_file_name   : string  := "H:\Projects\FPGA\PLC2_test\Python\ground_file.txt";
    constant result_file_name   : string  := "H:\Projects\FPGA\PLC2_test\Python\result_file.txt";
    constant res_w         : integer := 106;  -- horizontal size of image
    constant res_h         : integer := 160;   -- vertical size of image
    constant res           : integer := res_h*res_w;  
    constant width         : integer := 8;
    constant width_o       : integer := 16;
    constant kernel_width  : integer := 9;
-- signals of testbench
	signal clk       : std_logic := '0';
	signal reset     : std_logic;
	signal en_in 	 : std_logic;
	signal en_out	 : std_logic;
	signal d_in      : std_logic_vector(width-1 downto 0);
	signal d_out     : std_logic_vector(width_o-1 downto 0);
	signal mismatch  : integer   := 0;
	signal x, y      : integer;

begin
-- clock generation
    clk <= not clk after 5 ns;
    
-- instantiation of design-under-test
    dut : entity work.CONV2D
    generic map (width, width_o, res_w, res_h)
    port map (clk, reset, en_in, d_in, en_out, d_out);
------------------------------------------------------------------------------------------
-- main process for stimuli
    stimuli_process : process
    -- variables for origin file
        file origin_file   		: text;
        variable l_org     		: line;
        variable origin_status	: file_open_status;
		variable d_in_var   	: std_logic_vector(width-1 downto 0);
    begin
    -- init
        reset   <= '1', '0' after 50 ns;  -- reset for 10 clock cycles
        en_in   <= '0';
        d_in    <= (others=>'0');
	-- wait for reset
		wait for 100 ns;		
	-- open stimuli file
		file_open(origin_file, origin_file_name, read_mode);
	-- loop for one frame
		for y in 0 to res_h-1 loop		  
		  for x in 0 to res_w-1 loop
                readline(origin_file, l_org);      
                hread(l_org, d_in_var);                
                d_in <=  d_in_var;
                en_in <= '1';
                wait until falling_edge(clk);
			end loop;  
            d_in <= (others=>'0');
            en_in <= '0';
		end loop;  
	
        for i in 0 to 5 loop
            wait until falling_edge(clk);
        end loop;
        file_close(origin_file);
--        std.env.finish;
    end process;
--------------------------------------------------------------------------------------------
-- second process to handle DUT output
	response_process : process
		variable x_pos, y_pos     : integer := 0;
	-- variables for writing simulated result
		file result_file        : text;
		variable l_re           : line;
		variable d_out_var      : std_logic_vector(width_o-1 downto 0);		

	begin
	-- open file for output
		file_open(result_file, result_file_name, write_mode);
		wait until (en_out = '1');
            while (en_out = '1') loop                
            -- get result and write to result file
                d_out_var := d_out;
                hwrite(l_re, d_out_var);               
                writeline(result_file, l_re);
            wait until falling_edge(clk);
            end loop;

		
        for i in 0 to 5 loop
            wait until falling_edge(clk);
        end loop;		
		file_close(result_file);  
	end process;
--------------------------------------------------------------------------------------------
-- Third process to comare expected data with output
	comparing_process : process
		variable x_pos, y_pos     : integer := 0;	
	-- variables for expected result file
		file ground_file       : text;
		variable l_ex          : line;
		variable d_ex          : std_logic_vector(width_o-1 downto 0);
	begin
	-- open file for expected data
		file_open(ground_file, ground_file_name, read_mode);
		 
		wait until (en_out = '1');
            while (en_out = '1') loop                
    		-- read expected result and compare to simulation result
    			readline(ground_file, l_ex);  -- read one line
    			hread(l_ex, d_ex);
    			if (d_out /= d_ex) then
    				mismatch <= mismatch + 1;
    				assert false
    				report "MISMATCH in simulation at position x=" & integer'image(x_pos) & " y=" & integer'image(y_pos)
    				severity note;
    			end if;
    
    			x_pos := x_pos + 1;
    			if x_pos = res_w then
    			  y_pos := y_pos + 1;
    			  x_pos := 0;
    			end if;
            wait until falling_edge(clk);
            end loop;

		    report "*** The number of MISMATCH are: " & integer'image(MISMATCH);
        for i in 0 to 10 loop
            wait until falling_edge(clk);
        end loop;		
		file_close(ground_file);
        std.env.finish; 
	end process;

end Behavioral;
