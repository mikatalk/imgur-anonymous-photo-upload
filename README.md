<h2>Multipart POST Helper Singleton Class</h2>
<p>Upload anonymous images to album on imgur.com</p>
 
<h3>Options:</h3>
- album
- title 
- description

<h3>Set Up:</h3>

Create an account on imgur, then a app to get a client Id.
Add it to the class (l.22):
<pre>private const CLIENT_ID:String = "";</pre>

If you want to target a specific album, create an album and grab the deletehash key.
Add it to the class (l.23):
<pre>private const CLIENT_ALBUM:String = "";</pre>

<h3>Usage:</h3>
<pre>
ImgurEndPointLoader.saveImage(
  function(response:Object):void { trace(response); }, 
  PNGEncoder.encode( new bitmapData(300, 300, false, 0xFF00FF) ),
  ImgurEndPointLoader.IMAGE_TYPE_PNG,
  "this is an awesome title",
  "and of course we can add a caption to it!"
);

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
</pre>

<h3>Enjoy!</h3>