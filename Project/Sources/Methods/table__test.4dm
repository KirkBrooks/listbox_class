//%attributes = {}


var $class : cs.HTMLtable
var $listbox : cs.listbox
var $col : Collection
var $html : Text

$col:=[]

$listbox:=cs.listbox.new("htmlTable")
$listbox.setSource(ds.ADDRESS.all().slice(0; 12))

$class:=cs.HTMLtable.new().setListbox($listbox)  //  
$class.PKproperty:="ID"
$class.insertColumn("oneLine()")

// $class.setFields()

$html:=$class.getTable()

SET TEXT TO PASTEBOARD($html)







/*
For ($i; 1; 3)
$property:="col_"+String($i)

$colObj:={}
$colObj.property:=$property
$colObj.header:={}
$colObj.header.label:=$property
$colObj.x:=1224

$col.push($colObj)
End for 

var $entity : cs.ADDRESSEntity
$entity:=ds.ADDRESS.all().first()

$text:=$entity.oneLine()


$template:="<td><!--#4DEVAL String($1.latitude;$2)--></td>"
$output:=""
$format:="##.00"
PROCESS 4D TAGS($template; $output; $entity; $format)
*/


