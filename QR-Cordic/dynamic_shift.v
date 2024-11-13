`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/15 20:31:21
// Design Name: 
// Module Name: dynamic_shift
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


module dynamic_shift#(
    parameter D_WIDTH = 4,
    parameter DATA_WIDTH = 20
  ) (
    input signed[DATA_WIDTH-1:0] value,
    input [3:0] iter_num,
    output reg signed[DATA_WIDTH-1:0] value_itered
    );

wire signed[DATA_WIDTH-1:0] value_shift8 = iter_num[3] ? value >>> 8 : value;
wire signed[DATA_WIDTH-1:0] value_shift4 = iter_num[2] ? value_shift8 >>> 4 : value_shift8;
wire signed[DATA_WIDTH-1:0] value_shift2 = iter_num[1] ? value_shift4 >>> 2 : value_shift4;
wire signed[DATA_WIDTH-1:0] value_shift1 = iter_num[0] ? value_shift2 >>> 1 : value_shift2;

always @(*)begin
    value_itered <= value_shift1;
end


endmodule
