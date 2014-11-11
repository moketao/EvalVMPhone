package
{
	import flash.events.Event;
	
	public class As3LinkGoClientEvent extends Event
	{
		public static const MESSAGE_RECEIVED:String = "messageReceived";

		public var msg:String;
		public function As3LinkGoClientEvent(type:String,msg:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.msg = msg;
		}
		override public function clone():Event
		{
			return new As3LinkGoClientEvent(type, msg , bubbles, cancelable);
		}
	}
}