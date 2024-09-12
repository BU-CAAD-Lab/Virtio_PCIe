module gpio_axi(
clk,
rst,

a_axi_araddr,
a_axi_arvalid,
a_axi_arready,

a_axi_awaddr,
a_axi_awvalid,
a_axi_awready,

a_axi_rdata,
a_axi_rvalid,
a_axi_rready,

a_axi_wdata,
a_axi_wstrb,
a_axi_wvalid,
a_axi_wready,

a_b_ready,
a_b_valid,
a_b_response,

sw,
led
);


parameter ADDR_WIDTH = 1;
parameter DATA_WIDTH = 8; 
parameter NUM_LEDS = 4;
parameter NUM_SWITCHES = 4;

input clk;
input rst;

input [ADDR_WIDTH-1:0] 			a_axi_araddr;
input 			 	a_axi_arvalid;
output  			a_axi_arready;

input [ADDR_WIDTH-1:0] 			a_axi_awaddr;
input 			 	a_axi_awvalid;
output 			a_axi_awready;

output  [DATA_WIDTH-1:0] 		a_axi_rdata;
output reg		 		a_axi_rvalid;
input 			 	a_axi_rready;

input [DATA_WIDTH-1:0] 			a_axi_wdata;
input [(DATA_WIDTH>>3)-1:0] 			a_axi_wstrb;
input 			 	a_axi_wvalid;
output 		 	a_axi_wready;

input 				a_b_ready;
output 	reg			a_b_valid;
output [1:0] 		a_b_response;

////  io
input  [NUM_SWITCHES-1:0] sw;
output reg [NUM_LEDS-1:0] led;


