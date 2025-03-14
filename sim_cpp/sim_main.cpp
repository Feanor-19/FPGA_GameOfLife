#include <memory>
#include <iostream>

#include <SFML/Graphics.hpp>

#include <verilated.h>
#include "Vtop.h"

const int H_ACTIVE = 640;
const int V_ACTIVE = 480;
const int H_TOTAL  = H_ACTIVE + 16 + 96 + 48;
const int V_TOTAL  = V_ACTIVE + 10 + 2  + 33;

const sf::Keyboard::Key KEY_PAUSE = sf::Keyboard::Key::Space;
const sf::Keyboard::Key KEY_CFG_1 = sf::Keyboard::Key::Num1;
const sf::Keyboard::Key KEY_CFG_2 = sf::Keyboard::Key::Num2;

void init_and_rst_model(const std::unique_ptr<VerilatedContext>& contextp, const std::unique_ptr<Vtop> &top);

void update_inputs(const std::unique_ptr<Vtop> &top);

sf::Color from_rgb565(uint8_t r5, uint8_t g6, uint8_t b5);

int main(int argc, char** argv) 
{
    // SFML stuff
    sf::RenderWindow window{sf::VideoMode({H_ACTIVE, V_ACTIVE}), "FPGA_GameOfLife",
                            sf::Style::Titlebar | sf::Style::Close};
    
    sf::Image   screen_img{{H_ACTIVE, V_ACTIVE}};
    sf::Texture screen_texture{screen_img};
    sf::Sprite  screen_sprite{screen_texture};
    
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->randReset(2);
    #ifdef TRACE
    contextp->traceEverOn(true);
    #endif
    contextp->commandArgs(argc, argv);
    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};
    
    init_and_rst_model(contextp, top);
    
    // main cycle
    while (!contextp->gotFinish() && window.isOpen()) 
    {
        // handle window events
        while (const std::optional event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>())
                window.close();
        }

        for (uint cur_y = 0; cur_y < V_TOTAL; cur_y++)
        {
            for (uint cur_x = 0; cur_x < H_TOTAL; cur_x++)
            {
                contextp->timeInc(1);
                top->clk = 0;
                top->eval();

                contextp->timeInc(1);
                top->clk = 1;

                //@(posedge clk)
                if ((0 <= cur_x && cur_x <= H_ACTIVE-1) && (0 <= cur_y && cur_y <= V_ACTIVE-1))
                {
                    sf::Color cur_color = from_rgb565(top->o_vga_r, top->o_vga_g, top->o_vga_b);
                    screen_img.setPixel({cur_x, cur_y}, cur_color);       
                }
                top->eval();
            }
            update_inputs(top); // not too often, not too rarely
        }
        
        // update picture
        screen_texture.update(screen_img);
        window.clear();
        window.draw(screen_sprite);
        window.display();
    }

    top->final();

    return 0;
}

void init_and_rst_model(const std::unique_ptr<VerilatedContext>& contextp, const std::unique_ptr<Vtop> &top)
{
    // init
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
}

void update_inputs(const std::unique_ptr<Vtop> &top)
{
    top->i_cmd_toggle_pause = sf::Keyboard::isKeyPressed(KEY_PAUSE);
    top->i_cmd_load_cfg_1   = sf::Keyboard::isKeyPressed(KEY_CFG_1);
    top->i_cmd_load_cfg_2   = sf::Keyboard::isKeyPressed(KEY_CFG_2);
}

sf::Color from_rgb565(uint8_t r5, uint8_t g6, uint8_t b5)
{
    uint8_t r8 = (r5 * 527 + 23) >> 6;
    uint8_t g8 = (g6 * 259 + 33) >> 6;
    uint8_t b8 = (b5 * 527 + 23) >> 6;
    return sf::Color{r8, g8, b8};
}