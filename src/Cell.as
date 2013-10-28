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
	import alternativa.engine3d.objects.Mesh;

	public class Cell extends Object3D {

		public var isOccupied:Boolean;
		public var currentChecker:Checker;	// A pointer to the checker that is on this cell

		private var child:Mesh;
		private var _i:int;
		private var _j:int;

		public function Cell(obj:Mesh, name:String) {
			// Remember the index of the cell
			this._i = int(name.substr(1, 1));
			this._j = int(name.charCodeAt(0)) - 96; // Transform letter into digit

			this.child = obj;
			this.addChild(this.child);
			
			this.x = obj.x;
			this.y = obj.y;
			this.z = obj.z;
			
			this.child.x = this.child.y = this.child.z = 0;
			this.child.useHandCursor = true;
		}
		

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------


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