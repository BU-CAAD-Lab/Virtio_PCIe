module top (
sys_clk_p,sys_clk_n,sys_rst_n,uart_tx,uart_rx,pci_exp_txp,pci_exp_txn,pci_exp_rxp,pci_exp_rxn
);
`include "parameters.vh"
input sys_clk_p;
input sys_clk_n;
input sys_rst_n;
output uart_tx;
input uart_rx;
output [3:0] pci_exp_txp;
output [3:0] pci_exp_txn;
input [3:0] pci_exp_rxp;
input [3:0] pci_exp_rxn;
//sys_reset_n_ibuf	(IBUF)
wire module_sys_reset_n_ibuf_I;
wire module_sys_reset_n_ibuf_O;


//refclk_ibuf	(IBUFDS_GTE2)
wire module_refclk_ibuf_I;
wire module_refclk_ibuf_O;
wire module_refclk_ibuf_IB;
wire module_refclk_ibuf_ODIV2;
wire module_refclk_ibuf_CEB;


//xdma_xc7_i	(xdma_xc7)
wire module_xdma_xc7_i_sys_rst_n;
wire module_xdma_xc7_i_sys_clk;
wire [3:0] module_xdma_xc7_i_pci_exp_txn;
wire [3:0] module_xdma_xc7_i_pci_exp_txp;
wire [3:0] module_xdma_xc7_i_pci_exp_rxn;
wire [3:0] module_xdma_xc7_i_pci_exp_rxp;
wire [63:0] module_xdma_xc7_i_m_axi_awaddr;
wire [7:0] module_xdma_xc7_i_m_axi_awlen;
wire [2:0] module_xdma_xc7_i_m_axi_awsize;
wire [1:0] module_xdma_xc7_i_m_axi_awburst;
wire module_xdma_xc7_i_m_axi_awvalid;
wire module_xdma_xc7_i_m_axi_awready;
wire [127:0] module_xdma_xc7_i_m_axi_wdata;
wire [15:0] module_xdma_xc7_i_m_axi_wstrb;
wire module_xdma_xc7_i_m_axi_wvalid;
wire module_xdma_xc7_i_m_axi_wlast;
wire module_xdma_xc7_i_m_axi_wready;
wire [1:0] module_xdma_xc7_i_m_axi_bresp;
wire module_xdma_xc7_i_m_axi_bvalid;
wire module_xdma_xc7_i_m_axi_bready;
wire [63:0] module_xdma_xc7_i_m_axi_araddr;
wire [7:0] module_xdma_xc7_i_m_axi_arlen;
wire [2:0] module_xdma_xc7_i_m_axi_arsize;
wire [1:0] module_xdma_xc7_i_m_axi_arburst;
wire module_xdma_xc7_i_m_axi_arvalid;
wire module_xdma_xc7_i_m_axi_arready;
wire [127:0] module_xdma_xc7_i_m_axi_rdata;
wire [1:0] module_xdma_xc7_i_m_axi_rresp;
wire module_xdma_xc7_i_m_axi_rvalid;
wire module_xdma_xc7_i_m_axi_rlast;
wire module_xdma_xc7_i_m_axi_rready;
wire module_xdma_xc7_i_m_axi_bid;
wire module_xdma_xc7_i_m_axi_rid;
wire [31:0] module_xdma_xc7_i_m_axil_awaddr;
wire module_xdma_xc7_i_m_axil_awvalid;
wire module_xdma_xc7_i_m_axil_awready;
wire [31:0] module_xdma_xc7_i_m_axil_wdata;
wire [3:0] module_xdma_xc7_i_m_axil_wstrb;
wire module_xdma_xc7_i_m_axil_wvalid;
wire module_xdma_xc7_i_m_axil_wready;
wire [1:0] module_xdma_xc7_i_m_axil_bresp;
wire module_xdma_xc7_i_m_axil_bvalid;
wire module_xdma_xc7_i_m_axil_bready;
wire [31:0] module_xdma_xc7_i_m_axil_araddr;
wire module_xdma_xc7_i_m_axil_arvalid;
wire module_xdma_xc7_i_m_axil_arready;
wire [31:0] module_xdma_xc7_i_m_axil_rdata;
wire [1:0] module_xdma_xc7_i_m_axil_rresp;
wire module_xdma_xc7_i_m_axil_rvalid;
wire module_xdma_xc7_i_m_axil_rready;
wire [31:0] module_xdma_xc7_i_s_axil_awaddr;
wire module_xdma_xc7_i_s_axil_awvalid;
wire module_xdma_xc7_i_s_axil_awready;
wire [31:0] module_xdma_xc7_i_s_axil_wdata;
wire [3:0] module_xdma_xc7_i_s_axil_wstrb;
wire module_xdma_xc7_i_s_axil_wvalid;
wire module_xdma_xc7_i_s_axil_wready;
wire [1:0] module_xdma_xc7_i_s_axil_bresp;
wire module_xdma_xc7_i_s_axil_bvalid;
wire module_xdma_xc7_i_s_axil_bready;
wire [31:0] module_xdma_xc7_i_s_axil_araddr;
wire module_xdma_xc7_i_s_axil_arvalid;
wire module_xdma_xc7_i_s_axil_arready;
wire [31:0] module_xdma_xc7_i_s_axil_rdata;
wire [1:0] module_xdma_xc7_i_s_axil_rresp;
wire module_xdma_xc7_i_s_axil_rvalid;
wire module_xdma_xc7_i_s_axil_rready;
wire module_xdma_xc7_i_s_axil_awprot;
wire module_xdma_xc7_i_s_axil_arprot;
wire module_xdma_xc7_i_c2h_dsc_byp_ready_0;
wire [63:0] module_xdma_xc7_i_c2h_dsc_byp_src_addr_0;
wire [63:0] module_xdma_xc7_i_c2h_dsc_byp_dst_addr_0;
wire [27:0] module_xdma_xc7_i_c2h_dsc_byp_len_0;
wire [15:0] module_xdma_xc7_i_c2h_dsc_byp_ctl_0;
wire module_xdma_xc7_i_c2h_dsc_byp_load_0;
wire module_xdma_xc7_i_h2c_dsc_byp_ready_0;
wire [63:0] module_xdma_xc7_i_h2c_dsc_byp_src_addr_0;
wire [63:0] module_xdma_xc7_i_h2c_dsc_byp_dst_addr_0;
wire [27:0] module_xdma_xc7_i_h2c_dsc_byp_len_0;
wire [15:0] module_xdma_xc7_i_h2c_dsc_byp_ctl_0;
wire module_xdma_xc7_i_h2c_dsc_byp_load_0;
wire [7:0] module_xdma_xc7_i_c2h_sts_0;
wire [7:0] module_xdma_xc7_i_h2c_sts_0;
wire [3:0] module_xdma_xc7_i_usr_irq_req;
wire [3:0] module_xdma_xc7_i_usr_irq_ack;
wire module_xdma_xc7_i_axi_aclk;
wire module_xdma_xc7_i_axi_aresetn;


//pcie_controller_inst	(pcie_controller)
wire module_pcie_controller_inst_clk;
wire module_pcie_controller_inst_reset;
wire [31:0] module_pcie_controller_inst_s_axil_awaddr;
wire module_pcie_controller_inst_s_axil_awvalid;
wire module_pcie_controller_inst_s_axil_awready;
wire [31:0] module_pcie_controller_inst_s_axil_wdata;
wire [3:0] module_pcie_controller_inst_s_axil_wstrb;
wire module_pcie_controller_inst_s_axil_wvalid;
wire module_pcie_controller_inst_s_axil_wready;
wire [1:0] module_pcie_controller_inst_s_axil_bresp;
wire module_pcie_controller_inst_s_axil_bvalid;
wire module_pcie_controller_inst_s_axil_bready;
wire [31:0] module_pcie_controller_inst_s_axil_araddr;
wire module_pcie_controller_inst_s_axil_arvalid;
wire module_pcie_controller_inst_s_axil_arready;
wire [31:0] module_pcie_controller_inst_s_axil_rdata;
wire [1:0] module_pcie_controller_inst_s_axil_rresp;
wire module_pcie_controller_inst_s_axil_rvalid;
wire module_pcie_controller_inst_s_axil_rready;
wire module_pcie_controller_inst_c2h_dsc_byp_ready_0;
wire [63:0] module_pcie_controller_inst_c2h_dsc_byp_src_addr_0;
wire [63:0] module_pcie_controller_inst_c2h_dsc_byp_dst_addr_0;
wire [27:0] module_pcie_controller_inst_c2h_dsc_byp_len_0;
wire [15:0] module_pcie_controller_inst_c2h_dsc_byp_ctl_0;
wire module_pcie_controller_inst_c2h_dsc_byp_load_0;
wire module_pcie_controller_inst_h2c_dsc_byp_ready_0;
wire [63:0] module_pcie_controller_inst_h2c_dsc_byp_src_addr_0;
wire [63:0] module_pcie_controller_inst_h2c_dsc_byp_dst_addr_0;
wire [27:0] module_pcie_controller_inst_h2c_dsc_byp_len_0;
wire [15:0] module_pcie_controller_inst_h2c_dsc_byp_ctl_0;
wire module_pcie_controller_inst_h2c_dsc_byp_load_0;
wire [31:0] module_pcie_controller_inst_dma_engine_config_axil_awaddr;
wire module_pcie_controller_inst_dma_engine_config_axil_awvalid;
wire module_pcie_controller_inst_dma_engine_config_axil_awready;
wire [31:0] module_pcie_controller_inst_dma_engine_config_axil_wdata;
wire [3:0] module_pcie_controller_inst_dma_engine_config_axil_wstrb;
wire module_pcie_controller_inst_dma_engine_config_axil_wvalid;
wire module_pcie_controller_inst_dma_engine_config_axil_wready;
wire [1:0] module_pcie_controller_inst_dma_engine_config_axil_bresp;
wire module_pcie_controller_inst_dma_engine_config_axil_bvalid;
wire module_pcie_controller_inst_dma_engine_config_axil_bready;
wire [31:0] module_pcie_controller_inst_dma_engine_config_axil_araddr;
wire module_pcie_controller_inst_dma_engine_config_axil_arvalid;
wire module_pcie_controller_inst_dma_engine_config_axil_arready;
wire [31:0] module_pcie_controller_inst_dma_engine_config_axil_rdata;
wire [1:0] module_pcie_controller_inst_dma_engine_config_axil_rresp;
wire module_pcie_controller_inst_dma_engine_config_axil_rvalid;
wire module_pcie_controller_inst_dma_engine_config_axil_rready;
wire module_pcie_controller_inst_endpoint_ctrl;
wire [63:0] module_pcie_controller_inst_s_axi_awaddr;
wire [7:0] module_pcie_controller_inst_s_axi_awlen;
wire [2:0] module_pcie_controller_inst_s_axi_awsize;
wire [1:0] module_pcie_controller_inst_s_axi_awburst;
wire module_pcie_controller_inst_s_axi_awvalid;
wire module_pcie_controller_inst_s_axi_awready;
wire [127:0] module_pcie_controller_inst_s_axi_wdata;
wire [15:0] module_pcie_controller_inst_s_axi_wstrb;
wire module_pcie_controller_inst_s_axi_wvalid;
wire module_pcie_controller_inst_s_axi_wlast;
wire module_pcie_controller_inst_s_axi_wready;
wire [1:0] module_pcie_controller_inst_s_axi_bresp;
wire module_pcie_controller_inst_s_axi_bvalid;
wire module_pcie_controller_inst_s_axi_bready;
wire [63:0] module_pcie_controller_inst_s_axi_araddr;
wire [7:0] module_pcie_controller_inst_s_axi_arlen;
wire [2:0] module_pcie_controller_inst_s_axi_arsize;
wire [1:0] module_pcie_controller_inst_s_axi_arburst;
wire module_pcie_controller_inst_s_axi_arvalid;
wire module_pcie_controller_inst_s_axi_arready;
wire [127:0] module_pcie_controller_inst_s_axi_rdata;
wire [1:0] module_pcie_controller_inst_s_axi_rresp;
wire module_pcie_controller_inst_s_axi_rvalid;
wire module_pcie_controller_inst_s_axi_rlast;
wire module_pcie_controller_inst_s_axi_rready;
wire module_pcie_controller_inst_s_axi_wvalid_to_mem;
wire [15:0] module_pcie_controller_inst_s_axi_wstrb_to_mem;
wire module_pcie_controller_inst_s_axi_rvalid_from_mem;
wire module_pcie_controller_inst_s_axi_wready_from_mem;
wire module_pcie_controller_inst_s_axi_rready_to_mem;
wire module_pcie_controller_inst_s_axi_bready_to_mem;
wire module_pcie_controller_inst_s_axi_bvalid_from_mem;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_m_axil_awaddr;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_awvalid;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_awready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_m_axil_wdata;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_wvalid;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_wready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 4)-1:0] module_pcie_controller_inst_m_axil_wstrb;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 2)-1:0] module_pcie_controller_inst_m_axil_bresp;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_bvalid;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_bready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_m_axil_araddr;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_arvalid;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_arready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_m_axil_rdata;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 2)-1:0] module_pcie_controller_inst_m_axil_rresp;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_rvalid;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 1)-1:0] module_pcie_controller_inst_m_axil_rready;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_interrupt_usr;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_interrupt_usr_ack;
wire [7:0] module_pcie_controller_inst_c2h_sts_0;
wire [7:0] module_pcie_controller_inst_h2c_sts_0;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_cfg_intf_axil_awaddr;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_awvalid;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_awready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_cfg_intf_axil_wdata;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 4)-1:0] module_pcie_controller_inst_cfg_intf_axil_wstrb;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_wvalid;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_wready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 2)-1:0] module_pcie_controller_inst_cfg_intf_axil_bresp;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_bvalid;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_bready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_cfg_intf_axil_araddr;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_arvalid;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_arready;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 32)-1:0] module_pcie_controller_inst_cfg_intf_axil_rdata;
wire [(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES * 2)-1:0] module_pcie_controller_inst_cfg_intf_axil_rresp;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_rvalid;
wire [PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES-1:0] module_pcie_controller_inst_cfg_intf_axil_rready;
wire [3:0] module_pcie_controller_inst_usr_irq_req;
wire [3:0] module_pcie_controller_inst_usr_irq_ack;


//debug	(uart_axi)
wire module_debug_clk;
wire module_debug_rst;
wire [PARAMETER_DEBUG_ADDR_WIDTH-1:0] module_debug_a_axi_araddr;
wire module_debug_a_axi_arvalid;
wire module_debug_a_axi_arready;
wire [PARAMETER_DEBUG_ADDR_WIDTH-1:0] module_debug_a_axi_awaddr;
wire module_debug_a_axi_awvalid;
wire module_debug_a_axi_awready;
wire [PARAMETER_DEBUG_DATA_WIDTH-1:0] module_debug_a_axi_rdata;
wire module_debug_a_axi_rvalid;
wire module_debug_a_axi_rready;
wire [PARAMETER_DEBUG_DATA_WIDTH-1:0] module_debug_a_axi_wdata;
wire [(PARAMETER_DEBUG_DATA_WIDTH >> 3)-1:0] module_debug_a_axi_wstrb;
wire module_debug_a_axi_wvalid;
wire module_debug_a_axi_wready;
wire module_debug_a_b_ready;
wire [1:0] module_debug_a_b_response;
wire module_debug_a_b_valid;
wire module_debug_urx;
wire module_debug_utx;


//bram_intf0_access_ctrl	(ss_access_controller)
wire module_bram_intf0_access_ctrl_clk;
wire module_bram_intf0_access_ctrl_reset;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_arvalid;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_arready;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_rvalid;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_rready;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_awvalid;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_awready;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_bvalid;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS-1:0] module_bram_intf0_access_ctrl_bready;
wire [PARAMETER_BRAM_INTF0_ACCESS_CTRL_PORT_IDX_BITS-1:0] module_bram_intf0_access_ctrl_group_select;


//endpoint_select_inst	(endpoint_selector)
wire module_endpoint_select_inst_endpoint_ctrl;
wire [63:0] module_endpoint_select_inst_pci_axi_awaddr;
wire [7:0] module_endpoint_select_inst_pci_axi_awlen;
wire [2:0] module_endpoint_select_inst_pci_axi_awsize;
wire [1:0] module_endpoint_select_inst_pci_axi_awburst;
wire module_endpoint_select_inst_pci_axi_awvalid;
wire module_endpoint_select_inst_pci_axi_awready;
wire [127:0] module_endpoint_select_inst_pci_axi_wdata;
wire [15:0] module_endpoint_select_inst_pci_axi_wstrb;
wire module_endpoint_select_inst_pci_axi_wvalid;
wire module_endpoint_select_inst_pci_axi_wlast;
wire module_endpoint_select_inst_pci_axi_wready;
wire [1:0] module_endpoint_select_inst_pci_axi_bresp;
wire module_endpoint_select_inst_pci_axi_bvalid;
wire module_endpoint_select_inst_pci_axi_bready;
wire [63:0] module_endpoint_select_inst_pci_axi_araddr;
wire [7:0] module_endpoint_select_inst_pci_axi_arlen;
wire [2:0] module_endpoint_select_inst_pci_axi_arsize;
wire [1:0] module_endpoint_select_inst_pci_axi_arburst;
wire module_endpoint_select_inst_pci_axi_arvalid;
wire module_endpoint_select_inst_pci_axi_arready;
wire [127:0] module_endpoint_select_inst_pci_axi_rdata;
wire [1:0] module_endpoint_select_inst_pci_axi_rresp;
wire module_endpoint_select_inst_pci_axi_rvalid;
wire module_endpoint_select_inst_pci_axi_rlast;
wire module_endpoint_select_inst_pci_axi_rready;
wire [63:0] module_endpoint_select_inst_vc_axi_awaddr;
wire [7:0] module_endpoint_select_inst_vc_axi_awlen;
wire [2:0] module_endpoint_select_inst_vc_axi_awsize;
wire [1:0] module_endpoint_select_inst_vc_axi_awburst;
wire module_endpoint_select_inst_vc_axi_awvalid;
wire module_endpoint_select_inst_vc_axi_awready;
wire [127:0] module_endpoint_select_inst_vc_axi_wdata;
wire [15:0] module_endpoint_select_inst_vc_axi_wstrb;
wire module_endpoint_select_inst_vc_axi_wvalid;
wire module_endpoint_select_inst_vc_axi_wlast;
wire module_endpoint_select_inst_vc_axi_wready;
wire [1:0] module_endpoint_select_inst_vc_axi_bresp;
wire module_endpoint_select_inst_vc_axi_bvalid;
wire module_endpoint_select_inst_vc_axi_bready;
wire [63:0] module_endpoint_select_inst_vc_axi_araddr;
wire [7:0] module_endpoint_select_inst_vc_axi_arlen;
wire [2:0] module_endpoint_select_inst_vc_axi_arsize;
wire [1:0] module_endpoint_select_inst_vc_axi_arburst;
wire module_endpoint_select_inst_vc_axi_arvalid;
wire module_endpoint_select_inst_vc_axi_arready;
wire [127:0] module_endpoint_select_inst_vc_axi_rdata;
wire [1:0] module_endpoint_select_inst_vc_axi_rresp;
wire module_endpoint_select_inst_vc_axi_rvalid;
wire module_endpoint_select_inst_vc_axi_rlast;
wire module_endpoint_select_inst_vc_axi_rready;
wire [63:0] module_endpoint_select_inst_ss_awaddr;
wire [7:0] module_endpoint_select_inst_ss_awlen;
wire [2:0] module_endpoint_select_inst_ss_awsize;
wire [1:0] module_endpoint_select_inst_ss_awburst;
wire module_endpoint_select_inst_ss_awvalid;
wire module_endpoint_select_inst_ss_awready;
wire [127:0] module_endpoint_select_inst_ss_wdata;
wire [15:0] module_endpoint_select_inst_ss_wstrb;
wire module_endpoint_select_inst_ss_wvalid;
wire module_endpoint_select_inst_ss_wlast;
wire module_endpoint_select_inst_ss_wready;
wire [1:0] module_endpoint_select_inst_ss_bresp;
wire module_endpoint_select_inst_ss_bvalid;
wire module_endpoint_select_inst_ss_bready;
wire [63:0] module_endpoint_select_inst_ss_araddr;
wire [7:0] module_endpoint_select_inst_ss_arlen;
wire [2:0] module_endpoint_select_inst_ss_arsize;
wire [1:0] module_endpoint_select_inst_ss_arburst;
wire module_endpoint_select_inst_ss_arvalid;
wire module_endpoint_select_inst_ss_arready;
wire [127:0] module_endpoint_select_inst_ss_rdata;
wire [1:0] module_endpoint_select_inst_ss_rresp;
wire module_endpoint_select_inst_ss_rvalid;
wire module_endpoint_select_inst_ss_rlast;
wire module_endpoint_select_inst_ss_rready;


//dw_converter	(data_width_converter)
wire module_dw_converter_clk;
wire module_dw_converter_rst;
wire [31:0] module_dw_converter_a_awaddr;
wire [7:0] module_dw_converter_a_awlen;
wire [2:0] module_dw_converter_a_awsize;
wire [1:0] module_dw_converter_a_awburst;
wire module_dw_converter_a_awvalid;
wire module_dw_converter_a_awready;
wire [127:0] module_dw_converter_a_wdata;
wire [15:0] module_dw_converter_a_wstrb;
wire module_dw_converter_a_wvalid;
wire module_dw_converter_a_wlast;
wire module_dw_converter_a_wready;
wire [1:0] module_dw_converter_a_bresp;
wire module_dw_converter_a_bvalid;
wire module_dw_converter_a_bready;
wire [31:0] module_dw_converter_a_araddr;
wire [7:0] module_dw_converter_a_arlen;
wire [2:0] module_dw_converter_a_arsize;
wire [1:0] module_dw_converter_a_arburst;
wire module_dw_converter_a_arvalid;
wire module_dw_converter_a_arready;
wire [127:0] module_dw_converter_a_rdata;
wire [1:0] module_dw_converter_a_rresp;
wire module_dw_converter_a_rvalid;
wire module_dw_converter_a_rlast;
wire module_dw_converter_a_rready;
wire [31:0] module_dw_converter_b_awaddr;
wire module_dw_converter_b_awvalid;
wire module_dw_converter_b_awready;
wire [31:0] module_dw_converter_b_wdata;
wire [3:0] module_dw_converter_b_wstrb;
wire module_dw_converter_b_wvalid;
wire module_dw_converter_b_wready;
wire [1:0] module_dw_converter_b_bresp;
wire module_dw_converter_b_bvalid;
wire module_dw_converter_b_bready;
wire [31:0] module_dw_converter_b_araddr;
wire module_dw_converter_b_arvalid;
wire module_dw_converter_b_arready;
wire [31:0] module_dw_converter_b_rdata;
wire [1:0] module_dw_converter_b_rresp;
wire module_dw_converter_b_rvalid;
wire module_dw_converter_b_rready;


//main_memory	(bram_axi)
wire module_main_memory_clk;
wire module_main_memory_rst;
wire [PARAMETER_MAIN_MEMORY_ADDR_WIDTH-1:0] module_main_memory_mem_axi_araddr;
wire module_main_memory_mem_axi_arvalid;
wire module_main_memory_mem_axi_arready;
wire [PARAMETER_MAIN_MEMORY_ADDR_WIDTH-1:0] module_main_memory_mem_axi_awaddr;
wire module_main_memory_mem_axi_awvalid;
wire module_main_memory_mem_axi_awready;
wire [PARAMETER_MAIN_MEMORY_DATA_WIDTH-1:0] module_main_memory_mem_axi_rdata;
wire module_main_memory_mem_axi_rvalid;
wire module_main_memory_mem_axi_rready;
wire [PARAMETER_MAIN_MEMORY_DATA_WIDTH-1:0] module_main_memory_mem_axi_wdata;
wire [(PARAMETER_MAIN_MEMORY_DATA_WIDTH >> 3)-1:0] module_main_memory_mem_axi_wstrb;
wire module_main_memory_mem_axi_wvalid;
wire module_main_memory_mem_axi_wready;
wire module_main_memory_mem_b_ready;
wire [1:0] module_main_memory_mem_b_response;
wire module_main_memory_mem_b_valid;


//intf_splitter2	(interface_splitter_2)
wire [1:0] module_intf_splitter2_a_arvalid;
wire [1:0] module_intf_splitter2_a_arready;
wire [(PARAMETER_INTF_SPLITTER2_ADDR_WIDTH * 2)-1:0] module_intf_splitter2_a_araddr;
wire [1:0] module_intf_splitter2_a_rvalid;
wire [1:0] module_intf_splitter2_a_rready;
wire [(PARAMETER_INTF_SPLITTER2_DATA_WIDTH * 2)-1:0] module_intf_splitter2_a_rdata;
wire [(2 * 2)-1:0] module_intf_splitter2_a_rresp;
wire [1:0] module_intf_splitter2_a_awvalid;
wire [1:0] module_intf_splitter2_a_awready;
wire [(PARAMETER_INTF_SPLITTER2_ADDR_WIDTH * 2)-1:0] module_intf_splitter2_a_awaddr;
wire [1:0] module_intf_splitter2_a_wvalid;
wire [1:0] module_intf_splitter2_a_wready;
wire [(PARAMETER_INTF_SPLITTER2_DATA_WIDTH * 2)-1:0] module_intf_splitter2_a_wdata;
wire [(PARAMETER_INTF_SPLITTER2_STRB_WIDTH * 2)-1:0] module_intf_splitter2_a_wstrb;
wire [1:0] module_intf_splitter2_a_bvalid;
wire [1:0] module_intf_splitter2_a_bready;
wire [(2 * 2)-1:0] module_intf_splitter2_a_bresp;
wire [31:0] module_intf_splitter2_b0_awaddr;
wire module_intf_splitter2_b0_awvalid;
wire module_intf_splitter2_b0_awready;
wire [31:0] module_intf_splitter2_b0_wdata;
wire [3:0] module_intf_splitter2_b0_wstrb;
wire module_intf_splitter2_b0_wvalid;
wire module_intf_splitter2_b0_wready;
wire [1:0] module_intf_splitter2_b0_bresp;
wire module_intf_splitter2_b0_bvalid;
wire module_intf_splitter2_b0_bready;
wire [31:0] module_intf_splitter2_b0_araddr;
wire module_intf_splitter2_b0_arvalid;
wire module_intf_splitter2_b0_arready;
wire [31:0] module_intf_splitter2_b0_rdata;
wire [1:0] module_intf_splitter2_b0_rresp;
wire module_intf_splitter2_b0_rvalid;
wire module_intf_splitter2_b0_rready;
wire [31:0] module_intf_splitter2_b1_awaddr;
wire module_intf_splitter2_b1_awvalid;
wire module_intf_splitter2_b1_awready;
wire [31:0] module_intf_splitter2_b1_wdata;
wire [3:0] module_intf_splitter2_b1_wstrb;
wire module_intf_splitter2_b1_wvalid;
wire module_intf_splitter2_b1_wready;
wire [1:0] module_intf_splitter2_b1_bresp;
wire module_intf_splitter2_b1_bvalid;
wire module_intf_splitter2_b1_bready;
wire [31:0] module_intf_splitter2_b1_araddr;
wire module_intf_splitter2_b1_arvalid;
wire module_intf_splitter2_b1_arready;
wire [31:0] module_intf_splitter2_b1_rdata;
wire [1:0] module_intf_splitter2_b1_rresp;
wire module_intf_splitter2_b1_rvalid;
wire module_intf_splitter2_b1_rready;


//intf_concat2	(interface_concat_2)
wire [1:0] module_intf_concat2_b_arvalid;
wire [1:0] module_intf_concat2_b_arready;
wire [(PARAMETER_INTF_CONCAT2_ADDR_WIDTH * 2)-1:0] module_intf_concat2_b_araddr;
wire [1:0] module_intf_concat2_b_rvalid;
wire [1:0] module_intf_concat2_b_rready;
wire [(PARAMETER_INTF_CONCAT2_DATA_WIDTH * 2)-1:0] module_intf_concat2_b_rdata;
wire [(2 * 2)-1:0] module_intf_concat2_b_rresp;
wire [1:0] module_intf_concat2_b_awvalid;
wire [1:0] module_intf_concat2_b_awready;
wire [(PARAMETER_INTF_CONCAT2_ADDR_WIDTH * 2)-1:0] module_intf_concat2_b_awaddr;
wire [1:0] module_intf_concat2_b_wvalid;
wire [1:0] module_intf_concat2_b_wready;
wire [(PARAMETER_INTF_CONCAT2_DATA_WIDTH * 2)-1:0] module_intf_concat2_b_wdata;
wire [(PARAMETER_INTF_CONCAT2_STRB_WIDTH * 2)-1:0] module_intf_concat2_b_wstrb;
wire [1:0] module_intf_concat2_b_bvalid;
wire [1:0] module_intf_concat2_b_bready;
wire [(2 * 2)-1:0] module_intf_concat2_b_bresp;
wire [31:0] module_intf_concat2_a0_awaddr;
wire module_intf_concat2_a0_awvalid;
wire module_intf_concat2_a0_awready;
wire [31:0] module_intf_concat2_a0_wdata;
wire [3:0] module_intf_concat2_a0_wstrb;
wire module_intf_concat2_a0_wvalid;
wire module_intf_concat2_a0_wready;
wire [1:0] module_intf_concat2_a0_bresp;
wire module_intf_concat2_a0_bvalid;
wire module_intf_concat2_a0_bready;
wire [31:0] module_intf_concat2_a0_araddr;
wire module_intf_concat2_a0_arvalid;
wire module_intf_concat2_a0_arready;
wire [31:0] module_intf_concat2_a0_rdata;
wire [1:0] module_intf_concat2_a0_rresp;
wire module_intf_concat2_a0_rvalid;
wire module_intf_concat2_a0_rready;
wire [31:0] module_intf_concat2_a1_awaddr;
wire module_intf_concat2_a1_awvalid;
wire module_intf_concat2_a1_awready;
wire [31:0] module_intf_concat2_a1_wdata;
wire [3:0] module_intf_concat2_a1_wstrb;
wire module_intf_concat2_a1_wvalid;
wire module_intf_concat2_a1_wready;
wire [1:0] module_intf_concat2_a1_bresp;
wire module_intf_concat2_a1_bvalid;
wire module_intf_concat2_a1_bready;
wire [31:0] module_intf_concat2_a1_araddr;
wire module_intf_concat2_a1_arvalid;
wire module_intf_concat2_a1_arready;
wire [31:0] module_intf_concat2_a1_rdata;
wire [1:0] module_intf_concat2_a1_rresp;
wire module_intf_concat2_a1_rvalid;
wire module_intf_concat2_a1_rready;


//cpu	(picorv32_axi)
wire module_cpu_clk;
wire module_cpu_resetn;
wire [31:0] module_cpu_mem_axi_araddr;
wire module_cpu_mem_axi_arvalid;
wire module_cpu_mem_axi_arready;
wire [31:0] module_cpu_mem_axi_awaddr;
wire module_cpu_mem_axi_awvalid;
wire module_cpu_mem_axi_awready;
wire [31:0] module_cpu_mem_axi_rdata;
wire module_cpu_mem_axi_rvalid;
wire module_cpu_mem_axi_rready;
wire [31:0] module_cpu_mem_axi_wdata;
wire [3:0] module_cpu_mem_axi_wstrb;
wire module_cpu_mem_axi_wvalid;
wire module_cpu_mem_axi_wready;
wire module_cpu_mem_b_ready;
wire [1:0] module_cpu_mem_b_response;
wire module_cpu_mem_b_valid;
wire module_cpu_pcpi_valid;
wire [31:0] module_cpu_pcpi_insn;
wire [31:0] module_cpu_pcpi_rs1;
wire [31:0] module_cpu_pcpi_rs2;
wire module_cpu_pcpi_wr;
wire [31:0] module_cpu_pcpi_rd;
wire module_cpu_pcpi_wait;
wire module_cpu_pcpi_ready;
wire [31:0] module_cpu_irq;
wire [31:0] module_cpu_eoi;




wire [1 - 1 :0] custom_user_reset; assign custom_user_reset = module_xdma_xc7_i_axi_aresetn ^ 1'b1;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_main_mem_araddr; assign custom_main_mem_araddr = module_main_memory_mem_axi_araddr >> 2;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_main_mem_awaddr; assign custom_main_mem_awaddr = module_main_memory_mem_axi_awaddr >> 2;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_intf_concat_a0_araddr; assign custom_intf_concat_a0_araddr = module_intf_concat2_a0_araddr - 32'h10000000;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_intf_concat_a0_awaddr; assign custom_intf_concat_a0_awaddr = module_intf_concat2_a0_awaddr - 32'h10000000;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_intf_concat_a1_araddr; assign custom_intf_concat_a1_araddr = module_intf_concat2_a1_araddr - 32'h20000000;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_intf_concat_a1_awaddr; assign custom_intf_concat_a1_awaddr = module_intf_concat2_a1_awaddr - 32'h20000000;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_debug_araddr; assign custom_debug_araddr = module_debug_a_axi_araddr - 32'h80000000;
wire [PARAMETER_CPU_ADDR_WIDTH - 1 :0] custom_debug_awaddr; assign custom_debug_awaddr = module_debug_a_axi_awaddr - 32'h80000000;
wire [1 - 1 :0] custom_user_resetn; assign custom_user_resetn = module_xdma_xc7_i_axi_aresetn;
wire [1 - 1 :0] custom_user_clk; assign custom_user_clk = module_xdma_xc7_i_axi_aclk;
wire [4 - 1 :0] custom_bram_intf0_rvalid; assign custom_bram_intf0_rvalid = {module_pcie_controller_inst_m_axil_rvalid, module_dw_converter_b_rvalid, module_cpu_mem_axi_rvalid};
wire [4 - 1 :0] custom_bram_intf0_arvalid; assign custom_bram_intf0_arvalid = {module_pcie_controller_inst_m_axil_arvalid, module_dw_converter_b_arvalid, module_cpu_mem_axi_arvalid};
wire [4 - 1 :0] custom_bram_intf0_arready; assign custom_bram_intf0_arready = {module_pcie_controller_inst_m_axil_arready, module_dw_converter_b_arready, module_cpu_mem_axi_arready};
wire [4 - 1 :0] custom_bram_intf0_rready; assign custom_bram_intf0_rready = {module_pcie_controller_inst_m_axil_rready, module_dw_converter_b_rready, module_cpu_mem_axi_rready};
wire [4 - 1 :0] custom_bram_intf0_awvalid; assign custom_bram_intf0_awvalid = {module_pcie_controller_inst_m_axil_awvalid, module_dw_converter_b_awvalid, module_cpu_mem_axi_awvalid};
wire [4 - 1 :0] custom_bram_intf0_awready; assign custom_bram_intf0_awready = {module_pcie_controller_inst_m_axil_awready, module_dw_converter_b_awready, module_cpu_mem_axi_awready};
wire [4 - 1 :0] custom_bram_intf0_bvalid; assign custom_bram_intf0_bvalid = {module_pcie_controller_inst_m_axil_bvalid, module_dw_converter_b_bvalid, module_cpu_mem_b_valid};
wire [4 - 1 :0] custom_bram_intf0_bready; assign custom_bram_intf0_bready = {module_pcie_controller_inst_m_axil_bready, module_dw_converter_b_bready, module_cpu_mem_b_ready};
wire [PARAMETER_CPU_ADDR_WIDTH -1: 0] custom_cpu_axi_araddr;
reg [PARAMETER_CPU_ADDR_WIDTH -1: 0] internal_custom_cpu_axi_araddr;
initial internal_custom_cpu_axi_araddr = 0;
always @(posedge module_cpu_clk)
	internal_custom_cpu_axi_araddr <= module_cpu_mem_axi_arvalid ? module_cpu_mem_axi_araddr : custom_cpu_axi_araddr;
assign custom_cpu_axi_araddr = module_cpu_mem_axi_arvalid ? module_cpu_mem_axi_araddr : internal_custom_cpu_axi_araddr;
wire [PARAMETER_CPU_ADDR_WIDTH -1: 0] custom_cpu_axi_awaddr;
reg [PARAMETER_CPU_ADDR_WIDTH -1: 0] internal_custom_cpu_axi_awaddr;
initial internal_custom_cpu_axi_awaddr = 0;
always @(posedge module_cpu_clk)
	internal_custom_cpu_axi_awaddr <= module_cpu_mem_axi_awvalid ? module_cpu_mem_axi_awaddr : custom_cpu_axi_awaddr;
assign custom_cpu_axi_awaddr = module_cpu_mem_axi_awvalid ? module_cpu_mem_axi_awaddr : internal_custom_cpu_axi_awaddr;


assign module_refclk_ibuf_I = sys_clk_p;
assign module_refclk_ibuf_IB = sys_clk_n;
assign module_debug_urx = uart_rx;
assign uart_tx = module_debug_utx;
assign module_xdma_xc7_i_sys_clk = module_refclk_ibuf_O;
assign module_sys_reset_n_ibuf_I = sys_rst_n;
assign module_xdma_xc7_i_sys_rst_n = module_sys_reset_n_ibuf_O;
assign pci_exp_txp = module_xdma_xc7_i_pci_exp_txp;
assign pci_exp_txn = module_xdma_xc7_i_pci_exp_txn;
assign module_xdma_xc7_i_pci_exp_rxp = pci_exp_rxp;
assign module_xdma_xc7_i_pci_exp_rxn = pci_exp_rxn;
assign module_cpu_clk = custom_user_clk;
assign module_debug_clk = custom_user_clk;
assign module_pcie_controller_inst_clk = custom_user_clk;
assign module_pcie_controller_inst_reset = custom_user_reset;
assign module_debug_rst = custom_user_reset;
assign module_cpu_resetn = custom_user_resetn;
assign module_pcie_controller_inst_s_axil_awaddr = module_xdma_xc7_i_m_axil_awaddr;
assign module_pcie_controller_inst_s_axil_awvalid = module_xdma_xc7_i_m_axil_awvalid;
assign module_xdma_xc7_i_m_axil_awready = module_pcie_controller_inst_s_axil_awready;
assign module_pcie_controller_inst_s_axil_wdata = module_xdma_xc7_i_m_axil_wdata;
assign module_pcie_controller_inst_s_axil_wstrb = module_xdma_xc7_i_m_axil_wstrb;
assign module_pcie_controller_inst_s_axil_wvalid = module_xdma_xc7_i_m_axil_wvalid;
assign module_xdma_xc7_i_m_axil_wready = module_pcie_controller_inst_s_axil_wready;
assign module_xdma_xc7_i_m_axil_bresp = module_pcie_controller_inst_s_axil_bresp;
assign module_xdma_xc7_i_m_axil_bvalid = module_pcie_controller_inst_s_axil_bvalid;
assign module_pcie_controller_inst_s_axil_bready = module_xdma_xc7_i_m_axil_bready;
assign module_pcie_controller_inst_s_axil_araddr = module_xdma_xc7_i_m_axil_araddr;
assign module_pcie_controller_inst_s_axil_arvalid = module_xdma_xc7_i_m_axil_arvalid;
assign module_xdma_xc7_i_m_axil_arready = module_pcie_controller_inst_s_axil_arready;
assign module_xdma_xc7_i_m_axil_rdata = module_pcie_controller_inst_s_axil_rdata;
assign module_xdma_xc7_i_m_axil_rresp = module_pcie_controller_inst_s_axil_rresp;
assign module_xdma_xc7_i_m_axil_rvalid = module_pcie_controller_inst_s_axil_rvalid;
assign module_pcie_controller_inst_s_axil_rready = module_xdma_xc7_i_m_axil_rready;
assign module_pcie_controller_inst_c2h_dsc_byp_ready_0 = module_xdma_xc7_i_c2h_dsc_byp_ready_0;
assign module_xdma_xc7_i_c2h_dsc_byp_src_addr_0 = module_pcie_controller_inst_c2h_dsc_byp_src_addr_0;
assign module_xdma_xc7_i_c2h_dsc_byp_dst_addr_0 = module_pcie_controller_inst_c2h_dsc_byp_dst_addr_0;
assign module_xdma_xc7_i_c2h_dsc_byp_len_0 = module_pcie_controller_inst_c2h_dsc_byp_len_0;
assign module_xdma_xc7_i_c2h_dsc_byp_ctl_0 = module_pcie_controller_inst_c2h_dsc_byp_ctl_0;
assign module_xdma_xc7_i_c2h_dsc_byp_load_0 = module_pcie_controller_inst_c2h_dsc_byp_load_0;
assign module_pcie_controller_inst_h2c_dsc_byp_ready_0 = module_xdma_xc7_i_h2c_dsc_byp_ready_0;
assign module_xdma_xc7_i_h2c_dsc_byp_src_addr_0 = module_pcie_controller_inst_h2c_dsc_byp_src_addr_0;
assign module_xdma_xc7_i_h2c_dsc_byp_dst_addr_0 = module_pcie_controller_inst_h2c_dsc_byp_dst_addr_0;
assign module_xdma_xc7_i_h2c_dsc_byp_len_0 = module_pcie_controller_inst_h2c_dsc_byp_len_0;
assign module_xdma_xc7_i_h2c_dsc_byp_ctl_0 = module_pcie_controller_inst_h2c_dsc_byp_ctl_0;
assign module_xdma_xc7_i_h2c_dsc_byp_load_0 = module_pcie_controller_inst_h2c_dsc_byp_load_0;
assign module_bram_intf0_access_ctrl_rvalid = custom_bram_intf0_rvalid;
assign module_bram_intf0_access_ctrl_rready = custom_bram_intf0_rready;
assign module_bram_intf0_access_ctrl_arvalid = custom_bram_intf0_arvalid;
assign module_bram_intf0_access_ctrl_arready = custom_bram_intf0_arready;
assign module_bram_intf0_access_ctrl_awvalid = custom_bram_intf0_awvalid;
assign module_bram_intf0_access_ctrl_awready = custom_bram_intf0_awready;
assign module_bram_intf0_access_ctrl_bvalid = custom_bram_intf0_bvalid;
assign module_bram_intf0_access_ctrl_bready = custom_bram_intf0_bready;
assign module_endpoint_select_inst_pci_axi_awaddr = module_xdma_xc7_i_m_axi_awaddr;
assign module_endpoint_select_inst_pci_axi_awlen = module_xdma_xc7_i_m_axi_awlen;
assign module_endpoint_select_inst_pci_axi_awsize = module_xdma_xc7_i_m_axi_awsize;
assign module_endpoint_select_inst_pci_axi_awburst = module_xdma_xc7_i_m_axi_awburst;
assign module_endpoint_select_inst_pci_axi_awvalid = module_xdma_xc7_i_m_axi_awvalid;
assign module_xdma_xc7_i_m_axi_awready = module_endpoint_select_inst_pci_axi_awready;
assign module_endpoint_select_inst_pci_axi_wdata = module_xdma_xc7_i_m_axi_wdata;
assign module_endpoint_select_inst_pci_axi_wstrb = module_xdma_xc7_i_m_axi_wstrb;
assign module_endpoint_select_inst_pci_axi_wvalid = module_xdma_xc7_i_m_axi_wvalid;
assign module_endpoint_select_inst_pci_axi_wlast = module_xdma_xc7_i_m_axi_wlast;
assign module_xdma_xc7_i_m_axi_wready = module_endpoint_select_inst_pci_axi_wready;
assign module_xdma_xc7_i_m_axi_bresp = module_endpoint_select_inst_pci_axi_bresp;
assign module_xdma_xc7_i_m_axi_bvalid = module_endpoint_select_inst_pci_axi_bvalid;
assign module_endpoint_select_inst_pci_axi_bready = module_xdma_xc7_i_m_axi_bready;
assign module_endpoint_select_inst_pci_axi_araddr = module_xdma_xc7_i_m_axi_araddr;
assign module_endpoint_select_inst_pci_axi_arlen = module_xdma_xc7_i_m_axi_arlen;
assign module_endpoint_select_inst_pci_axi_arsize = module_xdma_xc7_i_m_axi_arsize;
assign module_endpoint_select_inst_pci_axi_arburst = module_xdma_xc7_i_m_axi_arburst;
assign module_endpoint_select_inst_pci_axi_arvalid = module_xdma_xc7_i_m_axi_arvalid;
assign module_xdma_xc7_i_m_axi_arready = module_endpoint_select_inst_pci_axi_arready;
assign module_xdma_xc7_i_m_axi_rdata = module_endpoint_select_inst_pci_axi_rdata;
assign module_xdma_xc7_i_m_axi_rresp = module_endpoint_select_inst_pci_axi_rresp;
assign module_xdma_xc7_i_m_axi_rvalid = module_endpoint_select_inst_pci_axi_rvalid;
assign module_xdma_xc7_i_m_axi_rlast = module_endpoint_select_inst_pci_axi_rlast;
assign module_endpoint_select_inst_pci_axi_rready = module_xdma_xc7_i_m_axi_rready;
assign module_xdma_xc7_i_s_axil_awaddr = module_pcie_controller_inst_dma_engine_config_axil_awaddr;
assign module_xdma_xc7_i_s_axil_awvalid = module_pcie_controller_inst_dma_engine_config_axil_awvalid;
assign module_pcie_controller_inst_dma_engine_config_axil_awready = module_xdma_xc7_i_s_axil_awready;
assign module_xdma_xc7_i_s_axil_wdata = module_pcie_controller_inst_dma_engine_config_axil_wdata;
assign module_xdma_xc7_i_s_axil_wstrb = module_pcie_controller_inst_dma_engine_config_axil_wstrb;
assign module_xdma_xc7_i_s_axil_wvalid = module_pcie_controller_inst_dma_engine_config_axil_wvalid;
assign module_pcie_controller_inst_dma_engine_config_axil_wready = module_xdma_xc7_i_s_axil_wready;
assign module_pcie_controller_inst_dma_engine_config_axil_bresp = module_xdma_xc7_i_s_axil_bresp;
assign module_pcie_controller_inst_dma_engine_config_axil_bvalid = module_xdma_xc7_i_s_axil_bvalid;
assign module_xdma_xc7_i_s_axil_bready = module_pcie_controller_inst_dma_engine_config_axil_bready;
assign module_xdma_xc7_i_s_axil_araddr = module_pcie_controller_inst_dma_engine_config_axil_araddr;
assign module_xdma_xc7_i_s_axil_arvalid = module_pcie_controller_inst_dma_engine_config_axil_arvalid;
assign module_pcie_controller_inst_dma_engine_config_axil_arready = module_xdma_xc7_i_s_axil_arready;
assign module_pcie_controller_inst_dma_engine_config_axil_rdata = module_xdma_xc7_i_s_axil_rdata;
assign module_pcie_controller_inst_dma_engine_config_axil_rresp = module_xdma_xc7_i_s_axil_rresp;
assign module_pcie_controller_inst_dma_engine_config_axil_rvalid = module_xdma_xc7_i_s_axil_rvalid;
assign module_xdma_xc7_i_s_axil_rready = module_pcie_controller_inst_dma_engine_config_axil_rready;
assign module_pcie_controller_inst_c2h_sts_0 = module_xdma_xc7_i_c2h_sts_0;
assign module_pcie_controller_inst_h2c_sts_0 = module_xdma_xc7_i_h2c_sts_0;
assign module_xdma_xc7_i_usr_irq_req = module_pcie_controller_inst_usr_irq_req;
assign module_pcie_controller_inst_usr_irq_ack = module_xdma_xc7_i_usr_irq_ack;
assign module_endpoint_select_inst_endpoint_ctrl = module_pcie_controller_inst_endpoint_ctrl;
assign module_pcie_controller_inst_s_axi_awaddr = module_endpoint_select_inst_vc_axi_awaddr;
assign module_pcie_controller_inst_s_axi_awlen = module_endpoint_select_inst_vc_axi_awlen;
assign module_pcie_controller_inst_s_axi_awsize = module_endpoint_select_inst_vc_axi_awsize;
assign module_pcie_controller_inst_s_axi_awburst = module_endpoint_select_inst_vc_axi_awburst;
assign module_pcie_controller_inst_s_axi_awvalid = module_endpoint_select_inst_vc_axi_awvalid;
assign module_endpoint_select_inst_vc_axi_awready = module_pcie_controller_inst_s_axi_awready;
assign module_pcie_controller_inst_s_axi_wdata = module_endpoint_select_inst_vc_axi_wdata;
assign module_pcie_controller_inst_s_axi_wstrb = module_endpoint_select_inst_vc_axi_wstrb;
assign module_pcie_controller_inst_s_axi_wvalid = module_endpoint_select_inst_vc_axi_wvalid;
assign module_pcie_controller_inst_s_axi_wlast = module_endpoint_select_inst_vc_axi_wlast;
assign module_endpoint_select_inst_vc_axi_wready = module_pcie_controller_inst_s_axi_wready;
assign module_endpoint_select_inst_vc_axi_bresp = module_pcie_controller_inst_s_axi_bresp;
assign module_endpoint_select_inst_vc_axi_bvalid = module_pcie_controller_inst_s_axi_bvalid;
assign module_pcie_controller_inst_s_axi_bready = module_endpoint_select_inst_vc_axi_bready;
assign module_pcie_controller_inst_s_axi_araddr = module_endpoint_select_inst_vc_axi_araddr;
assign module_pcie_controller_inst_s_axi_arlen = module_endpoint_select_inst_vc_axi_arlen;
assign module_pcie_controller_inst_s_axi_arsize = module_endpoint_select_inst_vc_axi_arsize;
assign module_pcie_controller_inst_s_axi_arburst = module_endpoint_select_inst_vc_axi_arburst;
assign module_pcie_controller_inst_s_axi_arvalid = module_endpoint_select_inst_vc_axi_arvalid;
assign module_endpoint_select_inst_vc_axi_arready = module_pcie_controller_inst_s_axi_arready;
assign module_endpoint_select_inst_vc_axi_rdata = module_pcie_controller_inst_s_axi_rdata;
assign module_endpoint_select_inst_vc_axi_rresp = module_pcie_controller_inst_s_axi_rresp;
assign module_endpoint_select_inst_vc_axi_rvalid = module_pcie_controller_inst_s_axi_rvalid;
assign module_endpoint_select_inst_vc_axi_rlast = module_pcie_controller_inst_s_axi_rlast;
assign module_pcie_controller_inst_s_axi_rready = module_endpoint_select_inst_vc_axi_rready;
assign module_dw_converter_a_awaddr = module_endpoint_select_inst_ss_awaddr;
assign module_dw_converter_a_awlen = module_endpoint_select_inst_ss_awlen;
assign module_dw_converter_a_awsize = module_endpoint_select_inst_ss_awsize;
assign module_dw_converter_a_awburst = module_endpoint_select_inst_ss_awburst;
assign module_dw_converter_a_awvalid = module_endpoint_select_inst_ss_awvalid;
assign module_endpoint_select_inst_ss_awready = module_dw_converter_a_awready;
assign module_dw_converter_a_wdata = module_endpoint_select_inst_ss_wdata;
assign module_dw_converter_a_wstrb = module_endpoint_select_inst_ss_wstrb;
assign module_dw_converter_a_wvalid = module_endpoint_select_inst_ss_wvalid;
assign module_dw_converter_a_wlast = module_endpoint_select_inst_ss_wlast;
assign module_endpoint_select_inst_ss_wready = module_dw_converter_a_wready;
assign module_endpoint_select_inst_ss_bresp = module_dw_converter_a_bresp;
assign module_endpoint_select_inst_ss_bvalid = module_dw_converter_a_bvalid;
assign module_dw_converter_a_bready = module_endpoint_select_inst_ss_bready;
assign module_dw_converter_a_araddr = module_endpoint_select_inst_ss_araddr;
assign module_dw_converter_a_arlen = module_endpoint_select_inst_ss_arlen;
assign module_dw_converter_a_arsize = module_endpoint_select_inst_ss_arsize;
assign module_dw_converter_a_arburst = module_endpoint_select_inst_ss_arburst;
assign module_dw_converter_a_arvalid = module_endpoint_select_inst_ss_arvalid;
assign module_endpoint_select_inst_ss_arready = module_dw_converter_a_arready;
assign module_endpoint_select_inst_ss_rdata = module_dw_converter_a_rdata;
assign module_endpoint_select_inst_ss_rresp = module_dw_converter_a_rresp;
assign module_endpoint_select_inst_ss_rvalid = module_dw_converter_a_rvalid;
assign module_endpoint_select_inst_ss_rlast = module_dw_converter_a_rlast;
assign module_dw_converter_a_rready = module_endpoint_select_inst_ss_rready;
assign module_pcie_controller_inst_s_axi_wvalid_to_mem = module_endpoint_select_inst_ss_wvalid;
assign module_pcie_controller_inst_s_axi_wstrb_to_mem = module_endpoint_select_inst_ss_wstrb;
assign module_pcie_controller_inst_s_axi_rvalid_from_mem = module_dw_converter_a_rvalid;
assign module_pcie_controller_inst_s_axi_wready_from_mem = module_dw_converter_a_wready;
assign module_pcie_controller_inst_s_axi_rready_to_mem = module_endpoint_select_inst_ss_rready;
assign module_pcie_controller_inst_s_axi_bready_to_mem = module_endpoint_select_inst_ss_bready;
assign module_pcie_controller_inst_s_axi_bvalid_from_mem = module_dw_converter_a_bvalid;
assign module_dw_converter_clk = custom_user_clk;
assign module_dw_converter_rst = custom_user_reset;
assign module_intf_splitter2_a_araddr = module_pcie_controller_inst_m_axil_araddr;
assign module_intf_splitter2_a_arvalid = module_pcie_controller_inst_m_axil_arvalid;
assign module_pcie_controller_inst_m_axil_arready = module_intf_splitter2_a_arready;
assign module_intf_splitter2_a_awaddr = module_pcie_controller_inst_m_axil_awaddr;
assign module_intf_splitter2_a_awvalid = module_pcie_controller_inst_m_axil_awvalid;
assign module_pcie_controller_inst_m_axil_awready = module_intf_splitter2_a_awready;
assign module_intf_splitter2_a_wdata = module_pcie_controller_inst_m_axil_wdata;
assign module_intf_splitter2_a_wvalid = module_pcie_controller_inst_m_axil_wvalid;
assign module_pcie_controller_inst_m_axil_wready = module_intf_splitter2_a_wready;
assign module_intf_splitter2_a_wstrb = module_pcie_controller_inst_m_axil_wstrb;
assign module_pcie_controller_inst_m_axil_rdata = module_intf_splitter2_a_rdata;
assign module_pcie_controller_inst_m_axil_rvalid = module_intf_splitter2_a_rvalid;
assign module_intf_splitter2_a_rready = module_pcie_controller_inst_m_axil_rready;
assign module_pcie_controller_inst_m_axil_rresp = module_intf_splitter2_a_rresp;
assign module_pcie_controller_inst_m_axil_bvalid = module_intf_splitter2_a_bvalid;
assign module_intf_splitter2_a_bready = module_pcie_controller_inst_m_axil_bready;
assign module_pcie_controller_inst_m_axil_bresp = module_intf_splitter2_a_bresp;
assign module_pcie_controller_inst_cfg_intf_axil_awvalid = module_intf_concat2_b_awvalid;
assign module_intf_concat2_b_awready = module_pcie_controller_inst_cfg_intf_axil_awready;
assign module_pcie_controller_inst_cfg_intf_axil_awaddr = module_intf_concat2_b_awaddr;
assign module_pcie_controller_inst_cfg_intf_axil_wvalid = module_intf_concat2_b_wvalid;
assign module_intf_concat2_b_wready = module_pcie_controller_inst_cfg_intf_axil_wready;
assign module_pcie_controller_inst_cfg_intf_axil_wdata = module_intf_concat2_b_wdata;
assign module_pcie_controller_inst_cfg_intf_axil_wstrb = module_intf_concat2_b_wstrb;
assign module_intf_concat2_b_bvalid = module_pcie_controller_inst_cfg_intf_axil_bvalid;
assign module_pcie_controller_inst_cfg_intf_axil_bready = module_intf_concat2_b_bready;
assign module_intf_concat2_b_bresp = module_pcie_controller_inst_cfg_intf_axil_bresp;
assign module_pcie_controller_inst_cfg_intf_axil_arvalid = module_intf_concat2_b_arvalid;
assign module_intf_concat2_b_arready = module_pcie_controller_inst_cfg_intf_axil_arready;
assign module_pcie_controller_inst_cfg_intf_axil_araddr = module_intf_concat2_b_araddr;
assign module_intf_concat2_b_rvalid = module_pcie_controller_inst_cfg_intf_axil_rvalid;
assign module_pcie_controller_inst_cfg_intf_axil_rready = module_intf_concat2_b_rready;
assign module_intf_concat2_b_rdata = module_pcie_controller_inst_cfg_intf_axil_rdata;
assign module_intf_concat2_b_rresp = module_pcie_controller_inst_cfg_intf_axil_rresp;
assign module_bram_intf0_access_ctrl_clk = custom_user_clk;
assign module_bram_intf0_access_ctrl_reset = custom_user_reset;
assign module_main_memory_clk = custom_user_clk;
assign module_main_memory_rst = custom_user_reset;


assign module_cpu_mem_axi_rvalid = (1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h10000000) && (custom_cpu_axi_araddr < (32'h10000000+32'h10000000)) ? module_intf_concat2_a0_rvalid :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h20000000) && (custom_cpu_axi_araddr < (32'h20000000+32'h10000000)) ? module_intf_concat2_a1_rvalid :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h80000000) && (custom_cpu_axi_araddr < (32'h80000000+32'h10000000)) ? module_debug_a_axi_rvalid :
	(0)))))));
assign {module_cpu_mem_axi_rdata} = (1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h10000000) && (custom_cpu_axi_araddr < (32'h10000000+32'h10000000)) ?  {module_intf_concat2_a0_rdata} :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h20000000) && (custom_cpu_axi_araddr < (32'h20000000+32'h10000000)) ?  {module_intf_concat2_a1_rdata} :
	((1'b1) && (custom_cpu_axi_araddr >= 32'h80000000) && (custom_cpu_axi_araddr < (32'h80000000+32'h10000000)) ?  {module_debug_a_axi_rdata} :
	(0)))))));
assign module_cpu_mem_b_valid = (1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_b_valid :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_b_valid :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_b_valid :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_main_memory_mem_b_valid :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h10000000) && (custom_cpu_axi_awaddr < (32'h10000000+32'h10000000)) ? module_intf_concat2_a0_bvalid :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h20000000) && (custom_cpu_axi_awaddr < (32'h20000000+32'h10000000)) ? module_intf_concat2_a1_bvalid :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h80000000) && (custom_cpu_axi_awaddr < (32'h80000000+32'h10000000)) ? module_debug_a_b_valid :
	(0)))))));
assign {module_cpu_mem_b_response} = (1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h10000000) && (custom_cpu_axi_awaddr < (32'h10000000+32'h10000000)) ?  {module_intf_concat2_a0_bresp} :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h20000000) && (custom_cpu_axi_awaddr < (32'h20000000+32'h10000000)) ?  {module_intf_concat2_a1_bresp} :
	((1'b1) && (custom_cpu_axi_awaddr >= 32'h80000000) && (custom_cpu_axi_awaddr < (32'h80000000+32'h10000000)) ?  {module_debug_a_b_response} :
	(0)))))));
assign module_debug_a_axi_awvalid = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h80000000) && (module_cpu_mem_axi_awaddr < (32'h80000000+32'h10000000)) ? module_cpu_mem_axi_awvalid :
	(0);
assign {module_debug_a_axi_awaddr} = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h80000000) && (module_cpu_mem_axi_awaddr < (32'h80000000+32'h10000000)) ?  {module_cpu_mem_axi_awaddr} :
	(0);
assign module_debug_a_axi_wvalid = (1'b1) && (custom_cpu_axi_awaddr >= 32'h80000000) && (custom_cpu_axi_awaddr < (32'h80000000+32'h10000000)) ? module_cpu_mem_axi_wvalid :
	(0);
assign {module_debug_a_axi_wdata,module_debug_a_axi_wstrb} = (1'b1) && (custom_cpu_axi_awaddr >= 32'h80000000) && (custom_cpu_axi_awaddr < (32'h80000000+32'h10000000)) ?  {module_cpu_mem_axi_wdata,module_cpu_mem_axi_wstrb} :
	(0);
assign module_debug_a_axi_arvalid = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h80000000) && (module_cpu_mem_axi_araddr < (32'h80000000+32'h10000000)) ? module_cpu_mem_axi_arvalid :
	(0);
assign {module_debug_a_axi_araddr} = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h80000000) && (module_cpu_mem_axi_araddr < (32'h80000000+32'h10000000)) ?  {module_cpu_mem_axi_araddr} :
	(0);
assign module_main_memory_mem_axi_awvalid = (module_bram_intf0_access_ctrl_group_select == 0) && (module_cpu_mem_axi_awaddr >= 32'h00000000) && (module_cpu_mem_axi_awaddr < (32'h00000000+32'h00004000)) ? module_cpu_mem_axi_awvalid :
	((module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_awvalid :
	((module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_awvalid :
	((module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_awvalid :
	(0))));
assign {module_main_memory_mem_axi_awaddr} = (module_bram_intf0_access_ctrl_group_select == 0) && (module_cpu_mem_axi_awaddr >= 32'h00000000) && (module_cpu_mem_axi_awaddr < (32'h00000000+32'h00004000)) ?  {module_cpu_mem_axi_awaddr} :
	((module_bram_intf0_access_ctrl_group_select == 1) ?  {module_dw_converter_b_awaddr} :
	((module_bram_intf0_access_ctrl_group_select == 2) ?  {module_intf_splitter2_b0_awaddr} :
	((module_bram_intf0_access_ctrl_group_select == 3) ?  {module_intf_splitter2_b1_awaddr} :
	(0))));
assign module_main_memory_mem_axi_wvalid = (module_bram_intf0_access_ctrl_group_select == 0) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) ? module_cpu_mem_axi_wvalid :
	((module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_wvalid :
	((module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_wvalid :
	((module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_wvalid :
	(0))));
assign {module_main_memory_mem_axi_wdata,module_main_memory_mem_axi_wstrb} = (module_bram_intf0_access_ctrl_group_select == 0) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) ?  {module_cpu_mem_axi_wdata,module_cpu_mem_axi_wstrb} :
	((module_bram_intf0_access_ctrl_group_select == 1) ?  {module_dw_converter_b_wdata,module_dw_converter_b_wstrb} :
	((module_bram_intf0_access_ctrl_group_select == 2) ?  {module_intf_splitter2_b0_wdata,module_intf_splitter2_b0_wstrb} :
	((module_bram_intf0_access_ctrl_group_select == 3) ?  {module_intf_splitter2_b1_wdata,module_intf_splitter2_b1_wstrb} :
	(0))));
assign module_main_memory_mem_axi_arvalid = (module_bram_intf0_access_ctrl_group_select == 0) && (module_cpu_mem_axi_araddr >= 32'h00000000) && (module_cpu_mem_axi_araddr < (32'h00000000+32'h00004000)) ? module_cpu_mem_axi_arvalid :
	((module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_arvalid :
	((module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_arvalid :
	((module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_arvalid :
	(0))));
assign {module_main_memory_mem_axi_araddr} = (module_bram_intf0_access_ctrl_group_select == 0) && (module_cpu_mem_axi_araddr >= 32'h00000000) && (module_cpu_mem_axi_araddr < (32'h00000000+32'h00004000)) ?  {module_cpu_mem_axi_araddr} :
	((module_bram_intf0_access_ctrl_group_select == 1) ?  {module_dw_converter_b_araddr} :
	((module_bram_intf0_access_ctrl_group_select == 2) ?  {module_intf_splitter2_b0_araddr} :
	((module_bram_intf0_access_ctrl_group_select == 3) ?  {module_intf_splitter2_b1_araddr} :
	(0))));
assign module_dw_converter_b_rvalid = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_axi_rvalid :
	(0))));
assign {module_dw_converter_b_rdata} = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_axi_rdata} :
	(0))));
assign module_dw_converter_b_bvalid = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_main_memory_mem_b_valid :
	(0))));
assign {module_dw_converter_b_bresp} = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) ?  {module_main_memory_mem_b_response} :
	(0))));
assign module_intf_splitter2_b0_rvalid = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_axi_rvalid :
	(0))));
assign {module_intf_splitter2_b0_rdata} = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_axi_rdata} :
	(0))));
assign module_intf_splitter2_b0_bvalid = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_main_memory_mem_b_valid :
	(0))));
assign {module_intf_splitter2_b0_bresp} = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) ?  {module_main_memory_mem_b_response} :
	(0))));
assign module_intf_splitter2_b1_rvalid = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_axi_rvalid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_axi_rvalid :
	(0))));
assign {module_intf_splitter2_b1_rdata} = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_axi_rdata} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_axi_rdata} :
	(0))));
assign module_intf_splitter2_b1_bvalid = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_b_valid :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_main_memory_mem_b_valid :
	(0))));
assign {module_intf_splitter2_b1_bresp} = (1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_b_response} :
	((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) ?  {module_main_memory_mem_b_response} :
	(0))));
assign module_intf_concat2_a0_awvalid = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h10000000) && (module_cpu_mem_axi_awaddr < (32'h10000000+32'h10000000)) ? module_cpu_mem_axi_awvalid :
	(0);
assign {module_intf_concat2_a0_awaddr} = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h10000000) && (module_cpu_mem_axi_awaddr < (32'h10000000+32'h10000000)) ?  {module_cpu_mem_axi_awaddr} :
	(0);
assign module_intf_concat2_a0_wvalid = (1'b1) && (custom_cpu_axi_awaddr >= 32'h10000000) && (custom_cpu_axi_awaddr < (32'h10000000+32'h10000000)) ? module_cpu_mem_axi_wvalid :
	(0);
assign {module_intf_concat2_a0_wdata,module_intf_concat2_a0_wstrb} = (1'b1) && (custom_cpu_axi_awaddr >= 32'h10000000) && (custom_cpu_axi_awaddr < (32'h10000000+32'h10000000)) ?  {module_cpu_mem_axi_wdata,module_cpu_mem_axi_wstrb} :
	(0);
assign module_intf_concat2_a0_arvalid = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h10000000) && (module_cpu_mem_axi_araddr < (32'h10000000+32'h10000000)) ? module_cpu_mem_axi_arvalid :
	(0);
assign {module_intf_concat2_a0_araddr} = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h10000000) && (module_cpu_mem_axi_araddr < (32'h10000000+32'h10000000)) ?  {module_cpu_mem_axi_araddr} :
	(0);
assign module_intf_concat2_a1_awvalid = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h20000000) && (module_cpu_mem_axi_awaddr < (32'h20000000+32'h10000000)) ? module_cpu_mem_axi_awvalid :
	(0);
assign {module_intf_concat2_a1_awaddr} = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h20000000) && (module_cpu_mem_axi_awaddr < (32'h20000000+32'h10000000)) ?  {module_cpu_mem_axi_awaddr} :
	(0);
assign module_intf_concat2_a1_wvalid = (1'b1) && (custom_cpu_axi_awaddr >= 32'h20000000) && (custom_cpu_axi_awaddr < (32'h20000000+32'h10000000)) ? module_cpu_mem_axi_wvalid :
	(0);
assign {module_intf_concat2_a1_wdata,module_intf_concat2_a1_wstrb} = (1'b1) && (custom_cpu_axi_awaddr >= 32'h20000000) && (custom_cpu_axi_awaddr < (32'h20000000+32'h10000000)) ?  {module_cpu_mem_axi_wdata,module_cpu_mem_axi_wstrb} :
	(0);
assign module_intf_concat2_a1_arvalid = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h20000000) && (module_cpu_mem_axi_araddr < (32'h20000000+32'h10000000)) ? module_cpu_mem_axi_arvalid :
	(0);
assign {module_intf_concat2_a1_araddr} = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h20000000) && (module_cpu_mem_axi_araddr < (32'h20000000+32'h10000000)) ?  {module_cpu_mem_axi_araddr} :
	(0);
assign module_main_memory_mem_axi_rready = (1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_axi_rready :
	 ((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_axi_rready :
	 ((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_axi_rready :
	 ((1'b1) && (custom_cpu_axi_araddr >= 32'h00000000) && (custom_cpu_axi_araddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_axi_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_rready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_rready :
	 (0))))))))))))))));
assign module_main_memory_mem_b_ready = (1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_b_ready :
	 ((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_b_ready :
	 ((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_b_ready :
	 ((1'b1) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (module_bram_intf0_access_ctrl_group_select == 0) && (module_bram_intf0_access_ctrl_group_select == 0) ? module_cpu_mem_b_ready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 1) && (module_bram_intf0_access_ctrl_group_select == 1) ? module_dw_converter_b_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 2) && (module_bram_intf0_access_ctrl_group_select == 2) ? module_intf_splitter2_b0_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_bready :
	 ((1'b1) && (module_bram_intf0_access_ctrl_group_select == 3) && (module_bram_intf0_access_ctrl_group_select == 3) ? module_intf_splitter2_b1_bready :
	 (0))))))))))))))));
assign module_intf_concat2_a0_rready = (1'b1) && (custom_cpu_axi_araddr >= 32'h10000000) && (custom_cpu_axi_araddr < (32'h10000000+32'h10000000)) && (1'b1) ? module_cpu_mem_axi_rready :
	 (0);
assign module_intf_concat2_a0_bready = (1'b1) && (custom_cpu_axi_awaddr >= 32'h10000000) && (custom_cpu_axi_awaddr < (32'h10000000+32'h10000000)) && (1'b1) ? module_cpu_mem_b_ready :
	 (0);
assign module_intf_concat2_a1_rready = (1'b1) && (custom_cpu_axi_araddr >= 32'h20000000) && (custom_cpu_axi_araddr < (32'h20000000+32'h10000000)) && (1'b1) ? module_cpu_mem_axi_rready :
	 (0);
assign module_intf_concat2_a1_bready = (1'b1) && (custom_cpu_axi_awaddr >= 32'h20000000) && (custom_cpu_axi_awaddr < (32'h20000000+32'h10000000)) && (1'b1) ? module_cpu_mem_b_ready :
	 (0);
assign module_debug_a_axi_rready = (1'b1) && (custom_cpu_axi_araddr >= 32'h80000000) && (custom_cpu_axi_araddr < (32'h80000000+32'h10000000)) && (1'b1) ? module_cpu_mem_axi_rready :
	 (0);
assign module_debug_a_b_ready = (1'b1) && (custom_cpu_axi_awaddr >= 32'h80000000) && (custom_cpu_axi_awaddr < (32'h80000000+32'h10000000)) && (1'b1) ? module_cpu_mem_b_ready :
	 (0);
assign module_cpu_mem_axi_awready = (1'b1) && (module_cpu_mem_axi_awaddr >= 32'h80000000) && (module_cpu_mem_axi_awaddr < (32'h80000000+32'h10000000)) && (1'b1) ? module_debug_a_axi_awready :
	 ((module_bram_intf0_access_ctrl_group_select == 0) && (module_cpu_mem_axi_awaddr >= 32'h00000000) && (module_cpu_mem_axi_awaddr < (32'h00000000+32'h00004000)) && (1'b1) ? module_main_memory_mem_axi_awready :
	 ((1'b1) && (module_cpu_mem_axi_awaddr >= 32'h10000000) && (module_cpu_mem_axi_awaddr < (32'h10000000+32'h10000000)) && (1'b1) ? module_intf_concat2_a0_awready :
	 ((1'b1) && (module_cpu_mem_axi_awaddr >= 32'h20000000) && (module_cpu_mem_axi_awaddr < (32'h20000000+32'h10000000)) && (1'b1) ? module_intf_concat2_a1_awready :
	 (0))));
assign module_cpu_mem_axi_wready = (1'b1) && (custom_cpu_axi_awaddr >= 32'h80000000) && (custom_cpu_axi_awaddr < (32'h80000000+32'h10000000)) && (1'b1) ? module_debug_a_axi_wready :
	 ((module_bram_intf0_access_ctrl_group_select == 0) && (custom_cpu_axi_awaddr >= 32'h00000000) && (custom_cpu_axi_awaddr < (32'h00000000+32'h00004000)) && (1'b1) ? module_main_memory_mem_axi_wready :
	 ((1'b1) && (custom_cpu_axi_awaddr >= 32'h10000000) && (custom_cpu_axi_awaddr < (32'h10000000+32'h10000000)) && (1'b1) ? module_intf_concat2_a0_wready :
	 ((1'b1) && (custom_cpu_axi_awaddr >= 32'h20000000) && (custom_cpu_axi_awaddr < (32'h20000000+32'h10000000)) && (1'b1) ? module_intf_concat2_a1_wready :
	 (0))));
assign module_cpu_mem_axi_arready = (1'b1) && (module_cpu_mem_axi_araddr >= 32'h80000000) && (module_cpu_mem_axi_araddr < (32'h80000000+32'h10000000)) && (1'b1) ? module_debug_a_axi_arready :
	 ((module_bram_intf0_access_ctrl_group_select == 0) && (module_cpu_mem_axi_araddr >= 32'h00000000) && (module_cpu_mem_axi_araddr < (32'h00000000+32'h00004000)) && (1'b1) ? module_main_memory_mem_axi_arready :
	 ((1'b1) && (module_cpu_mem_axi_araddr >= 32'h10000000) && (module_cpu_mem_axi_araddr < (32'h10000000+32'h10000000)) && (1'b1) ? module_intf_concat2_a0_arready :
	 ((1'b1) && (module_cpu_mem_axi_araddr >= 32'h20000000) && (module_cpu_mem_axi_araddr < (32'h20000000+32'h10000000)) && (1'b1) ? module_intf_concat2_a1_arready :
	 (0))));
assign module_dw_converter_b_awready = (module_bram_intf0_access_ctrl_group_select == 1) && (1'b1) ? module_main_memory_mem_axi_awready :
	 (0);
assign module_dw_converter_b_wready = (module_bram_intf0_access_ctrl_group_select == 1) && (1'b1) ? module_main_memory_mem_axi_wready :
	 (0);
assign module_dw_converter_b_arready = (module_bram_intf0_access_ctrl_group_select == 1) && (1'b1) ? module_main_memory_mem_axi_arready :
	 (0);
assign module_intf_splitter2_b0_awready = (module_bram_intf0_access_ctrl_group_select == 2) && (1'b1) ? module_main_memory_mem_axi_awready :
	 (0);
assign module_intf_splitter2_b0_wready = (module_bram_intf0_access_ctrl_group_select == 2) && (1'b1) ? module_main_memory_mem_axi_wready :
	 (0);
assign module_intf_splitter2_b0_arready = (module_bram_intf0_access_ctrl_group_select == 2) && (1'b1) ? module_main_memory_mem_axi_arready :
	 (0);
assign module_intf_splitter2_b1_awready = (module_bram_intf0_access_ctrl_group_select == 3) && (1'b1) ? module_main_memory_mem_axi_awready :
	 (0);
assign module_intf_splitter2_b1_wready = (module_bram_intf0_access_ctrl_group_select == 3) && (1'b1) ? module_main_memory_mem_axi_wready :
	 (0);
assign module_intf_splitter2_b1_arready = (module_bram_intf0_access_ctrl_group_select == 3) && (1'b1) ? module_main_memory_mem_axi_arready :
	 (0);





IBUF
sys_reset_n_ibuf
(
.I(module_sys_reset_n_ibuf_I),
.O(module_sys_reset_n_ibuf_O)
);


IBUFDS_GTE2
refclk_ibuf
(
.I(module_refclk_ibuf_I),
.O(module_refclk_ibuf_O),
.IB(module_refclk_ibuf_IB),
.ODIV2(module_refclk_ibuf_ODIV2),
.CEB(0)
);


xdma_xc7
xdma_xc7_i
(
.sys_rst_n(module_xdma_xc7_i_sys_rst_n),
.sys_clk(module_xdma_xc7_i_sys_clk),
.pci_exp_txn(module_xdma_xc7_i_pci_exp_txn),
.pci_exp_txp(module_xdma_xc7_i_pci_exp_txp),
.pci_exp_rxn(module_xdma_xc7_i_pci_exp_rxn),
.pci_exp_rxp(module_xdma_xc7_i_pci_exp_rxp),
.m_axi_awaddr(module_xdma_xc7_i_m_axi_awaddr),
.m_axi_awlen(module_xdma_xc7_i_m_axi_awlen),
.m_axi_awsize(module_xdma_xc7_i_m_axi_awsize),
.m_axi_awburst(module_xdma_xc7_i_m_axi_awburst),
.m_axi_awvalid(module_xdma_xc7_i_m_axi_awvalid),
.m_axi_awready(module_xdma_xc7_i_m_axi_awready),
.m_axi_wdata(module_xdma_xc7_i_m_axi_wdata),
.m_axi_wstrb(module_xdma_xc7_i_m_axi_wstrb),
.m_axi_wvalid(module_xdma_xc7_i_m_axi_wvalid),
.m_axi_wlast(module_xdma_xc7_i_m_axi_wlast),
.m_axi_wready(module_xdma_xc7_i_m_axi_wready),
.m_axi_bresp(module_xdma_xc7_i_m_axi_bresp),
.m_axi_bvalid(module_xdma_xc7_i_m_axi_bvalid),
.m_axi_bready(module_xdma_xc7_i_m_axi_bready),
.m_axi_araddr(module_xdma_xc7_i_m_axi_araddr),
.m_axi_arlen(module_xdma_xc7_i_m_axi_arlen),
.m_axi_arsize(module_xdma_xc7_i_m_axi_arsize),
.m_axi_arburst(module_xdma_xc7_i_m_axi_arburst),
.m_axi_arvalid(module_xdma_xc7_i_m_axi_arvalid),
.m_axi_arready(module_xdma_xc7_i_m_axi_arready),
.m_axi_rdata(module_xdma_xc7_i_m_axi_rdata),
.m_axi_rresp(module_xdma_xc7_i_m_axi_rresp),
.m_axi_rvalid(module_xdma_xc7_i_m_axi_rvalid),
.m_axi_rlast(module_xdma_xc7_i_m_axi_rlast),
.m_axi_rready(module_xdma_xc7_i_m_axi_rready),
.m_axi_bid(0),
.m_axi_rid(0),
.m_axil_awaddr(module_xdma_xc7_i_m_axil_awaddr),
.m_axil_awvalid(module_xdma_xc7_i_m_axil_awvalid),
.m_axil_awready(module_xdma_xc7_i_m_axil_awready),
.m_axil_wdata(module_xdma_xc7_i_m_axil_wdata),
.m_axil_wstrb(module_xdma_xc7_i_m_axil_wstrb),
.m_axil_wvalid(module_xdma_xc7_i_m_axil_wvalid),
.m_axil_wready(module_xdma_xc7_i_m_axil_wready),
.m_axil_bresp(module_xdma_xc7_i_m_axil_bresp),
.m_axil_bvalid(module_xdma_xc7_i_m_axil_bvalid),
.m_axil_bready(module_xdma_xc7_i_m_axil_bready),
.m_axil_araddr(module_xdma_xc7_i_m_axil_araddr),
.m_axil_arvalid(module_xdma_xc7_i_m_axil_arvalid),
.m_axil_arready(module_xdma_xc7_i_m_axil_arready),
.m_axil_rdata(module_xdma_xc7_i_m_axil_rdata),
.m_axil_rresp(module_xdma_xc7_i_m_axil_rresp),
.m_axil_rvalid(module_xdma_xc7_i_m_axil_rvalid),
.m_axil_rready(module_xdma_xc7_i_m_axil_rready),
.s_axil_awaddr(module_xdma_xc7_i_s_axil_awaddr),
.s_axil_awvalid(module_xdma_xc7_i_s_axil_awvalid),
.s_axil_awready(module_xdma_xc7_i_s_axil_awready),
.s_axil_wdata(module_xdma_xc7_i_s_axil_wdata),
.s_axil_wstrb(module_xdma_xc7_i_s_axil_wstrb),
.s_axil_wvalid(module_xdma_xc7_i_s_axil_wvalid),
.s_axil_wready(module_xdma_xc7_i_s_axil_wready),
.s_axil_bresp(module_xdma_xc7_i_s_axil_bresp),
.s_axil_bvalid(module_xdma_xc7_i_s_axil_bvalid),
.s_axil_bready(module_xdma_xc7_i_s_axil_bready),
.s_axil_araddr(module_xdma_xc7_i_s_axil_araddr),
.s_axil_arvalid(module_xdma_xc7_i_s_axil_arvalid),
.s_axil_arready(module_xdma_xc7_i_s_axil_arready),
.s_axil_rdata(module_xdma_xc7_i_s_axil_rdata),
.s_axil_rresp(module_xdma_xc7_i_s_axil_rresp),
.s_axil_rvalid(module_xdma_xc7_i_s_axil_rvalid),
.s_axil_rready(module_xdma_xc7_i_s_axil_rready),
.s_axil_awprot(0),
.s_axil_arprot(0),
.c2h_dsc_byp_ready_0(module_xdma_xc7_i_c2h_dsc_byp_ready_0),
.c2h_dsc_byp_src_addr_0(module_xdma_xc7_i_c2h_dsc_byp_src_addr_0),
.c2h_dsc_byp_dst_addr_0(module_xdma_xc7_i_c2h_dsc_byp_dst_addr_0),
.c2h_dsc_byp_len_0(module_xdma_xc7_i_c2h_dsc_byp_len_0),
.c2h_dsc_byp_ctl_0(module_xdma_xc7_i_c2h_dsc_byp_ctl_0),
.c2h_dsc_byp_load_0(module_xdma_xc7_i_c2h_dsc_byp_load_0),
.h2c_dsc_byp_ready_0(module_xdma_xc7_i_h2c_dsc_byp_ready_0),
.h2c_dsc_byp_src_addr_0(module_xdma_xc7_i_h2c_dsc_byp_src_addr_0),
.h2c_dsc_byp_dst_addr_0(module_xdma_xc7_i_h2c_dsc_byp_dst_addr_0),
.h2c_dsc_byp_len_0(module_xdma_xc7_i_h2c_dsc_byp_len_0),
.h2c_dsc_byp_ctl_0(module_xdma_xc7_i_h2c_dsc_byp_ctl_0),
.h2c_dsc_byp_load_0(module_xdma_xc7_i_h2c_dsc_byp_load_0),
.c2h_sts_0(module_xdma_xc7_i_c2h_sts_0),
.h2c_sts_0(module_xdma_xc7_i_h2c_sts_0),
.usr_irq_req(module_xdma_xc7_i_usr_irq_req),
.usr_irq_ack(module_xdma_xc7_i_usr_irq_ack),
.axi_aclk(module_xdma_xc7_i_axi_aclk),
.axi_aresetn(module_xdma_xc7_i_axi_aresetn)
);


pcie_controller
#(
.NUM_QUEUES(PARAMETER_PCIE_CONTROLLER_INST_NUM_QUEUES),
.SLEEP_TIMER_VAL(PARAMETER_PCIE_CONTROLLER_INST_SLEEP_TIMER_VAL)
)
pcie_controller_inst
(
.clk(module_pcie_controller_inst_clk),
.reset(module_pcie_controller_inst_reset),
.s_axil_awaddr(module_pcie_controller_inst_s_axil_awaddr),
.s_axil_awvalid(module_pcie_controller_inst_s_axil_awvalid),
.s_axil_awready(module_pcie_controller_inst_s_axil_awready),
.s_axil_wdata(module_pcie_controller_inst_s_axil_wdata),
.s_axil_wstrb(module_pcie_controller_inst_s_axil_wstrb),
.s_axil_wvalid(module_pcie_controller_inst_s_axil_wvalid),
.s_axil_wready(module_pcie_controller_inst_s_axil_wready),
.s_axil_bresp(module_pcie_controller_inst_s_axil_bresp),
.s_axil_bvalid(module_pcie_controller_inst_s_axil_bvalid),
.s_axil_bready(module_pcie_controller_inst_s_axil_bready),
.s_axil_araddr(module_pcie_controller_inst_s_axil_araddr),
.s_axil_arvalid(module_pcie_controller_inst_s_axil_arvalid),
.s_axil_arready(module_pcie_controller_inst_s_axil_arready),
.s_axil_rdata(module_pcie_controller_inst_s_axil_rdata),
.s_axil_rresp(module_pcie_controller_inst_s_axil_rresp),
.s_axil_rvalid(module_pcie_controller_inst_s_axil_rvalid),
.s_axil_rready(module_pcie_controller_inst_s_axil_rready),
.c2h_dsc_byp_ready_0(module_pcie_controller_inst_c2h_dsc_byp_ready_0),
.c2h_dsc_byp_src_addr_0(module_pcie_controller_inst_c2h_dsc_byp_src_addr_0),
.c2h_dsc_byp_dst_addr_0(module_pcie_controller_inst_c2h_dsc_byp_dst_addr_0),
.c2h_dsc_byp_len_0(module_pcie_controller_inst_c2h_dsc_byp_len_0),
.c2h_dsc_byp_ctl_0(module_pcie_controller_inst_c2h_dsc_byp_ctl_0),
.c2h_dsc_byp_load_0(module_pcie_controller_inst_c2h_dsc_byp_load_0),
.h2c_dsc_byp_ready_0(module_pcie_controller_inst_h2c_dsc_byp_ready_0),
.h2c_dsc_byp_src_addr_0(module_pcie_controller_inst_h2c_dsc_byp_src_addr_0),
.h2c_dsc_byp_dst_addr_0(module_pcie_controller_inst_h2c_dsc_byp_dst_addr_0),
.h2c_dsc_byp_len_0(module_pcie_controller_inst_h2c_dsc_byp_len_0),
.h2c_dsc_byp_ctl_0(module_pcie_controller_inst_h2c_dsc_byp_ctl_0),
.h2c_dsc_byp_load_0(module_pcie_controller_inst_h2c_dsc_byp_load_0),
.dma_engine_config_axil_awaddr(module_pcie_controller_inst_dma_engine_config_axil_awaddr),
.dma_engine_config_axil_awvalid(module_pcie_controller_inst_dma_engine_config_axil_awvalid),
.dma_engine_config_axil_awready(module_pcie_controller_inst_dma_engine_config_axil_awready),
.dma_engine_config_axil_wdata(module_pcie_controller_inst_dma_engine_config_axil_wdata),
.dma_engine_config_axil_wstrb(module_pcie_controller_inst_dma_engine_config_axil_wstrb),
.dma_engine_config_axil_wvalid(module_pcie_controller_inst_dma_engine_config_axil_wvalid),
.dma_engine_config_axil_wready(module_pcie_controller_inst_dma_engine_config_axil_wready),
.dma_engine_config_axil_bresp(module_pcie_controller_inst_dma_engine_config_axil_bresp),
.dma_engine_config_axil_bvalid(module_pcie_controller_inst_dma_engine_config_axil_bvalid),
.dma_engine_config_axil_bready(module_pcie_controller_inst_dma_engine_config_axil_bready),
.dma_engine_config_axil_araddr(module_pcie_controller_inst_dma_engine_config_axil_araddr),
.dma_engine_config_axil_arvalid(module_pcie_controller_inst_dma_engine_config_axil_arvalid),
.dma_engine_config_axil_arready(module_pcie_controller_inst_dma_engine_config_axil_arready),
.dma_engine_config_axil_rdata(module_pcie_controller_inst_dma_engine_config_axil_rdata),
.dma_engine_config_axil_rresp(module_pcie_controller_inst_dma_engine_config_axil_rresp),
.dma_engine_config_axil_rvalid(module_pcie_controller_inst_dma_engine_config_axil_rvalid),
.dma_engine_config_axil_rready(module_pcie_controller_inst_dma_engine_config_axil_rready),
.endpoint_ctrl(module_pcie_controller_inst_endpoint_ctrl),
.s_axi_awaddr(module_pcie_controller_inst_s_axi_awaddr),
.s_axi_awlen(module_pcie_controller_inst_s_axi_awlen),
.s_axi_awsize(module_pcie_controller_inst_s_axi_awsize),
.s_axi_awburst(module_pcie_controller_inst_s_axi_awburst),
.s_axi_awvalid(module_pcie_controller_inst_s_axi_awvalid),
.s_axi_awready(module_pcie_controller_inst_s_axi_awready),
.s_axi_wdata(module_pcie_controller_inst_s_axi_wdata),
.s_axi_wstrb(module_pcie_controller_inst_s_axi_wstrb),
.s_axi_wvalid(module_pcie_controller_inst_s_axi_wvalid),
.s_axi_wlast(module_pcie_controller_inst_s_axi_wlast),
.s_axi_wready(module_pcie_controller_inst_s_axi_wready),
.s_axi_bresp(module_pcie_controller_inst_s_axi_bresp),
.s_axi_bvalid(module_pcie_controller_inst_s_axi_bvalid),
.s_axi_bready(module_pcie_controller_inst_s_axi_bready),
.s_axi_araddr(module_pcie_controller_inst_s_axi_araddr),
.s_axi_arlen(module_pcie_controller_inst_s_axi_arlen),
.s_axi_arsize(module_pcie_controller_inst_s_axi_arsize),
.s_axi_arburst(module_pcie_controller_inst_s_axi_arburst),
.s_axi_arvalid(module_pcie_controller_inst_s_axi_arvalid),
.s_axi_arready(module_pcie_controller_inst_s_axi_arready),
.s_axi_rdata(module_pcie_controller_inst_s_axi_rdata),
.s_axi_rresp(module_pcie_controller_inst_s_axi_rresp),
.s_axi_rvalid(module_pcie_controller_inst_s_axi_rvalid),
.s_axi_rlast(module_pcie_controller_inst_s_axi_rlast),
.s_axi_rready(module_pcie_controller_inst_s_axi_rready),
.s_axi_wvalid_to_mem(module_pcie_controller_inst_s_axi_wvalid_to_mem),
.s_axi_wstrb_to_mem(module_pcie_controller_inst_s_axi_wstrb_to_mem),
.s_axi_rvalid_from_mem(module_pcie_controller_inst_s_axi_rvalid_from_mem),
.s_axi_wready_from_mem(module_pcie_controller_inst_s_axi_wready_from_mem),
.s_axi_rready_to_mem(module_pcie_controller_inst_s_axi_rready_to_mem),
.s_axi_bready_to_mem(module_pcie_controller_inst_s_axi_bready_to_mem),
.s_axi_bvalid_from_mem(module_pcie_controller_inst_s_axi_bvalid_from_mem),
.m_axil_awaddr(module_pcie_controller_inst_m_axil_awaddr),
.m_axil_awvalid(module_pcie_controller_inst_m_axil_awvalid),
.m_axil_awready(module_pcie_controller_inst_m_axil_awready),
.m_axil_wdata(module_pcie_controller_inst_m_axil_wdata),
.m_axil_wvalid(module_pcie_controller_inst_m_axil_wvalid),
.m_axil_wready(module_pcie_controller_inst_m_axil_wready),
.m_axil_wstrb(module_pcie_controller_inst_m_axil_wstrb),
.m_axil_bresp(module_pcie_controller_inst_m_axil_bresp),
.m_axil_bvalid(module_pcie_controller_inst_m_axil_bvalid),
.m_axil_bready(module_pcie_controller_inst_m_axil_bready),
.m_axil_araddr(module_pcie_controller_inst_m_axil_araddr),
.m_axil_arvalid(module_pcie_controller_inst_m_axil_arvalid),
.m_axil_arready(module_pcie_controller_inst_m_axil_arready),
.m_axil_rdata(module_pcie_controller_inst_m_axil_rdata),
.m_axil_rresp(module_pcie_controller_inst_m_axil_rresp),
.m_axil_rvalid(module_pcie_controller_inst_m_axil_rvalid),
.m_axil_rready(module_pcie_controller_inst_m_axil_rready),
.interrupt_usr(module_pcie_controller_inst_interrupt_usr),
.interrupt_usr_ack(0),
.c2h_sts_0(module_pcie_controller_inst_c2h_sts_0),
.h2c_sts_0(module_pcie_controller_inst_h2c_sts_0),
.cfg_intf_axil_awaddr(module_pcie_controller_inst_cfg_intf_axil_awaddr),
.cfg_intf_axil_awvalid(module_pcie_controller_inst_cfg_intf_axil_awvalid),
.cfg_intf_axil_awready(module_pcie_controller_inst_cfg_intf_axil_awready),
.cfg_intf_axil_wdata(module_pcie_controller_inst_cfg_intf_axil_wdata),
.cfg_intf_axil_wstrb(module_pcie_controller_inst_cfg_intf_axil_wstrb),
.cfg_intf_axil_wvalid(module_pcie_controller_inst_cfg_intf_axil_wvalid),
.cfg_intf_axil_wready(module_pcie_controller_inst_cfg_intf_axil_wready),
.cfg_intf_axil_bresp(module_pcie_controller_inst_cfg_intf_axil_bresp),
.cfg_intf_axil_bvalid(module_pcie_controller_inst_cfg_intf_axil_bvalid),
.cfg_intf_axil_bready(module_pcie_controller_inst_cfg_intf_axil_bready),
.cfg_intf_axil_araddr(module_pcie_controller_inst_cfg_intf_axil_araddr),
.cfg_intf_axil_arvalid(module_pcie_controller_inst_cfg_intf_axil_arvalid),
.cfg_intf_axil_arready(module_pcie_controller_inst_cfg_intf_axil_arready),
.cfg_intf_axil_rdata(module_pcie_controller_inst_cfg_intf_axil_rdata),
.cfg_intf_axil_rresp(module_pcie_controller_inst_cfg_intf_axil_rresp),
.cfg_intf_axil_rvalid(module_pcie_controller_inst_cfg_intf_axil_rvalid),
.cfg_intf_axil_rready(module_pcie_controller_inst_cfg_intf_axil_rready),
.usr_irq_req(module_pcie_controller_inst_usr_irq_req),
.usr_irq_ack(module_pcie_controller_inst_usr_irq_ack)
);


uart_axi
#(
.ADDR_WIDTH(PARAMETER_DEBUG_ADDR_WIDTH),
.DATA_WIDTH(PARAMETER_DEBUG_DATA_WIDTH),
.CLKS_PER_BIT(PARAMETER_DEBUG_CLKS_PER_BIT)
)
debug
(
.clk(module_debug_clk),
.rst(module_debug_rst),
.a_axi_araddr(custom_debug_araddr),
.a_axi_arvalid(module_debug_a_axi_arvalid),
.a_axi_arready(module_debug_a_axi_arready),
.a_axi_awaddr(custom_debug_awaddr),
.a_axi_awvalid(module_debug_a_axi_awvalid),
.a_axi_awready(module_debug_a_axi_awready),
.a_axi_rdata(module_debug_a_axi_rdata),
.a_axi_rvalid(module_debug_a_axi_rvalid),
.a_axi_rready(module_debug_a_axi_rready),
.a_axi_wdata(module_debug_a_axi_wdata),
.a_axi_wstrb(module_debug_a_axi_wstrb),
.a_axi_wvalid(module_debug_a_axi_wvalid),
.a_axi_wready(module_debug_a_axi_wready),
.a_b_ready(module_debug_a_b_ready),
.a_b_response(module_debug_a_b_response),
.a_b_valid(module_debug_a_b_valid),
.urx(module_debug_urx),
.utx(module_debug_utx)
);


ss_access_controller
#(
.NUM_PORTS(PARAMETER_BRAM_INTF0_ACCESS_CTRL_NUM_PORTS),
.PORT_IDX_BITS(PARAMETER_BRAM_INTF0_ACCESS_CTRL_PORT_IDX_BITS)
)
bram_intf0_access_ctrl
(
.clk(module_bram_intf0_access_ctrl_clk),
.reset(module_bram_intf0_access_ctrl_reset),
.arvalid(module_bram_intf0_access_ctrl_arvalid),
.arready(module_bram_intf0_access_ctrl_arready),
.rvalid(module_bram_intf0_access_ctrl_rvalid),
.rready(module_bram_intf0_access_ctrl_rready),
.awvalid(module_bram_intf0_access_ctrl_awvalid),
.awready(module_bram_intf0_access_ctrl_awready),
.bvalid(module_bram_intf0_access_ctrl_bvalid),
.bready(module_bram_intf0_access_ctrl_bready),
.group_select(module_bram_intf0_access_ctrl_group_select)
);


endpoint_selector
#(
.AXI_BUS_WIDTH(PARAMETER_ENDPOINT_SELECT_INST_AXI_BUS_WIDTH),
.AXI_ADDR_WIDTH(PARAMETER_ENDPOINT_SELECT_INST_AXI_ADDR_WIDTH)
)
endpoint_select_inst
(
.endpoint_ctrl(module_endpoint_select_inst_endpoint_ctrl),
.pci_axi_awaddr(module_endpoint_select_inst_pci_axi_awaddr),
.pci_axi_awlen(module_endpoint_select_inst_pci_axi_awlen),
.pci_axi_awsize(module_endpoint_select_inst_pci_axi_awsize),
.pci_axi_awburst(module_endpoint_select_inst_pci_axi_awburst),
.pci_axi_awvalid(module_endpoint_select_inst_pci_axi_awvalid),
.pci_axi_awready(module_endpoint_select_inst_pci_axi_awready),
.pci_axi_wdata(module_endpoint_select_inst_pci_axi_wdata),
.pci_axi_wstrb(module_endpoint_select_inst_pci_axi_wstrb),
.pci_axi_wvalid(module_endpoint_select_inst_pci_axi_wvalid),
.pci_axi_wlast(module_endpoint_select_inst_pci_axi_wlast),
.pci_axi_wready(module_endpoint_select_inst_pci_axi_wready),
.pci_axi_bresp(module_endpoint_select_inst_pci_axi_bresp),
.pci_axi_bvalid(module_endpoint_select_inst_pci_axi_bvalid),
.pci_axi_bready(module_endpoint_select_inst_pci_axi_bready),
.pci_axi_araddr(module_endpoint_select_inst_pci_axi_araddr),
.pci_axi_arlen(module_endpoint_select_inst_pci_axi_arlen),
.pci_axi_arsize(module_endpoint_select_inst_pci_axi_arsize),
.pci_axi_arburst(module_endpoint_select_inst_pci_axi_arburst),
.pci_axi_arvalid(module_endpoint_select_inst_pci_axi_arvalid),
.pci_axi_arready(module_endpoint_select_inst_pci_axi_arready),
.pci_axi_rdata(module_endpoint_select_inst_pci_axi_rdata),
.pci_axi_rresp(module_endpoint_select_inst_pci_axi_rresp),
.pci_axi_rvalid(module_endpoint_select_inst_pci_axi_rvalid),
.pci_axi_rlast(module_endpoint_select_inst_pci_axi_rlast),
.pci_axi_rready(module_endpoint_select_inst_pci_axi_rready),
.vc_axi_awaddr(module_endpoint_select_inst_vc_axi_awaddr),
.vc_axi_awlen(module_endpoint_select_inst_vc_axi_awlen),
.vc_axi_awsize(module_endpoint_select_inst_vc_axi_awsize),
.vc_axi_awburst(module_endpoint_select_inst_vc_axi_awburst),
.vc_axi_awvalid(module_endpoint_select_inst_vc_axi_awvalid),
.vc_axi_awready(module_endpoint_select_inst_vc_axi_awready),
.vc_axi_wdata(module_endpoint_select_inst_vc_axi_wdata),
.vc_axi_wstrb(module_endpoint_select_inst_vc_axi_wstrb),
.vc_axi_wvalid(module_endpoint_select_inst_vc_axi_wvalid),
.vc_axi_wlast(module_endpoint_select_inst_vc_axi_wlast),
.vc_axi_wready(module_endpoint_select_inst_vc_axi_wready),
.vc_axi_bresp(module_endpoint_select_inst_vc_axi_bresp),
.vc_axi_bvalid(module_endpoint_select_inst_vc_axi_bvalid),
.vc_axi_bready(module_endpoint_select_inst_vc_axi_bready),
.vc_axi_araddr(module_endpoint_select_inst_vc_axi_araddr),
.vc_axi_arlen(module_endpoint_select_inst_vc_axi_arlen),
.vc_axi_arsize(module_endpoint_select_inst_vc_axi_arsize),
.vc_axi_arburst(module_endpoint_select_inst_vc_axi_arburst),
.vc_axi_arvalid(module_endpoint_select_inst_vc_axi_arvalid),
.vc_axi_arready(module_endpoint_select_inst_vc_axi_arready),
.vc_axi_rdata(module_endpoint_select_inst_vc_axi_rdata),
.vc_axi_rresp(module_endpoint_select_inst_vc_axi_rresp),
.vc_axi_rvalid(module_endpoint_select_inst_vc_axi_rvalid),
.vc_axi_rlast(module_endpoint_select_inst_vc_axi_rlast),
.vc_axi_rready(module_endpoint_select_inst_vc_axi_rready),
.ss_awaddr(module_endpoint_select_inst_ss_awaddr),
.ss_awlen(module_endpoint_select_inst_ss_awlen),
.ss_awsize(module_endpoint_select_inst_ss_awsize),
.ss_awburst(module_endpoint_select_inst_ss_awburst),
.ss_awvalid(module_endpoint_select_inst_ss_awvalid),
.ss_awready(module_endpoint_select_inst_ss_awready),
.ss_wdata(module_endpoint_select_inst_ss_wdata),
.ss_wstrb(module_endpoint_select_inst_ss_wstrb),
.ss_wvalid(module_endpoint_select_inst_ss_wvalid),
.ss_wlast(module_endpoint_select_inst_ss_wlast),
.ss_wready(module_endpoint_select_inst_ss_wready),
.ss_bresp(module_endpoint_select_inst_ss_bresp),
.ss_bvalid(module_endpoint_select_inst_ss_bvalid),
.ss_bready(module_endpoint_select_inst_ss_bready),
.ss_araddr(module_endpoint_select_inst_ss_araddr),
.ss_arlen(module_endpoint_select_inst_ss_arlen),
.ss_arsize(module_endpoint_select_inst_ss_arsize),
.ss_arburst(module_endpoint_select_inst_ss_arburst),
.ss_arvalid(module_endpoint_select_inst_ss_arvalid),
.ss_arready(module_endpoint_select_inst_ss_arready),
.ss_rdata(module_endpoint_select_inst_ss_rdata),
.ss_rresp(module_endpoint_select_inst_ss_rresp),
.ss_rvalid(module_endpoint_select_inst_ss_rvalid),
.ss_rlast(module_endpoint_select_inst_ss_rlast),
.ss_rready(module_endpoint_select_inst_ss_rready)
);


data_width_converter
#(
.DATA_A_WIDTH(PARAMETER_DW_CONVERTER_DATA_A_WIDTH),
.DATA_B_WIDTH(PARAMETER_DW_CONVERTER_DATA_B_WIDTH),
.ADDR_WIDTH(PARAMETER_DW_CONVERTER_ADDR_WIDTH)
)
dw_converter
(
.clk(module_dw_converter_clk),
.rst(module_dw_converter_rst),
.a_awaddr(module_dw_converter_a_awaddr),
.a_awlen(module_dw_converter_a_awlen),
.a_awsize(module_dw_converter_a_awsize),
.a_awburst(module_dw_converter_a_awburst),
.a_awvalid(module_dw_converter_a_awvalid),
.a_awready(module_dw_converter_a_awready),
.a_wdata(module_dw_converter_a_wdata),
.a_wstrb(module_dw_converter_a_wstrb),
.a_wvalid(module_dw_converter_a_wvalid),
.a_wlast(module_dw_converter_a_wlast),
.a_wready(module_dw_converter_a_wready),
.a_bresp(module_dw_converter_a_bresp),
.a_bvalid(module_dw_converter_a_bvalid),
.a_bready(module_dw_converter_a_bready),
.a_araddr(module_dw_converter_a_araddr),
.a_arlen(module_dw_converter_a_arlen),
.a_arsize(module_dw_converter_a_arsize),
.a_arburst(module_dw_converter_a_arburst),
.a_arvalid(module_dw_converter_a_arvalid),
.a_arready(module_dw_converter_a_arready),
.a_rdata(module_dw_converter_a_rdata),
.a_rresp(module_dw_converter_a_rresp),
.a_rvalid(module_dw_converter_a_rvalid),
.a_rlast(module_dw_converter_a_rlast),
.a_rready(module_dw_converter_a_rready),
.b_awaddr(module_dw_converter_b_awaddr),
.b_awvalid(module_dw_converter_b_awvalid),
.b_awready(module_dw_converter_b_awready),
.b_wdata(module_dw_converter_b_wdata),
.b_wstrb(module_dw_converter_b_wstrb),
.b_wvalid(module_dw_converter_b_wvalid),
.b_wready(module_dw_converter_b_wready),
.b_bresp(module_dw_converter_b_bresp),
.b_bvalid(module_dw_converter_b_bvalid),
.b_bready(module_dw_converter_b_bready),
.b_araddr(module_dw_converter_b_araddr),
.b_arvalid(module_dw_converter_b_arvalid),
.b_arready(module_dw_converter_b_arready),
.b_rdata(module_dw_converter_b_rdata),
.b_rresp(0),
.b_rvalid(module_dw_converter_b_rvalid),
.b_rready(module_dw_converter_b_rready)
);


bram_axi
#(
.ADDR_WIDTH(PARAMETER_MAIN_MEMORY_ADDR_WIDTH),
.DATA_WIDTH(PARAMETER_MAIN_MEMORY_DATA_WIDTH),
.INITIALIZE(PARAMETER_MAIN_MEMORY_INITIALIZE),
.INIT_FILE(PARAMETER_MAIN_MEMORY_INIT_FILE)
)
main_memory
(
.clk(module_main_memory_clk),
.rst(module_main_memory_rst),
.mem_axi_araddr(custom_main_mem_araddr),
.mem_axi_arvalid(module_main_memory_mem_axi_arvalid),
.mem_axi_arready(module_main_memory_mem_axi_arready),
.mem_axi_awaddr(custom_main_mem_awaddr),
.mem_axi_awvalid(module_main_memory_mem_axi_awvalid),
.mem_axi_awready(module_main_memory_mem_axi_awready),
.mem_axi_rdata(module_main_memory_mem_axi_rdata),
.mem_axi_rvalid(module_main_memory_mem_axi_rvalid),
.mem_axi_rready(module_main_memory_mem_axi_rready),
.mem_axi_wdata(module_main_memory_mem_axi_wdata),
.mem_axi_wstrb(module_main_memory_mem_axi_wstrb),
.mem_axi_wvalid(module_main_memory_mem_axi_wvalid),
.mem_axi_wready(module_main_memory_mem_axi_wready),
.mem_b_ready(module_main_memory_mem_b_ready),
.mem_b_response(module_main_memory_mem_b_response),
.mem_b_valid(module_main_memory_mem_b_valid)
);


interface_splitter_2
#(
.DATA_WIDTH(PARAMETER_INTF_SPLITTER2_DATA_WIDTH),
.ADDR_WIDTH(PARAMETER_INTF_SPLITTER2_ADDR_WIDTH),
.STRB_WIDTH(PARAMETER_INTF_SPLITTER2_STRB_WIDTH)
)
intf_splitter2
(
.a_arvalid(module_intf_splitter2_a_arvalid),
.a_arready(module_intf_splitter2_a_arready),
.a_araddr(module_intf_splitter2_a_araddr),
.a_rvalid(module_intf_splitter2_a_rvalid),
.a_rready(module_intf_splitter2_a_rready),
.a_rdata(module_intf_splitter2_a_rdata),
.a_rresp(module_intf_splitter2_a_rresp),
.a_awvalid(module_intf_splitter2_a_awvalid),
.a_awready(module_intf_splitter2_a_awready),
.a_awaddr(module_intf_splitter2_a_awaddr),
.a_wvalid(module_intf_splitter2_a_wvalid),
.a_wready(module_intf_splitter2_a_wready),
.a_wdata(module_intf_splitter2_a_wdata),
.a_wstrb(module_intf_splitter2_a_wstrb),
.a_bvalid(module_intf_splitter2_a_bvalid),
.a_bready(module_intf_splitter2_a_bready),
.a_bresp(module_intf_splitter2_a_bresp),
.b0_awaddr(module_intf_splitter2_b0_awaddr),
.b0_awvalid(module_intf_splitter2_b0_awvalid),
.b0_awready(module_intf_splitter2_b0_awready),
.b0_wdata(module_intf_splitter2_b0_wdata),
.b0_wstrb(module_intf_splitter2_b0_wstrb),
.b0_wvalid(module_intf_splitter2_b0_wvalid),
.b0_wready(module_intf_splitter2_b0_wready),
.b0_bresp(module_intf_splitter2_b0_bresp),
.b0_bvalid(module_intf_splitter2_b0_bvalid),
.b0_bready(module_intf_splitter2_b0_bready),
.b0_araddr(module_intf_splitter2_b0_araddr),
.b0_arvalid(module_intf_splitter2_b0_arvalid),
.b0_arready(module_intf_splitter2_b0_arready),
.b0_rdata(module_intf_splitter2_b0_rdata),
.b0_rresp(0),
.b0_rvalid(module_intf_splitter2_b0_rvalid),
.b0_rready(module_intf_splitter2_b0_rready),
.b1_awaddr(module_intf_splitter2_b1_awaddr),
.b1_awvalid(module_intf_splitter2_b1_awvalid),
.b1_awready(module_intf_splitter2_b1_awready),
.b1_wdata(module_intf_splitter2_b1_wdata),
.b1_wstrb(module_intf_splitter2_b1_wstrb),
.b1_wvalid(module_intf_splitter2_b1_wvalid),
.b1_wready(module_intf_splitter2_b1_wready),
.b1_bresp(module_intf_splitter2_b1_bresp),
.b1_bvalid(module_intf_splitter2_b1_bvalid),
.b1_bready(module_intf_splitter2_b1_bready),
.b1_araddr(module_intf_splitter2_b1_araddr),
.b1_arvalid(module_intf_splitter2_b1_arvalid),
.b1_arready(module_intf_splitter2_b1_arready),
.b1_rdata(module_intf_splitter2_b1_rdata),
.b1_rresp(0),
.b1_rvalid(module_intf_splitter2_b1_rvalid),
.b1_rready(module_intf_splitter2_b1_rready)
);


interface_concat_2
#(
.DATA_WIDTH(PARAMETER_INTF_CONCAT2_DATA_WIDTH),
.ADDR_WIDTH(PARAMETER_INTF_CONCAT2_ADDR_WIDTH),
.STRB_WIDTH(PARAMETER_INTF_CONCAT2_STRB_WIDTH)
)
intf_concat2
(
.b_arvalid(module_intf_concat2_b_arvalid),
.b_arready(module_intf_concat2_b_arready),
.b_araddr(module_intf_concat2_b_araddr),
.b_rvalid(module_intf_concat2_b_rvalid),
.b_rready(module_intf_concat2_b_rready),
.b_rdata(module_intf_concat2_b_rdata),
.b_rresp(module_intf_concat2_b_rresp),
.b_awvalid(module_intf_concat2_b_awvalid),
.b_awready(module_intf_concat2_b_awready),
.b_awaddr(module_intf_concat2_b_awaddr),
.b_wvalid(module_intf_concat2_b_wvalid),
.b_wready(module_intf_concat2_b_wready),
.b_wdata(module_intf_concat2_b_wdata),
.b_wstrb(module_intf_concat2_b_wstrb),
.b_bvalid(module_intf_concat2_b_bvalid),
.b_bready(module_intf_concat2_b_bready),
.b_bresp(module_intf_concat2_b_bresp),
.a0_awaddr(custom_intf_concat_a0_awaddr),
.a0_awvalid(module_intf_concat2_a0_awvalid),
.a0_awready(module_intf_concat2_a0_awready),
.a0_wdata(module_intf_concat2_a0_wdata),
.a0_wstrb(module_intf_concat2_a0_wstrb),
.a0_wvalid(module_intf_concat2_a0_wvalid),
.a0_wready(module_intf_concat2_a0_wready),
.a0_bresp(module_intf_concat2_a0_bresp),
.a0_bvalid(module_intf_concat2_a0_bvalid),
.a0_bready(module_intf_concat2_a0_bready),
.a0_araddr(custom_intf_concat_a0_araddr),
.a0_arvalid(module_intf_concat2_a0_arvalid),
.a0_arready(module_intf_concat2_a0_arready),
.a0_rdata(module_intf_concat2_a0_rdata),
.a0_rresp(module_intf_concat2_a0_rresp),
.a0_rvalid(module_intf_concat2_a0_rvalid),
.a0_rready(module_intf_concat2_a0_rready),
.a1_awaddr(custom_intf_concat_a1_awaddr),
.a1_awvalid(module_intf_concat2_a1_awvalid),
.a1_awready(module_intf_concat2_a1_awready),
.a1_wdata(module_intf_concat2_a1_wdata),
.a1_wstrb(module_intf_concat2_a1_wstrb),
.a1_wvalid(module_intf_concat2_a1_wvalid),
.a1_wready(module_intf_concat2_a1_wready),
.a1_bresp(module_intf_concat2_a1_bresp),
.a1_bvalid(module_intf_concat2_a1_bvalid),
.a1_bready(module_intf_concat2_a1_bready),
.a1_araddr(custom_intf_concat_a1_araddr),
.a1_arvalid(module_intf_concat2_a1_arvalid),
.a1_arready(module_intf_concat2_a1_arready),
.a1_rdata(module_intf_concat2_a1_rdata),
.a1_rresp(module_intf_concat2_a1_rresp),
.a1_rvalid(module_intf_concat2_a1_rvalid),
.a1_rready(module_intf_concat2_a1_rready)
);


picorv32_axi
#(
.ENABLE_COUNTERS(PARAMETER_CPU_ENABLE_COUNTERS),
.ENABLE_COUNTERS64(PARAMETER_CPU_ENABLE_COUNTERS64),
.ENABLE_REGS_16_31(PARAMETER_CPU_ENABLE_REGS_16_31),
.ENABLE_REGS_DUALPORT(PARAMETER_CPU_ENABLE_REGS_DUALPORT),
.TWO_STAGE_SHIFT(PARAMETER_CPU_TWO_STAGE_SHIFT),
.BARREL_SHIFTER(PARAMETER_CPU_BARREL_SHIFTER),
.TWO_CYCLE_COMPARE(PARAMETER_CPU_TWO_CYCLE_COMPARE),
.TWO_CYCLE_ALU(PARAMETER_CPU_TWO_CYCLE_ALU),
.COMPRESSED_ISA(PARAMETER_CPU_COMPRESSED_ISA),
.CATCH_MISALIGN(PARAMETER_CPU_CATCH_MISALIGN),
.CATCH_ILLINSN(PARAMETER_CPU_CATCH_ILLINSN),
.ENABLE_PCPI(PARAMETER_CPU_ENABLE_PCPI),
.ENABLE_MUL(PARAMETER_CPU_ENABLE_MUL),
.ENABLE_FAST_MUL(PARAMETER_CPU_ENABLE_FAST_MUL),
.ENABLE_DIV(PARAMETER_CPU_ENABLE_DIV),
.ENABLE_IRQ_QREGS(PARAMETER_CPU_ENABLE_IRQ_QREGS),
.ENABLE_IRQ_TIMER(PARAMETER_CPU_ENABLE_IRQ_TIMER),
.ENABLE_TRACE(PARAMETER_CPU_ENABLE_TRACE),
.REGS_INIT_ZERO(PARAMETER_CPU_REGS_INIT_ZERO),
.MASKED_IRQ(PARAMETER_CPU_MASKED_IRQ),
.ADDR_WIDTH(PARAMETER_CPU_ADDR_WIDTH),
.DATA_WIDTH(PARAMETER_CPU_DATA_WIDTH),
.STACKADDR(PARAMETER_CPU_STACKADDR),
.LATCHED_IRQ(PARAMETER_CPU_LATCHED_IRQ),
.PROGADDR_RESET(PARAMETER_CPU_PROGADDR_RESET),
.PROGADDR_IRQ(PARAMETER_CPU_PROGADDR_IRQ),
.ENABLE_IRQ(PARAMETER_CPU_ENABLE_IRQ)
)
cpu
(
.clk(module_cpu_clk),
.resetn(module_cpu_resetn),
.mem_axi_araddr(module_cpu_mem_axi_araddr),
.mem_axi_arvalid(module_cpu_mem_axi_arvalid),
.mem_axi_arready(module_cpu_mem_axi_arready),
.mem_axi_awaddr(module_cpu_mem_axi_awaddr),
.mem_axi_awvalid(module_cpu_mem_axi_awvalid),
.mem_axi_awready(module_cpu_mem_axi_awready),
.mem_axi_rdata(module_cpu_mem_axi_rdata),
.mem_axi_rvalid(module_cpu_mem_axi_rvalid),
.mem_axi_rready(module_cpu_mem_axi_rready),
.mem_axi_wdata(module_cpu_mem_axi_wdata),
.mem_axi_wstrb(module_cpu_mem_axi_wstrb),
.mem_axi_wvalid(module_cpu_mem_axi_wvalid),
.mem_axi_wready(module_cpu_mem_axi_wready),
.mem_b_ready(module_cpu_mem_b_ready),
.mem_b_response(module_cpu_mem_b_response),
.mem_b_valid(module_cpu_mem_b_valid),
.pcpi_valid(module_cpu_pcpi_valid),
.pcpi_insn(module_cpu_pcpi_insn),
.pcpi_rs1(module_cpu_pcpi_rs1),
.pcpi_rs2(module_cpu_pcpi_rs2),
.pcpi_wr(module_cpu_pcpi_wr),
.pcpi_rd(module_cpu_pcpi_rd),
.pcpi_wait(module_cpu_pcpi_wait),
.pcpi_ready(module_cpu_pcpi_ready),
.irq(module_cpu_irq),
.eoi(module_cpu_eoi)
);


endmodule
