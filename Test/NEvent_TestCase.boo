import System
import UnityEngine


class NEventTest (UUnitTestCase):
	# utility vars/constructs
	
	public testGO as GameObject
	
	public testEventPort as NEventPort
	
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
		
		testEventPort = testGO.AddComponent(NEventPort)
		
		testEventDispatch = testGO.AddComponent(NEventDispatch)
		
		testAbilityDock = testGO.AddComponent(NAbilityDock)
		testReactionDock = testGO.AddComponent(NReactionDock)
	
	
	def AddCallbackToQueue(messageName as string, args as (object)):
		callbackInfo = CallbackInfo(messageName: messageName, args: args)
		
		callbackQueue += (callbackInfo,)
	
	
	
	# test methods
	
	[UUnitTest]
	def TestEventNames():
		testEventAction = NEventAction(NEventTestEvent)
		
		UUnitAssert.EqualString('NEventTest', testEventAction.name, "event name should match class name minus \"…Event\"")
		UUnitAssert.EqualString('OnNEventTest', testEventAction.messageName, "event's message name should be the name with \"On…\" at the beginning")
	
	
	[UUnitTest]
	def TestEventSend():
		testEventAction = NEventAction(NEventTestEvent)
		testEventAction.Send(testGO, 101)
	
	
	[UUnitTest]
	def TestEventPortCalls():
		UUnitAssert.EqualInt(0, testEventPort.count, "test should start with 0 events queued up")
		
		#testEventPort.OnNEventTest()
		#UUnitAssert.EqualInt(0, testEventPort.count, "this call should be IGNORED because it has no NEventAction argument")
		
		#testEventPort.NEventTest()
		#UUnitAssert.EqualInt(0, testEventPort.count, "this call should be IGNORED because it doesn't start with \"On…\"")
		
		#testEventPort.OnNEventTestDoesntExist()
		#UUnitAssert.EqualInt(0, testEventPort.count, "this call should ASSERT because the Note doesn't exist")
		
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 3) )
		UUnitAssert.EqualInt(1, testEventPort.count, "this call should be RECOGNIZED because it both starts with \"On…\" and is passing in valid Note type")
		
		#testEventPort.OnNEventTest()
		#UUnitAssert.EqualInt(2, testEventPort.count, "this call should be RECOGNIZED because it both starts with \"On…\" and is passing in valid Note type")
		
		testEventPort.Clean()
		UUnitAssert.EqualInt(0, testEventPort.count, "cleaned; now we should have 0 events again")
	
	
	[UUnitTest]
	def TestEventPortAddRemove():
		UUnitAssert.True(testEventPort.count == 0, "test should start with 0 events queued up")
		
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 1) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 2) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 3) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 4) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 5) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 6) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 7) )
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 8) )
		UUnitAssert.EqualInt(8, testEventPort.count, "add 8 events, then check that we have 8 queued up")
		
		testEventPort.ReceiveNEvent( NEventTestEvent(value: 8) )
		UUnitAssert.EqualInt(9, testEventPort.count, "add 1 that has been already added; currently they do not cancel out so we should have 9")
		
		result1 = testEventPort.Pop() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualInt(8, testEventPort.count, "pop 1 and make sure that there's now one fewer")
		UUnitAssert.EqualDuck(typeof(NEventTestEvent), result1.GetType(), "make sure we got the type we added first")
		UUnitAssert.EqualString('NEventTest', result1.name, "make sure we got the name we added first")
		
		result2 = testEventPort.Pop() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualInt(7, testEventPort.count, "pop another 1 and make sure that there's now one fewer")
		UUnitAssert.EqualDuck(typeof(NEventTestEvent), result2.GetType(), "make sure we got the type we added second")
		UUnitAssert.EqualString('NEventTest', result2.name, "make sure we got the name we added second")
		
		result3 = testEventPort.Flush() # make sure not to static type (we're testing the type)
		UUnitAssert.EqualDuck(typeof( (NEventBase) ), result3.GetType(), "flush the rest and make sure we got the right type back")
		UUnitAssert.EqualInt(7, result3.Length, "flush the rest and make sure we got the right number of elements back")
		
		UUnitAssert.EqualInt(0, testEventPort.count, "make sure there's none left now")
	
	
	[UUnitTest]
	def TestReaction():
		testReaction = NEventTestCallbackOnNEventTest()
		testReaction.callbacks += self.AddCallbackToQueue
		testReactionDock.reactions += (testReaction as NReactionBase,)
		
		UUnitAssert.EqualString('NEventTest', testReaction.eventName, "NReaction eventName should match what's after the \"On\" in the class name")
		
		UUnitAssert.EqualInt(0, callbackQueue.Length, "there should be 0 callbacks in the callback queue before the event Send")
		
		# send the message via an action
		testEventAction = NEventAction(NEventTestEvent)
		testEventAction.Send(testGO, 26)
		
		# check that the message went through
		UUnitAssert.EqualInt(1, callbackQueue.Length, "there should be 1 callback in the callback queue after the event Send")
		UUnitAssert.EqualString('OnNEventTest', callbackQueue[0].messageName, "make sure we got back the name of the action's event's message")
		UUnitAssert.EqualDuck(1, callbackQueue[0].args.Length, "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualDuck(26, callbackQueue[0].args[0], "make sure we got back the same args we sent via the action's event")
	
	
	[UUnitTest]
	def TestAbility():
		testReaction = NEventTestCallbackOnNEventTest()
		testReaction.callbacks += self.AddCallbackToQueue
		testReactionDock.reactions += (testReaction as NReactionBase,)
		
		testAbility = NEventTestAbility()
		testAbility.owner = testAbilityDock.gameObject
		testAbilityDock.abilities += (testAbility as NAbilityBase,)
		
		UUnitAssert.EqualInt(0, callbackQueue.Length, "there should be 0 callbacks in the callback queue before the event Send")
		
		# send the message via an ability change
		testAbility.value = -20
		testAbility.value = 20
		
		# check that the message went through
		UUnitAssert.EqualInt(2, callbackQueue.Length, "there should be 1 callback in the callback queue after the event Send")
		UUnitAssert.EqualString('OnNEventTest', callbackQueue[0].messageName, "make sure we got back the name of the action's event's message")
		UUnitAssert.EqualDuck(1, callbackQueue[0].args.Length, "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualDuck(-20, callbackQueue[0].args[0], "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualString('OnNEventTest', callbackQueue[1].messageName, "make sure we got back the name of the action's event's message")
		UUnitAssert.EqualDuck(1, callbackQueue[1].args.Length, "make sure we got back the same args we sent via the action's event")
		UUnitAssert.EqualDuck(20, callbackQueue[1].args[0], "make sure we got back the same args we sent via the action's event")
