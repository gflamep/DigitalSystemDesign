
`timescale 1ns / 10ps

module hourclock_tb;

    parameter real CLOCK_PERIOD = 10;
    /* you need to fill in the blanks here */
    
    /* Start */
	// Simulation parameters
    reg clk = 0;
    reg reset = 0;
    reg ena = 1;
    wire pm;
    wire [7:0] hour;
    wire [7:0] min;
    wire [7:0] sec;

	always #(CLOCK_PERIOD/2) clk = ~clk;

    // Instantiate the clock module
    hourclock hc (
        .clk(clk),
        .reset(reset),
        .ena(ena),
        .pm(pm),
        .hour(hour),
        .min(min),
        .sec(sec)
    );

    // Initial block to run tests
    initial begin
        // Display header for readability
        $display("Time\t\tReset\tEnable\tHour\tMin\tSec\tPM");
        $display("----------------------------------------------------------------");

        // Monitor any change in major signals
        $monitor("%g\t\t%b\t%b\t%02d\t%02d\t%02d\t%b", 
                 $time, reset, ena, hour, min, sec, pm);

        // Test Reset at Startup
        reset = 1; #10; reset = 0;
        #100; 

        // Test Normal Operation
        ena = 1; #1000;

        // Test Pause and Resume
        ena = 0; #400;
        ena = 1; #1000;

        // Test Pause and Resume
        ena = 0; #400;
        ena = 1; #40000;

        // Test Reset While Running
        reset = 1; #10; reset = 0; #40000;

		//Test Reset While Pause
		ena = 0; #400;
		reset = 1; # 10; reset = 0;# 1000;
		ena = 1; # 1000;

        // Long Run Test
        #1000000;

        // Finish the simulation
        $finish;
    end


    /* END */


endmodule