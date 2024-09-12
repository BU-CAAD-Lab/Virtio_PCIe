module xdma_xcvu13p (
  sys_clk,
  sys_clk_gt,
  sys_rst_n,
  user_lnk_up,
  pci_exp_txp,
  pci_exp_txn,
  pci_exp_rxp,
  pci_exp_rxn,
  axi_aclk,
  axi_aresetn,
  usr_irq_req,
  usr_irq_ack,
  msi_enable,
  msix_enable,
  msi_vector_width,
  m_axi_awready,
  m_axi_wready,
  m_axi_bid,
  m_axi_bresp,
  m_axi_bvalid,
  m_axi_arready,
  m_axi_rid,
  m_axi_rdata,
  m_axi_rresp,
  m_axi_rlast,
  m_axi_rvalid,
  m_axi_awid,
  m_axi_awaddr,
  m_axi_awlen,
  m_axi_awsize,
  m_axi_awburst,
  m_axi_awprot,
  m_axi_awvalid,
  m_axi_awlock,
  m_axi_awcache,
  m_axi_wdata,
  m_axi_wstrb,
  m_axi_wlast,
  m_axi_wvalid,
  m_axi_bready,
  m_axi_arid,
  m_axi_araddr,
  m_axi_arlen,
  m_axi_arsize,
  m_axi_arburst,
  m_axi_arprot,
  m_axi_arvalid,
  m_axi_arlock,
  m_axi_arcache,
  m_axi_rready,
  m_axil_awaddr,
  m_axil_awprot,
  m_axil_awvalid,
  m_axil_awready,
  m_axil_wdata,
  m_axil_wstrb,
  m_axil_wvalid,
  m_axil_wready,
  m_axil_bvalid,
  m_axil_bresp,
  m_axil_bready,
  m_axil_araddr,
  m_axil_arprot,
  m_axil_arvalid,
  m_axil_arready,
  m_axil_rdata,
  m_axil_rresp,
  m_axil_rvalid,
  m_axil_rready,
  s_axil_awaddr,
  s_axil_awprot,
  s_axil_awvalid,
  s_axil_awready,
  s_axil_wdata,
  s_axil_wstrb,
  s_axil_wvalid,
  s_axil_wready,
  s_axil_bvalid,
  s_axil_bresp,
  s_axil_bready,
  s_axil_araddr,
  s_axil_arprot,
  s_axil_arvalid,
  s_axil_arready,
  s_axil_rdata,
  s_axil_rresp,
  s_axil_rvalid,
  s_axil_rready,
  c2h_dsc_byp_ready_0,
  c2h_dsc_byp_src_addr_0,
  c2h_dsc_byp_dst_addr_0,
  c2h_dsc_byp_len_0,
  c2h_dsc_byp_ctl_0,
  c2h_dsc_byp_load_0,
  h2c_dsc_byp_ready_0,
  h2c_dsc_byp_src_addr_0,
  h2c_dsc_byp_dst_addr_0,
  h2c_dsc_byp_len_0,
  h2c_dsc_byp_ctl_0,
  h2c_dsc_byp_load_0,
  c2h_sts_0,
  h2c_sts_0,
  cfg_ext_read_received,
  cfg_ext_write_received,
  cfg_ext_register_number,
  cfg_ext_function_number,
  cfg_ext_write_data,
  cfg_ext_write_byte_enable,
  cfg_ext_read_data,
  cfg_ext_read_data_valid
);

