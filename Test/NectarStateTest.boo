#import UnityEngine



class NectarStateTest (UUnitTestCase):
	testCaseEvent as NectarEvent
	
	
	def SetUp():
		testCaseEvent = NectarEvent( NectarTestNote(value: 7) )
	
	
	[UUnitTest]
	def TestStateCreation():
		aState = NectarState('BlahA')
		UUnitAssert.EqualString('BlahA', aState.name, "")
		
		bState = NectarState('BlahB', testCaseEvent, testCaseEvent)
		UUnitAssert.EqualString('BlahB', bState.name, "")
		
