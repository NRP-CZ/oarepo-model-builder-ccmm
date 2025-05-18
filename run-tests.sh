#!/bin/bash
set -e

OAREPO_VERSION=${OAREPO_VERSION:-12}
PYTHON=${PYTHON:-python3}
export PIP_EXTRA_INDEX_URL=https://gitlab.cesnet.cz/api/v4/projects/1408/packages/pypi/simple
export UV_EXTRA_INDEX_URL=https://gitlab.cesnet.cz/api/v4/projects/1408/packages/pypi/simple

BUILDER_VENV=".venv-builder"
export INVENIO_INVENIO_RDM_ENABLED=true

if test -d $BUILDER_VENV ; then
	rm -rf $BUILDER_VENV
fi

$PYTHON -m venv $BUILDER_VENV
. $BUILDER_VENV/bin/activate
pip install -U setuptools pip wheel
pip install -e .


MODEL="datasets"
VENV=".venv-tests"

if test -d ./build-tests/$MODEL; then
	rm -rf ./build-tests/$MODEL
fi

oarepo-compile-model ./build-tests/$MODEL.yaml --output-directory ./build-tests/$MODEL -vvv
if test -d $VENV ; then
	rm -rf $VENV
fi
$PYTHON -m venv $VENV
. $VENV/bin/activate
pip install -U setuptools pip wheel nrp-devtools
pip install "oarepo[tests, rdm]==${OAREPO_VERSION}.*"

pip install -e "./build-tests/${MODEL}[tests]"

(
	echo "def test_import():"
	(
		cd build-tests/datasets/ ; 
		find . -type f | \
			egrep "^\./datasets/.*py" | \
			sed 's/\/__init__.py//' | \
			sed 's/\.py$//' | \
			sed 's/\.\///' | \
			tr '/' '.' | \
			grep -v '-' | \
			sed 's/^/    import /' | \
			sed 's/$/ # noqa/'
	)
) > build-tests/test_import.py
pytest build-tests/test_import.py

