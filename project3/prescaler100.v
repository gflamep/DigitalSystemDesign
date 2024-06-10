module prescaler100(
    input wire sig_in,
    output reg sig_out = 1'b0
    );
    
    reg [5:0] cnt = 6'd0;   // counter with initialization
    
    always @ (posedge sig_in) begin
        if(cnt == 6'd49) begin
            cnt <= 6'd0;
            sig_out <= ~sig_out; end
        else begin
            cnt <= cnt + 6'd1;
            sig_out <= sig_out; end
    end
    
endmodule