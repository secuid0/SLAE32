/* t_stime.c
   Demonstrate the use of stime() to set the system time.
   Requires superuser privileges.
*/
#include <time.h>

int main(int argc, char *argv[])
{
	time_t cTime = 0;
	int ret;

	ret = stime(&cTime); //set date/time to epoch
	return(0);
}
