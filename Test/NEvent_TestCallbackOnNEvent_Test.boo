#import UnityEngine


class NEvent_TestCallbackOnNEvent_Test (NReactionBase):
	event callbacks as callable(string, (object))
	
	def OnNEvent_Test(args as object):
		if args.GetType() == array:
			callbacks('OnNEvent_Test', args)
		else:
			callbacks('OnNEvent_Test', (args,))
