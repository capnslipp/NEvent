#import UnityEngine


class NEvent_TestPrintOnNEvent_Test (NReactionBase):
	def OnNEvent_Test(args as object):
		args = (args,) if args.GetType() != array
		
		eventString as string = 'OnNEvent_Test('
		for arg in args:
			eventString += arg.ToString()
		eventString += ')'
		
		print eventString
