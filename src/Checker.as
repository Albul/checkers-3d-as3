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
	import alternativa.engine3d.core.Object3D;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.MathUtils;

	public class Checker extends Object3D {

		public static const TIME_TO_MOVE:Number = 0.5;

		private var _team:Boolean;
		private var _isKilled:Boolean;
		private var _isQueen:Boolean;
		private var isRaised:Boolean;
		private var _currentCell:Cell;
		
		private var child:Object3D;
		private var z0:Number;  // Initial z coordinate of the checker

		// For animation movement of checker
		private var animationMove:TimelineMax = new TimelineMax();

		public function Checker(obj:Object3D, team:Boolean) {
			this._team = team;
			this.child = obj;
			this.addChild(this.child);
			this.z = obj.z;
			this.z0 = obj.z;
			
			this.child.x = this.child.y = this.child.z = 0;
			this.child.useHandCursor = true;
		}


		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------


		public function moveTo(cell:Cell, fast:Boolean = false):void {
			if (fast) {
				this.x = cell.x;
				this.y = cell.y;
			}
			else {
				animationMove.append(TweenMax.to(this, TIME_TO_MOVE, { x:cell.x, y:cell.y } ));
				animationMove.play();
			}
						
			if (this._currentCell != null)
				this._currentCell.isOccupied = false;
			this._currentCell = cell;
			this._currentCell.currentChecker = this;
			cell.isOccupied = true;
		}		

		/**
		 * kill the checker
		 * @param	x X coordinate of where to move checker after its death
		 * @param	y Y coordinate of where to move checker after its death
		 * @param	z Z coordinate of where to move checker after its death
		 */
		public function kill(x:Number, y:Number, z:Number):void {
			this._currentCell.isOccupied = false;
			this._currentCell = null;
			this._isKilled = true;
			
			//this.x = x;
			//this.y = y;
			//this.z = z;
			animationMove.clear();
			TweenMax.to(this, 1, { x: x / 2, y:y / 2, z:z + 40, rotationX:MathUtils.toRadians(360),
				delay: 0.5, onComplete: fallDown, onCompleteParams:[x, y, z] } );
		}

		public function raise():void {
			//this.z += 6;
			animationMove.append(TweenMax.to(this, 0.1, { z:z0 + 6 } ));
			animationMove.play();
			this.isRaised = true;
		}	

		public function lower():void {
			//this.z -= 6;
			animationMove.append(TweenMax.to(this, 0.1, { z:z0 } ));
			animationMove.play();
			this.isRaised = false;
		}	

		public function setQueen():void {
			this._isQueen = true;
			this.rotationX = MathUtils.toRadians(180);
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


		private function fallDown(x:Number, y:Number, z:Number):void {
			TweenMax.to(this, 0.5, {x:x, y:y, z:z, rotationX:MathUtils.toRadians(720)/*, ease: Bounce.easeIn*/ } );
		}

	}
}