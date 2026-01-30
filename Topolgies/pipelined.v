module biquad_df2t_pipelined #(
    parameter DATA_WIDTH=16,
    parameter COEFF_WIDTH=16
) (
    input wire clk,
    input wire rst,
    input signed [DATA_WIDTH-1:0] x_in,
    input signed [COEFF_WIDTH-1:0] b0, b1, b2, a1, a2,
    output reg signed [DATA_WIDTH-1:0] y_out
);

reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] s1, s2;
reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] y_temp;
reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] y_temp_d1;
reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] s1_d1, s2_d1;

wire signed [DATA_WIDTH+COEFF_WIDTH-1:0] y_temp_next = (b0 * x_in) + s1;
wire signed [DATA_WIDTH+COEFF_WIDTH-1:0] s1_next = (b1 * x_in) - (a1 * y_temp_d1) + s2_d1;
wire signed [DATA_WIDTH+COEFF_WIDTH-1:0] s2_next = (b2 * x_in) - (a2 * y_temp_d1);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        s1 <= 0; s2 <= 0; y_temp <= 0; y_temp_d1 <= 0; s1_d1 <= 0; s2_d1 <= 0; y_out <= 0;
    end else begin
        y_temp <= y_temp_next;
        y_temp_d1 <= y_temp;
        y_out <= y_temp_d1 >>> COEFF_WIDTH;
        s1 <= s1_next;
        s2 <= s2_next;
        s1_d1 <= s1;
        s2_d1 <= s2;
    end
end

endmodule
