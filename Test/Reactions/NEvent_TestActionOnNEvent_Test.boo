import UnityEngine


class NEvent_TestActionOnNEvent_Test (NReactionBase):
	public action as NEventAction
	public actionSender as GameObject
	
	def OnNEvent_Test(args as object):
		action.Send(actionSender)
