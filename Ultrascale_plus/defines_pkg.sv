// =============================================================================
//
// Author      : Sahan Bandara
// Filename    : defines_pkg.sv
// Description : Package including type definitions.
// 
// =============================================================================



`ifndef __DEFINES_PKG__
 `define __DEFINES_PKG__

package defines_pkg;

  typedef logic [7:0] byte_t;

  typedef union packed {
    logic  [15:0] word_bits;
    byte_t [1 :0] word_bytes;
  } word_t;

  typedef union packed {
    logic  [31:0] dword_bits;
    byte_t [3 :0] dword_bytes;
    word_t [1 :0] dword_words;
  } dword_t;

  typedef union packed {
    logic   [63:0] qword_bits;
    byte_t  [7 :0] qword_bytes;
    word_t  [3 :0] qword_words;
    dword_t [1 :0] qword_dwords;
  } qword_t;

  /* Common configuration data structure */
  typedef struct packed {
    qword_t queue_device;          /* rw */ // 0x30 - 0x37
    qword_t queue_driver;          /* rw */ // 0x28 - 0x2F
    qword_t queue_desc;            /* rw */ // 0x20 - 0x27
    word_t  queue_notify_off;      /* ro */ // 0x1E - 0x1F
    word_t  queue_enable;          /* rw */ // 0x1C - 0x1D
    word_t  queue_msix_vector;     /* rw */ // 0x1A - 0x1B
    word_t  queue_size;            /* rw */ // 0x18 - 0x19
    word_t  queue_select;          /* rw */ // 0x16 - 0x17
    byte_t  config_generation;     /* ro */ // 0x15
    byte_t  device_status;         /* rw */ // 0x14
    word_t  num_queues;            /* ro */ // 0x12 - 0x13
    word_t  msix_config;           /* rw */ // 0x10 - 0x11
    dword_t driver_feature;        /* rw */ // 0x0C - 0x0F
    dword_t driver_feature_select; /* rw */ // 0x08 - 0x0B
    dword_t device_feature;        /* ro */ // 0x04 - 0x07
    dword_t device_feature_select; /* rw */ // 0x00 - 0x03
  } common_config_t;

  // Duplicated configuration registers for individual queues (part of common config. structure)
  typedef struct packed {
    qword_t queue_device;      /* rw */  
    qword_t queue_driver;      /* rw */
    qword_t queue_desc;        /* rw */
    word_t  queue_notify_off;  /* ro */
    word_t  queue_enable;      /* rw */
    word_t  queue_msix_vector; /* rw */
    word_t  queue_size;        /* rw*/
  } queue_struct_t;
  
  typedef union packed {
    queue_struct_t queue_struct;
    dword_t [7:0] queue_dwords;
  } queue_data_t;


  /* Device specific configuration structure for network device */
  typedef struct packed {
    byte_t [5:0] mac;
    word_t       status;
    word_t       max_virtqueue_pairs;
    word_t       mtu;
  } virtio_net_config_struct_t;

  typedef union packed {
    virtio_net_config_struct_t net_config_struct;
    dword_t [2:0]              net_config_dwords;
  } virtio_net_config_t;


  /* PCIe controller configuration space */
  typedef struct packed {
    dword_t num_buffers;           // 0x6C (number of queue entries for the last transfer)
    dword_t timer_buf_clean_end;   // 0x68
    dword_t timer_buf_clean_start; // 0x64
    dword_t timer_trx_end;         // 0x60 (timer value at end of the trx)
    dword_t timer_trx_start;       // 0x5C (timer value at beginning of the trx)
    dword_t virtq_notify_vector;   // 0x58
    dword_t virtq_notify_addr;     // 0x54
    dword_t virtq_notify_reg;      // 0x50
    dword_t virtq_device;          // 0x4C
    dword_t virtq_driver;          // 0x48
    dword_t virtq_desc;            // 0x44
    dword_t virtq_size;            // 0x40
    dword_t activate_timers;       // 0x3C
    dword_t timers_valid;          // 0x38
    dword_t mm_tx_remaining_bytes; // 0x34
    dword_t mm_poll_wr_val;        // 0x30
    dword_t mm_poll_addr;          // 0x2C
    dword_t mm_tx_size;            // 0x28
    dword_t mm_tx_dst_addr;        // 0x24
    dword_t mm_tx_src_addr;        // 0x20
    dword_t mm_rx_desc_table_size; // 0x1C
    dword_t mm_rx_desc_table_addr; // 0x18
    dword_t mm_rx_buffer_size;     // 0x14
    dword_t mm_rx_buffer_addr;     // 0x10
    dword_t pcie_cmd_w1c;          // 0x0C
    dword_t pcie_cmd_w1s;          // 0x08
    dword_t pcie_cmd;              // 0x04
    dword_t pcie_status;           // 0x00
  } pcie_cfg_space_struct_t;

  typedef union packed {
    pcie_cfg_space_struct_t pcie_cfg_space_struct;
    dword_t [27:0] pcie_cfg_space_dwords;
  } pcie_cfg_space_t;

  typedef enum logic [2:0]{
    CFG_READ_INACTIVE,
    CFG_READ_INACTIVE_RESP,
    CFG_READ_IDLE,
    CFG_READ,
    CFG_READ_RESP_WAIT
  } cfg_space_read_state_t;
  
  typedef enum logic [2:0]{
    CFG_WRITE_INACTIVE,
    CFG_WRITE_IDLE,
    CFG_WRITE_AW_WAIT,
    CFG_WRITE_W_WAIT,
    CFG_WRITE,
    CFG_WRITE_RESP_WAIT
  } cfg_space_write_state_t;


  /* FSM state encoding for virtqueue controllers */
  typedef enum logic [7:0] {
    DMA_IDLE                          = 8'h0,
    ARBITRATION_WAIT                  = 8'h1,         // Wait for the arbiter to grant access to the DMA engine.
    RD_H2C_CTRL_REQ                   = 8'h2,
    RD_H2C_CTRL_WAIT                  = 8'h3,
    WR_H2C_CTRL_REQ                   = 8'h4,
    WR_H2C_CTRL_REQ_AW                = 8'h5,       // Waiting for address channel
    WR_H2C_CTRL_REQ_W                 = 8'h6,        // Waiting for write data channel
    WR_H2C_CTRL_WAIT                  = 8'h7,
    RD_C2H_CTRL_REQ                   = 8'h8,
    RD_C2H_CTRL_WAIT                  = 8'h9,
    WR_C2H_CTRL_REQ                   = 8'hA,
    WR_C2H_CTRL_REQ_AW                = 8'hB,       // Waiting for address channel
    WR_C2H_CTRL_REQ_W                 = 8'hC,        // Waiting for write data channel
    WR_C2H_CTRL_WAIT                  = 8'hD,
    START_TRANSACTION                 = 8'hE,        // Start data movement
    DIRECT_WR_REQ                     = 8'hF,
    DIRECT_WR_WAIT                    = 8'h10,           // Wait for the data movement to begin
    DIRECT_WR_WAIT_DESC_CMPL          = 8'h11, // Wait for descriptor done signal
    DIRECT_RD_REQ                     = 8'h12,
    DIRECT_RD_WAIT                    = 8'h13,           // Wait for the data movement to begin
    DIRECT_RD_WAIT_DESC_CMPL          = 8'h14, // Wait for descriptor done signal
    RD_Q_AVAIL_IDX                    = 8'h15,
    RD_Q_AVAIL_IDX_REQ                = 8'h16,
    RD_Q_AVAIL_IDX_WAIT               = 8'h17,
    RD_Q_AVAIL_RING_REQ_BUILD         = 8'h18,
    RD_Q_AVAIL_RING_REQ               = 8'h19,
    RD_Q_AVAIL_RING_WAIT              = 8'h1A,
    RD_Q_DESC_REQ                     = 8'h1B,
    RD_Q_DESC_WAIT                    = 8'h1C,
    Q_MOVE_DATA                       = 8'h1D,
    RD_Q_BUFFER_REQ                   = 8'h1E,
    RD_Q_BUFFER_WAIT                  = 8'h1F,
    RD_Q_BUFFER_COUNT_DATA            = 8'h20,
    RD_Q_BUFFER_WAIT_DESC_CMPL        = 8'h21,
    WR_Q_BUFFER_REQ                   = 8'h22,
    WR_Q_BUFFER_WAIT                  = 8'h23,
    WR_Q_BUFFER_WAIT_DESC_CMPL        = 8'h24,
    WR_Q_USED_RING_REQ                = 8'h25,
    WR_Q_USED_RING_WAIT_RD_REQ        = 8'h26,
    WR_Q_USED_RING_WAIT_RRESP         = 8'h27,
    WR_Q_USED_RING_WAIT_DESC_CMPL     = 8'h28,
    WR_Q_USED_IDX_REQ                 = 8'h29,
    WR_Q_USED_IDX_WAIT_RD_REQ         = 8'h2A,
    WR_Q_USED_IDX_WAIT_RRESP          = 8'h2B,
    WR_Q_USED_IDX_WAIT_DESC_CMPL      = 8'h2C,
    RAISE_Q_INT_REQ                   = 8'h2D,
    WR_IRQ_ENABLE_REQ                 = 8'h2E,
    WR_IRQ_ENABLE_WAIT                = 8'h2F,
    WR_IRQ_ENABLE_REQ_AW              = 8'h30,
    WR_IRQ_ENABLE_REQ_W               = 8'h31,
    WR_IRQ_MAP_REQ                    = 8'h32,
    WR_IRQ_MAP_WAIT                   = 8'h33,
    WR_IRQ_MAP_REQ_AW                 = 8'h34,
    WR_IRQ_MAP_REQ_W                  = 8'h35,
    DSC_TAB_WR_MDATA_REQ              = 8'h36,
    DSC_TAB_WR_MDATA_WAIT             = 8'h37,
    DSC_TAB_WR_MDATA_WAIT_AW          = 8'h38,
    DSC_TAB_WR_MDATA_WAIT_W           = 8'h39,
    DSC_TAB_WR_ADDR_REQ               = 8'h3A,
    DSC_TAB_WR_ADDR_WAIT              = 8'h3B,
    DSC_TAB_WR_ADDR_WAIT_AW           = 8'h3C,
    DSC_TAB_WR_ADDR_WAIT_W            = 8'h3D,
    INTERRUPT_USR                     = 8'h3E,
    INTERRUPT_USR_WAIT                = 8'h3F,
    WRITE_POLL_VAL                    = 8'h40,
    WRITE_POLL_VAL_WAIT_AW            = 8'h41,
    WRITE_POLL_VAL_WAIT_W             = 8'h42,
    WRITE_POLL_VAL_WAIT               = 8'h43,
    DESC_TAB_CLEANUP                  = 8'h44,
    DESC_TAB_CLEANUP_RD_MDATA         = 8'h45,
    DESC_TAB_CLEANUP_RD_MDATA_WAIT    = 8'h46,
    DESC_TAB_CLEANUP_WR_MDATA         = 8'h47,
    DESC_TAB_CLEANUP_WR_MDATA_WAIT    = 8'h48,
    DESC_TAB_CLEANUP_WR_MDATA_WAIT_W  = 8'h49,
    DESC_TAB_CLEANUP_WR_MDATA_WAIT_AW = 8'h4A,
    DESC_TAB_CLEANUP_RD_SIZE          = 8'h4B,
    DESC_TAB_CLEANUP_RD_SIZE_WAIT     = 8'h4C,
    SLEEP                             = 8'h4D,
    REACQUIRE_ACCESS                  = 8'h4E,
    DEASSERT_REQ                      = 8'h4F,
    VQ_RD_USED_IDX                    = 8'h50,
    VQ_RD_USED_IDX_WAIT               = 8'h51,
    VQ_IDX_COMPARE                    = 8'h52,
    VQ_RD_USED_IDX_REQ                = 8'h53,
    VQ_BUF_CLEANUP                    = 8'h54,
    VQ_RD_USED_RNG_ELEM               = 8'h55,
    VQ_RD_USED_RNG_ELEM_WAIT          = 8'h56,
    VQ_RD_AVAIL_RNG_ELEM              = 8'h57,
    VQ_RD_AVAIL_RNG_ELEM_WAIT         = 8'h58,
    VQ_RD_DESC_TAB                    = 8'h59,
    VQ_RD_DESC_TAB_WAIT               = 8'h5A,
    VQ_WR_DESC                        = 8'h5B,
    VQ_WR_DESC_ADDR                   = 8'h5C,
    VQ_WR_DESC_ADDR_WAIT              = 8'h5D,
    VQ_WR_DESC_ADDR_W                 = 8'h5E,
    VQ_WR_DESC_ADDR_AW                = 8'h5F,
    VQ_WR_DESC_LEN                    = 8'h60,
    VQ_WR_DESC_LEN_WAIT               = 8'h61,
    VQ_WR_DESC_LEN_W                  = 8'h62,
    VQ_WR_DESC_LEN_AW                 = 8'h63,
    VQ_WR_DESC_ADDR_H                 = 8'h64,
    VQ_WR_DESC_ADDR_H_WAIT            = 8'h65,
    VQ_WR_DESC_ADDR_H_W               = 8'h66,
    VQ_WR_DESC_ADDR_H_AW              = 8'h67,
    VQ_WR_DESC_FN                     = 8'h68,
    VQ_WR_DESC_FN_WAIT                = 8'h69,
    VQ_WR_DESC_FN_W                   = 8'h6A,
    VQ_WR_DESC_FN_AW                  = 8'h6B,
    VQ_UPDATE_AVAIL_RNG               = 8'h6C,
    VQ_UPDATE_AVAIL_RNG_WAIT          = 8'h6D,
    VQ_UPDATE_AVAIL_RNG_AW            = 8'h6E,
    VQ_UPDATE_AVAIL_RNG_W             = 8'h6F,
    VQ_WR_AVAIL_IDX                   = 8'h70,
    VQ_WR_AVAIL_IDX_WAIT              = 8'h71,
    VQ_WR_AVAIL_IDX_AW                = 8'h72,
    VQ_WR_AVAIL_IDX_W                 = 8'h73,
    VQ_NOTIFY                         = 8'h74,
    VQ_NOTIFY_WAIT                    = 8'h75,
    VQ_NOTIFY_AW                      = 8'h76,
    VQ_NOTIFY_W                       = 8'h77,
    VQ_RD_AVAIL_IDX                   = 8'h78,
    VQ_RD_AVAIL_IDX_WAIT              = 8'h79,
    VQ_RD_AVAIL_RNG                   = 8'h7A,
    VQ_RD_AVAIL_RNG_REQ               = 8'h7B,
    VQ_RD_AVAIL_RNG_WAIT              = 8'h7C,
    VQ_RD_DESC1                       = 8'h7D,
    VQ_RD_DESC1_REQ                   = 8'h7E,
    VQ_RD_DESC1_WAIT                  = 8'h7F,
    VQ_RD_DESC2_REQ                   = 8'h80,
    VQ_RD_DESC2_WAIT                  = 8'h81,
    VQ_RD_DESC3_REQ                   = 8'h82,
    VQ_RD_DESC3_WAIT                  = 8'h83,
    VQ_RD_DESC4_REQ                   = 8'h84,
    VQ_RD_DESC4_WAIT                  = 8'h85,
    VQ_WR_USED_RNG_ELM_ID             = 8'h86,
    VQ_WR_USED_RNG_ELM_ID_W           = 8'h87,
    VQ_WR_USED_RNG_ELM_ID_AW          = 8'h88,
    VQ_WR_USED_RNG_ELM_ID_WAIT        = 8'h89,
    VQ_WR_USED_RNG_ELM_LEN            = 8'h8A,
    VQ_WR_USED_RNG_ELM_LEN_W          = 8'h8B,
    VQ_WR_USED_RNG_ELM_LEN_AW         = 8'h8C,
    VQ_WR_USED_RNG_ELM_LEN_WAIT       = 8'h8D,
    VQ_WR_USED_RNG_IDX                = 8'h8E,
    VQ_WR_USED_RNG_IDX_W              = 8'h8F,
    VQ_WR_USED_RNG_IDX_AW             = 8'h90,
    VQ_WR_USED_RNG_IDX_WAIT           = 8'h91,
    RD_Q_BUFFER_WAIT_BVALID           = 8'h92,
    DIRECT_WR_COUNT_DATA              = 8'h93,
    DIRECT_RD_COUNT_DATA              = 8'h94,
    DIRECT_RD_WAIT_BVALID             = 8'h95,
    WR_Q_BUFFER_COUNT_DATA            = 8'h96
  } dma_config_state_t;



endpackage

`endif // `ifndef __DEFINES_PKG__
