package
{
	public dynamic class G
	{
		public static var class_from_js:Class;
		public static var main:EvalVMPhone;
		public function G(){}
		public static function print(...p):void {
			if(main){
				main.show2.apply(null,p);
			}else{
				trace.apply(null,p);
			}
		}
	}
}