# Written for CSCI 5611
# Author: Jason Woitalla

from math import sqrt

class Matrix:

    _matrix = []
    _width = 0
    _height = 0

    def __init__(self, width=0, height=0, matrix=None):
        self._matrix = matrix
        self._width = width
        self._height = height
    

    def set_column_vector(self, column):
        self._width = 1
        self._height = len(column)
        self._matrix = [[column[y]] for y in range(self._height)]


    def set(self, i, j, val):
        self._matrix[i][j] = val
    

    def get(self, i, j):
        return self._matrix[i][j]

    
    def set_row(self, i, row):
        for j in range(len(row)):
            self.set(i, j, row[j])


    def get_width(self):
        return self._width


    def get_height(self):
        return self._height


    def get_mag(self):
        mag = 0
        for row in self._matrix:
            for val in row:
                mag += val ** 2
        return sqrt(mag)
    

    # Used formal math definition found on this page: https://en.wikipedia.org/wiki/Matrix_multiplication
    def multiply(self, other):
        '''Given a matrix `other` multiply will multiply itself by the other matrix and return a new matrix as the result'''
        if self.get_width() != other.get_height():
            return None

        weight = [[0 for x in range(other.get_width())] for y in range(self.get_height())]
        output = Matrix(other.get_width(), self.get_height(), weight)
        for i in range(output.get_height()):
            for j in range(output.get_width()):
                my_val = 0
                for k in range(self.get_width()):
                    my_val += self.get(i, k) * other.get(k, j)
                output.set(i, j, my_val)
        
        return output
    

    def add(self, other):
        if self.get_width() != other.get_width() or self.get_height() != other.get_height():
            return

        for i in range(self.get_height()):
            for j in range(self.get_width()):
                self.set(i, j, self.get(i, j) + other.get(i, j))


    def relu(self):
        for i in range(self.get_height()):
            for j in range(self.get_width()):
                self.set(i, j, max(0, self.get(i, j)))
    

    def print(self):
        print("Row: {}, Column: {}".format(self._height, self._width))
        for row in self._matrix:
            for val in row:
                print(val, end=" ")
            print("")
    

    def print_even(self):
        print("Row: {}, Column: {}".format(self._height, self._width))
        for row in self._matrix:
            for val in row:
                print("{:6.2f}".format(val), end=" ")
            print("")
