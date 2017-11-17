#!/bin/sh

PACKAGE=`python setup.py --fullname`
echo Building $PACKAGE

if [ "$1" = "release" ]; then
  echo "Making release, uploading to PyPi and Anaconda..."

  # Check and test package
  python setup.py check
  python setup.py test
  
  # Python 2
  source ~/anaconda2/bin/activate root
  ~/anaconda2/bin/conda config --set anaconda_upload yes  
  python setup.py sdist                       # Source
  python setup.py bdist_egg                   # Binary
  python setup.py --no-pkg-config bdist_conda # Conda binary

  # Python 3 (source only needed once)
  source ~/anaconda3/bin/activate root
  ~/anaconda3/bin/conda config --set anaconda_upload yes  
  python setup.py bdist_egg                   # Binary
  python setup.py --no-pkg-config bdist_conda # Conda binary

  # Upload using twine
  twine uploader dist/$PACKAGE* --sign

  # docs will be built automatically by readthedocs.org
  
else
  echo "Dry run, not uploading anything..."
  
  # Python 2
  source ~/anaconda2/bin/activate root
  ~/anaconda2/bin/conda config --set anaconda_upload no
  python setup.py sdist                       # Source
  python setup.py bdist_egg                   # Binary
  python setup.py --no-pkg-config bdist_conda # Conda binary

  # Python 3 (source only needed once)
  source ~/anaconda3/bin/activate root
  ~/anaconda3/bin/conda config --set anaconda_upload no
  python setup.py bdist_egg                   # Binary
  python setup.py --no-pkg-config bdist_conda # Conda binary

  # List package
  echo Created following packages
  ls -1 dist/$PACKAGE*

  # Install & test
  python setup.py check
  python setup.py install  
  python setup.py test

  # docs
  python setup.py build_sphinx
  sphinx-build -b doctest -d doc/build/doctrees/ doc/source/ doc/build/

fi

