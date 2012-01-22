package aRenberg.utils 
{
	public function padLeft(string:String, width:int, pad:String):String 
	{
		while( string.length < width )
			{ string = pad + string; }
		return string;
	}
}
