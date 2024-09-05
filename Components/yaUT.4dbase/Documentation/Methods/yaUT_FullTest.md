<!-- Type your summary here -->
## yaUT_FullTest

This method runs all yaut test methods in the database, logs the results and returns a boolean pass/fail.

```4d
If (yaUT_FullTest())
	ALERT("everything worked!")
Else 
	ALERT("Some things to check on.")
End if 
```



## yaUT Test Logs

By default test logs are created in `Logs/yaut/yaut_2024-01-01T12-35-44.txt` 

You have the option of specifying the file you want to write a log to by passing a 4D File object. 

```
$file:=Folder(fk desktop folder).file("myTest.log")

If (yaUT_FullTest($file))
	ALERT("everything worked!")
Else 
	ALERT("Some things to check on.")
End if 
```

You can also write results to a log from the Main Dialog. 

