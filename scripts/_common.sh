#!/bin/bash

build_fcaptcha() {
    ynh_setup_source --dest_dir="$install_dir" --full_replace

    install -d -o "$app" -g "$app" -m 0700 "$install_dir/go-build" "$install_dir/go-mod"
    ynh_exec_as_app env CGO_ENABLED=0 GOTOOLCHAIN=local \
        GOCACHE="$install_dir/go-build" GOMODCACHE="$install_dir/go-mod" \
        go -C "$install_dir/server-go" build -trimpath -o "$install_dir/fcaptcha-server" .
    ynh_safe_rm "$install_dir/go-build"
    ynh_safe_rm "$install_dir/go-mod"

    install -d -m 0755 "$install_dir/static/demo"
    install -m 0644 "$install_dir/client/fcaptcha.js" "$install_dir/static/fcaptcha.js"
    sed -e 's|src="../client/fcaptcha.js"|src="/fcaptcha.js"|' \
        -e "s|FCaptcha.serverUrl = 'http://localhost:3000';|FCaptcha.serverUrl = '';|" \
        "$install_dir/demo/index.html" > "$install_dir/static/demo/index.html"
}

configure_fcaptcha() {
    if [[ ! -f "$data_dir/fcaptcha.env" ]]; then
        ( umask 077
          printf 'FCAPTCHA_SECRET=%s\nFCAPTCHA_VERIFY_SECRET=%s\nFCAPTCHA_ALLOWED_HOSTNAMES=%s\n' \
              "$(openssl rand -hex 32)" "$(openssl rand -hex 32)" "$domain" \
              > "$data_dir/fcaptcha.env" )
    fi

    ynh_config_add_nginx
    ynh_config_add_systemd
    yunohost service add "$app" --description="FCaptcha verification server"
    start_fcaptcha
}

start_fcaptcha() {
    ynh_systemctl --service="$app" --action=start
    curl --fail --silent --show-error --retry 6 --retry-connrefused \
        --max-time 5 "http://127.0.0.1:$port/health" > /dev/null
}
