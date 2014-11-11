package
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class As3LinkGoClient extends EventDispatcher
	{
		public var PORT:int;
		public var IP:String;
		public function As3LinkGoClient(ip:String="127.0.0.1",port:int=9999,onReceiveFunc:Function=null,warpSocket:Socket=null)
		{
			super();
			PORT = port;
			IP = ip;
			this.onReceiveFunc = onReceiveFunc;
			s = warpSocket ? warpSocket  : new Socket();
			
			s.addEventListener(Event.CONNECT,onConn);
			s.addEventListener(Event.CLOSE,remoteClose);
			s.addEventListener(ProgressEvent.SOCKET_DATA,socketData);
			s.addEventListener(IOErrorEvent.IO_ERROR,err);
			s.addEventListener(SecurityErrorEvent.SECURITY_ERROR,err);
			
			if(!warpSocket){
				connect(ip,port);
			}
		}
		private var _connected:Boolean;

		public function get connected():Boolean
		{
			return (s && s.connected);
		}

		public function connect(ip:String,port:int):void
		{
			PORT = port;
			IP = ip;
			if(s==null) s=new Socket();
			try{
				s.connect(ip,port);
			}catch(e:Error){
				alert(e.message);
			}
		}
		protected function alert(str:String):void
		{
			dispatchEvent(new DataEvent(SOCKET_INFO,false,false,str));
		}
		protected function err(e:IOErrorEvent):void
		{
			alert(e.toString());
		}
		
		protected function remoteClose(e:Event):void
		{
			alert(e.toString());
		}
		
		protected function onConn(e:Event):void
		{
			alert(e.toString());
		}
		protected function socketData(e:ProgressEvent):void
		{
			//loop 函数负责读取包头和包体，由于多个包有可能连着一起同时到来，所以 loop 函数可能会执行多次。
			function loop():void {
				
				//★是否包头可读取 ↓
				if (Len == 0) {
					if (s.bytesAvailable >= 4) {
						Len=s.readUnsignedInt(); //包裹总长度 Len
					} else {
						return; //如果包头还不够（有可能网络延迟等原因），则return，等待下一次  ProgressEvent.SOCKET_DATA 触发
					}
				}
				
				//★如果包头有效，接着看数据是否可读取 ↓
				if (Len > 0) {
					if (s.bytesAvailable >= Len) {
						Body.clear();
						s.readBytes(Body, 0, Len); //数据 Body
						Len=0;
						msg(Body); //★处理数据
						loop(); //★如果是多个包连着一起发来给前端（黏包），则继续  loop 函数
					} else {
						return; //如果将要读取的 body 部分的数据还不够长，则return，等待下一次  ProgressEvent.SOCKET_DATA 触发
					}
				}
			}
			
			//启动 loop 函数
			loop();
		}
		
		private function msg(Body:ByteArray):void
		{
			var str:String = Body.readUTFBytes(Body.bytesAvailable);
			if(onReceiveFunc)onReceiveFunc(str);
		}
		public function send(str:String):void{
			if(s && s.connected){
				var tmp:ByteArray = new ByteArray();
				tmp.writeUTFBytes(str);
				tmp.position = 0;
				s.writeUnsignedInt(tmp.length);//长度
				s.writeBytes(tmp);//数据
				s.flush();
			}else{
				alert("连接已关闭，不能发送信息");
			}
		}
		public function close():void{
			if(s && s.connected){
				s.close();
				s = null;
				alert("主动关闭连接");
			}
		}
		private var _message:String;
		private var s:Socket;
		public static const SOCKET_INFO:String = "SOCKET_INFO";

		private var onReceiveFunc:Function;
		private var Len:int;

		private var Body:ByteArray = new ByteArray();;
	}
}