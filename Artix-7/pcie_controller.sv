// =============================================================================
//
// Author      : Sahan Bandara
// Filename    : pcie_controller.sv
// Description : Controller for PCIe interface.
//               Implements the VirtIO interface on host side and multiple user
//               side interfaces.
//               Implements;
//               - virtio common, notification, ISR and PCI configuration access 
//                 structures.
//               - Virtqueue controllers and arbitration logic to share access 
//                 to the DMA engine
// 
// =============================================================================


module pcie_controller #(
  parameter NUM_QUEUES = 2,
  parameter SLEEP_TIMER_VAL = 1000
) (
  input clk,
  input reset,
  
  // AXI Lite Master Interface connections
  input  logic  [31:0] s_axil_awaddr,
  input  logic         s_axil_awvalid,
  output logic         s_axil_awready,
  input  logic  [31:0] s_axil_wdata,
  input  logic   [3:0] s_axil_wstrb,
  input  logic         s_axil_wvalid,
  output logic         s_axil_wready,
  output logic   [1:0] s_axil_bresp,
  output logic         s_axil_bvalid,
  input  logic         s_axil_bready,
  input  logic  [31:0] s_axil_araddr,
  input  logic         s_axil_arvalid,
  output logic         s_axil_arready,
  output logic  [31:0] s_axil_rdata,
  output logic   [1:0] s_axil_rresp,
  output logic         s_axil_rvalid,
  input  logic         s_axil_rready,

  // Descriptor bypass interface
  input  logic        c2h_dsc_byp_ready_0,
  output logic [63:0] c2h_dsc_byp_src_addr_0,
  output logic [63:0] c2h_dsc_byp_dst_addr_0,
  output logic [27:0] c2h_dsc_byp_len_0,
  output logic [15:0] c2h_dsc_byp_ctl_0,
  output logic        c2h_dsc_byp_load_0,
  
  input  logic        h2c_dsc_byp_ready_0,
  output logic [63:0] h2c_dsc_byp_src_addr_0,
  output logic [63:0] h2c_dsc_byp_dst_addr_0,
  output logic [27:0] h2c_dsc_byp_len_0,
  output logic [15:0] h2c_dsc_byp_ctl_0,
  output logic        h2c_dsc_byp_load_0,

  // AXI-Lite Interface (DMA engine configuration)
  output logic [31:0] dma_engine_config_axil_awaddr,
  output logic        dma_engine_config_axil_awvalid,
  input  logic        dma_engine_config_axil_awready,
  output logic [31:0] dma_engine_config_axil_wdata,
  output logic [3 :0] dma_engine_config_axil_wstrb,
  output logic        dma_engine_config_axil_wvalid,
  input  logic        dma_engine_config_axil_wready,
  input  logic        dma_engine_config_axil_bvalid,
  input  logic [1 :0] dma_engine_config_axil_bresp,
  output logic        dma_engine_config_axil_bready,
  output logic [31:0] dma_engine_config_axil_araddr,
  output logic        dma_engine_config_axil_arvalid,
  input  logic        dma_engine_config_axil_arready,
  input  logic [31:0] dma_engine_config_axil_rdata,
  input  logic [1 :0] dma_engine_config_axil_rresp,
  input  logic        dma_engine_config_axil_rvalid,
  output logic        dma_engine_config_axil_rready,

  // AXI-MM Interface (Data to/from DMA engine)
  output logic         endpoint_ctrl,
  input  logic [63 :0] s_axi_awaddr,
  input  logic [7  :0] s_axi_awlen,
  input  logic [2  :0] s_axi_awsize,
  input  logic [1  :0] s_axi_awburst,
  input  logic         s_axi_awvalid,
  output logic         s_axi_awready,
  input  logic [127:0] s_axi_wdata,
  input  logic [15 :0] s_axi_wstrb,
  input  logic         s_axi_wlast,
  input  logic         s_axi_wvalid,
  output logic         s_axi_wready,
  output logic [1  :0] s_axi_bresp,
  output logic         s_axi_bvalid,
  input  logic         s_axi_bready,
  input  logic [63 :0] s_axi_araddr,
  input  logic [7  :0] s_axi_arlen,
  input  logic [2  :0] s_axi_arsize,
  input  logic [1  :0] s_axi_arburst,
  input  logic         s_axi_arvalid,
  output logic         s_axi_arready,
  output logic [127:0] s_axi_rdata,
  output logic [1  :0] s_axi_rresp,
  output logic         s_axi_rlast,
  output logic         s_axi_rvalid,
  input  logic         s_axi_rready,
  input  logic         s_axi_wvalid_to_mem, // To verify that the memory is receiving data
  input  logic         s_axi_wready_from_mem,
  input  logic [15:0]  s_axi_wstrb_to_mem,
  input  logic         s_axi_bvalid_from_mem, // To verify the write response from memory
  input  logic         s_axi_bready_to_mem,
  input  logic         s_axi_rvalid_from_mem, // To verify the read response from memory
  input  logic         s_axi_rready_to_mem,

  // AXI Lite interface to write directly to memory.
  // Each controller is given its own interface including own interurpt line to facilitate future optimizations.
  // - Currently, the controller does not release the DMA engine even when it has to go into a wait state.
  // - Wait state and most of the descriptor table book keeping can be done without holding the DMA engine.
  // - Future iterations will implement support for one controller to release the DMA engine when going to a 
  //   sleep state or while doing book keeping tasks and another controller to use the DMA engine.
  output logic [NUM_QUEUES-1:0][31:0] m_axil_awaddr,
  output logic [NUM_QUEUES-1:0]       m_axil_awvalid,
  input  logic [NUM_QUEUES-1:0]       m_axil_awready,
  output logic [NUM_QUEUES-1:0][31:0] m_axil_wdata,
  output logic [NUM_QUEUES-1:0][3 :0] m_axil_wstrb,
  output logic [NUM_QUEUES-1:0]       m_axil_wvalid,
  input  logic [NUM_QUEUES-1:0]       m_axil_wready,
  input  logic [NUM_QUEUES-1:0][1 :0] m_axil_bresp,
  input  logic [NUM_QUEUES-1:0]       m_axil_bvalid,
  output logic [NUM_QUEUES-1:0]       m_axil_bready,
  output logic [NUM_QUEUES-1:0][31:0] m_axil_araddr,
  output logic [NUM_QUEUES-1:0]       m_axil_arvalid,
  input  logic [NUM_QUEUES-1:0]       m_axil_arready,
  input  logic [NUM_QUEUES-1:0][31:0] m_axil_rdata,
  input  logic [NUM_QUEUES-1:0][1 :0] m_axil_rresp,
  input  logic [NUM_QUEUES-1:0]       m_axil_rvalid,
  output logic [NUM_QUEUES-1:0]       m_axil_rready,

  output logic [NUM_QUEUES-1:0]       interrupt_usr,
  input  logic [NUM_QUEUES-1:0]       interrupt_usr_ack,

  // DMA Status
  input  logic [7 :0] c2h_sts_0,
  input  logic [7 :0] h2c_sts_0,

  // User side configuration interface (AXI)
  input  logic  [NUM_QUEUES-1:0][31:0] cfg_intf_axil_awaddr,
  input  logic  [NUM_QUEUES-1:0]       cfg_intf_axil_awvalid,
  output logic  [NUM_QUEUES-1:0]       cfg_intf_axil_awready,
  input  logic  [NUM_QUEUES-1:0][31:0] cfg_intf_axil_wdata,
  input  logic  [NUM_QUEUES-1:0][3 :0] cfg_intf_axil_wstrb,
  input  logic  [NUM_QUEUES-1:0]       cfg_intf_axil_wvalid,
  output logic  [NUM_QUEUES-1:0]       cfg_intf_axil_wready,
  output logic  [NUM_QUEUES-1:0][1 :0] cfg_intf_axil_bresp,
  output logic  [NUM_QUEUES-1:0]       cfg_intf_axil_bvalid,
  input  logic  [NUM_QUEUES-1:0]       cfg_intf_axil_bready,
  input  logic  [NUM_QUEUES-1:0][31:0] cfg_intf_axil_araddr,
  input  logic  [NUM_QUEUES-1:0]       cfg_intf_axil_arvalid,
  output logic  [NUM_QUEUES-1:0]       cfg_intf_axil_arready,
  output logic  [NUM_QUEUES-1:0][31:0] cfg_intf_axil_rdata,
  output logic  [NUM_QUEUES-1:0][1 :0] cfg_intf_axil_rresp,
  output logic  [NUM_QUEUES-1:0]       cfg_intf_axil_rvalid,
  input  logic  [NUM_QUEUES-1:0]       cfg_intf_axil_rready,

  // User interrupts
  //FIXME: Number of interrupts hard coded to 4. Should be parameterized.
  // Should be less than the max number of interrupts supported by the given IP.
  output logic [3 :0] usr_irq_req,
  input  logic [3: 0] usr_irq_ack
);

import defines_pkg::*;


// Device feature bits.
// Reserved feaature bits.
localparam bit [31:0] VIRTIO_F_RING_INDIRECT_DESC  = 32'd1 << (28 % 32); // word 0
localparam bit [31:0] VIRTIO_F_RING_EVENT_IDX      = 32'd1 << (29 % 32); // word 0
localparam bit [31:0] VIRTIO_F_VERSION_1           = 32'd1 << (32 % 32); // word 1
localparam bit [31:0] VIRTIO_F_ACCESS_PLATFORM     = 32'd1 << (33 % 32); // word 1
localparam bit [31:0] VIRTIO_F_RING_PACKED         = 32'd1 << (34 % 32); // word 1
localparam bit [31:0] VIRTIO_F_IN_ORDER            = 32'd1 << (35 % 32); // word 1
localparam bit [31:0] VIRTIO_F_ORDER_PLATFORM      = 32'd1 << (36 % 32); // word 1
localparam bit [31:0] VIRTIO_F_SR_IOV              = 32'd1 << (37 % 32); // word 1
localparam bit [31:0] VIRTIO_F_NOTIFICATION_DATA   = 32'd1 << (38 % 32); // word 1

// Legacy interface reserved feature bits
localparam bit [31:0] VIRTIO_F_NOTIFY_ON_EMPTY     = 32'd1 << (24 % 32); // word 0
localparam bit [31:0] VIRTIO_F_ANY_LAYOUT          = 32'd1 << (27 % 32); // word 0
localparam bit [31:0] UNUSED                       = 32'd1 << (30 % 32); // word 0

// Console device feature bits
localparam bit [31:0] VIRTIO_CONSOLE_F_SIZE        = 32'd1 << (0  % 32); // word 0
localparam bit [31:0] VIRTIO_CONSOLE_F_MULTIPORT   = 32'd1 << (1  % 32); // word 0
localparam bit [31:0] VIRTIO_CONSOLE_F_EMERG_WRITE = 32'd1 << (2  % 32); // word 0

