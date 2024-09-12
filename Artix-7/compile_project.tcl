open_project  ./virtio_net_device_udp_response/virtio_net_device_udp_response.xpr
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs synth_1 -jobs 24 
wait_on_run synth_1
launch_runs -to_step write_bitstream impl_1 -jobs 24
wait_on_run impl_1
