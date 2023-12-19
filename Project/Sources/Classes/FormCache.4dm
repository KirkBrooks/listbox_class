/*  FormCache class
 Created by: Kirk as Designer, Created: 11/18/23, 16:00:06
 ------------------
The idea of the formCache is to hold a reference to a 4D form. 
The source of the form can be: 
 - 4D:     name of the form defined in the structure
                 DIALOG by tableName; formName
 - file:   4D File to a form definition file. Resources for example. 
                 DIALOG by path to file
 - object: a form definition object is passed in. 
                 DIALOG by formDefinition


*/
property formDefinition : Object

Class constructor($input; $tableNumber : Integer)
	var $folder : 4D.Folder
	var $name : Text
	
	This._tableNumber:=$tableNumber
	
	Case of 
		: (Value type($input)=Is text)  //  a form name
			This._name:=$input
			If ($tableNumber>0)
				$folder:=Folder("/PROJECT/Sources/TableForms/"+String($tableNumber)+"/"+$input+"/")
			Else 
				$folder:=Folder("/PROJECT/Sources/Forms/"+$input+"/")
			End if 
			This._formFile:=$folder.file("form.4DForm")
			This.error:=This._formFile.exists ? "" : "The json file for '"+$name+"' does not exist."
			This._readFile()
			This.source:="4D"
			
		: (Value type($input)=Is object) && (OB Instance of($input; 4D.File))
			This._name:=$input.name="form" ? $input.parent.name : $input.name  //  folder is form name?
			This.error:=This._formFile.exists ? "" : "The json file for '"+$name+"' does not exist."
			This._formFile:=$input
			This._readFile()
			This.source:="file"
			
		: (Value type($input)=Is object)  // form definition
			This._form:=$input
			This._formFile:=Null
			This._name:="unnamed form"
			This.source:="object"
	End case 
	This._objectsHashTable()
	This._checksum:=This.getCheckSum()
	
	//mark:  --- properties
Function get formDefinition : Object
	return This.ready ? This._form : Null
	
Function get ready : Boolean
	return This._form#Null
	
Function get isTableForm : Boolean
	return This.ready ? This._tableNumber>0 : False
	
Function get isProjectForm : Boolean
	return This.ready ? This._tableNumber=0 : False
	
Function get nPages : Integer
	return This.ready ? This._form.pages.length-1 : 0
	
Function get windowTitle : Text
	return This.ready ? String(This._form.windowTitle) : ""
	
Function set windowTitle($title : Text)
	This.setWindowTitle($title)
	
Function get name : Text
	return This._name
	
Function get tableName : Text
	return (This.ready) && (This._tableNumber>0) ? Table name(This._tableNumber) : ""
	
	//mark:  --- functions
Function dialog($formData : Object; $sameProcess : Boolean)
	//  render the form in a DIALOG. 
	If (This.source="4D")
		Case of 
			: (Count parameters=0) && (Not($sameProcess))
				DIALOG(Table(This._tableNumber)->; This.name)
			: (Count parameters=0)
				DIALOG(Table(This._tableNumber)->; This.name; *)
			: (Count parameters=1) && (Not($sameProcess))
				DIALOG(Table(This._tableNumber)->; This.name; $formData)
			: (Count parameters=1)
				DIALOG(Table(This._tableNumber)->; This.name; $formData; *)
		End case 
		return 
	End if 
	
	If (This.source="file")
		Case of 
			: (Count parameters=0) && (Not($sameProcess))
				DIALOG(This.filePath(); This.name)
			: (Count parameters=0)
				DIALOG(This.filePath(); This.name; *)
			: (Count parameters=1) && (Not($sameProcess))
				DIALOG(This.filePath(); This.name; $formData)
			: (Count parameters=1)
				DIALOG(This.filePath(); This.name; $formData; *)
		End case 
		return 
	End if 
	
	If (This.source="object")
		Case of 
			: (Count parameters=0) && (Not($sameProcess))
				DIALOG(This.formDefinition; This.name)
			: (Count parameters=0)
				DIALOG(This.formDefinition; This.name; *)
			: (Count parameters=1) && (Not($sameProcess))
				DIALOG(This.formDefinition; This.name; $formData)
			: (Count parameters=1)
				DIALOG(This.formDefinition; This.name; $formData; *)
		End case 
		return 
	End if 
	
