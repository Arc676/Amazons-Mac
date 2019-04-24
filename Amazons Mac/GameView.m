//
//  GameView.m
//  Amazons Mac
//
//  Created by Alessandro Vinciguerra on 2019-04-24.
//      <alesvinciguerra@gmail.com>
//  Copyright (C) 2019 Arc676/Alessandro Vinciguerra

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation (version 3)

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//  See README and LICENSE for more details

#import "GameView.h"

@implementation GameView

- (void)awakeFromNib {
	Square wpos[4] = {
		{3, 0}, {0, 3}, {0,6}, {3, 9}
	};
	Square bpos[4] = {
		{6, 0}, {9, 3}, {9, 6}, {6, 9}
	};
	boardstate_init(&_board, 4, 4, 10, 10, wpos, bpos);
	self.clickedSquare = 0;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	for (int x = 0; x < self.board.boardWidth; x++) {
		for (int y = 0; y < self.board.boardHeight; y++) {
			if (x + y % 2 == 0) {
				[[NSColor grayColor] set];
				NSRectFill(NSMakeRect(20 + x * 20, 20 + y * 20, 20, 20));
			}
			switch (self.board.board[x * self.board.boardWidth + y]) {
				case WHITE:
				case BLACK:
				case ARROW:
				case EMPTY:
				default:
					break;
			}
		}
	}
}

- (void)mouseUp:(NSEvent*)event {
	int x = (event.locationInWindow.x - 20) / 20;
	int y = (event.locationInWindow.y - 20) / 20;
	switch (self.clickedSquare) {
		case 0:
			self.src = (Square) { x, y };
			break;
		case 1:
			self.dst = (Square) { x, y };
			break;
		case 2:
		default:
			self.shot = (Square) { x, y };
			if (amazons_move(&_board, &_src, &_dst)) {
				if (amazons_shoot(&_board, &_src, &_dst)) {
					swapPlayer(&_currentPlayer);
				} else {
					amazons_move(&_board, &_dst, &_src);
				}
			}
			break;
	}
	self.clickedSquare = (self.clickedSquare + 1) % 3;
}

@end
