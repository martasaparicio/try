Blockly.Blocks['organization_contract'] = {
  /**
   * Block for defining a procedure with no return value.
   * @this {Blockly.Block}
   */
  init: function() {
    // var nameField = new Blockly.FieldTextInput('',
        // Blockly.Procedures.rename);
	var nameField = new Blockly.FieldTextInput('organizationName',
        Blockly.Procedures.rename);
    nameField.setSpellcheck(false);
    this.appendDummyInput()
        .appendField("Organization Name:")
        .appendField(nameField, 'NAME')
        .appendField('', 'PARAMS');
    this.setMutator(new Blockly.Mutator(['organization_mutatorarg']));
    if ((this.workspace.options.comments ||
         (this.workspace.options.parentWorkspace &&
          this.workspace.options.parentWorkspace.options.comments)) &&
        Blockly.Msg['PROCEDURES_DEFNORETURN_COMMENT']) {
      //this.setCommentText(Blockly.Msg['PROCEDURES_DEFNORETURN_COMMENT']);
	  this.setCommentText("Set code comment about the contract...");
    }
    this.setStyle('procedure_blocks');
    //this.setTooltip(Blockly.Msg['PROCEDURES_DEFNORETURN_TOOLTIP']);
	this.setTooltip("Set organization name and corresponding transactions...");
    this.setHelpUrl(Blockly.Msg['PROCEDURES_DEFNORETURN_HELPURL']);
    this.arguments_ = [];
    this.argumentVarModels_ = [];
    this.setStatements_(true);
    this.statementConnection_ = null;
  },
  /**
   * Add or remove the statement block from this function definition.
   * @param {boolean} hasStatements True if a statement block is needed.
   * @this {Blockly.Block}
   */
  setStatements_: function(hasStatements) {
    if (this.hasStatements_ === hasStatements) {
      return;
    }
    if (hasStatements) {
      this.appendStatementInput('STACK')
          .appendField(Blockly.Msg['PROCEDURES_DEFNORETURN_DO']);
      if (this.getInput('RETURN')) {
        this.moveInputBefore('STACK', 'RETURN');
      }
    } else {
      this.removeInput('STACK', true);
    }
    this.hasStatements_ = hasStatements;
  },
  /**
   * Update the display of parameters for this procedure definition block.
   * @private
   * @this {Blockly.Block}
   */
  updateParams_: function() {

    // Merge the arguments into a human-readable list.
    var paramString = '';
    if (this.arguments_.length) {
		//console.log(this.arguments_);
      // paramString = Blockly.Msg['PROCEDURES_BEFORE_PARAMS'] +
          // ' ' + this.arguments_.join(', ');
	  paramString = "transactions:" +
	      ' ' + this.arguments_.join(', ');
    }
    // The params field is deterministic based on the mutation,
    // no need to fire a change event.
    Blockly.Events.disable();
    try {
      this.setFieldValue(paramString, 'PARAMS');
    } finally {
      Blockly.Events.enable();
    }
  },
  /**
   * Create XML to represent the argument inputs.
   * @param {boolean=} opt_paramIds If true include the IDs of the parameter
   *     quarks.  Used by Blockly.Procedures.mutateCallers for reconnection.
   * @return {!Element} XML storage element.
   * @this {Blockly.Block}
   */
  mutationToDom: function(opt_paramIds) {
    var container = Blockly.utils.xml.createElement('mutation');
    if (opt_paramIds) {
      container.setAttribute('name', this.getFieldValue('NAME'));
    }
    for (var i = 0; i < this.argumentVarModels_.length; i++) {
      var parameter = Blockly.utils.xml.createElement('arg');
      var argModel = this.argumentVarModels_[i];
      parameter.setAttribute('name', argModel.name);
      parameter.setAttribute('varid', argModel.getId());
      if (opt_paramIds && this.paramIds_) {
        parameter.setAttribute('paramId', this.paramIds_[i]);
      }
      container.appendChild(parameter);
    }

    // Save whether the statement input is visible.
    if (!this.hasStatements_) {
      container.setAttribute('statements', 'false');
    }
    return container;
  },
  /**
   * Parse XML to restore the argument inputs.
   * @param {!Element} xmlElement XML storage element.
   * @this {Blockly.Block}
   */
  domToMutation: function(xmlElement) {
    this.arguments_ = [];
    this.argumentVarModels_ = [];
    for (var i = 0, childNode; (childNode = xmlElement.childNodes[i]); i++) {
      if (childNode.nodeName.toLowerCase() == 'arg') {
        var varName = childNode.getAttribute('name');
        var varId = childNode.getAttribute('varid') || childNode.getAttribute('varId');
        this.arguments_.push(varName);
        var variable = Blockly.Variables.getOrCreateVariablePackage(
            this.workspace, varId, varName, '');
        if (variable != null) {
          this.argumentVarModels_.push(variable);
        } else {
          console.log('Failed to create a variable with name ' + varName + ', ignoring.');
        }
      }
    }
    this.updateParams_();
    Blockly.Procedures.mutateCallers(this);

    // Show or hide the statement input.
    this.setStatements_(xmlElement.getAttribute('statements') !== 'false');
  },
  /**
   * Populate the mutator's dialog with this block's components.
   * @param {!Blockly.Workspace} workspace Mutator's workspace.
   * @return {!Blockly.Block} Root block in mutator.
   * @this {Blockly.Block}
   */
  decompose: function(workspace) {
    /*
     * Creates the following XML:
     * <block type="organization_mutatorcontainer">
     *   <statement name="STACK">
     *     <block type="organization_mutatorarg">
     *       <field name="NAME">arg1_name</field>
     *       <next>etc...</next>
     *     </block>
     *   </statement>
     * </block>
     */

    var containerBlockNode = Blockly.utils.xml.createElement('block');
    containerBlockNode.setAttribute('type', 'organization_mutatorcontainer');
    var statementNode = Blockly.utils.xml.createElement('statement');
    statementNode.setAttribute('name', 'STACK');
    containerBlockNode.appendChild(statementNode);

    var node = statementNode;
    for (var i = 0; i < this.arguments_.length; i++) {
      var argBlockNode = Blockly.utils.xml.createElement('block');
      argBlockNode.setAttribute('type', 'organization_mutatorarg');
      var fieldNode = Blockly.utils.xml.createElement('field');
      fieldNode.setAttribute('name', 'NAME');
      var argumentName = Blockly.utils.xml.createTextNode(this.arguments_[i]);
      fieldNode.appendChild(argumentName);
      argBlockNode.appendChild(fieldNode);
      var nextNode = Blockly.utils.xml.createElement('next');
      argBlockNode.appendChild(nextNode);

      node.appendChild(argBlockNode);
      node = nextNode;
    }

    var containerBlock = Blockly.Xml.domToBlock(containerBlockNode, workspace);

    if (this.type == 'procedures_defreturn') {
      containerBlock.setFieldValue(this.hasStatements_, 'STATEMENTS');
    } else {
      containerBlock.removeInput('STATEMENT_INPUT');
    }

    // Initialize procedure's callers with blank IDs.
    Blockly.Procedures.mutateCallers(this);
    return containerBlock;
  },
  /**
   * Reconfigure this block based on the mutator dialog's components.
   * @param {!Blockly.Block} containerBlock Root block in mutator.
   * @this {Blockly.Block}
   */
  compose: function(containerBlock) {
    // Parameter list.
    this.arguments_ = [];
    this.paramIds_ = [];
    this.argumentVarModels_ = [];
    var paramBlock = containerBlock.getInputTargetBlock('STACK');
    while (paramBlock) {
      var varName = paramBlock.getFieldValue('NAME');
      this.arguments_.push(varName);
      var variable = this.workspace.getVariable(varName, '');
      this.argumentVarModels_.push(variable);

      this.paramIds_.push(paramBlock.id);
      paramBlock = paramBlock.nextConnection &&
          paramBlock.nextConnection.targetBlock();
    }
    this.updateParams_();
    Blockly.Procedures.mutateCallers(this);

    // Show/hide the statement input.
    var hasStatements = containerBlock.getFieldValue('STATEMENTS');
    if (hasStatements !== null) {
      hasStatements = hasStatements == 'TRUE';
      if (this.hasStatements_ != hasStatements) {
        if (hasStatements) {
          this.setStatements_(true);
          // Restore the stack, if one was saved.
          Blockly.Mutator.reconnect(this.statementConnection_, this, 'STACK');
          this.statementConnection_ = null;
        } else {
          // Save the stack, then disconnect it.
          var stackConnection = this.getInput('STACK').connection;
          this.statementConnection_ = stackConnection.targetConnection;
          if (this.statementConnection_) {
            var stackBlock = stackConnection.targetBlock();
            stackBlock.unplug();
            stackBlock.bumpNeighbours();
          }
          this.setStatements_(false);
        }
      }
    }
  },
  /**
   * Return the signature of this procedure definition.
   * @return {!Array} Tuple containing three elements:
   *     - the name of the defined procedure,
   *     - a list of all its arguments,
   *     - that it DOES NOT have a return value.
   * @this {Blockly.Block}
   */
  getProcedureDef: function() {
    return [this.getFieldValue('NAME'), this.arguments_, false];
  },
  /**
   * Return all variables referenced by this block.
   * @return {!Array.<string>} List of variable names.
   * @this {Blockly.Block}
   */
  getVars: function() {
    return this.arguments_;
  },
  /**
   * Return all variables referenced by this block.
   * @return {!Array.<!Blockly.VariableModel>} List of variable models.
   * @this {Blockly.Block}
   */
  getVarModels: function() {
    return this.argumentVarModels_;
  },
  /**
   * Notification that a variable is renaming.
   * If the ID matches one of this block's variables, rename it.
   * @param {string} oldId ID of variable to rename.
   * @param {string} newId ID of new variable.  May be the same as oldId, but
   *     with an updated name.  Guaranteed to be the same type as the old
   *     variable.
   * @override
   * @this {Blockly.Block}
   */
  renameVarById: function(oldId, newId) {
    var oldVariable = this.workspace.getVariableById(oldId);
    if (oldVariable.type != '') {
      // Procedure arguments always have the empty type.
      return;
    }
    var oldName = oldVariable.name;
    var newVar = this.workspace.getVariableById(newId);

    var change = false;
    for (var i = 0; i < this.argumentVarModels_.length; i++) {
      if (this.argumentVarModels_[i].getId() == oldId) {
        this.arguments_[i] = newVar.name;
        this.argumentVarModels_[i] = newVar;
        change = true;
      }
    }
    if (change) {
      this.displayRenamedVar_(oldName, newVar.name);
      Blockly.Procedures.mutateCallers(this);
    }
  },
  /**
   * Notification that a variable is renaming but keeping the same ID.  If the
   * variable is in use on this block, rerender to show the new name.
   * @param {!Blockly.VariableModel} variable The variable being renamed.
   * @package
   * @override
   * @this {Blockly.Block}
   */
  updateVarName: function(variable) {
    var newName = variable.name;
    var change = false;
    for (var i = 0; i < this.argumentVarModels_.length; i++) {
      if (this.argumentVarModels_[i].getId() == variable.getId()) {
        var oldName = this.arguments_[i];
        this.arguments_[i] = newName;
        change = true;
      }
    }
    if (change) {
      this.displayRenamedVar_(oldName, newName);
      Blockly.Procedures.mutateCallers(this);
    }
  },
  /**
   * Update the display to reflect a newly renamed argument.
   * @param {string} oldName The old display name of the argument.
   * @param {string} newName The new display name of the argument.
   * @private
   * @this {Blockly.Block}
   */
  displayRenamedVar_: function(oldName, newName) {
    this.updateParams_();
    // Update the mutator's variables if the mutator is open.
    if (this.mutator && this.mutator.isVisible()) {
      var blocks = this.mutator.workspace_.getAllBlocks(false);
      for (var i = 0, block; (block = blocks[i]); i++) {
        if (block.type == 'organization_mutatorarg' &&
            Blockly.Names.equals(oldName, block.getFieldValue('NAME'))) {
          block.setFieldValue(newName, 'NAME');
        }
      }
    }
  },
  /**
   * Add custom menu options to this block's context menu.
   * @param {!Array} options List of menu options to add to.
   * @this {Blockly.Block}
   */
  customContextMenu: function(options) {
    if (this.isInFlyout) {
      return;
    }
    // Add option to create caller.
    var option = {enabled: true};
    var name = this.getFieldValue('NAME');
    option.text = Blockly.Msg['PROCEDURES_CREATE_DO'].replace('%1', name);
    var xmlMutation = Blockly.utils.xml.createElement('mutation');
    xmlMutation.setAttribute('name', name);
    for (var i = 0; i < this.arguments_.length; i++) {
      var xmlArg = Blockly.utils.xml.createElement('arg');
      xmlArg.setAttribute('name', this.arguments_[i]);
      xmlMutation.appendChild(xmlArg);
    }
    var xmlBlock = Blockly.utils.xml.createElement('block');
    xmlBlock.setAttribute('type', this.callType_);
    xmlBlock.appendChild(xmlMutation);
    option.callback = Blockly.ContextMenu.callbackFactory(this, xmlBlock);
    options.push(option);

    // Add options to create getters for each parameter.
    if (!this.isCollapsed()) {
      for (var i = 0; i < this.argumentVarModels_.length; i++) {
        var argOption = {enabled: true};
        var argVar = this.argumentVarModels_[i];
        argOption.text = Blockly.Msg['VARIABLES_SET_CREATE_GET']
            .replace('%1', argVar.name);

        var argXmlField = Blockly.Variables.generateVariableFieldDom(argVar);
        var argXmlBlock = Blockly.utils.xml.createElement('block');
        argXmlBlock.setAttribute('type', 'variables_get');
        argXmlBlock.appendChild(argXmlField);
        argOption.callback =
            Blockly.ContextMenu.callbackFactory(this, argXmlBlock);
        options.push(argOption);
      }
    }
  },
  //callType_: 'procedures_callnoreturn'
};

