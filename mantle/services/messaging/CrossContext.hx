package mantle.services.messaging;

/**
 * ...
 * @author Pete Shand
 */
class CrossContext<Type1>
{
	private static var messengerObjects = new Map<String, CrossContextGroup<Type1>>();
	public var messenger:CrossContextGroup<Type1>;
	
	public function new(groupID:String) 
	{
		messenger = getMessengerObject(groupID);
	}
	
	private function getMessengerObject(groupID:String):CrossContextGroup<Type1>
	{
		if (messengerObjects.exists(groupID) == false) {
			var crossContextGroup = new CrossContextGroup<Type1>(groupID);
			messengerObjects.set(groupID, crossContextGroup);
		}
		return messengerObjects.get(groupID);
	}
}