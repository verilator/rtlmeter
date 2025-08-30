Collated results
================

You can use ``./rtlmeter collate`` to collect and combine all recorded data
from a working directory into as single JSON data file. This collated data
file can be used for archiving results or feeding them into downstream tools
for further processing. You can also use the ``collate`` subcommand to combine
multiple JSON data files into a single one.

Using collated data for reporting
---------------------------------

All ``rtlmeter`` subcommands that display data recorded in a working directory
can also accept a collated data file to use instead, so the following should
produce the same output:

.. code:: shell

   ./rtlmeter report work-a
   ./rtlmeter compare work-a work-b
   ./rtlmeter show --cases work-a

.. code:: shell

   ./rtlmeter collate work-a > data-a.json
   ./rtlmeter collate work-b > data-b.json
   ./rtlmeter report data-a.json
   ./rtlmeter compare data-a.json data-b.json
   ./rtlmeter show --cases data-a.json
