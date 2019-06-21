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
#import "GameViewController.h"

@implementation GameView

+ (NSNotificationName)standardNotifName {
	return @"com.arc676.amazons-mac.newstandardgame";
}

+ (NSNotificationName)customNotifName {
	return @"com.arc676.amazons-mac.newcustomgame";
}

- (void)awakeFromNib {
	self.whitePlayer = [NSImage imageNamed:@"P1.png"];
	self.blackPlayer = [NSImage imageNamed:@"P2.png"];

	self.srcCol = [[NSColor greenColor] colorWithAlphaComponent:0.5f];

	self.occupied = [NSImage imageNamed:@"Occupied.png"];
	self.isSettingUp = NO;
	[self newStandardGame:nil];

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(newStandardGame:)
											   name:[GameView standardNotifName]
											 object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(newCustomGame:)
											   name:[GameView customNotifName]
											 object:nil];
}

- (void)newGame {
	self.currentPlayer = WHITE;
	self.winner = EMPTY;
	self.clickedSquare = 0;
	if (self.board.board) {
		boardstate_free(&_board);
	}
	NSSize size = NSMakeSize(2 * MARGIN + self.bw * TILE_SIZE, 2 * MARGIN + self.bh * TILE_SIZE);
	if (size.width * size.height < 460 * 460) {
		size = NSMakeSize(460, 460);
	}
	[self setFrameSize:size];
}

- (void)newStandardGame:(NSNotification*)notif {
	self.bh = 10;
	self.bw = 10;
	[self newGame];
	Square wpos[4] = {
		{3, 0}, {0, 3}, {0,6}, {3, 9}
	};
	Square bpos[4] = {
		{6, 0}, {9, 3}, {9, 6}, {6, 9}
	};
	boardstate_init(&_board, 4, 4, 10, 10, wpos, bpos);
	[self.controller setHintText:@"Bows to move"];
	[self setNeedsDisplay:YES];
}

