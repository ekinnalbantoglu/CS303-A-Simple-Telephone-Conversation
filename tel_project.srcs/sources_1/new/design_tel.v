`timescale 1ns / 1ps


module design_tel(
input clk,
input rst,
input startCall, answerCall,
input endCall,
input sendChar,
input [7:0] charSent,
output reg [63:0] statusMsg,
output reg [63:0] sentMsg
);
    
parameter IDLE    =0;
parameter BUSY    =1;
parameter REJECTED=2;
parameter RINGING =3;
parameter CALLER  =4;
parameter COST    =5;

reg[2:0] curr_state, next_state;
reg[4:0] counter;
reg[63:0] temp;
reg[63:0] money;

always@ (posedge clk or posedge rst)begin
    if(rst)
        counter <= 0;
    else
        if(curr_state == RINGING )begin
                if(next_state == REJECTED)
                    counter <= 0;
                else if(counter == 9)
                    counter <= 0;
                else
                    counter <= counter + 1;
        end
        else if(curr_state == REJECTED)begin
                if(counter == 9)
                    counter <= 0;
                else
                    counter <= counter + 1;
        end
        else if(curr_state == BUSY    )begin
                if(counter == 9)
                    counter <= 0;
                else
                    counter <= counter + 1;
        end
        else if(curr_state == COST    )begin
                if(counter == 4)
                    counter <= 0;
                else
                    counter <= counter + 1;
        end
        else if(curr_state == CALLER  )begin
                counter <= 0;
        end
        else
            counter <= counter;
end

always@ (posedge clk or posedge rst)begin
    if(rst)
        curr_state <= 0;
    else
        curr_state <= next_state;
end

always@* begin
    case(curr_state)
        IDLE    : begin
            if(startCall == 1)
                next_state = RINGING ;
            else
                next_state = IDLE    ;
        end
        RINGING : begin
            if(endCall == 1)
                next_state = REJECTED;
            else if(answerCall == 1)
                next_state = CALLER  ;
            else if(counter == 9)
                next_state = BUSY    ;
            else
                next_state = RINGING ;
                
        end
        REJECTED: begin
        if(counter == 9)
            next_state = IDLE    ;
        else
            next_state = REJECTED;
        end
        BUSY    :begin
            if(counter == 9)
                next_state= IDLE    ;
            else
                next_state = BUSY    ;
        end
        CALLER  : begin
            if(endCall==1 | charSent == 127)
                next_state = COST    ;
            else
                next_state=CALLER  ;    
        end
        COST    : begin
            if(counter == 4)
                next_state = IDLE    ;
            else
                next_state = COST    ;
        end
    endcase
end 

always@(posedge clk or posedge rst) begin
    if(rst)begin
        statusMsg[7:0] <=  32;
        statusMsg[15:8] <= 32;
        statusMsg[23:16] <= 32;
        statusMsg[31:24] <= 32;
        statusMsg[39:32] <= 69;
        statusMsg[47:40] <= 76;
        statusMsg[55:48] <= 68;
        statusMsg[63:56] <= 73;
        sentMsg <= 0;
        money <=0;
        
    end
    else begin
        case(curr_state)
            IDLE    :begin
                statusMsg[7:0] <=  32;
                statusMsg[15:8] <= 32;
                statusMsg[23:16] <= 32;
                statusMsg[31:24] <= 32;
                statusMsg[39:32] <= 69;
                statusMsg[47:40] <= 76;
                statusMsg[55:48] <= 68;
                statusMsg[63:56] <= 73;
                sentMsg <= 0;
                money <=0;
            end
            RINGING :begin
                statusMsg[7:0] <= 32;
                statusMsg[15:8] <= 71;
                statusMsg[23:16] <= 78;
                statusMsg[31:24] <= 73;
                statusMsg[39:32] <= 71;
                statusMsg[47:40] <= 78;
                statusMsg[55:48] <= 73;
                statusMsg[63:56] <= 82;
                sentMsg <= 0;
                money <=0;
            end
            REJECTED: begin
                statusMsg[7:0] <= 68;
                statusMsg[15:8] <= 69;
                statusMsg[23:16] <= 84;
                statusMsg[31:24] <= 67;
                statusMsg[39:32] <= 69;
                statusMsg[47:40] <= 74;
                statusMsg[55:48] <= 69;
                statusMsg[63:56] <= 82;
                sentMsg <= 0;
                
                money <=0;
            end
            BUSY    : begin
                sentMsg <= 0;
                statusMsg[7:0] <= 32;
                statusMsg[15:8] <= 32;
                statusMsg[23:16] <= 32;
                statusMsg[31:24] <= 32;
                statusMsg[39:32] <= 89;
                statusMsg[47:40] <= 83;
                statusMsg[55:48] <= 85;
                statusMsg[63:56] <= 66;
                
                money <=0;
            end
            CALLER  : begin
                if(sendChar == 1 & charSent < 128 & charSent > 31) begin
                    if(charSent < 127)begin
                        temp = sentMsg << 8;
                        sentMsg = {temp[63:8], charSent };
                    end
                    if (charSent > 47 & charSent < 58)begin
                        money <= money + 64'h0001;
                    end    
                    else if( charSent <48 | charSent >57 )begin
                        money <= money + 64'h0002;
                    end    
                end    
                statusMsg[7:0] <= 32;
                statusMsg[15:8] <= 32;
                statusMsg[23:16] <= 82;
                statusMsg[31:24] <= 69;
                statusMsg[39:32] <= 76;
                statusMsg[47:40] <= 76;
                statusMsg[55:48] <= 65;
                statusMsg[63:56] <= 67;
            end
            COST    :begin
                sentMsg = {money};
                
                statusMsg[7:0] <= 32;
                statusMsg[15:8] <= 32;
                statusMsg[23:16] <= 32;
                statusMsg[31:24] <= 32;
                statusMsg[39:32] <= 84;
                statusMsg[47:40] <= 83;
                statusMsg[55:48] <= 79;
                statusMsg[63:56] <= 67;
            end
        endcase
    end
        
end
endmodule
