`timescale 1ns / 1ps
// Engineer: Troy Donnahoo
// Design Name: Transmitter
// Module Name: uart_tx

module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600,
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
)(
    input logic clk,
    input logic reset,
    input logic tx_start,
    input logic [7:0] tx_data,
    output logic tx,
    output logic tx_busy
);
    logic [$clog2(CLKS_PER_BIT)-1:0] baud_count;
    logic [2:0] bit_index;
    logic [7:0] tx_data_reg;
    logic [1:0] state;
    logic [1:0] next_state;
        //State Assignement:
        // 00 = IDLE
        // 01 = START
        // 10 = DATA
        // 11 = STOP

    always_ff @ (posedge clk or posedge reset) begin //D FF
        if (reset)
            state <= 2'b00;
        else
            state <= next_state;
    end
    
    always_ff @(posedge clk or posedge reset) begin //baud counter
        if (reset)
            baud_count <= 0;
        else if (state == 2'b00)
            baud_count <= 0;
        else if (baud_count == (CLKS_PER_BIT - 1))
            baud_count <= 0;
        else
            baud_count <= baud_count + 1;
    end
    
    
    // Not in DATA State, bit index = 0, In DATA State, wait until one UART Bit period finishes then increment
    always_ff @ (posedge clk or posedge reset) begin //bit counter
        if (reset)
            bit_index <= 0;
        else if (state != 2'b10)
            bit_index <= 0;
        else if (baud_count == CLKS_PER_BIT - 1) begin
            if (bit_index < 7)
                bit_index <= bit_index + 1;
        end
    end
            
    always_ff @ (posedge clk or posedge reset) begin //tx_data_reg freezes the byte internally until all 8 bits are sent out
        if (reset)
            tx_data_reg <= 8'b0;
        else if ((state == 2'b00) && tx_start)
            tx_data_reg <= tx_data;
    end
    
    
    
   
    always_comb begin //next-state comb logic
        next_state = state;
        case(state)
            2'b00 : begin //idle begin
                if (tx_start)
                    next_state = 2'b01;
                end
            
            2'b01 : begin //start 
                //wait one baud period
                if (baud_count == CLKS_PER_BIT - 1)
                    next_state = 2'b10;
            end
            
            2'b10 : begin //Data
                //send 8 bits
                if ((baud_count == CLKS_PER_BIT - 1) && (bit_index == 7))
                    next_state = 2'b11;
            end
            
            2'b11 : begin //STOP
                //wait one baud period then return to idle
                if (baud_count == CLKS_PER_BIT - 1)
                    next_state = 2'b00;
            end
            
            default : begin
                next_state = 2'b00;
            end
    endcase
    end
    
    always_comb begin //output logic
        tx = 1'b1;
        tx_busy = 1'b1;
        
        case (state)
            2'b00 : begin //IDLE
                tx = 1'b1;
                tx_busy = 1'b0;
            end
            
            2'b01 : begin //Start
                tx = 1'b0;
            end
            
            2'b10 : begin //DATA
                tx = tx_data_reg[bit_index];
            end
            
            2'b11 : begin //STOP
                tx = 1'b1;
            end
            
            default : begin
                tx = 1'b1;
                tx_busy = 1'b0;
            end
        endcase
   end
endmodule
