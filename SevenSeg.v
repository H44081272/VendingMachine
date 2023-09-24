`timescale 1ns / 1ns

//DeCoder解碼器
module SevenSeg(state,Din,Dout);
 input state;//Ein狀態，當Ein=change時，狀態是1
 input[3:0]  Din;//Eout1,Eout2編碼值輸入
 output reg[6:0] Dout;//Dout1,Dout2解碼值輸出

 always @(Din) begin
  //當Ein=change且Eout1=4'b1111 ->  Dout1顯示 -
  if((state==1)&&(Din==4'b1111))
    Dout=7'b1000000;
  else begin
  case(Din)       //gfedcba
  4'b0000:Dout=7'b0111111;
  4'b0001:Dout=7'b0000110;
  4'b0010:Dout=7'b1011011;
  4'b0011:Dout=7'b1001111;
  4'b0100:Dout=7'b1100110;
  4'b0101:Dout=7'b1101101;
  4'b0110:Dout=7'b1111101;
  4'b0111:Dout=7'b0000111;
  //當Eout1=4'b1000 ->  Dout1顯示8(呼吸燈)
  4'b1000:Dout=7'b1111111;
  4'b1001:Dout=7'b1101111;
  4'b1010:Dout=7'b1110111;
  //當Ein=moneysum且Eout1=4'b1111 ->  Dout1不顯示 
  4'b1111:Dout=7'b0000000;
  endcase
  end
 end
endmodule
