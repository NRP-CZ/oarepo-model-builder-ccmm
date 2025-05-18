# Model builder for CCMM-enabled NRP Invenio repositories

## Usage

To use this model builder, add the following line to your model file:

```python

plugins:
  packages:
    - oarepo-model-builder-ccmm
record:
  use:
    - invenio
    - rdm
    - ccmm#dataset
```

and recompile the model. The result will be a ccmm-compatible model where you can
add your own custom fields and types.

## User interface

The builder does not provide a user interface. Please see <https://nrp-cz.github.io/docs>
for details on how to use CCMM within the UI.
