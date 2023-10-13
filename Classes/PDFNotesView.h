//
//  PDFNotesView.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/8/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesView.h"

@protocol pdfnotesdelegate
-(void) updatePDFInfo:(NSDictionary*)newInfo;
@end

@interface PDFNotesView : NotesView {

}

@end
