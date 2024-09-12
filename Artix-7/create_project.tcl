create_project -force virtio_net_device_udp_response ./virtio_net_device_udp_response/ -part xc7a200tfbg484-2

add_files -fileset constrs_1 ./constraints.xdc
add_files -scan_for_includes .
update_compile_order -fileset sources_1
set_property top top [current_fileset]
update_compile_order -fileset sources_1
set PROJECT virtio_net_device_udp_response
          create_ip -name blk_mem_gen -vendor xilinx.com -library ip  -module_name blk_mem_gen_1
          set_property -dict [list CONFIG.Component_Name {blk_mem_gen_1} CONFIG.Interface_Type {AXI4} CONFIG.Use_AXI_ID {true} CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Use_Byte_Write_Enable {true} CONFIG.Byte_Size {8} CONFIG.Assume_Synchronous_Clk {true} CONFIG.Write_Width_A {32} CONFIG.Write_Depth_A {8192} CONFIG.Read_Width_A {32} CONFIG.Operating_Mode_A {READ_FIRST} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Operating_Mode_B {READ_FIRST} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Use_RSTB_Pin {true} CONFIG.Reset_Type {ASYNC} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.EN_SAFETY_CKT {true}] [get_ips blk_mem_gen_1]
          generate_target all [get_files  ./$PROJECT/$PROJECT.srcs/sources_1/ip/blk_mem_gen_1/blk_mem_gen_1.xci]
          export_ip_user_files -of_objects [get_files ./build/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/ip/blk_mem_gen_1/blk_mem_gen_1.xci] -no_script -sync -force -quiet
					create_ip_run [get_files -of_objects [get_fileset sources_1] ./$PROJECT/$PROJECT.srcs/sources_1/ip/blk_mem_gen_1/blk_mem_gen_1.xci]
					launch_runs blk_mem_gen_1_synth_1 -jobs 24
					wait_on_run blk_mem_gen_1_synth_1
          update_compile_order -fileset sources_1
          
          config_ip_cache -disable_cache
          create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 -module_name xdma_0
          set_property -dict [list CONFIG.mode_selection {Advanced} CONFIG.pl_link_cap_max_link_width {X4} CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} CONFIG.axi_data_width {128_bit} CONFIG.axisten_freq {125} CONFIG.vendor_id {1AF4} CONFIG.pf0_device_id {1040} CONFIG.pf0_revision_id {01} CONFIG.pf0_subsystem_vendor_id {1AF4} CONFIG.pf0_subsystem_id {1040} CONFIG.axilite_master_en {true} CONFIG.axilite_master_size {4} CONFIG.axilite_master_scale {Kilobytes} CONFIG.pf0_msi_cap_multimsgcap {4_vectors} CONFIG.xdma_axilite_slave {true} CONFIG.xdma_num_usr_irq {4} CONFIG.plltype {QPLL1} CONFIG.dsc_bypass_rd {0001} CONFIG.dsc_bypass_wr {0001} CONFIG.xdma_sts_ports {true} CONFIG.pf0_msix_enabled {true} CONFIG.pf0_msix_cap_table_size {01F} CONFIG.pf0_msix_cap_table_offset {00008000} CONFIG.pf0_msix_cap_table_bir {BAR_1} CONFIG.pf0_msix_cap_pba_offset {00008FE0} CONFIG.pf0_msix_cap_pba_bir {BAR_1} CONFIG.cfg_mgmt_if {false} CONFIG.PF0_DEVICE_ID_mqdma {9024} CONFIG.PF2_DEVICE_ID_mqdma {9224} CONFIG.PF3_DEVICE_ID_mqdma {9324} CONFIG.PF0_SRIOV_VF_DEVICE_ID {A034} CONFIG.PF1_SRIOV_VF_DEVICE_ID {A134} CONFIG.PF2_SRIOV_VF_DEVICE_ID {A234} CONFIG.PF3_SRIOV_VF_DEVICE_ID {A334}] [get_ips xdma_0]
          generate_target all [get_files ./build/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/ip/xdma_0/xdma_0.xci]
          export_ip_user_files -of_objects [get_files ./build/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/ip/xdma_0/xdma_0.xci] -no_script -sync -force -quiet
					create_ip_run [get_files -of_objects [get_fileset sources_1] ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/xdma_0.xci]
					launch_runs xdma_0_synth_1 -jobs 24
					wait_on_run xdma_0_synth_1
          update_compile_order -fileset sources_1
          set_property IS_LOCKED true [get_files xdma_0.xci]
          exec cp ../fpga/boards/alinx_ax7a200t/includes/hdl/xdma_0_axi_stream_intf.sv ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/xdma_v4_1/hdl/verilog/xdma_0_axi_stream_intf.sv
          exec cp ../fpga/boards/alinx_ax7a200t/includes/hdl/xdma_0_pcie2_ip_core_top.v ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/ip_0/source/xdma_0_pcie2_ip_core_top.v
          exec cp ../fpga/boards/alinx_ax7a200t/includes/hdl/xdma_0_rx_demux.sv ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/xdma_v4_1/hdl/verilog/xdma_0_rx_demux.sv
          exec cp ../fpga/boards/alinx_ax7a200t/includes/hdl/xdma_0_tgt_req.sv ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/xdma_v4_1/hdl/verilog/xdma_0_tgt_req.sv
          exec cp ../fpga/boards/alinx_ax7a200t/includes/hdl/xdma_0_tgt_cpl.sv ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/xdma_v4_1/hdl/verilog/xdma_0_tgt_cpl.sv
          reset_run xdma_0_synth_1
          launch_run xdma_0_synth_1
          wait_on_run xdma_0_synth_1
          
