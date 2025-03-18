#include <functions/functions.hpp>

#include <algorithm>

namespace functions {

template <typename result, typename first, typename second>
result add (first a, second b) {
  return a + b;
}

template <typename result, typename first, typename second>
result subtraction (first a, second b) {
  return a - b;
}

template <typename result, typename first, typename second>
result multiply (first a, second b) {
   return a * b;
}

template <typename result, typename first, typename second>
result divide (first a, second b) {
  return (double)a/(double)b;
}


}  // namespace functions
