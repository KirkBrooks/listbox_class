<!-- Type your summary here -->
## Yet Another Unit Test

This component gives you several levels of unit testing within your 4D app ranging from a simple class you can use to create unit tests on the fly while you work up to a full test suite that can be run in headless mode as part of a build action.

The reccommended strategy is to write unit test methods. If you prefix the method name with **yaUT_** you can run them from the yaUT Main Form as well as from the **yaUT_FullTest** method.

### Writing test methods

The included macro will configure a method to work with `TestMethod` and `FullTest`.

<img src="Screenshot 2024-01-01 at 1.13.20 PM.png" alt="Screenshot 2024-01-01 at 1.13.20 PM" style="zoom:67%;" />



Alternatively you can copy the example below as well.

```4D
#DECLARE->$testsRun : Collection  // return a collection of tests
var $test : Object

$test:=cs.yaUT.UnitTest  //  test constructor
$testsRun:=[]  //  collection of tests

//mark:  --- create unit tests
//$testsRun.push($test.new("1 is equal to 1").expect(1).toEqual(1))
//$testsRun.push($test.new("1 is not equal to 5").expect(1).not().toEqual(5))
//$testsRun.push($test.new("1 is not null").expect(1).not().toBeNull())
// insert a comment line
//$testsRun.push($test.new().insertComment("This is my comment "))
```

The key points are for your methods to work with **yaUT** they must:

- Begin with **yaUT_**
- return a collection of test classes



A nice feature of putting the tests in the collection is you can easily view them in the debugger while you’re working on the method:
<img src="Screenshot 2024-01-01 at 1.21.40 PM.png" alt="Screenshot 2024-01-01 at 1.21.40 PM" style="zoom:67%;" />

### The UnitTest class

Available as `cs.yaUT.UnitClass` this is the basis for all testing. See the documentation for the class for details.

### TestMethod Class

Available as `cs.yaUT.TestMethod` this class is primarily used by the Full Test. You might find it useful in some cases though. See the class doc for details on setting it up. The main reason to use it is to log the results of running just this method. However, everything you can do manually you can also do using the Main Form.

### yaUT_FullTest

This method runs all the test methods in your app, logs the results and returns a boolean for the overall results. See the method doc for details. You can use this to automate running your unit tests.

### yaUT_MAIN_FORM

Opens the dialog for working with all your unit tests.
