module iir_cascaded_serial #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16
) (
    input  wire                         clk,
    input  wire                         rst,
    input  wire signed [DATA_WIDTH-1:0] x_in,
    // Coefficients for first biquad
    input  wire signed [COEFF_WIDTH-1:0] b0_1,
    input  wire signed [COEFF_WIDTH-1:0] b1_1,
    input  wire signed [COEFF_WIDTH-1:0] b2_1,
    input  wire signed [COEFF_WIDTH-1:0] a1_1,
    input  wire signed [COEFF_WIDTH-1:0] a2_1,
    // Coefficients for second biquad
    input  wire signed [COEFF_WIDTH-1:0] b0_2,
    input  wire signed [COEFF_WIDTH-1:0] b1_2,
    input  wire signed [COEFF_WIDTH-1:0] b2_2,
    input  wire signed [COEFF_WIDTH-1:0] a1_2,
    input  wire signed [COEFF_WIDTH-1:0] a2_2,
    output wire signed [DATA_WIDTH-1:0] y_out
);

    wire signed [DATA_WIDTH-1:0] stage1_out;

    // First biquad instance
    biquad_iir_df2t #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEFF_WIDTH(COEFF_WIDTH)
    ) biquad1 (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .b0(b0_1),
        .b1(b1_1),
        .b2(b2_1),
        .a1(a1_1),
        .a2(a2_1),
        .y_out(stage1_out)
    );

    // Second biquad instance cascaded
    biquad_iir_df2t #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEFF_WIDTH(COEFF_WIDTH)
    ) biquad2 (
        .clk(clk),
        .rst(rst),
        .x_in(stage1_out),
        .b0(b0_2),
        .b1(b1_2),
        .b2(b2_2),
        .a1(a1_2),
        .a2(a2_2),
        .y_out(y_out)
    );

endmodule
