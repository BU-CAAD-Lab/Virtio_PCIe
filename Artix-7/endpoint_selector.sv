module endpoint_selector #(
  AXI_BUS_WIDTH  = 128,
  AXI_ADDR_WIDTH = 64,
  AXI_STRB_WIDTH = AXI_BUS_WIDTH/8
)
(
  input endpoint_ctrl, // 0: Select SS, 1: select virtIO controller
  // PCIe AXI-MM interface 
  input  logic [AXI_ADDR_WIDTH-1:0] pci_axi_awaddr,
  input  logic              [7  :0] pci_axi_awlen,
  input  logic              [2  :0] pci_axi_awsize,
  input  logic              [1  :0] pci_axi_awburst,
  input  logic                      pci_axi_awvalid,
  output logic                      pci_axi_awready,
  input  logic  [AXI_BUS_WIDTH-1:0] pci_axi_wdata,
  input  logic [AXI_STRB_WIDTH-1:0] pci_axi_wstrb,
  input  logic                      pci_axi_wlast,
  input  logic                      pci_axi_wvalid,
  output logic                      pci_axi_wready,
  output logic              [1  :0] pci_axi_bresp,
  output logic                      pci_axi_bvalid,
  input  logic                      pci_axi_bready,
  input  logic [AXI_ADDR_WIDTH-1:0] pci_axi_araddr,
  input  logic              [7  :0] pci_axi_arlen,
  input  logic              [2  :0] pci_axi_arsize,
  input  logic              [1  :0] pci_axi_arburst,
  input  logic                      pci_axi_arvalid,
  output logic                      pci_axi_arready,
  output logic  [AXI_BUS_WIDTH-1:0] pci_axi_rdata,
  output logic              [1  :0] pci_axi_rresp,
  output logic                      pci_axi_rlast,
  output logic                      pci_axi_rvalid,
  input  logic                      pci_axi_rready,

  // VirtIO controller AXI-MM interface
  output logic [AXI_ADDR_WIDTH-1:0] vc_axi_awaddr,
  output logic              [7  :0] vc_axi_awlen,
  output logic              [2  :0] vc_axi_awsize,
  output logic              [1  :0] vc_axi_awburst,
  output logic                      vc_axi_awvalid,
  input  logic                      vc_axi_awready,
  output logic  [AXI_BUS_WIDTH-1:0] vc_axi_wdata,
  output logic [AXI_STRB_WIDTH-1:0] vc_axi_wstrb,
  output logic                      vc_axi_wlast,
  output logic                      vc_axi_wvalid,
  input  logic                      vc_axi_wready,
  input  logic              [1  :0] vc_axi_bresp,
  input  logic                      vc_axi_bvalid,
  output logic                      vc_axi_bready,
  output logic [AXI_ADDR_WIDTH-1:0] vc_axi_araddr,
  output logic              [7  :0] vc_axi_arlen,
  output logic              [2  :0] vc_axi_arsize,
  output logic              [1  :0] vc_axi_arburst,
  output logic                      vc_axi_arvalid,
  input  logic                      vc_axi_arready,
  input  logic  [AXI_BUS_WIDTH-1:0] vc_axi_rdata,
  input  logic              [1  :0] vc_axi_rresp,
  input  logic                      vc_axi_rlast,
  input  logic                      vc_axi_rvalid,
  output logic                      vc_axi_rready,

  // Smart switch AXI-MM interface
  output logic [AXI_ADDR_WIDTH-1:0] ss_awaddr,
  output logic                [0:0] ss_awvalid,
  output logic              [7  :0] ss_awlen,
  output logic              [2  :0] ss_awsize,
  output logic              [1  :0] ss_awburst,
  input  logic                [0:0] ss_awready,
  output logic                [0:0] ss_wvalid,
  output logic  [AXI_BUS_WIDTH-1:0] ss_wdata,
  output logic [AXI_STRB_WIDTH-1:0] ss_wstrb,
  output logic                      ss_wlast,
  input  logic                [0:0] ss_wready,
  output logic                [0:0] ss_arvalid,
  output logic [AXI_ADDR_WIDTH-1:0] ss_araddr,
  output logic              [7  :0] ss_arlen,
  output logic              [2  :0] ss_arsize,
  output logic              [1  :0] ss_arburst,
  input  logic                [0:0] ss_arready,
  output logic                [0:0] ss_rready,
  input  logic  [AXI_BUS_WIDTH-1:0] ss_rdata,
  input  logic                      ss_rlast,
  input  logic                [1:0] ss_rresp,
  input  logic                [0:0] ss_rvalid,
  output logic                [0:0] ss_bready,
  input  logic                [1:0] ss_bresp,
  input  logic                [0:0] ss_bvalid
);


