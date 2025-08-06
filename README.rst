RTLMeter
=======

RTLMeter is a collection of reference designs and tools for the evaluation of
open source EDA tools, primarily Verilator.

The goal of RTLMeter is to collect accurate and reproducible performance
metrics, which can be used to evaluate the performance of tools, and to
evaluate the effect of changes, options or other relevant differences in the
host environment.

License
=======

In order to keep RTLMeter usage simple, the ``designs`` subdirectory contains
code imported from open source repositories (with RTLMeter specific
modifications). Copyright of these resides with their respective authors, and
their licenses are available in their subdirectories, or their upstream
repositories.

To see the source repositories and the licenses of imported designs, run:

.. code:: shell

  ./rtlmeter show --designs
  ./rtlmeter show --licenses

For RTLMeter itself, see `LICENSE
<https://github.com/verilator/rtlmeter/blob/main/LICENSE>`_.

Dependencies
============

We try to keep external dependencies to a minimum. You will need the following
available through your shell ``$PATH``:

- Python 3.10 or newer as ``python3``
- An installation of Verilator as ``verilator``

All other dependencies are managed via a Python virtual environment, please see
the `Getting started guide
<https://verilator.github.io/rtlmeter/gettingstarted.html>`_.

Documentation
=============

Please see the published User and Developer
`documentation <https://verilator.github.io/rtlmeter/>`_.

Nightly metrics
===============

Performance metrics collected from the nightly Verilator CI runs are accessible
through the `Verilator RTLMeter results
<https://verilator.github.io/verilator-rtlmeter-results/>`_ dashboard.
