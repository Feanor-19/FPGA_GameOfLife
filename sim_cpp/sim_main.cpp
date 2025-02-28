#include <memory>

#include <verilated.h>
#include "Vtop.h"

int main(int argc, char** argv) 
{
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    contextp->randReset(2);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};

    top->clk = 0;
    top->rst_n = !0;
    
    top->i_cmd_toggle_pause = 0;
    top->i_cmd_load_cfg_1   = 0;
    top->i_cmd_load_cfg_2   = 0;

    top->eval();

    // rst
    contextp->timeInc(1);
    top->rst_n = !1;
    top->clk = 0;
    top->eval();

    contextp->timeInc(1);
    top->rst_n = !0;
    top->clk = 1;
    top->eval();

    // main cycle
    while (!contextp->gotFinish()) {

        contextp->timeInc(1);

        top->clk = !top->clk;

        //@(posedge clk)
        if (top->clk) {
            VL_PRINTF("clk\n");
        }

        top->eval();

        VL_PRINTF("[%" PRId64 "] clk=%x rst_n=%x\n",
            contextp->time(), top->clk, top->rst_n);

        if (contextp->time() >= 100)
            break;
    }

    top->final();

    return 0;
}
