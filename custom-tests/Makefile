# Build custom test binaries using nexus-am framework
AM_HOME ?= /mnt/data1/yuqixue2/edatools_vm_shared/nexus-am
ARCH = riscv64-xs
TESTS = fp_test atomic_test tlb_mem_test
OUTPUT_DIR = /mnt/data1/yuqixue2/edatools_vm_shared/XiangShan/test-binaries

.PHONY: all clean $(TESTS)

all: $(TESTS)
	@echo "All custom tests built:"
	@ls -la $(OUTPUT_DIR)/custom-*.bin

$(TESTS): %:
	@echo "=== Building $@ ==="
	@mkdir -p build
	@cp $@.c $(AM_HOME)/tests/cputest/tests/$@.c
	$(MAKE) -C $(AM_HOME)/tests/cputest ARCH=$(ARCH) ALL=$@ image 2>&1 | tail -5
	@cp $(AM_HOME)/tests/cputest/build/$@-$(ARCH).bin $(OUTPUT_DIR)/custom-$@.bin
	@rm -f $(AM_HOME)/tests/cputest/tests/$@.c
	@echo "  -> $(OUTPUT_DIR)/custom-$@.bin"

clean:
	rm -f $(OUTPUT_DIR)/custom-*.bin
	rm -rf build
