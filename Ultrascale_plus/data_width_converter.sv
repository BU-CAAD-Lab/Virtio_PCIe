/*
Module: data_width_converter
Descriptoin: Converts input AXI data width to the output AXI data width
Notes:
  - Only the DATA_A_WIDTH > DATA_B_WIDTH case is supported currently.
  - We assume that the RX buffer address is at least DATA_B_WIDTh aligned.
  - Always assume burst type 2'b01 (incrementing addresses)

*/


module data_width_converter #(
  parameter DATA_A_WIDTH = 128,
  parameter DATA_B_WIDTH = 32,
  parameter ADDR_WIDTH   = 32,
  parameter WSTRB_A      = DATA_A_WIDTH/8,
  parameter WSTRB_B      = DATA_B_WIDTH/8
) (
  input clk,
  input rst,
  // Port A
  input logic  [ADDR_WIDTH-1  :0] a_araddr, 
  input logic                     a_arvalid,
  input logic                     a_rready,  
  input  logic            [7  :0] a_arlen,
  input  logic            [2  :0] a_arsize,
  input  logic            [1  :0] a_arburst,
  output logic                    a_arready,
  output logic [DATA_A_WIDTH-1:0] a_rdata,
  output logic                    a_rvalid,
  output logic              [1:0] a_rresp,
  output logic                    a_rlast,
  input logic  [ADDR_WIDTH-1  :0] a_awaddr,
  input logic                     a_awvalid,
  input logic  [DATA_A_WIDTH-1:0] a_wdata,
  input logic  [WSTRB_A-1     :0] a_wstrb,
  input logic                     a_wvalid,
  input  logic            [7  :0] a_awlen,
  input  logic            [2  :0] a_awsize,
  input  logic            [1  :0] a_awburst,
  input  logic                    a_wlast,
  input logic                     a_bready,
  output logic                    a_awready,
  output logic                    a_wready,
  output logic              [1:0] a_bresp,
  output logic                    a_bvalid,
  // Port B
  output logic [ADDR_WIDTH-1  :0] b_araddr, 
  output logic                    b_arvalid,
  output logic                    b_rready,  
  input logic                     b_arready,
  input logic  [DATA_B_WIDTH-1:0] b_rdata,
  input logic                     b_rvalid,
  input logic               [1:0] b_rresp,
  output logic [ADDR_WIDTH-1  :0] b_awaddr,
  output logic                    b_awvalid,
  output logic [DATA_B_WIDTH-1:0] b_wdata,
  output logic [WSTRB_B-1     :0] b_wstrb,
  output logic                    b_wvalid,
  output logic                    b_bready,
  input logic                     b_awready,
  input logic                     b_wready,
  input logic               [1:0] b_bresp,
  input logic                     b_bvalid
);

localparam RATIO       = DATA_A_WIDTH/DATA_B_WIDTH;
localparam COUNTER_W   = $clog2(RATIO);
localparam B_WORD_SIZE = DATA_B_WIDTH/8;

typedef enum logic [2:0]{
  R_IDLE       = 0,
  RREQ         = 1,
  WAIT_RREQ    = 2,
  B_RRESP      = 3,
  TX_BEAT      = 4,
  WAIT_A_RRESP = 5
} rstate_t;


typedef enum logic [3:0]{
  W_IDLE        = 0,
  WREQ_AW       = 1,
  WREQ_W        = 2,
  WREQ          = 3,
  WAIT_WREQ     = 4,
  WAIT_WREQ_AWR = 5, // Wait for awready signal
  WAIT_WREQ_WR  = 6,  // Wait for wready signal
  B_WRESP       = 7,
  WAIT_A_WRESP  = 8,
  WAIT_NXT_BEAT = 9
} wstate_t;



// Internal signals
rstate_t rstate, nxt_rstate;
wstate_t wstate, nxt_wstate;

logic                    nxt_a_arready;
//logic [DATA_A_WIDTH-1:0] nxt_a_rdata;
logic                    nxt_a_rvalid;
logic              [1:0] nxt_a_rresp;
logic                    nxt_a_rlast;
logic                    nxt_a_awready;
logic                    nxt_a_wready;
logic              [1:0] nxt_a_bresp;
logic                    nxt_a_bvalid;
logic [ADDR_WIDTH-1  :0] nxt_b_araddr;
logic                    nxt_b_arvalid;
logic                    nxt_b_rready;
logic [ADDR_WIDTH-1  :0] nxt_b_awaddr;
logic                    nxt_b_awvalid;
logic [DATA_B_WIDTH-1:0] nxt_b_wdata;
logic [WSTRB_B-1     :0] nxt_b_wstrb;
logic                    nxt_b_wvalid;
logic                    nxt_b_bready;


