//
//  GameView.h
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

#define MARGIN 30
#define TILE_SIZE 40

#import <Cocoa/Cocoa.h>

@class GameViewController;

#include "libamazons.h"

@interface GameView : NSView

@property (retain) GameViewController* controller;
@property (retain) NSImage *whitePlayer, *blackPlayer, *occupied;

@property (assign) BOOL isSettingUp;
@property (assign) int wp, bp, bw, bh;
@property (assign) int pickedPositions;
@property (assign) Square* initialPositions;

@property (assign) BoardState board;
@property (assign) SquareState currentPlayer;
@property (assign) Square src, dst, shot;
@property (assign) int clickedSquare;

- (void)newStandardGame:(NSNotification*)notif;
- (void)newCustomGame:(NSNotification*)notif;

- (void)drawSetup;
- (void)drawGame;

- (void)pickInitialPosAtX:(int)x Y:(int)y;
- (void)selectSquareAtX:(int)x Y:(int)y;

+ (NSNotificationName)standardNotifName;
+ (NSNotificationName)customNotifName;

@end