Blockly.Blocks['organization_mutatorcontainer'] = {
  /**
   * Mutator block for procedure container.
   * @this {Blockly.Block}
   */
  init: function() {
    this.appendDummyInput()
        // .appendField(Blockly.Msg['PROCEDURES_MUTATORCONTAINER_TITLE']);
		.appendField("transactions");
    this.appendStatementInput('STACK');
    this.appendDummyInput('STATEMENT_INPUT')
        .appendField(Blockly.Msg['PROCEDURES_ALLOW_STATEMENTS'])
        .appendField(new Blockly.FieldCheckbox('TRUE'), 'STATEMENTS');
    this.setStyle('procedure_blocks');
    // this.setTooltip(Blockly.Msg['PROCEDURES_MUTATORCONTAINER_TOOLTIP']);
	this.setTooltip("Add, remove, or reorder transactions to this organization.");
    this.contextMenu = false;
  },
};

Blockly.Blocks['organization_mutatorarg'] = {
  /**
   * Mutator block for procedure argument.
   * @this {Blockly.Block}
   */
  init: function() {
    var field = new Blockly.FieldTextInput(
        'transactionKindName', this.validator_);
    // Hack: override showEditor to do just a little bit more work.
    // We don't have a good place to hook into the start of a text edit.
    field.oldShowEditorFn_ = field.showEditor_;
    var newShowEditorFn = function() {
      this.createdVariables_ = [];
      this.oldShowEditorFn_();
    };
    field.showEditor_ = newShowEditorFn;

    this.appendDummyInput()
        // .appendField(Blockly.Msg['PROCEDURES_MUTATORARG_TITLE'])
		.appendField("transaction name:")
        .appendField(field, 'NAME');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setStyle('procedure_blocks');
    // this.setTooltip(Blockly.Msg['PROCEDURES_MUTATORARG_TOOLTIP']);
	this.setTooltip("Add a transaction to the organization.");
    this.contextMenu = false;

    // Create the default variable when we drag the block in from the flyout.
    // Have to do this after installing the field on the block.
    field.onFinishEditing_ = this.deleteIntermediateVars_;
    // Create an empty list so onFinishEditing_ has something to look at, even
    // though the editor was never opened.
    field.createdVariables_ = [];
    field.onFinishEditing_('x');
  },

  /**
   * Obtain a valid name for the procedure argument. Create a variable if
   * necessary.
   * Merge runs of whitespace.  Strip leading and trailing whitespace.
   * Beyond this, all names are legal.
   * @param {string} varName User-supplied name.
   * @return {?string} Valid name, or null if a name was not specified.
   * @private
   * @this Blockly.FieldTextInput
   */
  validator_: function(varName) {
    var sourceBlock = this.getSourceBlock();
    var outerWs = Blockly.Mutator.findParentWs(sourceBlock.workspace);
    varName = varName.replace(/[\s\xa0]+/g, ' ').replace(/^ | $/g, '');
    if (!varName) {
      return null;
    }

    // Prevents duplicate parameter names in functions
    var workspace = sourceBlock.workspace.targetWorkspace ||
        sourceBlock.workspace;
    var blocks = workspace.getAllBlocks(false);
    var caselessName = varName.toLowerCase();
    for (var i = 0; i < blocks.length; i++) {
      if (blocks[i].id == this.getSourceBlock().id) {
        continue;
      }
      // Other blocks values may not be set yet when this is loaded.
      var otherVar = blocks[i].getFieldValue('NAME');
      if (otherVar && otherVar.toLowerCase() == caselessName) {
        return null;
      }
    }

    // Don't create variables for arg blocks that
    // only exist in the mutator's flyout.
    if (sourceBlock.isInFlyout) {
      return varName;
    }

    var model = outerWs.getVariable(varName, '');
    if (model && model.name != varName) {
      // Rename the variable (case change)
      outerWs.renameVariableById(model.getId(), varName);
    }
    if (!model) {
      model = outerWs.createVariable(varName, '');
      if (model && this.createdVariables_) {
        this.createdVariables_.push(model);
      }
    }
    return varName;
  },

  /**
   * Called when focusing away from the text field.
   * Deletes all variables that were created as the user typed their intended
   * variable name.
   * @param {string} newText The new variable name.
   * @private
   * @this Blockly.FieldTextInput
   */
  deleteIntermediateVars_: function(newText) {
    var outerWs = Blockly.Mutator.findParentWs(this.getSourceBlock().workspace);
    if (!outerWs) {
      return;
    }
    for (var i = 0; i < this.createdVariables_.length; i++) {
      var model = this.createdVariables_[i];
      if (model.name != newText) {
        outerWs.deleteVariableById(model.getId());
      }
    }
  }
};

