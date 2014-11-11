package
{
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.hurlant.eval.ByteLoader;
	import com.hurlant.eval.CompiledESC;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.DataEvent;
	import flash.utils.ByteArray;
	
	public class EvalVMPhone extends Sprite
	{
		public var s:As3LinkGoClient;
		private var txt:TextArea;
		
		private var ipTxt:InputText;
		private var portTxt:InputText;

		private var vm:CompiledESC;
		public function EvalVMPhone()
		{
			G.main = this;
			super();
			
			vm = new CompiledESC(vmReady);
			function vmReady():void{
				run("var a=1;");
			}
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var scale:Number=3;
			Style.fontSize = 6*scale;
			Style.embedFonts = false;
			Style.fontName = "微软雅黑";
			var body:VBox = new VBox(this,20,20); body.spacing = 10*scale;
			ipTxt = new InputText(body);
			ipTxt.text = "127.0.0.1";//"58.68.237.13"
			ipTxt.setSize(50*scale,15*scale);
			portTxt = new InputText(body);
			portTxt.text = "9999";
			portTxt.setSize(30*scale,15*scale);
			txt = new TextArea(body); txt.text="hello";
			txt.setSize(200*scale,100*scale);
			var bt1:PushButton = new PushButton(body,0,0,"连接",onConn);
			var bt2:PushButton = new PushButton(body,0,0,"发送脚本",onSendScript);
			bt1.setSize(35*scale,15*scale);
			bt2.setSize(35*scale,15*scale);
		}
		
		private function run(str:String):void
		{
			var b:ByteArray = vm.eval(str);
			ByteLoader.loadBytes(b,function end():void{
				show("script end.\n");
			},true);
		}
		private function onConn(e:*):void
		{
			s = new As3LinkGoClient(ipTxt.text,parseInt(portTxt.text),receive);
			s.addEventListener(As3LinkGoClient.SOCKET_INFO,onInfo);
		}
		
		private function onSendScript(e:*):void
		{
			if(s==null || !s.connected){
				show("未连接,不可发消息");
				return;
			}
			var ob:Object = {};
			ob.kind = "script";
			ob.to = "pc";
			ob.from = "pc";
			ob.txt = txt.text;
			s.send(JSON.stringify(ob));
		}
		public function show(str:String):void
		{
			txt.text += str+"\n";
		}
		public function show2(...p):void
		{
			var ss:String = "";
			for (var i:int = 0; i < p.length; i++) 
			{
				var s:String = p[i].toString();
				ss+=" "+s;
			}
			show(ss);
		}
		protected function onInfo(e:DataEvent):void
		{
			show(e.data);
		}
		
		private function receive(msg:String):void{
			var ob:Object = JSON.parse(msg);
			switch(ob.kind)
			{
				case "script":
				{
					show("\n收到并运行:\n"+msg);
					try{
						run(msg);
					}catch(e:Error){
						show(e.message);
					}
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
	}
}