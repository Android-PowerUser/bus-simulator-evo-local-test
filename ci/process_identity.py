"""Distinguish the Android app process from same-name forked watchdogs."""
def main_process(process_table, package):
    matches = {}
    for line in process_table.splitlines():
        fields = line.split()
        if len(fields) == 3 and fields[0].isdigit() and fields[1].isdigit() and fields[2] == package:
            matches[fields[0]] = fields[1]
    roots = [pid for pid, parent in matches.items() if parent not in matches]
    return roots[0] if len(roots) == 1 else ''
