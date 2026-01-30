`timescale 1ns / 1ps

module tb_even_odd_filter;

    parameter DATA_WIDTH = 16;
    parameter COEFF_WIDTH = 16;

    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    reg rst;
    reg signed [DATA_WIDTH-1:0] x_in;
    wire signed [DATA_WIDTH-1:0] y_out;

    // Fixed-point coefficients (replace with your MATLAB converted values)
	//Give both for the rest, give only first one for pipelined - rename arrays accordingly
    reg signed [COEFF_WIDTH-1:0] b0_even = 2209, b1_even = 4419, b2_even = 2209;
    reg signed [COEFF_WIDTH-1:0] a1_even = -37462, a2_even = 13552;

    reg signed [COEFF_WIDTH-1:0] b0_odd = 2209, b1_odd = 4419, b2_odd = 2209;
    reg signed [COEFF_WIDTH-1:0] a1_odd = -37462, a2_odd = 13552;

    integer i;

    reg signed [DATA_WIDTH-1:0] input_samples [0:99]; // 100 samples
	
	
	//Use the appropriate dut initialisation for each. DO NOT RUN ALL AT ONCE
	cascade_series #(DATA_WIDTH, COEFF_WIDTH) dut (
		.clk(clk),
		.rst(rst),
		.x_in(x_in),
		.y_out(y_out),
		.b0_1(b0_1), .b1_1(b1_1), .b2_1(b2_1), .a1_1(a1_1), .a2_1(a2_1),
		.b0_2(b0_2), .b1_2(b1_2), .b2_2(b2_2), .a1_2(a1_2), .a2_2(a2_2)
	);

	parallel_biquads #(DATA_WIDTH, COEFF_WIDTH) dut (
		.clk(clk),
		.rst(rst),
		.x_in(x_in),
		.y_out(y_out),
		.b0_1(b0_1), .b1_1(b1_1), .b2_1(b2_1), .a1_1(a1_1), .a2_1(a2_1),
		.b0_2(b0_2), .b1_2(b1_2), .b2_2(b2_2), .a1_2(a1_2), .a2_2(a2_2)
	);

	biquad_df2t_pipelined #(DATA_WIDTH, COEFF_WIDTH) dut (
		.clk(clk),
		.rst(rst),
		.x_in(x_in),
		.b0(b0), .b1(b1), .b2(b2),
		.a1(a1), .a2(a2),
		.y_out(y_out)
	);
	
    even_odd_iir #(DATA_WIDTH, COEFF_WIDTH) dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out(y_out),
        .b0_even(b0_even), .b1_even(b1_even), .b2_even(b2_even), .a1_even(a1_even), .a2_even(a2_even),
        .b0_odd(b0_odd), .b1_odd(b1_odd), .b2_odd(b2_odd), .a1_odd(a1_odd), .a2_odd(a2_odd)
    );

    initial begin
        rst = 1;
        x_in = 0;
        #20;
        rst = 0;

        // Generate 50 Hz sine wave scaled for fixed-point input (-1 to 1 range)
        for (i = 0; i < 100; i = i + 1) begin
            input_samples[i] = $rtoi( (2**14) * $sin(2*3.1415926535*50*i/1000) );
        end

        // Feed input samples one per clock cycle and print outputs
        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            x_in <= input_samples[i];
            @(negedge clk);
            $display("Sample %0d: Input = %d, Output = %d", i, x_in, y_out);
        end

        $stop;
    end

endmodule
