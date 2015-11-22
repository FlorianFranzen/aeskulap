#!/bin/sh
#
#
#  Aeskulap - DICOM image viewer and network client
#  - generate SPEC-,SOURCES- and SRPM-files from latest git-master and move them
#    into the appropriate directories
#  - you need to check the paths and fix the maintainers name
#
# Copyright (C) 2005 - 2015  Alexander Pipelka
# Copyright (C) 2015  Jens Lody <fedora@jenslody.de>,
#
# This file is part of Aeskulap.
#
#    Aeskulap is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    Aeskulap is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Aeskulap; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#


GITHUB="jenslody-aeskulap"
BASE_URL="https://github.com/jenslody/aeskulap/tarball/master/"
TARBALL_PATH="${HOME}/rpmbuild/SOURCES/"
SPEC_PATH="${HOME}/rpmbuild/SPECS/"
SPEC_FILE="aeskulap.spec"

SCRIPT_DIR=`dirname "$0"`
#echo "x${SCRIPT_DIR}x"
SCRIPT_DIR=`( cd "$SCRIPT_DIR" && pwd )`
#echo "y${SCRIPT_DIR}y"


if test -z "$1"; then
    branch="master"
else
    branch="$1"
fi


# make sure git answers in english
export LC_ALL="C"

# let's import OLD_REV (if there)
if [ -f ./.last_commit ]; then
	. ./.last_commit
else
	OLD_COMMIT=0
fi

cd "$SCRIPT_DIR"

git checkout $branch
git pull
echo "Using 'git log -1' to get the newest commit"
COMMIT=`git log -1 --pretty=format:"%h"`

echo "Found revision: '${COMMIT}'"

DATE=`date +%Y%m%d`

echo "Use checkout-date: '${DATE}'"

cp ${SPEC_FILE} ${SPEC_FILE}.tmp
sed -i "s/%global git .*/%global git $COMMIT/"  ${SPEC_FILE}
sed -i "s/%global checkout_date .*/%global checkout_date $DATE/" ${SPEC_FILE}

rpmdev-bumpspec --comment="Fresh git checkout." --userstring="Jens Lody <fedora@jenslody.de>" ${SPEC_FILE}

vi ${SPEC_FILE}

cp ${SPEC_FILE} ${SPEC_PATH}${SPEC_FILE}
rm -f ${SPEC_FILE}
mv ${SPEC_FILE}.tmp ${SPEC_FILE}

rm -f ${TARBALL_PATH}${GITHUB}-*.tar.gz
wget -c ${BASE_URL}${GITHUB}-${COMMIT}.tar.gz -O ${TARBALL_PATH}${GITHUB}-${COMMIT}.tar.gz

cd ${SPEC_PATH}
rm -f ../SRPMS/${GITHUB}*.src.rpm
rpmbuild -bs ${SPEC_FILE}

echo "OLD_COMMIT=$COMMIT" > ./.last_commit

exit 0
