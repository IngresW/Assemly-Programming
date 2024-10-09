#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

int main() {
	int input, sum = 0;
	scanf("%d", &input);
	for (int i = 1; i <= input; i++) {
		sum += i;
	}
	printf("Your number is %d.\n", input);
	printf("The sum is %d.\n", sum);
	return 0;
}