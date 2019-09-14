`timescale 1ns / 1ps
`default_nettype none

`define one_sec 50000000
`define three_sec 150000000
`define thirty_sec 1500000000
`define fifteen_sec 750000000

module tlc_fsm(
    output reg [2:0] state, //output for debugging
    output reg RstCount, //use an always block
    output reg [1:0] highwaySignal, farmSignal,
    input wire [30:0] Count,
    input wire Clk, Rst, farmSensor
);

//highway lights
parameter green = 2'b11,
          yellow = 2'b10,
          red = 2'b01;
    
//defining states
parameter S0 = 3'b000,
          S1 = 3'b001,
          S2 = 3'b010,
          S3 = 3'b011,
          S4 = 3'b100,
          S5 = 3'b101,
          S6 = 3'b110;
          
reg [2:0] nextState;

//states
always@(Count) 
case(state)

S0: begin
    if(Count == `one_sec)
        nextState = S1;
    else
        nextState = S0;
    end
     
S1: begin
    if(Count >= `thirty_sec && farmSensor == 1) 
        nextState = S2;
    else
        nextState = S1;
    end 
    
S2: begin
    if(Count == `three_sec) 
        nextState = S3;
    else
        nextState = S2;
    end
     
S3: begin
    if(Count == `one_sec) 
        nextState = S4;
    else
        nextState = S3;
    end 
S4: begin
    if((Count == `three_sec && farmSensor == 0) || Count == `fifteen_sec) 
        nextState = S5;
    else
        nextState = S4;
    end 
S5: begin
    if(Count == `three_sec) 
        nextState = S0;
    else
        nextState = S5;
    end
S6: begin
    nextState = S0;
    end
    
endcase

//output
always@(*)
case(state)

S0: begin
    highwaySignal = red;
    farmSignal = red;
    if(Count == `one_sec) 
        RstCount = 1;
    else 
        RstCount = 0;
    end 
    
S1: begin
    highwaySignal = green;
    farmSignal = red;
    if(Count >= `thirty_sec && farmSensor == 1) 
        RstCount = 1;
    else 
        RstCount = 0;
    end 
    
S2: begin
    highwaySignal = yellow;
    farmSignal = red;
    if(Count == `three_sec) 
        RstCount = 1;
    else 
        RstCount = 0;
    end 
    
S3: begin
    highwaySignal = red;
    farmSignal = red;
    if(Count == `one_sec) 
        RstCount = 1;
    else
        RstCount = 0;
    end
     
S4: begin
    highwaySignal = red;
    farmSignal = green;
    if((Count == `three_sec && farmSensor == 0) || Count == `fifteen_sec) 
        RstCount = 1;
    else
        RstCount = 0;
    end 

S5: begin
    highwaySignal = red;
    farmSignal = yellow;
    if(Count == `three_sec) 
        RstCount = 1;
    else
        RstCount = 0;
    end
S6: begin
    highwaySignal = red;
    farmSignal = red;
    RstCount = 1;
    end
    
endcase


//the clock
always@(posedge Clk)
    if(Rst)
        state <= S6;
    else
        state <= nextState;
        
endmodule


