Blockly.JavaScript['organization_contract'] = function(block) {
  // Define a procedure with a return value.
  var funcName = Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('NAME'), Blockly.PROCEDURE_CATEGORY_NAME);
  var xfix1 = '';
  if (Blockly.JavaScript.STATEMENT_PREFIX) {
    xfix1 += Blockly.JavaScript.injectId(Blockly.JavaScript.STATEMENT_PREFIX,
        block);
  }
  if (Blockly.JavaScript.STATEMENT_SUFFIX) {
    xfix1 += Blockly.JavaScript.injectId(Blockly.JavaScript.STATEMENT_SUFFIX,
        block);
  }
  if (xfix1) {
    xfix1 = Blockly.JavaScript.prefixLines(xfix1, Blockly.JavaScript.INDENT);
  }
  var loopTrap = '';
  if (Blockly.JavaScript.INFINITE_LOOP_TRAP) {
    loopTrap = Blockly.JavaScript.prefixLines(
        Blockly.JavaScript.injectId(Blockly.JavaScript.INFINITE_LOOP_TRAP,
        block), Blockly.JavaScript.INDENT);
  }
  var branch = Blockly.JavaScript.statementToCode(block, 'STACK');
  var returnValue = Blockly.JavaScript.valueToCode(block, 'RETURN',
      Blockly.JavaScript.ORDER_NONE) || '';
  var xfix2 = '';
  if (branch && returnValue) {
    // After executing the function body, revisit this block for the return.
    xfix2 = xfix1;
  }
  if (returnValue) {
    returnValue = Blockly.JavaScript.INDENT + 'return ' + returnValue + ';\n';
  }
  var args = [];
  var variables = block.getVars();
  for (var i = 0; i < variables.length; i++) {
    args[i] = Blockly.JavaScript.variableDB_.getName(variables[i],
        Blockly.VARIABLE_CATEGORY_NAME);
  }
  // var code = 'function ' + funcName + '(' + args.join(', ') + ') {\n' +
      // xfix1 + loopTrap + branch + xfix2 + returnValue + '}';
  var code = '\'use strict\';\n\nconst { Contract, Context } = require(\'fabric-contract-api\');\n\n' + 
      'class ' + funcName + 'Context extends Context' + ' {\n' + Blockly.JavaScript.INDENT +
	  'constructor() {\n    super();\n    this.\n  }\n}\n' +
	  'class ' + funcName + ' extends Contract' + ' {\n' + '  createContext() {\n    return new ' + funcName + 'Context();\n  }\n'+
      xfix1 + loopTrap + branch + xfix2 + returnValue + '\n}\n\nmodule.exports = ' + funcName + ';';
  code = Blockly.JavaScript.scrub_(block, code);
  // Add % so as not to collide with helper functions in definitions list.
  Blockly.JavaScript.definitions_['%' + funcName] = code;
  return null;
};

Blockly.JavaScript['agendum_clause'] = function(block) {
  // For each loop.
  var variable0 = Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME);
  // var argument0 = Blockly.JavaScript.valueToCode(block, 'LIST',
      // Blockly.JavaScript.ORDER_ASSIGNMENT) || '[]';
  // console.log(argument0);
  var argument0 = block.getFieldValue('LIST');
  var branch = Blockly.JavaScript.statementToCode(block, 'DO');
  branch = Blockly.JavaScript.addLoopTrap(branch, block);
  var code = '';
  // // Cache non-trivial values to variables to prevent repeated look-ups.
  // // var listVar = argument0;
  // // if (!argument0.match(/^\w+$/)) {
    // // listVar = Blockly.JavaScript.variableDB_.getDistinctName(
        // // variable0 + '_list', Blockly.VARIABLE_CATEGORY_NAME);
    // // code += 'var ' + listVar + ' = ' + argument0 + ';\n';
  // // }
  // // var indexVar = Blockly.JavaScript.variableDB_.getDistinctName(
      // // variable0 + '_index', Blockly.VARIABLE_CATEGORY_NAME);
  // branch = Blockly.JavaScript.INDENT + variable0 + ' = ' +
      // listVar + '[' + indexVar + '];\n' + branch;
  // code += 'for (var ' + indexVar + ' in ' + listVar + ') {\n' + branch + '}\n';
  branch =  branch;
  // code += 'for (var ' + variable0 + ' in ' + argument0 + ') {\n' + branch + '}\n';
  code += 'async ' + variable0 + 'ON' + argument0 + '(ctx) {\n' + Blockly.JavaScript.INDENT +
  'if (!(' + variable0 + ' = \'' + argument0 + '\')) {\n'+Blockly.JavaScript.INDENT+Blockly.JavaScript.INDENT+'return JSON.stringify({ERROR: not compliant in agendum clause});\n' + Blockly.JavaScript.INDENT + '}\n'+
  branch+ '\n}\n';
  return code;
};

