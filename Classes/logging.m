void easyLog (NSString *format, ...) {
    if (format == nil) {
        printf("nil\n");
        return;
    }
    // reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
	
    NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
    printf("%s\n", [s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"].UTF8String);
    va_end(argList);
}
