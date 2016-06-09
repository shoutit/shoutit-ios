#import "NSObject+DPLJSONObject.h"
#import "DPLSerializableObject.h"

SpecBegin(NSObject_DPLJSONObject)

NSURL *testURL = [NSURL URLWithString:@"http://usebutton.com"];

describe(@"JSON Compatible Object", ^{
    
    it(@"returns the same dictionary when already compatible", ^{
        NSDictionary *dict = @{ @"foo": @"bar" };
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(dict);
    });
    
    it(@"returns a compatible dictionary when incompatible", ^{
        NSDictionary *dict = @{ @"foo": testURL };
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(@{ @"foo": [testURL absoluteString] });
    });
    
    it(@"converts dictionaries recursively", ^{
        NSDictionary *dict = @{ @"foo": @{ @"bar": @{ @"baz": @{ @"url": testURL }}}};
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(@{ @"foo": @{ @"bar": @{ @"baz": @{ @"url": [testURL absoluteString] }}}});
    });
    
    it(@"converts contents of arrays in a dictionary", ^{
        NSDictionary *dict = @{ @"foo": @[testURL] };
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(@{ @"foo": @[[testURL absoluteString]] });
    });
    
    it(@"returns the same array when compatible", ^{
        NSArray *arr = @[@1, @2, @3];
        id obj = [arr DPL_JSONObject];
        expect(obj).to.equal(arr);
    });
    
    it(@"returns a compatible array when incompatible", ^{
        NSArray *arr = @[testURL];
        id obj = [arr DPL_JSONObject];
        expect(obj).to.equal(@[[testURL absoluteString]]);
    });
    
    it(@"converts arrays recursively", ^{
        NSArray *arr = @[ @[ @[ @[testURL]]]];
        id obj = [arr DPL_JSONObject];
        expect(obj).to.equal(@[ @[ @[ @[[testURL absoluteString]]]]]);
    });
    
    it(@"converts contents of dictionaries in arrays", ^{
        NSArray *arr = @[ @{ @"foo": testURL } ];
        id obj = [arr DPL_JSONObject];
        expect(obj).to.equal(@[ @{ @"foo": [testURL absoluteString] } ]);
    });
    
    it(@"converts nan and inf numbers to strings", ^{
        NSDictionary *dict = @{ @"inf": @(INFINITY), @"nan": @(NAN) };
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(@{ @"inf": @"inf", @"nan": @"nan" });
    });
    
    it(@"converts date objects to timeIntervalSinceReferenceDate", ^{
        NSDate *someDate = [NSDate date];
        id obj = [someDate DPL_JSONObject];
        expect([obj doubleValue]).to.equal([someDate timeIntervalSinceReferenceDate]);
    });
    
    it(@"removes non-string keys from dictionaries", ^{
        NSDictionary *dict = @{ testURL: @"foo", @"bar": @"baz" };
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(@{ @"bar": @"baz" });
    });
    
    it(@"serializes DPLSerializable objects to dictionaries", ^{
        NSDictionary *rep = @{ @"some_id":     @"abc",
                               @"some_string": @"derp",
                               @"some_url":    @"http://dpl.io",
                               @"some_int":    @(123)};
        
        DPLSerializableObject *object = [[DPLSerializableObject alloc] initWithDictionary:rep];
        
        NSDictionary *dict = @{ @"object": object };
        id obj = [dict DPL_JSONObject];
        expect(obj).to.equal(@{ @"object": rep });
    });
});

SpecEnd
