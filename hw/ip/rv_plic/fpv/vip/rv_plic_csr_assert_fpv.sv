// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// FPV CSR read and write assertions auto-generated by `reggen` containing data structure
// Do Not Edit directly

`include "prim_assert.sv"

// Block: rv_plic
module rv_plic_csr_assert_fpv import tlul_pkg::*; (
  input clk_i,
  input rst_ni,

  //tile link ports
  input tl_h2d_t h2d,
  input tl_d2h_t d2h
);

  parameter int DWidth = 32;
  // mask register to convert byte to bit
  logic [DWidth-1:0] a_mask_bit;

  assign a_mask_bit[7:0]   = h2d.a_mask[0] ? '1 : '0;
  assign a_mask_bit[15:8]  = h2d.a_mask[1] ? '1 : '0;
  assign a_mask_bit[23:16] = h2d.a_mask[2] ? '1 : '0;
  assign a_mask_bit[31:24] = h2d.a_mask[3] ? '1 : '0;

  // declare common read and write sequences
  sequence device_wr_S(logic [8:0] addr);
    h2d.a_address == addr && h2d.a_opcode inside {PutFullData, PutPartialData} &&
        h2d.a_valid && h2d.d_ready && !d2h.d_valid;
  endsequence

  // this sequence is used for reg_field which has access w1c or w0c
  // it returns true if the `index` bit of a_data matches `exp_bit`
  // this sequence is under assumption - w1c/w0c will only use one bit per field
  sequence device_wc_S(logic [8:0] addr, bit exp_bit, int index);
    h2d.a_address == addr && h2d.a_opcode inside {PutFullData, PutPartialData} && h2d.a_valid &&
        h2d.d_ready && !d2h.d_valid && ((h2d.a_data[index] & a_mask_bit[index]) == exp_bit);
  endsequence

  sequence device_rd_S(logic [8:0] addr);
    h2d.a_address == addr && h2d.a_opcode inside {Get} && h2d.a_valid && h2d.d_ready &&
        !d2h.d_valid;
  endsequence

  // declare common read and write properties
  property wr_P(bit [8:0] addr, bit [DWidth-1:0] act_data, bit regen,
                bit [DWidth-1:0] mask);
    logic [DWidth-1:0] id, exp_data;
    (device_wr_S(addr), id = h2d.a_source, exp_data = h2d.a_data & a_mask_bit & mask) ##1
        first_match(##[0:$] d2h.d_valid && d2h.d_source == id) |->
        (d2h.d_error || act_data == exp_data || !regen);
  endproperty

  // external reg will use one clk cycle to update act_data from external
  property wr_ext_P(bit [8:0] addr, bit [DWidth-1:0] act_data, bit regen,
                    bit [DWidth-1:0] mask);
    logic [DWidth-1:0] id, exp_data;
    (device_wr_S(addr), id = h2d.a_source, exp_data = h2d.a_data & a_mask_bit & mask) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || $past(act_data) == exp_data || !regen);
  endproperty

  // For W1C or W0C, first scenario: write 1(W1C) or 0(W0C) that clears the value
  property wc0_P(bit [8:0] addr, bit act_data, bit regen, int index, bit clear_bit);
    logic [DWidth-1:0] id;
    (device_wc_S(addr, clear_bit, index), id = h2d.a_source) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || act_data == 1'b0 || !regen);
  endproperty

  // For W1C or W0C, second scenario: write 0(W1C) or 1(W0C) that won't clear the value
  property wc1_P(bit [8:0] addr, bit act_data, bit regen, int index, bit clear_bit);
    logic [DWidth-1:0] id;
    (device_wc_S(addr, !clear_bit, index), id = h2d.a_source) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || $stable(act_data) || !regen);
  endproperty

  property rd_P(bit [8:0] addr, bit [DWidth-1:0] act_data);
    logic [DWidth-1:0] id, exp_data;
    (device_rd_S(addr), id = h2d.a_source, exp_data = $past(act_data)) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || d2h.d_data == exp_data);
  endproperty

  property rd_ext_P(bit [8:0] addr, bit [DWidth-1:0] act_data);
    logic [DWidth-1:0] id, exp_data;
    (device_rd_S(addr), id = h2d.a_source, exp_data = act_data) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || d2h.d_data == exp_data);
  endproperty

  // read a WO register, always return 0
  property r_wo_P(bit [8:0] addr);
    logic [DWidth-1:0] id;
    (device_rd_S(addr), id = h2d.a_source) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || d2h.d_data == 0);
  endproperty

  property wr_regen_stable_P(bit regen, bit [DWidth-1:0] exp_data);
    (!regen && $stable(regen)) |-> $stable(exp_data);
  endproperty

// for all the regsters, declare assertion

  // define local fpv variable for the multi_reg
  logic [31:0] ip_d_fpv;
  for (genvar s = 0; s <= 31; s++) begin : gen_ip_d
    assign ip_d_fpv[s] = i_rv_plic.hw2reg.ip[s].d;
  end

  `ASSERT(ip_rd_A, rd_P(9'h0, ip_d_fpv[31:0]))

  // define local fpv variable for the multi_reg
  logic [31:0] le_q_fpv;
  for (genvar s = 0; s <= 31; s++) begin : gen_le_q
    assign le_q_fpv[s] = 1 ?
        i_rv_plic.reg2hw.le[s].q : le_q_fpv[s];
  end

  `ASSERT(le_wr_A, wr_P(9'h4, le_q_fpv[31:0], 1, 'hffffffff))
  `ASSERT(le_rd_A, rd_P(9'h4, le_q_fpv[31:0]))

  `ASSERT(prio0_wr_A, wr_P(9'h8, i_rv_plic.reg2hw.prio0.q, 1, 'h7))
  `ASSERT(prio0_rd_A, rd_P(9'h8, i_rv_plic.reg2hw.prio0.q))

  `ASSERT(prio1_wr_A, wr_P(9'hc, i_rv_plic.reg2hw.prio1.q, 1, 'h7))
  `ASSERT(prio1_rd_A, rd_P(9'hc, i_rv_plic.reg2hw.prio1.q))

  `ASSERT(prio2_wr_A, wr_P(9'h10, i_rv_plic.reg2hw.prio2.q, 1, 'h7))
  `ASSERT(prio2_rd_A, rd_P(9'h10, i_rv_plic.reg2hw.prio2.q))

  `ASSERT(prio3_wr_A, wr_P(9'h14, i_rv_plic.reg2hw.prio3.q, 1, 'h7))
  `ASSERT(prio3_rd_A, rd_P(9'h14, i_rv_plic.reg2hw.prio3.q))

  `ASSERT(prio4_wr_A, wr_P(9'h18, i_rv_plic.reg2hw.prio4.q, 1, 'h7))
  `ASSERT(prio4_rd_A, rd_P(9'h18, i_rv_plic.reg2hw.prio4.q))

  `ASSERT(prio5_wr_A, wr_P(9'h1c, i_rv_plic.reg2hw.prio5.q, 1, 'h7))
  `ASSERT(prio5_rd_A, rd_P(9'h1c, i_rv_plic.reg2hw.prio5.q))

  `ASSERT(prio6_wr_A, wr_P(9'h20, i_rv_plic.reg2hw.prio6.q, 1, 'h7))
  `ASSERT(prio6_rd_A, rd_P(9'h20, i_rv_plic.reg2hw.prio6.q))

  `ASSERT(prio7_wr_A, wr_P(9'h24, i_rv_plic.reg2hw.prio7.q, 1, 'h7))
  `ASSERT(prio7_rd_A, rd_P(9'h24, i_rv_plic.reg2hw.prio7.q))

  `ASSERT(prio8_wr_A, wr_P(9'h28, i_rv_plic.reg2hw.prio8.q, 1, 'h7))
  `ASSERT(prio8_rd_A, rd_P(9'h28, i_rv_plic.reg2hw.prio8.q))

  `ASSERT(prio9_wr_A, wr_P(9'h2c, i_rv_plic.reg2hw.prio9.q, 1, 'h7))
  `ASSERT(prio9_rd_A, rd_P(9'h2c, i_rv_plic.reg2hw.prio9.q))

  `ASSERT(prio10_wr_A, wr_P(9'h30, i_rv_plic.reg2hw.prio10.q, 1, 'h7))
  `ASSERT(prio10_rd_A, rd_P(9'h30, i_rv_plic.reg2hw.prio10.q))

  `ASSERT(prio11_wr_A, wr_P(9'h34, i_rv_plic.reg2hw.prio11.q, 1, 'h7))
  `ASSERT(prio11_rd_A, rd_P(9'h34, i_rv_plic.reg2hw.prio11.q))

  `ASSERT(prio12_wr_A, wr_P(9'h38, i_rv_plic.reg2hw.prio12.q, 1, 'h7))
  `ASSERT(prio12_rd_A, rd_P(9'h38, i_rv_plic.reg2hw.prio12.q))

  `ASSERT(prio13_wr_A, wr_P(9'h3c, i_rv_plic.reg2hw.prio13.q, 1, 'h7))
  `ASSERT(prio13_rd_A, rd_P(9'h3c, i_rv_plic.reg2hw.prio13.q))

  `ASSERT(prio14_wr_A, wr_P(9'h40, i_rv_plic.reg2hw.prio14.q, 1, 'h7))
  `ASSERT(prio14_rd_A, rd_P(9'h40, i_rv_plic.reg2hw.prio14.q))

  `ASSERT(prio15_wr_A, wr_P(9'h44, i_rv_plic.reg2hw.prio15.q, 1, 'h7))
  `ASSERT(prio15_rd_A, rd_P(9'h44, i_rv_plic.reg2hw.prio15.q))

  `ASSERT(prio16_wr_A, wr_P(9'h48, i_rv_plic.reg2hw.prio16.q, 1, 'h7))
  `ASSERT(prio16_rd_A, rd_P(9'h48, i_rv_plic.reg2hw.prio16.q))

  `ASSERT(prio17_wr_A, wr_P(9'h4c, i_rv_plic.reg2hw.prio17.q, 1, 'h7))
  `ASSERT(prio17_rd_A, rd_P(9'h4c, i_rv_plic.reg2hw.prio17.q))

  `ASSERT(prio18_wr_A, wr_P(9'h50, i_rv_plic.reg2hw.prio18.q, 1, 'h7))
  `ASSERT(prio18_rd_A, rd_P(9'h50, i_rv_plic.reg2hw.prio18.q))

  `ASSERT(prio19_wr_A, wr_P(9'h54, i_rv_plic.reg2hw.prio19.q, 1, 'h7))
  `ASSERT(prio19_rd_A, rd_P(9'h54, i_rv_plic.reg2hw.prio19.q))

  `ASSERT(prio20_wr_A, wr_P(9'h58, i_rv_plic.reg2hw.prio20.q, 1, 'h7))
  `ASSERT(prio20_rd_A, rd_P(9'h58, i_rv_plic.reg2hw.prio20.q))

  `ASSERT(prio21_wr_A, wr_P(9'h5c, i_rv_plic.reg2hw.prio21.q, 1, 'h7))
  `ASSERT(prio21_rd_A, rd_P(9'h5c, i_rv_plic.reg2hw.prio21.q))

  `ASSERT(prio22_wr_A, wr_P(9'h60, i_rv_plic.reg2hw.prio22.q, 1, 'h7))
  `ASSERT(prio22_rd_A, rd_P(9'h60, i_rv_plic.reg2hw.prio22.q))

  `ASSERT(prio23_wr_A, wr_P(9'h64, i_rv_plic.reg2hw.prio23.q, 1, 'h7))
  `ASSERT(prio23_rd_A, rd_P(9'h64, i_rv_plic.reg2hw.prio23.q))

  `ASSERT(prio24_wr_A, wr_P(9'h68, i_rv_plic.reg2hw.prio24.q, 1, 'h7))
  `ASSERT(prio24_rd_A, rd_P(9'h68, i_rv_plic.reg2hw.prio24.q))

  `ASSERT(prio25_wr_A, wr_P(9'h6c, i_rv_plic.reg2hw.prio25.q, 1, 'h7))
  `ASSERT(prio25_rd_A, rd_P(9'h6c, i_rv_plic.reg2hw.prio25.q))

  `ASSERT(prio26_wr_A, wr_P(9'h70, i_rv_plic.reg2hw.prio26.q, 1, 'h7))
  `ASSERT(prio26_rd_A, rd_P(9'h70, i_rv_plic.reg2hw.prio26.q))

  `ASSERT(prio27_wr_A, wr_P(9'h74, i_rv_plic.reg2hw.prio27.q, 1, 'h7))
  `ASSERT(prio27_rd_A, rd_P(9'h74, i_rv_plic.reg2hw.prio27.q))

  `ASSERT(prio28_wr_A, wr_P(9'h78, i_rv_plic.reg2hw.prio28.q, 1, 'h7))
  `ASSERT(prio28_rd_A, rd_P(9'h78, i_rv_plic.reg2hw.prio28.q))

  `ASSERT(prio29_wr_A, wr_P(9'h7c, i_rv_plic.reg2hw.prio29.q, 1, 'h7))
  `ASSERT(prio29_rd_A, rd_P(9'h7c, i_rv_plic.reg2hw.prio29.q))

  `ASSERT(prio30_wr_A, wr_P(9'h80, i_rv_plic.reg2hw.prio30.q, 1, 'h7))
  `ASSERT(prio30_rd_A, rd_P(9'h80, i_rv_plic.reg2hw.prio30.q))

  `ASSERT(prio31_wr_A, wr_P(9'h84, i_rv_plic.reg2hw.prio31.q, 1, 'h7))
  `ASSERT(prio31_rd_A, rd_P(9'h84, i_rv_plic.reg2hw.prio31.q))

  // define local fpv variable for the multi_reg
  logic [31:0] ie0_q_fpv;
  for (genvar s = 0; s <= 31; s++) begin : gen_ie0_q
    assign ie0_q_fpv[s] = 1 ?
        i_rv_plic.reg2hw.ie0[s].q : ie0_q_fpv[s];
  end

  `ASSERT(ie0_wr_A, wr_P(9'h100, ie0_q_fpv[31:0], 1, 'hffffffff))
  `ASSERT(ie0_rd_A, rd_P(9'h100, ie0_q_fpv[31:0]))

  `ASSERT(threshold0_wr_A, wr_P(9'h104, i_rv_plic.reg2hw.threshold0.q, 1, 'h7))
  `ASSERT(threshold0_rd_A, rd_P(9'h104, i_rv_plic.reg2hw.threshold0.q))

  `ASSERT(cc0_wr_A, wr_ext_P(9'h108, i_rv_plic.reg2hw.cc0.q, 1, 'h3f))
  `ASSERT(cc0_rd_A, rd_ext_P(9'h108, i_rv_plic.hw2reg.cc0.d))

  `ASSERT(msip0_wr_A, wr_P(9'h10c, i_rv_plic.reg2hw.msip0.q, 1, 'h1))
  `ASSERT(msip0_rd_A, rd_P(9'h10c, i_rv_plic.reg2hw.msip0.q))

endmodule