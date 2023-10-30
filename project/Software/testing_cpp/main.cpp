#include "classes/FatSfn.h"
#include <time.h>

int main() {
	FatSfn_t* a = new FatSfn_t();
	a->flags = 3;
	printf("flags: %d\r\n", a->flags);

	time_t rawtime;
	struct tm * timeinfo;

	time ( &rawtime );
	timeinfo = localtime ( &rawtime );
	printf ( "Current local time and date: %s", asctime (timeinfo) );


	return 0;
}
