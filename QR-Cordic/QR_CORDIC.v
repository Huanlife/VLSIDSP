`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/22 23:21:34
// Design Name: 
// Module Name: QR_CORDIC
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


module QR_CORDIC#(
    parameter D_WIDTH = 4,
    parameter DATA_WIDTH = 20
  ) (
    input signed[DATA_WIDTH*D_WIDTH -1:0] a_ij,
    input valid_i,
    input clk,
    input rst_n,
    
    output reg valid_o,
    output reg signed[DATA_WIDTH*D_WIDTH -1:0] out_r
    );
    
localparam ROW_INDEX = 8; //8 row
    
//state
localparam IDLE = 2'b00;
localparam STORE_and_CAL = 2'b01;
localparam CAL = 2'b10;
localparam OUT = 2'b11;

reg signed[DATA_WIDTH-1:0] store_data [0:ROW_INDEX*D_WIDTH-1];

reg [1:0]cur_state;
reg [4:0]counter;


//wire start_out = (!rst_n)? 0 :(counter == 4)? 1'b1 : start_out;
wire start_out = (!rst_n)? 0 :(counter == 30)? 1'b1 : start_out;
//==========  FSM  ========== //
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        if(valid_i) 
            cur_state <= STORE_and_CAL;
        else if(start_out)
            cur_state <= OUT;
        else
            cur_state <= CAL;
    end
end
//==========  Input Store to Memory ========== //
wire signed[DATA_WIDTH-1:0] store_buff1, store_buff2, store_buff3, store_buff4;
assign store_buff1 = a_ij[DATA_WIDTH*D_WIDTH -1 :DATA_WIDTH*(D_WIDTH -1)];
assign store_buff2 = a_ij[DATA_WIDTH*(D_WIDTH-1) -1 :DATA_WIDTH*(D_WIDTH -2)];
assign store_buff3 = a_ij[DATA_WIDTH*(D_WIDTH-2) -1 :DATA_WIDTH*(D_WIDTH -3)];
assign store_buff4 = a_ij[DATA_WIDTH*(D_WIDTH-3) -1 :DATA_WIDTH*(D_WIDTH -4)];

//wire [4:0] counter_mult4 =(valid_i | cur_state == OUT)? (counter<<2) : 0; //log_2^(row * col ) = 5 bits
reg [4:0] counter_mult4;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        counter_mult4 <= 0;
    else if(valid_i | cur_state == OUT)
        counter_mult4 <= counter<<2;
    else
        counter_mult4 <= 0;
end

always@(posedge clk) begin
    if(valid_i| cur_state == STORE_and_CAL) begin
        store_data[counter_mult4] <= store_buff1;
        store_data[counter_mult4 +1] <= store_buff2;
        store_data[counter_mult4 +2] <= store_buff3;
        store_data[counter_mult4 +3] <= store_buff4;
    end
end
//==========  Ans Store to Memory ========== //
wire GG1_1stAns = (!rst_n) ? 0 : (counter == 8) ? 1 : GG1_1stAns; // GG module first Ans arrive
wire GG2_1stAns = (!rst_n) ? 0 : (counter == 18) ? 1 : GG2_1stAns;
wire GG3_1stAns = (!rst_n) ? 0 : (counter == 28) ? 1 : GG3_1stAns;
wire GG4_1stAns = (!rst_n) ? 0 : (counter == 6 & cur_state == OUT) ? 1 : GG4_1stAns;

reg [4:0] GG1_address, GG2_address, GG3_address, GG4_address;

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        GG1_address <= 0;
    end
    else if(GG1_1stAns & GG1_address!= 28) begin
        if(valid_control == 1)
            GG1_address <= GG1_address + 4;
    end
    else
        GG1_address <= GG1_address;
end

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        GG2_address <= 1;
    else if(GG2_1stAns & GG1_address!= 29) begin
        if(valid_control == 2)
            GG2_address <= GG2_address + 4;
    end
    else
        GG2_address <= GG2_address;
end

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        GG3_address <= 2;
    else if(GG3_1stAns & GG1_address!= 30) begin
        if(valid_control == 1)
            GG3_address <= GG3_address + 4;
    end
    else
        GG3_address <= GG3_address;
end

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        GG4_address <= 3;
    else if(GG4_1stAns & GG4_address!= 31) begin
        if(valid_control == 3)
            GG4_address <= GG4_address + 4;
    end
    else
        GG4_address <= GG4_address;
end
wire GG1_valido_rij, GG2_valido_rij, GG3_valido_rij, GG4_valido_rij;
always@(posedge clk ) begin
    if(GG1_valido_rij) begin
        store_data[GG1_address] <= GG1_out;
        store_data[GG1_address + 4] <= GG1_x;
    end
    else if(GG2_valido_rij) begin
        store_data[GG2_address] <= GG2_out;
        store_data[GG2_address + 4] <= GG2_x;
    end
    if(GG3_valido_rij) begin
        store_data[GG3_address] <= GG3_out;
        store_data[GG3_address + 4] <= GG3_x;
    end
    if(GG4_valido_rij) begin
        store_data[GG4_address] <= GG4_out;
        store_data[GG4_address + 4] <= GG4_x;
    end
end

//==========  DESIGN  ========== //
//counter
always @(posedge clk or negedge rst_n) begin 
   if(!rst_n) begin
       counter <= 0;
   end 
   else if(valid_i)begin
       counter <= counter + 'd1;
   end
   else 
       counter <= counter + 'd1;
end 

wire data_finish =(!rst_n)? 0 : (GG4_address==31 & counter ==1)? 1 : data_finish;
wire data_output_finish =(!rst_n)? 0 : (data_finish & counter==9)? 1 : data_output_finish;
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        out_r <= 0;
        valid_o <= 0;
    end
    else if(data_finish & !data_output_finish) begin
        out_r <= {store_data[counter_mult4],store_data[counter_mult4+1],store_data[counter_mult4+2],store_data[counter_mult4+3]};
        valid_o <= 1;
    end 
    else 
        valid_o <= 0;
end

//==========  GG/GR  I/O  Control ==========//
reg signed[DATA_WIDTH-1:0] in_col1, in_col2, in_col3, in_col4;
reg [4:0] col1_num, col2_num, col3_num, col4_num;
always @(posedge clk or negedge rst_n) begin  //Get the address of the value
    if(!rst_n)
        col1_num <= 0;      
    else if(valid_control==0)
        col1_num <= col1_num + 4;
    else 
        col1_num <= col1_num;    
end

always @(posedge clk or negedge rst_n) begin  //Get the address of the value
    if(!rst_n) 
        col2_num <= 1;
    else if(valid1)
        col2_num <= col2_num + 4;
    else
        col2_num <= col2_num;
end
always @(posedge clk or negedge rst_n) begin  //Get the address of the value
    if(!rst_n) 
        col3_num <= 2;
    else if(valid2)
        col3_num <= col3_num + 4;
    else
        col3_num <= col3_num;
end
always @(posedge clk or negedge rst_n) begin  //Get the address of the value
    if(!rst_n) 
        col4_num <= 3;
    else if(valid3)
        col4_num <= col4_num + 4;
    else
        col4_num <= col4_num;
end

always @(posedge clk or negedge rst_n) begin //The value of the address
    if(!rst_n) begin
        in_col1 <= 0;
        in_col2 <= 0;
        in_col3 <= 0;
        in_col4 <= 0;
    end
    else if(cur_state == CAL || cur_state == STORE_and_CAL) begin
        if(valid_control == 0)
            in_col1 <= store_data[col1_num];
        if(valid1)
            in_col2 <= store_data[col2_num];
        if(valid2)
            in_col3 <= store_data[col3_num];
        if(valid3)
            in_col4 <= store_data[col4_num];
    end
end

reg valid1, valid2, valid3, valid4;
reg [1:0]valid_control;
wire GG_GR_CAL = (cur_state == CAL | cur_state ==STORE_and_CAL)? 1 : 0;
always @(posedge clk or negedge rst_n) begin //valid signal control
    if(!rst_n)
        valid_control <= 1;
    else if(GG_GR_CAL & (counter ==1 || counter ==2)) 
        valid_control <= 0;
    else if(valid_control ==3)
        valid_control <= 0;
    else 
        valid_control <= valid_control + 1;
end

always @(posedge clk or negedge rst_n) begin //valid1
    if(!rst_n)
        valid1 <= 0;
    else if(valid_control==0 & GG_GR_CAL)
        valid1 <= 1;
    else
        valid1 <= 0;
end

always @(posedge clk or negedge rst_n) begin //valid2
    if(!rst_n)
        valid2 <= 0;
    else if(valid1)
        valid2 <= 1;
    else
        valid2 <= 0;
end

always @(posedge clk or negedge rst_n) begin //valid3
    if(!rst_n)
        valid3 <= 0;
    else if(valid2 == 1)
        valid3 <= 1;
    else
        valid3 <= 0;
end

always @(posedge clk or negedge rst_n) begin //valid4
    if(!rst_n)
        valid4 <= 0;
    else if(valid3 == 1)
        valid4 <= 1;
    else
        valid4 <= 0;
end

//==========  Module  ==========//
// Module GG & GR
wire [D_WIDTH-1:0] do_gg1, do_gg2, do_gg3;
wire [D_WIDTH-1:0] do_gr1, do_gr2, do_gr3, do_gr4, do_gr5, do_gr6;// propagate d_12itr

wire signed[DATA_WIDTH-1:0] GG1_out, GG2_out, GG3_out; //GG output
wire signed[DATA_WIDTH-1:0] GR1_out, GR2_out, GR3_out, GR4_out, GR5_out, GR6_out, GG4_out; //GR output
wire signed[DATA_WIDTH-1:0] GG1_x, GG2_x, GG4_3, GG4_x;
reg signed[DATA_WIDTH-1:0] GG2_input, GR4_input, GG3_input, GR5_input, GR6_input, GG4_input;

wire valid_gr_o;
reg [D_WIDTH-1:0] di_gr1, di_gr2, di_gr3, di_gr4, di_gr5, di_gr6; //GR input / storage of d of the previous output
always @(*)begin
    di_gr1 <= do_gg1;
    di_gr2 <= do_gr1;
    di_gr3 <= do_gr2;
    di_gr4 <= do_gg2;
    di_gr5 <= do_gr4;
    di_gr6 <= do_gg3;
end

GG #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GG1(
       .a_ij(in_col1),
       .valid_i(valid1),
       .clk(clk),
       .rst_n(rst_n),
       //.valid_d_o(valid_d_o),
       .valid_o_rij(GG1_valido_rij),
       .rij_ff_o(GG1_out),
       .d_i_d_o(do_gg1),
       .final_nx(GG1_x)
     );
GR #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GR1(
       .clk(clk),
       .rst_n(rst_n),

       .a_ij(in_col2),
       .valid_i(valid2),
       .d_i(di_gr1),
//       .rotates_i(rotates_d_o),
       .rij_ff_o(GR1_out),
//       .rotates_d_o(rotates_gr_d_o),
//       .valid_d_o(valid_gr_o),
       .d_i_d_o(do_gr1)
     );

GR #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GR2(
       .clk(clk),
       .rst_n(rst_n),
       
       .a_ij(in_col3),
       .valid_i(valid3),
       .d_i(di_gr2),
//       .rotates_i(rotates_d_o),
       .rij_ff_o(GR2_out),
//       .rotates_d_o(rotates_gr_d_o),
//       .valid_d_o(valid_gr_o),
       .d_i_d_o(do_gr2)
     );

reg [6:0] DFF_7delay; //  highest bit is GG2_valid (first data arrive at cnt 13 )
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        DFF_7delay <= 0;
    else
        DFF_7delay <= {DFF_7delay,valid4};
end
reg GR4_valid, GR5_valid;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        GR4_valid <= 0;
    else if(DFF_7delay[6] == 1)
        GR4_valid <= 1;
    else
        GR4_valid <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        GR5_valid <= 0;
    else if(GR4_valid)
        GR5_valid <= 1;
    else
        GR5_valid <= 0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        GG2_input <= 0; //col2
        
        GG3_input <= 0; //col3
        GR4_input <= 0;
        
        GR5_input <= 0; // col4
        GR6_input <= 0;
        GG4_input <= 0;
    end
    else begin
        GG2_input <= GR1_out; //col2
        
        GR4_input <= GR2_out; //col3
        GG3_input <= GR4_out;
        
        GR5_input <= GR3_out; // col4
        GR6_input <= GR5_out;
        GG4_input <= GR6_out;
    end
end

GG #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GG2(
       .a_ij(GG2_input),
       .valid_i(DFF_7delay[6]),
       .clk(clk),
       .rst_n(rst_n),
       //.valid_d_o(valid_d_o),
       .valid_o_rij(GG2_valido_rij),
       .rij_ff_o(GG2_out),
       .d_i_d_o(do_gg2),
       .final_nx(GG2_x)
     );
GR #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GR4(
       .clk(clk),
       .rst_n(rst_n),
       .a_ij(GR4_input),
       .valid_i(GR4_valid),
       .d_i(di_gr4),
//       .rotates_i(rotates_d_o),
       .rij_ff_o(GR4_out),
//       .rotates_d_o(rotates_gr_d_o),
//       .valid_d_o(valid_gr_o),
       .d_i_d_o(do_gr4)
     );
reg [7:0] GG3_valid; 
always @(posedge clk or negedge rst_n) begin //DFF_8delay
    if(!rst_n)
        GG3_valid <= 0;
    else
        GG3_valid <= {GG3_valid,GR5_valid};
end

GG #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GG3(
       .a_ij(GG3_input),
       .valid_i(GG3_valid[7]),
       .clk(clk),
       .rst_n(rst_n),
       //.valid_d_o(valid_d_o),
       .valid_o_rij(GG3_valido_rij),
       .rij_ff_o(GG3_out),
       .d_i_d_o(do_gg3),
       .final_nx(GG3_x)
     );
//==========  col4  module ========== //     
GR #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GR3(
       .clk(clk),
       .rst_n(rst_n),
       .a_ij(in_col4),
       .valid_i(valid4),
       .d_i(di_gr3),
//       .rotates_i(rotates_d_o),
       .rij_ff_o(GR3_out),
//       .rotates_d_o(rotates_gr_d_o),
       .valid_d_o(valid_gr_o),
       .d_i_d_o(do_gr3)
     );     
GR #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GR5(
       .clk(clk),
       .rst_n(rst_n),
       .a_ij(GR5_input),
       .valid_i(GR5_valid),
       .d_i(di_gr5),
//       .rotates_i(rotates_d_o),
       .rij_ff_o(GR5_out),
//       .rotates_d_o(rotates_gr_d_o),
//       .valid_d_o(valid_gr_o),
       .d_i_d_o(do_gr5)
     );  
reg GR6_valid;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        GR6_valid <= 0;
    else if(GG3_valid[7] == 1)
        GR6_valid <= 1;
    else
        GR6_valid <= 0;
end

GR #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GR6(
       .clk(clk),
       .rst_n(rst_n),
       .a_ij(GR6_input),
       .valid_i(GR6_valid),
       .d_i(di_gr6),
//       .rotates_i(rotates_d_o),
       .rij_ff_o(GR6_out),
//       .rotates_d_o(rotates_gr_d_o),
//       .valid_d_o(valid_gr_o),
       .d_i_d_o(do_gr6)
     );       
reg [8:0]GG4_valid;
always @(posedge clk or negedge rst_n) begin //DFF_9delay
    if(!rst_n)
        GG4_valid <= 0;
    else
        GG4_valid <= {GG4_valid,GR6_valid};
end
GG #(
       .D_WIDTH(D_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
     ) u_GG4(
       .a_ij(GG4_input),
       .valid_i(GG4_valid[8]),
       .clk(clk),
       .rst_n(rst_n),
       //.valid_d_o(valid_d_o),
       .valid_o_rij(GG4_valido_rij),
       .rij_ff_o(GG4_out),
       .final_nx(GG4_x)
       //.d_i_d_o(d_i_d_o)
     );

 

endmodule
