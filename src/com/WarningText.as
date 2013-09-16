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
	 * 
	 * Класс позволяет создать уведомление, в виде текста в прямоугольнике
	 * 
	 */
	public class WarningText extends Sprite {
		
		private var time:Number;		// Время в секундах, сколько сообщение будет висеть на сцене (время затухания)
		
		/**
		 *  Конструктор класса уведомления
		 * 
		 * @param	text 	Текст уведомления
		 * @param	colorBg	Цвет фона уведомления
		 * @param	alphaBg Прозрачность фона
		 * @param	time 	Время затухания уведомления (0 если без затухания)
		 * @param	sizeText Размер тексата уведомления
		 * @param	isBold 	Жирность текста
		 * @param	font 	Шрифт текста
		 * @param	width0 	Ширина уведомления
		 * @param	height0 Высота уведомления
		 * @param	round 	Заокругленность углов уведомления (0 - без закругления)
		 */
		public function WarningText(text:String, colorBg:uint = 0x00FF00, alphaBg:Number = 1, time:Number = 4, sizeText:int = 32, isBold:Boolean = true, font:String = "Tahoma", width0:int = 0, height0:int = 0, round:int = 45) { // 0xFF0000
			this.time = time;
			
			// Формат текста
            var format:TextFormat = new TextFormat();
            format.font = font;
            format.color = 0x000000;
            format.size = sizeText;
			format.align = "center";
			format.bold = isBold;
			
			// Создаем текстовое поле
			var tf:TextField = new TextField();
			tf.autoSize = "left";
			tf.defaultTextFormat = format;
			tf.antiAliasType = "advanced";
			tf.selectable = false;
			tf.multiline = true;
			
			tf.htmlText = text;			// Заносим входной текст
			
			// Добавляем размытие для данного текста
			var myBlurFilter:BlurFilter = new BlurFilter(1, 1, 2);
			var myArrayFilters:Array = new Array(myBlurFilter);
			tf.filters = myArrayFilters;
			
			tf.x = - tf.textWidth / 2;
			tf.y = - tf.textHeight / 2;
			
			this.addChild(tf);
			
			graphics.beginFill(colorBg, alphaBg);
			
			if (width0 == 0 && height0 == 0) {		// Если высота и ширина не заданны, тогда рисуем прямоугольник в зависимости от объема текста
				if (round > 0)
					graphics.drawRoundRect(tf.x - 40, tf.y - 18, tf.textWidth + 80, tf.textHeight + 40, round);	// Рисуем прямоугольник с закругленными углами
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
			
						
			// Блокируем события мыши для данного спрайта
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);		// Слушаем добавление на сцену
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Events handlers
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Как только добавили на сцену данный спрайт, и если время ищезания больше нуля, 
		 * то запускаем анимацию альфа канала - через time секунд данный спрайт исчезнет, и удалится со сцены
		 */
		private function onAddToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			if (this.time > 0)
				TweenLite.to(this, time, { alpha: 0, ease: Back.easeIn, onComplete: onComplete});
		}
		
		
		/**
		 * Как только твин лайт закончил анимацию, то удалить данный спрайт со сцены
		 */
		private function onComplete():void {
			stage.removeChild(this);
		}
		
		
	}

}