#!/usr/bin/env python

import csv
import re
import string
import lxml.html

"""
Make CSV file of ICD codes.
"""


fmt = re.compile(r'^([.()A-Z0-9\-]+)\s+(.+)$')
icd_files = [(8, 'icd8h.htm'), (9, 'icd9h.htm'), (10, 'icd10h.htm')]

wsock = open('icd_codes.csv', 'w', encoding='latin-1')
wtr = csv.DictWriter(
    wsock,
    fieldnames=['scheme', 'code', 'cdc_rec', 'cdc_cause', 'clean_code',
                'description', 'group_num', 'group_name']
)
wtr.writeheader()

for scheme, i in icd_files:

    with open(i, 'r', encoding='iso-8859-1') as fh:
        dom = lxml.html.fromstring(fh.read())
    pre = dom.xpath('//pre')[0]
    txt = pre.text_content().strip()

    lines = txt.split('\n')
    for idx, m in enumerate((fmt.match(k) for k in lines)):
        if m is None:
            raise ValueError('Cannot parse: {0}'.format(lines[idx]))

        code = m.group(1)
        clean_code = code.replace('.', '')

        if code.startswith('('):  # denotes a range of codes, not a single code
            group_num, group_name = m.group(1), m.group(2)
            continue

        # create a codes that match CDC cause and record-axis style
        if scheme == 8:
            if clean_code[0] not in string.ascii_uppercase:
                cdc_rec = cdc_cause = clean_code
            else:  # CDC uses 1 as a flag for injury codes (start with N)
                injury = '1' if clean_code[0] == 'N' else '0'
                cdc_cause = clean_code[1:]
                cdc_rec = cdc_cause.ljust(4) + injury
        else:
            cdc_rec = cdc_cause = clean_code

        wtr.writerow(
            {'scheme': scheme,
             'code': code,
             'cdc_rec': cdc_rec,
             'cdc_cause': cdc_cause,
             'clean_code': clean_code,
             'description': m.group(2),
             'group_num': group_num,
             'group_name': group_name}
        )

wsock.close()
