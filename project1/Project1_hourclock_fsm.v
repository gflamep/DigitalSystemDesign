
module hourclock 
    (
        input wire clk,
        input wire reset,
        input wire ena,
        output reg pm,
        output reg [7:0] hour,
        output reg [7:0] min,
        output reg [7:0] sec
    );


    /* you need to fill in the blanks here */
    
    /* Start */
	// State Definitions
    localparam RESET = 2'b00,
            NORMAL = 2'b01,
            PAUSED = 2'b10;
	reg [1:0] state;
    // State Transition Logic
	always @(reset or ena) begin
	    if (reset) begin
	        // Reset condition
	        state <= RESET;
	    end 
		else begin
	        // Transition based on ena
	        if (ena)
	            state <= NORMAL;
	        else
	            state <= PAUSED;
	    end
	end

	// Time Counting Logic
	always @(posedge clk) begin
	    if (state == NORMAL) begin
	        // Increment time only if not in reset
	        sec = sec + 8'd1;
	        if (sec == 8'd60) begin
	            sec = 8'd0;
	            min = min + 8'd1;
	            if (min == 8'd60) begin
	                min = 8'd0;
	                hour = hour == 8'd12 ? 8'd1 : hour + 8'd1;
	                if (hour == 8'd12)
	                    pm = ~pm; // Toggle PM on 12-hour
	            end
	        end
	    end
		else if(state == RESET) begin
			// Reset outputs
        	hour = 8'd12;
        	min = 8'd0;
        	sec = 8'd0;
        	pm = 1'b0;
		end
		// PAUSE state requires no operational logic
	end
    /* END */


endmodule