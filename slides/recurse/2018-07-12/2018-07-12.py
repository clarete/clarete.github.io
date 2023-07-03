

class parser:
    def __init__(self, code):
        self.code = code
        self.pos = 0

    def curC(self, offset=0):
        if self.pos >= len(self.code): return None
        return self.code[self.pos]

    def nextC(self):
        self.pos += 1

    def matchC(self, c):
        if self.curC() == c:
            self.nextC()
            return True
        return False

    def parseAtom(self):
        d = self.pos
        while self.curC() and self.curC().isalpha():
            self.nextC()
        return self.code[d:self.pos]

    def parseList(self):
        newList = []
        while not self.matchC("]"):
            newList.append(self.parseValue())
        return newList

    def parseValue(self):
        while self.curC():
            if self.curC().isalpha():
                return self.parseAtom()
            elif self.matchC("["):
                return self.parseList()
            elif self.curC() == ',':
                self.nextC()
            else:
                raise SyntaxError("Char %s isn't expected" % self.curC())
        raise RuntimeError("Not sure what it means")

    def parse(self):
        newList = []
        while self.curC():
            if self.curC().isalpha():
                d = self.pos
                while self.curC() and self.curC().isalpha():
                    self.nextC()
                    newList.append(self.code[d:self.pos])
            elif self.curC() == ',':
                self.nextC()
            else:
                raise SyntaxError("Char %s isn't expected" % self.curC())
        return newList

    def parse(self):
        # return self.pv()
        return self.parseValue()


def parse(code):
    i = 0
    c = lambda n=0: (i+n) < len(code) and code[i+n] or None
    while True:
        if c() is None: break
        elif c().isalpha():
            d = i
            while c() and c().isalpha(): i += 1
            yield code[d:i]
        i += 1


def test0():
    print(list(parse("a")))
    assert(list(parse("a")) == ["a"])
    print(list(parse("a,b")))
    assert(list(parse("a,b")) == ["a", "b"])
    print(list(parse("abc,de")))
    assert(list(parse("abc,de")) == ["abc", "de"])


def test1():
    P = lambda i: parser(i).parse()
    print(P("a"))
    print(P("abc,de"))
    print(P("[abc,de]"))
    print(P("[abc,de,[fg,hij]]"))



if __name__ == '__main__':
    test0()
    test1()
