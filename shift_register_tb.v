module shift_register_tb();
        reg pclk;
        reg preset_n;
        reg ss;
        reg send_data;
        reg lsbfe;
        reg cpha;
        reg cpol;
        reg miso_rec_pos_sclk;
        reg miso_rec_neg_sclk;
        reg mosi_send_pos_sclk;
        reg mosi_send_neg_sclk;
        reg [7:0]data_mosi;
        reg miso;
        reg receive_data;
        reg spr;
        reg sppr;
        wire mosi;
        wire [7:0]data_miso;

        reg spi_swai;
        reg [1:0] spi_mode;

        reg sclk;
        wire [11:0] baud_rate_divisor;

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
                        count <= 12'b0;
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


        shift_register dut(.pclk(pclk),
                           .preset_n(preset_n),
                           .ss(ss),
                           .send_data(send_data),
                           .lsbfe(lsbfe),
                           .cpha(cpha),
                           .cpol(cpol),
                           .miso_rec_pos_sclk(miso_rec_pos_sclk),
                           .miso_rec_neg_sclk(miso_rec_neg_sclk),
                           .mosi_send_pos_sclk(mosi_send_pos_sclk),
                           .mosi_send_neg_sclk(mosi_send_neg_sclk),
                           .data_mosi(data_mosi),
                           .miso(miso),
                           .receive_data(receive_data),
                           .mosi(mosi),
                           .data_miso(data_miso)
                   );

        initial begin
                pclk = 0;
                forever begin
                        #5 pclk = ~pclk;
                end
        end

        task initialization();
                begin
                        preset_n = 0;
                        ss       = 1;
                        send_data= 0;
                        lsbfe    = 0;
                        cpha     = 0;
                        cpol     = 0;
                        miso_rec_pos_sclk = 0;
                        miso_rec_neg_sclk = 0;
                        mosi_send_pos_sclk= 0;
                        mosi_send_neg_sclk= 0;
                        data_mosi= 0;
                        miso     = 0;
                        receive_data      = 0;
                        spi_swai = 0;
                        spi_mode = 0;

                end
        endtask

        task reset();
                begin
                        @(negedge pclk);
                        preset_n = 0;
                        @(negedge pclk);
                        preset_n = 1;
                end
        endtask

        task baud_rate_gen_stimulus();
                begin
                        @(negedge pclk);
                        cpol = 0;
                        cpha = 1;
                        sppr = 3'b01;
                        spr  = 3'b01;
                        spi_mode = 2'b01;
                        spi_swai = 0;
                        ss = 0;
                end
        endtask

        task send_data_stimulus(input[7:0]x , input y);
                begin
                        @(negedge pclk);
                        send_data = 1;
                        data_mosi = x;
                        lsbfe     = y;
                        @(negedge pclk);
                        send_data = 0;
                end
        endtask

        task receive_data_stimulus(input[7:0]a,input b);
        integer i;
                begin
                        @(negedge pclk);
                        miso = 1'bz;
                        wait(~ss);
                        lsbfe = b;
                        for(i=0;i<=7;i=i+1)begin
                                @(posedge sclk);
                                begin
                                        miso = a[i];
                                end
                        end
                        @(negedge pclk);
                        receive_data = 1;
                        @(negedge pclk);
                        receive_data = 0;
                end
        endtask

        initial begin
                initialization();
                reset();
                baud_rate_gen_stimulus();
                send_data_stimulus(200,1);
                repeat(8) @(negedge sclk);
                send_data_stimulus(254,0);
                repeat(8) @(negedge sclk);
                receive_data_stimulus(100,1);
        end

        initial begin
                #1000 ;
                $finish;
        end


endmodule
