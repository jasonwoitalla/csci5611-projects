from matrix import Matrix
from random import gauss
from math import sqrt
import time

class NeuralNetwork: 

    _layers = 0
    _matrices = []
    _biases = []
    _relus = []

    _input_height = 0
    _example_input = []
    _example_output = []

    _epsilon = 0.000001


    def __init__(self, layers):
        self._layers = layers
        self._matrices = []
        self._biases = []
        self._relus = []
    

    def add_layer(self, matrix, bias, relu):
        self._matrices.append(matrix)
        self._biases.append(bias)
        self._relus.append(relu)
    

    def set_examples(self, example_input, example_output):
        self._example_input = example_input
        self._input_height = len(example_input)
        self._example_output = example_output


    # Given an input vector, return the output matrix
    def get_output(self, input):
        output = Matrix(0, 0, [])
        output.set_column_vector(input)
        for i in range(self._layers):
            output = self._matrices[i].multiply(output)
            output.add(self._biases[i])
            if self._relus[i]:
                output.relu()
        return output


    def test_network(self):
        print("Running test of the neural network")
        output = Matrix(0, 0, [])
        output.set_column_vector(self._example_input)
        print("Using this matrix as input")
        output.print_even()
        for i in range(self._layers):
            output = self._matrices[i].multiply(output)
            output.add(self._biases[i])
            if self._relus[i]:
                output.relu()

        print("Actual output: ")
        output.print_even()
        print("Expected output: " + str(self._example_output))


    def sample_gaussian(self, mean, sigma, n):
        x = []
        for i in range(n):
            x.append([gauss(mean[j], sigma[j]) for j in range(len(mean))])
        return x


    # Use the cross entropy method to minimize the neural network
    def cem_minimize(self):
        start_time = time.time()
        mean = [0 for _ in range(self._input_height)]
        sigma = [1.0 for _ in range(self._input_height)]
        sigma_mag = sqrt(len(sigma))
        t = 0
        max_iter = 150
        n = 200 # weights to sample
        ne = 15 # keep the best ne samples

        while t < max_iter and sigma_mag > self._epsilon:
            x = self.sample_gaussian(mean, sigma, n) # sample weights
            y = [self.get_output(x[i]).get_mag() for i in range(n)] # get outputs

            # sort by output
            pairs = zip(y, x)
            pairs = sorted(pairs, key=lambda y: y[0])
            # print("Results of my sort")
            # for i in range(ne):
            #     print(pairs[i])

            # get the best ne weights
            x = [pairs[i][1] for i in range(ne)]

            # update mean and sigma
            mean = [sum([x[i][j] for i in range(ne)]) / ne for j in range(len(mean))]
            sigma = [sqrt(sum([(x[i][j] - mean[j]) ** 2 for i in range(ne)]) / ne) for j in range(len(mean))]
            sigma_mag = sqrt(sum([sigma[i] ** 2 for i in range(len(sigma))]))

            t += 1
        
        print("Time to minimize: " + str(time.time() - start_time))
        return mean, sigma


    def print(self):
        print("Neural Network with " + str(self._layers) + " layers")
        for i in range(self._layers):
            print("Layer", i + 1)
            print("Matrix:")
            self._matrices[i].print_even()
            print("Bias:")
            print(self._biases[i])
            print("Relu:")
            print(self._relus[i])
            print()
