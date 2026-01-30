module parallel_biquads #(
    parameter DATA_WIDTH=16,
    parameter COEFF_WIDTH=16
) (
    input wire clk,
    input wire rst,
    input signed [DATA_WIDTH-1:0] x_in,
    output reg signed [DATA_WIDTH-1:0] y_out,

    input signed [COEFF_WIDTH-1:0] b0_1, b1_1, b2_1, a1_1, a2_1,
    input signed [COEFF_WIDTH-1:0] b0_2, b1_2, b2_2, a1_2, a2_2
);

wire signed [DATA_WIDTH-1:0] y1, y2;

biquad_iir_df2t #(
    .DATA_WIDTH(DATA_WIDTH),
    .COEFF_WIDTH(COEFF_WIDTH)
) biquad1 (
    .clk(clk), .rst(rst), .x_in(x_in),
    .b0(b0_1), .b1(b1_1), .b2(b2_1), .a1(a1_1), .a2(a2_1),
    .y_out(y1)
);

biquad_iir_df2t #(
    .DATA_WIDTH(DATA_WIDTH),
    .COEFF_WIDTH(COEFF_WIDTH)
) biquad2 (
    .clk(clk), .rst(rst), .x_in(x_in),
    .b0(b0_2), .b1(b1_2), .b2(b2_2), .a1(a1_2), .a2(a2_2),
    .y_out(y2)
);

always @(posedge clk or posedge rst) begin
    if (rst)
        y_out <= 0;
    else
        y_out <= y1 + y2;
end

endmodule
