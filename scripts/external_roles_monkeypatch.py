#!/usr/bin/env python3
"""
Patches installed external roles to fix compatibility issues that can't be
addressed upstream (e.g. version mismatches with newer system packages).
Run automatically after `make install_roles`.
"""
import re
import pathlib

REPO_ROOT = pathlib.Path(__file__).parent.parent


def patch_ssh_hardening_template():
    # dev-sec.ssh-hardening 9.7.0: Jinja2 3.x requires bare booleans in
    # template headers; the role ships with quoted strings ("true"/"false").
    p = REPO_ROOT / 'roles_external/dev-sec.ssh-hardening/templates/opensshd.conf.j2'
    original = p.read_text()
    patched = re.sub(r'"(true|false)"', lambda m: m.group(1).capitalize(), original)
    if patched != original:
        p.write_text(patched)
        print(f'Patched: {p.relative_to(REPO_ROOT)}')
    else:
        print(f'No patch needed: {p.relative_to(REPO_ROOT)}')


if __name__ == '__main__':
    patch_ssh_hardening_template()
