This library allows for the basic mathematical operations and logical operation on (basically) infinitely large numbers.

The benefits of using this alternative to integers is that it supports (basically) infinitely large numbers, and the time and space complexity is very efficient.
The downside of using this alternative to integers is that it's only as accurate as a 32-bit float, so if a Scientific Notation Integer is too small, the value stored in memory might not be accurate, and could just be 0.

The Normalization method takes O(log N) time.
Each method for the mathematical and logical operations takes O(log N) time and O(1) space. O(log N) time because it Normalizes the Scientific Notation Integer before any logic occurs for redundancy, the logic itself takes O(1) time.
