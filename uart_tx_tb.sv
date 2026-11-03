`timescale 1ns / 1ps

// Engineer: Troy Donnahoo
// Design Name: Transmitter Test Bench
// Module Name: uart_tx_tb


module uart_tx_tb();
    logic clk; 
    logic reset;
    logic tx_start;
    logic [7:0] tx_data;
    
    logic tx;
    logic tx_busy;
    
    //instantiate transmitter (uart_tx.sv)
    uart_tx dut(.clk(clk), .reset(reset), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .tx_busy(tx_busy));
    
    //testbench
    
    always #5 clk = ~clk;
    
    
    initial begin
        //values
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'b0;
        
        #20; 
        reset = 0;
        
        #20;
        
        tx_data = 8'h41; //sending ASCII A - 0x41
        tx_start = 1;
        
        #10;
        tx_start = 0;
        
        #2_000_000;
        $finish;
    
    
    
    
    
    end
    
    
    
    
endmodule
