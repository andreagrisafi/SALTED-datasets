# SALTED-datasets

## Configuration numbering

The first XYZ frame corresponds to `coefficients_conf0.npy` and `overlap_conf0.npy` in the published datasets. Cartesian density-response components use the same numbering.

For SALTED versions that support `qm.numbering_start`, set the following field in the existing `qm` section of your `inp.yaml`:

```yaml
qm:
  numbering_start: 0
```

For older SALTED versions that reject this keyword, omit it. Those versions already use zero-based reference filenames.