logic [RATIO-1:0][WSTRB_B-1:0] r_wstrobe, nxt_r_wstrobe;
logic [RATIO-1:0][DATA_B_WIDTH-1:0] r_wdata, nxt_r_wdata;
logic [RATIO-1:0][DATA_B_WIDTH-1:0] r_rdata, nxt_r_rdata;
logic [ADDR_WIDTH-1:0] r_raddr, nxt_r_raddr;
logic [ADDR_WIDTH-1:0] r_waddr, nxt_r_waddr;
logic [COUNTER_W-1:0] rcounter, nxt_rcounter;
logic [COUNTER_W-1:0] wcounter, nxt_wcounter;
logic [7:0] wbcounter, nxt_wbcounter;
logic [7:0] rbcounter, nxt_rbcounter;
logic [7:0] r_awlen, nxt_r_awlen;
logic [7:0] r_arlen, nxt_r_arlen;
logic [2:0] r_awsize, nxt_r_awsize;
logic [2:0] r_arsize, nxt_r_arsize;
logic [1:0] r_awburst, nxt_r_awburst;
logic [1:0] r_arburst, nxt_r_arburst;
logic [31:0] wb_increment, rb_increment;


// Combinational logic to determine address increments
always_comb begin
  case(r_awsize)
    3'b000 : wb_increment = 32'd1;
    3'b001 : wb_increment = 32'd2;
    3'b010 : wb_increment = 32'd4;
    3'b011 : wb_increment = 32'd8;
    3'b100 : wb_increment = 32'd16;
    3'b101 : wb_increment = 32'd32;
    3'b110 : wb_increment = 32'd64;
    3'b111 : wb_increment = 32'd128;
    default: wb_increment = 32'd0;
  endcase
end

always_comb begin
  case(r_arsize)
    3'b000 : rb_increment = 32'd1;
    3'b001 : rb_increment = 32'd2;
    3'b010 : rb_increment = 32'd4;
    3'b011 : rb_increment = 32'd8;
    3'b100 : rb_increment = 32'd16;
    3'b101 : rb_increment = 32'd32;
    3'b110 : rb_increment = 32'd64;
    3'b111 : rb_increment = 32'd128;
    default: rb_increment = 32'd0;
  endcase
end

