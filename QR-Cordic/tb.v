`timescale 1ns / 1ps
`define CYCLE_TIME    10.0 
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2024/10/23 14:47:31
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define ORI        "matrix_ori.txt"
`define ANS        "matrix_ans.txt"

module tb;
  parameter DATA_WIDTH = 20;
  parameter D_WIDTH = 4;
  parameter row = 8;

  reg rst_n,clk;
  reg signed[DATA_WIDTH*D_WIDTH -1:0] a_ij; //input
  reg valid_i,propogate_i;
  
  wire signed[DATA_WIDTH*D_WIDTH -1:0] out_r;
  wire valid_o;
  
  integer fp_r, fp_w;
  integer i;
  reg  [DATA_WIDTH -1:0] ori [0:row*D_WIDTH-1];

  initial
    clk = 0;
  always  #(`CYCLE_TIME/2.0)  clk = ~clk ;


  initial
  begin  
    $readmemb (`ORI, ori);
    $display("-----------------------------------------------------\n");
    $display("START!!! Simulation Start .....\n");
    $display("Your input matrix is : \n");
    for(i=0;i<8;i=i+1) begin
      $display("%20f %20f %20f %20f",$signed(ori[4*i]),$signed(ori[4*i+1]),$signed(ori[4*i+2]),$signed(ori[4*i+3]));
    end
    $display("-----------------------------------------------------\n");
    
    
    //rst_n = 1;

    
    #(`CYCLE_TIME*1.0) rst_n = 0;
    #(`CYCLE_TIME*1.0)
     // Starts calculation of GG
    rst_n = 1;
    //propogate_i = 0;
    
    #5;
    for(i=0;i<9;i=i+1) begin
      @(posedge clk)
        valid_i = 1; // start input data
        a_ij = {ori[4*i],ori[4*i+1],ori[4*i+2],ori[4*i+3]} ;
    end
    valid_i = 0;
    
    
    wait(valid_o);
    for(i=8;i>0;i=i-1) begin
      @(posedge clk) begin
          $display("Your matrix[%1d][0] is %8d",i,$signed(out_r[79:60]));
          $display("Your matrix[%1d][1] is %8d",i,$signed(out_r[59:40]));
          $display("Your matrix[%1d][2] is %8d",i,$signed(out_r[39:20]));
          $display("Your matrix[%1d][3] is %8d",i,$signed(out_r[19:0]));
          $display("------------------------------------------------------");
      end
    end
    
    
    #(`CYCLE_TIME*1.0);
    valid_i = 0;
    
    #(`CYCLE_TIME*10.0) $finish;
    end
    
  QR_CORDIC #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) QR(
       .a_ij(a_ij),
       .valid_i(valid_i),      
       .clk(clk),
       .rst_n(rst_n),    
       .valid_o(valid_o),
       .out_r(out_r)
     );

endmodule
