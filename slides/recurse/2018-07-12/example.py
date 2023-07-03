class parser:
    def __init__(self, code):
        self.code = code
        self.pos = 0

    def curC(self, offset=0):
        if self.pos >= len(self.code):
            return None
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
        values = []
        while self.pos < len(self.code):
            values.append(self.parseValue())
        return values


def t(input_string, expected):
    parsed = parser(input_string).parse()
    return parsed


def test1():
    print(t("a", ["a"]))
    print(t("abc,de", ["abc", "de"]))
    print(t("[abc,de]", [["abc", "de"]]))
    print(t("[abc,de,[fg,hij]]", [["abc", "de", ["fg", "hij"]]]))


if __name__ == '__main__':
    test1()
