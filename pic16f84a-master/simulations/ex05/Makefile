# Makefile for running the GHDL simulation and analyze the resulting signals with GTKWave

# the path of the vhdl directory relative to the Makefile
VHDL_PATH = ../../vhdl/ex05/

# the vhdl files you want to compile
FILES =	$(VHDL_PATH)operation_package.vhd $(VHDL_PATH)tb_ex05.vhd $(VHDL_PATH)W_register.vhd $(VHDL_PATH)memory_block.vhd $(VHDL_PATH)alu_easier.vhd $(VHDL_PATH)pic.vhd

TESTBENCH = tb_ex05
# testbench parameters
WORKDIR = work

# GHDL config
GHDL_CMD 	= ghdl
GHDL_FLAGS 	= --std=08 --workdir=$(WORKDIR)

# wave viewer config
WAVEFORM_VIEWER = gtkwave

all: clean make run view

make:
ifeq ($(strip $(TESTBENCH)),)
	echo "TESTBENCH missing. Call with TESTBENCH=<tb_entity_name>."
	exit 1
endif

	mkdir -p $(WORKDIR)
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(FILES)
	$(GHDL_CMD) -e $(GHDL_FLAGS) $(TESTBENCH)

run:
	$(GHDL_CMD) -r $(GHDL_FLAGS) --workdir=$(WORKDIR) $(TESTBENCH) --wave=$(TESTBENCH).ghw
	mv $(TESTBENCH).ghw $(WORKDIR)/

view:
	$(WAVEFORM_VIEWER) --dump=$(WORKDIR)/$(TESTBENCH).ghw

clean:
	rm -rf $(WORKDIR)
