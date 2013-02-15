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
package sogamo.connection {
	
	//import com.adobe.serialization.json.JSON; // NOTE : below Flash Player 11.0 or AIR 3.0
	
	import sogamo.core.sogamoSystem;
	
	import flash.net.URLRequestMethod;
	
	import flash.events.Event;
	
	/**
	 * Class used to get suggestions from sogamo.
	 * NOTE : In case u use a compiler for versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib
	 */
	
	public class ConnectionSuggestion extends ConnectionData {
		
		/**
         * ConnectionSuggestion
         * Connects to sogamo server to get suggestions
         * @param    $system                   reference to the main sogamo class
		 * @return none
         */
		public function ConnectionSuggestion($system:sogamoSystem):void {
			super($system);
			_requestServer.method = URLRequestMethod.GET;
		}
		
		/**
		 * getSuggestion returns an object from server based on type
         * @param    $type                     Suggestion Type
         * @param    $suggestionCallback       Function to call once we get a response from server
		 * @return   none
         */	
		public override function getSuggestion($type:String, $callback:Function):void {
			var params:Object = new Object();
			
			params["apiKey"] = _system.apiKey;
			params["playerId"] = _system.playerID;//Filled automatically
			params["suggestionType"] = $type;
			params["callback_function"] = $callback;
			
			super.send("", params);
		}
		
		/**
         * onDataCompleted
         * Data send to server
		 * @return none
         */
		protected override function onDataCompleted(e:Event):void {
			var serverData:Object = JSON.parse(e.currentTarget.data);
			
			var localData:Object = _dataStorage.peek();
			localData.data["callback_function"].apply(null, String(serverData.suggestion).split(","));
			_dataStorage.dequeue();//remove the value sent
			_available = true;
			checkStorage();
		}
	}
}