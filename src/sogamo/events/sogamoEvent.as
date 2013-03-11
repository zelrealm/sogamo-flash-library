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

package sogamo.events{
	
	import flash.events.Event;
	
	/**
	 * You can access more details about the event using the <code>data</code> object provided(as example ERROR_DATA provides two error types : SecurityError or IOError).
	 * 
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
	 */
	public class sogamoEvent extends Event {
		
  		public static const CONNECTED:String = "connected";
  		public static const ERROR_SESSION:String = "error_session";
		
  		public static const ERROR_DATA:String = "error_data";
  		public static const DATA_SENT:String = "data_sent";
		
  		public static const ERROR_DATA_STORAGE:String = "error_data_storage";
		
  		public static const SUGGESTION_EMPTY:String = "suggestion_empty";
		
  		public var data:Object;
  		
		public function sogamoEvent( $type:String, $data:Object = null ):void {
   			super($type);
   			this.data = $data;
		}
  	}	
}