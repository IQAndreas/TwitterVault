package
{
	// Singleton for architecture actors bounding
	// implemented not using the common pattern but a easier version
	// no exceptions throw on reinitialization
	public class Facade
	{
		private static var _istance:Facade;
		private static var _registeredObjects:Array;
		
		public function Facade()
		{
			if(_istance == null){
				_istance = this;
				_registeredObjects = new Array();
			}
		}
		
		
		public static function get istance():Facade{
			if(_istance == null){
				new Facade();
			}
			return _istance;	
		}
		
		/**
		 * registers a generic object o with the name s, 
		 * doesn't manage the collission of same name object
		 *
		 * @param o : object
		 * @param s : object's name
		 */
		public function registerObject(o:*,s:String):void{
			
			
			var registeredObject:Object = new Object();
			registeredObject.obj = o;
			registeredObject.registeredname = s;
			_registeredObjects.push(registeredObject);
		}
		
		/**
		 * returns the object paired with input string s
		 * doesn't manage collission (always returns the first object finded
		 * with name s)
		 * Cast needed at compiletime.
		 *
		 * @param s : input string to looks for
		 * @return the object.
		 */
		public function retriveObject(s:String):Object
		{
			var registeredObject:Object = null;
			var found:Boolean = false;
			
			for(var i:int = 0; i<_registeredObjects.length && !found;i++)
				if( _registeredObjects[i].registeredname == s)
				{
					registeredObject = _registeredObjects[i].obj;
					found = true;
				}
			
			return registeredObject;			
		}
		
		
		
	}
}