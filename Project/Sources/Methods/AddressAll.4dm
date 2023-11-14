//%attributes = {}
/* Purpose: 
 ------------------
AddressAll ()
 Created by: Kirk as Designer, Created: 11/14/23, 11:05:04
*/
#DECLARE($name : Text; $options : Object)->$listbox : cs.listbox
var $col : Collection
var $entity : cs.ADDRESSEntity

$col:=[]

For each ($entity; ds.ADDRESS.all())
	$col.push(cs.AddressWrap.new($entity))
End for each 

$listbox:=cs.listbox.new($name).setSource($col)
