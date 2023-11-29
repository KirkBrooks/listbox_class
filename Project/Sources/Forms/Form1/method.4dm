

//mark:  --- listbox: newListbox_LB
//todo: move this near the top, before any form objects that may access the data 
var $newListbox_LB : cs.listbox
$newListbox_LB:=Form.newListbox_LB ? Form.newListbox_LB : cs.listbox.new("newListbox_LB")

Case of 
: (Form event code=On Load) && (Form.newListbox_LB=Null)
Form.newListbox_LB:=$newListbox_LB
 $newListbox_LB.setSource([{a: 1}; {a: 2}; {a: 3}; {a: 4}])
: (FORM Event.objectName#"newListbox_LB")

: (Form event code=On Selection Change)

: (Form event code=On Data Change)

End case

//mark:  --- listbox: another_LB
//todo: move this near the top, before any form objects that may access the data 
var $another_LB : cs.listbox
$another_LB:=Form.another_LB ? Form.another_LB : cs.listbox.new("another_LB")

Case of 
: (Form event code=On Load) && (Form.another_LB=Null)
Form.another_LB:=$another_LB
 $another_LB.setSource([{a: 1}; {a: 2}; {a: 3}; {a: 4}])
: (FORM Event.objectName#"another_LB")

: (Form event code=On Selection Change)

: (Form event code=On Data Change)

End case
