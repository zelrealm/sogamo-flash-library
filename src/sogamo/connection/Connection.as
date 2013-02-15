/*
* Sogamo
* Visit http://sogamo.com/ for documentation, updates and examples.
* Author Oscar Arotaype Herrera 
* email : developers@sogamo.com 
*
* 
* Copyright (c) 2013 ZelRealm Interactive Pte Ltd.
*
*/

package sogamo.connection{
	
	import sogamo.core.sogamoSystem;
	
	import flash.errors.IllegalOperationError;
	
	/**
	 * Class base to be extended by connecitons to server and data;
	 */
	
	public class Connection {
		
		protected var _url:String = "";
		protected var _system:sogamoSystem;
		
		public function connect($apiKey:String, $player_id:String):void {
			
		}
		public function send($type:String, $data:Object, $priority:Boolean=false):void {
			throw new IllegalOperationError("Function send() no Supported on this Connector type");
		}
		public function checkStorage():void {
			throw new IllegalOperationError("Function checkStorage() no Supported on this Connector type");
		}
		public function getSuggestion($type:String, $callback:Function):void {
			throw new IllegalOperationError("Function getSuggestion() no Supported on this Connector type");
		}
		public function set url($url:String):void {
			_url = $url;
		}
	}
}