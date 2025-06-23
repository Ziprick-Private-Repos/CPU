import sys

def convert(fileName):
    fp = open(fileName, "rb")
    contents = fp.read()
    fp.close()

    outputStr = ""
    for byte in contents:
        bin = format(byte, '#010b') #forces leading 0's, set 10 character output in 0b format
        outputStr += bin[2:] #remove leading 0b, just keep leading 0's
        outputStr += "\n"
        print(bin[2:])

    #save to file as binary sting
    fp = open("data.txt", "w")
    fp.write(outputStr)
    fp.close()

def main():
    if len(sys.argv) < 2:
        print("Error: No argument given")

    else:
        fileName = sys.argv[1]
        convert(fileName)

if __name__ == "__main__":
    main()