//--- State machines ---//
// Read channel
always_ff @(posedge clk)begin
  if(rst)begin
    a_arready <= 1'b1;
    a_rvalid  <= 1'b0;
    a_rlast   <= 1'b0;
    a_rresp   <= 2'b00;
    b_araddr  <= {ADDR_WIDTH{1'b0}};
    b_arvalid <= 1'b0;
    b_rready  <= 1'b1;
    rcounter  <= {COUNTER_W{1'b0}};
    r_rdata   <= {RATIO*DATA_B_WIDTH{1'b0}};
    r_raddr   <= {ADDR_WIDTH{1'b0}};
    r_arsize  <= 3'd0;
    r_arlen   <= 8'd0;
    r_arburst <= 2'd0;
    rbcounter <= 8'd0;
    rstate    <= R_IDLE;
  end
  else begin
    a_arready <= nxt_a_arready;
    a_rresp   <= nxt_a_rresp;
    a_rvalid  <= nxt_a_rvalid;
    a_rlast   <= nxt_a_rlast;
    b_araddr  <= nxt_b_araddr;
    b_arvalid <= nxt_b_arvalid;
    b_rready  <= nxt_b_rready;
    rcounter  <= nxt_rcounter;
    r_rdata   <= nxt_r_rdata;
    r_raddr   <= nxt_r_raddr;
    r_arsize  <= nxt_r_arsize;
    r_arlen   <= nxt_r_arlen;
    r_arburst <= nxt_r_arburst;
    rbcounter <= nxt_rbcounter;
    rstate    <= nxt_rstate;
  end
end

always_comb begin
  nxt_a_arready = a_arready;
  nxt_r_rdata   = r_rdata;
  nxt_r_raddr   = r_raddr;
  nxt_a_rvalid  = a_rvalid;
  nxt_a_rlast   = a_rlast;
  nxt_a_rresp   = a_rresp;
  nxt_b_araddr  = b_araddr;
  nxt_b_arvalid = b_arvalid;
  nxt_b_rready  = b_rready;
  nxt_rcounter  = rcounter;
  nxt_r_arsize  = r_arsize;
  nxt_r_arlen   = r_arlen;
  nxt_r_arburst = r_arburst;
  nxt_rbcounter = rbcounter;
  nxt_rstate    = rstate;
  case(rstate)
    R_IDLE:begin
      if(a_arvalid & a_arready)begin
        nxt_r_raddr   = {a_araddr[ADDR_WIDTH-1:4], 4'd0};
        nxt_r_arsize  = a_arsize;
        nxt_r_arlen   = a_arlen;
        nxt_r_arburst = a_arburst;
        nxt_rcounter  = {COUNTER_W{1'b0}};
        nxt_rbcounter = 8'd0;
        nxt_a_arready = 1'b0;
        nxt_rstate    = RREQ;
      end
    end
    RREQ:begin
      nxt_b_arvalid = 1'b1;
      nxt_b_araddr  = r_raddr + (rcounter << 2);
      nxt_rstate    = WAIT_RREQ; 
    end
    WAIT_RREQ:begin
      if(b_arvalid & b_arready)begin
        nxt_b_arvalid = 1'b0;
        nxt_rstate    = B_RRESP;    
      end
    end
    B_RRESP:begin
      if(b_rvalid & b_rready)begin
        if(b_rresp == 2'b00)begin
          nxt_r_rdata[rcounter] = b_rdata;
          if(rcounter == RATIO-1)begin
            if(rbcounter == r_arlen)begin // Last beat
              nxt_rcounter  = {COUNTER_W{1'b0}};
              nxt_rbcounter = 8'd0;
              nxt_a_rlast   = 1'b1;
              nxt_a_rvalid  = 1'b1;
              nxt_a_rresp   = 2'b00;
              nxt_rstate    = WAIT_A_RRESP;
            end
            else begin  // More beats to be transmitted
              nxt_rcounter  = {COUNTER_W{1'b0}};
              nxt_rbcounter = rbcounter + 8'd1;
              nxt_r_raddr   = r_raddr + rb_increment;
              nxt_a_rvalid  = 1'b1;
              nxt_a_rresp   = 2'b00;
              nxt_rstate    = TX_BEAT;
            end
          end
          else begin  // More words to be read to complete the current beat
            nxt_rcounter = rcounter + {{COUNTER_W-1{1'b0}}, 1'b1};
            nxt_rstate   = RREQ;
          end
        end
        else begin // Read error
          nxt_a_rvalid = 1'b1;
          nxt_a_rresp  = b_rresp;
          nxt_rstate   = WAIT_A_RRESP;
        end
      end
    end
    TX_BEAT:begin
      if(a_rvalid & a_rready)begin
        nxt_a_rvalid  = 1'b0;
        nxt_a_rresp   = 2'b00;
        nxt_rstate    = RREQ;
      end
    end
    WAIT_A_RRESP:begin
      if(a_rvalid & a_rready)begin
        nxt_a_rvalid  = 1'b0;
        nxt_a_rresp   = 2'b00;
        nxt_a_rlast   = 1'b0;
        nxt_a_arready = 1'b1;
        nxt_rstate    = R_IDLE;
      end
    end
  endcase
end


// Write channel
always_ff @(posedge clk)begin
  if(rst)begin
    a_awready <= 1'b1;
    a_wready  <= 1'b1;
    a_bresp   <= 2'b00;
    a_bvalid  <= 1'b0;
    b_awaddr  <= {ADDR_WIDTH{1'b0}};
    b_awvalid <= 1'b0;
    b_wdata   <= {DATA_B_WIDTH{1'b0}};
    b_wstrb   <= {WSTRB_B{1'b0}};
    b_wvalid  <= 1'b0;
    b_bready  <= 1'b1;
    r_wstrobe <= {WSTRB_A{1'b0}};
    r_waddr   <= {ADDR_WIDTH{1'b0}};
    r_wdata   <= {RATIO*DATA_B_WIDTH{1'b0}};
    r_awsize  <= 3'd0;
    r_awlen   <= 8'd0;
    r_awburst <= 2'b00;
    wcounter  <= {COUNTER_W{1'b0}};
    wbcounter <= 8'd0;
    wstate    <= W_IDLE;
  end
  else begin
    a_awready <= nxt_a_awready;
    a_wready  <= nxt_a_wready;
    a_bresp   <= nxt_a_bresp;
    a_bvalid  <= nxt_a_bvalid;
    b_awaddr  <= nxt_b_awaddr;
    b_awvalid <= nxt_b_awvalid;
    b_wdata   <= nxt_b_wdata;
    b_wstrb   <= nxt_b_wstrb;
    b_wvalid  <= nxt_b_wvalid;
    b_bready  <= nxt_b_bready;
    r_wstrobe <= nxt_r_wstrobe;
    r_waddr   <= nxt_r_waddr;
    r_wdata   <= nxt_r_wdata;
    r_awsize  <= nxt_r_awsize;
    r_awlen   <= nxt_r_awlen;
    r_awburst <= nxt_r_awburst;
    wcounter  <= nxt_wcounter;
    wbcounter <= nxt_wbcounter;
    wstate    <= nxt_wstate;
  end
end

always_comb begin
  nxt_a_awready = a_awready;
  nxt_a_wready  = a_wready;
  nxt_a_bresp   = a_bresp;
  nxt_a_bvalid  = a_bvalid;
  nxt_b_awaddr  = b_awaddr;
  nxt_b_awvalid = b_awvalid;
  nxt_b_wdata   = b_wdata;
  nxt_b_wstrb   = b_wstrb;
  nxt_b_wvalid  = b_wvalid;
  nxt_b_bready  = b_bready;
  nxt_r_wstrobe = r_wstrobe;
  nxt_r_waddr   = r_waddr;
  nxt_r_wdata   = r_wdata;
  nxt_r_awsize  = r_awsize;
  nxt_r_awlen   = r_awlen;
  nxt_r_awburst = r_awburst;
  nxt_wcounter  = wcounter;
  nxt_wbcounter = wbcounter;
  nxt_wstate    = wstate;
  case(wstate)
    W_IDLE:begin
      if(a_awvalid & a_awready & a_wvalid & a_wready)begin
        // nxt_r_waddr   = {a_awaddr[ADDR_WIDTH-1:2], 2'd0};
        nxt_r_waddr   = {a_awaddr[ADDR_WIDTH-1:4], 4'd0}; // TODO: Will not work if bus width is different from 16 Byte.
        /* Note: This is a fix to workaround AXI addres alignment rules where AXI master can either zero out the lower bits or not for unalighned writes. strobe bits are correct. 
           Therefore,  starting with the 16 byte aligned address is the simplest solution.*/
        nxt_r_wdata   = a_wdata;
        nxt_r_wstrobe = a_wstrb;
        nxt_r_awlen   = a_awlen;
        nxt_r_awsize  = a_awsize;
        nxt_r_awburst = a_awburst;
        nxt_a_awready = 1'b0;
        nxt_a_wready  = 1'b0;
        nxt_wcounter  = {COUNTER_W{1'b0}};
        nxt_wbcounter = 8'd0;
        nxt_wstate    = WREQ;
      end
      else if(a_awvalid & a_awready)begin
        // nxt_r_waddr   = {a_awaddr[ADDR_WIDTH-1:2], 2'd0};
        nxt_r_waddr   = {a_awaddr[ADDR_WIDTH-1:4], 4'd0};
        nxt_r_wstrobe = a_wstrb;
        nxt_r_awlen   = a_awlen;
        nxt_r_awsize  = a_awsize;
        nxt_a_awready = 1'b0;
        nxt_wstate    = WREQ_W;
      end
      else if(a_wvalid & a_wready)begin
        nxt_r_wdata   = a_wdata;
        nxt_r_wstrobe = a_wstrb;
        nxt_a_wready  = 1'b0;
        nxt_wstate    = WREQ_AW;
      end
    end
    WREQ_AW:begin // Wait for address
      if(a_awvalid & a_awready)begin
        // nxt_r_waddr   = {a_awaddr[ADDR_WIDTH-1:2], 2'd0};
        nxt_r_waddr   = {a_awaddr[ADDR_WIDTH-1:4], 4'd0};
        nxt_a_awready = 1'b0;
        nxt_wcounter  = {COUNTER_W{1'b0}};
        nxt_wbcounter = 8'd0;
        nxt_wstate    = WREQ;
      end
    end
    WREQ_W:begin // Wait for data
      if(a_wvalid & a_wready)begin
        nxt_r_wdata   = a_wdata;
        nxt_r_wstrobe = a_wstrb;
        nxt_a_wready  = 1'b0;
        nxt_wcounter  = {COUNTER_W{1'b0}};
        nxt_wbcounter = 8'd0;
        nxt_wstate    = WREQ;
      end
    end
    WREQ:begin
      if(|r_wstrobe[wcounter])begin
        nxt_b_awvalid = 1'b1;
        nxt_b_wvalid  = 1'b1;
        nxt_b_awaddr  = r_waddr + (wcounter << 2);
        nxt_b_wdata   = r_wdata[wcounter];
        nxt_b_wstrb   = r_wstrobe[wcounter];
        nxt_wstate    = WAIT_WREQ;
      end
      else begin // wstrobe is low. Either at the beginning or the end of a transfer
        if(wcounter == RATIO-1)begin // End of a beat
          if(wbcounter == r_awlen)begin // All beats transmitted
            nxt_wcounter  = {COUNTER_W{1'b0}};
            nxt_wbcounter = 8'd0;
            nxt_a_bvalid  = 1'b1;
            nxt_a_bresp   = 2'b00;
            nxt_wstate    = WAIT_A_WRESP;
          end
          else begin // More beats to be transmitted
            nxt_wcounter  = {COUNTER_W{1'b0}};
            nxt_wbcounter = wbcounter + 8'd1;
            nxt_r_waddr   = r_waddr + wb_increment;
            nxt_a_wready  = 1'b1;
            nxt_wstate    = WAIT_NXT_BEAT;
          end
        end
        else begin
          nxt_wcounter = wcounter + {{COUNTER_W-1{1'b0}}, 1'b1};
          nxt_wstate   = WREQ;
        end
      end
      // else begin // Should be the end of the transfer.
      //   nxt_wcounter = {COUNTER_W{1'b0}};
      //   nxt_a_bvalid = 1'b1;
      //   nxt_a_bresp  = 2'b00;
      //   nxt_wstate   = WAIT_A_WRESP;
      // end
    end
    WAIT_WREQ:begin
      if(b_awvalid & b_awready & b_wvalid & b_wready)begin
        nxt_b_awvalid = 1'b0;
        nxt_b_wvalid  = 1'b0;
        nxt_wstate    = B_WRESP;
      end
      else if(b_awvalid & b_awready)begin
        nxt_b_awvalid = 1'b0;
        nxt_wstate    = WAIT_WREQ_WR;
      end
      else if(b_wvalid & b_wready)begin
        nxt_b_wvalid = 1'b0;
        nxt_wstate   = WAIT_WREQ_AWR;
      end
    end
    WAIT_WREQ_AWR:begin
      if(b_awvalid & b_awready)begin
        nxt_b_awvalid = 1'b0;
        nxt_wstate    = B_WRESP;
      end
    end
    WAIT_WREQ_WR:begin
      if(b_wvalid & b_wready)begin
        nxt_b_wvalid = 1'b0;
        nxt_wstate   = B_WRESP;
      end
    end
    B_WRESP:begin
      if(b_bvalid & b_bready)begin
        if(b_bresp == 2'b00)begin
          if(wcounter == RATIO-1)begin
            if(wbcounter == r_awlen)begin // All beats transmitted
              nxt_wcounter  = {COUNTER_W{1'b0}};
              nxt_wbcounter = 8'd0;
              nxt_a_bvalid  = 1'b1;
              nxt_a_bresp   = 2'b00;
              nxt_wstate    = WAIT_A_WRESP;
            end 
            else begin
              nxt_wcounter  = {COUNTER_W{1'b0}};
              nxt_wbcounter = wbcounter + 8'd1;
              nxt_r_waddr   = r_waddr + wb_increment;
              nxt_a_wready  = 1'b1;
              nxt_wstate    = WAIT_NXT_BEAT;
            end
          end
          else begin
            nxt_wcounter = wcounter + {{COUNTER_W-1{1'b0}}, 1'b1};
            nxt_wstate   = WREQ;
          end
        end
        else begin
          nxt_a_bvalid  = 1'b1;
          nxt_a_bresp   = b_bresp;
          nxt_wstate    = WAIT_A_WRESP;
        end
      end
    end
    WAIT_A_WRESP:begin
      if(a_bvalid & a_bready)begin
        nxt_a_bvalid  = 1'b0;
        nxt_a_bresp   = 2'b00;
        nxt_a_awready = 1'b1;
        nxt_a_wready  = 1'b1;
        nxt_wstate    = W_IDLE;
      end
    end
    WAIT_NXT_BEAT:begin
      if(a_wvalid & a_wready)begin
        nxt_r_wdata   = a_wdata;
        nxt_r_wstrobe = a_wstrb;
        nxt_a_wready  = 1'b0;
        nxt_wstate    = WREQ;
      end
    end
  endcase 
end


// Continuous assignments
assign a_rdata = r_rdata;

endmodule
