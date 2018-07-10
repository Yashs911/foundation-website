# Copyright 2018 The Oppia Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##########################################################################

# This file should not be invoked directly, but sourced from other sh scripts.
# Bash execution environent set up for all scripts.

if [ -z "$BASH_VERSION" ]
then
  echo ""
  echo "  Please run me using bash: "
  echo ""
  echo "    bash scripts/$0"
  echo ""
  return 1
fi

EXPECTED_PWD='foundation-website'
# The second option allows this script to also be run from deployment folders.
if [[ ${PWD##*/} != $EXPECTED_PWD ]]; then
  echo ""
  echo "  WARNING   This script should be run from the foundation-website/root folder."
  echo ""
  return 1
fi

export FOUNDATION_DIR=`pwd`
export COMMON_DIR=$(cd $FOUNDATION_DIR/..; pwd)
export MACHINE_TYPE=`uname -m`
export OS=`uname`

# This function takes a command for python as its only input.
# It checks this input for a specific version of python and returns false
# if it does not match the expected prefix.
function test_python_version() {
  EXPECTED_PYTHON_VERSION_PREFIX="2.7"
  PYTHON_VERSION=$($1 --version 2>&1)
  if [[ $PYTHON_VERSION =~ Python[[:space:]](.+) ]]; then
    PYTHON_VERSION=${BASH_REMATCH[1]}
  else
    echo "Unrecognizable Python command output: ${PYTHON_VERSION}"
    # Return a false condition if output of tested command is unrecognizable.
    return 1
  fi
  if [[ "${PYTHON_VERSION}" = ${EXPECTED_PYTHON_VERSION_PREFIX}* ]]; then
    # Return 0 to indicate a successful match.
    # Return 1 to indicate a failed match.
    return 0
  else
    return 1
  fi
}

# First, check the default Python command (which should be found within the user's $PATH).
PYTHON_CMD="python"
# Test whether the 'python' or 'python2.7' commands exist and finally fails when
# no suitable python version 2.7 can be found.
if ! test_python_version $PYTHON_CMD; then
  echo "Unable to find 'python'. Trying python2.7 instead..."
  PYTHON_CMD="python2.7"
  if ! test_python_version $PYTHON_CMD; then
    echo "Could not find a suitable Python environment. Exiting."
    # If OS is Windows, print helpful error message about adding Python to path.
    if [ ! "${OS}" == "Darwin" -a ! "${OS}" == "Linux" ]; then
        echo "It looks like you are using Windows. If you have Python installed,"
        echo "make sure it is in your PATH and that PYTHONPATH is set."
        echo "If you have two versions of Python (ie, Python 2.7 and 3), specify 2.7 before other versions of Python when setting the PATH."
        echo "Here are some helpful articles:"
        echo "http://docs.python-guide.org/en/latest/starting/install/win/"
        echo "https://stackoverflow.com/questions/3701646/how-to-add-to-the-pythonpath-in-windows-7"
    fi
    # Exit when no suitable Python environment can be found.
    return 1
  fi
fi
export PYTHON_CMD

# This should be placed at the very end of the setup script.
export SETUP_DONE=true

if [ "$SETUP_DONE" ]; then
  echo 'Environment setup completed.'
  return 0
fi