Function filePath : Text
	If (This._formFile=Null) || (This._formFile.exists=False)
		return ""
	End if 
	
	return This._formFile.path
	
Function getIsModified : Boolean
	return This.ready ? This._checksum#This.getCheckSum() : False
	
Function reload : cs.FormCache
	// reload the form from the definition
	This._readFile()
	return This
	
Function getObject($objName : Text) : Object
	return This._hash[$objName]
	
Function setObject($objName : Text; $obj : Object) : cs.FormCache
	// this doesn't add an object - it sets values in an existing object
	If (Not(This._hash[$objName]))
		This.error:="'"+$objName+"' is not on this form. Use addObject() instead."
		return This
	End if 
	
	This._hash[$objName]:=$obj
	
Function addObject($page : Integer; $objName : Text; $obj : Object) : cs.FormCache
	//  adds an object to the page - does not add the page
	var $pageObject : Object
	
	If (This.getObject($obj)#Null)
		This.error:="'"+$objName+"' is already on this form."
		return Null
	End if 
	
	$pageObject:=This.getPage($page)
	
	If ($pageObject=Null)
		return This
	End if 
	
	$pageObject[$objName]:=$obj  //  update the page
	This._hash[$objName]:=$obj  //  update the hash table
	This._modified:=True
	
Function getPage($page : Integer) : Object
	//  returns the page if it exists
	If ($page<0) || ($page>This.nPages)
		This.error:="This form doesn't have page # "+String($page)+"."
		return Null
	End if 
	
	return This._form.pages[$page]
	
Function getObjProperty($objName : Text; $property : Text) : Variant
	//  return the object property or 'is undefined'
	var $object : Object
	$object:=This.getObject($objName)
	If ($object=Null)
		return 
	End if 
	
	return $object[$property]
	
Function getFormEvents : Collection
	return This.ready ? This._form.events : []
	
Function setFormEvents($events : Collection) : cs.FormCache
	If (Not(This.ready))
		return This
	End if 
	
	This._form.events:=$events
	This._modified:=True
	return This
	
Function setWindowTitle($title : Text) : cs.FormCache
	If (Not(This.ready))
		return This
	End if 
	
	This._form.windowTitle:=$title
	return This
	
	//mark:  --- private
Function _readFile
	var $file : 4D.File
	var $method : Text
	
	If (Not(This._formFile.exists))
		This._form:=Null
		return 
	End if 
	
	This._form:=JSON Parse(This._formFile.getText())
	$method:=String(This._form.method)="" ? "method" : This._form.method
	
/*  formMethod can be tricky. This can be a project method 
*/
	// This._form.method:="Project/Sources/Forms/scalar_listbox/method.4dm"
	$file:=This._formFile.parent.file($method+".4dm")
	If ($file.exists)
		This._form.method:=$file.path
	Else 
		$file:=File("PROJECT/Sources/Methods/"+$method)
		
		If ($file.extension="")
			$file:=File("PROJECT/Sources/Methods/"+$method+".4dm")
		End if 
		
		This._form.method:=$file.path
	End if 
	
Function _objectsHashTable
	//  create a hash table of form objects
	var $page; $formObj : Object
	var $objName : Text
	
	This._hash:={}
	
	If (This._form=Null)
		return 
	End if 
	
	For each ($page; This._form.pages)
		
		If ($page=Null)
			continue
		End if 
		
		For each ($objName; $page.objects)
			$formObj:=$page.objects[$objName]
			
			If ($formObj.method#Null)
				$formObj.method:=This._rootPath+$formObj.method
			End if 
			
			This._hash[$objName]:=$formObj
		End for each 
	End for each 
	
Function _writeErr($text : Text)
	This.error:=$text
	
Function getCheckSum : Text
	//  used to determine modified
	return This.ready ? Generate digest(JSON Stringify(This._form); MD5 digest) : ""
	