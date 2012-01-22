package aRenberg.net 
{
	import flash.net.URLVariables;
	import aRenberg.utils.InstanceList;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	// TODO: Add "progress" and "data" properties?
	//This class could really be abstracted to allow any type of data,
	// but I'm lazy, and couldn't find a good "general" name...
	//This will do for now.
	public class XMLRequest 
	{
		protected static const instances:InstanceList = new InstanceList();
		
		public function XMLRequest(url:String, vars:Object, dataCallback:Function, errorCallback:Function = null, maxAttempts:uint = 1)
		{
			//Keep track of statically to avoid garbage collection before done loading 
			instances.add(this);
			
			this.url = url;
			this.vars = vars || {};
			
			this.dataCallback = dataCallback;
			this.errorCallback = errorCallback;
			
			this._maxAttempts = maxAttempts;
			this._failedAttempts = 0;
			this.startRequest();
		}
		
		//This was originally named "currentRequest" (more fitting)
		// but the naming for the "URLRequest" associated with this loader
		// looked REALLY odd and was more confusing. :(
		private var currentLoader:URLLoader;
		
		//Don't make public yet (because I can)
		protected var url:String;
		protected var vars:Object;
		
		protected var dataCallback:Function;
		protected var errorCallback:Function;
		
		
		private function startRequest():void
		{
			currentLoader = new URLLoader();
			
			var request:URLRequest = new URLRequest(this.url);
			request.method = URLRequestMethod.GET;
			request.data = (vars is URLVariables) ? this.vars : toURLVariables(this.vars);
			
			//With the current API, data is returned in XML format
			currentLoader.dataFormat = URLLoaderDataFormat.TEXT;
			
			//Is this overkill? Or is covering all bases good?
            currentLoader.addEventListener(Event.COMPLETE, onRequestComplete);
            //currentLoader.addEventListener(Event.OPEN, openHandler);
            //currentLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            currentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestErrorEvent);
            //currentLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            currentLoader.addEventListener(IOErrorEvent.IO_ERROR, onRequestErrorEvent);
			
			try
			{
				currentLoader.load(request);
			}
			catch (error:Error)
			{
				//TODO: Log error
				trace("Error loading request to", this.url);
				trace(" DETAILS:", error.toString());
				this.onError();
			}
        }
		
		private function resetCurrentRequest():void
		{
			currentLoader.removeEventListener(Event.COMPLETE, onRequestComplete);
            //currentLoader.removeEventListener(Event.OPEN, openHandler);
            //currentLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            currentLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestErrorEvent);
            //currentLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            currentLoader.removeEventListener(IOErrorEvent.IO_ERROR, onRequestErrorEvent);
			
			currentLoader = null;
		}
		
        private function onRequestErrorEvent(event:ErrorEvent):void
		{
			//TODO: Log error
			trace("Error loading request to", this.url);
			trace(" DETAILS:", event.toString());
			
			this.onError();
		}
		
		private function onRequestComplete(event:Event):void
		{
			var data:XML = new XML(currentLoader.data);
			
			//Call the data callback with one single parameter (of type XML)
			this.cleanUp(dataCallback, data);
		}
		
		protected function onError():void
		{
			this._failedAttempts++;
			
			if (this.retryFailedAttempts && (this.failedAttempts < this.maxAttempts))
			{
				//Retry request with the same properties
				//NOTE: The "onError" function will stack, so be careful!
				this.resetCurrentRequest();
				this.startRequest();
			}
			else
			{
				//FAILED, and giving up!
				//Call error callback with no parameters
				this.cleanUp(errorCallback);
			}
		}
		
		//Dispose of yoursef properly, even removing the "errorCallback" and "dataCallback"
		// properties, even though you haven't called them yet! This is to prevent
		// cases where users re-use this instance twice, and overwrite the callback
		// variables when calling the "currently active" callback function.
		//Am I overthinking things? Maybe...
		private function cleanUp(resultCallback:Function, ... resultCallbackParams):void
		{
			//Remove event listeners from loader and allow for garbage collection
			this.resetCurrentRequest();
			
			this.dataCallback = null;
			this.errorCallback = null;
			
			instances.remove(this);
			
			if (resultCallback) { resultCallback.apply(null, resultCallbackParams); }
		}
		
		
		
		
		protected var _failedAttempts:uint = 0;
		public function get failedAttempts():uint
		{ return _failedAttempts; }
		
		//Will automatically retry until "failedAttempts" exceeds this limit
		protected var _maxAttempts:uint = 1;
		public function get maxAttempts():uint 
			{ return this.retryFailedAttempts ? _maxAttempts : 1; }
		
		public function get retryFailedAttempts():Boolean { return Boolean(_maxAttempts > 1); }
		
	}
}
