/*
* Sogamo
* Visit http://sogamo.com/ for documentation, updates and examples.
* 
* Author Oscar Arotaype Herrera 
* email : developers@sogamo.com 
* 
* 
* Copyright (c) 2013 ZelRealm Interactive Pte Ltd.
* 
*/

package sogamo.core.connection{
	
	import sogamo.core.sogamoSystem;
	
	import flash.errors.IllegalOperationError;
	
	/**
	 * Base class to be extended by connecitons to start session, send tracks and get suggestions.
	 * 
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
	 */
	
	public class Connection {
		
		/** @private **/
		protected var _url:String = "";
		/** @private **/
		protected var _system:sogamoSystem;
		
		public function connect($apiKey:String, $player_id:String):void {
			
		}
		/** @private **/
		public function send($type:String, $data:Object, $priority:Boolean=false):void {
			throw new IllegalOperationError("Function send() no Supported on this Connector type");
		}
		/** @private **/
		public function checkStorage():void {
			throw new IllegalOperationError("Function checkStorage() no Supported on this Connector type");
		}
		/** @private **/
		public function getSuggestion($type:String, $callback:Function):void {
			throw new IllegalOperationError("Function getSuggestion() no Supported on this Connector type");
		}
		public function set url($url:String):void {
			_url = $url;
		}
	}
}