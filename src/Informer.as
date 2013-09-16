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
	import managers.PageManager;
	import pages.MenuPage;
	
	/**
	 * Класс отвечает за вывод информации о количестве живых шашек каждой команды, чей сейчас ход, а также кнопка выхода в главное меню
	 */
	public class Informer extends Sprite
	{
		static public const END_GAME:String = "endGame";  // Константа для события завершения игры
		
		private var logic:Logic; // Указатель на класс логики игры
		
		private var tfWhiteValue:TextField;
		private var tfBlackValue:TextField;
		private var tfMoveValue:TextField;
		private var btnBack:SimpleButton;
		
		/**
		 * Конструктор
		 * @param	logic Класс логики игры
		 */
		public function Informer(logic:Logic) {
			
			this.logic = logic;
			logic.addEventListener(Logic.CHECKER_KILLED, onCheckerKilled); 		// Слушаем событие убийства шашки
			logic.addEventListener(Logic.WHO_MOVE_CHANGED, onWhoMoveChanged); 	// Слушаем событие смены хода команды
			 
			// Кнопка возврата в меню
			btnBack = new ButtonBack();
			btnBack.addEventListener(MouseEvent.CLICK, onBtnClick);
			this.addChild(btnBack);
			btnBack.x = 45;
			btnBack.y = 85;
			
			this.graphics.beginFill(0x795E43, 0.9);		
			this.graphics.drawRoundRect(0, 0, 200, 123, 25); 
			this.graphics.endFill();
			
			var format:TextFormat = new TextFormat("Verdana", 14, 0xffffff, true);
			
			// Текстовое поле для надписи
			var tfWhite:TextField = new TextField();
			tfWhite.x = 10;
			tfWhite.y = 10;
			tfWhite.autoSize = "left";
			tfWhite.selectable = false;
			tfWhite.setTextFormat(format);
			tfWhite.defaultTextFormat = format;
			tfWhite.text = "White:";
			this.addChild(tfWhite);
			
			// Текстовое поле для надписи
			var tfBlack:TextField = new TextField();
			tfBlack.x = 10;
			tfBlack.y = 35;
			tfBlack.autoSize = "left";
			tfBlack.selectable = false;
			tfBlack.defaultTextFormat = format;
			tfBlack.text = "Black:";
			this.addChild(tfBlack);	
			
			// Текстовое поле для надписи
			var tfMove:TextField = new TextField();
			tfMove.x = 10;
			tfMove.y = 60;
			tfMove.autoSize = "left";
			tfMove.selectable = false;
			tfMove.defaultTextFormat = format;
			tfMove.text = "Move:";
			this.addChild(tfMove);
			
			format.color = 0xff0000;
			
			// Текстовое поле для вывода количества черных шашек
			tfBlackValue = new TextField();
			tfBlackValue.autoSize = "left";
			tfBlackValue.selectable = false;
			tfBlackValue.x = tfBlack.x + tfBlack.width + 2;
			tfBlackValue.y = tfBlack.y;
			tfBlackValue.defaultTextFormat = format;
			this.addChild(tfBlackValue);
			
			// Текстовое поле для вывода количества белых шашек			
			tfWhiteValue = new TextField();
			tfWhiteValue.autoSize = "left";
			tfWhiteValue.selectable = false;
			tfWhiteValue.x = tfBlackValue.x;
			tfWhiteValue.y = tfWhite.y;
			tfWhiteValue.defaultTextFormat = format;
			this.addChild(tfWhiteValue);	
			
			format.color = 0x00cc00;
			
			// Текстовое поле отображает чей сейчас ход
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
		
		
		/**
		 * Нажали на кнопку возврата в главное меню
		 */
		private function onBtnClick(e:MouseEvent):void {
			if (this.logic.NumberWhite > 0 && this.logic.NumberBlack > 0) { // Если пытаемся покинуть игру раньше времени тогда вывести сообщение о проиграше игрока :)
				var warning:WarningText = new WarningText("Вы проиграли!!!", 0xff0000, 0.8, 3, 36, true, "Tahoma", 640, 480, 45);
				warning.x = stage.stageWidth / 2;
				warning.y = stage.stageHeight / 2;
				stage.addChild(warning);
				setTimeout(endGame, 3000);		// Запускаем ф-ю завершения игры через определенный отрезок времени
			}
			else {
				endGame();
			}
		}
		

		/**
		 * Убили шашку
		 */
		private function onCheckerKilled(e:Event):void {
			tfWhiteValue.text = String(this.logic.NumberWhite);
			tfBlackValue.text = String(this.logic.NumberBlack);
			
			// Если игрок проиграл - вывести сообщение
			if ((this.logic.NumberWhite == 0 && this.logic.teamPlayer == Logic.WHITE_TEAM) 		
				|| (this.logic.NumberBlack == 0 && this.logic.teamPlayer == Logic.BLACK_TEAM)) {				
				var warning:WarningText = new WarningText("Вы проиграли!!!", 0xff0000, 0.8, 7, 36, true, "Tahoma", 640, 480, 45);
				warning.x = stage.stageWidth / 2;
				warning.y = stage.stageHeight / 2;
				stage.addChild(warning);
			}
			
			// Если игрок выиграл - вывести сообщение
			if ((this.logic.NumberBlack == 0 && this.logic.teamPlayer == Logic.WHITE_TEAM)
				|| (this.logic.NumberWhite == 0 && this.logic.teamPlayer == Logic.BLACK_TEAM)) {
				var warning:WarningText = new WarningText("Вы победили!!!", 0x00ff00, 0.8, 7, 36, true, "Tahoma", 640, 480, 45);
				warning.x = stage.stageWidth / 2;
				warning.y = stage.stageHeight / 2;
				stage.addChild(warning);
			}
		}
		
		
		/**
		 * Произошла смена хода команд
		 */
		private function onWhoMoveChanged(e:Event):void {
			tfMoveValue.text = String(this.logic.whoMove? "Black" : "White");
		}
			
		
		
		/**
		 * Завершыть игру
		 */
		private function endGame():void {
			this.dispatchEvent(new Event(END_GAME));		// Создание события завершения игры
			parent.removeChild(this);						// Удалить контейнер со сцены
		}
		
	
	}
}