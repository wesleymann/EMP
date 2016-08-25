//
//  main.m
//  testPraat
//
//  Created by Wesley Mann on 8/5/16.
//  Copyright (c) 2016 Wesley Mann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main (int argc, char *argv [ ]) {
    praat_setStandAloneScriptText (myScript);
    praat_init (U"Hello", argc, argv);
    INCLUDE_LIBRARY (praat_uvafon_init)
    praat_run ();
    return 0;
}
