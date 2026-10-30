#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Node.js itself is provisioned by the "nodejs" resource in manifest.toml.
# pnpm is fetched by Corepack at the exact version pinned by upstream in package.json.

# Run a command as the app user, keeping every download cache out of $install_dir
# (so that backups stay lean) in the temporary $build_cache directory.
# $build_cache/bin holds the pnpm shim, which turbo needs to find in the PATH.
_as_app_in_build_env() {
    ynh_exec_as_app env \
        PATH="$build_cache/bin:$PATH" \
        HOME="$build_cache" \
        XDG_CACHE_HOME="$build_cache/cache" \
        COREPACK_HOME="$build_cache/corepack" \
        TURBO_TELEMETRY_DISABLED=1 \
        "$@"
}

_pnpm() {
    _as_app_in_build_env pnpm "$@"
}

# Remove every node_modules folder of the workspace
_remove_node_modules() {
    local dir
    while read -r dir; do
        ynh_safe_rm "$dir"
    done < <(find "$install_dir" -name node_modules -type d -prune)
}

# Build the web app and the server, then keep only the runtime dependencies
_build_reactive_resume() {
    build_cache="$(mktemp --directory)"
    mkdir "$build_cache/bin"
    chown -R "$app:$app" "$build_cache"
    _as_app_in_build_env corepack enable --install-directory="$build_cache/bin" pnpm

    pushd "$install_dir"
        # The mobile app is part of the upstream workspace but is not needed here
        ynh_hide_warnings _pnpm install --frozen-lockfile --prod=false \
            --filter=reactive-resume --filter="web..." --filter="server..."

        ynh_hide_warnings _pnpm turbo run build --filter=web --filter=server --cache-dir="$build_cache/turbo"

        # Same as the official Docker image: only the server's production dependencies are needed at runtime
        _remove_node_modules
        ynh_hide_warnings _pnpm install --frozen-lockfile --prod --prefer-offline --filter="server..."
    popd

    ynh_safe_rm "$build_cache"
}
