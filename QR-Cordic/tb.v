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


module tb;

  parameter DATA_WIDTH = 20;
  parameter D_WIDTH = 4;

  reg rst_n,clk;

  reg signed[DATA_WIDTH*D_WIDTH -1:0] a_ij; //input
  reg valid_i,propogate_i;
  //reg valid_gr;

  //wire [DATA_WIDTH-1:0] rij_ff_o,rij_ff_gr_o;
  wire signed[DATA_WIDTH*D_WIDTH -1:0] out_r;
  wire valid_o;
  

  initial
    clk = 0;
  always  #(`CYCLE_TIME/2.0)  clk = ~clk ;


  initial
  begin
    // 00000010010000000000  // GG x = 9.000000
    // 00000010010000000000  //    y = 9.000000
    // 00000011001011011001  //    r = 12.711914
    // (20,10) fix-point.
    rst_n = 1;
    a_ij  = 0;
    //aij_gr = 0;
    #(`CYCLE_TIME*1.0) rst_n = 0;
    #(`CYCLE_TIME*1.0)
     // Starts calculation of GG
    rst_n = 1;
    //propogate_i = 0;
    
    #5;
    valid_i = 1; // start input data
    a_ij = 80'b10000010010000000000_00000010000000000010_00000000000010000100_00001000110000000000; // vector mode first input: a_81
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00000010010001000010_10000010010000001000_10000010010000000000_10000010010000001000; // vector mode second input: a_72
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00000010010001000010_10000010010000000000_10000010010000000000_10000010010000000001;
    // give first d0-d3 (rotation 1)
    //valid_gr = 1; //rotation mode (second)
    //aij_gr = 20'b00000010010001000010; // rotation mode second input a_72
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00100010011001000010_10000010010000000000_10000010010000010000_10000010010000000001;
    
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00100010011001000011_10000010010000000000_10000010010000010000_10000010010000000001;
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00100010011001010010_10000010010000000000_10000010010000010000_10000010010000000001;
    
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00101010011001010010_10000010010000001000_10000010010000000000_10000010010000000011;
    
    #(`CYCLE_TIME*1.0);
    valid_i  = 1;
    a_ij = 80'b00100010011001010011_10000010010000001001_10000000010000010000_01000010010000000001;
    //valid_gr = 0; //(rotation 3)
    
    #(`CYCLE_TIME*1.0);
    valid_i = 0;
    //valid_gr = 0;
    
    //========== ¥¼­×§ï========== //
    #(`CYCLE_TIME*1.0);
    //iter_num = 12;
    
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
