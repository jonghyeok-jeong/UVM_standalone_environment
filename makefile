#==================================
# argv 1
#==================================

IP_NAME			?= i2c
TEST				?= base_test
SEQ_NUM			?= 1
SERVER			?= #your_linux_server
REG_MODEL		?= UVM_REG_MODEL
SCOREBOARD 	?= SCOREBOARD

#==================================
# argv 2
#==================================

#SPEED				?= STANDARD_SPEED_MODE
#ADDR_MODE		?= ADDRESSING_7BIT

#==================================
# Ral system
#==================================

RAL_SYS 	?= DW_apb_i2c
RAL_FILE	?= DW_apb_i2c_uvm.ralf
export RAL_PATH = # *.ralf file path

#==================================
# Environment
#==================================

export WORKSPACE 			= .
export SVT_PATH				= # you synopsys VIP file (svt) path ex) /synopsys/vip/S-2021.12/src/sverilog/vcs/
export UVM_TB_PATH		= .
ifeq ($(SERVER),YourServerA)
MODULEPATH = #Your module path ex) /MODULES/defualt/init/bash
else
MODULEPATH = $$MODULEHOME/init/bash
endif

#==================================
# Module Version
#==================================

VCS_ver						= synopsys/#Version ex)R-2020.12-SP2-2
VERDI_ver					= synopsys/verdi/#Version ex) R-2020.12-SP2
DESIGNWARE_ver		= synopsys/designware/#Version ex) S-2021.09
GCC_ver						= gcc/gcc/7.5.0

#==================================
# VCS option
#==================================
VCS_opt = -l ./compile.log
VCS_opt += -q -Mdir=./build/csrc
VCS_opt += -ntb_opts uvm -full64 -sverilog
VCS_opt += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VCS_opt += -timescale=1ns/1ps
VCS_opt += +define+SVT_FSDB_ENABLE
VCS_opt += +define+UVM_PACKER_MAX_BYTES=1500000
VCS_opt += +define+WAVES_FSDB
VCS_opt += +define+WAVES=\"fsdb\"
VCS_opt += +define+SVT_APB_PADDR_WIDTH=8
VCS_opt += +define+SVT_APB_PWDATA_WIDTH=32
VCS_opt += +define+SVT_APB_MAX_NUM_SLAVE=1
VCS_opt += +define+SVT_APB_MAX_NUM_SLAVE_0
VCS_opt += +define+SVT_UVM_TECHNOLOGY
VCS_opt += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VCS_opt += +define+SYNOPSYS_SV
VCS_opt += +define+SVT_I2C_IF_ENABLE_RST_VIA_PORT
VCS_opt += +define+SVT_I2C_SLV_SCL_STRENGTH=strong0,pull1
VCS_opt += +define+SVT_I2C_SLV_SDA_STRENGTH=strong0,pull1
VCS_opt += +define+SVT_UVM_TECHNOLOGY
VCS_opt += +define+SVT_I2C_IF_ENABLE_RST_VIA_PORT
VCS_opt += +define+$(REGMODEL)
VCS_opt += +define+$(SCOREBOARD)
VCS_opt += +define+SEQ_NUM=$(SEQ_NUM)
VCS_opt += +define+$(REG_MODEL)
VCS_opt += +plusarg_save -debug_access+pp+dmptf+thread
VCS_opt += -debug_region=cell+encrypt -notice -P
VCS_opt += /tools/synopsys/verdi/R-2020.12-SP2-2/share/PLI/VCS/LINUX64/novas.tab
VCS_opt += /tools/synopsys/verdi/R-2020.12-SP2-2/share/PLI/VCS/LINUX64/pli.a
VCS_opt += +define+SVT_UVM_TECHNOLOGY
VCS_opt += +define+SYNOPSYS_SV
VCS_opt += +lint=TFIPC-L
#==================================
# VCS Include files
#==================================

VCS_file = +incdir+/data/IP/IP-INVENTORY/synopsys/vip/S-2021.12/include/sverilog
VCS_file += +incdir+/data/IP/IP-INVENTORY/synopsys/vip/S-2021.12/include/verilog
VCS_file += +incdir+/data/IP/IP-INVENTORY/synopsys/vip/S-2021.12/src/sverilog/vcs
VCS_file += +incdir+/data/IP/IP-INVENTORY/synopsys/vip/S-2021.12/src/verilog/vcs
VCS_file += +incdir+$(UVM_TB_PATH)/.
VCS_file += +incdir+$(UVM_TB_PATH)/ral_files
VCS_file += +incdir+$(UVM_TB_PATH)/env
VCS_file += +incdir+$(UVM_TB_PATH)/env/include
VCS_file += +incdir+$(UVM_TB_PATH)/env/seqs
VCS_file += +incdir+$(UVM_TB_PATH)/env/config
VCS_file += +incdir+$(UVM_TB_PATH)/verif_top/hdl_interconnect
VCS_file += +incdir+$(UVM_TB_PATH)/lib
VCS_file += +incdir+$(UVM_TB_PATH)/tests
VCS_file += +incdir+$(UVM_TB_PATH)/
VCS_file += -o ./build/simv -f ./verif_top/top_files -f ./verif_top/hdl_interconnect/hdl_files

#==================================
# SIMV option
#==================================

SIM_opt = +UVM_TESTNAME=$(TEST)
SIM_opt += -l sim.log
SIM_opt += ./log/simulate__base_test.log
SIM_opt += run
SIM_opt += +$(SPEED) +$(ADDR_MODE)

#==================================
# EXECUTE
#==================================

all: clean comp sim

comp:
	mkdir build; source $(MODULEPATH); module load $(VCS_ver) $(VERDI_ver) $(DESIGNWARE_ver) $(GCC_ver); \
	vcs $(VCS_opt) $(VCS_file)

sim:
	mkdir waveform; cd waveform; \
	source $(MODULEPATH); module load $(VCS_ver) $(VERDI_ver) $(DESIGNWARE_ver) $(GCC_ver); \
	../build/simv $(SIM_opt);

open:
	cd ./waveform; verdi -ssf sim.fsdb

clean:
	rm -rf compile.log ./build ./waveform ./verdiLog novas.conf novas.rc

clean_comp:
	rm -rf compile.log ./build ./verdiLog novas.conf novas.rc

clean_dump:
	rm -rf compile.log ./waveform ./verdiLog novas.conf novas.rc

ral:
	ralgen -uvm -t $(RAL_SYS) $(RAL_PATH)/$(RAL_FILE); \
	mv ral_$(RAL_SYS).sv ./ral_files
# if ($ make ral) is not avail, enter the server scv01 and use upper command except for srun.