Blockly.defineBlocksWithJsonArray([
{
    "type": "agendum_clause",
    "message0": "Rule: When %1 is %2",
    "args0": [
      {
        "type": "field_variable",
        "name": "VAR",
        "variable": "transactionKindName"
      },
      {
        "type": "field_dropdown",
        "name": "LIST",
        "options": [
          [
            "requested",
            "requested"
          ],
          [
            "promised",
            "promised"
          ],
          [
            "declared",
            "declared"
          ],
		  [
            "accepted",
            "accepted"
          ],
		  [
            "declined",
            "declined"
          ],
		  [
            "rejected",
            "rejected"
          ],
		  [
            "revoked",
            "revoked"
          ],
		  [
            "allowed",
            "allowed"
          ],
		  [
            "refused",
            "refused"
          ]
        ]
      }
    ],
    "message1": "%1",
    "args1": [{
      "type": "input_statement",
      "name": "DO"
    }],
    "previousStatement": null,
    "nextStatement": null,
    "style": "loop_blocks",
    "helpUrl": "%{BKY_CONTROLS_FOREACH_HELPURL}",
    "extensions": [
      "contextMenu_newGetVariableBlock",
      "agendum_clause_tooltip"
    ]
  }
]); 
Blockly.Extensions.register('agendum_clause_tooltip',
    Blockly.Extensions.buildTooltipWithFieldText(
        '%{BKY_CONTROLS_FOREACH_TOOLTIP}', 'VAR'));
		
