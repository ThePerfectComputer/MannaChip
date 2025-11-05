BUILD = build
BSC = bsc
BDPI_SRC = bdpi/uart_sim_device.c
BDPI_OBJ = $(BUILD)/uart_sim_device.o
DPI_LIB = $(BUILD)/libdpi.so
TOP_MODULE = mkTop
TOP_FILE = bs/Top.bs

BSV_PATH = ./bs:./bsv
BSV_FLAGS = -p +:$(BSV_PATH) -bdir $(BUILD) -vdir $(BUILD) -simdir $(BUILD)
VERILOG_FLAGS = $(BSV_FLAGS) -verilog -u -g $(TOP_MODULE)

$(BUILD):
	mkdir -p $(BUILD)

# === Bluesim ===
$(BDPI_OBJ): $(BDPI_SRC) | $(BUILD)
	$(CC) -c -fPIC $< -o $@

$(BUILD)/mkSim.bo: $(TOP_FILE) | $(BUILD)
	$(BSC) $(BSV_FLAGS) -sim -u -g $(TOP_MODULE) $(TOP_FILE)

sim: $(BDPI_OBJ) $(BUILD)/mkSim.bo
	$(BSC) -sim -bdir $(BUILD) -simdir $(BUILD) -e $(TOP_MODULE) -o build/mkSim $(BDPI_OBJ)

# === Verilog + DPI-C ===
$(DPI_LIB): $(BDPI_SRC) | $(BUILD)
	$(CC) -shared -fPIC -o $@ $<

verilog: $(DPI_LIB)
	$(BSC) $(VERILOG_FLAGS) $(TOP_FILE)
@echo "Verilog generated in: $(BUILD)/$(TOP_MODULE).v"

# Optional: Clean Verilog sim
verilog-sim: verilog
	iverilog -o $(BUILD)/sim_v $(BUILD)/$(TOP_MODULE).v \
		-I $(BLUESPEC_DIR)/Verilog \
		$(BLUESPEC_DIR)/Verilog/main.v
	LD_LIBRARY_PATH=$(BUILD) $(BUILD)/sim_v

clean:
	rm -rf $(BUILD) mkSim

.PHONY: sim verilog verilog-sim clean
