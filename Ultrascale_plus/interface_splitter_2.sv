module interface_splitter_2 #(
  DATA_WIDTH = 32,
  ADDR_WIDTH = 32,
  STRB_WIDTH = DATA_WIDTH/8
)(
  input  [1             :0] a_arvalid,
  output [1             :0] a_arready,
  input  [ADDR_WIDTH*2-1:0] a_araddr,
  input  [1             :0] a_rready,
  output [1             :0] a_rvalid,
  output [DATA_WIDTH*2-1:0] a_rdata,
  output [2*2-1         :0] a_rresp,
  input  [1             :0] a_awvalid,
  output [1             :0] a_awready,
  input  [ADDR_WIDTH*2-1:0] a_awaddr,
  input  [1             :0] a_wvalid,
  output [1             :0] a_wready,
  input  [DATA_WIDTH*2-1:0] a_wdata,
  input  [STRB_WIDTH*2-1:0] a_wstrb,
  input  [1             :0] a_bready,
  output [1             :0] a_bvalid,
  output [2*2-1         :0] a_bresp,

  output                  b0_arvalid,
  input                   b0_arready,
  output [ADDR_WIDTH-1:0] b0_araddr,
  output                  b0_rready,
  input                   b0_rvalid,
  input  [DATA_WIDTH-1:0] b0_rdata,
  input  [1           :0] b0_rresp,
  output                  b0_awvalid,
  input                   b0_awready,
  output [ADDR_WIDTH-1:0] b0_awaddr,
  output                  b0_wvalid,
  input                   b0_wready,
  output [DATA_WIDTH-1:0] b0_wdata,
  output [STRB_WIDTH-1:0] b0_wstrb,
  output                  b0_bready,
  input                   b0_bvalid,
  input  [1           :0] b0_bresp,

  output                  b1_arvalid,
  input                   b1_arready,
  output [ADDR_WIDTH-1:0] b1_araddr,
  output                  b1_rready,
  input                   b1_rvalid,
  input  [DATA_WIDTH-1:0] b1_rdata,
  input  [1           :0] b1_rresp,
  output                  b1_awvalid,
  input                   b1_awready,
  output [ADDR_WIDTH-1:0] b1_awaddr,
  output                  b1_wvalid,
  input                   b1_wready,
  output [DATA_WIDTH-1:0] b1_wdata,
  output [STRB_WIDTH-1:0] b1_wstrb,
  output                  b1_bready,
  input                   b1_bvalid,
  input  [1           :0] b1_bresp
);

  assign b0_arvalid                        = a_arvalid[0];
  assign a_arready[0]                      = b0_arready;
  assign b0_araddr                         = a_araddr[ADDR_WIDTH*0+:ADDR_WIDTH];
  assign b0_rready                         = a_rready[0];
  assign a_rvalid[0]                       = b0_rvalid;
  assign a_rdata[DATA_WIDTH*0+:DATA_WIDTH] = b0_rdata;
  assign a_rresp[2*0+:2]                   = b0_rresp;
  assign b0_awvalid                        = a_awvalid[0];
  assign a_awready[0]                      = b0_awready;
  assign b0_awaddr                         = a_awaddr[ADDR_WIDTH*0+:ADDR_WIDTH];
  assign b0_wvalid                         = a_wvalid[0];
  assign a_wready[0]                       = b0_wready;
  assign b0_wdata                          = a_wdata[DATA_WIDTH*0+:DATA_WIDTH];
  assign b0_wstrb                          = a_wstrb[STRB_WIDTH*0+:STRB_WIDTH];
  assign b0_bready                         = a_bready[0];
  assign a_bvalid[0]                       = b0_bvalid;
  assign a_bresp[2*0+:2]                   = b0_bresp;

  assign b1_arvalid                        = a_arvalid[1];
  assign a_arready[1]                      = b1_arready;
  assign b1_araddr                         = a_araddr[ADDR_WIDTH*1+:ADDR_WIDTH];
  assign b1_rready                         = a_rready[1];
  assign a_rvalid[1]                       = b1_rvalid;
  assign a_rdata[DATA_WIDTH*1+:DATA_WIDTH] = b1_rdata;
  assign a_rresp[2*1+:2]                   = b1_rresp;
  assign b1_awvalid                        = a_awvalid[1];
  assign a_awready[1]                      = b1_awready;
  assign b1_awaddr                         = a_awaddr[ADDR_WIDTH*1+:ADDR_WIDTH];
  assign b1_wvalid                         = a_wvalid[1];
  assign a_wready[1]                       = b1_wready;
  assign b1_wdata                          = a_wdata[DATA_WIDTH*1+:DATA_WIDTH];
  assign b1_wstrb                          = a_wstrb[STRB_WIDTH*1+:STRB_WIDTH];
  assign b1_bready                         = a_bready[1];
  assign a_bvalid[1]                       = b1_bvalid;
  assign a_bresp[2*1+:2]                   = b1_bresp;

endmodule
