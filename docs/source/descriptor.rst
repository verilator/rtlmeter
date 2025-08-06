.. _design-descriptor:

Design descriptor format
========================

This section explains the format of the design descriptor YAML file, which
is used by RTLMeter to understand how to handle a design.

For examples, please refer to the existing descriptors in the repository (
``designs/*/descriptor.yaml``).

The formal schema of the descriptor used for run-time validation can
be found in `src/rtlmeter/schema.yaml
<https://github.com/verilator/rtlmeter/blob/main/src/rtlmeter/schema.yaml>`_.

Types of entries
----------------

The YAML descriptor contains various entries, which are structurally either
scalars (values), sequences (lists), or mappings (dictionaries). The following
descriptions use these terms to be explicit about the format.

Various entries in the design descriptor refer to files in the design
subdirectory. All file references are interpreted as paths relative to the
deign directory (that is, relative to the directory containing
``descriptor.yaml``). Furthermore, to prevent picking up any unlisted files
during a build, RTLMeter runs are sandboxed in the working directory via
symlinks that point to the files listed in the design descriptor. This requires
that all file names used within the same descriptor entry to be unique.
That is, you cannot have two different files with the same name that are
stored under different subdirectories and use them in the same descriptor
entry. It is OK (and common) to have files with the same name when used in
different descriptor entries.

Top level properties
--------------------

The following are the top level entries that appear in a design descriptor.

``origin`` - required

   A sequence of source code repositories, with each item begin a mapping with
   properties ``repository``, ``revision``, and ``licenses``. The
   ``repository`` must be an internet accessible URL to the canonical source
   repository.  ``revision`` is the version control identifier for the revision
   that was used as the base to import the design. For Git, use a full 40-digit
   SHA. ``licenses`` is a sequence of file names, pointing to the license files
   of the repository, which must be imported as well.

   There must be at least one repository listed. If you include third party
   dependencies or submodules that either have a different copyright holder, or
   are licensed under a different license, then you must list every such
   dependency separately. There is no need to list submodules licensed under
   the same terms and copyright, if they are managed as part of version
   control.

   Whatever is listed here should be sufficient to reconstruct the source of
   the import (excluding modifications you made specifically for RTLMeter),
   to audit its ownership.

   If you wish to include a design under the RTLMeter license and copyright,
   you can set ``repository`` and ``revision`` to the value 'local' and point
   the ``licenses`` entry to the license file in the root of the RTLMeter
   repository, see the 'Example' design.

   See the Example, OpenTitan, and Vortex designs for example.

``compile`` - required

   The ``compile`` property contains a
   :ref:`compile descriptor<compile-descriptor>`, which defines how to compile
   your design, and is explained below.

``execute`` - required

   The ``execute`` property is a mapping with two entries: ``common``,
   and ``tests``.

   The ``tests`` entry, is a mapping from test names to
   :ref:`execute descriptors<execute-descriptor>`, which define how to execute
   a test. The keys of the ``tests`` entry are used by RTLMeter as the names
   of the tests. That is, they are the ``<TEST>`` part when naming cases with
   ``<DESIGN>:<CONFIGURATION>:<TEST>``.

   Tests defined under the root ``execute`` property will be executed with all
   configurations of the design.

   The ``common`` entry is an execute descriptor shared by all tests when
   :ref:`combining descriptors<combining-descriptors>`.

``configurations`` - optional

   Optionally, you can define different configurations of the design, by
   specifying the ``configurations`` property. The value of this is a mapping
   from configuration names (which will be used as the ``<CONFIGURATION>`` part
   in the names of case), to additional descriptors.

   Under each configuration, you can optionally specify a further ``compile``
   entry, which contains and additional compile descriptor to be merged with
   the root ``compile`` entry, and a further ``execute`` entry, to be merged
   with the root ``execute`` descriptor. The format of these additional entries
   under a configuration is the same as when written in the root of the
   descriptor.

   Tests defined only under a configuration ``execute`` property will be
   executed only with that configuration of the design.

   See the Example, XiangShan, and Vortex designs for example.

   If no ``configurations`` property is defined in the design descriptor, then
   a single configuration named 'default' with empty descriptors is added
   implicitly.

.. _compile-descriptor:

Compile descriptor
------------------

The compile descriptor is a mapping that specifies all information needed for
compiling your design. It contains the following properties

``verilogSourceFiles``

   A sequence of Verilog/SystemVerilog source files to be passed to Verilator.
   Files will be passed to Verilator in the listed order. You must include
   every source file that compilation is to consume. No files will be
   considered via ``-y`` or similar search paths.

``verilogIncludeFiles``

   A sequence of Verilog/SystemVerilog files that you wish to ``\`include``
   from the source files. These will all be linked into a single directory,
   which is then passed to Verilator with ``-I``. This means that of you cannot
   use relative paths in your ``\`include`` directives, only simple file names.

``verilogDefines``

   A mapping from pre-processor variable names to their definition, which will
   be passed to Verilator via ``+define+<KEY>=<VAL>`` options.

``cppSourceFiles``

   Similar to ``verilogSourceFiles``, this is a list of C++ files to be pass to
   Verilator and subsequently compiled and linked into the simulation
   executable.  This is where you can add DPI/VPI code.

``cppIncludeFiles``

   Similar to ``verilogIncludeFiles``, this is a list of header files that you
   want to ``#include`` from the C++ source files. The same restrictions on
   relative paths apply.

``cppDefines``

   similar to ``verilogDefines``, this mapping contains the necessary C
   pre-processor definitions.

``topModule``

   The name of the top level module. Must be defined in the combined
   descriptor.

``mainClock``

   A SystemVerilog hierarchical path expression that refers to the main clock
   signal of the design, relative to the root of the hierarchy (relative to
   SystemVerilog ``$root``). Typically something like ``top_module.clk``. This
   is the clock used by RTLMeter to measure the number or simulated clock
   cycles and report simulation speed as the achieved frequency of this clock.
   Must be defined in the combined descriptor.

``verilatorArgs``

   A sequence of additional command line arguments to pass to Verilator.

.. _execute-descriptor:

Execute descriptor
------------------

``args``

   A sequence of command line arguments to pass to the simulator executable.
   These are typically Verilog 'plusargs' used by the testbench.

``files``

   A sequence of files to be made available during execution. Similar to
   compilation, these are sandboxed by symlinking them into the working
   directory before execution.

``tags``

   Tags applied to this case (used with ``--cases +<TAG>``).

``prepHook``

   An executable file that will be run in the working directory before
   simulation.  You can use this for example to prepare some input resources
   for the test if necessary.

``postHook``

   An executable file that will be run in the working directory after
   simulation.  You can use this for example to check output files are correct,
   if necessary.

.. _combining-descriptors:

Combining descriptors
---------------------

When constructing cases, RTLMeter merges compile descriptors, and execute
descriptors from different entries in the design descriptor. All operation is
then based on the combined descriptors.

Compile descriptors are combined in this order:

#. Root compile descriptor, from the root ``compile`` property
#. If provided, the configuration specific compile descriptor, from
   ``configurations.<CONFIGURATION>.compile``

Execute descriptors are combined in the following order:

#. If provided, the common execute descriptor from
   ``execute.common``
#. If provided, the test specific execute descriptor from
   ``execute.tests.<TEST>`` property
#. If provided, the configuration specific common execute descriptor from
   ``configurations.<CONFIGURATION>.execute.common``
#. If provided, the configuration and test specific execute descriptor from
   ``configurations.<CONFIGURATION>.execute.tests.<TEST>``

When combining descriptors, the three types of entries are combined as follows.

Scalar values are overwritten, later descriptors taking precedence.

Sequences (lists) are concatenated, with entries from later entries appended
to the lists from earlier entries.

Mappings (dictionaries) are merged, with key-value pairs from later mappings
added to earlier mappings, an the values of existing keys overwritten with
the values from the later mappings.

This combining enables test and configuration specific control over the final
descriptor for each case, while allowing the specification of common
information in a single place.
