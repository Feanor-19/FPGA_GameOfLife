ifeq ($(MAKECMDGOALS),run)
ifeq ($(M),)
$(error No file is specified. Please, use 'make run M=*your module name*')
endif
endif

MODULE:=$(M)

OBJ_DIR := obj_dir

# always compile all
SRC_RTL := $(wildcard src/*.sv)

# compile only the one needed and make it top
TB := $(wildcard tb/tb_$(MODULE).sv)

# always compile all
ASRTS := $(wildcard assertions/asrt_*.sv assertions/binds.sv)

ifeq ($(words $(TB)),1)
MAKE_TOP_TB := --top tb_$(MODULE)
endif

COMPILER := verilator
COMPILER_FLAGS := --binary --trace-fst -j 0 -Wall --x-assign unique --assert

EXECUTABLE := ./obj_dir/Vtb_$(MODULE)
EXECUTABLE_FLAGS := +verilator+seed+50 +verilator+rand+reset+2
DUMP_FILE := dump.svc

ALL_SRCS :=  $(SRC_RTL) $(TB) $(ASRTS)

.PHONY: run waves info sim_cpp

info:
	@echo "Please, use 'make run M=*your module name* to compile corresponding tb."
	@echo "Or use 'make sim_cpp' to compile and run cpp simulation."
	@echo "Current targets to compile:" $(ALL_SRCS)
	@echo "MAKE_TOP_TB:" $(MAKE_TOP_TB)

run: $(EXECUTABLE)
	$(EXECUTABLE) $(EXECUTABLE_FLAGS)

$(EXECUTABLE): $(ALL_SRCS)
	$(COMPILER) $(COMPILER_FLAGS) $(MAKE_TOP_TB) $(ALL_SRCS)

$(TB) $(ASRTS): ;

sim_cpp:
	$(MAKE) -j -C . -f Makefile_sim_cpp.mk

waves:
	@gtkwave $(DUMP_FILE)

clean:
	rm -rf ./$(OBJ_DIR)/
	rm -f $(DUMP_FILE) $(DUMP_FILE).hier
