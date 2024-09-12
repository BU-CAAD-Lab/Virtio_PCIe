set PROJECT cvp13_virtio_net_dev_udp_resp
          config_ip_cache -disable_cache
          create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 -module_name xdma_0
          set_property -dict [list CONFIG.mode_selection {Advanced} CONFIG.pl_link_cap_max_link_width {X16} CONFIG.axi_data_width {128_bit} CONFIG.axisten_freq {250} CONFIG.vendor_id {1AF4} CONFIG.pf0_device_id {1043} CONFIG.pf0_revision_id {01} CONFIG.pf0_subsystem_vendor_id {1AF4} CONFIG.pf0_subsystem_id {1043} CONFIG.axilite_master_en {true} CONFIG.axilite_master_size {4} CONFIG.axilite_master_scale {Kilobytes} CONFIG.pf0_msi_cap_multimsgcap {4_vectors} CONFIG.xdma_axilite_slave {true} CONFIG.xdma_num_usr_irq {4} CONFIG.dsc_bypass_rd {0001} CONFIG.dsc_bypass_wr {0001} CONFIG.xdma_sts_ports {true} CONFIG.pf0_msix_enabled {true} CONFIG.pf0_msix_cap_table_size {01F} CONFIG.pf0_msix_cap_table_offset {00008000} CONFIG.pf0_msix_cap_table_bir {BAR_1} CONFIG.pf0_msix_cap_pba_offset {00008FE0} CONFIG.pf0_msix_cap_pba_bir {BAR_1} CONFIG.cfg_mgmt_if {false} CONFIG.cfg_ext_if {true} CONFIG.PF0_DEVICE_ID_mqdma {901F} CONFIG.PF2_DEVICE_ID_mqdma {901F} CONFIG.PF3_DEVICE_ID_mqdma {901F}] [get_ips xdma_0]
          generate_target all [get_files ./build/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/ip/xdma_0/xdma_0.xci]
          export_ip_user_files -of_objects [get_files ./build/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/ip/xdma_0/xdma_0.xci] -no_script -sync -force -quiet
					create_ip_run [get_files -of_objects [get_fileset sources_1] ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/xdma_0.xci]
					launch_runs xdma_0_synth_1 -jobs 24
					wait_on_run xdma_0_synth_1
          update_compile_order -fileset sources_1
          set_property IS_LOCKED true [get_files xdma_0.xci]
          exec cp ./xdma_0_pcie4_ip.v ./$PROJECT/$PROJECT.srcs/sources_1/ip/xdma_0/ip_0/synth/xdma_0_pcie4_ip.v
          reset_run xdma_0_synth_1
          launch_run xdma_0_synth_1
          wait_on_run xdma_0_synth_1
          
