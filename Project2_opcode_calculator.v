`timescale 1ns / 1ps

module TOP_module(
    input CLK100MHZ,
    input [15:0]SW,
    output CA,
    output CB,
    output CC,
    output CD,
    output CE,
    output CF,
    output CG,
    output DP,
    output reg [7:0] AN,
    output reg [15:0] LED
    );
    
    reg [3:0] BCD; // 4 Switch bit to make 7-segment
    wire [7:0] ALU_result; // Save alu result output
    reg[19:0] clkcnt; // Reduce multiplexing frequency for display
    
    ALU alu (
        .A(SW[7:4]),
        .B(SW[3:0]),
        .OPCODE(SW[15:13]),
        .Z(ALU_result)
    );
    
    BCDTo7Segment bcd_to_7seg(
        .BCD(BCD),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG)
    );
    
    // LED logic
    always @(*) begin
        // If OPCODE is 3'b000 LED OFF except OPCODE LED
        if (SW[15:13] == 3'b000) begin
            LED = {SW[15:13], 13'b0000000000000};
        end
        // If OPCODE is 3'b001 LED OFF except OPCODE LED and A LED
        else if(SW[15:13] == 3'b001) begin
            LED = {SW[15:13], 5'b00000, SW[7:4], 4'b0000};
        end
        else begin
            LED = {SW[15:13], 5'b00000, SW[7:0]};
        end
    end
    
    // Clock division logic
    always @(posedge CLK100MHZ) begin
        clkcnt <= clkcnt + 1;
    end
    
    // Multiplexing logic for 7-segment display
    always @(posedge clkcnt[16]) begin
        case (clkcnt[19:17])
            // Result lower bit
            3'b000: begin
                AN <= 8'b11111110;
                BCD <= ALU_result[3:0]; // ALU result lower
            end
            // Result higher bit
            3'b001: begin
                // if OPCODE is 3'b000, 001, 010, 011, 100 turn off upper bit
                if((SW[15:13] == 3'b000) || (SW[15:13] == 3'b001) || (SW[15:13] == 3'b010) || (SW[15:13] == 3'b011) || (SW[15:13] == 3'b100)) begin
                    AN <= 8'b11111111; // Turn off
                end
                else begin
                    AN <= 8'b11111101;
                    BCD <= ALU_result[7:4]; // ALU result upper
                end
            end
            // B bit
            3'b010: begin
                // if OPCODE is 000, 001 (NO B)
                if((SW[15:13] == 3'b000) || (SW[15:13] == 3'b001)) begin
                    AN <= 8'b11111111; // Turn off
                end
                else begin
                    AN <= 8'b11111011;
                    BCD <= SW[3:0]; // Operand B
                end
            end
            // A bit
            3'b011: begin
                // if OPCODE is 000
                if(SW[15:13] == 3'b000) begin
                    AN <= 8'b11111111; // Turn off
                end
                else begin
                    AN <= 8'b11110111;
                    BCD <= SW[7:4]; // Operand A
                end
            end
            // OPCODE lower bit
            3'b101: begin
                AN <= 8'b11011111;
                BCD <= {3'b000, SW[13]}; // SW[13]
            end
            // OPCODE middle bit
            3'b110: begin
                AN <= 8'b10111111;
                BCD <= {3'b000, SW[14]}; // SW[14]
            end
            // OPCODE upper bit
            3'b111: begin
                AN <= 8'b01111111;
                BCD <= {3'b000, SW[15]}; // SW[15]
            end
        endcase
    end

endmodule

module ALU(
    input signed [3:0] A,
    input signed[3:0] B,
    input [2:0] OPCODE,
    output reg [7:0] Z
);

    reg signed [4:0] temp_result; // 5 bit temporary result for addition and subtraction

    always @(*) begin
        case (OPCODE)
            3'b000: Z = 0;                  // Zero
            3'b001: Z = {4'b0000, ~A};      // Not A
            3'b010: Z = {4'b0000, A & B};   // Bitwise And
            3'b011: Z = {4'b0000, A | B};   // Bitwise OR
            3'b100: Z = {4'b0000, A ^ B};   // Bitwise XOR
            3'b101: begin                   // Signed Addition
                temp_result = A+B;
                Z = {3'b000, temp_result};   
            end
            3'b110: begin                   // Signed Subtraction
                temp_result = A-B;
                Z = {3'b000, temp_result};    
            end
            3'b111: Z = A * B;              // Signed Multiplication
        endcase
    end
endmodule


module BCDTo7Segment(
    input [3:0] BCD,
    output reg CA,
    output reg CB,
    output reg CC,
    output reg CD,
    output reg CE,
    output reg CF,
    output reg CG
);

    always @(*) begin
        case (BCD)
            4'b0000: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000001; // 0
            4'b0001: {CA, CB, CC, CD, CE, CF, CG} = 7'b1001111; // 1
            4'b0010: {CA, CB, CC, CD, CE, CF, CG} = 7'b0010010; // 2
            4'b0011: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000110; // 3
            4'b0100: {CA, CB, CC, CD, CE, CF, CG} = 7'b1001100; // 4
            4'b0101: {CA, CB, CC, CD, CE, CF, CG} = 7'b0100100; // 5
            4'b0110: {CA, CB, CC, CD, CE, CF, CG} = 7'b0100000; // 6
            4'b0111: {CA, CB, CC, CD, CE, CF, CG} = 7'b0001111; // 7
            4'b1000: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000000; // 8
            4'b1001: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000100; // 9
            4'b1010: {CA, CB, CC, CD, CE, CF, CG} = 7'b0001000; // A
            4'b1011: {CA, CB, CC, CD, CE, CF, CG} = 7'b1100000; // b
            4'b1100: {CA, CB, CC, CD, CE, CF, CG} = 7'b0110001; // C
            4'b1101: {CA, CB, CC, CD, CE, CF, CG} = 7'b1000010; // d
            4'b1110: {CA, CB, CC, CD, CE, CF, CG} = 7'b0110000; // E
            4'b1111: {CA, CB, CC, CD, CE, CF, CG} = 7'b0111000; // F
            default: {CA, CB, CC, CD, CE, CF, CG} = 7'b1111111; // All off
        endcase
    end

endmodule
    