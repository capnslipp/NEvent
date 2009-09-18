import System
import UnityEngine


class NEvent_TestCase (UUnitTestCase):
	# utility vars/constructs
	
	public testGO as GameObject
	
	public testEventPlug as NEventPlug
	public testEventSocket as NEventSocket
	
	public testEventDispatch as NEventDispatch
	
	public testAbilityDock as NAbilityDock
	public testReactionDock as NReactionDock
	
	
	struct CallbackInfo:
		messageName as string
		args as (object)
		
		def ToString() as string:
			argsString = ""
			for arg in args:
				argsString += ', ' unless String.IsNullOrEmpty(argsString)
				argsString += arg.ToString()
			
			return "NEventTestOnMessageCallbacker: ${messageName}(${argsString})"
	
	public callbackQueue as (CallbackInfo) = array(CallbackInfo, 0)
	
	
	
	# utility methods
	
	def SetUp():
		testGO = GameObject()
		testGO.name = "${self.GetType()}GO"
		testGO.transform.parent = GameObject.Find('/*Test').transform
		
		testEventPlug = testGO.AddComponent(NEventPlug)
		testEventPlug.enabled = false
		testEventSocket = testGO.AddComponent(NEventSocket)
		
		testEventDispatch = testGO.AddComponent(NEventDispatch)
		
		testAbilityDock = testGO.AddComponent(NAbilityDock)
		testReactionDock = testGO.AddComponent(NReactionDock)
	
	
	def AddCallbackToQueue(messageName as string, args as (object)):
		callbackInfo = CallbackInfo(messageName: messageName, args: args)
		
		callbackQueue += (callbackInfo,)
	
	
	
	# test methods
	
	[UUnitTest]
	def TestEventNames():
		testEventAction = NEventAction(NEvent_TestEvent)
		
		UUnitAssert.EqualString('NEvent_Test', testEventAction.name, "event name should match class name minus \"…Event\"")
		UUnitAssert.EqualString('OnNEvent_Test', testEventAction.messageName, "event's message name should be the name with \"On…\" at the beginning")
	
	
	[UUnitTest]
	def TestEventSend():
		testEventAction = NEventAction(NEvent_TestEvent)
		testEventAction.Send(testGO, 101)
	
	
	[UUnitTest]
	def TestEventPortCalls():
		UUnitAssert.EqualInt(0, testEventSocket.count, "test should start with 0 events queued up")
		
		#testEventSocket.OnNEvent_Test()
		#UUnitAssert.EqualInt(0, testEventSocket.count, "this call should be IGNORED because it has no NEventAction argument")
		
		#testEventSocket.NEvent_Test()
		#UUnitAssert.EqualInt(0, testEventSocket.count, "this call should be IGNORED because it doesn't start with \"On…\"")
		
		#testEventSocket.OnNEventTestDoesntExist()
		#UUnitAssert.EqualInt(0, testEventSocket.count, "this call should ASSERT because the Note doesn't exist")
		
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 3) )
		UUnitAssert.EqualInt(1, testEventSocket.count, "this call should be RECOGNIZED because it both starts with \"On…\" and is passing in valid Note type")
		
		#testEventSocket.OnNEvent_Test()
		#UUnitAssert.EqualInt(2, testEventSocket.count, "this call should be RECOGNIZED because it both starts with \"On…\" and is passing in valid Note type")
		
		testEventSocket.Clean()
		UUnitAssert.EqualInt(0, testEventSocket.count, "cleaned; now we should have 0 events again")
	
	
	[UUnitTest]
	def TestEventPortAddRemove():
		UUnitAssert.True(testEventSocket.count == 0, "test should start with 0 events queued up")
		
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 1) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 2) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 3) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 4) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 5) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 6) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 7) )
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 8) )
		UUnitAssert.EqualInt(8, testEventSocket.count, "add 8 events, then check that we have 8 queued up")
		
		testEventSocket.ReceiveNEvent( NEvent_TestEvent(value: 8) )
		UUnitAssert.EqualInt(9, testEventSocket.count, "add 1 that has been already added; currently they do not cancel out so we should have 9")
		
		result1 = testEventSocket.Pop() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualInt(8, testEventSocket.count, "pop 1 and make sure that there's now one fewer")
		UUnitAssert.EqualDuck(typeof(NEvent_TestEvent), result1.GetType(), "make sure we got the type we added first")
		UUnitAssert.EqualString('NEvent_Test', result1.name, "make sure we got the name we added first")
		
		result2 = testEventSocket.Pop() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualInt(7, testEventSocket.count, "pop another 1 and make sure that there's now one fewer")
		UUnitAssert.EqualDuck(typeof(NEvent_TestEvent), result2.GetType(), "make sure we got the type we added second")
		UUnitAssert.EqualString('NEvent_Test', result2.name, "make sure we got the name we added second")
		
		result3 = testEventSocket.Flush() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualDuck(typeof( (NEventBase) ), result3.GetType(), "flush the rest and make sure we got the right type back")
		UUnitAssert.EqualInt(7, result3.Length, "flush the rest and make sure we got the right number of elements back")
		
		UUnitAssert.EqualInt(0, testEventSocket.count, "make sure there's none left now")
	
	
	[UUnitTest]
	def TestReaction():
		testReaction = NEvent_TestCallbackOnNEvent_Test()
		testReaction.callbacks += self.AddCallbackToQueue
		testReactionDock.AddReaction(testReaction)
		
		UUnitAssert.EqualString('NEvent_Test', testReaction.eventName, "NReaction eventName should match what's after the \"On\" in the class name")
		
		# send the message via an action
		testEventAction = NEventAction(NEvent_TestEvent)
		testEventAction.Send(testGO, 26)
		
		UUnitAssert.EqualInt(0, callbackQueue.Length, "there should be 0 callbacks in the callback queue before the Plug's SendEvents()")
		
		testEventPlug.SendEvents()
		
		# check that the message went through
		UUnitAssert.EqualInt(1, callbackQueue.Length, "there should be 1 callback in the callback queue after the event Send")
		UUnitAssert.EqualString('OnNEvent_Test', callbackQueue[0].messageName, "make sure we got back the name of the action's event's message")
		UUnitAssert.EqualInt(1, callbackQueue[0].args.Length, "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualDuck(26, callbackQueue[0].args[0], "make sure we got back the same args we sent via the action's event")
	
	
	[UUnitTest]
	def TestAbility():
		testReaction = NEvent_TestCallbackOnNEvent_Test()
		testReaction.callbacks += self.AddCallbackToQueue
		testReactionDock.AddReaction(testReaction)
		
		testAbility = NEvent_TestAbility()
		testAbility.owner = testAbilityDock.gameObject
		testAbilityDock.AddAbility(testAbility)
		
		# send the message via an ability change
		testAbility.value = -20
		testAbility.value = 20
		
		UUnitAssert.EqualInt(0, callbackQueue.Length, "there should be 0 callbacks in the callback queue before the Plug's SendEvents()")
		
		testEventPlug.SendEvents()
		
		# check that the message went through
		UUnitAssert.EqualInt(2, callbackQueue.Length, "there should be 2 callback in the callback queue after the event Send")
		UUnitAssert.EqualString('OnNEvent_Test', callbackQueue[0].messageName, "make sure we got back the name of the action's event's message")
		UUnitAssert.EqualInt(1, callbackQueue[0].args.Length, "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualDuck(-20, callbackQueue[0].args[0], "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualString('OnNEvent_Test', callbackQueue[1].messageName, "make sure we got back the name of the action's event's message")
		UUnitAssert.EqualInt(1, callbackQueue[1].args.Length, "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualDuck(20, callbackQueue[1].args[0], "make sure we got back the same args we sent via the action's event")