// Network device feature bits
localparam bit [31:0] VIRTIO_NET_F_CSUM                = 32'd1 << (0  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_GUEST_CSUM          = 32'd1 << (1  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_CTRL_GUEST_OFFLOADS = 32'd1 << (2  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_MTU                 = 32'd1 << (3  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_MAC                 = 32'd1 << (5  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_GUEST_TSO4          = 32'd1 << (7  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_GUEST_TSO6          = 32'd1 << (8  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_GUEST_ECN           = 32'd1 << (9  % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_GUEST_UFO           = 32'd1 << (10 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_HOST_TSO4           = 32'd1 << (11 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_HOST_TSO6           = 32'd1 << (12 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_HOST_ECN            = 32'd1 << (13 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_HOST_UFO            = 32'd1 << (14 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_MRG_RXBUF           = 32'd1 << (15 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_STATUS              = 32'd1 << (16 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_CTRL_VQ             = 32'd1 << (17 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_CTRL_RX             = 32'd1 << (18 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_CTRL_VLAN           = 32'd1 << (19 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_GUEST_ANNOUNCE      = 32'd1 << (21 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_MQ                  = 32'd1 << (22 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_CTRL_MAC_ADDR       = 32'd1 << (23 % 32); // word 0
localparam bit [31:0] VIRTIO_NET_F_RSC_EXT             = 32'd1 << (61 % 32); // word 1
localparam bit [31:0] VIRTIO_NET_F_STANDBY             = 32'd1 << (62 % 32); // word 1

localparam QUEUE_SIZE     = 32;
localparam QUEUE_IDX_BITS = $clog2(QUEUE_SIZE);
localparam QUEUE_SEL_BITS = $clog2(NUM_QUEUES);

localparam RX = 1'b0;
localparam TX = 1'b1;

localparam USER  = 1'b0;
localparam TIMER = 1'b1;

localparam SLEEP_TIMER_BITS = $clog2(SLEEP_TIMER_VAL);

/* union common_config is mostly used for reads. 
Actual registers for duplicated writable fields are implemented separately. */
union packed{
  common_config_t common_config_struct;
  dword_t [13:0] common_config_dwords;
} common_config;

// Duplicated configuration registers for individual queues (part of common config. structure)
queue_data_t [NUM_QUEUES-1:0] queue_data;


// Duplicated registers for fields of common configuration structure.
// Device feature
/* 
Only 2 32-bit registers are required device and driver feature fields because 
no feature bits higher than bit 38 are defined in the current virtIO spec.   
 */
dword_t [1:0] comm_cfg_device_feature_regs;

// Driver feature
dword_t [1:0] comm_cfg_driver_feature_regs;

//FIXME
/* 
Only 2 queues are supported currently. Therefore, only the LSB of queue select
field needs to be taken into account to select from queue_data.
*/


// Device-specific configuration
virtio_net_config_t net_config;


// Address decoding
logic comm_cfg_w_access, comm_cfg_r_access;
logic notif_w_access, notif_r_access;
logic isr_stat_w_access, isr_stat_r_access;
logic pci_cfg_w_access, pci_cfg_r_access;
logic dev_cfg_w_access, dev_cfg_r_access;

assign comm_cfg_r_access = s_axil_araddr[11:8] == 4'h0;
assign comm_cfg_w_access = s_axil_awaddr[11:8] == 4'h0;
assign notif_r_access    = s_axil_araddr[11:8] == 4'h1;
assign notif_w_access    = s_axil_awaddr[11:8] == 4'h1;
assign isr_stat_r_access = s_axil_araddr[11:8] == 4'h2;
assign isr_stat_w_access = s_axil_awaddr[11:8] == 4'h2;
assign dev_cfg_r_access  = s_axil_araddr[11:8] == 4'h3;
assign dev_cfg_w_access  = s_axil_awaddr[11:8] == 4'h3;
assign pci_cfg_r_access  = s_axil_araddr[11:8] == 4'h4;
assign pci_cfg_w_access  = s_axil_awaddr[11:8] == 4'h4;

// Access completed signal for each structure
logic comm_cfg_wr_compl;
logic notify_wr_compl  = 1'b1; // TODO: temporarily tied to one
logic isr_wr_compl     = 1'b1; // TODO: temporarily tied to one
logic pci_cfg_wr_compl = 1'b1; // TODO: temporarily tied to one

logic [3:0] write_compl;// = {pci_cfg_wr_compl, isr_wr_compl, notify_wr_compl, comm_cfg_wr_compl};


// ISR structure
word_t isr_field;

// DMA engine configuration
logic [NUM_QUEUES-1:0] irq_configured;


// Global counter accessible by all queue controllers
// User clock is running at 125 MHz. A 32-bit counter will wrap around in ~34 seconds.
(* mark_debug = "true" *) logic [31:0] global_clock;

always_ff @(posedge clk)begin
  if(reset)
    global_clock <= 32'd0;
  else
    global_clock <= global_clock + 32'd1;
end


// AXI-lite write interface
/*
- All write requests with the current IP interface are 32-bit writes.
- Therefore, can be completed in a cycle.
- For write requests, the AXI write interface state mechine will lower the ready
  signal and wait for (s_axil_bvalid & s_axil_bready) to be true.
- Indvidual state machines for different control structures will complete the 
  write if the field is writable.
*/

typedef enum logic [1:0] {
  IDLE,
  ADDR_RECEIVED,
  DATA_RECEIVED,
  ACTIVE_WRITE
} axi_write_state_t;

axi_write_state_t write_state;
axi_write_state_t nxt_write_state;
logic [3 :0] write_sel;
logic [3 :0] nxt_write_sel;
logic [31:0] write_addr, nxt_write_addr;
dword_t      write_data, nxt_write_data;
logic [3 :0] write_strb, nxt_write_strb;
logic        nxt_axil_awready;
logic        nxt_axil_wready;

// Address and data interface
always_ff @(posedge clk)begin
  if(reset)begin
    write_sel      <= 4'b0000;
    write_addr     <= 32'd0;
    write_data     <= 32'd0;
    write_strb     <= 4'b0000;
    s_axil_awready <= 1'b1;
    s_axil_wready  <= 1'b1;
    write_state    <= IDLE;
  end
  else begin
    write_sel      <= nxt_write_sel;
    write_addr     <= nxt_write_addr;
    write_data     <= nxt_write_data;
    write_strb     <= nxt_write_strb;
    s_axil_awready <= nxt_axil_awready;
    s_axil_wready  <= nxt_axil_wready;
    write_state    <= nxt_write_state;
  end
end

always_comb begin
  nxt_write_sel    = write_sel;
  nxt_write_addr   = write_addr;
  nxt_write_data   = write_data;
  nxt_write_strb   = write_strb;
  nxt_axil_awready = s_axil_awready;
  nxt_axil_wready  = s_axil_wready;
  nxt_write_state  = write_state;
  case(write_state)
    IDLE:begin
      nxt_write_sel    = {pci_cfg_w_access, isr_stat_w_access, notif_w_access, comm_cfg_w_access};
      nxt_write_addr   = s_axil_awaddr;
      nxt_write_data   = s_axil_wdata;
      nxt_write_strb   = s_axil_wstrb;
      if(s_axil_awvalid & s_axil_awready & s_axil_wvalid & s_axil_wready)begin // both address and data available
        nxt_axil_awready = 1'b0;
        nxt_axil_wready  = 1'b0;
        nxt_write_state  = ACTIVE_WRITE;
      end
      else if(s_axil_awvalid & s_axil_awready)begin
        nxt_axil_awready = 1'b0;
        nxt_write_state  = ADDR_RECEIVED;
      end
      else if(s_axil_wvalid & s_axil_wready)begin
        nxt_axil_wready = 1'b0;
        nxt_write_state = DATA_RECEIVED;
      end
    end
    ADDR_RECEIVED:begin
      if(s_axil_wvalid & s_axil_wready)begin
        nxt_axil_wready = 1'b0;
        nxt_write_data  = s_axil_wdata;
        nxt_write_strb  = s_axil_wstrb;
        nxt_write_state = ACTIVE_WRITE;
      end
    end
    DATA_RECEIVED:begin
      if(s_axil_awvalid & s_axil_awready)begin
        nxt_axil_awready = 1'b0;
        nxt_write_addr   = s_axil_awaddr;
        nxt_write_sel    = {pci_cfg_w_access, isr_stat_w_access, notif_w_access, comm_cfg_w_access};
        nxt_write_state  = ACTIVE_WRITE;
      end
    end
    ACTIVE_WRITE:begin
      if(|(write_sel & write_compl))begin
        nxt_axil_awready = 1'b1;
        nxt_axil_wready  = 1'b1;
        nxt_write_sel    = 4'b0000;
        nxt_write_state  = IDLE;
      end
    end
    default:begin
      nxt_write_sel    = 4'b0000;
      nxt_write_addr   = 32'd0;
      nxt_write_data   = 32'd0;
      nxt_write_strb   = 4'b0000;
      nxt_axil_awready = 1'b1;
      nxt_axil_wready  = 1'b1;
      nxt_write_state  = IDLE;
    end
  endcase
end

// Write response interface
typedef enum logic {
  IDLE_BRESP,
  RESP
} write_resp_state_t;

write_resp_state_t wresp_state, nxt_wresp_state;
logic [1:0] nxt_axil_bresp;
logic       nxt_axil_bvalid;

always_ff @(posedge clk)begin
  if(reset)begin
    s_axil_bresp  <= 2'b00;
    s_axil_bvalid <= 1'b0;
    wresp_state   <= IDLE_BRESP;
  end
  else begin
    s_axil_bresp  <= nxt_axil_bresp;
    s_axil_bvalid <= nxt_axil_bvalid;
    wresp_state   <= nxt_wresp_state;
  end
end

always_comb begin
  nxt_axil_bresp  = s_axil_bresp;
  nxt_axil_bvalid = s_axil_bvalid;
  nxt_wresp_state = wresp_state;
  case(wresp_state)
    IDLE:begin
      if(write_state == ACTIVE_WRITE & |(write_sel & write_compl))begin // Write access complete
        nxt_axil_bvalid = 1'b1;
        nxt_wresp_state = RESP;
      end
    end
    RESP:begin
      if(s_axil_bvalid & s_axil_bready)begin
        nxt_axil_bvalid = 1'b0;
        nxt_wresp_state = IDLE_BRESP;
      end
    end
  endcase
end


// AXI-lite read interface
/*
The read interface can directly access the virtIO structures and respond to the requests
*/
typedef enum logic [1:0]{
  IDLE_READ,
  READ,
  WAIT
} axi_read_state_t;

axi_read_state_t read_state, nxt_read_state;
logic [31:0] nxt_axil_rdata;
logic        nxt_axil_rvalid;
logic        nxt_axil_arready;
logic [1 :0] nxt_axil_rresp;
logic [31:0] read_addr, nxt_read_addr;
logic [4 :0] read_sel, nxt_read_sel;


always_ff @(posedge clk)begin
  if(reset)begin
    s_axil_arready <= 1'b1;
    s_axil_rdata   <= 32'd0;
    s_axil_rvalid  <= 1'b0;
    s_axil_rresp   <= 2'b00;
    read_addr      <= 32'd0;
    read_sel       <= 5'b00000;
    read_state     <= IDLE_READ;
  end
  else begin
    s_axil_arready <= nxt_axil_arready;
    s_axil_rdata   <= nxt_axil_rdata;
    s_axil_rvalid  <= nxt_axil_rvalid;
    s_axil_rresp   <= nxt_axil_rresp;
    read_addr      <= nxt_read_addr;
    read_sel       <= nxt_read_sel;
    read_state     <= nxt_read_state;
  end
end

always_comb begin
  nxt_axil_arready = s_axil_arready;
  nxt_axil_rdata   = s_axil_rdata;
  nxt_axil_rvalid  = s_axil_rvalid;
  nxt_axil_rresp   = s_axil_rresp;
  nxt_read_addr    = read_addr;
  nxt_read_sel     = read_sel;
  nxt_read_state   = read_state;
  case(read_state)
    IDLE_READ:begin
      if(s_axil_arvalid & s_axil_arready)begin
        nxt_axil_arready = 1'b0;
        nxt_read_addr    = s_axil_araddr;
        nxt_read_sel     = {pci_cfg_r_access, dev_cfg_r_access, isr_stat_r_access, notif_r_access, comm_cfg_r_access};
        nxt_read_state   = READ;
      end
    end
    READ:begin
      nxt_axil_rvalid = 1'b1;
      nxt_axil_rresp  = 2'b00;
      nxt_read_state  = WAIT;
      case(read_sel)
        5'b00001: nxt_axil_rdata = common_config.common_config_dwords[read_addr[5:2]];
        5'b00010: nxt_axil_rdata = 32'd0;
        5'b00100: nxt_axil_rdata = isr_field;
        5'b01000: nxt_axil_rdata = net_config.net_config_dwords[read_addr[3:2]]; // network device config space is 3 dwords
        5'b10000: nxt_axil_rdata = 32'd0;
        default: nxt_axil_rdata = 32'd0;
      endcase
    end
    WAIT:begin
      if(s_axil_rvalid & s_axil_rready)begin
        nxt_read_sel     = 5'b00000;
        nxt_axil_rvalid  = 1'b0;
        nxt_axil_arready = 1'b1;
        nxt_read_state   = IDLE_READ;
      end
    end
    default:begin
      nxt_axil_arready = 1'b1;
      nxt_axil_rdata   = 32'd0;
      nxt_axil_rvalid  = 1'b0;
      nxt_axil_rresp   = 2'b00;
      nxt_read_addr    = 32'd0;
      nxt_read_sel     = 5'b00000;
      nxt_read_state   = IDLE_READ;
    end
  endcase
end



// State machine for common config structure write accesses
/*
Only two states are necessary since single cycle writes are possible.
If the CSRs are later implemented as BRAMs, add new states to the state machine.
*/
typedef enum logic{
  IDLE_VIRTIO_W,
  WAIT_VIRTIO_W
} config_write_state_t;

config_write_state_t cc_wr_state;
logic [3:0] comm_cfg_wr_dword_addr;// = write_addr[5:2];
logic [3:0] queue_data_wr_addr;// = comm_cfg_wr_dword_addr - 4'd6;

always_ff @(posedge clk)begin
  if(reset)begin
    comm_cfg_wr_compl <= 1'b0;
    cc_wr_state       <= IDLE_VIRTIO_W;
    // inititlize common config. structure
    common_config.common_config_struct.device_feature_select <= 32'd0;
    common_config.common_config_struct.device_feature        <= 32'd0;
    comm_cfg_device_feature_regs[0]                          <= (VIRTIO_NET_F_GUEST_CSUM);
    comm_cfg_device_feature_regs[1]                          <= (VIRTIO_F_VERSION_1 | VIRTIO_F_ACCESS_PLATFORM | VIRTIO_F_IN_ORDER | VIRTIO_F_ORDER_PLATFORM | VIRTIO_F_NOTIFICATION_DATA);
    common_config.common_config_struct.driver_feature_select <= 32'd0;
    common_config.common_config_struct.driver_feature        <= 32'd0;
    for(int i=0; i<2; i++)begin
      comm_cfg_driver_feature_regs[i] <= 32'd0;
    end
    common_config.common_config_struct.msix_config       <= 16'd0;
    common_config.common_config_struct.num_queues        <= 16'd2;
    common_config.common_config_struct.device_status     <= 8'd0;
    common_config.common_config_struct.config_generation <= 8'd0;
    /* About a specific virtqueue */
    common_config.common_config_struct.queue_select      <= 16'd0;
    common_config.common_config_struct.queue_size        <= QUEUE_SIZE;
    common_config.common_config_struct.queue_msix_vector <= 16'd0;
    common_config.common_config_struct.queue_enable      <= 16'd0;
    common_config.common_config_struct.queue_notify_off  <= 16'd0;
    common_config.common_config_struct.queue_desc        <= 64'd0;
    common_config.common_config_struct.queue_driver      <= 64'd0;
    common_config.common_config_struct.queue_device      <= 64'd0;

    for(int i=0; i<NUM_QUEUES; i++)begin
      queue_data[i].queue_struct.queue_size        <= QUEUE_SIZE;
      queue_data[i].queue_struct.queue_msix_vector <= 16'd0;
      queue_data[i].queue_struct.queue_enable      <= 16'd0;
      queue_data[i].queue_struct.queue_notify_off  <= 16'h10 * i;
      queue_data[i].queue_struct.queue_desc        <= 64'd0;
      queue_data[i].queue_struct.queue_driver      <= 64'd0;
      queue_data[i].queue_struct.queue_device      <= 64'd0;
    end
  end
  else begin
    case(cc_wr_state)
      IDLE_VIRTIO_W:begin
        if(write_sel == 4'b0001 & write_state == ACTIVE_WRITE)begin // Write request pending to be completed
          comm_cfg_wr_compl <= 1'b1;
          cc_wr_state       <= WAIT_VIRTIO_W;
          case(comm_cfg_wr_dword_addr)
            4'd0: begin  // Device feature select
              for(int i=0; i<4; i++)begin
                if(write_strb[i])
                  common_config.common_config_struct.device_feature_select.dword_bytes[i] <= write_data.dword_bytes[i];
              end
              // Update device_feature field to match the device_feature_select.
              /* Only bit 0 needs to be checked */
              if(write_strb[0])begin // New value might be written to bit 0 of device_feature_select
                common_config.common_config_struct.device_feature <= comm_cfg_device_feature_regs[write_data.dword_bits[0]];
              end
            end
            4'd2:begin  // Driver feature select
              for(int i=0; i<4; i++)begin
                if(write_strb[i])
                  common_config.common_config_struct.driver_feature_select.dword_bytes[i] <= write_data.dword_bytes[i];
              end
              // Update the driver feature field to match driver_feature_select
              if(write_strb[0])begin // New value might be written to bit 0 of driver_feature_select
                common_config.common_config_struct.driver_feature <= comm_cfg_driver_feature_regs[write_data.dword_bits[0]];
              end
            end
            4'd3:begin  // Driver feature
              /* Write both comm. cfg. structure field and duplicate register. */
              /* Only write valid bits after checking against device feature bits. */
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.driver_feature.dword_bytes[i]                                     <= write_data.dword_bytes[i] & 
                                 comm_cfg_device_feature_regs[common_config.common_config_struct.driver_feature_select.dword_bits[0]].dword_bytes[i];
                  comm_cfg_driver_feature_regs[common_config.common_config_struct.driver_feature_select.dword_bits[0]] <= write_data.dword_bytes[i] & 
                                 comm_cfg_device_feature_regs[common_config.common_config_struct.driver_feature_select.dword_bits[0]].dword_bytes[i];
                end
              end
            end
            4'd4:begin  // ||| num_queues (RO) || msix_config (RW) |||
              for(int i=0; i<2; i++)begin
                if(write_strb[i])
                  common_config.common_config_struct.msix_config.word_bytes[i] <= write_data.dword_bytes[i];
              end
            end
            4'd5:begin  // ||| queue_select (RW) || config_generation (RO) | device_status (RW) |||
              // device status
              if(write_strb[0])
                common_config.common_config_struct.device_status <= write_data.dword_bytes[0];

              // queue_select
              for(int i=0; i<2; i++)begin
                if(write_strb[i+2])
                  common_config.common_config_struct.queue_select.word_bytes[i] <= write_data.dword_bytes[i+2];
              end
              // Updateing other queue_* fields to match queue_select
              /* Only the LSB of the queue_select field is checked because only 2 queues are supported at this time. */
              // FIXME: when using more than 2 queues
              if(write_strb[2])begin
                common_config.common_config_struct.queue_size        <= queue_data[write_data.dword_bits[16]].queue_struct.queue_size;
                common_config.common_config_struct.queue_msix_vector <= queue_data[write_data.dword_bits[16]].queue_struct.queue_msix_vector;
                common_config.common_config_struct.queue_enable      <= queue_data[write_data.dword_bits[16]].queue_struct.queue_enable;
                common_config.common_config_struct.queue_notify_off  <= queue_data[write_data.dword_bits[16]].queue_struct.queue_notify_off;
                common_config.common_config_struct.queue_desc        <= queue_data[write_data.dword_bits[16]].queue_struct.queue_desc;
                common_config.common_config_struct.queue_driver      <= queue_data[write_data.dword_bits[16]].queue_struct.queue_driver;
                common_config.common_config_struct.queue_device      <= queue_data[write_data.dword_bits[16]].queue_struct.queue_device;
              end
            end
            4'd6:begin  // ||| queue_msix_vector || queue_size ||| // TODO: check for max queue size?
              for(int i=0; i<2; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_size.word_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_size.word_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_size.word_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                    default:begin
                      queue_data[0].queue_struct.queue_size.word_bytes[i] <= queue_data[0].queue_struct.queue_size.word_bytes[i];
                      queue_data[1].queue_struct.queue_size.word_bytes[i] <= queue_data[1].queue_struct.queue_size.word_bytes[i];
                    end
                  endcase
                end
              end
              for(int i=0; i<2; i++)begin
                if(write_strb[i+2])begin
                  common_config.common_config_struct.queue_msix_vector.word_bytes[i]                                                    <= write_data.dword_bytes[i+2];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_msix_vector.word_bytes[i] <= write_data.dword_bytes[i+2];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_msix_vector.word_bytes[i] <= write_data.dword_bytes[i+2];
                    end
                    // FIXME: when using more than 2 queues
                    default:begin
                      queue_data[0].queue_struct.queue_msix_vector.word_bytes[i] <= queue_data[0].queue_struct.queue_msix_vector.word_bytes[i];
                      queue_data[1].queue_struct.queue_msix_vector.word_bytes[i] <= queue_data[1].queue_struct.queue_msix_vector.word_bytes[i];
                    end
                  endcase
                end
              end
            end
            4'd7:begin  // ||| queue_notify_off (RO)  || queue_enable (RW) |||
              for(int i=0; i<2; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_enable.word_bytes[i]                                                    <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_enable.word_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_enable.word_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                    default:begin
                      queue_data[0].queue_struct.queue_enable.word_bytes[i] <= queue_data[0].queue_struct.queue_enable.word_bytes[i];
                      queue_data[1].queue_struct.queue_enable.word_bytes[i] <= queue_data[1].queue_struct.queue_enable.word_bytes[i];
                    end
                  endcase
                end
              end
            end
            4'd8:begin // queue_desc (lower half)
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_desc.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_desc.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_desc.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                    default:begin
                      queue_data[0].queue_struct.queue_desc.qword_dwords[0].dword_bytes[i] <= queue_data[0].queue_struct.queue_desc.qword_dwords[0].dword_bytes[i];
                      queue_data[1].queue_struct.queue_desc.qword_dwords[0].dword_bytes[i] <= queue_data[1].queue_struct.queue_desc.qword_dwords[0].dword_bytes[i];
                    end
                  endcase
                end
              end
            end
            4'd9:begin // queue_desc (upper half)
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_desc.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_desc.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_desc.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                  endcase
                end
              end
            end
            4'd10:begin // queue_driver (lower half)
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_driver.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_driver.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_driver.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                  endcase
                end
              end
            end
            4'd11:begin // queue_driver (upper half)
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_driver.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_driver.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_driver.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                  endcase
                end
              end
            end
            4'd12:begin // queue_device (lower half)
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_device.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_device.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_device.qword_dwords[0].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                  endcase
                end
              end
            end
            4'd13:begin // queue_device (upper half)
              for(int i=0; i<4; i++)begin
                if(write_strb[i])begin
                  common_config.common_config_struct.queue_device.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                  case(common_config.common_config_struct.queue_select.word_bits)
                    16'd0:begin
                      queue_data[0].queue_struct.queue_device.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    16'd1:begin
                      queue_data[1].queue_struct.queue_device.qword_dwords[1].dword_bytes[i] <= write_data.dword_bytes[i];
                    end
                    // FIXME: when using more than 2 queues
                  endcase
                end
              end
            end
            default:begin
              /* For read-only fields, set the complete signal without writing anything to the structure.*/
            end
          endcase
        end
      end
      WAIT_VIRTIO_W:begin
        if(write_state == IDLE)begin
          comm_cfg_wr_compl <= 1'b0;
          cc_wr_state       <= IDLE_VIRTIO_W;
        end
      end
    endcase
  end
end


// State machine for ISR structure
always_ff @(posedge clk)begin
  if(reset)
    isr_field <= 32'd0;
  else begin
    if(read_state == WAIT & read_sel == 5'b00100 & s_axil_rvalid & s_axil_rready)begin
      isr_field <= 32'd0;
    end
  end
end


// Instantiate the arbiter
logic [NUM_QUEUES-1:0] q_requests;
logic [QUEUE_SEL_BITS-1:0] q_grant;
logic arb_valid;

arbiter #(
  .WIDTH(NUM_QUEUES),
  .ARB_TYPE("PACKET")
) arbiter_inst (
  .clock(clk),
  .reset(reset),
  .requests(q_requests),
  .grant(q_grant),
  .valid(arb_valid)
);


// Virtqueue control logic

dma_config_state_t q0_state;
dma_config_state_t q1_state;
logic [31:0] q0_q_buf_len;
logic [15:0] q0_q_buf_flags;
logic [31:0] q0_mm_tx_remaining_bytes;
logic [15:0] q0_q_avail_rng_idx;
logic [15:0] q0_q_avail_int_idx;

(* mark_debug = "true" *) pcie_cfg_space_struct_t q0_pcie_cfg_space;
(* mark_debug = "true" *) pcie_cfg_space_struct_t q1_pcie_cfg_space;


(* mark_debug = "true" *) logic [7:0] q0_tx_counter;
(* mark_debug = "true" *) logic [7:0] q1_rx_counter;
logic [31:0] q1_rx_buffer_head;
logic [31:0] q1_rx_buffer_tail;
logic        q1_head_ptr_wraparound;
logic [31:0] q1_head_ptr_wraparound_addr;

assign q0_state = queue_ctrl_loop[0].q_dma_config_state;
assign q1_state = queue_ctrl_loop[1].q_dma_config_state;

assign q0_q_buf_len  = queue_ctrl_loop[0].q_buf_len;
assign q0_q_buf_flags = queue_ctrl_loop[0].q_buf_flags;
assign q0_mm_tx_remaining_bytes = queue_ctrl_loop[0].pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits;

assign q0_tx_counter = queue_ctrl_loop[0].tx_counter;
assign q1_rx_counter = queue_ctrl_loop[1].rx_counter;

assign q0_q_avail_rng_idx    = queue_ctrl_loop[0].q_avail_rng_idx;
assign q0_q_avail_int_idx    = queue_ctrl_loop[0].q_avail_int_idx;


assign q1_rx_buffer_head           = queue_ctrl_loop[1].rx_buffer_head;
assign q1_rx_buffer_tail           = queue_ctrl_loop[1].rx_buffer_tail;
assign q1_head_ptr_wraparound      = queue_ctrl_loop[1].head_ptr_wraparound;
assign q1_head_ptr_wraparound_addr = queue_ctrl_loop[1].head_ptr_wraparound_addr;

assign q0_pcie_cfg_space = queue_ctrl_loop[0].pcie_cfg_space.pcie_cfg_space_struct;
assign q1_pcie_cfg_space = queue_ctrl_loop[1].pcie_cfg_space.pcie_cfg_space_struct;


genvar q;

generate
  for(q=0; q<NUM_QUEUES; q++)begin: queue_ctrl_loop
    /* Configuration Space Control */
    pcie_cfg_space_t pcie_cfg_space;

    logic        nxt_cfg_intf_axil_awready;
    logic        nxt_cfg_intf_axil_wready;
    logic  [1:0] nxt_cfg_intf_axil_bresp;
    logic        nxt_cfg_intf_axil_bvalid;
    logic        nxt_cfg_intf_axil_arready;
    logic [31:0] nxt_cfg_intf_axil_rdata;
    logic  [1:0] nxt_cfg_intf_axil_rresp;
    logic        nxt_cfg_intf_axil_rvalid;
    logic [31:0] rx_buff_end_addr, nxt_rx_buff_end_addr;

    // Write control
    cfg_space_write_state_t cfg_write_state, nxt_cfg_write_state; 
    dword_t nxt_num_buffers;
    dword_t nxt_timer_buf_clean_end;
    dword_t nxt_timer_buf_clean_start;
    dword_t nxt_timer_trx_end;
    dword_t nxt_timer_trx_start;
    dword_t nxt_virtq_notify_vector;
    dword_t nxt_virtq_notify_addr;
    dword_t nxt_virtq_notify_reg;
    dword_t nxt_virtq_device;
    dword_t nxt_virtq_driver;
    dword_t nxt_virtq_desc;
    dword_t nxt_virtq_size;
    dword_t nxt_activate_timers;
    dword_t nxt_timers_valid;
    dword_t nxt_mm_poll_wr_val;
    dword_t nxt_mm_poll_addr;
    dword_t nxt_mm_tx_size;
    dword_t nxt_mm_tx_dst_addr;
    dword_t nxt_mm_tx_src_addr;
    dword_t nxt_mm_rx_desc_table_size;
    dword_t nxt_mm_rx_desc_table_addr;
    dword_t nxt_mm_rx_buffer_size;
    dword_t nxt_mm_rx_buffer_addr;
    dword_t nxt_pcie_cmd_w1s;
    dword_t nxt_pcie_cmd_w1c;
    dword_t nxt_pcie_cmd;
    //dword_t nxt_pcie_status;
    dword_t cfg_intf_awaddr, nxt_cfg_intf_awaddr;
    dword_t cfg_intf_wdata, nxt_cfg_intf_wdata;
    //dword_t cfg_intf_araddr, nxt_cfg_intf_araddr;
    logic [31:0] cfg_intf_araddr, nxt_cfg_intf_araddr;

    logic [31:0] nxt_mm_tx_remaining_bytes;


    /* Queue Control variables */
    dma_config_state_t q_dma_config_state;
    dma_config_state_t nxt_q_dma_config_state;
    dma_config_state_t goto_state, nxt_goto_state;
    
    always_ff @(posedge clk)begin
      if(reset)begin
        pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_vector   <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_addr     <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_reg      <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_device          <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_driver          <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_desc            <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_size            <= QUEUE_SIZE;
        pcie_cfg_space.pcie_cfg_space_struct.activate_timers       <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_poll_wr_val        <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_poll_addr          <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size            <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_dst_addr        <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr        <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size     <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr     <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd_w1s          <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd_w1c          <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd              <= 32'd0;
        cfg_intf_axil_awready[q]                                   <= 1'b0;
        cfg_intf_axil_wready[q]                                    <= 1'b0;
        cfg_intf_axil_bresp[q]                                     <= 2'b00;
        cfg_intf_axil_bvalid[q]                                    <= 1'b0;
        cfg_intf_awaddr                                            <= 32'd0;
        cfg_intf_wdata                                             <= 32'd0;
        rx_buff_end_addr                                           <= 32'd0;
        cfg_write_state                                            <= CFG_WRITE_INACTIVE;
      end
      else begin
        pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_vector   <= nxt_virtq_notify_vector;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_addr     <= nxt_virtq_notify_addr;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_reg      <= nxt_virtq_notify_reg;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_device          <= nxt_virtq_device;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_driver          <= nxt_virtq_driver;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_desc            <= nxt_virtq_desc;
        pcie_cfg_space.pcie_cfg_space_struct.virtq_size            <= nxt_virtq_size;
        pcie_cfg_space.pcie_cfg_space_struct.activate_timers       <= nxt_activate_timers;
        pcie_cfg_space.pcie_cfg_space_struct.mm_poll_wr_val        <= nxt_mm_poll_wr_val;
        pcie_cfg_space.pcie_cfg_space_struct.mm_poll_addr          <= nxt_mm_poll_addr;
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size            <= nxt_mm_tx_size;
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_dst_addr        <= nxt_mm_tx_dst_addr;
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr        <= nxt_mm_tx_src_addr;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size <= nxt_mm_rx_desc_table_size;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr <= nxt_mm_rx_desc_table_addr;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size     <= nxt_mm_rx_buffer_size;
        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr     <= nxt_mm_rx_buffer_addr;
        pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd_w1s          <= nxt_pcie_cmd_w1s;
        pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd_w1c          <= nxt_pcie_cmd_w1c;
        pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd              <= nxt_pcie_cmd;
        cfg_intf_axil_awready[q]                                   <= nxt_cfg_intf_axil_awready;
        cfg_intf_axil_wready[q]                                    <= nxt_cfg_intf_axil_wready;
        cfg_intf_axil_bresp[q]                                     <= nxt_cfg_intf_axil_bresp;
        cfg_intf_axil_bvalid[q]                                    <= nxt_cfg_intf_axil_bvalid;
        cfg_intf_awaddr                                            <= nxt_cfg_intf_awaddr;
        cfg_intf_wdata                                             <= nxt_cfg_intf_wdata;
        rx_buff_end_addr                                           <= nxt_rx_buff_end_addr;
        cfg_write_state                                            <= nxt_cfg_write_state;
      end
    end

    always_comb begin
      nxt_virtq_notify_vector   = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_vector;
      nxt_virtq_notify_addr     = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_addr;
      nxt_virtq_notify_reg      = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_reg;
      nxt_virtq_device          = pcie_cfg_space.pcie_cfg_space_struct.virtq_device;
      nxt_virtq_driver          = pcie_cfg_space.pcie_cfg_space_struct.virtq_driver;
      nxt_virtq_desc            = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc;
      nxt_virtq_size            = pcie_cfg_space.pcie_cfg_space_struct.virtq_size;
      nxt_activate_timers       = pcie_cfg_space.pcie_cfg_space_struct.activate_timers;
      nxt_mm_poll_wr_val        = pcie_cfg_space.pcie_cfg_space_struct.mm_poll_wr_val;
      nxt_mm_poll_addr          = pcie_cfg_space.pcie_cfg_space_struct.mm_poll_addr;
      nxt_mm_tx_size            = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size;
      nxt_mm_tx_dst_addr        = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_dst_addr;
      nxt_mm_tx_src_addr        = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr;
      nxt_mm_rx_desc_table_size = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size;
      nxt_mm_rx_desc_table_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr;
      nxt_mm_rx_buffer_size     = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size;
      nxt_mm_rx_buffer_addr     = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr;
      nxt_pcie_cmd_w1s          = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd_w1s;
      nxt_pcie_cmd_w1c          = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd_w1c;
      nxt_pcie_cmd              = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd;
      nxt_cfg_intf_axil_awready = cfg_intf_axil_awready[q];
      nxt_cfg_intf_axil_wready  = cfg_intf_axil_wready[q];
      nxt_cfg_intf_axil_bresp   = cfg_intf_axil_bresp[q];
      nxt_cfg_intf_axil_bvalid  = cfg_intf_axil_bvalid[q];
      nxt_rx_buff_end_addr      = rx_buff_end_addr;
      nxt_cfg_write_state       = cfg_write_state;
      case(cfg_write_state)
        CFG_WRITE_INACTIVE:begin
          if(queue_data[q].queue_struct.queue_enable)begin
            nxt_cfg_intf_axil_awready = 1'b1;
            nxt_cfg_intf_axil_wready  = 1'b1;
            nxt_cfg_write_state       = CFG_WRITE_IDLE;
          end
        end
        CFG_WRITE_IDLE:begin
          if(cfg_intf_axil_awvalid[q] & cfg_intf_axil_awready[q] & cfg_intf_axil_wvalid[q] & cfg_intf_axil_wready[q])begin
            nxt_cfg_intf_axil_awready = 1'b0;
            nxt_cfg_intf_axil_wready  = 1'b0;
            nxt_cfg_intf_awaddr       = cfg_intf_axil_awaddr[q];
            nxt_cfg_intf_wdata        = cfg_intf_axil_wdata[q];
            nxt_cfg_write_state       = CFG_WRITE;
          end
          else if(cfg_intf_axil_awvalid[q] & cfg_intf_axil_awready[q])begin
            nxt_cfg_intf_axil_awready = 1'b0;
            nxt_cfg_intf_awaddr       = cfg_intf_axil_awaddr[q];
            nxt_cfg_write_state       = CFG_WRITE_W_WAIT;
          end
          else if(cfg_intf_axil_wvalid[q] & cfg_intf_axil_wready[q])begin
            nxt_cfg_intf_axil_wready  = 1'b0;
            nxt_cfg_intf_wdata        = cfg_intf_axil_wdata[q];
            nxt_cfg_write_state       = CFG_WRITE_AW_WAIT;
          end
          else if(q_dma_config_state == DEASSERT_REQ)begin
            nxt_pcie_cmd              = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits & 32'hffff_ffbf;
            nxt_virtq_notify_reg      = 32'd0;
            nxt_cfg_write_state       = CFG_WRITE_IDLE;
          end
          else if(q_dma_config_state == VQ_NOTIFY_WAIT)begin
            nxt_virtq_notify_reg      = 32'd0;
            nxt_cfg_write_state       = CFG_WRITE_IDLE;
          end
          else if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0] &&
                  pcie_cfg_space.pcie_cfg_space_struct.timers_valid.dword_bits[0])begin
            nxt_activate_timers = 32'd0;
          end
        end
        CFG_WRITE_AW_WAIT:begin
          if(cfg_intf_axil_awvalid[q] & cfg_intf_axil_awready[q])begin
            nxt_cfg_intf_axil_awready = 1'b0;
            nxt_cfg_intf_awaddr       = cfg_intf_axil_awaddr[q];
            nxt_cfg_write_state       = CFG_WRITE;
          end
        end
        CFG_WRITE_W_WAIT:begin
          if(cfg_intf_axil_wvalid[q] & cfg_intf_axil_wready[q])begin
            nxt_cfg_intf_axil_wready  = 1'b0;
            nxt_cfg_intf_wdata        = cfg_intf_axil_wdata[q];
            nxt_cfg_write_state       = CFG_WRITE;
          end
        end
        CFG_WRITE:begin
          nxt_cfg_intf_axil_bresp  = 2'b00;
          nxt_cfg_intf_axil_bvalid = 1'b1;
          nxt_cfg_write_state      = CFG_WRITE_RESP_WAIT;
          case({cfg_intf_awaddr[31:2], 2'b00})
            32'h04:begin // cmd
              nxt_pcie_cmd = cfg_intf_wdata;
            end
            32'h08:begin // cmd w1s
              nxt_pcie_cmd     = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits | cfg_intf_wdata;
              nxt_pcie_cmd_w1s = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits | cfg_intf_wdata;
            end
            32'h0C:begin // cmd w1c
              nxt_pcie_cmd     = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits & (~cfg_intf_wdata);
              nxt_pcie_cmd_w1c = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits & (~cfg_intf_wdata);
            end
            32'h10:begin
              nxt_mm_rx_buffer_addr = cfg_intf_wdata;
            end
            32'h14:begin
              nxt_mm_rx_buffer_size = cfg_intf_wdata;
              nxt_rx_buff_end_addr  = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr + cfg_intf_wdata;
              /* This necessitates that the user logic always update rx buffer address before rx buffer size. */
            end
            32'h18:begin
              nxt_mm_rx_desc_table_addr = cfg_intf_wdata;
            end
            32'h1C:begin
              nxt_mm_rx_desc_table_size = cfg_intf_wdata;
            end
            32'h20:begin
              nxt_mm_tx_src_addr = cfg_intf_wdata;
            end
            32'h24:begin
              nxt_mm_tx_dst_addr = cfg_intf_wdata;
            end
            32'h28:begin
              nxt_mm_tx_size = cfg_intf_wdata;
            end
            32'h2C:begin
              nxt_mm_poll_addr = cfg_intf_wdata;
            end
            32'h30:begin
              nxt_mm_poll_wr_val = cfg_intf_wdata;
            end
            32'h3C:begin
              nxt_activate_timers = cfg_intf_wdata;
            end
            32'h40:begin
              //nxt_virtq_size = cfg_intf_wdata & 32'h0000FFFF; // 16-bit queue size
              nxt_virtq_size = pcie_cfg_space.pcie_cfg_space_struct.virtq_size;
            end
            32'h44:begin
              nxt_virtq_desc = cfg_intf_wdata;
            end
            32'h48:begin
              nxt_virtq_driver = cfg_intf_wdata;
            end
            32'h4C:begin
              nxt_virtq_device = cfg_intf_wdata;
            end
            32'h50:begin
              nxt_virtq_notify_reg = cfg_intf_wdata;
            end
            32'h54:begin
              nxt_virtq_notify_addr = cfg_intf_wdata;
            end
            32'h58:begin
              nxt_virtq_notify_vector = cfg_intf_wdata;
            end
            default:begin
            end
          endcase
        end
        CFG_WRITE_RESP_WAIT:begin
          if(cfg_intf_axil_bvalid[q] & cfg_intf_axil_bready[q])begin
            nxt_cfg_intf_axil_bvalid  = 1'b0;
            nxt_cfg_intf_axil_awready = 1'b1;
            nxt_cfg_intf_axil_wready  = 1'b1;
            nxt_cfg_write_state       = CFG_WRITE_IDLE;
          end
        end
        default:begin
          nxt_cfg_write_state = CFG_WRITE_IDLE;
        end
      endcase
    end

    // Read control
    cfg_space_read_state_t cfg_read_state, nxt_cfg_read_state; 

    always_ff @(posedge clk)begin
      if(reset)begin
        cfg_intf_axil_arready[q] <= 1'b1;
        cfg_intf_axil_rdata[q]   <= 32'd0;
        cfg_intf_axil_rvalid[q]  <= 1'b0;
        cfg_intf_axil_rresp[q]   <= 2'b00;
        cfg_intf_araddr          <= 32'd0;
        cfg_read_state           <= CFG_READ_INACTIVE;
      end
      else begin
        cfg_intf_axil_arready[q] <= nxt_cfg_intf_axil_arready;
        cfg_intf_axil_rdata[q]   <= nxt_cfg_intf_axil_rdata;
        cfg_intf_axil_rvalid[q]  <= nxt_cfg_intf_axil_rvalid;
        cfg_intf_axil_rresp[q]   <= nxt_cfg_intf_axil_rresp;
        cfg_intf_araddr          <= nxt_cfg_intf_araddr;
        cfg_read_state           <= nxt_cfg_read_state;    
      end
    end

    always_comb begin
      nxt_cfg_intf_axil_arready = cfg_intf_axil_arready[q];
      nxt_cfg_intf_axil_rdata   = cfg_intf_axil_rdata[q];
      nxt_cfg_intf_axil_rvalid  = cfg_intf_axil_rvalid[q];
      nxt_cfg_intf_axil_rresp   = cfg_intf_axil_rresp[q];
      nxt_cfg_intf_araddr       = cfg_intf_araddr;
      nxt_cfg_read_state        = cfg_read_state;    
      case(cfg_read_state)
        CFG_READ_INACTIVE:begin
          if(queue_data[q].queue_struct.queue_enable)begin
            nxt_cfg_intf_axil_arready = 1'b1;
            nxt_cfg_read_state        = CFG_READ_IDLE;
          end
          /* Following logic is added to prevent the softcore processor waiting on a read request until the queue is enabled by the host. */
          else if(cfg_intf_axil_arready[q] & cfg_intf_axil_arvalid[q])begin
            nxt_cfg_intf_axil_rvalid  = 1'b1;
            nxt_cfg_intf_axil_rdata   = 32'd0;
            nxt_cfg_intf_axil_rresp   = 2'b00;
            nxt_cfg_read_state        = CFG_READ_INACTIVE_RESP;
          end
        end
        CFG_READ_INACTIVE_RESP:begin
          nxt_cfg_intf_axil_rvalid  = 1'b0;
          nxt_cfg_read_state        = CFG_READ_INACTIVE;
        end
        CFG_READ_IDLE:begin
          if(cfg_intf_axil_arready[q] && cfg_intf_axil_arvalid[q])begin
            nxt_cfg_intf_araddr       = cfg_intf_axil_araddr[q] & 32'hFFFF_FFFC;
            nxt_cfg_intf_axil_arready = 1'b0;
            nxt_cfg_read_state        = CFG_READ;
          end
        end
        CFG_READ:begin
          nxt_cfg_intf_axil_rdata  = pcie_cfg_space.pcie_cfg_space_dwords[cfg_intf_araddr >> 2].dword_bits;
          nxt_cfg_intf_axil_rvalid = 1'b1;
          nxt_cfg_intf_axil_rresp  = 2'b00;
          nxt_cfg_read_state       = CFG_READ_RESP_WAIT;
        end
        CFG_READ_RESP_WAIT:begin
          if(cfg_intf_axil_rvalid[q] & cfg_intf_axil_rready[q])begin
            nxt_cfg_intf_axil_rdata   = 32'd0;
            nxt_cfg_intf_axil_rvalid  = 1'b0;
            nxt_cfg_intf_axil_rresp   = 2'b00;
            nxt_cfg_intf_axil_arready = 1'b1;
            nxt_cfg_read_state        = CFG_READ_IDLE;
          end
        end
        default:begin
          nxt_cfg_read_state = CFG_READ_IDLE;
        end
      endcase
    end


    /* Command register */
    /*
      [31]  : Enable (1) / disable (0) queue
      [6]   : MM transaction valid
      [5]   : MM mode interrupt (0) / polling (1) selection
      [4]   : Data movement direction for RX virtqueues. 0: to host memory  1: from host memory
              (Queue controller for RX virtqueues facilitate completely bypassing the virtIO driver and directly moving data to/from host memory)
      [3]   : Destination address field (0: not used / 1: used)
      [2:0] : Operating mode selection (virtIO/streaming/MM)
    */


    /* Status register */
    /*
      [31]  : Queue enabled/disabled (from host side)
      [30}  : Queue enabled/disabled (from device side)
      [29]  : Queue busy
      [28]  : Queue direction ( TX(1) or RX(0) virtqueue )
              (Indicates whether the controller is connected to a RX or TX virtqueue.)
      [11:6] : Last transaction status
                [6]  - success (0) / fail (1)
                [7]  - invalid command register contents
                [8]  - no valid buffers available (host)
                [9]  - no buffers available (device)
                [10] - data partially moved 
                [11] - There are chained buffers not moved to device because of lack of space
      [5]   : Interrupt/polling selection for MM mode
      [4]   : Direction of data movement (MM mode)
      [3]   : Destination address usage selection for MM mode
      [2:0] : Operating mode (virtIO/streaming/MM)
    */


    logic [31:0] pcie_status_temp;
    logic [5:0]  last_trx_status, nxt_last_trx_status;


    /* Queue Control */
    // dma_config_state_t q_dma_config_state;
    // dma_config_state_t nxt_q_dma_config_state;

    // Select the endpoint between this module and memory for the connection with the DMA engine.
    logic         q_endpoint_ctrl, nxt_q_endpoint_ctrl;
    // Request signal to the arbiter
    logic         nxt_q_request;

    logic         q_s_axi_awready, nxt_q_s_axi_awready;
    logic         q_s_axi_wready,  nxt_q_s_axi_wready;
    logic [1  :0] q_s_axi_bresp,   nxt_q_s_axi_bresp;
    logic         q_s_axi_arready, nxt_q_s_axi_arready;
    logic [1  :0] q_s_axi_rresp,   nxt_q_s_axi_rresp;
    logic         q_s_axi_bvalid,  nxt_q_s_axi_bvalid;
    logic [127:0] q_s_axi_rdata,   nxt_q_s_axi_rdata;
    logic         q_s_axi_rlast,   nxt_q_s_axi_rlast;
    logic         q_s_axi_rvalid,  nxt_q_s_axi_rvalid;

    logic [31 :0] q_m_axil_awaddr,  nxt_q_m_axil_awaddr;
    logic         q_m_axil_awvalid, nxt_q_m_axil_awvalid;
    logic [31 :0] q_m_axil_wdata,   nxt_q_m_axil_wdata;
    logic [3  :0] q_m_axil_wstrb,   nxt_q_m_axil_wstrb;
    logic         q_m_axil_wvalid,  nxt_q_m_axil_wvalid;
    logic         q_m_axil_bready,  nxt_q_m_axil_bready;
    logic [31 :0] q_m_axil_araddr,  nxt_q_m_axil_araddr;
    logic         q_m_axil_arvalid, nxt_q_m_axil_arvalid;
    logic         q_m_axil_rready,  nxt_q_m_axil_rready;

    logic        q_c2h_dsc_byp_ready,    nxt_q_c2h_dsc_byp_ready;
    logic [63:0] q_c2h_dsc_byp_src_addr, nxt_q_c2h_dsc_byp_src_addr;
    logic [63:0] q_c2h_dsc_byp_dst_addr, nxt_q_c2h_dsc_byp_dst_addr;
    logic [27:0] q_c2h_dsc_byp_len,      nxt_q_c2h_dsc_byp_len;
    logic [15:0] q_c2h_dsc_byp_ctl,      nxt_q_c2h_dsc_byp_ctl;
    logic        q_c2h_dsc_byp_load,     nxt_q_c2h_dsc_byp_load;
    logic [27:0] q_c2h_moved_data,       nxt_q_c2h_moved_data;
    
    logic        q_h2c_dsc_byp_ready,    nxt_q_h2c_dsc_byp_ready;
    logic [63:0] q_h2c_dsc_byp_src_addr, nxt_q_h2c_dsc_byp_src_addr;
    logic [63:0] q_h2c_dsc_byp_dst_addr, nxt_q_h2c_dsc_byp_dst_addr;
    logic [27:0] q_h2c_dsc_byp_len,      nxt_q_h2c_dsc_byp_len;
    logic [15:0] q_h2c_dsc_byp_ctl,      nxt_q_h2c_dsc_byp_ctl;
    logic        q_h2c_dsc_byp_load,     nxt_q_h2c_dsc_byp_load;
    logic [27:0] q_h2c_moved_data,       nxt_q_h2c_moved_data;
    
    logic [31:0] q_dma_engine_config_axil_awaddr,  nxt_q_dma_engine_config_axil_awaddr;
    logic        q_dma_engine_config_axil_awvalid, nxt_q_dma_engine_config_axil_awvalid;
    logic [31:0] q_dma_engine_config_axil_wdata,   nxt_q_dma_engine_config_axil_wdata;
    logic [3 :0] q_dma_engine_config_axil_wstrb,   nxt_q_dma_engine_config_axil_wstrb;
    logic        q_dma_engine_config_axil_wvalid,  nxt_q_dma_engine_config_axil_wvalid;
    logic        q_dma_engine_config_axil_bready,  nxt_q_dma_engine_config_axil_bready;
    logic [31:0] q_dma_engine_config_axil_araddr,  nxt_q_dma_engine_config_axil_araddr;
    logic        q_dma_engine_config_axil_arvalid, nxt_q_dma_engine_config_axil_arvalid;
    logic        q_dma_engine_config_axil_rready,  nxt_q_dma_engine_config_axil_rready;
    
    logic [3 :0] q_usr_irq_req, nxt_q_usr_irq_req;  // To user interrupt port of the DMA IP

    logic [15:0] q_avail_rng_flags, nxt_q_avail_rng_flags;
    logic [15:0] q_avail_rng_idx, nxt_q_avail_rng_idx;
    logic [15:0] q_avail_int_idx, nxt_q_avail_int_idx;
    logic [15:0] q_avail_entry, nxt_q_avail_entry;
    logic [63:0] q_buf_addr, nxt_q_buf_addr;
    logic [31:0] q_buf_len, nxt_q_buf_len;
    logic [15:0] q_buf_flags, nxt_q_buf_flags;
    logic [15:0] q_buf_next, nxt_q_buf_next;
    logic [31:0] q_moved_data, nxt_q_moved_data;  // in bytes

    logic        rx_q_check_avail_ring, nxt_rx_q_check_avail_ring;
    
    logic        q_irq_configured, nxt_q_irq_configured;
    logic        q_interrupt_usr, nxt_q_interrupt_usr;  // Interrupt signals to the user logic
    logic        driver_irq_pending, nxt_driver_irq_pending;  // Pending interrupt to be sent to the driver
    logic        q_data_partially_moved, nxt_q_data_partially_moved;

    logic [15:0] usr_q_avail_rng_idx, nxt_usr_q_avail_rng_idx;
    logic [15:0] usr_q_used_rng_idx, nxt_usr_q_used_rng_idx;
    logic [15:0] usr_q_avail_rng_idx_mod, usr_q_used_rng_idx_mod;
    logic [15:0] usr_q_avail_rng_int_idx, nxt_usr_q_avail_rng_int_idx;
    logic [15:0] usr_q_used_rng_int_idx, nxt_usr_q_used_rng_int_idx; 
    logic [15:0] usr_q_desc_idx, nxt_usr_q_desc_idx;
  
    logic [127:0] usr_q_desc, nxt_usr_q_desc;
    
    logic q_notify;


    logic sleep_mode, nxt_sleep_mode;
    logic [SLEEP_TIMER_BITS-1:0] sleep_timer, nxt_sleep_timer;
    logic [31:0] reclaimed_descs, nxt_reclaimed_descs;
    logic [31:0] reclaimed_buf_size, nxt_reclaimed_buf_size;

    // Queue direction
    localparam Q_DIR = q[0] ? RX : TX; // Queue direction from the point of view of the device.
                                       // This is the opposite of the virtqueue directions from the point of view of the driver.

    // Buffer and descriptor table management
    logic [31:0] rx_buffer_head, nxt_rx_buffer_head;
    logic [31:0] rx_buffer_head_new;
    logic [31:0] current_buffer_start, nxt_current_buffer_start;
    logic [31:0] rx_buffer_tail, nxt_rx_buffer_tail;
    logic [31:0] rx_desc_table_head, nxt_rx_desc_table_head;
    logic [31:0] rx_desc_table_tail, nxt_rx_desc_table_tail;
    logic        pointers_configured, nxt_pointers_configured;
    logic        head_ptr_wraparound, nxt_head_ptr_wraparound;
    logic [31:0] head_ptr_wraparound_addr, nxt_head_ptr_wraparound_addr;

    // Debug logic
    logic [7:0] rx_counter, nxt_rx_counter;
    logic [7:0] tx_counter, nxt_tx_counter;

    // Continuous assignments
    assign q_notify = write_addr[5:0] == (5'h10 * q);

    assign pcie_status_temp[31]    = (queue_data[q].queue_struct.queue_enable.word_bits != 0); // queue active (driver)
    assign pcie_status_temp[30]    = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[31]; // controller active (device)
    assign pcie_status_temp[29]    = (q_dma_config_state != DMA_IDLE);
    assign pcie_status_temp[28]    = q[0];
    assign pcie_status_temp[27:11] = 21'd0;
    assign pcie_status_temp[10:6]  = last_trx_status;
    assign pcie_status_temp[5]     = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[5]; // Interrupt/polling selection for MM mode
    assign pcie_status_temp[4]     = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[4]; // Direction of data movement (MM mode).
    assign pcie_status_temp[3]     = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3]; // Destination address usage selection for MM mode
    assign pcie_status_temp[2:0]   = pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0]; // Mode selection

    assign pcie_cfg_space.pcie_cfg_space_struct.pcie_status = pcie_status_temp;

    assign usr_q_avail_rng_idx_mod = usr_q_avail_rng_idx % QUEUE_SIZE;
    assign usr_q_used_rng_idx_mod  = usr_q_used_rng_idx % QUEUE_SIZE;

    assign rx_buffer_head_new = rx_buffer_head + q_moved_data;

    always_ff @(posedge clk)begin
      if(reset)begin
        // CSRs
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.num_buffers           <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.timer_buf_clean_end   <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.timer_buf_clean_start <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.timer_trx_end         <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.timer_trx_start       <= 32'd0;
        pcie_cfg_space.pcie_cfg_space_struct.timers_valid          <= 32'd0;
        // AXI-MM interface
        q_endpoint_ctrl                  <= 1'b1;
        q_requests[q]                    <= 1'b0;
        q_s_axi_awready                  <= 1'b1;
        q_s_axi_wready                   <= 1'b1;
        q_s_axi_bresp                    <= 2'b00;
        q_s_axi_arready                  <= 1'b1;
        q_s_axi_rresp                    <= 2'b00;
        q_s_axi_bvalid                   <= 1'b1;
        q_s_axi_rdata                    <= 128'd0;
        q_s_axi_rlast                    <= 1'b0;
        q_s_axi_rvalid                   <= 1'b0;
        // Descriptor bypass interface
        q_h2c_dsc_byp_load               <= 1'b0;
        q_h2c_dsc_byp_src_addr           <= 64'd0;
        q_h2c_dsc_byp_dst_addr           <= 64'd0;
        q_h2c_dsc_byp_len                <= 28'd0;
        q_h2c_moved_data                 <= 28'd0;
        q_c2h_moved_data                 <= 28'd0;
        q_h2c_dsc_byp_ctl                <= 16'd0;
        q_c2h_dsc_byp_load               <= 1'b0;
        q_c2h_dsc_byp_src_addr           <= 64'd0;
        q_c2h_dsc_byp_dst_addr           <= 64'd0;
        q_c2h_dsc_byp_len                <= 28'd0;
        q_c2h_moved_data                 <= 28'd0;
        q_c2h_dsc_byp_ctl                <= 16'd0;
        // DMA engine config. interface
        q_dma_engine_config_axil_awaddr  <= 32'd0;
        q_dma_engine_config_axil_awvalid <= 1'b0;
        q_dma_engine_config_axil_wdata   <= 32'd0;
        q_dma_engine_config_axil_wstrb   <= 4'b0000;
        q_dma_engine_config_axil_wvalid  <= 1'b0;
        q_dma_engine_config_axil_bready  <= 1'b1;
        q_dma_engine_config_axil_araddr  <= 32'd0;
        q_dma_engine_config_axil_arvalid <= 1'b0;
        q_dma_engine_config_axil_rready  <= 1'b1;
        // Master interface to the smart switch
        q_m_axil_awaddr                  <= 32'd0;
        q_m_axil_awvalid                 <= 1'b0;
        q_m_axil_wdata                   <= 32'd0;
        q_m_axil_wstrb                   <= 4'b0000;
        q_m_axil_wvalid                  <= 1'b0;
        q_m_axil_bready                  <= 1'b1;
        q_m_axil_araddr                  <= 32'd0;
        q_m_axil_arvalid                 <= 1'b0;
        q_m_axil_rready                  <= 1'b1;
        // Internal variables
        q_avail_rng_flags                <= 16'd0;
        q_avail_rng_idx                  <= 16'd0;
        q_avail_int_idx                  <= 16'd0;
        q_avail_entry                    <= 16'd0;
        q_buf_addr                       <= 64'd0;
        q_buf_len                        <= 32'd0;
        q_buf_flags                      <= 16'd0;
        q_buf_next                       <= 16'd0;
        usr_q_avail_rng_idx              <= 16'd0;
        usr_q_used_rng_idx               <= 16'd0;
        usr_q_avail_rng_int_idx          <= 16'd0;
        usr_q_used_rng_int_idx           <= 16'd0;
        usr_q_desc_idx                   <= 16'd0;
        usr_q_desc                       <= 128'd0;
        // Interrupts
        q_usr_irq_req                    <= 4'b0000;
        q_irq_configured                 <= 1'b0;
        // RX descriptor table
        rx_buffer_head                   <= 32'd0;
        current_buffer_start             <= 32'd0;
        rx_buffer_tail                   <= 32'd0;
        rx_desc_table_head               <= 32'hffffffff;
        rx_desc_table_tail               <= 32'hffffffff;
        pointers_configured              <= 1'b0;
        head_ptr_wraparound              <= 1'b0;
        head_ptr_wraparound_addr         <= 32'd0;
        last_trx_status                  <= 5'd0;
        driver_irq_pending               <= 1'b0;
        q_data_partially_moved           <= 1'b0;
        q_interrupt_usr                  <= 1'b0;
        q_moved_data                     <= 32'd0;
        sleep_mode                       <= USER;
        sleep_timer                      <= {SLEEP_TIMER_BITS{1'b0}}; 
        reclaimed_descs                  <= 32'd0;
        reclaimed_buf_size               <= 32'd0;
        rx_q_check_avail_ring            <= 1'b0;
        goto_state                       <= DMA_IDLE;
        // FSM state
        q_dma_config_state               <= DMA_IDLE;
        rx_counter                       <= 8'd0;
        tx_counter                       <= 8'd0;
      end 
      else begin
        pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes <= nxt_mm_tx_remaining_bytes;
        pcie_cfg_space.pcie_cfg_space_struct.num_buffers           <= nxt_num_buffers;
        pcie_cfg_space.pcie_cfg_space_struct.timer_buf_clean_end   <= nxt_timer_buf_clean_end;
        pcie_cfg_space.pcie_cfg_space_struct.timer_buf_clean_start <= nxt_timer_buf_clean_start;
        pcie_cfg_space.pcie_cfg_space_struct.timer_trx_end         <= nxt_timer_trx_end;
        pcie_cfg_space.pcie_cfg_space_struct.timer_trx_start       <= nxt_timer_trx_start;
        pcie_cfg_space.pcie_cfg_space_struct.timers_valid          <= nxt_timers_valid;
        q_endpoint_ctrl                  <= nxt_q_endpoint_ctrl;
        q_requests[q]                    <= nxt_q_request;
        q_s_axi_awready                  <= nxt_q_s_axi_awready;
        q_s_axi_wready                   <= nxt_q_s_axi_wready;
        q_s_axi_bresp                    <= nxt_q_s_axi_bresp;
        q_s_axi_arready                  <= nxt_q_s_axi_arready;
        q_s_axi_rresp                    <= nxt_q_s_axi_rresp;
        q_s_axi_bvalid                   <= nxt_q_s_axi_bvalid;
        q_s_axi_rdata                    <= nxt_q_s_axi_rdata;
        q_s_axi_rlast                    <= nxt_q_s_axi_rlast;
        q_s_axi_rvalid                   <= nxt_q_s_axi_rvalid;
        q_h2c_dsc_byp_load               <= nxt_q_h2c_dsc_byp_load;
        q_h2c_dsc_byp_src_addr           <= nxt_q_h2c_dsc_byp_src_addr;
        q_h2c_dsc_byp_dst_addr           <= nxt_q_h2c_dsc_byp_dst_addr;
        q_h2c_dsc_byp_len                <= nxt_q_h2c_dsc_byp_len;
        q_h2c_moved_data                 <= nxt_q_h2c_moved_data;
        q_c2h_moved_data                 <= nxt_q_c2h_moved_data;
        q_h2c_dsc_byp_ctl                <= nxt_q_h2c_dsc_byp_ctl;
        q_c2h_dsc_byp_load               <= nxt_q_c2h_dsc_byp_load;
        q_c2h_dsc_byp_src_addr           <= nxt_q_c2h_dsc_byp_src_addr;
        q_c2h_dsc_byp_dst_addr           <= nxt_q_c2h_dsc_byp_dst_addr;
        q_c2h_dsc_byp_len                <= nxt_q_c2h_dsc_byp_len;
        q_c2h_moved_data                 <= nxt_q_c2h_moved_data;
        q_c2h_dsc_byp_ctl                <= nxt_q_c2h_dsc_byp_ctl;
        q_dma_engine_config_axil_awaddr  <= nxt_q_dma_engine_config_axil_awaddr;
        q_dma_engine_config_axil_awvalid <= nxt_q_dma_engine_config_axil_awvalid;
        q_dma_engine_config_axil_wdata   <= nxt_q_dma_engine_config_axil_wdata;
        q_dma_engine_config_axil_wstrb   <= nxt_q_dma_engine_config_axil_wstrb;
        q_dma_engine_config_axil_wvalid  <= nxt_q_dma_engine_config_axil_wvalid;
        q_dma_engine_config_axil_bready  <= nxt_q_dma_engine_config_axil_bready;
        q_dma_engine_config_axil_araddr  <= nxt_q_dma_engine_config_axil_araddr;
        q_dma_engine_config_axil_arvalid <= nxt_q_dma_engine_config_axil_arvalid;
        q_dma_engine_config_axil_rready  <= nxt_q_dma_engine_config_axil_rready;
        q_m_axil_awaddr                  <= nxt_q_m_axil_awaddr;
        q_m_axil_awvalid                 <= nxt_q_m_axil_awvalid;
        q_m_axil_wdata                   <= nxt_q_m_axil_wdata;
        q_m_axil_wstrb                   <= nxt_q_m_axil_wstrb;
        q_m_axil_wvalid                  <= nxt_q_m_axil_wvalid;
        q_m_axil_bready                  <= nxt_q_m_axil_bready;
        q_m_axil_araddr                  <= nxt_q_m_axil_araddr;
        q_m_axil_arvalid                 <= nxt_q_m_axil_arvalid;
        q_m_axil_rready                  <= nxt_q_m_axil_rready;
        q_avail_rng_flags                <= nxt_q_avail_rng_flags;
        q_avail_rng_idx                  <= nxt_q_avail_rng_idx;
        q_avail_int_idx                  <= nxt_q_avail_int_idx;
        q_avail_entry                    <= nxt_q_avail_entry;
        q_buf_addr                       <= nxt_q_buf_addr;
        q_buf_len                        <= nxt_q_buf_len;
        q_buf_flags                      <= nxt_q_buf_flags;
        q_buf_next                       <= nxt_q_buf_next;
        usr_q_avail_rng_idx              <= nxt_usr_q_avail_rng_idx;
        usr_q_used_rng_idx               <= nxt_usr_q_used_rng_idx;
        usr_q_avail_rng_int_idx          <= nxt_usr_q_avail_rng_int_idx;
        usr_q_used_rng_int_idx           <= nxt_usr_q_used_rng_int_idx;
        usr_q_desc_idx                   <= nxt_usr_q_desc_idx;
        usr_q_desc                       <= nxt_usr_q_desc;
        q_irq_configured                 <= nxt_q_irq_configured;
        q_usr_irq_req                    <= nxt_q_usr_irq_req;
        rx_buffer_head                   <= nxt_rx_buffer_head;
        current_buffer_start             <= nxt_current_buffer_start;
        rx_buffer_tail                   <= nxt_rx_buffer_tail;
        rx_desc_table_head               <= nxt_rx_desc_table_head;
        rx_desc_table_tail               <= nxt_rx_desc_table_tail;
        pointers_configured              <= nxt_pointers_configured;
        head_ptr_wraparound              <= nxt_head_ptr_wraparound;
        head_ptr_wraparound_addr         <= nxt_head_ptr_wraparound_addr;
        last_trx_status                  <= nxt_last_trx_status;
        driver_irq_pending               <= nxt_driver_irq_pending;
        q_data_partially_moved           <= nxt_q_data_partially_moved;
        q_interrupt_usr                  <= nxt_q_interrupt_usr;
        q_moved_data                     <= nxt_q_moved_data;
        sleep_mode                       <= nxt_sleep_mode;
        sleep_timer                      <= nxt_sleep_timer;
        reclaimed_descs                  <= nxt_reclaimed_descs;
        reclaimed_buf_size               <= nxt_reclaimed_buf_size;
        rx_q_check_avail_ring            <= nxt_rx_q_check_avail_ring;
        goto_state                       <= nxt_goto_state;
        q_dma_config_state               <= nxt_q_dma_config_state;
        rx_counter                       <= nxt_rx_counter;
        tx_counter                       <= nxt_tx_counter;
      end
    end

    always_comb begin
      nxt_mm_tx_remaining_bytes            = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits;
      nxt_num_buffers                      = pcie_cfg_space.pcie_cfg_space_struct.num_buffers;
      nxt_timer_buf_clean_end              = pcie_cfg_space.pcie_cfg_space_struct.timer_buf_clean_end;
      nxt_timer_buf_clean_start            = pcie_cfg_space.pcie_cfg_space_struct.timer_buf_clean_start;
      nxt_timer_trx_end                    = pcie_cfg_space.pcie_cfg_space_struct.timer_trx_end;
      nxt_timer_trx_start                  = pcie_cfg_space.pcie_cfg_space_struct.timer_trx_start;
      nxt_timers_valid                     = pcie_cfg_space.pcie_cfg_space_struct.timers_valid;
      nxt_q_endpoint_ctrl                  = q_endpoint_ctrl;
      nxt_q_request                        = q_requests[q];
      nxt_q_s_axi_awready                  = q_s_axi_awready;
      nxt_q_s_axi_wready                   = q_s_axi_wready;
      nxt_q_s_axi_bresp                    = q_s_axi_bresp;
      nxt_q_s_axi_arready                  = q_s_axi_arready;
      nxt_q_s_axi_rresp                    = q_s_axi_rresp;
      nxt_q_s_axi_bvalid                   = q_s_axi_bvalid;
      nxt_q_s_axi_rdata                    = q_s_axi_rdata;
      nxt_q_s_axi_rlast                    = q_s_axi_rlast;
      nxt_q_s_axi_rvalid                   = q_s_axi_rvalid;
      nxt_q_h2c_dsc_byp_load               = q_h2c_dsc_byp_load;
      nxt_q_h2c_dsc_byp_src_addr           = q_h2c_dsc_byp_src_addr;
      nxt_q_h2c_dsc_byp_dst_addr           = q_h2c_dsc_byp_dst_addr;
      nxt_q_h2c_dsc_byp_len                = q_h2c_dsc_byp_len;
      nxt_q_h2c_moved_data                 = q_h2c_moved_data;
      nxt_q_c2h_moved_data                 = q_c2h_moved_data;
      nxt_q_h2c_dsc_byp_ctl                = q_h2c_dsc_byp_ctl;
      nxt_q_c2h_dsc_byp_load               = q_c2h_dsc_byp_load;
      nxt_q_c2h_dsc_byp_src_addr           = q_c2h_dsc_byp_src_addr;
      nxt_q_c2h_dsc_byp_dst_addr           = q_c2h_dsc_byp_dst_addr;
      nxt_q_c2h_dsc_byp_len                = q_c2h_dsc_byp_len;
      nxt_q_c2h_moved_data                 = q_c2h_moved_data;
      nxt_q_c2h_dsc_byp_ctl                = q_c2h_dsc_byp_ctl;
      nxt_q_dma_engine_config_axil_awaddr  = q_dma_engine_config_axil_awaddr;
      nxt_q_dma_engine_config_axil_awvalid = q_dma_engine_config_axil_awvalid;
      nxt_q_dma_engine_config_axil_wdata   = q_dma_engine_config_axil_wdata;
      nxt_q_dma_engine_config_axil_wstrb   = q_dma_engine_config_axil_wstrb;
      nxt_q_dma_engine_config_axil_wvalid  = q_dma_engine_config_axil_wvalid;
      nxt_q_dma_engine_config_axil_bready  = q_dma_engine_config_axil_bready;
      nxt_q_dma_engine_config_axil_araddr  = q_dma_engine_config_axil_araddr;
      nxt_q_dma_engine_config_axil_arvalid = q_dma_engine_config_axil_arvalid;
      nxt_q_dma_engine_config_axil_rready  = q_dma_engine_config_axil_rready;
      nxt_q_m_axil_awaddr                  = q_m_axil_awaddr;
      nxt_q_m_axil_awvalid                 = q_m_axil_awvalid;
      nxt_q_m_axil_wdata                   = q_m_axil_wdata;
      nxt_q_m_axil_wstrb                   = q_m_axil_wstrb;
      nxt_q_m_axil_wvalid                  = q_m_axil_wvalid;
      nxt_q_m_axil_bready                  = q_m_axil_bready;
      nxt_q_m_axil_araddr                  = q_m_axil_araddr;
      nxt_q_m_axil_arvalid                 = q_m_axil_arvalid;
      nxt_q_m_axil_rready                  = q_m_axil_rready;
      nxt_q_avail_rng_flags                = q_avail_rng_flags;
      nxt_q_avail_rng_idx                  = q_avail_rng_idx;
      nxt_q_avail_int_idx                  = q_avail_int_idx;
      nxt_q_avail_entry                    = q_avail_entry;
      nxt_q_buf_addr                       = q_buf_addr;
      nxt_q_buf_len                        = q_buf_len;
      nxt_q_buf_flags                      = q_buf_flags;
      nxt_q_buf_next                       = q_buf_next;
      nxt_usr_q_avail_rng_idx              = usr_q_avail_rng_idx;
      nxt_usr_q_used_rng_idx               = usr_q_used_rng_idx;
      nxt_usr_q_avail_rng_int_idx          = usr_q_avail_rng_int_idx;
      nxt_usr_q_used_rng_int_idx           = usr_q_used_rng_int_idx;
      nxt_usr_q_desc_idx                   = usr_q_desc_idx;
      nxt_usr_q_desc                       = usr_q_desc;
      nxt_q_irq_configured                 = q_irq_configured;
      nxt_q_usr_irq_req                    = q_usr_irq_req;
      nxt_rx_buffer_head                   = rx_buffer_head;
      nxt_current_buffer_start             = current_buffer_start;
      nxt_rx_buffer_tail                   = rx_buffer_tail;
      nxt_rx_desc_table_head               = rx_desc_table_head;
      nxt_rx_desc_table_tail               = rx_desc_table_tail;
      nxt_pointers_configured              = pointers_configured;
      nxt_head_ptr_wraparound              = head_ptr_wraparound;
      nxt_head_ptr_wraparound_addr         = head_ptr_wraparound_addr;
      nxt_rx_buffer_head                   = rx_buffer_head;
      nxt_current_buffer_start             = current_buffer_start;
      nxt_last_trx_status                  = last_trx_status;
      nxt_driver_irq_pending               = driver_irq_pending;
      nxt_q_data_partially_moved           = q_data_partially_moved;
      nxt_q_interrupt_usr                  = q_interrupt_usr;
      nxt_q_moved_data                     = q_moved_data;
      nxt_sleep_mode                       = sleep_mode;
      nxt_reclaimed_descs                  = reclaimed_descs;
      nxt_reclaimed_buf_size               = reclaimed_buf_size;
      nxt_sleep_timer                      = sleep_timer;
      nxt_rx_q_check_avail_ring            = rx_q_check_avail_ring;
      nxt_goto_state                       = goto_state;
      nxt_q_dma_config_state               = q_dma_config_state;
      nxt_rx_counter                       = rx_counter;
      nxt_tx_counter                       = tx_counter;
      case(q_dma_config_state)
        DMA_IDLE:begin
          if(!(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[31] & pcie_cfg_space.pcie_cfg_space_struct.pcie_status.dword_bits[31]))begin
          //  Queue is not enabled, either from by the driver or the user logic
            nxt_rx_buffer_head       = 32'd0;
            nxt_current_buffer_start = 32'd0;
            nxt_rx_buffer_tail       = 32'd0;
            nxt_rx_desc_table_head   = 32'hffffffff;
            nxt_rx_desc_table_tail   = 32'hffffffff;
            nxt_pointers_configured  = 1'b0;
          end
          else begin
            nxt_rx_buffer_head       = pointers_configured ? rx_buffer_head : pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
            nxt_current_buffer_start = pointers_configured ? current_buffer_start : pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
            nxt_rx_buffer_tail       = pointers_configured ? rx_buffer_tail : pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
            nxt_rx_desc_table_head   = pointers_configured ? rx_desc_table_head : 32'hffffffff;
            nxt_rx_desc_table_tail   = pointers_configured ? rx_desc_table_tail : 32'hffffffff;
            nxt_pointers_configured  = 1'b1;
            /*
            Figure out whether a RX or TX queue.
            Notifications for TX queues are ignored. Check for available buffers only when a transmit request is received from the user side.
            */
            if(Q_DIR == RX)begin // TX virtqueue
              if(write_state == ACTIVE_WRITE & write_sel == 4'b0010 & q_notify & queue_data[q].queue_struct.queue_enable.word_bits != 0)begin
                nxt_q_request          = 1'b1;
                nxt_q_moved_data       = 32'd0;
                nxt_last_trx_status    = 6'd0; // Clear the status of the last tranaction
                nxt_q_dma_config_state = ARBITRATION_WAIT;
                nxt_rx_counter         = rx_counter + 8'd1;
                //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
                  nxt_timer_trx_start       = global_clock;
                  nxt_timer_trx_end         = 32'd0;
                  nxt_timer_buf_clean_start = 32'd0;
                  nxt_timer_buf_clean_end   = 32'd0;
                //end
              end
            end
            else if(Q_DIR == TX)begin // RX virtqueue
              if((pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[6] | pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_reg != 0) & 
                queue_data[q].queue_struct.queue_enable.word_bits != 0)begin
                nxt_q_request          = 1'b1;
                nxt_q_moved_data       = 32'd0;
                nxt_last_trx_status    = 6'd0; // Clear the status of the last tranaction
                nxt_q_dma_config_state = ARBITRATION_WAIT;
                nxt_tx_counter         = tx_counter + 8'd1;
                //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
                  nxt_timer_trx_start       = global_clock;
                  nxt_timer_trx_end         = 32'd0;
                  nxt_timer_buf_clean_start = 32'd0;
                  nxt_timer_buf_clean_end   = 32'd0;
                //end
              end
            end
          end
        end
        ARBITRATION_WAIT:begin
          if(q_grant == q & arb_valid)begin // Access granted
            if(Q_DIR == RX)begin
              // VirtIO interface is used on the host side. Therefore, check both H2C and C2H engines.
              nxt_q_dma_engine_config_axil_araddr  = 32'h0000_0_0_04;
              nxt_q_dma_engine_config_axil_arvalid = 1'b1;
              nxt_q_dma_config_state               = RD_H2C_CTRL_REQ;
            end
            else if(Q_DIR == TX)begin
              // Figure out which mode the controller is operating on (Because the TX controller can act as a RX controller when required to bypass the virtIO drivers.)
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[0])begin // MM mode
                if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3] & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[4])begin
                // Bypass the VirtIO interface and directly read host memory.
                  // Check if the H2C engine is running
                  nxt_q_dma_engine_config_axil_araddr  = 32'h0000_0_0_04;
                  nxt_q_dma_engine_config_axil_arvalid = 1'b1;
                  nxt_q_dma_config_state               = RD_H2C_CTRL_REQ;
                end
                else if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3] & ~pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[4])begin
                // Bypass the VirtIO interface and directly write to host memory.
                  // Check if the C2H engine is running
                  nxt_q_dma_engine_config_axil_araddr  = 32'h0000_1_0_04;
                  nxt_q_dma_engine_config_axil_arvalid = 1'b1;
                  nxt_q_dma_config_state               = RD_C2H_CTRL_REQ;
                end
                else if(~pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3])begin // Use virtIO interface on the host side
                  // Need to check both H2C and C2H engines
                  nxt_q_dma_engine_config_axil_araddr  = 32'h0000_0_0_04;
                  nxt_q_dma_engine_config_axil_arvalid = 1'b1;
                  nxt_q_dma_config_state               = RD_H2C_CTRL_REQ;
                end
                else begin // Invalid command register contents
                  nxt_q_request            = 1'b0;
                  nxt_last_trx_status[1:0] = 2'b11;
                  nxt_q_dma_config_state   = DEASSERT_REQ;
                end
              end
              else if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // VirtIO mode
                // VirtIO interface is used on the host side. Therefore, check both H2C and C2H engines.
                nxt_q_dma_engine_config_axil_araddr  = 32'h0000_0_0_04;
                nxt_q_dma_engine_config_axil_arvalid = 1'b1;
                nxt_q_dma_config_state               = RD_H2C_CTRL_REQ;
              end
              else begin // Other modes not supported yet.
                nxt_q_request            = 1'b0;
                nxt_last_trx_status[1:0] = 2'b11;
                nxt_q_dma_config_state   = DEASSERT_REQ;
              end
            end
          end
        end
        RD_H2C_CTRL_REQ:begin
          if(dma_engine_config_axil_arvalid & dma_engine_config_axil_arready)begin
            nxt_q_dma_engine_config_axil_araddr  = 32'h0000_0_0_00;
            nxt_q_dma_engine_config_axil_arvalid = 1'b0;
            nxt_q_dma_config_state               = RD_H2C_CTRL_WAIT;
          end
        end
        RD_H2C_CTRL_WAIT:begin
          if(dma_engine_config_axil_rready & dma_engine_config_axil_rvalid)begin
            if(dma_engine_config_axil_rdata[0])begin  // 'Run' bit is set
              if(Q_DIR == RX | pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2] |~pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3])begin
                // Connected to TX virtqueue (RX from point of view of the controller) or VirtIO mode used or destination address field not used.
                // Need to check the C2H interface as well
                nxt_q_dma_engine_config_axil_araddr  = 32'h0000_1_0_04;
                nxt_q_dma_engine_config_axil_arvalid = 1'b1;
                nxt_q_dma_config_state               = RD_C2H_CTRL_REQ;
              end
              else begin
                nxt_q_dma_config_state               = START_TRANSACTION;
              end
            end
            else begin // Run bit is not set
              nxt_q_dma_engine_config_axil_awvalid = 1'b1;
              nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_08;
              nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
              nxt_q_dma_engine_config_axil_wdata   = 32'h00000001;
              nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
              nxt_q_dma_config_state               = WR_H2C_CTRL_REQ;
            end
          end
        end
        WR_H2C_CTRL_REQ:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid & dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_H2C_CTRL_WAIT;
          end
          else if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            /* Have to wait for the address channel. */
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_H2C_CTRL_REQ_AW;
          end
          else if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            /* Have to wait for the write data channel. */
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_H2C_CTRL_REQ_W;
          end
        end
        WR_H2C_CTRL_REQ_AW:begin
          if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_H2C_CTRL_WAIT;
          end
        end
        WR_H2C_CTRL_REQ_W:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_H2C_CTRL_WAIT;
          end
        end
        WR_H2C_CTRL_WAIT:begin
          if(dma_engine_config_axil_bvalid & dma_engine_config_axil_bready & dma_engine_config_axil_bresp == 2'b00)begin
            if(Q_DIR == RX | pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2] |~pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3])begin
              // Need to check the C2H interface as well
              nxt_q_dma_engine_config_axil_araddr  = 32'h0000_1_0_04;
              nxt_q_dma_engine_config_axil_arvalid = 1'b1;
              nxt_q_dma_config_state               = RD_C2H_CTRL_REQ;
            end
            else begin
              nxt_q_dma_config_state               = START_TRANSACTION;
            end
          end
        end
        RD_C2H_CTRL_REQ:begin
          if(dma_engine_config_axil_arvalid & dma_engine_config_axil_arready)begin
            nxt_q_dma_engine_config_axil_araddr  = 32'h0000_0_0_00;
            nxt_q_dma_engine_config_axil_arvalid = 1'b0;
            nxt_q_dma_config_state               = RD_C2H_CTRL_WAIT;
          end
        end
        RD_C2H_CTRL_WAIT:begin
          if(dma_engine_config_axil_rready & dma_engine_config_axil_rvalid)begin
            if(dma_engine_config_axil_rdata[0])begin  // 'Run' bit is set
              nxt_q_dma_config_state               = START_TRANSACTION;
            end
            else begin // 'Run' bit is not set
              nxt_q_dma_engine_config_axil_awvalid = 1'b1;
              nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_1_0_08;
              nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
              nxt_q_dma_engine_config_axil_wdata   = 32'h00000001;
              nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
              nxt_q_dma_config_state               = WR_C2H_CTRL_REQ;
            end
          end
        end
        WR_C2H_CTRL_REQ:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid & dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_C2H_CTRL_WAIT;
          end
          else if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            /* Have to wait for the address channel. */
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_C2H_CTRL_REQ_AW;
          end
          else if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            /* Have to wait for the write data channel. */
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_C2H_CTRL_REQ_W;
          end
        end
        WR_C2H_CTRL_REQ_AW:begin
          if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_C2H_CTRL_WAIT;
          end
        end
        WR_C2H_CTRL_REQ_W:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_C2H_CTRL_WAIT;
          end
        end
        WR_C2H_CTRL_WAIT:begin
          if(dma_engine_config_axil_bvalid & dma_engine_config_axil_bready & dma_engine_config_axil_bresp == 2'b00)begin
            nxt_q_dma_config_state               = START_TRANSACTION;
          end
        end
        START_TRANSACTION:begin
          if(Q_DIR == TX)begin
            if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[4:0] == 5'b01001)begin
            // Write to host memory bypassing the virtIO interface
              nxt_q_c2h_dsc_byp_load     = 1'b1;
              nxt_q_c2h_dsc_byp_src_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr;
              nxt_q_c2h_dsc_byp_dst_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_dst_addr;
              nxt_q_c2h_dsc_byp_len      = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size;
              nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
              nxt_q_dma_config_state     = DIRECT_WR_REQ;
            end
            else if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[4:0] == 5'b11001)begin
            // Read from host memory bypassing the virtIO interface
              nxt_q_h2c_dsc_byp_load     = 1'b1;
              nxt_q_h2c_dsc_byp_src_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr;
              nxt_q_h2c_dsc_byp_dst_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_dst_addr;
              nxt_q_h2c_dsc_byp_len      = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size;
              nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
              nxt_q_dma_config_state     = DIRECT_RD_REQ;
            end
            else if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3:0] == 4'b0001)begin
            // Write data to the RX virtqueue
              nxt_q_h2c_dsc_byp_load     = 1'b1;
              nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_driver;
              nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
              nxt_q_h2c_dsc_byp_len      = 28'd4;    // Read flags and idx
              nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
              nxt_mm_tx_remaining_bytes  = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size.dword_bits;
              nxt_q_dma_config_state     = RD_Q_AVAIL_IDX_REQ;
            end
            else if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[3:0] == 4'b0100)begin
              // Read available ring idx and flags
              nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_driver.dword_bits; // PCIe controller acts as device for TX requests.
              nxt_q_m_axil_arvalid   = 1'b1;
              nxt_q_dma_config_state = VQ_RD_AVAIL_IDX;
            end
            else begin
            // Invalid command register contents
              nxt_q_request            = 1'b0;
              nxt_last_trx_status[1:0] = 2'b11;
              nxt_q_dma_config_state   = DEASSERT_REQ;
            end
          end
          else if(Q_DIR == RX)begin
            nxt_q_h2c_dsc_byp_load     = 1'b1;
            nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_driver;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd4;    // Read flags and idx
            nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
            nxt_q_dma_config_state     = RD_Q_AVAIL_IDX_REQ;
          end
        end
        DIRECT_WR_REQ:begin
          if(c2h_dsc_byp_load_0 & c2h_dsc_byp_ready_0)begin
            nxt_q_c2h_dsc_byp_load     = 1'b0;
            nxt_q_c2h_dsc_byp_src_addr = 64'd0;
            nxt_q_c2h_dsc_byp_dst_addr = 64'd0;
            //nxt_q_c2h_dsc_byp_len      = 28'd0;
            nxt_q_c2h_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b0;     // Select memory as the endpoint
            nxt_q_c2h_moved_data       = 28'd0;
            nxt_q_dma_config_state     = DIRECT_WR_WAIT;
          end
        end
        DIRECT_WR_WAIT:begin
          if(s_axi_rvalid_from_mem & s_axi_rready_to_mem)begin // Read response from memory
            if(q_c2h_dsc_byp_len <= 28'd16)begin
              nxt_q_dma_config_state = DIRECT_WR_WAIT_DESC_CMPL;
            end
            else begin
              nxt_q_c2h_moved_data       = q_h2c_moved_data + 28'd16;
              nxt_q_dma_config_state     = DIRECT_WR_COUNT_DATA;
            end
          end
        end
        DIRECT_WR_COUNT_DATA:begin
          if(s_axi_rvalid_from_mem & s_axi_rready_to_mem)begin
            if(q_c2h_dsc_byp_len <= q_c2h_moved_data + 28'd16)begin
              nxt_q_dma_config_state     = DIRECT_WR_WAIT_DESC_CMPL;
            end
            else begin
              nxt_q_c2h_moved_data       = q_c2h_moved_data + 28'd16;
              nxt_q_dma_config_state     = DIRECT_WR_COUNT_DATA;
            end
          end
        end
        DIRECT_WR_WAIT_DESC_CMPL:begin
          //if(c2h_sts_0[3])begin  // Descriptor done
          if(~c2h_sts_0[0])begin  // DMA engine not busy
            nxt_q_endpoint_ctrl    = 1'b1;
            nxt_last_trx_status    = 6'd0;
            nxt_q_dma_config_state = DEASSERT_REQ;
          end
        end
        DIRECT_RD_REQ:begin
          if(h2c_dsc_byp_load_0 & h2c_dsc_byp_ready_0)begin
            nxt_q_h2c_dsc_byp_load     = 1'b0;
            nxt_q_h2c_dsc_byp_src_addr = 64'd0;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            //nxt_q_h2c_dsc_byp_len      = 28'd0;
            nxt_q_h2c_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b0;     // Select memory as the endpoint
            nxt_q_h2c_moved_data       = 28'd0;
            nxt_q_dma_config_state     = DIRECT_RD_WAIT;
          end
        end
        DIRECT_RD_WAIT:begin
          if(s_axi_wvalid_to_mem & s_axi_wready_from_mem)begin  // Memory is being written to
            if(q_h2c_dsc_byp_len <= 28'd16)begin
              nxt_q_dma_config_state = DIRECT_RD_WAIT_BVALID;
            end
            else begin
              nxt_q_h2c_moved_data   = q_h2c_moved_data + 28'd16;
              nxt_q_dma_config_state = DIRECT_RD_COUNT_DATA;
            end
          end
        end
        DIRECT_RD_COUNT_DATA:begin
          if(s_axi_wvalid_to_mem & s_axi_wready_from_mem)begin  // Memory is being written to
            if(q_h2c_dsc_byp_len <= q_h2c_moved_data + 28'd16)begin
              nxt_q_dma_config_state     = DIRECT_RD_WAIT_BVALID;
            end
            else begin
              nxt_q_h2c_moved_data       = q_h2c_moved_data + 28'd16;
              nxt_q_dma_config_state     = DIRECT_RD_COUNT_DATA;
            end
          end
        end
        DIRECT_RD_WAIT_BVALID:begin
          if(s_axi_bready_to_mem & s_axi_bvalid_from_mem)begin // Data movement complete.
            nxt_q_dma_config_state     = DIRECT_RD_WAIT_DESC_CMPL;
          end
        end
        DIRECT_RD_WAIT_DESC_CMPL:begin
          //if(h2c_sts_0[3])begin
          if(~h2c_sts_0[0])begin
            nxt_q_endpoint_ctrl    = 1'b1;
            nxt_last_trx_status    = 6'd0;
            nxt_q_dma_config_state = DEASSERT_REQ;
          end
        end
        RD_Q_AVAIL_IDX:begin
          nxt_q_h2c_dsc_byp_load     = 1'b1;
          nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_driver;
          nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
          nxt_q_h2c_dsc_byp_len      = 28'd4;    // Read flags and idx
          nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
          nxt_q_dma_config_state     = RD_Q_AVAIL_IDX_REQ;
        end
        RD_Q_AVAIL_IDX_REQ:begin
          if(h2c_dsc_byp_load_0 & h2c_dsc_byp_ready_0)begin
            nxt_q_h2c_dsc_byp_load     = 1'b0;
            nxt_q_h2c_dsc_byp_src_addr = 64'd0;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd0;
            nxt_q_h2c_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b1;     // Select this module as the endpoint
            nxt_q_dma_config_state     = RD_Q_AVAIL_IDX_WAIT;
          end
        end
        RD_Q_AVAIL_IDX_WAIT:begin
          if(s_axi_wvalid & s_axi_wready)begin
            nxt_q_avail_rng_flags  = s_axi_wdata[15:0];
            nxt_q_avail_rng_idx    = s_axi_wdata[31:16];
            nxt_q_dma_config_state = RD_Q_AVAIL_RING_REQ_BUILD;
          end
        end
        RD_Q_AVAIL_RING_REQ_BUILD:begin
          if(q_avail_rng_idx != q_avail_int_idx)begin // Unused buffers are available
            nxt_q_h2c_dsc_byp_load     = 1'b1;
            nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_driver + 64'd4 + (q_avail_int_idx[QUEUE_IDX_BITS-1:0] << 1);
            /* src addr = queue_driver based addr + flags(2 Bytes) + idx(2 Bytes) + (q_internal_index%queue_size)*2 (2 Bytes per entry)  */
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd2; // Read 1 entry
            nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
            nxt_q_moved_data           = 32'd0;
            nxt_q_dma_config_state     = RD_Q_AVAIL_RING_REQ;
          end
          else if(Q_DIR == RX & rx_q_check_avail_ring)begin // In case the controller has missed any notifications from the driver
            nxt_q_h2c_dsc_byp_load     = 1'b1;
            nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_driver;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd4;    // Read flags and idx
            nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
            nxt_rx_q_check_avail_ring  = 1'b0;
            nxt_q_moved_data           = 32'd0;
            nxt_q_dma_config_state     = RD_Q_AVAIL_IDX_REQ;
          end
          else begin
            if(Q_DIR == TX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // VirtIO device side interface
              /* No buffers available on the host. Sleep and check again later. */
              nxt_goto_state = RD_Q_AVAIL_IDX;
              nxt_q_dma_config_state = SLEEP;
            end
            else begin
              nxt_q_endpoint_ctrl    = 1'b1;
              nxt_q_dma_config_state = DEASSERT_REQ;
            end
          end
        end
        RD_Q_AVAIL_RING_REQ:begin
          if(h2c_dsc_byp_load_0 & h2c_dsc_byp_ready_0)begin
            nxt_q_h2c_dsc_byp_load     = 1'b0;
            nxt_q_h2c_dsc_byp_src_addr = 64'd0;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd0;
            nxt_q_h2c_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b1;     // Select this module as the endpoint
            nxt_q_dma_config_state     = RD_Q_AVAIL_RING_WAIT;
          end
        end
        RD_Q_AVAIL_RING_WAIT:begin
          if(s_axi_wvalid & s_axi_wready)begin
            nxt_q_avail_entry         = s_axi_wdata[15:0];
            // Build the descriptor to fetch a descriptor ring entry
            nxt_q_h2c_dsc_byp_load     = 1'b1;
            nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_desc + (s_axi_wdata[15:0] << 4);
            /* src addr = queue_desc based addr + avail_ring_entry*16 (16 Bytes per descriptor)  */
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd16; // Read 1 descriptor
            nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
            nxt_q_dma_config_state     = RD_Q_DESC_REQ;
          end
        end
        RD_Q_DESC_REQ:begin
          if(h2c_dsc_byp_load_0 & h2c_dsc_byp_ready_0)begin
            nxt_q_h2c_dsc_byp_load     = 1'b0;
            nxt_q_h2c_dsc_byp_src_addr = 64'd0;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd0;
            nxt_q_h2c_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b1;
            nxt_q_dma_config_state     = RD_Q_DESC_WAIT;
          end
        end
        RD_Q_DESC_WAIT:begin
          if(s_axi_wvalid & s_axi_wready)begin
            nxt_q_buf_addr         = s_axi_wdata[63:0];
            nxt_q_buf_len          = s_axi_wdata[95:64];
            nxt_q_buf_flags        = s_axi_wdata[111:96];
            nxt_q_buf_next         = s_axi_wdata[127:112];
            if(Q_DIR == RX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2])begin // VirtIO interface used
              // Check whether there are queue entries that can be used. If not read used queue idx from memory to see if 
              // the device has updated it.
              if(usr_q_avail_rng_idx == usr_q_used_rng_idx)begin // Device has consumed all entries previously made available.
                nxt_q_dma_config_state = Q_MOVE_DATA;
              end
              else if(usr_q_avail_rng_idx_mod == usr_q_used_rng_idx_mod)begin
                nxt_q_m_axil_arvalid       = 1'b1;
                nxt_q_m_axil_araddr        = pcie_cfg_space.pcie_cfg_space_struct.virtq_device.dword_bits;
                //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
                  nxt_timer_buf_clean_start  = global_clock;
                //end
                nxt_q_dma_config_state     = VQ_RD_USED_IDX;
              end
              else begin
                nxt_q_dma_config_state = Q_MOVE_DATA;
              end
            end
            else begin
              nxt_q_dma_config_state = Q_MOVE_DATA;
            end
          end
        end
        VQ_RD_AVAIL_IDX:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_AVAIL_IDX_WAIT;
          end
        end
        VQ_RD_USED_IDX:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_USED_IDX_WAIT;
          end
        end
        VQ_RD_USED_IDX_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp == 2'b00)begin
            nxt_usr_q_used_rng_idx = m_axil_rdata[q][31:16];
            nxt_q_dma_config_state = VQ_IDX_COMPARE;
          end
        end
        VQ_IDX_COMPARE:begin
          if(usr_q_avail_rng_idx == usr_q_used_rng_idx)begin // Device has consumed all entries previously made available.
            nxt_q_dma_config_state = VQ_BUF_CLEANUP;
          end
          else if(usr_q_avail_rng_idx_mod == usr_q_used_rng_idx_mod)begin
            nxt_q_endpoint_ctrl    = 1'b1;
            nxt_q_request          = 1'b0;
            nxt_sleep_mode         = TIMER;
            nxt_goto_state         = VQ_RD_USED_IDX_REQ;
            nxt_sleep_timer        = SLEEP_TIMER_VAL;
            nxt_q_dma_config_state = SLEEP;
          end
          else begin
            nxt_q_dma_config_state = VQ_BUF_CLEANUP;
          end
        end
        VQ_RD_USED_IDX_REQ:begin
          nxt_q_m_axil_arvalid   = 1'b1;
          nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_device.dword_bits;
          nxt_q_dma_config_state = VQ_RD_USED_IDX;
        end
        VQ_BUF_CLEANUP:begin
          if(usr_q_used_rng_idx == usr_q_used_rng_int_idx)begin // Done reclaiming buffer space
            //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
              nxt_timer_buf_clean_end = global_clock;
            //end
            nxt_q_dma_config_state  = Q_MOVE_DATA;
          end
          else begin
            nxt_q_m_axil_arvalid   = 1'b1;
            nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_device.dword_bits + 32'd4 + ((usr_q_used_rng_int_idx % QUEUE_SIZE) << 3) + 32'd4; // (8 Bytes per struct virtq_used_elem)
                                                                                                                                                                  // read length field
            nxt_q_dma_config_state = VQ_RD_USED_RNG_ELEM;
          end
        end
        /*
        In this veersion of the controller, we make the following assumptions:
        - user side logic is consuming the buffers in the same order they were exposed
        - user logic consumes the whole buffer before updateing the used ring.
          - This means the buffer tail pointer can be upadted only by reading the used_ring.ring.len field.
        */
        VQ_RD_USED_RNG_ELEM:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_USED_RNG_ELEM_WAIT;
          end
        end
        VQ_RD_USED_RNG_ELEM_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 2'b00)begin
            if(m_axil_rdata[q][1:0] != 2'b00)begin
              if((rx_buffer_tail + m_axil_rdata[q] + (3'b100 - m_axil_rdata[q][1:0]) == head_ptr_wraparound_addr) & head_ptr_wraparound)begin
                nxt_rx_buffer_tail      = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                nxt_head_ptr_wraparound = 1'b0;
              end
              else if((rx_buffer_tail + m_axil_rdata[q] + (3'b100 - m_axil_rdata[q][1:0]) == rx_buffer_head))begin // Buffer is empty
                nxt_rx_buffer_tail = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                nxt_rx_buffer_head = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
              end
              else begin
                nxt_rx_buffer_tail = (rx_buffer_tail + m_axil_rdata[q] + (3'b100 - m_axil_rdata[q][1:0]) < rx_buff_end_addr) ?
                                      rx_buffer_tail + m_axil_rdata[q] + (3'b100 - m_axil_rdata[q][1:0]) :
                                      rx_buffer_tail + m_axil_rdata[q] + (3'b100 - m_axil_rdata[q][1:0]) -
                                      pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
              end
            end
            else begin
              if((rx_buffer_tail + m_axil_rdata[q] == head_ptr_wraparound_addr) & head_ptr_wraparound)begin
                nxt_rx_buffer_tail      = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                nxt_head_ptr_wraparound = 1'b0;
              end
              else if((rx_buffer_tail + m_axil_rdata[q] == rx_buffer_head))begin
                nxt_rx_buffer_tail = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                nxt_rx_buffer_head = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
              end
              else begin
                nxt_rx_buffer_tail = (rx_buffer_tail + m_axil_rdata[q] < rx_buff_end_addr) ?
                                      rx_buffer_tail + m_axil_rdata[q] :
                                      rx_buffer_tail + m_axil_rdata[q] -
                                      pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
              end
            end
            nxt_usr_q_used_rng_int_idx = usr_q_used_rng_int_idx + 16'd1;
            nxt_q_dma_config_state     = VQ_BUF_CLEANUP;
          end
        end
        Q_MOVE_DATA:begin
          if(Q_DIR == RX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b001)begin // MM mode
            if(q_buf_len > pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits)begin // Data is larger than the total buffer size
              if(last_trx_status[5])begin  // One or more buffers from the current descriptor chain were moved previously.
              /* In the current version, the transaction is terminated if any of the buffers in a descriptor chain is larger than the whole receive
                 buffer in device memory.
                 In this version there is no way to recover that packet because the controller is going to pretend that the data was moved completely 
                 and update the used ring accordingly. This is done to keep the driver funcitoning properly and continue with future transactions.
                 User logic can use or throw away the partially moved data.
                 Later versions can include a mechanism to either move data in blocks as the user logic consumes moved data and clears the buffer space,
                 or for the controller to go into a wait state until the user logic allocates a larger buffer, or a combination of both. */
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_last_trx_status[0] = 1'b1; // trx unsuccessful
                nxt_last_trx_status[3] = 1'b1; // -\ Some buffers were moved. But one buffer in the chain is larger than the total available buffer space
                nxt_last_trx_status[5] = 1'b1; // -/ in the device. Therefore, aborting.
                nxt_q_dma_config_state = INTERRUPT_USR;
              end
              else begin  // No data moved previously
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_last_trx_status[0] = 1'b1;
                nxt_last_trx_status[3] = 1'b1;
                nxt_q_dma_config_state = INTERRUPT_USR;
              end
            end
            else begin
              if((rx_desc_table_head == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size.dword_bits - 1 & rx_desc_table_tail == 32'hffffffff) 
              || (rx_desc_table_head == rx_desc_table_tail-1))begin // Descriptor table is full
                // Look for used table entries and reclaim those
                // In the current vresion, DMA engine is not released by the controller.
                nxt_reclaimed_descs    = 32'd0;
                nxt_q_dma_config_state = DESC_TAB_CLEANUP;
              end
              else begin // Descriptor table entries are available
                if(rx_buffer_head > rx_buffer_tail)begin
                  if(q_buf_len > (rx_buff_end_addr - rx_buffer_head))begin /* data length is larger than the available contiguous buffer space */
                    if(rx_buffer_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits)begin
                    /* Cannot set the head pointer to buffer start address
                     * because that will be the same as tail pointer which 
                     * cause confusion about buffer full vs empty state*/
                      nxt_reclaimed_descs    = 32'd0;
                      nxt_q_dma_config_state = DESC_TAB_CLEANUP;
                    end
                    else begin // Set head pointer to buffer start address and recheck
                      nxt_rx_buffer_head           = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                      nxt_head_ptr_wraparound      = 1'b1;
                      nxt_head_ptr_wraparound_addr = rx_buffer_head;
                      nxt_q_dma_config_state       = Q_MOVE_DATA;
                    end
                  end
                  else if(q_buf_len == (rx_buff_end_addr - rx_buffer_head))begin /* Data fits remaining buffer space exactly. */
                    if(rx_buffer_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits)begin
                      nxt_reclaimed_descs    = 32'd0;
                      nxt_q_dma_config_state = DESC_TAB_CLEANUP;
                    end
                    else begin
                      if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                        // Move the data to device
                        nxt_q_h2c_dsc_byp_load     = 1'b1;
                        nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                        nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                        nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                        nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                        nxt_current_buffer_start   = rx_buffer_head;
                        nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                      end
                      else begin
                        nxt_q_endpoint_ctrl        = 1'b1;
                        nxt_last_trx_status[0]     = 1'b1;
                        nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                        nxt_q_dma_config_state     = DEASSERT_REQ;
                      end
                    end
                  end
                  else begin // Data is smaller than remaining buffer space
                    if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                      // Move the data to device
                      nxt_q_h2c_dsc_byp_load     = 1'b1;
                      nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                      nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                      nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                      nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                      nxt_current_buffer_start   = rx_buffer_head;
                      nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                    end
                    else begin
                      nxt_q_endpoint_ctrl        = 1'b1;
                      nxt_last_trx_status[0]     = 1'b1;
                      nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                      nxt_q_dma_config_state     = DEASSERT_REQ;
                    end
                  end
                end
                else if(rx_buffer_head < rx_buffer_tail)begin
                  if(q_buf_len >= (rx_buffer_tail - rx_buffer_head))begin // Cannot move data
                    nxt_reclaimed_descs    = 32'd0;
                    nxt_q_dma_config_state = DESC_TAB_CLEANUP;
                  end
                  else begin
                    if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                      // Move the data to device
                      nxt_q_h2c_dsc_byp_load     = 1'b1;
                      nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                      nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                      nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                      nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                      nxt_current_buffer_start   = rx_buffer_head;
                      nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                    end
                    else begin
                      nxt_q_endpoint_ctrl        = 1'b1;
                      nxt_last_trx_status[0]     = 1'b1;
                      nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                      nxt_q_dma_config_state     = DEASSERT_REQ;
                    end
                  end
                end 
                else begin // Sufficient space in the buffer, the empty buffer case (rx_buffer_head == rx_buffer_tail)
                  if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                    // Move the data to device
                    nxt_q_h2c_dsc_byp_load     = 1'b1;
                    nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                    nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                    nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                    nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                    nxt_current_buffer_start   = rx_buffer_head;
                    nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                  end
                  else begin
                    nxt_q_endpoint_ctrl        = 1'b1;
                    nxt_last_trx_status[0]     = 1'b1;
                    nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                    nxt_q_dma_config_state     = DEASSERT_REQ;
                  end
                end
              end
            end
          end
          else if(Q_DIR == RX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // virtIO mode
            if(q_buf_len > pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits)begin // Data is larger than the total buffer size
              if(last_trx_status[5])begin  // One or more buffers from the current descriptor chain were moved previously.
              /* In the current version, the transaction is terminated if any of the buffers in a descriptor chain is larger than the whole receive
                 buffer in device memory.
                 In this version there is no way to recover that packet because the controller is going to pretend that the data was moved completely 
                 and update the used ring accordingly. This is done to keep the driver funcitoning properly and continue with future transactions.
                 User logic can use or throw away the partially moved data.
                 Later versions can include a mechanism to either move data in blocks as the user logic consumes moved data and clears the buffer space,
                 or for the controller to go into a wait state until the user logic allocates a larger buffer, or a combination of both. */
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_last_trx_status[0] = 1'b1; // trx unsuccessful
                nxt_last_trx_status[3] = 1'b1; // -\ Some buffers were moved. But one buffer in the chain is larger than the total available buffer space
                nxt_last_trx_status[5] = 1'b1; // -/ in the device. Therefore, aborting.
                nxt_q_dma_config_state = INTERRUPT_USR;
              end
              else begin  // No data moved previously
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_last_trx_status[0] = 1'b1;
                nxt_last_trx_status[3] = 1'b1;
                nxt_q_dma_config_state = INTERRUPT_USR;
              end
            end
            else begin
              //Check available buffer space
              if(((rx_buffer_head > rx_buffer_tail) & (q_buf_len < (rx_buff_end_addr - rx_buffer_head))) | 
                 ((rx_buffer_head < rx_buffer_tail) & (q_buf_len < (rx_buffer_tail - rx_buffer_head)))   | 
                 (rx_buffer_head == rx_buffer_tail))begin // Enough space in the buffer
                if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                  // Move the data to device
                  nxt_q_h2c_dsc_byp_load     = 1'b1;
                  nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                  nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                  nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                  nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                  nxt_current_buffer_start   = rx_buffer_head;
                  nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                end
                else begin
                  nxt_q_endpoint_ctrl        = 1'b1;
                  nxt_last_trx_status[0]     = 1'b1;
                  nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                  nxt_q_dma_config_state     = DEASSERT_REQ;
                end
              end
              else begin // Insuffucient space in the buffer
                if(rx_buffer_head > rx_buffer_tail)begin
                  if(q_buf_len > (rx_buff_end_addr - rx_buffer_head))begin /* data length is larger than the available contiguous buffer space */
                    if(rx_buffer_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits)begin
                      //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
                        nxt_timer_buf_clean_start = global_clock;
                      //end
                      nxt_q_dma_config_state    = VQ_RD_USED_IDX_REQ;
                    end
                    else begin
                      nxt_rx_buffer_head           = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                      nxt_head_ptr_wraparound      = 1'b1;
                      nxt_head_ptr_wraparound_addr = rx_buffer_head;
                      nxt_q_dma_config_state       = Q_MOVE_DATA;
                    end
                  end
                  else if(q_buf_len == (rx_buff_end_addr - rx_buffer_head))begin /* Data fits remaining buffer space exactly. */
                    if(rx_buffer_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits)begin
                      //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
                        nxt_timer_buf_clean_start = global_clock;
                      //end
                      nxt_q_dma_config_state    = VQ_RD_USED_IDX_REQ;
                    end
                    else begin
                      if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                        // Move the data to device
                        nxt_q_h2c_dsc_byp_load     = 1'b1;
                        nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                        nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                        nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                        nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                        nxt_current_buffer_start   = rx_buffer_head;
                        nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                      end
                      else begin
                        nxt_q_endpoint_ctrl        = 1'b1;
                        nxt_last_trx_status[0]     = 1'b1;
                        nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                        nxt_q_dma_config_state     = DEASSERT_REQ;
                      end
                    end
                  end
                end
                else if(rx_buffer_head < rx_buffer_tail)begin
                  if(q_buf_len >= (rx_buffer_tail - rx_buffer_head))begin // Cannot move data
                    //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
                      nxt_timer_buf_clean_start = global_clock;
                    //end
                    nxt_q_dma_config_state    = VQ_RD_USED_IDX_REQ;
                  end 
                  else begin
                    if(!q_buf_flags[1])begin // Verify the buffer is not write-only
                      // Move the data to device
                      nxt_q_h2c_dsc_byp_load     = 1'b1;
                      nxt_q_h2c_dsc_byp_src_addr = q_buf_addr;
                      nxt_q_h2c_dsc_byp_dst_addr = (rx_buffer_head_new[1:0] == 2'b00) ? rx_buffer_head_new : rx_buffer_head_new + 32'd4 - {30'd0, rx_buffer_head_new[1:0]};
                      nxt_q_h2c_dsc_byp_len      = q_buf_len[27:0];
                      nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
                      nxt_current_buffer_start   = rx_buffer_head;
                      nxt_q_dma_config_state     = RD_Q_BUFFER_REQ;
                    end
                    else begin
                      nxt_q_endpoint_ctrl        = 1'b1;
                      nxt_last_trx_status[0]     = 1'b1;
                      nxt_last_trx_status[2]     = 1'b1; // No valid buffers available on the host (If this happens, it is more likely the driver has messed things up)
                      nxt_q_dma_config_state     = DEASSERT_REQ;
                    end
                  end
                end
              end
            end
          end
          else if(Q_DIR == TX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b001)begin // Card to host MM mode
            if(q_buf_flags[1])begin // Marks buffer as write-only (otherwise read-only)
              if(q_buf_len < pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits)begin // Data remaining cannot fit in a single buffer
                if(q_buf_flags[0])begin // Chained descriptor available -> Start data movement
                  nxt_mm_tx_remaining_bytes  = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits - q_buf_len;
                  nxt_last_trx_status[4]     = 1'b1; // Data partially moved
                  nxt_q_c2h_dsc_byp_load     = 1'b1;
                  nxt_q_c2h_dsc_byp_src_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr;
                  nxt_q_c2h_dsc_byp_dst_addr = q_buf_addr;
                  nxt_q_c2h_dsc_byp_len      = q_buf_len;
                  nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
                  nxt_q_endpoint_ctrl        = 1'b0;
                  nxt_q_dma_config_state     = WR_Q_BUFFER_REQ;
                  // Remaining data will be moved to the next available buffer on the available ring.
                  // If not buffers were available on the host, controller will go to idle state with error flags set to indicate that data was partially moved.
                  // User logic can read configuration space register 0x34 (mm_tx_remaining_bytes) to figure out how much data was not moved.
                end
                else begin // No chained descriptors -> Insufficient buffer space on the host -> abort
                  nxt_q_endpoint_ctrl    = 1'b1;
                  nxt_last_trx_status[0] = 1'b1; // Trx unsuccessful
                  nxt_last_trx_status[2] = 1'b1; // No valid buffers available on the host
                  nxt_q_dma_config_state = INTERRUPT_USR; // Interrupt user logic.
                end
              end
              else begin  // Data can fit in the current buffer
                nxt_mm_tx_remaining_bytes  = 32'd0;
                nxt_last_trx_status[4]     = 1'b0;
                nxt_q_c2h_dsc_byp_load     = 1'b1;
                nxt_q_c2h_dsc_byp_src_addr = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_src_addr;
                nxt_q_c2h_dsc_byp_dst_addr = q_buf_addr;
                //nxt_q_c2h_dsc_byp_len      = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size.dword_bits;
                nxt_q_c2h_dsc_byp_len      = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits;
                nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
                nxt_q_endpoint_ctrl        = 1'b0;
                nxt_q_dma_config_state     = WR_Q_BUFFER_REQ;
              end
            end
            else begin  // Driver seems to have messed up.
              nxt_q_endpoint_ctrl    = 1'b1;
              nxt_last_trx_status[0] = 1'b1; // Trx unsuccessful
              nxt_last_trx_status[2] = 1'b1; // No valid buffers available on the host
              nxt_q_dma_config_state = DEASSERT_REQ; // No need to interrupt user logic a s user initiated the trx and will read status when the busy signal is lowered.
            end
          end
          else if(Q_DIR == TX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // Card to host VirtIO mode
            if(q_buf_flags[1])begin // Marks buffer as write-only (otherwise read-only)
              if(q_buf_len < pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits)begin // Data remaining cannot fit in a single buffer
                if(q_buf_flags[0])begin // Chained descriptor available -> Start data movement
                  nxt_mm_tx_remaining_bytes  = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits - q_buf_len;
                  nxt_last_trx_status[4]     = 1'b1; // Data partially moved
                  nxt_q_c2h_dsc_byp_load     = 1'b1;
                  nxt_q_c2h_dsc_byp_src_addr = usr_q_desc[63:0];
                  nxt_q_c2h_dsc_byp_dst_addr = q_buf_addr; //FIXME: May leave some buffer space unused.
                  nxt_q_c2h_dsc_byp_len      = usr_q_desc[95:64];
                  nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
                  nxt_q_endpoint_ctrl        = 1'b0;
                  nxt_q_dma_config_state     = WR_Q_BUFFER_REQ;
                  // Remaining data will be moved to the next available buffer on the available ring.
                  // If not buffers were available on the host, controller will go to idle state with error flags set to indicate that data was partially moved.
                  // User logic can read configuration space register 0x34 (mm_tx_remaining_bytes) to figure out how much data was not moved.
                end
                else begin // No chained descriptors -> Insufficient buffer space on the host -> abort
                  nxt_q_endpoint_ctrl    = 1'b1;
                  nxt_last_trx_status[0] = 1'b1; // Trx unsuccessful
                  nxt_last_trx_status[2] = 1'b1; // No valid buffers available on the host
                  nxt_q_dma_config_state = INTERRUPT_USR; // Interrupt user logic. //TODO: need to update INTERRUPT_USR state
                end
              end
              else begin  // Data can fit in the current buffer
                nxt_mm_tx_remaining_bytes  = 32'd0;
                nxt_last_trx_status[4]     = 1'b0;
                nxt_q_c2h_dsc_byp_load     = 1'b1;
                nxt_q_c2h_dsc_byp_src_addr = usr_q_desc[63:0];
                nxt_q_c2h_dsc_byp_dst_addr = q_buf_addr;
                nxt_q_c2h_dsc_byp_len      = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits;
                nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
                nxt_q_endpoint_ctrl        = 1'b0;
                nxt_q_dma_config_state     = WR_Q_BUFFER_REQ;
              end
            end
            else begin  // Driver seems to have messed up.
              nxt_q_endpoint_ctrl    = 1'b1;
              nxt_last_trx_status[0] = 1'b1; // Trx unsuccessful
              nxt_last_trx_status[2] = 1'b1; // No valid buffers available on the host
              nxt_q_dma_config_state = INTERRUPT_USR; // Still need to interrupt user logic.
            end
          end
        end
        RD_Q_BUFFER_REQ:begin
          if(h2c_dsc_byp_load_0 & h2c_dsc_byp_ready_0)begin
            nxt_q_h2c_dsc_byp_load     = 1'b0;
            nxt_q_h2c_dsc_byp_src_addr = 64'd0;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            //nxt_q_h2c_dsc_byp_len      = 28'd0;
            nxt_q_h2c_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b0;
            nxt_q_h2c_moved_data       = 28'd0;
            nxt_q_dma_config_state     = RD_Q_BUFFER_WAIT;
          end
        end
        RD_Q_BUFFER_WAIT:begin
          if(s_axi_wvalid_to_mem & s_axi_wready_from_mem)begin // Memory is receiving data
            if(q_h2c_dsc_byp_len <= 28'd16)begin // Only one transfer is necessary. No need to count transferred bytes
              nxt_q_dma_config_state     = RD_Q_BUFFER_WAIT_BVALID;
            end
            else begin // Multiple transfers necessary
              nxt_q_h2c_moved_data       = q_h2c_moved_data + byte_count;
              nxt_q_dma_config_state     = RD_Q_BUFFER_COUNT_DATA;
            end
          end
        end
        RD_Q_BUFFER_COUNT_DATA:begin
          if(s_axi_wvalid_to_mem & s_axi_wready_from_mem)begin
            if(q_h2c_dsc_byp_len <= q_h2c_moved_data + byte_count)begin
              nxt_q_dma_config_state     = RD_Q_BUFFER_WAIT_BVALID;
            end
            else begin
              nxt_q_h2c_moved_data       = q_h2c_moved_data + byte_count;
              nxt_q_dma_config_state     = RD_Q_BUFFER_COUNT_DATA;
            end
          end
        end
        RD_Q_BUFFER_WAIT_BVALID:begin
          if(s_axi_bready_to_mem & s_axi_bvalid_from_mem)begin // Data movement complete.
            nxt_q_dma_config_state     = RD_Q_BUFFER_WAIT_DESC_CMPL;
          end
        end
        RD_Q_BUFFER_WAIT_DESC_CMPL:begin
          // if(h2c_sts_0[3])begin // Descriptor done        
          if(~h2c_sts_0[0])begin
            if(q_buf_flags[0])begin  // Descriptor chain continues through next entry
              nxt_last_trx_status[5]     = 1'b1;  // indicate data was partially moved
              nxt_q_h2c_dsc_byp_load     = 1'b1;
              nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_desc + (q_buf_next << 4);
              /* src addr = queue_desc based addr + avail_ring_entry*16 (16 Bytes per descriptor)  */
              nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
              nxt_q_h2c_dsc_byp_len      = 28'd16; // Read 1 descriptor
              nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
              nxt_q_moved_data           = q_moved_data + q_buf_len;
              /* Assume that if there are chained buffers, the current buffer is fully utilzed and the buffer size is a 4-byte multiple. */
              //nxt_rx_buffer_head         = rx_buffer_head + q_buf_len;
              nxt_q_dma_config_state     = RD_Q_DESC_REQ;
            end
            else begin  // No chained descriptors
              nxt_last_trx_status[5]     = 1'b0;
              nxt_q_c2h_dsc_byp_load     = 1'b1;
              nxt_q_c2h_dsc_byp_src_addr = 64'd0;
              nxt_q_c2h_dsc_byp_dst_addr = queue_data[q].queue_struct.queue_device + 64'd4 + (q_avail_int_idx[QUEUE_IDX_BITS-1:0] << 3);
              nxt_q_c2h_dsc_byp_len      = 28'd8; // 8 Bytes per used ring entry
              nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
              nxt_q_moved_data           = q_moved_data + q_buf_len;
              nxt_q_dma_config_state     = WR_Q_USED_RING_REQ; 
            end
          end
        end
        WR_Q_BUFFER_REQ:begin
          if(c2h_dsc_byp_load_0 & c2h_dsc_byp_ready_0)begin
            nxt_q_c2h_dsc_byp_load     = 1'b0;
            //nxt_q_c2h_dsc_byp_src_addr = 64'd0;
            nxt_q_c2h_dsc_byp_dst_addr = 64'd0;
            //nxt_q_c2h_dsc_byp_len      = 28'd0;
            nxt_q_c2h_dsc_byp_ctl      = 16'h0000;
            nxt_q_c2h_moved_data       = 28'd0;
            nxt_q_dma_config_state     = WR_Q_BUFFER_WAIT; 
          end
        end
        WR_Q_BUFFER_WAIT:begin
          if(s_axi_rvalid_from_mem & s_axi_rready_to_mem)begin // Read response from memory
            if(q_c2h_dsc_byp_len <= 28'd16)begin
              nxt_q_dma_config_state = WR_Q_BUFFER_WAIT_DESC_CMPL;
            end
            else begin
              nxt_q_dma_config_state     = WR_Q_BUFFER_COUNT_DATA;
              case(q_c2h_dsc_byp_src_addr[3:0])
                4'h0: nxt_q_c2h_moved_data = q_c2h_moved_data + 28'd16;
                4'h4: nxt_q_c2h_moved_data = q_c2h_moved_data + 28'd12;
                4'h8: nxt_q_c2h_moved_data = q_c2h_moved_data + 28'd8;
                4'hC: nxt_q_c2h_moved_data = q_c2h_moved_data + 28'd4;
                default: nxt_q_c2h_moved_data = q_c2h_moved_data + 28'd16;
              endcase
            end
          end
        end
        WR_Q_BUFFER_COUNT_DATA:begin
          if(s_axi_rvalid_from_mem & s_axi_rready_to_mem)begin
            if(q_c2h_dsc_byp_len <= q_c2h_moved_data + 28'd16)begin
              nxt_q_dma_config_state     = WR_Q_BUFFER_WAIT_DESC_CMPL;
            end
            else begin
              nxt_q_c2h_moved_data       = q_c2h_moved_data + 28'd16;
              nxt_q_dma_config_state     = WR_Q_BUFFER_COUNT_DATA;
            end
          end
        end
        WR_Q_BUFFER_WAIT_DESC_CMPL:begin
          //if(c2h_sts_0[3])begin // Descriptor done        
          if(~c2h_sts_0[0])begin
            if(pcie_cfg_space.pcie_cfg_space_struct.mm_tx_remaining_bytes.dword_bits != 0)begin  // More data to be moved. Read next descriptor
              nxt_last_trx_status[4]     = 1'b1;
              nxt_q_h2c_dsc_byp_load     = 1'b1;
              nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_desc + (q_buf_next << 4);
              /* src addr = queue_desc based addr + avail_ring_entry*16 (16 Bytes per descriptor)  */
              nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
              nxt_q_h2c_dsc_byp_len      = 28'd16; // Read 1 descriptor
              nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
              nxt_q_moved_data           = q_moved_data + q_buf_len;
              nxt_q_dma_config_state     = RD_Q_DESC_REQ;
            end
            else if(usr_q_desc[96])begin // Chained descriptors from user logic
              nxt_last_trx_status[4] = 1'b1;
              nxt_q_moved_data       = q_moved_data + usr_q_desc[95:64];
              nxt_q_m_axil_arvalid   = 1'b1;
              nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_desc[127:112] << 4); // 16 Bytes/descriptor
              nxt_q_dma_config_state = VQ_RD_DESC1_REQ;
            end
            else begin  // All data moved
              nxt_q_c2h_dsc_byp_load     = 1'b1;
              nxt_q_c2h_dsc_byp_src_addr = 64'd0;
              nxt_q_c2h_dsc_byp_dst_addr = queue_data[q].queue_struct.queue_device + 64'd4 + (q_avail_int_idx[QUEUE_IDX_BITS-1:0] << 3);
              nxt_q_c2h_dsc_byp_len      = 28'd8; // 8 Bytes per used ring entry
              nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd[2])begin // virtIO mode
                nxt_q_moved_data         = usr_q_desc[95:64]; // All data moved
              end
              else begin
                nxt_q_moved_data         = pcie_cfg_space.pcie_cfg_space_struct.mm_tx_size.dword_bits; // All data moved
              end
              nxt_q_dma_config_state     = WR_Q_USED_RING_REQ; 
            end
          end
        end
        WR_Q_USED_RING_REQ:begin
          if(c2h_dsc_byp_load_0 & c2h_dsc_byp_ready_0)begin
            nxt_q_c2h_dsc_byp_load     = 1'b0;
            nxt_q_c2h_dsc_byp_src_addr = 64'd0;
            nxt_q_c2h_dsc_byp_dst_addr = 64'd0;
            nxt_q_c2h_dsc_byp_len      = 28'd0;
            nxt_q_c2h_dsc_byp_ctl      = 16'h0000;
            nxt_q_endpoint_ctrl        = 1'b1;
            nxt_q_dma_config_state     = WR_Q_USED_RING_WAIT_RD_REQ;
          end
        end
        WR_Q_USED_RING_WAIT_RD_REQ:begin
          if(s_axi_arvalid & s_axi_arready)begin
            nxt_q_s_axi_rvalid     = 1'b1;
            nxt_q_s_axi_rlast      = 1'b1;
            nxt_q_s_axi_rdata      = {64'd0, q_moved_data, 16'd0, q_avail_entry};
            nxt_q_dma_config_state = WR_Q_USED_RING_WAIT_RRESP;
          end
        end
        WR_Q_USED_RING_WAIT_RRESP:begin
          if(s_axi_rvalid & s_axi_rready)begin
            nxt_q_s_axi_rvalid     = 1'b0;
            nxt_q_s_axi_rlast      = 1'b0;
            nxt_q_s_axi_rdata      = 128'd0;
            nxt_q_dma_config_state = WR_Q_USED_RING_WAIT_DESC_CMPL;
          end
        end
        WR_Q_USED_RING_WAIT_DESC_CMPL:begin
          if(c2h_sts_0[3])begin // Descriptor done
            // Initiate write to idx and flags fields.
            nxt_q_c2h_dsc_byp_load     = 1'b1;
            nxt_q_c2h_dsc_byp_src_addr = 64'd0;
            nxt_q_c2h_dsc_byp_dst_addr = queue_data[q].queue_struct.queue_device;
            nxt_q_c2h_dsc_byp_len      = 28'd4;
            nxt_q_c2h_dsc_byp_ctl      = 16'h0001; // Stop bit set
            nxt_q_dma_config_state     = WR_Q_USED_IDX_REQ;
          end
        end
        WR_Q_USED_IDX_REQ:begin
          if(c2h_dsc_byp_load_0 & c2h_dsc_byp_ready_0)begin
            nxt_q_c2h_dsc_byp_load     = 1'b0;
            nxt_q_c2h_dsc_byp_src_addr = 64'd0;
            nxt_q_c2h_dsc_byp_dst_addr = 64'd0;
            nxt_q_c2h_dsc_byp_len      = 28'd0;
            nxt_q_c2h_dsc_byp_ctl      = 16'h0000;
            nxt_q_dma_config_state     = WR_Q_USED_IDX_WAIT_RD_REQ;
          end
        end
        WR_Q_USED_IDX_WAIT_RD_REQ:begin
          if(s_axi_arvalid & s_axi_arready)begin
            nxt_q_s_axi_rvalid     = 1'b1;
            nxt_q_s_axi_rlast      = 1'b1;
            nxt_q_s_axi_rdata      = {96'd0, (q_avail_int_idx + 16'd1) ,16'd0};
            nxt_q_dma_config_state = WR_Q_USED_IDX_WAIT_RRESP;
          end
        end
        WR_Q_USED_IDX_WAIT_RRESP:begin
          if(s_axi_rvalid & s_axi_rready)begin
            nxt_q_s_axi_rvalid     = 1'b0;
            nxt_q_s_axi_rlast      = 1'b0;
            nxt_q_s_axi_rdata      = 128'd0;
            nxt_q_dma_config_state = WR_Q_USED_IDX_WAIT_DESC_CMPL;
          end
        end
        WR_Q_USED_IDX_WAIT_DESC_CMPL:begin
          if(c2h_sts_0[3])begin // Descriptor done
            if(Q_DIR == RX)begin
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // virtIO mode
                if(q_avail_int_idx + 1 != q_avail_rng_idx)begin // More buffers to be moved. -> Update descriptor table on device memory and get back to moving buffers.
                  nxt_q_endpoint_ctrl    = 1'b1;
                  nxt_q_dma_config_state = VQ_WR_DESC;
                end
                else begin
                  if(|irq_configured)begin
                    nxt_q_usr_irq_req      = 4'b0001 << (q+1);
                    nxt_q_dma_config_state = RAISE_Q_INT_REQ;
                  end
                  else begin  // Configure the interrupts.
                    nxt_q_dma_engine_config_axil_awvalid = 1'b1;
                    nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_2_0_08; // W1S for 0x2004
                    nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
                    // If you are the controller to first setup the IRQs, setup for everyone.
                    // FIXME: Move the general configuration interrupt out of the queue controller later when rest of the logic is fully implemented.
                    nxt_q_dma_engine_config_axil_wdata   = (32'h00000001 << (NUM_QUEUES+1)) - 32'd1;
                    nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
                    nxt_q_dma_config_state               = WR_IRQ_ENABLE_REQ;
                  end
                end
              end
              else begin // MM mode
                if(q_avail_int_idx + 1 != q_avail_rng_idx)begin // More buffers to be moved. -> Update descriptor table on device memory and get back to moving buffers.
                  nxt_q_m_axil_awaddr    = (rx_desc_table_head == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size.dword_bits - 1) ?
                                           pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits :
                                           pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits + ((rx_desc_table_head+1) << 3);
                  nxt_q_m_axil_awvalid   = 1'b1;
                  nxt_q_m_axil_wdata     = last_trx_status[5] ? {4'hA, q_moved_data[27:0]} : {4'h8, q_moved_data[27:0]};
                  nxt_q_m_axil_wstrb     = 4'b1111;
                  nxt_q_m_axil_wvalid    = 1'b1;
                  nxt_q_endpoint_ctrl    = 1'b1;
                  nxt_q_dma_config_state = DSC_TAB_WR_MDATA_REQ;
                end
                else begin //TODO: Should get rid of this whole block and goto writing descriptor table for every case. Interrupt host after updating desc. table.
                  if(|irq_configured)begin
                    nxt_q_usr_irq_req      = 4'b0001 << (q+1);
                    nxt_q_dma_config_state = RAISE_Q_INT_REQ;
                  end
                  else begin  // Configure the interrupts.
                    nxt_q_dma_engine_config_axil_awvalid = 1'b1;
                    nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_2_0_08; // W1S for 0x2004
                    nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
                    // If you are the controller to first setup the IRQs, setup for everyone.
                    // FIXME: Move the general configuration interrupt out of the queue controller later when rest of the logic is fully implemented.
                    nxt_q_dma_engine_config_axil_wdata   = (32'h00000001 << (NUM_QUEUES+1)) - 32'd1;
                    nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
                    nxt_q_dma_config_state               = WR_IRQ_ENABLE_REQ;
                  end
                end
              end
            end
            else begin // TX
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // virtIO mode
                nxt_q_m_axil_awvalid   = 1'b1;
                nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_device.dword_bits + 32'd4 + ((usr_q_avail_rng_int_idx % QUEUE_SIZE) << 3); // 8 Bytes per entry
                nxt_q_m_axil_wvalid    = 1'b1;
                nxt_q_m_axil_wdata     = usr_q_avail_rng_int_idx;
                nxt_q_m_axil_wstrb     = 4'b1111;
                nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_ID;
              end
              else begin
                if(|irq_configured)begin
                  nxt_q_usr_irq_req      = 4'b0001 << (q+1);
                  nxt_q_dma_config_state = RAISE_Q_INT_REQ;
                end
                else begin  // Configure the interrupts.
                  nxt_q_dma_engine_config_axil_awvalid = 1'b1;
                  nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_2_0_08; // W1S for 0x2004
                  nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
                  // If you are the controller to first setup the IRQs, setup for everyone.
                  // FIXME: Move the general configuration interrupt out of the queue controller later when rest of the logic is fully implemented.
                  nxt_q_dma_engine_config_axil_wdata   = (32'h00000001 << (NUM_QUEUES+1)) - 32'd1;
                  nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
                  nxt_q_dma_config_state               = WR_IRQ_ENABLE_REQ;
                end
              end
            end 
          end
        end
        WR_IRQ_ENABLE_REQ:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid & dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_IRQ_ENABLE_WAIT;
          end
          else if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            /* Have to wait for the address channel. */
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_IRQ_ENABLE_REQ_AW;
          end
          else if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            /* Have to wait for the write data channel. */
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_IRQ_ENABLE_REQ_W;
          end
        end
        WR_IRQ_ENABLE_REQ_AW:begin
          if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_IRQ_ENABLE_WAIT;
          end
        end
        WR_IRQ_ENABLE_REQ_W:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_IRQ_ENABLE_WAIT;
          end
        end
        WR_IRQ_ENABLE_WAIT:begin
          if(dma_engine_config_axil_bvalid & dma_engine_config_axil_bready & dma_engine_config_axil_bresp == 2'b00)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b1;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_2_0_80; // user IRQ to MSIx vector mapping
            nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
            nxt_q_dma_engine_config_axil_wdata   = {11'd0, queue_data[1].queue_struct.queue_msix_vector.word_bits[4:0], 
                                                  3'd0,  queue_data[0].queue_struct.queue_msix_vector.word_bits[4:0], 
                                                  3'd0,  common_config.common_config_struct.msix_config.word_bits[4:0]};
            //FIXME: This is writing all vectors (including ones for device and other queues.)
            // Not properly parameterized. Have to manually update to match the number of queues used.
            nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
            nxt_q_dma_config_state               = WR_IRQ_MAP_REQ;
          end
        end
        WR_IRQ_MAP_REQ:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid & dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_IRQ_MAP_WAIT;
          end
          else if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            /* Have to wait for the address channel. */
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_IRQ_MAP_REQ_AW;
          end
          else if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            /* Have to wait for the write data channel. */
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_IRQ_MAP_REQ_W;
          end
        end
        WR_IRQ_MAP_REQ_AW:begin
          if(dma_engine_config_axil_awready & dma_engine_config_axil_awvalid)begin
            nxt_q_dma_engine_config_axil_awvalid = 1'b0;
            nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_0_0_00;
            nxt_q_dma_config_state               = WR_IRQ_MAP_WAIT;
          end
        end
        WR_IRQ_MAP_REQ_W:begin
          if(dma_engine_config_axil_wready & dma_engine_config_axil_wvalid)begin
            nxt_q_dma_engine_config_axil_wvalid  = 1'b0;
            nxt_q_dma_engine_config_axil_wdata   = 32'd0;
            nxt_q_dma_engine_config_axil_wstrb   = 4'b0000;
            nxt_q_dma_config_state               = WR_IRQ_MAP_WAIT;
          end
        end
        WR_IRQ_MAP_WAIT:begin
          if(dma_engine_config_axil_bvalid & dma_engine_config_axil_bready & dma_engine_config_axil_bresp == 2'b00)begin
            nxt_q_irq_configured   = 1'b1;
            nxt_q_usr_irq_req      = 4'b0001 << (q+1);
            nxt_q_dma_config_state = RAISE_Q_INT_REQ;
          end
        end
        RAISE_Q_INT_REQ:begin
          if(usr_irq_ack[q+1])begin
            nxt_q_usr_irq_req   = 4'b0000;
            //if(pcie_cfg_space.pcie_cfg_space_struct.activate_timers.dword_bits[0])begin
              nxt_timer_trx_end   = global_clock;
              nxt_timers_valid    = 32'd1;
            //end
            // If RX queue -> update descriptor table and inform the CPU; update configuration registers
            if(Q_DIR == RX)begin
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b001)begin // MM mode
                nxt_q_m_axil_awaddr    = (rx_desc_table_head == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size.dword_bits - 1) ?
                                         pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits :
                                         pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits + ((rx_desc_table_head+1) << 3);
                nxt_q_m_axil_awvalid   = 1'b1;
                nxt_q_m_axil_wdata     = last_trx_status[5] ? {4'hA, q_moved_data[27:0]} : {4'h8, q_moved_data[27:0]};
                nxt_q_m_axil_wstrb     = 4'b1111;
                nxt_q_m_axil_wvalid    = 1'b1;
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_q_dma_config_state = DSC_TAB_WR_MDATA_REQ;
              end
              else if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // virtIO mode
                nxt_q_dma_config_state = VQ_WR_DESC;
              end
              else begin
                nxt_q_m_axil_awaddr    = (rx_desc_table_head == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size.dword_bits - 1) ?
                                         pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits :
                                         pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits + ((rx_desc_table_head+1) << 3);
                nxt_q_m_axil_awvalid   = 1'b1;
                nxt_q_m_axil_wdata     = last_trx_status[5] ? {4'hA, q_moved_data[27:0]} : {4'h8, q_moved_data[27:0]};
                nxt_q_m_axil_wstrb     = 4'b1111;
                nxt_q_m_axil_wvalid    = 1'b1;
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_q_dma_config_state = DSC_TAB_WR_MDATA_REQ;
              end
            end
            else if(Q_DIR == TX)begin
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin // virtIO mode
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_q_dma_config_state = INTERRUPT_USR;
              end
              else begin
                nxt_q_avail_int_idx    = q_avail_int_idx + 16'd1;
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_q_dma_config_state = DEASSERT_REQ;
              end
            end
          end
        end
        VQ_WR_DESC:begin
          nxt_q_m_axil_awvalid   = 1'b1;
          nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_avail_rng_idx_mod << 4); // 16 Bytes/descriptor
          nxt_q_m_axil_wvalid    = 1'b1;
          nxt_q_m_axil_wdata     = current_buffer_start;
          nxt_q_m_axil_wstrb     = 4'b1111;
          nxt_q_dma_config_state = VQ_WR_DESC_ADDR;
        end
        VQ_WR_DESC_ADDR:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_AW;
          end
        end
        VQ_WR_DESC_ADDR_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_WAIT;
          end
        end
        VQ_WR_DESC_ADDR_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_WAIT;
          end
        end
        VQ_WR_DESC_ADDR_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_avail_rng_idx_mod << 4) + 32'd8;
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_m_axil_wdata     = q_moved_data;
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_dma_config_state = VQ_WR_DESC_LEN;
          end
        end
        VQ_WR_DESC_LEN:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_LEN_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_LEN_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_LEN_AW;
          end
        end
        VQ_WR_DESC_LEN_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_LEN_WAIT;
          end

        end
        VQ_WR_DESC_LEN_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_LEN_WAIT;
          end
        end
        VQ_WR_DESC_LEN_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_avail_rng_idx_mod << 4) + 32'd4;
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_H; // Upper half of address field
          end
        end
        VQ_WR_DESC_ADDR_H:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_H_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_H_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_H_AW;
          end
        end
        VQ_WR_DESC_ADDR_H_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_H_WAIT;
          end
        end
        VQ_WR_DESC_ADDR_H_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_ADDR_H_WAIT;
          end
        end
        VQ_WR_DESC_ADDR_H_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_avail_rng_idx_mod << 4) + 32'd12;
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_dma_config_state = VQ_WR_DESC_FN; // flags and next fields
          end
        end
        VQ_WR_DESC_FN:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_FN_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_FN_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_FN_AW;
          end
        end
        VQ_WR_DESC_FN_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_DESC_FN_WAIT;
          end
        end
        VQ_WR_DESC_FN_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_DESC_FN_WAIT;
          end
        end
        VQ_WR_DESC_FN_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = (pcie_cfg_space.pcie_cfg_space_struct.virtq_driver.dword_bits + 32'd4 + (usr_q_avail_rng_idx_mod << 1)) & 32'hFFFF_FFFC;
            nxt_q_m_axil_wvalid    = 1'b1;
            $display("time: %t, queue: %h, usr_q_avail_rng_idx: %h", $time, q, usr_q_avail_rng_idx);
            if(usr_q_avail_rng_idx[0] == 1'b1)begin
              nxt_q_m_axil_wdata     = {usr_q_avail_rng_idx_mod, 16'd0};
              nxt_q_m_axil_wstrb     = 4'b1100;
            end
            else begin
              nxt_q_m_axil_wdata     = {16'd0, usr_q_avail_rng_idx_mod};
              nxt_q_m_axil_wstrb     = 4'b0011;
            end
            nxt_q_dma_config_state = VQ_UPDATE_AVAIL_RNG;
          end
        end
        VQ_UPDATE_AVAIL_RNG:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_UPDATE_AVAIL_RNG_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_UPDATE_AVAIL_RNG_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_UPDATE_AVAIL_RNG_AW;
          end
        end
        VQ_UPDATE_AVAIL_RNG_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_UPDATE_AVAIL_RNG_WAIT;
          end
        end
        VQ_UPDATE_AVAIL_RNG_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_UPDATE_AVAIL_RNG_WAIT;
          end
        end
        VQ_UPDATE_AVAIL_RNG_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_driver.dword_bits;
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_m_axil_wdata     = {(usr_q_avail_rng_idx + 16'd1), 16'd0};
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_dma_config_state = VQ_WR_AVAIL_IDX; // Available ring index and flags fields
          end
        end
        VQ_WR_AVAIL_IDX:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_AVAIL_IDX_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_AVAIL_IDX_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_AVAIL_IDX_AW;
          end
        end
        VQ_WR_AVAIL_IDX_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_AVAIL_IDX_WAIT;
          end
        end
        VQ_WR_AVAIL_IDX_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_AVAIL_IDX_WAIT;
          end
        end
        VQ_WR_AVAIL_IDX_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            if(q_moved_data[1:0]!=2'b00)begin // Need to pad the pointer value to get 4-byte alighned address
              nxt_rx_buffer_head = (rx_buffer_head  + q_moved_data + (3'b100 - q_moved_data[1:0]) < rx_buff_end_addr) ?
                                    rx_buffer_head  + q_moved_data + (3'b100 - q_moved_data[1:0]) :
                                    rx_buffer_head  + q_moved_data + (3'b100 - q_moved_data[1:0]) - 
                                    pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
            end
            else begin // Already got a 4-byte aligned address
              nxt_rx_buffer_head = (rx_buffer_head + q_moved_data < rx_buff_end_addr) ?
                                    rx_buffer_head + q_moved_data :
                                    rx_buffer_head + q_moved_data -
                                    pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
            end
            nxt_usr_q_avail_rng_idx  = usr_q_avail_rng_idx + 16'd1;
            if(q_avail_int_idx + 1 == q_avail_rng_idx)begin // All buffers moved
              nxt_q_m_axil_awvalid   = 1'b1;
              nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_addr.dword_bits;
              nxt_q_m_axil_wvalid    = 1'b1;
              nxt_q_m_axil_wdata     = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_vector.dword_bits;
              nxt_q_m_axil_wstrb     = 4'b1111;
              nxt_q_dma_config_state = VQ_NOTIFY;
            end
            else begin
              nxt_q_avail_int_idx       = q_avail_int_idx + 16'd1;
              nxt_rx_q_check_avail_ring = 1'b1;
              nxt_q_dma_config_state    = RD_Q_AVAIL_RING_REQ_BUILD;
            end
          end
        end
        VQ_RD_AVAIL_IDX_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 3'b00)begin
            nxt_usr_q_avail_rng_idx  = m_axil_rdata[q][31:16];
            if(usr_q_avail_rng_int_idx == m_axil_rdata[q][31:16])begin // No new buffers exposed
              nxt_q_dma_config_state = DEASSERT_REQ;
            end
            else begin
              nxt_q_dma_config_state = VQ_RD_AVAIL_RNG;
            end
          end
        end
        VQ_RD_AVAIL_RNG:begin
          nxt_q_m_axil_arvalid   = 1'b1;
          nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_driver.dword_bits + 32'd4 + ((usr_q_avail_rng_int_idx % QUEUE_SIZE) << 1); // 2 Bytes per ring entry
          nxt_q_dma_config_state = VQ_RD_AVAIL_RNG_REQ;
        end
        VQ_RD_AVAIL_RNG_REQ:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_dma_config_state = VQ_RD_AVAIL_RNG_WAIT;
          end
        end
        VQ_RD_AVAIL_RNG_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 2'b00)begin
            if(q_m_axil_araddr[1])begin
              nxt_usr_q_desc_idx = m_axil_rdata[q][31:16];
            end
            else begin
              nxt_usr_q_desc_idx = m_axil_rdata[q][15:0];
            end
            nxt_q_dma_config_state = VQ_RD_DESC1;
          end
        end
        VQ_RD_DESC1:begin
          nxt_q_m_axil_arvalid = 1'b1;
          nxt_q_m_axil_araddr  = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_desc_idx << 4);
          nxt_q_dma_config_state = VQ_RD_DESC1_REQ;
        end
        VQ_RD_DESC1_REQ:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_DESC1_WAIT;
          end
        end
        VQ_RD_DESC1_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 2'b00)begin
            nxt_usr_q_desc[31:0]   = m_axil_rdata[q];
            nxt_q_m_axil_arvalid   = 1'b1;
            nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_desc_idx << 4) + 32'd4;
            nxt_q_dma_config_state = VQ_RD_DESC2_REQ;
          end
        end
        VQ_RD_DESC2_REQ:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_DESC2_WAIT;
          end
        end
        VQ_RD_DESC2_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 2'b00)begin
            nxt_usr_q_desc[63:32]  = m_axil_rdata[q];
            nxt_q_m_axil_arvalid   = 1'b1;
            nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_desc_idx << 4) + 32'd8;
            nxt_q_dma_config_state = VQ_RD_DESC3_REQ;
          end
        end
        VQ_RD_DESC3_REQ:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_DESC3_WAIT;
          end
        end
        VQ_RD_DESC3_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 2'b00)begin
            nxt_usr_q_desc[95:64]  = m_axil_rdata[q];
            nxt_q_m_axil_arvalid   = 1'b1;
            nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_desc.dword_bits + (usr_q_desc_idx << 4) + 32'd12;
            nxt_q_dma_config_state = VQ_RD_DESC4_REQ;
          end
        end
        VQ_RD_DESC4_REQ:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = VQ_RD_DESC4_WAIT;
          end
        end
        VQ_RD_DESC4_WAIT:begin
          if(m_axil_rvalid[q] & m_axil_rready[q] & m_axil_rresp[q] == 2'b00)begin
            nxt_usr_q_desc[127:96]     = m_axil_rdata[q];
            nxt_mm_tx_remaining_bytes  = usr_q_desc[95:64];
            nxt_q_h2c_dsc_byp_load     = 1'b1;
            nxt_q_h2c_dsc_byp_src_addr = queue_data[q].queue_struct.queue_driver;
            nxt_q_h2c_dsc_byp_dst_addr = 64'd0;
            nxt_q_h2c_dsc_byp_len      = 28'd4;    // Read flags and idx
            nxt_q_h2c_dsc_byp_ctl      = 16'h0001; // Stop bit set
            nxt_q_dma_config_state     = RD_Q_AVAIL_IDX_REQ;
          end
        end
        VQ_WR_USED_RNG_ELM_ID:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_ID_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_ID_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_ID_AW;
          end
        end
        VQ_WR_USED_RNG_ELM_ID_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_ID_WAIT;
          end
        end
        VQ_WR_USED_RNG_ELM_ID_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_ID_WAIT;
          end
        end
        VQ_WR_USED_RNG_ELM_ID_WAIT:begin
          if(m_axil_bready[q] & m_axil_bvalid[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_device.dword_bits + 32'd4 + ((usr_q_avail_rng_int_idx % QUEUE_SIZE) << 3) + 32'd4; // 8 Bytes per entry
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_m_axil_wdata     = q_moved_data;
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_LEN;
          end
        end
        VQ_WR_USED_RNG_ELM_LEN:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_LEN_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_LEN_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_LEN_AW;
          end
        end
        VQ_WR_USED_RNG_ELM_LEN_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_LEN_WAIT;
          end
        end
        VQ_WR_USED_RNG_ELM_LEN_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_ELM_LEN_WAIT;
          end
        end
        VQ_WR_USED_RNG_ELM_LEN_WAIT:begin
          if(m_axil_bready[q] & m_axil_bvalid[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_device.dword_bits;
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_m_axil_wdata     = {(usr_q_avail_rng_int_idx + 16'd1),16'd0};
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_IDX;
          end
        end
        VQ_WR_USED_RNG_IDX:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_IDX_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_IDX_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_IDX_AW;
          end
        end
        VQ_WR_USED_RNG_IDX_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_IDX_WAIT;
          end
        end
        VQ_WR_USED_RNG_IDX_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_WR_USED_RNG_IDX_WAIT;
          end
        end
        VQ_WR_USED_RNG_IDX_WAIT:begin
          if(m_axil_bready[q] & m_axil_bvalid[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_usr_q_avail_rng_int_idx = usr_q_avail_rng_int_idx + 16'd1;
            if(usr_q_avail_rng_int_idx + 16'd1 == usr_q_avail_rng_idx)begin // No more buffers exposed
              if(|irq_configured)begin
                nxt_q_usr_irq_req      = 4'b0001 << (q+1);
                nxt_q_dma_config_state = RAISE_Q_INT_REQ;
              end
              else begin  // Configure the interrupts.
                nxt_q_dma_engine_config_axil_awvalid = 1'b1;
                nxt_q_dma_engine_config_axil_awaddr  = 32'h0000_2_0_08; // W1S for 0x2004
                nxt_q_dma_engine_config_axil_wvalid  = 1'b1;
                // If you are the controller to first setup the IRQs, setup for everyone.
                // FIXME: Move the general configuration interrupt out of the queue controller later when rest of the logic is fully implemented.
                nxt_q_dma_engine_config_axil_wdata   = (32'h00000001 << (NUM_QUEUES+1)) - 32'd1;
                nxt_q_dma_engine_config_axil_wstrb   = 4'b1111;
                nxt_q_dma_config_state               = WR_IRQ_ENABLE_REQ;
              end
            end
            else begin
              nxt_last_trx_status[5] = 1'b1;
              nxt_q_avail_int_idx    = q_avail_int_idx + 16'd1;
              nxt_q_dma_config_state = VQ_RD_AVAIL_RNG;
            end
          end
        end
        VQ_NOTIFY:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_NOTIFY_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_NOTIFY_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_NOTIFY_AW;
          end
        end
        VQ_NOTIFY_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = VQ_NOTIFY_WAIT;
          end
        end
        VQ_NOTIFY_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = VQ_NOTIFY_WAIT;
          end
        end
        VQ_NOTIFY_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            if(Q_DIR == RX)begin
              // Go back and move more buffers if available
              nxt_q_avail_int_idx       = q_avail_int_idx + 16'd1;
              nxt_rx_q_check_avail_ring = 1'b1;
              nxt_q_dma_config_state    = RD_Q_AVAIL_RING_REQ_BUILD;
            end
            else begin // TX
              if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd[2:0] == 3'b100)begin // VirtIO
                nxt_q_avail_int_idx       = q_avail_int_idx + 16'd1;
                nxt_q_m_axil_araddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_driver.dword_bits; // PCIe controller acts as device for TX requests.
                nxt_q_m_axil_arvalid   = 1'b1;
                nxt_q_dma_config_state = VQ_RD_AVAIL_IDX;
              end
              else begin
                nxt_q_dma_config_state = DEASSERT_REQ;
              end
            end
          end
        end
        DSC_TAB_WR_MDATA_REQ:begin
          /* 
          // Release the DMA engine control as the controller no longer needs to move data to/from host
          nxt_q_request = 1'b0;
          */
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_MDATA_WAIT;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_MDATA_WAIT_AW;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_MDATA_WAIT_W;
          end
        end
        DSC_TAB_WR_MDATA_WAIT_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_MDATA_WAIT;
          end
        end
        DSC_TAB_WR_MDATA_WAIT_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_MDATA_WAIT;
          end
        end
        DSC_TAB_WR_MDATA_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_q_m_axil_awaddr  = (rx_desc_table_head == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size.dword_bits - 1) ?
                                   pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits + 32'd4 :
                                   pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr.dword_bits + ((rx_desc_table_head+1) << 3) + 32'd4;
            nxt_q_m_axil_awvalid   = 1'b1;
            nxt_q_m_axil_wdata     = current_buffer_start;
            nxt_q_m_axil_wstrb     = 4'b1111;
            nxt_q_m_axil_wvalid    = 1'b1;
            nxt_q_dma_config_state = DSC_TAB_WR_ADDR_REQ;
          end
        end
        DSC_TAB_WR_ADDR_REQ:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_ADDR_WAIT;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_ADDR_WAIT_AW;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_ADDR_WAIT_W;
          end
        end
        DSC_TAB_WR_ADDR_WAIT_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_ADDR_WAIT;
          end
        end
        DSC_TAB_WR_ADDR_WAIT_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_dma_config_state = DSC_TAB_WR_ADDR_WAIT;
          end
        end
        DSC_TAB_WR_ADDR_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            nxt_rx_desc_table_head = (rx_desc_table_head == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size.dword_bits - 1) ?
                                      32'd0 : rx_desc_table_head + 32'd1;
            if(q_moved_data[1:0]!=2'b00)begin // Need to pad the pointer value to get 4-byte alighned address
              nxt_rx_buffer_head = (rx_buffer_head  + q_moved_data + (3'b100 - q_moved_data[1:0]) < rx_buff_end_addr) ?
                                    rx_buffer_head  + q_moved_data + (3'b100 - q_moved_data[1:0]) :
                                    rx_buffer_head  + q_moved_data + (3'b100 - q_moved_data[1:0]) - 
                                    pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
            end
            else begin // Already got a 4-byte aligned address
              nxt_rx_buffer_head = (rx_buffer_head + q_moved_data < rx_buff_end_addr) ?
                                    rx_buffer_head + q_moved_data :
                                    rx_buffer_head + q_moved_data -
                                    pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
            end
            nxt_q_dma_config_state = INTERRUPT_USR;
          end
        end
        INTERRUPT_USR:begin
          if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd[5])begin // polling mode
            if(pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd[2:0] == 3'b100)begin // VirtIO interface used
              nxt_q_m_axil_awvalid   = 1'b1;
              nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_addr.dword_bits;
              nxt_q_m_axil_wvalid    = 1'b1;
              nxt_q_m_axil_wdata     = pcie_cfg_space.pcie_cfg_space_struct.virtq_notify_vector.dword_bits;
              nxt_q_m_axil_wstrb     = 4'b1111;
              nxt_q_dma_config_state = VQ_NOTIFY;
            end
            else begin
              nxt_q_m_axil_awvalid   = 1'b1;
              nxt_q_m_axil_awaddr    = pcie_cfg_space.pcie_cfg_space_struct.mm_poll_addr.dword_bits;
              nxt_q_m_axil_wvalid    = 1'b1;
              nxt_q_m_axil_wdata     = pcie_cfg_space.pcie_cfg_space_struct.mm_poll_wr_val;
              nxt_q_m_axil_wstrb     = 4'hf;
              nxt_q_dma_config_state = WRITE_POLL_VAL;
            end
          end
          else begin // interrupt mode
            nxt_q_interrupt_usr    = 1'b1;
            nxt_q_dma_config_state = INTERRUPT_USR_WAIT;
          end
        end
        WRITE_POLL_VAL:begin
          if(m_axil_awvalid[q] & m_axil_awready[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'h0;
            nxt_q_dma_config_state = WRITE_POLL_VAL_WAIT;
          end
          else if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = WRITE_POLL_VAL_WAIT_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'h0;
            nxt_q_dma_config_state = WRITE_POLL_VAL_WAIT_AW;
          end
        end
        WRITE_POLL_VAL_WAIT_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'h0;
            nxt_q_dma_config_state = WRITE_POLL_VAL_WAIT;
          end
        end
        WRITE_POLL_VAL_WAIT_AW:begin
          if(m_axil_awvalid[q] & m_axil_awready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = WRITE_POLL_VAL_WAIT;
          end
        end
        WRITE_POLL_VAL_WAIT:begin
          if(Q_DIR == RX)begin
            // Go back and move more buffers if available
            nxt_q_avail_int_idx       = q_avail_int_idx + 16'd1;
            nxt_rx_q_check_avail_ring = 1'b1;
            nxt_q_dma_config_state    = RD_Q_AVAIL_RING_REQ_BUILD;
          end
          else begin
            //FIXME: might have to increment q_avail_int_idx here.
            nxt_q_dma_config_state = DEASSERT_REQ;
          end
        end
        INTERRUPT_USR_WAIT:begin
          if(interrupt_usr[q] & interrupt_usr_ack[q])begin
            nxt_q_interrupt_usr    = 1'b0;
            if(Q_DIR == RX)begin
              // Go back and move more buffers if available
              nxt_q_avail_int_idx       = q_avail_int_idx + 16'd1;
              nxt_rx_q_check_avail_ring = 1'b1;
              nxt_q_dma_config_state    = RD_Q_AVAIL_RING_REQ_BUILD;
            end
            else if(Q_DIR == TX & pcie_cfg_space.pcie_cfg_space_struct.pcie_cmd.dword_bits[2:0] == 3'b100)begin
              nxt_q_avail_int_idx       = q_avail_int_idx + 16'd1;
              nxt_q_dma_config_state    = VQ_RD_AVAIL_RNG;
            end
            else begin
              nxt_q_dma_config_state = DEASSERT_REQ;
            end
          end
        end
        DESC_TAB_CLEANUP:begin
          nxt_q_m_axil_arvalid   = 1'b1;
          nxt_q_m_axil_araddr    = (rx_desc_table_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size - 1) ?
                                    pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr : 
                                    pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr + ((rx_desc_table_tail + 32'd1) << 3);
          nxt_q_dma_config_state = DESC_TAB_CLEANUP_RD_MDATA;
        end
        DESC_TAB_CLEANUP_RD_MDATA:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_m_axil_araddr    = 32'd0;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_RD_MDATA_WAIT;
          end
        end
        DESC_TAB_CLEANUP_RD_MDATA_WAIT:begin
          if(m_axil_rready[q] & m_axil_rvalid[q] & m_axil_rresp[q] == 2'b00)begin
            if(m_axil_rdata[q][31:30] == 2'b10)begin // Buffer is not consumed by user logic yet
              if(reclaimed_descs == 0)begin // Unable to clean up any descriptor table entries
                // Release DMA engine and goto sleep
                nxt_q_endpoint_ctrl    = 1'b1;
                nxt_q_request          = 1'b0;
                nxt_sleep_mode         = TIMER;
                nxt_goto_state         = DESC_TAB_CLEANUP;
                nxt_sleep_timer        = SLEEP_TIMER_VAL;
                nxt_q_dma_config_state = SLEEP;
              end
              else begin  // At least one table entry was reclaimed.
                nxt_q_dma_config_state = Q_MOVE_DATA; 
              end
            end
            else if(m_axil_rdata[q][31:30] == 2'b11)begin // Buffer consumed by user logic. Okay to cleanup.
              nxt_q_m_axil_arvalid   = 1'b1;
              nxt_q_m_axil_araddr    = (rx_desc_table_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size - 1) ?
                                        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr + 32'd4 : 
                                        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr + ((rx_desc_table_tail + 32'd1) << 3) + 32'd4;
              nxt_reclaimed_buf_size = m_axil_rdata[q][27:0];
              nxt_q_dma_config_state = DESC_TAB_CLEANUP_RD_SIZE;
            end
            else if(m_axil_rdata[q][31:30] == 1'b00)begin // Either the entry is never used, or already cleaned up and we are wrapping around the table
              nxt_q_dma_config_state = Q_MOVE_DATA; 
            end
            else if(m_axil_rdata[q][31:30] == 1'b01)begin // Should never get here.
              nxt_q_endpoint_ctrl    = 1'b1;
              nxt_last_trx_status    = 6'b111111;  // Unknown error
              nxt_q_dma_config_state = DEASSERT_REQ;
            end
          end
        end
        DESC_TAB_CLEANUP_RD_SIZE:begin
          if(m_axil_arvalid[q] & m_axil_arready[q])begin
            nxt_q_m_axil_arvalid   = 1'b0;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_RD_SIZE_WAIT;
          end
        end
        DESC_TAB_CLEANUP_RD_SIZE_WAIT:begin
          if(m_axil_rready[q] & m_axil_rvalid[q] & m_axil_rresp[q] == 2'b00)begin
            // Update buffer tail pointer
            if(reclaimed_buf_size[1:0] != 2'b00)begin
              if((rx_buffer_tail + reclaimed_buf_size + (3'b100 - reclaimed_buf_size[1:0]) == head_ptr_wraparound_addr) & head_ptr_wraparound)begin
                nxt_rx_buffer_tail      = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                nxt_head_ptr_wraparound = 1'b0;
              end
              else begin
                nxt_rx_buffer_tail = (rx_buffer_tail + reclaimed_buf_size + (3'b100 - reclaimed_buf_size[1:0]) < rx_buff_end_addr) ?
                                      rx_buffer_tail + reclaimed_buf_size + (3'b100 - reclaimed_buf_size[1:0]) :
                                      rx_buffer_tail + reclaimed_buf_size + (3'b100 - reclaimed_buf_size[1:0]) -
                                      pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
              end
            end
            else begin
              if((rx_buffer_tail + reclaimed_buf_size == head_ptr_wraparound_addr) & head_ptr_wraparound)begin
                nxt_rx_buffer_tail      = pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_addr.dword_bits;
                nxt_head_ptr_wraparound = 1'b0;
              end
              else begin
                nxt_rx_buffer_tail = (rx_buffer_tail + reclaimed_buf_size < rx_buff_end_addr) ?
                                      rx_buffer_tail + reclaimed_buf_size :
                                      rx_buffer_tail + reclaimed_buf_size -
                                      pcie_cfg_space.pcie_cfg_space_struct.mm_rx_buffer_size.dword_bits;
              end
            end
            nxt_q_m_axil_arvalid     = 1'b0;
            nxt_q_m_axil_awvalid     = 1'b1;
            nxt_q_m_axil_awaddr      = (rx_desc_table_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size - 1) ?
                                        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr : 
                                        pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_addr + ((rx_desc_table_tail + 32'd1) << 3);
            nxt_q_m_axil_wvalid      = 1'b1;
            nxt_q_m_axil_wdata       = 32'd0;
            nxt_q_m_axil_wstrb       = 4'b1111;
            nxt_q_dma_config_state   = DESC_TAB_CLEANUP_WR_MDATA;
          end
        end
        DESC_TAB_CLEANUP_WR_MDATA:begin
          if(m_axil_awready[q] & m_axil_awvalid[q] & m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_WR_MDATA_WAIT;
          end
          else if(m_axil_awready[q] & m_axil_awvalid[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_WR_MDATA_WAIT_W;
          end
          else if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_WR_MDATA_WAIT_AW;
          end
        end
        DESC_TAB_CLEANUP_WR_MDATA_WAIT_W:begin
          if(m_axil_wvalid[q] & m_axil_wready[q])begin
            nxt_q_m_axil_wvalid    = 1'b0;
            nxt_q_m_axil_wdata     = 32'd0;
            nxt_q_m_axil_wstrb     = 4'b0000;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_WR_MDATA_WAIT;
          end
        end
        DESC_TAB_CLEANUP_WR_MDATA_WAIT_AW:begin
          if(m_axil_awready[q] & m_axil_awvalid[q])begin
            nxt_q_m_axil_awvalid   = 1'b0;
            nxt_q_m_axil_awaddr    = 32'd0;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP_WR_MDATA_WAIT;
          end
        end
        DESC_TAB_CLEANUP_WR_MDATA_WAIT:begin
          if(m_axil_bvalid[q] & m_axil_bready[q] & m_axil_bresp[q] == 2'b00)begin
            // Update descriptor table tail pointer
            if(rx_desc_table_tail == pcie_cfg_space.pcie_cfg_space_struct.mm_rx_desc_table_size - 1)begin
              nxt_rx_desc_table_tail = 32'd0;
            end
            else begin
              nxt_rx_desc_table_tail = rx_desc_table_tail + 32'd1;
            end
            nxt_reclaimed_descs = reclaimed_descs + 32'd1;
            nxt_q_dma_config_state = DESC_TAB_CLEANUP; 
          end
        end
        SLEEP:begin
          if(sleep_mode == TIMER)begin
            if(sleep_timer == 0)begin
              nxt_q_request          = 1'b1;
              nxt_q_dma_config_state = REACQUIRE_ACCESS;
            end
            else begin
              nxt_sleep_timer = sleep_timer - 1;
            end
          end
          // TODO: User mode is not useful with the current use modes supported. Implement later.
          /* User mode is used when the controller interrupts the user logic and expects user logic
             to perform some task and inform the controller when it is done. A bit in the command
             register will be written to by user logic to notify the controller. */
        end
        REACQUIRE_ACCESS:begin
          if(q_grant == q & arb_valid)begin
            nxt_q_dma_config_state = goto_state;
          end
        end
        DEASSERT_REQ:begin
          nxt_q_request          = 1'b0;
          nxt_q_dma_config_state = DMA_IDLE;
        end
      endcase
    end
  end
endgenerate


// Multiplexing the controller signals
    logic [NUM_QUEUES-1:0][63 :0] mux_c2h_dsc_byp_src_addr_0;
    logic [NUM_QUEUES-1:0][63 :0] mux_c2h_dsc_byp_dst_addr_0;
    logic [NUM_QUEUES-1:0][27 :0] mux_c2h_dsc_byp_len_0;
    logic [NUM_QUEUES-1:0][15 :0] mux_c2h_dsc_byp_ctl_0;
    logic [NUM_QUEUES-1:0]        mux_c2h_dsc_byp_load_0;
    logic [NUM_QUEUES-1:0][63 :0] mux_h2c_dsc_byp_src_addr_0;
    logic [NUM_QUEUES-1:0][63 :0] mux_h2c_dsc_byp_dst_addr_0;
    logic [NUM_QUEUES-1:0][27 :0] mux_h2c_dsc_byp_len_0;
    logic [NUM_QUEUES-1:0][15 :0] mux_h2c_dsc_byp_ctl_0;
    logic [NUM_QUEUES-1:0]        mux_h2c_dsc_byp_load_0;
    logic [NUM_QUEUES-1:0][31 :0] mux_dma_engine_config_axil_awaddr;
    logic [NUM_QUEUES-1:0]        mux_dma_engine_config_axil_awvalid;
    logic [NUM_QUEUES-1:0][31 :0] mux_dma_engine_config_axil_wdata;
    logic [NUM_QUEUES-1:0][3  :0] mux_dma_engine_config_axil_wstrb;
    logic [NUM_QUEUES-1:0]        mux_dma_engine_config_axil_wvalid;
    logic [NUM_QUEUES-1:0]        mux_dma_engine_config_axil_bready;
    logic [NUM_QUEUES-1:0][31 :0] mux_dma_engine_config_axil_araddr;
    logic [NUM_QUEUES-1:0]        mux_dma_engine_config_axil_arvalid;
    logic [NUM_QUEUES-1:0]        mux_dma_engine_config_axil_rready;
    logic [NUM_QUEUES-1:0]        mux_endpoint_ctrl;
    logic [NUM_QUEUES-1:0]        mux_s_axi_awready;
    logic [NUM_QUEUES-1:0]        mux_s_axi_wready;
    logic [NUM_QUEUES-1:0][1  :0] mux_s_axi_bresp;
    logic [NUM_QUEUES-1:0]        mux_s_axi_arready;
    logic [NUM_QUEUES-1:0][1  :0] mux_s_axi_rresp;
    logic [NUM_QUEUES-1:0]        mux_s_axi_bvalid;
    logic [NUM_QUEUES-1:0][127:0] mux_s_axi_rdata;
    logic [NUM_QUEUES-1:0]        mux_s_axi_rlast;
    logic [NUM_QUEUES-1:0]        mux_s_axi_rvalid;
    logic [NUM_QUEUES-1:0][3:0]   mux_usr_irq_req;


genvar g;

generate
  for(g=0; g<NUM_QUEUES; g++)begin
    assign mux_c2h_dsc_byp_src_addr_0[g]         = queue_ctrl_loop[g].q_c2h_dsc_byp_src_addr;
    assign mux_c2h_dsc_byp_dst_addr_0[g]         = queue_ctrl_loop[g].q_c2h_dsc_byp_dst_addr;
    assign mux_c2h_dsc_byp_len_0[g]              = queue_ctrl_loop[g].q_c2h_dsc_byp_len;
    assign mux_c2h_dsc_byp_ctl_0[g]              = queue_ctrl_loop[g].q_c2h_dsc_byp_ctl;
    assign mux_c2h_dsc_byp_load_0[g]             = queue_ctrl_loop[g].q_c2h_dsc_byp_load;
    assign mux_h2c_dsc_byp_src_addr_0[g]         = queue_ctrl_loop[g].q_h2c_dsc_byp_src_addr;
    assign mux_h2c_dsc_byp_dst_addr_0[g]         = queue_ctrl_loop[g].q_h2c_dsc_byp_dst_addr;
    assign mux_h2c_dsc_byp_len_0[g]              = queue_ctrl_loop[g].q_h2c_dsc_byp_len;
    assign mux_h2c_dsc_byp_ctl_0[g]              = queue_ctrl_loop[g].q_h2c_dsc_byp_ctl;
    assign mux_h2c_dsc_byp_load_0[g]             = queue_ctrl_loop[g].q_h2c_dsc_byp_load;
    assign mux_dma_engine_config_axil_awaddr[g]  = queue_ctrl_loop[g].q_dma_engine_config_axil_awaddr;
    assign mux_dma_engine_config_axil_awvalid[g] = queue_ctrl_loop[g].q_dma_engine_config_axil_awvalid;
    assign mux_dma_engine_config_axil_wdata[g]   = queue_ctrl_loop[g].q_dma_engine_config_axil_wdata;
    assign mux_dma_engine_config_axil_wstrb[g]   = queue_ctrl_loop[g].q_dma_engine_config_axil_wstrb;
    assign mux_dma_engine_config_axil_wvalid[g]  = queue_ctrl_loop[g].q_dma_engine_config_axil_wvalid;
    assign mux_dma_engine_config_axil_bready[g]  = queue_ctrl_loop[g].q_dma_engine_config_axil_bready;
    assign mux_dma_engine_config_axil_araddr[g]  = queue_ctrl_loop[g].q_dma_engine_config_axil_araddr;
    assign mux_dma_engine_config_axil_arvalid[g] = queue_ctrl_loop[g].q_dma_engine_config_axil_arvalid;
    assign mux_dma_engine_config_axil_rready[g]  = queue_ctrl_loop[g].q_dma_engine_config_axil_rready;
    assign mux_endpoint_ctrl[g]                  = queue_ctrl_loop[g].q_endpoint_ctrl;
    assign mux_s_axi_awready[g]                  = queue_ctrl_loop[g].q_s_axi_awready;
    assign mux_s_axi_wready[g]                   = queue_ctrl_loop[g].q_s_axi_wready;
    assign mux_s_axi_bresp[g]                    = queue_ctrl_loop[g].q_s_axi_bresp;
    assign mux_s_axi_arready[g]                  = queue_ctrl_loop[g].q_s_axi_arready;
    assign mux_s_axi_rresp[g]                    = queue_ctrl_loop[g].q_s_axi_rresp;
    assign mux_s_axi_bvalid[g]                   = queue_ctrl_loop[g].q_s_axi_bvalid;
    assign mux_s_axi_rdata[g]                    = queue_ctrl_loop[g].q_s_axi_rdata;
    assign mux_s_axi_rlast[g]                    = queue_ctrl_loop[g].q_s_axi_rlast;
    assign mux_s_axi_rvalid[g]                   = queue_ctrl_loop[g].q_s_axi_rvalid;
    assign mux_usr_irq_req[g]                    = queue_ctrl_loop[g].q_usr_irq_req;
  end
endgenerate

always_comb begin
  if(!arb_valid)begin
    c2h_dsc_byp_src_addr_0         = 64'd0;
    c2h_dsc_byp_dst_addr_0         = 64'd0;
    c2h_dsc_byp_len_0              = 28'd0;
    c2h_dsc_byp_ctl_0              = 16'd0;
    c2h_dsc_byp_load_0             = 1'b0;
    h2c_dsc_byp_src_addr_0         = 64'd0;
    h2c_dsc_byp_dst_addr_0         = 64'd0;
    h2c_dsc_byp_len_0              = 28'd0;
    h2c_dsc_byp_ctl_0              = 16'd0;
    h2c_dsc_byp_load_0             = 1'b0;
    dma_engine_config_axil_awaddr  = 32'd0;
    dma_engine_config_axil_awvalid = 1'b0;
    dma_engine_config_axil_wdata   = 32'd0;
    dma_engine_config_axil_wstrb   = 4'd0;
    dma_engine_config_axil_wvalid  = 1'b0;
    dma_engine_config_axil_bready  = 1'b0;
    dma_engine_config_axil_araddr  = 32'd0;
    dma_engine_config_axil_arvalid = 1'b0;
    dma_engine_config_axil_rready  = 1'b0;
    endpoint_ctrl                  = 1'b1;
    s_axi_awready                  = 1'b0;
    s_axi_wready                   = 1'b0;
    s_axi_bresp                    = 2'b00;
    s_axi_arready                  = 1'b0;
    s_axi_rresp                    = 2'b00;
    s_axi_bvalid                   = 1'b0;
    s_axi_rdata                    = 128'd0;
    s_axi_rlast                    = 1'b0;
    s_axi_rvalid                   = 1'b0;
    usr_irq_req                    = 4'd0;
  end
  else begin
    c2h_dsc_byp_src_addr_0         = mux_c2h_dsc_byp_src_addr_0[q_grant];
    c2h_dsc_byp_dst_addr_0         = mux_c2h_dsc_byp_dst_addr_0[q_grant];
    c2h_dsc_byp_len_0              = mux_c2h_dsc_byp_len_0[q_grant];
    c2h_dsc_byp_ctl_0              = mux_c2h_dsc_byp_ctl_0[q_grant];
    c2h_dsc_byp_load_0             = mux_c2h_dsc_byp_load_0[q_grant];
    h2c_dsc_byp_src_addr_0         = mux_h2c_dsc_byp_src_addr_0[q_grant];
    h2c_dsc_byp_dst_addr_0         = mux_h2c_dsc_byp_dst_addr_0[q_grant];
    h2c_dsc_byp_len_0              = mux_h2c_dsc_byp_len_0[q_grant];
    h2c_dsc_byp_ctl_0              = mux_h2c_dsc_byp_ctl_0[q_grant];
    h2c_dsc_byp_load_0             = mux_h2c_dsc_byp_load_0[q_grant];
    dma_engine_config_axil_awaddr  = mux_dma_engine_config_axil_awaddr[q_grant];
    dma_engine_config_axil_awvalid = mux_dma_engine_config_axil_awvalid[q_grant];
    dma_engine_config_axil_wdata   = mux_dma_engine_config_axil_wdata[q_grant];
    dma_engine_config_axil_wstrb   = mux_dma_engine_config_axil_wstrb[q_grant];
    dma_engine_config_axil_wvalid  = mux_dma_engine_config_axil_wvalid[q_grant];
    dma_engine_config_axil_bready  = mux_dma_engine_config_axil_bready[q_grant];
    dma_engine_config_axil_araddr  = mux_dma_engine_config_axil_araddr[q_grant];
    dma_engine_config_axil_arvalid = mux_dma_engine_config_axil_arvalid[q_grant];
    dma_engine_config_axil_rready  = mux_dma_engine_config_axil_rready[q_grant];
    endpoint_ctrl                  = mux_endpoint_ctrl[q_grant];
    s_axi_awready                  = mux_s_axi_awready[q_grant];
    s_axi_wready                   = mux_s_axi_wready[q_grant];
    s_axi_bresp                    = mux_s_axi_bresp[q_grant];
    s_axi_arready                  = mux_s_axi_arready[q_grant];
    s_axi_rresp                    = mux_s_axi_rresp[q_grant];
    s_axi_bvalid                   = mux_s_axi_bvalid[q_grant];
    s_axi_rdata                    = mux_s_axi_rdata[q_grant];
    s_axi_rlast                    = mux_s_axi_rlast[q_grant];
    s_axi_rvalid                   = mux_s_axi_rvalid[q_grant];
    usr_irq_req                    = mux_usr_irq_req[q_grant];
  end
end


generate
  for(g=0; g<NUM_QUEUES; g++)begin
    assign m_axil_awaddr[g]  = queue_ctrl_loop[g].q_m_axil_awaddr;
    assign m_axil_awvalid[g] = queue_ctrl_loop[g].q_m_axil_awvalid;
    assign m_axil_wdata[g]   = queue_ctrl_loop[g].q_m_axil_wdata;
    assign m_axil_wstrb[g]   = queue_ctrl_loop[g].q_m_axil_wstrb;
    assign m_axil_wvalid[g]  = queue_ctrl_loop[g].q_m_axil_wvalid;
    assign m_axil_bready[g]  = queue_ctrl_loop[g].q_m_axil_bready;
    assign m_axil_araddr[g]  = queue_ctrl_loop[g].q_m_axil_araddr;
    assign m_axil_arvalid[g] = queue_ctrl_loop[g].q_m_axil_arvalid;
    assign m_axil_rready[g]  = queue_ctrl_loop[g].q_m_axil_rready;
    assign interrupt_usr[g]  = queue_ctrl_loop[g].q_interrupt_usr;
  end
endgenerate


// Logic to support counting the number of bytes moved in H2C transfers
logic [4:0] byte_count;
integer iterator;

always_comb begin
  byte_count = 5'd0;
  for(iterator=0; iterator<16; iterator=iterator+1)begin
    byte_count = byte_count + s_axi_wstrb_to_mem[iterator];
  end
end


// IRQ configugred signal
generate
  for(g=0; g<NUM_QUEUES; g++)begin
    assign irq_configured[g] = queue_ctrl_loop[g].q_irq_configured;
  end
endgenerate


// Continuous assignments.
assign write_compl = {pci_cfg_wr_compl, isr_wr_compl, notify_wr_compl, comm_cfg_wr_compl};

assign comm_cfg_wr_dword_addr = write_addr[5:2];
assign queue_data_wr_addr = comm_cfg_wr_dword_addr - 4'd6;

endmodule
