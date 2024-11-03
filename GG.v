`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/19 16:40:40
// Design Name: 
// Module Name: GG
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

module GG #(
    parameter D_WIDTH = 4,
    parameter DATA_WIDTH = 20
  ) (
    input signed[DATA_WIDTH-1:0] a_ij,
    input valid_i,
    //input [3:0] iter_num,
    input clk,
    input rst_n,
    input clr_i,

    //output reg valid_d_o,
    output reg valid_o_rij,
    output reg signed[DATA_WIDTH-1:0] rij_ff_o,
    output reg signed[DATA_WIDTH-1:0] final_nx,
    output reg [D_WIDTH-1:0] d_i_d_o
  );

parameter signed K = 20'b0000000000_1001101101;

reg [3:0] shift_num0, shift_num1, shift_num2, shift_num3;

//========== initial X & Y ========== //
reg data1_arrive;
always @(posedge clk) begin
    if(!rst_n)
        data1_arrive <= 0;
    else if(shift_num0 ==0) // ==4
        data1_arrive <= 1;
    else
        data1_arrive <= data1_arrive;
end

//wire data1_arrive=(valid_i)? 1:data1_arrive;
reg signed[DATA_WIDTH-1:0] oy, ox;
always @(posedge clk ) begin  
    if(valid_i & data1_arrive) begin
        ox <= rij_ff_o;
        oy <= a_ij;
    end
    else if(valid_i & shift_num0 ==13)
        oy <= a_ij;
    else if(valid_i & shift_num0 ==0)
        ox <= a_ij;
    else begin
        oy <= y4_unoverflow;
        ox <= x4_unoverflow;
    end
end


wire d0 = ~ox[DATA_WIDTH-1] ^ oy[DATA_WIDTH-1];
wire d1 = ~x1_unoverflow[DATA_WIDTH-1] ^ y1_unoverflow[DATA_WIDTH-1];
wire d2 = ~x2_unoverflow[DATA_WIDTH-1] ^ y2_unoverflow[DATA_WIDTH-1];
wire d3 = ~x3_unoverflow[DATA_WIDTH-1] ^ y3_unoverflow[DATA_WIDTH-1];

wire signed[DATA_WIDTH-1:0] oy_shifted, y1_shifted, y2_shifted, y3_shifted;
wire signed[DATA_WIDTH-1:0] ox_shifted, x1_shifted, x2_shifted, x3_shifted;
//========== unfolding ========== //    unfolding factor = 4
wire signed[DATA_WIDTH:0] x1 = d0 ? ox + oy_shifted : ox - oy_shifted;
wire signed[DATA_WIDTH:0] y1 = d0 ? oy - ox_shifted : oy + ox_shifted;
wire signed[DATA_WIDTH:0] x2 = d1 ? x1_unoverflow + y1_shifted : x1_unoverflow - y1_shifted;
wire signed[DATA_WIDTH:0] y2 = d1 ? y1_unoverflow - x1_shifted : y1_unoverflow + x1_shifted;
wire signed[DATA_WIDTH:0] x3 = d2 ? x2_unoverflow + y2_shifted : x2_unoverflow - y2_shifted;
wire signed[DATA_WIDTH:0] y3 = d2 ? y2_unoverflow - x2_shifted : y2_unoverflow + x2_shifted;
wire signed[DATA_WIDTH:0] x4 = d3 ? x3_unoverflow + y3_shifted : x3_unoverflow - y3_shifted;
wire signed[DATA_WIDTH:0] y4 = d3 ? y3_unoverflow - x3_shifted : y3_unoverflow + x3_shifted;

dynamic_shift #(D_WIDTH,DATA_WIDTH) y_shifter1 (oy, shift_num0, oy_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) x_shifter1 (ox, shift_num0, ox_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) y_shifter2 (y1_unoverflow, shift_num1, y1_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) x_shifter2 (x1_unoverflow, shift_num1, x1_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) y_shifter3 (y2_unoverflow, shift_num2, y2_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) x_shifter3 (x2_unoverflow, shift_num2, x2_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) y_shifter4 (y3_unoverflow, shift_num3, y3_shifted);
dynamic_shift #(D_WIDTH,DATA_WIDTH) x_shifter4 (x3_unoverflow, shift_num3, x3_shifted);
//========== Determine overflow ========== //  extended bit + sign bit = 01 positive overflow, =10 negitive overflow
//wire signed[DATA_WIDTH-1:0] x1_unoverflow =(x1[DATA_WIDTH] ^ x1[DATA_WIDTH-1]) ? (x1[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : x1;
//wire signed[DATA_WIDTH-1:0] y1_unoverflow =(y1[DATA_WIDTH] ^ y1[DATA_WIDTH-1]) ? (y1[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : y1;

reg signed[DATA_WIDTH-1:0] x1_unoverflow, x2_unoverflow, x3_unoverflow, x4_unoverflow;
reg signed[DATA_WIDTH-1:0] y1_unoverflow, y2_unoverflow, y3_unoverflow, y4_unoverflow;
always @(*) begin
    if(shift_num0 != 12) begin
    x1_unoverflow <=(x1[DATA_WIDTH] ^ x1[DATA_WIDTH-1]) ? (x1[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : x1;
    y1_unoverflow <=(y1[DATA_WIDTH] ^ y1[DATA_WIDTH-1]) ? (y1[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : y1;
    x2_unoverflow <=(x2[DATA_WIDTH] ^ x2[DATA_WIDTH-1]) ? (x2[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : x2;
    y2_unoverflow <=(y2[DATA_WIDTH] ^ y2[DATA_WIDTH-1]) ? (y2[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : y2;
    x3_unoverflow <=(x3[DATA_WIDTH] ^ x3[DATA_WIDTH-1]) ? (x3[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : x3;
    y3_unoverflow <=(y3[DATA_WIDTH] ^ y3[DATA_WIDTH-1]) ? (y3[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : y3;
    x4_unoverflow <=(x4[DATA_WIDTH] ^ x4[DATA_WIDTH-1]) ? (x4[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : x4;
    y4_unoverflow <=(y4[DATA_WIDTH] ^ y4[DATA_WIDTH-1]) ? (y4[DATA_WIDTH] ? 20'b10000000000000000000 : 20'b01111111111111111111) : y4;
    end
end



always @(posedge clk) begin
    if(!rst_n)
        shift_num0 <= 13;
    else if(valid_i) begin
        shift_num0 <= 0;
        shift_num1 <= 1;
        shift_num2 <= 2;
        shift_num3 <= 3;
    end
    else if (data1_arrive)begin
        shift_num0 <= shift_num0 + 4;//ok!
        shift_num1 <= shift_num1 + 4;
        shift_num2 <= shift_num2 + 4;//unknow
        shift_num3 <= shift_num3 + 4;// iter_num is input
    end
    else begin
        shift_num0 <= shift_num0 ;//
        shift_num1 <= shift_num1 ;
        shift_num2 <= shift_num2 ;
        shift_num3 <= shift_num3 ;
    end
end


integer i;
//========== Caculate d ========== //
always @(*) begin
    if(!rst_n)begin
        for(i=0 ; i<4 ; i=i+1)begin
            d_i_d_o[i] <= 0;
        end
    end
    else begin
        d_i_d_o[0] <= d0;
        d_i_d_o[1] <= d1;
        d_i_d_o[2] <= d2;
        d_i_d_o[3] <= d3;
    end
end

reg [3:0] valid_time; // input Valid time
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_time <= 0;
    else
        valid_time = {valid_time,valid_i};
end 

always @(posedge clk) begin
    if(shift_num0 == 8) begin
        rij_ff_o <= y4_unoverflow *K;
        final_nx <= x4_unoverflow *K;
    end
end

always @(posedge clk) begin
    if(valid_time[3]) 
        valid_o_rij <= 1;
    else
        valid_o_rij <= 0;
end

/*
wire clk_out;
wire locked;

//========== PLL IP call ========== //
clk_wiz_0 clk_wiz_0_inst
   (
    .clk_in1(clk),            // IN 100Mhz
    // Clock out ports
    .clk_out1(clk_out),    // OUT 400Mhz	 
    // Status and control signals	 
    .reset(~rst_n),        // pll reset, high-active
    .locked(locked));     // OUT
*/

endmodule