module VGA_Controller (
	input logic clk,
	input logic rst,
	input logic validData,
	input logic [11:0] data,
	output logic hsync,
	output logic vsync,
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue);
	
	logic [9:0] cntRow;
	logic [9:0] cntColumn;
	logic enable;
	logic [11:0] keepData;
	
	always_ff @(posedge clk) begin
		if (validData)
			keepData <= data;
	end
	
	always_comb begin	
	if ((cntRow <480) && (cntColumn <640)) begin
		red = keepData[11:8];
		green	= keepData[7:4];
		blue	= keepData[3:0];
		end
	else begin
		red = 4'b0000;
		green	= 4'b0000;
		blue	= 4'b0000;
		end
	end
	
	/* ~~~~~~~~~~ VGA Protocol ~~~~~~~~~~ */
	//toggle ff for frequency division by 2
	always_ff @(posedge clk or negedge rst) begin
		if (!rst)
			enable <= 1;
		else
			enable <=  (!enable);
	end
	
	//counter for every collumn
	always_ff @(posedge clk or negedge rst) begin
		if (!rst) 
			cntColumn <= 0;
		else 
			if (enable) 
				if (cntColumn == 799) 
					cntColumn <= 0;
				else 
					cntColumn <= cntColumn + 1;
	end
	
	//counter for every row
	always_ff @(posedge clk or negedge rst) begin
		if (!rst) 
			cntRow <= 0;
		else
			if (enable) 
				if (cntColumn == 799)
					cntRow <= cntRow + 1;
				else if (cntRow == 523) 
					cntRow <= 0;
	end
	
	//HSYNC
	always_ff @(posedge clk) begin
		if (cntColumn > 655 && cntColumn < 752)
			hsync <= 0;	
		else 
			hsync <= 1;
	end
	
	//VSYNC
	always_ff @(posedge clk) begin
		if (cntRow > 490 && cntRow < 493)
			vsync <= 0;
		else
			vsync <= 1;
	end
endmodule