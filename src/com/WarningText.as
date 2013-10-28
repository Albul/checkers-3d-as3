/*
 * 
 * Copyright (c) 2012, Albul Alexandr
 
 This file is part of engine2D.

    engine2D is free software: you can redistribute it and/or modify
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
package com {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.greensock.*;
	import com.greensock.easing.*;

	/**
	 * Class of notification
	 */
	public class WarningText extends Sprite {
		
		private var time:Number;    // The time of extinction
		
		/**
		 *  Constructor
		 * 
		 * @param	text
		 * @param	colorBg
		 * @param	alphaBg
		 * @param	time 	 The time of extinction
		 * @param	sizeText
		 * @param	isBold
		 * @param	font
		 * @param	width0 	 Width of notification
		 * @param	height0  Height of notification
		 * @param	round 	 Rounded corners of notification
		 */
		public function WarningText(text:String, colorBg:uint = 0x00FF00, alphaBg:Number = 1, time:Number = 4,
		                            sizeText:int = 32, isBold:Boolean = true, font:String = "Tahoma", width0:int = 0,
		                            height0:int = 0, round:int = 45) { // 0xFF0000
			this.time = time;

			var format:TextFormat = new TextFormat();
            format.font = font;
            format.color = 0x000000;
            format.size = sizeText;
			format.align = "center";
			format.bold = isBold;
			
			var tf:TextField = new TextField();
			tf.autoSize = "left";
			tf.defaultTextFormat = format;
			tf.antiAliasType = "advanced";
			tf.selectable = false;
			tf.multiline = true;
			
			tf.htmlText = text;
			
			var myBlurFilter:BlurFilter = new BlurFilter(1, 1, 2);
			var myArrayFilters:Array = new Array(myBlurFilter);
			tf.filters = myArrayFilters;
			
			tf.x = - tf.textWidth / 2;
			tf.y = - tf.textHeight / 2;
			
			this.addChild(tf);
			
			graphics.beginFill(colorBg, alphaBg);
			
			if (width0 == 0 && height0 == 0) {
				// Draw the rect depending on size of text
				if (round > 0)
					graphics.drawRoundRect(tf.x - 40, tf.y - 18, tf.textWidth + 80, tf.textHeight + 40, round);
				else 
					graphics.drawRect(tf.x - 40, tf.y - 18, tf.textWidth + 80, tf.textHeight + 40);	
			}
			else {
				if (round > 0)
					graphics.drawRoundRect( -width0 / 2, -height0 / 2, width0, height0, round);
				else 
					graphics.drawRect( -width0 / 2, -height0 / 2, width0, height0);
			}
				
			graphics.endFill();

			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}

		
		//--------------------------------------------------------------------------
		//
		//  Events handlers
		//
		//--------------------------------------------------------------------------


		private function onAddToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			if (this.time > 0)
				TweenLite.to(this, time, { alpha: 0, ease: Back.easeIn, onComplete: onComplete});
		}

		private function onComplete():void {
			stage.removeChild(this);
		}

	}
}