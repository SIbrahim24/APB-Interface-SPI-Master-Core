module slave_control_select(
                         input pclk,
                         input preset_n,
                         input mstr,
                         input spi_swai,
                         input spi_mode,
                         input send_data,
                         input [11:0]baud_rate_divisor,

                         output reg receive_data,
                         output reg ss,
                         output  wire tip
                        );

                        reg [15:0]count;
                        wire[15:0] target;
                        reg rcv;

        assign target = baud_rate_divisor*8;
        assign tip = ~ss;

        always@(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                begin
                        count <= 16'hffff;
                        ss    <= 1;
                        rcv   <= 0;
                end
                else if(mstr &&(spi_mode == 0 || (spi_mode == 1 && spi_swai == 0)))
                begin

                        if (send_data)
                        begin
                                ss      <= 0;
                                count   <= 0;
                                rcv     <= 0;
                        end
                        else if(count <= (target -1))begin
                                ss    <= 0;
                                count <= count+1;

                                 if(count == target-1)begin
                                        rcv <= 1;
                                 end

                                 else begin
                                         rcv <= 0;
                                 end
                        end
                        else
                        begin
                                ss <= 1;
                                rcv<= 0;
                                count<=16'hffff;
                        end
                end
                else
                begin
                        ss      <= 1;
                        rcv     <= 0;
                        count <= 16'hffff;
                end

        end

        always@(posedge pclk or negedge preset_n)
        begin
                if(!preset_n)
                        receive_data <= 0;
                else
                        receive_data <= rcv;

        end
endmodule
