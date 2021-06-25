#include <pybind11/numpy.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include "fhmdot/include/babel_type.hpp"

namespace py = pybind11;

template <typename T> using numpy_array = py::array_t<T, py::array::c_style>;

numpy_array<num_t> view_nocopy(numpy_array<num_t> np_in) {
  py::buffer_info np_in_info = np_in.request();
  std::size_t n = np_in.size() - 2;
  auto ptr = np_in.data() + 1;
  auto fake_deallocator = py::capsule(ptr, [](void *ptr) {});
  numpy_array<num_t> np_out(n, ptr, fake_deallocator);
  return np_out;
}

PYBIND11_MODULE(fhm, m) {
  m.doc() = "Fast Hilbert Matrix Dot - a matrix representation (single matrix "
            "from MPS)";
  m.def("view_nocopy", &view_nocopy,
        "A numpy view of num_t without first and last element");
}