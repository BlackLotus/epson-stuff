import socket

class Epson:
    port = 3289

    def __init__(self, ip):
        print("Connecting to %s" % ip)
        self.ip = ip
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send(self, msg):
        out = ["EPSON",
                "Q",    # PacketType (Q)
                "\x03", # DeviceType(3)
                "\x00", # DeviceNumber(0)
                "\x00", # Function(0010h)
                "\x10", # Function(0010h)
                "\x00", # Result
                "\x00",
                "\x00", # parameter length Length
                "\x00"]
        l = len("".join(out))

        print self.sock.sendto("".join(out), (self.ip, self.port))
        print self.sock.recv(100)

