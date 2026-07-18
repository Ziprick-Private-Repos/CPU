
if __name__ == "__main__":
    paddedData = []
    f = open("a.out", "rb")
    data = bytearray(f.read())
    f.close()
    
    for d in data:
        paddedData.extend((d, 0x00))
        #paddedData.append(d)
        #paddedData.append(0x00)
        
    f = open("padded.bin", "wb")
    for d in paddedData:
        f.write(bytes([d]))
    f.close()
    print(paddedData)