always_comb begin
  if(endpoint_ctrl)begin
    vc_axi_awaddr   = pci_axi_awaddr;
    vc_axi_awlen    = pci_axi_awlen;
    vc_axi_awsize   = pci_axi_awsize;
    vc_axi_awburst  = pci_axi_awburst;
    vc_axi_awvalid  = pci_axi_awvalid;
    vc_axi_wdata    = pci_axi_wdata;
    vc_axi_wstrb    = pci_axi_wstrb;
    vc_axi_wlast    = pci_axi_wlast;
    vc_axi_wvalid   = pci_axi_wvalid;
    vc_axi_bready   = pci_axi_bready;
    vc_axi_araddr   = pci_axi_araddr;
    vc_axi_arlen    = pci_axi_arlen;
    vc_axi_arsize   = pci_axi_arsize;
    vc_axi_arburst  = pci_axi_arburst;
    vc_axi_arvalid  = pci_axi_arvalid;
    vc_axi_rready   = pci_axi_rready;
    pci_axi_awready = vc_axi_awready;
    pci_axi_wready  = vc_axi_wready;
    pci_axi_bresp   = vc_axi_bresp;
    pci_axi_bvalid  = vc_axi_bvalid;
    pci_axi_arready = vc_axi_arready;
    pci_axi_rdata   = vc_axi_rdata;
    pci_axi_rresp   = vc_axi_rresp;
    pci_axi_rlast   = vc_axi_rlast;
    pci_axi_rvalid  = vc_axi_rvalid;
    ss_araddr       = {AXI_ADDR_WIDTH{1'b0}};
    ss_arvalid      = 1'b0;
    ss_arlen        = 8'd0;
    ss_arsize       = 3'b000;
    ss_arburst      = 2'b00;
    ss_awaddr       = {AXI_ADDR_WIDTH{1'b0}};
    ss_awvalid      = 1'b0;
    ss_awlen        = 8'd0;
    ss_awsize       = 3'b000;
    ss_awburst      = 2'b00;
    ss_wdata        = {AXI_BUS_WIDTH{1'b0}};
    ss_wstrb        = {AXI_STRB_WIDTH{1'b0}};
    ss_wvalid       = 1'b0;
    ss_wlast        = 1'b0;
    ss_rready       = 1'b0;
    ss_bready       = 1'b0;
  end
  else begin
    ss_araddr       = pci_axi_araddr;
    ss_arvalid      = pci_axi_arvalid;
    ss_arlen        = pci_axi_arlen;
    ss_arsize       = pci_axi_arsize;
    ss_arburst      = pci_axi_arburst;
    ss_awaddr       = pci_axi_awaddr;
    ss_awvalid      = pci_axi_awvalid;
    ss_awlen        = pci_axi_awlen;
    ss_awsize       = pci_axi_awsize;
    ss_awburst      = pci_axi_awburst;
    ss_wdata        = pci_axi_wdata;
    ss_wstrb        = pci_axi_wstrb;
    ss_wlast        = pci_axi_wlast;
    ss_wvalid       = pci_axi_wvalid;
    ss_rready       = pci_axi_rready;
    ss_bready       = pci_axi_bready;
    pci_axi_awready = ss_awready;
    pci_axi_wready  = ss_wready;
    pci_axi_bresp   = ss_bresp;
    pci_axi_bvalid  = ss_bvalid;
    pci_axi_arready = ss_arready;
    pci_axi_rdata   = ss_rdata;
    pci_axi_rresp   = ss_rresp;
    pci_axi_rlast   = ss_rlast;
    pci_axi_rvalid  = ss_rvalid;

    vc_axi_awaddr   = {AXI_ADDR_WIDTH{1'b0}};
    vc_axi_awlen    = 8'd0;
    vc_axi_awsize   = 3'd0;
    vc_axi_awburst  = 2'd0;
    vc_axi_awvalid  = 1'b0;
    vc_axi_wdata    = {AXI_BUS_WIDTH{1'b0}};
    vc_axi_wstrb    = {AXI_STRB_WIDTH{1'b0}};
    vc_axi_wlast    = 1'b0;
    vc_axi_wvalid   = 1'b0;
    vc_axi_bready   = 1'b0;
    vc_axi_araddr   = 1'b0;
    vc_axi_arlen    = 8'd0;
    vc_axi_arsize   = 3'd0;
    vc_axi_arburst  = 2'd0;
    vc_axi_arvalid  = 1'b0;
    vc_axi_rready   = 1'b0;
  end
end



endmodule
