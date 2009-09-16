#import UnityEngine


class NEventTestCallbackOnNEventTest (NReactionBase):
	event callbacks as callable(string, (object))
	
	def OnNEventTest(args as object):
		if args.GetType() == array:
			callbacks('OnNEventTest', args)
		else:
			callbacks('OnNEventTest', (args,))
