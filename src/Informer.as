/*
 * 
 * Copyright (c) 2012, Albul Alexandr
 
 This file is part of Checkers3D.

    Checkers3D is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see < http://www.gnu.org/licenses/>.
*/
package {
	import com.WarningText;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	/**
	 * Class is responsible for displaying information on the number of alive checkers each team,
	 * whose turn it is, and also contains a button exit to main menu
	 */
	public class Informer extends Sprite
	{
		static public const END_GAME:String = "endGame";
		
		private var logic:Logic;
		
		private var tfWhiteValue:TextField;
		private var tfBlackValue:TextField;
		private var tfMoveValue:TextField;
		private var btnBack:SimpleButton;   // The back button in the main menu

		public function Informer(logic:Logic) {
			this.logic = logic;
			logic.addEventListener(Logic.CHECKER_KILLED, onCheckerKilled);
			logic.addEventListener(Logic.WHO_MOVE_CHANGED, onWhoMoveChanged);
			 
			btnBack = new ButtonBack();
			btnBack.addEventListener(MouseEvent.CLICK, onBtnClick);
			this.addChild(btnBack);
			btnBack.x = 45;
			btnBack.y = 85;
			
			this.graphics.beginFill(0x795E43, 0.9);		
			this.graphics.drawRoundRect(0, 0, 200, 123, 25); 
			this.graphics.endFill();
			
			var format:TextFormat = new TextFormat("Verdana", 14, 0xffffff, true);
			
			var tfWhite:TextField = new TextField();
			tfWhite.x = 10;
			tfWhite.y = 10;
			tfWhite.autoSize = "left";
			tfWhite.selectable = false;
			tfWhite.setTextFormat(format);
			tfWhite.defaultTextFormat = format;
			tfWhite.text = "White:";
			this.addChild(tfWhite);
			
			var tfBlack:TextField = new TextField();
			tfBlack.x = 10;
			tfBlack.y = 35;
			tfBlack.autoSize = "left";
			tfBlack.selectable = false;
			tfBlack.defaultTextFormat = format;
			tfBlack.text = "Black:";
			this.addChild(tfBlack);	
			
			var tfMove:TextField = new TextField();
			tfMove.x = 10;
			tfMove.y = 60;
			tfMove.autoSize = "left";
			tfMove.selectable = false;
			tfMove.defaultTextFormat = format;
			tfMove.text = "Move:";
			this.addChild(tfMove);
			
			format.color = 0xff0000;
			
			tfBlackValue = new TextField();
			tfBlackValue.autoSize = "left";
			tfBlackValue.selectable = false;
			tfBlackValue.x = tfBlack.x + tfBlack.width + 2;
			tfBlackValue.y = tfBlack.y;
			tfBlackValue.defaultTextFormat = format;
			this.addChild(tfBlackValue);
			
			tfWhiteValue = new TextField();
			tfWhiteValue.autoSize = "left";
			tfWhiteValue.selectable = false;
			tfWhiteValue.x = tfBlackValue.x;
			tfWhiteValue.y = tfWhite.y;
			tfWhiteValue.defaultTextFormat = format;
			this.addChild(tfWhiteValue);	
			
			format.color = 0x00cc00;
			
			tfMoveValue = new TextField();
			tfMoveValue.autoSize = "left";
			tfMoveValue.selectable = false;
			tfMoveValue.x = tfBlackValue.x;
			tfMoveValue.y = tfMove.y;
			tfMoveValue.defaultTextFormat = format;
			this.addChild(tfMoveValue);
			
			onCheckerKilled(null);
			onWhoMoveChanged(null);
		}

		private function endGame():void {
			this.dispatchEvent(new Event(END_GAME));
			parent.removeChild(this);
		}


		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------


		private function onBtnClick(e:MouseEvent):void {
			if (this.logic.NumberWhite > 0 && this.logic.NumberBlack > 0) {
				var warning:WarningText = new WarningText("Вы проиграли!!!",
						0xff0000, 0.8, 3, 36, true, "Tahoma", 640, 480, 45);
				warning.x = stage.stageWidth / 2;
				warning.y = stage.stageHeight / 2;
				stage.addChild(warning);
				setTimeout(endGame, 3000);
			}
			else {
				endGame();
			}
		}

		private function onCheckerKilled(e:Event):void {
			tfWhiteValue.text = String(this.logic.NumberWhite);
			tfBlackValue.text = String(this.logic.NumberBlack);
			
			// The player has already lost
			if ((this.logic.NumberWhite == 0 && this.logic.teamPlayer == Logic.WHITE_TEAM) 		
				|| (this.logic.NumberBlack == 0 && this.logic.teamPlayer == Logic.BLACK_TEAM)) {				
				var warning:WarningText = new WarningText("Вы проиграли!!!",
						0xff0000, 0.8, 7, 36, true, "Tahoma", 640, 480, 45);
				warning.x = stage.stageWidth / 2;
				warning.y = stage.stageHeight / 2;
				stage.addChild(warning);
			}
			
			// The player has already won
			if ((this.logic.NumberBlack == 0 && this.logic.teamPlayer == Logic.WHITE_TEAM)
				|| (this.logic.NumberWhite == 0 && this.logic.teamPlayer == Logic.BLACK_TEAM)) {
				var warning:WarningText = new WarningText("Вы победили!!!",
						0x00ff00, 0.8, 7, 36, true, "Tahoma", 640, 480, 45);
				warning.x = stage.stageWidth / 2;
				warning.y = stage.stageHeight / 2;
				stage.addChild(warning);
			}
		}

		private function onWhoMoveChanged(e:Event):void {
			tfMoveValue.text = String(this.logic.whoMove? "Black" : "White");
		}
	
	}
}