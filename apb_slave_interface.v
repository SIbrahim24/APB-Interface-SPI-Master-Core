`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module apb_slave_interface(
			input pclk,
			input preset_n,
			input [`SPI_APB_ADDR_WIDTH-1:0]paddr,
			input pwrite,
			input psel,
			input penable,
			input [7:0]pwdata,
			input ss,
			input [7:0]data_miso,
			input receive_data,
			input tip,
			

			output reg [`SPI_APB_DATA_WIDTH-1:0]prdata,
			output mstr,
			output cpol,
			output cpha,
			output lsbfe,
			output spi_swai,
			output [2:0]sppr,
			output [2:0]spr,
			output reg spi_interrupt_request,
			output pready,
			output pslverr,
			output reg send_data,
			output reg[7:0]data_mosi,
			output [1:0]spi_mode
			);

reg [`SPI_REG_WIDTH-1:0]SPI_CR_1;
reg [`SPI_REG_WIDTH-1:0]SPI_CR_2;
reg [`SPI_REG_WIDTH-1:0]SPI_BR;
reg [`SPI_REG_WIDTH-1:0]SPI_SR;
reg [`SPI_REG_WIDTH-1:0]SPI_DR;

wire wr_en;
wire rd_en;

wire spie,spe,sptie,ssoe;
wire modfen;
wire modf;
wire spif,sptef;

reg[1:0] state, next_state;
reg[1:0] mode,next_mode;

//APB_FSM
parameter IDLE = 2'b00;
parameter SETUP = 2'b01;
parameter ENABLE = 2'b10;

always @(posedge pclk or  negedge preset_n)begin
	if(!preset_n)
		state <= IDLE;
	else
		state <= next_state;
end

always @(*)begin
	next_state = state;

	case(state)

	IDLE: begin
	    if(psel && !penable)
		next_state = SETUP;
	    else
		next_state = IDLE;
	end

	SETUP:begin
		if(psel && !penable)
			next_state = SETUP;
		else if(psel && penable)
			next_state = ENABLE;
		else
			next_state = IDLE;
	end

	ENABLE:begin
		if(psel)
			next_state = SETUP;
		else
			next_state = IDLE;
	end

	default: next_state = IDLE;
	endcase
end

//SPI_FSM

parameter RUN = 2'b00;
parameter WAIT= 2'b01;
parameter STOP= 2'b10;

always @(posedge pclk or negedge preset_n)begin
	if(!preset_n)begin
		mode <= RUN;
	end
	else 
		mode <= next_mode;
end

always @(*) begin
	next_mode = mode;

	case(mode)
	
	RUN:begin
		if(!spe)
			next_mode = WAIT;
		else
			next_mode = RUN;
	end

	WAIT:begin
		if(spi_swai)
			next_mode = STOP;
		else if(spe)	
			next_mode = RUN;
		else
			next_mode = WAIT;
	end

	STOP:begin
		if(!spi_swai)
			next_mode = WAIT;
		else if(spe)
			next_mode = RUN;
		else
			next_mode = STOP;
	end

	default: next_mode = RUN;
	
	endcase
end

assign spi_mode = mode;

assign pready = (state == ENABLE) ? 1'b1 : 1'b0;
assign pslverr= (state == ENABLE) ? (!tip) : 1'b0;

assign wr_en = (pwrite && (state == ENABLE)) ? 1'b1 : 1'b0;
assign rd_en = (!pwrite && (state == ENABLE)) ? 1'b1 : 1'b0;

wire [7:0] cr2_mask = 8'b00011011;
wire [7:0] br_mask  = 8'b01110111;

//SPI_CR_1 = control register 1

assign lsbfe = SPI_CR_1[0];
assign ssoe  = SPI_CR_1[1];
assign cpha  = SPI_CR_1[2];
assign cpol  = SPI_CR_1[3];
assign mstr  = SPI_CR_1[4];
assign sptie = SPI_CR_1[5];
assign spe   = SPI_CR_1[6];
assign spie  = SPI_CR_1[7];

