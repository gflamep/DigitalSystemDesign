`timescale 1ns/1ps

module tb_ALU;

    reg signed [3:0] A;
    reg signed [3:0] B;
    reg [2:0] OPCODE;
    wire [7:0] Z;

    // Instantiate the ALU module
    ALU alu (
        .A(A),
        .B(B),
        .OPCODE(OPCODE),
        .Z(Z)
    );

    initial begin
        // Test case 1: No operation (OPCODE 000)
        OPCODE = 3'b000; A = 4'b0101; B = 4'b0011; // A = 5, B = 3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 2: NOT A (OPCODE 001)
        OPCODE = 3'b001; A = 4'b1100; B = 4'b0101; // A = -4, B = 5 (not used)
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 3: A AND B (OPCODE 010)
        OPCODE = 3'b010; A = 4'b0110; B = 4'b1101; // A = 6, B = -3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 4: A OR B (OPCODE 011)
        OPCODE = 3'b011; A = 4'b0110; B = 4'b1101; // A = 6, B = -3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 5: A XOR B (OPCODE 100)
        OPCODE = 3'b100; A = 4'b0110; B = 4'b1101; // A = 6, B = -3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 6: A + B (OPCODE 101)
        OPCODE = 3'b101; A = 4'b0110; B = 4'b1101; // A = 6, B = -3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 7: A + B (OPCODE 101)
        OPCODE = 3'b101; A = 4'b1111; B = 4'b0001; // A = -1, B = 1
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 8: A - B (OPCODE 110)
        OPCODE = 3'b110; A = 4'b0110; B = 4'b1101; // A = 6, B = -3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 9: A - B (OPCODE 110)
        OPCODE = 3'b110; A = 4'b0001; B = 4'b0011; // A = 1, B = 3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        // Test case 10: A * B (OPCODE 111)
        OPCODE = 3'b111; A = 4'b0110; B = 4'b1101; // A = 6, B = -3
        #10;
        $display("OPCODE = %b, A = %b, B = %b, Z = %b", OPCODE, A, B, Z);

        $finish;
    end
endmodule

