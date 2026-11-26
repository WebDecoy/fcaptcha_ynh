Install FCaptcha on a dedicated HTTPS domain. Open the application from the
YunoHost portal to try the widget on the demo page.

The service listens on IPv4 loopback. YunoHost's nginx forwards requests from
the public domain. The signing key and the separate backend verification key
are generated at install and kept in `fcaptcha.env` in the app data directory.
Keep both keys with the backup and never put them in browser code.

To use the widget on another website, add the website's hostname to the
comma-separated `FCAPTCHA_ALLOWED_HOSTNAMES` setting in that file and restart the
service. Configure your application's backend with the verification key and
the FCaptcha domain. See the [integration quickstart](https://docs.webdecoy.com/fcaptcha/quickstart/).

The package runs one process with in-memory state. Outstanding challenges
are lost on restart. Use the original architecture when restoring a backup.
