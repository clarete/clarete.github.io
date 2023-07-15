export const Instruction = {
  HALT: 'halt',
  PUSH: 'push',
  LOAD: 'load',
  STORE: 'store',
  SUM: 'sum',
  SUB: 'sub',
  MUL: 'mul',
  DIV: 'div',
  CMP: 'cmp',
  JMP: 'jmp',
  JNE: 'jne',
  JNB: 'jnb',
  INCR: 'incr',
  PRIMITIVE: 'primitive',
};

export function interpreter(code, values) {
  let instructionPointer = 0;
  const flags = [0];
  const stack = [];
  const primitives = {
    'print': console.log,
  };

  outer: while (true) {
    const instruction = code[instructionPointer++];

    //console.log(instructionPointer-1, instruction);

    switch (instruction) {
    case Instruction.HALT: {
      break outer;
    }

    case Instruction.PUSH: {
      const arg = code[instructionPointer++];
      stack.push(arg);
      break;
    }

    case Instruction.LOAD: {
      const arg = code[instructionPointer++];
      const value = values[arg];
      stack.push(value);
      break;
    }

    case Instruction.STORE: {
      const arg = code[instructionPointer++];
      const value = stack.pop();
      values[arg] = value;
      break;
    }

    case Instruction.SUM: {
      const b = stack.pop();
      const a = stack.pop();
      stack.push(a + b);
      break;
    }

    case Instruction.SUB: {
      const b = stack.pop();
      const a = stack.pop();
      stack.push(a - b);
      break;
    }

    case Instruction.MUL: {
      const b = stack.pop();
      const a = stack.pop();
      stack.push(a * b);
      break;
    }

    case Instruction.DIV: {
      const b = stack.pop();
      const a = stack.pop();
      stack.push(a / b);
      break;
    }

    case Instruction.INCR: {
      const v = stack.pop();
      stack.push(v + 1);
      break;
    }

    case Instruction.CMP: {
      const b = stack.pop();
      const a = stack.pop();
      const r = a === b;
      stack.push(r);
      if (a > b)
        flags[0] = 1;
      if (a < b)
        flags[0] = -1;
      if (r)
        flags[0] = 0;
      break;
    }

    case Instruction.JMP: {
      instructionPointer = code[instructionPointer];
      break;
    }

    case Instruction.JNE: {
      const arg = code[instructionPointer++];
      if (flags[0] !== 0) {
        instructionPointer = arg;
      }
      break;
    }

    case Instruction.JNB: {
      const arg = code[instructionPointer++];
      if (flags[0] !== -1) {
        instructionPointer = arg;
      }
      break;
    }

    case Instruction.PRIMITIVE: {
      const name = code[instructionPointer++];
      const arity = code[instructionPointer++];
      const func = primitives[name];
      const args = [];
      for (let i = 0; i < arity; i++) {
        args.push(stack.pop());
      }
      stack.push(func.apply(null, args));
      break;
    }

    }
  }

  if (stack.length > 0) {
    return stack.pop();
  }
  return undefined;
}
