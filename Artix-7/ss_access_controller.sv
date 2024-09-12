module ss_access_controller #(
  parameter NUM_PORTS = 4,
  parameter PORT_IDX_BITS = $clog2(NUM_PORTS)
)(
  input clk,
  input reset,
  input [NUM_PORTS-1:0] arvalid,
  input [NUM_PORTS-1:0] arready,
  input [NUM_PORTS-1:0] rvalid,
  input [NUM_PORTS-1:0] rready,
  input [NUM_PORTS-1:0] awvalid,
  input [NUM_PORTS-1:0] awready,
  input [NUM_PORTS-1:0] bvalid,
  input [NUM_PORTS-1:0] bready,

  output logic [PORT_IDX_BITS-1:0] group_select
);

typedef enum logic [1:0]{
  IDLE,
  ACCESS_GRANTED,
  ACTIVE_ACCESS
} access_ctrl_state_t;

access_ctrl_state_t ctrl_state, nxt_ctrl_state;
logic [PORT_IDX_BITS-1:0] nxt_group_select;
logic [NUM_PORTS-1:0] requests;
logic [PORT_IDX_BITS-1:0] arb_grant;
logic arb_valid;

// Instantiate arbiter
arbiter #(
  .WIDTH(NUM_PORTS),
  .ARB_TYPE("PACKET")
) req_arb (
  .clock(clk),
  .reset(reset),
  .requests(requests),
  .grant(arb_grant),
  .valid(arb_valid)
);


always_comb begin
  for(int i=0; i<NUM_PORTS; i++)begin
    requests[i] = arvalid[i] | awvalid[i];
  end
end

always_ff @(posedge clk)begin
  if(reset)begin
    group_select <= {PORT_IDX_BITS{1'b0}};
    ctrl_state   <= IDLE;
  end
  else begin
    group_select <= nxt_group_select;
    ctrl_state   <= nxt_ctrl_state;
  end
end

always_comb begin
  nxt_group_select = group_select;
  nxt_ctrl_state   = ctrl_state;
  case(ctrl_state)
    IDLE:begin
      if(arb_valid)begin
        nxt_group_select = arb_grant;
        nxt_ctrl_state   = ACCESS_GRANTED;
      end
    end
    ACCESS_GRANTED:begin
      if((arvalid[group_select] & arready[group_select]) | (awvalid[group_select] & awready[group_select]))begin
        nxt_ctrl_state = ACTIVE_ACCESS;
      end
    end
    ACTIVE_ACCESS:begin
      if((rvalid[group_select] & rready[group_select]) | (bvalid[group_select] & bready[group_select]))begin
        if(arb_valid)begin // requests pending
          nxt_group_select = arb_grant;
          nxt_ctrl_state   = ACCESS_GRANTED;
        end
        else begin
          nxt_group_select = {PORT_IDX_BITS{1'b0}};
          nxt_ctrl_state   = IDLE;
        end
      end
    end
  endcase
end

endmodule
