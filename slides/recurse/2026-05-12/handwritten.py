class Error(Exception):
    pass

class Parser:
    cursor: int
    source: str

    def __init__(self, source):
        self.cursor = 0
        self.source = source

    def any_(self):
        if self.cursor < len(self.source):
            c = self.source[self.cursor]
            self.cursor += 1
            return c
        raise Error("EOF")

    def literal(self, e):
        c = self.source[self.cursor]
        if c == e:
            self.cursor += 1
            return c
        raise Error(f"Expected {e}, but got {c}")

    def literal_range(self, a, b):
        c = self.source[self.cursor]
        if ord(c) >= ord(a) and ord(c) <= ord(b):
            self.cursor += 1
            return c
        raise Error(f"Expected {e}, but got {c}")

    def literal_range(self, a, b):
        c = self.source[self.cursor]
        if ord(c) >= ord(a) and ord(c) <= ord(b):
            self.cursor += 1
            return c
        raise Error(f"Expected [{a}-{b}], but got {c}")

    def zero_or_more(self, expression):
        output = []
        while True:
            try:
                output.append(expression())
            except:
                break
        return output

    def one_or_more(self, expression):
        output = [expression()]
        output.extend(self.zero_or_more(expression))
        return output

    def choice(self, alternatives):
        cursor = self.cursor
        for alt in alternatives:
            try:
                return alt()
            except:
                self.cursor = cursor # backtracking
        raise Error(f"dunno wat to do")

    def not_(self, expression):
        cursor = self.cursor
        try:
            expression()
        except:
            return None
        finally:
            self.cursor = cursor
        raise Error("NOT")

    def parse_spaces(self):
        return self.zero_or_more(lambda: self.literal(" "))


class SheepLang(Parser):
    def parse(self):
        output = [self.literal("b")]
        output.extend(self.one_or_more(lambda: self.choice([
            lambda: self.literal("a"),
            lambda: self.literal("e"),
        ])))
        output.append(self.literal("h"))
        return output


print(SheepLang("baaah").parse())
print(SheepLang("beeeeeeh").parse())


class ListLang(Parser):

    def parse_decimal(self):
        return ''.join(self.one_or_more(lambda: self.literal_range("0", "9")))

    def parse_string(self):
        output = [self.literal('"')]

        def char():
            self.not_(lambda: self.literal('"'))
            return self.any_()

        output.append(''.join(self.zero_or_more(char)))
        output.append(self.literal('"'))
        return output

    def parse_list(self):
        output = [self.literal("(")]
        self.parse_spaces()

        def item():
            v = self.parse_value()
            self.parse_spaces()
            return v

        output.extend(self.zero_or_more(item))
        output.append(self.literal(")"))
        self.parse_spaces()
        return output

    def parse_value(self):
        return self.choice([
            self.parse_decimal,
            self.parse_string,
            self.parse_list,
        ])

    def parse(self):
        return self.parse_value()


print(ListLang("()").parse())
print(ListLang('"foo"').parse())
print(ListLang('(42)').parse())
print(ListLang('(42 "test str")').parse())
print(ListLang('(41 42 (43 44 (45 46)))').parse())
print(ListLang('(42 "test str" (43 "another str"))').parse())


class PEG(Parser):
    def parse_grammar(self):
        defs = self.one_or_more(self.parse_definition)
        return ['Grammar', defs]

    def parse_definition(self):
        ident = self.parse_identifier()
        self.parse_spaces()
        self.literal("<")
        self.literal("-")
        self.parse_spaces()
        expr = self.parse_expr()
        return ['Def', [ident, expr]]

    def parse_identifier(self):
        self.choice([
            lambda: self.literal_range(),
        ])


def visit_definition(self, definition):
    ident, expr = definition
    self.output.write(f"def parse_{ident}(self):")
    self.output.ident()
    self.visit_expr(expr)
    self.output.unident()
