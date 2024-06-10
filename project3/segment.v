module segment (
    input wire [3:0] Din,
    output reg [6:0] segout);

    // active-low version
    always @ (Din) begin
            case (Din)
                4'd0    : segout <= 7'b1000000;	// gfedcba
                4'd1    : segout <= 7'b1111001;	// 1
                4'd2    : segout <= 7'b0100100;	// 2
                4'd3    : segout <= 7'b0110000;	// 3
                4'd4    : segout <= 7'b0011001;	// 4
                4'd5    : segout <= 7'b0010010;	// 5
                4'd6    : segout <= 7'b0000010;	// 6
                4'd7    : segout <= 7'b1111000;	// 7
                4'd8    : segout <= 7'b0000000;	// 8
                4'd9    : segout <= 7'b0010000;	// 9
                4'd10   : segout <= 7'b0001000;	// A
                4'd11   : segout <= 7'b0000011;	// b
                4'd12   : segout <= 7'b1000110;	// C
                4'd13   : segout <= 7'b0100001;	// d
                4'd14   : segout <= 7'b0000100;	// e
                default : segout <= 7'b0001110;	// F
            endcase
    end

endmodule