Blockly.defineBlocksWithJsonArray([
  {
    "type": "while_clause",
    "message0": "While %1",
    "args0": [
      {
        "type": "input_dummy",
        "name": "IF0",
        
      }
    ],
    // "message1": "%1",
    // "args1": [
      // {
        // "type": "input_dummy",
        // "name": "DO0"
      // }
    // ],
    "previousStatement": null,
    "nextStatement": null,
    "style": "logic_blocks",
    "helpUrl": "%{BKY_CONTROLS_IF_HELPURL}",
    "mutator": "while_mutator",
    "extensions": ["while_tooltip"]
  }
]);

Blockly.defineBlocksWithJsonArray([ // Mutator blocks. Do not extract.
  // Block representing the if statement in the controls_if mutator.
  {
    "type": "controls_while_while",
    "message0": "While",
    "nextStatement": null,
    "enableContextMenu": false,
    "style": "logic_blocks",
    "tooltip": "%{BKY_CONTROLS_IF_IF_TOOLTIP}"
  },
  // Block representing the else-if statement in the controls_if mutator.
  {
    "type": "controls_while_elseif",
    "message0": "%1 is %2",
	  "args0": [
		{
        "type": "field_variable",
        "name": "VAR",
        "variable": "transactionKindName"
        },
		{
		  "type": "field_dropdown",
		  "name": "optionsNAME",
		          "options": [
          [
            "requested",
            "requested"
          ],
          [
            "promised",
            "promised"
          ],
          [
            "declared",
            "declared"
          ],
		  [
            "accepted",
            "accepted"
          ],
		  [
            "declined",
            "declined"
          ],
		  [
            "rejected",
            "rejected"
          ],
		  [
            "revoked",
            "revoked"
          ],
		  [
            "allowed",
            "allowed"
          ],
		  [
            "refused",
            "refused"
          ]
        ]
		}
	  ],
    "previousStatement": null,
    "enableContextMenu": false,
    "style": "logic_blocks",
    "tooltip": "%{BKY_CONTROLS_IF_ELSEIF_TOOLTIP}"
  },
  
    // Block representing the else statement in the controls_if mutator.
  {
    "type": "controls_while_else",
    "message0": "for each item %1 in %2 is %3",
	"args0": [
      {
        "type": "field_variable",
        "name": "VAR",
        "variable": null
      },
      {
        "type": "input_value",
        "name": "LIST",
        "check": "Array"
      },
	  {  
	    "type": "field_dropdown",
		 "name": "optionsNAME",
		 "options": [
          [
            "requested",
            "requested"
          ],
          [
            "promised",
            "promised"
          ],
          [
            "declared",
            "declared"
          ],
		  [
            "accepted",
            "accepted"
          ],
		  [
            "declined",
            "declined"
          ],
		  [
            "rejected",
            "rejected"
          ],
		  [
            "revoked",
            "revoked"
          ],
		  [
            "allowed",
            "allowed"
          ],
		  [
            "refused",
            "refused"
          ]
        ]
		}
    ],
    "previousStatement": null,
    "enableContextMenu": false,
    "style": "logic_blocks",
    "tooltip": "%{BKY_CONTROLS_IF_ELSE_TOOLTIP}"
  }
]);

