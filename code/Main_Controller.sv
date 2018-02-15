module Main_Controller (
	input logic clk,
	input logic rst,
	input logic acceptInput,
	//codec inputs
	input logic validInput,
	input logic [15:0] voiceIn,
	//i2c_bus
	input logic transmitionOver,
	input logic ACK, 
	output logic rwi2c,
	output logic [6:0] addressi2c,
	output logic [15:0] datai2c,
	//HEX screen
	output logic up,
	output logic upRight,
	output logic upLeft,
	output logic down,
	output logic downLeft,
	output logic downRight,
	output logic middle,
	//VGA
	output logic [11:0] sendToVGA,
	output logic sendEnable);
	
	logic [14:0] buffer;
	logic [8:0] counter;
	logic [25:0] sum;
	logic [15:0] mean_value;
	logic [11:0] ColorsMem [6:0];
		
	logic [2:0] times_sent;
	logic [6:0] addressToSend;
	logic [15:0] Reset;
	logic [15:0] Activate;
	logic [15:0] sampleRate8kHz;
	logic [15:0] beMaster16bit;
	logic [15:0] powerOn;
	logic [15:0] disableDacMute;
	logic [15:0] enableMicrophone;
	
	/* 47 - 84: Configurng codec through I2C */
	always_ff @(posedge clk) begin
			if (!rst) begin	
				addressToSend <= 7'b0011010;
				Reset <= 16'b0001111000000000;
				Activate <= 16'b0001001000000001;
				sampleRate8kHz <= 16'b0001000000001100;
				beMaster16bit <= 16'b0000111001000010;
				powerOn <= 16'b0000110000000000;
				disableDacMute <= 16'b0000101000000001; //bit 0 was 0(now is 1)
				enableMicrophone <= 16'b0000100000010101;
			end
		end
	always_ff @(posedge clk) begin
		if (!rst) begin
			times_sent <= 0;
		end else 
			if (transmitionOver)
				times_sent<= times_sent +3'b001;
	end
	assign addressi2c = addressToSend;
	assign rwi2c = 1'b0;
	always_comb begin
		if (times_sent == 0)
			datai2c = Reset;
		else if (times_sent==1)
			datai2c = Activate;
		else if (times_sent==2)
			datai2c = sampleRate8kHz;
		else if (times_sent==3)
			datai2c = beMaster16bit;
		else if (times_sent==4)
			datai2c = powerOn;
		else if (times_sent==5)
			datai2c = disableDacMute;
		else 
			datai2c = enableMicrophone;
	end
	
	/* HEX screen configuration */
	/* if screen = 7, configuration is done */
	always_ff @(posedge clk) begin
		if (!rst) begin
			up <= 1'b1;
			down <= 1'b1;
			middle <= 1'b1;
			upLeft <= 1'b1;
			upRight <= 1'b1;
			downLeft <=1'b1;
			downRight <= 1'b1;
		end else 
			if (times_sent == 0) begin
				up <= 1'b0;
				down <= 1'b0;
				middle <= 1'b1;
				upLeft <= 1'b0;
				upRight <= 1'b0;
				downLeft <=1'b0;
				downRight <= 1'b0;
			end else if (times_sent == 1) begin
				up <= 1'b1;
				down <= 1'b1;
				middle <= 1'b1;
				upLeft <= 1'b1;
				upRight <= 1'b0;
				downLeft <=1'b1;
				downRight <= 1'b0;
			end else if (times_sent == 2) begin
				up <= 1'b0;
				down <= 1'b0;
				middle <= 1'b0;
				upLeft <= 1'b1;
				upRight <= 1'b0;
				downLeft <=1'b0;
				downRight <= 1'b1;
				end else if (times_sent == 3) begin
				up <= 1'b0;
				down <= 1'b0;
				middle <= 1'b0;
				upLeft <= 1'b1;
				upRight <= 1'b0;
				downLeft <=1'b1;
				downRight <= 1'b0;
				end else if (times_sent == 4) begin
				up <= 1'b1;
				down <= 1'b1;
				middle <= 1'b0;
				upLeft <= 1'b0;
				upRight <= 1'b0;
				downLeft <=1'b1;
				downRight <= 1'b0;
				end else if (times_sent == 5) begin
				up <= 1'b0;
				down <= 1'b0;
				middle <= 1'b0;
				upLeft <= 1'b0;
				upRight <= 1'b1;
				downLeft <=1'b1;
				downRight <= 1'b0;
			end else if (times_sent == 6) begin
				up <= 1'b0;
				down <= 1'b0;
				middle <= 1'b0;
				upLeft <= 1'b0;
				upRight <= 1'b1;
				downLeft <=1'b0;
				downRight <= 1'b0;
			end else if (times_sent == 7) begin
				up <= 1'b0;
				down <= 1'b1;
				middle <= 1'b1;
				upLeft <= 1'b1;
				upRight <= 1'b0;
				downLeft <=1'b1;
				downRight <= 1'b0;
			end
	end
		
	/* Saved colors */
	always_ff @(posedge clk) begin
		if (rst)
			ColorsMem[0] <= 12'b111100000000; //red 
			ColorsMem[1] <= 12'b111110000000; //orange
			ColorsMem[2] <= 12'b111111110000; //yellow
			ColorsMem[3] <= 12'b000011110000; //green
			ColorsMem[4] <= 12'b000011111111; //light blue
			ColorsMem[5] <= 12'b000000001111; //blue
			ColorsMem[6] <= 12'b111100001111; //purple
	end	
	
	/* Calculate Mean Value of Voice */
	always_ff @(posedge clk) begin
		if (!rst) begin
			sum <= 0;
			counter<=0;
			buffer <= 0;
		end else begin
			if ( counter == 0) begin
				if (validInput) begin
					sum <= sum + buffer + voiceIn[14:0] - ~voiceIn[14:0] + 1'b1;
					counter <= counter + 1;
				end
			end else if ( counter < 350) begin
				if (validInput) begin
					sum <= sum + voiceIn[14:0] - ~voiceIn[14:0] + 1'b1;
					counter <= counter + 1;
				end
			end else if (counter == 350) begin
				mean_value<=sum/351;
				sum <= 0;
				counter <= 0;
				if (validInput)
					buffer <= voiceIn[14:0] - ~voiceIn[14:0] + 1'b1;
			end
		end
	end
	
	/* Send data to VGA Controller */
	assign sendEnable = 1;
	always_comb
	begin
		if (acceptInput)
			sendToVGA=ColorsMem[6];
		else if (mean_value < 110)
			sendToVGA=ColorsMem[0];
		else if (mean_value < 120)
			sendToVGA=ColorsMem[1];
		else if (mean_value < 130)
			sendToVGA=ColorsMem[2];
		else if (mean_value < 140)
			sendToVGA=ColorsMem[3];
		else if (mean_value < 150)
			sendToVGA=ColorsMem[4];
		else if (mean_value < 160)
			sendToVGA=ColorsMem[5];
		else 
			sendToVGA=ColorsMem[6];
	end
endmodule