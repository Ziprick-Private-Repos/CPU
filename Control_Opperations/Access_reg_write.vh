if(instruction == MOV)
begin
    case(dataIn[3:2])			
        2'b00:
            r1En <= 1;
            
        2'b01:
            r2En <= 1;
            
        2'b10:
            r3En <= 1;
            
        2'b11:
            r4En <= 1;
    endcase

    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == XCHG)
begin
    if(cycleCount == 1)
    begin
        swapReg <= r1Out;
        r1En <= 1;
        r2En <= 0;
        r3En <= 0;
        r4En <= 0;
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        r1En <= 0;
        r2En <= 0;
        r3En <= 0;
        r4En <= 0;
        tmpReg <= swapReg;

        case(dataIn[1:0])
            2'b00:
                r1En <= 1;
                
            2'b01:
                r2En <= 1;   

            2'b10:
                r3En <= 1;
                
            2'b11:
                r4En <= 1;
        endcase

        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == LODSB)
begin
    si <= si + 1;
    tmpReg <= dataIn;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == RLODSB)
begin
    si <= si - 1;
    tmpReg <= dataIn;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == LOD)
begin
    if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        r1En <= 1;
        tmpReg <= dataIn;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == LDM)
begin
    if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;
        tmpReg <= dataIn;
        r1En <= 1;
    end

    else
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end    
end

else if(instruction == LDMREG)
begin
    if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;
        tmpReg <= dataIn;
        r1En <= 1;
    end

    else
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end    
end

else if(instruction == POP)
begin
    tmpReg <= dataIn;

    case(pushPopRegSel[1:0])			
        2'b00:
            r1En <= 1;
            
        2'b01:
            r2En <= 1;
            
        2'b10:
            r3En <= 1;
            
        2'b11:
            r4En <= 1;
    endcase

    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == LDSP)
begin
    if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;
        tmpReg <= dataIn;
        r1En <= 1;
    end

    else
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == LDSPI)
begin
    if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;
        tmpReg <= dataIn;
        r1En <= 1;
    end

    else
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == GSFP)
begin
    if(cycleCount == 3)
    begin
        r3En <= 1;            
        tmpReg <= stackFramePointer[23:16];
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        r3En <= 0;
        r2En <= 1;
        tmpReg <= stackFramePointer[15:8];
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        r2En <= 0;
        r1En <= 1;
        tmpReg <= stackFramePointer[7:0];
        cycleCount <= cycleCount - 1;
    end

    else
    begin
        memReadWrite <= ADDR_MODE_PC;
        r1En <= 0;
        state <= I_PC_NEXT;
    end                        
end

else if(instruction == OR)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == AND)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == SHL)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == SHR)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == NOT)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;  
    cycleCount <= 1;
end

else if(instruction == XOR)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT; 
    cycleCount <= 2;
end

else if(instruction == ADD)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT; 
    cycleCount <= 1;
end

else if(instruction == SUB)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT; 
    cycleCount <= 1;
end

else if(instruction == INC)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == DEC)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == ROL)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == ROR)
begin
    aluRun <= 0;
    r1En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end 

else if(instruction == MUL)
begin
    aluRun <= 0;
    state <= I_PC_NEXT; 
    cycleCount <= tmpReg + 1;
end

else if(instruction == DIV)
begin
    cycleCount <= cycleCount - 1;
    if(cycleCount == 0 || aluDivDone)
    begin
        //r1En <= 1;
        aluRun <= 0;
        cycleCount <= 1;
        aluCycle <= 0;
        state <= I_PC_NEXT;
    end
end

else if(instruction == ADDS)
begin
    aluRun <= 0;
    //r1En <= 1;
    //r2En <= 1;
    state <= I_PC_NEXT; 
    cycleCount <= 3;
end

else if(instruction == SUBS)
begin
    aluRun <= 0;
    //r1En <= 1;
    //r2En <= 1;
    state <= I_PC_NEXT; 
    cycleCount <= 2;
end

else if(instruction == INCS)
begin
    aluRun <= 0;
    //r1En <= 1;
    //r2En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 2;
end

else if(instruction == DECS)
begin
    aluRun <= 0;
    //r1En <= 1;
    //r2En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 2;
end

else if(instruction == ROLS)
begin
    aluRun <= 0;
    //r1En <= 1;
    //r2En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 2;
end

else if(instruction == RORS)
begin
    aluRun <= 0;
    //r1En <= 1;
    //r2En <= 1;
    state <= I_PC_NEXT;
    cycleCount <= 2;
end 

else if(instruction == MULS)
begin
    aluRun <= 0;
    state <= I_PC_NEXT; 
    cycleCount <= {r1Out, r2Out} + 1;
end

else if(instruction == DIVS)
begin
    cycleCount <= cycleCount - 1;
    if(cycleCount == 0 || aluDivDone)
    begin
        //r1En <= 1;
        aluRun <= 0;
        cycleCount <= 2;
        aluCycle <= 0;
        state <= I_PC_NEXT;
    end
end