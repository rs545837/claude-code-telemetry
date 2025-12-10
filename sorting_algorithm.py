def quicksort(arr):
    """
    Implements the QuickSort algorithm to sort an array in ascending order.

    Time Complexity: O(n log n) average case, O(n^2) worst case
    Space Complexity: O(log n) due to recursion stack

    Args:
        arr: List of comparable elements to sort

    Returns:
        Sorted list in ascending order
    """
    if len(arr) <= 1:
        return arr

    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]

    return quicksort(left) + middle + quicksort(right)


def merge_sort(arr):
    """
    Implements the Merge Sort algorithm to sort an array in ascending order.

    Time Complexity: O(n log n) in all cases
    Space Complexity: O(n)

    Args:
        arr: List of comparable elements to sort

    Returns:
        Sorted list in ascending order
    """
    if len(arr) <= 1:
        return arr

    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])

    return merge(left, right)


def merge(left, right):
    """Helper function for merge_sort to merge two sorted arrays."""
    result = []
    i = j = 0

    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1

    result.extend(left[i:])
    result.extend(right[j:])
    return result


def bubble_sort(arr):
    """
    Implements the Bubble Sort algorithm to sort an array in ascending order.

    Time Complexity: O(n^2)
    Space Complexity: O(1)

    Args:
        arr: List of comparable elements to sort

    Returns:
        Sorted list in ascending order
    """
    arr = arr.copy()
    n = len(arr)

    for i in range(n):
        swapped = False
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swapped = True
        if not swapped:
            break

    return arr


if __name__ == "__main__":
    test_arr = [64, 34, 25, 12, 22, 11, 90, 88, 45, 50, 23, 36, 18, 77]

    print("Original array:", test_arr)
    print("\nQuickSort result:", quicksort(test_arr))
    print("Merge Sort result:", merge_sort(test_arr))
    print("Bubble Sort result:", bubble_sort(test_arr))

    print("\nTesting with different data types:")
    string_arr = ["banana", "apple", "cherry", "date", "elderberry"]
    print("Strings with QuickSort:", quicksort(string_arr))

    float_arr = [3.14, 2.71, 1.41, 0.57, 2.23]
    print("Floats with Merge Sort:", merge_sort(float_arr))
