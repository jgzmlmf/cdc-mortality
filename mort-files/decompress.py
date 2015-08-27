#!/usr/bin/env python

import os
import re
import glob
import shutil
import zipfile
import logging

"""
Unzip all CDC mortality files.
"""


def parse_archive_year(name):
    """Parse year from archive name."""
    if isinstance(name, zipfile.ZipFile):
        name = name.filename
    m = re.search(r'mort([0-9]{4})us\.zip', name)
    if m is None:
        raise ValueError('Could not parse year from archive {0}'.format(name))
    return int(m.group(1))


def extract_members(z):
    """Extract all files from CDC archive."""

    yr = parse_archive_year(z)
    contents = z.namelist()

    for idx, name in enumerate(contents, 1):
        c = z.getinfo(name)
        logging.info('Extracting {0} from {1}'.format(c.filename, z.filename))
        z.extract(c, path='tmp/')

        # move and rename the file
        shutil.move('tmp/{0}'.format(c.filename), '{0}.{1}.dat'.format(yr, idx))

    logging.info('Extracted {0} files from {1}'.format(idx, z.filename))


def main(archive_paths=None):
    """Extract desired archives."""
    if archive_paths is None:
        archive_paths = glob.glob('archives/*.zip')

    os.mkdir('tmp')
    for a in archive_paths:
        z = zipfile.ZipFile(a)
        extract_members(z)
    os.rmdir('tmp')


if __name__ == '__main__':
    import argparse
    argp = argparse.ArgumentParser(description='Extract CDC archives')
    argp.add_argument('archive_files', nargs='*', help='Files to extract')
    opts = argp.parse_args()
    if len(opts.archive_files) == 0:
        opts.archive_files = None

    logging.basicConfig(level=logging.INFO)
    main(opts.archive_files)
