module baud_rate_generator(
        input pclk,
        input preset_n,
        input spi_swai,
        input [1:0] spi_mode,
        input cpol,
        input cpha,
        input [2:0] sppr,
        input [2:0] spr,
        input ss,

        output reg sclk,
        output reg miso_rec_neg_sclk,
        output reg miso_rec_pos_sclk,
        output reg mosi_send_pos_sclk,
        output reg mosi_send_neg_sclk,
        output [11:0] baud_rate_divisor);

        wire pre_sclk;
        reg [11:0] count;

        assign baud_rate_divisor = (sppr+1)*(2**(spr+1));
        assign pre_sclk = cpol;

        always @(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                begin
                        sclk  <= pre_sclk;
                        count <= 12'hfff;
                end

                else if ((spi_mode == 2'b00 || (spi_mode == 2'b01 && spi_swai == 1'b0)) && !ss)
                begin
                        if(count == ((baud_rate_divisor/2) -1))
                        begin
                                sclk  <= ~sclk;
                                count <= 12'b0;
                        end
                        else
                        begin
                                sclk  <= sclk;
                                count <= count+1'b1;
                        end
                end
                else
                begin
                        sclk  <= pre_sclk;
                        count <= 12'b00;
                end
        end

        always @(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                begin
                        miso_rec_pos_sclk <= 1'b0;
                        miso_rec_neg_sclk <= 1'b0;
                end

                else if((cpol && cpha) || (!cpol && !cpha))
                begin
                        if (sclk == 0)
                        begin
                                if(count == ((baud_rate_divisor/2)-1))
                                begin
                                        miso_rec_pos_sclk <= 1'b1;
                                end
                                else
                                begin
                                        miso_rec_pos_sclk <= 1'b0;
                                end
                        end
                        else
                        begin
                                miso_rec_pos_sclk <= 1'b0;
                        end
                end

                else if((cpol && !cpha) || (!cpol && cpha))
                begin
                        if(sclk == 1)
                        begin
                                if(count == ((baud_rate_divisor/2)-1))
                                begin
                                        miso_rec_neg_sclk <= 1'b1;
                                end
                                else
                                begin
                                        miso_rec_neg_sclk <= 1'b0;
                                end
                        end
                        else
                        begin
                                miso_rec_neg_sclk <= 1'b0;
                        end
                end
                else
                begin
                        miso_rec_neg_sclk <= 1'b0;
                        miso_rec_pos_sclk <= 1'b0;
                end
        end

        always @(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                begin
                        mosi_send_pos_sclk <= 1'b0;
                        mosi_send_neg_sclk <= 1'b0;
                end

                else if((cpol && cpha) || (!cpol && !cpha))
                begin
                        if(sclk == 0)
                        begin
                                if(count == ((baud_rate_divisor/2)-2))
                                begin
                                        mosi_send_pos_sclk <= 1'b1;
                                end
                                else
                                begin
                                        mosi_send_pos_sclk <= 1'b0;
                                end
                        end
                        else
                        begin
                                mosi_send_pos_sclk <= 1'b0;
                        end
                end

                else if((cpol && !cpha) || (!cpol && cpha))
                begin
                        if(sclk == 1)
                        begin
                                if(count == ((baud_rate_divisor/2)-2))
                                begin
                                        mosi_send_neg_sclk <= 1'b1;
                                end
                                else
                                begin
                                        mosi_send_neg_sclk <= 1'b0;
                                end
                        end
                        else
                        begin
                                mosi_send_neg_sclk <= 1'b0;
                        end
                end
                else
                begin
                        mosi_send_neg_sclk <= 1'b0;
                        mosi_send_pos_sclk <= 1'b0;
                end
        end


endmodule
