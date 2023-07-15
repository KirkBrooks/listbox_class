//%attributes = {}
/*  Run_demo2 ()
 Created by: Kirk 
*/
var $window : Integer
var $formData : Object
var $es : cs.ADDRESSSelection

$window:=Open form window("demo_two"; Plain form window)

$formData:=New object()
/*  I'm going to use the Address data
I'm going to instantiate some listbox classes populated with various 
selections of address before opening the form. This could also be done
on the form but I'm doing it here. 

*/

var $listboxes : Collection
$listboxes:=New collection()

// notice I'm using a temp name for the listbox
/* Also - notice that I populate each listbox with a separate query. This means the 
contents of each listbox are discrete. One set of entities in the 'CA address' and 
in 'All records' a different set of entities for the same records. If I make changes
to one set they are not propagated to the other. 

On the other hand if I had done a query on the All records class then any changes I
made to the 'CA Addresses' would also appear on the 'All records' class - though I 
may need a refresh. 
*/
$listboxes.push(New object(\
"name"; "All Records"; \
"listbox"; cs.listbox.new("x").setSource(ds.ADDRESS.all())))

$listboxes.push(New object(\
"name"; "CA addresses"; \
"listbox"; cs.listbox.new("x").setSource(ds.ADDRESS.query("state = :1"; "CA"))))

$listboxes.push(New object(\
"name"; "DC addresses"; \
"listbox"; cs.listbox.new("x").setSource(ds.ADDRESS.query("state = :1"; "DC"))))

$listboxes.push(New object(\
"name"; "Springfield"; \
"listbox"; cs.listbox.new("x").setSource(ds.ADDRESS.query("city = :1"; "Springfield"))))


$formData.listboxes:=$listboxes

DIALOG("demo_two"; $formData)
CLOSE WINDOW($window)



