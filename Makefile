ifeq ($(MAKECMDGOALS),run)
ifeq ($(M),)
$(error No file is specified. Please, use 'make run M=*your module name*')
endif
endif

MODULE:=$(M)

EXECUTABLE := ./obj_dir/Vtb_$(MODULE)

# always compile all
SRC   := $(wildcard src/*.sv)

# compile only the one needed and make it top
TB 	  := $(wildcard tb/tb_$(MODULE).sv)

# always compile all
ASRTS := $(wildcard assertions/asrt_*.sv assertions/binds_asrt.sv)

ifeq ($(words $(TB)),1)
MAKE_TOP_TB := --top tb_$(MODULE)
endif

COMPILER := verilator
COMPILER_FLAGS := --binary --trace-fst -j 0 -Wall --x-assign unique

EXECUTABLE_FLAGS := +verilator+seed+50 +verilator+rand+reset+2
DUMP_FILE := dump.svc
OBJ_DIR := obj_dir

ALL_SRCS := $(TB) $(SRC) $(ASRTS)

.PHONY: run waves info

info:
	@echo "Please, use 'make run M=*your module name* to compile corresponding tb."
	@echo "Current targets to compile:" $(ALL_SRCS)
	@echo "MAKE_TOP_TB:" $(MAKE_TOP_TB)

run: $(EXECUTABLE)
	$(EXECUTABLE) $(EXECUTABLE_FLAGS)

$(EXECUTABLE): $(ALL_SRCS)
	$(COMPILER) $(COMPILER_FLAGS) $(MAKE_TOP_TB) $(ALL_SRCS)

$(TB) $(ASRTS): ;

waves:
	@gtkwave $(DUMP_FILE)

clean:
	rm -rf ./$(OBJ_DIR)/
	rm -f $(DUMP_FILE)
