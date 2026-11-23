Importing new designs
=====================

Here we describe the considerations you need to make before, and the process of
adding new benchmarks to RTLMeter.

Requirements about new benchmarks
---------------------------------

Please consider the following before deciding to add a new design. Some of
these (e.g. licensing) are hard requirements, as stated. For others we only
ask that you use your best judgement, and please reach out if you would like
to discuss specifics.

Source repository and Licensing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Any new designs that are to be added to the public RTLMeter repository must
be available as open source code form a publicly hosted repository that
provides unconditional and immediate read-only access to the public, and hence
can be forked if desired.

Designs must be licensed under an open source license that permits the use
of the source code in RTLMeter.

In practice this means that designs from public repositories hosted on GitHub,
GitLab, etc., or hosted publicly by your own organization without access
restrictions, and that use any of the common open source licenses are OK.

Code hosted on public repositories that require registration or use any form
of access control for read access, will generally not be accepted, even if
licensed in a compatible way.

If your design depends on third party components or submodules that have a
different copyright holder, or are licensed under a different license, then
all those dependencies must be available under the same terms as above, and
will need to be included when adding your design.

If you cannot meet all of these requirements, but still would like to use a
design with RTLMeter *privately*, then you can do so as described
:ref:`here <private-benchmarks>`, and you are not required to consider anything
else described here.

Alternatively, if you are the original author, then you can contribute cases
to be included with the RTLMeter Copyright and License itself, if you are
happy to do so.

Maturity
^^^^^^^^

Any design added to the RTLMeter repository must have sufficient maturity
and code quality that they are unlikely to cause difficulties in the use of
RTLMeter. This is required because the intention of RTLMeter is not to
find novel issues in your design, but to aid tool development.

This means that the designs must be sufficiently well tested in the included
configurations that Verilator changes are unlikely to cause breakage. The
existence of bugs is of course often unavoidable, but there should be no known
issues likely to cause problems at a later time. Judging this is hard, but if
you have done sufficient verification to satisfy yourself of the quality of
the contribution, then that is satisfactory.

One particular issue to keep in mind, is the existence of observable race
conditions in the design or especially testbenches. These can cause problems
when changing scheduling algorithms, so please try to avoid knowingly including
them. Again we appreciate race conditions are hard to discover, so we are only
asking for your diligence.

Scale and relevance
^^^^^^^^^^^^^^^^^^^

Benchmarks need to be of a certain size to be useful. This means that if both
compilation and execution takes less than a few seconds, then there is little
information to be learned from analyzing the results. Similarly, if the case
consists of a few hundred lines of code, but simulates billions of clock cycles
then again its usefulness is limited. As an example, we would not be interested
in a simple UART that just checks basic operation during a short simulation.
These are more well suited as test cases rather than benchmarks.

We are interested in large designs, but size should be limited to be usable
in practice. We are unlikely to be able to use designs that require terabytes
of memory to compile, or require days to execute a single simulation. Unless
that is due to a performance bug you wish to demonstrate, in which case we are
very interested.

Please do not be discouraged by the above, and reach out to discuss the
inclusion of something that you are not sure is meeting these requirements.

It is even better if your design is configurable, and the configuration can be
tuned such that it yield a conveniently sized benchmark. The Vortex GPU design
included in RTLMeter is a good example of such a case.

Functionality
^^^^^^^^^^^^^

The function of a design does not matter much beyond the point that it needs
to do something that is considered useful by the community.

We are particularly interested in non-CPU designs, heterogenous designs,
whole SoCs, or designs using coding styles not covered by existing cases.
This is not a requirement, and we are happy to add more CPU designs as well.
If in doubt, please reach out to discuss.

When adding a design, we need to be able to assert basic correctness of
functionality, so the cases provided will need to be able make a boolean
decision on whether the simulation "passed", or "failed". This is required
as we do not want to draw false conclusions by optimizing something away
that was required, then claim a significant speedup only to realize later
that the design is no longer doing what it is supposed to do.

Dependencies
^^^^^^^^^^^^

The goal of RTLMeter is to facilitate tool development, so we need to keep
external dependencies to a minimum, as we cannot afford the time to handle
issues arising from the management of external dependencies. This is the
primary reason why all benchmarks are imported into the RTLMeter repository
in a standardized form as source.

