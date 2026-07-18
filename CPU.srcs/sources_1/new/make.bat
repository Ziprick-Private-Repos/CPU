assembler helloUart.asm -v
python convertBinToVlg.py a.out
iverilog Test.v IO.v Debounce.v Control.v ALU.v Register.v SevenSegDisp.v Uart.v
vvp a.out