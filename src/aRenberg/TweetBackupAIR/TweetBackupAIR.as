package aRenberg.TweetBackupAIR 
{
	import aRenberg.utils.padLeft;
	import aRenberg.TweetBackupAIR.requests.UserTimeline;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.net.FileReference;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;

	public class TweetBackupAIR extends Sprite
	{
		private var username:String = "iqandreas";
		
		private var tweets:Vector.<XML>;
		private var tweetsGathered:Object = {};
		
		public function TweetBackupAIR()
		{
			tweets = new Vector.<XML>();
			waitTimer = new Timer(40000, 1);
			waitTimer.addEventListener(TimerEvent.TIMER, loadNextPage);
			
			stage.addEventListener(MouseEvent.CLICK, stageClicked);
			
			///   1/account/rate_limit_status.xml
			//var url:String = "https://api.twitter.com/1/statuses/show.xml?id=152843172672847872&include_entities=true";
			
			trace("Downloading tweets for", username);
			timelineRequest = new UserTimeline();
			timelineRequest.username = username;
			timelineRequest.page = 1;
			timelineRequest.count = 200;
			
			this.loadNextPage();
		}
		
		private var timelineRequest:UserTimeline;
		private var waitTimer:Timer;

		private function loadNextPage(ev:Event = null):void
		{
			if (done) return;
			
			trace("GETTING PAGE", timelineRequest.page + ":");
			timelineRequest.request(onData, onError);
			
			this.fillStage(0xFCD116);
		}
		
		//Use their own "failedAttempts" system since the Twitter API 
		// requires you to cool down between fetch attemtps. :(
		private var failedAttempts:uint = 0;
		private function onError():void
		{
			this.fillStage(0xDD0000);
			failedAttempts++;
			
			trace("  >>  Error downloading tweets");
			
			if (failedAttempts <= 4)
			{
				trace("Trying again - attempt #" + (failedAttempts + 1));
				waitTimer.start();
			}
			else
			{
				trace("Giving up after", failedAttempts, "attempts. :(");
				trace("Here are your tweets downloaded so far.");
				this.generateZIP();
			}
		}
		
		private function onData(data:XML):void
		{
			if (done) return;
			
			failedAttempts = 0;
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
					trace("totalTweets", totalTweets);
					trace("duplicateTweets", duplicateTweets);
					trace("newTweets", newTweets);
					this.generateZIP();
				}
				else
				{
					trace("TRYING ONE MORE PAGE JUST IN CASE");
					triedAgain = true;
					timelineRequest.page++;
					waitTimer.start();
				}
			}
			else
			{
				trace("  >>  Found", numTweets, "new Tweets");
				//Load the next page after the set amount of seconds
				timelineRequest.page++;
				waitTimer.start();
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
			
			done = true;
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
				this.generateZIP();
				trace("DOWNLOAD CANCELLED EARLY"); 
				
				trace("totalTweets", totalTweets);
				trace("duplicateTweets", duplicateTweets);
				trace("newTweets", newTweets);
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
