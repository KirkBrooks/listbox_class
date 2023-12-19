//%attributes = {}
/* Purpose: 
 ------------------
FormCache__readMe ()
 Created by: Kirk as Designer, Created: 12/10/23, 13:42:49
*/

var $class : cs.FormCache
var $file : 4D.File
var $folder : 4D.Folder
var $name : Text
var $formDef : Object

$name:="Classic_field"

$folder:=Folder("/PROJECT/Sources/Forms/"+$name+"/")

$class:=cs.FormCache.new("input"; 1)
$formDef:=$class.formDefinition

$class:=cs.FormCache.new($formDef)

