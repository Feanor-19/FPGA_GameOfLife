OBJ_DIR := obj_dir

EXECUTABLE := $(OBJ_DIR)/Vtop

SRC_RTL := $(wildcard src/*.sv)

SRC_CPP := $(wildcard sim_cpp/*.cpp)

ASRTS := $(wildcard assertions/asrt_*.sv assertions/binds_asrt.sv)

COMPILER := verilator
COMPILER_FLAGS := --cc --exe --trace-fst -j 0 -Wall --x-assign fast --assert

EXECUTABLE_FLAGS := +verilator+seed+50 +verilator+rand+reset+2

ifeq ($(TRACE),1)
EXECUTABLE_FLAGS += +trace
endif

DUMP_FILE := dump.svc

ALL_SRCS := $(SRC_RTL) $(ASRTS) $(SRC_CPP)

TOP_FILE := $(wildcard src/top.sv)

ifeq ($(words $(TOP_FILE)),1)
EXPLICIT_TOP := --top top
endif

run: $(EXECUTABLE)
	$(EXECUTABLE) $(EXECUTABLE_FLAGS)

$(EXECUTABLE): $(ALL_SRCS)
	$(COMPILER) $(COMPILER_FLAGS) $(EXPLICIT_TOP) $(ALL_SRCS)
	$(MAKE) -j -C obj_dir -f ../sim_cpp/Makefile_obj.mk 

$(ASRTS): ;

waves:
	@gtkwave $(DUMP_FILE)

clean:
	rm -rf $(OBJ_DIR)
	rm -f $(DUMP_FILE) $(DUMP_FILE).hier
