import UnityEngine


# can't use IQuackFu and QuackInvoke() because they don't get called from GameObject#SendMessage()
class NEventTestOnMessageCallbacker (MonoBehaviour):
	event callbacks as callable(string, (object))
	
	def OnNEventTest(args as (object)):
		callbacks('OnNEventTest', args)
