`timescale 1ns/1ns


module VendingMachine(clk,rst,select,confirm,left1,left2,left3,money,cstate,timecount,moneysum,change,product,Dout1,Dout2);
  
  //input
  input clk,rst;
  input[1:0]  select;//販賣機選擇有三種品項編號為1、2、3
  input confirm;//確認選擇鍵 1:確認 0:不確認
  input[5:0] left1,left2,left3;//所剩貨物量
  input[3:0] money;//顧客投入金額 只接受1、5、10元 

  //output
  output reg[3:0] cstate;//現在狀態
  output reg[3:0] timecount;//15秒內投幣
  output reg[3:0] moneysum;//累積投入金額總數 最多10元
  output reg[3:0] change;//找零 最多找7元 10-3=7
  output reg[1:0] product;//出貨  品項編號為1、2、3
  output[6:0] Dout1,Dout2;//七段顯示器輸出1、輸出2

  //reg
  reg[3:0] nstate;//下次狀態
  reg starttimecount;//開始計時15s
  reg[1:0]  choose;//內部儲存select值
  reg check=0;//內部儲存confirm值
  reg  state=0;//Ein狀態
  reg[3:0] Ein;//Ein可能為投入金額、找零、出貨

  
  //wire
  wire[3:0] Eout1,Eout2;//編碼器輸出1、輸出2

  
  
  //state register(應用 D Flip-Flop with asynchronous reset)
  always @(posedge clk or posedge rst or select)begin

    //當clk為上升沿，且rst為0 -> 前往S0
    if(!rst) 
       cstate=4'b0000;
    //當select變動時 -> 把select值儲存在choose裡，以免因為select初始化影響後面流程進行計算並跳過S0直接進入S1，以免choose值被初始化 
    else if(select!=2'b00)begin    
       choose=select;
       cstate=4'b0001;
    end

    //當clk為上升沿，且rst為1 -> 前往上個clk儲存的下次狀態
    else
       cstate=nstate; 
  end
 

  //計數器
  always @(posedge clk)begin
    //開始計時
    if(starttimecount==1)
      //秒數+1
      timecount=timecount+1;
  end


   //如果confirm變動，且confirm為1，把confirm值儲存在內部的check，以免因為confirm初始化影響後面流程進行計算
   always @(confirm)begin  
    if(confirm!=0)begin    
      check=confirm;
    end
   end
   
   //如果money變動，且money不為0
   always @(money)begin   
    if(money!=0)begin 
    //累積投入金額總數=上次投入金額總數+投入金額       
     moneysum=moneysum+money;
    end
   end
   

   //////七段顯示器//////

  //顯示器優先權:product > change > moneysum
  //moneysum持續顯示直到change改變
  //change持續顯示直到product改變
  always@(moneysum,change,product)begin
   //product!=X 顯示
   if((2'd0<=product)&&(product<=2'd3)) begin 
     Ein=4'b1111;           //編碼器輸入=呼吸燈88      
     state=0;               //狀態是0
   end
   //change!=X 顯示
   else if((4'd0<=change)&&(change<=4'd15)) begin 
     Ein=change;            //編碼器輸入=找零 
     state=1;               //狀態是1-> Dout1顯示 -
   end
   //moneysum 持續顯示
   else if((4'd0<=moneysum)&&(moneysum<=4'd15)) begin 
     Ein=moneysum;          //編碼器輸入=累積投入金額總數     
     state=0;               //狀態是0
   end
  end

   //////七段顯示器//////


  //next state combinational logic(應用 MUXs with case)
  always @(*)begin
    case(cstate)
    //S0初始化狀態
    4'b0000:begin   
        starttimecount=0;//還沒開始計時
        timecount=0;//計時歸零   
        moneysum=0;//累積投入金額總數歸零  
        choose=2'b00;//內部儲存select值歸零
        check=0;//內部儲存confirm值歸零
        product=2'bxx;//出貨未知
        change=4'bxxxx;//找零未知      
        nstate=4'b0001;//next state S1
    end
    //S1:選擇貨物
    4'b0001:begin
        //選擇貨物編號>3 or 選擇貨物編號=0 
        if((choose>2'b11)||(choose==2'b00))
          nstate=4'b0000;//back to S0
        //選擇貨物編號1、2、3
        else
          nstate=4'b0010;//next state S2         
    end
    //S2:確認選擇
    4'b0010:begin
        //確認鍵為否
        if(check==0)
          nstate=4'b0000;//back to S0
        //確認鍵為是
        else
          nstate=4'b0011;//next state S3         
    end
    //S3:判斷是否售完
    4'b0011:begin
        //選擇1號且1號所剩貨物量<=0
        if((choose==2'd1)&&(left1<=0))
          nstate=4'b0000;//back to S0
        //選擇2號且2號所剩貨物量<=0
        else if((choose==2'd2)&&(left2<=0))
          nstate=4'b0000;//back to S0 
        //選擇3號且3號所剩貨物量<=0
        else if((choose==2'd3)&&(left3<=0))
          nstate=4'b0000;//back to S0 
        //選擇所剩貨物量充足
        else
          nstate=4'b0100;//next state S4

          //開始計時
          starttimecount=1;         
    end
    //S4:是否在15s內投幣
    4'b0100:begin 
        //15s內未投幣
        if(timecount>=4'd15)begin
         change=moneysum;//退幣=累積投入金額總數
         nstate=4'b0000;//back to S0 
        end
        //1~15s內反覆前往S5檢查累積投入金額總數是否足夠，若不足則從S5返回S4，直到投幣金額足夠or15s內未投幣才跳脫loop
        else begin
         nstate=4'b0101;//next state S5
        end
    end
    //S5:投幣金額是否足夠
    4'b0101:begin
        //選擇1號且1號累積投入金額總數>=3元
        if((choose==2'd1)&&(moneysum>=4'd3))
          nstate=4'b0110;//next state S6
        //選擇2號且2號累積投入金額總數>=5元
        else if((choose==2'd2)&&(moneysum>=4'd5))
          nstate=4'b0110;//next state S6
        //選擇3號且3號累積投入金額總數>=10元
        else if((choose==2'd3)&&(moneysum>=4'd10))
          nstate=4'b0110;//next state S6
        //投入金額不足
        else
          nstate=4'b0100;//back to S4         
    end
    //S6:是否需要找零
    4'b0110:begin
        //選擇1號且1號累積投入金額總數剛好=3元
        if((choose==2'd1)&&(moneysum==4'd3))
          nstate=4'b1000;//next state S8
        //選擇2號且2號累積投入金額總數剛好=5元
        else if((choose==2'd2)&&(moneysum==4'd5))
          nstate=4'b1000;//next state S8
        //選擇3號且3號累積投入金額總數剛好=10元
        else if((choose==2'd3)&&(moneysum==4'd10))
          nstate=4'b1000;//next state S8
        //累積投入金額總數!=所選品項金額
        else
          nstate=4'b0111;//next state S7         
    end
    //S7:找零
    4'b0111:begin
        //選擇1號
        if(choose==2'd1)begin
         //找零=累積投入金額總數-商品金額3元
         change=moneysum-4'd3;
         nstate=4'b1000;//next state S8  
        end    
        //選擇2號  
        else if(choose==2'd2)begin
         //找零=累積投入金額總數-商品金額5元
         change=moneysum-4'd5;
         nstate=4'b1000;//next state S8    
        end     
        //選擇3號
        else if(choose==2'd3)begin
         //找零=累積投入金額總數-商品金額10元
         change=moneysum-4'd10;  
         nstate=4'b1000;//next state S8      
        end      
    end
    //S8:出貨
    4'b1000:begin
        //選擇1號
        if(choose==2'd1)begin
         //售出1號品項
         product=2'd1;
         nstate=4'b0000;//back to S0 
        end
        //選擇2號
        else if(choose==2'd2)begin
         //售出2號品項
         product=2'd2;
         nstate=4'b0000;//back to S0  
        end
        //選擇3號
        else if(choose==2'd3)begin
         //售出3號品項
         product=2'd3;  
         nstate=4'b0000;//back to S0       
        end    
    end
   endcase
  end
  
  //Substitute into module EnCoder
  EnCoder E0(.Ein(Ein),.Eout1(Eout1),.Eout2(Eout2)) ;
  //Substitute into module SevenSeg
  SevenSeg S0(.state(state),.Din(Eout1),.Dout(Dout1));
  SevenSeg S1(.state(state),.Din(Eout2),.Dout(Dout2));
  
  
endmodule