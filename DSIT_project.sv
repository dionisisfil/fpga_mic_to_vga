module DSIT_project (
	input logic clk,
	input logic rst,
	//Codec Interdace 
	input logic BCLK,
	input logic ADCLRC,
	input logic ADCDAT,
	input logic acceptInput,
	input logic begin_trans,
	output logic MCLK,
	//HEX Screen for memory module
	output logic up,
	output logic upRight,
	output logic upLeft,
	output logic down,
	output logic downLeft,
	output logic downRight,
	output logic middle,
	//I2C Bus Interdace
	output logic SCL,
	inout SDA,
	//VGA Interdace
	output logic hsync,
	output logic vsync,
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue);
	
	logic validProcessedInputToMemory;
	logic [15:0] ProcessedInputToMemory;
	logic validMemoryToVGA;
	logic [11:0] memoryToVGA;
	logic [15:0] dataToI2C;
	logic [6:0] addressToI2C;
	logic rwToI2C, trans_over, ACK;
	
	I2C_Bus
	i2c(
		.clk (clk),
		.rst (rst),
		.begin_transmition (begin_trans),
		.dataToSend (dataToI2C),
		.ACK (ACK),
		.Receiver_address (addressToI2C),
		.r_w (rwToI2C),
		.transmition_over (trans_over),
		.SCLK (SCL),
		.SDA(SDA));
	
	Codec_Interface
	codec(
		.clk (clk),
		.rst (rst),
		.listening (acceptInput),
		.audio_sampl (ADCLRC),
		.audio_data (ADCDAT),
		.bclk (BCLK),
		. MCLK (MCLK),
		.valid_data (validProcessedInputToMemory),
		.data_out (ProcessedInputToMemory));
	
	Main_Controller
	contr(
		.clk (clk),
		.rst (rst),
		.acceptInput (acceptInput),
		.up (up),
		.upRight (upRight),
		.upLeft (upLeft),
		.down (down),
		.downLeft (downLeft),
		.downRight (downRight),
		.middle (middle),
		.ACK (ACK),		
		.validInput (validProcessedInputToMemory),
		.voiceIn (ProcessedInputToMemory),
		.transmitionOver (trans_over),
		.rwi2c (rwToI2C),
		.addressi2c (addressToI2C),
		.datai2c (dataToI2C),
		.sendToVGA (memoryToVGA),
		.sendEnable (validMemoryToVGA));

	VGA_Controller
	vga(
		.clk (clk),
		.rst (rst),
		.validData (validMemoryToVGA),
		.data (memoryToVGA),
		.hsync (hsync),
		.vsync (vsync),
		.red (red),
		.blue (blue),
		.green (green));
	
endmodule