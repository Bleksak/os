OUTPUT_FORMAT(binary)
ENTRY(boot)

SECTIONS
{
	. = 0x7C00;

	.boot : {
		*(.boot)
		. = ALIGN(0x200);
	}
	
	STAGE_LOAD_ADDR = .;
	STAGE_LOAD_SEGMENT = . / 0x10;
	STAGE_LOAD_OFFSET = . % 0x10;

	.stage : ALIGN(0x200) {
		CHECKSUM_ADDRESS = .;
		*(.checksum)
		. = ALIGN(0x10);

		STAGE_CODE_ADDR = .;

		*(.stage)
		*(.lib)
		*(.data)
		. = ALIGN(0x200);
		_STAGE2_END = .;
	}

	STAGE_SIZE = SIZEOF(.stage) / 0x200;

	/* Size in 512 byte sectors */
}
