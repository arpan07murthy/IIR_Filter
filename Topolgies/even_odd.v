module even_odd_iir #(
    parameter DATA_WIDTH=16,
    parameter COEFF_WIDTH=16
) (
    input wire clk,
    input wire rst,
    input signed [DATA_WIDTH-1:0] x_in,
    output reg signed [DATA_WIDTH-1:0] y_out,

    input signed [COEFF_WIDTH-1:0] b0_even, b1_even, b2_even, a1_even, a2_even,
    input signed [COEFF_WIDTH-1:0] b0_odd,  b1_odd,  b2_odd,  a1_odd,  a2_odd
);

reg sample_toggle;
reg signed [DATA_WIDTH-1:0] x_even, x_odd;
wire signed [DATA_WIDTH-1:0] y_even, y_odd;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sample_toggle <= 0;
        x_even <= 0; x_odd <= 0;
        y_out <= 0;
    end else begin
        sample_toggle <= ~sample_toggle;
        if (sample_toggle == 0)
            x_even <= x_in;
        else
            x_odd <= x_in;
    end
end

biquad_iir_df2t #(
    .DATA_WIDTH(DATA_WIDTH), .COEFF_WIDTH(COEFF_WIDTH)
) even_biquad (
    .clk(clk), .rst(rst), .x_in(x_even),
    .b0(b0_even), .b1(b1_even), .b2(b2_even),
    .a1(a1_even), .a2(a2_even),
    .y_out(y_even)
);

biquad_iir_df2t #(
    .DATA_WIDTH(DATA_WIDTH), .COEFF_WIDTH(COEFF_WIDTH)
) odd_biquad (
    .clk(clk), .rst(rst), .x_in(x_odd),
    .b0(b0_odd), .b1(b1_odd), .b2(b2_odd),
    .a1(a1_odd), .a2(a2_odd),
    .y_out(y_odd)
);

always @(posedge clk or posedge rst) begin
    if (rst)
        y_out <= 0;
    else
        y_out <= (sample_toggle == 0) ? y_even : y_odd;
end

endmodule
