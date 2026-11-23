Running benchmarks
==================

To run a cases, you use the ``./rtlmeter run`` subcommand. This uses the
``verilator`` executable from your ``$PATH`` to compile and execute
simulations, gathering performance metrics as it does.

Steps during a run
------------------

Several distinct steps happen when you run a case. For example, starting from
a clean repository, run:

.. code:: shell

    ./rtlmeter run --cases OpenTitan:default:hello

The above will perform 2 major operations:

#. *Compile* the ``OpenTitan:default`` configuration into a simulator executable
#. *Execute* the compiled simulator to run the ``OpenTitan:default:hello`` test

Both of these are sub-divided into smaller *steps*, and performance metrics are
recorded for each step.

Compilation contains two major steps: ``verilate`` to run Verilator, and
``cppbuild`` to compile and link the output of Verilator (together with design
specific C++ code, if any) into the simulator executable.

Execution contains only one major step, ``execute``, which corresponds to
running the simulator executable.

There are other minor steps involved, for preparing compilation and simulation
inputs, and checking simulation results, which are not relevant for performance
evaluation, and are not instrumented.

To see all major steps that RTLMeter will instrument, you can run:

.. code:: shell

    ./rtlmeter show --steps

Structure of working directory
------------------------------

``./rtlmeter run`` will place all artifacts into a *working directory*,
which is called ``work`` by default. An alternative path to the working
directory can be specified with the ``--workRoot`` option.

After successfully running the example above, the working directory will have
the following structure (with some entries omitted):

.. code:: text

    work
    └── OpenTitan
        └── default
            ├── compile-0
            │   ├── _files
            │   ├── _verilate
            │   └── _cppbuild
            └── execute-0
                └── hello
                    ├── _files
                    ├── _execute
                    ├── _postHook
                    └── _checkCycles

For a given configuration, compilation is performed, and artifacts are stored
in the ``<DESIGN>/<CONFIGURATION>/compile-0`` subdirectory.

Subsequently, for a given case, execution uses the
``<DESIGN>/<CONFIGURATION>/execute-0/<TEST>`` subdirectory when running the
simulation.

Within each of these directories, there are subdirectories starting with ``_``,
that RTLMeter uses to keep track of various thing. There is one of these
``_`` directories per internal step executed by RTLMeter, some of which are
major steps as described above (e.g: ``_verilate`` corresponds to the
``verilate`` step), while others are minor steps not relevant for performance
evaluation (e.g.: ``_files`` corresponds to setting up input files for
compilation or execution).

.. _specifying-cases:

Specifying cases
----------------

The ``--cases`` command line option is used by various sub-commands to limit
operation to the specified cases.

The ``--cases`` option takes a single string as argument. The simplest form
is to specify a single case:

.. code:: shell

    ./rtlmeter run --cases OpenTitan:default:hello

You can also use shell-style wildcards to specify multiple cases (be careful
to escape the file globbing of your shell). For example, to run all cases of
the OpenTitan design:

.. code:: shell

    ./rtlmeter run --cases 'OpenTitan:*'

This will run the subset of all cases (as reported by
``./rtlmeter show --cases``) that match the given pattern.

You can also provide multiple patterns, separated by spaces. For example, to
run two cases:

.. code:: shell

    ./rtlmeter run --cases 'OpenTitan:default:hello OpenTitan:default:cmark'

You can prefix a pattern with ``!`` to exclude matching cases. The following
runs all OpenTitan cases, except for ``OpenTitan:default:hello``:

.. code:: shell

    ./rtlmeter run --cases 'OpenTitan:* !*:hello'

Patterns are processed left to right, and cases are run in the order they
are matched. Exclusions apply only to cases listed earlier. If multiple
patterns match the same case, it will only be run once, at the point it
is specified without being excluded later. For example, the following will
run the ``cmark`` tests on all configurations of all VeeR cores, except
``hiperf``, and then run ``VeeR-EH1:highperf:cmark``:

.. code:: shell

    ./rtlmeter run --cases 'VeeR*:cmark !*:hiperf:* VeeR-EH1:hiperf:cmark'

The point here is that you can fine tune the order in which cases are run,
in case you would like to see some results earlier than others.

If you want, you can of course run all cases with:

.. code:: shell

    ./rtlmeter run --cases "*"

Beware however that this will take a very long time to complete and some cases
need a very large amount of host memory (128GB+).

If all patterns are exclusionary, a leading ``*`` is implied, so for example
you can run all but some very long and very short cases with:

.. code:: shell

    ./rtlmeter run --cases "!Vortex:huge* !XiangShan:default* !*:linux !*:hello"

There are two further ways you can specify cases.

Cases can be marked as belonging to a special set of cases using *tags*.
To see the available tags, you can run ``./rtlmeter show --tags``.
You can specify a tag to the ``--cases`` option as ``+<TAG>``, for example, to
run a standard set of cases suitable for baseline performance evaluation, you
can try:

.. code:: shell

    ./rtlmeter run --cases "+standard"

To select cases not marked with a tag, you can use ``-<TAG>``.

