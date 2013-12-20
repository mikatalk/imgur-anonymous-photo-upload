package com.mika.meme.services.imgur
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	public class ImgurEndPointLoader extends URLLoader
	{

		public static const IMAGE_TYPE_JPEG:String = "jpeg";
		public static const IMAGE_TYPE_PNG:String = "png";
		public static const IMAGE_TYPE_GIF:String = "gif";
		
		private static var instance:ImgurEndPointLoader;
		
		private const CLIENT_URL:String = "https://api.imgur.com/3/image";
		private const CLIENT_ID:String = "";
		private const CLIENT_ALBUM:String = "";
		
		/**
		 * onComplete Response Model:
		 * see https://api.imgur.com/models/basic for more info
		 * {
		 *      "status"  : 200, 400, 401, 403, 404, 429, 500
		 *     	"success" : true/false
		 * 	    "id"      : image id
		 * 	    "link"    : link to image
		 * }
		 */ 
		private var onComplete:Function;
		
		private var request:URLRequest;
		
		public function ImgurEndPointLoader(pvt:SingletonEnforcer) { 
			super();
			addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
		}	
		
		public static function getInstance():ImgurEndPointLoader
		{
			if ( instance === null ) instance = new ImgurEndPointLoader(new SingletonEnforcer());
			return instance;
		}
		
		public static function saveImage(onComplete:Function, ba:ByteArray, imageType:String, title:String = "", description:String = ""):void
		{
			getInstance().saveImage(onComplete, ba, imageType, title, description);
		}
		
		private function saveImage(onComplete:Function, ba:ByteArray, imageType:String, title:String = "", description:String = ""):void
		{
			if ( request != null ) {
				request.data = null;
				request = null;
			}
			
			this.onComplete = onComplete;
			
			var boundary: String = getBoundary();
			
			request = new URLRequest( CLIENT_URL );

			request.requestHeaders.push(new URLRequestHeader("Authorization", "Client-ID " + CLIENT_ID ) );
			request.requestHeaders.push(new URLRequestHeader("Accept", "application/json" ) );
			
			request.data = new ByteArray();
			
			request.method = URLRequestMethod.POST;
			
			request.contentType = "multipart/form-data; boundary=" + boundary;
			
			writeString('--'+boundary + '\r\n'
			    + 'Content-Disposition: form-data; name="type"\r\n\r\n'
			    + 'file\r\n');
			
			if ( CLIENT_ALBUM != "" ) writeString('--'+boundary + '\r\n'
			    + 'Content-Disposition: form-data; name="album"\r\n\r\n'
			    + CLIENT_ALBUM + '\r\n');
			
			if ( title != "" ) writeString('--'+boundary + '\r\n'
				+ 'Content-Disposition: form-data; name="title"\r\n\r\n'
				+ title + '\r\n');
			
			if ( description != "" ) writeString('--'+boundary + '\r\n'
				+ 'Content-Disposition: form-data; name="description"\r\n\r\n'
				+ description + '\r\n');
			
			writeString('--'+boundary + '\r\n'
					+ 'Content-Disposition: form-data; name="image"; filename="MemeStudio" \r\n'
					+ 'Content-Type: image/' + imageType + '\r\n\r\n');
			
			writeBytes( ba );

			writeString('\r\n--' + boundary + '--\r\n');
			
			try {
				load(request);
			} catch ( error:Error ) {
				if ( onComplete !== null ) onComplete( { success:false, errorType: "RequestError" } );
			}
		}
		
		private function writeString(value:String):void {
			var b:ByteArray = new ByteArray();
			b.writeMultiByte(value, "ascii");
			request.data.writeBytes(b, 0, b.length);
		}
		
		private function writeBytes(value:ByteArray):void {
			value.position = 0;
			request.data.writeBytes(value, 0, value.length);
		}
		
		private function getBoundary(numChars:int = 40):String
		{
			var chars:Array = String("1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").split("");
			var boundary:String = "";
			for (var i:int = 0; i < numChars; i++) 
				boundary += chars[Math.floor(chars.length * Math.random())];
			return boundary;
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if ( onComplete !== null ) onComplete( { success:false, errorType: "IOErrorEvent" } );
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			if ( onComplete !== null ) onComplete( { success:false, errorType: "SecurityErrorEvent" } );
		}
		
		private function loaderCompleteHandler(event:Event):void
		{
			if ( onComplete !== null ) onComplete( event.target.data );
		}
		
	}
}
class SingletonEnforcer { }
