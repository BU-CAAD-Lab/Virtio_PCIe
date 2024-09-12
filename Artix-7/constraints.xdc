set_property LOC IBUFDS_GTE2_X0Y3 [get_cells refclk_ibuf]
create_clock -period 10.000 -name sys_clk [get_ports {sys_clk_p}] 


set_property -dict {PACKAGE_PIN L16   IOSTANDARD LVCMOS18  PULLUP true} [get_ports {sys_rst_n}]
set_false_path -from [get_ports sys_rst_n]

set_property -dict {PACKAGE_PIN L15   IOSTANDARD LVCMOS18} [get_ports { uart_tx }]
set_property -dict {PACKAGE_PIN L14    IOSTANDARD LVCMOS18} [get_ports { uart_rx }]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]




