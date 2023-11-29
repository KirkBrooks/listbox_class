/*  AddListBox form macro class
 Created by: Kirk as Designer, Created: 11/28/23, 15:22:24
 ------------------

*/

Function onInvoke($editor : Object) : Object
	var $name; $text; $code : Text
	var $page; $lbObj : Object
	var $form : cs.FormEditor
	var $methodFile : 4D.File
	
	$name:=Request("Enter the listbox name:")
	
	If ($name="") || (OK=0)  //  user canceled
		return 
	End if 
	
	$form:=cs.FormEditor.new($editor.editor.form; $editor.editor.file)
	
	$page:=$editor.editor.currentPage
	//  check the name is unique
	If ($form.isDupeName($name))
		ALERT("There is already an object named '"+$name+"' on this form.")
		return 
	End if 
	
	// where to put it?
	$lbObj:=$form.newListbox()
	//  add the listbox class properties
	$lbObj.currentItemSource:="Form."+$name+".currentItem"
	$lbObj.currentItemPositionSource:="Form."+$name+".position"
	$lbObj.selectedItemsSource:="Form."+$name+".selectedItems"
	$lbObj.dataSource:="Form."+$name+".data"
	
	$lbObj.columns[0].dataSource:="This.a"
	// insert it onto the page
	$page.objects[$name]:=$lbObj
	
	// now add the intialization code to the form method
	$text:="\n//mark:  --- listbox: <!--#4DTEXT $1-->\n"
	$text+="//todo: move this near the top, before any form objects that may access the data \n"
	$text+="var $<!--#4DTEXT $1--> : cs.listbox\n"
	$text+="$<!--#4DTEXT $1-->:=Form.<!--#4DTEXT $1--> ? Form.<!--#4DTEXT $1--> : cs.listbox.new(\"<!--#4DTEXT $1-->\")\n"
	$text+="\n"
	$text+="Case of \n"
	$text+=": (Form event code=On Load) && (Form.<!--#4DTEXT $1-->=Null)\n"
	$text+="Form.<!--#4DTEXT $1-->:=$<!--#4DTEXT $1-->\n"
	$text+=" $<!--#4DTEXT $1-->.setSource([{a: 1}; {a: 2}; {a: 3}; {a: 4}])\n"
	$text+=": (FORM Event.objectName#\"<!--#4DTEXT $1-->\")\n"
	$text+="\n"
	$text+=": (Form event code=On Selection Change)\n"
	$text+="\n"
	$text+=": (Form event code=On Data Change)\n"
	$text+="\n"
	$text+="End case\n"
	
	
	
	
	PROCESS 4D TAGS($text; $text; $name)
	
	// this part involves parsing the method text a little bit
	$methodFile:=$form.getMethodFile()
	If ($methodFile.exists=False)
		$methodFile.create()
	End if 
	
	$code:=$methodFile.getText()
	$code+=$text
	$methodFile.setText($code)
	
	return {currentPage: $editor.editor.currentPage}
	
Function onError($editor : Object; $resultMacro : Object; $error : Collection)
	var $obj : Object
	var $txt : Text
	$txt:=""
	
	For each ($obj; $error)
		$txt:=$txt+$obj.message+" \n"
	End for each 
	
	ALERT($txt)
	