In general, you should assume only a standard, modern Linux environment is
available (e.g. a recent Ubuntu LTS release), but not arbitrary third party
libraries or target toolchains. Even if dependencies are available through
the host package manager today, or you can provide them yourself, managing
these across multiple designs that might require different versions is not
feasible in the long term. This unfortunately excludes the use of external
testing infrastructure like cocotb as well.

If necessary, new designs have to be simplified during the import process to
eliminate external dependencies. For example, if you depend on a complex
third party DRAM model that provides more accurate timing behavior, it is
preferred that you remove this and replace it with something simpler, even
if less accurate, that can be included in source form with the design. This
should not affect the functionality of your design, and should have little
effect on the performance of Verilator that we are trying to evaluate with
RTLMeter.

Similarly, you need to pickle target executables and provide them as blobs,
e.g in a binary, or hex dump form, so we do not need to invoke the target
toolchain when using RTLMeter. The same applies for example if you need
complex external libraries to generate input stimulus to your design. You need
to pre-compute the stimulus, and expected results, and provide them as resource
files when importing the design into RTLMeter.

You can include C/C++ code invoked via the DPI/VPI during simulation, but
you need to provide all dependencies beyond the C/C++ standard library in
source form, as part of the design. For example, you can include the necessary
parts of a soft floating point library, assuming it meets the licensing
requirements laid out above and you can extract only the parts relevant to
the design. That is, please do not bulk import third party libraries as source
if not necessary.

As always, common sense prevails, keeping in mind the goal of RTLMeter is
to be an easy to use performance evaluation platform. When in doubt, please
open a discussion.

Code Structure
^^^^^^^^^^^^^^

In order to import a new design into RTLMeter, it must fit into the
standard structure RTLMeter uses. This is hopefully generic enough to
fit most cases, but if you are facing difficulty please reach out to discuss.

Most importantly, RTLMeter compiles all designs with the Verilator options
``--cc --main --timing``. That is, the simulation driver ``main`` function is
the builtin one provided by Verilator.

If you are using an existing C++ wrapper of your own to drive the verilated
model, you will need to modify your simulation environment by adding a top
level testbench with no inputs to drive your design, and add ``initial`` blocks
there to perform any run-time setup (you can call back into C++ via the DPI if
necessary). If your design is so heavily dependent on the Verilator C++
interface that you cannot reasonably do this, then it is not suitable for
RTLMeter. However, a lot of the existing designs in RTLMeter use
complex external simulation wrappers in their original repositories, and
modifying these to operate via a top level testbench only required small
effort. If you have a proper SystemVerilog testbench that you use with
commercial simulator, that might be a more appropriate starting point for
RTLMeter.

If you originally depend on the Verilator ``--no-timing`` option, then you need
to manually remove timing controls ('``#`` delays') first. It is easiest to do
this by removing the ``--timing``/``--no-timing``` option from Verilator, and
then remove the delays where Verilator complains with a 'NEEDTIMINGOPT' message.

For further constraints on code structure, please see the import steps below.

Steps for adding a new design
-----------------------------

Please follow these steps if you would like to proceed to add a new design to
RTLMeter. Your contribution is appreciated.

Creating the design subdirectory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Every individual design resides in a subdirectory under the ``designs/``
directory located in the root of the RTLMeter repository.

You must create a new subdirectory here. The name of this subdirectory is
the name of the new design.

All files belonging to this specific design, including design source code,
imported dependencies, input files, etc. must reside in this subdirectory.
You must not depend on any resources external to this subdirectory.

There must be no dependencies between different designs either. If you want to
include several cases that share source code, you can use a different
configurations within the same design to achieve this.

If necessary, you can add your cases as multiple designs, duplicating code on
a small scale if necessary, but designs should be meaningfully different not
to warrant bulk duplication. If you can't meet this, please reconsider whether
your case is suitable for RTLMeter.

Adding the design descriptor and source files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Within the design subdirectory, you need to create a RTLMeter descriptor
file, called ``descriptor.yaml``. This is a YAML file that defines how to
compile your design, how to execute tests, its configurations, and some other
required metadata, like the origin and licensing of your design. The format of
the RTLMeter descriptor is described :ref:`here <design-descriptor>`.
You can also refer to the descriptors of existing designs. The 'Example'
design contains a minimal design to showcase the structure.

The only strict requirement about the structure of the design subdirectory is
the presence of the ``descriptor.yaml`` file in its root. Otherwise you can
follow whatever structure is suitable for your case. Conventionally source code
used during compilation is contained in the ``src`` subdirectory, and files
required during execution are contained in the ``tests`` subdirectory. The way
RTLMeter figures out your design is through the ``descriptor.yaml`` file,
so as long as that is correct you can add your code in whatever way is most
appropriate.

Once you added the design descriptor, you can use ``./rtlmeter show --cases``
to see that RTLMeter is now aware of your cases, or to see potential errors.

RTLMeter specific code
^^^^^^^^^^^^^^^^^^^^^^^^^

The only RTLMeter specific change you need to make to your design, is to
add the line

.. code:: systemverilog

    `include "__rtlmeter_top_include.vh"

