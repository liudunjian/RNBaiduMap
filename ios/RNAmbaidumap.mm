
#import "RNAmbaidumap.h"

@implementation RNAmbaidumap

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
    NSLog(@"Pretending to create an event %@ at %@", name, location);
}
@end
  
