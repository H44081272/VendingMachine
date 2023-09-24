`timescale 1ns / 1ns


module EnCoder(Ein,Eout1,Eout2);
    input[3:0] Ein;//Ein可能為投入金額、找零、出貨
    output reg[3:0] Eout1,Eout2;//編碼器輸出1、輸出2
    //Eout1=4'b1111如果Ein是moneysum，state為0 -> Dout1不顯示
    //Eout1=4'b1111如果Ein是change，state為1 -> Dout1顯示 -
    always @(Ein) begin
        case(Ein)       
            4'b0000:begin//0
              Eout1=4'b1111;Eout2=4'b0000;
            end         
            4'b0001:begin//1
              Eout1=4'b1111;Eout2=4'b0001;
            end      
            4'b0010:begin//2
              Eout1=4'b1111;Eout2=4'b0010;
            end           
            4'b0011:begin//3
              Eout1=4'b1111;Eout2=4'b0011;
            end           
            4'b0100:begin//4
              Eout1=4'b1111;Eout2=4'b0100;
            end         
            4'b0101:begin//5
              Eout1=4'b1111;Eout2=4'b0101;
            end            
            4'b0110:begin//6
              Eout1=4'b1111;Eout2=4'b0110;
            end           
            4'b0111:begin//7
              Eout1=4'b1111;Eout2=4'b0111;
            end       
            4'b1000:begin//8
              Eout1=4'b1111;Eout2=4'b1000;
            end
            4'b1001:begin//9
              Eout1=4'b1111;Eout2=4'b1001;
            end
            //表示10，左邊燈必須顯示為1
            4'b1010:begin//10
              Eout1=4'b0001;Eout2=4'b0000;
            end
            //若為呼吸燈，Ein必須為4'b1111
            4'b1111:begin//呼吸燈88
              Eout1=4'b1000;Eout2=4'b1000;
            end
                      
        endcase
    end
endmodule

