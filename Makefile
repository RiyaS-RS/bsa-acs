## @file
 # Copyright (c) 2023, Arm Limited or its affiliates. All rights reserved.
 # SPDX-License-Identifier : Apache-2.0
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #  http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 ##

default: all

BSA_ROOT:= $(BSA_PATH)
BSA_DIR := $(BSA_ROOT)/baremetal_app/

CFLAGS    += -I$(BSA_ROOT)/
CFLAGS    += -I$(BSA_ROOT)/baremetal_app

OUT_DIR = $(BSA_ROOT)/build
OBJ_DIR := $(BSA_ROOT)/build/obj
LIB_DIR := $(BSA_ROOT)/build/lib
FILES   += $(foreach files,$(BSA_DIR),$(wildcard $(files)/*.c))
FILE    = `find $(FILES) -type f -exec sh -c 'echo {} $$(basename {})' \; | sort -u --stable -k2,2 | awk '{print $$1}'`
FILE_1  := $(shell echo $(FILE))
XYZ     := $(foreach a,$(FILE_1),$(info $(a)))
PAL_OBJS :=$(addprefix $(OBJ_DIR)/,$(addsuffix .o, $(basename $(notdir $(foreach dirz,$(FILE_1),$(dirz))))))

CC = $(GCC49_AARCH64_PREFIX)gcc -march=armv8.2-a -DTARGET_EMULATION
AR = $(GCC49_AARCH64_PREFIX)ar

compile:
	make -f $(BSA_ROOT)/platform/pal_baremetal.mk all
	make -f $(BSA_ROOT)/val/val.mk all
	make -f $(BSA_ROOT)/test_pool/test_pool.mk all

create_dirs:
	rm -rf ${OBJ_DIR}
	rm -rf ${LIB_DIR}
	rm -rf ${OUT_DIR}
	@mkdir ${OUT_DIR}
	@mkdir ${OBJ_DIR}
	@mkdir ${LIB_DIR}

$(OBJ_DIR)/%.o: $(BSA_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(LIB_DIR)/lib_bsa.a: $(PAL_OBJS)
	$(AR) $(ARFLAGS) $@ $^ >> $(OUT_DIR)/link.log 2>&1

PAL_LIB: $(LIB_DIR)/lib_bsa.a

clean:
	rm -rf ${OBJ_DIR}
	rm -rf ${LIB_DIR}
	rm -rf ${OUT_DIR}

all: create_dirs compile PAL_LIB

.PHONY: all PAL_LIB
