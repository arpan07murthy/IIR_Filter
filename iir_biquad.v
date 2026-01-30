module biquad_iir_df2t #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16
) (
    input  wire                         clk,
    input  wire                         rst,
    input  wire signed [DATA_WIDTH-1:0] x_in,
    input  wire signed [COEFF_WIDTH-1:0] b0,
    input  wire signed [COEFF_WIDTH-1:0] b1,
    input  wire signed [COEFF_WIDTH-1:0] b2,
    input  wire signed [COEFF_WIDTH-1:0] a1,
    input  wire signed [COEFF_WIDTH-1:0] a2,
    output reg  signed [DATA_WIDTH-1:0] y_out
);

    // State registers with extended precision for intermediate calculations
    reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] s1, s2;
    reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] y_temp;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s1 <= 0;
            s2 <= 0;
            y_out <= 0;
        end else begin
            // Calculate output sample (scaled back by COEFF_WIDTH)
            y_temp = (b0 * x_in) + s1;
            y_out <= y_temp >>> COEFF_WIDTH; // Right shift for fixed-point scaling

            // Update filter states for next cycle
            s1 <= (b1 * x_in) - (a1 * y_temp) + s2;
            s2 <= (b2 * x_in) - (a2 * y_temp);
        end
    end

endmodule
