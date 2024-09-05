<!-- Type your summary here -->
## FullTest class

This class runs all or some selected unit test methods. This is a convienent way to run a large suite of unit tests. 

```4d
var $fullTest : cs.FullTest
$fullTest:=cs.FullTest.new().getTestMethods().run().logResults()

if($fullTest.pass)
  //  all test passed
Else
  // one or more did not pass
End if
```

This example will find all the test methods beginning with `yaUT_` (the default prefix for unit test methods), run them and write the results to a file in the Logs folder. Then the code continues depending on the result. 



FullTest is also used by the Main Display Form. 
