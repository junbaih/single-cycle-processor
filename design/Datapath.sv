`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:10:33 PM
// Design Name: 
// Module Name: Datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Datapath #(
    parameter PC_W = 9, // Program Counter
    parameter INS_W = 32, // Instruction Width
    parameter RF_ADDRESS = 5, // Register File Address
    parameter DATA_W = 32, // Data WriteData
    parameter DM_ADDRESS = 9, // Data Memory Address
    parameter ALU_CC_W = 4 // ALU Control Code Width, original = 4
    )(
    input logic clk , reset , // global clock
                              // reset , sets the PC to zero
    RegWrite , MemtoReg ,     // Register file writing enable   // Memory or ALU MUX
    ALUsrc , MemWrite ,       // Register file or Immediate MUX // Memroy Writing Enable
    MemRead, Branch , 
     JALR,Jump,PCtoReg,
    input logic [1:0] PCregSrc,              // Memroy Reading Enable  //Branch CC signal
    input logic [ ALU_CC_W -1:0] ALU_CC, // ALU Control Code ( input of the ALU )
    output logic [6:0] opcode,
    output logic [6:0] Funct7,
    output logic [2:0] Funct3,
    output logic [DATA_W-1:0] WB_Data //ALU_Result
    );

logic [PC_W-1:0] PC, PCPlus4, PCPlusN,PCPlusF,PCF,PCJ;  // PCPlusF = mux(PCPlus4,PCPlusN)  PCF = mux(PCPlusF,JumpPC)
logic [INS_W-1:0] Instr;
logic [DATA_W-1:0] Result,DataWrtReg,PCResult,PCf,PCr,PCPN,jReg;
logic [DATA_W-1:0] Reg1, Reg2;
logic [DATA_W-1:0] ReadData,tempReadData;
logic [DATA_W-1:0] SrcB, ALUResult;
logic [DATA_W-1:0] ExtImm;
logic Zero;
logic Brcc;

// next PC
    adder #(9) pcadd (PC, 9'b100, PCPlus4);
    flopr #(9) pcreg(clk, reset, PCF, PC);

 //Instruction memory
    instructionmemory instr_mem (PC, Instr);
    
    assign opcode = Instr[6:0];
    assign Funct7 = Instr[31:25];
    assign Funct3 = Instr[14:12];
    

// //Register File
    assign PCf = {23'b0,PCPlus4};
    mux2 #(32) pcsrc0(PCf,PCPN,PCregSrc[0],PCr); 
    mux2 #(32) pcsrc1(PCr,ExtImm,PCregSrc[1],PCResult);
    mux2 #(32) regwrtmux(DataWrtReg,PCResult,PCtoReg,Result);

    RegFile rf(clk, reset, RegWrite, Instr[11:7], Instr[19:15], Instr[24:20],
            Result,Instr[14:12], Reg1, Reg2);
            
    mux2 #(32) resmux(ALUResult, ReadData, MemtoReg, DataWrtReg);
    
    logic [31:0] tempv;     
    adder #(32) jpaddr (Reg1, ExtImm,tempv);
    
    assign jReg = {tempv[31:1],1'b0};
    mux2 #(9) jalpcsrc(PCPlusN,tempv[8:0],JALR,PCJ);
    
    
           
//// sign extend
    imm_Gen Ext_Imm (Instr,ExtImm);

//// ALU
    mux2 #(32) srcbmux(Reg2, ExtImm, ALUsrc, SrcB);
    alu alu_module(Reg1, SrcB, ALU_CC, ALUResult,Zero);
    
    assign WB_Data = Result;

/// Branch control

    assign Brcc = Zero && Branch;
    //adder #(9) pcaddn (PC, ExtImm[8:0], PCPlusN);
    adder #(32) pcaddn ({23'b0,PC}, ExtImm, PCPN);
    assign PCPlusN = PCPN[8:0];
    mux2 #(9) pcmux(PCPlus4,PCPlusN,Brcc,PCPlusF);
/// Jump control
    mux2 #(9) pcBorJ(PCPlusF,PCJ,Jump,PCF);
        
////// Data memory 
	datamemory data_mem (clk, MemRead, MemWrite, ALUResult[DM_ADDRESS-1:0], Reg2, tempReadData);
always_comb begin
    ReadData = tempReadData;
    case(Funct3)
	3'b000:
        ReadData = {tempReadData[31]?{24{1'b1}}:24'b0,tempReadData[7:0]};
    3'b001:
        ReadData = {tempReadData[31]?{16{1'b1}}:16'b0,tempReadData[15:0]};
    3'b010:
        ReadData = tempReadData;
    3'b100:
        ReadData = {24'b0,tempReadData[7:0]};
    3'b101:
        ReadData = {16'b0,tempReadData[15:0]};
    default:
        ReadData = tempReadData;
    endcase
end
	
     
endmodule