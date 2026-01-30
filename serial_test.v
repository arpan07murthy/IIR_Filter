`timescale 1ns / 1ps

module tb_iir_cascaded_serial;

    parameter DATA_WIDTH = 16;
    parameter COEFF_WIDTH = 16;

    reg clk;
    reg rst;
    reg signed [DATA_WIDTH-1:0] x_in;

    // Coefficients (example same as before)
    reg signed [COEFF_WIDTH-1:0] b0_1, b1_1, b2_1, a1_1, a2_1;
    reg signed [COEFF_WIDTH-1:0] b0_2, b1_2, b2_2, a1_2, a2_2;

    wire signed [DATA_WIDTH-1:0] y_out;

    iir_cascaded_serial #(DATA_WIDTH, COEFF_WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .b0_1(b0_1), .b1_1(b1_1), .b2_1(b2_1), .a1_1(a1_1), .a2_1(a2_1),
        .b0_2(b0_2), .b1_2(b1_2), .b2_2(b2_2), .a1_2(a1_2), .a2_2(a2_2),
        .y_out(y_out)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;
    reg signed [DATA_WIDTH-1:0] input_samples [0:99];

    initial begin
        rst = 1;
        #20;
        rst = 0;

        // Load coefficients Q1.15 (same as before)
        b0_1 = 2209;  b1_1 = 4419;  b2_1 = 2209;
        a1_1 = -37462; a2_1 = 13552;
        b0_2 = 2209;  b1_2 = 4419;  b2_2 = 2209;
        a1_2 = -37462; a2_2 = 13552;

        // Generate sine wave samples
        for(i=0; i<100; i=i+1) begin
            input_samples[i] = $rtoi( (2**14) * $sin(2*3.14159*50*i/1000) );
        end

        // Feed samples one per clock cycle, print output
        for(i=0; i<100; i=i+1) begin
            @(posedge clk);
            x_in = input_samples[i];
            @(negedge clk); // wait for output to stabilize
            $display("Input %d: %d, Output: %d", i, x_in, y_out);
        end

        $finish;
    end

endmodule