always @(posedge pclk or negedge preset_n)begin
	if(!preset_n)
		SPI_CR_1 <= 8'h04;
	else begin
		if(wr_en)begin
			if(paddr == 3'b000)begin
				SPI_CR_1 <= pwdata;
			end
			else begin
				SPI_CR_1 <= SPI_CR_1;	
			end
		end
	end
end

//SPI_CR_2 = control register 2

assign spi_swai = SPI_CR_2[1];
assign modfen   = SPI_CR_2[4];


always @(posedge pclk or negedge preset_n) begin
	if(!preset_n)
		SPI_CR_2 <= 8'h00;
	else begin
		if(wr_en)begin
			if(paddr == 3'b001)begin
				SPI_CR_2 <= pwdata & cr2_mask;
			end
			else 
				SPI_CR_2 <= SPI_CR_2;
		end
	end
end

// SPI_BR = baud rate generator 

assign sppr = SPI_BR[6:4];
assign spr  = SPI_BR[2:0];

always @(posedge pclk or negedge preset_n)begin
	if(!preset_n)
		SPI_BR <= 8'h00;
	else begin
		if(wr_en)begin
			if(paddr == 3'b010)begin
				SPI_BR <= pwdata & br_mask;	
			end
			else 
				SPI_BR <= SPI_BR;
		end
		
	end
end

// status_flags

assign sptef = (SPI_DR == 8'h00) ? 1'b1 : 1'b0;
assign spif  = (SPI_DR != 8'h00) ? 1'b1 : 1'b0;
assign modf  = (!ss && mstr && modfen && !ssoe);

always @(*)begin
	if(!preset_n)
		SPI_SR <= 8'b00100000;
	else 
		SPI_SR <= {spif,1'b0,sptef,modf,4'b0};	
end

//SPI_DR = Data Register

always @(posedge pclk or negedge preset_n)begin
	if(!preset_n)
		SPI_DR <= 8'b0;
	else begin
		if(wr_en)begin
			if(paddr == 3'b101)begin
				SPI_DR <= pwdata;	
			end
			else begin
				SPI_DR <= SPI_DR;	
			end
		end
		else begin
			if((spi_mode == RUN || spi_mode == WAIT) && (SPI_DR == pwdata) && (SPI_DR != data_miso))
				SPI_DR <= 8'h00;
			else begin
				if((spi_mode == WAIT) || (spi_mode == RUN) && receive_data)
					SPI_DR <= data_miso;
				else 
					SPI_DR <= SPI_DR;
			end
		end
	end
end


//Read_data

always @(*)begin
	if(!rd_en)
		prdata = 8'b0;

	else begin
		case(paddr)
			3'd0: prdata = SPI_CR_1;
			3'd1: prdata = SPI_CR_2;
			3'd2: prdata = SPI_BR;
			3'd3: prdata = SPI_SR;
			3'd5: prdata = SPI_DR;

			default: prdata = 8'b0;
		endcase
	end
end


//send_data

always @(posedge pclk or negedge preset_n)begin
	if(!preset_n)
		send_data <= 1'b0;
	else begin
		if(wr_en)begin
		     send_data <= send_data;
		 end
		else if((spi_mode == WAIT || spi_mode == RUN) && (SPI_DR != data_miso) && (SPI_DR == pwdata))
				send_data <= 1'b1;
		else if((spi_mode == RUN || spi_mode == WAIT) && receive_data)
					send_data <= 1'b0;
		else
					send_data <= 1'b0;
			

end
end


//data_mosi
	
always @(posedge pclk or negedge preset_n)begin
	if(!preset_n)
		data_mosi <= 1'b0;
	else begin
	   if(wr_en)begin
	       data_mosi <= data_mosi;
        end
   		else if((SPI_DR == pwdata) && (SPI_DR != data_miso) && (spi_mode == RUN || spi_mode == WAIT))
			data_mosi <= SPI_DR;
		else
			data_mosi <= data_mosi;
	end
end
                            
//SPI_Interrupt_Request 

always @(*)begin
    spi_interrupt_request = 1'b0;

    if (!spie && !sptie) begin
        spi_interrupt_request = 1'b0;
    end
    else if (spie && !sptie) begin
        spi_interrupt_request = spif || modf;
    end
    else if (!spie && sptie) begin
        spi_interrupt_request = sptef;
    end
    else begin
        spi_interrupt_request = spif || modf || sptef;
    end
end

endmodule
