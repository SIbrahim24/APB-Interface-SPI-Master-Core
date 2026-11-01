`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module apb_interface_tb;
	reg pclk;
	reg preset_n;
	reg [`SPI_APB_ADDR_WIDTH-1:0]paddr;
	reg [`SPI_APB_DATA_WIDTH-1:0]pwdata;
	reg psel;
	reg penable;
	reg pwrite;
	reg ss;
	reg receiver_data;
	reg [7:0] data_miso;
	reg tip;

	wire [`SPI_APB_DATA_WIDTH-1:0]prdata;
	wire pready;
	wire pslverr;
	wire spi_interrupt_request;
	wire send_data;
	wire mstr;
	wire cpol;
	wire cpha;
	wire lsbfe;
	wire spi_swai;
	wire [7:0] data_mosi;
	wire [1:0] spi_mode;
	wire [2:0] sppr;
	wire [2:0] spr;
	
	apb_slave_interface DUT(
			.pclk(pclk),
			.preset_n(preset_n),
			.paddr(paddr),
			.psel(psel),
			.penable(penable),
			.pwrite(pwrite),
			.pwdata(pwdata),
			.ss(ss),
			.receive_data(receiver_data),
			.data_miso(data_miso),
			.tip(tip),
			.prdata(prdata),
			.pready(pready),
			.pslverr(pslverr),
			.spi_interrupt_request(spi_interrupt_request),
			.send_data(send_data),
			.mstr(mstr),
			.cpol(cpol),
			.cpha(cpha),
			.lsbfe(lsbfe),
			.spi_swai(spi_swai),
			.data_mosi(data_mosi),
			.spi_mode(spi_mode),
			.sppr(sppr),
			.spr(spr)
			);

	initial begin
		pclk = 1'b0;
		forever #5 pclk = ~pclk;
	end

	task reset();
		begin
			@(negedge pclk)
			preset_n = 1'b0;
			@(negedge pclk)
			preset_n = 1'b1;
		end
	endtask

	task initialization();
		begin
			pclk = 1'b0;
			preset_n = 1'b0;
			paddr = 3'b000;
			pwrite = 1'b0;
			psel = 1'b1;
			penable = 1'b0;
			pwdata = 8'b0;
			ss = 1'b1;
			data_miso = 8'b0;	
			receiver_data = 1'b0;
			tip = 1'b0;
		end
	endtask
			
	task write_register(input [7:0] ctrl_reg1, input [7:0] ctrl_reg2, input [7:0] baud_reg); 
		begin
	   		@(negedge pclk) // CR_1
			paddr  = 3'b000;
			pwrite = 1'b1;
			psel   = 1'b1;
			penable= 1'b0;
			pwdata = ctrl_reg1;

			@(negedge pclk)
			paddr = 3'b000;
			pwrite= 1'b1;
			psel  = 1'b1;
			penable= 1'b1;
			pwdata = ctrl_reg1;

			@(negedge pclk)
			wait(pready)
			penable = 1'b0;
		
			@(negedge pclk) // CR_2
		        paddr  = 3'b001;
			pwrite = 1'b1;
			psel   = 1'b1;
			penable= 1'b0;
			pwdata = ctrl_reg2;

			@(negedge pclk)
			paddr = 3'b001;
			pwrite= 1'b1;
			psel  = 1'b1;
			penable= 1'b1;
			pwdata = ctrl_reg2;

			@(negedge pclk)
			wait(pready)
			penable = 1'b0;
		
			@(negedge pclk) // Baudrate_reg
		        paddr  = 3'b010;
			pwrite = 1'b1;
			psel   = 1'b1;
			penable= 1'b0;
			pwdata = baud_reg;

			@(negedge pclk)
			paddr = 3'b010;
			pwrite= 1'b1;
			psel  = 1'b1;
			penable= 1'b1;
			pwdata = baud_reg;
			
			
			@(negedge pclk)
			wait(pready)
			penable = 1'b0;
		end
	endtask


	task write_data_reg(input [7:0]data_reg);
	begin
		@(negedge pclk) // data_reg
		paddr = 3'b101;
		pwrite= 1'b1;
		psel  = 1'b1;
		penable= 1'b0;
		pwdata = data_reg;
	
		@(negedge pclk)
		paddr = 3'b101;
		pwrite = 1'b1;
		psel  = 1'b1;
		penable = 1'b1;
		pwdata = data_reg;

		@(negedge pclk)
		wait(pready)
		penable = 1'b0;
	
	end
	endtask

	
	task read_register(input[2:0] address);
	begin
		@(negedge pclk)
		paddr = address;
		pwrite = 1'b0;
		psel = 1'b1;
		penable = 1'b0;

		@(negedge pclk)
		paddr = address;
		pwrite = 1'b0;
		psel = 1'b1;
		penable = 1'b1;

		@(negedge pclk)
		wait(pready)
		penable = 1'b0;
	end
	endtask

	initial begin
		initialization;
		reset;
		ss = 1'b0;
		receiver_data = 1'b1;
		tip = 1'b1;
		data_miso = 8'hFA;
		write_register(8'b01011101, 8'b00000000, 8'b00000001);
		write_data_reg(8'hDD);
		read_register(3'b000);
		read_register(3'b001);
		read_register(3'b010);
		read_register(3'b011);
		read_register(3'b101);

	end

	initial begin
		#4000 $finish();
	end
endmodule
