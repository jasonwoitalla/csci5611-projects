# Written for CSCI 5611
# Author: Jason Woitalla

import os
import sys
from neural_network import NeuralNetwork
from matrix import Matrix
import time
from threading import Thread

print("Working dir:" + os.getcwd())
thread_size = 10
threads = [None] * thread_size
inputRes = [None] * thread_size
results = [None] * thread_size

def minimize_thread(nn, index):
    input = nn.cem_minimize()[0]
    output = nn.get_output(input)
    
    inputRes[index] = input
    results[index] = output.get_mag()

if __name__ == "__main__":
    neural_networks = []
    smallest_inputs = []

    with open("networks.txt", "r") as f:
        line = f.readline()
        count = 0
        max_networks = 10
        while line != "":
            layers = int(line.split(":")[1])
            # create a neural network with the number of layers
            nn = NeuralNetwork(layers)
            for i in range(layers):
                rows = int(f.readline().split(":")[1])
                cols = int(f.readline().split(":")[1])

                weights = f.readline().split(":")[1].replace(" ", "")
                weights = weights.replace("[[", "").replace("]]", "").replace("],", "").replace("[", "|").split("|")
                for i in range(len(weights)):
                    weights[i] = weights[i].split(",")
                    for j in range(len(weights[i])):
                        weights[i][j] = float(weights[i][j])

                # converting bias with format [[1], [2], [3]] to list [1, 2, 3]
                bias = f.readline().split(":")[1].replace(" ", "")[1:-2].split(",")
                bias = [float(i[1:-1]) for i in bias]
                bias_matrix = Matrix(1, len(bias), [])
                bias_matrix.set_column_vector(bias)

                relu = f.readline().split(":")[1].strip().lower() == "true"

                # create a matrix with the weights and add the layers
                matrix = Matrix(cols, rows, weights)
                nn.add_layer(matrix, bias_matrix, relu)
            
            example_input = f.readline().split(":")[1].replace(" ", "")
            example_input = example_input.replace("[[", "").replace("]]", "").replace("],", "").replace("[", "|").split("|")
            example_input = [float(i) for i in example_input]

            example_output = f.readline().split(":")[1].replace(" ", "")
            example_output = example_output.replace("[[", "").replace("]]", "").replace("],", "").replace("[", "|").split("|")
            example_output = [float(i) for i in example_output]

            nn.set_examples(example_input, example_output)

            print("Minimizing the network: ")
            for i in range(len(threads)):
                threads[i] = Thread(target=minimize_thread, args=(nn, i))
                threads[i].start()

            for i in range(len(threads)):
                threads[i].join()

            min_val = min(results)
            min_input = results.index(min_val)
            print("Output with smallest input: ")
            my_output = nn.get_output(inputRes[min_input])
            my_output.print_even()
            smallest_inputs.append(inputRes[min_input])

            neural_networks.append(nn)
            blank_line = f.readline()
            line = f.readline()
            count = count + 1
        
    with open("solutions.txt", "w") as f: # write the output file
        for i in range(len(smallest_inputs)):
            f.write("[")
            for j in range(len(smallest_inputs[i])):
                f.write("[" + str(smallest_inputs[i][j]))
                if j < len(smallest_inputs[i]) - 1:
                    f.write("], ")
                else:
                    f.write("]")
            f.write("]\n")
