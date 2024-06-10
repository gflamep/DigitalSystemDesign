`timescale 1ns / 1ps

module Elevator(
    input wire CLK100MHZ,
    input wire [15:0] SW,
    input wire BTNC, BTNU, BTNL, BTNR, BTND,    // Buttons, high output only when they are pressed.
    output reg [15:0] LED,                      // active-high
    output reg CA, CB, CC, CD, CE, CF, CG,      // 7 segment display, seven common cathod, active-low
    output reg DP,                             // adtive-low
    output reg [7:0] AN,                       // annode, active-low
    output reg LED16_B,
    output reg LED17_G,
    output reg LED17_R
    );
    
    wire C, U, L, R, D;
    wire CLK1MHZ, CLK10KHZ, CLK100HZ, CLK1HZ;
    wire [6:0] seg_out [7:0];
    reg [3:0] seg_in [7:0];
    
    //100MHZ to 1HZ
    prescaler100 P1 (.sig_in(CLK100MHZ), .sig_out(CLK1MHZ));
    prescaler100 P2 (.sig_in(CLK1MHZ), .sig_out(CLK10KHZ));
    prescaler100 P3 (.sig_in(CLK10KHZ), .sig_out(CLK100HZ));
    prescaler100 P4 (.sig_in(CLK100HZ), .sig_out(CLK1HZ));
    
    // oneshot(clk, in, out);
    oneshot O1 (CLK100HZ, BTNC, C);
    oneshot O2 (CLK100HZ, BTNU, U);
    oneshot O3 (CLK100HZ, BTNL, L);
    oneshot O4 (CLK100HZ, BTNR, R);
    oneshot O5 (CLK100HZ, BTND, D);
    
    /*
    assign C = BTNC;
    assign U = BTNU;
    assign D = BTND;
    */
    
    // encoding student ID logic
    segment S0 (.Din(seg_in[0]), .segout(seg_out[0]));
    segment S1 (.Din(seg_in[1]), .segout(seg_out[1]));
    segment S2 (.Din(seg_in[2]), .segout(seg_out[2]));
    segment S3 (.Din(seg_in[3]), .segout(seg_out[3]));
    segment S4 (.Din(seg_in[4]), .segout(seg_out[4]));
    segment S5 (.Din(seg_in[5]), .segout(seg_out[5]));
    segment S6 (.Din(seg_in[6]), .segout(seg_out[6]));
    segment S7 (.Din(seg_in[7]), .segout(seg_out[7]));
    
    
    // State definitions
    localparam [3:0] INITIAL = 4'b0000, SET = 4'b0001 , UP = 4'b0010, DOWN = 4'b0011,
        OPEN = 4'b0100, CLOSE = 4'b0101, LOAD = 4'b0110, UNLOAD = 4'b0111, FINISH = 4'b1000;    
    reg [3:0] state = INITIAL, next_state = INITIAL;
    
    reg [3:0] current_floor;
    reg [4:0] people_count;
    reg [3:0] highest_floor;
    reg [1:0] people_on_floor [8:0];
    integer i;
    // 7-segment display multiplexing counter
    reg [2:0] digit_select = 3'b000;

    // Asynchronous reset, state update
    always @(posedge CLK100HZ or posedge D or posedge U or posedge C) begin
        if (D) begin
            state <= INITIAL;
        end
        else if (U) begin
            if(state == INITIAL) begin
                state <= SET;
            end
        end
        else if (C) begin
            if(state == SET)
                state <= UP;
        end
        else begin
            state <= next_state;
            case(state)
                INITIAL: begin
                    // Initialize parameters
                    current_floor <= 1;
                    people_count <= 0;
                    //highest_floor <= 1;
                    people_on_floor[8] = SW[15:14];
                    people_on_floor[7] = SW[13:12];
                    people_on_floor[6] = SW[11:10];
                    people_on_floor[5] = SW[9:8];
                    people_on_floor[4] = SW[7:6];
                    people_on_floor[3] = SW[5:4];
                    people_on_floor[2] = SW[3:2];
                    people_on_floor[1] = 2'b00;
                    people_on_floor[0] = 2'b00;
                    highest_floor = (SW[15:14] > 0) ? 8 :
                                     (SW[13:12] > 0) ? 7 :
                                     (SW[11:10] > 0) ? 6 :
                                     (SW[9:8] > 0) ? 5 :
                                     (SW[7:6] > 0) ? 4 :
                                     (SW[5:4] > 0) ? 3 :
                                     (SW[3:2] > 0) ? 2 : 1;
                end
                UP: begin
                    if(next_state == UP)
                        current_floor <= current_floor + 1;
                    
                end
                LOAD: begin
                    if(people_count == 16) begin end
                    else if(people_on_floor[current_floor] > 0) begin
                        people_on_floor[current_floor] <= people_on_floor[current_floor] - 1;
                        people_count <= people_count + 1;
                    end
                end
                UNLOAD: begin
                    people_count <= people_count - 1;
                end
                DOWN: begin
                    if(next_state == DOWN)
                        current_floor <= current_floor - 1;
                end
            endcase
        end
    end
    
    // State controller
    always @(*) begin
        next_state = state;
        case(state)
            INITIAL: begin
                if(U) next_state = SET;
            end
            SET: begin
                if(C) next_state = UP;
            end
            UP: begin
                if(highest_floor == 1) next_state = FINISH;
                // changed
                else if(current_floor == highest_floor) next_state = OPEN;
            end
            OPEN: begin
                // load or unload
                if(current_floor == 1) next_state = UNLOAD;
                else if (people_on_floor[current_floor] > 0) next_state = LOAD;
            end
            LOAD: begin
            // changes 0 to 1
                if(people_on_floor[current_floor] == 0 || people_count == 16) next_state = CLOSE;
            end
            UNLOAD: begin
             // changed 0 to 1
                if(people_count == 0) next_state = CLOSE;
            end
            CLOSE: begin
                if(current_floor == 1) next_state = FINISH;
                else next_state = DOWN;
            end
            DOWN: begin
                if(current_floor == 1) next_state = OPEN;
                else if(people_count >= 16) next_state = DOWN;
                else if(people_on_floor[current_floor] > 0) next_state = OPEN;
            end
        endcase
    end
    /*
    always @(posedge CLK1HZ or posedge U) begin
        // added!!!!

        state <= next_state;
        if(U)begin
         
            if(state == INITIAL) begin
                // Get highest level to go to TODO
                for (i = 8; i > 1; i = i - 1) begin
                    if (people_on_floor[i] > 0 && highest_floor == 1) begin
                        highest_floor = i;
                    end
                end
            end
        end
        else begin
            
            
            case(state)
                INITIAL: begin
                    // Initialize parameters
                    current_floor <= 1;
                    people_count <= 0;
                    //highest_floor <= 1;
                    people_on_floor[8] = SW[15:14];
                    people_on_floor[7] = SW[13:12];
                    people_on_floor[6] = SW[11:10];
                    people_on_floor[5] = SW[9:8];
                    people_on_floor[4] = SW[7:6];
                    people_on_floor[3] = SW[5:4];
                    people_on_floor[2] = SW[3:2];
                    people_on_floor[1] = 2'b00;
                    people_on_floor[0] = 2'b00;
                    highest_floor = (SW[15:14] > 0) ? 8 :
                                     (SW[13:12] > 0) ? 7 :
                                     (SW[11:10] > 0) ? 6 :
                                     (SW[9:8] > 0) ? 5 :
                                     (SW[7:6] > 0) ? 4 :
                                     (SW[5:4] > 0) ? 3 :
                                     (SW[3:2] > 0) ? 2 : 1;
                end
                UP: begin
                    if(next_state == UP)
                        current_floor <= current_floor + 1;
                    
                end
                LOAD: begin
                    if(people_count == 16) begin end
                    else if(people_on_floor[current_floor] > 0) begin
                        people_on_floor[current_floor] <= people_on_floor[current_floor] - 1;
                        people_count <= people_count + 1;
                    end
                end
                UNLOAD: begin
                    people_count <= people_count - 1;
                end
                DOWN: begin
                    if(next_state == DOWN)
                        current_floor <= current_floor - 1;
                end
            endcase
            
            
        end
    end
    */
    
    // LED 17, 16
    always @(posedge CLK100HZ)begin
        case(state)
            INITIAL, SET, OPEN, LOAD, UNLOAD: begin
                // Turn on LED17 RED
                LED17_G = 1'b0; LED17_R = 1'b1;
                LED16_B = 1'b0;
            end
            UP: begin
                
                // Turn on LED17 GREEN
                LED17_G = 1'b1; LED17_R = 1'b0;
                LED16_B = 1'b0;
            end
            DOWN: begin
                if(people_on_floor[current_floor] == 0 || people_count >= 16) begin
                    // Turn on LED17 GREEN
                    LED17_G = 1'b1; LED17_R = 1'b0;
                    LED16_B = 1'b0;
                end
                else begin
                    // Turn on LED17 RED
                    LED17_G = 1'b0; LED17_R = 1'b1;
                    LED16_B = 1'b0;
                end
            end
            // TEST TODO
            CLOSE: begin
                if(current_floor == 1) begin
                    // Turn on LED17 RED
                    LED17_G = 1'b0; LED17_R = 1'b1;
                    LED16_B = 1'b0;
                end
                else if(people_on_floor[current_floor] == 0 || people_count >= 16) begin
                    
                    // Turn on LED17 GREEN
                    LED17_G = 1'b1; LED17_R = 1'b0;
                    LED16_B = 1'b0;
                end
            end
            FINISH: begin
                // Turn on LED16 BLUE
                LED17_G = 1'b0; LED17_R = 1'b0;
                LED16_B = 1'b1;
            end
        endcase
    end
    
    // Seg_in
    always @(posedge CLK100HZ) begin
        case(state)
            INITIAL: begin
                // Segment
                seg_in[0] = 4'd8;
                seg_in[1] = 4'd2; 
                seg_in[2] = 4'd6;
                seg_in[3] = 4'd0;
                seg_in[4] = 4'd1;
                seg_in[5] = 4'd3;
                seg_in[6] = 4'd0;
                seg_in[7] = 4'd2;
            end
            SET, UP: begin
                seg_in[0] = 4'd8;
                seg_in[1] = 4'd8; 
                seg_in[2] = 4'd8;
                seg_in[3] = 4'd8;
                seg_in[4] = 4'd8;
                seg_in[5] = 4'd8;
                seg_in[6] = 4'd8;
                seg_in[7] = 4'd8;
            end
            OPEN, LOAD, UNLOAD: begin
                seg_in[current_floor-1] = 4'd0;
            end
            CLOSE, DOWN: begin
                seg_in[current_floor-1] = 4'd8;
            end
            FINISH: begin
                seg_in[0] = 4'd8;
            end
        endcase
    end
    
    
    // 7-segment display multiplexing
    always @(posedge CLK10KHZ) begin
        digit_select <= digit_select + 1;
        DP <= 0;
        if(state == INITIAL) begin
            case (digit_select)
                3'd0: begin
                    AN <= 8'b11111110;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[0];
                end
                3'd1: begin
                    AN <= 8'b11111101;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[1];
                end
                3'd2: begin
                    AN <= 8'b11111011;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[2];
                end
                3'd3: begin
                    AN <= 8'b11110111;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[3];
                end
                3'd4: begin
                    AN <= 8'b11101111;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[4];
                end
                3'd5: begin
                    AN <= 8'b11011111;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[5];
                end
                3'd6: begin
                    AN <= 8'b10111111;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[6];
                end
                3'd7: begin
                    AN <= 8'b01111111;
                    {CG, CF, CE, CD, CC, CB, CA} <= seg_out[7];
                end
                default: begin
                    AN <= 8'b11111111; 
                    {CG, CF, CE, CD, CC, CB, CA} <= 7'b1111111;
                end
            endcase
        end
        else begin
            case (digit_select)
                3'd0: begin
                    if(current_floor == 1) begin
                        AN <= 8'b11111110;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[0];
                    end
                end
                3'd1: begin
                    if(current_floor == 2) begin
                        AN <= 8'b11111101;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[1];
                    end
                end
                3'd2: begin
                    if(current_floor == 3) begin
                        AN <= 8'b11111011;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[2];
                    end
                end
                3'd3: begin
                    if(current_floor == 4) begin
                        AN <= 8'b11110111;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[3];
                    end
                end
                3'd4: begin
                    if(current_floor == 5) begin
                        AN <= 8'b11101111;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[4];
                    end
                end
                3'd5: begin
                    if(current_floor == 6) begin
                        AN <= 8'b11011111;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[5];
                    end
                end
                3'd6: begin
                    if(current_floor == 7) begin
                        AN <= 8'b10111111;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[6];
                    end
                end
                3'd7: begin
                    if(current_floor == 8) begin
                        AN <= 8'b01111111;
                        {CG, CF, CE, CD, CC, CB, CA} <= seg_out[7];
                    end
                end
                default: begin
                    AN <= 8'b11111111; 
                    {CG, CF, CE, CD, CC, CB, CA} <= 7'b1111111;
                end
            endcase
        end
    end
    
    // SWITCH, led logic
    always @(SW or state or people_count) begin
        case(state)
            INITIAL: begin
                LED = SW;
            end
            LOAD, UNLOAD, UP, DOWN, OPEN, CLOSE: begin
                // LED represents the number of people in the elevator
                LED = 0;
                case (people_count)
                    5'd0:  LED = 16'b0000000000000000;
                    5'd1:  LED = 16'b0000000000000001;
                    5'd2:  LED = 16'b0000000000000011;
                    5'd3:  LED = 16'b0000000000000111;
                    5'd4:  LED = 16'b0000000000001111;
                    5'd5:  LED = 16'b0000000000011111;
                    5'd6:  LED = 16'b0000000000111111;
                    5'd7:  LED = 16'b0000000001111111;
                    5'd8:  LED = 16'b0000000011111111;
                    5'd9:  LED = 16'b0000000111111111;
                    5'd10: LED = 16'b0000001111111111;
                    5'd11: LED = 16'b0000011111111111;
                    5'd12: LED = 16'b0000111111111111;
                    5'd13: LED = 16'b0001111111111111;
                    5'd14: LED = 16'b0011111111111111;
                    5'd15: LED = 16'b0111111111111111;
                    5'd16: LED = 16'b1111111111111111;
                    default: LED = 16'b0000000000000000;
                endcase
            end
            default: begin
                LED = 16'b0;
            end
        endcase
    end
    
    
endmodule