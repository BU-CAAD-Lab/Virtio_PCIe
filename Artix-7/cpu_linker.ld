MEMORY {
	.main_memory (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00004000
	.pci_cfg0 (rwx) : ORIGIN = 0x10000000, LENGTH = 0x10000000
	.pci_cfg1 (rwx) : ORIGIN = 0x20000000, LENGTH = 0x10000000
	.debug (rwx) : ORIGIN = 0x80000000, LENGTH = 0x10000000
}

SECTIONS {
	.main_memory : {
		. = 0x0;
		cpu_reset_handler.o;
		start*(.text);
		*(.text);
		*(*);
		end = .;
	}
	.pci_cfg0 0x10000000: {PROVIDE(PCI_CFG0 = .);}
	.pci_cfg1 0x20000000: {PROVIDE(PCI_CFG1 = .);}
	.debug 0x80000000: {PROVIDE(DEBUG = .);}
}

ENTRY(main)