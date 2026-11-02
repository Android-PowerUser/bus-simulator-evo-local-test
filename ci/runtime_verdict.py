"""Conservative runtime verdict; launcher success is not gameplay success."""
def verify_runtime(status, launch):
    return bool(
        status.get('game_installed')
        and status.get('control_launched')
        and status.get('app_survived_120s')
        and status.get('foreground_is_game')
        and not status.get('game_fatal_crash_seen')
        and status.get('system_server_pid_before')
        == status.get('system_server_pid_after')
        and status.get('system_server_pid_before')
        and status.get('app_pid_at_15s')
        == status.get('app_pid_at_45s')
        == status.get('app_pid_at_120s')
        and 'Status: ok' in launch
    )
