package aRenberg.TweetBackupAIR.requests 
{
	import aRenberg.net.XMLRequest;
	public class TwitterRequest 
	{
		public function TwitterRequest(url:String)
		{
			this.url = url;
		}
		
		public function request(dataCallback:Function, errorCallback:Function = null, maxAttempts:uint = 1):XMLRequest
		{
			if (!this.validate()) { return null; } //TODO: Add some sort of error message
			return new XMLRequest(this.url, this.generateVars(), dataCallback, errorCallback, maxAttempts);
		}
		
		protected var url:String;
		
		protected function validate():Boolean
		{
			//Override plz!
			return true;
		}
		
		protected function generateVars():Object
		{
			//Override plz!
			return {};
		}
		
	}
}