to the body of your top level module. This includes a small amount of support
code that RTLMeter uses to implement some of its functionality, like enable
waveform tracing or count the number of simulated clock cycles. You should not
need to be aware of the specifics for the purposes of importing your design.

Test cases
^^^^^^^^^^

When choosing test cases, it is preferable that all tests are runnable on
all configurations of your design. However, you can pass configuration specific
arguments to the simulator executable, or add configuration specific tests,
by specifying them in the relevant section of the design descriptor.

Tests need to assert that basic functionality is correct. They can do so either
by being self checking, and terminate the simulation with a non-zero exist
status, or you can use the test ``postHook`` in the design descriptor to run an
external script that can check output or log files.

Please also record the number of simulated clock cycles of each case using
``expectedCycles`` in the design descriptor. Clock cycle counts should be
deterministic, so this provides an additional sanity check on simulation
behavior.

Otherwise there is no restriction on what a test does when it is executed, but
there are some helpful considerations.

If possible, you should include at least one test that is the moral equivalent
of a "Hello world" program. That is, one that runs for as short a time as
possible, and just demonstrates that basic functionality is OK. This is useful
when evaluating Verilator changes, to quickly make sure no major correctness
issues were introduced.

For all other tests, it is helpful to make them somehow scalable in execution
time. That is, to have a parameter that will make the test execute for a longer
or shorter period of time. A lot of the existing cases do this using the
``+iterations`` argument, which the design testbench picks up to change the
initialization or behavior of the simulation.

There are two strategies that are commonly usable to make a test scalable in
simulation time.

The simplest is to make the testbench execute the whole test
multiple time, by repeating the reset sequence and necessary initialization
a given number of time. The testbench for the Vortex design does this for
example.

Alternatively, if your test has some natural parameter that influences
execution time, you can initialize that differently in the testbench. For
example most of the existing CPU designs (e.g. VeeR-\*, OpenTitan,
XiangShan, XuanTie-\*) simulate the execution of a standard workload like the
CoreMark or Dhrystone benchmarks, which have an iteration count parameter. You
can modify your target linker scripts to store this iteration count at a fixed
location in memory, and override the value from the testbench after
initialization.

Having tests scalable like this is not a requirement, and it is OK to provide
tests that perform a constant function, so long as that takes a sufficient
amount of simulation time to be useful for RTLMeter.

Validating the new entry
^^^^^^^^^^^^^^^^^^^^^^^^

Once you have your new design all set up, please run ``./rtlmeter validate``,
which will perform some consistency checks, for example that you have not
added any unnecessary files, or that the repository and license URLs are
reachable.

Finally, please run ``./rtlmeter run --cases 'YourDesign:*'``, and make sure
that all cases can pass successfully.

.. _private-benchmarks:

Private benchmarks
------------------

If you wish to use a private benchmark with RTLMeter, you can follow the
steps above to create a design subdirectory and design descriptor the same way
as described, except you are recommended to symlink the subdirectory under the
``designs/`` directory, instead of moving it there directly. This way you can
manage the external design subdirectory in whatever way you need to while
making RTLMeter aware of its existence.