Blockly.JavaScript['while_clause'] = function(block) {
  // If/elseif/else condition.
  var n = 0;
  var code = ''
  if (Blockly.JavaScript.STATEMENT_PREFIX) {
    // Automatic prefix insertion is switched off for this block.  Add manually.
    code += Blockly.JavaScript.injectId(Blockly.JavaScript.STATEMENT_PREFIX,
        block);
  }
  // do {
	  // //console.log(block.inputList[1].fieldRow[0].getValue().substr(block.inputList[1].fieldRow[0].getValue().length-2, 2));
	  // console.log(block.inputList[2]);//[1].fieldRow[2].getValue());   
   // conditionCode = Blockly.JavaScript.valueToCode(block, 'IF' + n,
        // Blockly.JavaScript.ORDER_NONE) || 'false';
    // branchCode = Blockly.JavaScript.statementToCode(block, 'DO' + n);
    // if (Blockly.JavaScript.STATEMENT_SUFFIX) {
      // branchCode = Blockly.JavaScript.prefixLines(
          // Blockly.JavaScript.injectId(Blockly.JavaScript.STATEMENT_SUFFIX,
          // block), Blockly.JavaScript.INDENT) + branchCode;
    // }
    // code += (n > 0 ? ' else ' : '') +
        // '\tif (!(' + block.inputList[1].fieldRow[0].getValue().substr(block.inputList[1].fieldRow[0].getValue().length-2, 2) + '==' + block.inputList[1].fieldRow[2].getValue() + ')) {\n' + '\treturn JSON.stringify({error: not complying with while clause});' + '\t'+'\n\t}';
    // ++n;
  // } while (block.getInput('IF' + n));
  //console.log(block.inputList[1].getValue());
  if (block.inputList.length == 2){
	  code += 
        'if (!(' + block.inputList[1].fieldRow[0].getValue().substr(block.inputList[1].fieldRow[0].getValue().length-2, 2) + '== \'' + block.inputList[1].fieldRow[2].getValue() + '\')) {\n' + Blockly.JavaScript.INDENT +'return JSON.stringify({ERROR: not compliant in while clause});\n' + '}';}
  if (block.inputList.length == 3){  
	var argument0 = Blockly.JavaScript.valueToCode(block, 'LIST', Blockly.JavaScript.ORDER_ASSIGNMENT) || '[]';
	var listVar = argument0;
	if (!argument0.match(/^\w+$/)) {
		listVar = Blockly.JavaScript.variableDB_.getDistinctName(
        Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME) + '_list', Blockly.VARIABLE_CATEGORY_NAME);
		code += 'var ' + listVar + ' = ' + argument0 + ';\n';
	}
			code += 'if (!(' + listVar+'.forEach(function('+Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME)+'){ if('+Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME) + '==' + 'RQ){return true;}else{return false;}}'+ ')) {\n' + 
	  Blockly.JavaScript.INDENT + 'return JSON.stringify({ERROR: not complying in while clause});' + '\n}'; 
  }		
  return code + '\n';
};

Blockly.JavaScript['with_clause'] = function(block) {
  // Variable setter.
  var varName = Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME);
  var OPERATORS = {
    'EQ': '==',
    'NEQ': '!=',
    'LT': '<',
    'LTE': '<=',
    'GT': '>',
    'GTE': '>='
  };
  var operator = OPERATORS[block.getFieldValue('OP')];
  var order = (operator == '==' || operator == '!=') ?
      Blockly.JavaScript.ORDER_EQUALITY : Blockly.JavaScript.ORDER_RELATIONAL;
  var argument1 = Blockly.JavaScript.valueToCode(block, 'B', order) || '0';
  var code = 'if(!(' + varName + operator + argument1 + ')) {\n' +
  Blockly.JavaScript.INDENT + 'return JSON.stringify({ERROR: not complying in with clause});\n}'
  return code + '\n';
};

Blockly.JavaScript['clause'] = function(block) {
  // Variable setter.
  var varName = Blockly.JavaScript.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.VARIABLE_CATEGORY_NAME);
  var OPERATORS = {
    'request': 'request',
    'promise': 'promise',
    'decline': 'decline'
  };
  var operator = OPERATORS[block.getFieldValue('OP')];
  var order = (operator == '==' || operator == '!=') ?
      Blockly.JavaScript.ORDER_EQUALITY : Blockly.JavaScript.ORDER_RELATIONAL;
  var argument1 = Blockly.JavaScript.valueToCode(block, 'B', order) || '0';
  var code = 'if(!(' + varName + operator + argument1 + ')) {\n' +
  Blockly.JavaScript.INDENT + 'return JSON.stringify({ERROR: not complying in with clause});\n}'
  return code + '\n';
};