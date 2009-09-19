import UnityEngine


class NEvent_TestActionOnNEvent_Test (NReactionBase):
	public actionSender as GameObject
	public action as NEventAction
	
	def OnNEvent_Test(args as object):
		action.Send(actionSender)
