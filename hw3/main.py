from matrix import Matrix 


if __name__ == "__main__":
    m1 = Matrix(3, 3)
    m1.set_row(0, [1, 2, 3])
    m1.set_row(1, [4, 5, 6])
    m1.set_row(2, [7, 8, 9])

    m2 = Matrix(1, 3)
    m2.set_column_vector(3, [2, 3, 4])

    m3 = m1.multiply(m2)
    m3.print()
