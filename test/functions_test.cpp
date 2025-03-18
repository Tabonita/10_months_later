#include <functions/functions.hpp>

#include <boost/ut.hpp>

using namespace functions;
using namespace boost::ut;

int main() {
  should("add 2 numbers") = [] {
    expect(add<int>(1,2) == 3);
    expect(add<double>(1.2,2.3) == 3.5);
    expect(add<int>(-2,2) == 0);
    expect(add<int>(1.2,2.3) == 3);
    expect(add<double>(1,2) == 3.0);
  };
  should("substract") = [] {
    expect(subtraction(1,2) == -1);
    expect(subtraction(1.2,2.3) == -1.1);
    expect(subtraction(-2,2) == -4);
  };
  should("muptiply") = [] {
    expect(multiply(1,2) == 2);
    expect(multiply(2,2.5) == 5);
    expect(multiply(-2,2) == -4);
  };

  should("divide") = [] {
    expect(divide(1,2) == 0.5);
    expect(divide(5,2.5) == 2);
    expect(divide(-2,2) == -1);
  };
}
