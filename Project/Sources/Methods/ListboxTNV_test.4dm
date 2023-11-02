//%attributes = {}
/* Purpose: 
 ------------------
ListboxTNV_test ()
 Created by: Kirk as Designer, Created: 10/30/23, 14:17:38
*/

var $class : cs.Listbox_tnv


$class:=cs.Listbox_tnv.new("testLB")

$class:=cs.Listbox_tnv.new("addresses").setSource(ds.ADDRESS.all())


.setHeaders({street: "Street"; city: "City"; kind: "Type"})

