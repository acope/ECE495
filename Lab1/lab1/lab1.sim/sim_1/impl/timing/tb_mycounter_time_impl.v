// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Wed Sep 23 17:38:37 2015
// Host        : EC464ubuntu running 64-bit Ubuntu 15.04
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               /home/akcopema/Documents/ECE495/Lab1/lab1/lab1.sim/sim_1/impl/timing/tb_mycounter_time_impl.v
// Design      : mybcd_udcount_top
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module my_genpulse
   (\Qt_reg[3]_0 ,
    E_IBUF,
    CLK,
    AS);
  output \Qt_reg[3]_0 ;
  input E_IBUF;
  input CLK;
  input [0:0]AS;

  wire [0:0]AS;
  wire CLK;
  wire E_IBUF;
  wire \Qt[0]_i_2_n_0 ;
  wire \Qt[0]_i_3_n_0 ;
  wire \Qt[0]_i_4_n_0 ;
  wire \Qt[0]_i_5_n_0 ;
  wire \Qt[0]_i_6_n_0 ;
  wire \Qt[12]_i_2_n_0 ;
  wire \Qt[12]_i_3_n_0 ;
  wire \Qt[12]_i_4_n_0 ;
  wire \Qt[12]_i_5_n_0 ;
  wire \Qt[16]_i_2_n_0 ;
  wire \Qt[16]_i_3_n_0 ;
  wire \Qt[16]_i_4_n_0 ;
  wire \Qt[16]_i_5_n_0 ;
  wire \Qt[20]_i_2_n_0 ;
  wire \Qt[20]_i_3_n_0 ;
  wire \Qt[20]_i_4_n_0 ;
  wire \Qt[20]_i_5_n_0 ;
  wire \Qt[24]_i_2_n_0 ;
  wire \Qt[24]_i_3_n_0 ;
  wire \Qt[3]_i_3_n_0 ;
  wire \Qt[3]_i_4_n_0 ;
  wire \Qt[3]_i_5_n_0 ;
  wire \Qt[3]_i_6_n_0 ;
  wire \Qt[4]_i_2_n_0 ;
  wire \Qt[4]_i_3_n_0 ;
  wire \Qt[4]_i_4_n_0 ;
  wire \Qt[4]_i_5_n_0 ;
  wire \Qt[8]_i_2_n_0 ;
  wire \Qt[8]_i_3_n_0 ;
  wire \Qt[8]_i_4_n_0 ;
  wire \Qt[8]_i_5_n_0 ;
  wire [25:0]Qt_reg;
  wire \Qt_reg[0]_i_1_n_0 ;
  wire \Qt_reg[0]_i_1_n_4 ;
  wire \Qt_reg[0]_i_1_n_5 ;
  wire \Qt_reg[0]_i_1_n_6 ;
  wire \Qt_reg[0]_i_1_n_7 ;
  wire \Qt_reg[12]_i_1_n_0 ;
  wire \Qt_reg[12]_i_1_n_4 ;
  wire \Qt_reg[12]_i_1_n_5 ;
  wire \Qt_reg[12]_i_1_n_6 ;
  wire \Qt_reg[12]_i_1_n_7 ;
  wire \Qt_reg[16]_i_1_n_0 ;
  wire \Qt_reg[16]_i_1_n_4 ;
  wire \Qt_reg[16]_i_1_n_5 ;
  wire \Qt_reg[16]_i_1_n_6 ;
  wire \Qt_reg[16]_i_1_n_7 ;
  wire \Qt_reg[20]_i_1_n_0 ;
  wire \Qt_reg[20]_i_1_n_4 ;
  wire \Qt_reg[20]_i_1_n_5 ;
  wire \Qt_reg[20]_i_1_n_6 ;
  wire \Qt_reg[20]_i_1_n_7 ;
  wire \Qt_reg[24]_i_1_n_6 ;
  wire \Qt_reg[24]_i_1_n_7 ;
  wire \Qt_reg[3]_0 ;
  wire \Qt_reg[4]_i_1_n_0 ;
  wire \Qt_reg[4]_i_1_n_4 ;
  wire \Qt_reg[4]_i_1_n_5 ;
  wire \Qt_reg[4]_i_1_n_6 ;
  wire \Qt_reg[4]_i_1_n_7 ;
  wire \Qt_reg[8]_i_1_n_0 ;
  wire \Qt_reg[8]_i_1_n_4 ;
  wire \Qt_reg[8]_i_1_n_5 ;
  wire \Qt_reg[8]_i_1_n_6 ;
  wire \Qt_reg[8]_i_1_n_7 ;
  wire [2:0]\NLW_Qt_reg[0]_i_1_CO_UNCONNECTED ;
  wire [2:0]\NLW_Qt_reg[12]_i_1_CO_UNCONNECTED ;
  wire [2:0]\NLW_Qt_reg[16]_i_1_CO_UNCONNECTED ;
  wire [2:0]\NLW_Qt_reg[20]_i_1_CO_UNCONNECTED ;
  wire [3:0]\NLW_Qt_reg[24]_i_1_CO_UNCONNECTED ;
  wire [3:2]\NLW_Qt_reg[24]_i_1_O_UNCONNECTED ;
  wire [2:0]\NLW_Qt_reg[4]_i_1_CO_UNCONNECTED ;
  wire [2:0]\NLW_Qt_reg[8]_i_1_CO_UNCONNECTED ;

  LUT2 #(
    .INIT(4'h2)) 
    \Qt[0]_i_2 
       (.I0(Qt_reg[0]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[0]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[0]_i_3 
       (.I0(Qt_reg[3]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[0]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[0]_i_4 
       (.I0(Qt_reg[2]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[0]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[0]_i_5 
       (.I0(Qt_reg[1]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[0]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \Qt[0]_i_6 
       (.I0(Qt_reg[0]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[0]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[12]_i_2 
       (.I0(Qt_reg[15]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[12]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[12]_i_3 
       (.I0(Qt_reg[14]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[12]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[12]_i_4 
       (.I0(Qt_reg[13]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[12]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[12]_i_5 
       (.I0(Qt_reg[12]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[12]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[16]_i_2 
       (.I0(Qt_reg[19]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[16]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[16]_i_3 
       (.I0(Qt_reg[18]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[16]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[16]_i_4 
       (.I0(Qt_reg[17]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[16]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[16]_i_5 
       (.I0(Qt_reg[16]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[16]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[20]_i_2 
       (.I0(Qt_reg[23]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[20]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[20]_i_3 
       (.I0(Qt_reg[22]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[20]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[20]_i_4 
       (.I0(Qt_reg[21]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[20]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[20]_i_5 
       (.I0(Qt_reg[20]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[20]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[24]_i_2 
       (.I0(Qt_reg[25]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[24]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[24]_i_3 
       (.I0(Qt_reg[24]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[24]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \Qt[3]_i_1 
       (.I0(Qt_reg[2]),
        .I1(Qt_reg[1]),
        .I2(\Qt[3]_i_3_n_0 ),
        .I3(\Qt[3]_i_4_n_0 ),
        .I4(\Qt[3]_i_5_n_0 ),
        .I5(\Qt[3]_i_6_n_0 ),
        .O(\Qt_reg[3]_0 ));
  LUT6 #(
    .INIT(64'h0000000000000001)) 
    \Qt[3]_i_3 
       (.I0(Qt_reg[5]),
        .I1(Qt_reg[8]),
        .I2(Qt_reg[9]),
        .I3(Qt_reg[12]),
        .I4(Qt_reg[14]),
        .I5(Qt_reg[17]),
        .O(\Qt[3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \Qt[3]_i_4 
       (.I0(Qt_reg[22]),
        .I1(Qt_reg[23]),
        .I2(Qt_reg[24]),
        .I3(Qt_reg[25]),
        .I4(Qt_reg[21]),
        .I5(Qt_reg[18]),
        .O(\Qt[3]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \Qt[3]_i_5 
       (.I0(Qt_reg[7]),
        .I1(Qt_reg[0]),
        .I2(Qt_reg[4]),
        .I3(Qt_reg[15]),
        .I4(Qt_reg[10]),
        .I5(Qt_reg[3]),
        .O(\Qt[3]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h0080000000000000)) 
    \Qt[3]_i_6 
       (.I0(Qt_reg[11]),
        .I1(Qt_reg[16]),
        .I2(Qt_reg[20]),
        .I3(Qt_reg[6]),
        .I4(Qt_reg[13]),
        .I5(Qt_reg[19]),
        .O(\Qt[3]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[4]_i_2 
       (.I0(Qt_reg[7]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[4]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[4]_i_3 
       (.I0(Qt_reg[6]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[4]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[4]_i_4 
       (.I0(Qt_reg[5]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[4]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[4]_i_5 
       (.I0(Qt_reg[4]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[4]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[8]_i_2 
       (.I0(Qt_reg[11]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[8]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[8]_i_3 
       (.I0(Qt_reg[10]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[8]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[8]_i_4 
       (.I0(Qt_reg[9]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[8]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \Qt[8]_i_5 
       (.I0(Qt_reg[8]),
        .I1(\Qt_reg[3]_0 ),
        .O(\Qt[8]_i_5_n_0 ));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[0] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[0]_i_1_n_7 ),
        .Q(Qt_reg[0]));
  CARRY4 \Qt_reg[0]_i_1 
       (.CI(1'b0),
        .CO({\Qt_reg[0]_i_1_n_0 ,\NLW_Qt_reg[0]_i_1_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\Qt[0]_i_2_n_0 }),
        .O({\Qt_reg[0]_i_1_n_4 ,\Qt_reg[0]_i_1_n_5 ,\Qt_reg[0]_i_1_n_6 ,\Qt_reg[0]_i_1_n_7 }),
        .S({\Qt[0]_i_3_n_0 ,\Qt[0]_i_4_n_0 ,\Qt[0]_i_5_n_0 ,\Qt[0]_i_6_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[10] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[8]_i_1_n_5 ),
        .Q(Qt_reg[10]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[11] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[8]_i_1_n_4 ),
        .Q(Qt_reg[11]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[12] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[12]_i_1_n_7 ),
        .Q(Qt_reg[12]));
  CARRY4 \Qt_reg[12]_i_1 
       (.CI(\Qt_reg[8]_i_1_n_0 ),
        .CO({\Qt_reg[12]_i_1_n_0 ,\NLW_Qt_reg[12]_i_1_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\Qt_reg[12]_i_1_n_4 ,\Qt_reg[12]_i_1_n_5 ,\Qt_reg[12]_i_1_n_6 ,\Qt_reg[12]_i_1_n_7 }),
        .S({\Qt[12]_i_2_n_0 ,\Qt[12]_i_3_n_0 ,\Qt[12]_i_4_n_0 ,\Qt[12]_i_5_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[13] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[12]_i_1_n_6 ),
        .Q(Qt_reg[13]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[14] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[12]_i_1_n_5 ),
        .Q(Qt_reg[14]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[15] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[12]_i_1_n_4 ),
        .Q(Qt_reg[15]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[16] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[16]_i_1_n_7 ),
        .Q(Qt_reg[16]));
  CARRY4 \Qt_reg[16]_i_1 
       (.CI(\Qt_reg[12]_i_1_n_0 ),
        .CO({\Qt_reg[16]_i_1_n_0 ,\NLW_Qt_reg[16]_i_1_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\Qt_reg[16]_i_1_n_4 ,\Qt_reg[16]_i_1_n_5 ,\Qt_reg[16]_i_1_n_6 ,\Qt_reg[16]_i_1_n_7 }),
        .S({\Qt[16]_i_2_n_0 ,\Qt[16]_i_3_n_0 ,\Qt[16]_i_4_n_0 ,\Qt[16]_i_5_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[17] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[16]_i_1_n_6 ),
        .Q(Qt_reg[17]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[18] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[16]_i_1_n_5 ),
        .Q(Qt_reg[18]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[19] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[16]_i_1_n_4 ),
        .Q(Qt_reg[19]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[1] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[0]_i_1_n_6 ),
        .Q(Qt_reg[1]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[20] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[20]_i_1_n_7 ),
        .Q(Qt_reg[20]));
  CARRY4 \Qt_reg[20]_i_1 
       (.CI(\Qt_reg[16]_i_1_n_0 ),
        .CO({\Qt_reg[20]_i_1_n_0 ,\NLW_Qt_reg[20]_i_1_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\Qt_reg[20]_i_1_n_4 ,\Qt_reg[20]_i_1_n_5 ,\Qt_reg[20]_i_1_n_6 ,\Qt_reg[20]_i_1_n_7 }),
        .S({\Qt[20]_i_2_n_0 ,\Qt[20]_i_3_n_0 ,\Qt[20]_i_4_n_0 ,\Qt[20]_i_5_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[21] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[20]_i_1_n_6 ),
        .Q(Qt_reg[21]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[22] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[20]_i_1_n_5 ),
        .Q(Qt_reg[22]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[23] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[20]_i_1_n_4 ),
        .Q(Qt_reg[23]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[24] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[24]_i_1_n_7 ),
        .Q(Qt_reg[24]));
  CARRY4 \Qt_reg[24]_i_1 
       (.CI(\Qt_reg[20]_i_1_n_0 ),
        .CO(\NLW_Qt_reg[24]_i_1_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_Qt_reg[24]_i_1_O_UNCONNECTED [3:2],\Qt_reg[24]_i_1_n_6 ,\Qt_reg[24]_i_1_n_7 }),
        .S({1'b0,1'b0,\Qt[24]_i_2_n_0 ,\Qt[24]_i_3_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[25] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[24]_i_1_n_6 ),
        .Q(Qt_reg[25]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[2] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[0]_i_1_n_5 ),
        .Q(Qt_reg[2]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[3] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[0]_i_1_n_4 ),
        .Q(Qt_reg[3]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[4] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[4]_i_1_n_7 ),
        .Q(Qt_reg[4]));
  CARRY4 \Qt_reg[4]_i_1 
       (.CI(\Qt_reg[0]_i_1_n_0 ),
        .CO({\Qt_reg[4]_i_1_n_0 ,\NLW_Qt_reg[4]_i_1_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\Qt_reg[4]_i_1_n_4 ,\Qt_reg[4]_i_1_n_5 ,\Qt_reg[4]_i_1_n_6 ,\Qt_reg[4]_i_1_n_7 }),
        .S({\Qt[4]_i_2_n_0 ,\Qt[4]_i_3_n_0 ,\Qt[4]_i_4_n_0 ,\Qt[4]_i_5_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[5] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[4]_i_1_n_6 ),
        .Q(Qt_reg[5]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[6] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[4]_i_1_n_5 ),
        .Q(Qt_reg[6]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[7] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[4]_i_1_n_4 ),
        .Q(Qt_reg[7]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[8] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[8]_i_1_n_7 ),
        .Q(Qt_reg[8]));
  CARRY4 \Qt_reg[8]_i_1 
       (.CI(\Qt_reg[4]_i_1_n_0 ),
        .CO({\Qt_reg[8]_i_1_n_0 ,\NLW_Qt_reg[8]_i_1_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\Qt_reg[8]_i_1_n_4 ,\Qt_reg[8]_i_1_n_5 ,\Qt_reg[8]_i_1_n_6 ,\Qt_reg[8]_i_1_n_7 }),
        .S({\Qt[8]_i_2_n_0 ,\Qt[8]_i_3_n_0 ,\Qt[8]_i_4_n_0 ,\Qt[8]_i_5_n_0 }));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[9] 
       (.C(CLK),
        .CE(E_IBUF),
        .CLR(AS),
        .D(\Qt_reg[8]_i_1_n_6 ),
        .Q(Qt_reg[9]));
endmodule

module mybcd_udcount
   (Q,
    CLK,
    AS,
    E);
  output [3:0]Q;
  input CLK;
  input [0:0]AS;
  input [0:0]E;

  wire [0:0]AS;
  wire CLK;
  wire [0:0]E;
  wire [3:0]Q;
  wire [3:0]Qt;
  wire [0:0]flg;
  wire \flg[0]_i_1_n_0 ;
  wire \flg[0]_i_2_n_0 ;

  LUT5 #(
    .INIT(32'h4CCC4CCD)) 
    \Qt[0]_i_1 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(Q[3]),
        .I3(Q[2]),
        .I4(flg),
        .O(Qt[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hD555D554)) 
    \Qt[1]_i_1 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(Q[3]),
        .I3(Q[2]),
        .I4(flg),
        .O(Qt[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h8FF0F00E)) 
    \Qt[2]_i_1 
       (.I0(Q[0]),
        .I1(Q[3]),
        .I2(Q[1]),
        .I3(Q[2]),
        .I4(flg),
        .O(Qt[2]));
  LUT5 #(
    .INIT(32'hFE817E80)) 
    \Qt[3]_i_2 
       (.I0(flg),
        .I1(Q[2]),
        .I2(Q[1]),
        .I3(Q[3]),
        .I4(Q[0]),
        .O(Qt[3]));
  FDCE #(
    .INIT(1'b0)) 
    \Qt_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(AS),
        .D(Qt[0]),
        .Q(Q[0]));
  FDPE #(
    .INIT(1'b1)) 
    \Qt_reg[1] 
       (.C(CLK),
        .CE(E),
        .D(Qt[1]),
        .PRE(AS),
        .Q(Q[1]));
  FDPE #(
    .INIT(1'b1)) 
    \Qt_reg[2] 
       (.C(CLK),
        .CE(E),
        .D(Qt[2]),
        .PRE(AS),
        .Q(Q[2]));
  FDPE #(
    .INIT(1'b1)) 
    \Qt_reg[3] 
       (.C(CLK),
        .CE(E),
        .D(Qt[3]),
        .PRE(AS),
        .Q(Q[3]));
  LUT3 #(
    .INIT(8'h78)) 
    \flg[0]_i_1 
       (.I0(E),
        .I1(\flg[0]_i_2_n_0 ),
        .I2(flg),
        .O(\flg[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000080000001)) 
    \flg[0]_i_2 
       (.I0(flg),
        .I1(Q[0]),
        .I2(Q[3]),
        .I3(Q[2]),
        .I4(Q[1]),
        .I5(AS),
        .O(\flg[0]_i_2_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \flg_reg[0] 
       (.C(CLK),
        .CE(1'b1),
        .D(\flg[0]_i_1_n_0 ),
        .Q(flg),
        .R(1'b0));
endmodule

(* ECO_CHECKSUM = "2d4a85e" *) 
(* NotValidForBitStream *)
module mybcd_udcount_top
   (clock,
    reset,
    E,
    Q);
  input clock;
  input reset;
  input E;
  output [3:0]Q;

  wire E;
  wire E_IBUF;
  wire [3:0]Q;
  wire [3:0]Q_OBUF;
  wire a1_n_0;
  wire clock;
  wire clock_IBUF;
  wire clock_IBUF_BUFG;
  wire reset;
  wire reset_IBUF;

initial begin
 $sdf_annotate("tb_mycounter_time_impl.sdf",,,,"tool_control");
end
  IBUF E_IBUF_inst
       (.I(E),
        .O(E_IBUF));
  OBUF \Q_OBUF[0]_inst 
       (.I(Q_OBUF[0]),
        .O(Q[0]));
  OBUF \Q_OBUF[1]_inst 
       (.I(Q_OBUF[1]),
        .O(Q[1]));
  OBUF \Q_OBUF[2]_inst 
       (.I(Q_OBUF[2]),
        .O(Q[2]));
  OBUF \Q_OBUF[3]_inst 
       (.I(Q_OBUF[3]),
        .O(Q[3]));
  my_genpulse a1
       (.AS(reset_IBUF),
        .CLK(clock_IBUF_BUFG),
        .E_IBUF(E_IBUF),
        .\Qt_reg[3]_0 (a1_n_0));
  mybcd_udcount a2
       (.AS(reset_IBUF),
        .CLK(clock_IBUF_BUFG),
        .E(a1_n_0),
        .Q(Q_OBUF));
  BUFG clock_IBUF_BUFG_inst
       (.I(clock_IBUF),
        .O(clock_IBUF_BUFG));
  IBUF clock_IBUF_inst
       (.I(clock),
        .O(clock_IBUF));
  IBUF reset_IBUF_inst
       (.I(reset),
        .O(reset_IBUF));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