You can also specify a list of patterns in a file, one per line, and pass
``@filename`` to ``--cases``.

You can also combine these, so for example to run some list of cases read
from a file, excluding those that might compile or execute for a long time,
you can use:

.. code:: shell

    ./rtlmeter run --cases "@case-list.txt !+long !+large"

.. _saved-steps:

Saving of intermediate steps performed earlier
----------------------------------------------

When the working directory already contains the required artifacts from an
earlier run, ``rtlmeter run`` will reuse those results, and skip the
corresponding steps on a subsequent run. This can be used to incrementally
collect more data while minimizing latency:

.. code:: shell

    # Quick sanity check
    ./rtlmeter run --cases OpenTitan:default:hello

If you are satisfied with the above, you can then run all remaining cases:

.. code:: shell

    # Run all remaining cases
    ./rtlmeter run --cases 'OpenTitan:*'

This second invocation will skip compilation, and will also skip running the
``hello`` test, as these steps were already performed by the first invocation.

If you want to force rerunning a step (maybe because you realized some
background process kicked in on your computer and made that performance
measurement unreliable), you can delete the relevant part of the working
directory:

.. code:: shell

    rm -rf work/OpenTitan/default/execute-0/aes
    # This will rerun OpenTitan:default:aes
    ./rtlmeter run --cases 'OpenTitan:*'

.. important::

    RTLMeter does not track data dependencies among steps, so doing this
    is only safe if you have not modified the design or verilator in between
    the runs.

Also note that steps that have failed on an earlier run will not be run again
on a subsequent run (that is, failures are saved in the working directory as
well). This is by design, in case a long running benchmarking session (e.g.:
an overnight script) encounters a failure, we do not want to waste time
re-attempting the failed step. To force retrying steps failed on an earlier
run, use the ``--retry`` option of ``./rtlmeter run``, or use a new
working directory.

Rerunning external commands manually
------------------------------------

Whenever an external command is invoked during a step, RTLMeter prints the
working directory, command line, and the location of the log file holding the
stdout/stderr produced by the command.

This is designed to facilitate hacking on (debugging, profiling, etc)
intermediate steps, like the invocation of Verilator, or the running of the
simulation.

For example, when you first run
``./rtlmeter run --cases OpenTitan:default:hello``, it will print something
akin to the following:

.. code:: text

    @@@ (2/6) OpenTitan:default - Verilate
    @@@ CWD: work/OpenTitan/default/compile-0
    @@@ LOG: work/OpenTitan/default/compile-0/_verilate/stdout.log
    @@@ CMD: verilator --cc --main --exe --timing ... omitted ...

You should be able to ``cd`` into the working directory (printed after CWD),
and invoke the printed command (CMD) directly to run exactly the same command
as RTLMeter just did. The command is also written to a one-liner shell
script file ``cmd``, under the ``_<STEP>`` directory, in this case
``_verilate/cmd``. You can run this to reproduce the step. You can also pass
additional command line arguments to the ``cmd`` file, which are passed through
directly:

.. code:: shell

    # Move to working directory
    cd work/OpenTitan/default/compile-0
    # Debug 'verilate' step
    _verilate/cmd --debug --gdb
    # Profile 'verilate' step
    perf record _verilate/cmd

Keep in mind the Verilator ``--no-skip-identical`` and similar options that
might have an effect on a re-run.

Repeating runs for better measurements
--------------------------------------

One issue with benchmarking software performance is the variability in
measurements due to random processes on the host machine (noise). To help
evaluate this variance, and to enable drawing robust conclusions, RTLMeter
supports running compilation and execution multiple times, using the
``--nCompile`` and ``--nExecute`` options of ``./rtlmeter run``. These will
cause RTLMeter to perform repeated compilation and execution of each case.
For example, the following will run each of the specified cases 3 times:

.. code:: shell

    ./rtlmeter run --cases 'OpenTitan:*' --nExecute 3

Actually, what this command really does, is it populates the
``<DESIGN>/<CONFIGURATION>/execute-<N>/<TEST>`` subdirectories for ``<N>``
0, 1, and 2, under the working directory, so you will have 3 samples for
the relevant measurements. If it turns out these are still too noisy, you can
add more samples by increasing the sample count:

.. code:: shell

    ./rtlmeter run --cases 'OpenTitan:*' --nExecute 5

As described in the section about saving of intermediate results, the above
will skip execution for ``<N>`` 0, 1, and 2 (they are available from the
previous run), then populate ``execute-3`` and ``execute-4``. You can collect
more samples this way, as necessary, in the least amount of time.

If you are interested in measuring compilation speed only, you can use:

.. code:: shell

    ./rtlmeter run --cases 'OpenTitan:*' --nCompile 3 --nExecute 0

This will perform 3 repeated compilation of the configurations required by
the specified cases, but will not execute any of the tests.

Note that all execution will use the simulator executable from the first
compilation (that is, from the ``<DESIGN>/<CONFIGURATION>/compile-0``
subdirectory of the working directory), even if multiple compilations were
performed.