Blockly.Constants.Logic.CONTROLS_IF_MUTATOR_MIXIN = {
  elseifCount_: 0,
  elseCount_: 0,

  /**
   * Don't automatically add STATEMENT_PREFIX and STATEMENT_SUFFIX to generated
   * code.  These will be handled manually in this block's generators.
   */
  suppressPrefixSuffix: true,

  /**
   * Create XML to represent the number of else-if and else inputs.
   * @return {Element} XML storage element.
   * @this {Blockly.Block}
   */
  mutationToDom: function() {
    if (!this.elseifCount_ && !this.elseCount_) {
      return null;
    }
    var container = Blockly.utils.xml.createElement('mutation');
    if (this.elseifCount_) {
      container.setAttribute('elseif', this.elseifCount_);
    }
	// if (this.elseifCount_) {
      // container.setAttribute('elseif', 1);
    // }
    if (this.elseCount_) {
      container.setAttribute('else', 1);
    }
    return container;
  },
  /**
   * Parse XML to restore the else-if and else inputs.
   * @param {!Element} xmlElement XML storage element.
   * @this {Blockly.Block}
   */
  domToMutation: function(xmlElement) {
    this.elseifCount_ = parseInt(xmlElement.getAttribute('elseif'), 10) || 0;
    this.elseCount_ = parseInt(xmlElement.getAttribute('else'), 10) || 0;
    this.rebuildShape_();
  },
  /**
   * Populate the mutator's dialog with this block's components.
   * @param {!Blockly.Workspace} workspace Mutator's workspace.
   * @return {!Blockly.Block} Root block in mutator.
   * @this {Blockly.Block}
   */
  decompose: function(workspace) {
    var containerBlock = workspace.newBlock('controls_while_while');
    containerBlock.initSvg();
    var connection = containerBlock.nextConnection;
    for (var i = 1; i <= this.elseifCount_; i++) {
      var elseifBlock = workspace.newBlock('controls_while_elseif');
      elseifBlock.initSvg();
      connection.connect(elseifBlock.previousConnection);
      connection = elseifBlock.nextConnection;
    }
	// if (this.elseifCount_) {
      // var elseifBlock = workspace.newBlock('controls_while_elseif');
      // elseifBlock.initSvg();
      // connection.connect(elseifBlock.previousConnection);
    // }
    if (this.elseCount_) {
      var elseBlock = workspace.newBlock('controls_while_else');
      elseBlock.initSvg();
      connection.connect(elseBlock.previousConnection);
    }
    return containerBlock;
  },
  /**
   * Reconfigure this block based on the mutator dialog's components.
   * @param {!Blockly.Block} containerBlock Root block in mutator.
   * @this {Blockly.Block}
   */
  compose: function(containerBlock) {
    var clauseBlock = containerBlock.nextConnection.targetBlock();
    // Count number of inputs.
    this.elseifCount_ = 0;
    this.elseCount_ = 0;
    var valueConnections = [null];
    var statementConnections = [null];
    var elseStatementConnection = null;
    while (clauseBlock) {
      switch (clauseBlock.type) {
        case 'controls_while_elseif':
          this.elseifCount_++;
          valueConnections.push(clauseBlock.valueConnection_);
          statementConnections.push(clauseBlock.statementConnection_);
		  //elseStatementConnection = clauseBlock.statementConnection_;
          break;
        case 'controls_while_else':
          this.elseCount_++;
          elseStatementConnection = clauseBlock.statementConnection_;
          break;
        default:
          throw TypeError('Unknown block type: ' + clauseBlock.type);
      }
      clauseBlock = clauseBlock.nextConnection &&
          clauseBlock.nextConnection.targetBlock();
    }
    this.updateShape_();
    // Reconnect any child blocks.
    this.reconnectChildBlocks_(valueConnections, statementConnections,
        elseStatementConnection);
  },
  /**
   * Store pointers to any connected child blocks.
   * @param {!Blockly.Block} containerBlock Root block in mutator.
   * @this {Blockly.Block}
   */
  saveConnections: function(containerBlock) {
    var clauseBlock = containerBlock.nextConnection.targetBlock();
    var i = 1;
    while (clauseBlock) {
      switch (clauseBlock.type) {
        case 'controls_while_elseif':
		  //console.log(this.getInput('transactionKindNAME'));
          var inputIf = this.getInput('transactionKindNAME');
		  console.log(inputIf);	//AQUI
          //var inputDo = this.getInput('optionsNAME');
		  //console.log(inputDo);	//AQUI
          clauseBlock.valueConnection_ =
              inputIf && inputIf.connection.targetConnection;
          // clauseBlock.statementConnection_ =
              // inputDo && inputDo.connection.targetConnection;
          i++;
          break;
        case 'controls_while_else':
          var inputDo = this.getInput('LIST');
		  console.log(inputDo);
          clauseBlock.statementConnection_ =
              inputDo && inputDo.connection.targetConnection;
          break;
        default:
          throw TypeError('Unknown block type: ' + clauseBlock.type);
      }
      clauseBlock = clauseBlock.nextConnection &&
          clauseBlock.nextConnection.targetBlock();
    }
  },
  /**
   * Reconstructs the block with all child blocks attached.
   * @this {Blockly.Block}
   */
  rebuildShape_: function() {
    var valueConnections = [null];
    var statementConnections = [null];
    var elseStatementConnection = null;

    if (this.getInput('LIST')) {
      elseStatementConnection = this.getInput('LIST').connection.targetConnection;
    }
    var i = 1;
    // while (this.getInput('IF' + i)) {
      // var inputIf = this.getInput('IF' + i);
      // var inputDo = this.getInput('DO' + i);
      // valueConnections.push(inputIf.connection.targetConnection);
      // statementConnections.push(inputDo.connection.targetConnection);
      // i++;
    // }
	while (this.getInput('transactionKindNAME')) {
      var inputIf = this.getInput('transactionKindNAME');
      //var inputDo = this.getInput('DO' + i);
      valueConnections.push(inputIf.connection.targetConnection);
      //statementConnections.push(inputDo.connection.targetConnection);
      i++;
    }
    this.updateShape_();
    this.reconnectChildBlocks_(valueConnections, statementConnections,
        elseStatementConnection);
  },
  /**
   * Modify this block to have the correct number of inputs.
   * @this {Blockly.Block}
   * @private
   */
  updateShape_: function() {
    // Delete everything.
    if (this.getInput('LIST')) {
      this.removeInput('LIST');
    }
    var i = 1;
    while (this.getInput('transactionKindNAME')) {
      this.removeInput('transactionKindNAME');
      //this.removeInput('DO' + i);
      i++;
    }
    // Rebuild block.
    for (i = 1; i <= this.elseifCount_; i++) {
		this.appendDummyInput('transactionKindNAME')
			.appendField(new Blockly.FieldTextInput("transactionKindName"), "transactionKindNAME")
			.appendField("is")
			.appendField(new Blockly.FieldDropdown([["requested","requested"], ["promised","promised"], ["declared","declared"], ["accepted","accepted"], ["declined","declined"], ["rejected","rejected"], ["revoked","revoked"], ["allowed","allowed"], ["refused","refused"]]), "NAME");
	  // this.appendValueInput('IF' + i)
          // .setCheck('Boolean')
          // .appendField(Blockly.Msg['CONTROLS_IF_MSG_ELSEIF']);
      // this.appendStatementInput('DO' + i)
          // .appendField(Blockly.Msg['CONTROLS_IF_MSG_THEN']);
    }
    if (this.elseCount_) {
		this.appendValueInput("LIST")
        .setCheck("Array")
        .appendField("for each item")
        .appendField(new Blockly.FieldVariable("i"), "VAR")
        .appendField("in list");
    this.appendDummyInput()
        .appendField("is")
        .appendField(new Blockly.FieldDropdown([["requested","requested"], ["promised","promised"], ["declared","declared"], ["accepted","accepted"], ["declined","declined"], ["rejected","rejected"], ["revoked","revoked"], ["allowed","allowed"], ["refused","refused"]]), "NAME");
    this.setInputsInline(true);
      // this.appendStatementInput('ELSE')
          // .appendField(Blockly.Msg['CONTROLS_IF_MSG_ELSE']);
    }
  },
  /**
   * Reconnects child blocks.
   * @param {!Array.<?Blockly.RenderedConnection>} valueConnections List of
   * value connections for 'if' input.
   * @param {!Array.<?Blockly.RenderedConnection>} statementConnections List of
   * statement connections for 'do' input.
   * @param {?Blockly.RenderedConnection} elseStatementConnection Statement
   * connection for else input.
   * @this {Blockly.Block}
   */
  reconnectChildBlocks_: function(valueConnections, statementConnections,
      elseStatementConnection) {
    for (var i = 1; i <= this.elseifCount_; i++) {
      Blockly.Mutator.reconnect(valueConnections[i], this, 'transactionKindNAME');
      //Blockly.Mutator.reconnect(statementConnections[i], this, 'DO' + i);
    }
    Blockly.Mutator.reconnect(elseStatementConnection, this, 'LIST');
  }
};