assign a_axi_arready =  a_axi_arvalid;
assign a_axi_awready = a_axi_awvalid;
assign a_axi_wready = a_axi_wvalid;
assign a_axi_rdata = {{ADDR_WIDTH-NUM_SWITCHES{1'b0}}, sw};
assign a_b_response = 0;

always @(posedge clk) begin
	if (rst) begin
		a_axi_rvalid <= 0;
	end else if (a_axi_arvalid)  begin
		a_axi_rvalid <= 1;
	end else if (a_axi_rready) begin
		a_axi_rvalid <= 0;
	end
end


always @(posedge clk) begin
	if (rst) begin
		a_b_valid <= 0;
		led <= 0;
	end else if (a_axi_wready && a_axi_wvalid)  begin
		a_b_valid <= 1;
		led <= a_axi_wdata[NUM_LEDS-1:0];
	end else if (a_b_ready) begin
		a_b_valid <= 0;
	end
end

endmodule




module timer_axi(
clk,
rst,

a_axi_araddr,
a_axi_arvalid,
a_axi_arready,

a_axi_awaddr,
a_axi_awvalid,
a_axi_awready,

a_axi_rdata,
a_axi_rvalid,
a_axi_rready,

a_axi_wdata,
a_axi_wstrb,
a_axi_wvalid,
a_axi_wready,

a_b_ready,
a_b_valid,
a_b_response
);

parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32; 
parameter TCKS_PER_US = 83;

input clk;
input rst;

input [ADDR_WIDTH-1:0] 			a_axi_araddr;
input 			 	a_axi_arvalid;
output  			a_axi_arready;

input [ADDR_WIDTH-1:0] 			a_axi_awaddr;
input 			 	a_axi_awvalid;
output 			a_axi_awready;

output  [DATA_WIDTH-1:0] 		a_axi_rdata;
output reg		 		a_axi_rvalid;
input 			 	a_axi_rready;

input [DATA_WIDTH-1:0] 			a_axi_wdata;
input [(DATA_WIDTH>>3)-1:0] 			a_axi_wstrb;
input 			 	a_axi_wvalid;
output 		 	a_axi_wready;

input 				a_b_ready;
output 	reg			a_b_valid;
output [1:0] 		a_b_response;



reg [DATA_WIDTH-1:0] timer;
reg [31:0] us_timer;


assign a_axi_rdata = timer;
assign a_axi_arready = 1;
assign a_axi_awready = 1;
assign a_axi_wready = 1;
assign a_b_response = 0;

always @(posedge clk) begin
	if (rst) 
		a_axi_rvalid <= 0;
	else if (a_axi_arvalid) 
		a_axi_rvalid <= 1;
	else if (a_axi_rready)
		a_axi_rvalid <= 0;
end
		
always @(posedge clk) begin
	if (rst) 
		a_b_valid <= 0;
	else if (a_axi_wready && a_axi_wvalid) 
		a_b_valid <= 1;
	else if (a_b_ready)
		a_b_valid <= 0;
end
			
always @(posedge clk) begin
	if (rst) begin
		timer <= 0;
		us_timer <= 0;
	end else begin
		if (us_timer == TCKS_PER_US) begin
			us_timer <= 0;
			timer <= timer + 1;
		end else begin
			us_timer <= us_timer + 1;
		end
	end
end
endmodule






module progloader_axi(
clk,rst,urx,reprogram,busy,
a_axi_araddr,a_axi_arvalid,a_axi_arready,
a_axi_rdata, a_axi_rready, a_axi_rvalid,
a_axi_awaddr,a_axi_awvalid,a_axi_awready,
a_axi_wdata,a_axi_wstrb,a_axi_wvalid,a_axi_wready,
a_b_ready,a_b_valid,a_b_response
);

parameter MEM_ADDR_SIZE = 32;
parameter DATA_WIDTH = 32;
parameter SIMULATION = 0;
parameter CLKS_PER_BIT = 83;

input 				clk;
input 				rst;
input 				urx;
input 				reprogram;

output				busy;

output	reg 	[MEM_ADDR_SIZE-1:0]			a_axi_awaddr;
output	reg						a_axi_awvalid;
input							a_axi_awready;
output	reg 	[DATA_WIDTH-1:0]			a_axi_wdata;
output   	[(DATA_WIDTH>>3)-1:0]			a_axi_wstrb;
output	reg						a_axi_wvalid;
input							a_axi_wready;
output	reg 	[MEM_ADDR_SIZE-1:0]		a_axi_araddr;
output	reg						a_axi_arvalid;
input							a_axi_arready;
input	 	[DATA_WIDTH-1:0]			a_axi_rdata;
input							a_axi_rvalid;
output							a_axi_rready;

output	reg						a_b_ready;
input							a_b_valid;
input 		[1:0]					a_b_response;



wire				w_processing = !a_axi_wready;

reg [7:0] state;
wire rx_dv;
wire [7:0] rx_byte;
reg [7:0] rx_byte_buff;
reg [DATA_WIDTH-1:0] mem_data;

assign a_axi_wstrb = {(DATA_WIDTH>>3){1'b1}};
assign busy = (state > 0) ? 1'b1 : 1'b0;

always @(posedge clk) begin
	if (rst) begin
		a_axi_wvalid <= 0;
		a_axi_awvalid <= 0;
		a_b_ready <= 0;
		a_axi_awaddr <= 0;
		a_axi_wdata <= 0;
		mem_data <= 0;
	
	end else if ((state == 0) && reprogram && w_processing) begin
		a_b_ready <= 1'b1;
		a_axi_wvalid <= a_axi_wready ? 1'b1 : 0;
		a_axi_awvalid <= a_axi_awready ? 1'b1 : 0;
		
	end else if (state == 0) begin
		a_axi_wvalid <= 0;
		a_axi_awvalid <= 0;
		a_b_ready <= 0;
		
	end else if (state == 8'd1) begin
		mem_data  <= {24'd0,rx_byte_buff};
		
	end else if (state == 8'd2) begin
		mem_data <= mem_data | {16'h0,rx_byte_buff, 8'd0};
		
	end else if (state == 8'd3) begin
		mem_data <= mem_data | {8'd0,rx_byte_buff, 16'd0};
		
	end else if (state == 8'd4) begin
		a_axi_awaddr <= mem_data | {rx_byte_buff,24'd0};
		
	end else if (state == 8'd5) begin
		mem_data  <= {24'd0,rx_byte_buff};
		
	end else if (state == 8'd6) begin
		mem_data <= mem_data | {16'h0,rx_byte_buff, 8'd0};
		
	end else if (state == 8'd7) begin
		mem_data <= mem_data | {8'd0,rx_byte_buff, 16'd0};
		
	end else if (state == 8'd8) begin
		a_axi_wdata <= mem_data | {rx_byte_buff,24'd0};
    a_axi_wvalid <= 1'b1;
    a_axi_awvalid <= 1'b1;
		
	end else if (state == 8'd9) begin
		a_axi_wvalid <= 1'b0;
		
	end else if (state == 8'd10) begin
		a_axi_awvalid <= 1'b0;
		
	end else if (state == 8'd11) begin
		a_axi_wvalid <= 1'b0;
		a_axi_awvalid <= 1'b0;
		a_b_ready <= 1'b1;
	end
end


always @(posedge clk) begin
		
	if (rst) begin
		state <= 0;	
		rx_byte_buff <= 0;
		
	end else if ((state == 0) && w_processing) begin
		
	
	end else if (reprogram) begin
	
		if (rx_dv) begin
			state <= state + 8'd1; 
			rx_byte_buff <= rx_byte;
			
		end else if (state == 8'd8) begin	
			if (a_axi_wready && a_axi_awready)
				state <= 8'd11;
			else if (a_axi_wready)
				state <= 8'd9;
			else if (a_axi_awready)
				state <= 8'd10;
				
		end else if (state == 8'd9) begin
			if (a_axi_awready)
				state <= 8'd11;
				
		end else if (state == 8'd10) begin
			if (a_axi_wready)
				state <= 8'd11;
				
		end else if (state == 8'd11) begin
			if (a_b_valid)
				state <= 8'd0;
		end
	end
end
	
generate 
    if (SIMULATION ) begin
        reg [7:0] uart_state;
        reg rx_dv_reg;
        initial rx_dv_reg = 0;
        assign rx_dv = rx_dv_reg;
        reg [31:0] pc;
        initial pc = 0;
        reg [7:0] rx_byte_reg;
        reg [7:0] instrs [0: 1048575];
        
        initial $readmemh("firmware.hex", instrs);
        assign rx_byte = rx_byte_reg; 
	always @(posedge clk) begin
		if (rst || !reprogram) begin
			uart_state <= 0;
			pc <= 0;
			rx_byte_reg <= 0;
			
		end else if ((state == 0) && reprogram && w_processing) begin
		
		end else if (rx_dv_reg) begin
			rx_dv_reg <= 0;
		end else if (uart_state == 0) begin
			if (state == 0)
				uart_state <= uart_state + 8'd1;
		end else if (uart_state == 8'd1) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[7:0];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd2) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[15:8];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd3) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[23:16];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd4) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[31:24];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd5) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd6) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd7) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd8) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= 8'd0;
		end
	end
     
        
end else begin
        uart_rx  #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx(. i_Clock(clk),.i_Rx_Serial(urx),.o_Rx_DV(rx_dv),.o_Rx_Byte(rx_byte));
end
endgenerate			
endmodule


module uart_axi(
clk,
rst,

a_axi_araddr,
a_axi_arvalid,
a_axi_arready,

a_axi_awaddr,
a_axi_awvalid,
a_axi_awready,

a_axi_rdata,
a_axi_rvalid,
a_axi_rready,

a_axi_wdata,
a_axi_wstrb,
a_axi_wvalid,
a_axi_wready,

a_b_ready,
a_b_valid,
a_b_response,

urx,
utx
);


  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32; 
  parameter CLKS_PER_BIT = 83;
  
  input clk;
  input rst;
  
  input [ADDR_WIDTH-1:0] 			a_axi_araddr;
  input 			 	a_axi_arvalid;
  output  			a_axi_arready;

  input [ADDR_WIDTH-1:0] 			a_axi_awaddr;
  input 			 	a_axi_awvalid;
  output 			a_axi_awready;

  output  [DATA_WIDTH-1:0] 		a_axi_rdata;
  output reg		 		a_axi_rvalid;
  input 			 	a_axi_rready;

  input [DATA_WIDTH-1:0] 			a_axi_wdata;
input [(DATA_WIDTH>>3)-1:0] 			a_axi_wstrb;
  input 			 	a_axi_wvalid;
  output 		 	a_axi_wready;

  input 				a_b_ready;
  output 	reg			a_b_valid;
  output [1:0] 		a_b_response;

  input urx;
  output utx;
  
  
  wire rx_dv;
  wire fifo_data_out_valid;
  wire [7:0] rx_byte;
  wire [7:0] a_axi_rdata_int;
  
  assign a_axi_arready = 1'b1;
  assign a_axi_rdata = {DATA_WIDTH{1'b0}} + a_axi_rdata_int;  
  
  always @(posedge clk) begin
	if (rst) 
		a_axi_rvalid <= 0;
	else if (fifo_data_out_valid & a_axi_arvalid) 
		a_axi_rvalid <= 1;
	else if (a_axi_rready)
		a_axi_rvalid <= 0;
end
	
  ring_buffer rx_fifo (.clk(clk), .rst(rst), .data_in_data(rx_byte), .data_in_valid(rx_dv), .data_out_data(a_axi_rdata[7:0]), .data_out_ready(a_axi_rready), .data_out_valid(fifo_data_out_valid));
	
  uart_rx  #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx(
   . i_Clock(clk),
   .i_Rx_Serial(urx),
   .o_Rx_DV(rx_dv),
   .o_Rx_Byte(rx_byte)
   );
   
   
   wire tx_active;
   wire tx_done;
   
   assign a_axi_awready = (tx_active | tx_done) ? 1'b0 : 1'b1;
   assign a_axi_wready = (tx_active | tx_done) ? 1'b0 : 1'b1;
   assign a_b_response = 2'b00;

   
   uart_tx  #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx(
   .i_Clock(clk),
   .i_Tx_DV(a_axi_wready && a_axi_wvalid),
   .i_Tx_Byte(a_axi_wdata[7:0]), 
   .o_Tx_Active(tx_active),
   .o_Tx_Serial(utx),
   . o_Tx_Done(tx_done)
   );
   
  
	always @(posedge clk) begin
		if (rst) 
			a_b_valid <= 0;
		else if (a_axi_wready && a_axi_wvalid) 
			a_b_valid <= 1;
		else if (a_b_ready)
			a_b_valid <= 0;
	end
endmodule














//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_tx (
   input       i_Clock,
   input       i_Tx_DV,
   input [7:0] i_Tx_Byte, 
   output      o_Tx_Active,
   output reg  o_Tx_Serial,
   output      o_Tx_Done
   );
   
   
  parameter CLKS_PER_BIT = 16'd83;
  parameter s_IDLE         = 3'b000;
  parameter s_TX_START_BIT = 3'b001;
  parameter s_TX_DATA_BITS = 3'b010;
  parameter s_TX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
   
  reg [2:0]    r_SM_Main     = 0;
  reg [15:0]    r_Clock_Count = 0;
  reg [2:0]    r_Bit_Index   = 0;
  reg [7:0]    r_Tx_Data     = 0;
  reg          r_Tx_Done     = 0;
  reg          r_Tx_Active   = 0;
     
  always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
        s_IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (i_Tx_DV == 1'b1)
              begin
                r_Tx_Active <= 1'b1;
                r_Tx_Data   <= i_Tx_Byte;
                r_SM_Main   <= s_TX_START_BIT;
              end
            else
              r_SM_Main <= s_IDLE;
          end // case: s_IDLE
         
         
        // Send out Start Bit. Start bit = 0
        s_TX_START_BIT :
          begin
            o_Tx_Serial <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_START_BIT;
              end
            else
              begin
                r_Clock_Count <= 0;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
          end // case: s_TX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        s_TX_DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
             
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count <= 0;
                 
                // Check if we have sent out all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_TX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_TX_STOP_BIT;
                  end
              end
          end // case: s_TX_DATA_BITS
         
         
        // Send out Stop bit.  Stop bit = 1
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_STOP_BIT;
              end
            else
              begin
                r_Tx_Done     <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
                r_Tx_Active   <= 1'b0;
              end
          end // case: s_Tx_STOP_BIT
         
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_Tx_Done <= 1'b1;
            r_SM_Main <= s_IDLE;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end
 
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
   
endmodule


//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_rx 
  (
   input        i_Clock,
   input        i_Rx_Serial,
   output       o_Rx_DV,
   output [7:0] o_Rx_Byte
   );
  parameter CLKS_PER_BIT   = 8'd83;
  parameter s_IDLE         = 3'b000;
  parameter s_RX_START_BIT = 3'b001;
  parameter s_RX_DATA_BITS = 3'b010;
  parameter s_RX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
   
  reg           r_Rx_Data_R = 1'b1;
  reg           r_Rx_Data   = 1'b1;
   
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total
  reg [7:0]     r_Rx_Byte     = 0;
  reg           r_Rx_DV       = 0;
  reg [2:0]     r_SM_Main     = 0;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock)
    begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
   
   
  // Purpose: Control RX state machine
  always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)          // Start bit detected
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
        // Check middle of start bit to make sure it's still low
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule // uart_rx
