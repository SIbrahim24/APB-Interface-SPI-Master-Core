module slave_select_tb;                       
                                 reg pclk;
                                reg preset_n;
                                reg  mstr;
                                reg spi_swai;
                                reg [1:0]spi_mode;
                                reg send_data;
                                reg [11:0]baud_rate_divisor;

                                wire receive_data;
                                wire ss;
                                wire tip;

        slave_control_select dut(.pclk(pclk),
                                   .preset_n(preset_n),
                                   .mstr(mstr),
                                   .spi_swai(spi_swai),
                                   .spi_mode(spi_mode),
                                   .send_data(send_data),
                                   .baud_rate_divisor(baud_rate_divisor),
                                   .receive_data(receive_data),
                                   .ss(ss),
                                   .tip(tip)
                           );


        initial begin
                pclk = 1'b0;
        forever
                #10 pclk = ~pclk;
        end

        task initialization();
         begin
                 preset_n = 1'b0;
                 mstr = 1'b0;
                 spi_swai =1'b0;
                 spi_mode = 2'b00;
                 send_data = 1'b0;
                 baud_rate_divisor =12'd0;
         end
        endtask

        task reset();
                begin
                        @(negedge pclk)
                        preset_n = 0;
                        @(negedge pclk)
                        preset_n = 1;
                end
        endtask


        task stimulus();
         begin
                @(negedge pclk)
                mstr = 1;
                spi_swai = 0;
                spi_mode = 1;
                baud_rate_divisor = 2;
                send_data = 1;
                @(negedge pclk)
                send_data = 0;
         end
        endtask

        initial begin
                initialization();
                reset();
                baud_rate_divisor =12'd4;
                @(negedge pclk);
                stimulus();
                #1000;
                $finish;
        end
endmodule
