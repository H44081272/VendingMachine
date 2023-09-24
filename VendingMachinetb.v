`timescale 1ns/1ns


module VendingMachinetb;
  //input signal line  
  reg clk;
  reg rst;
  reg [1:0] select;//品項選擇
  reg confirm;//確認鍵
  reg [5:0] left1,left2,left3;//所剩貨物量
  reg [3:0] money;//顧客投入金額

  //output signal line    
  wire[3:0] cstate;//現在狀態
  wire[3:0] timecount;//15秒
  wire[3:0] moneysum;//累積投入金額總數
  wire [3:0] change;//找零
  wire [1:0] product;//出貨
  wire[6:0] Dout1,Dout2;//七段顯示器輸出

  
  //Substitute into module VendingMachine
  VendingMachine v1(.clk(clk),.rst(rst),.select(select),.confirm(confirm),.left1(left1),.left2(left2),.left3(left3),.money(money),.cstate(cstate),.timecount(timecount),.moneysum(moneysum),.change(change),.product(product),.Dout1(Dout1),.Dout2(Dout2));
  
  initial
  begin
    clk=0;
    rst=0;
    select=2'b00;//品項選擇=0
    confirm=0;//確認鍵為否
    money=0;//顧客投入金額=0
    left1=32;//所剩貨物量=32
    left2=32;
    left3=32;
    //20ns後自動販賣機開始啟動
    #20 rst=1;
  end
  
 always
  begin
    //每10ns clk 從1->0 or 從0->1
    #10 clk=~clk;
  end
  


  //Note:每次輸入，10ns之後販賣機系統必須將剛剛的輸入自動初始化，
  //以免系統一直存著剛剛的輸入，導致商品持續出貨或找零

  initial
  begin
    //情況一:不找零
    #20 select=2'b01;//選擇品項1
    #10 select=2'b00;//初始化
        confirm=1;//確認
    #10 confirm=0;//初始化
    #40 money=1;//投入1元
    #10 money=0;//初始化
    #10 money=1;//投入1元
    #10 money=0;//初始化
    #10 money=1;//投入1元
    #10 money=0;//初始化
    //情況二:未在15s內投幣
    #140 select=2'b01;//選擇品項1
    #10  select=2'b00;//初始化
         confirm=1;//確認
    #10  confirm=0;//初始化
    #400;//15s內未投幣
    //情況三:選擇未確認
    #20 select=2'b11;//選擇品項3
    #10  select=2'b00;//初始化
         confirm=0;//未確認
    //情況四:找零
    #20 select=2'b10;//選擇品項2
    #10  select=2'b00;//初始化
         confirm=1;//確認
    #10  confirm=0;//初始化
    #40  money=10;//投入10元
    #10  money=0;//初始化
  end
  
endmodule