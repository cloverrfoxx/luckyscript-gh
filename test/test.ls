// Welcome the new program to the world
string = "Hello, world!";
test = 'String but with " quotes in it';
prankd = "Ok, but for real: \" now it has quotes";
print(string);
print(test);
print(prankd);

/* 
 * Calculates the Fibonacci sequence
 * from the starting number to the
 * ending length
 */
fib(start, _end) = {
	nums = [0, start];

	//for (i = 0; i <= _end; i++) {
	while (0 <= _end) {
		next = nums[-1] + nums[-2];
		nums.push(next);
		_end--;
	};
	return nums
};

//print(fib(1, 10));
for num in fib(1, 10)
	print('<#ffa>'+num);
print("Finished!");
exit();
