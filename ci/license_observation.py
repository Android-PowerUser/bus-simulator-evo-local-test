"""Detect license UI even when it immediately redirects to Google Play."""
def license_block_seen(package, foreground, events):
    return ('com.pairip.licensecheck.' in foreground
            or package + '/com.pairip.licensecheck.' in events)
