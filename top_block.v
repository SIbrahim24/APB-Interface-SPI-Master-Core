module top(
        input pclk,
        input preset_n,
        input [2:0] paddr,
        input pwrite,
        input psel,
        input penable,
        input [7:0]pwdata,
        input miso,

        output ss,
        output sclk,
        output spi_interrupt_request,
        output mosi,
        output [7:0]prdata,
        output pready,
        output pslverr
        );

        wire [1:0] spi_mode;
        wire spi_swai;
        wire [2:0] sppr;
        wire [2:0] spr;
        wire cpol;
        wire cpha;
        wire lsbfe;
        wire mstr;


        wire send_data;
        wire receive_data;
        wire tip;


        wire miso_rec_pos_sclk;
        wire miso_rec_neg_sclk;
        wire mosi_send_pos_sclk;
        wire mosi_send_neg_sclk;


        wire [11:0] baud_rate_divisor;
        wire [7:0] data_mosi;
        wire [7:0] data_miso;



        baud_rate_generator baud(
                          .pclk(pclk),
                          .preset_n(preset_n),
                          .spi_mode(spi_mode),
                          .spi_swai(spi_swai),
                          .sppr(sppr),
                          .spr(spr),
                          .cpol(cpol),
                          .cpha(cpha),
                          .ss(ss),
                          .sclk(sclk),
                          .miso_rec_pos_sclk(miso_rec_pos_sclk),
                          .miso_rec_neg_sclk(miso_rec_neg_sclk),
                          .mosi_send_pos_sclk(mosi_send_pos_sclk),
                          .mosi_send_neg_sclk(mosi_send_neg_sclk),
                          .baud_rate_divisor(baud_rate_divisor)
                        );

        slave_control_select slave(
                        .pclk(pclk),
                        .preset_n(preset_n),
                        .spi_mode(spi_mode),
                        .mstr(mstr),
                        .spi_swai(spi_swai),
                        .send_data(send_data),
                        .baud_rate_divisor(baud_rate_divisor),
                        .ss(ss),
                        .receive_data(receive_data),
                        .tip(tip)
                        );

        shift_register shift(
                        .pclk(pclk),
                        .preset_n(preset_n),
                        .ss(ss),
                        .send_data(send_data),
                        .lsbfe(lsbfe),
                        .cpha(cpha),
                        .cpol(cpol),
                        .miso_rec_neg_sclk(miso_rec_neg_sclk),
                        .miso_rec_pos_sclk(miso_rec_pos_sclk),
                        .mosi_send_neg_sclk(mosi_send_neg_sclk),
                        .mosi_send_pos_sclk(mosi_send_pos_sclk),
                        .data_mosi(data_mosi),
                        .miso(miso),
                        .receive_data(receive_data),
                        .mosi(mosi),
                        .data_miso(data_miso)
                        );

        apb_slave_interface apb(
                        .pclk(pclk),
                        .preset_n(preset_n),
                        .paddr(paddr),
                        .psel(psel),
                        .penable(penable),
                        .pwrite(pwrite),
                        .pwdata(pwdata),
                        .ss(ss),
                        .receive_data(receive_data),
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


endmodule
