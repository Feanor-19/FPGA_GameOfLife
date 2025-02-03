ifeq ($(M),)
$(error No file is specified. Please, use 'make *target* M=*your module name*')
else
MODULE:=$(M)
endif

EXECUTABLE := ./obj_dir/V$(MODULE)

SRC := src/$(MODULE).sv

TB := tb/tb_$(MODULE).sv

# ASSERTIONS := assertions/assertions_$(MODULE).sv \
			  assertions/assertions_binds_$(MODULE).sv


COMPILER := verilator
COMPILER_FLAGS := --binary --trace-fst -j 0 -Wall --x-assign unique

EXECUTABLE_FLAGS := +verilator+seed+50 +verilator+rand+reset+2
DUMP_FILE := dump.svc
OBJ_DIR := obj_dir

ALL_SRCS := $(SRC) $(TB) $(ASSERTIONS)

.PHONY: run waves test

test:
	@echo $(MODULE) $(EXECUTABLE) $(SRC) $(TB)

run: $(EXECUTABLE)
	$(EXECUTABLE) $(EXECUTABLE_FLAGS)

$(EXECUTABLE): $(ALL_SRCS)
	$(COMPILER) $(COMPILER_FLAGS) $(ALL_SRCS)

waves:
	@gtkwave $(DUMP_FILE)

clean:
	rm -rf ./$(OBJ_DIR)/
	rm -f $(DUMP_FILE)