- (void)newCustomGame:(NSNotification *)notif {
	self.bw = [notif.userInfo[@"BoardWidth"] intValue];
	self.bh = [notif.userInfo[@"BoardHeight"] intValue];
	[self newGame];
	self.isSettingUp = YES;
	self.pickedPositions = 0;
	self.wp = [notif.userInfo[@"WhitePieces"] intValue];
	self.bp = [notif.userInfo[@"BlackPieces"] intValue];
	self.initialPositions = malloc((self.wp + self.bp) * sizeof(Square));
	[self.controller setHintText:@"Select initial starting positions for first player"];
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (NSRect)getBoardSquareAtX:(int)x Y:(int)y {
	return NSMakeRect(MARGIN + x * TILE_SIZE, MARGIN + y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
}

- (void)drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	if (self.isSettingUp) {
		[self drawSetup];
	} else {
		[self drawGame];
	}
}

- (void)drawSetup {
	for (int x = 0; x < self.bw; x++) {
		for (int y = 0; y < self.bh; y++) {
			NSRect square = [self getBoardSquareAtX:x Y:y];
			if ((x + y) % 2 == 0) {
				[[NSColor grayColor] set];
				NSRectFill(square);
			}
		}
	}
	for (int i = 0; i < self.pickedPositions; i++) {
		int x = self.initialPositions[i].x;
		int y = self.initialPositions[i].y;
		if (i < self.wp) {
			[[NSColor lightGrayColor] set];
		} else {
			[[NSColor blackColor] set];
		}
		NSRectFill([self getBoardSquareAtX:x Y:y]);
	}
}

- (void)drawGame {
	for (int x = 0; x < self.board.boardWidth; x++) {
		for (int y = 0; y < self.board.boardHeight; y++) {
			NSRect square = [self getBoardSquareAtX:x Y:y];
			if ((x + y) % 2 == 0) {
				[[NSColor grayColor] set];
				NSRectFill(square);
			}
			switch (self.board.board[y * self.board.boardWidth + x]) {
				case WHITE:
					[self.whitePlayer drawInRect:square];
					break;
				case BLACK:
					[self.blackPlayer drawInRect:square];
					break;
				case ARROW:
					[self.occupied drawInRect:square];
					break;
				case EMPTY:
				default:
					break;
			}
		}
	}
	switch (self.clickedSquare) {
		case 2:
			[[NSColor redColor] set];
			NSRectFill([self getBoardSquareAtX:self.dst.x Y:self.dst.y]);
		case 1:
			[self.srcCol set];
			NSRectFillUsingOperation([self getBoardSquareAtX:self.src.x Y:self.src.y], NSCompositingOperationSourceOver);
		default:
			break;
	}
}

- (void)mouseUp:(NSEvent*)event {
	NSPoint scrollOrigin = [self.controller getScrollPosition];
	NSPoint adjustedPoint = NSMakePoint(event.locationInWindow.x + scrollOrigin.x,
										event.locationInWindow.y + scrollOrigin.y);
	int x = (adjustedPoint.x - MARGIN) / TILE_SIZE;
	int y = (adjustedPoint.y - MARGIN) / TILE_SIZE;
	if (self.isSettingUp) {
		[self pickInitialPosAtX:x Y:y];
	} else {
		[self selectSquareAtX:x Y:y];
	}
	[self setNeedsDisplay:YES];
}

- (void)pickInitialPosAtX:(int)x Y:(int)y {
	Square square = (Square) { x, y };
	for (int i = 0; i < self.pickedPositions; i++) {
		if (self.initialPositions[i].x == x && self.initialPositions[i].y == y) {
			return;
		}
	}
	self.initialPositions[self.pickedPositions++] = square;
	if (self.pickedPositions >= self.wp + self.bp) {
		boardstate_init(&_board, self.wp, self.bp, self.bw, self.bh,
						self.initialPositions, self.initialPositions + self.wp);
		free(self.initialPositions);
		self.isSettingUp = NO;
		[self.controller setHintText:@"Bows to move"];
	} else {
		if (self.pickedPositions < self.wp) {
			[self.controller setHintText:@"Select initial starting positions for first player"];
		} else {
			[self.controller setHintText:@"Select initial starting positions for second player"];
		}
	}
}

- (void)selectSquareAtX:(int)x Y:(int)y {
	switch (self.clickedSquare) {
		case 0:
			if (self.board.board[y * self.board.boardWidth + x] != self.currentPlayer) {
				return;
			}
			self.src = (Square) { x, y };
			break;
		case 1:
		{
			Square dst = (Square) { x, y };
			if (isValidMove(&_board, &_src, &dst)) {
				self.dst = dst;
			} else {
				return;
			}
			break;
		}
		case 2:
		default:
			self.shot = (Square) { x, y };
			if (amazons_move(&_board, &_src, &_dst) && amazons_shoot(&_board, &_dst, &_shot)) {
				swapPlayer(&_currentPlayer);
				if (playerHasValidMove(&_board, _currentPlayer)) {
					if (self.currentPlayer == WHITE) {
						[self.controller setHintText:@"Bows to move"];
					} else {
						[self.controller setHintText:@"Spears to move"];
					}
				} else {
					self.winner = self.currentPlayer;
					swapPlayer(&_winner);
					if (self.winner == WHITE) {
						[self.controller setHintText:@"Bows win!"];
					} else {
						[self.controller setHintText:@"Spears win!"];
					}
				}
			} else {
				amazons_move(&_board, &_dst, &_src);
				return;
			}
			break;
	}
	self.clickedSquare = (self.clickedSquare + 1) % 3;
}

- (void)keyDown:(NSEvent *)event {}

- (void)keyUp:(NSEvent *)event {
	if (event.keyCode == 53) {
		if (self.isSettingUp) {
			self.pickedPositions--;
		} else {
			self.clickedSquare = 0;
		}
		[self setNeedsDisplay:YES];
	}
}

@end
