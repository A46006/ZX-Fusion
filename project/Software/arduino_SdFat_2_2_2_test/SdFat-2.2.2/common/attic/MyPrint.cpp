#include "PrintBasic.h"
#include "..\..\..\terasic_lib\terasic_includes.h"
class MyPrint : public PrintBasic {
public:
	MyPrint() = default;

	size_t write(uint8_t b) {
		printf("%c", b);
		return 0;
	}

	size_t write(const uint8_t *buffer, size_t size) {
		printf("%s", buffer);
		return size;
	}
};