Blockly.Extensions.registerMutator('while_mutator',
    Blockly.Constants.Logic.CONTROLS_IF_MUTATOR_MIXIN, null,
    ['controls_while_elseif', 'controls_while_else']);
	
Blockly.Constants.Logic.CONTROLS_IF_TOOLTIP_EXTENSION = function() {

  this.setTooltip(function() {
    if (!this.elseifCount_ && !this.elseCount_) {
      return Blockly.Msg['CONTROLS_IF_TOOLTIP_1'];
    } else if (!this.elseifCount_ && this.elseCount_) {
      return Blockly.Msg['CONTROLS_IF_TOOLTIP_2'];
    } else if (this.elseifCount_ && !this.elseCount_) {
      return Blockly.Msg['CONTROLS_IF_TOOLTIP_3'];
    } else if (this.elseifCount_ && this.elseCount_) {
      return Blockly.Msg['CONTROLS_IF_TOOLTIP_4'];
    }
    return '';
  }.bind(this));
};

Blockly.Extensions.register('while_tooltip',
    Blockly.Constants.Logic.CONTROLS_IF_TOOLTIP_EXTENSION);
	
Blockly.defineBlocksWithJsonArray([
{
    "type": "with_clause",
    "message0": "With %1 %2 %3",
    "args0": [
      // {
        // "type": "input_value",
        // "name": "A"
      // },
	  {
        "type": "field_variable",
        "name": "VAR",
        "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
      },
      {
        "type": "field_dropdown",
        "name": "OP",
        "options": [
          ["=", "EQ"],
          ["\u2260", "NEQ"],
          ["\u200F<", "LT"],
          ["\u200F\u2264", "LTE"],
          ["\u200F>", "GT"],
          ["\u200F\u2265", "GTE"]
        ]
      },
      {
        "type": "input_value",
        "name": "B"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "style": "logic_blocks",
    "helpUrl": "%{BKY_LOGIC_COMPARE_HELPURL}",
    "extensions": ["logic_compare", "logic_op_tooltip"]
  }
]);

Blockly.defineBlocksWithJsonArray([
{
    "type": "clause",
    "message0": "%1 %2",
    "args0": [
      // {
        // "type": "input_value",
        // "name": "A"
      // },
      {
        "type": "field_dropdown",
        "name": "OP",
        "options": [
          ["request", "request"],
          ["promise", "promise"],
          ["decline", "decline"]
        ]
      },
	  	  {
        "type": "field_variable",
        "name": "VAR",
        "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
      }
    ],
    "inputsInline": true,
    "previousStatement": null,
    "nextStatement": null,
    "style": "logic_blocks",
    "helpUrl": "%{BKY_LOGIC_COMPARE_HELPURL}",
    "extensions": ["logic_compare", "logic_op_tooltip"]
  }
]);