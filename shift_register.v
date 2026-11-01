module shift_register(
                      input pclk ,
                      input preset_n,
                      input ss,
                      input send_data,
                      input lsbfe,
                      input cpha,
                      input cpol,
                      input miso_rec_pos_sclk,
                      input miso_rec_neg_sclk,
                      input mosi_send_pos_sclk,
                      input mosi_send_neg_sclk,
                      input [7:0]data_mosi,
                      input miso,
                      input receive_data,

                      output reg mosi,
                      output wire [7:0] data_miso);

                         reg[7:0] shift_register;
                         reg[7:0] temp_reg;
                         reg[2:0] count;
                         reg[2:0] count1;
                         reg[2:0] count2;
                         reg[2:0] count3;

        always@(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)begin
                        shift_register <= 0;
                end
                else if(send_data)begin
                        shift_register <= data_mosi;
                end
        end

        always@(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                        begin
                                mosi <= 1'b0;
                                count <= 3'b0;
                                count1<= 3'd7;
                        end
                else if(ss == 0)
                begin
                        if((!cpha && cpol)||(cpha && !cpol))begin
                                if(lsbfe == 1)begin
                                        if(count<=7)begin
                                                if(mosi_send_neg_sclk)begin
                                                        mosi <= shift_register[count];
                                                        count <= count+1;
                                                 end
                                         end

                                         else begin
                                                 count <= 0;
                                        end
                                 end

                                 else begin
                                        if(count1>=0)begin
                                                if(mosi_send_neg_sclk)
                                                begin
                                                        mosi <= shift_register[count];
                                                        count1 <= count-1;
                                                end
                                        end
                                        else begin
                                                count1 <= 3'd7;
                                        end
                                end
                        end

                        else begin
                                if(lsbfe ==1)
                                begin
                                        if(count<=7)begin
                                                if(mosi_send_pos_sclk)begin
                                                                mosi <= shift_register[count];
                                                                count<= count+1;
                                                end
                                        end
                                        else
                                        begin
                                                count <= 0;
                                        end
                                end
                                else
                                begin
                                        if(count >= 0)begin
                                                        if(mosi_send_pos_sclk)begin
                                                                        mosi <= shift_register[count1];
                                                                        count1 <= count1-1'b1;
                                                        end
                                        end
                                        else begin
                                                count<= 3'd7;
                                        end
                                end

                        end
                end

        end

        always@(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                begin
                        temp_reg <= 8'b0;
                        count2<= 3'b0;
                        count3<= 3'd7;
                end
                else begin
                        if(!ss)begin
                                if((!cpha && cpol)||(cpha&&!cpol))begin
                                        if(lsbfe ==1)begin
                                                if(count2 <= 7)begin
                                                        if(miso_rec_neg_sclk)begin
                                                                temp_reg[count2] <= miso;
                                                                count2 <= count2+1;
                                                        end
                                                end
                                                else begin
                                                        count2 <= 0;
                                                end
                                        end
                                        else begin
                                                if(count3 >= 0)begin
                                                        if(miso_rec_neg_sclk)begin
                                                                temp_reg[count3] <= miso;
                                                                count3 <= count3-1;
                                                        end
                                                end
                                                else begin
                                                        count3 <=3'd7;
                                                 end
                                        end
                                end
                                else begin
                                        if(lsbfe == 1)begin
                                                if(count2 <= 7)begin
                                                        if(miso_rec_pos_sclk)begin
                                                                temp_reg[count2] <= miso;
                                                                count2 <= count2+1;
                                                        end
                                                        end
                                                        else begin
                                                                count2 <= 0;
                                                        end
                                                        end
                                                
                                                else begin
                                                         if(count3 >=0)begin
                                                                 if(miso_rec_pos_sclk)begin
                                                                         temp_reg[count3]<= miso;
                                                                         count3 <= count3-1;
                                                                 end
                                                         end
                                                         else begin
                                                                count3 <= 3'd7;
                                                         end
                                                 end
                                        end
                                end
                        end
                end

    

        assign data_miso = receive_data?temp_reg :8'b0;
endmodule
