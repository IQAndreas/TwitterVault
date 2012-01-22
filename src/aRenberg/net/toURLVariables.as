package aRenberg.net
{
	import flash.net.URLVariables;

	public function toURLVariables(data:*):URLVariables
	{
		if (data is String) { return new URLVariables(data); }
		
		//else - Will also clone existing URLVariables
		var vars:URLVariables = new URLVariables();
		for (var property:String in data)
		{
			vars[property] = data[property];
		}
		
		return vars;
	}
}
