`timescale 1ns / 1ps

// Engineer: Troy Donnahoo
// Design Name: Entire UART TB 
// Module Name: uart_entire_tb

module uart_loopback_tb();

    logic clk, reset;
    logic tx, tx_busy, tx_start;
    logic [7:0] tx_data, rx_data;
    logic rx_valid;
    
    //Connecting both RX and TX
    
    uart_tx tx_dut(.clk(clk), .reset(reset), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .tx_busy(tx_busy));
    uart_rx rx_dut(.clk(clk), .reset(reset), .rx(tx), .rx_data(rx_data), .rx_valid(rx_valid));
    
    //clk
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'b0;
        
        #20;
        reset = 0;
        #20;
        
        //sending 0x55
        tx_data = 8'h55;
        tx_start = 1;
        
        #10;
        
        tx_start = 0;
        
        #2_000_000;
        
        $finish;
    end
    
    
    
    
endmodule
