extern void easyLog (NSString *format, ...);



#ifdef DEBUG_TPM
#define SimpleLog(format,...) \
{ \
NSString *file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent]; \
printf("[TPM] "); \
easyLog((format),##__VA_ARGS__); \
}
#else
#define SimpleLog(format,...)
#endif

#ifdef DEBUG_TPM
#define LocationLog(format,...) \
{ \
NSString *file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent]; \
printf("[TPM] %s: Method %s  ", [file UTF8String], __PRETTY_FUNCTION__); \
easyLog((format),##__VA_ARGS__); \
}
#else
#define LocationLog(format,...)
#endif




#ifdef DEBUG_TPM
#define LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#define LOG(fmt, ...) /*NSLog(fmt, ##__VA_ARGS__)*/
#endif

