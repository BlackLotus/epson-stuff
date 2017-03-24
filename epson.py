import socket
from binascii import hexlify

class Epson:
    port = 3289
    # offset ,size, function, value
#    packagestructure=[{"offset":0, "size":5, "value":"EPSON"},{"offset":5, "size":1}]

    def __init__(self, ip):
        print("Connecting to %s" % ip)
        self.ip = ip
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send(self):
        out = ["EPSON",
                "Q",        # PacketType (Q for query and C for command)
                "\x03",     # DeviceType(3) (fixed)
                "\x00",     # DeviceNumber(0) (fixed)
                "\x00\x10", # Function(0010h)
                "\x00\x00", # Result (fixed?)
                "\x00\x00", # parameter length Length
                ""]         # command parameter
        l = len("".join(out))

        print self.sock.sendto("".join(out), (self.ip, self.port))
        print self.parse(self.sock.recv(100))


    def parse(self, msg):
        if msg[0:5]!="EPSON":
            print("Invalid package")

        if msg[5:6].lower()=="q":
            type="Query"
        elif msg[5:6].lower()=="c":
            type="Command"

        func=msg[8:10]
        result=msg[10:12]
        l=msg[12:14]
#        reply=msg[14:14+l]
        reply=msg[14:]

        return {"type":type, "func":hexlify(func), "result":hexlify(result), "length":l, "reply": hexlify(reply)}

