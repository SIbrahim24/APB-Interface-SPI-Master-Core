module baud_rate_gen_tb();
        reg pclk;
        reg preset_n;
        reg [1:0]spi_mode;
        reg spi_swai;
        reg [2:0]sppr;
        reg [2:0]spr;
        reg cpol;
        reg cpha;
        reg ss;

        wire sclk;
        wire miso_rec_neg_sclk;
        wire miso_rec_pos_sclk;
        wire mosi_send_neg_sclk;
        wire mosi_send_pos_sclk;
        wire [11:0]baud_rate_divisor;


        baud_rate_generator dut(.pclk(pclk),
                                  .preset_n(preset_n),
                                  .spi_mode(spi_mode),
                                  .spi_swai(spi_swai),
                                  .sppr(sppr),
                                  .spr(spr),
                                  .cpol(cpol),
                                  .cpha(cpha),
                                  .ss(ss),
                                  .sclk(sclk),
                                  .miso_rec_neg_sclk(miso_rec_neg_sclk),
                                  .miso_rec_pos_sclk(miso_rec_pos_sclk),
                                  .mosi_send_neg_sclk(mosi_send_neg_sclk),
                                  .mosi_send_pos_sclk(mosi_send_pos_sclk),
                                  .baud_rate_divisor(baud_rate_divisor));

        initial begin
                pclk = 1;
        forever
                #5 pclk = ~pclk;
        end

        task initialization();
          begin
                preset_n =0;
                ss = 1;
                spi_swai =0;
                spi_mode =0;
                cpol =0;
                cpha =0;
                spr = 0;
                sppr = 0;
          end
        endtask

        task reset();
                begin
                @(negedge pclk)
                preset_n =0;
                @(negedge pclk)
                #10 preset_n = 1;
                end
        endtask

        task stimulus(input x,input[1:0]y,input a,input b,input[2:0]c ,input[2:0]d);
                begin
                 ss   =0;
                 spi_swai =x;
                 spi_mode =y;
                 cpol =a;
                 cpha =b;
                 sppr =c;
                 spr  =d;
                end
        endtask


        initial begin
                initialization();
                reset();
                @(negedge pclk)
                stimulus(0,0,0,0,1,1);
                #100;
                @(negedge pclk)
                stimulus(0,1,0,1,0,1);
                #120;
                @(negedge pclk)
                stimulus(1,2,1,0,1,1);
                #100;
                @(negedge pclk)
                stimulus(0,0,1,1,1,0);
                #100;
                @(negedge pclk)
                stimulus(0,1,0,1,1,2);
                #300;
                @(negedge pclk)
                stimulus(0,1,0,1,1,0);
        #300;
                $finish;
        end
endmodule
