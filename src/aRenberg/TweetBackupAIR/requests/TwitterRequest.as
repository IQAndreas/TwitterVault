package aRenberg.TweetBackupAIR.requests 
{
	import aRenberg.net.RequestQueue;
	import aRenberg.net.Request;
	public class TwitterRequest 
	{
		public function TwitterRequest(url:String, requestQueue:RequestQueue = null)
		{
			this.requestQueue = requestQueue;
			this.url = url;
		}
		
		public function request(dataCallback:Function, errorCallback:Function = null, maxAttempts:uint = 1):Request
		{
			if (!this.validate()) { return null; } //TODO: Add some sort of error message
			
			if (requestQueue)
			{
				return requestQueue.getXML(this.url, this.generateVars(), dataCallback, errorCallback, maxAttempts);
			}
			
			//else
			return Request.getXML(this.url, this.generateVars(), dataCallback, errorCallback, maxAttempts);
		}
		
		protected var requestQueue:RequestQueue;
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
