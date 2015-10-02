GFK_AICS
========

This package is a performance-improved version of GFK by
Exascale Computing Project, RIKEN AICS.

Original [GFK](https://github.com/HumanGenomeCenter/GFK),
Genomon-fusion for K computer, is being developed in Human Genome Center,
the University of Tokyo.

Install
-------

Before installing this package,
you must install original GFK package, 0.4 or later, and the sample data set.
Refer to the original GFK manual for detailed instructions.

To install this package, at first, edit `Makefile.in` to set two variables:

  * `GFKDIR`: specify the directory where original GFK has been installed,
  * `INPUT_DIR`: specify the directory where sample data, `GFKINPUT.*` files, are located.

Then, just do `make`.

Run
---

Sample job scripts for K computer are located in three directories:
`align`, `dedup` and `detect`.
Run job scripts `GFK*.sh` in this order.