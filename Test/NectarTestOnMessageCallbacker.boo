import UnityEngine


# can't use IQuackFu and QuackInvoke() because they don't get called from GameObject#SendMessage()
class NectarTestOnMessageCallbacker (MonoBehaviour):
	event callbacks as callable(string, (object))
	
	def OnNectarTest(args as (object)):
		callbacks('OnNectarTest', args)
