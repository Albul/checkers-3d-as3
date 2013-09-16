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
package  {
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	import flash.events.Event;
	
	/**
	 * Класс клетки. Клетка имеет  индекс, флаг занятости, и указатель на шашку которая на ней стоит
	 */
	public class Cell extends Object3D {
		
		//----------------------------------
		//  Public properties
		//----------------------------------		
				
		public var isOccupied:Boolean;		// Указывает на то, стоит ли шашка на этой клетке
		public var currentChecker:Checker;	// Указатель на текущую шашку (которая стоит на этой клетке), == null если шашка на ней не стоит
		
		//----------------------------------
		//  Private properties
		//----------------------------------
		
		private var child:Mesh;
		private var _i:int;					// Рядок в котором находится клетка
		private var _j:int;					// Столбец в котором находится клетка
		
		/**
		 * Конструктор
		 * @param	obj Меш самой клетки
		 * @param	name Bмя клетки (2a, 5h)
		 */	
		public function Cell(obj:Mesh, name:String) {

			// Запоминаем индекс клетки
			this._i = int(name.substr(1, 1));
			this._j = int(name.charCodeAt(0)) - 96;		// Превращаем букву в цифру			
			

			this.child = obj;
			this.addChild(this.child);
			
			// Координаты контейнера такие как координаты меша
			this.x = obj.x;
			this.y = obj.y;
			this.z = obj.z;
			
			this.child.x = this.child.y = this.child.z = 0;			// Координаты меша обнуляем
			this.child.useHandCursor = true;						// При наведении на клетку, курсор будет у виде руки
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Получить индекс клетки
		 */
		public function getIndex():String {
			return String(this.i) + String(this.j);
		}
		
		public function get i():int {
			return _i;
		}	
		
		public function get j():int {
			return _j;
		}
				
	}

}