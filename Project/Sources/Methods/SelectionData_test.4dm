//%attributes = {}
/* Purpose: 
 ------------------
SelectionData_test ()
 Created by: Kirk as Designer, Created: 10/30/23, 13:03:42
*/

var $class : cs.SelectionData


$class:=cs.SelectionData.new()

$class:=cs.SelectionData.new("test")

$class:=cs.SelectionData.new("addresses")\
.setSource(ds.ADDRESS.all())\
.setHeaders({street: "Street"; city: "City"; kind: "Type"})

$collection:=ds.ADDRESS.all().toCollection()
$class:=cs.SelectionData.new("addresses").setSource($collection)

$collection:=ds.ADDRESS.all().toCollection(""; dk with stamp)
$class:=cs.SelectionData.new("addresses").setSource($collection)

