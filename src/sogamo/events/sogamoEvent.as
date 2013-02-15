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
package sogamo.events{
	
	import flash.events.Event;

	public class sogamoEvent extends Event {
		
  		public static const ERROR_SESSION:String = "error_session";
  		public static const CONNECTED:String = "connected";
  		
  		public var data:Object;
  		
		public function sogamoEvent( $type:String, $data:Object = null ):void {
   			super($type);
   			this.data = $data;
		}
  	}	
}