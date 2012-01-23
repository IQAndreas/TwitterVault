package aRenberg.TweetBackupAIR.requests 
{
	import aRenberg.net.RequestQueue;
	import aRenberg.TweetBackupAIR.requests.TwitterRequest;

	public class UserTimeline extends TwitterRequest 
	{
		public function UserTimeline(requestQueue:RequestQueue = null) 
		{
			super("http://api.twitter.com/1/statuses/user_timeline.xml", requestQueue);
		}
			
		override protected function generateVars():Object
		{
			return {page:page, count:count, include_rts:String(includeRetweets), screen_name:username};
		}
		
		public var page:int = 1;
		public var count:int = 200;
		
		public var includeRetweets:Boolean = true;
		public var username:String = "";
	}
}
