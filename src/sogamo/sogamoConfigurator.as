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

package sogamo{
	
	/**
	 * Class used to change the default properties for <strong>SOGAMO's system</strong>.
	 * 
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
	 */
	
	public class sogamoConfigurator {
		
		private var _localStorageSize:uint = 5;
		private var _timerTime:uint = 20;
		
		/** @private
		 * Automatically sends the tracks, this one is the default.
		 */
		public static var AUTOMATIC:uint = 0;//"Automatic";//default
		
		/** @private
		 * Developer requieres to call <code>sendData()</code> on the connector implementation to send all tracks.
		 */
		public static var MANUAL:uint = 1;//"Manual";//in this case we return to a boolean for the operation
		
		/** @private
		 * A timer is used to send teh tracks every amount fo time.
		 */
		public static var TIMER:uint = 2;//"Timer";
		
		/** 
		 * The type of method used to send the tracks to <strong>SOGAMO's system.</strong>, the default is automatic, in some cases the data is send automatically no matter the method send(when the local storage space is gettign closer to its limit and in case of error for manual and timer update methods as it means teh data has not reached destination).
		 * 
		 * <p>If the <code>updateType</code> property is sogamoConfigurator.<code>AUTOMATIC</code>(default), the tracks are send as soon as they are called.</p>
		 * <p>If the <code>updateType</code> property is sogamoConfigurator.<code>MANUAL</code>, the developer requieres to call the method <code>sendData()</code> to send the parameters.</p>
		 * <p>If the <code>updateType</code> property is sogamoConfigurator.<code>TIMER</code>, a timer sends the tracks every amount of time(the time is set using the <code>format</code> variable on sogamoConfigurator.</p>
		 */
		public var UpdateType:uint = 0;
		
		/** 
		 * If storage locally data is allowed(we recommend to enable this feature)
		 */
		public var LocalStorageEnable:Boolean = true;
		
		/** 
		 * Seconds to be used between calls using the Timer update method, no lower than 30 secs, longer the time used, bigger the amount of data to be store locally is needed
		 */
		public function set TimerTime($var:uint):void {
			$var < 30 ? _timerTime = 30 : _timerTime = $var;
		}
		public function get TimerTime():uint {
			return _timerTime;
		}
		
		/** 
		 * The default storage local size in KB, no lower than 10KB and no bigger than 100KB, flash will request a bigger size if requiered, if this value is bigger than the current amount of data available on the user's computer a popup will be shown to the user to allow more data space.
		 */
		public function set LocalStorageSize($var:uint):void {
			$var < 10 ? _localStorageSize = 10 : _localStorageSize = $var;
			$var > 100 ? _localStorageSize = 100 : _localStorageSize = $var;
		}
		public function get LocalStorageSize():uint {
			return _localStorageSize;
		}
	}
}
