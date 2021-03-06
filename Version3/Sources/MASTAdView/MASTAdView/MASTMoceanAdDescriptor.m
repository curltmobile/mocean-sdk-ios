//
//  MASTAdView
//
/*
 * PubMatic Inc. (“PubMatic”) CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2014 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
 * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
 * Confidentiality and Non-disclosure agreements explicitly covering such access.
 *
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
 * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
 * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
 * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */
//

#import "MASTMoceanAdDescriptor.h"


@interface MASTMoceanAdDescriptor()
@property (nonatomic, strong) NSDictionary* attributes;
@property (nonatomic, assign) id<NSXMLParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableArray* elementStack;
@property (nonatomic, strong) NSMutableDictionary* elementValues;
@property (nonatomic, strong) NSMutableString* stringBuffer;
@end

@implementation MASTMoceanAdDescriptor

@synthesize attributes, parentDelegate, elementStack, elementValues, stringBuffer;

+ (id)descriptorWithRichMediaContent:(NSString*)content
{
    MASTMoceanAdDescriptor* descriptor = [[MASTMoceanAdDescriptor alloc] initWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"richmedia", @"type", nil]];
    
    [[descriptor elementValues] setValue:content forKey:@"content"];
    
    return descriptor;
}

- (id)initWithAttributes:(NSDictionary*)a
{
    self = [super init];
    if (self)
    {
        self.attributes = a;
        self.elementStack = [NSMutableArray new];
        self.elementValues = [NSMutableDictionary new];
    }
    return self;
}

- (id)initWithParser:(NSXMLParser*)parser attributes:(NSDictionary*)a
{
    self = [self initWithAttributes:a];
    if (self)
    {
        self.parentDelegate = parser.delegate;
        parser.delegate = self;
    }
    return self;
}

- (NSString*)type
{
    return [self.attributes valueForKey:@"type"];
}

- (NSString*)url
{
    return [self.elementValues valueForKey:@"url"];
}

- (NSString*)text
{
    return [self.elementValues valueForKey:@"text"];
}

- (NSString*)img
{
    return [self.elementValues valueForKey:@"img"];
}

- (NSString*)content
{
    return [self.elementValues valueForKey:@"content"];
}

- (NSString*)track
{
    return [self.elementValues valueForKey:@"track"];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [self.elementStack addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    id key = [self.elementStack lastObject];
    if ((key != nil) && (self.stringBuffer != nil))
    {
        [self.elementValues setValue:self.stringBuffer forKey:key];
        self.stringBuffer = nil;
    }
    
    if ([@"ad" isEqualToString:elementName])
    {
        parser.delegate = self.parentDelegate;
        
        if ([parser.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)])
            [parser.delegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
        
        self.parentDelegate = nil;
        self.elementStack = nil;
    }
    
    [self.elementStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    id key = [self.elementStack lastObject];
    if (key == nil)
        return;
    
    if (self.stringBuffer == nil)
        self.stringBuffer = [[NSMutableString alloc] initWithCapacity:1024];
    
    [self.stringBuffer appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    id key = [self.elementStack lastObject];
    if (key == nil)
        return;
    
    NSString* string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    
    [self.elementValues setValue:string forKey:key];
}

#pragma mark -

- (NSString*)description
{
    return [NSString stringWithFormat:@"type:%@, url:%@", [self type], [self url]];
}

@end
