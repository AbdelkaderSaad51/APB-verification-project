/////////////////////////////////////////////////////////////////////////////////////
// Engineer: - Mohamed Ahmed 
//           - Mostafa Akram 
//
// Create Date:    20/10/2024 
// Design Name:    apb_slave
// Module Name:    apb - Behavioral 
// Project Name:   System-on-Chip (SoC) Integration
// Tool versions:  Questa Sim-64 2021.1
// Description:     APB Master module for System-on-Chip Integration project.
//
//  
//
/////////////////////////////////////////////////////////////////////////////////////
module apb_master(master_arb_if.DUT mast_inter);

logic i_rd0_wr1_reg;
logic [31:0] i_addr_reg , i_wr_data_reg;
    // FSM states
    typedef enum logic [1:0] {
        IDLE   = 2'b00,  // Idle state
        SETUP  = 2'b01,  // Setup state
        ACCESS = 2'b10   // Access state (read/write operation)
    } state_t;

    state_t state, next_state;

    // State transition logic (Sequential block)
    always @(posedge mast_inter.i_clk_apb or negedge mast_inter.i_rstn_apb) begin
        if (!mast_inter.i_rstn_apb) begin
            state <= IDLE;  // Reset state is IDLE
        end 
        else begin
            state <= next_state;  // Move to the next state on each clock cycle
        end
    end
    
    always @(posedge mast_inter.i_clk_apb or negedge mast_inter.i_rstn_apb) begin
        if (!mast_inter.i_rstn_apb) begin
            i_rd0_wr1_reg <= 'b0;
            i_addr_reg <= 'b0;
            i_wr_data_reg <= 'b0;
        end else if (mast_inter.o_ready && mast_inter.i_valid) begin
            i_rd0_wr1_reg <= mast_inter.i_rd0_wr1;
            i_addr_reg <= mast_inter.i_addr;
            i_wr_data_reg <= mast_inter.i_wr_data;
        end
    end

    // Combinational logic block for FSM and output logic
    always @(*) begin
    
        case (state)
            IDLE: begin
                // Default values for all outputs
                mast_inter.o_psel = 1'b0;
                mast_inter.o_penable = 1'b0;
                mast_inter.o_pwrite = 1'b0;
                mast_inter.o_rd_valid = 1'b0;
                mast_inter.o_rd_data = 32'b0;
                mast_inter.o_paddr = 32'b0;
                mast_inter.o_pwdata = 32'b0;
                mast_inter.o_ready = 1'b1;  // Master is ready by default
                // In IDLE, wait for valid transaction
                if (mast_inter.i_valid) begin
                    next_state = SETUP;  // Move to SETUP when transaction is valid
                end
                else begin
                    next_state = IDLE;  // Stay in IDLE if no valid transaction
                end
            end

            SETUP: begin
                // In SETUP, configure APB signals for read/write operation
                mast_inter.o_penable = 1'b0;
                mast_inter.o_rd_valid = 1'b0;
                mast_inter.o_rd_data = 32'b0;
                mast_inter.o_psel = 1'b1;                  // Select the peripheral
                mast_inter.o_pwrite = i_rd0_wr1_reg;       // Set write/read based on control signal
                mast_inter.o_paddr =i_addr_reg;           // Set address for transaction
                if (i_rd0_wr1_reg == 1'b1) begin
                    mast_inter.o_pwdata =i_wr_data_reg;   // Set write data if it's a write operation
                end else begin
                    mast_inter.o_pwdata = 'b0 ;
                end 
                mast_inter.o_ready = 1'b0;           // Master is busy now
                next_state = ACCESS;      // Move to ACCESS phase
            end

            ACCESS: begin
                // In ACCESS, enable peripheral and check for completion
                mast_inter.o_penable = 1'b1;          // Enable the peripheral for data transfer
                mast_inter.o_ready = 1'b0;            // Master is still busy
                mast_inter.o_psel = 1'b1;             // Select the peripheral
                mast_inter.o_pwrite = i_rd0_wr1_reg;  // Set write/read based on control signal
                mast_inter.o_paddr = i_addr_reg;      // Set address for transaction
                if (mast_inter.i_pready) begin        // Wait for slave to be ready
                    if (i_rd0_wr1_reg == 1'b0) begin
                        mast_inter.o_rd_data = mast_inter.i_prdata;   // Capture read data from slave
                        mast_inter.o_pwdata = 'b0 ;
                        mast_inter.o_rd_valid = 1'b1;      // Indicate valid read data
                    end else begin
                        mast_inter.o_rd_data = 'b0 ;
                        mast_inter.o_pwdata =i_wr_data_reg;   // Set write data if it's a write operation
                        mast_inter.o_rd_valid = 1'b0;      
                    end

                    mast_inter.o_ready = 1'b1;         // Master is ready for next transaction

                    if (mast_inter.i_valid) begin
                                 
                        next_state = SETUP;     // Move to SETUP if a new valid transaction is present 
                    end
                    else begin
                        
                        next_state = IDLE;      // Return to IDLE after transaction completes
                    end
                end
                else begin
                    mast_inter.o_rd_data = 'b0;   // Capture read data from slave
                    mast_inter.o_pwdata = i_wr_data_reg ;
                    mast_inter.o_rd_valid = 1'b0;      // Indicate valid read data
                    next_state = ACCESS;        // Stay in ACCESS if slave is not ready yet
                end
            end

            default: begin
                next_state = IDLE;              // Default state is IDLE
            end
        endcase
    end


///////////////////////////////////////////////////////////////////////////////
//sequence for assertions usage

sequence idle_phase; 
   !mast_inter.o_psel ;
endsequence

sequence setup_phase ;
   mast_inter.o_psel && !mast_inter.o_penable ;
endsequence

sequence access_phase_wait ;
   mast_inter.o_psel && mast_inter.o_penable && !mast_inter.i_pready ;
endsequence
sequence access_phase_last ;
   mast_inter.o_psel && mast_inter.o_penable && mast_inter.i_pready ;
endsequence;

///////////////////////////////////////////////////////////////////////////////
// Assert that the state transitions correctly from IDLE to SETUP when i_valid is asserted
property p1;
    @(posedge mast_inter.i_clk_apb) disable iff (!mast_inter.i_rstn_apb)
        (state == IDLE && mast_inter.i_valid) |-> (next_state == SETUP);
endproperty assert property (p1);

// Assert that the state transitions from SETUP to ACCESS
property p2;
    @(posedge mast_inter.i_clk_apb) disable iff (!mast_inter.i_rstn_apb)
        (state == SETUP) |-> (next_state == ACCESS);
endproperty assert property (p2);

// Assert that the state transitions from ACCESS to IDLE or SETUP based on i_valid signal
property p3;
    @(posedge mast_inter.i_clk_apb) disable iff (!mast_inter.i_rstn_apb)
        (state == ACCESS && mast_inter.i_pready && !mast_inter.i_valid) |-> (next_state == IDLE);
endproperty assert property (p3);

property p4;
    @(posedge mast_inter.i_clk_apb) disable iff (!mast_inter.i_rstn_apb)
        (state == ACCESS && mast_inter.i_pready && mast_inter.i_valid) |-> (next_state == SETUP);
endproperty assert property (p4);

// Assert that o_rd_valid is asserted only for read transactions and when i_pready is high
property p5;
    @(posedge mast_inter.i_clk_apb) disable iff (!mast_inter.i_rstn_apb)
        (state == ACCESS && mast_inter.i_pready && i_rd0_wr1_reg == 1'b0) |-> mast_inter.o_rd_valid == 1'b1;
endproperty assert property (p5);

// Assert that o_rd_data is valid only when o_rd_valid is asserted
property p6;
    @(posedge mast_inter.i_clk_apb) disable iff (!mast_inter.i_rstn_apb)
        (mast_inter.o_rd_valid) |-> (mast_inter.o_rd_data == mast_inter.i_prdata);
endproperty assert property (p6);




 

cover property(p1);
cover property(p2);
cover property(p3);
cover property(p4);
cover property(p5);
cover property(p6);




endmodule
