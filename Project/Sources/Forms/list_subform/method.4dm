/*  list_subform - form method
 Created by: Kirk as Designer, Created: 01/08/24, 09:47:59
 ------------------
  ListSubform class is instantiated as Form
*/

var $objectName; $tableName : Text
var $l; $t; $r; $b; $formEvent : Integer
var $items_LB : cs.listbox
var $listSubform : cs.ListSubform

If (Form=Null)
	return 
End if 

$listSubform:=Form

$objectName:=String(FORM Event.objectName)
$items_LB:=Form.items_LB
$formEvent:=Form event code

//mark:  --- on load
If ($formEvent=On Load)  //  catches all objects
	
End if 

//mark:  --- form events handled by ListSubform class
$formEvent:=$listSubform.eventHandler($formEvent; $objectName)


//mark:  --- object actions
If ($objectName="items_LB")
	
End if 

If ($objectName="searchInput") && (Form event code=On After Edit)
	
	
End if 

If ($objectName="table_btn")
	Form.selectTableForms()
End if 

//mark:  --- update state and formats
If (Bool(Form.doResize))
	Form.resizeListbox()
End if 