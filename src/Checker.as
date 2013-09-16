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
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.MathUtils;
	
	/**
	 * Класс шашки. Шашка может ходить, умереть, стать дамкой, приподняться и опуститься
	 */
	public class Checker extends Object3D {
		
		
		//----------------------------------
		//  Public properties
		//----------------------------------		
				
			
		//----------------------------------
		//  Private properties
		//----------------------------------
		
		private var _team:Boolean;				// Команда шашки
		private var _isKilled:Boolean;			// Убита ли шашка?
		private var _isQueen:Boolean;			// Это королева?
		private var isRaised:Boolean;			// Указывает на приподнятость шашки
		private var _currentCell:Cell;			// Указатель на клетку на которой стоит эта шашка
		
		private var child:Object3D;
		private var z0:Number;					// Начальная Z координата шашки
		
		private var animationMove:TimelineMax = new TimelineMax();	// Класс для анимации передвижения шашки
		
		/**
		 * Конструктор
		 * @param	obj Меш самой шашки
		 * @param	team Команда шашки
		 */		
		public function Checker(obj:Object3D, team:Boolean) {
			this._team = team;
			this.child = obj;
			this.addChild(this.child);
			this.z = obj.z;			// Устанавливаем Z координату шашки, такую как у меша
			this.z0 = obj.z;
			
			this.child.x = this.child.y = this.child.z = 0;
			
			this.child.useHandCursor = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Походить на указанную клетку
		 * @param	cell Клетка на которую ходим
		 * @param	fast Если true то шашка моментально стает на свое место, иначе плавно
		 */
		public function moveTo(cell:Cell, fast:Boolean = false):void {
			
			// Перемещаем эту шашку на указанную клетку
			if (fast) {
				this.x = cell.x;
				this.y = cell.y;
			}
			else {
				animationMove.append(TweenMax.to(this, 0.5, { x:cell.x, y:cell.y } ));
				animationMove.play();
			}
						
			if (this._currentCell != null)
				this._currentCell.isOccupied = false;	// Предыдущая текущая клетка больше не занята
			this._currentCell = cell;					// Назначаем новую текущую клетку
			this._currentCell.currentChecker = this;	// Назначаем текущей клетке эту шашку как текущую
			cell.isOccupied = true;						// Указываем что клетка занята
		}		
		
		
		/**
		 * Убить эту шашку
		 * @param	x X координата куда перемещается шашка после смерти
		 * @param	y X координата куда перемещается шашка после смерти
		 * @param	z Y координата куда перемещается шашка после смерти
		 */
		public function kill(x:Number, y:Number, z:Number):void {
			this._currentCell.isOccupied = false;
			this._currentCell = null;
			this._isKilled = true;
			
			//this.x = x;
			//this.y = y;
			//this.z = z;
			animationMove.clear();		// Очищаем стек анимаций
			TweenMax.to(this, 1, { x: x / 2, y:y / 2, z:z + 40, rotationX:MathUtils.toRadians(360), delay: 0.5, onComplete: fallDown, onCompleteParams:[x, y, z] } );
		}
		
		
		/**
		 * Поднять шашку
		 */
		public function raise():void {
			//this.z += 6;
			animationMove.append(TweenMax.to(this, 0.1, { z:z0 + 6 } ));
			animationMove.play();
			this.isRaised = true;
		}	
		
		
		/**
		 * Опустить шашку
		 */
		public function lower():void {
			//this.z -= 6;
			animationMove.append(TweenMax.to(this, 0.1, { z:z0 } ));
			animationMove.play();
			this.isRaised = false;
		}	
		
		
		/**
		 * Назначить шашку дамкой
		 */
		public function setQueen():void {
			this._isQueen = true;
			this.rotationX = MathUtils.toRadians(180);		// Перевернуть шашку
		}
		
		
		public function get isQueen():Boolean {
			return _isQueen;
		}
		
		public function get team():Boolean {
			return _team;
		}
		
		public function get currentCell():Cell {
			return _currentCell;
		}
		
		public function get isKilled():Boolean {
			return _isKilled;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Падение шашки
		 */
		private function fallDown(x:Number, y:Number, z:Number):void {
			TweenMax.to(this, 0.5, {x:x, y:y, z:z, rotationX:MathUtils.toRadians(720)/*, ease: Bounce.easeIn*/ } );
		}
		


	}

}