`timescale 1ns / 1ps
// Engineer: Troy Donnahoo
// Design Name: Receiver
// Module Name: uart_rx

//when rx goes low, want to wait half a UART Bit --> CLKS_PER_BIT/2

module uart_rx #(parameter CLK_FREQ = 100_000_000, 
                 parameter BAUD_RATE = 9600, 
                 parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE)
    (
    input logic clk, reset, rx, 
    output logic [7:0] rx_data, output logic rx_valid
    );
    
    logic [$clog2(CLKS_PER_BIT)-1:0] baud_count; //$clog2 to round up
    logic [7:0] rx_data_reg;
    logic [2:0] bit_index;
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
    
    always_ff @ (posedge clk or posedge reset) begin //Baud Counter
        if (reset)
            baud_count <= 0;
            
        else if (state == 2'b00) begin
            baud_count <= 0;
        end
        
        else if (state == 2'b01) begin //Start
            if (baud_count == (CLKS_PER_BIT / 2) - 1)
                baud_count <= 0;
            else
                baud_count <= baud_count + 1;
        end
        
        else begin //DATA or STOP
            if (baud_count == CLKS_PER_BIT - 1)
                baud_count <= 0;
            else
                baud_count <= baud_count + 1;
        end
    end
    

    always_ff @ (posedge clk or posedge reset) begin //wait one full UART bit period
        if (reset) begin
            bit_index <= 0;
            rx_data_reg <= 8'b0;
        end
        
        else if (state != 2'b10) begin
            bit_index <= 0;
        end
        
        else if (baud_count == CLKS_PER_BIT - 1) begin
            rx_data_reg[bit_index] <= rx;
            
            if (bit_index < 7)
                bit_index <= bit_index + 1;
        end
    end
    
    always_ff @ (posedge clk or posedge reset) begin
        if (reset) begin
            rx_data <= 8'b0;
            rx_valid <= 1'b0;
        end
        
        else begin
            rx_valid <= 1'b0; //valid is only a one-clock pulse
            
            if ((state == 2'b11) && (baud_count == CLKS_PER_BIT - 1)) begin
                if (rx == 1'b1) begin
                    rx_data <= rx_data_reg;
                    rx_valid <= 1'b1;
                end
            end
        end
    end



    always_comb begin //state combinational
        next_state = state; //prevent latch problem
        
        case (state)
            
            2'b00 : begin //IDLE
                if (rx == 1'b0)
                    next_state = 2'b01;
            end
            
            2'b01 : begin //START
                if (baud_count == (CLKS_PER_BIT / 2) - 1) begin
                    if (rx == 1'b0)
                        next_state = 2'b10;
                    else
                        next_state = 2'b00;
                end
            end
            
            2'b10 : begin //DATA
                if ((baud_count == CLKS_PER_BIT - 1) && (bit_index == 7))
                    next_state = 2'b11;
            end
            
            2'b11 : begin //STOP
                if (baud_count == CLKS_PER_BIT - 1)
                    next_state = 2'b00;
            end
            
            default : begin
                next_state = 2'b00;
            end
    endcase
    end
    
    
    
endmodule
