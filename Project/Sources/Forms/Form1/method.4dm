
var $listbox1 : cs.listbox

$listbox1:=Form.listbox1 || cs.listbox.new("listbox1")

If (Form event code=On Load)
	Form.selectRowNumber:=0
	
	Form.listbox1:=$listbox1
	$listbox1.setSource([{value: "a"}; {value: "b"}; {value: "c"}; {value: "d"}])
	
	return 
End if 

If (FORM Event.objectName="button1")  // insertion
	$listbox1.insert(0; {value: Substring(Generate UUID; 14; 6)})
End if 

If (FORM Event.objectName="btn_clearSelection")
	$listbox1.deselect()
End if 

If (FORM Event.objectName="btn_selectRow")
	$listbox1.selectRow(Form.selectRowNumber)
End if 

