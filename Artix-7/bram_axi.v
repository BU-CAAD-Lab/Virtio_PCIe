`timescale 1ns/1ns

module bram_axi(
clk,rst,
mem_axi_araddr,mem_axi_arvalid,mem_axi_arready,
mem_axi_awaddr,mem_axi_awvalid,mem_axi_awready,
mem_axi_rdata,mem_axi_rvalid,mem_axi_rready,
mem_axi_wdata,mem_axi_wstrb,mem_axi_wvalid,mem_axi_wready,
mem_b_ready,mem_b_valid,mem_b_response
);


parameter ADDR_WIDTH = 10;
parameter DATA_WIDTH = 32;
parameter INITIALIZE = 1;
parameter INIT_FILE  = "./text.hex";

input                            clk;
input                            rst;
input	     [ADDR_WIDTH-1:0]	     mem_axi_araddr;
input 			 		                 mem_axi_arvalid;
output reg 				               mem_axi_arready;
input	     [ADDR_WIDTH-1:0]	     mem_axi_awaddr;
input 			 		                 mem_axi_awvalid;
output reg				               mem_axi_awready;
output reg [DATA_WIDTH-1:0]	     mem_axi_rdata;
output reg	 			               mem_axi_rvalid;
input 			 		                 mem_axi_rready;
input	     [DATA_WIDTH-1:0]	     mem_axi_wdata;
input	     [(DATA_WIDTH>>3)-1:0] mem_axi_wstrb;
input 			 		                 mem_axi_wvalid;
output reg				               mem_axi_wready;
input 					                 mem_b_ready;
output reg				               mem_b_valid;
output     [1:0] 			           mem_b_response;



reg [ADDR_WIDTH-1:0] araddr_buff;
reg [ADDR_WIDTH-1:0] awaddr_buff;
reg [DATA_WIDTH-1:0] wdata_buff;
reg [(DATA_WIDTH>>3)-1:0] wstrb_buff;

assign mem_b_response = 0;
//////////////////////////////////////////////////////////  MEMORY /////////////////////////////////////

reg [DATA_WIDTH-1:0] mem [0: (2**(ADDR_WIDTH-2))-1];

integer i;
//initial begin
//	for (i = 0 ; i < (2**ADDR_WIDTH); i=i+1) begin
//	mem[i] = 0;		
//	end
//end

initial begin
  if(INITIALIZE)
    $readmemh(INIT_FILE, mem);
end

/////////////////////////////////////////////////////////   READ ///////////////////////////////////////
reg [1:0] r_state;

always @(posedge clk)begin
  if(rst)begin
    mem_axi_arready <= 1'b1;
    r_state         <= 0;
  end
  else begin
    case(r_state)
      0:begin
        if(mem_axi_arready & mem_axi_arvalid)begin
          araddr_buff <= mem_axi_araddr;
          r_state     <= 1;
        end
      end
      1:begin
        mem_axi_rdata   <= mem[araddr_buff];
        mem_axi_rvalid  <= 1'b1;
        r_state         <= 2;
      end
      2:begin
        if(mem_axi_rvalid & mem_axi_rready)begin
          mem_axi_rdata   <= {DATA_WIDTH{1'b0}};
          mem_axi_rvalid  <= 1'b0;
          mem_axi_arready <= 1'b1;
          r_state         <= 0;
        end
      end
      default:begin
        mem_axi_rdata   <= {DATA_WIDTH{1'b0}};
        mem_axi_rvalid  <= 1'b0;
        mem_axi_arready <= 1'b1;
        r_state         <= 0;
      end
    endcase
  end
end

/////////////////////////////////////////////////////////////////////// WRITE //////////////////////////////////////////////////


reg [DATA_WIDTH-1:0] write_data;
reg [DATA_WIDTH-1:0] write_data_masked;
reg [2:0] w_state;
	
integer j;
always @(*) begin
	for (j=0; j < (DATA_WIDTH>>3); j=j+1) begin
		write_data_masked[(j<<3)+:8] = wstrb_buff[j] ? wdata_buff[(j<<3)+:8] : write_data[(j<<3)+:8];
	end
end


always @(posedge clk)begin
  if(rst)begin
    awaddr_buff     <= {ADDR_WIDTH{1'b0}};
    wdata_buff      <= {DATA_WIDTH{1'b0}};
    wstrb_buff      <= {(DATA_WIDTH>>3){1'b0}};
    write_data      <= {DATA_WIDTH{1'b0}};
    mem_axi_awready <= 1'b1;
    mem_axi_wready  <= 1'b1;
    mem_b_valid     <= 1'b0;
    w_state         <= 0;
  end
  else begin
    case(w_state)
      0:begin
        if(mem_axi_awvalid & mem_axi_awready & mem_axi_wvalid & mem_axi_wready)begin
          awaddr_buff     <= mem_axi_awaddr;
          wdata_buff      <= mem_axi_wdata;
          wstrb_buff      <= mem_axi_wstrb;
          mem_axi_awready <= 1'b0;
          mem_axi_wready  <= 1'b0;
          w_state         <= 3;
        end
        else if(mem_axi_awvalid & mem_axi_awready)begin
          awaddr_buff     <= mem_axi_awaddr;
          mem_axi_awready <= 1'b0;
          w_state         <= 1; // wait for data
        end
        else if(mem_axi_wvalid & mem_axi_wready)begin
          wdata_buff      <= mem_axi_wdata;
          wstrb_buff      <= mem_axi_wstrb;
          mem_axi_wready  <= 1'b0;
          w_state         <= 2; // wait for address
        end
      end
      1:begin
        wdata_buff      <= mem_axi_wdata;
        wstrb_buff      <= mem_axi_wstrb;
        mem_axi_wready  <= 1'b0;
        w_state         <= 3;
      end
      2:begin
        awaddr_buff     <= mem_axi_awaddr;
        mem_axi_awready <= 1'b0;
        w_state         <= 3;
      end
      3:begin
        write_data <= mem[awaddr_buff];
        w_state    <= 4;
      end
      4:begin
        mem[awaddr_buff] <= write_data_masked;
        mem_b_valid      <= 1'b1;
        w_state          <= 5;
      end
      5:begin
        if(mem_b_valid & mem_b_ready)begin
          mem_b_valid     <= 1'b0;
          mem_axi_awready <= 1'b1;
          mem_axi_wready  <= 1'b1;
          w_state         <= 0;
        end
      end
      default:begin
        mem_b_valid     <= 1'b0;
        mem_axi_awready <= 1'b1;
        mem_axi_wready  <= 1'b1;
        w_state         <= 0;
      end
    endcase
  end
end

endmodule

