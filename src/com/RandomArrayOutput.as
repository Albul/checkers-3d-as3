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
package com {
	
	/**
	 * Class for creating random permutation array and its output
	 */
	public class RandomArrayOutput extends Object {
		
		public var isPrinted:Boolean;				// Whether printed the whole array
		
		private var arrayIndx:Array;
		private var arrayData:Array;
		private var i:int;
		
		public function RandomArrayOutput() {
		}


		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Creating a random permutation
		 */
		public function createRandom(array:Array):void {
			this.arrayData = array;
			this.arrayIndx = createArrayIndx(array);
			this.i = 0;
			this.isPrinted = false;
			
			var k:int;
			while (k <= array.length * 2) {					// Do 2000 random permutations
				var r1:int = Math.random() * array.length;
				var r2:int = Math.random() * array.length;
				this.arrayIndx = swap(r1, r2, this.arrayIndx);
				k++;
			}
		}

		public function getRandomItem():* {
			var item:* = this.arrayData[this.arrayIndx[i]];
			if (i == arrayIndx.length - 1)
				this.isPrinted = true;
			i++;
			return item;
		}

		public function createArrayIndx(array:Array):Array {
			var arrResult:Array = new Array();
			for (var i:int = 0; i < array.length; i++) {
				arrResult.push(i);
			}
			return arrResult;
		}

		public function swap(indxItem1:int, indxItem2:int, array:Array):Array {
			var tmpItem:* = array[indxItem1];
			array[indxItem1] = array[indxItem2];
			array[indxItem2] = tmpItem;
			return array;
		}
		
	}
}