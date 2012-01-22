package aRenberg.utils 
{
	//This class helps keep references to instances, to prevent garbage collection issues.
	//MUCH cleaner and clearer than constantly using "splice" and arrays
	public final class InstanceList 
	{
		public function InstanceList():void
		{
			instances = new Vector.<Object>();
		}
		
		private var instances:Vector.<Object>;
		
		public function add(object:Object):void
		{
			//Avoid 'null' etc?
			//(list is not made for natives for very good reason!)
			if (!object) return;
			
			//Avoid duplicates
			if (instances.indexOf(object) != -1) { return; }
			
			instances.push(object);
		}
		
		public function remove(object:Object):void
		{
			//If the 'instance' vector is DEFINITELY kept private,
			// and the only function to add items to it is 'add',
			// there is no need to check for duplicates and remove them all.
			// There should only be one instance.
			
			var index:int = instances.indexOf(object);
			if (index >= 0) { instances.splice(index, 1); }
		}
		
		//Add a "numInstances" property? Seems uneccessary and just sloppy
	}
}
