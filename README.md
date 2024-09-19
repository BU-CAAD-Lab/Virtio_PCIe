# Virtio_PCIe
This repo includes the components necessary to implement a Virtio-compliant interface on an FPGA.  
This includes modifications to the PCIe IP cores and a controller to implement virtqueue functionality. The implementation is described in detail in the following:

[1] Bandara, S., Sanaullah, A., Tahir, Z., Drepper, U., and Herbordt, M. (2022). Enabling VirtIO Driver Support on FPGAs. In 8th International Workshop on Heterogeneous High Performance Reconfigurable Computing. doi:10.1109/H2RC56700.2022.00006.  
[2] Bandara, S., Sanaullah, A., Tahir, Z., Drepper, U., and Herbordt, M. (2024c). Performance Evaluation of VirtIO Device Drivers for Host-FPGA PCIe Communication. In 31st Reconfigurable Architectures Workshop (RAW). doi:10.1109/IPDPSW63119.2024.00043.

Example designs targeting Xilinx Artix-7 and Ultrascale+ devices are provided here.  


Generating the designs
======================
