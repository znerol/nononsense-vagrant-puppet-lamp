#!/usr/bin/python
#
# Usage: python mysql-restore.py srcdir
#
# Given a directory with database dumps, restore each into a database whose
# name is derived from the file name after piping the dump through oppropriate
# decompression utilities. Successfully processed files are REMOVED afterwards.
# If you like to keep your dumps, just symlink them to the source directory.

from __future__ import print_function
from pipes import quote
import os.path, re, subprocess, sys


CAT = '/bin/cat'
MYSQL = '/usr/bin/mysql'
EXTFILTERS = {
        '.bz2': '/bin/bzcat',
        '.gz': '/bin/zcat',
        '.lzma': '/usr/bin/lzcat',
        '.xz': '/usr/bin/xzcat',
}
EXTIGNORE = [
        '.mysql',
        '.sql',
]


def log(message):
    print(message, file=sys.stderr)


def usage_exit():
    log("Usage: {} srcdir".format(sys.argv[0]))
    sys.exit()


def process_file(path, dbname, filters):
    """
    Restore one mysql database.

    Given the full path to a file, a sanitized database name and a list of
    filter commands, restore one mysql database. After the database has been
    restored successfully, the source file is removed.
    """

    log("Restoring mysql database `{0}` from {1}".format(dbname, path))
    sql = os.tmpfile()
    sql.write("DROP DATABASE IF EXISTS `{0}`; CREATE DATABASE `{0}`;".format(dbname))
    sql.seek(0)

    status = subprocess.call([MYSQL], stdin=sql)
    if status:
        log("Failed to create database `{0}`, mysql returned status {1}".format(dbname, status))
        sys.exit(1)

    cmdline = "|".join(["{cat} {path}"] + list(filters) + ["{mysql} {dbname}"]).format(
            cat = CAT,
            path = path,
            mysql = MYSQL,
            dbname = dbname)

    status = subprocess.call(cmdline, shell=True)
    if status:
        log("Failed to restore database `{0}`, mysql returned status {1}".format(dbname, status))
        sys.exit(1)

    log("Successfully restored mysql database `{0}`".format(dbname))
    os.unlink(path)


def process_dir(src):
    """
    Process each file in the given directory

    For each file in the given directory, derive the target database (sanitized
    basename of file) and decompression utilities (by examining file
    extensions).
    """

    for name in os.listdir(src):
        path = os.path.join(src, name)
        if not os.path.isfile(path):
            continue

        extensions = []
        while True:
            (name, ext) = os.path.splitext(name)
            if ext == '':
                break

            extensions.append(ext)

        dbname = re.sub(r'[^a-z0-9]', '_', name)
        filters = reversed([EXTFILTERS[ext] for ext in extensions if ext not in EXTIGNORE])
        process_file(path, dbname, filters)


if __name__ == '__main__':
    if not len(sys.argv) == 2:
        usage_exit()

    src = sys.argv[1]

    if not os.path.isdir(src):
        usage_exit()

    process_dir(src)
