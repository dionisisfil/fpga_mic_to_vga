module Codec_Interface(
	input logic clk,
	input logic rst,
	input logic listening,
	input logic audio_sampl,
	input logic audio_data,
	input logic bclk,
	output logic MCLK,
	output logic valid_data,
	output logic [15:0] data_out);

	logic mqcl, mqcl1;
	logic Q1, Q2, Q3;
	logic AS1, AS2,AS3;
	logic BClock_raising_edge, ADCLRC_falling_edge;
	logic [15:0] data;
	logic enable;
	logic [4:0] i;
	logic data_synch1, data_synch2, data_synch3;
	logic accept;
		
	/* ADCLRC synchronizer */
	always_ff @(posedge clk) begin
		AS1<=audio_sampl;
		AS2<=AS1;
		AS3<=AS2;
	end	
	
	/* Clock synchronizer */
	always_ff @(posedge clk) begin
		Q1<=bclk;
		Q2<=Q1;
		Q3<=Q2;
	end
	
	/* Data synchronizer */
	always_ff @(posedge clk) begin
			data_synch1 <= audio_data;
			data_synch2 <= data_synch1;
			data_synch3 <= data_synch2;
	end	
	
	/* Defining MCLK to 12.5MHz */
	always_ff @(posedge clk) begin
		if (!rst)
			mqcl <= 1'b1;
		else 
			mqcl <= ~mqcl;
	end
	always_ff @(posedge mqcl) begin
		if (!rst)
			mqcl1 <= 1'b1;
		else 
			mqcl1 <= ~mqcl1;
	end
	
	assign BClock_raising_edge = Q2 & ~Q3;	
	assign ADCLRC_falling_edge = AS3 & ~AS2;
	
	/* enable = 1 while there are data */
	always_ff @(posedge clk) begin
		if (!rst) begin
			enable <= 0;
			accept <= 0;
		end else
			if (!listening) begin 
				if (ADCLRC_falling_edge) //accept Left channel data from I2S mode
					accept <= 1;
				if ((BClock_raising_edge & !AS3) && i==0 && accept) begin //writing input data
					enable <= 1;
				end else if (i==16) begin
					enable <= 0;		
					accept <= 0;
				end
			end
	end
	
	/* Data Bits Counter */
	always_ff @(posedge clk) begin
		if (!rst)
			i <= 0;
		else
			if (enable)
				i <= i + 5'b00001;
			else 
				i <= 0;
	end
	
	/* Writting data into a register */
	always_ff @(posedge clk) begin
		if (enable && i<16) begin
			data[15:1] <= data[14:0];
			data[0]<=data_synch3;	
			end
	end
	
	/* when all 16bits are written send them to main controller */
	always_ff @(posedge clk) begin
		if (i==15)
			valid_data<= 1;
		else 
			valid_data<= 0;
	end
	
	/* Outputs */
	assign	data_out = data;
	assign MCLK = mqcl1;
endmodule