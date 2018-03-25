`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:23:43 PM
// Design Name: 
// Module Name: alu
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


module alu#(
        parameter DATA_WIDTH = 32,
        parameter OPCODE_LENGTH = 4
        )(
        input logic [DATA_WIDTH-1:0]    SrcA,
        input logic [DATA_WIDTH-1:0]    SrcB,

        input logic [OPCODE_LENGTH-1:0]    Operation,
        output logic[DATA_WIDTH-1:0] ALUResult,
        output logic Zero
        );
    
        always_comb
        begin
            Zero = 'd0;
            ALUResult = 'd0;
            case(Operation)
            4'b0000:        // AND
                    ALUResult = SrcA & SrcB;
            4'b0001:        //OR
                    ALUResult = SrcA | SrcB;
            4'b0010:        //ADD
                    ALUResult = SrcA + SrcB;
            4'b1000:        // SRL
                    ALUResult = SrcA >> SrcB[4:0];   
            4'b0110:        //Subtract
                    ALUResult = $signed(SrcA) - $signed(SrcB);
            4'b0100:          // XOR
                    ALUResult = SrcA ^ SrcB;
            4'b1001:        //SRA
                    ALUResult = $signed(SrcA) >>> SrcB[4:0];
            4'b1010:        //SLL
                    ALUResult = SrcA << SrcB[4:0];
            4'b1100:         //SLT
                    ALUResult = $signed(SrcA)<$signed(SrcB)? 31'b1: 31'b0;
            4'b1101:          //SLTU
                    ALUResult = SrcA<SrcB? 31'b1:31'b0;
            4'b0011:            //BEQ
                    Zero = (SrcA==SrcB);
            4'b0101:                //BNE
                    Zero = (SrcA!=SrcB);
            4'b0111:                //BLT
                    Zero = ($signed(SrcA)<$signed(SrcB));
            4'b1011:              //BGE
                    Zero = ($signed(SrcA)>=$signed(SrcB));
            4'b1110:               //BLTU
                    Zero = (SrcA<SrcB);
            4'b1111:              //BGEU
                    Zero = (SrcA>=SrcB);
            default:
            begin 
                    ALUResult = 'b0;
                    Zero = 'b0;
            end
            endcase
        end
        
endmodule

