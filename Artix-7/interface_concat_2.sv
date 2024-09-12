module interface_concat_2 #(
  DATA_WIDTH = 32,
  ADDR_WIDTH = 32,
  STRB_WIDTH = DATA_WIDTH/8
)(
  input                   a0_arvalid,
  output                  a0_arready,
  input  [ADDR_WIDTH-1:0] a0_araddr,
  input                   a0_rready,
  output                  a0_rvalid,
  output [DATA_WIDTH-1:0] a0_rdata,
  output [1           :0] a0_rresp,
  input                   a0_awvalid,
  output                  a0_awready,
  input  [ADDR_WIDTH-1:0] a0_awaddr,
  input                   a0_wvalid,
  output                  a0_wready,
  input  [DATA_WIDTH-1:0] a0_wdata,
  input  [STRB_WIDTH-1:0] a0_wstrb,
  input                   a0_bready,
  output                  a0_bvalid,
  output [1           :0] a0_bresp,

  input                   a1_arvalid,
  output                  a1_arready,
  input  [ADDR_WIDTH-1:0] a1_araddr,
  input                   a1_rready,
  output                  a1_rvalid,
  output [DATA_WIDTH-1:0] a1_rdata,
  output [1           :0] a1_rresp,
  input                   a1_awvalid,
  output                  a1_awready,
  input  [ADDR_WIDTH-1:0] a1_awaddr,
  input                   a1_wvalid,
  output                  a1_wready,
  input  [DATA_WIDTH-1:0] a1_wdata,
  input  [STRB_WIDTH-1:0] a1_wstrb,
  input                   a1_bready,
  output                  a1_bvalid,
  output [1           :0] a1_bresp,

  output [1             :0] b_arvalid,
  input  [1             :0] b_arready,
  output [2*ADDR_WIDTH-1:0] b_araddr,
  output [1             :0] b_rready,
  input  [1             :0] b_rvalid,
  input  [2*DATA_WIDTH-1:0] b_rdata,
  input  [2*2-1         :0] b_rresp,
  output [1             :0] b_awvalid,
  input  [1             :0] b_awready,
  output [2*ADDR_WIDTH-1:0] b_awaddr,
  output [1             :0] b_wvalid,
  input  [1             :0] b_wready,
  output [2*DATA_WIDTH-1:0] b_wdata,
  output [2*STRB_WIDTH-1:0] b_wstrb,
  output [1             :0] b_bready,
  input  [1             :0] b_bvalid,
  input  [2*2-1         :0] b_bresp
);

  assign b_arvalid  = {a1_arvalid, a0_arvalid};
  assign a0_arready = b_arready[0];
  assign a1_arready = b_arready[1];
  assign b_araddr   = {a1_araddr, a0_araddr};
  assign b_rready   = {a1_rready, a0_rready};
  assign a0_rvalid  = b_rvalid[0];
  assign a1_rvalid  = b_rvalid[1];
  assign a0_rdata   = b_rdata[0*DATA_WIDTH+:DATA_WIDTH];
  assign a1_rdata   = b_rdata[1*DATA_WIDTH+:DATA_WIDTH];
  assign a0_rresp   = b_rresp[0*2+:2];
  assign a1_rresp   = b_rresp[1*2+:2];
  assign b_awvalid  = {a1_awvalid, a0_awvalid};
  assign a0_awready = b_awready[0];
  assign a1_awready = b_awready[1];
  assign b_awaddr   = {a1_awaddr, a0_awaddr};
  assign b_wvalid   = {a1_wvalid, a0_wvalid};
  assign a0_wready  = b_wready[0];
  assign a1_wready  = b_wready[1];
  assign b_wdata    = {a1_wdata, a0_wdata};
  assign b_wstrb    = {a1_wstrb, a0_wstrb};
  assign b_bready   = {a1_bready, a0_bready};
  assign a0_bvalid  = b_bvalid[0];
  assign a1_bvalid  = b_bvalid[1];
  assign a0_bresp   = b_bresp[0*2+:2];
  assign a1_bresp   = b_bresp[1*2+:2];


endmodule