input wire sys_clk;
input wire sys_clk_gt;
input wire sys_rst_n;
output wire user_lnk_up;
output wire [15 : 0] pci_exp_txp;
output wire [15 : 0] pci_exp_txn;
input wire [15 : 0] pci_exp_rxp;
input wire [15 : 0] pci_exp_rxn;
output wire axi_aclk;
output wire axi_aresetn;
input wire [3 : 0] usr_irq_req;
output wire [3 : 0] usr_irq_ack;
output wire msi_enable;
output wire msix_enable;
output wire [2 : 0] msi_vector_width;
input wire m_axi_awready;
input wire m_axi_wready;
input wire [3 : 0] m_axi_bid;
input wire [1 : 0] m_axi_bresp;
input wire m_axi_bvalid;
input wire m_axi_arready;
input wire [3 : 0] m_axi_rid;
input wire [127 : 0] m_axi_rdata;
input wire [1 : 0] m_axi_rresp;
input wire m_axi_rlast;
input wire m_axi_rvalid;
output wire [3 : 0] m_axi_awid;
output wire [63 : 0] m_axi_awaddr;
output wire [7 : 0] m_axi_awlen;
output wire [2 : 0] m_axi_awsize;
output wire [1 : 0] m_axi_awburst;
output wire [2 : 0] m_axi_awprot;
output wire m_axi_awvalid;
output wire m_axi_awlock;
output wire [3 : 0] m_axi_awcache;
output wire [127 : 0] m_axi_wdata;
output wire [15 : 0] m_axi_wstrb;
output wire m_axi_wlast;
output wire m_axi_wvalid;
output wire m_axi_bready;
output wire [3 : 0] m_axi_arid;
output wire [63 : 0] m_axi_araddr;
output wire [7 : 0] m_axi_arlen;
output wire [2 : 0] m_axi_arsize;
output wire [1 : 0] m_axi_arburst;
output wire [2 : 0] m_axi_arprot;
output wire m_axi_arvalid;
output wire m_axi_arlock;
output wire [3 : 0] m_axi_arcache;
output wire m_axi_rready;
output wire [31 : 0] m_axil_awaddr;
output wire [2 : 0] m_axil_awprot;
output wire m_axil_awvalid;
input wire m_axil_awready;
output wire [31 : 0] m_axil_wdata;
output wire [3 : 0] m_axil_wstrb;
output wire m_axil_wvalid;
input wire m_axil_wready;
input wire m_axil_bvalid;
input wire [1 : 0] m_axil_bresp;
output wire m_axil_bready;
output wire [31 : 0] m_axil_araddr;
output wire [2 : 0] m_axil_arprot;
output wire m_axil_arvalid;
input wire m_axil_arready;
input wire [31 : 0] m_axil_rdata;
input wire [1 : 0] m_axil_rresp;
input wire m_axil_rvalid;
output wire m_axil_rready;
input wire [31 : 0] s_axil_awaddr;
input wire [2 : 0] s_axil_awprot;
input wire s_axil_awvalid;
output wire s_axil_awready;
input wire [31 : 0] s_axil_wdata;
input wire [3 : 0] s_axil_wstrb;
input wire s_axil_wvalid;
output wire s_axil_wready;
output wire s_axil_bvalid;
output wire [1 : 0] s_axil_bresp;
input wire s_axil_bready;
input wire [31 : 0] s_axil_araddr;
input wire [2 : 0] s_axil_arprot;
input wire s_axil_arvalid;
output wire s_axil_arready;
output wire [31 : 0] s_axil_rdata;
output wire [1 : 0] s_axil_rresp;
output wire s_axil_rvalid;
input wire s_axil_rready;
output wire c2h_dsc_byp_ready_0;
input wire [63 : 0] c2h_dsc_byp_src_addr_0;
input wire [63 : 0] c2h_dsc_byp_dst_addr_0;
input wire [27 : 0] c2h_dsc_byp_len_0;
input wire [15 : 0] c2h_dsc_byp_ctl_0;
input wire c2h_dsc_byp_load_0;
output wire h2c_dsc_byp_ready_0;
input wire [63 : 0] h2c_dsc_byp_src_addr_0;
input wire [63 : 0] h2c_dsc_byp_dst_addr_0;
input wire [27 : 0] h2c_dsc_byp_len_0;
input wire [15 : 0] h2c_dsc_byp_ctl_0;
input wire h2c_dsc_byp_load_0;
output wire [7 : 0] c2h_sts_0;
output wire [7 : 0] h2c_sts_0;
output wire cfg_ext_read_received;
output wire cfg_ext_write_received;
output wire [9 : 0] cfg_ext_register_number;
output wire [7 : 0] cfg_ext_function_number;
output wire [31 : 0] cfg_ext_write_data;
output wire [3 : 0] cfg_ext_write_byte_enable;
input wire [31 : 0] cfg_ext_read_data;
input wire cfg_ext_read_data_valid;


