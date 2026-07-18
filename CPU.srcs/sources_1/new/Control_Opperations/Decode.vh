uartWrt <= 1;
//next state dependant on instruction type
case(instruction)
    NOP:
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end

    MOV:
    begin
        state <= I_ACCESS_MEM_READ;
    end

    LODSB:
    begin
        state <= I_ACCESS_MEM_READ;
    end

    RLODSB:
    begin
        state <= I_ACCESS_MEM_READ;
    end

    LOD:
    begin
        state <= I_ACCESS_MEM_READ;
    end

    STB:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    STBREG:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;  
    end

    BNE:
    begin
        if(eqFlag == 0)
            state <= I_ACCESS_MEM_READ;

        else
        begin
            state <= I_PC_NEXT;
            cycleCount <= 1;
        end

        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    BEQ:
    begin
        if(eqFlag)
            state <= I_ACCESS_MEM_READ;

        else
        begin
            state <= I_PC_NEXT;
            cycleCount <= 1;
        end

        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    BGR:
    begin
        if(greaterFlag)
            state <= I_ACCESS_MEM_READ;

        else
        begin
            state <= I_PC_NEXT;
            cycleCount <= 1;
        end

        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    PUSH:
    begin
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    POP:
    begin
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        stackPointer <= stackPointer + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    LDM:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    LDMREG:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;    
    end

    S_INT:
    begin
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        retAddr <= pc + 2;
        memReadWrite <= ADDR_MODE_RD;
    end

    IRET:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 4;
        stackPointer <= stackPointer + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    PUSHA:
    begin
        state <= I_ACCESS_MEM_WRITE;
        cycleCount <= 3;
    end

    POPA:
    begin
        memReadWrite <= ADDR_MODE_RD;
        stackPointer <= stackPointer + 1;
        addressOutBuff <= stackPointer + 1;
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
    end

    CLI:
    begin
        disableInt <= 1'b1;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end

    STI:
    begin
        disableInt <= 1'b0;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end

    HALT:
    begin
        state <= I_IDLE;
    end

    CALL:
    begin
        state <= I_ACCESS_MEM_READ;
        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    RTS:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 4;
        stackPointer <= stackPointer + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    RTSV:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 4;
        stackPointer <= stackPointer + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    BRA:
    begin
        state <= I_ACCESS_MEM_READ;
        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    NSB:
    begin
        stackPointer <= stackTop;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end

    BRZ:
    begin
        if(zeroFlag)
            state <= I_ACCESS_MEM_READ;

        else
        begin
            state <= I_PC_NEXT;
            cycleCount <= 1;
        end

        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    SPIR:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    RST:
    begin
        rst <= 1;
    end

    SBP:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;    
    end

    STOSB:
    begin
        state <= I_ACCESS_REG_READ;
        addressOutBuff <= di;
    end

    STOSBA:
    begin
        state <= I_ACCESS_REG_READ;
        addressOutBuff <= di;
    end

    SSFP:
    begin
        stackFramePointer <= stackPointer + 3; //stack frame position would be after +3 after call statement
        state <= I_PC_NEXT;
    end

    SSFPM:
    begin
        stackFramePointer <= stackPointer; //doesn't have offset since there is no call to main function
        state <= I_PC_NEXT;
    end  

    SSFPR:
    begin
        stackFramePointer <= {r3Out, r2Out, r1Out}; //stack frame not offset for main function since there is no call
        state <= I_PC_NEXT;
    end

    GSFP:
    begin
        addressOutBuff <= pc + 1;
        stackFrameBuff <= stackFramePointer;
        memReadWrite <= ADDR_MODE_RD;
        state <= I_ACCESS_MEM_READ;
    end

    RSTOSB:
    begin
        state <= I_ACCESS_REG_READ;
        addressOutBuff <= di;   
    end

    SPDR:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    XCHG:
    begin
        state <= I_ACCESS_MEM_READ;
    end

    SSPR:
    begin
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 3;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    SDEQUAL:
    begin
        if(spr == si || spr == di)
        begin
            srFlag <= 1;
        end
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end

    SDBEQ:
    begin
        if(srFlag)
            state <= I_ACCESS_MEM_READ;

        else
        begin
            state <= I_PC_NEXT;
            cycleCount <= 1;
        end

        retAddr <= pc + 4;
        cycleCount <= 2;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    H_INT:
    begin
        state <= I_ACCESS_MEM_WRITE;
        retAddr <= pc;

        case(intLock)
            4'b0001:
                intNum <= 1;

            4'b0010:
                intNum <= 2;

            4'b0011:
                intNum <= 3; 

            4'b0100:
                intNum <= 4;

            4'b0101:
                intNum <= 5;

            4'b0110:
                intNum <= 6;   

            4'b0111:
                intNum <= 7;

            4'b1000:
                intNum <= 8;

            4'b1001:
                intNum <= 9;  

            4'b1010:
                intNum <= 10;

            4'b1011:
                intNum <= 11;

            4'b1100:
                intNum <= 12;   

            4'b1101:
                intNum <= 13;

            4'b1110:
                intNum <= 14;

            4'b1111:
                intNum <= 15;           
        endcase

        cycleCount <= 4;
    end

    LDSP:
    begin
        state <= I_ACCESS_REG_WRITE;
        cycleCount <= 1;
        addressOutBuff <= stackPointer + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    LDSPI:
    begin
        state <= I_ACCESS_REG_WRITE;
        cycleCount <= 1;
        addressOutBuff <= stackFramePointer + r2Out;
        memReadWrite <= ADDR_MODE_RD;
    end

    SPIRFR:
    begin
        state <= I_ACCESS_REG_READ;
    end

    SPDRFR:
    begin
        state <= I_ACCESS_REG_READ;
    end

    //ALU
    OR:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    AND:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    SHL:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    SHR:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    CMP:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 4;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    NOT:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    XOR:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    ADD:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    SUB:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    INC:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    DEC:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    ROL:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    ROR:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_ALU;
    end

    MUL:
    begin
        //cycle count is determined after reading in second reg value
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    DIV:
    begin
        //aluCycle <= 255; //max cycles, will stop earlier based on aluDivDone line
        state <= I_ACCESS_MEM_READ;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    CMPI:
    begin
        aluCycle <= 1;
        state <= I_ACCESS_MEM_READ;
        cycleCount <= 4;
        addressOutBuff <= pc + 1;
        memReadWrite <= ADDR_MODE_RD;
    end

    default: //invalid instruction
    begin
        rst <= 1;
    end

endcase