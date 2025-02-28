WORKSPACE_DIR := ..
OBJ_DIR := obj_dir

EXECUTABLE := $(OBJ_DIR)/Vtop

SRC_RTL := $(wildcard $(WORKSPACE_DIR)/src/*.sv)

SRC_CPP := $(wildcard *.cpp)

ASRTS := $(wildcard $(WORKSPACE_DIR)/assertions/asrt_*.sv assertions/binds_asrt.sv)

COMPILER := verilator
COMPILER_FLAGS := --cc --exe --build --trace-fst -j 0 -Wall --x-assign unique --assert

EXECUTABLE_FLAGS := +verilator+seed+50 +verilator+rand+reset+2 +trace
DUMP_FILE := dump.svc

ALL_SRCS := $(SRC_RTL) $(ASRTS) $(SRC_CPP)

TOP_FILE := $(wildcard $(WORKSPACE_DIR)/src/top.sv)

ifeq ($(words $(TOP_FILE)),1)
EXPLICIT_TOP := --top top
endif

run: $(EXECUTABLE)
	$(EXECUTABLE) $(EXECUTABLE_FLAGS)

$(EXECUTABLE): $(ALL_SRCS)
	$(COMPILER) $(COMPILER_FLAGS) $(EXPLICIT_TOP) $(ALL_SRCS)

$(ASRTS): ;

waves:
	@gtkwave $(DUMP_FILE)

clean:
	rm -rf $(OBJ_DIR)
	rm -f $(DUMP_FILE)
