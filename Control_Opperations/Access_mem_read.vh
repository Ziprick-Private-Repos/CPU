if(instruction == MOV) 
begin
    memReadWrite <= ADDR_MODE_RD;
    addressOutBuff <= pc + 1;
    state <= I_ACCESS_REG_READ;
end

else if(instruction == LODSB)
begin
    memReadWrite <= ADDR_MODE_RD;
    addressOutBuff <= si;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == RLODSB)
begin
    memReadWrite <= ADDR_MODE_RD;
    addressOutBuff <= si;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == LOD)
begin
        memReadWrite <= ADDR_MODE_RD;
        addressOutBuff <= pc + 1;
        state <= I_ACCESS_REG_WRITE;
end

else if(instruction == STB)
begin
    if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        cycleCount <= 1;
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_ACCESS_MEM_WRITE;
    end 
end

else if(instruction == STBREG)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin       
        addressLinesOutBuff[23:16] <= dataIn;
        cycleCount <= cycleCount - 1;
    end 

    else
    begin
        addressLinesOutBuff <= addressLinesOutBuff + r2Out;
        state <= I_ACCESS_MEM_WRITE;
        cycleCount <= 1;
    end
end

else if(instruction == PUSH)
begin
//pushPopRegSel <= dataIn;
    case(dataIn[1:0]) //pushPopRegSel data
        2'b00:
            tmpReg <= r1Out;
            
        2'b01:
            tmpReg <= r2Out;
            
        2'b10:
            tmpReg <= r3Out;
            
        2'b11:
            tmpReg <= r4Out;
    endcase

    state <= I_ACCESS_MEM_WRITE;
end

else if(instruction == BNE)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end 
end

else if(instruction == BEQ)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end 
end

else if(instruction == BGR)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end 
end

/*else if(instruction == PUSH)
begin
    pushPopRegSel <= dataIn;
    state <= I_ACCESS_MEM_READ;
end*/

else if(instruction == POP)
begin
    pushPopRegSel <= dataIn;
    addressOutBuff <= stackPointer;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == LDM)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        memReadWrite <= ADDR_MODE_RD;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressOutBuff <= addressLinesOutBuff;
        state <= I_ACCESS_REG_WRITE;
        cycleCount <= 1;
    end
end

else if(instruction == LDMREG)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        memReadWrite <= ADDR_MODE_RD;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressOutBuff <= addressLinesOutBuff + r1Out;
        state <= I_ACCESS_REG_WRITE;
        cycleCount <= 1;
    end
end

else if(instruction == S_INT)
begin
    intNum <= dataIn;
    cycleCount <= 4;
    state <= I_ACCESS_MEM_WRITE;
end

else if(instruction == IRET)
begin
    if(cycleCount == 4)
    begin
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        tmpReg <= dataIn;
        srFlag <= dataIn[5];
        divZero <= dataIn[4];
        greaterFlag <= dataIn[3];
        zeroFlag <= dataIn[2];
        eqFlag <= dataIn[1];
        overflowFlag <= dataIn[0];
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        retAddr[23:16] <= dataIn;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        retAddr[15:8] <= dataIn;  
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        retAddr[7:0] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == POPA)
begin
    if(cycleCount == 3)
    begin
        tmpReg <= dataIn;
        r4En <= 1;
        stackPointer <= stackPointer + 1;
        addressOutBuff <= stackPointer + 1;
        cycleCount <= cycleCount - 1;  
    end

    else if(cycleCount == 2)
    begin
        tmpReg <= dataIn;
        r4En <= 0;
        r3En <= 1;  
        stackPointer <= stackPointer + 1;
        addressOutBuff <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        tmpReg <= dataIn;
        r3En <= 0;
        r2En <= 1;  
        stackPointer <= stackPointer + 1;
        addressOutBuff <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        tmpReg <= dataIn;
        r2En <= 0;
        r1En <= 1;  
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == RTS)
begin
    if(cycleCount == 4)
    begin          
        retAddr <= 0;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        retAddr[23:16] <= dataIn;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        retAddr[15:8] <= dataIn;  
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        retAddr[7:0] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == RTSV)
begin
    if(cycleCount == 4)
    begin          
        retAddr <= 0;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        retAddr[23:16] <= dataIn;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer + 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        retAddr[15:8] <= dataIn;  
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        toDataBus <= r1Out; //save r1 and push to stack for return
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        memReadWrite <= ADDR_MODE_WRT;

        retAddr[7:0] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == CALL)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_ACCESS_MEM_WRITE;
        cycleCount <= 4;
    end
end

else if(instruction == BRA)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end 
end

else if(instruction == BRZ)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end 
end

else if(instruction == SPIR)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        memReadWrite <= ADDR_MODE_RD;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        si <= addressLinesOutBuff;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == SBP)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        stackTop[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        stackTop[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        stackTop[23:16] <= dataIn;
        memReadWrite <= ADDR_MODE_RD;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end  
end

else if(instruction == SPDR)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        memReadWrite <= ADDR_MODE_RD;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        di <= addressLinesOutBuff;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end 

else if(instruction == XCHG) 
begin
    memReadWrite <= ADDR_MODE_RD;
    addressOutBuff <= pc + 1;
    state <= I_ACCESS_REG_READ;
end

else if(instruction == SSPR)
begin
    if(cycleCount == 3)
    begin
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        memReadWrite <= ADDR_MODE_RD;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        spr <= addressLinesOutBuff;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == SDBEQ)
begin
    if(cycleCount == 2)
    begin        
        addressOutBuff <= pc + 2;
        addressLinesOutBuff[7:0] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        addressOutBuff <= pc + 3;
        addressLinesOutBuff[15:8] <= dataIn;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        addressLinesOutBuff[23:16] <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end 
end

else if(instruction == GSFP)
begin
    cycleCount <= 3;
    stackFrameBuff <= stackFrameBuff + dataIn;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == H_INT)
begin
    intNum <= dataIn;
    cycleCount <= 4;
    state <= I_ACCESS_MEM_WRITE;
end

else if(instruction == OR)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == AND)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == CMP)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == XOR)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == ADD)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == SUB)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == MUL)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

else if(instruction == DIV)
begin
    aluRegSel <= dataIn;
    state <= I_ACCESS_ALU;
end

/*else if(instruction == CMPI)
begin
    tmpReg <= dataIn;
    state <= I_ACCESS_ALU;   
end*/