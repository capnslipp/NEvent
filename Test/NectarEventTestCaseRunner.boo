import UnityEngine


class NEventTestCaseRunner (MonoBehaviour):
	def Start():
		suite = UUnitTestSuite()
		
		suite.AddAll( NEventTest() )
		
		
		result = suite.Run(null)
		Debug.Log(result.Summary())
		
		#result = suite.RunAllowingExceptions(null)
		#Debug.Log(result.Summary())
		
		
		if result.failedCount > 0: # fail
			Camera.main.backgroundColor = Color(1.0, 0.25, 0.0) # red-ish color
		else: # pass
			Camera.main.backgroundColor = Color(0.75, 1.0, 0.0) # green-ish color