xdma_0 xdma_ip_inst(
  .sys_clk(sys_clk),
  .sys_clk_gt(sys_clk_gt),
  .sys_rst_n(sys_rst_n),
  .user_lnk_up(user_lnk_up),
  .pci_exp_txp(pci_exp_txp),
  .pci_exp_txn(pci_exp_txn),
  .pci_exp_rxp(pci_exp_rxp),
  .pci_exp_rxn(pci_exp_rxn),
  .axi_aclk(axi_aclk),
  .axi_aresetn(axi_aresetn),
  .usr_irq_req(usr_irq_req),
  .usr_irq_ack(usr_irq_ack),
  .msi_enable(msi_enable),
  .msix_enable(msix_enable),
  .msi_vector_width(msi_vector_width),
  .m_axi_awready(m_axi_awready),
  .m_axi_wready(m_axi_wready),
  .m_axi_bid(m_axi_bid),
  .m_axi_bresp(m_axi_bresp),
  .m_axi_bvalid(m_axi_bvalid),
  .m_axi_arready(m_axi_arready),
  .m_axi_rid(m_axi_rid),
  .m_axi_rdata(m_axi_rdata),
  .m_axi_rresp(m_axi_rresp),
  .m_axi_rlast(m_axi_rlast),
  .m_axi_rvalid(m_axi_rvalid),
  .m_axi_awid(m_axi_awid),
  .m_axi_awaddr(m_axi_awaddr),
  .m_axi_awlen(m_axi_awlen),
  .m_axi_awsize(m_axi_awsize),
  .m_axi_awburst(m_axi_awburst),
  .m_axi_awprot(m_axi_awprot),
  .m_axi_awvalid(m_axi_awvalid),
  .m_axi_awlock(m_axi_awlock),
  .m_axi_awcache(m_axi_awcache),
  .m_axi_wdata(m_axi_wdata),
  .m_axi_wstrb(m_axi_wstrb),
  .m_axi_wlast(m_axi_wlast),
  .m_axi_wvalid(m_axi_wvalid),
  .m_axi_bready(m_axi_bready),
  .m_axi_arid(m_axi_arid),
  .m_axi_araddr(m_axi_araddr),
  .m_axi_arlen(m_axi_arlen),
  .m_axi_arsize(m_axi_arsize),
  .m_axi_arburst(m_axi_arburst),
  .m_axi_arprot(m_axi_arprot),
  .m_axi_arvalid(m_axi_arvalid),
  .m_axi_arlock(m_axi_arlock),
  .m_axi_arcache(m_axi_arcache),
  .m_axi_rready(m_axi_rready),
  .m_axil_awaddr(m_axil_awaddr),
  .m_axil_awprot(m_axil_awprot),
  .m_axil_awvalid(m_axil_awvalid),
  .m_axil_awready(m_axil_awready),
  .m_axil_wdata(m_axil_wdata),
  .m_axil_wstrb(m_axil_wstrb),
  .m_axil_wvalid(m_axil_wvalid),
  .m_axil_wready(m_axil_wready),
  .m_axil_bvalid(m_axil_bvalid),
  .m_axil_bresp(m_axil_bresp),
  .m_axil_bready(m_axil_bready),
  .m_axil_araddr(m_axil_araddr),
  .m_axil_arprot(m_axil_arprot),
  .m_axil_arvalid(m_axil_arvalid),
  .m_axil_arready(m_axil_arready),
  .m_axil_rdata(m_axil_rdata),
  .m_axil_rresp(m_axil_rresp),
  .m_axil_rvalid(m_axil_rvalid),
  .m_axil_rready(m_axil_rready),
  .s_axil_awaddr(s_axil_awaddr),
  .s_axil_awprot(s_axil_awprot),
  .s_axil_awvalid(s_axil_awvalid),
  .s_axil_awready(s_axil_awready),
  .s_axil_wdata(s_axil_wdata),
  .s_axil_wstrb(s_axil_wstrb),
  .s_axil_wvalid(s_axil_wvalid),
  .s_axil_wready(s_axil_wready),
  .s_axil_bvalid(s_axil_bvalid),
  .s_axil_bresp(s_axil_bresp),
  .s_axil_bready(s_axil_bready),
  .s_axil_araddr(s_axil_araddr),
  .s_axil_arprot(s_axil_arprot),
  .s_axil_arvalid(s_axil_arvalid),
  .s_axil_arready(s_axil_arready),
  .s_axil_rdata(s_axil_rdata),
  .s_axil_rresp(s_axil_rresp),
  .s_axil_rvalid(s_axil_rvalid),
  .s_axil_rready(s_axil_rready),
  .c2h_dsc_byp_ready_0(c2h_dsc_byp_ready_0),
  .c2h_dsc_byp_src_addr_0(c2h_dsc_byp_src_addr_0),
  .c2h_dsc_byp_dst_addr_0(c2h_dsc_byp_dst_addr_0),
  .c2h_dsc_byp_len_0(c2h_dsc_byp_len_0),
  .c2h_dsc_byp_ctl_0(c2h_dsc_byp_ctl_0),
  .c2h_dsc_byp_load_0(c2h_dsc_byp_load_0),
  .h2c_dsc_byp_ready_0(h2c_dsc_byp_ready_0),
  .h2c_dsc_byp_src_addr_0(h2c_dsc_byp_src_addr_0),
  .h2c_dsc_byp_dst_addr_0(h2c_dsc_byp_dst_addr_0),
  .h2c_dsc_byp_len_0(h2c_dsc_byp_len_0),
  .h2c_dsc_byp_ctl_0(h2c_dsc_byp_ctl_0),
  .h2c_dsc_byp_load_0(h2c_dsc_byp_load_0),
  .c2h_sts_0(c2h_sts_0),
  .h2c_sts_0(h2c_sts_0),
  .cfg_ext_read_received(cfg_ext_read_received),
  .cfg_ext_write_received(cfg_ext_write_received),
  .cfg_ext_register_number(cfg_ext_register_number),
  .cfg_ext_function_number(cfg_ext_function_number),
  .cfg_ext_write_data(cfg_ext_write_data),
  .cfg_ext_write_byte_enable(cfg_ext_write_byte_enable),
  .cfg_ext_read_data(cfg_ext_read_data),
  .cfg_ext_read_data_valid(cfg_ext_read_data_valid)
);






endmodule
