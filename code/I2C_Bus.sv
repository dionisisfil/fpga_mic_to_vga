module I2C_Bus (
	input logic clk,
	input logic rst,
	input logic begin_transmition,
	input logic [15:0] dataToSend,
	input logic [6:0] Receiver_address,
	input logic r_w,
	output logic transmition_over,
	output logic SCLK,
	output logic ACK,
	inout SDA);
	
	enum logic [2:0] {idle=3'b000, start=3'b001, address=3'b010, acknowledge=3'b011, register=3'b100, data=3'b101, stop=3'b110} state;
	enum logic [1:0] {regi = 2'b00, dat = 2'b01, stopstep = 2'b10} next_step;
	
	
	logic [7:0] registerToSend;
	logic [4:0] counter;
	logic [1:0] ACK_count;
	logic SCL_neg_edge, prev_SCL, SCL, Q1, Q2, Q3, Q4, Q5, data_out, ACK_buff;
	logic scl_out, begin_trans_neg_edge, buffed_begin_trans, tri_state;
	
	/* The command has been transfered successfully */
	assign transmition_over = (state==idle && counter == 5'b00011 && ACK_count==2'b11)? 1'b1:1'b0;

	/* negative edge means that we start transfer data */
	always_ff @(posedge clk) begin
		buffed_begin_trans <= begin_transmition;
	end
	assign begin_trans_neg_edge = !begin_transmition & buffed_begin_trans;
	
	/*32 - 63 Devide clock by 32 (result 400KHz for I2C) */
	always_ff @(posedge clk) begin
		if (!rst)
			Q1 <= 1'b1;
		else 
			Q1 <= ~Q1;
	end
	always_ff @(posedge Q1) begin
		if (!rst)
			Q2 <= 1'b1;
		else 
			Q2 <= ~Q2;
	end
	always_ff @(posedge Q2) begin
		if (!rst)
			Q3 <= 1'b1;
		else 
			Q3 <= ~Q3;
	end
	always_ff @(posedge Q3) begin
		if (!rst)
			Q4 <= 1'b1;
		else 
			Q4 <= ~Q4;
	end
	always_ff @(posedge Q4) begin
		if (!rst)
			Q5 <= 1'b1;
		else 
			Q5 <= ~Q5;
	end
	assign SCL = (state != idle)? Q5:1'b1;
	
	/* finding negative edge of 400KHz clock */
	always_ff @(posedge clk) begin
		prev_SCL <= SCL;
	end
	assign SCL_neg_edge = ~SCL & prev_SCL;
	
	/* FSM to drive SDAT & SCLK */
	always_ff @(posedge clk) begin
		if (!rst) 
			state <= idle;
		else
			case (state)
				idle: 
				begin
					if (begin_trans_neg_edge) begin
						registerToSend [7:1] <= Receiver_address;
						registerToSend [0] <= r_w;
						state <= start;
					end
					counter <= 0;
					tri_state <= 1'b1;
					scl_out <= 1'b1;
					data_out <= 1'b1;
					ACK_buff <= 1'b1;
					ACK_count <=2'b00;
				end
				start: 
				if (SCL_neg_edge) begin
					if (counter == 0) begin
						data_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 1) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else begin
						counter <= 0;
						next_step <= regi;
						state <= address;
					end
				end
				address: 
				if (SCL_neg_edge) begin
					if (counter == 0) begin
						data_out <= registerToSend[7];
						counter <= counter + 5'b00001;
					end else if (counter == 1) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 2) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 3) begin
						data_out <= registerToSend[6];
						counter <= counter + 5'b00001;
					end else if (counter == 4) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 5) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 6) begin
						data_out <= registerToSend[5];
						counter <= counter + 5'b00001;
					end else if (counter == 7) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 8) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 9) begin
						data_out <= registerToSend[4];
						counter <= counter + 5'b00001;
					end else if (counter == 10) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 11) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter ==12) begin
						data_out <= registerToSend[3];
						counter <= counter + 5'b00001;
					end else if (counter == 13) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 14) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 15) begin
						data_out <= registerToSend[2];
						counter <= counter + 5'b00001;
					end else if (counter == 16) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 17) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 18) begin
						data_out <= registerToSend[1];
						counter <= counter + 5'b00001;
					end else if (counter == 19) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 20) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 21) begin
						data_out <= registerToSend[0];
						counter <= counter + 5'b00001;
					end else if (counter == 22) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 23) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else begin
						counter <= 0;
						state <= acknowledge;
						next_step <= regi;
					end							
				end
				acknowledge: 
				if (SCL_neg_edge) begin
					if (counter == 0) begin
						data_out <= 1'b1;
						tri_state <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 1) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 2) begin
						ACK_buff <= SDA;
						counter <= counter + 5'b00001;
					end else if (counter == 3) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 4) begin
						tri_state <= 1'b1;
						data_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else begin
						if (ACK_buff == 0)  begin
							ACK_count <= ACK_count + 2'b01;
							if (next_step == regi) begin
								counter <= 0;
								registerToSend <= dataToSend[15:8];
								state <= register;
							end else if (next_step == dat) begin
								counter <= 0;
								registerToSend <= dataToSend[7:0];
								state <= data;
							end else if (next_step == stopstep) begin
								counter <= 0;
								state <= stop;
								//registerToSend <= dataToSend[7:0];
							end
						end else
							state <= stop;
					end
				end
				register: 
				if (SCL_neg_edge) begin
					if (counter == 0) begin
						data_out <= registerToSend[7];
						counter <= counter + 5'b00001;
					end else if (counter == 1) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 2) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 3) begin
						data_out <= registerToSend[6];
						counter <= counter + 5'b00001;
					end else if (counter == 4) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 5) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 6) begin
						data_out <= registerToSend[5];
						counter <= counter + 5'b00001;
					end else if (counter == 7) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 8) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 9) begin
						data_out <= registerToSend[4];
						counter <= counter + 5'b00001;
					end else if (counter == 10) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 11) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter ==12) begin
						data_out <= registerToSend[3];
						counter <= counter + 5'b00001;
					end else if (counter == 13) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 14) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 15) begin
						data_out <= registerToSend[2];
						counter <= counter + 5'b00001;
					end else if (counter == 16) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 17) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 18) begin
						data_out <= registerToSend[1];
						counter <= counter + 5'b00001;
					end else if (counter == 19) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 20) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 21) begin
						data_out <= registerToSend[0];
						counter <= counter + 5'b00001;
					end else if (counter == 22) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 23) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else begin
						counter <= 0;
						state <= acknowledge;
						next_step <= dat;
					end
				end
				data:
				if (SCL_neg_edge) begin
					if (counter == 0) begin
						data_out <= registerToSend[7];
						counter <= counter + 5'b00001;
					end else if (counter == 1) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 2) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 3) begin
						data_out <= registerToSend[6];
						counter <= counter + 5'b00001;
					end else if (counter == 4) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 5) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 6) begin
						data_out <= registerToSend[5];
						counter <= counter + 5'b00001;
					end else if (counter == 7) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 8) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 9) begin
						data_out <= registerToSend[4];
						counter <= counter + 5'b00001;
					end else if (counter == 10) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 11) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter ==12) begin
						data_out <= registerToSend[3];
						counter <= counter + 5'b00001;
					end else if (counter == 13) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 14) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 15) begin
						data_out <= registerToSend[2];
						counter <= counter + 5'b00001;
					end else if (counter == 16) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 17) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 18) begin
						data_out <= registerToSend[1];
						counter <= counter + 5'b00001;
					end else if (counter == 19) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 20) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else if (counter == 21) begin
						data_out <= registerToSend[0];
						counter <= counter + 5'b00001;
					end else if (counter == 22) begin
						scl_out <= 1'b1;
						counter <= counter + 5'b00001;
					end else if (counter == 23) begin
						scl_out <= 1'b0;
						counter <= counter + 5'b00001;
					end else begin
						counter <= 0;
						state <= acknowledge;
						next_step <= stopstep;
					end
				end
				stop: 
				if (SCL_neg_edge) begin
					if (counter == 0)
						scl_out <= 1'b1;
					else if (counter == 1)
						data_out <= 1'b1;
					else begin
						counter <= 0;
						state <= idle;
					end
					counter <= counter + 5'b00001;
				end
			endcase
	end
	
	/* Outputs */
	assign ACK = ACK_buff;
	assign SCLK = scl_out;
	assign SDA = (!tri_state)? 1'bz: data_out;
endmodule