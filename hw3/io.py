import os
import sys
from neural_network import NeuralNetwork
from matrix import Matrix
import time

print("Working dir:" + os.getcwd())

if __name__ == "__main__":
    neural_networks = []
    smallest_inputs = []

    with open("hw3/networks.txt", "r") as f:
        # read the first line
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

                # create a matrix with the weights
                matrix = Matrix(cols, rows, weights)
                # add the layer to the neural network
                nn.add_layer(matrix, bias_matrix, relu)
            
            example_input = f.readline().split(":")[1].replace(" ", "")
            example_input = example_input.replace("[[", "").replace("]]", "").replace("],", "").replace("[", "|").split("|")
            example_input = [float(i) for i in example_input]

            example_output = f.readline().split(":")[1].replace(" ", "")
            example_output = example_output.replace("[[", "").replace("]]", "").replace("],", "").replace("[", "|").split("|")
            example_output = [float(i) for i in example_output]

            nn.set_examples(example_input, example_output)
            # nn.test_network()
            # print("")
            print("Minimizing the network: ")
            # minimize the network 5 times and select the one with the output smallest size
            smallest_size = sys.maxsize
            smallest_input = []
            smallest_output = []
            for i in range(5):
                input = nn.cem_minimize()[0]
                output = nn.get_output(input)
                output_size = output.get_mag()
                if output_size < smallest_size:
                    smallest_size = output_size
                    smallest_input = input
                    smallest_output = output
            print("Output with smallest input: ")
            output.print_even()
            smallest_inputs.append(smallest_input)

            neural_networks.append(nn)
            blank_line = f.readline()
            line = f.readline()
            count = count + 1
        
    with open("hw3/solutions.txt", "w") as f:
        for i in range(len(smallest_inputs)):
            f.write("[")
            for j in range(len(smallest_inputs[i])):
                f.write("[" + str(smallest_inputs[i][j]))
                if j < len(smallest_inputs[i]) - 1:
                    f.write("], ")
                else:
                    f.write("]")
            f.write("]\n")
