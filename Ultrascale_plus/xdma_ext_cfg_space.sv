module xdma_ext_cfg_space (
  input clk,
  input rst,
  
(* mark_debug="true" *)  input  logic [7 :0] cfg_ext_function_number,
(* mark_debug="true" *)  input  logic        cfg_ext_read_received,
(* mark_debug="true" *)  input  logic [9 :0] cfg_ext_register_number,
(* mark_debug="true" *)  input  logic [3 :0] cfg_ext_write_byte_enable,
(* mark_debug="true" *)  input  logic [31:0] cfg_ext_write_data,
(* mark_debug="true" *)  input  logic        cfg_ext_write_received,
(* mark_debug="true" *)  output logic [31:0] cfg_ext_read_data,
(* mark_debug="true" *)  output logic        cfg_ext_read_data_valid
);

assign cfg_ext_read_data = (cfg_ext_register_number >= 10'h120 & cfg_ext_register_number <= 10'h138) ? cfg_space[cfg_addr] : 32'd0;

always_ff @(posedge clk)begin
  if(rst)begin
    cfg_ext_read_data_valid <= 1'b0;
  end
  else begin
    cfg_ext_read_data_valid <= (cfg_ext_register_number >= 10'h120 & cfg_ext_register_number <= 10'h13F) ? cfg_ext_read_received : 1'b0;
  end
end

// B0 -> 1011 0000 >> 2 = 0010 1100 = 2C
// FF -> 1111 1111 >> 2 = 0011 0000 = 3F

// 480 -> 0100 1000 0000 >> 2 = 01 0010 0000 (120)
// 4FF -> 0100 1111 1111 >> 2 = 01 0011 1111 (13F)
// Total bytes for VirtIO capabilities = 24*4 = 96 Bytes (0x60)
// 0x480 + 0x60 = 0x4E0
// 4E0 -> 0100 1110 0000 >> 2 = 01 0011 1000 (138)

  // Configuration space registers.
  logic [23:0][31:0] cfg_space;

  // Address to access config space
 (* mark_debug="true" *) logic [9:0] cfg_addr;

  assign cfg_addr = cfg_ext_register_number - 10'h120;

/*  // Configurations space
  assign cfg_space[0]  = 32'h0001000B;  // {le16 cap_rev:4 | le16 cap_vndr}
  assign cfg_space[1]  = 32'h00010000;  // {le16 cfg_type  | le16 cap_next:12}
  assign cfg_space[2]  = 32'h00180001;  // {le16 cap_len:12| le16 cfg_rev:4} //TODO:cap_len
  assign cfg_space[3]  = 32'h00000000;  // {u8 padding[2]  | u8 id | u8 bar}
  assign cfg_space[4]  = 32'h00000000;  // {le32 offset}
  assign cfg_space[5]  = 32'h00000038;  // {le32 length}
  assign cfg_space[6]  = 32'h00000000;  // 
  assign cfg_space[7]  = 32'h00000000;  // 
  assign cfg_space[8]  = 32'h00000000;  // 
  assign cfg_space[9]  = 32'h00000000;  // 
  assign cfg_space[10] = 32'h00000000;  // 
  assign cfg_space[11] = 32'h00000000;  // 
  assign cfg_space[12] = 32'h00000000;  // 
  assign cfg_space[13] = 32'h00000000;  // 
  assign cfg_space[14] = 32'h00000000;  // 
  assign cfg_space[15] = 32'h00000000;  // 
  assign cfg_space[16] = 32'h00000000;  // 
  assign cfg_space[17] = 32'h00000000;  // 
  assign cfg_space[18] = 32'h00000000;  // 
  assign cfg_space[19] = 32'h00000000;  // 
  assign cfg_space[20] = 32'h00000000;  // 
  assign cfg_space[21] = 32'h00000000;  // 
*/


  // Configurations space
  assign cfg_space[0]  = 32'h4A01000B;  // 0x480 (ISR) 
  assign cfg_space[1]  = 32'h01410003;  // 0x484
  assign cfg_space[2]  = 32'h00000000;  // 0x488
  assign cfg_space[3]  = 32'h00000200;  // 0x48c
  assign cfg_space[4]  = 32'h00000004;  // 0x490
  assign cfg_space[5]  = 32'h00000000;  // 0x494
  assign cfg_space[6]  = 32'h00000000;  // 0x498
  assign cfg_space[7]  = 32'h00000000;  // 0x49c
  assign cfg_space[8]  = 32'h4B41000B;  // 0x4a0 (Common config.)
  assign cfg_space[9]  = 32'h01410001;  // 0x4a4 
  assign cfg_space[10] = 32'h00000000;  // 0x4a8
  assign cfg_space[11] = 32'h00000000;  // 0x4ac
  assign cfg_space[12] = 32'h00000038;  // 0x4b0
  assign cfg_space[13] = 32'h4CC1000B;  // 0x4b4 (Notification)
  assign cfg_space[14] = 32'h01810002;  // 0x4b8 
  assign cfg_space[15] = 32'h00000000;  // 0x4bc
  assign cfg_space[16] = 32'h00000100;  // 0x4c0
  assign cfg_space[17] = 32'h00000100;  // 0x4c4
  assign cfg_space[18] = 32'h00000001;  // 0x4c8
  assign cfg_space[19] = 32'h0001000B;  // 0x4cc (Device config.)
  assign cfg_space[20] = 32'h01410004;  // 0x4d0
  assign cfg_space[21] = 32'h00000000;  // 0x4d4
  assign cfg_space[22] = 32'h00000300;  // 0x4d8
  assign cfg_space[23] = 32'h0000000C;  // 0x4dc

endmodule
