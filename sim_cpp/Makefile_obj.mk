# -*- Makefile -*-
#######################################################################
#
# DESCRIPTION: Verilator Example: Makefile for inside object directory
#
# This is executed in the object directory, and called by ../Makefile
#
# This file ONLY is placed under the Creative Commons Public Domain, for
# any use, without warranty, 2020 by Wilson Snyder.
# SPDX-License-Identifier: CC0-1.0
#
#######################################################################

default: Vtop

# Include the rules made by Verilator
include Vtop.mk

# Use OBJCACHE (ccache) if using gmake and its installed
COMPILE.cc = $(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c

#######################################################################
# Compile flags

# Turn on creating .d make dependency files
CPPFLAGS += -MMD -MP

# Compile in Verilator runtime debugging, so +verilator+debug works
CPPFLAGS += -DVL_DEBUG=1

ifeq ($(TRACE),1)
CPPFLAGS += -DTRACE
endif

# SFML libs
LIBS += -lsfml-graphics -lsfml-window -lsfml-system

# Turn on some more compiler lint flags (when configured appropriately)
# For testing inside Verilator, "configure --enable-ccwarn" will do this
# automatically; otherwise you may want this unconditionally enabled
ifeq ($(CFG_WITH_CCWARN),yes)  # Local... Else don't burden users
USER_CPPFLAGS_WALL += -W -Werror -Wall
endif

# Fast path optimizations.  Most time is spent in these classes.
OPT_FAST = -Os -fstrict-aliasing

######################################################################
######################################################################
# Automatically understand dependencies

DEPS := $(wildcard *.d)
ifneq ($(DEPS),)
include $(DEPS)
endif
