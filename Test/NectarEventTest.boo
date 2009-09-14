import System
import UnityEngine


class NectarEventTest (UUnitTestCase):
	public testGO as GameObject
	
	public testEventPort as NectarEventPort
	
	public testEventDispatch as NectarEventDispatch
	public testEventOnMessageCallbacker as NectarTestOnMessageCallbacker
	
	
	def SetUp():
		testGO = GameObject()
		testGO.name = "${self.GetType()}GO"
		testGO.transform.parent = GameObject.Find('/*Test').transform
		
		testEventPort = testGO.AddComponent( NectarEventPort )
		
		testEventDispatch = testGO.AddComponent( NectarEventDispatch )
		testEventOnMessageCallbacker = testGO.AddComponent( NectarTestOnMessageCallbacker )
		testEventOnMessageCallbacker.callbacks += PrintOnMessageCallbacks
	
	
	def PrintOnMessageCallbacks(messageName as string, args as (object)):
		argsString = ""
		
		for arg in args:
			argsString += ', ' unless String.IsNullOrEmpty(argsString)
			argsString += arg.ToString()
		
		Debug.Log("NectarTestOnMessageCallbacker: ${messageName}(${argsString})")
	
	
	[UUnitTest]
	def TestEventNames():
		testCaseEvent = NectarEvent( NectarTestNote(value: 5) )
		
		UUnitAssert.EqualString('NectarTest', testCaseEvent.name, "event name should match class name minus \"…Event\"")
		UUnitAssert.EqualString('OnNectarTest', testCaseEvent.messageName, "event's message name should be the name with \"On…\" at the beginning")
	
	
	[UUnitTest]
	def TestEventSend():
		testEvent = NectarEvent( NectarTestNote(value: 1) )
		testEvent.Send(testGO)
	
	
	[UUnitTest]
	def TestEventPortCalls():
		UUnitAssert.EqualInt(0, testEventPort.count, "test should start with 0 events queued up")
		
		#testEventPort.OnNectarTest()
		#UUnitAssert.EqualInt(0, testEventPort.count, "this call should be IGNORED because it has no NectarEvent argument")
		
		#testEventPort.NectarTest()
		#UUnitAssert.EqualInt(0, testEventPort.count, "this call should be IGNORED because it doesn't start with \"On…\"")
		
		#testEventPort.OnNectarTestDoesntExist()
		#UUnitAssert.EqualInt(0, testEventPort.count, "this call should ASSERT because the Note doesn't exist")
		
		testEventPort.NectarReceive( NectarTestNote(value: 3) )
		UUnitAssert.EqualInt(1, testEventPort.count, "this call should be RECOGNIZED because it both starts with \"On…\" and is passing in valid Note type")
		
		#testEventPort.OnNectarTest()
		#UUnitAssert.EqualInt(2, testEventPort.count, "this call should be RECOGNIZED because it both starts with \"On…\" and is passing in valid Note type")
		
		testEventPort.Clean()
		UUnitAssert.EqualInt(0, testEventPort.count, "cleaned; now we should have 0 events again")
	
	
	[UUnitTest]
	def TestEventPortAddRemove():
		UUnitAssert.True(testEventPort.count == 0, "test should start with 0 events queued up")
		
		testEventPort.NectarReceive( NectarTestNote(value: 1) )
		testEventPort.NectarReceive( NectarTestNote(value: 2) )
		testEventPort.NectarReceive( NectarTestNote(value: 3) )
		testEventPort.NectarReceive( NectarTestNote(value: 4) )
		testEventPort.NectarReceive( NectarTestNote(value: 5) )
		testEventPort.NectarReceive( NectarTestNote(value: 6) )
		testEventPort.NectarReceive( NectarTestNote(value: 7) )
		testEventPort.NectarReceive( NectarTestNote(value: 8) )
		UUnitAssert.EqualInt(8, testEventPort.count, "add 8 events, then check that we have 8 queued up")
		
		testEventPort.NectarReceive( NectarTestNote(value: 8) )
		UUnitAssert.EqualInt(9, testEventPort.count, "add 1 that has been already added; currently they do not cancel out so we should have 9")
		
		result1 = testEventPort.Pop() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualInt(8, testEventPort.count, "pop 1 and make sure that there's now one fewer")
		UUnitAssert.EqualDuck(typeof(NectarTestNote), result1.GetType(), "make sure we got the type we added first")
		UUnitAssert.EqualString('NectarTest', result1.name, "make sure we got the name we added first")
		
		result2 = testEventPort.Pop() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualInt(7, testEventPort.count, "pop another 1 and make sure that there's now one fewer")
		UUnitAssert.EqualDuck(typeof(NectarTestNote), result2.GetType(), "make sure we got the type we added second")
		UUnitAssert.EqualString('NectarTest', result2.name, "make sure we got the name we added second")
		
		result3 = testEventPort.Flush() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualDuck(typeof( (NectarNoteBase) ), result3.GetType(), "flush the rest and make sure we got the right type back")
		UUnitAssert.EqualInt(7, result3.Length, "flush the rest and make sure we got the right number of elements back")
		
		UUnitAssert.EqualInt(0, testEventPort.count, "make sure there's none left now")
