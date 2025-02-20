import sys
import numpy as np

def main():
    # Read inputs with validation
    while True:
        try:
            field_width = int(input("Enter field width: "))
            field_height = int(input("Enter field height: "))
            if field_width <= 0 or field_height <= 0:
                raise ValueError("Field dimensions must be positive integers.")
            break
        except ValueError as e:
            print(f"Invalid input: {e}. Please enter positive integers for field dimensions.")

    output_filename = input("Enter output filename: ")

    # Read the figure (2D array of 0s and 1s) with validation
    print("Enter the figure (2D array of 0s and 1s) row by row, end with an empty line:")
    figure = []
    while True:
        line = input().strip()
        if line == "":
            break
        # Validate the input line
        row = line.split()
        if not all(x in ['0', '1'] for x in row):
            print("Invalid input: Each row must consist only of 0s and 1s.")
            continue
        figure.append([int(x) for x in row])

    # Check if the figure is empty
    if not figure:
        print("No figure was entered. Exiting.")
        return

    # Check if the figure is rectangular
    fig_height = len(figure)
    fig_width = len(figure[0])
    for row in figure:
        if len(row) != fig_width:
            print("Invalid input: The figure must be a rectangular array.")
            return

    # Check if the figure fits within the field dimensions
    if fig_width > field_width or fig_height > field_height:
        print("Invalid input: The figure must fit within the specified field dimensions.")
        return

    # Convert figure to numpy array for easier manipulation
    figure_array = np.array(figure)

    # Create a new array of zeros with the specified field dimensions
    output_array = np.zeros((field_height, field_width), dtype=int)

    # Calculate the position to place the figure in the center
    start_row = (field_height - fig_height) // 2
    start_col = (field_width - fig_width) // 2

    # Place the figure in the center of the output array
    output_array[start_row:start_row + fig_height, start_col:start_col + fig_width] = figure_array

    # Write the output array to the specified file with custom formatting
    with open(output_filename, 'w') as f:
        for row in output_array:
            formatted_row = ' '.join(['00' if x == 0 else '01' for x in row])
            f.write(formatted_row + '\n')

    print(f"Output array has been written to {output_filename}")

if __name__ == "__main__":
    main()