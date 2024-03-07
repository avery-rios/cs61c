from unittest import TestCase
from framework import AssemblyTest, print_coverage
import math

class TestAbs(TestCase):
    def _simple_test(self, input, check):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", input)
        t.call("abs")
        t.check_scalar("a0", check)
        t.execute()

    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_one(self):
        self._simple_test(-1, 1)

    def test_two(self):
        self._simple_test(2, 2)

    def test_minus_two(self):
        self._simple_test(-2, 2)

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute()

    def test_empty(self):
        t = AssemblyTest(self, "relu.s")
        array0 = t.array([])
        t.input_array("a0", array0)
        t.input_scalar("a1", len(array0))
        t.call("relu")
        t.execute(code = 78)

    def _test_ok(self, input, output):
        t = AssemblyTest(self, "relu.s")
        array0 = t.array(input)
        t.input_array("a0", array0)
        t.input_scalar("a1", len(array0))
        t.call("relu")
        t.check_array(array0, output)
        t.execute()

    def test_minus_one(self):
        self._test_ok([-1], [0])

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def test_empty(self):
        t = AssemblyTest(self, "argmax.s")
        arr = t.array([])
        t.input_array("a0", arr)
        t.input_scalar("a1", len(arr))
        t.call("argmax")
        t.execute(code = 77)

    def _test_ok(self, input, output):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array = t.array(input)
        # load address of the array into register a0
        t.input_array("a0", array)
        # set a1 to the length of the array
        t.input_scalar("a1", len(array))
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", output)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_one(self):
        self._test_ok([2], 0)

    def test_simple(self):
        self._test_ok([2, 3, -1, 4, -5, -2, 1], 3)

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def _test(self, v0, s0, v1, s1, l):
        t = AssemblyTest(self, "dot.s")
        av0 = t.array(v0)
        av1 = t.array(v1)
        t.input_array("a0", av0)
        t.input_array("a1", av1)
        t.input_scalar("a2", l)
        t.input_scalar("a3", s0)
        t.input_scalar("a4", s1)
        t.call("dot")
        return t

    def _test_exn(self, v0, s0, v1, s1, l, code):
        self._test(v0, s0, v1, s1, l).execute(code = code)

    def _test_ok(self, v0, s0, v1, s1, v):
        l0 = math.ceil(len(v0) / s0)
        l1 = math.ceil(len(v1) / s1)
        t = self._test(v0, s0, v1, s1, min(l0, l1))
        t.check_scalar("a0", v)
        t.execute()

    def test_empty(self):
        self._test_exn([], 1, [], 1, 0, 75)

    def test_zero_stride0(self):
        self._test_exn([1, 2], 0, [1], 1, 1, 76)

    def test_zero_stride1(self):
        self._test_exn([1, 2], 1, [1, 2], 0, 1, 76)

    def test_singleton(self):
        self._test_ok([1], 1, [2], 1, 2)

    def test_simple(self):
        v = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        self._test_ok(v, 1, v, 1, 285)

    def test_stride(self):
        v = [1, 2, 3, 4, 5]
        self._test_ok(v, 2, v, 1, 22)

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):

    def do_matmul(self, m0, m1, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        # we need to include (aka import) the dot.s file since it is used by matmul.s
        t.include("dot.s")

        m0_r = len(m0)
        m0_c = len(m0[0]) if m0_r != 0 else 0
        m1_r = len(m1)
        m1_c = len(m1[0]) if m1_r != 0 else 0

        # create arrays for the arguments and to store the result
        array0 = t.array(sum(m0, []))
        array1 = t.array(sum(m1, []))
        array_out = t.array([0] * sum(map(len, result)))

        # load address of input matrices and set their dimensions
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_r)
        t.input_scalar("a2", m0_c)
        t.input_array("a3", array1)
        t.input_scalar("a4", m1_r)
        t.input_scalar("a5", m1_c)
        # load address of output array
        t.input_array("a6", array_out)

        # call the matmul function
        t.call("matmul")

        # check the content of the output array
        t.check_array(array_out, sum(result, []))

        # generate the assembly file and run it through venus, we expect the simulation to exit with code `code`
        t.execute(code=code)

    def _test_exn(self, m0, m1, code):
        self.do_matmul(m0, m1, [[0]], code)

    def test_empty_0r(self):
        self._test_exn([], [[1]], 72)

    def test_empty_0c(self):
        self._test_exn([[]], [[1]], 72)

    def test_empty_1r(self):
        self._test_exn([[1]], [], 73)

    def test_empty_1c(self):
        self._test_exn([[1]], [[]], 73)

    def test_mismatch(self):
        self._test_exn([[1, 2]], [[1, 2]], 74)

    def test_singleton(self):
        self.do_matmul([[3]], [[2]], [[6]])

    def test_simple(self):
        self.do_matmul(
            [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            [[30, 36, 42], [66, 81, 96], [102, 126, 150]]
        )

    def test_simple2(self):
        self.do_matmul(
            [[2, 3], [1, -5]],
            [[4, 3, 6], [1, -2, 3]],
            [[11, 0, 21], [-1, 13, -9]]
        )

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

    def do_read_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "read_matrix.s")
        # load address to the name of the input file into register a0
        t.input_read_filename("a0", "inputs/test_read_matrix/test_input.bin")

        # allocate space to hold the rows and cols output parameters
        rows = t.array([-1])
        cols = t.array([-1])

        # load the addresses to the output parameters into the argument registers
        t.input_array("a1", rows)
        t.input_array("a2", cols)

        # call the read_matrix function
        t.call("read_matrix")

        # check the output from the function
        t.check_array(rows, [3])
        t.check_array(cols, [3])
        t.check_array_pointer("a0", [1, 2, 3, 4, 5, 6, 7, 8, 9])

        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)

    def test_simple(self):
        self.do_read_matrix()

    def test_open_fail(self):
        self.do_read_matrix('fopen', 90)

    def test_read_fail(self):
        self.do_read_matrix('fread', 91)

    def test_close_fail(self):
        self.do_read_matrix('fclose', 92)

    def test_malloc_fail(self):
        self.do_read_matrix('malloc', 88)

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student.bin"
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        # load input array and other arguments
        arr = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        t.input_array("a1", arr)
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 3)
        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        if code == 0:
            # compare the output file against the reference
            t.check_file_output(outfile, "outputs/test_write_matrix/reference.bin")

    def test_simple(self):
        self.do_write_matrix()

    def test_open_fail(self):
        self.do_write_matrix('fopen', 93)

    def test_write_fail(self):
        self.do_write_matrix('fwrite', 94)

    def test_close_fail(self):
        self.do_write_matrix('fclose', 95)

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        return t

    def _test_args_error(self, args):
        t = self.make_test()
        t.call("classify")
        t.execute(args=args, code=89)

    def test_empty_arg(self):
        self._test_args_error(None)

    def test_single_arg(self):
        self._test_args_error(["arg0"])

    def test_5_args(self):
        self._test_args_error(["arg0", "arg1", "arg2", "arg3", "arg4"])

    def _test_ok(self, m0_file, m1_file, in_file, out_id, val, out, ref_file):
        t = self.make_test()
        t.input_scalar("a2", 0)
        t.call("classify")
        t.check_scalar("a0", val)
        out_file = f"outputs/test_basic_main/student{out_id}.bin"
        t.execute(args=[m0_file, m1_file, in_file, out_file])
        t.check_file_output(out_file, ref_file)
        t.check_stdout(out)

    def _test_sample0(self, in_file, out_id, val, out, ref_file):
        self._test_ok(
            "inputs/simple0/bin/m0.bin",
            "inputs/simple0/bin/m1.bin",
            in_file, out_id,
            val, out, ref_file)

    def test_simple0_input0(self):
        self._test_sample0(
            "inputs/simple0/bin/inputs/input0.bin", 0,
            2, "2\n", "outputs/test_basic_main/reference0.bin")

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")
