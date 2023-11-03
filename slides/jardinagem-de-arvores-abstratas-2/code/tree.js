const BinaryOperator = {
  Add: '+',
  Sub: '-',
  Mul: '*',
  Div: '/',
};

class BinaryOperation {
  constructor(operator, operandLeft, operandRight) {
    this.operator = operator;
    this.operandLeft = operandLeft;
    this.operandRight = operandRight;
  }
}

function interpreter(node) {
  if (node instanceof BinaryOperation) {
    const left = interpreter(node.operandLeft);
    const right = interpreter(node.operandRight);
    switch (node.operator) {
    case BinaryOperator.Add: return left + right;
    case BinaryOperator.Sub: return left - right;
    case BinaryOperator.Mul: return left * right;
    case BinaryOperator.Div: return left / right;
    }
  } else {
    return node
  }
}

const tree = new BinaryOperation(BinaryOperator.Mul, new BinaryOperation(BinaryOperator.Add, 1, 2), 3);

console.log(interpreter(tree))
