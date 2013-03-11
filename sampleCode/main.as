package {
	
	import sogamo.sogamoConnector;//Unique class needed to use Sogamo, uses around 18Kb on the final swf output//****************************SOGAMO****************************
	
	import sogamo.sogamoConfigurator;//In case you want to change the default properties form SOGAMO(like use timer or manual method to update)//****************************SOGAMO****************************
	import sogamo.events.sogamoEvent;//In case you want to detect connection and errors//****************************SOGAMO****************************
	
	import com.bit101.components.PushButton;//http://code.google.com/p/minimalcomps/
	import com.bit101.components.InputText;//http://code.google.com/p/minimalcomps/
	import com.bit101.components.Label;//http://code.google.com/p/minimalcomps/
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class main extends MovieClip {//set this class as the main for your flash doc

		/* This example uses Minimal Comps (//http://code.google.com/p/minimalcomps/) Please download the package in order to try this sample
		 * The specific sogamo's code is fallowed by //****************************SOGAMO****************************
		 */
		
		private var _sogamo:sogamoConnector;//****************************SOGAMO****************************
		private var _sogamoConfigurator:sogamoConfigurator;//****************************SOGAMO****************************
		
		private var _api_id:String = "";//API ID from Sogamo
		private var _user_id:String = "";//Set users ID
		
		private var _inputApiId_label:Label;
		private var _inputApiId:InputText;
		
		private var _inputUserId_label:Label;
		private var _inputUserId:InputText;
		
		private var _connect_label:Label;
		private var _connectButton:PushButton;
		
		private var _back:Sprite;
		
		public function main():void {
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(event:Event = null):void {
			
			_back = new Sprite();
			addChild(_back);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_sogamoConfigurator = new sogamoConfigurator();//****************************SOGAMO****************************
			//_sogamoConfigurator.UpdateType = sogamoConfigurator.MANUAL;//We set the method to be used as Manual(you will need to call the sendData method to send all tracks to Sogamo)//****************************SOGAMO****************************
			//_sogamoConfigurator.UpdateType = sogamoConfigurator.TIMER;//We set the method to be used as Timer(an internal timer is used)//****************************SOGAMO****************************
			//_sogamoConfigurator.TimerTime = 20;//seconds to be used//****************************SOGAMO****************************
			
			_sogamo = new sogamoConnector(_sogamoConfigurator);//****************************SOGAMO****************************
			_sogamo.addEventListener(sogamoEvent.CONNECTED, onSogamoConnected);// We could fire some action once we get a connection, but we start to track events righ way sicne the API has a buffer//****************************SOGAMO****************************
			_sogamo.addEventListener(sogamoEvent.ERROR_SESSION, onSogamoErrorSession);//****************************SOGAMO****************************
			
			_connectButton = new PushButton(this, 0, 0, "Connect", connect);
			_connectButton.x = (stage.stageWidth - _connectButton.width) / 2;
			_connectButton.y = (stage.stageHeight - _connectButton.height) / 2;
			
			_inputApiId_label = new Label(this, 0, 0, "API ID : ");
			_inputApiId_label.x = 35;
			_inputApiId_label.y = 40;
			
			_inputApiId = new InputText(this, 0, 0, _api_id, null);
			_inputApiId.width = 180;
			_inputApiId.x = 70;
			_inputApiId.y = 40;
			
			_inputUserId_label = new Label(this, 0, 0, "USER ID : ");
			_inputUserId_label.x = 25;
			_inputUserId_label.y = 65;
			
			_inputUserId = new InputText(this, 0, 0, _user_id, null);
			_inputUserId.width = 180;
			_inputUserId.x = 70;
			_inputUserId.y = 65;
			
		}
		private function onSogamoConnected(e:sogamoEvent):void {//****************************SOGAMO****************************
			_sogamo.removeEventListener(sogamoEvent.CONNECTED, onSogamoConnected);//****************************SOGAMO****************************
			
			var _inviteSentButton:PushButton = new PushButton(this, 0, 0, "Sent Invitation", inviteSent);
			_inviteSentButton.x = (stage.stageWidth / 2) - (_inviteSentButton.width + 10);
			_inviteSentButton.y = (stage.stageHeight / 2) - (_connectButton.height + 5);
			
			var _playerActionButton:PushButton = new PushButton(this, 0, 0, "Player Action", playerAction);
			_playerActionButton.x = (stage.stageWidth / 2) + 10;
			_playerActionButton.y = (stage.stageHeight / 2) - (_playerActionButton.height + 5);
			
			var _trackPUA:PushButton = new PushButton(this, 0, 0, "Track PUA", trackPUA);
			_trackPUA.x = (stage.stageWidth / 2) - (_trackPUA.width + 10);
			_trackPUA.y = _inviteSentButton.y - (_trackPUA.height + 5);
			
			var _userClicks:PushButton = new PushButton(this, 0, 0, "User Click", userClicks);
			_userClicks.x = (stage.stageWidth / 2) + 10;
			_userClicks.y = _playerActionButton.y - (_userClicks.height + 5);
			
			var _feedStory:PushButton = new PushButton(this, 0, 0, "Feed Story", feedStory);
			_feedStory.x = (stage.stageWidth / 2) - (_feedStory.width + 10);
			_feedStory.y = _trackPUA.y - (_feedStory.height + 5);
			
			var _itemChange:PushButton = new PushButton(this, 0, 0, "Item Change", itemChange);
			_itemChange.x = (stage.stageWidth / 2) + 10;
			_itemChange.y = _userClicks.y - (_itemChange.height + 5);
			
			
			
			var _suggestionButton:PushButton = new PushButton(this, 0, 0, "Get Suggestion", suggestionAction);
			_suggestionButton.x = (stage.stageWidth - _playerActionButton.width) / 2;
			_suggestionButton.y = (stage.stageHeight / 2) + 5;
			
			if (_sogamoConfigurator.UpdateType == sogamoConfigurator.MANUAL) {//If manual update is set, we create button to send tracks to SOGAMO
				_connect_label = new Label(this, 0, 0, "Send events manually : ");
				_connect_label.x = (stage.stageWidth / 2) - (_connect_label.width + 10);
				_connect_label.y = stage.stageHeight - (_connect_label.height + 10);
				
				var _sendDataButton:PushButton = new PushButton(this, 0, 0, "Send Data", sendData);
				_sendDataButton.x = (stage.stageWidth / 2) + 10 ;
				_sendDataButton.y = stage.stageHeight - (_sendDataButton.height + 10);
				
				_back.graphics.lineStyle(2, 0xC4C4C4);
				_back.graphics.moveTo(10, stage.stageHeight - (_sendDataButton.height + 20));
				_back.graphics.lineTo(stage.stageWidth - 10, stage.stageHeight - (_sendDataButton.height + 20));
				//trace("here")
			}
		}
		private function onSogamoErrorSession(e:sogamoEvent):void {//****************************SOGAMO****************************
			addChild(_inputApiId_label);
			addChild(_inputApiId);
			addChild(_inputUserId_label);
			addChild(_inputUserId);
			addChild(_connectButton);
		}
		private function connect(e:MouseEvent):void {
			//You can start to place events right away or even before connect to the api
			_sogamo.trackInviteSent(100, "user_final");//Sent track to Sogamo, before even start it(it is stored internally until get session login with SOGAMO's System)//****************************SOGAMO****************************
			_sogamo.API(_inputApiId.text, _inputUserId.text);//API connection//****************************SOGAMO****************************
			
			removeChild(_inputApiId_label);
			removeChild(_inputApiId);
			removeChild(_inputUserId_label);
			removeChild(_inputUserId);
			removeChild(_connectButton);
		}
		
		private function inviteSent(e:MouseEvent):void {
			_sogamo.trackInviteSent(1, "user_" + Math.random() + ", user_" + Math.random() + ", user_" + Math.random() + "");//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function playerAction(e:MouseEvent):void {
			_sogamo.trackPlayerAction("click", true, "User clicked on button " +  + Math.random());//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function trackPUA(e:MouseEvent):void {
			_sogamo.trackPUA(1, "trackPUA");//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function userClicks(e:MouseEvent):void {
			_sogamo.trackUserClicks(1, 1,"screen_" + Math.random());//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function feedStory(e:MouseEvent):void {
			_sogamo.trackFeedStory(1, "user_" + Math.random());//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function itemChange(e:MouseEvent):void {
			_sogamo.trackItemChange("action_" + Math.random() + ", action_" + Math.random());//Sent track to Sogamo//****************************SOGAMO****************************
		}
		
		private function sendData(e:MouseEvent):void {
			if (!_sogamo.sendData()) {//if session value is not ready or we are already sending data
				trace("No possible to send data")
			}
		}
		private function suggestionAction(e:MouseEvent):void {
			_sogamo.getSuggestion("buy", suggestionReceiver);//Get Suggestion from Sogamo//****************************SOGAMO****************************
		}
		public function suggestionReceiver($val:String):void {
			trace("suggestionReceiver " + $val);
		}
	}
}