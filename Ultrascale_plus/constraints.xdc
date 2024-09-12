set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR NO [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]

set_property -dict { PACKAGE_PIN AV22    IOSTANDARD DIFF_SSTL18_I } [get_ports {clk_i_p}];
set_property -dict { PACKAGE_PIN AV21    IOSTANDARD DIFF_SSTL18_I } [get_ports {clk_i_n}];
set_property -dict { PACKAGE_PIN AT19   IOSTANDARD LVCMOS18 } [get_ports { uart_tx }];
set_property -dict { PACKAGE_PIN AT20    IOSTANDARD LVCMOS18 } [get_ports { uart_rx }];
set_property -dict { PACKAGE_PIN AL21    IOSTANDARD LVCMOS18 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN AL20    IOSTANDARD LVCMOS18 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN AP21    IOSTANDARD LVCMOS18 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN AP20    IOSTANDARD LVCMOS18 } [get_ports { led[3] }];

set_false_path -to [get_pins -hier *sync_reg[0]/D]




create_clock -period 10.000 -name sys_clk [get_ports {sys_clk_p}]
set_property LOC AT11 [get_ports sys_clk_p]

set_property LOC AT10 [get_ports sys_clk_n]
set_property -dict {PACKAGE_PIN AP26   IOSTANDARD LVCMOS18  PULLUP true} [get_ports {sys_rst_n}]
set_false_path -from [get_ports sys_rst_n]

