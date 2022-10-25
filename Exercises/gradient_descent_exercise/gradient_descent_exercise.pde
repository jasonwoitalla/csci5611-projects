//Gradient-based optimization
//CSCI 5611 Gradient Descent [Excercise]
// Stephen J. Guy <sjguy@umn.edu>

/* 
INTRO:
 Gradient decent is the backbone of optimization techniques used across graphics, animation,
 robotics, computer vision, machine learning, and more. The exercise code starts with a
 simple gradient descent implementation. And uses it to optimize the function,
 f(x,y) = (x + 2y - 7)^2 + (2x + y - 5)^2  
 This is known as Booth's function and you can see a visualization here: 
 https://en.wikipedia.org/wiki/File:Booth%27s_function.pdf
 In the activity, we'll optimize a new function, and improve the optimizer.

TODO (Required):
1. The code in the exercise tries to find inputs (guess_x,guess_y) with minimizes the 
   function f(x,y). We do this going against the gradients grad_f_x() and grad_f_y().
   If you run the code, you see the best guess after 10 iterations is ~(1.4, 3.1) with an
   estimated optimal value of 1.3. The actual optimal value of Booth's function is 0. So
   we can improve things. 
   -Increase the maximum iterations (max_itr) until you find an input which gives a value near 0. 
   -What do you think the true optimal input is?
2. Currently f(x,y) is the the function f(x,y) = (x + 2y - 7)^2 + (2x + y - 5)^2 (Booth's function)
   There are special functions designed to test optimizers, such as the famous Rosenbrock function:
   f(x,y) = (a-x)^2 + b*(y-x^2)^2
   -Update f() in the code to evaluate this function
   -Update grad_f_x() to be this functions gradient with respect to x
   -Update grad_f_y() to be this functions gradient with respect to y
   [hint: grad_f_x is -2a + 4bx^3 - 4bxy + 2x]
   [note: the variables a and b are defined in the code as 1 and 10]
3. If you run the code as-is on this new, harder function you will not find the minimum input.
   In fact, the optimizer is unstable and may explode off to infinity after a few steps. You
   can improve the stability by making the step size, k, smaller. 
   -How small do you have to make k to get a sable optimization?
   -Try a few values of k and max_itr, what do you think the optimizing input is?
4. We can improve our optimizer by adding "momentum". This means we wont update our guess based
   on the current gradient, but rather we'll take a weighted average of the current and previous
   gradients. One simple approach is to take some of your historic gradient estimate and some of
   your new gradient. For example (pseudocode):
      cur_grad = [grad_f_x(),grad_f_y()]
      grad = beta * grad + (1-beta) * cur_grad
   - Update the code to use this momentum based strategy to smooth out the gradient.
   - With beta = 0, there is no momentum, set beta = 0.9 and see if the method still works.
5. Now that your code supports momentum, it should be much more stable (esp with large beta values).
   Go back to using a larger value for k (k=0.1), you should find the true optimum quickly.
   How does this compare to you earlier guess in step 3?
6. Instead of the gradient-based optimization approach in Steps 1-5, try gradient-free optimization:
   Try random values of guess_x and guess_y between -5 and 5. How many guesses does it take
   to find an input f(x,y) < 0.1, what about f(x,y) < 0.01 and f(x,y) < 0.001?
   How might you make the gradient-free approach better?
   (Hint: try to random search code from the lecture slides is it better than random guessing?)

Challenge:
 0. Typically the Rosenbrock function uses a=1 and b=100. The optimal value is (a,a^2) which does
    not depend on b. But a larger b makes the optimum harder to find! Try your code with b=100.
    Likely, your code doesn't do very well on these hard examples. =)
 1. Several techniques try to improve gradient-based optimizers by scaling the update of
    differently for each paramater x, y, etc at different rates. Popular examples of this
    strategy include: adagrad, rmsprop, and Adam.
    Placed in our above code a gradient scaling strategy might look like:
      guess_x = guess_x - grad_x*k/sqrt(scale_x + 0.00001);
      guess_y = guess_y - grad_y*k/sqrt(scale_y + 0.00001);
    Where a simple choice of scale_x and scale_y is setting the scale to the square of the gradient:
      scale_x = grad_x*grad_x;
      scale_y = grad_y*grad_y;
    Better is to set use momentum here also! Use a 2nd beta parameter to smooth out the estimate
    of scale_x and scale_y. 
    -Try find the optimum of the b=100 Rosenbrock function now. It should be possible.
 2. We've looked at Booth's function and the Rosenbrock function. Try a new function from this list:
    https://en.wikipedia.org/w/index.php?title=Test_functions_for_optimization
 3. An alternative to momentum is backtracking line search. Try both, which works better
    for these functions?
*/

float k = 0.1;
float max_itr = 500;
float beta = 0.9;    // Momentum parameters
float a = 1, b = 10; // Rosenbrock parameters


// f(x,y) = (a-x)^2 + b*(y-x^2)^2
float f(float x, float y) {
  return sq(a - x) + b*sq(y-sq(x));
}

// df(x,y)/dx = -2a + 4bx^3 - 4bxy + 2x
float grad_f_x(float x, float y) {
  return -2*a + 4*b*pow(x,3) - 4*b*x*y+ 2*x;
}

// df(x,y)/dy = 2b(y - x^2)
float grad_f_y(float x, float y) {
  return 2*b*(y - sq(x));
}

float magnitude(float x, float y) {
  return sqrt(x*x + y*y); 
}

void setup() {
   float guess_x = 0;
   float guess_y = 0;
   float grad_x = grad_f_x(guess_x, guess_y);
   float grad_y = grad_f_y(guess_x, guess_y);
   int count = 0;
   while (count < max_itr && magnitude(grad_x,grad_y) > 0.0001) {
      println(count);
      println("guess:",guess_x,guess_y);
      println("val:",f(guess_x,guess_y));
      println("grad:",grad_x,grad_y);
      println("k:",k);

      float cur_gradX = grad_f_x(guess_x, guess_y);
      float cur_gradY = grad_f_y(guess_x, guess_y);
      grad_x = beta * grad_x + (1-beta) * cur_gradX;
      grad_y = beta * grad_y + (1-beta) * cur_gradY;
      guess_x = guess_x - grad_x*k;
      guess_y = guess_y - grad_y*k;
      count++;
      println("---");
   }
  exit();
}
