package aRenberg.TweetBackupAIR 
{
	import flash.events.Event;
	import flash.display.Shape;
	import aRenberg.net.RequestQueue;
	import aRenberg.utils.padLeft;
	import aRenberg.TweetBackupAIR.requests.UserTimeline;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	import flash.net.FileReference;
	import flash.events.MouseEvent;
	import flash.display.Sprite;

	public class TweetBackupAIR extends Sprite
	{
		private var username:String = "iqandreas";
		
		private var tweets:Vector.<XML>;
		private var tweetsGathered:Object = {};
		
		private var progressBar:Shape;
		
		public function TweetBackupAIR()
		{
			tweets = new Vector.<XML>();
			requestQueue = new RequestQueue(60000);
			
			progressBar = new Shape();
			progressBar.graphics.beginFill(0x000000);
			progressBar.graphics.drawRect(0, stage.stageHeight - 40, stage.stageWidth, 40);
			this.addChild(progressBar);
			
			this.addEventListener(Event.ENTER_FRAME, updateProgressbar);
			stage.addEventListener(MouseEvent.CLICK, stageClicked);
			
			///   1/account/rate_limit_status.xml
			//var url:String = "https://api.twitter.com/1/statuses/show.xml?id=152843172672847872&include_entities=true";
			
			trace("Downloading tweets for", username);
			timelineRequest = new UserTimeline(requestQueue);
			timelineRequest.username = username;
			timelineRequest.page = 1;
			timelineRequest.count = 200;
			
			this.loadNextPage();
		}
		
		private function updateProgressbar(ev:Event):void
		{
			progressBar.scaleX = requestQueue.currentItemProgress;
		}
		
		private const maxAttempts:uint = 3;
		private var timelineRequest:UserTimeline;
		private var requestQueue:RequestQueue;
		
		private function loadNextPage():void
		{
			if (done) return;
			
			trace("GETTING PAGE", timelineRequest.page + ":");
			timelineRequest.request(onData, onError, maxAttempts);
			
			this.fillStage(0xFCD116);
		}
		
		private function onError():void
		{
			this.fillStage(0xDD0000);
			trace("  >>  Error downloading tweets");
			trace("Giving up after", maxAttempts, "attempts. :(");
			trace("Here are your tweets downloaded so far.");
			this.generateZIP();
		}
		
		private function onData(data:XML):void
		{
			if (done) return;
			
			this.fillStage(0x00DD00);
			
			var i:int = 0;
			var numTweets:int = 0;
			for each (var tweet:XML in data.*)
			{
				totalTweets++;
				
				//Check so we don't get duplicate tweets
				if (tweetsGathered.hasOwnProperty(tweet.id))
				{
					//var other:XML = tweetsGathered[tweet.id];
					trace("  >>  DUPLICATE TWEET", i, "> ", tweet.text);
					//trace("        >>  " + tweet.text);
					//trace("        >>  " + other.text);
					duplicateTweets++;
				}
				else
				{
					if (tweetsGathered[tweet.id]) { trace("ALREADY GATHERED", tweet.id, tweetsGathered.hasOwnProperty(tweet.id)); }
					
					tweetsGathered[tweet.id] = tweet;
					tweets.push(tweet);
					i++;
					numTweets++;
					newTweets++;
				}
			}
			
			
			if (numTweets <= 0)
			{
				trace("  >>  No new tweets found!");
				if (triedAgain)
				{
					trace("DONE DOWNLOADING ALL TWEETS");
					done = true;
					this.generateZIP();
				}
				else
				{
					trace("TRYING ONE MORE PAGE JUST IN CASE");
					triedAgain = true;
					timelineRequest.page++;
					this.loadNextPage();
				}
			}
			else
			{
				trace("  >>  Found", numTweets, "new Tweets");
				//Load the next page after the set amount of seconds
				timelineRequest.page++;
				this.loadNextPage();
			}
		}
		
		private var triedAgain:Boolean = false;
		private var done:Boolean = false;
		
		private var totalTweets:int = 0;
		private var duplicateTweets:int = 0;
		private var newTweets:int = 0;
		
		
		private var outZip:ZipOutput;
		private function generateZIP():void
		{
			if (tweets.length <= 0)
			{
				trace("No tweets retrieved. Unable to generate ZIP.");
				return;
			}
			
			trace("totalTweets", totalTweets);
			trace("duplicateTweets", duplicateTweets);
			trace("newTweets", newTweets);	
			
			outZip = new ZipOutput();
			
			for each (var tweet:XML in tweets)
			{
				var data:ByteArray = new ByteArray();
				data.writeUTFBytes(tweet.toString());
				outZip.putNextEntry(new ZipEntry(padLeft(tweet.id, 24, "0") + ".xml"));
				outZip.write(data);
				outZip.closeEntry();
			}
			
			outZip.finish();
			
			trace("DONE!");
			trace("Click stage to download the ZIP.");
			this.fillStage(0x0000DD);
		}
		
		private function stageClicked(me:MouseEvent):void
		{
			if (!done) 
			{ 
				trace("DOWNLOAD CANCELLED EARLY"); 
				done = true;
				
				this.generateZIP();
			}
			
			var fileReference:FileReference = new FileReference();
			fileReference.save(outZip.byteArray, username + "-tweets.zip");
		}
		
		private function fillStage(color:uint):void
		{
			this.graphics.beginFill(color);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
		}
	}
}
