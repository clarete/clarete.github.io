const TokenTypes = {
  Atom:  0,
  Comma: 1,
};

function tokenize(input) {
  let i = 0;
  const curr = (n=0) => i + n < input.length ? input[i] : null;
  const test = (re) => curr() && curr().match(re);
  const match = (re) => {
    if (test(re)) {
      i++;
      return true;
    }
    return false;
  };

  return (() => {
    while (curr() && curr().match(/\s/)) i++;
    if (curr() == null) return null;
    else if (test(/[a-zA-Z\+\-\*\/]/)) {
      const d = i; while (test(/[\w\+\-\*\/]/)) i++;
      return { type: TokenTypes.Atom, value: input.slice(d, i) };
    }
    else throw new Error(`Char ${curr()} not expected`);
  });
}

function main() {
  console.log(parse("a, b, c"));
}


if (!process.parent) main();
