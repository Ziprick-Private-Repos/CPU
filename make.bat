assembler test.asm -v
python convertBinToVlg.py a.out
iverilog Test.v IO.v Control.v ALU.v Register.v
vvp a.out