#!/usr/bin/env sh

# Code taken from https://github.com/drdaeman/

# Set up variables
PROJECT_NAME="$1"
RETURN_DIR=$(pwd)

# Detect color terminal
USE_COLOR=""
case "${TERM}" in
    xterm*)
        USE_COLOR="1"
        ;;
esac

# Color scheme
COLOR_RESET="\033[0m"
COLOR_NOTICE="\033[32;01m"
COLOR_ERROR="\033[31;01m"
COLOR_WARN="\033[33;01m"
COLOR_INFO="\033[34;01m"
DATE=$(date +%F)

color() {
    local ID="COLOR_$1"
    if [ -n "${USE_COLOR}" ]; then
        echo $(eval "echo \$$ID")
    fi
}

fatal() {
    local ERRNUM="$1"
    local ERRMSG="$2"

    echo "$(color ERROR)Fatal error:$(color RESET) ${ERRMSG}"
    echo
    exit "${ERRNUM}"
}

action() {
    local MESSAGE="$1"
    echo "${MESSAGE}... "
}

success() {
    echo "$(color NOTICE)[ OK ]$(color RESET)"
}

failure() {
    echo "$(color WARN)[ FAIL ]$(color RESET)"
}

# Expect a project name
[ -n "${PROJECT_NAME}" ] || fatal 1 "Please, specify a project name"

# Check project name validity
echo "${PROJECT_NAME}" | grep -qie '^[a-z][a-z0-9_]*[a-z0-9]$' || fatal 1 "Invalid project name"

# Fail if directory already exists
[ ! -e "${PROJECT_NAME}" ] || fatal 1 "Directory '${PROJECT_NAME}' already exists."

# First, make the project's directory
action "Creating project directory ${PROJECT_NAME}"
    mkdir "${PROJECT_NAME}"
    cd "${PROJECT_NAME}"
success

# Create the basic layout
action "Creating the layout"
    for X in "${PROJECT_NAME}" doc tmp test; do
        mkdir $X
    done
    touch readme.md
    touch "${PROJECT_NAME}/__init__.py"
    cat <<END > "${PROJECT_NAME}/main.py"
#!/usr/bin/env python

"""
This module is used when ${PROJECT_NAME} is run
as a standalone application.
"""

import sys
from optparse import OptionParser


def main():
    parser = OptionParser(prog='${PROJECT_NAME}')
    parser.add_option('-v', '--verbose',
                      action='store_true', dest='verbose', default=False,
                      help='be verbose')
    (options, args) = parser.parse_args()
    return 0

if __name__ == '__main__':
    sys.exit(main())
END
    cat <<END > test/test_sanity.py
#!/usr/bin/env python

import unittest


class SanityTest(unittest.TestCase):
    def runTest(self):
        self.assertTrue(2 * 2 == 4)

if __name__ == '__main__':
    unittest.main()
END
    cat <<END > run
#!/usr/bin/env python

from ${PROJECT_NAME}.main import main
main()
END
    chmod +x run
    cat <<END > LICENSE
Copyright (c) 2011 Paul Miller
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
END
success

# Generate setup.py
action "Creating setup.py"
    cat <<END > setup.py
#!/usr/bin/env python

from distutils.core import setup
import os.path

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name='${PROJECT_NAME}',
    version="0.0.1",
    packages=['${PROJECT_NAME}'],
    package_data={
        '': ['*.txt', '*.rst', '*.md']
    },
    data_files=[
        ('', ['LICENSE'])
    ],

    author='Paul Miller',
    author_email='paulpmillr@gmail.com',
    description='No description entered for ${PROJECT_NAME}',
    url='http://pbagwl.com/projects/${PROJECT_NAME}',
    license='MIT',

    long_description=read('readme.md'),
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Topic :: Utilities',
        'License :: OSI Approved :: MIT License',
    ],
)
END
    cat <<END > MANIFEST.in
include *.txt
include *.rst
include LICENSE
prune tmp
END
success

# Initialize Git repository
action "Initializing Git repository"
    cat <<END > .gitignore
*.pyc
*.pyo
/.coverage
/doc
/dist
/build
/MANIFEST
/${PROJECT_NAME}.egg-info
/tmp/
END
    git init -q && git add "${PROJECT_NAME}" test run setup.py MANIFEST.in readme.md LICENSE .gitignore \
&& success || failure

# Return back to the original working directory
cd "${RETURN_DIR}"
