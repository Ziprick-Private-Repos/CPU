if(instruction == OR)
begin
    aluRun <= 1;
    if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == AND)
begin
    aluRun <= 1;
    if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == SHL)
begin
    aluRun <= 1;
    tmpReg <= r1Out;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == SHR)
begin
    aluRun <= 1;
    tmpReg <= r1Out;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == CMP)
begin
    if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;

    if(cycleCount == 4)
    begin
        aluRun <= 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        aluRun <= 0;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
        cycleCount <= cycleCount - 1;

    else if(cycleCount == 1)
    begin
        greaterFlag <= greaterFlagBus;
        zeroFlag <= zeroFlagBus;
        eqFlag <= eqFlagBus;
        overflowFlag <= overflowFlagBus;
        divZero <= divZeroBus;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == NOT)
begin
    aluRun <= 1;
    aluCycle <= 1;
    tmpReg <= 8'hZZ;
    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == XOR)
begin    
    if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;

    aluRun <= 1;
    aluCycle <= 1;

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == ADD)
begin
    aluRun <= 1;
    if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;

    overflowFlag <= overflowFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == SUB)
begin
    aluRun <= 1;
    if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == INC)
begin
    aluRun <= 1;
    overflowFlag <= overflowFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == DEC)
begin
    aluRun <= 1;
    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == ROL)
begin
    aluRun <= 1;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == ROR)
begin
    aluRun <= 1;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == MUL)
begin
    aluRun <= 1;
    if(aluRegSel[1:0] == 2'b00)
    begin
        tmpReg <= r1Out;
        aluCycle <= r1Out;
    end

    else if(aluRegSel[1:0] == 2'b01)
    begin
        tmpReg <= r2Out;
        aluCycle <= r2Out;
    end

    else if(aluRegSel[1:0] == 2'b10)
    begin
        tmpReg <= r3Out;
        aluCycle <= r3Out;
    end

    else if(aluRegSel[1:0] == 2'b11)
    begin
        tmpReg <= r4Out;
        aluCycle <= r4Out;
    end

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == DIV)
begin
    aluRun <= 1;
    if(aluRegSel[1:0] == 2'b00)
    begin
        tmpReg <= r1Out;
    end

    else if(aluRegSel[1:0] == 2'b01)
    begin
        tmpReg <= r2Out;
    end

    else if(aluRegSel[1:0] == 2'b10)
    begin
        tmpReg <= r3Out;
    end

    else if(aluRegSel[1:0] == 2'b11)
    begin
        tmpReg <= r4Out;
    end

    zeroFlag <= zeroFlagBus;

    cycleCount <= 8'hFF;
    aluCycle <= 8'hFF;
    state <= I_ACCESS_REG_WRITE;
end







else if(instruction == ADDS)
begin
    aluRun <= 1;
    /*if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;*/

    overflowFlag <= overflowFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == SUBS)
begin
    aluRun <= 1;
    /*if(aluRegSel[1:0] == 2'b00)
        tmpReg <= r1Out;

    else if(aluRegSel[1:0] == 2'b01)
        tmpReg <= r2Out;

    else if(aluRegSel[1:0] == 2'b10)
        tmpReg <= r3Out;

    else if(aluRegSel[1:0] == 2'b11)
        tmpReg <= r4Out;*/

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == INCS)
begin
    aluRun <= 1;
    overflowFlag <= overflowFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == DECS)
begin
    aluRun <= 1;
    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == ROLS)
begin
    aluRun <= 1;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == RORS)
begin
    aluRun <= 1;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == MULS)
begin
    aluRun <= 1;
    aluCycle <= {r3Out, r4Out};

    /*if(aluRegSel[1:0] == 2'b00)
    begin
        tmpReg <= r1Out;
        aluCycle <= r1Out;
    end

    else if(aluRegSel[1:0] == 2'b01)
    begin
        tmpReg <= r2Out;
        aluCycle <= r2Out;
    end

    else if(aluRegSel[1:0] == 2'b10)
    begin
        tmpReg <= r3Out;
        aluCycle <= r3Out;
    end

    else if(aluRegSel[1:0] == 2'b11)
    begin
        tmpReg <= r4Out;
        aluCycle <= r4Out;
    end*/

    zeroFlag <= zeroFlagBus;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == DIVS)
begin
    aluRun <= 1;
    /*if(aluRegSel[1:0] == 2'b00)
    begin
        tmpReg <= r1Out;
    end

    else if(aluRegSel[1:0] == 2'b01)
    begin
        tmpReg <= r2Out;
    end

    else if(aluRegSel[1:0] == 2'b10)
    begin
        tmpReg <= r3Out;
    end

    else if(aluRegSel[1:0] == 2'b11)
    begin
        tmpReg <= r4Out;
    end*/

    zeroFlag <= zeroFlagBus;

    cycleCount <= 8'hFF;
    aluCycle <= 8'hFF;
    state <= I_ACCESS_REG_WRITE;
end

/*else if(instruction == CMPI)
begin
    if(cycleCount == 4)
    begin
        aluRun <= 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        aluRun <= 0;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
        cycleCount <= cycleCount - 1;

    else if(cycleCount == 1)
    begin
        greaterFlag <= greaterFlagBus;
        zeroFlag <= zeroFlagBus;
        eqFlag <= eqFlagBus;
        overflowFlag <= overflowFlagBus;
        divZero <= divZeroBus;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end*/